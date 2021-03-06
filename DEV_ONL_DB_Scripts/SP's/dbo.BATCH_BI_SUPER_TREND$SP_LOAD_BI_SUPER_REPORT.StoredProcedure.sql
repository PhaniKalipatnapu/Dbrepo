/****** Object:  StoredProcedure [dbo].[BATCH_BI_SUPER_TREND$SP_LOAD_BI_SUPER_REPORT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_BI_SUPER_TREND$SP_LOAD_BI_SUPER_REPORT
Programmer Name   :	Imp Team
Description       :	This process reads, loads the end of month case level summary details as wells as member and 
					caseworker details data into BSURD_Y1, BSURS_Y1 tables 
Frequency		  : Monthly.					
Developed On      :	03/06/2012
Called BY         :	None
Called On         :	BATCH_COMMON$SP_GET_BATCH_DETAILS,
					BATCH_COMMON$BATE_LOG,  
					BATCH_COMMON$BSTL_LOG,
					BATCH_COMMON$SP_UPDATE_PARM_DATE,
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	0.01
-------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_SUPER_TREND$SP_LOAD_BI_SUPER_REPORT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_County99_IDNO               NUMERIC(5) = 99,
          @Ln_County1_IDNO                NUMERIC(5) = 1,
          @Ln_County3_IDNO                NUMERIC(5) = 3,
          @Ln_County5_IDNO                NUMERIC(5) = 5,
          @Ln_Line_NUMB                   NUMERIC(5) = 1,
          @Li_ReceiptReversed1250_NUMB    INT = 1250,
          @Li_ReceiptDistributed1820_NUMB INT = 1820,
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_CheckRecipient1_CODE        CHAR(1) = '1',
          @Lc_CheckRecipient3_CODE        CHAR(1) = '3',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_TypeRecordO_CODE            CHAR(1) = 'O',
          @Lc_ActionR_CODE                CHAR(1) = 'R',
          @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',
          @Lc_TypeErrorWarning_CODE       CHAR(1) = 'W',
          @Lc_RespondInitI_CODE           CHAR(1) = 'I',
          @Lc_RespondInitC_CODE           CHAR(1) = 'C',
          @Lc_RespondInitT_CODE           CHAR(1) = 'T',
          @Lc_RespondInitR_CODE           CHAR(1) = 'R',
          @Lc_RespondInitY_CODE           CHAR(1) = 'Y',
          @Lc_RespondInitS_CODE           CHAR(1) = 'S',
          @Lc_TypeCaseH_CODE              CHAR(1) = 'H',
          @Lc_StatusCaseOpen_CODE         CHAR(1) = 'O',
          @Lc_StatusCaseClose_CODE        CHAR(1) = 'C',
          @Lc_IoDirectionI_CODE           CHAR(1) = 'I',
          @Lc_RefAssistR_CODE             CHAR(1) = 'R',
          @Lc_CaseRelationshipNcp_CODE    CHAR(1) = 'A',
          @Lc_CaseRelationshipP_CODE      CHAR(1) = 'P',
          @Lc_StatusLocatedN_CODE         CHAR(1) = 'N',
          @Lc_TypeAddressMailing_CODE     CHAR(1) = 'M',
          @Lc_MedicalOnlyN_INDC           CHAR(1) = 'N',
          @Lc_TypeCaseA_CODE              CHAR(1) = 'A',
          @Lc_TypeCaseN_CODE              CHAR(1) = 'N',
          @Lc_TypeCaseF_CODE              CHAR(1) = 'F',
          @Lc_TypeCaseJ_CODE              CHAR(1) = 'J',
          @Lc_ExcludeStateN_CODE          CHAR(1) = 'N',
          @Lc_ExcludeStateY_CODE          CHAR(1) = 'Y',
          @Lc_StatusGood_CODE             CHAR(1) = 'Y',
          @Lc_ExcludeIrsN_CODE            CHAR(1) = 'N',
          @Lc_Msg_CODE                    CHAR(1) = ' ',
          @Lc_CaseMemberStatusA_CODE	  CHAR(1) = 'A',	
          @Lc_TypeTransactionAdd_CODE     CHAR(1) = 'A',
          @Lc_TypeTransactionInit_CODE	  CHAR(1) = 'I',
          @Lc_StatusRequestPn_CODE        CHAR(2) = 'PN',
          @Lc_CaseCategoryDp_CODE         CHAR(2) = 'DP',
          @Lc_CaseCategoryMo_CODE         CHAR(2) = 'MO',
          @Lc_CaseCategoryPa_CODE         CHAR(2) = 'PA',
          @Lc_CaseCategoryPo_CODE         CHAR(2) = 'PO',
          @Lc_ReasonStatusDw_CODE         CHAR(2) = 'DW',
          @Lc_ReasonStatusGo_CODE         CHAR(2) = 'GO',
          @Lc_ReasonStatusNa_CODE         CHAR(2) = 'NA',
          @Lc_ReasonStatusGm_CODE         CHAR(2) = 'GM',
          @Lc_ReasonStatusSc_CODE         CHAR(2) = 'SC',
          @Lc_ReasonStatusSd_CODE         CHAR(2) = 'SD',
          @Lc_ReasonStatusSe_CODE         CHAR(2) = 'SE',
          @Lc_ReasonStatusPj_CODE         CHAR(2) = 'PJ',
          @Lc_ReasonStatusPg_CODE         CHAR(2) = 'PG',
          @Lc_ReasonStatusCi_CODE         CHAR(2) = 'CI',
          @Lc_ReasonStatusPl_CODE         CHAR(2) = 'PL',
          @Lc_ReasonStatusCm_CODE         CHAR(2) = 'CM',
          @Lc_ReasonStatusGp_CODE         CHAR(2) = 'GP',
          @Lc_ReasonStatusRp_CODE         CHAR(2) = 'RP',
          @Lc_ReasonStatusCd_CODE         CHAR(2) = 'CD',
          @Lc_ReasonStatusMs_CODE         CHAR(2) = 'MS',
          @Lc_ReasonStatusAe_CODE         CHAR(2) = 'AE',
          @Lc_ReasonStatusAf_CODE         CHAR(2) = 'AF',
          @Lc_ReasonStatusUn_CODE         CHAR(2) = 'UN',
          @Lc_ReasonStatusYa_CODE         CHAR(2) = 'YA',
          @Lc_ReasonStatusPs_CODE         CHAR(2) = 'PS',
          @Lc_ReasonStatusBi_CODE         CHAR(2) = 'BI',
          @Lc_ReasonChangeOm_CODE         CHAR(2) = 'OM',
          @Lc_FunctionLo1_CODE            CHAR(3) = 'LO1',
          @Lc_StatusStrt_CODE             CHAR(4) = 'STRT',
          @Lc_StatusComp_CODE             CHAR(4) = 'COMP',
          @Lc_ActivityMajorMapp_CODE      CHAR(4) = 'MAPP',
          @Lc_ActivityMajorRofo_CODE      CHAR(4) = 'ROFO',
          @Lc_ActivityMajorEstp_CODE      CHAR(4) = 'ESTP',
          @Lc_ActivityMajorGtst_CODE      CHAR(4) = 'GTST',
          @Lc_ActivityMajorObra_CODE      CHAR(4) = 'OBRA',
          @Lc_ActivityMajorLsnr_CODE      CHAR(4) = 'LSNR',
          @Lc_ActivityMajorCclo_CODE      CHAR(4) = 'CCLO',
          @Lc_StatusEnforceWcap_CODE      CHAR(4) = 'WCAP',
          @Lc_StatusExmt_CODE             CHAR(4) = 'EXMT',
          @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
          @Lc_WorkerRoleRc005_CODE        CHAR(5) = 'RC005',
          @Lc_WorkerRoleRs016_CODE        CHAR(5) = 'RS016',
          @Lc_WorkerRoleRt001_CODE        CHAR(5) = 'RT001',
          @Lc_WorkerRoleRe001_CODE        CHAR(5) = 'RE001',
          @Lc_WorkerRoleRs017_CODE        CHAR(5) = 'RS017',
          @Lc_WorkerRoleRp004_CODE        CHAR(5) = 'RP004',
          @Lc_ActivityMinorMonls_CODE     CHAR(5) = 'MONLS',
          @Lc_ActivityMinorAdagr_CODE     CHAR(5) = 'ADAGR',
          @Lc_ActivityMinorAdror_CODE     CHAR(5) = 'ADROR',
          @Lc_ActivityMinorGncdo_CODE     CHAR(5) = 'GNCDO',
          @Lc_ActivityMinorAordd_CODE     CHAR(5) = 'AORDD',
          @Lc_ActivityMinorPetde_CODE     CHAR(5) = 'PETDE',
          @Lc_ActivityMinorAserr_CODE     CHAR(5) = 'ASERR',
          @Lc_ActivityMinorAschd_CODE     CHAR(5) = 'ASCHD',
          @Lc_ActivityMinorAgtsc_CODE     CHAR(5) = 'AGTSC',
          @Lc_ActivityMinorFamup_CODE     CHAR(5) = 'FAMUP',
          @Lc_ActivityMinorWtrpa_CODE     CHAR(5) = 'WTRPA',
          @Lc_ActivityMinorFcpro_CODE     CHAR(5) = 'FCPRO',
          @Lc_ActivityMinorWrdrs_CODE     CHAR(5) = 'WRDRS',
          @Lc_ReasonAadin_CODE            CHAR(5) = 'AADIN',
          @Lc_ReasonErres_CODE            CHAR(5) = 'ERRES',
          @Lc_ReasonSrpat_CODE            CHAR(5) = 'SRPAT',
          @Lc_ReasonSrord_CODE            CHAR(5) = 'SRORD',
          @Lc_ErrorE0944_CODE             CHAR(5) = 'E0944',
          @Lc_Job_ID                      CHAR(7) = 'DEB8115',
          @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT        VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                VARCHAR(100) = 'BATCH_BI_SUPER_TREND',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_LOAD_BI_SUPER_REPORT',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = ' ',
          @Ls_Sql_TEXT                    VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT                VARCHAR(5000) = ' ',
          @Ls_DynamicaSql_TEXT            VARCHAR(5000) = ' ',
          @Ld_High_DATE                   DATE = '12/31/9999';
  DECLARE @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_Zero_NUMB                   NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_MonthReport_NUMB            NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(11) = 0,
          @Ld_Run_DATE                    DATE,
          @Ld_ReportingMonthFrom_DATE     DATE,
          @Ld_ReportingMonthTo_DATE       DATE,
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
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   BEGIN TRANSACTION SUPERTREND_LOAD;

   SET @Ld_ReportingMonthFrom_DATE = DATEADD(DAY, -(DAY(@Ld_Run_DATE) - 1), @Ld_Run_DATE);

   IF DATEPART(DAY, @Ld_Run_DATE) < 25
    BEGIN
     SET @Ld_ReportingMonthFrom_DATE =DATEADD(MONTH, -1, @Ld_ReportingMonthFrom_DATE);
    END

   SET @Ld_ReportingMonthTo_DATE = DATEADD(DAY, -1, DATEADD(MONTH, 1, @Ld_ReportingMonthFrom_DATE));
   SET @Ln_MonthReport_NUMB = CONVERT(VARCHAR(6), @Ld_ReportingMonthFrom_DATE, 112);
   SET @Ls_Sql_TEXT = 'CHECKING THE DATA EXISTS OR NOT';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF EXISTS (SELECT 1
                FROM BSURD_Y1
               WHERE MthReport_NUMB = @Ln_MonthReport_NUMB)
       OR EXISTS (SELECT 1
                    FROM BSURS_Y1
                   WHERE MthReport_NUMB = @Ln_MonthReport_NUMB)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'BATCH ALREADY RAN FOR THIS MONTH ' + DATENAME(MONTH, @Ld_ReportingMonthFrom_DATE) + ', ' + CAST(YEAR(@Ld_ReportingMonthFrom_DATE) AS VARCHAR) + ' AND DATA AVAILABLE IN REPORTING TABLES';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DELETE 1 YEAR OLD DATA FROM BSURD_Y1 TABLES';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE BSURD_Y1
    WHERE MthReport_NUMB <= CONVERT(VARCHAR(6), DATEADD (YY, -1, @Ld_Run_DATE), 112);

   SET @Ls_Sql_TEXT = 'DELETE 1 YEAR OLD DATA FROM BSURD_Y1 TABLES';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE BSURS_Y1
    WHERE MthReport_NUMB <= CONVERT(VARCHAR(6), DATEADD (YY, -1, @Ld_Run_DATE), 112);

   SET @Ls_Sql_TEXT = 'INSERT INTO BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Line1_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line2_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line3_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line4_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line5_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line6_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line7_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line8_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line9_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line10_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line11_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line12_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line13_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line14_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line15_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line16_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line17_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line18_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line19_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line20_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line21_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line22_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line23_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line24_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line25_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line26_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line27_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line28_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line29_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line30_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line31_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line32_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line33_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line34_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line35_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line36_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line37_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line38_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line39_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line40_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line41_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line42_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line43_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line44_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line45_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line46_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line47_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line48_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line49_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line50_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line51_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line52_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line53_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line54_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line55_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line56_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line57_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line58_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line59_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line60_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line61_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line62_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Line63_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   INSERT INTO BSURD_Y1
               (Case_IDNO,
                MthReport_NUMB,
                TypeCase_CODE,
                County_IDNO,
                Worker_ID,
                Supervisor_ID,
                Line1_NUMB,
                Line2_NUMB,
                Line3_NUMB,
                Line4_NUMB,
                Line5_NUMB,
                Line6_NUMB,
                Line7_NUMB,
                Line8_NUMB,
                Line9_NUMB,
                Line10_NUMB,
                Line11_NUMB,
                Line12_NUMB,
                Line13_NUMB,
                Line14_NUMB,
                Line15_NUMB,
                Line16_NUMB,
                Line17_NUMB,
                Line18_NUMB,
                Line19_NUMB,
                Line20_NUMB,
                Line21_NUMB,
                Line22_NUMB,
                Line23_NUMB,
                Line24_NUMB,
                Line25_NUMB,
                Line26_NUMB,
                Line27_NUMB,
                Line28_NUMB,
                Line29_NUMB,
                Line30_NUMB,
                Line31_NUMB,
                Line32_NUMB,
                Line33_NUMB,
                Line34_NUMB,
                Line35_NUMB,
                Line36_NUMB,
                Line37_NUMB,
                Line38_NUMB,
                Line39_NUMB,
                Line40_NUMB,
                Line41_NUMB,
                Line42_NUMB,
                Line43_NUMB,
                Line44_NUMB,
                Line45_NUMB,
                Line46_NUMB,
                Line47_NUMB,
                Line48_NUMB,
                Line49_NUMB,
                Line50_NUMB,
                Line51_NUMB,
                Line52_NUMB,
                Line53_AMNT,
                Line54_AMNT,
                Line55_AMNT,
                Line56_NUMB,
                Line57_NUMB,
                Line58_NUMB,
                Line59_NUMB,
                Line60_NUMB,
                Line61_NUMB,
                Line62_NUMB,
                Line63_NUMB)
   SELECT DISTINCT
          a.Case_IDNO,
          @Ln_MonthReport_NUMB AS MthReport_NUMB,
          a.TypeCase_CODE,
          a.County_IDNO,
          a.Worker_ID,
          b.Supervisor_ID,
          @Ln_Zero_NUMB AS Line1_NUMB,
          @Ln_Zero_NUMB AS Line2_NUMB,
          @Ln_Zero_NUMB AS Line3_NUMB,
          @Ln_Zero_NUMB AS Line4_NUMB,
          @Ln_Zero_NUMB AS Line5_NUMB,
          @Ln_Zero_NUMB AS Line6_NUMB,
          @Ln_Zero_NUMB AS Line7_NUMB,
          @Ln_Zero_NUMB AS Line8_NUMB,
          @Ln_Zero_NUMB AS Line9_NUMB,
          @Ln_Zero_NUMB AS Line10_NUMB,
          @Ln_Zero_NUMB AS Line11_NUMB,
          @Ln_Zero_NUMB AS Line12_NUMB,
          @Ln_Zero_NUMB AS Line13_NUMB,
          @Ln_Zero_NUMB AS Line14_NUMB,
          @Ln_Zero_NUMB AS Line15_NUMB,
          @Ln_Zero_NUMB AS Line16_NUMB,
          @Ln_Zero_NUMB AS Line17_NUMB,
          @Ln_Zero_NUMB AS Line18_NUMB,
          @Ln_Zero_NUMB AS Line19_NUMB,
          @Ln_Zero_NUMB AS Line20_NUMB,
          @Ln_Zero_NUMB AS Line21_NUMB,
          @Ln_Zero_NUMB AS Line22_NUMB,
          @Ln_Zero_NUMB AS Line23_NUMB,
          @Ln_Zero_NUMB AS Line24_NUMB,
          @Ln_Zero_NUMB AS Line25_NUMB,
          @Ln_Zero_NUMB AS Line26_NUMB,
          @Ln_Zero_NUMB AS Line27_NUMB,
          @Ln_Zero_NUMB AS Line28_NUMB,
          @Ln_Zero_NUMB AS Line29_NUMB,
          @Ln_Zero_NUMB AS Line30_NUMB,
          @Ln_Zero_NUMB AS Line31_NUMB,
          @Ln_Zero_NUMB AS Line32_NUMB,
          @Ln_Zero_NUMB AS Line33_NUMB,
          @Ln_Zero_NUMB AS Line34_NUMB,
          @Ln_Zero_NUMB AS Line35_NUMB,
          @Ln_Zero_NUMB AS Line36_NUMB,
          @Ln_Zero_NUMB AS Line37_NUMB,
          @Ln_Zero_NUMB AS Line38_NUMB,
          @Ln_Zero_NUMB AS Line39_NUMB,
          @Ln_Zero_NUMB AS Line40_NUMB,
          @Ln_Zero_NUMB AS Line41_NUMB,
          @Ln_Zero_NUMB AS Line42_NUMB,
          @Ln_Zero_NUMB AS Line43_NUMB,
          @Ln_Zero_NUMB AS Line44_NUMB,
          @Ln_Zero_NUMB AS Line45_NUMB,
          @Ln_Zero_NUMB AS Line46_NUMB,
          @Ln_Zero_NUMB AS Line47_NUMB,
          @Ln_Zero_NUMB AS Line48_NUMB,
          @Ln_Zero_NUMB AS Line49_NUMB,
          @Ln_Zero_NUMB AS Line50_NUMB,
          @Ln_Zero_NUMB AS Line51_NUMB,
          @Ln_Zero_NUMB AS Line52_NUMB,
          @Ln_Zero_NUMB AS Line53_AMNT,
          @Ln_Zero_NUMB AS Line54_AMNT,
          @Ln_Zero_NUMB AS Line55_AMNT,
          @Ln_Zero_NUMB AS Line56_NUMB,
          @Ln_Zero_NUMB AS Line57_NUMB,
          @Ln_Zero_NUMB AS Line58_NUMB,
          @Ln_Zero_NUMB AS Line59_NUMB,
          @Ln_Zero_NUMB AS Line60_NUMB,
          @Ln_Zero_NUMB AS Line61_NUMB,
          @Ln_Zero_NUMB AS Line62_NUMB,
          @Ln_Zero_NUMB AS Line63_NUMB
     FROM CASE_Y1 a,
          USRL_Y1 b
    WHERE a.Worker_ID = b.Worker_ID
      AND b.Expire_DATE = @Ld_High_DATE
      AND b.EndValidity_DATE = @Ld_High_DATE
      AND a.County_IDNO = b.Office_IDNO
      AND b.Role_ID = (SELECT CASE
                               WHEN a.TypeCase_CODE = @Lc_TypeCaseH_CODE
                                THEN
                                CASE
                                 WHEN EXISTS (SELECT 1
                                                FROM USRL_Y1 c
                                               WHERE c.Worker_ID = b.Worker_ID
                                                 AND c.Expire_DATE = @Ld_High_DATE
                                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                                 AND c.Office_IDNO = b.Office_IDNO
                                                 AND c.Role_ID = @Lc_WorkerRoleRc005_CODE)
                                  THEN @Lc_WorkerRoleRc005_CODE
                                 WHEN EXISTS (SELECT 1
                                                FROM USRL_Y1 c
                                               WHERE c.Worker_ID = b.Worker_ID
                                                 AND c.Expire_DATE = @Ld_High_DATE
                                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                                 AND c.Office_IDNO = b.Office_IDNO
                                                 AND c.Role_ID = @Lc_WorkerRoleRp004_CODE)
                                  THEN @Lc_WorkerRoleRp004_CODE
                                 ELSE @Lc_WorkerRoleRs017_CODE
                                END
                               WHEN a.RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE)
                                THEN
                                CASE
                                 WHEN EXISTS (SELECT 1
                                                FROM USRL_Y1 c
                                               WHERE c.Worker_ID = b.Worker_ID
                                                 AND c.Expire_DATE = @Ld_High_DATE
                                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                                 AND c.Office_IDNO = b.Office_IDNO
                                                 AND c.Role_ID = @Lc_WorkerRoleRs016_CODE)
                                  THEN @Lc_WorkerRoleRs016_CODE
                                 WHEN EXISTS (SELECT 1
                                                FROM USRL_Y1 c
                                               WHERE c.Worker_ID = b.Worker_ID
                                                 AND c.Expire_DATE = @Ld_High_DATE
                                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                                 AND c.Office_IDNO = b.Office_IDNO
                                                 AND c.Role_ID = @Lc_WorkerRoleRp004_CODE)
                                  THEN @Lc_WorkerRoleRp004_CODE
                                 ELSE @Lc_WorkerRoleRs017_CODE
                                END
                               WHEN NOT EXISTS (SELECT 1
                                                  FROM SORD_Y1 s
                                                 WHERE s.Case_IDNO = a.Case_IDNO)
                                THEN
                                CASE
                                 WHEN EXISTS (SELECT 1
                                                FROM USRL_Y1 c
                                               WHERE c.Worker_ID = b.Worker_ID
                                                 AND c.Expire_DATE = @Ld_High_DATE
                                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                                 AND c.Office_IDNO = b.Office_IDNO
                                                 AND c.Role_ID = @Lc_WorkerRoleRt001_CODE)
                                  THEN @Lc_WorkerRoleRt001_CODE
                                 WHEN EXISTS (SELECT 1
                                                FROM USRL_Y1 c
                                               WHERE c.Worker_ID = b.Worker_ID
                                                 AND c.Expire_DATE = @Ld_High_DATE
                                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                                 AND c.Office_IDNO = b.Office_IDNO
                                                 AND c.Role_ID = @Lc_WorkerRoleRp004_CODE)
                                  THEN @Lc_WorkerRoleRp004_CODE
                                 ELSE @Lc_WorkerRoleRs017_CODE
                                END
                               WHEN EXISTS (SELECT 1
                                              FROM SORD_Y1 s
                                             WHERE s.Case_IDNO = a.Case_IDNO)
                                THEN
                                CASE
                                 WHEN EXISTS (SELECT 1
                                                FROM USRL_Y1 c
                                               WHERE c.Worker_ID = b.Worker_ID
                                                 AND c.Expire_DATE = @Ld_High_DATE
                                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                                 AND c.Office_IDNO = b.Office_IDNO
                                                 AND c.Role_ID = @Lc_WorkerRoleRe001_CODE)
                                  THEN @Lc_WorkerRoleRe001_CODE
                                 WHEN EXISTS (SELECT 1
                                                FROM USRL_Y1 c
                                               WHERE c.Worker_ID = b.Worker_ID
                                                 AND c.Expire_DATE = @Ld_High_DATE
                                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                                 AND c.Office_IDNO = b.Office_IDNO
                                                 AND c.Role_ID = @Lc_WorkerRoleRp004_CODE)
                                  THEN @Lc_WorkerRoleRp004_CODE
                                 ELSE @Lc_WorkerRoleRs017_CODE
                                END
                               WHEN EXISTS (SELECT 1
                                              FROM USRL_Y1 c
                                             WHERE c.Worker_ID = b.Worker_ID
                                               AND c.Expire_DATE = @Ld_High_DATE
                                               AND c.EndValidity_DATE = @Ld_High_DATE
                                               AND c.Office_IDNO = b.Office_IDNO
                                               AND c.Role_ID = @Lc_WorkerRoleRp004_CODE)
                                THEN @Lc_WorkerRoleRp004_CODE
                               ELSE @Lc_WorkerRoleRs017_CODE
                              END)
    ORDER BY CASE_IDNO;

   --Updating each Line_NUMB (1 to 63) in BSURD_Y1
   /** Line 1 : Total IV-D Cases - Cases from the CASE_Y1 table with case status set to 'Open' **/
   SET @Ls_Sql_TEXT = 'UPDATE Line1_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line1_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE TypeCase_CODE <> @Lc_TypeCaseH_CODE
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 2 : Number of MAO Cases - Cases from the CASE_Y1 table with case category of 'MO' **/
   SET @Ls_Sql_TEXT = 'UPDATE Line2_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'CaseCategory_CODE = ' + ISNULL(@Lc_CaseCategoryMo_CODE, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line2_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE CaseCategory_CODE = @Lc_CaseCategoryMo_CODE
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 3 : Number of POC Cases - Cases from the CASE_Y1 table with case category of 'PO' **/
   SET @Ls_Sql_TEXT = 'UPDATE Line3_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'CaseCategory_CODE = ' + ISNULL(@Lc_CaseCategoryPo_CODE, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line3_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE CaseCategory_CODE = @Lc_CaseCategoryPo_CODE
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 4 : Number of PFA Cases - Cases from the CASE_Y1 table with case category of 'PA' **/
   SET @Ls_Sql_TEXT = 'UPDATE Line4_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line4_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE CaseCategory_CODE IN (@Lc_CaseCategoryPa_CODE)
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 5 : Number of Non IV-D Cases ' Cases from the CASE_Y1 table with case type of 'H' **/
   SET @Ls_Sql_TEXT = 'UPDATE Line5_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseH_CODE, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line5_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE TypeCase_CODE = @Lc_TypeCaseH_CODE
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 6 : Number of Non IV-D Direct Pay Cases ' Cases from the CASE_Y1 table with case category 'DP' **/
   SET @Ls_Sql_TEXT = 'UPDATE Line6_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseH_CODE, '') + ', CaseCategory_CODE = ' + ISNULL(@Lc_CaseCategoryDp_CODE, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line6_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE TypeCase_CODE = @Lc_TypeCaseH_CODE
                           AND CaseCategory_CODE = @Lc_CaseCategoryDp_CODE
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 7 : Number of Non IV-D Cases with No Support Obligation ' Cases from the CASE_Y1 table with case category **/
   SET @Ls_Sql_TEXT = 'UPDATE Line7_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseH_CODE, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line7_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE TypeCase_CODE = @Lc_TypeCaseH_CODE
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND Case_IDNO NOT IN (SELECT Case_IDNO
                              FROM OBLE_Y1
                             WHERE EndObligation_DATE > @Ld_Run_DATE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 8 : Number of Intergovernmental Cases ' Cases from the CASE_Y1 table with values of 'I' = Initiating State, 'C' = Initiating International,
   'T' = Initiating Tribal, 'R' = Responding State, 'Y' = International, and 'S' = Responding Tribal **/
   SET @Ls_Sql_TEXT = 'UPDATE Line8_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line8_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE, @Lc_RespondInitR_CODE,
                                                    @Lc_RespondInitY_CODE, @Lc_RespondInitS_CODE)
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 9 :Number of Initiating Cases - Cases from the CASE_Y1 table with values of 'I' = Initiating State, 'C' = Initiating International, 
   'T' = Initiating Tribal**/
   SET @Ls_Sql_TEXT = 'UPDATE Line9_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line9_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE RespondInit_CODE IN (@Lc_RespondInitI_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE)
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 10: Number of Intergovernmental Cases ' Cases from the CASE_Y1 table with values of 'I' = Initiating State, 'C' = Initiating International,
    'T' = Initiating Tribal, 'R' = Responding State,'Y' =   International, and 'S' = Responding Tribal **/
   SET @Ls_Sql_TEXT = 'UPDATE Line10_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line10_NUMB = 1
    WHERE Case_IDNO IN (SELECT Case_IDNO
                          FROM CASE_Y1
                         WHERE RespondInit_CODE IN (@Lc_RespondInitR_CODE, @Lc_RespondInitY_CODE, @Lc_RespondInitS_CODE)
                           AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /*  Line 11 :Cases Not Created within 20 Days of Application Date derived from application date from the APCS_Y1 
      for which cases exist in CASE_Y1 and the date of case create is more than 20 days in advance of the application date */
   SET @Ls_Sql_TEXT = 'UPDATE Line11_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line11_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.CASE_IDNO
                          FROM APCS_Y1 a,
                               CASE_Y1 c
                         WHERE a.Application_IDNO = c.Application_IDNO
                           AND c.Application_IDNO <> 0
                           AND DATEDIFF(DD, a.Application_DATE, c.Opened_DATE) > 20
                           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND c.Opened_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE);

   /** Line 12 :Intergovernmental Referrals Received ' Cases with an incoming transaction in the CTHB_Y1 table where loDirections is 'I' 
    and the Function/Action reason combination in CTHB_Y1 table matches a row in the CFAR_Y1 table with RefAssist_CODE = 'R **/
   SET @Ls_Sql_TEXT = 'UPDATE Line12_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', IoDirection_CODE = ' + ISNULL(@Lc_IoDirectionI_CODE, '') + ', RefAssist_CODE = ' + ISNULL(@Lc_RefAssistR_CODE, '');

   UPDATE BSURD_Y1
      SET Line12_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.Case_IDNO
                          FROM CTHB_Y1 c,
                               CFAR_Y1 f
                         WHERE c.Action_CODE = f.Action_CODE
                           AND c.Reason_CODE = f.Reason_CODE
                           AND c.IoDirection_CODE = @Lc_IoDirectionI_CODE
                           AND f.RefAssist_CODE = @Lc_RefAssistR_CODE
						   AND c.Transaction_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = c.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /** Line 13 :Cases Not Created in 10 Business Days of Receipt of Referral ' Cases with an incoming transaction in the CTHB_Y1 table 
    where loDirections is 'I' and the Function/Action reason combination in CTHB_Y1 table matches a row in the CFAR_Y1 table 
    with RefAssist_CODE = 'R' and date of case create is greater than 10 business days later in the CASE_Y1 table or 10 days 
    have elapsed and no case has been created in the CASE_Y1 table **/
   SET @Ls_Sql_TEXT = 'UPDATE Line13_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', IoDirection_CODE = ' + ISNULL(@Lc_IoDirectionI_CODE, '') + ', REFASSIST_CODE = ' + ISNULL(@Lc_RefAssistR_CODE, '');

   UPDATE BSURD_Y1
      SET Line13_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT C.CASE_IDNO
                          FROM CTHB_Y1 c,
                               CASE_Y1 s,
                               CFAR_Y1 f
                         WHERE c.Case_IDNO = s.Case_IDNO
                           AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND c.Action_CODE = f.Action_CODE
                           AND c.Reason_CODE = f.Reason_CODE
                           AND c.Reason_CODE IN (@Lc_ReasonErres_CODE, @Lc_ReasonSrpat_CODE, @Lc_ReasonSrord_CODE)
                           AND c.IoDirection_CODE = @Lc_IoDirectionI_CODE
                           AND f.REFASSIST_CODE = @Lc_RefAssistR_CODE
                           AND DATEDIFF(DD, c.Transaction_DATE,s.Opened_DATE) > 10
						   AND s.Opened_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE);

   /** Line 14 :Request for Additional Information Sent to Initiating Agency ' Cases with an outgoing transaction in the CFAR_Y1 
    table during the reported month and IMCL reason is 'MSC' ' Manage state case **/
   SET @Ls_Sql_TEXT = 'UPDATE Line14_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Reason_CODE = ' + ISNULL(@Lc_ReasonAadin_CODE, '');

   UPDATE BSURD_Y1
      SET Line14_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT Case_IDNO
                          FROM CSPR_Y1 c
                         WHERE c.Case_IDNO <> 0
                           AND c.Generated_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND c.Reason_CODE = @Lc_ReasonAadin_CODE
                           AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = c.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /** Line 15 :Cases Referred to County Office ' Cases transferred from ICR to a county office in UASM_Y1 table  
    For 15, count each case that is transferred from 99 (ICR/Central) to a worker in 01, 03 or 05 during the month. **/
   SET @Ls_Sql_TEXT = 'UPDATE Line15_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', County_IDNO = ' + ISNULL(CAST(@Ln_County99_IDNO AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line15_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.CASE_IDNO
                          FROM CASE_Y1 c,
                               HCASE_Y1 h
                         WHERE c.Case_IDNO = h.Case_IDNO
                           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND h.BeginValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.County_IDNO = @Ln_County99_IDNO
                           AND c.County_IDNO IN (@Ln_County1_IDNO, @Ln_County3_IDNO, @Ln_County5_IDNO));

   /** Line 16 :Cases Where NCP is Un-Located After 60 Days of Case Creation -  Cases where case create date in CASE_Y1 is more than 60 days in the past,
   relationship to the case is NCP in CMEM_Y1 table, and NCP status is unlocated in the LSTT_Y1 table **/
   SET @Ls_Sql_TEXT = 'UPDATE Line16_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', StatusLocate_CODE = ' + ISNULL(@Lc_StatusLocatedN_CODE, '') + ', StatusLocate_CODE = ' + ISNULL(@Lc_StatusLocatedN_CODE, '');

   UPDATE BSURD_Y1
      SET Line16_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.Case_IDNO
                          FROM CASE_Y1 c,
                               CMEM_Y1 m,
                               LSTT_Y1 l
                         WHERE m.Case_IDNO = c.Case_IDNO
                           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipP_CODE)
                           AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                           AND DATEDIFF(DD, c.Opened_DATE, l.BeginValidity_DATE) > 60
                           AND m.MemberMci_IDNO = l.MemberMci_IDNO
                           AND l.StatusLocate_CODE = @Lc_StatusLocatedN_CODE
                           AND EndValidity_DATE > @Ld_Run_DATE
                           AND l.BeginValidity_DATE = (SELECT MAX(BeginValidity_DATE)
                                                         FROM LSTT_Y1 s
                                                        WHERE m.MemberMci_IDNO = s.MemberMci_IDNO
                                                          AND s.StatusLocate_CODE = @Lc_StatusLocatedN_CODE)
						   AND NOT EXISTS (SELECT 1
											 FROM SORD_Y1 s
											WHERE s.Case_IDNO = c.Case_IDNO));

   /** Line 17 : Response to Quick Locate Request Pending for More Than 60 Days ' Cases where there is a RefAssist_CODE = 'R' 
   	in the CFAR_Y1 table that was entered more than 60 days in the past **/
   SET @Ls_Sql_TEXT = 'UPDATE Line17_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Function_CODE = ' + ISNULL(@Lc_FunctionLo1_Code, '') + ', Action_CODE = ' + ISNULL(@Lc_ActionR_Code, '') + ', StatusRequest_CODE = ' + ISNULL(@Lc_StatusRequestPn_CODE, '');

   UPDATE BSURD_Y1
      SET Line17_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT Case_IDNO
                          FROM CSPR_Y1 c
                         WHERE c.Case_IDNO <> 0
                           AND c.Function_CODE = @Lc_FunctionLo1_Code
                           AND c.Action_CODE = @Lc_ActionR_Code
                           AND c.StatusRequest_CODE = @Lc_StatusRequestPn_CODE
                           AND DATEDIFF(DAY, Generated_DATE, @Ld_Run_DATE) > 60
                           AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = c.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
						   AND NOT EXISTS (SELECT 1
											 FROM SORD_Y1 s
											WHERE s.Case_IDNO = c.Case_IDNO));						                  

   /** Line 18 : Cases Where Order Exists and NCP has No Confirmed Good Mailing Address ' Cases with an open record in SORD_Y1, 
   	relationship to the case is NCP in CMEM_Y1 table, and no confirmed good address in AHIS_Y1 for address type mailing 'M' **/
   SET @Ls_Sql_TEXT = 'UPDATE Line18_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressMailing_CODE, '') + ', End_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line18_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT m.Case_IDNO
                          FROM SORD_Y1 s,
                               CMEM_Y1 m
                         WHERE m.Case_IDNO = s.Case_IDNO
                           AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipP_CODE)
                           AND s.OrderEnd_DATE > @Ld_Run_DATE
                           AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                           AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = m.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
                           AND NOT EXISTS (SELECT 1
                                             FROM AHIS_Y1 a
                                            WHERE m.MemberMci_IDNO = a.MemberMci_IDNO
                                              AND a.TypeAddress_CODE = @Lc_TypeAddressMailing_CODE
                                              AND a.Status_CODE = @Lc_StatusGood_CODE
                                              AND a.End_DATE = @Ld_High_DATE));

   /** Line 19 Cases Where Order Exists and NCP has No Confirmed Good Employer - Cases with an open record in SORD_Y1, 
   	relationship to the case is NCP in CMEM_Y1 table, and no confirmed employer in EHIS_Y1 **/
   SET @Ls_Sql_TEXT = 'UPDATE Line19_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line19_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT m.Case_IDNO
                          FROM SORD_Y1 s,
                               CMEM_Y1 m
                         WHERE m.Case_IDNO = s.Case_IDNO
                           AND m.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipP_CODE)
                           AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                           AND s.OrderEnd_DATE > @Ld_Run_DATE
                           AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = m.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
                           AND NOT EXISTS (SELECT 1
                                             FROM EHIS_Y1 e
                                            WHERE m.MemberMci_IDNO = e.MemberMci_IDNO
                                              AND e.Status_CODE = @Lc_StatusGood_CODE
                                              AND e.EndEmployment_DATE = @Ld_High_DATE));

   /**
   	Line 20 :
   	Petitions Pending DAG Approval ' Cases with an open MAPP ' Motion and Petition activity chain and 
   	the first step GNDCO ' Generate new court document has a reason code 'GP' ' Generate Petition and 
   	has an open minor activity of ADAGR ' Await DAG approval which remain open at the end of the month
   	
   	///Open MAPP major with ADAGR is open status and the dt_entered is within current month, and exists 
   		GNCDO minor completed with GP reason code for the same seq_major_int.  
   		OR 
   	Open ESTP major with ADAGR is open status and the dt_entered is within current month
   	    OR 
   	 Open ROFO major with ADROR is open status and the dt_entered is within current month   ///
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line20_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGp_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorRofo_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdror_CODE, '');

   UPDATE BSURD_Y1
      SET Line20_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.Status_CODE = @Lc_StatusStrt_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.Status_DATE = @Ld_High_DATE
                           AND ((j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                                 AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                 AND EXISTS (SELECT 1
                                               FROM DMNR_Y1 d
                                              WHERE j.Case_IDNO = d.Case_IDNO
                                                AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                                AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                                AND d.Status_CODE = @Lc_StatusComp_CODE
                                                AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                                AND d.ReasonStatus_CODE = @Lc_ReasonStatusGp_CODE))
                                 OR (j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                                     AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE)
                                 OR (j.ActivityMajor_CODE = @Lc_ActivityMajorRofo_CODE
                                     AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdror_CODE))
                           AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /**
   	Line 21 :
   	Petitions Referred to DAG  ' Cases with an open MAPP ' Motion and Petition activity chain and 
   	the first step GNDCO ' Generate new court document has a reason code 'GP' ' Generate Petition 
   	and has an open minor activity of ADAGR ' Await DAG approval which remain open at the end of the month 
   	or the ADAGR is closed with the reason code 'PJ' ' Petition approved, send to family court
   	
   	
   	///(Open MAPP major with ADAGR is open status and the dt_entered is within current month, or any (open or closed) MAPP major 
   			with ADAGR closed in the current month with reason code PJ) AND exists 
   		GNCDO minor completed with GP reason code for the same seq_major_int.  
   	 			OR 
   	  Open ESTP major with ADAGR is open status and the dt_entered is within current month, or any (open or closed) ESPT major 
   			with ADAGR closed in the current month with reason code PJ
   	    OR 
   	 Open ROFO major with ADROR is open status and the dt_entered is within current month, or any (open or closed) ROFO major 
   			with ADROR closed in the current month with reason code CD   ///
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line21_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusPj_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGp_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusPj_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorRofo_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdror_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusCd_CODE, '');

   UPDATE BSURD_Y1
      SET Line21_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE j.Status_CODE = @Lc_StatusStrt_CODE
                           AND ((j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                                 AND ((n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                       AND n.Status_CODE = @Lc_StatusStrt_CODE
                                       AND n.Entered_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE)
                                       OR EXISTS (SELECT 1
                                                    FROM DMNR_Y1 d
                                                   WHERE j.Case_IDNO = d.Case_IDNO
                                                     AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                                     AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                                     AND d.Status_CODE = @Lc_StatusComp_CODE
                                                     AND d.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                                     AND d.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                                     AND d.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE))
                                 AND EXISTS (SELECT 1
                                               FROM DMNR_Y1 d
                                              WHERE j.Case_IDNO = d.Case_IDNO
                                                AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                                AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                                AND d.Status_CODE = @Lc_StatusComp_CODE
                                                AND d.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                                AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                                AND d.ReasonStatus_CODE = @Lc_ReasonStatusGp_CODE))
                                 OR (j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                                     AND ((n.Status_CODE = @Lc_StatusStrt_CODE
                                           AND n.Entered_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                           AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE)
                                           OR EXISTS (SELECT 1
                                                        FROM DMNR_Y1 d
                                                       WHERE j.Case_IDNO = d.Case_IDNO
                                                         AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                                         AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                                         AND d.Status_CODE = @Lc_StatusComp_CODE
                                                         AND d.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                                         AND d.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                                         AND d.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE)))
                                 OR (j.ActivityMajor_CODE = @Lc_ActivityMajorRofo_CODE
                                     AND ((n.Status_CODE = @Lc_StatusStrt_CODE
                                           AND n.Entered_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                           AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE)
                                           OR EXISTS (SELECT 1
                                                        FROM DMNR_Y1 d
                                                       WHERE j.Case_IDNO = d.Case_IDNO
                                                         AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                                         AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                                         AND d.Status_CODE = @Lc_StatusComp_CODE
                                                         AND d.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                                         AND d.ActivityMinor_CODE = @Lc_ActivityMinorAdror_CODE
                                                         AND d.ReasonStatus_CODE = @Lc_ReasonStatusCd_CODE))))
                           AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /**
   	Line 22 :
   	Petitions Rejected by DAG ' Cases with a MAPP ' Motion and Petition activity chain and the first step 
   	GNDCO ' Generate new court document has a reason code 'GP' ' Generate Petition is completed with a 
   	reason code 'DW' - Sent to worker for resubmission
   	
   	///Any (open or closed) MAPP major with ADAGR closed in the current month with reason code DW AND exists 
   		GNCDO minor completed with GP reason code for the same seq_major_int.  
   	 			OR 
   	   Any (open or closed) ESPT major with ADAGR closed in the current month with reason code PL
   	    OR 
   	 Any (open or closed) ROFO major with ADROR closed in the current month with reason code CM   ///
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line22_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusDw_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGp_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusPl_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorRofo_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdror_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusCm_CODE, '');

   UPDATE BSURD_Y1
      SET Line22_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND ((j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                                 AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusDw_CODE
                                 AND EXISTS (SELECT 1
                                               FROM DMNR_Y1 d
                                              WHERE j.Case_IDNO = d.Case_IDNO
                                                AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                                AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                                AND d.Status_CODE = @Lc_StatusComp_CODE
                                                AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                                AND d.ReasonStatus_CODE = @Lc_ReasonStatusGp_CODE))
                                 OR (j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                                     AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                     AND n.ReasonStatus_CODE = @Lc_ReasonStatusPl_CODE)
                                 OR (j.ActivityMajor_CODE = @Lc_ActivityMajorRofo_CODE
                                     AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdror_CODE
                                     AND n.ReasonStatus_CODE = @Lc_ReasonStatusCm_CODE))
                           AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /**
   	Line 23 :
   	Motions Pending DAG Approval – Cases with an open MAPP – Motion and Petition activity chain and the first step 
   	GNCDO – Generate new court document has a reason code ‘GM’ – Generate Motion and has an open minor activity of ADAGR – Await DAG approval 
   	which remains open at the end of the month
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line23_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGm_CODE, '');

   UPDATE BSURD_Y1
      SET Line23_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                           AND n.Status_CODE = @Lc_StatusStrt_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.Status_DATE = @Ld_High_DATE
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE j.Case_IDNO = d.Case_IDNO
                                          AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                          AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusGm_CODE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                          

   /**
   	Line 24 :
   	Motions Referred to DAG - Cases with an open MAPP – Motion and Petition activity chain and the first step 
   	GNCDO – Generate new court document has a reason code ‘GM’ – Generate Motion and has an open minor activity of ADAGR – Await DAG approval 
   	which remains open at the end of the month or the ADAGR is closed with the reason code ‘MS’ – Motion approved
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line24_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusMs_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGm_CODE, '');

   UPDATE BSURD_Y1
      SET Line24_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                           AND (n.Status_CODE = @Lc_StatusStrt_CODE
                                AND n.Entered_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                 OR (n.Status_CODE = @Lc_StatusComp_CODE
                                     AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                     AND n.ReasonStatus_CODE = @Lc_ReasonStatusMs_CODE))
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE j.Case_IDNO = d.Case_IDNO
                                          AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                          AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusGm_CODE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /**
   	Line 25 :
   	Motions Rejected by DAG - Cases with an open MAPP ' Motion and Petition activity chain and the first step 
   	GNDCO ' Generate new court document has a reason code 'GM' ' Generate Motion is completed with a 
   	reason code 'DW' - Sent to worker for resubmission
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line25_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusDw_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGm_CODE, '');

   UPDATE BSURD_Y1
      SET Line25_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE 
                           AND n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ReasonStatus_CODE = @Lc_ReasonStatusDw_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE j.Case_IDNO = d.Case_IDNO
                                          AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                          AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusGm_CODE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                          

   /**
   	Line 26 :
   	NOAAs Pending DAG Approval - Cases with an open MAPP ' Motion and Petition activity chain and the first step 
   	GNDCO ' Generate new court document has a reason code 'GO' ' Generate NOAA and has an open minor activity of 
   	ADAGR ' Awaiting DAG approval which remains open at the end of the month
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line26_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGo_CODE, '');

   UPDATE BSURD_Y1
      SET Line26_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                           AND n.Status_CODE = @Lc_StatusStrt_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.Status_DATE = @Ld_High_DATE
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE j.Case_IDNO = d.Case_IDNO
                                          AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                          AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusGo_CODE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                             

   /**
   	Line 27 :
   	NOAAs Referred to DAG - Cases with an open MAPP ' Motion and Petition activity chain and the first step 
   	GNDCO ' Generate new court document has a reason code 'GO' ' Generate NOAA and has an open minor activity of 
   	ADAGR ' Awaiting DAG approval which remains open at the end of the month or is completed with a reason code 'NA' ' NOAA approved
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line27_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusNa_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGo_CODE, '');

   UPDATE BSURD_Y1
      SET Line27_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                           AND (n.Status_CODE = @Lc_StatusStrt_CODE
                                AND n.Entered_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                 OR (n.Status_CODE = @Lc_StatusComp_CODE
                                     AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                     AND n.ReasonStatus_CODE = @Lc_ReasonStatusNa_CODE))
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE j.Case_IDNO = d.Case_IDNO
                                          AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                          AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusGo_CODE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                                                                       

   /**
   	Line 28 :
   NOAAs Rejected by DAG - Cases with an open MAPP – Motion and Petition activity chain and the first step 
   GNCDO – Generate new court document has a reason code ‘GO’ – Generate NOAA is completed  and the ADAGR – Await DAG review is completed 
   with a reason code ‘DW’ - Sent to worker for resubmission
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line28_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAdagr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusDw_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorMapp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGncdo_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusGo_CODE, '');

   UPDATE BSURD_Y1
      SET Line28_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                           AND n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ReasonStatus_CODE = @Lc_ReasonStatusDw_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE j.Case_IDNO = d.Case_IDNO
                                          AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                          AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorGncdo_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusGo_CODE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                             
   /**
   	Line 29 :
   	Petitions Pending Service ' Cases with an open ESTP - Establishment activity chain where minor activity 
   	ASERR ' Await service results remains open at the end of the month
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line29_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAserr_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '');

   UPDATE BSURD_Y1
      SET Line29_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.ActivityMinor_CODE = @Lc_ActivityMinorAserr_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.Status_DATE = @Ld_High_DATE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                                                        

   /**
   	Line 30 :
   	Petitions with Hearing Scheduled ' Cases with an open ESTP ' Establishment activity chain where the minor activity 
   	ASCHD ' Await scheduling details is completed with any reason code except 'SD' ' Scheduling details not received
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line30_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAschd_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusSd_CODE, '');

   UPDATE BSURD_Y1
      SET Line30_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ActivityMinor_CODE = @Lc_ActivityMinorAschd_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                           AND n.ReasonStatus_CODE <> @Lc_ReasonStatusSd_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                             
   /**
   	Line 31 :
   	Cases with Genetic Testing Scheduled ' Cases with an open GTST ' Genetic Test activity chain where the minor activity 
   	AGTSC ' Await genetic test to be scheduled is completed with the reason code 'SE' ' Schedule genetic test
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line31_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAgtsc_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorGtst_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusSe_CODE, '');

   UPDATE BSURD_Y1
      SET Line31_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ActivityMinor_CODE = @Lc_ActivityMinorAgtsc_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorGtst_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.ReasonStatus_CODE = @Lc_ReasonStatusSe_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                             
   /**
   Line 32 : 
   Cases with Petitions Filed -  Establishment – Cases with ESTP Establishment chain with ADAGR minor activity completed with PJ reason code 
   anytime during the month or ROFO Registration of Foreign Order chain with ADROR minor completed with CD reason code anytime during the month.
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line32_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAgtsc_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorGtst_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusSe_CODE, '');

   UPDATE BSURD_Y1
      SET Line32_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND ((n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                 AND j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                                 AND n.ReasonStatus_CODE = @Lc_ReasonStatusPj_CODE)
                                 OR (n.ActivityMinor_CODE = @Lc_ActivityMinorAdror_CODE
                                     AND j.ActivityMajor_CODE = @Lc_ActivityMajorRofo_CODE
                                     AND n.ReasonStatus_CODE = @Lc_ReasonStatusCd_CODE))
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                       

   /**
   	Line 33 :
   	Orders Established within 90 Days of Service ' Cases with an ESTP ' Establishment activity chain with a 
   	completed minor activity of ASERR ' Await service initiation and has an order established date in SORD_Y1 
   	within 90 or less days of the ASERR completion date
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line33_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAserr_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '');

   UPDATE BSURD_Y1
      SET Line33_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                               JOIN SORD_Y1 s
                                ON s.Case_IDNO = n.Case_IDNO
                         WHERE n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ActivityMinor_CODE = @Lc_ActivityMinorAserr_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                           AND s.OrderEffective_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND DATEDIFF(DAY, n.Status_DATE, s.OrderIssued_DATE) <= 90
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                             

   /**
   	Line 34 :
   	Orders Not Established within 90 Days of Service - Cases with an ESTP ' Establishment activity chain with a 
   	completed minor activity of ASERR ' Await service initiation and has an order established date in SORD_Y1 
   	greater than 90 of the ASERR completion date or case has yet to be established as of the end of the month 
   	and more than 90 days have elapsed since the ASERR completion date
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line34_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAserr_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '');

   UPDATE BSURD_Y1
      SET Line34_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                               LEFT JOIN SORD_Y1 s
                                ON s.Case_IDNO = n.Case_IDNO
                         WHERE n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ActivityMinor_CODE = @Lc_ActivityMinorAserr_CODE
						   AND n.ReasonStatus_CODE = @Lc_ReasonStatusSc_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                           AND ISNULL(s.OrderEffective_DATE, @Ld_Run_DATE) BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND DATEDIFF(DAY, n.Status_DATE, ISNULL(s.OrderIssued_DATE, @Ld_Run_DATE)) > 90
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                             

   /**
   	Line 35 :
   	Cases Where Paternity is Established by Court Order ' Cases with and ESTP ' Establishment activity chain 
   	with the minor activity PETDE ' Paternity Determination is completed with a reason code 
   	'PG' ' Petition for Parentage Determination and minor activity AORDD ' Await order details is completed 
   	with a reason code 'CI' ' Court order received with final disposition
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line35_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAordd_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusPg_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorPetde_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusCi_CODE, '');

   UPDATE BSURD_Y1
      SET Line35_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.ActivityMinor_CODE = @Lc_ActivityMinorAordd_CODE
                           AND n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ReasonStatus_CODE = @Lc_ReasonStatusCi_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE j.Case_IDNO = d.Case_IDNO
                                          AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                          AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorPetde_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusPg_CODE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                            

   /**
   	Line 36 :
   	Cases Where Paternity is Dis-Established by Court Order ' Cases with and ESTP ' Establishment activity chain 
   	with the minor activity PETDE ' Paternity Determination is completed with a reason code 
   	'PG' ' Petition for Parentage Determination and minor activity AORDD ' Await order details is completed 
   	with a reason code 'CI' ' Court order received with final disposition and check MPAT_Y1 for the dependant 
   	having a Disestablished date equal to or later than the 'CI' date
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line36_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorAordd_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusPg_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorEstp_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorPetde_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusCi_CODE, '');

   UPDATE BSURD_Y1
      SET Line36_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                               JOIN CMEM_Y1 c
                                ON c.Case_IDNO = n.Case_IDNO
                               JOIN MPAT_Y1 m
                                ON m.MemberMci_IDNO = c.MemberMci_IDNO
                         WHERE n.ActivityMinor_CODE = @Lc_ActivityMinorAordd_CODE
                           AND n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ReasonStatus_CODE = @Lc_ReasonStatusCi_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE j.Case_IDNO = d.Case_IDNO
                                          AND j.OrderSeq_NUMB = d.OrderSeq_NUMB
                                          AND j.MajorIntSeq_NUMB = d.MajorIntSeq_NUMB
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorPetde_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusPg_CODE)
                           AND m.Disestablish_DATE <= n.Status_DATE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                           

   /**
   	Line 37
   	Cases with New Support Ordered ' Cases with an initial record in the SORD_Y1 table during the current month
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line37_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line37_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT s.Case_IDNO
                          FROM SORD_Y1 s
                         WHERE s.OrderEffective_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND NOT EXISTS (SELECT 1
                                             FROM SORD_Y1 c
                                            WHERE c.Case_IDNO = s.Case_IDNO
                                              AND c.OrderEffective_DATE < @Ld_ReportingMonthFrom_DATE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = s.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                              

   /**
   	Line 38
   	Cases with Medical Support Ordered ' Cases with an initial record in the SORD_Y1 table during the current month 
   	and medical support is not equal to 'N'
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line38_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line38_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT s.Case_IDNO
                          FROM SORD_Y1 s
                         WHERE s.OrderEffective_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND s.InsOrdered_CODE <> @Lc_MedicalOnlyN_INDC
                           AND NOT EXISTS (SELECT 1
                                             FROM SORD_Y1 c
                                            WHERE c.Case_IDNO = s.Case_IDNO
                                              AND c.OrderEffective_DATE < @Ld_ReportingMonthFrom_DATE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = s.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                                

   /**
   	Line 39
   	Cases with Payment On Arrears Ordered ' Cases with an initial record in the SORD_Y1 during the current month and a record 
   	has been added in OBLE_Y1 with an amount expected to pay greater than 0
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line39_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line39_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT s.Case_IDNO
                          FROM SORD_Y1 s
                         WHERE s.OrderEffective_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND NOT EXISTS (SELECT 1
                                             FROM SORD_Y1 c
                                            WHERE c.Case_IDNO = s.Case_IDNO
                                              AND c.OrderEffective_DATE < @Ld_ReportingMonthFrom_DATE)
                           AND EXISTS (SELECT 1
                                         FROM OBLE_Y1 o
                                        WHERE o.Case_IDNO = s.Case_IDNO
                                          AND o.OrderSeq_NUMB = s.OrderSeq_NUMB
                                          AND o.ExpectToPay_AMNT > 0
                                          AND o.BeginObligation_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE)
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = s.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                                            

   /**
   	Line 40 :
   	Foreign Support Orders Registered in Delaware ' Cases with a ROFO ' Registration of a Foreign Order activity chain with the 
   	minor activity FAMUP ' Await FAMIS update is closed with the reason code 'RP' - Court order received with final disposition
   	' Confirmation of Registered Order
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line40_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorFamup_CODE, '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorRofo_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusRp_CODE, '');

   UPDATE BSURD_Y1
      SET Line40_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT n.Case_IDNO
                          FROM DMNR_Y1 n
                               JOIN DMJR_Y1 j
                                ON n.Case_IDNO = j.Case_IDNO
                                   AND n.OrderSeq_NUMB = j.OrderSeq_NUMB
                                   AND n.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
                         WHERE n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.ActivityMinor_CODE = @Lc_ActivityMinorFamup_CODE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorRofo_CODE
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.ReasonStatus_CODE = @Lc_ReasonStatusRp_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                             

   /** Line 41:	
   	Cases Changed from Non PA to PA ' Cases where last update date in CASE_Y1 is  'A' ' Case type PA .
   	and is in the current month and most recent history record in HCASE_Y1 is 'N' ' Case type Non PA
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line41_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseA_CODE, '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseN_CODE, '');

   UPDATE BSURD_Y1
      SET Line41_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.Case_IDNO
                          FROM CASE_Y1 c,
                               HCASE_Y1 h
                         WHERE c.Case_IDNO = h.Case_IDNO
                           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND c.BeginValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.EndValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                               FROM HCASE_Y1 a
                                                              WHERE a.Case_IDNO = h.Case_IDNO
                                                                AND a.TypeCase_CODE <> @Lc_TypeCaseA_CODE)
                           AND c.TypeCase_CODE = @Lc_TypeCaseA_CODE
                           AND h.TypeCase_CODE = @Lc_TypeCaseN_CODE);

   /** Line 42:
    Cases Changed from Non IV-D to Non PA ' Cases where last update date in CASE_Y1 is 'N' ' 
    Case type Non PA and is in the current month and most recent history record in HCASE_Y1 is 'H' ' Case type Non IV-D
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line42_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseN_CODE, '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseH_CODE, '');

   UPDATE BSURD_Y1
      SET Line42_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.Case_IDNO
                          FROM CASE_Y1 c,
                               HCASE_Y1 h
                         WHERE c.Case_IDNO = h.Case_IDNO
                           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND c.BeginValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.EndValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                               FROM HCASE_Y1 a
                                                              WHERE a.Case_IDNO = h.Case_IDNO
                                                                AND a.TypeCase_CODE <> @Lc_TypeCaseN_CODE)
                           AND c.TypeCase_CODE = @Lc_TypeCaseN_CODE
                           AND h.TypeCase_CODE = @Lc_TypeCaseH_CODE);

   /** Line 43:
    Cases Changed from Non IV-D to PA ' Cases where last update date in CASE_Y1 is  'A' ' 
    Case type PA and is in the current month and most recent history record in HCASE_Y1 is 'H' ' Case type Non IV-D
    **/
   SET @Ls_Sql_TEXT = 'UPDATE Line43_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseA_CODE, '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseH_CODE, '');

   UPDATE BSURD_Y1
      SET Line43_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.Case_IDNO
                          FROM CASE_Y1 c,
                               HCASE_Y1 h
                         WHERE c.Case_IDNO = h.Case_IDNO
                           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND c.BeginValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.EndValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                               FROM HCASE_Y1 a
                                                              WHERE a.Case_IDNO = h.Case_IDNO
                                                                AND a.TypeCase_CODE <> @Lc_TypeCaseA_CODE)
                           AND c.TypeCase_CODE = @Lc_TypeCaseA_CODE
                           AND h.TypeCase_CODE = @Lc_TypeCaseH_CODE);

   /** Line 44:
   Cases Changed from PA to Non PA ' Cases where last update date in CASE_Y1 is 'N' ' 
   Case type Non PA and is in the current month and most recent history record in HCASE_Y1 is 'A' ' Case type PA
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line44_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseN_CODE, '') + ', TypeCase_CODE = ' + ISNULL(@Lc_TypeCaseA_CODE, '');

   UPDATE BSURD_Y1
      SET Line44_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.Case_IDNO
                          FROM CASE_Y1 c,
                               HCASE_Y1 h
                         WHERE c.Case_IDNO = h.Case_IDNO
                           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND c.BeginValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.EndValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND h.TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                               FROM HCASE_Y1 a
                                                              WHERE a.Case_IDNO = h.Case_IDNO
                                                                AND a.TypeCase_CODE <> @Lc_TypeCaseN_CODE)
                           AND c.TypeCase_CODE = @Lc_TypeCaseN_CODE
                           AND h.TypeCase_CODE = @Lc_TypeCaseA_CODE);

   /**
   	Line : 45
   	Support Order Review Requested ' Cases with an OBRA ' Obligation Review and Adjustment activity chain is opened during the reported month
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line45_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorObra_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '');

   UPDATE BSURD_Y1
      SET Line45_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT Case_IDNO
                          FROM DMNR_Y1 n
                         WHERE n.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
                           AND n.Entered_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND n.Status_CODE = @Lc_StatusStrt_CODE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = n.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                             

   /**
   	Line : 46
   	Support Order Review Completed ' Cases with an OBRA ' Obligation Review and Adjustment activity chain is closed 
   	with any reason code(expect AE reason code) during the reported month 
   	or [Status_CODE = 'COMP',Major = 'OBRA', Reason code = 'AE', Minor code = 'WTRPA' and Major = 'MAPP', CLOSED.
   	This opens the MAPP activity chain based on an OBRA referral.  Any MAPP activity chains that are opened at any time based on an 
   	OBRA referral and closed for any reason during the month
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line46_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorObra_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '');

   UPDATE BSURD_Y1
      SET Line46_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND (Case_IDNO IN (SELECT Case_IDNO
                          FROM DMNR_Y1 a
                         WHERE a.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
                           AND a.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND a.Status_CODE = @Lc_StatusComp_CODE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = a.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)                           
                           AND EXISTS (SELECT 1 
										 FROM DMJR_Y1 c
										WHERE a.Case_IDNO = c.Case_IDNO
										  AND c.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
										  AND c.Status_CODE = @Lc_StatusComp_CODE
										  AND c.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE)
                           AND ((a.ReasonStatus_CODE <> @Lc_ReasonStatusAe_CODE
                                AND a.ActivityMinor_CODE = @Lc_ActivityMinorWtrpa_CODE)
                                OR (a.ReasonStatus_CODE = @Lc_ReasonStatusAe_CODE
                                AND a.ActivityMinor_CODE <> @Lc_ActivityMinorWtrpa_CODE)))          
			OR Case_IDNO IN (SELECT Case_IDNO
                               FROM DMJR_Y1 a
                              WHERE a.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                                AND a.TypeReference_CODE = @Lc_ActivityMajorObra_CODE
                                AND a.Status_CODE = @Lc_StatusComp_CODE
							    AND a.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
						        AND EXISTS (SELECT 1 
											  FROM CASE_Y1 d
											 WHERE d.Case_IDNO = a.Case_IDNO
											   AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)  							    
							    AND EXISTS (SELECT 1 
											  FROM DMJR_Y1 c
											 WHERE c.Case_IDNO = a.Case_IDNO
											   AND c.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
											   AND c.Status_CODE = @Lc_StatusComp_CODE)));

   /**
   	Line 47
   	Order Modified Completed ' Cases with an OBRA ' Obligation Review and Adjustment activity chain and the 
   	minor activity WTRPA ' Worker to review for possible adjustment is completed with the reason code 'AE' ' Adjusted to be pursued
   	This opens the MAPP activity chain based on an OBRA referral.  Any MAPP Activity chains that are opened at any time based on an OBRA referral 
   	and closed during the month at the step of FAMUP – Await FAMIS Update with the reason ‘CI’ – Court Order received with Final Disposition 
   	and there is a modified OBLE record for the case 
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line47_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorObra_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorWtrpa_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusAe_CODE, '');

   UPDATE BSURD_Y1
      SET Line47_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT Case_IDNO
                          FROM DMNR_Y1 a
                         WHERE a.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
                           AND a.Status_CODE = @Lc_StatusComp_CODE
                           AND a.ActivityMinor_CODE = @Lc_ActivityMinorWtrpa_CODE
                           AND a.ReasonStatus_CODE = @Lc_ReasonStatusAe_CODE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = a.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)                           
                           AND EXISTS (SELECT 1 
										 FROM DMJR_Y1 c
										WHERE a.Case_IDNO = c.Case_IDNO
										  AND c.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
										  AND c.Status_CODE = @Lc_StatusComp_CODE)
                           AND EXISTS (SELECT 1 
										 FROM DMJR_Y1 e
										WHERE a.Case_IDNO = e.Case_IDNO
										  AND e.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
										  AND e.TypeReference_CODE = @Lc_ActivityMajorObra_CODE
										  AND e.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
										  AND e.Status_CODE = @Lc_StatusComp_CODE)										  
                           AND EXISTS (SELECT 1
                                         FROM DMNR_Y1 d
                                        WHERE d.Case_IDNO = a.Case_IDNO
                                          AND d.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                                          AND d.ActivityMinor_CODE = @Lc_ActivityMinorFamup_CODE
                                          AND d.ReasonStatus_CODE = @Lc_ReasonStatusCi_CODE
                                          AND d.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                          AND d.Status_CODE = @Lc_StatusComp_CODE
                                          AND EXISTS (SELECT 1
                                                        FROM OBLE_Y1 c
                                                       WHERE c.Case_IDNO = d.Case_IDNO
                                                         AND c.BeginValidity_DATE >= a.Status_DATE
                                                         AND c.ReasonChange_CODE = @Lc_ReasonChangeOm_CODE)));

   /**
   	Line 48 :
   	Order Not Modified ' Cases with an OBRA ' Obligation Review and Adjustment activity chain and the 
   	minor activity WTRPA ' Worker to review for possible adjustment is completed with the reason code 'AF' - Adjustment not pursued 
   	' Case does not meet criteria for adjustment or minor activity MONLS ' Monitor NCP locate status is closed with the 
   	reason code 'UN' ' NCP unlocated ' Adjustment not pursued 
   	or if the minor activity WTRPA is closed with reason code ‘AE’ Adjustment to be pursued, the MAPP activity chain opens based on an OBRA referral.  
   	Any MAPP activity chains that are opened at any time based on an OBRA referral and closed during the month at the step of 
   	FAMUP – Await FAMIS Update with the reason ‘CI’ – Court Order received with Final Disposition and there is no modified OBLE record for the case 
   	or the MAPP activity chain is closed at the step WRDRS – Worker to Review Document for Resubmission with the reason ‘CH’ – Cancel Petition/Motion
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line48_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorObra_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorWtrpa_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusAf_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorMonls_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusUn_CODE, '');

   UPDATE BSURD_Y1
      SET Line48_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND (Case_IDNO IN (SELECT Case_IDNO
                           FROM DMNR_Y1 a
                          WHERE a.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
                            AND a.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                            AND a.Status_CODE = @Lc_StatusComp_CODE
						    AND EXISTS (SELECT 1 
						                  FROM CASE_Y1 d
						                 WHERE d.Case_IDNO = a.Case_IDNO
						                   AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)                              
                            AND ((a.ActivityMinor_CODE = @Lc_ActivityMinorWtrpa_CODE
                                  AND a.ReasonStatus_CODE = @Lc_ReasonStatusAf_CODE)
                                  OR (a.ActivityMinor_CODE = @Lc_ActivityMinorMonls_CODE
                                      AND a.ReasonStatus_CODE = @Lc_ReasonStatusUn_CODE))
							AND EXISTS (SELECT 1 
										  FROM DMJR_Y1 c
										 WHERE a.Case_IDNO = c.Case_IDNO
										   AND c.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
										   AND c.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
										   AND c.Status_CODE = @Lc_StatusComp_CODE)))
       OR (Case_IDNO IN (SELECT Case_IDNO
                           FROM DMJR_Y1 a
                          WHERE a.ActivityMajor_CODE = @Lc_ActivityMajorObra_CODE
                            AND a.Status_CODE = @Lc_StatusComp_CODE
						    AND EXISTS (SELECT 1 
						                  FROM CASE_Y1 d
						                 WHERE d.Case_IDNO = a.Case_IDNO
						                   AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)                              
                            AND EXISTS (SELECT 1
										  FROM DMJR_Y1 d
										 WHERE d.Case_IDNO = a.Case_IDNO
										   AND d.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
										   AND d.TypeReference_CODE = @Lc_ActivityMajorObra_CODE
										   AND d.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
										   AND d.Status_CODE = @Lc_StatusComp_CODE)
                            AND (EXISTS(SELECT 1
                                          FROM DMNR_Y1 b
                                         WHERE b.Case_IDNO = a.Case_IDNO
                                           AND b.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                                           AND b.ActivityMinor_CODE = @Lc_ActivityMinorFamup_CODE
                                           AND b.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                           AND b.ReasonStatus_CODE = @Lc_ReasonStatusCi_CODE
                                           AND NOT EXISTS (SELECT 1
															 FROM OBLE_Y1 c
														    WHERE c.Case_IDNO = b.Case_IDNO
															  AND c.BeginValidity_DATE >= a.Status_DATE
															  AND c.ReasonChange_CODE = @Lc_ReasonChangeOm_CODE)))
                                  OR (EXISTS(SELECT 1
                                               FROM DMNR_Y1 b
                                              WHERE b.Case_IDNO = a.Case_IDNO
                                                AND b.ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE
                                                AND b.ActivityMinor_CODE = @Lc_ActivityMinorWrdrs_CODE
                                                AND b.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                                                AND b.ReasonStatus_CODE = @Lc_ReasonStatusBi_CODE))));

   /**
   	Line 49 :
   	Cases Closed within Last 30 Days ' Cases with a CCLO ' Case Closure activity chain with the 
   	minor activity FCPRO ' Final closure procedures completed with the reason code 'YA' ' All case activities closed 
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line49_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCclo_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorFcpro_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusYa_CODE, '');

   UPDATE BSURD_Y1
      SET Line49_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT Case_IDNO
                          FROM DMNR_Y1 a
                         WHERE a.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                           AND a.ActivityMinor_CODE = @Lc_ActivityMinorFcpro_CODE
                           AND a.Status_CODE = @Lc_StatusComp_CODE
                           AND a.ReasonStatus_CODE = @Lc_ReasonStatusYa_CODE
                           AND a.Status_DATE BETWEEN DATEADD(DD, -30, @Ld_Run_DATE) AND @Ld_Run_DATE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = a.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseClose_CODE));

   /**
   	Line 50 :
   	Cases with Petition Filed ' Enforcement ' Cases with an open MAPP ' Motion and Petition activity chain with 
   	minor activity PETDE ' Petition determination completed with the reason code 'PS' ' Petition ' rule to Show Cause
   **/
   SET @Ls_Sql_TEXT = 'UPDATE Line50_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusStrt_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusComp_CODE, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatusPs_CODE, '');

   UPDATE BSURD_Y1
      SET Line50_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT j.Case_IDNO
                          FROM DMJR_Y1 j,
                               DMNR_Y1 N
                         WHERE j.Case_IDNO = N.Case_IDNO
                           AND j.Status_CODE = @Lc_StatusStrt_CODE
                           AND n.Status_CODE = @Lc_StatusComp_CODE
                           AND n.Status_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND n.ReasonStatus_CODE = @Lc_ReasonStatusPs_CODE
						    AND EXISTS (SELECT 1 
						                  FROM CASE_Y1 d
						                 WHERE d.Case_IDNO = n.Case_IDNO
						                   AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /** Line 51 : Cases Paying 75 - 100% of Current Support Amount ' Cases with an entry in the Current Support column of LSUP_Y1 table 
   				 with total paid for current support at least 75% of amount ordered from OBLE_Y1 table **/
   SET @Ls_Sql_TEXT = 'UPDATE Line51_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordO_CODE, '');

   UPDATE BSURD_Y1
      SET Line51_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT Case_IDNO
                          FROM LSUP_Y1 l
                         WHERE l.MtdCurSupOwed_AMNT > 0
                           AND l.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
                           AND l.EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB)
                           AND l.TypeRecord_CODE = @Lc_TypeRecordO_CODE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = l.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
                         GROUP BY Case_IDNO
                        HAVING SUM(TransactionCurSup_AMNT) / (SELECT SUM (MtdCurSupOwed_AMNT)
																FROM (SELECT MAX(MtdCurSupOwed_AMNT) MtdCurSupOwed_AMNT
																	   FROM LSUP_Y1 a
																	  WHERE a.CASE_IDNO = l.CASE_IDNO
																	    AND a.MtdCurSupOwed_AMNT > 0 
																		AND a.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB 
																		AND a.EventFunctionalSeq_NUMB = @Li_ReceiptDistributed1820_NUMB
																		AND a.TypeRecord_CODE = @Lc_TypeRecordO_CODE
																   GROUP BY a.ObligationSeq_NUMB) b) >= 0.75);

   /** Line 52 : Cases Paying Less Than 75% of Current Support Amount ' Cases with no entry or an entry in the Current Support column of LSUP_Y1 table 
				 with total paid for current support lower than 75% of amount ordered from OBLE_Y1 table **/
   SET @Ls_Sql_TEXT = 'UPDATE Line52_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordO_CODE, '') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line52_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT Case_IDNO
                          FROM LSUP_Y1 l
                         WHERE MtdCurSupOwed_AMNT > 0
                           AND SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
                           AND EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB)
                           AND TypeRecord_CODE = @Lc_TypeRecordO_CODE
						   AND EXISTS (SELECT 1 
						                 FROM CASE_Y1 d
						                WHERE d.Case_IDNO = l.Case_IDNO
						                  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)                           
                         GROUP BY Case_IDNO
                         HAVING SUM(TransactionCurSup_AMNT)/(SELECT SUM (MtdCurSupOwed_AMNT)
																FROM (SELECT MAX(MtdCurSupOwed_AMNT) MtdCurSupOwed_AMNT
																	   FROM LSUP_Y1 a
																	  WHERE a.CASE_IDNO = l.CASE_IDNO
																	    AND a.MtdCurSupOwed_AMNT > 0 
																		AND a.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB 
																		AND a.EventFunctionalSeq_NUMB = @Li_ReceiptDistributed1820_NUMB
																		AND a.TypeRecord_CODE = @Lc_TypeRecordO_CODE
																   GROUP BY a.ObligationSeq_NUMB) b) < 0.75);

   /** Line 53 : Amount Paid Towards Arrears Owed to the CP ' Cases with an entry in the NAA Arrears column in LSUP_Y1 
    and Check Recipient CODE column has '1' ' Owed to CP, add the NAA Transaction amount to the total for this line **/
   SET @Ls_Sql_TEXT = 'UPDATE Line53_AMNT IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line53_AMNT = a.SumTransactionNaa_AMNT
     FROM (SELECT l.Case_IDNO,
                  SUM( CASE WHEN TypeWelfare_CODE = @Lc_TypeCaseN_CODE 
							THEN (l.TransactionNaa_AMNT - l.TransactionCurSup_AMNT)
                            ELSE l.TransactionNaa_AMNT 
                       END) AS SumTransactionNaa_AMNT     
             FROM LSUP_Y1 l
            WHERE l.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
              AND l.TransactionNaa_AMNT > 0
              AND l.TransactionExptPay_AMNT > 0
              AND l.CheckRecipient_CODE = @Lc_CheckRecipient1_CODE
              AND EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB)
              AND TypeRecord_CODE = @Lc_TypeRecordO_CODE
			  AND EXISTS (SELECT 1 
			                FROM CASE_Y1 d
			               WHERE d.Case_IDNO = l.Case_IDNO
			                 AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
            GROUP BY l.Case_IDNO) a
    WHERE a.Case_IDNO = BSURD_Y1.Case_IDNO
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /**  Line 54 :Amount Paid Towards Arrears Owed T to the State IV-A - Cases with an entry in the PAA Arrears column in LSUP_Y1,
   Check Recipient CODE has '3' ' Owed to State with a recipient ID = to IV-A, add the PAA Transaction amount to the total for this line **/
   SET @Ls_Sql_TEXT = 'UPDATE Line54_AMNT IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line54_AMNT = a.SumTransactionPaa_AMNT
     FROM (SELECT l.Case_IDNO,
                  SUM( CASE WHEN TypeWelfare_CODE = @Lc_TypeCaseA_CODE 
							THEN  (l.TransactionPaa_AMNT - l.TransactionCurSup_AMNT)
                            ELSE l.TransactionPaa_AMNT 
                       END) AS SumTransactionPaa_AMNT
             FROM LSUP_Y1 l
            WHERE l.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
              AND l.TransactionPaa_AMNT > 0
              AND l.TransactionExptPay_AMNT > 0
              AND l.EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB)
              AND l.TypeRecord_CODE = @Lc_TypeRecordO_CODE
			  AND EXISTS (SELECT 1 
							FROM LWEL_Y1 w 
						   WHERE w.CASE_IDNO = L.CASE_IDNO 
						     AND l.SupportYearMonth_NUMB = w.WelfareYearMonth_NUMB
							 AND w.Distribute_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
							 AND w.SourceBatch_CODE = l.SourceBatch_CODE 
							 AND w.Batch_NUMB = l.Batch_NUMB
							 AND w.SeqReceipt_NUMB = l.SeqReceipt_NUMB)
			  AND EXISTS (SELECT 1 
							FROM DSBL_Y1 w 
						   WHERE w.CASE_IDNO = L.CASE_IDNO AND CheckRecipient_CODE = @Lc_CheckRecipient3_CODE
							 AND w.Disburse_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
							 AND w.SourceBatch_CODE = l.SourceBatch_CODE 
							 AND w.Batch_NUMB = l.Batch_NUMB
							 AND w.SeqReceipt_NUMB = l.SeqReceipt_NUMB)              
			  AND EXISTS (SELECT 1 
			                FROM CASE_Y1 d
			               WHERE d.Case_IDNO = l.Case_IDNO
			                 AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
            GROUP BY l.Case_IDNO) a
    WHERE a.Case_IDNO = BSURD_Y1.Case_IDNO
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /**  Line 55 : Amount Paid Towards Arrears Owed to the State IV-E - Cases with an entry in the IVEF Arrears column in LSUP_Y1,
   Check Recipient CODE has '3' ' Owed to State with a recipient ID = to IV-E, add the IVEF Transaction amount to the total for this line**/
   SET @Ls_Sql_TEXT = 'UPDATE Line55_AMNT IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line55_AMNT = a.SumTransactionIvef_AMNT
     FROM (SELECT l.Case_IDNO,
                  SUM( CASE WHEN TypeWelfare_CODE = @Lc_TypeCaseF_CODE 
							THEN (l.TransactionIvef_AMNT - l.TransactionCurSup_AMNT)
                            ELSE l.TransactionIvef_AMNT 
                       END) AS SumTransactionIvef_AMNT                    
             FROM LSUP_Y1 l
            WHERE l.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
              AND l.TransactionExptPay_AMNT > 0
              AND l.TransactionIvef_AMNT > 0
              AND l.CheckRecipient_CODE = @Lc_CheckRecipient3_CODE
              AND EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB)
              AND TypeRecord_CODE = @Lc_TypeRecordO_CODE
			  AND EXISTS (SELECT 1 
			                FROM CASE_Y1 d
			               WHERE d.Case_IDNO = l.Case_IDNO
			                 AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
            GROUP BY l.Case_IDNO) a
    WHERE a.Case_IDNO = BSURD_Y1.Case_IDNO
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /**	Line 56 :Arrears Only Cases Paying - Cases with current support obligation in OBLE_Y1 of 0 and LSUP has an transaction amount entry in the Arrears column**/
   SET @Ls_Sql_TEXT = 'UPDATE Line56_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordO_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line56_NUMB = 1
    WHERE Case_IDNO IN (SELECT o.Case_IDNO
                          FROM OBLE_Y1 o,
                               LSUP_Y1 l
                         WHERE o.Case_IDNO = l.Case_IDNO
                           AND l.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
						   AND EXISTS (SELECT 1 
						  				 FROM CASE_Y1 d
									    WHERE d.Case_IDNO = l.Case_IDNO
										  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
                           AND EXISTS (SELECT 1
                                         FROM LSUP_Y1 c
                                        WHERE c.Case_IDNO = l.Case_IDNO
                                          AND c.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
                                          AND EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB)
                                          AND TypeRecord_CODE = @Lc_TypeRecordO_CODE
                                          AND (c.TransactionNaa_AMNT + c.TransactionPaa_AMNT + c.TransactionTaa_AMNT + c.TransactionCaa_AMNT + c.TransactionUpa_AMNT + c.TransactionUda_AMNT + c.TransactionIvef_AMNT + c.TransactionMedi_AMNT + c.TransactionNffc_AMNT + c.TransactionNonIvd_AMNT) > 0)
                            GROUP BY o.Case_IDNO 
                            HAVING SUM(o.Periodic_AMNT) = 0)
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 57 : Arrears Only Cases Not Paying ' Cases with current support obligation in OBLE_Y1 of 0 
				 and LSUP has no transaction amount entry in the Arrears column **/
   SET @Ls_Sql_TEXT = 'UPDATE Line57_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'Periodic_AMNT = ' + CAST(0.00 AS VARCHAR) + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordO_CODE, '') + ', MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '');

   UPDATE BSURD_Y1
      SET Line57_NUMB = 1
    WHERE Case_IDNO IN (SELECT o.Case_IDNO
                          FROM OBLE_Y1 o,
                               LSUP_Y1 l
                         WHERE o.Case_IDNO = l.Case_IDNO
                           AND l.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
						   AND EXISTS (SELECT 1 
						  				 FROM CASE_Y1 d
									    WHERE d.Case_IDNO = l.Case_IDNO
										  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE)
                           AND NOT EXISTS (SELECT 1
                                             FROM LSUP_Y1 c
                                            WHERE c.Case_IDNO = l.Case_IDNO
                                              AND c.SupportYearMonth_NUMB = @Ln_MonthReport_NUMB
                                              AND EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB)
                                              AND TypeRecord_CODE = @Lc_TypeRecordO_CODE
                                              AND (c.TransactionNaa_AMNT + c.TransactionPaa_AMNT + c.TransactionTaa_AMNT + c.TransactionCaa_AMNT + c.TransactionUpa_AMNT + c.TransactionUda_AMNT + c.TransactionIvef_AMNT + c.TransactionMedi_AMNT + c.TransactionNffc_AMNT + c.TransactionNonIvd_AMNT) > 0)
                            GROUP BY o.Case_IDNO 
                            HAVING SUM(o.Periodic_AMNT) = 0)                                              
      AND MthReport_NUMB = @Ln_MonthReport_NUMB;

   /** Line 58 :Cases Submitted for Federal Tax Refund Offset ' Cases with a record in the FEDH_Y1 table initiated for federal offset during the reported month**/
   SET @Ls_Sql_TEXT = 'UPDATE Line58_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_ExcludeIrsN_CODE, '');

   UPDATE BSURD_Y1
      SET Line58_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.Case_IDNO
                          FROM FEDH_Y1 f,
                               CMEM_Y1 c,
                               CASE_Y1 s
                         WHERE c.MemberMci_IDNO = f.MemberMci_IDNO
                           AND c.Case_IDNO = s.Case_IDNO
                           AND s.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                           AND s.TypeCase_CODE <> @Lc_TypeCaseH_CODE
                           AND f.BeginValidity_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND f.ExcludeIrs_CODE = @Lc_ExcludeIrsN_CODE
                           AND f.TypeTransaction_CODE = @Lc_TypeTransactionAdd_CODE);

   /** Line 59	: Cases Submitted for  State Tax Offset ' Cases with a record in the FEDH_Y1 table initiated for state offset during the reported month **/
   SET @Ls_Sql_TEXT = 'UPDATE Line59_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ExcludeState_CODE = ' + ISNULL(@Lc_ExcludeStateN_CODE, '');

   UPDATE BSURD_Y1
      SET Line59_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT t.Case_IDNO
                          FROM ISTX_Y1 t
                         WHERE t.SubmitLast_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
						   and t.TypeTransaction_CODE = @Lc_TypeTransactionInit_CODE
                           AND t.ExcludeState_CODE = @Lc_ExcludeStateN_CODE
						   AND EXISTS (SELECT 1 
						  				 FROM CASE_Y1 d
									    WHERE d.Case_IDNO = t.Case_IDNO
										  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /**	Line 60	: Cases Excluded  from State Tax Offset ' Cases with a record in the TEXC_Y1 table initiated for State Offset during the reported month **/
   SET @Ls_Sql_TEXT = 'UPDATE Line60_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ExcludeState_CODE = ' + ISNULL(@Lc_ExcludeStateY_CODE, '');

   UPDATE BSURD_Y1
      SET Line60_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT t.Case_IDNO
                          FROM TEXC_Y1 t
                         WHERE t.Effective_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND t.EndValidity_DATE = @Ld_High_DATE
                           AND t.ExcludeState_CODE = @Lc_ExcludeStateY_CODE
						   AND EXISTS (SELECT 1 
						  				 FROM CASE_Y1 d
									    WHERE d.Case_IDNO = t.Case_IDNO
										  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /** Line 61	: Cases with Enforcement Exemptions ' Cases with any major activity in DMJR_Y1 set to EXMT and DMJR record is in the reported month **/
   SET @Ls_Sql_TEXT = 'UPDATE Line61_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusExmt_CODE, '');

   UPDATE BSURD_Y1
      SET Line61_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT j.Case_IDNO
                          FROM DMJR_Y1 j
                         WHERE j.Entered_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND j.Status_CODE = @Lc_StatusExmt_CODE
						   AND EXISTS (SELECT 1 
						  				 FROM CASE_Y1 d
									    WHERE d.Case_IDNO = j.Case_IDNO
										  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));

   /** Line 62 : Cases with Capias Issued ' Cases where the ENF status in CASE_Y1 is set to WCAP ' Capias issued **/
   SET @Ls_Sql_TEXT = 'UPDATE Line62_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', StatusEnforce_CODE = ' + ISNULL(@Lc_StatusEnforceWcap_CODE, '');

   UPDATE BSURD_Y1
      SET Line62_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT c.Case_IDNO
                          FROM CASE_Y1 c
                         WHERE c.StatusEnforce_CODE = @Lc_StatusEnforceWcap_CODE
                           AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE);

   /** Line 63	: Cases with License Suspension Exempted ' Cases with the LSNR ' License Suspension activity chain with status of EXMT in the DMJR_Y1 table **/
   SET @Ls_Sql_TEXT = 'UPDATE Line63_NUMB IN BSURD_Y1 TABLE';
   SET @Ls_Sqldata_TEXT = 'MthReport_NUMB = ' + ISNULL(CAST(@Ln_MonthReport_NUMB AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorLsnr_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusExmt_CODE, '');

   UPDATE BSURD_Y1
      SET Line63_NUMB = 1
    WHERE MthReport_NUMB = @Ln_MonthReport_NUMB
      AND Case_IDNO IN (SELECT j.Case_IDNO
                          FROM DMJR_Y1 j
                         WHERE j.Entered_DATE BETWEEN @Ld_ReportingMonthFrom_DATE AND @Ld_ReportingMonthTo_DATE
                           AND j.ActivityMajor_CODE = @Lc_ActivityMajorLsnr_CODE
                           AND j.Status_CODE = @Lc_StatusExmt_CODE
						   AND EXISTS (SELECT 1 
						  				 FROM CASE_Y1 d
									    WHERE d.Case_IDNO = j.Case_IDNO
										  AND d.StatusCase_CODE = @Lc_StatusCaseOpen_CODE));                           

   --BSURS_Y1 DATA INSERTION LINE BY LINE 1-63
   WHILE (@Ln_Line_NUMB <= 63)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_NUMB INTO BSURS_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
     SET @Ls_DynamicaSql_TEXT = '';
     SET @Ls_DynamicaSql_TEXT = '
		   INSERT INTO BSURS_Y1
		   (
		    MthReport_NUMB,
			Line_IDNO,
			County_IDNO,
			Worker_ID,
			Supervisor_ID,
			Tanf_AMNT,
			IVEFosterCare_AMNT,
			NonIVD_AMNT,
			NonFederalFosterCare_AMNT,
			NonPA_AMNT
		   )
		   SELECT x.MthReport_NUMB,
				  x.Line_IDNO ,
				  x.County_IDNO,
				  x.Worker_Id,
				  x.Supervisor_ID,
				  SUM(x.Tanf_AMNT) AS Tanf_AMNT,
				  SUM(x.IVEFosterCare_AMNT) AS IVEFosterCare_AMNT,
				  SUM(x.NonIVD_AMNT) AS NonIVD_AMNT,
				  SUM(x.NonFederalFosterCare_AMNT) AS NonFederalFosterCare_AMNT,
				  SUM(x.NonPA_AMNT) AS NonPA_AMNT
		    FROM 
			   (SELECT 
				b.MthReport_NUMB,' + CAST(@Ln_Line_NUMB AS VARCHAR) + ' AS Line_IDNO,
				b.County_IDNO,
				b.Worker_Id,
				b.Supervisor_ID,
				CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseA_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_NUMB) ELSE 0 END  AS Tanf_AMNT,
				CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseF_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_NUMB) ELSE 0 END  AS IVEFosterCare_AMNT,
				CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseH_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_NUMB) ELSE 0 END  AS NonIVD_AMNT,
				CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseJ_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_NUMB) ELSE 0 END  AS NonFederalFosterCare_AMNT,
				CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseN_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_NUMB) ELSE 0 END  AS NonPA_AMNT
				FROM BSURD_Y1 b
				WHERE b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_NUMB <> 0
				  AND b.MthReport_NUMB = ' + CAST(@Ln_MonthReport_NUMB AS VARCHAR) + '
				GROUP BY b.MthReport_NUMB,
						 b.TypeCase_CODE,
						 b.County_IDNO,
						 b.Worker_Id,
						 b.Supervisor_ID ) AS x
			GROUP BY x.MthReport_NUMB,
					 x.Line_IDNO ,
					 x.County_IDNO,
					 x.Worker_Id,
					 x.Supervisor_ID';
     SET @Ls_Sql_TEXT = 'EXECUTION OF INSERT Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_NUMB INTO BSURS_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     EXECUTE (@Ls_DynamicaSql_TEXT);

     SET @Ln_Line_NUMB = @Ln_Line_NUMB + 1;

     IF @Ln_Line_NUMB = 53
      BEGIN
       -- TO SUM THE AMOUNTS FOR LINE NUMBERS 53,54 AND 55
       WHILE (@Ln_Line_NUMB <= 55)
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_AMNT INTO BSURS_Y1 TABLE';
         SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
         SET @Ls_DynamicaSql_TEXT = '';
         SET @Ls_DynamicaSql_TEXT = '
					   INSERT INTO BSURS_Y1
					   (
						MthReport_NUMB,
						Line_IDNO,
						County_IDNO,
						Worker_ID,
						Supervisor_ID,
						Tanf_AMNT,
						IVEFosterCare_AMNT,
						NonIVD_AMNT,
						NonFederalFosterCare_AMNT,
						NonPA_AMNT
					   )
					   SELECT x.MthReport_NUMB,
							  x.Line_IDNO ,
							  x.County_IDNO,
							  x.Worker_Id,
							  x.Supervisor_ID,
							  SUM(x.Tanf_AMNT) AS Tanf_AMNT,
							  SUM(x.IVEFosterCare_AMNT) AS IVEFosterCare_AMNT,
							  SUM(x.NonIVD_AMNT) AS NonIVD_AMNT,
							  SUM(x.NonFederalFosterCare_AMNT) AS NonFederalFosterCare_AMNT,
							  SUM(x.NonPA_AMNT) AS NonPA_AMNT
						FROM 
						   (SELECT 
							b.MthReport_NUMB,' + CAST(@Ln_Line_NUMB AS VARCHAR) + ' AS Line_IDNO,
							b.County_IDNO,
							b.Worker_Id,
							b.Supervisor_ID,
							CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseA_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_AMNT) ELSE 0 END  AS Tanf_AMNT,
							CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseF_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_AMNT) ELSE 0 END  AS IVEFosterCare_AMNT,
							CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseH_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_AMNT) ELSE 0 END  AS NonIVD_AMNT,
							CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseJ_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_AMNT) ELSE 0 END  AS NonFederalFosterCare_AMNT,
							CASE TypeCase_CODE WHEN ''' + @Lc_TypeCaseN_CODE + ''' THEN SUM(b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_AMNT) ELSE 0 END  AS NonPA_AMNT
							FROM BSURD_Y1 b
							WHERE b.Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_AMNT <> 0
							  AND b.MthReport_NUMB = ' + CAST(@Ln_MonthReport_NUMB AS VARCHAR) + '
							GROUP BY b.MthReport_NUMB,
									 b.TypeCase_CODE,
									 b.County_IDNO,
									 b.Worker_Id,
									 b.Supervisor_ID ) AS x
						GROUP BY x.MthReport_NUMB,
								 x.Line_IDNO ,
								 x.County_IDNO,
								 x.Worker_Id,
								 x.Supervisor_ID';
         SET @Ls_Sql_TEXT = 'EXECUTION OF INSERT Line' + CAST(@Ln_Line_NUMB AS VARCHAR) + '_AMNT INTO BSURS_Y1 TABLE';
         SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

         EXECUTE (@Ls_DynamicaSql_TEXT);

         SET @Ln_Line_NUMB = @Ln_Line_NUMB + 1;

         IF @Ln_Line_NUMB = 56
          BEGIN
           BREAK;
          END
        END
      END

     IF @Ln_Line_NUMB = 64
      BEGIN
       BREAK;
      END
    END

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM BSURS_Y1 b
                                         WHERE MthReport_NUMB = @Ln_MonthReport_NUMB);

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO LOAD INTO BSURS_Y1';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

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

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   COMMIT TRANSACTION SUPERTREND_LOAD;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION SUPERTREND_LOAD;
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
    @An_ProcessedRecordCount_QNTY =@Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
