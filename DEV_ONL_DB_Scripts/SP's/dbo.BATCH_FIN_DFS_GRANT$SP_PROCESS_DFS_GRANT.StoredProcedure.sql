/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DFS_GRANT$SP_PROCESS_DFS_GRANT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_DFS_GRANT$SP_PROCESS_DFS_GRANT
Programmer Name   :	Imp Team
Description       :	The procedure BATCH_FIN_DFS_GRANT$SP_PROCESS_DFS_GRANT
Frequency         :	This process reads the data from the temporary table and updates the Monthly Grant Modification
					IVEGRANT (IVMG_Y1) table.
Developed On      :	11/30/2011
Called BY         :	None
Called On		  :	BATCH_COMMON$SP_GET_BATCH_DETAILS,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DFS_GRANT$SP_PROCESS_DFS_GRANT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Ln_CpMci_IDNO                               NUMERIC(10) = 999998,
           @Li_AssessGrantOnFosterCareMembers2760_NUMB  INT = 2760,
           @Lc_StatusFailed_CODE                        CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE                       CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE                   CHAR(1) = 'A',
           @Lc_IndNote_TEXT                             CHAR(1) = 'N',
           @Lc_TypeErrorE_CODE                          CHAR(1) = 'E',
           @Lc_ProcessY_INDC                            CHAR(1) = 'Y',
           @Lc_ProcessN_INDC                            CHAR(1) = 'N',
           @Lc_WelfareEligFc_CODE                       CHAR(1) = 'F',
           @Lc_FirstDateofMonth_CODE					CHAR(2) = '01',
           @Lc_BatchRunUser_TEXT                        CHAR(5) = 'BATCH',
           @Lc_ErrorE0085_CODE                          CHAR(5) = 'E0085',
           @Lc_ErrorE0928_CODE                          CHAR(5) = 'E0928',
           @Lc_ErrorE0102_CODE                          CHAR(5) = 'E0102',
           @Lc_ErrorE0043_CODE                          CHAR(5) = 'E0043',
           @Lc_ErrorE0869_CODE                          CHAR(5) = 'E0869',
           @Lc_ErrorE0004_CODE                          CHAR(5) = 'E0004',
           @Lc_ErrorE0944_CODE                          CHAR(5) = 'E0944',
           @Lc_Job_ID                                   CHAR(7) = 'DEB6040',
           @Lc_Successful_TEXT                          CHAR(20) = 'SUCCESSFUL',
           @Lc_Err0002_TEXT                             CHAR(30) = 'UPDATE NOT SUCCESSFUL',
           @Ls_ParmDateProblem_TEXT                     VARCHAR(50) = 'PARM DATE PROBLEM',
           @Ls_Process_NAME                             VARCHAR(100) = 'BATCH_FIN_DFS_GRANT',
           @Ls_Procedure_NAME                           VARCHAR(100) = 'SP_PROCESS_DFS_GRANT',
           @Ld_High_DATE                                DATE = '12/31/9999';
  DECLARE  @Ln_CommitFreq_QNTY               NUMERIC(5) = 0,
           @Ln_CommitFreqParm_QNTY           NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY       NUMERIC(5) = 0,
           @Ln_ExceptionThresholdParm_QNTY   NUMERIC(5) = 0,
           @Ln_Zero_NUMB                     NUMERIC(5) = 0,
           @Ln_RestartLine_NUMB              NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY     NUMERIC(6) = 0,
           @Ln_SelectedWelfareYyyymm_NUMB    NUMERIC(6) = 0,
           @Ln_ProcessedRecordsCommit_QNTY   NUMERIC(6) = 0,
           @Ln_CurrentWelfare_NUMB           NUMERIC(6) = 0,
           @Ln_RunDateWelfare_NUMB           NUMERIC(6) = 0,
           @Ln_PrevWelfare_NUMB              NUMERIC(6) = 0,
           @Ln_RecCount_NUMB                 NUMERIC(10) = 0,
           @Ln_Error_NUMB                    NUMERIC(11) = 0,
           @Ln_ErrorLine_NUMB                NUMERIC(11) = 0,
           @Ln_MtdAssistExpend_AMNT          NUMERIC(11,2) = 0,
           @Ln_LtdAssistExpend_AMNT          NUMERIC(11,2) = 0,
           @Ln_TransactionAssistRecoup_AMNT  NUMERIC(11,2) = 0,
           @Ln_MtdAssistRecoup_AMNT          NUMERIC(11,2) = 0,
           @Ln_LtdAssistRecoup_AMNT          NUMERIC(11,2) = 0,
           @Ln_EventGlobalSeq_NUMB           NUMERIC(18) = 0,
           @Li_FetchStatus_NUMB              SMALLINT,
           @Li_RowCount_NUMB                 SMALLINT,
           @Lc_Msg_CODE                      CHAR(1) = '',
           @Lc_Space_TEXT                    CHAR(1) = '',
           @Lc_TypeAdjust_CODE               CHAR(1) = '',
           @Lc_AdjustLtdFlag_INDC            CHAR(1) = '',
           @Lc_ZeroGrant_INDC                CHAR(1) = '',
           @Lc_BateError_CODE                CHAR(5) = '',
           @Ls_CursorLocation_TEXT           VARCHAR(200) = '',
           @Ls_Sql_TEXT                      VARCHAR(2000) = '',
           @Ls_ErrorMessage_TEXT             VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT         VARCHAR(4000) = '',
           @Ls_BateRecord_TEXT               VARCHAR(4000) = '',
           @Ls_Sqldata_TEXT                  VARCHAR(5000) = '',
           @Ld_Run_DATE                      DATE,
           @Ld_LastRun_DATE                  DATE,
           @Ld_MonthAdjust_DATE              DATE,
           @Ld_Start_DATE                    DATETIME2;

  DECLARE DfsGrant_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.Rec_ID,
          a.ChildMci_IDNO,
          a.ChildPid_IDNO,
          a.ChidSsn_NUMB,
          a.GrantYearMonth_NUMB,
          a.Grant_AMNT,
          a.FileLoad_DATE,
          a.Process_INDC
     FROM LFGRA_Y1 a
    WHERE a.Process_INDC = @Lc_ProcessN_INDC;
  
  DECLARE @Ln_DfsGrantCur_Seq_IDNO                NUMERIC(19),
          @Lc_DfsGrantCur_Rec_ID                  CHAR(1),
          @Lc_DfsGrantCur_ChildMciIdno_TEXT       CHAR(10),
          @Lc_DfsGrantCur_ChildPid_IDNO           CHAR(10),
          @Lc_DfsGrantCur_ChidSsn_NUMB            CHAR(9),
          @Lc_DfsGrantCur_GrantYearMonthNumb_TEXT CHAR(6),
          @Lc_DfsGrantCur_GrantAmnt_TEXT          CHAR(12),
          @Ld_DfsGrantCur_FileLoad_DATE           DATE,
          @Lc_DfsGrantCur_Process_INDC            CHAR(1);
  DECLARE @Lc_DfsMonthlyCur_ChildIveCaseIdno_TEXT CHAR(10),
          @Lc_DfsMonthlyCur_WfYearMonthNumb_TEXT  CHAR(6),
          @Lc_DfsMonthlyCur_DfsGrantAmnt_TEXT     CHAR(11);
  
  DECLARE @Ln_DfsGrantCurChildMci_IDNO NUMERIC(10),
          @Ln_DfsGrantCurGrant_AMNT    NUMERIC(9, 2);
  DECLARE @Ln_DfsMonthlyCurChildIveCase_IDNO NUMERIC(10),
          @Ln_DfsMonthlyCurWfYearMonth_NUMB  NUMERIC(6),
          @Ln_DfsMonthlyCurDfsGrant_AMNT     NUMERIC(9, 2);  

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION DFSGRANT_PROCESS;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ln_RunDateWelfare_NUMB =  CONVERT(VARCHAR(6), @Ld_Run_DATE, 112); 
   
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   SELECT @Ln_RestartLine_NUMB = CAST(RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Lc_Job_ID
      AND r.Run_DATE = @Ld_Run_DATE;

   SET @Li_RowCount_NUMB = @@ROWCOUNT;

   IF @Li_RowCount_NUMB = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', NO_LINE = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   CREATE TABLE #LoadFcGrant_P1
    (
      [Seq_IDNO]            [NUMERIC](19, 0) NOT NULL,
      [Rec_ID]              [CHAR](1) NOT NULL,
      [ChildMci_IDNO]       [CHAR](10) NOT NULL,
      [ChildPid_IDNO]       [CHAR](10) NOT NULL,
      [ChidSsn_NUMB]        [CHAR](11) NOT NULL,
      [GrantYearMonth_NUMB] [CHAR](6) NOT NULL,
      [Grant_AMNT]          [CHAR](12) NOT NULL,
      [FileLoad_DATE]       [DATE] NOT NULL,
      [Process_INDC]        [CHAR](1) NOT NULL,
      [IveCase_IDNO]        [NUMERIC] (10) NOT NULL
    );

   SET @Ls_Sql_TEXT = 'OPEN DfsGrant_CUR';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   OPEN DfsGrant_CUR;

   SET @Ls_Sql_TEXT = 'FETCH DfsGrant_CUR';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   FETCH NEXT FROM DfsGrant_CUR INTO @Ln_DfsGrantCur_Seq_IDNO, @Lc_DfsGrantCur_Rec_ID, @Lc_DfsGrantCur_ChildMciIdno_TEXT, @Lc_DfsGrantCur_ChildPid_IDNO, @Lc_DfsGrantCur_ChidSsn_NUMB, @Lc_DfsGrantCur_GrantYearMonthNumb_TEXT, @Lc_DfsGrantCur_GrantAmnt_TEXT, @Ld_DfsGrantCur_FileLoad_DATE, @Lc_DfsGrantCur_Process_INDC;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   IF @Li_FetchStatus_NUMB <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   --Cursor , records will processed one by one.
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVEDFSGRANT_PROCESS;

      SET @Lc_BateError_CODE = @Lc_Space_TEXT;
      SET @Ln_RecCount_NUMB = @Ln_RecCount_NUMB + 1;
      SET @Ls_CursorLocation_TEXT = 'DFS Grant - CURSOR COUNT - ' + CAST(@Ln_RecCount_NUMB AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Child Mci = ' + @Lc_DfsGrantCur_ChildMciIdno_TEXT;
      SET @Ls_BateRecord_TEXT = 'Sequence Number = ' + CAST(@Ln_DfsGrantCur_Seq_IDNO AS VARCHAR) + ', Record Id = ' + @Lc_DfsGrantCur_Rec_ID + ', Child MCI Numeber = ' + @Lc_DfsGrantCur_ChildMciIdno_TEXT + ', Child PID Number = ' + @Lc_DfsGrantCur_ChildPid_IDNO + ', Child SSN Number = ' + @Lc_DfsGrantCur_ChidSsn_NUMB + ', Grant Year Month = ' + @Lc_DfsGrantCur_GrantYearMonthNumb_TEXT + ', Grant Amount = ' + @Lc_DfsGrantCur_GrantAmnt_TEXT;

      IF LTRIM(RTRIM(@Lc_DfsGrantCur_ChildMciIdno_TEXT)) = @Lc_Space_TEXT
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0102_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE IF LTRIM(RTRIM(@Lc_DfsGrantCur_GrantYearMonthNumb_TEXT)) = @Lc_Space_TEXT
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0043_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE IF ISNUMERIC(@Lc_DfsGrantCur_GrantAmnt_TEXT) = 1
       BEGIN
        SET @Ln_DfsGrantCurGrant_AMNT = CAST(@Lc_DfsGrantCur_GrantAmnt_TEXT AS MONEY);

        IF @Ln_DfsGrantCurGrant_AMNT <= 0
         BEGIN
          SET @Lc_BateError_CODE = @Lc_ErrorE0869_CODE;

          RAISERROR (50001,16,1);
         END
        ELSE IF SUBSTRING(@Lc_DfsGrantCur_GrantAmnt_TEXT, LEN(@Lc_DfsGrantCur_GrantAmnt_TEXT) - 2, 1) <> '.'
         BEGIN
          SET @Lc_BateError_CODE = @Lc_ErrorE0004_CODE;

          RAISERROR (50001,16,1);
         END
       END

      IF ISNUMERIC(@Lc_DfsGrantCur_ChildMciIdno_TEXT) = 0
          OR ISNUMERIC(@Lc_DfsGrantCur_GrantYearMonthNumb_TEXT) = 0
          OR ISNUMERIC(@Lc_DfsGrantCur_GrantAmnt_TEXT) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_DfsGrantCurChildMci_IDNO = CAST (@Lc_DfsGrantCur_ChildMciIdno_TEXT AS NUMERIC);
       END

      IF NOT EXISTS ((SELECT 1
                        FROM MHIS_Y1 m
                       WHERE m.MEMBERMCI_IDNO = @Ln_DfsGrantCurChildMci_IDNO
                         AND m.CaseWelfare_IDNO <> 0
                         AND m.TypeWelfare_CODE = @Lc_WelfareEligFc_CODE
                         AND @Lc_DfsGrantCur_GrantYearMonthNumb_TEXT BETWEEN CONVERT(VARCHAR(6), m.Start_DATE, 112) AND CONVERT(VARCHAR(6), m.End_DATE, 112)))
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0928_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT INTO #LoadFcGrant_P1';
        SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST( @Ln_DfsGrantCur_Seq_IDNO AS VARCHAR ),'')+ ', Rec_ID = ' + ISNULL(@Lc_DfsGrantCur_Rec_ID,'')+ ', ChildMci_IDNO = ' + ISNULL(@Lc_DfsGrantCur_ChildMciIdno_TEXT,'')+ ', ChildPid_IDNO = ' + ISNULL(@Lc_DfsGrantCur_ChildPid_IDNO,'')+ ', ChidSsn_NUMB = ' + ISNULL(@Lc_DfsGrantCur_ChidSsn_NUMB,'')+ ', GrantYearMonth_NUMB = ' + ISNULL(@Lc_DfsGrantCur_GrantYearMonthNumb_TEXT,'')+ ', Grant_AMNT = ' + ISNULL(@Lc_DfsGrantCur_GrantAmnt_TEXT,'')+ ', FileLoad_DATE = ' + ISNULL(CAST( @Ld_DfsGrantCur_FileLoad_DATE AS VARCHAR ),'')+ ', Process_INDC = ' + ISNULL(@Lc_DfsGrantCur_Process_INDC,'');

        INSERT #LoadFcGrant_P1
               (Seq_IDNO,
                Rec_ID,
                ChildMci_IDNO,
                ChildPid_IDNO,
                ChidSsn_NUMB,
                GrantYearMonth_NUMB,
                Grant_AMNT,
                FileLoad_DATE,
                Process_INDC,
                IveCase_IDNO)
        VALUES (@Ln_DfsGrantCur_Seq_IDNO,--Seq_IDNO
                @Lc_DfsGrantCur_Rec_ID,--Rec_ID
                @Lc_DfsGrantCur_ChildMciIdno_TEXT,--ChildMci_IDNO
                @Lc_DfsGrantCur_ChildPid_IDNO,--ChildPid_IDNO
                @Lc_DfsGrantCur_ChidSsn_NUMB,--ChidSsn_NUMB
                @Lc_DfsGrantCur_GrantYearMonthNumb_TEXT,--GrantYearMonth_NUMB
                @Lc_DfsGrantCur_GrantAmnt_TEXT,--Grant_AMNT
                @Ld_DfsGrantCur_FileLoad_DATE,--FileLoad_DATE
                @Lc_DfsGrantCur_Process_INDC,--Process_INDC
                (SELECT DISTINCT TOP 1 
                        m.CaseWelfare_IDNO
                   FROM MHIS_Y1 m
                  WHERE m.MEMBERMCI_IDNO = @Ln_DfsGrantCurChildMci_IDNO
                    AND m.CaseWelfare_IDNO <> 0
                    AND m.TypeWelfare_CODE = @Lc_WelfareEligFc_CODE
                    AND @Lc_DfsGrantCur_GrantYearMonthNumb_TEXT BETWEEN CONVERT(VARCHAR(6), m.Start_DATE, 112) AND CONVERT(VARCHAR(6), m.End_DATE, 112)) --IveCase_IDNO	
        );

        SET @Li_RowCount_NUMB = @@ROWCOUNT;

        IF @Li_RowCount_NUMB = 0
         BEGIN
          SET @Ls_Sql_TEXT = 'Record not inserted into #LoadFcGrant_P1 of Seq_IDNO = ' + CAST(@Ln_DfsGrantCur_Seq_IDNO AS VARCHAR);
          SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

          RAISERROR (50001,16,1);
         END
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF @@TRANCOUNT > 0
        BEGIN
         ROLLBACK TRANSACTION SAVEDFSGRANT_PROCESS;
        END

       SET @Ln_Error_NUMB = ERROR_NUMBER ();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
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

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
       SET @Ls_Sqldata_TEXT = ' Child MCI = ' + @Lc_DfsGrantCur_ChildMciIdno_TEXT;
       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
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

       SET @Ls_Sql_TEXT = 'UPDATE LFGRA_Y1';
       SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_DfsGrantCur_Seq_IDNO AS VARCHAR);

       UPDATE LFGRA_Y1
          SET Process_INDC = @Lc_ProcessY_INDC
        WHERE Seq_IDNO = @Ln_DfsGrantCur_Seq_IDNO;

       SET @Li_RowCount_NUMB = @@ROWCOUNT;

       IF @Li_RowCount_NUMB = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

         RAISERROR (50001,16,1);
        END

       SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowCount_NUMB;
      END
     END CATCH

     SET @Ls_Sql_TEXT = 'FETCH NEXT RECORD FROM CURSOR';
     SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

     FETCH NEXT FROM DfsGrant_CUR INTO @Ln_DfsGrantCur_Seq_IDNO, @Lc_DfsGrantCur_Rec_ID, @Lc_DfsGrantCur_ChildMciIdno_TEXT, @Lc_DfsGrantCur_ChildPid_IDNO, @Lc_DfsGrantCur_ChidSsn_NUMB, @Lc_DfsGrantCur_GrantYearMonthNumb_TEXT, @Lc_DfsGrantCur_GrantAmnt_TEXT, @Ld_DfsGrantCur_FileLoad_DATE, @Lc_DfsGrantCur_Process_INDC;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE,'')+ ', Line_NUMB = ' + ISNULL(CAST( @Ln_RestartLine_NUMB AS VARCHAR ),'')+ ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'');
     
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   CLOSE DfsGrant_CUR;

   DEALLOCATE DfsGrant_CUR;

   SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;

   DECLARE DfsMonthly_CUR INSENSITIVE CURSOR FOR
    SELECT IveCase_IDNO,
           GrantYearMonth_NUMB,
           SUM(CAST(Grant_AMNT AS MONEY)) AS TotalGrant_AMNT
      FROM #LoadFcGrant_P1 a
     WHERE Process_INDC = @Lc_ProcessN_INDC 
     GROUP BY IveCase_IDNO,
              GrantYearMonth_NUMB
	 ORDER BY IveCase_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN DfsMonthly_CUR';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   OPEN DfsMonthly_CUR;

   SET @Ls_Sql_TEXT = 'FETCH DfsMonthly_CUR - 1';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   FETCH NEXT FROM DfsMonthly_CUR INTO @Lc_DfsMonthlyCur_ChildIveCaseIdno_TEXT, @Lc_DfsMonthlyCur_WfYearMonthNumb_TEXT, @Lc_DfsMonthlyCur_DfsGrantAmnt_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Cursor
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVEDFSMONTHLYPROCESS;
      SET @Ls_BateRecord_TEXT = 'Child IV E Case Idno = ' + @Lc_DfsMonthlyCur_ChildIveCaseIdno_TEXT + ', Welfare YearMonth = ' + @Lc_DfsMonthlyCur_WfYearMonthNumb_TEXT + ', Dfs Grant Amount = ' + @Lc_DfsMonthlyCur_DfsGrantAmnt_TEXT;

      IF ISNUMERIC(@Lc_DfsMonthlyCur_ChildIveCaseIdno_TEXT) = 0
          OR ISNUMERIC(@Lc_DfsMonthlyCur_WfYearMonthNumb_TEXT) = 0
          OR ISNUMERIC(@Lc_DfsMonthlyCur_DfsGrantAmnt_TEXT) = 0
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

        RAISERROR (50001,16,1);
       END
      ELSE
       BEGIN
        SET @Ln_DfsMonthlyCurChildIveCase_IDNO = CAST(@Lc_DfsMonthlyCur_ChildIveCaseIdno_TEXT AS NUMERIC);
        SET @Ln_DfsMonthlyCurWfYearMonth_NUMB = CAST(@Lc_DfsMonthlyCur_WfYearMonthNumb_TEXT AS NUMERIC);
        SET @Ln_DfsMonthlyCurDfsGrant_AMNT = CAST(@Lc_DfsMonthlyCur_DfsGrantAmnt_TEXT AS NUMERIC);
       END
	
	  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
	  SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @Li_AssessGrantOnFosterCareMembers2760_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'');

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_AssessGrantOnFosterCareMembers2760_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_IndNote_TEXT,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'ASSIGN CURRENT GRANT WELFARE YEAR MONTH';
      SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_DfsMonthlyCurChildIveCase_IDNO AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareEligFc_CODE,'');
      
      SELECT @Ln_CurrentWelfare_NUMB = ISNULL(MAX(a.WelfareYearMonth_NUMB), @Ln_RunDateWelfare_NUMB)
        FROM IVMG_Y1 a
       WHERE a.CaseWelfare_IDNO = @Ln_DfsMonthlyCurChildIveCase_IDNO
         AND a.WelfareElig_CODE = @Lc_WelfareEligFc_CODE
         AND a.WelfareYearMonth_NUMB >= @Ln_DfsMonthlyCurWfYearMonth_NUMB;

      SET @Ln_PrevWelfare_NUMB = @Ln_DfsMonthlyCurWfYearMonth_NUMB;

      -- Inserts into IVMG_Y1 till current Yearmonth
      WHILE @Ln_PrevWelfare_NUMB <= @Ln_CurrentWelfare_NUMB
       BEGIN
        SET @Ln_MtdAssistExpend_AMNT = @Ln_Zero_NUMB;
        SET @Ln_LtdAssistExpend_AMNT = @Ln_Zero_NUMB;
        SET @Ln_TransactionAssistRecoup_AMNT = @Ln_Zero_NUMB;
        SET @Ln_MtdAssistRecoup_AMNT = @Ln_Zero_NUMB;
        SET @Ln_LtdAssistRecoup_AMNT = @Ln_Zero_NUMB;
        
        SET @Ls_Sql_TEXT = 'ASSIGNING CURRENT VALUES OF THAT MONTH YEAR ';
        SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_DfsMonthlyCurChildIveCase_IDNO AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareEligFc_CODE,'');

        SELECT @Ln_SelectedWelfareYyyymm_NUMB = a.WelfareYearMonth_NUMB,
               @Ln_MtdAssistExpend_AMNT = a.MtdAssistExpend_AMNT,
               @Ln_LtdAssistExpend_AMNT = a.LtdAssistExpend_AMNT,
               @Ln_TransactionAssistRecoup_AMNT = a.TransactionAssistRecoup_AMNT,
               @Ln_LtdAssistRecoup_AMNT = a.LtdAssistRecoup_AMNT,
               @Ln_MtdAssistRecoup_AMNT = a.MtdAssistRecoup_AMNT,
               @Lc_TypeAdjust_CODE = a.TypeAdjust_CODE,
               @Lc_ZeroGrant_INDC = a.ZeroGrant_INDC,
               @Lc_AdjustLtdFlag_INDC = a.AdjustLtdFlag_INDC
          FROM IVMG_Y1 a
         WHERE a.CaseWelfare_IDNO = @Ln_DfsMonthlyCurChildIveCase_IDNO
           AND a.WelfareElig_CODE = @Lc_WelfareEligFc_CODE
           AND a.WelfareYearMonth_NUMB = (SELECT MAX(c.WelfareYearMonth_NUMB)
                                            FROM IVMG_Y1 c
                                           WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                             AND c.WelfareElig_CODE = a.WelfareElig_CODE
                                             AND c.WelfareYearMonth_NUMB <= @Ln_PrevWelfare_NUMB)
           AND a.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                          FROM IVMG_Y1 b
                                         WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                           AND b.WelfareElig_CODE = a.WelfareElig_CODE
                                           AND b.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

        SET @Ls_Sql_TEXT = 'INSERT INTO IVMG_Y1';
        SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + ISNULL(CAST( @Ln_DfsMonthlyCurChildIveCase_IDNO AS VARCHAR ),'')+ ', WelfareYearMonth_NUMB = ' + ISNULL(CAST( @Ln_PrevWelfare_NUMB AS VARCHAR ),'')+ ', WelfareElig_CODE = ' + ISNULL(@Lc_WelfareEligFc_CODE,'')+ ', TransactionAssistExpend_AMNT = ' + ISNULL(CAST( @Ln_DfsMonthlyCurDfsGrant_AMNT AS VARCHAR ),'')+ ', TransactionAssistRecoup_AMNT = ' + ISNULL(CAST( @Ln_TransactionAssistRecoup_AMNT AS VARCHAR ),'')+ ', MtdAssistRecoup_AMNT = ' + ISNULL(CAST( @Ln_MtdAssistRecoup_AMNT AS VARCHAR ),'')+ ', LtdAssistRecoup_AMNT = ' + ISNULL(CAST( @Ln_LtdAssistRecoup_AMNT AS VARCHAR ),'')+ ', TypeAdjust_CODE = ' + ISNULL(@Lc_TypeAdjust_CODE,'')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @Ln_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', ZeroGrant_INDC = ' + ISNULL(@Lc_ZeroGrant_INDC,'')+ ', AdjustLtdFlag_INDC = ' + ISNULL(@Lc_AdjustLtdFlag_INDC,'')+ ', Defra_AMNT = ' + ISNULL(CAST( @Ln_Zero_NUMB AS VARCHAR ),'')+ ', CpMci_IDNO = ' + ISNULL(CAST( @Ln_CpMci_IDNO AS VARCHAR ),'');

        INSERT IVMG_Y1
               (CaseWelfare_IDNO,
                WelfareYearMonth_NUMB,
                WelfareElig_CODE,
                TransactionAssistExpend_AMNT,
                MtdAssistExpend_AMNT,
                LtdAssistExpend_AMNT,
                TransactionAssistRecoup_AMNT,
                MtdAssistRecoup_AMNT,
                LtdAssistRecoup_AMNT,
                TypeAdjust_CODE,
                EventGlobalSeq_NUMB,
                ZeroGrant_INDC,
                AdjustLtdFlag_INDC,
                Defra_AMNT,
                CpMci_IDNO)
        VALUES( @Ln_DfsMonthlyCurChildIveCase_IDNO,--CaseWelfare_IDNO
                @Ln_PrevWelfare_NUMB,--WelfareYearMonth_NUMB
                @Lc_WelfareEligFc_CODE,--WelfareElig_CODE
                @Ln_DfsMonthlyCurDfsGrant_AMNT,--TransactionAssistExpend_AMNT
                CASE @Ln_PrevWelfare_NUMB
                 WHEN @Ln_DfsMonthlyCurWfYearMonth_NUMB
                  THEN @Ln_MtdAssistExpend_AMNT + @Ln_DfsMonthlyCurDfsGrant_AMNT
                 WHEN @Ln_SelectedWelfareYyyymm_NUMB
                  THEN @Ln_MtdAssistExpend_AMNT
                 ELSE @Ln_Zero_NUMB
                END,--MtdAssistExpend_AMNT
                CASE @Ln_PrevWelfare_NUMB
                 WHEN @Ln_SelectedWelfareYyyymm_NUMB
                  THEN @Ln_LtdAssistExpend_AMNT + @Ln_DfsMonthlyCurDfsGrant_AMNT
                 ELSE @Ln_DfsMonthlyCurDfsGrant_AMNT
                END,--LtdAssistExpend_AMNT
                @Ln_TransactionAssistRecoup_AMNT,--TransactionAssistRecoup_AMNT
                @Ln_MtdAssistRecoup_AMNT,--MtdAssistRecoup_AMNT
                @Ln_LtdAssistRecoup_AMNT,--LtdAssistRecoup_AMNT
                @Lc_TypeAdjust_CODE,--TypeAdjust_CODE
                @Ln_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
                @Lc_ZeroGrant_INDC,--ZeroGrant_INDC
                @Lc_AdjustLtdFlag_INDC,--AdjustLtdFlag_INDC 
                @Ln_Zero_NUMB,--Defra_AMNT
                @Ln_CpMci_IDNO --CpMci_IDNO
        );

        SET @Li_RowCount_NUMB = @@ROWCOUNT;

        IF @Li_RowCount_NUMB = 0
         BEGIN
          SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

          RAISERROR (50001,16,1);
         END

        SET @Ld_MonthAdjust_DATE = DATEADD(m, 1,CAST((CAST(@Ln_PrevWelfare_NUMB AS VARCHAR) + @Lc_FirstDateofMonth_CODE)  AS DATE));
        SET @Ln_PrevWelfare_NUMB =  CONVERT(VARCHAR(6), @Ld_MonthAdjust_DATE, 112); 
        
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF @@TRANCOUNT > 0
        BEGIN
         ROLLBACK TRANSACTION SAVEDFSMONTHLYPROCESS;
        END

       SET @Ln_Error_NUMB = ERROR_NUMBER ();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
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

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 3';
       SET @Ls_Sqldata_TEXT = 'Child SSN = ' + @Lc_DfsGrantCur_ChildMciIdno_TEXT;
       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
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
       
      END

     END CATCH

     SET @Ls_Sql_TEXT = 'Updating Process Indicator to "Y" for record in #LoadFcGrant_P1';
     SET @Ls_Sqldata_TEXT = 'IveCase_IDNO = ' + ISNULL(CAST( @Ln_DfsMonthlyCurChildIveCase_IDNO AS VARCHAR ),'')+ ', GrantYearMonth_NUMB = ' + ISNULL(CAST( @Ln_DfsMonthlyCurWfYearMonth_NUMB AS VARCHAR ),'');

     UPDATE #LoadFcGrant_P1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE IveCase_IDNO = @Ln_DfsMonthlyCurChildIveCase_IDNO
        AND GrantYearMonth_NUMB = @Ln_DfsMonthlyCurWfYearMonth_NUMB;

     SET @Ls_Sql_TEXT = 'UPDATE LFGRA_Y1';
     SET @Ls_Sqldata_TEXT = 'Process_INDC = ' + ISNULL(@Lc_ProcessY_INDC,'')+ ', IveCase_IDNO = ' + ISNULL(CAST( @Ln_DfsMonthlyCurChildIveCase_IDNO AS VARCHAR ),'')+ ', GrantYearMonth_NUMB = ' + ISNULL(CAST( @Ln_DfsMonthlyCurWfYearMonth_NUMB AS VARCHAR ),'');

     UPDATE LFGRA_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO IN (SELECT Seq_IDNO
                           FROM #LoadFcGrant_P1 a
                          WHERE Process_INDC = @Lc_ProcessY_INDC
                            AND IveCase_IDNO = @Ln_DfsMonthlyCurChildIveCase_IDNO
                            AND GrantYearMonth_NUMB = @Ln_DfsMonthlyCurWfYearMonth_NUMB);

     SET @Li_RowCount_NUMB = @@ROWCOUNT;

     IF @Li_RowCount_NUMB = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Li_RowCount_NUMB;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Li_RowCount_NUMB;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', RESTART_KEY = ' + ISNULL (CAST (@Ln_RecCount_NUMB AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecCount_NUMB,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
       SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       COMMIT TRANSACTION DFSGRANT_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       BEGIN TRANSACTION DFSGRANT_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;
       COMMIT TRANSACTION DFSGRANT_PROCESS;
       
       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
	   
       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM DfsMonthly_CUR INTO @Lc_DfsMonthlyCur_ChildIveCaseIdno_TEXT, @Lc_DfsMonthlyCur_WfYearMonthNumb_TEXT, @Lc_DfsMonthlyCur_DfsGrantAmnt_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END

   CLOSE DfsMonthly_CUR;

   DEALLOCATE DfsMonthly_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST( @Ld_Run_DATE AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ld_Start_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Lc_Job_ID,'')+ ', Process_NAME = ' + ISNULL(@Ls_Process_NAME,'')+ ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME,'')+ ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT,'')+ ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT,'')+ ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT,'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE,'')+ ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT,'')+ ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST( @Ln_ProcessedRecordCount_QNTY AS VARCHAR ),'');
   
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TEMPORARY TABLE';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE #LoadFcGrant_P1;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION DFSGRANT_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DFSGRANT_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'DfsGrant_CUR') IN (0, 1)
    BEGIN
     CLOSE DfsGrant_CUR;

     DEALLOCATE DfsGrant_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'DfsMonthly_CUR') IN (0, 1)
    BEGIN
     CLOSE DfsMonthly_CUR;

     DEALLOCATE DfsMonthly_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
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
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
