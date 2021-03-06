/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_LKCA$SP_PROCESS_FC_LKCA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_EST_INCOMING_FC_LKCA$SP_PROCESS_FC_LKCA 
Programmer Name 	: IMP Team.
Description			: The procedure BATCH_EST_INCOMING_FC_LKCA$SP_PROCESS_FC_LKCA processes the Court Address data received from FAMIS 
					  and makes the appropriate updates on AHIS_Y1, DEMO_Y1, DMNR_Y1 table 
Frequency			: 'DAILY'
Developed On		: 04/28/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_LKCA$SP_PROCESS_FC_LKCA]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_MemberMci595_IDNO        NUMERIC(10) = 999995, --Bug13703
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE   CHAR(1) = 'A',
          @Lc_TypeAddress_CODE         CHAR(1) = 'C',
          @Lc_Status_CODE              CHAR(1) = 'Y',
          @Lc_Note_INDC                CHAR(1) = 'N',
          @Lc_CaseMemberStatusA_CODE   CHAR(1) = 'A',
          @Lc_StatusCaseO_CODE         CHAR(1) = 'O',
          @Lc_UpdateBirthDate_INDC     CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE          CHAR(1) = 'E',
          @Lc_ProcessY_INDC            CHAR(1) = 'Y',
          @Lc_ProcessN_INDC            CHAR(1) = 'N',
          @Lc_Country_ADDR             CHAR(2) = 'US',
          @Lc_SourceVerified_CODE      CHAR(3) = 'T',
          @Lc_SourceLoc_CODE           CHAR(3) = 'FAM',
          @Lc_Subsystem_CODE           CHAR(3) = 'ES',
          @Lc_ActivityMajorCase_CODE   CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO       CHAR(4) = ' ',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Lc_BateErrorE1375_CODE      CHAR(5) = 'E1375',
          @Lc_ActivityMinorLkcau_CODE  CHAR(5) = 'LKCAU',
          @Lc_BateErrorE1424_CODE      CHAR(5) = 'E1424',
          @Lc_BateErrorE0944_CODE      CHAR(5) = 'E0944',
          @Lc_BateErrorE1089_CODE      CHAR(5) = 'E1089',
          @Lc_BateErrorE0026_CODE      CHAR(5) = 'E0026', --Bug13703
          @Lc_Job_ID                   CHAR(7) = 'DEB8051',
          @Lc_Notice_ID                CHAR(8) = NULL,
          @Lc_Process_ID               CHAR(10) = 'BATCH',
          @Lc_Successful_TEXT          CHAR(20) = 'SUCCESSFUL',
          @Lc_BirthCity_NAME           CHAR(28) = NULL,
          --@Lc_WorkerUpdate_ID          CHAR(30) = 'FAMIS', --Bug-13593
          @Lc_ParmDateProblem_TEXT     CHAR(30) = 'PARM DATE PROBLEM',
          @Lc_WorkerDelegate_ID        CHAR(30) = ' ',
          @Lc_Reference_ID             CHAR(30) = ' ',
          @Lc_Attn_ADDR                CHAR(40) = ' ',
          @Ls_Process_NAME             VARCHAR(100) = 'BATCH_EST_INCOMING_FC_LKCA',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_PROCESS_FC_LKCA',
          @Ls_DescriptionComments_TEXT VARCHAR(1000) = ' ',
          @Ls_XmlIn_TEXT               VARCHAR(MAX) = ' ',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                        NUMERIC = 0,
          @Ln_Office_IDNO                      NUMERIC(3) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                 NUMERIC(5),
          @Ln_MajorIntSeq_NUMB                 NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB                 NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_ProcessedRecordCountCommit_QNTY  NUMERIC(6) = 0,
          @Ln_RecordCount_QNTY                 NUMERIC(10) = 0,
          @Ln_TopicIn_IDNO                     NUMERIC(10) = 0,
          @Ln_Schedule_NUMB                    NUMERIC(10) = 0,
          @Ln_Topic_IDNO                       NUMERIC(10),
          @Ln_ErrorLine_NUMB                   NUMERIC(11) = 0,
          @Ln_Error_NUMB                       NUMERIC(11),
          @Ln_Phone_NUMB                       NUMERIC(15) = 0,
          @Ln_TransactionEventSeq_NUMB         NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY                 SMALLINT,
          @Li_RowCount_QNTY                    SMALLINT,
          @Lc_Msg_CODE                         CHAR(5),
          @Lc_BateError_CODE                   CHAR(5),
          @Ls_Sql_TEXT                         VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT              VARCHAR(200),
          @Ls_SqlData_TEXT                     VARCHAR(1000) = '',
          @Ls_DescriptionServiceDirection_TEXT VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT                VARCHAR(2000),
          @Ls_DescriptionError_TEXT            VARCHAR(4000),
          @Ls_BateRecord_TEXT                  VARCHAR(4000),
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_DATE                       DATETIME2;
  DECLARE @Ln_FcLkcaCur_Seq_IDNO               NUMERIC(19) = 0,
          @Lc_FcLkcaCur_MemberMciIdno_TEXT     CHAR(10),
          @Lc_FcLkcaCur_MemberSsnNumb_TEXT     CHAR(9),
          @Lc_FcLkcaCur_BirthDate_TEXT         CHAR(8),
          @Lc_FcLkcaCur_AddrUpdateDate_TEXT    CHAR(8),
          @Lc_FcLkcaCur_NormalizationCode_TEXT CHAR(1),
          @Ls_FcLkcaCur_Line1Addr_TEXT         VARCHAR(50),
          @Ls_FcLkcaCur_Line2Addr_TEXT         VARCHAR(50),
          @Lc_FcLkcaCur_CityAddr_TEXT          CHAR(28),
          @Lc_FcLkcaCur_StateAddr_TEXT         CHAR(2),
          @Lc_FcLkcaCur_ZipAddr_TEXT           CHAR(15),
          @Ln_CaseMemberCur_Case_IDNO          NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO     NUMERIC(10);
  DECLARE @Ln_FcLkcaCur_MemberSsn_NUMB  NUMERIC(9),
          @Ln_FcLkcaCur_MemberMci_IDNO  NUMERIC(10),
          @Ld_FcLkcaCur_Birth_DATE      DATE,
          @Ld_FcLkcaCur_AddrUpdate_DATE DATE;
  DECLARE FcLkca_CUR INSENSITIVE CURSOR FOR
   SELECT A.Seq_IDNO,
          A.MemberMci_IDNO,
          A.MemberSsn_NUMB,
          A.Birth_DATE,
          A.AddrUpdate_DATE,
          A.Normalization_CODE,
          A.Line1_ADDR,
          A.Line2_ADDR,
          A.City_ADDR,
          A.State_ADDR,
          A.Zip_ADDR
     FROM LLKCA_Y1 A
    WHERE A.Process_INDC = @Lc_ProcessN_INDC
    ORDER BY A.Seq_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_FC_LKCA';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TXN_PROCESS_FC_LKCA;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

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
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_SqlData_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK FOR RECORDS TO PROCESS FROM LLKCA_Y1';
   SET @Ls_SqlData_TEXT = '';

   IF EXISTS (SELECT 1
                FROM LLKCA_Y1 A
               WHERE A.Process_INDC = @Lc_ProcessN_INDC)
    BEGIN
     SET @Ls_Sql_TEXT = 'OPEN FcLkca_CUR';
     SET @Ls_SqlData_TEXT = '';

     OPEN FcLkca_CUR;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcLkca_CUR - 1';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM FcLkca_CUR INTO @Ln_FcLkcaCur_Seq_IDNO, @Lc_FcLkcaCur_MemberMciIdno_TEXT, @Lc_FcLkcaCur_MemberSsnNumb_TEXT, @Lc_FcLkcaCur_BirthDate_TEXT, @Lc_FcLkcaCur_AddrUpdateDate_TEXT, @Lc_FcLkcaCur_NormalizationCode_TEXT, @Ls_FcLkcaCur_Line1Addr_TEXT, @Ls_FcLkcaCur_Line2Addr_TEXT, @Lc_FcLkcaCur_CityAddr_TEXT, @Lc_FcLkcaCur_StateAddr_TEXT, @Lc_FcLkcaCur_ZipAddr_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT = 'LOOP THROUGH FcLkca_CUR';
     SET @Ls_SqlData_TEXT = '';

     --Process the Court Address data received from FAMIS and make the appropriate updates in DECSS
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       BEGIN TRY
        SAVE TRANSACTION SAVE_PROCESS_FC_LKCA;

        SET @Lc_UpdateBirthDate_INDC = 'N';
        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
        SET @Ls_ErrorMessage_TEXT = '';
        SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
        SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
        SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
        SET @Ls_CursorLocation_TEXT = 'FcLkca - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
        SET @Ls_BateRecord_TEXT = 'Seq_IDNO = ' + CAST(@Ln_FcLkcaCur_Seq_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + @Lc_FcLkcaCur_MemberMciIdno_TEXT + ', MemberSsn_NUMB = ' + @Lc_FcLkcaCur_MemberSsnNumb_TEXT + ', Birth_DATE = ' + @Lc_FcLkcaCur_BirthDate_TEXT + ', AddrUpdate_DATE = ' + @Lc_FcLkcaCur_AddrUpdateDate_TEXT + ', Normalization_CODE = ' + @Lc_FcLkcaCur_NormalizationCode_TEXT + ', Line1_ADDR = ' + @Ls_FcLkcaCur_Line1Addr_TEXT + ', Line2_ADDR = ' + @Ls_FcLkcaCur_Line2Addr_TEXT + ', City_ADDR = ' + @Lc_FcLkcaCur_CityAddr_TEXT + ', State_ADDR = ' + @Lc_FcLkcaCur_StateAddr_TEXT + ', Zip_ADDR = ' + @Lc_FcLkcaCur_ZipAddr_TEXT;
        SET @Ls_Sql_TEXT = 'CHECK FOR MISSING KEY MEMBER IDENTIFIER';
        SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + @Lc_FcLkcaCur_MemberMciIdno_TEXT + ', MemberSsn_NUMB = ' + @Lc_FcLkcaCur_MemberSsnNumb_TEXT;

        IF ((ISNUMERIC(ISNULL(@Lc_FcLkcaCur_MemberMciIdno_TEXT, '')) = 0
              OR CAST(@Lc_FcLkcaCur_MemberMciIdno_TEXT AS NUMERIC) = 0)
            AND (ISNUMERIC(ISNULL(@Lc_FcLkcaCur_MemberSsnNumb_TEXT, '')) = 0
                  OR CAST(@Lc_FcLkcaCur_MemberSsnNumb_TEXT AS NUMERIC) = 0))
         BEGIN
          SELECT @Lc_BateError_CODE = @Lc_BateErrorE1375_CODE,
                 @Ls_ErrorMessage_TEXT = 'MISSING KEY MEMBER IDENTIFIER - There is no MCI or SSN in the record received from FAMIS';

          RAISERROR(50001,16,1);
         END;
        ELSE IF (ISNUMERIC(ISNULL(@Lc_FcLkcaCur_MemberMciIdno_TEXT, '')) > 0
            AND CAST(@Lc_FcLkcaCur_MemberMciIdno_TEXT AS NUMERIC) > 0)
         BEGIN
          SET @Ln_FcLkcaCur_MemberMci_IDNO = CAST(@Lc_FcLkcaCur_MemberMciIdno_TEXT AS NUMERIC);
          SET @Ls_Sql_TEXT = 'CHECK WHETHER INCOMING MCI EXISTS IN DECSS';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FcLkcaCur_MemberMci_IDNO AS VARCHAR);

          IF NOT EXISTS (SELECT 1
                           FROM CMEM_Y1 A
                          WHERE A.MemberMci_IDNO = @Ln_FcLkcaCur_MemberMci_IDNO
                            AND A.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)
           BEGIN
            SELECT @Lc_BateError_CODE = @Lc_BateErrorE1375_CODE,
                   @Ls_ErrorMessage_TEXT = 'MISSING KEY MEMBER IDENTIFIER - The MCI received in the file does not exist in the DECSS Replacement System';

            RAISERROR(50001,16,1);
           END;
         END;
        ELSE IF (ISNUMERIC(ISNULL(@Lc_FcLkcaCur_MemberSsnNumb_TEXT, '')) > 0
            AND CAST(@Lc_FcLkcaCur_MemberSsnNumb_TEXT AS NUMERIC) > 0)
         BEGIN
          SET @Ln_FcLkcaCur_MemberSsn_NUMB = CAST(@Lc_FcLkcaCur_MemberSsnNumb_TEXT AS NUMERIC);
          SET @Ls_Sql_TEXT = 'CHECK WHETHER INCOMING SSN EXISTS IN DECSS';
          SET @Ls_SqlData_TEXT = 'MemberSsn_NUMB = ' + CAST(@Ln_FcLkcaCur_MemberSsn_NUMB AS VARCHAR);

          IF NOT EXISTS (SELECT 1
                           FROM DEMO_Y1 A
                          WHERE A.MemberSsn_NUMB = @Ln_FcLkcaCur_MemberSsn_NUMB)
           BEGIN
            SELECT @Lc_BateError_CODE = @Lc_BateErrorE1375_CODE,
                   @Ls_ErrorMessage_TEXT = 'MISSING KEY MEMBER IDENTIFIER - When the MCI field is null, the SSN received in the file does not exist in the DECSS Replacement System';

            RAISERROR(50001,16,1);
           END;
          ELSE
           BEGIN
            SET @Ls_Sql_TEXT = 'FIND MCI IN DECSS USING INCOMING SSN';
            SET @Ls_SqlData_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_FcLkcaCur_MemberSsn_NUMB AS VARCHAR), '');

            SELECT TOP 1 @Ln_FcLkcaCur_MemberMci_IDNO = ISNULL(A.MemberMci_IDNO, 0)
              FROM DEMO_Y1 A
                   LEFT OUTER JOIN CMEM_Y1 B
                    ON B.MemberMci_IDNO = A.MemberMci_IDNO
                       AND B.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
             WHERE A.MemberSsn_NUMB = @Ln_FcLkcaCur_MemberSsn_NUMB;

            SET @Ls_Sql_TEXT = 'CHECK WHETHER MCI RETRIEVED FROM DECSS IS ZERO';
            SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FcLkcaCur_MemberMci_IDNO AS VARCHAR);

            IF ISNULL(@Ln_FcLkcaCur_MemberMci_IDNO, 0) = 0
             BEGIN
              SELECT @Lc_BateError_CODE = @Lc_BateErrorE1375_CODE,
                     @Ls_ErrorMessage_TEXT = 'MISSING KEY MEMBER IDENTIFIER - Couldn''t find member''s MCI using the SSN that was provided';

              RAISERROR(50001,16,1);
             END;
           END;
         END;

--Bug13703-ADD-BEGIN
		IF @Ln_FcLkcaCur_MemberMci_IDNO = @Ln_MemberMci595_IDNO
		BEGIN
			SELECT @Lc_BateError_CODE = @Lc_BateErrorE0026_CODE,
				 @Ls_ErrorMessage_TEXT = 'Update not allowed for MCI 999995 - UNIDENTIFIED ABSENT PARENT';

			RAISERROR(50001,16,1);
		END
--Bug13703-ADD-END

        SET @Ls_Sql_TEXT = 'CHECK WHETHER DOB RECEIVED FROM FAMIS IS VALID';
        SET @Ls_SqlData_TEXT = 'Birth_DATE = ' + @Lc_FcLkcaCur_BirthDate_TEXT;

        IF ISDATE(@Lc_FcLkcaCur_BirthDate_TEXT) = 1
           AND CAST(@Lc_FcLkcaCur_BirthDate_TEXT AS DATE) != @Ld_High_DATE
           AND CAST(@Lc_FcLkcaCur_BirthDate_TEXT AS DATE) != CAST('01/01/1900' AS DATE)
         BEGIN
          SET @Ld_FcLkcaCur_Birth_DATE = CAST(@Lc_FcLkcaCur_BirthDate_TEXT AS DATE);
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_DEMO';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcLkcaCur_MemberMci_IDNO AS VARCHAR), '') + ', BirthCity_NAME = ' + ISNULL(@Lc_BirthCity_NAME, '') + ', HomePhone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', CellPhone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', WorkPhone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_FcLkcaCur_Birth_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', Process_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

          EXECUTE BATCH_COMMON$SP_UPDATE_DEMO
           @An_MemberMci_IDNO        = @Ln_FcLkcaCur_MemberMci_IDNO,
           @Ac_BirthCity_NAME        = @Lc_BirthCity_NAME,
           @An_HomePhone_NUMB        = @Ln_Zero_NUMB,
           @An_CellPhone_NUMB        = @Ln_Zero_NUMB,
           @An_WorkPhone_NUMB        = @Ln_Zero_NUMB,
           @Ad_Birth_DATE            = @Ld_FcLkcaCur_Birth_DATE,
           @Ac_Process_ID            = @Lc_Job_ID,
           @Ad_Process_DATE          = @Ld_Run_DATE,
           @Ac_WorkerUpdate_ID       = @Lc_BatchRunUser_TEXT, --Bug-13593
           @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR(50001,16,1);
           END;
         END;

        SET @Ls_Sql_TEXT = 'VALIDATE INCOMING ADDRESS UPDATE DATE';
        SET @Ls_SqlData_TEXT = 'AddrUpdate_DATE = ' + @Lc_FcLkcaCur_AddrUpdateDate_TEXT;

        IF ISDATE(@Lc_FcLkcaCur_AddrUpdateDate_TEXT) = 0
            OR CAST(@Lc_FcLkcaCur_AddrUpdateDate_TEXT AS DATE) = @Ld_High_DATE
            OR CAST(@Lc_FcLkcaCur_AddrUpdateDate_TEXT AS DATE) = CAST('01/01/1900' AS DATE)
         BEGIN
          SET @Ld_FcLkcaCur_AddrUpdate_DATE = @Ld_Run_DATE;
         END;
        ELSE
         BEGIN
          SET @Ld_FcLkcaCur_AddrUpdate_DATE = CAST(@Lc_FcLkcaCur_AddrUpdateDate_TEXT AS DATE);
         END;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE';
        SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcLkcaCur_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_FcLkcaCur_AddrUpdate_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FcLkcaCur_Line1Addr_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Ls_FcLkcaCur_Line2Addr_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_FcLkcaCur_CityAddr_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_FcLkcaCur_StateAddr_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_FcLkcaCur_ZipAddr_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Phone_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_FcLkcaCur_AddrUpdate_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_Status_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerified_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Ls_DescriptionServiceDirection_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_FcLkcaCur_NormalizationCode_TEXT, '');

        IF LEN(LTRIM(RTRIM(ISNULL(@Ls_FcLkcaCur_Line1Addr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_FcLkcaCur_CityAddr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_FcLkcaCur_StateAddr_TEXT, '')))) > 0
            OR LEN(LTRIM(RTRIM(ISNULL(@Lc_FcLkcaCur_ZipAddr_TEXT, '')))) > 0
         BEGIN
          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_FcLkcaCur_MemberMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_TypeAddress_CODE,
           @Ad_Begin_DATE                       = @Ld_FcLkcaCur_AddrUpdate_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
           @As_Line1_ADDR                       = @Ls_FcLkcaCur_Line1Addr_TEXT,
           @As_Line2_ADDR                       = @Ls_FcLkcaCur_Line2Addr_TEXT,
           @Ac_City_ADDR                        = @Lc_FcLkcaCur_CityAddr_TEXT,
           @Ac_State_ADDR                       = @Lc_FcLkcaCur_StateAddr_TEXT,
           @Ac_Zip_ADDR                         = @Lc_FcLkcaCur_ZipAddr_TEXT,
           @Ac_Country_ADDR                     = @Lc_Country_ADDR,
           @An_Phone_NUMB                       = @Ln_Phone_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_SourceLoc_CODE,
           @Ad_SourceReceived_DATE              = @Ld_FcLkcaCur_AddrUpdate_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_Status_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerified_CODE,
           @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
           @Ac_Process_ID                       = @Lc_Job_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
           @Ac_Normalization_CODE               = @Lc_FcLkcaCur_NormalizationCode_TEXT,
           @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE, @Lc_BateErrorE1089_CODE)
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
            SET @Lc_BateError_CODE = @Lc_Msg_CODE;

            RAISERROR (50001,16,1);
           END

          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
          SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
           @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
           @Ac_Process_ID               = @Lc_Job_ID,
           @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
           @Ac_Note_INDC                = @Lc_Note_INDC,
           @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'DECLARE CaseMember_CUR';
          SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_FcLkcaCur_MemberMci_IDNO AS VARCHAR);

          DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
           SELECT A.Case_IDNO,
                  A.MemberMci_IDNO
             FROM CMEM_Y1 A,
                  CASE_Y1 B
            WHERE A.MemberMci_IDNO = @Ln_FcLkcaCur_MemberMci_IDNO
              AND A.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
              AND A.Case_IDNO = B.Case_IDNO
              AND B.StatusCase_CODE = @Lc_StatusCaseO_CODE;

          SET @Ls_Sql_TEXT = 'OPEN CaseMember_CUR';
          SET @Ls_SqlData_TEXT = '';

          OPEN CaseMember_CUR;

          SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 1';
          SET @Ls_SqlData_TEXT = '';

          FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
          SET @Ls_Sql_TEXT = 'LOOP THROUGH CaseMember_CUR';
          SET @Ls_SqlData_TEXT = '';

          --Make a Case Journal Entry for each case of the member...
          WHILE @Li_FetchStatus_QNTY = 0
           BEGIN
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY';
            SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorLkcau_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '');

            EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
             @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
             @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
             @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
             @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorLkcau_CODE,
             @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
             @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
             @Ac_Reference_ID             = @Lc_Reference_ID,
             @Ac_Notice_ID                = @Lc_Notice_ID,
             @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @As_Xml_TEXT                 = @Ls_XmlIn_TEXT,
             @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
             @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
             @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
             @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

              RAISERROR (50001,16,1);
             END;

            SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CaseMember_CUR - 2';
            SET @Ls_SqlData_TEXT = '';

            FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
           END;

          SET @Ls_Sql_TEXT = 'CLOSE CaseMember_CUR';
          SET @Ls_SqlData_TEXT = '';

          CLOSE CaseMember_CUR;

          SET @Ls_Sql_TEXT = 'DEALLOCATE CaseMember_CUR';
          SET @Ls_SqlData_TEXT = '';

          DEALLOCATE CaseMember_CUR;
         END
       END TRY

       BEGIN CATCH
        IF XACT_STATE() = 1
         BEGIN
          ROLLBACK TRANSACTION SAVE_PROCESS_FC_LKCA;
         END
        ELSE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

          RAISERROR(50001,16,1);
         END

        IF CURSOR_STATUS('Local', 'CaseMember_CUR') IN (0, 1)
         BEGIN
          CLOSE CaseMember_CUR;

          DEALLOCATE CaseMember_CUR;
         END;

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
         @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
         @An_Error_NUMB            = @Ln_Error_NUMB,
         @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
        SET @Ls_SqlData_TEXT = '';

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
         @An_Line_NUMB                = @Ln_RecordCount_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
         @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END;

        IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
         BEGIN
          SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
         END
       END CATCH;

       SET @Ls_Sql_TEXT = 'UPDATE LLKCA_Y1';
       SET @Ls_SqlData_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_FcLkcaCur_Seq_IDNO AS VARCHAR), '');

       UPDATE LLKCA_Y1
          SET Process_INDC = @Lc_ProcessY_INDC
        WHERE Seq_IDNO = @Ln_FcLkcaCur_Seq_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE LLKCA_Y1 FAILED';

         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'CHECKING COMMIT FREQUENCY';
       SET @Ls_SqlData_TEXT = 'CommitFreqParm_QNTY = ' + CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR) + ', CommitFreq_QNTY = ' + CAST(@Ln_CommitFreq_QNTY AS VARCHAR);

       IF @Ln_CommitFreq_QNTY <> 0
          AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        BEGIN
         SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_FC_LKCA';
         SET @Ls_SqlData_TEXT = '';

         COMMIT TRANSACTION TXN_PROCESS_FC_LKCA;

         SET @Ls_Sql_TEXT = 'NOTING DOWN PROCESSED RECORD COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
         SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TXN_PROCESS_FC_LKCA';
         SET @Ls_SqlData_TEXT = '';

         BEGIN TRANSACTION TXN_PROCESS_FC_LKCA;

         SET @Ls_Sql_TEXT = 'RESETTING COMMIT FREQUENCY COUNT';
         SET @Ls_SqlData_TEXT = '';
         SET @Ln_CommitFreq_QNTY = 0;
        END;

       SET @Ls_Sql_TEXT = 'CHECKING EXCEPTION THRESHOLD';
       SET @Ls_SqlData_TEXT = 'ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR) + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR);

       IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        BEGIN
         COMMIT TRANSACTION TXN_PROCESS_FC_LKCA;

         SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_RecordCount_QNTY;
         SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

         RAISERROR(50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcLkca_CUR - 2';
       SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

       FETCH NEXT FROM FcLkca_CUR INTO @Ln_FcLkcaCur_Seq_IDNO, @Lc_FcLkcaCur_MemberMciIdno_TEXT, @Lc_FcLkcaCur_MemberSsnNumb_TEXT, @Lc_FcLkcaCur_BirthDate_TEXT, @Lc_FcLkcaCur_AddrUpdateDate_TEXT, @Lc_FcLkcaCur_NormalizationCode_TEXT, @Ls_FcLkcaCur_Line1Addr_TEXT, @Ls_FcLkcaCur_Line2Addr_TEXT, @Lc_FcLkcaCur_CityAddr_TEXT, @Lc_FcLkcaCur_StateAddr_TEXT, @Lc_FcLkcaCur_ZipAddr_TEXT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     SET @Ls_Sql_TEXT = 'CLOSE FcLkca_CUR';
     SET @Ls_SqlData_TEXT = '';

     CLOSE FcLkca_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FcLkca_CUR';
     SET @Ls_SqlData_TEXT = '';

     DEALLOCATE FcLkca_CUR;
    END
   ELSE
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
     SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
     SET @Ls_DescriptionError_TEXT = 'NO RECORD(S) TO PROCESS';
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = '';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

       RAISERROR(50001,16,1);
      END;
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TXN_PROCESS_FC_LKCA';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TXN_PROCESS_FC_LKCA;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION TXN_PROCESS_FC_LKCA;
    END;

   IF CURSOR_STATUS('Local', 'FcLkca_CUR') IN (0, 1)
    BEGIN
     CLOSE FcLkca_CUR;

     DEALLOCATE FcLkca_CUR;
    END;

   IF CURSOR_STATUS('Local', 'CaseMember_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseMember_CUR;

     DEALLOCATE CaseMember_CUR;
    END;

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
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
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
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalEnd_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
