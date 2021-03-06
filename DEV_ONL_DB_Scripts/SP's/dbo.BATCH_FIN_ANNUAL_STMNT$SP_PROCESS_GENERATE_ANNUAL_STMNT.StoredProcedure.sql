/****** Object:  StoredProcedure [dbo].[BATCH_FIN_ANNUAL_STMNT$SP_PROCESS_GENERATE_ANNUAL_STMNT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_ANNUAL_STMNT$SP_PROCESS_GENERATE_ANNUAL_STMNT
Programmer Name 	: IMP Team
Description			: This batch generates annual statements to CPs and NCPs by September
					  30th of every year to include case financial data from October 1 through
					  September 30 of the prior fiscal year.
Frequency			: 'ANNUALLY'
Developed On		: 11/29/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_ANNUAL_STMNT$SP_PROCESS_GENERATE_ANNUAL_STMNT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ReceiptDistributed1820_NUMB             INT = 1820,
          @Li_DirectPayCredit1040_NUMB                INT = 1040,
          @Li_ArrearAdjustment1030_NUMB               INT = 1030,
          @Li_ReceiptReversed1250_NUMB                INT = 1250,
          @Li_ObligationModification1020_NUMB		  INT = 1020,
          @Li_ObligationCreation1010_NUMB		      INT = 1010,
          @Lc_Yes_INDC                                CHAR (1) = 'Y',
          @Lc_No_INDC                                 CHAR (1) = 'N',
          @Lc_StatusFailed_CODE                       CHAR (1) = 'F',
          @Lc_StatusSuccess_CODE                      CHAR (1) = 'S',
          @Lc_StatusAbnormalend_CODE                  CHAR (1) = 'A',
          @Lc_StatusO_CODE                            CHAR (1) = 'O',
          @Lc_FreqPeriodicO_CODE					  CHAR (1) = 'O',
          @Lc_TypeCaseH_CODE                          CHAR (1) = 'H',
          @Lc_RespondInitN_CODE                       CHAR (1) = 'N',
          @Lc_CaseRelationshipA_CODE                  CHAR (1) = 'A',
          @Lc_CaseRelationshipP_CODE                  CHAR (1) = 'P',
          @Lc_CaseRelationshipC_CODE                  CHAR (1) = 'C',
          @Lc_CaseMemberStatusA_CODE                  CHAR (1) = 'A',
          @Lc_CaseRelationshipD_CODE                  CHAR (1) = 'D',
          @Lc_TypeError_CODE                          CHAR (1) = ' ',
          @Lc_TypeErrorE_CODE                         CHAR (1) = 'E',
          @Lc_TypeRecordO_CODE                        CHAR (1) = 'O',
          @Lc_RespondInitRespondingState_CODE         CHAR(1) = 'R',
          @Lc_RespondInitRespondingTribal_CODE        CHAR(1) = 'S',
          @Lc_RespondInitRespondingInternational_CODE CHAR(1) = 'Y',
          @Lc_RespondInitInitiate_TEXT                CHAR(1) = 'I',
          @Lc_RespondInitInitiateIntrnl_TEXT          CHAR(1) = 'C',
          @Lc_RespondInitInitiateTribal_TEXT          CHAR(1) = 'T',
          @Lc_TypeReference_CODE					  CHAR(1) = '',
          @Lc_TypeDebtChildSupp_CODE                  CHAR (2) = 'CS',
          @Lc_TypeDebtSpousalSupp_CODE                CHAR (2) = 'SS',
          @Lc_TypeDebtMedicalSupp_CODE                CHAR (2) = 'MS',
          @Lc_TypeDebtGeneticTest_CODE                CHAR (2) = 'GT',
          @Lc_OctMonth10_TEXT                         CHAR (2) = '10',
          @Lc_SepMonth09_TEXT                         CHAR (2) = '09',
          @Lc_SubSystemFm_CODE                        CHAR (2) = 'FM',
          @Lc_ActivityMajorCase_CODE                  CHAR (4) = 'CASE',
          @Lc_ActivityMinorGeoys_CODE                 CHAR (5) = 'GEOYS',
          @Lc_BateErrorE1424_CODE                     CHAR (5) = 'E1424',
          @Lc_ErrorE1001_CODE                         CHAR (5) = 'E1001',
          @Lc_AnnualBeg01Oct_TEXT                     CHAR (6) = '10/01/',
          @Lc_AnnualEnd30Sep_TEXT                     CHAR (6) = '09/30/',
          @Lc_Job_ID                                  CHAR (7) = 'DEB8620',
          @Lc_NoticeFin07_ID                          CHAR (8) = 'FIN-07',
          @Lc_MonthOct_TEXT                           CHAR(10) = 'October',
          @Lc_MonthNov_TEXT                           CHAR(10) = 'November',
          @Lc_MonthDec_TEXT                           CHAR(10) = 'December',
          @Lc_Successful_TEXT                         CHAR (20) = 'SUCCESSFUL',
          @Lc_BatchRunUser_TEXT                       CHAR (30) = 'BATCH',
          @Ls_Sql_TEXT                                VARCHAR (100) = ' ',
          @Ls_Process_NAME                            VARCHAR (100) = 'BATCH_FIN_ANNUAL_STMNT',
          @Ls_Procedure_NAME                          VARCHAR (100) = 'SP_PROCESS_GENERATE_ANNUAL_STMNT',
          @Ls_CursorLoc_TEXT                          VARCHAR (200) = ' ',
          @Ls_Sqldata_TEXT                            VARCHAR (1000) = ' ',
          @Ld_Low_DATE                                DATE = '01/01/0001',
          @Ld_High_DATE                               DATE = '12/31/9999';
  DECLARE @Ln_ExceptionThreshold_QNTY                   NUMERIC (5) = 0,
          @Ln_ExceptionThresholdParm_QNTY               NUMERIC (5),
          @Ln_CommitFreqParm_QNTY                       NUMERIC (5) = 0,
          @Ln_CommitFreq_QNTY                           NUMERIC (5) = 0,
          @Ln_CaseAccr_QNTY                             NUMERIC (5) = 0,
          @Ln_Case_IDNO                                 NUMERIC (6) = 0,
          @Ln_FiscalEndYearSep_NUMB                     NUMERIC (6) = 0,
          @Ln_FiscalStartYearOct_NUMB                   NUMERIC (6) = 0,
          @Ln_PrevFiscalEndYearSep_NUMB                 NUMERIC (6) = 0,
          @Ln_PrevFiscalEndYearSepSupportYearMonth_NUMB NUMERIC (6) = 0,
          @Ln_ProcessedRecordCount_QNTY                 NUMERIC (9) = 0,
          @Ln_ProcessedRecordsCommit_QNTY               NUMERIC (9) = 0,
          @Ln_MemberMciCp_IDNO                          NUMERIC (10)= 0,
          @Ln_MemberMciNcp_IDNO                         NUMERIC (10)= 0,
          @Ln_Cursor_QNTY                               NUMERIC (11) = 0,
          @Ln_Arrear_AMNT                               NUMERIC (11, 2) = 0,
          @Ln_ArrearBegin_AMNT                          NUMERIC (11, 2) = 0,
          @Ln_ArrearEnd_AMNT                            NUMERIC (11, 2) = 0,
          @Ln_OrderedMonthlySup_AMNT                    NUMERIC (11, 2) = 0,
          @Ln_OrderedMonthlyArrears_AMNT                NUMERIC (11, 2) = 0,
          @Ln_CurrentSupportDue_AMNT                    NUMERIC (11, 2) = 0,
          @Ln_ChildSupportPaid_AMNT                     NUMERIC (11, 2) = 0,
          @Ln_Adjustments_AMNT                          NUMERIC (11, 2) = 0,
          @Ln_Adjustments1030_AMNT                      NUMERIC (11, 2) = 0,
          @Ln_Adjustments1040_AMNT                      NUMERIC (11, 2) = 0,
          @Ln_Error_NUMB                                NUMERIC (11),
          @Ln_ErrorLine_NUMB                            NUMERIC (11),
          @Ln_Topic_IDNO                                NUMERIC (11),
          @Ln_TransactionEventSeq_NUMB                  NUMERIC (11) = 0,
          @Ln_Rowcount_QNTY                             NUMERIC (11),
          @Li_FetchStatus_QNTY                          SMALLINT,
          @Lc_Msg_CODE                                  CHAR (5),
          @Lc_BateError_CODE                            CHAR (5),
          @Lc_MemberMci_IDNO                            CHAR (10),
          @Ls_BateRecord_TEXT                           VARCHAR (8000),
          @Ls_ErrorMessage_TEXT                         VARCHAR (8000),
          @Ls_DescriptionError_TEXT                     VARCHAR (8000),
          @Ls_XmlTextIn_TEXT                            VARCHAR (8000),
          @Ld_FiscalYearBegin_DATE                      DATE,
          @Ld_FiscalYearEnd_DATE                        DATE,
          @Ld_BeginDateYear_DATE                        DATE,
          @Ld_EndDateYear_DATE                          DATE,
          @Ld_Run_DATE                                  DATE,
          @Ld_LastRun_DATE                              DATE,
          @Ld_Start_DATE                                DATETIME2;
  DECLARE @Ln_CaseCur_Case_IDNO NUMERIC(6);

  BEGIN TRY
   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';
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
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   
   -- Setting the Fiscal year variables(For Ex: Run Date is '09/30/2012', @Ld_FiscalYearBegin_DATE is '10/01/2011', @Ld_FiscalYearEnd_DATE is '09/30/2012', 
   -- @Ln_FiscalStartYearOct_NUMB is '201110' ,@Ln_FiscalEndYearSep_NUMB is '201209',  @Ln_PrevFiscalEndYearSep_NUMB is 201109, )
   SET @Ld_FiscalYearBegin_DATE = @Lc_AnnualBeg01Oct_TEXT + DATENAME(YEAR, DATEADD(m, -12, @Ld_Run_DATE));
   SET @Ld_FiscalYearEnd_DATE = @Lc_AnnualEnd30Sep_TEXT + DATENAME(YEAR, @Ld_Run_DATE);
   
   -- Setting fiscal year Start and End month using run date
   SET @Ln_FiscalStartYearOct_NUMB = ISNULL(CAST((CAST(CONVERT(VARCHAR(4), @Ld_FiscalYearBegin_DATE, 112) AS SMALLINT)) AS VARCHAR), '') + ISNULL(@Lc_OctMonth10_TEXT, '');
   SET @Ln_FiscalEndYearSep_NUMB = ISNULL(CAST((CAST(CONVERT(VARCHAR(4), @Ld_FiscalYearEnd_DATE, 112) AS SMALLINT)) AS VARCHAR), '') + ISNULL(@Lc_SepMonth09_TEXT, '');
   -- Setting previous fiscal year Start month using run date
   SET @Ln_PrevFiscalEndYearSep_NUMB = ISNULL(CAST((CAST(CONVERT(VARCHAR(4), @Ld_FiscalYearBegin_DATE, 112) AS SMALLINT)) AS VARCHAR), '') + ISNULL(@Lc_SepMonth09_TEXT, '');
   -- Check if restart key exists in Restart table.
   SET @Ls_Sql_TEXT = 'SELECT RSTL_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CONVERT(VARCHAR(10), @Ld_Run_DATE, 101), '');

   SELECT @Ln_Case_IDNO = CAST(a.RestartKey_TEXT AS NUMERIC)
     FROM RSTL_Y1 a
    WHERE a.Job_ID = @Lc_Job_ID
      AND a.Run_DATE = @Ld_Run_DATE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ln_Case_IDNO = 0;
    END

   /*
    Read the both CP and NCP's Case Details (CASE_Y1) table and get the open Instate IVD cases 
    as of October 1 through September 30 of the fiscal year.
   */
   DECLARE Case_CUR INSENSITIVE CURSOR FOR
    SELECT x.Case_IDNO
      FROM (SELECT DISTINCT
                   a.Case_IDNO,
                   ISNULL((SELECT TOP 1 @Lc_Yes_INDC
                             FROM SORD_Y1 b
                            WHERE a.Case_IDNO = b.Case_IDNO
                              AND b.EndValidity_DATE = @Ld_High_DATE), @Lc_No_INDC) Sord_INDC
              FROM CASE_Y1 a,
                   CMEM_Y1 m,
                   DEMO_Y1 d
             WHERE a.Case_IDNO > @Ln_Case_IDNO
               AND a.Case_IDNO = m.Case_IDNO
               AND m.MemberMci_IDNO = d.MemberMci_IDNO
               --Member should not be deceased	
               AND d.Deceased_DATE = @Ld_Low_DATE
               AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
               AND a.StatusCase_CODE = @Lc_StatusO_CODE
               -- Non-IVD cases
               AND a.TypeCase_CODE <> @Lc_TypeCaseH_CODE
               -- Dependant should not be Inactive			
			   AND EXISTS ( SELECT 1 
							FROM CMEM_Y1 b
							WHERE b.Case_IDNO = a.Case_IDNO
							AND b.CaseRelationship_CODE = @Lc_CaseRelationshipD_CODE
							AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE)	
               AND ((
                    --Open IV-D Instate cases and open initiating intergovernmental cases
                    m.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                    AND (a.RespondInit_CODE = @Lc_RespondInitN_CODE
                          OR (a.RespondInit_CODE IN (@Lc_RespondInitInitiateIntrnl_TEXT, @Lc_RespondInitInitiate_TEXT, @Lc_RespondInitInitiateTribal_TEXT)
                              AND EXISTS (SELECT 1
                                            FROM ICAS_Y1 Y
                                           WHERE Y.Case_IDNO = a.Case_IDNO
                                             AND Y.Status_CODE = @Lc_StatusO_CODE
                                             AND Y.End_DATE = @Ld_High_DATE
                                             AND Y.EndValidity_DATE = @Ld_High_DATE))))
                     OR (
                        --Open IV-D Instate cases or open responding intergovernmental cases (ICAS_Y1) 
                        m.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                        AND (a.RespondInit_CODE = @Lc_RespondInitN_CODE
                              OR (a.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
                                  AND EXISTS (SELECT 1
                                                FROM ICAS_Y1 Y
                                               WHERE Y.Case_IDNO = a.Case_IDNO
                                                 AND Y.Status_CODE = @Lc_StatusO_CODE
                                                 AND Y.End_DATE = @Ld_High_DATE
                                                 AND Y.EndValidity_DATE = @Ld_High_DATE)))))) x
     WHERE x.Sord_INDC = @Lc_Yes_INDC
     ORDER BY x.Case_IDNO;

   BEGIN TRANSACTION GEN_ANNUAL_STMNT;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', Process_ID = ' + @Lc_Job_ID + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + @Lc_No_INDC + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = '',
    @An_EventFunctionalSeq_NUMB  = 0,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'OPEN Case_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Case_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Case_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN
    -- Cursor loop started
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
      BEGIN TRY
       SET @Ls_Sql_TEXT = 'GEN_ANNUAL_STMNT_SAVE BEGINS - 2';
       SET @Ls_Sqldata_TEXT = '';

       SAVE TRANSACTION GEN_ANNUAL_STMNT_SAVE;

       SET @Ls_ErrorMessage_TEXT = '';
       SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
       SET @Ls_BateRecord_TEXT = 'Case_IDNO = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR);
       SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
       SET @Ls_CursorLoc_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', Cursor_QNTY= ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '');
       SET @Ln_MemberMciCp_IDNO = 0;	
	   SET @Ln_MemberMciNcp_IDNO = 0;
	   SET @Lc_TypeReference_CODE ='';
      /*
      Check whether the case is accruing by looking at the obligation begin date and obligation 
      end date in Obligation (OBLE_Y1) table. There is current accrual on the case if the 
      obligation end date is higher than the batch run date.
      */
       -- (For Ex: Run Date is '09/30/2012', @Ld_FiscalYearEnd_DATE is '09/30/2012')
       SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1 RECORDS';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', EndDateRunYr_TEXT = ' + CAST(@Ld_FiscalYearEnd_DATE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       SELECT TOP 1 @Ln_CaseAccr_QNTY = 1
         FROM OBLE_Y1 a
        WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
          AND @Ld_FiscalYearEnd_DATE BETWEEN a.BeginObligation_DATE AND a.EndObligation_DATE
          AND a.Periodic_AMNT > 0
          AND a.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtMedicalSupp_CODE)
          AND a.EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 0
        BEGIN
         SET @Ln_CaseAccr_QNTY = 0;
        END

       /*
        Calculate the arrears by adding up the difference amount (owed - applied) 
        in all the buckets as of Current year September from Run Date	
       */
       SET @Ls_Sql_TEXT = 'CALCULATE AMOUNT ARREARS AS BEGIN DATE';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + CAST(@Ln_FiscalStartYearOct_NUMB AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', TypeDebt_CODE = ' + 'CS SS MS' + ', SupportYearMonth_NUMB = ' + CAST(@Ln_FiscalEndYearSep_NUMB AS VARCHAR);

       -- (For Ex: Run Date is '09/30/2012', @Ln_FiscalEndYearSep_NUMB is '201209')
       -- Amount of Arrears as of Current year September from Run Date
       SELECT @Ln_Arrear_AMNT = ISNULL(SUM((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT)), 0)
         FROM LSUP_Y1 a,
              OBLE_Y1 b
        WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
          AND a.Case_IDNO = b.Case_IDNO
          AND b.EndValidity_DATE = @Ld_High_DATE
          AND b.TypeDebt_CODE IN (@Lc_TypeDebtChildSupp_CODE, @Lc_TypeDebtSpousalSupp_CODE, @Lc_TypeDebtMedicalSupp_CODE)
          AND a.SupportYearMonth_NUMB = @Ln_FiscalEndYearSep_NUMB
          AND a.EventGlobalSeq_NUMB = (SELECT MAX(p.EventGlobalSeq_NUMB)
                                         FROM LSUP_Y1 p
                                        WHERE a.Case_IDNO = p.Case_IDNO
                                          AND a.OrderSeq_NUMB = p.OrderSeq_NUMB
                                          AND a.ObligationSeq_NUMB = p.ObligationSeq_NUMB
                                          AND a.SupportYearMonth_NUMB = p.SupportYearMonth_NUMB);

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF @Ln_Rowcount_QNTY = 0
        BEGIN
         SET @Ln_Arrear_AMNT = 0;
        END

       /*
        Proceed to the next step only when the obligation is accruing or there is an arrears balance on the case. 
        If the case is neither accruing nor has any arrear balance then skip the case from further processing.
       */
       
       IF (@Ln_CaseAccr_QNTY > 0
            OR @Ln_Arrear_AMNT > 0)
        BEGIN
         -- Initialize the total amount due,disbursed and agency
         SET @Ln_CurrentSupportDue_AMNT = 0;
         SET @Ln_ChildSupportPaid_AMNT = 0;
         SET @Ln_Adjustments_AMNT = 0;
         
         -- 50 - Amount of Arrears as of Begin Date(For Ex: Run Date is '09/30/2012', @Ln_PrevFiscalEndYearSep_NUMB is '201109')
         -- Amount of Arrears as of Sep month Previous fiscal year from Run Date
         SET @Ls_Sql_TEXT = 'AMOUNT OF ARREARS AS OF BEGIN DATE';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + CAST(@Ln_PrevFiscalEndYearSep_NUMB AS VARCHAR);
		 --BUG13608:If obligation started after 201109 (i.e from 201110) then @Ln_ArrearBegin_AMNT will be always '0'
		 --else if the obligation started before 201110 then the @Ln_ArrearBegin_AMNT will be all Owed - Appled buckets
         SELECT @Ln_ArrearBegin_AMNT = ISNULL(SUM((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT)), 0)
           FROM LSUP_Y1 a
          WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
            AND a.SupportYearMonth_NUMB = @Ln_PrevFiscalEndYearSep_NUMB
            AND a.EventGlobalSeq_NUMB = (SELECT MAX(p.EventGlobalSeq_NUMB)
                                           FROM LSUP_Y1 p
                                          WHERE a.Case_IDNO = p.Case_IDNO
                                            AND a.OrderSeq_NUMB = p.OrderSeq_NUMB
                                            AND a.ObligationSeq_NUMB = p.ObligationSeq_NUMB
                                            AND a.SupportYearMonth_NUMB = p.SupportYearMonth_NUMB);

         -- 51 - Amount Current Support Due for the fiscal year(For Ex: Run Date is '09/30/2012',@Ln_FiscalStartYearOct_NUMB is '201110', @Ln_FiscalEndYearSep_NUMB is '201209')
         -- Amount Current Support Due between October to September of Fiscal year from Run Date
         SET @Ls_Sql_TEXT = 'AMOUNT CURRENT SUPPORT DUE BETWEEN BEGIN AND END DATE';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', SupportYearMonthFirst_NUMB = ' + CAST(@Ln_FiscalStartYearOct_NUMB AS VARCHAR) + ', SupportYearMonthLast_NUMB = ' + CAST(@Ln_FiscalEndYearSep_NUMB AS VARCHAR);
		 
		 SELECT @Ln_CurrentSupportDue_AMNT = SUM(x.TotalOwedCurSup_ANT) FROM (
										--BUG13608: In Obligation Modification created by OWIZ Record (i.e EventFunctionalSeq_NUMB -1020) modified amount only added in OweTotCurSup_AMNT But not in MtdCurSupOwed_AMNT
										 SELECT ISNULL(SUM(a.OweTotCurSup_AMNT), 0) TotalOwedCurSup_ANT
										   FROM LSUP_Y1 a
										  WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
											AND a.SupportYearMonth_NUMB BETWEEN @Ln_FiscalStartYearOct_NUMB AND @Ln_FiscalEndYearSep_NUMB
											AND a.TypeWelfare_CODE <> @Lc_TypeCaseH_CODE
											AND a.EventGlobalSeq_NUMB = (SELECT MAX(p.EventGlobalSeq_NUMB)
																		   FROM LSUP_Y1 p
																		  WHERE p.TypeWelfare_CODE <> @Lc_TypeCaseH_CODE
																			AND a.Case_IDNO = p.Case_IDNO
																			AND a.OrderSeq_NUMB = p.OrderSeq_NUMB
																			AND a.ObligationSeq_NUMB = p.ObligationSeq_NUMB
																			AND a.SupportYearMonth_NUMB = p.SupportYearMonth_NUMB)
                                            --BUG13608:Onetime Obligation Genetic Test (GT) is added to the Child Support Due amount to avoid Arrear End Imbalance
											UNION ALL
											SELECT ISNULL(SUM (TransactionNaa_AMNT + TransactionPaa_AMNT + TransactionTaa_AMNT + TransactionCaa_AMNT + TransactionUpa_AMNT + TransactionUda_AMNT + TransactionMedi_AMNT + TransactionIvef_AMNT + TransactionNffc_AMNT ), 0) TotalOwedCurSup_ANT
											 FROM LSUP_Y1 a,OBLE_Y1 o 
											 WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO 
											AND a.Case_IDNO = o.Case_IDNO 
											AND a.SupportYearMonth_NUMB BETWEEN @Ln_FiscalStartYearOct_NUMB AND @Ln_FiscalEndYearSep_NUMB
											AND a.OrderSeq_NUMB = o.OrderSeq_NUMB
											AND a.ObligationSeq_NUMB = o.ObligationSeq_NUMB
											AND a.EventFunctionalSeq_NUMB = @Li_ObligationCreation1010_NUMB
											AND a.TypeWelfare_CODE <> @Lc_TypeCaseH_CODE
											AND o.TypeDebt_CODE = @Lc_TypeDebtGeneticTest_CODE
											AND o.FreqPeriodic_CODE = @Lc_FreqPeriodicO_CODE
											AND o.EndValidity_DATE =@Ld_High_DATE
											AND a.SupportYearMonth_NUMB	= (SELECT MIN(P.SupportYearMonth_NUMB)
																			   FROM LSUP_Y1 p
																			  WHERE p.TypeWelfare_CODE <> @Lc_TypeCaseH_CODE
																				AND a.Case_IDNO = p.Case_IDNO
																				AND a.OrderSeq_NUMB = p.OrderSeq_NUMB
																				AND a.ObligationSeq_NUMB = p.ObligationSeq_NUMB
																				AND p.EventFunctionalSeq_NUMB = @Li_ObligationCreation1010_NUMB
																				AND a.EventGlobalSeq_NUMB = p.EventGlobalSeq_NUMB)                     
                                            
					) AS x
					

         -- 52 - Amount of Current Support Paid for the fiscal year(For Ex: Run Date is '09/30/2012',@Ln_FiscalStartYearOct_NUMB is '201110', @Ln_FiscalEndYearSep_NUMB is '201209')
         -- Amount of Current Support Paid between October to September of Fiscal year from Run Date
         SET @Ls_Sql_TEXT = 'AMOUNT OF CURRENT SUPPORT PAID BETWEEN BEGIN AND END DATE';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', SupportYearMonthFirst_NUMB = ' + CAST(@Ln_FiscalStartYearOct_NUMB AS VARCHAR) + ', SupportYearMonthLast_NUMB = ' + CAST(@Ln_FiscalEndYearSep_NUMB AS VARCHAR) + ', EventFunctionalSeq_NUMB = ' + '1820 1250' + ', TypeRecord_CODE = ' + @Lc_TypeRecordO_CODE;

         SELECT @Ln_ChildSupportPaid_AMNT = ISNULL(SUM (TransactionNaa_AMNT + TransactionPaa_AMNT + TransactionTaa_AMNT + TransactionCaa_AMNT + TransactionUpa_AMNT + TransactionUda_AMNT + TransactionMedi_AMNT + TransactionIvef_AMNT + TransactionNffc_AMNT), 0)
           FROM LSUP_Y1 a
          WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
            AND a.SupportYearMonth_NUMB BETWEEN @Ln_FiscalStartYearOct_NUMB AND @Ln_FiscalEndYearSep_NUMB
            AND a.EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB)
            AND a.TypeRecord_CODE = @Lc_TypeRecordO_CODE;

         -- 53 - Amount of Adjustments between begin and end date(For Ex: Run Date is '09/30/2012',@Ln_FiscalStartYearOct_NUMB is '201110', @Ln_FiscalEndYearSep_NUMB is '201209')
         -- Amount of Adjustments between October to September of Fiscal year from Run Date
         SET @Ls_Sql_TEXT = 'AMOUNT OF ADJUSTMENTS BETWEEN BEGIN AND END DATE';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', SupportYearMonthFirst_NUMB = ' + CAST(@Ln_FiscalStartYearOct_NUMB AS VARCHAR) + ', SupportYearMonthLast_NUMB = ' + CAST(@Ln_FiscalEndYearSep_NUMB AS VARCHAR) + ', EventFunctionalSeq_NUMB = ' + CAST(@Li_ArrearAdjustment1030_NUMB AS VARCHAR) + ', TypeRecord_CODE = ' + @Lc_TypeRecordO_CODE;

         SELECT @Ln_Adjustments1030_AMNT = ISNULL(SUM (TransactionNaa_AMNT + TransactionPaa_AMNT + TransactionTaa_AMNT + TransactionCaa_AMNT + TransactionUpa_AMNT + TransactionUda_AMNT + TransactionMedi_AMNT + TransactionIvef_AMNT + TransactionNffc_AMNT - TransactionCurSup_AMNT), 0)
           FROM LSUP_Y1 a
           --13608: Since we whould not consider Non-IVD cases adjustment amount, TypeWelfare_CODE 'H' excluded from the @Ln_Adjustments1030_AMNT amount
		   --and in Obligation Modification (1020) is inserting the TypeRecord_CODE as empty where 'P' or 'O' is expected so the logic changed to take the 
		   --modified amount from the record with minimum SupportYearMonth_NUMB for each EventGlobalSeq_NUMB
          WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
			AND a.TypeWelfare_CODE <> @Lc_TypeCaseH_CODE
            AND a.SupportYearMonth_NUMB BETWEEN @Ln_FiscalStartYearOct_NUMB AND @Ln_FiscalEndYearSep_NUMB
            AND ( (a.EventFunctionalSeq_NUMB  = @Li_ArrearAdjustment1030_NUMB AND a.TypeRecord_CODE = @Lc_TypeRecordO_CODE)
								OR
							  (a.EventFunctionalSeq_NUMB  = @Li_ObligationModification1020_NUMB 
							   AND a.SupportYearMonth_NUMB IN (SELECT MIN(P.SupportYearMonth_NUMB)
													   FROM LSUP_Y1 p
													  WHERE a.Case_IDNO = p.Case_IDNO
													    AND p.TypeWelfare_CODE <> @Lc_TypeCaseH_CODE
														AND a.OrderSeq_NUMB = p.OrderSeq_NUMB
														AND a.ObligationSeq_NUMB = p.ObligationSeq_NUMB
														AND p.EventFunctionalSeq_NUMB = @Li_ObligationModification1020_NUMB
														AND a.EventGlobalSeq_NUMB = p.EventGlobalSeq_NUMB
														
														)
								
							  )
			);
		  
		  
		  SELECT @Ln_Adjustments1040_AMNT = ISNULL(SUM (TransactionNaa_AMNT + TransactionPaa_AMNT + TransactionTaa_AMNT + TransactionCaa_AMNT + TransactionUpa_AMNT + TransactionUda_AMNT + TransactionMedi_AMNT + TransactionIvef_AMNT + TransactionNffc_AMNT), 0)
           FROM LSUP_Y1 a
          WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
            AND a.SupportYearMonth_NUMB BETWEEN @Ln_FiscalStartYearOct_NUMB AND @Ln_FiscalEndYearSep_NUMB
            AND a.EventFunctionalSeq_NUMB = @Li_DirectPayCredit1040_NUMB
            -- OBAA Adjustments
            AND a.TypeRecord_CODE = @Lc_TypeRecordO_CODE
            AND a.SupportYearMonth_NUMB = (SELECT MAX(P.SupportYearMonth_NUMB)
                                           FROM LSUP_Y1 p
                                          WHERE a.Case_IDNO = p.Case_IDNO
                                            AND a.OrderSeq_NUMB = p.OrderSeq_NUMB
                                            AND a.ObligationSeq_NUMB = p.ObligationSeq_NUMB
                                            AND p.EventFunctionalSeq_NUMB = @Li_DirectPayCredit1040_NUMB
                                            AND a.EventGlobalSeq_NUMB = p.EventGlobalSeq_NUMB
                                            AND p.TypeRecord_CODE = @Lc_TypeRecordO_CODE);
                                            
          
		  SET @Ln_Adjustments_AMNT = @Ln_Adjustments1030_AMNT - @Ln_Adjustments1040_AMNT;
		  
		  
         -- 54 - Arrears as of End Date (For Ex: Run Date is '09/30/2012', @Ln_FiscalEndYearSep_NUMB is '201209')
         -- Arrears as of September of Fiscal year from Run Date
         SET @Ls_Sql_TEXT = 'AMOUNT OF ARREARS AS OF END DATE';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', SupportYearMonth_NUMB = ' + CAST(@Ln_FiscalEndYearSep_NUMB AS VARCHAR);

         SELECT @Ln_ArrearEnd_AMNT = ISNULL(SUM((a.OweTotNaa_AMNT - a.AppTotNaa_AMNT) + (a.OweTotPaa_AMNT - a.AppTotPaa_AMNT) + (a.OweTotTaa_AMNT - a.AppTotTaa_AMNT) + (a.OweTotCaa_AMNT - a.AppTotCaa_AMNT) + (a.OweTotUpa_AMNT - a.AppTotUpa_AMNT) + (a.OweTotUda_AMNT - a.AppTotUda_AMNT) + (a.OweTotIvef_AMNT - a.AppTotIvef_AMNT) + (a.OweTotMedi_AMNT - a.AppTotMedi_AMNT) + (a.OweTotNffc_AMNT - a.AppTotNffc_AMNT)), 0)
           FROM LSUP_Y1 a
          WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
            AND a.SupportYearMonth_NUMB = @Ln_FiscalEndYearSep_NUMB
            AND a.EventGlobalSeq_NUMB = (SELECT MAX(p.EventGlobalSeq_NUMB)
                                           FROM LSUP_Y1 p
                                          WHERE a.Case_IDNO = p.Case_IDNO
                                            AND a.OrderSeq_NUMB = p.OrderSeq_NUMB
                                            AND a.ObligationSeq_NUMB = p.ObligationSeq_NUMB
                                            AND a.SupportYearMonth_NUMB = p.SupportYearMonth_NUMB);

         /* 
                Notice Element Numbers : IF 54 = 50 + 51 -52 (+-) 53 then generate notice   
                Arrears as of End Date = Arrears as of Begin date + Amount Current Support Due for the year  - Amount Paid for the year + Adjustments                          
                If amounts do not match, do not insert the record into Notice Print Request table and log details in Batch Status log (BSTL_Y1). 
               */
               
         IF @Ln_ArrearEnd_AMNT = @Ln_ArrearBegin_AMNT + @Ln_CurrentSupportDue_AMNT - @Ln_ChildSupportPaid_AMNT + @Ln_Adjustments_AMNT
          BEGIN
           
           --Get the members for the Open IV-D Instate cases and open initiating intergovernmental cases
           
           SET @Ls_Sql_TEXT = 'SELECT THE CP FOR THE OPEN INSTATE IVD CASE';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + @Lc_StatusO_CODE + ', TypeCase_CODE = ' + @Lc_TypeCaseH_CODE + ', RespondInit_CODE = ' + @Lc_RespondInitN_CODE + ', Deceased_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CaseRelationship_CODE = ' + @Lc_CaseRelationshipA_CODE + ', CaseMemberStatus_CODE = ' + @Lc_CaseMemberStatusA_CODE;
		   
           SELECT @Ln_MemberMciCp_IDNO = ISNULL(b.MemberMci_IDNO,0)
             FROM CMEM_Y1 b
            WHERE b.Case_IDNO = @Ln_CaseCur_Case_IDNO
                  -- Member Should Be CP
                  AND b.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
                  AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                  AND EXISTS (SELECT 1 FROM CASE_Y1 a
							   WHERE a.Case_IDNO = b.Case_IDNO	
								AND (a.RespondInit_CODE = @Lc_RespondInitN_CODE
									  OR (a.RespondInit_CODE IN (@Lc_RespondInitInitiateIntrnl_TEXT, @Lc_RespondInitInitiate_TEXT, @Lc_RespondInitInitiateTribal_TEXT)
										  AND EXISTS (SELECT 1
														FROM ICAS_Y1 Y
													   WHERE Y.Case_IDNO = a.Case_IDNO
														 AND Y.Status_CODE = @Lc_StatusO_CODE
														 AND Y.End_DATE = @Ld_High_DATE
														 AND Y.EndValidity_DATE = @Ld_High_DATE)
													  )
										  )
									 );
			
		   --Get the members for the Open IV-D Instate cases or open responding intergovernmental cases (ICAS_Y1) 	
		   SET @Ls_Sql_TEXT = 'SELECT THE NCP FOR THE OPEN INSTATE IVD CASE';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + @Lc_StatusO_CODE + ', TypeCase_CODE = ' + @Lc_TypeCaseH_CODE + ', RespondInit_CODE = ' + @Lc_RespondInitN_CODE + ', Deceased_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CaseRelationship_CODE = ' + @Lc_CaseRelationshipA_CODE + ', CaseMemberStatus_CODE = ' + @Lc_CaseMemberStatusA_CODE;

           SELECT @Ln_MemberMciNcp_IDNO = ISNULL(b.MemberMci_IDNO,0)
             FROM CMEM_Y1 b
            WHERE b.Case_IDNO = @Ln_CaseCur_Case_IDNO
                  -- Member Should Be NCP
                  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                  AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
                  AND EXISTS (SELECT 1 FROM CASE_Y1 a
							   WHERE a.Case_IDNO = b.Case_IDNO	
								AND (a.RespondInit_CODE = @Lc_RespondInitN_CODE
									  OR (a.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
										  AND EXISTS (SELECT 1
														FROM ICAS_Y1 Y
													   WHERE Y.Case_IDNO = a.Case_IDNO
														 AND Y.Status_CODE = @Lc_StatusO_CODE
														 AND Y.End_DATE = @Ld_High_DATE
														 AND Y.EndValidity_DATE = @Ld_High_DATE)
													  )
										  )
									 );
			
			 						 
			 IF @Ln_MemberMciCp_IDNO <> 0 AND @Ln_MemberMciNcp_IDNO <> 0
			 BEGIN
				-- Notice should go to CP and NCP
				SET @Lc_TypeReference_CODE = 'B';
			 END
			 ELSE IF @Ln_MemberMciCp_IDNO <> 0 AND @Ln_MemberMciNcp_IDNO = 0						 
			 BEGIN
				-- Notice should go to CP only
				SET @Lc_TypeReference_CODE = 'C';
			 END
			 ELSE IF @Ln_MemberMciNcp_IDNO <> 0 AND @Ln_MemberMciCp_IDNO = 0						 
			 BEGIN
				-- Notice should go to NCP only
				SET @Lc_TypeReference_CODE = 'A';
			 END
			 
		   
		   /*
           Get the members for the Open Instate IVD Case 
           */
           SET @Ls_Sql_TEXT = 'SELECT THE NCP FOR THE OPEN INSTATE IVD CASE';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + @Lc_StatusO_CODE + ', TypeCase_CODE = ' + @Lc_TypeCaseH_CODE + ', RespondInit_CODE = ' + @Lc_RespondInitN_CODE + ', Deceased_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CaseRelationship_CODE = ' + @Lc_CaseRelationshipA_CODE + ', CaseMemberStatus_CODE = ' + @Lc_CaseMemberStatusA_CODE;

           SELECT @Lc_MemberMci_IDNO = CAST(b.MemberMci_IDNO AS VARCHAR)
             FROM CMEM_Y1 b
            WHERE b.Case_IDNO = @Ln_CaseCur_Case_IDNO
                  -- Member Should Be NCP
                  AND b.CaseRelationship_CODE IN (@Lc_CaseRelationshipA_CODE, @Lc_CaseRelationshipP_CODE)
                  AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE;
		   	 
           -- Ordered Monthly Support Payment Amount Date (For Ex: Run Date is '09/30/2012',@Ln_FiscalEndYearSep_NUMB is '201209' )
           SET @Ls_Sql_TEXT = 'SELECT ORDERED MONTHLY SUPPORT PAYMENT AMOUNT FROM LSUP_Y1 - 1';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', SupportYearMonth_NUMB From = ' + CAST(@Ln_FiscalStartYearOct_NUMB AS VARCHAR) + ', SupportYearMonth_NUMB = ' + CAST(@Ln_FiscalEndYearSep_NUMB AS VARCHAR);

           SELECT @Ln_OrderedMonthlySup_AMNT = ISNULL(SUM(MtdCurSupOwed_AMNT), 0)
             FROM LSUP_Y1 a
            WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
              AND a.SupportYearMonth_NUMB = @Ln_FiscalEndYearSep_NUMB
              AND a.EventGlobalSeq_NUMB = (SELECT MAX(d.EventGlobalSeq_NUMB)
                                             FROM LSUP_Y1 d
                                            WHERE d.Case_IDNO = a.Case_IDNO
                                              AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                              AND d.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);

           -- Ordered Monthly Arrears Payment Amount (For Ex: Run Date is '09/30/2012',@Ln_FiscalEndYearSep_NUMB is '201209' )
           SET @Ls_Sql_TEXT = 'SELECT ORDERED MONTHLY ARREARS PAYMENT AMOUNT FROM LSUP_Y1 - 1';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', SupportYearMonth_NUMB From = ' + CAST(@Ln_FiscalStartYearOct_NUMB AS VARCHAR) + ', SupportYearMonth_NUMB = ' + CAST(@Ln_FiscalEndYearSep_NUMB AS VARCHAR);

           SELECT @Ln_OrderedMonthlyArrears_AMNT = ISNULL(SUM(OweTotExptPay_AMNT), 0)
             FROM LSUP_Y1 a
            WHERE a.Case_IDNO = @Ln_CaseCur_Case_IDNO
              AND a.SupportYearMonth_NUMB = @Ln_FiscalEndYearSep_NUMB
              AND a.EventGlobalSeq_NUMB = (SELECT MAX(d.EventGlobalSeq_NUMB)
                                             FROM LSUP_Y1 d
                                            WHERE d.Case_IDNO = a.Case_IDNO
                                              AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                              AND d.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);
			
           /*
           If the amounts are equal as calculated in above step, insert record into Notice Print Request (NMRQ_Y1) 
           table with the notice details for the NCP and CP annual statement (FIN-07).
           */
           IF @Ln_Adjustments_AMNT < 0
		   BEGIN
				SET @Ln_Adjustments_AMNT = -(@Ln_Adjustments_AMNT);
		   END
           SET @Ld_BeginDateYear_DATE = @Ld_FiscalYearBegin_DATE;
           SET @Ld_EndDateYear_DATE = @Ld_FiscalYearEnd_DATE;
           SET @Ls_XmlTextIn_TEXT ='<INPUTPARAMETERS><REPORT_BEGIN_DATE>' + CONVERT(VARCHAR, @Ld_BeginDateYear_DATE, 101) --mm/dd/yyyy 
									+ '</REPORT_BEGIN_DATE>' + '<REPORT_END_DATE>' + CONVERT(VARCHAR, @Ld_EndDateYear_DATE, 101) --mm/dd/yyyy  
									+ '</REPORT_END_DATE>' + '<ORDERED_MONTHLY_SUPPORT_AMNT>' + ISNULL (CAST(@Ln_OrderedMonthlySup_AMNT AS VARCHAR), '') + '</ORDERED_MONTHLY_SUPPORT_AMNT>' + '<ORDERED_MONTHLY_ARREARS_AMNT>' + ISNULL (CAST(@Ln_OrderedMonthlyArrears_AMNT AS VARCHAR), '') + '</ORDERED_MONTHLY_ARREARS_AMNT>' + '<ARREARS_BEGIN_DATE_AMNT>' + ISNULL (CAST(@Ln_ArrearBegin_AMNT AS VARCHAR), '') + '</ARREARS_BEGIN_DATE_AMNT>' + '<CURRENT_SUPPORT_DUE_AMNT>' + ISNULL (CAST(@Ln_CurrentSupportDue_AMNT AS VARCHAR), '') + '</CURRENT_SUPPORT_DUE_AMNT>' + '<CHILD_SUPPORT_PAID_AMNT>' + ISNULL (CAST(@Ln_ChildSupportPaid_AMNT AS VARCHAR), '') + '</CHILD_SUPPORT_PAID_AMNT>' + '<ADJUSTMENTS_AMNT>' + ISNULL (CAST(@Ln_Adjustments_AMNT AS VARCHAR), '') + '</ADJUSTMENTS_AMNT>' + '<ARREARS_END_DATE_AMNT>' + ISNULL (CAST(@Ln_ArrearEnd_AMNT AS VARCHAR), '') + '</ARREARS_END_DATE_AMNT></INPUTPARAMETERS>';
           
           /*
           Common routine (BATCH_COMMON$SP_INSERT_ACTIVITY) inserts records into Notice Print Request (NMRQ_Y1) table.  
           If there is any error while calling notice generation routine, write error code into BATE_Y1 table
           
           If NCP is passed to insert activity for both CP and NCP Notice will be generated
           */
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - GENERATE NOTICE FOR NCP ';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Lc_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorGeoys_CODE, '') + ', ReasonStatus_CODE = ' + '' + ', Subsystem_CODE = ' + ISNULL(@Lc_SubSystemFm_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Notice_ID = ' + ISNULL(@Lc_NoticeFin07_ID, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Xml_TEXT = ' + ISNULL(@Ls_XmlTextIn_TEXT, '') + ', ScheduleListMemberMci_ID = ' + ISNULL(CAST(@Lc_MemberMci_IDNO AS VARCHAR), '');

           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_CaseCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Lc_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorGeoys_CODE,
            @Ac_ReasonStatus_CODE        = '',
            @Ac_Subsystem_CODE           = @Lc_SubSystemFm_CODE,
            @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
            @Ad_Run_DATE                 = @Ld_Run_DATE,
            @Ac_Notice_ID                = @Lc_NoticeFin07_ID,
            @Ac_Job_ID                   = @Lc_Job_ID,
            @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            @As_Xml_TEXT                 = @Ls_XmlTextIn_TEXT,
            @As_ScheduleListMemberMci_ID = @Lc_MemberMci_IDNO,
            @Ac_TypeReference_CODE		 = @Lc_TypeReference_CODE,		
            @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

           -- If Recipient address is missing then no need to generate FIN-07 Annual Summary of Account notice i.e) skip the notice generation
           IF @Lc_Msg_CODE <> @Lc_ErrorE1001_CODE
            BEGIN
             IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;

               RAISERROR (50001,16,1);
              END
             ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
              BEGIN
               SET @Lc_BateError_CODE = @Lc_Msg_CODE;

               RAISERROR (50001,16,1);
              END
            END
          END
        END
      END TRY

      BEGIN CATCH
       -- Rollback the transaction if its not Committed.
       IF XACT_STATE() = 1
        BEGIN
         ROLLBACK TRANSACTION GEN_ANNUAL_STMNT_SAVE
        END
       ELSE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

         RAISERROR( 50001,16,1);
        END

       -- Check if cursor is open close and deallocate it
       IF CURSOR_STATUS('LOCAL', 'Member_CUR') IN (0, 1)
        BEGIN
         CLOSE Member_CUR;

         DEALLOCATE Member_CUR;
        END

       SET @Ln_Error_NUMB = ERROR_NUMBER();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE();

       IF @Ln_Error_NUMB <> 50001
        BEGIN
         SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE ();
        END

       EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
        @As_Procedure_NAME        = @Ls_Procedure_NAME,
        @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
        @As_Sql_TEXT              = @Ls_Sql_TEXT,
        @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
        @An_Error_NUMB            = @Ln_Error_NUMB,
        @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_Cursor_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       -- Checking if error type is 'E' then increment the threshold count
       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END CATCH

      SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

      -- If the commit frequency is attained, the following is done.Reset the commit count, Commit the transaction completed until now.	
      IF @Ln_CommitFreq_QNTY <> 0
         AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
        SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', RestartKey_TEXT = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR);

        EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
         @Ac_Job_ID                = @Lc_Job_ID,
         @Ad_Run_DATE              = @Ld_Run_DATE,
         @As_RestartKey_TEXT       = @Ln_CaseCur_Case_IDNO,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR(50001,16,1);
         END

        COMMIT TRANSACTION GEN_ANNUAL_STMNT;

        SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;

        BEGIN TRANSACTION GEN_ANNUAL_STMNT;

        SET @Ln_CommitFreq_QNTY = 0;
       END

      IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
       BEGIN
        COMMIT TRANSACTION GEN_ANNUAL_STMNT;

        SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;
        SET @Ls_ErrorMessage_TEXT = 'REACHED THRESHOLD';

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Case_CUR - 2';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_CaseCur_Case_IDNO AS VARCHAR);

      FETCH NEXT FROM Case_CUR INTO @Ln_CaseCur_Case_IDNO;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE Case_CUR;

   DEALLOCATE Case_CUR;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Ls_CursorLoc_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + '' + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = '',
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = '',
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   COMMIT TRANSACTION GEN_ANNUAL_STMNT;
  END TRY

  BEGIN CATCH
   -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION GEN_ANNUAL_STMNT;
    END

   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS('LOCAL', 'Case_CUR') IN (0, 1)
    BEGIN
     CLOSE Case_CUR;

     DEALLOCATE Case_CUR;
    END

   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS('LOCAL', 'Member_CUR') IN (0, 1)
    BEGIN
     CLOSE Member_CUR;

     DEALLOCATE Member_CUR;
    END

   -- Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ln_ErrorLine_NUMB = ERROR_LINE();
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();
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
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
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
