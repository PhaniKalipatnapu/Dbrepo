/****** Object:  StoredProcedure [dbo].[BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_VOLUNTARY_RECEIPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_VOLUNTARY_RECEIPT   

Programmer Name 	: IMP Team

Description			: This process retrieves all held Voluntary receipts from the RCTH_Y1 table
                      and releases them by Creating the SORD/OBLE Record(s).

Frequency			: 'DAILY'

Developed On		: 03/05/2012

Called BY			: BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_RECEIPT

Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_VOLUNTARY_RECEIPT]
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT,
 @Ac_Job_ID                CHAR(7) OUTPUT,
 @Ad_Run_DATE              DATE OUTPUT,
 @Ad_Process_DATE          DATE OUTPUT,
 @Ad_Create_DATE           DATETIME2 OUTPUT,
 @As_Process_NAME          VARCHAR(100) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Li_ObligationCreation1010_NUMB	   INT	    = 1010,
		   @Li_ReleaseAHeldReceipt1430_NUMB	   INT      = 1430,
		   @Lc_TypePostingPayor_CODE           CHAR (1) = 'P',
           @Lc_TypePostingCase_CODE            CHAR (1) = 'C',
           @Lc_CaseRelationshipNcp_CODE        CHAR (1) = 'A',
           @Lc_CaseRelationshipPutFather_CODE  CHAR (1) = 'P',
           @Lc_CaseMemberStatusActive_CODE     CHAR (1) = 'A',
           @Lc_OrderTypeVoluntary_CODE         CHAR (1) = 'V',
           @Lc_StatusReceiptHeld_CODE          CHAR (1) = 'H',
           @Lc_Yes_INDC                        CHAR (1) = 'Y',
           @Lc_No_INDC                         CHAR (1) = 'N',
           @Lc_StatusFailed_CODE               CHAR (1) = 'F',
           @Lc_Space_TEXT                      CHAR (1) = ' ',
           @Lc_CaseRelationshipDp_CODE         CHAR (1) = 'D',
           @Lc_Weekly_TEXT                     CHAR (1) = 'W',
           @Lc_CaseRelationshipCp_CODE         CHAR (1) = 'C',
           @Lc_StatusReceiptIdentified_CODE    CHAR (1) = 'I',
           @Lc_StatusSuccess_CODE              CHAR (1) = 'S',
           @Lc_CreateObleRecord_CODE           CHAR (1) = 'O',
           @Lc_CreateSordRecord_CODE           CHAR (1) = 'S',
           @Lc_SourceReceiptVoluntary_CODE     CHAR (2) = 'VN',
           @Lc_DebtTypeChildSupp_CODE          CHAR (2) = 'CS',
           @Lc_DebtTypeSpousalSupp_CODE        CHAR (2) = 'SS',
           @Lc_HoldReasonStatusSnno_CODE       CHAR (4) = 'SNNO',
           @Lc_DeFips_CODE                     CHAR (7) = '1000000',
           @Lc_BatchRunUser_ID				   CHAR (30) = 'BATCH',
           @Ls_Procedure_NAME                  VARCHAR (100) = 'BATCH_FIN_RELEASE_RECEIPT$SP_SNFX_HOLD_ALERT',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Dp_QNTY							NUMERIC,
           @Ln_QNTY								NUMERIC,
           @Ln_Error_NUMB						NUMERIC (11),
           @Ln_ErrorLine_NUMB					NUMERIC (11),
           @Ln_Rowcount_QNTY					NUMERIC (11),
           @Ln_EventGlobalSeq_NUMB				NUMERIC (19),
           @Ln_TransactionEventSeq_NUMB         NUMERIC(19) = 0,
           @Li_FetchStatus_QNTY					SMALLINT,
           @Lc_DebtType_CODE					CHAR (2),
           @Lc_Msg_CODE							CHAR (3),
           @Lc_File_ID							CHAR (15),
           @Ls_Sql_TEXT							VARCHAR (4000),
           @Ls_Sqldata_TEXT						VARCHAR (4000),
           @Ls_ErrorMessage_TEXT				VARCHAR (4000),
           @Ld_RunTemp_DATE						DATE;
   DECLARE @Ld_VoluntaryCur_Batch_DATE               DATE,
           @Lc_VoluntaryCur_SourceBatch_CODE         CHAR(3),
           @Ln_VoluntaryCur_Batch_NUMB               NUMERIC(4, 0),
           @Ln_VoluntaryCur_SeqReceipt_NUMB          NUMERIC(6),
           @Lc_VoluntaryCur_SourceReceipt_CODE       CHAR(2),
           @Lc_VoluntaryCur_TypeRemittance_CODE      CHAR(3),
           @Lc_VoluntaryCur_TypePosting_CODE         CHAR(1),
           @Ln_VoluntaryCur_Case_IDNO                NUMERIC(6),
           @Ln_VoluntaryCur_PayorMCI_IDNO            NUMERIC(10),
           @Ln_VoluntaryCur_Receipt_AMNT             NUMERIC(11, 2),
           @Ln_VoluntaryCur_ToDistribute_AMNT        NUMERIC(11, 2),
           @Ln_VoluntaryCur_Fee_AMNT                 NUMERIC(11, 2),
           @Lc_VoluntaryCur_Employer_IDNO            CHAR(9),
           @Lc_VoluntaryCur_Fips_IDNO                CHAR(7),
           @Ld_VoluntaryCur_Check_DATE               DATE,
           @Lc_VoluntaryCur_CheckNo_TEXT             CHAR(18),
           @Ld_VoluntaryCur_Receipt_DATE             DATE,
           @Lc_VoluntaryCur_Tanf_INDC                CHAR(1),
           @Lc_VoluntaryCur_TaxJoint_INDC            CHAR(1),
           @Lc_VoluntaryCur_TaxJoint_NAME            CHAR(35),
           @Lc_VoluntaryCur_StatusReceipt_CODE       CHAR(1),
           @Lc_VoluntaryCur_ReasonStatus_CODE        CHAR(4),
           @Lc_VoluntaryCur_BackOut_INDC             CHAR(1),
           @Lc_VoluntaryCur_ReasonBackOut_CODE       CHAR(2),
           @Ld_VoluntaryCur_Release_DATE             DATE,
           @Ld_VoluntaryCur_Refund_DATE              DATE,
           @Ln_VoluntaryCur_ReferenceIrs_IDNO        NUMERIC(6),
           @Lc_VoluntaryCur_RefundRecipient_ID       CHAR(9),
           @Lc_VoluntaryCur_RefundRecipient_CODE     CHAR(1),
           @Ln_VoluntaryCur_EventGlobalBeginSeq_NUMB NUMERIC(9),
           @Lc_VoluntaryCur_Processed_INDC           CHAR(4);
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ac_Job_ID = ISNULL(@Ac_Job_ID, 'DEB0550');
   SET @Ad_Run_DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   SET @Ad_Create_DATE = ISNULL(@Ad_Create_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_FIN_RELEASE_RECEIPT');

   DECLARE Voluntary_CUR INSENSITIVE CURSOR FOR
    SELECT f.Batch_DATE,
           f.SourceBatch_CODE,
           f.Batch_NUMB,
           f.SeqReceipt_NUMB,
           f.SourceReceipt_CODE,
           f.TypeRemittance_CODE,
           f.TypePosting_CODE,
           f.Case_IDNO,
           f.PayorMCI_IDNO,
           f.Receipt_AMNT,
           f.ToDistribute_AMNT,
           f.Fee_AMNT,
           f.Employer_IDNO,
           f.Fips_CODE,
           f.Check_DATE,
           f.CheckNo_Text,
           f.Receipt_DATE,
           f.Tanf_CODE,
           f.TaxJoint_CODE,
           f.TaxJoint_NAME,
           f.StatusReceipt_CODE,
           f.ReasonStatus_CODE,
           f.BackOut_INDC,
           f.ReasonBackOut_CODE,
           f.Release_DATE,
           f.Refund_DATE,
           f.ReferenceIrs_IDNO,
           f.RefundRecipient_ID,
           f.RefundRecipient_CODE,
           f.EventGlobalBeginSeq_NUMB,
           f.ind_processed
      FROM (SELECT a.Batch_DATE,
                   a.SourceBatch_CODE,
                   a.Batch_NUMB,
                   a.SeqReceipt_NUMB,
                   a.SourceReceipt_CODE,
                   a.TypeRemittance_CODE,
                   a.TypePosting_CODE,
                   a.Case_IDNO,
                   a.PayorMCI_IDNO,
                   a.Receipt_AMNT,
                   a.ToDistribute_AMNT,
                   a.Fee_AMNT,
                   a.Employer_IDNO,
                   a.Fips_CODE,
                   a.Check_DATE,
                   a.CheckNo_Text,
                   a.Receipt_DATE,
                   a.Tanf_CODE,
                   a.TaxJoint_CODE,
                   a.TaxJoint_NAME,
                   a.StatusReceipt_CODE,
                   a.ReasonStatus_CODE,
                   a.BackOut_INDC,
                   a.ReasonBackOut_CODE,
                   a.Release_DATE,
                   a.Refund_DATE,
                   a.ReferenceIrs_IDNO,
                   a.RefundRecipient_ID,
                   a.RefundRecipient_CODE,
                   a.EventGlobalBeginSeq_NUMB,
                   CASE
                    WHEN (EXISTS (SELECT 1 
                                    FROM SORD_Y1 s,
                                         CMEM_Y1 m
                                   WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                           AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                           OR (m.Case_IDNO = a.Case_IDNO
                                               AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                     AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                     AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                     AND m.Case_IDNO = s.Case_IDNO
                                     AND s.EndValidity_DATE = @Ld_High_DATE
                                     AND s.TypeOrder_CODE = @Lc_OrderTypeVoluntary_CODE)
                          AND NOT EXISTS (SELECT 1 
                                            FROM OBLE_Y1 o,
                                                 CMEM_Y1 m
                                           WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                   AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                                   OR (m.Case_IDNO = a.Case_IDNO
                                                       AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                             AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                             AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                             AND m.Case_IDNO = o.Case_IDNO
                                             AND o.EndValidity_DATE = @Ld_High_DATE))
                     THEN @Lc_CreateObleRecord_CODE
                    WHEN (NOT EXISTS (SELECT 1 
                                        FROM SORD_Y1 s,
                                             CMEM_Y1 m
                                       WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                               AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                               OR (m.Case_IDNO = a.Case_IDNO
                                                   AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                         AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                         AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                         AND m.Case_IDNO = s.Case_IDNO
                                         AND s.EndValidity_DATE = @Ld_High_DATE)
                          AND NOT EXISTS (SELECT 1 
                                            FROM OBLE_Y1 o,
                                                 CMEM_Y1 m
                                           WHERE ((m.MemberMci_IDNO = a.PayorMCI_IDNO
                                                   AND a.TypePosting_CODE = @Lc_TypePostingPayor_CODE)
                                                   OR (m.Case_IDNO = a.Case_IDNO
                                                       AND a.TypePosting_CODE = @Lc_TypePostingCase_CODE))
                                             AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                             AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                             AND m.Case_IDNO = o.Case_IDNO
                                             AND o.EndValidity_DATE = @Ld_High_DATE))
                     THEN @Lc_CreateSordRecord_CODE
                   END AS ind_processed
              FROM RCTH_Y1 a
             WHERE a.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
               AND a.SourceReceipt_CODE = @Lc_SourceReceiptVoluntary_CODE
               AND a.ReasonStatus_CODE = @Lc_HoldReasonStatusSnno_CODE
               AND a.EndValidity_DATE = @Ld_High_DATE
               AND a.Distribute_DATE = @Ld_Low_DATE
               AND EXISTS (SELECT 1 
                             FROM UCAT_Y1 u
                            WHERE a.ReasonStatus_CODE = u.Udc_CODE
                              AND u.AutomaticRelease_INDC = @Lc_Yes_INDC
                              AND u.EndValidity_DATE = @Ld_High_DATE)) f
     WHERE f.ind_processed IN (@Lc_CreateSordRecord_CODE, @Lc_CreateObleRecord_CODE);

   SET @Ld_RunTemp_DATE = CONVERT(VARCHAR(10),@Ad_Run_DATE,101);
   SET @Ls_Sql_TEXT = 'Voluntary Cursor BATCH_COMMON$SP_GENERATE_SEQ ';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReleaseAHeldReceipt1430_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_RunTemp_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_ID,'');
   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_ReleaseAHeldReceipt1430_NUMB,
    @Ac_Process_ID              = @Ac_Job_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_RunTemp_DATE,
    @Ac_Note_INDC               = @Lc_No_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_ID,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
	
	SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
      SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_ID, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_RunTemp_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST('0' AS VARCHAR), '');

      EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_ID,
       @Ac_Process_ID               = @Ac_Job_ID,
       @Ad_EffectiveEvent_DATE      = @Ld_RunTemp_DATE,
       @Ac_Note_INDC                = @Lc_No_INDC,
       @An_EventFunctionalSeq_NUMB  = 0,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @As_DescriptionError_TEXT;

        RAISERROR (50001,16,1);
       END;
	
   SET @Ls_Sql_TEXT = 'OPEN Voluntary_CUR';
   SET @Ls_Sqldata_TEXT = '';
   OPEN Voluntary_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Voluntary_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM Voluntary_CUR INTO @Ld_VoluntaryCur_Batch_DATE, @Lc_VoluntaryCur_SourceBatch_CODE, @Ln_VoluntaryCur_Batch_NUMB, @Ln_VoluntaryCur_SeqReceipt_NUMB, @Lc_VoluntaryCur_SourceReceipt_CODE, @Lc_VoluntaryCur_TypeRemittance_CODE, @Lc_VoluntaryCur_TypePosting_CODE, @Ln_VoluntaryCur_Case_IDNO, @Ln_VoluntaryCur_PayorMCI_IDNO, @Ln_VoluntaryCur_Receipt_AMNT, @Ln_VoluntaryCur_ToDistribute_AMNT, @Ln_VoluntaryCur_Fee_AMNT, @Lc_VoluntaryCur_Employer_IDNO, @Lc_VoluntaryCur_Fips_IDNO, @Ld_VoluntaryCur_Check_DATE, @Lc_VoluntaryCur_CheckNo_TEXT, @Ld_VoluntaryCur_Receipt_DATE, @Lc_VoluntaryCur_Tanf_INDC, @Lc_VoluntaryCur_TaxJoint_INDC, @Lc_VoluntaryCur_TaxJoint_NAME, @Lc_VoluntaryCur_StatusReceipt_CODE, @Lc_VoluntaryCur_ReasonStatus_CODE, @Lc_VoluntaryCur_BackOut_INDC, @Lc_VoluntaryCur_ReasonBackOut_CODE, @Ld_VoluntaryCur_Release_DATE, @Ld_VoluntaryCur_Refund_DATE, @Ln_VoluntaryCur_ReferenceIrs_IDNO, @Lc_VoluntaryCur_RefundRecipient_ID, @Lc_VoluntaryCur_RefundRecipient_CODE, @Ln_VoluntaryCur_EventGlobalBeginSeq_NUMB, @Lc_VoluntaryCur_Processed_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   BEGIN
    -- Voluntary cursor started
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
      SET @Ls_Sql_TEXT = 'Voluntary_CUR Data';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_VoluntaryCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_VoluntaryCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_VoluntaryCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_VoluntaryCur_SeqReceipt_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_VoluntaryCur_Case_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_VoluntaryCur_PayorMCI_IDNO AS VARCHAR), '') + ', Processed_INDC = ' + ISNULL(@Lc_VoluntaryCur_Processed_INDC, '');
	  /*If obligation record does not exist for the case then create a Support Order record in SORD_Y1 table with order type “Voluntary” and 
	  	create an Obligation record(s) in OBLE_Y1 table. Obligation record will be non-charging with weekly frequency.*/
	   IF @Lc_VoluntaryCur_Processed_INDC = @Lc_CreateSordRecord_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'SELECT_SORD_Y1';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_VoluntaryCur_Case_IDNO AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);
        SELECT @Ln_QNTY = COUNT(1)
          FROM SORD_Y1 s
         WHERE s.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
           AND s.EndValidity_DATE = @Ld_High_DATE;
        
        SET @Ls_Sql_TEXT = 'SELECT_CASE_Y1';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_VoluntaryCur_Case_IDNO AS VARCHAR);  
         
        SELECT @Lc_File_ID = c.File_ID
          FROM CASE_Y1 c
         WHERE c.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO;
         
         IF LTRIM(RTRIM(@Lc_File_ID)) = ''
         BEGIN
			SELECT @Lc_File_ID = f.File_ID 
			FROM FDEM_Y1 f
			WHERE f.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
			AND f.Respondent_IDNO = @Ln_VoluntaryCur_PayorMCI_IDNO
			AND f.EndValidity_DATE = @Ld_High_DATE
			AND f.TransactionEventSeq_NUMB = (SELECT MAX(p.TransactionEventSeq_NUMB)
                                           FROM FDEM_Y1 p
                                          WHERE f.Case_IDNO = p.Case_IDNO
                                            AND f.Respondent_IDNO = p.Respondent_IDNO
                                            AND p.EndValidity_DATE = @Ld_High_DATE);
			SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
			
			IF @Ln_Rowcount_QNTY <> 0
			BEGIN

			SET @Ls_Sql_TEXT = 'BATCH_FIN_RELEASE_RECEIPT$SP_RELEASE_VOLUNTARY_RECEIPT -CASE_Y1';
			SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_VoluntaryCur_Case_IDNO AS VARCHAR(6)), '');

				UPDATE CASE_Y1
					  SET File_ID = ISNULL(@Lc_File_ID,File_ID),
						  TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
						  WorkerUpdate_ID = @Lc_BatchRunUser_ID,
						  BeginValidity_DATE = @Ad_Run_DATE,
						  Update_DTTM = @Ad_Create_DATE
				   OUTPUT deleted.Case_IDNO,
						  deleted.StatusCase_CODE,
						  deleted.TypeCase_CODE,
						  deleted.RsnStatusCase_CODE,
						  deleted.RespondInit_CODE,
						  deleted.SourceRfrl_CODE,
						  deleted.Opened_DATE,
						  deleted.Marriage_DATE,
						  deleted.Divorced_DATE,
						  deleted.StatusCurrent_DATE,
						  deleted.AprvIvd_DATE,
						  deleted.County_IDNO,
						  deleted.Office_IDNO,
						  deleted.AssignedFips_CODE,
						  deleted.GoodCause_CODE,
						  deleted.GoodCause_DATE,
						  deleted.Restricted_INDC,
						  deleted.MedicalOnly_INDC,
						  deleted.Jurisdiction_INDC,
						  deleted.IvdApplicant_CODE,
						  deleted.Application_IDNO,
						  deleted.AppSent_DATE,
						  deleted.AppReq_DATE,
						  deleted.AppRetd_DATE,
						  deleted.CpRelationshipToNcp_CODE,
						  deleted.Worker_ID,
						  deleted.AppSigned_DATE,
						  deleted.ClientLitigantRole_CODE,
						  deleted.DescriptionComments_TEXT,
						  deleted.NonCoop_CODE,
						  deleted.NonCoop_DATE,
						  deleted.BeginValidity_DATE,
						  @Ad_Run_DATE AS EndValidity_DATE,
						  @Lc_BatchRunUser_ID AS WorkerUpdate_ID,
						  deleted.TransactionEventSeq_NUMB,
						  deleted.Update_DTTM,
						  deleted.Referral_DATE,
						  deleted.CaseCategory_CODE,
						  deleted.File_ID,
						  deleted.ApplicationFee_CODE,
						  deleted.FeePaid_DATE,
						  deleted.ServiceRequested_CODE,
						  deleted.StatusEnforce_CODE,
						  deleted.FeeCheckNo_TEXT,
						  deleted.ReasonFeeWaived_CODE,
						  deleted.Intercept_CODE
				   INTO HCASE_Y1
					WHERE Case_IDNO = @Ln_VoluntaryCur_Case_IDNO;
				END	
         END
         
        IF @Ln_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT_SORD_Y1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_VoluntaryCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL('1','')+ ', Order_IDNO = ' + ISNULL('0','')+ ', File_ID = ' + ISNULL(@Lc_File_ID,'')+ ', OrderEnt_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', OrderIssued_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', OrderEffective_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', OrderEnd_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', StatusOrder_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', StatusOrder_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', InsOrdered_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', MedicalOnly_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Iiwo_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', NoIwReason_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', IwoInitiatedBy_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', GuidelinesFollowed_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', DeviationReason_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', DescriptionDeviationOthers_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', OrderOutOfState_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CejStatus_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CejFips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', IssuingOrderFips_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Qdro_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', LastIrscReferred_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', LastIrscUpdated_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', LastIrscReferred_AMNT = ' + ISNULL('0','')+ ', UnreimMedical_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CpMedical_PCT = ' + ISNULL('0','')+ ', NcpMedical_PCT = ' + ISNULL('0','')+ ', ParentingTime_PCT = ' + ISNULL('0','')+ ', NoParentingDays_QNTY = ' + ISNULL('0','')+ ', DescriptionParentingNotes_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', PetitionerAppeared_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', RespondentAppeared_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', PetitionerAttorneyAppeared_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', RespondentAttorneyAppeared_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', OthersAppeared_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', PetitionerReceived_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', RespondentReceived_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', PetitionerAttorneyReceived_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', RespondentAttorneyReceived_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', OthersReceived_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', PetitionerMailed_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', RespondentMailed_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', PetitionerAttorneyMailed_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', RespondentAttorneyMailed_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', OthersMailed_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', PetitionerMailed_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', RespondentMailed_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', PetitionerAttorneyMailed_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', RespondentAttorneyMailed_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', OthersMailed_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', CoverageMedical_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CoverageDrug_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CoverageMental_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CoverageDental_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CoverageVision_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', CoverageOthers_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', DescriptionCoverageOthers_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_ID,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', StatusControl_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', StateControl_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', OrderControl_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', DirectPay_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', LastNoticeSent_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'') + ', NextReview_DATE = ' + ISNULL(CAST( DATEADD(m, 36, @Ad_Run_DATE) AS VARCHAR ),'') + ', LastReview_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', ReviewRequested_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', SourceOrdered_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', TypeOrder_CODE = ' + ISNULL(@Lc_OrderTypeVoluntary_CODE,'');
          INSERT SORD_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  Order_IDNO,
                  File_ID,
                  OrderEnt_DATE,
                  OrderIssued_DATE,
                  OrderEffective_DATE,
                  OrderEnd_DATE,
                  ReasonStatus_CODE,
                  StatusOrder_CODE,
                  StatusOrder_DATE,
                  InsOrdered_CODE,
                  MedicalOnly_INDC,
                  Iiwo_CODE,
                  NoIwReason_CODE,
                  IwoInitiatedBy_CODE,
                  GuidelinesFollowed_INDC,
                  DeviationReason_CODE,
                  DescriptionDeviationOthers_TEXT,
                  OrderOutOfState_ID,
                  CejStatus_CODE,
                  CejFips_CODE,
                  IssuingOrderFips_CODE,
                  Qdro_INDC,
                  LastIrscReferred_DATE,
                  LastIrscUpdated_DATE,
                  LastIrscReferred_AMNT,
                  UnreimMedical_INDC,
                  CpMedical_PCT,
                  NcpMedical_PCT,
                  ParentingTime_PCT,
                  NoParentingDays_QNTY,
                  DescriptionParentingNotes_TEXT,
                  PetitionerAppeared_INDC,
                  RespondentAppeared_INDC,
                  PetitionerAttorneyAppeared_INDC,
                  RespondentAttorneyAppeared_INDC,
                  OthersAppeared_INDC,
                  PetitionerReceived_INDC,
                  RespondentReceived_INDC,
                  PetitionerAttorneyReceived_INDC,
                  RespondentAttorneyReceived_INDC,
                  OthersReceived_INDC,
                  PetitionerMailed_INDC,
                  RespondentMailed_INDC,
                  PetitionerAttorneyMailed_INDC,
                  RespondentAttorneyMailed_INDC,
                  OthersMailed_INDC,
                  PetitionerMailed_DATE,
                  RespondentMailed_DATE,
                  PetitionerAttorneyMailed_DATE,
                  RespondentAttorneyMailed_DATE,
                  OthersMailed_DATE,
                  CoverageMedical_CODE,
                  CoverageDrug_CODE,
                  CoverageMental_CODE,
                  CoverageDental_CODE,
                  CoverageVision_CODE,
                  CoverageOthers_CODE,
                  DescriptionCoverageOthers_TEXT,
                  WorkerUpdate_ID,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  StatusControl_CODE,
                  StateControl_CODE,
                  OrderControl_ID,
                  DirectPay_INDC,
                  LastNoticeSent_DATE,
                  NextReview_DATE,
                  LastReview_DATE,
                  ReviewRequested_DATE,
                  SourceOrdered_CODE,
                  TypeOrder_CODE)
          VALUES ( @Ln_VoluntaryCur_Case_IDNO,      --Case_IDNO                      
                   1,                               --OrderSeq_NUMB                  
                   0,							    --Order_IDNO                     
                   @Lc_File_ID,                     --File_ID                        
                   @Ad_Run_DATE,                    --OrderEnt_DATE                  
                   @Ad_Run_DATE,                    --OrderIssued_DATE               
                   @Ad_Run_DATE,                    --OrderEffective_DATE            
                   @Ld_High_DATE,                   --OrderEnd_DATE                  
                   @Lc_Space_TEXT,                  --ReasonStatus_CODE              
                   @Lc_Space_TEXT,                  --StatusOrder_CODE               
                   @Ld_Low_DATE,                    --StatusOrder_DATE               
                   @Lc_Space_TEXT,                  --InsOrdered_CODE                
                   @Lc_Space_TEXT,                  --MedicalOnly_INDC               
                   @Lc_Space_TEXT,                  --Iiwo_CODE                      
                   @Lc_Space_TEXT,                  --NoIwReason_CODE                
                   @Lc_Space_TEXT,                  --IwoInitiatedBy_CODE            
                   @Lc_No_INDC,                     --GuidelinesFollowed_INDC        
                   @Lc_Space_TEXT,                  --DeviationReason_CODE           
                   @Lc_Space_TEXT,                  --DescriptionDeviationOthers_TEXT
                   @Lc_Space_TEXT,                  --OrderOutOfState_ID             
                   @Lc_Space_TEXT,                  --CejStatus_CODE                 
                   @Lc_Space_TEXT,                  --CejFips_CODE                   
                   @Lc_Space_TEXT,                  --IssuingOrderFips_CODE          
                   @Lc_No_INDC,                     --Qdro_INDC                      
                   @Ld_Low_DATE,                    --LastIrscReferred_DATE          
                   @Ld_Low_DATE,                    --LastIrscUpdated_DATE           
                   0,								--LastIrscReferred_AMNT          
                   @Lc_Space_TEXT,                  --UnreimMedical_INDC             
                   0,								--CpMedical_PCT                  
                   0,								--NcpMedical_PCT                 
                   0,								--ParentingTime_PCT              
                   0,								--NoParentingDays_QNTY           
                   @Lc_Space_TEXT,                  --DescriptionParentingNotes_TEXT 
                   @Lc_No_INDC,                     --PetitionerAppeared_INDC        
                   @Lc_No_INDC,                     --RespondentAppeared_INDC        
                   @Lc_No_INDC,                     --PetitionerAttorneyAppeared_INDC
                   @Lc_No_INDC,                     --RespondentAttorneyAppeared_INDC
                   @Lc_No_INDC,                     --OthersAppeared_INDC            
                   @Lc_No_INDC,                     --PetitionerReceived_INDC        
                   @Lc_No_INDC,                     --RespondentReceived_INDC        
                   @Lc_No_INDC,                     --PetitionerAttorneyReceived_INDC
                   @Lc_No_INDC,                     --RespondentAttorneyReceived_INDC
                   @Lc_No_INDC,                     --OthersReceived_INDC            
                   @Lc_No_INDC,                     --PetitionerMailed_INDC          
                   @Lc_No_INDC,                     --RespondentMailed_INDC          
                   @Lc_No_INDC,                     --PetitionerAttorneyMailed_INDC  
                   @Lc_No_INDC,                     --RespondentAttorneyMailed_INDC  
                   @Lc_No_INDC,                     --OthersMailed_INDC              
                   @Ld_Low_DATE,                    --PetitionerMailed_DATE          
                   @Ld_Low_DATE,                    --RespondentMailed_DATE          
                   @Ld_Low_DATE,                    --PetitionerAttorneyMailed_DATE  
                   @Ld_Low_DATE,                    --RespondentAttorneyMailed_DATE  
                   @Ld_Low_DATE,                    --OthersMailed_DATE              
                   @Lc_Space_TEXT,                  --CoverageMedical_CODE           
                   @Lc_Space_TEXT,                  --CoverageDrug_CODE              
                   @Lc_Space_TEXT,                  --CoverageMental_CODE            
                   @Lc_Space_TEXT,                  --CoverageDental_CODE            
                   @Lc_Space_TEXT,                  --CoverageVision_CODE            
                   @Lc_Space_TEXT,                  --CoverageOthers_CODE            
                   @Lc_Space_TEXT,                  --DescriptionCoverageOthers_TEXT 
                   @Lc_BatchRunUser_ID,             --WorkerUpdate_ID                
                   @Ad_Run_DATE,                    --BeginValidity_DATE             
                   @Ld_High_DATE,                   --EndValidity_DATE               
                   @Ln_EventGlobalSeq_NUMB,         --EventGlobalBeginSeq_NUMB       
                   0,							    --EventGlobalEndSeq_NUMB         
                   @Lc_Space_TEXT,                  --StatusControl_CODE             
                   @Lc_Space_TEXT,                  --StateControl_CODE              
                   @Lc_Space_TEXT,                  --OrderControl_ID                
                   @Lc_No_INDC,                     --DirectPay_INDC                 
                   @Ld_Low_DATE,                    --LastNoticeSent_DATE            
                   DATEADD(m, 36, @Ad_Run_DATE),    --NextReview_DATE                
                   @Ad_Run_DATE,                    --LastReview_DATE                
                   @Ld_Low_DATE,                    --ReviewRequested_DATE           
                   @Lc_Space_TEXT,                  --SourceOrdered_CODE             
                   @Lc_OrderTypeVoluntary_CODE );    --TypeOrder_CODE                 
         END
        SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1 - 1';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_VoluntaryCur_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
        SELECT @Ln_QNTY = COUNT(1)
          FROM OBLE_Y1 o
         WHERE o.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
           AND o.EndValidity_DATE = @Ld_High_DATE;

        IF @Ln_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT_CMEM_Y1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_VoluntaryCur_Case_IDNO AS VARCHAR ),'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipDp_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'');

          SELECT @Ln_Dp_QNTY = COUNT(1)
            FROM CMEM_Y1 c
           WHERE c.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
             AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
             AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

          IF @Ln_Dp_QNTY > 0
           BEGIN
            SET @Lc_DebtType_CODE = @Lc_DebtTypeChildSupp_CODE;
           END
          ELSE
           BEGIN
            SET @Lc_DebtType_CODE = @Lc_DebtTypeSpousalSupp_CODE;
            SET @Ln_Dp_QNTY = 1;
           END

          SET @Ls_Sql_TEXT = 'INSERT_OBLE_Y1 1';
		  SET @Ls_Sqldata_TEXT = 'OrderSeq_NUMB = ' + ISNULL('1','')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtType_CODE,'')+ ', Fips_CODE = ' + ISNULL(@Lc_DeFips_CODE,'')+ ', FreqPeriodic_CODE = ' + ISNULL(@Lc_Weekly_TEXT,'')+ ', Periodic_AMNT = ' + ISNULL('0','')+ ', ExpectToPay_AMNT = ' + ISNULL('0','')+ ', ExpectToPay_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ReasonChange_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', AccrualLast_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', AccrualNext_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', CheckRecipient_CODE = ' + ISNULL('1','')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
          INSERT OBLE_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  ObligationSeq_NUMB,
                  MemberMci_IDNO,
                  TypeDebt_CODE,
                  Fips_CODE,
                  FreqPeriodic_CODE,
                  Periodic_AMNT,
                  ExpectToPay_AMNT,
                  ExpectToPay_CODE,
                  ReasonChange_CODE,
                  BeginObligation_DATE,
                  EndObligation_DATE,
                  AccrualLast_DATE,
                  AccrualNext_DATE,
                  CheckRecipient_ID,
                  CheckRecipient_CODE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB,
                  BeginValidity_DATE,
                  EndValidity_DATE)
          (SELECT Case_IDNO,
                  1 AS OrderSeq_NUMB,           
                  ROW_NUMBER() OVER( ORDER BY num) AS ObligationSeq_NUMB,      
                  MemberMci_IDNO,
                  @Lc_DebtType_CODE AS TypeDebt_CODE,           
                  @Lc_DeFips_CODE AS Fips_CODE,               
                  @Lc_Weekly_TEXT AS FreqPeriodic_CODE,       
                  0 AS Periodic_AMNT,           
                  0 AS ExpectToPay_AMNT,        
                  @Lc_Space_TEXT AS ExpectToPay_CODE,        
                  @Lc_Space_TEXT AS ReasonChange_CODE,       
                  @Ad_Run_DATE AS BeginObligation_DATE,    
                  DATEADD(D, 1, @Ad_Run_DATE) AS EndObligation_DATE,      
                  @Ad_Run_DATE AS AccrualLast_DATE,        
                  @Ad_Run_DATE AS AccrualNext_DATE,        
                  (SELECT d.MemberMci_IDNO                                                               
                     FROM CMEM_Y1 d                                                            
                    WHERE d.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO                                
                      AND d.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE                   
                      AND d.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE) AS CheckRecipient_ID,             
                  1 AS CheckRecipient_CODE,     
                  @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
                  0 AS EventGlobalEndSeq_NUMB,  
                  @Ad_Run_DATE AS BeginValidity_DATE,      
                  @Ld_High_DATE AS EndValidity_DATE        
             FROM CMEM_Y1 c,
                  (SELECT 1 AS num) nm
            WHERE c.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
              AND ((c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
                    AND @Lc_DebtType_CODE = @Lc_DebtTypeChildSupp_CODE)
                    OR (c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                        AND @Lc_DebtType_CODE = @Lc_DebtTypeSpousalSupp_CODE))
              AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE);
         END
       END
      ELSE
       BEGIN
       /*
        If there is no dependent on the case then create a Spousal Support (SS) obligation record but if dependent(s) exist 
        then create a Child Support (CS) obligation record for each dependent to the amount of the received Voluntary payment. 
       */
        IF @Lc_VoluntaryCur_Processed_INDC = @Lc_CreateObleRecord_CODE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT_OBLE_Y1 - 2';
		  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_VoluntaryCur_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
          SELECT @Ln_QNTY = COUNT(1)
            FROM OBLE_Y1 o
           WHERE o.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
             AND o.EndValidity_DATE = @Ld_High_DATE;
          IF @Ln_QNTY = 0
           BEGIN
            SET @Ls_Sql_TEXT = 'SELECT_CMEM_Y1';
			SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_VoluntaryCur_Case_IDNO AS VARCHAR ),'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipDp_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'');
            SELECT @Ln_Dp_QNTY = COUNT(1)
              FROM CMEM_Y1 c
             WHERE c.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
               AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
               AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
          	-- If there is dependent on the case then create a Child Support (CS) obligation record
            IF @Ln_Dp_QNTY > 0
             BEGIN
              SET @Lc_DebtType_CODE = @Lc_DebtTypeChildSupp_CODE;
             END
            ELSE
             BEGIN
              -- If there is no dependent on the case then create a Spousal Support (SS) obligation record
              SET @Lc_DebtType_CODE = @Lc_DebtTypeSpousalSupp_CODE;
              SET @Ln_Dp_QNTY = 1;
             END
            SET @Ls_Sql_TEXT = 'INSERT_OBLE_Y1 2';
		    SET @Ls_Sqldata_TEXT = 'OrderSeq_NUMB = ' + ISNULL('1','')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtType_CODE,'')+ ', Fips_CODE = ' + ISNULL(@Lc_DeFips_CODE,'')+ ', FreqPeriodic_CODE = ' + ISNULL(@Lc_Weekly_TEXT,'')+ ', Periodic_AMNT = ' + ISNULL('0','')+ ', ExpectToPay_AMNT = ' + ISNULL('0','')+ ', ExpectToPay_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ReasonChange_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginObligation_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', AccrualLast_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', AccrualNext_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', CheckRecipient_CODE = ' + ISNULL('1','')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
            INSERT OBLE_Y1
                   (Case_IDNO,
                    OrderSeq_NUMB,
                    ObligationSeq_NUMB,
                    MemberMci_IDNO,
                    TypeDebt_CODE,
                    Fips_CODE,
                    FreqPeriodic_CODE,
                    Periodic_AMNT,
                    ExpectToPay_AMNT,
                    ExpectToPay_CODE,
                    ReasonChange_CODE,
                    BeginObligation_DATE,
                    EndObligation_DATE,
                    AccrualLast_DATE,
                    AccrualNext_DATE,
                    CheckRecipient_ID,
                    CheckRecipient_CODE,
                    EventGlobalBeginSeq_NUMB,
                    EventGlobalEndSeq_NUMB,
                    BeginValidity_DATE,
                    EndValidity_DATE)
            (SELECT d.Case_IDNO,                                                              
                    1 AS OrderSeq_NUMB,                                    
                    ROW_NUMBER() OVER( ORDER BY d.Case_IDNO) AS ObligationSeq_NUMB,
                    d.MemberMci_IDNO,     
                    @Lc_DebtType_CODE AS TypeDebt_CODE,
                    @Lc_DeFips_CODE AS Fips_CODE,      
                    @Lc_Weekly_TEXT AS FreqPeriodic_CODE,
                    0 AS Periodic_AMNT,                  
                    0 AS ExpectToPay_AMNT,               
                    @Lc_Space_TEXT AS ExpectToPay_CODE, 
                    @Lc_Space_TEXT AS ReasonChange_CODE,
                    @Ad_Run_DATE AS BeginObligation_DATE,
                    DATEADD(D, 1, @Ad_Run_DATE) AS EndObligation_DATE,
                    @Ad_Run_DATE AS AccrualLast_DATE,                                      
                    @Ld_High_DATE AS AccrualNext_DATE,                                     
                    (SELECT c.MemberMci_IDNO                                                 
                       FROM CMEM_Y1 c                                                        
                      WHERE c.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO                          
                        AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE             
                        AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE) AS CheckRecipient_ID,       
                    1 AS CheckRecipient_CODE,                             
                    @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,  
                    0 AS EventGlobalEndSeq_NUMB,                          
                    @Ad_Run_DATE AS BeginValidity_DATE,                   
                    @Ld_High_DATE AS EndValidity_DATE                     
               FROM CMEM_Y1 d
              WHERE d.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
                AND ((d.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
                      AND @Lc_DebtType_CODE = @Lc_DebtTypeChildSupp_CODE)
                      OR (d.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                          AND @Lc_DebtType_CODE = @Lc_DebtTypeSpousalSupp_CODE))
                AND d.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE);
           END
         END
       END

      SET @Ls_Sql_TEXT = 'SELECT_LSUP_Y1';
	  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_VoluntaryCur_Case_IDNO AS VARCHAR), '');	
      SELECT @Ln_QNTY = COUNT(1)
        FROM LSUP_Y1 l
       WHERE l.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO;
      IF @Ln_QNTY = 0
       BEGIN
        -- The receipt will be made ready for distribution to be processed by Distribution batch process.
        SET @Ls_Sql_TEXT = 'INSERT_LSUP_Y1';
		SET @Ls_Sqldata_TEXT = 'TransactionCurSup_AMNT = ' + ISNULL('0','')+ ', OweTotCurSup_AMNT = ' + ISNULL('0','')+ ', AppTotCurSup_AMNT = ' + ISNULL('0','')+ ', MtdCurSupOwed_AMNT = ' + ISNULL('0','')+ ', TransactionExptPay_AMNT = ' + ISNULL('0','')+ ', OweTotExptPay_AMNT = ' + ISNULL('0','')+ ', AppTotExptPay_AMNT = ' + ISNULL('0','')+ ', TransactionNaa_AMNT = ' + ISNULL('0','')+ ', OweTotNaa_AMNT = ' + ISNULL('0','')+ ', AppTotNaa_AMNT = ' + ISNULL('0','')+ ', TransactionPaa_AMNT = ' + ISNULL('0','')+ ', OweTotPaa_AMNT = ' + ISNULL('0','')+ ', AppTotPaa_AMNT = ' + ISNULL('0','')+ ', TransactionTaa_AMNT = ' + ISNULL('0','')+ ', OweTotTaa_AMNT = ' + ISNULL('0','')+ ', AppTotTaa_AMNT = ' + ISNULL('0','')+ ', TransactionCaa_AMNT = ' + ISNULL('0','')+ ', OweTotCaa_AMNT = ' + ISNULL('0','')+ ', AppTotCaa_AMNT = ' + ISNULL('0','')+ ', TransactionUpa_AMNT = ' + ISNULL('0','')+ ', OweTotUpa_AMNT = ' + ISNULL('0','')+ ', AppTotUpa_AMNT = ' + ISNULL('0','')+ ', TransactionUda_AMNT = ' + ISNULL('0','')+ ', OweTotUda_AMNT = ' + ISNULL('0','')+ ', AppTotUda_AMNT = ' + ISNULL('0','')+ ', TransactionIvef_AMNT = ' + ISNULL('0','')+ ', OweTotIvef_AMNT = ' + ISNULL('0','')+ ', AppTotIvef_AMNT = ' + ISNULL('0','')+ ', TransactionMedi_AMNT = ' + ISNULL('0','')+ ', OweTotMedi_AMNT = ' + ISNULL('0','')+ ', AppTotMedi_AMNT = ' + ISNULL('0','')+ ', TransactionNffc_AMNT = ' + ISNULL('0','')+ ', OweTotNffc_AMNT = ' + ISNULL('0','')+ ', AppTotNffc_AMNT = ' + ISNULL('0','')+ ', TransactionNonIvd_AMNT = ' + ISNULL('0','')+ ', OweTotNonIvd_AMNT = ' + ISNULL('0','')+ ', AppTotNonIvd_AMNT = ' + ISNULL('0','')+ ', Batch_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Batch_NUMB = ' + ISNULL('0','')+ ', SeqReceipt_NUMB = ' + ISNULL('0','')+ ', Receipt_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ObligationCreation1010_NUMB AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', TransactionFuture_AMNT = ' + ISNULL('0','')+ ', AppTotFuture_AMNT = ' + ISNULL('0','');
        INSERT LSUP_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                ObligationSeq_NUMB,
                SupportYearMonth_NUMB,
                TypeWelfare_CODE,
                TransactionCurSup_AMNT,
                OweTotCurSup_AMNT,
                AppTotCurSup_AMNT,
                MtdCurSupOwed_AMNT,
                TransactionExptPay_AMNT,
                OweTotExptPay_AMNT,
                AppTotExptPay_AMNT,
                TransactionNaa_AMNT,
                OweTotNaa_AMNT,
                AppTotNaa_AMNT,
                TransactionPaa_AMNT,
                OweTotPaa_AMNT,
                AppTotPaa_AMNT,
                TransactionTaa_AMNT,
                OweTotTaa_AMNT,
                AppTotTaa_AMNT,
                TransactionCaa_AMNT,
                OweTotCaa_AMNT,
                AppTotCaa_AMNT,
                TransactionUpa_AMNT,
                OweTotUpa_AMNT,
                AppTotUpa_AMNT,
                TransactionUda_AMNT,
                OweTotUda_AMNT,
                AppTotUda_AMNT,
                TransactionIvef_AMNT,
                OweTotIvef_AMNT,
                AppTotIvef_AMNT,
                TransactionMedi_AMNT,
                OweTotMedi_AMNT,
                AppTotMedi_AMNT,
                TransactionNffc_AMNT,
                OweTotNffc_AMNT,
                AppTotNffc_AMNT,
                TransactionNonIvd_AMNT,
                OweTotNonIvd_AMNT,
                AppTotNonIvd_AMNT,
                Batch_DATE,
                SourceBatch_CODE,
                Batch_NUMB,
                SeqReceipt_NUMB,
                Receipt_DATE,
                Distribute_DATE,
                TypeRecord_CODE,
                EventFunctionalSeq_NUMB,
                EventGlobalSeq_NUMB,
                TransactionFuture_AMNT,
                AppTotFuture_AMNT,
                CheckRecipient_ID,
                CheckRecipient_CODE)
        (SELECT o.Case_IDNO, 
                o.OrderSeq_NUMB,
                o.ObligationSeq_NUMB,
                SUBSTRING(CONVERT(VARCHAR(6),@Ad_Run_DATE,112),1,6) AS SupportYearMonth_NUMB,
                ISNULL((SELECT TOP 1 TypeWelfare_CODE
                          FROM MHIS_Y1 m
                         WHERE m.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
                           AND o.MemberMci_IDNO = m.MemberMci_IDNO
                           AND @Ad_Run_DATE BETWEEN Start_DATE AND End_DATE
                           AND o.EndValidity_DATE = @Ld_High_DATE), dbo.BATCH_COMMON_GETS$SF_GETCASETYPE(@Ln_VoluntaryCur_Case_IDNO)) AS TypeWelfare_CODE,
                0 AS TransactionCurSup_AMNT ,
				0 AS OweTotCurSup_AMNT      ,
				0 AS AppTotCurSup_AMNT      ,
				0 AS MtdCurSupOwed_AMNT     ,
				0 AS TransactionExptPay_AMNT,
				0 AS OweTotExptPay_AMNT     ,
				0 AS AppTotExptPay_AMNT     ,
				0 AS TransactionNaa_AMNT    ,
				0 AS OweTotNaa_AMNT         ,
				0 AS AppTotNaa_AMNT         ,
				0 AS TransactionPaa_AMNT    ,
				0 AS OweTotPaa_AMNT         ,
				0 AS AppTotPaa_AMNT         ,
				0 AS TransactionTaa_AMNT    ,
				0 AS OweTotTaa_AMNT         ,
				0 AS AppTotTaa_AMNT         ,
				0 AS TransactionCaa_AMNT    ,
				0 AS OweTotCaa_AMNT         ,
				0 AS AppTotCaa_AMNT         ,
				0 AS TransactionUpa_AMNT    ,
				0 AS OweTotUpa_AMNT         ,
				0 AS AppTotUpa_AMNT         ,
				0 AS TransactionUda_AMNT    ,
				0 AS OweTotUda_AMNT         ,
				0 AS AppTotUda_AMNT         ,
				0 AS TransactionIvef_AMNT   ,
				0 AS OweTotIvef_AMNT        ,
				0 AS AppTotIvef_AMNT        ,
				0 AS TransactionMedi_AMNT   ,
				0 AS OweTotMedi_AMNT        ,
				0 AS AppTotMedi_AMNT        ,
				0 AS TransactionNffc_AMNT   ,
				0 AS OweTotNffc_AMNT        ,
				0 AS AppTotNffc_AMNT        ,
				0 AS TransactionNonIvd_AMNT ,
				0 AS OweTotNonIvd_AMNT      ,
				0 AS AppTotNonIvd_AMNT      ,     
                @Ld_Low_DATE AS Batch_DATE, 
                @Lc_Space_TEXT AS SourceBatch_CODE,
                0 AS Batch_NUMB, 
                0 AS SeqReceipt_NUMB,
                @Ld_Low_DATE AS Receipt_DATE,    
                @Ad_Run_DATE AS Distribute_DATE,  
                @Lc_Space_TEXT AS TypeRecord_CODE,
                @Li_ObligationCreation1010_NUMB AS EventFunctionalSeq_NUMB,              
                @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                0 AS TransactionFuture_AMNT,
                0 AS AppTotFuture_AMNT,
                o.CheckRecipient_ID ,
                o.CheckRecipient_CODE
           FROM OBLE_Y1 o
          WHERE o.Case_IDNO = @Ln_VoluntaryCur_Case_IDNO
            AND o.EndValidity_DATE = @Ld_High_DATE);
       END

      SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1_VL';
      SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ld_VoluntaryCur_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Lc_VoluntaryCur_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @Ln_VoluntaryCur_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @Ln_VoluntaryCur_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_VoluntaryCur_EventGlobalBeginSeq_NUMB AS VARCHAR ),'');

      UPDATE RCTH_Y1
         SET EndValidity_DATE = @Ad_Process_DATE,
             EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
        FROM RCTH_Y1
       WHERE Batch_DATE = @Ld_VoluntaryCur_Batch_DATE
         AND SourceBatch_CODE = @Lc_VoluntaryCur_SourceBatch_CODE
         AND Batch_NUMB = @Ln_VoluntaryCur_Batch_NUMB
         AND SeqReceipt_NUMB = @Ln_VoluntaryCur_SeqReceipt_NUMB
         AND EventGlobalBeginSeq_NUMB = @Ln_VoluntaryCur_EventGlobalBeginSeq_NUMB;

      SET @Ls_Sql_TEXT = 'MERG_INSERT_RCTH_Y1_VL';
	  SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ld_VoluntaryCur_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Lc_VoluntaryCur_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_VoluntaryCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_VoluntaryCur_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_VoluntaryCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '');
     MERGE INTO RCTH_Y1 t USING (SELECT @Ld_VoluntaryCur_Batch_DATE Batch_DATE, @Lc_VoluntaryCur_SourceBatch_CODE SourceBatch_CODE, @Ln_VoluntaryCur_Batch_NUMB Batch_NUMB, @Ln_VoluntaryCur_SeqReceipt_NUMB SeqReceipt_NUMB) s ON ( t.Batch_DATE = s.Batch_DATE AND t.SourceBatch_CODE = s.SourceBatch_CODE AND t.Batch_NUMB = s.Batch_NUMB AND t.SeqReceipt_NUMB = s.SeqReceipt_NUMB AND t.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE AND t.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB) WHEN MATCHED THEN UPDATE SET ToDistribute_AMNT = ToDistribute_AMNT + @Ln_VoluntaryCur_ToDistribute_AMNT WHEN NOT MATCHED THEN INSERT (Batch_DATE, SourceBatch_CODE, Batch_NUMB, SeqReceipt_NUMB, SourceReceipt_CODE, TypeRemittance_CODE, TypePosting_CODE, Case_IDNO, PayorMCI_IDNO, Receipt_AMNT, ToDistribute_AMNT, Fee_AMNT, Employer_IDNO, Fips_CODE, Check_DATE, CheckNo_Text, Receipt_DATE, Distribute_DATE, Tanf_CODE, TaxJoint_CODE, TaxJoint_NAME, StatusReceipt_CODE, ReasonStatus_CODE, BackOut_INDC, ReasonBackOut_CODE, BeginValidity_DATE, EndValidity_DATE, Release_DATE, Refund_DATE, ReferenceIrs_IDNO, RefundRecipient_ID, RefundRecipient_CODE, EventGlobalBeginSeq_NUMB, EventGlobalEndSeq_NUMB) VALUES ( @Ld_VoluntaryCur_Batch_DATE, @Lc_VoluntaryCur_SourceBatch_CODE, @Ln_VoluntaryCur_Batch_NUMB, @Ln_VoluntaryCur_SeqReceipt_NUMB, @Lc_VoluntaryCur_SourceReceipt_CODE, @Lc_VoluntaryCur_TypeRemittance_CODE, @Lc_VoluntaryCur_TypePosting_CODE, @Ln_VoluntaryCur_Case_IDNO, @Ln_VoluntaryCur_PayorMCI_IDNO, @Ln_VoluntaryCur_Receipt_AMNT, @Ln_VoluntaryCur_ToDistribute_AMNT, @Ln_VoluntaryCur_Fee_AMNT, @Lc_VoluntaryCur_Employer_IDNO, @Lc_VoluntaryCur_Fips_IDNO, @Ld_VoluntaryCur_Check_DATE, @Lc_VoluntaryCur_CheckNo_TEXT, @Ld_VoluntaryCur_Receipt_DATE, @Ld_Low_DATE, @Lc_VoluntaryCur_Tanf_INDC, @Lc_VoluntaryCur_TaxJoint_INDC, @Lc_VoluntaryCur_TaxJoint_NAME, @Lc_StatusReceiptIdentified_CODE, @Lc_VoluntaryCur_ReasonStatus_CODE, @Lc_No_INDC, @Lc_Space_TEXT, @Ad_Process_DATE, @Ld_High_DATE, @Ad_Process_DATE, @Ld_VoluntaryCur_Refund_DATE, @Ln_VoluntaryCur_ReferenceIrs_IDNO, @Lc_VoluntaryCur_RefundRecipient_ID, @Lc_VoluntaryCur_RefundRecipient_CODE, @Ln_EventGlobalSeq_NUMB, 0);

      SET @Ls_Sql_TEXT = 'FETCH Voluntary_CUR - 2';
	  SET @Ls_Sqldata_TEXT = '';	
      FETCH NEXT FROM Voluntary_CUR INTO @Ld_VoluntaryCur_Batch_DATE, @Lc_VoluntaryCur_SourceBatch_CODE, @Ln_VoluntaryCur_Batch_NUMB, @Ln_VoluntaryCur_SeqReceipt_NUMB, @Lc_VoluntaryCur_SourceReceipt_CODE, @Lc_VoluntaryCur_TypeRemittance_CODE, @Lc_VoluntaryCur_TypePosting_CODE, @Ln_VoluntaryCur_Case_IDNO, @Ln_VoluntaryCur_PayorMCI_IDNO, @Ln_VoluntaryCur_Receipt_AMNT, @Ln_VoluntaryCur_ToDistribute_AMNT, @Ln_VoluntaryCur_Fee_AMNT, @Lc_VoluntaryCur_Employer_IDNO, @Lc_VoluntaryCur_Fips_IDNO, @Ld_VoluntaryCur_Check_DATE, @Lc_VoluntaryCur_CheckNo_TEXT, @Ld_VoluntaryCur_Receipt_DATE, @Lc_VoluntaryCur_Tanf_INDC, @Lc_VoluntaryCur_TaxJoint_INDC, @Lc_VoluntaryCur_TaxJoint_NAME, @Lc_VoluntaryCur_StatusReceipt_CODE, @Lc_VoluntaryCur_ReasonStatus_CODE, @Lc_VoluntaryCur_BackOut_INDC, @Lc_VoluntaryCur_ReasonBackOut_CODE, @Ld_VoluntaryCur_Release_DATE, @Ld_VoluntaryCur_Refund_DATE, @Ln_VoluntaryCur_ReferenceIrs_IDNO, @Lc_VoluntaryCur_RefundRecipient_ID, @Lc_VoluntaryCur_RefundRecipient_CODE, @Ln_VoluntaryCur_EventGlobalBeginSeq_NUMB, @Lc_VoluntaryCur_Processed_INDC;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE Voluntary_CUR;

   DEALLOCATE Voluntary_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   
   IF CURSOR_STATUS('LOCAL', 'Voluntary_CUR') IN (0, 1)
    BEGIN
     CLOSE Voluntary_CUR;
     DEALLOCATE Voluntary_CUR;
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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
 END


GO
