/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_NA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name      : BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_DETAILS_NA
 Programmer Name     : IMP Team
 Description         : The procedure BATCH_GEN_NOTICE_UTIL$GET_RECP_DETAILS_NA gets NCP  Attorney Details
 Frequency           :
 Developed On        : 03/25/2011
 Called By           : BATCH_GEN_NOTICE_UTIL$EXEC_RECIPIENT_DETAILS_PROC
 Called On           :
---------------------------------------------------------
 Modified By         :
 Modified On         :
 Version No          : 1.0 
---------------------------------------------------------
*/ 
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_NA](
 @Ac_Recipient_CODE        CHAR(2),
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO		   NUMERIC(10),
 @Ac_PrintMethod_CODE      CHAR(1),
 @Ac_TypeService_CODE      CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT)
AS
BEGIN
SET NOCOUNT ON;
 DECLARE @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_DETAILS_NA',
         @Ld_High_DATE      DATE = '12/31/9999';
 DECLARE @Lc_CaseRelationship_CP_CODE     CHAR,
         @Lc_CaseRelationship_NCP_CODE    CHAR,
         @Lc_CaseRelationship_PF_CODE     CHAR,
         @Lc_CaseMemberStatus_Active_CODE CHAR,
         @Lc_StatusApproval_CODE          CHAR,
         @Lc_StatusCase_Open_CODE         CHAR,
         @Lc_StatusSuccess_CODE           CHAR,
         @Lc_StatusFailed_CODE            CHAR,
         @Ls_Sql_TEXT                     VARCHAR(100) = '',
         @Ls_Sqldata_TEXT                 VARCHAR(1000) = '',
         @Ls_DescriptionError_TEXT        VARCHAR(4000),
         @Ld_Current_DATE              DATE;
  
 SET @Lc_CaseRelationship_CP_CODE = 'C';
 SET @Lc_CaseRelationship_NCP_CODE = 'A';
 SET @Lc_CaseRelationship_PF_CODE = 'P';
 SET @Lc_CaseMemberStatus_Active_CODE = 'A';
 SET @Lc_StatusApproval_CODE = 'I';
 SET @Lc_StatusCase_Open_CODE = 'O';
 SET @Lc_StatusFailed_CODE = 'F';
 SET @Lc_StatusSuccess_CODE = 'S';
 SET @Ld_Current_DATE =dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

 BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_DETAILS_NA';
   SET @Ls_Sqldata_TEXT = ' @Recipient_CODE = ' + @Ac_Recipient_CODE + ', Case_IDNO = ' + CONVERT(VARCHAR(MAX), @An_Case_IDNO) + ', printMethod = ' + @Ac_PrintMethod_CODE + ', TypeService = ' + @Ac_TypeService_CODE;

   INSERT INTO #NoticeRecipients_P1
               (Recipient_ID,
                Recipient_NAME,
                Recipient_CODE,
                PrintMethod_CODE,
                TypeService_CODE)
   SELECT CASE
           WHEN LEN(LTRIM(RTRIM(recipient_id))) < 10
            THEN STUFF(recipient_id, 1, 0, REPLICATE('0', 10 - LEN(recipient_id)))
           ELSE recipient_id
          END recipient_id,
          Recipient_NAME,
          Recipient_CODE,
          Print_METHOD,
          Type_SERVICE
     FROM (SELECT (SUBSTRING(b.Recipient_NAME, 1, CHARINDEX(';', b.Recipient_NAME) - 1)) recipient_id,
                  (SUBSTRING(b.Recipient_NAME, (CHARINDEX(';', b.Recipient_NAME) + 1), LEN(b.Recipient_NAME))) Recipient_NAME,
                  b.Recipient_CODE,
                  @Ac_PrintMethod_CODE AS Print_METHOD,
                  @Ac_TypeService_CODE AS Type_SERVICE
             FROM (SELECT @Ac_Recipient_CODE Recipient_CODE,
                          (CONVERT(VARCHAR(MAX), d.DocketPerson_IDNO) + ';' + o.OtherParty_NAME) Recipient_NAME
                     FROM DPRS_Y1 d,
                          OTHP_Y1 o
                    WHERE File_ID = (SELECT File_ID
                                       FROM CASE_Y1 c
                                      WHERE c.Case_IDNO = @An_Case_IDNO
                                        AND c.StatusCase_CODE = 'O')
                      AND d.TypePerson_CODE = 'A'
                      AND d.AssociatedMemberMci_IDNO = @An_MemberMci_IDNO
                      AND d.EndValidity_DATE = @Ld_High_DATE
                      AND @Ld_Current_DATE BETWEEN d.EffectiveStart_DATE AND d.EffectiveEnd_DATE
                      AND d.DocketPerson_IDNO = o.OtherParty_IDNO
                      AND o.EndValidity_DATE = @Ld_High_DATE)b)c;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Ln_Error_NUMB NUMERIC (11), @Ln_ErrorLine_NUMB NUMERIC (11);

         SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
                @Ln_Error_NUMB = ERROR_NUMBER (),
                @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF ERROR_NUMBER () <> 50001
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB       = @Ln_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Ln_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;
         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
