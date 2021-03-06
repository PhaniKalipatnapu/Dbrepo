/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GENERATE_CSM23_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GENERATE_CSM23_NOTICE
Programmer Name 	: IMP Team
Description			: This procedure is added for Bug 13634 CR0411 to generate CSM-23 notice for cases added 
					  to IFMS_Y1 for the 1st time with A type transaction.
					  This notice must be automatically sent to the CP in the life of the case.  
					  Once the notice is sent to the CP, a new notice should not be sent if the NCP becomes 
					  ineligible for a time and later becomes eligible and is referred again, 
					  or if the NCP becomes eligible for additional programs, such as Passport Denial.
Frequency			: 'WEEKLY'
Developed On		: 
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GENERATE_CSM23_NOTICE] (
 @Ac_Job_ID                CHAR(7),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_TypeError_CODE            CHAR(1) = 'E',
          @Lc_Note_INDC                 CHAR(1) = 'N',
          @Lc_TypeTransactionEnf24_CODE CHAR(1) = '4',
          @Lc_TypeTransactionEnf27_CODE CHAR(1) = '7',
          @Lc_TypeTransactionEnf25_CODE CHAR(1) = '5',
          @Lc_CaseRelationshipC_CODE	CHAR(1) = 'C',
          @Lc_CaseMemberStatusA_CODE	CHAR(1) = 'A',
          @Lc_TypeTransactionA_CODE     CHAR(1) = 'A',
          @Lc_SubsystemEn_CODE          CHAR(2) = 'EN',
          @Lc_ActivityMajorCase_CODE    CHAR(4) = 'CASE',
          @Lc_BatchRunUser_TEXT         CHAR(5) = 'BATCH',
          @Lc_BateErrorE1424_CODE       CHAR(5) = 'E1424',
          @Lc_ActivityMinorNopri_CODE   CHAR(5) = 'NOPRI',
          @Lc_Job_ID                    CHAR(7) = @Ac_Job_ID,
          @Lc_NoticeCsm23_ID            CHAR(8) = 'CSM-23',
          @Ls_Procedure_NAME            VARCHAR(100) = 'SP_GENERATE_CSM23_NOTICE',
          @Ls_Process_NAME              VARCHAR(100) = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET',
          @Ld_Run_DATE                  DATE = @Ad_Run_DATE,
          @Ld_Start_DATE                DATETIME2;
  DECLARE @Ln_Zero_NUMB                NUMERIC = 0,
          @Ln_RecordCount_QNTY         NUMERIC(10, 0) = 0,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_Topic_IDNO               NUMERIC(18),
          @Ln_TopicIn23_IDNO           NUMERIC(18) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Ln_FetchStatus_QNTY         NUMERIC = 0,
          @Ln_RowCount_QNTY            NUMERIC = 0,
          @Lc_Empty_TEXT               CHAR = '',
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_BateError_CODE           CHAR(5),
          @Ls_Sql_TEXT                 VARCHAR(200),
          @Ls_SqlData_TEXT             VARCHAR(1000),
          @Ls_ErrorMessage_TEXT        VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT          VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT    VARCHAR(MAX);
  DECLARE @Ln_NoticeCur_MemberMci_IDNO     NUMERIC(10) = 0,
          @Ln_NoticeCur_Case_IDNO          NUMERIC(6) = 0;

  BEGIN TRY
   IF OBJECT_ID('tempdb..##PrepFedCsm23Notice_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##PrepFedCsm23Notice_P1;
    END;

   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
    	   
	--get all cases that got added to IFMS today.
	;WITH Q1 AS
	(
		SELECT DISTINCT A.MemberMci_IDNO, A.Case_IDNO, B.MemberMci_IDNO AS MemberMciCp_IDNO
		FROM IFMS_Y1 A, CMEM_Y1 B
		WHERE A.SubmitLast_DATE = @Ad_Run_DATE
		AND A.TypeTransaction_CODE = @Lc_TypeTransactionA_CODE
		AND B.Case_IDNO = A.Case_IDNO
		AND B.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
		AND B.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
	)
	--make sure that the case got added to IFMS for the 1st time in it's life.
	, Q2 AS
	(
		SELECT A.MemberMci_IDNO, A.Case_IDNO, A.MemberMciCp_IDNO
		FROM Q1 A
		--case should not exist in IFMS before
		WHERE NOT EXISTS
		(
			SELECT 1
			FROM IFMS_Y1 X
			WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
			AND X.Case_IDNO = A.Case_IDNO
			AND X.SubmitLast_DATE < @Ad_Run_DATE
		)
		--case should not exist in HIFMS other than notice records
		AND NOT EXISTS
		(
			SELECT 1
			FROM HIFMS_Y1 X
			WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
			AND X.Case_IDNO = A.Case_IDNO
			AND X.SubmitLast_DATE < @Ad_Run_DATE
			AND X.TypeTransaction_CODE NOT IN (@Lc_TypeTransactionEnf24_CODE, @Lc_TypeTransactionEnf25_CODE, @Lc_TypeTransactionEnf27_CODE)
		)
	)
	--make sure that csm23 notice was never generated for this CP on this case.
	, Q3 AS
	(
		SELECT A.MemberMci_IDNO, A.Case_IDNO, A.MemberMciCp_IDNO
		FROM Q2 A
		WHERE 
		--make sure that csm23 notice was NOT generated TODAY by tax offset batches for this CP on this case (or) is NOT in queue in NMRQ to move to NRRQ.
		NOT EXISTS
		(
			SELECT 1
			FROM NMRQ_Y1 X
			WHERE 
			(
				X.Recipient_ID = RIGHT(('0000000000' + LTRIM(RTRIM(A.MemberMciCp_IDNO))), 10)
				OR Recipient_ID = CAST(A.MemberMciCp_IDNO AS VARCHAR)
			)
			AND X.Case_IDNO = A.Case_IDNO
			AND UPPER(LTRIM(RTRIM(X.Notice_ID))) = UPPER(@Lc_NoticeCsm23_ID)
		)
		--make sure that csm23 notice was NOT sent already to this CP on this case
		AND NOT EXISTS
		(
			SELECT 1
			FROM NRRQ_Y1 X
			WHERE 
			(
				X.Recipient_ID = RIGHT(('0000000000' + LTRIM(RTRIM(A.MemberMciCp_IDNO))), 10)
				OR Recipient_ID = CAST(A.MemberMciCp_IDNO AS VARCHAR)
			)
			AND X.Case_IDNO = A.Case_IDNO
			AND UPPER(LTRIM(RTRIM(X.Notice_ID))) = UPPER(@Lc_NoticeCsm23_ID)
		)		
	)
	SELECT A.MemberMci_IDNO, A.Case_IDNO, A.MemberMciCp_IDNO INTO ##PrepFedCsm23Notice_P1 FROM Q3 A;

   DECLARE Notice_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT A.MemberMciCp_IDNO AS MemberMci_IDNO,
           A.Case_IDNO
      FROM ##PrepFedCsm23Notice_P1 A
     ORDER BY 1, 2;

   SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TRAN_GEN_FED_CSM23_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   BEGIN TRANSACTION TRAN_GEN_FED_CSM23_NOTICE;

   SET @Ln_RecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'OPEN Notice_CUR';

   OPEN Notice_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Notice_CUR - 1';

   FETCH NEXT FROM Notice_CUR INTO @Ln_NoticeCur_MemberMci_IDNO, @Ln_NoticeCur_Case_IDNO;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE @Ln_FetchStatus_QNTY = @Ln_Zero_NUMB
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'SAVE TRANSACTION SAVE_GEN_FED_CSM23_NOTICE';
      SET @Ls_SqlData_TEXT = '';

	  SAVE TRANSACTION SAVE_GEN_FED_CSM23_NOTICE;
     
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_NoticeCur_Case_IDNO AS VARCHAR);

      SELECT @Ln_TopicIn23_IDNO = 0;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
      SET @Ls_SqlData_TEXT = '';

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

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - CSM-23';
      SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NoticeCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorNopri_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemEn_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_NoticeCsm23_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn23_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '');

      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
       @An_Case_IDNO                = @Ln_NoticeCur_Case_IDNO,
       @An_MemberMci_IDNO           = @Ln_NoticeCur_MemberMci_IDNO,
       @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
       @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorNopri_CODE,
       @Ac_Subsystem_CODE           = @Lc_SubsystemEn_CODE,
       @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
       @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_Notice_ID                = @Lc_NoticeCsm23_ID,
       @An_TopicIn_IDNO             = @Ln_TopicIn23_IDNO,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

        RAISERROR (50001,16,1);
       END
      ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
        SET @Lc_BateError_CODE = @Lc_Msg_CODE;

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TRAN_GEN_FED_CSM23_NOTICE';
      SET @Ls_SqlData_TEXT = '';

      COMMIT TRANSACTION TRAN_GEN_FED_CSM23_NOTICE;

      SET @Ls_Sql_TEXT = 'BEGIN TRANSACTION TRAN_GEN_FED_CSM23_NOTICE';
      SET @Ls_SqlData_TEXT = '';

      BEGIN TRANSACTION TRAN_GEN_FED_CSM23_NOTICE;
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION SAVE_GEN_FED_CSM23_NOTICE;
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING(ERROR_MESSAGE(), 1, 200);

        RAISERROR(50001,16,1);
       END

      IF LEN(LTRIM(RTRIM(ISNULL(@Lc_BateError_CODE, '')))) = @Ln_Zero_NUMB
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
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
      SET @Ls_SqlData_TEXT = 'BateError_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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
     END CATCH;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Notice_CUR - 2';

     FETCH NEXT FROM Notice_CUR INTO @Ln_NoticeCur_MemberMci_IDNO, @Ln_NoticeCur_Case_IDNO;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Notice_CUR';

   CLOSE Notice_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Notice_CUR';

   DEALLOCATE Notice_CUR;

   SET @Ls_Sql_TEXT = 'COMMIT TRANSACTION TRAN_GEN_FED_CSM23_NOTICE';
   SET @Ls_SqlData_TEXT = '';

   COMMIT TRANSACTION TRAN_GEN_FED_CSM23_NOTICE;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;

   IF OBJECT_ID('tempdb..##PrepFedCsm23Notice_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##PrepFedCsm23Notice_P1;
    END;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > @Ln_Zero_NUMB
    BEGIN
     ROLLBACK TRANSACTION TRAN_GEN_FED_CSM23_NOTICE;
    END;
  
   IF OBJECT_ID('tempdb..##PrepFedCsm23Notice_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##PrepFedCsm23Notice_P1;
    END;

   IF CURSOR_STATUS('Local', 'Notice_CUR') IN (0, 1)
    BEGIN
     CLOSE Notice_CUR;

     DEALLOCATE Notice_CUR;
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

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
