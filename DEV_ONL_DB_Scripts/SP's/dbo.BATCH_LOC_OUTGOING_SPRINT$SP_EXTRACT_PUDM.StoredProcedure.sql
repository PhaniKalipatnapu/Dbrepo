/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_SPRINT$SP_EXTRACT_PUDM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_OUTGOING_SPRINT$SP_EXTRACT_PUDM
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
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_SPRINT$SP_EXTRACT_PUDM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_TypeErrorWarning_CODE         CHAR(1) = 'W',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_StatusCaseOpen_CODE           CHAR(1) = 'O',
          @Lc_StatusNonLocate_CODE          CHAR(1) = 'N',
          @Lc_CaseMemberActiveStatus_CODE   CHAR(1) = 'A',
          @Lc_RespondInitResponding_CODE    CHAR(1) = 'R',
          @Lc_RespondInitInState_CODE       CHAR(1) = 'N',
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE       CHAR(1) = 'C',
          @Lc_StatusConfirmedGood_CODE      CHAR(1) = 'Y',
          @Lc_TypeAddressTrip_CODE          CHAR(1) = 'T',
          @Lc_StatusReceiptHold_CODE        CHAR(1) = 'H',
          @Lc_TypeCaseNonIvd_CODE           CHAR(1) = 'H',
          @Lc_CheckRecipientNcpCp_CODE      CHAR(1) = '1',
          @Lc_CaseCategoryPt_CODE           CHAR(2) = 'PT',
          @Lc_ReasonOnHoldSdna_CODE         CHAR(4) = 'SDNA',
          @Lc_Job_ID                        CHAR(7) = 'DEB8094',
          @Lc_ErrorE0944_CODE               CHAR(18) = 'E0944',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_UserBatch_IDNO                CHAR(30) = 'BATCH',
          @Lc_ParmDateProblem_TEXT          CHAR(30) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_LOC_OUTGOING_SPRINT',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_EXTRACT_PUDM',
		  @Ld_High_DATE						DATE = '9999-12-31';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
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
   --Global temprary table creation
   SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractSprint_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractSprint_P1
    (
      Record_TEXT CHAR(9)
    );

   -- Begin the transaction to extract data 
   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION OUTGOING_SPRINT;

   -- The Batch start time to use while inserting in to the batch log
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   -- Selecting the Batch details
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

   --Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --Delete data from ESPRT_Y1
   SET @Ls_Sql_TEXT = 'DELETE ESPRT_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE ESPRT_Y1;

   -- Insert NCP details into table ESPRT_Y1
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
                     AND s.TypeCasE_CODE <> @Lc_TypeCaseNonIvd_CODE
                     AND s.CaseCategory_CODE <> @Lc_CaseCategoryPt_CODE)
      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND ((EXISTS (SELECT 1
                      FROM LSTT_Y1 l
                     WHERE l.MemberMci_IDNO = d.MemberMci_IDNO
                       AND l.StatusLocate_CODE = @Lc_StatusNonLocate_CODE
					   AND l.EndValidity_DATE = @Ld_High_DATE)
            AND EXISTS (SELECT 1
                          FROM CASE_Y1 s
                         WHERE s.Case_IDNO = m.Case_IDNO
                           AND s.RespondInit_CODE IN (@Lc_RespondInitInState_CODE, @Lc_RespondInitResponding_CODE))
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
                                    AND a.TypeAddress_CODE <> @Lc_TypeAddressTrip_CODE)
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
                     AND s.TypeCasE_CODE <> @Lc_TypeCaseNonIvd_CODE
                     AND s.CaseCategory_CODE <> @Lc_CaseCategoryPt_CODE)
      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
      AND m.Case_IDNO = l.Case_IDNO
      AND l.ReasonStatus_CODE = @Lc_ReasonOnHoldSdna_CODE
      AND l.Status_CODE = @Lc_StatusReceiptHold_CODE
      AND l.CheckRecipient_ID = d.MemberMci_IDNO
      AND l.CheckRecipient_CODE = @Lc_CheckRecipientNcpCp_CODE;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(*)
                                          FROM ESPRT_Y1 e);

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS FOUND';
     SET @Ls_Sqldata_TEXT = 'BATCH_COMMON$SP_BATE_LOG';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
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
     -- Extracting Data
     -- Writing Detail Records 
     SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtractSprint_P1';
     SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

     INSERT INTO ##ExtractSprint_P1
                 (Record_TEXT)
     SELECT RIGHT(('000000000' + LTRIM(RTRIM(e.MemberSsn_NUMB))), 9)
       FROM ESPRT_Y1 e;

     SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     COMMIT TRANSACTION OUTGOING_SPRINT;

     SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractSprint_P1';
     SET @Ls_Sql_TEXT = 'EXTRACT DATA';
     SET @Ls_Sqldata_TEXT = ' FILE Location = ' + @Ls_FileLocation_TEXT + ', Ls_File_NAME = ' + @Ls_File_NAME + ', Query TEXT = ' + @Ls_Query_TEXT;
     SET @Ls_File_NAME = @Ls_File_NAME + '_' + CONVERT(VARCHAR, @Ld_Run_DATE, 112) + '.txt';

     -- Output file name format is PUDM_INQ_CCYYMMDD.txt
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
    END

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

   --Success full execution write to BSTL_Y1
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', USER ID = ' + @Lc_UserBatch_IDNO;

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
    @Ac_Worker_ID                 = @Lc_UserBatch_IDNO,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Drop the temporary table used to store data
   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractSprint_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE ##ExtractSprint_P1;

   --Commit the transaction
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION OUTGOING_SPRINT;
  END TRY

  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_SPRINT;
    END;

   --Check if temporary table exists drop the table
   IF OBJECT_ID('tempdb..##ExtractSprint_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractSprint_P1;
    END

   --Check for Exception information to log the description text based on the error
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
    @Ac_Worker_ID                 = @Lc_UserBatch_IDNO,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
