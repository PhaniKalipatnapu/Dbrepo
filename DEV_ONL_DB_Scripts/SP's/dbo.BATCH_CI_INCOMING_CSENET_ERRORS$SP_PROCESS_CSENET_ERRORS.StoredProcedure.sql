/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_ERRORS$SP_PROCESS_CSENET_ERRORS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_ERRORS$SP_PROCESS_CSENET_ERRORS
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
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_ERRORS$SP_PROCESS_CSENET_ERRORS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_CaseRelationshipNcp_CODE             CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE       CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE          CHAR(1) = 'A',
          @Lc_StatusFailed_CODE                    CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE               CHAR(1) = 'A',
          @Lc_StatusSuccess_CODE                   CHAR(1) = 'S',
          @Lc_No_INDC                              CHAR(1) = 'N',
          @Lc_Yes_INDC                             CHAR(1) = 'Y',
          @Lc_TypeErrorWarning_CODE                CHAR(1) = 'W',
          @Lc_TypeErrorE_CODE                      CHAR(1) = 'E',
          @Lc_Space_TEXT                           CHAR(1) = ' ',
          @Lc_HostError_CODE                       CHAR(2) = 'CE',
          @Lc_SubsystemIn_CODE                     CHAR(3) = 'IN',
          @Lc_MajorActivityCase_CODE               CHAR(4) = 'CASE',
          @Lc_ErrorAddNotSuccessfulE0113_CODE      CHAR(5) = 'E0113',
          @Lc_BateErrorUnknown_CODE                CHAR(5) = 'E1424',
          @Lc_ErrorDuplicateRecordExistsE0145_CODE CHAR(5) = 'E0145',
          @Lc_ErrorE0944_CODE                      CHAR(5) = 'E0944',
          @Lc_BatchRunUser_TEXT                    CHAR(5) = 'BATCH',
          @Lc_ActivityMinorCnher_CODE              CHAR(5) = 'CNHER',
          @Lc_Job_ID                               CHAR(7) = 'DEB0345',
          @Lc_Successful_TEXT                      CHAR(10) = 'SUCCESSFUL',
          @Ls_ErrorE0944_TEXT                      VARCHAR(50) = 'NO RECORDS(S) TO PROCESS',
          @Ls_Procedure_NAME                       VARCHAR(100) = 'SP_PROCESS_CSENET_ERRORS',
          @Ls_Process_NAME                         VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_ERRORS',
          @Ld_High_DATE                            DATE = '12/31/9999';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_Case_IDNO                   NUMERIC(6) = 0,
          @Ln_SeqError_IDNO               NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(6) = 0,
          @Ln_MemberMci_IDNO              NUMERIC(10) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_RecordCount_NUMB            NUMERIC(10) = 0,
          @Ln_RowCount_NUMB               NUMERIC(11) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_TransactionHeader_IDNO      NUMERIC(12) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_BateError_CODE              CHAR(5),
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_BateRecord_TEXT             VARCHAR(1000),
          @Ls_Sqldata_TEXT                VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Transaction_DATE            DATE,
          @Ld_Resolution_DATE             DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ln_CsnetCur_Seq_IDNO               NUMERIC(19),
          @Lc_CsnetCur_Sequence_TEXT          CHAR(5),
          @Lc_CsnetCur_InStateFips_TEXT       CHAR(7),
          @Lc_CsnetCur_IVDOutOfStateFips_TEXT CHAR(7),
          @Lc_CsnetCur_Case_TEXT              CHAR(6),
          @Lc_CsnetCur_IVDOutOfStateCase_TEXT CHAR(15),
          @Lc_CsnetCur_Action_TEXT            CHAR(1),
          @Lc_CsnetCur_Function_TEXT          CHAR(3),
          @Lc_CsnetCur_Reason_TEXT            CHAR(5),
          @Lc_CsnetCur_ActionResolution_TEXT  CHAR(8),
          @Lc_CsnetCur_Transaction_TEXT       CHAR(8),
          @Lc_CsnetCur_Error_TEXT             CHAR(4),
          @Lc_CsnetCur_TransactionSerial_TEXT CHAR(12),
          @Ls_CsnetCur_ErrorMessage_TEXT      VARCHAR(41),
          @Lc_CsnetCur_Process_TEXT           CHAR(1);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT='GET BATCH DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   --Validation: Check whether the Batch already ran for the day        
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END;

   --CURSOR Declaration
   DECLARE Csnet_CUR INSENSITIVE CURSOR FOR
    SELECT l.Seq_IDNO,
           l.Sequence_NUMB,
           l.InStateFips_CODE,
           l.IVDOutOfStateFips_CODE,
           l.Case_IDNO,
           l.IVDOutOfStateCase_ID,
           l.Action_CODE,
           l.Function_CODE,
           l.Reason_CODE,
           l.ActionResolution_DATE,
           l.Transaction_DATE,
           l.Error_CODE,
           l.TransactionSerial_NUMB,
           l.ErrorMessage_TEXT,
           l.Process_INDC
      FROM LCSER_Y1 l
     WHERE l.Process_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = '';

   BEGIN TRANSACTION CNETERRORS_PROCESS;

   SET @Ls_Sql_TEXT = 'OPEN Csnet_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Csnet_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Csnet_CUR-1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Csnet_CUR INTO @Ln_CsnetCur_Seq_IDNO, @Lc_CsnetCur_Sequence_TEXT, @Lc_CsnetCur_InStateFips_TEXT, @Lc_CsnetCur_IVDOutOfStateFips_TEXT, @Lc_CsnetCur_Case_TEXT, @Lc_CsnetCur_IVDOutOfStateCase_TEXT, @Lc_CsnetCur_Action_TEXT, @Lc_CsnetCur_Function_TEXT, @Lc_CsnetCur_Reason_TEXT, @Lc_CsnetCur_ActionResolution_TEXT, @Lc_CsnetCur_Transaction_TEXT, @Lc_CsnetCur_Error_TEXT, @Lc_CsnetCur_TransactionSerial_TEXT, @Ls_CsnetCur_ErrorMessage_TEXT, @Lc_CsnetCur_Process_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --When no records are selected to process.
   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
     SET @Ls_DescriptionError_TEXT = @Ls_ErrorE0944_TEXT;
    END;

   --cursor to fetch records from the load table and insert into cerr_y1 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION SAVECNETERRORS_PROCESS

      SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CsnetCur_Seq_IDNO AS VARCHAR), '') + ', Sequence_NUMB = ' + ISNULL(@Lc_CsnetCur_Sequence_TEXT, '') + ', InStateFips_CODE = ' + ISNULL(@Lc_CsnetCur_InStateFips_TEXT, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_CsnetCur_IVDOutOfStateFips_TEXT, '') + ', Case_IDNO = ' + ISNULL(@Lc_CsnetCur_Case_TEXT, '') + ', IVDOutOfStateCase_ID = ' + ISNULL(@Lc_CsnetCur_IVDOutOfStateCase_TEXT, '') + ', Action_CODE = ' + ISNULL(@Lc_CsnetCur_Action_TEXT, '') + ', Function_CODE = ' + ISNULL(@Lc_CsnetCur_Function_TEXT, '') + ', Reason_CODE = ' + ISNULL(@Lc_CsnetCur_Reason_TEXT, '') + ', ActionResolution_DATE = ' + ISNULL(@Lc_CsnetCur_ActionResolution_TEXT, '') + ', Transaction_DATE = ' + ISNULL(@Lc_CsnetCur_Transaction_TEXT, '') + ', Error_CODE = ' + ISNULL(@Lc_CsnetCur_Error_TEXT, '') + ', TransactionSerial_NUMB = ' + ISNULL(@Lc_CsnetCur_TransactionSerial_TEXT, '') + ', ErrorMessage_TEXT = ' + ISNULL(@Ls_CsnetCur_ErrorMessage_TEXT, '') + ', Process_INDC = ' + ISNULL(@Lc_CsnetCur_Process_TEXT, '');
      SET @Ln_RecordCount_NUMB = @Ln_RecordCount_NUMB + 1;
      SET @Ln_CommitFreq_QNTY= @Ln_CommitFreq_QNTY + 1;
      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
	  SET @Ls_CursorLocation_TEXT ='CSENET ERRORS - CURSOR COUNT - ' + CAST (@Ln_RecordCount_NUMB AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      IF ISDATE (@Lc_CsnetCur_Transaction_TEXT) = 0
          OR ISNUMERIC (@Lc_CsnetCur_Case_TEXT) = 0
          OR ISNUMERIC (@Lc_CsnetCur_Sequence_TEXT) = 0
          OR ISNUMERIC (@Lc_CsnetCur_TransactionSerial_TEXT) = 0
       BEGIN
        SET @Lc_BateError_CODE = 'E0085';
        SET @Ls_DescriptionError_TEXT = 'INVALID VALUE';

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ld_Transaction_DATE = CAST(@Lc_CsnetCur_Transaction_TEXT AS DATE);
        SET @Ln_Case_IDNO = CAST(@Lc_CsnetCur_Case_TEXT AS NUMERIC);
        SET @Ln_SeqError_IDNO = CAST(@Lc_CsnetCur_Sequence_TEXT AS NUMERIC);
        SET @Ln_TransactionHeader_IDNO = CAST(@Lc_CsnetCur_TransactionSerial_TEXT AS NUMERIC);
       END

      SET @Ld_Resolution_DATE = CASE
                                 WHEN ISDATE (@Lc_CsnetCur_ActionResolution_TEXT) = 1
                                  THEN CAST(@Lc_CsnetCur_ActionResolution_TEXT AS DATE)
                                 ELSE @Ld_High_DATE
                                END;
      /* Check if error with OTHER FIPS CODE, TRANSACTION DATE and TRANSACTION SERIAL NUMBER was added to the system.
      	If the error was already processed, write the error E0145 - Duplicate record exists into BATE_Y1 table. Skip record and read the next record */
      SET @Ls_Sql_TEXT = 'CERR_Y1 Record Check';
      SET @Ls_Sqldata_TEXT = '';

      IF EXISTS (SELECT 1
                   FROM CERR_Y1 C
                  WHERE C.SeqError_IDNO = @Ln_SeqError_IDNO
                    AND C.TransHeader_IDNO = @Ln_TransactionHeader_IDNO
                    AND C.Transaction_DATE = @Ld_Transaction_DATE
                    AND C.OtherFips_CODE = @Lc_CsnetCur_IVDOutOfStateFips_TEXT)
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorDuplicateRecordExistsE0145_CODE;
        SET @Ls_DescriptionError_TEXT ='Duplicate Record Exists';

        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'INSERT CERR_Y1 ';
      SET @Ls_Sqldata_TEXT = 'SeqError_IDNO = ' + ISNULL(CAST(@Ln_SeqError_IDNO AS VARCHAR), '') + ', Fips_CODE = ' + ISNULL(@Lc_CsnetCur_InStateFips_TEXT, '') + ', OtherFips_CODE = ' + ISNULL(@Lc_CsnetCur_IVDOutOfStateFips_TEXT, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', OutStateCase_ID = ' + ISNULL(@Lc_CsnetCur_IVDOutOfStateCase_TEXT, '') + ', Action_CODE = ' + ISNULL(@Lc_CsnetCur_Action_TEXT, '') + ', Function_CODE = ' + ISNULL(@Lc_CsnetCur_Function_TEXT, '') + ', Reason_CODE = ' + ISNULL(@Lc_CsnetCur_Reason_TEXT, '') + ', Resolution_DATE = ' + ISNULL(CAST(@Ld_Resolution_DATE AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_Transaction_DATE AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_CsnetCur_Error_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_CsnetCur_ErrorMessage_TEXT, '') + ', ActionTaken_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_TransactionHeader_IDNO AS VARCHAR), '');

      INSERT CERR_Y1
             (SeqError_IDNO,
              Fips_CODE,
              OtherFips_CODE,
              Case_IDNO,
              OutStateCase_ID,
              Action_CODE,
              Function_CODE,
              Reason_CODE,
              Resolution_DATE,
              Transaction_DATE,
              Error_CODE,
              DescriptionError_TEXT,
              ActionTaken_DATE,
              WorkerUpdate_ID,
              Update_DTTM,
              TransHeader_IDNO)
      SELECT @Ln_SeqError_IDNO AS SeqError_IDNO,
             @Lc_CsnetCur_InStateFips_TEXT AS Fips_CODE,
             @Lc_CsnetCur_IVDOutOfStateFips_TEXT AS OtherFips_CODE,
             @Ln_Case_IDNO AS Case_IDNO,
             @Lc_CsnetCur_IVDOutOfStateCase_TEXT AS OutStateCase_ID,
             @Lc_CsnetCur_Action_TEXT AS Action_CODE,
             @Lc_CsnetCur_Function_TEXT AS Function_CODE,
             @Lc_CsnetCur_Reason_TEXT AS Reason_CODE,
             @Ld_Resolution_DATE AS Resolution_DATE,
             @Ld_Transaction_DATE AS Transaction_DATE,
             @Lc_CsnetCur_Error_TEXT AS Error_CODE,
             @Ls_CsnetCur_ErrorMessage_TEXT AS DescriptionError_TEXT,
             @Ld_High_DATE AS ActionTaken_DATE,
             @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
             @Ld_Run_DATE AS Update_DTTM,
             @Ln_TransactionHeader_IDNO AS TransHeader_IDNO;

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;

      IF @Ln_RowCount_NUMB = 0
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'INSERT CERR_Y1 FAILED';

        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1';
      SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_TransactionHeader_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

      UPDATE CSPR_Y1
         SET StatusRequest_CODE = @Lc_HostError_CODE
       WHERE TransHeader_IDNO = @Ln_TransactionHeader_IDNO
         AND EndValidity_DATE = @Ld_High_DATE;

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;

      IF (@Ln_RowCount_NUMB = 0)
       BEGIN
        SET @Lc_TypeErrorE_CODE=@Lc_TypeErrorE_CODE;
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
        SET @Ls_DescriptionError_TEXT = 'UPDATE CSPR_Y1 FAILED';

        RAISERROR(50001,16,1);
       END;

      SET @Ln_MemberMci_IDNO=0;
      SET @Ls_Sql_TEXT = 'SELECT  CMEM_Y1';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '');

      SELECT TOP 1 @Ln_MemberMci_IDNO = a.MemberMci_IDNO
        FROM CMEM_Y1 a
       WHERE a.Case_IDNO = @Ln_Case_IDNO
         AND a.CaseRelationship_CODE IN(@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
         AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       ORDER BY a.CaseRelationship_CODE DESC;

      /* If generation of action alert fails, write the error E0113 - Add not successful into BATE_Y1 table */
      IF @Ln_MemberMci_IDNO = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorAddNotSuccessfulE0113_CODE;
        SET @Ls_DescriptionError_TEXT ='Add Not Successful';

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
      SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '');

      EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_No_INDC,
       @An_EventFunctionalSeq_NUMB = 0,
       @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      /* Generate an action alert to the caseworker equal to IS  Returned CSENet Communication. */
      SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_INSERT_ACTIVITY';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_MajorActivityCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorCnher_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemIn_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @Ln_Case_IDNO,
       @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCnher_CODE,
       @Ac_Subsystem_CODE           = @Lc_SubsystemIn_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Lc_TypeErrorE_CODE = @Lc_TypeErrorE_CODE;
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
       BEGIN
        SET @Lc_TypeErrorE_CODE = @Lc_TypeErrorE_CODE;
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVECNETERRORS_PROCESS
       END
      ELSE
       BEGIN
        SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
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

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
      SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_CsnetCur_Seq_IDNO AS VARCHAR);

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_RecordCount_NUMB,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LCSER_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CsnetCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LCSER_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Seq_IDNO = @Ln_CsnetCur_Seq_IDNO;

     SET @Ln_RowCount_NUMB = @@ROWCOUNT;

     IF @Ln_RowCount_NUMB = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_RowCount_NUMB;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Ln_RowCount_NUMB;

     -- If the commit frequency is attained, Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION CNETERRORS_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;

       BEGIN TRANSACTION CNETERRORS_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_RecordCount_NUMB;

       COMMIT TRANSACTION CNETERRORS_PROCESS;

       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH Csnet_CUR-2';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CsnetCur_Seq_IDNO AS VARCHAR), '');

     FETCH NEXT FROM Csnet_CUR INTO @Ln_CsnetCur_Seq_IDNO, @Lc_CsnetCur_Sequence_TEXT, @Lc_CsnetCur_InStateFips_TEXT, @Lc_CsnetCur_IVDOutOfStateFips_TEXT, @Lc_CsnetCur_Case_TEXT, @Lc_CsnetCur_IVDOutOfStateCase_TEXT, @Lc_CsnetCur_Action_TEXT, @Lc_CsnetCur_Function_TEXT, @Lc_CsnetCur_Reason_TEXT, @Lc_CsnetCur_ActionResolution_TEXT, @Lc_CsnetCur_Transaction_TEXT, @Lc_CsnetCur_Error_TEXT, @Lc_CsnetCur_TransactionSerial_TEXT, @Ls_CsnetCur_ErrorMessage_TEXT, @Lc_CsnetCur_Process_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RecordCount_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_RecordCount_NUMB,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE Csnet_CUR;

   DEALLOCATE Csnet_CUR;

   -- Update the parameter table with the job run date as the current system date 
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE  ';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   --Update the Log in BSTL_Y1 as the Job is suceeded.
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION CNETERRORS_PROCESS;
  END TRY

  --Check if active transaction exists for this session then rollback the transaction
  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CNETERRORS_PROCESS;
    END

   IF CURSOR_STATUS ('local', 'Csnet_CUR') IN (0, 1)
    BEGIN
     CLOSE Csnet_CUR;

     DEALLOCATE Csnet_CUR;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
