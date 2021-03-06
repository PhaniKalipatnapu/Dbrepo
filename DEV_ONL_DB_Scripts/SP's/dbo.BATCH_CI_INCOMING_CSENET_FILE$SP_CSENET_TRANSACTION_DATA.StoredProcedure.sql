/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_TRANSACTION_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_TRANSACTION_DATA
Programmer Name	:	IMP Team.
Description		:	This process loads the inbound CSENET transaction into tables according to the data blocks in the file
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_TRANSACTION_DATA]
 @Ac_ExchangeMode_CODE     CHAR(1),
 @Ac_TranStatus_CODE       CHAR(2),
 @Ac_RejectReason_CODE     CHAR(5),
 @Ac_JobProcess_IDNO       CHAR(7),
 @Ad_Run_DATE              DATE,
 @Ac_WorkerUpdate_ID       CHAR(30),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StringZero_TEXT           CHAR(1) = '0',
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_No_INDC                   CHAR(1) = 'N',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_Yes_INDC                  CHAR(1) = 'Y',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_DuplicateX1_INDC          CHAR(1) = 'X',
          @Lc_InputDirection_TEXT       CHAR(1) = 'I',
          @Lc_OthpEmployer_CODE         CHAR(1) = 'E',
          @Lc_NcpLocateBlock_TEXT       CHAR(30) = 'NCP_LOCATE_BLOCK',
          @Lc_CaseDataBlock_TEXT        CHAR(30) = 'CASE_DATA_BLOCKS',
          @Lc_NcpDataBlock_TEXT         CHAR(30) = 'NCP_DATA_BLOCKS',
          @Lc_OrderDataBlock_TEXT       CHAR(30) = 'ORDER_DATA_BLOCKS',
          @Lc_CaseType_TEXT             CHAR(30) = 'CASE_TYPE_CODE',
          @Lc_NonDisclosureFinding_TEXT CHAR(30) = 'NONDISCLOSURE_FINDING_INDC',
          @Lc_Race_TEXT                 CHAR(30) = 'RACE_CODE',
          @Lc_MemSex_TEXT               CHAR(30) = 'MEM_SEX',
          @Lc_HairColor_TEXT            CHAR(30) = 'HAIR_COLOR_CODE',
          @Lc_EyeColor_TEXT             CHAR(30) = 'EYE_COLOR_CODE',
          @Lc_ResidentialConfirmed_TEXT CHAR(30) = 'RESIDENTIAL_CONFIRMED_INDC',
          @Lc_MailingConfirmed_TEXT     CHAR(30) = 'MAILING_CONFIRMED_INDC',
          @Lc_EmployerConfirmed_TEXT    CHAR(30) = 'EMPLOYER_CONFIRMED_INDC',
          @Lc_TypeOrder_TEXT            CHAR(30) = 'TYPE_ORDER_CODE',
          @Lc_TypeDebt_TEXT             CHAR(30) = 'DEBT_TYPE_CODE',
          @Lc_OrderFreq_TEXT            CHAR(30) = 'ORDER_FREQ_CODE',
          @Lc_FreqOrderArrears_TEXT     CHAR(30) = 'FREQ_ORDER_ARREARS_CODE',
          @Lc_MedicalOrdered_TEXT       CHAR(30) = 'MEDICAL_ORDERED_INDC',
          @Ls_Procedure_NAME            VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE$SP_CSENET_TRANSACTION_DATA',
          @Ld_Low_DATE                  DATE = '01/01/0001',
          @Ld_High_DATE                 DATE = '12/31/9999',
          @Lb_BlockUnprocessed_BIT      BIT = 1;
  DECLARE @Ln_Rec_QNTY                 NUMERIC(6) = 0,
          @Ln_ticeCount_NUMB           NUMERIC(6) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Li_RowCount_QNTY            INT,
          @Li_Error_NUMB               INT,
          @Li_ErrorLine_NUMB           INT,
          @Li_Zero_NUMB                SMALLINT = 0,
          @Li_FetchStatus_QNTY         SMALLINT,
          @Lc_Empty_TEXT               CHAR(1) = '',
          @Lc_Msg_CODE                 CHAR(5) = '',
          @Ls_Sql_TEXT                 VARCHAR(200) = '',
          @Ls_DescriptionError_TEXT    VARCHAR(1000) = '',
          @Ls_Sqldata_TEXT             VARCHAR(4000) = '',
          @Ld_Start_DTTM               DATETIME2;
  --CURSOR Variable Declaration
  DECLARE @Ln_FVoilenceCur_MemberMci_IDNO   CHAR(10),
          @Ln_FVoilenceCur_Case_IDNO        NUMERIC(6),
          @Ld_FVoilenceCur_Transaction_DATE DATE;
  DECLARE @Ln_AttachmentCur_TransHeader_IDNO       NUMERIC(12),
          @Lc_AttachmentCur_IVDOutOfStateFips_CODE CHAR(2),
          @Ld_AttachmentCur_Transaction_DATE       DATE,
          @Lc_AttachmentCur_Notice_ID              CHAR(8);

  BEGIN TRY
   SET @Ld_Start_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'INSERT CTHB_Y1';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE LTHBL_Y1
      SET Case_IDNO = REPLACE(REPLACE(REPLACE(REPLACE(CASE_IDNO, ',', ''), '.', ''), '+', ''), '-', '');

   SET @Ls_Sql_TEXT = 'INSERT CTHB_Y1';
   SET @Ls_Sqldata_TEXT = 'ExchangeMode_CODE = ' + ISNULL(@Ac_ExchangeMode_CODE, '') + ', TimeSent_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Due_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Response_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Overdue_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', End_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   INSERT CTHB_Y1
          (Message_ID,
           IoDirection_CODE,
           StateFips_CODE,
           CountyFips_CODE,
           OfficeFips_CODE,
           IVDOutOfStateCase_ID,
           IVDOutOfStateFips_CODE,
           IVDOutOfStateCountyFips_CODE,
           IVDOutOfStateOfficeFips_CODE,
           CsenetTran_ID,
           Function_CODE,
           Action_CODE,
           Reason_CODE,
           Case_IDNO,
           ExchangeMode_CODE,
           TranStatus_CODE,
           AttachDue_DATE,
           InterstateFrmsPrint_CODE,
           TimeSent_DATE,
           Due_DATE,
           Response_DATE,
           Overdue_CODE,
           WorkerUpdate_ID,
           Transaction_DATE,
           ActionResolution_DATE,
           Attachments_INDC,
           CaseData_QNTY,
           Ncp_QNTY,
           NcpLoc_QNTY,
           Participant_QNTY,
           Order_QNTY,
           Collection_QNTY,
           Info_QNTY,
           End_DATE,
           CsenetVersion_ID,
           ErrorReason_CODE,
           Received_DTTM,
           RejectReason_CODE,
           Transaction_IDNO,
           Trans3Printed_INDC)
   SELECT a.Message_ID,
          a.IoDirection_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.StateFips_CODE)), 2) AS StateFips_CODE,
          RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(a.CountyFips_CODE)), 3) AS CountyFips_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.OfficeFips_CODE)), 2) AS OfficeFips_CODE,
          a.IVDOutOfStateCase_ID,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(a.IVDOutOfStateCountyFips_CODE)), 3) AS IVDOutOfStateCountyFips_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateOfficeFips_CODE)), 2) AS IVDOutOfStateOfficeFips_CODE,
          a.CsenetTran_ID,
          a.Function_CODE,
          a.Action_CODE,
          a.Reason_CODE,
          CAST((CASE ISNUMERIC(a.Case_IDNO)
                 WHEN 1
                  THEN a.Case_IDNO
                 ELSE @Lc_StringZero_TEXT
                END) AS NUMERIC) AS Case_IDNO,
          @Ac_ExchangeMode_CODE AS ExchangeMode_CODE,
          CASE a.RejectReason_CODE
           WHEN @Lc_Space_TEXT
            THEN @Ac_TranStatus_CODE
           ELSE @Ac_RejectReason_CODE
          END AS TranStatus_CODE,
          a.AttachDue_DATE,
          a.InterstateFrmsPrint_CODE,
          @Ld_Low_DATE AS TimeSent_DATE,
          @Ld_Low_DATE AS Due_DATE,
          @Ld_Low_DATE AS Response_DATE,
          @Lc_Space_TEXT AS Overdue_CODE,
          a.WorkerUpdate_ID,
          a.Transaction_DATE,
          CASE LTRIM(a.ActionResolution_DATE)
           WHEN ''
            THEN @Ld_Low_DATE
           WHEN '01/01/1900'
            THEN @Ld_Low_DATE
           ELSE a.ActionResolution_DATE
          END AS ActionResolution_DATE,
          a.Attachments_INDC,
          a.CaseData_QNTY,
          a.Ncp_QNTY,
          a.NcpLoc_QNTY,
          a.Participant_QNTY,
          a.Order_QNTY,
          a.Collection_QNTY,
          a.Info_QNTY,
          @Ad_Run_DATE AS End_DATE,
          a.CsenetVersion_ID,
          a.ErrorReason_CODE,
          CASE LTRIM(a.Received_DATE)
           WHEN ''
            THEN @Ld_Low_DATE
           WHEN '01/01/1900'
            THEN @Ld_Low_DATE
           ELSE a.Received_DATE
          END AS Received_DTTM,
          a.RejectReason_CODE,
          CAST(a.TransHeader_IDNO AS NUMERIC) AS Transaction_IDNO,
          'N' AS Trans3Printed_INDC
     FROM LTHBL_Y1 a
    WHERE a.Process_INDC = @Lc_No_INDC;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = @Li_Zero_NUMB
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'UPDATE LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE LTHBL_Y1
      SET Process_INDC = @Lc_Yes_INDC
    WHERE LTHBL_Y1.Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'SELECT COUNT LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   SELECT @Ln_Rec_QNTY = COUNT(1)
     FROM LTHBL_Y1 a
    WHERE a.Process_INDC = @Lc_Yes_INDC
      AND a.CaseData_QNTY > @Lc_StringZero_TEXT;

   IF @Ln_Rec_QNTY > @Li_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT CSDB_Y1';
     SET @Ls_Sqldata_TEXT = '';

     INSERT CSDB_Y1
            (TransHeader_IDNO,
             Transaction_DATE,
             IVDOutOfStateFips_CODE,
             TypeCase_CODE,
             StatusCase_CODE,
             PaymentLine1_ADDR,
             PaymentLine2_ADDR,
             PaymentCity_ADDR,
             PaymentState_ADDR,
             PaymentZip_ADDR,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             Suffix_NAME,
             ContactLine1_ADDR,
             ContactLine2_ADDR,
             ContactCity_ADDR,
             ContactState_ADDR,
             ContactZip_ADDR,
             ContactPhone_NUMB,
             PhoneExtensionCount_NUMB,
             RespondingFile_ID,
             Fax_NUMB,
             Contact_EML,
             InitiatingFile_ID,
             AcctSendPaymentsBankNo_TEXT,
             SendPaymentsRouting_ID,
             StateWithCej_CODE,
             PayFipsSt_CODE,
             PayFipsCnty_CODE,
             PayFipsSub_CODE,
             NondisclosureFinding_INDC)
     SELECT CAST(d.TransHeader_IDNO AS NUMERIC) AS TransHeader_IDNO,
            CAST(b.Transaction_DATE AS DATE) AS Transaction_DATE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_CaseDataBlock_TEXT, @Lc_CaseType_TEXT, @Lc_InputDirection_TEXT, a.TypeCase_CODE) AS TypeCase_CODE,
            a.StatusCase_CODE,
            SUBSTRING(a.PaymentLine1_ADDR, 1, 25) AS PaymentLine1_ADDR,
            SUBSTRING(a.PaymentLine2_ADDR, 1, 25) AS PaymentLine2_ADDR,
            SUBSTRING(a.PaymentCity_ADDR, 1, 18) AS PaymentCity_ADDR,
            a.PaymentState_ADDR,
            a.PaymentZip_ADDR,
            SUBSTRING(a.Last_NAME, 1, 20) AS Last_NAME,
            SUBSTRING(a.First_NAME, 1, 16) AS First_NAME,
            SUBSTRING(a.Middle_NAME, 1, 20) AS Middle_NAME,
            SUBSTRING(a.Suffix_NAME, 1, 4) AS Suffix_NAME,
            SUBSTRING(a.ContactLine1_ADDR, 1, 25) AS ContactLine1_ADDR,
            SUBSTRING(a.ContactLine2_ADDR, 1, 25) AS ContactLine2_ADDR,
            SUBSTRING(a.ContactCity_ADDR, 1, 18) AS ContactCity_ADDR,
            a.ContactState_ADDR,
            a.ContactZip_ADDR,
            CASE(ISNUMERIC(a.ContactPhone_NUMB))
             WHEN @Li_Zero_NUMB
              THEN @Lc_StringZero_TEXT
             ELSE a.ContactPhone_NUMB
            END AS ContactPhone_NUMB,
            CASE(ISNUMERIC(a.PhoneExtensionCount_NUMB))
             WHEN @Li_Zero_NUMB
              THEN @Lc_StringZero_TEXT
             ELSE a.PhoneExtensionCount_NUMB
            END AS PhoneExtensionCount_NUMB,
            a.RespondingFile_ID,
            CASE(ISNUMERIC(a.Fax_NUMB))
             WHEN @Li_Zero_NUMB
              THEN @Lc_StringZero_TEXT
             ELSE a.Fax_NUMB
            END AS Fax_NUMB,
            a.Contact_EML,
            a.InitiatingFile_ID,
            a.AcctSendPaymentsBankNo_TEXT,
            a.SendPaymentsRouting_ID,
            a.StateWithCej_CODE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.PayFipsSt_CODE)), 2) AS PayFipsSt_CODE,
            RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(a.PayFipsCnty_CODE)), 3) AS PayFipsCnty_CODE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.PayFipsSub_CODE)), 2) AS PayFipsSub_CODE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_CaseDataBlock_TEXT, @Lc_NonDisclosureFinding_TEXT, @Lc_InputDirection_TEXT, a.NondisclosureFinding_INDC) AS NondisclosureFinding_INDC
       FROM LCDBL_Y1 a,
            LTHBL_Y1 b,
            CTHB_Y1 d
      WHERE b.Process_INDC = @Lc_Yes_INDC
        AND a.TransHeader_IDNO = b.TransHeader_IDNO
        AND a.Transaction_DATE = b.Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
        AND a.Process_INDC = @Lc_No_INDC
        AND d.CsenetTran_ID = b.CsenetTran_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY < @Ln_Rec_QNTY
      BEGIN
       SET @Lb_BlockUnprocessed_BIT = 0;
      END;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE FAMILY VIOLENCE CURSOR';

   DECLARE FVoilence_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           c.MemberMci_IDNO,
           c.Case_IDNO,
           a.Transaction_DATE
      FROM LCDBL_Y1 a,
           LTHBL_Y1 b,
           CMEM_Y1 c,
		   CASE_Y1 ca
     WHERE a.TransHeader_IDNO = b.TransHeader_IDNO
       AND a.Transaction_DATE = b.Transaction_DATE
       AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
       AND a.Process_INDC = @Lc_No_INDC
       AND b.Process_INDC = @Lc_Yes_INDC
       AND a.NondisclosureFinding_INDC = @Lc_Yes_INDC
       AND LTRIM(b.Case_IDNO) != ''
       AND c.Case_IDNO = b.Case_IDNO
       AND c.CaseRelationship_CODE IN ('C', 'D')
       AND c.MemberMci_IDNO != 999998
	   AND ca.StatusCase_CODE = 'O'
	   AND c.Case_IDNO = ca.Case_IDNO
	   AND c.CaseMemberStatus_CODE = 'A'
       AND c.FamilyViolence_INDC = @Lc_No_INDC;

   OPEN FVoilence_CUR;

   FETCH NEXT FROM FVoilence_CUR INTO @Ln_FVoilenceCur_MemberMci_IDNO, @Ln_FVoilenceCur_Case_IDNO, @Ld_FVoilenceCur_Transaction_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Update Family Violence from Incoming batch to CMEM_Y1 if Family Violence is Y.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
      @Ac_Process_ID               = @Ac_JobProcess_IDNO,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = 'N',
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'UPDATE CMEM_Y1 FOR FAMILY VIOLENCE';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(@Ln_FVoilenceCur_MemberMci_IDNO, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_FVoilenceCur_Case_IDNO AS VARCHAR), '') + ', FamilyViolence_DATE = ' + ISNULL(CAST(@Ld_FVoilenceCur_Transaction_DATE AS VARCHAR), '');

     UPDATE CMEM_Y1
        SET FamilyViolence_INDC = @Lc_Yes_INDC,
            TypeFamilyViolence_CODE = 'UN',
            BeginValidity_DATE = @Ad_Run_DATE,
            WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            Update_DTTM = @Ld_Start_DTTM,
            FamilyViolence_DATE = @Ld_FVoilenceCur_Transaction_DATE
     OUTPUT deleted.Case_IDNO,
            deleted.MemberMci_IDNO,
            deleted.CaseRelationship_CODE,
            deleted.CaseMemberStatus_CODE,
            deleted.CpRelationshipToChild_CODE,
            deleted.NcpRelationshipToChild_CODE,
            deleted.BenchWarrant_INDC,
            deleted.ReasonMemberStatus_CODE,
            deleted.Applicant_CODE,
            deleted.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            deleted.WorkerUpdate_ID,
            deleted.TransactionEventSeq_NUMB,
            deleted.Update_DTTM,
            deleted.FamilyViolence_DATE,
            deleted.FamilyViolence_INDC,
            deleted.TypeFamilyViolence_CODE
     INTO HCMEM_Y1
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_FVoilenceCur_MemberMci_IDNO
        AND c.Case_IDNO = @Ln_FVoilenceCur_Case_IDNO
		AND c.CaseMemberStatus_CODE = 'A';

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = @Li_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE CMEM_Y1 FAILED';

       RAISERROR (50001,16,1);
      END;

     FETCH NEXT FROM FVoilence_CUR INTO @Ln_FVoilenceCur_MemberMci_IDNO, @Ln_FVoilenceCur_Case_IDNO, @Ld_FVoilenceCur_Transaction_DATE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'FVoilence_CUR') IN (0, 1)
    BEGIN
     CLOSE FVoilence_CUR;

     DEALLOCATE FVoilence_CUR;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE LCDBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE c
      SET Process_INDC = @Lc_Yes_INDC
     FROM LCDBL_Y1 c
    WHERE EXISTS (SELECT 1
                    FROM LCDBL_Y1 a,
                         LTHBL_Y1 b
                   WHERE b.Process_INDC = @Lc_Yes_INDC
                     AND a.TransHeader_IDNO = b.TransHeader_IDNO
                     AND a.Transaction_DATE = b.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                     AND a.Process_INDC <> @Lc_DuplicateX1_INDC
                     AND a.TransHeader_IDNO = c.TransHeader_IDNO
                     AND a.Transaction_DATE = c.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = c.IVDOutOfStateFips_CODE)
      AND c.Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'SELECT COUNT LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   SELECT @Ln_Rec_QNTY = COUNT(1)
     FROM LTHBL_Y1 a
    WHERE a.Process_INDC = @Lc_Yes_INDC
      AND a.Ncp_QNTY > @Lc_StringZero_TEXT;

   IF (@Ln_Rec_QNTY > 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT CNCB_Y1';
     SET @Ls_Sqldata_TEXT = '';

     INSERT CNCB_Y1
            (TransHeader_IDNO,
             Transaction_DATE,
             IVDOutOfStateFips_CODE,
             MemberMci_IDNO,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             Suffix_NAME,
             MemberSsn_NUMB,
             Birth_DATE,
             Race_CODE,
             MemberSex_CODE,
             PlaceOfBirth_NAME,
             FtHeight_TEXT,
             InHeight_TEXT,
             DescriptionWeightLbs_TEXT,
             ColorHair_CODE,
             ColorEyes_CODE,
             DistinguishingMarks_TEXT,
             Alias1Ssn_NUMB,
             Alias2Ssn_NUMB,
             PossiblyDangerous_INDC,
             Maiden_NAME,
             FatherOrMomMaiden_NAME)
     SELECT CAST(d.TransHeader_IDNO AS NUMERIC) AS TransHeader_IDNO,
            CAST(b.Transaction_DATE AS DATE) AS Transaction_DATE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
            CAST((CASE LTRIM(a.MemberMci_IDNO)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.MemberMci_IDNO
                  END) AS NUMERIC) AS MemberMci_IDNO,
            a.Last_NAME,
            a.First_NAME,
            a.Middle_NAME,
            a.Suffix_NAME,
            CAST((CASE LTRIM(a.MemberSsn_NUMB)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.MemberSsn_NUMB
                  END) AS NUMERIC) AS MemberSsn_NUMB,
            CAST((CASE LTRIM(a.Birth_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.Birth_DATE
                  END) AS DATE) AS Birth_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpDataBlock_TEXT, @Lc_Race_TEXT, @Lc_InputDirection_TEXT, a.Race_CODE) AS Race_CODE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpDataBlock_TEXT, @Lc_MemSex_TEXT, @Lc_InputDirection_TEXT, a.MemberSex_CODE) AS MemberSex_CODE,
            a.PlaceOfBirth_NAME,
            a.FtHeight_TEXT,
            a.InHeight_TEXT,
            a.DescriptionWeightLbs_TEXT,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpDataBlock_TEXT, @Lc_HairColor_TEXT, @Lc_InputDirection_TEXT, a.ColorHair_CODE) AS ColorHair_CODE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpDataBlock_TEXT, @Lc_EyeColor_TEXT, @Lc_InputDirection_TEXT, a.ColorEyes_CODE) AS ColorEyes_CODE,
            a.DistinguishingMarks_TEXT,
            CAST((CASE LTRIM(a.Alias1Ssn_NUMB)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Alias1Ssn_NUMB
                  END) AS NUMERIC) AS Alias1Ssn_NUMB,
            CAST((CASE LTRIM(a.Alias2Ssn_NUMB)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Alias2Ssn_NUMB
                  END) AS NUMERIC) AS Alias2Ssn_NUMB,
            a.PossiblyDangerous_INDC,
            a.Maiden_NAME,
            a.FatherOrMomMaiden_NAME
       FROM LNBLK_Y1 a,
            LTHBL_Y1 b,
            CTHB_Y1 d
      WHERE b.Process_INDC = @Lc_Yes_INDC
        AND a.TransHeader_IDNO = b.TransHeader_IDNO
        AND a.Transaction_DATE = b.Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
        AND a.Process_INDC = @Lc_No_INDC
        AND d.CsenetTran_ID = b.CsenetTran_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY < @Ln_Rec_QNTY
      BEGIN
       SET @Lb_BlockUnprocessed_BIT = 0;
      END;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE LNBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE c
      SET Process_INDC = @Lc_Yes_INDC
     FROM LNBLK_Y1 c
    WHERE EXISTS (SELECT a.TransHeader_IDNO,
                         a.Transaction_DATE,
                         a.IVDOutOfStateFips_CODE
                    FROM LNBLK_Y1 a,
                         LTHBL_Y1 b
                   WHERE b.Process_INDC = @Lc_Yes_INDC
                     AND a.TransHeader_IDNO = b.TransHeader_IDNO
                     AND a.Transaction_DATE = b.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                     AND a.Process_INDC <> @Lc_DuplicateX1_INDC
                     AND a.TransHeader_IDNO = c.TransHeader_IDNO
                     AND A.Transaction_DATE = C.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = C.IVDOutOfStateFips_CODE)
      AND C.Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'SELECT COUNT LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   SELECT @Ln_Rec_QNTY = COUNT(1)
     FROM LTHBL_Y1 a
    WHERE a.Process_INDC = @Lc_Yes_INDC
      AND a.NcpLoc_QNTY > @Lc_StringZero_TEXT;

   IF (@Ln_Rec_QNTY > 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT CNLB_Y1';
     SET @Ls_Sqldata_TEXT = 'HomePhone_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', EmployerPhone_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', LastEmployerEin_ID = ' + ISNULL(@Lc_Empty_TEXT, '') + ', Employer2Phone_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', Employer3Phone_NUMB = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '');

     INSERT CNLB_Y1
            (TransHeader_IDNO,
             Transaction_DATE,
             IVDOutOfStateFips_CODE,
             ResidentialLine1_ADDR,
             ResidentialLine2_ADDR,
             ResidentialCity_ADDR,
             ResidentialState_ADDR,
             ResidentialZip_ADDR,
             MailingLine1_ADDR,
             MailingLine2_ADDR,
             MailingCity_ADDR,
             MailingState_ADDR,
             MailingZip_ADDR,
             EffectiveResidential_DATE,
             EndResidential_DATE,
             ResidentialConfirmed_CODE,
             EffectiveMailing_DATE,
             EndMailing_DATE,
             MailingConfirmed_CODE,
             HomePhone_NUMB,
             WorkPhone_NUMB,
             DriversLicenseState_CODE,
             DriversLicenseNo_TEXT,
             Alias1First_NAME,
             Alias1Middle_NAME,
             Alias1Last_NAME,
             Alias1Suffix_NAME,
             Alias2First_NAME,
             Alias2Middle_NAME,
             Alias2Last_NAME,
             Alias2Suffix_NAME,
             Alias3First_NAME,
             Alias3Middle_NAME,
             Alias3Last_NAME,
             Alias3Suffix_NAME,
             SpouseLast_NAME,
             SpouseFirst_NAME,
             SpouseMiddle_NAME,
             SpouseSuffix_NAME,
             Occupation_TEXT,
             EmployerEin_ID,
             Employer_NAME,
             EmployerLine1_ADDR,
             EmployerLine2_ADDR,
             EmployerCity_ADDR,
             EmployerState_ADDR,
             EmployerZip_ADDR,
             EmployerPhone_NUMB,
             EffectiveEmployer_DATE,
             EndEmployer_DATE,
             EmployerConfirmed_INDC,
             WageQtr_CODE,
             WageYear_NUMB,
             Wage_AMNT,
             InsCarrier_NAME,
             PolicyInsNo_TEXT,
             LastResidentialLine1_ADDR,
             LastResidentialLine2_ADDR,
             LastResidentialCity_ADDR,
             LastResidentialState_ADDR,
             LastResidentialZip_ADDR,
             LastResAddress_DATE,
             LastMailLine1_ADDR,
             LastMailLine2_ADDR,
             LastMailCity_ADDR,
             LastMailState_ADDR,
             LastMailZip_ADDR,
             LastMailAddress_DATE,
             LastEmployerEin_ID,
             LastEmployer_NAME,
             LastEmployer_DATE,
             LastEmployerLine1_ADDR,
             LastEmployerLine2_ADDR,
             LastEmployerCity_ADDR,
             LastEmployerState_ADDR,
             LastEmployerZip_ADDR,
             LastEmployerEffective_DATE,
             Employer2Ein_ID,
             Employer2_NAME,
             Employer2Line1_ADDR,
             Employer2Line2_ADDR,
             Employer2City_ADDR,
             Employer2State_ADDR,
             Employer2Zip_ADDR,
             Employer2Phone_NUMB,
             EffectiveEmployer2_DATE,
             EndEmployer2_DATE,
             Employer2Confirmed_INDC,
             Wage2Qtr_CODE,
             Wage2Year_NUMB,
             Wage2_AMNT,
             Employer3Ein_ID,
             Employer3_NAME,
             Employer3Line1_ADDR,
             Employer3Line2_ADDR,
             Employer3City_ADDR,
             Employer3State_ADDR,
             Employer3Zip_ADDR,
             Employer3Phone_NUMB,
             EffectiveEmployer3_DATE,
             EndEmployer3_DATE,
             Employer3Confirmed_INDC,
             Wage3Qtr_CODE,
             Wage3Year_NUMB,
             Wage3_AMNT,
             ProfessionalLicenses_TEXT)
     SELECT CAST(d.TransHeader_IDNO AS NUMERIC) AS TransHeader_IDNO,
            CAST(b.Transaction_DATE AS DATE) AS Transaction_DATE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
            LTRIM(RTRIM(SUBSTRING(a.ResidentialLine1_ADDR, 1, 25))) AS ResidentialLine1_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.ResidentialLine2_ADDR, 1, 25))) AS ResidentialLine2_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.ResidentialCity_ADDR, 1, 18))) AS ResidentialCity_ADDR,
            a.ResidentialState_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.ResidentialZip_ADDR, '-', ''), 1, 9))) AS ResidentialZip_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.MailingLine1_ADDR, 1, 25))) AS MailingLine1_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.MailingLine2_ADDR, 1, 25))) AS MailingLine2_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.MailingCity_ADDR, 1, 18))) AS MailingCity_ADDR,
            a.MailingState_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.MailingZip_ADDR, '-', ''), 1, 9))) AS MailingZip_ADDR,
            CAST((CASE LTRIM(a.EffectiveResidential_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.EffectiveResidential_DATE
                  END) AS DATE) AS EffectiveResidential_DATE,
            CAST((CASE LTRIM(a.EndResidential_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_High_DATE
                   ELSE a.EndResidential_DATE
                  END) AS DATE) AS EndResidential_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpLocateBlock_TEXT, @Lc_ResidentialConfirmed_TEXT, @Lc_InputDirection_TEXT, a.ResidentialConfirmed_CODE) AS ResidentialConfirmed_CODE,--ResidentialConfirmed_INDC, 
            CAST((CASE LTRIM(a.EffectiveMailing_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.EffectiveMailing_DATE
                  END) AS DATE) AS EffectiveMailing_DATE,
            CAST((CASE LTRIM(a.EndMailing_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_High_DATE
                   ELSE a.EndMailing_DATE
                  END) AS DATE) AS EndMailing_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpLocateBlock_TEXT, @Lc_MailingConfirmed_TEXT, @Lc_InputDirection_TEXT, a.MailingConfirmed_CODE) AS MailingConfirmed_CODE,--MailingConfirmed_INDC, 
            @Li_Zero_NUMB AS HomePhone_NUMB,
            CASE(ISNUMERIC(a.WorkPhone_NUMB))
             WHEN @Li_Zero_NUMB
              THEN @Lc_StringZero_TEXT
             ELSE a.WorkPhone_NUMB
            END AS WorkPhone_NUMB,
            a.DriversLicenseState_CODE,
            a.DriversLicenseNo_TEXT,
            a.Alias1First_NAME,
            a.Alias1Middle_NAME,
            a.Alias1Last_NAME,
            a.Alias1Suffix_NAME,
            a.Alias2First_NAME,
            a.Alias2Middle_NAME,
            a.Alias2Last_NAME,
            a.Alias2Suffix_NAME,
            a.Alias3First_NAME,
            a.Alias3Middle_NAME,
            a.Alias3Last_NAME,
            a.Alias3Suffix_NAME,
            a.SpouseLast_NAME,
            a.SpouseFirst_NAME,
            a.SpouseMiddle_NAME,
            a.SpouseSuffix_NAME,
            a.Occupation_TEXT,
            a.EmployerEin_ID,
            a.Employer_NAME,
            LTRIM(RTRIM(SUBSTRING(a.EmployerLine1_ADDR, 1, 25))) AS EmployerLine1_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.EmployerLine2_ADDR, 1, 25))) AS EmployerLine2_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.EmployerCity_ADDR, 1, 18))) AS EmployerCity_ADDR,
            a.EmployerState_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.EmployerZip_ADDR, '-', ''), 1, 9))) AS EmployerZip_ADDR,
            @Li_Zero_NUMB AS EmployerPhone_NUMB,
            CAST((CASE LTRIM(a.EffectiveEmployer_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.EffectiveEmployer_DATE
                  END) AS DATE) AS EffectiveEmployer_DATE,
            CAST((CASE LTRIM(a.EndEmployer_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_High_DATE
                   ELSE a.EndEmployer_DATE
                  END) AS DATE) AS EndEmployer_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpLocateBlock_TEXT, @Lc_EmployerConfirmed_TEXT, @Lc_InputDirection_TEXT, a.EmployerConfirmed_INDC) AS EmployerConfirmed_INDC,--EmployerConfirmed_INDC, 
            a.WageQtr_CODE,
            CAST((CASE LTRIM(a.WageYear_NUMB)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.WageYear_NUMB
                  END) AS NUMERIC) AS WageYear_NUMB,
            CAST((CASE LTRIM(a.Wage_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Wage_AMNT
                  END) AS NUMERIC) AS Wage_AMNT,
            a.InsCarrier_NAME,
            a.PolicyInsNo_TEXT,
            LTRIM(RTRIM(SUBSTRING(a.LastResidentialLine1_ADDR, 1, 25))) AS LastResidentialLine1_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.LastResidentialLine2_ADDR, 1, 25))) AS LastResidentialLine2_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.LastResidentialCity_ADDR, 1, 18))) AS LastResidentialCity_ADDR,
            a.LastResidentialState_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.LastResZip_ADDR, '-', ''), 1, 9))) AS LastResidentialZip_ADDR,
            CAST((CASE LTRIM(a.LastResAddress_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.LastResAddress_DATE
                  END) AS DATE) AS LastResAddress_DATE,
            LTRIM(RTRIM(SUBSTRING(a.LastMailLine1_ADDR, 1, 25))) AS LastMailLine1_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.LastMailLine2_ADDR, 1, 25))) AS LastMailLine2_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.LastMailCity_ADDR, 1, 18))) AS LastMailCity_ADDR,
            a.LastMailState_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.LastMailZip_ADDR, '-', ''), 1, 9))) AS LastMailZip_ADDR,
            CAST((CASE LTRIM(a.LastMailAddress_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.LastMailAddress_DATE
                  END) AS DATE) AS LastMailAddress_DATE,
            @Lc_Empty_TEXT AS LastEmployerEin_ID,
            a.LastEmployer_NAME,
            CAST((CASE LTRIM(a.LastEmployer_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.LastEmployer_DATE
                  END) AS DATE) AS LastEmployer_DATE,
            LTRIM(RTRIM(SUBSTRING(a.LastEmployerLine1_ADDR, 1, 25))) AS LastEmployerLine1_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.LastEmployerLine2_ADDR, 1, 25))) AS LastEmployerLine2_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.LastEmployerCity_ADDR, 1, 18))) AS LastEmployerCity_ADDR,
            a.LastEmployerState_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.LastEmployerZip_ADDR, '-', ''), 1, 9))) AS LastEmployerZip_ADDR,
            CAST((CASE LTRIM(a.LastEmployerEffective_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.LastEmployerEffective_DATE
                  END) AS DATE) AS LastEmployerEffective_DATE,
            a.Employer2Ein_ID,
            a.Employer2_NAME,
            LTRIM(RTRIM(SUBSTRING(a.Employer2Line1_ADDR, 1, 25))) AS Employer2Line1_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.Employer2Line2_ADDR, 1, 25))) AS Employer2Line2_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.Employer2City_ADDR, 1, 18))) AS Employer2City_ADDR,
            a.Employer2State_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.Employer2Zip_ADDR, '-', ''), 1, 9))) AS Employer2Zip_ADDR,
            @Li_Zero_NUMB AS Employer2Phone_NUMB,
            CAST((CASE LTRIM(a.EffectiveEmployer2_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.EffectiveEmployer2_DATE
                  END) AS DATE) AS EffectiveEmployer2_DATE,
            CAST((CASE LTRIM(a.EndEmployer2_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_High_DATE
                   ELSE a.EndEmployer2_DATE
                  END) AS DATE) AS EndEmployer2_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpLocateBlock_TEXT, @Lc_EmployerConfirmed_TEXT, @Lc_InputDirection_TEXT, a.Employer2Confirmed_INDC) AS Employer2Confirmed_INDC,--Employer2Confirmed_INDC, 
            a.Wage2Qtr_CODE,
            CAST((CASE LTRIM(a.Wage2Year_NUMB)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Wage2Year_NUMB
                  END) AS NUMERIC) AS Wage2Year_NUMB,
            CAST((CASE LTRIM(a.Wage2_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Wage2_AMNT
                  END) AS NUMERIC) AS Wage2_AMNT,
            a.Employer3Ein_ID,
            a.Employer3_NAME,
            LTRIM(RTRIM(SUBSTRING(a.Employer3Line1_ADDR, 1, 25))) AS Employer3Line1_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.Employer3Line2_ADDR, 1, 25))) AS Employer3Line2_ADDR,
            LTRIM(RTRIM(SUBSTRING(a.Employer3City_ADDR, 1, 18))) AS Employer3City_ADDR,
            a.Employer3State_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.Employer3Zip_ADDR, '-', ''), 1, 9))) AS Employer3Zip_ADDR,
            @Li_Zero_NUMB AS Employer3Phone_NUMB,
            CAST((CASE LTRIM(a.EffectiveEmployer3_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.EffectiveEmployer3_DATE
                  END) AS DATE) AS EffectiveEmployer3_DATE,
            CAST((CASE LTRIM(a.EndEmployer3_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_High_DATE
                   ELSE a.EndEmployer3_DATE
                  END) AS DATE) AS EndEmployer3_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpLocateBlock_TEXT, @Lc_EmployerConfirmed_TEXT, @Lc_InputDirection_TEXT, a.Employer3Confirmed_INDC) AS Employer3Confirmed_INDC,--Employer3Confirmed_INDC, 
            a.Wage3Qtr_CODE,
            CAST((CASE LTRIM(a.Wage3Year_NUMB)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Wage3Year_NUMB
                  END) AS NUMERIC) AS Wage3Year_NUMB,
            CAST((CASE LTRIM(a.Wage3_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Wage3_AMNT
                  END) AS NUMERIC) AS Wage3_AMNT,
            a.ProfessionalLicenses_TEXT
       FROM LNLBL_Y1 a,
            LTHBL_Y1 b,
            CTHB_Y1 d
      WHERE b.Process_INDC = @Lc_Yes_INDC
        AND a.TransHeader_IDNO = b.TransHeader_IDNO
        AND a.Transaction_DATE = b.Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
        AND a.Process_INDC = @Lc_No_INDC
        AND d.CsenetTran_ID = b.CsenetTran_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY < @Ln_Rec_QNTY
      BEGIN
       SET @Lb_BlockUnprocessed_BIT = 0;
      END;

     SET @Ls_Sql_TEXT = 'UPDATE CNLB_Y1';
     SET @Ls_Sqldata_TEXT = '';

     UPDATE a
        SET LastEmployerEin_ID = ISNULL((SELECT TOP 1 Fein_IDNO
                                           FROM OTHP_Y1 b
                                          WHERE b.OtherParty_Name = a.LastEmployer_NAME
                                            AND b.Line1_ADDR = a.LastEmployerLine1_ADDR
                                            AND b.Line2_ADDR = a.LastEmployerLine2_ADDR
                                            AND b.City_addr = a.LastEmployerCity_ADDR
                                            AND b.State_Addr = a.LastEmployerState_ADDR
                                            AND b.Zip_Addr = a.LastEmployerZip_ADDR
                                            AND b.EndValidity_date = @Ld_High_DATE
                                            AND b.TypeOthp_code = @Lc_OthpEmployer_CODE), @Lc_StringZero_TEXT)
       FROM CNLB_Y1 a
      WHERE a.LastEmployer_NAME <> @Lc_Empty_TEXT
        AND a.LastEmployerLine1_ADDR <> @Lc_Empty_TEXT;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE LNLBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE C
      SET Process_INDC = @Lc_Yes_INDC
     FROM LNLBL_Y1 C
    WHERE EXISTS (SELECT a.TransHeader_IDNO,
                         a.Transaction_DATE,
                         a.IVDOutOfStateFips_CODE
                    FROM LNLBL_Y1 a,
                         LTHBL_Y1 b
                   WHERE b.Process_INDC = @Lc_Yes_INDC
                     AND a.TransHeader_IDNO = b.TransHeader_IDNO
                     AND a.Transaction_DATE = b.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                     AND a.Process_INDC <> @Lc_DuplicateX1_INDC
                     AND A.TransHeader_IDNO = C.TransHeader_IDNO
                     AND a.Transaction_DATE = C.Transaction_DATE
                     AND A.IVDOutOfStateFips_CODE = C.IVDOutOfStateFips_CODE)
      AND Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'SELECT COUNT LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   SELECT @Ln_Rec_QNTY = SUM(CAST(a.Participant_QNTY AS INTEGER))
     FROM LTHBL_Y1 a
    WHERE a.Process_INDC = @Lc_Yes_INDC
      AND a.Participant_QNTY > @Lc_StringZero_TEXT;

   IF @Ln_Rec_QNTY > @Li_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT CPTB_Y1';
     SET @Ls_Sqldata_TEXT = '';

     INSERT CPTB_Y1
            (TransHeader_IDNO,
             Transaction_DATE,
             IVDOutOfStateFips_CODE,
             BlockSeq_NUMB,
             Employer_NAME,
             EmployerLine1_ADDR,
             EmployerLine2_ADDR,
             EmployerCity_ADDR,
             EmployerState_ADDR,
             EmployerZip_ADDR,
             EinEmployer_ID,
             ConfirmedAddress_INDC,
             ConfirmedAddress_DATE,
             ConfirmedEmployer_INDC,
             ConfirmedEmployer_DATE,
             WorkPhone_NUMB,
             PlaceOfBirth_NAME,
             ChildStateResidence_CODE,
             ChildPaternityStatus_CODE,
             MemberMci_IDNO,
             Last_NAME,
             First_NAME,
             Middle_NAME,
             Suffix_NAME,
             Birth_DATE,
             MemberSsn_NUMB,
             MemberSex_CODE,
             Race_CODE,
             Relationship_CODE,
             ParticipantStatus_CODE,
             ChildRelationshipNcp_CODE,
             ParticipantLine1_ADDR,
             ParticipantLine2_ADDR,
             ParticipantCity_ADDR,
             ParticipantState_ADDR,
             ParticipantZip_ADDR)
     SELECT CAST(d.TransHeader_IDNO AS NUMERIC) AS TransHeader_IDNO,
            CAST(b.Transaction_DATE AS DATE) AS Transaction_DATE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
            CAST(a.BlockSeq_NUMB AS NUMERIC) AS BlockSeq_NUMB,
            a.Employer_NAME,
            SUBSTRING(a.EmployerLine1_ADDR, 1, 25) AS EmployerLine1_ADDR,
            SUBSTRING(a.EmployerLine2_ADDR, 1, 25) AS EmployerLine2_ADDR,
            SUBSTRING(a.EmployerCity_ADDR, 1, 18) AS EmployerCity_ADDR,
            a.EmployerState_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.EmployerZip_ADDR, '-', ''), 1, 9))) AS EmployerZip_ADDR,
            a.EinEmployer_ID,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpLocateBlock_TEXT, @Lc_ResidentialConfirmed_TEXT, @Lc_InputDirection_TEXT, a.ConfirmedAddress_INDC) AS ConfirmedAddress_INDC,
            CAST((CASE LTRIM(a.ConfirmedAddress_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_High_DATE
                   ELSE a.ConfirmedAddress_DATE
                  END) AS DATE) AS ConfirmedAddress_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpLocateBlock_TEXT, @Lc_EmployerConfirmed_TEXT, @Lc_InputDirection_TEXT, a.ConfirmedEmployer_INDC) AS ConfirmedEmployer_INDC,
            CAST((CASE LTRIM(a.ConfirmedEmployer_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_High_DATE
                   ELSE a.ConfirmedEmployer_DATE
                  END) AS DATE) AS ConfirmedEmployer_DATE,
            CASE(ISNUMERIC(a.WorkPhone_NUMB))
             WHEN @Li_Zero_NUMB
              THEN @Lc_StringZero_TEXT
             ELSE a.WorkPhone_NUMB
            END AS WorkPhone_NUMB,
            a.PlaceOfBirth_NAME,
            a.ChildStateResidence_CODE,
            a.ChildPaternityStatus_CODE,
            CAST((CASE LTRIM(a.MemberMci_IDNO)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.MemberMci_IDNO
                  END) AS NUMERIC) AS MemberMci_IDNO,
            SUBSTRING(a.Last_NAME, 1, 20) AS Last_NAME,
            SUBSTRING(a.First_NAME, 1, 16) AS First_NAME,
            SUBSTRING(a.Middle_NAME, 1, 20) AS Middle_NAME,
            SUBSTRING(a.Suffix_NAME, 1, 4) AS Suffix_NAME,
            CAST((CASE LTRIM(a.Birth_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.Birth_DATE
                  END) AS DATE) AS Birth_DATE,
            CAST((CASE LTRIM(a.MemberSsn_NUMB)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.MemberSsn_NUMB
                  END) AS NUMERIC) AS MemberSsn_NUMB,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpDataBlock_TEXT, @Lc_MemSex_TEXT, @Lc_InputDirection_TEXT, a.MemberSex_CODE) AS MemberSex_CODE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_NcpDataBlock_TEXT, @Lc_Race_TEXT, @Lc_InputDirection_TEXT, a.Race_CODE) AS Race_CODE,
            a.Relationship_CODE,
            a.ParticipantStatus_CODE,
            a.ChildRelationshipNcp_CODE,
            SUBSTRING(a.ParticipantLine1_ADDR, 1, 25) AS ParticipantLine1_ADDR,
            SUBSTRING(a.ParticipantLine2_ADDR, 1, 25) AS ParticipantLine2_ADDR,
            SUBSTRING(a.ParticipantCity_ADDR, 1, 18) AS ParticipantCity_ADDR,
            a.ParticipantState_ADDR,
            LTRIM(RTRIM(SUBSTRING(REPLACE(a.ParticipantZip_ADDR, '-', ''), 1, 9))) AS ParticipantZip_ADDR
       FROM LPBLK_Y1 a,
            LTHBL_Y1 b,
            CTHB_Y1 d
      WHERE b.Process_INDC = @Lc_Yes_INDC
        AND a.TransHeader_IDNO = b.TransHeader_IDNO
        AND a.Transaction_DATE = b.Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
        AND a.Process_INDC = @Lc_No_INDC
        AND d.CsenetTran_ID = b.CsenetTran_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY < @Ln_Rec_QNTY
      BEGIN
       SET @Lb_BlockUnprocessed_BIT = 0;
      END;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE LPBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE C
      SET Process_INDC = @Lc_Yes_INDC
     FROM LPBLK_Y1 C
    WHERE EXISTS (SELECT a.TransHeader_IDNO,
                         a.Transaction_DATE,
                         a.IVDOutOfStateFips_CODE
                    FROM LPBLK_Y1 a,
                         LTHBL_Y1 b
                   WHERE b.Process_INDC = @Lc_Yes_INDC
                     AND a.TransHeader_IDNO = b.TransHeader_IDNO
                     AND a.Transaction_DATE = b.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                     AND a.Process_INDC <> @Lc_DuplicateX1_INDC
                     AND A.TransHeader_IDNO = C.TransHeader_IDNO
                     AND A.Transaction_DATE = C.Transaction_DATE
                     AND A.IVDOutOfStateFips_CODE = C.IVDOutOfStateFips_CODE)
      AND Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'SELECT LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   SELECT @Ln_Rec_QNTY = SUM(CAST((CASE LTRIM(a.Order_QNTY)
                                    WHEN @Lc_Empty_TEXT
                                     THEN @Lc_StringZero_TEXT
                                    ELSE a.Order_QNTY
                                   END) AS INT))
     FROM LTHBL_Y1 a
    WHERE Process_INDC = @Lc_Yes_INDC
      AND Order_QNTY > @Lc_StringZero_TEXT;

   IF @Ln_Rec_QNTY > @Li_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT CORB_Y1';
     SET @Ls_Sqldata_TEXT = '';

     INSERT CORB_Y1
            (TransHeader_IDNO,
             Transaction_DATE,
             IVDOutOfStateFips_CODE,
             BlockSeq_NUMB,
             StFipsOrder_CODE,
             CntyFipsOrder_CODE,
             SubFipsOrder_CODE,
             CsenetOrder_ID,
             FilingOrder_DATE,
             TypeOrder_CODE,
             DebtType_CODE,
             OrderFreq_CODE,
             OrderFreq_AMNT,
             OrderEffective_DATE,
             OrderEnd_DATE,
             OrderCancel_DATE,
             FreqOrderArrears_CODE,
             FreqOrderArrears_AMNT,
             OrderArrearsTotal_AMNT,
             ArrearsAfdcFrom_DATE,
             ArrearsAfdcThru_DATE,
             ArrearsAfdc_AMNT,
             ArrearsNonAfdcFrom_DATE,
             ArrearsNonAfdcThru_DATE,
             ArrearsNonAfdc_AMNT,
             FosterCareFrom_DATE,
             FosterCareThru_DATE,
             FosterCare_AMNT,
             MedicalFrom_DATE,
             MedicalThru_DATE,
             Medical_AMNT,
             MedicalOrdered_INDC,
             TribunalCaseNo_TEXT,
             OfLastPayment_DATE,
             ControllingOrderFlag_CODE,
             NewOrderFlag_INDC,
             File_ID)
     SELECT CAST(d.TransHeader_IDNO AS NUMERIC) AS TransHeader_IDNO,
            CAST((CASE LTRIM(b.Transaction_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE b.Transaction_DATE
                  END) AS DATE) AS Transaction_DATE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
            CAST(a.BlockSeq_NUMB AS NUMERIC) AS BlockSeq_NUMB,
            RIGHT(REPLICATE('0', 2) + LTRIM(a.StFipsOrder_CODE), 2) AS StFipsOrder_CODE,
            RIGHT(REPLICATE('0', 3) + LTRIM(a.CntyFipsOrder_CODE), 3) AS CntyFipsOrder_CODE,
            RIGHT(REPLICATE('0', 2) + LTRIM(a.SubFipsOrder_CODE), 2) AS SubFipsOrder_CODE,
            CASE LTRIM(SUBSTRING(a.Order_IDNO, 1, 15))
             WHEN @Lc_Empty_TEXT
              THEN @Lc_StringZero_TEXT
             ELSE SUBSTRING(a.Order_IDNO, 1, 15)
            END AS CsenetOrder_ID,
            CAST((CASE LTRIM(a.FilingOrder_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.FilingOrder_DATE
                  END) AS DATE) AS FilingOrder_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_OrderDataBlock_TEXT, @Lc_TypeOrder_TEXT, @Lc_InputDirection_TEXT, a.TypeOrder_CODE) AS TypeOrder_CODE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_OrderDataBlock_TEXT, @Lc_TypeDebt_TEXT, @Lc_InputDirection_TEXT, a.DebtType_CODE) AS DebtType_CODE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_OrderDataBlock_TEXT, @Lc_OrderFreq_TEXT, @Lc_InputDirection_TEXT, a.OrderFreq_CODE) AS OrderFreq_CODE,
            CAST((CASE LTRIM(a.OrderFreq_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.OrderFreq_AMNT
                  END) AS NUMERIC) AS OrderFreq_AMNT,
            CAST((CASE LTRIM(a.OrderEffective_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.OrderEffective_DATE
                  END) AS DATE) AS OrderEffective_DATE,
            CAST((CASE LTRIM(a.OrderEnd_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.OrderEnd_DATE
                  END) AS DATE) AS OrderEnd_DATE,
            CAST((CASE LTRIM(a.OrderCancel_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.OrderCancel_DATE
                  END) AS DATE) AS OrderCancel_DATE,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_OrderDataBlock_TEXT, @Lc_FreqOrderArrears_TEXT, @Lc_InputDirection_TEXT, a.FreqOrderArrears_CODE) AS FreqOrderArrears_CODE,
            CAST((CASE LTRIM(a.FreqOrderArrears_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.FreqOrderArrears_AMNT
                  END) AS NUMERIC) AS FreqOrderArrears_AMNT,
            CAST((CASE LTRIM(a.OrderArrearsTotal_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.OrderArrearsTotal_AMNT
                  END) AS NUMERIC) AS OrderArrearsTotal_AMNT,
            CAST((CASE LTRIM(a.ArrearsAfdcFrom_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.ArrearsAfdcFrom_DATE
                  END) AS DATE) AS ArrearsAfdcFrom_DATE,
            CAST((CASE LTRIM(a.ArrearsAfdcThru_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.ArrearsAfdcThru_DATE
                  END) AS DATE) AS ArrearsAfdcThru_DATE,
            CAST((CASE LTRIM(a.ArrearsAfdc_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.ArrearsAfdc_AMNT
                  END) AS NUMERIC) AS ArrearsAfdc_AMNT,
            CAST((CASE LTRIM(a.ArrearsNonAfdcFrom_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.ArrearsNonAfdcFrom_DATE
                  END) AS DATE) AS ArrearsNonAfdcFrom_DATE,
            CAST((CASE LTRIM(a.ArrearsNonAfdcThru_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.ArrearsNonAfdcThru_DATE
                  END) AS DATE) AS ArrearsNonAfdcThru_DATE,
            CAST((CASE LTRIM(a.ArrearsNonAfdc_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.ArrearsNonAfdc_AMNT
                  END) AS NUMERIC) AS ArrearsNonAfdc_AMNT,
            CAST((CASE LTRIM(a.FosterCareFrom_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.FosterCareFrom_DATE
                  END) AS DATE) AS FosterCareFrom_DATE,
            CAST((CASE LTRIM(a.FosterCareThru_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.FosterCareThru_DATE
                  END) AS DATE) AS FosterCareThru_DATE,
            CAST((CASE LTRIM(a.FosterCare_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.FosterCare_AMNT
                  END) AS NUMERIC) AS FosterCare_AMNT,
            CAST((CASE LTRIM(a.MedicalFrom_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.MedicalFrom_DATE
                  END) AS DATE) AS MedicalFrom_DATE,
            CAST((CASE LTRIM(a.MedicalThru_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.MedicalThru_DATE
                  END) AS DATE) AS MedicalThru_DATE,
            CAST((CASE LTRIM(a.Medical_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Medical_AMNT
                  END) AS NUMERIC) AS Medical_AMNT,
            dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE(@Lc_OrderDataBlock_TEXT, @Lc_MedicalOrdered_TEXT, @Lc_InputDirection_TEXT, a.MedicalOrdered_INDC) AS MedicalOrdered_INDC,
            a.TribunalCaseNo_TEXT,
            CAST((CASE LTRIM(a.OfLastPayment_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.OfLastPayment_DATE
                  END) AS DATE) AS OfLastPayment_DATE,
            a.ControllingOrderFlag_CODE,
            a.NewOrderFlag_INDC,
            (CASE LTRIM(SUBSTRING(a.File_ID, 1, 15))
              WHEN @Lc_Empty_TEXT
               THEN @Lc_Space_TEXT
              ELSE SUBSTRING(a.File_ID, 1, 15)
             END) AS File_ID
       FROM LOBLK_Y1 a,
            LTHBL_Y1 b,
            CTHB_Y1 d
      WHERE b.Process_INDC = @Lc_Yes_INDC
        AND a.TransHeader_IDNO = b.TransHeader_IDNO
        AND a.Transaction_DATE = b.Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
        AND a.Process_INDC = @Lc_No_INDC
        AND d.CsenetTran_ID = b.CsenetTran_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY < @Ln_Rec_QNTY
      BEGIN
       SET @Lb_BlockUnprocessed_BIT = 0;
      END;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE LOBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE C
      SET Process_INDC = @Lc_Yes_INDC
     FROM LOBLK_Y1 C
    WHERE EXISTS (SELECT a.TransHeader_IDNO,
                         a.Transaction_DATE,
                         a.IVDOutOfStateFips_CODE
                    FROM LOBLK_Y1 a,
                         LTHBL_Y1 b
                   WHERE b.Process_INDC = @Lc_Yes_INDC
                     AND a.TransHeader_IDNO = b.TransHeader_IDNO
                     AND a.Transaction_DATE = b.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                     AND a.Process_INDC <> @Lc_DuplicateX1_INDC
                     AND A.TransHeader_IDNO = C.TransHeader_IDNO
                     AND A.Transaction_DATE = C.Transaction_DATE
                     AND A.IVDOutOfStateFips_CODE = C.IVDOutOfStateFips_CODE)
      AND Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'SELECT LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   SELECT @Ln_Rec_QNTY = SUM(CAST((CASE LTRIM(a.Collection_QNTY)
                                    WHEN @Lc_Empty_TEXT
                                     THEN @Lc_StringZero_TEXT
                                    ELSE a.Collection_QNTY
                                   END) AS INT))
     FROM LTHBL_Y1 a
    WHERE a.Process_INDC = @Lc_Yes_INDC
      AND a.Collection_QNTY > @Lc_StringZero_TEXT;

   IF @Ln_Rec_QNTY > @Li_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT CCLB_Y1';
     SET @Ls_Sqldata_TEXT = '';

     INSERT CCLB_Y1
            (TransHeader_IDNO,
             Transaction_DATE,
             IVDOutOfStateFips_CODE,
             BlockSeq_NUMB,
             Collection_DATE,
             Posting_DATE,
             Payment_AMNT,
             PaymentSource_CODE,
             PaymentMethod_CODE,
             Rdfi_ID,
             RdfiAcctNo_TEXT)
     SELECT CAST(d.TransHeader_IDNO AS NUMERIC) AS TransHeader_IDNO,
            CAST((CASE LTRIM(a.Transaction_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.Transaction_DATE
                  END) AS DATE) AS Transaction_DATE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
            a.BlockSeq_NUMB,
            CAST((CASE LTRIM(a.Collection_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.Collection_DATE
                  END) AS DATE) AS Collection_DATE,
            CAST((CASE LTRIM(a.Posting_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.Posting_DATE
                  END) AS DATE) AS Posting_DATE,
            CAST((CASE LTRIM(a.Payment_AMNT)
                   WHEN @Lc_Empty_TEXT
                    THEN @Lc_StringZero_TEXT
                   ELSE a.Payment_AMNT
                  END) AS NUMERIC) AS Payment_AMNT,
            a.PaymentSource_CODE,
            a.PaymentMethod_CODE,
            a.Rdfi_ID,
            a.RdfiAcctNo_TEXT
       FROM LCBLK_Y1 a,
            LTHBL_Y1 b,
            CTHB_Y1 d
      WHERE b.Process_INDC = @Lc_Yes_INDC
        AND a.TransHeader_IDNO = b.TransHeader_IDNO
        AND a.Transaction_DATE = b.Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
        AND a.Process_INDC = @Lc_No_INDC
        AND d.CsenetTran_ID = b.CsenetTran_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY < @Ln_Rec_QNTY
      BEGIN
       SET @Lb_BlockUnprocessed_BIT = 0;
      END;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE LCBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE C
      SET Process_INDC = @Lc_Yes_INDC
     FROM LCBLK_Y1 C
    WHERE EXISTS (SELECT a.TransHeader_IDNO,
                         a.Transaction_DATE,
                         a.IVDOutOfStateFips_CODE
                    FROM LCBLK_Y1 a,
                         LTHBL_Y1 b
                   WHERE b.Process_INDC = @Lc_Yes_INDC
                     AND a.TransHeader_IDNO = b.TransHeader_IDNO
                     AND a.Transaction_DATE = b.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                     AND a.Process_INDC <> @Lc_DuplicateX1_INDC
                     AND A.TransHeader_IDNO = C.TransHeader_IDNO
                     AND A.Transaction_DATE = C.Transaction_DATE
                     AND A.IVDOutOfStateFips_CODE = C.IVDOutOfStateFips_CODE)
      AND Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'SELECT COUNT LTHBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   SELECT @Ln_Rec_QNTY = COUNT(1)
     FROM LTHBL_Y1 a
    WHERE a.Process_INDC = @Lc_Yes_INDC
      AND a.Info_QNTY > @Lc_StringZero_TEXT;

   IF @Ln_Rec_QNTY > @Li_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT CFOB_Y1';
     SET @Ls_Sqldata_TEXT = '';

     INSERT CFOB_Y1
            (TransHeader_IDNO,
             Transaction_DATE,
             IVDOutOfStateFips_CODE,
             StatusChange_CODE,
             CaseNew_ID,
             InfoLine1_TEXT,
             InfoLine2_TEXT,
             InfoLine3_TEXT,
             InfoLine4_TEXT,
             InfoLine5_TEXT)
     SELECT CAST(d.TransHeader_IDNO AS NUMERIC) AS TransHeader_IDNO,
            CAST((CASE LTRIM(a.Transaction_DATE)
                   WHEN @Lc_Empty_TEXT
                    THEN @Ld_Low_DATE
                   ELSE a.Transaction_DATE
                  END) AS DATE) AS Transaction_DATE,
            RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
            a.StatusChange_CODE,
            a.CaseNew_ID,
            a.InfoLine1_TEXT,
            a.InfoLine2_TEXT,
            a.InfoLine3_TEXT,
            a.InfoLine4_TEXT,
            a.InfoLine5_TEXT
       FROM LIBLK_Y1 a,
            LTHBL_Y1 b,
            CTHB_Y1 d
      WHERE b.Process_INDC = @Lc_Yes_INDC
        AND a.TransHeader_IDNO = b.TransHeader_IDNO
        AND a.Transaction_DATE = b.Transaction_DATE
        AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
        AND a.Process_INDC = @Lc_No_INDC
        AND d.CsenetTran_ID = b.CsenetTran_ID;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY < @Ln_Rec_QNTY
      BEGIN
       SET @Lb_BlockUnprocessed_BIT = 0;
      END;
    END;

   SET @Ls_Sql_TEXT = 'UPDATE LIBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', Process_INDC = ' + ISNULL(@Lc_No_INDC, '');

   UPDATE C
      SET Process_INDC = @Lc_Yes_INDC
     FROM LIBLK_Y1 C
    WHERE EXISTS (SELECT a.TransHeader_IDNO,
                         a.Transaction_DATE,
                         a.IVDOutOfStateFips_CODE
                    FROM LIBLK_Y1 a,
                         LTHBL_Y1 b
                   WHERE b.Process_INDC = @Lc_Yes_INDC
                     AND a.TransHeader_IDNO = b.TransHeader_IDNO
                     AND a.Transaction_DATE = b.Transaction_DATE
                     AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                     AND a.Process_INDC <> @Lc_DuplicateX1_INDC
                     AND A.TransHeader_IDNO = C.TransHeader_IDNO
                     AND A.Transaction_DATE = C.Transaction_DATE
                     AND A.IVDOutOfStateFips_CODE = C.IVDOutOfStateFips_CODE)
      AND Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'ATTACHMENT CURSOR';

   DECLARE Attachment_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           a.IVDOutOfStateFips_CODE,
           a.Transaction_DATE,
           b.Notice_ID
      FROM CTHB_Y1 a,
           FFCL_Y1 b
     WHERE a.Function_CODE = b.Function_CODE
       AND a.Action_CODE = b.Action_CODE
       AND a.Reason_CODE = b.Reason_CODE
       AND a.TranStatus_CODE = @Ac_TranStatus_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE;

   OPEN Attachment_CUR;

   FETCH NEXT FROM Attachment_CUR INTO @Ln_AttachmentCur_TransHeader_IDNO, @Lc_AttachmentCur_IVDOutOfStateFips_CODE, @Ld_AttachmentCur_Transaction_DATE, @Lc_AttachmentCur_Notice_ID;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Insert Attachment information
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', Process_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
      @Ac_Process_ID               = @Ac_JobProcess_IDNO,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = 'N',
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'SELECT COUNT CAIN_Y1';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_AttachmentCur_TransHeader_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_AttachmentCur_IVDOutOfStateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_AttachmentCur_Transaction_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_AttachmentCur_Notice_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ln_ticeCount_NUMB = COUNT(1)
       FROM CAIN_Y1 a
      WHERE a.TransHeader_IDNO = @Ln_AttachmentCur_TransHeader_IDNO
        AND a.IVDOutOfStateFips_CODE = @Lc_AttachmentCur_IVDOutOfStateFips_CODE
        AND a.Transaction_DATE = @Ld_AttachmentCur_Transaction_DATE
        AND a.Notice_ID = @Lc_AttachmentCur_Notice_ID
        AND a.EndValidity_DATE = @Ld_High_DATE;

     IF (@Ln_ticeCount_NUMB = 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT CAIN_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_AttachmentCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_AttachmentCur_Transaction_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_AttachmentCur_Notice_ID, '') + ', Received_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

       INSERT CAIN_Y1
              (TransHeader_IDNO,
               IVDOutOfStateFips_CODE,
               Transaction_DATE,
               Notice_ID,
               Received_INDC,
               BeginValidity_DATE,
               EndValidity_DATE,
               WorkerUpdate_ID,
               TransactionEventSeq_NUMB,
               Update_DTTM,
               Barcode_NUMB)
       VALUES ( @Ln_AttachmentCur_TransHeader_IDNO,--TransHeader_IDNO
                RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(@Lc_AttachmentCur_IVDOutOfStateFips_CODE)), 2),--IVDOutOfStateFips_CODE
                @Ld_AttachmentCur_Transaction_DATE,--Transaction_DATE
                @Lc_AttachmentCur_Notice_ID,--Notice_ID
                @Lc_No_INDC,--Received_INDC
                @Ad_Run_DATE,--BeginValidity_DATE
                @Ld_High_DATE,--EndValidity_DATE
                @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
                @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                0 --Barcode_NUMB
       );

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = @Li_Zero_NUMB
        BEGIN
         RAISERROR(50001,16,1);
        END;
      END;

     FETCH NEXT FROM Attachment_CUR INTO @Ln_AttachmentCur_TransHeader_IDNO, @Lc_AttachmentCur_IVDOutOfStateFips_CODE, @Ld_AttachmentCur_Transaction_DATE, @Lc_AttachmentCur_Notice_ID;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Attachment_CUR') IN (0, 1)
    BEGIN
     CLOSE Attachment_CUR;

     DEALLOCATE Attachment_CUR;
    END;

   IF @Lb_BlockUnprocessed_BIT = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_CI_INCOMING_CSENET_FILE$SP_CHECK_BLOCK_COUNT';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_JobProcess_IDNO, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_CI_INCOMING_CSENET_FILE$SP_CHECK_BLOCK_COUNT
      @Ac_Job_ID                = @Ac_JobProcess_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'FVoilence_CUR') IN (0, 1)
    BEGIN
     CLOSE FVoilence_CUR;

     DEALLOCATE FVoilence_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'Attachment_CUR') IN (0, 1)
    BEGIN
     CLOSE Attachment_CUR;

     DEALLOCATE Attachment_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
