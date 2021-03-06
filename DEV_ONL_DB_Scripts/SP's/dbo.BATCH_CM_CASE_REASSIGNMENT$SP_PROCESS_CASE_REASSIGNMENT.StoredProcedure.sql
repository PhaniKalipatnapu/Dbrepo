/****** Object:  StoredProcedure [dbo].[BATCH_CM_CASE_REASSIGNMENT$SP_PROCESS_CASE_REASSIGNMENT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_CASE_REASSIGNMENT$SP_PROCESS_CASE_REASSIGNMENT
Programmer Name	:	IMP Team.
Description		:	This procedure is used to assign a worker for an case
Frequency		:	
Developed On	:	10/10/2011
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_CASE_REASSIGNMENT$SP_PROCESS_CASE_REASSIGNMENT]
AS
 BEGIN
  SET NOCOUNT ON;

  CREATE TABLE #PrimaryRole_P1
   (
     Role_ID CHAR(5)
   );

  DECLARE @Li_Exists_NUMB						INT			= 0,
		  @Ln_Error_NUMB						NUMERIC(10)	= 0,
          @Ln_ErrorLine_NUMB					NUMERIC(10)	= 0,
          @Lc_StatusFailed_CODE					CHAR(1)		= 'F',
          @Lc_StatusSuccess_CODE				CHAR(1)		= 'S',
          @Lc_StatusAbnormalend_CODE			CHAR(1)		= 'A',
          @Lc_TypeRequestO_CODE					CHAR(1)		= 'O',
          @Lc_TypeRequestR_CODE					CHAR(1)		= 'R',
          @Lc_Yes_INDC							CHAR(1)		= 'Y',
          @Lc_No_INDC							CHAR(1)		= 'N',
          @Lc_StatusCaseOpen_CODE				CHAR(1)		= 'O',
          @Lc_InformOldWorker_INDC				CHAR(1)		= 'N',
          @Lc_TypeErrorE_CODE					CHAR(1)		= 'E',
          @Lc_TypeErrorW_CODE					CHAR(1)		= 'W',
          @Lc_Space_TEXT						CHAR(1)		= ' ',
          @Lc_Rs002Role_ID						CHAR(5)		= 'RS002',
          @Lc_Rc005Role_ID						CHAR(5)		= 'RC005',
          @Lc_Rt001Role_ID						CHAR(5)		= 'RT001',
          @Lc_Re001Role_ID						CHAR(5)		= 'RE001',
          @Lc_Rs016Role_ID						CHAR(5)		= 'RS016',
          @Lc_Rp004Role_ID						CHAR(5)		= 'RP004',
          @Lc_BateErrorE0944_CODE				CHAR(5)		= 'E0944',
          @Lc_BateErrorE0058_CODE				CHAR(5)		= 'E0058',
          @Lc_Job_ID							CHAR(7)		= 'DEB5280',
          @Lc_Successful_TEXT					CHAR(20)	= 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT					CHAR(30)	= 'BATCH',
          @Ls_Package_NAME						VARCHAR(50) = 'BATCH_CM_CASE_REASSIGNMENT',
          @Ls_Procedure_NAME					VARCHAR(50) = 'SP_PROCESS_CASE_REASSIGNMENT',
          @Ld_Low_DATE							DATE		= '01/01/0001',
          @Ld_High_DATE							DATE		= '12/31/9999';
  DECLARE @Ln_FetchStatus_QNTY					NUMERIC(2),
          @Ln_CommitFreqParm_QNTY				NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY		NUMERIC(5),
          @Ln_CommitFreq_QNTY					NUMERIC(6)	= 0,
          @Ln_ExceptionThreshold_QNTY			NUMERIC(6)	= 0,
          @Ln_Cursor_QNTY						NUMERIC(10) = 0,
          @Ln_CursorTotal_QNTY					NUMERIC(10) = 0,
          @Ln_CursorError_QNTY					NUMERIC(10) = 0,
          @Lc_Msg_CODE							CHAR(5),
          @Lc_CsenetReason_CODE					CHAR(5),
          @Lc_AssignedWorker_ID					CHAR(30)	= '',
          @Ls_Sql_TEXT							VARCHAR(100),
          @Ls_DescriptionError_TEXT				VARCHAR(4000),
          @Ls_CursorLoc_TEXT					VARCHAR(4000),
          @Ls_Sqldata_TEXT						VARCHAR(MAX) = '',
          @Ld_Run_DATE							DATE,
          @Ld_LastRun_DATE						DATE,
          @Ld_Start_DATE						DATETIME2;
          
  DECLARE @Ln_CrasCurOffice_IDNO				NUMERIC(3),
          @Ln_CrasCurTransactionEventSeq_NUMB	NUMERIC(19),
          @Lc_CrasCurStatus_CODE				CHAR(1),
          @Lc_CrasCurTypeRequest_CODE			CHAR(1),
          @Lc_CrasCurRole_ID					CHAR(5),
          @Ld_CrasCurRequest_DATE				DATE,
          @Ld_CrasCurUpdate_DTTM				DATETIME2;
           
  DECLARE @Ln_CwrkCurOffice_IDNO				NUMERIC(3),
          @Ln_CwrkCurCase_IDNO					NUMERIC(6),
          @Lc_CwrkCurRole_ID					CHAR(5),
          @Lc_CwrkCurCaseWorker_ID				CHAR(30),
          @Lc_CwrkCurWorker_ID					CHAR(30),
          @Ld_CwrkCurEffective_DATE				DATE,
          @Ld_CwrkCurExpire_DATE				DATE;

  BEGIN TRY
   /* Inserting Primary Roles into #PrimaryRole_P1
   RS002 --> Central Registry Manager (Responding interstate case)
   RC005 --> Customer Service Specialist (Non IV-D and instate case)
   RT001 --> Establishment Specialist (IV-D and instate case)
   RE001 --> Enforcement Specialist (order established)
   RS016 --> Intergovernmental Specialist (Initiating Case)
   RP004 --> Child Support Supervisor (If No Worker for the given Role)
   */
   SET @Ls_Sql_TEXT = 'INSERT #PrimaryRole_P1';
   
   -- 13573 Case reassignment batch populated incorrect total case load - Code Standard -- Start
   INSERT INTO #PrimaryRole_P1
               (Role_ID)
        VALUES (@Lc_Rs002Role_ID),
			   (@Lc_Rc005Role_ID),
			   (@Lc_Rt001Role_ID),
			   (@Lc_Re001Role_ID),
			   (@Lc_Rs016Role_ID),
			   (@Lc_Rp004Role_ID);
	-- 13573 Case reassignment batch populated incorrect total case load - Code Standard -- End	
   
   SET @Ls_Sql_TEXT = 'CRAS001 : GET BATCH START TIME';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   
   -- Initiating the Batch start Date and Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   -- Fetching date run, date last run, commit freq, exception threshold details
   SET @Ls_Sql_TEXT = 'CRAS002 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   --Date Run Validation
   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'CRAS003 : CHECKING BATCH LAST RUN DATE';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS CHAR(10)) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10));

   --Last Run Date Validation
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION MAIN_TRAN;
   
   SAVE TRANSACTION MAIN;

   -- Exclude the Role based request when there is an office based request exists on the same office.
   SET @Ls_Sql_TEXT = 'UPDATE CRAS_Y1 - 1'; 
   UPDATE o
	  SET o.Processed_DATE = @Ld_Run_DATE,
		  o.Status_CODE = @Lc_Yes_INDC
	 FROM CRAS_Y1 o
	WHERE EXISTS (SELECT 1
					FROM CRAS_Y1 i
				   WHERE i.Office_IDNO = o.Office_IDNO
					 AND i.TypeRequest_CODE = @Lc_TypeRequestO_CODE
					 AND i.Status_CODE = @Lc_No_INDC
					 AND i.Processed_DATE = @Ld_Low_DATE)
	  AND o.TypeRequest_CODE != @Lc_TypeRequestO_CODE
	  AND o.Status_CODE = @Lc_No_INDC
	  AND o.Processed_DATE = @Ld_Low_DATE;
	  
   DECLARE Cras_CUR INSENSITIVE CURSOR FOR
    SELECT a.Office_IDNO,
           CASE a.TypeRequest_CODE
            WHEN @Lc_TypeRequestO_CODE
             THEN @Lc_Space_TEXT
            ELSE a.Role_ID
           END AS Role_ID,
           a.Status_CODE,
           a.TypeRequest_CODE,
           a.Request_DATE,
           a.TransactionEventSeq_NUMB,
           a.Update_DTTM
      FROM CRAS_Y1 a
     WHERE a.Request_DATE <= @Ld_Run_DATE
       AND a.Status_CODE = @Lc_No_INDC
       AND a.Processed_DATE = @Ld_Low_DATE
       AND a.TypeRequest_CODE IN (@Lc_TypeRequestO_CODE, @Lc_TypeRequestR_CODE)
     ORDER BY a.Office_IDNO,
              Role_ID;

   -- CRAS CURSOR
   SET @Ls_Sql_TEXT = 'OPEN Cras_CUR';
   SET @Ls_Sqldata_TEXT = '';
   OPEN Cras_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Cras_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';
   
   FETCH NEXT FROM Cras_CUR INTO @Ln_CrasCurOffice_IDNO, @Lc_CrasCurRole_ID, @Lc_CrasCurStatus_CODE, @Lc_CrasCurTypeRequest_CODE, @Ld_CrasCurRequest_DATE, @Ln_CrasCurTransactionEventSeq_NUMB, @Ld_CrasCurUpdate_DTTM;
   
   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE - 1';
   SET @Ls_Sqldata_TEXT = '';

   /*Cras_CUR cursor count*/
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
      SET @Li_Exists_NUMB = 0;
	  
      DECLARE Cwrk_CUR INSENSITIVE CURSOR FOR
       SELECT c.Case_IDNO,
              c.Worker_ID,
              c.Office_IDNO,
              c.Role_ID,
              s.Worker_ID,
              c.Effective_DATE,
              c.Expire_DATE
         FROM CWRK_Y1 c,
              CASE_Y1 s
        WHERE c.Office_IDNO = @Ln_CrasCurOffice_IDNO
          AND ((c.Role_ID = @Lc_CrasCurRole_ID
                AND @Lc_CrasCurTypeRequest_CODE = @Lc_TypeRequestR_CODE)
                OR (@Lc_CrasCurTypeRequest_CODE = @Lc_TypeRequestO_CODE
                    AND c.Role_ID IN (SELECT r.Role_ID
                                        FROM ROLE_Y1 r
                                       WHERE r.EndValidity_DATE = @Ld_High_DATE
                                         AND r.Effective_DATE <= @Ld_Run_DATE
                                         AND r.Expire_DATE > @Ld_Run_DATE)))
          AND c.EndValidity_DATE = @Ld_High_DATE
          AND c.Effective_DATE <= @Ld_Run_DATE
          AND c.Expire_DATE > @Ld_Run_DATE
          AND c.Case_IDNO = s.Case_IDNO
          AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
          AND c.TransactionEventSeq_NUMB != @Ln_CrasCurTransactionEventSeq_NUMB
        ORDER BY c.Office_IDNO,
                 c.Role_ID;

      -- CWRK Cursor
   
	  SET @Ls_Sql_TEXT = 'OPEN Cwrk_CUR';
	  SET @Ls_Sqldata_TEXT = '';
      OPEN Cwrk_CUR;

	  SET @Ls_Sql_TEXT = 'FETCH Cwrk_CUR - 1';
	  SET @Ls_Sqldata_TEXT = '';
	  
      FETCH NEXT FROM Cwrk_CUR INTO @Ln_CwrkCurCase_IDNO, @Lc_CwrkCurWorker_ID, @Ln_CwrkCurOffice_IDNO, @Lc_CwrkCurRole_ID, @Lc_CwrkCurCaseWorker_ID, @Ld_CwrkCurEffective_DATE, @Ld_CwrkCurExpire_DATE;

      SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
		
      /*Checking Cwrk_CUR is active*/
      WHILE @Ln_FetchStatus_QNTY = 0
       BEGIN
        BEGIN TRY
         SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
         SET @Ln_CursorTotal_QNTY = @Ln_CursorTotal_QNTY + 1;
         SET @Ls_CursorLoc_TEXT = 'CASE REASSIGNMENT - CURSOR COUNT - ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '');
         SET @Lc_CsenetReason_CODE = 'GSWKR';
         
         -- 13573 Case reassignment batch populated incorrect total case load - Usrl Update Code Removed -- Start
		 SET @Li_Exists_NUMB = 1;
         -- 13573 Case reassignment batch populated incorrect total case load - Usrl Update Code Removed -- End

         SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_GET_ALERT_WORKER_ID';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_CwrkCurCase_IDNO AS VARCHAR) + ', Case_Worker_ID = ' + @Lc_CwrkCurCaseWorker_ID + ', Office_IDNO = ' + CAST(@Ln_CwrkCurOffice_IDNO AS VARCHAR) + ', Role_ID = ' + @Lc_CwrkCurRole_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', SignedonWorker_ID = ' + @Lc_BatchRunUser_TEXT;
		 
         EXECUTE BATCH_COMMON$SP_GET_ALERT_WORKER_ID
          @An_Case_IDNO             = @Ln_CwrkCurCase_IDNO,
          @Ac_Case_Worker_ID        = @Lc_CwrkCurCaseWorker_ID,
          @An_Office_IDNO           = @Ln_CwrkCurOffice_IDNO,
          @Ac_Role_ID               = @Lc_CwrkCurRole_ID OUTPUT,
          @Ad_Run_DATE              = @Ld_Run_DATE,
          @Ac_SignedonWorker_ID     = @Lc_BatchRunUser_TEXT,
          @Ac_Job_ID                = @Lc_Job_ID,
          @Ac_Worker_ID             = @Lc_AssignedWorker_ID OUTPUT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END
		 
		 IF @Lc_AssignedWorker_ID != @Lc_CwrkCurCaseWorker_ID
          BEGIN
           SET @Lc_InformOldWorker_INDC = @Lc_Yes_INDC;
          END

         -- Ac_Worker_ID will be either as Input or Case Worker(CASE_Y1)/Role Worker(CWRK_Y1) will be assigned to the variable
         IF ISNULL(@Lc_AssignedWorker_ID,'') != ''
          BEGIN
           SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_CwrkCurCase_IDNO AS VARCHAR) + ' , Office_IDNO = ' + CAST(@Ln_CwrkCurOffice_IDNO AS VARCHAR) + ' , OfficeTo_IDNO = ' + CAST(@Ln_CwrkCurOffice_IDNO AS VARCHAR) + ' , Role_ID = ' + @Lc_CwrkCurRole_ID + ' , RoleTo_ID = ' + @Lc_CwrkCurRole_ID + ' , Current_Worker_ID = ' + @Lc_CwrkCurCaseWorker_ID + ' , Assigned_Worker_ID = ' + @Lc_AssignedWorker_ID + ' , CsenetReason_CODE = ' + @Lc_CsenetReason_CODE + ' , TransactionEventSeq_NUMB = ' + CAST(@Ln_CrasCurTransactionEventSeq_NUMB AS VARCHAR) + ' , Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ' , Job_ID = ' + @Lc_Job_ID + ' , SignedonWorker_ID = ' + @Lc_BatchRunUser_TEXT;

           EXECUTE BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER
            @An_Case_IDNO                = @Ln_CwrkCurCase_IDNO,
            @An_Office_IDNO              = @Ln_CwrkCurOffice_IDNO,
            @An_OfficeTo_IDNO            = @Ln_CwrkCurOffice_IDNO,
            @Ac_Role_ID                  = @Lc_CwrkCurRole_ID,
            @Ac_RoleTo_ID                = @Lc_CwrkCurRole_ID,
            @Ac_Current_Worker_ID        = @Lc_CwrkCurWorker_ID,
            @Ac_Assigned_Worker_ID       = @Lc_AssignedWorker_ID,
            @Ac_CsenetReason_CODE        = @Lc_CsenetReason_CODE,
            @An_MajorIntSeq_NUMB         = 0,
            @An_MinorIntSeq_NUMB         = 0,
            @An_TransactionEventSeq_NUMB = @Ln_CrasCurTransactionEventSeq_NUMB,
            @Ad_Run_DATE                 = @Ld_Run_DATE,
            @Ac_Job_ID                   = @Lc_Job_ID,
            @Ac_SignedOnWorker_ID        = @Lc_BatchRunUser_TEXT,
            @Ac_InformOldWorker_INDC     = @Lc_InformOldWorker_INDC,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END
          END
         ELSE
          BEGIN
           SET @Lc_Msg_CODE = @Lc_BateErrorE0058_CODE;
           SET @Ls_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_ALERT_WORKER' + ' PROCEDURE ' + '. Error DESC - ' + 'Worker_ID IS EMPTY OR NULL.';
		   
           RAISERROR(50001,16,1);
          END
          
         SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
          
        END TRY

        BEGIN CATCH
         SET @Ln_CursorError_QNTY = @Ln_CursorError_QNTY + 1;
         SET @Ln_Error_NUMB = ERROR_NUMBER ();
         SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
				 
          ROLLBACK TRANSACTION MAIN;
         			
         IF @Ln_Error_NUMB <> 50001
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
		 
         EXECUTE BATCH_COMMON$SP_BATE_LOG
          @As_Process_NAME             = @Ls_Package_NAME,
          @As_Procedure_NAME           = @Ls_Procedure_NAME,
          @Ac_Job_ID                   = @Lc_Job_ID,
          @Ad_Run_DATE                 = @Ld_Run_DATE,
          @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
          @An_Line_NUMB                = @Ln_Cursor_QNTY,
          @Ac_Error_CODE               = @Lc_Msg_CODE,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT, --@Ls_Sqldata_TEXT,
          @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
         ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
         BEGIN
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END
         SAVE TRANSACTION MAIN;
          
        END CATCH

        -- Resetting Assigned Worker_ID to Empty to Fetch the Worker_ID from SP_GET_ALERT_WORKER_ID
        SET @Lc_AssignedWorker_ID = '';

        --If the Erroneous Exceptions are more than the threshold, then we need to abend the program. The commit will ensure that the records processed so far without any problems are committed. Also the exception entries are committed so that it will be easy to determine the error records.	
        IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
           AND @Ln_ExceptionThresholdParm_QNTY > 0
         BEGIN
		  SET @Ln_ExceptionThreshold_QNTY = 0;
          -- 'Reached Threshold'
          SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD REACHED';
          SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '');
		  
          RAISERROR (50001,16,1);
         END

        --If the commit frequency is attained, the following is done. Reset the commit COUNT, Commit the transaction completed until now.
        IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
           AND @Ln_CommitFreqParm_QNTY > 0
         BEGIN
        		
            COMMIT TRANSACTION MAIN_TRAN;

			BEGIN TRANSACTION MAIN_TRAN;
			
            SAVE TRANSACTION MAIN;
       

          SET @Ln_CommitFreq_QNTY = 0;
         END
		
		SET @Ls_Sql_TEXT = 'FETCH Cwrk_CUR - 2';
		SET @Ls_Sqldata_TEXT = '';
		
        FETCH NEXT FROM Cwrk_CUR INTO @Ln_CwrkCurCase_IDNO, @Lc_CwrkCurWorker_ID, @Ln_CwrkCurOffice_IDNO, @Lc_CwrkCurRole_ID, @Lc_CwrkCurCaseWorker_ID, @Ld_CwrkCurEffective_DATE, @Ld_CwrkCurExpire_DATE;

        SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
       END
	  
      CLOSE Cwrk_CUR;

      DEALLOCATE Cwrk_CUR;

     BEGIN TRY
     
		-- 13573 Case reassignment batch populated incorrect total case load -- Start
		IF @Li_Exists_NUMB != 0
		BEGIN
			SET @Ls_Sql_TEXT = 'UPDATE USRL_Y1';
			SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(CAST(@Ln_CrasCurOffice_IDNO AS VARCHAR), '') + ', Role_ID = ' + @Lc_CrasCurRole_ID+', TransactionEventSeq_NUMB = ' + CAST(@Ln_CrasCurTransactionEventSeq_NUMB AS VARCHAR(19));
        
			UPDATE u 
			  SET u.CasesAssigned_QNTY = (SELECT COUNT(1)
											FROM CWRK_Y1 w
										   WHERE w.Worker_ID = u.Worker_ID
											AND w.Role_ID = u.Role_ID
											AND w.Office_IDNO = u.Office_IDNO
											AND w.EndValidity_DATE = @Ld_High_DATE
											AND w.Effective_DATE <= @Ld_Run_DATE
											AND w.Expire_DATE > @Ld_Run_DATE
											AND EXISTS (SELECT 1
														  FROM CASE_Y1 c
														 WHERE c.Case_IDNO = w.Case_IDNO
														   AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)),
				  u.BeginValidity_DATE = @Ld_Run_DATE,
				  u.TransactionEventSeq_NUMB = @Ln_CrasCurTransactionEventSeq_NUMB,
				  u.Update_DTTM = @Ld_Start_DATE,
				  u.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT
			 OUTPUT DELETED.Worker_ID,
					DELETED.Office_IDNO,
					DELETED.Role_ID,
					DELETED.Effective_DATE,
					DELETED.Expire_DATE,
					DELETED.BeginValidity_DATE,
					@Ld_Run_DATE,
					DELETED.TransactionEventSeq_NUMB,
					DELETED.Update_DTTM,
					DELETED.WorkerUpdate_ID,
					DELETED.AlphaRangeFrom_CODE,
					DELETED.AlphaRangeTo_CODE,
					DELETED.WorkerSub_ID,
					DELETED.Supervisor_ID,
					DELETED.CasesAssigned_QNTY
			 INTO USRL_Y1
			 FROM USRL_Y1 u
			 JOIN CRAS_Y1 c
			   ON c.Office_IDNO = @Ln_CrasCurOffice_IDNO
			  AND c.Office_IDNO = u.Office_IDNO
			  AND c.Role_ID = @Lc_CrasCurRole_ID
			  AND c.TransactionEventSeq_NUMB = @Ln_CrasCurTransactionEventSeq_NUMB
			  AND c.Request_DATE <= @Ld_Run_DATE
			  AND c.Status_CODE = @Lc_No_INDC
			  AND c.Processed_DATE = @Ld_Low_DATE
			  AND c.TypeRequest_CODE IN (@Lc_TypeRequestO_CODE, @Lc_TypeRequestR_CODE)
			 WHERE u.Role_ID = CASE WHEN c.Role_ID = @Lc_Space_TEXT
									THEN u.Role_ID
									ELSE c.Role_ID
							  END
			  AND @Ld_Run_DATE BETWEEN u.Effective_DATE AND u.Expire_DATE
			  AND u.EndValidity_DATE = @Ld_High_DATE;
			  
			IF @@ROWCOUNT = 0
			BEGIN
				SET @Ls_DescriptionError_TEXT = 'UPDATE USRL_Y1 CasesAssigned_QNTY Failed';
				RAISERROR(50001,16,1);
			END
		END
        
        SET @Ls_Sql_TEXT = 'UPDATE CRAS_Y1 - 2';
        SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(CAST(@Ln_CrasCurOffice_IDNO AS VARCHAR), '') + ', Role_ID = ' + @Lc_CrasCurRole_ID;

        UPDATE CRAS_Y1
           SET Status_CODE = @Lc_Yes_INDC,
               Processed_DATE = @Ld_Run_DATE
         WHERE Office_IDNO = @Ln_CrasCurOffice_IDNO
           AND ((Role_ID = @Lc_CrasCurRole_ID
                 AND @Lc_CrasCurTypeRequest_CODE = @Lc_TypeRequestR_CODE)
                 OR @Lc_CrasCurTypeRequest_CODE = @Lc_TypeRequestO_CODE)
           AND TransactionEventSeq_NUMB = @Ln_CrasCurTransactionEventSeq_NUMB;
          
        IF @@ROWCOUNT = 0
		BEGIN
			SET @Ls_DescriptionError_TEXT = 'UPDATE CRAS_Y1 Failed';
			RAISERROR(50001,16,1);
		END
		-- 13573 Case reassignment batch populated incorrect total case load -- End   
        
     END TRY

     BEGIN CATCH
      IF CURSOR_STATUS('Local', 'Cwrk_CUR') IN (0, 1)
       BEGIN
        CLOSE Cwrk_CUR;

        DEALLOCATE Cwrk_CUR;
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER ();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

    
		ROLLBACK TRANSACTION MAIN;
		
        SAVE TRANSACTION MAIN;
   

      IF @Ln_Error_NUMB <> 50001
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

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Package_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_Msg_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT, --@Ls_Sqldata_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
        RAISERROR (50001,16,1);
      END
      ELSE IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
      BEGIN
		SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
	  END
     END CATCH

     --If the Erroneous Exceptions are more than the threshold, then we need to abend the program. The commit will ensure that the records processed so far without any problems are committed. Also the exception entries are committed so that it will be easy to determine the error records.	
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
        AND @Ln_ExceptionThresholdParm_QNTY > 0
      BEGIN
       SET @Ln_ExceptionThreshold_QNTY = 0;
       -- 'Reached Threshold'
       SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD REACHED';
       SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
	   
       RAISERROR (50001,16,1);
      END

     --If the commit frequency is attained, the following is done. Reset the commit COUNT, Commit the transaction completed until now.
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        AND @Ln_CommitFreqParm_QNTY > 0
      BEGIN
       
		 
         COMMIT TRANSACTION MAIN_TRAN;
		 
		 BEGIN TRANSACTION MAIN_TRAN;

         SAVE TRANSACTION MAIN;
       

       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ln_CursorError_QNTY = 0;
     SET @Ln_Cursor_QNTY = 0;
     
     SET @Ls_Sql_TEXT = 'FETCH Cras_CUR - 2';
	 SET @Ls_Sqldata_TEXT = '';
	 
     FETCH NEXT FROM Cras_CUR INTO @Ln_CrasCurOffice_IDNO, @Lc_CrasCurRole_ID, @Lc_CrasCurStatus_CODE, @Lc_CrasCurTypeRequest_CODE, @Ld_CrasCurRequest_DATE, @Ln_CrasCurTransactionEventSeq_NUMB, @Ld_CrasCurUpdate_DTTM;
	 
     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END /*END*/
   
   CLOSE Cras_CUR;

   DEALLOCATE Cras_CUR;

   /* If received input file is not having any record(s) to process then
        NO RECORD(S) TO PROCESS message logging in BATE_Y1 table */
   IF @Ln_CursorTotal_QNTY = 0
    BEGIN

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
      SET @Ls_Sqldata_TEXT = 'Package_NAME = ' + @Ls_Package_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', RunParm_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR)+', Sql_data = ' + @Ls_Sqldata_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Package_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorW_CODE,
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_BateErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sqldata_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   --Update the daily_date field for this procedure in vparm table with the pd_dt_run value
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Updating the log with result
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) 
						 + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) 
						 + ', Job_ID = ' + @Lc_Job_ID 
						 + ', Process_NAME = ' + @Ls_Package_NAME 
						 + ', Procedure_NAME = ' + @Ls_Procedure_NAME;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Package_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_CursorTotal_QNTY;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION MAIN_TRAN;
    END
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION MAIN_TRAN;
    END

   IF CURSOR_STATUS('Local', 'Cras_CUR') IN (0, 1)
    BEGIN
     CLOSE Cras_CUR;

     DEALLOCATE Cras_CUR;
    END

   IF CURSOR_STATUS('Local', 'Cwrk_CUR') IN (0, 1)
    BEGIN
     CLOSE Cwrk_CUR;

     DEALLOCATE Cwrk_CUR;
    END

   SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END
   
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Package_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Cursor_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
