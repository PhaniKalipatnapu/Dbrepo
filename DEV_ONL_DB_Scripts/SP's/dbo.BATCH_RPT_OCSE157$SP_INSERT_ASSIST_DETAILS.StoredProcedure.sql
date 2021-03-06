/****** Object:  StoredProcedure [dbo].[BATCH_RPT_OCSE157$SP_INSERT_ASSIST_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name          : BATCH_RPT_OCSE157$SP_INSERT_ASSIST_DETAILS
Programmer Name			: IMP Team
Description             : This procedure is used for generating monthly OCSE-157 report
Frequency               : Monthly/Annually
Developed On            : 09/07/2012
Called BY               : This procedure is called by BATCH_RPT_OCSE157$SP_GENERATE_OCSE157
Called On               : 
--------------------------------------------------------------------------------------------------------------------
Modified BY             :
Modified On             :
Version No              : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_RPT_OCSE157$SP_INSERT_ASSIST_DETAILS] (
 @Ad_BeginFiscal_DATE                         DATE,
 @Ad_EndFiscal_DATE                           DATE,
 @Ac_TypeReport_CODE                          CHAR(1),
 @An_SupportYearMonth_NUMB                    NUMERIC(6,0),
 @Ac_Job_ID			                          CHAR(7),
 @Ad_Run_DATE		                          DATE,
 @Ac_Msg_CODE                                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT                    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE 
          @Li_ReceiptReversed1250_NUMB                  INT = 1250,
          @Li_ReceiptDistributed1820_NUMB               INT = 1820,
          @Lc_Space_TEXT                                CHAR(1) = ' ',
          @Lc_Yes_INDC                                  CHAR(1) = 'Y',
          @Lc_No_INDC                                   CHAR(1) = 'N',
          @Lc_CaseStatusClosed_CODE                     CHAR(1) = 'C',
          @Lc_OrderTypeVoluntary_CODE                   CHAR(1) = 'V',
          @Lc_OrderTypeJudicialFinal_CODE               CHAR(1) = 'J',
          @Lc_OrderTypeJudicialInterim_CODE             CHAR(1) = 'I',
          @Lc_OrderTypeAdministrative_CODE              CHAR(1) = 'A',
          @Lc_OrderTypeTribal_CODE                      CHAR(1) = 'T',
          @Lc_RelationshipCaseDp_CODE                   CHAR(1) = 'D',
          @Lc_StatusCaseMemberActive_CODE               CHAR(1) = 'A',
          @Lc_WelfareTypeTanf_CODE                      CHAR(1) = 'A',
          @Lc_WelfareTypeNonIve_CODE                    CHAR(1) = 'F',
          @Lc_RespondInitResponding_CODE                CHAR(1) = 'R',
          @Lc_RespondingInternational_CODE		        CHAR(1) = 'Y',
          @Lc_RespondingTribal_CODE				        CHAR(1) = 'S',
          @Lc_CaseStatusOpen_CODE                       CHAR(1) = 'O',
          @Lc_StatusSuccess_CODE                        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE                         CHAR(1) = 'F',
          @Lc_RespondInitInitiate_CODE                  CHAR(1) = 'I',
          @Lc_InitiateInternational_CODE                CHAR(1) = 'C',
          @Lc_InitiateTribal_CODE                       CHAR(1) = 'T',
          @Lc_CaseTypeNonIvd_CODE                       CHAR(1) = 'H',
          @Lc_RelationshipCaseCp_CODE                   CHAR(1) = 'C',
          @Lc_WelfareTypeMedicaid_CODE                  CHAR(1) = 'M',
          @Lc_RespondInitNonInterstate_CODE             CHAR(1) = 'N',
          @Lc_RelationshipCaseNcp_CODE                  CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE            CHAR(1) = 'P',
          @Lc_VerificationStatusGood_CODE               CHAR(1) = 'Y',
          @Lc_TypeRecordOriginal_CODE                   CHAR(1) = 'O',
          @Lc_InterstateDirectionInput_INDC             CHAR(1) = 'I',
          @Lc_ActionRequest_CODE                        CHAR(1) = 'R',
          @Lc_StatusReceiptHeld_CODE                    CHAR(1) = 'H',
          @Lc_InsOrderedBoth_CODE                       CHAR(1) = 'B',
          @Lc_InsOrderedBothUncond_CODE                 CHAR(1) = 'D',
          @Lc_InsOrderedNcpOnly_CODE                    CHAR(1) = 'A',
          @Lc_InsOrderedNcpOnlyUncond_CODE              CHAR(1) = 'U',
          @Lc_InsOrderedCpOnly_CODE                     CHAR(1) = 'C',
          @Lc_InsOrderedCpOnlyUncond_CODE               CHAR(1) = 'O',
          @Lc_WelfareTypeNonIvd_CODE                    CHAR(1) = 'H',
          @Lc_TypeRecordPrior_CODE                      CHAR(1) = 'P',
          @Lc_RecipientTypeCpNcp_CODE                   CHAR(1) = '1',
          @Lc_RecipientTypeFips_CODE                    CHAR(1) = '2',
          @Lc_RecipientTypeOthp_CODE                    CHAR(1) = '3',
          @Lc_AsstTypeCurrent_CODE                      CHAR(1) = 'C',
          @Lc_AsstTypeFormer_CODE                       CHAR(1) = 'F',
          @Lc_AsstTypeNever_CODE                        CHAR(1) = 'N',
          @Lc_CaseStatusFiscalClose_CODE                CHAR(1) = 'K',
          @Lc_TypeOrderEstablished_CODE                 CHAR(1) = 'O',
          @Lc_TypeOrderNotEstablished_CODE              CHAR(1) = 'S',
          @Lc_TypePaternityEstablished_CODE             CHAR(1) = 'P',
          @Lc_ReportTypeAnnual_CODE                     CHAR(1) = 'A',
          @Lc_GoodCauseApproved_CODE                    CHAR(1) = 'A',
          @Lc_CaseTypeTanf_CODE                         CHAR(1) = 'A',
          @Lc_ProvideInfoFailed_CODE                    CHAR(1) = 'P',
          @Lc_HearingAppearFailed_CODE                  CHAR(1) = 'H',
          @Lc_Unmarried_CODE                            CHAR(1) = 'U',
          @Lc_StateTypeFormerAssitance_CODE             CHAR(1) = 'S',
          @Lc_StateTypeTanf_CODE                        CHAR(1) = 'A',
          @Lc_StateTypeFosterArrears_CODE               CHAR(1) = 'C',
          @Lc_StateTypeFosterCare_CODE                  CHAR(1) = 'F',
          @Lc_StateTypeMedicalCare_CODE                 CHAR(1) = 'M',
          @Lc_EnsdArrears_CODE                          CHAR(1) = 'A',
          @Lc_Msg_CODE                                  CHAR(1) = NULL,
          @Lc_DebtTypeGeneticTest_CODE                  CHAR(2) = 'GT',
          @Lc_CountryUs_CODE                            CHAR(2) = 'US',
          @Lc_DebtTypeSpousalSupp_CODE                  CHAR(2) = 'SS',
          @Lc_DebtTypeChildSupp_CODE                    CHAR(2) = 'CS',
          @Lc_DebtTypeMedicalSupp_CODE                  CHAR(2) = 'MS',
          @Lc_DebtTypeCashMedical_CODE                  CHAR(2) = 'CM',          
          @Lc_DisburseStatusOutstanding_CODE            CHAR(2) = 'OU',
          @Lc_DisburseStatusTransferEft_CODE            CHAR(2) = 'TR',
          @Lc_CaseCategoryMedicaidOnly_CODE             CHAR(2) = 'MO', 
          @Lc_CaseCategoryMedicalServices_CODE          CHAR(2) = 'MS',        
          @Lc_AddressTypeInt_CODE                       CHAR(3) = 'INT',
          @Lc_FunctionEnforcement_CODE                  CHAR(3) = 'ENF',
          @Lc_FunctionEstablishment_CODE                CHAR(3) = 'EST',
          @Lc_PaternityEstLegaladopt_CODE               CHAR(3) = 'LA',
          @Lc_PaternityEstNmother_CODE                  CHAR(3) = 'BM',          
          @Lc_StatusEstablished_CODE                    CHAR(3) = 'E',
          @Lc_LineNo24_TEXT                             CHAR(3) = '24',
          @Lc_LineNo26_TEXT                             CHAR(3) = '26',
          @Lc_TableCsen_IDNO                            CHAR(4) = 'CSEN',
          @Lc_TableSubIfip_IDNO                         CHAR(4) = 'IFIP',
          @Lc_TranStatusSr_CODE                         CHAR(4) = 'SR',
          @Lc_statusEnforceNJUR_CODE                    CHAR(4) = 'NJUR',
          @Lc_FarSromc_CODE                             CHAR(5) = 'SROMC',
          @Lc_FarSrooc_CODE                             CHAR(5) = 'SROOC',
          @Lc_FarSropp_CODE                             CHAR(5) = 'SROPP',
          @Lc_FarSrord_CODE                             CHAR(5) = 'SRORD',
          @Lc_FarSross_CODE                             CHAR(5) = 'SROSS',
          @Lc_RestartLoc_TEXT                           CHAR(5) = ' ',
          @Lc_RestartLoc1_TEXT                          CHAR(5) = 'STEP1',
          @Lc_RestartLoc2_TEXT                          CHAR(5) = 'STEP2',
          @Lc_RestartLoc3_TEXT                          CHAR(5) = 'STEP3',
          @Lc_RestartLoc4_TEXT                          CHAR(5) = 'STEP4',
          @Lc_RestartLoc5_TEXT                          CHAR(5) = 'STEP5',
          @Lc_RestartLoc6_TEXT                          CHAR(5) = 'STEP6',
          @Lc_DisbursementTypeRefund_CODE               CHAR(5) = 'REFND',
          @Lc_DisbursementTypeRefundOthp_CODE           CHAR(5) = 'ROTHP',
          @Lc_FarRegoffsobyObligee_CODE                 CHAR(5) = 'ERFSM',
          @Lc_FarRegfsomodObligee_CODE                  CHAR(5) = 'ERFSO',
          @Lc_FarRegoffsomodivdagy_CODE                 CHAR(5) = 'ERFSS',
          @Lc_FarRegfsomodenfstagy_CODE                 CHAR(5) = 'ERMEE',
          @Lc_FarRegoffsomodenfobl_CODE                 CHAR(5) = 'ERMEM',
          @Lc_FarRefsomodenfObligr_CODE                 CHAR(5) = 'ERMEO',
          @Lc_FarRegfsoenfObligor_CODE                  CHAR(5) = 'ERREG',
          @Lc_FarRegfsoenfObligee_CODE                  CHAR(5) = 'ERREO',
          @Lc_FarRegfsoenfstAgency_CODE                 CHAR(5) = 'ERRES',                   
          @Lc_DisburseStatusCashed_CODE                 CHAR(7) = 'CA',
          @Lc_MonthSep_TEXT                             CHAR(10) = 'September',
          @Lc_MonthOct_TEXT                             CHAR(10) = 'October',
          @Lc_LookInSlog_TEXT                           CHAR(20) = 'SLOG',
          @Ls_Procedure_NAME							VARCHAR(100) = 'BATCH_RPT_OCSE157$SP_GENERATE_OCSE157',
          @Ls_DescriptionError_TEXT                     VARCHAR(4000) = NULL,
          @Ld_Low_DATE                                  DATE = '01/01/0001',
          @Ld_High_DATE                                 DATE = '12/31/9999';          
          
   DECLARE
          @Ln_Isexist_NUMB                              NUMERIC(6), 
          @Ln_RowCount_QNTY                             NUMERIC(10),
          @Lc_Monthly_INDC                              CHAR(1),
          @Lc_YyyymmBegin_TEXT                          CHAR(6),
          @Lc_YyyymmEnd_TEXT                            CHAR(6),
          @Ls_Sql_TEXT                                  VARCHAR(200),
          @Ls_Sqldata_TEXT                              VARCHAR(4000), 
          @Ls_ErrorMessage_TEXT                         VARCHAR (4000),         
          @Ld_PriorFyBegin_DATE                         DATE,
          @Ld_PriorFyEnd_DATE                           DATE;       

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'CHECK RESTART KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'');

   SELECT @Lc_RestartLoc_TEXT = LTRIM(RTRIM(r.RestartKey_TEXT))
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Ac_Job_ID
      AND r.Run_DATE =  @Ad_Run_DATE;

   SET @Ls_Sql_TEXT = 'CHECKS RESTART KEY ';
   SET @Ls_Sqldata_TEXT = 'YEAR_MONTH: ' + ISNULL(CAST(@An_SupportYearMonth_NUMB AS VARCHAR),' ') + ' , BEGIN FISCAL: ' + CAST(@Ad_BeginFiscal_DATE AS VARCHAR) 
			+ ' , END FISCAL: ' + CAST(@Ad_EndFiscal_DATE AS VARCHAR) 
			+ ' , REP TYPE: ' + @Ac_TypeReport_CODE;

   IF @Lc_RestartLoc_TEXT = @Lc_Space_TEXT
    BEGIN
     -- To Check if data exists in ASST Table for that period
     SET @Ls_Sql_TEXT = 'SELECT RASST_Y1 1 ';
     SET @Ls_Sqldata_TEXT = 'SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'');

     SELECT @Ln_Isexist_NUMB = COUNT(1)
       FROM RASST_Y1 r
      WHERE r.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB;

     IF (@Ln_Isexist_NUMB > 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE RASST_Y1 ';
       SET @Ls_Sqldata_TEXT = 'SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'');

       DELETE FROM RASST_Y1
        WHERE SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF (@Ln_RowCount_QNTY = 0)
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END
     SET @Ls_Sql_TEXT = 'INSERT RASST_Y1 1';     
     SET @Ls_Sqldata_TEXT = 'SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'');
   
     INSERT INTO RASST_Y1
                 (SupportYearMonth_NUMB,
                  Case_IDNO,
                  TypeAsst_CODE,
                  StatusCase_CODE,
                  TypeCase_CODE,
                  CaseCategory_CODE,
                  CaseCategoryPrev_CODE,
                  RespondInit_CODE,
                  Office_IDNO,
                  TypeEstablish_CODE,
                  TypeOrder_CODE,
                  OrderEffective_DATE,
                  Run_DATE)
     SELECT @An_SupportYearMonth_NUMB AS SupportYearMonth_NUMB,
            c.Case_IDNO,
            CASE
             WHEN a.asst_type_current = @Lc_Yes_INDC
              THEN @Lc_AsstTypeCurrent_CODE
             WHEN a.asst_type_former = @Lc_Yes_INDC
              THEN @Lc_AsstTypeFormer_CODE
             ELSE @Lc_AsstTypeNever_CODE
            END AS TypeAsst_CODE,
            CASE
             WHEN c.StatusCase_CODE = @Lc_CaseStatusClosed_CODE
                  AND vw.Case_IDNO IS NOT NULL
              THEN @Lc_CaseStatusFiscalClose_CODE
             ELSE c.StatusCase_CODE
            END AS StatusCase_CODE,
            c.TypeCase_CODE,
            c.CaseCategory_CODE,
            c.CaseCategory_CODE,
            c.RespondInit_CODE,
            c.Office_IDNO,
            CASE
             WHEN ISNULL(s.TypeOrder_CODE, @Lc_OrderTypeVoluntary_CODE) <> @Lc_OrderTypeVoluntary_CODE
              THEN @Lc_TypeOrderEstablished_CODE
             ELSE @Lc_TypeOrderNotEstablished_CODE
            END AS TypeEstablish_CODE,
            ISNULL(s.TypeOrder_CODE, @Lc_OrderTypeVoluntary_CODE) AS TypeOrder_CODE,
            ISNULL(s.OrderEffective_DATE, @Ld_Low_DATE) AS OrderEffective_DATE,
             @Ad_Run_DATE AS Run_DATE
       FROM CASE_Y1 c
            LEFT OUTER JOIN SORD_Y1 s
             ON c.Case_IDNO = s.Case_IDNO
                AND s.EndValidity_DATE = @Ld_High_DATE
            LEFT OUTER JOIN (SELECT h.Case_IDNO,
                                    MAX(CASE
                                         WHEN h.End_DATE < @Ad_EndFiscal_DATE
                                          THEN @Lc_Yes_INDC
                                         ELSE @Lc_No_INDC
                                        END) AS asst_type_former,
                                    MAX(CASE
                                         WHEN h.End_DATE >= @Ad_EndFiscal_DATE
                                          THEN @Lc_Yes_INDC
                                         ELSE @Lc_No_INDC
                                        END) AS asst_type_current,
                                    @Lc_No_INDC AS init_responding
                               FROM CMEM_Y1 b,
                                    MHIS_Y1 h
                              WHERE h.Case_IDNO = b.Case_IDNO
                                AND h.MemberMci_IDNO = b.MemberMci_IDNO
                                AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
                                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                AND h.TypeWelfare_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonIve_CODE)
                              GROUP BY h.Case_IDNO
                             UNION ALL
                             SELECT c.Case_IDNO,
                                    MAX(CASE
                                         WHEN c.End_DATE = @Ld_High_DATE
                                              AND c.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
                                              AND c.IVDOutOfStateTypeCase_CODE IN (@Lc_StateTypeFormerAssitance_CODE)
                                          THEN @Lc_Yes_INDC
                                         ELSE @Lc_No_INDC
                                        END) AS asst_type_former,
                                    MAX(CASE
                                         WHEN c.End_DATE = @Ld_High_DATE
                                              AND c.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
                                              AND c.Status_CODE = @Lc_CaseStatusOpen_CODE
                                              AND c.IVDOutOfStateTypeCase_CODE IN (@Lc_StateTypeTanf_CODE, @Lc_StateTypeFosterArrears_CODE, @Lc_StateTypeFosterCare_CODE, @Lc_StateTypeMedicalCare_CODE)
                                          THEN @Lc_Yes_INDC
                                         ELSE @Lc_No_INDC
                                        END) AS asst_type_current,
                                    @Lc_RespondInitResponding_CODE AS init_responding
                               FROM ICAS_Y1 c
                              WHERE c.EndValidity_DATE = @Ld_High_DATE
                              GROUP BY c.Case_IDNO) AS a
             ON c.Case_IDNO = a.Case_IDNO
                AND (CASE c.RespondInit_CODE
                      WHEN @Lc_RespondInitResponding_CODE
                       THEN @Lc_RespondInitResponding_CODE
                      WHEN @Lc_RespondingInternational_CODE
                       THEN @Lc_RespondingInternational_CODE
                      WHEN @Lc_RespondingTribal_CODE
                       THEN @Lc_RespondingTribal_CODE
                      ELSE @Lc_No_INDC
                     END) = a.init_responding
            LEFT OUTER JOIN (SELECT DISTINCT  b.Case_IDNO
                               FROM UCASE_V1 b
                              WHERE b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                                AND b.EndValidity_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE) AS vw
             ON c.Case_IDNO = vw.Case_IDNO;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF (@Ln_RowCount_QNTY = 0)
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'UPDATE RASST_Y1 - TypeEstablish_CODE = P';
     SET @Ls_Sqldata_TEXT ='TypeEstablish_CODE ='+ISNULL(@Lc_TypePaternityEstablished_CODE,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', TypeEstablish_CODE = ' + ISNULL(@Lc_TypeOrderNotEstablished_CODE,'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseDp_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'')+',PaternityEst_INDC = '+ ISNULL(@Lc_Yes_INDC,'');

     UPDATE a
        SET TypeEstablish_CODE = @Lc_TypePaternityEstablished_CODE
       FROM RASST_Y1 AS a
      WHERE a.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
        AND a.TypeEstablish_CODE = @Lc_TypeOrderNotEstablished_CODE
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 AS b,
                           DEMO_Y1 AS c,
                           MPAT_Y1 m
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND c.MemberMci_IDNO = b.MemberMci_IDNO
                       AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
                       AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                       AND m.MemberMci_IDNO = c.MemberMci_IDNO
                       AND m.PaternityEst_INDC = @Lc_Yes_INDC);

     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(@Lc_RestartLoc1_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ad_Run_DATE              =  @Ad_Run_DATE,
      @As_RestartKey_TEXT       = @Lc_RestartLoc1_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END

     SET @Lc_RestartLoc_TEXT = @Lc_Space_TEXT;
    END

   IF @Lc_RestartLoc_TEXT = @Lc_Space_TEXT
       OR @Lc_RestartLoc_TEXT = @Lc_RestartLoc1_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT RC157_Y1-1';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'');

     -- Delete the RC157 records for the report type. Also delete Annual report for performance on RC157
     SELECT @Ln_Isexist_NUMB = COUNT(1)
       FROM RC157_Y1 C
      WHERE C.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND C.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND C.TypeReport_CODE IN (@Ac_TypeReport_CODE, @Lc_ReportTypeAnnual_CODE);

     IF (@Ln_Isexist_NUMB > 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE RC157_Y1';
       SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'');

       DELETE c
         FROM RC157_Y1 c
        WHERE c.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
          AND c.EndFiscal_DATE = @Ad_EndFiscal_DATE
          AND c.TypeReport_CODE IN (@Ac_TypeReport_CODE, @Lc_ReportTypeAnnual_CODE);

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF (@Ln_RowCount_QNTY = 0)
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'INSERT RC157_Y1';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'') + ' , StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'')+
                   ' , RespondInit_CODE= ' + ISNULL(@Lc_RespondInitInitiate_CODE,'') + ' ,RespondInitResponding_CODE = ' + ISNULL(@Lc_RespondInitResponding_CODE,'')+ ' , Line1_INDC = ' + ISNULL(@Lc_Yes_INDC,'') + ', CaseCategory_CODE = ' + ISNULL(@Lc_CaseCategoryMedicaidOnly_CODE,'') +
                   ' ,  TypeAsst_CODE = ' + ISNULL(@Lc_AsstTypeNever_CODE,'')+ ' ,InitiateTribal_CODE= ' + ISNULL(@Lc_InitiateTribal_CODE,'')+ ', RespondingTribal_CODE = ' + ISNULL(@Lc_RespondingTribal_CODE,'') + ', InitiateInternational_CODE = ' + ISNULL(@Lc_InitiateInternational_CODE,'')+
                   ' ,RespondingInternational_CODE = ' + ISNULL(@Lc_RespondingInternational_CODE,'')+' ,RespondInitInitiate_CODE= ' + ISNULL(@Lc_RespondInitInitiate_CODE,'') + ',RespondInitResponding_CODE =' + ISNULL(@Lc_RespondInitResponding_CODE,'') +  ' , TypeCase_CODE = ' + ISNULL(@Lc_CaseTypeNonIvd_CODE,'')+
                   ' , TypeEstablish_CODE = ' + ISNULL(@Lc_TypeOrderNotEstablished_CODE,'')+', NonCoop_CODE = '  + ISNULL(@Lc_GoodCauseApproved_CODE,'') + ',CaseStatusFiscalClose_CODE = ' + ISNULL(@Lc_CaseStatusFiscalClose_CODE,'')+ ',ProvideInfoFailed_CODE= ' + ISNULL(@Lc_ProvideInfoFailed_CODE,'')+
                   ' ,Line18_INDC = ' + ISNULL(@Lc_No_INDC,'')+' , HearingAppearFailed_CODE = ' + ISNULL(@Lc_HearingAppearFailed_CODE,'')+',Lc_CaseTypeTanf_CODE = ' + ISNULL(@Lc_CaseTypeTanf_CODE,'')+', GoodCause_CODE = ' + ISNULL(@Lc_GoodCauseApproved_CODE,'')+ ', OrderTypeJudicialFinal_CODE = ' + ISNULL(@Lc_OrderTypeJudicialFinal_CODE,'') +
                   ',OrderTypeJudicialInterim_CODE = ' + ISNULL(@Lc_OrderTypeJudicialInterim_CODE,'') + 'OrderTypeAdministrative_CODE = ' + ISNULL(@Lc_OrderTypeAdministrative_CODE, '') + 'OrderTypeTribal_CODE = ' + ISNULL(@Lc_OrderTypeTribal_CODE, '') + ',TypeOrderEstablished_CODE = ' + ISNULL(@Lc_TypeOrderEstablished_CODE,'')+ 
                   ', WelfareTypeNonIve_CODE = ' + ISNULL(@Lc_WelfareTypeNonIve_CODE,'') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@An_SupportYearMonth_NUMB AS VARCHAR),'')+ ' , EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseCp_CODE,'')+',CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'');
        
     INSERT INTO RC157_Y1
                 (BeginFiscal_DATE,
                  EndFiscal_DATE,
                  TypeReport_CODE,
                  Case_IDNO,
                  MemberMci_IDNO,
                  CaseRelationship_CODE,
                  Line1_INDC,
                  Line1a_INDC,
                  Line1b_INDC,
                  Line1c_INDC,
                  Line1d_INDC,
                  Line1e_INDC,
                  Line1f_INDC,
                  Line1g_INDC,
                  Line2_INDC,
                  Line2a_INDC,
                  Line2b_INDC,
                  Line2c_INDC,
                  Line2d_INDC,
                  Line2e_INDC,
                  Line2f_INDC,
                  Line2g_INDC,
                  Line2h_INDC,
                  Line2i_INDC,
                  Line3_INDC,
                  Line12_INDC,
                  Line14_INDC,
                  Line17_INDC,
                  Line18_INDC,
                  Line18a_INDC,
                  Line19_INDC,
                  Line20_INDC,
                  Line21_INDC,
                  Line21a_INDC,
                  Line22_INDC,
                  Line23_INDC,
                  Line28_INDC,
                  Line29_INDC,
                  Line35_INDC,
                  Line37_INDC,
                  Line38_INDC,
                  County_IDNO,
                  Office_IDNO,
                  Worker_ID)
     SELECT @Ad_BeginFiscal_DATE AS BeginFiscal_DATE,
            @Ad_EndFiscal_DATE AS EndFiscal_DATE,
            @Ac_TypeReport_CODE AS TypeReport_CODE,
            fci.Case_IDNO,
            fci.MemberMci_IDNO,
            fci.CaseRelationship_CODE,
            fci.Line1_INDC,-- Cases open at the End of the Fiscal Year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE)
                   AND fci.Line1_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line1a_INDC,-- Interstate Cases Initiated in This State Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE)
                   AND fci.Line1_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line1b_INDC,-- Interstate Cases Received From Another State Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND CaseCategory_CODE = @Lc_CaseCategoryMedicaidOnly_CODE
                   AND TypeAsst_CODE = @Lc_AsstTypeNever_CODE
                   AND fci.Line1_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line1c_INDC,-- Medicaid-Only IV-D Cases Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_InitiateTribal_CODE
                   AND fci.Line1_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line1d_INDC, -- State-Tribal IV-D Cases Initiated in This State Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_RespondingTribal_CODE
                   AND fci.Line1_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line1e_INDC, -- State-Tribal IV-D Cases Received From a Tribal IV-D Program Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_InitiateInternational_CODE
                   AND fci.Line1_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line1f_INDC, -- International IV-D Cases Initiated in This State Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_RespondingInternational_CODE
                   AND fci.Line1_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line1g_INDC, -- International IV-D Cases Received from Another Country Open at the End of the Fiscal year
            fci.Line2_INDC,-- Cases Open at the End of the Fiscal year With Support Orders Established
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_RespondInitInitiate_CODE
                   AND fci.Line2_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line2a_INDC,
            -- Interstate Cases Initiated in This State With Support Orders Established Open at the End of the Fiscal Year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_RespondInitResponding_CODE
                   AND fci.Line2_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line2b_INDC,
            -- Interstate Cases Received From State With Support Orders Established Open at the End of the Fiscal Year
            @Lc_No_INDC Line2c_INDC,
            -- Cases With Orders Established for Zero Cash Support Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND CaseCategory_CODE = @Lc_CaseCategoryMedicaidOnly_CODE
                   AND TypeAsst_CODE = @Lc_AsstTypeNever_CODE
                   AND fci.Line2_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line2d_INDC,
            -- Medicaid-Only IV-D Cases With Orders Established Open at the End of the Fiscal year
            @Lc_No_INDC Line2e_INDC,
            -- Arrears-Only IV-D Cases With Orders Established Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_InitiateTribal_CODE
                   AND fci.Line2_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line2f_INDC,
            -- State-Tribal IV-D Cases Initiated in This State With Support Orders Established Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_RespondingTribal_CODE
                   AND fci.Line2_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line2g_INDC,
            -- State-Tribal IV-D Cases With Support Orders Established Received From a Tribe Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_InitiateInternational_CODE
                   AND fci.Line2_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line2h_INDC,
            -- International IV-D Cases With Support Orders Established Initiated in This State Open at the End of the Fiscal year
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.RespondInit_CODE = @Lc_RespondingInternational_CODE
                   AND fci.Line2_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line2i_INDC,
            -- International IV-D Cases With Support Orders Established Received From Another Country Open at the End of the Fiscal year
            CASE
             WHEN (fci.StatusEnforce_code = @Lc_statusEnforceNJUR_CODE
                   AND fci.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE)
              THEN @Lc_Yes_Indc
             ELSE @Lc_No_INDC
            END AS Line3_INDC,
            -- Cases Open at the End of the Fiscal year for Which the State Has No Jurisdiction
            CASE
             WHEN (StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                   AND fci.Line1_INDC = @Lc_Yes_INDC
                   AND fci.TypeEstablish_CODE = @Lc_TypeOrderNotEstablished_CODE
                   AND fci.NonCoop_CODE <> @Lc_GoodCauseApproved_CODE)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line12_INDC,-- Cases Open at the End of the Fiscal Year Requiring Services to Establish an Order
            @Lc_No_INDC AS Line14_INDC,
            -- Title IV-A Cases Closed During the Fiscal Year Where a Child Support Payment Was Received
            @Lc_No_INDC AS Line17_INDC,-- Cases With Orders Established During the Fiscal year
            @Lc_No_INDC AS Line18_INDC,-- Cases With Collection During the Fiscal year
            @Lc_No_INDC AS Line18a_INDC,
            -- Interstate Cases Received From Another State With Collections During the Fiscal year
            CASE
             WHEN (StatusCase_CODE IN (@Lc_CaseStatusOpen_CODE, @Lc_CaseStatusFiscalClose_CODE)
                   AND TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                   AND fci.Line19_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line19_INDC,-- Cases Sent to Another State During the Fiscal Year
            CASE
             WHEN (StatusCase_CODE IN (@Lc_CaseStatusOpen_CODE, @Lc_CaseStatusFiscalClose_CODE)
                   AND TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                   AND fci.Line20_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line20_INDC,-- Cases Received From Another State During the Fiscal Year
            @Lc_No_INDC AS Line21_INDC,
            -- Cases Open at the End of the Fiscal year in Which Medical Support is Ordered
            @Lc_No_INDC AS Line21a_INDC,
            -- Cases Open at the End of the Fiscal year in Which Medical Support is Ordered and Provided
            @Lc_No_INDC AS Line22_INDC,
            -- Cases Open at the End of the Fiscal year Where Health Insurance is Ordered
            @Lc_No_INDC AS Line23_INDC,
            -- Cases Open at the End of the Fiscal year Where Health Insurance is Provided as Ordered
            @Lc_No_INDC AS Line28_INDC,-- Cases With Arrears Due During the Fiscal year
            @Lc_No_INDC AS Line29_INDC,-- Cases Paying Toward Arrears During the Fiscal Year
            @Lc_No_INDC AS Line35_INDC,-- Cases With Medical Coverage Received From any Source
            CASE
             WHEN (fci.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   AND fci.TypeCase_CODE = @Lc_CaseTypeTanf_CODE
                   AND fci.NonCoop_CODE IN (@Lc_ProvideInfoFailed_CODE, @Lc_HearingAppearFailed_CODE)
                   AND fci.Line1_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line37_INDC,
            -- Cases Open at the End of the Fiscal year in Which There is a Determination of Noncooperation
            CASE
             WHEN (fci.StatusCase_CODE IN (@Lc_CaseStatusOpen_CODE, @Lc_CaseStatusFiscalClose_CODE)
                   AND fci.TypeCase_CODE = @Lc_CaseTypeTanf_CODE
                   AND fci.GoodCause_CODE = @Lc_GoodCauseApproved_CODE)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line38_INDC,-- Cases Open During the Fiscal year with Good Cause Determinations
            fci.County_IDNO,
            fci.Office_IDNO,
            fci.Worker_ID
       FROM (SELECT @Ad_BeginFiscal_DATE AS Begin_DATE,
                    @Ad_EndFiscal_DATE AS End_DATE,
                    @Ac_TypeReport_CODE AS RepType_CODE,
                    b.Case_IDNO,
                    b.MemberMci_IDNO,
                    b.CaseRelationship_CODE,
                    x.RespondInit_CODE,
                    x.statusEnforce_code,
                    a.StatusCase_CODE,
                    CASE
                     WHEN a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                          AND a.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                          AND a.EligibleValidCase = 1
                          AND x.statusEnforce_CODE != @Lc_StatusEnforceNJUR_CODE
                      THEN @Lc_Yes_INDC
                     ELSE @Lc_No_INDC
                    END Line1_INDC,-- Cases open at the End of the Fiscal Year
                    CASE
                     WHEN a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                          AND a.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                          AND a.TypeEstablish_CODE = @Lc_TypeOrderEstablished_CODE
                          AND a.TypeOrder_CODE IN (@Lc_OrderTypeJudicialFinal_CODE,@Lc_OrderTypeJudicialInterim_CODE,@Lc_OrderTypeAdministrative_CODE,@Lc_OrderTypeTribal_CODE)
                          AND a.EligibleValidCase = 1
                          AND x.statusEnforce_CODE != @Lc_StatusEnforceNJUR_CODE
                      THEN @Lc_Yes_INDC
                     ELSE @Lc_No_INDC
                    END Line2_INDC,-- Cases Open at the End of the Fiscal year With Support Orders Established
                    x.County_IDNO,
                    x.Office_IDNO,
                    x.Worker_ID,
                    a.CaseCategory_CODE,
                    a.TypeAsst_CODE,
                    a.TypeEstablish_CODE,
                    a.TypeCase_CODE,
                    x.GoodCause_CODE,
                    x.NonCoop_CODE,
                    ISNULL(c.Line19_INDC, @Lc_No_INDC) Line19_INDC,
                    -- Cases Sent to Another State During the Fiscal Year
                    ISNULL(c.Line20_INDC, @Lc_No_INDC) Line20_INDC
               -- Cases Received From Another State During the Fiscal Year
               FROM (SELECT SupportYearMonth_NUMB,
                            Case_IDNO,
                            TypeAsst_CODE,
                            StatusCase_CODE,
                            CaseCategory_CODE,
                            CaseCategoryPrev_CODE,
                            RespondInit_CODE,
                            Office_IDNO,
                            TypeEstablish_CODE,
                            TypeOrder_CODE,
                            OrderEffective_DATE,
                            Run_DATE,
                            TypeCase_CODE,
                            CASE
                             WHEN a.TypeCase_CODE = @Lc_WelfareTypeNonIve_CODE
                              THEN 1
                             ELSE dbo.BATCH_RPT_OCSE157$SF_VALID_CASE(a.Case_IDNO, @Ad_EndFiscal_DATE)
                            END AS EligibleValidCase
                       FROM RASST_Y1 a
                      WHERE SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB) AS a,
                    CMEM_Y1 b ,
                    CASE_Y1 x 
                    LEFT OUTER JOIN
                    (SELECT c.Case_IDNO,
                            MAX(CASE
                                 WHEN (c.Referral_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                       AND c.ValidReferral_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                       AND c.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_InitiateInternational_CODE, @Lc_InitiateTribal_CODE))
                                  THEN @Lc_Yes_INDC
                                 ELSE @Lc_No_INDC
                                END) AS Line19_INDC,-- Cases Sent to Another State During the Fiscal Year
                            MAX(CASE
                                 WHEN (c.Referral_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                       AND c.ValidReferral_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                       AND c.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE))
                                  THEN @Lc_Yes_INDC
                                 ELSE @Lc_No_INDC
                                END) AS Line20_INDC -- Cases Received From Another State During the Fiscal Year
                       FROM (SELECT c.Case_IDNO,
                                    (SELECT MIN(e.Referral_DATE)
                                       FROM ICAS_Y1 e 
                                      WHERE e.Case_IDNO = c.Case_IDNO
                                        AND e.IVDOutOfStateFips_CODE = c.IVDOutOfStateFips_CODE) AS Referral_DATE,
                                    MIN(c.RespondInit_CODE) AS RespondInit_CODE,
                                    MIN(c.Referral_DATE) AS ValidReferral_DATE
                               FROM ICAS_Y1 c
                              WHERE c.EndValidity_DATE = @Ld_High_DATE
                              GROUP BY c.Case_IDNO,
                                       c.IVDOutOfStateFips_CODE) c
                      GROUP BY c.Case_IDNO) c
                  ON x.Case_IDNO = c.Case_IDNO
              WHERE a.Case_IDNO = b.Case_IDNO
                AND b.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE
                AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                AND a.Case_IDNO = x.Case_IDNO) AS fci;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF (@Ln_RowCount_QNTY = 0)
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END

     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-2';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(@Lc_RestartLoc2_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_RestartKey_TEXT       = @Lc_RestartLoc2_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END

     SET @Lc_RestartLoc_TEXT = @Lc_Space_TEXT;
    END

   IF (@Lc_RestartLoc_TEXT = @Lc_Space_TEXT
        OR @Lc_RestartLoc_TEXT = @Lc_RestartLoc2_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT RD157_Y1 DETAILS';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'');

     SELECT @Ln_Isexist_NUMB = COUNT(1)
       FROM RD157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE;

     IF @Ln_Isexist_NUMB > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE_OCSE157_CHILD_DETAIL ';
       SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'');

       DELETE d
         FROM RD157_Y1 d
        WHERE d.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
          AND d.EndFiscal_DATE = @Ad_EndFiscal_DATE
          AND d.TypeReport_CODE = @Ac_TypeReport_CODE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Lc_Monthly_INDC = CASE
                             WHEN (DATENAME(MONTH, @Ad_BeginFiscal_DATE) <> @Lc_MonthOct_TEXT
                                    OR DATENAME(MONTH, @Ad_EndFiscal_DATE) <> @Lc_MonthSep_TEXT)
                              THEN @Lc_Yes_INDC
                             ELSE @Lc_No_INDC
                            END;
     SET @Ls_Sql_TEXT = 'INSERT_OCSE157_CHILD_DETAILS_TBL';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ' , Line4_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ' , BornOfMarriage_CODE = ' + ISNULL(@Lc_Unmarried_CODE,'')+ + ',PaternityEstLegaladopt_CODE = ' + ISNULL(@Lc_PaternityEstLegaladopt_CODE,'')+',PaternityEstNmother_CODE = ' + ISNULL(@Lc_PaternityEstNmother_CODE,'')+' ,BornOfMarriage_CODE = ' + ISNULL(@Lc_No_INDC,'')+', Line5a_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Line13_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Line16_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Line33_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Line34_INDC = ' + ISNULL(@Lc_No_INDC,'')+
     ', PaternityEst_CODE = ' + ISNULL(@Lc_PaternityEstLegaladopt_CODE,'')+ ' ,PaternityEstNmother_CODE = ' + ISNULL(@Lc_PaternityEstNmother_CODE,'')+ ',PriorFyBegin_DATE = ' + ISNULL(CAST(@Ld_PriorFyBegin_DATE AS VARCHAR),'')+' , PriorFyEnd_DATE = ' + ISNULL(CAST(@Ld_PriorFyEnd_DATE AS VARCHAR),'') +' , Monthly_INDC  = ' + ISNULL(@Lc_Monthly_INDC,'')+ ' ,ReportTypeAnnual_CODE = ' + ISNULL(@Lc_ReportTypeAnnual_CODE,'')+',LOW_DATE = '+ ISNULL(CAST(@Ld_Low_DATE AS VARCHAR),'')+ ', Space_TEXT = ' + ISNULL(@Lc_Space_TEXT,'') + ' , StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'')+ ' , CaseStatusFiscalClose_CODE = ' + ISNULL(@Lc_CaseStatusFiscalClose_CODE,'') + ' ,RespondInitInitiate_CODE = ' + ISNULL(@Lc_RespondInitInitiate_CODE,'')+ 
     ' ,InitiateInternational_CODE = ' + ISNULL(@Lc_InitiateInternational_CODE,'')+ ',InitiateTribal_CODE = ' + ISNULL(@Lc_InitiateTribal_CODE,'')+ ' ,RespondInitNonInterstate_CODE = ' + ISNULL(@Lc_RespondInitNonInterstate_CODE,'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseDp_CODE,'')+' ,CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'') + ' , SupportYearMonth_NUMB = ' + ISNULL(CAST(@An_SupportYearMonth_NUMB AS VARCHAR),'')+ ',TypeCase_CODE = ' + ISNULL(@Lc_CaseTypeNonIvd_CODE,'')+ ' , TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeMedicaid_CODE,'')+ ',WelfareTypeTanf_CODE = ' + ISNULL( @Lc_WelfareTypeTanf_CODE,'');
      
     INSERT RD157_Y1
                 (BeginFiscal_DATE,
                  EndFiscal_DATE,
                  TypeReport_CODE,
                  MemberMci_IDNO,
                  Case_IDNO,
                  Birth_DATE,
                  PaternityEst_CODE,
                  PaternityEst_DATE,
                  PaternityEst_INDC,
                  BornOfMarriage_CODE,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  MemberSsn_NUMB,
                  BirthState_CODE,
                  Line4_INDC,
                  Line5_INDC,
                  Line5a_INDC,
                  Line6_INDC,
                  Line7_INDC,
                  Line8_INDC,
                  Line8a_INDC,
                  Line9_INDC,
                  Line10_INDC,
                  Line13_INDC,
                  Line16_INDC,
                  Line33_INDC,
                  Line34_INDC,
                  County_IDNO,
                  Office_IDNO,
                  Worker_ID)
     SELECT @Ad_BeginFiscal_DATE AS BeginFiscal_DATE,
            @Ad_EndFiscal_DATE AS EndFiscal_DATE,
            @Ac_TypeReport_CODE AS TypeReport_CODE,
            fci.MemberMci_IDNO,
            Case_IDNO,
            fci.Birth_DATE,
            ISNULL(fci.PaternityEst_CODE, @Lc_Space_TEXT) AS PaternityEst_CODE,
            fci.PaternityEst_DATE,
            fci.PaternityEst_INDC ,
            ISNULL(fci.BornOfMarriage_CODE, @Lc_Space_TEXT)AS BornOfMarriage_CODE,
            fci.Last_NAME,
            fci.First_NAME,
            fci.Middle_NAME,
            fci.MemberSsn_NUMB,
            fci.BirthState_CODE,
            Line4_INDC,-- Number of Children in IV-D Cases Open at the End of the Fiscal Year
            CASE
             WHEN (fci.BornOfMarriage_CODE IN (@Lc_No_INDC, @Lc_Unmarried_CODE)
                   AND Line4_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line5_INDC,
            -- Children in IV-D Cases Open at the End of the Current Federal Fiscal Year Who Were Born Out-of-Wedlock
            @Lc_No_INDC AS Line5a_INDC,
            -- Children in IV-D Cases Open at the End of the Prior Federal Fiscal Year Who Were Born Out-of-Wedlock
            CASE
             WHEN(fci.BornOfMarriage_CODE IN (@Lc_No_INDC, @Lc_Unmarried_CODE)
                  AND Line6_INDC = @Lc_Yes_INDC
                  AND fci.PaternityEst_INDC = @Lc_Yes_INDC
                  AND fci.PaternityEst_CODE NOT IN (@Lc_PaternityEstLegaladopt_CODE, @Lc_PaternityEstNmother_CODE))
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line6_INDC,
            -- Children in IV-D Cases Open during or at the End of the Fiscal year With Paternity Established or Acknowledged
            CASE
             WHEN (fci.PaternityEst_INDC = @Lc_Yes_INDC
                   AND Line4_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line7_INDC,-- Children in IV-D Cases Open at the End of the Fiscal year With Paternity Resolved
            CASE
             WHEN (fci.Statewide_INDC = @Lc_Yes_INDC
                         AND fci.Initiate_INDC = @Lc_Yes_INDC
                   AND fci.Birth_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line8_INDC,-- Children in the State Born Out-of-Wedlock During the Current Year
            CASE
             WHEN (fci.Initiate_INDC = @Lc_Yes_INDC
                   AND fci.BornOfMarriage_CODE = @Lc_Yes_INDC
                   AND fci.Birth_DATE BETWEEN @Ld_PriorFyBegin_DATE AND @Ld_PriorFyEnd_DATE
                   AND @Lc_Monthly_INDC = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line8a_INDC,-- Children in the State Born Out-of-Wedlock During the Prior Year
            CASE
             WHEN (fci.Statewide_INDC = @Lc_Yes_INDC
                           AND fci.Initiate_INDC = @Lc_Yes_INDC
                   AND fci.PaternityEst_INDC = @Lc_Yes_INDC
                   AND fci.PaternityEst_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line9_INDC,-- Children in the State With Paternity Established or Acknowledged During the Year
            CASE
             WHEN (fci.Statewide_INDC = @Lc_Yes_INDC
                           AND fci.Initiate_INDC = @Lc_Yes_INDC
                   AND fci.PaternityEst_INDC = @Lc_Yes_INDC
                   AND fci.PaternityEst_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                   AND fci.StatusEstablish_CODE = @Lc_Yes_INDC)
              THEN @Lc_Yes_INDC
             ELSE @Lc_No_INDC
            END AS Line10_INDC,-- Children in the State With Paternity Acknowledged During The Fiscal Year
            @Lc_No_INDC AS Line13_INDC,
            -- Children Requiring Paternity Determination Services in Cases Open at the End of the Fiscal Year
            @Lc_No_INDC AS Line16_INDC,
            -- Children in the IV-D Caseload for Whom Paternity Was Established or Acknowledged During the Fiscal Year
            @Lc_No_INDC AS Line33_INDC,
            -- Number of Children Determined Eligible for Medicaid in IV-D Cases Open at the End of the Fiscal Year
            @Lc_No_INDC AS Line34_INDC,
            -- Number of Children Determined Eligible for Medicaid in IV-D Cases Covered by Private Health Insurance
            fci.County_IDNO,
            Office_IDNO,
            Worker_ID
            
       FROM (SELECT a.MemberMci_IDNO,
                    s.Case_IDNO,
                    ISNULL(a.Birth_DATE, @Ld_Low_DATE) AS Birth_DATE,
                    p.PaternityEst_CODE,
                    p.StatusEstablish_CODE,
                    ISNULL(p.PaternityEst_DATE, @Ld_Low_DATE) AS PaternityEst_DATE,
                    ISNULL(LTRIM(RTRIM(p.PaternityEst_INDC)), @Lc_No_INDC) AS PaternityEst_INDC,
                    ISNULL(LTRIM(RTRIM(p.BornOfMarriage_CODE)), @Lc_No_INDC) AS BornOfMarriage_CODE,
                    a.Last_NAME,
                    a.First_NAME,
                    a.Middle_NAME,
                    a.MemberSsn_NUMB,
                    a.BirthState_CODE,
                    MAX(CASE
                         WHEN s.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                          AND DATEADD(year,20,a.Birth_DATE) > GETDATE()
                          THEN @Lc_Yes_INDC
                         ELSE @Lc_No_INDC
                        END) OVER(PARTITION BY c.MemberMci_IDNO) AS Line4_INDC,
                    -- Number of Children in IV-D Cases Open at the End of the Fiscal Year
                    MAX(CASE
                         WHEN s.StatusCase_CODE IN (@Lc_CaseStatusOpen_CODE, @Lc_CaseStatusFiscalClose_CODE)
                          AND DATEADD(year,20,a.Birth_DATE) > GETDATE()
                          THEN @Lc_Yes_INDC
                         ELSE @Lc_No_INDC
                        END) OVER(PARTITION BY c.MemberMci_IDNO) AS Line6_INDC,
                    -- Children in IV-D Cases Open during or at the End of the Fiscal year With Paternity Established or Acknowledged
                    MAX(CASE
                         WHEN s.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_InitiateInternational_CODE, @Lc_InitiateTribal_CODE, @Lc_RespondInitNonInterstate_CODE)
                          THEN @Lc_Yes_INDC
                         ELSE @Lc_No_INDC
                        END) OVER(PARTITION BY c.MemberMci_IDNO) AS Initiate_INDC,
                    MAX(CASE
                         WHEN s.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
                          THEN @Lc_Yes_INDC
                         ELSE @Lc_No_INDC
                        END) OVER(PARTITION BY c.MemberMci_IDNO) AS Responding_INDC,
                    r.County_IDNO,
                    r.Office_IDNO,
                    r.Worker_ID,
                    CASE
                     WHEN p.BornOfMarriage_CODE = @Lc_Yes_INDC
                           AND DATEADD(m, 216, ISNULL(a.Birth_DATE, @Ld_Low_DATE)) >=  @Ad_BeginFiscal_DATE
                           AND @Lc_Monthly_INDC = @Lc_Yes_INDC
                      THEN @Lc_Yes_INDC
                     ELSE @Lc_No_INDC
                    END AS Statewide_INDC,
                    ROW_NUMBER() OVER(PARTITION BY c.MemberMci_IDNO ORDER BY r.Line1_INDC DESC, ISNULL(m.WelfarePriority_NUMB, 3) ASC, s.StatusCase_CODE DESC, r.Case_IDNO DESC) AS rnm
               FROM RASST_Y1 s
               JOIN RC157_Y1 r
                 ON r.Case_IDNO = s.Case_IDNO
                AND r.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
                AND r.EndFiscal_DATE = @Ad_EndFiscal_DATE
                AND r.TypeReport_CODE = @Ac_TypeReport_CODE
                AND s.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                        AND s.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                     JOIN CMEM_Y1 c
                       ON s.Case_IDNO = c.Case_IDNO
                      AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
                AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
               JOIN DEMO_Y1 a
                 ON a.MemberMci_IDNO = c.MemberMci_IDNO
                
               LEFT OUTER JOIN MPAT_Y1 p
                 ON p.MemberMci_IDNO = a.MemberMci_IDNO
               LEFT OUTER JOIN (SELECT h.MemberMci_IDNO,
                                h.Case_IDNO,
                                h.TypeWelfare_CODE,
                                CASE
                                 WHEN h.TypeWelfare_CODE IN (@Lc_WelfareTypeMedicaid_CODE, @Lc_WelfareTypeTanf_CODE)
                                  THEN 1
                                 ELSE 2
                                END AS WelfarePriority_NUMB
                           FROM MHIS_Y1 h
                          WHERE h.Start_DATE <= @Ad_EndFiscal_DATE
                             AND h.End_DATE > @Ad_EndFiscal_DATE) AS m
                  ON m.MemberMci_IDNO = c.MemberMci_IDNO
                 AND m.Case_IDNO = c.Case_IDNO
                  ) AS fci
           WHERE fci.rnm = 1


     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END

     -- Cases With Orders Established for Zero Cash Support Open at the End of the Fiscal year
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 2C';
     SET @Ls_Sqldata_TEXT = 'Line2c_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ',BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ 
     ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ 
     ', Line2_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+
      ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'')+ ', TypeEstablish_CODE = ' + ISNULL(@Lc_TypeOrderEstablished_CODE,'')+
      ',CaseCategory_CODE = '+ ISNULL(@Lc_CaseCategoryMedicalServices_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'');
     
     UPDATE a
        SET Line2c_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line2_INDC = @Lc_Yes_INDC
        AND EXISTS (SELECT 1
                      FROM RASST_Y1 b
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                       AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                       AND b.TypeEstablish_CODE = @Lc_TypeOrderEstablished_CODE
                       AND NOT EXISTS (SELECT 1
                                         FROM OBLE_Y1 c
                                        WHERE c.Case_IDNO = b.Case_IDNO
                                          AND c.EndValidity_DATE = @Ld_High_DATE));

     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 2E';
     SET @Ls_Sqldata_TEXT = 'Line2e_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', CaseChargingArrears_CODE = ' + ISNULL(@Lc_EnsdArrears_CODE,'')+ ' ,TypeCase_CODE = '+ ISNULL(@Lc_CaseTypeNonIvd_CODE,'') + 
     ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'')+ ', BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ 
     ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ 
     ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line2_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ 
     ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+
     ',TypeOrder_CODE = '+ ISNULL(@Lc_OrderTypeVoluntary_CODE,'') + ', TypeEstablish_CODE = ' + ISNULL(@Lc_TypeOrderEstablished_CODE,'')+
      ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeGeneticTest_CODE,'');

     -- Arrears-Only IV-D Cases With Orders Established Open at the End of the Fiscal year
       
     UPDATE a
        SET Line2e_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a, ENSD_Y1 e
      WHERE a.Case_IDNO = e.Case_IDNO
        AND e.CaseChargingArrears_CODE = @Lc_EnsdArrears_CODE
        AND e.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
        AND e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
        AND a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line2_INDC = @Lc_Yes_INDC
        AND a.Case_IDNO IN (SELECT b.Case_IDNO
                              FROM RASST_Y1 b,
                                   (SELECT s.Case_IDNO,
                                           s.OweTotNaa_AMNT,
                                           s.AppTotNaa_AMNT,
                                           s.OweTotPaa_AMNT,
                                           s.AppTotPaa_AMNT,
                                           s.OweTotTaa_AMNT,
                                           s.AppTotTaa_AMNT,
                                           s.OweTotCaa_AMNT,
                                           s.AppTotCaa_AMNT,
                                           s.OweTotUpa_AMNT,
                                           s.AppTotUpa_AMNT,
                                           s.OweTotUda_AMNT,
                                           s.AppTotUda_AMNT,
                                           s.OweTotIvef_AMNT,
                                           s.AppTotIvef_AMNT,
                                           s.OweTotMedi_AMNT,
                                           s.AppTotMedi_AMNT,
                                           s.OweTotNffc_AMNT,
                                           s.AppTotNffc_AMNT,
                                           s.OweTotNonIvd_AMNT,
                                           s.AppTotNonIvd_AMNT,
                                           ROW_NUMBER() OVER(PARTITION BY s.Case_IDNO, s.OrderSeq_NUMB, s.ObligationSeq_NUMB ORDER BY s.SupportYearMonth_NUMB DESC, s.EventGlobalSeq_NUMB DESC) AS rno
                                      FROM LSUP_Y1 s
                                     WHERE s.SupportYearMonth_NUMB <= @An_SupportYearMonth_NUMB) AS l
                             WHERE l.rno = 1
                               AND ((l.OweTotNaa_AMNT - l.AppTotNaa_AMNT) + (l.OweTotPaa_AMNT - l.AppTotPaa_AMNT) + (l.OweTotTaa_AMNT - l.AppTotTaa_AMNT) + (l.OweTotCaa_AMNT - l.AppTotCaa_AMNT) + (l.OweTotUpa_AMNT - l.AppTotUpa_AMNT) + (l.OweTotUda_AMNT - l.AppTotUda_AMNT) + (l.OweTotIvef_AMNT - l.AppTotIvef_AMNT) + (l.OweTotMedi_AMNT - l.AppTotMedi_AMNT) + (l.OweTotNffc_AMNT - l.AppTotNffc_AMNT) + (l.OweTotNonIvd_AMNT - l.AppTotNonIvd_AMNT)) > 0
                               AND b.Case_IDNO = l.Case_IDNO
                               AND b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                               AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                               AND b.TypeOrder_CODE <> @Lc_OrderTypeVoluntary_CODE
                               AND b.TypeEstablish_CODE = @Lc_TypeOrderEstablished_CODE
                               AND b.Case_IDNO NOT IN (SELECT o.Case_IDNO
                                                         FROM OBLE_Y1 o
                                                        WHERE @Ad_EndFiscal_DATE BETWEEN o.BeginObligation_DATE AND o.EndObligation_DATE
                                                          AND o.EndValidity_DATE = @Ld_High_DATE
                                                          AND o.Periodic_AMNT > 0
                                                          AND o.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE));
   
     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-3';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(@Lc_RestartLoc3_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_RestartKey_TEXT       = @Lc_RestartLoc3_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END

     SET @Lc_RestartLoc_TEXT = @Lc_Space_TEXT;
    END

   IF @Lc_RestartLoc_TEXT = @Lc_Space_TEXT
       OR @Lc_RestartLoc_TEXT = @Lc_RestartLoc3_TEXT
    BEGIN
     -- Cases Open at the End of the Fiscal Year Requiring Services to Establish an Order
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 12';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line12_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', IoDirection_CODE = ' + ISNULL(@Lc_InterstateDirectionInput_INDC,'')+ ', Function_CODE = ' + ISNULL(@Lc_FunctionEnforcement_CODE,'')+ ', Action_CODE = ' + ISNULL(@Lc_ActionRequest_CODE,'')+ ', TranStatus_CODE = ' + ISNULL(@Lc_TranStatusSr_CODE,'')+
                       ', EndValidity_DATE = '+ ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'')+' , RespondInit_CODE = ' + ISNULL(@Lc_RespondInitResponding_CODE,'')+ ',RespondingInternational_CODE = '+ ISNULL(@Lc_RespondingInternational_CODE,'')+ ',RespondingTribal_CODE = ' + ISNULL(@Lc_RespondingTribal_CODE,'')+ ' , Reason_CODE = ' + ISNULL(@Lc_FarRegoffsobyObligee_CODE,'')+' ,FarRegfsomodObligee_CODE = '+ ISNULL(@Lc_FarRegfsomodObligee_CODE,'')+ ',FarRegoffsomodivdagy_CODE = ' + ISNULL(@Lc_FarRegoffsomodivdagy_CODE,'')+',FarRegfsomodenfstagy_CODE = ' + ISNULL(@Lc_FarRegfsomodenfstagy_CODE,'')+ ' ,FarRegoffsomodenfobl_CODE = ' + ISNULL(@Lc_FarRegoffsomodenfobl_CODE,'')+ 
                        ' ,FarRefsomodenfObligr_CODE = '+ ISNULL(@Lc_FarRefsomodenfObligr_CODE,'') +', FarRegfsoenfObligor_CODE = ' + ISNULL(@Lc_FarRegfsoenfObligor_CODE,'')+', FarRegfsoenfObligee_CODE = ' + ISNULL( @Lc_FarRegfsoenfObligee_CODE,'')+ ',FarRegfsoenfstAgency_CODE= ' + ISNULL(@Lc_FarRegfsoenfstAgency_CODE,'');
     UPDATE a
        SET Line12_INDC = @Lc_No_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line12_INDC = @Lc_Yes_INDC
        AND EXISTS (SELECT 1
                      FROM ICAS_Y1 i,
                           RASST_Y1 s
                     WHERE a.Case_IDNO = s.Case_IDNO
                       AND s.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                       AND s.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
                       AND s.Case_IDNO = i.Case_IDNO
                       AND i.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
                       AND i.EndValidity_DATE = @Ld_High_DATE
                       AND ((i.Reason_CODE IN (@Lc_FarRegoffsobyObligee_CODE, @Lc_FarRegfsomodObligee_CODE, @Lc_FarRegoffsomodivdagy_CODE, @Lc_FarRegfsomodenfstagy_CODE,
                                               @Lc_FarRegoffsomodenfobl_CODE, @Lc_FarRefsomodenfObligr_CODE, @Lc_FarRegfsoenfObligor_CODE, @Lc_FarRegfsoenfObligee_CODE, @Lc_FarRegfsoenfstAgency_CODE))
                             OR EXISTS (SELECT 1
                                          FROM CTHB_Y1 c
                                         WHERE c.Case_IDNO = i.Case_IDNO
                                           AND c.IoDirection_CODE = @Lc_InterstateDirectionInput_INDC
                                           AND c.Function_CODE = @Lc_FunctionEnforcement_CODE
                                           AND c.Action_CODE = @Lc_ActionRequest_CODE
                                           AND c.Reason_CODE IN (@Lc_FarRegoffsobyObligee_CODE, @Lc_FarRegfsomodObligee_CODE, @Lc_FarRegoffsomodivdagy_CODE, @Lc_FarRegfsomodenfstagy_CODE,
                                                                 @Lc_FarRegoffsomodenfobl_CODE, @Lc_FarRefsomodenfObligr_CODE, @Lc_FarRegfsoenfObligor_CODE, @Lc_FarRegfsoenfObligee_CODE, @Lc_FarRegfsoenfstAgency_CODE)
                                           AND c.TranStatus_CODE = @Lc_TranStatusSr_CODE)));

     SET @Ls_Sql_TEXT = 'UPDATE_OCSE157_CHILD_DETAILS_13';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line4_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', PaternityEst_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'')+ ', NonCoop_CODE = ' + ISNULL(@Lc_GoodCauseApproved_CODE,'');

     -- Children Requiring Paternity Determination Services in Cases Open at the End of the Fiscal year
         
     UPDATE a
        SET Line13_INDC = @Lc_Yes_INDC
       FROM RD157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line4_INDC = @Lc_Yes_INDC
        AND a.PaternityEst_INDC = @Lc_No_INDC
        AND DATEADD(m, 276, a.Birth_DATE) >= @Ad_BeginFiscal_DATE
        AND NOT EXISTS (SELECT 1
                          FROM CASE_Y1 c WITH (INDEX(0)),
                               CMEM_Y1 m
                         WHERE a.MemberMci_IDNO = m.MemberMci_IDNO
                           AND m.Case_IDNO = c.Case_IDNO
                           AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                           AND c.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE
                           AND c.NonCoop_CODE = @Lc_GoodCauseApproved_CODE);
   


     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-4';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(@Lc_RestartLoc4_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_RestartKey_TEXT       = @Lc_RestartLoc4_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END

     SET @Lc_RestartLoc_TEXT = @Lc_Space_TEXT;
    END

   IF (@Lc_RestartLoc_TEXT = @Lc_Space_TEXT
        OR @Lc_RestartLoc_TEXT = @Lc_RestartLoc4_TEXT)
    BEGIN
     -- Title IV-A Cases Closed During the Fiscal Year Where a Child Support Payment Was Received
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 14';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', TypeWelfare_CODE = ' + ISNULL(@Lc_WelfareTypeTanf_CODE,'')+ ', End_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Batch_DATE =' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR),'')+', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE,'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseDp_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'')+
     ' , TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeGeneticTest_CODE,'')+ ', DebtTypeSpousalSupp_CODE = ' + ISNULL(@Lc_DebtTypeSpousalSupp_CODE,'') + ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC,'') + ' , EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'');
               
     UPDATE e
     SET Line14_INDC = @Lc_Yes_INDC
      FROM RC157_Y1 e
      WHERE e.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND e.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND e.TypeReport_CODE = @Ac_TypeReport_CODE
        AND e.Case_IDNO IN (SELECT
                               a.Case_IDNO
                              FROM (SELECT c.Case_IDNO,
                                           c.MemberMci_IDNO,
                                           CONVERT(VARCHAR(7), c.End_DATE, 120) AS End_DATE,
                                           ROW_NUMBER() OVER(PARTITION BY c.Case_IDNO, c.MemberMci_IDNO ORDER BY End_DATE DESC, c.EventGlobalBeginSeq_NUMB DESC ) AS rno
                                      FROM MHIS_Y1 c WITH(INDEX(0))
                                     WHERE c.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
                                       AND c.End_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                       AND NOT EXISTS (SELECT 1
                                                         FROM MHIS_Y1 m 
                                                        WHERE c.Case_IDNO = m.Case_IDNO
                                                          AND m.TypeWelfare_CODE = @Lc_WelfareTypeTanf_CODE
                                                          AND m.End_DATE = @Ld_High_DATE)) AS a,
                                   (SELECT f.Case_IDNO,
                                           CONVERT(VARCHAR(7), f.Receipt_DATE, 120) AS Receipt_DATE
                                      FROM LSUP_Y1 f,
                                           OBLE_Y1 o
                                     WHERE f.Batch_DATE <> @Ld_Low_DATE
                                       AND f.Receipt_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                       AND f.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                       AND (f.TransactionPaa_AMNT + f.TransactionTaa_AMNT + f.TransactionCaa_AMNT) > 0
                                       AND f.Case_IDNO = o.Case_IDNO
                                       AND f.OrderSeq_NUMB = o.OrderSeq_NUMB
                                       AND f.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                       AND o.TypeDebt_CODE NOT IN (@Lc_DebtTypeGeneticTest_CODE, @Lc_DebtTypeSpousalSupp_CODE)
                                       AND o.EndValidity_DATE = @Ld_High_DATE
                                       AND NOT EXISTS (SELECT 1
                                                         FROM RCTH_Y1 x WITH(INDEX(0))
                                                        WHERE x.Batch_DATE = f.Batch_DATE
                                                          AND x.SourceBatch_CODE = f.SourceBatch_CODE
                                                          AND x.Batch_NUMB = f.Batch_NUMB
                                                          AND x.SeqReceipt_NUMB = f.SeqReceipt_NUMB
                                                          AND x.BackOut_INDC = @Lc_Yes_INDC
                                                          AND x.EndValidity_DATE = @Ld_High_DATE)) AS b,
                                   CMEM_Y1 AS c WITH(INDEX(0))
                             WHERE a.rno = 1
                               AND a.End_DATE = b.Receipt_DATE
                               AND a.Case_IDNO = b.Case_IDNO
                               AND a.Case_IDNO = c.Case_IDNO
                               AND a.MemberMci_IDNO = c.MemberMci_IDNO
                               AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
                               AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE);

           
     -- Children in the IV-D Caseload for Whom Paternity Was Established or Acknowledged During the Fiscal Year
     SET @Ls_Sql_TEXT = 'UPDATE_OCSE157_CHILD_DETAILS_16';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', StatusEstablish_CODE = ' + ISNULL(@Lc_StatusEstablished_CODE,'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseDp_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'');
     
  
     UPDATE a
        SET Line16_INDC = @Lc_Yes_INDC
       FROM RD157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.PaternityEst_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 c,
                           CASE_Y1 d,
                           MPAT_Y1 e
                     WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                       AND e.MemberMci_IDNO = a.MemberMci_IDNO
                       AND e.StatusEstablish_CODE = @Lc_StatusEstablished_CODE
                       AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
                       AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                       AND c.Case_IDNO = d.Case_IDNO
                       AND d.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE)
        AND a.PaternityEst_DATE >= (SELECT MIN(s.Opened_DATE)
                                      FROM UCASE_V1 s
                                     WHERE a.Case_IDNO = s.Case_IDNO);
                                         


     -- Cases With Orders Established During the Fiscal year
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 17';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', IoDirection_CODE = ' + ISNULL(@Lc_InterstateDirectionInput_INDC,'')+ ', Function_CODE = ' + ISNULL(@Lc_FunctionEstablishment_CODE,'')+ ', Action_CODE = ' + ISNULL(@Lc_ActionRequest_CODE,'')+ ', TranStatus_CODE = ' + ISNULL(@Lc_TranStatusSr_CODE,'')
     + ', StatusCase_CODE =' + ISNULL(@Lc_CaseStatusOpen_CODE,'')+' , CaseStatusFiscalClose_CODE = ' + ISNULL(@Lc_CaseStatusFiscalClose_CODE,'') + ' , TypeCase_CODE = ' + ISNULL(@Lc_CaseTypeNonIvd_CODE,'') + ', TypeOrder_CODE = '+ ISNULL(@Lc_OrderTypeVoluntary_CODE,'')+ ' , RespondInit_CODE = ' + ISNULL(@Lc_RespondInitResponding_CODE,'')+ ', RespondingInternational_CODE = ' + ISNULL(@Lc_RespondingInternational_CODE,'')+', RespondingTribal_CODE = ' + ISNULL(@Lc_RespondingTribal_CODE,'')+ ' , EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'')
     + ' , Reason_CODE= '+ ISNULL(@Lc_FarSromc_CODE,'')+ ', FarSrooc_CODE = ' + ISNULL(@Lc_FarSrooc_CODE,'')+ ',FarSropp_CODE = '+ISNULL(@Lc_FarSropp_CODE,'')+', FarSrord_CODE = '+ISNULL(@Lc_FarSrord_CODE,'')+', FarSross_CODE = ' + ISNULL(@Lc_FarSross_CODE,'');


     UPDATE a
        SET Line17_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND EXISTS (SELECT 1
                      FROM RASST_Y1 b
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                       AND b.StatusCase_CODE IN (@Lc_CaseStatusOpen_CODE, @Lc_CaseStatusFiscalClose_CODE)
                       AND b.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                       AND b.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                       AND (b.RespondInit_CODE NOT IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
                             OR (b.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
                                 AND EXISTS (SELECT 1
                                               FROM ICAS_Y1 i
                                              WHERE b.Case_IDNO = i.Case_IDNO
                                                AND i.RespondInit_CODE = b.RespondInit_CODE
                                                AND i.EndValidity_DATE = @Ld_High_DATE
                                                AND ((i.Reason_CODE IN (@Lc_FarSromc_CODE, @Lc_FarSrooc_CODE, @Lc_FarSropp_CODE, @Lc_FarSrord_CODE, @Lc_FarSross_CODE))
                                                      OR EXISTS (SELECT 1
                                                                   FROM CTHB_Y1 c
                                                                  WHERE c.Case_IDNO = i.Case_IDNO
                                                                    AND c.IoDirection_CODE = @Lc_InterstateDirectionInput_INDC
                                                                    AND c.Function_CODE = @Lc_FunctionEstablishment_CODE
                                                                    AND c.Action_CODE = @Lc_ActionRequest_CODE
                                                                    AND c.Reason_CODE IN (@Lc_FarSromc_CODE, @Lc_FarSrooc_CODE, @Lc_FarSropp_CODE, @Lc_FarSrord_CODE, @Lc_FarSross_CODE)
                                                                    AND c.TranStatus_CODE = @Lc_TranStatusSr_CODE))))))
        AND EXISTS (SELECT 1
                      FROM CASE_Y1 c,
                           SORD_Y1 s
                     WHERE a.Case_IDNO = c.Case_IDNO
                       AND c.Case_IDNO = s.Case_IDNO
                       AND c.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE
                       AND s.OrderIssued_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                       AND s.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                       AND c.AppSigned_DATE < s.OrderIssued_DATE
                       AND s.BeginValidity_DATE = (SELECT MIN(r.BeginValidity_DATE)
                                                     FROM SORD_Y1 r
                                                    WHERE s.Case_IDNO = r.Case_IDNO
                                                      AND r.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                                                     ))
        AND EXISTS (SELECT 1
                      FROM OBLE_Y1 s
                     WHERE a.Case_IDNO = s.Case_IDNO
                       AND s.BeginObligation_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                       AND s.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeSpousalSupp_CODE)
                       AND s.Periodic_AMNT > 0
                       AND s.BeginObligation_DATE = (SELECT MIN(r.BeginObligation_DATE)
                                                       FROM OBLE_Y1 r
                                                      WHERE s.Case_IDNO = r.Case_IDNO
                                                        AND r.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeSpousalSupp_CODE)
                                                        AND r.Periodic_AMNT > 0));

     
     -- Cases With Collection During the Fiscal year
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 18-1';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ' , TypeCase_CODE = ' + ISNULL(@Lc_CaseTypeNonIvd_CODE,'') + ',Batch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR),'') + ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE,'')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeGeneticTest_CODE,'') + ' , BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+' , EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'');
       
     UPDATE a
        SET Line18_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND EXISTS (SELECT 1
                      FROM RASST_Y1 b WITH(INDEX(0))
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                       AND b.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE)
        AND a.Case_IDNO IN (SELECT c.Case_IDNO
                              FROM (SELECT s.Case_IDNO,
                                           ROW_NUMBER() OVER(PARTITION BY s.Case_IDNO ORDER BY s.Case_IDNO) AS rno
                                      FROM LSUP_Y1 s WITH(INDEX(0))
                                     WHERE s.Batch_DATE <> @Ld_Low_DATE
                                       AND s.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                       AND s.Receipt_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                       AND (s.TransactionNaa_AMNT + s.TransactionPaa_AMNT + s.TransactionTaa_AMNT + s.TransactionCaa_AMNT + s.TransactionUpa_AMNT + s.TransactionUda_AMNT + s.TransactionIvef_AMNT + s.TransactionMedi_AMNT + s.TransactionNffc_AMNT) > 0
                                       AND NOT EXISTS (SELECT 1
                                                         FROM OBLE_Y1 o WITH(INDEX(0))
                                                        WHERE s.Case_IDNO = o.Case_IDNO
                                                          AND s.OrderSeq_NUMB = o.OrderSeq_NUMB
                                                          AND s.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                                          AND o.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                                                          AND o.EndValidity_DATE = @Ld_High_DATE)
                                       AND NOT EXISTS (SELECT 1
                                                         FROM RCTH_Y1 x WITH(INDEX(0))
                                                        WHERE x.Batch_DATE = s.Batch_DATE
                                                          AND x.SourceBatch_CODE = s.SourceBatch_CODE
                                                          AND x.Batch_NUMB = s.Batch_NUMB
                                                          AND x.SeqReceipt_NUMB = s.SeqReceipt_NUMB
                                                          AND x.BackOut_INDC = @Lc_Yes_INDC
                                                          AND x.EndValidity_DATE = @Ld_High_DATE)) c
       
                             WHERE c.rno = 1);

    
     -- Cases With Collection During the Fiscal year
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 18-2';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line18_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ' , TypeCase_CODE = '+ ISNULL(@Lc_CaseTypeNonIvd_CODE,'') + ', StatusReceipt_CODE = ' + ISNULL(@Lc_StatusReceiptHeld_CODE,'') + ' , EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'') + ' , BackOut_INDC = '  + ISNULL(@Lc_Yes_INDC,'') + ' , EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'');

     UPDATE a
        SET Line18_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line18_INDC = @Lc_No_INDC
        AND EXISTS (SELECT 1
                      FROM RASST_Y1 b
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                       AND b.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE)
        AND a.Case_IDNO IN (SELECT x.Case_IDNO
                              FROM RCTH_Y1 x
                             WHERE x.Receipt_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                               AND x.StatusReceipt_CODE = @Lc_StatusReceiptHeld_CODE
                               AND x.ToDistribute_AMNT > 0
                               AND x.EndValidity_DATE = @Ld_High_DATE
                               AND NOT EXISTS (SELECT 1
                                                 FROM RCTH_Y1 c
                                                WHERE x.Batch_DATE = c.Batch_DATE
                                                  AND x.SourceBatch_CODE = c.SourceBatch_CODE
                                                  AND x.Batch_NUMB = c.Batch_NUMB
                                                  AND x.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                                  AND c.BackOut_INDC = @Lc_Yes_INDC
                                                  AND c.EndValidity_DATE = @Ld_High_DATE));
                                                  
 
     -- Interstate Cases Received From Another State With Collections During the Fiscal year
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 18A';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line18_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'') + ', RespondInitResponding_CODE = ' + ISNULL(@Lc_RespondInitResponding_CODE,'')+ ' ,RespondingInternational_CODE = ' + ISNULL(@Lc_RespondingInternational_CODE,'') + ',RespondingTribal_CODE = ' + ISNULL(@Lc_RespondingTribal_CODE,'');
      
     UPDATE a
        SET Line18a_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line18_INDC = @Lc_Yes_INDC
        AND EXISTS (SELECT 1
                      FROM RASST_Y1 b
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                       AND b.RespondInit_CODE IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE));

     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-5';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(@Lc_RestartLoc5_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_RestartKey_TEXT       = @Lc_RestartLoc5_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END

     SET @Lc_RestartLoc_TEXT = @Lc_Space_TEXT;
    END

   IF @Lc_RestartLoc_TEXT = @Lc_Space_TEXT
       OR @Lc_RestartLoc_TEXT = @Lc_RestartLoc5_TEXT
    BEGIN
     -- Line 21 - Cases Open at the End of the Fiscal year in Which Medical Support is Ordered
     -- Line 22 - Cases Open at the End of the Fiscal year Where Health Insurance is Ordered
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 22';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line1_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Line2e_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE,'') +
     ' , TypeCase_CODE = '+ ISNULL(@Lc_CaseTypeNonIvd_CODE,'') + ' ,RespondInitInitiate_CODE = ' + ISNULL(@Lc_RespondInitInitiate_CODE,'') + ' ,InitiateInternational_CODE = ' + ISNULL(@Lc_InitiateInternational_CODE,'')+' ,InitiateTribal_CODE = ' + ISNULL(@Lc_InitiateTribal_CODE,'') + ', TypeOrder_CODE = ' + ISNULL(@Lc_OrderTypeVoluntary_CODE,'') + ' , EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'') + ', MedicalOnly_INDC = '+ ISNULL(@Lc_Yes_INDC,'')
     + ', InsOrderedBoth_CODE = '  + ISNULL(@Lc_InsOrderedBoth_CODE,'') + ' , InsOrderedBothUncond_CODE = ' + ISNULL(@Lc_InsOrderedBothUncond_CODE,'') + ',InsOrderedNcpOnly_CODE = ' + ISNULL(@Lc_InsOrderedNcpOnly_CODE ,'') + ' , InsOrderedNcpOnlyUncond_CODE = ' + ISNULL(@Lc_InsOrderedNcpOnlyUncond_CODE,'') + ' ,InsOrderedCpOnly_CODE = ' + ISNULL(@Lc_InsOrderedCpOnly_CODE,'') + ',InsOrderedCpOnlyUncond_CODE = ' + ISNULL(@Lc_InsOrderedCpOnlyUncond_CODE,'');
 
     UPDATE a
        SET Line21_INDC = @Lc_Yes_INDC,
            Line22_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line1_INDC = @Lc_Yes_INDC
        AND a.Line2e_INDC = @Lc_No_INDC
        AND EXISTS (SELECT 1
                      FROM RASST_Y1 b
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                       AND b.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                       AND b.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE
                       AND EXISTS (SELECT 1
                                     FROM SORD_Y1 s
                                    WHERE b.Case_IDNO = s.Case_IDNO
                                      AND s.TypeOrder_CODE <> @Lc_OrderTypeVoluntary_CODE
                                      AND s.OrderEnd_DATE > @Ad_EndFiscal_DATE
                                      AND s.EndValidity_DATE = @Ld_High_DATE
                                      AND(
                                         s.MedicalOnly_INDC = @Lc_Yes_INDC
                                      OR
                                      s.InsOrdered_CODE IN (@Lc_InsOrderedBoth_CODE, @Lc_InsOrderedBothUncond_CODE, @Lc_InsOrderedNcpOnly_CODE, @Lc_InsOrderedNcpOnlyUncond_CODE,
                                                                @Lc_InsOrderedCpOnly_CODE, @Lc_InsOrderedCpOnlyUncond_CODE))));
                                                                 


     -- Line 21A - Cases Open at the End of the Fiscal year in Which Medical Support is Ordered and Provided
     -- Line 23 - Cases Open at the End of the Fiscal year Where Health Insurance is Provided as Ordered
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 23';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line1_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Line22_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'')+ ' , RelationshipCaseNcp_CODE = ' + ISNULL(@Lc_RelationshipCaseNcp_CODE,'')+
     ' , RelationshipCaseCp_CODE = ' + ISNULL(@Lc_RelationshipCaseCp_CODE,'')+ ' , RelationshipCasePutFather_CODE = ' + ISNULL(@Lc_RelationshipCasePutFather_CODE,'') + ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseDp_CODE,'')+ ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE,'');

     UPDATE a
        SET Line21a_INDC = @Lc_Yes_INDC,
            Line23_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line1_INDC = @Lc_Yes_INDC
        AND a.Line22_INDC = @Lc_Yes_INDC
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 b,
                           MINS_Y1 c
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCaseCp_CODE, @Lc_RelationshipCasePutFather_CODE)
                       AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                       AND b.MemberMci_IDNO = c.MemberMci_IDNO
                       AND c.EndValidity_DATE = @Ld_High_DATE
                       AND EXISTS (SELECT 1
                                     FROM CMEM_Y1 d,
                                          DINS_Y1 e
                                    WHERE d.Case_IDNO = b.Case_IDNO
                                      AND d.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
                                      AND d.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                      AND e.MemberMci_IDNO = c.MemberMci_IDNO
                                      AND e.ChildMCI_IDNO = d.MemberMci_IDNO
                                      AND e.PolicyInsNo_TEXT = c.PolicyInsNo_TEXT
                                      AND e.EndValidity_DATE = @Ld_High_DATE));


     -- Cases Open at the End of the Fiscal year in Which Medical Support is Ordered
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 21';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line1_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Line2e_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', Line21_INDC = ' + ISNULL(@Lc_No_INDC,'') + ' , TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeCashMedical_CODE,'') + ' , DebtTypeMedicalSupp_CODE = ' + ISNULL(@Lc_DebtTypeMedicalSupp_CODE,'') + ' , EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR),'');
     
     UPDATE a
        SET Line21_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line1_INDC = @Lc_Yes_INDC
        AND a.Line2e_INDC = @Lc_No_INDC
        AND a.Line21_INDC = @Lc_No_INDC
        AND EXISTS (SELECT 1
                      FROM OBLE_Y1 c
                     WHERE c.Case_IDNO = a.Case_IDNO
                       AND c.TypeDebt_CODE IN (@Lc_DebtTypeCashMedical_CODE, @Lc_DebtTypeMedicalSupp_CODE)
                       AND c.Periodic_AMNT > 0
                       AND c.EndObligation_DATE > @Ad_EndFiscal_DATE
                       AND c.EndValidity_DATE = @Ld_High_DATE);

     -- Cases Open at the End of the Fiscal year in Which Medical Support is Ordered and Provided
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 21A';
     SET @Ls_Sqldata_TEXT = 'Line21a_INDC = ' + ISNULL(@Lc_Yes_INDC,'') + ' , BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line1_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Line21_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', Line21a_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ' , DebtTypeCashMedical_CODE = ' + @Lc_DebtTypeCashMedical_CODE + ' , DebtTypeMedicalSupp_CODE = ' + @Lc_DebtTypeMedicalSupp_CODE + 
      ' , Batch_DATE = '+  CAST(@Ld_Low_DATE AS VARCHAR)+', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE,'') + ', BackOut_INDC = '+ ISNULL(@Lc_Yes_INDC,'') ;

     UPDATE a
        SET Line21a_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line1_INDC = @Lc_Yes_INDC
        AND a.Line21_INDC = @Lc_Yes_INDC
        AND a.Line21a_INDC = @Lc_No_INDC
        AND EXISTS (SELECT 1
                      FROM OBLE_Y1 c,
                           LSUP_Y1 b
                     WHERE c.Case_IDNO = a.Case_IDNO
                       AND c.TypeDebt_CODE IN (@Lc_DebtTypeCashMedical_CODE, @Lc_DebtTypeMedicalSupp_CODE)
                       AND c.Periodic_AMNT > 0
                       AND c.EndObligation_DATE > @Ad_EndFiscal_DATE
                       AND c.EndValidity_DATE = @Ld_High_DATE
                       AND c.Case_IDNO = b.Case_IDNO
                       AND c.OrderSeq_NUMB = b.OrderSeq_NUMB
                       AND c.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                       AND b.Batch_DATE <> @Ld_Low_DATE
                       AND b.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                       AND (b.TransactionNaa_AMNT + b.TransactionPaa_AMNT + b.TransactionTaa_AMNT + b.TransactionCaa_AMNT + b.TransactionUpa_AMNT + b.TransactionUda_AMNT + b.TransactionIvef_AMNT + b.TransactionMedi_AMNT + b.TransactionNffc_AMNT) > 0
                       AND b.Receipt_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                       AND NOT EXISTS (SELECT 1
                                         FROM RCTH_Y1 x
                                        WHERE x.Batch_DATE = b.Batch_DATE
                                          AND x.SourceBatch_CODE = b.SourceBatch_CODE
                                          AND x.Batch_NUMB = b.Batch_NUMB
                                          AND x.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                          AND x.BackOut_INDC = @Lc_Yes_INDC
                                          AND x.EndValidity_DATE = @Ld_High_DATE));

     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE-6';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Run_DATE = ' + ISNULL(CAST(  @Ad_Run_DATE AS VARCHAR ),'')+ ', RestartKey_TEXT = ' + ISNULL(@Lc_RestartLoc6_TEXT,'');

     EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_RestartKey_TEXT       = @Lc_RestartLoc6_TEXT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
      SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
       RAISERROR (50001,16,1);
      END

     SET @Lc_RestartLoc_TEXT = @Lc_Space_TEXT;
    END

   IF @Lc_RestartLoc_TEXT = @Lc_Space_TEXT
       OR @Lc_RestartLoc_TEXT = @Lc_RestartLoc6_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT R2426_Y1 DETAILS';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'');

     SELECT @Ln_Isexist_NUMB = COUNT(1)
       FROM R2426_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE;

     IF @Ln_Isexist_NUMB > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' DELETE_V2426 ';
	   SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'');
       
	   DELETE R2426_Y1
        WHERE BeginFiscal_DATE = @Ad_BeginFiscal_DATE
          AND EndFiscal_DATE = @Ad_EndFiscal_DATE
          AND TypeReport_CODE = @Ac_TypeReport_CODE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'ERROR IN ' + ISNULL(@Ls_Sql_TEXT, '');
         RAISERROR (50001,16,1);
        END
      END

     SET @Lc_YyyymmBegin_TEXT = CONVERT(VARCHAR(6), @Ad_BeginFiscal_DATE, 112);
     SET @Lc_YyyymmEnd_TEXT = CONVERT(VARCHAR(6), @Ad_EndFiscal_DATE, 112);
     SET @Ls_Sql_TEXT = 'INSERT INTO R2426_Y1 LINE 24-1';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', LookIn_TEXT = ' + ISNULL(@Lc_LookInSlog_TEXT,'')+ ', Trans_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', SupportYearMonth_NUMB = ' + ISNULL(CAST( @An_SupportYearMonth_NUMB AS VARCHAR ),'')+ ' ,Space_TEXT = ' + ISNULL(@Lc_Space_TEXT,'') + ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'') + ', TypeDebt_CODE = ' +  @Lc_DebtTypeGeneticTest_CODE +
                        ' , EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', TypeWelfare_CODE = ' + @Lc_WelfareTypeNonIvd_CODE;

     -- Line 24 - Total Amount of Current Support Due for the Fiscal Year
     INSERT INTO R2426_Y1
                 (Case_IDNO,
                  BeginFiscal_DATE,
                  EndFiscal_DATE,
                  Line_NUMB,
                  LookIn_TEXT,
                  Trans_DATE,
                  Trans_AMNT,
                  SupportYearMonth_NUMB,
                  PayorMCI_IDNO,
                  ObligationKey_ID,
                  TypeAsst_CODE,
                  County_IDNO,
                  Office_IDNO,
                  Worker_ID,
                  TypeReport_CODE)
     SELECT fci.Case_IDNO,
            @Ad_BeginFiscal_DATE AS BeginFiscal_DATE,
            @Ad_EndFiscal_DATE AS EndFiscal_DATE,
            CAST(@Lc_LineNo24_TEXT AS NUMERIC) AS Line_NUMB,
            @Lc_LookInSlog_TEXT AS LookIn_TEXT,
            @Ad_EndFiscal_DATE AS Trans_DATE,
            SUM(fci.MtdCurSupOwed_AMNT) AS Trans_AMNT,
            @An_SupportYearMonth_NUMB AS SupportYearMonth_NUMB,
            0 AS PayorMCI_IDNO,
            @Lc_Space_TEXT AS ObligationKey_ID,
            MIN(fci.TypeWelfare_CODE) AS TypeAsst_CODE,
            MIN(fci.County_IDNO) AS County_IDNO,
            MIN(fci.Office_IDNO) AS Office_IDNO,
            MIN(fci.Worker_ID) AS Worker_ID,
            @Ac_TypeReport_CODE AS TypeReport_CODE
       FROM (SELECT a.Case_IDNO,
                    c.MtdCurSupOwed_AMNT,
                    s.TypeAsst_CODE AS TypeWelfare_CODE,
                    d.County_IDNO,
                    d.Office_IDNO,
                    d.Worker_ID
               FROM CASE_Y1 d,
                    RASST_Y1 s,
                    (SELECT l.Case_IDNO,
                            l.OrderSeq_NUMB,
                            l.ObligationSeq_NUMB,
                            l.SupportYearMonth_NUMB,
                            l.MtdCurSupOwed_AMNT,
                            l.TypeWelfare_CODE,
                            l.Batch_DATE,
                            l.SourceBatch_CODE,
                            l.Batch_NUMB,
                            l.SeqReceipt_NUMB,
                            ROW_NUMBER() OVER(PARTITION BY l.Case_IDNO, l.OrderSeq_NUMB, l.ObligationSeq_NUMB, l.SupportYearMonth_NUMB ORDER BY l.EventGlobalSeq_NUMB DESC) AS seqno
                       FROM LSUP_Y1 l
                      WHERE l.SupportYearMonth_NUMB BETWEEN CAST(@Lc_YyyymmBegin_TEXT AS NUMERIC) AND CAST(@Lc_YyyymmEnd_TEXT AS NUMERIC)) AS c,
                    (SELECT o.Case_IDNO,
                            o.OrderSeq_NUMB,
                            o.ObligationSeq_NUMB,
                            o.Fips_CODE,
                            o.TypeDebt_CODE,
                            o.MemberMci_IDNO,
                            o.CheckRecipient_ID
                       FROM OBLE_Y1 o
                      WHERE o.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE
                        AND o.EndValidity_DATE = @Ld_High_DATE
                        AND o.BeginObligation_DATE = (SELECT MAX(e.BeginObligation_DATE)
                                                        FROM OBLE_Y1 e
                                                       WHERE o.Case_IDNO = e.Case_IDNO
                                                         AND o.OrderSeq_NUMB = e.OrderSeq_NUMB
                                                         AND o.ObligationSeq_NUMB = e.ObligationSeq_NUMB
                                                         AND e.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE
                                                         AND e.EndValidity_DATE = @Ld_High_DATE)
                        AND o.EventGlobalBeginSeq_NUMB = (SELECT MAX(e.EventGlobalBeginSeq_NUMB)
                                                            FROM OBLE_Y1 e
                                                           WHERE o.Case_IDNO = e.Case_IDNO
                                                             AND o.OrderSeq_NUMB = e.OrderSeq_NUMB
                                                             AND o.ObligationSeq_NUMB = e.ObligationSeq_NUMB
                                                             AND e.TypeDebt_CODE <> @Lc_DebtTypeGeneticTest_CODE
                                                             AND o.BeginObligation_DATE = e.BeginObligation_DATE
                                                             AND e.EndValidity_DATE = @Ld_High_DATE)) AS a
              WHERE d.Case_IDNO = a.Case_IDNO
                AND d.Case_IDNO = s.Case_IDNO
                AND s.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                AND a.Case_IDNO = c.Case_IDNO
                AND a.OrderSeq_NUMB = c.OrderSeq_NUMB
                AND a.ObligationSeq_NUMB = c.ObligationSeq_NUMB
                AND c.MtdCurSupOwed_AMNT > 0
                AND c.TypeWelfare_CODE <> @Lc_WelfareTypeNonIvd_CODE
                AND c.seqno = 1) AS fci
      GROUP BY fci.Case_IDNO;

     -- Line 26 - Total Amount of Arrears Due for All Fiscal Year
     SET @Ls_Sql_TEXT = 'INSERT INTO R2426_Y1 LINE 26';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', Line_NUMB = ' + ISNULL(@Lc_LineNo26_TEXT,'')+ ', LookIn_TEXT = ' + ISNULL(@Lc_LookInSlog_TEXT,'')+ ', Trans_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'') + ' , Space_TEXT = ' + ISNULL(@Lc_Space_TEXT,'') + ', SupportYearMonth_NUMB = ' + ISNULL(CAST(@An_SupportYearMonth_NUMB AS VARCHAR),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ' ,  TypeDebt_CODE = ' + @Lc_DebtTypeGeneticTest_CODE + ' , EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR)
     + ' , TypeCase_CODE = ' + @Lc_CaseTypeNonIvd_CODE + ' , RespondInitResponding_CODE = ' + @Lc_RespondInitResponding_CODE + ' ,RespondingInternational_CODE = ' + @Lc_RespondingInternational_CODE + ', RespondingTribal_CODE= ' + @Lc_RespondingTribal_CODE;
      
     INSERT INTO R2426_Y1
                 (Case_IDNO,
                  BeginFiscal_DATE,
                  EndFiscal_DATE,
                  Line_NUMB,
                  LookIn_TEXT,
                  Trans_DATE,
                  Trans_AMNT,
                  SupportYearMonth_NUMB,
                  PayorMCI_IDNO,
                  ObligationKey_ID,
                  TypeAsst_CODE,
                  County_IDNO,
                  Office_IDNO,
                  Worker_ID,
                  TypeReport_CODE)
     SELECT Case_IDNO,
            @Ad_BeginFiscal_DATE AS BeginFiscal_DATE,
            @Ad_EndFiscal_DATE AS EndFiscal_DATE,
            @Lc_LineNo26_TEXT AS Line_NUMB,
            @Lc_LookInSlog_TEXT LookIn_TEXT,
            @Ad_EndFiscal_DATE AS Trans_DATE,
            arr AS Trans_AMNT,
            @An_SupportYearMonth_NUMB AS SupportYearMonth_NUMB,
            0 AS PayorMCI_IDNO,
            @Lc_Space_TEXT AS ObligationKey_ID,
            TypeAsst_CODE,
            fci.County_IDNO,
            fci.Office_IDNO,
            fci.Worker_ID,
            @Ac_TypeReport_CODE AS TypeReport_CODE
       FROM (SELECT b.Case_IDNO,
                    c.arr,
                    b.TypeAsst_CODE,
                    d.County_IDNO,
                    d.Office_IDNO,
                    d.Worker_ID
               FROM RASST_Y1 b,
                    CASE_Y1 d,
                    (SELECT c.Case_IDNO,
                            SUM(((c.OweTotNaa_AMNT - c.AppTotNaa_AMNT) + (c.OweTotPaa_AMNT - c.AppTotPaa_AMNT) + (c.OweTotTaa_AMNT - c.AppTotTaa_AMNT) + (c.OweTotCaa_AMNT - c.AppTotCaa_AMNT) + (c.OweTotUpa_AMNT - c.AppTotUpa_AMNT) + (c.OweTotUda_AMNT - c.AppTotUda_AMNT) + (c.OweTotIvef_AMNT - c.AppTotIvef_AMNT) + (c.OweTotMedi_AMNT - c.AppTotMedi_AMNT) + (c.OweTotNffc_AMNT - c.AppTotNffc_AMNT) - (c.OweTotCurSup_AMNT - c.AppTotCurSup_AMNT))) arr
                       FROM LSUP_Y1 c
                      WHERE c.SupportYearMonth_NUMB = (SELECT MAX(b.SupportYearMonth_NUMB)
                                                         FROM LSUP_Y1 b
                                                        WHERE b.Case_IDNO = c.Case_IDNO
                                                          AND b.OrderSeq_NUMB = c.OrderSeq_NUMB
                                                          AND b.ObligationSeq_NUMB = c.ObligationSeq_NUMB
                                                          AND b.SupportYearMonth_NUMB <= @An_SupportYearMonth_NUMB)
                        AND c.EventGlobalSeq_NUMB = (SELECT MAX(b.EventGlobalSeq_NUMB)
                                                       FROM LSUP_Y1 b
                                                      WHERE b.Case_IDNO = c.Case_IDNO
                                                        AND b.OrderSeq_NUMB = c.OrderSeq_NUMB
                                                        AND b.ObligationSeq_NUMB = c.ObligationSeq_NUMB
                                                        AND b.SupportYearMonth_NUMB = c.SupportYearMonth_NUMB)
                        AND NOT EXISTS (SELECT 1
                                          FROM OBLE_Y1 o
                                         WHERE c.Case_IDNO = o.Case_IDNO
                                           AND c.OrderSeq_NUMB = o.OrderSeq_NUMB
                                           AND c.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                           AND o.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                                           AND o.EndValidity_DATE = @Ld_High_DATE)
                      GROUP BY c.Case_IDNO) AS c
              WHERE b.SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB
                AND b.TypeCase_CODE <> @Lc_CaseTypeNonIvd_CODE
                AND b.RespondInit_CODE NOT IN (@Lc_RespondInitResponding_CODE, @Lc_RespondingInternational_CODE, @Lc_RespondingTribal_CODE)
                AND b.Case_IDNO = d.Case_IDNO
                AND b.Case_IDNO = c.Case_IDNO
                AND c.arr > 0) AS fci;

 -- Cases With Arrears Due During the Fiscal Year
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 28';
     SET @Ls_Sqldata_TEXT = 'BeginFiscal_DATE = ' + ISNULL(CAST( @Ad_BeginFiscal_DATE AS VARCHAR ),'')+ ', EndFiscal_DATE = ' + ISNULL(CAST( @Ad_EndFiscal_DATE AS VARCHAR ),'')+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'');
     
     UPDATE a
        SET Line28_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND EXISTS (SELECT 1
                      FROM LSUP_Y1 s
                     WHERE s.Case_IDNO = a.Case_IDNO
                       AND s.TypeRecord_CODE != @Lc_TypeRecordPrior_CODE
                       AND s.TypeWelfare_CODE != @Lc_WelfareTypeNonIvd_CODE
                       AND s.Distribute_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                       AND (((s.OweTotNaa_AMNT - s.AppTotNaa_AMNT) + (s.OweTotPaa_AMNT - s.AppTotPaa_AMNT) + (s.OweTotTaa_AMNT - s.AppTotTaa_AMNT) + (s.OweTotCaa_AMNT - s.AppTotCaa_AMNT) + (s.OweTotUpa_AMNT - s.AppTotUpa_AMNT) + (s.OweTotUda_AMNT - s.AppTotUda_AMNT) + (s.OweTotIvef_AMNT - s.AppTotIvef_AMNT) + (s.OweTotMedi_AMNT - s.AppTotMedi_AMNT) + (s.OweTotNffc_AMNT - s.AppTotNffc_AMNT) - (s.OweTotCurSup_AMNT - s.AppTotCurSup_AMNT)) > 0));

     -- Cases Paying Toward Arrears During the Fiscal Year        
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 CASE DETAILS 29-1';
     SET @Ls_Sqldata_TEXT = 'Line29_INDC = ' + ISNULL(@Lc_Yes_INDC,'') + ' ,BeginFiscal_DATE = ' + CAST( @Ad_BeginFiscal_DATE AS VARCHAR )+ ', EndFiscal_DATE = ' + CAST( @Ad_EndFiscal_DATE AS VARCHAR )+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'')+ ', Line28_INDC = ' + ISNULL(@Lc_Yes_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', TypeDebt_CODE = ' + ISNULL(@Lc_DebtTypeGeneticTest_CODE,'')+ ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE,'')+ ' , TypeWelfare_CODE = ' +  @Lc_WelfareTypeNonIvd_CODE + ', CheckRecipient_CODE = ' + ISNULL(@Lc_RecipientTypeOthp_CODE,'')
     + ' , ReceiptDistributed1820_NUMB =' + CAST(@Li_ReceiptDistributed1820_NUMB AS VARCHAR) + ', ReceiptReversed1250_NUMB = ' + CAST(@Li_ReceiptReversed1250_NUMB AS VARCHAR) + ' , DisbursementTypeRefundOthp_CODE = ' + @Lc_DisbursementTypeRefundOthp_CODE + ' ,DisbursementTypeRefund_CODE = ' +  @Lc_DisbursementTypeRefund_CODE + ' , DisburseStatusTransferEft_CODE = ' + @Lc_DisburseStatusTransferEft_CODE + ', DisburseStatusOutstanding_CODE = ' + @Lc_DisburseStatusOutstanding_CODE+ ',DisburseStatusCashed_CODE = ' + @Lc_DisburseStatusCashed_CODE + ' ,RecipientTypeCpNcp_CODE = ' +  @Lc_RecipientTypeCpNcp_CODE+ ',RecipientTypeFips_CODE = ' +  @Lc_RecipientTypeFips_CODE
     + ' , WelfareTypeTanf_CODE = ' + @Lc_WelfareTypeTanf_CODE + ' , WelfareTypeNonIve_CODE = ' + @Lc_WelfareTypeNonIve_CODE;
     
     UPDATE a
        SET Line29_INDC = @Lc_Yes_INDC
       FROM RC157_Y1 a
      WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
        AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
        AND a.TypeReport_CODE = @Ac_TypeReport_CODE
        AND a.Line28_INDC = @Lc_Yes_INDC
        AND a.Case_IDNO IN (SELECT m.Case_IDNO
                              FROM (SELECT y.Case_IDNO,
                                           y.County_IDNO,
                                           y.Batch_DATE,
                                           y.SourceBatch_CODE,
                                           y.Batch_NUMB,
                                           y.SeqReceipt_NUMB,
                                           y.TypeWelfare_CODE,
                                           y.curapp,
                                           CAST(y.curapp AS NUMERIC(11, 2)) - CAST(y.dhldc1 AS NUMERIC(11, 2)) - CAST(y.dhldc2 AS NUMERIC(11, 2)) - CAST(y.dhldc3 AS NUMERIC(11, 2)) AS curdisb,
                                           y.arrapp,
                                           CAST(y.arrapp AS NUMERIC(11, 2)) - CAST(y.dhlda1 AS NUMERIC(11, 2)) - CAST(y.dhlda2 AS NUMERIC(11, 2)) - CAST(y.dhlda3 AS NUMERIC(11, 2)) AS arrdisb,
                                           y.disb1,
                                           y.disb2,
                                           y.disb3,
                                           y.cgrntapp,
                                           y.agrntapp,
                                           y.poflassess,
                                           y.pofl1,
                                           y.pofl2,
                                           y.pofl3,
                                           y.dhldc1,
                                           y.dhldc2,
                                           y.dhldc3,
                                           y.dhlda1,
                                           y.dhlda2,
                                           y.dhlda3,
                                           y.SupportYearMonth_NUMB,
                                           (SELECT SUM(((x.OweTotNaa_AMNT - x.AppTotNaa_AMNT) + (x.OweTotUpa_AMNT - x.AppTotUpa_AMNT) + (x.OweTotUda_AMNT - x.AppTotUda_AMNT) + (x.OweTotMedi_AMNT - x.AppTotMedi_AMNT) + (x.OweTotNffc_AMNT - x.AppTotNffc_AMNT)) - CASE
                                                                                                                                                                                                                                                                      WHEN x.TypeWelfare_CODE NOT IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonIve_CODE, @Lc_WelfareTypeNonIvd_CODE)
                                                                                                                                                                                                                                                                       THEN x.OweTotCurSup_AMNT - x.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                      ELSE 0
                                                                                                                                                                                                                                                                     END)
                                              FROM LSUP_Y1 x
                                             WHERE y.Case_IDNO = x.Case_IDNO
                                               AND y.SupportYearMonth_NUMB = x.SupportYearMonth_NUMB
                                               AND x.EventGlobalSeq_NUMB = (SELECT MAX(z.EventGlobalSeq_NUMB)
                                                                              FROM LSUP_Y1 z
                                                                             WHERE x.Case_IDNO = z.Case_IDNO
                                                                               AND x.OrderSeq_NUMB = z.OrderSeq_NUMB
                                                                               AND x.ObligationSeq_NUMB = z.ObligationSeq_NUMB
                                                                               AND x.SupportYearMonth_NUMB = z.SupportYearMonth_NUMB)
                                               AND NOT EXISTS (SELECT 1
                                                                 FROM OBLE_Y1 z
                                                                WHERE x.Case_IDNO = z.Case_IDNO
                                                                  AND x.OrderSeq_NUMB = z.OrderSeq_NUMB
                                                                  AND x.ObligationSeq_NUMB = z.ObligationSeq_NUMB
                                                                  AND z.EndValidity_DATE = @Ld_High_DATE
                                                                  AND z.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE)) unassigned
                                      FROM (SELECT a.Case_IDNO,
                                                   b.County_IDNO,
                                                   a.Batch_DATE,
                                                   a.SourceBatch_CODE,
                                                   a.Batch_NUMB,
                                                   a.SeqReceipt_NUMB,
                                                   a.TypeWelfare_CODE,
                                                   a.SupportYearMonth_NUMB,
                                                   (SELECT ISNULL(SUM(x.TransactionNaa_AMNT + x.TransactionPaa_AMNT + x.TransactionTaa_AMNT + x.TransactionCaa_AMNT + x.TransactionUda_AMNT + x.TransactionUpa_AMNT + x.TransactionIvef_AMNT + x.TransactionNffc_AMNT + x.TransactionMedi_AMNT - x.TransactionCurSup_AMNT), 0)
                                                      FROM LSUP_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.TypeWelfare_CODE = a.TypeWelfare_CODE
                                                       AND x.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.TypeWelfare_CODE <> @Lc_WelfareTypeNonIvd_CODE
                                                       AND x.Distribute_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB)) AS arrapp,
                                                   (SELECT ISNULL(SUM(x.TransactionCurSup_AMNT), 0)
                                                      FROM LSUP_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.TypeWelfare_CODE = a.TypeWelfare_CODE
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.TypeWelfare_CODE <> @Lc_WelfareTypeNonIvd_CODE
                                                       AND x.Distribute_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.EventFunctionalSeq_NUMB IN (@Li_ReceiptDistributed1820_NUMB, @Li_ReceiptReversed1250_NUMB)) AS curapp,
                                                   (SELECT ISNULL(SUM(x.Disburse_AMNT), 0)
                                                      FROM DSBL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                                                       AND x.Disburse_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND EXISTS (SELECT 1
                                                                     FROM DSBH_Y1 d
                                                                    WHERE x.CheckRecipient_ID = d.CheckRecipient_ID
                                                                      AND x.CheckRecipient_CODE = d.CheckRecipient_CODE
                                                                      AND x.Disburse_DATE = d.Disburse_DATE
                                                                      AND x.DisburseSeq_NUMB = d.DisburseSeq_NUMB
                                                                      AND d.EndValidity_DATE = @Ld_High_DATE
                                                                      AND x.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefundOthp_CODE, @Lc_DisbursementTypeRefund_CODE)
                                                                      AND d.StatusCheck_CODE IN (@Lc_DisburseStatusTransferEft_CODE, @Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusCashed_CODE))) AS disb1,
                                                   (SELECT ISNULL(SUM(x.Disburse_AMNT), 0)
                                                      FROM DSBL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                                                       AND x.Disburse_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND EXISTS (SELECT 1
                                                                     FROM DSBH_Y1 d
                                                                    WHERE x.CheckRecipient_ID = d.CheckRecipient_ID
                                                                      AND x.CheckRecipient_CODE = d.CheckRecipient_CODE
                                                                      AND x.Disburse_DATE = d.Disburse_DATE
                                                                      AND x.DisburseSeq_NUMB = d.DisburseSeq_NUMB
                                                                      AND d.EndValidity_DATE = @Ld_High_DATE
                                                                      AND x.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefundOthp_CODE, @Lc_DisbursementTypeRefund_CODE)
                                                                      AND d.StatusCheck_CODE IN (@Lc_DisburseStatusTransferEft_CODE, @Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusCashed_CODE))) AS disb2,
                                                   (SELECT ISNULL(SUM(x.Disburse_AMNT), 0)
                                                      FROM DSBL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
                                                       AND x.Disburse_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND EXISTS (SELECT 1
                                                                     FROM DSBH_Y1 d
                                                                    WHERE x.CheckRecipient_ID = d.CheckRecipient_ID
                                                                      AND x.CheckRecipient_CODE = d.CheckRecipient_CODE
                                                                      AND x.Disburse_DATE = d.Disburse_DATE
                                                                      AND x.DisburseSeq_NUMB = d.DisburseSeq_NUMB
                                                                      AND d.EndValidity_DATE = @Ld_High_DATE
                                                                      AND x.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefundOthp_CODE, @Lc_DisbursementTypeRefund_CODE)
                                                                      AND d.StatusCheck_CODE IN (@Lc_DisburseStatusTransferEft_CODE, @Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusCashed_CODE))) AS disb3,
                                                   (SELECT ISNULL(SUM(x.Disburse_AMNT), 0)
                                                      FROM DSBL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
                                                       AND x.Disburse_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND EXISTS (SELECT 1
                                                                     FROM DSBH_Y1 d
                                                                    WHERE x.CheckRecipient_ID = d.CheckRecipient_ID
                                                                      AND x.CheckRecipient_CODE = d.CheckRecipient_CODE
                                                                      AND x.Disburse_DATE = d.Disburse_DATE
                                                                      AND x.DisburseSeq_NUMB = d.DisburseSeq_NUMB
                                                                      AND d.EndValidity_DATE = @Ld_High_DATE
                                                                      AND x.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefundOthp_CODE, @Lc_DisbursementTypeRefund_CODE)
                                                                      AND SUBSTRING(x.TypeDisburse_CODE, 2, 1) <> 'Z'
                                                                      AND LEFT(x.TypeDisburse_CODE, 2) IN ('CG', 'PG')
                                                                      AND d.CheckRecipient_ID <> 'OSR'
                                                                      AND d.StatusCheck_CODE IN (@Lc_DisburseStatusTransferEft_CODE, @Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusCashed_CODE))) AS cgrntapp,
                                                   (SELECT ISNULL(SUM(x.Disburse_AMNT), 0)
                                                      FROM DSBL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
                                                       AND x.Disburse_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND EXISTS (SELECT 1
                                                                     FROM DSBH_Y1 d
                                                                    WHERE x.CheckRecipient_ID = d.CheckRecipient_ID
                                                                      AND x.CheckRecipient_CODE = d.CheckRecipient_CODE
                                                                      AND x.Disburse_DATE = d.Disburse_DATE
                                                                      AND x.DisburseSeq_NUMB = d.DisburseSeq_NUMB
                                                                      AND d.EndValidity_DATE = @Ld_High_DATE
                                                                      AND x.TypeDisburse_CODE NOT IN (@Lc_DisbursementTypeRefundOthp_CODE, @Lc_DisbursementTypeRefund_CODE)
                                                                      AND SUBSTRING(x.TypeDisburse_CODE, 2, 1) <> 'Z'
                                                                      AND LEFT(x.TypeDisburse_CODE, 2) IN ('AG')
                                                                      AND d.CheckRecipient_ID <> 'OSR'
                                                                      AND d.StatusCheck_CODE IN (@Lc_DisburseStatusTransferEft_CODE, @Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusCashed_CODE))) AS agrntapp,
                                                   (SELECT ISNULL(SUM(x.AssessOverpay_AMNT), 0)
                                                      FROM POFL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.Transaction_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.CheckRecipient_CODE IN (@Lc_RecipientTypeCpNcp_CODE, @Lc_RecipientTypeFips_CODE, @Lc_RecipientTypeOthp_CODE)) AS poflassess,
                                                   (SELECT ISNULL(SUM(x.RecOverpay_AMNT), 0)
                                                      FROM POFL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.Transaction_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE) AS pofl1,
                                                   (SELECT ISNULL(SUM(x.RecOverpay_AMNT), 0)
                                                      FROM POFL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.Transaction_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE) AS pofl2,
                                                   (SELECT ISNULL(SUM(x.RecOverpay_AMNT), 0)
                                                      FROM POFL_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.Transaction_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE) AS pofl3,
                                                   (SELECT ISNULL(SUM(x.Transaction_AMNT), 0)
                                                      FROM DHLD_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                                                       AND x.TypeDisburse_CODE LIKE 'C%'
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.BeginValidity_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.EndValidity_DATE = @Ld_High_DATE) AS dhldc1,
                                                   (SELECT ISNULL(SUM(x.Transaction_AMNT), 0)
                                                      FROM DHLD_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                                                       AND x.TypeDisburse_CODE LIKE 'C%'
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.BeginValidity_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.EndValidity_DATE = @Ld_High_DATE) AS dhldc2,
                                                   (SELECT ISNULL(SUM(x.Transaction_AMNT), 0)
                                                      FROM DHLD_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
                                                       AND x.TypeDisburse_CODE LIKE 'C%'
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.BeginValidity_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.EndValidity_DATE = @Ld_High_DATE) AS dhldc3,
                                                   (SELECT ISNULL(SUM(x.Transaction_AMNT), 0)
                                                      FROM DHLD_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                                                       AND (x.TypeDisburse_CODE LIKE 'A%'
                                                             OR x.TypeDisburse_CODE LIKE 'X%')
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.BeginValidity_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.EndValidity_DATE = @Ld_High_DATE) AS dhlda1,
                                                   (SELECT ISNULL(SUM(x.Transaction_AMNT), 0)
                                                      FROM DHLD_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
                                                       AND (x.TypeDisburse_CODE LIKE 'A%'
                                                             OR x.TypeDisburse_CODE LIKE 'X%')
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.BeginValidity_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                                       AND x.EndValidity_DATE = @Ld_High_DATE) AS dhlda2,
                                                   (SELECT ISNULL(SUM(x.Transaction_AMNT), 0)
                                                      FROM DHLD_Y1 x
                                                     WHERE x.Batch_DATE = a.Batch_DATE
                                                       AND x.SourceBatch_CODE = a.SourceBatch_CODE
                                                       AND x.Batch_NUMB = a.Batch_NUMB
                                                       AND x.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                       AND x.Case_IDNO = a.Case_IDNO
                                                       AND x.CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
                                                       AND (x.TypeDisburse_CODE LIKE 'A%'
                                                             OR x.TypeDisburse_CODE LIKE 'X%')
                                                       AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                       AND x.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                       AND x.EndValidity_DATE = @Ld_High_DATE) AS dhlda3
                                              FROM LSUP_Y1 a,
                                                   CASE_Y1 b
                                             WHERE a.Distribute_DATE BETWEEN @Ad_BeginFiscal_DATE AND @Ad_EndFiscal_DATE
                                               AND a.Batch_DATE <> @Ld_Low_DATE
                                               AND a.Case_IDNO = b.Case_IDNO
                                               AND NOT EXISTS (SELECT 1
                                                                 FROM OBLE_Y1 c
                                                                WHERE a.Case_IDNO = c.Case_IDNO
                                                                  AND a.OrderSeq_NUMB = c.OrderSeq_NUMB
                                                                  AND a.ObligationSeq_NUMB = c.ObligationSeq_NUMB
                                                                  AND c.TypeDebt_CODE = @Lc_DebtTypeGeneticTest_CODE
                                                                  AND c.EndValidity_DATE = @Ld_High_DATE)
                                             GROUP BY a.Case_IDNO,
                                                      b.County_IDNO,
                                                      a.Batch_DATE,
                                                      a.SourceBatch_CODE,
                                                      a.Batch_NUMB,
                                                      a.SeqReceipt_NUMB,
                                                      a.OrderSeq_NUMB,
                                                      a.ObligationSeq_NUMB,
                                                      a.TypeWelfare_CODE,
                                                      a.SupportYearMonth_NUMB) AS y) AS m
                             WHERE ((m.TypeWelfare_CODE IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonIve_CODE)
                                 AND arrapp > 0
                                 AND m.arrdisb > 0)
                                 OR (m.TypeWelfare_CODE NOT IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonIve_CODE, @Lc_WelfareTypeNonIvd_CODE)
                                     AND m.unassigned <= 0
                                     AND arrapp > 0
                                     AND m.arrdisb > 0)
                                 OR (m.TypeWelfare_CODE NOT IN (@Lc_WelfareTypeTanf_CODE, @Lc_WelfareTypeNonIve_CODE, @Lc_WelfareTypeNonIvd_CODE)
                                     AND m.unassigned > 0
                                     AND (CAST(arrapp AS NUMERIC(11, 2)) - CAST(agrntapp AS NUMERIC(11, 2))) > 0)
                                    AND m.arrdisb > 0));        
     -- Bug 13628 Start
     -- Updating the fiscal case close value 'K' to Case close value 'C'        
     SET @Ls_Sql_TEXT = 'UPDATE OCSE157 RASST_Y1 Case status value K TO C';
     SET @Ls_Sqldata_TEXT = 'UPDATE RASST_Y1 FROM VALUE FISCAL CASE CLOSE K TO CASE CLOSED C' +  ' ,BeginFiscal_DATE = ' + CAST( @Ad_BeginFiscal_DATE AS VARCHAR )+ ', EndFiscal_DATE = ' + CAST( @Ad_EndFiscal_DATE AS VARCHAR )+ ', TypeReport_CODE = ' + ISNULL(@Ac_TypeReport_CODE,'');
     UPDATE RASST_Y1 
     SET StatusCase_CODE = @Lc_CaseStatusClosed_CODE
		WHERE StatusCase_CODE = @Lc_CaseStatusFiscalClose_CODE
		AND SupportYearMonth_NUMB = @An_SupportYearMonth_NUMB;
     -- Bug 13628 End  
 SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   END
  END TRY

  BEGIN CATCH
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   DECLARE
		@Li_Error_NUMB INT = ERROR_NUMBER (),
		@Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
   BEGIN
	 SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
   END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                   @As_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT,
                                   @As_Sql_TEXT = @Ls_Sql_TEXT,
                                   @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                   @An_Error_NUMB = @Li_Error_NUMB,
                                   @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                   @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;




GO
