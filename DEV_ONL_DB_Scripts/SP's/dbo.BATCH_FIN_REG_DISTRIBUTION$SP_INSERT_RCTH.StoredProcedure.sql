/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH
Programmer Name 	: IMP Team
Description			: This Procedure Inserts/Updates the RCTH_Y1 (RCTH_Y1) Based on the Value_AMNT it got Distributed
					  and/or the Amount Value that went on Hold.
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
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH]
 @Ad_Batch_DATE                 DATE,
 @Ac_SourceBatch_CODE           CHAR(3),
 @An_Batch_NUMB                 NUMERIC(4),
 @An_SeqReceipt_NUMB            NUMERIC(6),
 @Ac_SourceReceipt_CODE         CHAR(2),
 @An_Case_IDNO                  NUMERIC(6),
 @An_PayorMCI_IDNO              NUMERIC(10),
 @Ad_Receipt_DATE               DATE,
 @Ac_TypePosting_CODE           CHAR(1),
 @Ac_ReasonStatus_CODE          CHAR(4),
 @An_Receipt_AMNT               NUMERIC(11, 2),
 @An_Remaining_AMNT             NUMERIC (11, 2),
 @An_EventGlobalReceiptSeq_NUMB NUMERIC (19),
 @An_EventGlobalSeq_NUMB        NUMERIC(19),
 @Ad_ReleaseIn_DATE             DATETIME2,
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT,
 @Ad_Process_DATE               DATE OUTPUT,
 @Ac_ReleasedFrom_CODE          CHAR(4) OUTPUT,
 @Ad_Release_DATE               DATE OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Li_ReceiptOnHold1420_NUMB          INT = 1420,
           @Lc_No_INDC                         CHAR(1) = 'N',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_TypePostingCase_CODE            CHAR(1) = 'C',
           @Lc_TypePostingPayor_CODE           CHAR(1) = 'P',
           @Lc_CaseRelationshipNcp_TEXT        CHAR(1) = 'A',
           @Lc_CaseRelationshipPutFather_TEXT  CHAR(1) = 'P',
           @Lc_CaseMemberStatusActive_CODE     CHAR(1) = 'A',
           @Lc_StatusReceiptIdentified_CODE    CHAR(1) = 'I',
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_StatusReceiptHeld_CODE          CHAR(1) = 'H',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_NegPosCloseRemedy_CODE          CHAR(1) = 'N',
           @Lc_LsupInsertFail_INDC             CHAR(1) = 'L',
           @Lc_ObleNotFound_TEXT               CHAR(1) = 'O',
           @Lc_CaseLevelHold_CODE              CHAR(1) = 'C',
           @Lc_PayorLevelHold_CODE             CHAR(1) = 'P',
           @Lc_SourceReceiptLevyFidm_CODE      CHAR(2) = 'FD',
           @Lc_SourceReceiptCsln_CODE          CHAR(2) = 'WC',
           @Lc_DistributionHoldSrc_CODE        CHAR(2) = 'DH',
           @Lc_TypeChangeFd_CODE               CHAR(2) = 'FD',
           @Lc_TypeChangePd_CODE               CHAR(2) = 'PD',
           @Lc_HoldReasonStatusSner_CODE       CHAR(4) = 'SNER',
           @Lc_HoldReasonStatusSnax_CODE       CHAR(4) = 'SNAX',
           @Lc_HoldReasonStatusSnfx_CODE       CHAR(4) = 'SNFX',
           @Lc_ActivityMajorFidm_CODE          CHAR(4) = 'FIDM',
           @Lc_RemedyStatusStart_CODE          CHAR(4) = 'STRT',
           @Lc_ActivityMajorCsln_CODE          CHAR(4) = 'CSLN',
           @Lc_ActivityMinorMorfd_CODE         CHAR(5) = 'MORFD',
           @Lc_ActivityMinorRfins_CODE         CHAR(5) = 'FINS',
           @Lc_ProcessRdist_ID                 CHAR(10) = 'DEB0560',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Lc_TypeEntityCase_CODE             CHAR(30) = 'CASE',
           @Lc_TypeEntityRctno_CODE            CHAR(30) = 'RCTNO',
           @Lc_TypeEntityRctdt_CODE            CHAR(30) = 'RCTDT',
           @Lc_TypeEntityPayor_CODE            CHAR(30) = 'PAYOR',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_INSERT_RCTH',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Hold_AMNT                NUMERIC(11,2) = 0,
           @Ln_Error_NUMB               NUMERIC(11),
           @Ln_ErrorLine_NUMB           NUMERIC(11),
           @Ln_EventGlobalHoldSeq_NUMB  NUMERIC(19,0),
           @Ln_EventGlobalSeq_NUMB      NUMERIC(19),
           @Li_FetchStatus_QNTY         SMALLINT,
           @Li_Rowcount_QNTY            SMALLINT,
           @Lc_TypePosting_CODE         CHAR(1),
           @Lc_Msg_CODE                 CHAR(1),
           @Lc_ReasonStatus_CODE        CHAR(4),
           @Lc_Receipt_TEXT             CHAR(30),
           @Ls_Sql_TEXT                 VARCHAR(100) = '',
           @Ls_Sqldata_TEXT             VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT        VARCHAR(2000);
  DECLARE  @Ln_CslnDmnrCur_OrderSeq_NUMB  NUMERIC(2),
           @Ln_FidmDmnrCur_OrderSeq_NUMB  NUMERIC(2),
           @Ln_PaidCur_Case_IDNO          NUMERIC(6),
           @Ln_CslnDmnrCur_Case_IDNO      NUMERIC(6),
           @Ln_FidmDmnrCur_Case_IDNO      NUMERIC(6),
           @Ln_PaidCur_Receipt_AMNT       NUMERIC(11,2),
           @Lc_PaidCur_Flag_INDC          CHAR(1);
          
  DECLARE Paid_CUR INSENSITIVE CURSOR FOR
   SELECT a.Case_IDNO,
          a.Flag_INDC,
          SUM (a.ArrPaid_AMNT) AS Receipt_AMNT
     FROM (SELECT b.Case_IDNO,
                  'L' AS Flag_INDC,
                  b.ArrPaid_AMNT
             FROM #Tpaid_P1 b
            WHERE ISNULL (b.LsupInsert_INDC, 'N') = 'N'
              AND b.ArrPaid_AMNT > 0
           UNION ALL
           SELECT c.Case_IDNO,
                  'O' AS Flag_INDC,
                  c.ArrPaid_AMNT
             FROM #Tpaid_P1 c
            WHERE c.ObleFound_INDC = 'N'
              AND c.ArrPaid_AMNT > 0) AS a
    GROUP BY a.Case_IDNO,
             a.Flag_INDC;
             
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   -- When a manually held receipt is released systematically/manually then the Receipt should not be held with the Same UDC Code and should get distributed when there are no other Hold exists for the Payor/Case.
   IF @An_Case_IDNO = 0
    BEGIN
     SET @Lc_TypePosting_CODE = @Lc_TypePostingPayor_CODE;
    END
   ELSE
    BEGIN
     IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
        AND @Ac_ReleasedFrom_CODE IN (@Lc_HoldReasonStatusSnfx_CODE, @Lc_HoldReasonStatusSnax_CODE)
      BEGIN
       SET @Lc_TypePosting_CODE = @Lc_TypePostingPayor_CODE;
      END
     ELSE
      BEGIN
       SET @Lc_TypePosting_CODE = @Lc_TypePostingCase_CODE;
      END
    END

   SET @Lc_Receipt_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB);
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 4';   
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
    @Ac_Process_ID              = @Lc_ProcessRdist_ID,
    @Ad_EffectiveEvent_DATE     = @Ad_Process_DATE,
    @Ac_Note_INDC               = @Lc_No_INDC,
    @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalHoldSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   IF @An_Receipt_AMNT = @An_Remaining_AMNT
    BEGIN
     SET @Ln_EventGlobalSeq_NUMB = @Ln_EventGlobalHoldSeq_NUMB;
    END
   ELSE
    BEGIN
     SET @Ln_EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;
    END

   SET @Ls_Sql_TEXT = 'UPDATE_RCTH_Y1 ';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalReceiptSeq_NUMB AS VARCHAR ),'');

   UPDATE RCTH_Y1
      SET EndValidity_DATE = @Ad_Process_DATE,
          EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
    WHERE Batch_DATE = @Ad_Batch_DATE
      AND SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND Batch_NUMB = @An_Batch_NUMB
      AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND (EndValidity_DATE = @Ld_High_DATE
            OR EndValidity_DATE = @Ad_Process_DATE)
      AND EventGlobalBeginSeq_NUMB = @An_EventGlobalReceiptSeq_NUMB;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'UPDATE_RCTH_Y1_FAILED';

     RAISERROR (50001,16,1);
    END

   IF @Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
    BEGIN
    SET @Ls_Sql_TEXT = 'SELECT_#Tpaid_P1 - 1';	
    SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', ObleFound_INDC = ' + ISNULL(@Lc_No_INDC,'');

    SELECT @Ln_Hold_AMNT = ISNULL (SUM (a.ArrPaid_AMNT), 0)
      FROM #Tpaid_P1 a
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.ArrPaid_AMNT > 0
       AND (ISNULL (a.LsupInsert_INDC, @Lc_No_INDC) = @Lc_No_INDC
             OR a.ObleFound_INDC = @Lc_No_INDC);
END
   ELSE
    BEGIN
     IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
      BEGIN
        SET @Ls_Sql_TEXT = 'SELECT_#Tpaid_P1 - 2';		
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_PayorMCI_IDNO AS VARCHAR ),'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE,'')+ ', ObleFound_INDC = ' + ISNULL(@Lc_No_INDC,'');

        SELECT @Ln_Hold_AMNT = ISNULL (SUM (t.ArrPaid_AMNT), 0)
        FROM #Tpaid_P1 t
       WHERE t.Case_IDNO IN (SELECT a.Case_IDNO
                               FROM CMEM_Y1 a
                              WHERE a.MemberMci_IDNO = @An_PayorMCI_IDNO
                                AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_TEXT, @Lc_CaseRelationshipPutFather_TEXT)
                                AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
         AND (ISNULL (t.LsupInsert_INDC, @Lc_No_INDC) = @Lc_No_INDC
               OR t.ObleFound_INDC = @Lc_No_INDC)
         AND t.ArrPaid_AMNT > 0;
END
    END

   IF (@An_Receipt_AMNT - (ISNULL (@An_Remaining_AMNT, 0) + @Ln_Hold_AMNT)) > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1 - 1';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptIdentified_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL('0','')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Release_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'');

     INSERT RCTH_Y1
            (Batch_DATE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceBatch_CODE,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             PayorMCI_IDNO,
             Case_IDNO,
             Employer_IDNO,
             Fips_CODE,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Receipt_DATE,
             Distribute_DATE,
             Check_DATE,
             CheckNo_TEXT,
             TaxJoint_CODE,
             Tanf_CODE,
             BackOut_INDC,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             TaxJoint_NAME,
             Fee_AMNT,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             ReasonBackOut_CODE,
             Release_DATE,
             Refund_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_ID,
             RefundRecipient_CODE)
     SELECT @Ad_Batch_DATE AS Batch_DATE,
            @An_Batch_NUMB AS Batch_NUMB,
            @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
            @Ac_SourceBatch_CODE AS SourceBatch_CODE,
            r.SourceReceipt_CODE,
            r.TypeRemittance_CODE,
            r.TypePosting_CODE,
            r.PayorMCI_IDNO,
            r.Case_IDNO,
            r.Employer_IDNO,
            r.Fips_CODE,
            r.Receipt_AMNT,
            (@An_Receipt_AMNT - (ISNULL (@An_Remaining_AMNT, 0) + @Ln_Hold_AMNT)) AS ToDistribute_AMNT,
            r.Receipt_DATE,
            @Ad_Process_DATE AS Distribute_DATE,
            r.Check_DATE,
            r.CheckNo_TEXT,
            r.TaxJoint_CODE,
            r.Tanf_CODE,
            r.BackOut_INDC,
            @Lc_StatusReceiptIdentified_CODE AS StatusReceipt_CODE,
            @Lc_Space_TEXT AS ReasonStatus_CODE,
            r.TaxJoint_NAME,
            r.Fee_AMNT,
            @Ad_Process_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            @An_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
            0 AS EventGlobalEndSeq_NUMB,
            @Lc_Space_TEXT AS ReasonBackOut_CODE,
            @Ad_Process_DATE AS Release_DATE,
            r.Refund_DATE,
            r.Case_IDNO,
            r.RefundRecipient_ID,
            r.RefundRecipient_CODE
       FROM RCTH_Y1 r
      WHERE r.Batch_DATE = @Ad_Batch_DATE
        AND r.SourceBatch_CODE = @Ac_SourceBatch_CODE
        AND r.Batch_NUMB = @An_Batch_NUMB
        AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND r.EventGlobalBeginSeq_NUMB = @An_EventGlobalReceiptSeq_NUMB;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_RCTH_Y11 FAILED';

       RAISERROR (50001,16,1);
      END
    END

   -- Paid_CUR
   SET @Ls_Sql_TEXT = 'OPEN Paid_CUR';
   SET @Ls_Sqldata_TEXT = '';
   
   OPEN Paid_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Paid_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   
   FETCH Paid_CUR INTO @Ln_PaidCur_Case_IDNO, @Lc_PaidCur_Flag_INDC, @Ln_PaidCur_Receipt_AMNT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Cursor Started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     IF @Lc_PaidCur_Flag_INDC = @Lc_ObleNotFound_TEXT
      BEGIN
       SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSner_CODE;
      END
     ELSE
      BEGIN
       IF @Lc_PaidCur_Flag_INDC = @Lc_LsupInsertFail_INDC
        BEGIN
         
         BEGIN

          SET @Ls_Sql_TEXT = 'SELECT_DISH_Y1';
          SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(CAST(@Ln_PaidCur_Case_IDNO AS VARCHAR),'') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityCase_CODE,'') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'');

          SELECT TOP 1 @Lc_ReasonStatus_CODE = ISNULL (a.ReasonHold_CODE, @Lc_Space_TEXT),
                         @Ad_Release_DATE = a.Expiration_DATE
            FROM (SELECT l.ReasonHold_CODE,
                         l.Expiration_DATE,
                         l.SourceHold_CODE
                    FROM DISH_Y1 l
                   WHERE ((l.CasePayorMCI_IDNO = @An_PayorMCI_IDNO
                           AND TypeHold_CODE = @Lc_PayorLevelHold_CODE
                           AND @Ac_TypePosting_CODE = @Lc_PayorLevelHold_CODE
                           AND l.ReasonHold_CODE <> @Ac_ReleasedFrom_CODE)
                           OR (l.CasePayorMCI_IDNO = @Ln_PaidCur_Case_IDNO
                               AND TypeHold_CODE = @Lc_CaseLevelHold_CODE
                               AND @Ac_TypePosting_CODE = @Lc_CaseLevelHold_CODE
                               AND l.ReasonHold_CODE <> @Ac_ReleasedFrom_CODE)
                           OR (l.CasePayorMCI_IDNO = @An_PayorMCI_IDNO
                               AND TypeHold_CODE = @Lc_PayorLevelHold_CODE
                               AND @Ac_TypePosting_CODE = @Lc_CaseLevelHold_CODE)
                           OR (l.CasePayorMCI_IDNO = @Ln_PaidCur_Case_IDNO
                               AND TypeHold_CODE = @Lc_CaseLevelHold_CODE
                               AND @Ac_TypePosting_CODE = @Lc_PayorLevelHold_CODE))
                     AND l.SourceHold_CODE IN (@Ac_SourceReceipt_CODE, @Lc_DistributionHoldSrc_CODE)
                     AND @Ad_Process_DATE >= l.Effective_DATE
                     AND @Ad_Process_DATE < l.Expiration_DATE
                     AND l.EndValidity_DATE = @Ld_High_DATE) a
           ORDER BY CASE a.ReasonHold_CODE
                     WHEN @Ac_ReleasedFrom_CODE
                      THEN 1
                     ELSE 2
                    END DESC,
                    a.Expiration_DATE,
                    CASE a.SourceHold_CODE
                     WHEN @Lc_DistributionHoldSrc_CODE
                      THEN 1
                     ELSE 2
                    END DESC;
          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          IF @Li_Rowcount_QNTY = 0
           BEGIN
            SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonStatusSner_CODE;
            SET @Ad_Release_DATE = @Ld_High_DATE;
           END
         END
        END
      END

     BEGIN
      SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1 1';      
      SET @Ls_Sqldata_TEXT = ' Entity_ID - Case_IDNO = ' + CAST(@Ln_PaidCur_Case_IDNO AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalHoldSeq_NUMB AS VARCHAR) + ', TypeEntity_CODE = ' + @Lc_TypeEntityCase_CODE + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR);

      INSERT ESEM_Y1
             (Entity_ID,
              EventGlobalSeq_NUMB,
              TypeEntity_CODE,
              EventFunctionalSeq_NUMB)
      VALUES (CAST(@Ln_PaidCur_Case_IDNO AS VARCHAR),      --Entity_ID
              @Ln_EventGlobalHoldSeq_NUMB,      --EventGlobalSeq_NUMB
              @Lc_TypeEntityCase_CODE,      --TypeEntity_CODE
              @Li_ReceiptOnHold1420_NUMB  --EventFunctionalSeq_NUMB
			 );

      SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1 2';
      SET @Ls_Sqldata_TEXT = ' Entity_ID - Receipt_TEXT = ' + CAST(@Lc_Receipt_TEXT AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalHoldSeq_NUMB AS VARCHAR) + ', TypeEntity_CODE = ' + @Lc_TypeEntityRctno_CODE + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR);

      INSERT ESEM_Y1
             (Entity_ID,
              EventGlobalSeq_NUMB,
              TypeEntity_CODE,
              EventFunctionalSeq_NUMB)
      VALUES (@Lc_Receipt_TEXT,      --Entity_ID
              @Ln_EventGlobalHoldSeq_NUMB,      --EventGlobalSeq_NUMB
              @Lc_TypeEntityRctno_CODE,      --TypeEntity_CODE
              @Li_ReceiptOnHold1420_NUMB  --EventFunctionalSeq_NUMB
  
		);

      SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1 3';      
      SET @Ls_Sqldata_TEXT = ' Entity_ID - Receipt_TEXT = ' + CAST(REPLACE(CONVERT(VARCHAR(10), @Ad_Receipt_DATE, 101), '/', '') AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalHoldSeq_NUMB AS VARCHAR) + ', TypeEntity_CODE = ' + @Lc_TypeEntityRctdt_CODE + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR);

      INSERT ESEM_Y1
             (Entity_ID,
              EventGlobalSeq_NUMB,
              TypeEntity_CODE,
              EventFunctionalSeq_NUMB)
      VALUES ( REPLACE(CONVERT(VARCHAR(10), @Ad_Receipt_DATE, 101), '/', ''),      --Entity_ID
               @Ln_EventGlobalHoldSeq_NUMB,      --EventGlobalSeq_NUMB
               @Lc_TypeEntityRctdt_CODE,      --TypeEntity_CODE
               @Li_ReceiptOnHold1420_NUMB  --EventFunctionalSeq_NUMB
  
			  );

      SET @Ls_Sql_TEXT = 'INSERT_ESEM_Y1 4';
      SET @Ls_Sqldata_TEXT = ' Entity_ID - PyaorMci_IDNO = ' + CAST(@An_PayorMCI_IDNO AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalHoldSeq_NUMB AS VARCHAR) + ', TypeEntity_CODE = ' + @Lc_TypeEntityPayor_CODE + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR);

      INSERT ESEM_Y1
             (Entity_ID,
              EventGlobalSeq_NUMB,
              TypeEntity_CODE,
              EventFunctionalSeq_NUMB)
      VALUES (CAST(@An_PayorMCI_IDNO AS VARCHAR),      --Entity_ID
              @Ln_EventGlobalHoldSeq_NUMB,      --EventGlobalSeq_NUMB
              @Lc_TypeEntityPayor_CODE,      --TypeEntity_CODE
              @Li_ReceiptOnHold1420_NUMB  --EventFunctionalSeq_NUMB
    		  );
     END

     SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1_OBLE_Y1';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', Case_IDNO = ' + ISNULL(CAST( @Ln_PaidCur_Case_IDNO AS VARCHAR ),'')+ ', ToDistribute_AMNT = ' + ISNULL(CAST( @Ln_PaidCur_Receipt_AMNT AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptHeld_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Release_DATE = ' + ISNULL(CAST( @Ad_Release_DATE AS VARCHAR ),'') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalReceiptSeq_NUMB AS VARCHAR ),'');

     INSERT RCTH_Y1
            (Batch_DATE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceBatch_CODE,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             PayorMCI_IDNO,
             Case_IDNO,
             Employer_IDNO,
             Fips_CODE,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Receipt_DATE,
             Distribute_DATE,
             Check_DATE,
             CheckNo_TEXT,
             TaxJoint_CODE,
             Tanf_CODE,
             BackOut_INDC,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             TaxJoint_NAME,
             Fee_AMNT,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             ReasonBackOut_CODE,
             Release_DATE,
             Refund_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_ID,
             RefundRecipient_CODE)
     (SELECT @Ad_Batch_DATE AS Batch_DATE,              
             @An_Batch_NUMB AS Batch_NUMB,
             @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
             @Ac_SourceBatch_CODE AS SourceBatch_CODE,
             a.SourceReceipt_CODE,
             a.TypeRemittance_CODE,
             a.TypePosting_CODE,
             a.PayorMCI_IDNO,
             @Ln_PaidCur_Case_IDNO AS Case_IDNO,
             a.Employer_IDNO,
             a.Fips_CODE,
             a.Receipt_AMNT,
             @Ln_PaidCur_Receipt_AMNT AS ToDistribute_AMNT,
             a.Receipt_DATE,
             @Ld_Low_DATE AS Distribute_DATE,
             a.Check_DATE,
             a.CheckNo_TEXT,
             a.TaxJoint_CODE,
             a.Tanf_CODE,
             a.BackOut_INDC,
             @Lc_StatusReceiptHeld_CODE AS StatusReceipt_CODE,
             @Lc_ReasonStatus_CODE AS ReasonStatus_CODE,
             a.TaxJoint_NAME,
             ISNULL (a.Fee_AMNT,0) AS Fee_AMNT,                                                        
             @Ad_Process_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             @Ln_EventGlobalHoldSeq_NUMB AS EventGlobalBeginSeq_NUMB,
             0 AS EventGlobalEndSeq_NUMB,
             @Lc_Space_TEXT AS ReasonBackOut_CODE,
             @Ad_Release_DATE AS Release_DATE,
             a.Refund_DATE,
             a.ReferenceIrs_IDNO,
             a.RefundRecipient_ID,
             a.RefundRecipient_CODE
        FROM RCTH_Y1 a
       WHERE a.Batch_DATE = @Ad_Batch_DATE
         AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
         AND a.Batch_NUMB = @An_Batch_NUMB
         AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
         AND a.Distribute_DATE = @Ld_Low_DATE
         AND a.EventGlobalBeginSeq_NUMB = @An_EventGlobalReceiptSeq_NUMB);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_RCTH_Y12 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 5';     
     SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
      @Ac_Process_ID              = @Lc_ProcessRdist_ID,
      @Ad_EffectiveEvent_DATE     = @Ad_Process_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalHoldSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Paid_CUR - 2';  
     SET @Ls_Sqldata_TEXT = '';   
     
     FETCH NEXT FROM Paid_CUR INTO @Ln_PaidCur_Case_IDNO, @Lc_PaidCur_Flag_INDC, @Ln_PaidCur_Receipt_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Paid_CUR;

   DEALLOCATE Paid_CUR;

   IF ISNULL (@An_Remaining_AMNT, 0) > 0
    BEGIN
     IF @Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_ESEM_HOLD_CASE - 1';
       SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityCase_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'');

       INSERT ESEM_Y1
              (Entity_ID,
               EventGlobalSeq_NUMB,
               TypeEntity_CODE,
               EventFunctionalSeq_NUMB)
       VALUES (@An_Case_IDNO,      --Entity_ID
               @Ln_EventGlobalHoldSeq_NUMB,      --EventGlobalSeq_NUMB
               @Lc_TypeEntityCase_CODE,      --TypeEntity_CODE
               @Li_ReceiptOnHold1420_NUMB  --EventFunctionalSeq_NUMB
				);
      END

     BEGIN
      SET @Ls_Sql_TEXT = 'INSERT_ESEM_HOLD_CASE - 2';      
      SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(@Lc_Receipt_TEXT,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRctno_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'');

      INSERT ESEM_Y1
             (Entity_ID,
              EventGlobalSeq_NUMB,
              TypeEntity_CODE,
              EventFunctionalSeq_NUMB)
      VALUES (@Lc_Receipt_TEXT,      --Entity_ID
              @Ln_EventGlobalHoldSeq_NUMB,      --EventGlobalSeq_NUMB
              @Lc_TypeEntityRctno_CODE,      --TypeEntity_CODE
              @Li_ReceiptOnHold1420_NUMB  --EventFunctionalSeq_NUMB
              );
	  SET @Ls_Sql_TEXT = 'INSERT_ESEM_HOLD_CASE - 3';      SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRctdt_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'');

      INSERT ESEM_Y1
             (Entity_ID,
              EventGlobalSeq_NUMB,
              TypeEntity_CODE,
              EventFunctionalSeq_NUMB)
      VALUES ( REPLACE(CONVERT(VARCHAR(10), @Ad_Receipt_DATE, 101), '/', ''),      --Entity_ID
               @Ln_EventGlobalHoldSeq_NUMB,      --EventGlobalSeq_NUMB
               @Lc_TypeEntityRctdt_CODE,      --TypeEntity_CODE
               @Li_ReceiptOnHold1420_NUMB  --EventFunctionalSeq_NUMB
			 );
	  
	  SET @Ls_Sql_TEXT = 'INSERT_ESEM_HOLD_CASE - 4';
	  SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(CAST( @An_PayorMCI_IDNO AS VARCHAR ),'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityPayor_CODE,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_ReceiptOnHold1420_NUMB AS VARCHAR ),'');

      INSERT ESEM_Y1
             (Entity_ID,
              EventGlobalSeq_NUMB,
              TypeEntity_CODE,
              EventFunctionalSeq_NUMB)
      VALUES (@An_PayorMCI_IDNO,      --Entity_ID
              @Ln_EventGlobalHoldSeq_NUMB,      --EventGlobalSeq_NUMB
              @Lc_TypeEntityPayor_CODE,      --TypeEntity_CODE
              @Li_ReceiptOnHold1420_NUMB  --EventFunctionalSeq_NUMB
			 );
     END

     IF @Ad_ReleaseIn_DATE IS NULL
      BEGIN
       SET @Ad_Release_DATE = dbo.BATCH_FIN_REG_DISTRIBUTION$SF_HELD_MONEY_RELEASE_DATE (@Ac_ReasonStatus_CODE, @Ad_Process_DATE);
      END

     SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1 - 3';     
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST( @Ad_Batch_DATE AS VARCHAR ),'')+ ', Batch_NUMB = ' + ISNULL(CAST( @An_Batch_NUMB AS VARCHAR ),'')+ ', SeqReceipt_NUMB = ' + ISNULL(CAST( @An_SeqReceipt_NUMB AS VARCHAR ),'')+ ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE,'')+ ', ToDistribute_AMNT = ' + ISNULL(CAST( @An_Remaining_AMNT AS VARCHAR ),'')+ ', Distribute_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptHeld_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalHoldSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalReceiptSeq_NUMB AS VARCHAR ),'');

     INSERT RCTH_Y1
            (Batch_DATE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             SourceBatch_CODE,
             SourceReceipt_CODE,
             TypeRemittance_CODE,
             TypePosting_CODE,
             PayorMCI_IDNO,
             Case_IDNO,
             Employer_IDNO,
             Fips_CODE,
             Receipt_AMNT,
             ToDistribute_AMNT,
             Receipt_DATE,
             Distribute_DATE,
             Check_DATE,
             CheckNo_TEXT,
             TaxJoint_CODE,
             Tanf_CODE,
             BackOut_INDC,
             StatusReceipt_CODE,
             ReasonStatus_CODE,
             TaxJoint_NAME,
             Fee_AMNT,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             ReasonBackOut_CODE,
             Release_DATE,
             Refund_DATE,
             ReferenceIrs_IDNO,
             RefundRecipient_ID,
             RefundRecipient_CODE)
     (SELECT @Ad_Batch_DATE AS Batch_DATE,
             @An_Batch_NUMB AS Batch_NUMB,
             @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
             @Ac_SourceBatch_CODE AS SourceBatch_CODE,
             a.SourceReceipt_CODE,
             a.TypeRemittance_CODE,
             a.TypePosting_CODE,
             a.PayorMCI_IDNO,
             CASE
              WHEN @Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
               THEN a.Case_IDNO
              WHEN @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
                   AND @Ac_ReasonStatus_CODE NOT IN (@Lc_HoldReasonStatusSnax_CODE, @Lc_HoldReasonStatusSnfx_CODE)
               THEN a.Case_IDNO
              ELSE 0
             END AS Case_IDNO,
             a.Employer_IDNO,
             a.Fips_CODE,
             a.Receipt_AMNT,
             @An_Remaining_AMNT AS ToDistribute_AMNT,
             a.Receipt_DATE,
             @Ld_Low_DATE AS Distribute_DATE,
             a.Check_DATE AS EndValidity_DATE,
             a.CheckNo_TEXT,
             a.TaxJoint_CODE,
             a.Tanf_CODE,
             a.BackOut_INDC,
             @Lc_StatusReceiptHeld_CODE AS StatusReceipt_CODE,
             ISNULL (@Ac_ReasonStatus_CODE, @Lc_Space_TEXT) AS ReasonStatus_CODE,
             a.TaxJoint_NAME,
             ISNULL (a.Fee_AMNT, 0) AS Fee_AMNT,
             @Ad_Process_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             @Ln_EventGlobalHoldSeq_NUMB AS EventGlobalBeginSeq_NUMB,
             0 AS EventGlobalEndSeq_NUMB,
             @Lc_Space_TEXT AS ReasonBackOut_CODE,
             ISNULL (@Ad_ReleaseIn_DATE, @Ad_Release_DATE) AS Release_DATE,
             a.Refund_DATE,
             a.ReferenceIrs_IDNO,
             a.RefundRecipient_ID,
             a.RefundRecipient_CODE
        FROM RCTH_Y1 a
       WHERE a.Batch_DATE = @Ad_Batch_DATE
         AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
         AND a.Batch_NUMB = @An_Batch_NUMB
         AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
         AND a.Distribute_DATE = @Ld_Low_DATE
         AND a.EventGlobalBeginSeq_NUMB = @An_EventGlobalReceiptSeq_NUMB);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_RCTH_Y13 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END

   IF ISNULL (@An_Remaining_AMNT, 0) = 0
    BEGIN
	IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptLevyFidm_CODE
     BEGIN
      DECLARE FidmDmnr_CUR INSENSITIVE CURSOR FOR
       SELECT DISTINCT m.Case_IDNO,
              n.OrderSeq_NUMB
         FROM CMEM_Y1 m,
              DMNR_Y1 n
        WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
          AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_TEXT, @Lc_CaseRelationshipPutFather_TEXT)
          AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
          AND m.Case_IDNO = n.Case_IDNO
          AND n.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
          AND n.Status_CODE = @Lc_RemedyStatusStart_CODE
          AND n.ActivityMinor_CODE = @Lc_ActivityMinorMorfd_CODE
          AND n.MinorIntSeq_NUMB = (SELECT MAX (b.MinorIntSeq_NUMB) 
                                      FROM DMNR_Y1 b
                                     WHERE n.Case_IDNO = b.Case_IDNO
                                       AND n.OrderSeq_NUMB = b.OrderSeq_NUMB
                                       AND n.MajorIntSEQ_NUMB = b.MajorIntSEQ_NUMB);

      SET @Ls_Sql_TEXT = 'OPEN FidmDmnr_CUR - 1';
      SET @Ls_Sqldata_TEXT = '';
      
      OPEN FidmDmnr_CUR;

      SET @Ls_Sql_TEXT = 'FETCH FidmDmnr_CUR - 1';
      SET @Ls_Sqldata_TEXT = '';
      
      FETCH NEXT FROM FidmDmnr_CUR INTO @Ln_FidmDmnrCur_Case_IDNO, @Ln_FidmDmnrCur_OrderSeq_NUMB;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	  -- Loop started
      WHILE @Li_FetchStatus_QNTY = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC_FIDM';        
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_FidmDmnrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_FidmDmnrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_PayorMCI_IDNO AS VARCHAR ),'')+ ', OthpSource_IDNO = ' + ISNULL('0','')+ ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChangeFd_CODE,'')+ ', NegPos_CODE = ' + ISNULL(@Lc_NegPosCloseRemedy_CODE,'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', Create_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

        EXECUTE BATCH_COMMON$SP_INSERT_ELFC
         @An_Case_IDNO                = @Ln_FidmDmnrCur_Case_IDNO,
         @An_OrderSeq_NUMB            = @Ln_FidmDmnrCur_OrderSeq_NUMB,
         @An_MemberMci_IDNO           = @An_PayorMCI_IDNO,
         @An_OthpSource_IDNO          = 0,
         @Ac_TypeChange_CODE          = @Lc_TypeChangeFd_CODE,
         @Ac_NegPos_CODE              = @Lc_NegPosCloseRemedy_CODE,
         @Ac_Process_ID               = @Lc_ProcessRdist_ID,
         @Ad_Create_DATE              = @Ad_Process_DATE,
         @An_TransactionEventSeq_NUMB = 0,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'FETCH Dmnr_CUR - 2';
        SET @Ls_Sqldata_TEXT = '';
        
        FETCH NEXT FROM FidmDmnr_CUR INTO @Ln_FidmDmnrCur_Case_IDNO, @Ln_FidmDmnrCur_OrderSeq_NUMB;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       END

      CLOSE FidmDmnr_CUR;

      DEALLOCATE FidmDmnr_CUR;
     END
    ELSE
     BEGIN
      IF @Ac_SourceReceipt_CODE = @Lc_SourceReceiptCsln_CODE
       BEGIN
        DECLARE CslnDmnr_CUR INSENSITIVE CURSOR FOR
         SELECT DISTINCT
                m.Case_IDNO,
                n.OrderSeq_NUMB
           FROM CMEM_Y1 m,
                DMNR_Y1 n
          WHERE m.MemberMci_IDNO = @An_PayorMCI_IDNO
            AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_TEXT, @Lc_CaseRelationshipPutFather_TEXT)
            AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
            AND m.Case_IDNO = n.Case_IDNO
            AND n.ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE
            AND n.Status_CODE = @Lc_RemedyStatusStart_CODE
            AND n.ActivityMinor_CODE = @Lc_ActivityMinorRfins_CODE
            AND n.MinorIntSeq_NUMB = (SELECT MAX (b.MinorIntSeq_NUMB) 
                                        FROM DMNR_Y1 b
                                       WHERE n.Case_IDNO = b.Case_IDNO
                                         AND n.OrderSeq_NUMB = b.OrderSeq_NUMB
                                         AND n.MajorIntSEQ_NUMB = b.MajorIntSEQ_NUMB);

        SET @Ls_Sql_TEXT = 'OPEN CslnDmnr_CUR - 3';
        SET @Ls_Sqldata_TEXT = '';
        
        OPEN CslnDmnr_CUR;

        SET @Ls_Sql_TEXT = 'FETCH CslnDmnr_CUR - 3';
        SET @Ls_Sqldata_TEXT = '';
        
        FETCH NEXT FROM CslnDmnr_CUR INTO @Ln_CslnDmnrCur_Case_IDNO, @Ln_CslnDmnrCur_OrderSeq_NUMB;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
		-- Loop Started
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC_CSLN';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @Ln_CslnDmnrCur_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @Ln_CslnDmnrCur_OrderSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_PayorMCI_IDNO AS VARCHAR ),'')+ ', OthpSource_IDNO = ' + ISNULL('0','')+ ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChangePd_CODE,'')+ ', NegPos_CODE = ' + ISNULL(@Lc_NegPosCloseRemedy_CODE,'')+ ', Process_ID = ' + ISNULL(@Lc_ProcessRdist_ID,'')+ ', Create_DATE = ' + ISNULL(CAST( @Ad_Process_DATE AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

          EXECUTE BATCH_COMMON$SP_INSERT_ELFC
           @An_Case_IDNO                = @Ln_CslnDmnrCur_Case_IDNO,
           @An_OrderSeq_NUMB            = @Ln_CslnDmnrCur_OrderSeq_NUMB,
           @An_MemberMci_IDNO           = @An_PayorMCI_IDNO,
           @An_OthpSource_IDNO          = 0,
           @Ac_TypeChange_CODE          = @Lc_TypeChangePd_CODE,
           @Ac_NegPos_CODE              = @Lc_NegPosCloseRemedy_CODE,
           @Ac_Process_ID               = @Lc_ProcessRdist_ID,
           @Ad_Create_DATE              = @Ad_Process_DATE,
           @An_TransactionEventSeq_NUMB = 0,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC_CSLN FAILED';

            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'FETCH CslnDmnr_CUR - 4';
          SET @Ls_Sqldata_TEXT = '';
          
          FETCH NEXT FROM CslnDmnr_CUR INTO @Ln_CslnDmnrCur_Case_IDNO, @Ln_CslnDmnrCur_OrderSeq_NUMB;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE CslnDmnr_CUR;

        DEALLOCATE CslnDmnr_CUR;
       END
     END
   END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY
 BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('LOCAL', 'Paid_CUR') IN (0, 1)
    BEGIN
     CLOSE Paid_CUR;

     DEALLOCATE Paid_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'FidmDmnr_CUR') IN (0, 1)
    BEGIN
     CLOSE FidmDmnr_CUR;

     DEALLOCATE FidmDmnr_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'CslnDmnr_CUR') IN (0, 1)
    BEGIN
     CLOSE CslnDmnr_CUR;

     DEALLOCATE CslnDmnr_CUR;
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
