/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_GR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
---------------------------------------------------------
 Procedure Name   : BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_GR
 Programmer Name  : IMP Team
 Description      : The procedure BATCH_GEN_UTIL$GET_RECP_DETAILS_NCP gets NCP/PF  Recipient Details
 Frequency        :
 Developed On     : 03/25/2011
 Called By        : BATCH_GEN_UTIL$EXEC_RECP_DETAILS_PROC
 Called On        :
---------------------------------------------------------
 Modified By      :
 Modified On      :
 Version No       : 1.0 
---------------------------------------------------------
*/  
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_GR] (
 @Ac_Recipient_CODE        CHAR (2),
 @An_Case_IDNO             NUMERIC (6),
 @Ac_PrintMethod_CODE          CHAR (2),
 @Ac_TypeService_CODE          CHAR (2),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  BEGIN TRY
   DECLARE @Lc_CaseRelationship_GR_CODE     CHAR (1) = 'G',
           @Lc_CaseRelationship_NCP_CODE    CHAR (1) = 'A',
           @Lc_CaseMemberStatus_Active_CODE CHAR (1) = 'A',
           @Lc_StatusCase_open_CODE         CHAR (1) = 'O',
           @Lc_StatusSuccess_CODE           CHAR (1) = 'S',
           @Lc_StatusFailed_CODE            CHAR (1) = 'F',
           @Ls_Procedure_NAME               VARCHAR (100) = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_GR',
           @Ld_Today_DATE            DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME ();
   DECLARE @Ls_Sql_TEXT              VARCHAR (100) = '',
           @Ls_Sqldata_TEXT          VARCHAR (1000) = '',
           @Ls_DescriptionError_TEXT VARCHAR (4000);
           
   DECLARE @Li_Error_NUMB     INT = 0,
           @Li_ErrorLine_NUMB INT = 0;

   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_GR';
   SET @Ls_Sqldata_TEXT = ' @Recipient_CODE = ' + @Ac_Recipient_CODE + ', Case_IDNO = ' + CAST (@An_Case_IDNO AS VARCHAR (6)) + ', PrintMethod = ' + @Ac_PrintMethod_CODE + ', TypeService = ' + @Ac_TypeService_CODE;

   WITH Nrep_CTE
        AS (SELECT d.MemberMci_IDNO,
                   d.Last_NAME,
                   d.First_NAME,
                   d.Middle_NAME,
                   d.Suffix_NAME
              FROM CMEM_Y1 cm
                   JOIN DEMO_Y1 d
                    ON cm.MemberMci_IDNO = d.MemberMci_IDNO
                   JOIN CASE_Y1 f
                    ON cm.Case_IDNO = f.Case_IDNO
                       AND f.StatusCase_CODE = @Lc_StatusCase_open_CODE
             WHERE cm.Case_IDNO = @An_Case_IDNO
               AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatus_Active_CODE
               AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationship_GR_CODE)
               AND EXISTS (SELECT 1
                             FROM CMEM_Y1 ncp
                            WHERE ncp.Case_IDNO = @An_Case_IDNO
                              AND ncp.CaseRelationship_CODE = @Lc_CaseRelationship_NCP_CODE
                              AND ncp.CaseMemberStatus_CODE = @Lc_CaseMemberStatus_Active_CODE
                              AND EXISTS (SELECT 1
                                            FROM DEMO_Y1 d
                                           WHERE d.MemberMci_IDNO = cm.MemberMci_IDNO
                                             AND DATEADD (YYYY, 18, d.Birth_DATE) > @Ld_Today_DATE)))
     
       INSERT INTO #NoticeRecipients_P1
			   (Recipient_ID,
				Recipient_NAME,
				Recipient_CODE,
				PrintMethod_CODE,
				TypeService_CODE)
        SELECT CASE
           WHEN LEN (LTRIM (RTRIM (a.recipient_id))) < 10
            THEN STUFF (recipient_id, 1, 0, REPLICATE ('0', 10 - LEN (a.recipient_id)))
           ELSE a.recipient_id
          END AS Recipient_ID,
          a.Recipient_NAME,
          a.Recipient_CODE,
          a.Print_METHOD,
          a.Type_SERVICE
     FROM (SELECT (SUBSTRING (b.Recipient_NAME, 1, CHARINDEX (';', b.Recipient_NAME) - 1)) recipient_id,
                  (SUBSTRING (b.Recipient_NAME, (CHARINDEX (';', b.Recipient_NAME) + 1), LEN (b.Recipient_NAME))) Recipient_NAME,
                  b.Recipient_CODE,
                  @Ac_PrintMethod_CODE AS Print_METHOD,
                  @Ac_TypeService_CODE AS Type_SERVICE
             FROM (SELECT @Ac_Recipient_CODE Recipient_CODE,
                          (CONVERT (VARCHAR (10), ct.MemberMci_IDNO) + ';' + LTRIM (RTRIM (ct.Last_NAME)) + ' ' + LTRIM (RTRIM (ct.Suffix_NAME)) + ' ' + LTRIM (RTRIM (ct.First_NAME)) + ' ' + LTRIM (RTRIM (ct.Middle_NAME))) Recipient_NAME,
                          @Ac_PrintMethod_CODE AS Print_METHOD,
                          @Ac_TypeService_CODE AS Type_SERVICE
                     FROM Nrep_CTE ct) b) a;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
