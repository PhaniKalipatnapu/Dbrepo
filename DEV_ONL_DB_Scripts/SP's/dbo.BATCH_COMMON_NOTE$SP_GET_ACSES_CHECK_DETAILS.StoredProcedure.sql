/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_NOTE$SP_GET_ACSES_CHECK_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_NOTE$SP_GET_ACSES_CHECK_DETAILS
Programmer Name		: IMP Team
Description			: 
Frequency			: 
Developed On		:	04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_NOTE$SP_GET_ACSES_CHECK_DETAILS]
 @Ac_Case_IDNO             CHAR(6),
 @An_Check_NUMB            NUMERIC(19),
 @An_Check_AMNT            NUMERIC(9, 2) OUTPUT,
 @Ad_Check_DATE            DATE OUTPUT,
 @Ad_Receipt_DATE          DATE OUTPUT,
 @As_DisbursedTo_CODE      VARCHAR(MAX) OUTPUT,
 @An_CwicSeq_NUMB          NUMERIC(19) OUTPUT,
 @Ac_Msg_CODE              CHAR(3) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR OUTPUT
AS
 BEGIN
  DECLARE @Lc_StatusSuccess_CODE     CHAR = 'S',
          @Lc_StatusNoDataFound_CODE CHAR = 'N',
          @Lc_Space_TEXT             CHAR = ' ',
          @Lc_StatusFailed_CODE      CHAR = 'F',
          @Lc_CheckEft_TEXT          CHAR(1) = 'E',
          @Lc_CheckSvc_TEXT          CHAR(1) = 'S',
          @Ls_Procedure_NAME         VARCHAR(60) = 'SP_GET_ACSES_CHECK_DETAILS',
          @Ls_Sql_TEXT               VARCHAR(100),
          @Ls_Sqldata_TEXT           VARCHAR(200),
          @Ln_Error_NUMB             NUMERIC(11),
          @Ln_ErrorLine_NUMB         NUMERIC(11),
          @Ls_ErrorMessage_TEXT      VARCHAR(200)

  BEGIN TRY
   SET @An_Check_AMNT = NULL
   SET @Ad_Check_DATE = NULL
   SET @Ad_Receipt_DATE = NULL
   SET @As_DisbursedTo_CODE = NULL
   SET @An_CwicSeq_NUMB = NULL
   SET @Ac_Msg_CODE = NULL
   SET @As_DescriptionError_TEXT = NULL
   SET @Ls_Sql_TEXT = ' SELECT_VCWIC '
   SET @Ls_Sqldata_TEXT = ' Check_NUMB ' + ISNULL(@An_Check_NUMB, '')

   --CWIC_Y1 table removed
   SELECT @An_Check_AMNT = CWIC_Y1.Check_AMNT,
          @Ad_Check_DATE = CWIC_Y1.Check_DATE,
          @Ad_Receipt_DATE = CWIC_Y1.Receipt_DATE,
          @An_CwicSeq_NUMB = CWIC_Y1.CwicSeq_NUMB
     FROM CWIC_Y1
    WHERE CWIC_Y1.Case_IDNO = @Ac_Case_IDNO
      AND CWIC_Y1.Check_NUMB = @An_Check_NUMB
      AND dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR(CWIC_Y1.Check_NUMB, 1, 1) IN ('0', '1', '2', '3',
                                                                                   '4', '5', '6', '7',
                                                                                   '8', '9', @Lc_CheckEft_TEXT, @Lc_CheckSvc_TEXT)
      AND CWIC_Y1.Ncp_NAME NOT LIKE '%*%'

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

   -- Retrieve and log the Error Description.
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
