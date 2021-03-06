/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_NOTE$SP_VOID_REISSUE_ACSES_CHECK]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_NOTE$SP_VOID_REISSUE_ACSES_CHECK
Programmer Name		: IMP Team
Description			: 
Frequency			: 
Developed On		:	04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_NOTE$SP_VOID_REISSUE_ACSES_CHECK]
 @An_Topic_IDNO            NUMERIC(10),
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(2),
 @Ac_Category_CODE         CHAR(2),
 @Ac_Subject_CODE          CHAR(5),
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @An_MinorIntSeq_NUMB      NUMERIC(5),
 @An_CwicSeq_NUMB          NUMERIC(19),
 @An_Check_NUMB            NUMERIC(19),
 @An_Check_AMNT            NUMERIC(9, 2),
 @Ad_Check_DATE            DATE,
 @Ad_Receipt_DATE          DATE,
 @Ac_DisbursedTo_CODE      VARCHAR(MAX),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_WorkerSignedOn_IDNO   CHAR,
 @Ac_Msg_CODE              CHAR(3) OUTPUT,
 @Ac_DescriptionError_TEXT CHAR OUTPUT
AS
 BEGIN
  DECLARE @Ln_Error_NUMB                    NUMERIC(11),
          @Ln_ErrorLine_NUMB                NUMERIC(11),
          @Ls_ErrorMessage_TEXT             VARCHAR(200),
          @Lc_ChildSrcAcsesAcs_CODE         CHAR(3) = 'ACS',
          @Lc_No_TEXT                       CHAR = 'N',
          @Lc_StatusSuccess_CODE            CHAR = 'S',
          @Ln_EventFunctionalSeq1820_NUMB   NUMERIC(4, 0) = 1820,
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Lc_ReceiptSrcRegularPayment_CODE CHAR(2) = 'RE',
          @Lc_RemitTypeCheck_CODE           CHAR(3) = 'CHK',
          @Lc_BatchStatusReconciled_CODE    CHAR(1) = 'R',
          @Lc_StringZero_TEXT               CHAR = '0',
          @Lc_RelationshipCaseCp_TEXT       CHAR(1) = 'C',
          @Lc_ReceiptSrcAc_CODE             CHAR(2) = 'AC',
          @Lc_ReceiptSrcAn_CODE             CHAR(2) = 'AN',
          @Lc_TypePostingCase_CODE          CHAR(1) = 'C',
          @Lc_Space_TEXT                    CHAR = ' ',
          @Lc_StatusReceiptIdentified_CODE  CHAR(1) = 'I',
          @Lc_StatusReceiptRefunded_CODE    CHAR(1) = 'R',
          @Ld_Low_DATE                      DATE = '01/01/0001',
          @Lc_RelationshipCaseNcp_TEXT      CHAR(1) = 'A',
          @Lc_RecipientTypeCpNcp_CODE       CHAR(1) = '1',
          @Lc_DebtTypeChildSupp_CODE        CHAR(2) = 'Cs_AMNT',
          @Lc_DebtTypeSpousalSupp_CODE      CHAR(2) = 'SS',
          @Lc_DebtTypeAlimony_CODE          CHAR(2) = 'AL',
          @Lc_DateFormatYyyymm_TEXT         CHAR(6) = 'YYYYMM',
          @Lc_TypeRecordOriginal_CODE       CHAR(1) = 'O',
          @Lc_DisbursementTypeRefund_CODE   CHAR(5) = 'REFND',
          @Lc_DisbursementTypeAznaa_CODE    CHAR(5) = 'AZNAA',
          @Ln_Zero_NUMB                     FLOAT(53) = 0,
          @Lc_StatusFailed_CODE             CHAR = 'F',
          @Ln_EventFunctionalSeq1030_NUMB   NUMERIC(4, 0) = 1030,
          @Lc_Process_ID                    CHAR(10) = 'NOTE',
          @Ln_CtControlReceipt2_QNTY        NUMERIC(3) = 999,
          @Lc_RePost_INDC                   CHAR(1) = 'N',
          @Lc_SeqReceipt001_TEXT            CHAR(3) = '001',
          @Lc_BackOut_INDC                  CHAR(1) = 'N',
          @Ln_EventFunctional1820_SEQ       NUMERIC(4, 0) = 1820,
          @Ln_EventFunctionalSeq1220_NUMB   NUMERIC(4, 0) = 1220,
          @Lc_SubjectFaovo_CODE             CHAR(5) = 'FAOVO',
          @Lc_StatusHold_CODE               CHAR(1) = 'H',
          @Lc_StatusRelationship_CODE       CHAR(1) = 'R',
          @Lc_DhldPayeeHold_TEXT            CHAR(1) = 'P',
          @Lc_ReasonStatusMdpd_CODE         CHAR(4) = 'MDPD',
          @Lc_DisbursementReadyDhld_TEXT    CHAR(4) = 'DR',
          @Lc_ActivityMajor_CODE            CHAR(4) = 'CASE',
          @Ls_Procedure_NAME                VARCHAR(60) = ' SPKG_NOTE.BATCH_COMMON_NOTE$SP_VOID_REISSUE_ACSES_CHECKS ',
          @Ls_Sql_TEXT                      VARCHAR(100),
          @Ls_Sqldata_TEXT                  VARCHAR(200),
          @Ld_Batch_DATE                    DATE,
          @Lc_SourceBatch_CODE              CHAR(3),
          @Ln_Batch_NUMB                    NUMERIC(4),
          @Ln_SeqReceipt_NUMB               NUMERIC(6),
          @Ln_CtControlReceipt_QNTY         NUMERIC(3),
          @Ln_EventGlobalSeqRbat_NUMB       NUMERIC(19, 0),
          @Ln_PayorMCI_IDNO                 NUMERIC(10),
          @Ln_ObligationSeq_NUMB            NUMERIC(2) = 0,
          @Lc_TypeDebt_CODE                 CHAR(2),
          @Ln_MemberMci_IDNO                NUMERIC(10),
          @Lc_Fips_CODE                     CHAR(7),
          @Lc_CheckRecipient_ID             CHAR(10),
          @Ln_SupportYearMonth_NUMB         NUMERIC(6),
          @Ln_EventGlobalSeq1820_NUMB       NUMERIC(19, 0),
          @Ln_EventGlobalSeq1030_NUMB       NUMERIC(19, 0),
          @Ln_EventGlobalSeq1220_NUMB       NUMERIC(19, 0),
          @Lc_ReceiptNo_TEXT                CHAR(30),
          @Ln_Order_IDNO                    NUMERIC(15),
          @Ln_OrderSeq_NUMB                 NUMERIC(2) = 0

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL
   SET @Ac_DescriptionError_TEXT = NULL
   SET @Ld_Batch_DATE = dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
   SET @Lc_SourceBatch_CODE = @Lc_ChildSrcAcsesAcs_CODE
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 1030'
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB ' + ISNULL(CAST(@Ln_EventFunctionalSeq1030_NUMB AS NVARCHAR(MAX)), '')

   DECLARE @Ld_EffectiveEvent_DATE DATE

   SET @Ld_EffectiveEvent_DATE = dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Ln_EventFunctionalSeq1030_NUMB,
    @Ac_Process_ID              = @Lc_Process_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_EffectiveEvent_DATE,
    @Ac_Note_INDC               = @Lc_No_TEXT,
    @Ac_Worker_ID               = @Ac_WorkerSignedOn_IDNO,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq1030_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
    @Ac_DescriptionError_TEXT   = @Ac_DescriptionError_TEXT OUTPUT

   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ 1030 FAILED '

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 1820'
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB ' + ISNULL(CAST(@Ln_EventFunctionalSeq1820_NUMB AS NVARCHAR(MAX)), '')

   DECLARE @Ld_EffectiveEvent2_DATE DATE

   SET @Ld_EffectiveEvent2_DATE = dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Ln_EventFunctionalSeq1820_NUMB,
    @Ac_Process_ID              = @Lc_Process_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_EffectiveEvent2_DATE,
    @Ac_Note_INDC               = @Lc_No_TEXT,
    @Ac_Worker_ID               = @Ac_WorkerSignedOn_IDNO,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq1820_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
    @Ac_DescriptionError_TEXT   = @Ac_DescriptionError_TEXT OUTPUT

   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ 1820 FAILED '

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = ' SELECT_VRBAT '
   SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CAST(@Ld_Batch_DATE AS NVARCHAR(MAX)), '') + ' SourceBatch_CODE ' + ISNULL(@Lc_SourceBatch_CODE, '')

   SELECT @Ln_CtControlReceipt_QNTY = RBAT_Y1.CtControlReceipt_QNTY + 1,
          @Ln_EventGlobalSeqRbat_NUMB = RBAT_Y1.EventGlobalBeginSeq_NUMB,
          @Ln_Batch_NUMB = RBAT_Y1.Batch_NUMB
     FROM RBAT_Y1
    WHERE RBAT_Y1.Batch_NUMB = (SELECT MAX(RBAT_Y1.Batch_NUMB) AS expr
                                  FROM RBAT_Y1
                                 WHERE RBAT_Y1.Batch_DATE = @Ld_Batch_DATE
                                   AND RBAT_Y1.SourceBatch_CODE = @Lc_SourceBatch_CODE
                                   AND RBAT_Y1.EndValidity_DATE = @Ld_High_DATE)
      AND RBAT_Y1.Batch_DATE = @Ld_Batch_DATE
      AND RBAT_Y1.SourceBatch_CODE = @Lc_SourceBatch_CODE
      AND RBAT_Y1.EndValidity_DATE = @Ld_High_DATE

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ln_CtControlReceipt_QNTY = 1
    END

   SET @Ln_CtControlReceipt_QNTY = 1

   IF @Ln_CtControlReceipt_QNTY <= @Ln_CtControlReceipt2_QNTY
    BEGIN
     SET @Ls_Sql_TEXT = ' UPDATE_VRBAT '
     SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CAST(@Ld_Batch_DATE AS NVARCHAR(MAX)), '') + ' SourceBatch_CODE ' + ISNULL(@Lc_SourceBatch_CODE, '')

     UPDATE RBAT_Y1
        SET CtControlReceipt_QNTY = @Ln_CtControlReceipt_QNTY,
            CtActualReceipt_QNTY = @Ln_CtControlReceipt_QNTY,
            ControlReceipt_AMNT = RBAT_Y1.ControlReceipt_AMNT + @An_Check_AMNT,
            ActualReceipt_AMNT = RBAT_Y1.ControlReceipt_AMNT + @An_Check_AMNT,
            CtControlTrans_QNTY = @Ln_CtControlReceipt_QNTY,
            CtActualTrans_QNTY = @Ln_CtControlReceipt_QNTY
      WHERE RBAT_Y1.Batch_DATE = @Ld_Batch_DATE
        AND RBAT_Y1.SourceBatch_CODE = @Lc_SourceBatch_CODE
        AND RBAT_Y1.EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeqRbat_NUMB
        AND RBAT_Y1.Batch_NUMB = @Ln_Batch_NUMB
        AND RBAT_Y1.EndValidity_DATE = @Ld_High_DATE

     IF @@ROWCOUNT = 0
      BEGIN
       SET @Ls_Sql_TEXT = ' UPDATE_VRBAT FAILED '

       RAISERROR(50001,16,1);
      END
    END

   IF @Ln_CtControlReceipt_QNTY > @Ln_CtControlReceipt2_QNTY
       OR @Ln_CtControlReceipt_QNTY = 1
    BEGIN
     SET @Ls_Sql_TEXT = ' SELECT_SEQ_CBAT '

     BEGIN TRANSACTION

     DELETE FROM IdentSeqCbat_T1;

     INSERT INTO IdentSeqCbat_T1
          VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

     SELECT @Ln_Batch_NUMB = Seq_IDNO
       FROM IdentSeqCbat_T1;

     COMMIT TRANSACTION

     SET @Ls_Sql_TEXT = ' INSERT_VRBAT '
     SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CAST(@Ld_Batch_DATE AS NVARCHAR(MAX)), '') + ' SourceBatch_CODE ' + ISNULL(@Lc_SourceBatch_CODE, '')

     INSERT RBAT_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SourceReceipt_CODE,
             CtControlReceipt_QNTY,
             CtActualReceipt_QNTY,
             ControlReceipt_AMNT,
             ActualReceipt_AMNT,
             TypeRemittance_CODE,
             Receipt_DATE,
             StatusBatch_CODE,
             RePost_INDC,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             CtControlTrans_QNTY,
             CtActualTrans_QNTY)
     VALUES ( @Ld_Batch_DATE,
              @Lc_SourceBatch_CODE,
              @Ln_Batch_NUMB,
              @Lc_ReceiptSrcRegularPayment_CODE,
              1,
              1,
              @An_Check_AMNT,
              @An_Check_AMNT,
              @Lc_RemitTypeCheck_CODE,
              dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
              @Lc_BatchStatusReconciled_CODE,
              @Lc_RePost_INDC,
              @Ln_EventGlobalSeq1820_NUMB,
              0,
              dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
              @Ld_High_DATE,
              dbo.BATCH_COMMON_SCALAR$SF_LPAD_NVARCHAR(CAST(1 AS NVARCHAR(4000)), 3, @Lc_StringZero_TEXT),
              dbo.BATCH_COMMON_SCALAR$SF_LPAD_NVARCHAR(CAST(1 AS NVARCHAR(4000)), 3, @Lc_StringZero_TEXT))

     IF @@ROWCOUNT = 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT_VRBAT FAILED '

       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = ' SELECT_VRCTH '
   SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CAST(@Ld_Batch_DATE AS NVARCHAR(MAX)), '') + ' SourceBatch_CODE ' + ISNULL(@Lc_SourceBatch_CODE, '') + ' Batch_NUMB ' + ISNULL(CAST(@Ln_Batch_NUMB AS NVARCHAR(MAX)), '')

   SELECT @Ln_SeqReceipt_NUMB = ISNULL(dbo.BATCH_COMMON_SCALAR$SF_LPAD_NVARCHAR(CAST(ISNULL((CAST(MAX(dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR(RCTH_Y1.SeqReceipt_NUMB, 1, 3)) AS FLOAT(53)) + 1), 1) AS NVARCHAR(4000)), 3, @Lc_StringZero_TEXT), '') + ISNULL(@Lc_SeqReceipt001_TEXT, '')
     FROM RCTH_Y1
    WHERE RCTH_Y1.Batch_DATE = @Ld_Batch_DATE
      AND RCTH_Y1.SourceBatch_CODE = @Lc_SourceBatch_CODE
      AND RCTH_Y1.Batch_NUMB = @Ln_Batch_NUMB
      AND RCTH_Y1.EndValidity_DATE = @Ld_High_DATE

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ln_SeqReceipt_NUMB = ISNULL(@Lc_SeqReceipt001_TEXT, '') + ISNULL(@Lc_SeqReceipt001_TEXT, '')
    END

   SET @Ln_PayorMCI_IDNO = dbo.BATCH_COMMON$SF_GETNCPMEMBERFORACTIVECASE(@An_Case_IDNO)
   SET @Ls_Sql_TEXT = ' INSERT_VRCTH '
   SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CAST(@Ld_Batch_DATE AS NVARCHAR(MAX)), '') + ' SourceBatch_CODE ' + ISNULL(@Lc_SourceBatch_CODE, '') + ' Batch_NUMB ' + ISNULL(CAST(@Ln_Batch_NUMB AS NVARCHAR(MAX)), '') + ' SeqReceipt_NUMB ' + ISNULL(@Ln_SeqReceipt_NUMB, '')

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
           RefundRecipient_ID,
           RefundRecipient_CODE,
           BeginValidity_DATE,
           EndValidity_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB)
   VALUES ( @Ld_Batch_DATE,
            @Lc_SourceBatch_CODE,
            @Ln_Batch_NUMB,
            @Ln_SeqReceipt_NUMB,
            CASE @Ac_DisbursedTo_CODE
             WHEN @Lc_RelationshipCaseCp_TEXT
              THEN @Lc_ReceiptSrcAc_CODE
             ELSE @Lc_ReceiptSrcAn_CODE
            END,
            @Lc_RemitTypeCheck_CODE,
            @Lc_TypePostingCase_CODE,
            @An_Case_IDNO,
            @Ln_PayorMCI_IDNO,
            @An_Check_AMNT,
            @An_Check_AMNT,
            0,
            @Lc_Space_TEXT,
            @Lc_Space_TEXT,
            @Ad_Check_DATE,
            @An_Check_NUMB,
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            @Lc_Space_TEXT,
            @Lc_Space_TEXT,
            @Lc_Space_TEXT,
            CASE @Ac_DisbursedTo_CODE
             WHEN @Lc_RelationshipCaseCp_TEXT
              THEN @Lc_StatusReceiptIdentified_CODE
             ELSE @Lc_StatusReceiptRefunded_CODE
            END,
            @Lc_Space_TEXT,
            @Lc_BackOut_INDC,
            @Lc_Space_TEXT,
            @Ld_Low_DATE,
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            
            CASE @Ac_DisbursedTo_CODE
             WHEN @Lc_RelationshipCaseNcp_TEXT
              THEN @An_MemberMci_IDNO
             ELSE @Lc_Space_TEXT
            END,
            CASE @Ac_DisbursedTo_CODE
             WHEN @Lc_RelationshipCaseNcp_TEXT
              THEN @Lc_RecipientTypeCpNcp_CODE
             ELSE @Lc_Space_TEXT
            END,
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            @Ld_High_DATE,
            @Ln_EventGlobalSeq1820_NUMB,
            0)

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT_VRCTH FAILED '

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = ' SELECT_VSORD '
   SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@An_Case_IDNO, '')

   SELECT DISTINCT
          @Ln_Order_IDNO = a.Order_IDNO
     FROM SORD_Y1 AS a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.EndValidity_DATE = @Ld_High_DATE

   SET @Ls_Sql_TEXT = ' BATCH_COMMON$SF_GET_RECEIPT_NO '
   SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CAST(@Ld_Batch_DATE AS NVARCHAR(MAX)), '') + ' SourceBatch_CODE ' + ISNULL(@Lc_SourceBatch_CODE, '') + ' Batch_NUMB ' + ISNULL(CAST(@Ln_Batch_NUMB AS NVARCHAR(MAX)), '') + ' SeqReceipt_NUMB ' + ISNULL(@Ln_SeqReceipt_NUMB, '')
   SET @Lc_ReceiptNo_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO(@Ld_Batch_DATE, @Lc_SourceBatch_CODE, @Ln_Batch_NUMB, @Ln_SeqReceipt_NUMB)

   IF @Ac_DisbursedTo_CODE = @Lc_RelationshipCaseCp_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT OBLE'
     SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@An_Case_IDNO, '') + ' MemberMci_IDNO ' + ISNULL(@An_MemberMci_IDNO, '')

     SELECT DISTINCT
            @Ln_ObligationSeq_NUMB = a.ObligationSeq_NUMB,
            @Lc_TypeDebt_CODE = a.TypeDebt_CODE,
            @Ln_OrderSeq_NUMB = a.OrderSeq_NUMB
       FROM OBLE_Y1 AS a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.ObligationSeq_NUMB = (SELECT MIN(b.ObligationSeq_NUMB) AS expr
                                      FROM OBLE_Y1 AS b
                                     WHERE a.Case_IDNO = b.Case_IDNO
                                       AND b.CheckRecipient_ID = @An_MemberMci_IDNO
                                       AND b.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                                       AND b.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeSpousalSupp_CODE, @Lc_DebtTypeAlimony_CODE)
                                       AND b.EndValidity_DATE = @Ld_High_DATE)
        AND a.EndValidity_DATE = @Ld_High_DATE

     SET @Ln_SupportYearMonth_NUMB = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()), @Lc_DateFormatYyyymm_TEXT)
     SET @Ls_Sql_TEXT = 'INSERT LSUP_Y1 1030'
     SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CAST(@Ld_Batch_DATE AS NVARCHAR(MAX)), '') + ' SourceBatch_CODE ' + ISNULL(@Lc_SourceBatch_CODE, '') + ' Batch_NUMB ' + ISNULL(CAST(@Ln_Batch_NUMB AS NVARCHAR(MAX)), '') + ' SeqReceipt_NUMB ' + ISNULL(@Ln_SeqReceipt_NUMB, '')

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
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.SupportYearMonth_NUMB,
            a.TypeWelfare_CODE,
            0,
            a.OweTotCurSup_AMNT,
            a.AppTotCurSup_AMNT,
            a.MtdCurSupOwed_AMNT,
            0,
            a.OweTotExptPay_AMNT,
            a.AppTotExptPay_AMNT,
            @An_Check_AMNT,
            (@An_Check_AMNT + a.OweTotNaa_AMNT),
            a.AppTotNaa_AMNT,
            0,
            a.OweTotPaa_AMNT,
            a.AppTotPaa_AMNT,
            0,
            a.OweTotTaa_AMNT,
            a.AppTotTaa_AMNT,
            0,
            a.OweTotCaa_AMNT,
            a.AppTotCaa_AMNT,
            0,
            a.OweTotUpa_AMNT,
            a.AppTotUpa_AMNT,
            0,
            a.OweTotUda_AMNT,
            a.AppTotUda_AMNT,
            0,
            a.OweTotIvef_AMNT,
            a.AppTotIvef_AMNT,
            0,
            a.OweTotMedi_AMNT,
            a.AppTotMedi_AMNT,
            0,
            a.OweTotNffc_AMNT,
            a.AppTotNffc_AMNT,
            0,
            a.OweTotNonIvd_AMNT,
            a.AppTotNonIvd_AMNT,
            @Ld_Low_DATE,
            @Lc_Space_TEXT,
            0,
            0,
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            @Lc_TypeRecordOriginal_CODE,
            @Ln_EventFunctionalSeq1030_NUMB,
            @Ln_EventGlobalSeq1030_NUMB,
            0,
            a.AppTotFuture_AMNT,
            @An_MemberMci_IDNO,
            @Lc_RecipientTypeCpNcp_CODE
       FROM LSUP_Y1 AS a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
        AND a.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
        AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) AS expr
                                       FROM LSUP_Y1 AS b
                                      WHERE b.Case_IDNO = a.Case_IDNO
                                        AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                        AND b.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB)

     IF @@ROWCOUNT = 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT_VLSUP 1030 FAILED '

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT LSUP_Y1 1820'
     SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CAST(@Ld_Batch_DATE AS NVARCHAR(MAX)), '') + ' SourceBatch_CODE ' + ISNULL(@Lc_SourceBatch_CODE, '') + ' Batch_NUMB ' + ISNULL(CAST(@Ln_Batch_NUMB AS NVARCHAR(MAX)), '') + ' SeqReceipt_NUMB ' + ISNULL(@Ln_SeqReceipt_NUMB, '')

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
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.ObligationSeq_NUMB,
            a.SupportYearMonth_NUMB,
            a.TypeWelfare_CODE,
            0,
            a.OweTotCurSup_AMNT,
            a.AppTotCurSup_AMNT,
            a.MtdCurSupOwed_AMNT,
            0,
            a.OweTotExptPay_AMNT,
            a.AppTotExptPay_AMNT,
            @An_Check_AMNT,
            a.OweTotNaa_AMNT,
            (@An_Check_AMNT + a.AppTotNaa_AMNT),
            0,
            a.OweTotPaa_AMNT,
            a.AppTotPaa_AMNT,
            0,
            a.OweTotTaa_AMNT,
            a.AppTotTaa_AMNT,
            0,
            a.OweTotCaa_AMNT,
            a.AppTotCaa_AMNT,
            0,
            a.OweTotUpa_AMNT,
            a.AppTotUpa_AMNT,
            0,
            a.OweTotUda_AMNT,
            a.AppTotUda_AMNT,
            0,
            a.OweTotIvef_AMNT,
            a.AppTotIvef_AMNT,
            0,
            a.OweTotMedi_AMNT,
            a.AppTotMedi_AMNT,
            0,
            a.OweTotNffc_AMNT,
            a.AppTotNffc_AMNT,
            0,
            a.OweTotNonIvd_AMNT,
            a.AppTotNonIvd_AMNT,
            @Ld_Batch_DATE,
            @Lc_SourceBatch_CODE,
            @Ln_Batch_NUMB,
            @Ln_SeqReceipt_NUMB,
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            @Lc_TypeRecordOriginal_CODE,
            @Ln_EventFunctional1820_SEQ,
            @Ln_EventGlobalSeq1820_NUMB,
            0,
            a.AppTotFuture_AMNT,
            @An_MemberMci_IDNO,
            @Lc_RecipientTypeCpNcp_CODE
       FROM LSUP_Y1 AS a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
        AND a.ObligationSeq_NUMB = @Ln_ObligationSeq_NUMB
        AND a.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
        AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB) AS expr
                                       FROM LSUP_Y1 AS b
                                      WHERE b.Case_IDNO = a.Case_IDNO
                                        AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                        AND b.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB)

     IF @@ROWCOUNT = 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT_VLSUP 1820 FAILED '

       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ 1220'
   SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB ' + ISNULL(CAST(@Ln_EventFunctionalSeq1220_NUMB AS NVARCHAR(MAX)), '')

   DECLARE @Ld_EffectiveEvent3_DATE DATE

   SET @Ld_EffectiveEvent3_DATE = dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())

   EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
    @An_EventFunctionalSeq_NUMB = @Ln_EventFunctionalSeq1220_NUMB,
    @Ac_Process_ID              = @Lc_Process_ID,
    @Ad_EffectiveEvent_DATE     = @Ld_EffectiveEvent3_DATE,
    @Ac_Note_INDC               = @Lc_No_TEXT,
    @Ac_Worker_ID               = @Ac_WorkerSignedOn_IDNO,
    @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq1220_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
    @Ac_DescriptionError_TEXT   = @Ac_DescriptionError_TEXT OUTPUT

   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_GENERATE_SEQ 1220 FAILED '

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'INSERT DHLD_Y1'

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
           Transaction_AMNT,
           Status_CODE,
           TypeDisburse_CODE,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           TypeHold_CODE,
           ReasonStatus_CODE,
           Unique_IDNO,
           ProcessOffset_INDC,
           EventGlobalSupportSeq_NUMB,
           BeginValidity_DATE,
           EndValidity_DATE,
           EventGlobalBeginSeq_NUMB,
           EventGlobalEndSeq_NUMB,
           Disburse_DATE,
           DisburseSeq_NUMB,
           StatusEscheat_DATE,
           StatusEscheat_CODE)
   VALUES ( @An_Case_IDNO,
            @Ln_OrderSeq_NUMB,
            @Ln_ObligationSeq_NUMB,
            @Ld_Batch_DATE,
            @Lc_SourceBatch_CODE,
            @Ln_Batch_NUMB,
            @Ln_SeqReceipt_NUMB,
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            CASE @Ac_Subject_CODE
             WHEN @Lc_SubjectFaovo_CODE
              THEN @Ld_High_DATE
             ELSE dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
            END,
            @An_Check_AMNT,
            CASE @Ac_Subject_CODE
             WHEN @Lc_SubjectFaovo_CODE
              THEN @Lc_StatusHold_CODE
             ELSE @Lc_StatusRelationship_CODE
            END,
            CASE @Ac_DisbursedTo_CODE
             WHEN @Lc_RelationshipCaseNcp_TEXT
              THEN @Lc_DisbursementTypeRefund_CODE
             ELSE @Lc_DisbursementTypeAznaa_CODE
            END,
            @An_MemberMci_IDNO,
            @Lc_RecipientTypeCpNcp_CODE,
            @Lc_DhldPayeeHold_TEXT,
            CASE @Ac_Subject_CODE
             WHEN @Lc_SubjectFaovo_CODE
              THEN @Lc_ReasonStatusMdpd_CODE
             ELSE @Lc_DisbursementReadyDhld_TEXT
            END,
            dbo.BATCH_COMMON_SCALAR$SF_DB_GET_NEXT_SEQUENCE_VALUE(N'', N'dbo', N'SEQ_UNIQUE_ID_DHLD'),
            @Lc_No_TEXT,
            @Ln_EventGlobalSeq1820_NUMB,
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()),
            @Ld_High_DATE,
            @Ln_EventGlobalSeq1220_NUMB,
            @Ln_Zero_NUMB,
            @Ld_Low_DATE,
            @Ln_Zero_NUMB,
            @Ld_High_DATE,
            @Lc_Space_TEXT)

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT_VDHLD FAILED '

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = ' INSERT_VDSBA '
   SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + ISNULL(@An_Case_IDNO, '') + ' ActivityMinor_CODE ' + ISNULL(@Ac_Subject_CODE, '') + ' MajorIntSEQ_NUMB ' + ISNULL(CAST(@An_MajorIntSeq_NUMB AS NVARCHAR(MAX)), '') + ' MinorIntSeq_NUMB ' + ISNULL(CAST(@An_MinorIntSeq_NUMB AS NVARCHAR(MAX)), '') + ' Topic_IDNO ' + ISNULL(CAST(@An_Topic_IDNO AS NVARCHAR(MAX)), '')

   INSERT DSBA_Y1
          (Case_IDNO,
           Topic_IDNO,
           OrderSeq_NUMB,
           MajorIntSEQ_NUMB,
           MinorIntSeq_NUMB,
           ActivityMajor_CODE,
           ActivityMinor_CODE,
           Subsystem_CODE,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           CheckCwicNo_TEXT,
           CheckCwic_AMNT,
           CheckCwic_DATE,
           ReceiptCwic_DATE,
           CwicSeq_NUMB,
           CheckRecipient_ID,
           CheckRecipient_CODE,
           EventGlobalSeq_NUMB)
   VALUES ( @An_Case_IDNO,
            @An_Topic_IDNO,
            @An_OrderSeq_NUMB,
            @An_MajorIntSeq_NUMB,
            @An_MinorIntSeq_NUMB,
            @Lc_ActivityMajor_CODE,
            @Ac_Subject_CODE,
            @Ac_Category_CODE,
            @Ld_Batch_DATE,
            @Lc_SourceBatch_CODE,
            @Ln_Batch_NUMB,
            @Ln_SeqReceipt_NUMB,
            @An_Check_NUMB,
            @An_Check_AMNT,
            @Ad_Check_DATE,
            @Ad_Receipt_DATE,
            @An_CwicSeq_NUMB,
            @An_MemberMci_IDNO,
            @Lc_RecipientTypeCpNcp_CODE,
            @An_EventGlobalSeq_NUMB)

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT_VDSBA FAILED '

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

   -- Retrieve and log the Error Description.
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @Ac_DescriptionError_TEXT = @Ac_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
