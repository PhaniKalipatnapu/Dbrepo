/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_GET_VOWED_FAIL_REASON_CODE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_GET_VOWED_FAIL_REASON_CODE
Programmer Name 	: IMP Team
Description			: This Procedure gets the Hold Code for the VOWED Fail
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REGULAR_DISTRIBUTION
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_GET_VOWED_FAIL_REASON_CODE] (
 @An_Case_IDNO             NUMERIC(6),
 @Ac_SourceReceipt_CODE    CHAR(2),
 @Ac_TaxJoint_CODE         CHAR(1),
 @Ad_Process_DATE          DATE,
 @Ac_ReasonStatus_CODE     CHAR(4) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 -- Check whether Record Exists in LSUP for RCTH_Y1 Month if so proceed further
 -- if not check whether Arrear = 0 for Latest Month in LSUP, if so put it on SNAX Hold
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_OrderTypeVoluntary_CODE              CHAR (1) = 'V',
           @Lc_IrsJointFiling_CODE                  CHAR (1) = 'J',
           @Lc_StatusFailed_CODE                    CHAR (1) = 'F',
           @Lc_StatusSuccess_CODE                   CHAR (1) = 'S',
           @Lc_IrsividualFiling_CODE                CHAR (1) = 'I',
           @Lc_SourceReceiptSpecialCollection_CODE  CHAR (2) = 'SC',
           @Lc_SourceReceiptStateTaxRefund_CODE     CHAR (2) = 'ST',
           @Lc_HoldReasonStatusSner_CODE            CHAR (4) = 'SNER',
           @Lc_HoldReasonStatusSnax_CODE            CHAR (4) = 'SNAX',
           @Lc_HoldReasonStatusSnjw_CODE            CHAR (4) = 'SNJW',
           @Lc_HoldReasonStatusSnxo_CODE            CHAR (4) = 'SNXO',
           @Ls_Procedure_NAME                       VARCHAR (100) = 'SP_GET_VOWED_FAIL_REASON_CODE',
           @Ld_High_DATE                            DATE = '12/31/9999';
  DECLARE  @Ln_NUMB               NUMERIC (1) = 0,
           @Ln_Arrear_AMNT        NUMERIC (11,2) = 0,
           @Ln_Error_NUMB         NUMERIC (11),
           @Ln_ErrorLine_NUMB     NUMERIC (11),
           @Li_Rowcount_QNTY      SMALLINT,
           @Lc_ReasonStatus_CODE  CHAR (4),
           @Ls_Sql_TEXT           VARCHAR (100),
           @Ls_Sqldata_TEXT       VARCHAR (1000),
           @Ls_ErrorMessage_TEXT  VARCHAR (4000);
  BEGIN TRY
   SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSner_CODE;

   -- If the following Query Executes successfuly then it means there is LSUP Record in the Receipt Month
   --If the VOWED fails, then the only reason could be the non-existence of LSUP
   -- in either the Receipt month or current month. Before checking for LSUp in the latest month,
   -- we chack for the existence of a cyclic OBLE_Y1 in OBLE_Y1. If it exists,
   --then we should have a record in the recipt month and current month in LSUP.
   -- so we need not check in LSUP and hence should go on SNER.
   -- If the OBLE_Y1 is not cyclic, then check for the existence of arrears on atleast 1 record in LSUP.
   --If there is no arrears then it should go on SNAX, SNIX, SNJX. If arrears exist, then should go on SNER.
   -- Should check only for latest month, since there can be no records in the current month for a non-cyclic OBLE_Y1 that has no arrears.
   SET @Ls_Sql_TEXT = 'SELECT - #Tcord_P1 - 1';   
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT TOP 1 @Ln_NUMB = 1
     FROM OBLE_Y1 o,
          #Tcord_P1 l
    WHERE o.Case_IDNO = l.Case_IDNO
      AND o.OrderSeq_NUMB = l.OrderSeq_NUMB
      AND o.EndValidity_DATE = @Ld_High_DATE
      AND o.Periodic_AMNT > 0
      AND dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Process_DATE) + 1 BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY <> 0
    BEGIN
     SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSner_CODE;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT - #Tcord_P1 - 2';   
     -- Check whether latest Available Records Arrear = 0 if so put it on SNAX Hold
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'');

     SELECT @Ln_Arrear_AMNT = ISNULL (SUM (CASE SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6)
                                            WHEN l.SupportYearMonth_NUMB
                                             THEN (l.MtdCurSupOwed_AMNT - l.AppTotCurSup_AMNT)
                                            ELSE 0
                                           END + (l.OweTotNaa_AMNT - l.AppTotNaa_AMNT) + (l.OweTotPaa_AMNT - l.AppTotPaa_AMNT) + (l.OweTotTaa_AMNT - l.AppTotTaa_AMNT) + (l.OweTotCaa_AMNT - l.AppTotCaa_AMNT) + (l.OweTotUpa_AMNT - l.AppTotUpa_AMNT) + (l.OweTotUda_AMNT - l.AppTotUda_AMNT) + (l.OweTotIvef_AMNT - l.AppTotIvef_AMNT) + (l.OweTotNffc_AMNT - l.AppTotNffc_AMNT) + (l.OweTotNonIvd_AMNT - l.AppTotNonIvd_AMNT) + (l.OweTotMedi_AMNT - l.AppTotMedi_AMNT) - CASE SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6) 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                              WHEN l.SupportYearMonth_NUMB
                                                                                                                                                                                                                                                                                                                                                                                                                                                                               THEN (l.OweTotCurSup_AMNT - l.AppTotCurSup_AMNT)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                             END), 0)
       FROM #Tcord_P1 c,
            LSUP_Y1 l
      WHERE c.Case_IDNO = @An_Case_IDNO
        AND c.Case_IDNO = l.Case_IDNO
        AND c.OrderSeq_NUMB = l.OrderSeq_NUMB
        AND ((@Ac_SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE)
              AND c.OrderType_CODE != @Lc_OrderTypeVoluntary_CODE)
              OR @Ac_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollection_CODE, @Lc_SourceReceiptStateTaxRefund_CODE))
        AND l.SupportYearMonth_NUMB = (SELECT MAX (b.SupportYearMonth_NUMB)
                                         FROM LSUP_Y1 b
                                        WHERE l.Case_IDNO = b.Case_IDNO
                                          AND l.OrderSeq_NUMB = b.OrderSeq_NUMB
                                          AND l.ObligationSeq_NUMB = b.ObligationSeq_NUMB)
        AND l.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB)
                                       FROM LSUP_Y1 b
                                      WHERE l.Case_IDNO = b.Case_IDNO
                                        AND l.OrderSeq_NUMB = b.OrderSeq_NUMB
                                        AND l.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                                        AND l.SupportYearMonth_NUMB = b.SupportYearMonth_NUMB);

     IF @Ln_Arrear_AMNT <= 0
      BEGIN
       IF @Ac_SourceReceipt_CODE <> @Lc_SourceReceiptSpecialCollection_CODE
        BEGIN
         SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSnax_CODE;
        END
       ELSE
        BEGIN
         IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollection_CODE
          BEGIN
           IF @Ac_TaxJoint_CODE = @Lc_IrsJointFiling_CODE
            BEGIN
             SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSnjw_CODE;
            END
           ELSE
            BEGIN
             IF @Ac_TaxJoint_CODE = @Lc_IrsividualFiling_CODE
              BEGIN
               SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSnxo_CODE;
              END
             ELSE
              BEGIN
               SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSnxo_CODE;
              END
            END
          END
        END
      END
     ELSE
      BEGIN
       SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSner_CODE;
      END
    END

   SET @Ac_ReasonStatus_CODE = @Lc_ReasonStatus_CODE;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
  END CATCH
 END


GO
