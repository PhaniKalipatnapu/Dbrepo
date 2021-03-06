/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_BILLING$SP_GET_BILLING_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*------------------------------------------------------------------------------------------------------------------
 Procedure Name	    : BATCH_FIN_EXT_BILLING$SP_GET_BILLING_DETAILS
 Programmer Name	: IMP Team
 Description		: Get the data from EBILL_Y1 table to generate Coupon in PDF formate
 Frequency   		:
 Developed On  	    : 6/19/2012
 Called By   		: None
 Called On			: 
  ------------------------------------------------------------------------------------------------------------------
 Modified By        :
 Modified On        :
 Version No         : 1.0
  ------------------------------------------------------------------------------------------------------------------
   */
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_BILLING$SP_GET_BILLING_DETAILS]
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_No_INDC           CHAR(1) = 'N',
          @Lc_StatusFailed_CODE CHAR(1) = 'F',
          @Lc_Space_TEXT        CHAR(1) = ' ',
          @Lc_Doller_TEXT       CHAR(2) = '$ ',
          @Lc_Procedure_NAME    CHAR(30) = 'SP_GET_BILLING_DETAILS';
  DECLARE @Ln_Error_NUMB     NUMERIC(11),
          @Ln_ErrorLine_NUMB NUMERIC(11),
          @Ls_Sql_TEXT       VARCHAR(100),
          @Ls_Sqldata_TEXT   VARCHAR(1000);

  BEGIN TRY
   SET @Ls_Sql_TEXT ='SELECT EBILL_Y1';
   SET @Ls_Sqldata_TEXT ='No_INDC = ' + @Lc_No_INDC;

   SELECT e.MemberMci_IDNO MemberMci_IDNO,
          e.MemberMci_IDNO SecondMemberMci_IDNO,
          e.MemberMci_IDNO ThirdMemberMci_IDNO,
          e.Payor1_NAME Payor_NAME,
          e.Payor1_NAME SecondPayor_NAME,
          e.Payor1_NAME ThirdPayor_NAME,
          e.FirstCouponDue_DATE,
          e.SecondCouponDue_DATE,
          e.ThirdCouponDue_DATE,
          CASE CAST(E.FirstCoupon_AMNT AS NUMERIC)
           WHEN 0
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + e.FirstCoupon_AMNT
          END FirstCoupon_AMNT,
          CASE CAST(e.SecondCoupon_AMNT AS NUMERIC)
           WHEN 0
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + e.SecondCoupon_AMNT
          END SecondCoupon_AMNT,
          CASE CAST(e.ThirdCoupon_AMNT AS NUMERIC)
           WHEN 0
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + e.ThirdCoupon_AMNT
          END ThirdCoupon_AMNT,
          @Lc_Doller_TEXT + e.Arrears_AMNT Arrears_AMNT,
          e.Case_IDNO,
          e.CreditedMonthYear_TEXT,
          e.Transaction01_DATE,
          e.TransactionType01_CODE,
          CASE e.Receipt01_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt01_AMNT)), 8)
          END Receipt01_AMNT,
          e.Transaction02_DATE,
          e.TransactionType02_CODE,
          CASE e.Receipt02_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt02_AMNT)), 8)
          END Receipt02_AMNT,
          e.Transaction03_DATE,
          e.TransactionType03_CODE,
          CASE e.Receipt03_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt03_AMNT)), 8)
          END Receipt03_AMNT,
          e.Transaction04_DATE,
          e.TransactionType04_CODE,
          CASE e.Receipt04_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt04_AMNT)), 8)
          END Receipt04_AMNT,
          e.Transaction05_DATE,
          e.TransactionType05_CODE,
          CASE e.Receipt05_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt05_AMNT)), 8)
          END Receipt05_AMNT,
          e.Transaction06_DATE,
          e.TransactionType06_CODE,
          CASE e.Receipt06_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt06_AMNT)), 8)
          END Receipt06_AMNT,
          e.Transaction07_DATE,
          e.TransactionType07_CODE,
          CASE e.Receipt07_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt07_AMNT)), 8)
          END Receipt07_AMNT,
          e.Transaction08_DATE,
          e.TransactionType08_CODE,
          CASE e.Receipt08_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt08_AMNT)), 8)
          END Receipt08_AMNT,
          e.Transaction09_DATE,
          e.TransactionType09_CODE,
          CASE e.Receipt09_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt09_AMNT)), 8)
          END Receipt09_AMNT,
          e.Transaction10_DATE,
          e.TransactionType10_CODE,
          CASE e.Receipt10_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt10_AMNT)), 8)
          END Receipt10_AMNT,
          e.Transaction11_DATE,
          e.TransactionType11_CODE,
          CASE e.Receipt11_AMNT
           WHEN @Lc_Space_TEXT
            THEN @Lc_Space_TEXT
           ELSE @Lc_Doller_TEXT + RIGHT(REPLICATE(@Lc_Space_TEXT, 8) + LTRIM(RTRIM(e.Receipt11_AMNT)), 8)
          END Receipt11_AMNT,
          e.Payor2_NAME,
          e.Line1_ADDR,
          e.Line2_ADDR,
          e.CityStateZip_ADDR
     FROM EBILL_Y1 e
    WHERE e.Process_INDC = @Lc_No_INDC
    ORDER BY e.MemberMci_IDNO, Case_IDNO
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
