/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_DMDC_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_DMDC_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure reads the the DMDC (Defense Manpower Data Center)
                       details from the temporary table LOAD_FCR_DMDC_DETAILS
                       and look for the NCP.  If matching is found,
                       then the insurance details are updated in MINS_Y1
                       and DINS_Y1 tables.
                       FCR sends proactive DMDC matches on a quarterly basis.
Frequency			 : Daily
Developed On		 : 04/10/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_COMMON$SP_MINS_UPDATE
					   BATCH_COMMON$SP_DINS_UPDATE
					   BATCH_COMMON$SP_BATE_LOG
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_DMDC_DETAILS]
 @Ac_Job_ID                  CHAR(7),
 @Ad_Run_DATE                DATE,
 @As_Process_NAME            VARCHAR(100),
 @An_CommitFreq_QNTY         NUMERIC(5),
 @An_ExceptionThreshold_QNTY NUMERIC(5),
 @An_ProcessedRecordCount_QNTY NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE                CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_NoValue_CODE                    CHAR(1) = 'N',
           @Lc_CaseStatusOpen_CODE             CHAR(1) = 'O',
           @Lc_RelationshipCaseDp_TEXT         CHAR(1) = 'D',
           @Lc_StatusCaseMemberActive_CODE     CHAR(1) = 'A',
           @Lc_VerificationStatusGood_CODE     CHAR(1) = 'Y',
           @Lc_RelationshipCaseNcp_TEXT        CHAR(1) = 'A',
           @Lc_RelationshipCasePutFather_TEXT  CHAR(1) = 'P',
           @Lc_RelationshipCaseCp_TEXT         CHAR(1) = 'C',
           @Lc_Yes_INDC                        CHAR(1) = 'Y',
           @Lc_ProcessY_INDC                   CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_ErrorTypeError_CODE             CHAR(1) = 'E',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_MedCoverageSponserOth_TEXT      CHAR(1) = '4',
           @Lc_MedCoverageSponserNcp_TEXT      CHAR(1) = '1',
           @Lc_MedCoverageSponserCp_TEXT       CHAR(1) = '2',
           @Lc_MedCoverageSponserPf_TEXT       CHAR(1) = '3',
           @Lc_Note_INDC					   CHAR(1) = 'N',
           @Lc_RelationshipSelf_CODE           CHAR(2) = 'SF',
           @Lc_RelationshipOther_TEXT          CHAR(2) = 'OT',
           @Lc_SubsystemLoc_CODE			   CHAR(3) = 'LO',
           @Lc_InsuranceSourceFc_CODE          CHAR(3) = 'FC',
           @Lc_MajorActivityCase_CODE		   CHAR(4) = 'CASE',
           @Lc_ErrorE1072_CODE                 CHAR(5) = 'E1072',
           @Lc_ErrorE1176_CODE                 CHAR(5) = 'E1176',
           @Lc_ErrorE0888_CODE                 CHAR(5) = 'E0888',
           @Lc_ErrorE0145_CODE                 CHAR(5) = 'E0145',
           @Lc_ErrorE0894_CODE                 CHAR(5) = 'E0894',
           @Lc_ErrorE1088_CODE                 CHAR(5) = 'E1088',
           @Lc_BateErrorE1424_CODE             CHAR(5) = 'E1424',
           @Lc_MinorActivityRrfcr_CODE		   CHAR(5) = 'RRFCR',
           @Lc_ProcessFcrDmdc_ID               CHAR(8) = 'FCR_DMDC',
           @Lc_NoInsuranceGroup_TEXT           CHAR(25) = 'TRI CARE',
           @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME                  VARCHAR(60) = 'SP_DMDC_DETAILS',
           @Ld_High_DATE                       DATE = '12/31/9999',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB                       NUMERIC(1) = 0,
           @Ln_CommitFreq_QNTY                 NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY         NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY	   NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
           @Ln_OtherParty_IDNO                 NUMERIC(9) = 0,
           @Ln_PolicyHolderSsn_NUMB            NUMERIC(9) = 0,
           @Ln_MemberSsn_TEXT                  NUMERIC(9) = 0,
           @Ln_Cur_QNTY                        NUMERIC(10,0) = 0,
           @Ln_EventFunctionalSeq_NUMB		   NUMERIC(10) = 0,
           @Ln_ChildMCI_IDNO                   NUMERIC(10) = 0,
           @Ln_MemberMci_IDNO                  NUMERIC(10) = 0,
           @Ln_Exists_NUMB                     NUMERIC(10) = 0,
           @Ln_Topic_IDNO					   NUMERIC(10) = 0,
           @Ln_Error_NUMB                      NUMERIC(11),
           @Ln_ErrorLine_NUMB                  NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB		   NUMERIC(19),
           @Li_FetchStatus_QNTY                SMALLINT,
           @Li_RowCount_QNTY                   SMALLINT,
           @Lc_Space_TEXT                      CHAR(1) = '',
           @Lc_TypeError_CODE                  CHAR(1) = '',
           @Lc_Msg_CODE                        CHAR(5) = '',
           @Lc_BateError_CODE                  CHAR(5) = '',
           @Lc_RelationshipPolicyHolder_CODE   CHAR(9),
           @Lc_NoPolicyInsMins_TEXT            CHAR(20),
           @Lc_NoInsuranceGroupMins_TEXT       CHAR(25),
           @Ls_PolicyHolder_NAME               VARCHAR(62),
           @Ls_Sql_TEXT                        VARCHAR(100),
           @Ls_CursorLoc_TEXT                  VARCHAR(200),
           @Ls_Sqldata_TEXT                    VARCHAR(1000),
           @Ls_BateRecord_TEXT                 VARCHAR(4000) = '',
           @Ls_DescriptionError_TEXT           VARCHAR(4000),
           @Ls_ErrorMessage_TEXT               VARCHAR(4000),
           @Ld_DmdcCoverageBegin_DATE          DATE,
           @Ld_DmdcCoverageEnd_DATE			   DATE,
           @Lb_MinsUpdate_CODE                 BIT = 0,
           @Lb_DinsUpdate_CODE                 BIT = 0;

  DECLARE FcrDmdcLoc_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.Rec_ID,
          a.StateTransmitter_CODE,
          a.County_IDNO,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.Case_IDNO, '')))) = 0
            THEN '0'
           ELSE a.Case_IDNO
          END AS Case_IDNO,
          a.Order_INDC,
          a.FirstCh_NAME,
          a.MiddledCh_NAME,
          a.LastCh_NAME AS name_last_ch,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.ChildSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE a.ChildSsn_NUMB
          END AS ChildSsn_NUMB,
          a.SsnVerifiedCh_INDC,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.ChildMCI_IDNO, '')))) = 0
            THEN '0'
           ELSE a.ChildMCI_IDNO
          END AS ChildMCI_IDNO,
          a.DeathCh_INDC,
          a.MedCoverageCh_INDC,
          a.MedCoverageSponsorCh_INDC,
          CONVERT(DATETIME, dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.BeginCoverageCh_DATE), 112) AS dt_beg_coverage,
          CONVERT(DATETIME, dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(a.EndCoverageCh_DATE), 112) AS dt_end_coverage,
          a.FirstNcp_NAME,
          a.MiddleNcp_NAME,
          a.LastNcp_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.NcpSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE a.NcpSsn_NUMB
          END AS NcpSsn_NUMB,
          a.SsnVerifiedNcp_INDC,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.NcpMci_IDNO, '')))) = 0
            THEN '0'
           ELSE a.NcpMci_IDNO
          END AS NcpMci_IDNO,
          a.DeathNcp_INDC,
          a.MedCoverageNcp_INDC,
          a.FirstPf_NAME,
          a.MiddlePf_NAME,
          a.LastPf_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.PfSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE a.PfSsn_NUMB
          END AS PfSsn_NUMB,
          a.SsnVerifiedPf_INDC,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.PfMci_IDNO, '')))) = 0
            THEN '0'
           ELSE a.PfMci_IDNO
          END AS PfMci_IDNO,
          a.DeathPf_INDC,
          a.MedCoveragePf_INDC,
          a.FirstCp_NAME,
          a.MiddleCp_NAME,
          a.LastCp_NAME,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.CpSsn_NUMB, '')))) = 0
            THEN '0'
           ELSE a.CpSsn_NUMB
          END AS CpSsn_NUMB,
          a.SsnVerifiedCp_INDC,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(a.CpMci_IDNO, '')))) = 0
            THEN '0'
           ELSE a.CpMci_IDNO
          END AS CpMci_IDNO,
          a.DeathCp_INDC,
          a.MedCoverageCp_INDC
     FROM LFDMD_Y1 a
    WHERE a.Process_INDC = 'N';
  DECLARE @Ln_FcrDmdcLocCur_Seq_IDNO                  NUMERIC(19),
          @Lc_FcrDmdcLocCur_Rec_ID                    CHAR(2),
          @Lc_FcrDmdcLocCur_StateTransmitter_CODE     CHAR(2),
          @Lc_FcrDmdcLocCur_County_IDNO               CHAR(3),
          @Lc_FcrDmdcLocCur_CaseIdno_TEXT             CHAR(6),
          @Lc_FcrDmdcLocCur_Order_INDC                CHAR(1),
          @Lc_FcrDmdcLocCur_FirstCh_NAME              CHAR(16),
          @Lc_FcrDmdcLocCur_MidCh_NAME                CHAR(16),
          @Lc_FcrDmdcLocCur_LastCh_NAME               CHAR(30),
          @Lc_FcrDmdcLocCur_ChildSsnNumb_TEXT         CHAR(9),
          @Lc_FcrDmdcLocCur_SsnVerifiedCh_INDC        CHAR(1),
          @Lc_FcrDmdcLocCur_ChildMciIdno_TEXT         CHAR(10),
          @Lc_FcrDmdcLocCur_DeathCh_INDC              CHAR(1),
          @Lc_FcrDmdcLocCur_MedCoverageCh_INDC        CHAR(1),
          @Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC CHAR(1),
          @Ld_FcrDmdcLocCur_BegCoverage_DATE          DATE,
          @Ld_FcrDmdcLocCur_EndCoverage_DATE          DATE,
          @Lc_FcrDmdcLocCur_FirstNcp_NAME             CHAR(16),
          @Lc_FcrDmdcLocCur_MiddleNcp_NAME            CHAR(16),
          @Lc_FcrDmdcLocCur_LastNcp_NAME              CHAR(30),
          @Lc_FcrDmdcLocCur_NcpSsnNumb_TEXT           CHAR(9),
          @Lc_FcrDmdcLocCur_SsnVerifiedNcp_INDC       CHAR(1),
          @Lc_FcrDmdcLocCur_NcpMciIdno_TEXT		      CHAR(10),
          @Lc_FcrDmdcLocCur_DeathNcp_INDC             CHAR(1),
          @Lc_FcrDmdcLocCur_MedCoverageNcp_INDC       CHAR(1),
          @Lc_FcrDmdcLocCur_FirstPf_NAME              CHAR(16),
          @Lc_FcrDmdcLocCur_MiddlePf_NAME             CHAR(16),
          @Lc_FcrDmdcLocCur_LastPf_NAME               CHAR(30),
          @Lc_FcrDmdcLocCur_PfSsnNumb_TEXT            CHAR(9),
          @Lc_FcrDmdcLocCur_SsnVerifiedPf_INDC        CHAR(1),
          @Lc_FcrDmdcLocCur_PfMciIdno_TEXT            CHAR(10),
          @Lc_FcrDmdcLocCur_DeathPf_INDC              CHAR(1),
          @Lc_FcrDmdcLocCur_MedCoveragePf_INDC        CHAR(1),
          @Lc_FcrDmdcLocCur_FirstCp_NAME              CHAR(16),
          @Lc_FcrDmdcLocCur_MiddleCp_NAME             CHAR(16),
          @Lc_FcrDmdcLocCur_LastCp_NAME               CHAR(30),
          @Lc_FcrDmdcLocCur_CpSsnNumb_TEXT            CHAR(9),
          @Lc_FcrDmdcLocCur_SsnVerifiedCp_INDC        CHAR(1),
          @Lc_FcrDmdcLocCur_CpMciIdno_TEXT            CHAR(10),
          @Lc_FcrDmdcLocCur_DeathCp_INDC              CHAR(1),
          @Lc_FcrDmdcLocCur_MedCoverageCp_INDC        CHAR(1),
          
          @Ln_FcrDmdcLocCur_Case_IDNO				  NUMERIC(6),
          @Ln_FcrDmdcLocCur_ChildSsn_NUMB			  NUMERIC(9),
          @Ln_FcrDmdcLocCur_ChildMci_IDNO			  NUMERIC(10),
          @Ln_FcrDmdcLocCur_NcpSsn_NUMB				  NUMERIC(9),
          @Ln_FcrDmdcLocCur_NcpMci_IDNO				  NUMERIC(10),
          @Ln_FcrDmdcLocCur_PfSsn_NUMB				  NUMERIC(9),
          @Ln_FcrDmdcLocCur_PfMci_IDNO				  NUMERIC(10),
          @Ln_FcrDmdcLocCur_CpSsn_NUMB				  NUMERIC(9),
          @Ln_FcrDmdcLocCur_CpMci_IDNO				  NUMERIC(10);

  BEGIN TRY
   BEGIN TRANSACTION DMDC_DETAILS;

   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = ISNULL(@Ln_Cur_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL(@An_ExceptionThreshold_QNTY, 0);
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   SET @An_CommitFreq_QNTY = ISNULL(@An_CommitFreq_QNTY, 0);
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_ErrorMessage_TEXT = @Lc_Space_TEXT;
   SET @Lc_Msg_CODE = @Lc_Space_TEXT;
   SET @Ln_CommitFreq_QNTY = @Ln_Zero_NUMB;
   SET @Ln_Cur_QNTY = 0;
   SET @Ls_Sql_TEXT = 'DMDC LOC  OPEN CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   OPEN FcrDmdcLoc_CUR;

   SET @Ls_Sql_TEXT = 'DMDC LOC  FETCH CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   FETCH NEXT FROM FcrDmdcLoc_CUR INTO @Ln_FcrDmdcLocCur_Seq_IDNO, @Lc_FcrDmdcLocCur_Rec_ID, @Lc_FcrDmdcLocCur_StateTransmitter_CODE, @Lc_FcrDmdcLocCur_County_IDNO, @Lc_FcrDmdcLocCur_CaseIdno_TEXT, @Lc_FcrDmdcLocCur_Order_INDC, @Lc_FcrDmdcLocCur_FirstCh_NAME, @Lc_FcrDmdcLocCur_MidCh_NAME, @Lc_FcrDmdcLocCur_LastCh_NAME, @Lc_FcrDmdcLocCur_ChildSsnNumb_TEXT, @Lc_FcrDmdcLocCur_SsnVerifiedCh_INDC, @Lc_FcrDmdcLocCur_ChildMciIdno_TEXT, @Lc_FcrDmdcLocCur_DeathCh_INDC, @Lc_FcrDmdcLocCur_MedCoverageCh_INDC, @Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC, @Ld_FcrDmdcLocCur_BegCoverage_DATE, @Ld_FcrDmdcLocCur_EndCoverage_DATE, @Lc_FcrDmdcLocCur_FirstNcp_NAME, @Lc_FcrDmdcLocCur_MiddleNcp_NAME, @Lc_FcrDmdcLocCur_LastNcp_NAME, @Lc_FcrDmdcLocCur_NcpSsnNumb_TEXT, @Lc_FcrDmdcLocCur_SsnVerifiedNcp_INDC, @Lc_FcrDmdcLocCur_NcpMciIdno_TEXT, @Lc_FcrDmdcLocCur_DeathNcp_INDC, @Lc_FcrDmdcLocCur_MedCoverageNcp_INDC, @Lc_FcrDmdcLocCur_FirstPf_NAME, @Lc_FcrDmdcLocCur_MiddlePf_NAME, @Lc_FcrDmdcLocCur_LastPf_NAME, @Lc_FcrDmdcLocCur_PfSsnNumb_TEXT, @Lc_FcrDmdcLocCur_SsnVerifiedPf_INDC, @Lc_FcrDmdcLocCur_PfMciIdno_TEXT, @Lc_FcrDmdcLocCur_DeathPf_INDC, @Lc_FcrDmdcLocCur_MedCoveragePf_INDC, @Lc_FcrDmdcLocCur_FirstCp_NAME, @Lc_FcrDmdcLocCur_MiddleCp_NAME, @Lc_FcrDmdcLocCur_LastCp_NAME, @Lc_FcrDmdcLocCur_CpSsnNumb_TEXT, @Lc_FcrDmdcLocCur_SsnVerifiedCp_INDC, @Lc_FcrDmdcLocCur_CpMciIdno_TEXT, @Lc_FcrDmdcLocCur_DeathCp_INDC, @Lc_FcrDmdcLocCur_MedCoverageCp_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process FCR dmdc records in the loop
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
	 SAVE TRANSACTION SAVEDMDC_DETAILS;
     
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     SET @Lb_MinsUpdate_CODE =  0;
     SET @Lb_DinsUpdate_CODE =  0;
     IF ISNUMERIC (@Lc_FcrDmdcLocCur_CaseIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_Case_IDNO = @Lc_FcrDmdcLocCur_CaseIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_Case_IDNO = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC (@Lc_FcrDmdcLocCur_ChildSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_ChildSsn_NUMB = @Lc_FcrDmdcLocCur_ChildSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_ChildSsn_NUMB = @Ln_Zero_NUMB;
		END
	 IF ISNUMERIC (@Lc_FcrDmdcLocCur_ChildMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_ChildMci_IDNO = @Lc_FcrDmdcLocCur_ChildMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_ChildMci_IDNO = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC (@Lc_FcrDmdcLocCur_NcpSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_NcpSsn_NUMB = @Lc_FcrDmdcLocCur_NcpSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_NcpSsn_NUMB = @Ln_Zero_NUMB;
		END
					
     IF ISNUMERIC (@Lc_FcrDmdcLocCur_NcpMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_NcpMci_IDNO = @Lc_FcrDmdcLocCur_NcpMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_NcpMci_IDNO = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC (@Lc_FcrDmdcLocCur_PfSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_PfSsn_NUMB = @Lc_FcrDmdcLocCur_PfSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_PfSsn_NUMB = @Ln_Zero_NUMB;
		END	
		
     IF ISNUMERIC (@Lc_FcrDmdcLocCur_PfMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_PfMci_IDNO = @Lc_FcrDmdcLocCur_PfMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_PfMci_IDNO = @Ln_Zero_NUMB;
		END	
	 
	 IF ISNUMERIC (@Lc_FcrDmdcLocCur_CpSsnNumb_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_CpSsn_NUMB = @Lc_FcrDmdcLocCur_CpSsnNumb_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_CpSsn_NUMB = @Ln_Zero_NUMB;
		END	
	 
	 IF ISNUMERIC (@Lc_FcrDmdcLocCur_CpMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrDmdcLocCur_CpMci_IDNO = @Lc_FcrDmdcLocCur_CpMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrDmdcLocCur_CpMci_IDNO = @Ln_Zero_NUMB;
		END	
		
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Ls_CursorLoc_TEXT = 'ID_MEMBER_CHILD: ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_ChildMci_IDNO AS VARCHAR(10)), 0) + ' NcpMci_IDNO: ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_NcpMci_IDNO AS VARCHAR(10)), 0) + ' PfMci_IDNO: ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_PfMci_IDNO AS VARCHAR(10)), 0) + ' CpMci_IDNO: ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_CpMci_IDNO AS VARCHAR(10)), 0) + ' Case_IDNO: ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(6)), 0) + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), 0);
     
     SET @Ls_BateRecord_TEXT = ' Rec_ID = ' + ISNULL(@Lc_FcrDmdcLocCur_Rec_ID, '') + ', StateTransmitter_CODE = ' + ISNULL(@Lc_FcrDmdcLocCur_StateTransmitter_CODE, '') + ', County_IDNO = ' + ISNULL(@Lc_FcrDmdcLocCur_County_IDNO, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(10)), 0) + ', Order_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_Order_INDC, '') + ', FirstCh_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_FirstCh_NAME, '') + ', MidCh_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_MidCh_NAME, '') + ', NAME_LAST_CH = ' + ISNULL(@Lc_FcrDmdcLocCur_LastCh_NAME, '') + ', ChildSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_ChildSsn_NUMB AS VARCHAR(9)), 0) + ', SsnVerifiedCh_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_SsnVerifiedCh_INDC, '') + ', ChildMCI_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_ChildMci_IDNO AS VARCHAR(10)), 0) + ', DeathCh_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_DeathCh_INDC, '') + ', MedCoverageCh_INDC = ' + ISNULL (@Lc_FcrDmdcLocCur_MedCoverageCh_INDC, '') + ', MedCoverageSponsorCh_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC, '') + ', BeginCoverageCh_DATE = ' + ISNULL(CAST(@Ld_FcrDmdcLocCur_BegCoverage_DATE AS VARCHAR(10)), '') + ', EndCoverageCh_DATE = ' + ISNULL (CAST(@Ld_FcrDmdcLocCur_EndCoverage_DATE AS VARCHAR(10)), '') + ', FirstNcp_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_FirstNcp_NAME, '') + ', MiddleNcp_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_MiddleNcp_NAME, '') + ', LastNcp_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_LastNcp_NAME, '') + ', NcpSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_NcpSsn_NUMB AS VARCHAR(9)), 0) + ', SsnVerifiedNcp_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_SsnVerifiedNcp_INDC, '') + ', NcpMci_IDNO = ' + ISNULL (CAST(@Ln_FcrDmdcLocCur_NcpMci_IDNO AS VARCHAR(10)), 0) + ', DeathNcp_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_DeathNcp_INDC, '') + ', MedCoverageNcp_INDC = ' + ISNULL (@Lc_FcrDmdcLocCur_MedCoverageNcp_INDC, '') + ', FirstPf_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_FirstPf_NAME, '') + ', MiddlePf_NAME = ' + ISNULL (@Lc_FcrDmdcLocCur_MiddlePf_NAME, '') + ', LastPf_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_LastPf_NAME, '') + ', PfSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_PfSsn_NUMB AS VARCHAR(9)), 0) + ', SsnVerifiedPf_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_SsnVerifiedPf_INDC, '') + ', PfMci_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_PfMci_IDNO AS VARCHAR(10)), 0) + ', DeathPf_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_DeathPf_INDC, '') + ', MedCoveragePf_INDC = ' + ISNULL (@Lc_FcrDmdcLocCur_MedCoveragePf_INDC, '') + ', FirstCp_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_FirstCp_NAME, '') + ', MiddleCp_NAME = ' + ISNULL (@Lc_FcrDmdcLocCur_MiddleCp_NAME, '') + ', LastCp_NAME = ' + ISNULL(@Lc_FcrDmdcLocCur_LastCp_NAME, '') + ', CpSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_CpSsn_NUMB AS VARCHAR(9)), 0) + ', SsnVerifiedCp_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_SsnVerifiedCp_INDC, '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_CpMci_IDNO AS VARCHAR(10)), 0) + ', DeathCp_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_DeathCp_INDC, '') + ', MedCoverageCp_INDC = ' + ISNULL (@Lc_FcrDmdcLocCur_MedCoverageCp_INDC, '');
     SET @Ln_Exists_NUMB = 0;
     SET @Ls_Sql_TEXT = 'CHECK FOR Case_IDNO IN CASE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(6)), 0);
          
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CASE_Y1 d
      WHERE d.Case_IDNO = @Ln_FcrDmdcLocCur_Case_IDNO
        AND d.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       -- No open case found to process
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1072_CODE;

       GOTO lx_exception;
      END

     SET @Ls_Sql_TEXT = 'CP/NCP/PF MEDICAL COVERAGE';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(6)), 0) + ', ID_MEMBER_CHILD = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_ChildMci_IDNO AS VARCHAR(10)), 0) + ', MedCoverageCh_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageCh_INDC, '') + ', MedCoverageSponsorCh_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC, '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_NcpMci_IDNO AS VARCHAR(10)), 0) + ', MedCoverageNcp_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageNcp_INDC, '') + ', PfMci_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_PfMci_IDNO AS VARCHAR(10)), 0) + ', MedCoveragePf_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoveragePf_INDC, '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_CpMci_IDNO AS VARCHAR(10)), 0) + ', MedCoverageCp_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageCp_INDC, '');
     
     -- Do not process DMDC record if CP and NCP/PF medical coverage indicator is N
     IF (@Lc_FcrDmdcLocCur_MedCoverageNcp_INDC = @Lc_NoValue_CODE
          OR @Lc_FcrDmdcLocCur_MedCoveragePf_INDC = @Lc_NoValue_CODE)
        AND @Lc_FcrDmdcLocCur_MedCoverageCp_INDC = @Lc_NoValue_CODE
      BEGIN
       -- --Insufficient information to process
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1176_CODE;

       GOTO lx_exception;
      END

     SET @Ls_Sql_TEXT = 'CHILD MEDICAL COVERAGE';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(6)), 0) + ', ID_MEMBER_CHILD = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_ChildMci_IDNO AS VARCHAR(10)), 0) + ', MedCoverageCh_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageCh_INDC, '') + ', MedCoverageSponsorCh_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC, '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_NcpMci_IDNO AS VARCHAR(10)), 0) + ', PfMci_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_PfMci_IDNO AS VARCHAR(10)), 0) + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_CpMci_IDNO AS VARCHAR(10)), 0);
     
     --Check child medical coverage 
     IF @Lc_FcrDmdcLocCur_MedCoverageCh_INDC = @Lc_NoValue_CODE
         OR @Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC = @Lc_MedCoverageSponserOth_TEXT
      BEGIN
       --Insufficient information to process
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1176_CODE;

       GOTO lx_exception;
      
      END

     SET @Ln_Exists_NUMB = 0;
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF CHILD IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(6)), 0) + ', ID_MEMBER_CHILD = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_ChildMci_IDNO AS VARCHAR(10)), 0) + ', ChildSsn_NUMB = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_ChildSsn_NUMB AS VARCHAR(9)), 0);

     --check for existance of Child Member MCI in the case member table 
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 AS d
      WHERE d.Case_IDNO = @Ln_FcrDmdcLocCur_Case_IDNO
        AND d.MemberMci_IDNO = @Ln_FcrDmdcLocCur_ChildMci_IDNO
        AND d.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
        AND d.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1, MSSN_Y1 1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR), '');

       SELECT DISTINCT
              @Ln_ChildMCI_IDNO = a.MemberMci_IDNO
         FROM CMEM_Y1 AS a,
              MSSN_Y1 AS b
        WHERE a.Case_IDNO = @Ln_FcrDmdcLocCur_Case_IDNO
          AND a.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
          AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
          AND b.MemberMci_IDNO = a.MemberMci_IDNO
          AND b.MemberSsn_NUMB = @Ln_FcrDmdcLocCur_ChildSsn_NUMB
          AND b.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND b.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         -- Not a valid dependent member 
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0888_CODE;

         GOTO lx_exception;
        END
       ELSE IF @Li_RowCount_QNTY > 1
        BEGIN
         -- Duplicate record exists
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

         GOTO lx_exception;
        END
      END
     ELSE
      BEGIN
       -- Get Child Member MCI Number
       SET @Ln_ChildMCI_IDNO = @Ln_FcrDmdcLocCur_ChildMci_IDNO;
      END

     --To insert policy holder details in MINS_Y1
     SET @Ln_PolicyHolderSsn_NUMB = @Ln_Zero_NUMB;
     SET @Lc_RelationshipPolicyHolder_CODE = @Lc_RelationshipSelf_CODE;
     SET @Ln_MemberMci_IDNO = @Ln_Zero_NUMB;
     SET @Ln_MemberSsn_TEXT = @Ln_Zero_NUMB;

     --Get medical coverage sponsor
     SET @Ls_Sql_TEXT = 'CHILD MEDICAL COVERAGE SPONSOR';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     IF @Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC = @Lc_MedCoverageSponserNcp_TEXT
      BEGIN
       SET @Ln_MemberMci_IDNO = @Ln_FcrDmdcLocCur_NcpMci_IDNO;
       SET @Ln_PolicyHolderSsn_NUMB = ISNULL(@Ln_FcrDmdcLocCur_NcpSsn_NUMB, @Ln_Zero_NUMB);
       SET @Lc_RelationshipPolicyHolder_CODE = @Lc_RelationshipSelf_CODE;
       SET @Ln_MemberSsn_TEXT = @Ln_FcrDmdcLocCur_NcpSsn_NUMB;
      END
     ELSE IF @Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC = @Lc_MedCoverageSponserCp_TEXT
      BEGIN
       SET @Ln_MemberMci_IDNO = @Ln_FcrDmdcLocCur_CpMci_IDNO;
       SET @Ln_PolicyHolderSsn_NUMB = ISNULL(@Ln_FcrDmdcLocCur_CpSsn_NUMB, @Ln_Zero_NUMB);
       SET @Lc_RelationshipPolicyHolder_CODE = @Lc_RelationshipSelf_CODE;
       SET @Ln_MemberSsn_TEXT = @Ln_FcrDmdcLocCur_CpSsn_NUMB;
      END
     ELSE IF @Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC = @Lc_MedCoverageSponserPf_TEXT
      BEGIN
       SET @Ln_MemberMci_IDNO = @Ln_FcrDmdcLocCur_PfMci_IDNO;
       SET @Ln_PolicyHolderSsn_NUMB = ISNULL(@Ln_FcrDmdcLocCur_PfSsn_NUMB, @Ln_Zero_NUMB);
       SET @Lc_RelationshipPolicyHolder_CODE = @Lc_RelationshipSelf_CODE;
       SET @Ln_MemberSsn_TEXT = @Ln_FcrDmdcLocCur_PfSsn_NUMB;
      END
     ELSE
      BEGIN
       SET @Ln_MemberMci_IDNO = @Ln_FcrDmdcLocCur_NcpMci_IDNO;
       SET @Ln_PolicyHolderSsn_NUMB = @Ln_Zero_NUMB;
       SET @Lc_RelationshipPolicyHolder_CODE = @Lc_RelationshipOther_TEXT;
       SET @Ln_MemberSsn_TEXT = @Ln_Zero_NUMB;
      END

     SET @Ln_Exists_NUMB = 0;
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(6)), 0) + ', ID_MEMBER_CHILD = ' + ISNULL(CAST(@Ln_ChildMCI_IDNO AS VARCHAR(10)), 0) + ', ID_MEMBER_INS_SPONSOR = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MEM_SSN_INS_SPONSOR = ' + ISNULL(CAST(@Ln_MemberSsn_TEXT AS VARCHAR(9)), 0) + ', MedCoverageSponsorCh_INDC = ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC, '');
     
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 AS d
      WHERE d.Case_IDNO = @Ln_FcrDmdcLocCur_Case_IDNO
        AND d.MemberMci_IDNO = @Ln_MemberMci_IDNO
        AND d.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT, @Lc_RelationshipCaseCp_TEXT)
        AND d.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1, MSSN_Y1 2';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR), 0);

       SELECT DISTINCT
              @Ln_MemberMci_IDNO = a.MemberMci_IDNO
         FROM CMEM_Y1 AS a,
              MSSN_Y1 AS b
        WHERE a.Case_IDNO = @Ln_FcrDmdcLocCur_Case_IDNO
          AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT, @Lc_RelationshipCaseCp_TEXT)
          AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
          AND b.MemberMci_IDNO = a.MemberMci_IDNO
          AND b.MemberSsn_NUMB = @Ln_MemberSsn_TEXT
          AND b.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND b.EndValidity_DATE = @Ld_High_DATE;
       
       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         --E0894 Active participant not found
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0894_CODE;

         GOTO lx_exception;
        END
       ELSE IF @Li_RowCount_QNTY > 1
        BEGIN
         ---Duplicate record exists
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;

         GOTO lx_exception;
        END
      END

     SET @Ls_Sql_TEXT = 'GET OTHER PARTY Seq_IDNO';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(6)), 0) + ', CD_REFERENCE_OTHP = FK3' + ', TypeOthp_CODE = I - Insurer';
     -- Get Other Party ID for Insurer Tricare 'FK3'.
     -- Check this field later (@Lc_RefOthpTricare_IDNO) , this was alphanumeric in NJ and was changed to numeric in DECSS
  
     SET @Ln_OtherParty_IDNO = 999999975;
     SET @Ls_Sqldata_TEXT = 'Case_IDNO: ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR(6)), 0) + ' MemberMci_IDNO: ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ' OthpInsurance_IDNO: ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0) + ' MedCoverageSponsorCh_INDC: ' + ISNULL(@Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC, '');
     SET @Ln_Exists_NUMB = 0;

     SET @Ls_Sql_TEXT = 'CHECK FOR MEMBER INSURANCE DETAILS';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0);

     SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
       FROM MINS_Y1
      WHERE MINS_Y1.MemberMci_IDNO = @Ln_MemberMci_IDNO
        AND MINS_Y1.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
        AND MINS_Y1.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'GET PolicyHolder_NAME';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0);
       -- The scalar function removed
       
       SET @Ls_PolicyHolder_NAME = SUBSTRING(dbo.BATCH_COMMON_GETS$SF_GET_MEMBER_NAME(@Ln_MemberMci_IDNO), 1, 62);
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_MINS_UPDATE 1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', OthpInsurance_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0) + ', InsuranceGroupNo_TEXT = ' + ISNULL(@Lc_NoInsuranceGroup_TEXT, '') + ', DT_BEG_COVERAGE = ' + ISNULL(CAST(@Ld_FcrDmdcLocCur_BegCoverage_DATE AS VARCHAR(10)), '') + ', DT_END_COVERAGE = ' + ISNULL(CAST(@Ld_FcrDmdcLocCur_EndCoverage_DATE AS VARCHAR(10)), '');
       
       SET @Ld_DmdcCoverageBegin_DATE = ISNULL(@Ld_FcrDmdcLocCur_BegCoverage_DATE, @Ad_Run_DATE);
       SET @Ld_DmdcCoverageEnd_DATE = ISNULL(@Ld_FcrDmdcLocCur_EndCoverage_DATE, @Ld_High_DATE);
       
       EXECUTE BATCH_COMMON$SP_MINS_UPDATE
        @An_MemberMci_IDNO                = @Ln_MemberMci_IDNO,
        @Ad_Run_DATE                      = @Ad_Run_DATE,
        @An_OthpInsurance_IDNO            = @Ln_OtherParty_IDNO,
        @Ac_InsuranceGroupNo_TEXT         = @Lc_NoInsuranceGroup_TEXT,
        @Ac_PolicyInsNo_TEXT              = @Lc_Space_TEXT,
        @Ac_InsSource_CODE                = @Lc_InsuranceSourceFc_CODE,
        @Ac_DentalIns_INDC                = @Lc_Yes_INDC,
        @Ac_MedicalIns_INDC               = @Lc_Yes_INDC,
        @Ac_MentalIns_INDC                = @Lc_NoValue_CODE,
        @Ac_PrescptIns_INDC               = @Lc_Yes_INDC,
        @Ac_VisionIns_INDC                = @Lc_Yes_INDC,
        @Ac_OtherIns_INDC                 = @Lc_NoValue_CODE,
        @As_DescriptionOtherIns_TEXT      = @Lc_Space_TEXT,
        @Ad_Begin_DATE                    = @Ld_DmdcCoverageBegin_DATE,
        @Ac_EmployerPaid_INDC             = @Lc_Yes_INDC,
        @An_OthpEmployer_IDNO             = @Ln_Zero_NUMB,
        @An_MedicalMonthlyPremium_AMNT    = @Ln_Zero_NUMB,
        @An_CoPay_AMNT                    = @Ln_Zero_NUMB,
        @Ad_End_DATE                      = @Ld_DmdcCoverageEnd_DATE,
        @Ac_PolicyHolderRelationship_CODE = @Lc_RelationshipPolicyHolder_CODE,
        @As_PolicyHolder_NAME             = @Ls_PolicyHolder_NAME,
        @An_PolicyHolderSsn_NUMB          = @Ln_PolicyHolderSsn_NUMB,
        @Ad_BirthPolicyHolder_DATE        = @Ld_Low_DATE,
        @An_TransactionEventSeq_NUMB      = 0,
        @Ac_Process_ID                    = @Lc_ProcessFcrDmdc_ID,
        @Ac_Msg_CODE                      = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT         = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		  BEGIN
			SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			RAISERROR (50001,16,1);
		  END
		 ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			   BEGIN
				SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE; 
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
			   END
         ELSE
          BEGIN 
           SET @Lb_MinsUpdate_CODE = 1;
          END
      END

     SET @Ls_Sql_TEXT = 'SELECT MINS_Y1 NO_GROUP, PolicyNo_TEXT, Begin_DATE';
     SET @Ls_Sqldata_TEXT = 'NcpMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', OthpInsurance_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0);
     
     SELECT TOP 1 @Lc_NoInsuranceGroupMins_TEXT = b.InsuranceGroupNo_TEXT,
                  @Lc_NoPolicyInsMins_TEXT = b.PolicyInsNo_TEXT
       FROM MINS_Y1 b
      WHERE b.MemberMci_IDNO = @Ln_MemberMci_IDNO
        AND b.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
        AND b.EndValidity_DATE = @Ld_High_DATE
        AND b.Begin_DATE = (SELECT MAX(a.Begin_DATE)
                              FROM MINS_Y1 a
                             WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                               AND b.OthpInsurance_IDNO = a.OthpInsurance_IDNO
                               AND b.EndValidity_DATE = a.EndValidity_DATE);

     SET @Ln_Exists_NUMB = 0;
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN DINS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', ChildMCI_IDNO = ' + ISNULL(CAST(@Ln_ChildMCI_IDNO AS VARCHAR(10)), 0) + ', OthpInsurance_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0) + ', InsGroup_NUMB = ' + ISNULL(@Lc_NoInsuranceGroupMins_TEXT, '') + ', PolicyInsNo_TEXT = ' + ISNULL(@Lc_NoPolicyInsMins_TEXT, '');
     
     SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
       FROM DINS_Y1 
      WHERE DINS_Y1.MemberMci_IDNO = @Ln_MemberMci_IDNO
        AND DINS_Y1.ChildMCI_IDNO = @Ln_ChildMCI_IDNO
        AND DINS_Y1.OthpInsurance_IDNO = @Ln_OtherParty_IDNO
        AND DINS_Y1.InsuranceGroupNo_TEXT = @Lc_NoInsuranceGroupMins_TEXT
        AND DINS_Y1.PolicyInsNo_TEXT = @Lc_NoPolicyInsMins_TEXT
        AND DINS_Y1.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_DINS_UPDATE 1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', ChildMCI_IDNO = ' + ISNULL(CAST(@Ln_ChildMCI_IDNO AS VARCHAR(10)), 0) + ', OthpInsurance_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR(9)), 0) + ', InsGroup_NUMB = ' + ISNULL(@Lc_NoInsuranceGroupMins_TEXT, '') + ', PolicyInsNo_TEXT = ' + ISNULL(@Lc_NoPolicyInsMins_TEXT, '');
       SET @Ld_DmdcCoverageBegin_DATE = ISNULL(@Ld_FcrDmdcLocCur_BegCoverage_DATE, @Ad_Run_DATE);
       SET @Ld_DmdcCoverageEnd_DATE = ISNULL(@Ld_FcrDmdcLocCur_EndCoverage_DATE, @Ld_High_DATE);

       EXECUTE BATCH_COMMON$SP_DINS_UPDATE
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @An_OthpInsurance_IDNO       = @Ln_OtherParty_IDNO,
        @Ac_InsuranceGroupNo_TEXT    = @Lc_NoInsuranceGroupMins_TEXT,
        @Ac_PolicyInsNo_TEXT         = @Lc_NoPolicyInsMins_TEXT,
        @An_ChildMCI_IDNO            = @Ln_ChildMCI_IDNO,
        @Ad_Begin_DATE               = @Ld_DmdcCoverageBegin_DATE,
        @Ac_InsSource_CODE           = @Lc_InsuranceSourceFc_CODE,
        @Ac_DentalIns_INDC           = @Lc_Yes_INDC,
        @Ac_MedicalIns_INDC          = @Lc_Yes_INDC,
        @Ac_MentalIns_INDC           = @Lc_Space_TEXT,
        @Ac_PrescptIns_INDC          = @Lc_Yes_INDC,
        @Ac_VisionIns_INDC           = @Lc_Yes_INDC,
        @As_DescriptionOthers_TEXT   = @Lc_Space_TEXT,
        @Ad_End_DATE                 = @Ld_DmdcCoverageEnd_DATE,
        @An_TransactionEventSeq_NUMB = @Ln_Zero_NUMB,
        @Ac_Process_ID               = @Lc_ProcessFcrDmdc_ID,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
   
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		  BEGIN
			SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			RAISERROR (50001,16,1);
		  END
		 ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			   BEGIN
				SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE; 
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
			   END
         ELSE
          BEGIN
           SET @Lb_DinsUpdate_CODE = 1
          END 
      END
     ELSE
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1088_CODE;

       GOTO lx_exception;
      END
     
     -- Bug 10827 Start Create Case journal entry RRFCR for all the cases where member is active cp or pf or ncp 
     IF @Lb_MinsUpdate_CODE = 1 
     OR @Lb_DinsUpdate_CODE = 1 
        BEGIN 
         -- Add code here to create the RRFCR case journal entry
	     SET @Ls_Sql_TEXT = 'GENERATE TransactionEventSeq_NUMB A';
		 SET @Ls_Sqldata_TEXT ='Job_ID = ' + @Ac_Job_ID;
		 EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
          @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
          @Ac_Process_ID               = @Ac_Job_ID,
          @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
          @Ac_Note_INDC                = @Lc_Note_INDC,
          @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
          @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'GENERATE TransactionEventSeq_NUMB A FAILED';

           RAISERROR(50001,16,1);
          END
          
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 1';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), 0) + ', Case_IDNO = ' + ISNULL (CAST(@Ln_FcrDmdcLocCur_Case_IDNO AS VARCHAR), '') + ', MINOR_ACTIVITY = ' + ISNULL(@Lc_MinorActivityRrfcr_CODE, '');
           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_FcrDmdcLocCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_MinorActivityRrfcr_CODE,
            @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
            @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            @Ac_WorkerUpdate_ID		     = @Lc_BatchRunUser_TEXT,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_Job_ID                   = @Ac_Job_ID,
            @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		    BEGIN
			 SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			 SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			 RAISERROR (50001,16,1);
		    END
		   ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
               BEGIN
				SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE; 
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
               END
        END  
     -- Bug 10827 End
     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
       
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
              
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @As_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME, 
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         
         RAISERROR(50001,16,1);
        END
       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END  
      END

     END TRY
     
     BEGIN CATCH
      BEGIN 
		SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
		-- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	     BEGIN
	   	   ROLLBACK TRANSACTION SAVEDMDC_DETAILS;
		 END
		ELSE
		 BEGIN
		    SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + '' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
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
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
                
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0) ;

        SET @Ls_BateRecord_TEXT = @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @As_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Ac_Job_ID,
         @Ad_Run_DATE                 = @Ad_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
         @An_Line_NUMB                = @Ln_Cur_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
         @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END
       
      END
     END CATCH
     
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1 ;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_Sql_TEXT = 'UPDATE LFDMD_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_FcrDmdcLocCur_Seq_IDNO AS VARCHAR), 0);

     UPDATE LFDMD_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrDmdcLocCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LFDMD_Y1';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'COMMIT FREQUENCY CHECK ';
     SET @Ls_Sqldata_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(10)), 0);

     IF @An_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @An_CommitFreq_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID: ' + ISNULL(@Ac_Job_ID, '');
       
       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Ac_Job_ID,
        @Ad_Run_DATE              = @Ad_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cur_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'BATCH RESTART UPDATE FAILED ';

         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION DMDC_DETAILS; 
       BEGIN TRANSACTION DMDC_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK ';
     SET @Ls_Sqldata_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), 0);

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION DMDC_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD' + + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcrDmdcLoc_CUR INTO @Ln_FcrDmdcLocCur_Seq_IDNO, @Lc_FcrDmdcLocCur_Rec_ID, @Lc_FcrDmdcLocCur_StateTransmitter_CODE, @Lc_FcrDmdcLocCur_County_IDNO, @Lc_FcrDmdcLocCur_CaseIdno_TEXT, @Lc_FcrDmdcLocCur_Order_INDC, @Lc_FcrDmdcLocCur_FirstCh_NAME, @Lc_FcrDmdcLocCur_MidCh_NAME, @Lc_FcrDmdcLocCur_LastCh_NAME, @Lc_FcrDmdcLocCur_ChildSsnNumb_TEXT, @Lc_FcrDmdcLocCur_SsnVerifiedCh_INDC, @Lc_FcrDmdcLocCur_ChildMciIdno_TEXT, @Lc_FcrDmdcLocCur_DeathCh_INDC, @Lc_FcrDmdcLocCur_MedCoverageCh_INDC, @Lc_FcrDmdcLocCur_MedCoverageSponsorCh_INDC, @Ld_FcrDmdcLocCur_BegCoverage_DATE, @Ld_FcrDmdcLocCur_EndCoverage_DATE, @Lc_FcrDmdcLocCur_FirstNcp_NAME, @Lc_FcrDmdcLocCur_MiddleNcp_NAME, @Lc_FcrDmdcLocCur_LastNcp_NAME, @Lc_FcrDmdcLocCur_NcpSsnNumb_TEXT, @Lc_FcrDmdcLocCur_SsnVerifiedNcp_INDC, @Lc_FcrDmdcLocCur_NcpMciIdno_TEXT, @Lc_FcrDmdcLocCur_DeathNcp_INDC, @Lc_FcrDmdcLocCur_MedCoverageNcp_INDC, @Lc_FcrDmdcLocCur_FirstPf_NAME, @Lc_FcrDmdcLocCur_MiddlePf_NAME, @Lc_FcrDmdcLocCur_LastPf_NAME, @Lc_FcrDmdcLocCur_PfSsnNumb_TEXT, @Lc_FcrDmdcLocCur_SsnVerifiedPf_INDC, @Lc_FcrDmdcLocCur_PfMciIdno_TEXT, @Lc_FcrDmdcLocCur_DeathPf_INDC, @Lc_FcrDmdcLocCur_MedCoveragePf_INDC, @Lc_FcrDmdcLocCur_FirstCp_NAME, @Lc_FcrDmdcLocCur_MiddleCp_NAME, @Lc_FcrDmdcLocCur_LastCp_NAME, @Lc_FcrDmdcLocCur_CpSsnNumb_TEXT, @Lc_FcrDmdcLocCur_SsnVerifiedCp_INDC, @Lc_FcrDmdcLocCur_CpMciIdno_TEXT, @Lc_FcrDmdcLocCur_DeathCp_INDC, @Lc_FcrDmdcLocCur_MedCoverageCp_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcrDmdcLoc_CUR;

   DEALLOCATE FcrDmdcLoc_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   
   -- Transaction ends 
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   COMMIT TRANSACTION DMDC_DETAILS;
  END TRY

  BEGIN CATCH
   
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcrDmdcLoc_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrDmdcLoc_CUR;

     DEALLOCATE FcrDmdcLoc_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DMDC_DETAILS;
    END

   --Set Error Description
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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
 END


GO
