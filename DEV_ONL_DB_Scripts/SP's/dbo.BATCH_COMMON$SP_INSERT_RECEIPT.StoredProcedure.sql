/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_RECEIPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_COMMON$SP_INSERT_RECEIPT

Programmer Name   : IMP Team.

Description       : 

Frequency         : 

Developed On      :	04/12/2011


Called BY         : None

Called On         : BATCH_COMMON_SCALAR$SF_SSMA_RETHROWERROR,
					BATCH_COMMON$SP_RECEIPT_ON_HOLD, 
					BATCH_COMMON$SP_GENERATE_SEQ, 
					BATCH_COMMON$SP_ENTITY_MATRIX 
-------------------------------------------------------------------------------------------------------------------------------------------------					
Modified BY       :

Modified On       :

Version No        : 1.0
----------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_RECEIPT](
 @Ad_Batch_DATE               DATE,
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Batch_NUMB               NUMERIC(4),
 @Ac_TypePosting_CODE         CHAR(1),
 @An_CasePayorMCI_IDNO        NUMERIC(10),
 @Ac_SourceReceipt_CODE       CHAR(2),
 @Ac_StatusReceipt_CODE       CHAR(1),
 @Ac_ReasonStatus_CODE        CHAR(4),
 @Ad_Receipt_DATE             DATE,
 @An_Receipt_AMNT             NUMERIC(11, 2),
 @Ac_TypeRemittance_CODE      CHAR(3),
 @An_Employer_IDNO            NUMERIC(9),
 @Ac_Fips_CODE                CHAR(7),
 @Ad_Check_DATE               DATE,
 @Ac_CheckNo_TEXT             CHAR(19),
 @Ac_TaxJoint_CODE            CHAR(1),
 @Ac_Tanf_CODE                CHAR(1),
 @Ac_TaxJoint_NAME            CHAR(35),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19),
 @An_Fee_AMNT                 NUMERIC(11, 2),
 @Ac_Screen_ID                CHAR(4),
 @As_DescriptionNote_TEXT     VARCHAR(4000),
 @Ac_SignedOnWorker_ID        CHAR(30),
 --Bug 13447 : CR0384 -- Added parameter @Ac_NcpRefundRecoverReceipt_INDC for not to check receipt on hold procedure when value is 'Y'  - START
 @Ac_NcpRefundRecoverReceipt_INDC CHAR(1) ='N',
 --Bug 13447 : CR0384 -- Added parameter @Ac_NcpRefundRecoverReceipt_INDC for not to check receipt on hold procedure when value is 'Y'  - End
 @An_NewSeqReceipt_NUMB       NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Zero_NUMB                      NUMERIC(19) = 0,
          @Lc_TypePostingCase_CODE           CHAR (1) = 'C',
          @Lc_SourceReceiptCpRecoupment_CODE CHAR (2) = 'CR',
          @Lc_SourceReceiptCpFeePayment_CODE CHAR(2) = 'CF',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_TypePostingPayor_CODE          CHAR(1) = 'P',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusReceiptIdentified_CODE   CHAR(1) = 'I',
          @Lc_StatusReceiptHeld_CODE         CHAR(1) = 'H',
          @Lc_HoldReasonSnna_CODE            CHAR(4) = 'SNNA',
          @Lc_StatusReceiptUnidentified_CODE CHAR(1) = 'U',
          @Lc_DateFormatMmDdYyyy_TEXT        CHAR(10) = 'MM/DD/YYYY',
          @Lc_StringZero_TEXT                CHAR(1) = '0',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Lc_Highdate_TEXT                  CHAR(11) = '12/31/9999',
          @Lc_HoldReasonUnid_CODE            CHAR(4) = 'UNID',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_StatusConChkFail_CODE          CHAR(1) = 'L',
          @Ld_System_DATE                    DATETIME2(0) = CONVERT(VARCHAR(10), dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 121),
          @Ln_FunctionalEvent1420_NUMB       NUMERIC(4) = 1420,
          @Lc_Note_INDC                      CHAR(1) = 'N',
          @Lc_BackOut_INDC                   CHAR(1) = 'N',
          @Ls_Routine_TEXT                   VARCHAR(100) = 'BATCH_COMMON$SP_INSERT_RECEIPT',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'BATCH_COMMON$SP_INSERT_RECEIPT',
          @Ln_Case_IDNO                      NUMERIC(6),
          @Ln_PayorMCI_IDNO                  NUMERIC(10),
          @Lc_StatusReceipt_CODE             CHAR(1),
          @Lc_ReasonStatus_CODE              CHAR(4),
          @Ln_EventGlobalBeginSeq_NUMB       NUMERIC(19),
          @Ln_NewEventGlobalSeq_NUMB         NUMERIC(19, 0),
          @Lc_Receipt_TEXT                   CHAR(30),
          @Ln_Held_AMNT                      NUMERIC(11, 2),
          @Ln_Identified_AMNT                NUMERIC(11, 2),
          @Ld_Release_DATE                   DATE,
          @Lc_HoldReason_CODE                CHAR(4),
          @Ln_Distribute_AMNT                NUMERIC(11, 2),
          @Ln_NumDaysHold_QNTY               NUMERIC(9) = 0,
          @Ls_Sql_TEXT                       VARCHAR(100),
          @Ls_Sqldata_TEXT                   VARCHAR(200),
          @Ln_RowCount_QNTY                  NUMERIC(7),
          @Ln_Error_NUMB                     NUMERIC(11),
          @Ln_ErrorLine_NUMB                 NUMERIC(11),
          @Ls_ErrorMessage_TEXT              VARCHAR(2000),
          @Ls_ErrorDesc_TEXT                 VARCHAR(4000);

  BEGIN TRY
   SET @An_NewSeqReceipt_NUMB = 0;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_StatusReceipt_CODE = @Ac_StatusReceipt_CODE;
   SET @Lc_ReasonStatus_CODE = @Ac_ReasonStatus_CODE;

   IF (@Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
       AND @An_CasePayorMCI_IDNO > 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_VCMEM';
     SET @Ls_Sqldata_TEXT = 'CASE_ID  ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '');
     SET @Ln_PayorMCI_IDNO = (SELECT TOP 1 cm.MemberMci_IDNO
                                FROM CMEM_Y1 cm
                               WHERE cm.Case_IDNO = @An_CasePayorMCI_IDNO
                                 AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                 AND cm.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
     SET @Ln_Case_IDNO = @An_CasePayorMCI_IDNO;
  
    END
   ELSE IF (@Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
        AND @An_CasePayorMCI_IDNO > 0)
    BEGIN
     /* The Active CP found make Receipt status as Identified */
     SET @Ls_Sql_TEXT = 'SELECT_VCMEM 2';
     SET @Ls_Sqldata_TEXT = ' PayorMci_ID = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '');
     SET @Ln_PayorMCI_IDNO = @An_CasePayorMCI_IDNO;
     SET @Ln_Case_IDNO = 0;

     IF @Ac_SourceReceipt_CODE IN (@Lc_SourceReceiptCpRecoupment_CODE, @Lc_SourceReceiptCpFeePayment_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_VCMEM CP';

       IF EXISTS (SELECT 1
                    FROM CMEM_Y1 cm
                   WHERE cm.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                     AND cm.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                     AND cm.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
        BEGIN
         SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE;
        END
       ELSE
        
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         SET @As_DescriptionError_TEXT = 'NO ACTIVE CP ';

         RAISERROR(50001,16,1);
        END
     
      END
     /* The Active NCP/PF found make Receipt status as Identified */
     ELSE IF EXISTS (SELECT 1
                  FROM CMEM_Y1 cm
                 WHERE cm.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                   AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                   AND cm.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE)
      BEGIN
       SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE;
      END
     ELSE IF EXISTS (SELECT 1
                  FROM CMEM_Y1 CM
                 WHERE cm.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                   AND cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE))
      BEGIN
       SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE;
       SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonSnna_CODE;
      END
     ELSE
      BEGIN
       SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE;
      END
    END
   
   ELSE IF @Ac_TypePosting_CODE = @Lc_Space_TEXT
       OR LTRIM(RTRIM(@Ac_TypePosting_CODE)) = ''
    BEGIN
     SET @Ln_PayorMCI_IDNO = 0;
     SET @Ln_Case_IDNO = 0;
    END

   SET @Ls_Sql_TEXT = 'SELECT_GENERATE_RECEIPT';
   SET @Ls_Sqldata_TEXT = ' Batch_DATE ' + ISNULL(CONVERT(VARCHAR(10), @Ad_Batch_DATE, 101), '') + ' Batch_NUMB ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ' SourceBatch_CODE ' + ISNULL(@Ac_SourceBatch_CODE, '');

   SELECT @An_NewSeqReceipt_NUMB = RIGHT('000' + CONVERT(VARCHAR, ISNULL(CONVERT(INT, LEFT(MAX(RIGHT (REPLICATE (0, 6) + CONVERT (VARCHAR, R.SeqReceipt_NUMB), 6)), 3)), 0) + 1), 3) + '001'
     FROM RCTH_Y1 R
    WHERE R.Batch_NUMB = @An_Batch_NUMB
      AND R.SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND R.Batch_DATE = @Ad_Batch_DATE;

   SET @Ln_Distribute_AMNT = @An_Receipt_AMNT;

   IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
    BEGIN
     
     --Bug 13447 : CR0384 -- BATCH_COMMON$SP_RECEIPT_ON_HOLD procedure needs to be called only @Ac_NcpRefundRecoverReceipt_INDC value is 'N' i.e No need to check hold instructions when posting new receipt to recover NCP Refund amount - START
	IF @Ac_NcpRefundRecoverReceipt_INDC ='N'
	--Bug 13447 : CR0384 -- BATCH_COMMON$SP_RECEIPT_ON_HOLD procedure needs to be called only @Ac_NcpRefundRecoverReceipt_INDC value is 'N' i.e No need to check hold instructions when posting new receipt to recover NCP Refund amount - START
	BEGIN
		 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_RECEIPT_ON_HOLD';

		 EXECUTE BATCH_COMMON$SP_RECEIPT_ON_HOLD
		  @Ac_TypePosting_CODE      = @Ac_TypePosting_CODE,
		  @An_CasePayorMCI_IDNO     = @An_CasePayorMCI_IDNO,
		  @Ac_SourceReceipt_CODE    = @Ac_SourceReceipt_CODE,
		  @An_Receipt_AMNT          = @An_Receipt_AMNT,
		  @Ad_Receipt_DATE          = @Ad_Receipt_DATE,
		  @Ad_Run_DATE              = @Ld_System_DATE,
		  @Ac_TypeRemittance_CODE   = @Ac_TypeRemittance_CODE,
		  @Ac_SuspendPayment_CODE   = NULL,
		  @Ac_Process_ID		    = @Ac_Screen_ID,
		  @An_Held_AMNT             = @Ln_Held_AMNT OUTPUT,
		  @An_Identified_AMNT       = @Ln_Identified_AMNT OUTPUT,
		  @Ad_Release_Date          = @Ld_Release_DATE OUTPUT,
		  @Ac_ReasonHold_CODE       = @Lc_HoldReason_CODE OUTPUT,
		  @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
		  @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

		 IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
		  BEGIN
		   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_RECEIPT_ON_HOLD_FAILED';

		   RAISERROR(50001,16,1);
		  END
	 END		  
	
     IF @Ln_Held_AMNT > @Ln_Zero_NUMB
      BEGIN
       SET @Ln_Distribute_AMNT = @Ln_Identified_AMNT;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';

       EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
        @An_EventFunctionalSeq_NUMB = @Ln_FunctionalEvent1420_NUMB,
        @Ac_Process_ID              = @Ac_Screen_ID,
        @Ad_EffectiveEvent_Date     = @Ld_System_DATE,
        @Ac_Note_INDC               = @Lc_Note_INDC,
        @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
        @An_EventGlobalSeq_NUMB     = @Ln_NewEventGlobalSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'SPKG_SEQ.BATCH_COMMON$SP_GENERATE_SEQ FAILED';

         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'INSERT_VRCTH_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE ' + ISNULL(CONVERT(VARCHAR(10), @Ad_Batch_DATE, 101), '') + 'Batch_NUMB ' + ISNULL(CAST(@An_Batch_NUMB AS NVARCHAR), '') + 'SeqReceipt_NUMB ' + ISNULL(CAST(@An_NewSeqReceipt_NUMB AS NVARCHAR), '');

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
               CheckNo_TEXT,
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
               ReferenceIrs_IDNO,
               RefundRecipient_ID,
               RefundRecipient_CODE,
               BeginValidity_DATE,
               EndValidity_DATE,
               EventGlobalBeginSeq_NUMB,
               EventGlobalEndSeq_NUMB,
               Release_DATE)
       VALUES ( @Ad_Batch_DATE,--Batch_DATE
                @Ac_SourceBatch_CODE,--SourceBatch_CODE
                @An_Batch_NUMB,--Batch_NUMB
                @An_NewSeqReceipt_NUMB,--SeqReceipt_NUMB
                @Ac_SourceReceipt_CODE,--SourceReceipt_CODE
                @Ac_TypeRemittance_CODE,--TypeRemittance_CODE
                @Ac_TypePosting_CODE,--TypePosting_CODE
                @Ln_Case_IDNO,--Case_IDNO
                @Ln_PayorMCI_IDNO,--PayorMCI_IDNO
                @An_Receipt_AMNT,--Receipt_AMNT
                @Ln_Held_AMNT,--ToDistribute_AMNT
                @An_Fee_AMNT,--Fee_AMNT
                @An_Employer_IDNO,--Employer_IDNO
                @Ac_Fips_CODE,--Fips_CODE
                @Ad_Check_DATE,--Check_DATE
                @Ac_CheckNo_TEXT,--CheckNo_TEXT
                @Ad_Receipt_DATE,--Receipt_DATE
                @Ld_Low_DATE,--Distribute_DATE
                @Ac_Tanf_CODE,--Tanf_CODE
                @Ac_TaxJoint_CODE,--TaxJoint_CODE
                ISNULL(@Ac_TaxJoint_NAME, @Lc_Space_TEXT),--TaxJoint_NAME
                @Lc_StatusReceiptHeld_CODE,--StatusReceipt_CODE
                @Lc_HoldReason_CODE,--ReasonStatus_CODE
                @Lc_BackOut_INDC,--BackOut_INDC
                @Lc_Space_TEXT,--ReasonBackOut_CODE
                @Ld_Low_DATE,--Refund_DATE
                0,--ReferenceIrs_IDNO
                @Lc_Space_TEXT,--RefundRecipient_ID
                @Lc_Space_TEXT,--RefundRecipient_CODE
                @Ld_System_DATE,--BeginValidity_DATE
                @Lc_Highdate_TEXT,--EndValidity_DATE
                @Ln_NewEventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                @Ln_Zero_NUMB,--EventGlobalEndSeq_NUMB
                @Ld_Release_DATE); --Release_DATE

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;
			
       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_VRCTH HOLD FAILED';

         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX_HOLD_1420';
       SET @Ls_Sqldata_TEXT = 'EventGlobalRefundSeq_NUMB ' + ISNULL(CAST(@An_EventGlobalBeginSeq_NUMB AS NVARCHAR), '') + 'EventFunctionalSeq_NUMB ' + ISNULL(CAST(@Ln_FunctionalEvent1420_NUMB AS NVARCHAR), '');
       SET @Lc_Receipt_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO(@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_NewSeqReceipt_NUMB);

       EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
        @An_EventGlobalSeq_NUMB     = @Ln_NewEventGlobalSeq_NUMB,
        @An_EventFunctionalSeq_NUMB = @Ln_FunctionalEvent1420_NUMB,
        @Ac_EntityReceipt_ID        = @Lc_Receipt_TEXT,
        @Ad_EntityReceipt_DATE      = @Ad_Receipt_DATE,
        @An_EntityCase_IDNO         = @Ln_Case_IDNO,
        @An_EntityPayor_IDNO        = @Ln_PayorMCI_IDNO,
        @Ac_EntityCheckNo_TEXT      = @Ac_CheckNo_TEXT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX_1420 FAILED';

         RAISERROR(50001,16,1);
        END
      END
    END

   IF @Ln_Distribute_AMNT > @Ln_Zero_NUMB
    BEGIN
     IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
      SET @Ln_Case_IDNO = 0;

     IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
      SET @Lc_ReasonStatus_CODE = @Lc_HoldReasonUnid_CODE;
     ELSE
      BEGIN
       IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
        BEGIN
         IF @As_DescriptionNote_TEXT > @Lc_Space_TEXT
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT_VUNOT';
           SET @Ls_Sqldata_TEXT = 'SEG ' + ISNULL(CAST(@An_EventGlobalBeginSeq_NUMB AS NVARCHAR), '');

           INSERT UNOT_Y1
                  (EventGlobalSeq_NUMB,
                   EventGlobalApprovalSeq_NUMB,
                   DescriptionNote_TEXT)
           VALUES ( @An_EventGlobalBeginSeq_NUMB,
                    @Ln_Zero_NUMB,
                    @As_DescriptionNote_TEXT)
          END

         SET @Ls_Sql_TEXT = 'SELECT_VUCAT ';
         SET @Ls_Sqldata_TEXT = 'UDC CODE ' + ISNULL(@Lc_ReasonStatus_CODE, '');

         SELECT @Ln_NumDaysHold_QNTY = ISNULL(UCAT_Y1.NumDaysHold_QNTY, 9999)
           FROM UCAT_Y1
          WHERE UCAT_Y1.Udc_CODE = @Lc_ReasonStatus_CODE
            AND UCAT_Y1.EndValidity_DATE = @Ld_High_DATE;
        END
      END

     SET @Ls_Sql_TEXT = 'INSERT RCTH_Y1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE ' + ISNULL(CONVERT(VARCHAR(10), @Ad_Batch_DATE, 101), '') + 'Batch_NUMB ' + ISNULL(CAST(@An_Batch_NUMB AS NVARCHAR), '') + 'SeqReceipt_NUMB ' + ISNULL(CAST(@An_NewSeqReceipt_NUMB AS VARCHAR), '');

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
             CheckNo_TEXT,
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
             ReferenceIrs_IDNO,
             RefundRecipient_ID,
             RefundRecipient_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             Release_DATE)
     VALUES ( @Ad_Batch_DATE,--Batch_DATE
              @Ac_SourceBatch_CODE,--SourceBatch_CODE
              @An_Batch_NUMB,--Batch_NUMB
              @An_NewSeqReceipt_NUMB,--SeqReceipt_NUMB
              @Ac_SourceReceipt_CODE,--SourceReceipt_CODE
              @Ac_TypeRemittance_CODE,--TypeRemittance_CODE
              @Ac_TypePosting_CODE,--TypePosting_CODE
              @Ln_Case_IDNO,--Case_IDNO
              @Ln_PayorMCI_IDNO,--PayorMCI_IDNO
              @An_Receipt_AMNT,--Receipt_AMNT
              @Ln_Distribute_AMNT,--ToDistribute_AMNT
              @An_Fee_AMNT,--Fee_AMNT
              @An_Employer_IDNO,--Employer_IDNO
              @Ac_Fips_CODE,--Fips_CODE
              @Ad_Check_DATE,--Check_DATE
              @Ac_CheckNo_TEXT,--CheckNo_TEXT
              @Ad_Receipt_DATE,--Receipt_DATE
              @Ld_Low_DATE,--Distribute_DATE
              @Ac_Tanf_CODE,--Tanf_CODE
              @Ac_TaxJoint_CODE,--TaxJoint_CODE
              @Ac_TaxJoint_NAME,--TaxJoint_NAME
              @Lc_StatusReceipt_CODE,--StatusReceipt_CODE
              @Lc_ReasonStatus_CODE,--ReasonStatus_CODE
              @Lc_No_INDC,--BackOut_INDC
              @Lc_Space_TEXT,--ReasonBackOut_CODE
              @Ld_Low_DATE,--Refund_DATE
              0,--ReferenceIrs_IDNO
              @Lc_Space_TEXT,--RefundRecipient_ID
              @Lc_Space_TEXT,--RefundRecipient_CODE
              @Ld_System_DATE,--BeginValidity_DATE
              @Ld_High_DATE,--EndValidity_DATE
              @An_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
              @Ln_Zero_NUMB,--EventGlobalEndSeq_NUMB
              CASE @Lc_StatusReceipt_CODE
               WHEN @Lc_StatusReceiptHeld_CODE
                THEN
                CASE @Ln_NumDaysHold_QNTY
                 WHEN 9999
                  THEN @Ld_High_DATE
               ELSE DATEADD (d, @Ln_NumDaysHold_QNTY, @Ad_Receipt_DATE)
                END
               ELSE @Ld_System_DATE
              END ) --Release_DATE 

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_RCTH_V1 FAILED';

       RAISERROR(50001,16,1);
      END
    END

   IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_VURCT';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE ' + ISNULL(CONVERT(VARCHAR(10), @Ad_Batch_DATE, 101), '') + 'Batch_NUMB ' + ISNULL(CAST(@An_Batch_NUMB AS NVARCHAR), '') + 'SeqReceipt_NUMB ' + ISNULL(CAST(@An_NewSeqReceipt_NUMB AS VARCHAR), '');

     INSERT URCT_Y1
            (Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalBeginSeq_NUMB,
             SourceReceipt_CODE,
             Payor_NAME,
             PayorLine1_ADDR,
             PayorLine2_ADDR,
             PayorCity_ADDR,
             PayorState_ADDR,
             PayorZip_ADDR,
             PayorCountry_ADDR,
             Bank_NAME,
             Bank1_ADDR,
             Bank2_ADDR,
             BankCity_ADDR,
             BankState_ADDR,
             BankZip_ADDR,
             BankCountry_ADDR,
             Bank_IDNO,
             BankAcct_NUMB,
             Remarks_TEXT,
             CaseIdent_IDNO,
             IdentifiedPayorMci_IDNO,
             Identified_DATE,
             OtherParty_IDNO,
             IdentificationStatus_CODE,
             Employer_IDNO,
             IvdAgency_IDNO,
             UnidentifiedMemberMci_IDNO,
             UnidentifiedSsn_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE,
             StatusEscheat_DATE,
             StatusEscheat_CODE)
     VALUES ( @Ad_Batch_DATE,--Batch_DATE
              @Ac_SourceBatch_CODE,--SourceBatch_CODE
              @An_Batch_NUMB,--Batch_NUMB
              @An_NewSeqReceipt_NUMB,--SeqReceipt_NUMB
              @An_EventGlobalBeginSeq_NUMB,--EventGlobalBeginSeq_NUMB
              @Ac_SourceReceipt_CODE,--SourceReceipt_CODE
              @Lc_Space_TEXT,--Payor_NAME
              @Lc_Space_TEXT,--PayorLine1_ADDR
              @Lc_Space_TEXT,--PayorLine2_ADDR
              @Lc_Space_TEXT,--PayorCity_ADDR
              @Lc_Space_TEXT,--PayorState_ADDR
              @Lc_Space_TEXT,--PayorZip_ADDR
              @Lc_Space_TEXT,--PayorCountry_ADDR
              @Lc_Space_TEXT,--Bank_NAME
              @Lc_Space_TEXT,--Bank1_ADDR
              @Lc_Space_TEXT,--Bank2_ADDR
              @Lc_Space_TEXT,--BankCity_ADDR
              @Lc_Space_TEXT,--BankState_ADDR
              @Lc_Space_TEXT,--BankZip_ADDR
              @Lc_Space_TEXT,--BankCountry_ADDR
              @Ln_Zero_NUMB,--Bank_IDNO
              @Ln_Zero_NUMB,--BankAcct_NUMB
              @Lc_Space_TEXT,--Remarks_TEXT
              @Ln_Zero_NUMB,--CaseIdent_IDNO
              @Ln_Zero_NUMB,--IdentifiedPayorMci_IDNO
              @Ld_Low_DATE,--Identified_DATE
              @Ln_Zero_NUMB,--OtherParty_IDNO
              @Lc_StatusReceiptUnidentified_CODE,--IdentificationStatus_CODE
              @An_Employer_IDNO,--Employer_IDNO
              @Ln_Zero_NUMB,--IvdAgency_IDNO
              @Ln_Zero_NUMB,--UnidentifiedMemberMci_IDNO
              @Ln_Zero_NUMB,--UnidentifiedSsn_NUMB
              @Ln_Zero_NUMB,--EventGlobalEndSeq_NUMB
              @Ld_System_DATE,--BeginValidity_DATE
              @Ld_High_DATE,--EndValidity_DATE
              @Ld_Low_DATE,--StatusEscheat_DATE
              @Lc_Space_TEXT ) --StatusEscheat_CODE

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT URCT_Y1 FAILED';

       RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
      BEGIN
       IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
        SET @Ln_Case_IDNO = 0;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX_1420';
       SET @Ls_Sqldata_TEXT = 'EventGlobalRefundSeq_NUMB ' + ISNULL(CAST(@An_EventGlobalBeginSeq_NUMB AS NVARCHAR), '') + 'EventFunctionalSeq_NUMB ' + ISNULL(CAST(@Ln_FunctionalEvent1420_NUMB AS NVARCHAR), '');
       SET @Lc_Receipt_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO(@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_NewSeqReceipt_NUMB);

       DECLARE @Ln_TempPayorMCI_IDNO NUMERIC(8);

       SET @Ln_TempPayorMCI_IDNO = ISNULL(@Ln_PayorMCI_IDNO, 0);

       DECLARE @Lc_CheckNo_TEXT CHAR(19);

       SET @Lc_CheckNo_TEXT = ISNULL(@Ac_CheckNo_TEXT, @Lc_Space_TEXT);

       EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
        @An_EventGlobalSeq_NUMB     = @An_EventGlobalBeginSeq_NUMB,
        @An_EventFunctionalSeq_NUMB = @Ln_FunctionalEvent1420_NUMB,
        @Ac_EntityReceipt_ID        = @Lc_Receipt_TEXT,
        @Ad_EntityReceipt_DATE      = @Ad_Receipt_DATE,
        @An_EntityCase_IDNO         = @Ln_Case_IDNO,
        @An_EntityPayor_IDNO        = @Ln_TempPayorMCI_IDNO,
        @Ac_EntityCheckNo_TEXT      = @Lc_CheckNo_TEXT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX_1420 FAILED';

         RAISERROR(50001,16,1);
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE
   SET @Ln_Error_NUMB = ERROR_NUMBER();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ln_ErrorLine_NUMB = ERROR_LINE();
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @As_DescriptionError_TEXT;
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_ErrorDesc_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_ErrorDesc_TEXT;
  END CATCH
 END


GO
