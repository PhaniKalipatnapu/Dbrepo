/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_JOB_STATUS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_JOB_STATUS
Programmer Name		: IMP Team
Description			: This procedure is used to get the job status i.e.) Success or Abend from BSTL_Y1 table
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_JOB_STATUS]
 @As_Process_NAME             VARCHAR(100),
 @As_Procedure_NAME           VARCHAR(100),
 @Ac_Status_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionErrorOut_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccessS_CODE CHAR(1) = 'S',
          @Lc_StatusFailedF_CODE  CHAR(1) = 'F',
          @Lc_DailyJob_ID         CHAR(5) = 'DAILY',
          @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_COMMON$SP_GET_JOB_STATUS',
          @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_Sqldata_TEXT          VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Status_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionErrorOut_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'SELECT PARM_Y1 ';
   SET @Ls_Sqldata_TEXT = ' SELECT STATUS - BSTL ' + 'Process_NAME  = ' + @As_Process_NAME + ', Procedure_NAME = ' + @As_Procedure_NAME;

   SELECT TOP 1 @Ac_Status_CODE = Status_CODE,
                @As_DescriptionError_TEXT = DescriptionError_TEXT
     FROM (SELECT Status_CODE,b.BatchLogSeq_NUMB,
                  DescriptionError_TEXT
             FROM PARM_Y1 a,
                  BSTL_Y1 b
            WHERE a.Process_NAME = @As_Process_NAME
              AND a.Procedure_NAME = @As_Procedure_NAME
              AND a.EndValidity_DATE = @Ld_High_DATE
              AND a.Job_ID = b.Job_ID
              AND Run_DATE = (SELECT Run_DATE
                                FROM PARM_Y1 d
                               WHERE Job_ID = @Lc_DailyJob_ID
                                 AND EndValidity_DATE = @Ld_High_DATE)
                                 ) AS c  ORDER BY BatchLogSeq_NUMB DESC;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'NO DATA FOUND IN PARM_Y1 BSTL_Y1 FOR THE PACKAGE AND PROCEDURE';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccessS_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailedF_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();      
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();      

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;
    
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionErrorOut_TEXT OUTPUT;
  END CATCH
 END


GO
