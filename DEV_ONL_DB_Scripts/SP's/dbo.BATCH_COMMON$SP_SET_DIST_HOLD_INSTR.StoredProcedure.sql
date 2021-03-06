/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_SET_DIST_HOLD_INSTR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_SET_DIST_HOLD_INSTR
Programmer Name		: IMP Team
Description			: 
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_SET_DIST_HOLD_INSTR](
 @An_CasePayorMCI_IDNO        NUMERIC(10),
 @Ac_TypeHold_CODE            CHAR(1),
 @As_DescriptionNote_TEXT     VARCHAR(4000),
 @Ad_Effective_DATE           DATE,
 @Ad_Expiration_DATE          DATE,
 @Ac_SourceHold_CODE          CHAR(2),
 @Ac_ReasonHoldDist_CODE      CHAR(4),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19),
 @Ac_Action_CODE              CHAR(1),
 @An_Sequence_NUMB            NUMERIC(11),
 @Ac_EntityActn_IDNO          CHAR(30),
 @Ac_WorkerSignedOn_ID        CHAR(30),
 @Ad_Run_DATE                 DATE = NULL,
 @Ac_Process_ID               CHAR(10),
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
   DECLARE @Li_DistributionHoldInstruction1880_NUMB INT = 1880,
           @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
           @Lc_StatusFailure_CODE               CHAR(1) = 'F',
           @Lc_StatusFailed_CODE                CHAR(1) = 'F',
           @Lc_TypeHoldPostingPayor_CODE        CHAR(1) = 'P',
           @Lc_TypeHoldPostingCase_CODE         CHAR(1) = 'C',
           @Lc_CaseRelationshipNcp_CODE         CHAR(1) = 'A',
           @Lc_CaseRelationshipPutFather_CODE   CHAR(1) = 'P',
           @Lc_CaseMemberStatusActive_CODE      CHAR(1) = 'A',
           @Lc_StatusReceiptIdentified_CODE     CHAR(1) = 'I',
           @Lc_StatusReceiptHeld_CODE           CHAR(1) = 'H',
           @Lc_No_INDC                          CHAR(1) = 'N',
           @Lc_Space_CODE                       CHAR(1) = ' ',
           @Lc_ActionChange_CODE                CHAR(1) = 'C',
           @Lc_ActionExtend_CODE                CHAR(1) = 'E',
           @Lc_ActionAdd_CODE                   CHAR(1) = 'A',
           @Lc_SourceHold_CODE                  CHAR(2) = 'DH',
           @Ls_Routine_TEXT                     VARCHAR(60) = 'BATCH_COMMON$SP_SET_DIST_HOLD_INSTR',
           @Ld_High_DATE                        DATE = '12/31/9999',
           @Ld_Low_DATE                         DATE = '01/01/0001',
           @Ld_Today_DATE                       DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();;
  DECLARE  @Ln_Error_NUMB             NUMERIC,
           @Ln_RowCount_QNTY          NUMERIC,
           @Ln_FetchStatus_QNTY       NUMERIC,
           @Ln_Rcth_QNTY              NUMERIC,
           @Ln_Zero_NUMB              NUMERIC(1) = 0,
           @Ln_EntityCase_IDNO        NUMERIC(6),
           @Ln_PayorMCI_IDNO          NUMERIC(10),
           @Ln_ErrorLine_NUMB         NUMERIC(11),
           @Ln_Seq_NUMB               NUMERIC(11),
           @Ln_Count_QNTY             NUMERIC(11) = 0,
           @Ln_EventGlobalSeq_NUMB    NUMERIC(19),
           @Lc_EntityPayor_IDNO       CHAR(10),
           @Ls_Sql_TEXT               VARCHAR(100),
           @Ls_Sqldata_TEXT           VARCHAR(200),
           @Ls_DescriptionError_TEXT  VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT      VARCHAR(4000) = '',
           @Ld_Run_DATE               DATE;
 DECLARE @Ld_RcthCur_Batch_DATE           DATE,
         @Lc_RcthCur_SourceBatch_CODE     CHAR(3),
         @Ln_RcthCur_Batch_NUMB           NUMERIC(4),
         @Ln_RcthCur_SeqReceipt_NUMB      NUMERIC(6),
         @Lc_RcthCur_SourceReceipt_CODE   CHAR(2),
         @Lc_RcthCur_TypeRemittance_CODE  CHAR(3),
         @Lc_RcthCur_TypePosting_CODE     CHAR(1),
         @Lc_RcthCur_OfficePosting_CODE   CHAR(3),
         @Ln_RcthCur_Case_IDNO            NUMERIC(6),
         @Ln_RcthCur_PayorMCI_IDNO        NUMERIC(10),
         @Ln_RcthCur_Receipt_AMNT         NUMERIC(11, 2),
         @Ln_RcthCur_ToDistribute_AMNT    NUMERIC(11, 2),
         @Ln_RcthCur_Fee_AMNT             NUMERIC(11, 2),
         @Ln_RcthCur_Employer_IDNO        NUMERIC(9),
         @Lc_RcthCur_Fips_CODE            CHAR(7),
         @Ld_RcthCur_Check_DATE           DATE,
         @Ln_RcthCur_Check_NUMB           NUMERIC(19),
         @Ld_RcthCur_Receipt_DATE         DATE,
         @Ld_RcthCur_Distribute_DATE      DATE,
         @Lc_RcthCur_Tanf_CODE            CHAR(1),
         @Lc_RcthCur_TaxJoint_CODE        CHAR(1),
         @Lc_RcthCur_TaxJoint_NAME        CHAR(35),
         @Lc_RcthCur_StatusReceipt_CODE   CHAR(1),
         @Lc_RcthCur_ReasonStatus_CODE    CHAR(4),
         @Lc_RcthCur_BackOut_INDC         CHAR(1),
         @Lc_RcthCur_ReasonBackOut_CODE   CHAR(2),
         @Ld_RcthCur_Refund_DATE          DATE,
         @Ld_RcthCur_Release_DATE         DATE,
         @Lc_RcthCur_RefundRecipient_ID   CHAR(10),
         @Lc_RcthCur_RefundRecipient_CODE CHAR(1);
  BEGIN TRY
   -- Initialize variable 
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ln_Count_QNTY = 0;
   SET @Ln_Rcth_QNTY = 0;

   -- For Batch use run date and for Online use Yystem Date
   IF (@Ad_Run_DATE IS NOT NULL)
    BEGIN
     SET @Ld_Run_DATE = CONVERT(VARCHAR(10), @Ad_Run_DATE, 101);
    END
   ELSE
    BEGIN
     SET @Ld_Run_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
    END

   SET @Ls_Sql_TEXT = 'SELECT DISH_Y1';
   SET @Ls_Sqldata_TEXT = 'CasePayorMCI_IDNO = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '') + ', TypeHold_CODE = ' + ISNULL(@Ac_TypeHold_CODE, '') + ', PYMT SOURCE = ' + ISNULL(@Ac_SourceHold_CODE, '') + ', EFF DATE = ' + ISNULL(CAST(@Ad_Effective_DATE AS VARCHAR), '') + ', EXP DATE = ' + ISNULL(CAST(@Ad_Expiration_DATE AS VARCHAR), '');

   -- Check Already in Distribution Hold  or Change of Hold or Extend of Hold
   IF @Ac_Action_CODE IN (@Lc_ActionChange_CODE, @Lc_ActionExtend_CODE)
    BEGIN
     SET @Ln_Count_QNTY = 0;
    END
   ELSE IF @Ac_TypeHold_CODE IN (@Lc_TypeHoldPostingPayor_CODE, @Lc_TypeHoldPostingCase_CODE)
    BEGIN
     SET @Ln_Count_QNTY = 0;

     -- Check Already in  Distribution Hold  
     IF(EXISTS (SELECT TOP 1 1
                  FROM DISH_Y1 D
                 WHERE D.CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
                   AND D.TypeHold_CODE = @Ac_TypeHold_CODE
                   AND D.SourceHold_CODE = @Ac_SourceHold_CODE
                   AND (@Ad_Effective_DATE < D.Effective_DATE
                         OR (@Ad_Expiration_DATE BETWEEN D.Effective_DATE AND D.Expiration_DATE)
                         OR D.Effective_DATE > @Ad_Effective_DATE
                         OR (D.Expiration_DATE > @Ad_Effective_DATE
                             AND D.Expiration_DATE < @Ad_Expiration_DATE))
                   AND D.EndValidity_DATE = @Ld_High_DATE))
      BEGIN
       SET @Ln_Count_QNTY = 1;
      END
    END

   -- BEGIN if Distribution hold need to be changed    
   IF (@Ln_Count_QNTY = @Ln_Zero_NUMB)
    BEGIN
     -- Generate new Global Event 
     SET @Ls_Sql_TEXT = '	BATCH_COMMON$SP_GENERATE_SEQ ';
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CONVERT(VARCHAR, @Li_DistributionHoldInstruction1880_NUMB), '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', WorkerSignedOn_IDNO = ' + ISNULL(@Ac_WorkerSignedOn_ID, '');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_DistributionHoldInstruction1880_NUMB,
      @Ac_Process_ID              = @Ac_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_WorkerSignedOn_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

     IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ FAILED';
       RAISERROR (50001,16,1);
      END

     -- if the action is Change the Hold or Extend the hold then end date current hold
     IF(@Ac_Action_CODE IN (@Lc_ActionChange_CODE, @Lc_ActionExtend_CODE))
      BEGIN
       SET @Ls_Sql_TEXT = '	UPDATE DISH_Y1 - CHANGE OR EXTEND';
       SET @Ls_Sqldata_TEXT = 'CasePayorMCI_IDNO = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '') + ', TypeHold_CODE = ' + ISNULL(@Ac_TypeHold_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalBeginSeq_NUMB AS VARCHAR), '') + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '');

       UPDATE DISH_Y1
          SET EndValidity_DATE = @Ld_Run_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
        WHERE CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
          AND Sequence_NUMB = @An_Sequence_NUMB
          AND TypeHold_CODE = @Ac_TypeHold_CODE
          AND SourceHold_CODE = @Ac_SourceHold_CODE
          AND ReasonHold_CODE = @Ac_ReasonHoldDist_CODE
          AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = @Ln_Zero_NUMB
        BEGIN
         SET @As_DescriptionError_TEXT = 'UPDATE DISH_Y1 - FAILED';
         RAISERROR (50001,16,1);
        END
      END -- END of End Date the current distribution Hold

     IF @Ac_Action_CODE IN (@Lc_ActionAdd_CODE, @Lc_ActionChange_CODE, @Lc_ActionExtend_CODE)
      BEGIN
       SET @Ln_Seq_NUMB = @An_Sequence_NUMB;

       -- for new hold action find the next Sequence Hold  
       IF (@Ac_Action_CODE = @Lc_ActionAdd_CODE)
        BEGIN
         SET @Ln_Seq_NUMB = 1;

         SELECT @Ln_Seq_NUMB = ISNULL(MAX(D.Sequence_NUMB), 0) + 1
           FROM DISH_Y1 D
          WHERE D.CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
             OR (@Ac_TypeHold_CODE = @Lc_TypeHoldPostingPayor_CODE
                 AND D.CasePayorMCI_IDNO IN (SELECT CM.Case_IDNO
                                               FROM CMEM_Y1 CM
                                              WHERE CM.MemberMci_IDNO = @An_CasePayorMCI_IDNO
                                                AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE))
             OR (@Ac_TypeHold_CODE = @Lc_TypeHoldPostingCase_CODE
                 AND D.CasePayorMCI_IDNO IN (SELECT CM.MemberMci_IDNO
                                               FROM CMEM_Y1 CM
                                              WHERE CM.Case_IDNO = @An_CasePayorMCI_IDNO
                                                AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE));
        END -- END for new hold action find the next Sequence Hold  

       -- find EntityPayor and EntityCase for hold
       IF (@Ac_TypeHold_CODE = @Lc_TypeHoldPostingPayor_CODE)
        BEGIN
         SET @Ln_EntityCase_IDNO = NULL;
         SET @Lc_EntityPayor_IDNO = @An_CasePayorMCI_IDNO;
        END
       ELSE IF (@Ac_TypeHold_CODE = @Lc_TypeHoldPostingCase_CODE)
        BEGIN
         SET @Lc_EntityPayor_IDNO = ' ';

         SELECT @Lc_EntityPayor_IDNO = CM.MemberMci_IDNO
           FROM CMEM_Y1 CM
          WHERE CM.Case_IDNO = @An_CasePayorMCI_IDNO
            AND CM.CaseMemberStatus_CODE = 'A'
            AND CM.CaseRelationship_CODE = 'A';

         SET @Ln_EntityCase_IDNO = @An_CasePayorMCI_IDNO;
        END

       -- END find EntityPayor and EntityCase for hold
       -- Begin Generate Entity Matrix      
       SET @Ls_Sql_TEXT = '	BATCH_COMMON$SP_ENTITY_MATRIX ';
       SET @Ls_Sqldata_TEXT = 'CasePayorMCI_IDNO = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB 1880';

       EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
        @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB,
        @An_EventFunctionalSeq_NUMB = @Li_DistributionHoldInstruction1880_NUMB,
        @An_EntityCase_IDNO         = @Ln_EntityCase_IDNO,
        @Ac_EntityPayor_IDNO        = @Lc_EntityPayor_IDNO,
        @Ac_EntityRshld_IDNO        = @Ac_ReasonHoldDist_CODE,
        @Ac_EntityActn_IDNO         = @Ac_EntityActn_IDNO,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       -- END Generate Entity Matrix     
       -- Add Distribution Hold  
       SET @Ls_Sql_TEXT = 'INSERT DISH_Y1';
       SET @Ls_Sqldata_TEXT = 'CasePayorMCI_IDNO = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '') + ', TypeHold_CODE = ' + ISNULL(@Ac_TypeHold_CODE, '') + ', EFF DATE = ' + ISNULL(CAST(@Ad_Effective_DATE AS VARCHAR), '') + ', EXP DATE = ' + ISNULL(CAST(@Ad_Expiration_DATE AS VARCHAR), '');

       INSERT DISH_Y1
              (CasePayorMCI_IDNO,
               Sequence_NUMB,
               TypeHold_CODE,
               SourceHold_CODE,
               ReasonHold_CODE,
               Effective_DATE,
               Expiration_DATE,
               EventGlobalBeginSeq_NUMB,
               EventGlobalEndSeq_NUMB,
               BeginValidity_DATE,
               EndValidity_DATE)
       VALUES ( @An_CasePayorMCI_IDNO,			--CasePayorMCI_IDNO
                @Ln_Seq_NUMB,					--Sequence_NUMB
                @Ac_TypeHold_CODE,				--TypeHold_CODE
                @Ac_SourceHold_CODE,			--SourceHold_CODE
                @Ac_ReasonHoldDist_CODE,		--ReasonHold_CODE
                @Ad_Effective_DATE,				--Effective_DATE
                @Ad_Expiration_DATE,			--Expiration_DATE
                @Ln_EventGlobalSeq_NUMB,		--EventGlobalBeginSeq_NUMB
                @Ln_Zero_NUMB,					--EventGlobalEndSeq_NUMB
                @Ld_Run_DATE,					--BeginValidity_DATE
                @Ld_High_DATE);					--EndValidity_DATE

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF (@Ln_RowCount_QNTY = @Ln_Zero_NUMB)
        BEGIN
         SET @As_DescriptionError_TEXT = 'INSERT DISH_Y1 FAILED';
         RAISERROR (50001,16,1);
        END
      END -- END of Action Code Add, Change , Extend     
    END -- END if Distribution hold need to be changed               

   SET @Ln_Rcth_QNTY = 0;

   IF (@Ad_Effective_DATE <= @Ld_Today_DATE)
    BEGIN
     -- if the payor receipt of hold end date the Receipt  
     IF (@Ac_TypeHold_CODE = @Lc_TypeHoldPostingPayor_CODE)
      BEGIN
       SET @Ln_PayorMCI_IDNO = @An_CasePayorMCI_IDNO;
       SET @Ls_Sql_TEXT = ' SELECT  RCTH_Y1 P ';
       SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', UDC = ' + ISNULL(@Ac_ReasonHoldDist_CODE, '');

       -- if the receipt of hold end date the Receipt                        
       IF EXISTS (SELECT TOP 1 1
                    FROM RCTH_Y1 R
                   WHERE R.PayorMCI_IDNO = @Ln_PayorMCI_IDNO
                     AND R.SourceReceipt_CODE = (CASE @Ac_SourceHold_CODE
                                                  WHEN @Lc_SourceHold_CODE
                                                   THEN R.SourceReceipt_CODE
                                                  ELSE @Ac_SourceHold_CODE
                                                 END)
                     AND R.Distribute_DATE = @Ld_Low_DATE
                     AND R.EndValidity_DATE = @Ld_High_DATE
                     AND (R.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                           OR (R.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                               AND R.ReasonStatus_CODE = @Ac_ReasonHoldDist_CODE)))
        BEGIN
         SET @Ln_Rcth_QNTY = 1;
         SET @Ls_Sql_TEXT = ' SELECT  RCTH_Y1 P ';
         SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '');

         UPDATE RCTH_Y1
            SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
                EndValidity_DATE = @Ld_Run_DATE
          WHERE PayorMCI_IDNO = @Ln_PayorMCI_IDNO
            AND SourceReceipt_CODE = (CASE @Ac_SourceHold_CODE
                                       WHEN @Lc_SourceHold_CODE
                                        THEN SourceReceipt_CODE
                                       ELSE @Ac_SourceHold_CODE
                                      END)
            AND Distribute_DATE = @Ld_Low_DATE
            AND EndValidity_DATE = @Ld_High_DATE
            AND (StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                  OR (StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                      AND ReasonStatus_CODE = @Ac_ReasonHoldDist_CODE));

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF (@Ln_RowCount_QNTY = @Ln_Zero_NUMB)
          BEGIN
           SET @As_DescriptionError_TEXT = ' UPDATE RCTH_Y1 P FAILED ';
           RAISERROR (50001,16,1);
          END
        END --END of Exists Check
      END -- END if the payor receipt of hold end date the Receipt                        
     ELSE IF (@Ac_TypeHold_CODE = @Lc_TypeHoldPostingCase_CODE)
      -- END if the case receipt of hold end date the Receipt  
      BEGIN
       SET @Ls_Sql_TEXT = ' SELECT CMEM_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '');

       SELECT @Ln_PayorMCI_IDNO = CM.MemberMci_IDNO
         FROM CMEM_Y1 CM
        WHERE CM.Case_IDNO = @An_CasePayorMCI_IDNO
          AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
          AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

       SET @Ls_Sql_TEXT = ' SELECT RCTH_Y1 C ';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', UDC = ' + ISNULL(@Ac_ReasonHoldDist_CODE, '');

       IF EXISTS (SELECT TOP 1 1
                    FROM RCTH_Y1 R
                   WHERE R.PayorMCI_IDNO = @Ln_PayorMCI_IDNO
                     AND R.Case_IDNO = @An_CasePayorMCI_IDNO
                     AND R.SourceReceipt_CODE = (CASE @Ac_SourceHold_CODE
                                                  WHEN @Lc_SourceHold_CODE
                                                   THEN R.SourceReceipt_CODE
                                                  ELSE @Ac_SourceHold_CODE
                                                 END)
                     AND R.Distribute_DATE = @Ld_Low_DATE
                     AND R.EndValidity_DATE = @Ld_High_DATE
                     AND (R.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                           OR (R.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                               AND R.ReasonStatus_CODE = @Ac_ReasonHoldDist_CODE)))
        BEGIN
         SET @Ln_Rcth_QNTY = 1;
         SET @Ls_Sql_TEXT = ' UPDATE RCTH_Y1 C ';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL (CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', UDC = ' + ISNULL(@Ac_ReasonHoldDist_CODE, '');

         UPDATE RCTH_Y1
            SET EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
                EndValidity_DATE = @Ld_Run_DATE
          WHERE PayorMCI_IDNO = @Ln_PayorMCI_IDNO
            AND Case_IDNO = @An_CasePayorMCI_IDNO
            AND SourceReceipt_CODE = (CASE @Ac_SourceHold_CODE
                                       WHEN @Lc_SourceHold_CODE
                                        THEN SourceReceipt_CODE
                                       ELSE @Ac_SourceHold_CODE
                                      END)
            AND Distribute_DATE = @Ld_Low_DATE
            AND EndValidity_DATE = @Ld_High_DATE
            AND (StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                  OR (StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                      AND ReasonStatus_CODE = @Ac_ReasonHoldDist_CODE));

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF (@Ln_RowCount_QNTY = @Ln_Zero_NUMB)
          BEGIN
           SET @As_DescriptionError_TEXT = ' UPDATE RCTH_Y1 C FAILED ';
           RAISERROR (50001,16,1);
          END
        END --END of Exists Check
      END -- END if the case receipt of hold end date the Receipt  
    END -- END of Effective DATE  

   -- When Receipt Updated         
   IF(@Ln_Rcth_QNTY > 0)
    BEGIN
     SET @Ls_Sql_TEXT = ' SELECT RCTH_Y1 ';
     SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');

     DECLARE rcth_cur CURSOR LOCAL FORWARD_ONLY FOR
      SELECT R.Batch_DATE,
             R.SourceBatch_CODE,
             R.Batch_NUMB,
             R.SeqReceipt_NUMB,
             R.SourceReceipt_CODE,
             R.TypeRemittance_CODE,
             R.TypePosting_CODE,
             R.Case_IDNO,
             R.PayorMCI_IDNO,
             R.Receipt_AMNT,
             R.ToDistribute_AMNT,
             R.Fee_AMNT,
             R.Employer_IDNO,
             R.Fips_CODE,
             R.Check_DATE,
             R.CheckNo_Text,
             R.Receipt_DATE,
             R.Distribute_DATE,
             R.Tanf_CODE,
             R.TaxJoint_CODE,
             R.TaxJoint_NAME,
             CASE @Ad_Expiration_DATE
              WHEN @Ld_Run_DATE
               THEN @Lc_StatusReceiptIdentified_CODE
              ELSE @Lc_StatusReceiptHeld_CODE
             END AS StatusReceipt_CODE,
             CASE @Ad_Expiration_DATE
              WHEN @Ld_Run_DATE
               THEN @Lc_Space_CODE
              ELSE @Ac_ReasonHoldDist_CODE
             END AS ReasonStatus_CODE,
             R.BackOut_INDC,
             R.ReasonBackOut_CODE,
             R.Refund_DATE,
             R.RefundRecipient_ID,
             R.RefundRecipient_CODE
        FROM RCTH_Y1 R
       WHERE R.PayorMCI_IDNO = @Ln_PayorMCI_IDNO
         AND R.EndValidity_DATE = @Ld_Run_DATE
         AND R.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

     SET @Ls_Sql_TEXT = ' OPEN RCTH_CUR ';

     OPEN rcth_cur;

     SET @Ls_Sql_TEXT = ' FETCH RCTH_CUR  # 1';

     FETCH NEXT FROM rcth_cur INTO @Ld_RcthCur_Batch_DATE, @Lc_RcthCur_SourceBatch_CODE, @Ln_RcthCur_Batch_NUMB, @Ln_RcthCur_SeqReceipt_NUMB, @Lc_RcthCur_SourceReceipt_CODE, @Lc_RcthCur_TypeRemittance_CODE, @Lc_RcthCur_TypePosting_CODE, @Lc_RcthCur_OfficePosting_CODE, @Ln_RcthCur_Case_IDNO, @Ln_RcthCur_PayorMCI_IDNO, @Ln_RcthCur_Receipt_AMNT, @Ln_RcthCur_ToDistribute_AMNT, @Ln_RcthCur_Fee_AMNT, @Ln_RcthCur_Employer_IDNO, @Lc_RcthCur_Fips_CODE, @Ld_RcthCur_Check_DATE, @Ln_RcthCur_Check_NUMB, @Ld_RcthCur_Receipt_DATE, @Ld_RcthCur_Distribute_DATE, @Lc_RcthCur_Tanf_CODE, @Lc_RcthCur_TaxJoint_CODE, @Lc_RcthCur_TaxJoint_NAME, @Lc_RcthCur_StatusReceipt_CODE, @Lc_RcthCur_ReasonStatus_CODE, @Lc_RcthCur_BackOut_INDC, @Lc_RcthCur_ReasonBackOut_CODE, @Ld_RcthCur_Refund_DATE, @Ld_RcthCur_Release_DATE, @Lc_RcthCur_RefundRecipient_ID, @Lc_RcthCur_RefundRecipient_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

     WHILE (@Ln_FetchStatus_QNTY = 0)
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT RCTH_Y1 ';
       SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(@Ln_RcthCur_PayorMCI_IDNO, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');

       IF EXISTS (SELECT 1
                    FROM RCTH_Y1 R
                   WHERE R.Batch_DATE = @Ld_RcthCur_Batch_DATE
                     AND R.SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
                     AND R.Batch_NUMB = @Ln_RcthCur_Batch_NUMB
                     AND R.SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
                     AND R.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB
                     AND R.StatusReceipt_CODE = @Lc_RcthCur_StatusReceipt_CODE
                     AND R.ReasonStatus_CODE = @Lc_RcthCur_ReasonStatus_CODE
                     AND R.EndValidity_DATE = @Ld_High_DATE)
        BEGIN
         SET @Ls_Sql_TEXT = ' UPDATE RCTH_Y1 1 ';

         UPDATE RCTH_Y1
            SET ToDistribute_AMNT = ToDistribute_AMNT + @Ln_RcthCur_ToDistribute_AMNT
          WHERE Batch_DATE = @Ld_RcthCur_Batch_DATE
            AND SourceBatch_CODE = @Lc_RcthCur_SourceBatch_CODE
            AND Batch_NUMB = @Ln_RcthCur_Batch_NUMB
            AND SeqReceipt_NUMB = @Ln_RcthCur_SeqReceipt_NUMB
            AND EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB
            AND StatusReceipt_CODE = @Lc_RcthCur_StatusReceipt_CODE
            AND ReasonStatus_CODE = @Lc_RcthCur_ReasonStatus_CODE
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF (@Ln_RowCount_QNTY = @Ln_Zero_NUMB)
          BEGIN
           SET @As_DescriptionError_TEXT = ' UPDATE RCTH_Y1 1 FAILED ';

           RAISERROR (50001,16,1);
          END
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = ' INSERT RCTH_Y1 1 ';

         INSERT INTO RCTH_Y1
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
                      RefundRecipient_ID,
                      RefundRecipient_CODE,
                      BeginValidity_DATE,
                      EndValidity_DATE,
                      EventGlobalBeginSeq_NUMB,
                      EventGlobalEndSeq_NUMB)
              VALUES ( @Ld_RcthCur_Batch_DATE,				--Batch_DATE
                       @Lc_RcthCur_SourceBatch_CODE,		--SourceBatch_CODE
                       @Ln_RcthCur_Batch_NUMB,				--Batch_NUMB
                       @Ln_RcthCur_SeqReceipt_NUMB,			--SeqReceipt_NUMB
                       @Lc_RcthCur_SourceReceipt_CODE,		--SourceReceipt_CODE
                       @Lc_RcthCur_TypeRemittance_CODE,		--TypeRemittance_CODE
                       @Lc_RcthCur_TypePosting_CODE,		--TypePosting_CODE
                       @Ln_RcthCur_Case_IDNO,				--Case_IDNO
                       @Ln_RcthCur_PayorMCI_IDNO,			--PayorMCI_IDNO
                       @Ln_RcthCur_Receipt_AMNT,			--Receipt_AMNT
                       @Ln_RcthCur_ToDistribute_AMNT,		--ToDistribute_AMNT
                       @Ln_RcthCur_Fee_AMNT,				--Fee_AMNT
                       @Ln_RcthCur_Employer_IDNO,			--Employer_IDNO
                       @Lc_RcthCur_Fips_CODE,				--Fips_CODE
                       @Ld_RcthCur_Check_DATE,				--Check_DATE
                       @Ln_RcthCur_Check_NUMB,				--CheckNo_Text
                       @Ld_RcthCur_Receipt_DATE,			--Receipt_DATE
                       @Ld_RcthCur_Distribute_DATE,			--Distribute_DATE
                       @Lc_RcthCur_Tanf_CODE,				--Tanf_CODE
                       @Lc_RcthCur_TaxJoint_CODE,			--TaxJoint_CODE
                       @Lc_RcthCur_TaxJoint_NAME,			--TaxJoint_NAME
                       @Lc_RcthCur_StatusReceipt_CODE,		--StatusReceipt_CODE
                       @Lc_RcthCur_ReasonStatus_CODE,		--ReasonStatus_CODE
                       @Lc_RcthCur_BackOut_INDC,			--BackOut_INDC
                       @Lc_RcthCur_ReasonBackOut_CODE,		--ReasonBackOut_CODE
                       @Ld_RcthCur_Refund_DATE,				--Refund_DATE
                       @Ad_Expiration_DATE,					--Release_DATE
                       @Lc_RcthCur_RefundRecipient_ID,		--RefundRecipient_ID
                       @Lc_RcthCur_RefundRecipient_CODE,	--RefundRecipient_CODE
                       @Ld_Run_DATE,						--BeginValidity_DATE
                       @Ld_High_DATE,						--EndValidity_DATE
                       @Ln_EventGlobalSeq_NUMB,				--EventGlobalBeginSeq_NUMB
                       @Ln_Zero_NUMB );						--EventGlobalEndSeq_NUMB

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF (@Ln_RowCount_QNTY = @Ln_Zero_NUMB)
          BEGIN
           SET @As_DescriptionError_TEXT = ' INSERT RCTH_Y1 1 FAILED ';
           RAISERROR (50001,16,1);
          END
        END

       SET @Ls_Sql_TEXT = ' FETCH RCTH_CUR  # 2';

       FETCH NEXT FROM rcth_cur INTO @Ld_RcthCur_Batch_DATE, @Lc_RcthCur_SourceBatch_CODE, @Ln_RcthCur_Batch_NUMB, @Ln_RcthCur_SeqReceipt_NUMB, @Lc_RcthCur_SourceReceipt_CODE, @Lc_RcthCur_TypeRemittance_CODE, @Lc_RcthCur_TypePosting_CODE, @Lc_RcthCur_OfficePosting_CODE, @Ln_RcthCur_Case_IDNO, @Ln_RcthCur_PayorMCI_IDNO, @Ln_RcthCur_Receipt_AMNT, @Ln_RcthCur_ToDistribute_AMNT, @Ln_RcthCur_Fee_AMNT, @Ln_RcthCur_Employer_IDNO, @Lc_RcthCur_Fips_CODE, @Ld_RcthCur_Check_DATE, @Ln_RcthCur_Check_NUMB, @Ld_RcthCur_Receipt_DATE, @Ld_RcthCur_Distribute_DATE, @Lc_RcthCur_Tanf_CODE, @Lc_RcthCur_TaxJoint_CODE, @Lc_RcthCur_TaxJoint_NAME, @Lc_RcthCur_StatusReceipt_CODE, @Lc_RcthCur_ReasonStatus_CODE, @Lc_RcthCur_BackOut_INDC, @Lc_RcthCur_ReasonBackOut_CODE, @Ld_RcthCur_Refund_DATE, @Ld_RcthCur_Release_DATE, @Lc_RcthCur_RefundRecipient_ID, @Lc_RcthCur_RefundRecipient_CODE;

       SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
      END -- END OF WHILE LOOP                   
     CLOSE rcth_cur;

     DEALLOCATE rcth_cur;

     SET @Ls_Sql_TEXT = ' UPDATE VRCTH_H CTE';
     SET @Ls_Sqldata_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '');

     -- Begin  Update RCTH for Hold
     WITH Dish_CTE
          AS (SELECT DH.CasePayorMCI_IDNO,
                     DH.TypeHold_CODE,
                     DH.Expiration_DATE,
                     DH.ReasonHold_CODE
                FROM DISH_Y1 DH
               WHERE (DH.CasePayorMCI_IDNO = @Ln_PayorMCI_IDNO
                       OR DH.CasePayorMCI_IDNO IN (SELECT CM.Case_IDNO
                                                     FROM CMEM_Y1 CM
                                                    WHERE CM.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                                                      AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                      AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE))
                 AND DH.Effective_DATE <= @Ld_Run_DATE
                 AND DH.Expiration_DATE > @Ld_Run_DATE
                 AND DH.EndValidity_DATE = @Ld_High_DATE)
     UPDATE RCTH_Y1
        SET StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE,
            ReasonStatus_CODE = DH.ReasonHold_CODE,
            Release_DATE = DH.Expiration_DATE
       FROM RCTH_Y1 R,
            Dish_CTE DH
      WHERE R.PayorMCI_IDNO = @Ln_PayorMCI_IDNO
        AND LTRIM(RTRIM(R.Case_IDNO)) = (CASE
                                          WHEN DH.TypeHold_CODE = @Lc_TypeHoldPostingCase_CODE
                                           THEN DH.CasePayorMCI_IDNO
                                          ELSE ''
                                         END)
        AND R.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
        AND R.Distribute_DATE = @Ld_Low_DATE
        AND R.BeginValidity_DATE = @Ld_Run_DATE
        AND R.EndValidity_DATE = @Ld_High_DATE
        AND R.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF (@Ln_RowCount_QNTY = @Ln_Zero_NUMB)
      BEGIN
       SET @As_DescriptionError_TEXT = 'UPDATE VRCTH_H CTE FAILED';
       RAISERROR (50001,16,1);
      END

     -- End  Update RCTH for Hold  
     SET @Ls_Sql_TEXT = 'INSERT UNOT_Y1';
     SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');

     INSERT UNOT_Y1
            (EventGlobalSeq_NUMB,
             DescriptionNote_TEXT,
             EventGlobalApprovalSeq_NUMB)
     VALUES (@Ln_EventGlobalSeq_NUMB,		--EventGlobalSeq_NUMB
             @As_DescriptionNote_TEXT,		--DescriptionNote_TEXT
             @Ln_Zero_NUMB);				--EventGlobalApprovalSeq_NUMB

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF (@Ln_RowCount_QNTY = @Ln_Zero_NUMB)
      BEGIN
       SET @As_DescriptionError_TEXT = 'INSERT UNOT_Y1 FAILED';
       RAISERROR (50001,16,1);
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END -- END Recept Update
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ActionExtend_CODE;
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailure_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
	
	SET @Ln_Error_NUMB = ERROR_NUMBER();  
	SET @Ln_ErrorLine_NUMB = ERROR_LINE(); 
		   
	--Check for Exception information to log the description text based on the error
	EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION 
	@As_Procedure_NAME		  = @Ls_Routine_TEXT,  
	@As_ErrorMessage_TEXT	  = @Ls_ErrorMessage_TEXT,
	@As_Sql_TEXT			  = @Ls_Sql_TEXT,
	@As_Sqldata_TEXT	      = @Ls_Sqldata_TEXT,
	@An_Error_NUMB			  = @Ln_Error_NUMB,
	@An_ErrorLine_NUMB		  = @Ln_ErrorLine_NUMB,  
	@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT      OUTPUT; 

  END CATCH
 END 

GO
