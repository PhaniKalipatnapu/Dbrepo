/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_PROCESS_MEMBER_MERGE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Program Name      : BATCH_CM_MERG$SP_PROCESS_MEMBER_MERGE
Programmer Name   : IMP Team.
Description       : The CM Merge batch will read “Pending Requests to Merge Members”.  The process will ensure that criteria for 
					the requested merge are in accordance with the system’s rules for merging.
Frequency         : DAILY
Developed On      : 04/06/2011
Called By         : None
Called On		  : BATCH_COMMON$SP_GET_BATCH_DETAILS, BATCH_CM_MERG$SP_VALIDATE_MMRG_MEMBERS, BATCH_CM_MERG$SP_MEMBER_MERGE,
					BATCH_COMMON$SP_BATE_LOG and BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
----------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_PROCESS_MEMBER_MERGE]
AS
   SET NOCOUNT ON;
   DECLARE @Lc_StatusFailed_CODE         CHAR(1)		= 'F',
           @Lc_StatusSuccess_CODE        CHAR(1)		= 'S',
           @Lc_Space_TEXT                CHAR(1)		= ' ',
           @Ls_No_INDC					 CHAR(1)		= 'N',
           @Lc_StatusMergePending_CODE   CHAR(1)		= 'P',
           @Lc_StatusMergeModified_CODE  CHAR(1)		= 'M',
           @Lc_TypeErrorE_CODE			 CHAR(1)		= 'E',
           @Lc_StatusAbnormalend_CODE	 CHAR(1)		= 'A',
           @Lc_MsgA_CODE				 CHAR(1)		= 'A',
           @Lc_MsgB_CODE				 CHAR(1)		= 'B',
           @Lc_MsgC_CODE				 CHAR(1)		= 'C',
           @Lc_MsgD_CODE				 CHAR(1)		= 'D',
           @Lc_MsgE_CODE				 CHAR(1)		= 'E',
           @Lc_MsgG_CODE				 CHAR(1)		= 'G',
           @Lc_MsgH_CODE				 CHAR(1)		= 'H',
           @Lc_MsgI_CODE				 CHAR(1)		= 'I',
           @Lc_MsgJ_CODE				 CHAR(1)		= 'J',
           @Lc_MsgK_CODE				 CHAR(1)		= 'K',
           @Lc_MsgM_CODE				 CHAR(1)		= 'M',
           @Lc_MsgP_CODE				 CHAR(1)		= 'P',
           @Lc_MsgR_CODE				 CHAR(1)		= 'R',
           -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - START
           @Lc_MsgQ_CODE				 CHAR(1)		= 'Q',
		   @Lc_MsgU_CODE				 CHAR(1)		= 'U',
		   @Lc_MsgV_CODE				 CHAR(1)		= 'V',
		   -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - END
           @Lc_ErrorE1014_CODE           CHAR(5)		= 'E1014',
           @Lc_ErrorE1015_CODE           CHAR(5)		= 'E1015',
           @Lc_ErrorE1016_CODE           CHAR(5)		= 'E1016',
           @Lc_ErrorE1017_CODE           CHAR(5)		= 'E1017',
           @Lc_ErrorE1018_CODE           CHAR(5)		= 'E1018',
           @Lc_ErrorE1021_CODE           CHAR(5)		= 'E1021',
           @Lc_ErrorE1245_CODE           CHAR(5)		= 'E1245',
           @Lc_ErrorE1023_CODE           CHAR(5)		= 'E1023',
           @Lc_ErrorE1019_CODE           CHAR(5)		= 'E1019',
           @Lc_ErrorE1025_CODE           CHAR(5)		= 'E1025',
           @Lc_ErrorE1026_CODE           CHAR(5)		= 'E1026',
           @Lc_ErrorE1350_CODE           CHAR(5)		= 'E1350',
           @Lc_ErrorE1243_CODE           CHAR(5)		= 'E1243',
           @Lc_ErrorE5000_CODE           CHAR(5)		= 'E5000',
           @Lc_ErrorBatch_CODE			 CHAR(5)		= 'E1424',
           -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - START
           @Lc_ErrorE0022_CODE           CHAR(5)		= 'E0022',
		   @Lc_ErrorE0023_CODE           CHAR(5)		= 'E0023',
		   @Lc_ErrorE0024_CODE           CHAR(5)		= 'E0024',
		   -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - END
           @Lc_Job_ID					 CHAR(7)		= 'DEB1030',
           @Lc_Successful_TEXT           CHAR(20)		= 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT         CHAR(30)		= 'BATCH',
           @Ls_Procedure_NAME			 VARCHAR(50)	= 'SP_PROCESS_MEMBER_MERGE',
           @Ls_Process_NAME				 VARCHAR(50)	= 'BATCH_CM_MERG',
           @Ld_High_DATE                 DATETIME2		= '12/31/9999';
           
  DECLARE  @Ls_FetchStatus_BIT           SMALLINT,
           @Ln_CommitFreq_NUMB           NUMERIC(5)		= 0,
           @Ln_CommitFreq_QNTY           NUMERIC(5)		= 0,
           @Ln_MemberMciPrimary_IDNO     NUMERIC(10),
           @Ln_MemberMciSecondary_IDNO   NUMERIC(10),
		   @Ln_Error_NUMB				 NUMERIC(10),
           @Ln_ErrorLine_NUMB			 NUMERIC(10),
           @Ln_Cursor_QNTY               NUMERIC(11)	= 0,
           @Ln_ExceptionThreshold_NUMB   NUMERIC(11)	= 0,
           @Ln_ExceptionThreshold_QNTY   NUMERIC(11)	= 0,
           @Ln_TransactionEventSeq_NUMB  NUMERIC(19),
           @Lc_Error_CODE                CHAR(5),
           @Lc_Msg_CODE                  VARCHAR(5),
           @Ls_Sql_TEXT                  VARCHAR(100)	= '',
           @Ls_Sqldata_TEXT              VARCHAR(1000),
           @Ls_DescriptionError_TEXT     VARCHAR(4000)	= '',
           @Ld_Start_DATE                DATETIME2,
           @Ld_Run_DATE                  DATE,
           @Ld_LastRun_DATE              DATE;
           
  DECLARE  @Mmrg_CUR							CURSOR,
           @Mmrg_REC$MemberMciPrimary_IDNO		NUMERIC(10),
		   @Mmrg_REC$MemberMciSecondary_IDNO	NUMERIC(10),		   
           @Mmrg_REC$TransactionEventSeq_NUMB	NUMERIC(19);
           
 BEGIN
  BEGIN TRY
   BEGIN TRANSACTION Main_Transaction;

   -- Defining the cursor @Mmrg_CUR
   SET @Mmrg_CUR = CURSOR LOCAL FORWARD_ONLY STATIC
   FOR SELECT MemberMciPrimary_IDNO,
              MemberMciSecondary_IDNO,
              TransactionEventSeq_NUMB
         FROM MMRG_Y1
        WHERE StatusMerge_CODE = @Lc_StatusMergePending_CODE
          AND EndValidity_DATE = @Ld_High_DATE          
        ORDER BY MemberMciSecondary_IDNO;
        
   SET @Ls_Sql_TEXT = 'GET BATCH_CM_MERG$SP_PROCESS_MEMBER_MERGE START TIME START TIME';
   -- Selecting the Batch start time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_CM_MERG$SP_PROCESS_MEMBER_MERGE - GET BATCH DETAILS';
   SET @Ls_Sqldata_TEXT = 'JOB Seq_IDNO : ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_NUMB OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_NUMB OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   --  Check to avoid duplicate execution of the process
   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_Sql_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'OPEN @Mmrg_CUR';

   OPEN @Mmrg_CUR;

   SET @Ls_Sql_TEXT = 'FETCH @Mmrg_CUR - 1';

   FETCH NEXT FROM @Mmrg_CUR INTO @Mmrg_REC$MemberMciPrimary_IDNO, @Mmrg_REC$MemberMciSecondary_IDNO, @Mmrg_REC$TransactionEventSeq_NUMB;

   SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS;

   -- Cursor loop Starts @Mmrg_CUR		
   WHILE @Ls_FetchStatus_BIT = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION Cursor_Transaction;
      SET @Ln_MemberMciPrimary_IDNO = @Mmrg_REC$MemberMciPrimary_IDNO;
      SET @Ln_MemberMciSecondary_IDNO = @Mmrg_REC$MemberMciSecondary_IDNO;
      SET @Lc_Error_CODE = @Lc_ErrorBatch_CODE;
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      
		-- 13271  - MERG - CR0367 Amend MCI Number 20140219 - START
      /*If Primary Member Not exsits in DB no validation required*/
      IF EXISTS (SELECT 1 FROM DEMO_Y1 a WHERE a.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO)
			BEGIN
				  SET @Ls_Sql_TEXT = 'BATCH_CM_MERG$SP_VALIDATE_MMRG_MEMBERS - MMERG VALIDATIONS';
				  SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO: ' + ISNULL (CAST (@Ln_MemberMciPrimary_IDNO AS VARCHAR (10)), '') + ' MemberMciSecondary_IDNO: ' + ISNULL (CAST (@Ln_MemberMciSecondary_IDNO AS VARCHAR (10)), '');

				  EXECUTE BATCH_CM_MERG$SP_VALIDATE_MMRG_MEMBERS
				   @An_MemberMciPrimary_IDNO   = @Ln_MemberMciPrimary_IDNO,
				   @An_MemberMciSecondary_IDNO = @Ln_MemberMciSecondary_IDNO,
				   @Ac_Process_ID              = @Lc_Job_ID,
				   @Ad_Run_DATE                = @Ld_Run_DATE,
				   @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
				   @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

					
				  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				   BEGIN
					SET @Ls_Sqldata_TEXT = 'BATCH_CM_MERG$SP_VALIDATE_MMRG_MEMBERS FAILED';
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgA_CODE
				   BEGIN
					-- A - E1014  Must have at least one active Member DCN
					SET @Lc_Error_CODE = @Lc_ErrorE1014_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgB_CODE
				   BEGIN
					-- B - E1015 DP and CP from the same case
					SET @Lc_Error_CODE = @Lc_ErrorE1015_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgC_CODE
				   BEGIN
					-- C - E1016 CP and NCP/PF from the same case
					SET @Lc_Error_CODE = @Lc_ErrorE1016_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgD_CODE
				   BEGIN
					-- D - E1017  DP and NCP/PF from the same case
					SET @Lc_Error_CODE = @Lc_ErrorE1017_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgE_CODE
				   BEGIN
					-- E - E1018 Two Member DCN's with different Program Types
					SET @Lc_Error_CODE = @Lc_ErrorE1018_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgG_CODE
				   BEGIN
					-- G - E1021 There are open or closed financial obligations
					SET @Lc_Error_CODE = @Lc_ErrorE1021_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgH_CODE
				   BEGIN
					-- H - E1245 Two Member DCN's with mismatched count in member welfare details
					SET @Lc_Error_CODE = @Lc_ErrorE1245_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgI_CODE
				   BEGIN
					-- I - E1023 - Merging member MCIs must not have an open activity chain
					SET @Lc_Error_CODE = @Lc_ErrorE1023_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgJ_CODE
				   BEGIN
					-- J - E1019  The merging MCI numbers must have the same addresses
					SET @Lc_Error_CODE = @Lc_ErrorE1019_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgK_CODE
				   BEGIN
					-- K - E1025  Member DCN's SSN, DOB and Name does not match
					SET @Lc_Error_CODE = @Lc_ErrorE1025_CODE;
					RAISERROR(50001,16,1);
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgP_CODE
				   BEGIN
					-- P - E1026  Member DCN's Paternity Status does not match
					SET @Lc_Error_CODE = @Lc_ErrorE1026_CODE;
					RAISERROR(50001,16,1);
				   END      
				  ELSE IF @Lc_Msg_CODE = @Lc_MsgR_CODE
				   BEGIN
					-- R - E1025 Merging Member MCI's DOB, Gender and Name must match
					SET @Lc_Error_CODE = @Lc_ErrorE1025_CODE;
					RAISERROR(50001,16,1);
				   END
				 ELSE IF @Lc_Msg_CODE = @Lc_MsgM_CODE
				   BEGIN
					-- M - E1027 Primary Member cannot exists as a Secondary Member
					SET @Lc_Error_CODE = @Lc_ErrorE1243_CODE
					RAISERROR(50001,16,1);
				   END
				-- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - START   
				ELSE IF @Lc_Msg_CODE = @Lc_MsgQ_CODE
				   BEGIN
					-- Q - E0022 Guardian and CP from the same case
					SET @Lc_Error_CODE = @Lc_ErrorE0022_CODE
					RAISERROR(50001,16,1);
				   END
				ELSE IF @Lc_Msg_CODE = @Lc_MsgU_CODE
				   BEGIN
					-- U - E0023 Guardian and NCP/PF from the same case
					SET @Lc_Error_CODE = @Lc_ErrorE0023_CODE
					RAISERROR(50001,16,1);
				   END
				ELSE IF @Lc_Msg_CODE = @Lc_MsgV_CODE
				   BEGIN
					-- V - E0024 Guardian and DP from the same case	
					SET @Lc_Error_CODE = @Lc_ErrorE0024_CODE
					RAISERROR(50001,16,1);
				   END    
				-- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - END  
			END				   
		
		-- 13271  - MERG - CR0367 Amend MCI Number 20140219 - END	
      SET @Ls_Sql_TEXT = 'Generate Seq_IDNO Txn Event1';

      EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
       @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
       @Ac_Process_ID               = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
       @Ac_Note_INDC                = @Ls_No_INDC,
       @An_EventFunctionalSeq_NUMB  = 0,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'UNABLE TO GENERATE TransactionEventSeq_NUMB';
        RAISERROR(50001,16,1);
       END

	  SET @Ls_Sql_TEXT = 'EXECUTE BATCH_CM_MERG$SP_MEMBER_MERGE';
	 
      EXECUTE BATCH_CM_MERG$SP_MEMBER_MERGE
       @An_MemberMciSecondary_IDNO  = @Ln_MemberMciSecondary_IDNO,
       @An_MemberMciPrimary_IDNO    = @Ln_MemberMciPrimary_IDNO,
       @An_Cursor_QNTY              = @Ln_Cursor_QNTY,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_CM_MERG$SP_MEMBER_MERGE FAILED';
        RAISERROR(50001,16,1);
       END
      ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
       BEGIN
        SET @Ls_Sql_TEXT = 'UPDATE MMRG_Y1';

        UPDATE MMRG_Y1
           SET EndValidity_DATE = @Ld_Run_DATE
         WHERE MemberMciPrimary_IDNO = @Ln_MemberMciPrimary_IDNO
           AND MemberMciSecondary_IDNO = @Ln_MemberMciSecondary_IDNO
           AND StatusMerge_CODE = @Lc_StatusMergePending_CODE
           AND EndValidity_DATE = @Ld_High_DATE
           AND TransactionEventSeq_NUMB = @Mmrg_REC$TransactionEventSeq_NUMB;

        IF @@ROWCOUNT = 0
         BEGIN
          SET @Ls_DescriptionError_TEXT = 'UPDATE MMRG_Y1 FAILED';
          RAISERROR(50001,16,1);
         END

        SET @Ls_Sql_TEXT = 'INSERT MMRG_Y1' + ISNULL (CAST (@Ln_MemberMciPrimary_IDNO AS VARCHAR (10)), '') + ' ' + ISNULL (CAST (@Ln_MemberMciSecondary_IDNO AS VARCHAR (10)), '') + ' ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR (19)), '');

        INSERT MMRG_Y1
               (MemberMciPrimary_IDNO,
                MemberMciSecondary_IDNO,
                StatusMerge_CODE,
                BeginValidity_DATE,
                EndValidity_DATE,
                WorkerUpdate_ID,
                Update_DTTM,
                TransactionEventSeq_NUMB)
        SELECT MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               @Lc_StatusMergeModified_CODE,
               @Ld_Run_DATE,
               @Ld_High_DATE,
               @Lc_BatchRunUser_TEXT,
               @Ld_Start_DATE,
               @Ln_TransactionEventSeq_NUMB
          FROM MMRG_Y1
         WHERE MemberMciPrimary_IDNO = @Ln_MemberMciPrimary_IDNO
           AND MemberMciSecondary_IDNO = @Ln_MemberMciSecondary_IDNO
           AND TransactionEventSeq_NUMB = @Mmrg_REC$TransactionEventSeq_NUMB;

        IF @@ROWCOUNT = 0
         BEGIN
          SET @Ls_DescriptionError_TEXT = 'INSERT MMRG_Y1 FAILED';
          RAISERROR(50001,16,1);
         END
       END

      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
    
     END TRY

     BEGIN CATCH
		-- 13588 - Merg Batch Exception Handling - Start
		IF XACT_STATE() = 1
		BEGIN
		   ROLLBACK TRANSACTION Cursor_Transaction;
		END
		ELSE
		BEGIN
			SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE(), 1, 200);
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
     
	   SAVE TRANSACTION Cursor_Transaction;
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
       
        IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
		BEGIN
		 SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		END
		ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		BEGIN
		 RAISERROR (50001,16,1);
		END
		-- 13588 - Merg Batch Exception Handling - End
					
     END CATCH

     SET @Ls_Sql_TEXT = 'RECORD COMMIT COUNT1: ' + ISNULL(CAST(@Ln_CommitFreq_QNTY AS CHAR(5)), '');

     IF (@Ln_CommitFreq_NUMB <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreq_NUMB)
      BEGIN
       SET @Ls_Sqldata_TEXT = 'JOB Seq_IDNO : ' + ISNULL(@Lc_Job_ID, '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '');
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cursor_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE : FAILED';
         RAISERROR(50001,16,1);
        END

       IF (@@TRANCOUNT > 0)
        BEGIN
			COMMIT TRANSACTION Main_Transaction;
			BEGIN TRANSACTION Main_Transaction;
        END
       SET @Ln_CommitFreq_QNTY = 0;
      END

     IF (@Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThreshold_NUMB 
		AND @Ln_ExceptionThreshold_NUMB > 0)
      BEGIN
	   SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThreshold_NUMB AS VARCHAR);
       SET @Ls_DescriptionError_TEXT ='REACHED EXCEPTION THRESHOLD';
       COMMIT TRANSACTION Main_Transaction;	
       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM @Mmrg_CUR INTO @Mmrg_REC$MemberMciPrimary_IDNO, @Mmrg_REC$MemberMciSecondary_IDNO, @Mmrg_REC$TransactionEventSeq_NUMB;

     SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS;
    END

   CLOSE @Mmrg_CUR;

   DEALLOCATE @Mmrg_CUR;

   IF @Ln_Cursor_QNTY = 0
    BEGIN
     SET @Ls_Sqldata_TEXT = 'JOB Seq_IDNO : ' + ISNULL(@Lc_Job_ID, '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '')
     SET @Ls_Sql_TEXT = ' BATCH_COMMON.SP_BATE_LOG_11';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = 'W',
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = 'E0944',
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 2 : FAILED';
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sqldata_TEXT = 'JOB ID : ' + ISNULL(@Lc_Job_ID, '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '');
   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   
   -- Update the daily_date field for this procedure in vparm table with the pd_dt_run value
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF (@Lc_Msg_CODE != @Lc_StatusSuccess_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE : FAILED';
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'LOG THE Result_TEXT';

   -- Updating the log with result
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = '',
    @As_ExecLocation_TEXT     = @LC_Successful_TEXT,
    @As_ListKey_TEXT          = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY	= @Ln_Cursor_QNTY;

   IF @@TRANCOUNT > 0
    BEGIN
     COMMIT TRANSACTION Main_Transaction;
    END
  END TRY

  BEGIN CATCH
	
   IF @@TRANCOUNT > 0
    BEGIN
		ROLLBACK TRANSACTION Main_Transaction;
    END

   IF CURSOR_STATUS('VARIABLE', '@@Mmrg_CUR') IN (0, 1)
    BEGIN
     CLOSE @Mmrg_CUR;
     DEALLOCATE @Mmrg_CUR;
    END
    
   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
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
    @As_CursorLocation_TEXT			= '',
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
