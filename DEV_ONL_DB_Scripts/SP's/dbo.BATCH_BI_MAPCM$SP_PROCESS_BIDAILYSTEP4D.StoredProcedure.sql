/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4D]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4D
Programmer Name	:	IMP Team.
Description		:	This process loads data from staging tables into BPCAS4_Y1.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDAILYSTEP4D]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY                      INT = 0,
          @Lc_Space_TEXT                         CHAR(1) = ' ',
          @Lc_CaseMemberActive_CODE              CHAR(1) = 'A',
          @Lc_StatusAbnormalend_CODE             CHAR(1) = 'A',
          @Lc_No_TEXT                            CHAR(1) = 'N',
          @Lc_Yes_TEXT                           CHAR(1) = 'Y',
          @Lc_RelationshipCaseDp_TEXT            CHAR(1) = 'D',
          @Lc_StatusCaseMemberActive_CODE        CHAR(1) = 'A',
          @Lc_RelationshipCaseNcp_TEXT           CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_TEXT     CHAR(1) = 'P',
          @Lc_CaseStatusOpen_CODE                CHAR(1) = 'O',
          @Lc_CaseStatusClosed_CODE              CHAR(1) = 'C',
          @Lc_Success_CODE                       CHAR(1) = 'S',
          @Lc_Failed_CODE                        CHAR(1) = 'F',
          @Lc_InsOrderedC1_TEXT                  CHAR(1) = 'C',
          @Lc_InsOrderedA1_TEXT                  CHAR(1) = 'A',
          @Lc_InsOrderedD1_TEXT                  CHAR(1) = 'D',
          @Lc_InsOrderedB1_TEXT                  CHAR(1) = 'B',
          @Lc_InsOrderedO1_TEXT                  CHAR(1) = 'O',
          @Lc_InsOrderedU1_TEXT                  CHAR(1) = 'U',
          @Lc_InsOrderedN1_TEXT                  CHAR(1) = 'N',
          @Lc_TypeEstablishO1_CODE               CHAR(1) = 'O',
          @Lc_TypeEstablishP1_CODE               CHAR(1) = 'P',
          @Lc_TypeEstablishS1_CODE               CHAR(1) = 'S',
          @Lc_ActionB1_TEXT                      CHAR(1) = 'B',
          @Lc_ActionP1_TEXT                      CHAR(1) = 'P',
          @Lc_ToBeEstablished_CODE               CHAR(1) = 'T',
          @Lc_Pending_TEXT						 CHAR(1) = 'P',
          @Lc_Partial_TEXT						 CHAR(1) = 'P',
          @Lc_Month_CODE						 CHAR(2) = 'MM',
          @Lc_StateInState_CODE                  CHAR(2) = 'DE',
          @Lc_ReceiptSrcDirectPaymentCredit_CODE CHAR(2) = 'CD',
          @Lc_County000_TEXT                     CHAR(3) = '000',
          @Lc_TableStat_IDNO                     CHAR(4) = 'STAT',
          @Lc_TableSubStat_IDNO                  CHAR(4) = 'STAT',
          @Lc_BatchRunUser_TEXT                  CHAR(5) = 'BATCH',
          @Lc_BateError_CODE                     CHAR(5) = 'E0944',
          @Lc_JobStep4d_IDNO                     CHAR(7) = 'DEB1390',
          @Lc_Successful_TEXT                    CHAR(10) = 'SUCCESSFUL',
          @Lc_Process_NAME                       CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME                     VARCHAR(50) = 'SP_PROCESS_BIDAILYSTEP4D',
          @Ld_Highdate_DATE                      DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                    NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY          NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY  NUMERIC(5),
          @Ln_PreviousMsoMonthSupport_NUMB NUMERIC(7),
          @Ln_Error_NUMB                   NUMERIC(11),
          @Ln_ErrorLine_NUMB               NUMERIC(11),
          @Lc_Msg_CODE                     CHAR(1),
          @Ls_Sql_TEXT                     VARCHAR(100),
          @Ls_Sqldata_TEXT                 VARCHAR(1000),
          @Ls_ErrorMessage_TEXT            VARCHAR(4000),
          @Ls_DescriptionError_TEXT        VARCHAR(4000),
          @Ls_BateRecord_TEXT              VARCHAR(4000),
          @Ld_Maxdate_DATE                 DATE,
          @Ld_Mindate_DATE                 DATE,
          @Ld_Begin_DATE                   DATE,
          @Ld_PreviousMsoMaxdate_DATE      DATE,
          @Ld_Run_DATE                     DATE,
          @Ld_LastRun_DATE                 DATE,
          @Ld_Start_DATE                   DATETIME2;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4d_IDNO, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_JobStep4d_IDNO,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_Failed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE CHECK';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(DAY, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SELECT @Ld_Maxdate_DATE = MAX(a.End_DATE),
          @Ld_Mindate_DATE = MIN(a.End_DATE),
          @Ld_Begin_DATE = MIN(a.Begin_DATE)
     FROM BPDATE_Y1 a;

   SET @Ls_Sql_TEXT = 'MAX OF PREVIOUS MSO DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4d_IDNO, '');

   SELECT @Ld_PreviousMsoMaxdate_DATE = MAX(a.End_DATE)
     FROM BPDATE_Y1 a
    WHERE a.End_DATE <= @Ld_Run_DATE;

   SET @Ln_PreviousMsoMonthSupport_NUMB = SUBSTRING(CONVERT(VARCHAR(6), @Ld_PreviousMsoMaxdate_DATE, 112), 1, 6);

   BEGIN TRANSACTION STEP4D;

   SET @Ls_DescriptionError_TEXT = 'STEP:1 UPDATING BPCAS4_Y1';
   SET @Ls_Sql_TEXT = 'DELETE FROM BPCAS4_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4d_IDNO, '');

   DELETE FROM BPCAS4_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPCAS4_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4d_IDNO, '');

   INSERT BPCAS4_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           DelinquencyPeriod_QNTY,
           Collection_AMNT,
           Mso_CODE,
           Collection_INDC,
           MonthsMso_QNTY,
           MonthsNoMso_QNTY,
           MonthsCollection_QNTY,
           MonthsNoCollection_QNTY,
           DirectPay_AMNT,
           NcpIncome_AMNT,
           MemberOther_ID,
           LastOther_NAME,
           FirstOther_NAME,
           DurationNoMailAddr_QNTY,
           DurationNoResiAddr_QNTY,
           DurationNoCpMailAddr_QNTY,
           DurationNoCpResiAddr_QNTY,
           WokerSubordinate_CODE,
           CpOrdered_CODE,
           NcpOrdered_CODE,
           BothOrdered_CODE,
           BothOrderedConditional_CODE,
           CpOnlyConditional_CODE,
           NcpOnlyConditional_CODE,
           Notordered_CODE,
           ControllingOrdDe_CODE,
           ControllingOrdOt_CODE,
           ReliefsRequested_TEXT,
           ReliefsOrdered_TEXT,
           TypeEstablish_CODE,
           NotSatisfied_CODE,
           NotSatisfiedPartialCol_CODE,
           NotSatisfiedNoCol_CODE,
           Satisfied_CODE,
           Casebar_NUMB,
           RangeObligationPeriod_QNTY,
           ObligationPeriod_QNTY,
           Mso_AMNT,
           CpArrear_AMNT,
           IvaArrear_AMNT,
           TotalOwed_AMNT,
           TotalPaid_AMNT,
           DisbursementHold_AMNT,
           CpRecoupBal_AMNT,
           Ura_AMNT,
           ChildSupport_CODE,
           MedicalSupport_CODE,
           SpousalSupport_CODE,
           CashMedical_CODE,
           Alimony_CODE,
           GeneticTest_CODE,
           InterestOnChildSupport_CODE,
           InterestOnMedicalSupp_CODE,
           InterestOnSpousalSupp_CODE,
           InterestOnCashMedical_CODE,
           InterestOnAlimony_CODE,
           StatusObligation_CODE,
           EndObligationMax_DATE,
           OrderEstablished_DATE,
           UedbStrtComp_DATE,
           SourceReceiptsReceived_TEXT,
           NcpEmploymentAddrGood_CODE,
           NcpEmploymentAddrBad_CODE,
           NcpEmploymentAddrPend_CODE,
           DescriptionLicense_TEXT)
   SELECT DISTINCT
          a.Case_IDNO,
          a.MemberMci_IDNO,
          CASE
           WHEN r.Case_IDNO IS NOT NULL
            THEN
            CASE
             WHEN r.DelinquencyPeriod_QNTY > 12
              THEN 13
             ELSE r.DelinquencyPeriod_QNTY
            END
           ELSE DATEDIFF(MM, @Ld_Mindate_DATE, @Ld_Maxdate_DATE)
          END AS DelinquencyPeriod_QNTY,
          ISNULL(r.Collection_AMNT, @Ln_Zero_NUMB) AS Collection_AMNT,
          ISNULL(delinq.Mso_CODE, @Lc_No_TEXT) AS Mso_CODE,
          ISNULL(delinq.Collection_INDC, @Lc_No_TEXT) AS Collection_INDC,
          CASE
           WHEN delinq2.MaxMsoNo_DATE IS NOT NULL
            THEN dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF(@Lc_Month_CODE, delinq2.MaxMsoNo_DATE, @Ld_PreviousMsoMaxdate_DATE) 
           WHEN delinq2.MinMsoYes_DATE IS NOT NULL
            THEN (dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF(@Lc_Month_CODE, delinq2.MinMsoYes_DATE, @Ld_PreviousMsoMaxdate_DATE) + 1)
           ELSE @Ln_Zero_NUMB
          END AS MonthsMso_QNTY,
          CASE
           WHEN delinq2.MaxMsoYes_DATE IS NOT NULL
            THEN dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF(@Lc_Month_CODE, delinq2.MaxMsoYes_DATE, @Ld_PreviousMsoMaxdate_DATE)
           WHEN delinq2.MinMsoNo_DATE IS NOT NULL
            THEN (dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF(@Lc_Month_CODE, delinq2.MinMsoNo_DATE, @Ld_PreviousMsoMaxdate_DATE) + 1)
           ELSE @Ln_Zero_NUMB
          END AS MonthsNoMso_QNTY,
          CASE
           WHEN delinq2.MaxCollNo_DATE IS NOT NULL
            THEN dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF(@Lc_Month_CODE, delinq2.MaxCollNo_DATE, @Ld_PreviousMsoMaxdate_DATE)
           WHEN delinq2.MinCollYes_DATE IS NOT NULL
            THEN (dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF(@Lc_Month_CODE, delinq2.MinCollYes_DATE, @Ld_PreviousMsoMaxdate_DATE) + 1)
           ELSE @Ln_Zero_NUMB
          END AS MonthsCollection_QNTY,
          CASE
           WHEN delinq2.MaxCollYes_DATE IS NOT NULL
            THEN dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF(@Lc_Month_CODE, delinq2.MaxCollYes_DATE, @Ld_PreviousMsoMaxdate_DATE)
           WHEN delinq2.MinCollNo_DATE IS NOT NULL
            THEN (dbo.BATCH_COMMON$SF_CALCULATE_DATE_DIFF(@Lc_Month_CODE, delinq2.MinCollNo_DATE, @Ld_PreviousMsoMaxdate_DATE) + 1)
           ELSE @Ln_Zero_NUMB
          END AS MonthsNoCollection_QNTY,
          ISNULL(r.DirectPay_AMNT, @Ln_Zero_NUMB) AS DirectPay_AMNT,
          @Ln_Zero_NUMB AS NcpIncome_AMNT,
          @Lc_Space_TEXT AS MemberOther_ID,
          @Lc_Space_TEXT AS LastOther_NAME,
          @Lc_Space_TEXT AS FirstOther_NAME,
          @Ln_Zero_NUMB AS DurationNoMailAddr_QNTY,
          @Ln_Zero_NUMB AS DurationNoResiAddr_QNTY,
          @Ln_Zero_NUMB AS DurationNoCpMailAddr_QNTY,
          @Ln_Zero_NUMB AS DurationNoCpResiAddr_QNTY,
          @Ln_Zero_NUMB AS WokerSubordinate_CODE,
          ISNULL(order_stg.CpOrdered_CODE, @Ln_Zero_NUMB) AS CpOrdered_CODE,
          ISNULL(order_stg.NcpOrdered_CODE, @Ln_Zero_NUMB) AS NcpOrdered_CODE,
          ISNULL(order_stg.BothOrdered_CODE, @Ln_Zero_NUMB) AS BothOrdered_CODE,
          ISNULL(order_stg.BothOrderedConditional_CODE, @Ln_Zero_NUMB) AS BothOrderedConditional_CODE,
          ISNULL(order_stg.CpOnlyConditional_CODE, @Ln_Zero_NUMB) AS CpOnlyConditional_CODE,
          ISNULL(order_stg.NcpOnlyConditional_CODE, @Ln_Zero_NUMB) AS NcpOnlyConditional_CODE,
          ISNULL(order_stg.Notordered_CODE, @Ln_Zero_NUMB) AS Notordered_CODE,
          ISNULL(order_stg.ControllingOrdDe_CODE, @Ln_Zero_NUMB) AS ControllingOrdDe_CODE,
          ISNULL(order_stg.ControllingOrdOt_CODE, @Ln_Zero_NUMB) AS ControllingOrdOt_CODE,
          @Lc_Space_TEXT AS ReliefsRequested_TEXT,
          @Lc_Space_TEXT AS ReliefsOrdered_TEXT,
          ISNULL((CASE
                   WHEN EXISTS (SELECT 1
                                  FROM SORD_Y1 fci
                                 WHERE fci.Case_IDNO = a.Case_IDNO)
                        AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                    THEN @Lc_TypeEstablishO1_CODE                   
                   WHEN NOT EXISTS (SELECT 1
                                      FROM SORD_Y1 fci
                                     WHERE fci.Case_IDNO = a.Case_IDNO)
                                       AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                    THEN @Lc_TypeEstablishS1_CODE
                  END), @Lc_Space_TEXT) AS TypeEstablish_CODE,
          CASE 
           WHEN delinq.Mso_CODE = @Lc_No_TEXT
            AND (ISNULL(ob.TotalObligations_CODE, 0) > 0
                  or a.ArrearsReg_AMNT > 0)
            THEN 1
           ELSE 0
          END AS NotSatisfied_CODE,
          CASE 
           WHEN delinq.Mso_CODE = @Lc_No_TEXT
            AND (ISNULL(ob.TotalObligations_CODE, 0) > 0
                  or a.ArrearsReg_AMNT > 0)
            AND delinq.Collection_INDC =  @Lc_Partial_TEXT
            THEN 1
           ELSE 0
          END AS NotSatisfiedPartialCol_CODE,
          CASE 
           WHEN delinq.Mso_CODE = @Lc_No_TEXT
            AND (ISNULL(ob.TotalObligations_CODE, 0) > 0
                  or a.ArrearsReg_AMNT > 0)
            AND delinq.Collection_INDC =  @Lc_No_TEXT
            THEN 1
           ELSE 0
          END AS NotSatisfiedNoCol_CODE,
          CASE 
           WHEN delinq.Mso_CODE = @Lc_Yes_TEXT
            AND (ISNULL(ob.TotalObligations_CODE, 0) > 0
                  or a.ArrearsReg_AMNT > 0)
            THEN 1
           ELSE 0
          END AS Satisfied_CODE,
          CASE
           WHEN ob.ExistsObleSord_INDC IS NULL
            THEN 1
           WHEN ob.TotalObligations_CODE > @Ln_Zero_NUMB
                AND ISNULL(r.Collection_AMNT, @Ln_Zero_NUMB) = @Ln_Zero_NUMB
                AND a.ArrearsReg_AMNT > @Ln_Zero_NUMB
            THEN 2
           WHEN a.ArrearsReg_AMNT > @Ln_Zero_NUMB
                AND r.Collection_AMNT > @Ln_Zero_NUMB
                AND ob.TotalObligations_CODE > @Ln_Zero_NUMB
            THEN 3
           WHEN a.ArrearsReg_AMNT > @Ln_Zero_NUMB
                AND ISNULL(r.Collection_AMNT, @Ln_Zero_NUMB) = @Ln_Zero_NUMB
                AND ob.TotalObligations_CODE = @Ln_Zero_NUMB
            THEN 4
           WHEN a.ArrearsReg_AMNT > @Ln_Zero_NUMB
                AND r.Collection_AMNT > @Ln_Zero_NUMB
                AND ob.TotalObligations_CODE = @Ln_Zero_NUMB
            THEN 5
           WHEN a.ArrearsReg_AMNT <= @Ln_Zero_NUMB
                AND ob.TotalObligations_CODE > @Ln_Zero_NUMB
            THEN 6
           WHEN a.ArrearsReg_AMNT <= @Ln_Zero_NUMB
                AND ob.TotalObligations_CODE = @Ln_Zero_NUMB
            THEN 7
          END AS Casebar_NUMB,
          ISNULL(CASE
                  WHEN ABS(DATEDIFF(MM, @Ld_Run_DATE, ob.MinBeginObligation_DATE)) BETWEEN @Ln_Zero_NUMB AND 3                         
                   THEN 1
                  WHEN ABS(DATEDIFF(MM, @Ld_Run_DATE, ob.MinBeginObligation_DATE)) BETWEEN 4 AND 6
                   THEN 2
                  WHEN ABS(DATEDIFF(MM, @Ld_Run_DATE, ob.MinBeginObligation_DATE)) BETWEEN 7 AND 9
                   THEN 3
                  WHEN ABS(DATEDIFF(MM, @Ld_Run_DATE, ob.MinBeginObligation_DATE)) BETWEEN 10 AND 12
                   THEN 4
                  WHEN ABS(DATEDIFF(MM, @Ld_Run_DATE, ob.MinBeginObligation_DATE)) BETWEEN 13 AND 24
                   THEN 5
                  WHEN ABS(DATEDIFF(MM, @Ld_Run_DATE, ob.MinBeginObligation_DATE)) BETWEEN 25 AND 36
                   THEN 6
                  WHEN ABS(DATEDIFF(MM, @Ld_Run_DATE, ob.MinBeginObligation_DATE)) > 36
                   THEN 7
                 END, @Ln_Zero_NUMB) AS RangeObligationPeriod_QNTY,
          ISNULL(DATEDIFF(MM, @Ld_Run_DATE, ob.MinBeginObligation_DATE), @Ln_Zero_NUMB) AS ObligationPeriod_QNTY,
          @Ln_Zero_NUMB AS Mso_AMNT,
          @Ln_Zero_NUMB AS CpArrear_AMNT,
          @Ln_Zero_NUMB AS IvaArrear_AMNT,
          @Ln_Zero_NUMB AS TotalOwed_AMNT,
          @Ln_Zero_NUMB AS TotalPaid_AMNT,
          @Ln_Zero_NUMB AS DisbursementHold_AMNT,
          @Ln_Zero_NUMB AS CpRecoupBal_AMNT,
          @Ln_Zero_NUMB AS Ura_AMNT,
          @Ln_Zero_NUMB AS ChildSupport_CODE,
          @Ln_Zero_NUMB AS MedicalSupport_CODE,
          @Ln_Zero_NUMB AS SpousalSupport_CODE,
          @Ln_Zero_NUMB AS CashMedical_CODE,
          @Ln_Zero_NUMB AS Alimony_CODE,
          @Ln_Zero_NUMB AS GeneticTest_CODE,
          @Ln_Zero_NUMB AS InterestOnChildSupport_CODE,
          @Ln_Zero_NUMB AS InterestOnMedicalSupp_CODE,
          @Ln_Zero_NUMB AS InterestOnSpousalSupp_CODE,
          @Ln_Zero_NUMB AS InterestOnCashMedical_CODE,
          @Ln_Zero_NUMB AS InterestOnAlimony_CODE,
          @Ln_Zero_NUMB AS StatusObligation_CODE,
          @Lc_Space_TEXT AS EndObligationMax_DATE,
          @Lc_Space_TEXT AS OrderEstablished_DATE,
          @Lc_Space_TEXT AS UedbStrtComp_DATE,
          @Lc_Space_TEXT AS SourceReceiptsReceived_TEXT,
          ISNULL(ehis_stg.NcpEmploymentAddrGood_CODE, @Ln_Zero_NUMB) AS NcpEmploymentAddrGood_CODE,
          ISNULL(ehis_stg.NcpEmploymentAddrBad_CODE, @Ln_Zero_NUMB) AS NcpEmploymentAddrBad_CODE,
          ISNULL(ehis_stg.NcpEmploymentAddrPend_CODE, @Ln_Zero_NUMB) AS NcpEmploymentAddrPend_CODE,
          @Lc_Space_TEXT AS DescriptionLicense_TEXT
     FROM (SELECT c.MemberMci_IDNO,  
                  e.*
             FROM ENSD_Y1 e, 
                  CMEM_Y1 c
            WHERE e.Case_IDNO = c.Case_IDNO
              AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
              AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE) AS a
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.NcpEmploymentAddrGood_CODE AS NUMERIC(1))) AS NcpEmploymentAddrGood_CODE,
                                  MAX(CAST(fci.NcpEmploymentAddrBad_CODE AS NUMERIC(1))) AS NcpEmploymentAddrBad_CODE,
                                  MAX(CAST(fci.NcpEmploymentAddrPend_CODE AS NUMERIC(1))) AS NcpEmploymentAddrPend_CODE
                             FROM (SELECT z.Case_IDNO,
                                          CASE
                                           WHEN z.Action_CODE = @Lc_Yes_TEXT
                                                AND z.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND z.EhisEnd_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS NcpEmploymentAddrGood_CODE,
                                          CASE
                                           WHEN z.Action_CODE = @Lc_ActionB1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS NcpEmploymentAddrBad_CODE,
                                          CASE
                                           WHEN z.Action_CODE = @Lc_ActionP1_TEXT
                                                AND z.EndOfMonth_DATE = @Ld_Maxdate_DATE
                                                AND z.EhisEnd_DATE > @Ld_Run_DATE
                                            THEN 1
                                           ELSE 0
                                          END AS NcpEmploymentAddrPend_CODE
                                     FROM BPEHIS_Y1 z) AS fci
                            GROUP BY fci.Case_IDNO) AS ehis_stg
           ON a.Case_IDNO = ehis_stg.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  fci.EndOfMonth_DATE,
                                  CAST(ABS(DATEDIFF(MM, fci.EndOfMonth_DATE, @Ld_Maxdate_DATE)) AS NUMERIC(9)) AS DelinquencyPeriod_QNTY,
                                  fci.Collection_AMNT,
                                  fci.DirectPay_AMNT
                             FROM (SELECT z.Case_IDNO,
                                          z.EndOfMonth_DATE,
                                          z.Receipt_AMNT,
                                          z.OrderSeq_NUMB,
                                          z.ObligationSeq_NUMB,
                                          z.Batch_DATE,
                                          z.SourceBatch_CODE,
                                          z.Batch_NUMB,
                                          z.SeqReceipt_NUMB,
                                          z.SourceReceipt_CODE,
                                          z.PayorMCI_IDNO,
                                          z.ToDistribute_AMNT,
                                          z.StatusReceipt_CODE,
                                          z.Receipt_DATE,
                                          ROW_NUMBER() OVER(PARTITION BY z.Case_IDNO ORDER BY z.EndOfMonth_DATE DESC) AS rnm,
                                          SUM(z.Receipt_AMNT) OVER(PARTITION BY z.Case_IDNO, z.EndOfMonth_DATE) AS Collection_AMNT,
                                          (SUM(CASE
                                                WHEN z.SourceReceipt_CODE = @Lc_ReceiptSrcDirectPaymentCredit_CODE
                                                 THEN z.ToDistribute_AMNT
                                                ELSE 0
                                               END) OVER (PARTITION BY Case_IDNO)) AS DirectPay_AMNT
                                     FROM BPRCTH_Y1 z) AS fci
                            WHERE fci.rnm = 1) AS r
           ON a.Case_IDNO = r.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  MAX(CAST(fci.CpOrdered_CODE AS NUMERIC(1))) AS CpOrdered_CODE,
                                  MAX(CAST(fci.NcpOrdered_CODE AS NUMERIC(1))) AS NcpOrdered_CODE,
                                  MAX(CAST(fci.BothOrdered_CODE AS NUMERIC(1))) AS BothOrdered_CODE,
                                  MAX(CAST(fci.BothOrderedConditional_CODE AS NUMERIC(1))) AS BothOrderedConditional_CODE,
                                  MAX(CAST(fci.CpOnlyConditional_CODE AS NUMERIC(1))) AS CpOnlyConditional_CODE,
                                  MAX(CAST(fci.NcpOnlyConditional_CODE AS NUMERIC(1))) AS NcpOnlyConditional_CODE,
                                  MAX(CAST(fci.Notordered_CODE AS NUMERIC(1))) AS Notordered_CODE,
                                  MAX(CAST(fci.ControllingOrdDe_CODE AS NUMERIC(1))) AS ControllingOrdDe_CODE,
                                  MAX(CAST(fci.ControllingOrdOt_CODE AS NUMERIC(1))) AS ControllingOrdOt_CODE,
                                  MAX(CAST(fci.OrderSeq_NUMB AS NUMERIC(1))) AS OrderSeq_NUMB
                             FROM (SELECT x.Case_IDNO,
                                          CASE
                                           WHEN x.InsOrdered_CODE = @Lc_InsOrderedO1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS CpOrdered_CODE,
                                          CASE
                                           WHEN x.InsOrdered_CODE = @Lc_InsOrderedU1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS NcpOrdered_CODE,
                                          CASE
                                           WHEN x.InsOrdered_CODE = @Lc_InsOrderedD1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS BothOrdered_CODE,
                                          CASE
                                           WHEN x.InsOrdered_CODE = @Lc_InsOrderedB1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS BothOrderedConditional_CODE,
                                          CASE
                                           WHEN x.InsOrdered_CODE = @Lc_InsOrderedC1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS CpOnlyConditional_CODE,
                                          CASE
                                           WHEN x.InsOrdered_CODE = @Lc_InsOrderedA1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS NcpOnlyConditional_CODE,
                                          CASE
                                           WHEN x.InsOrdered_CODE = @Lc_InsOrderedN1_TEXT
                                            THEN 1
                                           ELSE 0
                                          END AS Notordered_CODE,
                                          CASE
                                           WHEN x.StateControl_CODE = @Lc_StateInState_CODE
                                            THEN 1
                                           ELSE 0
                                          END AS ControllingOrdDe_CODE,
                                          CASE
                                           WHEN x.StateControl_CODE != @Lc_StateInState_CODE
                                                AND x.StateControl_CODE IN (SELECT a.Value_CODE
                                                                              FROM REFM_Y1 a
                                                                             WHERE a.Table_ID = @Lc_TableStat_IDNO
                                                                               AND a.TableSub_ID = @Lc_TableSubStat_IDNO)
                                            THEN 1
                                           ELSE 0
                                          END AS ControllingOrdOt_CODE,
                                          x.OrderSeq_NUMB AS OrderSeq_NUMB
                                     FROM BPSORD_Y1 x) AS fci
                            GROUP BY fci.Case_IDNO) AS order_stg
           ON a.Case_IDNO = order_stg.Case_IDNO
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  fci.Mso_CODE,
                                  fci.Collection_INDC
                             FROM (SELECT z.Case_IDNO,
                                          z.SupportYearMonth_NUMB,
                                          ROW_NUMBER() OVER(PARTITION BY z.Case_IDNO ORDER BY z.SupportYearMonth_NUMB DESC) AS rnm,
                                          z.Mso_CODE,
                                          z.Collection_INDC
                                     FROM BPDLNC_Y1 z
                                    WHERE z.SupportYearMonth_NUMB = @Ln_PreviousMsoMonthSupport_NUMB) AS fci
                            WHERE fci.rnm = 1) AS delinq
           ON a.Case_IDNO = delinq.Case_IDNO
          LEFT OUTER JOIN (SELECT mm.Case_IDNO,
                                  MAX(mm.MsoNo_DATE) AS MaxMsoNo_DATE,
                                  MIN(mm.MsoYes_DATE) AS MinMsoYes_DATE,
                                  MIN(mm.MsoNo_DATE) AS MinMsoNo_DATE,
                                  MAX(mm.MsoYes_DATE) AS MaxMsoYes_DATE,
                                  MAX(mm.CollYes_DATE) AS MaxCollYes_DATE,
                                  MAX(mm.CollNo_DATE) AS MaxCollNo_DATE,
                                  MIN(mm.CollYes_DATE) AS MinCollYes_DATE,
                                  MIN(mm.CollNo_DATE) AS MinCollNo_DATE
                             FROM (SELECT z.Case_IDNO,
                                          CASE
                                           WHEN z.Mso_CODE = @Lc_No_TEXT
                                            THEN y.End_DATE
                                          END AS MsoNo_DATE,
                                          CASE
                                           WHEN z.Mso_CODE = @Lc_Yes_TEXT
                                            THEN y.End_DATE
                                          END AS MsoYes_DATE,
                                          CASE
                                           WHEN z.Collection_INDC IN (@Lc_Yes_TEXT, @Lc_Pending_TEXT)
                                            THEN y.End_DATE
                                          END AS CollYes_DATE,
                                          CASE
                                           WHEN z.Collection_INDC = @Lc_No_TEXT
                                            THEN y.End_DATE
                                          END AS CollNo_DATE
                                     FROM BPDLNC_Y1 z,
                                          BPDATE_Y1 y
                                    WHERE z.SupportYearMonth_NUMB = y.SupportYearMonth_NUMB
                                      AND y.End_DATE <= @Ld_Run_DATE) AS mm
                            GROUP BY mm.Case_IDNO) AS delinq2
           ON a.Case_IDNO = delinq2.Case_IDNO
          LEFT OUTER JOIN (SELECT b.Case_IDNO,
                                  SUM(CASE
                                       WHEN @Ld_Run_DATE BETWEEN b.BeginObligation_DATE AND b.EndObligation_DATE
                                            AND b.Periodic_AMNT > 0
                                        THEN 1
                                       ELSE 0
                                      END) AS TotalObligations_CODE,
                                  MIN(b.BeginObligation_DATE) AS MinBeginObligation_DATE,
                                  MIN(CASE
                                       WHEN s.Case_IDNO IS NOT NULL
                                        THEN @Lc_Yes_TEXT
                                       ELSE @Lc_No_TEXT
                                      END) AS ExistsObleSord_INDC
                             FROM OBLE_Y1 b
                                  LEFT OUTER JOIN SORD_Y1 s
                                   ON b.Case_IDNO = s.Case_IDNO
                                      AND b.OrderSeq_NUMB = s.OrderSeq_NUMB
                                      AND s.EndValidity_DATE = @Ld_Highdate_DATE
                            WHERE b.EndValidity_DATE = @Ld_Highdate_DATE
                            GROUP BY b.Case_IDNO) AS ob
           ON a.Case_IDNO = ob.Case_IDNO
          LEFT OUTER JOIN (SELECT b.Case_IDNO,
                                  @Lc_No_TEXT AS PaternityEst_INDC
                             FROM CMEM_Y1 b,
                                  MPAT_Y1 c
                            WHERE b.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                              AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                              AND c.MemberMci_IDNO = b.MemberMci_IDNO
                              AND c.PaternityEst_INDC = @Lc_No_TEXT
                            GROUP BY b.Case_IDNO) AS dep
           ON a.Case_IDNO = dep.Case_IDNO
    WHERE (a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
            OR (a.StatusCase_CODE = @Lc_CaseStatusClosed_CODE
                AND a.StatusCurrent_DATE >= @Ld_Begin_DATE))
      AND a.County_IDNO <> @Lc_County000_TEXT;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT BPCAS4_Y1 FAILED';
     SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_JobStep4d_IDNO,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_Space_TEXT,
      @An_Line_NUMB                = @Li_RowCount_QNTY,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   COMMIT TRANSACTION STEP4D;

   BEGIN TRANSACTION STEP4D;

   SET @Ls_Sql_TEXT = 'UPDATE BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_JobStep4d_IDNO + ', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Lc_Space_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Space_TEXT + ', Status_CODE = ' + @Lc_Success_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_JobStep4d_IDNO,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_Success_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'UPDATE PARM_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_JobStep4d_IDNO, '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_JobStep4d_IDNO,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_Failed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   COMMIT TRANSACTION STEP4D;
  END TRY

  BEGIN CATCH
   BEGIN
    SELECT @Ls_Sql_TEXT;

    IF @@TRANCOUNT > 0
     BEGIN
      ROLLBACK TRANSACTION STEP4D;
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
     @Ac_Job_ID                    = @Lc_JobStep4d_IDNO,
     @As_Process_NAME              = @Lc_Process_NAME,
     @As_Procedure_NAME            = @Ls_Procedure_NAME,
     @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
     @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
     @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
     @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT,
     @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
     @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
     @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

    RAISERROR(@Ls_DescriptionError_TEXT,16,1);
   END
  END CATCH
 END 

GO
