/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_NO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name     : BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_DETAILS_NO
 Programmer Name    : IMP Team
 Description        : The procedure BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_DETAILS_NO gets Non Ordered Party Recipient Details
 Frequency          :
 Developed On       : 03/25/2011
 Called By          : BATCH_GEN_NOTICE_UTIL$EXEC_RECIPIENT_DETAILS_PROC
 Called On          :
---------------------------------------------------------
 Modified By        :
 Modified On        :
 Version No         : 1.0 
---------------------------------------------------------
*/  

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_NO]
 @Ac_Recipient_CODE        CHAR(2),
 @An_Case_IDNO             NUMERIC(6),
 @An_OthpSource_IDNO       NUMERIC(9),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @Ac_PrintMethod_CODE     CHAR(1),
 @Ac_TypeService_CODE     CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
BEGIN
SET NOCOUNT ON;

 DECLARE @Li_MemberRecordCount_NUMB       INT			= 0,
         @Lc_CaseRelationship_CP_CODE     CHAR(1)		= 'C',
         @Lc_CaseRelationship_NCP_CODE    CHAR(1)		= 'A',
         @Lc_CaseRelationship_PF_CODE     CHAR(1)		= 'P',
         @Lc_CaseMemberStatus_Active_CODE CHAR(1)		= 'A',
         @Lc_StatusSucess_CODE            CHAR(1)		= 'S',
         @Lc_StatusFailed_CODE            CHAR(1)		= 'F',
         @Ls_Procedure_NAME				  VARCHAR (100) = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_NO';
 DECLARE @Ls_Sql_TEXT                     VARCHAR(100)	= '',
         @Ls_Sqldata_TEXT                 VARCHAR(1000) = '',
         @Ls_DescriptionError_TEXT        VARCHAR(4000);
 
  BEGIN TRY
   SELECT @Li_MemberRecordCount_NUMB = COUNT(1)
     FROM CMEM_Y1 c
    WHERE c.MemberMci_IDNO = @An_OthpSource_IDNO
      AND c.Case_IDNO  = @An_Case_IDNO;

   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_NO';
   SET @Ls_Sqldata_TEXT = ' @Recipient_CODE = ' + @Ac_Recipient_CODE + ', Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', printMethod = ' + @Ac_PrintMethod_CODE + ', TypeService = ' + @Ac_TypeService_CODE + ', MajorIntSEQ_NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS VARCHAR) + ', OthpSource_IDNO = ' + CAST(@An_OthpSource_IDNO AS VARCHAR);

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
     FROM (SELECT (SUBSTRING(b.Recipient_NAME, 1, CHARINDEX(';', b.Recipient_NAME) - 1))recipient_id,
                  (SUBSTRING(b.Recipient_NAME, (CHARINDEX(';', b.Recipient_NAME) + 1), LEN(b.Recipient_NAME))) Recipient_NAME,
                  b.Recipient_CODE,
                  @Ac_PrintMethod_CODE AS Print_METHOD,
                  @Ac_TypeService_CODE AS Type_SERVICE
             FROM(SELECT @Ac_Recipient_CODE Recipient_CODE,
                         (CASE
                           WHEN @Li_MemberRecordCount_NUMB > 0
                            THEN (SELECT (CAST(MemberMci_IDNO AS VARCHAR) + ';' + LTRIM(RTRIM(Last_NAME)) + ' ' + LTRIM(RTRIM(Suffix_NAME)) + ' ' + LTRIM(RTRIM(First_NAME)) + ' ' + LTRIM(RTRIM(Middle_NAME))) Recipient_NAME
                                    FROM DEMO_Y1 d
                                   WHERE MemberMci_IDNO IN (SELECT MemberMci_IDNO
                                                              FROM (SELECT MemberMci_IDNO
                                                                      FROM CMEM_Y1 c
                                                                     WHERE c.Case_IDNO = @An_Case_IDNO
                                                                       AND c.CaseRelationship_CODE IN (@Lc_CaseRelationship_CP_CODE, @Lc_CaseRelationship_NCP_CODE, @Lc_CaseRelationship_PF_CODE)
                                                                       AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatus_Active_CODE
                                                                       AND c.MemberMci_IDNO <> @An_OthpSource_IDNO) a))
                           WHEN @Li_MemberRecordCount_NUMB = 0
                            THEN (SELECT (CAST(MemberMci_IDNO AS VARCHAR) + ';' + LTRIM(RTRIM(Last_NAME)) + ' ' + LTRIM(RTRIM(Suffix_NAME)) + ' ' + LTRIM(RTRIM(First_NAME)) + ' ' + LTRIM(RTRIM(Middle_NAME))) Recipient_NAME
                                    FROM DEMO_Y1 d
                                   WHERE d.MemberMci_IDNO = (SELECT MemberMci_IDNO
                                                             FROM (SELECT MemberMci_IDNO
                                                                     FROM CMEM_Y1 c
                                                                    WHERE c.Case_IDNO = @An_Case_IDNO
                                                                      AND c.CaseRelationship_CODE IN (@Lc_CaseRelationship_CP_CODE, @Lc_CaseRelationship_NCP_CODE, @Lc_CaseRelationship_PF_CODE)
                                                                      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatus_Active_CODE
                                                                      AND c.MemberMci_IDNO <> (SELECT Reference_ID
                                                                                                 FROM DMJR_Y1 m
                                                                                                WHERE m.Case_IDNO = @An_Case_IDNO
                                                                                                  AND m.MajorIntSEQ_NUMB = @An_MajorIntSeq_NUMB
                                                                                                  AND m.OthpSource_IDNO = @An_OthpSource_IDNO)) a))
                           ELSE ' '
                          END)Recipient_NAME) b)c;

   SET @Ac_Msg_CODE = @Lc_StatusSucess_CODE;
  
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
