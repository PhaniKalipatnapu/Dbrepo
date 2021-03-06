/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_ORDER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_ORDER
Programmer Name	:	IMP Team.
Description		:	This procedure loads all order data in to extract_order_data_blocks table for each row of pending_request table
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INIT_TRAN
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_ORDER]
 @An_Case_IDNO             NUMERIC(6),
 @An_TransHeader_IDNO      NUMERIC(12),
 @Ac_StateFips_CODE        CHAR(2),
 @Ad_Run_DATE              DATE,
 @Ad_Start_DATE            DATE,
 @Ai_Order_QNTY            INTEGER OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ErrorLine_NUMB              INT = 0,
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_WelfareTypeTanf_CODE        CHAR(1) = 'A',
          @Lc_RelationshipCaseDp_TEXT     CHAR(1) = 'D',
          @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A',
          @Lc_WelfareTypeNonTanf_CODE     CHAR(1) = 'N',
          @Lc_WelfareTypeFosterCare_CODE  CHAR(1) = 'J',
          @Lc_WelfareTypeMedicaid_CODE    CHAR(1) = 'M',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_Value_NUMB                  CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_MedicalOrdered_TEXT         CHAR(1) = ' ',
          @Lc_FreqOrderArrears_CODE       CHAR(1) = ' ',
          @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_ORDER',
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Ld_ArrearsNonAfdcFrom_DATE     DATE = '01/01/0001',
          @Ld_ArrearsNonAfdcThru_DATE     DATE = '01/01/0001',
          @Ld_FosterCareFrom_DATE         DATE = '01/01/0001',
          @Ld_FosterCareThru_DATE         DATE = '01/01/0001',
          @Ld_MedicalFrom_DATE            DATE = '01/01/0001',
          @Ld_MedicalThru_DATE            DATE = '01/01/0001',
          @Ld_ArrearsAfdcFrom_DATE        DATE = '01/01/0001',
          @Ld_ArrearsAfdcThru_DATE        DATE = '01/01/0001';
  DECLARE @Ln_ArrearsAfdc_AMNT       NUMERIC(11, 2) = 0,
          @Ln_ArrearsNonAfdc_AMNT    NUMERIC(11, 2) = 0,
          @Ln_FosterCare_AMNT        NUMERIC(11, 2) = 0,
          @Ln_Medical_AMNT           NUMERIC(11, 2) = 0,
          @Ln_OrderArrearsTotal_AMNT NUMERIC(11, 2) = 0,
          @Li_Error_NUMB             INT = 0,
          @Li_Ord_QNTY               INT = 0,
          @Li_FetchStatus_NUMB       SMALLINT,
          @Li_Rowcount_QNTY          SMALLINT,
          @Lc_OthStateFips_CODE      CHAR(2),
          @Ls_Sql_TEXT               VARCHAR(2000),
          @Ls_DescriptionError_TEXT  VARCHAR(4000),
          @Ls_Sqldata_TEXT           VARCHAR(4000),
          @Ld_Generated_DATE         DATE;
  DECLARE @Ln_SelectOrdCur_Order_IDNO                NUMERIC(15),
          @Ln_SelectOrdCur_OrderSeq_NUMB             NUMERIC(2),
          @Lc_SelectOrdCur_File_ID                   CHAR(15),
          @Lc_SelectOrdCur_TypeOrder_CODE            CHAR(1),
          @Ld_SelectOrdCur_OrderEffective_DATE       DATE,
          @Ld_SelectOrdCur_OrderEnd_DATE             DATE,
          @Lc_SelectOrdCur_FreqOrderArrears_CODE     CHAR(1),
          @Ln_SelectOrdCur_FreqOrderArrears_AMNT     NUMERIC(11, 2),
          @Lc_SelectOrdCur_ControllingOrderFlag_CODE CHAR(1),
          @Lc_SelectOrdCur_OrderFreq_CODE            CHAR(1),
          @Ln_SelectOrdCur_Periodic_AMNT             NUMERIC(11, 2),
          @Lc_SelectOrdCur_IssuingOrderFips_CODE     CHAR(7),
          @Ld_SelectOrdCur_OrderIssued_DATE          DATE,
          @Lc_SelectOrdCur_TypeDebt_CODE             CHAR(2),
          @Ln_SelectOrdCur_ObligationSeq_NUMB        NUMERIC(2),
          @Lc_SelectOrdCur_CoverageMedical_CODE      CHAR(1);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT CSPR_Y1 - ORDER DATA BLOCK ' + CAST(@An_Case_IDNO AS VARCHAR);
   SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Lc_OthStateFips_CODE = a.IVDOutOfStateFips_CODE,
          @Ld_Generated_DATE = a.Generated_DATE
     FROM CSPR_Y1 a
    WHERE a.Request_IDNO = @An_TransHeader_IDNO
      AND a.EndValidity_DATE = @Ld_High_DATE;

   DECLARE SelectOrd_CUR INSENSITIVE CURSOR FOR
    SELECT a.Order_IDNO,
           a.OrderSeq_NUMB AS OrderSeq_NUMB,
           a.File_ID AS File_ID,
           a.TypeOrder_CODE,
           b.BeginObligation_DATE AS OrderEffective_DATE,
           b.EndObligation_DATE AS OrderEnd_DATE,
           b.FreqPeriodic_CODE AS FreqOrderArrears_CODE,
           b.ExpectToPay_AMNT AS FreqOrderArrears_AMNT,
           a.StatusControl_CODE AS ControllingOrderFlag_CODE,
           b.FreqPeriodic_CODE AS OrderFreq_CODE,
           b.Periodic_AMNT,
           a.IssuingOrderFips_CODE,
           a.OrderIssued_DATE,
           b.TypeDebt_CODE,
           b.ObligationSeq_NUMB,
           a.CoverageMedical_CODE
      FROM SORD_Y1 a,
           OBLE_Y1 b
     WHERE b.Case_IDNO = @An_Case_IDNO
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND @Ad_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
       AND a.Case_IDNO = b.Case_IDNO
       AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
       AND b.EndValidity_DATE = @Ld_High_DATE
       AND @Ad_Run_DATE BETWEEN b.BeginObligation_DATE AND b.EndObligation_DATE;

   SET @Ls_Sql_TEXT = 'OPEN SelectOrd_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN SelectOrd_CUR;

   SET @Ls_Sql_TEXT = 'FETCH SelectOrd_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM SelectOrd_CUR INTO @Ln_SelectOrdCur_Order_IDNO, @Ln_SelectOrdCur_OrderSeq_NUMB, @Lc_SelectOrdCur_File_ID, @Lc_SelectOrdCur_TypeOrder_CODE, @Ld_SelectOrdCur_OrderEffective_DATE, @Ld_SelectOrdCur_OrderEnd_DATE, @Lc_SelectOrdCur_FreqOrderArrears_CODE, @Ln_SelectOrdCur_FreqOrderArrears_AMNT, @Lc_SelectOrdCur_ControllingOrderFlag_CODE, @Lc_SelectOrdCur_OrderFreq_CODE, @Ln_SelectOrdCur_Periodic_AMNT, @Lc_SelectOrdCur_IssuingOrderFips_CODE, @Ld_SelectOrdCur_OrderIssued_DATE, @Lc_SelectOrdCur_TypeDebt_CODE, @Ln_SelectOrdCur_ObligationSeq_NUMB, @Lc_SelectOrdCur_CoverageMedical_CODE;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Get information from LSUP_Y1, SORD_Y1, MHIS_Y1, CMEM_Y1 and insert to Order Block
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     SET @Li_Ord_QNTY = @Li_Ord_QNTY + 1;

     IF (@Ln_SelectOrdCur_Periodic_AMNT > 0)
      BEGIN
       SET @Lc_FreqOrderArrears_CODE = @Lc_SelectOrdCur_FreqOrderArrears_CODE;
      END
     ELSE
      BEGIN
       SET @Lc_FreqOrderArrears_CODE = @Lc_Space_TEXT;
      END;

     SET @Ls_Sql_TEXT = 'SELECT LSUP_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_SelectOrdCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_SelectOrdCur_ObligationSeq_NUMB AS VARCHAR), '');

     SELECT @Ln_OrderArrearsTotal_AMNT = SUM((a.OweTotNaa_AMNT + a.OweTotCaa_AMNT + a.OweTotUpa_AMNT + a.OweTotUda_AMNT + a.OweTotMedi_AMNT + a.OweTotNffc_AMNT + a.OweTotNonIvd_AMNT + a.OweTotPaa_AMNT + a.OweTotTaa_AMNT + a.OweTotIvef_AMNT) - (a.AppTotNaa_AMNT + a.AppTotCaa_AMNT + a.AppTotUpa_AMNT + a.AppTotUda_AMNT + a.AppTotMedi_AMNT + a.AppTotNffc_AMNT + a.AppTotNonIvd_AMNT + a.AppTotPaa_AMNT + a.AppTotTaa_AMNT + a.AppTotIvef_AMNT)),
            @Ln_ArrearsAfdc_AMNT = SUM((a.OweTotPaa_AMNT + a.OweTotTaa_AMNT + a.OweTotCaa_AMNT) - (a.AppTotPaa_AMNT + a.AppTotTaa_AMNT + a.AppTotCaa_AMNT)),
            @Ln_ArrearsNonAfdc_AMNT = SUM((a.OweTotNaa_AMNT + a.OweTotUpa_AMNT + a.OweTotUda_AMNT) - (a.AppTotNaa_AMNT + a.AppTotUpa_AMNT + a.AppTotUda_AMNT)),
            @Ln_FosterCare_AMNT = SUM(a.OweTotIvef_AMNT - a.AppTotIvef_AMNT),
            @Ln_Medical_AMNT = 0
       FROM LSUP_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.OrderSeq_NUMB = @Ln_SelectOrdCur_OrderSeq_NUMB
        AND a.ObligationSeq_NUMB = @Ln_SelectOrdCur_ObligationSeq_NUMB
        AND a.SupportYearMonth_NUMB = (SELECT TOP 1 MAX(d.SupportYearMonth_NUMB)
                                         FROM LSUP_Y1 d
                                        WHERE d.Case_IDNO = a.Case_IDNO
                                          AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                          AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
        AND a.EventGlobalSeq_NUMB = (SELECT TOP 1 MAX(c.EventGlobalSeq_NUMB)
                                       FROM LSUP_Y1 c
                                      WHERE c.Case_IDNO = a.Case_IDNO
                                        AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                        AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                        AND c.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB);

     IF @Ln_ArrearsAfdc_AMNT > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MHIS_Y1 - 1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

       SELECT TOP 1 @Ld_ArrearsAfdcFrom_DATE = fci.Start_DATE,
                    @Ld_ArrearsAfdcThru_DATE = fci.End_DATE
         FROM (SELECT a.Start_DATE,
                      a.End_DATE,
                      a.BeginValidity_DATE
                 FROM MHIS_Y1 a,
                      CMEM_Y1 b
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
                  AND a.Case_IDNO = b.Case_IDNO
                  AND a.MemberMci_IDNO = b.MemberMci_IDNO
                  AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                  AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE) AS fci
        ORDER BY fci.BeginValidity_DATE DESC;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ld_ArrearsAfdcFrom_DATE = @Ld_SelectOrdCur_OrderEffective_DATE;
         SET @Ld_ArrearsAfdcThru_DATE = CONVERT(DATE, @Ad_Start_DATE, 101);
        END
       ELSE
        BEGIN
         IF @Ld_ArrearsAfdcThru_DATE = @Ld_High_DATE
          BEGIN
           SET @Ld_ArrearsAfdcThru_DATE = CONVERT(DATE, @Ad_Start_DATE, 101);
          END;

         IF @Ld_ArrearsAfdcFrom_DATE >= CONVERT(DATE, @Ad_Start_DATE, 101)
          BEGIN
           SET @Ld_ArrearsAfdcFrom_DATE = DATEADD(dd, -1, CONVERT(DATE, @Ad_Start_DATE, 101));
          END;
        END;
      END
     ELSE
      BEGIN
       SET @Ld_ArrearsAfdcFrom_DATE = @Ld_Low_DATE;
       SET @Ld_ArrearsAfdcThru_DATE = @Ld_Low_DATE;
      END;

     IF @Ln_ArrearsNonAfdc_AMNT > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MHIS_Y1 - 2';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

       SELECT TOP (1) @Ld_ArrearsNonAfdcFrom_DATE = fci.Start_DATE,
                      @Ld_ArrearsNonAfdcThru_DATE = fci.End_DATE
         FROM (SELECT a.Start_DATE,
                      a.End_DATE,
                      a.BeginValidity_DATE
                 FROM MHIS_Y1 a,
                      CMEM_Y1 b
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.TypeWelfare_CODE = @Lc_WelfareTypeNonTanf_CODE
                  AND a.Case_IDNO = b.Case_IDNO
                  AND a.MemberMci_IDNO = b.MemberMci_IDNO
                  AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                  AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE) AS fci
        ORDER BY fci.BeginValidity_DATE DESC;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ld_ArrearsNonAfdcFrom_DATE = @Ld_SelectOrdCur_OrderEffective_DATE;
         SET @Ld_ArrearsNonAfdcThru_DATE = CONVERT(DATE, @Ad_Start_DATE, 101);
        END;
       ELSE
        BEGIN
         IF @Ld_ArrearsNonAfdcThru_DATE = @Ld_High_DATE
          BEGIN
           SET @Ld_ArrearsNonAfdcThru_DATE = CONVERT(DATE, @Ad_Start_DATE, 101);
          END;

         -- To correct the CSENet Host error - Arrears Non TANF through Date <= Non TANF From Date
         -- and to make sure that the Through Date on TANF and Non TANF arrears should always
         -- be greater than From Date on TANF and Non TANF arrears
         IF @Ld_ArrearsNonAfdcFrom_DATE >= CONVERT(DATE, @Ad_Start_DATE, 101)
          BEGIN
           SET @Ld_ArrearsNonAfdcFrom_DATE = DATEADD(dd, -1, CONVERT(DATE, @Ad_Start_DATE, 101));
          END;
        END;
      END
     ELSE
      BEGIN
       SET @Ld_ArrearsNonAfdcFrom_DATE = @Ld_Low_DATE;
       SET @Ld_ArrearsNonAfdcThru_DATE = @Ld_Low_DATE;
      END;

     IF @Ln_FosterCare_AMNT > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MHIS_Y1 - 3';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

       SELECT TOP (1) @Ld_FosterCareFrom_DATE = fci.Start_DATE,
                      @Ld_FosterCareThru_DATE = fci.End_DATE
         FROM (SELECT a.Start_DATE,
                      a.End_DATE,
                      a.BeginValidity_DATE
                 FROM MHIS_Y1 a,
                      CMEM_Y1 b
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.TypeWelfare_CODE = @Lc_WelfareTypeFosterCare_CODE
                  AND a.Case_IDNO = b.Case_IDNO
                  AND a.MemberMci_IDNO = b.MemberMci_IDNO
                  AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                  AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE) AS fci
        ORDER BY fci.BeginValidity_DATE DESC;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ld_FosterCareFrom_DATE = @Ld_SelectOrdCur_OrderEffective_DATE;
         SET @Ld_FosterCareThru_DATE = CONVERT(DATE, @Ad_Start_DATE, 101);
        END
       ELSE
        BEGIN
         IF @Ld_FosterCareThru_DATE = @Ld_High_DATE
          BEGIN
           SET @Ld_FosterCareThru_DATE = CONVERT(DATE, @Ad_Start_DATE, 101);
          END;

         IF @Ld_FosterCareFrom_DATE >= CONVERT(DATE, @Ad_Start_DATE, 101)
          BEGIN
           SET @Ld_FosterCareFrom_DATE = DATEADD(dd, -1, CONVERT(DATE, @Ad_Start_DATE, 101));
          END;
        END;
      END
     ELSE
      BEGIN
       SET @Ld_FosterCareFrom_DATE = @Ld_Low_DATE;
       SET @Ld_FosterCareThru_DATE = @Ld_Low_DATE;
      END;

     IF @Ln_Medical_AMNT > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MHIS_Y1 - 4';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

       SELECT TOP (1) @Ld_MedicalFrom_DATE = fci.Start_DATE,
                      @Ld_MedicalThru_DATE = fci.End_DATE
         FROM (SELECT a.Start_DATE,
                      a.End_DATE,
                      a.BeginValidity_DATE
                 FROM MHIS_Y1 a,
                      CMEM_Y1 b
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.TypeWelfare_CODE = @Lc_WelfareTypeMedicaid_CODE
                  AND a.Case_IDNO = b.Case_IDNO
                  AND a.MemberMci_IDNO = b.MemberMci_IDNO
                  AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                  AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE) AS fci
        ORDER BY fci.BeginValidity_DATE DESC;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ld_MedicalFrom_DATE = @Ld_SelectOrdCur_OrderEffective_DATE;
         SET @Ld_MedicalThru_DATE = CONVERT(DATE, @Ad_Start_DATE, 101);
        END
       ELSE
        BEGIN
         IF @Ld_MedicalThru_DATE = @Ld_High_DATE
          BEGIN
           SET @Ld_MedicalThru_DATE = CONVERT(DATE, @Ad_Start_DATE, 101);
          END;

         IF @Ld_MedicalFrom_DATE >= CONVERT(DATE, @Ad_Start_DATE, 101)
          BEGIN
           SET @Ld_MedicalFrom_DATE = DATEADD(dd, -1, CONVERT(DATE, @Ad_Start_DATE, 101));
          END;
        END;
      END;
     ELSE
      BEGIN
       SET @Ld_MedicalFrom_DATE = @Ld_Low_DATE;
       SET @Ld_MedicalThru_DATE = @Ld_Low_DATE;
      END;

     IF @Lc_SelectOrdCur_CoverageMedical_CODE = @Lc_WelfareTypeTanf_CODE
      BEGIN
       SET @Lc_MedicalOrdered_TEXT = @Lc_Yes_INDC;
      END
     ELSE
      BEGIN
       SET @Lc_MedicalOrdered_TEXT = @Lc_Value_NUMB;
      END;

     SET @Ls_Sql_TEXT = 'INSERT EOBLK_Y1';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_StateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_Generated_DATE AS VARCHAR), '') + ', BlockSeq_NUMB = ' + ISNULL(CAST(@Li_Ord_QNTY AS VARCHAR), '') + ', Order_IDNO = ' + ISNULL(CAST(@Ln_SelectOrdCur_Order_IDNO AS VARCHAR), '') + ', FilingOrder_DATE = ' + ISNULL(CAST(@Ld_SelectOrdCur_OrderIssued_DATE AS VARCHAR), '') + ', TypeOrder_CODE = ' + ISNULL(@Lc_SelectOrdCur_TypeOrder_CODE, '') + ', DebtType_CODE = ' + ISNULL(@Lc_SelectOrdCur_TypeDebt_CODE, '') + ', OrderFreq_CODE = ' + ISNULL(@Lc_SelectOrdCur_OrderFreq_CODE, '') + ', OrderFreq_AMNT = ' + ISNULL(CAST(@Ln_SelectOrdCur_Periodic_AMNT AS VARCHAR), '') + ', OrderEffective_DATE = ' + ISNULL(CAST(@Ld_SelectOrdCur_OrderEffective_DATE AS VARCHAR), '') + ', OrderEnd_DATE = ' + ISNULL(CAST(@Ld_SelectOrdCur_OrderEnd_DATE AS VARCHAR), '') + ', OrderCancel_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', FreqOrderArrears_CODE = ' + ISNULL(@Lc_SelectOrdCur_FreqOrderArrears_CODE, '') + ', FreqOrderArrears_AMNT = ' + ISNULL(CAST(@Ln_SelectOrdCur_FreqOrderArrears_AMNT AS VARCHAR), '') + ', OrderArrearsTotal_AMNT = ' + ISNULL(CAST(@Ln_OrderArrearsTotal_AMNT AS VARCHAR), '') + ', ArrearsAfdcFrom_DATE = ' + ISNULL(CAST(@Ld_ArrearsAfdcFrom_DATE AS VARCHAR), '') + ', ArrearsAfdcThru_DATE = ' + ISNULL(CAST(@Ld_ArrearsAfdcThru_DATE AS VARCHAR), '') + ', ArrearsAfdc_AMNT = ' + ISNULL(CAST(@Ln_ArrearsAfdc_AMNT AS VARCHAR), '') + ', ArrearsNonAfdcFrom_DATE = ' + ISNULL(CAST(@Ld_ArrearsNonAfdcFrom_DATE AS VARCHAR), '') + ', ArrearsNonAfdcThru_DATE = ' + ISNULL(CAST(@Ld_ArrearsNonAfdcThru_DATE AS VARCHAR), '') + ', ArrearsNonAfdc_AMNT = ' + ISNULL(CAST(@Ln_ArrearsNonAfdc_AMNT AS VARCHAR), '') + ', FosterCareFrom_DATE = ' + ISNULL(CAST(@Ld_FosterCareFrom_DATE AS VARCHAR), '') + ', FosterCareThru_DATE = ' + ISNULL(CAST(@Ld_FosterCareThru_DATE AS VARCHAR), '') + ', FosterCare_AMNT = ' + ISNULL(CAST(@Ln_FosterCare_AMNT AS VARCHAR), '') + ', MedicalFrom_DATE = ' + ISNULL(CAST(@Ld_MedicalFrom_DATE AS VARCHAR), '') + ', MedicalThru_DATE = ' + ISNULL(CAST(@Ld_MedicalThru_DATE AS VARCHAR), '') + ', Medical_AMNT = ' + ISNULL(CAST(@Ln_Medical_AMNT AS VARCHAR), '') + ', MedicalOrdered_INDC = ' + ISNULL(@Lc_MedicalOrdered_TEXT, '') + ', TribunalCaseNo_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', OfLastPayment_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ControllingOrderFlag_CODE = ' + ISNULL(@Lc_SelectOrdCur_ControllingOrderFlag_CODE, '') + ', NewOrderFlag_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', File_ID = ' + ISNULL(@Lc_SelectOrdCur_File_ID, '');

     INSERT EOBLK_Y1
            (TransHeader_IDNO,
             IVDOutOfStateFips_CODE,
             Transaction_DATE,
             BlockSeq_NUMB,
             StFipsOrder_CODE,
             CntyFipsOrder_CODE,
             SubFipsOrder_CODE,
             Order_IDNO,
             FilingOrder_DATE,
             TypeOrder_CODE,
             DebtType_CODE,
             OrderFreq_CODE,
             OrderFreq_AMNT,
             OrderEffective_DATE,
             OrderEnd_DATE,
             OrderCancel_DATE,
             FreqOrderArrears_CODE,
             FreqOrderArrears_AMNT,
             OrderArrearsTotal_AMNT,
             ArrearsAfdcFrom_DATE,
             ArrearsAfdcThru_DATE,
             ArrearsAfdc_AMNT,
             ArrearsNonAfdcFrom_DATE,
             ArrearsNonAfdcThru_DATE,
             ArrearsNonAfdc_AMNT,
             FosterCareFrom_DATE,
             FosterCareThru_DATE,
             FosterCare_AMNT,
             MedicalFrom_DATE,
             MedicalThru_DATE,
             Medical_AMNT,
             MedicalOrdered_INDC,
             TribunalCaseNo_TEXT,
             OfLastPayment_DATE,
             ControllingOrderFlag_CODE,
             NewOrderFlag_INDC,
             File_ID)
     VALUES ( @An_TransHeader_IDNO,--TransHeader_IDNO
              @Ac_StateFips_CODE,--IVDOutOfStateFips_CODE
              @Ld_Generated_DATE,--Transaction_DATE
              @Li_Ord_QNTY,--BlockSeq_NUMB
              SUBSTRING(@Lc_SelectOrdCur_IssuingOrderFips_CODE, 1, 2),--StFipsOrder_CODE
              SUBSTRING(@Lc_SelectOrdCur_IssuingOrderFips_CODE, 3, 3),--CntyFipsOrder_CODE
              SUBSTRING(@Lc_SelectOrdCur_IssuingOrderFips_CODE, 6, 2),--SubFipsOrder_CODE
              @Ln_SelectOrdCur_Order_IDNO,--Order_IDNO
              @Ld_SelectOrdCur_OrderIssued_DATE,--FilingOrder_DATE
              @Lc_SelectOrdCur_TypeOrder_CODE,--TypeOrder_CODE
              @Lc_SelectOrdCur_TypeDebt_CODE,--DebtType_CODE
              @Lc_SelectOrdCur_OrderFreq_CODE,--OrderFreq_CODE
              @Ln_SelectOrdCur_Periodic_AMNT,--OrderFreq_AMNT
              @Ld_SelectOrdCur_OrderEffective_DATE,--OrderEffective_DATE
              @Ld_SelectOrdCur_OrderEnd_DATE,--OrderEnd_DATE
              @Ld_Low_DATE,--OrderCancel_DATE
              @Lc_SelectOrdCur_FreqOrderArrears_CODE,--FreqOrderArrears_CODE
              @Ln_SelectOrdCur_FreqOrderArrears_AMNT,--FreqOrderArrears_AMNT
              @Ln_OrderArrearsTotal_AMNT,--OrderArrearsTotal_AMNT
              @Ld_ArrearsAfdcFrom_DATE,--ArrearsAfdcFrom_DATE
              @Ld_ArrearsAfdcThru_DATE,--ArrearsAfdcThru_DATE
              @Ln_ArrearsAfdc_AMNT,--ArrearsAfdc_AMNT
              @Ld_ArrearsNonAfdcFrom_DATE,--ArrearsNonAfdcFrom_DATE
              @Ld_ArrearsNonAfdcThru_DATE,--ArrearsNonAfdcThru_DATE
              @Ln_ArrearsNonAfdc_AMNT,--ArrearsNonAfdc_AMNT
              @Ld_FosterCareFrom_DATE,--FosterCareFrom_DATE
              @Ld_FosterCareThru_DATE,--FosterCareThru_DATE
              @Ln_FosterCare_AMNT,--FosterCare_AMNT
              @Ld_MedicalFrom_DATE,--MedicalFrom_DATE
              @Ld_MedicalThru_DATE,--MedicalThru_DATE
              @Ln_Medical_AMNT,--Medical_AMNT
              @Lc_MedicalOrdered_TEXT,--MedicalOrdered_INDC
              @Lc_Space_TEXT,--TribunalCaseNo_TEXT
              @Ld_Low_DATE,--OfLastPayment_DATE
              @Lc_SelectOrdCur_ControllingOrderFlag_CODE,--ControllingOrderFlag_CODE
              @Lc_Space_TEXT,--NewOrderFlag_INDC
              @Lc_SelectOrdCur_File_ID --File_ID
     );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT EOBLK_Y1 - Failed';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH SelectOrd_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM SelectOrd_CUR INTO @Ln_SelectOrdCur_Order_IDNO, @Ln_SelectOrdCur_OrderSeq_NUMB, @Lc_SelectOrdCur_File_ID, @Lc_SelectOrdCur_TypeOrder_CODE, @Ld_SelectOrdCur_OrderEffective_DATE, @Ld_SelectOrdCur_OrderEnd_DATE, @Lc_SelectOrdCur_FreqOrderArrears_CODE, @Ln_SelectOrdCur_FreqOrderArrears_AMNT, @Lc_SelectOrdCur_ControllingOrderFlag_CODE, @Lc_SelectOrdCur_OrderFreq_CODE, @Ln_SelectOrdCur_Periodic_AMNT, @Lc_SelectOrdCur_IssuingOrderFips_CODE, @Ld_SelectOrdCur_OrderIssued_DATE, @Lc_SelectOrdCur_TypeDebt_CODE, @Ln_SelectOrdCur_ObligationSeq_NUMB, @Lc_SelectOrdCur_CoverageMedical_CODE;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'SelectOrd_CUR') IN (0, 1)
    BEGIN
     CLOSE SelectOrd_CUR;

     DEALLOCATE SelectOrd_CUR;
    END;

   IF @Li_Ord_QNTY = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NO ORDER/OBLE_Y1 INFORMATION FOUND FOR : ' + CAST(@An_Case_IDNO AS VARCHAR);

     RAISERROR(50001,16,1);
    END;

   IF @Li_Ord_QNTY < @Ai_Order_QNTY
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'THIS CASE REQUIRES MINIMUM' + CAST(@Ai_Order_QNTY AS VARCHAR) + ' ORDER BLOCKS : ' + CAST(@An_Case_IDNO AS VARCHAR);

     RAISERROR(50001,16,1);
    END;

   SET @Ai_Order_QNTY = @Li_Ord_QNTY;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'SelectOrd_CUR') IN (0, 1)
    BEGIN
     CLOSE SelectOrd_CUR;

     DEALLOCATE SelectOrd_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
