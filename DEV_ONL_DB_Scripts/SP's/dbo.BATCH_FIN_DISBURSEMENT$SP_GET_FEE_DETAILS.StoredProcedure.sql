/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_GET_FEE_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_GET_FEE_DETAILS
Programmer Name 	: IMP Team
Description			: Procedure to get Fee details for IRS Offset / DRA
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_GET_FEE_DETAILS] (
 @An_OffsetEligIrs_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_OffsetFeeIrs_AMNT     NUMERIC(11, 2) OUTPUT,
 @An_DraFee_AMNT           NUMERIC(11, 2) OUTPUT,
 @An_DisbEligYtdDra_AMNT   NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Ls_Procedure_NAME     VARCHAR (100) = 'SP_GET_FEE_DETAILS';
  DECLARE @Ln_Error_NUMB            NUMERIC (11),
          @Ln_ErrorLine_NUMB        NUMERIC (11),
          @Ls_Sql_TEXT              VARCHAR (100) = '',
          @Ls_SqlData_TEXT          VARCHAR (1000),
          @Ls_ErrorMessage_TEXT     VARCHAR (4000);

  BEGIN TRY
   SET @An_OffsetEligIrs_AMNT = 75;
   SET @An_OffsetFeeIrs_AMNT = 25;
   SET @An_DisbEligYtdDra_AMNT = 500;
   SET @An_DraFee_AMNT = 25;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = ' ';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
 END


GO
