/****** Object:  StoredProcedure [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_RESOLVED_PETITION_NO_PAT_GUIDE_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_PATERNITY_REPORTS$SP_LOAD_RESOLVED_PETITION_NO_PAT_GUIDE_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get all the dependents and their cases where a paternity guide was not printed for the particular month.
Frequency		:	
Developed On	:	4/27/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_RESOLVED_PETITION_NO_PAT_GUIDE_REPORT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB              INT = 0,
          @Li_RowCount_QNTY          INT = 0,
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_CaseRelationshipD_CODE CHAR(1) = 'D',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_StatusEstablishT_CODE  CHAR(1) = 'T',
          @Lc_StatusFailedF_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccessS_CODE    CHAR(1) = 'S',
          @Lc_CaseMemberStatusA_CODE CHAR(1) = 'A',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_ReasonStatusCI_CODE    CHAR(2) = 'CI',
          @Lc_ReasonStatusRP_CODE    CHAR(2) = 'RP',
          @Lc_StatusCOMP_CODE        CHAR(4) = 'COMP',
          @Lc_ActivityMajorESTP_CODE CHAR(4) = 'ESTP',
          @Lc_ActivityMajorMAPP_CODE CHAR(4) = 'MAPP',
          @Lc_ActivityMajorROFO_CODE CHAR(4) = 'ROFO',
          @Lc_BateError_CODE         CHAR(5) = 'E0944',
          @Lc_DateFormatYyyymm_CODE  CHAR(6) = 'YYYYMM',
          @Lc_Job_ID                 CHAR(7) = 'DEB0023',
          @Lc_Notice_ID              CHAR(8) = 'CSM-17',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT      CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_RESOLVED_PETITION_NO_PAT_GUIDE_REPORT',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_BI_PATERNITY_REPORTS';
  DECLARE @Ln_CommitFreq_QNTY             NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_RunDate_NUMB                NUMERIC(6, 0),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Lc_Msg_CODE                    CHAR(5),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_Sqldata_TEXT                VARCHAR(200),
          @Ls_ErrorMessage_TEXT           VARCHAR(2000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreq_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailedF_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   BEGIN TRANSACTION NOPATGUIDE_LOAD;

   SET @Ls_Sql_TEXT = 'DELETE BRPPG_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BRPPG_Y1;

   SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE, @Lc_DateFormatYyyymm_CODE) AS NUMERIC);
   SET @Ls_Sql_TEXT = 'INSERT INTO BRPPG_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Generate_DATE = ' + ISNULL(CAST(@Ln_RunDate_NUMB AS VARCHAR), '');

   INSERT INTO BRPPG_Y1
               (Case_IDNO,
                ChildMemberMci_IDNO,
                County_IDNO,
                ResponsibleWorker_ID,
                PaternityUpdatedWorker_ID,
                Updated_DATE,
                Resolved_DATE,
                Generate_DATE,
                TransactionEventSeq_NUMB)
   SELECT a.Case_IDNO,
          a.ChildMemberMci_IDNO,
          a.county_idno,
          a.Worker_ID,
          a.WorkerUpdate_ID,
          a.update_dttm,
          a.Resolved_DATE,
          a.Generate_DATE,
          a.TransactionEventSeq_NUMB
     FROM(SELECT a.Case_IDNO,
                 a.MemberMci_IDNO AS ChildMemberMci_IDNO,
                 b.county_idno,
                 b.Worker_ID,
                 m.WorkerUpdate_ID,
                 m.update_dttm,
                 d.Status_DATE Resolved_DATE,
                 @Ld_Run_DATE AS Generate_DATE,
                 a.TransactionEventSeq_NUMB,
                 ROW_NUMBER() OVER(PARTITION BY a.MemberMci_IDNO ORDER BY a.TransactionEventSeq_NUMB DESC) Row_NUMB
            FROM CMEM_Y1 a,
                 CASE_Y1 b,
                 DEMO_Y1 c,
                 (SELECT z.Case_IDNO,
                         MAX(z.Status_DATE) AS Status_DATE
                    FROM (SELECT x.Case_IDNO,
                                 x.Status_DATE
                            FROM DMJR_Y1 x
                           WHERE x.Status_CODE = @Lc_StatusCOMP_CODE
                             AND x.ActivityMajor_CODE IN (@Lc_ActivityMajorESTP_CODE, @Lc_ActivityMajorMAPP_CODE, @Lc_ActivityMajorROFO_CODE)
                             AND CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(x.Status_DATE, @Lc_DateFormatYyyymm_CODE) AS NUMERIC) = @Ln_RunDate_NUMB
                             AND EXISTS (SELECT 1
                                           FROM DMNR_Y1 q
                                          WHERE q.Case_IDNO = x.Case_IDNO
                                            AND q.MajorIntSeq_NUMB = X.MajorIntSeq_NUMB
                                            AND q.ReasonStatus_CODE IN (@Lc_ReasonStatusCI_CODE, @Lc_ReasonStatusRP_CODE))
                             AND NOT EXISTS (SELECT 1
                                               FROM NRRQ_Y1 y
                                              WHERE y.Case_IDNO = x.Case_IDNO
                                                AND y.Notice_ID = @Lc_Notice_ID
                                                AND CAST(y.Generate_DTTM AS DATE) BETWEEN x.Entered_DATE AND x.Status_DATE)) z
                   GROUP BY z.Case_IDNO) d,
                 MPAT_Y1 m
           WHERE a.Case_IDNO = b.Case_IDNO
             AND a.MemberMci_IDNO = m.MemberMci_IDNO
             AND a.MemberMci_IDNO = c.MemberMci_IDNO
             AND m.StatusEstablish_CODE = @Lc_StatusEstablishT_CODE
             AND a.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
             AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
             AND a.Case_IDNO = d.case_idno) a
    WHERE Row_NUMB = 1
    ORDER BY 1;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BRPPG_Y1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Line_NUMB = ' + ISNULL(CAST(@Li_RowCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Li_RowCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailedF_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_BATE_LOG FAILED';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailedF_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';

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
    @Ac_Status_CODE               = @Lc_StatusSuccessS_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   COMMIT TRANSACTION NOPATGUIDE_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION NOPATGUIDE_LOAD;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END; 

GO
