/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DFS_DISTRIBUTION$SP_CS_PROCESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_DFS_DISTRIBUTION$SP_CS_PROCESS
Programmer Name 	: IMP Team
Description			: This stored Procedure is called from the main SP_FC_DISTRIBUTION to proces the CHIVE
                      money applied towards current month IV-E grant.				  
Frequency			: 'MONTHLY'
Developed On		: 07/14/2011
Called BY			: BATCH_FIN_FC_DISTRIBUTION$SP_FC_DISTRIBUTION
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DFS_DISTRIBUTION$SP_CS_PROCESS]
 @An_Case_IDNO                  NUMERIC(6),
 @An_OrderSeq_NUMB              NUMERIC(2),
 @An_ObligationSeq_NUMB         NUMERIC(2),
 @An_CaseWelfare_IDNO           NUMERIC(10),
 @Ad_Batch_DATE                 DATE,
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_Batch_NUMB                 NUMERIC(4),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @Ad_Receipt_DATE               DATE,
 @Ac_CheckRecipient_ID          CHAR(10),
 @Ac_CheckRecipient_CODE        CHAR (1),
 @An_EventGlobalSupportSeq_NUMB NUMERIC (19),
 @An_EventGlobalSeq_NUMB         NUMERIC (19),
 @Ac_TypeHold_CODE              CHAR(1),
 @An_Cs_AMNT                    NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE               DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_FosterCareDistributionHold1845_NUMB  INT = 1845,
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_WelfareTypeNonIve_CODE          CHAR(1) = 'F',
           @Lc_Yes_INDC                        CHAR(1) = 'Y',
           @Lc_RecipientTypeOthp_CODE          CHAR(1) = '3',
           @Lc_No_INDC                         CHAR(1) = 'N',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_RegularHold_CODE                CHAR(1) = 'D',
           @Lc_DisbursementStatusHeld_CODE     CHAR(1) = 'H',
           @Lc_IveHold_CODE                    CHAR(1) = 'E',
           @Lc_DisbursementStatusRelease_CODE  CHAR(1) = 'R',
           @Lc_ReasonStatus_CODE			   CHAR(4) = ' ',
           @Lc_ReasonStatusSdfm_CODE           CHAR(4) = 'SDFM',  
           @Lc_ReasonStatusSdfg_CODE           CHAR(4) = 'SDFG',
           @Lc_ReasonStatusDr_CODE             CHAR(4) = 'DR',
           @Lc_DisbursementTypeChive_CODE      CHAR(5) = 'CHIVE',
           @Lc_DisbursementTypeCgive_CODE      CHAR(5) = 'CGIVE',
           @Lc_EntityWcase_CODE                CHAR(5) = 'WCASE',
           @Lc_CheckRecipientIve999999993_ID   CHAR(9) = 999999993,
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_CS_PROCESS',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Error_NUMB          NUMERIC(11),
           @Ln_ErrorLine_NUMB      NUMERIC(11),
           @Ln_MtdUrg_AMNT         NUMERIC(11,2) = 0,
           @Ln_GrantPaid_AMNT      NUMERIC(11,2),
           @Ln_Cg_AMNT             NUMERIC(11,2),
           @Li_Rowcount_QNTY       SMALLINT,
           @Lc_DistWcaseFlag_INDC  CHAR(1),
           @Ls_Sql_TEXT            VARCHAR(100) = '',
           @Ls_Sqldata_TEXT        VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT   VARCHAR(4000);

  BEGIN TRY
   BEGIN
    SET @Ac_Msg_CODE = '';
    SET @Ln_MtdUrg_AMNT = 0;
    SET @Ln_Cg_AMNT = 0;
    SET @Ls_Sql_TEXT = 'SELECT_IVMG_Y1_CS';
    SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL (CAST(@An_CaseWelfare_IDNO AS VARCHAR), '') + ', WelfareElig_CODE = ' + @Lc_WelfareTypeNonIve_CODE;
    SELECT @Ln_MtdUrg_AMNT = a.MtdAssistExpend_AMNT - a.MtdAssistRecoup_AMNT,
           @Ln_Cg_AMNT = a.MtdAssistExpend_AMNT
      FROM IVMG_Y1 a
     WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
       AND a.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE
       AND a.WelfareYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6)
       AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB)
                                      FROM IVMG_Y1 b
                                     WHERE b.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                                       AND b.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE
                                       AND b.WelfareYearMonth_NUMB = SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6));

    --Hold the DHLD_Y1 records as SDFG if there are no existing IVMG records
    SET @Li_Rowcount_QNTY = @@ROWCOUNT;

    IF @Li_Rowcount_QNTY = 0
     BEGIN
      -- When the record is already held, skip from further processing
      IF @Ac_TypeHold_CODE != @Lc_RegularHold_CODE
       BEGIN
        SET @An_Cs_AMNT = 0;

        RETURN;
       END
             
	  -- SDFM - NO IV-E MHIS RECORD FOR DEPENDENT
	  -- SDFG - NO IV-E GRANT
      IF @An_CaseWelfare_IDNO = 0
       BEGIN
        SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusSdfm_CODE;
       END
       ELSE
       BEGIN
		SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusSdfg_CODE;
       END

      IF @An_Cs_AMNT > 0
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y1_SDFG_CS';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ad_Receipt_DATE AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_DisbursementTypeChive_CODE,'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @An_Cs_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusHeld_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_IveHold_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', CheckRecipient_ID = ' + ISNULL(@Ac_CheckRecipient_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(' ','');
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
                EventGlobalBeginSeq_NUMB,
                EventGlobalEndSeq_NUMB,
                EventGlobalSupportSeq_NUMB,
                BeginValidity_DATE,
                EndValidity_DATE,
                Disburse_DATE,
                DisburseSeq_NUMB,
                StatusEscheat_DATE,
                StatusEscheat_CODE)
        VALUES (@An_Case_IDNO, -- Case_IDNO
                @An_OrderSeq_NUMB, -- OrderSeq_NUMB
                @An_ObligationSeq_NUMB, -- ObligationSeq_NUMB
                @Ad_Batch_DATE, -- Batch_DATE
                @Ac_SourceBatch_CODE, -- SourceBatch_CODE
                @An_Batch_NUMB, -- Batch_NUMB
                @An_SeqReceipt_NUMB, -- SeqReceipt_NUMB
                @Ad_Process_DATE, -- Transaction_DATE
                @Ad_Receipt_DATE, -- Release_DATE
                @Lc_DisbursementTypeChive_CODE, -- TypeDisburse_CODE
                @An_Cs_AMNT, -- Transaction_AMNT
                @Lc_DisbursementStatusHeld_CODE, -- Status_CODE
                @Lc_IveHold_CODE, -- TypeHold_CODE
                @Lc_Yes_INDC, -- ProcessOffset_INDC
                @Ac_CheckRecipient_ID, -- CheckRecipient_ID
                @Ac_CheckRecipient_CODE, -- CheckRecipient_CODE
                @Lc_ReasonStatus_CODE, -- ReasonStatus_CODE
                @An_EventGlobalSeq_NUMB, -- EventGlobalBeginSeq_NUMB
                0, -- EventGlobalEndSeq_NUMB
                @An_EventGlobalSupportSeq_NUMB, -- EventGlobalSupportSeq_NUMB
                @Ad_Process_DATE, -- BeginValidity_DATE
                @Ld_High_DATE, -- EndValidity_DATE
                @Ld_Low_DATE, -- Disburse_DATE
                0, -- DisburseSeq_NUMB
                @Ld_High_DATE, -- StatusEscheat_DATE
                ' '); -- StatusEscheat_CODE

        SET @Li_Rowcount_QNTY = @@ROWCOUNT;

        IF @Li_Rowcount_QNTY = 0
         BEGIN
          SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y1_SDFG_CS FAILED';

          RAISERROR (50001,16,1);
         END

        SET @An_Cs_AMNT = 0;
       END

      SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1';
      SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@Li_FosterCareDistributionHold1845_NUMB AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@An_EventGlobalSeq_NUMB AS VARCHAR), '');

      INSERT INTO ESEM_Y1
                  (TypeEntity_CODE,
                   EventGlobalSeq_NUMB,
                   EventFunctionalSeq_NUMB,
                   Entity_ID)
      (SELECT p.TypeEntity_CODE,
              @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
              @Li_FosterCareDistributionHold1845_NUMB AS EventFunctionalSeq_NUMB,
              p.Entity_ID
         FROM #EsemHold_P1 p);

      SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

      RETURN;
     END
   END

   SET @Ln_GrantPaid_AMNT = 0;

   IF @Ln_MtdUrg_AMNT < 0
    BEGIN
     SET @Ln_MtdUrg_AMNT = 0;
    END

   IF @An_Cs_AMNT > @Ln_MtdUrg_AMNT
    BEGIN
     SET @Ln_GrantPaid_AMNT = @Ln_MtdUrg_AMNT;
     SET @An_Cs_AMNT = @An_Cs_AMNT - @Ln_MtdUrg_AMNT;
    END
   ELSE
    BEGIN
     SET @Ln_GrantPaid_AMNT = @An_Cs_AMNT;
     SET @An_Cs_AMNT = 0;
    END

   IF @Ln_GrantPaid_AMNT > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y1_CG';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Transaction_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Release_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_DisbursementTypeCgive_CODE,'')+ ', Transaction_AMNT = ' + ISNULL(CAST( @Ln_GrantPaid_AMNT AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_DisbursementStatusRelease_CODE,'')+ ', TypeHold_CODE = ' + ISNULL(@Lc_RegularHold_CODE,'')+ ', ProcessOffset_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', CheckRecipient_ID = ' + ISNULL(@Lc_CheckRecipientIve999999993_ID,'')+ ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusDr_CODE,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Disburse_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', DisburseSeq_NUMB = ' + ISNULL('0','')+ ', StatusEscheat_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', StatusEscheat_CODE = ' + ISNULL(' ','');
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
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             EventGlobalSupportSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             Disburse_DATE,
             DisburseSeq_NUMB,
             StatusEscheat_DATE,
             StatusEscheat_CODE)
  VALUES (@An_Case_IDNO,                         -- Case_IDNO                 
         @An_OrderSeq_NUMB,                    -- OrderSeq_NUMB             
         @An_ObligationSeq_NUMB,               -- ObligationSeq_NUMB        
         @Ad_Batch_DATE,                       -- Batch_DATE                
         @Ac_SourceBatch_CODE,                 -- SourceBatch_CODE          
         @An_Batch_NUMB,                       -- Batch_NUMB                
         @An_SeqReceipt_NUMB,                  -- SeqReceipt_NUMB           
         @Ad_Process_DATE,                     -- Transaction_DATE          
         @Ad_Process_DATE,                     -- Release_DATE              
         @Lc_DisbursementTypeCgive_CODE,       -- TypeDisburse_CODE         
         @Ln_GrantPaid_AMNT,                   -- Transaction_AMNT          
         @Lc_DisbursementStatusRelease_CODE,   -- Status_CODE               
         @Lc_RegularHold_CODE,                 -- TypeHold_CODE             
         @Lc_Yes_INDC,                         -- ProcessOffset_INDC        
         @Lc_CheckRecipientIve999999993_ID,           -- CheckRecipient_ID         
         @Lc_RecipientTypeOthp_CODE,           -- CheckRecipient_CODE       
         @Lc_ReasonStatusDr_CODE,              -- ReasonStatus_CODE         
         @An_EventGlobalSeq_NUMB,               -- EventGlobalBeginSeq_NUMB  
         0,                                    -- EventGlobalEndSeq_NUMB    
         @An_EventGlobalSupportSeq_NUMB,       -- EventGlobalSupportSeq_NUMB
         @Ad_Process_DATE,                     -- BeginValidity_DATE        
         @Ld_High_DATE,                        -- EndValidity_DATE          
         @Ld_Low_DATE,                         -- Disburse_DATE             
         0,                                    -- DisburseSeq_NUMB          
         @Ld_High_DATE,                        -- StatusEscheat_DATE        
         ' ');                                  -- StatusEscheat_CODE        

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y1_CG FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT_LWEL_Y1_CG';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', ObligationSeq_NUMB = ' + ISNULL(CAST( @An_ObligationSeq_NUMB AS VARCHAR ),'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeNonIve_CODE,'')+ ', TypeDisburse_CODE = ' + ISNULL(@Lc_DisbursementTypeCgive_CODE,'')+ ', Distribute_AMNT = ' + ISNULL(CAST( @Ln_GrantPaid_AMNT AS VARCHAR ),'')+ ', Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSupportSeq_NUMB AS VARCHAR ),'');
     INSERT LWEL_Y1
            (Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             CaseWelfare_IDNO,
             WelfareYearMonth_NUMB,
             TypeWelfare_CODE,
             TypeDisburse_CODE,
             Distribute_AMNT,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             Distribute_DATE,
             EventGlobalSeq_NUMB,
             EventGlobalSupportSeq_NUMB)
    VALUES ( @An_Case_IDNO,                                                -- Case_IDNO                 
              @An_OrderSeq_NUMB,                                           -- OrderSeq_NUMB             
              @An_ObligationSeq_NUMB,                                      -- ObligationSeq_NUMB        
              @An_CaseWelfare_IDNO,                                        -- CaseWelfare_IDNO          
              SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6),     -- WelfareYearMonth_NUMB     
              @Lc_WelfareTypeNonIve_CODE,                                  -- TypeWelfare_CODE          
              @Lc_DisbursementTypeCgive_CODE,                              -- TypeDisburse_CODE         
              @Ln_GrantPaid_AMNT,                                          -- Distribute_AMNT           
              @Ad_Batch_DATE,                                              -- Batch_DATE                
              @Ac_SourceBatch_CODE,                                        -- SourceBatch_CODE          
              @An_Batch_NUMB,                                              -- Batch_NUMB                
              @An_SeqReceipt_NUMB,                                         -- SeqReceipt_NUMB           
              @Ad_Process_DATE,                                            -- Distribute_DATE           
              @An_EventGlobalSeq_NUMB,                                     -- EventGlobalSeq_NUMB       
              @An_EventGlobalSupportSeq_NUMB);                             -- EventGlobalSupportSeq_NUMB
              
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_LWEL_Y1_CG FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT_IVMG_Y1_CG';
     SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL (CAST(@An_CaseWelfare_IDNO AS VARCHAR), '') + ', WelfareElig_CODE = ' + @Lc_WelfareTypeNonIve_CODE + ', TransactionAssistExpend_AMNT = ' + CAST(0 AS VARCHAR) + ', TransactionAssistRecoup_AMNT = ' + CAST(@Ln_GrantPaid_AMNT AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@An_EventGlobalSeq_NUMB AS VARCHAR);
     INSERT IVMG_Y1
            (CaseWelfare_IDNO,
             WelfareYearMonth_NUMB,
             WelfareElig_CODE,
             MtdAssistExpend_AMNT,
             TransactionAssistExpend_AMNT,
             LtdAssistExpend_AMNT,
             TransactionAssistRecoup_AMNT,
             LtdAssistRecoup_AMNT,
             MtdAssistRecoup_AMNT,
             TypeAdjust_CODE,
             EventGlobalSeq_NUMB,
             ZeroGrant_INDC,
             AdjustLtdFlag_INDC,
             Defra_AMNT,
             CpMci_IDNO)
     (SELECT @An_CaseWelfare_IDNO AS CaseWelfare_IDNO,
             a.WelfareYearMonth_NUMB,
             @Lc_WelfareTypeNonIve_CODE AS WelfareElig_CODE,
             a.MtdAssistExpend_AMNT,
             0 AS TransactionAssistExpend_AMNT,
             a.LtdAssistExpend_AMNT,
             @Ln_GrantPaid_AMNT AS TransactionAssistRecoup_AMNT,
             a.LtdAssistRecoup_AMNT + @Ln_GrantPaid_AMNT AS LtdAssistRecoup_AMNT,
             a.MtdAssistRecoup_AMNT + CASE SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6) 
                                       WHEN a.WelfareYearMonth_NUMB
                                        THEN @Ln_GrantPaid_AMNT
                                       ELSE 0
                                      END AS MtdAssistRecoup_AMNT,
             a.TypeAdjust_CODE,
             @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
             a.ZeroGrant_INDC,
             a.AdjustLtdFlag_INDC,
             a.Defra_AMNT,
			 a.CpMci_IDNO
        FROM IVMG_Y1 a
       WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
         AND a.WelfareYearMonth_NUMB BETWEEN SUBSTRING(CONVERT(VARCHAR(6),@Ad_Receipt_DATE,112),1,6) AND SUBSTRING(CONVERT(VARCHAR(6),@Ad_Process_DATE,112),1,6)
         AND a.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE
         AND a.EventGlobalSeq_NUMB = (SELECT MAX (b.EventGlobalSeq_NUMB)
                                        FROM IVMG_Y1 b
                                       WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                         AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB
                                         AND b.WelfareElig_CODE = @Lc_WelfareTypeNonIve_CODE));

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_IVMG_Y1_CG FAILED';

       RAISERROR (50001,16,1);
      END
    END

   SET @Lc_DistWcaseFlag_INDC = @Lc_No_INDC;

   IF (SELECT 1
         FROM #EsemDist_P1 p
        WHERE p.TypeEntity_CODE = @Lc_EntityWcase_CODE
          AND p.Entity_ID = @An_CaseWelfare_IDNO) > 0
    BEGIN
		SET @Lc_DistWcaseFlag_INDC = @Lc_Yes_INDC;
    END

   IF @Lc_DistWcaseFlag_INDC = @Lc_No_INDC
    BEGIN
		 SET @Ls_Sql_TEXT = 'INSERT_#EsemDist_P1 - DistWcaseFlag_INDC = N';
		 SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_EntityWcase_CODE + ', Entity_ID = ' + CAST(@An_CaseWelfare_IDNO AS VARCHAR);
		 INSERT INTO #EsemDist_P1
					 (TypeEntity_CODE,
					  Entity_ID)
			  VALUES (@Lc_EntityWcase_CODE, -- TypeEntity_CODE
					  @An_CaseWelfare_IDNO); -- Entity_ID
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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
