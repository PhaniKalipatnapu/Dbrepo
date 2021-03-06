/****** Object:  StoredProcedure [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_QI_STATUS_PAT_GUIDE_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_PATERNITY_REPORTS$SP_LOAD_QI_STATUS_PAT_GUIDE_REPORT
Programmer Name	:	IMP Team.
Description		:	Procedure to get all the dependents and their cases where paternity guide was printed and qi status as locked for the particular month.
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
CREATE PROCEDURE [dbo].[BATCH_BI_PATERNITY_REPORTS$SP_LOAD_QI_STATUS_PAT_GUIDE_REPORT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB              INT = 0,
          @Li_RowCount_QNTY          INT = 0,
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_TypeError_CODE         CHAR(1) = 'E',
          @Lc_CaseRelationshipD_CODE CHAR(1) = 'D',
          @Lc_QiStatusL_CODE         CHAR(1) = 'L',
          @Lc_Yes_INDC               CHAR(1) = 'Y',
          @Lc_No_INDC                CHAR(1) = 'N',
          @Lc_QiStatusN_CODE         CHAR(1) = 'N',
          @Lc_StatusFailedF_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccessS_CODE    CHAR(1) = 'S',
          @Lc_CaseMemberStatusA_CODE CHAR(1) = 'A',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_ReasonStatusTR_CODE    CHAR(2) = 'TR',
          @Lc_ReasonStatusCG_CODE    CHAR(2) = 'CG',
          @Lc_ReasonStatusTE_CODE    CHAR(2) = 'TE',
          @Lc_ReasonStatusSH_CODE    CHAR(2) = 'SH',
          @Lc_BateError_CODE         CHAR(5) = 'E0944',
          @Lc_DateFormatYyyymm_CODE  CHAR(6) = 'YYYYMM',
          @Lc_Job_ID                 CHAR(7) = 'DEB0024',
          @Lc_Notice_ID              CHAR(8) = 'CSM-17',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT      CHAR(30) = 'BATCH',
          @Lc_StatusComp_CODE        CHAR(4) = 'COMP',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_LOAD_QI_STATUS_PAT_GUIDE_REPORT',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_BI_PATERNITY_REPORTS',
          @Ld_Low_DATE               DATE = '01/01/0001',
          @Ld_Current_DATE           DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
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
   BEGIN TRANSACTION QISTATUS_LOAD;

   SET @Ls_Sql_TEXT = 'DELETE BQPGR_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BQPGR_Y1;

   SET @Ln_RunDate_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ld_Run_DATE, @Lc_DateFormatYyyymm_CODE) AS NUMERIC);
   SET @Ls_Sql_TEXT = 'INSERT INTO BQPGR_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'SchdInfoReceived_DATE = ' + ISNULL(CAST(@Ld_Current_DATE AS VARCHAR), '') + ', Generate_DATE = ' + ISNULL(CAST(@Ln_RunDate_NUMB AS VARCHAR), '');

   INSERT INTO BQPGR_Y1
               (ChildMemberMci_IDNO,
                QIStatus_CODE,
                PatGuideGenerated_INDC,
                ChildBirth_DATE,
                BornOfMarriage_CODE,
                PaternityStatus_CODE,
                Establishment_DATE,
                BirthState_CODE,
                EstablishmentMethod_CODE,
                ChildBirthCertificate_ID,
                SchdInfoReceived_DATE,
                PaternityInfoUpdate_DATE,
                ResponsibleWorker_ID,
                Case_IDNO,
                County_IDNO,
                WorkerUpdate_ID,
                Update_DATE,
                Generate_DATE,
                TransactionEventSeq_NUMB)
   SELECT a.MemberMci_IDNO AS ChildMemberMci_IDNO,
          c.QiStatus_CODE,
          (CASE
            WHEN (SELECT COUNT(1)
                    FROM NRRQ_Y1 y
                   WHERE y.case_idno = a.case_idno
                     AND y.Notice_ID = @Lc_Notice_ID
                     AND CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(y.Generate_DTTM, @Lc_DateFormatYyyymm_CODE) AS NUMERIC) = @Ln_RunDate_NUMB ---prev month?
                 ) > 0
             THEN @Lc_Yes_INDC
            ELSE @Lc_No_INDC
           END) AS PatGuideGenerated_INDC,
          d.Birth_DATE,
          c.BornOfMarriage_CODE,
          c.StatusEstablish_CODE AS PaternityStatus_CODE,
          c.PaternityEst_DATE AS Establishment_DATE,
          d.BirthState_CODE,
          c.PaternityEst_CODE AS EstablishmentMethod_CODE,
          c.BirthCertificate_ID AS ChildBirthCertificate_ID,
          (CASE
            WHEN (SELECT COUNT(1)
                    FROM DMNR_Y1 R
                   WHERE R.CASE_IDNO = A.CASE_IDNO
                     AND STATUS_CODE = @Lc_StatusComp_CODE
                     AND REASONSTATUS_CODE IN (@Lc_ReasonStatusTR_CODE, @Lc_ReasonStatusCG_CODE, @Lc_ReasonStatusTE_CODE, @Lc_ReasonStatusSH_CODE)
                     AND WORKERUPDATE_ID = @Lc_BatchRunUser_TEXT) > 0
             THEN(SELECT TOP 1 STATUS_DATE
                    FROM DMNR_Y1 R
                   WHERE R.CASE_IDNO = A.CASE_IDNO
                     AND STATUS_CODE = @Lc_StatusComp_CODE
                     AND REASONSTATUS_CODE IN (@Lc_ReasonStatusTR_CODE, @Lc_ReasonStatusCG_CODE, @Lc_ReasonStatusTE_CODE, @Lc_ReasonStatusSH_CODE)
                     AND WORKERUPDATE_ID = @Lc_BatchRunUser_TEXT)
            ELSE @Ld_Low_DATE
           END) AS SchdInfoReceived_DATE,
          c.Update_DTTM,
          e.Worker_ID AS ResponsibleWorker_ID,
          a.Case_IDNO,
          e.County_IDNO AS County_IDNO,
          s.WorkerUpdate_ID,
          s.Update_DTTM,
          @Ld_Run_DATE AS Generate_DATE,
          ROW_NUMBER() OVER(ORDER BY a.MemberMci_IDNO) AS TransactionEventSeq_NUMB
     FROM CMEM_Y1 a
          JOIN MPAT_Y1 c -----all dep ll b in mpat?
           ON a.membermci_idno = c.membermci_idno
          JOIN DEMO_Y1 d
           ON a.membermci_idno = d.membermci_idno
          JOIN CASE_Y1 e
           ON e.Case_IDNO = a.Case_IDNO
          LEFT OUTER JOIN(SELECT c.MemberMci_IDNO,
                                 CASE
                                  WHEN c.QiStatus_CODE <> ISNULL(d.QiStatus_CODE, @Lc_Space_TEXT)
                                       AND c.QiStatus_CODE <> @Lc_QiStatusN_CODE
                                   THEN c.WorkerUpdate_ID
                                  WHEN d.QiStatus_CODE <> @Lc_QiStatusN_CODE
                                   THEN d.WorkerUpdate_ID
                                  ELSE @Lc_Space_TEXT
                                 END AS WorkerUpdate_ID,
                                 CASE
                                  WHEN c.QiStatus_CODE <> ISNULL(d.QiStatus_CODE, @Lc_Space_TEXT)
                                       AND c.QiStatus_CODE <> @Lc_QiStatusN_CODE
                                   THEN c.Update_DTTM
                                  WHEN d.QiStatus_CODE <> @Lc_QiStatusN_CODE
                                   THEN d.Update_DTTM
                                  ELSE @Ld_Low_DATE
                                 END AS Update_DTTM
                            FROM MPAT_Y1 c
                                 LEFT OUTER JOIN (SELECT TOP 1 a.MemberMci_IDNO,
                                                               a.QiStatus_CODE,
                                                               a.TransactionEventSeq_NUMB,
                                                               a.WorkerUpdate_ID,
                                                               a.Update_DTTM,
                                                               ROW_NUMBER() OVER(ORDER BY a.TransactionEventSeq_NUMB DESC) AS rownum
                                                    FROM HMPAT_Y1 a,
                                                         HMPAT_Y1 b
                                                   WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                                                     AND a.TransactionEventSeq_NUMB > b.TransactionEventSeq_NUMB
                                                     AND a.QiStatus_CODE <> b.QiStatus_CODE)d
                                  ON c.MemberMci_IDNO = d.MemberMci_IDNO) s
           ON s.MemberMci_IDNO = d.membermci_idno
    WHERE a.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE --active status
      AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
      AND (a.Case_IDNO IN (SELECT y.Case_IDNO
                             FROM NRRQ_Y1 y
                            WHERE y.Notice_ID = @Lc_Notice_ID
                              AND CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(y.Generate_DTTM, @Lc_DateFormatYyyymm_CODE) AS NUMERIC) = @Ln_RunDate_NUMB ---prev month?
                          )
            OR a.MemberMci_IDNO IN (SELECT b.MemberMci_IDNO
                                      FROM MPAT_Y1 b
                                     WHERE b.QiStatus_CODE = @Lc_QiStatusL_CODE));

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BQPGR_Y1';
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

   COMMIT TRANSACTION QISTATUS_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION QISTATUS_LOAD;
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
 END; --BATCH_BI_PATERNITY_REPORTS$SP_LOAD_QI_STATUS_PAT_GUIDE_REPORT


GO
