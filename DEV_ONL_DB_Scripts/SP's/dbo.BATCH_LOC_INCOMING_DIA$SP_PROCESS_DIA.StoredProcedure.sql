/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_DIA$SP_PROCESS_DIA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_DIA$SP_PROCESS_DIA
Programmer Name   :	IMP Team
Description       :	Reads the DIA load table and updates the member's address, employer details, Asset table.
Frequency         :	Weekly.
Developed On      :	01/19/2012
Called By         :	None
Called On		  :	
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_DIA$SP_PROCESS_DIA]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE                CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE               CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE           CHAR(1) = 'A',
          @Lc_MailingTypeAddress_CODE          CHAR(1) = 'M',
          @Lc_PendingStatus_CODE               CHAR(1) = 'P',
          @Lc_IndNote_TEXT                     CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE                  CHAR(1) = 'E',
          @Lc_ActiveCaseMemberStatus_CODE      CHAR(1) = 'A',
          @Lc_OpenStatusCase_CODE              CHAR(1) = 'O',
          @Lc_ProcessY_INDC                    CHAR(1) = 'Y',
          @Lc_StatusConfGoodY_CODE             CHAR(1) = 'Y',
          @Lc_TypeOthpEmployer_CODE            CHAR(1) = 'E',
          @Lc_TypeOthpInsurer_CODE             CHAR(1) = 'I',
          @Lc_ProcessN_INDC                    CHAR(1) = 'N',
          @Lc_StatusCaseOpen_CODE              CHAR(1) = 'O',
          @Lc_TypeCaseNivd_CODE                CHAR(1) = 'H',
          @Lc_CaseRelationshipNcp_CODE         CHAR(1) = 'A',
          @Lc_CaseRelationshipPutative_CODE    CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE          CHAR(1) = 'C',
          @Lc_NegPosP_CODE                     CHAR(1) = 'P',
          @Lc_StatusEnforceO_CODE              CHAR(1) = 'O',
          @Lc_SourceLocA_CODE				   CHAR(1) = 'A',
          @Lc_TypeChangeLi_CODE                CHAR(2) = 'LI',
          @Lc_Country_ADDR                     CHAR(2) = 'US',
          @Lc_TypeIncomeWc_CODE                CHAR(2) = 'WC',
          @Lc_Subsystem_CODE                   CHAR(3) = 'LO',
          @Lc_DiaSourceLoc_CODE                CHAR(3) = 'DIA',
          @Lc_AssetIns_CODE                    CHAR(3) = 'INS',
          @Lc_ActivityMajor_CODE               CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO               CHAR(4) = ' ',
          @Lc_BatchRunUser_TEXT                CHAR(5) = 'BATCH',
          @Lc_BateError_CODE                   CHAR(5) = ' ',
          @Lc_ErrorE0944_CODE                  CHAR(5) = 'E0944',
          @Lc_ErrorE0085_CODE                  CHAR(5) = 'E0085',
          @Lc_ErrorE0145_CODE                  CHAR(5) = 'E0145',
          @Lc_ErrorE0012_CODE                  CHAR(5) = 'E0012',
          @Lc_ErrorE1373_CODE                  CHAR(5) = 'E1373',
          @Lc_ErrorE1452_CODE                  CHAR(5) = 'E1452',
          @Lc_ErrorE1424_CODE                  CHAR(5) = 'E1424',
          @Lc_ErrorE0270_CODE                  CHAR(5) = 'E0270',
          @Lc_ErrorE0071_CODE                  CHAR(5) = 'E0071',
		  @Lc_ErrorE1089_CODE				   CHAR(5) = 'E1089',
          @Lc_ActivityMinorRedia_CODE          CHAR(5) = 'REDIA',
          @Lc_Job_ID                           CHAR(7) = 'DEB8110',
          @Lc_Process_ID                       CHAR(7) = 'DEB8110',
          @Lc_Successful_TEXT                  CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT                     CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Lc_WorkerDelegate_ID                CHAR(30) = ' ',
          @Lc_Reference_ID                     CHAR(30) = ' ',
          @Lc_Attn_ADDR                        CHAR(40) = ' ',
          @Ls_ParmDateProblem_TEXT             VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                     VARCHAR(100) = 'BATCH_LOC_INCOMING_DIA',
          @Ls_Procedure_NAME                   VARCHAR(100) = 'SP_PROCESS_DIA',
          @Ls_DescriptionComments_TEXT         VARCHAR(1000) = ' ',
          @Ls_DescriptionServiceDirection_TEXT VARCHAR(1000) = ' ',
          @Ls_XmlTextIn_TEXT                   VARCHAR(8000) = ' ',
          @Ld_Low_DATE                         DATE = '01/01/0001',
          @Ld_High_DATE                        DATE = '12/31/9999';
  DECLARE @Ln_TopicIn_IDNO                NUMERIC(3) = 0,
          @Ln_OrderSeq_NUMB               NUMERIC(3) = 0,
          @Ln_AssetSeq_NUMB               NUMERIC(3) = 0,
          @Ln_Office_IDNO                 NUMERIC(3) = 0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_Zero_NUMB                   NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB            NUMERIC(5) = 0,
          @Ln_MajorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB            NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_OthpSource_IDNO             NUMERIC(9) = 0,
          @Ln_OthpLocation_IDNO           NUMERIC(9) = 0,
          @Ln_Schedule_NUMB               NUMERIC(10) = 0,
          @Ln_RecordCount_QNTY            NUMERIC(10) = 0,
          @Ln_Topic_IDNO                  NUMERIC(10) = 0,
          @Ln_MemberMci_IDNO              NUMERIC(10) = 0,
          @Ln_OthpPartyInsurer_IDNO       NUMERIC(10) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB    NUMERIC(18) = 0,
          @Ln_ProcessedRecordsCommit_QNTY NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Li_RowsCount_QNTY              SMALLINT,
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_ReasonStatus_CODE           CHAR(2) = '',
          @Lc_OthStateFips_CODE           CHAR(2) = '',
          @Lc_Msg_CODE                    CHAR(5) = '',
          @Lc_Notice_ID                   CHAR(8) = '',
          @Lc_Schedule_Member_IDNO        CHAR(10) = '',
          @Lc_Schedule_Worker_IDNO        CHAR(30) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sql_TEXT                    VARCHAR(2000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_Sqldata_TEXT                VARCHAR(5000) = '',
          @Ls_BateRecord_TEXT             VARCHAR(8000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Ld_BeginSch_DTTM               DATETIME2,
          @Lb_ErrorExpection_CODE         BIT = 0;
  DECLARE Dia_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.InsuranceMatchRecord_NUMB,
          a.DiaCase_IDNO,
          a.DiaInsurer_IDNO,
          a.Insurer_NAME,
          a.InsurerClaim_NUMB,
          a.ClaimLoss_DATE,
          a.First_NAME,
          a.Middle_NAME,
          a.Last_NAME,
          a.MemberSsn_NUMB,
          a.Birth_DATE,
          a.Employer_NAME,
          a.InsurerAddressNormalization_CODE,
          a.InsurerLine1_ADDR,
          a.InsurerLine2_ADDR,
          a.InsurerCity_ADDR,
          a.InsurerState_ADDR,
          a.InsurerZip_ADDR,
          a.ClaimantAddressNormalization_CODE,
          a.ClaimantLine1_ADDR,
          a.ClaimantLine2_ADDR,
          a.ClaimantCity_ADDR,
          a.ClaimantState_ADDR,
          a.ClaimantZip_ADDR,
          a.EmployerAddressNormalization_CODE,
          a.EmployerLine1_ADDR,
          a.EmployerLine2_ADDR,
          a.EmployerCity_ADDR,
          a.EmployerState_ADDR,
          a.EmployerZip_ADDR
     FROM LDIAL_Y1 a
    WHERE a.Process_INDC = @Lc_ProcessN_INDC
    ORDER BY a.Seq_IDNO;
  DECLARE @Ln_DiaCur_Seq_IDNO                          NUMERIC(19),
          @Lc_DiaCur_InsuranceMatchRecordNumb_TEXT     CHAR(3),
          @Lc_DiaCur_DiaCaseIdno_TEXT                  CHAR(10),
          @Lc_DiaCur_DiaInsurerIdno_TEXT               CHAR(10),
          @Ls_DiaCur_Insurer_NAME                      VARCHAR(50),
          @Lc_DiaCur_InsurerClaimNumb_TEXT             CHAR(20),
          @Lc_DiaCur_ClaimLossDate_TEXT                CHAR(8),
          @Lc_DiaCur_First_NAME                        CHAR(20),
          @Lc_DiaCur_Middle_NAME                       CHAR(5),
          @Lc_DiaCur_Last_NAME                         CHAR(30),
          @Lc_DiaCur_MemberSsnNumb_TEXT                CHAR(9),
          @Lc_DiaCur_BirthDate_TEXT                    CHAR(8),
          @Ls_DiaCur_Employer_NAME                     VARCHAR(60),
          @Lc_DiaCur_InsurerAddressNormalization_CODE  CHAR(1),
          @Ls_DiaCur_InsurerLine1_ADDR                 VARCHAR(50),
          @Ls_DiaCur_InsurerLine2_ADDR                 VARCHAR(50),
          @Lc_DiaCur_InsurerCity_ADDR                  CHAR(28),
          @Lc_DiaCur_InsurerState_ADDR                 CHAR(2),
          @Lc_DiaCur_InsurerZip_ADDR                   CHAR(15),
          @Lc_DiaCur_ClaimantAddressNormalization_CODE CHAR(1),
          @Ls_DiaCur_ClaimantLine1_ADDR                VARCHAR(50),
          @Ls_DiaCur_ClaimantLine2_ADDR                VARCHAR(50),
          @Lc_DiaCur_ClaimantCity_ADDR                 CHAR(28),
          @Lc_DiaCur_ClaimantState_ADDR                CHAR(2),
          @Lc_DiaCur_ClaimantZip_ADDR                  CHAR(15),
          @Lc_DiaCur_EmployerAddressNormalization_CODE CHAR(1),
          @Ls_DiaCur_EmployerLine1_ADDR                VARCHAR(50),
          @Ls_DiaCur_EmployerLine2_ADDR                VARCHAR(50),
          @Lc_DiaCur_EmployerCity_ADDR                 CHAR(28),
          @Lc_DiaCur_EmployerState_ADDR                CHAR(2),
          @Lc_DiaCur_EmployerZip_ADDR                  CHAR(15),
          @Ln_CaseMemberCur_Case_IDNO                  NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO             NUMERIC(10);
  DECLARE @Ln_DiaCurMemberSsn_NUMB NUMERIC(9),
          @Ld_DiaCurClaimLoss_DATE DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION DIA_PROCESS;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;
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
    WHERE Job_ID = @Lc_Job_ID
      AND Run_DATE = @Ld_Run_DATE;

   SET @Li_RowsCount_QNTY = @@ROWCOUNT;

   IF @Li_RowsCount_QNTY = 0
    BEGIN
     SET @Ln_RestartLine_NUMB = 0;
    END;

   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Line Number = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN Dia_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   OPEN Dia_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Dia_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   FETCH NEXT FROM Dia_CUR INTO @Ln_DiaCur_Seq_IDNO, @Lc_DiaCur_InsuranceMatchRecordNumb_TEXT, @Lc_DiaCur_DiaCaseIdno_TEXT, @Lc_DiaCur_DiaInsurerIdno_TEXT, @Ls_DiaCur_Insurer_NAME, @Lc_DiaCur_InsurerClaimNumb_TEXT, @Lc_DiaCur_ClaimLossDate_TEXT, @Lc_DiaCur_First_NAME, @Lc_DiaCur_Middle_NAME, @Lc_DiaCur_Last_NAME, @Lc_DiaCur_MemberSsnNumb_TEXT, @Lc_DiaCur_BirthDate_TEXT, @Ls_DiaCur_Employer_NAME, @Lc_DiaCur_InsurerAddressNormalization_CODE, @Ls_DiaCur_InsurerLine1_ADDR, @Ls_DiaCur_InsurerLine2_ADDR, @Lc_DiaCur_InsurerCity_ADDR, @Lc_DiaCur_InsurerState_ADDR, @Lc_DiaCur_InsurerZip_ADDR, @Lc_DiaCur_ClaimantAddressNormalization_CODE, @Ls_DiaCur_ClaimantLine1_ADDR, @Ls_DiaCur_ClaimantLine2_ADDR, @Lc_DiaCur_ClaimantCity_ADDR, @Lc_DiaCur_ClaimantState_ADDR, @Lc_DiaCur_ClaimantZip_ADDR, @Lc_DiaCur_EmployerAddressNormalization_CODE, @Ls_DiaCur_EmployerLine1_ADDR, @Ls_DiaCur_EmployerLine2_ADDR, @Lc_DiaCur_EmployerCity_ADDR, @Lc_DiaCur_EmployerState_ADDR, @Lc_DiaCur_EmployerZip_ADDR;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY = -1
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   -- Fetchs each record.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 2';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

      SAVE TRANSACTION SAVEDIA_PROCESS;

      SET @Ls_BateRecord_TEXT = 'Sequence IDNO = ' + RTRIM(CAST(@Ln_DiaCur_Seq_IDNO AS VARCHAR)) + ', Insurer Match Idno = ' + @Lc_DiaCur_InsuranceMatchRecordNumb_TEXT + ', Case Idno = ' + @Lc_DiaCur_DiaCaseIdno_TEXT + ', Insurer Idno = ' + @Lc_DiaCur_DiaInsurerIdno_TEXT + ', Insurer Name = ' + @Ls_DiaCur_Insurer_NAME + ', Insurer Claim number = ' + @Lc_DiaCur_InsurerClaimNumb_TEXT + ', Claim Loss Date = ' + @Lc_DiaCur_ClaimLossDate_TEXT + ', First Name = ' + @Lc_DiaCur_First_NAME + ', Middle Name = ' + @Lc_DiaCur_Middle_NAME + ', Last Name = ' + @Lc_DiaCur_Last_NAME + ', Member SSN Number = ' + @Lc_DiaCur_MemberSsnNumb_TEXT + ', Birth Date = ' + @Lc_DiaCur_BirthDate_TEXT + ', Employer Name = ' + @Ls_DiaCur_Employer_NAME + ', Insurer Address Normalization Code = ' + @Lc_DiaCur_InsurerAddressNormalization_CODE + ', Insurer Address Line 1 = ' + @Ls_DiaCur_InsurerLine1_ADDR + ', Insurer Address Line 2 = ' + @Ls_DiaCur_InsurerLine2_ADDR + ', Insurer Address City = ' + @Lc_DiaCur_InsurerCity_ADDR + ', Insurer Address State = ' + @Lc_DiaCur_InsurerState_ADDR + ', Insurer Address Zip Code = ' + @Lc_DiaCur_InsurerZip_ADDR + ', Claimant Address Normalization Code = ' + @Lc_DiaCur_ClaimantAddressNormalization_CODE + ', Claimant Address Line 1 = ' + @Ls_DiaCur_ClaimantLine1_ADDR + ', Claimant Address Line 2 = ' + @Ls_DiaCur_ClaimantLine2_ADDR + ', Claimant Address City = ' + @Lc_DiaCur_ClaimantCity_ADDR + ', Claimant Address State = ' + @Lc_DiaCur_ClaimantState_ADDR + ', Claimant Address Zip Code = ' + @Lc_DiaCur_ClaimantZip_ADDR + ', Employer Address Normalization Code = ' + @Lc_DiaCur_EmployerAddressNormalization_CODE + ', Employer Address Line 1 = ' + @Ls_DiaCur_EmployerLine1_ADDR + ', Employer Address Line 2 = ' + @Ls_DiaCur_EmployerLine2_ADDR + ', Employer Address City = ' + @Lc_DiaCur_EmployerCity_ADDR + ', Employer Address State = ' + @Lc_DiaCur_EmployerState_ADDR + ', Employer Address Zip Code = ' + @Lc_DiaCur_EmployerZip_ADDR;
      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'DIA - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Member SSN = ' + @Lc_DiaCur_MemberSsnNumb_TEXT;
      SET @Ln_TransactionEventSeq_NUMB = 0;
      SET @Ln_OthpPartyInsurer_IDNO = 0
      SET @Lb_ErrorExpection_CODE = 0;

      IF ISNULL(@Ls_DiaCur_Insurer_NAME, @Lc_Space_TEXT) <> @Lc_Space_TEXT
         AND ISNULL(@Lc_DiaCur_MemberSsnNumb_TEXT, @Lc_Space_TEXT) <> @Lc_Space_TEXT
         AND ISNULL(@Lc_DiaCur_ClaimLossDate_TEXT, @Lc_Space_TEXT) <> @Lc_Space_TEXT
       BEGIN
         IF @Ls_DiaCur_InsurerLine1_ADDR <> @Lc_Space_TEXT
           AND @Lc_DiaCur_InsurerCity_ADDR <> @Lc_Space_TEXT
           AND @Lc_DiaCur_InsurerZip_ADDR <> @Lc_Space_TEXT
           AND @Lc_DiaCur_InsurerState_ADDR <> @Lc_Space_TEXT
          BEGIN
			IF ISNUMERIC(LTRIM(RTRIM(@Lc_DiaCur_MemberSsnNumb_TEXT))) = 1
			   AND ISNUMERIC(@Lc_DiaCur_ClaimLossDate_TEXT) = 1
			 BEGIN
			  SET @Ln_DiaCurMemberSsn_NUMB = CAST(@Lc_DiaCur_MemberSsnNumb_TEXT AS NUMERIC);
			  SET @Ld_DiaCurClaimLoss_DATE = CONVERT(DATE, @Lc_DiaCur_ClaimLossDate_TEXT, 112);
			 END
			ELSE
			 BEGIN
			  SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

			  RAISERROR (50001,16,1);
			 END

			IF EXISTS (SELECT 1
						 FROM DEMO_Y1
						WHERE MemberSsn_NUMB = @Ln_DiaCurMemberSsn_NUMB)
			   AND @Ln_DiaCurMemberSsn_NUMB > 0
			 BEGIN
			  IF EXISTS(SELECT 1
						  FROM DEMO_Y1
						 WHERE MemberSsn_NUMB = @Ln_DiaCurMemberSsn_NUMB
						 GROUP BY MemberSsn_NUMB
						HAVING COUNT(MemberSsn_NUMB) > 1)
			   BEGIN
				SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

				RAISERROR (50001,16,1);
			   END

			  IF EXISTS (SELECT 1
						   FROM DEMO_Y1
						  WHERE LEFT(Last_NAME, 5) = LEFT(@Lc_DiaCur_Last_NAME, 5)
							AND MemberSsn_NUMB = @Ln_DiaCurMemberSsn_NUMB)
			   BEGIN
				IF NOT EXISTS (SELECT 1
								 FROM CASE_Y1 c
									  JOIN CMEM_Y1 m
									   ON c.Case_IDNO = m.Case_IDNO
									  JOIN DEMO_Y1 d
									   ON d.MemberMci_IDNO = m.MemberMci_IDNO
								WHERE c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
								  AND c.TypeCase_CODE <> @Lc_TypeCaseNivd_CODE
								  AND m.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
								  AND d.MemberSsn_NUMB = @Ln_DiaCurMemberSsn_NUMB
								  AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE))
				 BEGIN
				  SET @Lc_BateError_CODE = @Lc_ErrorE0270_CODE;

				  RAISERROR (50001,16,1);
				 END
				ELSE
				 BEGIN
				  SET @Ln_MemberMci_IDNO = (SELECT MemberMci_IDNO
											  FROM DEMO_Y1
											 WHERE MemberSsn_NUMB = @Ln_DiaCurMemberSsn_NUMB
											   AND LEFT(Last_NAME, 5) = LEFT(@Lc_DiaCur_Last_NAME, 5));
				 END
	          
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
			SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpInsurer_CODE, '') + ', OtherParty_NAME = ' + ISNULL(@Ls_DiaCur_Insurer_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DiaCur_InsurerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DiaCur_InsurerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DiaCur_InsurerCity_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DiaCur_InsurerZip_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DiaCur_InsurerState_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_DiaSourceLoc_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', DchCarrier_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_DiaCur_InsurerAddressNormalization_CODE, '') + ', Process_ID = ' + ISNULL(@Lc_Space_TEXT, '');

			EXECUTE BATCH_COMMON$SP_GET_OTHP
			 @Ad_Run_DATE                     = @Ld_Run_DATE,
			 @An_Fein_IDNO                    = @Ln_Zero_NUMB,
			 @Ac_TypeOthp_CODE                = @Lc_TypeOthpInsurer_CODE,
			 @As_OtherParty_NAME              = @Ls_DiaCur_Insurer_NAME,
			 @Ac_Aka_NAME                     = @Lc_Space_TEXT,
			 @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
			 @As_Line1_ADDR                   = @Ls_DiaCur_InsurerLine1_ADDR,
			 @As_Line2_ADDR                   = @Ls_DiaCur_InsurerLine2_ADDR,
			 @Ac_City_ADDR                    = @Lc_DiaCur_InsurerCity_ADDR,
			 @Ac_Zip_ADDR                     = @Lc_DiaCur_InsurerZip_ADDR,
			 @Ac_State_ADDR                   = @Lc_DiaCur_InsurerState_ADDR,
			 @Ac_Fips_CODE                    = @Lc_Space_TEXT,
			 @Ac_Country_ADDR                 = @Lc_Country_ADDR,
			 @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
			 @An_Phone_NUMB                   = @Ln_Zero_NUMB,
			 @An_Fax_NUMB                     = @Ln_Zero_NUMB,
			 @As_Contact_EML                  = @Lc_Space_TEXT,
			 @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
			 @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
			 @An_Sein_IDNO                    = @Ln_Zero_NUMB,
			 @Ac_SourceLoc_CODE               = @Lc_DiaSourceLoc_CODE,
			 @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
			 @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
			 @Ac_Normalization_CODE           = @Lc_DiaCur_InsurerAddressNormalization_CODE,
			 @Ac_Process_ID                   = @Lc_Process_ID,
			 @An_OtherParty_IDNO              = @Ln_OthpPartyInsurer_IDNO OUTPUT,
			 @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
			 @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

			IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			 BEGIN
			  SET @Lc_BateError_Code = @Lc_ErrorE0071_CODE;

			  RAISERROR (50001,16,1);
			 END 
			ELSE 
			 IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			  BEGIN
			   RAISERROR (50001,16,1);
			  END 

			IF EXISTS (SELECT 1
						 FROM ASFN_Y1
						WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
						  AND OthpInsFin_IDNO = @Ln_OthpPartyInsurer_IDNO
						  AND ClaimLoss_DATE = @Ld_DiaCurClaimLoss_DATE)
				 BEGIN
				  IF NOT EXISTS (SELECT 1
								   FROM ASFN_Y1
								  WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
									AND OthpInsFin_IDNO = @Ln_OthpPartyInsurer_IDNO
									AND ClaimLoss_DATE = @Ld_DiaCurClaimLoss_DATE
									AND AccountAssetNo_TEXT = @Lc_DiaCur_InsurerClaimNumb_TEXT)
				   BEGIN
					IF @Lc_DiaCur_InsurerClaimNumb_TEXT = @Lc_Space_TEXT
					 BEGIN
					  SET @Lc_BateError_CODE = @Lc_ErrorE1452_CODE;

					  RAISERROR (50001,16,1);
					 END
					ELSE
					 BEGIN
					  IF EXISTS (SELECT 1
								   FROM ASFN_Y1
								  WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
									AND OthpInsFin_IDNO = @Ln_OthpPartyInsurer_IDNO
									AND ClaimLoss_DATE = @Ld_DiaCurClaimLoss_DATE
									AND AccountAssetNo_TEXT = @Lc_Space_TEXT)
					   BEGIN
						SET @Ls_Sql_TEXT = 'UPDATE ASFN_Y1 - 1';
						SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', OthpInsFin_IDNO = ' + ISNULL(CAST(@Ln_OthpPartyInsurer_IDNO AS VARCHAR), '') + ', ClaimLoss_DATE = ' + ISNULL(CAST(@Ld_DiaCurClaimLoss_DATE AS VARCHAR), '');

						UPDATE ASFN_Y1
						   SET AccountAssetNo_TEXT = @Lc_DiaCur_InsurerClaimNumb_TEXT
						 WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
						   AND OthpInsFin_IDNO = @Ln_OthpPartyInsurer_IDNO
						   AND ClaimLoss_DATE = @Ld_DiaCurClaimLoss_DATE;
					   END
					  ELSE
					   BEGIN
						SET @Lc_BateError_CODE = @Lc_ErrorE1452_CODE;

						RAISERROR (50001,16,1);
					   END
					 END
				   END
				 END
				ELSE
				 BEGIN
				  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
				  SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

				  EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
				   @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
				   @Ac_Process_ID               = @Lc_Process_ID,
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

				  SET @Ln_AssetSeq_NUMB = ISNULL((SELECT MAX(AssetSeq_NUMB)
													FROM ASFN_Y1
												   WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO), 0) + 1;
	                                               
				  SET @Ls_Sql_TEXT = 'ASFN_Y1 Data Insertion -1';
				  SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

				  INSERT INTO ASFN_Y1
							  (MemberMci_IDNO,
							   Asset_CODE,
							   AssetSeq_NUMB,
							   SourceLoc_CODE,
							   OthpInsFin_IDNO,
							   OthpAtty_IDNO,
							   Status_CODE,
							   Status_DATE,
							   AccountAssetNo_TEXT,
							   AcctType_CODE,
							   JointAcct_INDC,
							   NameAcctPrimaryNo_TEXT,
							   NameAcctSecondaryNo_TEXT,
							   ValueAsset_AMNT,
							   DescriptionNote_TEXT,
							   AssetValue_DATE,
							   LienInitiated_INDC,
							   LocateState_CODE,
							   Settlement_DATE,
							   Settlement_AMNT,
							   Potential_DATE,
							   Potential_AMNT,
							   BeginValidity_DATE,
							   EndValidity_DATE,
							   WorkerUpdate_ID,
							   Update_DTTM,
							   TransactionEventSeq_NUMB,
							   ClaimLoss_DATE)
				  SELECT @Ln_MemberMci_IDNO AS MemberMci_IDNO,
						 @Lc_AssetIns_CODE AS Asset_CODE,
						 @Ln_AssetSeq_NUMB AS AssetSeq_NUMB,
						 @Lc_DiaSourceLoc_CODE AS SourceLoc_CODE,
						 @Ln_OthpPartyInsurer_IDNO AS OthpInsFin_IDNO,
						 @Ln_Zero_NUMB AS OthpAtty_IDNO,
						 @Lc_StatusConfGoodY_CODE AS Status_CODE,
						 @Ld_Run_DATE AS Status_DATE,
						 @Lc_DiaCur_InsurerClaimNumb_TEXT AS AccountAssetNo_TEXT,
						 @Lc_TypeIncomeWc_CODE AS AcctType_CODE,
						 @Lc_Space_TEXT AS JointAcct_INDC,
						 SUBSTRING(RTRIM(LTRIM(@Lc_DiaCur_First_NAME)) + @Lc_Space_TEXT + RTRIM(LTRIM(@Lc_DiaCur_Middle_NAME)) + @Lc_Space_TEXT + RTRIM(LTRIM(@Lc_DiaCur_Last_NAME)), 1, 40) AS NameAcctPrimaryNo_TEXT,
						 @Lc_Space_TEXT AS NameAcctSecondaryNo_TEXT,
						 @Ln_Zero_NUMB AS ValueAsset_AMNT,
						 @Lc_Space_TEXT AS DescriptionNote_TEXT,
						 @Ld_Low_DATE AS AssetValue_DATE,
						 @Lc_Space_TEXT AS LienInitiated_INDC,
						 @Lc_DiaCur_ClaimantState_ADDR AS LocateState_CODE,
						 @Ld_Low_DATE AS Settlement_DATE,
						 @Ln_Zero_NUMB AS Settlement_AMNT,
						 @Ld_Low_DATE AS Potential_DATE,
						 @Ln_Zero_NUMB AS Potential_AMNT,
						 @Ld_Run_DATE AS BeginValidity_DATE,
						 @Ld_High_DATE AS EndValidity_DATE,
						 @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
						 @Ld_Start_DATE AS Update_DTTM,
						 @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
						 @Ld_DiaCurClaimLoss_DATE AS ClaimLoss_DATE;
				 END

				IF @Ln_TransactionEventSeq_NUMB = 0
				 BEGIN
				  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
				  SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

				  EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
				   @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
				   @Ac_Process_ID               = @Lc_Process_ID,
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
				 END

			IF @Ls_DiaCur_ClaimantLine1_ADDR <> ''
			 OR @Ls_DiaCur_ClaimantLine2_ADDR <> ''
			 OR @Lc_DiaCur_Claimantcity_ADDR <> ''
			 OR @Lc_DiaCur_ClaimantState_ADDR <> ''
			 OR @Lc_DiaCur_ClaimantZip_ADDR <> ''
			  BEGIN	
				SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE ';
				SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_DiaCur_ClaimantLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_DiaCur_ClaimantLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_DiaCur_Claimantcity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_DiaCur_ClaimantState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_DiaCur_ClaimantZip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_DiaSourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_PendingStatus_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceLocA_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Ls_DescriptionServiceDirection_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_DiaCur_ClaimantAddressNormalization_CODE, '');

				EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
				 @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
				 @Ad_Run_DATE                         = @Ld_Run_DATE,
				 @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
				 @Ad_Begin_DATE                       = @Ld_Run_DATE,
				 @Ad_End_DATE                         = @Ld_High_DATE,
				 @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
				 @As_Line1_ADDR                       = @Ls_DiaCur_ClaimantLine1_ADDR,
				 @As_Line2_ADDR                       = @Ls_DiaCur_ClaimantLine2_ADDR,
				 @Ac_City_ADDR                        = @Lc_DiaCur_Claimantcity_ADDR,
				 @Ac_State_ADDR                       = @Lc_DiaCur_ClaimantState_ADDR,
				 @Ac_Zip_ADDR                         = @Lc_DiaCur_ClaimantZip_ADDR,
				 @Ac_Country_ADDR                     = @Lc_Country_ADDR,
				 @An_Phone_NUMB                       = @Ln_Zero_NUMB,
				 @Ac_SourceLoc_CODE                   = @Lc_DiaSourceLoc_CODE,
				 @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
				 @Ad_Status_DATE                      = @Ld_Run_DATE,
				 @Ac_Status_CODE                      = @Lc_PendingStatus_CODE,
				 @Ac_SourceVerified_CODE              = @Lc_SourceLocA_CODE,
				 @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
				 @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
				 @Ac_Process_ID                       = @Lc_Process_ID,
				 @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
				 @An_TransactionEventSeq_NUMB         = @Ln_TransactionEventSeq_NUMB,
				 @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
				 @Ac_Normalization_CODE               = @Lc_DiaCur_ClaimantAddressNormalization_CODE,
				 @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
				 @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

				IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				 BEGIN
				  RAISERROR (50001,16,1);
				 END;
				ELSE IF @Lc_Msg_CODE NOT IN (@Lc_StatusSuccess_CODE,@Lc_ErrorE1089_CODE)
				 BEGIN
				  SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
				  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1, ADDRESS UPDATE ';
				  SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_Msg_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

				  EXECUTE BATCH_COMMON$SP_BATE_LOG
				   @As_Process_NAME             = @Ls_Process_NAME,
				   @As_Procedure_NAME           = @Ls_Procedure_NAME,
				   @Ac_Job_ID                   = @Lc_Job_ID,
				   @Ad_Run_DATE                 = @Ld_Run_DATE,
				   @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
				   @An_Line_NUMB                = @Ln_RestartLine_NUMB,
				   @Ac_Error_CODE               = @Lc_Msg_CODE,
				   @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
				   @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
				   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				   @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

				  IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
				   BEGIN
					SET @Lb_ErrorExpection_CODE = 1;
				   END
				  ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				   BEGIN
					RAISERROR (50001,16,1);
				   END
				 END
			END

			IF @Ln_OthpPartyInsurer_IDNO <> 0
				BEGIN
				  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE -3, INSURER AGENCY ID';
				  SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OthpPartyInsurer_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusConfGoodY_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_TypeIncomeWc_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceLocA_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_DiaSourceLoc_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

				  EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
				   @An_MemberMci_IDNO             = @Ln_MemberMci_IDNO,
				   @An_OthpPartyEmpl_IDNO         = @Ln_OthpPartyInsurer_IDNO,
				   @Ad_SourceReceived_DATE        = @Ld_Run_DATE,
				   @Ac_Status_CODE                = @Lc_StatusConfGoodY_CODE,
				   @Ad_Status_DATE                = @Ld_Run_DATE,
				   @Ac_TypeIncome_CODE            = @Lc_TypeIncomeWc_CODE,
				   @Ac_SourceLocConf_CODE         = @Lc_SourceLocA_CODE,
				   @Ad_Run_DATE                   = @Ld_Run_DATE,
				   @Ad_BeginEmployment_DATE       = @Ld_Run_DATE,
				   @Ad_EndEmployment_DATE         = @Ld_High_DATE,
				   @An_IncomeGross_AMNT           = @Ln_Zero_NUMB,
				   @An_IncomeNet_AMNT             = @Ln_Zero_NUMB,
				   @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
				   @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
				   @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
				   @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
				   @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
				   @Ac_SourceLoc_CODE             = @Lc_DiaSourceLoc_CODE,
				   @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
				   @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
				   @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
				   @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
				   @An_CostInsurance_AMNT         = @Ln_Zero_NUMB,
				   @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
				   @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
				   @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
				   @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
				   @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
				   @Ac_Process_ID                 = @Lc_Process_ID,
				   @An_OfficeSignedOn_IDNO        = @Ln_Zero_NUMB,
				   @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
				   @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

				  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				   BEGIN
					RAISERROR (50001,16,1);
				   END;
				END
				
				  DECLARE CaseMember_Cur INSENSITIVE CURSOR FOR
				   SELECT a.Case_IDNO,
						  a.MemberMci_IDNO
					 FROM CMEM_Y1 a,
						  CASE_Y1 b
					WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
					  AND a.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
					  AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
					  AND a.Case_IDNO = B.Case_IDNO
					  AND B.StatusCase_CODE = @Lc_OpenStatusCase_CODE
					ORDER BY a.Case_IDNO;

				  SET @Ls_Sql_TEXT = 'OPEN CaseMember_Cur';
				  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

				  OPEN CaseMember_Cur;

				  SET @Ls_Sql_TEXT = 'FETCH CaseMember_Cur - 1';
				  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR);

				  FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

				  SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

				  -- Fetch each case of the member.
				  WHILE @Li_FetchStatus_QNTY = 0
				   BEGIN
					SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY ';
					SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorRedia_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', DescriptionNote_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarcodeIn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

					EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
					 @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
					 @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
					 @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
					 @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRedia_CODE,
					 @Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
					 @As_DescriptionNote_TEXT     = @Lc_Space_TEXT,
					 @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
					 @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
					 @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
					 @Ac_WorkerDelegate_ID        = @Lc_WorkerDelegate_ID,
					 @Ac_SignedonWorker_ID        = @Lc_Space_TEXT,
					 @Ad_Run_DATE                 = @Ld_Run_DATE,
					 @Ac_TypeReference_CODE       = @Lc_TypeReference_IDNO,
					 @Ac_Reference_ID             = @Lc_Reference_ID,
					 @Ac_Notice_ID                = @Lc_Notice_ID,
					 @An_TopicIn_IDNO             = @Ln_TopicIn_IDNO,
					 @Ac_Job_ID                   = @Lc_Job_ID,
					 @As_Xml_TEXT                 = @Ls_XmlTextIn_TEXT,
					 @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
					 @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
					 @An_Schedule_NUMB            = @Ln_Schedule_NUMB,
					 @Ad_Schedule_DATE            = @Ld_Low_DATE,
					 @Ad_BeginSch_DTTM            = @Ld_BeginSch_DTTM,
					 @An_OthpLocation_IDNO        = @Ln_OthpLocation_IDNO,
					 @Ac_ScheduleWorker_ID        = @Lc_Schedule_Worker_IDNO,
					 @As_ScheduleListMemberMci_ID = @Lc_Schedule_Member_IDNO,
					 @An_OthpSource_IDNO          = @Ln_OthpSource_IDNO,
					 @Ac_IVDOutOfStateFips_CODE   = @Lc_OthStateFips_CODE,
					 @An_TransHeader_IDNO         = @Ln_Schedule_NUMB,
					 @An_OrderSeq_NUMB            = @Ln_Zero_NUMB,
					 @An_BarcodeIn_NUMB           = @Ln_Zero_NUMB,
					 @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
					 @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
					 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

					IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					 BEGIN
					  RAISERROR (50001,16,1);
					 END;

					IF EXISTS (SELECT 1
								 FROM ACEN_Y1 a
								WHERE a.Case_IDNO = @Ln_CaseMemberCur_Case_IDNO
								  AND a.StatusEnforce_CODE = @Lc_StatusEnforceO_CODE
								  AND a.EndValidity_DATE = @Ld_High_DATE)
					 AND @Lc_DiaCur_InsurerClaimNumb_TEXT <> @Lc_Space_TEXT
					 BEGIN
					  SET @Ln_OrderSeq_NUMB = (SELECT MAX(OrderSeq_NUMB)
												 FROM ACEN_Y1 a
												WHERE a.Case_IDNO = @Ln_CaseMemberCur_Case_IDNO
												  AND a.StatusEnforce_CODE = @Lc_StatusEnforceO_CODE
												  AND a.EndValidity_DATE = @Ld_High_DATE);
					  SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ELFC';
					  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpPartyInsurer_IDNO AS VARCHAR), '') + ', TypeChange_CODE = ' + ISNULL(@Lc_TypeChangeLi_CODE, '') + ', NegPos_CODE = ' + ISNULL(@Lc_NegPosP_CODE, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Create_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TypeReference_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reference_ID = ' + ISNULL(@Lc_DiaCur_InsurerClaimNumb_TEXT, '');

					  EXECUTE BATCH_COMMON$SP_INSERT_ELFC
					   @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
					   @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
					   @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
					   @An_OthpSource_IDNO          = @Ln_OthpPartyInsurer_IDNO,
					   @Ac_TypeChange_CODE          = @Lc_TypeChangeLi_CODE,
					   @Ac_NegPos_CODE              = @Lc_NegPosP_CODE,
					   @Ac_Process_ID               = @Lc_Process_ID,
					   @Ad_Create_DATE              = @Ld_Run_DATE,
					   @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
					   @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
					   @Ac_TypeReference_CODE       = @Lc_AssetIns_CODE,
					   @Ac_Reference_ID             = @Lc_DiaCur_InsurerClaimNumb_TEXT,
					   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
					   @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

					  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
					   BEGIN
						SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

						RAISERROR (50001,16,1);
					   END;
					 END

					SET @Ls_Sql_TEXT = 'FETCH CaseMember_Cur - 2';
					SET @Ls_Sqldata_TEXT = 'Cursor CaseMember_Cur Previous Record Case_IDNO = ' + CAST (@Ln_CaseMemberCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR);

					FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

					SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				   END;

				  CLOSE CaseMember_Cur;

				  DEALLOCATE CaseMember_Cur;
				 END

				IF @Lb_ErrorExpection_CODE = 1
				 BEGIN
				  SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
				 END
			 END
         END
	   END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEDIA_PROCESS;
        END
       ELSE
        BEGIN
         SET @Ls_DescriptionError_TEXT = @Ls_DescriptionError_TEXT + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

       IF CURSOR_STATUS ('LOCAL', 'CaseMember_Cur') IN (0, 1)
        BEGIN
         CLOSE CaseMember_Cur;

         DEALLOCATE CaseMember_Cur;
        END

       SET @Ln_Error_NUMB = ERROR_NUMBER ();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
       SET @Ls_Sqldata_TEXT = 'Member SSN = ' + RTRIM(CAST(@Lc_DiaCur_MemberSsnNumb_TEXT AS VARCHAR));
       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_StatusSuccess_CODE, @Lc_Space_TEXT)
        BEGIN
         SET @Lc_Msg_CODE = @Lc_BateError_CODE;
        END

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
        @An_Line_NUMB                = @Ln_RestartLine_NUMB,
        @Ac_Error_CODE               = @Lc_Msg_CODE,
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

     SET @Ls_Sql_TEXT = 'UPDATE LDIAL_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_DiaCur_Seq_IDNO AS VARCHAR);

     UPDATE LDIAL_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_DiaCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY = @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS NVARCHAR (MAX)), '') + ', RESTART KEY = ' + ISNULL (CAST (@Ln_RecordCount_QNTY AS NVARCHAR (MAX)), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       COMMIT TRANSACTION DIA_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       BEGIN TRANSACTION DIA_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;

       COMMIT TRANSACTION DIA_PROCESS;

       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Dia_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Dia_CUR INTO @Ln_DiaCur_Seq_IDNO, @Lc_DiaCur_InsuranceMatchRecordNumb_TEXT, @Lc_DiaCur_DiaCaseIdno_TEXT, @Lc_DiaCur_DiaInsurerIdno_TEXT, @Ls_DiaCur_Insurer_NAME, @Lc_DiaCur_InsurerClaimNumb_TEXT, @Lc_DiaCur_ClaimLossDate_TEXT, @Lc_DiaCur_First_NAME, @Lc_DiaCur_Middle_NAME, @Lc_DiaCur_Last_NAME, @Lc_DiaCur_MemberSsnNumb_TEXT, @Lc_DiaCur_BirthDate_TEXT, @Ls_DiaCur_Employer_NAME, @Lc_DiaCur_InsurerAddressNormalization_CODE, @Ls_DiaCur_InsurerLine1_ADDR, @Ls_DiaCur_InsurerLine2_ADDR, @Lc_DiaCur_InsurerCity_ADDR, @Lc_DiaCur_InsurerState_ADDR, @Lc_DiaCur_InsurerZip_ADDR, @Lc_DiaCur_ClaimantAddressNormalization_CODE, @Ls_DiaCur_ClaimantLine1_ADDR, @Ls_DiaCur_ClaimantLine2_ADDR, @Lc_DiaCur_ClaimantCity_ADDR, @Lc_DiaCur_ClaimantState_ADDR, @Lc_DiaCur_ClaimantZip_ADDR, @Lc_DiaCur_EmployerAddressNormalization_CODE, @Ls_DiaCur_EmployerLine1_ADDR, @Ls_DiaCur_EmployerLine2_ADDR, @Lc_DiaCur_EmployerCity_ADDR, @Lc_DiaCur_EmployerState_ADDR, @Lc_DiaCur_EmployerZip_ADDR;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Lc_BateError_CODE = @Lc_ErrorE0944_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorE_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

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

   CLOSE Dia_CUR;

   DEALLOCATE Dia_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

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

   SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 3';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION DIA_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DIA_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'Dia_CUR') IN (0, 1)
    BEGIN
     CLOSE Dia_CUR;

     DEALLOCATE Dia_CUR;
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
