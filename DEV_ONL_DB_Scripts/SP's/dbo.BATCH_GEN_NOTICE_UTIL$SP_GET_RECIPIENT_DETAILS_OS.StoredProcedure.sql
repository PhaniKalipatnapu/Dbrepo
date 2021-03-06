/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_OS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name     : BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_OS
 Programmer Name    : IMP Team
 Description        : The procedure BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_DETAILS_OS gets Other State Recipient details from ICAS_Y1
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_OS](
 @Ac_Recipient_CODE         CHAR(2),
 @An_Case_IDNO              NUMERIC(6),
  @Ac_IVDOutOfStateFips_CODE CHAR(7),
 @Ac_PrintMethod_CODE      CHAR(1),
 @Ac_TypeService_CODE      CHAR(1),
 @Ac_Msg_CODE               CHAR(5) OUTPUT,

 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
 DECLARE
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_OS';
         
 DECLARE @Ln_RowCount_QNTY NUMERIC(5),
         @Lc_CaseStatus_Open_CODE      CHAR,
         @Lc_StatusSucess_CODE         CHAR,
         @Lc_StatusFailed_CODE         CHAR,
         @Lc_IVDOutOfStateFips_00_CODE CHAR(2),
         @Ls_Sql_TEXT                  VARCHAR(100) = '',
         @Ls_Sqldata_TEXT              VARCHAR(1000) = '',
         @Ls_DescriptionError_TEXT     VARCHAR(4000),
         @Ld_Current_DATE              DATE,
         @Ld_High_DATE                 DATE;

 --Indicates case Open
 SET @Lc_CaseStatus_Open_CODE = 'O';
 -- Indicates the Interstate Case office
 SET @Lc_IVDOutOfStateFips_00_CODE = '00';
 SET @Ld_High_DATE = '12/31/9999';
 SET @Lc_StatusSucess_CODE = 'S';
 SET @Lc_StatusFailed_CODE = 'F';
 SET @Ld_Current_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
 
  BEGIN TRY
   IF LEN(LTRIM(RTRIM(@Ac_IVDOutOfStateFips_CODE))) = 2
    BEGIN
     SET @Ac_IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE + '00000';
    END

   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_OS';
   SET @Ls_Sqldata_TEXT = ' @Recipient_CODE = ' + @Ac_Recipient_CODE + ', printMethod = ' + @Ac_PrintMethod_CODE + ', TypeService = ' + @Ac_TypeService_CODE + ', Recipient_CODE = ' + @Ac_Recipient_CODE + ', IVDOutOfStateFips_CODE = ' + @Ac_IVDOutOfStateFips_CODE;

   INSERT INTO #NoticeRecipients_P1
               (Recipient_ID,
                Recipient_NAME,
                Recipient_CODE,
                PrintMethod_CODE,
                TypeService_CODE)
   SELECT CASE
           WHEN LEN(LTRIM(RTRIM(recipient_id))) < 7
            THEN STUFF(recipient_id, 1, 0, REPLICATE('0', 7 - LEN(recipient_id)))
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
             FROM (SELECT DISTINCT 
						  @Ac_Recipient_CODE Recipient_CODE,
                          (i.IVDOutOfStateFips_CODE + I.IVDOutOfStateCountyFips_CODE + ISNULL(I.IVDOutOfStateOfficeFips_CODE, @Lc_IVDOutOfStateFips_00_CODE) + ';' + (SELECT State_NAME
                                                                                                                                                                       FROM STAT_Y1 s
                                                                                                                                                                      WHERE s.StateFips_CODE = i.IVDOutOfStateFips_CODE)) Recipient_NAME
                     FROM ICAS_Y1 i
                    WHERE Case_IDNO = @An_Case_IDNO
                      AND i.Status_CODE = @Lc_CaseStatus_Open_CODE
                      AND @Ld_Current_DATE BETWEEN i.Effective_DATE AND i.End_DATE
                      AND i.IVDOutOfStateFips_CODE + I.IVDOutOfStateCountyFips_CODE + ISNULL(I.IVDOutOfStateOfficeFips_CODE, @Lc_IVDOutOfStateFips_00_CODE) = ISNULL(@Ac_IVDOutOfStateFips_CODE, i.IVDOutOfStateFips_CODE + I.IVDOutOfStateCountyFips_CODE + ISNULL(I.IVDOutOfStateOfficeFips_CODE, @Lc_IVDOutOfStateFips_00_CODE))
                      AND i.EndValidity_DATE = @Ld_High_DATE)b)C;
   SET @Ln_RowCount_QNTY = @@ROWCOUNT; 
   IF @Ln_RowCount_QNTY  = 0
    BEGIN
     IF @Ac_IVDOutOfStateFips_CODE <> ''
        AND @Ac_IVDOutOfStateFips_CODE IS NOT NULL
      BEGIN
      SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_OS';
      SET @Ls_Sqldata_TEXT = ' @Recipient_CODE = ' + @Ac_Recipient_CODE + ', printMethod = ' + @Ac_PrintMethod_CODE + ', TypeService = ' + @Ac_TypeService_CODE + ', Recipient_CODE = ' + @Ac_Recipient_CODE + ', IVDOutOfStateFips_CODE = ' + @Ac_IVDOutOfStateFips_CODE;
       INSERT INTO #NoticeRecipients_P1
                   (Recipient_ID,
                    Recipient_NAME,
                    Recipient_CODE,
                    PrintMethod_CODE,
                    TypeService_CODE)
       SELECT CASE
               WHEN LEN(LTRIM(RTRIM(recipient_id))) < 7
                THEN STUFF(recipient_id, 1, 0, REPLICATE('0', 7 - LEN(recipient_id)))
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
                 FROM (SELECT @Ac_Recipient_CODE Recipient_CODE,
                              ( @Ac_IVDOutOfStateFips_CODE + ';' + (SELECT State_NAME
                                                                    FROM STAT_Y1 s
                                                                   WHERE s.StateFips_CODE = SUBSTRING(@Ac_IVDOutOfStateFips_CODE, 1, 2))) Recipient_NAME)b)C;
      END
    END

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
