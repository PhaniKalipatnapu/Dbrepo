/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EFT_SVC_PNOTE_DISB$SP_EXTRACT_EFT_SVC_PNOTE_DISB]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*  
------------------------------------------------------------------------------------------------------------------  
 Procedure Name    :   BATCH_FIN_EFT_SVC_PNOTE_DISB$SP_EXTRACT_EFT_SVC_PNOTE_DISB   
 Programmer Name   :  IMP Team
 Description       :	The process extracts data relating to Pre-note for 
						new EFT instructions created on CPs .
						No Pre-note will be created for EFT instructions on 
						Interstate FIPS.
						In addition, if the Funds Recipient has EFT/Stored 
						Value Instructions in active status, the data 
						relating to daily EFT disbursements of CPs, 
						Interstate FIPS, County AND data relating to 
						daily Stored value card disbursements of CPs will be 
						extracted. This file will be delivered to PNC Bank.
 Frequency			: Daily  
 Developed On		: 4/12/2011
 Called By			: None  
 Called On			:  
 --------------------------------------------------------------------------------------------------------------------
 Modified By		:  
 Modified On		:  
 Version No			: 0.1
 ------------------------------------------------------------------------------------------------------------------  
   */
CREATE PROCEDURE [dbo].[BATCH_FIN_EFT_SVC_PNOTE_DISB$SP_EXTRACT_EFT_SVC_PNOTE_DISB]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ElectronicFundInstruction2150_NUMB INT = 2150,
          @Lc_Space_TEXT                         CHAR(1) = ' ',
          @Lc_Yes_TEXT                           CHAR(1) = 'Y',
          @Lc_DisbursementSvc_CODE               CHAR(1) = 'B',
          @Lc_DisbursementEft_CODE               CHAR(1) = 'E',
          @Lc_StatusFailed_CODE                  CHAR(1) = 'F',
          @Lc_AccountTypeChecking_CODE           CHAR(1) = 'C',
          @Lc_RecipientTypeCpNcp_CODE            CHAR(1) = '1',
          @Lc_RecipientTypefIPS_CODE             CHAR(1) = '2',
          @Lc_RecipientTypeOthp_CODE             CHAR(1) = '3',
          @Lc_StatusActive_CODE                  CHAR(1) = 'A',
          @Lc_RespondInitResponding_CODE         CHAR(1) = 'R',
          @Lc_CaseStatusOpen_CODE                CHAR(1) = 'O',
          @Lc_RelationshipCaseNcp_CODE           CHAR(1) = 'A',
		  @Lc_RelationshipCaseCp_CODE            CHAR(1) = 'C',
          @Lc_StatusCaseMemberActive_CODE        CHAR(1) = 'A',
          @Lc_ErrorTypeWarning_CODE              CHAR(1) = 'W',
          @Lc_StatusSuccess_CODE                 CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE             CHAR(1) = 'A',
          @Lc_Format_CODE                        CHAR(1) = '1',
          @Lc_RecordTypePrenote_CODE             CHAR(1) = 'P',
          @Lc_RecordTypeCpNcp_CODE               CHAR(1) = 'C',
          @Lc_RecordTypeFipsOthp_CODE            CHAR(1) = 'F',
          @Lc_RecordTypeIva_CODE                 CHAR(1) = 'A',
          @Lc_FileMode_IDNO                      CHAR(1) = 'A',
          @Lc_TypeOthpOffice_CODE                CHAR(1) = 'O',
          @Lc_RespondInitResTribal_CODE          CHAR(1) = 'S',
          @Lc_RespondInitResInternational_CODE   CHAR(1) = 'Y',
          @Lc_No_INDC                            CHAR(1) = 'N',
          @Lc_Record_INDC                        CHAR(1) = '1',
          @Lc_MsIndicator_TEXT                   CHAR(1) = 'N',
          @Lc_Seprator_TEXT                      CHAR(1) = '*',
          @Lc_FileHeader_INDC                    CHAR(1) = '1',
          @Lc_BatchHeader_CODE                   CHAR(1) = '5',
          @Lc_OrginatingState_CODE               CHAR(1) = '1',
          @Lc_DetailRecord_INDC                  CHAR(1) = '6',
          @Lc_AddendaRecord_INDC                 CHAR(1) = '7',
          @Lc_BatchControlRecord_INDC            CHAR(1) = '8',
          @Lc_FileControlRecord_INDC             CHAR(1) = '9',
          @Lc_Zero_TEXT                          CHAR(1) = '0',
          @Lc_DisburseStatusTransferEft_CODE     CHAR(2) = 'TR',
          @Lc_EftStatusPrenotepending_CODE       CHAR(2) = 'PP',
          @Lc_EftStatusActiveprenotegen_CODE     CHAR(2) = 'PG',
          @Lc_EftStatusActive_CODE               CHAR(2) = 'AC',
          @Lc_TransPnoteChking_CODE              CHAR(2) = '23',
          @Lc_TransPnoteAny_CODE                 CHAR(2) = '33',
          @Lc_TransChecking_CODE                 CHAR(2) = '22',
          @Lc_TransSaving_CODE                   CHAR(2) = '32',
          @Lc_Prrty_CODE                         CHAR(2) = '01',
          @Lc_BlockingFctr_NUMB                  CHAR(2) = '10',
          @Lc_AddendaType_CODE                   CHAR(2) = '05',
          @Lc_Application_ID                     CHAR(2) = 'II',
          @Lc_ApplicationEft_ID                  CHAR(2) = 'CS',
          @Lc_MsIndicatorPrenote_CODE            CHAR(2) = 'N ',
          @Lc_Segment_IDNO                       CHAR(3) = 'DED',
          @Lc_AddressTypeState_CODE              CHAR(3) = 'STA',
          @Lc_AddressSubTypeSdu_CODE             CHAR(3) = 'SDU',
          @Lc_AddressTypeInt_CODE                CHAR(3) = 'INT',
          @Lc_AddressSubTypeFrc_CODE             CHAR(3) = 'FRC',
          @Lc_HeaderRecordSize_TEXT              CHAR(3) = '094',
          @Lc_ServClassPrenote_CODE              CHAR(3) = '230',
          @Lc_EftSvcServClass_CODE               CHAR(3) = '220',
          @Lc_EntryClassFipsOthp_CODE            CHAR(3) = 'CCD',
          @Lc_EntryClassCpNcp_CODE               CHAR(3) = 'PPD',
          @Lc_AdditionalSeq_NUMB                 CHAR(4) = '0001',
          @Lc_TableOthp_ID                       CHAR(4) = 'OTHP',
          @Lc_TableRtyp_ID                       CHAR(4) = 'RTYP',
          @Lc_CasePrenote_CODE                   CHAR(6) = 'CASE12',
          @Lc_Job_ID                             CHAR(7) = 'DEB0640',
          @Lc_DetailedSeq_NUMB                   CHAR(7) = '0000001',
          @Lc_OrginatingBatch_NUMB               CHAR(7) = '0000001',
          @Lc_BatchNumber_NUMB                   CHAR(7) = '0000001',
          @Lc_FipsPrenote_CODE                   CHAR(7) = '9876543',
          @Lc_Origin_CODE                        CHAR(8) = '03110008',
          @Lc_OrginatingDfi_IDNO                 CHAR(8) = '03110008',
          @Lc_Destination_TEXT                   CHAR(9) = '031100089',
          @Lc_Company_IDNO                       CHAR(9) = '516000279',
          @Lc_HeaderCompany_IDNO                 CHAR(10) = '1516000279',
          @Lc_CheckRecipientIVA_ID               CHAR(10) = '999999994',
          @Lc_PrenoteEntryDescription_TEXT       CHAR(10) = 'PRENOTE',
          @Lc_EftEntryDescription_TEXT           CHAR(10) = 'DE10000',
          @Lc_Trace_NUMB                         CHAR(15) = '031100080000001',
          @Lc_PrenoteCompany_NAME                CHAR(16) = 'DELAWARE - DCSE',
          @Lc_ErrorE0944_CODE                    CHAR(18) = 'E0944',
          @Lc_Successful_TEXT                    CHAR(20) = 'SUCCESSFUL',
          @Lc_Destination_NAME                   CHAR(23) = 'PNC BANK OF DELAWARE',
          @Lc_Origin_NAME                        CHAR(23) = 'DELAWARE - DCSE',
          @Lc_EftSvcCompany_NAME                 CHAR(23) = 'DELAWARE - DCSE1',
          @Lc_BatchRunUser_TEXT                  CHAR(30) = 'BATCH',
          @Lc_Procedure_NAME                     CHAR(30) = 'SP_PROCESS_EFT_SVC_PNOTE_DISB',
          @Lc_Process_NAME                       CHAR(30) = 'BATCH_FIN_EFT_SVC_PNOTE_DISB',
          @Ld_High_DATE                          DATE = '12/31/9999',
          @Ld_Start_DATE                         DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_BatchCount_QNTY             NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RoutingBank_NUMB            NUMERIC(9) = 0,
          @Ln_PrenoteCursorLocation_QNTY  NUMERIC(10) = 0,
          @Ln_EftCursorLocation_QNTY      NUMERIC(10) = 0,
          @Ln_EftCpCount_QNTY             NUMERIC(10) = 0,
          @Ln_EftFipsOthpCount_QNTY       NUMERIC(10) = 0,
          @Ln_EftIvaCount_QNTY            NUMERIC(10) = 0,
          @Ln_RowCount_QNTY               NUMERIC(11),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_Agency_QNTY                 NUMERIC(11) = 0,
          @Ln_AgencySum_AMNT              NUMERIC(11, 2) = 0,
          @Ln_Addenda_QNTY                NUMERIC(11) = 0,
          @Ln_Svc_QNTY                    NUMERIC(11) = 0,
          @Ln_SvcSum_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_Eftdisb_QNTY                NUMERIC(11) = 0,
          @Ln_EftdisbSum_AMNT             NUMERIC(11, 2) = 0,
          @Ln_CreditEntry_AMNT            NUMERIC(11, 2) = 0,
          @Ln_CreditEntryIva_AMNT         NUMERIC(11, 2) = 0,
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19),
          @Ln_PrenoteHashCount_QNTY       NUMERIC(19) = 0,
          @Ln_EftCpNcpHashcount_QNTY      NUMERIC(19) = 0,
          @Ln_EftFipsOthpHashcount_QNTY   NUMERIC(19) = 0,
          @Ln_EftIvaHashcount_QNTY        NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_MsIndicator7_TEXT           CHAR(1) = '',
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Lc_AccountType_CODE            CHAR(1),
          @Lc_RecordType_CODE             CHAR(1),
          @Lc_Transaction_CODE            CHAR(2),
          @Lc_BlockCount_TEXT             CHAR(6),
          @Lc_Fips7_CODE                  CHAR(7) = '',
          @Lc_PrevRcpid_TEXT              CHAR(9) = '',
          @Lc_NcpSsn7_TEXT                CHAR(9) = '',
          @Lc_PaymentAmount7_TEXT         CHAR(10) = '',
          @Lc_Ncp7_NAME                   CHAR(10) = '',
          @Lc_PreNoteControlNo_TEXT       CHAR(11),
          @Lc_DsbhControlNo_TEXT          CHAR(11),
          @Lc_CaseIdentifier7_TEXT        CHAR(15) = '',
          @Lc_CaseOthState_IDNO           CHAR(15),
          @Lc_AccountNumber_TEXT          CHAR(17),
          @Lc_Payee_NAME                  CHAR(22),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_RestartKey_TEXT             VARCHAR(200),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE;
  DECLARE @Lc_PrenoteCur_CheckRecipient_ID        CHAR(10),
          @Lc_PrenoteCur_CheckRecipient_CODE      CHAR(1),
          @Ln_PrenoteCur_RoutingBank_NUMB         NUMERIC(9),
          @Lc_PrenoteCur_AccountBankNo_TEXT       CHAR(17),
          @Lc_PrenoteCur_TypeAccount_CODE         CHAR(1),
          @Ld_PrenoteCur_PreNote_DATE             DATE,
          @Ld_PrenoteCur_FirstTransfer_DATE       DATE,
          @Ld_PrenoteCur_EftStatus_DATE           DATE,
          @Lc_PrenoteCur_StatusEft_CODE           CHAR(2),
          @Lc_PrenoteCur_Reason_CODE              CHAR(5),
          @Lc_PrenoteCur_Function_CODE            CHAR(3),
          @Lc_PrenoteCur_Misc_ID                  CHAR(11),
          @Ln_PrenoteCur_EventGlobalBeginSeq_NUMB NUMERIC,
          @Ld_PrenoteCur_BeginValidity_DATE       DATE,
          @Ld_PrenoteCur_EndValidity_DATE         DATE;
  DECLARE @Lc_DsbhCur_CheckRecipient_ID        CHAR(10),
          @Lc_DsbhCur_CheckRecipient_CODE      CHAR(1),
          @Ld_DsbhCur_Disburse_DATE            DATE,
          @Ln_DsbhCur_DisburseSeq_NUMB         NUMERIC(4),
          @Lc_DsbhCur_MediumDisburse_CODE      CHAR(1),
          @Ln_DsbhCur_Disburse_AMNT            NUMERIC(11, 2),
          @Ln_DsbhCur_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Ln_DsbhCur_EventGlobalEndSeq_NUMB   NUMERIC(19),
          @Ld_DsbhCur_BeginValidity_DATE       DATE,
          @Ld_DsbhCur_EndValidity_DATE         DATE,
          @Ld_DsbhCur_Issue_DATE               DATE,
          @Lc_DsbhCur_Misc_ID                  CHAR(11),
          @Ln_DsbhCur_Case_IDNO                NUMERIC(6);
  DECLARE @Lc_EdisbCur_RecordType_CODE    CHAR(1),
          @Lc_EdisbCur_Transaction_CODE   CHAR(2),
          @Lc_EdisbCur_RoutingBank_NUMB   CHAR(9),
          @Lc_EdisbCur_AccountBankNo_TEXT CHAR(17),
          @Lc_EdisbCur_Disburse_AMNT      CHAR(10),
          @Lc_EdisbCur_Indiv_NUMB         CHAR(15),
          @Lc_EdisbCur_Payee_NAME         CHAR(22),
          @Ls_EdisbCur_AddendaRecord_TEXT VARCHAR(80);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractPnoteDisb_P1';
   SET @Ls_Sqldata_TEXT = '';

   CREATE TABLE ##ExtractPnoteDisb_P1
    (
      Seq_IDNO    NUMERIC IDENTITY(1, 1),
      Record_TEXT VARCHAR(94)
    );

   BEGIN TRANSACTION PNOTE;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   /*
   	Get the current run date and last run date from PARM_Y1 (Parameters table), and validate that the 
   	batch program was not executed for the run date
   */
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   IF EXISTS(SELECT 1
               FROM RSTL_Y1 r
              WHERE r.Job_ID = @Lc_Job_ID
                AND R.RestartKey_TEXT = CAST(@Ld_Run_DATE AS VARCHAR))
    BEGIN
     GOTO Restart_at_extract_Data;
    END

   SET @Ls_Sql_TEXT = 'DELETE EDISB_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM EDISB_Y1;

   /*
   	Generate the control number (max + 1) and update the Misc_ID field in EFTI/EFTR_Y1.
   */
   SET @Ls_Sql_TEXT = 'SELECT Misc_ID';
   SET @Ls_Sqldata_TEXT = '';
   SET @Lc_PreNoteControlNo_TEXT =0;

   SELECT @Lc_PreNoteControlNo_TEXT = ISNULL(MAX(CAST(a.Misc_ID AS NUMERIC)), 0)
     FROM EFTR_Y1 a
    WHERE a.Misc_ID <> @Lc_Space_TEXT;

   /*
   	Select all the EFT pre-notes from EFTI/EFTR_Y1
   */
   DECLARE Prenote_CUR INSENSITIVE CURSOR FOR
    SELECT e.CheckRecipient_ID,
           e.CheckRecipient_CODE,
           e.RoutingBank_NUMB,
           e.AccountBankNo_TEXT,
           e.TypeAccount_CODE,
           e.PreNote_DATE,
           e.FirstTransfer_DATE,
           e.EftStatus_DATE,
           e.StatusEft_CODE,
           e.Reason_CODE,
           e.Function_CODE,
           e.Misc_ID,
           e.EventGlobalBeginSeq_NUMB,
           e.BeginValidity_DATE,
           e.EndValidity_DATE
      FROM EFTR_Y1 e
     WHERE e.PreNote_DATE <= @Ld_Run_DATE
       AND e.StatusEft_CODE = @Lc_EftStatusPrenotepending_CODE
       AND e.EndValidity_DATE = @Ld_High_DATE
       AND e.EventGlobalEndSeq_NUMB = 0;

   SET @Ls_Sql_TEXT = 'OPEN Prenote_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Prenote_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Prenote_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Prenote_CUR INTO @Lc_PrenoteCur_CheckRecipient_ID, @Lc_PrenoteCur_CheckRecipient_CODE, @Ln_PrenoteCur_RoutingBank_NUMB, @Lc_PrenoteCur_AccountBankNo_TEXT, @Lc_PrenoteCur_TypeAccount_CODE, @Ld_PrenoteCur_PreNote_DATE, @Ld_PrenoteCur_FirstTransfer_DATE, @Ld_PrenoteCur_EftStatus_DATE, @Lc_PrenoteCur_StatusEft_CODE, @Lc_PrenoteCur_Reason_CODE, @Lc_PrenoteCur_Function_CODE, @Lc_PrenoteCur_Misc_ID, @Ln_PrenoteCur_EventGlobalBeginSeq_NUMB, @Ld_PrenoteCur_BeginValidity_DATE, @Ld_PrenoteCur_EndValidity_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE -1';
   SET @Ls_Sqldata_TEXT = '';

   -- While loop for inserting pre note data into EDISB_Y1 table.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_PrenoteCursorLocation_QNTY = @Ln_PrenoteCursorLocation_QNTY + 1;
     SET @Ls_CursorLocation_TEXT = ' PrenoteCursorLocation_QNTY = ' + ISNULL(CAST(@Ln_PrenoteCursorLocation_QNTY AS VARCHAR), '');
     SET @Ls_Sql_TEXT ='Prenote control Number';
     SET @Ls_Sqldata_TEXT ='PreNoteControlNo_TEXT = ' + @Lc_PreNoteControlNo_TEXT;
     SET @Lc_PreNoteControlNo_TEXT = CAST(@Lc_PreNoteControlNo_TEXT AS NUMERIC) + 1;

     IF @Lc_PrenoteCur_TypeAccount_CODE = @Lc_AccountTypeChecking_CODE
      BEGIN
       SET @Lc_Transaction_CODE = @Lc_TransPnoteChking_CODE;
      END
     ELSE
      BEGIN
       SET @Lc_Transaction_CODE = @Lc_TransPnoteAny_CODE;
      END
	    SET @Lc_Payee_NAME=''
	   --Bug 13735 : CR0437 - Retrive Payee Name(EFTDTL-INDIV-NAME) for Prenote - START
	   SET @Ls_Sql_TEXT = 'SELECT PAYEE NAME 1';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_PrenoteCur_CheckRecipient_ID , '');

       SELECT @Lc_Payee_NAME = ISNULL(LTRIM(RTRIM(a.First_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(a.Middle_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(a.Last_NAME)),'')
         FROM DEMO_Y1 a
        WHERE a.MemberMci_IDNO = @Lc_PrenoteCur_CheckRecipient_ID ;
		
	   --Bug 13735 : CR0437 - Retrive Payee Name(EFTDTL-INDIV-NAME) for Prenote - END
     SET @Ln_Addenda_QNTY = @Ln_Addenda_QNTY + 1;
     SET @Ls_Sql_TEXT = 'PRENOTE DETAIL RECORD';
     SET @Ls_Sqldata_TEXT ='RecordTypePrenote_CODE = ' + @Lc_RecordTypePrenote_CODE + ', Transaction_CODE = ' + @Lc_Transaction_CODE + ', RoutingBank_NUMB = ' + CAST(@Ln_PrenoteCur_RoutingBank_NUMB AS VARCHAR) + ', AccountBankNo_TEXT = ' + @Lc_PrenoteCur_AccountBankNo_TEXT + ', CheckRecipient_ID = ' + @Lc_PrenoteCur_CheckRecipient_ID + ', Payee_NAME = ' + @Lc_Payee_NAME + ', Segment_IDNO = ' + @Lc_Segment_IDNO + ', ApplicationEft_ID = ' + @Lc_ApplicationEft_ID + ', Seprator_TEXT = ' + @Lc_Seprator_TEXT + ', CasePrenote_CODE = ' + @Lc_CasePrenote_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', MsIndicatorPrenote_CODE = ' + @Lc_MsIndicatorPrenote_CODE + ', FipsPrenote_CODE = ' + @Lc_FipsPrenote_CODE;

     INSERT INTO EDISB_Y1
                 (RecordType_CODE,
                  Transaction_CODE,
                  RoutingBank_NUMB,
                  AccountBankNo_TEXT,
                  Disburse_AMNT,
                  Individual_NUMB,
                  Payee_NAME,
                  AddendaRecord_TEXT)
          VALUES ( @Lc_RecordTypePrenote_CODE,--RecordType_CODE
                   @Lc_Transaction_CODE,--Transaction_CODE
                   RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + CAST(@Ln_PrenoteCur_RoutingBank_NUMB AS VARCHAR), 9),--RoutingBank_NUMB
                   CONVERT(CHAR(17), ISNULL(@Lc_PrenoteCur_AccountBankNo_TEXT, '')),--AccountBankNo_TEXT
                   REPLICATE(@Lc_Zero_TEXT, 10),--Disburse_AMNT
                  --Bug 13735 : CR0437 - (Prenote('P') + CheckRecipient_ID + CheckRecipient_CODE)  -START
				   @Lc_RecordTypePrenote_CODE+CONVERT(CHAR(10), ISNULL(@Lc_PrenoteCur_CheckRecipient_ID, '')) + CONVERT(CHAR(4), ISNULL(@Lc_PrenoteCur_CheckRecipient_CODE, '')),--Individual_NUMB
                  --Bug 13735 : CR0437 - (Prenote('P') + CheckRecipient_ID + CheckRecipient_CODE)  -END 
				   --Bug 13735 : CR0437 - (CP First Name + Space + CP Middle Name + Space + CP Last Name)  in EFTDTL-INDIV-NAME - START
				   CONVERT(CHAR(22), @Lc_Payee_NAME),--Payee_NAME
                   --Bug 13735 : CR0437 - (CP First Name + Space + CP Middle Name + Space + CP Last Name)  in EFTDTL-INDIV-NAME - END
				   CONVERT(CHAR(80), @Lc_Segment_IDNO + @Lc_Seprator_TEXT + @Lc_ApplicationEft_ID + @Lc_Seprator_TEXT + @Lc_CasePrenote_CODE + @Lc_Seprator_TEXT + LTRIM(RTRIM(CONVERT(CHAR(15), @Ld_Run_DATE, 12))) + @Lc_Seprator_TEXT + ''--amount
                                      + @Lc_Seprator_TEXT + '' --ssn
                                      + @Lc_Seprator_TEXT + @Lc_MsIndicatorPrenote_CODE + @Lc_Seprator_TEXT + ''--Ncp Last name
                                      + @Lc_Seprator_TEXT + @Lc_FipsPrenote_CODE + '\') --AddendaRecord_TEXT
     );

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ  2150';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', ElectronicFundInstruction2150_NUMB = ' + CAST(@Li_ElectronicFundInstruction2150_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_ElectronicFundInstruction2150_NUMB,
      @Ac_Process_ID              = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE_EFTR_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_CODE = ' + ISNULL(@Lc_PrenoteCur_CheckRecipient_CODE, '') + ', CheckRecipient_ID = ' + ISNULL(@Lc_PrenoteCur_CheckRecipient_ID, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_PrenoteCur_EventGlobalBeginSeq_NUMB AS VARCHAR), '');

     UPDATE EFTR_Y1
        SET EndValidity_DATE = @Ld_Run_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
      WHERE CheckRecipient_CODE = @Lc_PrenoteCur_CheckRecipient_CODE
        AND CheckRecipient_ID = @Lc_PrenoteCur_CheckRecipient_ID
        AND EventGlobalBeginSeq_NUMB = @Ln_PrenoteCur_EventGlobalBeginSeq_NUMB;

     SET @Ln_RowCount_QNTY=@@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE EFTR_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     /*
     	Update the EFT Status field/ StatusEft_CODE table in EFTI/EFTR_Y1 to 
     	'PG' – Pre-note Generated for the selected EFT pre-notes.
     */
     SET @Ls_Sql_TEXT = 'INSERT INTO EFTR_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_PrenoteCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_PrenoteCur_CheckRecipient_CODE, '') + ', RoutingBank_NUMB = ' + ISNULL(CAST(@Ln_PrenoteCur_RoutingBank_NUMB AS VARCHAR), '') + ', AccountBankNo_TEXT = ' + ISNULL(@Lc_PrenoteCur_AccountBankNo_TEXT, '') + ', TypeAccount_CODE = ' + ISNULL(@Lc_PrenoteCur_TypeAccount_CODE, '') + ', PreNote_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', FirstTransfer_DATE = ' + ISNULL(CAST(@Ld_PrenoteCur_FirstTransfer_DATE AS VARCHAR), '') + ', EftStatus_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', StatusEft_CODE = ' + ISNULL(@Lc_EftStatusActiveprenotegen_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Function_CODE = ' + ISNULL(@Lc_PrenoteCur_Function_CODE, '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     INSERT EFTR_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             RoutingBank_NUMB,
             AccountBankNo_TEXT,
             TypeAccount_CODE,
             PreNote_DATE,
             FirstTransfer_DATE,
             EftStatus_DATE,
             StatusEft_CODE,
             Reason_CODE,
             Function_CODE,
             Misc_ID,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             BeginValidity_DATE,
             EndValidity_DATE)
     VALUES ( @Lc_PrenoteCur_CheckRecipient_ID,--CheckRecipient_ID
              @Lc_PrenoteCur_CheckRecipient_CODE,--CheckRecipient_CODE
              @Ln_PrenoteCur_RoutingBank_NUMB,--RoutingBank_NUMB
              @Lc_PrenoteCur_AccountBankNo_TEXT,--AccountBankNo_TEXT
              @Lc_PrenoteCur_TypeAccount_CODE,--TypeAccount_CODE
              @Ld_Run_DATE,--PreNote_DATE
              @Ld_PrenoteCur_FirstTransfer_DATE,--FirstTransfer_DATE
              @Ld_Run_DATE,--EftStatus_DATE
              @Lc_EftStatusActiveprenotegen_CODE,--StatusEft_CODE
              @Lc_Space_TEXT,--Reason_CODE
              @Lc_PrenoteCur_Function_CODE,--Function_CODE
              RIGHT(REPLICATE(@Lc_Zero_TEXT, 7) + LTRIM(RTRIM(@Lc_PreNoteControlNo_TEXT)), 7),--Misc_ID
              @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
              0,--EventGlobalEndSeq_NUMB
              @Ld_Run_DATE,--BeginValidity_DATE
              @Ld_High_DATE--EndValidity_DATE
     );

     SET @Ln_RowCount_QNTY=@@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO EFTR_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Prenote_CUR- 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Prenote_CUR INTO @Lc_PrenoteCur_CheckRecipient_ID, @Lc_PrenoteCur_CheckRecipient_CODE, @Ln_PrenoteCur_RoutingBank_NUMB, @Lc_PrenoteCur_AccountBankNo_TEXT, @Lc_PrenoteCur_TypeAccount_CODE, @Ld_PrenoteCur_PreNote_DATE, @Ld_PrenoteCur_FirstTransfer_DATE, @Ld_PrenoteCur_EftStatus_DATE, @Lc_PrenoteCur_StatusEft_CODE, @Lc_PrenoteCur_Reason_CODE, @Lc_PrenoteCur_Function_CODE, @Lc_PrenoteCur_Misc_ID, @Ln_PrenoteCur_EventGlobalBeginSeq_NUMB, @Ld_PrenoteCur_BeginValidity_DATE, @Ld_PrenoteCur_EndValidity_DATE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Prenote_CUR;

   DEALLOCATE Prenote_CUR;

   /*
    Find the maximum Misc_ID number created in DSBV/DSBH_Y1, increment the number by one, and update DSBV/DSBH_Y1 for the SVC disbursements.
   */
   SET @Ls_Sql_TEXT = 'GET MAX(Misc_ID) FORM DSBH_Y1';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Lc_DsbhControlNo_TEXT = ISNULL(MAX(CAST(d.Misc_ID AS NUMERIC)), 0)
     FROM DSBH_Y1 d
    WHERE d.Misc_ID <> @Lc_Space_TEXT;

   /*
   Disbursements cursor to select Transfer EFT records not yet send to Bank 
   Select all the CP’s SVC disbursements from DSBV/DSBH_Y1
   EFT disbursements ready to be sent out to CPs, County FIPS’, and other agencies and EFT disbursements from DSBV/DSBH_Y1 are selected 
   */
   SET @Ls_Sql_TEXT = 'INITIALIZE  Dsbh_CUR';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DECLARE Dsbh_CUR INSENSITIVE CURSOR FOR
    SELECT m.CheckRecipient_ID,
           m.CheckRecipient_CODE,
           m.Disburse_DATE,
           m.DisburseSeq_NUMB,
           m.MediumDisburse_CODE,
           m.Disburse_AMNT,
           m.EventGlobalBeginSeq_NUMB,
           m.EventGlobalEndSeq_NUMB,
           m.BeginValidity_DATE,
           m.EndValidity_DATE,
           m.Issue_DATE,
           m.Misc_ID,
           m.Case_IDNO
      FROM (SELECT d.CheckRecipient_ID,
                   d.CheckRecipient_CODE,
                   d.Disburse_DATE,
                   d.DisburseSeq_NUMB,
                   d.MediumDisburse_CODE,
                   l.Disburse_AMNT,
                   d.EventGlobalBeginSeq_NUMB,
                   d.EventGlobalEndSeq_NUMB,
                   d.BeginValidity_DATE,
                   d.EndValidity_DATE,
                   d.Issue_DATE,
                   d.Misc_ID,
                   l.Case_IDNO
              FROM DSBL_Y1 l,
                   DSBH_Y1 d
             WHERE d.MediumDisburse_CODE IN (@Lc_DisbursementSvc_CODE, @Lc_DisbursementEft_CODE)
               AND d.StatusCheck_CODE = @Lc_DisburseStatusTransferEft_CODE
               AND d.Misc_ID = @Lc_Space_TEXT
               AND d.Disburse_DATE <= @Ld_Run_DATE
               AND d.EndValidity_DATE = @Ld_High_DATE
               AND l.CheckRecipient_ID = d.CheckRecipient_ID
               AND l.CheckRecipient_CODE = d.CheckRecipient_CODE
               AND l.Disburse_DATE = d.Disburse_DATE
               AND l.DisburseSeq_NUMB = d.DisburseSeq_NUMB
               AND l.CheckRecipient_ID <> @Lc_CheckRecipientIVA_ID
            UNION ALL
            SELECT d.CheckRecipient_ID,
                   d.CheckRecipient_CODE,
                   d.Disburse_DATE,
                   d.DisburseSeq_NUMB,
                   d.MediumDisburse_CODE,
                   D.Disburse_AMNT,
                   d.EventGlobalBeginSeq_NUMB,
                   d.EventGlobalEndSeq_NUMB,
                   d.BeginValidity_DATE,
                   d.EndValidity_DATE,
                   d.Issue_DATE,
                   d.Misc_ID,
                   0 AS Case_IDNO
              FROM DSBH_Y1 D
             WHERE d.MediumDisburse_CODE = @Lc_DisbursementEft_CODE
               AND d.StatusCheck_CODE = @Lc_DisburseStatusTransferEft_CODE
               AND d.Misc_ID = @Lc_Space_TEXT
               AND d.Disburse_DATE <= @Ld_Run_DATE
               AND d.EndValidity_DATE = @Ld_High_DATE
               AND d.CheckRecipient_ID = @Lc_CheckRecipientIVA_ID) M
     ORDER BY M.CheckRecipient_ID,
              M.CheckRecipient_CODE,
              M.Disburse_DATE,
              M.DisburseSeq_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN Dsbh_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Dsbh_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Dsbh_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Dsbh_CUR INTO @Lc_DsbhCur_CheckRecipient_ID, @Lc_DsbhCur_CheckRecipient_CODE, @Ld_DsbhCur_Disburse_DATE, @Ln_DsbhCur_DisburseSeq_NUMB, @Lc_DsbhCur_MediumDisburse_CODE, @Ln_DsbhCur_Disburse_AMNT, @Ln_DsbhCur_EventGlobalBeginSeq_NUMB, @Ln_DsbhCur_EventGlobalEndSeq_NUMB, @Ld_DsbhCur_BeginValidity_DATE, @Ld_DsbhCur_EndValidity_DATE, @Ld_DsbhCur_Issue_DATE, @Lc_DsbhCur_Misc_ID, @Ln_DsbhCur_Case_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE -2';
   SET @Ls_Sqldata_TEXT = '';

   --While loop for insering EFT/SVC transaction data into EDISB_Y1 table.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_EftCursorLocation_QNTY =@Ln_EftCursorLocation_QNTY + 1;
     SET @Ls_CursorLocation_TEXT = 'EftCursorLocation_QNTY = ' + ISNULL(CAST(@Ln_EftCursorLocation_QNTY AS VARCHAR), '');
     SET @Ln_RoutingBank_NUMB =0;
     SET @Lc_AccountNumber_TEXT =@Lc_Space_TEXT;

     IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
        AND @Lc_DsbhCur_MediumDisburse_CODE = @Lc_DisbursementSvc_CODE
      BEGIN
       /*
       Find the SVC instructions (account number and SVC number) of the CheckRecipient_ID  in SVCI/DCRS_Y1 table.
       */
       SET @Ls_Sql_TEXT = 'SELECT SVC_INSTRUCTIONS FROM DCRS_Y1';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_DsbhCur_CheckRecipient_ID AS VARCHAR), '') + ', StatusActive_CODE = ' + @Lc_StatusActive_CODE + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       SELECT @Ln_RoutingBank_NUMB = d.RoutingBank_NUMB,
              @Lc_AccountNumber_TEXT = CAST(d.AccountBankNo_TEXT AS VARCHAR)
         FROM DCRS_Y1 d
        WHERE d.CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
          AND d.Status_CODE = @Lc_StatusActive_CODE
          AND d.EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY=@@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'ACTIVE SVC_INSTRUCTIONS NOT FOUND FOR RECIPIENT';

         RAISERROR(50001,16,1);
        END

       SET @Ln_Svc_QNTY = @Ln_Svc_QNTY + 1;
       SET @Ln_SvcSum_AMNT = @Ln_SvcSum_AMNT + @Ln_DsbhCur_Disburse_AMNT;
       SET @Lc_Transaction_CODE = @Lc_TransChecking_CODE;
      END --SVC
     ELSE
      BEGIN
       /*
       For all the selected records, active EFT instructions (bank routing number, account number, and type of account) of the funds recipient are extracted from EFTI/EFTR_Y1.
       */
       SET @Ls_Sql_TEXT = 'SELECT EFT_INSTRUCTIONS FROM EFTR_Y1';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_DsbhCur_CheckRecipient_ID AS VARCHAR), '') + ', EftStatusActive_CODE = ' + @Lc_EftStatusActive_CODE + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       SELECT @Ln_RoutingBank_NUMB = e.RoutingBank_NUMB,
              @Lc_AccountNumber_TEXT = e.AccountBankNo_TEXT,
              @Lc_AccountType_CODE = e.TypeAccount_CODE
         FROM EFTR_Y1 e
        WHERE e.CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
          AND e.StatusEft_CODE = @Lc_EftStatusActive_CODE
          AND e.EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY=@@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'ACTIVE EFT_INSTRUCTIONS NOT FOUND FOR RECIPIENT';

         RAISERROR (50001,16,1);
        END

       IF @Lc_AccountType_CODE = @Lc_AccountTypeChecking_CODE
        BEGIN
         SET @Lc_Transaction_CODE = @Lc_TransChecking_CODE;
        END
       ELSE
        BEGIN
         SET @Lc_Transaction_CODE = @Lc_TransSaving_CODE;
        END
      END

     IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
      BEGIN
       IF @Lc_DsbhCur_MediumDisburse_CODE = @Lc_DisbursementEft_CODE
        BEGIN
         SET @Ln_EftdisbSum_AMNT = @Ln_EftdisbSum_AMNT + @Ln_DsbhCur_Disburse_AMNT;
         SET @Ln_Eftdisb_QNTY = @Ln_Eftdisb_QNTY + 1;
        END
      END
     ELSE
      BEGIN
       SET @Ln_Agency_QNTY = @Ln_Agency_QNTY + 1;
       SET @Ln_AgencySum_AMNT = @Ln_AgencySum_AMNT + @Ln_DsbhCur_Disburse_AMNT;
      END
    
     --Bug 13735 : CR0437 - Existing Payee Name(EFTDTL-INDIV-NAME) retrival logic - REMOVED

	 IF EXISTS(SELECT 1
                 FROM DSBH_Y1
                WHERE CheckRecipient_CODE = @Lc_DsbhCur_CheckRecipient_CODE
                  AND CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
                  AND Disburse_DATE = @Ld_DsbhCur_Disburse_DATE
                  AND DisburseSeq_NUMB = @Ln_DsbhCur_DisburseSeq_NUMB
                  AND EventGlobalBeginSeq_NUMB = @Ln_DsbhCur_EventGlobalBeginSeq_NUMB
                  AND Misc_ID = @Lc_Space_TEXT)
      BEGIN
       SET @Ls_Sql_TEXT = 'INCREMENT CONTROL NUMBER';
       SET @Ls_Sqldata_TEXT = 'DsbhControlNo_TEXT = ' + @Lc_DsbhControlNo_TEXT;
       SET @Lc_DsbhControlNo_TEXT = CAST((CAST(@Lc_DsbhControlNo_TEXT AS NUMERIC) + 1) AS VARCHAR);
       /*
       Update the ISSUE_DATE field with the job run date (PROCESS-DATE) in DSBV/DSBH_Y1 for the SVC disbursements.
       */
       SET @Ls_Sql_TEXT = 'UPDATE DSBH_Y1';
       SET @Ls_Sqldata_TEXT ='DsbhControlNo_TEXT = ' + @Lc_DsbhControlNo_TEXT + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', CheckRecipient_CODE = ' + @Lc_DsbhCur_CheckRecipient_CODE + ', CheckRecipient_ID = ' + @Lc_DsbhCur_CheckRecipient_ID + ', Disburse_DATE = ' + CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR) + ', DisburseSeq_NUMB = ' + CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR) + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_DsbhCur_EventGlobalBeginSeq_NUMB AS VARCHAR);

       UPDATE DSBH_Y1
          SET Misc_ID = @Lc_DsbhControlNo_TEXT,
              Issue_DATE = @Ld_Run_DATE
        WHERE CheckRecipient_CODE = @Lc_DsbhCur_CheckRecipient_CODE
          AND CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
          AND Disburse_DATE = @Ld_DsbhCur_Disburse_DATE
          AND DisburseSeq_NUMB = @Ln_DsbhCur_DisburseSeq_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_DsbhCur_EventGlobalBeginSeq_NUMB;

       SET @Ln_RowCount_QNTY=@@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE_VDSBH FAILED';

         RAISERROR(50001,16,1);
        END
      END

     IF NOT EXISTS(SELECT 1
                     FROM DEFT_Y1
                    WHERE CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
                      AND CheckRecipient_CODE = @Lc_DsbhCur_CheckRecipient_CODE
                      AND Disburse_DATE = @Ld_DsbhCur_Disburse_DATE
                      AND DisburseSeq_NUMB = @Ln_DsbhCur_DisburseSeq_NUMB
                      AND EventGlobalSeq_NUMB = @Ln_DsbhCur_EventGlobalBeginSeq_NUMB)
      BEGIN
       /*
       	Insert a record into DEFT_Y1 to view the disbursement details in DSBV.
       */
       SET @Ls_Sql_TEXT = 'INSERT INTO DEFT_Y1';
       SET @Ls_Sqldata_TEXT ='CheckRecipient_ID = ' + @Lc_DsbhCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_DsbhCur_CheckRecipient_CODE + ', Disburse_DATE = ' + CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR) + ', DisburseSeq_NUMB = ' + CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR) + ', RoutingBank_NUMB = ' + CAST(@Ln_RoutingBank_NUMB AS VARCHAR) + ', AccountNumber_TEXT = ' + @Lc_AccountNumber_TEXT + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_DsbhCur_EventGlobalBeginSeq_NUMB AS VARCHAR);

       INSERT DEFT_Y1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               Disburse_DATE,
               DisburseSeq_NUMB,
               RoutingBank_NUMB,
               AccountBankNo_TEXT,
               EventGlobalSeq_NUMB)
       VALUES ( @Lc_DsbhCur_CheckRecipient_ID,--CheckRecipient_ID
                @Lc_DsbhCur_CheckRecipient_CODE,--CheckRecipient_CODE
                @Ld_DsbhCur_Disburse_DATE,--Disburse_DATE
                @Ln_DsbhCur_DisburseSeq_NUMB,--DisburseSeq_NUMB
                @Ln_RoutingBank_NUMB,--RoutingBank_NUMB
                ISNULL(@Lc_AccountNumber_TEXT, @Lc_Space_TEXT),--AccountBankNo_TEXT
                @Ln_DsbhCur_EventGlobalBeginSeq_NUMB --EventGlobalSeq_NUMB
       );

       SET @Ln_RowCount_QNTY=@@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO DEFT_Y1 FAILED';

         RAISERROR(50001,16,1);
        END
      END;

     SET @Ls_Sql_TEXT = 'ASSIGN_RECORD_7_EFT_VALUES';
     SET @Ls_Sqldata_TEXT ='';
     SET @Ls_Sql_TEXT = 'SELECT_ICAS_Y1';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_DsbhCur_CheckRecipient_ID AS VARCHAR), '') + ', Case_IDNO = ' + CAST(@Ln_DsbhCur_Case_IDNO AS VARCHAR) + ', RespondInitResponding_CODE = ' + @Lc_RespondInitResponding_CODE + ', CaseStatusOpen_CODE = ' + @Lc_CaseStatusOpen_CODE + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);
     SET @Lc_CaseOthState_IDNO ='000000000000000';

     SELECT @Lc_CaseOthState_IDNO = i.IVDOutOfStateCase_ID
       FROM ICAS_Y1 i
      WHERE i.Case_IDNO = @Ln_DsbhCur_Case_IDNO
        AND @Ln_DsbhCur_Case_IDNO <> 0
        AND i.RespondInit_CODE IN(@Lc_RespondInitResponding_CODE, @Lc_RespondInitResTribal_CODE, @Lc_RespondInitResInternational_CODE)
        AND i.Status_CODE = @Lc_CaseStatusOpen_CODE
        AND i.IVDOutOfStateFips_CODE = SUBSTRING(@Lc_DsbhCur_CheckRecipient_ID, 1, 2)
        AND i.EndValidity_DATE = @Ld_High_DATE;

     SET @Ls_Sql_TEXT = 'SELECT_MS_INDICATOR';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Lc_DsbhCur_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DsbhCur_Case_IDNO AS VARCHAR), '') + ', Yes_TEXT = ' + @Lc_Yes_TEXT + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);
     SET @Lc_CaseIdentifier7_TEXT = @Lc_CaseOthState_IDNO;
     SET @Lc_PaymentAmount7_TEXT = CAST(@Ln_DsbhCur_Disburse_AMNT * 100 AS BIGINT);
     SET @Lc_NcpSsn7_TEXT=REPLICATE(@Lc_Zero_TEXT, 9);
     SET @Lc_Fips7_CODE = REPLICATE(@Lc_Zero_TEXT, 7);

     IF @Ln_DsbhCur_Case_IDNO <> 0
      BEGIN
       SET @Ln_Addenda_QNTY = @Ln_Addenda_QNTY + 1;
      END;

     IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
      BEGIN
       SET @Lc_RecordType_CODE= @Lc_RecordTypeCpNcp_CODE;
      END
     ELSE IF @Ln_DsbhCur_Case_IDNO <> 0
      BEGIN
       SET @Lc_RecordType_CODE =@Lc_RecordTypeFipsOthp_CODE;
       SET @Ls_Sql_TEXT = 'SELECT_DEMO_CP_SSN';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_DsbhCur_Case_IDNO AS VARCHAR) + ', RelationshipCaseNcp_CODE = ' + CAST(@Lc_RelationshipCaseNcp_CODE AS VARCHAR) + ', StatusCaseMemberActive_CODE = ' + @Lc_StatusCaseMemberActive_CODE;

       SELECT @Lc_NcpSsn7_TEXT = RIGHT(REPLICATE(CAST(0 AS VARCHAR), 9) + CAST(d.MemberSsn_NUMB AS VARCHAR), 9)
         FROM DEMO_Y1 d
        WHERE d.MemberMci_IDNO = (SELECT c.MemberMci_IDNO
                                    FROM CMEM_Y1 c
                                   WHERE c.Case_IDNO = @Ln_DsbhCur_Case_IDNO
                                     AND c.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
                                     AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE);

       SET @Lc_Fips7_CODE = @Lc_DsbhCur_CheckRecipient_ID;
      END
     ELSE IF @Ln_DsbhCur_Case_IDNO = 0
      BEGIN
       SET @Lc_RecordType_CODE =@Lc_RecordTypeIva_CODE;
       SET @Ln_CreditEntryIva_AMNT =@Ln_CreditEntryIva_AMNT + @Ln_DsbhCur_Disburse_AMNT;
      END
	
	  --Bug 13735 : CR0437 - (CP First Name + Space + CP Middle Name + Space + CP Last Name)  in EFTDTL-INDIV-NAME - START
     SET @Lc_Ncp7_NAME=@Lc_Space_TEXT;
	 SET @Lc_Payee_NAME =@Lc_Space_TEXT;

     IF @Ln_DsbhCur_Case_IDNO <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT NCP NAME';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_DsbhCur_Case_IDNO AS VARCHAR);

       SELECT @Lc_Ncp7_NAME = LTRIM(RTRIM(a.LastNcp_NAME)),
		@Lc_Payee_NAME =LTRIM(RTRIM(a.FirstCp_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(a.MiddleCp_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(a.LastCp_NAME))
         FROM ENSD_Y1 a
        WHERE a.Case_IDNO = @Ln_DsbhCur_Case_IDNO;

       SET @Ln_RowCount_QNTY=@@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT NCP NAME 1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_DsbhCur_Case_IDNO AS VARCHAR) + ', RelationshipCaseNcp_CODE = ' + @Lc_RelationshipCaseNcp_CODE + ', StatusCaseMemberActive_CODE = ' + @Lc_StatusCaseMemberActive_CODE;

         SELECT @Lc_Ncp7_NAME = LTRIM(RTRIM(d.Last_NAME))
           FROM DEMO_Y1 d
          WHERE d.MemberMci_IDNO = (SELECT c.MemberMci_IDNO
                                      FROM CMEM_Y1 c
                                     WHERE c.Case_IDNO = @Ln_DsbhCur_Case_IDNO
                                       AND c.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_CODE
                                       AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE);
		
		 -- Payee Name retrival for EFT and SVC
		 SET @Ls_Sql_TEXT = 'SELECT CP NAME 1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_DsbhCur_Case_IDNO AS VARCHAR) + ', RelationshipCaseCp_CODE = ' + @Lc_RelationshipCaseCp_CODE + ', StatusCaseMemberActive_CODE = ' + @Lc_StatusCaseMemberActive_CODE;

         SELECT  @Lc_Payee_NAME = ISNULL(LTRIM(RTRIM(d.First_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(d.Middle_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(d.Last_NAME)),'')
           FROM DEMO_Y1 d
          WHERE d.MemberMci_IDNO = (SELECT c.MemberMci_IDNO
                                      FROM CMEM_Y1 c
                                     WHERE c.Case_IDNO = @Ln_DsbhCur_Case_IDNO
                                       AND c.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE
                                       AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE);
        END;
      END
	  ELSE IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT PAYEE NAME 3';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', TypeOthpOffice_CODE = ' + @Lc_TypeOthpOffice_CODE + ', TableOthp_ID = ' + @Lc_TableOthp_ID + ', TableRtyp_ID = ' + @Lc_TableRtyp_ID + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       SELECT @Lc_Payee_NAME = e.OtherParty_NAME
         FROM OTHP_Y1 e
        WHERE e.OtherParty_IDNO = @Lc_DsbhCur_CheckRecipient_ID 
          AND e.TypeOthp_CODE IN (SELECT @Lc_TypeOthpOffice_CODE
                                  UNION ALL
                                  SELECT a.Value_CODE
                                    FROM REFM_Y1 a
                                   WHERE a.Table_ID = @Lc_TableOthp_ID
                                     AND a.TableSub_ID = @Lc_TableRtyp_ID)
          AND e.EndValidity_DATE = @Ld_High_DATE;

		END;
     SET @Ls_Sql_TEXT = 'EFT SVC DETAIL RECORD 1';
     SET @Ls_Sqldata_TEXT = 'RecordType_CODE = ' + @Lc_RecordType_CODE + ', Transaction_CODE = ' + @Lc_Transaction_CODE + ', RoutingBank_NUMB = ' + CAST(@Ln_RoutingBank_NUMB AS VARCHAR) + ', AccountNumber_TEXT = ' + @Lc_AccountNumber_TEXT + ', Disburse_AMNT = ' + CAST(@Ln_DsbhCur_Disburse_AMNT AS VARCHAR) + ', CheckRecipient_ID = ' + @Lc_DsbhCur_CheckRecipient_ID + ', Payee_NAME = ' + ISNULL(@Lc_Payee_NAME, '') + ', Segment_IDNO = ' + @Lc_Segment_IDNO + ', Seprator_TEXT = ' + @Lc_Seprator_TEXT + ', Application_ID = ' + @Lc_Application_ID + ', CaseIdentifier7_TEXT = ' + @Lc_CaseIdentifier7_TEXT + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', PaymentAmount7_TEXT = ' + @Lc_PaymentAmount7_TEXT + ', MsIndicator7_TEXT = ' + @Lc_MsIndicator_TEXT + ', Ncp7_NAME = ' + @Lc_Ncp7_NAME + ', Fips7_CODE = ' + @Lc_Fips7_CODE;

     INSERT INTO EDISB_Y1
                 (RecordType_CODE,
                  Transaction_CODE,
                  RoutingBank_NUMB,
                  AccountBankNo_TEXT,
                  Disburse_AMNT,
                  Individual_NUMB,
                  Payee_NAME,
                  AddendaRecord_TEXT)
          VALUES ( @Lc_RecordType_CODE,--RecordType_CODE
                   @Lc_Transaction_CODE,--Transaction_CODE
                   RIGHT(REPLICATE(@Lc_Zero_TEXT, 9) + CAST(@Ln_RoutingBank_NUMB AS VARCHAR), 9),--RoutingBank_NUMB
                   CONVERT(CHAR(17), ISNULL(@Lc_AccountNumber_TEXT, '')),--AccountBankNo_TEXT
                   RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + CAST(CAST(@Ln_DsbhCur_Disburse_AMNT * 100 AS BIGINT) AS VARCHAR), 10),--Disburse_AMNT
                   @Lc_DsbhCur_MediumDisburse_CODE+CONVERT(CHAR(14), @Lc_DsbhControlNo_TEXT ),--Individual_NUMB
                   CONVERT(CHAR(22), @Lc_Payee_NAME),--Payee_NAME
                   CONVERT(CHAR(80), @Lc_Segment_IDNO + @Lc_Seprator_TEXT + @Lc_Application_ID + @Lc_Seprator_TEXT + LTRIM(RTRIM(@Lc_CaseIdentifier7_TEXT)) + @Lc_Seprator_TEXT + LTRIM(RTRIM(CONVERT(CHAR(15), @Ld_Run_DATE, 12))) + @Lc_Seprator_TEXT + LTRIM(RTRIM(@Lc_PaymentAmount7_TEXT)) + @Lc_Seprator_TEXT + @Lc_NcpSsn7_TEXT + @Lc_Seprator_TEXT + @Lc_MsIndicator_TEXT + @Lc_Seprator_TEXT + LTRIM(RTRIM(ISNULL(UPPER(@Lc_Ncp7_NAME), ''))) + @Lc_Seprator_TEXT + LTRIM(RTRIM(@Lc_Fips7_CODE)) + '\') --AddendaRecord_TEXT
     );
	  --Bug 13735 : CR0437 - (CP First Name + Space + CP Middle Name + Space + CP Last Name)  in EFTDTL-INDIV-NAME - END
     SET @Lc_CaseIdentifier7_TEXT = @Lc_Space_TEXT;
     SET @Lc_PaymentAmount7_TEXT = @Lc_Space_TEXT;
     SET @Lc_MsIndicator7_TEXT = @Lc_Space_TEXT;
     SET @Lc_Ncp7_NAME = @Lc_Space_TEXT;
     SET @Lc_Fips7_CODE = @Lc_Space_TEXT;
     SET @Ls_Sql_TEXT = 'FETCH Dsbl_CUR-1';
     SET @Ls_Sqldata_TEXT = '';
     SET @Lc_PrevRcpid_TEXT = @Lc_DsbhCur_CheckRecipient_ID;
     SET @Ls_Sql_TEXT = 'FETCH Dsbh_CUR - 1';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Dsbh_CUR INTO @Lc_DsbhCur_CheckRecipient_ID, @Lc_DsbhCur_CheckRecipient_CODE, @Ld_DsbhCur_Disburse_DATE, @Ln_DsbhCur_DisburseSeq_NUMB, @Lc_DsbhCur_MediumDisburse_CODE, @Ln_DsbhCur_Disburse_AMNT, @Ln_DsbhCur_EventGlobalBeginSeq_NUMB, @Ln_DsbhCur_EventGlobalEndSeq_NUMB, @Ld_DsbhCur_BeginValidity_DATE, @Ld_DsbhCur_EndValidity_DATE, @Ld_DsbhCur_Issue_DATE, @Lc_DsbhCur_Misc_ID, @Ln_DsbhCur_Case_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Dsbh_CUR;

   DEALLOCATE Dsbh_CUR;

   IF @Ln_EftCursorLocation_QNTY = 0
      AND @Ln_PrenoteCursorLocation_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrorTypeWarning_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_EftCursorLocation_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '') + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', Space_TEXT = ' + @Lc_Space_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @An_Line_NUMB                = @Ln_EftCursorLocation_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'INSERT_EFCD';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', CountPreNotes_QNTY = ' + ISNULL(CAST(@Ln_PrenoteCursorLocation_QNTY AS VARCHAR), '') + ', DirectDeposit_AMNT = ' + ISNULL(CAST(@Ln_EftdisbSum_AMNT AS VARCHAR), '') + ', CountDirectDeposit_QNTY = ' + ISNULL(CAST(@Ln_Eftdisb_QNTY AS VARCHAR), '') + ', Svc_AMNT = ' + ISNULL(CAST(@Ln_SvcSum_AMNT AS VARCHAR), '') + ', CountSvc_QNTY = ' + ISNULL(CAST(@Ln_Svc_QNTY AS VARCHAR), '') + ', Agency_AMNT = ' + ISNULL(CAST(@Ln_AgencySum_AMNT AS VARCHAR), '') + ', CountAgency_QNTY = ' + ISNULL(CAST(@Ln_Agency_QNTY AS VARCHAR), '') + ', CountAgencyAddenda_QNTY = ' + ISNULL(CAST(@Ln_Addenda_QNTY AS VARCHAR), '');

   INSERT EFCD_Y1
          (Generate_DATE,
           CountPreNotes_QNTY,
           DirectDeposit_AMNT,
           CountDirectDeposit_QNTY,
           Svc_AMNT,
           CountSvc_QNTY,
           Agency_AMNT,
           CountAgency_QNTY,
           CountAgencyAddenda_QNTY)
   VALUES ( @Ld_Run_DATE,--Generate_DATE
            @Ln_PrenoteCursorLocation_QNTY,--CountPreNotes_QNTY
            @Ln_EftdisbSum_AMNT,--DirectDeposit_AMNT
            @Ln_Eftdisb_QNTY,--CountDirectDeposit_QNTY
            @Ln_SvcSum_AMNT,--Svc_AMNT
            @Ln_Svc_QNTY,--CountSvc_QNTY
            @Ln_AgencySum_AMNT,--Agency_AMNT
            @Ln_Agency_QNTY,--CountAgency_QNTY
            @Ln_Addenda_QNTY --CountAgencyAddenda_QNTY
   );

   SET @Ln_RowCount_QNTY=@@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'INSERT_EFCD FAILED';

     RAISERROR(50001,16,1);
    END

   RESTART_AT_EXTRACT_DATA:

   SET @Ls_RestartKey_TEXT = CAST(@Ld_Run_DATE AS VARCHAR);
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', RestartKey_TEXT = ' + ISNULL(@Ls_RestartKey_TEXT, '');

   EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @As_RestartKey_TEXT       = @Ls_RestartKey_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   COMMIT TRANSACTION PNOTE;

   SET @Ls_Sql_TEXT = 'FILE HEADER RECORD';
   SET @Ls_Sqldata_TEXT = 'FileHeader_INDC = ' + @Lc_FileHeader_INDC + ', Prrty_CODE = ' + @Lc_Prrty_CODE + ', Destination_TEXT = ' + @Lc_Destination_TEXT + ', Company_IDNO = ' + @Lc_Company_IDNO + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', FileMode_IDNO = ' + @Lc_FileMode_IDNO + ', HeaderRecordSize_TEXT = ' + @Lc_HeaderRecordSize_TEXT + ', BlockingFctr_NUMB = ' + @Lc_BlockingFctr_NUMB + ', Format_CODE = ' + @Lc_Format_CODE + ', Destination_NAME = ' + @Lc_Destination_NAME + ', Origin_NAME = ' + @Lc_Origin_NAME;

   INSERT INTO ##ExtractPnoteDisb_P1
               (Record_TEXT)
        VALUES ( @Lc_FileHeader_INDC --  EFT-FILE-HEADER-TYPE 
                  + @Lc_Prrty_CODE --  EFTCFH-PRRTY-CD
                  + @Lc_Space_TEXT --  FILLER
                  + @Lc_Destination_TEXT --  EFTCFH-IMMED-DEST
                  + @Lc_Space_TEXT --  FILLER
                  + @Lc_Company_IDNO --  EFTCFH-IMMED-ORIG
                  + CONVERT(CHAR(6), @Ld_Run_DATE, 12) -- EFTCFH-TRANSMSSN-DT
                  + CONVERT(CHAR(4), REPLACE(CONVERT(CHAR, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 108), ':', '')) --EFTCFH-TRNSMSSN-TIME
                  + @Lc_FileMode_IDNO -- EFTCH-FILE-ID-MODFR
                  + @Lc_HeaderRecordSize_TEXT -- EFTCFH-REC-SIZE
                  + @Lc_BlockingFctr_NUMB -- EFTCFH-BLK-FCTR 
                  + @Lc_Format_CODE --  EFTCFH-FMAT-CD
                  + CONVERT(CHAR(23), @Lc_Destination_NAME) -- EFTCFH-IMMED-DEST-NAME 
                  + CONVERT(CHAR(23), @Lc_Origin_NAME) -- EFTCFH-IMMED-ORIG-NAME 
                  + REPLICATE(@Lc_Space_TEXT, 8) -- EFTCFH-RFRNC-CD -- Record_TEXT
   );

   SET @Ls_Sql_TEXT = 'PRENOTE  RECORD COUNT';
   SET @Ls_Sqldata_TEXT = 'RecordTypePrenote_CODE = ' + @Lc_RecordTypePrenote_CODE;

   SELECT @Ln_PrenoteCursorLocation_QNTY = COUNT(1)
     FROM EDISB_Y1 e
    WHERE e.RecordType_CODE = @Lc_RecordTypePrenote_CODE;

   IF @Ln_PrenoteCursorLocation_QNTY > 0
    BEGIN
     SET @Ln_BatchCount_QNTY =@Ln_BatchCount_QNTY + 1;
     SET @Ls_Sql_TEXT = 'PRENOTE BATCH HEADER RECORD';
     SET @Ls_Sqldata_TEXT = 'BatchHeader_CODE = ' + @Lc_BatchHeader_CODE + ', ServClassPrenote_CODE = ' + @Lc_ServClassPrenote_CODE + ', PrenoteCompany_NAME = ' + @Lc_PrenoteCompany_NAME + ', HeaderCompany_IDNO = ' + @Lc_HeaderCompany_IDNO + ', EntryClassCpNcp_CODE = ' + @Lc_EntryClassCpNcp_CODE + ', PrenoteEntryDescription_TEXT = ' + @Lc_PrenoteEntryDescription_TEXT + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', OrginatingState_CODE = ' + @Lc_OrginatingState_CODE + ', OrginatingDfi_IDNO = ' + @Lc_OrginatingDfi_IDNO + ', BatchNumber_NUMB = ' + @Lc_BatchNumber_NUMB;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
          VALUES ( @Lc_BatchHeader_CODE -- EFT-BATCH-HEADER-TYPE 
                    + @Lc_ServClassPrenote_CODE -- EFTCBH-SERV-CLS-CD 
                    + CONVERT(CHAR(16), @Lc_PrenoteCompany_NAME) --  EFTCBH-COMP-NAME 
                    + REPLICATE(@Lc_Space_TEXT, 20)-- EFTCBH-COMP-DESCRET-DATA 
                    + @Lc_HeaderCompany_IDNO --EFTCBH-COMP-ID 
                    + @Lc_EntryClassCpNcp_CODE -- EFTCBH-STD-ENTRY-CLS-CD 
                    + CONVERT(CHAR(10), @Lc_PrenoteEntryDescription_TEXT)-- EFTCBH-COMP-ENTRY-DESC 
                    + CONVERT(VARCHAR, @Ld_Run_DATE, 12) -- EFTCBH-COMP-DESC-DT 
                    + CONVERT(VARCHAR, @Ld_Run_DATE, 12) -- EFTCBH-EFF-ENTRY 
                    + REPLICATE(@Lc_Space_TEXT, 3)-- EFTCBH-STTLMNT-DT 
                    + @Lc_OrginatingState_CODE -- EFTCBH-ORIG-STAT-CD 
                    + @Lc_OrginatingDfi_IDNO -- EFTCBH-ORIG-DFI-ID 
                    + @Lc_BatchNumber_NUMB -- EFTCBH-BATCH-NBR -- Record_TEXT
     );

     DECLARE Edisb_CUR INSENSITIVE CURSOR FOR
      SELECT e.RecordType_CODE,
             e.Transaction_CODE,
             e.RoutingBank_NUMB,
             e.AccountBankNo_TEXT,
             e.Disburse_AMNT,
             e.Individual_NUMB,
             e.Payee_NAME,
             e.AddendaRecord_TEXT
        FROM EDISB_Y1 e
       WHERE e.RecordType_CODE = @Lc_RecordTypePrenote_CODE;

     SET @Ls_Sql_TEXT = 'OPEN Edisb_CUR';
     SET @Ls_Sqldata_TEXT = '';

     OPEN Edisb_CUR;

     SET @Ls_Sql_TEXT = 'FETCH Edisb_CUR - 1';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Edisb_CUR INTO @Lc_EdisbCur_RecordType_CODE, @Lc_EdisbCur_Transaction_CODE, @Lc_EdisbCur_RoutingBank_NUMB, @Lc_EdisbCur_AccountBankNo_TEXT, @Lc_EdisbCur_Disburse_AMNT, @Lc_EdisbCur_Indiv_NUMB, @Lc_EdisbCur_Payee_NAME, @Ls_EdisbCur_AddendaRecord_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'WHILE -4';
     SET @Ls_Sqldata_TEXT = '';

     -- While loop for creating prenote detail record
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       --For Prenote records, -  Check amount is always Zero.	
       SET @Ls_Sql_TEXT = 'PRENOTE DETAIL RECORD';
       SET @Ls_Sqldata_TEXT ='Transaction_CODE = ' + @Lc_EdisbCur_Transaction_CODE + ', RoutingBank_NUMB = ' + @Lc_EdisbCur_RoutingBank_NUMB + ', AccountBankNo_TEXT = ' + @Lc_EdisbCur_AccountBankNo_TEXT + ', Disburse_AMNT = ' + @Lc_EdisbCur_Disburse_AMNT + ', Indiv_NUMB = ' + @Lc_EdisbCur_Indiv_NUMB + ', Payee_NAME = ' + @Lc_EdisbCur_Payee_NAME + ', Record_INDC = ' + @Lc_Record_INDC + ', Trace_NUMB = ' + @Lc_Trace_NUMB;

       INSERT INTO ##ExtractPnoteDisb_P1
                   (Record_TEXT)
            VALUES ( @Lc_DetailRecord_INDC -- EFT-DET-REC-TYPE
                      + @Lc_EdisbCur_Transaction_CODE-- EFTDTL-TRANS-CD 
                      + @Lc_EdisbCur_RoutingBank_NUMB-- EFTDTL-RCVNG-DFI   EFTDTL-CHK-DIGIT
                      + @Lc_EdisbCur_AccountBankNo_TEXT-- EFTDTL-DFI-ACCT-NBR 
                      + @Lc_EdisbCur_Disburse_AMNT--EFTDTL-AMT 
                      + @Lc_EdisbCur_Indiv_NUMB-- EFTDTL-INDIV-ID-NBR 
                      + @Lc_EdisbCur_Payee_NAME--EFTDTL-INDIV-ID-NBR
                      + REPLICATE(@Lc_Space_TEXT, 2)-- EFTDTL-DESCRET-DATA 
                      + @Lc_Record_INDC -- EFTDTL-ADD-REC-IND 
                      + @Lc_Trace_NUMB -- EFTDTL-TRACE-NBR 	 --	 Record_TEXT
       );

       SET @Ls_Sql_TEXT = 'PRENOTE Addenda Record';
       SET @Ls_Sqldata_TEXT ='AddendaRecord_INDC = ' + @Lc_AddendaRecord_INDC + ', AddendaType_CODE = ' + @Lc_AddendaType_CODE + ', AdditionalSeq_NUMB = ' + @Lc_AdditionalSeq_NUMB + ', DetailedSeq_NUMB = ' + @Lc_DetailedSeq_NUMB;

       INSERT INTO ##ExtractPnoteDisb_P1
                   (Record_TEXT)
            VALUES ( @Lc_AddendaRecord_INDC --EFT-DET-REC-TYPE
                      + @Lc_AddendaType_CODE --EFTADD-REC-TYP-CD
                      + @Ls_EdisbCur_AddendaRecord_TEXT--EFTADD-FREEFORM-AREA
                      + @Lc_AdditionalSeq_NUMB --EFTADD-SPCL-ADD-SEQ-NBR
                      + @Lc_DetailedSeq_NUMB --EFTADD-ENTRY-DTL-SEQ-NBR --Record_TEXT
       );

       SET @Ln_PrenoteHashCount_QNTY = @Ln_PrenoteHashCount_QNTY + CAST(CAST(@Lc_EdisbCur_RoutingBank_NUMB AS CHAR(8)) AS NUMERIC);
       SET @Ls_Sql_TEXT = 'FETCH Edisb_CUR - 2';
       SET @Ls_Sqldata_TEXT = '';

       FETCH NEXT FROM Edisb_CUR INTO @Lc_EdisbCur_RecordType_CODE, @Lc_EdisbCur_Transaction_CODE, @Lc_EdisbCur_RoutingBank_NUMB, @Lc_EdisbCur_AccountBankNo_TEXT, @Lc_EdisbCur_Disburse_AMNT, @Lc_EdisbCur_Indiv_NUMB, @Lc_EdisbCur_Payee_NAME, @Ls_EdisbCur_AddendaRecord_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE Edisb_CUR;

     DEALLOCATE Edisb_CUR;

     ---For Prenote records, This credit_amt Value_AMNT always Zeros.
     SET @Ls_Sql_TEXT = 'PRENOTE CONTROL RECORD';
     SET @Ls_Sqldata_TEXT = 'PrenoteCursorLocation_QNTY = ' + CAST(@Ln_PrenoteCursorLocation_QNTY AS VARCHAR) + ', PrenoteHashCount_QNTY = ' + CAST(@Ln_PrenoteHashCount_QNTY AS VARCHAR) + ', BatchControlRecord_INDC = ' + @Lc_BatchControlRecord_INDC + ', ServClassPrenote_CODE = ' + @Lc_ServClassPrenote_CODE + ', HeaderCompany_IDNO = ' + @Lc_HeaderCompany_IDNO + ', Origin_CODE = ' + @Lc_Origin_CODE + ', OrginatingBatch_NUMB = ' + @Lc_OrginatingBatch_NUMB;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
          VALUES ( @Lc_BatchControlRecord_INDC-- EFTADD-REC-TYPE-CD
                    + @Lc_ServClassPrenote_CODE --EFTCBC-SERV-CLS-CD
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 6) + CAST(@Ln_PrenoteCursorLocation_QNTY * 2 AS VARCHAR), 6)--EFTCBC-ENTRY-ADD-CNT 
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + CAST(@Ln_PrenoteHashCount_QNTY AS VARCHAR), 10)--EFTCBC-EFTCBC-ENTRY-HASH 
                    + REPLICATE(@Lc_Zero_TEXT, 12)--EFTCBC-TOT-DEBIT-ENTRY-AMT 
                    + REPLICATE(@Lc_Zero_TEXT, 12)--EFTCBC-TOT-CREDIT-ENTRY-AMT 
                    + @Lc_HeaderCompany_IDNO--EFTCBC-COMP-ID 
                    + REPLICATE(@Lc_Space_TEXT, 19)--EFTCBC-MSG-AUTH-CD 
                    + REPLICATE(@Lc_Space_TEXT, 6)--EFTCBC-RESERVED 
                    + @Lc_Origin_CODE --EFTCBC-ORIG-DFI-ID 
                    + @Lc_OrginatingBatch_NUMB --EFTCBC-BATCH-NBR --Record_TEXT
     );
    END

   SET @Ls_Sql_TEXT = 'EFT/SVC RECORD FOR CP/NCP COUNT';
   SET @Ls_Sqldata_TEXT = 'RecordTypeCp_CODE = ' + @Lc_RecordTypeCpNcp_CODE;

   SELECT @Ln_EftCpCount_QNTY = COUNT(1)
     FROM EDISB_Y1 e
    WHERE e.RecordType_CODE IN(@Lc_RecordTypeCpNcp_CODE);

   IF @Ln_EftCpCount_QNTY > 0
    BEGIN
     SET @Ln_BatchCount_QNTY =@Ln_BatchCount_QNTY + 1;
     SET @Ls_Sql_TEXT = 'EFT SVC BATCH HEADER FOR CP/NCP';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', BatchHeader_CODE = ' + @Lc_BatchHeader_CODE + ', EftSvcServClass_CODE = ' + @Lc_EftSvcServClass_CODE + ', EftSvcCompany_NAME = ' + @Lc_EftSvcCompany_NAME + ', HeaderCompany_IDNO = ' + @Lc_HeaderCompany_IDNO + ', EntryClassCpNcp_CODE = ' + @Lc_EntryClassCpNcp_CODE + ', EftEntryDescription_TEXT = ' + @Lc_EftEntryDescription_TEXT + ', OrginatingState_CODE = ' + @Lc_OrginatingState_CODE + ', OrginatingDfi_IDNO = ' + @Lc_OrginatingDfi_IDNO + ', OrginatingBatch_NUMB = ' + @Lc_OrginatingBatch_NUMB;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
          VALUES ( @Lc_BatchHeader_CODE-- EFT-BATCH-HEADER-TYPE 
                    + @Lc_EftSvcServClass_CODE-- EFTCBH-SERV-CLS-CD 
                    + CONVERT(CHAR(16), @Lc_EftSvcCompany_NAME)----  EFTCBH-COMP-NAME            
                    + REPLICATE(@Lc_Space_TEXT, 20)-- EFTCBH-COMP-DESCRET-DATA 
                    + @Lc_HeaderCompany_IDNO--EFTCBH-COMP-ID 
                    + @Lc_EntryClassCpNcp_CODE-- EFTCBH-STD-ENTRY-CLS-CD
                    + @Lc_EftEntryDescription_TEXT-- EFTCBH-COMP-ENTRY-DESC
                    + CONVERT(VARCHAR, @Ld_Run_DATE, 12) -- EFTCBH-COMP-DESC-DT 
                    + CONVERT(VARCHAR, @Ld_Run_DATE, 12) -- EFTCBH-EFF-ENTRY -DT
                    + REPLICATE(@Lc_Space_TEXT, 3)---- EFTCBH-STTLMNT-DT 
                    + @Lc_OrginatingState_CODE-- EFTCBH-ORIG-STAT-CD 
                    + @Lc_OrginatingDfi_IDNO-- EFTCBH-ORIG-DFI-ID 
                    + @Lc_OrginatingBatch_NUMB -- EFTCBH-BATCH-NBR -- Record_TEXT
     );

     DECLARE Edisb_CUR INSENSITIVE CURSOR FOR
      SELECT e.RecordType_CODE,
             e.Transaction_CODE,
             e.RoutingBank_NUMB,
             e.AccountBankNo_TEXT,
             e.Disburse_AMNT,
             e.Individual_NUMB,
             e.Payee_NAME,
             e.AddendaRecord_TEXT
        FROM EDISB_Y1 e
       WHERE e.RecordType_CODE IN(@Lc_RecordTypeCpNcp_CODE);

     SET @Ls_Sql_TEXT = 'OPEN Edisb_CUR-2';
     SET @Ls_Sqldata_TEXT = '';

     OPEN Edisb_CUR;

     SET @Ls_Sql_TEXT = 'FETCH Edisb_CUR - 3';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Edisb_CUR INTO @Lc_EdisbCur_RecordType_CODE, @Lc_EdisbCur_Transaction_CODE, @Lc_EdisbCur_RoutingBank_NUMB, @Lc_EdisbCur_AccountBankNo_TEXT, @Lc_EdisbCur_Disburse_AMNT, @Lc_EdisbCur_Indiv_NUMB, @Lc_EdisbCur_Payee_NAME, @Ls_EdisbCur_AddendaRecord_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'WHILE -5';
     SET @Ls_Sqldata_TEXT = '';

     -- while loop for creating 	EFT SVC DETAIL RECORD FOR CP/NCP
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'EFT SVC DETAIL RECORD FOR CP/NCP';
       SET @Ls_Sqldata_TEXT = 'Transaction_CODE = ' + ISNULL(@Lc_Transaction_CODE, '') + ', RoutingBank_NUMB = ' + CAST(@Ln_RoutingBank_NUMB AS VARCHAR) + ', AccountNumber_TEXT = ' + ISNULL(@Lc_AccountNumber_TEXT, '') + ', Payee_NAME = ' + ISNULL(@Lc_Payee_NAME, '') + ', Disburse_AMNT = ' + @Lc_EdisbCur_Disburse_AMNT + ', Indiv_NUMB = ' + @Lc_EdisbCur_Indiv_NUMB + ', Record_INDC = ' + @Lc_Record_INDC + ', Trace_NUMB = ' + @Lc_Trace_NUMB;

       INSERT INTO ##ExtractPnoteDisb_P1
                   (Record_TEXT)
            VALUES ( @Lc_DetailRecord_INDC -- EFT-DET-REC-TYPE 
                      + @Lc_EdisbCur_Transaction_CODE-- EFTDTL-TRANS-CD 
                      + @Lc_EdisbCur_RoutingBank_NUMB --EFTDTL-RCVNG-DFI-CD EFTDTL-CHK-DIGIT
                      + @Lc_EdisbCur_AccountBankNo_TEXT --EFTDTL-DFI-ACCT-NBR 
                      + @Lc_EdisbCur_Disburse_AMNT --EFTDTL-AMT
                      + @Lc_EdisbCur_Indiv_NUMB --EFTDTL-INDIV-ID-NBR
                      + @Lc_EdisbCur_Payee_NAME --EFTDTL-INDIV-NAME
                      + REPLICATE(@Lc_Space_TEXT, 2) -- EFTDTL-DESCRET-DATA 
                      + @Lc_Record_INDC -- EFTDTL-ADD-REC-IND 
                      + @Lc_Trace_NUMB -- EFTDTL-TRACE-NBR -- Record_TEXT
       );

       SET @Ls_Sql_TEXT = 'RECORD_7_ADDENDA FOR CP/NCP';
       SET @Ls_Sqldata_TEXT = 'AddendaRecord_INDC = ' + @Lc_AddendaRecord_INDC + ', AddendaType_CODE = ' + @Lc_AddendaType_CODE + ', AddendaRecord_TEXT = ' + @Ls_EdisbCur_AddendaRecord_TEXT + ', AdditionalSeq_NUMB = ' + @Lc_AdditionalSeq_NUMB + ', DetailedSeq_NUMB = ' + @Lc_DetailedSeq_NUMB;

       INSERT INTO ##ExtractPnoteDisb_P1
                   (Record_TEXT)
            VALUES ( @Lc_AddendaRecord_INDC --EFT-DET-REC-TYPE
                      + @Lc_AddendaType_CODE --EFTADD-REC-TYP-CD
                      + @Ls_EdisbCur_AddendaRecord_TEXT--EFTADD-FREEFORM-AREA
                      + @Lc_AdditionalSeq_NUMB ----EFTADD-SPCL-ADD-SEQ-NBR
                      + @Lc_DetailedSeq_NUMB --EFTADD-ENTRY-DTL-SEQ-NBR --Record_TEXT
       );

       SET @Ln_EftCpNcpHashcount_QNTY= @Ln_EftCpNcpHashcount_QNTY + CAST(CAST(@Lc_EdisbCur_RoutingBank_NUMB AS CHAR(8)) AS NUMERIC);
       SET @Ls_Sql_TEXT = 'FETCH Edisb_CUR - 4';
       SET @Ls_Sqldata_TEXT = '';

       FETCH NEXT FROM Edisb_CUR INTO @Lc_EdisbCur_RecordType_CODE, @Lc_EdisbCur_Transaction_CODE, @Lc_EdisbCur_RoutingBank_NUMB, @Lc_EdisbCur_AccountBankNo_TEXT, @Lc_EdisbCur_Disburse_AMNT, @Lc_EdisbCur_Indiv_NUMB, @Lc_EdisbCur_Payee_NAME, @Ls_EdisbCur_AddendaRecord_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE Edisb_CUR;

     DEALLOCATE Edisb_CUR;

     SET @Ls_Sql_TEXT = 'SELECT_EFCD_Y1';
     SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');
     SET @Ln_CreditEntry_AMNT =0;

     SELECT @Ln_CreditEntry_AMNT = e.DirectDeposit_AMNT + e.Svc_AMNT
       FROM EFCD_Y1 e
      WHERE e.Generate_DATE = @Ld_Run_DATE;

     SET @Ls_Sql_TEXT = 'RECORD_8_EFT FOR CP/NCP';
     SET @Ls_Sqldata_TEXT ='BatchControlRecord_INDC = ' + @Lc_BatchControlRecord_INDC + ', EftSvcServClass_CODE = ' + @Lc_EftSvcServClass_CODE + ', EftCursorLocation_QNTY = ' + CAST(@Ln_EftCpCount_QNTY AS VARCHAR) + ', EftHashcount_QNTY = ' + CAST(@Ln_EftCpNcpHashcount_QNTY AS VARCHAR) + ', CreditEntry_AMNT = ' + CAST(@Ln_CreditEntry_AMNT AS VARCHAR) + ', HeaderCompany_IDNO = ' + @Lc_HeaderCompany_IDNO + ', Origin_CODE = ' + @Lc_Origin_CODE + ', OrginatingBatch_NUMB = ' + @Lc_OrginatingBatch_NUMB;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
          VALUES ( @Lc_BatchControlRecord_INDC -- EFTADD-REC-TYPE-CD
                    + @Lc_EftSvcServClass_CODE --EFTCBC-SERV-CLS-CD
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 6) + CAST(@Ln_EftCpCount_QNTY * 2 AS VARCHAR), 6) --EFTCBC-ENTRY-ADD-CNT
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + CAST(@Ln_EftCpNcpHashcount_QNTY AS VARCHAR), 10) --EFTCBC-EFTCBC-ENTRY-HASH
                    + REPLICATE(@Lc_Zero_TEXT, 12)--EFTCBC-TOT-DEBIT-ENTRY-AMT 
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 12) + CAST(CAST(@Ln_CreditEntry_AMNT * 100 AS BIGINT) AS VARCHAR), 12) ----EFTCBC-TOT-CREDIT-ENTRY-AMT 
                    + @Lc_HeaderCompany_IDNO--EFTCBC-COMP-ID 
                    + REPLICATE(@Lc_Space_TEXT, 19)--EFTCBC-MSG-AUTH-CD 
                    + REPLICATE(@Lc_Space_TEXT, 6)--EFTCBC-RESERVED 
                    + @Lc_Origin_CODE --EFTCBC-ORIG-DFI-ID 
                    + @Lc_OrginatingBatch_NUMB --EFTCBC-BATCH-NBR  --Record_TEXT
     );
    END

   SET @Ls_Sql_TEXT = 'EFT/SVC RECORD FOR FIPS/OTHP COUNT';
   SET @Ls_Sqldata_TEXT = 'RecordTypeFipsOthp_CODE = ' + @Lc_RecordTypeFipsOthp_CODE;

   SELECT @Ln_EftFipsOthpCount_QNTY = COUNT(1)
     FROM EDISB_Y1 e
    WHERE e.RecordType_CODE IN(@Lc_RecordTypeFipsOthp_CODE);

   IF @Ln_EftFipsOthpCount_QNTY > 0
    BEGIN
     SET @Ln_BatchCount_QNTY =@Ln_BatchCount_QNTY + 1;
     SET @Ls_Sql_TEXT = 'EFT SVC BATCH HEADER FOR FIPS/OTHP';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', BatchHeader_CODE = ' + @Lc_BatchHeader_CODE + ', EftSvcServClass_CODE = ' + @Lc_EftSvcServClass_CODE + ', EftSvcCompany_NAME = ' + @Lc_EftSvcCompany_NAME + ', HeaderCompany_IDNO = ' + @Lc_HeaderCompany_IDNO + ', EntryClass_CODE = ' + @Lc_EntryClassFipsOthp_CODE + ', EftEntryDescription_TEXT = ' + @Lc_EftEntryDescription_TEXT + ', OrginatingState_CODE = ' + @Lc_OrginatingState_CODE + ', OrginatingDfi_IDNO = ' + @Lc_OrginatingDfi_IDNO + ', OrginatingBatch_NUMB = ' + @Lc_OrginatingBatch_NUMB;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
          VALUES ( @Lc_BatchHeader_CODE -- EFT-BATCH-HEADER-TYPE 
                    + @Lc_EftSvcServClass_CODE -- EFTCBH-SERV-CLS-CD 
                    + CONVERT(CHAR(16), @Lc_EftSvcCompany_NAME) --  EFTCBH-COMP-NAME            
                    + REPLICATE(@Lc_Space_TEXT, 20) -- EFTCBH-COMP-DESCRET-DATA 
                    + @Lc_HeaderCompany_IDNO --EFTCBH-COMP-ID 
                    + @Lc_EntryClassFipsOthp_CODE -- EFTCBH-STD-ENTRY-CLS-CD
                    + @Lc_EftEntryDescription_TEXT -- EFTCBH-COMP-ENTRY-DESC
                    + CONVERT(VARCHAR, @Ld_Run_DATE, 12) -- EFTCBH-COMP-DESC-DT 
                    + CONVERT(VARCHAR, @Ld_Run_DATE, 12) -- EFTCBH-EFF-ENTRY -DT
                    + REPLICATE(@Lc_Space_TEXT, 3) -- EFTCBH-STTLMNT-DT 
                    + @Lc_OrginatingState_CODE -- EFTCBH-ORIG-STAT-CD 
                    + @Lc_OrginatingDfi_IDNO -- EFTCBH-ORIG-DFI-ID 
                    + @Lc_OrginatingBatch_NUMB -- EFTCBH-BATCH-NBR -- Record_TEXT
     );

     DECLARE Edisb_CUR INSENSITIVE CURSOR FOR
      SELECT e.RecordType_CODE,
             e.Transaction_CODE,
             e.RoutingBank_NUMB,
             e.AccountBankNo_TEXT,
             e.Disburse_AMNT,
             e.Individual_NUMB,
             e.Payee_NAME,
             e.AddendaRecord_TEXT
        FROM EDISB_Y1 e
       WHERE e.RecordType_CODE IN(@Lc_RecordTypeFipsOthp_CODE);

     SET @Ls_Sql_TEXT = 'OPEN Edisb_CUR-3';
     SET @Ls_Sqldata_TEXT = '';

     OPEN Edisb_CUR;

     SET @Ls_Sql_TEXT = 'FETCH Edisb_CUR - 5';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Edisb_CUR INTO @Lc_EdisbCur_RecordType_CODE, @Lc_EdisbCur_Transaction_CODE, @Lc_EdisbCur_RoutingBank_NUMB, @Lc_EdisbCur_AccountBankNo_TEXT, @Lc_EdisbCur_Disburse_AMNT, @Lc_EdisbCur_Indiv_NUMB, @Lc_EdisbCur_Payee_NAME, @Ls_EdisbCur_AddendaRecord_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'WHILE -6';
     SET @Ls_Sqldata_TEXT = '';

     -- while loop for creating FT SVC DETAIL RECORD FOR FIPS/OTHP.
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'EFT SVC DETAIL RECORD FOR FIPS/OTHP';
       SET @Ls_Sqldata_TEXT = 'Transaction_CODE = ' + ISNULL(@Lc_Transaction_CODE, '') + ', RoutingBank_NUMB = ' + CAST(@Ln_RoutingBank_NUMB AS VARCHAR) + ', AccountNumber_TEXT = ' + ISNULL(@Lc_AccountNumber_TEXT, '') + ', Payee_NAME = ' + ISNULL(@Lc_Payee_NAME, '') + ', Disburse_AMNT = ' + @Lc_EdisbCur_Disburse_AMNT + ', Indiv_NUMB = ' + @Lc_EdisbCur_Indiv_NUMB + ', Record_INDC = ' + @Lc_Record_INDC + ', Trace_NUMB = ' + @Lc_Trace_NUMB;

       INSERT INTO ##ExtractPnoteDisb_P1
                   (Record_TEXT)
            VALUES ( @Lc_DetailRecord_INDC -- EFT-DET-REC-TYPE 
                      + @Lc_EdisbCur_Transaction_CODE-- EFTDTL-TRANS-CD 
                      + @Lc_EdisbCur_RoutingBank_NUMB --EFTDTL-RCVNG-DFI-CD EFTDTL-CHK-DIGIT
                      + @Lc_EdisbCur_AccountBankNo_TEXT --EFTDTL-DFI-ACCT-NBR 
                      + @Lc_EdisbCur_Disburse_AMNT --EFTDTL-AMT
                      + @Lc_EdisbCur_Indiv_NUMB --EFTDTL-INDIV-ID-NBR
                      + @Lc_EdisbCur_Payee_NAME --EFTDTL-INDIV-NAME
                      + REPLICATE(@Lc_Space_TEXT, 2) -- EFTDTL-DESCRET-DATA 
                      + @Lc_Record_INDC -- EFTDTL-ADD-REC-IND 
                      + @Lc_Trace_NUMB -- EFTDTL-TRACE-NBR -- Record_TEXT
       );

       SET @Ls_Sql_TEXT = 'RECORD_7_ADDENDA FOR FIPS/OTHP';
       SET @Ls_Sqldata_TEXT = 'AddendaRecord_INDC = ' + @Lc_AddendaRecord_INDC + ', AddendaType_CODE = ' + @Lc_AddendaType_CODE + ', AddendaRecord_TEXT = ' + @Ls_EdisbCur_AddendaRecord_TEXT + ', AdditionalSeq_NUMB = ' + @Lc_AdditionalSeq_NUMB + ', DetailedSeq_NUMB = ' + @Lc_DetailedSeq_NUMB;

       INSERT INTO ##ExtractPnoteDisb_P1
                   (Record_TEXT)
            VALUES ( @Lc_AddendaRecord_INDC --EFT-DET-REC-TYPE
                      + @Lc_AddendaType_CODE --EFTADD-REC-TYP-CD
                      + @Ls_EdisbCur_AddendaRecord_TEXT--EFTADD-FREEFORM-AREA
                      + @Lc_AdditionalSeq_NUMB ----EFTADD-SPCL-ADD-SEQ-NBR
                      + @Lc_DetailedSeq_NUMB ); --EFTADD-ENTRY-DTL-SEQ-NBR --Record_TEXT

       SET @Ln_EftFipsOthpHashcount_QNTY = @Ln_EftFipsOthpHashcount_QNTY + CAST(CAST(@Lc_EdisbCur_RoutingBank_NUMB AS CHAR(8)) AS NUMERIC);
       SET @Ls_Sql_TEXT = 'FETCH Edisb_CUR - 6';
       SET @Ls_Sqldata_TEXT = '';

       FETCH NEXT FROM Edisb_CUR INTO @Lc_EdisbCur_RecordType_CODE, @Lc_EdisbCur_Transaction_CODE, @Lc_EdisbCur_RoutingBank_NUMB, @Lc_EdisbCur_AccountBankNo_TEXT, @Lc_EdisbCur_Disburse_AMNT, @Lc_EdisbCur_Indiv_NUMB, @Lc_EdisbCur_Payee_NAME, @Ls_EdisbCur_AddendaRecord_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE Edisb_CUR;

     DEALLOCATE Edisb_CUR;

     SET @Ls_Sql_TEXT = 'SELECT_EFCD_Y1 -2';
     SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');
     SET @Ln_CreditEntry_AMNT =0;

     SELECT @Ln_CreditEntry_AMNT = e.Agency_AMNT - @Ln_CreditEntryIva_AMNT
       FROM EFCD_Y1 e
      WHERE e.Generate_DATE = @Ld_Run_DATE;

     SET @Ls_Sql_TEXT = 'RECORD_8_EFT FOR FIPS/OTHP';
     SET @Ls_Sqldata_TEXT ='BatchControlRecord_INDC = ' + @Lc_BatchControlRecord_INDC + ', EftSvcServClass_CODE = ' + @Lc_EftSvcServClass_CODE + ', EftCursorLocation_QNTY = ' + CAST(@Ln_EftFipsOthpCount_QNTY AS VARCHAR) + ', EftHashcount_QNTY = ' + CAST(@Ln_EftFipsOthpHashcount_QNTY AS VARCHAR) + ', CreditEntry_AMNT = ' + CAST(@Ln_CreditEntry_AMNT AS VARCHAR) + ', HeaderCompany_IDNO = ' + @Lc_HeaderCompany_IDNO + ', Origin_CODE = ' + @Lc_Origin_CODE + ', OrginatingBatch_NUMB = ' + @Lc_OrginatingBatch_NUMB;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
          VALUES ( @Lc_BatchControlRecord_INDC -- EFTADD-REC-TYPE-CD
                    + @Lc_EftSvcServClass_CODE --EFTCBC-SERV-CLS-CD
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 6) + CAST(@Ln_EftFipsOthpCount_QNTY * 2 AS VARCHAR), 6) --EFTCBC-ENTRY-ADD-CNT
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + CAST(@Ln_EftFipsOthpHashcount_QNTY AS VARCHAR), 10) --EFTCBC-EFTCBC-ENTRY-HASH
                    + REPLICATE(@Lc_Zero_TEXT, 12)--EFTCBC-TOT-DEBIT-ENTRY-AMT 
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 12) + CAST(CAST(@Ln_CreditEntry_AMNT * 100 AS BIGINT) AS VARCHAR), 12) ----EFTCBC-TOT-CREDIT-ENTRY-AMT 
                    + @Lc_HeaderCompany_IDNO--EFTCBC-COMP-ID 
                    + REPLICATE(@Lc_Space_TEXT, 19)--EFTCBC-MSG-AUTH-CD 
                    + REPLICATE(@Lc_Space_TEXT, 6)--EFTCBC-RESERVED 
                    + @Lc_Origin_CODE --EFTCBC-ORIG-DFI-ID 
                    + @Lc_OrginatingBatch_NUMB --EFTCBC-BATCH-NBR--Record_TEXT
     );
    END

   SET @Ls_Sql_TEXT = 'EFT RECORD FOR IVA COUNT';
   SET @Ls_Sqldata_TEXT = 'RecordTypeIva_CODE = ' + @Lc_RecordTypeIva_CODE;

   SELECT @Ln_EftIvaCount_QNTY = COUNT(1)
     FROM EDISB_Y1 e
    WHERE e.RecordType_CODE = @Lc_RecordTypeIva_CODE;

   IF @Ln_EftIvaCount_QNTY > 0
    BEGIN
     SET @Ln_BatchCount_QNTY =@Ln_BatchCount_QNTY + 1;
     SET @Ls_Sql_TEXT = 'EFT  BATCH HEADER FOR IVA';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', BatchHeader_CODE = ' + @Lc_BatchHeader_CODE + ', EftSvcServClass_CODE = ' + @Lc_EftSvcServClass_CODE + ', EftSvcCompany_NAME = ' + @Lc_EftSvcCompany_NAME + ', HeaderCompany_IDNO = ' + @Lc_HeaderCompany_IDNO + ', EntryClass_CODE = ' + @Lc_EntryClassFipsOthp_CODE + ', EftEntryDescription_TEXT = ' + @Lc_EftEntryDescription_TEXT + ', OrginatingState_CODE = ' + @Lc_OrginatingState_CODE + ', OrginatingDfi_IDNO = ' + @Lc_OrginatingDfi_IDNO + ', OrginatingBatch_NUMB = ' + @Lc_OrginatingBatch_NUMB;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
          VALUES ( @Lc_BatchHeader_CODE -- EFT-BATCH-HEADER-TYPE 
                    + @Lc_EftSvcServClass_CODE -- EFTCBH-SERV-CLS-CD 
                    + CONVERT(CHAR(16), @Lc_EftSvcCompany_NAME) --  EFTCBH-COMP-NAME            
                    + REPLICATE(@Lc_Space_TEXT, 20) -- EFTCBH-COMP-DESCRET-DATA 
                    + @Lc_HeaderCompany_IDNO --EFTCBH-COMP-ID 
                    + @Lc_EntryClassFipsOthp_CODE -- EFTCBH-STD-ENTRY-CLS-CD
                    + @Lc_EftEntryDescription_TEXT -- EFTCBH-COMP-ENTRY-DESC
                    + CONVERT(VARCHAR, @Ld_Run_DATE, 12) -- EFTCBH-COMP-DESC-DT 
                    + CONVERT(VARCHAR, @Ld_Run_DATE, 12) -- EFTCBH-EFF-ENTRY -DT
                    + REPLICATE(@Lc_Space_TEXT, 3) -- EFTCBH-STTLMNT-DT 
                    + @Lc_OrginatingState_CODE -- EFTCBH-ORIG-STAT-CD 
                    + @Lc_OrginatingDfi_IDNO -- EFTCBH-ORIG-DFI-ID 
                    + @Lc_OrginatingBatch_NUMB -- EFTCBH-BATCH-NBR -- Record_TEXT
     );

     SET @Ls_Sql_TEXT = 'EFT DETAIL RECORD FOR IVA';
     SET @Ls_Sqldata_TEXT = 'DetailRecord_INDC = ' + @Lc_DetailRecord_INDC + ', Record_INDC = ' + @Lc_Record_INDC + ', Trace_NUMB = ' + @Lc_Trace_NUMB + ', @Lc_Space_TEXT = ' + @Lc_Space_TEXT + ', RecordTypeIva_CODE = ' + @Lc_RecordTypeIva_CODE;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
     SELECT @Lc_DetailRecord_INDC -- EFT-DET-REC-TYPE
             + e.Transaction_CODE-- EFTDTL-TRANS-CD 
             + e.RoutingBank_NUMB --EFTDTL-RCVNG-DFI-CD EFTDTL-CHK-DIGIT
             + e.AccountBankNo_TEXT --EFTDTL-DFI-ACCT-NBR 
             + e.Disburse_AMNT --EFTDTL-AMT
             + e.Individual_NUMB --EFTDTL-INDIV-ID-NBR
             + e.Payee_NAME --EFTDTL-INDIV-NAME
             + REPLICATE(@Lc_Space_TEXT, 2) -- EFTDTL-DESCRET-DATA 
             + @Lc_Record_INDC -- EFTDTL-ADD-REC-IND 
             + @Lc_Trace_NUMB  AS Record_TEXT  -- EFTDTL-TRACE-NBR -- Record_TEXT
       FROM EDISB_Y1 e
      WHERE e.RecordType_CODE = @Lc_RecordTypeIva_CODE;

     SET @Ls_Sql_TEXT = 'EFT HASH COUNT FOR IVA';
     SET @Ls_Sqldata_TEXT = ' EftIvaHashcount_QNTY' + CAST(@Ln_EftIvaHashcount_QNTY AS VARCHAR) + ', RecordTypeIva_CODE = ' + @Lc_RecordTypeIva_CODE;

     SELECT @Ln_EftIvaHashcount_QNTY = @Ln_EftIvaHashcount_QNTY + CAST(CAST(RoutingBank_NUMB AS CHAR(8)) AS NUMERIC)
       FROM EDISB_Y1 e
      WHERE e.RecordType_CODE = @Lc_RecordTypeIva_CODE;

     SET @Ls_Sql_TEXT = 'RECORD_8_EFT FOR IVA';
     SET @Ls_Sqldata_TEXT ='BatchControlRecord_INDC = ' + @Lc_BatchControlRecord_INDC + ', EftSvcServClass_CODE = ' + @Lc_EftSvcServClass_CODE + ', EftIvaCount_QNTY = ' + CAST(@Ln_EftIvaCount_QNTY AS VARCHAR) + ', EftHashcount_QNTY = ' + CAST(@Ln_EftIvaHashcount_QNTY AS VARCHAR) + ', CreditEntry_AMNT = ' + CAST(@Ln_CreditEntry_AMNT AS VARCHAR) + ', HeaderCompany_IDNO = ' + @Lc_HeaderCompany_IDNO + ', Origin_CODE = ' + @Lc_Origin_CODE + ', OrginatingBatch_NUMB = ' + @Lc_OrginatingBatch_NUMB;

     INSERT INTO ##ExtractPnoteDisb_P1
                 (Record_TEXT)
          VALUES ( @Lc_BatchControlRecord_INDC -- EFTADD-REC-TYPE-CD
                    + @Lc_EftSvcServClass_CODE --EFTCBC-SERV-CLS-CD
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 6) + CAST(@Ln_EftIvaCount_QNTY AS VARCHAR), 6) --EFTCBC-ENTRY-ADD-CNT
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + CAST(@Ln_EftIvaHashcount_QNTY AS VARCHAR), 10) --EFTCBC-EFTCBC-ENTRY-HASH
                    + REPLICATE(@Lc_Zero_TEXT, 12)--EFTCBC-TOT-DEBIT-ENTRY-AMT 
                    + RIGHT(REPLICATE(@Lc_Zero_TEXT, 12) + CAST(CAST(@Ln_CreditEntryIva_AMNT * 100 AS BIGINT) AS VARCHAR), 12) ----EFTCBC-TOT-CREDIT-ENTRY-AMT 
                    + @Lc_HeaderCompany_IDNO--EFTCBC-COMP-ID 
                    + REPLICATE(@Lc_Space_TEXT, 19)--EFTCBC-MSG-AUTH-CD 
                    + REPLICATE(@Lc_Space_TEXT, 6)--EFTCBC-RESERVED 
                    + @Lc_Origin_CODE --EFTCBC-ORIG-DFI-ID 
                    + @Lc_OrginatingBatch_NUMB --EFTCBC-BATCH-NBR--Record_TEXT
     );
    END

   --NUMBER OF PHYSICAL BLOCKS IN THE FILE, INCLUDING FILE HEADER AND FILE CONTROL RECORDS
   SET @Lc_BlockCount_TEXT = CAST(CEILING((@Ln_PrenoteCursorLocation_QNTY * 2 + @Ln_EftCpCount_QNTY * 2 + @Ln_EftFipsOthpCount_QNTY * 2 + @Ln_EftIvaCount_QNTY + @Ln_BatchCount_QNTY * 2 + 1) / 10) AS VARCHAR);
   SET @Ls_Sql_TEXT = 'SELECT_EFCD_Y1';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');
   SET @Ln_CreditEntry_AMNT =0;

   SELECT @Ln_CreditEntry_AMNT = e.DirectDeposit_AMNT + e.Svc_AMNT + e.Agency_AMNT
     FROM EFCD_Y1 e
    WHERE e.Generate_DATE = @Ld_Run_DATE;

   SET @Ls_Sql_TEXT = 'SUMMARY_RECORD';
   SET @Ls_Sqldata_TEXT = 'FileControlRecord_INDC = ' + @Lc_FileControlRecord_INDC + ', BatchCount_QNTY = ' + CAST(@Ln_BatchCount_QNTY AS VARCHAR) + ', BlockCount_TEXT = ' + @Lc_BlockCount_TEXT + ', PrenoteCursorLocation_QNTY = ' + CAST(@Ln_PrenoteCursorLocation_QNTY AS VARCHAR) + ', EftCpCount_QNTY = ' + CAST(@Ln_EftCpCount_QNTY AS VARCHAR) + ', EftFipsOthpHashcount_QNTY = ' + CAST(@Ln_EftFipsOthpHashcount_QNTY AS VARCHAR) + ', EftCpNcpHashcount_QNTY = ' + CAST(@Ln_EftCpNcpHashcount_QNTY AS VARCHAR) + ', EftFipsOthpCount_QNTY = ' + CAST(@Ln_EftFipsOthpCount_QNTY AS VARCHAR) + ', PrenoteHashCount_QNTY = ' + CAST(@Ln_PrenoteHashCount_QNTY AS VARCHAR) + ', CreditEntry_AMNT = ' + CAST(@Ln_CreditEntry_AMNT AS VARCHAR);

   INSERT INTO ##ExtractPnoteDisb_P1
               (Record_TEXT)
        VALUES ( @Lc_FileControlRecord_INDC --EFTADD-REC-TYP-CD
                  + RIGHT(REPLICATE(@Lc_Zero_TEXT, 6) + CAST(@Ln_BatchCount_QNTY AS VARCHAR), 6) --EFTFIC-BATCH-CNT
                  + RIGHT(REPLICATE(@Lc_Zero_TEXT, 6) + LTRIM(RTRIM(LTRIM(RTRIM(@Lc_BlockCount_TEXT)))), 6) --EFTFIC-BLK-CNT
                  + RIGHT(REPLICATE(@Lc_Zero_TEXT, 8) + CAST(@Ln_PrenoteCursorLocation_QNTY * 2 + @Ln_EftCpCount_QNTY * 2 + @Ln_EftFipsOthpCount_QNTY * 2 + @Ln_EftIvaCount_QNTY AS VARCHAR), 8)--EFTFIC-ENTRY-ADD-CNT
                  + RIGHT(REPLICATE(@Lc_Zero_TEXT, 10) + CAST(@Ln_EftFipsOthpHashcount_QNTY + @Ln_EftCpNcpHashcount_QNTY + @Ln_PrenoteHashCount_QNTY + @Ln_EftIvaHashcount_QNTY AS VARCHAR), 10) --EFTFIC-ENTRY-HASH NBR
                  + REPLICATE(@Lc_Zero_TEXT, 12) --EFTFIC-TOT-FL-DEBIT-ENTRY-AMT
                  + RIGHT(REPLICATE(@Lc_Zero_TEXT, 12) + CAST(CAST(@Ln_CreditEntry_AMNT * 100 AS BIGINT) AS VARCHAR), 12)--EFTFIC-TOT-FL-CREDIT-ENTRY-AMT
                  + REPLICATE(@Lc_Space_TEXT, 39)--EFTFIC-RESERVED --Record_TEXT
   );

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractPnoteDisb_P1 ORDER BY Seq_IDNO';
   SET @Ls_Sql_TEXT = 'Extract Data';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_File_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;

   
   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   /*
   	Update the last run date in the PARM_Y1 table with the current run date, upon successful completion
   */
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ln_ProcessedRecordCount_QNTY= @Ln_PrenoteCursorLocation_QNTY + @Ln_EftCursorLocation_QNTY;
   SET @Ls_Sql_TEXT = 'JOB RUN SUCCESS';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   DROP TABLE ##ExtractPnoteDisb_P1;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PNOTE;
    END;

   IF CURSOR_STATUS ('LOCAL', 'Prenote_CUR') IN (0, 1)
    BEGIN
     CLOSE Prenote_CUR;

     DEALLOCATE Prenote_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'Dsbl_CUR') IN (0, 1)
    BEGIN
     CLOSE Dsbl_CUR;

     DEALLOCATE Dsbl_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'Edisb_CUR') IN (0, 1)
    BEGIN
     CLOSE Edisb_CUR;

     DEALLOCATE Edisb_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'Dsbh_CUR') IN (0, 1)
    BEGIN
     CLOSE Dsbh_CUR;

     DEALLOCATE Dsbh_CUR;
    END

   --Check if temporary table exists drop the table
   IF OBJECT_ID('tempdb..##ExtractPnoteDisb_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractPnoteDisb_P1;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @ls_sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
