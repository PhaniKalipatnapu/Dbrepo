/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIAMJR]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIAMJR
Programmer Name	:	IMP Team.
Description		:	This procedure loads the major and minor activity details.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIAMJR]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT, 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY  INT = 0,
          @Lc_Failed_CODE    CHAR(1) = 'F',
          @Lc_Success_CODE   CHAR(1) = 'S',
          @Lc_Space_TEXT     CHAR(1) = ' ',
          @Lc_TypeError_CODE CHAR(1) = 'E',
          @Lc_BateError_CODE CHAR(5) = 'E0944',
          @Lc_Job_ID         CHAR(7) = 'DEB0830',
          @Lc_Process_NAME   CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME VARCHAR(50) = 'SP_PROCESS_BIAMJR',
          @Ld_Highdate_DATE  DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BPAMJR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPAMJR_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPAMJR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPAMJR_Y1
          (ActivityMajor_CODE,
           BiSubsystem_CODE,
           DescriptionActivity_TEXT,
           PrActivityMajorInd_NUMB,
           Ahis_INDC,
           Ehis_INDC,
           Ssn_INDC,
           Plic_INDC,
           Ssi_INDC,
           AhisCp_INDC,
           AhisNcp_INDC,
           Bankruptcy07_CODE,
           Bankruptcy13_CODE,
           FinAsset_INDC,
           NonFinAsset_INDC,
           Incarceration_INDC,
           Stop_INDC,
           TypeOthpSource_CODE)
   SELECT a.ActivityMajor_CODE,
          a.SubSystem_CODE AS BiSubsystem_CODE,
          a.DescriptionActivity_TEXT,
          @Ln_Zero_NUMB AS PrActivityMajorInd_NUMB,
          @Lc_Space_TEXT AS Ahis_INDC,
          @Lc_Space_TEXT AS Ehis_INDC,
          @Lc_Space_TEXT AS Ssn_INDC,
          @Lc_Space_TEXT AS Plic_INDC,
          @Lc_Space_TEXT AS Ssi_INDC,
          @Lc_Space_TEXT AS AhisCp_INDC,
          @Lc_Space_TEXT AS AhisNcp_INDC,
          @Lc_Space_TEXT AS Bankruptcy07_CODE,
          @Lc_Space_TEXT AS Bankruptcy13_CODE,
          @Lc_Space_TEXT AS FinAsset_INDC,
          @Lc_Space_TEXT AS NonFinAsset_INDC,
          @Lc_Space_TEXT AS Incarceration_INDC,
          a.Stop_INDC,
          @Lc_Space_TEXT AS TypeOthpSource_CODE
     FROM AMJR_Y1 a
    WHERE a.EndValidity_DATE = @Ld_Highdate_DATE;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_Failed_CODE;
    SET @An_RecordCount_NUMB = 0;
    SET @Ln_Error_NUMB = ERROR_NUMBER ();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
    SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

    IF @Ln_Error_NUMB <> 50001
     BEGIN
      SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
     END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   END
  END CATCH
 END 

GO
