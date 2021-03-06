/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_EXTRACT_CSENET]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_EXTRACT_CSENET
Programmer Name	:	IMP Team.
Description		:	This process loads all data blocks in extract tables FOR each row of pending_request table
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_CASE
					BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_NCP_LOCATE
				    BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_PART
				    BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_ORDER
				    BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_COLLECTION
				    BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_TYPE_VALIDATION
				    BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_VALIDATE
				    BATCH_CI_OUTGOING_CSENET_FILE$SP_EXT_CSENET_TEXT
				    BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INSERT_ALERT
				    BATCH_COMMON$SP_GET_BATCH_DETAILS2
				    BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
				    BATCH_COMMON$SP_UPDATE_PARM_DATE
				    BATCH_COMMON$SP_MEMBER_CLEARENCE
				    BATCH_COMMON$SF_GET_VERIFIED_SSN_ITIN
				    BATCH_COMMON$SP_INSERT_ACTIVITY
				    BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
				    BATCH_COMMON$SP_BATE_LOG
				    BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_EXTRACT_CSENET]
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  --Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Lc_ExchangeModePaper_TEXT         CHAR(1) = 'P',
          @Lc_ExchangeModeCsenet_TEXT        CHAR(1) = 'C',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Lc_ActionProvide_CODE             CHAR(1) = 'P',
          @Lc_ErrorTypeError_CODE            CHAR(1) = 'E',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_RelationshipCaseNcp_TEXT       CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT CHAR(1) = 'P',
          @Lc_StatusCaseMemberActive_CODE    CHAR(1) = 'A',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_StatusChange_CODE              CHAR(1) = ' ',
          @Lc_IoDirection_CODE               CHAR(1) = 'O',
          @Lc_CaseStatusClosed_CODE          CHAR(1) = 'C',
          @Lc_Action_CODE                    CHAR(1) = ' ',
          @Lc_SntToStHost_CODE               CHAR(1) = ' ',
          @Lc_ProcComplete_CODE              CHAR(1) = ' ',
          @Lc_InterstateFrmsPrint_CODE       CHAR(1) = ' ',
          @Lc_Overdue_CODE                   CHAR(1) = ' ',
          @Lc_MemberSex_CODE                 CHAR(1) = ' ',
          @Lc_MemberSsn_INDC                 CHAR(1) = 'N',
          @Lc_BirthDate_INDC                 CHAR(1) = 'N',
          @Lc_Gender_CODE                    CHAR(1) = ' ',
          @Lc_Race_CODE                      CHAR(1) = ' ',
          @Lc_PossiblyDangerous_CODE         CHAR(1) = ' ',
          @Lc_SuccessStatusLoad_CODE         CHAR(2) = 'LS',
          @Lc_StatusValidationSuccess_CODE   CHAR(2) = 'VS',
          @Lc_ReqStatusPending_CODE          CHAR(2) = 'PN',
          @Lc_ReqStatusBatchError_CODE       CHAR(2) = 'BE',
          @Lc_RecdetOtherState_CODE          CHAR(2) = 'OS',
          @Lc_ReqStatusSuccessSent_CODE      CHAR(2) = 'SS',
          @Lc_StateInState_CODE              CHAR(2) = 'DE',
          @Lc_ReqStatusValiSuccess_CODE      CHAR(2) = 'VS',
          @Lc_StateFips_CODE                 CHAR(2) = '10',
          @Lc_IVDOutOfStateFips_CODE         CHAR(2) = ' ',
          @Lc_IVDOutOfStateOfficeFips_CODE   CHAR(2) = ' ',
          @Lc_ErrorReason_CODE               CHAR(2) = ' ',
          @Lc_InHeight_TEXT                  CHAR(2) = ' ',
          @Lc_PossiblyDangerousHv_CODE       CHAR(2) = 'HV',
          @Lc_CaseInitiation_TEXT            CHAR(2) = 'CI',
          @Lc_OfficeDE_CODE                  CHAR(2) = '00',
          @Lc_CsenetVersion_ID               CHAR(3) = '003',
          @Lc_FunctionManagestcases_CODE     CHAR(3) = 'MSC',
          @Lc_FunctionCasesummary_CODE       CHAR(3) = 'CSI',
          @Lc_FunctionQuickLocate_CODE       CHAR(3) = 'LO1',
          @Lc_FunctionPaternity_CODE         CHAR(3) = 'PAT',
          @Lc_CountyFips_CODE                CHAR(3) = ' ',
          @Lc_IVDOutOfStateCountyFips_CODE   CHAR(3) = ' ',
          @Lc_Function_CODE                  CHAR(3) = ' ',
          @Lc_FtHeight_TEXT                  CHAR(3) = ' ',
          @Lc_DescriptionWeightLbs_TEXT      CHAR(3) = ' ',
          @Lc_ColorHair_CODE                 CHAR(3) = ' ',
          @Lc_ColorEyes_CODE                 CHAR(3) = ' ',
          @Lc_MajorActivityCase_CODE         CHAR(4) = 'CASE',
          @Lc_Suffix_NAME                    CHAR(4) = ' ',
          @Lc_Error_CODE                     CHAR(5) = ' ',
          @Lc_FarUnprocessed_CODE            CHAR(5) = 'REJCT',
          @Lc_ReasonPichs_CODE               CHAR(5) = 'PICHS',
          @Lc_ReasonGiher_CODE               CHAR(5) = 'GIHER',
          @Lc_ReasonSichs_CODE               CHAR(5) = 'SICHS',
          @Lc_ErrorNoDataFound_TEXT          CHAR(5) = 'E0058',
          @Lc_UpdateFailed_TEXT              CHAR(5) = 'E0001',
          @Lc_Reason_CODE                    CHAR(5) = ' ',
          @Lc_RejectReason_CODE              CHAR(5) = ' ',
          @Lc_ReasonFuinf_CODE               CHAR(5) = 'FUINF',
          @Lc_ReasonLuall_CODE               CHAR(5) = 'LUALL',
          @Lc_ReasonLuapd_CODE               CHAR(5) = 'LUAPD',
          @Lc_ReasonFsinf_CODE               CHAR(5) = 'FSINF',
          @Lc_ReasonGscas_CODE               CHAR(5) = 'GSCAS',
          @Lc_ReasonPipns_CODE               CHAR(5) = 'PIPNS',
          @Lc_ReasonLsadr_CODE               CHAR(5) = 'LSADR',
          @Lc_ReasonLsout_CODE               CHAR(5) = 'LSOUT',
          @Lc_ReasonLsall_CODE               CHAR(5) = 'LSALL',
          @Lc_ReasonLsemp_CODE               CHAR(5) = 'LSEMP',
          @Lc_ReasonLicad_CODE               CHAR(5) = 'LICAD',
          @Lc_ReasonLicem_CODE               CHAR(5) = 'LICEM',
          @Lc_ReasonLsoth_CODE               CHAR(5) = 'LSOTH',
          @Lc_MinorActivityCsnet_CODE        CHAR(5) = 'CSNET',
          @Lc_BatchRunUser_TEXT              CHAR(5) = 'BATCH',
          @Lc_BateError_CODE                 CHAR(5) = ' ',
          @Lc_Job_ID                         CHAR(7) = 'DEB0740',
          @Lc_Message_ID                     CHAR(11) = ' ',
          @Lc_CsenetTran_ID                  CHAR(12) = ' ',
          @Lc_CaseNew_ID                     CHAR(15) = ' ',
          @Lc_IVDOutOfStateCase_ID           CHAR(15) = ' ',
          @Lc_PlaceOfBirth_TEXT              CHAR(15) = ' ',
          @Lc_First_NAME                     CHAR(16) = ' ',
          @Lc_Last_NAME                      CHAR(20) = ' ',
          @Lc_Middle_NAME                    CHAR(20) = ' ',
          @Lc_DistinguishingMarks_TEXT       CHAR(20) = ' ',
          @Lc_FatherOrMomMaiden_NAME         CHAR(21) = ' ',
          @Ls_BatchSuccess_INDC              VARCHAR(50) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT           VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_EXTRACT_CSENET',
          @Ls_Process_NAME                   VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE',
          @Ls_Xml_TEXT                       VARCHAR(100) = ' ',
          @Ls_BateRecord_TEXT                VARCHAR(4000) = ' ',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_AttachDue_DATE                 DATE = '01/01/0001',
          @Ld_TimeSent_DATE                  DATE = '01/01/0001',
          @Ld_Due_DATE                       DATE = '01/01/0001',
          @Ld_Response_DATE                  DATE = '01/01/0001',
          @Ld_ActionResolution_DATE          DATE = '01/01/0001',
          @Ld_Birth_DATE                     DATE = '01/01/0001',
          @Ld_Received_DTTM                  DATE = '01/01/0001',
          @Lb_SkipTran_BIT                   BIT = 1;
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(6) = 0,
          @Ln_Case_IDNO                   NUMERIC(6) = 0,
          @Ln_MemberSsn_NUMB              NUMERIC(9) = 0,
          @Ln_MemberMci_IDNO              NUMERIC(10) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_NoticeCount_NUMB            NUMERIC(10),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransHeader_IDNO            NUMERIC(12) = 0,
          @Ln_Transaction_IDNO            NUMERIC(12) = 0,
          @Ln_Barcode_NUMB                NUMERIC(12),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19),
          @Li_RecordCount_QNTY            INT = 0,
          @Li_NextTranPointer_NUMB        INT = 0,
          @Li_CaseData_QNTY               SMALLINT = 0,
          @Li_Ncp_QNTY                    SMALLINT = 0,
          @Li_NcpLoc_QNTY                 SMALLINT = 0,
          @Li_Participant_QNTY            SMALLINT = 0,
          @Li_Order_QNTY                  SMALLINT = 0,
          @Li_Collection_QNTY             SMALLINT = 0,
          @Li_Info_QNTY                   SMALLINT = 0,
          @Li_FetchStatus_NUMB            SMALLINT,
          @Li_Rowcount_QNTY               SMALLINT,
          @Li_FetchNoticeStatus_NUMB      SMALLINT,
          @Lc_Papersuccess_INDC           CHAR(1),
          @Lc_Attachments_INDC            CHAR(1),
          @Lc_MemberAddFound_TEXT         CHAR(1),
          @Lc_MemberAddVerified_TEXT      CHAR(1),
          @Lc_MemberEmpFound_TEXT         CHAR(1),
          @Lc_MemberEmpVerified_TEXT      CHAR(1),
          @Lc_MemberDeceased_TEXT         CHAR(1),
          @Lc_SsnMatch_CODE               CHAR(1),
          @Lc_NameMatch_INDC              CHAR(1),
          @Lc_ExactMatch_INDC             CHAR(1),
          @Lc_MultMatch_INDC              CHAR(1),
          @Lc_ResidentialState_ADDR       CHAR(2),
          @Lc_Msg_CODE                    CHAR(5),
          @Lc_Fips_CODE                   CHAR(7),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Information_TEXT            VARCHAR(400),
          @Ls_CursorLoc_TEXT              VARCHAR(1000) = '',
          @Ls_DescriptionComments_TEXT    VARCHAR(1000),
          @Ls_Sql_TEXT                    VARCHAR(4000),
          @Ls_Sqldata_TEXT                VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ls_BcpCommand_TEXT             VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_Deceased_DATE               DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Lb_RowsFoundToday_BIT          BIT;
  --Cursor Variable Naming:
  DECLARE @Lc_PendReqCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_PendReqCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_PendReqCur_IVDOutOfStateCase_ID         CHAR(15),
          @Lc_PendReqCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Ln_PendReqCur_Case_IDNO                    NUMERIC(6),
          @Lc_PendReqCur_Function_CODE                CHAR(3),
          @Lc_PendReqCur_Action_CODE                  CHAR(1),
          @Lc_PendReqCur_Reason_CODE                  CHAR(5),
          @Ln_PendReqCur_Request_IDNO                 NUMERIC(9),
          @Ld_PendReqCur_Generated_DATE               DATE,
          @Ln_PendReqCur_TransactionEvent_NUMB        NUMERIC(12);
  DECLARE @Ln_PaperTranCur_Request_IDNO                 NUMERIC(9),
          @Ln_PaperTranCur_Case_IDNO                    NUMERIC(6),
          @Lc_PaperTranCur_Notice_ID                    CHAR(8),
          @Ln_PaperTranCur_RespondentMci_IDNO           NUMERIC(10),
          @Lc_PaperTranCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_PaperTranCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_PaperTranCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_PaperTranCur_IVDOutOfStateCase_ID         CHAR(15),
          @Lc_PaperTranCur_Function_CODE                CHAR(3),
          @Lc_PaperTranCur_Action_CODE                  CHAR(1),
          @Lc_PaperTranCur_Reason_CODE                  CHAR(5),
          @Lc_PaperTranCur_CaseFormer_ID                CHAR(6),
          @Lc_PaperTranCur_Attachment_INDC              CHAR(1),
          @Ld_PaperTranCur_Generated_DATE               DATE,
          @Lc_PaperTranCur_OldCsenetTrans_IDNO          CHAR(12);
  DECLARE @Ln_CsenetTranCur_Request_IDNO                 NUMERIC(9),
          @Ln_CsenetTranCur_Case_IDNO                    NUMERIC(6),
          @Lc_CsenetTranCur_IVDOutOfStateFips_CODE       CHAR(2),
          @Lc_CsenetTranCur_IVDOutOfStateCountyFips_CODE CHAR(3),
          @Lc_CsenetTranCur_IVDOutOfStateOfficeFips_CODE CHAR(2),
          @Lc_CsenetTranCur_IVDOutOfStateCase_ID         CHAR(15),
          @Lc_CsenetTranCur_Function_CODE                CHAR(3),
          @Lc_CsenetTranCur_Action_CODE                  CHAR(1),
          @Lc_CsenetTranCur_Reason_CODE                  CHAR(5),
          @Lc_CsenetTranCur_CaseFormer_ID                CHAR(6),
          @Lc_CsenetTranCur_Attachment_INDC              CHAR(1),
          @Ld_CsenetTranCur_Generated_DATE               DATE,
          @Lc_CsenetTranCur_OldCsenetTrans_IDNO          CHAR(12),
          @Ls_CsenetTranCur_DescriptionComments_TEXT     VARCHAR(1000),
          @Ld_CsenetTranCur_PfNoShow_DATE                DATE,
          @Ld_CsenetTranCur_Hearing_DATE                 DATE;

  BEGIN TRY
   --Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   -- Begin the transaction to extract data
   BEGIN TRANSACTION CSENET_EXT;

   -- Get date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR(50001,16,1);
    END;

   -- Before start 'out going process' delete the extract tables data
   SET @Ls_Sql_TEXT = 'DELETE ETHBL_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM ETHBL_Y1;

   SET @Ls_Sql_TEXT = 'DELETE ECDBL_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM ECDBL_Y1;

   SET @Ls_Sql_TEXT = 'DELETE ENBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM ENBLK_Y1;

   SET @Ls_Sql_TEXT = 'DELETE ENLBL_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM ENLBL_Y1;

   SET @Ls_Sql_TEXT = 'DELETE EPBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM EPBLK_Y1;

   SET @Ls_Sql_TEXT = 'DELETE EOBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM EOBLK_Y1;

   SET @Ls_Sql_TEXT = 'DELETE ECBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM ECBLK_Y1;

   SET @Ls_Sql_TEXT = 'DELETE EIBLK_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM EIBLK_Y1;

   -- If no rows found for pd_dt_run
   SET @Lb_RowsFoundToday_BIT = 0;

   --UPDATE CSPR FOR TRANSACTIONS
   IF EXISTS (SELECT 1
                FROM CSPR_Y1 b
               WHERE b.EndValidity_DATE = @Ld_High_DATE
                 AND b.StatusRequest_CODE = @Lc_ReqStatusPending_CODE
                 AND EXISTS (SELECT 1
                               FROM ICAS_Y1 a
                              WHERE a.Case_IDNO = b.Case_IDNO
                                AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                                AND a.EndValidity_DATE = b.EndValidity_DATE
                                AND a.Status_CODE = @Lc_CaseStatusOpen_CODE))
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT - 1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '');

     EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     -- Update (Logical delete and insert) CSPR with StartDate and Updated User information
     SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1';
     SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_PendReqCur_Request_IDNO AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_PendReqCur_TransactionEvent_NUMB AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     UPDATE b
        SET BeginValidity_DATE = @Ld_Start_DATE,
            EndValidity_DATE = @Ld_High_DATE,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            Update_DTTM = @Ld_Start_DATE,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB
     OUTPUT deleted.Generated_DATE,
            deleted.Case_IDNO,
            deleted.IVDOutOfStateFips_CODE,
            deleted.IVDOutOfStateCountyFips_CODE,
            deleted.IVDOutOfStateOfficeFips_CODE,
            deleted.IVDOutOfStateCase_ID,
            deleted.ExchangeMode_INDC,
            deleted.StatusRequest_CODE,
            deleted.Form_ID,
            deleted.FormWeb_URL,
            deleted.TransHeader_IDNO,
            deleted.Function_CODE,
            deleted.Action_CODE,
            deleted.Reason_CODE,
            deleted.DescriptionComments_TEXT,
            deleted.CaseFormer_ID,
            deleted.InsCarrier_NAME,
            deleted.InsPolicyNo_TEXT,
            deleted.Hearing_DATE,
            deleted.Dismissal_DATE,
            deleted.GeneticTest_DATE,
            deleted.Attachment_INDC,
            deleted.BeginValidity_DATE,
            @Ld_Start_DATE AS EndValidity_DATE,
            deleted.WorkerUpdate_ID,
            deleted.Update_DTTM,
            deleted.TransactionEventSeq_NUMB,
            deleted.File_ID,
            deleted.PfNoShow_DATE,
            deleted.RespondentMci_IDNO,
            deleted.ArrearComputed_DATE,
            deleted.TotalInterestOwed_AMNT,
            deleted.TotalArrearsOwed_AMNT
     INTO CSPR_Y1
       FROM CSPR_Y1 b
      WHERE b.EndValidity_DATE = @Ld_High_DATE
        AND b.StatusRequest_CODE = @Lc_ReqStatusPending_CODE
        AND EXISTS (SELECT 1
                      FROM ICAS_Y1 a
                     WHERE a.Case_IDNO = b.Case_IDNO
                       AND a.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE
                       AND a.EndValidity_DATE = b.EndValidity_DATE
                       AND a.Status_CODE = @Lc_CaseStatusOpen_CODE);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FOR TRANSACTIONS FAILED.';

       RAISERROR(50001,16,1);
      END;
    END;

   -- Do bulk insert for notices - Join with CSPR_Y1 sp_insert_notices (case IDNO);
   -- if it return  F update CSPR_Y1 ER. 
   -- ref_far_forms_checklist select valid notices from above table insert into printQueue for notice
   --CURSOR FOR PROCESSING THE NOTICE GENERATION FOR THE NON-CSENET TRANSACTIONS
   DECLARE PaperTran_CUR INSENSITIVE CURSOR FOR
    SELECT a.Request_IDNO,
           a.Case_IDNO,
           ISNULL(x.Notice_ID, '') AS Notice_ID,
           a.RespondentMci_IDNO,
           a.IVDOutOfStateFips_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.IVDOutOfStateCase_ID,
           a.Function_CODE,
           a.Action_CODE,
           a.Reason_CODE,
           a.CaseFormer_ID,
           a.Attachment_INDC,
           a.Generated_DATE,
           a.TransHeader_IDNO AS OldCsenetTrans_IDNO
      FROM CSPR_Y1 a
           LEFT OUTER JOIN (FFCL_Y1 x
                            JOIN NREF_Y1 y
                             ON x.Notice_ID = y.Notice_ID)
            ON a.Function_CODE = x.Function_CODE
               AND a.Action_CODE = x.Action_CODE
               AND x.Notice_ID IN ('INT-01', 'INT-02', 'INT-03', 'INT-08', 'INT-14')
               AND a.Reason_CODE = x.Reason_CODE
               AND x.EndValidity_DATE = @Ld_High_DATE
               AND y.EndValidity_DATE = @Ld_High_DATE
     WHERE a.StatusRequest_CODE = @Lc_ReqStatusPending_CODE
       AND a.ExchangeMode_INDC = @Lc_ExchangeModePaper_TEXT
       AND a.EndValidity_DATE = @Ld_High_DATE;

   OPEN PaperTran_CUR;

   FETCH NEXT FROM PaperTran_CUR INTO @Ln_PaperTranCur_Request_IDNO, @Ln_PaperTranCur_Case_IDNO, @Lc_PaperTranCur_Notice_ID, @Ln_PaperTranCur_RespondentMci_IDNO, @Lc_PaperTranCur_IVDOutOfStateFips_CODE, @Lc_PaperTranCur_IVDOutOfStateCountyFips_CODE, @Lc_PaperTranCur_IVDOutOfStateOfficeFips_CODE, @Lc_PaperTranCur_IVDOutOfStateCase_ID, @Lc_PaperTranCur_Function_CODE, @Lc_PaperTranCur_Action_CODE, @Lc_PaperTranCur_Reason_CODE, @Lc_PaperTranCur_CaseFormer_ID, @Lc_PaperTranCur_Attachment_INDC, @Ld_PaperTranCur_Generated_DATE, @Lc_PaperTranCur_OldCsenetTrans_IDNO;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
   SET @Li_RecordCount_QNTY = 0;

   -- Process paper mode transaction
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION SAVECSENET_EXT;

      SET @Ln_Barcode_NUMB = 0;
      SET @Ln_Topic_IDNO = 0;
      SET @Lc_Papersuccess_INDC = @Lc_Yes_INDC;
      SET @Lc_BateError_CODE = 'E1424';
      SET @Ls_BateRecord_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_PaperTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_PaperTranCur_Case_IDNO AS VARCHAR), '') + ', RespondentMci_IDNO = ' + ISNULL(CAST(@Ln_PaperTranCur_RespondentMci_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_PaperTranCur_IVDOutOfStateFips_CODE, '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(@Lc_PaperTranCur_IVDOutOfStateCountyFips_CODE, '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(@Lc_PaperTranCur_IVDOutOfStateOfficeFips_CODE, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_PaperTranCur_IVDOutOfStateCase_ID, '') + ', Function_CODE = ' + ISNULL(@Lc_PaperTranCur_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_PaperTranCur_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_PaperTranCur_Reason_CODE, '') + ', CaseFormer_ID = ' + ISNULL(@Lc_PaperTranCur_CaseFormer_ID, '') + ', Attachment_INDC = ' + ISNULL(@Lc_PaperTranCur_Attachment_INDC, '') + ', Generated_DATE = ' + ISNULL(CAST(@Ld_PaperTranCur_Generated_DATE AS VARCHAR), '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Lc_PaperTranCur_OldCsenetTrans_IDNO AS VARCHAR), '');
      SET @Li_RecordCount_QNTY = @Li_RecordCount_QNTY + 1;
      SET @Ls_CursorLoc_TEXT = 'PAPER NOTICE - CURSOR COUNT - ' + CAST(@Li_RecordCount_QNTY AS VARCHAR);

      IF @Lc_PaperTranCur_Notice_ID = ''
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'NOTICE ID NOT FOUND FOR FAR COMBINATION IN FFCL';
        SET @Lc_BateError_CODE = 'E0058';

        RAISERROR(50001,16,1);
       END
      ELSE
       BEGIN
        IF @Ln_PaperTranCur_RespondentMci_IDNO <> 0
         BEGIN
          SET @Ln_MemberMci_IDNO = @Ln_PaperTranCur_RespondentMci_IDNO;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PaperTranCur_Case_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE, '');

          SELECT @Ln_MemberMci_IDNO = a.MemberMci_IDNO
            FROM CMEM_Y1 a
           WHERE a.Case_IDNO = @Ln_PaperTranCur_Case_IDNO
             AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
             AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
         END;

        -- if the record exists in CAIN_Y1 with Bar Code 0 then Notice id should be 0
        -- PaperSuccess Indicator is setting as Y
        SET @Ls_Sql_TEXT = 'SELECT CAIN_Y1 BARCODE';
        SET @Ls_Sqldata_TEXT = 'Notice_ID = ' + ISNULL(@Lc_PaperTranCur_Notice_ID, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_PaperTranCur_Generated_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_PaperTranCur_IVDOutOfStateFips_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

        SELECT @Ln_Barcode_NUMB = a.Barcode_NUMB
          FROM CAIN_Y1 a
         WHERE a.TransHeader_IDNO = CAST(@Ln_PaperTranCur_Request_IDNO AS VARCHAR)
           AND a.Notice_ID = @Lc_PaperTranCur_Notice_ID
           AND a.Transaction_DATE = @Ld_PaperTranCur_Generated_DATE
           AND a.IVDOutOfStateFips_CODE = @Lc_PaperTranCur_IVDOutOfStateFips_CODE
           AND a.EndValidity_DATE = @Ld_High_DATE;

        SET @Li_Rowcount_QNTY = @@ROWCOUNT;

        IF (@Li_Rowcount_QNTY = 0)
         BEGIN
          SET @Ln_NoticeCount_NUMB = 0;
          SET @Ln_Barcode_NUMB = 0;
         END;
        ELSE IF @Ln_Barcode_NUMB > 0
         BEGIN
          SET @Ln_NoticeCount_NUMB = 1;
         END;
        ELSE
         BEGIN
          SET @Ln_NoticeCount_NUMB = 0;
         END;

        IF (@Ln_NoticeCount_NUMB > 0)
         BEGIN
          IF (@Ln_Barcode_NUMB > 0)
           BEGIN
            SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
           END;
         END;

        IF (@Ln_NoticeCount_NUMB = 0)
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
          SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '');

          EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_No_INDC,
           @An_EventFunctionalSeq_NUMB  = 0,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR(50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'INSERT CAIN_Y1';
          SET @Ls_Sqldata_TEXT = 'IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_PaperTranCur_IVDOutOfStateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_PaperTranCur_Generated_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_PaperTranCur_Notice_ID, '') + ', Received_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Barcode_NUMB = ' + ISNULL(CAST(@Ln_Barcode_NUMB AS VARCHAR), '');

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
          VALUES ( CAST(@Ln_PaperTranCur_Request_IDNO AS VARCHAR),--TransHeader_IDNO
                   @Lc_PaperTranCur_IVDOutOfStateFips_CODE,--IVDOutOfStateFips_CODE
                   @Ld_PaperTranCur_Generated_DATE,--Transaction_DATE
                   @Lc_PaperTranCur_Notice_ID,--Notice_ID
                   @Lc_Yes_INDC,--Received_INDC
                   CONVERT(DATE, @Ld_Start_DATE, 102),--BeginValidity_DATE
                   @Ld_High_DATE,--EndValidity_DATE
                   @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                   @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                   @Ld_Start_DATE,--Update_DTTM
                   @Ln_Barcode_NUMB --Barcode_NUMB
          );

          SET @Li_Rowcount_QNTY = @@ROWCOUNT;

          IF (@Li_Rowcount_QNTY = 0)
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'INSERT INTO CAIN_Y1 FAILED';

            RAISERROR(50001,16,1);
           END;
         END;

        IF (@Ln_Barcode_NUMB = 0)
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
          SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '');

          EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_No_INDC,
           @An_EventFunctionalSeq_NUMB  = 0,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR(50001,16,1);
           END;

          SET @Lc_Fips_CODE = @Lc_PaperTranCur_IVDOutOfStateFips_CODE + @Lc_PaperTranCur_IVDOutOfStateCountyFips_CODE + @Lc_PaperTranCur_IVDOutOfStateOfficeFips_CODE;
          SET @Ls_Xml_TEXT = '<inputparameters><request_idno>' + CAST(@Ln_PaperTranCur_Request_IDNO AS VARCHAR) + '</request_idno></inputparameters>';
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_PaperTranCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_MinorActivityCsnet_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_CaseInitiation_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_PaperTranCur_Notice_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_Xml_TEXT, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_Fips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_PaperTranCur_Request_IDNO AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_PaperTranCur_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivityCsnet_CODE,
           @Ac_Subsystem_CODE           = @Lc_CaseInitiation_TEXT,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_Notice_ID                = @Lc_PaperTranCur_Notice_ID,
           @As_Xml_TEXT                 = @Ls_Xml_TEXT,
           @An_TopicIn_IDNO             = @Ln_Topic_IDNO,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ac_IVDOutOfStateFips_CODE   = @Lc_Fips_CODE,
           @An_TransHeader_IDNO         = @Ln_PaperTranCur_Request_IDNO,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          -- If the code is not  'S' the barcode was selecting from FORM_Y1 using id_topic
          IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
               OR @Ln_Topic_IDNO = 0)
           BEGIN
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR(50001,16,1);
           END;
          ELSE IF (@Lc_Msg_CODE = @Lc_StatusSuccess_CODE)
           BEGIN
            SET @Ls_Sql_TEXT = 'SELECT BAR CODE FROM FORM_Y1';
            SET @Ls_Sqldata_TEXT = 'Topic_IDNO = ' + ISNULL(CAST(@Ln_Topic_IDNO AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_PaperTranCur_Notice_ID, '') + ', Recipient_CODE = ' + ISNULL(@Lc_RecdetOtherState_CODE, '');

            SELECT @Ln_Barcode_NUMB = a.Barcode_NUMB
              FROM FORM_Y1 a
             WHERE a.Topic_IDNO = @Ln_Topic_IDNO
               AND a.Notice_ID = @Lc_PaperTranCur_Notice_ID
               AND a.Recipient_CODE = @Lc_RecdetOtherState_CODE
               AND a.Barcode_NUMB != 0;

            SET @Li_Rowcount_QNTY = @@ROWCOUNT;

            IF (@Li_Rowcount_QNTY = 0)
             BEGIN
              SET @Ln_Barcode_NUMB = 0;
              SET @Ls_DescriptionError_TEXT = 'BAR CODE NOT FOUND';

              RAISERROR(50001,16,1);
             END;

            IF (@Ln_Barcode_NUMB != 0)
             BEGIN
              SET @Ls_Sql_TEXT = 'UPDATE CAIN_Y1';
              SET @Ls_Sqldata_TEXT = 'IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_PaperTranCur_IVDOutOfStateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_PaperTranCur_Generated_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_PaperTranCur_Notice_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

              UPDATE CAIN_Y1
                 SET Barcode_NUMB = @Ln_Barcode_NUMB
               WHERE TransHeader_IDNO = CAST(@Ln_PaperTranCur_Request_IDNO AS VARCHAR)
                 AND IVDOutOfStateFips_CODE = @Lc_PaperTranCur_IVDOutOfStateFips_CODE
                 AND Transaction_DATE = @Ld_PaperTranCur_Generated_DATE
                 AND Notice_ID = @Lc_PaperTranCur_Notice_ID
                 AND EndValidity_DATE = @Ld_High_DATE;

              SET @Li_Rowcount_QNTY = @@ROWCOUNT;

              IF (@Li_Rowcount_QNTY = 0)
               BEGIN
                SET @Ls_DescriptionError_TEXT = 'UPDATE CAIN_Y1 FAILED';

                RAISERROR(50001,16,1);
               END;
             END;
           END;
         END;
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVECSENET_EXT
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      -- Check for Exception information to log the description text based on the error
      SET @Ln_Error_NUMB = ERROR_NUMBER ();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Ls_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
       @An_Line_NUMB                = 0,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      SET @Lc_Papersuccess_INDC = 'N';

      IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     IF @Lc_Papersuccess_INDC = 'N'
      BEGIN
       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE Request_IDNO = @Ln_PaperTranCur_Request_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;
      END
     ELSE
      BEGIN
       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusSuccessSent_CODE
        WHERE Request_IDNO = @Ln_PaperTranCur_Request_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;
      END

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_Rowcount_QNTY;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Li_RecordCount_QNTY;

       COMMIT TRANSACTION CSENET_EXT;

       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD FOR PAPER';

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM PaperTran_CUR INTO @Ln_PaperTranCur_Request_IDNO, @Ln_PaperTranCur_Case_IDNO, @Lc_PaperTranCur_Notice_ID, @Ln_PaperTranCur_RespondentMci_IDNO, @Lc_PaperTranCur_IVDOutOfStateFips_CODE, @Lc_PaperTranCur_IVDOutOfStateCountyFips_CODE, @Lc_PaperTranCur_IVDOutOfStateOfficeFips_CODE, @Lc_PaperTranCur_IVDOutOfStateCase_ID, @Lc_PaperTranCur_Function_CODE, @Lc_PaperTranCur_Action_CODE, @Lc_PaperTranCur_Reason_CODE, @Lc_PaperTranCur_CaseFormer_ID, @Lc_PaperTranCur_Attachment_INDC, @Ld_PaperTranCur_Generated_DATE, @Lc_PaperTranCur_OldCsenetTrans_IDNO;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'PaperTran_CUR') IN (0, 1)
    BEGIN
     CLOSE PaperTran_CUR;

     DEALLOCATE PaperTran_CUR;
    END;

   SET @Ls_Sql_TEXT = 'SELECT COUNT FROM CSPR_Y1';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusPending_CODE, '') + ', ExchangeMode_INDC = ' + ISNULL(@Lc_ExchangeModeCsenet_TEXT, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   IF (NOT EXISTS (SELECT 1
                     FROM CSPR_Y1 a
                    WHERE a.StatusRequest_CODE = @Lc_ReqStatusPending_CODE
                      AND a.ExchangeMode_INDC = @Lc_ExchangeModeCsenet_TEXT
                      AND a.EndValidity_DATE = @Ld_High_DATE))
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_DescriptionError_TEXT = 'NO RECORDS TO EXTRACT';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = 'W',
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = 'E0944',
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     EXECUTE BATCH_COMMON$SP_BSTL_LOG
      @Ad_Run_DATE                  = @Ld_Run_DATE,
      @Ad_Start_DATE                = @Ld_Start_DATE,
      @Ac_Job_ID                    = @Lc_Job_ID,
      @As_Process_NAME              = @Ls_Process_NAME,
      @As_Procedure_NAME            = @Ls_Procedure_NAME,
      @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
      @As_ExecLocation_TEXT         = @Ls_BatchSuccess_INDC,
      @As_ListKey_TEXT              = @Ls_BatchSuccess_INDC,
      @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
      @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
      @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
      @An_ProcessedRecordCount_QNTY = 0;

     COMMIT TRANSACTION CSENET_EXT;

     RETURN;
    END;

   DECLARE CsenetTran_CUR INSENSITIVE CURSOR FOR
    SELECT a.Request_IDNO,
           a.Case_IDNO,
           a.IVDOutOfStateFips_CODE,
           a.IVDOutOfStateCountyFips_CODE,
           a.IVDOutOfStateOfficeFips_CODE,
           a.IVDOutOfStateCase_ID,
           a.Function_CODE,
           a.Action_CODE,
           a.Reason_CODE,
           a.CaseFormer_ID,
           a.Attachment_INDC,
           a.Generated_DATE,
           a.TransHeader_IDNO AS OldCsenetTrans_IDNO,
           a.DescriptionComments_TEXT,
           a.PfNoShow_DATE,
           a.Hearing_DATE
      FROM CSPR_Y1 a
     WHERE a.StatusRequest_CODE = @Lc_ReqStatusPending_CODE
       AND a.ExchangeMode_INDC = @Lc_ExchangeModeCsenet_TEXT
       AND a.EndValidity_DATE = @Ld_High_DATE;

   OPEN CsenetTran_CUR;

   FETCH NEXT FROM CsenetTran_CUR INTO @Ln_CsenetTranCur_Request_IDNO, @Ln_CsenetTranCur_Case_IDNO, @Lc_CsenetTranCur_IVDOutOfStateFips_CODE, @Lc_CsenetTranCur_IVDOutOfStateCountyFips_CODE, @Lc_CsenetTranCur_IVDOutOfStateOfficeFips_CODE, @Lc_CsenetTranCur_IVDOutOfStateCase_ID, @Lc_CsenetTranCur_Function_CODE, @Lc_CsenetTranCur_Action_CODE, @Lc_CsenetTranCur_Reason_CODE, @Lc_CsenetTranCur_CaseFormer_ID, @Lc_CsenetTranCur_Attachment_INDC, @Ld_CsenetTranCur_Generated_DATE, @Lc_CsenetTranCur_OldCsenetTrans_IDNO, @Ls_CsenetTranCur_DescriptionComments_TEXT, @Ld_CsenetTranCur_PfNoShow_DATE, @Ld_CsenetTranCur_Hearing_DATE;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
   SET @Li_RecordCount_QNTY = 0;

   -- Process CSENet mode transaction
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     SET @Lb_RowsFoundToday_BIT = 1;
     SET @Lb_SkipTran_BIT = 1;
     SET @Lc_Msg_CODE = @Lc_Space_TEXT;
     SET @Ls_DescriptionComments_TEXT = @Lc_Space_TEXT;
     SET @Ls_DescriptionError_TEXT = '';
     SET @Ld_ActionResolution_DATE = @Ld_Low_DATE;
     SET @Li_RecordCount_QNTY = @Li_RecordCount_QNTY + 1;
     SET @Ls_CursorLoc_TEXT = 'CSENet MODE TRANSACTION - CURSOR COUNT - ' + CAST(@Li_RecordCount_QNTY AS VARCHAR);

     -- If the reason is GIHER, PICHS, SICHS HearingDate should pass in ActionResolution Date field
     -- GIHER - Notice of an upcoming hearing
     -- PICHS - Paternity hearing scheduled
     -- SICHS - Support order hearing scheduled
     IF @Lc_CsenetTranCur_Reason_CODE IN (@Lc_ReasonPichs_CODE, @Lc_ReasonGiher_CODE, @Lc_ReasonSichs_CODE)
      BEGIN
       SET @Ld_ActionResolution_DATE = @Ld_CsenetTranCur_Hearing_DATE;
      END;

     SET @Li_NextTranPointer_NUMB = 0;
     SET @Lc_Function_CODE = @Lc_CsenetTranCur_Function_CODE;
     SET @Lc_Action_CODE = @Lc_CsenetTranCur_Action_CODE;
     SET @Lc_Reason_CODE = @Lc_CsenetTranCur_Reason_CODE;
     SET @Ln_Case_IDNO = @Ln_CsenetTranCur_Case_IDNO;
     SET @Lc_StateFips_CODE = @Lc_CsenetTranCur_IVDOutOfStateFips_CODE;
     SET @Lc_Attachments_INDC = (CASE LTRIM(@Lc_CsenetTranCur_Attachment_INDC)
                                  WHEN ''
                                   THEN @Lc_No_INDC
                                  ELSE @Lc_CsenetTranCur_Attachment_INDC
                                 END);
     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Lc_Message_ID = CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR);
     SET @Ln_TransHeader_IDNO = CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR);
	 SET @Ls_Sql_TEXT = 'SELECT FROM FAR_COMBINATION TABLE TO SET ALL BLOCK INDICATORS VALUE IN HEADER BLOCK';
     SET @Ls_Sqldata_TEXT = 'Function_CODE = ' + ISNULL(@Lc_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_Reason_CODE, '');

     SELECT @Li_CaseData_QNTY = a.CaseBlock_QNTY,
            @Li_Ncp_QNTY = a.NcpBlock_QNTY,
            @Li_NcpLoc_QNTY = a.NcpLocateBlock_QNTY,
            @Li_Participant_QNTY = a.ParticipantBlock_QNTY,
            @Li_Order_QNTY = a.OrderBlock_QNTY,
            @Li_Collection_QNTY = a.CollectionBlock_QNTY,
            @Li_Info_QNTY = a.InfoBlock_QNTY
       FROM CFAR_Y1 a
      WHERE a.Function_CODE = @Lc_Function_CODE
        AND a.Action_CODE = @Lc_Action_CODE
        AND a.Reason_CODE = @Lc_Reason_CODE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       --UPDATE CSPR - START
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1';
       SET @Ls_Sqldata_TEXT = @Ls_Sqldata_TEXT + ', Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
          AND Case_IDNO = @Ln_Case_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

         RAISERROR(50001,16,1);
        END;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @An_Line_NUMB                = 0,
        @Ac_Error_CODE               = @Lc_UpdateFailed_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END;

       SET @Li_NextTranPointer_NUMB = 10;
      END;

     --Bug 13651 - OTHER-CASE-ID is required for all responses and acknowledgments. if OTHER-CASE-ID is not present the transaction should be written to BATE - Start
     IF (@Lc_CsenetTranCur_IVDOutOfStateCase_ID = ''
	      AND @Lc_Action_CODE = 'P')
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 : IVDOutOfStateCase_ID missing for response and acknowledgment.';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');
       SET @Ls_DescriptionError_TEXT = 'IVDOutOfStateCase_ID missing for response and acknowledgment.';
	   SET @Li_NextTranPointer_NUMB = 10;
      END;
	 --Bug 13651 - OTHER-CASE-ID is required for all responses and acknowledgments. if OTHER-CASE-ID is not present the transaction should be written to BATE - End

	 -- If cleared for next transaction and Provide Information about NCP Locate
     IF @Li_NextTranPointer_NUMB = 0
        AND @Lc_Function_CODE = @Lc_FunctionQuickLocate_CODE
        AND @Lc_Action_CODE = @Lc_ActionProvide_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'FUNCTION CODE - ' + @Lc_FunctionQuickLocate_CODE + ', ACTION CODE - ' + @Lc_ActionProvide_CODE;
       SET @Ls_Sqldata_TEXT = 'Transaction_IDNO = ' + ISNULL(@Lc_CsenetTranCur_OldCsenetTrans_IDNO, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_CsenetTranCur_Generated_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_CsenetTranCur_IVDOutOfStateFips_CODE, '');

       SELECT @Lc_Last_NAME = a.Last_NAME,
              @Lc_First_NAME = a.First_NAME,
              @Ln_MemberSsn_NUMB = a.MemberSsn_NUMB,
              @Ld_Birth_DATE = a.Birth_DATE,
              @Lc_Middle_NAME = a.Middle_NAME,
              @Lc_MemberSex_CODE = a.MemberSex_CODE
         FROM CNCB_Y1 a,
              CTHB_Y1 b
        WHERE b.Transaction_IDNO = @Lc_CsenetTranCur_OldCsenetTrans_IDNO
          AND a.TransHeader_IDNO = b.TransHeader_IDNO
          AND a.Transaction_DATE = @Ld_CsenetTranCur_Generated_DATE
          AND a.IVDOutOfStateFips_CODE = @Lc_CsenetTranCur_IVDOutOfStateFips_CODE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ln_MemberMci_IDNO = 0;
         SET @Lc_Reason_CODE = @Lc_ReasonLuall_CODE;
         SET @Li_CaseData_QNTY = 0;
         SET @Li_Ncp_QNTY = 0;
         SET @Li_NcpLoc_QNTY = 0;
         SET @Li_Info_QNTY = 0;
        END;
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_MEMBER_CLEARENCE';
         SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_MemberSsn_NUMB AS VARCHAR), '') + ', First_NAME = ' + ISNULL(@Lc_First_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_Last_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_Middle_NAME, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_MemberSex_CODE, '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_Birth_DATE AS VARCHAR), '');

         EXECUTE BATCH_COMMON$SP_MEMBER_CLEARENCE
          @An_MemberMci_IDNO        = 0,
          @An_MemberSsn_NUMB        = @Ln_MemberSsn_NUMB,
          @Ac_First_NAME            = @Lc_First_NAME,
          @Ac_Last_NAME             = @Lc_Last_NAME,
          @Ac_Middle_NAME           = @Lc_Middle_NAME,
          @Ac_MemberSex_CODE        = @Lc_MemberSex_CODE,
          @Ad_Birth_DATE            = @Ld_Birth_DATE,
          @An_MemberMciOut_IDNO     = @Ln_MemberMci_IDNO OUTPUT,
          @Ac_MemberSsnMatch_INDC   = @Lc_SsnMatch_CODE OUTPUT,
          @Ac_NameMatch_INDC        = @Lc_NameMatch_INDC OUTPUT,
          @Ac_ExactMatch_INDC       = @Lc_ExactMatch_INDC OUTPUT,
          @Ac_MultMatch_INDC        = @Lc_MultMatch_INDC OUTPUT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         -- Set the Correct Reason code for LO1 P transaction.
         -- IF the Member Is returned from the above SP is null Set reason Code as 'LUALL'
         -- If single member Id found then set the reason code according to the value found in the system
         -- If member is deceased then comments added. Info indicator is set 1
         IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
              OR @Ln_MemberMci_IDNO IS NULL
              OR @Ln_MemberMci_IDNO = 0)
          BEGIN
           SET @Lc_Reason_CODE = @Lc_ReasonLuall_CODE;
           SET @Li_CaseData_QNTY = 0;
           SET @Li_Ncp_QNTY = 0;
           SET @Li_NcpLoc_QNTY = 0;
           SET @Li_Info_QNTY = 0;
          END;
         ELSE
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1.Deceased_DATE';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '');

           SELECT @Ld_Deceased_DATE = a.Deceased_DATE
             FROM DEMO_Y1 a
            WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO;

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF (@Li_Rowcount_QNTY = 0)
            BEGIN
             SET @Lc_MemberDeceased_TEXT = @Lc_No_INDC;
            END;
           ELSE
            BEGIN
             IF @Ld_Deceased_DATE = @Ld_High_DATE
                 OR @Ld_Deceased_DATE = @Ld_Low_DATE
              BEGIN
               SET @Lc_MemberDeceased_TEXT = @Lc_No_INDC;
              END
             ELSE
              BEGIN
               SET @Lc_MemberDeceased_TEXT = @Lc_Yes_INDC;
              END;
            END;

           IF @Lc_MemberDeceased_TEXT = @Lc_Yes_INDC
            BEGIN
             SET @Lc_Reason_CODE = @Lc_ReasonLuapd_CODE;
             SET @Li_NcpLoc_QNTY = 0;
             SET @Ls_DescriptionComments_TEXT = 'NCP DECEASED.  DATE OF DEATH: ' + ISNULL(CAST(@Ld_Deceased_DATE AS VARCHAR), '');
             SET @Li_Info_QNTY = 1;
            END

           SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1.Case_IDNO';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseNcp_TEXT, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE, '');

           SELECT TOP 1 @Ln_Case_IDNO = b.Case_IDNO
             FROM CMEM_Y1 a
                  JOIN CASE_Y1 b
                   ON a.Case_IDNO = b.Case_IDNO
            WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
              AND a.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_TEXT
              AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF (@Li_Rowcount_QNTY = 0)
            BEGIN
             SET @Ln_Case_IDNO = 0;
            END;
          END;
        END;
      END;

     -- Function Code = 'CSI' (Case Summary Information)
     -- Action Code = 'P' (Provide Information / Request)
     -- Reason Code = 'FSINF' (Provide all available case information)
     IF @Li_NextTranPointer_NUMB = 0
        AND (@Lc_Function_CODE = @Lc_FunctionCasesummary_CODE
             AND @Lc_Action_CODE = @Lc_ActionProvide_CODE
             AND @Lc_Reason_CODE = @Lc_ReasonFsinf_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'CHECK CASE DATA FOR CSI-P-FSINF';

       IF (NOT EXISTS (SELECT 1
                         FROM CASE_Y1 a
                        WHERE a.Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
                          AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE))
        BEGIN
         SET @Lc_Reason_CODE = @Lc_ReasonFuinf_CODE;
         SET @Li_CaseData_QNTY = 0;
         SET @Li_Ncp_QNTY = 0;
         SET @Li_NcpLoc_QNTY = 0;
         SET @Li_Participant_QNTY = 0;
         SET @Li_Info_QNTY = 0;
        END;
      END;

     IF (@Li_NextTranPointer_NUMB = 0
         AND ISNULL(@Li_CaseData_QNTY, 0) > 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_CASE';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', StateFips_CODE = ' + ISNULL(@Lc_StateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

       EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_CASE
        @An_Case_IDNO             = @Ln_Case_IDNO,
        @Ac_StateFips_CODE        = @Lc_StateFips_CODE,
        @An_TransHeader_IDNO      = @Ln_TransHeader_IDNO,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         IF @Lc_Function_CODE = @Lc_FunctionCasesummary_CODE
            AND @Lc_Action_CODE = @Lc_ActionProvide_CODE
          BEGIN
           -- FUINF - No case information available for case number provided
           SET @Lc_Reason_CODE = @Lc_ReasonFuinf_CODE;
           SET @Li_CaseData_QNTY = 0;
           SET @Li_Ncp_QNTY = 0;
           SET @Li_Participant_QNTY = 0;
          END;
         ELSE
          BEGIN
           SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 : FAILED TO LOAD CASE DATA BLOCK ';
           SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

           UPDATE CSPR_Y1
              SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
            WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
              AND EndValidity_DATE = @Ld_High_DATE;

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF (@Li_Rowcount_QNTY = 0)
            BEGIN
             SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

             RAISERROR(50001,16,1);
            END;

           SET @Li_NextTranPointer_NUMB = 10;
          END;
        END;
      END;

     -- This will build NCP block for all transactions, if the block indicator is true
     IF @Li_NextTranPointer_NUMB = 0
        AND ISNULL(@Li_Ncp_QNTY, 0) > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'NCP DATA BLOCK REQUIRED FOR THIS TRANSACTION ';
       SET @Ls_Sqldata_TEXT = '';

       SELECT TOP (1) @Ln_MemberMci_IDNO = z.MemberMci_IDNO,
                      @Lc_Last_NAME = z.Last_NAME,
                      @Lc_First_NAME = z.First_NAME,
                      @Lc_Middle_NAME = z.Middle_NAME,
                      @Lc_Suffix_NAME = z.Suffix_NAME,
                      @Ln_MemberSsn_NUMB = z.MemberSsn_NUMB,
                      @Ld_Birth_DATE = z.Birth_DATE,
                      @Lc_FtHeight_TEXT = z.FtHeight_TEXT,
                      @Lc_InHeight_TEXT = z.InHeight_TEXT,
                      @Lc_DescriptionWeightLbs_TEXT = z.DescriptionWeightLbs_TEXT,
                      @Lc_Gender_CODE = z.MemberSex_CODE,
                      @Lc_ColorHair_CODE = z.hair_color,
                      @Lc_ColorEyes_CODE = z.eye_color,
                      @Lc_Race_CODE = z.Race_CODE,
                      @Lc_PlaceOfBirth_TEXT = z.BirthCity_NAME,
                      @Lc_DistinguishingMarks_TEXT = z.DescriptionIdentifyingMarks_TEXT,
                      @Lc_FatherOrMomMaiden_NAME = z.MotherMaiden_NAME,
                      @Lc_PossiblyDangerous_CODE = CASE z.TypeProblem_CODE
                                                    WHEN @Lc_PossiblyDangerousHv_CODE
                                                     THEN @Lc_Yes_INDC
                                                    ELSE @Lc_No_INDC
                                                   END
         FROM (SELECT b.MemberMci_IDNO,
                      a.Last_NAME AS Last_NAME,
                      a.First_NAME AS First_NAME,
                      a.Middle_NAME AS Middle_NAME,
                      a.Suffix_NAME,
                      a.MemberSsn_NUMB,
                      a.Birth_DATE,
                      SUBSTRING(a.DescriptionHeight_TEXT, 1, 1) AS FtHeight_TEXT,
                      SUBSTRING(a.DescriptionHeight_TEXT, 2, 2) AS InHeight_TEXT,
                      a.DescriptionWeightLbs_TEXT,
                      a.MemberSex_CODE AS MemberSex_CODE,
                      a.ColorHair_CODE AS hair_color,
                      a.ColorEyes_CODE AS eye_color,
                      a.Race_CODE,
                      SUBSTRING(a.BirthCity_NAME, 1, 15) AS BirthCity_NAME,
                      SUBSTRING(a.DescriptionIdentifyingMarks_TEXT, 1, 20) AS DescriptionIdentifyingMarks_TEXT,
                      a.MotherMaiden_NAME,
                      a.TypeProblem_CODE,
                      b.CaseRelationship_CODE
                 FROM DEMO_Y1 a,
                      CMEM_Y1 b
                WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                  AND b.Case_IDNO = @Ln_Case_IDNO
                  AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                  AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)) AS z
        ORDER BY z.CaseRelationship_CODE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'NO NCP INFORMATION FOUND FOR CASE Seq_IDNO : ' + CAST(@Ln_Case_IDNO AS VARCHAR);
         SET @Lc_Msg_CODE = @Lc_No_INDC;
         SET @Lc_Error_CODE = @Lc_ErrorNoDataFound_TEXT;

         RAISERROR(50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'SELECTS THE NCP MemberSsn_NUMB';
       SET @Ln_MemberSsn_NUMB = dbo.BATCH_COMMON$SF_GET_VERIFIED_SSN_ITIN(@Ln_MemberMci_IDNO);
       SET @Ls_Sql_TEXT = 'INSERTS THE NCP INFORMATION TO ENBLK_Y1 TABLE';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_StateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_CsenetTranCur_Generated_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Last_NAME = ' + ISNULL(@Lc_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_First_NAME, '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_MemberSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_Birth_DATE AS VARCHAR), '') + ', Race_CODE = ' + ISNULL(@Lc_Race_CODE, '') + ', MemberSex_CODE = ' + ISNULL(@Lc_Gender_CODE, '') + ', PlaceOfBirth_NAME = ' + ISNULL(@Lc_PlaceOfBirth_TEXT, '') + ', DescriptionWeightLbs_TEXT = ' + ISNULL(@Lc_DescriptionWeightLbs_TEXT, '') + ', ColorHair_CODE = ' + ISNULL(@Lc_ColorHair_CODE, '') + ', ColorEyes_CODE = ' + ISNULL(@Lc_ColorEyes_CODE, '') + ', DistinguishingMarks_TEXT = ' + ISNULL(@Lc_DistinguishingMarks_TEXT, '') + ', PossiblyDangerous_INDC = ' + ISNULL(@Lc_PossiblyDangerous_CODE, '') + ', FatherOrMomMaiden_NAME = ' + ISNULL(@Lc_FatherOrMomMaiden_NAME, '');

       INSERT ENBLK_Y1
              (TransHeader_IDNO,
               IVDOutOfStateFips_CODE,
               Transaction_DATE,
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
       VALUES ( @Ln_TransHeader_IDNO,--TransHeader_IDNO
                @Lc_StateFips_CODE,--IVDOutOfStateFips_CODE
                @Ld_CsenetTranCur_Generated_DATE,--Transaction_DATE
                @Ln_MemberMci_IDNO,--MemberMci_IDNO
                @Lc_Last_NAME,--Last_NAME
                @Lc_First_NAME,--First_NAME
                --13833 - CSENet extract error due to 17 character middle name -START-
				SUBSTRING(ISNULL(@Lc_Middle_NAME, @Lc_Space_TEXT), 1, 16),--Middle_NAME
				--13833 - CSENet extract error due to 17 character middle name -END-
                ISNULL(@Lc_Suffix_NAME, @Lc_Space_TEXT),--Suffix_NAME
                @Ln_MemberSsn_NUMB,--MemberSsn_NUMB
                @Ld_Birth_DATE,--Birth_DATE
                @Lc_Race_CODE,--Race_CODE
                @Lc_Gender_CODE,--MemberSex_CODE
                @Lc_PlaceOfBirth_TEXT,--PlaceOfBirth_NAME
                ISNULL(@Lc_FtHeight_TEXT, 0),--FtHeight_TEXT
                ISNULL(@Lc_InHeight_TEXT, 0),--InHeight_TEXT
                @Lc_DescriptionWeightLbs_TEXT,--DescriptionWeightLbs_TEXT
                @Lc_ColorHair_CODE,--ColorHair_CODE
                @Lc_ColorEyes_CODE,--ColorEyes_CODE
                @Lc_DistinguishingMarks_TEXT,--DistinguishingMarks_TEXT
                ' ',--Alias1Ssn_NUMB
                ' ',--Alias2Ssn_NUMB
                @Lc_PossiblyDangerous_CODE,--PossiblyDangerous_INDC
                ' ',--Maiden_NAME
                @Lc_FatherOrMomMaiden_NAME --FatherOrMomMaiden_NAME
       );

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       -- CSENET SELECT NCP - END
       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 : FAILED TO LOAD NCP DATA BLOCK ';
         SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
          WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
            AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF (@Li_Rowcount_QNTY = 0)
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

           RAISERROR(50001,16,1);
          END;

         SET @Li_NextTranPointer_NUMB = 10;
        END;
      END;

     IF @Li_NextTranPointer_NUMB = 0
        AND ISNULL(@Li_NcpLoc_QNTY, 0) > 0
      BEGIN
       IF (@Ln_MemberMci_IDNO != 0)
        BEGIN
         SET @Ls_Sql_TEXT = 'CALL BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_NCP_LOCATE : LOCATE DATA BLOCK REQUIRED FOR THIS TRANSACTION ';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', StateFips_CODE = ' + ISNULL(@Lc_StateFips_CODE, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

         EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_NCP_LOCATE
          @An_Case_IDNO             = @Ln_Case_IDNO,
          @An_TransHeader_IDNO      = @Ln_TransHeader_IDNO,
          @Ac_StateFips_CODE        = @Lc_StateFips_CODE,
          @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
          @Ad_Start_DATE            = @Ld_Start_DATE,
          @Ad_Run_DATE              = @Ld_Run_DATE,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
        END
       ELSE
        BEGIN
         SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
        END;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 : FAILED TO LOAD LOCATE DATA BLOCK ';
         SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
          WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
            AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF (@Li_Rowcount_QNTY = 0)
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

           RAISERROR(50001,16,1);
          END;

         SET @Li_NextTranPointer_NUMB = 10;
        END;
      END;

     IF @Li_NextTranPointer_NUMB = 0
        AND ISNULL(@Li_Participant_QNTY, 0) > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'CALL BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_PART : PARTICIPANT DATA BLOCK REQUIRED FOR THIS TRANSACTION ';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', StateFips_CODE = ' + ISNULL(@Lc_StateFips_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_Reason_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '');

       EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_PART
        @An_Case_IDNO             = @Ln_Case_IDNO,
        @An_TransHeader_IDNO      = @Ln_TransHeader_IDNO,
        @Ac_StateFips_CODE        = @Lc_StateFips_CODE,
        @Ac_Function_CODE         = @Lc_Function_CODE,
        @Ac_Action_CODE           = @Lc_Action_CODE,
        @Ac_Reason_CODE           = @Lc_Reason_CODE,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ad_Start_DATE            = @Ld_Start_DATE,
        @Ai_Participant_QNTY      = @Li_Participant_QNTY OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 : FAILED TO LOAD PARTICIPANT DATA BLOCK ';
         SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
          WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
            AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF (@Li_Rowcount_QNTY = 0)
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

           RAISERROR(50001,16,1);
          END;

         SET @Li_NextTranPointer_NUMB = 10;
        END;
      END;

     IF @Li_NextTranPointer_NUMB = 0
        AND ISNULL(@Li_Order_QNTY, 0) > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'CALL BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_ORDER : ORDER DATA BLOCK REQUIRED FOR THIS TRANSACTION ';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', StateFips_CODE = ' + ISNULL(@Lc_StateFips_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '');

       EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_ORDER
        @An_Case_IDNO             = @Ln_Case_IDNO,
        @An_TransHeader_IDNO      = @Ln_TransHeader_IDNO,
        @Ac_StateFips_CODE        = @Lc_StateFips_CODE,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @Ad_Start_DATE            = @Ld_Start_DATE,
        @Ai_Order_QNTY            = @Li_Order_QNTY OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 : FAILED TO LOAD ORDER DATA BLOCK ';
         SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
          WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
            AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF (@Li_Rowcount_QNTY = 0)
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

           RAISERROR(50001,16,1);
          END;

         SET @Li_NextTranPointer_NUMB = 10;
        END;
      END

     IF @Li_NextTranPointer_NUMB = 0
        AND ISNULL(@Li_Collection_QNTY, 0) > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'CALL BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_COLLECTION : COLLECTION DATA BLOCK REQUIRED FOR THIS TRANSACTION ';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '');

       EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_COLLECTION
        @An_Case_IDNO             = @Ln_Case_IDNO,
        @An_TransHeader_IDNO      = @Ln_TransHeader_IDNO,
        @Ai_Collection_QNTY       = @Li_Collection_QNTY OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 : FAILED TO LOAD COLLECTION DATA BLOCK ';
         SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
          WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
            AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF (@Li_Rowcount_QNTY = 0)
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

           RAISERROR(50001,16,1);
          END;

         SET @Li_NextTranPointer_NUMB = 10;
        END;
      END;

     IF (@Li_NextTranPointer_NUMB = 0)
      BEGIN
       IF (@Lc_Function_CODE = @Lc_FunctionManagestcases_CODE
           AND @Lc_Action_CODE = @Lc_ActionProvide_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = 'MSC/P';

         IF (@Lc_Reason_CODE = @Lc_FarUnprocessed_CODE)
          BEGIN
           SET @Li_Info_QNTY = 1;
          END;
         ELSE IF (@Lc_Reason_CODE = @Lc_ReasonGscas_CODE)
          BEGIN
           -- GSCAS - Change local case ID
           SET @Li_Info_QNTY = 1;
           SET @Ls_DescriptionComments_TEXT = ISNULL(@Ls_DescriptionComments_TEXT, '') + ' STATE FORMER CASE Seq_IDNO WAS: ' + ISNULL(@Lc_CsenetTranCur_CaseFormer_ID, '');
          END;
        END;
       ELSE IF (@Lc_Function_CODE = @Lc_FunctionPaternity_CODE
           AND @Lc_Action_CODE = @Lc_ActionProvide_CODE
           AND @Lc_Reason_CODE = @Lc_ReasonPipns_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = 'PAT/P/PIPNS';
         -- PIPNS - Putative father did not show for genetic test
         SET @Li_Info_QNTY = 1;
         SET @Ls_DescriptionComments_TEXT = ISNULL(@Ls_DescriptionComments_TEXT, '') + 'PUTATIVE FATHER DID NOT SHOW FOR GENETIC TEST SCHEDULED FOR: ' + ISNULL(CONVERT(VARCHAR, @Ld_CsenetTranCur_PfNoShow_DATE, 101), '');
        END;
      END;

     IF (@Lc_Attachments_INDC = @Lc_Yes_INDC)
      BEGIN
       SET @Li_Info_QNTY = 1;
      END;

     SET @Ls_DescriptionComments_TEXT = ISNULL(@Ls_DescriptionComments_TEXT, '') + ' ' + ISNULL(@Ls_CsenetTranCur_DescriptionComments_TEXT, '');

     IF (@Li_NextTranPointer_NUMB = 0
         AND ((@Lc_Function_CODE = @Lc_FunctionQuickLocate_CODE
               AND @Lc_Action_CODE = @Lc_ActionProvide_CODE)
               OR (@Lc_Function_CODE = @Lc_FunctionManagestcases_CODE
                   AND @Lc_Action_CODE = @Lc_ActionProvide_CODE
                   AND @Lc_Reason_CODE = @Lc_ReasonLsadr_CODE)))
      BEGIN
       -- LSADR - NCP address located and confirmed
       -- LSALL - Locate successful - address and employer both located and confirmed
       IF @Lc_Reason_CODE IN (@Lc_ReasonLsall_CODE, @Lc_ReasonLsadr_CODE)
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT ENBLK_Y1.MemberSsn_NUMB';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '');

         SELECT @Lc_MemberSsn_INDC = CASE LEN(LTRIM(a.MemberSsn_NUMB))
                                      WHEN 9
                                       THEN @Lc_Yes_INDC
                                      ELSE @Lc_No_INDC
                                     END,
                @Ld_Birth_DATE = a.Birth_DATE
           FROM ENBLK_Y1 a
          WHERE a.TransHeader_IDNO = @Ln_TransHeader_IDNO;

         IF @Ld_Birth_DATE = @Ld_High_DATE
             OR @Ld_Birth_DATE = @Ld_Low_DATE
          BEGIN
           SET @Lc_BirthDate_INDC = @Lc_No_INDC;
          END
         ELSE
          BEGIN
           SET @Lc_BirthDate_INDC = @Lc_Yes_INDC;
          END;

         SET @Ls_Sql_TEXT = 'SELECT ENLBL_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '');

         SELECT @Lc_MemberAddFound_TEXT = CASE
                                           WHEN (LTRIM(a.ResidentialLine1_ADDR) != ''
                                                  OR LTRIM(a.MailingLine1_ADDR) != '')
                                            THEN @Lc_Yes_INDC
                                           ELSE @Lc_No_INDC
                                          END,
                @Lc_MemberAddVerified_TEXT = CASE
                                              WHEN (LTRIM(a.ResidentialConfirmed_CODE) != ''
                                                     OR LTRIM(a.MailingConfirmed_CODE) != '')
                                               THEN @Lc_Yes_INDC
                                              ELSE @Lc_No_INDC
                                             END,
                @Lc_MemberEmpFound_TEXT = CASE LTRIM(a.EmployerLine1_ADDR)
                                           WHEN ''
                                            THEN @Lc_No_INDC
                                           ELSE @Lc_Yes_INDC
                                          END,
                @Lc_MemberEmpVerified_TEXT = CASE LTRIM(a.EmployerConfirmed_INDC)
                                              WHEN ''
                                               THEN @Lc_No_INDC
                                              ELSE a.EmployerConfirmed_INDC
                                             END,
                @Lc_ResidentialState_ADDR = a.ResidentialState_ADDR
           FROM ENLBL_Y1 a
          WHERE a.TransHeader_IDNO = @Ln_TransHeader_IDNO;

         IF @Lc_MemberAddFound_TEXT = @Lc_Yes_INDC
            AND @Lc_MemberAddVerified_TEXT = @Lc_Yes_INDC
            AND @Lc_MemberEmpFound_TEXT = @Lc_Yes_INDC
            AND @Lc_MemberAddVerified_TEXT = @Lc_Yes_INDC
            AND @Lc_Reason_CODE = @Lc_ReasonLsall_CODE
          BEGIN
           -- LSALL - Locate successful - address and employer both located and confirmed
           SET @Lc_Reason_CODE = @Lc_ReasonLsall_CODE;
          END;
         ELSE IF @Lc_MemberAddFound_TEXT = @Lc_Yes_INDC
            AND @Lc_MemberAddVerified_TEXT = @Lc_Yes_INDC
          BEGIN
           IF (@Lc_ResidentialState_ADDR != @Lc_StateInState_CODE)
            BEGIN
             -- LSOUT - NCP out of State address verified
             SET @Lc_Reason_CODE = @Lc_ReasonLsout_CODE;
            END;
           ELSE
            BEGIN
             -- LSADR - NCP address located and confirmed
             SET @Lc_Reason_CODE = @Lc_ReasonLsadr_CODE;
            END;
          END;
         ELSE IF @Lc_MemberEmpFound_TEXT = @Lc_Yes_INDC
            AND @Lc_MemberEmpVerified_TEXT = @Lc_Yes_INDC
            AND @Lc_Reason_CODE = @Lc_ReasonLsall_CODE
          BEGIN
           -- LSEMP - Employer located
           SET @Lc_Reason_CODE = @Lc_ReasonLsemp_CODE;
          END;
         ELSE IF @Lc_MemberAddFound_TEXT = @Lc_Yes_INDC
            AND @Lc_MemberAddVerified_TEXT = @Lc_No_INDC
            AND @Lc_Reason_CODE = @Lc_ReasonLsall_CODE
          BEGIN
           -- LICAD - Address found but not confirmed
           SET @Lc_Reason_CODE = @Lc_ReasonLicad_CODE;
          END;
         ELSE IF @Lc_MemberEmpFound_TEXT = @Lc_Yes_INDC
            AND @Lc_MemberEmpVerified_TEXT = @Lc_No_INDC
            AND @Lc_Reason_CODE = @Lc_ReasonLsall_CODE
          BEGIN
           -- LICEM - Employer found but not confirmed
           SET @Lc_Reason_CODE = @Lc_ReasonLicem_CODE;
          END;
         ELSE IF (@Lc_MemberSsn_INDC = @Lc_Yes_INDC
              OR @Lc_BirthDate_INDC = @Lc_Yes_INDC)
            AND @Lc_Reason_CODE = @Lc_ReasonLsall_CODE
          BEGIN
           -- LSOTH - Other information found
           SET @Lc_Reason_CODE = @Lc_ReasonLsoth_CODE;
          END;
         ELSE IF @Lc_Reason_CODE = @Lc_ReasonLsall_CODE
          BEGIN
           -- LUALL - No information found
           SET @Lc_Reason_CODE = @Lc_ReasonLuall_CODE;
          END;
        END;

       -- LUALL - No information found
       IF @Lc_Reason_CODE = @Lc_ReasonLuall_CODE
        BEGIN
         -- LOAD INBOUND DATA - FOR CASE DATA BLOCK - START
         SET @Ls_Sql_TEXT = 'INSERT ECDBL_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '');

         INSERT ECDBL_Y1
                (TransHeader_IDNO,
                 IVDOutOfStateFips_CODE,
                 Transaction_DATE,
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
         SELECT @Ln_TransHeader_IDNO AS TransHeader_IDNO,
                a.IVDOutOfStateFips_CODE,
                a.Transaction_DATE,
                a.TypeCase_CODE,
                a.StatusCase_CODE,
                a.PaymentLine1_ADDR,
                a.PaymentLine2_ADDR,
                a.PaymentCity_ADDR,
                a.PaymentState_ADDR,
                SUBSTRING(REPLACE(a.PaymentZip_ADDR, '-', ''), 1, 9) AS PaymentZip_ADDR,
                a.Last_NAME,
                a.First_NAME,
                --13833 - CSENet extract error due to 17 character middle name -START-
				SUBSTRING(a.Middle_NAME, 1, 16) AS Middle_NAME,
				--13833 - CSENet extract error due to 17 character middle name -END-
                a.Suffix_NAME,
                a.ContactLine1_ADDR,
                a.ContactLine2_ADDR,
                a.ContactCity_ADDR,
                a.ContactState_ADDR,
                SUBSTRING(REPLACE(a.ContactZip_ADDR, '-', ''), 1, 9) AS ContactZip_ADDR,
                a.ContactPhone_NUMB,
                a.PhoneExtensionCount_NUMB,
                a.RespondingFile_ID,
                a.Fax_NUMB,
                SUBSTRING(a.Contact_EML, 1, 35) AS Contact_EML,
                a.InitiatingFile_ID,
                a.AcctSendPaymentsBankNo_TEXT,
                a.SendPaymentsRouting_ID,
                a.StateWithCej_CODE,
                RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.PayFipsSt_CODE)), 2) AS PayFipsSt_CODE,
                RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(a.PayFipsCnty_CODE)), 3) AS PayFipsCnty_CODE,
                RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.PayFipsSub_CODE)), 2) AS PayFipsSub_CODE,
                a.NondisclosureFinding_INDC
           FROM CSDB_Y1 a,
                CTHB_Y1 b
          WHERE b.Transaction_IDNO = @Lc_CsenetTranCur_OldCsenetTrans_IDNO
            AND a.TransHeader_IDNO = b.TransHeader_IDNO
            AND a.IVDOutOfStateFips_CODE = @Lc_CsenetTranCur_IVDOutOfStateFips_CODE
            AND a.Transaction_DATE = @Ld_CsenetTranCur_Generated_DATE;

         -- LOAD INBOUND DATA - FOR CASE DATA BLOCK - END
         SET @Li_CaseData_QNTY = 1;
         -- LOAD INBOUND DATA - FOR CASE DATA BLOCK - START
         SET @Ls_Sql_TEXT = 'INSERT ENBLK_Y1';
         SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '');

         INSERT ENBLK_Y1
                (TransHeader_IDNO,
                 IVDOutOfStateFips_CODE,
                 Transaction_DATE,
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
         SELECT @Ln_TransHeader_IDNO AS TransHeader_IDNO,
                a.IVDOutOfStateFips_CODE,
                a.Transaction_DATE,
                a.MemberMci_IDNO,
                a.Last_NAME,
                a.First_NAME,
                a.Middle_NAME,
                a.Suffix_NAME,
                a.MemberSsn_NUMB,
                a.Birth_DATE,
                a.Race_CODE,
                a.MemberSex_CODE,
                a.PlaceOfBirth_NAME,
                a.FtHeight_TEXT,
                a.InHeight_TEXT,
                a.DescriptionWeightLbs_TEXT,
                a.ColorHair_CODE,
                a.ColorEyes_CODE,
                a.DistinguishingMarks_TEXT,
                a.Alias1Ssn_NUMB,
                a.Alias2Ssn_NUMB,
                a.PossiblyDangerous_INDC,
                a.Maiden_NAME,
                a.FatherOrMomMaiden_NAME
           FROM CNCB_Y1 a,
                CTHB_Y1 b
          WHERE b.Transaction_IDNO = @Lc_CsenetTranCur_OldCsenetTrans_IDNO
            AND a.TransHeader_IDNO = b.TransHeader_IDNO
            AND a.IVDOutOfStateFips_CODE = @Lc_CsenetTranCur_IVDOutOfStateFips_CODE
            AND a.Transaction_DATE = @Ld_CsenetTranCur_Generated_DATE;

         -- LOAD INBOUND DATA - FOR CASE DATA BLOCK - END
         SET @Li_Ncp_QNTY = 1;
        END;
      END

     IF LTRIM(@Ls_DescriptionComments_TEXT) != ''
      BEGIN
       SET @Li_Info_QNTY = 1;
      END;

     IF (@Li_NextTranPointer_NUMB = 0
         AND @Li_Info_QNTY > 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'INFO DATA BLOCK REQUIRED FOR THIS TRANSACTION ';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_TransHeader_IDNO AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Lc_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_Action_CODE, '') + ', Reason_CODE = ' + ISNULL(@Lc_Reason_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '');

       EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_ADDITIONAL_INFO_DESC
        @An_Request_IDNO          = @Ln_TransHeader_IDNO,
        @Ac_Function_CODE         = @Lc_Function_CODE,
        @Ac_Action_CODE           = @Lc_Action_CODE,
        @Ac_Reason_CODE           = @Lc_Reason_CODE,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
        @As_Information_TEXT      = @Ls_Information_TEXT OUTPUT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF RTRIM(LTRIM(@Ls_Information_TEXT)) != ''
        BEGIN
         SET @Ls_DescriptionComments_TEXT = ISNULL(@Ls_DescriptionComments_TEXT, '') + ' - ' + @Ls_Information_TEXT;
        END

       -- CSENET UPDATE INFO - START
       SET @Ls_Sql_TEXT = 'BEFORE INSERT EIBLK_Y1';

       IF (@Lc_Function_CODE = @Lc_FunctionManagestcases_CODE
           AND @Lc_Action_CODE = @Lc_ActionProvide_CODE
           AND @Lc_Reason_CODE = @Lc_ReasonGscas_CODE)
        BEGIN
         SET @Lc_CaseNew_ID = CAST(@Ln_Case_IDNO AS VARCHAR);
        END;

       SET @Ls_Sql_TEXT = 'SELECT CASE_Y1.StatusCase_CODE';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '');

       SELECT @Lc_StatusChange_CODE = a.StatusCase_CODE
         FROM CASE_Y1 a
        WHERE a.Case_IDNO = @Ln_Case_IDNO;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Lc_StatusChange_CODE = @Lc_CaseStatusClosed_CODE;
        END

       IF (@Lc_Function_CODE = @Lc_FunctionManagestcases_CODE
           AND @Lc_Action_CODE = @Lc_ActionProvide_CODE
           AND @Lc_Reason_CODE = @Lc_FarUnprocessed_CODE)
        BEGIN
         SET @Lc_StatusChange_CODE = @Lc_Space_TEXT;
        END;

       SET @Ls_Sql_TEXT = 'INSERT EIBLK_Y1';
       SET @Ls_Sqldata_TEXT = 'IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_CsenetTranCur_IVDOutOfStateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_CsenetTranCur_Generated_DATE AS VARCHAR), '') + ', CaseNew_ID = ' + ISNULL(@Lc_CaseNew_ID, '') + ', StatusChange_CODE = ' + ISNULL(@Lc_StatusChange_CODE, '');

       INSERT EIBLK_Y1
              (TransHeader_IDNO,
               IVDOutOfStateFips_CODE,
               Transaction_DATE,
               CaseNew_ID,
               StatusChange_CODE,
               InfoLine1_TEXT,
               InfoLine2_TEXT,
               InfoLine3_TEXT,
               InfoLine4_TEXT,
               InfoLine5_TEXT)
       VALUES ( CAST(@Ln_TransHeader_IDNO AS VARCHAR),--TransHeader_IDNO
                @Lc_CsenetTranCur_IVDOutOfStateFips_CODE,--IVDOutOfStateFips_CODE
                @Ld_CsenetTranCur_Generated_DATE,--Transaction_DATE
                @Lc_CaseNew_ID,--CaseNew_ID
                @Lc_StatusChange_CODE,--StatusChange_CODE
                ISNULL(SUBSTRING(@Ls_DescriptionComments_TEXT, 1, 80), @Lc_Space_TEXT),--InfoLine1_TEXT
                ISNULL(SUBSTRING(@Ls_DescriptionComments_TEXT, 81, 80), @Lc_Space_TEXT),--InfoLine2_TEXT
                ISNULL(SUBSTRING(@Ls_DescriptionComments_TEXT, 161, 80), @Lc_Space_TEXT),--InfoLine3_TEXT
                ISNULL(SUBSTRING(@Ls_DescriptionComments_TEXT, 241, 80), @Lc_Space_TEXT),--InfoLine4_TEXT
                ISNULL(SUBSTRING(@Ls_DescriptionComments_TEXT, 321, 80), @Lc_Space_TEXT) --InfoLine5_TEXT
       );

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       -- CSENET UPDATE INFO - END
       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 : FAILED TO LOAD INFO DATA BLOCK ';
         SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
          WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
            AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF (@Li_Rowcount_QNTY = 0)
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

           RAISERROR(50001,16,1);
          END;

         SET @Li_NextTranPointer_NUMB = 10;
        END; -- End IF (@Li_Rowcount_QNTY = 0)
      END;

     IF (@Li_NextTranPointer_NUMB = 0)
      BEGIN
       -- FUINF - No case information available for case number provided
       IF NOT (@Lc_Action_CODE = @Lc_ActionProvide_CODE
               AND ((@Lc_Function_CODE = @Lc_FunctionManagestcases_CODE
                     AND @Lc_Reason_CODE = @Lc_FarUnprocessed_CODE)
                     OR (@Lc_Function_CODE = @Lc_FunctionCasesummary_CODE
                         AND @Lc_Reason_CODE = @Lc_ReasonFuinf_CODE)))
        BEGIN
         SET @Ls_Sql_TEXT = 'SELECT CASE_Y1.County_IDNO';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE, '');
         SET @Lc_CountyFips_CODE = ISNULL((SELECT RIGHT(REPLICATE('0', 3) + CAST(a.County_IDNO AS VARCHAR), 3)
                                             FROM CASE_Y1 a
                                            WHERE a.Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
                                              AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                                              AND a.County_IDNO IN (1, 3, 5)), '000');
        END

       SET @Ls_Sql_TEXT = 'INSERT ETHBL_Y1';
       SET @Ls_Sqldata_TEXT = 'Message_ID = ' + ISNULL(@Lc_Message_ID, '') + ', IoDirection_CODE = ' + ISNULL(@Lc_IoDirection_CODE, '') + ', OfficeFips_CODE = ' + ISNULL(@Lc_OfficeDE_CODE, '') + ', CsenetTran_ID = ' + ISNULL(@Lc_CsenetTran_ID, '') + ', Function_CODE = ' + ISNULL(@Lc_Function_CODE, '') + ', Action_CODE = ' + ISNULL(@Lc_Action_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', AttachDue_DATE = ' + ISNULL(CAST(@Ld_AttachDue_DATE AS VARCHAR), '') + ', SntToStHost_CODE = ' + ISNULL(@Lc_SntToStHost_CODE, '') + ', ProcComplete_CODE = ' + ISNULL(@Lc_ProcComplete_CODE, '') + ', InterstateFrmsPrint_CODE = ' + ISNULL(@Lc_InterstateFrmsPrint_CODE, '') + ', TimeSent_DATE = ' + ISNULL(CAST(@Ld_TimeSent_DATE AS VARCHAR), '') + ', Due_DATE = ' + ISNULL(CAST(@Ld_Due_DATE AS VARCHAR), '') + ', Response_DATE = ' + ISNULL(CAST(@Ld_Response_DATE AS VARCHAR), '') + ', Overdue_CODE = ' + ISNULL(@Lc_Overdue_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_CsenetTranCur_Generated_DATE AS VARCHAR), '') + ', ActionResolution_DATE = ' + ISNULL(CAST(@Ld_ActionResolution_DATE AS VARCHAR), '') + ', Attachments_INDC = ' + ISNULL(@Lc_Attachments_INDC, '') + ', CaseData_QNTY = ' + ISNULL(CAST(@Li_CaseData_QNTY AS VARCHAR), '') + ', Ncp_QNTY = ' + ISNULL(CAST(@Li_Ncp_QNTY AS VARCHAR), '') + ', NcpLoc_QNTY = ' + ISNULL(CAST(@Li_NcpLoc_QNTY AS VARCHAR), '') + ', Participant_QNTY = ' + ISNULL(CAST(@Li_Participant_QNTY AS VARCHAR), '') + ', Order_QNTY = ' + ISNULL(CAST(@Li_Order_QNTY AS VARCHAR), '') + ', Collection_QNTY = ' + ISNULL(CAST(@Li_Collection_QNTY AS VARCHAR), '') + ', Info_QNTY = ' + ISNULL(CAST(@Li_Info_QNTY AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', CsenetVersion_ID = ' + ISNULL(@Lc_CsenetVersion_ID, '') + ', ErrorReason_CODE = ' + ISNULL(@Lc_ErrorReason_CODE, '') + ', Received_DTTM = ' + ISNULL(CAST(@Ld_Received_DTTM AS VARCHAR), '') + ', RejectReason_CODE = ' + ISNULL(@Lc_RejectReason_CODE, '') + ', Transaction_IDNO = ' + ISNULL(CAST(@Ln_Transaction_IDNO AS VARCHAR), '') + ', ExchangeMode_CODE = ' + ISNULL(@Lc_ExchangeModeCsenet_TEXT, '');

       INSERT ETHBL_Y1
              (TransHeader_IDNO,
               Message_ID,
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
               TranStatus_CODE,
               AttachDue_DATE,
               SntToStHost_CODE,
               ProcComplete_CODE,
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
               ExchangeMode_CODE)
       VALUES ( CAST(@Ln_TransHeader_IDNO AS VARCHAR),--TransHeader_IDNO
                @Lc_Message_ID,--Message_ID
                @Lc_IoDirection_CODE,--IoDirection_CODE
                '10',--StateFips_CODE
                CASE LTRIM(RTRIM(@Lc_CountyFips_CODE))
                 WHEN ''
                  THEN '000'
                 ELSE @Lc_CountyFips_CODE
                END,--CountyFips_CODE
                @Lc_OfficeDE_CODE,--OfficeFips_CODE
                ISNULL(@Lc_CsenetTranCur_IVDOutOfStateCase_ID, @Lc_IVDOutOfStateCase_ID),--IVDOutOfStateCase_ID
                ISNULL(@Lc_CsenetTranCur_IVDOutOfStateFips_CODE, @Lc_IVDOutOfStateFips_CODE),--IVDOutOfStateFips_CODE
                ISNULL(@Lc_CsenetTranCur_IVDOutOfStateCountyFips_CODE, @Lc_IVDOutOfStateCountyFips_CODE),--IVDOutOfStateCountyFips_CODE
                ISNULL(@Lc_CsenetTranCur_IVDOutOfStateOfficeFips_CODE, @Lc_IVDOutOfStateOfficeFips_CODE),--IVDOutOfStateOfficeFips_CODE
                @Lc_CsenetTran_ID,--CsenetTran_ID
                @Lc_Function_CODE,--Function_CODE
                @Lc_Action_CODE,--Action_CODE
                ISNULL(@Lc_Reason_CODE, @Lc_Space_TEXT),--Reason_CODE
                @Ln_Case_IDNO,--Case_IDNO
                'SS',--TranStatus_CODE
                @Ld_AttachDue_DATE,--AttachDue_DATE
                @Lc_SntToStHost_CODE,--SntToStHost_CODE
                @Lc_ProcComplete_CODE,--ProcComplete_CODE
                @Lc_InterstateFrmsPrint_CODE,--InterstateFrmsPrint_CODE
                @Ld_TimeSent_DATE,--TimeSent_DATE
                @Ld_Due_DATE,--Due_DATE
                @Ld_Response_DATE,--Response_DATE
                @Lc_Overdue_CODE,--Overdue_CODE
                @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                @Ld_CsenetTranCur_Generated_DATE,--Transaction_DATE
                @Ld_ActionResolution_DATE,--ActionResolution_DATE
                @Lc_Attachments_INDC,--Attachments_INDC
                @Li_CaseData_QNTY,--CaseData_QNTY
                @Li_Ncp_QNTY,--Ncp_QNTY
                @Li_NcpLoc_QNTY,--NcpLoc_QNTY
                @Li_Participant_QNTY,--Participant_QNTY
                @Li_Order_QNTY,--Order_QNTY
                @Li_Collection_QNTY,--Collection_QNTY
                @Li_Info_QNTY,--Info_QNTY
                @Ld_Run_DATE,--End_DATE
                @Lc_CsenetVersion_ID,--CsenetVersion_ID
                @Lc_ErrorReason_CODE,--ErrorReason_CODE
                @Ld_Received_DTTM,--Received_DTTM
                @Lc_RejectReason_CODE,--RejectReason_CODE
                @Ln_Transaction_IDNO,--Transaction_IDNO
                @Lc_ExchangeModeCsenet_TEXT --ExchangeMode_CODE
       );

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'HEADER RECORD NOT INSERTED FOR MESSAGE Seq_IDNO :' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '');
         SET @Li_NextTranPointer_NUMB = 10;
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1';
         SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
          WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
            AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF (@Li_Rowcount_QNTY = 0)
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

           RAISERROR(50001,16,1);
          END;

         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = @Ls_Process_NAME,
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Lc_Job_ID,
          @Ad_Run_DATE                 = @Ld_Run_DATE,
          @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
          @An_Line_NUMB                = 0,
          @Ac_Error_CODE               = @Lc_UpdateFailed_TEXT,
          @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END;
        END;

       SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
      END;

     IF (@Li_NextTranPointer_NUMB = 0)
      BEGIN
       SET @Lb_SkipTran_BIT = 0;
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_SuccessStatusLoad_CODE
        WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
          AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

         RAISERROR(50001,16,1);
        END;
      END;

     IF (@Li_NextTranPointer_NUMB != 0
         AND @Lb_SkipTran_BIT = 1)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'SKIP TRANSACTION: ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
        @An_Line_NUMB                = 0,
        @Ac_Error_CODE               = @Lc_UpdateFailed_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Request_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_CsenetTranCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE Request_IDNO = @Ln_CsenetTranCur_Request_IDNO
          AND Case_IDNO = @Ln_CsenetTranCur_Case_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

         RAISERROR(50001,16,1);
        END;
      END;

     FETCH NEXT FROM CsenetTran_CUR INTO @Ln_CsenetTranCur_Request_IDNO, @Ln_CsenetTranCur_Case_IDNO, @Lc_CsenetTranCur_IVDOutOfStateFips_CODE, @Lc_CsenetTranCur_IVDOutOfStateCountyFips_CODE, @Lc_CsenetTranCur_IVDOutOfStateOfficeFips_CODE, @Lc_CsenetTranCur_IVDOutOfStateCase_ID, @Lc_CsenetTranCur_Function_CODE, @Lc_CsenetTranCur_Action_CODE, @Lc_CsenetTranCur_Reason_CODE, @Lc_CsenetTranCur_CaseFormer_ID, @Lc_CsenetTranCur_Attachment_INDC, @Ld_CsenetTranCur_Generated_DATE, @Lc_CsenetTranCur_OldCsenetTrans_IDNO, @Ls_CsenetTranCur_DescriptionComments_TEXT, @Ld_CsenetTranCur_PfNoShow_DATE, @Ld_CsenetTranCur_Hearing_DATE;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'CsenetTran_CUR') IN (0, 1)
    BEGIN
     CLOSE CsenetTran_CUR;

     DEALLOCATE CsenetTran_CUR;
    END;

   IF @Lb_RowsFoundToday_BIT = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NO PENDING TRANSACTION FOR OUTBOUND TODAY';

     RAISERROR(50001,16,1);
    END;

   -- DELETE EXTRACT ERROR - BEGIN
   SET @Ls_Sql_TEXT = 'DELETE ECBLK_Y1 WHICH ARE MARKED AS ER IN PENDING REQUEST TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusBatchError_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   DELETE ECBLK_Y1
    WHERE TransHeader_IDNO IN (SELECT b.TransHeader_IDNO
                                 FROM CSPR_Y1 a,
                                      ETHBL_Y1 b
                                WHERE a.Request_IDNO = CAST(b.Message_ID AS NUMERIC)
                                  AND a.StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
                                  AND a.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'DELETE EIBLK_Y1 WHICH ARE MARKED AS ER IN PENDING REQUEST TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusBatchError_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   DELETE EIBLK_Y1
    WHERE TransHeader_IDNO IN (SELECT b.TransHeader_IDNO
                                 FROM CSPR_Y1 a,
                                      ETHBL_Y1 b
                                WHERE a.Request_IDNO = CAST(b.Message_ID AS NUMERIC)
                                  AND a.StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
                                  AND a.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'DELETE EOBLK_Y1 WHICH ARE MARKED AS ER IN PENDING REQUEST TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusBatchError_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   DELETE EOBLK_Y1
    WHERE TransHeader_IDNO IN (SELECT b.TransHeader_IDNO
                                 FROM CSPR_Y1 a,
                                      ETHBL_Y1 b
                                WHERE a.Request_IDNO = CAST(b.Message_ID AS NUMERIC)
                                  AND a.StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
                                  AND a.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'DELETE EPBLK_Y1 WHICH ARE MARKED AS ER IN PENDING REQUEST TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusBatchError_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   DELETE EPBLK_Y1
    WHERE TransHeader_IDNO IN (SELECT b.TransHeader_IDNO
                                 FROM CSPR_Y1 a,
                                      ETHBL_Y1 b
                                WHERE a.Request_IDNO = CAST(b.Message_ID AS NUMERIC)
                                  AND a.StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
                                  AND a.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'DELETE ENLBL_Y1 WHICH ARE MARKED AS ER IN PENDING REQUEST TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusBatchError_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   DELETE ENLBL_Y1
    WHERE TransHeader_IDNO IN (SELECT b.TransHeader_IDNO
                                 FROM CSPR_Y1 a,
                                      ETHBL_Y1 b
                                WHERE a.Request_IDNO = CAST(b.Message_ID AS NUMERIC)
                                  AND a.StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
                                  AND a.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'DELETE ENBLK_Y1 WHICH ARE MARKED AS ER IN PENDING REQUEST TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusBatchError_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   DELETE ENBLK_Y1
    WHERE TransHeader_IDNO IN (SELECT b.TransHeader_IDNO
                                 FROM CSPR_Y1 a,
                                      ETHBL_Y1 b
                                WHERE a.Request_IDNO = CAST(b.Message_ID AS NUMERIC)
                                  AND a.StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
                                  AND a.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'DELETE ECDBL_Y1 WHICH ARE MARKED AS ER IN PENDING REQUEST TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusBatchError_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   DELETE ECDBL_Y1
    WHERE TransHeader_IDNO IN (SELECT b.TransHeader_IDNO
                                 FROM CSPR_Y1 a,
                                      ETHBL_Y1 b
                                WHERE a.Request_IDNO = CAST(b.Message_ID AS NUMERIC)
                                  AND a.StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
                                  AND a.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'DELETE ETHBL_Y1 WHICH ARE MARKED AS ER IN PENDING REQUEST TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusBatchError_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   DELETE ETHBL_Y1
    WHERE TransHeader_IDNO IN (SELECT b.TransHeader_IDNO
                                 FROM CSPR_Y1 a,
                                      ETHBL_Y1 b
                                WHERE a.Request_IDNO = CAST(b.Message_ID AS NUMERIC)
                                  AND a.StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
                                  AND a.EndValidity_DATE = @Ld_High_DATE);

   -- DELETE EXTRACT ERROR - END
   SET @Ls_Sql_TEXT = 'TYPE VALIDATION ON EXTRACT TABLES ';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_SuccessStatusLoad_CODE, '');

   EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_TYPE_VALIDATION
    @Ac_StatusRequest_CODE    = @Lc_SuccessStatusLoad_CODE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'VALIDATION ON EXTRACT TABLES - IF VALID RECORDS WILL BE MOVED TO CSENET TABLE';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_SuccessStatusLoad_CODE, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusValidationSuccess_CODE, '');

   EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_VALIDATE
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ac_StatusRequest_CODE    = @Lc_SuccessStatusLoad_CODE,
    @As_Process_NAME          = @Ls_Process_NAME,
    @Ac_Status_CODE           = @Lc_StatusValidationSuccess_CODE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Lc_ReqStatusValiSuccess_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE CSPR_Y1
      SET StatusRequest_CODE = @Lc_ReqStatusSuccessSent_CODE
    WHERE StatusRequest_CODE = @Lc_ReqStatusValiSuccess_CODE
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'CREATE TEMPORARY TABLE ##ExtCsenet_P1';

   CREATE TABLE ##ExtCsenet_P1
    (
      Record_TEXT VARCHAR(MAX)
    );

   SET @Ls_Sql_TEXT = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_EXT_CSENET_TEXT';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '');

   EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_EXT_CSENET_TEXT
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   COMMIT TRANSACTION CSENET_EXT;

   SET @Ls_BcpCommand_TEXT = 'SELECT Record_TEXT FROM ##ExtCsenet_P1';
   SET @Ls_Sql_TEXT='BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@Ls_File_NAME, '') + ', Query_TEXT = ' + ISNULL(@Ls_BcpCommand_TEXT, '');

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_BcpCommand_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtCsenet_P1';

   DROP TABLE ##ExtCsenet_P1;

   -- Begin transaction for BSTL and VPARM
   BEGIN TRANSACTION CSENET_EXT;

   SET @Ls_Sql_TEXT = 'CLOSING ACTIVITY CHAIN';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', BatchRunUser_TEXT = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

   EXECUTE BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INSERT_ALERT
    @Ad_LastRun_DATE          = @Ld_LastRun_DATE,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ac_BatchRunUser_TEXT     = @Lc_BatchRunUser_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_Msg_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END;

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Ls_BatchSuccess_INDC, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_BatchSuccess_INDC, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Li_RecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Ls_BatchSuccess_INDC,
    @As_ListKey_TEXT              = @Ls_BatchSuccess_INDC,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RecordCount_QNTY;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION CSENET_EXT;
    END;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CSENET_EXT;
    END;

   --Drop temporary table if exists
   IF OBJECT_ID('tempdb..##ExtCsenet_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtCsenet_P1;
    END;

   IF CURSOR_STATUS('LOCAL', 'PaperTran_CUR') IN (0, 1)
    BEGIN
     CLOSE PaperTran_CUR;

     DEALLOCATE PaperTran_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'Paper_CUR') IN (0, 1)
    BEGIN
     CLOSE Paper_CUR;

     DEALLOCATE Paper_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'CsenetTran_CUR') IN (0, 1)
    BEGIN
     CLOSE CsenetTran_CUR;

     DEALLOCATE CsenetTran_CUR;
    END;

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = '',
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = 'A',
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
