/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_SPRINT$SP_EXTRACT_SPRINT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_OUTGOING_SPRINT$SP_EXTRACT_SPRINT
Programmer Name 	: IMP Team
Description			: This process extracts DACSES NCP's data to create locate requests to Sprint wireless.
Frequency			: 'QUATERLY'
Developed On		: 10/18/2011
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
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_SPRINT$SP_EXTRACT_SPRINT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Increment_NUMB				NUMERIC(1) = 1,
          @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_TypeErrorWarning_CODE         CHAR(1) = 'W',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_StatusCaseOpen_CODE           CHAR(1) = 'O',
          @Lc_No_INDC                       CHAR(1) = 'N',
          @Lc_StatusNonLocate_CODE          CHAR(1) = 'N',
          @Lc_MemberActiveStatus_CODE		CHAR(1) = 'A',
          @Lc_RespondInitResponding_CODE    CHAR(1) = 'R',
          @Lc_RespondInitInState_CODE       CHAR(1) = 'N',
          @Lc_TribalResponding_CODE			CHAR(1) = 'S',
          @Lc_InternationalResponding_CODE  CHAR(1) = 'Y',          
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE       CHAR(1) = 'C',
          @Lc_StatusConfirmedGood_CODE      CHAR(1) = 'Y',
          @Lc_TypeAddressMailing_CODE       CHAR(1) = 'M',
          @Lc_StatusReceiptHold_CODE        CHAR(1) = 'H',
          @Lc_TypeCaseNonIvd_CODE           CHAR(1) = 'H',
          @Lc_CheckRecipientNcpCp_CODE      CHAR(1) = '1',
          @Lc_CaseCategoryPt_CODE           CHAR(2) = 'PT',
          @Lc_SubsystemLocate_CODE			CHAR(2) = 'LO',
          @Lc_ReasonStatusBi_CODE			CHAR(2) = 'BI',
          @Lc_ReasonStatusSy_CODE			CHAR(2) = 'SY',
		  @Lc_ReasonOnHoldSdca_CODE         CHAR(4) = 'SDCA',
          @Lc_ReasonOnHoldSdna_CODE         CHAR(4) = 'SDNA',
          @Lc_ActivityMajorCase_CODE		CHAR(4)	= 'CASE',
          @Lc_StatusComp_CODE               CHAR(4) = 'COMP',
          @Lc_StatusStrt_CODE               CHAR(4) = 'STRT',
          @Lc_ActivityMinorStfpu_CODE       CHAR(5) = 'STFPU',
          @Lc_Job_ID                        CHAR(7) = 'DEB8094',
          @Lc_ErrorE0944_CODE               CHAR(18) = 'E0944',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_UserBatch_TEXT                CHAR(30) = 'BATCH',
          @Ls_ParmDateProblem_TEXT          VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_LOC_OUTGOING_SPRINT',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_EXTRACT_SPRINT',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Ld_Low_DATE                      DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO              NUMERIC(19) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
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
   SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractSprint_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractSprint_P1
    (
      Record_TEXT CHAR(9)
    );

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION OUTGOING_SPRINT;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
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
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DELETE ESPRT_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE ESPRT_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO ESPRT_Y1';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT ESPRT_Y1
          (MemberSsn_NUMB)
   SELECT DISTINCT
          d.MemberSsn_NUMB
     FROM DEMO_Y1 d
          JOIN CMEM_Y1 m
           ON m.MemberMci_IDNO = d.MemberMci_IDNO
    WHERE d.MemberSsn_NUMB <> @Ln_Zero_NUMB
      AND d.FullDisplay_NAME <> @Lc_Space_TEXT
      AND EXISTS (SELECT 1
                    FROM CASE_Y1 s
                   WHERE s.Case_IDNO = m.Case_IDNO
                     AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                     AND s.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
                     AND s.CaseCategory_CODE <> @Lc_CaseCategoryPt_CODE)
      AND m.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND ((EXISTS (SELECT 1
                      FROM LSTT_Y1 l
                     WHERE l.MemberMci_IDNO = d.MemberMci_IDNO
                       AND l.StatusLocate_CODE = @Lc_StatusNonLocate_CODE
					   AND l.EndValidity_DATE = @Ld_High_DATE)
            AND EXISTS (SELECT 1
                          FROM CASE_Y1 s
                         WHERE s.Case_IDNO = m.Case_IDNO
                           AND s.RespondInit_CODE IN (@Lc_RespondInitInState_CODE, @Lc_RespondInitResponding_CODE, @Lc_TribalResponding_CODE, @Lc_InternationalResponding_CODE))
            AND NOT EXISTS (SELECT 1
                              FROM SORD_Y1 s
                             WHERE s.Case_IDNO = m.Case_IDNO
                               AND s.EndValidity_DATE >= @Ld_Run_DATE))
            OR (EXISTS (SELECT 1
                          FROM SORD_Y1 s
                         WHERE s.Case_IDNO = m.Case_IDNO
                           AND s.EndValidity_DATE > @Ld_Run_DATE)
                AND (NOT EXISTS (SELECT 1
                                   FROM AHIS_Y1 a
                                  WHERE a.Status_CODE = @Lc_StatusConfirmedGood_CODE
                                    AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                    AND a.MemberMci_IDNO = d.MemberMci_IDNO
                                    AND a.TypeAddress_CODE = @Lc_TypeAddressMailing_CODE)
                      OR NOT EXISTS (SELECT 1
                                       FROM EHIS_Y1 e
                                      WHERE e.MemberMci_IDNO = d.MemberMci_IDNO
                                        AND @Ld_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
                                        AND e.Status_CODE = @Lc_StatusConfirmedGood_CODE))))
   UNION
   SELECT DISTINCT
          d.MemberSsn_NUMB
     FROM DEMO_Y1 d,
          DHLD_Y1 l,
          CMEM_Y1 m
    WHERE d.MemberMci_IDNO = m.MemberMci_IDNO
      AND d.MemberSsn_NUMB <> @Ln_Zero_NUMB
      AND d.FullDisplay_NAME <> @Lc_Space_TEXT
      AND EXISTS (SELECT 1
                    FROM CASE_Y1 s
                   WHERE s.Case_IDNO = m.Case_IDNO
                     AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                     AND s.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
                     AND s.CaseCategory_CODE <> @Lc_CaseCategoryPt_CODE)
      AND m.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
      AND m.Case_IDNO = l.Case_IDNO
      AND l.ReasonStatus_CODE IN (@Lc_ReasonOnHoldSdca_CODE,@Lc_ReasonOnHoldSdna_CODE)
      AND l.Status_CODE = @Lc_StatusReceiptHold_CODE
      AND l.CheckRecipient_ID = d.MemberMci_IDNO
      AND l.CheckRecipient_CODE = @Lc_CheckRecipientNcpCp_CODE;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM ESPRT_Y1 e);

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
		   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

		   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
			@Ac_Worker_ID                = @Lc_UserBatch_TEXT,
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
			SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', Increment_NUMB = '+ CAST(@Ln_Increment_NUMB  AS VARCHAR) + ', ActivityMajorCase_CODE = '+@Lc_ActivityMajorCase_CODE  +', SubsystemLo_CODE = '+@Lc_SubsystemLocate_CODE +', Run_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR) +', High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR) +', ReasonStatusBi_CODE = '+  @Lc_ReasonStatusBi_CODE +', Low_DATE = '+ CAST(@Ld_Low_DATE AS VARCHAR) +', BatchRunUser_TEXT = '+ @Lc_UserBatch_TEXT ;
		 	
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
					  @Lc_UserBatch_TEXT AS WorkerUpdate_ID,
					  @Ld_Start_DATE AS UPDATE_DTTM,
					  @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
					  @Lc_Space_TEXT AS TypeReference_CODE,
					  @Lc_Space_TEXT AS Reference_ID
				FROM ESPRT_Y1 a,
					 CMEM_Y1 b,
					 CASE_Y1 s,
					 DEMO_Y1 d
			   WHERE CAST(a.MemberSsn_NUMB AS NUMERIC) = d.MemberSsn_NUMB
			      AND b.MemberMci_IDNO = d.MemberMci_IDNO
			      AND b.Case_IDNO = s.Case_IDNO
			      AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
				  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE ,@Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
				  AND b.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
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

   SET @Ls_Sql_TEXT = 'INSERT CJNR_Y1';
   SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', ActivityMinorStfdm_CODE = '+ @Lc_ActivityMinorStfpu_CODE + ', Run_DATE = '+ CAST( @Ld_Run_DATE  AS VARCHAR)+ ', StatusComplete_CODE = '+ @Lc_StatusComp_CODE  +', ReasonStatusSy_CODE = '+@Lc_ReasonStatusSy_CODE +', BatchRunUser_TEXT = '+ @Lc_UserBatch_TEXT +', SubsystemLo_CODE = '+@Lc_SubsystemLocate_CODE  + ', ActivityMajorCase_CODE = '+ @Lc_ActivityMajorCase_CODE +', StatusStart_CODE = '+ @Lc_StatusStrt_CODE;
			   
	WITH BulkInsert_CjnrItopc
	AS (
				   SELECT b.Case_IDNO AS Case_IDNO,
							  0 AS OrderSeq_NUMB,
							  d.MajorIntSEQ_NUMB AS MajorIntSEQ_NUMB,
							  ISNULL((SELECT MAX(x.MinorIntSeq_NUMB)
										FROM UDMNR_V1 x
									   WHERE d.Case_IDNO = x.Case_IDNO
										 AND d.MajorIntSEQ_NUMB = x.MajorIntSEQ_NUMB), 0) + ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO ORDER BY b.Case_IDNO) AS MinorIntSeq_NUMB,
							  b.MemberMci_IDNO AS MemberMci_IDNO,
							  @Lc_ActivityMinorStfpu_CODE AS ActivityMinor_CODE,
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
							  @Lc_UserBatch_TEXT AS UserLastPoster_ID,
							  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS LastPost_DTTM,
							  @Ld_Run_DATE AS AlertPrior_DATE,
							  @Ld_Run_DATE AS BeginValidity_DATE,
							  @Lc_UserBatch_TEXT AS WorkerUpdate_ID,
							  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
							  @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
							  @Lc_Space_TEXT AS WorkerDelegate_ID,
							  0 AS UssoSeq_NUMB,
							  @Lc_SubsystemLocate_CODE AS Subsystem_CODE,
							  @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE
						 FROM CMEM_Y1 b,
							  DMJR_Y1 d,
							  ESPRT_Y1 a,
							  CASE_Y1 s,
							  DEMO_Y1 e
					    WHERE CAST(a.MemberSsn_NUMB AS NUMERIC) = e.MemberSsn_NUMB
						  AND b.MemberMci_IDNO = e.MemberMci_IDNO
						  AND b.Case_IDNO = d.Case_IDNO
						  AND b.Case_IDNO = s.Case_IDNO
						  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE ,@Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
						  AND b.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
						  AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
						  AND d.Subsystem_CODE = @Lc_SubsystemLocate_CODE
						  AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
						  AND d.Status_CODE = @Lc_StatusStrt_CODE
						  AND NOT EXISTS (SELECT 1
											FROM CJNR_Y1 x
										   WHERE x.Case_IDNO = b.Case_IDNO
										     AND x.MemberMci_IDNO = b.MemberMci_IDNO
											 AND x.Subsystem_CODE = @Lc_SubsystemLocate_CODE
											 AND x.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
											 AND x.ActivityMinor_CODE = @Lc_ActivityMinorStfpu_CODE
											 AND x.Entered_DATE = @Ld_Run_DATE)
	   )
			    INSERT INTO CJNR_Y1
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
			FROM BulkInsert_CjnrItopc;

	  END	    
    
     SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtractSprint_P1';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

     INSERT INTO ##ExtractSprint_P1
                 (Record_TEXT)
     SELECT RIGHT(('000000000' + LTRIM(RTRIM(e.MemberSsn_NUMB))), 9) AS Record_TEXT
       FROM ESPRT_Y1 e;

     SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     COMMIT TRANSACTION OUTGOING_SPRINT;

     SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractSprint_P1';
     SET @Ls_Sql_TEXT = 'EXTRACT DATA';
     SET @Ls_Sqldata_TEXT = ' FILE Location = ' + @Ls_FileLocation_TEXT + ', Ls_File_NAME = ' + @Ls_File_NAME + ', Query TEXT = ' + @Ls_Query_TEXT;
     
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
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     BEGIN TRANSACTION OUTGOING_SPRINT;
  
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_UserBatch_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

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
    @Ac_Worker_ID                 = @Lc_UserBatch_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractSprint_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE ##ExtractSprint_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION OUTGOING_SPRINT;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_SPRINT;
    END;

   IF OBJECT_ID('tempdb..##ExtractSprint_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractSprint_P1;
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
    @Ac_Worker_ID                 = @Lc_UserBatch_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
