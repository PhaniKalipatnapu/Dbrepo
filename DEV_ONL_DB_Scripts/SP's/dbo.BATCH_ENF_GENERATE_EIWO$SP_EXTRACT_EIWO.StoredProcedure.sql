/****** Object:  StoredProcedure [dbo].[BATCH_ENF_GENERATE_EIWO$SP_EXTRACT_EIWO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_GENERATE_EIWO$SP_EXTRACT_EIWO
Programmer Name	:	IMP Team.
Description		:	The process extracts all the members who are eligible for e-IWO and creates an output file instead of generating a notice.
                       1. This  batch program scans Major Activity (DMJR_Y1) table and Minor Activity (DMNR_Y1) table
                          to retrieve cases which have active Income Withholding remedy, the batch program then checks
                          if non-end dated employers electronic IWN (Income Withholding Notice) value is equal to 'yes'
                          on Other Party (OTHP_Y1) database table, if yes, an electronic income withholding will be generated,
                          the paper notice will not generated.r.
                       2. This  batch program scans Major Activity (DMJR_Y1) table and Minor Activity (DMNR_Y1) table
                          to retrieve cases which are eligible for a modified or terminated notice and the non-end dated employer's
                          Electronic IWN value is equal to 'yes' on Other Party (OTHP_Y1) database table,
                          and electronic modified or terminated income withholding will be generated,
                          the paper notice will not generated.
                       3. Before this batch Program run following batch program to feed inputs.
                               a. BATCH_ENF_STAGING$SP_INSERT_ENSD_COMMON
                               a. BATCH_ENF_ELFC and
                               b. BATCH_ENF_EMON
Frequency		:	WEEKLY
Developed On	:	01/20/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_GENERATE_EIWO$SP_EXTRACT_EIWO]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE CHAR(1) = 'A',
          @Lc_ErrrorTypeW_CODE       CHAR(1) = 'W',
          @Lc_Weekly_CODE            CHAR(1) = 'W',
          @Lc_Monthly_CODE           CHAR(1) = 'M',
          @Lc_Quarterly_CODE         CHAR(1) = 'Q',
          @Lc_Yes_INDC               CHAR(1) = 'Y',
          @Lc_Annual_CODE            CHAR(1) = 'A',
          @Lc_No_INDC                CHAR(1) = 'N',
          @Lc_MedicalSupport_CODE    CHAR(1) = 'MS',
          @Lc_Active_CODE            CHAR(1) = 'A',
          @Lc_Pending_CODE           CHAR(1) = 'P',
          @Lc_TypeOrderV_CODE        CHAR(1) = 'V',
          @Lc_BiWeekly_CODE          CHAR(2) = 'BW',
          @Lc_SemiMonthly_CODE       CHAR(2) = 'SM',
          @Lc_ChildSupport_CODE      CHAR(2) = 'CS',
          @Lc_SpouseSupport_CODE     CHAR(2) = 'SS',
          @Lc_OneTime_CODE           CHAR(2) = 'OT',
          @Lc_ActionTrm_CODE         CHAR(3) = 'TRM',
          @Lc_ActionOrg_CODE         CHAR(3) = 'ORG',
          @Lc_ActionAmd_CODE         CHAR(3) = 'AMD',
          @Lc_TableIdUsem_ID         CHAR(4) = 'USEM',
          @Lc_TableSubIdTtls_ID      CHAR(4) = 'TTLS',
          @Lc_BatchRunUser_TEXT      CHAR(5) = 'BATCH',
          @Lc_ErrrorE0944_CODE       CHAR(5) = 'E0944',
          @Lc_Job_ID                 CHAR(7) = 'DEB1250',
          @Lc_Successful_TEXT        CHAR(20) = 'SUCCESSFUL',
          @Lc_StateDe_ADDR           CHAR(35) = 'DELAWARE',
          @Ls_Process_NAME           VARCHAR(100) = 'BATCH_ENF_GENERATE_EIWO',
          @Ls_Procedure_NAME         VARCHAR(100) = 'SP_EXTRACT_EIWO',
          @Ld_High_DATE              DATE = '12/31/9999',
          @Ld_Low_DATE               DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1, 0) = 0,
          @Ln_Rowcount_QNTY               NUMERIC,
          @Ln_WithheldPercent_NUMB        NUMERIC(5, 0),
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_CommitFrequency_QNTY        NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_FeinOld_IDNO                NUMERIC(9) = 0,
          @Ln_OtherParty_IDNO             NUMERIC(9),
          @Ln_WorkPhone_NUMB              NUMERIC(10, 0),
          @Ln_OfficeFax_NUMB              NUMERIC(10, 0),
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_Annual_AMNT                 NUMERIC(11, 2) = 0,
          @Ln_CurMd_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_Payback_AMNT                NUMERIC(11, 2) = 0,
          @Ln_PaybackCs_AMNT              NUMERIC(11, 2) = 0,
          @Ln_CurCs_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_CurSs_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_CurMs_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_CurOt_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_PaybackMs_AMNT              NUMERIC(11, 2) = 0,
          @Ln_PaybackSs_AMNT              NUMERIC(11, 2) = 0,
          @Ln_BatchCount_NUMB             NUMERIC(11) = 0,
          @Ln_HeaderBatchCount_NUMB       NUMERIC(11) = 0,
          @Ln_TrailerBatchCount_NUMB      NUMERIC(11) = 0,
          @Ln_FileTrailerBatchCount_NUMB  NUMERIC(11) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) = 0,
          @Ln_LumpSum_AMNT                NUMERIC(11, 2) = 0,
          @Ln_TotalCur_AMNT               NUMERIC(11, 2) = 0,
          @Li_FetchStatus_QNTY            SMALLINT,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_FreqCs_CODE                 CHAR(1) = '',
          @Lc_FreqSs_CODE                 CHAR(1) = '',
          @Lc_FreqMs_CODE                 CHAR(1) = '',
          @Lc_FreqOt_CODE                 CHAR(1) = '',
          @Lc_PaybackFreqMs_CODE          CHAR(1) = '',
          @Lc_PaybackFreqSs_CODE          CHAR(1) = '',
          @Lc_PaybackFreqcs_CODE          CHAR(1) = '',
          @Lc_ArrearAged_INDC             CHAR(1) = '',
          @Lc_FreqMd_CODE                 CHAR(1) = '',
          @Lc_FreqPayback_CODE            CHAR(1) = '',
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Lc_TypeDebt_CODE               CHAR(2) = '',
          @Lc_State_ADDR                  CHAR(2),
          @Lc_FreqPer_CODE                CHAR(5) = '',
          @Lc_Case_IDNO                   CHAR(6),
          @Lc_Zip_ADDR                    CHAR(9),
          @Lc_WorkerFirst_NAME            CHAR(20),
          @Lc_WorkerMiddle_NAME           CHAR(20),
          @Lc_Control_TEXT                CHAR(22),
          @Lc_City_ADDR                   CHAR(22),
          @Lc_WorkerLast_NAME             CHAR(25),
          @Lc_Line1_ADDR                  CHAR(25),
          @Lc_Line2_ADDR                  CHAR(25),
          @Lc_Worker_ID                   CHAR(30),
          @Lc_DocumentTracking_NUMB       CHAR(30),
          @Lc_JrsdictionParty_NAME        CHAR(35),
          @Ls_WorkerTitle_CODE            VARCHAR(50),
          @Ls_FileName_TEXT               VARCHAR(50),
          @Ls_WorkerEmail_EML             VARCHAR(100),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT                    VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_BcpCommand_TEXT             VARCHAR(1000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_ReturnValue_TEXT            VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;
  DECLARE @Ln_ExtEiwCur_Case_IDNO           NUMERIC(6),
          @Ln_ExtEiwCur_OrderSeq_NUMB       NUMERIC(2) = 0,
          @Ln_ExtEiwCur_OthpSource_IDNO     NUMERIC(9),
          @Ln_ExtEiwCur_MemberMci_IDNO      NUMERIC(10),
          @Ln_ExtEiwCur_Fein_IDNO           NUMERIC(9),
          @Ls_ExtEiwCur_EmpOtherParty_NAME  VARCHAR(57),
          @Lc_ExtEiwCur_EmpLine1_ADDR       CHAR(25),
          @Lc_ExtEiwCur_EmpLine2_ADDR       CHAR(25),
          @Lc_ExtEiwCur_EmpCity_ADDR        CHAR(22),
          @Lc_ExtEiwCur_EmpState_ADDR       CHAR(2),
          @Lc_ExtEiwCur_EmpZip_ADDR         CHAR(9),
          @Lc_ExtEiwCur_LastNcp_NAME        CHAR(20),
          @Lc_ExtEiwCur_FirstNcp_NAME       CHAR(15),
          @Lc_ExtEiwCur_MiNcp_NAME          CHAR(15),
          @Lc_ExtEiwCur_SuffixNcp_NAME      CHAR(4),
          @Ln_ExtEiwCur_MemberSsn_NUMB      NUMERIC(9),
          @Ld_ExtEiwCur_BirthNcp_DATE       DATE,
          @Ls_ExtEiwCur_LastCp_NAME         VARCHAR(57),
          @Lc_ExtEiwCur_FirstCp_NAME        CHAR(15),
          @Lc_ExtEiwCur_MiCp_NAME           CHAR(15),
          @Lc_ExtEiwCur_SuffixCp_NAME       CHAR(4),
          @Lc_ExtEiwCur_File_ID             CHAR(10),
          @Lc_ExtEiwCur_NewIwo_INDC         CHAR(1),
          @Lc_ExtEiwCur_TerminateIwo_INDC   CHAR(1),
          @Ld_ExtEiwCur_Entered_DATE        DATE,
          @Ld_ExtEiwCur_Status_DATE         DATE,
          @Lc_ExtEiwCur_ActivityMinor_CODE  CHAR(5),
          @Lc_ExtEiwCur_ReasonStatus_CODE   CHAR(2),
          @Lc_ExtEiwCur_TypeOthpSource_CODE CHAR(1),
          @Ln_ExtEiwCur_MajorIntSeq_NUMB    NUMERIC(5),
          @Ln_ExtEiwCur_MinorIntSeq_NUMB    NUMERIC(5);
  DECLARE @Lc_EiwoRecCur_DocumentAction_CODE                CHAR(3),
          @Lc_EiwoRecCur_Document_DATE                      CHAR(8),
          @Lc_EiwoRecCur_IssuingState_CODE                  CHAR(35),
          @Lc_EiwoRecCur_IssuingJurisdiction_NAME           CHAR(35),
          @Ln_EiwoRecCur_Case_IDNO                          NUMERIC(6),
          @Ls_EiwoRecCur_Employer_NAME                      VARCHAR(57),
          @Lc_EiwoRecCur_EmployerLine1_ADDR                 CHAR(25),
          @Lc_EiwoRecCur_EmployerLine2_ADDR                 CHAR(25),
          @Lc_EiwoRecCur_EmployerCity_ADDR                  CHAR(22),
          @Lc_EiwoRecCur_EmployerState_ADDR                 CHAR(2),
          @Lc_EiwoRecCur_EmployerZip_ADDR                   CHAR(9),
          @Ln_EiwoRecCur_Fein_IDNO                          NUMERIC(9),
          @Lc_EiwoRecCur_NcpLast_NAME                       CHAR(20),
          @Lc_EiwoRecCur_NcpFirst_NAME                      CHAR(15),
          @Lc_EiwoRecCur_NcpMi_NAME                         CHAR(15),
          @Lc_EiwoRecCur_NcpSuffix_NAME                     CHAR(4),
          @Ln_EiwoRecCur_MemberSsn_NUMB                     NUMERIC(9),
          @Ld_EiwoRecCur_NcpBirth_DATE                      DATE,
          @Ls_EiwoRecCur_CpLast_NAME                        VARCHAR(57),
          @Lc_EiwoRecCur_CpFirst_NAME                       CHAR(15),
          @Lc_EiwoRecCur_CpMiddle_NAME                      CHAR(15),
          @Lc_EiwoRecCur_CpSuffix_NAME                      CHAR(4),
          @Lc_EiwoRecCur_IssuingTribunal_NAME               CHAR(35),
          @Ln_EiwoRecCur_CurCs_AMNT                         NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_FreqCs_CODE                        CHAR(1) = '',
          @Ln_EiwoRecCur_PaybackCs_AMNT                     NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_PaybackFreqcs_CODE                 CHAR(1) = '',
          @Ln_EiwoRecCur_CurMs_AMNT                         NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_FreqMs_CODE                        CHAR(1) = '',
          @Ln_EiwoRecCur_PaybackMs_AMNT                     NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_PaybackFreqMs_CODE                 CHAR(1) = '',
          @Ln_EiwoRecCur_CurSs_AMNT                         NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_FreqSs_CODE                        CHAR(1) = '',
          @Ln_EiwoRecCur_PaybackSs_AMNT                     NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_PaybackFreqSs_CODE                 CHAR(1) = '',
          @Ln_EiwoRecCur_CurOt_AMNT                         NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_FreqOt_CODE                        CHAR(1) = '',
          @Lc_EiwoRecCur_ReasonOt_CODE                      CHAR(35),
          @Ln_EiwoRecCur_TotalCur_AMNT                      NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_FreqTotal_CODE                     CHAR(1) = '',
          @Lc_EiwoRecCur_Arr12WkDue_CODE                    CHAR(1),
          @Ln_EiwoRecCur_WeeklyWithheld_AMNT                NUMERIC(11, 2) = 0,
          @Ln_EiwoRecCur_BiweeklyWithheld_AMNT              NUMERIC(11, 2) = 0,
          @Ln_EiwoRecCur_MonthlyWithheld_AMNT               NUMERIC(11, 2) = 0,
          @Ln_EiwoRecCur_SemiMonthlyWithheld_AMNT           NUMERIC(11, 2) = 0,
          @Lc_EiwoRecCur_SendingState_NAME                  CHAR(35),
          @Lc_EiwoRecCur_DaysBeginWithhold_NUMB             CHAR(2),
          @Lc_EiwoRecCur_IwoStart_DATE                      CHAR(8),
          @Lc_EiwoRecCur_DaysBeginPayment_NUMB              CHAR(2),
          @Ln_EiwoRecCur_CcpaPercent_NUMB                   NUMERIC(3),
          @Ls_EiwoRecCur_Payee_NAME                         VARCHAR(57) = 'Division of Child Support Enforcement',
          @Lc_EiwoRecCur_PayeeLine1_ADDR                    CHAR(25) = 'P.O. Box 12287',
          @Lc_EiwoRecCur_PayeeLine2_ADDR                    CHAR(25) = '',
          @Lc_EiwoRecCur_PayeeCity_ADDR                     CHAR(22) = 'Wilmington',
          @Lc_EiwoRecCur_PayeeState_ADDR                    CHAR(2) = 'DE',
          @Lc_EiwoRecCur_PayeeZip_ADDR                      CHAR(9) = '19850',
          @Lc_EiwoRecCur_FipsRemittance_CODE                CHAR(7) = '1000000',
          @Ls_EiwoRecCur_StateOfficial_NAME                 VARCHAR(70),
          @Ls_EiwoRecCur_StateOfficialTitle_NAME            VARCHAR(50),
          @Lc_EiwoRecCur_EmployeeCopy_INDC                  CHAR(1),
          @Ls_EiwoRecCur_PenalityLiabilityDescription_TEXT  VARCHAR(160),
          @Ls_EiwoRecCur_AntiDiscriminationDescription_TEXT VARCHAR(160),
          @Ls_EiwoRecCur_PayeeWitholdLimitDescription_TEXT  VARCHAR(160),
          @Ls_EiwoRecCur_EmployeeContact_NAME               VARCHAR(57),
          @Lc_EiwoRecCur_EmployeeContactPhone_NUMB          CHAR(10),
          @Lc_EiwoRecCur_EmployeeContactFax_NUMB            CHAR(10),
          @Ls_EiwoRecCur_EmployeeContactEmail_EML           VARCHAR(48),
          @Lc_EiwoRecCur_DocumentTacking_NUMB               CHAR(30),
          @Lc_EiwoRecCur_Order_IDNO                         CHAR(15),
          @Ls_EiwoRecCur_EmployerContact_NAME               VARCHAR(57),
          @Lc_EiwoRecCur_EmployerContactLine1_ADDR          CHAR(25),
          @Lc_EiwoRecCur_EmployerContactLine2_ADDR          CHAR(25),
          @Lc_EiwoRecCur_EmployerContactCity_ADDR           CHAR(22),
          @Lc_EiwoRecCur_EmployerContactState_ADDR          CHAR(2),
          @Lc_EiwoRecCur_EmployerContactZip_ADDR            CHAR(9),
          @Lc_EiwoRecCur_EmployerContactPhone_NUMB          CHAR(10),
          @Lc_EiwoRecCur_EmployerContactFax_NUMB            CHAR(10),
          @Ls_EiwoRecCur_EmployerContactEmail_EML           VARCHAR(48),
          @Lc_EiwoRecCur_ChildLast1_NAME                    CHAR(19),
          @Lc_EiwoRecCur_ChildFirst1_NAME                   CHAR(14),
          @Lc_EiwoRecCur_ChildMiddle1_NAME                  CHAR(14),
          @Lc_EiwoRecCur_ChildSuffix1_NAME                  CHAR(3),
          @Ld_EiwoRecCur_ChildBirth1_DATE                   DATE,
          @Lc_EiwoRecCur_ChildLast2_NAME                    CHAR(19),
          @Lc_EiwoRecCur_ChildFirst2_NAME                   CHAR(14),
          @Lc_EiwoRecCur_ChildMiddle2_NAME                  CHAR(14),
          @Lc_EiwoRecCur_ChildSuffix2_NAME                  CHAR(3),
          @Ld_EiwoRecCur_ChildBirth2_DATE                   DATE,
          @Lc_EiwoRecCur_ChildLast3_NAME                    CHAR(19),
          @Lc_EiwoRecCur_ChildFirst3_NAME                   CHAR(14),
          @Lc_EiwoRecCur_ChildMiddle3_NAME                  CHAR(14),
          @Lc_EiwoRecCur_ChildSuffix3_NAME                  CHAR(3),
          @Ld_EiwoRecCur_ChildBirth3_DATE                   DATE,
          @Lc_EiwoRecCur_ChildLast4_NAME                    CHAR(19),
          @Lc_EiwoRecCur_ChildFirst4_NAME                   CHAR(14),
          @Lc_EiwoRecCur_ChildMiddle4_NAME                  CHAR(14),
          @Lc_EiwoRecCur_ChildSuffix4_NAME                  CHAR(3),
          @Ld_EiwoRecCur_ChildBirth4_DATE                   DATE,
          @Lc_EiwoRecCur_ChildLast5_NAME                    CHAR(19),
          @Lc_EiwoRecCur_ChildFirst5_NAME                   CHAR(14),
          @Lc_EiwoRecCur_ChildMiddle5_NAME                  CHAR(14),
          @Lc_EiwoRecCur_ChildSuffix5_NAME                  CHAR(3),
          @Ld_EiwoRecCur_ChildBirth5_DATE                   DATE,
          @Lc_EiwoRecCur_ChildLast6_NAME                    CHAR(19),
          @Lc_EiwoRecCur_ChildFirst6_NAME                   CHAR(14),
          @Lc_EiwoRecCur_ChildMiddle6_NAME                  CHAR(14),
          @Lc_EiwoRecCur_ChildSuffix6_NAME                  CHAR(3),
          @Ld_EiwoRecCur_ChildBirth6_DATE                   DATE,
          @Ln_EiwoRecCur_Remittance_IDNO                    NUMERIC(20),
          @Lc_EiwoRecCur_FirstError_NAME                    CHAR(32),
          @Lc_EiwoRecCur_SecondError_NAME                   CHAR(32),
          @Lc_EiwoRecCur_MultiError_INDC                    CHAR(1);

  BEGIN TRY
   BEGIN TRANSACTION EiwoTran;

   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ln_ProcessedRecordCount_QNTY = 0;
   SET @Ln_CommitFrequency_QNTY = 0;
   -- Selecting Date Run, Date Last Run, Commit Freq, Exception Threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_TEXT OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   -- Validation 1:Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'GET RESTART KEY DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Lc_Case_IDNO = LEFT(R.RestartKey_TEXT, 6)
     FROM RSTL_Y1 R
    WHERE R.Job_ID = @Lc_Job_ID
      AND R.Run_DATE = @Ld_Run_DATE;

   -- Delete the rows of the tables every time the batch is executed
   SET @Ls_Sql_TEXT = 'DELETE EEIWO_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE EEIWO_Y1;

   --cursor declaration
   DECLARE Exteiw_CUR INSENSITIVE CURSOR FOR
    WITH EligEiwo_CTE ( Case_IDNO, OrderSeq_NUMB, OthpSource_IDNO, MemberMci_IDNO, Status_DATE, ActivityMinor_CODE, ReasonStatus_CODE, Entered_DATE, TypeOthpSource_CODE, MajorIntSEQ_NUMB, MinorIntSeq_NUMB, DocumentAction_CODE)
         AS (SELECT j.Case_IDNO,
                    j.OrderSeq_NUMB,
                    j.OthpSource_IDNO,
                    j.MemberMci_IDNO,
                    d.Status_DATE,
                    d.ActivityMinor_CODE,
                    d.ReasonStatus_CODE,
                    j.Entered_DATE,
                    j.TypeOthpSource_CODE,
                    d.MajorIntSEQ_NUMB,
                    d.MinorIntSeq_NUMB,
                    CASE
                     WHEN f.ActivityMinorNext_CODE = 'RMDCY'
                      THEN 'TRM'
                     WHEN f.ActivityMinor_CODE != 'MPCOA'
                      THEN 'ORG'
                     ELSE 'AMD'
                    END AS DocumentAction_CODE
               FROM DMNR_y1 d
                    JOIN AFMS_Y1 f
                     ON f.ActivityMajor_CODE = 'IMIW'
                        AND f.Notice_ID = 'ENF-01'
                        AND f.Recipient_CODE = 'SI'
                        AND f.EndValidity_DATE = '12/31/9999'
                        AND f.ActivityMajor_CODE = d.ActivityMajor_CODE
                        AND f.ActivityMinor_CODE = d.ActivityMinor_CODE
                        AND f.Reason_CODE = d.ReasonStatus_CODE
                        AND f.ActivityMinorNext_CODE = d.ActivityMinorNext_CODE
                    JOIN DMJR_Y1 j
                     ON j.Case_IDNO = d.Case_IDNO
                        AND j.MajorIntseq_NUMB = d.MajorIntseq_NUMB
              WHERE d.Status_DATE > @Ld_LastRun_DATE
                AND d.Status_DATE <= @Ld_Run_DATE)
    SELECT EW.Case_IDNO,
           EW.OrderSeq_NUMB,
           EW.OthpSource_IDNO,
           EW.MemberMci_IDNO,
           o.Fein_IDNO,
           o.OtherParty_NAME AS Empl_NAME,
           o.Line1_ADDR AS Empl_Line1_ADDR,
           o.Line2_ADDR AS Empl_Line2_ADDR,
           o.City_ADDR AS Empl_City_ADDR,
           o.State_ADDR AS Empl_State_ADDR,
           o.Zip_ADDR AS Empl_Zip_ADDR,
           e.LastNcp_NAME,
           e.FirstNcp_NAME,
           e.MiddleNcp_NAME,
           e.SuffixNcp_NAME,
           e.VerifiedltinNcpOrpfSsn_NUMB AS MemberSsn_NUMB,
           e.BirthNcp_DATE,
           e.LastCp_NAME,
           e.FirstCp_NAME,
           e.MiddleCp_NAME,
           e.SuffixCp_NAME,
           e.File_ID,
           CASE
            WHEN EW.Entered_DATE > @Ld_LastRun_DATE
             THEN @Lc_Yes_INDC
            ELSE @Lc_No_INDC
           END NewIwo_INDC,
           CASE EW.DocumentAction_CODE
            WHEN 'TRM'
             THEN @Lc_Yes_INDC
            ELSE @Lc_No_INDC
           END AS TerminateIwo_INDC,
           EW.Entered_DATE,
           EW.Status_DATE,
           EW.ActivityMinor_CODE,
           EW.ReasonStatus_CODE,
           EW.TypeOthpSource_CODE,
           EW.MajorIntSEQ_NUMB,
           EW.MinorIntSeq_NUMB
      FROM ENSD_Y1 e
           JOIN (SELECT a.Case_IDNO,
                        a.OrderSeq_NUMB,
                        a.OthpSource_IDNO,
                        a.MemberMci_IDNO,
                        a.Status_DATE,
                        a.DocumentAction_CODE,
                        a.ActivityMinor_CODE,
                        a.ReasonStatus_CODE,
                        a.Entered_DATE,
                        a.TypeOthpSource_CODE,
                        a.MajorIntSEQ_NUMB,
                        a.MinorIntSeq_NUMB,
                        ROW_NUMBER () OVER ( PARTITION BY a.Case_IDNO, a.MemberMci_IDNO, a.OthpSource_IDNO ORDER BY a.MajorIntSEQ_NUMB DESC, a.MinorIntSeq_NUMB DESC, a.Status_DATE DESC) Row_NUMB
                   FROM ((SELECT t.Case_IDNO,
                                 t.OrderSeq_NUMB,
                                 t.OthpSource_IDNO,
                                 t.MemberMci_IDNO,
                                 t.Status_DATE,
                                 CASE
                                  WHEN DocumentAction_CODE = 'ORG'
                                   THEN 'AMD'
                                  ELSE DocumentAction_CODE
                                 END DocumentAction_CODE,
                                 t.ActivityMinor_CODE,
                                 t.ReasonStatus_CODE,
                                 t.Entered_DATE,
                                 t.TypeOthpSource_CODE,
                                 t.MajorIntSEQ_NUMB,
                                 t.MinorIntSeq_NUMB
                            FROM EIWT_Y1 t
                           WHERE t.Resend_INDC = @Lc_Yes_INDC
                             AND t.ReceivedAcknowledgement_DATE > @Ld_LastRun_DATE
                             AND t.ReceivedAcknowledgement_DATE <= @Ld_Run_DATE
                             AND NOT EXISTS (SELECT 1
                                               FROM EligEiwo_CTE de
                                              WHERE t.Case_IDNO = de.Case_IDNO
                                                AND t.OthpSource_IDNO = de.OthpSource_IDNO))
                         UNION ALL
                         SELECT Ecte.Case_IDNO,
                                Ecte.OrderSeq_NUMB,
                                Ecte.OthpSource_IDNO,
                                Ecte.MemberMci_IDNO,
                                Ecte.Status_DATE,
                                Ecte.DocumentAction_CODE,
                                Ecte.ActivityMinor_CODE,
                                Ecte.ReasonStatus_CODE,
                                Ecte.Entered_DATE,
                                Ecte.TypeOthpSource_CODE,
                                Ecte.MajorIntSEQ_NUMB,
                                Ecte.MinorIntSeq_NUMB
                           FROM EligEiwo_CTE Ecte -- New Income Withholding
                        ) a) EW
            ON EW.Case_IDNO = e.Case_IDNO
           JOIN OTHP_Y1 o
            ON EW.OthpSource_IDNO = o.OtherParty_IDNO
               AND EW.TypeOthpSource_CODE = o.TypeOthp_CODE
               AND o.Eiwn_INDC = @Lc_Yes_INDC
               AND o.EndValidity_DATE = @Ld_High_DATE
               AND EW.Row_NUMB = 1
     WHERE EXISTS (SELECT 1
                     FROM EHIS_Y1 e
                    WHERE e.OthpPartyEmpl_IDNO = EW.OthpSource_IDNO
                      AND e.MemberMci_IDNO = EW.MemberMci_IDNO
                      AND (e.EndEmployment_DATE = @Ld_High_DATE
                            OR e.EndEmployment_DATE > @Ld_LastRun_DATE
                               AND e.EndEmployment_DATE <= @Ld_Run_DATE))
     ORDER BY EW.OthpSource_IDNO;

   OPEN Exteiw_CUR;

   FETCH NEXT FROM Exteiw_CUR INTO @Ln_ExtEiwCur_Case_IDNO, @Ln_ExtEiwCur_OrderSeq_NUMB, @Ln_ExtEiwCur_OthpSource_IDNO, @Ln_ExtEiwCur_MemberMci_IDNO, @Ln_ExtEiwCur_Fein_IDNO, @Ls_ExtEiwCur_EmpOtherParty_NAME, @Lc_ExtEiwCur_EmpLine1_ADDR, @Lc_ExtEiwCur_EmpLine2_ADDR, @Lc_ExtEiwCur_EmpCity_ADDR, @Lc_ExtEiwCur_EmpState_ADDR, @Lc_ExtEiwCur_EmpZip_ADDR, @Lc_ExtEiwCur_LastNcp_NAME, @Lc_ExtEiwCur_FirstNcp_NAME, @Lc_ExtEiwCur_MiNcp_NAME, @Lc_ExtEiwCur_SuffixNcp_NAME, @Ln_ExtEiwCur_MemberSsn_NUMB, @Ld_ExtEiwCur_BirthNcp_DATE, @Ls_ExtEiwCur_LastCp_NAME, @Lc_ExtEiwCur_FirstCp_NAME, @Lc_ExtEiwCur_MiCp_NAME, @Lc_ExtEiwCur_SuffixCp_NAME, @Lc_ExtEiwCur_File_ID, @Lc_ExtEiwCur_NewIwo_INDC, @Lc_ExtEiwCur_TerminateIwo_INDC, @Ld_ExtEiwCur_Entered_DATE, @Ld_ExtEiwCur_Status_DATE, @Lc_ExtEiwCur_ActivityMinor_CODE, @Lc_ExtEiwCur_ReasonStatus_CODE, @Lc_ExtEiwCur_TypeOthpSource_CODE, @Ln_ExtEiwCur_MajorIntSeq_NUMB, @Ln_ExtEiwCur_MinorIntSeq_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --Select member/employers to generate eiwo
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
     SET @Ls_Sql_TEXT = 'SET Default Values to Amount and Freq for NON terminated IWO';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_TotalCur_AMNT = @Ln_Zero_NUMB,
            @Ln_EiwoRecCur_WeeklyWithheld_AMNT = @Ln_Zero_NUMB,
            @Ln_EiwoRecCur_MonthlyWithheld_AMNT = @Ln_Zero_NUMB,
            @Ln_EiwoRecCur_BiweeklyWithheld_AMNT = @Ln_Zero_NUMB,
            @Ln_EiwoRecCur_SemiMonthlyWithheld_AMNT = @Ln_Zero_NUMB,
            @Ln_Annual_AMNT = @Ln_Zero_NUMB,
            @Ln_CurCs_AMNT = @Ln_Zero_NUMB,
            @Ln_CurSs_AMNT = @Ln_Zero_NUMB,
            @Ln_CurMs_AMNT = @Ln_Zero_NUMB,
            @Ln_CurOt_AMNT = @Ln_Zero_NUMB,
            @Ln_Payback_AMNT = @Ln_Zero_NUMB,
            @Lc_FreqCs_CODE = @Lc_Space_TEXT,
            @Lc_FreqSs_CODE = @Lc_Space_TEXT,
            @Lc_FreqMs_CODE = @Lc_Space_TEXT,
            @Lc_FreqOt_CODE = @Lc_Space_TEXT,
            @Lc_FreqPayback_CODE = @Lc_Space_TEXT,
            @Lc_FreqPer_CODE = @Lc_Space_TEXT,
            @Lc_ArrearAged_INDC = @Lc_No_INDC,
            @Ln_PaybackCs_AMNT = @Ln_Zero_NUMB,
            @Ln_PaybackMs_AMNT = @Ln_Zero_NUMB,
            @Ln_PaybackSs_AMNT = @Ln_Zero_NUMB,
            @Lc_PaybackFreqCs_CODE = @Lc_Space_TEXT,
            @Lc_PaybackFreqSs_CODE = @Lc_Space_TEXT,
            @Lc_PaybackFreqMs_CODE = @Lc_Space_TEXT,
            @Lc_EiwoRecCur_FreqTotal_CODE = @Lc_Space_TEXT;

     --If the income needs to be withheld
     IF @Lc_ExtEiwCur_TerminateIwo_INDC = @Lc_No_INDC
        AND EXISTS (SELECT 1
                      FROM IWEM_Y1 i
                     WHERE i.Case_IDNO = @Ln_ExtEiwCur_Case_IDNO
                       AND i.OrderSeq_NUMB = @Ln_ExtEiwCur_OrderSeq_NUMB
                       AND i.MemberMci_IDNO = @Ln_ExtEiwCur_MemberMci_IDNO
                       AND i.OthpEmployer_IDNO = @Ln_ExtEiwCur_OthpSource_IDNO
                       AND i.IwnStatus_CODE IN (@Lc_Active_CODE, @Lc_Pending_CODE)
                       AND i.End_DATE = @Ld_High_DATE
                       AND i.EndValidity_DATE = @Ld_High_DATE)
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT IWEM_Y1 Freq and Amount';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_ExtEiwCur_OrderSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_MemberMci_IDNO AS VARCHAR), '') + ', OthpEmployer_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_OthpSource_IDNO AS VARCHAR), '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ln_Annual_AMNT = ISNULL ((CASE i.FreqCs_CODE
                                          WHEN @Lc_Weekly_CODE
                                           THEN i.CurCs_AMNT * 52
                                          WHEN @Lc_Monthly_CODE
                                           THEN i.CurCs_AMNT * 12
                                          WHEN @Lc_SemiMonthly_CODE
                                           THEN i.CurCs_AMNT * 24
                                          WHEN @Lc_BiWeekly_CODE
                                           THEN i.CurCs_AMNT * 26
                                          WHEN @Lc_Quarterly_CODE
                                           THEN i.CurCs_AMNT * 4
                                          WHEN @Lc_Annual_CODE
                                           THEN i.CurCs_AMNT
                                         END), 0) + ISNULL ((CASE i.FreqSs_CODE
                                                              WHEN @Lc_Weekly_CODE
                                                               THEN i.CurSs_AMNT * 52
                                                              WHEN @Lc_Monthly_CODE
                                                               THEN i.CurSs_AMNT * 12
                                                              WHEN @Lc_SemiMonthly_CODE
                                                               THEN i.CurSs_AMNT * 24
                                                              WHEN @Lc_Biweekly_CODE
                                                               THEN i.CurSs_AMNT * 26
                                                              WHEN @Lc_Quarterly_CODE
                                                               THEN i.CurSs_AMNT * 4
                                                              WHEN @Lc_Annual_CODE
                                                               THEN i.CurSs_AMNT
                                                             END), 0) + ISNULL ((CASE i.FreqOt_CODE
                                                                                  WHEN @Lc_Weekly_CODE
                                                                                   THEN i.CurOt_AMNT * 52
                                                                                  WHEN @Lc_Monthly_CODE
                                                                                   THEN i.CurOt_AMNT * 12
                                                                                  WHEN @Lc_SemiMonthly_CODE
                                                                                   THEN i.CurOt_AMNT * 24
                                                                                  WHEN @Lc_Biweekly_CODE
                                                                                   THEN i.CurOt_AMNT * 26
                                                                                  WHEN @Lc_Quarterly_CODE
                                                                                   THEN i.CurOt_AMNT * 4
                                                                                  WHEN @Lc_Annual_CODE
                                                                                   THEN i.CurOt_AMNT
                                                                                 END), 0) + ISNULL ((CASE i.FreqMd_CODE
                                                                                                      WHEN @Lc_Weekly_CODE
                                                                                                       THEN i.CurMd_AMNT * 52
                                                                                                      WHEN @Lc_Monthly_CODE
                                                                                                       THEN i.CurMd_AMNT * 12
                                                                                                      WHEN @Lc_SemiMonthly_CODE
                                                                                                       THEN i.CurMd_AMNT * 24
                                                                                                      WHEN @Lc_Biweekly_CODE
                                                                                                       THEN i.CurMd_AMNT * 26
                                                                                                      WHEN @Lc_Quarterly_CODE
                                                                                                       THEN i.CurMd_AMNT * 4
                                                                                                      WHEN @Lc_Annual_CODE
                                                                                                       THEN i.CurMd_AMNT
                                                                                                     END), 0) + ISNULL ((CASE i.FreqPayback_CODE
                                                                                                                          WHEN @Lc_Weekly_CODE
                                                                                                                           THEN i.Payback_AMNT * 52
                                                                                                                          WHEN @Lc_Monthly_CODE
                                                                                                                           THEN i.Payback_AMNT * 12
                                                                                                                          WHEN @Lc_SemiMonthly_CODE
                                                                                                                           THEN i.Payback_AMNT * 24
                                                                                                                          WHEN @Lc_Biweekly_CODE
                                                                                                                           THEN i.Payback_AMNT * 26
                                                                                                                          WHEN @Lc_Quarterly_CODE
                                                                                                                           THEN i.Payback_AMNT * 4
                                                                                                                          WHEN @Lc_Annual_CODE
                                                                                                                           THEN i.Payback_AMNT
                                                                                                                         END), 0),
              @Ln_CurCs_AMNT = i.CurCs_AMNT,
              @Ln_CurSs_AMNT = i.CurSs_AMNT,
              @Ln_CurMd_AMNT = i.CurMd_AMNT,
              @Ln_CurOt_AMNT = i.CurOt_AMNT,
              @Ln_Payback_AMNT = i.Payback_AMNT,
              @Lc_FreqCs_CODE = i.FreqCs_CODE,
              @Lc_FreqMd_CODE = i.FreqMd_CODE,
              @Lc_FreqOt_CODE = i.FreqOt_CODE,
              @Lc_FreqSs_CODE = i.FreqSs_CODE,
              @Lc_FreqPayback_CODE = i.FreqPayback_CODE,
              @Lc_FreqPer_CODE = (ISNULL(i.FreqCs_CODE, '') + ISNULL(i.FreqMd_CODE, '') + ISNULL(i.FreqOt_CODE, '') + ISNULL(i.FreqSs_CODE, '') + ISNULL(i.FreqPayback_CODE, '')),
              @Lc_ArrearAged_INDC = i.ArrearAged_INDC
         FROM IWEM_Y1 i
        WHERE i.Case_IDNO = @Ln_ExtEiwCur_Case_IDNO
          AND i.OrderSeq_NUMB = @Ln_ExtEiwCur_OrderSeq_NUMB
          AND i.MemberMci_IDNO = @Ln_ExtEiwCur_MemberMci_IDNO
          AND i.OthpEmployer_IDNO = @Ln_ExtEiwCur_OthpSource_IDNO
          AND i.IwnStatus_CODE IN (@Lc_Active_CODE, @Lc_Pending_CODE)
          AND i.End_DATE = @Ld_High_DATE
          AND i.EndValidity_DATE = @Ld_High_DATE;

       SET @Ls_Sql_TEXT = 'SET @Lc_EiwoRecCur_FreqTotal_CODE';
       SET @Ls_Sqldata_TEXT = '';
       SET @Lc_EiwoRecCur_FreqTotal_CODE = CASE
                                            WHEN CHARINDEX (@Lc_Weekly_CODE, @Lc_FreqPer_CODE, 1) > @Ln_Zero_NUMB
                                             THEN @Lc_Weekly_CODE
                                            WHEN CHARINDEX (@Lc_BiWeekly_CODE, @Lc_FreqPer_CODE, 1) > @Ln_Zero_NUMB
                                             THEN @Lc_BiWeekly_CODE
                                            WHEN CHARINDEX (@Lc_SemiMonthly_CODE, @Lc_FreqPer_CODE, 1) > @Ln_Zero_NUMB
                                             THEN @Lc_SemiMonthly_CODE
                                            WHEN CHARINDEX (@Lc_Monthly_CODE, @Lc_FreqPer_CODE, 1) > @Ln_Zero_NUMB
                                             THEN @Lc_Monthly_CODE
                                            WHEN CHARINDEX (@Lc_Quarterly_CODE, @Lc_FreqPer_CODE, 1) > @Ln_Zero_NUMB
                                             THEN @Lc_Quarterly_CODE
                                            WHEN CHARINDEX (@Lc_Annual_CODE, @Lc_FreqPer_CODE, 1) > @Ln_Zero_NUMB
                                             THEN @Lc_Annual_CODE
                                            WHEN CHARINDEX (@Lc_OneTime_CODE, @Lc_FreqPer_CODE, 1) > @Ln_Zero_NUMB
                                             THEN @Lc_OneTime_CODE
                                            ELSE @Lc_Space_TEXT
                                           END;
       SET @Ls_Sql_TEXT = 'CALCULATE TOTAL WITHHOLD AMOUNT';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_TotalCur_AMNT = ISNULL ((CASE @Lc_EiwoRecCur_FreqTotal_CODE
                                            WHEN @Lc_Weekly_CODE
                                             THEN @Ln_Annual_AMNT / 52
                                            WHEN @Lc_Monthly_CODE
                                             THEN @Ln_Annual_AMNT / 12
                                            WHEN @Lc_SemiMonthly_CODE
                                             THEN @Ln_Annual_AMNT / 24
                                            WHEN @Lc_Biweekly_CODE
                                             THEN @Ln_Annual_AMNT / 26
                                            WHEN @Lc_Quarterly_CODE
                                             THEN @Ln_Annual_AMNT / 4
                                            WHEN @Lc_Annual_CODE
                                             THEN @Ln_Annual_AMNT
                                           END), 0),
              @Ln_EiwoRecCur_WeeklyWithheld_AMNT = @Ln_Annual_AMNT / 52,
              @Ln_EiwoRecCur_BiweeklyWithheld_AMNT = @Ln_Annual_AMNT / 26,
              @Ln_EiwoRecCur_SemiMonthlyWithheld_AMNT = @Ln_Annual_AMNT / 24,
              @Ln_EiwoRecCur_MonthlyWithheld_AMNT = @Ln_Annual_AMNT / 12,
              @Ln_PaybackMs_AMNT = 0,
              @Ln_PaybackSs_AMNT = 0,
              @Ln_PaybackCs_AMNT = 0,
              @Lc_PaybackFreqMs_CODE = @Lc_Space_TEXT,
              @Lc_PaybackFreqCs_CODE = @Lc_Space_TEXT,
              @Lc_PaybackFreqSs_CODE = @Lc_Space_TEXT;

       --calculate payback amount  
       IF @Ln_Payback_AMNT = 0
        BEGIN
         SET @Lc_FreqPayback_CODE = @Lc_Space_TEXT;
        END
       ELSE
        BEGIN
         IF @Ln_CurCs_AMNT > @Ln_Zero_NUMB
          BEGIN
           SET @Ln_PaybackCs_AMNT = @Ln_Payback_AMNT;
           SET @Lc_PaybackFreqCs_CODE = @Lc_FreqPayback_CODE;
          END
         ELSE IF @Ln_CurSs_AMNT > @Ln_Zero_NUMB
          BEGIN
           SET @Ln_PaybackSs_AMNT = @Ln_Payback_AMNT;
           SET @Lc_PaybackFreqSs_CODE = @Lc_FreqPayback_CODE;
          END
         ELSE IF @Ln_CurMd_AMNT > @Ln_Zero_NUMB
          BEGIN
           SET @Ln_PaybackMs_AMNT = @Ln_Payback_AMNT;
           SET @Lc_PaybackFreqMs_CODE = @Lc_FreqPayback_CODE;
          END
         ELSE IF @Ln_CurCs_AMNT = @Ln_Zero_NUMB
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT @Lc_TypeDebt_CODE';
           SET @Ls_Sqldata_TEXT = '';

           SELECT @Lc_TypeDebt_CODE = ISNULL(TypeDebt_CODE, @Lc_Space_TEXT)
             FROM (SELECT OB.TypeDebt_CODE,
                          ROW_NUMBER () OVER (ORDER BY TypeDebt_CODE) AS RNM
                     FROM OBLE_Y1 OB
                    WHERE OB.Case_IDNO = @Ln_ExtEiwCur_Case_IDNO
                      AND OrderSeq_NUMB = @Ln_ExtEiwCur_OrderSeq_NUMB
                      AND OB.TypeDebt_CODE IN (@Lc_ChildSupport_CODE, @Lc_SpouseSupport_CODE, @Lc_MedicalSupport_CODE)
                      AND OB.EndValidity_DATE = @Ld_High_DATE) R
            WHERE RNM = 1;
          END

         IF @Lc_TypeDebt_CODE = @Lc_SpouseSupport_CODE
          BEGIN
           SET @Ln_PaybackSs_AMNT = @Ln_Payback_AMNT;
           SET @Lc_PaybackFreqSs_CODE = @Lc_FreqPayback_CODE;
          END
         ELSE IF @Lc_TypeDebt_CODE = @Lc_ChildSupport_CODE
          BEGIN
           SET @Ln_PaybackCs_AMNT = @Ln_Payback_AMNT;
           SET @Lc_PaybackFreqCs_CODE = @Lc_FreqPayback_CODE;
          END
         ELSE IF @Lc_TypeDebt_CODE = @Lc_MedicalSupport_CODE
          BEGIN
           SET @Ln_PaybackMs_AMNT = @Ln_Payback_AMNT;
           SET @Lc_PaybackFreqMs_CODE = @Lc_FreqPayback_CODE;
          END
        END
      END;

     -- Calculate the IW record type
     SET @Ls_Sql_TEXT = 'DERIVE DOC ACTION CODE';
     SET @Ls_Sqldata_TEXT = '';
     SET @Lc_EiwoRecCur_DocumentAction_CODE = CASE
                                               WHEN @Lc_ExtEiwCur_TerminateIwo_INDC = @Lc_Yes_INDC
                                                THEN @Lc_ActionTrm_CODE
                                               WHEN @Lc_ExtEiwCur_NewIwo_INDC = @Lc_Yes_INDC
                                                THEN @Lc_ActionOrg_CODE
                                               ELSE @Lc_ActionAmd_CODE
                                              END;
     SET @Ls_Sql_TEXT = 'SELECT @Ln_WithheldPercent_NUMB';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_MemberMci_IDNO AS VARCHAR), '');

     SELECT @Ln_WithheldPercent_NUMB = CASE
                                        WHEN D.SecondFamily_INDC = @Lc_Yes_INDC
                                             AND @Lc_ArrearAged_INDC = @Lc_Yes_INDC
                                         THEN 55
                                        WHEN D.SecondFamily_INDC = @Lc_Yes_INDC
                                             AND @Lc_ArrearAged_INDC = @Lc_No_INDC
                                         THEN 50
                                        WHEN D.SecondFamily_INDC != @Lc_Yes_INDC
                                             AND @Lc_ArrearAged_INDC = @Lc_Yes_INDC
                                         THEN 65
                                        WHEN D.SecondFamily_INDC != @Lc_Yes_INDC
                                             AND @Lc_ArrearAged_INDC = @Lc_No_INDC
                                         THEN 60
                                        ELSE 0
                                       END
       FROM DEMO_Y1 D
      WHERE MemberMci_IDNO = @Ln_ExtEiwCur_MemberMci_IDNO;

     IF @Ln_WithheldPercent_NUMB = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'SELECT DEMO_Y1 - CCPA PERCENTAGE FAILED ';

       RAISERROR (50001,16,1);
      END

     --get the phone number of case worker 
     SET @Ls_Sql_TEXT = 'SELECT the phone number of case worker';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ln_OtherParty_IDNO = d.OtherParty_IDNO,
            @Lc_Worker_ID = a.Worker_ID,
            @Ln_WorkPhone_NUMB = (SELECT b.WorkPhone_NUMB
                                    FROM UASM_Y1 b
                                   WHERE Worker_ID = a.Worker_ID
                                     AND b.Office_IDNO = a.Office_IDNO
                                     AND @Ld_Run_DATE BETWEEN b.Effective_DATE AND b.Expire_DATE
                                     AND b.EndValidity_DATE = @Ld_High_DATE)
       FROM CASE_Y1 a,
            OFIC_Y1 d
      WHERE a.Case_IDNO = @Ln_ExtEiwCur_Case_IDNO
        AND a.Office_IDNO = d.Office_IDNO
        AND d.EndValidity_DATE = @Ld_High_DATE;

     IF LEN(CAST(@Ln_WorkPhone_NUMB AS VARCHAR)) = 11
      BEGIN
       SET @Ln_WorkPhone_NUMB = SUBSTRING(CAST(@Ln_WorkPhone_NUMB AS VARCHAR), 2, 10);
      END
     ELSE IF LEN(CAST(@Ln_WorkPhone_NUMB AS VARCHAR)) > 11
         OR @Ln_WorkPhone_NUMB = NULL
      BEGIN
       SET @Ln_WorkPhone_NUMB = 0;
      END

     --get the email of the case worker 
     SET @Ls_Sql_TEXT = 'SELECT USEM_Y1 - WORKER';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_Worker_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Lc_WorkerLast_NAME = e.Last_NAME,
            @Lc_WorkerFirst_NAME = e.First_NAME,
            @Lc_WorkerMiddle_NAME = e.Middle_NAME,
            @Ls_WorkerTitle_CODE = ISNULL ((SELECT R.DescriptionValue_TEXT
                                              FROM REFM_Y1 R
                                             WHERE R.Table_ID = @Lc_TableIdUsem_ID
                                               AND R.TableSub_ID = @Lc_TableSubIdTtls_ID
                                               AND R.Value_CODE = e.WorkerTitle_CODE), @Lc_Space_TEXT),
            @Ls_WorkerEmail_EML = LEFT(e.Contact_EML, 48)
       FROM USEM_Y1 e
      WHERE e.Worker_ID = @Lc_Worker_ID
        AND e.EndValidity_DATE = @Ld_High_DATE;

     IF (@Lc_WorkerLast_NAME = @Lc_Space_TEXT
         AND @Lc_WorkerFirst_NAME = @Lc_Space_TEXT
         AND @Lc_WorkerMiddle_NAME = @Lc_Space_TEXT)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'SELECT USEM_Y1 - WORKER FAILED';

       RAISERROR(50001,16,1);
      END

     -- get jurisdiction details
     SET @Ls_Sql_TEXT = 'SELECT VOTHP - OFFICE';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Lc_JrsdictionParty_NAME = SUBSTRING (b.OtherParty_NAME, 1, 35),
            @Lc_Line1_ADDR = b.Line1_ADDR,
            @Lc_Line2_ADDR = b.Line2_ADDR,
            @Lc_City_ADDR = b.City_ADDR,
            @Lc_Zip_ADDR = b.Zip_ADDR,
            @Lc_State_ADDR = b.State_ADDR,
            @Ln_WorkPhone_NUMB = ISNULL (CASE
                                          WHEN @Ln_WorkPhone_NUMB = 0
                                           THEN b.Phone_NUMB
                                          ELSE @Ln_WorkPhone_NUMB
                                         END, 0),
            @Ln_OfficeFax_NUMB = ISNULL (b.Fax_NUMB, 0)
       FROM OTHP_Y1 b
      WHERE b.OtherParty_IDNO = @Ln_OtherParty_IDNO
        AND b.EndValidity_DATE = @Ld_High_DATE;

     --get child names,date of birth
     SET @Ls_Sql_TEXT = 'SELECT VOTHP - OFFICE -2';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Lc_EiwoRecCur_ChildLast1_NAME = (MAX (CASE rnm
                                                    WHEN 1
                                                     THEN e.Last_NAME
                                                    ELSE ''
                                                   END)),
            @Lc_EiwoRecCur_ChildLast2_NAME = (MAX (CASE rnm
                                                    WHEN 2
                                                     THEN e.Last_NAME
                                                    ELSE ''
                                                   END)),
            @Lc_EiwoRecCur_ChildLast3_NAME = (MAX (CASE rnm
                                                    WHEN 3
                                                     THEN e.Last_NAME
                                                    ELSE ''
                                                   END)),
            @Lc_EiwoRecCur_ChildLast4_NAME = (MAX (CASE rnm
                                                    WHEN 4
                                                     THEN e.Last_NAME
                                                    ELSE ''
                                                   END)),
            @Lc_EiwoRecCur_ChildLast5_NAME = (MAX (CASE rnm
                                                    WHEN 5
                                                     THEN e.Last_NAME
                                                    ELSE ''
                                                   END)),
            @Lc_EiwoRecCur_ChildLast6_NAME = (MAX (CASE rnm
                                                    WHEN 6
                                                     THEN e.Last_NAME
                                                    ELSE ''
                                                   END)),
            @Lc_EiwoRecCur_ChildFirst1_NAME = (MAX (CASE rnm
                                                     WHEN 1
                                                      THEN e.First_NAME
                                                     ELSE ''
                                                    END)),
            @Lc_EiwoRecCur_ChildFirst2_NAME = (MAX (CASE rnm
                                                     WHEN 2
                                                      THEN e.First_NAME
                                                     ELSE ''
                                                    END)),
            @Lc_EiwoRecCur_ChildFirst3_NAME = (MAX (CASE rnm
                                                     WHEN 3
                                                      THEN e.First_NAME
                                                     ELSE ''
                                                    END)),
            @Lc_EiwoRecCur_ChildFirst4_NAME = (MAX (CASE rnm
                                                     WHEN 4
                                                      THEN e.First_NAME
                                                     ELSE ''
                                                    END)),
            @Lc_EiwoRecCur_ChildFirst5_NAME = (MAX (CASE rnm
                                                     WHEN 5
                                                      THEN e.First_NAME
                                                     ELSE ''
                                                    END)),
            @Lc_EiwoRecCur_ChildFirst6_NAME = (MAX (CASE rnm
                                                     WHEN 6
                                                      THEN e.First_NAME
                                                     ELSE ''
                                                    END)),
            @Lc_EiwoRecCur_ChildMiddle1_NAME = (MAX (CASE rnm
                                                      WHEN 1
                                                       THEN SUBSTRING (e.Middle_NAME, 1, 15)
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildMiddle2_NAME = (MAX (CASE rnm
                                                      WHEN 2
                                                       THEN SUBSTRING (e.Middle_NAME, 1, 15)
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildMiddle3_NAME = (MAX (CASE rnm
                                                      WHEN 3
                                                       THEN SUBSTRING (e.Middle_NAME, 1, 15)
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildMiddle4_NAME = (MAX (CASE rnm
                                                      WHEN 4
                                                       THEN SUBSTRING (e.Middle_NAME, 1, 15)
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildMiddle5_NAME = (MAX (CASE rnm
                                                      WHEN 5
                                                       THEN SUBSTRING (e.Middle_NAME, 1, 15)
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildMiddle6_NAME = (MAX (CASE rnm
                                                      WHEN 6
                                                       THEN SUBSTRING (e.Middle_NAME, 1, 15)
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildSuffix1_NAME = (MAX (CASE rnm
                                                      WHEN 1
                                                       THEN e.Suffix_NAME
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildSuffix2_NAME = (MAX (CASE rnm
                                                      WHEN 2
                                                       THEN e.Suffix_NAME
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildSuffix3_NAME = (MAX (CASE rnm
                                                      WHEN 3
                                                       THEN e.Suffix_NAME
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildSuffix4_NAME = (MAX (CASE rnm
                                                      WHEN 4
                                                       THEN e.Suffix_NAME
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildSuffix5_NAME = (MAX (CASE rnm
                                                      WHEN 5
                                                       THEN e.Suffix_NAME
                                                      ELSE ''
                                                     END)),
            @Lc_EiwoRecCur_ChildSuffix6_NAME = (MAX (CASE rnm
                                                      WHEN 6
                                                       THEN e.Suffix_NAME
                                                      ELSE ''
                                                     END)),
            @Ld_EiwoRecCur_ChildBirth1_DATE = (MAX (CASE rnm
                                                     WHEN 1
                                                      THEN e.Birth_DATE
                                                     ELSE ''
                                                    END)),
            @Ld_EiwoRecCur_ChildBirth2_DATE = (MAX (CASE rnm
                                                     WHEN 2
                                                      THEN e.Birth_DATE
                                                     ELSE ''
                                                    END)),
            @Ld_EiwoRecCur_ChildBirth3_DATE = (MAX (CASE rnm
                                                     WHEN 3
                                                      THEN e.Birth_DATE
                                                     ELSE ''
                                                    END)),
            @Ld_EiwoRecCur_ChildBirth4_DATE = (MAX (CASE rnm
                                                     WHEN 4
                                                      THEN e.Birth_DATE
                                                     ELSE ''
                                                    END)),
            @Ld_EiwoRecCur_ChildBirth5_DATE = (MAX (CASE rnm
                                                     WHEN 5
                                                      THEN e.Birth_DATE
                                                     ELSE ''
                                                    END)),
            @Ld_EiwoRecCur_ChildBirth6_DATE = (MAX (CASE rnm
                                                     WHEN 6
                                                      THEN e.Birth_DATE
                                                     ELSE ''
                                                    END))
       FROM (SELECT c.Case_IDNO,
                    e.MemberMci_IDNO,
                    e.Last_NAME,
                    e.First_NAME,
                    e.Middle_NAME,
                    e.Birth_DATE,
                    e.Suffix_NAME,
                    ROW_NUMBER () OVER (PARTITION BY Case_IDNO ORDER BY e.MemberMci_IDNO) rnm
               FROM CMEM_Y1 c,
                    DEMO_Y1 e
              WHERE EXISTS (SELECT 1
                              FROM SORD_Y1 a,
                                   OBLE_Y1 b
                             WHERE a.Case_IDNO = @Ln_ExtEiwCur_Case_IDNO
                               AND a.TypeOrder_CODE != @Lc_TypeOrderV_CODE
                               AND a.EndValidity_DATE = @Ld_High_DATE
                               AND a.Case_IDNO = b.Case_IDNO
                               AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                               AND b.EndValidity_DATE = @Ld_High_DATE
                               AND b.BeginObligation_DATE = (SELECT MAX (x.BeginObligation_DATE)
                                                               FROM OBLE_Y1 x
                                                              WHERE a.Case_IDNO = x.Case_IDNO
                                                                AND a.OrderSeq_NUMB = x.OrderSeq_NUMB
                                                                AND b.ObligationSeq_NUMB = x.ObligationSeq_NUMB
                                                                AND x.EndValidity_DATE = @Ld_High_DATE)
                               AND b.EventGlobalBeginSeq_NUMB = (SELECT MAX (x.EventGlobalBeginSeq_NUMB)
                                                                   FROM OBLE_Y1 x
                                                                  WHERE a.Case_IDNO = x.Case_IDNO
                                                                    AND a.OrderSeq_NUMB = x.OrderSeq_NUMB
                                                                    AND b.ObligationSeq_NUMB = x.ObligationSeq_NUMB
                                                                    AND b.BeginObligation_DATE = x.BeginObligation_DATE
                                                                    AND x.EndValidity_DATE = @Ld_High_DATE)
                               AND C.Case_IDNO = B.Case_IDNO
                               AND c.MemberMci_IDNO = b.MemberMci_IDNO)
                AND c.CaseRelationship_CODE = 'D'
                AND c.CaseMemberStatus_CODE = @Lc_Active_CODE
                AND c.MemberMci_IDNO = e.MemberMci_IDNO) e
      GROUP BY Case_IDNO;

     SET @Lc_DocumentTracking_NUMB = '10' + SUBSTRING(CAST(@Ln_ExtEiwCur_Case_IDNO AS VARCHAR), 1, 3) + STUFF(CAST(@Ln_ExtEiwCur_MajorIntSeq_NUMB AS VARCHAR), 1, 0, REPLICATE('0', 5 - LEN(CAST(@Ln_ExtEiwCur_MajorIntSeq_NUMB AS VARCHAR)))) + STUFF(CAST(@Ln_ExtEiwCur_MinorIntSeq_NUMB AS VARCHAR), 1, 0, REPLICATE('0', 5 - LEN(CAST(@Ln_ExtEiwCur_MinorIntSeq_NUMB AS VARCHAR)))) + CONVERT(VARCHAR(8), @Ld_Run_DATE, 112);
     SET @Lc_DocumentTracking_NUMB = CONVERT (CHAR (30), @Lc_DocumentTracking_NUMB);
     SET @Ls_Sql_TEXT = 'INSERT EEIWO_Y1 ';
     SET @Ls_Sqldata_TEXT = 'DocumentAction_CODE = ' + ISNULL(@Lc_EiwoRecCur_DocumentAction_CODE, '') + ', NameIssuingState_NAME = ' + ISNULL(@Lc_StateDe_ADDR, '') + ', FreqCs_CODE = ' + ISNULL(@Lc_FreqCs_CODE, '') + ', FreqPaybackCs_CODE = ' + ISNULL(@Lc_PaybackFreqCs_CODE, '') + ', FreqMs_CODE = ' + ISNULL(@Lc_FreqMd_CODE, '') + ', FreqPaybackMs_CODE = ' + ISNULL(@Lc_PaybackFreqMs_CODE, '') + ', FreqSs_CODE = ' + ISNULL(@Lc_FreqSs_CODE, '') + ', FreqPaybackSs_CODE = ' + ISNULL(@Lc_PaybackFreqSs_CODE, '') + ', FreqOt_CODE = ' + ISNULL(@Lc_FreqOt_CODE, '') + ', DescriptionReasonOt_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqTotal_CODE = ' + ISNULL(@Lc_EiwoRecCur_FreqTotal_CODE, '') + ', Arr12wkDue_INDC = ' + ISNULL(@Lc_ArrearAged_INDC, '') + ', NameSendingState_NAME = ' + ISNULL(@Lc_StateDe_ADDR, '') + ', Line2Payee_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', CopyEmployee_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', DescriptionPenaltyLiability_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionAntiDescrimination_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionWithholdLimitPayee_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2EmployerContact_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', LumpSum_AMNT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SecondError_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', MultipleError_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

     INSERT EEIWO_Y1
            (DocumentAction_CODE,
             Document_DATE,
             NameIssuingState_NAME,
             IssuingJurisdiction_NAME,
             Case_IDNO,
             Employer_NAME,
             Line1Employer_ADDR,
             Line2Employer_ADDR,
             EmployerCity_ADDR,
             EmployerState_ADDR,
             EmployerZip_ADDR,
             Fein_IDNO,
             LastNcp_NAME,
             FirstNcp_NAME,
             MiddleNcp_NAME,
             SuffixNcp_NAME,
             NcpSsn_NUMB,
             BirthNcp_DATE,
             LastCp_NAME,
             FirstCp_NAME,
             MiddleCp_NAME,
             SuffixCp_NAME,
             IssuingTribunal_NAME,
             CurCs_AMNT,
             FreqCs_CODE,
             PaybackCs_AMNT,
             FreqPaybackCs_CODE,
             CurMs_AMNT,
             FreqMs_CODE,
             PaybackMs_AMNT,
             FreqPaybackMs_CODE,
             CurSs_AMNT,
             FreqSs_CODE,
             PaybackSs_AMNT,
             FreqPaybackSs_CODE,
             CurOt_AMNT,
             FreqOt_CODE,
             DescriptionReasonOt_TEXT,
             CurTotal_AMNT,
             FreqTotal_CODE,
             Arr12wkDue_INDC,
             WithheldWeekly_AMNT,
             WithheldBiweekly_AMNT,
             WithheldMonthly_AMNT,
             WithheldSemimonthly_AMNT,
             NameSendingState_NAME,
             DaysBeginWithhold_NUMB,
             IwoStart_DATE,
             DaysBeginPayment_NUMB,
             CcpaPercent_NUMB,
             Payee_NAME,
             Line1Payee_ADDR,
             Line2Payee_ADDR,
             CityPayee_ADDR,
             StatePayee_ADDR,
             ZipPayee_ADDR,
             FipsRemittance_CODE,
             NameStateOfficial_NAME,
             TitleStateOfficial_NAME,
             CopyEmployee_INDC,
             DescriptionPenaltyLiability_TEXT,
             DescriptionAntiDescrimination_TEXT,
             DescriptionWithholdLimitPayee_TEXT,
             EmployeeContact_NAME,
             PhoneEmployeeContact_NUMB,
             FaxEmployeeContact_NUMB,
             AddrEmployeeContact_TEXT,
             DocTrackNo_TEXT,
             Order_IDNO,
             EmployerContact_NAME,
             Line1EmployerContact_ADDR,
             Line2EmployerContact_ADDR,
             CityEmployerContact_ADDR,
             StateEmployerContact_ADDR,
             ZipEmployerContact_ADDR,
             PhoneEmployerContact_NUMB,
             FaxEmployerContact_NUMB,
             EmployerContact_ADDR,
             LastChild1_NAME,
             FirstChild1_NAME,
             MiddleChild1_NAME,
             SuffixChild1_NAME,
             BirthChild1_DATE,
             LastChild2_NAME,
             FirstChild2_NAME,
             MiddleChild2_NAME,
             SuffixChild2_NAME,
             BirthChild2_DATE,
             LastChild3_NAME,
             FirstChild3_NAME,
             MiddleChild3_NAME,
             SuffixChild3_NAME,
             BirthChild3_DATE,
             LastChild4_NAME,
             FirstChild4_NAME,
             MiddleChild4_NAME,
             SuffixChild4_NAME,
             BirthChild4_DATE,
             LastChild5_NAME,
             FirstChild5_NAME,
             MiddleChild5_NAME,
             SuffixChild5_NAME,
             BirthChild5_DATE,
             LastChild6_NAME,
             FirstChild6_NAME,
             MiddleChild6_NAME,
             SuffixChild6_NAME,
             BirthChild6_DATE,
             LumpSum_AMNT,
             Remittance_IDNO,
             FirstError_NAME,
             SecondError_NAME,
             MultipleError_CODE)
     VALUES ( @Lc_EiwoRecCur_DocumentAction_CODE,--DocumentAction_CODE
              CONVERT (CHAR (8), @Ld_Run_DATE, 112),--Document_DATE
              @Lc_StateDe_ADDR,--NameIssuingState_NAME
              CONVERT(CHAR(35), ISNULL (@Lc_JrsdictionParty_NAME, @Lc_Space_TEXT)),--IssuingJurisdiction_NAME
              CONVERT(CHAR(15), CAST (@Ln_ExtEiwCur_Case_IDNO AS VARCHAR)),--Case_IDNO
              CONVERT(CHAR(57), @Ls_ExtEiwCur_EmpOtherParty_NAME),--Employer_NAME
              CONVERT(CHAR(25), @Lc_ExtEiwCur_EmpLine1_ADDR),--Line1Employer_ADDR
              CONVERT(CHAR(25), @Lc_ExtEiwCur_EmpLine2_ADDR),--Line2Employer_ADDR
              CONVERT(CHAR(22), @Lc_ExtEiwCur_EmpCity_ADDR),--EmployerCity_ADDR
              CONVERT(CHAR(2), @Lc_ExtEiwCur_EmpState_ADDR),--EmployerState_ADDR
              CONVERT(CHAR(9), @Lc_ExtEiwCur_EmpZip_ADDR),--EmployerZip_ADDR
              CONVERT(CHAR(9), CAST (@Ln_ExtEiwCur_Fein_IDNO AS VARCHAR)),--Fein_IDNO
              CONVERT(CHAR(20), @Lc_ExtEiwCur_LastNcp_NAME),--LastNcp_NAME
              CONVERT(CHAR(15), @Lc_ExtEiwCur_FirstNcp_NAME),--FirstNcp_NAME
              CONVERT(CHAR(15), @Lc_ExtEiwCur_MiNcp_NAME),--MiddleNcp_NAME
              CONVERT(CHAR(4), @Lc_ExtEiwCur_SuffixNcp_NAME),--SuffixNcp_NAME
              CONVERT(CHAR(9), CAST(@Ln_ExtEiwCur_MemberSsn_NUMB AS VARCHAR)),--NcpSsn_NUMB
              CONVERT (CHAR (8), @Ld_ExtEiwCur_BirthNcp_DATE, 112),--BirthNcp_DATE
              CONVERT(CHAR(57), @Ls_ExtEiwCur_LastCp_NAME),--LastCp_NAME
              CONVERT(CHAR(15), @Lc_ExtEiwCur_FirstCp_NAME),--FirstCp_NAME
              CONVERT(CHAR(15), @Lc_ExtEiwCur_MiCp_NAME),--MiddleCp_NAME
              CONVERT(CHAR(4), @Lc_ExtEiwCur_SuffixCp_NAME),--SuffixCp_NAME
              CONVERT(CHAR(35), @Lc_StateDe_ADDR),--IssuingTribunal_NAME
              CONVERT (CHAR (11), @Ln_CurCs_AMNT),--CurCs_AMNT
              @Lc_FreqCs_CODE,--FreqCs_CODE
              CONVERT (CHAR (11), @Ln_PaybackCs_AMNT),--PaybackCs_AMNT
              @Lc_PaybackFreqCs_CODE,--FreqPaybackCs_CODE
              CONVERT (CHAR (11), @Ln_CurMd_AMNT),--CurMs_AMNT
              @Lc_FreqMd_CODE,--FreqMs_CODE
              CONVERT (CHAR (11), @Ln_PaybackMs_AMNT),--PaybackMs_AMNT
              @Lc_PaybackFreqMs_CODE,--FreqPaybackMs_CODE
              CONVERT (CHAR (11), @Ln_CurSs_AMNT),--CurSs_AMNT
              @Lc_FreqSs_CODE,--FreqSs_CODE
              CONVERT (CHAR (11), @Ln_PaybackSs_AMNT),--PaybackSs_AMNT
              @Lc_PaybackFreqSs_CODE,--FreqPaybackSs_CODE
              CONVERT (CHAR (11), @Ln_CurOt_AMNT),--CurOt_AMNT
              @Lc_FreqOt_CODE,--FreqOt_CODE
              @Lc_Space_TEXT,--DescriptionReasonOt_TEXT
              CONVERT (CHAR (11), @Ln_TotalCur_AMNT),--CurTotal_AMNT
              @Lc_EiwoRecCur_FreqTotal_CODE,--FreqTotal_CODE
              @Lc_ArrearAged_INDC,--Arr12wkDue_INDC
              CONVERT (CHAR (11), CAST (@Ln_EiwoRecCur_WeeklyWithheld_AMNT AS NUMERIC(11, 2))),--WithheldWeekly_AMNT
              CONVERT (CHAR (11), CAST (@Ln_EiwoRecCur_BiweeklyWithheld_AMNT AS NUMERIC(11, 2))),--WithheldBiweekly_AMNT
              CONVERT (CHAR (11), CAST (@Ln_EiwoRecCur_SemiMonthlyWithheld_AMNT AS NUMERIC(11, 2))),--WithheldMonthly_AMNT
              CONVERT (CHAR (11), CAST (@Ln_EiwoRecCur_MonthlyWithheld_AMNT AS NUMERIC(11, 2))),--WithheldSemimonthly_AMNT
              @Lc_StateDe_ADDR,--NameSendingState_NAME
              0,--DaysBeginWithhold_NUMB
              CONVERT (CHAR (10), @Ld_ExtEiwCur_Status_DATE, 112),--IwoStart_DATE
              0,--DaysBeginPayment_NUMB
              CONVERT(CHAR(2), @Ln_WithheldPercent_NUMB),--CcpaPercent_NUMB
              CONVERT(CHAR(57), @Ls_EiwoRecCur_Payee_NAME),--Payee_NAME
              CONVERT(CHAR(25), @Lc_EiwoRecCur_PayeeLine1_ADDR),--Line1Payee_ADDR
              @Lc_Space_TEXT,--Line2Payee_ADDR
              CONVERT(CHAR(22), @Lc_EiwoRecCur_PayeeCity_ADDR),--CityPayee_ADDR
              CONVERT(CHAR(2), @Lc_EiwoRecCur_PayeeState_ADDR),--StatePayee_ADDR
              CONVERT(CHAR(9), @Lc_EiwoRecCur_PayeeZip_ADDR),--ZipPayee_ADDR
              CONVERT(CHAR(7), @Lc_EiwoRecCur_FipsRemittance_CODE),--FipsRemittance_CODE
              @Lc_WorkerFirst_NAME + @Lc_Space_TEXT + @Lc_WorkerLast_NAME,--NameStateOfficial_NAME
              CONVERT(CHAR(57), @Ls_WorkerTitle_CODE),--TitleStateOfficial_NAME
              @Lc_No_INDC,--CopyEmployee_INDC
              @Lc_Space_TEXT,--DescriptionPenaltyLiability_TEXT
              @Lc_Space_TEXT,--DescriptionAntiDescrimination_TEXT
              @Lc_Space_TEXT,--DescriptionWithholdLimitPayee_TEXT
              @Lc_WorkerFirst_NAME + @Lc_Space_TEXT + @Lc_WorkerLast_NAME,--EmployeeContact_NAME
              CONVERT (CHAR(10), CASE
                                  WHEN @Ln_WorkPhone_NUMB = 0
                                   THEN ''
                                  ELSE @Ln_WorkPhone_NUMB
                                 END),--PhoneEmployeeContact_NUMB
              CONVERT (CHAR(10), CASE
                                  WHEN @Ln_OfficeFax_NUMB = 0
                                   THEN ''
                                  ELSE @Ln_OfficeFax_NUMB
                                 END),--FaxEmployeeContact_NUMB
              CONVERT(CHAR(48), ISNULL(@Ls_WorkerEmail_EML, '')),--AddrEmployeeContact_TEXT
              CONVERT(CHAR(30), ISNULL(@Lc_DocumentTracking_NUMB, '')),--DocTrackNo_TEXT
              CONVERT(CHAR(30), ISNULL(@Lc_EiwoRecCur_Order_IDNO, '')),--Order_IDNO
              @Lc_WorkerFirst_NAME + @Lc_Space_TEXT + @Lc_WorkerLast_NAME,--EmployerContact_NAME
              CONVERT(CHAR(25), @Lc_EiwoRecCur_PayeeLine1_ADDR),--Line1EmployerContact_ADDR
              @Lc_Space_TEXT,--Line2EmployerContact_ADDR
              CONVERT(CHAR(22), @Lc_EiwoRecCur_PayeeCity_ADDR),--CityEmployerContact_ADDR
              CONVERT(CHAR(2), @Lc_EiwoRecCur_PayeeState_ADDR),--StateEmployerContact_ADDR
              CONVERT(CHAR(9), @Lc_EiwoRecCur_PayeeZip_ADDR),--ZipEmployerContact_ADDR
              ISNULL (CAST (@Ln_WorkPhone_NUMB AS VARCHAR), @Lc_Space_TEXT),--PhoneEmployerContact_NUMB
              ISNULL (CAST (@Ln_OfficeFax_NUMB AS VARCHAR), @Lc_Space_TEXT),--FaxEmployerContact_NUMB
              CONVERT(CHAR(48), ISNULL(@Ls_WorkerEmail_EML, '')),--EmployerContact_ADDR
              CONVERT(CHAR(20), ISNULL(@Lc_EiwoRecCur_ChildLast1_NAME, '')),--LastChild1_NAME
              CONVERT(CHAR(15), ISNULL(@Lc_EiwoRecCur_ChildFirst1_NAME, '')),--FirstChild1_NAME
              CONVERT(CHAR(15), ISNULL(@Lc_EiwoRecCur_ChildMiddle1_NAME, '')),--MiddleChild1_NAME
              CONVERT(CHAR(4), ISNULL(@Lc_EiwoRecCur_ChildSuffix1_NAME, '')),--SuffixChild1_NAME
              ISNULL(CONVERT(CHAR(8), @Ld_EiwoRecCur_ChildBirth1_DATE, 112), @Lc_Space_TEXT),--BirthChild1_DATE
              CONVERT(CHAR(20), ISNULL(@Lc_EiwoRecCur_ChildLast2_NAME, '')),--LastChild2_NAME
              CONVERT(CHAR(15), ISNULL(@Lc_EiwoRecCur_ChildFirst2_NAME, '')),--FirstChild2_NAME
              CONVERT(CHAR(15), ISNULL(@Lc_EiwoRecCur_ChildMiddle2_NAME, '')),--MiddleChild2_NAME
              CONVERT(CHAR(4), ISNULL(@Lc_EiwoRecCur_ChildSuffix2_NAME, '')),--SuffixChild2_NAME
              ISNULL(CONVERT(CHAR(8), @Ld_EiwoRecCur_ChildBirth2_DATE, 112), ''),--BirthChild2_DATE
              CONVERT(CHAR(20), ISNULL(@Lc_EiwoRecCur_ChildLast3_NAME, '')),--LastChild3_NAME
              CONVERT(CHAR(15), ISNULL(@Lc_EiwoRecCur_ChildFirst3_NAME, '')),--FirstChild3_NAME
              CONVERT(CHAR(15), ISNULL(@Lc_EiwoRecCur_ChildMiddle3_NAME, '')),--MiddleChild3_NAME
              CONVERT(CHAR(4), ISNULL (@Lc_EiwoRecCur_ChildSuffix3_NAME, '')),--SuffixChild3_NAME
              ISNULL (CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth3_DATE, 112), @Lc_Space_TEXT),--BirthChild3_DATE
              CONVERT(CHAR(20), ISNULL (@Lc_EiwoRecCur_ChildLast4_NAME, '')),--LastChild4_NAME
              CONVERT(CHAR(15), ISNULL (@Lc_EiwoRecCur_ChildFirst4_NAME, '')),--FirstChild4_NAME
              CONVERT(CHAR(15), ISNULL (@Lc_EiwoRecCur_ChildMiddle4_NAME, '')),--MiddleChild4_NAME
              CONVERT(CHAR(4), ISNULL (@Lc_EiwoRecCur_ChildSuffix4_NAME, '')),--SuffixChild4_NAME
              ISNULL (CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth4_DATE, 112), @Lc_Space_TEXT),--BirthChild4_DATE
              CONVERT(CHAR(20), ISNULL (@Lc_EiwoRecCur_ChildLast5_NAME, '')),--LastChild5_NAME
              CONVERT(CHAR(15), ISNULL (@Lc_EiwoRecCur_ChildFirst5_NAME, '')),--FirstChild5_NAME
              CONVERT(CHAR(15), ISNULL (@Lc_EiwoRecCur_ChildMiddle5_NAME, '')),--MiddleChild5_NAME
              CONVERT(CHAR(4), ISNULL (@Lc_EiwoRecCur_ChildSuffix5_NAME, '')),--SuffixChild5_NAME
              ISNULL (CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth5_DATE, 112), @Lc_Space_TEXT),--BirthChild5_DATE
              CONVERT(CHAR(20), ISNULL (@Lc_EiwoRecCur_ChildLast6_NAME, '')),--LastChild6_NAME
              CONVERT(CHAR(15), ISNULL (@Lc_EiwoRecCur_ChildFirst6_NAME, '')),--FirstChild6_NAME
              CONVERT(CHAR(15), ISNULL (@Lc_EiwoRecCur_ChildMiddle6_NAME, '')),--MiddleChild6_NAME
              CONVERT(CHAR(4), ISNULL (@Lc_EiwoRecCur_ChildSuffix6_NAME, '')),--SuffixChild6_NAME
              ISNULL (CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth6_DATE, 112), @Lc_Space_TEXT),--BirthChild6_DATE
              @Lc_Space_TEXT,--LumpSum_AMNT
              CONVERT(CHAR(20), CAST (@Ln_ExtEiwCur_Case_IDNO AS VARCHAR)),--Remittance_IDNO
              CONVERT(CHAR(32), CAST (@Ln_ExtEiwCur_OthpSource_IDNO AS VARCHAR)),--FirstError_NAME
              @Lc_Space_TEXT,--SecondError_NAME
              @Lc_Space_TEXT --MultipleError_CODE
     );

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT EEIWO_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT VIEWT TABLE';
     SET @Ls_Sqldata_TEXT = 'DocumentAction_CODE = ' + ISNULL(@Lc_EiwoRecCur_DocumentAction_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_ExtEiwCur_OrderSeq_NUMB AS VARCHAR), '') + ', MajorIntSEQ_NUMB = ' + ISNULL(CAST(@Ln_ExtEiwCur_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_ExtEiwCur_MinorIntSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_MemberMci_IDNO AS VARCHAR), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_OthpSource_IDNO AS VARCHAR), '') + ', TypeOthpSource_CODE = ' + ISNULL(@Lc_ExtEiwCur_TypeOthpSource_CODE, '') + ', IwSent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Entered_DATE = ' + ISNULL(CAST(@Ld_ExtEiwCur_Entered_DATE AS VARCHAR), '') + ', Status_DATE = ' + ISNULL(CAST(@Ld_ExtEiwCur_Status_DATE AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ExtEiwCur_ActivityMinor_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ExtEiwCur_ReasonStatus_CODE, '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_ExtEiwCur_Fein_IDNO AS VARCHAR), '') + ', DocTrackNo_TEXT = ' + ISNULL(@Lc_DocumentTracking_NUMB, '') + ', NcpSsn_NUMB = ' + ISNULL(CAST(@Ln_ExtEiwCur_MemberSsn_NUMB AS VARCHAR), '') + ', Disp_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', RejReason_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Termination_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', FinalPayment_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', FinalPay_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', LumpSumPay_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', LumpSumPay_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', DescriptionLumpSumPay_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReceivedAcknowledgement_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', FirstError_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', SecondError_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', MultipleError_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReceivedResult_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Resend_INDC = ' + ISNULL(@Lc_No_INDC, '');

     INSERT EIWT_Y1
            (DocumentAction_CODE,
             Case_IDNO,
             OrderSeq_NUMB,
             MajorIntSEQ_NUMB,
             MinorIntSeq_NUMB,
             MemberMci_IDNO,
             OthpSource_IDNO,
             TypeOthpSource_CODE,
             IwSent_DATE,
             Entered_DATE,
             Status_DATE,
             ActivityMinor_CODE,
             ReasonStatus_CODE,
             Fein_IDNO,
             DocTrackNo_TEXT,
             Order_IDNO,
             NcpSsn_NUMB,
             Disp_CODE,
             RejReason_CODE,
             Termination_DATE,
             FinalPayment_DATE,
             FinalPay_AMNT,
             LumpSumPay_DATE,
             LumpSumPay_AMNT,
             DescriptionLumpSumPay_TEXT,
             ReceivedAcknowledgement_DATE,
             FirstError_NAME,
             SecondError_NAME,
             MultipleError_CODE,
             ReceivedResult_DATE,
             Resend_INDC,
             XmlExtEiwo_TEXT)
     VALUES ( @Lc_EiwoRecCur_DocumentAction_CODE,--DocumentAction_CODE
              @Ln_ExtEiwCur_Case_IDNO,--Case_IDNO
              @Ln_ExtEiwCur_OrderSeq_NUMB,--OrderSeq_NUMB
              @Ln_ExtEiwCur_MajorIntSeq_NUMB,--MajorIntSEQ_NUMB
              @Ln_ExtEiwCur_MinorIntSeq_NUMB,--MinorIntSeq_NUMB
              @Ln_ExtEiwCur_MemberMci_IDNO,--MemberMci_IDNO
              @Ln_ExtEiwCur_OthpSource_IDNO,--OthpSource_IDNO
              @Lc_ExtEiwCur_TypeOthpSource_CODE,--TypeOthpSource_CODE
              @Ld_Run_DATE,--IwSent_DATE
              @Ld_ExtEiwCur_Entered_DATE,--Entered_DATE
              @Ld_ExtEiwCur_Status_DATE,--Status_DATE
              @Lc_ExtEiwCur_ActivityMinor_CODE,--ActivityMinor_CODE
              @Lc_ExtEiwCur_ReasonStatus_CODE,--ReasonStatus_CODE
              @Ln_ExtEiwCur_Fein_IDNO,--Fein_IDNO
              @Lc_DocumentTracking_NUMB,--DocTrackNo_TEXT
              0,--Order_IDNO
              @Ln_ExtEiwCur_MemberSsn_NUMB,--NcpSsn_NUMB
              @Lc_Space_TEXT,--Disp_CODE
              @Lc_Space_TEXT,--RejReason_CODE
              @Ld_Low_DATE,--Termination_DATE
              @Ld_Low_DATE,--FinalPayment_DATE
              @Ln_Zero_NUMB,--FinalPay_AMNT
              @Ld_Low_DATE,--LumpSumPay_DATE
              @Ln_Zero_NUMB,--LumpSumPay_AMNT
              @Lc_Space_TEXT,--DescriptionLumpSumPay_TEXT
              @Ld_Low_DATE,--ReceivedAcknowledgement_DATE
              @Lc_Space_TEXT,--FirstError_NAME
              @Lc_Space_TEXT,--SecondError_NAME
              @Lc_Space_TEXT,--MultipleError_CODE
              @Ld_Low_DATE,--ReceivedResult_DATE
              @Lc_No_INDC,--Resend_INDC
              CONVERT (VARCHAR (MAX), (SELECT *
                                         FROM EEIWO_Y1
                                        WHERE DocumentAction_CODE = @Lc_EiwoRecCur_DocumentAction_CODE
                                          AND Document_DATE = CONVERT (CHAR (8), @Ld_Run_DATE, 112)
                                          AND Employer_NAME = CONVERT(CHAR(57), @Ls_ExtEiwCur_EmpOtherParty_NAME)
										  AND Fein_IDNO = CONVERT(CHAR(9), CAST (@Ln_ExtEiwCur_Fein_IDNO AS VARCHAR))
										  AND Case_IDNO = @Ln_ExtEiwCur_Case_IDNO
                                       FOR XML AUTO, TYPE)) --XmlExtEiwo_TEXT
     );

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT EIWT_Y1 FAILED';

       RAISERROR (50001,16,1);
      END

     FETCH NEXT FROM Exteiw_CUR INTO @Ln_ExtEiwCur_Case_IDNO, @Ln_ExtEiwCur_OrderSeq_NUMB, @Ln_ExtEiwCur_OthpSource_IDNO, @Ln_ExtEiwCur_MemberMci_IDNO, @Ln_ExtEiwCur_Fein_IDNO, @Ls_ExtEiwCur_EmpOtherParty_NAME, @Lc_ExtEiwCur_EmpLine1_ADDR, @Lc_ExtEiwCur_EmpLine2_ADDR, @Lc_ExtEiwCur_EmpCity_ADDR, @Lc_ExtEiwCur_EmpState_ADDR, @Lc_ExtEiwCur_EmpZip_ADDR, @Lc_ExtEiwCur_LastNcp_NAME, @Lc_ExtEiwCur_FirstNcp_NAME, @Lc_ExtEiwCur_MiNcp_NAME, @Lc_ExtEiwCur_SuffixNcp_NAME, @Ln_ExtEiwCur_MemberSsn_NUMB, @Ld_ExtEiwCur_BirthNcp_DATE, @Ls_ExtEiwCur_LastCp_NAME, @Lc_ExtEiwCur_FirstCp_NAME, @Lc_ExtEiwCur_MiCp_NAME, @Lc_ExtEiwCur_SuffixCp_NAME, @Lc_ExtEiwCur_File_ID, @Lc_ExtEiwCur_NewIwo_INDC, @Lc_ExtEiwCur_TerminateIwo_INDC, @Ld_ExtEiwCur_Entered_DATE, @Ld_ExtEiwCur_Status_DATE, @Lc_ExtEiwCur_ActivityMinor_CODE, @Lc_ExtEiwCur_ReasonStatus_CODE, @Lc_ExtEiwCur_TypeOthpSource_CODE, @Ln_ExtEiwCur_MajorIntSeq_NUMB, @Ln_ExtEiwCur_MinorIntSeq_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Exteiw_CUR;

   DEALLOCATE Exteiw_CUR;

   SET @Ls_Sql_TEXT = 'CREATE TABLE ##ExtEiwo_P1';
   SET @Ls_Sqldata_TEXT = '';

   CREATE TABLE ##ExtEiwo_P1
    (
      Seq_NUMB          INT IDENTITY,
      OutputRecord_TEXT VARCHAR (2406)
    );

   SET @Lc_Control_TEXT = '10000' + CONVERT (CHAR (6), @Ld_Run_DATE, 12) + LTRIM (RTRIM (REPLACE (REPLACE (SUBSTRING (CONVERT (VARCHAR (21), @Ld_Start_DATE, 121), 11, 40), ':', ''), '.', ''))) + '0000';
   SET @Ls_ReturnValue_TEXT = 'FHI' + CONVERT (CHAR (22), @Lc_Control_TEXT) + '10000' + REPLICATE (@Lc_Space_TEXT, 18) + CONVERT (VARCHAR (8), @Ld_Run_DATE, 112) + CONVERT (CHAR (6), REPLACE (CAST (CONVERT (VARCHAR (10), @Ld_Start_DATE, 108) AS CHAR), ':', '')) + REPLICATE (@Lc_Space_TEXT, 2344);
   SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtEiwo_P1';
   SET @Ls_Sqldata_TEXT = 'OutputRecord_TEXT = ' + ISNULL(@Ls_ReturnValue_TEXT, '');

   INSERT ##ExtEiwo_P1
          (OutputRecord_TEXT)
   VALUES (@Ls_ReturnValue_TEXT --OutputRecord_TEXT
   );

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS FOUND';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_ErrrorTypeW_CODE, '') + ', Error_CODE = ' + ISNULL(@Lc_ErrrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrrorTypeW_CODE,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_ErrrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sqldata_TEXT,
      @As_ListKey_TEXT             = @Ls_Sql_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END
   ELSE
    BEGIN
     DECLARE EiwoRec_CUR INSENSITIVE CURSOR FOR
      SELECT EW.DocumentAction_CODE,
             EW.Document_DATE,
             EW.NameIssuingState_NAME,
             EW.IssuingJurisdiction_NAME,
             CAST (EW.Case_IDNO AS NUMERIC (6)) AS Case_IDNO,
             EW.Employer_NAME,
             EW.Line1Employer_ADDR,
             EW.Line2Employer_ADDR,
             EW.EmployerCity_ADDR,
             EW.EmployerState_ADDR,
             EW.EmployerZip_ADDR,
             CAST (EW.Fein_IDNO AS NUMERIC (9)) AS Fein_IDNO,
             EW.LastNcp_NAME,
             EW.FirstNcp_NAME,
             EW.MiddleNcp_NAME,
             EW.SuffixNcp_NAME,
             CAST (EW.NcpSsn_NUMB AS NUMERIC (9)) AS NcpSsn_NUMB,
             EW.BirthNcp_DATE,
             EW.LastCp_NAME,
             EW.FirstCp_NAME,
             EW.MiddleCp_NAME,
             EW.SuffixCp_NAME,
             EW.IssuingTribunal_NAME,
             CAST (EW.CurCs_AMNT AS NUMERIC(11, 2)) AS CurCs_AMNT,
             FreqCs_CODE,
             CAST (EW.PaybackCs_AMNT AS NUMERIC(11, 2)) AS PaybackCs_AMNT,
             EW.FreqPaybackCs_CODE,
             CAST (EW.CurMs_AMNT AS NUMERIC(11, 2)) AS CurMs_AMNT,
             FreqMs_CODE,
             CAST (EW.PaybackMs_AMNT AS NUMERIC(11, 2)) AS PaybackMs_AMNT,
             EW.FreqPaybackMs_CODE,
             CAST (EW.CurSs_AMNT AS NUMERIC(11, 2)) AS CurSs_AMNT,
             EW.FreqSs_CODE,
             CAST (EW.PaybackSs_AMNT AS NUMERIC(11, 2)) AS PaybackSs_AMNT,
             EW.FreqPaybackSs_CODE,
             CAST (EW.CurOt_AMNT AS NUMERIC),
             EW.FreqOt_CODE,
             EW.DescriptionReasonOt_TEXT,
             CAST (EW.CurTotal_AMNT AS NUMERIC),
             EW.FreqTotal_CODE,
             EW.Arr12wkDue_INDC,
             CAST (EW.WithheldWeekly_AMNT AS NUMERIC(11, 2)),
             CAST (EW.WithheldBiweekly_AMNT AS NUMERIC(11, 2)),
             CAST (EW.WithheldMonthly_AMNT AS NUMERIC(11, 2)),
             CAST (EW.WithheldSemimonthly_AMNT AS NUMERIC(11, 2)),
             EW.NameSendingState_NAME,
             CAST (EW.DaysBeginWithhold_NUMB AS NUMERIC),
             EW.IwoStart_DATE,
             CAST (EW.DaysBeginPayment_NUMB AS NUMERIC),
             CAST (EW.CcpaPercent_NUMB AS NUMERIC),
             EW.Payee_NAME,
             EW.Line1Payee_ADDR,
             EW.Line2Payee_ADDR,
             EW.CityPayee_ADDR,
             EW.StatePayee_ADDR,
             EW.ZipPayee_ADDR,
             EW.FipsRemittance_CODE,
             EW.NameStateOfficial_NAME,
             EW.TitleStateOfficial_NAME,
             EW.CopyEmployee_INDC,
             EW.DescriptionPenaltyLiability_TEXT,
             EW.DescriptionAntiDescrimination_TEXT,
             EW.DescriptionWithholdLimitPayee_TEXT,
             EW.EmployeeContact_NAME,
             EW.PhoneEmployeeContact_NUMB,
             EW.FaxEmployeeContact_NUMB,
             EW.AddrEmployeeContact_TEXT,
             EW.DocTrackNo_TEXT,
             EW.Order_IDNO,
             EW.EmployerContact_NAME,
             EW.Line1EmployerContact_ADDR,
             EW.Line2EmployerContact_ADDR,
             EW.CityEmployerContact_ADDR,
             EW.StateEmployerContact_ADDR,
             EW.ZipEmployerContact_ADDR,
             EW.PhoneEmployerContact_NUMB,
             EW.FaxEmployerContact_NUMB,
             EW.EmployerContact_ADDR,
             EW.LastChild1_NAME,
             EW.FirstChild1_NAME,
             EW.MiddleChild1_NAME,
             EW.SuffixChild1_NAME,
             CAST (EW.BirthChild1_DATE AS DATE),
             EW.LastChild2_NAME,
             EW.FirstChild2_NAME,
             EW.MiddleChild2_NAME,
             EW.SuffixChild2_NAME,
             CAST (EW.BirthChild2_DATE AS DATE),
             EW.LastChild3_NAME,
             EW.FirstChild3_NAME,
             EW.MiddleChild3_NAME,
             EW.SuffixChild3_NAME,
             CAST (EW.BirthChild3_DATE AS DATE),
             EW.LastChild4_NAME,
             EW.FirstChild4_NAME,
             EW.MiddleChild4_NAME,
             EW.SuffixChild4_NAME,
             CAST (EW.BirthChild4_DATE AS DATE),
             EW.LastChild5_NAME,
             EW.FirstChild5_NAME,
             EW.MiddleChild5_NAME,
             EW.SuffixChild5_NAME,
             CAST (EW.BirthChild5_DATE AS DATE),
             EW.LastChild6_NAME,
             EW.FirstChild6_NAME,
             EW.MiddleChild6_NAME,
             EW.SuffixChild6_NAME,
             CAST (EW.BirthChild6_DATE AS DATE),
             EW.Remittance_IDNO,
             EW.FirstError_NAME,
             EW.SecondError_NAME,
             EW.MultipleError_CODE
        FROM EEIWO_Y1 EW
       ORDER BY EW.Fein_IDNO,
                EW.FirstError_NAME;

     OPEN EiwoRec_CUR;

     FETCH NEXT FROM EiwoRec_CUR INTO @Lc_EiwoRecCur_DocumentAction_CODE, @Lc_EiwoRecCur_Document_DATE, @Lc_EiwoRecCur_IssuingState_CODE, @Lc_EiwoRecCur_IssuingJurisdiction_NAME, @Ln_EiwoRecCur_Case_IDNO, @Ls_EiwoRecCur_Employer_NAME, @Lc_EiwoRecCur_EmployerLine1_ADDR, @Lc_EiwoRecCur_EmployerLine2_ADDR, @Lc_EiwoRecCur_EmployerCity_ADDR, @Lc_EiwoRecCur_EmployerState_ADDR, @Lc_EiwoRecCur_EmployerZip_ADDR, @Ln_EiwoRecCur_Fein_IDNO, @Lc_EiwoRecCur_NcpLast_NAME, @Lc_EiwoRecCur_NcpFirst_NAME, @Lc_EiwoRecCur_NcpMi_NAME, @Lc_EiwoRecCur_NcpSuffix_NAME, @Ln_EiwoRecCur_MemberSsn_NUMB, @Ld_EiwoRecCur_NcpBirth_DATE, @Ls_EiwoRecCur_CpLast_NAME, @Lc_EiwoRecCur_CpFirst_NAME, @Lc_EiwoRecCur_CpMiddle_NAME, @Lc_EiwoRecCur_CpSuffix_NAME, @Lc_EiwoRecCur_IssuingTribunal_NAME, @Ln_EiwoRecCur_CurCs_AMNT, @Lc_EiwoRecCur_FreqCs_CODE, @Ln_EiwoRecCur_PaybackCs_AMNT, @Lc_EiwoRecCur_PaybackFreqcs_CODE, @Ln_EiwoRecCur_CurMs_AMNT, @Lc_EiwoRecCur_FreqMs_CODE, @Ln_EiwoRecCur_PaybackMs_AMNT, @Lc_EiwoRecCur_PaybackFreqMs_CODE, @Ln_EiwoRecCur_CurSs_AMNT, @Lc_EiwoRecCur_FreqSs_CODE, @Ln_EiwoRecCur_PaybackSs_AMNT, @Lc_EiwoRecCur_PaybackFreqSs_CODE, @Ln_EiwoRecCur_CurOt_AMNT, @Lc_EiwoRecCur_FreqOt_CODE, @Lc_EiwoRecCur_ReasonOt_CODE, @Ln_EiwoRecCur_TotalCur_AMNT, @Lc_EiwoRecCur_FreqTotal_CODE, @Lc_EiwoRecCur_Arr12WkDue_CODE, @Ln_EiwoRecCur_WeeklyWithheld_AMNT, @Ln_EiwoRecCur_BiweeklyWithheld_AMNT, @Ln_EiwoRecCur_SemiMonthlyWithheld_AMNT, @Ln_EiwoRecCur_MonthlyWithheld_AMNT, @Lc_EiwoRecCur_SendingState_NAME, @Lc_EiwoRecCur_DaysBeginWithhold_NUMB, @Lc_EiwoRecCur_IwoStart_DATE, @Lc_EiwoRecCur_DaysBeginPayment_NUMB, @Ln_EiwoRecCur_CcpaPercent_NUMB, @Ls_EiwoRecCur_Payee_NAME, @Lc_EiwoRecCur_PayeeLine1_ADDR, @Lc_EiwoRecCur_PayeeLine2_ADDR, @Lc_EiwoRecCur_PayeeCity_ADDR, @Lc_EiwoRecCur_PayeeState_ADDR, @Lc_EiwoRecCur_PayeeZip_ADDR, @Lc_EiwoRecCur_FipsRemittance_CODE, @Ls_EiwoRecCur_StateOfficial_NAME, @Ls_EiwoRecCur_StateOfficialTitle_NAME, @Lc_EiwoRecCur_EmployeeCopy_INDC, @Ls_EiwoRecCur_PenalityLiabilityDescription_TEXT, @Ls_EiwoRecCur_AntiDiscriminationDescription_TEXT, @Ls_EiwoRecCur_PayeeWitholdLimitDescription_TEXT, @Ls_EiwoRecCur_EmployeeContact_NAME, @Lc_EiwoRecCur_EmployeeContactPhone_NUMB, @Lc_EiwoRecCur_EmployeeContactFax_NUMB, @Ls_EiwoRecCur_EmployeeContactEmail_EML, @Lc_EiwoRecCur_DocumentTacking_NUMB, @Lc_EiwoRecCur_Order_IDNO, @Ls_EiwoRecCur_EmployerContact_NAME, @Lc_EiwoRecCur_EmployerContactLine1_ADDR, @Lc_EiwoRecCur_EmployerContactLine2_ADDR, @Lc_EiwoRecCur_EmployerContactCity_ADDR, @Lc_EiwoRecCur_EmployerContactState_ADDR, @Lc_EiwoRecCur_EmployerContactZip_ADDR, @Lc_EiwoRecCur_EmployerContactPhone_NUMB, @Lc_EiwoRecCur_EmployerContactFax_NUMB, @Ls_EiwoRecCur_EmployerContactEmail_EML, @Lc_EiwoRecCur_ChildLast1_NAME, @Lc_EiwoRecCur_ChildFirst1_NAME, @Lc_EiwoRecCur_ChildMiddle1_NAME, @Lc_EiwoRecCur_ChildSuffix1_NAME, @Ld_EiwoRecCur_ChildBirth1_DATE, @Lc_EiwoRecCur_ChildLast2_NAME, @Lc_EiwoRecCur_ChildFirst2_NAME, @Lc_EiwoRecCur_ChildMiddle2_NAME, @Lc_EiwoRecCur_ChildSuffix2_NAME, @Ld_EiwoRecCur_ChildBirth2_DATE, @Lc_EiwoRecCur_ChildLast3_NAME, @Lc_EiwoRecCur_ChildFirst3_NAME, @Lc_EiwoRecCur_ChildMiddle3_NAME, @Lc_EiwoRecCur_ChildSuffix3_NAME, @Ld_EiwoRecCur_ChildBirth3_DATE, @Lc_EiwoRecCur_ChildLast4_NAME, @Lc_EiwoRecCur_ChildFirst4_NAME, @Lc_EiwoRecCur_ChildMiddle4_NAME, @Lc_EiwoRecCur_ChildSuffix4_NAME, @Ld_EiwoRecCur_ChildBirth4_DATE, @Lc_EiwoRecCur_ChildLast5_NAME, @Lc_EiwoRecCur_ChildFirst5_NAME, @Lc_EiwoRecCur_ChildMiddle5_NAME, @Lc_EiwoRecCur_ChildSuffix5_NAME, @Ld_EiwoRecCur_ChildBirth5_DATE, @Lc_EiwoRecCur_ChildLast6_NAME, @Lc_EiwoRecCur_ChildFirst6_NAME, @Lc_EiwoRecCur_ChildMiddle6_NAME, @Lc_EiwoRecCur_ChildSuffix6_NAME, @Ld_EiwoRecCur_ChildBirth6_DATE, @Ln_EiwoRecCur_Remittance_IDNO, @Lc_EiwoRecCur_FirstError_NAME, @Lc_EiwoRecCur_SecondError_NAME, @Lc_EiwoRecCur_MultiError_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

     --writing the records into output file 
     WHILE @Li_FetchStatus_QNTY = 0
      BEGIN
       IF @Ln_EiwoRecCur_Fein_IDNO <> @Ln_FeinOld_IDNO
          AND @Ln_FeinOld_IDNO != 0
        BEGIN
         SET @Ln_TrailerBatchCount_NUMB = @Ln_TrailerBatchCount_NUMB + 1;
         SET @Lc_Control_TEXT = '10000' + CONVERT (CHAR (6), @Ld_Run_DATE, 12) + LTRIM (RTRIM (REPLACE (REPLACE (SUBSTRING (CONVERT (VARCHAR (21), @Ld_Start_DATE, 121), 11, 40), ':', ''), '.', ''))) + RIGHT(REPLICATE('0', 4) + CAST(@Ln_TrailerBatchCount_NUMB AS VARCHAR), 4);
         SET @Ls_ReturnValue_TEXT = 'BTI' + CONVERT (CHAR (22), @Lc_Control_TEXT) + '00000' + CONVERT (CHAR (5), RIGHT (LTRIM (RTRIM ('00000' + CAST (@Ln_BatchCount_NUMB AS VARCHAR))), 5)) + '00000' + '00000' + REPLICATE (@Lc_Space_TEXT, 2361);
         SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtEiwo_P1 ';
         SET @Ls_Sqldata_TEXT = 'OutputRecord_TEXT = ' + ISNULL(@Ls_ReturnValue_TEXT, '');

         INSERT INTO ##ExtEiwo_P1
                     (OutputRecord_TEXT)
              VALUES ( @Ls_ReturnValue_TEXT --OutputRecord_TEXT
         );
        END

       IF @Ln_EiwoRecCur_Fein_IDNO <> @Ln_FeinOld_IDNO
        BEGIN
         --batch header
         SET @Ln_BatchCount_NUMB = 0;
         SET @Ln_HeaderBatchCount_NUMB = @Ln_HeaderBatchCount_NUMB + 1;
         SET @Ln_FileTrailerBatchCount_NUMB = @Ln_FileTrailerBatchCount_NUMB + 1;
         SET @Lc_Control_TEXT = '10000' + CONVERT (CHAR (6), @Ld_Run_DATE, 12) + LTRIM (RTRIM (REPLACE (REPLACE (SUBSTRING (CONVERT (VARCHAR (21), @Ld_Start_DATE, 121), 11, 40), ':', ''), '.', ''))) + RIGHT(REPLICATE('0', 4) + CAST(@Ln_HeaderBatchCount_NUMB AS VARCHAR), 4);
         SET @Ls_ReturnValue_TEXT = 'BHI' + CONVERT (CHAR (22), @Lc_Control_TEXT) + '10000' + CONVERT (CHAR (9), RIGHT (LTRIM (RTRIM ('000000000' + CAST (@Ln_EiwoRecCur_Fein_IDNO AS VARCHAR))), 9)) + REPLICATE (@Lc_Space_TEXT, 9) + CONVERT (CHAR (8), @Ld_Run_DATE, 112) + CONVERT (CHAR (6), REPLACE (CAST (CONVERT (VARCHAR (10), @Ld_Start_DATE, 108) AS CHAR), ':', '')) + REPLICATE (@Lc_Space_TEXT, 2344);
         SET @Ls_Sql_TEXT = 'INSERT INTO  ##ExtEiwo_P1';
         SET @Ls_Sqldata_TEXT = 'OutputRecord_TEXT = ' + ISNULL(@Ls_ReturnValue_TEXT, '');

         INSERT INTO ##ExtEiwo_P1
                     (OutputRecord_TEXT)
              VALUES (@Ls_ReturnValue_TEXT --OutputRecord_TEXT
         );
        END

       SET @Ls_ReturnValue_TEXT = 'DTL' + REPLICATE (@Lc_Space_TEXT, 3) + @Lc_EiwoRecCur_DocumentAction_CODE + CONVERT (CHAR (8), @Lc_EiwoRecCur_Document_DATE, 112) + CONVERT (CHAR (35), @Lc_EiwoRecCur_IssuingState_CODE) + CONVERT (CHAR (35), @Lc_EiwoRecCur_IssuingJurisdiction_NAME) + CONVERT (CHAR (15), @Ln_EiwoRecCur_Case_IDNO) + CONVERT (CHAR (57), @Ls_EiwoRecCur_Employer_NAME) + CONVERT (CHAR (25), @Lc_EiwoRecCur_EmployerLine1_ADDR) + CONVERT (CHAR (25), @Lc_EiwoRecCur_EmployerLine2_ADDR) + CONVERT (CHAR (22), @Lc_EiwoRecCur_EmployerCity_ADDR) + CONVERT (CHAR (2), @Lc_EiwoRecCur_EmployerState_ADDR) + CONVERT (CHAR (9), @Lc_EiwoRecCur_EmployerZip_ADDR) + CONVERT (CHAR (9), RIGHT (LTRIM (RTRIM ('000000000' + CAST (@Ln_EiwoRecCur_Fein_IDNO AS VARCHAR))), 9)) + CONVERT (CHAR (20), @Lc_EiwoRecCur_NcpLast_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_NcpFirst_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_NcpMi_NAME) + CONVERT (CHAR (4), @Lc_EiwoRecCur_NcpSuffix_NAME) + CONVERT (CHAR (9), RIGHT (LTRIM (RTRIM ('000000000' + CAST (@Ln_EiwoRecCur_MemberSsn_NUMB AS VARCHAR))), 9)) + CONVERT (CHAR (8), @Ld_EiwoRecCur_NcpBirth_DATE, 112) + CONVERT (CHAR (57), @Ls_EiwoRecCur_CpLast_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_CpFirst_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_CpMiddle_NAME) + CONVERT (CHAR (4), @Lc_EiwoRecCur_CpSuffix_NAME) + CONVERT (CHAR (35), @Lc_EiwoRecCur_IssuingTribunal_NAME) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_CurCs_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (1), @Lc_EiwoRecCur_FreqCs_CODE) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_PaybackCs_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (1), @Lc_EiwoRecCur_PaybackFreqcs_CODE) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_CurMs_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (1), @Lc_EiwoRecCur_FreqMs_CODE) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_PaybackMs_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (1), @Lc_EiwoRecCur_PaybackFreqMs_CODE) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_CurSs_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (1), @Lc_EiwoRecCur_FreqSs_CODE) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_PaybackSs_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (1), @Lc_EiwoRecCur_PaybackFreqSs_CODE) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_CurOt_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (1), @Lc_EiwoRecCur_FreqOt_CODE) + REPLICATE (@Lc_Space_TEXT, 35) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_TotalCur_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (1), @Lc_EiwoRecCur_FreqTotal_CODE) + CONVERT (CHAR (1), @Lc_EiwoRecCur_Arr12WkDue_CODE) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_WeeklyWithheld_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_BiweeklyWithheld_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_SemiMonthlyWithheld_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_EiwoRecCur_MonthlyWithheld_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR (35), @Lc_EiwoRecCur_SendingState_NAME) + CONVERT (CHAR (2), RIGHT (LTRIM (RTRIM ('00' + CAST (@Lc_EiwoRecCur_DaysBeginWithhold_NUMB AS VARCHAR))), 11)) + CONVERT (CHAR (8), @Lc_EiwoRecCur_IwoStart_DATE) + CONVERT (CHAR (2), RIGHT (LTRIM (RTRIM ('00' + CAST (@Lc_EiwoRecCur_DaysBeginPayment_NUMB AS VARCHAR))), 11)) + CONVERT (CHAR (2), RIGHT (LTRIM (RTRIM ('00' + CAST (@Ln_EiwoRecCur_CcpaPercent_NUMB AS VARCHAR))), 2)) + CONVERT (CHAR (57), @Ls_EiwoRecCur_Payee_NAME) + CONVERT (CHAR (25), @Lc_EiwoRecCur_PayeeLine1_ADDR) + CONVERT (CHAR (25), @Lc_EiwoRecCur_PayeeLine2_ADDR) + CONVERT (CHAR (22), @Lc_EiwoRecCur_PayeeCity_ADDR) + CONVERT (CHAR (2), @Lc_EiwoRecCur_PayeeState_ADDR) + CONVERT (CHAR (9), @Lc_EiwoRecCur_PayeeZip_ADDR) + CONVERT (CHAR (7), @Lc_EiwoRecCur_FipsRemittance_CODE) + CONVERT (CHAR (70), @Ls_EiwoRecCur_StateOfficial_NAME) + CONVERT (CHAR (50), @Ls_EiwoRecCur_StateOfficialTitle_NAME) + REPLICATE (@Lc_Space_TEXT, 1) + CONVERT (CHAR (1), @Lc_EiwoRecCur_EmployeeCopy_INDC) + CONVERT (CHAR (160), @Ls_EiwoRecCur_PenalityLiabilityDescription_TEXT) + CONVERT (CHAR (160), @Ls_EiwoRecCur_AntiDiscriminationDescription_TEXT) + CONVERT (CHAR (160), @Ls_EiwoRecCur_PayeeWitholdLimitDescription_TEXT) + CONVERT (CHAR (57), @Ls_EiwoRecCur_EmployeeContact_NAME) + CONVERT (CHAR (10), RIGHT (LTRIM (RTRIM ('0000000000' + CAST (@Lc_EiwoRecCur_EmployeeContactPhone_NUMB AS VARCHAR))), 10)) + CONVERT (CHAR (10), RIGHT (LTRIM (RTRIM ('0000000000' + CAST (@Lc_EiwoRecCur_EmployeeContactFax_NUMB AS VARCHAR))), 10)) + CONVERT (CHAR (48), @Ls_EiwoRecCur_EmployeeContactEmail_EML) + CONVERT (CHAR (30), @Lc_EiwoRecCur_DocumentTacking_NUMB) + CONVERT (CHAR (30), @Lc_EiwoRecCur_Order_IDNO) + CONVERT (CHAR (57), @Ls_EiwoRecCur_EmployerContact_NAME) + CONVERT (CHAR (25), @Lc_EiwoRecCur_EmployerContactLine1_ADDR) + CONVERT (CHAR (25), @Lc_EiwoRecCur_EmployerContactLine2_ADDR) + CONVERT (CHAR (22), @Lc_EiwoRecCur_EmployerContactCity_ADDR) + CONVERT (CHAR (2), @Lc_EiwoRecCur_EmployerContactState_ADDR) + CONVERT (CHAR (9), @Lc_EiwoRecCur_EmployerContactZip_ADDR) + CONVERT (CHAR (10), RIGHT (LTRIM (RTRIM ('0000000000' + CAST (@Lc_EiwoRecCur_EmployerContactPhone_NUMB AS VARCHAR))), 10)) + CONVERT (CHAR (10), RIGHT (LTRIM (RTRIM ('0000000000' + CAST (@Lc_EiwoRecCur_EmployerContactFax_NUMB AS VARCHAR))), 10)) + CONVERT (CHAR (48), @Ls_EiwoRecCur_EmployerContactEmail_EML) + CONVERT (CHAR (20), @Lc_EiwoRecCur_ChildLast1_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildFirst1_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildMiddle1_NAME) + CONVERT (CHAR (4), @Lc_EiwoRecCur_ChildSuffix1_NAME) + CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth1_DATE, 112) + CONVERT (CHAR (20), @Lc_EiwoRecCur_ChildLast2_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildFirst2_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildMiddle2_NAME) + CONVERT (CHAR (4), @Lc_EiwoRecCur_ChildSuffix2_NAME) + CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth2_DATE, 112) + CONVERT (CHAR (20), @Lc_EiwoRecCur_ChildLast3_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildFirst3_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildMiddle3_NAME) + CONVERT (CHAR (4), @Lc_EiwoRecCur_ChildSuffix3_NAME) + CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth3_DATE, 112) + CONVERT (CHAR (20), @Lc_EiwoRecCur_ChildLast4_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildFirst4_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildMiddle4_NAME) + CONVERT (CHAR (4), @Lc_EiwoRecCur_ChildSuffix4_NAME) + CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth4_DATE, 112) + CONVERT (CHAR (20), @Lc_EiwoRecCur_ChildLast5_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildFirst5_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildMiddle5_NAME) + CONVERT (CHAR (4), @Lc_EiwoRecCur_ChildSuffix5_NAME) + CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth5_DATE, 112) + CONVERT (CHAR (20), @Lc_EiwoRecCur_ChildLast6_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildFirst6_NAME) + CONVERT (CHAR (15), @Lc_EiwoRecCur_ChildMiddle6_NAME) + CONVERT (CHAR (4), @Lc_EiwoRecCur_ChildSuffix6_NAME) + CONVERT (CHAR (8), @Ld_EiwoRecCur_ChildBirth6_DATE, 112) + CONVERT (CHAR (11), RIGHT (LTRIM (RTRIM ('00000000000' + REPLACE(CAST (@Ln_LumpSum_AMNT AS VARCHAR), '.', ''))), 11)) + CONVERT (CHAR(9), @Lc_Space_TEXT) + CONVERT (CHAR (20), CAST(@Ln_EiwoRecCur_Remittance_IDNO AS VARCHAR)) + CONVERT (CHAR(25), '10') + CONVERT (CHAR (32), @Lc_EiwoRecCur_FirstError_NAME) + CONVERT (CHAR (32), @Lc_EiwoRecCur_SecondError_NAME) + CONVERT (CHAR (1), @Lc_EiwoRecCur_MultiError_INDC) + CONVERT (CHAR(89), @Lc_Space_TEXT);
       SET @Ls_ReturnValue_TEXT = REPLACE(REPLACE(@Ls_ReturnValue_TEXT, '19000101', '        '), '00010101', '        ');
       SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtEiwo_P1';
       SET @Ls_Sqldata_TEXT = 'OutputRecord_TEXT = ' + ISNULL(@Ls_ReturnValue_TEXT, '');

       INSERT INTO ##ExtEiwo_P1
                   (OutputRecord_TEXT)
            VALUES ( @Ls_ReturnValue_TEXT --OutputRecord_TEXT
       );

       SET @Ln_BatchCount_NUMB = @Ln_BatchCount_NUMB + 1;

       IF @Ln_EiwoRecCur_Fein_IDNO <> @Ln_FeinOld_IDNO
        BEGIN
         SET @Ln_FeinOld_IDNO = @Ln_EiwoRecCur_Fein_IDNO;
        END

       FETCH NEXT FROM EiwoRec_CUR INTO @Lc_EiwoRecCur_DocumentAction_CODE, @Lc_EiwoRecCur_Document_DATE, @Lc_EiwoRecCur_IssuingState_CODE, @Lc_EiwoRecCur_IssuingJurisdiction_NAME, @Ln_EiwoRecCur_Case_IDNO, @Ls_EiwoRecCur_Employer_NAME, @Lc_EiwoRecCur_EmployerLine1_ADDR, @Lc_EiwoRecCur_EmployerLine2_ADDR, @Lc_EiwoRecCur_EmployerCity_ADDR, @Lc_EiwoRecCur_EmployerState_ADDR, @Lc_EiwoRecCur_EmployerZip_ADDR, @Ln_EiwoRecCur_Fein_IDNO, @Lc_EiwoRecCur_NcpLast_NAME, @Lc_EiwoRecCur_NcpFirst_NAME, @Lc_EiwoRecCur_NcpMi_NAME, @Lc_EiwoRecCur_NcpSuffix_NAME, @Ln_EiwoRecCur_MemberSsn_NUMB, @Ld_EiwoRecCur_NcpBirth_DATE, @Ls_EiwoRecCur_CpLast_NAME, @Lc_EiwoRecCur_CpFirst_NAME, @Lc_EiwoRecCur_CpMiddle_NAME, @Lc_EiwoRecCur_CpSuffix_NAME, @Lc_EiwoRecCur_IssuingTribunal_NAME, @Ln_EiwoRecCur_CurCs_AMNT, @Lc_EiwoRecCur_FreqCs_CODE, @Ln_EiwoRecCur_PaybackCs_AMNT, @Lc_EiwoRecCur_PaybackFreqcs_CODE, @Ln_EiwoRecCur_CurMs_AMNT, @Lc_EiwoRecCur_FreqMs_CODE, @Ln_EiwoRecCur_PaybackMs_AMNT, @Lc_EiwoRecCur_PaybackFreqMs_CODE, @Ln_EiwoRecCur_CurSs_AMNT, @Lc_EiwoRecCur_FreqSs_CODE, @Ln_EiwoRecCur_PaybackSs_AMNT, @Lc_EiwoRecCur_PaybackFreqSs_CODE, @Ln_EiwoRecCur_CurOt_AMNT, @Lc_EiwoRecCur_FreqOt_CODE, @Lc_EiwoRecCur_ReasonOt_CODE, @Ln_EiwoRecCur_TotalCur_AMNT, @Lc_EiwoRecCur_FreqTotal_CODE, @Lc_EiwoRecCur_Arr12WkDue_CODE, @Ln_EiwoRecCur_WeeklyWithheld_AMNT, @Ln_EiwoRecCur_BiweeklyWithheld_AMNT, @Ln_EiwoRecCur_SemiMonthlyWithheld_AMNT, @Ln_EiwoRecCur_MonthlyWithheld_AMNT, @Lc_EiwoRecCur_SendingState_NAME, @Lc_EiwoRecCur_DaysBeginWithhold_NUMB, @Lc_EiwoRecCur_IwoStart_DATE, @Lc_EiwoRecCur_DaysBeginPayment_NUMB, @Ln_EiwoRecCur_CcpaPercent_NUMB, @Ls_EiwoRecCur_Payee_NAME, @Lc_EiwoRecCur_PayeeLine1_ADDR, @Lc_EiwoRecCur_PayeeLine2_ADDR, @Lc_EiwoRecCur_PayeeCity_ADDR, @Lc_EiwoRecCur_PayeeState_ADDR, @Lc_EiwoRecCur_PayeeZip_ADDR, @Lc_EiwoRecCur_FipsRemittance_CODE, @Ls_EiwoRecCur_StateOfficial_NAME, @Ls_EiwoRecCur_StateOfficialTitle_NAME, @Lc_EiwoRecCur_EmployeeCopy_INDC, @Ls_EiwoRecCur_PenalityLiabilityDescription_TEXT, @Ls_EiwoRecCur_AntiDiscriminationDescription_TEXT, @Ls_EiwoRecCur_PayeeWitholdLimitDescription_TEXT, @Ls_EiwoRecCur_EmployeeContact_NAME, @Lc_EiwoRecCur_EmployeeContactPhone_NUMB, @Lc_EiwoRecCur_EmployeeContactFax_NUMB, @Ls_EiwoRecCur_EmployeeContactEmail_EML, @Lc_EiwoRecCur_DocumentTacking_NUMB, @Lc_EiwoRecCur_Order_IDNO, @Ls_EiwoRecCur_EmployerContact_NAME, @Lc_EiwoRecCur_EmployerContactLine1_ADDR, @Lc_EiwoRecCur_EmployerContactLine2_ADDR, @Lc_EiwoRecCur_EmployerContactCity_ADDR, @Lc_EiwoRecCur_EmployerContactState_ADDR, @Lc_EiwoRecCur_EmployerContactZip_ADDR, @Lc_EiwoRecCur_EmployerContactPhone_NUMB, @Lc_EiwoRecCur_EmployerContactFax_NUMB, @Ls_EiwoRecCur_EmployerContactEmail_EML, @Lc_EiwoRecCur_ChildLast1_NAME, @Lc_EiwoRecCur_ChildFirst1_NAME, @Lc_EiwoRecCur_ChildMiddle1_NAME, @Lc_EiwoRecCur_ChildSuffix1_NAME, @Ld_EiwoRecCur_ChildBirth1_DATE, @Lc_EiwoRecCur_ChildLast2_NAME, @Lc_EiwoRecCur_ChildFirst2_NAME, @Lc_EiwoRecCur_ChildMiddle2_NAME, @Lc_EiwoRecCur_ChildSuffix2_NAME, @Ld_EiwoRecCur_ChildBirth2_DATE, @Lc_EiwoRecCur_ChildLast3_NAME, @Lc_EiwoRecCur_ChildFirst3_NAME, @Lc_EiwoRecCur_ChildMiddle3_NAME, @Lc_EiwoRecCur_ChildSuffix3_NAME, @Ld_EiwoRecCur_ChildBirth3_DATE, @Lc_EiwoRecCur_ChildLast4_NAME, @Lc_EiwoRecCur_ChildFirst4_NAME, @Lc_EiwoRecCur_ChildMiddle4_NAME, @Lc_EiwoRecCur_ChildSuffix4_NAME, @Ld_EiwoRecCur_ChildBirth4_DATE, @Lc_EiwoRecCur_ChildLast5_NAME, @Lc_EiwoRecCur_ChildFirst5_NAME, @Lc_EiwoRecCur_ChildMiddle5_NAME, @Lc_EiwoRecCur_ChildSuffix5_NAME, @Ld_EiwoRecCur_ChildBirth5_DATE, @Lc_EiwoRecCur_ChildLast6_NAME, @Lc_EiwoRecCur_ChildFirst6_NAME, @Lc_EiwoRecCur_ChildMiddle6_NAME, @Lc_EiwoRecCur_ChildSuffix6_NAME, @Ld_EiwoRecCur_ChildBirth6_DATE, @Ln_EiwoRecCur_Remittance_IDNO, @Lc_EiwoRecCur_FirstError_NAME, @Lc_EiwoRecCur_SecondError_NAME, @Lc_EiwoRecCur_MultiError_INDC;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE EiwoRec_CUR;

     DEALLOCATE EiwoRec_CUR;

     IF @Ln_BatchCount_NUMB != 0
      BEGIN
       SET @Ln_TrailerBatchCount_NUMB = @Ln_TrailerBatchCount_NUMB + 1;
       SET @Lc_Control_TEXT = '10000' + CONVERT (CHAR (6), @Ld_Run_DATE, 12) + LTRIM (RTRIM (REPLACE (REPLACE (SUBSTRING (CONVERT (VARCHAR (21), @Ld_Start_DATE, 121), 11, 40), ':', ''), '.', ''))) + RIGHT(REPLICATE('0', 4) + CAST(@Ln_TrailerBatchCount_NUMB AS VARCHAR), 4);
       SET @Ls_ReturnValue_TEXT = 'BTI' + CONVERT (CHAR (22), @Lc_Control_TEXT) + '00000' + CONVERT (CHAR (5), RIGHT (LTRIM (RTRIM ('00000' + CAST (@Ln_BatchCount_NUMB AS VARCHAR))), 5)) + '00000' + '00000' + REPLICATE (@Lc_Space_TEXT, 2361);
       SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtEiwo_P1 ';
       SET @Ls_Sqldata_TEXT = 'OutputRecord_TEXT = ' + ISNULL(@Ls_ReturnValue_TEXT, '');

       INSERT INTO ##ExtEiwo_P1
                   (OutputRecord_TEXT)
            VALUES ( @Ls_ReturnValue_TEXT --OutputRecord_TEXT
       );
      END
    END

   SET @Lc_Control_TEXT = '10000' + CONVERT (CHAR (6), @Ld_Run_DATE, 12) + LTRIM (RTRIM (REPLACE (REPLACE (SUBSTRING (CONVERT (VARCHAR (21), @Ld_Start_DATE, 121), 11, 40), ':', ''), '.', ''))) + '0000';
   SET @Ls_ReturnValue_TEXT = 'FTI' + CONVERT (CHAR (22), @Lc_Control_TEXT) + CONVERT (CHAR (5), RIGHT (LTRIM (RTRIM ('00000' + CAST (@Ln_FileTrailerBatchCount_NUMB AS VARCHAR))), 5)) + '00000' + '00000' + '00000' + REPLICATE (@Lc_Space_TEXT, 2361);
   SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtEiwo_P1 ';
   SET @Ls_Sqldata_TEXT = 'OutputRecord_TEXT = ' + ISNULL(@Ls_ReturnValue_TEXT, '');

   INSERT INTO ##ExtEiwo_P1
               (OutputRecord_TEXT)
        VALUES ( @Ls_ReturnValue_TEXT --OutputRecord_TEXT
   );

   SET @Ls_BcpCommand_TEXT = 'SELECT OutputRecord_TEXT FROM  ##ExtEiwo_P1 Order by Seq_NUMB';

   COMMIT TRANSACTION EiwoTran;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@Ls_FileName_TEXT, '') + ', Query_TEXT = ' + ISNULL(@Ls_BcpCommand_TEXT, '');

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_FileName_TEXT,
    @As_Query_TEXT            = @Ls_BcpCommand_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION EiwoTran;

   -- Update the parameter table with the job run date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the Status of job in BSTL_Y1 as Success
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@LC_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   DROP TABLE ##ExtEiwo_P1;

   COMMIT TRANSACTION EiwoTran;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EiwoTran;
    END;

   --Drop temporary table if exists
   IF OBJECT_ID ('tempdb..##ExtEiwo_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtEiwo_P1;
    END

   -- Close the Cursor
   IF CURSOR_STATUS ('local', 'Exteiw_CUR') IN (0, 1)
    BEGIN
     CLOSE Exteiw_CUR;

     DEALLOCATE Exteiw_CUR;
    END

   IF CURSOR_STATUS ('local', 'EiwoRec_CUR') IN (0, 1)
    BEGIN
     CLOSE EiwoRec_CUR;

     DEALLOCATE EiwoRec_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
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
    @As_CursorLocation_TEXT       = @Ls_Sql_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
