/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_DMV$SP_EXTRACT_DMV]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_OUTGOING_DMV$SP_EXTRACT_DMV
Programmer Name 	: IMP Team
Description			: This batch program creates an extract file to be sent to the DMV consists of , for enforcement 
					  selected NCP's whose driver license is eligible for suspension or restoration and for locate 
					  selected NCP's who have no address or license information in the system
Frequency			: DAILY
Developed On		: 05/31/2011
Called BY			: None
Called On			: BATCH_COMMON$SP_GET_BATCH_DETAILS
					  BATCH_COMMON$SP_UPDATE_PARM_DATE
					  BATCH_COMMON$SP_BATE_LOG
					  BATCH_COMMON$SP_BSTL_LOG
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_DMV$SP_EXTRACT_DMV]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Increment_NUMB				NUMERIC(1) = 1,
		  @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_TypeErrorWarning_CODE         CHAR(1) = 'W',
          @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_No_INDC                       CHAR(1) = 'N',
          @Lc_ActionCodeM_CODE              CHAR(1) = 'M',
          @Lc_ActionCodeS_CODE              CHAR(1) = 'S',
          @Lc_ActionCodeL_CODE              CHAR(1) = 'L',
          @Lc_StatusCaseOpen_CODE           CHAR(1) = 'O',
          @Lc_MemberActiveStatus_CODE       CHAR(1) = 'A',
          @Lc_TypeCaseNonIVD_CODE           CHAR(1) = 'H',
          @Lc_RespondInitResponding_CODE    CHAR(1) = 'R',
          @Lc_RespondInitInState_CODE       CHAR(1) = 'N',
          @Lc_TribalResponding_CODE         CHAR(1) = 'S',
          @Lc_InternationalResponding_CODE  CHAR(1) = 'Y',
          @Lc_StatusGoodAddress_CODE        CHAR(1) = 'Y',
          @Lc_TypeAddressTrip_CODE          CHAR(1) = 'T',
          @Lc_LicenseTypePrimary_CODE       CHAR(1) = 'P',
          @Lc_LicenseTypeItin_CODE          CHAR(1) = 'I',
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',
          @Lc_RecordHeader_CODE             CHAR(1) = 'H',
          @Lc_RecordDetail_CODE             CHAR(1) = 'D',
          @Lc_SourceId_CODE                 CHAR(2) = 'CS',
          @Lc_TypeLicenseDr_CODE            CHAR(2) = 'DR',
          @Lc_StatusConfirmedGood_CODE      CHAR(2) = 'CG',
          @Lc_ReasonStatusGb_CODE           CHAR(2) = 'GB',
          @Lc_ReasonStatusNy_CODE           CHAR(2) = 'NY',
          @Lc_ReasonStatusLf_CODE           CHAR(2) = 'LF',
          @Lc_ReasonStatusEy_CODE           CHAR(2) = 'EY',
          @Lc_ReasonStatusNr_CODE           CHAR(2) = 'NR',
          @Lc_ReasonStatusZj_CODE           CHAR(2) = 'ZJ',
          @Lc_ReasonStatusLs_CODE           CHAR(2) = 'LS',
          @Lc_ReasonStatusFs_CODE           CHAR(2) = 'FS',
          @Lc_ReasonStatusLg_CODE           CHAR(2) = 'LG',
          @Lc_IssuingStateDe_CODE           CHAR(2) = 'DE',
          @Lc_SubsystemLocate_CODE			CHAR(2) = 'LO',
          @Lc_ReasonStatusBi_CODE			CHAR(2) = 'BI',
          @Lc_ReasonStatusSy_CODE			CHAR(2) = 'SY',
          @Lc_DescriptionDmv_CODE           CHAR(3) = 'DMV',
          @Lc_ActivityMajorCase_CODE		CHAR(4)	= 'CASE',
          @Lc_TableIdnoPlic_CODE            CHAR(4) = 'PLIC',
          @Lc_TableSubIdnoAgnc_CODE         CHAR(4) = 'AGNC',
          @Lc_MajorActivityLsnr_CODE        CHAR(4) = 'LSNR',
          @Lc_MajorActivityCpls_CODE        CHAR(4) = 'CPLS',
          @Lc_StatusComp_CODE               CHAR(4) = 'COMP',
          @Lc_StatusStrt_CODE               CHAR(4) = 'STRT',
          @Lc_ReasonErfss_CODE              CHAR(5) = 'ERFSS',
          @Lc_MinorActivityCelis_CODE       CHAR(5) = 'CELIS',
          @Lc_MinorActivityRncpl_CODE       CHAR(5) = 'RNCPL',
          @Lc_MinorActivityInfff_CODE       CHAR(5) = 'INFFF',
          @Lc_MinorActivityRradh_CODE       CHAR(5) = 'RRADH',
          @Lc_MinorActivityMofre_CODE       CHAR(5) = 'MOFRE',
          @Lc_ActivityMinorStdmv_CODE       CHAR(5) = 'STDMV',
          @Lc_Job_ID                        CHAR(7) = 'DEB5080',
          @Lc_ErrorE0944_CODE               CHAR(18) = 'E0944',
          @Lc_Successful_CODE               CHAR(20) = 'SUCCESSFUL',
          @Lc_UserBatch_TEXT                CHAR(30) = 'BATCH',
          @Ls_ParmDateProblem_TEXT          VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_ENF_OUTGOING_DMV',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_EXTRACT_DMV',
          @Ld_High_DATE                     DATE = '12/31/9999',
          @Ld_Low_DATE                      DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB    NUMERIC(19) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO              NUMERIC(19) = 0,
          @Lc_Msg_CODE                    CHAR(5) = '',
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
   SET @Ls_Sql_TEXT ='CREATE TEMPORARY TABLE';
   SET @Ls_Sqldata_TEXT='Job Id = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractDmvl_P1
    (
      --13649 - to order the action code in outgoing file -START-
	  Seq_IDNO NUMERIC IDENTITY(1,1),
	  --13649 - to order the action code in outgoing file -END-
	  Record_TEXT VARCHAR(486)
    );

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION OUTGOING_DMV;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID;
   
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID;

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
   SET @Ls_Sqldata_TEXT = 'RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'DELETE EDMVL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE EDMVL_Y1;

   --13649 - updated the sql text for error location -START-
   SET @Ls_Sql_TEXT = 'INSERT MATCHED RECORDS INTO EDMVL_Y1 - 1';
   --13649 - updated the sql text for error location -END-
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO EDMVL_Y1
               (Last_NAME,
                First_NAME,
                Middle_NAME,
                Birth_DATE,
                LicenseNo_TEXT,
                MemberSsn_NUMB,
                MemberSex_CODE,
                MemberMci_IDNO,
                Action_CODE)
   SELECT DISTINCT
          LEFT(d.Last_NAME, 12) AS Last_NAME,
          LEFT(d.First_NAME, 11) AS First_NAME,
          LEFT(d.Middle_NAME, 1) AS Miiddle_NAME,
          CONVERT(CHAR, d.Birth_DATE, 112) AS Birth_DATE,
          ISNULL(LEFT((SELECT TOP 1
                              l.LicenseNo_TEXT
                         FROM PLIC_Y1 l
                        WHERE d.MemberMci_IDNO = l.MemberMci_IDNO
                          AND l.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
                          AND l.IssuingState_CODE = @Lc_IssuingStateDe_CODE
                          AND l.EndValidity_DATE = @Ld_High_DATE), 12), @Lc_Space_TEXT) AS LicenseNo_TEXT,
          d.MemberSsn_NUMB AS MemberSsn_NUMB,
          d.MemberSex_CODE AS MemberSex_CODE,
          d.MemberMci_IDNO AS MemberMci_IDNO,
          @Lc_ActionCodeM_CODE AS Action_CODE
     FROM DEMO_Y1 d
          JOIN CMEM_Y1 c
           ON c.MemberMci_IDNO = d.MemberMci_IDNO
          JOIN MSSN_Y1 m
           ON m.MemberMci_IDNO = d.MemberMci_IDNO
          JOIN CASE_Y1 s
           ON s.Case_IDNO = c.Case_IDNO
    WHERE s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
      AND s.TypeCase_CODE <> @Lc_TypeCaseNonIVD_CODE
      AND (s.RespondInit_CODE = @Lc_RespondInitInState_CODE
            OR (s.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_TribalResponding_CODE, @Lc_InternationalResponding_CODE)
                AND NOT EXISTS (SELECT 1
                              FROM ICAS_Y1 c
                             WHERE c.Case_IDNO = s.Case_IDNO
                               AND c.Reason_CODE = @Lc_ReasonErfss_CODE)))
      AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
      AND c.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
      AND m.Enumeration_CODE = @Lc_StatusGoodAddress_CODE
      AND m.TypePrimary_CODE IN (@Lc_LicenseTypePrimary_CODE, @Lc_LicenseTypeItin_CODE)
      AND d.MemberSsn_NUMB <> @Ln_Zero_NUMB
      --13649 - eliminating deceased members from extract file -START-
      AND d.Deceased_DATE = @Ld_Low_DATE
      --13649 - eliminating deceased members from extract file -END-
      AND (NOT EXISTS (SELECT 1
                         FROM PLIC_Y1 p
                        WHERE d.MemberMci_IDNO = p.MemberMci_IDNO
                          AND p.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
                          AND p.Status_CODE = @Lc_StatusConfirmedGood_CODE
                          AND p.IssuingState_CODE = @Lc_IssuingStateDe_CODE
                          AND EndValidity_DATE = @Ld_High_DATE)
            OR NOT EXISTS (SELECT 1
                             FROM AHIS_Y1 a
                            WHERE a.Status_CODE = @Lc_StatusGoodAddress_CODE
                              AND a.End_DATE = @Ld_High_DATE
                              AND a.MemberMci_IDNO = d.MemberMci_IDNO
                              AND a.TypeAddress_CODE <> @Lc_TypeAddressTrip_CODE))
   --13649 - for better performance, using different inserts instead of union -START-
   SET @Ls_Sql_TEXT = 'INSERT SUSPEND, LIFT RECORDS INTO EDMVL_Y1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO EDMVL_Y1
               (Last_NAME,
                First_NAME,
                Middle_NAME,
                Birth_DATE,
                LicenseNo_TEXT,
                MemberSsn_NUMB,
                MemberSex_CODE,
                MemberMci_IDNO,
                Action_CODE)
   --13649 - for better performance, using different inserts instead of union -END-
   SELECT DISTINCT 
          LEFT(en.LastNcp_NAME, 12) AS Last_NAME,
          LEFT(en.FirstNcp_NAME, 11) AS First_NAME,
          LEFT(en.MiddleNcp_NAME, 1) AS Middle_NAME,
          CONVERT(CHAR, en.BirthNcp_DATE, 112) AS Birth_DATE,
          LEFT(pl.LicenseNo_TEXT, 12) AS LicenseNo_TEXT,
          dm.MemberSsn_NUMB AS MemberSsn_NUMB,
          dm.MemberSex_CODE AS MemberSex_CODE,
          en.NcpPf_IDNO AS MemberMci_IDNO,
          CASE
           WHEN mn.ReasonStatus_CODE IN (@Lc_ReasonStatusEy_CODE, @Lc_ReasonStatusNr_CODE, @Lc_ReasonStatusZj_CODE,
                                         @Lc_ReasonStatusLs_CODE, @Lc_ReasonStatusFs_CODE, @Lc_ReasonStatusLg_CODE)
            THEN @Lc_ActionCodeS_CODE
           WHEN mn.ReasonStatus_CODE IN (@Lc_ReasonStatusGb_CODE, @Lc_ReasonStatusNy_CODE, @Lc_ReasonStatusLf_CODE)
            THEN @Lc_ActionCodeL_CODE
          END AS Action_CODE
     FROM DMJR_Y1 mj,
          DMNR_Y1 mn,
          ENSD_Y1 en,
          PLIC_Y1 pl,
          DEMO_Y1 dm
    WHERE mj.ActivityMajor_CODE IN (@Lc_MajorActivityLsnr_CODE, @Lc_MajorActivityCpls_CODE)
      AND mj.Status_CODE IN (@Lc_StatusStrt_CODE, @Lc_StatusComp_CODE)
      AND mj.Case_IDNO = mn.Case_IDNO
      AND mj.OrderSeq_NUMB = mn.OrderSeq_NUMB
      AND mj.MajorIntSEQ_NUMB = mn.MajorIntSEQ_NUMB
      AND en.Case_IDNO = mj.Case_IDNO
      AND dm.MemberMci_IDNO = en.NcpPf_IDNO
      AND dm.MemberSsn_NUMB <> @Ln_Zero_NUMB
      --13649 - eliminating deceased members from extract file -START-
      AND dm.Deceased_DATE = @Ld_Low_DATE
      --13649 - eliminating deceased members from extract file -END-
      AND pl.LicenseNo_TEXT = mj.Reference_ID
      AND pl.IssuingState_CODE = @Lc_IssuingStateDe_CODE
      AND pl.Status_CODE = @Lc_StatusConfirmedGood_CODE
      AND pl.EndValidity_DATE = @Ld_High_DATE
      AND pl.TypeLicense_CODE IN (SELECT Rm.Value_CODE
                                    FROM REFM_Y1 rm
                                   WHERE Rm.Table_ID = @Lc_TableIdnoPlic_CODE
                                     AND Rm.TableSub_ID = @Lc_TableSubIdnoAgnc_CODE
                                     AND Rm.DescriptionValue_TEXT = @Lc_DescriptionDmv_CODE)
      AND mn.Status_DATE > @Ld_LastRun_DATE
      AND mn.Status_DATE <= @Ld_Run_DATE
      AND ( mj.Status_CODE = @Lc_StatusStrt_CODE
            AND ((mn.ActivityMinor_CODE = @Lc_MinorActivityCelis_CODE
             AND mn.ReasonStatus_CODE IN(@Lc_ReasonStatusEy_CODE, @Lc_ReasonStatusLs_CODE))
             OR (mn.ActivityMinor_CODE = @Lc_MinorActivityRncpl_CODE
                 AND mn.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE)
             OR (mn.ActivityMinor_CODE = @Lc_MinorActivityInfff_CODE
                 AND mn.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE)
             OR (mn.ActivityMinor_CODE = @Lc_MinorActivityRradh_CODE
                 AND mn.ReasonStatus_CODE = @Lc_ReasonStatusZj_CODE)
             OR (mn.ActivityMinor_CODE = @Lc_MinorActivityMofre_CODE
                 AND mn.ReasonStatus_CODE = @Lc_ReasonStatusLg_CODE))
            OR (mj.Status_CODE = @Lc_StatusComp_CODE
                AND mn.ActivityMinor_CODE = @Lc_MinorActivityMofre_CODE
                AND mn.ReasonStatus_CODE IN (@Lc_ReasonStatusGb_CODE, @Lc_ReasonStatusNy_CODE, @Lc_ReasonStatusLf_CODE)
                AND NOT EXISTS (SELECT 1
                                  FROM DMJR_Y1 mji,
                                       DMNR_Y1 mni
                                 WHERE pl.MemberMci_IDNO = mji.MemberMci_IDNO
                                   AND pl.LicenseNo_TEXT = mji.Reference_ID
                                   AND mj.OthpSource_IDNO = mji.OthpSource_IDNO
                                   AND NOT (mji.MajorIntSEQ_NUMB = mj.MajorIntSEQ_NUMB
                                            AND mji.Case_IDNO = mj.Case_IDNO
                                            AND mji.OrderSeq_NUMB = mj.OrderSeq_NUMB)
                                   AND mji.ActivityMajor_CODE IN (@Lc_MajorActivityLsnr_CODE, @Lc_MajorActivityCpls_CODE)
                                   AND mji.Status_CODE IN (@Lc_StatusStrt_CODE, @Lc_StatusComp_CODE)
                                   AND mji.Case_IDNO = mni.Case_IDNO
                                   AND mji.OrderSeq_NUMB = mni.OrderSeq_NUMB
                                   AND mji.MajorIntSEQ_NUMB = mni.MajorIntSEQ_NUMB
                                   AND mni.Status_DATE > @Ld_LastRun_DATE
                                   AND ((mni.ActivityMinor_CODE = @Lc_MinorActivityCelis_CODE
                                         AND mni.ReasonStatus_CODE IN (@Lc_ReasonStatusEy_CODE, @Lc_ReasonStatusLs_CODE))
                                         OR (mni.ActivityMinor_CODE = @Lc_MinorActivityRncpl_CODE
                                             AND mni.ReasonStatus_CODE = @Lc_ReasonStatusNr_CODE)
                                         OR (mn.ActivityMinor_CODE = @Lc_MinorActivityInfff_CODE
                                             AND mn.ReasonStatus_CODE = @Lc_ReasonStatusFs_CODE)
                                         OR (mni.ActivityMinor_CODE = @Lc_MinorActivityRradh_CODE
                                             AND mni.ReasonStatus_CODE = @Lc_ReasonStatusZj_CODE)
                                         OR (mni.ActivityMinor_CODE = @Lc_MinorActivityMofre_CODE
                                             AND mni.ReasonStatus_CODE = @Lc_ReasonStatusLg_CODE)))));

   --13649 - inserting matched records for members eligible for license suspension -START-
   SET @Ls_Sql_TEXT = 'DUPLICATING SUSPEND RECORDS WITH MATCHING ACTION CODE, INSERT INTO EDMVL_Y1 - 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO EDMVL_Y1
               (Last_NAME,
                First_NAME,
                Middle_NAME,
                Birth_DATE,
                LicenseNo_TEXT,
                MemberSsn_NUMB,
                MemberSex_CODE,
                MemberMci_IDNO,
                Action_CODE)
		 SELECT Last_NAME,
                First_NAME,
                Middle_NAME,
                Birth_DATE,
                LicenseNo_TEXT,
                MemberSsn_NUMB,
                MemberSex_CODE,
                MemberMci_IDNO,
                @Lc_ActionCodeM_CODE AS Action_CODE
           FROM EDMVL_Y1 e
          WHERE e.Action_CODE = @Lc_ActionCodeS_CODE
            AND NOT EXISTS(SELECT 1
							 FROM EDMVL_Y1 a
							WHERE a.MemberMci_IDNO = e.MemberMci_IDNO
							  AND a.Action_CODE = @Lc_ActionCodeM_CODE);
   --13649 - inserting matched records for members eligible for license suspension -END-
   
   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM EDMVL_Y1);

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO EXTRACT';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
		   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT FOR ACTIVITY';
		   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

		   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
			@Ac_Worker_ID                = @Lc_UserBatch_TEXT,
			@Ac_Process_ID               = @Lc_Job_ID,
			@Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
			@Ac_Note_INDC                = @Lc_No_INDC,
			@An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
			@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

		   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR (50001,16,1);
			END;
			
			SET @Ls_Sql_TEXT = 'INSERT DMJR_Y1';
			SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', Increment_NUMB = '+ CAST(@Ln_Increment_NUMB  AS VARCHAR) + ', ActivityMajorCase_CODE = '+@Lc_ActivityMajorCase_CODE  +', SubsystemLo_CODE = '+@Lc_SubsystemLocate_CODE +', Run_DATE = '+ CAST(@Ld_Run_DATE AS VARCHAR) +', High_DATE = '+ CAST(@Ld_High_DATE AS VARCHAR) +', ReasonStatusBi_CODE = '+  @Lc_ReasonStatusBi_CODE +', Low_DATE = '+ CAST(@Ld_Low_DATE AS VARCHAR) +', BatchRunUser_TEXT = '+ @Lc_UserBatch_TEXT ;
			
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
			   SELECT DISTINCT B.Case_IDNO, 
					  0 AS OrderSeq_NUMB,
					  (SELECT ISNULL(MAX(c.MajorIntSEQ_NUMB), 0) + @Ln_Increment_NUMB
						 FROM DMJR_Y1 c
						WHERE c.Case_IDNO = b.Case_IDNO) AS MajorIntSEQ_NUMB,
					  0 AS MemberMci_IDNO, 
					  @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE,
					  @Lc_SubsystemLocate_CODE AS Subsystem_CODE,
					  @Lc_Space_TEXT AS TypeOthpSource_CODE,
					  0 AS OthpSource_IDNO,
					  @Ld_Run_DATE AS Entered_DATE,
					  @Ld_High_DATE AS Status_DATE,
					  @Lc_StatusStrt_CODE AS Status_CODE,
					  @Lc_ReasonStatusBi_CODE AS ReasonStatus_CODE,
					  @Ld_Low_DATE AS BeginExempt_DATE,
					  @Ld_Low_DATE AS EndExempt_DATE,
					  0 AS TotalTopics_QNTY,
					  0 AS PostLastPoster_IDNO,
					  @Lc_Space_TEXT AS UserLastPoster_ID,
					  @Lc_Space_TEXT AS SubjectLastPoster_TEXT,
					  @Ld_Low_DATE AS LastPost_DTTM,
					  @Ld_Run_DATE AS BeginValidity_DATE,
					  @Lc_UserBatch_TEXT AS WorkerUpdate_ID,
					  @Ld_Start_DATE AS UPDATE_DTTM,
					  @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
					  @Lc_Space_TEXT AS TypeReference_CODE,
					  @Lc_Space_TEXT AS Reference_ID
				FROM EDMVL_Y1 a,
					 CMEM_Y1 b,
					 CASE_Y1 s
			   WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
			      AND b.Case_IDNO = s.Case_IDNO
			      AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
				  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE ,@Lc_CaseRelationshipPutative_CODE)
				  AND b.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
				  --13649 - not writing case journal entry for suspension records -START-
				  AND a.Action_CODE <> @Lc_ActionCodeS_CODE
				  --13649 - not writing case journal entry for suspension records -END-
				  AND NOT EXISTS (SELECT 1
									FROM DMJR_Y1 d
								   WHERE b.Case_IDNO = d.Case_IDNO
									 AND d.Subsystem_CODE = @Lc_SubsystemLocate_CODE
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
	SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', ActivityMinorStfdm_CODE = '+ @Lc_ActivityMinorstdmv_CODE + ', Run_DATE = '+ CAST( @Ld_Run_DATE  AS VARCHAR)+ ', StatusComplete_CODE = '+ @Lc_StatusComp_CODE  +', ReasonStatusSy_CODE = '+@Lc_ReasonStatusSy_CODE +', BatchRunUser_TEXT = '+ @Lc_UserBatch_TEXT +', SubsystemLo_CODE = '+@Lc_SubsystemLocate_CODE  + ', ActivityMajorCase_CODE = '+ @Lc_ActivityMajorCase_CODE +', StatusStart_CODE = '+ @Lc_StatusStrt_CODE;
			   
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
							  @Lc_ActivityMinorStdmv_CODE AS ActivityMinor_CODE,
							  @Lc_Space_TEXT AS ActivityMinorNext_CODE,
							  @Ld_Run_DATE AS Entered_DATE,
							  @Ld_Run_DATE AS Due_DATE,
							  @Ld_Run_DATE AS Status_DATE,
							  @Lc_StatusComp_CODE AS Status_CODE,
							  @Lc_ReasonStatusSy_CODE AS ReasonStatus_CODE,
							  0 AS Schedule_NUMB,
							  d.Forum_IDNO,
							  0 AS NoTotalReplies_QNTY,
							  0 AS NoTotalViews_QNTY,
							  0 AS PostLastPoster_IDNO,
							  @Lc_UserBatch_TEXT AS UserLastPoster_ID,
							  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS LastPost_DTTM,
							  @Ld_Run_DATE AS AlertPrior_DATE,
							  @Ld_Run_DATE AS BeginValidity_DATE,
							  @Lc_UserBatch_TEXT AS WorkerUpdate_ID,
							  dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
							  @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
							  @Lc_Space_TEXT AS WorkerDelegate_ID,
							  0 AS UssoSeq_NUMB,
							  @Lc_SubsystemLocate_CODE AS Subsystem_CODE,
							  @Lc_ActivityMajorCase_CODE AS ActivityMajor_CODE
						 FROM CMEM_Y1 b,
							  DMJR_Y1 d,
							  EDMVL_Y1 a,
							  CASE_Y1 s
						WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
						  AND b.Case_IDNO = d.Case_IDNO
						  AND b.Case_IDNO = s.Case_IDNO
						  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE ,@Lc_CaseRelationshipPutative_CODE)
						  AND b.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
						  AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
						  AND d.Subsystem_CODE = @Lc_SubsystemLocate_CODE
						  AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
						  AND d.Status_CODE = @Lc_StatusStrt_CODE
						  --13649 - not writing case journal entry for suspension records -START-
						  AND a.Action_CODE <> @Lc_ActionCodeS_CODE
						  --13649 - not writing case journal entry for suspension records -END-
	   )
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
   
   SET @Ls_Sql_TEXT = 'INSERT Header Record';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractDmvl_P1
               (Record_TEXT)
   SELECT @Lc_RecordHeader_CODE + CONVERT(VARCHAR(10), @Ld_Run_DATE, 112) + RIGHT(('000000' + LTRIM(RTRIM(@Ln_ProcessedRecordCount_QNTY))), 6) + REPLICATE(@Lc_Space_TEXT, 471); --Record_TEXT
   
   SET @Ls_Sql_TEXT = 'INSERT DETAIL RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractDmvl_P1
               (Record_TEXT)
   SELECT CONVERT(CHAR(1), @Lc_RecordDetail_CODE) + CONVERT(CHAR(12), Last_NAME) + CONVERT(CHAR(11), First_NAME) + CONVERT(CHAR(01), Middle_NAME) + CONVERT(CHAR(08), Birth_DATE) + CONVERT(CHAR(12), LicenseNo_TEXT) + RIGHT (('000000000' + LTRIM(RTRIM(MemberSsn_NUMB))), 9) + CONVERT(CHAR(1), MemberSex_CODE) + RIGHT(('0000000000' + LTRIM(RTRIM(MemberMci_IDNO))), 10) + CONVERT(CHAR(2), @Lc_SourceId_CODE) + CONVERT(CHAR(1), Action_CODE) + REPLICATE(@Lc_Space_TEXT, 418) --Record_TEXT
     --13649 - inserting into global temporary table in Action code order -START-
     FROM EDMVL_Y1 a ORDER BY a.Action_CODE;
     --13649 - inserting into global temporary table in Action code order -END-

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION OUTGOING_DMV;

   --13649 - updated query with Seq_IDNO order -START-
   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractDmvl_P1 ORDER BY Seq_IDNO ASC';
   --13649 - updated query with Seq_IDNO order -END-
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

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   BEGIN TRANSACTION OUTGOING_DMV;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', USER ID = ' + @Lc_UserBatch_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_CODE,
    @As_ListKey_TEXT              = @Lc_Successful_CODE,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_UserBatch_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractDmvl_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE ##ExtractDmvl_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION OUTGOING_DMV;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_DMV;
    END;

   IF CURSOR_STATUS ('LOCAL', 'CaseMember_Cur') IN (0, 1)
    BEGIN
     CLOSE CaseMember_Cur;

     DEALLOCATE CaseMember_Cur;
    END

   IF OBJECT_ID('tempdb..##ExtractDmvl_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractDmvl_P1;
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
    @Ac_Worker_ID                 = @Lc_UserBatch_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
