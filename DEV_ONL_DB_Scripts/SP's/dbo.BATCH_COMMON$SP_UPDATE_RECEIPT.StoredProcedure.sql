/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_RECEIPT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_RECEIPT
Programmer Name		: IMP Team
Description			: BATCH_COMMON$SP_UPDATE_RECEIPT 
Frequency			: 
Developed On		: 04/12/2011
Called By			: None
Called ON           :
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_RECEIPT](
 @Ad_Batch_DATE              DATE,
 @Ac_SourceBatch_CODE        CHAR(3),
 @An_Batch_NUMB              NUMERIC(4),
 @An_SeqReceipt_NUMB         NUMERIC(6),
 @Ac_TypeRemittance_CODE     CHAR(3),
 @Ac_TypePosting_CODE        CHAR(1),
 @Ac_SourceReceipt_CODE      CHAR(2),
 @Ac_StatusReceipt_CODE      CHAR(1),
 @Ac_ReasonStatus_CODE       CHAR(4),
 @An_CasePayorMCI_IDNO       NUMERIC(10),
 @An_Employer_IDNO           NUMERIC(9),
 @Ac_Fips_CODE               CHAR(7),
 @Ad_Check_DATE              DATE,
 @Ac_Check_TEXT              CHAR(19),
 @Ad_Receipt_DATE            DATE,
 @An_Receipt_AMNT            NUMERIC(11, 2),
 @Ac_TaxJoint_CODE           CHAR(1),
 @Ac_Tanf_CODE               CHAR(1),
 @Ac_TaxJoint_NAME           CHAR(35),
 @An_EventGlobalRcthSeq_NUMB NUMERIC(19),
 @An_EventGlobalUrctSeq_NUMB NUMERIC(19),
 @An_EventGlobalSeq_NUMB     NUMERIC(19),
 @An_Fee_AMNT                NUMERIC(11, 2),
 @Ac_Screen_ID               CHAR(4),
 @As_DescriptionNote_TEXT    VARCHAR(4000),
 @Ac_SignedOnWorker_ID       CHAR(30),
 @Ac_Msg_CODE                CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Conversion9999_NUMB			 INT = 9999,
          @Li_ReceiptOnHold1420_NUMB         INT = 1420,
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_TypePostingCase_CODE           CHAR(1) = 'C',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_RelationshipCaseNcp_CODE       CHAR(1) = 'A',
          @Lc_RelationshipCaseCp_CODE        CHAR(1) = 'C',
          @Lc_RelationshipCasePutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_TypePostingPayor_CODE          CHAR(1) = 'P',
          @Lc_StatusReceiptIdentified_CODE   CHAR(1) = 'I',
          @Lc_StatusReceiptHeld_CODE         CHAR(1) = 'H',
          @Lc_StatusReceiptM_CODE            CHAR(1) = 'M',
          @Lc_StatusReceiptUnidentified_CODE CHAR(1) = 'U',
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_Note_INDC                      CHAR(1) = 'N',
          @Lc_BackOut_INDC                   CHAR(1) = 'N',
          @Lc_SourceReceiptCpRecoupment_CODE CHAR(2) = 'CR',
          @Lc_SourceReceiptCpFeePayment_CODE CHAR(2) = 'CF',
          @Lc_HoldReasonSnna_CODE            CHAR(4) = 'SNNA',
          @Lc_HoldRsnUnid_CODE               CHAR(4) = 'UNID',
          @Lc_HoldDist_CODE                  CHAR(4) = 'DIST',
          @Lc_InitiateManual_CODE            CHAR(5) = 'MANUAL',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'BATCH_COMMON$SP_UPDATE_RECEIPT',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_CurrentDTTM_DATE               DATETIME = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_System_DATE                    DATETIME2 = CONVERT(VARCHAR(10), DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 121);
  DECLARE @Ln_CasePayor_IDNO             NUMERIC(6),
          @Ln_RowCount_QNTY              NUMERIC(7),
          @Ln_IVDAgency_IDNO             NUMERIC(7, 0),
          @Ln_Employer_IDNO              NUMERIC(9),
          @Ln_UnidentifiedSsn_NUMB       NUMERIC(9),
          @Ln_PayorMCI_IDNO              NUMERIC(10),
          @Ln_Bank_IDNO                  NUMERIC(10),
          @Ln_UnidentifiedMemberMci_IDNO NUMERIC(10),
          @Ln_PayorOld_IDNO              NUMERIC(10),
          @Ln_Case_IDNO                  NUMERIC(10),
          @Ln_Held_AMNT                  NUMERIC(11, 2),
          @Ln_Identified_AMNT            NUMERIC(11, 2),
          @Ln_Distribute_AMNT            NUMERIC(11, 2),
          @Ln_ToDistribute_AMNT          NUMERIC(11, 2),
          @Ln_Error_NUMB                 NUMERIC(11),
          @Ln_ErrorLine_NUMB             NUMERIC(11),
          @Ln_BankAcct_NUMB              NUMERIC(17),
          @Ln_EventGlobalBeginSeq_NUMB   NUMERIC(19),
          @Ln_NewEventGlobalSeq_NUMB     NUMERIC(19, 0),
          @Ln_EventGlobalPrev_NUMB       NUMERIC(19, 0),
          @Ln_EventGlobalOrigSeq_NUMB    NUMERIC(19),
          @Lc_StatusReceipt_CODE         CHAR(1),
          @Lc_StatusReceiptOld_CODE      CHAR(1),
          @Lc_PayorState_ADDR            CHAR(2),
          @Lc_BankState_ADDR             CHAR(2),
          @Lc_SourceReceipt_CODE         CHAR(2),
          @Lc_HoldReason_CODE            CHAR(4),
          @Lc_ReasonStatus_CODE          CHAR(4),
          @Lc_PayorZip_ADDR              CHAR(15),
          @Lc_BankZip_ADDR               CHAR(15),
          @Lc_PayorLine1_ADDR            CHAR(25),
          @Lc_PayorLine2_ADDR            CHAR(25),
          @Lc_PayorCity_ADDR             CHAR(25),
          @Lc_BankLine1_ADDR             CHAR(25),
          @Lc_BankLine2_ADDR             CHAR(25),
          @Lc_BankCity_ADDR              CHAR(25),
          @Lc_Receipt_TEXT               CHAR(30),
          @Lc_PayorCountry_ADDR          CHAR(30),
          @Lc_Bank_NAME                  CHAR(30),
          @Lc_BankCountry_ADDR           CHAR(30),
          @Ls_Payor_NAME                 VARCHAR(71),
          @Ls_Sql_TEXT                   VARCHAR(100),
          @Ls_Sqldata_TEXT               VARCHAR(200),
          @Ls_Remarks_TEXT               VARCHAR(400),
          @Ls_ErrorMessage_TEXT          VARCHAR(2000),
          @Ld_Release_DATE               DATE,
          @Ld_ToRelease_DATE             DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_StatusReceipt_CODE = @Ac_StatusReceipt_CODE;
   SET @Lc_ReasonStatus_CODE = @Ac_ReasonStatus_CODE;
   SET @Ln_Case_IDNO = @An_CasePayorMCI_IDNO;

   IF (@Ac_TypePosting_CODE = @Lc_TypePostingCase_CODE
       AND @An_CasePayorMCI_IDNO > 0)
    BEGIN
     SET @Ln_PayorMCI_IDNO = (SELECT TOP 1 cm.MemberMci_IDNO
                                FROM CMEM_Y1 cm
                               WHERE cm.Case_IDNO = @Ln_Case_IDNO
                                 AND cm.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
                                 AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE);
     SET @Ln_CasePayor_IDNO = @An_CasePayorMCI_IDNO;
    END
   ELSE IF (@Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
       AND @An_CasePayorMCI_IDNO > 0)
    BEGIN
     SET @Ln_PayorMCI_IDNO = @An_CasePayorMCI_IDNO;
     SET @Ln_CasePayor_IDNO = 0;

     /* The Active CP found make Receipt status as Identified */
     IF @Ac_SourceReceipt_CODE IN (@Lc_SourceReceiptCpRecoupment_CODE, @Lc_SourceReceiptCpFeePayment_CODE)
      BEGIN
       IF EXISTS (SELECT 1
                    FROM CMEM_Y1 cm
                   WHERE cm.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                     AND cm.CaseRelationship_CODE = @Lc_RelationshipCasecp_CODE
                     AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
        BEGIN
         SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE;
        END
       ELSE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'NO ACTIVE CP ';

         RAISERROR(50001,16,1);
        END
      END
     /* The Active NCP/PF found make Receipt status as Identified */
     ELSE IF EXISTS (SELECT 1
                  FROM CMEM_Y1 cm
                 WHERE cm.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                   AND cm.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
                   AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
      BEGIN
       SET @Lc_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE;
      END
     ELSE IF EXISTS (SELECT 1
                  FROM CMEM_Y1 CM
                 WHERE cm.MemberMci_IDNO = @Ln_PayorMCI_IDNO
                   AND cm.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE))
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
       OR @Ac_TypePosting_CODE IS NULL
    BEGIN
     SET @Ln_PayorMCI_IDNO = 0;
     SET @Ln_CasePayor_IDNO = 0;
    END

   IF EXISTS (SELECT 1
                FROM RCTH_Y1
               WHERE Batch_DATE = @Ad_Batch_DATE
                 AND Batch_NUMB = @An_Batch_NUMB
                 AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                 AND EventGlobalBeginSeq_NUMB = @An_EventGlobalRcthSeq_NUMB
                 AND EndValidity_DATE = @Ld_High_DATE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_RCTH_Y1 2';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalRcthSeq_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Lc_StatusReceiptOld_CODE = r.StatusReceipt_CODE,
            @Ln_ToDistribute_AMNT = r.ToDistribute_AMNT,
            @Ld_ToRelease_DATE = r.Release_DATE,
            @Ln_EventGlobalPrev_NUMB = r.EventGlobalBeginSeq_NUMB,
            @Ln_EventGlobalOrigSeq_NUMB = r.EventGlobalBeginSeq_NUMB,
            @Ln_PayorOld_IDNO = r.PayorMCI_IDNO
       FROM RCTH_Y1 r
      WHERE r.Batch_DATE = @Ad_Batch_DATE
        AND r.Batch_NUMB = @An_Batch_NUMB
        AND r.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
        AND r.EventGlobalBeginSeq_NUMB = @An_EventGlobalRcthSeq_NUMB
        AND r.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'SELECT_RCTH_Y1 1 FAILED';

     RAISERROR(50001,16,1);
    END

   IF @Lc_StatusReceiptOld_CODE <> @Lc_StatusReceiptHeld_CODE
      AND @Ac_StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_UCAT_Y1 1';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Ac_ReasonStatus_CODE, '') + ', HoldLevel_CODE = ' + ISNULL(@Lc_HoldDist_CODE, '') + ', Initiate_CODE = ' + ISNULL(@Lc_InitiateManual_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ld_ToRelease_DATE = CASE
                                  WHEN ISNULL(u.NumDaysHold_QNTY, @Li_Conversion9999_NUMB) = @Li_Conversion9999_NUMB
                                   THEN @Ld_High_DATE
                                  ELSE DATEADD(D, u.NumDaysHold_QNTY, @Ad_Receipt_DATE)
                                 END
       FROM UCAT_Y1 u
      WHERE u.Udc_CODE = @Ac_ReasonStatus_CODE
        AND u.HoldLevel_CODE = @Lc_HoldDist_CODE
        AND u.Initiate_CODE = @Lc_InitiateManual_CODE
        AND u.EndValidity_DATE = @Ld_High_DATE;

     -- Insert notes entered by the User
     IF @As_DescriptionNote_TEXT > @Lc_Space_TEXT
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT_UNOT_Y1';
       SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalApprovalSeq_NUMB = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT, '');

       INSERT INTO UNOT_Y1
                   (EventGlobalSeq_NUMB,
                    EventGlobalApprovalSeq_NUMB,
                    DescriptionNote_TEXT)
            VALUES (@An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                    0,--EventGlobalApprovalSeq_NUMB
                    @As_DescriptionNote_TEXT --DescriptionNote_TEXT
       );
      END
    END
   ELSE IF @Lc_StatusReceiptOld_CODE = @Lc_StatusReceiptHeld_CODE
      AND @Ac_StatusReceipt_CODE != @Lc_StatusReceiptHeld_CODE
    BEGIN
     SET @Ld_ToRelease_DATE = @Ld_CurrentDTTM_DATE;
    END

   IF @Lc_StatusReceiptOld_CODE = @Lc_StatusReceiptUnidentified_CODE
    BEGIN
     IF @Ac_StatusReceipt_CODE IN (@Lc_StatusReceiptIdentified_CODE, @Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptM_CODE)
      BEGIN
       IF EXISTS (SELECT 1
                    FROM URCT_Y1
                   WHERE Batch_DATE = @Ad_Batch_DATE
                     AND Batch_NUMB = @An_Batch_NUMB
                     AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                     AND SourceBatch_CODE = @Ac_SourceBatch_CODE
                     AND EndValidity_DATE = @Ld_High_DATE)
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT_URCT_Y1 1';
         SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         SELECT @Ln_EventGlobalBeginSeq_NUMB = u.EventGlobalBeginSeq_NUMB,
                @Ls_Payor_NAME = ISNULL(u.Payor_NAME, @Lc_Space_TEXT),
                @Lc_PayorLine1_ADDR = ISNULL(u.PayorLine1_ADDR, @Lc_Space_TEXT),
                @Lc_PayorLine2_ADDR = ISNULL(u.PayorLine2_ADDR, @Lc_Space_TEXT),
                @Lc_PayorCity_ADDR = ISNULL(u.PayorCity_ADDR, @Lc_Space_TEXT),
                @Lc_PayorState_ADDR = ISNULL(u.PayorState_ADDR, @Lc_Space_TEXT),
                @Lc_PayorZip_ADDR = ISNULL(u.PayorZip_ADDR, @Lc_Space_TEXT),
                @Lc_PayorCountry_ADDR = ISNULL(u.PayorCountry_ADDR, @Lc_Space_TEXT),
                @Lc_Bank_NAME = ISNULL(u.Bank_NAME, @Lc_Space_TEXT),
                @Lc_BankLine1_ADDR = ISNULL(u.Bank1_ADDR, @Lc_Space_TEXT),
                @Lc_BankLine2_ADDR = ISNULL(u.Bank2_ADDR, @Lc_Space_TEXT),
                @Lc_BankCity_ADDR = ISNULL(u.BankCity_ADDR, @Lc_Space_TEXT),
                @Lc_BankState_ADDR = ISNULL(u.BankState_ADDR, @Lc_Space_TEXT),
                @Lc_BankZip_ADDR = ISNULL(u.BankZip_ADDR, @Lc_Space_TEXT),
                @Lc_BankCountry_ADDR = ISNULL(u.BankCountry_ADDR, @Lc_Space_TEXT),
                @Ln_Bank_IDNO = ISNULL(Bank_IDNO, 0),
                @Ln_BankAcct_NUMB = ISNULL(BankAcct_NUMB, 0),
                @Ls_Remarks_TEXT = ISNULL(Remarks_TEXT, @Lc_Space_TEXT),
                @Ln_Employer_IDNO = Employer_IDNO,
                @Lc_SourceReceipt_CODE = SourceReceipt_CODE,
                @Ln_IVDAgency_IDNO = IvdAgency_IDNO,
                @Ln_UnidentifiedMemberMci_IDNO = UnidentifiedMemberMci_IDNO,
                @Ln_UnidentifiedSsn_NUMB = UnidentifiedSsn_NUMB
           FROM URCT_Y1 u
          WHERE u.Batch_DATE = @Ad_Batch_DATE
            AND u.Batch_NUMB = @An_Batch_NUMB
            AND u.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
            AND u.SourceBatch_CODE = @Ac_SourceBatch_CODE
            AND u.EndValidity_DATE = @Ld_High_DATE;
            
         --Concurrency check
         IF @An_EventGlobalUrctSeq_NUMB <> @Ln_EventGlobalBeginSeq_NUMB
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'EventGlobalUrctSeq_NUMB <> EventGlobalBeginSeq_NUMB';
           
           RAISERROR(50001,16,1);
          END
        END
       ELSE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE RCTH_Y1 FAILED - 1';

         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'UPDATE_URCT_Y1 2';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', IdentificationStatus_CODE = ' + ISNULL(@Lc_StatusReceiptUnidentified_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE URCT_Y1
          SET EndValidity_DATE = @Ld_CurrentDTTM_DATE,
              EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
        WHERE Batch_DATE = @Ad_Batch_DATE
          AND Batch_NUMB = @An_Batch_NUMB
          AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
          AND SourceBatch_CODE = @Ac_SourceBatch_CODE
          AND IdentificationStatus_CODE = @Lc_StatusReceiptUnidentified_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE_URCT_Y1 FAILED 2';

         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'INSERT_URCT_Y1';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE, '') + ', Payor_NAME = ' + ISNULL(@Ls_Payor_NAME, '') + ', PayorLine1_ADDR = ' + ISNULL(@Lc_PayorLine1_ADDR, '') + ', PayorLine2_ADDR = ' + ISNULL(@Lc_PayorLine2_ADDR, '') + ', PayorCity_ADDR = ' + ISNULL(@Lc_PayorCity_ADDR, '') + ', PayorState_ADDR = ' + ISNULL(@Lc_PayorState_ADDR, '') + ', PayorZip_ADDR = ' + ISNULL(@Lc_PayorZip_ADDR, '') + ', PayorCountry_ADDR = ' + ISNULL(@Lc_PayorCountry_ADDR, '') + ', Bank_NAME = ' + ISNULL(@Lc_Bank_NAME, '') + ', Bank1_ADDR = ' + ISNULL(@Lc_BankLine1_ADDR, '') + ', Bank2_ADDR = ' + ISNULL(@Lc_BankLine2_ADDR, '') + ', BankCity_ADDR = ' + ISNULL(@Lc_BankCity_ADDR, '') + ', BankState_ADDR = ' + ISNULL(@Lc_BankState_ADDR, '') + ', BankZip_ADDR = ' + ISNULL(@Lc_BankZip_ADDR, '') + ', BankCountry_ADDR = ' + ISNULL(@Lc_BankCountry_ADDR, '') + ', Bank_IDNO = ' + ISNULL(CAST(@Ln_Bank_IDNO AS VARCHAR), '') + ', BankAcct_NUMB = ' + ISNULL(CAST(@Ln_BankAcct_NUMB AS VARCHAR), '') + ', Remarks_TEXT = ' + ISNULL(@Ls_Remarks_TEXT, '') + ', CaseIdent_IDNO = ' + ISNULL(CAST(@Ln_CasePayor_IDNO AS VARCHAR), '') + ', IdentifiedPayorMci_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', Identified_DATE = ' + ISNULL(CAST(@Ld_CurrentDTTM_DATE AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', IdentificationStatus_CODE = ' + ISNULL(@Lc_StatusReceiptIdentified_CODE, '') + ', Employer_IDNO = ' + ISNULL(CAST(@Ln_Employer_IDNO AS VARCHAR), '') + ', IvdAgency_IDNO = ' + ISNULL(CAST(@Ln_IVDAgency_IDNO AS VARCHAR), '') + ', UnidentifiedMemberMci_IDNO = ' + ISNULL(CAST(@Ln_UnidentifiedMemberMci_IDNO AS VARCHAR), '') + ', UnidentifiedSsn_NUMB = ' + ISNULL(CAST(@Ln_UnidentifiedSsn_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_CurrentDTTM_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', StatusEscheat_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

       INSERT INTO URCT_Y1
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
                     @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
                     @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                     @Lc_SourceReceipt_CODE,--SourceReceipt_CODE
                     @Ls_Payor_NAME,--Payor_NAME
                     @Lc_PayorLine1_ADDR,--PayorLine1_ADDR
                     @Lc_PayorLine2_ADDR,--PayorLine2_ADDR
                     @Lc_PayorCity_ADDR,--PayorCity_ADDR
                     @Lc_PayorState_ADDR,--PayorState_ADDR
                     @Lc_PayorZip_ADDR,--PayorZip_ADDR
                     @Lc_PayorCountry_ADDR,--PayorCountry_ADDR
                     @Lc_Bank_NAME,--Bank_NAME
                     @Lc_BankLine1_ADDR,--Bank1_ADDR
                     @Lc_BankLine2_ADDR,--Bank2_ADDR
                     @Lc_BankCity_ADDR,--BankCity_ADDR
                     @Lc_BankState_ADDR,--BankState_ADDR
                     @Lc_BankZip_ADDR,--BankZip_ADDR
                     @Lc_BankCountry_ADDR,--BankCountry_ADDR
                     @Ln_Bank_IDNO,--Bank_IDNO
                     @Ln_BankAcct_NUMB,--BankAcct_NUMB
                     @Ls_Remarks_TEXT,--Remarks_TEXT
                     @Ln_CasePayor_IDNO,--CaseIdent_IDNO
                     @Ln_PayorMCI_IDNO,--IdentifiedPayorMci_IDNO
                     @Ld_CurrentDTTM_DATE,--Identified_DATE
                     0,--OtherParty_IDNO
                     @Lc_StatusReceiptIdentified_CODE,--IdentificationStatus_CODE
                     @Ln_Employer_IDNO,--Employer_IDNO
                     @Ln_IVDAgency_IDNO,--IvdAgency_IDNO
                     @Ln_UnidentifiedMemberMci_IDNO,--UnidentifiedMemberMci_IDNO
                     @Ln_UnidentifiedSsn_NUMB,--UnidentifiedSsn_NUMB
                     0,--EventGlobalEndSeq_NUMB
                     @Ld_CurrentDTTM_DATE,--BeginValidity_DATE
                     @Ld_High_DATE,--EndValidity_DATE
                     @Ld_Low_DATE,--StatusEscheat_DATE
                     @Lc_Space_TEXT --StatusEscheat_CODE
       );

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_URCT_Y1 FAILED';

         RAISERROR(50001,16,1);
        END
      END
    END

   SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1';
   SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE RCTH_Y1
      SET EndValidity_DATE = @Ld_System_DATE,
          EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
    WHERE Batch_DATE = @Ad_Batch_DATE
      AND Batch_NUMB = @An_Batch_NUMB
      AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
      AND SourceBatch_CODE = @Ac_SourceBatch_CODE
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'UPDATE RCTH_Y1 FAILED - 2';

     RAISERROR(50001,16,1);
    END

   SET @Ln_Distribute_AMNT = @An_Receipt_AMNT;

   IF @Ac_StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_RECEIPT_ON_HOLD';
     SET @Ls_Sqldata_TEXT = 'TypePosting_CODE = ' + ISNULL(@Ac_TypePosting_CODE, '') + ', CasePayorMCI_IDNO = ' + ISNULL(CAST(@An_CasePayorMCI_IDNO AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE, '') + ', Receipt_AMNT = ' + ISNULL(CAST(@An_Receipt_AMNT AS VARCHAR), '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ad_Receipt_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_System_DATE AS VARCHAR), '') + ', TypeRemittance_CODE = ' + ISNULL(@Ac_TypeRemittance_CODE, '');

     EXECUTE BATCH_COMMON$SP_RECEIPT_ON_HOLD
      @Ac_TypePosting_CODE      = @Ac_TypePosting_CODE,
      @An_CasePayorMCI_IDNO     = @An_CasePayorMCI_IDNO,
      @Ac_SourceReceipt_CODE    = @Ac_SourceReceipt_CODE,
      @An_Receipt_AMNT          = @An_Receipt_AMNT,
      @Ad_Receipt_DATE          = @Ad_Receipt_DATE,
      @Ad_Run_DATE              = @Ld_System_DATE,
      @Ac_TypeRemittance_CODE   = @Ac_TypeRemittance_CODE,
      @Ac_SuspendPayment_CODE   = NULL,
      @Ac_Process_ID			= @Ac_Screen_ID,
      @An_Held_AMNT             = @Ln_Held_AMNT OUTPUT,
      @An_Identified_AMNT       = @Ln_Identified_AMNT OUTPUT,
      @Ad_Release_Date          = @Ld_Release_DATE OUTPUT,
      @Ac_ReasonHold_CODE       = @Lc_HoldReason_CODE OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_RECEIPT_ON_HOLD_FAILED';

       RAISERROR(50001,16,1);
      END

     IF @Ln_Held_AMNT > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
       SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_Screen_ID, '') + ', EffectiveEvent_Date = ' + ISNULL(CAST(@Ld_System_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', Worker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '');

       EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
        @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
        @Ac_Process_ID              = @Ac_Screen_ID,
        @Ad_EffectiveEvent_Date     = @Ld_System_DATE,
        @Ac_Note_INDC               = @Lc_Note_INDC,
        @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
        @An_EventGlobalSeq_NUMB     = @Ln_NewEventGlobalSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ FAILED';

         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1_HOLD';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE, '') + ', TypeRemittance_CODE = ' + ISNULL(@Ac_TypeRemittance_CODE, '') + ', TypePosting_CODE = ' + ISNULL(@Ac_TypePosting_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CasePayor_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', Receipt_AMNT = ' + ISNULL(CAST(@An_Receipt_AMNT AS VARCHAR), '') + ', ToDistribute_AMNT = ' + ISNULL(CAST(@Ln_Held_AMNT AS VARCHAR), '') + ', Fee_AMNT = ' + ISNULL(CAST(@An_Fee_AMNT AS VARCHAR), '') + ', Employer_IDNO = ' + ISNULL(CAST(@An_Employer_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Ac_Fips_CODE, '') + ', Check_DATE = ' + ISNULL(CAST(@Ad_Check_DATE AS VARCHAR), '') + ', CheckNo_TEXT = ' + ISNULL(@Ac_Check_TEXT, '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ad_Receipt_DATE AS VARCHAR), '') + ', Distribute_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Tanf_CODE = ' + ISNULL(@Ac_Tanf_CODE, '') + ', TaxJoint_CODE = ' + ISNULL(@Ac_TaxJoint_CODE, '') + ', TaxJoint_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptHeld_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_HoldReason_CODE, '') + ', BackOut_INDC = ' + ISNULL(@Lc_BackOut_INDC, '') + ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Refund_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ReferenceIrs_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', RefundRecipient_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', RefundRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_System_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_NewEventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', Release_DATE = ' + ISNULL(CAST(@Ld_Release_DATE AS VARCHAR), '');

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
                @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
                @Ac_SourceReceipt_CODE,--SourceReceipt_CODE
                @Ac_TypeRemittance_CODE,--TypeRemittance_CODE
                @Ac_TypePosting_CODE,--TypePosting_CODE
                @Ln_CasePayor_IDNO,--Case_IDNO
                @Ln_PayorMCI_IDNO,--PayorMCI_IDNO
                @An_Receipt_AMNT,--Receipt_AMNT
                @Ln_Held_AMNT,--ToDistribute_AMNT
                @An_Fee_AMNT,--Fee_AMNT
                @An_Employer_IDNO,--Employer_IDNO
                @Ac_Fips_CODE,--Fips_CODE
                @Ad_Check_DATE,--Check_DATE
                @Ac_Check_TEXT,--CheckNo_TEXT
                @Ad_Receipt_DATE,--Receipt_DATE
                @Ld_Low_DATE,--Distribute_DATE
                @Ac_Tanf_CODE,--Tanf_CODE
                @Ac_TaxJoint_CODE,--TaxJoint_CODE
                @Lc_Space_TEXT,--TaxJoint_NAME
                @Lc_StatusReceiptHeld_CODE,--StatusReceipt_CODE
                @Lc_HoldReason_CODE,--ReasonStatus_CODE
                @Lc_BackOut_INDC,--BackOut_INDC
                @Lc_Space_TEXT,--ReasonBackOut_CODE
                @Ld_Low_DATE,--Refund_DATE
                0,--ReferenceIrs_IDNO
                @Lc_Space_TEXT,--RefundRecipient_ID
                @Lc_Space_TEXT,--RefundRecipient_CODE
                @Ld_System_DATE,--BeginValidity_DATE
                @Ld_High_DATE,--EndValidity_DATE
                @Ln_NewEventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                0,--EventGlobalEndSeq_NUMB
                @Ld_Release_DATE --Release_DATE
       );

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT_RCTH_Y1_HOLD FAILED';

         RAISERROR(50001,16,1);
        END

       SET @Ln_Distribute_AMNT = @Ln_Identified_AMNT;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX_HOLD_1420';
       SET @Lc_Receipt_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO(@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB);
       SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_NewEventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_ReceiptOnHold1420_NUMB AS VARCHAR), '') + ', EntityReceipt_ID = ' + ISNULL(@Lc_Receipt_TEXT, '') + ', EntityReceipt_DATE = ' + ISNULL(CAST(@Ad_Receipt_DATE AS VARCHAR), '') + ', EntityCase_IDNO = ' + ISNULL(CAST(@Ln_CasePayor_IDNO AS VARCHAR), '') + ', EntityPayor_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', EntityCheckNo_TEXT = ' + ISNULL(@Ac_Check_TEXT, '');

       EXECUTE BATCH_COMMON$SP_ENTITY_MATRIX
        @An_EventGlobalSeq_NUMB     = @Ln_NewEventGlobalSeq_NUMB,
        @An_EventFunctionalSeq_NUMB = @Li_ReceiptOnHold1420_NUMB,
        @Ac_EntityReceipt_ID        = @Lc_Receipt_TEXT,
        @Ad_EntityReceipt_DATE      = @Ad_Receipt_DATE,
        @An_EntityCase_IDNO         = @Ln_CasePayor_IDNO,
        @An_EntityPayor_IDNO        = @Ln_PayorMCI_IDNO,
        @Ac_EntityCheckNo_TEXT      = @Ac_Check_TEXT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END
    END

   IF @Ln_Distribute_AMNT > 0
    BEGIN
     IF @Ac_TypePosting_CODE = @Lc_TypePostingPayor_CODE
      BEGIN
       SET @Ln_CasePayor_IDNO = 0;
      END

     IF @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
      BEGIN
       SET @Lc_ReasonStatus_CODE = @Lc_HoldRsnUnid_CODE;
      END

     SET @Ls_Sql_TEXT = 'INSERT_RCTH_Y1';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL(@Ac_SourceReceipt_CODE, '') + ', TypeRemittance_CODE = ' + ISNULL(@Ac_TypeRemittance_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CasePayor_IDNO AS VARCHAR), '') + ', PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_PayorMCI_IDNO AS VARCHAR), '') + ', Receipt_AMNT = ' + ISNULL(CAST(@An_Receipt_AMNT AS VARCHAR), '') + ', ToDistribute_AMNT = ' + ISNULL(CAST(@Ln_Distribute_AMNT AS VARCHAR), '') + ', Fee_AMNT = ' + ISNULL(CAST(@An_Fee_AMNT AS VARCHAR), '') + ', Employer_IDNO = ' + ISNULL(CAST(@An_Employer_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Ac_Fips_CODE, '') + ', Check_DATE = ' + ISNULL(CAST(@Ad_Check_DATE AS VARCHAR), '') + ', CheckNo_TEXT = ' + ISNULL(@Ac_Check_TEXT, '') + ', Receipt_DATE = ' + ISNULL(CAST(@Ad_Receipt_DATE AS VARCHAR), '') + ', Distribute_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Tanf_CODE = ' + ISNULL(@Ac_Tanf_CODE, '') + ', TaxJoint_CODE = ' + ISNULL(@Ac_TaxJoint_CODE, '') + ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceipt_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', BackOut_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', ReasonBackOut_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Refund_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ReferenceIrs_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', RefundRecipient_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', RefundRecipient_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_System_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', Release_DATE = ' + ISNULL(CAST(@Ld_ToRelease_DATE AS VARCHAR), '');

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
              @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
              @Ac_SourceReceipt_CODE,--SourceReceipt_CODE
              @Ac_TypeRemittance_CODE,--TypeRemittance_CODE
              ISNULL(@Ac_TypePosting_CODE, @Lc_Space_TEXT),--TypePosting_CODE
              @Ln_CasePayor_IDNO,--Case_IDNO
              @Ln_PayorMCI_IDNO,--PayorMCI_IDNO
              @An_Receipt_AMNT,--Receipt_AMNT
              @Ln_Distribute_AMNT,--ToDistribute_AMNT
              @An_Fee_AMNT,--Fee_AMNT
              @An_Employer_IDNO,--Employer_IDNO
              @Ac_Fips_CODE,--Fips_CODE
              @Ad_Check_DATE,--Check_DATE
              @Ac_Check_TEXT,--CheckNo_TEXT
              @Ad_Receipt_DATE,--Receipt_DATE
              @Ld_Low_DATE,--Distribute_DATE
              @Ac_Tanf_CODE,--Tanf_CODE
              @Ac_TaxJoint_CODE,--TaxJoint_CODE
              ISNULL(@Ac_TaxJoint_NAME, @Lc_Space_TEXT),--TaxJoint_NAME
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
              @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
              0,--EventGlobalEndSeq_NUMB
              @Ld_ToRelease_DATE --Release_DATE
     );

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_RCTH_Y1 FAILED';

       RAISERROR(50001,16,1);
      END
    END

   IF @Lc_StatusReceiptOld_CODE <> @Lc_StatusReceiptUnidentified_CODE
      AND @Lc_StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT_URCT_Y1';
     SET @Lc_SourceReceipt_CODE = @Ac_SourceReceipt_CODE;

     IF EXISTS (SELECT 1
                  FROM URCT_Y1
                 WHERE Batch_DATE = @Ad_Batch_DATE
                   AND Batch_NUMB = @An_Batch_NUMB
                   AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
                   AND SourceBatch_CODE = @Ac_SourceBatch_CODE
                   AND EndValidity_DATE = @Ld_High_DATE)
      BEGIN
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ls_Payor_NAME = ISNULL(u.Payor_NAME, @Lc_Space_TEXT),
              @Lc_PayorLine1_ADDR = ISNULL(u.PayorLine1_ADDR, @Lc_Space_TEXT),
              @Lc_PayorLine2_ADDR = ISNULL(u.PayorLine2_ADDR, @Lc_Space_TEXT),
              @Lc_PayorCity_ADDR = ISNULL(u.PayorCity_ADDR, @Lc_Space_TEXT),
              @Lc_PayorState_ADDR = ISNULL(u.PayorState_ADDR, @Lc_Space_TEXT),
              @Lc_PayorZip_ADDR = ISNULL(u.PayorZip_ADDR, @Lc_Space_TEXT),
              @Lc_PayorCountry_ADDR = ISNULL(u.PayorCountry_ADDR, @Lc_Space_TEXT),
              @Lc_Bank_NAME = ISNULL(u.Bank_NAME, @Lc_Space_TEXT),
              @Lc_BankLine1_ADDR = ISNULL(u.Bank1_ADDR, @Lc_Space_TEXT),
              @Lc_BankLine2_ADDR = ISNULL(u.Bank2_ADDR, @Lc_Space_TEXT),
              @Lc_BankCity_ADDR = ISNULL(u.BankCity_ADDR, @Lc_Space_TEXT),
              @Lc_BankState_ADDR = ISNULL(u.BankState_ADDR, @Lc_Space_TEXT),
              @Lc_BankZip_ADDR = ISNULL(u.BankZip_ADDR, @Lc_Space_TEXT),
              @Lc_BankCountry_ADDR = ISNULL(u.BankCountry_ADDR, @Lc_Space_TEXT),
              @Ln_Bank_IDNO = ISNULL(u.Bank_IDNO, 0),
              @Ln_BankAcct_NUMB = ISNULL(u.BankAcct_NUMB, 0),
              @Ls_Remarks_TEXT = ISNULL(u.Remarks_TEXT, @Lc_Space_TEXT),
              @Ln_Employer_IDNO = u.Employer_IDNO,
              @Lc_SourceReceipt_CODE = u.SourceReceipt_CODE,
              @Ln_IVDAgency_IDNO = u.IvdAgency_IDNO,
              @Ln_UnidentifiedMemberMci_IDNO = u.UnidentifiedMemberMci_IDNO,
              @Ln_UnidentifiedSsn_NUMB = u.UnidentifiedSsn_NUMB
         FROM URCT_Y1 u
        WHERE u.Batch_DATE = @Ad_Batch_DATE
          AND u.Batch_NUMB = @An_Batch_NUMB
          AND u.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
          AND u.SourceBatch_CODE = @Ac_SourceBatch_CODE
          AND u.EndValidity_DATE = @Ld_High_DATE;

       SET @Ls_Sql_TEXT = 'UPDATE_URCT_Y1';
       SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE URCT_Y1
          SET EndValidity_DATE = @Ld_CurrentDTTM_DATE,
              EventGlobalEndSeq_NUMB = @An_EventGlobalSeq_NUMB
        WHERE Batch_DATE = @Ad_Batch_DATE
          AND Batch_NUMB = @An_Batch_NUMB
          AND SeqReceipt_NUMB = @An_SeqReceipt_NUMB
          AND SourceBatch_CODE = @Ac_SourceBatch_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE URCT_Y1 FAILED';

         RAISERROR(50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'INSERT_URCT_Y1 2';
     SET @Ls_Sqldata_TEXT = 'Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', SourceReceipt_CODE = ' + ISNULL(@Lc_SourceReceipt_CODE, '') + ', CaseIdent_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', IdentifiedPayorMci_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', Identified_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', IdentificationStatus_CODE = ' + ISNULL(@Lc_StatusReceiptUnidentified_CODE, '') + ', Employer_IDNO = ' + ISNULL(CAST(@An_Employer_IDNO AS VARCHAR), '') + ', IvdAgency_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', UnidentifiedMemberMci_IDNO = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', UnidentifiedSsn_NUMB = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST('0' AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_CurrentDTTM_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', StatusEscheat_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

     INSERT INTO URCT_Y1
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
                   @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
                   @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                   @Lc_SourceReceipt_CODE,--SourceReceipt_CODE
                   ISNULL(@Ls_Payor_NAME, @Lc_Space_TEXT),--Payor_NAME
                   ISNULL(@Lc_PayorLine1_ADDR, @Lc_Space_TEXT),--PayorLine1_ADDR
                   ISNULL(@Lc_PayorLine2_ADDR, @Lc_Space_TEXT),--PayorLine2_ADDR
                   ISNULL(@Lc_PayorCity_ADDR, @Lc_Space_TEXT),--PayorCity_ADDR
                   ISNULL(@Lc_PayorState_ADDR, @Lc_Space_TEXT),--PayorState_ADDR
                   ISNULL(@Lc_PayorZip_ADDR, @Lc_Space_TEXT),--PayorZip_ADDR
                   ISNULL(@Lc_PayorCountry_ADDR, @Lc_Space_TEXT),--PayorCountry_ADDR
                   ISNULL(@Lc_Bank_NAME, @Lc_Space_TEXT),--Bank_NAME
                   ISNULL(@Lc_BankLine1_ADDR, @Lc_Space_TEXT),--Bank1_ADDR
                   ISNULL(@Lc_BankLine2_ADDR, @Lc_Space_TEXT),--Bank2_ADDR
                   ISNULL(@Lc_BankCity_ADDR, @Lc_Space_TEXT),--BankCity_ADDR
                   ISNULL(@Lc_BankState_ADDR, @Lc_Space_TEXT),--BankState_ADDR
                   ISNULL(@Lc_BankZip_ADDR, @Lc_Space_TEXT),--BankZip_ADDR
                   ISNULL(@Lc_BankCountry_ADDR, @Lc_Space_TEXT),--BankCountry_ADDR
                   ISNULL(@Ln_Bank_IDNO, 0),--Bank_IDNO
                   ISNULL(@Ln_BankAcct_NUMB, 0),--BankAcct_NUMB
                   ISNULL(@Ls_Remarks_TEXT, @Lc_Space_TEXT),--Remarks_TEXT
                   0,--CaseIdent_IDNO
                   0,--IdentifiedPayorMci_IDNO
                   @Ld_Low_DATE,--Identified_DATE
                   0,--OtherParty_IDNO
                   @Lc_StatusReceiptUnidentified_CODE,--IdentificationStatus_CODE
                   @An_Employer_IDNO,--Employer_IDNO
                   0,--IvdAgency_IDNO
                   0,--UnidentifiedMemberMci_IDNO
                   0,--UnidentifiedSsn_NUMB
                   0,--EventGlobalEndSeq_NUMB
                   @Ld_CurrentDTTM_DATE,--BeginValidity_DATE
                   @Ld_High_DATE,--EndValidity_DATE
                   @Ld_Low_DATE,--StatusEscheat_DATE
                   @Lc_Space_TEXT --StatusEscheat_CODE
     );

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_URCT_Y1 FAILED 2';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
 END;


GO
