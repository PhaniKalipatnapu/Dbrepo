/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_DOR_ADDRESS$SP_EXTRACT_DOR_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_OUTGOING_DOR_ADDRESS$SP_EXTRACT_DOR_ADDRESS
Programmer Name 	: IMP Team
Description			: This process extracts all NCP's on the system for locate match against DOR database.
Frequency			: 'WEEKLY'
Developed On		: 07/22/2011
Called BY			: None
Called On			: BATCH_COMMON$SP_GET_BATCH_DETAILS2 
					  BATCH_COMMON$SP_UPDATE_PARM_DATE
					  BATCH_COMMON$SP_BATE_LOG
					  BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 0.01 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_DOR_ADDRESS$SP_EXTRACT_DOR_ADDRESS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Increment_NUMB				NUMERIC(1) = 1,
		  @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_No_INDC                       CHAR(1) = 'N',
          @Lc_TypeErrorWarning_CODE         CHAR(1) = 'W',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_StatusCaseOpen_CODE           CHAR(1) = 'O',
          @Lc_TypeCaseNonIvd_CODE           CHAR(1) = 'H',
          @Lc_StatusNonLocate_CODE          CHAR(1) = 'N',
          @Lc_CaseMemberActiveStatus_CODE   CHAR(1) = 'A',
          @Lc_EnumerationConfirmedGood_CODE CHAR(1) = 'Y',
          @Lc_SsnTypePrimary_CODE           CHAR(1) = 'P',
          @Lc_SsnTypeItin_CODE              CHAR(1) = 'I',
          @Lc_SsnTypeSecondary_CODE         CHAR(1) = 'S',
          @Lc_SsnTypeTertiary_CODE          CHAR(1) = 'T',
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',
          @Lc_RecordHeader_CODE             CHAR(1) = 'H',
          @Lc_SsnPrefix_CODE                CHAR(1) = '2',
          @Lc_RecordTrailer_CODE            CHAR(1) = 'T',
          @Lc_ReasonStatusBi_CODE			CHAR(2) = 'BI',
          @Lc_ReasonStatusSy_CODE           CHAR(2) = 'SY',
          @Lc_SubsystemLocate_CODE          CHAR(2) = 'LO',
          @Lc_ActivityMajorCase_CODE        CHAR(4) = 'CASE',
          @Lc_StatusComp_CODE               CHAR(4) = 'COMP',
          @Lc_StatusStrt_CODE               CHAR(4) = 'STRT',
          @Lc_ActivityMinorStdor_CODE       CHAR(5) = 'STDOR',
          @Lc_Job_ID                        CHAR(7) = 'DEB8079',
          @Lc_ErrorE0944_CODE               CHAR(18) = 'E0944',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT             CHAR(30) = 'BATCH',
          @Ls_ParmDateProblem_TEXT          VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_LOC_OUTGOING_DOR_ADDRESS',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_EXTRACT_DOR_ADDRESS',
          @Ld_Low_DATE                      DATE = '01/01/0001',
          @Ld_High_DATE                     DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(18) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO              NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1) = '',
          @Ls_File_NAME                   VARCHAR(50) = '',
          @Ls_FileLocation_TEXT           VARCHAR(80) = '',
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_Query_TEXT                  VARCHAR(1000) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
          
  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractAddressDor_P1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractAddressDor_P1
    (
      Record_TEXT VARCHAR(60)
    );

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION OUTGOING_DOR;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID;

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
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = ' RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DELETE EADOR_Y1';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE EADOR_Y1;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERT INTO EADOR_Y1';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT EADOR_Y1
          (MemberSsn_NUMB,
           Last_NAME,
           First_NAME,
           MemberMci_IDNO)
   SELECT DISTINCT
          CONVERT(VARCHAR(9), s.MemberSsn_NUMB),
          SUBSTRING(d.Last_NAME, 1, 24),
          SUBSTRING(d.First_NAME, 1, 12),
          CONVERT(VARCHAR(10), d.MemberMci_IDNO)
     FROM MSSN_Y1 s
          JOIN DEMO_Y1 d
           ON s.MemberMci_IDNO = d.MemberMci_IDNO
          JOIN LSTT_Y1 l
           ON d.MemberMci_IDNO = l.MemberMci_IDNO
          JOIN CMEM_Y1 c
           ON d.MemberMci_IDNO = c.MemberMci_IDNO
          JOIN CASE_Y1 cs
           ON cs.CASE_IDNO = c.CASE_IDNO
    WHERE cs.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
      AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND cs.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND s.Enumeration_CODE = @Lc_EnumerationConfirmedGood_CODE
      AND s.TypePrimary_CODE = @Lc_SsnTypePrimary_CODE
      AND s.EndValidity_DATE = @Ld_High_DATE
      AND l.StatusLocate_CODE = @Lc_StatusNonLocate_CODE
      AND l.EndValidity_DATE = @Ld_High_DATE
   UNION
   SELECT DISTINCT
          CONVERT(VARCHAR(9), s.MemberSsn_NUMB),
          SUBSTRING(d.Last_NAME, 1, 24),
          SUBSTRING(d.First_NAME, 1, 12),
          CONVERT(VARCHAR(10), d.MemberMci_IDNO)
     FROM MSSN_Y1 s
          JOIN DEMO_Y1 d
           ON s.MemberMci_IDNO = d.MemberMci_IDNO
          JOIN LSTT_Y1 l
           ON d.MemberMci_IDNO = l.MemberMci_IDNO
          JOIN CMEM_Y1 c
           ON d.MemberMci_IDNO = c.MemberMci_IDNO
          JOIN CASE_Y1 cs
           ON cs.CASE_IDNO = c.CASE_IDNO
    WHERE cs.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
      AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND cs.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND s.Enumeration_CODE = @Lc_EnumerationConfirmedGood_CODE
      AND s.TypePrimary_CODE = @Lc_SsnTypeSecondary_CODE
      AND s.EndValidity_DATE = @Ld_High_DATE
      AND l.StatusLocate_CODE = @Lc_StatusNonLocate_CODE
      AND l.EndValidity_DATE = @Ld_High_DATE
      AND s.MemberMci_IDNO NOT IN (SELECT MemberMci_IDNO
                                     FROM MSSN_Y1 y
                                    WHERE y.Enumeration_CODE = @Lc_EnumerationConfirmedGood_CODE
                                      AND y.TypePrimary_CODE IN (@Lc_SsnTypePrimary_CODE)
                                      AND y.EndValidity_DATE = @Ld_High_DATE)
   UNION
   SELECT DISTINCT
          CONVERT(VARCHAR(9), s.MemberSsn_NUMB),
          SUBSTRING(d.Last_NAME, 1, 24),
          SUBSTRING(d.First_NAME, 1, 12),
          CONVERT(VARCHAR(10), d.MemberMci_IDNO)
     FROM MSSN_Y1 s
          JOIN DEMO_Y1 d
           ON s.MemberMci_IDNO = d.MemberMci_IDNO
          JOIN LSTT_Y1 l
           ON d.MemberMci_IDNO = l.MemberMci_IDNO
          JOIN CMEM_Y1 c
           ON d.MemberMci_IDNO = c.MemberMci_IDNO
          JOIN CASE_Y1 cs
           ON cs.CASE_IDNO = c.CASE_IDNO
    WHERE cs.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
      AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND cs.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND s.Enumeration_CODE = @Lc_EnumerationConfirmedGood_CODE
      AND s.TypePrimary_CODE = @Lc_SsnTypeTertiary_CODE
      AND s.EndValidity_DATE = @Ld_High_DATE
      AND l.StatusLocate_CODE = @Lc_StatusNonLocate_CODE
      AND l.EndValidity_DATE = @Ld_High_DATE
      AND s.MemberMci_IDNO NOT IN (SELECT MemberMci_IDNO
                                     FROM MSSN_Y1 y
                                    WHERE y.Enumeration_CODE = @Lc_EnumerationConfirmedGood_CODE
                                      AND y.TypePrimary_CODE IN (@Lc_SsnTypePrimary_CODE, @Lc_SsnTypeSecondary_CODE)
                                      AND y.EndValidity_DATE = @Ld_High_DATE)
   UNION
   SELECT DISTINCT
          CONVERT(VARCHAR(9), s.MemberSsn_NUMB),
          SUBSTRING(d.Last_NAME, 1, 24),
          SUBSTRING(d.First_NAME, 1, 12),
          CONVERT(VARCHAR(10), d.MemberMci_IDNO)
     FROM MSSN_Y1 s
          JOIN DEMO_Y1 d
           ON s.MemberMci_IDNO = d.MemberMci_IDNO
          JOIN LSTT_Y1 l
           ON d.MemberMci_IDNO = l.MemberMci_IDNO
          JOIN CMEM_Y1 c
           ON d.MemberMci_IDNO = c.MemberMci_IDNO
          JOIN CASE_Y1 cs
           ON cs.CASE_IDNO = c.CASE_IDNO
    WHERE cs.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
      AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND cs.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND s.Enumeration_CODE = @Lc_EnumerationConfirmedGood_CODE
      AND s.TypePrimary_CODE = @Lc_SsnTypeItin_CODE
      AND s.EndValidity_DATE = @Ld_High_DATE
      AND l.StatusLocate_CODE = @Lc_StatusNonLocate_CODE
      AND l.EndValidity_DATE = @Ld_High_DATE
      AND s.MemberMci_IDNO NOT IN (SELECT MemberMci_IDNO
                                     FROM MSSN_Y1 y
                                    WHERE y.Enumeration_CODE = @Lc_EnumerationConfirmedGood_CODE
                                      AND y.TypePrimary_CODE IN (@Lc_SsnTypePrimary_CODE, @Lc_SsnTypeSecondary_CODE, @Lc_SsnTypeTertiary_CODE)
                                      AND y.EndValidity_DATE = @Ld_High_DATE);

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM EADOR_Y1 a);

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO EXTRACT';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
		   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT FOR ACTIVITY';
		   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'');

		   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
			@Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
			@Ac_Process_ID               = @Lc_Job_ID,
			@Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
			@Ac_Note_INDC                = @Lc_No_INDC,
			@An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
			@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

		   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR (50001,16,1);
			END;
			
			SET @Ls_Sql_TEXT = 'INSERT DMJR_Y1';
			SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemLocate_CODE,'')+ ', TypeOthpSource_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Entered_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Status_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE,'')+ ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusBi_CODE,'')+ ', BeginExempt_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', EndExempt_DATE = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', UserLastPoster_ID = ' + ISNULL(@Lc_Space_TEXT,'')+ ', SubjectLastPoster_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', LastPost_DTTM = ' + ISNULL(CAST( @Ld_Low_DATE AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', Update_DTTM = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', TypeReference_CODE = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Reference_ID = ' + ISNULL(@Lc_Space_TEXT,'');
			
			   INSERT DMJR_Y1
					  (Case_IDNO,
					   OrderSeq_NUMB,
					   MajorIntSEQ_NUMB,
					   MemberMci_IDNO,
					   ActivityMajor_CODE,
					   Subsystem_CODE,
					   TypeOthpSource_CODE,
					   OthpSource_IDNO,
					   Entered_DATE,
					   Status_DATE,
					   Status_CODE,
					   ReasonStatus_CODE,
					   BeginExempt_DATE,
					   EndExempt_DATE,
					   TotalTopics_QNTY,
					   PostLastPoster_IDNO,
					   UserLastPoster_ID,
					   SubjectLastPoster_TEXT,
					   LastPost_DTTM,
					   BeginValidity_DATE,
					   WorkerUpdate_ID,
					   Update_DTTM,
					   TransactionEventSeq_NUMB,
					   TypeReference_CODE,
					   Reference_ID)
			   SELECT DISTINCT B.Case_IDNO, 
					  0 AS OrderSeq_NUMB,
					  (SELECT ISNULL(MAX(c.MajorIntSEQ_NUMB), 0) + @Ln_Increment_NUMB
						 FROM DMJR_Y1 c
						WHERE c.Case_IDNO = b.Case_IDNO) AS MajorIntSEQ_NUMB,
					  0 AS MemberMci_IDNO, 
					  @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
					  @Lc_SubsystemLocate_CODE AS Subsystem_CODE,
					  @Lc_Space_TEXT AS TypeOthpSource_CODE,
					  0 AS OthpSource_IDNO,
					  @Ld_Run_DATE AS Entered_DATE,
					  @Ld_High_DATE AS Status_DATE,
					  @Lc_StatusStrt_CODE AS Status_CODE,
					  @Lc_ReasonStatusBi_CODE AS ReasonStatus_CODE,
					  @Ld_Low_DATE AS BeginExempt_DATE,
					  @Ld_Low_DATE AS EndExempt_DATE,
					  0 AS TotalTopics_QNTY,
					  0 AS PostLastPoster_IDNO,
					  @Lc_Space_TEXT AS UserLastPoster_ID,
					  @Lc_Space_TEXT AS SubjectLastPoster_TEXT,
					  @Ld_Low_DATE AS LastPost_DTTM,
					  @Ld_Run_DATE AS BeginValidity_DATE,
					  @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
					  @Ld_Start_DATE AS Update_DTTM,
					  @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
					  @Lc_Space_TEXT AS TypeReference_CODE,
					  @Lc_Space_TEXT AS Reference_ID
				FROM EADOR_Y1 a,
					 CMEM_Y1 b
			   WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
				  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE ,@Lc_CaseRelationshipPutative_CODE)
				  AND b.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE			   
				  AND NOT EXISTS (SELECT 1
									FROM DMJR_Y1 d
								   WHERE b.Case_IDNO = d.Case_IDNO
									 AND d.Subsystem_CODE = @Lc_SubsystemLocate_CODE
									 AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
									 AND d.Status_CODE = @Lc_StatusStrt_CODE);

   SET @Ls_Sql_TEXT = 'GET THE MAX OF TOPIC IDNO FROM ITOPC_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);		

   SELECT @Ln_SeqUnique_IDNO = ISNULL(MAX(a.Seq_IDNO), 0) 
     FROM ITOPC_Y1 a;
  
  IF @Ln_SeqUnique_IDNO = 0 
   BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT ITOPC_Y1';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);   
	   
	   INSERT INTO ITOPC_Y1
				   (Entered_DATE)
			VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()--Entered_DATE
	   );   

	   SET @Ls_Sql_TEXT = 'GET THE MAX OF TOPIC IDNO FROM ITOPC_Y1 - 2';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
	   
       SELECT @Ln_SeqUnique_IDNO = ISNULL(MAX(a.Seq_IDNO), 0) 
		 FROM ITOPC_Y1 a;	   

   END 

	   SET @Ls_Sql_TEXT = 'INSERT DMNR_Y1';
	   SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', ActivityMinorStfdm_CODE = '+ @Lc_ActivityMinorStdor_CODE + ', Run_DATE = '+ CAST( @Ld_Run_DATE  AS VARCHAR)+ ', StatusComplete_CODE = '+ @Lc_StatusComp_CODE  +', ReasonStatusSy_CODE = '+@Lc_ReasonStatusSy_CODE +', BatchRunUser_TEXT = '+ @Lc_BatchRunUser_TEXT +', SubsystemLo_CODE = '+@Lc_SubsystemLocate_CODE  + ', ActivityMajorCase_CODE = '+ @Lc_ActivityMajorCase_CODE +', StatusStart_CODE = '+ @Lc_StatusStrt_CODE;
	
		WITH BulkInsert_DmnrItopc
		AS (	
			   SELECT b.Case_IDNO AS Case_IDNO,
						  0 AS OrderSeq_NUMB,
						  d.MajorIntSEQ_NUMB AS MajorIntSEQ_NUMB,
						  ISNULL((SELECT MAX(x.MinorIntSeq_NUMB)
									FROM UDMNR_V1 x
								   WHERE d.Case_IDNO = x.Case_IDNO
									 AND d.MajorIntSEQ_NUMB = x.MajorIntSEQ_NUMB), 0) + ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO ORDER BY b.Case_IDNO) AS MinorIntSeq_NUMB,
						  b.MemberMci_IDNO AS MemberMci_IDNO,
						  @Lc_ActivityMinorStdor_CODE AS ActivityMinor_CODE,
						  @Lc_Space_TEXT AS ActivityMinorNext_CODE,
						  @Ld_Run_DATE AS Entered_DATE,
						  @Ld_Run_DATE AS Due_DATE,
						  @Ld_Run_DATE AS Status_DATE,
						  @Lc_StatusComp_CODE AS Status_CODE,
						  @Lc_ReasonStatusSy_CODE AS ReasonStatus_CODE,
						  0 AS Schedule_NUMB,
						  d.Forum_IDNO,
						  0 AS NoTotalReplies_QNTY,
						  0 AS NoTotalViews_QNTY,
						  0 AS PostLastPoster_IDNO,
						  @Lc_BatchRunUser_TEXT AS UserLastPoster_ID,
						  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS LastPost_DTTM,
						  @Ld_Run_DATE AS AlertPrior_DATE,
						  @Ld_Run_DATE AS BeginValidity_DATE,
						  @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
						  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
						  @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
						  @Lc_Space_TEXT AS WorkerDelegate_ID,
						  0 AS UssoSeq_NUMB,
						  @Lc_SubsystemLocate_CODE AS Subsystem_CODE,
						  @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE
					 FROM EADOR_Y1 a,
						  CMEM_Y1 b,
						  DMJR_Y1 d
					WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
					  AND b.Case_IDNO = d.Case_IDNO
					  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE ,@Lc_CaseRelationshipPutative_CODE)
					  AND b.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE						  
					  AND d.Subsystem_CODE = @Lc_SubsystemLocate_CODE
					  AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
					  AND d.Status_CODE = @Lc_StatusStrt_CODE
					)
			   INSERT INTO DMNR_Y1
					  (Case_IDNO,
					   OrderSeq_NUMB,
					   MajorIntSEQ_NUMB,
					   MinorIntSeq_NUMB,
					   MemberMci_IDNO,
					   ActivityMinor_CODE,
					   ActivityMinorNext_CODE,
					   Entered_DATE,
					   Due_DATE,
					   Status_DATE,
					   Status_CODE,
					   ReasonStatus_CODE,
					   Schedule_NUMB,
					   Forum_IDNO,
					   Topic_IDNO,
					   TotalReplies_QNTY,
					   TotalViews_QNTY,
					   PostLastPoster_IDNO,
					   UserLastPoster_ID,
					   LastPost_DTTM,
					   AlertPrior_DATE,
					   BeginValidity_DATE,
					   WorkerUpdate_ID,
					   Update_DTTM,
					   TransactionEventSeq_NUMB,
					   WorkerDelegate_ID,
					   Subsystem_CODE,
					   ActivityMajor_CODE)		
	        OUTPUT @Ld_Run_DATE
			INTO ITOPC_Y1   
			SELECT Case_IDNO,
			OrderSeq_NUMB,
			MajorIntSEQ_NUMB,
			MinorIntSeq_NUMB,
			MemberMci_IDNO,
			ActivityMinor_CODE,
			ActivityMinorNext_CODE,
			Entered_DATE,
			Due_DATE,
			Status_DATE,
			Status_CODE,
			ReasonStatus_CODE,
			Schedule_NUMB,
			Forum_IDNO,
			@Ln_SeqUnique_IDNO + (ROW_NUMBER() OVER( ORDER BY TransactionEventSeq_NUMB)) AS Topic_IDNO,
			NoTotalReplies_QNTY,
			NoTotalViews_QNTY,
			PostLastPoster_IDNO,
			UserLastPoster_ID,
			LastPost_DTTM,
			AlertPrior_DATE,
			BeginValidity_DATE,
			WorkerUpdate_ID,	
			Update_DTTM,
			TransactionEventSeq_NUMB,
			WorkerDelegate_ID,
			Subsystem_CODE,
			ActivityMajor_CODE
			FROM BulkInsert_DmnrItopc
		           
	  END	
	  
   SET @Ls_Sql_TEXT = 'INSERT Header Record';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractAddressDor_P1
               (Record_TEXT)
   SELECT @Lc_RecordHeader_CODE + CONVERT(VARCHAR, @Ld_Run_DATE, 112) + REPLICATE(@Lc_Space_TEXT, 51) AS Record_TEXT;

   SET @Ls_Sql_TEXT = 'Insert Detail Record';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractAddressDor_P1
               (Record_TEXT)
   SELECT @Lc_SsnPrefix_CODE + RIGHT(('000000000' + LTRIM(RTRIM(a.MemberSsn_NUMB))), 9) + CONVERT(CHAR(24), A.Last_NAME) + CONVERT(CHAR(12), a.First_NAME) + RIGHT(('0000000000' + LTRIM(RTRIM(a.MemberMci_IDNO))), 10) + REPLICATE(@Lc_Space_TEXT, 4) AS Record_TEXT
     FROM EADOR_Y1 a;

   SET @Ls_Sql_TEXT = 'INSERT TRAILER RECORD';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractAddressDor_P1
               (Record_TEXT)
   SELECT @Lc_RecordTrailer_CODE + CONVERT(VARCHAR, @Ld_Run_DATE, 112) + RIGHT(('00000000' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR)), 8) + REPLICATE(@Lc_Space_TEXT, 43) AS Record_TEXT;
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION OUTGOING_DOR;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractAddressDor_P1 ';
   SET @Ls_Sql_TEXT = 'Extract Data';
   SET @Ls_Sqldata_TEXT ='FILE Location = ' + @Ls_FileLocation_TEXT + ', Ls_File_NAME = ' + @Ls_File_NAME + ', Query TEXT = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   BEGIN TRANSACTION OUTGOING_DOR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractAddressDor_P1 - 2';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE ##ExtractAddressDor_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION OUTGOING_DOR;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_DOR;
    END;

   IF OBJECT_ID('tempdb..##ExtractAddressDor_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractAddressDor_P1;
    END

   IF CURSOR_STATUS ('LOCAL', 'CaseMember_Cur') IN (0, 1)
    BEGIN
     CLOSE CaseMember_Cur;

     DEALLOCATE CaseMember_Cur;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
