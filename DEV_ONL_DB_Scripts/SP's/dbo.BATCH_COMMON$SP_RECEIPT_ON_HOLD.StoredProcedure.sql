/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_RECEIPT_ON_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_RECEIPT_ON_HOLD
Programmer Name 	: IMP Team
Description			: This procedure checks the receipt to determine if all or any part of the amount should be placed on hold.
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: BATCH_FIN_COLLECTIONS$SP_PROCESS_COLLECTIONS
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_RECEIPT_ON_HOLD]
 @Ac_TypePosting_CODE      CHAR(1),
 @An_CasePayorMCI_IDNO     NUMERIC(10),
 @Ac_SourceReceipt_CODE    CHAR(2),
 @An_Receipt_AMNT          NUMERIC(11, 2),
 @Ad_Receipt_DATE          DATE,
 @Ad_Run_DATE              DATE,
 @Ac_TypeRemittance_CODE   CHAR(3) = ' ',
 @Ac_SuspendPayment_CODE   CHAR(1) = '0',
 @Ac_Process_ID            CHAR(10) = 'DEB0540',
 @An_Held_AMNT             NUMERIC(11, 2) OUTPUT,
 @An_Identified_AMNT       NUMERIC(11, 2) OUTPUT,
 @Ad_Release_DATE          DATE OUTPUT,
 @Ac_ReasonHold_CODE       CHAR(4) OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                           CHAR(1) = ' ',
          @Lc_NoSpace_TEXT                         CHAR(1) = '',
          @Lc_CaseMemberStatusActive_CODE          CHAR(1) = 'A',
          @Lc_CaseStatusOpen_CODE                  CHAR(1) = 'O',
          @Lc_CaseRelationshipNcp_CODE             CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE       CHAR(1) = 'P',
          @Lc_StatusFailed_CODE                    CHAR(1) = 'F',
          @Lc_RespondInitI_CODE                    CHAR(1) = 'I',
          @Lc_RespondInitC_CODE                    CHAR(1) = 'C',
          @Lc_RespondInitT_CODE                    CHAR(1) = 'T',
          @Lc_RespondInitN_CODE                    CHAR(1) = 'N',
          @Lc_RespondInitY_CODE                    CHAR(1) = 'Y',
          @Lc_RespondInitR_CODE                    CHAR(1) = 'R',
          @Lc_RespondInitS_CODE                    CHAR(1) = 'S',                              
          @Lc_Yes_INDC                             CHAR(1) = 'Y',
          @Lc_No_INDC                              CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE                   CHAR(1) = 'S',
          @Lc_SuspendPayment1_CODE                 CHAR(1) = '1',
          @Lc_TypePostingCase_CODE                 CHAR(1) = 'C',
          @Lc_TypePostingPayor_CODE                CHAR(1) = 'P',
          @Lc_ReceiptSrcInterstatIvdRegF4_CODE     CHAR(2) = 'F4',
          @Lc_ReceiptSrcInterstatIvdFeeFF_CODE     CHAR(2) = 'FF',
          @Lc_ReceiptSrcEmployerwageEW_CODE        CHAR(2) = 'EW',
          @Lc_ReceiptSrcUibUC_CODE                 CHAR(2) = 'UC',
          @Lc_ReceiptSrcQdroQR_CODE                CHAR(2) = 'QR',
          @Lc_ReceiptSrcFidmFD_CODE                CHAR(2) = 'FD',
          @Lc_ReceiptSrcCslnLN_CODE                CHAR(2) = 'LN',
          @Lc_ReceiptSrcSequestrationLevySQ_CODE   CHAR(2) = 'SQ',
          @Lc_ReceiptSrcDisabilityinsurDB_CODE     CHAR(2) = 'DB',
          @Lc_ReceiptSrcWorkersCompensationWC_CODE CHAR(2) = 'WC',
          @Lc_ReceiptSrcDh_CODE                    CHAR(2) = 'DH',
          @Lc_SubsystemFm_CODE                     CHAR(2) = 'FM',
          @Lc_SourceReceiptSpecialCollectionSC_CODE CHAR (2) = 'SC',
          @Lc_SourceReceiptCpRecoupmentCR_CODE		CHAR(2) = 'CR',
          @Lc_SourceReceiptCpFeePaymentCF_CODE		CHAR(2) = 'CF',          
          @Lc_RemitTypeCheck_CODE                  CHAR(3) = 'CHK',
          @Lc_HoldReasonStatusSncc_CODE            CHAR (4) = 'SNCC',
          @Lc_HoldReasonStatusSncl_CODE            CHAR (4) = 'SNCL',
          @Lc_ActivityMajorCase_CODE               CHAR(4) = 'CASE',
		  @Lc_ActivityMajorSeqo_CODE               CHAR(4) = 'SEQO',            
          @Lc_HoldRsnSnfp_CODE                     CHAR(4) = 'SNFP',
          @Lc_HoldReasonStatusSsdu_CODE            CHAR(4) = 'SSDU',
          @Lc_HoldRsnShru_CODE                     CHAR(4) = 'SHRU',
          @Lc_HoldRsnSnqr_CODE                     CHAR(4) = 'SNQR',
          @Lc_HoldRsnSnsq_CODE                     CHAR(4) = 'SNSQ',
          @Lc_HoldRsnSnwg_CODE                     CHAR(4) = 'SNWG',
          @Lc_RemedyStatusStart_CODE               CHAR(4) = 'STRT',
          @Lc_RemedyStatusComp_CODE                CHAR(4) = 'COMP',
          @Lc_ActivityMinorFidmp_CODE              CHAR(5) = 'FIDMP',
          @Lc_ActivityMinorQdrop_CODE              CHAR(5) = 'QDROP',
          @Lc_ActivityMinorSeqlp_CODE              CHAR(5) = 'SEQLP',
          @Lc_ActivityMinorInsup_CODE              CHAR(5) = 'INSUP',          
          @Lc_BatchRunUser_ID                      CHAR(5) = 'BATCH',
          @Lc_CollectionJob_ID					   CHAR(7) = 'DEB0540',
          @Ls_Procedure_NAME                       VARCHAR(100) = 'BATCH_COMMON$SP_RECEIPT_ON_HOLD',
          @Ls_Error01_TEXT                         VARCHAR(300) = 'NO ACTIVE NCP/PUTATIVE FATHER FOUND',
          @Ls_Error02_TEXT                         VARCHAR(300) = 'INVALID RECEIPT SOURCE',
          @Ls_Error03_TEXT                         VARCHAR(300) = 'NO RECORD FOUND IN UCAT_Y1 FOR SSDU UDC CODE',
          @Ls_Error04_TEXT                         VARCHAR(300) = 'NO RECORD FOUND IN UCAT_Y1 FOR SNQR UDC CODE',
          @Ls_Error05_TEXT                         VARCHAR(300) = 'NO RECORD FOUND IN UCAT_Y1 FOR SHRU UDC CODE',
          @Ls_Error06_TEXT                         VARCHAR(300) = 'BOTH HELD AND IDENTIFIED AMOUNTS RETURNED ZERO VALUE',
          @Ls_Error07_TEXT                         VARCHAR(300) = 'NO RECORD FOUND IN UCAT_Y1 FOR SNFP UDC CODE',
          @Ld_High_DATE                            DATE = '12/31/9999';
  
  DECLARE @Ln_Value_NUMB			   NUMERIC (1) = 0,
		  @Ln_FetchStatus_QNTY         NUMERIC,
          @Ln_Rowcount_QNTY            NUMERIC,
          @Ln_OfDaysHold_NUMB          NUMERIC(5),
          @Ln_Case_IDNO                NUMERIC(6),
          @Ln_QdroActiveStatus_QNTY    NUMERIC(10),
          @Ln_SeqoActivityChainStatus_QNTY NUMERIC(10),
          @Ln_InitiatingCases_QNTY     NUMERIC(10),
          @Ln_InstateRespondCases_QNTY NUMERIC(10),          
          @Ln_Topic_NUMB               NUMERIC(10),
          @Ln_PayorMCI_IDNO            NUMERIC(10),
          @Ln_Held_AMNT                NUMERIC(11, 2),
          @Ln_Identified_AMNT          NUMERIC(11, 2),
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Li_Rowcount_QNTY            SMALLINT,
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_TypePosting_CODE         CHAR(1),
          @Lc_ActivityMinor_CODE       CHAR(5),
          @Ls_Sql_TEXT                 VARCHAR(100),
          @Ls_Sqldata_TEXT             VARCHAR(100),
          @Ls_ErrorMessage_TEXT        VARCHAR(4000),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ld_ToDay_DATE               DATE;
  DECLARE @Ln_CaseMemberCur_Case_IDNO      NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO NUMERIC(10);

  BEGIN TRY
   SET @An_Held_AMNT = 0;
   SET @Ac_Msg_CODE = @Lc_NoSpace_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_NoSpace_TEXT;
   SET @An_Held_AMNT = 0;
   SET @An_Identified_AMNT = @An_Receipt_AMNT;
   SET @Ld_ToDay_DATE = @Ad_Run_DATE;
   SET @Ad_Release_DATE = @Ld_ToDay_DATE;
   SET @Ac_ReasonHold_CODE = @Lc_Space_TEXT;
   SET @Ln_OfDaysHold_NUMB = 0;
   SET @Ln_OfDaysHold_NUMB = 0;
   SET @Ln_QdroActiveStatus_QNTY = 0;
   SET @Ln_SeqoActivityChainStatus_QNTY = 0;
   SET @Ln_InitiatingCases_QNTY = 0;
   SET @Ln_InstateRespondCases_QNTY = 0;
   SET @Ln_Held_AMNT = 0;
   SET @Ln_Identified_AMNT = 0;
   SET @Ls_ErrorMessage_TEXT = '';

   IF @Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
    BEGIN
     SET @Ln_Case_IDNO = @An_CasePayorMCI_IDNO;
    END
   ELSE
    BEGIN
     IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
      BEGIN
       SET @Ln_PayorMCI_IDNO = @An_CasePayorMCI_IDNO;
      END
    END

   IF @Ln_Case_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_Case_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'');

     BEGIN
      SELECT @Ln_PayorMCI_IDNO = a.MemberMci_IDNO
        FROM CMEM_Y1 a
       WHERE a.Case_IDNO = @Ln_Case_IDNO
         AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      -- 'NO ACTIVE NCP/PUTATIVE FOUND'
      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 1';
        SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error01_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_Error01_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = 0,
         @An_ErrorLine_NUMB        = 0,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

        RETURN;
       END
     END
    END

   SET @Ls_Sql_TEXT = 'SELECT HIMS_Y1 1';
   SET @Ls_Sqldata_TEXT = 'SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
   BEGIN
    SELECT @Lc_TypePosting_CODE = h.TypePosting_CODE
      FROM HIMS_Y1 h
     WHERE h.SourceReceipt_CODE = @Ac_SourceReceipt_CODE
       AND h.EndValidity_DATE = @Ld_High_DATE;

    SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

    -- 'INVALID RECEIPT SOURCE'
    IF @Ln_Rowcount_QNTY = 0
     BEGIN
      SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 2';
      SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error02_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_Error02_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = 0,
       @An_ErrorLine_NUMB        = 0,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

      RETURN;
     END
   END

   -- If SDU source's receipts Hold indicator is 1, then check will be placed on a SSDU Collections Received SDU as a Hold with Special 
   -- Instructions for 14 calendar days.
   -- SSDU - COLLECTION RECEIVED FROM SDU AS A HOLD WITH SPECIAL INSTRUCTIONS
   IF @Ac_SuspendPayment_CODE = @Lc_SuspendPayment1_CODE
    BEGIN
     -- Hold days selection for SSDU udc code
     SET @Ln_OfDaysHold_NUMB = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SSDU';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_HoldReasonStatusSsdu_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_OfDaysHold_NUMB = a.NumDaysHold_QNTY
       FROM UCAT_Y1 a
      WHERE a.Udc_CODE = @Lc_HoldReasonStatusSsdu_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
     -- 'NO RECORD FOUND IN UCAT_Y1 FOR SSDU UDC CODE'
     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 3';
       SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error03_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
       EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
        @As_Procedure_NAME        = @Ls_Procedure_NAME,
        @As_ErrorMessage_TEXT     = @Ls_Error03_TEXT,
        @As_Sql_TEXT              = @Ls_Sql_TEXT,
        @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
        @An_Error_NUMB            = 0,
        @An_ErrorLine_NUMB        = 0,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

       RETURN;
      END

     SET @Ac_ReasonHold_CODE = @Lc_HoldReasonStatusSsdu_CODE;
     SET @An_Held_AMNT = @An_Receipt_AMNT;
     SET @An_Identified_AMNT = 0;
     SET @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ld_ToDay_DATE);
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

	 RETURN;
    END
  
  -- Information alert applicable only when receipt posting via collection batch process
  IF @Ac_Process_ID = @Lc_CollectionJob_ID
  BEGIN
   -- If the receipt source is 'FD â€“ FIDM', 'QR â€“ QDRO', 'SQ â€“ Sequestration Levy', 'LN â€“ Insurance (CSLN)', then an information alert is generated to the authorized worker.
   -- Cursor For Member and Case Details
   IF @Ac_SourceReceipt_CODE IN (@Lc_ReceiptSrcFidmFD_CODE, @Lc_ReceiptSrcQdroQR_CODE, @Lc_ReceiptSrcCslnLN_CODE, @Lc_ReceiptSrcSequestrationLevySQ_CODE)
    BEGIN
     DECLARE CaseMemberCur INSENSITIVE CURSOR FOR
      SELECT a.Case_IDNO,
             a.MemberMci_IDNO
        FROM CMEM_Y1 a,
             CASE_Y1 b
       WHERE a.MemberMci_IDNO = @Ln_PayorMCI_IDNO
         AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
         AND a.Case_IDNO = b.Case_IDNO
         AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

     BEGIN
      SET @Ls_Sql_TEXT = 'OPEN CaseMemberCur';

      OPEN CaseMemberCur;

      SET @Ls_Sql_TEXT = 'FETCH CaseMemberCur - 2';

      FETCH NEXT FROM CaseMemberCur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO

      SELECT @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

      IF @Ln_FetchStatus_QNTY = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1'

        EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_ID,
         @Ac_Process_ID               = @Ac_Process_ID,
         @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
         @Ac_Note_INDC                = @Lc_No_INDC,
         @An_EventFunctionalSeq_NUMB  = 0,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1)
         END
       END

      SELECT @Lc_ActivityMinor_CODE = CASE @Ac_SourceReceipt_CODE
                                       WHEN @Lc_ReceiptSrcFidmFD_CODE
                                        THEN @Lc_ActivityMinorFidmp_CODE
                                       WHEN @Lc_ReceiptSrcQdroQR_CODE
                                        THEN @Lc_ActivityMinorQdrop_CODE
                                       WHEN @Lc_ReceiptSrcSequestrationLevySQ_CODE
                                        THEN @Lc_ActivityMinorSeqlp_CODE
                                       WHEN @Lc_ReceiptSrcCslnLN_CODE
                                        THEN @Lc_ActivityMinorInsup_CODE
                                      END;

      WHILE @Ln_FetchStatus_QNTY = 0
       BEGIN
        /*
        Record will be created in DMNR_Y1 for the all open cases of the member using sp_insert_activity one of the below possible value based on Receipt Source
        FIDMP - FIDM Payment is posted to the case
        QDROP - QDRO Payment is posted to the case
        SEQLP - Sequestration Levy payment is posted to the case
        INSUP - Insurance Payment is posted to the case
        */
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
		SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CaseMemberCur_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR ),'')+ ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemFm_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_ID,'');
        EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
         @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
         @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
         @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
         @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
         @Ac_Subsystem_CODE           = @Lc_SubsystemFm_CODE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_ID,
         @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        FETCH NEXT FROM CaseMemberCur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

        SELECT @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
       END

      CLOSE CaseMemberCur;

      DEALLOCATE CaseMemberCur;
     END
    END
	END
	
    -- Defect 13522 - Issue with changing Receipt Source from NCP payment to CP payment in DECSS - Fix - Start -- 
	-- SNCL, SNCC hold applicable only for NON CR, NON CF receipts
	IF @Ac_SourceReceipt_CODE NOT IN (@Lc_SourceReceiptCpRecoupmentCR_CODE, @Lc_SourceReceiptCpFeePaymentCF_CODE)
	-- Defect 13522 - Issue with changing Receipt Source from NCP payment to CP payment in DECSS - Fix - End -- 
	BEGIN
   -- Check whether the Payor's Case is Closed if so put in SNCL Hold
   -- If its an IRS Receipt then put it on SNCC
  
    IF @Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_CASE_Y1_SNCL';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL (CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + @Lc_CaseStatusOpen_CODE;

      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM CASE_Y1 c
       WHERE c.Case_IDNO = @Ln_Case_IDNO
         AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     END
    ELSE IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT_CMEM_Y1_CASE_Y1_SNCL';
      SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO ' + ISNULL (CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + @Lc_CaseStatusOpen_CODE;

      SELECT TOP 1 @Ln_Value_NUMB = 1
        FROM CMEM_Y1 m,
             CASE_Y1 c
       WHERE m.MemberMci_IDNO = @Ln_PayorMCI_IDNO
         AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND m.Case_IDNO = c.Case_IDNO
         AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

      SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     END

    IF @Li_Rowcount_QNTY = 0
     BEGIN
      IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptSpecialCollectionSC_CODE
       BEGIN
        SET @Ac_ReasonHold_CODE = @Lc_HoldReasonStatusSncc_CODE;
       END
      ELSE
       BEGIN
        SET @Ac_ReasonHold_CODE = @Lc_HoldReasonStatusSncl_CODE;
       END

		 SET @Ln_OfDaysHold_NUMB = 0;
		 SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNCC_SNCL';
		 SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Ac_ReasonHold_CODE, '');

		 BEGIN
		  SELECT @Ln_OfDaysHold_NUMB = u.NumDaysHold_QNTY
			FROM UCAT_Y1 u
		   WHERE u.Udc_CODE = @Ac_ReasonHold_CODE
			 AND u.EndValidity_DATE = @Ld_High_DATE;

		  SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

		  -- 'NO RECORD FOUND IN UCAT_Y1 FOR SNWG UDC CODE'
		  IF @Ln_Rowcount_QNTY = 0
		   BEGIN
			SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 3.1';
			SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error04_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
			EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
			 @As_Procedure_NAME        = @Ls_Procedure_NAME,
			 @As_ErrorMessage_TEXT     = @Ls_Error04_TEXT,
			 @As_Sql_TEXT              = @Ls_Sql_TEXT,
			 @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
			 @An_Error_NUMB            = 0,
			 @An_ErrorLine_NUMB        = 0,
			 @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

			SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

			RETURN;
		   END
		 END
		 
       SET @An_Held_AMNT = @An_Receipt_AMNT;
       SET @An_Identified_AMNT = 0;

       SELECT @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ld_ToDay_DATE);

       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;		 

      RETURN;
     END
	END

  /* 
   If the receipt source is 'QR-QDRO', the batch process checks if the at least one of the Payor's cases has an active QDRO indicator. If no QDRO indicator 
  	exists for any of the Payor's cases then the QR receipt is put on 'SNQR - System Hold Potential QDRO' hold.
  */
   -- SNQR - SYSTEM HOLD POTENTIAL QDRO/EDRO
   IF @Ac_SourceReceipt_CODE = @Lc_ReceiptSrcQdroQR_CODE
    BEGIN
     SET @Ln_OfDaysHold_NUMB = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNQR';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = SNQR';

     BEGIN
      SELECT @Ln_OfDaysHold_NUMB = u.NumDaysHold_QNTY
        FROM UCAT_Y1 u
       WHERE u.Udc_CODE = @Lc_HoldRsnSnqr_CODE
         AND u.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      -- 'NO RECORD FOUND IN UCAT_Y1 FOR SNQR UDC CODE'
      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 4';
        SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error04_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_Error04_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = 0,
         @An_ErrorLine_NUMB        = 0,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

        RETURN;
       END
     END

     SET @Ls_Sql_TEXT = 'SELECT CMEM SORD - SNQR-1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '');

     SELECT @Ln_QdroActiveStatus_QNTY = COUNT(1)
       FROM CMEM_Y1 m,
            SORD_Y1 s
      WHERE ((@Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
				AND m.MemberMci_IDNO = @Ln_PayorMCI_IDNO
				AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
				AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
				AND m.Case_IDNO = s.Case_IDNO) 
			OR 
			(@Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
			 AND s.Case_IDNO = @Ln_Case_IDNO))
        AND s.EndValidity_DATE = @Ld_High_DATE
        AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
        AND s.Qdro_INDC = @Lc_Yes_INDC;

     IF (@Ac_SourceReceipt_CODE = @Lc_ReceiptSrcQdroQR_CODE
         AND @Ln_QdroActiveStatus_QNTY = 0)
      BEGIN
       SET @Ac_ReasonHold_CODE = @Lc_HoldRsnSnqr_CODE;
       SET @An_Held_AMNT = @An_Receipt_AMNT;
       SET @An_Identified_AMNT = 0;

       SELECT @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ld_ToDay_DATE);

       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

       RETURN;
      END
    END

  /* 
   If the receipt source is 'SQ-SEQUESTRATION LEVY', the batch process checks if the at least one of the Payor's cases has an active Sequestration Order 
   Activity chain exists in active state. If no Sequestration Order Activity chain exists in active state
  	exists for any of the Payor's cases then the SQ receipt is put on 'SNSQ - SYSTEM HOLD SEQUESTRATION' hold.
  */
   -- SNSQ - SYSTEM HOLD SEQUESTRATION
   IF @Ac_SourceReceipt_CODE = @Lc_ReceiptSrcSequestrationLevySQ_CODE
    BEGIN
     SET @Ln_OfDaysHold_NUMB = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNSQ';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = SNSQ';

     BEGIN
      SELECT @Ln_OfDaysHold_NUMB = u.NumDaysHold_QNTY
        FROM UCAT_Y1 u
       WHERE u.Udc_CODE = @Lc_HoldRsnSnsq_CODE
         AND u.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      -- 'NO RECORD FOUND IN UCAT_Y1 FOR SNSQ UDC CODE'
      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 5';
        SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error04_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_Error04_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = 0,
         @An_ErrorLine_NUMB        = 0,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

        RETURN;
       END
     END

     SET @Ls_Sql_TEXT = 'SELECT CMEM DMJR - SNSQ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '');

	 SELECT @Ln_SeqoActivityChainStatus_QNTY = COUNT(1)  
     FROM CMEM_Y1 m,
          DMJR_Y1 n
    WHERE 
		((@Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
	  AND m.MemberMci_IDNO = @Ln_PayorMCI_IDNO
      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND m.Case_IDNO = n.Case_IDNO)
      OR
      (@Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
			 AND n.Case_IDNO = @Ln_Case_IDNO))
      AND n.ActivityMajor_CODE = @Lc_ActivityMajorSeqo_CODE
      AND n.Status_CODE IN (@Lc_RemedyStatusStart_CODE, @Lc_RemedyStatusComp_CODE)

     IF (@Ac_SourceReceipt_CODE = @Lc_ReceiptSrcSequestrationLevySQ_CODE
         AND @Ln_SeqoActivityChainStatus_QNTY = 0)
      BEGIN
       SET @Ac_ReasonHold_CODE = @Lc_HoldRsnSNSQ_CODE;
       SET @An_Held_AMNT = @An_Receipt_AMNT;
       SET @An_Identified_AMNT = 0;

       SELECT @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ld_ToDay_DATE);

       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

       RETURN;
      END
    END

  IF @Ac_Process_ID = @Lc_CollectionJob_ID
  BEGIN
  /* 
  Checking case level hold (SHCS - CASE SPECIFIC RECEIPT HOLD) in Hold Instruction Maintenance (HIMS_Y1) table for the receipt source. If there is a hold 
  instruction for the receipt source, the receipt will be placed on hold for the number of calendar days identified in the (HIMS_Y1, UCAT_Y1) table. 
  */
   -- SHCS - CASE SPECIFIC RECEIPT HOLD
   SET @Ls_Sql_TEXT = 'SELECT HIMS_Y1, UCAT_Y1 - SHCS';
   SET @Ls_Sqldata_TEXT = 'SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', CaseHold_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
   SELECT @Ln_OfDaysHold_NUMB = u.NumDaysHold_QNTY,
          @Ac_ReasonHold_CODE = u.Udc_CODE
     FROM HIMS_Y1 h,
          UCAT_Y1 u
    WHERE h.SourceReceipt_CODE = @Ac_SourceReceipt_CODE
      AND h.EndValidity_DATE = @Ld_High_DATE
      AND h.CaseHold_INDC = @Lc_Yes_INDC
      AND h.UdcCaseHold_CODE = u.Udc_CODE
      AND u.EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @An_Held_AMNT = 0;
     SET @An_Identified_AMNT = @An_Receipt_AMNT;
     SET @Ad_Release_DATE = @Ld_ToDay_DATE;
     SET @Ac_ReasonHold_CODE = @Lc_Space_TEXT;
    END
   ELSE
    BEGIN
     SET @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ad_Receipt_DATE);
     SET @An_Held_AMNT = @An_Receipt_AMNT;
     SET @An_Identified_AMNT = 0;
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

     RETURN;
    END
  END

  /* 
   Wage receipt (EW) will be put on SNWG hold if all of the NCPâ€™s cases are Initiating
  */
   -- SNWG - WAGE RECEIVED - ALL CASES ARE INITIATING
   IF @Ac_SourceReceipt_CODE IN (@Lc_ReceiptSrcEmployerwageEW_CODE)
    BEGIN
     SET @Ln_OfDaysHold_NUMB = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNWG';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = SNWG';

     BEGIN
      SELECT @Ln_OfDaysHold_NUMB = u.NumDaysHold_QNTY
        FROM UCAT_Y1 u
       WHERE u.Udc_CODE = @Lc_HoldRsnSnwg_CODE
         AND u.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      -- 'NO RECORD FOUND IN UCAT_Y1 FOR SNWG UDC CODE'
      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 6';
        SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error04_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_Error04_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = 0,
         @An_ErrorLine_NUMB        = 0,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

        RETURN;
       END
     END

     SET @Ls_Sql_TEXT = 'SELECT CMEM CASE - SNWG';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'');
     SELECT @Ln_InstateRespondCases_QNTY = COUNT(1)
       FROM CMEM_Y1 a,
            CASE_Y1 b
      WHERE a.MemberMci_IDNO = @Ln_PayorMCI_IDNO
        AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
        AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
        AND a.Case_IDNO = b.Case_IDNO
        AND b.RespondInit_CODE  IN (@Lc_RespondInitN_CODE, @Lc_RespondInitY_CODE, @Lc_RespondInitR_CODE,@Lc_RespondInitS_CODE)
        AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

     IF (@Ac_SourceReceipt_CODE = @Lc_ReceiptSrcEmployerwageEW_CODE AND @Ln_InstateRespondCases_QNTY = 0)
      BEGIN
       SET @Ac_ReasonHold_CODE = @Lc_HoldRsnSnwg_CODE;
       SET @An_Held_AMNT = @An_Receipt_AMNT;
       SET @An_Identified_AMNT = 0;

       SELECT @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ld_ToDay_DATE);

       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
       RETURN;
      END
    END

  /* 
   If the receipt source is 'EW - Employer Wage', 'WC - Worker's Compensation', 'DB - Disability Insurance', 
  	'UC - Unemployment Compensation (UIB)', the system checks:
  
  	 If the payor of the case has a QDRO Indicator on any one of the open cases, the wage receipt will be placed on a SNQR â€“ System Hold Potential QDRO hold. 
  	 
  	 The QDRO administrator will research these payments to verify if these are EW/ WC/ DB/ UC receipts or QR payments and change the receipt source 
  	 to QR (if required) and then release the receipt.
  
   If the receipt source is 'QR-QDRO', the batch process checks if the at least one of the Payor's cases has an active QDRO indicator. If no QDRO indicator 
  	exists for any of the Payor's cases then the QR receipt is put on 'SNQR - System Hold Potential QDRO' hold.
  */
   -- SNQR - SYSTEM HOLD POTENTIAL QDRO/EDRO
   IF @Ac_SourceReceipt_CODE IN (@Lc_ReceiptSrcEmployerwageEW_CODE, @Lc_ReceiptSrcWorkersCompensationWC_CODE, @Lc_ReceiptSrcDisabilityinsurDB_CODE, @Lc_ReceiptSrcUibUC_CODE)--, @Lc_ReceiptSrcQdroQR_CODE)
    BEGIN
     SET @Ln_OfDaysHold_NUMB = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNQR';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = SNQR';

     BEGIN
      SELECT @Ln_OfDaysHold_NUMB = u.NumDaysHold_QNTY
        FROM UCAT_Y1 u
       WHERE u.Udc_CODE = @Lc_HoldRsnSnqr_CODE
         AND u.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      -- 'NO RECORD FOUND IN UCAT_Y1 FOR SNQR UDC CODE'
      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 7';
        SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error04_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_Error04_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = 0,
         @An_ErrorLine_NUMB        = 0,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

        RETURN;
       END
     END

     SET @Ls_Sql_TEXT = 'SELECT CMEM SORD - SNQR';
	 SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Qdro_INDC = ' + ISNULL(@Lc_Yes_INDC,'');
     SELECT @Ln_QdroActiveStatus_QNTY = COUNT(1)
       FROM CMEM_Y1 m,
            SORD_Y1 s
      WHERE m.MemberMci_IDNO = @Ln_PayorMCI_IDNO
        AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
        AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
        AND m.Case_IDNO = s.Case_IDNO
        AND s.EndValidity_DATE = @Ld_High_DATE
        AND @Ad_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
        AND s.Qdro_INDC = @Lc_Yes_INDC;

     IF (@Ac_SourceReceipt_CODE IN (@Lc_ReceiptSrcEmployerwageEW_CODE, @Lc_ReceiptSrcUibUC_CODE, @Lc_ReceiptSrcDisabilityinsurDB_CODE, @Lc_ReceiptSrcWorkersCompensationWC_CODE)
         AND @Ln_QdroActiveStatus_QNTY > 0)
      BEGIN
       SET @Ac_ReasonHold_CODE = @Lc_HoldRsnSnqr_CODE;
       SET @An_Held_AMNT = @An_Receipt_AMNT;
       SET @An_Identified_AMNT = 0;

       SELECT @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ld_ToDay_DATE);

       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
       RETURN;
      END
    END

  /*
  If the receipt source is â€˜F4 - Intergovernmental IVD-Regularâ€™ or â€˜FF- Intergovernmental IVD-Fee (Cost Recovery)â€™, the batch process puts the receipt 
  on SNFP â€“ Intergovernmental Returned Payment hold if there are no â€˜Initiatingâ€™ intergovernmental cases for the payor in the system. 
  */
   -- SNFP - INTERGOVERNMENTAL PAYMENT; NO INITIATING CASE
   IF @Ac_SourceReceipt_CODE IN (@Lc_ReceiptSrcInterstatIvdRegF4_CODE, @Lc_ReceiptSrcInterstatIvdFeeFF_CODE)
    BEGIN
     SET @Ln_OfDaysHold_NUMB = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 - SNFP';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_HoldRsnSnfp_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     BEGIN
      SELECT @Ln_OfDaysHold_NUMB = u.NumDaysHold_QNTY
        FROM UCAT_Y1 u
       WHERE u.Udc_CODE = @Lc_HoldRsnSnfp_CODE
         AND u.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      --'NO RECORD FOUND IN UCAT_Y1 FOR SNFP UDC CODE'
      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 8';
        SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error07_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_Error07_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = 0,
         @An_ErrorLine_NUMB        = 0,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        RETURN;
       END
     END

     SET @Ls_Sql_TEXT = 'SELECT CMEM CASE - SNFP';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'');
     SELECT @Ln_InitiatingCases_QNTY = COUNT(1)
       FROM CMEM_Y1 a,
            CASE_Y1 b
      WHERE a.MemberMci_IDNO = @Ln_PayorMCI_IDNO
        AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
        AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
        AND a.Case_IDNO = b.Case_IDNO
        AND b.RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE)
        AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

     IF @Ln_InitiatingCases_QNTY = 0
      BEGIN
       SET @Ac_ReasonHold_CODE = @Lc_HoldRsnSnfp_CODE;
       SET @An_Held_AMNT = @An_Receipt_AMNT;
       SET @An_Identified_AMNT = 0;

       SELECT @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ld_ToDay_DATE);

       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

       RETURN;
      END
    END

  /*
    For all receipt sources with a remit type of CHK (Personal Check), if the NSF indicator exists on the Hold Instructions 
    (HLDI) screen/BCHK_Y1 table then put the receipt on a 14 day â€˜SHRU - History of NSF Return Checksâ€™ hold 
   */
   -- SHRU - HISTORY OF NSF RETURN CHECKS
   IF @Ac_TypeRemittance_CODE = @Lc_RemitTypeCheck_CODE
    BEGIN
     SET @Ln_OfDaysHold_NUMB = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 4';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_HoldRsnShru_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     BEGIN
      SELECT @Ln_OfDaysHold_NUMB = u.NumDaysHold_QNTY
        FROM UCAT_Y1 u
       WHERE u.Udc_CODE = @Lc_HoldRsnShru_CODE
         AND u.EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      -- 'NO RECORD FOUND IN UCAT_Y1 FOR SHRU UDC CODE'
      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 9';
        SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error05_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_Error05_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = 0,
         @An_ErrorLine_NUMB        = 0,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        RETURN;
       END
     END

     SET @Ls_Sql_TEXT = 'SELECT BCHK_Y1 ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @Ln_PayorMCI_IDNO AS VARCHAR ),'')+ ', BadCheck_INDC = ' + ISNULL(@Lc_Yes_INDC,'');
     SELECT @Ac_ReasonHold_CODE = @Lc_HoldRsnShru_CODE,
            @An_Held_AMNT = @An_Receipt_AMNT,
            @An_Identified_AMNT = 0,
            @Ad_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ld_ToDay_DATE),
            @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
       FROM BCHK_Y1 a
      WHERE a.MemberMci_IDNO = @Ln_PayorMCI_IDNO
        AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB)
                                       FROM BCHK_Y1 b
                                      WHERE b.MemberMci_IDNO = a.MemberMci_IDNO)
        AND a.BadCheck_INDC = @Lc_Yes_INDC;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @An_Held_AMNT = 0;
       SET @An_Identified_AMNT = @An_Receipt_AMNT;
       SET @Ad_Release_DATE = @Ld_ToDay_DATE;
       SET @Ac_ReasonHold_CODE = @Lc_Space_TEXT;
      END
     ELSE
      BEGIN
       RETURN;
      END
    END

   /*
   The system will then check the Manual Hold Instructions (HLDI) screen/ DISH_Y1 (DISH) table to determine
   if a distribution hold exists for the Payor
   */
   BEGIN
    SET @Ls_Sql_TEXT = 'SELECT DISH';
    SET @Ls_Sqldata_TEXT = 'CasePayorMCI_IDNO = ' + ISNULL (CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '') + ', TypePosting_CODE = ' + ISNULL (@Lc_TypePosting_CODE, '') + ', SourceReceipt_CODE = ' + ISNULL (@Ac_SourceReceipt_CODE, '');

    SELECT TOP 1 @Ad_Release_DATE = e.Expiration_DATE,
                 @Ac_ReasonHold_CODE = e.Udc_CODE,
                 @An_Held_AMNT = @An_Receipt_AMNT,
                 @An_Identified_AMNT = 0
      FROM (SELECT Expiration_DATE,
                   ReasonHold_CODE AS Udc_CODE,
                   CASE SourceHold_CODE
                    WHEN @Lc_ReceiptSrcDh_CODE
                     THEN 1
                    ELSE 2
                   END AS priority
              FROM DISH_Y1 a
             WHERE CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
               AND TypeHold_CODE = @Lc_TypePosting_CODE
               AND (SourceHold_CODE = @Lc_ReceiptSrcDh_CODE
                     OR SourceHold_CODE = @Ac_SourceReceipt_CODE)
               AND Effective_DATE <= @Ld_ToDay_DATE
               AND Expiration_DATE > @Ld_ToDay_DATE
               AND EndValidity_DATE = @Ld_High_DATE
            UNION ALL
            SELECT d.Expiration_DATE,
                   d.ReasonHold_CODE AS Udc_CODE,
                   CASE d.SourceHold_CODE
                    WHEN @Lc_ReceiptSrcDh_CODE
                     THEN 1
                    ELSE 2
                   END AS priority
              FROM DISH_Y1 d,
                   CMEM_Y1 c
             WHERE c.Case_IDNO = @An_CasePayorMCI_IDNO
               AND @Lc_TypePosting_CODE = @Lc_TypePostingCase_CODE
               AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
               AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
               AND d.CasePayorMCI_IDNO = c.MemberMci_IDNO
               AND d.TypeHold_CODE = @Lc_TypePostingPayor_CODE
               AND (d.SourceHold_CODE = @Lc_ReceiptSrcDh_CODE
                     OR d.SourceHold_CODE = @Ac_SourceReceipt_CODE)
               AND d.Effective_DATE <= @Ld_ToDay_DATE
               AND d.Expiration_DATE > @Ld_ToDay_DATE
               AND d.EndValidity_DATE = @Ld_High_DATE) AS e
     ORDER BY Expiration_DATE,
              priority DESC;
   END

   IF @Ad_Release_DATE <= @Ld_ToDay_DATE
    BEGIN
     SET @Ad_Release_DATE = @Ld_ToDay_DATE;
     SET @An_Held_AMNT = 0;
     SET @An_Identified_AMNT = @An_Receipt_AMNT;
     SET @Ac_ReasonHold_CODE = @Lc_Space_TEXT;
    END

   -- 'BOTH HELD AND IDENTIFIED AMOUNTS RETURNED ZERO VALUE '
   IF @An_Held_AMNT = 0
      AND @An_Identified_AMNT = 0
    BEGIN
     SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 10';
     SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', ErrorMessage_TEXT = ' + ISNULL(@Ls_Error06_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_Error06_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = 0,
      @An_ErrorLine_NUMB        = 0,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	IF CURSOR_STATUS('Local', 'CaseMember_CUR') IN (0,1)
	BEGIN
		CLOSE CaseMember_CUR;
		DEALLOCATE CaseMember_CUR;
	END   
	
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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
