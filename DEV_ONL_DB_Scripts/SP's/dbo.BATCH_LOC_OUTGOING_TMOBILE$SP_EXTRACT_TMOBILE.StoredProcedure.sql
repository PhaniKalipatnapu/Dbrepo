/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_TMOBILE$SP_EXTRACT_TMOBILE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_OUTGOING_TMOBILE$SP_EXTRACT_TMOBILE
Programmer Name 	: IMP Team
Description			: This process extracts DACSES NCP's data to create locate requests to T-Mobile wireless.
Frequency			: 'QUATERLY'
Developed On		: 06/07/2011
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
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_TMOBILE$SP_EXTRACT_TMOBILE]
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
		  @Lc_ReasonOnHoldSdca_CODE         CHAR(4) = 'SDCA',
          @Lc_ReasonOnHoldSdna_CODE         CHAR(4) = 'SDNA',
          @Lc_ErrorE0944_CODE               CHAR(5) = 'E0944',
          @Lc_Job_ID                        CHAR(7) = 'DEB8076',
          @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
          @Lc_UserBatch_IDNO                CHAR(30) = 'BATCH',
          @Ls_ParmDateProblem_TEXT          VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_LOC_OUTGOING_TMOBILE',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_EXTRACT_TMOBILE',
		  @Ld_High_DATE                     DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_FileSequence_NUMB           NUMERIC(7, 0),
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
   SET @Ls_Sql_TEXT = 'GLOBAL TEMPORARY TABLE CREATION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractTmobile_P1
    (
      Record_TEXT VARCHAR(85)
    );

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   BEGIN TRANSACTION OUTGOING_TMOBILE;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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

   SET @Ls_Sql_TEXT = 'COUNT OF SUCCESSFUL EXECUTION OF JOB';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   SET @Ln_FileSequence_NUMB = (SELECT COUNT(1)
                                  FROM BSTL_Y1
                                 WHERE Job_ID = @Lc_Job_ID
                                   AND Status_CODE = @Lc_StatusSuccess_CODE) + 1;
   
   SET @Ls_Sql_TEXT = 'DELETE ExtractTmobile_T1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   DELETE ETMOB_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO ETMOB_Y1';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT ETMOB_Y1
          (FileSeq_IDNO,
           First_NAME,
           Middle_NAME,
           Last_NAME,
           MemberSsn_NUMB,
           Birth_DATE,
           MemberMci_IDNO)
   SELECT DISTINCT
          @Ln_FileSequence_NUMB,
          SUBSTRING(d.First_NAME, 1, 15),
          SUBSTRING(d.Middle_NAME, 1, 15),
          SUBSTRING(d.Last_NAME, 1, 16),
          CONVERT(VARCHAR(9), d.MemberSsn_NUMB),
          CONVERT(VARCHAR, d.Birth_DATE, 112),
          CONVERT(VARCHAR(7), RIGHT(d.MemberMci_IDNO, 7))
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
      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND ((EXISTS (SELECT 1
                      FROM LSTT_Y1 l
                     WHERE MemberMci_IDNO = d.MemberMci_IDNO
                       AND StatusLocate_CODE = @Lc_StatusNonLocate_CODE
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
                                  WHERE A.Status_CODE = @Lc_StatusConfirmedGood_CODE
                                    AND @Ld_Run_DATE BETWEEN A.Begin_DATE AND A.End_DATE
                                    AND A.MemberMci_IDNO = d.MemberMci_IDNO
                                    AND A.TypeAddress_CODE = @Lc_TypeAddressMailing_CODE)
                      OR NOT EXISTS (SELECT 1
                                       FROM EHIS_Y1 e
                                      WHERE e.MemberMci_IDNO = d.MemberMci_IDNO
                                        AND @Ld_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
                                        AND e.Status_CODE = @Lc_StatusConfirmedGood_CODE))))
   UNION
   SELECT DISTINCT
          @Ln_FileSequence_NUMB,
          SUBSTRING(d.First_NAME, 1, 15),
          SUBSTRING(d.Middle_NAME, 1, 15),
          SUBSTRING(d.Last_NAME, 1, 16),
          CONVERT(VARCHAR(9), d.MemberSsn_NUMB),
          CONVERT(VARCHAR, d.Birth_DATE, 112),
          CONVERT(VARCHAR(7), RIGHT(d.MemberMci_IDNO, 7))
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
      AND m.CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
      AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
      AND m.Case_IDNO = l.Case_IDNO
      AND l.ReasonStatus_CODE IN (@Lc_ReasonOnHoldSdca_CODE,@Lc_ReasonOnHoldSdna_CODE)
      AND l.Status_CODE = @Lc_StatusReceiptHold_CODE
      AND l.CheckRecipient_ID = d.MemberMci_IDNO
      AND l.CheckRecipient_CODE = @Lc_CheckRecipientNcpCp_CODE;

   SET @Ls_Sql_TEXT = 'NO OF RECORDS COUNT';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM ETMOB_Y1 e);

   IF @Ln_ProcessedRecordCount_QNTY = 0
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

   SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtractTmobile_P1';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractTmobile_P1
               (Record_TEXT)
   SELECT CONVERT(VARCHAR, @Ld_Run_DATE, 112) + RIGHT(('0000000' + LTRIM(RTRIM(e.FileSeq_IDNO))), 7) + CONVERT(CHAR(15), e.First_NAME) + CONVERT(CHAR(15), e.Middle_NAME) + CONVERT(CHAR(16), e.Last_NAME) + RIGHT(('000000000' + LTRIM(RTRIM(e.MemberSsn_NUMB))), 9) + e.Birth_DATE + RIGHT(('0000000' + LTRIM(RTRIM(e.MemberMci_IDNO))), 7) AS Record_TEXT
     FROM ETMOB_Y1 e;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   COMMIT TRANSACTION OUTGOING_TMOBILE;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractTmobile_P1 ';
   SET @Ls_Sql_TEXT = 'Extract Data';
   SET @Ls_Sqldata_TEXT = ' File Location = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_File_NAME + ', Query TEXT = ' + @Ls_Query_TEXT;
   
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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   BEGIN TRANSACTION OUTGOING_TMOBILE;

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_UserBatch_IDNO,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');

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

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractTmobile_P1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE ##ExtractTmobile_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   COMMIT TRANSACTION OUTGOING_TMOBILE;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_TMOBILE;
    END;

   IF OBJECT_ID('tempdb..##ExtractTmobile_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractTmobile_P1;
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
    @Ac_Worker_ID                 = @Lc_UserBatch_IDNO,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
