/****** Object:  StoredProcedure [dbo].[BATCH_FIN_COLLECTIONS$SP_CF_RECEIPT_PROCESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_COLLECTIONS$SP_CF_RECEIPT_PROCESS
Programmer Name 	: IMP Team
Description			: This procedure is used to process 'CF' receipt type records.
Frequency			: 'DAILY'
Developed On		: 12/05/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_COLLECTIONS$SP_CF_RECEIPT_PROCESS]
 @Ad_Batch_DATE               DATE,
 @An_Batch_NUMB               NUMERIC(4),
 @An_SeqReceipt_NUMB          NUMERIC(6),
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Case_IDNO                NUMERIC(6),
 @An_PayorMCI_IDNO            NUMERIC(10),
 @An_Identified_AMNT          NUMERIC(11, 2),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19),
 @Ad_Receipt_DATE             DATE,
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT,
 @Ac_Job_ID					  CHAR(7) = 'DEB0540'
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_IdentifyAReceipt1410_NUMB	   INT = 1410,
		   @Li_ReceiptOnHold1420_NUMB		   INT = 1420,
           @Lc_CheckRecipientTypeOthp_CODE     CHAR(1) = '3',
           @Lc_No_INDC                         CHAR(1) = 'N',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_Yes_INDC                        CHAR(1) = 'Y',
           @Lc_StatusReceiptIdentified_CODE    CHAR(1) = 'I',
           @Lc_StatusReceiptHeld_CODE          CHAR(1) = 'H',
           @Lc_CaseRelationshipCp_CODE         CHAR(1) = 'C',
           @Lc_DhldStatusR_CODE                CHAR(1) = 'R',
           @Lc_DhldTypeHoldD_CODE              CHAR(1) = 'D',
           @Lc_FeeTypeNs_CODE				   CHAR(2) = 'NS',	
           @Lc_HoldRsnShcp_CODE                CHAR(4) = 'SHCP',
           @Lc_TypeEntityCase_CODE             CHAR(4) = 'CASE',
           @Lc_TransactionSrec_CODE			   CHAR(4) = 'SREC',
           @Lc_TypeEntityRctdt_CODE            CHAR(5) = 'RCTDT',
           @Lc_TypeEntityRctno_CODE            CHAR(5) = 'RCTNO',
           @Lc_CPNsfFeeReceipient999999964_ID  CHAR(9) = '999999964',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_CF_RECEIPT_PROCESS',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_OfDaysHold_NUMB           NUMERIC(5) = 0,
		   @Ln_Case_IDNO                 NUMERIC(6) = 0,
           @Ln_Count_QNTY                NUMERIC(10) = 0,
           @Ln_CpflBalance_AMNT          NUMERIC(11,2),
           @Ln_Identified_AMNT           NUMERIC(11,2) = 0,
           @Ln_Held_AMNT                 NUMERIC(11,2) = 0,
           @Ln_AssessedTot_AMNT			 NUMERIC(11,2) = 0,
	       @Ln_RecoveredTot_AMNT		 NUMERIC(11,2) = 0,
	       @Ln_Error_NUMB                NUMERIC(11),
           @Ln_ErrorLine_NUMB            NUMERIC(11),
           @Ln_EventGlobalSeq_NUMB       NUMERIC(19),
           @Ln_EventGlobalBeginSeq_NUMB  NUMERIC(19),
           @Li_Rowcount_QNTY             SMALLINT,
           @Lc_Msg_CODE                  CHAR(1),
           @Lc_HoldReasonStatus_CODE     CHAR(4),
           @Lc_Receipt_IDNO              CHAR(30),
           @Ls_Sql_TEXT                  VARCHAR(100),
           @Ls_Sqldata_TEXT              VARCHAR(1000),
           @Ls_ErrorMessage_TEXT         VARCHAR(4000),
           @Ld_Release_DATE              DATE;
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ln_Identified_AMNT = @An_Identified_AMNT;
   SET @Ln_EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;
   
   -- CP NSF Fee (NS) Assesment Checking
   SET @Ls_Sql_TEXT = ' SELECT CPFL_Y1';
   SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ', FeeType_CODE = ' + @Lc_FeeTypeNs_CODE;	
   
   SELECT 	@Ln_AssessedTot_AMNT = AssessedTot_AMNT, 
			@Ln_RecoveredTot_AMNT = RecoveredTot_AMNT,
			@Ln_Case_IDNO = Case_IDNO
       FROM CPFL_Y1 a
      WHERE a.MemberMci_IDNO = @An_PayorMCI_IDNO
        AND a.FeeType_CODE = @Lc_FeeTypeNs_CODE
        AND a.Unique_IDNO =
               (SELECT MAX (Unique_IDNO)
                  FROM CPFL_Y1 b
                 WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                   AND a.FeeType_CODE = b.FeeType_CODE
	            );
	            
	 SET @Li_Rowcount_QNTY = @@ROWCOUNT;
	 
     IF @Li_Rowcount_QNTY = 0
     BEGIN
        SET @Ln_AssessedTot_AMNT = 0;
        SET @Ln_RecoveredTot_AMNT = 0;
     END
        
   --  Checking Balance amount in CPFL_Y1
   SET @Ls_Sql_TEXT = 'SELECT CPFL_Y1';
   SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '');

   SELECT @Ln_CpflBalance_AMNT = @Ln_AssessedTot_AMNT - @Ln_RecoveredTot_AMNT ;
			
   IF @Ln_CpflBalance_AMNT < 0
    BEGIN
     SET @Ln_CpflBalance_AMNT = 0;
    END

   -- Checking receipt amount is greater than Balance amount
   IF @Ln_Identified_AMNT > @Ln_CpflBalance_AMNT
    BEGIN
     -- Hold amount calculation
     SET @Ln_Held_AMNT = @Ln_Identified_AMNT - @Ln_CpflBalance_AMNT;
     -- SHCP - EXCESS OF CP FEE
     SET @Lc_HoldReasonStatus_CODE = @Lc_HoldRsnShcp_CODE;
     -- Hold days selection for SHCP udc code
     SET @Ln_OfDaysHold_NUMB = 0;
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 1';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Lc_HoldRsnShcp_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     SELECT @Ln_OfDaysHold_NUMB = ISNULL (a.NumDaysHold_QNTY, 9999)
       FROM UCAT_Y1 a
      WHERE a.Udc_CODE = @Lc_HoldRsnShcp_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'NO RECORD FOUND IN UCAT_Y1 FOR SHCP UDC CODE';
       RAISERROR (50001,16,1);
      END

     -- Release date assignment
     IF @Ln_OfDaysHold_NUMB = 9999
      BEGIN
       SET @Ld_Release_DATE = CAST (@Ld_High_DATE AS DATE);
      END
     ELSE
      BEGIN
       SET @Ld_Release_DATE = DATEADD(DAY, @Ln_OfDaysHold_NUMB, @Ad_Run_DATE);
      END

     -- Receipt Identified amount assignment using pofl over pay amount
     SET @Ln_Identified_AMNT = @Ln_CpflBalance_AMNT;
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ - 1';
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST(@Li_IdentifyAReceipt1410_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Ac_Job_ID + ', EffectiveEvent_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Note_INDC = ' + ISNULL (@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL (@Lc_BatchRunUser_TEXT, '');

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_IdentifyAReceipt1410_NUMB,
    @Ac_Process_ID              = @Ac_Job_ID,
    @Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
    @Ac_Note_INDC               = @Lc_No_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
   IF @Ln_CpflBalance_AMNT <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT DHLD_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL('0','')+ ', ObligationSeq_NUMB = ' + ISNULL('0','')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_Identified_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_DhldStatusR_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_DhldTypeHoldD_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CPNsfFeeReceipient999999964_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_CheckRecipientTypeOthp_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL('0','')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT,'');
     INSERT DHLD_Y1
            (Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             Transaction_DATE,
             Release_DATE,
             TypeDisburse_CODE,
             Transaction_AMNT,
             Status_CODE,
             TypeHold_CODE,
             ProcessOffset_INDC,
             CheckRecipient_ID,
             CheckRecipient_CODE,
             ReasonStatus_CODE,
             EventGlobalSupportSeq_NUMB,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             Disburse_DATE,
             DisburseSeq_NUMB,
             StatusEscheat_DATE,
             StatusEscheat_CODE)
     VALUES (@An_Case_IDNO,-- Case_IDNO
             0,-- OrderSeq_NUMB		
             0,-- ObligationSeq_NUMB
             @Ad_Batch_DATE,-- Batch_DATE
             @Ac_SourceBatch_CODE,-- SourceBatch_CODE
             @An_Batch_NUMB,-- Batch_NUMB
             @An_SeqReceipt_NUMB,-- SeqReceipt_NUMB
             @Ad_Run_DATE,-- Transaction_DATE
             @Ad_Run_DATE,-- Release_DATE
             @Lc_Space_TEXT,-- TypeDisburse_CODE
             @Ln_Identified_AMNT,-- Transaction_AMNT
             @Lc_DhldStatusR_CODE,-- Status_CODE
             @Lc_DhldTypeHoldD_CODE,-- TypeHold_CODE
             @Lc_Yes_INDC,-- ProcessOffset_INDC
             @Lc_CPNsfFeeReceipient999999964_ID,-- CheckRecipient_ID
             @Lc_CheckRecipientTypeOthp_CODE,-- CheckRecipient_CODE
             @Lc_Space_TEXT,-- ReasonStatus_CODE
             0,-- EventGlobalSupportSeq_NUMB
             @Ln_EventGlobalSeq_NUMB,-- EventGlobalBeginSeq_NUMB
             0,-- EventGlobalEndSeq_NUMB
             @Ad_Run_DATE,-- BeginValidity_DATE
             @Ld_High_DATE,-- EndValidity_DATE
             @Ld_Low_DATE,-- Disburse_DATE
             0,-- DisburseSeq_NUMB
             @Ld_High_DATE,-- StatusEscheat_DATE
             @Lc_Space_TEXT -- StatusEscheat_CODE
     );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     -- Move 0 to @Ln_Identified_AMNT when @Ln_CpflBalance_AMNT value is 0 i.e) receipt will move to Hold
     SET @Ln_Identified_AMNT = 0;
    END
    
   IF @Ln_Identified_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1 1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST (@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalBeginSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Identified_AMNT = ' + ISNULL (CAST (@Ln_Identified_AMNT AS VARCHAR), '') + ', Identified_AMNT = ' + ISNULL (CAST (@An_Identified_AMNT AS VARCHAR), '');

     UPDATE RCTH_Y1
        SET EndValidity_DATE = @Ad_Run_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
      WHERE Batch_DATE = @Ad_Batch_DATE
        AND Batch_NUMB = @An_Batch_NUMB
        AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND EventGlobalBeginSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = ' INSERT RCTH_Y1 4 ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST (@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', ToDistribute_AMNT = ' + CAST(@Ln_Identified_AMNT AS VARCHAR) + ', Distribute_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', StatusReceipt_CODE = ' + @Lc_StatusReceiptIdentified_CODE + ', BeginValidity_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', EventGlobalEndSeq_NUMB = 0';

     INSERT RCTH_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             Case_IDNO,
             PayorMCI_IDNO,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Fee_AMNT,
             Employer_IDNO,
             Fips_CODE,
             Check_DATE,
             CheckNo_Text,
             Receipt_DATE,
             Distribute_DATE,
             Tanf_CODE,
             TaxJoint_CODE,
             TaxJoint_NAME,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             BackOut_INDC,
             ReasonBackOut_CODE,
             Refund_DATE,
             Release_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_ID,
             RefundRecipient_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB)
     SELECT r.Batch_DATE,
            r.SourceBatch_CODE,
            r.Batch_NUMB,
            r.SeqReceipt_NUMB,
            r.SourceReceipt_CODE,
            r.TypeRemittance_CODE,
            r.TypePosting_CODE,
            r.Case_IDNO,
            r.PayorMCI_IDNO,
            r.Receipt_AMNT,
            @Ln_Identified_AMNT AS ToDistribute_AMNT,
            r.Fee_AMNT,
            r.Employer_IDNO,
            r.Fips_CODE,
            r.Check_DATE,
            r.CheckNo_Text,
            r.Receipt_DATE,
            @Ad_Run_DATE AS Distribute_DATE,
            r.Tanf_CODE,
            r.TaxJoint_CODE,
            r.TaxJoint_NAME,
            @Lc_StatusReceiptIdentified_CODE AS StatusReceipt_CODE,
            r.ReasonStatus_CODE,
            r.BackOut_INDC,
            r.ReasonBackOut_CODE,
            r.Refund_DATE,
            r.Release_DATE,
            r.ReferenceIrs_IDNO,
            r.RefundRecipient_ID,
            r.RefundRecipient_CODE,
            @Ad_Run_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS  EndValidity_DATE,
            @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS  EventGlobalEndSeq_NUMB
       FROM RCTH_Y1 r
      WHERE r.Batch_DATE = @Ad_Batch_DATE
        AND r.Batch_NUMB = @An_Batch_NUMB
        AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND r.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';
       RAISERROR (50001,16,1);
      END
      
      SET @Ls_Sql_TEXT = 'INSERT INTO CPFL_Y1';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL (CAST (@Ln_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL ('0', '') + ', ObligationSeq_NUMB = ' + ISNULL ('0', '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@An_PayorMCI_IDNO AS VARCHAR), '') + ', FeeType_CODE = ' + ISNULL (@Lc_FeeTypeNs_CODE, '') + ', AssessedYear_NUMB = ' + CAST(SUBSTRING(CONVERT(VARCHAR(4),@Ad_Run_DATE,112),1,4) AS VARCHAR) + ', Transaction_CODE = ' + CAST(@Lc_TransactionSrec_CODE AS VARCHAR) + ', Transaction_DATE = ' + CAST(@Ad_Run_DATE  AS VARCHAR)+ ', Transaction_AMNT = ' + CAST(@Ln_Identified_AMNT AS VARCHAR) + ', AssessedTot_AMNT = ' + CAST(@Ln_AssessedTot_AMNT AS VARCHAR) + ', RecoveredTot_AMNT = ' + CAST(@Ln_RecoveredTot_AMNT AS VARCHAR) + ', TypeDisburse_CODE = ' + @Lc_Space_TEXT + ', Batch_DATE = ' + CAST(@Ad_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Ac_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@An_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@An_SeqReceipt_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', EventGlobalSupportSeq_NUMB = ' + CAST(@An_EventGlobalBeginSeq_NUMB AS VARCHAR) ;
      INSERT INTO CPFL_Y1
				  (Case_IDNO, 
				   OrderSeq_NUMB, 
				   ObligationSeq_NUMB,
				   MemberMci_IDNO, 
				   FeeType_CODE,
				   AssessedYear_NUMB, 
				   Transaction_CODE, 
				   Transaction_DATE,
				   Transaction_AMNT,
				   AssessedTot_AMNT,
				   RecoveredTot_AMNT,
				   TypeDisburse_CODE, 
				   Batch_DATE, 
				   SourceBatch_CODE,
				   Batch_NUMB, 
				   SeqReceipt_NUMB,
				   EventGlobalSeq_NUMB, 
				   EventGlobalSupportSeq_NUMB
				  )
		   VALUES (@Ln_Case_IDNO, -- Case_IDNO
				   0, -- OrderSeq_NUMB
				   0, -- ObligationSeq_NUMB
				   @An_PayorMCI_IDNO, -- MemberMci_IDNO 
				   @Lc_FeeTypeNs_CODE, -- FeeType_CODE
				   SUBSTRING(CONVERT(VARCHAR(4),@Ad_Run_DATE,112),1,4), -- AssessedYear_NUMB
				   @Lc_TransactionSrec_CODE, -- Transaction_CODE
				   @Ad_Run_DATE, -- Transaction_DATE
				   @Ln_Identified_AMNT, -- Transaction_AMNT
				   @Ln_AssessedTot_AMNT, -- AssessedTot_AMNT
				   @Ln_RecoveredTot_AMNT + @Ln_Identified_AMNT, -- RecoveredTot_AMNT
				   @Lc_Space_TEXT,  -- TypeDisburse_CODE
				   @Ad_Batch_DATE, -- Batch_DATE
				   @Ac_SourceBatch_CODE, -- SourceBatch_CODE
				   @An_Batch_NUMB, -- Batch_NUMB
				   @An_SeqReceipt_NUMB, -- SeqReceipt_NUMB
				   @Ln_EventGlobalSeq_NUMB, -- EventGlobalSeq_NUMB
				   @An_EventGlobalBeginSeq_NUMB -- EventGlobalSupportSeq_NUMB
				  );
		
	 SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
	  BEGIN
		 SET @Ls_ErrorMessage_TEXT = 'CPFL INSERT FAILED';
		 RAISERROR(50001,16,1);
	  END
    END
   IF @Ln_Held_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_GET_RECEIPT_NO 1 ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST (@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '');
     SET @Lc_Receipt_IDNO = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB);
     
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ - 2';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Ac_Job_ID + ', EffectiveEvent_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Note_INDC = ' + ISNULL (@Lc_No_INDC, '') + ', Worker_ID = ' + ISNULL (@Lc_BatchRunUser_TEXT, '');
     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
      @Ac_Process_ID              = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = ' UPDATE RCTH_Y1 2 ';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST (@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalBeginSeq_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', Identified_AMNT = ' + ISNULL (CAST (@Ln_Identified_AMNT AS VARCHAR), '') + ', Identified_AMNT = ' + ISNULL (CAST (@An_Identified_AMNT AS VARCHAR), '');

     UPDATE RCTH_Y1
        SET EndValidity_DATE = @Ad_Run_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
      WHERE Batch_DATE = @Ad_Batch_DATE
        AND Batch_NUMB = @An_Batch_NUMB
        AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND EventGlobalBeginSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT ESEM 1';
     SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + CAST(RIGHT(CONVERT(VARCHAR, @Ad_Receipt_DATE, 112), 4) + LEFT(CONVERT(VARCHAR, @Ad_Receipt_DATE, 112), 4) AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', TypeEntity_CODE = ' + @Lc_TypeEntityRctdt_CODE + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR);

     INSERT ESEM_Y1
            (Entity_ID,
             EventGlobalSeq_NUMB,
             TypeEntity_CODE,
             EventFunctionalSeq_NUMB)
     VALUES ( RIGHT(CONVERT(VARCHAR, @Ad_Receipt_DATE, 112), 4) + LEFT(CONVERT(VARCHAR, @Ad_Receipt_DATE, 112), 4), -- Entity_ID
              @Ln_EventGlobalSeq_NUMB, -- EventGlobalSeq_NUMB
              @Lc_TypeEntityRctdt_CODE, -- TypeEntity_CODE
              @Li_ReceiptOnHold1420_NUMB -- EventFunctionalSeq_NUMB
              );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT ESEM 2';
     SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL (@Lc_Receipt_IDNO, '') + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', TypeEntity_CODE = ' + @Lc_TypeEntityRctno_CODE + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR);;
     
     INSERT ESEM_Y1
            (Entity_ID,
             EventGlobalSeq_NUMB,
             TypeEntity_CODE,
             EventFunctionalSeq_NUMB)
     VALUES (@Lc_Receipt_IDNO, -- Entity_ID
             @Ln_EventGlobalSeq_NUMB, -- EventGlobalSeq_NUMB
             @Lc_TypeEntityRctno_CODE, -- TypeEntity_CODE
             @Li_ReceiptOnHold1420_NUMB -- EventFunctionalSeq_NUMB
             );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1 5';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL (CAST (@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL (CAST (@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL (CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL (@Ac_SourceBatch_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL (CAST (@Ln_EventGlobalBeginSeq_NUMB AS VARCHAR), '');

     INSERT RCTH_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             Case_IDNO,
             PayorMCI_IDNO,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Fee_AMNT,
             Employer_IDNO,
             Fips_CODE,
             Check_DATE,
             CheckNo_Text,
             Receipt_DATE,
             Distribute_DATE,
             Tanf_CODE,
             TaxJoint_CODE,
             TaxJoint_NAME,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             BackOut_INDC,
             ReasonBackOut_CODE,
             Refund_DATE,
             Release_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_ID,
             RefundRecipient_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB)
     SELECT r.Batch_DATE,
            r.SourceBatch_CODE,
            r.Batch_NUMB,
            r.SeqReceipt_NUMB,
            r.SourceReceipt_CODE,
            r.TypeRemittance_CODE,
            r.TypePosting_CODE,
            r.Case_IDNO,
            r.PayorMCI_IDNO,
            r.Receipt_AMNT,
            @Ln_Held_AMNT AS ToDistribute_AMNT,
            r.Fee_AMNT,
            r.Employer_IDNO,
            r.Fips_CODE,
            r.Check_DATE,
            r.CheckNo_Text,
            r.Receipt_DATE,
            @Ld_Low_DATE AS Distribute_DATE,
            r.Tanf_CODE,
            r.TaxJoint_CODE,
            r.TaxJoint_NAME,
            @Lc_StatusReceiptHeld_CODE AS StatusReceipt_CODE,
            @Lc_HoldReasonStatus_CODE AS ReasonStatus_CODE,
            r.BackOut_INDC,
            r.ReasonBackOut_CODE,
            r.Refund_DATE,
            @Ld_Release_DATE AS Release_DATE,
            r.ReferenceIrs_IDNO,
            r.RefundRecipient_ID,
            r.RefundRecipient_CODE,
            @Ad_Run_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            @Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB
       FROM RCTH_Y1 r
      WHERE r.Batch_DATE = @Ad_Batch_DATE
        AND r.Batch_NUMB = @An_Batch_NUMB
        AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND r.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     IF @An_PayorMCI_IDNO <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT CASE_Y1,CMEM_Y1 ';
       SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + @Lc_CaseRelationshipCp_Code;

       SELECT @Ln_Count_QNTY = COUNT (1)
         FROM CASE_Y1 a,
              CMEM_Y1 c
        WHERE c.MemberMci_IDNO = @An_PayorMCI_IDNO
          AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_Code
          AND a.Case_IDNO = c.Case_IDNO;

       IF @Ln_Count_QNTY > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT ESEM - 3';
         SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL (CAST(@An_PayorMCI_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + @Lc_CaseRelationshipCp_Code;

         INSERT ESEM_Y1
                (Entity_ID,
                 EventGlobalSeq_NUMB,
                 TypeEntity_CODE,
                 EventFunctionalSeq_NUMB)
         SELECT c.Case_IDNO AS Entity_ID,
                @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                @Lc_TypeEntityCase_CODE AS TypeEntity_CODE,
                @Li_ReceiptOnHold1420_NUMB AS EventFunctionalSeq_NUMB
           FROM CASE_Y1 a,
                CMEM_Y1 c
          WHERE c.MemberMci_IDNO = @An_PayorMCI_IDNO
            AND c.CaseRelationship_CODE = @Lc_CaseRelationshipCp_Code
            AND a.Case_IDNO = c.Case_IDNO;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'INSERT NOT SUCCESSFUL';
           RAISERROR (50001,16,1);
          END
        END
      END
    END
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
  SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   --Check for Exception information to log the description text based on the error
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
