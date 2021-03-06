/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DOR_ADDRESS$SP_PROCESS_DOR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_DOR_ADDRESS$SP_PROCESS_DOR
Programmer Name   :	IMP Team
Description       :	This process will update the address information for the Non-Custodial Parent (NCP) in the system.
Frequency         :	Weekly.
Developed On      :	07/26/2011
Called BY         :	None
Called On		  :	
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DOR_ADDRESS$SP_PROCESS_DOR]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE   CHAR(1) = 'A',
          @Lc_MailingTypeAddress_CODE  CHAR(1) = 'M',
          @Lc_ConGoodStatus_CODE       CHAR(1) = 'Y',
          @Lc_IndNote_TEXT             CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE          CHAR(1) = 'E',
          @Lc_ProcessY_INDC            CHAR(1) = 'Y',
          @Lc_ProcessN_INDC            CHAR(1) = 'N',
          @Lc_Record_ID                CHAR(1) = '2',
          @Lc_SourceVerifiedA_CODE	   CHAR(1) = 'A',
          @Lc_Country_ADDR             CHAR(2) = 'US',
          @Lc_DorSourceLoc_CODE        CHAR(3) = 'DOR',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE          CHAR(5) = 'E0944',
          @Lc_ErrorE0085_CODE          CHAR(5) = 'E0085',
          @Lc_ErrorE0485_CODE          CHAR(5) = 'E0485',
          @Lc_ErrorE0907_CODE          CHAR(5) = 'E0907',
          @Lc_ErrorE1424_CODE          CHAR(5) = 'E1424',
          @Lc_ErrorE1089_CODE          CHAR(5) = 'E1089',
          @Lc_Job_ID                   CHAR(7) = 'DEB8040',
          @Lc_Process_ID               CHAR(7) = 'DEB8040',
          @Lc_Successful_TEXT          CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT             CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Lc_Attn_ADDR                CHAR(40) = ' ',
          @Ls_ParmDateProblem_TEXT     VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME             VARCHAR(100) = 'BATCH_LOC_INCOMING_DOR_ADDRESS',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_PROCESS_DOR',
          @Ls_DescriptionComments_TEXT VARCHAR(1000) = ' ',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                        NUMERIC(1) = 0,
          @Ln_Office_IDNO                      NUMERIC(3) = 0,
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                 NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY      NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY                 NUMERIC(10) = 0,
          @Ln_Error_NUMB                       NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB                   NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB         NUMERIC(18) = 0,
          @Li_FetchStatus_QNTY                 SMALLINT,
          @Li_RowsCount_QNTY                   SMALLINT,
          @Lc_Space_TEXT                       CHAR(1) = '',
          @Lc_Msg_CODE                         CHAR(5) = '',
          @Lc_BateError_CODE                   CHAR(5) = '',
          @Ls_CursorLocation_TEXT              VARCHAR(200) = '',
          @Ls_DescriptionServiceDirection_TEXT VARCHAR(1000) = '',
          @Ls_Sql_TEXT                         VARCHAR(2000) = '',
          @Ls_ErrorMessage_TEXT                VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT            VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT                  VARCHAR(4000) = '',
          @Ls_Sqldata_TEXT                     VARCHAR(5000) = '',
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_DATE                       DATETIME2;
  DECLARE DorAddress_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.Rec_ID,
          a.MemberSsn_NUMB,
          a.Last_NAME,
          a.First_NAME,
          a.MemberMci_IDNO,
          a.Normalization_CODE,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.City_ADDR,
          a.State_ADDR,
          a.Zip_ADDR
     FROM LADOR_Y1 a
    WHERE a.Process_INDC = @Lc_ProcessN_INDC;
  DECLARE @Ln_DorAddressCur_Seq_IDNO           NUMERIC,
          @Lc_DorAddressCur_Rec_ID             CHAR(1),
          @Lc_DorAddressCur_MemberSsnNumb_TEXT CHAR(9),
          @Lc_DorAddressCur_Last_NAME          CHAR(24),
          @Lc_DorAddressCur_First_NAME         CHAR(12),
          @Lc_DorAddressCur_MemberMciIdno_TEXT CHAR(10),
          @Ls_DorAddressCur_Line1_ADDR         VARCHAR(50),
          @Ls_DorAddressCur_Line2_ADDR         VARCHAR(50),
          @Lc_DorAddressCur_City_ADDR          CHAR(28),
          @Lc_DorAddressCur_State_ADDR         CHAR(2),
          @Lc_DorAddressCur_Zip_ADDR           CHAR(15),
          @Lc_DorAddressCur_Normalization_CODE CHAR(1);
  DECLARE @Ln_DorAddressCurMemberSsn_NUMB NUMERIC(9),
          @Ln_DorAddressCurMemberMci_IDNO NUMERIC(9);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

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
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION DORADDRESS_PROCESS;

   SET @Ls_Sql_TEXT = 'OPEN DorAddress_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   OPEN DorAddress_CUR;

   SET @Ls_Sql_TEXT = 'FETCH DorAddress_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   FETCH NEXT FROM DorAddress_CUR INTO @Ln_DorAddressCur_Seq_IDNO, @Lc_DorAddressCur_Rec_ID, @Lc_DorAddressCur_MemberSsnNumb_TEXT, @Lc_DorAddressCur_Last_NAME, @Lc_DorAddressCur_First_NAME, @Lc_DorAddressCur_MemberMciIdno_TEXT, @Lc_DorAddressCur_Normalization_CODE, @Ls_DorAddressCur_Line1_ADDR, @Ls_DorAddressCur_Line2_ADDR, @Lc_DorAddressCur_City_ADDR, @Lc_DorAddressCur_State_ADDR, @Lc_DorAddressCur_Zip_ADDR;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   --Fetch the records.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVEDORADDRESS_PROCESS;

      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      SET @Ls_BateRecord_TEXT = 'Sequence Idno = ' + CAST(@Ln_DorAddressCur_Seq_IDNO AS VARCHAR) + ', Record Id = ' + @Lc_DorAddressCur_Rec_ID + ', Member SSN = ' + @Lc_DorAddressCur_MemberSsnNumb_TEXT + ', Last Name = ' + @Lc_DorAddressCur_Last_NAME + ', First Name = ' + @Lc_DorAddressCur_First_NAME + ', Member MCI IDNO = ' + @Lc_DorAddressCur_MemberMciIdno_TEXT + ', Line 1 Address = ' + @Ls_DorAddressCur_Line1_ADDR + ', Line 2 Address = ' + @Ls_DorAddressCur_Line2_ADDR + ', City Address = ' + @Lc_DorAddressCur_City_ADDR + ', State Address = ' + @Lc_DorAddressCur_State_ADDR + ', Zip Address = ' + @Lc_DorAddressCur_Zip_ADDR + ', Address Normalization Code = ' + @Lc_DorAddressCur_Normalization_CODE;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'DOR ADDRESS - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

      IF @Lc_DorAddressCur_Rec_ID = @Lc_Record_ID
       BEGIN
        IF ISNUMERIC(@Lc_DorAddressCur_MemberSsnNumb_TEXT) = 1
           AND ISNUMERIC(@Lc_DorAddressCur_MemberMciIdno_TEXT) = 1
         BEGIN
          SET @Ln_DorAddressCurMemberSsn_NUMB = CAST(@Lc_DorAddressCur_MemberSsnNumb_TEXT AS NUMERIC);
          SET @Ln_DorAddressCurMemberMci_IDNO = CAST(@Lc_DorAddressCur_MemberMciIdno_TEXT AS NUMERIC);
         END
        ELSE
         BEGIN
          SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

          RAISERROR (50001,16,1);
         END

        IF NOT EXISTS (SELECT 1
                         FROM MSSN_Y1
                        WHERE MemberSsn_NUMB = @Ln_DorAddressCurMemberSsn_NUMB)
            OR @Ln_DorAddressCurMemberSsn_NUMB = 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_ErrorE0485_CODE;

          RAISERROR (50001,16,1);
         END
        ELSE IF NOT EXISTS (SELECT 1
                         FROM DEMO_Y1
                        WHERE LEFT(Last_NAME, 5) = LEFT(@Lc_DorAddressCur_Last_NAME, 5)
                          AND MemberSsn_NUMB = @Ln_DorAddressCurMemberSsn_NUMB
                          AND MemberMci_IDNO = @Ln_DorAddressCurMemberMci_IDNO)
         BEGIN
          SET @Lc_BateError_CODE = @Lc_ErrorE0907_CODE;

          RAISERROR (50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + @Lc_DorAddressCur_MemberMciIdno_TEXT;

        EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Process_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_IndNote_TEXT,
         @An_EventFunctionalSeq_NUMB  = 0,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        IF @Ls_DorAddressCur_Line1_ADDR <> @Lc_Space_TEXT
            OR @Ls_DorAddressCur_Line2_ADDR <> @Lc_Space_TEXT
            OR @Lc_DorAddressCur_City_ADDR <> @Lc_Space_TEXT
            OR @Lc_DorAddressCur_State_ADDR <> @Lc_Space_TEXT
            OR @Lc_DorAddressCur_Zip_ADDR <> @Lc_Space_TEXT
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DorAddressCurMemberMci_IDNO AS VARCHAR), '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + @Lc_MailingTypeAddress_CODE + ', Begin_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '')+ ', End_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', Attn_ADDR = ' + @Lc_Attn_ADDR + ', Line1_ADDR = ' + @Ls_DorAddressCur_Line1_ADDR+ ', Line2_ADDR = ' + @Ls_DorAddressCur_Line2_ADDR + ', City_ADDR = ' + @Lc_DorAddressCur_City_ADDR + ', State_ADDR = ' + @Lc_DorAddressCur_State_ADDR + ', Zip_ADDR = ' + @Lc_DorAddressCur_Zip_ADDR + ', Country_ADDR = ' + @Lc_Country_ADDR + ', Phone_NUMB = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', SourceLoc_CODE = ' + @Lc_DorSourceLoc_CODE + ', SourceReceived_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + @Lc_ConGoodStatus_CODE + ', SourceVerified_CODE = ' + @Lc_SourceVerifiedA_CODE + ', DescriptionComments_TEXT = ' + @Ls_DescriptionComments_TEXT + ', DescriptionServiceDirection_TEXT = ' + @Ls_DescriptionServiceDirection_TEXT + ', Process_ID = ' + @Lc_Process_ID + ', SignedOnWorker_ID = ' + @Lc_BatchRunUser_TEXT + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', OfficeSignedOn_IDNO = ' + CAST(@Ln_Office_IDNO AS VARCHAR) + ', Normalization_CODE = ' + @Lc_DorAddressCur_Normalization_CODE + ', CcrtMemberAddress_CODE = ' + @Lc_Space_TEXT + ', CcrtCaseRelationship_CODE = ' + @Lc_Space_TEXT; 

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_DorAddressCurMemberMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
           @As_Line1_ADDR                       = @Ls_DorAddressCur_Line1_ADDR,
           @As_Line2_ADDR                       = @Ls_DorAddressCur_Line2_ADDR,
           @Ac_City_ADDR                        = @Lc_DorAddressCur_City_ADDR,
           @Ac_State_ADDR                       = @Lc_DorAddressCur_State_ADDR,
           @Ac_Zip_ADDR                         = @Lc_DorAddressCur_Zip_ADDR,
           @Ac_Country_ADDR                     = @Lc_Country_ADDR,
           @An_Phone_NUMB                       = @Ln_Zero_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_DorSourceLoc_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_ConGoodStatus_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
           @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
           @Ac_Process_ID                       = @Lc_Process_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
           @Ac_Normalization_CODE               = @Lc_DorAddressCur_Normalization_CODE,
           @Ac_CcrtMemberAddress_CODE           = @Lc_Space_TEXT,
           @Ac_CcrtCaseRelationship_CODE        = @Lc_Space_TEXT,
           @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_ErrorE1089_CODE)
           BEGIN
            RAISERROR (50001,16,1);
           END
         END
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEDORADDRESS_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

       SET @Ln_Error_NUMB = ERROR_NUMBER ();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', Member SSN = ' + RTRIM(CAST(@Lc_DorAddressCur_MemberSsnNumb_TEXT AS VARCHAR));

       IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_StatusSuccess_CODE, @Lc_Space_TEXT)
        BEGIN
         SET @Lc_Msg_CODE = @Lc_BateError_CODE;
        END

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_Msg_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATE LADOR_Y1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', Seq_IDNO = ' + CAST(@Ln_DorAddressCur_Seq_IDNO AS VARCHAR);

     UPDATE LADOR_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_DorAddressCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', Restart Key = ' + ISNULL (CAST (@Ln_RecordCount_QNTY AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       COMMIT TRANSACTION DORADDRESS_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       BEGIN TRANSACTION DORADDRESS_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;

       COMMIT TRANSACTION DORADDRESS_PROCESS;

       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH NEXT RECORD FROM CURSOR';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM DorAddress_CUR INTO @Ln_DorAddressCur_Seq_IDNO, @Lc_DorAddressCur_Rec_ID, @Lc_DorAddressCur_MemberSsnNumb_TEXT, @Lc_DorAddressCur_Last_NAME, @Lc_DorAddressCur_First_NAME, @Lc_DorAddressCur_MemberMciIdno_TEXT, @Lc_DorAddressCur_Normalization_CODE, @Ls_DorAddressCur_Line1_ADDR, @Ls_DorAddressCur_Line2_ADDR, @Lc_DorAddressCur_City_ADDR, @Lc_DorAddressCur_State_ADDR, @Lc_DorAddressCur_Zip_ADDR;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE DorAddress_CUR;

   DEALLOCATE DorAddress_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run Date = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION DORADDRESS_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DORADDRESS_PROCESS;
    END

   IF CURSOR_STATUS ('local', 'DorAddress_CUR') IN (0, 1)
    BEGIN
     CLOSE DorAddress_CUR;

     DEALLOCATE DorAddress_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
