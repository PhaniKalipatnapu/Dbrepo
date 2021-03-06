/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_TO_IVE$SP_EXTRACT_IVE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_EXT_TO_IVE$SP_EXTRACT_IVE
Programmer Name 	: IMP Team
Description			: This process maps IV-E NCP's to individual children, 
					  determines how much was paid by the NCP in a month for that chilD.
Frequency			: 'MONTHLY' (1st of every month).
Developed On		: 08/22/2011
Called BY			: None
Called On			: BATCH_COMMON$SP_GET_BATCH_DETAILS2 
					  BATCH_COMMON$SP_UPDATE_PARM_DATE
					  BATCH_COMMON$SP_EXTRACT_DATA
					  BATCH_COMMON$SP_BATE_LOG
					  BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------	
Modified BY			:
Modified On			:
Version No			: 0.01
----------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_TO_IVE$SP_EXTRACT_IVE]
AS
 BEGIN
  SET NOCOUNT ON;
  
     DECLARE @Ln_MemberMciCp_IDNO              NUMERIC = 999998,
           @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_TypeErrorWarning_CODE           CHAR(1) = 'W',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
           @Lc_MemberStatusActive_CODE         CHAR(1) = 'A',
           @Lc_CaseRelationshipDependent_CODE  CHAR(1) = 'D',
           @Lc_CaseRelationshipNcp_CODE        CHAR(1) = 'A',
           @Lc_CaseRelationshipPutative_CODE   CHAR(1) = 'P',
           @Lc_CaseRelationshipCp_CODE         CHAR(1) = 'C',
           @Lc_IveCase_CODE                    CHAR(1) = 'F',
           @Lc_NonFederalFosterCare_CODE       CHAR(1) = 'J',
           @Lc_OpenCase_CODE                   CHAR(1) = 'O',
           @Lc_RecordHeader_CODE               CHAR(1) = 'H',
           @Lc_RecordDetail_CODE               CHAR(1) = 'D',
           @Lc_RecordTrailer_CODE              CHAR(1) = 'T',
           @Lc_NcpMother_CODE                  CHAR(3) = 'MTR',
           @Lc_NcpFather_CODE                  CHAR(3) = 'FTR',
           @Lc_DisbursementTypeAgive_CODE      CHAR(5) = 'AGIVE',
           @Lc_DisbursementTypeCgive_CODE      CHAR(5) = 'CGIVE',
           @Lc_DisbursementTypePgive_CODE      CHAR(5) = 'PGIVE',
           @Lc_DisbursementTypeAxive_CODE      CHAR(5) = 'AXIVE',
           @Lc_DisbursementTypeCxive_CODE      CHAR(5) = 'CXIVE',
           @Lc_DisbursementTypeAznfc_CODE      CHAR(5) = 'AZNFC',
           @Lc_DisbursementTypeCznfc_CODE      CHAR(5) = 'CZNFC',
           @Lc_Job_ID                          CHAR(7) = 'DEB6350',
           @Lc_ErrorE0944_CODE                 CHAR(18) = 'E0944',
           @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
           @Lc_UserBatch_IDNO                  CHAR(30) = 'BATCH',
           @Ls_ParmDateProblem_TEXT			   VARCHAR(50) = 'PARM DATE PROBLEM',
           @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_FIN_EXT_TO_IVE',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_EXTRACT_IVE';
           
  DECLARE  @Ln_Zero_NUMB                  NUMERIC(1) = 0,
           @Ln_CommitFreqParm_QNTY           NUMERIC(5),
           @Ln_ExceptionThresholdParm_QNTY    NUMERIC(5),
           @Ln_Error_NUMB                 NUMERIC(11),
           @Ln_ErrorLine_NUMB             NUMERIC(11),
           @Ln_ProcessedRecordCount_QNTY  NUMERIC(19) = 0,
           @Lc_Msg_CODE                   CHAR(1) = '',
           @Ls_File_NAME                  VARCHAR(50) = '',
           @Ls_FileLocation_TEXT          VARCHAR(80) = '',
           @Ls_Sql_TEXT                   VARCHAR(100) = '',
           @Ls_Query_TEXT                 VARCHAR(1000) = '',
           @Ls_Sqldata_TEXT               VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT          VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT      VARCHAR(4000) = '',
           @Ld_Run_DATE                   DATE,
           @Ld_LastRun_DATE               DATE,
           @Ld_ProcessBegin_DATE          DATE,
           @Ld_ProcessEnd_DATE            DATE,
           @Ld_Start_DATE                 DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TABLE CREATION ##ExtractIveColl_P1';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractIveColl_P1
    (
      Record_TEXT VARCHAR(154)
    );

   BEGIN TRANSACTION OUTGOING_IVE;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;

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

   SET @Ld_ProcessBegin_DATE = DATEADD(DAY,-(DAY(@Ld_Run_DATE)-1),@Ld_Run_DATE);
   SET @Ld_ProcessEnd_DATE = DATEADD(DAY, -1, DATEADD(MONTH, 1, @Ld_ProcessBegin_DATE));
   
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DELETE EICOL_Y1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID;

   DELETE EICOL_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO EICOL_Y1';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   WITH LwelDetailsTab
        AS (SELECT a.MemberMci_IDNO Dependent_IDNO,
                   a.NcpRelationshipToChild_CODE,
                   a.Case_IDNO,
                   n.MemberMci_IDNO AS Ncp_IDNO,
                   nd.IveParty_IDNO,
                   a.Collected_AMNT,
                   a.Payment_DATE
              FROM (SELECT l.Case_IDNO,
                           SUM(l.Distribute_AMNT) Collected_AMNT,
                           MAX(l.Distribute_DATE) Payment_DATE,
                           o.MemberMci_IDNO,
                           m.NcpRelationshipToChild_CODE
                      FROM (SELECT m.NcpRelationshipToChild_CODE,
                                   m.MemberMci_IDNO,
                                   m.Case_IDNO
                              FROM CMEM_Y1 m
                             WHERE m.CaseRelationship_CODE = @Lc_CaseRelationshipDependent_CODE
                               AND m.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE
                               AND m.NcpRelationshipToChild_CODE IN (@Lc_NcpMother_CODE, @Lc_NcpFather_CODE)) m,
                           (SELECT o.Case_IDNO,
                                   o.OrderSeq_NUMB,
                                   o.ObligationSeq_NUMB,
                                   o.MemberMci_IDNO
                              FROM OBLE_Y1 o
                             WHERE o.BeginObligation_DATE = (SELECT MAX(x.BeginObligation_DATE)
                                                               FROM OBLE_Y1 AS x
                                                              WHERE x.Case_IDNO = o.Case_IDNO
                                                                AND x.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                                AND x.ObligationSeq_NUMB = o.ObligationSeq_NUMB)
                               AND o.EventGlobalBeginSeq_NUMB = (SELECT MAX(y.EventGlobalBeginSeq_NUMB)
                                                                   FROM OBLE_Y1 y
                                                                  WHERE y.Case_IDNO = o.Case_IDNO
                                                                    AND y.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                                    AND y.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                                    AND y.BeginObligation_DATE = o.BeginObligation_DATE)) o,
                           (SELECT l.Case_IDNO,
                                   l.OrderSeq_NUMB,
                                   l.ObligationSeq_NUMB,
                                   l.Distribute_AMNT,
                                   l.Distribute_DATE
                              FROM LWEL_Y1 l
                             WHERE l.Distribute_DATE BETWEEN @Ld_ProcessBegin_DATE AND @Ld_ProcessEnd_DATE
                                   AND  l.TypeDisburse_CODE 
                                        IN (
											@Lc_DisbursementTypeAgive_CODE,
											@Lc_DisbursementTypeCgive_CODE, 
											@Lc_DisbursementTypePgive_CODE, 
											@Lc_DisbursementTypeAxive_CODE, 
											@Lc_DisbursementTypeCxive_CODE, 
											@Lc_DisbursementTypeAznfc_CODE, 
											@Lc_DisbursementTypeCznfc_CODE
										   )													      
                                   AND NOT EXISTS (SELECT 1
                                                     FROM ELRP_Y1 r
                                                    WHERE l.Batch_DATE = r.BatchOrig_DATE
                                                      AND l.Batch_NUMB = r.BatchOrig_NUMB
                                                      AND l.SourceBatch_CODE = r.SourceBatchOrig_CODE
                                                      AND l.SeqReceipt_NUMB = r.SeqReceiptOrig_NUMB)) l
                     WHERE m.MemberMci_IDNO = o.MemberMci_IDNO
                       AND m.Case_IDNO = o.Case_IDNO
                       AND o.Case_IDNO = l.Case_IDNO
                       AND o.OrderSeq_NUMB = l.OrderSeq_NUMB
                       AND o.ObligationSeq_NUMB = l.ObligationSeq_NUMB
                     GROUP BY l.Case_IDNO,
                              o.MemberMci_IDNO,
                              m.NcpRelationshipToChild_CODE) a,
                   CMEM_Y1 n,
                   DEMO_Y1 nd,
                   CASE_Y1 s
             WHERE s.Case_IDNO IN (SELECT Case_IDNO 
									 FROM CMEM_Y1 b 
								    WHERE b.CaseRelationship_CODE =  @Lc_CaseRelationshipCp_CODE 
								      AND b.MemberMci_IDNO = @Ln_MemberMciCp_IDNO)
			   AND a.Case_IDNO = n.Case_IDNO
			   AND s.Case_IDNO = n.Case_IDNO
			   AND n.MemberMci_IDNO = nd.MemberMci_IDNO
			   AND n.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPutative_CODE)
			   AND n.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE
               AND s.StatusCase_CODE = @Lc_OpenCase_CODE
               AND s.TypeCase_CODE IN (@Lc_IveCase_CODE, @Lc_NonFederalFosterCare_CODE)
               )
   
   INSERT INTO EICOL_Y1
               (DependantMCI_IDNO,
                DependantPid_IDNO,
                DependantSsn_NUMB,
                Dependant_NAME,
                MotherCase_IDNO,
                MotherMci_IDNO,
                MotherPid_IDNO,
                MotherCollected_AMNT,
                MotherCollected_DATE,
                FatherCase_IDNO,
                FatherMci_IDNO,
                FatherPid_IDNO,
                FatherCollected_AMNT,
                FatherCollected_DATE)
   SELECT ISNULL(a.Dependent_IDNO, b.Dependent_IDNO) AS DependantMCI_IDNO,
          ISNULL(d.IveParty_IDNO, 0) AS DependantPid_IDNO,
          ISNULL(d.MemberSsn_NUMB, 0) AS DependantSsn_NUMB,
          ISNULL(d.Last_NAME, '') AS Dependant_NAME,
          ISNULL(a.Case_IDNO, 0) AS MotherCase_IDNO,
          ISNULL(a.Ncp_IDNO, 0) AS MotherMci_IDNO,
          ISNULL(a.IveParty_IDNO, 0) AS MotherPid_IDNO,
          ISNULL(a.Collected_AMNT, 0) AS MotherCollected_AMNT,
          ISNULL(CONVERT(VARCHAR(8), a.Payment_DATE, 112), '') AS MotherCollected_DATE,
          ISNULL(b.Case_IDNO, 0) AS FatherCase_IDNO,
          ISNULL(b.Ncp_IDNO, 0) AS FatherMci_IDNO,
          ISNULL(b.IveParty_IDNO, 0) AS FatherPid_IDNO,
          ISNULL(b.Collected_AMNT, 0) AS FatherCollected_AMNT,
          ISNULL(CONVERT(VARCHAR(8), b.Payment_DATE, 112), '') AS FatherCollected_DATE
     FROM (SELECT a.Dependent_IDNO,
                  a.NcpRelationshipToChild_CODE,
                  a.Case_IDNO,
                  a.Ncp_IDNO,
                  a.IveParty_IDNO,
                  a.Collected_AMNT,
                  a.Payment_DATE
             FROM LwelDetailsTab a
            WHERE a.NcpRelationshipToChild_CODE = @Lc_NcpMother_CODE)a
          FULL OUTER JOIN (SELECT a.Dependent_IDNO,
                                  a.NcpRelationshipToChild_CODE,
                                  a.Case_IDNO,
                                  a.Ncp_IDNO,
                                  a.IveParty_IDNO,
                                  a.Collected_AMNT,
                                  a.Payment_DATE
                             FROM LwelDetailsTab a
                            WHERE a.NcpRelationshipToChild_CODE = @Lc_NcpFather_CODE)b
           ON a.Dependent_IDNO = b.Dependent_IDNO
          JOIN DEMO_Y1 d
           ON ISNULL(a.Dependent_IDNO, b.Dependent_IDNO) = d.MemberMci_IDNO;
  
   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
										  FROM EICOL_Y1 e);	
	
  IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS(S) TO EXTRACT';
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
   
   SET @Ls_Sql_TEXT = 'INSERT HEADER RECORD';
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID +  ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractIveColl_P1
               (Record_TEXT)
        VALUES ( @Lc_RecordHeader_CODE + CONVERT(VARCHAR, @Ld_Run_DATE, 112) + REPLICATE(@Lc_Space_TEXT, 145) --Record_TEXT
				);

   SET @Ls_Sql_TEXT = 'INSERT DETAIAL RECORDS';
   SET @Ls_Sqldata_TEXT = 'RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractIveColl_P1
               (Record_TEXT)
   SELECT @Lc_RecordDetail_CODE + RIGHT(('0000000000' + LTRIM(RTRIM(e.DependantMCI_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(e.DependantPid_IDNO))), 10) + RIGHT(('000000000' + LTRIM(RTRIM(e.DependantSsn_NUMB))), 9) + CONVERT(CHAR(24), e.Dependant_NAME) + RIGHT(('0000000000' + LTRIM(RTRIM(e.MotherCase_IDNO))), 10) + RIGHT (('0000000000' + LTRIM(RTRIM(e.MotherMci_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(e.MotherPid_IDNO))), 10) + RIGHT(('++++++++++++' + LTRIM(RTRIM(e.MotherCollected_AMNT))), 12) + LEFT(MotherCollected_DATE, 8) + RIGHT (('0000000000' + LTRIM(RTRIM(e.FatherCase_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(e.FatherMci_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(e.FatherPid_IDNO))), 10) + RIGHT(('++++++++++++' + LTRIM(RTRIM(e.FatherCollected_AMNT))), 12) + LEFT(FatherCollected_DATE, 8) AS Record_TEXT
     FROM EICOL_Y1 e;

   SET @Ls_Sql_TEXT = 'INSERT TRAILER RECORD';
   SET @Ls_Sqldata_TEXT = 'Total record quantity = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);

   INSERT INTO ##ExtractIveColl_P1
				(Record_TEXT)
        VALUES ( @Lc_RecordTrailer_CODE + RIGHT(('0000000000' + LTRIM(RTRIM(@Ln_ProcessedRecordCount_QNTY))), 10) + REPLICATE(@Lc_Space_TEXT, 143) --Record_TEXT
				);

   COMMIT TRANSACTION OUTGOING_IVE;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractIveColl_P1 ';
   SET @Ls_Sql_TEXT = 'Extract Data';
   SET @Ls_Sqldata_TEXT = 'FILE Location = ' + @Ls_FileLocation_TEXT + ', Ls_File_NAME = ' + @Ls_File_NAME + ', Query TEXT = ' + @Ls_Query_TEXT;
   
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

   BEGIN TRANSACTION OUTGOING_IVE;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_UserBatch_IDNO,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractIveColl_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job Id = ' + @Lc_Job_ID;

   DROP TABLE ##ExtractIveColl_P1;

   COMMIT TRANSACTION OUTGOING_IVE;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_IVE;
    END;

   IF OBJECT_ID('tempdb..##ExtractIveColl_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractIveColl_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT= @Ls_DescriptionError_TEXT;

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
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_UserBatch_IDNO,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB ;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END;


GO
