/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DPR$SP_PROCESS_DPR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
---------------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_LOC_INCOMING_DPR$SP_PROCESS_DPR
Programmer Name   : IMP Team
Description       : The procedure BATCH_LOC_INCOMING_DPR$SP_PROCESS_RESPONSE Process the data received 
					from DPR and loads into table PLIC_Y1 for further processing.
Frequency         : DAILY
Developed On      : 5/6/2011
Called BY         : None
Called On         : BATCH_COMMON$SP_GET_BATCH_DETAILS ,
				    BATCH_COMMON$BATE_LOG,  
				    BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT,
					BATCH_COMMON$SP_ADDRESS_UPDATE,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
					BATCH_COMMON$SP_BATCH_RESTART_UPDATE,
---------------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
---------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DPR$SP_PROCESS_DPR]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Ln_OtherParty_IDNO                NUMERIC = 999999972,
           @Lc_StatusAbnormalend_CODE         CHAR(1) = 'A',
           @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
           @Lc_StatusFailed_CODE              CHAR(1) = 'F',
           @Lc_TypeErrorE_CODE                CHAR(1) = 'E',
           @Lc_ActiveCaseMemberStatus_CODE    CHAR(1) = 'A',
           @Lc_TypeAddress_CODE               CHAR(1) = 'M',
           @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
           @Lc_ProcessY_INDC                  CHAR(1) = 'Y',
           @Lc_TypeCaseNivd_CODE              CHAR(1) = 'H',
           @Lc_ProcessN_INDC                  CHAR(1) = 'N',
           @Lc_CaseRelationshipPutative_CODE  CHAR(1) = 'P',
           @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
           @Lc_StatusCaseOpen_CODE            CHAR(1) = 'O',
           @Lc_StatusCaseClose_CODE           CHAR(1) = 'C',
           @Lc_LicenseStatusActive_CODE       CHAR(1) = 'A',
           @Lc_LicenseStatusInActive_CODE     CHAR(1) = 'I',
           @Lc_LicenseStatus1_CODE            CHAR(1) = '1',
           @Lc_SourceVerifiedA_CODE           CHAR(1) = 'A',
           @Lc_Country_ADDR                   CHAR(2) = 'US',
           @Lc_StateDe_ADDR                   CHAR(2) = 'DE',
           @Lc_Status_CODE                    CHAR(2) = 'P',
           @Lc_RsnStatusCaseUc_CODE           CHAR(2) = 'UC',
           @Lc_RsnStatusCaseUb_CODE           CHAR(2) = 'UB',
           @Lc_SourceVerifiedDpr_CODE		  CHAR(3) = 'DPR',
           @Lc_SourceLocation_CODE            CHAR(3) = 'DPR',
           @Lc_LicenseStatus506_CODE          CHAR(3) = '506',
           @Lc_BatchRunUser_TEXT              CHAR(5) = 'BATCH',
           @Lc_ErrorE0002_CODE                CHAR(5) = 'E0002',
           @Lc_ErrorE1089_CODE                CHAR(5) = 'E1089',
           @Lc_ErrorE0944_CODE                CHAR(5) = 'E0944',
           @Lc_ErrorE0907_CODE                CHAR(5) = 'E0907',
           @Lc_ErrorE0085_CODE                CHAR(5) = 'E0085',
           @Lc_ErrorE1405_CODE                CHAR(5) = 'E1405',
		   @Lc_ErrorE1424_CODE                CHAR(5) = 'E1424',
           @Lc_ErrorE0962_CODE                CHAR(5) = 'E0962',
           @Lc_Job_ID                         CHAR(7) = 'DEB8098',
           @Ls_ParmDateProblem_TEXT           VARCHAR(50) = 'PARM DATE PROBLEM',
           @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_PROCESS_DPR',
           @Ls_Process_NAME                   VARCHAR(100) = 'BATCH_LOC_INCOMING_DPR',
           @Ld_Low_DATE                       DATE = '01/01/0001',
           @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE  @Ln_CommitFreq_QNTY                   NUMERIC(5) = 0,
           @Ln_CommitFreqParm_QNTY               NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY           NUMERIC(5) = 0,
           @Ln_ExceptionThresholdParm_QNTY       NUMERIC(5) = 0,
           @Ln_RestartLine_NUMB                  NUMERIC(5) = 0,
           @Ln_ExcpThreshold_QNTY                NUMERIC(5) = 0,
           @Ln_RowsCount_NUMB                    NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY		 NUMERIC(6) = 0,
           @Ln_MemberSsn_NUMB                    NUMERIC(9) = 0,
           @Ln_RecordCount_NUMB                  NUMERIC(10) = 0,
           @Ln_Count_NUMB                        NUMERIC(10) = 0,
           @Ln_MemberMci_IDNO                    NUMERIC(10) = 0,
           @Ln_ProcessedRecordsCountCommit_QNTY  NUMERIC(11) = 0,
           @Ln_Error_NUMB                        NUMERIC(11) = 0,
           @Ln_ErrorLine_NUMB                    NUMERIC(11) = 0,
           @Ln_Phone_NUMB                        NUMERIC(15) = 0,
           @Ln_TransactionEventSeq_NUMB          NUMERIC(19,0),
           @Li_FetchStatus_QNTY                  SMALLINT,
           @Lc_Note_INDC                         CHAR(1) = '',
           @Lc_Space_TEXT                        CHAR(1) = '',
           @Lc_Profession_CODE                   CHAR(2),
           @Lc_Msg_CODE                          CHAR(5),
           @Lc_BateError_CODE                    CHAR(5),
           @Lc_Attn_ADDR                         CHAR(40) = '',
           @Ls_Sql_TEXT                          VARCHAR(200) = '',
           @Ls_CursorLocation_TEXT               VARCHAR(200),
           @Ls_Sqldata_TEXT                      VARCHAR(1000) = '',
           @Ls_BateRecord_TEXT                   VARCHAR(1000),
           @Ls_DescriptionError_TEXT             VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT                 VARCHAR(4000),
           @Ld_Run_DATE                          DATE,
           @Ld_LastRun_DATE                      DATE,
           @Ld_Start_DATE                        DATETIME2;
  DECLARE  @Ln_DprProcessCur_Seq_IDNO           NUMERIC(19),		   
           @Ls_DprProcessCur_Last_NAME          VARCHAR(50),
           @Ls_DprProcessCur_Line1_ADDR         VARCHAR(50),
           @Ls_DprProcessCur_Line2_ADDR         VARCHAR(50),
           @Lc_DprProcessCur_City_ADDR          CHAR(28),
           @Lc_DprProcessCur_Zip_ADDR           CHAR(15),
           @Lc_DprProcessCur_LicenseNo_TEXT     CHAR(16),
           @Lc_DprProcessCur_MemberSsnNumb_TEXT CHAR(9),
		   @Lc_DprProcessCur_TypeLicence_CODE   CHAR(5),
           @Lc_DprProcessCur_LicenseStatus_CODE CHAR(4),
           @Lc_DprProcessCur_State_ADDR         CHAR(2),
           @Lc_DprProcessCur_Profession_CODE    CHAR(2),           
           @Lc_DprProcessCur_Process_INDC       CHAR(1),
           @Lc_DprProcessCur_Normalization_CODE CHAR(1);
     
  DECLARE DprProcess_CUR INSENSITIVE CURSOR FOR
   SELECT l.Seq_IDNO,
          l.MemberSsn_NUMB,
          l.Last_NAME,
          l.Line1_ADDR,
          l.Line2_ADDR,
          l.City_ADDR,
          l.State_ADDR,
          l.Zip_ADDR,
          l.LicenseNo_TEXT,
          l.LicenseStatus_CODE,
          l.Profession_CODE,
          l.TypeLicense_CODE,
          l.Process_INDC,
          l.Normalization_CODE
     FROM LDPRL_Y1 l
    WHERE l.Process_INDC = @Lc_ProcessN_INDC;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
      
   BEGIN TRANSACTION DPR_PROCESS;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_Lastrun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
   
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Ln_RestartLine_NUMB = CAST (R.RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 R
    WHERE R.Job_ID = @Lc_Job_ID
      AND R.Run_DATE = @Ld_Run_DATE;

   SET @Ln_RowsCount_NUMB = @@ROWCOUNT;

   IF @Ln_RowsCount_NUMB = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;
   
   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveRun_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   DELETE FROM BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN DprProcess_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   OPEN DprProcess_CUR;   

   FETCH NEXT FROM DprProcess_CUR INTO @Ln_DprProcessCur_Seq_IDNO,@Lc_DprProcessCur_MemberSsnNumb_TEXT, @Ls_DprProcessCur_Last_NAME, @Ls_DprProcessCur_Line1_ADDR, @Ls_DprProcessCur_Line2_ADDR, @Lc_DprProcessCur_City_ADDR, @Lc_DprProcessCur_State_ADDR, @Lc_DprProcessCur_Zip_ADDR, @Lc_DprProcessCur_LicenseNo_TEXT, @Lc_DprProcessCur_LicenseStatus_CODE, @Lc_DprProcessCur_Profession_CODE, @Lc_DprProcessCur_TypeLicence_CODE, @Lc_DprProcessCur_Process_INDC, @Lc_DprProcessCur_Normalization_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY = -1
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   --Cursor will process all unprocessed records.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
	 BEGIN TRY
      SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      SAVE TRANSACTION SAVEDPR_PROCESS;	

      SET @Ls_BateRecord_TEXT = 'Sequence IDNO = ' + CAST(@Ln_DprProcessCur_Seq_IDNO AS VARCHAR)+ ', Member SSN = ' + @Lc_DprProcessCur_MemberSsnNumb_TEXT + ', Last_NAME = ' + @Ls_DprProcessCur_Last_NAME + ', Line1_ADDR = ' + @Ls_DprProcessCur_Line1_ADDR + ', Line2_ADDR = ' + @Ls_DprProcessCur_Line2_ADDR + ', City_ADDR = ' + @Lc_DprProcessCur_City_ADDR + ', State_ADDR = ' + @Lc_DprProcessCur_State_ADDR + ', Zip_ADDR = ' + @Lc_DprProcessCur_Zip_ADDR + ', LicenseNo_TEXT = ' + @Lc_DprProcessCur_LicenseNo_TEXT + ', LicenseStatus_CODE = ' + @Lc_DprProcessCur_LicenseStatus_CODE + ', Profession_CODE = ' + @Lc_DprProcessCur_Profession_CODE + ', TypeLicence_CODE = ' + @Lc_DprProcessCur_TypeLicence_CODE + ', Process_INDC = ' + @Lc_DprProcessCur_Process_INDC + ', Normalization_CODE = ' +  @Lc_DprProcessCur_Normalization_CODE;
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ln_RecordCount_NUMB = @Ln_RecordCount_NUMB + 1;

      SET @Ls_CursorLocation_TEXT = 'DPR - CURSOR COUNT - ' + CAST (@Ln_RecordCount_NUMB AS VARCHAR);
      SET @Ln_MemberSsn_NUMB = -1;

	  SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + @Lc_DprProcessCur_MemberSsnNumb_TEXT;

      IF ISNUMERIC(LTRIM(RTRIM(@Lc_DprProcessCur_MemberSsnNumb_TEXT))) = 1
       BEGIN
        SET @Ln_MemberSsn_NUMB = CAST(@Lc_DprProcessCur_MemberSsnNumb_TEXT AS NUMERIC);
       END
                  
      IF EXISTS (SELECT 1
                   FROM DEMO_Y1
                  WHERE MemberSsn_NUMB = @Ln_MemberSsn_NUMB)
       BEGIN
        SET @Ls_Sql_TEXT = 'MEMBERSSN COUNT';
        SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_MemberSsn_NUMB AS VARCHAR), '');

        SELECT @Ln_Count_NUMB = COUNT(1)
          FROM DEMO_Y1 D
         WHERE D.MemberSsn_NUMB = @Ln_MemberSsn_NUMB;
                
        IF @Ln_Count_NUMB > 1
         BEGIN
		  SET @Lc_BateError_CODE = @Lc_ErrorE0962_CODE;

		  RAISERROR (50001,16,1);
         END;	
		ELSE IF @Ln_Count_NUMB = 1
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT DEMO ';
          SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_MemberSsn_NUMB AS VARCHAR), '');
			
          SELECT @Ln_Count_NUMB = COUNT(1)
          FROM DEMO_Y1 D
           WHERE D.MemberSsn_NUMB = @Ln_MemberSsn_NUMB
		     AND LEFT(Last_NAME, 5) = LEFT(@Ls_DprProcessCur_Last_NAME, 5);
		  
		  IF  @Ln_Count_NUMB = 0
		  BEGIN
			SET @Lc_BateError_CODE = @Lc_ErrorE0907_CODE;
	     
	   		RAISERROR (50001,16,1);		    
		  END 
		 ELSE IF @Ln_Count_NUMB = 1
		   BEGIN
			SET @Ln_MemberMci_IDNO = (SELECT MemberMci_IDNO
										FROM DEMO_Y1
									   WHERE MemberSsn_NUMB = @Ln_MemberSsn_NUMB
										 AND LEFT(Last_NAME, 5) = LEFT(@Ls_DprProcessCur_Last_NAME, 5));

	       		IF NOT EXISTS (SELECT 1
                       FROM CASE_Y1 C
                            JOIN CMEM_Y1 M
                             ON C.Case_IDNO = M.Case_IDNO
                            JOIN DEMO_Y1 D
                             ON D.MemberMci_IDNO = M.MemberMci_IDNO
                      WHERE C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                        AND C.TypeCase_CODE <> @Lc_TypeCaseNivd_CODE
                        AND M.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE 
                        AND D.MemberSsn_NUMB = @Ln_MemberSsn_NUMB
                        AND M.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE))
				AND NOT EXISTS (SELECT 1
								   FROM CASE_Y1 C
										JOIN CMEM_Y1 M
										 ON C.CASE_IDNO = M.CASE_IDNO
										JOIN DEMO_Y1 D
										 ON D.MemberMci_IDNO = M.MemberMci_IDNO
								  WHERE C.StatusCase_CODE = @Lc_StatusCaseClose_CODE
									AND M.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE 
									AND C.RsnStatusCase_CODE IN (@Lc_RsnStatusCaseUc_CODE, @Lc_RsnStatusCaseUb_CODE)
									AND M.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
									AND D.MemberSsn_NUMB = @Ln_MemberSsn_NUMB)
					BEGIN
						SET @Lc_BateError_CODE = @Lc_ErrorE1405_CODE;
		
						RAISERROR (50001,16,1);
					END;		 
			END
		 END

		    SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
            SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

            EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
             @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
             @Ac_Process_ID               = @Lc_Job_ID,
             @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
             @Ac_Note_INDC                = @Lc_Note_INDC,
             @An_EventFunctionalSeq_NUMB  = 0,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              RAISERROR ( 50001,16,1);
             END

            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE ';
            SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DprProcessCur_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DprProcessCur_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DprProcessCur_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DprProcessCur_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DprProcessCur_Zip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Phone_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_SourceLocation_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_Status_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedA_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL('0', '') + ', Normalization_CODE = ' + ISNULL(@Lc_DprProcessCur_Normalization_CODE, '');

            EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
             @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
             @Ad_Run_DATE                         = @Ld_Run_DATE,
             @Ac_TypeAddress_CODE                 = @Lc_TypeAddress_CODE,
             @Ad_Begin_DATE                       = @Ld_Run_DATE,
             @Ad_End_DATE                         = @Ld_High_DATE,
             @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
             @As_Line1_ADDR                       = @Ls_DprProcessCur_Line1_ADDR,
             @As_Line2_ADDR                       = @Ls_DprProcessCur_Line2_ADDR,
             @Ac_City_ADDR                        = @Lc_DprProcessCur_City_ADDR,
             @Ac_State_ADDR                       = @Lc_DprProcessCur_State_ADDR,
             @Ac_Zip_ADDR                         = @Lc_DprProcessCur_Zip_ADDR,
             @Ac_Country_ADDR                     = @Lc_Country_ADDR,
             @An_Phone_NUMB                       = @Ln_Phone_NUMB,
             @Ac_SourceLoc_CODE                   = @Lc_SourceLocation_CODE,
             @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
             @Ad_Status_DATE                      = @Ld_Run_DATE,
             @Ac_Status_CODE                      = @Lc_Status_CODE,
             @Ac_SourceVerified_CODE              = @Lc_SourceVerifiedA_CODE,
             @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
             @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
             @Ac_Process_ID                       = @Lc_Job_ID,
             @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
             @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
             @An_OfficeSignedOn_IDNO              = 0,
             @Ac_Normalization_CODE               = @Lc_DprProcessCur_Normalization_CODE,
             @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

		  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		    BEGIN
			  RAISERROR (50001,16,1);
			END 
		  ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE,@Lc_ErrorE1089_CODE)
			BEGIN
			   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
			   SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + RTRIM(CAST(@Ln_MemberSsn_NUMB AS VARCHAR));
			   SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

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
		
            IF @Lc_DprProcessCur_LicenseStatus_CODE NOT IN(@Lc_LicenseStatus1_CODE, @Lc_LicenseStatus506_CODE)
             BEGIN
              SET @Lc_DprProcessCur_LicenseStatus_CODE = @Lc_LicenseStatusInActive_CODE;
             END
            ELSE IF @Lc_DprProcessCur_LicenseStatus_CODE IN(@Lc_LicenseStatus1_CODE, @Lc_LicenseStatus506_CODE)
             BEGIN
              SET @Lc_DprProcessCur_LicenseStatus_CODE = @Lc_LicenseStatusActive_CODE;
             END

            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_LICENSE_UPDATE';
            SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', LicenseNo_TEXT = ' + ISNULL(@Lc_DprProcessCur_LicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_DprProcessCur_TypeLicence_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', LicenseStatus_CODE = ' + ISNULL(@Lc_DprProcessCur_LicenseStatus_CODE, '') + ', IssuingState_CODE = ' + ISNULL(@Lc_StateDe_ADDR, '') + ', IssueLicense_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', ExpireLicense_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', SuspLicense_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerifiedA_CODE, '') + ', Profession_CODE = ' + ISNULL(@Lc_Profession_CODE, '') + ', Business_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Trade_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

            EXECUTE BATCH_COMMON$SP_LICENSE_UPDATE
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ac_LicenseNo_TEXT           = @Lc_DprProcessCur_LicenseNo_TEXT,
             @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
             @Ac_TypeLicense_CODE         = @Lc_DprProcessCur_TypeLicence_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_LicenseStatus_CODE       = @Lc_DprProcessCur_LicenseStatus_CODE,
             @Ac_IssuingState_CODE        = @Lc_StateDe_ADDR,
             @Ad_IssueLicense_DATE        = @Ld_Run_DATE,
             @Ad_ExpireLicense_DATE       = @Ld_High_DATE,
             @Ad_SuspLicense_DATE         = @Ld_Low_DATE,
             @An_OtherParty_IDNO          = @Ln_OtherParty_IDNO,
             @Ac_SourceVerified_CODE      = @Lc_SourceVerifiedDpr_CODE,
             @Ac_Profession_CODE          = @Lc_DprProcessCur_Profession_CODE,
             @As_Business_NAME            = @Lc_Space_TEXT,
             @As_Trade_NAME               = @Lc_Space_TEXT,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_Process_ID               = @Lc_Job_ID,
             @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				BEGIN
				 RAISERROR (50001,16,1);
				END				          
         END    
	END TRY

	BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEDPR_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + SUBSTRING(ERROR_MESSAGE(), 1, 200);

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

       IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_StatusSuccess_CODE, @Lc_Space_TEXT)
        BEGIN
         SET @Lc_Msg_CODE = @Lc_BateError_CODE;
        END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 3';
       SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + RTRIM(CAST(@Ln_MemberSsn_NUMB AS VARCHAR));
       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

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

     SET @Ls_Sql_TEXT = 'UPDATE LDPRL_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(@Lc_DprProcessCur_MemberSsnNumb_TEXT, '');

     UPDATE LDPRL_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_DprProcessCur_Seq_IDNO;

     SET @Ln_RowsCount_NUMB = @@ROWCOUNT;

     IF @Ln_RowsCount_NUMB = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_ErrorE0002_CODE;

       RAISERROR (50001,16,1);
      END

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', RestartKey_TEXT = ' + ISNULL(CAST(@Ln_RecordCount_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_NUMB,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       COMMIT TRANSACTION DPR_PROCESS;

	   SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY + @Ln_CommitFreqParm_QNTY;

       BEGIN TRANSACTION DPR_PROCESS;
       
       SET @Ln_CommitFreq_QNTY = 0;
      
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExcpThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
             
     IF @Ln_ExcpThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN       
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';
	   SET @Ln_ProcessedRecordsCountCommit_QNTY = @Ln_RecordCount_NUMB;
	   COMMIT TRANSACTION DPR_PROCESS;
              
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH DprProcess_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM DprProcess_CUR INTO @Ln_DprProcessCur_Seq_IDNO,@Lc_DprProcessCur_MemberSsnNumb_TEXT, @Ls_DprProcessCur_Last_NAME, @Ls_DprProcessCur_Line1_ADDR, @Ls_DprProcessCur_Line2_ADDR, @Lc_DprProcessCur_City_ADDR, @Lc_DprProcessCur_State_ADDR, @Lc_DprProcessCur_Zip_ADDR, @Lc_DprProcessCur_LicenseNo_TEXT, @Lc_DprProcessCur_LicenseStatus_CODE, @Lc_DprProcessCur_Profession_CODE, @Lc_DprProcessCur_TypeLicence_CODE, @Lc_DprProcessCur_Process_INDC, @Lc_DprProcessCur_Normalization_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END
  
   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

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
   
   CLOSE DprProcess_CUR;

   DEALLOCATE DprProcess_CUR;
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(CAST(@Ln_RecordCount_NUMB AS VARCHAR), '') + ', ExecLocation_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_RecordCount_NUMB AS VARCHAR), '');

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
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_RecordCount_NUMB;

   COMMIT TRANSACTION DPR_PROCESS;
   
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DPR_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'DprProcess_CUR') IN (0, 1)
    BEGIN
     CLOSE DprProcess_CUR;

     DEALLOCATE DprProcess_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
 
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @ls_sql_TEXT,
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
    @As_CursorLocation_TEXT       = @Ln_RecordCount_NUMB,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
