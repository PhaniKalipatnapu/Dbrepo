/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PROCESS_EMON_WEEKLY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		:	BATCH_ENF_EMON$SP_PROCESS_EMON_WEEKLY
Programmer Name		:	IMP Team
Description			:	This process monitors Compliance schedules takes the appropriate action defined.
Frequency			:   'WEEKLY'
Developed On		:	01/05/2012
Called By			:	None
Called On       	:   BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_GET_THREAD_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
					    BATCH_COMMON$SP_BATE_LOG, BATCH_COMMON$SP_BSTL_LOG, BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY
					    and BATCH_ENF_EMON$SP_PEWKL_UPDATE_FLAG
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PROCESS_EMON_WEEKLY]
 @An_Thread_NUMB NUMERIC(15)
AS
 BEGIN
 SET NOCOUNT ON;
 DECLARE  @Lc_StatusNoDataFound_CODE           CHAR(1)			= 'N',
          @Lc_StatusTooManyRows_CODE           CHAR(1)			= 'T',
          @Lc_MsgRaiseexception_CODE           CHAR(1)			= 'T',
          @Lc_MsgKeydatanotfound_CODE          CHAR(1)			= 'K',
          @Lc_TypeErrorE_CODE                  CHAR(1)			= 'E',
          @Lc_StatusReceiptRefunded_CODE       CHAR(1)			= 'R',
          @Lc_NegPosPositive_CODE              CHAR(1)			= 'P',
          @Lc_StatusReceiptOthpRefund_CODE     CHAR(1)			= 'O',
          @Lc_StatusSuccess_CODE       		   CHAR(1)			= 'S',
          @Lc_No_INDC                  		   CHAR(1)			= 'N',
          @Lc_StatusFailed_CODE        		   CHAR(1)			= 'F',
          @Lc_StatusAbnormalend_CODE           CHAR(1)			= 'A',
          @Lc_ThreadLocked_INDC				   CHAR(1)			= 'L',
          @Lc_Null_TEXT                		   CHAR(1)			= ' ',
          @Lc_Yes_INDC                 		   CHAR(1)			= 'Y',
          @Lc_TypeRecordOriginal_CODE 		   CHAR(1)			= 'O',
          @Lc_ComplianceTypeBond_CODE          CHAR(2)			= 'BD',
          @Lc_ComplianceTypeLumpSum_CODE       CHAR(2)			= 'LS',
          @Lc_ComplianceTypeMissedPayment_CODE CHAR(2)			= 'MP',
          @Lc_ComplianceTypePaymentPlan_CODE   CHAR(2)			= 'PP',
          @Lc_ComplianceTypeMedical_CODE       CHAR(2)			= 'MD',
          @Lc_ComplianceTypeOther_CODE         CHAR(2)			= 'OT',
          @Lc_ComplianceTypePeramt_CODE        CHAR(2)			= 'PA',
          @Lc_ReceiptSrcBond_CODE              CHAR(2)			= 'BN',
          @Lc_ComplianceStatusEnded_CODE       CHAR(2)			= 'ED',
          @Lc_CompliancStatusNoncomp_CODE      CHAR(2)			= 'NC',
          @Lc_TypeChangeBc_CODE                CHAR(2)			= 'BC',
          @Lc_SubsystemEnforcement_CODE        CHAR(2)			= 'EN',
          @Lc_SourceReceiptBond_CODE           CHAR(2)			= 'BN',
          @Lc_SourceReceiptLumpSum_CODE		   CHAR(2)			= 'LS',
          @Lc_SourceReceiptWorkcomp_CODE       CHAR(2)			= 'WC',
          @Lc_SourceReceiptLevyfidm_CODE       CHAR(2)			= 'LE',
          @Lc_SourceReceiptCprecoup_CODE       CHAR(2)			= 'CR',
          @Lc_SourceReceiptNsfrecoup_CODE      CHAR(2)			= 'NR',
          @Lc_SourceReceiptAc_CODE             CHAR(2)			= 'AC',
          @Lc_SourceReceiptAn_CODE             CHAR(2)			= 'AN',
          @Lc_StatusConfirmedGood_CODE         CHAR(2)			= 'CG',
          @Lc_CaseRelationshipDp_CODE          CHAR(2)			= 'D',
          @Lc_CaseMemberStatusActive_CODE      CHAR(2)			= 'A',
          @Lc_TypeReferenceCom_ID              CHAR(3)			= 'COM',
          @Lc_ActivityMajorCase_CODE           CHAR(4)			= 'CASE',
          @Lc_BatchRunUser_TEXT                CHAR(5)			= 'BATCH',
          @Lc_ActivityMinorCompi_CODE          CHAR(5)			= 'COMPI',
          @Lc_ActivityMinorRcmpi_CODE          CHAR(5)			= 'RCMPI',
          @Lc_BatchRunUser_ID             	   CHAR(5)			= 'BATCH',
          @Lc_ErrorBatch_CODE				   CHAR(5)			= 'E1424',
          @Lc_Job_ID                   		   CHAR(7)			= 'DEB5420',
          @Lc_JobPre_ID        				   CHAR(7)			= 'DEB5470',
          @Lc_WorkerUpdateConv_ID              CHAR(10)			= 'CONVERSION',
          @Ls_Process_NAME             		   CHAR(15)			= 'BATCH_ENF_EMON',
          @Lc_Successful_TEXT          		   CHAR(20)			= 'SUCCESSFUL',
          @Lc_ParmDateProblem_TEXT             CHAR (30)		= 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME             	   VARCHAR(50)		= 'BATCH_ENF_EMON$SP_PROCESS_EMON_WEEKLY',
          @Ld_High_DATE                		   DATE				= '12/31/9999',
          @Ld_Low_DATE                 		   DATE				= '01/01/0001';
          
  DECLARE @Li_Error_NUMB			        INT,
          @Li_ErrorLine_NUMB		        INT,   
          @Li_FetchStatus_QNTY              SMALLINT,
          @Li_RowCount_QNTY                 SMALLINT,     
          @Ln_Tmp_Update_QNTY            	NUMERIC,
  		  @Ln_Error_QNTY                    NUMERIC(1)				= 0,
   		  @Ln_Obl_Terminated_QNTY     		NUMERIC(3)				= 0,
  		  @Ln_Count_NUMB                    NUMERIC(4)				= 0,
          @Ln_Record_No_NUMB           		NUMERIC(5),
          @Ln_CommitFreqParm_QNTY       	NUMERIC(5), 
          @Ln_ExceptionThresholdParm_QNTY  	NUMERIC(5), 
          @Ln_ProcessedRecordCount_QNTY     NUMERIC(5)				= 0,
          @Ln_Commit_QNTY               	NUMERIC(5)				= 0,
          @Ln_Exception_QNTY                NUMERIC(9)				= 0,
          @Ln_Irsc_Cur_QNTY             	NUMERIC(10)				= 0,
          @Ln_Topic_IDNO               		NUMERIC(10)				= 0,
          @Ln_TopicOut_IDNO					NUMERIC(10),
          @Ln_Receipt_AMNT             		NUMERIC(11, 2),
          @Ln_ArrearPast_AMNT    			NUMERIC(11)				= 0,
          @Ln_Error_NUMB               		NUMERIC(11),
          @Ln_ErrorLine_NUMB                NUMERIC(10),
          @Ln_ArrearCurrent_AMNT        	NUMERIC(11)				= 0,
          @Ln_OweTotCurSup_AMNT       		NUMERIC(11)				= 0,
          @Ln_TotalInterval_NUMB       		NUMERIC(11)				= 0,
          @Ln_RecStart_NUMB            		NUMERIC(15),
          @Ln_RecRestart_NUMB          		NUMERIC(15),
          @Ln_RecEnd_NUMB              		NUMERIC(15),
          @Ln_TransactionEventSeq_NUMB 		NUMERIC(19),
          @Lc_Process_INDC             		CHAR(1),
		  @Lc_Error_CODE               		CHAR(5)					= 'E1424',
          @Lc_Msg_CODE                 		CHAR(5),
          @Lc_Compliance_TEXT               CHAR(19),
          @Ls_Sql_TEXT                 		VARCHAR(100)			= '',
          @Ls_RestartKey_TEXT          		VARCHAR(200),
          @Ls_SqlData_TEXT             		VARCHAR(400)			= '',
          @Ls_DescriptionError_TEXT    		VARCHAR(4000)			= '',
          @Ls_ListKey_TEXT             		VARCHAR(1000)			= ' ',
          @Ld_DATE                     		DATE,
          @Ld_Compliance_Eff_DATE      		DATE,
          @Ld_Compliance_EffEnd_DATE   		DATE,
          @Ld_Run_DATE                 		DATE,
          @Ld_LastRun_DATE             		DATE,
          @Ld_Start_DATE               		DATETIME2;
                    
  DECLARE @Ln_CompCur_OrderSeq_NUMB                     NUMERIC(2),
		  @Ln_CompCur_NoMissPayment_QNTY                NUMERIC(5),
		  @Ln_CompCur_Case_IDNO                         NUMERIC(6),
		  @Ln_CompCur_MemberMci_IDNO                    NUMERIC(10),
		  @Ln_CompCur_PaybackSord_AMNT                  NUMERIC(11, 2),
		  @Ln_CompCur_Compliance_AMNT                   NUMERIC(11, 2),
		  @Ln_CompCur_RecordRowNumber_NUMB              NUMERIC(15),
		  @Ln_CompCur_Compliance_IDNO                   NUMERIC(19),
		  @Ln_CompCur_TransactionEventSeq_NUMB          NUMERIC(19),
		  @Lc_CompCur_Process_INDC                      CHAR(1),
		  @Lc_CompCur_ComplianceType_CODE               CHAR(2),
		  @Ld_CompCur_Entry_DATE                        DATE,
		  @Ld_CompCur_Effective_DATE                    DATE,
		  @Ld_CompCur_End_DATE                          DATETIME;

  BEGIN TRY
   BEGIN TRANSACTION Emon_Main_Transaction;

   SET @Ls_Procedure_NAME = 'SP_PROCESS_EMON_WEEKLY';
   SET @Ls_Sql_TEXT = 'EMON021 : GET BATCH START TIME';
   SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
   -- Selecting the Batch start times
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- Selecting date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'EMON022 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_SqlData_TEXT = ' Job_ID = ' + @Lc_Job_ID;

      EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
    
  IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
       RAISERROR (50001,16,1);
    END
    
	SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
    SET @Ls_SqlData_TEXT = ' Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') +', LastRun_DATE = '+ ISNULL (CAST (@Ld_LastRun_DATE AS VARCHAR (20)), '');
    
    IF DATEADD(DAY, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
      SET @Ls_Sql_TEXT = @Lc_ParmDateProblem_TEXT;
      RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'EMONPRE : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
   SET @Ls_SqlData_TEXT = 'ID_JOB = ' + ISNULL (@Lc_Job_ID, '') + ', DT_RUN = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '');

   EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_JobPre_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'EMONWPRE : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED';
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'EMONWGETTHRD : BATCH_COMMON$SP_GET_THREAD_DETAILS';
   SET @Ls_SqlData_TEXT = ' Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '');

   EXECUTE BATCH_COMMON$SP_GET_THREAD_DETAILS
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_Thread_NUMB           = @An_Thread_NUMB,
    @An_RecRestart_NUMB       = @Ln_RecRestart_NUMB OUTPUT,
    @An_RecEnd_NUMB           = @Ln_RecEnd_NUMB OUTPUT,
    @An_RecStart_NUMB         = @Ln_RecStart_NUMB OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'EMONWGETTHRD : BATCH_COMMON$SP_GET_THREAD_DETAILS FAILED';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'EMON024 : COMPLIANCE CURSOR';
   SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
   --- Defining the cursor
   DECLARE Comp_CUR INSENSITIVE CURSOR 
   FOR SELECT a.RecordRowNumber_NUMB,
              a.Case_IDNO,
              a.OrderSeq_NUMB,
              a.MemberMci_IDNO,
              a.ComplianceType_CODE,
              a.Compliance_AMNT,
              a.NoMissPayment_QNTY,
              a.Entry_DATE,
              a.Effective_DATE,
              a.End_DATE,
              a.Compliance_IDNO,
              a.TransactionEventSeq_NUMB,
              a.PaybackSord_AMNT,
              a.Process_INDC
         FROM PEWKL_Y1 a
        WHERE RecordRowNumber_NUMB >= @Ln_RecRestart_NUMB
          AND RecordRowNumber_NUMB <= @Ln_RecEnd_NUMB
          AND Process_INDC = @Lc_No_INDC
        ORDER BY RecordRowNumber_NUMB;        
  
   OPEN Comp_CUR;
  
   FETCH NEXT FROM Comp_CUR INTO @Ln_CompCur_RecordRowNumber_NUMB, @Ln_CompCur_Case_IDNO, @Ln_CompCur_OrderSeq_NUMB, @Ln_CompCur_MemberMci_IDNO, @Lc_CompCur_ComplianceType_CODE, @Ln_CompCur_Compliance_AMNT, @Ln_CompCur_NoMissPayment_QNTY, @Ld_CompCur_Entry_DATE, @Ld_CompCur_Effective_DATE, @Ld_CompCur_End_DATE, @Ln_CompCur_Compliance_IDNO, @Ln_CompCur_TransactionEventSeq_NUMB, @Ln_CompCur_PaybackSord_AMNT, @Lc_CompCur_Process_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   --WHILE LOOP BEGINS
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
	 SAVE TRANSACTION Emon_Cursor_Transaction;
	 
     SET @Ln_Irsc_Cur_QNTY = @Ln_Irsc_Cur_QNTY + 1;
     SET @Ln_Commit_QNTY = @Ln_Commit_QNTY + 1;
     SET @Ln_Record_No_NUMB = @Ln_CompCur_RecordRowNumber_NUMB;
     SET @Lc_Process_INDC = @Lc_Null_TEXT;
     SET @Ls_RestartKey_TEXT = @Ln_CompCur_Case_IDNO;
     SET @Lc_Compliance_TEXT = ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '');
     SET @Ls_Sql_TEXT = 'EMON025 : SP_GENERATE_SEQ_TXN_EVENT';
     SET @Lc_Error_CODE = @Lc_ErrorBatch_CODE;
     SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = Ls_DescriptionError_TEXT;

     IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
         RAISERROR (50001,16,1);
      END;

     BEGIN TRY
      IF @Lc_CompCur_ComplianceType_CODE NOT IN (@Lc_ComplianceTypeBond_CODE, @Lc_ComplianceTypePeramt_CODE, @Lc_ComplianceTypeMedical_CODE, @Lc_ComplianceTypeLumpSum_CODE,
                                        @Lc_ComplianceTypePaymentPlan_CODE, @Lc_ComplianceTypeMissedPayment_CODE, @Lc_ComplianceTypeOther_CODE)
       BEGIN
        SET @Ls_Sql_TEXT = 'EMON027 : COMPLIANCE TYPE OTHER THAN OT';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', ComplianceType_CODE = ' + @Lc_CompCur_ComplianceType_CODE;
        SET @Ls_DescriptionError_TEXT = 'Compliance TYPE NOT Matched WITH The Allowed TYPE, The Compliance TYPE IS: ' + @Lc_CompCur_ComplianceType_CODE;

        RAISERROR (50001,16,1);
       END
      
      IF @Lc_CompCur_ComplianceType_CODE = @Lc_ComplianceTypeBond_CODE
       BEGIN
        -- Check Obligation Terminated
        SET @Ls_Sql_TEXT = 'EMON028A : CHECK WHETHER OBLIGATION IS ACTIVE';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '');
        SET @Ln_Obl_Terminated_QNTY = dbo.BATCH_ENF_EMON$SF_CHK_OBLIGATION_TERMINATED (@Ln_CompCur_Case_IDNO, @Ln_CompCur_OrderSeq_NUMB, @Ld_Run_DATE);
        SET @Ls_Sql_TEXT = 'EMON028 : SELECT BOND AMOUNT RECEIVED FROM VRCTH';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', Effective_DATE = ' + ISNULL (CAST (@Ld_CompCur_Effective_DATE AS VARCHAR (20)), '') + ', End_DATE = ' + ISNULL (CAST (@Ld_CompCur_End_DATE AS VARCHAR (20)), '');

        SELECT @Ln_Receipt_AMNT = ISNULL(SUM(ToDistribute_AMNT), 0)
          FROM RCTH_Y1 r
         WHERE (r.Case_IDNO = @Ln_CompCur_Case_IDNO
                 OR r.PayorMCI_IDNO = @Ln_CompCur_MemberMci_IDNO)
           AND r.SourceReceipt_CODE = @Lc_ReceiptSrcBond_CODE
           AND r.Receipt_AMNT > 0
           AND r.Receipt_DATE BETWEEN @Ld_CompCur_Effective_DATE AND @Ld_CompCur_End_DATE
           AND r.EndValidity_DATE = @Ld_High_DATE
           AND r.StatusReceipt_CODE NOT IN (@Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
           AND NOT EXISTS (SELECT 1
                             FROM ELRP_Y1 i
                            WHERE r.Batch_DATE = i.BatchOrig_DATE
                              AND r.SourceBatch_CODE = i.SourceBatchOrig_CODE
                              AND r.Batch_NUMB = i.BatchOrig_NUMB
                              AND r.SeqReceipt_NUMB = i.SeqReceiptOrig_NUMB);

        -- If Obligation terminated, then update the compliance status to Ended
        IF ((@Ln_Receipt_AMNT >= @Ln_CompCur_Compliance_AMNT
             AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE)
             OR @Ln_Obl_Terminated_QNTY = 0)
         BEGIN
          SET @Ls_Sql_TEXT = 'EMON026A : UPDATE VCOMP';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- Update the VCOMP record which meets the criteria
          UPDATE COMP_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;
             
         SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE VCOMP FAILED';

            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON029 : INSERT VCOMP 1';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- INSERT INTO COMP_Y1
          INSERT INTO COMP_Y1
						(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)
          SELECT a.Compliance_IDNO,
                 a.Case_IDNO,
                 a.OrderSeq_NUMB,
                 a.ComplianceType_CODE,
                 @Lc_ComplianceStatusEnded_CODE ComplianceStatus_CODE,
                 a.Effective_DATE,
                 a.End_DATE,
                 a.Compliance_AMNT,
                 ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                 a.NoMissPayment_QNTY,
                 a.OrderedParty_CODE,
                 @Ld_Run_DATE BeginValidity_DATE,
                 @Ld_High_DATE EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                 dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() Update_DTTM,
                 @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                 a.Entry_DATE
            FROM COMP_Y1 a
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;             
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'INSERT VCOMP FAILED';

            RAISERROR (50001,16,1);
           END;
         END
        ELSE IF @Ln_Receipt_AMNT < @Ln_CompCur_Compliance_AMNT
           AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE
         BEGIN
          SET @Ls_Sql_TEXT = 'EMON026B : UPDATE VCOMP';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- UPDATE the COMP_Y1 record which meets the criteria
          UPDATE COMP_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE COMP_Y1 FAILED';

            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON030 : INSERT COMP_Y1 2';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- INSERT INTO COMP_Y1
          INSERT INTO COMP_Y1 
          				(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)
          SELECT a.Compliance_IDNO,
                 a.Case_IDNO,
                 a.OrderSeq_NUMB,
                 a.ComplianceType_CODE,
                 @Lc_CompliancStatusNoncomp_CODE ComplianceStatus_CODE,
                 a.Effective_DATE,
                 a.End_DATE,
                 a.Compliance_AMNT,
                 ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                 a.NoMissPayment_QNTY,
                 a.OrderedParty_CODE,
                 @Ld_Run_DATE BeginValidity_DATE,
                 @Ld_High_DATE EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                 dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() Update_DTTM,
                 @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                 a.Entry_DATE
            FROM COMP_Y1 a
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;
             
          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE COMP_Y1 FAILED 1';

            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON031 : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY 1';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', OthpSource_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', TypeChange_CODE = ' + @Lc_TypeChangeBc_CODE + ', NegPos_CODE = ' + @Lc_NegPosPositive_CODE + ', Job_ID = ' + @Lc_Job_ID + ', DT_CREATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorCompi_CODE + ', Subsystem_CODE = ' + @Lc_SubsystemEnforcement_CODE + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR (19)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TypeReference_CODE = ' + @Lc_TypeReferenceCom_ID + ', ID_REFERENCE = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', Topic_IDNO = ' + ISNULL (CAST (@Ln_Topic_IDNO AS VARCHAR (MAX)), '');

          EXECUTE BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY
           @An_Case_IDNO                = @Ln_CompCur_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_CompCur_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCompi_CODE,
           @Ac_Subsystem_CODE           = @Lc_SubsystemEnforcement_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Lc_Error_CODE = 'E5000';

            IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$P_INSERT_ELFC_OR_ACTIVITY FAILED 1' + ' ' + @Ls_SqlData_TEXT;
             END
            ELSE
             BEGIN
              SET @Ls_Sql_TEXT = 'EMON031B : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 2';
              SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
             END

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE IN (@Lc_StatusNoDataFound_CODE, @Lc_StatusTooManyRows_CODE, @Lc_MsgRaiseexception_CODE, @Lc_MsgKeydatanotfound_CODE)
           BEGIN
            IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 3' + ' ' + @Ls_SqlData_TEXT;
             END
            ELSE
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 4' + ' ' + @Ls_DescriptionError_TEXT;
             END

            IF @Lc_Msg_CODE IN(@Lc_MsgKeydatanotfound_CODE, @Lc_StatusNoDataFound_CODE)
             BEGIN
              SET @Lc_Error_CODE = 'E0958';
             END
            ELSE IF @Lc_Msg_CODE = @Lc_StatusTooManyRows_CODE
             BEGIN
              SET @Lc_Error_CODE = 'E0087';
             END
            ELSE IF @Lc_Msg_CODE = @Lc_MsgRaiseexception_CODE
             BEGIN
              SET @Lc_Error_CODE = 'E1081';
             END

            SET @Ln_Error_QNTY = 1;

            RAISERROR (50001,16,1);
           END
          ELSE
           BEGIN
            SET @Lc_Error_CODE = 'E5000';
            SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED UNEXPECTED ERROR 1' + ' ' + @Ls_DescriptionError_TEXT;
           END
         END
       END
       ELSE IF @Lc_CompCur_ComplianceType_CODE IN(@Lc_ComplianceTypeMissedPayment_CODE, @Lc_ComplianceTypePaymentPlan_CODE)
       BEGIN
        SET @Ls_Sql_TEXT = 'EMON028A : CHECK WHETHER OBLIGATION IS ACTIVE';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '');
        SET @Ln_Obl_Terminated_QNTY = dbo.BATCH_ENF_EMON$SF_CHK_OBLIGATION_TERMINATED (@Ln_CompCur_Case_IDNO, @Ln_CompCur_OrderSeq_NUMB, @Ld_Run_DATE);
        
        IF @Ld_CompCur_End_DATE IN (@Ld_High_DATE, @Ld_Low_DATE)
           BEGIN
            SET @Ld_Compliance_EffEnd_DATE = @Ld_Run_DATE;
           END
          ELSE
           BEGIN
            SET @Ld_Compliance_EffEnd_DATE = @Ld_CompCur_End_DATE;
           END

          SET @Ls_Sql_TEXT = 'EMON040A : SELECT  Worker_IDNO';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', Order_SEQ = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Effective_DATE = ' + ISNULL (CAST (@Ld_CompCur_Effective_DATE AS VARCHAR (MAX)), '');

          SELECT @Ld_Compliance_Eff_DATE = MAX(Effective_DATE)
            FROM (SELECT ISNULL((CASE
                                  WHEN (SELECT TOP 1 LTRIM(RTRIM(b.WorkerUpdate_ID))
                                          FROM UCASE_V1 b
                                         WHERE b.Case_IDNO = @Ln_CompCur_Case_IDNO
                                         ORDER BY b.Update_DTTM)			= @Lc_WorkerUpdateConv_ID
                                   THEN (SELECT a.EffectiveEvent_DATE
                                           FROM GLEV_Y1 a	
                                          WHERE a.EventGlobalSeq_NUMB = (SELECT MIN(l.EventGlobalSeq_NUMB)
                                                                         FROM LSUP_Y1 l
                                                                        WHERE l.Case_IDNO = @Ln_CompCur_Case_IDNO
                                                                          AND l.OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB))
                                  ELSE @Ld_CompCur_Effective_DATE
                                 END), @Ld_CompCur_Effective_DATE) AS Effective_DATE
                  UNION
                  SELECT @Ld_CompCur_Effective_DATE AS Effective_DATE) T;

          SET @Ln_ArrearPast_AMNT = dbo.BATCH_ENF_EMON$SF_GET_ENF_ARREARS(@Ln_CompCur_Case_IDNO, @Ld_Compliance_Eff_DATE);

          SELECT @Ln_ArrearCurrent_AMNT = a.Arrears_AMNT
            FROM ENSD_Y1 a
           WHERE a.Case_IDNO = @Ln_CompCur_Case_IDNO;

          SELECT @Ln_OweTotCurSup_AMNT = ISNULL(SUM(ISNULL(l.OweTotCurSup_AMNT, 0)), 0)
            FROM LSUP_Y1 l 
           WHERE l.Case_IDNO = @Ln_CompCur_Case_IDNO
             AND l.Batch_DATE != @Ld_Low_DATE
             AND l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
             AND l.Distribute_DATE BETWEEN @Ld_CompCur_Effective_DATE AND @Ld_CompCur_End_DATE;

          SET @Ln_OweTotCurSup_AMNT = (ISNULL(@Ln_OweTotCurSup_AMNT, 0) * 12) / 365;

          SELECT @Ln_TotalInterval_NUMB = DATEDIFF(D, @Ld_Compliance_Eff_DATE, @Ld_CompCur_End_DATE);

         IF ((@Ln_Obl_Terminated_QNTY = 0
           AND @Ln_CompCur_PaybackSord_AMNT = 0)
           OR (@Ln_ArrearCurrent_AMNT - @Ln_ArrearPast_AMNT) >= @Ln_OweTotCurSup_AMNT * @Ln_TotalInterval_NUMB)
         BEGIN
          SET @Ls_Sql_TEXT = 'EMON026A : UPDATE VCOMP';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

           UPDATE COMP_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE VCOMP FAILED';

            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON029 : INSERT VCOMP 1';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

           INSERT INTO COMP_Y1
          				(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)
          SELECT a.Compliance_IDNO,
                 a.Case_IDNO,
                 a.OrderSeq_NUMB,
                 a.ComplianceType_CODE,
                 @Lc_ComplianceStatusEnded_CODE ComplianceStatus_CODE,
                 a.Effective_DATE,
                 a.End_DATE,
                 a.Compliance_AMNT,
                 ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                 a.NoMissPayment_QNTY,
                 a.OrderedParty_CODE,
                 @Ld_Run_DATE BeginValidity_DATE,
                 @Ld_High_DATE EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                 dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() Update_DTTM,
                 @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                 a.Entry_DATE
            FROM COMP_Y1 a
           WHERE a.Case_IDNO = @Ln_CompCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND a.Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND a.TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'INSERT VCOMP FAILED';

            RAISERROR (50001,16,1);
           END;
         END
        ELSE
         BEGIN
          
          IF((@Ln_ArrearCurrent_AMNT - @Ln_ArrearPast_AMNT) < (@Ln_OweTotCurSup_AMNT * @Ln_TotalInterval_NUMB))
           BEGIN
            SET @Ls_Sql_TEXT = 'MISSPAY : UPDATE VCOMP';
            SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          UPDATE COMP_Y1
               SET EndValidity_DATE = @Ld_Run_DATE
             WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
               AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
               AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
               AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;
            
            SET @Li_RowCount_QNTY = @@ROWCOUNT;
            IF @Li_RowCount_QNTY = 0
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'MISSPAY :  UPDATE COMP_Y1 FAILED';

              RAISERROR (50001,16,1);
             END;

            SET @Ls_Sql_TEXT = 'EMON034 : INSERT COMP_Y1 2';
            SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

           INSERT INTO COMP_Y1
						(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)		
            SELECT a.Compliance_IDNO,
                   a.Case_IDNO,
                   a.OrderSeq_NUMB,
                   a.ComplianceType_CODE,
                   @Lc_CompliancStatusNoncomp_CODE ComplianceStatus_CODE,
                   a.Effective_DATE,
                   a.End_DATE,
                   a.Compliance_AMNT,
                   ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                   a.NoMissPayment_QNTY,
                   a.OrderedParty_CODE,
                   @Ld_Run_DATE BeginValidity_DATE,
                   @Ld_High_DATE EndValidity_DATE,
                   @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                   dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() Update_DTTM,
                   @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                   a.Entry_DATE
              FROM COMP_Y1 a
             WHERE a.Case_IDNO = @Ln_CompCur_Case_IDNO
               AND a.OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
               AND a.Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
               AND a.TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

            SET @Li_RowCount_QNTY = @@ROWCOUNT;   
            IF @Li_RowCount_QNTY = 0
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'MISSPAY :  UPDATE COMP_Y1 FAILED';

              RAISERROR (50001,16,1);
             END;

            SET @Ls_Sql_TEXT = 'EMON031 : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY 2';
            SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (MAX)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', OthpSource_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', TypeChange_CODE = ' + @Lc_TypeChangeBc_CODE + ', NegPos_CODE = ' + @Lc_NegPosPositive_CODE + ', Job_ID = ' + @Lc_Job_ID + ', DT_CREATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorCompi_CODE + ', Subsystem_CODE = ' + @Lc_SubsystemEnforcement_CODE + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR (19)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TypeReference_CODE = ' + @Lc_TypeReferenceCom_ID + ', Id_Reference = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', Topic_IDNO = ' + ISNULL (CAST (@Ln_Topic_IDNO AS VARCHAR (11)), '');

            EXECUTE BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY
             @An_Case_IDNO                = @Ln_CompCur_Case_IDNO,
             @An_MemberMci_IDNO           = @Ln_CompCur_MemberMci_IDNO,
             @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
             @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCompi_CODE,
             @Ac_Subsystem_CODE           = @Lc_SubsystemEnforcement_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
             @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
             BEGIN
              SET @Lc_Error_CODE = 'E5000';

              IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
               BEGIN
                SET @Ls_Sql_TEXT = 'EMON031B : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 5';
                SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
                SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$P_INSERT_ELFC_OR_ACTIVITY FAILED 5' + ' ' + @Ls_SqlData_TEXT;
               END
              ELSE
               BEGIN
                SET @Ls_Sql_TEXT = 'EMON035A : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 6';
                SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
               END

              RAISERROR (50001,16,1);
             END
           END
         END
       END
      
      ELSE IF @Lc_CompCur_ComplianceType_CODE = @Lc_ComplianceTypePeramt_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'EMON032A : CHECK WHETHER OBLIGATION IS ACTIVE';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '');
        SET @Ln_Obl_Terminated_QNTY = dbo.BATCH_ENF_EMON$SF_CHK_OBLIGATION_TERMINATED (@Ln_CompCur_Case_IDNO, @Ln_CompCur_OrderSeq_NUMB, @Ld_Run_DATE);
        SET @Ls_Sql_TEXT = 'EMON032 :SELECT PERIODIC AMOUNT RECEIVED FROM VRCTH';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', Effective_DATE = ' + ISNULL (CAST (@Ld_CompCur_Effective_DATE AS VARCHAR (20)), '') + ', End_DATE = ' + ISNULL (CAST (@Ld_CompCur_End_DATE AS VARCHAR (20)), '');

      --  Select 'before RCTH select '
        SELECT @Ln_Receipt_AMNT = ISNULL(SUM(ToDistribute_AMNT), 0)
          FROM RCTH_Y1 r
         WHERE (r.Case_IDNO = @Ln_CompCur_Case_IDNO
                 OR r.PayorMCI_IDNO = @Ln_CompCur_MemberMci_IDNO)
           AND r.SourceReceipt_CODE NOT IN (@Lc_SourceReceiptLumpSum_CODE,@Lc_SourceReceiptBond_CODE,@Lc_SourceReceiptWorkcomp_CODE,@Lc_SourceReceiptLevyfidm_CODE,@Lc_SourceReceiptCprecoup_CODE,@Lc_SourceReceiptNsfrecoup_CODE,@Lc_SourceReceiptAc_CODE,@Lc_SourceReceiptAn_CODE)
           AND r.Receipt_AMNT > 0
           AND r.Receipt_DATE BETWEEN @Ld_CompCur_Effective_DATE AND @Ld_CompCur_End_DATE
           AND r.EndValidity_DATE = @Ld_High_DATE
           AND r.StatusReceipt_CODE NOT IN(@Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
           AND NOT EXISTS (SELECT 1
                             FROM ELRP_Y1 i
                            WHERE r.Batch_DATE = i.BatchOrig_DATE
                              AND r.SourceBatch_CODE = i.SourceBatchOrig_CODE
                              AND r.Batch_NUMB = i.BatchOrig_NUMB
                              AND r.SeqReceipt_NUMB = i.SeqReceiptOrig_NUMB);
                              
        -- If Obligation terminated, then update the compliance status to Ended
        IF ((@Ln_Receipt_AMNT >= @Ln_CompCur_Compliance_AMNT
             AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE)
             OR @Ln_Obl_Terminated_QNTY = 0)
         BEGIN
          SET @Ls_Sql_TEXT = 'EMON026C : UPDATE VCOMP';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          UPDATE COMP_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;
           
          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE VCOMP FAILED';
            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON033 : INSERT VCOMP 3';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- INSERT INTO COMP_Y1
          INSERT INTO COMP_Y1
						(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)	
          SELECT a.Compliance_IDNO,
                 a.Case_IDNO,
                 a.OrderSeq_NUMB,
                 a.ComplianceType_CODE,
                 @Lc_ComplianceStatusEnded_CODE ComplianceStatus_CODE,
                 a.Effective_DATE,
                 a.End_DATE,
                 a.Compliance_AMNT,
                 ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                 a.NoMissPayment_QNTY,
                 a.OrderedParty_CODE,
                 @Ld_Run_DATE BeginValidity_DATE,
                 @Ld_High_DATE EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                 dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() Update_DTTM,
                 @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                 a.Entry_DATE
            FROM COMP_Y1 a
           WHERE a.Case_IDNO = @Ln_CompCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND a.Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND a.TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;
 
          SET @Li_RowCount_QNTY = @@ROWCOUNT;

          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'INSERT VCOMP FAILED';
            RAISERROR (50001,16,1);
           END;
         END
        ELSE IF @Ln_Receipt_AMNT < @Ln_CompCur_Compliance_AMNT
           AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE
         BEGIN
          SET @Ls_Sql_TEXT = 'EMON026D : UPDATE VCOMP';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- UPDATE the COMP_Y1 record which meets the criteria
          UPDATE COMP_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE COMP_Y1 FAILED';
            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON034 : INSERT COMP_Y1 2';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- INSERT INTO COMP_Y1
          INSERT INTO COMP_Y1
						(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)
          SELECT a.Compliance_IDNO,
                 a.Case_IDNO,
                 a.OrderSeq_NUMB,
                 a.ComplianceType_CODE,
                 @Lc_CompliancStatusNoncomp_CODE ComplianceStatus_CODE,
                 a.Effective_DATE,
                 a.End_DATE,
                 a.Compliance_AMNT,
                 ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                 a.NoMissPayment_QNTY,
                 a.OrderedParty_CODE,
                 @Ld_Run_DATE BeginValidity_DATE,
                 @Ld_High_DATE EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                 dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() Update_DTTM,
                 @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                 a.Entry_DATE
            FROM COMP_Y1 a
           WHERE a.Case_IDNO = @Ln_CompCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND a.Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND a.TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE COMP_Y1 FAILED 2';
            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON032 : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY 2';
		  SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (MAX)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', OthpSource_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', TypeChange_CODE = ' + @Lc_TypeChangeBc_CODE + ', NegPos_CODE = ' + @Lc_NegPosPositive_CODE + ', Job_ID = ' + @Lc_Job_ID + ', DT_CREATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorCompi_CODE + ', Subsystem_CODE = ' + @Lc_SubsystemEnforcement_CODE + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR (19)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TypeReference_CODE = ' + @Lc_TypeReferenceCom_ID + ', ID_REFERENCE = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', Topic_IDNO = ' + ISNULL (CAST (@Ln_Topic_IDNO AS VARCHAR (11)), '');
		  
          EXECUTE BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY
           @An_Case_IDNO                = @Ln_CompCur_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_CompCur_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCompi_CODE,
           @Ac_Subsystem_CODE           = @Lc_SubsystemEnforcement_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
           
          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Lc_Error_CODE = 'E5000';

            IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
             BEGIN
              SET @Ls_Sql_TEXT = 'EMON031B : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 5';
              SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$P_INSERT_ELFC_OR_ACTIVITY FAILED 5' + ' ' + @Ls_SqlData_TEXT;
             END
            ELSE
             BEGIN
              SET @Ls_Sql_TEXT = 'EMON035A : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 6';
              SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
             END

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE IN (@Lc_StatusNoDataFound_CODE, @Lc_StatusTooManyRows_CODE, @Lc_MsgRaiseexception_CODE, @Lc_MsgKeydatanotfound_CODE)
           BEGIN
            IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 7' + ' ' + @Ls_SqlData_TEXT;
             END
            ELSE
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 8' + ' ' + @Ls_DescriptionError_TEXT;
             END

            IF @Lc_Msg_CODE IN(@Lc_MsgKeydatanotfound_CODE, @Lc_StatusNoDataFound_CODE)
             BEGIN
              SET @Lc_Error_CODE = 'E0958';
             END
            ELSE IF @Lc_Msg_CODE = @Lc_StatusTooManyRows_CODE
             BEGIN
              SET @Lc_Error_CODE = 'E0087';
             END
            ELSE IF @Lc_Msg_CODE = @Lc_MsgRaiseexception_CODE
             BEGIN
              SET @Lc_Error_CODE = 'E1081';
             END

            SET @Ln_Error_QNTY = 1;

            RAISERROR (50001,16,1);
           END 
         END
       END

      ELSE IF @Lc_CompCur_ComplianceType_CODE = @Lc_ComplianceTypeMedical_CODE
       BEGIN

        SET @Ls_Sql_TEXT = 'EMON036 : CHECK ALL DEPENDANTS ENROLLED IN INSURANCE POLICY';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') + ', Status_CODE = ' + @Lc_StatusConfirmedGood_CODE;

        SELECT @Ln_Count_NUMB = COUNT(1)
          FROM CMEM_Y1 c,
               DEMO_Y1 d,
               MPAT_Y1 m
         WHERE c.Case_IDNO = @Ln_CompCur_Case_IDNO
           AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
           AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           AND c.MemberMci_IDNO = d.MemberMci_IDNO
           AND m.MemberMci_IDNO = d.MemberMci_IDNO
           AND m.PaternityEst_INDC <> @Lc_No_INDC
           AND NOT EXISTS (SELECT 1
                             FROM DINS_Y1 n
                            WHERE n.MemberMci_IDNO = @Ln_CompCur_MemberMci_IDNO
                              AND c.MemberMci_IDNO = n.ChildMCI_IDNO
                              AND n.EndValidity_DATE = @Ld_High_DATE
                              AND @Ld_Run_DATE BETWEEN Begin_DATE AND End_DATE
                              AND n.Status_CODE = @Lc_StatusConfirmedGood_CODE);

        IF @Ln_Count_NUMB = 0
           AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE
         BEGIN
          SET @Ls_Sql_TEXT = 'EMON026E : UPDATE VCOMP';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- Update the VCOMP record which meets the criteria
          UPDATE COMP_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE VCOMP FAILED';
            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON037 : INSERT VCOMP 5';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- INSERT INTO COMP_Y1
          INSERT INTO COMP_Y1
						(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)
          SELECT a.Compliance_IDNO,
                 a.Case_IDNO,
                 a.OrderSeq_NUMB,
                 a.ComplianceType_CODE,
                 @Lc_ComplianceStatusEnded_CODE ComplianceStatus_CODE,
                 a.Effective_DATE,
                 a.End_DATE,
                 a.Compliance_AMNT,
                 ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                 a.NoMissPayment_QNTY,
                 a.OrderedParty_CODE,
                 @Ld_Run_DATE BeginValidity_DATE,
                 @Ld_High_DATE EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                 dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()Update_DTTM,
                 @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                 a.Entry_DATE
            FROM COMP_Y1 a
           WHERE a.Case_IDNO = @Ln_CompCur_Case_IDNO
             AND a.OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND a.Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND a.TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'INSERT VCOMP FAILED';
            RAISERROR (50001,16,1);
           END;
         END
        ELSE IF @Ln_Count_NUMB > 0
           AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE
         BEGIN
          SET @Ls_Sql_TEXT = 'EMON026F : UPDATE VCOMP';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- UPDATE the COMP_Y1 record which meets the criteria
          UPDATE COMP_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE COMP_Y1 FAILED';
            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON034 : INSERT COMP_Y1 6';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

          -- INSERT INTO COMP_Y1
          INSERT INTO COMP_Y1
						(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)
          SELECT a.Compliance_IDNO,
                 a.Case_IDNO,
                 a.OrderSeq_NUMB,
                 a.ComplianceType_CODE,
                 @Lc_CompliancStatusNoncomp_CODE ComplianceStatus_CODE,
                 a.Effective_DATE,
                 a.End_DATE,
                 a.Compliance_AMNT,
                 ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                 a.NoMissPayment_QNTY,
                 a.OrderedParty_CODE,
                 @Ld_Run_DATE BeginValidity_DATE,
                 @Ld_High_DATE EndValidity_DATE,
                 @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                 dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()Update_DTTM,
                 @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                 a.Entry_DATE
            FROM COMP_Y1 a
           WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
             AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
             AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
             AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

          SET @Li_RowCount_QNTY = @@ROWCOUNT;
          IF @Li_RowCount_QNTY = 0
           BEGIN
            SET @Ls_DescriptionError_TEXT = 'UPDATE COMP_Y1 FAILED 3';
            RAISERROR (50001,16,1);
           END;

          SET @Ls_Sql_TEXT = 'EMON031 : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY 3';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', OthpSource_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', TypeChange_CODE = ' + @Lc_TypeChangeBc_CODE + ', NegPos_CODE = ' + @Lc_NegPosPositive_CODE + ', Job_ID = ' + @Lc_Job_ID + ', DT_CREATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorCompi_CODE + ', Subsystem_CODE = ' + @Lc_SubsystemEnforcement_CODE + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR (19)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TypeReference_CODE = ' + @Lc_TypeReferenceCom_ID + ', ID_REFERENCE = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', Topic_IDNO = ' + ISNULL (CAST (@Ln_Topic_IDNO AS VARCHAR (11)), '');

          EXECUTE BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY
           @An_Case_IDNO                = @Ln_CompCur_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_CompCur_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCompi_CODE,
           @Ac_Subsystem_CODE           = @Lc_SubsystemEnforcement_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            SET @Lc_Error_CODE = 'E5000';

            IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$P_INSERT_ELFC_OR_ACTIVITY FAILED 9' + ' ' + @Ls_SqlData_TEXT;
             END
            ELSE
             BEGIN
              SET @Ls_Sql_TEXT = 'EMON035A : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 10';
              SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
             END

            RAISERROR (50001,16,1);
           END
          ELSE IF @Lc_Msg_CODE IN (@Lc_StatusNoDataFound_CODE, @Lc_StatusTooManyRows_CODE, @Lc_MsgRaiseexception_CODE, @Lc_MsgKeydatanotfound_CODE)
           BEGIN
            IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 7' + ' ' + @Ls_SqlData_TEXT;
             END
            ELSE
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 8' + ' ' + @Ls_DescriptionError_TEXT;
             END

            IF @Lc_Msg_CODE IN(@Lc_MsgKeydatanotfound_CODE, @Lc_StatusNoDataFound_CODE)
             BEGIN
              SET @Lc_Error_CODE = 'E0958';
             END
            ELSE IF @Lc_Msg_CODE = @Lc_StatusTooManyRows_CODE
             BEGIN
              SET @Lc_Error_CODE = 'E0087';
             END
            ELSE IF @Lc_Msg_CODE = @Lc_MsgRaiseexception_CODE
             BEGIN
              SET @Lc_Error_CODE = 'E1081';
             END

            SET @Ln_Error_QNTY = 1;

            RAISERROR (50001,16,1);
           END
         END
       END
       
      ELSE IF @Lc_CompCur_ComplianceType_CODE = @Lc_ComplianceTypeOther_CODE
         AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE
       BEGIN
       
        SET @Ls_Sql_TEXT = 'EMON045 : BATCH_COMMON$SP_INSERT_ACTIVITY';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', ActivityMajor_CODE = ' + ' CASE ' + ', ActivityMinor_CODE = ' + ' RCMPI ' + ', Subsystem_CODE = ' + ' EN ' + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR (19)), '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') + ', WorkerUpdate_ID  = ' + @Lc_BatchRunUser_TEXT;

        EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
         @An_Case_IDNO                = @Ln_CompCur_Case_IDNO,
         @An_MemberMci_IDNO           = @Ln_CompCur_MemberMci_IDNO,
         @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
         @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRcmpi_CODE,
         @Ac_Subsystem_CODE           = @Lc_SubsystemEnforcement_CODE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
         @Ac_WorkerDelegate_ID        = @Lc_Null_TEXT,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @An_TopicIn_IDNO             = 0,
         @An_Topic_IDNO				  = @Ln_TopicOut_IDNO OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
       END
       
      ELSE IF @Lc_CompCur_ComplianceType_CODE = @Lc_ComplianceTypeLumpSum_CODE
       BEGIN
       
        IF @Ld_CompCur_End_DATE IN (@Ld_High_DATE)
         BEGIN
          SET @Ls_Sql_TEXT = 'EMON046B : VALIDATE LUMP SUM COMPLIANCE TYPE';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR ), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', Effective_DATE = ' + ISNULL (CAST (@Ld_CompCur_Effective_DATE AS VARCHAR (20)), '') + ', End_DATE = ' + ISNULL (CAST (@Ld_CompCur_End_DATE AS VARCHAR (20)), '');
          SET @Lc_Error_CODE = 'E1213';
          SET @Ls_DescriptionError_TEXT = 'DATE END HAS HIGH DATE';
          SET @Ln_Error_QNTY = 1;

          RAISERROR (50001,16,1);
         END

        -- Check Obligation Terminated
        SET @Ls_Sql_TEXT = 'EMON028A : CHECK WHETHER OBLIGATION IS ACTIVE';
        SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '');
        SET @Ln_Obl_Terminated_QNTY = dbo.BATCH_ENF_EMON$SF_CHK_OBLIGATION_TERMINATED (@Ln_CompCur_Case_IDNO, @Ln_CompCur_OrderSeq_NUMB, @Ld_Run_DATE);
        /* COMP screen allows to enter DT_EFFECTIVE less than system date,
        so need to take the least date among effective and entry dates */
        SET @Ld_DATE = @Ld_CompCur_Effective_DATE;
          SET @Ls_Sql_TEXT = 'EMON046 : SELECT LUMPSUM AMOUNT PAID FROM VRCTH';
          SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', Entry_DATE = ' + ISNULL (CAST (@Ld_DATE AS VARCHAR (20)), '');

          SELECT @Ln_Receipt_AMNT = ISNULL(SUM(ToDistribute_AMNT), 0)
            FROM RCTH_Y1 r
           WHERE (r.Case_IDNO = @Ln_CompCur_Case_IDNO
                   OR r.PayorMCI_IDNO = @Ln_CompCur_MemberMci_IDNO)
             AND r.Receipt_AMNT > 0
             -- Date between Compliance Begin Date and Compliance End Date
             AND r.Receipt_DATE BETWEEN @Ld_CompCur_Effective_DATE AND @Ld_CompCur_End_DATE
             AND r.SourceReceipt_CODE NOT IN(@Lc_SourceReceiptAc_CODE, @Lc_SourceReceiptAn_CODE)
             AND r.EndValidity_DATE = @Ld_High_DATE
             AND r.StatusReceipt_CODE NOT IN(@Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
             AND NOT EXISTS (SELECT 1
                               FROM ELRP_Y1 i
                              WHERE r.Batch_DATE = i.BatchOrig_DATE
                                AND r.SourceBatch_CODE = i.SourceBatchOrig_CODE
                                AND r.Batch_NUMB = i.BatchOrig_NUMB
                                AND r.SeqReceipt_NUMB = i.SeqReceiptOrig_NUMB);

          IF ((@Ln_Receipt_AMNT >= @Ln_CompCur_Compliance_AMNT
               AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE)
               OR @Ln_Obl_Terminated_QNTY = 0)
           BEGIN
            SET @Ls_Sql_TEXT = 'EMON026I : UPDATE VCOMP';
            SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (MAX)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (MAX)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (MAX)), '');

            -- Update the VCOMP record which meets the criteria
            UPDATE COMP_Y1
               SET EndValidity_DATE = @Ld_Run_DATE
             WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
               AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
               AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
               AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

            SET @Li_RowCount_QNTY = @@ROWCOUNT;
            IF @Li_RowCount_QNTY = 0
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'UPDATE VCOMP FAILED';

              RAISERROR (50001,16,1);
             END;

            SET @Ls_Sql_TEXT = 'EMON047 : INSERT VCOMP 9';
            SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

            -- INSERT INTO COMP_Y1
            INSERT INTO COMP_Y1
						(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)
            SELECT a.Compliance_IDNO,
                   a.Case_IDNO,
                   a.OrderSeq_NUMB,
                   a.ComplianceType_CODE,
                   @Lc_ComplianceStatusEnded_CODE ComplianceStatus_CODE,
                   a.Effective_DATE,
                   a.End_DATE,
                   a.Compliance_AMNT,
                   ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                   a.NoMissPayment_QNTY,
                   a.OrderedParty_CODE,
                   @Ld_Run_DATE BeginValidity_DATE,
                   @Ld_High_DATE EndValidity_DATE,
                   @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                   dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()Update_DTTM,
                   @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                   a.Entry_DATE
              FROM COMP_Y1 a
             WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
               AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
               AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
               AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

            SET @Li_RowCount_QNTY = @@ROWCOUNT;
            IF @Li_RowCount_QNTY = 0
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'INSERT COMP_Y1 FAILED';

              RAISERROR (50001,16,1);
             END;

           END
          ELSE IF (@Ln_Receipt_AMNT < @Ln_CompCur_Compliance_AMNT
              AND @Ld_Run_DATE >= @Ld_CompCur_End_DATE)
           BEGIN
            SET @Ls_Sql_TEXT = 'EMON026J : UPDATE COMP_Y1';
            SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

            -- UPDATE the COMP_Y1 record which meets the criteria
            UPDATE COMP_Y1
               SET EndValidity_DATE = @Ld_Run_DATE
             WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
               AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
               AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
               AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

            SET @Li_RowCount_QNTY = @@ROWCOUNT;
            IF @Li_RowCount_QNTY = 0
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'UPDATE COMP_Y1 FAILED';

              RAISERROR (50001,16,1);
             END;

            SET @Ls_Sql_TEXT = 'EMON048 : INSERT COMP_Y1 10';
            SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

            -- INSERT INTO COMP_Y1
            INSERT INTO COMP_Y1
						(Compliance_IDNO,
						 Case_IDNO,
						 OrderSeq_NUMB,
						 ComplianceType_CODE,
						 ComplianceStatus_CODE,
						 Effective_DATE,
						 End_DATE,
						 Compliance_AMNT,
						 Freq_CODE,
						 NoMissPayment_QNTY,
						 OrderedParty_CODE,
						 BeginValidity_DATE,
						 EndValidity_DATE,
						 WorkerUpdate_ID,
						 Update_DTTM,
						 TransactionEventSeq_NUMB,
						 Entry_DATE)
            SELECT a.Compliance_IDNO,
                   a.Case_IDNO,
                   a.OrderSeq_NUMB,
                   a.ComplianceType_CODE,
                   @Lc_CompliancStatusNoncomp_CODE ComplianceStatus_CODE,
                   a.Effective_DATE,
                   a.End_DATE,
                   a.Compliance_AMNT,
                   ISNULL(Freq_CODE, @Lc_Null_TEXT) Freq_CODE,
                   a.NoMissPayment_QNTY,
                   a.OrderedParty_CODE,
                   @Ld_Run_DATE BeginValidity_DATE,
                   @Ld_High_DATE EndValidity_DATE,
                   @Lc_BatchRunUser_TEXT WorkerUpdate_ID,
                   dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()Update_DTTM,
                   @Ln_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
                   a.Entry_DATE
              FROM COMP_Y1 a
             WHERE Case_IDNO = @Ln_CompCur_Case_IDNO
               AND OrderSeq_NUMB = @Ln_CompCur_OrderSeq_NUMB
               AND Compliance_IDNO = @Ln_CompCur_Compliance_IDNO
               AND TransactionEventSeq_NUMB = @Ln_CompCur_TransactionEventSeq_NUMB;

            SET @Li_RowCount_QNTY = @@ROWCOUNT;
            IF @Li_RowCount_QNTY = 0
             BEGIN
              SET @Ls_DescriptionError_TEXT = 'UPDATE COMP_Y1 FAILED 6';

              RAISERROR (50001,16,1);
             END;

            SET @Ls_Sql_TEXT = 'EMON031 : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY 5';
            SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Case_IDNO AS VARCHAR (6)), '') + ', OrderSeq_NUMB = ' + ISNULL (CAST (@Ln_CompCur_OrderSeq_NUMB AS VARCHAR (5)), '') + ', MemberMci_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', OthpSource_IDNO = ' + ISNULL (CAST (@Ln_CompCur_MemberMci_IDNO AS VARCHAR (10)), '') + ', TypeChange_CODE = ' + @Lc_TypeChangeBc_CODE + ', NegPos_CODE = ' + @Lc_NegPosPositive_CODE + ', Job_ID = ' + @Lc_Job_ID + ', DT_CREATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (20)), '') + ', ActivityMajor_CODE = ' + @Lc_ActivityMajorCase_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinorCompi_CODE + ', Subsystem_CODE = ' + @Lc_SubsystemEnforcement_CODE + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST (@Ln_TransactionEventSeq_NUMB AS VARCHAR (19)), '') + ', Compliance_IDNO = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', TypeReference_CODE = ' + @Lc_TypeReferenceCom_ID + ', ID_REFERENCE = ' + ISNULL (CAST (@Ln_CompCur_Compliance_IDNO AS VARCHAR (10)), '') + ', Topic_IDNO = ' + ISNULL (CAST (@Ln_Topic_IDNO AS VARCHAR (11)), '');

            EXECUTE BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY
             @An_Case_IDNO                = @Ln_CompCur_Case_IDNO,
             @An_MemberMci_IDNO           = @Ln_CompCur_MemberMci_IDNO,
             @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
             @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorCompi_CODE,
             @Ac_Subsystem_CODE           = @Lc_SubsystemEnforcement_CODE,
             @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
             @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,             
             @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
             @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
             @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

            IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
             BEGIN
              SET @Lc_Error_CODE = 'E5000';

              IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
               BEGIN
                SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$P_INSERT_ELFC_OR_ACTIVITY FAILED 17' + ' ' + @Ls_SqlData_TEXT;
               END
              ELSE
               BEGIN
                SET @Ls_Sql_TEXT = 'EMON031B : BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 18';
                SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
               END

              RAISERROR (50001,16,1);
             END
            ELSE IF @Lc_Msg_CODE IN (@Lc_StatusNoDataFound_CODE, @Lc_StatusTooManyRows_CODE, @Lc_MsgRaiseexception_CODE, @Lc_MsgKeydatanotfound_CODE)
             BEGIN
              IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT))			= ''
               BEGIN
                SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 3' + ' ' + @Ls_SqlData_TEXT;
               END
              ELSE
               BEGIN
                SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_INSERT_ELFC_OR_ACTIVITY FAILED 4' + ' ' + @Ls_DescriptionError_TEXT;
               END

              IF @Lc_Msg_CODE IN(@Lc_MsgKeydatanotfound_CODE, @Lc_StatusNoDataFound_CODE)
               BEGIN
                SET @Lc_Error_CODE = 'E0958';
               END
              ELSE IF @Lc_Msg_CODE = @Lc_StatusTooManyRows_CODE
               BEGIN
                SET @Lc_Error_CODE = 'E0087';
               END
              ELSE IF @Lc_Msg_CODE = @Lc_MsgRaiseexception_CODE
               BEGIN
                SET @Lc_Error_CODE = 'E1081';
               END

              SET @Ln_Error_QNTY = 1;

              RAISERROR (50001,16,1);
             END
           END
       END
 
      EXECUTE BATCH_ENF_EMON$SP_PEWKL_UPDATE_FLAG
       @An_RecordRowNumber_NUMB  = @Ln_Record_No_NUMB,
       @Ac_Process_INDC          = @Lc_Yes_INDC,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      
      IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'EMONW02Z : BATCH_ENF_EMON$SP_PEWKL_UPDATE_FLAG FAILED';
        SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
        RAISERROR (50001,16,1);
       END;
     END TRY

     BEGIN CATCH
     
		IF XACT_STATE() = 1
			BEGIN
			   ROLLBACK TRANSACTION Emon_Cursor_Transaction;
			END
		ELSE
			BEGIN
				SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
				RAISERROR( 50001 ,16,1);
			END
		
		SAVE TRANSACTION Emon_Cursor_Transaction;
      
      SET @Lc_Process_INDC = @Lc_TypeErrorE_CODE;
      SET @Ln_Error_NUMB = ERROR_NUMBER ();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_Error_CODE = @Lc_ErrorBatch_CODE;
        SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

       EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Irsc_Cur_QNTY,
       @Ac_Error_CODE               = @Lc_Error_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      SET @Ln_Error_QNTY = 0;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'EMON050 : BATCH_COMMON$SP_BATE_LOG FAILED';
        SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
        RAISERROR (50001,16,1);
       END;
      ELSE IF @Lc_Error_CODE = @Lc_TypeErrorE_CODE
		BEGIN
			SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
		END 
     END CATCH

     SET @Lc_Process_INDC = @Lc_Yes_INDC;

     /* If the commit frequency is attained, the following is done.
     Reset the commit count, Commit the transaction completed until now.*/
     IF @Ln_Commit_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'VJRTL UPDATE ';
       SET @Ls_SqlData_TEXT = ' Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (MAX)), '') + ', An_Thread_NUMB = ' + ISNULL (CAST (@An_Thread_NUMB AS VARCHAR (MAX)), '');

       UPDATE JRTL_Y1
          SET RecRestart_NUMB = @Ln_Record_No_NUMB + 1,
              RestartKey_TEXT = @Ls_RestartKey_TEXT
        WHERE Job_ID = @Lc_Job_ID
          AND Run_DATE = @Ld_Run_DATE
          AND Thread_NUMB = @An_Thread_NUMB;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;
       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'JRTL_Y1 UPDATE FAILED ';
         SET @Ls_SqlData_TEXT = @Lc_Null_TEXT;
         RAISERROR (50001,16,1);
        END
	
       IF @@TRANCOUNT > 0
        BEGIN
         COMMIT TRANSACTION Emon_Main_Transaction;
         BEGIN TRANSACTION Emon_Main_Transaction;
        END;

       SET @Ln_Commit_QNTY = 0;
      END

     /*If the Erroneous Exceptions are more than the threshold, then we need to
      abend the program. The commit will ensure that the records processed so far without
      any problems are committed. Also the exception entries are committed so
      that it will be easy to determine the error records.*/
     IF @Ln_Exception_QNTY > @Ln_ExceptionThresholdParm_QNTY
        AND @Ln_ExceptionThresholdParm_QNTY > 0
      BEGIN
       COMMIT TRANSACTION Emon_Main_Transaction;
       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_SqlData_TEXT = 'ExceptionThreshold_QNTY = ' + CAST(@Ln_Exception_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';
       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM Comp_CUR INTO @Ln_CompCur_RecordRowNumber_NUMB, @Ln_CompCur_Case_IDNO, @Ln_CompCur_OrderSeq_NUMB, @Ln_CompCur_MemberMci_IDNO, @Lc_CompCur_ComplianceType_CODE, @Ln_CompCur_Compliance_AMNT, @Ln_CompCur_NoMissPayment_QNTY, @Ld_CompCur_Entry_DATE, @Ld_CompCur_Effective_DATE, @Ld_CompCur_End_DATE, @Ln_CompCur_Compliance_IDNO, @Ln_CompCur_TransactionEventSeq_NUMB, @Ln_CompCur_PaybackSord_AMNT, @Lc_CompCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    --- WHILE LOOP ENDS
    END

    CLOSE Comp_CUR;
    DEALLOCATE Comp_CUR;
    
   SELECT @Ln_Tmp_Update_QNTY  = COUNT(1)
     FROM PEWKL_Y1 a
    WHERE a.Process_INDC = @Lc_No_INDC;

   --PARM date will be updated only if all the threads are completed.
   --The above check determines whether all records are processed thro the thread
   IF @Ln_Tmp_Update_QNTY  = 0
    BEGIN
     -- Update the daily_date field for this procedure in vparm table with the pd_dt_run value
     SET @Ls_Sql_TEXT = 'EMON052 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
     SET @Ls_SqlData_TEXT = ' Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR (MAX)), '');

     EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
      @Ac_Job_ID              = @Lc_Job_ID,
      @Ad_Run_DATE              = @Ld_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'EMON052A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

       RAISERROR (50001,16,1);
      END;
    END

   SET @Ls_ListKey_TEXT = @Ls_ListKey_TEXT + ' THREAD NUMBER ' + ISNULL (CAST (@An_Thread_NUMB AS VARCHAR (MAX)), '') + 'STARTING THREAD VALUE ' + ISNULL (CAST (@Ln_RecStart_NUMB AS VARCHAR (MAX)), '') + 'ENDING THREAD VALUE ' + ISNULL (CAST (@Ln_RecEnd_NUMB AS VARCHAR (MAX)), '');

   -- Updating the log with result
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = LC_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Null_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @Ls_DescriptionError_TEXT = @Lc_Null_TEXT;


   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION Emon_Main_Transaction;
    END
  END TRY

  BEGIN CATCH
 
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION Emon_Main_Transaction;
    END
	IF CURSOR_STATUS ('LOCAL','Comp_CUR') IN (0,1)
	BEGIN
		CLOSE Comp_CUR;
		DEALLOCATE Comp_CUR;
	END
	
	--- Updating JRTL to ThreadProcess_CODE 'A' to restart the job again
     UPDATE JRTL_Y1
		SET  ThreadProcess_CODE = @Lc_StatusAbnormalend_CODE
		FROM JRTL_Y1 AS a
		WHERE a.Job_ID = @Lc_Job_ID
		AND ThreadProcess_CODE = @Lc_ThreadLocked_INDC
		AND a.Run_DATE = @Ld_Run_DATE
		AND a.Thread_NUMB = @An_Thread_NUMB;

	SET @Ln_Error_NUMB = ERROR_NUMBER ();
	SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

	IF @Ln_Error_NUMB <> 50001
	BEGIN
		SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
	END	
	
   SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;

	EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
												   @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
												   @As_Sql_TEXT = @Ls_Sql_TEXT,
												   @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
												   @An_Error_NUMB = @Li_Error_NUMB,
												   @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
												   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   -- Updating the log with result
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Null_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_ID,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);

  END CATCH;
 END


GO
