/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_CHECK$SP_GET_CHECK_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_EXT_CHECK$SP_GET_CHECK_DETAILS
Programmer Name	:	IMP Team.
Description		:	Get the data from ECHCK_Y1 table to generate Check in PDF formate
Frequency		:	
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_CHECK$SP_GET_CHECK_DETAILS]
 @Ac_Process_INDC		  CHAR(1),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE CHAR(1) = 'F',
          @Lc_Procedure_NAME    CHAR(30) = 'SP_GET_CHECK_DETAILS';
  DECLARE @Ln_Error_NUMB     NUMERIC(11),
          @Ln_ErrorLine_NUMB NUMERIC(11),
          @Ls_Sql_TEXT       VARCHAR(100),
          @Ls_Sqldata_TEXT   VARCHAR(1000);

  BEGIN TRY
   SET @Ls_Sql_TEXT ='SELECT ECHCK_Y1';
   SET @Ls_Sqldata_TEXT ='Process_INDC = ' + @Ac_Process_INDC;
   
   SELECT e.Check_NUMB,
          e.Check_DATE,
          e.Receipt_DATE,
          e.Check_AMNT,
          e.Payee_NAME,
          e.Payor_NAME,
          e.Case_IDNO,
          e.IVDOutOfStateCase_ID,
          e.PaymentBatch_CODE,
          e.FeesTaken_AMNT,
          e.Line1_ADDR,
          e.Line2_ADDR,
          e.Line3_ADDR,
          e.Line4_ADDR,
          e.CheckAmountLiteral_TEXT
     FROM ECHCK_Y1 e
    WHERE e.Process_INDC = ISNULL(@Ac_Process_INDC,'')
    ORDER BY Check_NUMB;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END 

GO
