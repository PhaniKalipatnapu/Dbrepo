/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_PUDM$SP_PROCESS_PUDM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
----------------------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_LOC_INCOMING_PUDM$SP_PROCESS_PUDM
Programmer Name   :	IMP Team
Description       :	This process updates DECSS with members billing address and employment data. This occurs in two steps. 
					The first step reads the incoming file and loads the information into a LPUDM_Y1 table. A second program reads the  LPUDM_Y1 table 
					and matches information against DECSS and updates the member address history and member employment history tables.
Frequency         :	The job will be run when the file is received from the public utlity companies
Developed On      :	05/24/2011
Called BY         :	None
Called On		  :	
---------------------------------------------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        :	0.01
----------------------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_PUDM$SP_PROCESS_PUDM]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE             CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
          @Lc_MailingTypeAddress_CODE       CHAR(1) = 'M',
          @Lc_ResidentailTypeAddress_CODE   CHAR(1) = 'R',
          @Lc_ConfirmedGoodStatus_CODE      CHAR(1) = 'Y',
          @Lc_PendingStatus_CODE            CHAR(1) = 'P',
          @Lc_IndNote_TEXT                  CHAR(1) = 'N',
          @Lc_TypeErrorWarning_CODE         CHAR(1) = 'W',
          @Lc_TypeError_CODE                CHAR(1) = 'E',
          @Lc_ActiveCaseMemberStatus_CODE   CHAR(1) = 'A',
          @Lc_StatusCaseOpen_CODE           CHAR(1) = 'O',
          @Lc_StatusCaseClose_CODE          CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE      CHAR(1) = 'A',
          @Lc_YDpCoverageAvlb_INDC          CHAR(1) = 'Y',
          @Lc_NDpCovered_INDC               CHAR(1) = 'N',
          @Lc_YInsProvider_INDC             CHAR(1) = 'Y',
          @Lc_YInsReasonable_CODE           CHAR(1) = 'Y',
          @Lc_NLimitCcpa_INDC               CHAR(1) = 'N',
          @Lc_WeeklyFreqIncome_CODE         CHAR(1) = 'W',
          @Lc_CaseRelationshipPutative_CODE CHAR(1) = 'P',
          @Lc_CaseRelationshipCp_CODE       CHAR(1) = 'C',
          @Lc_EmployerStatusY_CODE          CHAR(1) = 'Y',
          @Lc_TypeCaseNivd_CODE             CHAR(1) = 'H',
          @Lc_TypeOthpEmployer_CODE         CHAR(1) = 'E',
          @Lc_ProcessY_INDC                 CHAR(1) = 'Y',
          @Lc_ProcessN_INDC                 CHAR(1) = 'N',
          @Lc_TypeErrorE_CODE               CHAR(1) = 'E',
          @Lc_SourceLocConfA_CODE           CHAR(1) = 'A',
          @Lc_Country_ADDR                  CHAR(2) = 'US',
          @Lc_OthStateFips_CODE             CHAR(2) = ' ',
          @Lc_TypeIncome_CODE               CHAR(2) = 'EM',
          @Lc_RsnStatusCaseUc_CODE          CHAR(2) = 'UC',
          @Lc_RsnStatusCaseUb_CODE          CHAR(2) = 'UB',
          @Lc_SourceVerified_CODE           CHAR(3) = 'A',
          @Lc_Subsystem_CODE                CHAR(3) = 'LO',
          @Lc_PutSourceLoc_CODE             CHAR(3) = 'PUT',
          @Lc_ActivityMajor_CODE            CHAR(4) = 'CASE',
          @Lc_TypeReference_IDNO            CHAR(4) = ' ',
          @Lc_BatchRunUser_TEXT             CHAR(5) = 'BATCH',
          @Lc_ErrorE1405_CODE               CHAR(5) = 'E1405',
          @Lc_ActivityMinorRcona_CODE       CHAR(5) = 'RCONA',
          @Lc_ActivityMinorRunca_CODE       CHAR(5) = 'RUNCA',
          @Lc_ActivityMinorRrfpu_CODE       CHAR(5) = 'RRFPU',
          @Lc_ErrorE0085_CODE               CHAR(5) = 'E0085',
          @Lc_ErrorE0012_CODE               CHAR(5) = 'E0012',
          @Lc_ErrorE1373_CODE               CHAR(5) = 'E1373',
          @Lc_ErrorE0944_CODE               CHAR(5) = 'E0944',
          @Lc_ErrorE1424_CODE               CHAR(5) = 'E1424',
          @Lc_ErrorE1089_CODE               CHAR(5) = 'E1089',
          @Lc_Job_ID                        CHAR(7) = 'DEB8072',
          @Lc_Process_ID                    CHAR(7) = 'DEB8072',
          @Lc_Successful_INDC               CHAR(20) = 'SUCCESSFUL',
          @Lc_Err0002_TEXT                  CHAR(30) = 'UPDATE NOT SUCCESSFUL',
          @Lc_WorkerDelegate_ID             CHAR(30) = ' ',
          @Lc_Reference_ID                  CHAR(30) = ' ',
          @Lc_Attn_ADDR                     CHAR(40) = ' ',
          @Ls_ParmDateProblem_TEXT          VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_LOC_INCOMING_PUDM',
          @Ls_Procedure_NAME                VARCHAR(100) = 'SP_PROCESS_PUDM',
          @Ls_DescriptionComments_TEXT      VARCHAR(8000) = ' ',
          @Ls_XmlTextIn_TEXT                VARCHAR(8000) = ' ',
          @Ld_Low_DATE                      DATE = '01/01/0001',
          @Ld_High_DATE                     DATE = '12/31/9999';
  DECLARE @Ln_TopicIn_IDNO                     NUMERIC = 0,
          @Ln_Office_IDNO                      NUMERIC(3) = 0,
          @Ln_ExceptionThresholdParm_QNTY      NUMERIC(5) = 0,
          @Ln_ExceptionThreshold_QNTY          NUMERIC(5) = 0,
          @Ln_CommitFreqParm_QNTY              NUMERIC(5) = 0,
          @Ln_Zero_NUMB                        NUMERIC(5) = 0,
          @Ln_RestartLine_NUMB                 NUMERIC(5) = 0,
          @Ln_MajorIntSeq_NUMB                 NUMERIC(5) = 0,
          @Ln_MinorIntSeq_NUMB                 NUMERIC(5) = 0,
          @Ln_CommitFreq_QNTY                  NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY        NUMERIC(6) = 0,
          @Ln_ProcessedRecordsCommit_QNTY      NUMERIC(6) = 0,
          @Ln_OthpSource_IDNO                  NUMERIC(9) = 0,
          @Ln_OthpLocation_IDNO                NUMERIC(9) = 0,
          @Ln_OthpPartyEmpl_IDNO               NUMERIC(9) = 0,
          @Ln_Schedule_NUMB                    NUMERIC(10) = 0,
          @Ln_RecordCount_NUMB                 NUMERIC(10) = 0,
          @Ln_Topic_IDNO                       NUMERIC(10) = 0,
          @Ln_CostInsurance_AMNT               NUMERIC(11, 2) = 0,
          @Ln_IncomeNet_AMNT                   NUMERIC(11, 2) = 0,
          @Ln_IncomeGross_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_Error_NUMB                       NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB                   NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB         NUMERIC(18) = 0,
          @Li_FetchStatus_QNTY                 SMALLINT,
          @Li_RowsCount_QNTY                   SMALLINT,
          @Lc_Space_TEXT                       CHAR(1) = '',
          @Lc_Status_CODE                      CHAR(1) = '',
          @Lc_FreqInsurance_CODE               CHAR(1) = '',
          @Lc_FreqPay_CODE                     CHAR(1) = '',
          @Lc_ReasonStatus_CODE                CHAR(2) = '',
          @Lc_Msg_CODE                         CHAR(5) = '',
          @Lc_BateError_CODE                   CHAR(5) = '',
          @Lc_BillingActivityMinor_CODE        CHAR(5) = '',
          @Lc_ServiceActivityMinor_CODE        CHAR(5) = '',
          @Lc_Notice_ID                        CHAR(8) = '',
          @Lc_Schedule_Member_IDNO             CHAR(10) = '',
          @Lc_Schedule_Worker_IDNO             CHAR(30) = '',
          @Lc_DescriptionOccupation_TEXT       CHAR(32) = '',
          @Ls_Sql_TEXT                         VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT              VARCHAR(200) = '',
          @Ls_DescriptionServiceDirection_TEXT VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT                VARCHAR(8000) = '',
          @Ls_DescriptionError_TEXT            VARCHAR(8000),
          @Ls_BateRecord_TEXT                  VARCHAR(8000),
          @Ls_BateRecord1_TEXT                 VARCHAR(8000),
          @Ls_Sqldata_TEXT                     VARCHAR(8000) = '',
          @Ld_Run_DATE                         DATE,
          @Ld_LastRun_DATE                     DATE,
          @Ld_Start_DATE                       DATETIME2,
          @Ld_BeginSch_DTTM                    DATETIME2,
          @Lb_ErrorExpection_CODE              BIT = 0,
          @Lb_AhisServiceAddress_CODE          BIT = 0,
          @Lb_AhisBillingAddress_CODE          BIT = 0;
  DECLARE Pudm_CUR INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.HeaderSeq_IDNO,
          a.Rec_ID,
          a.MemberSsn_NUMB,
          a.MemberMci_IDNO,
          a.Last_NAME,
          a.First_NAME,
          a.Middle_NAME,
          a.Title_NAME,
          a.Phone_NUMB,
          a.Billing_NAME,
          a.BillingPhone_NUMB,
          a.Employer_NAME,
          a.EmployerPhone_NUMB,
          a.ServiceAddressNormalization_CODE,
          a.ServiceLine1_ADDR,
          a.ServiceLine2_ADDR,
          a.ServiceCity_ADDR,
          a.ServiceState_ADDR,
          a.ServiceZip_ADDR,
          a.BillingAddressNormalization_CODE,
          a.BillingLine1_ADDR,
          a.BillingLine2_ADDR,
          a.BillingCity_ADDR,
          a.BillingState_ADDR,
          a.BillingZip_ADDR,
          a.EmployerAddressNormalization_CODE,
          a.EmployerLine1_ADDR,
          a.EmployerLine2_ADDR,
          a.EmployerCity_ADDR,
          a.EmployerState_ADDR,
          a.EmployerZip_ADDR
     FROM LPUDM_Y1 a
    WHERE a.Process_INDC = @Lc_ProcessN_INDC  
    ORDER BY Seq_IDNO;
    
  DECLARE @Ln_PudmCur_Seq_IDNO               NUMERIC(19),
          @Ln_PudmCur_HeaderSeq_IDNO         NUMERIC(19),
          @Lc_PudmCur_RecId_TEXT             CHAR(2),
          @Lc_PudmCur_MemberSsnNumb_TEXT     CHAR(9),
          @Lc_PudmCur_MemberMciIdno_TEXT     CHAR(10),
          @Lc_PudmCur_Last_NAME              CHAR(13),
          @Lc_PudmCur_First_NAME             CHAR(9),
          @Lc_PudmCur_Middle_NAME            CHAR(1),
          @Lc_PudmCur_Title_NAME             CHAR(1),
          @Lc_PudmCur_PhoneNumb_TEXT         CHAR(10),
          @Lc_PudmCur_Bill_NAME              CHAR(24),
          @Lc_PudmCur_BillingPhoneNumb_TEXT  CHAR(15),
          @Lc_PudmCur_Empl_NAME              CHAR(31),
          @Lc_PudmCur_EmployerPhoneNumb_TEXT CHAR(15),
          @Lc_PudmCur_SerAddrNorm_CODE       CHAR(1),
          @Ls_PudmCur_SerLine1_ADDR          VARCHAR(50),
          @Ls_PudmCur_SerLine2_ADDR          VARCHAR(50),
          @Lc_PudmCur_SerCity_ADDR           CHAR(28),
          @Lc_PudmCur_SerState_ADDR          CHAR(2),
          @Lc_PudmCur_SerZip_ADDR            CHAR(15),
          @Lc_PudmCur_BillAddrNorm_CODE      CHAR(1),
          @Ls_PudmCur_Bill1_ADDR             VARCHAR(50),
          @Ls_PudmCur_Bill2_ADDR             VARCHAR(50),
          @Lc_PudmCur_BillCity_ADDR          CHAR(28),
          @Lc_PudmCur_BillState_ADDR         CHAR(2),
          @Lc_PudmCur_BillZip_ADDR           CHAR(15),
          @Lc_PudmCur_EmplAddrNorm_CODE      CHAR(1),
          @Ls_PudmCur_Empl1_ADDR             VARCHAR(50),
          @Ls_PudmCur_Empl2_ADDR             VARCHAR(50),
          @Lc_PudmCur_EmplCity_ADDR          CHAR(28),
          @Lc_PudmCur_EmplState_ADDR         CHAR(2),
          @Lc_PudmCur_EmplZip_ADDR           CHAR(15),
          @Ln_CaseMemberCur_Case_IDNO        NUMERIC(6, 0),
          @Ln_CaseMemberCur_MemberMci_IDNO   NUMERIC(10, 0);
  DECLARE @Ln_PudmCurMemberSsn_NUMB NUMERIC(9),
          @Ln_PudmCurMemberMci_IDNO NUMERIC(10),
          @Ln_PudmCurPhone_NUMB     NUMERIC(10),
          @Ln_PudmCurBillPhone_NUMB NUMERIC(10),
          @Ln_PudmCurEmplPhone_NUMB NUMERIC(10);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   BEGIN TRANSACTION PUDM_PROCESS;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
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
   SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Line Number = ' + CAST(@Ln_RestartLine_NUMB AS VARCHAR);

   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_RestartLine_NUMB;

   SET @Ls_Sql_TEXT = 'OPEN Pudm_CUR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   OPEN Pudm_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Pudm_CUR - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');

   FETCH NEXT FROM Pudm_CUR INTO @Ln_PudmCur_Seq_IDNO, @Ln_PudmCur_HeaderSeq_IDNO, @Lc_PudmCur_RecId_TEXT, @Lc_PudmCur_MemberSsnNumb_TEXT, @Lc_PudmCur_MemberMciIdno_TEXT, @Lc_PudmCur_Last_NAME, @Lc_PudmCur_First_NAME, @Lc_PudmCur_Middle_NAME, @Lc_PudmCur_Title_NAME, @Lc_PudmCur_PhoneNumb_TEXT, @Lc_PudmCur_Bill_NAME, @Lc_PudmCur_BillingPhoneNumb_TEXT, @Lc_PudmCur_Empl_NAME, @Lc_PudmCur_EmployerPhoneNumb_TEXT, @Lc_PudmCur_SerAddrNorm_CODE, @Ls_PudmCur_SerLine1_ADDR, @Ls_PudmCur_SerLine2_ADDR, @Lc_PudmCur_SerCity_ADDR, @Lc_PudmCur_SerState_ADDR, @Lc_PudmCur_SerZip_ADDR, @Lc_PudmCur_BillAddrNorm_CODE, @Ls_PudmCur_Bill1_ADDR, @Ls_PudmCur_Bill2_ADDR, @Lc_PudmCur_BillCity_ADDR, @Lc_PudmCur_BillState_ADDR, @Lc_PudmCur_BillZip_ADDR, @Lc_PudmCur_EmplAddrNorm_CODE, @Ls_PudmCur_Empl1_ADDR, @Ls_PudmCur_Empl2_ADDR, @Lc_PudmCur_EmplCity_ADDR, @Lc_PudmCur_EmplState_ADDR, @Lc_PudmCur_EmplZip_ADDR;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   IF @Li_FetchStatus_QNTY <> 0
    BEGIN
     SET @Lc_BateError_CODE = @Lc_ErrorE0944_CODE;
    END;

   --Cursor to process each record in load table
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION SAVEPUDM_PROCESS;

      SET @Lc_BateError_CODE = @Lc_ErrorE1424_CODE;
      SET @Lc_Msg_CODE = @Lc_Space_TEXT;
      SET @Ln_RecordCount_NUMB = @Ln_RecordCount_NUMB + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT = 'Pudm - CURSOR COUNT - ' + CAST(@Ln_RecordCount_NUMB AS VARCHAR);
      SET @Ls_BateRecord_TEXT = 'Sequence Idno = ' + CAST(@Ln_PudmCur_Seq_IDNO AS VARCHAR) + ', Header Sequence Idno = ' + CAST(@Ln_PudmCur_HeaderSeq_IDNO AS VARCHAR) + ', Record Id = ' + @Lc_PudmCur_RecId_TEXT + ', Member SSN = ' + @Lc_PudmCur_MemberSsnNumb_TEXT + ', Member MCI Number = ' + @Lc_PudmCur_MemberMciIdno_TEXT + ', Last Name = ' + @Lc_PudmCur_Last_NAME + ', First Name = ' + @Lc_PudmCur_First_NAME + ', Middle Name = ' + @Lc_PudmCur_Middle_NAME + ', Title Name = ' + @Lc_PudmCur_Title_NAME + ', Phone Number = ' + @Lc_PudmCur_PhoneNumb_TEXT + ', Billing Phone Number = ' + @Lc_PudmCur_BillingPhoneNumb_TEXT + ', Employer Phone Number = ' + @Lc_PudmCur_EmployerPhoneNumb_TEXT + ', Service Address Normalization Code = ' + @Lc_PudmCur_SerAddrNorm_CODE + ', Service Line 1 Address = ' + @Ls_PudmCur_SerLine1_ADDR + ', Service Line 2 Address = ' + @Ls_PudmCur_SerLine2_ADDR + ', Service Address City = ' + @Lc_PudmCur_SerCity_ADDR + ', Service Address State = ' + @Lc_PudmCur_SerState_ADDR + ', Service Address Zip Code = ' + @Lc_PudmCur_SerZip_ADDR + ', Billing Name = ' + @Lc_PudmCur_Bill_NAME + ', Billing Address Normalization Code = ' + @Lc_PudmCur_BillAddrNorm_CODE + ', Billing Address Line 1 = ' + @Ls_PudmCur_Bill1_ADDR + ', Billing Address Line 2 = ' + @Ls_PudmCur_Bill2_ADDR + ', Billing Address City = ' + @Lc_PudmCur_BillCity_ADDR + ', Billing Address State = ' + @Lc_PudmCur_BillState_ADDR + ', Billing Address Zip Code = ' + @Lc_PudmCur_BillZip_ADDR + ', Employer Name = ' + @Lc_PudmCur_Empl_NAME + ', Employer Address Normalizatin Code = ' + @Lc_PudmCur_EmplAddrNorm_CODE + ', Employer Address Line 1 = ' + @Ls_PudmCur_Empl1_ADDR + ', Employer Address Line 2 = ' + @Ls_PudmCur_Empl2_ADDR + ', Employer Address City = ' + @Lc_PudmCur_EmplCity_ADDR + ', Employer State Address = ' + @Lc_PudmCur_EmplState_ADDR + ', Employer Address Zip Code = ' + @Lc_PudmCur_EmplZip_ADDR;
      SET @Ls_BateRecord1_TEXT = @Ls_BateRecord_TEXT;
      SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
      SET @Lb_ErrorExpection_CODE = 0;
      SET @Lb_AhisServiceAddress_CODE = 0;
      SET @Lb_AhisBillingAddress_CODE = 0;

      IF ISNUMERIC(@Lc_PudmCur_MemberSsnNumb_TEXT) = 1
         AND ISNUMERIC(@Lc_PudmCur_MemberMciIdno_TEXT) = 1
       BEGIN
        SET @Ln_PudmCurMemberSsn_NUMB = @Lc_PudmCur_MemberSsnNumb_TEXT;
        SET @Ln_PudmCurMemberMci_IDNO = @Lc_PudmCur_MemberMciIdno_TEXT;

        IF LTRIM(RTRIM(@Lc_PudmCur_PhoneNumb_TEXT)) <> @Lc_Space_TEXT
         BEGIN
          IF ISNUMERIC(@Lc_PudmCur_PhoneNumb_TEXT) = 1
           BEGIN
            SET @Ln_PudmCurPhone_NUMB = CAST(@Lc_PudmCur_PhoneNumb_TEXT AS NUMERIC);
           END
          ELSE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

            RAISERROR (50001,16,1);
           END
         END
        ELSE
         BEGIN
          SET @Ln_PudmCurPhone_NUMB = @Ln_Zero_NUMB;
         END

        IF LTRIM(RTRIM(@Lc_PudmCur_BillingPhoneNumb_TEXT)) <> @Lc_Space_TEXT
         BEGIN
          IF ISNUMERIC(@Lc_PudmCur_BillingPhoneNumb_TEXT) = 1
           BEGIN
            SET @Ln_PudmCurBillPhone_NUMB = CAST(@Lc_PudmCur_BillingPhoneNumb_TEXT AS NUMERIC);
           END
          ELSE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

            RAISERROR (50001,16,1);
           END
         END
        ELSE
         BEGIN
          SET @Ln_PudmCurBillPhone_NUMB = @Ln_Zero_NUMB;
         END

        IF LTRIM(RTRIM(@Lc_PudmCur_EmployerPhoneNumb_TEXT)) <> @Lc_Space_TEXT
         BEGIN
          IF ISNUMERIC(@Lc_PudmCur_EmployerPhoneNumb_TEXT) = 1
           BEGIN
            SET @Ln_PudmCurEmplPhone_NUMB = CAST(@Lc_PudmCur_EmployerPhoneNumb_TEXT AS NUMERIC);
           END
          ELSE
           BEGIN
            SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

            RAISERROR (50001,16,1);
           END
         END
        ELSE
         BEGIN
          SET @Ln_PudmCurEmplPhone_NUMB = @Ln_Zero_NUMB;
         END
       END
      ELSE
       BEGIN
        SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;

        RAISERROR (50001,16,1);
       END

      IF NOT EXISTS (SELECT 1
                       FROM DEMO_Y1 d
                      WHERE d.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO
                        AND LEFT(d.Last_NAME, 5) = LEFT(@Lc_PudmCur_Last_NAME, 5))
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
        SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0012_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @Ls_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Lc_Job_ID,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
         @An_Line_NUMB                = @Ln_RestartLine_NUMB,
         @Ac_Error_CODE               = @Lc_ErrorE0012_CODE,
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

        IF NOT EXISTS (SELECT 1
                         FROM DEMO_Y1 d
                        WHERE d.MemberSsn_NUMB = @Ln_PudmCurMemberSsn_NUMB
                          AND LEFT(d.Last_NAME, 5) = LEFT(@Lc_PudmCur_Last_NAME, 5))
         BEGIN
          SET @Ls_Sql_TEXT = 'Check with Member SSN and Last Name';
          SET @Ls_Sqldata_TEXT = 'Member Last Name Does Not Match, MemberMci_IDNO = ' + CAST(@Ln_PudmCurMemberMci_IDNO AS VARCHAR) + ', Last Name = ' + @Lc_PudmCur_Last_NAME;
          SET @Lc_BateError_CODE = @Lc_ErrorE1373_CODE;

          RAISERROR (50001,16,1);
         END
        ELSE
         BEGIN
          SET @Ln_PudmCurMemberMci_IDNO = (SELECT ISNULL(a.MemberMci_IDNO, 0)
                                             FROM DEMO_Y1 a
                                            WHERE a.MemberSsn_NUMB = @Ln_PudmCurMemberSsn_NUMB
                                              AND LEFT(Last_NAME, 5) = LEFT(@Lc_PudmCur_Last_NAME, 5));
         END
       END

      IF NOT EXISTS (SELECT 1
                       FROM CASE_Y1 c
                            JOIN CMEM_Y1 m
                             ON c.Case_IDNO = m.Case_IDNO
                            JOIN DEMO_Y1 d
                             ON d.MemberMci_IDNO = m.MemberMci_IDNO
                      WHERE c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                        AND c.TypeCase_CODE <> @Lc_TypeCaseNivd_CODE
                        AND m.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
                        AND (d.MemberSsn_NUMB = @Ln_PudmCurMemberSsn_NUMB
                              OR d.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO)
                        AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE))
         AND NOT EXISTS (SELECT 1
                           FROM CASE_Y1 c
                                JOIN CMEM_Y1 m
                                 ON c.CASE_IDNO = m.CASE_IDNO
                                JOIN DEMO_Y1 d
                                 ON d.MemberMci_IDNO = m.MemberMci_IDNO
                          WHERE c.StatusCase_CODE = @Lc_StatusCaseClose_CODE
                            AND m.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
                            AND c.RsnStatusCase_CODE IN (@Lc_RsnStatusCaseUc_CODE, @Lc_RsnStatusCaseUb_CODE)
                            AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE)
                            AND (d.MemberSsn_NUMB = @Ln_PudmCurMemberSsn_NUMB
                                  OR d.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO))
       BEGIN
        SET @Ls_Sql_TEXT = 'DATA REJECTED, NO VALID CASE FOUND TO LOAD DATA';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '');
        SET @Lc_BateError_CODE = @Lc_ErrorE1405_CODE;

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
      SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_IndNote_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

      EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
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

      IF EXISTS (SELECT 1
                   FROM AHIS_Y1 a
                  WHERE a.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO
                    AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                    AND a.TypeAddress_CODE IN (@Lc_MailingTypeAddress_CODE, @Lc_ResidentailTypeAddress_CODE)
                    AND Status_CODE = @Lc_ConfirmedGoodStatus_CODE)
       BEGIN
        SET @Lc_Status_CODE = @Lc_PendingStatus_CODE;
       END
      ELSE
       BEGIN
        SET @Lc_Status_CODE = @Lc_ConfirmedGoodStatus_CODE;
       END

      IF @Ls_PudmCur_Bill1_ADDR <> @Lc_Space_TEXT
          OR @Ls_PudmCur_Bill2_ADDR <> @Lc_Space_TEXT
          OR @Lc_PudmCur_BillCity_ADDR <> @Lc_Space_TEXT
          OR @Lc_PudmCur_BillState_ADDR <> @Lc_Space_TEXT
          OR @Lc_PudmCur_BillZip_ADDR <> @Lc_Space_TEXT
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE -1';
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PudmCurMemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_MailingTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_PudmCur_Bill1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_PudmCur_Bill2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_PudmCur_BillCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_PudmCur_BillState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_PudmCur_BillZip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_PudmCurBillPhone_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_PutSourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_Status_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerified_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Ls_DescriptionServiceDirection_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_PudmCur_BillAddrNorm_CODE, '') + ', CcrtMemberAddress_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', CcrtCaseRelationship_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

        EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
         @An_MemberMci_IDNO                   = @Ln_PudmCurMemberMci_IDNO,
         @Ad_Run_DATE                         = @Ld_Run_DATE,
         @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
         @Ad_Begin_DATE                       = @Ld_Run_DATE,
         @Ad_End_DATE                         = @Ld_High_DATE,
         @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
         @As_Line1_ADDR                       = @Ls_PudmCur_Bill1_ADDR,
         @As_Line2_ADDR                       = @Ls_PudmCur_Bill2_ADDR,
         @Ac_City_ADDR                        = @Lc_PudmCur_BillCity_ADDR,
         @Ac_State_ADDR                       = @Lc_PudmCur_BillState_ADDR,
         @Ac_Zip_ADDR                         = @Lc_PudmCur_BillZip_ADDR,
         @Ac_Country_ADDR                     = @Lc_Country_ADDR,
         @An_Phone_NUMB                       = @Ln_PudmCurBillPhone_NUMB,
         @Ac_SourceLoc_CODE                   = @Lc_PutSourceLoc_CODE,
         @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
         @Ad_Status_DATE                      = @Ld_Run_DATE,
         @Ac_Status_CODE                      = @Lc_Status_CODE,
         @Ac_SourceVerified_CODE              = @Lc_SourceVerified_CODE,
         @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
         @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
         @Ac_Process_ID                       = @Lc_Process_ID,
         @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
         @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
         @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
         @Ac_Normalization_CODE               = @Lc_PudmCur_BillAddrNorm_CODE,
         @Ac_CcrtMemberAddress_CODE           = @Lc_Space_TEXT,
         @Ac_CcrtCaseRelationship_CODE        = @Lc_Space_TEXT,
         @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END;
        ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
         BEGIN
          SET @Lb_AhisBillingAddress_CODE = 1;

          --13838 - Assigning latest record address status -START-
          IF @Lc_ConfirmedGoodStatus_CODE = (SELECT TOP 1 Status_CODE
                                               FROM AHIS_Y1 a
                                              WHERE a.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO
                                                AND a.TypeAddress_CODE = @Lc_MailingTypeAddress_CODE
                                                AND a.Begin_DATE = @Ld_Run_DATE
                                                AND a.SourceLoc_CODE = @Lc_PutSourceLoc_CODE
                                                ORDER BY a.TransactionEventSeq_NUMB DESC)
           BEGIN
            SET @Lc_BillingActivityMinor_CODE = @Lc_ActivityMinorRcona_CODE;
           END
          ELSE IF @Lc_PendingStatus_CODE = (SELECT TOP 1 Status_CODE
                                               FROM AHIS_Y1 a
                                              WHERE a.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO
                                                AND a.TypeAddress_CODE = @Lc_MailingTypeAddress_CODE
                                                AND a.Begin_DATE = @Ld_Run_DATE
                                                AND a.SourceLoc_CODE = @Lc_PutSourceLoc_CODE
                                                ORDER BY a.TransactionEventSeq_NUMB DESC)
           BEGIN
            SET @Lc_BillingActivityMinor_CODE = @Lc_ActivityMinorRunca_CODE;
           END
          ELSE 
           BEGIN
            SET @Lb_AhisBillingAddress_CODE = 0;
           END  
          --13838 - Assigning latest record address status -END-
         END;
        ELSE IF @Lc_Msg_CODE != @Lc_ErrorE1089_CODE 
         BEGIN
          SET @Lb_AhisBillingAddress_CODE = 0;
          SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord1_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2 ';
          SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_Msg_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

          EXECUTE BATCH_COMMON$SP_BATE_LOG
           @As_Process_NAME             = @Ls_Process_NAME,
           @As_Procedure_NAME           = @Ls_Procedure_NAME,
           @Ac_Job_ID                   = @Lc_Job_ID,
           @Ad_Run_DATE                 = @Ld_Run_DATE,
           @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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

      IF LTRIM(RTRIM(@Ls_PudmCur_SerLine1_ADDR)) <> @Lc_Space_TEXT
       BEGIN
        IF(@Ls_PudmCur_Bill1_ADDR <> @Ls_PudmCur_SerLine1_ADDR
            OR @Ls_PudmCur_Bill2_ADDR <> @Ls_PudmCur_SerLine2_ADDR
            OR @Lc_PudmCur_BillCity_ADDR <> @Lc_PudmCur_SerCity_ADDR
            OR @Lc_PudmCur_BillState_ADDR <> @Lc_PudmCur_SerState_ADDR
            OR @Lc_PudmCur_BillZip_ADDR <> @Lc_PudmCur_SerZip_ADDR)
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE -2';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PudmCurMemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_ResidentailTypeAddress_CODE, '') + ', Begin_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Attn_ADDR = ' + ISNULL(@Lc_Attn_ADDR, '') + ', Line1_ADDR = ' + ISNULL(@Ls_PudmCur_SerLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_PudmCur_SerLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_PudmCur_SerCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_PudmCur_SerState_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_PudmCur_SerZip_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_PudmCurPhone_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_PutSourceLoc_CODE, '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_PendingStatus_CODE, '') + ', SourceVerified_CODE = ' + ISNULL(@Lc_SourceVerified_CODE, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Ls_DescriptionComments_TEXT, '') + ', DescriptionServiceDirection_TEXT = ' + ISNULL(@Ls_DescriptionServiceDirection_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_PudmCur_SerAddrNorm_CODE, '') + ', CcrtMemberAddress_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', CcrtCaseRelationship_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

          EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
           @An_MemberMci_IDNO                   = @Ln_PudmCurMemberMci_IDNO,
           @Ad_Run_DATE                         = @Ld_Run_DATE,
           @Ac_TypeAddress_CODE                 = @Lc_ResidentailTypeAddress_CODE,
           @Ad_Begin_DATE                       = @Ld_Run_DATE,
           @Ad_End_DATE                         = @Ld_High_DATE,
           @Ac_Attn_ADDR                        = @Lc_Attn_ADDR,
           @As_Line1_ADDR                       = @Ls_PudmCur_SerLine1_ADDR,
           @As_Line2_ADDR                       = @Ls_PudmCur_SerLine2_ADDR,
           @Ac_City_ADDR                        = @Lc_PudmCur_SerCity_ADDR,
           @Ac_State_ADDR                       = @Lc_PudmCur_SerState_ADDR,
           @Ac_Zip_ADDR                         = @Lc_PudmCur_SerZip_ADDR,
           @Ac_Country_ADDR                     = @Lc_Country_ADDR,
           @An_Phone_NUMB                       = @Ln_PudmCurPhone_NUMB,
           @Ac_SourceLoc_CODE                   = @Lc_PutSourceLoc_CODE,
           @Ad_SourceReceived_DATE              = @Ld_Run_DATE,
           @Ad_Status_DATE                      = @Ld_Run_DATE,
           @Ac_Status_CODE                      = @Lc_PendingStatus_CODE,
           @Ac_SourceVerified_CODE              = @Lc_SourceVerified_CODE,
           @As_DescriptionComments_TEXT         = @Ls_DescriptionComments_TEXT,
           @As_DescriptionServiceDirection_TEXT = @Ls_DescriptionServiceDirection_TEXT,
           @Ac_Process_ID                       = @Lc_Process_ID,
           @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
           @An_OfficeSignedOn_IDNO              = @Ln_Office_IDNO,
           @Ac_Normalization_CODE               = @Lc_PudmCur_SerAddrNorm_CODE,
           @Ac_CcrtMemberAddress_CODE           = @Lc_Space_TEXT,
           @Ac_CcrtCaseRelationship_CODE        = @Lc_Space_TEXT,
           @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END;
          ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE 
           BEGIN
            SET @Lb_AhisServiceAddress_CODE = 1;

            --13838 - Assigning latest record address status -START-
            IF @Lc_ConfirmedGoodStatus_CODE = (SELECT TOP 1 Status_CODE
                                                 FROM AHIS_Y1 a
                                                WHERE a.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO
                                                  AND a.TypeAddress_CODE = @Lc_ResidentailTypeAddress_CODE
                                                  AND a.Begin_DATE = @Ld_Run_DATE
                                                  AND a.SourceLoc_CODE = @Lc_PutSourceLoc_CODE
                                                  ORDER BY a.TransactionEventSeq_NUMB DESC)
             BEGIN
              SET @Lc_ServiceActivityMinor_CODE = @Lc_ActivityMinorRcona_CODE;
             END
            ELSE IF @Lc_PendingStatus_CODE = (SELECT TOP 1 Status_CODE
                                                 FROM AHIS_Y1 a
                                                WHERE a.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO
                                                  AND a.TypeAddress_CODE = @Lc_ResidentailTypeAddress_CODE
                                                  AND a.Begin_DATE = @Ld_Run_DATE
                                                  AND a.SourceLoc_CODE = @Lc_PutSourceLoc_CODE
                                                  ORDER BY a.TransactionEventSeq_NUMB DESC)
             BEGIN
              SET @Lc_ServiceActivityMinor_CODE = @Lc_ActivityMinorRunca_CODE;
             END
            ELSE 
             BEGIN 
              SET @Lb_AhisServiceAddress_CODE = 0;
             END 
            --13838 - Assigning latest record address status -END-
           END;
          ELSE IF @Lc_Msg_CODE != @Lc_ErrorE1089_CODE 
           BEGIN
            SET @Lb_AhisServiceAddress_CODE = 0;
            SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord1_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
            SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 3 ';
            SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_Msg_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_BateRecord_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

            EXECUTE BATCH_COMMON$SP_BATE_LOG
             @As_Process_NAME             = @Ls_Process_NAME,
             @As_Procedure_NAME           = @Ls_Procedure_NAME,
             @Ac_Job_ID                   = @Lc_Job_ID,
             @Ad_Run_DATE                 = @Ld_Run_DATE,
             @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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
       END

      IF @Ls_PudmCur_Empl1_ADDR <> @Lc_Space_TEXT
          OR @Ls_PudmCur_Empl2_ADDR <> @Lc_Space_TEXT
          OR @Lc_PudmCur_EmplCity_ADDR <> @Lc_Space_TEXT
          OR @Lc_PudmCur_EmplZip_ADDR <> @Lc_Space_TEXT
          OR @Lc_PudmCur_EmplState_ADDR <> @Lc_Space_TEXT
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
        SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpEmployer_CODE, '') + ', OtherParty_NAME = ' + ISNULL(@Lc_PudmCur_Empl_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Ls_PudmCur_Empl1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_PudmCur_Empl2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_PudmCur_EmplCity_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Lc_PudmCur_EmplZip_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_PudmCur_EmplState_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Phone_NUMB = ' + ISNULL(CAST(@Ln_PudmCurEmplPhone_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_PutSourceLoc_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', DchCarrier_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Normalization_CODE = ' + ISNULL(@Lc_PudmCur_EmplAddrNorm_CODE, '') + ', Process_ID = ' + ISNULL(@Lc_Space_TEXT, '');

        EXECUTE BATCH_COMMON$SP_GET_OTHP
         @Ad_Run_DATE                     = @Ld_Run_DATE,
         @An_Fein_IDNO                    = @Ln_Zero_NUMB,
         @Ac_TypeOthp_CODE                = @Lc_TypeOthpEmployer_CODE,
         @As_OtherParty_NAME              = @Lc_PudmCur_Empl_NAME,
         @Ac_Aka_NAME                     = @Lc_Space_TEXT,
         @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
         @As_Line1_ADDR                   = @Ls_PudmCur_Empl1_ADDR,
         @As_Line2_ADDR                   = @Ls_PudmCur_Empl2_ADDR,
         @Ac_City_ADDR                    = @Lc_PudmCur_EmplCity_ADDR,
         @Ac_Zip_ADDR                     = @Lc_PudmCur_EmplZip_ADDR,
         @Ac_State_ADDR                   = @Lc_PudmCur_EmplState_ADDR,
         @Ac_Fips_CODE                    = @Lc_Space_TEXT,
         @Ac_Country_ADDR                 = @Lc_Country_ADDR,
         @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
         @An_Phone_NUMB                   = @Ln_PudmCurEmplPhone_NUMB,
         @An_Fax_NUMB                     = @Ln_Zero_NUMB,
         @As_Contact_EML                  = @Lc_Space_TEXT,
         @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
         @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
         @An_Sein_IDNO                    = @Ln_Zero_NUMB,
         @Ac_SourceLoc_CODE               = @Lc_PutSourceLoc_CODE,
         @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
         @An_DchCarrier_IDNO              = @Ln_Zero_NUMB,
         @Ac_Normalization_CODE           = @Lc_PudmCur_EmplAddrNorm_CODE,
         @Ac_Process_ID                   = @Lc_Process_ID,
         @An_OtherParty_IDNO              = @Ln_OthpPartyEmpl_IDNO OUTPUT,
         @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE -1 ';
          SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PudmCurMemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_EmployerStatusY_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_TypeIncome_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_SourceLocConfA_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Ln_IncomeGross_AMNT AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Ln_IncomeNet_AMNT AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_WeeklyFreqIncome_CODE, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_FreqPay_CODE, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_NLimitCcpa_INDC, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_YInsReasonable_CODE, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_PutSourceLoc_CODE, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_YInsProvider_INDC, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_NDpCovered_INDC, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_YDpCoverageAvlb_INDC, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Ln_CostInsurance_AMNT AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_FreqInsurance_CODE, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_DescriptionOccupation_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Process_ID, '') + ', OfficeSignedOn_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
           @An_MemberMci_IDNO             = @Ln_PudmCurMemberMci_IDNO,
           @An_OthpPartyEmpl_IDNO         = @Ln_OthpPartyEmpl_IDNO,
           @Ad_SourceReceived_DATE        = @Ld_Run_DATE,
           @Ac_Status_CODE                = @Lc_EmployerStatusY_CODE,
           @Ad_Status_DATE                = @Ld_Run_DATE,
           @Ac_TypeIncome_CODE            = @Lc_TypeIncome_CODE,
           @Ac_SourceLocConf_CODE         = @Lc_SourceLocConfA_CODE,
           @Ad_Run_DATE                   = @Ld_Run_DATE,
           @Ad_BeginEmployment_DATE       = @Ld_Run_DATE,
           @Ad_EndEmployment_DATE         = @Ld_High_DATE,
           @An_IncomeGross_AMNT           = @Ln_IncomeGross_AMNT,
           @An_IncomeNet_AMNT             = @Ln_IncomeNet_AMNT,
           @Ac_FreqIncome_CODE            = @Lc_WeeklyFreqIncome_CODE,
           @Ac_FreqPay_CODE               = @Lc_FreqPay_CODE,
           @Ac_LimitCcpa_INDC             = @Lc_NLimitCcpa_INDC,
           @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
           @Ac_InsReasonable_INDC         = @Lc_YInsReasonable_CODE,
           @Ac_SourceLoc_CODE             = @Lc_PutSourceLoc_CODE,
           @Ac_InsProvider_INDC           = @Lc_YInsProvider_INDC,
           @Ac_DpCovered_INDC             = @Lc_NDpCovered_INDC,
           @Ac_DpCoverageAvlb_INDC        = @Lc_YDpCoverageAvlb_INDC,
           @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
           @An_CostInsurance_AMNT         = @Ln_CostInsurance_AMNT,
           @Ac_FreqInsurance_CODE         = @Lc_FreqInsurance_CODE,
           @Ac_DescriptionOccupation_TEXT = @Lc_DescriptionOccupation_TEXT,
           @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
           @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
           @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
           @Ac_Process_ID                 = @Lc_Process_ID,
           @An_OfficeSignedOn_IDNO        = @Ln_Zero_NUMB,
           @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

          IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END;
         END
       END

      DECLARE CaseMember_Cur INSENSITIVE CURSOR FOR
       SELECT a.Case_IDNO,
              a.MemberMci_IDNO
         FROM CMEM_Y1 a,
              CASE_Y1 b
        WHERE a.MemberMci_IDNO = @Ln_PudmCurMemberMci_IDNO
          AND a.CaseMemberStatus_CODE = @Lc_ActiveCaseMemberStatus_CODE
		  AND a.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutative_CODE, @Lc_CaseRelationshipCp_CODE)
          AND a.Case_IDNO = b.Case_IDNO
          AND b.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;

      SET @Ls_Sql_TEXT = 'OPEN CaseMember_Cur';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + @Lc_PudmCur_MemberMciIdno_TEXT;

      OPEN CaseMember_Cur;

      SET @Ls_Sql_TEXT = 'FETCH CaseMember_Cur - 1';
      SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + @Lc_PudmCur_MemberMciIdno_TEXT;

      FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

      -- Cursor will pick all cases of the member.
      WHILE @Li_FetchStatus_QNTY = 0
       BEGIN
        IF @Lb_AhisBillingAddress_CODE = 1
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 1';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_BillingActivityMinor_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', DescriptionNote_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarcodeIn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_BillingActivityMinor_CODE,
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

          IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        IF @Lb_AhisServiceAddress_CODE = 1
           AND @Lc_BillingActivityMinor_CODE <> @Lc_ServiceActivityMinor_CODE
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 2';
          SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ServiceActivityMinor_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', DescriptionNote_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarcodeIn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

          EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_ServiceActivityMinor_CODE,
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

          IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
           BEGIN
            RAISERROR (50001,16,1);
           END
         END

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - 3';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorRrfpu_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '') + ', DescriptionNote_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', WorkerDelegate_ID = ' + ISNULL(@Lc_WorkerDelegate_ID, '') + ', SignedonWorker_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_IDNO, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Notice_ID = ' + ISNULL(@Lc_Notice_ID, '') + ', TopicIn_IDNO = ' + ISNULL(CAST(@Ln_TopicIn_IDNO AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', Schedule_NUMB = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', Schedule_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginSch_DTTM = ' + ISNULL(CAST(@Ld_BeginSch_DTTM AS VARCHAR), '') + ', OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR), '') + ', ScheduleWorker_ID = ' + ISNULL(@Lc_Schedule_Worker_IDNO, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(@Lc_Schedule_Member_IDNO, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_OthpSource_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_OthStateFips_CODE, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@Ln_Schedule_NUMB AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarcodeIn_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');
        
		IF NOT EXISTS(SELECT 1 
						FROM UDMNR_V1 c
					   WHERE c.Case_IDNO = @Ln_CaseMemberCur_Case_IDNO
					     AND c.MemberMci_IDNO = @Ln_CaseMemberCur_MemberMci_IDNO
					     AND c.ActivityMinor_CODE = @Lc_ActivityMinorRrfpu_CODE
					     AND c.Entered_DATE = @Ld_Run_DATE
						  ) 
         BEGIN
			EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
			 @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
			 @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
			 @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
			 @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRrfpu_CODE,
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

			IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			 BEGIN
			  RAISERROR (50001,16,1);
			 END
         END

        SET @Ls_Sql_TEXT = 'FETCH CaseMember_Cur - 2';
        SET @Ls_Sqldata_TEXT = 'Cursor Previous Record Case_IDNO = ' + CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR);

        FETCH NEXT FROM CaseMember_Cur INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       END;

      CLOSE CaseMember_Cur;

      DEALLOCATE CaseMember_Cur;

      SET @Ls_Sql_TEXT = 'INSERTING INTO HDEMO_Y1';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_PudmCurMemberMci_IDNO AS VARCHAR), '') + ', BirthCity_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', HomePhone_NUMB = ' + ISNULL('0', '') + ', CellPhone_NUMB = ' + ISNULL(CAST(@Ln_PudmCurPhone_NUMB AS VARCHAR), '') + ', WorkPhone_NUMB = ' + ISNULL('0', '') + ', Birth_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

      EXECUTE BATCH_COMMON$SP_UPDATE_DEMO
       @An_MemberMci_IDNO        = @Ln_PudmCurMemberMci_IDNO,
       @Ac_BirthCity_NAME        = @Lc_Space_TEXT,
       @An_HomePhone_NUMB        = 0,
       @An_CellPhone_NUMB        = @Ln_PudmCurPhone_NUMB,
       @An_WorkPhone_NUMB        = 0,
       @Ad_Birth_DATE            = @Ld_Low_DATE,
       @Ac_Process_ID            = @Lc_Process_ID,
       @Ad_Process_DATE          = @Ld_Run_DATE,
       @Ac_WorkerUpdate_ID       = @Lc_BatchRunUser_TEXT,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lb_ErrorExpection_CODE = 1
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END TRY

     BEGIN CATCH
      BEGIN
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION SAVEPUDM_PROCESS;
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

       SET @Ls_BateRecord_TEXT = 'Error Record = ' + @Ls_BateRecord1_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 4';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', MemberMci_IDNO = ' + @Lc_PudmCur_MemberMciIdno_TEXT;

       IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_StatusSuccess_CODE, @Lc_Space_TEXT)
        BEGIN
         SET @Lc_Msg_CODE = @Lc_BateError_CODE;
        END

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
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

     SET @Ls_Sql_TEXT = 'UPDATE LPUDM_Y1, Seq_IDNO = ' + CAST(@Ln_PudmCur_Seq_IDNO AS VARCHAR);
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', Seq_IDNO = ' + CAST(@Ln_PudmCur_Seq_IDNO AS VARCHAR);

     UPDATE LPUDM_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_PudmCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = @Lc_Err0002_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
     SET @Ls_Sql_TEXT = 'UPDATE LPUDM_Y1, Seq_IDNO = ' + CAST(@Ln_PudmCur_Seq_IDNO AS VARCHAR);
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', Seq_IDNO = ' + ISNULL(CAST(@Ln_PudmCur_HeaderSeq_IDNO AS VARCHAR), '') + ', HeaderSeq_IDNO = ' + ISNULL(CAST(@Ln_PudmCur_HeaderSeq_IDNO AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_ProcessN_INDC, '');

     UPDATE LHPUD_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_PudmCur_HeaderSeq_IDNO
        AND NOT EXISTS (SELECT 1
                          FROM LPUDM_Y1
                         WHERE HeaderSeq_IDNO = @Ln_PudmCur_HeaderSeq_IDNO
                           AND Process_INDC = @Lc_ProcessN_INDC);

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 1';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       COMMIT TRANSACTION PUDM_PROCESS;

       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       BEGIN TRANSACTION PUDM_PROCESS;

       SET @Ln_CommitFreq_QNTY = 0;
      END;

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;

       COMMIT TRANSACTION PUDM_PROCESS;

       SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Pudm_CUR - 2';
     SET @Ls_Sqldata_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM Pudm_CUR INTO @Ln_PudmCur_Seq_IDNO, @Ln_PudmCur_HeaderSeq_IDNO, @Lc_PudmCur_RecId_TEXT, @Lc_PudmCur_MemberSsnNumb_TEXT, @Lc_PudmCur_MemberMciIdno_TEXT, @Lc_PudmCur_Last_NAME, @Lc_PudmCur_First_NAME, @Lc_PudmCur_Middle_NAME, @Lc_PudmCur_Title_NAME, @Lc_PudmCur_PhoneNumb_TEXT, @Lc_PudmCur_Bill_NAME, @Lc_PudmCur_BillingPhoneNumb_TEXT, @Lc_PudmCur_Empl_NAME, @Lc_PudmCur_EmployerPhoneNumb_TEXT, @Lc_PudmCur_SerAddrNorm_CODE, @Ls_PudmCur_SerLine1_ADDR, @Ls_PudmCur_SerLine2_ADDR, @Lc_PudmCur_SerCity_ADDR, @Lc_PudmCur_SerState_ADDR, @Lc_PudmCur_SerZip_ADDR, @Lc_PudmCur_BillAddrNorm_CODE, @Ls_PudmCur_Bill1_ADDR, @Ls_PudmCur_Bill2_ADDR, @Lc_PudmCur_BillCity_ADDR, @Lc_PudmCur_BillState_ADDR, @Lc_PudmCur_BillZip_ADDR, @Lc_PudmCur_EmplAddrNorm_CODE, @Ls_PudmCur_Empl1_ADDR, @Ls_PudmCur_Empl2_ADDR, @Lc_PudmCur_EmplCity_ADDR, @Lc_PudmCur_EmplState_ADDR, @Lc_PudmCur_EmplZip_ADDR;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_RestartLine_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_RestartLine_NUMB,
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

   CLOSE Pudm_CUR;

   DEALLOCATE Pudm_CUR;

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
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_INDC, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_INDC,
    @As_ListKey_TEXT              = @Lc_Successful_INDC,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'TRASACTION COMMIT - 2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION PUDM_PROCESS;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION PUDM_PROCESS;
    END

   IF CURSOR_STATUS ('LOCAL', 'Pudm_CUR') IN (0, 1)
    BEGIN
     CLOSE Pudm_CUR;

     DEALLOCATE Pudm_CUR;
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
  END CATCH
 END


GO
