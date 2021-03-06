/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_DOL$SP_EXTRACT_DOL]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_DOL$SP_EXTRACT_DOL
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_OUTGOING_DOL$SP_EXTRACT_DOL extracts all the NCP's who are eligible 
					       for unemployment income withholding and creates an output file to be sent out to 
					       Division of Labor (DOL).
Frequency		:	'WEEKLY'
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_DOL$SP_EXTRACT_DOL]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY                INT = 0,
		  @Li_FetchRowCount_QNTY		   INT = 0,
		  --13129 - EXDOL_Y1 - CR0345 IWO Process Changes 20131226 -START-
          @Ln_OthpIdDeUnemployOffice_NUMB  NUMERIC(9) = 999999928,
          --13129 - EXDOL_Y1 - CR0345 IWO Process Changes 20131226 -END-
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE       CHAR(1) = 'A',
          @Lc_StringZero_TEXT              CHAR(1) = '0',
          @Lc_Space_TEXT                   CHAR(1) = ' ',
          @Lc_Dot_TEXT					   CHAR(1) = '.',
          @Lc_StatusCaseOpen_CODE          CHAR(1) = 'O',
          @Lc_No_TEXT                      CHAR(1) = 'N',
          @Lc_Yes_TEXT                     CHAR(1) = 'Y',
          @Lc_InitiatingState_CODE         CHAR(1) = 'I',
          @Lc_InitiatingTribal_CODE        CHAR(1) = 'T',
          @Lc_InitiatingInternational_CODE CHAR(1) = 'C',
          @Lc_CaseTypeNonIVD_CODE          CHAR(1) = 'H',
          @Lc_ItinSsn_CODE                 CHAR(1) = 'I',
          @Lc_CaseRelationshipNcp_CODE     CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',          
          @Lc_TypeWarning_CODE             CHAR(1) = 'W',
          @Lc_MemberStatusA_CODE           CHAR(1) = 'A',
          --13129 - EXDOL_Y1 - CR0345 IWO Process Changes 20131226 -START-
          @Lc_NoIwnIssued_CODE			   CHAR(1) = 'N',
          --13129 - EXDOL_Y1 - CR0345 IWO Process Changes 20131226 -END-
          @Lc_SubsystemEn_CODE             CHAR(2) = 'EN',
          @Lc_EmployerWage_CODE            CHAR(2) = 'EW',
          @Lc_DirectPay_CODE               CHAR(2) = 'DP',
          @Lc_ChildSupport_CODE            CHAR(2) = 'CS',
          @Lc_MedicalSupport_CODE          CHAR(2) = 'MS',
          @Lc_ReasonStatusBi_CODE		   CHAR(2) = 'BI',
          @Lc_ReasonStatusSy_CODE		   CHAR(2) = 'SY',
          @Lc_StatusStrt_CODE			   CHAR(4) = 'STRT',
          @Lc_StatusComp_CODE			   CHAR(4) = 'COMP',
          @Lc_Wage_TEXT                    CHAR(4) = 'WAGE',
          @Lc_Regp_TEXT                    CHAR(4) = 'REGP',
          @Lc_ActivityMajorCASE_CODE       CHAR(4) = 'CASE',
          @Lc_BatchRunUser_TEXT            CHAR(5) = 'BATCH',
          @Lc_ReasonErfso_CODE             CHAR(5) = 'ERFSO',
          @Lc_ReasonErfsm_CODE             CHAR(5) = 'ERFSM',
          @Lc_ReasonErfss_CODE             CHAR(5) = 'ERFSS',
          @Lc_ActivityMinorStnld_CODE      CHAR(5) = 'STNLD',
          @Lc_BateError_CODE               CHAR(5) = 'E0944',
          @Lc_Job_ID                       CHAR(7) = 'DEB0007',          
          @Lc_Successful_TEXT              CHAR(10) = 'SUCCESSFUL',
          @Ls_Procedure_NAME               VARCHAR(50) = 'BATCH_ENF_OUTGOING_DOL$SP_EXTRACT_DOL',
          @Ls_Process_NAME                 VARCHAR(50) = 'BATCH_ENF_OUTGOING_DOL',
          @Ld_Low_DATE					   DATE = '01/01/0001',
          @Ld_High_DATE                    DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
		  @Ln_Increment_NUMB			  NUMERIC(1) = 1,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_Topic_IDNO                  NUMERIC(12),
          @Ln_SeqUnique_IDNO              NUMERIC(19) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19),
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_FileName_NAME               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2(0);
  DECLARE @Ln_CaseMemberCur_Case_IDNO      NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO NUMERIC(10);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE ##ExtDol_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   CREATE TABLE ##ExtDol_P1
    (
      Record_TEXT VARCHAR(4000)
    );

   BEGIN TRANSACTION EXTRACT_DOL;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

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

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE CHECK';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);
   SET @Ls_FileSource_TEXT = ISNULL(LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_NAME)), @Lc_Space_TEXT);

   IF @Ls_FileSource_TEXT = @Lc_Space_TEXT
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT='DELETE EXDOL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   DELETE FROM EXDOL_Y1;

   SET @Ls_Sql_TEXT = 'INSERT NCP EXDOL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   INSERT INTO EXDOL_Y1
               (MemberSsn_NUMB,
                TotalPeriodic_AMNT,
                PaymentType_CODE)
   SELECT a.NcpPfSsn_NUMB,
		  CASE
		   WHEN SUM(a.TotalPeriodic_AMNT) < 0
		    THEN REPLACE(CAST(CAST(@Ln_Zero_NUMB AS DECIMAL(9, 2)) AS VARCHAR(10)), @Lc_Dot_TEXT, '')
		   ELSE REPLACE(CAST(CAST(SUM(a.TotalPeriodic_AMNT) AS DECIMAL(9, 2)) AS VARCHAR(10)), @Lc_Dot_TEXT, '')
		  END AS TotalPeriodic_AMNT,
          a.PaymentType_CODE
     FROM (SELECT a.NcpPfSsn_NUMB,
                  CASE
                   WHEN (a.Mso_AMNT > 0) or (a.ExpectToPay_AMNT > 0 and a.FullArrears_AMNT > 0)
                    THEN (a.Mso_AMNT * 12 / 52) + (a.ExpectToPay_AMNT * 12 / 52)
                   ELSE a.FullArrears_AMNT
                  END TotalPeriodic_AMNT,
                  @Lc_Wage_TEXT AS PaymentType_CODE
             FROM ENSD_Y1 a
            WHERE a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
              AND a.Case_IDNO NOT IN (SELECT x.Case_IDNO
                                        FROM ENSD_Y1 x
                                       WHERE x.TypeCase_CODE = @Lc_CaseTypeNonIVD_CODE
                                         AND x.CaseCategory_CODE = @Lc_DirectPay_CODE)
              AND a.NcpPfSsn_NUMB <> 0
              AND a.NcpPfSsn_NUMB NOT IN (SELECT x.MemberSsn_NUMB
                                            FROM MSSN_Y1 x
                                           WHERE x.MemberSsn_NUMB = a.NcpPfSsn_NUMB
                                             AND x.TypePrimary_CODE = @Lc_ItinSsn_CODE)
              AND a.Bankruptcy13_INDC = @Lc_No_TEXT
              AND a.RespondInit_CODE NOT IN (@Lc_InitiatingInternational_CODE, @Lc_InitiatingState_CODE, @Lc_InitiatingTribal_CODE)
              AND NOT EXISTS (SELECT 1
                                FROM CTHB_Y1 c
                               WHERE c.Case_IDNO = a.Case_IDNO
                                 AND c.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE)
                                 AND c.End_DATE = @Ld_High_DATE)
              AND a.ImiwExempt_INDC <> @Lc_Yes_TEXT 
              --13129 - EXDOL_Y1 - CR0345 IWO Process Changes 20131226 -START-
              AND NOT EXISTS (SELECT 1 
                                FROM EHIS_Y1 e
                               WHERE e.OthpPartyEmpl_IDNO = @Ln_OthpIdDeUnemployOffice_NUMB
                                 AND e.Status_CODE = @Lc_NoIwnIssued_CODE
                                 AND e.EndEmployment_DATE = @Ld_High_DATE
                                 AND e.MemberMci_IDNO = a.NcpPf_IDNO)   
              --13129 - EXDOL_Y1 - CR0345 IWO Process Changes 20131226 -END-          
              AND EXISTS (SELECT 1
                            FROM OBLE_Y1 x
                           WHERE x.TypeDebt_CODE IN (@Lc_ChildSupport_CODE, @Lc_MedicalSupport_CODE)
						     AND x.Case_IDNO = a.Case_IDNO
                             AND ((x.EndObligation_DATE > @Ld_Run_DATE
                                   AND x.Periodic_AMNT > 0)
                                   OR (x.ExpectToPay_AMNT > 0)))) a
    WHERE a.TotalPeriodic_AMNT > 0
    GROUP BY a.NcpPfSsn_NUMB, a.PaymentType_CODE
   OPTION (RECOMPILE);

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF(@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'NO RECORD(S) TO PROCESS';
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION';
     SET @Ls_SqlData_TEXT = 'Procedure_NAME = ' + @Ls_Procedure_NAME + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', Error_NUMB = ' + CAST(@Ln_Error_NUMB AS VARCHAR) + ', ErrorLine_NUMB = ' + CAST(@Ln_ErrorLine_NUMB AS VARCHAR);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeWarning_CODE + ', Line_NUMB = ' + @Ln_Zero_NUMB + ', Error_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeWarning_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   ELSE     
    BEGIN
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
 	   FROM EXDOL_Y1 a,
 	 	    CMEM_Y1 b,
 		    CASE_Y1 s,
 		    DEMO_Y1 d
 	  WHERE a.MemberSsn_NUMB = d.MemberSsn_NUMB
 	    AND d.MemberMci_IDNO = b.MemberMci_IDNO
 	    AND b.Case_IDNO = s.Case_IDNO
 	    AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
 	    AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE ,@Lc_CaseRelationshipPutative_CODE)
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
 	 SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', ActivityMinor_CODE = '+ @Lc_ActivityMinorStnld_CODE + ', Run_DATE = '+ CAST( @Ld_Run_DATE  AS VARCHAR)+ ', StatusComplete_CODE = '+ @Lc_StatusComp_CODE  +', ReasonStatusSy_CODE = '+ @Lc_ReasonStatusSy_CODE +', BatchRunUser_TEXT = '+ @Lc_BatchRunUser_TEXT +', SubsystemLo_CODE = '+@Lc_SubsystemEn_CODE  + ', ActivityMajorCase_CODE = '+ @Lc_ActivityMajorCase_CODE +', StatusStart_CODE = '+ @Lc_StatusStrt_CODE;
 	   
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
			   @Lc_ActivityMinorStnld_CODE AS ActivityMinor_CODE,
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
			   EXDOL_Y1 a,
			   CASE_Y1 s,
			   DEMO_Y1 f,
			   ENSD_Y1 e
		 WHERE a.MemberSsn_NUMB = f.MemberSsn_NUMB
		   AND f.MemberMci_IDNO = b.MemberMci_IDNO
		   AND b.Case_IDNO = d.Case_IDNO
		   AND b.Case_IDNO = s.Case_IDNO
		   AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
		   AND d.Subsystem_CODE = @Lc_SubsystemEn_CODE
		   AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
		   AND d.Status_CODE = @Lc_StatusStrt_CODE
		   AND e.NcpPfSsn_NUMB = a.MemberSsn_NUMB
		   AND e.Case_IDNO = b.Case_IDNO
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
   
   SET @Ls_Sql_TEXT = 'INSERT ##ExtDol_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   INSERT INTO ##ExtDol_P1
               (Record_TEXT)
   SELECT (RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(x.MemberSsn_NUMB))), 9) + RIGHT((REPLICATE(@Lc_StringZero_TEXT, 10) + LTRIM(RTRIM(x.TotalPeriodic_AMNT))), 10) + LEFT((x.PaymentType_CODE + REPLICATE(@Lc_Space_TEXT, 4)), 4)) AS Record_TEXT
     FROM EXDOL_Y1 x
    ORDER BY CAST(MemberSsn_NUMB AS NUMERIC);

   COMMIT TRANSACTION EXTRACT_DOL;

--13840 - As part of bug 13840, changed DOL extract job code to display ssn in ascending order in the extract file -START- 
   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtDol_P1 ORDER BY LEFT(Record_TEXT, 9)';
--13840 - As part of bug 13840, changed DOL extract job code to display ssn in ascending order in the extract file -END-   
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

   BEGIN TRANSACTION EXTRACT_DOL;      

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', START DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', PACKAGE NAME = ' + @Ls_Process_NAME + ', PROCEDURE NAME = ' + @Ls_Procedure_NAME;

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
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtDol_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   DROP TABLE ##ExtDol_P1;

   COMMIT TRANSACTION EXTRACT_DOL;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EXTRACT_DOL;
    END

   IF OBJECT_ID('tempdb..##ExtDol_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtDol_P1;
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
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
