/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_BILLING$SP_MARK_AS_PROCESSED]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*------------------------------------------------------------------------------------------------------------------
 Procedure Name	: BATCH_FIN_EXT_BILLING$SP_MARK_AS_PROCESSED
 Programmer Name	: IMP Team
 Description		: Mark EBILL_Y1.Process_INDC as Y for processed records
 Frequency   		:
 Developed On  	: 6/19/2012
 Called By   		: None
 Called On			: 
 ------------------------------------------------------------------------------------------------------------------
 Modified By   :
 Modified On   :
 Version No    : 1.0
  ------------------------------------------------------------------------------------------------------------------
   */
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_BILLING$SP_MARK_AS_PROCESSED]
 @Ac_Case_IDNO              CHAR(6),
 @Ac_MemberMci_IDNO         CHAR(10),
 @Ac_CreditedMonthYear_TEXT CHAR(8),
 @Ac_Msg_CODE               CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Yes_INDC          CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE CHAR(1) = 'F',
          @Lc_Procedure_NAME    CHAR(30) = 'BATCH_FIN_EXT_BILLING$SP_MARK_AS_PROCESSED';
  DECLARE @Ln_RowCount_QNTY  NUMERIC(11) =0,
          @Ln_Error_NUMB     NUMERIC(11),
          @Ln_ErrorLine_NUMB NUMERIC(11),
          @Ls_Sql_TEXT       VARCHAR(100),
          @Ls_Sqldata_TEXT   VARCHAR(1000);

  BEGIN TRY
    SET @Ls_Sql_TEXT ='UPDATE EBILL_Y1';
   SET @Ls_Sqldata_TEXT ='Case_IDNO = ' + ISNULL(@Ac_Case_IDNO, '') + ', MemberMci_IDNO = ' + ISNULL(@Ac_MemberMci_IDNO, '') + ', CreditedMonthYear_TEXT = ' + ISNULL(@Ac_CreditedMonthYear_TEXT, '') + ', Yes_INDC = ' + @Lc_Yes_INDC;

   UPDATE EBILL_Y1
      SET Process_INDC = @Lc_Yes_INDC
    WHERE Case_IDNO = @Ac_Case_IDNO
      AND MemberMci_IDNO = @Ac_MemberMci_IDNO
      AND CreditedMonthYear_TEXT = @Ac_CreditedMonthYear_TEXT;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @As_DescriptionError_TEXT = 'INSERT EBILL_Y1 FAILED';

     RAISERROR(50001,16,1);
    END
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
 END; 

GO
