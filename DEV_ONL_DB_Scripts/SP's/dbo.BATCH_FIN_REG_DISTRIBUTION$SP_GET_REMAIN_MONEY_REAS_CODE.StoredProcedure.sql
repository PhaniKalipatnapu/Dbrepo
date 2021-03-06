/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_GET_REMAIN_MONEY_REAS_CODE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_GET_REMAIN_MONEY_REAS_CODE
Programmer Name 	: IMP Team
Description			: This Procedure will get the Hold Code for the Remaining Money and holds the Money back
					  in RCTH_Y1 (RCTH_Y1) Table.
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_REG_DISTRIBUTION$SP_REGULAR_DISTRIBUTION
Called On			: BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_GET_REMAIN_MONEY_REAS_CODE]
 @An_Case_IDNO                NUMERIC(6),
 @An_PayorMCI_IDNO            NUMERIC(10),
 @Ac_TypePosting_CODE         CHAR(1),
 @Ac_TypePostingOriginal_CODE CHAR (1),
 @Ac_SourceReceipt_CODE       CHAR(2),
 @Ac_TaxJoint_CODE            CHAR(1),
 @Ad_Receipt_DATE             DATE, 
 @Ac_ReasonStatus_CODE        CHAR(4) OUTPUT,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE             DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_TypePostingCase_CODE                 CHAR (1) = 'C',
           @Lc_TypePostingPayor_CODE                CHAR (1) = 'P',
           @Lc_CaseRelationshipNcp_CODE             CHAR (1) = 'A',
           @Lc_CaseRelationshipPutFather_CODE       CHAR (1) = 'P',
           @Lc_CaseMemberStatusActive_CODE          CHAR (1) = 'A',
           @Lc_StatusFailed_CODE                    CHAR (1) = 'F',
           @Lc_StatusSuccess_CODE                   CHAR (1) = 'S',
           @Lc_IrsJointFiling_CODE                  CHAR (1) = 'J',
           @Lc_IrsividualFiling_CODE                CHAR (1) = 'I',
           @Lc_EnfArrearE_CODE						CHAR (1) = 'E',
           @Lc_SourceReceiptBond_CODE               CHAR (2) = 'BN',
           @Lc_SourceReceiptNsfRecoupment_CODE      CHAR (2) = 'NR',
           @Lc_TypeDebtMedicaid_CODE                CHAR (2) = 'DS',
           @Lc_TypeDebtIntMedicaid_CODE             CHAR (2) = 'DI',
           @Lc_SourceReceiptSpecialCollection_CODE  CHAR (2) = 'SC',
           @Lc_HoldReasonStatusSnfx_CODE            CHAR (4) = 'SNFX',
           @Lc_HoldReasonStatusSnjx_CODE            CHAR (4) = 'SNJX',
           @Lc_HoldReasonStatusSnjw_CODE            CHAR (4) = 'SNJW',
           @Lc_HoldReasonStatusSnix_CODE            CHAR (4) = 'SNIX',
           @Lc_HoldReasonStatusSnxo_CODE            CHAR (4) = 'SNXO',
           @Lc_HoldReasonStatusSnax_CODE            CHAR (4) = 'SNAX',
           @Lc_HoldReasonStatusSnbn_CODE            CHAR (4) = 'SNBN',
           @Lc_HoldReasonStatusShnf_CODE            CHAR (4) = 'SHNF',
           @Ls_Procedure_NAME                       VARCHAR (100) = 'SP_GET_REMAIN_MONEY_REAS_CODE',
           @Ld_High_DATE                            DATE = '12/31/9999';
  DECLARE  @Ln_Value_NUMB         NUMERIC (1),
           @Ln_Error_NUMB         NUMERIC (11),
           @Ln_ErrorLine_NUMB     NUMERIC (11),
           @Ln_Arrears_AMNT       NUMERIC (11,2) = 0,
           @Li_Rowcount_QNTY      SMALLINT,
           @Ls_Sql_TEXT           VARCHAR (100) = '',
           @Ls_Sqldata_TEXT       VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT  VARCHAR (4000);

  BEGIN TRY
   SET @Ac_ReasonStatus_CODE = '';
   SET @Ac_Msg_CODE = '';

   IF @Ac_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptBond_CODE)
    BEGIN
     IF @Ac_TypePostingOriginal_CODE = @Lc_TypePostingCase_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1 - 1';       
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT TOP 1 @Ln_Value_NUMB = 1
         FROM OBLE_Y1 o
        WHERE o.Case_IDNO = @An_Case_IDNO
          AND o.EndValidity_DATE = @Ld_High_DATE
          AND o.TypeDebt_CODE NOT IN (@Lc_TypeDebtMedicaid_CODE, @Lc_TypeDebtIntMedicaid_CODE)
          AND o.Periodic_AMNT > 0
          AND dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Process_DATE) + 1 BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;
      END
     ELSE IF @Ac_TypePostingOriginal_CODE = @Lc_TypePostingPayor_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1 - 2';
       SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

       SELECT @Ln_Value_NUMB = 1
         FROM OBLE_Y1 o,
              (SELECT m.Case_IDNO
                 FROM CMEM_Y1 m
                WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
                  AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                  AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE) AS b
        WHERE o.Case_IDNO = b.Case_IDNO
          AND o.EndValidity_DATE = @Ld_High_DATE
          AND o.TypeDebt_CODE NOT IN (@Lc_TypeDebtMedicaid_CODE, @Lc_TypeDebtIntMedicaid_CODE)
          AND o.Periodic_AMNT > 0
          AND dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Process_DATE) + 1 BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;
      END

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       IF @Ac_SourceReceipt_CODE <> @Lc_SourceReceiptSpecialCollection_CODE
        BEGIN
         SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnax_CODE;
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS - 1';
         SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST( @An_PayorMCI_IDNO AS VARCHAR ),'') + ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'') + ', TypePosting_CODE = ' + ISNULL(@Ac_TypePosting_CODE,'') + ', Process_DATE = ' + ISNULL(CAST(@Ad_Process_DATE AS VARCHAR),'') + ', SourceReceipt_CODE = ' + ISNULL(CAST(@Ac_SourceReceipt_CODE AS VARCHAR),'') + ', Receipt_DATE = ' + ISNULL(CAST(@Ad_Receipt_DATE AS VARCHAR),'');

		  -- Note: If Payor has NO IFMS record then always receipt will be placed in SNIO, SNJO hold irrespective of case arrear balance in LSUP table. 
		  --		If Payor has IFMS record with Delete transaction with ExcludeIRS_CODE = 'N' and Latest HIFMS record with Add or Mod transaction with ExcludeIRS_CODE = 'N' 
		  --		then receipt will be placed in SNIN, SNJN when case arrear balance > 0 in LSUP table.                  
         SET @Ln_Arrears_AMNT = dbo.BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS (@An_PayorMCI_IDNO, @An_Case_IDNO, @Ac_TypePosting_CODE, @Ad_Process_DATE, @Ac_SourceReceipt_CODE, @Ad_Receipt_DATE);

         IF @Ac_TaxJoint_CODE = @Lc_IrsJointFiling_CODE
          BEGIN
           IF @Ln_Arrears_AMNT > 0
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnjx_CODE;
            END
           ELSE
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnjw_CODE;
            END
          END
         ELSE IF @Ac_TaxJoint_CODE = @Lc_IrsividualFiling_CODE
          BEGIN
           IF @Ln_Arrears_AMNT > 0
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnix_CODE;
            END
           ELSE
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnxo_CODE;
            END
          END
         ELSE
          BEGIN
           IF @Ln_Arrears_AMNT > 0
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnix_CODE;
            END
           ELSE
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnxo_CODE;
            END
          END
        END
      END
     ELSE
      BEGIN
       IF @Ac_SourceReceipt_CODE <> @Lc_SourceReceiptSpecialCollection_CODE
        BEGIN
         SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnfx_CODE;
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS - 2';
         SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST( @An_PayorMCI_IDNO AS VARCHAR ),'') + ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', TypePosting_CODE = ' + ISNULL(@Ac_TypePosting_CODE,'') + ', Process_DATE = ' + ISNULL(CAST(@Ad_Process_DATE AS VARCHAR),'') + ', SourceReceipt_CODE = ' + ISNULL(CAST(@Ac_SourceReceipt_CODE AS VARCHAR),'')+ ', Receipt_DATE = ' + ISNULL(CAST(@Ad_Receipt_DATE AS VARCHAR),'');
                  
         SET @Ln_Arrears_AMNT = dbo.BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS (@An_PayorMCI_IDNO, @An_Case_IDNO, @Lc_EnfArrearE_CODE, @Ad_Process_DATE, @Ac_SourceReceipt_CODE, @Ad_Receipt_DATE);

         IF @Ac_TaxJoint_CODE = @Lc_IrsJointFiling_CODE
          BEGIN
           IF @Ln_Arrears_AMNT > 0
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnjx_CODE;
            END
           ELSE
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnjw_CODE;
            END
          END
         ELSE IF @Ac_TaxJoint_CODE = @Lc_IrsividualFiling_CODE
          BEGIN
           IF @Ln_Arrears_AMNT > 0
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnix_CODE;
            END
           ELSE
            BEGIN
             SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnxo_CODE;
            END
          END
         ELSE IF @Ln_Arrears_AMNT > 0
          BEGIN
           SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnix_CODE;
          END
         ELSE
          BEGIN
           SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnxo_CODE;
          END
        END
      END
    END
   ELSE IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptBond_CODE
    BEGIN
     SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnbn_CODE;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
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
  END CATCH
 END


GO
