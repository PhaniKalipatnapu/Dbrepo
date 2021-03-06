/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_DIST_VALIDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_DIST_VALIDATE
Programmer Name 	: IMP Team
Description			: This Procedure validates the Condition to Distribute the receipt. If there any potential Hold 
					  condition exists for the Payor/Case/receipt then the receipt will go on Hold.
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
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_DIST_VALIDATE]
 @Ac_TypePosting_CODE      CHAR(1),
 @An_Case_IDNO             NUMERIC(6),
 @An_PayorMCI_IDNO         NUMERIC(10),
 @Ac_TaxJoint_CODE         CHAR(1),
 @Ad_Receipt_DATE          DATE,
 @Ac_SourceReceipt_CODE    CHAR(2),
 @Ac_RcptToProcess_INDC    CHAR (1) OUTPUT,
 @Ac_StatusReceipt_CODE    CHAR(1) OUTPUT,
 @Ac_ReasonStatus_CODE     CHAR(4) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ac_ReleasedFrom_CODE     CHAR(4) OUTPUT,
 @Ac_IrsCertAdd_CODE       CHAR (1) OUTPUT,
 @Ac_IrsCertMod_CODE       CHAR (1) OUTPUT,
 @Ad_Process_DATE          DATE OUTPUT,
 @Ac_N4dFlag_INDC          CHAR (1) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

   DECLARE @Lc_Yes_INDC                             CHAR (1) = 'Y',
           @Lc_TypePostingCase_CODE                 CHAR (1) = 'C',
           @Lc_CaseStatusOpen_CODE                  CHAR (1) = 'O',
           @Lc_TypePostingPayor_CODE                CHAR (1) = 'P',
           @Lc_CaseRelationshipNcp_CODE             CHAR (1) = 'A',
           @Lc_CaseRelationshipPutFather_CODE       CHAR (1) = 'P',
           @Lc_StatusReceiptHeld_CODE               CHAR (1) = 'H',
           @Lc_No_INDC                              CHAR (1) = 'N',
           @Lc_StatusCaseMemberActive_CODE          CHAR (1) = 'A',
           @Lc_Space_TEXT                           CHAR (1) = ' ',
           @Lc_TypeOrderVoluntary_CODE              CHAR (1) = 'V',
           @Lc_StatusFailed_CODE                    CHAR (1) = 'F',
           @Lc_StatusSuccess_CODE                   CHAR (1) = 'S',
           @Lc_IrsividualFiling_CODE                CHAR (1) = 'I',
           @Lc_IrsJointFiling_CODE                  CHAR (1) = 'J',
           @Lc_IwnActiveStatus_CODE                 CHAR (1) = 'A',
           @Lc_TypeArrearA_CODE		                CHAR (1) = 'A',
           @Lc_TypeArrearN_CODE		                CHAR (1) = 'N',
           @Lc_TypeTransactionD_CODE				CHAR (1) = 'D',
           @Lc_TypeTransactionI_CODE				CHAR (1) = 'I',
           @Lc_TypeTransactionC_CODE				CHAR (1) = 'C',                      
           @Lc_NonIvdCaseType_CODE                  CHAR (1) = 'H',
           @Lc_RespondInitI_CODE                    CHAR (1) = 'I',
           @Lc_RespondInitC_CODE                    CHAR (1) = 'C',
           @Lc_RespondInitT_CODE                    CHAR (1) = 'T',         
           @Lc_SourceReceiptSpecialCollectionSC_CODE CHAR (2) = 'SC',
           @Lc_SourceReceiptStateTaxRefundST_CODE   CHAR (2) = 'ST',
           @Lc_SourceReceiptLevyFidmFD_CODE         CHAR (2) = 'FD',
           @Lc_SourceReceiptCslnLN_CODE             CHAR (2) = 'LN',
           @Lc_SourceReceiptQdroQR_CODE             CHAR (2) = 'QR',
           @Lc_SourceReceiptEmployerwageEW_CODE     CHAR (2) = 'EW',
           @Lc_SourceReceiptUibUC_CODE              CHAR (2) = 'UC',
           @Lc_SourceReceiptDisabilityinsurDB_CODE  CHAR (2) = 'DB',
           @Lc_SourceReceiptInterstatIvdRegF4_CODE  CHAR (2) = 'F4',
           @Lc_HoldReasonStatusShcs_CODE            CHAR (4) = 'SHCS',
           @Lc_HoldReasonStatusSncc_CODE            CHAR (4) = 'SNCC',
           @Lc_HoldReasonStatusSncl_CODE            CHAR (4) = 'SNCL',
           @Lc_HoldReasonStatusSnna_CODE            CHAR (4) = 'SNNA',
           @Lc_HoldReasonStatusSnin_CODE            CHAR (4) = 'SNIN',
           @Lc_HoldReasonStatusSnjn_CODE            CHAR (4) = 'SNJN',
           @Lc_HoldReasonStatusSnix_CODE            CHAR (4) = 'SNIX',
           @Lc_HoldReasonStatusSnjx_CODE            CHAR (4) = 'SNJX',
           @Lc_HoldReasonStatusSnio_CODE            CHAR (4) = 'SNIO',
           @Lc_HoldReasonStatusSnjo_CODE            CHAR (4) = 'SNJO',
           @Lc_HoldReasonStatusSnsn_CODE            CHAR (4) = 'SNSN',
           @Lc_HoldReasonStatusSnwc_CODE            CHAR (4) = 'SNWC',
           @Lc_HoldReasonStatusSnno_CODE            CHAR (4) = 'SNNO',
           @Lc_HoldReasonStatusSnpo_CODE            CHAR (4) = 'SNPO',
           @Lc_HoldReasonStatusShnd_CODE            CHAR (4) = 'SHND',
           @Lc_HoldReasonStatusShew_CODE			CHAR (4) = 'SHEW',
           @Lc_HoldReasonStatusSnqr_CODE			CHAR (4) = 'SNQR',
           @Lc_HoldReasonStatusSnfp_CODE            CHAR(4)  = 'SNFP',
           @Lc_ActivityMajorFidm_CODE               CHAR (4) = 'FIDM',
           @Lc_RemedyStatusStart_CODE               CHAR (4) = 'STRT',
           @Lc_HoldReasonStatusSnle_CODE            CHAR (4) = 'SNLE',
           @Lc_ActivityMajorCsln_CODE               CHAR (4) = 'CSLN',
           @Lc_ActivityMajorLien_CODE               CHAR (4) = 'LIEN',
           @Lc_ActivityMajorImiw_CODE				CHAR (4) = 'IMIW',
           @Lc_StatusExmt_CODE						CHAR (4) = 'EXMT',          
           @Lc_MinorActivityMorfd_CODE              CHAR (5) = 'MORFD',
           @Lc_MinorActivityRfins_CODE              CHAR (5) = 'RFINS',
           @Ls_Procedure_NAME                       VARCHAR (100) = 'BATCH_FIN_REG_DISTRIBUTION$SP_DIST_VALIDATE',
           @Ld_High_DATE                            DATE = '12/31/9999',
           @Ld_Low_DATE                             DATE = '01/01/0001';
  DECLARE  @Ln_Value_NUMB					NUMERIC (1) = 0,
		   @Ln_QdroActiveStatus_QNTY		NUMERIC(1) = 0,
		   @Ln_InitiatingCases_QNTY			NUMERIC(10) = 0,
           @Ln_NTanfCount_QNTY              NUMERIC (11) = 0,
           @Ln_TanfCount_QNTY               NUMERIC (11) = 0,           
		   @Ln_IwnActiveStatusCount_QNTY    NUMERIC (11) = 0,
           @Ln_IwnNoRecordStatusCount_QNTY  NUMERIC (11) = 0,
           @Ln_TotalCaseCount_QNTY          NUMERIC (11) = 0,
           @Ln_TotalCaseExmtCount_QNTY		NUMERIC (11) = 0,
		   @Ln_NTanfNotCertCount_QNTY		NUMERIC (11) = 0,
           @Ln_TanfNotCertCount_QNTY		NUMERIC (11) = 0,
           @Ln_FidmNotMorfdStatusCount_QNTY	NUMERIC (11) = 0,
           @Ln_FidmNotRfinsStatusCount_QNTY	NUMERIC (11) = 0,		   
           @Ln_Error_NUMB               NUMERIC (11),
           @Ln_ErrorLine_NUMB           NUMERIC (11),
           @Ln_Arrear_AMNT              NUMERIC (11,2) = 0,
           @Li_Rowcount_QNTY            SMALLINT,
           @Lc_DistNonIvd_INDC          CHAR (1) = '',
           @Ls_Sql_TEXT                 VARCHAR (100) = '',
           @Ls_Sqldata_TEXT             VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT        VARCHAR (4000) = '',
           @Ld_BeginObligation_DATE     DATE;
  BEGIN TRY
   SET @Ac_StatusReceipt_CODE = '';
   SET @Ac_ReasonStatus_CODE = '';
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ac_RcptToProcess_INDC = @Lc_Yes_INDC;
   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';

   -- For case level receipts (BN, FC, PM, QR, SQ, VN) if user release the receipt and NOT reposting with CASE ID then regular distribution program should place it in SHCS hold. For these 6 receipts sources program should distribute only when it is posted as case identified.
   BEGIN
	IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
     BEGIN
      SET @Ln_Value_NUMB = 0;
      
      SET @Ls_Sql_TEXT = 'SELECT_HIMS_Y1, UCAT_Y1_SHCS';
	  SET @Ls_Sqldata_TEXT = 'SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', CaseHold_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM HIMS_Y1 h,
          UCAT_Y1 u
		WHERE h.SourceReceipt_CODE = @Ac_SourceReceipt_CODE
		  AND h.EndValidity_DATE = @Ld_High_DATE
		  AND h.CaseHold_INDC = @Lc_Yes_INDC
		  AND h.UdcCaseHold_CODE = u.Udc_CODE
		  AND u.EndValidity_DATE = @Ld_High_DATE;
		 
	  SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     END
	 IF @Li_Rowcount_QNTY = 1
      BEGIN
       SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
       SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusShcs_CODE;
       SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;
	   RETURN;
      END	     
   END	
   -- Check whether the Payor's Case is Closed if so put in SNCL Hold
   -- If its an IRS Receipt then put it on SNCC
   BEGIN
    IF @Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_CASE_Y1_SNCL';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + @Lc_CaseStatusOpen_CODE;

      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM CASE_Y1 c
       WHERE c.Case_IDNO = @An_Case_IDNO
         AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     END
    ELSE IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_CMEM_Y1_CASE_Y1_SNCL';
      SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + @Lc_CaseStatusOpen_CODE;

      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM CMEM_Y1 m,
             CASE_Y1 c
       WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
         AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND m.Case_IDNO = c.Case_IDNO
         AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     END

    IF @Li_Rowcount_QNTY = 0
     BEGIN
      SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;

      IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollectionSC_CODE
       BEGIN
        SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSncc_CODE;
       END
      ELSE
       BEGIN
        SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSncl_CODE;
       END

      SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;

      RETURN;
     END
   END

   -- If Payor Level Posting then check whether the NCP is Active if not put it on SNNA Hold
   BEGIN
    IF @Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_CASE_Y1_SNNA';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_PayorMCI_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'');

      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM CMEM_Y1 a,
             CASE_Y1 b
       WHERE a.Case_IDNO = @An_Case_IDNO
         AND a.MemberMci_IDNO = @An_PayorMCI_IDNO
         AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
         AND a.Case_IDNO = b.Case_IDNO
         AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     END
    ELSE IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_CMEM_Y1_CASE_Y1_SNNA';
      SET @Ls_Sqldata_TEXT = ' PayorMCI_IDNO ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + @Lc_CaseStatusOpen_CODE + ', CaseMemberStatus_CODE = ' + @Lc_StatusCaseMemberActive_CODE;

      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM CMEM_Y1 a,
             CASE_Y1 b
       WHERE a.MemberMci_IDNO = @An_PayorMCI_IDNO
         AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
         AND a.Case_IDNO = b.Case_IDNO
         AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     END

    IF @Li_Rowcount_QNTY = 0
     BEGIN
      SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
      SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnna_CODE;
      SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;

      RETURN;
     END
   END

   -- Check whether there exists Certification (if its IRS (SC) Receipt) if not put it on
   -- SNIN (NO CERTIFICATION SPC INDIVIDUAL - WITH ARREARS) OR
   -- SNIO (NO CERTIFICATION SPC INDIVIDUAL - WITHOUT ARREARS) OR
   -- SNJN (NO CERTIFICATION SPC JOINT - WITH ARREARS) OR
   -- SNJO (NO CERTIFICATION IRS JOINT - WITHOUT ARREARS),
   -- (if its State Tax (ST) Receipt) then put it on SNSN (NO CERTIFICATION STATE TAX OFFSET) Hold
   -- Note: If Payor has NO IFMS record then always receipt will be placed in SNIO, SNJO hold irrespective of case arrear balance in LSUP table. 
   --		If Payor has IFMS record with Delete transaction with ExcludeIRS_CODE = 'N' and Latest HIFMS record with Add or Mod transaction with ExcludeIRS_CODE = 'N' 
   --		then receipt will be placed in SNIN, SNJN when case arrear balance > 0 in LSUP table. 
   IF @Ac_SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollectionSC_CODE, @Lc_SourceReceiptStateTaxRefundST_CODE)
    BEGIN
     IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollectionSC_CODE
      BEGIN
		-- DECSS distribution program will always check case certification existance for IRS Receipts distribution. Certified case – is the case submitted for IRS tax offset intercept. Certified cases do not include IRS excluded/exempted cases, responding cases, or Non IV-D cases.
        BEGIN
         -- DECSS Change:Distribution Code was modified to consider the existence of the one (TANF/NTANF) Certified Record as a Valid Certification even if the other is deleted. - Start --
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT_FEDH_Y1';
		  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', SubmitLast_DATE = ' + CAST(@Ad_Receipt_DATE AS VARCHAR);
          SELECT @Ln_TanfNotCertCount_QNTY = ISNULL(SUM(CASE
                                               WHEN f.TypeArrear_CODE = @Lc_TypeArrearA_CODE
                                                    AND (f.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                                                          OR f.RejectInd_INDC = @Lc_Yes_INDC)
                                                THEN 1
                                               ELSE 0
                                              END),0),
                 @Ln_NTanfNotCertCount_QNTY = ISNULL(SUM(CASE
                                                WHEN f.TypeArrear_CODE = @Lc_TypeArrearN_CODE
                                                     AND (f.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                                                           OR f.RejectInd_INDC = @Lc_Yes_INDC)
                                                 THEN 1
                                                ELSE 0
                                               END),0),
                 @Ln_TanfCount_QNTY = ISNULL(SUM(CASE
                                       WHEN f.TypeArrear_CODE = @Lc_TypeArrearA_CODE
                                        THEN 1
                                       ELSE 0
                                      END),0),
                 @Ln_NTanfCount_QNTY = ISNULL(SUM(CASE
                                        WHEN f.TypeArrear_CODE = @Lc_TypeArrearN_CODE
                                         THEN 1
                                        ELSE 0
                                       END),0)
            FROM (SELECT f.MemberMci_IDNO,
                         f.TypeArrear_CODE,
                         f.TypeTransaction_CODE,
                         f.SubmitLast_DATE,
                         f.Arrear_AMNT,
                         f.TransactionEventSeq_NUMB,
                         f.RejectInd_INDC RejectInd_INDC
                    FROM FEDH_Y1 f
                   WHERE f.MemberMci_IDNO = @An_PayorMCI_IDNO
                     AND f.SubmitLast_DATE < @Ad_Receipt_DATE
                     AND f.ExcludeIrs_CODE = @Lc_No_INDC
                     AND f.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                                         FROM FEDH_Y1 h
                                                        WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                          AND f.TypeArrear_CODE = h.TypeArrear_CODE
                                                          AND h.SubmitLast_DATE <= f.SubmitLast_DATE)                                 
                  UNION
                  SELECT f.MemberMci_IDNO,
                         f.TypeArrear_CODE,
                         f.TypeTransaction_CODE,
                         f.SubmitLast_DATE,
                         f.Arrear_AMNT,
                         f.TransactionEventSeq_NUMB,
                         f.RejectInd_INDC RejectInd_INDC
                    FROM HFEDH_Y1 f
                   WHERE f.MemberMci_IDNO = @An_PayorMCI_IDNO
                     AND f.SubmitLast_DATE < @Ad_Receipt_DATE
                     AND f.ExcludeIrs_CODE = @Lc_No_INDC
                     AND f.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                                         FROM HFEDH_Y1 h
                                                        WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                          AND f.TypeArrear_CODE = h.TypeArrear_CODE
                                                          AND h.SubmitLast_DATE <= f.SubmitLast_DATE)                                                         
                     AND NOT EXISTS (SELECT 1
                                       FROM FEDH_Y1 d
                                      WHERE f.MemberMci_IDNO = d.MemberMci_IDNO
                                        AND f.TypeArrear_CODE = d.TypeArrear_CODE
                                        AND d.SubmitLast_DATE > f.SubmitLast_DATE
                                        AND (d.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                                              OR d.RejectInd_INDC = @Lc_Yes_INDC)
                                        AND d.SubmitLast_DATE < @Ad_Receipt_DATE
                                     -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - Start --
                                     UNION
                                     SELECT 1
                                       FROM HFEDH_Y1 h
                                      WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                        AND f.TypeArrear_CODE = h.TypeArrear_CODE
                                        AND h.SubmitLast_DATE > f.SubmitLast_DATE
                                        AND (h.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                                              OR h.RejectInd_INDC = @Lc_Yes_INDC)
                                        AND h.SubmitLast_DATE < @Ad_Receipt_DATE
                                    -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - End --
                                    )) AS f;
         END
        
         IF (@Ln_TanfCount_QNTY > @Ln_TanfNotCertCount_QNTY)
             OR (@Ln_NTanfCount_QNTY > @Ln_NTanfNotCertCount_QNTY)
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS-1';
           SET @Ls_Sqldata_TEXT = '';
          END
         ELSE
         -- (TanfCount Lessthan TanfNotCertCount) OR (NTanfCount < NTanfNotCertCount)
         --    OR (TanfCount = 0 AND TanfNotCertCount = 0 AND NTanfCount = 0 AND NTanfNotCertCount = 0)
          -- DECSS Change:Distribution Code was modified to consider the existence of the one (TANF/NTANF) Certified Record as a Valid Certification even if the other is deleted. - End --
          BEGIN
           SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
           SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;
           SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS-2';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', TypePosting_CODE = ' + ISNULL(@Ac_TypePosting_CODE, '') + ', Process_DATE = ' + ISNULL(CAST(@Ad_Process_DATE AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL(CAST(@Ac_SourceReceipt_CODE AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ad_Receipt_DATE AS VARCHAR),'');
           SET @Ln_Arrear_AMNT = dbo.BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS (@An_PayorMCI_IDNO, @An_Case_IDNO, @Ac_TypePosting_CODE, @Ad_Process_DATE, @Ac_SourceReceipt_CODE, @Ad_Receipt_DATE);

           IF @Ac_TaxJoint_CODE = @Lc_IrsividualFiling_CODE
            BEGIN
             IF @Ln_Arrear_AMNT > 0
              BEGIN
               SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnin_CODE;
              END
             ELSE
              BEGIN
               SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnio_CODE;
              END
            END
           ELSE IF @Ac_TaxJoint_CODE = @Lc_IrsJointFiling_CODE
            BEGIN
             IF @Ln_Arrear_AMNT > 0
              BEGIN
               SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnjn_CODE;
              END
             ELSE
              BEGIN
               SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnjo_CODE;
              END
            END
           ELSE
            BEGIN
             IF @Ln_Arrear_AMNT > 0
              BEGIN
               SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnin_CODE;
              END
             ELSE
              BEGIN
               SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnio_CODE;
              END
            END

           RETURN;
          END
        END
      END
     ELSE
      BEGIN
       ---- Condition Added not to look for the Certification when the Receipt is released from SNSN Hold
       SET @Ls_Sql_TEXT = 'SELECT_SLST_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', SubmitLast_DATE = ' + CAST(@Ad_Receipt_DATE AS VARCHAR);

       SELECT TOP 1 @Ln_Value_NUMB = 1
         FROM SLST_Y1 f
        WHERE f.MemberMci_IDNO = @An_PayorMCI_IDNO
          AND f.TypeTransaction_CODE IN (@Lc_TypeTransactionI_CODE, @Lc_TypeTransactionC_CODE)
          AND f.SubmitLast_DATE < @Ad_Receipt_DATE
          AND f.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                              FROM SLST_Y1 h
                                             WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                               AND h.TypeTransaction_CODE IN (@Lc_TypeTransactionI_CODE, @Lc_TypeTransactionC_CODE)
                                               AND h.SubmitLast_DATE < @Ad_Receipt_DATE);

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;
      END

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
       SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;
       SET @Ls_Sql_TEXT = 'BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS-3';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', TypePosting_CODE = ' + ISNULL(@Ac_TypePosting_CODE, '') + ', Process_DATE = ' + ISNULL(CAST(@Ad_Process_DATE AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL(CAST(@Ac_SourceReceipt_CODE AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ad_Receipt_DATE AS VARCHAR),'');
       SET @Ln_Arrear_AMNT = dbo.BATCH_FIN_REG_DISTRIBUTION$SF_GET_ARREARS (@An_PayorMCI_IDNO, @An_Case_IDNO, @Ac_TypePosting_CODE, @Ad_Process_DATE, @Ac_SourceReceipt_CODE, @Ad_Receipt_DATE);

       IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptStateTaxRefundST_CODE
        BEGIN
         SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnsn_CODE;
        END

       RETURN;
      END
    END

   -- DECSS Change: NR Receipt No need to check for POFL Balance and the Check Recipient should not be NCP instead it should be whatever is there on OBLE
   
   IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptLevyFidmFD_CODE
    BEGIN
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_DMJR_FIDM';
      SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + @Lc_StatusCaseMemberActive_CODE + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorFidm_CODE + ', Status_CODE = ' + @Lc_RemedyStatusStart_CODE;

      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM DMJR_Y1 a,
             CMEM_Y1 m
       WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
         AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
         AND m.MemberMci_IDNO = a.MemberMci_IDNO
         AND m.Case_IDNO = a.Case_IDNO
         AND a.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
         AND a.Status_CODE = @Lc_RemedyStatusStart_CODE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;

      IF @Li_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
        SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnle_CODE;
        SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;

        RETURN;
       END
     END

     BEGIN

       SET @Ls_Sql_TEXT = 'SELECT_CMEM_DMNR_FIDM';
	   SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + @Lc_StatusCaseMemberActive_CODE + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorFidm_CODE + ', Status_CODE = ' + @Lc_RemedyStatusStart_CODE;
       SELECT @Ln_FidmNotMorfdStatusCount_QNTY = SUM (a.ActivityMinorNotMorfdCount_QNTY) ,
              @Ln_TotalCaseCount_QNTY = SUM (a.CaseCount_QNTY) 
         FROM (SELECT a.MemberMci_IDNO,
                      a.Case_IDNO,
                      a.ActivityMinor_CODE,
                      CASE
                       WHEN a.ActivityMinor_CODE <> @Lc_MinorActivityMorfd_CODE
                        THEN 1
                       ELSE 0
                      END AS ActivityMinorNotMorfdCount_QNTY,
                      1 AS CaseCount_QNTY
                 FROM (SELECT m.MemberMci_IDNO,
                              m.Case_IDNO,
                              ISNULL (a.ActivityMinor_CODE, @Lc_Space_TEXT) AS ActivityMinor_CODE
                         FROM CMEM_Y1 m
                              LEFT OUTER JOIN DMNR_Y1 a
                               ON  m.MemberMci_IDNO = a.MemberMci_IDNO
									AND m.Case_IDNO = a.Case_IDNO
                        WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
                          AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                          AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                          AND a.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
						 AND a.Status_CODE = @Lc_RemedyStatusStart_CODE
						 AND a.MinorIntSeq_NUMB = (SELECT MAX (b.MinorIntSeq_NUMB)
													 FROM DMNR_Y1 b
													WHERE a.Case_IDNO = b.Case_IDNO
													  AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
													  AND a.MajorIntSEQ_NUMB = b.MajorIntSEQ_NUMB)
                          )a) a;

		IF @Ln_TotalCaseCount_QNTY = @Ln_FidmNotMorfdStatusCount_QNTY
		BEGIN
			SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
			SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnle_CODE;
			SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;
			RETURN;
		END
		
     END
    END
   ELSE IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptCslnLN_CODE
    BEGIN
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_DMJR_CSLN';
      SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + @Lc_StatusCaseMemberActive_CODE + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCsln_CODE + ', Status_CODE = ' + @Lc_RemedyStatusStart_CODE;

      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM DMJR_Y1 a,
             CMEM_Y1 m
       WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
         AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
         AND m.MemberMci_IDNO = a.MemberMci_IDNO
         AND m.Case_IDNO = a.Case_IDNO
         AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorCsln_CODE, @Lc_ActivityMajorLien_CODE)--= @Lc_ActivityMajorCsln_CODE
         AND a.Status_CODE = @Lc_RemedyStatusStart_CODE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;

      IF @Li_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
        SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnwc_CODE;
        SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;

        RETURN;
       END
     END

     BEGIN

       SET @Ls_Sql_TEXT = 'SELECT_CMEM_DMNR_CSLN';
	   SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + @Lc_StatusCaseMemberActive_CODE + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorFidm_CODE + ', Status_CODE = ' + @Lc_RemedyStatusStart_CODE;
       SELECT @Ln_FidmNotRfinsStatusCount_QNTY = SUM (a.ActivityMinorNotRfinsCount_QNTY) ,
              @Ln_TotalCaseCount_QNTY = SUM (a.CaseCount_QNTY) 
         FROM (SELECT a.MemberMci_IDNO,
                      a.Case_IDNO,
                      a.ActivityMinor_CODE,
                      CASE
                       WHEN a.ActivityMinor_CODE <> @Lc_MinorActivityRfins_CODE
                        THEN 1
                       ELSE 0
                      END AS ActivityMinorNotRfinsCount_QNTY,
                      1 AS CaseCount_QNTY
                 FROM (SELECT m.MemberMci_IDNO,
                              m.Case_IDNO,
                              ISNULL (a.ActivityMinor_CODE, @Lc_Space_TEXT) AS ActivityMinor_CODE
                         FROM CMEM_Y1 m
                              LEFT OUTER JOIN DMNR_Y1 a
                               ON  m.MemberMci_IDNO = a.MemberMci_IDNO
									AND m.Case_IDNO = a.Case_IDNO
                        WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
                          AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                          AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                          AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorCsln_CODE, @Lc_ActivityMajorLien_CODE)
						 AND a.Status_CODE = @Lc_RemedyStatusStart_CODE
						 AND a.MinorIntSeq_NUMB = (SELECT MAX (b.MinorIntSeq_NUMB)
													 FROM DMNR_Y1 b
													WHERE a.Case_IDNO = b.Case_IDNO
													  AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
													  AND a.MajorIntSEQ_NUMB = b.MajorIntSEQ_NUMB)
                          )a) a;

		IF (@Ln_TotalCaseCount_QNTY = @Ln_FidmNotRfinsStatusCount_QNTY)
		BEGIN
			SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
			SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnwc_CODE;
			SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;
			RETURN;
		END
     END
    END

   IF @Ac_SourceReceipt_CODE IN (@Lc_SourceReceiptEmployerwageEW_CODE, @Lc_SourceReceiptUibUC_CODE, @Lc_SourceReceiptDisabilityinsurDB_CODE)
    BEGIN
     IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
      BEGIN
       -- IF Income Withholding is not active on any Case, system post the receipt at the Payor Level
       -- IF NCP has multiple Cases then posts Receipt only to Cases where Income Withholding is Active
       SET @Ls_Sql_TEXT = 'SELECT_IWEM_IwnStatus_CODE';
	   SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + ISNULL (@Lc_StatusCaseMemberActive_CODE, '');
       SELECT @Ln_IwnActiveStatusCount_QNTY = SUM (a.IwnStatusActive_CODE),
              @Ln_IwnNoRecordStatusCount_QNTY = SUM (a.iwn_no_status),
              @Ln_TotalCaseCount_QNTY = SUM (a.CaseCount_QNTY),
              @Ln_TotalCaseExmtCount_QNTY = SUM(a.CaseExmtCount_QNTY)
         FROM (SELECT a.MemberMci_IDNO,
                      a.Case_IDNO,
                      a.IwnStatus_CODE,
                      CASE
                       WHEN a.IwnStatus_CODE = @Lc_IwnActiveStatus_CODE
                        THEN 1
                       ELSE 0
                      END AS IwnStatusActive_CODE,    
                      CASE
                       WHEN a.IwnStatus_CODE NOT IN (@Lc_IwnActiveStatus_CODE)
                        THEN 1
                       ELSE 0
                      END AS Iwn_No_Status,
                      1 AS CaseCount_QNTY,
                      ISNULL((SELECT TOP 1 1 FROM DMJR_Y1 b WHERE b.Case_IDNO = a.Case_IDNO AND ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE AND Status_CODE = @Lc_StatusExmt_CODE AND @Ad_Process_DATE BETWEEN BeginExempt_DATE	AND EndExempt_DATE),0 )AS CaseExmtCount_QNTY
                 FROM (SELECT m.MemberMci_IDNO,
                              m.Case_IDNO,
                              ISNULL (w.IwnStatus_CODE, @Lc_Space_TEXT) AS IwnStatus_CODE
                         FROM CMEM_Y1 m
                              LEFT OUTER JOIN IWEM_Y1 w
                               ON m.Case_IDNO = w.Case_IDNO
                                  AND w.End_DATE = @Ld_High_DATE
                                  AND w.EndValidity_DATE = @Ld_High_DATE
                        WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
                          AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                          AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                           AND EXISTS (SELECT 1 FROM CASE_Y1 a, SORD_Y1 b,OBLE_Y1 c
										WHERE a.Case_IDNO = m.Case_IDNO
										AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
										AND a.Case_IDNO = b.Case_IDNO
										AND a.Case_IDNO = C.Case_IDNO
										AND C.EndValidity_DATE = @Ld_High_DATE)
                          ) a) a;

		IF (@Ln_IwnActiveStatusCount_QNTY = 0 AND @Ln_IwnNoRecordStatusCount_QNTY > 0 AND @Ln_IwnNoRecordStatusCount_QNTY = @Ln_TotalCaseExmtCount_QNTY AND  @Ln_IwnNoRecordStatusCount_QNTY = @Ln_TotalCaseCount_QNTY)
		BEGIN
			SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
			SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusShew_CODE;
			SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;
			RETURN;
		END
      END
    END

  /* 
   If the receipt source is 'QR-QDRO', the batch process checks if the case has an active QDRO indicator. If no QDRO indicator 
  	exists for case then the QR receipt is put on 'SNQR - System Hold Potential QDRO' hold.
  */
   -- SNQR - SYSTEM HOLD POTENTIAL QDRO/EDRO
   BEGIN
	IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptQdroQR_CODE  
     BEGIN
      
	 SET @Ls_Sql_TEXT = 'SELECT CMEM SORD - SNQR-1';
	 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '');
	 
	 SELECT @Ln_QdroActiveStatus_QNTY = COUNT(1)
	   FROM CMEM_Y1 m,
			SORD_Y1 s
	  WHERE ((@Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
			AND m.MemberMci_IDNO = @An_PayorMCI_IDNO
			AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
			AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
			AND m.Case_IDNO = s.Case_IDNO) 
		OR 
		(@Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
		 AND s.Case_IDNO = @An_Case_IDNO
		 AND m.Case_IDNO = s.Case_IDNO))			 
		AND s.EndValidity_DATE = @Ld_High_DATE
		AND @Ad_Process_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
		AND s.Qdro_INDC = @Lc_Yes_INDC;		
    
	 IF @Ln_QdroActiveStatus_QNTY = 0
      BEGIN
       SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
       SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSNQR_CODE;
       SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;
	   RETURN;
      END	     
     END   
   END	   

  /*
	If receipt source is F4 (Intergovernmental Payment): 
		If there are no ‘Initiating’ intergovernmental cases for the payor, the receipt will be put on ‘SNFP - Intergovernmental Payment; No Initiating Case’ hold.
		If there are one or more initiating intergovernmental cases for the payor, the receipt will be distributed to all the ‘Initiating’ cases.
  */

   BEGIN
	IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptInterstatIvdRegF4_CODE  
     BEGIN
      
     SET @Ls_Sql_TEXT = 'SELECT CMEM CASE - SNFP';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_PayorMCI_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'');
     SELECT @Ln_InitiatingCases_QNTY = COUNT(1)
       FROM CMEM_Y1 a,
            CASE_Y1 b
      WHERE a.MemberMci_IDNO = @An_PayorMCI_IDNO
        AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
        AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
        AND a.Case_IDNO = b.Case_IDNO
        AND b.RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE)
        AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

     IF @Ln_InitiatingCases_QNTY = 0
      BEGIN

       SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
       SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnfp_CODE;
       SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;
	   RETURN;      
      END      
     END   
   END	   
   
   -- ExcludeIrs_CODE Code Possible Values and Meaning
   -------------------------------------------------------------------
   -- Table/Screen		Value		Meaning
   -------------------------------------------------------------------
   -- IFMS_Y1/FEDH_Y1	N			Submitted - Not Excluded
   -- IFMS_Y1/FEDH_Y1	Y			NOT Submitted - Manual Excluded
   -- IFMS_Y1/FEDH_Y1	S			NOT Submitted - System Excluded
   -- TAXI				Y			Submitted - Not Excluded
   -- TAXI				N			NOT Submitted - Manual Excluded
   -- TAXI				S			NOT Submitted - System Excluded
   -------------------------------------------------------------------

   -- Insert #Tcord_P1
   IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_TCORD';
     SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', TypePosting_CODE = ' + ISNULL (@Ac_TypePosting_CODE, '') + ', SourceReceipt_CODE = ' + ISNULL (@Ac_SourceReceipt_CODE, '') + ', ReleasedFrom_CODE = ' + ISNULL (@Ac_ReleasedFrom_CODE, '') + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '')  + ', @Ln_IwnActiveStatusCount_QNTY = ' + ISNULL(CAST( @Ln_IwnActiveStatusCount_QNTY AS VARCHAR ),'') + ', @Ln_IwnNoRecordStatusCount_QNTY = ' + ISNULL(CAST( @Ln_IwnNoRecordStatusCount_QNTY AS VARCHAR ),'') + ', @Ln_TotalCaseCount_QNTY = ' + ISNULL(CAST( @Ln_TotalCaseCount_QNTY AS VARCHAR ),'') + ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     INSERT #Tcord_P1
            (Case_IDNO,
             Order_IDNO,
             OrderSeq_NUMB,
             OrderType_CODE,
             CaseType_CODE)
     (SELECT DISTINCT
             a.Case_IDNO,
             c.Order_IDNO,
             c.OrderSeq_NUMB,
             c.TypeOrder_CODE,
             b.TypeCase_CODE
        FROM CMEM_Y1 a,
             CASE_Y1 b,
             SORD_Y1 c
       WHERE a.MemberMci_IDNO = @An_PayorMCI_IDNO
         AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
         AND a.Case_IDNO = b.Case_IDNO
         AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
         AND c.Case_IDNO = a.Case_IDNO
         AND ((@Ac_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollectionSC_CODE, @Lc_SourceReceiptStateTaxRefundST_CODE, @Lc_SourceReceiptEmployerwageEW_CODE, 
											 @Lc_SourceReceiptUibUC_CODE, @Lc_SourceReceiptDisabilityinsurDB_CODE,@Lc_SourceReceiptQdroQR_CODE, 
											 @Lc_SourceReceiptInterstatIvdRegF4_CODE, @Lc_SourceReceiptLevyFidmFD_CODE, @Lc_SourceReceiptCslnLN_CODE))
			   OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollectionSC_CODE
               AND c.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
			   -- DECSS distribution program will always check case certification existance for IRS Receipts distribution. Certified case – is the case submitted for IRS tax offset intercept. Certified cases do not include IRS excluded/exempted cases, responding cases, or Non IV-D cases.       
               AND EXISTS (SELECT 1
                             FROM IFMS_Y1 f
                            WHERE f.MemberMci_IDNO = @An_PayorMCI_IDNO
                              AND f.Case_IDNO = b.Case_IDNO
                              AND f.ExcludeIrs_CODE = @Lc_No_INDC
                              AND f.TypeTransaction_CODE IN (@Ac_IrsCertAdd_CODE, @Ac_IrsCertMod_CODE)
                              AND f.SubmitLast_DATE < @Ad_Receipt_DATE
                              AND f.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                                                  FROM IFMS_Y1 h
                                                                 WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                   AND f.Case_IDNO = h.Case_IDNO
                                                                   -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - Start --
                                                                   AND f.TypeArrear_CODE = h.TypeArrear_CODE
                                                                   AND h.TypeTransaction_CODE IN (@Ac_IrsCertAdd_CODE, @Ac_IrsCertMod_CODE)
                                                                   -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - End --
                                                                   AND h.SubmitLast_DATE < @Ad_Receipt_DATE)
                           UNION
                           SELECT 1
                             FROM HIFMS_Y1 f
                            WHERE f.MemberMci_IDNO = @An_PayorMCI_IDNO
                              AND f.Case_IDNO = b.Case_IDNO
                              AND f.ExcludeIrs_CODE = @Lc_No_INDC
                              AND f.TypeTransaction_CODE IN (@Ac_IrsCertAdd_CODE, @Ac_IrsCertMod_CODE)
                              AND f.SubmitLast_DATE < @Ad_Receipt_DATE
                              AND f.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                                                  FROM HIFMS_Y1 h
                                                                 WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                   AND f.Case_IDNO = h.Case_IDNO
                                                                   -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - Start --
                                                                   AND f.TypeArrear_CODE = h.TypeArrear_CODE
                                                                   AND h.TypeTransaction_CODE IN (@Ac_IrsCertAdd_CODE, @Ac_IrsCertMod_CODE)
                                                                   -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - End --
                                                                   AND h.SubmitLast_DATE < @Ad_Receipt_DATE)))
               OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptStateTaxRefundST_CODE
                   AND EXISTS (SELECT 1
                                 FROM ISTX_Y1 s
                                WHERE s.MemberMci_IDNO = @An_PayorMCI_IDNO
                                  AND s.Case_IDNO = b.Case_IDNO
                                  AND s.TypeTransaction_CODE IN (@Lc_TypeTransactionI_CODE, @Lc_TypeTransactionC_CODE)
                                  AND s.SubmitLast_DATE < @Ad_Receipt_DATE
                                  AND s.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                                                      FROM ISTX_Y1 h
                                                                     WHERE s.MemberMci_IDNO = h.MemberMci_IDNO
                                                                       AND s.Case_IDNO = h.Case_IDNO
                                                                       AND h.TypeTransaction_CODE IN (@Lc_TypeTransactionI_CODE, @Lc_TypeTransactionC_CODE)
                                                                       AND h.SubmitLast_DATE < @Ad_Receipt_DATE)))
				OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptStateTaxRefundST_CODE
                   AND @Ac_ReleasedFrom_CODE = @Lc_HoldReasonStatusSnsn_CODE)                                                                                          
               OR (@Ac_SourceReceipt_CODE IN (@Lc_SourceReceiptEmployerwageEW_CODE, @Lc_SourceReceiptUibUC_CODE, @Lc_SourceReceiptDisabilityinsurDB_CODE)                   
                   AND ((@Ln_IwnActiveStatusCount_QNTY > 0
                         AND @Ln_IwnActiveStatusCount_QNTY = @Ln_TotalCaseCount_QNTY
                         )
                         OR (@Ln_IwnNoRecordStatusCount_QNTY > 0
                             AND @Ln_IwnNoRecordStatusCount_QNTY = @Ln_TotalCaseCount_QNTY
							 AND NOT EXISTS (SELECT	1
											  FROM  DMJR_Y1 b 
											 WHERE  b.Case_IDNO = a.Case_IDNO 
											   AND  b.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE 
											   AND  b.Status_CODE = @Lc_StatusExmt_CODE
											   AND @Ad_Process_DATE BETWEEN BeginExempt_DATE AND EndExempt_DATE)
                             )
                         OR (@Ln_IwnActiveStatusCount_QNTY > 0
                             AND @Ln_IwnActiveStatusCount_QNTY <> @Ln_TotalCaseCount_QNTY
                         AND NOT EXISTS (SELECT	1
											  FROM  DMJR_Y1 b 
											 WHERE  b.Case_IDNO = a.Case_IDNO 
											   AND  b.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE 
											   AND  b.Status_CODE = @Lc_StatusExmt_CODE
											   AND @Ad_Process_DATE BETWEEN BeginExempt_DATE AND EndExempt_DATE)                             
                                            )
                                            )
	                                            
                          )
			 OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptQdroQR_CODE
				  AND @Ad_Process_DATE BETWEEN c.OrderEffective_DATE AND c.OrderEnd_DATE
                   AND c.Qdro_INDC = @Lc_Yes_INDC)                         
               OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptInterstatIvdRegF4_CODE
				   AND b.RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE)
                    )                          
               OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptLevyFidmFD_CODE
                   AND EXISTS (SELECT 1
                                 FROM DMNR_Y1 n
                                WHERE a.Case_IDNO = n.Case_IDNO
                                  AND n.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
                                  AND n.Status_CODE = @Lc_RemedyStatusStart_CODE
                                  AND n.ActivityMinor_CODE = @Lc_MinorActivityMorfd_CODE
                                  AND n.MinorIntSeq_NUMB = (SELECT MAX (b.MinorIntSeq_NUMB)
                                                              FROM DMNR_Y1 b
                                                             WHERE n.Case_IDNO = b.Case_IDNO
                                                               AND n.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                               AND n.MajorIntSEQ_NUMB = b.MajorIntSEQ_NUMB)))
               OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptCslnLN_CODE
                   AND EXISTS (SELECT 1
                                 FROM DMNR_Y1 n
                                WHERE a.Case_IDNO = n.Case_IDNO
                                  AND n.ActivityMajor_CODE IN (@Lc_ActivityMajorCsln_CODE, @Lc_ActivityMajorLien_CODE) -- = @Lc_ActivityMajorCsln_CODE
                                  AND n.Status_CODE = @Lc_RemedyStatusStart_CODE
                                  AND n.ActivityMinor_CODE IN (@Lc_MinorActivityRfins_CODE)
                                  AND n.MinorIntSeq_NUMB = (SELECT MAX (b.MinorIntSeq_NUMB)
                                                              FROM DMNR_Y1 b
                                                             WHERE n.Case_IDNO = b.Case_IDNO
                                                               AND n.OrderSeq_NUMB = b.OrderSeq_NUMB
                                                               AND n.MajorIntSEQ_NUMB = b.MajorIntSEQ_NUMB))))
         AND c.EndValidity_DATE = @Ld_High_DATE);
    END    
   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record , as the Receipt will be put on Hold
   ELSE IF @Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_TCORD1';
	 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ', TypePosting_CODE = ' + ISNULL (@Ac_TypePosting_CODE, '') + ', SourceReceipt_CODE = ' + ISNULL (@Ac_SourceReceipt_CODE, '') + ', ReleasedFrom_CODE = ' + ISNULL (@Ac_ReleasedFrom_CODE, '') + ', Receipt_DATE = ' + ISNULL (CAST(@Ad_Receipt_DATE AS VARCHAR), '')  + ', @Ln_IwnActiveStatusCount_QNTY = ' + ISNULL(CAST( @Ln_IwnActiveStatusCount_QNTY AS VARCHAR ),'') + ', @Ln_IwnNoRecordStatusCount_QNTY = ' + ISNULL(CAST( @Ln_IwnNoRecordStatusCount_QNTY AS VARCHAR ),'') + ', @Ln_TotalCaseCount_QNTY = ' + ISNULL(CAST( @Ln_TotalCaseCount_QNTY AS VARCHAR ),'') + ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
     INSERT #Tcord_P1
            (Case_IDNO,
             Order_IDNO,
             OrderSeq_NUMB,
             OrderType_CODE,
             CaseType_CODE)
     (SELECT DISTINCT
             a.Case_IDNO,
             b.Order_IDNO,
             b.OrderSeq_NUMB,
             b.TypeOrder_CODE,
             a.TypeCase_CODE
        FROM CASE_Y1 a,
             SORD_Y1 b
       WHERE a.Case_IDNO = @An_Case_IDNO
         AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
         AND b.Case_IDNO = a.Case_IDNO
         AND b.EndValidity_DATE = @Ld_High_DATE
         AND ((@Ac_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollectionSC_CODE, @Lc_SourceReceiptStateTaxRefundST_CODE))
               OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollectionSC_CODE
                   AND b.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
				   -- DECSS distribution program will always check case certification existance for IRS Receipts distribution. Certified case – is the case submitted for IRS tax offset intercept. Certified cases do not include IRS excluded/exempted cases, responding cases, or Non IV-D cases.
                   AND EXISTS (SELECT 1
                                 FROM IFMS_Y1 f
                                WHERE f.MemberMci_IDNO = @An_PayorMCI_IDNO
                                  AND f.Case_IDNO = b.Case_IDNO
                                  AND f.ExcludeIrs_CODE = @Lc_No_INDC
                                  AND f.TypeTransaction_CODE IN (@Ac_IrsCertAdd_CODE, @Ac_IrsCertMod_CODE)
                                  AND f.SubmitLast_DATE < @Ad_Receipt_DATE
                                  AND f.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                                                      FROM IFMS_Y1 h
                                                                     WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                       AND f.Case_IDNO = h.Case_IDNO
                                                                       -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - Start --
                                                                       AND f.TypeArrear_CODE = h.TypeArrear_CODE
                                                                       AND h.TypeTransaction_CODE IN (@Ac_IrsCertAdd_CODE, @Ac_IrsCertMod_CODE)
                                                                       -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - End --                                                                       
                                                                       AND h.SubmitLast_DATE < @Ad_Receipt_DATE)
                               UNION
                               SELECT 1
                                 FROM HIFMS_Y1 f
                                WHERE f.MemberMci_IDNO = @An_PayorMCI_IDNO
                                  AND f.Case_IDNO = b.Case_IDNO
                                  AND f.ExcludeIrs_CODE = @Lc_No_INDC
                                  AND f.TypeTransaction_CODE IN (@Ac_IrsCertAdd_CODE, @Ac_IrsCertMod_CODE)
                                  AND f.SubmitLast_DATE < @Ad_Receipt_DATE
                                  AND f.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                                                      FROM HIFMS_Y1 h
                                                                     WHERE f.MemberMci_IDNO = h.MemberMci_IDNO
                                                                       AND f.Case_IDNO = h.Case_IDNO
                                                                       -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - Start --
                                                                       AND f.TypeArrear_CODE = h.TypeArrear_CODE
                                                                       AND h.TypeTransaction_CODE IN (@Ac_IrsCertAdd_CODE, @Ac_IrsCertMod_CODE)
                                                                       -- DECSS Change:Distribution Code changed to calculate the Certified Arrears correctly from the History Table as well while processing the IRS Receipt. - End --                                                                       
                                                                       AND h.SubmitLast_DATE < @Ad_Receipt_DATE)))
               OR (@Ac_SourceReceipt_CODE IN (@Lc_SourceReceiptStateTaxRefundST_CODE)
                   AND EXISTS (SELECT 1
                                 FROM ISTX_Y1 s
                                WHERE s.MemberMci_IDNO = @An_PayorMCI_IDNO
                                  AND s.Case_IDNO = b.Case_IDNO
                                  AND s.TypeTransaction_CODE IN (@Lc_TypeTransactionI_CODE, @Lc_TypeTransactionC_CODE)
                                  AND s.SubmitLast_DATE < @Ad_Receipt_DATE
                                  AND s.TransactionEventSeq_NUMB = (SELECT MAX (h.TransactionEventSeq_NUMB)
                                                                      FROM ISTX_Y1 h
                                                                     WHERE s.MemberMci_IDNO = h.MemberMci_IDNO
                                                                       AND s.Case_IDNO = h.Case_IDNO
                                                                       AND h.TypeTransaction_CODE IN (@Lc_TypeTransactionI_CODE, @Lc_TypeTransactionC_CODE)
                                                                       AND h.SubmitLast_DATE < @Ad_Receipt_DATE)))
			OR (@Ac_SourceReceipt_CODE = @Lc_SourceReceiptStateTaxRefundST_CODE
			   AND @Ac_ReleasedFrom_CODE = @Lc_HoldReasonStatusSnsn_CODE)));
    END

   -- No need to Handle the Exception here as the Batch can Proceed further even if the
   -- above Insert Fail to insert any record , as the Receipt will be put on Hold
   -- Check whether there any Active obligation exists for the Case if not then put it on SNNO Hold
   SET @Ls_Sql_TEXT = 'SELECT_OBLE_TCORD_SNNO';
   SET @Ls_Sqldata_TEXT = 'SourceReceipt_CODE = ' + ISNULL (@Ac_SourceReceipt_CODE, '') + 'EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ld_BeginObligation_DATE = ISNULL (MIN (o.BeginObligation_DATE), @Ld_Low_DATE)
     FROM #Tcord_P1 c,
          OBLE_Y1 o
    WHERE c.Case_IDNO = o.Case_IDNO
      AND c.OrderSeq_NUMB = o.OrderSeq_NUMB
      AND o.EndValidity_DATE = @Ld_High_DATE
      AND ((@Ac_SourceReceipt_CODE IN (@Lc_SourceReceiptSpecialCollectionSC_CODE, @Lc_SourceReceiptStateTaxRefundST_CODE)
            AND c.OrderType_CODE != @Lc_TypeOrderVoluntary_CODE)
            OR @Ac_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptSpecialCollectionSC_CODE, @Lc_SourceReceiptStateTaxRefundST_CODE));

   IF  ISNULL (@Ld_BeginObligation_DATE, @Ld_Low_DATE) = @Ld_Low_DATE
    BEGIN
     SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
     SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnno_CODE;
     SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;

     RETURN;
    END
   ELSE IF @Ld_BeginObligation_DATE >= dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY (@Ad_Receipt_DATE) 
      AND @Ad_Process_DATE < @Ld_BeginObligation_DATE
    BEGIN
     SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
     SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusSnpo_CODE;
     SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;

     RETURN;
    END

   BEGIN
    SET @Ls_Sql_TEXT = 'SELECT TCORD_Y1 FOR NIVD CASE';
	SET @Ls_Sqldata_TEXT = 'CaseType_CODE = ' + @Lc_NonIvdCaseType_CODE;
    SELECT TOP 1 @Ln_Value_NUMB = 1
      FROM #Tcord_P1 a
     WHERE CaseType_CODE <> @Lc_NonIvdCaseType_CODE;

    SET @Li_Rowcount_QNTY = @@ROWCOUNT;

    IF @Li_Rowcount_QNTY = 0
     BEGIN
      SET @Ac_N4dFlag_INDC = @Lc_Yes_INDC;
     END
    ELSE
     BEGIN
      SET @Ac_N4dFlag_INDC = @Lc_No_INDC;
     END
   END

   -- Check whether the Receipt Source is eligble for Distribution to Non-IVD Cases if not
   -- put it on SHND Hold
   BEGIN
    SET @Ls_Sql_TEXT = 'SELECT_HIMS_SHND';
    SET @Ls_Sqldata_TEXT = 'SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
    
    SELECT @Lc_DistNonIvd_INDC = a.DistNonIvd_INDC
      FROM HIMS_Y1 a
     WHERE a.SourceReceipt_CODE = @Ac_SourceReceipt_CODE
       AND a.EndValidity_DATE = @Ld_High_DATE;

    SET @Li_Rowcount_QNTY = @@ROWCOUNT;

    IF @Li_Rowcount_QNTY = 0
     BEGIN
      SET @Lc_DistNonIvd_INDC = @Lc_No_INDC;
     END
   END

   -- When there is receipt Source is not Eligble for Distribution to NIVD Cases and there
   -- not exists any IVD Case then the Receipt is held with SHND Hold
   IF @Lc_DistNonIvd_INDC = @Lc_No_INDC
      AND @Ac_N4dFlag_INDC = @Lc_Yes_INDC
    BEGIN
     SET @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
     SET @Ac_ReasonStatus_CODE = @Lc_HoldReasonStatusShnd_CODE;
     SET @Ac_RcptToProcess_INDC = @Lc_No_INDC;

     RETURN;
    END

   -- If the receipt Source is not Eligble to distribute to N4D Case and there exists another IVD Case
   -- for the Payor then distribute the money only to the IVD Cases
   IF @Lc_DistNonIvd_INDC = @Lc_No_INDC
      AND @Ac_N4dFlag_INDC = @Lc_No_INDC
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE TCORD_Y1 NIVD CASES';
	 SET @Ls_Sqldata_TEXT = 'CaseType_CODE = ' + @Lc_NonIvdCaseType_CODE;
     DELETE #Tcord_P1
      WHERE CaseType_CODE = @Lc_NonIvdCaseType_CODE;
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
