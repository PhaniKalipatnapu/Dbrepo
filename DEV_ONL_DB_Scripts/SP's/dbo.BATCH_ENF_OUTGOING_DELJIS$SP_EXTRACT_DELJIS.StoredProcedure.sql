/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_DELJIS$SP_EXTRACT_DELJIS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_OUTGOING_DELJIS$SP_EXTRACT_DELJIS
Programmer Name 	: IMP Team
Description			: The procedure BATCH_ENF_OUTGOING_DELJIS scans the NCP records for all eligible cases
                       and send the NCP's details to Delaware Criminal Justice Information System through
                       the file transmission process.
Frequency			: 'Weekly'
Developed On		: 08/16/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 0.1
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_DELJIS$SP_EXTRACT_DELJIS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Increment_NUMB               NUMERIC(1) = 1,
          @Ln_UnIdentifyMember_IDNO        NUMERIC(9) = 999995,
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_IndNote_TEXT                 CHAR(1) = 'N',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE       CHAR(1) = 'A',
          @Lc_CaseMemberStatusActive_CODE  CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE      CHAR(1) = 'P',
          @Lc_StatusCaseOpen_CODE          CHAR(1) = 'O',
          @Lc_RespondInitInstate_CODE      CHAR(1) = 'N',
          @Lc_RespondInitResponding_CODE   CHAR(1) = 'R',
          @Lc_TribalResponding_CODE        CHAR(1) = 'S',
          @Lc_InternationalResponding_CODE CHAR(1) = 'Y',
          @Lc_TypeCaseNonIvd_CODE          CHAR(1) = 'H',
          @Lc_Yes_INDC                     CHAR(1) = 'Y',
          @Lc_TypeErrorWarning_CODE        CHAR(1) = 'W',
          @Lc_RaceI_CODE                   CHAR(1) = 'I',
          @Lc_RaceA_CODE                   CHAR(1) = 'A',
          @Lc_RaceB_CODE                   CHAR(1) = 'B',
          @Lc_RaceX_CODE                   CHAR(1) = 'X',
          @Lc_RaceH_CODE                   CHAR(1) = 'H',
          @Lc_RaceW_CODE                   CHAR(1) = 'W',
          @Lc_DeljisEthnicityAa_CODE       CHAR(2) = 'AA',
          @Lc_DeljisEthnicityAs_CODE       CHAR(2) = 'AS',
          @Lc_DeljisEthnicityBl_CODE       CHAR(2) = 'BL',
          @Lc_DeljisEthnicityOt_CODE       CHAR(2) = 'OT',
          @Lc_DeljisEthnicityHs_CODE       CHAR(2) = 'HS',
          @Lc_DeljisEthnicityCa_CODE       CHAR(2) = 'CA',
          @Lc_TypeLicenseDr_CODE           CHAR(2) = 'DR',
          @Lc_SubsystemEn_CODE             CHAR(2) = 'EN',
          @Lc_ActivityMajorCase_CODE       CHAR(4) = 'CASE',
          @Lc_StatusStrt_CODE              CHAR(4) = 'STRT',
          @Lc_StatusComp_CODE              CHAR(4) = 'COMP',
          @Lc_ReasonErfsm_CODE             CHAR(5) = 'ERFSM',
          @Lc_ReasonErfso_CODE             CHAR(5) = 'ERFSO',
          @Lc_ReasonErfss_CODE             CHAR(5) = 'ERFSS',
          @Lc_ActivityMinorStdel_CODE      CHAR(5) = 'STDEL',
          @Lc_BatchRunUser_TEXT            CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE              CHAR(5) = 'E0944',
          @Lc_Job_ID                       CHAR(7) = 'DEB8087',
          @Lc_LeadZero_TEXT                CHAR(15) = '000000000000000',
          @Lc_Successful_TEXT              CHAR(20) = 'SUCCESSFUL',
          @Ls_Procedure_NAME               VARCHAR(100) = 'SP_EXTRACT_DELJIS',
          @Ls_Process_NAME                 VARCHAR(100) = 'BATCH_ENF_OUTGOING_DELJIS',
          @Ld_High_DATE                    DATE = '12/31/9999',
          @Ld_Low_DATE                     DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO              NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_Empty_TEXT                  CHAR(1) = '',
          @Lc_ReasonStatus_CODE           CHAR(2) = '',
          @Ls_FileName_NAME               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(200),
          @Ls_SqlData_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CREATE ##OutgoingDeljis_P1';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE ##OutgoingDeljis_P1
    (
      Record_TEXT VARCHAR (188)
    );

   BEGIN TRANSACTION OUTGOING_DELJIS;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
    
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DELETE EDLJS_Y1';
   SET @Ls_SqlData_TEXT = '';

   DELETE EDLJS_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO EDLJS_Y1';
   SET @Ls_SqlData_TEXT = 'StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', RespondInit_CODE = ' + ISNULL(@Lc_RespondInitInState_CODE, '') + ', CsObligationExist_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   INSERT INTO EDLJS_Y1
               (MemberMci_IDNO,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                Suffix_NAME,
                Birth_DATE,
                IssuingState_CODE,
                LicenseNo_TEXT,
                MemberSsn_NUMB,
                Ethnicity_CODE,
                MemberSex_CODE,
                Case_IDNO,
                Arrears_AMNT)
   (SELECT RIGHT(@Lc_LeadZero_TEXT + CAST(sd.NcpPf_IDNO AS VARCHAR), 10) AS MemberMci_IDNO,
           sd.LastNcp_NAME AS Last_NAME,
           sd.FirstNcp_NAME AS First_NAME,
           sd.MiddleNcp_NAME AS Middle_NAME,
           sd.SuffixNcp_NAME AS Suffix_NAME,
           CONVERT (CHAR (8), sd.BirthNcp_DATE, 112) AS Birth_DATE,
           ISNULL(p.IssuingState_CODE, @Lc_Space_TEXT) AS IssuingState_CODE,
           LEFT(ISNULL(p.LicenseNo_TEXT, @Lc_Space_TEXT), 12) AS LicenseNo_TEXT,
           RIGHT(@Lc_LeadZero_TEXT + CAST(d.MemberSsn_NUMB AS VARCHAR), 9) AS MemberSsn_NUMB,
           CASE
            WHEN d.Race_CODE = @Lc_RaceI_CODE
             THEN @Lc_DeljisEthnicityAa_CODE
            WHEN d.Race_CODE = @Lc_RaceA_CODE
             THEN @Lc_DeljisEthnicityAs_CODE
            WHEN d.Race_CODE = @Lc_RaceB_CODE
             THEN @Lc_DeljisEthnicityBl_CODE
            WHEN d.Race_CODE = @Lc_RaceX_CODE
             THEN @Lc_DeljisEthnicityOt_CODE
            WHEN d.Race_CODE = @Lc_RaceH_CODE
             THEN @Lc_DeljisEthnicityHs_CODE
            WHEN d.Race_CODE = @Lc_RaceW_CODE
             THEN @Lc_DeljisEthnicityCa_CODE
            ELSE @Lc_Space_TEXT
           END AS Ethnicity_CODE,
           d.MemberSex_CODE AS MemberSex_CODE,
           RIGHT(@Lc_LeadZero_TEXT + CAST(sd.Case_IDNO AS VARCHAR), 6) AS Case_IDNO,
           RIGHT(@Lc_LeadZero_TEXT + CAST(sd.Arrears_AMNT AS VARCHAR), 11) AS Arrears_AMNT
      FROM ENSD_Y1 sd
           JOIN DEMO_Y1 d
            ON d.MemberMci_IDNO = sd.NcpPf_IDNO
           LEFT OUTER JOIN (SELECT l.MemberMci_IDNO,
                                   l.IssuingState_CODE,
                                   l.LicenseNo_TEXT
                              FROM PLIC_Y1 l
                             WHERE l.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
                               AND l.EndValidity_DATE = @Ld_High_DATE) p
            ON d.MemberMci_IDNO = p.MemberMci_IDNO
     WHERE sd.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
       AND sd.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
       AND sd.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND sd.NcpPf_IDNO <> @Ln_UnIdentifyMember_IDNO
       AND (sd.RespondInit_CODE = @Lc_RespondInitInState_CODE
             OR (sd.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_TribalResponding_CODE, @Lc_InternationalResponding_CODE)
                 AND NOT EXISTS (SELECT 1
                                   FROM ICAS_Y1 c
                                  WHERE c.Case_IDNO = sd.Case_IDNO
                                    AND c.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE)))))
   UNION
   (SELECT RIGHT(@Lc_LeadZero_TEXT + CAST(d.MemberMci_IDNO AS VARCHAR), 10) AS MemberMci_IDNO,
           d.Last_NAME AS Last_NAME,
           d.First_NAME AS First_NAME,
           d.Middle_NAME AS Middle_NAME,
           d.Suffix_NAME AS Suffix_NAME,
           CONVERT (CHAR (8), d.Birth_DATE, 112) AS Birth_DATE,
           ISNULL(p.IssuingState_CODE, @Lc_Space_TEXT) AS IssuingState_CODE,
           LEFT(ISNULL(p.LicenseNo_TEXT, @Lc_Space_TEXT), 12) AS LicenseNo_TEXT,
           RIGHT(@Lc_LeadZero_TEXT + CAST(d.MemberSsn_NUMB AS VARCHAR), 9) AS MemberSsn_NUMB,
           CASE
            WHEN d.Race_CODE = @Lc_RaceI_CODE
             THEN @Lc_DeljisEthnicityAa_CODE
            WHEN d.Race_CODE = @Lc_RaceA_CODE
             THEN @Lc_DeljisEthnicityAs_CODE
            WHEN d.Race_CODE = @Lc_RaceB_CODE
             THEN @Lc_DeljisEthnicityBl_CODE
            WHEN d.Race_CODE = @Lc_RaceX_CODE
             THEN @Lc_DeljisEthnicityOt_CODE
            WHEN d.Race_CODE = @Lc_RaceH_CODE
             THEN @Lc_DeljisEthnicityHs_CODE
            WHEN d.Race_CODE = @Lc_RaceW_CODE
             THEN @Lc_DeljisEthnicityCa_CODE
            ELSE @Lc_Space_TEXT
           END AS Ethnicity_CODE,
           d.MemberSex_CODE AS MemberSex_CODE,
           RIGHT(@Lc_LeadZero_TEXT + CAST(m.Case_IDNO AS VARCHAR), 6) AS Case_IDNO,
           RIGHT(@Lc_LeadZero_TEXT + CAST(0.00 AS VARCHAR), 11) AS Arrears_AMNT
      FROM CMEM_Y1 m
           JOIN DEMO_Y1 D
            ON d.MemberMci_IDNO = m.MemberMci_IDNO
           INNER JOIN CASE_Y1 c
            ON c.Case_IDNO = m.Case_IDNO
           LEFT OUTER JOIN (SELECT l.MemberMci_IDNO,
                                   l.IssuingState_CODE,
                                   l.LicenseNo_TEXT
                              FROM PLIC_Y1 l
                             WHERE l.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
                               AND l.EndValidity_DATE = @Ld_High_DATE) p
            ON d.MemberMci_IDNO = p.MemberMci_IDNO
     WHERE c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
       AND c.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
       AND m.CaseRelationship_CODE = @Lc_CaseRelationshipPf_CODE
       AND m.MemberMci_IDNO <> @Ln_UnIdentifyMember_IDNO
       AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND NOT EXISTS (SELECT 1 
						 FROM ENSD_Y1 e
						WHERE e.NcpPf_IDNO = m.MemberMci_IDNO
						  AND e.Case_IDNO = m.Case_IDNO
						  AND e.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
						  AND e.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
					      AND e.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
       AND (c.RespondInit_CODE = @Lc_RespondInitInState_CODE
             OR (c.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_TribalResponding_CODE, @Lc_InternationalResponding_CODE)
                 AND NOT EXISTS (SELECT 1
                                   FROM ICAS_Y1 c
                                  WHERE c.Case_IDNO = m.Case_IDNO
                                    AND c.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE)))));

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM EDLJS_Y1 e);

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO EXTRACT';
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
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
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
     SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

     EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_IndNote_TEXT,
      @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT DMJR_Y1';
     SET @Ls_SqlData_TEXT = 'OrderSeq_NUMB = ' + ISNULL('0', '') + ', MemberMci_IDNO = ' + ISNULL('0', '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemEn_CODE, '') + ', TypeOthpSource_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', OthpSource_IDNO = ' + ISNULL('0', '') + ', Entered_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', BeginExempt_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', EndExempt_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', TotalTopics_QNTY = ' + ISNULL('0', '') + ', PostLastPoster_IDNO = ' + ISNULL('0', '') + ', UserLastPoster_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', SubjectLastPoster_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', LastPost_DTTM = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reference_ID = ' + ISNULL(@Lc_Space_TEXT, '');

     INSERT DMJR_Y1
            (Case_IDNO,
             OrderSeq_NUMB,
             MajorIntSEQ_NUMB,
             MemberMci_IDNO,
             ActivityMajor_CODE,
             Subsystem_CODE,
             TypeOthpSource_CODE,
             OthpSource_IDNO,
             Entered_DATE,
             Status_DATE,
             Status_CODE,
             ReasonStatus_CODE,
             BeginExempt_DATE,
             EndExempt_DATE,
             TotalTopics_QNTY,
             PostLastPoster_IDNO,
             UserLastPoster_ID,
             SubjectLastPoster_TEXT,
             LastPost_DTTM,
             BeginValidity_DATE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB,
             TypeReference_CODE,
             Reference_ID)
     SELECT DISTINCT
            B.Case_IDNO,
            0 AS OrderSeq_NUMB,
            (SELECT ISNULL(MAX(c.MajorIntSEQ_NUMB), 0) + @Ln_Increment_NUMB
               FROM DMJR_Y1 c
              WHERE c.Case_IDNO = b.Case_IDNO) AS MajorIntSEQ_NUMB,
            0 AS MemberMci_IDNO,
            @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
            @Lc_SubsystemEn_CODE AS Subsystem_CODE,
            @Lc_Space_TEXT AS TypeOthpSource_CODE,
            0 AS OthpSource_IDNO,
            @Ld_Run_DATE AS Entered_DATE,
            @Ld_High_DATE AS Status_DATE,
            @Lc_StatusStrt_CODE AS Status_CODE,
            @Lc_ReasonStatus_CODE AS ReasonStatus_CODE,
            @Ld_Low_DATE AS BeginExempt_DATE,
            @Ld_Low_DATE AS EndExempt_DATE,
            0 AS TotalTopics_QNTY,
            0 AS PostLastPoster_IDNO,
            @Lc_Space_TEXT AS UserLastPoster_ID,
            @Lc_Space_TEXT AS SubjectLastPoster_TEXT,
            @Ld_Low_DATE AS LastPost_DTTM,
            @Ld_Run_DATE AS BeginValidity_DATE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            @Ld_Start_DATE AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
            @Lc_Space_TEXT AS TypeReference_CODE,
            @Lc_Space_TEXT AS Reference_ID
       FROM EDLJS_Y1 a,
            CMEM_Y1 b,
            CASE_Y1 s
      WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
        AND b.Case_IDNO = s.Case_IDNO
        AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
        AND NOT EXISTS (SELECT 1
                          FROM DMJR_Y1 d
                         WHERE b.Case_IDNO = d.Case_IDNO
                           AND d.Subsystem_CODE = @Lc_SubsystemEn_CODE
                           AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
                           AND d.Status_CODE = @Lc_StatusStrt_CODE);

   SET @Ls_Sql_TEXT = 'GET THE MAX OF TOPIC IDNO FROM ITOPC_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);		

   SELECT @Ln_SeqUnique_IDNO = ISNULL(MAX(a.Seq_IDNO), 0) 
     FROM ITOPC_Y1 a;
  
  IF @Ln_SeqUnique_IDNO = 0 
   BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT ITOPC_Y1';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);   
	   
	   INSERT INTO ITOPC_Y1
				   (Entered_DATE)
			VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()--Entered_DATE
	   );   

	   SET @Ls_Sql_TEXT = 'GET THE MAX OF TOPIC IDNO FROM ITOPC_Y1 - 2';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
	   
       SELECT @Ln_SeqUnique_IDNO = ISNULL(MAX(a.Seq_IDNO), 0) 
		 FROM ITOPC_Y1 a;	   

   END 

     SET @Ls_Sql_TEXT = 'INSERT CJNR_Y1';
     SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ActivityMinorStfdm_CODE = ' + @Lc_ActivityMinorStdel_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', StatusComplete_CODE = ' + @Lc_StatusComp_CODE + ', ReasonStatusSy_CODE = ' + @Lc_ReasonStatus_CODE + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', SubsystemLo_CODE = ' + @Lc_SubsystemEn_CODE + ', ActivityMajorCase_CODE = ' + @Lc_ActivityMajorCase_CODE + ', StatusStart_CODE = ' + @Lc_StatusStrt_CODE;
	WITH BulkInsert_CjnrItopc
	AS (
       SELECT b.Case_IDNO AS Case_IDNO,
                    0 AS OrderSeq_NUMB,
                    d.MajorIntSEQ_NUMB AS MajorIntSEQ_NUMB,
                    ISNULL((SELECT MAX(x.MinorIntSeq_NUMB)
                              FROM UDMNR_V1 x
                             WHERE d.Case_IDNO = x.Case_IDNO
                               AND d.MajorIntSEQ_NUMB = x.MajorIntSEQ_NUMB), 0) + ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO ORDER BY b.Case_IDNO) AS MinorIntSeq_NUMB,
                    b.MemberMci_IDNO AS MemberMci_IDNO,
                    @Lc_ActivityMinorStdel_CODE AS ActivityMinor_CODE,
                    @Lc_Space_TEXT AS ActivityMinorNext_CODE,
                    @Ld_Run_DATE AS Entered_DATE,
                    @Ld_Run_DATE AS Due_DATE,
                    @Ld_Run_DATE AS Status_DATE,
                    @Lc_StatusComp_CODE AS Status_CODE,
                    @Lc_ReasonStatus_CODE AS ReasonStatus_CODE,
                    0 AS Schedule_NUMB,
                    d.Forum_IDNO,
                    0 AS NoTotalReplies_QNTY,
                    0 AS NoTotalViews_QNTY,
                    0 AS PostLastPoster_IDNO,
                    @Lc_BatchRunUser_TEXT AS UserLastPoster_ID,
                    @Ld_Start_DATE AS LastPost_DTTM,
                    @Ld_Run_DATE AS AlertPrior_DATE,
                    @Ld_Run_DATE AS BeginValidity_DATE,
                    @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                    @Ld_Start_DATE AS Update_DTTM,
                    @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                    @Lc_Space_TEXT AS WorkerDelegate_ID,
                    0 AS UssoSeq_NUMB,
                    @Lc_SubsystemEn_CODE AS Subsystem_CODE,
                    @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE
               FROM CMEM_Y1 b,
                    DMJR_Y1 d,
                    EDLJS_Y1 a,
                    CASE_Y1 s
              WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                AND b.Case_IDNO = d.Case_IDNO
                AND b.Case_IDNO = s.Case_IDNO
                AND a.Case_IDNO = d.Case_IDNO
                AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                AND d.Subsystem_CODE = @Lc_SubsystemEn_CODE
                AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
                AND d.Status_CODE = @Lc_StatusStrt_CODE)

			   INSERT INTO CJNR_Y1
					  (Case_IDNO,
					   OrderSeq_NUMB,
					   MajorIntSEQ_NUMB,
					   MinorIntSeq_NUMB,
					   MemberMci_IDNO,
					   ActivityMinor_CODE,
					   ActivityMinorNext_CODE,
					   Entered_DATE,
					   Due_DATE,
					   Status_DATE,
					   Status_CODE,
					   ReasonStatus_CODE,
					   Schedule_NUMB,
					   Forum_IDNO,
					   Topic_IDNO,
					   TotalReplies_QNTY,
					   TotalViews_QNTY,
					   PostLastPoster_IDNO,
					   UserLastPoster_ID,
					   LastPost_DTTM,
					   AlertPrior_DATE,
					   BeginValidity_DATE,
					   WorkerUpdate_ID,
					   Update_DTTM,
					   TransactionEventSeq_NUMB,
					   WorkerDelegate_ID,
					   Subsystem_CODE,
					   ActivityMajor_CODE)		
	        OUTPUT @Ld_Run_DATE
			INTO ITOPC_Y1   
			SELECT Case_IDNO,
			OrderSeq_NUMB,
			MajorIntSEQ_NUMB,
			MinorIntSeq_NUMB,
			MemberMci_IDNO,
			ActivityMinor_CODE,
			ActivityMinorNext_CODE,
			Entered_DATE,
			Due_DATE,
			Status_DATE,
			Status_CODE,
			ReasonStatus_CODE,
			Schedule_NUMB,
			Forum_IDNO,
			@Ln_SeqUnique_IDNO + (ROW_NUMBER() OVER( ORDER BY TransactionEventSeq_NUMB)) AS Topic_IDNO,
			NoTotalReplies_QNTY,
			NoTotalViews_QNTY,
			PostLastPoster_IDNO,
			UserLastPoster_ID,
			LastPost_DTTM,
			AlertPrior_DATE,
			BeginValidity_DATE,
			WorkerUpdate_ID,	
			Update_DTTM,
			TransactionEventSeq_NUMB,
			WorkerDelegate_ID,
			Subsystem_CODE,
			ActivityMajor_CODE
			FROM BulkInsert_CjnrItopc						
                
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO EDLJS_Y1';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ##OutgoingDeljis_P1
               (Record_TEXT)
   SELECT e.MemberMci_IDNO + e.Last_NAME + e.First_NAME + e.Middle_NAME + e.Suffix_NAME + e.Birth_DATE + e.IssuingState_CODE + e.LicenseNo_TEXT + e.MemberSsn_NUMB + e.Ethnicity_CODE + e.MemberSex_CODE + e.Case_IDNO + e.Arrears_AMNT + REPLICATE (@Lc_Space_TEXT, 2) AS Record_TEXT
     FROM EDLJS_Y1 e;

   COMMIT TRANSACTION OUTGOING_DELJIS;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##OutgoingDeljis_P1';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@Ls_FileName_NAME, '') + ', Query_TEXT = ' + ISNULL(@Ls_Query_TEXT, '');

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_FileName_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION OUTGOING_DELJIS;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_SqlData_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

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
   SET @Ls_SqlData_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Empty_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Empty_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION OUTGOING_DELJIS;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##OutgoingDeljis_P1 - 2';

   DROP TABLE ##OutgoingDeljis_P1;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_DELJIS;
    END

   IF CURSOR_STATUS ('LOCAL', 'Deljis_CUR') IN (0, 1)
    BEGIN
     CLOSE Deljis_CUR;

     DEALLOCATE Deljis_CUR;
    END

   IF OBJECT_ID ('tempdb..##OutgoingDeljis_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##OutgoingDeljis_P1;
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Empty_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
