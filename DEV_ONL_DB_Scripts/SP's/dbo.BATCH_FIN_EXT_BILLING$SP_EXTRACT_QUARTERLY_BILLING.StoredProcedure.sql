/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_BILLING$SP_EXTRACT_QUARTERLY_BILLING]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*------------------------------------------------------------------------------------------------------------------
 Procedure Name	    : BATCH_FIN_EXT_BILLING$SP_EXTRACT_QUARTERLY_BILLING
 Programmer Name	: IMP Team
 Description		: This batch process extracts data from the system, calculates the coupon level information,
					  generates the coupon file in PDF format .
 Frequency   		: 'Quaterly'
 Developed On  	    : 11/06/2011
 Called By   		: None
 Called On			: BATCH_FIN_EXT_BILLING$SP_CALCULATE_MONTH_SUPPORT 
  ------------------------------------------------------------------------------------------------------------------
 Modified By   :
 Modified On   :
 Version No    : 1.0
  ------------------------------------------------------------------------------------------------------------------
   */
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_BILLING$SP_EXTRACT_QUARTERLY_BILLING]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_NoOfDays60_NUMB                 NUMERIC(2)=60,
          @Li_BillingSuppression1510_NUMB     INT = 1510,
          @Li_DirectPayCredit1040_NUMB        INT = 1040,
          @Li_ReceiptReversed1250_NUMB        INT = 1250,
          @Li_ReceiptDistributed1820_NUMB     INT = 1820,
          @Lc_Space_TEXT                      CHAR(1) = ' ',
          @Lc_StatusReceiptRefunded_CODE      CHAR(1) = 'R',
          @Lc_StatusCaseMemberActive_CODE     CHAR(1) = 'A',
          @Lc_StatusReceiptOthpRefund_CODE    CHAR(1) = 'O',
          @Lc_No_INDC                         CHAR(1) = 'N',
          @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
          @Lc_TypeErrorE_CODE                 CHAR(1) = 'E',
          @Lc_TypeErrorInformation_CODE       CHAR(1) = 'I',
          @Lc_StatusFailed_CODE               CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
          @Lc_ActionOveride_CODE              CHAR(1) = 'O',
          @Lc_ActionSuppress_CODE             CHAR(1) = 'S',
          @Lc_RelationshipCaseNcp_TEXT        CHAR(1) = 'A',
          @Lc_RelationshipPutativeFather_TEXT CHAR(1) = 'P',
          @Lc_StatusCaseOpen_CODE             CHAR(1) = 'O',
          @Lc_TypeRecordOriginal_CODE         CHAR(1) = 'O',
          @Lc_CaseMemberStatusActive_CODE     CHAR(1) = 'A',
          @Lc_Yes_TEXT                        CHAR(1) = 'Y',
          @Lc_TypeCaseNonIvd_CODE             CHAR(1) = 'H',
          @Lc_RespondInitInternationalC_CODE  CHAR(1) = 'C',
          @Lc_RespondInitStateI_CODE          CHAR(1) = 'I',
          @Lc_RespondInitTribalT_CODE         CHAR(1) = 'T',
          @Lc_RespondInitInstateN_CODE        CHAR(1) = 'N',
          @Lc_RespondInitRespondIntY_CODE     CHAR(1) = 'Y',
          @Lc_RespondInitRespondStateR_CODE   CHAR(1) = 'R',
          @Lc_RespondInitRespondTribalS_CODE  CHAR(1) = 'S',
          @Lc_ZipSeprator_CODE                CHAR(1) = '-',
          @Lc_SourceReceiptWage_CODE          CHAR(2) = 'EW',
          @Lc_SourceReceiptUnemployment_CODE  CHAR(2) = 'UC',
          @Lc_SourceReceiptQdro_CODE          CHAR(2) = 'QR',
          @Lc_TypeDebtGeneticTest_CODE        CHAR(2) = 'GT',
          @Lc_TypeDebtNcpNSfFee_CODE          CHAR(2) = 'NF',
          @Lc_CountryUS_CODE                  CHAR(2) = 'US',
          @Lc_ImmediateIncomeWithholding_CODE CHAR(4) = 'IMIW',
          @Lc_Start_CODE                      CHAR(4) = 'STRT',
          @Lc_BateErrorUnknown_CODE           CHAR(5) = 'E1424',
          @Lc_NoRecordsToProcess_CODE         CHAR(5) = 'E0944',
          @Lc_ReasonErfso_CODE                CHAR(5) = 'ERFSO',
          @Lc_ReasonErfsm_CODE                CHAR(5) = 'ERFSM',
          @Lc_ReasonErfss_CODE                CHAR(5) = 'ERFSS',
          @Lc_Job_ID                          CHAR(7) = 'DEB7530',
          @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
          @Lc_Process_NAME                    CHAR(30) = 'BATCH_FIN_EXT_BILLING',
          @Lc_Procedure_NAME                  CHAR(30) = 'SP_EXTRACT_QUARTERLY_BILLING',
          @Lc_BatchRunUser_TEXT               CHAR(30) = 'BATCH',
          @Ld_High_DATE                       DATE = '12/31/9999',
          @Ld_Low_DATE                        DATE = '01/01/0001',
          @Ld_Start_DATE                      DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_QuaterMonthsCount_QNTY      NUMERIC(1) =0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) =0,
          @Ln_CommitFreq_QNTY             NUMERIC(5) =0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) =0,
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5) =0,
          @Ln_QuarterEndMonthSupport_NUMB NUMERIC(6) =0,
          @Ln_ProcessingMonthSupport_NUMB NUMERIC(6) =0,
          @Ln_Cursor_QNTY                 NUMERIC(10) =0,
          @Ln_RowCount_QNTY               NUMERIC(11) =0,
          @Ln_Error_NUMB                  NUMERIC(11)=0,
          @Ln_ErrorLine_NUMB              NUMERIC(11)=0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11) =0,
          @Ln_ExpectToPay_AMNT            NUMERIC(11, 2)=0,
          @Ln_FirstMonthExpectToPay_AMNT  NUMERIC(11, 2) =0,
          @Ln_SecondMonthExpectToPay_AMNT NUMERIC(11, 2) =0,
          @Ln_ThirdMonthExpectToPay_AMNT  NUMERIC(11, 2) =0,
          @Ln_MonthSupport_AMNT           NUMERIC(11, 2)=0,
          @Ln_FirstMonthSupport_AMNT      NUMERIC(11, 2)=0,
          @Ln_SecondMonthSupport_AMNT     NUMERIC(11, 2)=0,
          @Ln_ThirdMonthSupport_AMNT      NUMERIC(11, 2)=0,
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19)=0,
          @Li_FetchStatus_NUMB            SMALLINT,
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Error_CODE                  CHAR(5) = '',
          @Lc_BateError_CODE              CHAR(5),
          @Lc_Line3_ADDR                  CHAR(28),
          @Lc_Line2_ADDR                  CHAR(31),
          @Lc_Line1_ADDR                  CHAR(40),
          @Ls_Payor_NAME                  VARCHAR(48),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(80),
          @Ls_Sql_TEXT                    VARCHAR(100),
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000),
          @Ls_BateRecord_TEXT             VARCHAR(4000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_QuarterBegin_DATE           DATE,
          @Ld_QuarterEnd_DATE             DATE,
          @Ld_FirstMonthEnd_DATE          DATE,
          @Ld_SecondMonthEnd_DATE         DATE,
          @Ld_ThirdMonthEnd_DATE          DATE,
          @Ld_ProcessingMonthBegin_DATE   DATE,
          @Ld_BeginBill_DATE              DATE,
          @Ld_CurrentMonthBegin_DATE      DATE;
  DECLARE @Ln_NcpCur_Case_IDNO       NUMERIC(6),
          @Ln_NcpCur_MemberMci_IDNO  NUMERIC(10),
          @Lc_NcpCur_LastNcp_NAME    CHAR(20),
          @Lc_NcpCur_SuffixNcp_NAME  CHAR(4),
          @Lc_NcpCur_FirstNcp_NAME   CHAR(15),
          @Lc_NcpCur_MiNcp_NAME      CHAR(20),
          @Ls_NcpCur_Line1Ncp_ADDR   VARCHAR(50),
          @Ls_NcpCur_Line2Ncp_ADDR   VARCHAR(50),
          @Lc_NcpCur_CityNcp_ADDR    CHAR(28),
          @Lc_NcpCur_StateNcp_ADDR   CHAR(2),
          @Lc_NcpCur_ZipNcp_ADDR     CHAR(15),
          @Lc_NcpCur_CountryNcp_ADDR CHAR(2),
          @Ln_NcpCur_OrderSeq_NUMB   NUMERIC(2, 0),
          @Ln_NcpCur_Arrears_AMNT    NUMERIC(11, 2),
          @Lc_NcpCur_TypeOrder_CODE  CHAR(1);
  DECLARE @Ld_RcthCur_Transaction01_DATE     DATE,
          @Lc_RcthCur_TransactionType01_CODE CHAR(3),
          @Ln_RcthCur_Receipt01_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction02_DATE     DATE,
          @Lc_RcthCur_TransactionType02_CODE CHAR(3),
          @Ln_RcthCur_Receipt02_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction03_DATE     DATE,
          @Lc_RcthCur_TransactionType03_CODE CHAR(3),
          @Ln_RcthCur_Receipt03_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction04_DATE     DATE,
          @Lc_RcthCur_TransactionType04_CODE CHAR(3),
          @Ln_RcthCur_Receipt04_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction05_DATE     DATE,
          @Lc_RcthCur_TransactionType05_CODE CHAR(3),
          @Ln_RcthCur_Receipt05_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction06_DATE     DATE,
          @Lc_RcthCur_TransactionType06_CODE CHAR(3),
          @Ln_RcthCur_Receipt06_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction07_DATE     DATE,
          @Lc_RcthCur_TransactionType07_CODE CHAR(3),
          @Ln_RcthCur_Receipt07_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction08_DATE     DATE,
          @Lc_RcthCur_TransactionType08_CODE CHAR(3),
          @Ln_RcthCur_Receipt08_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction09_DATE     DATE,
          @Lc_RcthCur_TransactionType09_CODE CHAR(3),
          @Ln_RcthCur_Receipt09_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction10_DATE     DATE,
          @Lc_RcthCur_TransactionType10_CODE CHAR(3),
          @Ln_RcthCur_Receipt10_AMNT         NUMERIC(11, 2),
          @Ld_RcthCur_Transaction11_DATE     DATE,
          @Lc_RcthCur_TransactionType11_CODE CHAR(3),
          @Ln_RcthCur_Receipt11_AMNT         NUMERIC(11, 2);

  BEGIN TRY
   BEGIN TRANSACTION FINEXTBILL;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   /*
   Get the run date and last run date from the Parameter (PARM_Y1) table and validate that the batch program was not
   executed for the run date by checking the last run date in the PARM_Y1 table
   */
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'DELETE EBILL_Y1';
   SET @Ls_Sqldata_TEXT = 'Yes_TEXT = ' + @Lc_Yes_TEXT;

   DELETE FROM EBILL_Y1
    WHERE Process_INDC = @Lc_Yes_TEXT;

   SET @Ld_ProcessingMonthBegin_DATE =CONVERT(DATE, CAST(DATEPART(M, @Ld_Run_DATE) AS VARCHAR(2)) + '/01/' + CONVERT(VARCHAR, YEAR(@Ld_Run_DATE)));
   SET @Ld_ProcessingMonthBegin_DATE =DATEADD(M, +1, @Ld_ProcessingMonthBegin_DATE);
   SET @Ls_Sql_TEXT = 'CALCULATE THE QUARTER';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_ProcessingMonthBegin_DATE AS VARCHAR);
   SET @Ld_QuarterBegin_DATE = CONVERT(DATE, CAST(DATEPART(Q, @Ld_ProcessingMonthBegin_DATE) * 3 - 2 AS VARCHAR(2)) + '/01/' + CONVERT(VARCHAR, YEAR(@Ld_ProcessingMonthBegin_DATE)));
   SET @Ld_QuarterEnd_DATE = DATEADD(D, -1, DATEADD(M, +3, @Ld_QuarterBegin_DATE));
   SET @Ls_Sql_TEXT = 'CALCULATE THE QUARTER-2';
   SET @Ls_Sqldata_TEXT = 'QuarterEnd_DATE = ' + CAST(@Ld_QuarterEnd_DATE AS VARCHAR);
   SET @Ln_QuarterEndMonthSupport_NUMB =CAST (CONVERT(CHAR(6), @Ld_QuarterEnd_DATE, 112) AS NUMERIC(6));
   SET @Ls_Sql_TEXT = 'CALCULATE THE BeginBill_DATE';
   SET @Ls_Sqldata_TEXT = 'ProcessingMonthBegin_DATE = ' + CAST(@Ld_ProcessingMonthBegin_DATE AS VARCHAR);
   SET @Ld_BeginBill_DATE =@Ld_ProcessingMonthBegin_DATE;
   SET @Ld_CurrentMonthBegin_DATE = CONVERT(DATE, CAST(DATEPART(M, @Ld_Run_DATE) AS VARCHAR(2)) + '/01/' + CONVERT(VARCHAR, YEAR(@Ld_Run_DATE)));

   IF @Ld_ProcessingMonthBegin_DATE <> @Ld_QuarterBegin_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'BATCH SHOULD BE RUN ON THE LAST DATE OF THE QUARTER ONLY.';

     RAISERROR (50001,16,1);
    END

   /*
   	If the billing process is part of the quarterly schedule select all the NCP's in the system from the
   	 Case Member Relationship (ENSD_Y1) table
   	Select the name of the NCP associated with the case from the ENSD_Y1 table by joining the NCP's MCI number.
   	Get the NCPs address using the address hierarchy (Common Routine) from ENSD_Y1 table
   */
   DECLARE Ncp_CUR INSENSITIVE CURSOR FOR
    SELECT e.Case_IDNO,
           e.NcpPf_IDNO AS MemberMci_IDNO,
           LEFT(e.LastNcp_NAME, 18) AS LastNcp_NAME,
           LEFT(e.SuffixNcp_NAME, 3) AS SuffixNcp_NAME,
           LEFT(e.FirstNcp_NAME, 12) AS FirstNcp_NAME,
           LEFT(e.MiddleNcp_NAME, 1) AS MiddleNcp_NAME,
           e.Line1Ncp_ADDR,
           e.Line2Ncp_ADDR,
           e.CityNcp_ADDR,
           e.StateNcp_ADDR,
           CASE
            WHEN e.ZipNcp_ADDR <> @Lc_Space_TEXT
                 AND LEN(LTRIM(RTRIM(e.ZipNcp_ADDR))) = 9
                 AND e.CountryNcp_ADDR = @Lc_CountryUS_CODE
             THEN SUBSTRING(LTRIM(RTRIM(e.ZipNcp_ADDR)), 1, 5) + @Lc_ZipSeprator_CODE + SUBSTRING(LTRIM(RTRIM(e.ZipNcp_ADDR)), 6, 4)
            ELSE e.ZipNcp_ADDR
           END,
           e.CountryNcp_ADDR,
           e.OrderSeq_NUMB,
           e.ArrearsReg_AMNT AS Arrears_AMNT,
           e.TypeOrder_CODE
      FROM ENSD_Y1 e
     WHERE e.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
       AND e.TypeCase_CODE <> @Lc_TypeCaseNonIvd_CODE
       AND e.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
       AND (e.Line1Ncp_ADDR <> @Lc_Space_TEXT
             OR e.Line2Ncp_ADDR <> @Lc_Space_TEXT)
       /*
            Check whether the case is charging in the Obligation (OBLE_Y1) table; the case should exist in the
            OBLE_Y1 table
            */
       /* 
       If the obligation is being modified or created in the middle of the month then billing coupon will
       be sent out for remaining months of the quarter minus the month in which obligation is created or
       modified                
       */
       AND ((EXISTS (SELECT 1
                       FROM OBLE_Y1 o
                      WHERE e.Case_IDNO = o.Case_IDNO
                        AND o.TypeDebt_CODE <> @Lc_TypeDebtGeneticTest_CODE
                        AND o.TypeDebt_CODE <> @Lc_TypeDebtNcpNSfFee_CODE
                        AND o.EndObligation_DATE >= @Ld_ProcessingMonthBegin_DATE
                        AND o.BeginObligation_DATE <= @Ld_QuarterEnd_DATE
                        AND (o.Periodic_AMNT > 0
                              OR (o.ExpectToPay_AMNT > 0
                                  AND e.ArrearsReg_AMNT > 0))
                        AND o.EndValidity_DATE = @Ld_High_DATE
                        AND o.EndObligation_DATE IN (SELECT x.EndObligation_DATE
                                                      FROM OBLE_Y1 X
                                                     WHERE o.Case_IDNO = X.Case_IDNO
                                                       AND o.OrderSeq_NUMB = X.OrderSeq_NUMB
                                                       AND o.ObligationSeq_NUMB = X.ObligationSeq_NUMB
                                                       AND X.EndValidity_DATE = @Ld_High_DATE
                                                       AND x.BeginObligation_DATE < DATEADD(M, 1, @Ld_ProcessingMonthBegin_DATE)
                                                       ))
              OR EXISTS (SELECT 1
                           FROM OBLE_Y1 o
                          WHERE e.Case_IDNO = o.Case_IDNO
                            AND o.TypeDebt_CODE <> @Lc_TypeDebtGeneticTest_CODE
                            AND o.TypeDebt_CODE <> @Lc_TypeDebtNcpNSfFee_CODE
                            AND (o.ExpectToPay_AMNT > 0
                                 AND e.ArrearsReg_AMNT > 0)
                            AND o.EndValidity_DATE = @Ld_High_DATE
                            AND o.EndObligation_DATE = (SELECT MAX(x.EndObligation_DATE)
                                                          FROM OBLE_Y1 X
                                                         WHERE o.Case_IDNO = X.Case_IDNO
                                                           AND o.OrderSeq_NUMB = X.OrderSeq_NUMB
                                                           AND o.ObligationSeq_NUMB = X.ObligationSeq_NUMB
                                                           AND X.EndValidity_DATE = @Ld_High_DATE)))
            --Skip the case if it is in pending closure; check in the Major Activity Diary (DMJR_Y1) table.
            AND e.CcloStrt_INDC != @Lc_Yes_TEXT
            --Exclude NCP's who have been deceased; (Check the, ENSD_Y1, table for a filed Deceased Date).
            AND (e.Deceased_DATE = @Ld_Low_DATE
                 --Exclude NCPs who have been incarcerated or institutionalized   
                 AND ((e.Incarceration_DATE = @Ld_Low_DATE
                       AND e.Institutionalized_DATE = @Ld_Low_DATE)
                       OR @Ld_Run_DATE > e.Released_DATE)
                 /*
                 
                 If the Intergovernmental Indicator is equal to ‘C-INITIATING INTERNATIONAL’, ‘I-INITIATING STATE’, or ‘T-INITIATING TRIBAL’, then the case is NOT eligible for billing statement. 
                 If the Intergovernmental Indicator is equal to ‘N-INSTATE’, then the case IS eligible for billing statement.
                 If the Intergovernmental Indicator is equal to ‘Y-RESPONDING INTERNATIONAL, R-RESPONDING STATE’, or ‘S-RESPONDING TRIBAL’, and the Referral Type is NOT EQUAL to ‘ERFSO’, ‘ERFSM’, or ‘ERFSS’. then the case IS eligible for billing statement.
                 */
                 AND e.RespondInit_CODE NOT IN (@Lc_RespondInitInternationalC_CODE, @Lc_RespondInitStateI_CODE, @Lc_RespondInitTribalT_CODE)
                 AND (e.RespondInit_CODE IN(@Lc_RespondInitInstateN_CODE)
                       OR (e.RespondInit_CODE IN (@Lc_RespondInitRespondIntY_CODE, @Lc_RespondInitRespondStateR_CODE, @Lc_RespondInitRespondTribalS_CODE)
                           AND NOT EXISTS(SELECT 1
                                            FROM ICAS_Y1 x
                                           WHERE x.Case_IDNO = e.Case_IDNO
                                             AND x.RespondInit_CODE IN (@Lc_RespondInitRespondIntY_CODE, @Lc_RespondInitRespondStateR_CODE, @Lc_RespondInitRespondTribalS_CODE)
                                             AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE)
                                             AND x.EndValidity_DATE = @Ld_High_DATE)))
                 /*
                 Exclude cases with billing suppression by selecting the NCP that is not having Suppression information
                 specified in Billing Suppression (BSUP_Y1) table (this existence in the table for the case).
                 */
                 AND NOT EXISTS (SELECT 1
                                   FROM BSUP_Y1 b
                                  WHERE e.Case_IDNO = b.Case_IDNO
                                    AND b.TypeAction_CODE = @Lc_ActionSuppress_CODE
                                    AND @Ld_Run_DATE BETWEEN b.Begin_DATE AND b.End_DATE
                                    AND b.EndValidity_DATE = @Ld_High_DATE)
                 /*
                 Cases with active income withholding are excluded; check in the Major Activity Diary (DMJR_Y1) table.
                 
                 */
                 AND NOT EXISTS (SELECT 1
                                   FROM DMJR_Y1 j
                                  WHERE e.Case_IDNO = j.Case_IDNO
                                    AND e.NcpPf_IDNO = j.MemberMci_IDNO
                                    AND j.ActivityMajor_CODE IN (@Lc_ImmediateIncomeWithholding_CODE)
                                    AND j.Status_CODE = @Lc_Start_CODE)
                 /*
                 Include the cases with no wage, unemployment or QDRO payments received in last 60 days
                 */
                 AND NOT EXISTS (SELECT 1
                                   FROM LSUP_Y1 l,
                                        RCTH_Y1 o
                                  WHERE l.Case_IDNO = e.Case_IDNO
                                    AND o.Batch_DATE = l.Batch_DATE
                                    AND o.SourceBatch_CODE = l.SourceBatch_CODE
                                    AND o.Batch_NUMB = l.Batch_NUMB
                                    AND o.SeqReceipt_NUMB = l.SeqReceipt_NUMB
                                    AND o.SourceReceipt_CODE IN (@Lc_SourceReceiptWage_CODE, @Lc_SourceReceiptUnemployment_CODE, @Lc_SourceReceiptQdro_CODE)
                                    AND o.EndValidity_DATE = @Ld_High_DATE
                                    AND o.StatusReceipt_CODE NOT IN (@Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
                                    AND o.Receipt_AMNT > 0
                                    AND NOT EXISTS (SELECT 1
                                                      FROM RCTH_Y1 i
                                                     WHERE o.Batch_DATE = i.Batch_DATE
                                                       AND o.SourceBatch_CODE = i.SourceBatch_CODE
                                                       AND o.Batch_NUMB = i.Batch_NUMB
                                                       AND o.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                                                       AND i.BackOut_INDC = @Lc_Yes_TEXT
                                                       AND i.EndValidity_DATE = @Ld_High_DATE)
                                    AND (o.Case_IDNO = e.Case_IDNO
                                          OR o.PayorMCI_IDNO = (SELECT MemberMci_IDNO
                                                                  FROM CMEM_Y1 a
                                                                 WHERE a.Case_IDNO = e.Case_IDNO
                                                                   AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipPutativeFather_TEXT)
                                                                   AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE))
                                    AND l.Batch_DATE != @Ld_Low_DATE
                                    AND l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                    AND l.Distribute_DATE BETWEEN DATEADD(dd, -@Ln_NoOfDays60_NUMB, @Ld_Run_DATE) AND @Ld_Run_DATE))
             /*
             In addition to the above cases, include cases for which billing is initiated by the case worker using the 'Billing Override' option in the Billing History (BHIS_Y1) table.
             */
             OR EXISTS (SELECT 1
                          FROM BSUP_Y1 b
                         WHERE e.Case_IDNO = b.Case_IDNO
                           AND b.TypeAction_CODE = @Lc_ActionOveride_CODE
                           AND @Ld_Run_DATE BETWEEN b.Begin_DATE AND b.End_DATE
                           AND b.EndValidity_DATE = @Ld_High_DATE))
       AND NOT EXISTS(SELECT 1
                        FROM BHIS_Y1 b
                       WHERE b.Case_IDNO = e.Case_IDNO
                         AND b.Statement_DATE = @Ld_Run_DATE)
     ORDER BY e.NcpPf_IDNO,
              e.Case_IDNO;

   SET @Ls_Sql_TEXT = 'FETCH Ncp_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Ncp_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Ncp_CUR';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Ncp_CUR INTO @Ln_NcpCur_Case_IDNO, @Ln_NcpCur_MemberMci_IDNO, @Lc_NcpCur_LastNcp_NAME, @Lc_NcpCur_SuffixNcp_NAME, @Lc_NcpCur_FirstNcp_NAME, @Lc_NcpCur_MiNcp_NAME, @Ls_NcpCur_Line1Ncp_ADDR, @Ls_NcpCur_Line2Ncp_ADDR, @Lc_NcpCur_CityNcp_ADDR, @Lc_NcpCur_StateNcp_ADDR, @Lc_NcpCur_ZipNcp_ADDR, @Lc_NcpCur_CountryNcp_ADDR, @Ln_NcpCur_OrderSeq_NUMB, @Ln_NcpCur_Arrears_AMNT, @Lc_NcpCur_TypeOrder_CODE;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'WHILE -1';
   SET @Ls_Sqldata_TEXT = '';

   --While loop for storing coupon data into EBILL_Y1 table
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION EXT_BILL_SAVE;

      SET @Ls_ErrorMessage_TEXT ='';
      SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
      SET @Lc_Error_CODE ='';
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      SET @Ls_CursorLocation_TEXT ='Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR);
      SET @Ls_BateRecord_TEXT ='Case_IDNO = ' + CAST(@Ln_NcpCur_Case_IDNO AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@Ln_NcpCur_MemberMci_IDNO AS VARCHAR) + ', LastNcp_NAME = ' + @Lc_NcpCur_LastNcp_NAME + ', SuffixNcp_NAME = ' + @Lc_NcpCur_SuffixNcp_NAME + ', FirstNcp_NAME = ' + @Lc_NcpCur_FirstNcp_NAME + ', MiNcp_NAME = ' + @Lc_NcpCur_MiNcp_NAME + ', Line1Ncp_ADDR = ' + @Ls_NcpCur_Line1Ncp_ADDR + ', Line2Ncp_ADDR = ' + @Ls_NcpCur_Line2Ncp_ADDR + ', CityNcp_ADDR = ' + @Lc_NcpCur_CityNcp_ADDR + ', StateNcp_ADDR = ' + @Lc_NcpCur_StateNcp_ADDR + ', ZipNcp_ADDR = ' + @Lc_NcpCur_ZipNcp_ADDR + ', CountryNcp_ADDR = ' + @Lc_NcpCur_CountryNcp_ADDR + ', OrderSeq_NUMB = ' + CAST(@Ln_NcpCur_OrderSeq_NUMB AS VARCHAR) + ', Arrears_AMNT = ' + CAST(@Ln_NcpCur_Arrears_AMNT AS VARCHAR) + ', TypeOrder_CODE = ' + @Lc_NcpCur_TypeOrder_CODE;
      SET @Ld_ProcessingMonthBegin_DATE =@Ld_BeginBill_DATE;
      SET @Ln_ProcessingMonthSupport_NUMB =CAST (CONVERT(CHAR(6), @Ld_ProcessingMonthBegin_DATE, 112) AS NUMERIC);
      SET @Ln_QuaterMonthsCount_QNTY =0;

      --While loop for calculating month support
      WHILE @Ln_ProcessingMonthSupport_NUMB <= @Ln_QuarterEndMonthSupport_NUMB
       BEGIN
        SET @Ln_QuaterMonthsCount_QNTY =@Ln_QuaterMonthsCount_QNTY + 1;
        SET @Ls_Sql_TEXT = 'SP_CALCULATE_MONTH_SUPPORT -1 ';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_NcpCur_Case_IDNO AS VARCHAR) + ', ProcessingMonthSupport_NUMB = ' + CAST(@Ln_ProcessingMonthSupport_NUMB AS VARCHAR);

        EXECUTE BATCH_FIN_EXT_BILLING$SP_CALCULATE_MONTH_SUPPORT
         @An_Case_IDNO             = @Ln_NcpCur_Case_IDNO,
         @An_SupportYearMonth_NUMB = @Ln_ProcessingMonthSupport_NUMB,
         @An_ExpectToPay_AMNT      = @Ln_ExpectToPay_AMNT OUTPUT,
         @An_MtdCurSupOwed_AMNT    = @Ln_MonthSupport_AMNT OUTPUT,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR(50001,16,1);
         END

        SET @Ls_Sql_TEXT = ' QUATER INFO';
        SET @Ls_Sqldata_TEXT = 'QuaterMonthsCount_QNTY = ' + CAST(@Ln_QuaterMonthsCount_QNTY AS VARCHAR) + ', ExpectToPay_AMNT = ' + CAST(@Ln_ExpectToPay_AMNT AS VARCHAR) + ', MonthSupport_AMNT = ' + CAST(@Ln_MonthSupport_AMNT AS VARCHAR) + ', ProcessingMonthBegin_DATE = ' + CAST(@Ld_ProcessingMonthBegin_DATE AS VARCHAR);

        IF @Ln_QuaterMonthsCount_QNTY = 1
         BEGIN
          SET @Ln_FirstMonthExpectToPay_AMNT =@Ln_ExpectToPay_AMNT;
          SET @Ln_FirstMonthSupport_AMNT =@Ln_MonthSupport_AMNT;
          SET @Ld_FirstMonthEnd_DATE = DATEADD(D, -1, DATEADD(M, 1, @Ld_ProcessingMonthBegin_DATE));
         END
        ELSE IF @Ln_QuaterMonthsCount_QNTY = 2
         BEGIN
          SET @Ln_SecondMonthExpectToPay_AMNT =@Ln_ExpectToPay_AMNT;
          SET @Ln_SecondMonthSupport_AMNT =@Ln_MonthSupport_AMNT;
          SET @Ld_SecondMonthEnd_DATE = DATEADD(D, -1, DATEADD(M, 1, @Ld_ProcessingMonthBegin_DATE));
         END
        ELSE IF @Ln_QuaterMonthsCount_QNTY = 3
         BEGIN
          SET @Ln_ThirdMonthExpectToPay_AMNT =@Ln_ExpectToPay_AMNT;
          SET @Ln_ThirdMonthSupport_AMNT =@Ln_MonthSupport_AMNT;
          SET @Ld_ThirdMonthEnd_DATE = DATEADD(D, -1, DATEADD(M, 1, @Ld_ProcessingMonthBegin_DATE));
         END

        SET @Ld_ProcessingMonthBegin_DATE =DATEADD(M, 1, @Ld_ProcessingMonthBegin_DATE);
        SET @Ln_ProcessingMonthSupport_NUMB =CAST (CONVERT(CHAR(6), @Ld_ProcessingMonthBegin_DATE, 112) AS NUMERIC);
       END

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
      SET @Ls_Sqldata_TEXT = 'BillingSuppression1510_NUMB = ' + CAST(@Li_BillingSuppression1510_NUMB AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', No_INDC = ' + @Lc_No_INDC + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT;

      EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
       @An_EventFunctionalSeq_NUMB = @Li_BillingSuppression1510_NUMB,
       @Ac_Process_ID              = @Lc_Job_ID,
       @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
       @Ac_Note_INDC               = @Lc_No_INDC,
       @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
       @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
       @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'INSERT BHIS_Y1 TABLE';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_NcpCur_Case_IDNO AS VARCHAR) + ', ActionOveride_CODE = ' + @Lc_ActionOveride_CODE + ', BeginBill_DATE = ' + CAST(@Ld_BeginBill_DATE AS VARCHAR) + ', QuarterEnd_DATE = ' + CAST(@Ld_QuarterEnd_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', MonthSupport_AMNT = ' + CAST(@Ln_MonthSupport_AMNT AS VARCHAR) + ', ExpectToPay_AMNT = ' + CAST(@Ln_ExpectToPay_AMNT AS VARCHAR) + ', Arrears_AMNT = ' + CAST(@Ln_NcpCur_Arrears_AMNT AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', No_INDC = ' + CAST(@Lc_No_INDC AS VARCHAR) + ', Low_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR);

      /*
      	After all the information is selected for a case ID, insert a record into BHIS_Y1 table
      */
      INSERT BHIS_Y1
             (Case_IDNO,
              TypeBill_CODE,
              BeginBill_DATE,
              EndBill_DATE,
              Statement_DATE,
              CurrentSupport_AMNT,
              ExpectToPay_AMNT,
              Arrears_AMNT,
              EventGlobalSeq_NUMB,
              Request_INDC,
              ReqReprint_DATE)
      SELECT @Ln_NcpCur_Case_IDNO Case_IDNO,
             @Lc_ActionOveride_CODE TypeBill_CODE,
             @Ld_BeginBill_DATE BeginBill_DATE,
             @Ld_QuarterEnd_DATE EndBill_DATE,
             @Ld_Run_DATE Statement_DATE,
             CASE
              WHEN @Ln_ThirdMonthSupport_AMNT + @Ln_ThirdMonthExpectToPay_AMNT > 0
               THEN @Ln_ThirdMonthSupport_AMNT
              WHEN @Ln_SecondMonthSupport_AMNT + @Ln_SecondMonthExpectToPay_AMNT > 0
               THEN @Ln_SecondMonthSupport_AMNT
              ELSE @Ln_FirstMonthSupport_AMNT
             END CurrentSupport_AMNT,
             CASE
              WHEN @Ln_ThirdMonthSupport_AMNT + @Ln_ThirdMonthExpectToPay_AMNT > 0
               THEN @Ln_ThirdMonthExpectToPay_AMNT
              WHEN @Ln_SecondMonthSupport_AMNT + @Ln_SecondMonthExpectToPay_AMNT > 0
               THEN @Ln_SecondMonthExpectToPay_AMNT
              ELSE @Ln_FirstMonthExpectToPay_AMNT
             END ExpectToPay_AMNT,
             @Ln_NcpCur_Arrears_AMNT Arrears_AMNT,
             @Ln_EventGlobalSeq_NUMB EventGlobalSeq_NUMB,
             @Lc_No_INDC Request_INDC,
             @Ld_Low_DATE ReqReprint_DATE;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT BHIS_Y1 FAILED';

        RAISERROR(50001,16,1);
       END

      SET @Ls_Payor_NAME= LTRIM(RTRIM(ISNULL(@Lc_NcpCur_FirstNcp_NAME, ''))) + @Lc_Space_TEXT + LTRIM(RTRIM(ISNULL(@Lc_NcpCur_MiNcp_NAME, ''))) + @Lc_Space_TEXT + LTRIM(RTRIM(ISNULL(@Lc_NcpCur_LastNcp_NAME, ''))) + @Lc_Space_TEXT + LTRIM(RTRIM(ISNULL(@Lc_NcpCur_SuffixNcp_NAME, '')));
      SET @Ld_RcthCur_Transaction01_DATE =NULL;
      SET @Ld_RcthCur_Transaction02_DATE =NULL;
      SET @Ld_RcthCur_Transaction03_DATE =NULL;
      SET @Ld_RcthCur_Transaction04_DATE =NULL;
      SET @Ld_RcthCur_Transaction05_DATE =NULL;
      SET @Ld_RcthCur_Transaction06_DATE =NULL;
      SET @Ld_RcthCur_Transaction07_DATE =NULL;
      SET @Ld_RcthCur_Transaction08_DATE =NULL;
      SET @Ld_RcthCur_Transaction09_DATE =NULL;
      SET @Ld_RcthCur_Transaction10_DATE =NULL;
      SET @Ld_RcthCur_Transaction11_DATE =NULL;
      SET @Lc_RcthCur_TransactionType01_CODE =NULL;
      SET @Lc_RcthCur_TransactionType02_CODE =NULL;
      SET @Lc_RcthCur_TransactionType03_CODE =NULL;
      SET @Lc_RcthCur_TransactionType04_CODE =NULL;
      SET @Lc_RcthCur_TransactionType05_CODE =NULL;
      SET @Lc_RcthCur_TransactionType06_CODE =NULL;
      SET @Lc_RcthCur_TransactionType07_CODE =NULL;
      SET @Lc_RcthCur_TransactionType08_CODE =NULL;
      SET @Lc_RcthCur_TransactionType09_CODE =NULL;
      SET @Lc_RcthCur_TransactionType10_CODE =NULL;
      SET @Lc_RcthCur_TransactionType11_CODE =NULL;
      SET @Ln_RcthCur_Receipt01_AMNT =NULL;
      SET @Ln_RcthCur_Receipt02_AMNT =NULL;
      SET @Ln_RcthCur_Receipt03_AMNT =NULL;
      SET @Ln_RcthCur_Receipt04_AMNT =NULL;
      SET @Ln_RcthCur_Receipt05_AMNT =NULL;
      SET @Ln_RcthCur_Receipt06_AMNT =NULL;
      SET @Ln_RcthCur_Receipt07_AMNT =NULL;
      SET @Ln_RcthCur_Receipt08_AMNT =NULL;
      SET @Ln_RcthCur_Receipt09_AMNT =NULL;
      SET @Ln_RcthCur_Receipt10_AMNT =NULL;
      SET @Ln_RcthCur_Receipt11_AMNT =NULL;

      /*
      		Maximum 11 transaction detail are shown in billing coupon
      	*/
      DECLARE RCTH_CUR INSENSITIVE CURSOR FOR
       SELECT TOP 11 Distribute_DATE,
                     TypeRemittance_CODE,
                     Distributed_AMNT
         FROM (SELECT a.Distribute_DATE,
                      ISNULL(SUM((TransactionNaa_AMNT + TransactionPaa_AMNT + TransactionTaa_AMNT + TransactionCaa_AMNT + TransactionUpa_AMNT + TransactionUda_AMNT + TransactionMedi_AMNT + TransactionIvef_AMNT + TransactionNffc_AMNT)), 0) Distributed_AMNT,
                      b.TypeRemittance_CODE
                 FROM LSUP_Y1 a,
                      RCTH_Y1 b
                WHERE a.Case_IDNO = @Ln_NcpCur_Case_IDNO
                  AND EventFunctionalSeq_NUMB IN (@Li_DirectPayCredit1040_NUMB, @Li_ReceiptReversed1250_NUMB, @Li_ReceiptDistributed1820_NUMB)
                  AND TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                  AND a.Batch_DATE = b.Batch_DATE
                  AND a.SourceBatch_CODE = b.SourceBatch_CODE
                  AND a.Batch_NUMB = b.Batch_NUMB
                  AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                  AND b.EndValidity_DATE = @Ld_High_DATE
                  AND a.Distribute_DATE = b.Distribute_DATE
                  AND NOT EXISTS (SELECT 1
                                    FROM RCTH_Y1 r
                                   WHERE r.Batch_DATE = b.Batch_DATE
                                     AND r.SourceBatch_CODE = b.SourceBatch_CODE
                                     AND r.Batch_NUMB = b.Batch_NUMB
                                     AND r.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                     AND r.EndValidity_DATE = @Ld_High_DATE
                                     AND b.BackOut_INDC = @Lc_Yes_TEXT)
                GROUP BY a.Distribute_DATE,
                         b.TypeRemittance_CODE) A
        WHERE Distributed_AMNT > 0
        ORDER BY Distribute_DATE DESC;

      SET @Ls_Sql_TEXT = 'OPEN Ncp_CUR';
      SET @Ls_Sqldata_TEXT = '';

      OPEN RCTH_CUR;

      SET @Ls_Sql_TEXT = 'FETCH Ncp_CUR';
      SET @Ls_Sqldata_TEXT = '';

      FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction01_DATE, @Lc_RcthCur_TransactionType01_CODE, @Ln_RcthCur_Receipt01_AMNT;

      SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction02_DATE, @Lc_RcthCur_TransactionType02_CODE, @Ln_RcthCur_Receipt02_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction03_DATE, @Lc_RcthCur_TransactionType03_CODE, @Ln_RcthCur_Receipt03_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction04_DATE, @Lc_RcthCur_TransactionType04_CODE, @Ln_RcthCur_Receipt04_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction05_DATE, @Lc_RcthCur_TransactionType05_CODE, @Ln_RcthCur_Receipt05_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction06_DATE, @Lc_RcthCur_TransactionType06_CODE, @Ln_RcthCur_Receipt06_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction07_DATE, @Lc_RcthCur_TransactionType07_CODE, @Ln_RcthCur_Receipt07_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction08_DATE, @Lc_RcthCur_TransactionType08_CODE, @Ln_RcthCur_Receipt08_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction09_DATE, @Lc_RcthCur_TransactionType09_CODE, @Ln_RcthCur_Receipt09_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction10_DATE, @Lc_RcthCur_TransactionType10_CODE, @Ln_RcthCur_Receipt10_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      IF @Li_FetchStatus_NUMB = 0
       BEGIN
        FETCH NEXT FROM RCTH_CUR INTO @Ld_RcthCur_Transaction11_DATE, @Lc_RcthCur_TransactionType11_CODE, @Ln_RcthCur_Receipt11_AMNT;

        SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
       END

      CLOSE RCTH_CUR;

      DEALLOCATE RCTH_CUR;

      SET @Lc_Line1_ADDR =@Lc_Space_TEXT;
      SET @Lc_Line2_ADDR =@Lc_Space_TEXT;
      SET @Lc_Line3_ADDR =@Lc_Space_TEXT;

      IF @Ls_NcpCur_Line1Ncp_ADDR = @Lc_Space_TEXT
       BEGIN
        SET @Lc_Line1_ADDR = @Ls_NcpCur_Line2Ncp_ADDR;
        SET @Lc_Line2_ADDR = LTRIM(RTRIM(@Lc_NcpCur_CityNcp_ADDR)) + @Lc_Space_TEXT + LTRIM(RTRIM(@Lc_NcpCur_StateNcp_ADDR)) + @Lc_Space_TEXT + LTRIM(RTRIM(@Lc_NcpCur_ZipNcp_ADDR));
       END
      ELSE IF @Ls_NcpCur_Line2Ncp_ADDR = @Lc_Space_TEXT
       BEGIN
        SET @Lc_Line1_ADDR = @Ls_NcpCur_Line1Ncp_ADDR;
        SET @Lc_Line2_ADDR = LTRIM(RTRIM(@Lc_NcpCur_CityNcp_ADDR)) + @Lc_Space_TEXT + LTRIM(RTRIM(@Lc_NcpCur_StateNcp_ADDR)) + @Lc_Space_TEXT + LTRIM(RTRIM(@Lc_NcpCur_ZipNcp_ADDR));
       END
      ELSE
       BEGIN
        SET @Lc_Line1_ADDR = @Ls_NcpCur_Line1Ncp_ADDR;
        SET @Lc_Line2_ADDR = @Ls_NcpCur_Line2Ncp_ADDR;
        SET @Lc_Line3_ADDR = LTRIM(RTRIM(@Lc_NcpCur_CityNcp_ADDR)) + @Lc_Space_TEXT + LTRIM(RTRIM(@Lc_NcpCur_StateNcp_ADDR)) + @Lc_Space_TEXT + LTRIM(RTRIM(@Lc_NcpCur_ZipNcp_ADDR));
       END

      SET @Ls_Sql_TEXT = 'insert  EBILL_Y1';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_NcpCur_MemberMci_IDNO AS VARCHAR), '') + ', Payor_NAME = ' + @Ls_Payor_NAME + ', FirstMonthBegin_DATE = ' + ISNULL(CAST(@Ld_FirstMonthEnd_DATE AS VARCHAR), '') + ', SecondMonthBegin_DATE = ' + ISNULL(CAST(@Ld_SecondMonthEnd_DATE AS VARCHAR), '') + ', ThirdMonthBegin_DATE = ' + ISNULL(CAST(@Ld_ThirdMonthEnd_DATE AS VARCHAR), '') + ', FirstMonthSupport_AMNT = ' + ISNULL(CAST(@Ln_FirstMonthSupport_AMNT AS VARCHAR), '') + ', SecondMonthSupport_AMNT = ' + ISNULL(CAST(@Ln_SecondMonthSupport_AMNT AS VARCHAR), '') + ', ThirdMonthSupport_AMNT = ' + ISNULL(CAST(@Ln_ThirdMonthSupport_AMNT AS VARCHAR), '') + ', Arrears_AMNT = ' + ISNULL(CAST(@Ln_NcpCur_Arrears_AMNT AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_NcpCur_Case_IDNO AS VARCHAR), '') + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Transaction01_DATE = ' + ISNULL(CAST(@Ld_RcthCur_Transaction01_DATE AS VARCHAR), '') + ', TransactionType01_CODE = ' + ISNULL(CAST(@Lc_RcthCur_TransactionType01_CODE AS VARCHAR), '') + ', Receipt01_AMNT = ' + ISNULL(CAST(@Ln_RcthCur_Receipt01_AMNT AS VARCHAR), '') + ', Payor_NAME = ' + @Ls_Payor_NAME + ', Line1Ncp_ADDR = ' + @Ls_NcpCur_Line1Ncp_ADDR + ', Line2Ncp_ADDR = ' + @Ls_NcpCur_Line2Ncp_ADDR + ', CityNcp_ADDR = ' + @Lc_NcpCur_CityNcp_ADDR + ', StateNcp_ADDR = ' + @Lc_NcpCur_StateNcp_ADDR + ', ZipNcp_ADDR = ' + @Lc_NcpCur_ZipNcp_ADDR + ', FirstMonthExpectToPay_AMNT = ' + CAST(@Ln_FirstMonthExpectToPay_AMNT AS VARCHAR) + ', SecondMonthExpectToPay_AMNT = ' + CAST(@Ln_SecondMonthExpectToPay_AMNT AS VARCHAR) + ', ThirdMonthExpectToPay_AMNT = ' + CAST(@Ln_ThirdMonthExpectToPay_AMNT AS VARCHAR) + ', Transaction02_DATE = ' + CAST(@Ld_RcthCur_Transaction02_DATE AS VARCHAR) + ', Transaction03_DATE = ' + CAST(@Ld_RcthCur_Transaction03_DATE AS VARCHAR) + ', Transaction04_DATE = ' + CAST(@Ld_RcthCur_Transaction04_DATE AS VARCHAR) + ', Transaction05_DATE = ' + CAST(@Ld_RcthCur_Transaction05_DATE AS VARCHAR) + ', Transaction06_DATE = ' + CAST(@Ld_RcthCur_Transaction06_DATE AS VARCHAR) + ', Transaction07_DATE = ' + CAST(@Ld_RcthCur_Transaction07_DATE AS VARCHAR) + ', Transaction08_DATE = ' + CAST(@Ld_RcthCur_Transaction08_DATE AS VARCHAR) + ', Transaction09_DATE = ' + CAST(@Ld_RcthCur_Transaction09_DATE AS VARCHAR) + ', Transaction10_DATE = ' + CAST(@Ld_RcthCur_Transaction10_DATE AS VARCHAR) + ', Transaction11_DATE = ' + CAST(@Ld_RcthCur_Transaction11_DATE AS VARCHAR) + ', TransactionType02_CODE = ' + @Lc_RcthCur_TransactionType02_CODE + ', TransactionType03_CODE = ' + @Lc_RcthCur_TransactionType03_CODE + ', TransactionType04_CODE = ' + @Lc_RcthCur_TransactionType04_CODE + ', TransactionType05_CODE = ' + @Lc_RcthCur_TransactionType05_CODE + ', TransactionType06_CODE = ' + @Lc_RcthCur_TransactionType06_CODE + ', TransactionType07_CODE = ' + @Lc_RcthCur_TransactionType07_CODE + ', TransactionType08_CODE = ' + @Lc_RcthCur_TransactionType08_CODE + ', TransactionType09_CODE = ' + @Lc_RcthCur_TransactionType09_CODE + ', TransactionType10_CODE = ' + @Lc_RcthCur_TransactionType10_CODE + ', TransactionType11_CODE = ' + @Lc_RcthCur_TransactionType11_CODE + ', Receipt02_AMNT = ' + CAST(@Ln_RcthCur_Receipt02_AMNT AS VARCHAR) + ', Receipt03_AMNT = ' + CAST(@Ln_RcthCur_Receipt03_AMNT AS VARCHAR) + ', Receipt04_AMNT = ' + CAST(@Ln_RcthCur_Receipt04_AMNT AS VARCHAR) + ', Receipt05_AMNT = ' + CAST(@Ln_RcthCur_Receipt05_AMNT AS VARCHAR) + ', Receipt06_AMNT = ' + CAST(@Ln_RcthCur_Receipt06_AMNT AS VARCHAR) + ', Receipt07_AMNT = ' + CAST(@Ln_RcthCur_Receipt07_AMNT AS VARCHAR) + ', Receipt08_AMNT = ' + CAST(@Ln_RcthCur_Receipt08_AMNT AS VARCHAR) + ', Receipt09_AMNT = ' + CAST(@Ln_RcthCur_Receipt09_AMNT AS VARCHAR) + ', Receipt10_AMNT = ' + CAST(@Ln_RcthCur_Receipt10_AMNT AS VARCHAR) + ', Receipt11_AMNT = ' + CAST(@Ln_RcthCur_Receipt11_AMNT AS VARCHAR) + ', Line1_ADDR = ' + @Lc_Line1_ADDR + ', Line2_ADDR = ' + @Lc_Line2_ADDR + ', Line3_ADDR = ' + @Lc_Line3_ADDR + ',No_INDC = ' + @Lc_No_INDC;

      INSERT EBILL_Y1
             (MemberMci_IDNO,
              Payor1_NAME,
              FirstCouponDue_DATE,
              SecondCouponDue_DATE,
              ThirdCouponDue_DATE,
              FirstCoupon_AMNT,
              SecondCoupon_AMNT,
              ThirdCoupon_AMNT,
              Arrears_AMNT,
              Case_IDNO,
              CreditedMonthYear_TEXT,
              Transaction01_DATE,
              TransactionType01_CODE,
              Receipt01_AMNT,
              Transaction02_DATE,
              TransactionType02_CODE,
              Receipt02_AMNT,
              Transaction03_DATE,
              TransactionType03_CODE,
              Receipt03_AMNT,
              Transaction04_DATE,
              TransactionType04_CODE,
              Receipt04_AMNT,
              Transaction05_DATE,
              TransactionType05_CODE,
              Receipt05_AMNT,
              Transaction06_DATE,
              TransactionType06_CODE,
              Receipt06_AMNT,
              Transaction07_DATE,
              TransactionType07_CODE,
              Receipt07_AMNT,
              Transaction08_DATE,
              TransactionType08_CODE,
              Receipt08_AMNT,
              Transaction09_DATE,
              TransactionType09_CODE,
              Receipt09_AMNT,
              Transaction10_DATE,
              TransactionType10_CODE,
              Receipt10_AMNT,
              Transaction11_DATE,
              TransactionType11_CODE,
              Receipt11_AMNT,
              Payor2_NAME,
              Line1_ADDR,
              Line2_ADDR,
              CityStateZip_ADDR,
              Process_INDC)
      VALUES ( RIGHT(REPLICATE('0', 10) + CAST(@Ln_NcpCur_MemberMci_IDNO AS VARCHAR), 10),-- MemberMci_IDNO
               CONVERT(CHAR(17), REPLACE(@Ls_Payor_NAME, @Lc_Space_TEXT + @Lc_Space_TEXT, @Lc_Space_TEXT)),--Payor1_NAME
               ISNULL(CONVERT(VARCHAR(10), @Ld_FirstMonthEnd_DATE, 101), ''),--FirstCouponDue_DATE
               ISNULL(CONVERT(VARCHAR(10), @Ld_SecondMonthEnd_DATE, 101), ''),--SecondCouponDue_DATE
               ISNULL(CONVERT(VARCHAR(10), @Ld_ThirdMonthEnd_DATE, 101), ''),--ThirdCouponDue_DATE
               ISNULL(CONVERT(CHAR(9), @Ln_FirstMonthSupport_AMNT + @Ln_FirstMonthExpectToPay_AMNT), ''),-- FirstCoupon_AMNT
               ISNULL(CONVERT(CHAR(9), @Ln_SecondMonthSupport_AMNT + @Ln_SecondMonthExpectToPay_AMNT), ''),--SecondCoupon_AMNT
               ISNULL(CONVERT(CHAR(9), @Ln_ThirdMonthSupport_AMNT + @Ln_ThirdMonthExpectToPay_AMNT), ''),--ThirdCoupon_AMNT
               @Ln_NcpCur_Arrears_AMNT,-- Arrears_AMNT
               @Ln_NcpCur_Case_IDNO,--Case_IDNO
               UPPER(CAST(DATENAME(Month, @Ld_Run_DATE) AS CHAR(3))) + ' ' + CAST(DATEPART(Year, @Ld_Run_DATE)AS VARCHAR),--CreditedMonthYear_TEXT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction01_DATE, 101), ''),--Transaction01_DATE
               ISNULL(@Lc_RcthCur_TransactionType01_CODE, ''),--TransactionType01_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt01_AMNT), ''),--Receipt01_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction02_DATE, 101), ''),--Transaction02_DATE
               ISNULL(@Lc_RcthCur_TransactionType02_CODE, ''),--TransactionType02_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt02_AMNT), ''),--Receipt02_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction03_DATE, 101), ''),--Transaction03_DATE
               ISNULL(@Lc_RcthCur_TransactionType03_CODE, ''),--TransactionType03_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt03_AMNT), ''),--Receipt03_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction04_DATE, 101), ''),--Transaction04_DATE
               ISNULL(@Lc_RcthCur_TransactionType04_CODE, ''),--TransactionType04_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt04_AMNT), ''),--Receipt04_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction05_DATE, 101), ''),--Transaction05_DATE
               ISNULL(@Lc_RcthCur_TransactionType05_CODE, ''),--TransactionType05_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt05_AMNT), ''),--Receipt05_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction06_DATE, 101), ''),--Transaction06_DATE
               ISNULL(@Lc_RcthCur_TransactionType06_CODE, ''),--TransactionType06_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt06_AMNT), ''),--Receipt06_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction07_DATE, 101), ''),--Transaction07_DATE
               ISNULL(@Lc_RcthCur_TransactionType07_CODE, ''),--TransactionType07_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt07_AMNT), ''),--Receipt07_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction08_DATE, 101), ''),--Transaction08_DATE
               ISNULL(@Lc_RcthCur_TransactionType08_CODE, ''),--TransactionType08_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt08_AMNT), ''),--Receipt08_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction09_DATE, 101), ''),--Transaction09_DATE
               ISNULL(@Lc_RcthCur_TransactionType09_CODE, ''),--TransactionType09_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt09_AMNT), ''),--Receipt09_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction10_DATE, 101), ''),--Transaction10_DATE
               ISNULL(@Lc_RcthCur_TransactionType10_CODE, ''),--TransactionType10_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt10_AMNT), ''),--Receipt10_AMNT
               ISNULL(CONVERT(VARCHAR(10), @Ld_RcthCur_Transaction11_DATE, 101), ''),--Transaction11_DATE
               ISNULL(@Lc_RcthCur_TransactionType11_CODE, ''),--TransactionType11_CODE
               ISNULL(CONVERT(CHAR(9), @Ln_RcthCur_Receipt11_AMNT), ''),--Receipt11_AMNT
               CONVERT(CHAR(31), REPLACE(@Ls_Payor_NAME, @Lc_Space_TEXT + @Lc_Space_TEXT, @Lc_Space_TEXT)),--Payor2_NAME
               @Lc_Line1_ADDR,--Line1_ADDR
               @Lc_Line2_ADDR,--Line2_ADDR
               @Lc_Line3_ADDR,--CityStateZip_ADDR               
               @Lc_No_INDC --Process_INDC
      );

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT EBILL_Y1 FAILED';

        RAISERROR(50001,16,1);
       END
     END TRY

     BEGIN CATCH
      IF XACT_STATE() = 1
       BEGIN
        ROLLBACK TRANSACTION EXT_BILL_SAVE
       END
      ELSE
       BEGIN
        SET @Ls_ErrorMessage_TEXT =@Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);

        RAISERROR( 50001,16,1);
       END

      SET @Ln_Error_NUMB = ERROR_NUMBER();
      SET @Ln_ErrorLine_NUMB = ERROR_LINE();

      IF @Ln_Error_NUMB <> 50001
       BEGIN
        SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
        SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
       END

      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
       @As_Procedure_NAME        = @Lc_Procedure_NAME,
       @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
       @As_Sql_TEXT              = @Ls_Sql_TEXT,
       @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
       @An_Error_NUMB            = @Ln_Error_NUMB,
       @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
       @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
      SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeErrorE_CODE + ', CursorLocation_TEXT = ' + @Ls_CursorLocation_TEXT + ', BateError_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Lc_Process_NAME,
       @As_Procedure_NAME           = @Lc_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR (50001,16,1);
       END

      IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
       BEGIN
        SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
       END
     END CATCH

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD';

       COMMIT TRANSACTION FINEXTBILL;

       SET @Ln_ProcessedRecordCount_QNTY =@Ln_Cursor_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;

       RAISERROR (50001,16,1);
      END

     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       COMMIT TRANSACTION FINEXTBILL;

       BEGIN TRANSACTION FINEXTBILL;

       SET @Ln_ProcessedRecordCount_QNTY =@Ln_Cursor_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'FETCH Ncp_CUR';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Ncp_CUR INTO @Ln_NcpCur_Case_IDNO, @Ln_NcpCur_MemberMci_IDNO, @Lc_NcpCur_LastNcp_NAME, @Lc_NcpCur_SuffixNcp_NAME, @Lc_NcpCur_FirstNcp_NAME, @Lc_NcpCur_MiNcp_NAME, @Ls_NcpCur_Line1Ncp_ADDR, @Ls_NcpCur_Line2Ncp_ADDR, @Lc_NcpCur_CityNcp_ADDR, @Lc_NcpCur_StateNcp_ADDR, @Lc_NcpCur_ZipNcp_ADDR, @Lc_NcpCur_CountryNcp_ADDR, @Ln_NcpCur_OrderSeq_NUMB, @Ln_NcpCur_Arrears_AMNT, @Lc_NcpCur_TypeOrder_CODE;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   CLOSE Ncp_CUR;

   DEALLOCATE Ncp_CUR;

   IF @Ln_Cursor_QNTY = 0
    BEGIN
     /*
     If no data extracted then write message 'E0944 – No Record(s) to Process' into BATE_Y1 table
     */
     SET @Ls_ErrorMessage_TEXT ='No Records To Process';
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG 2';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeErrorInformation_CODE = ' + @Lc_TypeErrorInformation_CODE + ', Cursor_QNTY = ' + CAST(@Ln_Cursor_QNTY AS VARCHAR) + ', NoRecordsToProcess_CODE = ' + @Lc_NoRecordsToProcess_CODE + ', DescriptionError_TEXT = ' + @Ls_ErrorMessage_TEXT + ', Sqldata_TEXT = ' + @Ls_Sqldata_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorInformation_CODE,
      @An_Line_NUMB                = @Ln_Cursor_QNTY,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcess_CODE,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

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

   SET @Ln_ProcessedRecordCount_QNTY =@Ln_Cursor_QNTY;
   SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Lc_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   COMMIT TRANSACTION FINEXTBILL;
  END TRY

  --Execption Begins
  BEGIN CATCH
   --Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FINEXTBILL;
    END;

   IF CURSOR_STATUS ('LOCAL', 'Ncp_CUR') IN (0, 1)
    BEGIN
     CLOSE Ncp_CUR;

     DEALLOCATE Ncp_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'RCTH_CUR') IN (0, 1)
    BEGIN
     CLOSE RCTH_CUR;

     DEALLOCATE RCTH_CUR;
    END

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @An_ProcessedRecordCount_QNTY =0,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_SqlData_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
