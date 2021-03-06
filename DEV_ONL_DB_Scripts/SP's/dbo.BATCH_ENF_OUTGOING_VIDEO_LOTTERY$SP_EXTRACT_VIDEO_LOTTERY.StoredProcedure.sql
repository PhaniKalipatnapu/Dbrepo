/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_VIDEO_LOTTERY$SP_EXTRACT_VIDEO_LOTTERY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_VIDEO_LOTTERY$SP_EXTRACT_VIDEO_LOTTERY
Programmer Name	:	IMP Team.
Description		:	The purpose of this batch program is to send delinquent NCPs to Video Lottery Operators (VLOs) 
                    for Video Lottery Intercept. NCP’s details  are included in the outgoing file if NCP is associated 
                    with one or more case(s) which is eligible for video lottery intercept.
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_VIDEO_LOTTERY$SP_EXTRACT_VIDEO_LOTTERY]
AS
 BEGIN
  SET NOCOUNT ON;
  
  DECLARE @Li_RowCount_QNTY                 INT = 0,
		  @Li_FetchStatus_NUMB			    INT = 0,
          @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE		    CHAR(1) = 'S',
          @Lc_Failed_CODE                   CHAR(1) = 'F',          
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',          
          @Lc_CaseTypeNonIVD_CODE           CHAR(1) = 'H',
          @Lc_Header_CODE				    CHAR(1) = 'H',
          @Lc_Detail_TEXT				    CHAR(1) = 'D',
          @Lc_Trailer_CODE				    CHAR(1) = 'T',
          @Lc_Yes_TEXT					    CHAR(1) = 'Y',
          @Lc_CaseRealationshipNcp_CODE	    CHAR(1) = 'A',
          @Lc_CaseMemberStatusActive_CODE   CHAR(1) = 'A',
          @Lc_StatusCaseOpen_CODE		    CHAR(1) = 'O',
          @Lc_TypeWarning_CODE              CHAR(1) = 'W',
          @Lc_StringZero_TEXT			    CHAR(1) = '0',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_MemberStatusA_CODE            CHAR(1) = 'A',
          @Lc_StatusCaseO_CODE			    CHAR(1) = 'O',
          @Lc_No_TEXT					    CHAR(1) = 'N',
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',
          @Lc_SubsystemEN_CODE			    CHAR(2) = 'EN',
          @Lc_ReasonStatusBi_CODE		    CHAR(2) = 'BI',
          @Lc_ReasonStatusSy_CODE		    CHAR(2) = 'SY',
          @Lc_TypeReferenceLottery_CODE	    CHAR(3) = 'LTY',
          @Lc_ActivityMajorCase_CODE	    CHAR(4) = 'CASE',          
          @Lc_ActivityMajorCclo_CODE	    CHAR(4) = 'CCLO',
          @Lc_ActivityMajorAren_CODE	    CHAR(4) = 'AREN',
          @Lc_StatusStrt_CODE			    CHAR(4) = 'STRT',
          @Lc_StatusComp_CODE			    CHAR(4) = 'COMP',
          @Lc_ActivityMinorSfvli_CODE	    CHAR(5) = 'SFVLI',
          @Lc_ActivityMinorExmcr_CODE		CHAR(5) = 'EXMCR',
          @Lc_BatchRunUser_TEXT             CHAR(5) = 'BATCH',
          @Lc_BateError_CODE                CHAR(5) = 'E0944',
          @Lc_Job_ID                        CHAR(7) = 'DEB5030',
          @Lc_Successful_TEXT               CHAR(10) = 'SUCCESSFUL',                
          @Lc_Procedure_NAME                CHAR(24) = 'SP_EXTRACT_VIDEO_LOTTERY',
          @Lc_Process_NAME                  CHAR(32) = 'BATCH_ENF_OUTGOING_VIDEO_LOTTERY',   
          @Ld_Low_DATE					    DATE = '01/01/0001',       
          @Ld_High_DATE                     DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,  
		  @Ln_Increment_NUMB			  NUMERIC(1) = 1,        
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TopicID_NUMB   			  NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO              NUMERIC(19) = 0,
          @Ln_TransactionEventSeq_NUMB	  NUMERIC(19),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_FileName_NAME               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100),          
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;  
  
  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   BEGIN TRANSACTION ExtractVideoLottery;

   SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractVideoLottery_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractVideoLottery_P1
    (
	  Seq_IDNO NUMERIC(6) IDENTITY(1,1),
      Record_TEXT VARCHAR(150)
    );
    
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_Failed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE CHECK';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(DAY, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END
    
   SET @Ls_Sql_TEXT = 'DELETE FROM EVLOT_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM EVLOT_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO EVLOT_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT EVLOT_Y1
	      (MemberMci_IDNO,
	       MemberSsn_NUMB,
	       Last_NAME,
	       First_NAME,
	       Middle_NAME,
	       Birth_DATE,
	       Arrears_AMNT)
   SELECT d.MemberMci_IDNO,
		  d.MemberSsn_NUMB, 		  		  
		  d.Last_NAME,
		  d.First_NAME,
		  d.Middle_NAME,
		  CONVERT(VARCHAR(8), d.Birth_DATE, 112) AS Birth_DATE,
		  CAST(REPLACE(CAST(SUM(a.FullArrears_AMNT) AS VARCHAR),'.','') AS NUMERIC) AS Arrears_AMNT
    FROM ENSD_Y1 a,
         CMEM_Y1 c,
         DEMO_Y1 d
    WHERE d.MemberMci_IDNO = a.NcpPf_IDNO
      AND c.Case_IDNO = a.Case_IDNO 
      AND c.MemberMci_IDNO = a.NcpPf_IDNO 
      AND c.CaseRelationship_CODE = @Lc_CaseRealationshipNcp_CODE 
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
      AND a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE  
      AND a.TypeCase_CODE <> @Lc_CaseTypeNonIVD_CODE 
	  AND a.CaseExempt_INDC <> @Lc_Yes_TEXT 
	  AND a.LintExempt_INDC <> @Lc_Yes_TEXT  
      AND EXISTS (SELECT 1 
					FROM SORD_Y1 s
				   WHERE s.Case_IDNO = a.Case_IDNO
				     AND s.OrderEnd_DATE > @Ld_Run_DATE) 
      AND ISNULL((SELECT SUM(x.FullArrears_AMNT)
			        FROM ENSD_Y1 x
			       WHERE x.NcpPf_IDNO = a.NcpPf_IDNO), @Ln_Zero_NUMB) >= 150 
      AND a.FullArrears_AMNT > a.Mso_AMNT 
	  AND NOT EXISTS (SELECT 1 
					    FROM DMJR_Y1 d
				       WHERE d.Case_IDNO = a.Case_IDNO
				         AND d.MemberMci_IDNO = a.NcpPf_IDNO
				         AND d.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
				         AND d.Status_CODE = @Lc_StatusStrt_CODE) 
	  AND NOT EXISTS (SELECT 1 
					    FROM DMJR_Y1 d
				       WHERE d.Case_IDNO = a.Case_IDNO
				         AND d.MemberMci_IDNO = a.NcpPf_IDNO
				         AND d.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
				         AND d.TypeReference_CODE = @lC_TypeReferenceLottery_CODE
				         AND d.Status_CODE = @Lc_StatusStrt_CODE) 			         
      AND EXISTS (SELECT 1
					FROM MSSN_Y1 m
				   WHERE m.MemberMci_IDNO = a.NcpPf_IDNO
				     AND m.MemberSsn_NUMB = d.MemberSsn_NUMB
					 AND m.MemberSsn_NUMB > @Ln_Zero_NUMB
				     AND m.EndValidity_DATE = @Ld_High_DATE) 
	GROUP BY d.MemberMci_IDNO, 
			 d.MemberSsn_NUMB, 
			 d.Last_NAME, 
			 d.First_NAME, 
			 d.Middle_NAME, 
			 d.Birth_DATE;
	
	SET @Li_RowCount_QNTY = @@ROWCOUNT;

    IF @Li_RowCount_QNTY = 0
     BEGIN
      SET @Ls_Sql_TEXT = 'NO RECORDS TO EXTRACT';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Li_RowCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Lc_Process_NAME,
       @As_Procedure_NAME           = @Lc_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeWarning_CODE,
       @An_Line_NUMB                = @Li_RowCount_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END
     END
    
	SET @Ls_Sql_TEXT = 'INSERT HEADER';
    SET @Ls_Sqldata_TEXT = 'Header Code = ' + @Lc_Header_CODE + 'Run Date = ' + CAST(@Ld_Run_DATE AS VARCHAR);

    INSERT INTO ##ExtractVideoLottery_P1
                (Record_TEXT)
         VALUES ( @Lc_Header_CODE + CONVERT(VARCHAR, @Ld_Run_DATE, 112) + REPLICATE(@Lc_Space_TEXT, 141) -- Record_TEXT
    );

    SET @Ls_Sql_TEXT = 'INSERT ##ExtractVideoLottery_P1';
    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

    INSERT INTO ##ExtractVideoLottery_P1
                (Record_TEXT)
    SELECT @Lc_Detail_TEXT + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 10) + LTRIM(RTRIM(x.MemberMci_IDNO))), 10) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(x.MemberSsn_NUMB))), 9) + LEFT((x.Birth_DATE + REPLICATE(@Lc_Space_TEXT, 8)), 8) + LEFT((x.First_NAME + REPLICATE(@Lc_Space_TEXT, 16)), 16) + LEFT((x.Last_NAME + REPLICATE(@Lc_Space_TEXT, 20)), 20) + LEFT((x.Middle_NAME + REPLICATE(@Lc_Space_TEXT, 20)), 20) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 11) + LTRIM(RTRIM(x.Arrears_AMNT))), 11) + REPLICATE(@Lc_Space_TEXT, 55) AS Record_TEXT
     FROM EVLOT_Y1 x
    ORDER BY x.MemberSsn_NUMB; 
 
    SET @Ls_Sql_TEXT='INSERT TRAILER';
    SET @Ls_Sqldata_TEXT = 'FILE RECORD COUNT = ' + CAST(@Li_Rowcount_QNTY AS VARCHAR);

    INSERT INTO ##ExtractVideoLottery_P1
                (Record_TEXT)
         VALUES ( @Lc_Trailer_CODE + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(@Li_Rowcount_QNTY))), 9) + REPLICATE(@Lc_Space_TEXT, 140) -- Record_TEXT
    );

   COMMIT TRANSACTION ExtractVideoLottery;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractVideoLottery_P1 ORDER BY Seq_IDNO ASC';
   SET @Ls_Sql_TEXT = 'EXTRACT TO FILE';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_FileName_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_FileName_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION ExtractVideoLottery;
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_No_TEXT,
    @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
  
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
   
   -- Case Journal Entry 
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_No_TEXT,
    @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'INSERT DMJR_Y1';
   SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', Increment_NUMB = '+ CAST(@Ln_Increment_NUMB  AS VARCHAR) + ', ActivityMajorCase_CODE = '+@Lc_ActivityMajorCase_CODE  +', SubsystemLo_CODE = '+@Lc_SubsystemEn_CODE +', Run_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR) +', High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR) +', ReasonStatusBi_CODE = '+  @Lc_ReasonStatusBi_CODE +', Low_DATE = '+ CAST(@Ld_Low_DATE AS VARCHAR) +', BatchRunUser_TEXT = '+ @Lc_BatchRunUser_TEXT ;
			
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
   SELECT DISTINCT b.Case_IDNO, 
		  0 AS OrderSeq_NUMB,
		  (SELECT ISNULL(MAX(c.MajorIntSEQ_NUMB), 0) + @Ln_Increment_NUMB
			 FROM DMJR_Y1 c
			WHERE c.Case_IDNO = b.Case_IDNO) AS MajorIntSEQ_NUMB,
		  0 AS MemberMci_IDNO, 
		  @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
		  @Lc_SubsystemEn_CODE AS Subsystem_CODE,
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
		  @Ld_Start_DATE AS UPDATE_DTTM,
		  @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
		  @Lc_Space_TEXT AS TypeReference_CODE,
		  @Lc_Space_TEXT AS Reference_ID
     FROM EVLOT_Y1 a,
 	      CMEM_Y1 b,
	      CASE_Y1 s,
	      DEMO_Y1 d
    WHERE a.MemberSsn_NUMB = d.MemberSsn_NUMB
      AND d.MemberMci_IDNO = b.MemberMci_IDNO
      AND b.Case_IDNO = s.Case_IDNO
      AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND b.CaseMemberStatus_CODE = @Lc_MemberStatusA_CODE
      AND NOT EXISTS (SELECT 1
					    FROM DMJR_Y1 d
					   WHERE b.Case_IDNO = d.Case_IDNO
					     AND d.Subsystem_CODE = @Lc_SubsystemEn_CODE
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
   SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', ActivityMinor_CODE = '+ @Lc_ActivityMinorSfvli_CODE + ', Run_DATE = '+ CAST( @Ld_Run_DATE  AS VARCHAR)+ ', StatusComplete_CODE = '+ @Lc_StatusComp_CODE  +', ReasonStatusSy_CODE = '+ @Lc_ReasonStatusSy_CODE +', BatchRunUser_TEXT = '+ @Lc_BatchRunUser_TEXT +', SubsystemLo_CODE = '+@Lc_SubsystemEn_CODE  + ', ActivityMajorCase_CODE = '+ @Lc_ActivityMajorCase_CODE +', StatusStart_CODE = '+ @Lc_StatusStrt_CODE;
   
   WITH BulkInsert_CjnrItopc
   AS(
      SELECT b.Case_IDNO AS Case_IDNO,
		     0 AS OrderSeq_NUMB,
		     d.MajorIntSEQ_NUMB AS MajorIntSEQ_NUMB,
		     ISNULL((SELECT MAX(x.MinorIntSeq_NUMB)
		  		       FROM UDMNR_V1 x
		  	          WHERE d.Case_IDNO = x.Case_IDNO
		  		        AND d.MajorIntSEQ_NUMB = x.MajorIntSEQ_NUMB), 0) + ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO ORDER BY b.Case_IDNO) AS MinorIntSeq_NUMB,
		     b.MemberMci_IDNO AS MemberMci_IDNO,
		     @Lc_ActivityMinorSfvli_CODE AS ActivityMinor_CODE,
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
		     @Lc_SubsystemEn_CODE AS Subsystem_CODE,
		     @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE
        FROM CMEM_Y1 b,
		     DMJR_Y1 d,
		     EVLOT_Y1 a,		     
		     DEMO_Y1 f,
		     ENSD_Y1 e
	   WHERE a.MemberSsn_NUMB = f.MemberSsn_NUMB
	     AND f.MemberMci_IDNO = b.MemberMci_IDNO
	     AND b.Case_IDNO = d.Case_IDNO	     
	     AND d.Subsystem_CODE = @Lc_SubsystemEn_CODE
	     AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
	     AND d.Status_CODE = @Lc_StatusStrt_CODE
	     AND NOT EXISTS (SELECT 1 
					       FROM CJNR_Y1 z, CASE_Y1 y
					      WHERE z.Case_IDNO = b.Case_IDNO
						    AND z.ActivityMinor_CODE = @Lc_ActivityMinorSfvli_CODE
						    AND z.Case_IDNO = y.Case_IDNO 
						    AND z.Entered_DATE > y.Opened_DATE
						    AND NOT EXISTS (SELECT 1
						                      FROM DMNR_Y1 n
											 WHERE n.Case_IDNO = y.Case_IDNO
											   AND n.Activityminor_CODE = @Lc_ActivityMinorExmcr_CODE
											   and n.Status_DATE > z.Entered_DATE)) 
		 AND f.MemberMci_IDNO = e.NcpPf_IDNO
		 AND b.Case_IDNO = e.Case_IDNO 
		 AND b.MemberMci_IDNO = e.NcpPf_IDNO 
		 AND b.CaseRelationship_CODE = @Lc_CaseRealationshipNcp_CODE 
		 AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
		 AND e.StatusCase_CODE = @Lc_StatusCaseOpen_CODE  
		 AND e.TypeCase_CODE <> @Lc_CaseTypeNonIVD_CODE  
		 AND e.CaseExempt_INDC <> @Lc_Yes_TEXT 
		 AND e.LintExempt_INDC <> @Lc_Yes_TEXT 
		 AND EXISTS (SELECT 1 
					   FROM SORD_Y1 s
				      WHERE s.Case_IDNO = e.Case_IDNO
					    AND s.OrderEnd_DATE > @Ld_Run_DATE) 
		 AND ISNULL((SELECT SUM(x.FullArrears_AMNT)
					   FROM ENSD_Y1 x
				      WHERE x.NcpPf_IDNO = e.NcpPf_IDNO), @Ln_Zero_NUMB) >= 150
		 AND ABS(DATEDIFF(DD, e.ReceiptLast_DATE, @Ld_Run_DATE)) > 30 
		 AND e.FullArrears_AMNT > e.Mso_AMNT 
		 AND NOT EXISTS (SELECT 1 
						   FROM DMJR_Y1 z
					      WHERE z.Case_IDNO = e.Case_IDNO
						    AND z.MemberMci_IDNO = e.NcpPf_IDNO
						    AND z.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
						    AND z.Status_CODE = @Lc_StatusStrt_CODE) 
		 AND NOT EXISTS (SELECT 1 
						   FROM DMJR_Y1 z
					      WHERE z.Case_IDNO = e.Case_IDNO
						    AND z.MemberMci_IDNO = e.NcpPf_IDNO
						    AND z.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
						    AND z.TypeReference_CODE = @lC_TypeReferenceLottery_CODE
						    AND z.Status_CODE = @Lc_StatusStrt_CODE) 			         
		 AND EXISTS (SELECT 1
					  FROM MSSN_Y1 m
				     WHERE m.MemberMci_IDNO = e.NcpPf_IDNO
				  	   AND m.MemberSsn_NUMB = f.MemberSsn_NUMB
				 	   AND m.MemberSsn_NUMB > @Ln_Zero_NUMB
					   AND m.EndValidity_DATE = @Ld_High_DATE)
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
   
   DROP TABLE ##ExtractVideoLottery_P1;
   
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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Li_RowCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                 = @Ld_Run_DATE,
    @Ad_Start_DATE               = @Ld_Start_DATE,
    @Ac_Job_ID                   = @Lc_Job_ID,
    @As_Process_NAME             = @Lc_Process_NAME,
    @As_Procedure_NAME           = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT      = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT        = @Lc_Successful_TEXT,
    @As_ListKey_TEXT             = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE              = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY= @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION ExtractVideoLottery;
  END TRY

  BEGIN CATCH
   IF OBJECT_ID('tempdb..##ExtractVideoLottery_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractVideoLottery_P1;
    END   
   
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ExtractVideoLottery;
    END   

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
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
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
