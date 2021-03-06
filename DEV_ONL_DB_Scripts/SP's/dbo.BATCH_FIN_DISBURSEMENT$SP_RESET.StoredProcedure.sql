/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_RESET]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DISBURSEMENT$SP_RESET
Programmer Name 	: IMP Team
Description			: Procedure to reset the variable when recipient changes.
Frequency			: 'DAILY'
Developed On		: 01/31/2012
Called BY			: BATCH_FIN_DISBURSEMENT$SP_DISB_RECOUP
Called On			: None
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_RESET]
 @An_TotDisburse_AMNT      NUMERIC (11, 2) OUTPUT,
 @An_Disburse_QNTY         NUMERIC (6) OUTPUT,
 @Ac_CdEftChk_INDC         CHAR (1) OUTPUT,
 @Ac_CpDeceInstInca_CODE   CHAR (1) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @Ab_RecpQueried_BIT       BIT OUTPUT,
 @Ab_ChldQueried_BIT       BIT OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_No_INDC            CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_RESET';
  DECLARE @Ln_Error_NUMB        NUMERIC(11),
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Ls_Sql_TEXT          VARCHAR(100) = '',
          @Ls_Sqldata_TEXT      VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT NVARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   -- Resetting Values for the new recipient
   SET @Ls_Sql_TEXT = 'SP_RESET DELETING #Tlhld_P1 TABLE';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #Tlhld_P1;

   SET @Ab_RecpQueried_BIT = 0;
   SET @Ab_ChldQueried_BIT = 0;
   SET @An_TotDisburse_AMNT = 0;
   SET @An_Disburse_QNTY = 0;
   SET @Ac_CdEftChk_INDC = @Lc_No_INDC;
   SET @Ac_CpDeceInstInca_CODE = @Lc_No_INDC;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    SET @Ln_Error_NUMB = ERROR_NUMBER ();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
    SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   END
  END CATCH;
 END;


GO
