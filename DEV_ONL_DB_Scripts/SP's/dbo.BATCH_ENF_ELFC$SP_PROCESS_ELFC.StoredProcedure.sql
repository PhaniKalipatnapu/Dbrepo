/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_PROCESS_ELFC]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_ELFC$SP_PROCESS_ELFC
Programmer Name		: IMP Team
Description			: This process reads records from ELFC_Y1 table and initiates/closes remedies based on the
					  TypeChange_CODE and NegPos_CODE.
Frequency			: 'DAILY'
Developed On		: 07/06/2011
Called BY			: None
Called On	        : BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_COMMON$SP_GET_THREAD_DETAILS, BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
					  BATCH_COMMON$SP_BATE_LOG, BATCH_COMMON$SP_BSTL_LOG, BATCH_ENF_ELFC$SP_CHECK_INSERT and BATCH_ENF_ELFC$SP_CLOSE_REMEDY
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_PROCESS_ELFC]
	@An_Thread_NUMB NUMERIC(15)
AS
 BEGIN  
  SET NOCOUNT ON;
  DECLARE  @Lc_Percentage_TEXT				CHAR(1)			= '%',
           @Lc_Space_TEXT					CHAR(1)			= ' ',
           @Lc_NegPosPositive_CODE			CHAR(1)			= 'P',
           @Lc_NegPosNegative_CODE			CHAR(1)			= 'N',
           @Lc_StatusAbnormalend_CODE		CHAR(1)			= 'A',
           @Lc_StatusFailed_CODE			CHAR(1)			= 'F',
           @Lc_TypeErrorE_CODE				CHAR(1)			= 'E',
           @Lc_StatusSuccess_CODE			CHAR(1)			= 'S',
           @Lc_MsgG1_CODE					CHAR(1)			= 'G',
           @Lc_MsgE1_CODE					CHAR(1)			= 'E',
           @Lc_ThreadLocked_INDC			CHAR(1)			= 'L',
           @Lc_TypeOrderVoluntary_CODE		CHAR(1)			= 'V',
           @Lc_TypeChangeIw_CODE			CHAR(2)			= 'IW',
           @Lc_TypeChangeLi_CODE			CHAR(2)			= 'LI',
           @Lc_TypeChangeMp_CODE			CHAR(2)			= 'MP',
           @Lc_TypeChangeRa_CODE			CHAR(2)			= 'RA',
           @Lc_TypeChangeRe_CODE			CHAR(2)			= 'RE',
           @Lc_TypeChangeRm_CODE			CHAR(2)			= 'RM',
           @Lc_TypeChangeRn_CODE			CHAR(2)			= 'RN',
           @Lc_TypeChangeCr_CODE			CHAR(2)			= 'CR',
           @Lc_TypeChangeCl_CODE			CHAR(2)			= 'CL',
           @Lc_TypeChangeDm_CODE			CHAR(2)			= 'DM',
           @Lc_TypeChangeLt_CODE			CHAR(2)			= 'LT',
           @Lc_TypeChangeLs_CODE			CHAR(2)			= 'LS',
           @Lc_TypeChangeCa_CODE			CHAR(2)			= 'CA',
           @Lc_TypeChangeNm_CODE			CHAR(2)			= 'NM',
           @Lc_TypeChangeIr_CODE			CHAR(2)			= 'IR',
           @Lc_TypeChangeEm_CODE			CHAR(2)			= 'EM',
           @Lc_TypeChangeEp_CODE			CHAR(2)			= 'EP',
           @Lc_TypeChangeCc_CODE			CHAR(2)			= 'CC',
           @Lc_TypeChangeEe_CODE			CHAR(2)			= 'EE',
           @Lc_TypeChangeEt_CODE			CHAR(2)			= 'ET',
           @Lc_TypeChangeOt_CODE			CHAR(2)			= 'OT',
           @Lc_TypeChangeNs_CODE			CHAR(2)			= 'NS',
           @Lc_TypeChangeSt_CODE			CHAR(2)			= 'ST',
           @Lc_TypeChangeLo_CODE			CHAR(2)			= 'LO',
           @Lc_TypeChangeLc_CODE			CHAR(2)			= 'LC',
           @Lc_TypeChangePd_CODE			CHAR(2)			= 'PD',
		   @Lc_TypeChangeDl_CODE			CHAR(2)			= 'DL',
		   @Lc_TypeChangeMm_CODE			CHAR(2)			= 'MM',          
		   @Lc_TypeChangeSm_CODE			CHAR(2)			= 'SM',
		   @Lc_TypeChangeTm_CODE			CHAR(2)			= 'TM',
		   @Lc_TypeChangeYe_CODE			CHAR(2)			= 'YE',  
		   @Lc_TypeChangeIl_CODE			CHAR(2)			= 'IL',
           @Lc_SubsystemEnforcement_CODE	CHAR(2)			= 'EN',
           @Lc_ActivityMajorImiw_CODE		CHAR(4)			= 'IMIW',
           @Lc_ActivityMajorLien_CODE		CHAR(4)			= 'LIEN',
           @Lc_ActivityMajorEmnp_CODE		CHAR(4)			= 'EMNP',
           @Lc_ActivityMajorMapp_CODE		CHAR(4)			= 'MAPP',
           @Lc_ActivityMajorObra_CODE		CHAR(4)			= 'OBRA',
           @Lc_ActivityMajorCrpt_CODE		CHAR(4)			= 'CRPT',
           @Lc_ActivityMajorCsln_CODE		CHAR(4)			= 'CSLN',
           @Lc_ActivityMajorFidm_CODE		CHAR(4)			= 'FIDM',
           @Lc_ActivityMajorLint_CODE		CHAR(4)			= 'LINT',
           @Lc_ActivityMajorLsnr_CODE		CHAR(4)			= 'LSNR',
           -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Start
           @Lc_ActivityMajorCpls_CODE		CHAR(4)			= 'CPLS',
           -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - End
           @Lc_ActivityMajorNmsn_CODE		CHAR(4)			= 'NMSN',
           @Lc_ActivityMajorIrsc_CODE		CHAR(4)			= 'IRSC',
           @Lc_ActivityMajorEmnd_CODE		CHAR(4)			= 'EMND',
           @Lc_ActivityMajorCclo_CODE		CHAR(4)			= 'CCLO',
           @Lc_ActivityMajorCase_CODE		CHAR(4)			= 'CASE',
           @Lc_StatusStart_CODE				CHAR(4)			= 'STRT',
           @Lc_ErrorBatch_CODE				CHAR(5)			= 'E1424',
           @Lc_ErrorI0062_CODE				CHAR(5)			= 'I0062',
           @Lc_ErrorE1176_CODE				CHAR(5)			= 'E1176',
           @Lc_JobPre_ID					CHAR(7)			= 'DEB9991',
           @Lc_Job_ID                       CHAR(7)			= 'DEB0665',
           @Lc_Successful_TEXT				CHAR(20)		= 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT			CHAR(30)		= 'BATCH',
           @Ls_Process_NAME                 VARCHAR(100)	= 'BATCH_ENF_ELFC',
           @Ls_Procedure_NAME				VARCHAR(100)	= 'SP_PROCESS_ELFC',
           @Ld_High_DATE					DATE			= '12/31/9999';
           
  DECLARE  @Ln_OrderSeq_NUMB                NUMERIC(2)		= 0,
           @Ln_CommitFreq_NUMB              NUMERIC(5),
           @Ln_ExceptionThreshold_NUMB      NUMERIC(5),
           @Ln_QNTY                         NUMERIC(5)		= 0,
           @Ln_Case_IDNO                    NUMERIC(6),
           @Ln_Cursor_QNTY                  NUMERIC(10)		= 0,
           @Ln_Exception_QNTY               NUMERIC(10)		= 0,
           @Ln_Commit_QNTY                  NUMERIC(10)		= 0,
           @Ln_IelfcRecordUpdate_QNTY       NUMERIC(11,2)	= 0,
           @Ln_MemberMci_IDNO               NUMERIC(10),
           @Ln_OthpSource_IDNO              NUMERIC(10),
           @Ln_OthpActivityMajorSource_IDNO NUMERIC(10),
           @Ln_Error_NUMB                   NUMERIC(10),
           @Ln_ErrorLine_NUMB               NUMERIC(10),
           @Ln_FetchStatus_QNTY             NUMERIC(10),
           @Ln_RowCount_QNTY                NUMERIC(10),
           @Ln_RecStart_NUMB                NUMERIC(15),
           @Ln_RecRestart_NUMB              NUMERIC(15),
           @Ln_RecEnd_NUMB                  NUMERIC(15),
           @Ln_TransactionEventSeq_NUMB     NUMERIC(19),
           @Lc_Null_TEXT                    CHAR(1)			= '',
           @Lc_NegPos_CODE                  CHAR(1),
           @Lc_TypeOthp_CODE                CHAR(1),
           @Lc_TypeChange_CODE              CHAR(2),
           @Lc_TypeReference_CODE           CHAR(5),
           @Lc_ActivityMajor_CODE           CHAR(4),
           @Lc_Error_CODE                   CHAR(5),
           @Lc_Msg_CODE                     CHAR(5),
           @Lc_Reference_ID                 CHAR(30),
           @Ls_Sql_TEXT                     VARCHAR(100),
           @Ls_Sqldata_TEXT                 VARCHAR(1000),
           @Ls_DescriptionError_TEXT        VARCHAR(MAX),         
           @Ld_Run_DATE                     DATE,
           @Ld_LastRun_DATE                 DATE,
           @Ld_Start_DATE                   DATETIME2,
           @Lb_ExceptionRaised_BIT          BIT				= 0;
           
   DECLARE @Ln_EnfLocCur_RecordRowNumber_NUMB		NUMERIC(15), 
		   @Ln_Record_NUMB							NUMERIC(15),
		   @Ln_EnfLocCur_Case_IDNO					NUMERIC(6),
           @Ln_EnfLocCur_OrderSeq_NUMB				NUMERIC(2),
           @Ln_EnfLocCur_MemberMci_IDNO				NUMERIC(10),
           @Ln_EnfLocCur_OthpSource_IDNO			NUMERIC(10),
           @Ls_RestartKey_TEXT						VARCHAR(200),
           @Lc_EnfLocCur_TypeChange_CODE			CHAR(2),
           @Lc_EnfLocCur_NegPos_CODE				CHAR(1),
           @Lc_EnfLocCur_TypeReference_CODE			CHAR(5),
           @Lc_EnfLocCur_Reference_ID				CHAR(30),
           @Ln_EnfLocCur_TransactionEventSeq_NUMB	NUMERIC(19),
           @Ld_EnfLocCur_Update_DTTM				DATETIME2,
           @Ld_EnfLocCur_Create_DATE				DATE,
           @Lc_EnfLocCur_WorkerUpdate_ID			CHAR(30),
           @Lc_EnfLocCur_Process_ID					CHAR (10);          
  DECLARE  @Ln_RemCloseCur_OthpSource_IDNO			NUMERIC(10),
           @Lc_RemCloseCur_TypeReference_CODE		CHAR(5),
           @Lc_RemCloseCur_Reference_ID				CHAR(30);  

  BEGIN TRY
  
   BEGIN TRANSACTION Elfc_Main_Transaction;
   
   SET @Ls_Sql_TEXT = 'ELFC001 : GET BATCH START TIME';
   SET @Ls_Sqldata_TEXT = @Lc_Null_TEXT;
   -- Initiating the Batch start Date and Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'ELFC002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + @Lc_Job_ID;

   -- Fetching date run, date last run, commit freq, exception threshold details
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_NUMB OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   --Date Run Validation
   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ELFC002A : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'ELFC003 : CHECKING BATCH LAST RUN DATE';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS CHAR(10)) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));   

   --Last Run Date Validation
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END
    
    SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK';
	SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10)) + ', PreJob_ID = ' + @Lc_JobPre_ID;
		
	EXECUTE BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_JobPre_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    
    IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'ELFC003 1 : BATCH_COMMON$SP_PREDECESSOR_JOB_CHECK FAILED' + @Ls_DescriptionError_TEXT;
     RAISERROR(50001,16,1);
    END
    
    SET @Ls_Sql_TEXT = 'EXEC BATCH_COMMON$SP_GET_THREAD_DETAILS ELFC';
    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID 
						+ ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10)) 
						+ ', Thread_NUMB = ' + CAST(@An_Thread_NUMB AS VARCHAR);
						
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
     SET @Ls_DescriptionError_TEXT = 'ELFC003 2 : BATCH_COMMON$SP_GET_THREAD_DETAILS FAILED '+ ISNULL(@Ls_DescriptionError_TEXT,'');
     RAISERROR(50001,16,1);
    END
    						
   SET @Ls_Sql_TEXT = 'ELFC004 : ELFC DAILY CURSOR';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
     
   --Enforcement Locate Cursor
   DECLARE EnfLoc_CUR INSENSITIVE CURSOR FOR 
    SELECT c.RecordRowNumber_NUMB,
		   c.Case_IDNO,
           c.OrderSeq_NUMB,
           c.MemberMci_IDNO,
           CASE WHEN c.OthpSource_IDNO > 0 THEN c.OthpSource_IDNO
				ELSE NULL
		   END OthpSource_IDNO,
           c.TypeChange_CODE,
           c.NegPos_CODE,
           c.TypeReference_CODE,
           CASE WHEN LTRIM(RTRIM(c.Reference_ID)) != '' THEN c.Reference_ID
				ELSE NULL
			END Reference_ID,
           c.TransactionEventSeq_NUMB,
           c.Update_DTTM,
           c.Create_DATE,
           c.WorkerUpdate_ID,
           LTRIM(RTRIM(c.Process_ID)) Process_ID
      FROM IELFC_Y1 c
     WHERE c.RecordRowNumber_NUMB >= @Ln_RecRestart_NUMB
       AND c.RecordRowNumber_NUMB <= @Ln_RecEnd_NUMB
       AND c.Process_DATE = @Ld_High_DATE
     ORDER BY c.RecordRowNumber_NUMB;

   OPEN EnfLoc_CUR;

   FETCH NEXT FROM EnfLoc_CUR INTO @Ln_EnfLocCur_RecordRowNumber_NUMB,@Ln_EnfLocCur_Case_IDNO, @Ln_EnfLocCur_OrderSeq_NUMB, @Ln_EnfLocCur_MemberMci_IDNO, @Ln_EnfLocCur_OthpSource_IDNO, @Lc_EnfLocCur_TypeChange_CODE, @Lc_EnfLocCur_NegPos_CODE, @Lc_EnfLocCur_TypeReference_CODE, @Lc_EnfLocCur_Reference_ID, @Ln_EnfLocCur_TransactionEventSeq_NUMB, @Ld_EnfLocCur_Update_DTTM, @Ld_EnfLocCur_Create_DATE, @Lc_EnfLocCur_WorkerUpdate_ID, @Lc_EnfLocCur_Process_ID;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS; 

   WHILE @Ln_FetchStatus_QNTY = 0
	BEGIN
		
		 SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
		 SET @Ln_Commit_QNTY = @Ln_Commit_QNTY + 1;
		 SET @Ln_Record_NUMB = @Ln_EnfLocCur_RecordRowNumber_NUMB;		
		 SET @Lc_Error_CODE = @Lc_ErrorBatch_CODE;
		 SET @Ls_RestartKey_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS CHAR(6)),'0') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '0') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '0') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '0');

		 IF @Ln_EnfLocCur_TransactionEventSeq_NUMB = 0
		  BEGIN
			   SET @Ls_Sql_TEXT = ' ELFC006 : GENERATE TransactionEventSeq_NUMB ';
			   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

			   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
				@Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
				@Ac_Process_ID               = @Lc_EnfLocCur_Process_ID,
				@Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
				@Ac_Note_INDC                = 'N',
				@An_EventFunctionalSeq_NUMB  = 0,
				@An_TransactionEventSeq_NUMB = @Ln_EnfLocCur_TransactionEventSeq_NUMB OUTPUT,
				@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

			   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
				BEGIN
					RAISERROR(50001,16,1);
				END;
		  END
				  
		 SET @Ln_Case_IDNO = @Ln_EnfLocCur_Case_IDNO;
		 SET @Ln_OrderSeq_NUMB = @Ln_EnfLocCur_OrderSeq_NUMB;
		 SET @Ln_MemberMci_IDNO = @Ln_EnfLocCur_MemberMci_IDNO;
		 SET @Ln_OthpSource_IDNO = @Ln_EnfLocCur_OthpSource_IDNO;
		 SET @Lc_TypeChange_CODE = @Lc_EnfLocCur_TypeChange_CODE;
		 SET @Lc_NegPos_CODE = @Lc_EnfLocCur_NegPos_CODE;
		 SET @Lc_TypeReference_CODE = @Lc_EnfLocCur_TypeReference_CODE;
		 SET @Lc_Reference_ID = @Lc_EnfLocCur_Reference_ID;
		 SET @Ln_TransactionEventSeq_NUMB = @Ln_EnfLocCur_TransactionEventSeq_NUMB;
			 
		BEGIN TRY
			 SAVE TRANSACTION Elfc_Cursor_Transaction;
			 
			 IF @Lc_TypeChange_CODE != @Lc_TypeChangeCc_CODE AND @Ln_OrderSeq_NUMB = 0
				BEGIN
				 SELECT @Ln_OrderSeq_NUMB = ISNULL(OrderSeq_NUMB, 0)
				   FROM SORD_Y1 s
				  WHERE s.Case_IDNO = @Ln_EnfLocCur_Case_IDNO
					AND @Ld_Run_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
					AND s.EndValidity_DATE = @Ld_High_DATE
					AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE;
				END
			 
			 -- Checking whether the Key information exist or not
			 IF @Ln_Case_IDNO = 0
				 -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Start
				 OR (@Ln_OrderSeq_NUMB = 0 AND @Lc_TypeChange_CODE NOT IN ( @Lc_TypeChangeCc_CODE, @Lc_TypeChangeCa_CODE, @Lc_TypeChangeIl_CODE, @Lc_TypeChangeLo_CODE ))
				 -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - End
				 OR @Ln_MemberMci_IDNO = 0
				 OR LTRIM(RTRIM(@Lc_TypeChange_CODE)) = ''
				 OR (LTRIM(RTRIM(@Lc_NegPos_CODE)) = ''
					  OR LTRIM(RTRIM(@Lc_NegPos_CODE)) NOT IN (@Lc_NegPosPositive_CODE, @Lc_NegPosNegative_CODE))
				  BEGIN
					SET @Ls_Sql_TEXT = 'ELFC007 : FETCH NEXT FROM ELFC INFORMATION';
					SET @Ls_DescriptionError_TEXT = 'Required Data Missing in the trigger';
                    SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '0') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '0') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '0');
					SET @Lc_Error_CODE = @Lc_ErrorE1176_CODE;
					RAISERROR (50001,16,1);
				  END
		END TRY
		BEGIN CATCH
			IF XACT_STATE() = 1
			BEGIN
			   ROLLBACK TRANSACTION Elfc_Cursor_Transaction;
			END
			ELSE
			BEGIN
				SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
				RAISERROR( 50001 ,16,1);
			END
		
			SET @Ln_Error_NUMB = ERROR_NUMBER ();
			SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

			IF @Ln_Error_NUMB <> 50001
			BEGIN
				SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
			END

			EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
			@As_Procedure_NAME        = @Ls_Procedure_NAME,
			@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
			@As_Sql_TEXT              = @Ls_Sql_TEXT,
			@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
			@An_Error_NUMB            = @Ln_Error_NUMB,
			@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
			@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
		  
			SET @Lc_Error_CODE = ISNULL(@Lc_Error_CODE,@Lc_ErrorE1176_CODE);
			EXECUTE BATCH_COMMON$SP_BATE_LOG
			 @As_Process_NAME             = @Ls_Process_NAME,
			 @As_Procedure_NAME           = @Ls_Procedure_NAME,
			 @Ac_Job_ID                   = @Lc_Job_ID,
			 @Ad_Run_DATE                 = @Ld_Run_DATE,
			 @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
			 @An_Line_NUMB                = @Ln_Cursor_QNTY,
			 @Ac_Error_CODE               = @Lc_Error_CODE,
			 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
			 @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
			 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
				SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG 1 FAILED : ' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
				RAISERROR (50001, 16, 1); 
			END
			ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
			BEGIN
				SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
			END	
			SET @Lb_ExceptionRaised_BIT = 1;
		 END CATCH
				 
		 IF (@Lc_NegPos_CODE = @Lc_NegPosPositive_CODE AND @Lb_ExceptionRaised_BIT = 0)
			BEGIN
				BEGIN TRY
					IF @Lc_TypeChange_CODE IN (	@Lc_TypeChangeIw_CODE, -- IMIW
											  @Lc_TypeChangeLi_CODE, -- LIEN
											  @Lc_TypeChangeMp_CODE, -- MAPP
											  @Lc_TypeChangeRa_CODE, -- OBRA Current Assistance
											  @Lc_TypeChangeRe_CODE, -- OBRA Foster Care
											  @Lc_TypeChangeRm_CODE, -- OBRA Medicaid Only
											  @Lc_TypeChangeRn_CODE, -- OBRA Never Assistance
											  @Lc_TypeChangeCr_CODE, -- CPRT
											  @Lc_TypeChangeCl_CODE, -- CSLN
											  @Lc_TypeChangeDm_CODE, -- FIDM
											  @Lc_TypeChangeLt_CODE, -- LINT
											  @Lc_TypeChangeLs_CODE, -- LSNR Non Capias
											  @Lc_TypeChangeCa_CODE, -- LSNR Capias
											  @Lc_TypeChangeNm_CODE, -- NMSN
											  @Lc_TypeChangeIr_CODE, -- IRSC
											  @Lc_TypeChangeEm_CODE, -- EMNP
											  @Lc_TypeChangeEp_CODE, -- EMNP
											  @Lc_TypeChangeCc_CODE,-- CCLO,
											  @Lc_TypeChangeDl_CODE, -- CASE
											  @Lc_TypeChangeLo_CODE, -- CASE
											  @Lc_TypeChangeMm_CODE, -- CASE
											  @Lc_TypeChangeSm_CODE, -- CASE
											  @Lc_TypeChangeTm_CODE, -- CASE
											  @Lc_TypeChangeYe_CODE, -- CASE
											  @Lc_TypeChangeIl_CODE -- CASE
											 )
						BEGIN
							 SELECT @Lc_ActivityMajor_CODE = CASE @Lc_TypeChange_CODE
															  WHEN @Lc_TypeChangeIw_CODE
															   THEN @Lc_ActivityMajorImiw_CODE
															  WHEN @Lc_TypeChangeLi_CODE
															   THEN @Lc_ActivityMajorLien_CODE
															  WHEN @Lc_TypeChangeMp_CODE
															   THEN @Lc_ActivityMajorMapp_CODE
															  WHEN @Lc_TypeChangeRa_CODE
															   THEN @Lc_ActivityMajorObra_CODE
															  WHEN @Lc_TypeChangeRe_CODE
															   THEN @Lc_ActivityMajorObra_CODE
															  WHEN @Lc_TypeChangeRm_CODE
															   THEN @Lc_ActivityMajorObra_CODE
															  WHEN @Lc_TypeChangeRn_CODE
															   THEN @Lc_ActivityMajorObra_CODE
															  WHEN @Lc_TypeChangeCr_CODE
															   THEN @Lc_ActivityMajorCrpt_CODE
															  WHEN @Lc_TypeChangeCl_CODE
															   THEN @Lc_ActivityMajorCsln_CODE
															  WHEN @Lc_TypeChangeDm_CODE
															   THEN @Lc_ActivityMajorFidm_CODE
															  WHEN @Lc_TypeChangeLt_CODE
															   THEN @Lc_ActivityMajorLint_CODE
															  WHEN @Lc_TypeChangeLs_CODE
															   THEN @Lc_ActivityMajorLsnr_CODE
															  WHEN @Lc_TypeChangeCa_CODE
															   THEN CASE WHEN EXISTS (SELECT 1
																						FROM SORD_Y1 s
																					   WHERE s.Case_IDNO = @Ln_Case_IDNO
																					     AND s.EndValidity_DATE = @Ld_High_DATE)
																		THEN @Lc_ActivityMajorLsnr_CODE
																		ELSE @Lc_ActivityMajorCpls_CODE
																	END
															  WHEN @Lc_TypeChangeNm_CODE
															   THEN @Lc_ActivityMajorNmsn_CODE
															  WHEN @Lc_TypeChangeIr_CODE
															   THEN @Lc_ActivityMajorIrsc_CODE
															  WHEN @Lc_TypeChangeEm_CODE
															   THEN @Lc_ActivityMajorEmnp_CODE
															  WHEN @Lc_TypeChangeEp_CODE
															   THEN @Lc_ActivityMajorEmnp_CODE
															  WHEN @Lc_TypeChangeCc_CODE
															   THEN @Lc_ActivityMajorCclo_CODE
															  ELSE	
																 @Lc_ActivityMajorCase_CODE
															 END;

							 SELECT @Ln_OthpActivityMajorSource_IDNO = CASE @Lc_ActivityMajor_CODE
																		WHEN @Lc_ActivityMajorImiw_CODE
																		 THEN @Ln_OthpSource_IDNO
																		WHEN @Lc_ActivityMajorLien_CODE
																		 THEN @Ln_OthpSource_IDNO
																		WHEN @Lc_ActivityMajorCsln_CODE
																		 THEN @Ln_OthpSource_IDNO
																		WHEN @Lc_ActivityMajorFidm_CODE
																		 THEN @Ln_OthpSource_IDNO
																		WHEN @Lc_ActivityMajorLsnr_CODE
																		 THEN @Ln_OthpSource_IDNO
																		WHEN @Lc_ActivityMajorCpls_CODE
																		 THEN @Ln_OthpSource_IDNO
																		WHEN @Lc_ActivityMajorNmsn_CODE
																		 THEN @Ln_OthpSource_IDNO
																		WHEN @Lc_ActivityMajorEmnp_CODE
																		 THEN @Ln_OthpSource_IDNO
																		ELSE @Ln_MemberMci_IDNO
																	   END;
																	   
							IF @Lc_TypeChange_CODE =  @Lc_TypeChangeMm_CODE
								BEGIN
									 SET @Ln_OthpActivityMajorSource_IDNO = @Ln_OthpSource_IDNO
								END

							SET @Ls_Sql_TEXT = 'ELFC008 : SELECT ELFC_Y1 - CHECK NEGATIVE TRIGGER EXISTS FOR THE SAME READY';
							SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', MemberMci_IDNO = ' + ISNULL (CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPosNegative_CODE, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_EnfLocCur_Update_DTTM AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', CD_TYPE_CHAGE = ' + ISNULL(@Lc_TypeChange_CODE, '');

							 SELECT @Ln_QNTY = COUNT(1)
							   FROM ELFC_Y1 e
							  WHERE e.Case_IDNO = @Ln_Case_IDNO
								AND e.MemberMci_IDNO = @Ln_MemberMci_IDNO
								AND e.NegPos_CODE = @Lc_NegPosNegative_CODE
								AND e.Update_DTTM > @Ld_EnfLocCur_Update_DTTM
								AND e.Process_DATE = @Ld_High_DATE
								AND ((@Lc_ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
									  AND e.TypeChange_CODE IN (@Lc_TypeChangeEe_CODE, @Lc_TypeChangeOt_CODE, @Lc_TypeChangeSt_CODE, @Lc_TypeChangeEt_CODE))
									  OR
									 (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
									  AND e.TypeChange_CODE IN (@Lc_TypeChangeSt_CODE, @Lc_TypeChangeLc_CODE))
									  OR
									 (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorLsnr_CODE
									  AND e.TypeChange_CODE = @Lc_TypeChangeSt_CODE)
									  OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorNmsn_CODE
										  AND e.TypeChange_CODE IN (@Lc_TypeChangeEe_CODE, @Lc_TypeChangeNs_CODE, @Lc_TypeChangeSt_CODE, @Lc_TypeChangeLc_CODE))--OR 
									);

							 IF @Ln_QNTY >= 1
							  BEGIN
									SET @Lc_Error_CODE = @Lc_ErrorI0062_CODE;
									SET @Ls_DescriptionError_TEXT = 'Negative Request Exists for the Same Key';
									RAISERROR(50001,16,1);
							  END
							 ELSE
							  BEGIN
							   SET @Ls_Sql_TEXT = 'ELFC010 : SELECT ELFC_Y1 - CHECK REMEDY PROCESSED FOR THE RUN DATE ALREADY';
							   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10)) + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '');

							   --Checking whether the Remedy for the below given input has been checked and processed on the given run date
							   IF @Lc_ActivityMajor_CODE != @Lc_ActivityMajorCclo_CODE
								BEGIN
								   SELECT @Ln_QNTY = COUNT(1)
									 FROM ELFC_Y1 e
									WHERE e.Case_IDNO = @Ln_Case_IDNO
									  AND e.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
									  AND e.MemberMci_IDNO = @Ln_MemberMci_IDNO
									  AND e.OthpSource_IDNO = @Ln_OthpSource_IDNO
									  AND e.TypeReference_CODE = @Lc_TypeReference_CODE
									  AND e.Reference_ID = @Lc_Reference_ID
									  AND e.NegPos_CODE = @Lc_NegPos_CODE
									  AND ((@Lc_ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
											AND e.TypeChange_CODE = @Lc_TypeChangeIw_CODE)
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorLien_CODE
												AND e.TypeChange_CODE = @Lc_TypeChangeLi_CODE)
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
												AND e.TypeChange_CODE IN (@Lc_TypeChangeRa_CODE, @Lc_TypeChangeRe_CODE, @Lc_TypeChangeRm_CODE, @Lc_TypeChangeRn_CODE))
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
												AND e.TypeChange_CODE = @Lc_TypeChangeCr_CODE)
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE
												AND e.TypeChange_CODE = @Lc_TypeChangeCl_CODE)
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
												AND e.TypeChange_CODE = @Lc_TypeChangeDm_CODE)
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorLint_CODE
												AND e.TypeChange_CODE IN (@Lc_TypeChangeLt_CODE))
											OR (@Lc_ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE, @Lc_ActivityMajorCpls_CODE)
												AND e.TypeChange_CODE IN (@Lc_TypeChangeLs_CODE, @Lc_TypeChangeCa_CODE))
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorNmsn_CODE
												AND e.TypeChange_CODE = @Lc_TypeChangeNm_CODE)
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorEmnp_CODE
												AND (e.TypeChange_CODE = @Lc_TypeChangeEm_CODE
													OR e.TypeChange_CODE = @Lc_TypeChangeEp_CODE))
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
												AND e.TypeChange_CODE = @Lc_TypeChangeMp_CODE)
											OR
										  (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorIrsc_CODE
											AND e.TypeChange_CODE = @Lc_TypeChangeIr_CODE)
											OR (@Lc_ActivityMajor_CODE = @Lc_ActivityMajorEmnp_CODE
												AND (e.TypeChange_CODE = @Lc_TypeChangeEm_CODE
													OR e.TypeChange_CODE = @Lc_TypeChangeEp_CODE)))
									  AND e.Process_DATE = @Ld_Run_DATE;
								END
							   ELSE
								BEGIN
									/* 13775 - ELFC - All the ELFC triggers did not successfully process - START */
									/*Checking whether the Remedy for the below given input has been checked and processed on the given run date*/
									SELECT @Ln_QNTY = COUNT(1)
									  FROM ELFC_Y1 e
									 WHERE e.Case_IDNO = @Ln_Case_IDNO
									   AND e.NegPos_CODE = @Lc_NegPos_CODE
									   AND @Lc_ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
									   AND e.TypeChange_CODE = @Lc_TypeChangeCc_CODE
									   AND e.Process_DATE = @Ld_Run_DATE;
									/* 13775 - ELFC - All the ELFC triggers did not successfully process - END */
								END

							   IF @Lc_ActivityMajor_CODE IN (@Lc_ActivityMajorIrsc_CODE, @Lc_ActivityMajorEmnd_CODE)
								BEGIN
									SET @Lc_ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE;
								END
						
						   IF @Ln_QNTY = 0
							BEGIN
								SAVE TRANSACTION Elfc_Cursor_Transaction;								 
								IF @Lc_ActivityMajor_CODE IN (@Lc_ActivityMajorLien_CODE, @Lc_ActivityMajorCsln_CODE, @Lc_ActivityMajorFidm_CODE, @Lc_ActivityMajorImiw_CODE,
															@Lc_ActivityMajorLsnr_CODE, @Lc_ActivityMajorCpls_CODE, @Lc_ActivityMajorNmsn_CODE)
								BEGIN
									SET @Ls_Sql_TEXT = 'ELFC011 : SELECT TypeOthp_CODE FROM OTHP_Y1';
									SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OthpActivityMajorSource_IDNO AS VARCHAR (9)), '');

									SELECT @Lc_TypeOthp_CODE = o.TypeOthp_CODE
									  FROM OTHP_Y1 o
									 WHERE o.OtherParty_IDNO = @Ln_OthpActivityMajorSource_IDNO
									   AND o.EndValidity_DATE = @Ld_High_DATE;
								END
								ELSE
								BEGIN
									SET @Ls_Sql_TEXT = 'ELFC011A : SELECT CaseRelationship_CODE FROM CMEM_Y1';
									SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OthpActivityMajorSource_IDNO AS VARCHAR (9)), '');

									SELECT @Lc_TypeOthp_CODE = o.CaseRelationship_CODE
									  FROM CMEM_Y1 o
									 WHERE o.Case_IDNO = @Ln_Case_IDNO
									   AND o.MemberMci_IDNO = @Ln_OthpActivityMajorSource_IDNO;
								 END

							     SET @Ls_Sql_TEXT = 'ELFC012 : BATCH_ENF_ELFC$SP_CHECK_INSERT';
							     SET @Ls_Sqldata_TEXT = 'TypeChange_CODE = ' + @Lc_TypeChange_CODE + 
													 ', Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS CHAR(6)), '') + 
													 ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + 
													 ', TypeOthpSource_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + 
													 ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + 
													 ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_CODE, '') + 
													 ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + 
													 ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + 
													 ', ActivityMajor_CODE = ' + ISNULL (@Lc_ActivityMajor_CODE, '') + 
													 ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + 
													 ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + 
													 ', InProcess_ID = ' + ISNULL(@Lc_EnfLocCur_Process_ID, '') + 
													 ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

								  EXECUTE BATCH_ENF_ELFC$SP_CHECK_INSERT
								   @Ac_TypeChange_CODE         = @Lc_TypeChange_CODE,
								   @An_Case_IDNO               = @Ln_Case_IDNO,
								   @An_OrderSeq_NUMB           = @Ln_OrderSeq_NUMB,
								   @An_MemberMci_IDNO          = @Ln_MemberMci_IDNO,
								   @Ac_TypeOthpSource_CODE     = @Lc_TypeOthp_CODE,
								   @An_OthpSource_IDNO         = @Ln_OthpActivityMajorSource_IDNO,
								   @Ac_TypeReference_CODE      = @Lc_TypeReference_CODE,
								   @Ac_Reference_ID            = @Lc_Reference_ID,
								   @Ac_ActivityMajor_CODE      = @Lc_ActivityMajor_CODE,
								   @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB,
								   @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
								   @Ad_Run_DATE                = @Ld_Run_DATE,
								   @Ac_InProcess_ID			   = @Lc_EnfLocCur_Process_ID,
								   @Ac_Process_ID              = @Lc_Job_ID,
								   @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
								   @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
															   
								  IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
								   BEGIN
										SET @Lc_Error_CODE = @Lc_Msg_CODE;
										SET @Ls_DescriptionError_TEXT = 'ELFC013 : BATCH_ENF_ELFC$SP_CHECK_INSERT FAILED' +' '+ISNULL(@Ls_DescriptionError_TEXT, '');
										RAISERROR (50001, 16, 1);
								   END								  
							    END
							END
						END
				END TRY	
				BEGIN CATCH
							 
					IF XACT_STATE() = 1
					BEGIN
						ROLLBACK TRANSACTION Elfc_Cursor_Transaction;
					END
					ELSE
					BEGIN
						SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
						RAISERROR( 50001 ,16,1);
					END
					
					SET @Ln_Error_NUMB = ERROR_NUMBER ();
					SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

					IF @Ln_Error_NUMB <> 50001
					BEGIN
						SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
					END

					EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
					@As_Procedure_NAME        = @Ls_Procedure_NAME,
					@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
					@As_Sql_TEXT              = @Ls_Sql_TEXT,
					@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
					@An_Error_NUMB            = @Ln_Error_NUMB,
					@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
					@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
						
					SET @Lc_Error_CODE = ISNULL(@Lc_Error_CODE,@Lc_ErrorE1176_CODE);
					EXECUTE BATCH_COMMON$SP_BATE_LOG
					 @As_Process_NAME             = @Ls_Process_NAME,
					 @As_Procedure_NAME           = @Ls_Procedure_NAME,
					 @Ac_Job_ID                   = @Lc_Job_ID,
					 @Ad_Run_DATE                 = @Ld_Run_DATE,
					 @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
					 @An_Line_NUMB                = @Ln_Cursor_QNTY,
					 @Ac_Error_CODE               = @Lc_Error_CODE,
					 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
					 @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
					 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
					 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
									 
					IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
					BEGIN
						SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG 2 FAILED ' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
						RAISERROR (50001, 16, 1); 
					END	
					ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
					BEGIN
						SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
					END
				END CATCH
			END

			ELSE IF (@Lc_NegPos_CODE = @Lc_NegPosNegative_CODE  AND @Lb_ExceptionRaised_BIT = 0)
			  BEGIN
			   IF @Lc_TypeChange_CODE IN (@Lc_TypeChangeEt_CODE, @Lc_TypeChangeEe_CODE, @Lc_TypeChangeOt_CODE, @Lc_TypeChangeSt_CODE)
					BEGIN
						SET @Ls_Sql_TEXT = 'ELFC014 : SELECT ELFC_Y1 - CHECK REMEDY PROCESSED FOR THE RUN DATE ALREADY';
                        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

						 --Checking whether the Remedy for the below given input has been checked and processed on the given run date
						 SELECT @Ln_QNTY = COUNT(1)
						   FROM ELFC_Y1 e
						  WHERE e.Case_IDNO = @Ln_Case_IDNO
							AND e.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
							AND e.MemberMci_IDNO = @Ln_MemberMci_IDNO
							AND e.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), @Lc_Percentage_TEXT)
							AND e.NegPos_CODE = @Lc_NegPos_CODE
							AND e.TypeChange_CODE IN (@Lc_TypeChangeEt_CODE, @Lc_TypeChangeEe_CODE, @Lc_TypeChangeOt_CODE, @Lc_TypeChangeSt_CODE)
							AND e.Process_DATE = @Ld_Run_DATE;

						 IF @Ln_QNTY = 0
							  BEGIN
							   DECLARE RemClose_CUR INSENSITIVE CURSOR FOR 
								SELECT j.OthpSource_IDNO,
									   j.TypeReference_CODE,
									   j.Reference_ID
								  FROM DMJR_Y1 j
								 WHERE j.Case_IDNO = @Ln_Case_IDNO
								   AND j.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
								   AND j.MemberMci_IDNO = @Ln_MemberMci_IDNO
								   AND j.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), '%')
								   AND j.Reference_ID LIKE ISNULL(LTRIM(RTRIM(@Lc_Reference_ID)), '%')
								   AND j.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
								   AND j.Status_CODE = @Lc_StatusStart_CODE;

								OPEN RemClose_CUR;

								FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;

							    SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS; 

                               WHILE @Ln_FetchStatus_QNTY = 0
								BEGIN
								 SAVE TRANSACTION  Elfc_Cursor_Transaction;

								 BEGIN TRY
									SET @Ls_Sql_TEXT = 'ELFC015 : BATCH_ENF_ELFC$SP_CLOSE_REMEDY';
                                    SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_RemCloseCur_OthpSource_IDNO AS VARCHAR), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorImiw_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', TypeReference_CODE = ' + ISNULL(@Lc_RemCloseCur_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Lc_RemCloseCur_Reference_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

								   EXECUTE BATCH_ENF_ELFC$SP_CLOSE_REMEDY
								   @An_Case_IDNO               = @Ln_Case_IDNO,
								   @An_OrderSeq_NUMB           = @Ln_OrderSeq_NUMB,
								   @An_MemberMci_IDNO          = @Ln_MemberMci_IDNO,
								   @An_OthpSource_IDNO         = @Ln_RemCloseCur_OthpSource_IDNO,
								   @Ac_TypeReference_CODE      = @Lc_RemCloseCur_TypeReference_CODE,
								   @Ac_Reference_ID            = @Lc_RemCloseCur_Reference_ID,
								   @Ac_ActivityMajor_CODE      = @Lc_ActivityMajorImiw_CODE,
								   @Ac_ReasonStatus_CODE       = @Lc_TypeChange_CODE,
								   @Ac_Subsystem_CODE          = @Lc_SubsystemEnforcement_CODE,
								   @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB,
								   @Ad_Run_DATE                = @Ld_Run_DATE,
								   @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
								   @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

								   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
								   BEGIN
										SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_ELFC$SP_CLOSE_REMEDY FAILED :' + ISNULL(@Ls_DescriptionError_TEXT, '');
										RAISERROR (50001, 16, 1); 
								   END
								 END TRY

								 BEGIN CATCH
								 
									IF XACT_STATE() = 1
									BEGIN
									   ROLLBACK TRANSACTION Elfc_Cursor_Transaction;
									END
									ELSE
									BEGIN
										SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
										RAISERROR( 50001 ,16,1);
									END
								
									SET @Ln_Error_NUMB = ERROR_NUMBER ();
									SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

									IF @Ln_Error_NUMB <> 50001
									BEGIN
										SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
									END

									EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
									@As_Procedure_NAME        = @Ls_Procedure_NAME,
									@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
									@As_Sql_TEXT              = @Ls_Sql_TEXT,
									@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
									@An_Error_NUMB            = @Ln_Error_NUMB,
									@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
									@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

									SET @Lc_Error_CODE = ISNULL(@Lc_Error_CODE,@Lc_ErrorE1176_CODE);	
									EXECUTE BATCH_COMMON$SP_BATE_LOG
									 @As_Process_NAME             = @Ls_Process_NAME,
									 @As_Procedure_NAME           = @Ls_Procedure_NAME,
									 @Ac_Job_ID                   = @Lc_Job_ID,
									 @Ad_Run_DATE                 = @Ld_Run_DATE,
									 @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
									 @An_Line_NUMB                = @Ln_Cursor_QNTY,
									 @Ac_Error_CODE               = @Lc_Error_CODE,
									 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
									 @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
									 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
									 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		
													 
									IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
									BEGIN
										SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG 3 FAILED : ' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
										RAISERROR (50001, 16, 1); 
									END
									ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
									BEGIN
										SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
									END														 									
								 END CATCH

								 FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;
								 
								  SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
								END

							IF CURSOR_STATUS('Local', 'RemClose_CUR') IN (0,1)
                                BEGIN
                                 CLOSE RemClose_CUR;
                                 DEALLOCATE RemClose_CUR;
                                END   
							  END
					END

			   IF @Lc_TypeChange_CODE IN (@Lc_TypeChangeEe_CODE, @Lc_TypeChangeNs_CODE, @Lc_TypeChangeSt_CODE, @Lc_TypeChangeLc_CODE)
				BEGIN
				 SET @Ls_Sql_TEXT = 'ELFC017 : SELECT ELFC_Y1 - CHECK REMEDY PROCESSED FOR THE RUN DATE ALREADY';
				 SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(10)), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

				 --Checking whether the Remedy for the below given input has been checked and processed on the given run date
				 SELECT @Ln_QNTY = COUNT(1)
				   FROM ELFC_Y1 e
				  WHERE e.Case_IDNO = @Ln_Case_IDNO
					AND e.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
					AND e.MemberMci_IDNO = @Ln_MemberMci_IDNO
					AND e.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), @Lc_Percentage_TEXT)
					AND e.NegPos_CODE = @Lc_NegPos_CODE
					AND e.TypeChange_CODE IN (@Lc_TypeChangeEe_CODE, @Lc_TypeChangeNs_CODE, @Lc_TypeChangeSt_CODE, @Lc_TypeChangeCr_CODE)
					AND e.Process_DATE = @Ld_Run_DATE;

				 IF @Ln_QNTY = 0
				  BEGIN
				   DECLARE RemClose_CUR INSENSITIVE CURSOR FOR 
					SELECT j.OthpSource_IDNO,
						   j.TypeReference_CODE,
						   j.Reference_ID
					  FROM DMJR_Y1 j
					 WHERE j.Case_IDNO = @Ln_Case_IDNO
					   AND j.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
					   AND j.MemberMci_IDNO = @Ln_MemberMci_IDNO
					   AND j.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), '%')
					   AND j.Reference_ID LIKE ISNULL(LTRIM(RTRIM(@Lc_Reference_ID)), '%')
					   AND j.ActivityMajor_CODE = @Lc_ActivityMajorNmsn_CODE
					   AND j.Status_CODE = @Lc_StatusStart_CODE;

				   OPEN RemClose_CUR;

				   FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;
                
					SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
                  
					WHILE @Ln_FetchStatus_QNTY = 0
					BEGIN
					 SAVE TRANSACTION Elfc_Cursor_Transaction;

					 BEGIN TRY
					  SET @Ls_Sql_TEXT = 'ELFC018 : BATCH_ENF_ELFC$SP_CLOSE_REMEDY';
                      SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_RemCloseCur_OthpSource_IDNO AS VARCHAR), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorNmsn_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', TypeReference_CODE = ' + ISNULL(@Lc_RemCloseCur_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Lc_RemCloseCur_Reference_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

					  EXECUTE BATCH_ENF_ELFC$SP_CLOSE_REMEDY
					   @An_Case_IDNO               = @Ln_Case_IDNO,
					   @An_OrderSeq_NUMB           = @Ln_OrderSeq_NUMB,
					   @An_MemberMci_IDNO          = @Ln_MemberMci_IDNO,
					   @An_OthpSource_IDNO         = @Ln_RemCloseCur_OthpSource_IDNO,
					   @Ac_TypeReference_CODE      = @Lc_RemCloseCur_TypeReference_CODE,
					   @Ac_Reference_ID            = @Lc_RemCloseCur_Reference_ID,
					   @Ac_ActivityMajor_CODE      = @Lc_ActivityMajorNmsn_CODE,
					   @Ac_ReasonStatus_CODE       = @Lc_TypeChange_CODE,
					   @Ac_Subsystem_CODE          = @Lc_SubsystemEnforcement_CODE,
					   @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB,
					   @Ad_Run_DATE                = @Ld_Run_DATE,
					   @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
					   @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

					   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
					   BEGIN
							SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_ELFC$SP_CLOSE_REMEDY FAILED :' + ISNULL(@Ls_DescriptionError_TEXT, '');
							RAISERROR (50001, 16, 1); 
					   END
					 END TRY

					 BEGIN CATCH
					 
						IF XACT_STATE() = 1
						BEGIN
						   ROLLBACK TRANSACTION Elfc_Cursor_Transaction;
						END
						ELSE
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
							RAISERROR( 50001 ,16,1);
						END
						
						SET @Ln_Error_NUMB = ERROR_NUMBER ();
						SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   
						IF @Ln_Error_NUMB <> 50001
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
						END
	   
						EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
						@As_Procedure_NAME        = @Ls_Procedure_NAME,
						@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
						@As_Sql_TEXT              = @Ls_Sql_TEXT,
						@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
						@An_Error_NUMB            = @Ln_Error_NUMB,
						@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
						@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
							
						SET @Lc_Error_CODE = ISNULL(@Lc_Error_CODE,@Lc_ErrorE1176_CODE);	
						EXECUTE BATCH_COMMON$SP_BATE_LOG
						 @As_Process_NAME             = @Ls_Process_NAME,
						 @As_Procedure_NAME           = @Ls_Procedure_NAME,
						 @Ac_Job_ID                   = @Lc_Job_ID,
						 @Ad_Run_DATE                 = @Ld_Run_DATE,
						 @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
						 @An_Line_NUMB                = @Ln_Cursor_QNTY,
						 @Ac_Error_CODE               = @Lc_Error_CODE,
						 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
						 @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
						 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
						 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		
										 
						IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
						BEGIN
							SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG 4 FAILED : ' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
							RAISERROR (50001, 16, 1); 
						END
						ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
						BEGIN
							SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
						END
					 END CATCH
					 FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;
					 
					 SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
					END

					IF CURSOR_STATUS('Local', 'RemClose_CUR') IN (0,1)
                    BEGIN
						CLOSE RemClose_CUR;
						DEALLOCATE RemClose_CUR;
                    END 
				  END
				END

			   IF @Lc_TypeChange_CODE IN (@Lc_TypeChangeSt_CODE, @Lc_TypeChangeLc_CODE)
				BEGIN
				 SET @Ls_Sql_TEXT = 'ELFC020 : SELECT ELFC_Y1 - CHECK REMEDY PROCESSED FOR THE RUN DATE ALREADY';
                 SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

				 --Checking whether the Remedy for the below given input has been checked and processed on the given run date
				 SELECT @Ln_QNTY = COUNT(1)
				   FROM ELFC_Y1 e
				  WHERE e.Case_IDNO = @Ln_Case_IDNO
					AND e.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
					AND e.MemberMci_IDNO = @Ln_MemberMci_IDNO
					AND e.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), @Lc_Percentage_TEXT)
					AND e.NegPos_CODE = @Lc_NegPos_CODE
					AND e.TypeChange_CODE IN (@Lc_TypeChangeSt_CODE, @Lc_TypeChangeCr_CODE)
					AND e.Process_DATE = @Ld_Run_DATE;

				 IF @Ln_QNTY = 0
				  BEGIN
				   DECLARE RemClose_CUR INSENSITIVE CURSOR FOR 
					SELECT j.OthpSource_IDNO,
						   j.TypeReference_CODE,
						   j.Reference_ID
					  FROM DMJR_Y1 j
					 WHERE j.Case_IDNO = @Ln_Case_IDNO
					   AND j.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
					   AND j.MemberMci_IDNO = @Ln_MemberMci_IDNO
					   AND j.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), '%')
					   AND j.Reference_ID LIKE ISNULL(LTRIM(RTRIM(@Lc_Reference_ID)), '%')
					   AND j.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
					   AND j.Status_CODE = @Lc_StatusStart_CODE;

				   OPEN RemClose_CUR;

				   FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;

                   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS; 
                   
				   WHILE @Ln_FetchStatus_QNTY = 0
					BEGIN
					 SAVE TRANSACTION Elfc_Cursor_Transaction;

					 BEGIN TRY
						SET @Ls_Sql_TEXT = 'ELFC021 : BATCH_ENF_ELFC$SP_CLOSE_REMEDY 8 - CLOSE CRPT REMEDY';
						SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_RemCloseCur_OthpSource_IDNO AS VARCHAR), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCrpt_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', TypeReference_CODE = ' + ISNULL(@Lc_RemCloseCur_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Lc_RemCloseCur_Reference_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

						EXECUTE BATCH_ENF_ELFC$SP_CLOSE_REMEDY
						@An_Case_IDNO               = @Ln_Case_IDNO,
						@An_OrderSeq_NUMB           = @Ln_OrderSeq_NUMB,
						@An_MemberMci_IDNO          = @Ln_MemberMci_IDNO,
						@An_OthpSource_IDNO         = @Ln_RemCloseCur_OthpSource_IDNO,
						@Ac_TypeReference_CODE      = @Lc_RemCloseCur_TypeReference_CODE,
						@Ac_Reference_ID            = @Lc_RemCloseCur_Reference_ID,
						@Ac_ActivityMajor_CODE      = @Lc_ActivityMajorCrpt_CODE,
						@Ac_ReasonStatus_CODE       = @Lc_TypeChange_CODE,
						@Ac_Subsystem_CODE          = @Lc_SubsystemEnforcement_CODE,
						@An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB,
						@Ad_Run_DATE                = @Ld_Run_DATE,
						@Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
						@As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

						IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
						BEGIN
							SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_ELFC$SP_CLOSE_REMEDY - CLOSE CRPT REMEDY FAILED' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
							RAISERROR(50001,16,1);
						END
					 END TRY
					 BEGIN CATCH
					 
						IF XACT_STATE() = 1
						BEGIN
							ROLLBACK TRANSACTION Elfc_Cursor_Transaction;
						END
						ELSE
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
							RAISERROR( 50001 ,16,1);
						END
						
						SET @Ln_Error_NUMB = ERROR_NUMBER ();
						SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   
						IF @Ln_Error_NUMB <> 50001
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
						END
	   
						EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
						@As_Procedure_NAME        = @Ls_Procedure_NAME,
						@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
						@As_Sql_TEXT              = @Ls_Sql_TEXT,
						@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
						@An_Error_NUMB            = @Ln_Error_NUMB,
						@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
						@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

						SET @Lc_Error_CODE = ISNULL(@Lc_Error_CODE,@Lc_ErrorE1176_CODE);	
						EXECUTE BATCH_COMMON$SP_BATE_LOG
						 @As_Process_NAME             = @Ls_Process_NAME,
						 @As_Procedure_NAME           = @Ls_Procedure_NAME,
						 @Ac_Job_ID                   = @Lc_Job_ID,
						 @Ad_Run_DATE                 = @Ld_Run_DATE,
						 @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
						 @An_Line_NUMB                = @Ln_Cursor_QNTY,
						 @Ac_Error_CODE               = @Lc_Error_CODE,
						 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
						 @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
						 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
						 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		
										 
						IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
						BEGIN
							SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG 5 FAILED : ' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
							RAISERROR (50001, 16, 1); 
						END
						ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
						BEGIN
							SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
						END	
					 END CATCH

					 FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;
					 
					 SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
					END

					IF CURSOR_STATUS('Local', 'RemClose_CUR') IN (0,1)
                    BEGIN
                     CLOSE RemClose_CUR;
                     DEALLOCATE RemClose_CUR;
                    END 
				  END
				END

			   IF @Lc_TypeChange_CODE IN (@Lc_TypeChangeSt_CODE)
				BEGIN
				 SET @Ls_Sql_TEXT = 'ELFC023 : SELECT ELFC_Y1 - CHECK REMEDY PROCESSED FOR THE RUN DATE ALREADY';
                 SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

				 --Checking whether the Remedy for the below given input has been checked and processed on the given run date
				
				 SELECT @Ln_QNTY = COUNT(1)
				   FROM ELFC_Y1 e
				  WHERE e.Case_IDNO = @Ln_Case_IDNO
					AND e.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
					AND e.MemberMci_IDNO = @Ln_MemberMci_IDNO
					AND e.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), @Lc_Percentage_TEXT)
					AND e.NegPos_CODE = @Lc_NegPos_CODE
					AND e.TypeChange_CODE IN (@Lc_TypeChangeSt_CODE)
					AND e.Process_DATE = @Ld_Run_DATE

				 IF @Ln_QNTY = 0
				  BEGIN
				   DECLARE RemClose_CUR INSENSITIVE CURSOR FOR 
					SELECT j.OthpSource_IDNO,
						   j.TypeReference_CODE,
						   j.Reference_ID
					  FROM DMJR_Y1 j
					 WHERE j.Case_IDNO = @Ln_Case_IDNO
					   AND j.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
					   AND j.MemberMci_IDNO = @Ln_MemberMci_IDNO
					   AND j.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), '%')
					   AND j.Reference_ID LIKE ISNULL(LTRIM(RTRIM(@Lc_Reference_ID)), '%')
					   AND j.ActivityMajor_CODE = @Lc_ActivityMajorLsnr_CODE
					   AND j.Status_CODE = @Lc_StatusStart_CODE;

				   OPEN RemClose_CUR;

				   FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;
                  
                  SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
                  
				   WHILE @Ln_FetchStatus_QNTY = 0
					BEGIN
					 SAVE TRANSACTION Elfc_Cursor_Transaction;

					 BEGIN TRY
					  SET @Ls_Sql_TEXT = 'ELFC051 : BATCH_ENF_ELFC$SP_CLOSE_REMEDY - CLOSE LSNR REMEDY';
                      SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_RemCloseCur_OthpSource_IDNO AS VARCHAR), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorLsnr_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', TypeReference_CODE = ' + ISNULL(@Lc_RemCloseCur_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Lc_RemCloseCur_Reference_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

					  EXECUTE BATCH_ENF_ELFC$SP_CLOSE_REMEDY
					   @An_Case_IDNO               = @Ln_Case_IDNO,
					   @An_OrderSeq_NUMB           = @Ln_OrderSeq_NUMB,
					   @An_MemberMci_IDNO          = @Ln_MemberMci_IDNO,
					   @An_OthpSource_IDNO         = @Ln_RemCloseCur_OthpSource_IDNO,
					   @Ac_TypeReference_CODE      = @Lc_RemCloseCur_TypeReference_CODE,
					   @Ac_Reference_ID            = @Lc_RemCloseCur_Reference_ID,
					   @Ac_ActivityMajor_CODE      = @Lc_ActivityMajorLsnr_CODE,
					   @Ac_ReasonStatus_CODE       = @Lc_TypeChange_CODE,
					   @Ac_Subsystem_CODE          = @Lc_SubsystemEnforcement_CODE,
					   @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB,
					   @Ad_Run_DATE                = @Ld_Run_DATE,
					   @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
					   @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

					  IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
					   BEGIN								
						SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_ELFC$SP_CLOSE_REMEDY - CLOSE LSNR REMEDY FAILED' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
						RAISERROR (50001, 16, 1); 
					   END
					  ELSE IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
						BEGIN
							SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_ELFC$SP_CLOSE_REMEDY - CLOSE IMIW REMEDY FAILED' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
							RAISERROR(50001,16,1);
						END
					 END TRY

					 BEGIN CATCH
					 
						IF XACT_STATE() = 1
						BEGIN
						   ROLLBACK TRANSACTION Elfc_Cursor_Transaction;
						END
						ELSE
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
							RAISERROR( 50001 ,16,1);
						END
						
						SET @Ln_Error_NUMB = ERROR_NUMBER ();
						SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   
						IF @Ln_Error_NUMB <> 50001
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
						END
	   
						EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
						@As_Procedure_NAME        = @Ls_Procedure_NAME,
						@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
						@As_Sql_TEXT              = @Ls_Sql_TEXT,
						@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
						@An_Error_NUMB            = @Ln_Error_NUMB,
						@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
						@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
						
						SET @Lc_Error_CODE = ISNULL(@Lc_Error_CODE,@Lc_ErrorE1176_CODE);
						EXECUTE BATCH_COMMON$SP_BATE_LOG
						@As_Process_NAME             = @Ls_Process_NAME,
						@As_Procedure_NAME           = @Ls_Procedure_NAME,
						@Ac_Job_ID                   = @Lc_Job_ID,
						@Ad_Run_DATE                 = @Ld_Run_DATE,
						@Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
						@An_Line_NUMB                = @Ln_Cursor_QNTY,
						@Ac_Error_CODE               = @Lc_Error_CODE,
						@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
						@As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
						@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
						@As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		
										 
						IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
						BEGIN
							SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG 6 FAILED : ' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
							RAISERROR (50001, 16, 1); 
						END
						ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
						BEGIN
							SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
						END	
					 END CATCH

					 FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;
					 
					 SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
					END

					IF CURSOR_STATUS('Local', 'RemClose_CUR') IN (0,1)
					BEGIN
						CLOSE RemClose_CUR;
						DEALLOCATE RemClose_CUR;
					END 
				  END
				END

			   IF @Lc_TypeChange_CODE IN (@Lc_TypeChangePd_CODE)
				BEGIN
				 SET @Ls_Sql_TEXT = 'ELFC052 : SELECT ELFC_Y1 - CHECK REMEDY PROCESSED FOR THE RUN DATE ALREADY';
                 SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

				 --Checking whether the Remedy for the below given input has been checked and processed on the given run date
				
				 SELECT @Ln_QNTY = COUNT(1)
				   FROM ELFC_Y1 e
				  WHERE e.Case_IDNO = @Ln_Case_IDNO
					AND e.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
					AND e.MemberMci_IDNO = @Ln_MemberMci_IDNO
					AND e.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), @Lc_Percentage_TEXT)
					AND e.NegPos_CODE = @Lc_NegPos_CODE
					AND e.TypeChange_CODE IN (@Lc_TypeChangePd_CODE)
					AND e.Process_DATE = @Ld_Run_DATE

				 IF @Ln_QNTY = 0
				  BEGIN
				   DECLARE RemClose_CUR INSENSITIVE CURSOR FOR 
					SELECT j.OthpSource_IDNO,
						   j.TypeReference_CODE,
						   j.Reference_ID
					  FROM DMJR_Y1 j
					 WHERE j.Case_IDNO = @Ln_Case_IDNO
					   AND j.OrderSeq_NUMB = @Ln_OrderSeq_NUMB
					   AND j.MemberMci_IDNO = @Ln_MemberMci_IDNO
					   AND j.OthpSource_IDNO LIKE ISNULL(LTRIM(RTRIM(@Ln_OthpSource_IDNO)), '%')
					   AND j.Reference_ID LIKE ISNULL(LTRIM(RTRIM(@Lc_Reference_ID)), '%')
					   AND j.ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE
					   AND j.Status_CODE = @Lc_StatusStart_CODE;

				   OPEN RemClose_CUR;

				   FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;
                  
                  SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
                  
				   WHILE @Ln_FetchStatus_QNTY = 0
					BEGIN
					 SAVE TRANSACTION Elfc_Cursor_Transaction;

					 BEGIN TRY
					  SET @Ls_Sql_TEXT = 'ELFC053 : BATCH_ENF_ELFC$SP_CLOSE_REMEDY - CLOSE CSLN REMEDY';
                      SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_RemCloseCur_OthpSource_IDNO AS VARCHAR), '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPos_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCsln_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_TypeChange_CODE, '') + ', TypeReference_CODE = ' + ISNULL(@Lc_RemCloseCur_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Lc_RemCloseCur_Reference_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL (CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

					  EXECUTE BATCH_ENF_ELFC$SP_CLOSE_REMEDY
					   @An_Case_IDNO               = @Ln_Case_IDNO,
					   @An_OrderSeq_NUMB           = @Ln_OrderSeq_NUMB,
					   @An_MemberMci_IDNO          = @Ln_MemberMci_IDNO,
					   @An_OthpSource_IDNO         = @Ln_RemCloseCur_OthpSource_IDNO,
					   @Ac_TypeReference_CODE      = @Lc_RemCloseCur_TypeReference_CODE,
					   @Ac_Reference_ID            = @Lc_RemCloseCur_Reference_ID,
					   @Ac_ActivityMajor_CODE      = @Lc_ActivityMajorCsln_CODE,
					   @Ac_ReasonStatus_CODE       = @Lc_TypeChange_CODE,
					   @Ac_Subsystem_CODE          = @Lc_SubsystemEnforcement_CODE,
					   @An_TransactionEventSeq_NUMB= @Ln_TransactionEventSeq_NUMB,
					   @Ad_Run_DATE                = @Ld_Run_DATE,
					   @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
					   @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

					  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
						BEGIN
							SET @Ls_DescriptionError_TEXT ='BATCH_ENF_ELFC$SP_CLOSE_REMEDY - CLOSE CSLN REMEDY FAILED' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
							RAISERROR (50001, 16, 1); 
						END
					  ELSE IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_ELFC$SP_CLOSE_REMEDY - CLOSE IMIW REMEDY FAILED' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
						RAISERROR(50001,16,1);
					  END
					 END TRY
					 BEGIN CATCH
					 
						IF XACT_STATE() = 1
						BEGIN
						   ROLLBACK TRANSACTION Elfc_Cursor_Transaction;
						END
						ELSE
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
							RAISERROR( 50001 ,16,1);
						END
						
						SET @Ln_Error_NUMB = ERROR_NUMBER ();
						SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   
						IF @Ln_Error_NUMB <> 50001
						BEGIN
							SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE(), 1, 200);
						END
	   
						EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
						@As_Procedure_NAME        = @Ls_Procedure_NAME,
						@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
						@As_Sql_TEXT              = @Ls_Sql_TEXT,
						@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
						@An_Error_NUMB            = @Ln_Error_NUMB,
						@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
						@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

						SET @Lc_Error_CODE = ISNULL(@Lc_Error_CODE,@Lc_ErrorE1176_CODE);
						EXECUTE BATCH_COMMON$SP_BATE_LOG
						 @As_Process_NAME             = @Ls_Process_NAME,
						 @As_Procedure_NAME           = @Ls_Procedure_NAME,
						 @Ac_Job_ID                   = @Lc_Job_ID,
						 @Ad_Run_DATE                 = @Ld_Run_DATE,
						 @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
						 @An_Line_NUMB                = @Ln_Cursor_QNTY,
						 @Ac_Error_CODE               = @Lc_Error_CODE,
						 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
						 @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
						 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
						 @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;		
										 
						IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
						BEGIN
							SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_BATE_LOG 7 FAILED : ' + ' ' + ISNULL(@Ls_DescriptionError_TEXT, '');
							RAISERROR (50001, 16, 1); 
						END
						ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
						BEGIN
							SET @Ln_Exception_QNTY = @Ln_Exception_QNTY + 1;
						END	
					 END CATCH

					 FETCH NEXT FROM RemClose_CUR INTO @Ln_RemCloseCur_OthpSource_IDNO, @Lc_RemCloseCur_TypeReference_CODE, @Lc_RemCloseCur_Reference_ID;
					 
					 SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
					END

					IF CURSOR_STATUS('Local', 'RemClose_CUR') IN (0,1)
                    BEGIN
						 CLOSE RemClose_CUR;
						 DEALLOCATE RemClose_CUR;
                    END 
				  END
				END
			  END

		 --If the Erroneous Exceptions are more than the threshold, then we need to abend the program. The commit will ensure that the records processed so far without any problems are committed. Also the exception entries are committed so that it will be easy to determine the error records.
		
		 IF @Ln_Exception_QNTY > @Ln_ExceptionThreshold_NUMB
			AND @Ln_ExceptionThreshold_NUMB > 0
			  BEGIN
			   COMMIT TRANSACTION Elfc_Main_Transaction;
			   SET @Ln_Exception_QNTY = 0;
			   SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
			   SET @Ls_Sqldata_TEXT = 'ExceptionThreshold_QNTY = ' + CAST(@Ln_Exception_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThreshold_NUMB AS VARCHAR);
			   SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';
			   RAISERROR (50001,16,1);
			  END
			  
		SET @Ls_Sql_TEXT = 'ELFC057A : UPDATE IELFC_Y1';
		SET @Ls_Sqldata_TEXT = ' TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Process_DATE = ' + ISNULL(CONVERT(VARCHAR(10), @Ld_Run_DATE, 101), '') +', Update_DTTM = ' + CONVERT(VARCHAR, @Ld_EnfLocCur_Update_DTTM, 121);
			 
		-- Update ELFC_Y1 table and change the Process Date of the record to Current Date
		 UPDATE IELFC_Y1
			SET Process_DATE = @Ld_Run_DATE
		  WHERE RecordRowNumber_NUMB = @Ln_EnfLocCur_RecordRowNumber_NUMB;
		  
		  SET @Ln_RowCount_QNTY = @@ROWCOUNT;
		  
		IF @Lb_ExceptionRaised_BIT = 0
		BEGIN  
			SET @Ls_Sql_TEXT = 'ELFC057 : UPDATE ELFC_Y1';
			SET @Ls_Sqldata_TEXT = ' TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Case_IDNO = ' + CAST(@Ln_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR(9)), '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Process_DATE = ' + ISNULL(CONVERT(VARCHAR(10), @Ld_Run_DATE, 101), '') + ', Process_ID = ' + @Lc_EnfLocCur_Process_ID + ', TypeChange_CODE = ' + @Lc_EnfLocCur_TypeChange_CODE + ', Create_DATE = ' + CAST (@Ld_EnfLocCur_Create_DATE AS VARCHAR) + ', Update_DTTM = ' + CONVERT(VARCHAR, @Ld_EnfLocCur_Update_DTTM, 121);

			-- Update ELFC	
			UPDATE e SET Process_DATE = @Ld_Run_DATE
			  FROM ELFC_Y1 e, IELFC_Y1 i
			 WHERE i.RecordRowNumber_NUMB = @Ln_EnfLocCur_RecordRowNumber_NUMB
				AND e.Case_IDNO = i.Case_IDNO
				AND e.MemberMci_IDNO = i.MemberMci_IDNO
				AND e.OthpSource_IDNO = i.OthpSource_IDNO
				AND e.Reference_ID = i.Reference_ID
				AND e.Process_ID = i.Process_ID
				AND e.TypeChange_CODE = i.TypeChange_CODE
				AND e.Create_DATE = i.Create_DATE 
				AND e.UPDATE_DTTM = i.UPDATE_DTTM;
			IF @Ln_RowCount_QNTY = 0
			BEGIN
				SET @Ln_RowCount_QNTY = @@ROWCOUNT;					
			END

			IF @Ln_RowCount_QNTY = 0
			BEGIN
			 SET @Ls_DescriptionError_TEXT = 'ELFC_Y1 UPDATE FAILED';
			 RAISERROR (50001,16,1);
			END
		END
        
		 --If the commit frequency is attained, the following is done. Reset the commit COUNT, Commit the transaction completed until now.
		 IF @Ln_Commit_QNTY >= @Ln_CommitFreq_NUMB
			AND @Ln_CommitFreq_NUMB > 0
			  BEGIN
				SET @Ls_Sql_TEXT = 'JRTL_Y1 UPDATE ';
				SET @Ls_Sqldata_TEXT = 'JOB_ID = ' + @Lc_Job_ID 
									 + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10)) 
									 + ', Thread_NUMB = ' + ISNULL(CAST(@An_Thread_NUMB AS VARCHAR(15)), '');
				UPDATE JRTL_Y1
						SET RecRestart_NUMB = @Ln_Record_NUMB + 1,
						   RestartKey_TEXT = @Ls_RestartKey_TEXT
						FROM JRTL_Y1 AS a
						WHERE a.Job_ID = @Lc_Job_ID
						AND a.Run_DATE = @Ld_Run_DATE
						AND a.Thread_NUMB = @An_Thread_NUMB;
				
				COMMIT TRANSACTION Elfc_Main_Transaction;
				BEGIN TRANSACTION Elfc_Main_Transaction;
				SAVE TRANSACTION Elfc_Cursor_Transaction;
				SET @Ln_Commit_QNTY = 0;
			  END
		SET @Lb_ExceptionRaised_BIT = 0;
					
		FETCH NEXT FROM EnfLoc_CUR INTO @Ln_EnfLocCur_RecordRowNumber_NUMB,@Ln_EnfLocCur_Case_IDNO, @Ln_EnfLocCur_OrderSeq_NUMB, @Ln_EnfLocCur_MemberMci_IDNO, @Ln_EnfLocCur_OthpSource_IDNO, @Lc_EnfLocCur_TypeChange_CODE, @Lc_EnfLocCur_NegPos_CODE, @Lc_EnfLocCur_TypeReference_CODE, @Lc_EnfLocCur_Reference_ID, @Ln_EnfLocCur_TransactionEventSeq_NUMB, @Ld_EnfLocCur_Update_DTTM, @Ld_EnfLocCur_Create_DATE, @Lc_EnfLocCur_WorkerUpdate_ID, @Lc_EnfLocCur_Process_ID;
		SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
	END 
	 
   IF CURSOR_STATUS('Local', 'EnfLoc_CUR') IN (0,1)
   BEGIN
	CLOSE EnfLoc_CUR;
	DEALLOCATE EnfLoc_CUR;
   END   
   
   SET @Ls_Sql_TEXT = 'ELFC057B : SELECT IELFC_Y1';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   -- IELFC_Y1 RECORD COUNT
   SELECT @Ln_IelfcRecordUpdate_QNTY = COUNT(1)
     FROM IELFC_Y1 p
    WHERE p.Process_DATE = @Ld_High_DATE;
    

	IF @Ln_IelfcRecordUpdate_QNTY = 0
	BEGIN
		--Update the daily_date field for this procedure in vparm table with the pd_dt_run value
	   SET @Ls_Sql_TEXT = 'ELFC058 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
	   SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

	   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
		@Ac_Job_ID                = @Lc_Job_ID,
		@Ad_Run_DATE              = @Ld_Run_DATE,
		@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

	   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		BEGIN
		 SET @Ls_Sql_TEXT = 'ELFC059A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

		 RAISERROR (50001,16,1);
		END
	END

   -- Updating the log with result
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE					= @Ld_Run_DATE,
    @Ad_Start_DATE					= @Ld_Start_DATE,
    @Ac_Job_ID						= @Lc_Job_ID,
    @As_Process_NAME				= @Ls_Process_NAME,
    @As_Procedure_NAME				= @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT			= @Lc_Null_TEXT,
    @As_ExecLocation_TEXT			= @Lc_Successful_TEXT,
    @As_ListKey_TEXT				= @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT		= @Lc_Null_TEXT,
    @Ac_Status_CODE					= @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID					= @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY	= @Ln_Cursor_QNTY;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION Elfc_Main_Transaction;
    END
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
   BEGIN 
    ROLLBACK TRANSACTION Elfc_Main_Transaction;  
   END

   IF CURSOR_STATUS('Local', 'EnfLoc_CUR') IN (0,1)
    BEGIN
	 CLOSE EnfLoc_CUR;
	 DEALLOCATE EnfLoc_CUR;
    END   
   
   --Check for Exception information to log the description text based on the error
  
  
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
    --- Updating JRTL to ThreadProcess_CODE 'A' to restart the job again
     UPDATE JRTL_Y1
		SET  ThreadProcess_CODE = @Lc_StatusAbnormalend_CODE
		FROM JRTL_Y1 AS a
		WHERE a.Job_ID = @Lc_Job_ID
		AND ThreadProcess_CODE = @Lc_ThreadLocked_INDC
		AND a.Run_DATE = @Ld_Run_DATE
		AND a.Thread_NUMB = @An_Thread_NUMB;

   IF (@Ln_Error_NUMB <> 50001)
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
    @Ad_Run_DATE					= @Ld_Run_DATE,
    @Ad_Start_DATE					= @Ld_Start_DATE,
    @Ac_Job_ID						= @Lc_Job_ID,
    @As_Process_NAME				= @Ls_Process_NAME,
    @As_Procedure_NAME				= @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT			= @Lc_Null_TEXT,
    @As_ExecLocation_TEXT			= @Ls_Sql_TEXT,
    @As_ListKey_TEXT				= @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT		= @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE					= @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID					= @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY	= @Ln_Cursor_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
