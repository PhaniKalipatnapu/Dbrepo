/****** Object:  StoredProcedure [dbo].[BATCH_EST_OUTGOING_FC$SP_UPDATE_GENERATE_PDF_INFO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_OUTGOING_FC$SP_UPDATE_GENERATE_PDF_INFO
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_EST_OUTGOING_FC$SP_UPDATE_GENERATE_PDF_INFO batch procedure is to 
					  update generate pdf info as and when they get generated
Frequency		:	'DAILY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_OUTGOING_FC$SP_UPDATE_GENERATE_PDF_INFO]
 @An_Barcode_NUMB          NUMERIC(12),
 @Ac_Msg_CODE              CHAR (5) = '' OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) = '' OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_TypeError_CODE     CHAR(1) = 'E',
          @Lc_GeneratePdfY_INDC  CHAR(1) = 'Y',
          @Lc_Job_ID             CHAR(7) = 'DEB8053',
          @Ls_Process_NAME       VARCHAR(100) = 'BATCH_EST_OUTGOING_FC',
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_UPDATE_GENERATE_PDF_INFO',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_RestartLine_NUMB      NUMERIC(5, 0) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Li_RowCount_QNTY         SMALLINT,
          @Lc_Empty_TEXT            CHAR = '',
          @Lc_Msg_CODE              CHAR(5),
          @Lc_BateError_CODE        CHAR(5) = '',
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Run_DATE              DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'UPDATE PDAFP_Y1';
   SET @Ls_Sqldata_TEXT = 'Barcode_NUMB = ' + CAST(@An_Barcode_NUMB AS VARCHAR);

   UPDATE PDAFP_Y1
      SET GeneratePdf_INDC = @Lc_GeneratePdfY_INDC
    WHERE Barcode_NUMB = @An_Barcode_NUMB;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'RECORD NOT UPDATED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
