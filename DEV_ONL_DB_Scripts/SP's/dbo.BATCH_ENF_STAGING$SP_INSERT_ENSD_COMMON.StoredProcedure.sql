/****** Object:  StoredProcedure [dbo].[BATCH_ENF_STAGING$SP_INSERT_ENSD_COMMON]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_STAGING$SP_INSERT_ENSD_COMMON
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_ENF_STAGING$SP_INSERT_ENSD_COMMON is used to insert data in ENSD_Y1.
Frequency		:	
Developed On	:	4/19/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_STAGING$SP_INSERT_ENSD_COMMON]
 @Ad_Run_DATE     DATE,
 @Ac_Msg_CODE     CHAR(1) OUTPUT,
 @As_Error_DESC   VARCHAR(4000) OUTPUT,
 @As_Sql_TEXT     VARCHAR(100) OUTPUT,
 @As_Sqldata_TEXT VARCHAR(1000) OUTPUT
AS
 SET ANSI_WARNINGS OFF;

 DECLARE @Lc_Space_TEXT                       CHAR = ' ',
         @Lc_DateFormatYyyy_TEXT              CHAR(4) = 'YYYY',
         @Lc_DateFormatYyyymm_TEXT            CHAR(6) = 'YYYYMM',
         @Lc_TypePrimary_SSN                  CHAR = 'P',
         @Lc_VerificationStatusGood_CODE      CHAR = 'Y',
         @Lc_VerificationStatusPending_CODE   CHAR = 'P',
         @Ld_High_DATE                        DATE = '12/31/9999',
         @Lc_Yes_INDC                         CHAR = 'Y',
         @Lc_Residential_ADDR                 CHAR(1) = 'R',
         @Lc_Mailing_ADDR                     CHAR(1) = 'M',
         @Lc_LastKnownCourt_ADDR              CHAR(1) = 'C',
         @Lc_Trip_ADDR                        CHAR(1) = 'T',
         @Lc_StateInState_CODE                CHAR(2) = 'DE',
         @Lc_No_INDC                          CHAR = 'N',
         @Lc_RespondInitInitiate_TEXT         CHAR(1) = 'I',
         @Ld_Low_DATE                         DATE = '01/01/0001',
         @Lc_OrderTypeVoluntary_CODE          CHAR(1) = 'V',
         @Lc_StatusExempt_CODE                CHAR = 'E',
         @Lc_Onetime_TEXT                     CHAR = 'O',
         @Lc_Daily_TEXT                       CHAR = 'D',
         @Lc_Weekly_TEXT                      CHAR = 'W',
         @Lc_Monthly_TEXT                     CHAR = 'M',
         @Lc_Biweekly_TEXT                    CHAR = 'B',
         @Lc_Semimonthly_TEXT                 CHAR = 'S',
         @Lc_Annual_TEXT                      CHAR = 'A',
         @Lc_DebtTypeNCPfees_CODE             CHAR(2) = 'NF',
         @Lc_DebtTypeSpousalSupp_CODE         CHAR(2) = 'SS',
         @Lc_DebtTypeIntSpousalSupp_CODE      CHAR(2) = 'SI',
         @Lc_Quarterly_TEXT                   CHAR	  = 'Q',
         @Lc_OnRequest_TEXT                   CHAR	  = 'O',
         @Lc_DebtTypeChildSupp_CODE           CHAR(2) = 'CS',
         @Lc_DebtTypeIntChildSupp_CODE        CHAR(2) = 'CI',
         @Lc_DebtTypeMedicalSupp_CODE         CHAR(2) = 'MS',
         @Lc_DebtTypeIntMedicalSupp_CODE      CHAR(2) = 'MI',
         @Lc_DebtTypeCashMedical_CODE         CHAR(2) = 'CM',
         @Lc_DebtTypeIntCashMedical_CODE      CHAR(2) = 'HI',
         @Lc_DebtTypeAlimony_CODE             CHAR(2) = 'AL',
         @Lc_DebtTypeIntAlimony_CODE          CHAR(2) = 'AI',
         @Lc_RelationshipCaseCp_TEXT          CHAR(1) = 'C',
         @Lc_StatusCaseMemberActive_CODE      CHAR(1) = 'A',
         @Lc_RelationshipCaseNcp_TEXT         CHAR(1) = 'A',
         @Lc_RelationshipCasePutFather_TEXT   CHAR(1) = 'P',
         @Lc_ReceiptSrcAdminretirement_CODE   CHAR(2) = 'AR',
         @Lc_ReceiptSrcAdminsalary_CODE       CHAR(2) = 'AS',
         @Lc_ReceiptSrcAdminvendorpymt_CODE   CHAR(2) = 'AV',
         @Lc_ReceiptSrcBond_CODE              CHAR(2) = 'BN',
         @Lc_ReceiptSrcDisabilityinsur_CODE   CHAR(2) = 'DB',
         @Lc_ReceiptSrcEmployerwage_CODE      CHAR(2) = 'EW',
         @Lc_ReceiptSrcInterstativdreg_CODE   CHAR(2) = 'F4',
         @Lc_ReceiptSrcInterstativdfee_CODE   CHAR(2) = 'FF',
         @Lc_ReceiptSrcSpecialCollection_CODE CHAR(2) = 'SC',
         @Lc_ReceiptSrcJudgment_CODE          CHAR(2) = 'JM',
         @Lc_RemitTypeCheck_CODE              CHAR(3) = 'CHK',
         @Lc_RemitTypeCashierscheck_CODE      CHAR(3) = 'CTF',
         @Lc_RemitTypeForeigncurrency_CODE    CHAR(3) = 'FNC',
         @Lc_RemitTypeMoneyorder_CODE         CHAR(3) = 'MNO',
         @Lc_RemitTypeCash_CODE               CHAR(3) = 'CSH',
         @Lc_RemitTypeCountycash_CODE         CHAR(3) = 'CSL',
         @Lc_RemitTypeCreditcard_CODE         CHAR(3) = 'CRD',
         @Lc_RemitTypeEft_CODE                CHAR(3) = 'EFT',
         @Lc_ReceiptSrcLevyFidm_CODE          CHAR(2) = 'FD',
         @Lc_ReceiptSrcLottery_CODE           CHAR(2) = 'LO',
         @Lc_ReceiptSrcReleaseAmount_CODE     CHAR(2) = 'PM',
         @Lc_ReceiptSrcCentralpayroll_CODE    CHAR(2) = 'PY',
         @Lc_ReceiptSrcQdro_CODE              CHAR(2) = 'QR',
         @Lc_ReceiptSrcRegularPayment_CODE    CHAR(2) = 'RE',
         @Lc_ReceiptSrcHomesteadRebate_CODE   CHAR(2) = 'SH',
         @Lc_ReceiptSrcSaverRebate_CODE       CHAR(2) = 'SS',
         @Lc_ReceiptSrcStateTaxRefund_CODE    CHAR(2) = 'ST',
         @Lc_ReceiptSrcUib_CODE               CHAR(2) = 'UC',
         @Lc_ReceiptSrcVoluntary_CODE         CHAR(2) = 'VN',
         @Lc_ReceiptSrcCsln_CODE              CHAR(2) = 'WC',
         @Lc_StatusReceiptIdentified_CODE     CHAR(1) = 'I',
         @Lc_ReceiptSrcAc_CODE                CHAR(2) = 'AC',
         @Lc_ReceiptSrcAn_CODE                CHAR(2) = 'AN',
         @Lc_StatusReceiptRefunded_CODE       CHAR(1) = 'R',
         @Lc_StatusReceiptOthpRefund_CODE     CHAR(1) = 'O',
         @Lc_BankruptcyType13_CODE            CHAR(2) = '13',
         @Lc_RecipientTypeCpNcp_CODE          CHAR(1) = '1',
         @Lc_DisbursementTypeRefund_CODE      CHAR(5) = 'REFND',
         @Lc_RemedyStatusExempt_CODE          CHAR(4) = 'EXMT',
         @Lc_RemedyStatusStart_CODE           CHAR(4) = 'STRT',
         @Lc_ReqStatusSuccessSent_CODE        CHAR(2) = 'SS',
         @Lc_FunctionEnforcement_CODE         CHAR(3) = 'ENF',
         @Lc_ActionRequest_CODE               CHAR	  = 'R',
         @Lc_FarRegfsomodenfstagy_CODE        CHAR(5) = 'ERMEE',
         @Lc_FarRegoffsomodenfobl_CODE        CHAR(5) = 'ERMEM',
         @Lc_FarRefsomodenfobligr_CODE        CHAR(5) = 'ERMEO',
         @Lc_FarRegfsoenfobligor_CODE         CHAR(5) = 'ERREG',
         @Lc_FarRegfsoenfobligee_CODE         CHAR(5) = 'ERREO',
         @Lc_FarRegfsoenfstagency_CODE        CHAR(5) = 'ERRES',
         @Lc_InterstateDirectionOutput_TEXT   CHAR = 'O',
         @Lc_InterstateDirectionInput_TEXT    CHAR = 'I',
         @Lc_ActionAcknowledgment_CODE        CHAR = 'A',
         @Lc_CaseStatusOpen_CODE              CHAR(1) = 'O',
         @Lc_RespondInitResponding_TEXT       CHAR(1) = 'R',
         @Lc_ReceiptSrcCpRecoupment_CODE      CHAR(2) = 'CR',
         @Lc_ReceiptSrcNsfRecoupment_CODE     CHAR(2) = 'NR',
         @Lc_TypeRecordOriginal_CODE          CHAR(1) = 'O',
         @Lc_StatusSuccess_CODE               CHAR = 'S',
         @Lc_StatusFailed_CODE                CHAR = 'F',
         @Lc_CurrentYear01jan_TEXT            CHAR(7) = '01-JAN-',
         @Lc_CurrentYear31dec_TEXT            CHAR(7) = '31-DEC-',
         @Lc_CurrentMonth01_TEXT              CHAR(2) = '01',
         @Lc_CurrentMonth31_TEXT              CHAR(2) = '30',
         @Lc_FormatMonYyy_TEXT                CHAR(8) = 'MON-YYYY',
         @Lc_FormatMonyyy3_TEXT               CHAR(8) = 'MONYYYY',
         @Lc_TypeItinI1_SSN                   CHAR = 'I',
         @Lc_Primaryresidential_ADDR          CHAR = 'P',
         @Lc_Secondaryresidential_ADDR        CHAR = 'S',
         @Lc_VerStatusPending_ADDR            CHAR = 'P',
         @Lc_TypeLicenceDr_IDNO               CHAR(2) = 'DR',
         @Lc_TypeLicenceDr01_IDNO             CHAR(4) = 'DR01',
         @Lc_TypeLicenceDr02_IDNO             CHAR(4) = 'DR02',
         @Lc_TypeLicenceDr03_IDNO             CHAR(4) = 'DR03',
         @Lc_TypeLicenceDr04_IDNO             CHAR(4) = 'DR04',
         @Lc_TypeLicenceDr05_IDNO             CHAR(4) = 'DR05',
         @Lc_TypeLicenceDr06_IDNO             CHAR(4) = 'DR06',
         @Lc_StatusCg_CODE                    CHAR(2) = 'CG',
         @Lc_ChargingCase_TEXT                CHAR(1) = 'C',
         @Lc_ArrearsonlyCase_TEXT             CHAR(1) = 'A',
         @Lc_NotchargingOrArrearsCase_TEXT    CHAR(1) = 'N',
         @Lc_Biweekly3_TEXT                   CHAR(1) = 'B',
         @Lc_SourceT1_CODE                    CHAR(1) = 'T',
         @Lc_SourceB1_CODE                    CHAR(1) = 'B',
         @Lc_SourceI1_CODE                    CHAR(1) = 'I',
         @Lc_SourceW1_CODE                    CHAR(1) = 'W',
         @Lc_SourceF1_CODE                    CHAR(1) = 'F',
         @Lc_SourceE1_CODE                    CHAR(1) = 'E',
         @Lc_SourceK1_CODE                    CHAR(1) = 'K',
         @Lc_SourceM1_CODE                    CHAR(1) = 'M',
         @Lc_SourceC1_CODE                    CHAR(1) = 'C',
         @Lc_SourceG1_CODE                    CHAR(1) = 'G',
         @Lc_SourceV1_CODE                    CHAR(1) = 'V',
         @Lc_SourceH1_CODE                    CHAR(1) = 'H',
         @Lc_SourceS1_CODE                    CHAR(1) = 'S',
         @Lc_SourceU1_CODE                    CHAR(1) = 'U',
         @Lc_SourceN1_CODE                    CHAR(1) = 'N',
         @Lc_MinorActivityEmancipation_CODE   CHAR(5) = 'EMANI',
         @Lc_MinorActivityIrsci_CODE          CHAR(5) = 'IRSCI',
         @Lc_MinorActivityDelqn_CODE          CHAR(5) = 'DELQN',
         @Lc_ActivityMajorApin_CODE           CHAR(4) = 'APIN',
         @Lc_ActivityMajorAren_CODE           CHAR(4) = 'AREN',
         @Lc_ActivityMajorBwnt_CODE           CHAR(4) = 'BWNT',
         @Lc_ActivityMajorCola_CODE           CHAR(4) = 'COLA',
         @Lc_ColaExmtRsnPre911998_CODE        CHAR(2) = 'PR',
         @Lc_ColaExmtRsnCortordered_CODE      CHAR(2) = 'CO',
         @Lc_ColaExmtRsnAltperadjust_CODE     CHAR(2) = 'AP',
         @Lc_ActivityMajorCrpt_CODE           CHAR(4) = 'CRPT',
         @Lc_ActivityMajorCsln_CODE           CHAR(4) = 'CSLN',
         @Lc_ActivityMajorFidm_CODE           CHAR(4) = 'FIDM',
         @Lc_ActivityMajorImiw_CODE           CHAR(4) = 'IMIW',
         @Lc_ActivityMajorIniw_CODE           CHAR(4) = 'INIW',
         @Lc_ActivityMajorLint_CODE           CHAR(4) = 'LINT',
         @Lc_ActivityMajorQdro_CODE           CHAR(4) = 'QDRO',
         @Lc_ActivityMajorRlcs_CODE           CHAR(4) = 'RLCS',
         @Lc_ActivityMajorRlms_CODE           CHAR(4) = 'RLMS',
         @Lc_ActivityMajorSois_CODE           CHAR(4) = 'SOIS',
         @Lc_ActivityMajorUedb_CODE           CHAR(4) = 'UEDB',
         @Lc_ActivityMajorLsnr_CODE           CHAR(4) = 'LSNR',
         @Lc_ActivityMajorNmsn_CODE           CHAR(4) = 'NMSN',
         @Lc_ActivityMajorAcms_CODE           CHAR(4) = 'ACMS',
         @Lc_ActivityMajorPsoc_CODE           CHAR(4) = 'PSOC',
         @Lc_ActivityMajorCclo_CODE           CHAR(4) = 'CCLO',
         @Lc_ActivityMajorFacl_CODE           CHAR(4) = 'FACL',
         @Lc_ActivityMajorOgco_CODE           CHAR(4) = 'OGCO',
         @Lc_ActivityMajorPbcl_CODE           CHAR(4) = 'PBCL',
         @Lc_ActivityMajorRevw_CODE           CHAR(4) = 'REVW',
         @Lc_ActivityMajorTanf_CODE           CHAR(4) = 'TANF',
         @Lc_ActivityMajorCrim_CODE           CHAR(4) = 'CRIM',
         @Lc_ActivityMajorLien_CODE           CHAR(4) = 'LIEN',
         @Lc_ActivityMajorSeqo_CODE           CHAR(4) = 'SEQO',
         @Lc_ExchangeModePaper_TEXT           CHAR(1) = 'P',
         @Ld_CurrentYearSt_DATE               DATETIME2(0),
         @Ld_CurrentYearEnd_DATE              DATETIME2(0),
         @Ld_CurrentMonthSt_DATE              DATETIME2(0),
         @Ld_CurrentMonthEnd_DATE             DATETIME2(0),
         @Ln_WelfareYearMonth_NUMB            NUMERIC(6),
         @Ln_PrevWelfare_DTYM                 NUMERIC(6, 0),
         @Ln_SupportYearMonth_NUMB            NUMERIC(6),
         @Ls_Err_Description_TEXT             VARCHAR (4000),
         @Lc_ReasonAnoad_CODE                 CHAR(5);

 BEGIN
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_Error_DESC = NULL;
   SET @Lc_ReasonAnoad_CODE = ISNULL(@Lc_ReasonAnoad_CODE, 'ANOAD');
   SET @As_Sql_TEXT = 'TRUNCATE TABLE ENSD_Y1';
   SET @As_Sqldata_TEXT = @Lc_Space_TEXT;

   --DELETE FROM ENSD_Y1;
   TRUNCATE TABLE EnforcementStagingDetails_T1;

   SET @Ld_CurrentYearSt_DATE = CAST(@Lc_CurrentYear01jan_TEXT + ISNULL(CONVERT(VARCHAR(4), @Ad_Run_DATE, 112), '') AS DATETIME2);
   SET @Ld_CurrentYearEnd_DATE = CAST(@Lc_CurrentYear31dec_TEXT + ISNULL(CONVERT(VARCHAR(4), @Ad_Run_DATE, 112), '') AS DATETIME2);
   SET @Ld_CurrentMonthSt_DATE = CAST(ISNULL(CONVERT(VARCHAR(6), @Ad_Run_DATE, 112), '') + @Lc_CurrentMonth01_TEXT AS DATETIME2);
   SET @Ld_CurrentMonthEnd_DATE = CAST(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, @Ad_Run_DATE) + 1, 0)) AS DATETIME2);
   SET @Ln_SupportYearMonth_NUMB = CAST(CONVERT(VARCHAR(6), @Ad_Run_DATE, 112) AS NUMERIC);
   SET @Ln_PrevWelfare_DTYM = CAST(CONVERT(VARCHAR(6), (DATEADD(m, -1, @Ad_Run_DATE)), 112) AS NUMERIC);
   SET @As_Sql_TEXT = 'INSERT ENSD_Y1';

   WITH ssn_tab
        AS (SELECT MemberMci_IDNO,
                   MemberSsn_NUMB,
                   TypePrimary_CODE,
                   Enumeration_CODE
              FROM (SELECT MemberMci_IDNO,
                           MemberSsn_NUMB,
                           TypePrimary_CODE,
                           Enumeration_CODE,
                           ROW_NUMBER() OVER(PARTITION BY MemberMci_IDNO ORDER BY TypePrimary_CODE DESC, Enumeration_CODE DESC, TransactionEventSeq_NUMB DESC) rnm
                      FROM MSSN_Y1 m WITH (INDEX(0))
                     WHERE Enumeration_CODE = @Lc_VerificationStatusGood_CODE
                       AND TypePrimary_CODE IN (@Lc_TypePrimary_SSN, @Lc_TypeItinI1_SSN)                     
                       AND EndValidity_DATE = @Ld_High_DATE) s
             WHERE rnm = 1),
        rcth_backout_tab
        AS (SELECT C.Batch_DATE,
                   C.Batch_NUMB,
                   C.SourceBatch_CODE,
                   C.SeqReceipt_NUMB
              FROM RCTH_Y1 c WITH (INDEX(0))
             WHERE c.BackOut_INDC = @Lc_Yes_INDC
               AND c.EndValidity_DATE = @Ld_High_DATE),
         rcth_valid_tab
        AS (SELECT R.*
              FROM RCTH_Y1 AS r WITH (INDEX(0))
             WHERE NOT EXISTS (SELECT c.Batch_DATE,
                                      c.Batch_NUMB,
                                      c.SourceBatch_CODE,
                                      c.SeqReceipt_NUMB
                                 FROM RCTH_BACKOUT_TAB c
                                WHERE C.Batch_DATE = r.Batch_DATE
                                  AND C.Batch_NUMB = r.Batch_NUMB
                                  AND C.SourceBatch_CODE = r.SourceBatch_CODE
                                  AND C.SeqReceipt_NUMB = r.SeqReceipt_NUMB)
               AND r.StatusReceipt_CODE NOT IN (@Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE)
               AND NOT EXISTS (SELECT 1 FROM GLEV_Y1 a WHERE a.EventGlobalSeq_NUMB = r.EventGlobalBeginSeq_NUMB AND a.Worker_ID='CONVERSION')
               AND r.EndValidity_DATE = @Ld_High_DATE),
        ahis_tab
        AS (SELECT MemberMci_IDNO,
                   Line1_ADDR,
                   Line2_ADDR,
                   City_ADDR,
                   State_ADDR,
                   Zip_ADDR,
                   Country_ADDR,
                   Status_CODE,
                   NcpInstateResidence_INDC,
                   CASE
                    WHEN @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE
                     THEN Status_CODE
                   END AddrExists_INDC
              FROM (SELECT MemberMci_IDNO,
                           UPPER(Line1_ADDR) AS Line1_ADDR,
                           UPPER(Line2_ADDR) AS Line2_ADDR,
                           UPPER(City_ADDR) AS City_ADDR,
                           UPPER(State_ADDR) AS State_ADDR,
                           Zip_ADDR AS Zip_ADDR,
                           UPPER(Country_ADDR) AS Country_ADDR,
                           Status_CODE,
                           Begin_DATE,
                           End_DATE,
                           MAX(CASE
                                WHEN (TypeAddress_CODE IN (@Lc_Mailing_ADDR, @Lc_Residential_ADDR, @Lc_LastKnownCourt_ADDR, @Lc_Trip_ADDR)
                                     AND State_ADDR = @Lc_StateInState_CODE
                                     AND Status_CODE = @Lc_VerificationStatusGood_CODE
                                     AND @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE)
                                 THEN @Lc_Yes_INDC
                                ELSE @Lc_No_INDC
                               END) OVER(PARTITION BY MemberMci_IDNO) NcpInstateResidence_INDC,
                           ROW_NUMBER() OVER(PARTITION BY MemberMci_IDNO ORDER BY CASE WHEN (@Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE) THEN 1 ELSE 2 END, CASE WHEN Status_CODE = 'Y' THEN 1 WHEN Status_CODE = 'P' THEN 2 ELSE 3 END, CASE WHEN TypeAddress_CODE = 'M' THEN 1 WHEN TypeAddress_CODE = 'R' THEN 2 WHEN TypeAddress_CODE = 'C' THEN 3 ELSE 4 END, End_DATE DESC, TransactionEventSeq_NUMB DESC) ROW_NUMBER
                      FROM AHIS_Y1 a WITH (INDEX(0))
                     WHERE TypeAddress_CODE IN (@Lc_Mailing_ADDR, @Lc_Residential_ADDR, @Lc_LastKnownCourt_ADDR, @Lc_Trip_ADDR)
                   AND Status_CODE IN (@Lc_VerificationStatusGood_CODE, @Lc_VerificationStatusPending_CODE, 'N')) a
             WHERE ROW_NUMBER = 1),
        sord_tab
        AS (SELECT s.Case_IDNO,
                   s.OrderSeq_NUMB,
                   s.Order_IDNO,
                   s.File_ID,
                   s.OrderEnt_DATE,
                   s.OrderIssued_DATE,
                   s.OrderEffective_DATE,
                   s.OrderEnd_DATE,
                   s.ReasonStatus_CODE,
                   s.StatusOrder_CODE,
                   s.StatusOrder_DATE,
                   s.InsOrdered_CODE,
                   s.MedicalOnly_INDC,
                   s.Iiwo_CODE,
                   s.NoIwReason_CODE,
                   s.IwoInitiatedBy_CODE,
                   s.GuidelinesFollowed_INDC,
                   s.DeviationReason_CODE,
                   s.DescriptionDeviationOthers_TEXT,
                   s.OrderOutOfState_ID,
                   s.CejStatus_CODE,
                   s.CejFips_CODE,
                   s.IssuingOrderFips_CODE,
                   s.Qdro_INDC,
                   s.UnreimMedical_INDC,
                   s.CpMedical_PCT,
                   s.NcpMedical_PCT,
                   s.ParentingTime_PCT,
                   s.NoParentingDays_QNTY,
                   s.PetitionerAppeared_INDC,
                   s.RespondentAppeared_INDC,
                   s.OthersAppeared_INDC,
                   s.PetitionerReceived_INDC,
                   s.RespondentReceived_INDC,
                   s.OthersReceived_INDC,
                   s.PetitionerMailed_INDC,
                   s.RespondentMailed_INDC,
                   s.OthersMailed_INDC,
                   s.PetitionerMailed_DATE,
                   s.RespondentMailed_DATE,
                   s.OthersMailed_DATE,
                   s.CoverageMedical_CODE,
                   s.CoverageDrug_CODE,
                   s.CoverageMental_CODE,
                   s.CoverageDental_CODE,
                   s.CoverageVision_CODE,
                   s.CoverageOthers_CODE,
                   s.DescriptionCoverageOthers_TEXT,
                   s.WorkerUpdate_ID,
                   s.BeginValidity_DATE,
                   s.EndValidity_DATE,
                   s.EventGlobalBeginSeq_NUMB,
                   s.EventGlobalEndSeq_NUMB,
                   s.DescriptionParentingNotes_TEXT,
                   s.LastIrscReferred_DATE,
                   s.LastIrscUpdated_DATE,
                   s.LastIrscReferred_AMNT,
                   s.StatusControl_CODE,
                   s.StateControl_CODE,
                   s.OrderControl_ID,
                   s.PetitionerAttorneyAppeared_INDC,
                   s.RespondentAttorneyAppeared_INDC,
                   s.PetitionerAttorneyReceived_INDC,
                   s.RespondentAttorneyReceived_INDC,
                   s.PetitionerAttorneyMailed_INDC,
                   s.RespondentAttorneyMailed_INDC,
                   s.PetitionerAttorneyMailed_DATE,
                   s.RespondentAttorneyMailed_DATE,
                   s.TypeOrder_CODE,
                   s.ReviewRequested_DATE,
                   s.NextReview_DATE,
                   s.LastReview_DATE,
                   s.LastNoticeSent_DATE,
                   s.DirectPay_INDC,
                   s.SourceOrdered_CODE,
                   s.CourtOrderIssuedOrg_DATE
              FROM (SELECT s.Case_IDNO,
                           s.OrderSeq_NUMB,
                           s.Order_IDNO,
                           s.File_ID,
                           s.OrderEnt_DATE,
                           s.OrderIssued_DATE,
                           s.OrderEffective_DATE,
                           s.OrderEnd_DATE,
                           s.ReasonStatus_CODE,
                           s.StatusOrder_CODE,
                           s.StatusOrder_DATE,
                           s.InsOrdered_CODE,
                           s.MedicalOnly_INDC,
                           s.Iiwo_CODE,
                           s.NoIwReason_CODE,
                           s.IwoInitiatedBy_CODE,
                           s.GuidelinesFollowed_INDC,
                           s.DeviationReason_CODE,
                           s.DescriptionDeviationOthers_TEXT,
                           s.OrderOutOfState_ID,
                           s.CejStatus_CODE,
                           s.CejFips_CODE,
                           s.IssuingOrderFips_CODE,
                           s.Qdro_INDC,
                           s.UnreimMedical_INDC,
                           s.CpMedical_PCT,
                           s.NcpMedical_PCT,
                           s.ParentingTime_PCT,
                           s.NoParentingDays_QNTY,
                           s.PetitionerAppeared_INDC,
                           s.RespondentAppeared_INDC,
                           s.OthersAppeared_INDC,
                           s.PetitionerReceived_INDC,
                           s.RespondentReceived_INDC,
                           s.OthersReceived_INDC,
                           s.PetitionerMailed_INDC,
                           s.RespondentMailed_INDC,
                           s.OthersMailed_INDC,
                           s.PetitionerMailed_DATE,
                           s.RespondentMailed_DATE,
                           s.OthersMailed_DATE,
                           s.CoverageMedical_CODE,
                           s.CoverageDrug_CODE,
                           s.CoverageMental_CODE,
                           s.CoverageDental_CODE,
                           s.CoverageVision_CODE,
                           s.CoverageOthers_CODE,
                           s.DescriptionCoverageOthers_TEXT,
                           s.WorkerUpdate_ID,
                           s.BeginValidity_DATE,
                           s.EndValidity_DATE,
                           s.EventGlobalBeginSeq_NUMB,
                           s.EventGlobalEndSeq_NUMB,
                           s.DescriptionParentingNotes_TEXT,
                           s.LastIrscReferred_DATE,
                           s.LastIrscUpdated_DATE,
                           s.LastIrscReferred_AMNT,
                           s.StatusControl_CODE,
                           s.StateControl_CODE,
                           s.OrderControl_ID,
                           s.PetitionerAttorneyAppeared_INDC,
                           s.RespondentAttorneyAppeared_INDC,
                           s.PetitionerAttorneyReceived_INDC,
                           s.RespondentAttorneyReceived_INDC,
                           s.PetitionerAttorneyMailed_INDC,
                           s.RespondentAttorneyMailed_INDC,
                           s.PetitionerAttorneyMailed_DATE,
                           s.RespondentAttorneyMailed_DATE,
                           s.TypeOrder_CODE,
                           s.ReviewRequested_DATE,
                           s.NextReview_DATE,
                           s.LastReview_DATE,
                           s.LastNoticeSent_DATE,
                           s.DirectPay_INDC,
                           s.SourceOrdered_CODE,
                           MIN(CAST(CASE
                                     WHEN s.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                                      THEN s.OrderIssued_DATE
                                     ELSE @Ld_Low_DATE
                                    END AS DATETIME2)) OVER(PARTITION BY s.Case_IDNO, s.OrderSeq_NUMB) AS CourtOrderIssuedOrg_DATE
                      FROM SORD_Y1 AS s WITH (INDEX(0)
                      )) AS s
             WHERE s.EndValidity_DATE = @Ld_High_DATE),
        oble_tab
        AS (SELECT y.Case_IDNO,
                   y.OrderSeq_NUMB,
                   y.ObligationSeq_NUMB,
                   y.MemberMci_IDNO,
                   y.TypeDebt_CODE,
                   y.Fips_CODE,
                   y.FreqPeriodic_CODE,
                   y.Periodic_AMNT,
                   y.ExpectToPay_AMNT,
                   y.ExpectToPay_CODE, 
                   y.BeginObligation_DATE,
                   y.EndObligation_DATE,
                   y.AccrualLast_DATE,
                   y.AccrualNext_DATE,
                   y.CheckRecipient_ID,
                   y.CheckRecipient_CODE,
                   y.EventGlobalBeginSeq_NUMB,
                   y.EventGlobalEndSeq_NUMB,
                   y.BeginValidity_DATE,
                   y.EndValidity_DATE,
                   y.rnm,
                   CASE
                    WHEN y.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeSpousalSupp_CODE)
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END AS CsMsSs_INDC,
                   CASE
                    WHEN @Ad_Run_DATE BETWEEN y.BeginObligation_DATE AND y.EndObligation_DATE
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END AS Active_INDC,
                   CASE
                    WHEN y.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeMedicalSupp_CODE)
                         AND @Ad_Run_DATE BETWEEN y.BeginObligation_DATE AND y.EndObligation_DATE
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END AS Csms_INDC,
                   CASE
                    WHEN y.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE)
                         AND @Ad_Run_DATE BETWEEN y.BeginObligation_DATE AND y.EndObligation_DATE
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END AS OblCs_INDC,
                   CASE
                    WHEN y.TypeDebt_CODE IN (@Lc_DebtTypeMedicalSupp_CODE)
                         AND @Ad_Run_DATE BETWEEN y.BeginObligation_DATE AND y.EndObligation_DATE
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END AS OblMs_INDC,
                   CASE
                    WHEN y.TypeDebt_CODE IN (@Lc_DebtTypeSpousalSupp_CODE)
                         AND @Ad_Run_DATE BETWEEN y.BeginObligation_DATE AND y.EndObligation_DATE
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END AS OblSs_INDC,
                   CASE
                    WHEN y.TypeDebt_CODE IN (@Lc_DebtTypeNCPfees_CODE)
                         AND @Ad_Run_DATE BETWEEN y.BeginObligation_DATE AND y.EndObligation_DATE
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END AS OblNf_INDC,
                   CASE y.FreqPeriodic_CODE
                    WHEN @Lc_Weekly_TEXT
                     THEN 52
                    WHEN @Lc_Monthly_TEXT
                     THEN 12
                    WHEN @Lc_Biweekly3_TEXT
                     THEN 26
                    WHEN @Lc_Semimonthly_TEXT
                     THEN 24
                    WHEN @Lc_Quarterly_TEXT
                     THEN 4
                    WHEN @Lc_Annual_TEXT
                     THEN 1
                    WHEN @Lc_OnRequest_TEXT
                     THEN 0
                    ELSE 52
                   END AS DecFreqPeriodic_QNTY,
                   y.AccrualNext_DATE AS NextPayLeastOble_DATE
              FROM (SELECT y.Case_IDNO,
                           y.OrderSeq_NUMB,
                           y.ObligationSeq_NUMB,
                           y.MemberMci_IDNO,
                           y.TypeDebt_CODE,
                           y.Fips_CODE,
                           y.FreqPeriodic_CODE,
                           y.Periodic_AMNT,
                           y.ExpectToPay_AMNT,
                           y.ExpectToPay_CODE,
                           y.BeginObligation_DATE,
                           y.EndObligation_DATE,
                           y.AccrualLast_DATE,
                           y.AccrualNext_DATE,
                           y.CheckRecipient_ID,
                           y.CheckRecipient_CODE,
                           y.EventGlobalBeginSeq_NUMB,
                           y.EventGlobalEndSeq_NUMB,
                           y.BeginValidity_DATE,
                           y.EndValidity_DATE,
                           ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO, y.OrderSeq_NUMB, y.ObligationSeq_NUMB ORDER BY y.BeginObligation_DATE DESC, y.EventGlobalBeginSeq_NUMB DESC) AS rnm
                      FROM OBLE_Y1 AS y WITH (INDEX(0))
                     WHERE y.BeginObligation_DATE <= @Ad_Run_DATE
                       AND y.EndValidity_DATE = @Ld_High_DATE) AS y
             WHERE y.rnm = 1),
        lsup_tab
        AS (SELECT L.*,
                   CASE
                    WHEN L.SupportYearMonth_NUMB = @Ln_SupportYearMonth_NUMB
                     THEN @Lc_Yes_INDC
                    ELSE @Lc_No_INDC
                   END Current_INDC
              FROM (SELECT su.*,
                           ROW_NUMBER() OVER(PARTITION BY su.Case_IDNO, su.OrderSeq_NUMB, su.ObligationSeq_NUMB, su.SupportYearMonth_NUMB ORDER BY su.EventGlobalSeq_NUMB DESC) row_num
                      FROM LSUP_Y1 su WITH (INDEX(0))
                     WHERE su.Distribute_DATE <= @Ad_Run_DATE) L
             WHERE row_num = 1),
        cmem_cp_tab
        AS (SELECT fci.Case_IDNO,
                   fci.MemberMci_IDNO,
                   fci.CaseRelationship_CODE,
                   fci.CaseMemberStatus_CODE
              FROM (SELECT c.Case_IDNO,
                           c.MemberMci_IDNO,
                           c.CaseRelationship_CODE,
                           c.CaseMemberStatus_CODE,
                           ROW_NUMBER() OVER(PARTITION BY c.Case_IDNO ORDER BY c.CaseMemberStatus_CODE, c.CaseRelationship_CODE, c.MemberMci_IDNO) AS rnm
                      FROM CMEM_Y1 AS c WITH (INDEX(0))
                     WHERE c.CaseRelationship_CODE = @Lc_RelationshipCaseCp_TEXT
                       AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE) AS fci
             WHERE fci.rnm = 1),
        cmem_ncp_tab
        AS (SELECT fci.Case_IDNO,
                   fci.MemberMci_IDNO,
                   fci.CaseRelationship_CODE,
                   fci.CaseMemberStatus_CODE
              FROM (SELECT cm.Case_IDNO,
                           cm.MemberMci_IDNO,
                           cm.CaseRelationship_CODE,
                           cm.CaseMemberStatus_CODE,
                           ROW_NUMBER() OVER(PARTITION BY cm.Case_IDNO ORDER BY cm.CaseMemberStatus_CODE, cm.CaseRelationship_CODE, cm.TransactionEventSeq_NUMB DESC,cm.MemberMci_IDNO) AS rnm
                      FROM CMEM_Y1 AS cm WITH (INDEX(0))
                     WHERE cm.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT,@Lc_RelationshipCasePutFather_TEXT)
                       AND cm.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE) AS fci
             WHERE fci.rnm = 1),
        ehis_tab
        AS (SELECT e.MemberMci_IDNO,
                   e.Status_CODE
              FROM EHIS_Y1 AS e WITH (INDEX(0))
             WHERE @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
               AND e.Status_CODE = @Lc_VerificationStatusGood_CODE
             GROUP BY e.MemberMci_IDNO,
                      e.Status_CODE),
        bnkr_tab
        AS (SELECT dd.MemberMci_IDNO,
				  CASE WHEN (dd.Dismissed_DATE != @Ld_Low_DATE AND @Ad_Run_DATE > dd.Dismissed_DATE) 
						 OR (dd.Discharge_DATE != @Ld_Low_DATE AND @Ad_Run_DATE > dd.Discharge_DATE) THEN
					@Lc_No_INDC
				  ELSE @Lc_Yes_INDC  END AS Bankruptcy_INDC,
                   dd.Filed_DATE,
                   dd.Discharge_DATE,
                   dd.Dismissed_DATE
              FROM BNKR_Y1 AS dd WITH (INDEX(0))
             WHERE dd.TypeBankruptcy_CODE = @Lc_BankruptcyType13_CODE
               AND dd.EndValidity_DATE = @Ld_High_DATE),
        mdet_tab
        AS (SELECT md.MemberMci_IDNO,
                   md.Institution_IDNO,
                   md.Institution_NAME,
                   md.TypeInst_CODE,
                   md.PoliceDept_IDNO,
                   md.Institutionalized_DATE,
                   md.Incarceration_DATE,
                   md.Release_DATE,
                   md.EligParole_DATE,
                   md.MoveType_CODE,
                   md.Inmate_NUMB,
                   md.ParoleReason_CODE,
                   md.InstSbin_IDNO,
                   md.InstFbin_IDNO,
                   md.ParoleOfficer_NAME,
                   md.PhoneParoleOffice_NUMB,
                   md.DescriptionHold_TEXT,
                   md.Sentence_CODE,
                   md.WorkerUpdate_ID,
                   md.TransactionEventSeq_NUMB,
                   md.Update_DTTM,
                   md.BeginValidity_DATE,
                   md.EndValidity_DATE,
                   md.ProbationOfficer_NAME,
                   md.MaxRelease_DATE
              FROM MDET_Y1 AS md WITH (INDEX(0))
             WHERE md.EndValidity_DATE = @Ld_High_DATE),
        mem_ins_tab
        AS (SELECT MemberMci_IDNO,
                   @Lc_Yes_INDC Status_CODE
              FROM MINS_Y1 M WITH (INDEX(0))
             WHERE @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE
               AND EndValidity_DATE = @Ld_High_DATE
             GROUP BY MemberMci_IDNO),
        plic_tab
        AS (SELECT DISTINCT
                   MemberMci_IDNO,
                   @Lc_Yes_INDC DrLicenseExist_INDC
              FROM PLIC_Y1 pc WITH (INDEX(0))
             WHERE -- Any type of license can be suspended from Batch in DECSS
            Status_CODE = @Lc_StatusCg_CODE
           AND IssuingState_CODE = @Lc_StateInState_CODE
           AND @Ad_Run_DATE BETWEEN IssueLicense_DATE AND ExpireLicense_DATE
           AND EndValidity_DATE = @Ld_High_DATE)
   INSERT ENSD_Y1
          (Case_IDNO,
           NcpPf_IDNO,
           NcpPfSsn_NUMB,
           County_IDNO,
           TypeCase_CODE,
           StatusCase_CODE,
           RespondInit_CODE,
           InterstateEligible_NUMB,
           InsOrdered_CODE,
           Iiwo_CODE,
           MedicalOnly_INDC,
           LastReview_DATE,
           OrderIssued_DATE,
           OrderEffective_DATE,
           OrderEnd_DATE,
           TypeOrder_CODE,
           CaseMemberStatus_CODE,
           Bankruptcy13_INDC,
           Mso_AMNT,
           Arrears_AMNT,
           MsoCsms_AMNT,
           BalanceCurSup_AMNT,
           ArrearsCsms_AMNT,
           ReceiptLast_DATE,
           CaseExempt_INDC,
           FullArrears_AMNT,
           ArrearsReg_AMNT,
           TotYtdColl_AMNT,
           TotMtdColl_AMNT,
           PaymentLastReceived_AMNT,
           DefraPrevMonth_AMNT,
           CheckLastCp_AMNT,
           FreqPayback_CODE,
           FreqLeastOble_CODE,
           TypePayback_CODE,
           SourceReceiptLast_CODE,
           NextPayLeastOble_DATE,
           CheckLastCp_DATE,
           LastRegularPaymentReceived_DATE,
           CourtOrderIssuedOrg_DATE,
           GenerateIrsci_DATE,
           GenerateEmancipation_DATE,
           GenerateDelqn_DATE,
           Dismissed_DATE,
           Discharge_DATE,
           Filed_DATE,
           File_ID,
           CaseWelfare_IDNO,
           MultiIva_INDC,
           WorkerCase_ID,
           Incarceration_DATE,
           Institutionalized_DATE,
           Deceased_DATE,
           Released_DATE,
           CaseChargingArrears_CODE,
           CejFips_CODE,
           CejStatus_CODE,
           CoverageDental_CODE,
           CoverageDrug_CODE,
           CoverageMedical_CODE,
           CoverageMental_CODE,
           CoverageVision_CODE,
           CpMci_IDNO,
           VerifiedltinNcpOrpfSsn_NUMB,
           VerifiedItinCpSsn_NUMB,
           LastNcp_NAME,
           FirstNcp_NAME,
           MiddleNcp_NAME,
           SuffixNcp_NAME,
           BirthNcp_DATE,
           Line1Ncp_ADDR,
           Line2Ncp_ADDR,
           CityNcp_ADDR,
           StateNcp_ADDR,
           ZipNcp_ADDR,
           CountryNcp_ADDR,
           NcpInstateResidence_INDC,
           VerifiedNcpAddrExist_INDC,
           NcpAddrExist_INDC,
           NcpEmplExist_INDC,
           LastCp_NAME,
           FirstCp_NAME,
           MiddleCp_NAME,
           SuffixCp_NAME,
           BirthCp_DATE,
           Line1Cp_ADDR,
           Line2Cp_ADDR,
           CityCp_ADDR,
           StateCp_ADDR,
           ZipCp_ADDR,
           CountryCp_ADDR,
           CpInStateResidence_INDC,
           VerCpAddrExist_INDC,
           CsObligationExist_INDC,
           MsObligationExist_INDC,
           SsObligationExist_INDC,
           MeansTestedInc_INDC,
           LicenseExist_INDC,
           ArenExempt_INDC,
           CrptExempt_INDC,
           CslnExempt_INDC,
           FidmExempt_INDC,
           ImiwExempt_INDC,
           LintExempt_INDC,
           QdroExempt_INDC,
           LsnrExempt_INDC,
           NmsnExempt_INDC,
           PsocExempt_INDC,
           NonCoop_CODE,
           GoodCause_CODE,
           CaseCategory_CODE,
           StatusEnforce_CODE,--EnfStatus_CODE,
           StatusCurrent_DATE,
           RsnStatusCase_CODE,
           InterstateEligibleRevw_INDC,
           OrderSeq_NUMB,
           IssuingOrderFips_CODE,
           CoverageOthers_CODE,
           BeginObligationRecent_DATE,
           ObleCs_AMNT,
           ObleMs_AMNT,
           ObleSs_AMNT,
           ObleNf_AMNT,
           TotToDistributeMtd_AMNT,
           ExpectToPay_AMNT,
           DistributeLast_DATE,
           LastIdenPaymentReceived_DATE,
           PhoneCp_NUMB,
           PhoneNcp_NUMB,
           InsuranceExistsCp_INDC,
           InsuranceExistsNcp_INDC,
           LicenseExistsCp_INDC,
           CrptStrt_INDC,
           CcloStrt_INDC,
           LintStrt_INDC,
           OgcoStrt_INDC,
           PsocStrt_INDC,
           RevwStrt_INDC,
           CrimExempt_INDC,
           LienExempt_INDC,
           SeqoExempt_INDC)
   SELECT C.Case_IDNO AS Case_IDNO,
          ISNULL(ncp.MemberMci_IDNO, 0) AS NcpPf_IDNO,
          ISNULL(CASE
                  WHEN (ncp.TypePrimary_CODE = @Lc_TypePrimary_SSN
                        AND ncp.Enumeration_CODE = @Lc_VerificationStatusGood_CODE)
                   THEN ncp.MemberSsn_NUMB
                  ELSE 0
                 END, 0) AS NcpPfSsn_NUMB,
          C.County_IDNO,
          C.TypeCase_CODE,
          C.StatusCase_CODE,
          C.RespondInit_CODE,
          CASE C.RespondInit_CODE
           WHEN @Lc_RespondInitInitiate_TEXT
            THEN ISNULL(i.Interstate_QNTY, 0)
           ELSE 0
          END AS InterstateEligible_NUMB,
          ISNULL(S.InsOrdered_CODE, @Lc_Space_TEXT) AS InsOrdered_CODE,
          ISNULL(S.Iiwo_CODE, @Lc_Space_TEXT) AS Iiwo_CODE,
          ISNULL(S.MedicalOnly_INDC, @Lc_Space_TEXT) AS MedicalOnly_INDC,
          ISNULL(S.LastReview_DATE, @Ld_Low_DATE) AS LastReview_DATE,
          ISNULL(S.OrderIssued_DATE, @Ld_Low_DATE) AS OrderIssued_DATE,
          ISNULL(S.OrderEffective_DATE, @Ld_Low_DATE) AS OrderEffective_DATE,
          ISNULL(S.OrderEnd_DATE, @Ld_Low_DATE) AS OrderEnd_DATE,
          ISNULL(S.TypeOrder_CODE, @Lc_Space_TEXT) AS TypeOrder_CODE,
          ISNULL(ncp.CaseMemberStatus_CODE, @Lc_Space_TEXT) AS CaseMemberStatus_CODE,
          ISNULL(ncp.Bankruptcy_INDC, @Lc_No_INDC) AS Bankruptcy13_INDC,
          ISNULL(S.Mso_AMNT, 0) AS Mso_AMNT,
          ISNULL(S.Arrears_AMNT, 0) AS Arrears_AMNT,
          ISNULL(S.MsoCsms_AMNT, 0) AS MsoCsms_AMNT,
          ISNULL(S.MissedCurSup_AMNT, 0) AS BalanceCurSup_AMNT,--MissedCurSup_AMNT,
          ISNULL(S.ArrearsCsms_AMNT, 0) AS ArrearsCsms_AMNT,
          ISNULL(ncp.ReceiptLast_DATE, @Ld_Low_DATE) AS ReceiptLast_DATE,
          ISNULL(S.CaseExempt_INDC, @Lc_No_INDC) AS CaseExempt_INDC,
          ISNULL(S.FullArrears_AMNT, 0) AS FullArrears_AMNT,
          ISNULL(S.ArrearsReg_AMNT, 0) AS ArrearsReg_AMNT,
          ISNULL(ncp.PaymentYtd_AMNT, 0) AS TotYtdColl_AMNT,
          ISNULL(ncp.TotMtdColl_AMNT, 0) AS TotMtdColl_AMNT,
          ISNULL(rk.Lsup_PaymentLastReceived_AMNT, 0) AS PaymentLastReceived_AMNT,
          ISNULL(w.DefraPrevMonth_AMNT, 0) AS DefraPrevMonth_AMNT,
          ISNULL(d.CheckLastCp_AMNT, 0) AS CheckLastCp_AMNT,
          CASE
           WHEN ISNULL(S.ExpectToPay_AMNT, 0) = 0
            THEN @Lc_Space_TEXT
           ELSE 'M'
          END AS FreqPayback_CODE,
          ISNULL(S.FreqLeastOble_CODE, @Lc_Space_TEXT) AS FreqLeastOble_CODE,
          ISNULL(S.ExpectToPay_CODE,@Lc_Space_TEXT) AS TypePayback_CODE,
          ISNULL(ncp.Source_CODE, @Lc_Space_TEXT) AS SourceReceiptLast_CODE,
          ISNULL(s.NextPayLeastOble_DATE, @Ld_Low_DATE) AS NextPayLeastOble_DATE,
          ISNULL(d.CheckLastCp_DATE, @Ld_Low_DATE) AS CheckLastCp_DATE,
          ISNULL(rk.LastRegularPaymentReceived_DATE, @Ld_Low_DATE)AS LastRegularPaymentReceived_DATE,
          ISNULL(S.CourtOrderIssuedOrg_DATE, @Ld_Low_DATE) AS CourtOrderIssuedOrg_DATE,
          ISNULL(mnr.MinorIrsci_DATE, @Ld_Low_DATE) AS GenerateIrsci_DATE,
          ISNULL(mnr.MinorEmani_DATE, @Ld_Low_DATE) AS GenerateEmancipation_DATE,
          ISNULL(mnr.MinorDelqn_DATE, @Ld_Low_DATE) AS GenerateDelqn_DATE,
          ISNULL(ncp.Dismissed_DATE, @Ld_Low_DATE) AS Dismissed_DATE,
          ISNULL(ncp.Discharge_DATE, @Ld_Low_DATE) AS Discharge_DATE,
          ISNULL(ncp.Filed_DATE, @Ld_Low_DATE) AS Filed_DATE,
          ISNULL(S.File_ID, @Lc_Space_TEXT) AS File_ID,
          ISNULL(W.CaseWelfare_IDNO, 0) AS CaseWelfare_IDNO,
          ISNULL(W.MultiIva_INDC, @Lc_No_INDC) AS MultiIva_INDC,
          C.Worker_ID AS WorkerCase_ID,
          ISNULL(ncp.Incarceration_DATE, @Ld_Low_DATE) AS Incarceration_DATE,
          ISNULL(ncp.Institutionalized_DATE, @Ld_Low_DATE) AS Institutionalized_DATE,
          ISNULL(ncp.Deceased_DATE, @Ld_Low_DATE) AS Deceased_DATE,
          ISNULL(ncp.Release_DATE, @Ld_High_DATE) AS Released_DATE,
          ISNULL(S.CaseChargingArrears_CODE, @Lc_No_INDC) AS CaseChargingArrears_CODE,
          ISNULL(S.CejFips_CODE, @Lc_Space_TEXT) AS CejFips_CODE,
          ISNULL(S.CejStatus_CODE, @Lc_Space_TEXT) AS CejStatus_CODE,
          ISNULL(S.CoverageDental_CODE, @Lc_Space_TEXT) AS CoverageDental_CODE,
          ISNULL(S.CoverageDrug_CODE, @Lc_Space_TEXT) AS CoverageDrug_CODE,
          ISNULL(S.CoverageMedical_CODE, @Lc_Space_TEXT) AS CoverageMedical_CODE,
          ISNULL(S.CoverageMental_CODE, @Lc_Space_TEXT) AS CoverageMental_CODE,
          ISNULL(S.CoverageVision_CODE, @Lc_Space_TEXT) AS CoverageVision_CODE,
          ISNULL(cp.MemberMci_IDNO, 0) AS CpMci_IDNO,
          ISNULL(ncp.MemberSsn_NUMB, 0) AS VerifiedltinNcpOrpfSsn_NUMB,
          ISNULL(cp.MemberSsn_NUMB, 0) AS VerifiedItinCpSsn_NUMB,
          ISNULL(ncp.Last_NAME, @Lc_Space_TEXT) AS LastNcp_NAME,
          ISNULL(ncp.First_NAME, @Lc_Space_TEXT) AS FirstNcp_NAME,
          ISNULL(ncp.Middle_NAME, @Lc_Space_TEXT) AS MiNcp_NAME,
          ISNULL(ncp.Suffix_NAME, @Lc_Space_TEXT) AS SuffixNcp_NAME,
          ISNULL(ncp.Birth_DATE, @Ld_Low_DATE) AS BirthNcp_DATE,
          ISNULL(ncp.Line1_ADDR, @Lc_Space_TEXT) AS Line1Ncp_ADDR,
          ISNULL(ncp.Line2_ADDR, @Lc_Space_TEXT) AS Line2Ncp_ADDR,
          ISNULL(ncp.City_ADDR, @Lc_Space_TEXT) AS CityNcp_ADDR,
          ISNULL(ncp.State_ADDR, @Lc_Space_TEXT) AS StateNcp_ADDR,
          ISNULL(ncp.Zip_ADDR, @Lc_Space_TEXT) AS ZipNcp_ADDR,
          ISNULL(ncp.Country_ADDR, @Lc_Space_TEXT) AS CountryNcp_ADDR,
          ISNULL(ncp.NcpInstateResidence_INDC, @Lc_No_INDC) AS NcpInstateResidence_INDC,
          CASE ncp.AddrExists_INDC
           WHEN @Lc_VerificationStatusGood_CODE
            THEN @Lc_Yes_INDC
           ELSE @Lc_No_INDC
          END AS NcpVerifiedAddrExist_INDC,
          CASE
           WHEN ncp.AddrExists_INDC IN (@Lc_VerificationStatusGood_CODE, 'P', 'N')
            THEN @Lc_Yes_INDC
           ELSE @Lc_No_INDC
          END AS NcpAddrExist_INDC,
          CASE ncp.StatusNe_CODE
           WHEN @Lc_VerificationStatusGood_CODE
            THEN @Lc_Yes_INDC
           ELSE @Lc_No_INDC
          END AS NcpEmplExist_INDC,
          ISNULL(cp.Last_NAME, @Lc_Space_TEXT) AS LastCp_NAME,
          ISNULL(cp.First_NAME, @Lc_Space_TEXT) AS FirstCp_NAME,
          ISNULL(cp.Middle_NAME, @Lc_Space_TEXT) AS MiCp_NAME,
          ISNULL(cp.Suffix_NAME, @Lc_Space_TEXT) AS SuffixCp_NAME,
          ISNULL(cp.Birth_DATE, @Ld_Low_DATE) AS BirthCp_DATE,
          ISNULL(cp.Line1_ADDR, @Lc_Space_TEXT) AS Line1Cp_ADDR,
          ISNULL(cp.Line2_ADDR, @Lc_Space_TEXT) AS Line2Cp_ADDR,
          ISNULL(cp.City_ADDR, @Lc_Space_TEXT) AS CityCp_ADDR,
          ISNULL(cp.State_ADDR, @Lc_Space_TEXT) AS StateCp_ADDR,
          ISNULL(cp.Zip_ADDR, @Lc_Space_TEXT) AS ZipCp_ADDR,
          ISNULL(cp.Country_ADDR, @Lc_Space_TEXT) AS CountryCp_ADDR,
          ISNULL(cp.CpInStateResidence_INDC, @Lc_No_INDC) AS CpInStateResidence_INDC,
          CASE cp.AddrExists_INDC
           WHEN @Lc_VerificationStatusGood_CODE
            THEN @Lc_Yes_INDC
           ELSE @Lc_No_INDC
          END AS VerCpAddrExist_INDC,
          ISNULL(s.CsObligationExist_INDC, @Lc_No_INDC) AS CsObligationExist_INDC,
          ISNULL(s.MsObligationExist_INDC, @Lc_No_INDC) AS MsObligationExist_INDC,
          ISNULL(s.SsObligationExist_INDC, @Lc_No_INDC) AS SsObligationExist_INDC,
          ISNULL(ncp.MeansTestedInc_INDC, @Lc_No_INDC) AS MeansTestedInc_INDC,
          ISNULL(ncp.DrLicenseExist_INDC, @Lc_No_INDC) AS LicenseExist_INDC,
          ISNULL(mjr.ArenExempt_INDC, @Lc_No_INDC) AS ArenExempt_INDC,
          ISNULL(mjr.CrptExempt_INDC, @Lc_No_INDC) AS CrptExempt_INDC,
          ISNULL(mjr.CslnExempt_INDC, @Lc_No_INDC) AS CslnExempt_INDC,
          ISNULL(mjr.FidmExempt_INDC, @Lc_No_INDC) AS FidmExempt_INDC,
          ISNULL(mjr.ImiwExempt_INDC, @Lc_No_INDC) AS ImiwExempt_INDC,
          ISNULL(mjr.LintExempt_INDC, @Lc_No_INDC) AS LintExempt_INDC,
          ISNULL(mjr.QdroExempt_INDC, @Lc_No_INDC) AS QdroExempt_INDC,
          ISNULL(mjr.LsnrExempt_INDC, @Lc_No_INDC) AS LsnrExempt_INDC,
          ISNULL(mjr.NmsnExempt_INDC, @Lc_No_INDC) AS NmsnExempt_INDC,
          ISNULL(mjr.PsocExempt_INDC, @Lc_No_INDC) AS PsocExempt_INDC,
          ISNULL(C.NonCoop_CODE, @Lc_Space_TEXT) AS NonCoop_CODE,
          ISNULL(C.GoodCause_CODE, @Lc_Space_TEXT) AS GoodCause_CODE,
          ISNULL(C.CaseCategory_CODE, @Lc_Space_TEXT) AS CaseCategory_CODE,
          ISNULL(C.StatusEnforce_CODE, @Lc_Space_TEXT) AS StatusEnforce_CODE,
          ISNULL(C.StatusCurrent_DATE, @Ld_Low_DATE) AS StatusCurrent_DATE,
          ISNULL(C.RsnStatusCase_CODE, @Lc_Space_TEXT) AS RsnStatusCase_CODE,
          ISNULL(i2.InterstateEligibleRevw_INDC, @Lc_No_INDC) AS InterstateEligibleRevw_INDC,
          ISNULL(S.OrderSeq_NUMB, 0) AS OrderSeq_NUMB,
          ISNULL(S.IssuingOrderFips_CODE, @Lc_Space_TEXT) AS IssuingOrderFips_CODE,
          ISNULL(S.CoverageOthers_CODE, @Lc_Space_TEXT) AS CoverageOthers_CODE,
          ISNULL(S.BeginObligationRecent_DATE, @Ld_Low_DATE) AS BeginObligationRecent_DATE,
          ISNULL(S.MsoCs_AMNT, 0) AS ObleCs_AMNT,
          ISNULL(S.MsoMs_AMNT, 0) AS ObleMs_AMNT,
          ISNULL(S.MsoSs_AMNT, 0) AS ObleSs_AMNT,
          ISNULL(S.MsoNf_AMNT, 0) AS ObleNf_AMNT,
          ISNULL(TotToDistributeMtd_AMNT, 0) AS TotToDistributeMtd_AMNT,
          ISNULL(S.ExpectToPay_AMNT, 0) AS ExpectToPay_AMNT,
          ISNULL(ncp.DistributeLast_DATE, @Ld_Low_DATE) AS DistributeLast_DATE,
          ISNULL(ncp.LastIdenPaymentReceived_DATE, @Ld_Low_DATE) AS LastIdenPaymentReceived_DATE,
          ISNULL(cp.Phone_NUMB, 0) AS PhoneCp_NUMB,
          ISNULL(ncp.Phone_NUMB, 0) AS PhoneNcp_NUMB,
          ISNULL(cp.InsuranceExistsCp_INDC, @Lc_No_INDC) AS InsuranceExistsCp_INDC,
          ISNULL(ncp.InsuranceExistsNcp_INDC, @Lc_No_INDC) AS InsuranceExistsNcp_INDC,
          ISNULL(cp.DrLicenseExist_INDC, @Lc_No_INDC) AS LicenceExistsCp_INDC,
          ISNULL(mjr.CrptStrt_INDC, @Lc_No_INDC) AS CrptStrt_INDC,
          ISNULL(mjr.CcloStrt_INDC, @Lc_No_INDC) AS CwclStrt_INDC,
          ISNULL(mjr.LintStrt_INDC, @Lc_No_INDC) AS LintStrt_INDC,
          ISNULL(mjr.OgcoStrt_INDC, @Lc_No_INDC) AS OgcoStrt_INDC,
          ISNULL(mjr.PsocStrt_INDC, @Lc_No_INDC) AS PsocStrt_INDC,
          ISNULL(mjr.RevwStrt_INDC, @Lc_No_INDC) AS RevwStrt_INDC,
          ISNULL(mjr.CrimExempt_INDC, @Lc_No_INDC) AS CrimExempt_INDC,
          ISNULL(mjr.LienExempt_INDC, @Lc_No_INDC) AS LienExempt_INDC,
          ISNULL(mjr.SeqoExempt_INDC, @Lc_No_INDC) AS SeqoExempt_INDC
     FROM CASE_Y1 AS C WITH (INDEX(0)) 
          LEFT OUTER JOIN (SELECT so.Case_IDNO,
                                  so.OrderSeq_NUMB,
                                  so.Order_IDNO,
                                  so.File_ID,
                                  so.OrderEnt_DATE,
                                  so.OrderIssued_DATE,
                                  so.OrderEffective_DATE,
                                  so.OrderEnd_DATE,
                                  so.ReasonStatus_CODE,
                                  so.StatusOrder_CODE,
                                  so.StatusOrder_DATE,
                                  so.InsOrdered_CODE,
                                  so.MedicalOnly_INDC,
                                  so.Iiwo_CODE,
                                  so.NoIwReason_CODE,
                                  so.IwoInitiatedBy_CODE,
                                  so.GuidelinesFollowed_INDC,
                                  so.DeviationReason_CODE,
                                  so.DescriptionDeviationOthers_TEXT,
                                  so.OrderOutOfState_ID,
                                  so.CejStatus_CODE,
                                  so.CejFips_CODE,
                                  so.IssuingOrderFips_CODE,
                                  so.Qdro_INDC,
                                  so.UnreimMedical_INDC,
                                  so.CpMedical_PCT,
                                  so.NcpMedical_PCT,
                                  so.ParentingTime_PCT,
                                  so.NoParentingDays_QNTY,
                                  so.PetitionerAppeared_INDC,
                                  so.RespondentAppeared_INDC,
                                  so.OthersAppeared_INDC,
                                  so.PetitionerReceived_INDC,
                                  so.RespondentReceived_INDC,
                                  so.OthersReceived_INDC,
                                  so.PetitionerMailed_INDC,
                                  so.RespondentMailed_INDC,
                                  so.OthersMailed_INDC,
                                  so.PetitionerMailed_DATE,
                                  so.RespondentMailed_DATE,
                                  so.OthersMailed_DATE,
                                  so.CoverageMedical_CODE,
                                  so.CoverageDrug_CODE,
                                  so.CoverageMental_CODE,
                                  so.CoverageDental_CODE,
                                  so.CoverageVision_CODE,
                                  so.CoverageOthers_CODE,
                                  so.DescriptionCoverageOthers_TEXT,
                                  so.WorkerUpdate_ID,
                                  so.BeginValidity_DATE,
                                  so.EndValidity_DATE,
                                  so.EventGlobalBeginSeq_NUMB,
                                  so.EventGlobalEndSeq_NUMB,
                                  so.DescriptionParentingNotes_TEXT,
                                  so.LastIrscReferred_DATE,
                                  so.LastIrscUpdated_DATE,
                                  so.LastIrscReferred_AMNT,
                                  so.StatusControl_CODE,
                                  so.StateControl_CODE,
                                  so.OrderControl_ID,
                                  so.PetitionerAttorneyAppeared_INDC,
                                  so.RespondentAttorneyAppeared_INDC,
                                  so.PetitionerAttorneyReceived_INDC,
                                  so.RespondentAttorneyReceived_INDC,
                                  so.PetitionerAttorneyMailed_INDC,
                                  so.RespondentAttorneyMailed_INDC,
                                  so.PetitionerAttorneyMailed_DATE,
                                  so.RespondentAttorneyMailed_DATE,
                                  so.TypeOrder_CODE,
                                  so.ReviewRequested_DATE,
                                  so.NextReview_DATE,
                                  so.LastReview_DATE,
                                  so.LastNoticeSent_DATE,
                                  so.DirectPay_INDC,
                                  so.SourceOrdered_CODE,
                                  so.CourtOrderIssuedOrg_DATE,
                                  ob.ExpectToPay_CODE,
                                  ISNULL(ob.Mso_AMNT, 0) AS Mso_AMNT,
                                  ob.CurrObleExists_INDC,
                                  ISNULL(ob.Arrears_AMNT, 0) AS Arrears_AMNT,
                                  ISNULL(ob.FullArrears_AMNT, 0) AS FullArrears_AMNT,
                                  ISNULL(ob.RegArrears_AMNT, 0) AS ArrearsReg_AMNT,
                                  ISNULL(ob.MsoCsms_AMNT, 0) AS MsoCsms_AMNT,
                                  ISNULL(ob.MissedCurSup_AMNT, 0) AS MissedCurSup_AMNT,
                                  ISNULL(ob.ArrearsCsms_AMNT, 0) AS ArrearsCsms_AMNT,
                                  ob.CsObligationExist_INDC,
                                  ob.MsObligationExist_INDC,
                                  ob.SsObligationExist_INDC,
                                  ob.FreqLeastOble_CODE,
                                  ob.NextPayLeastOble_DATE,
                                  ob.ExpectToPay_AMNT,
                                  ob.BeginObligationRecent_DATE,
                                  ob.MsoCs_AMNT,
                                  ob.MsoMs_AMNT,
                                  ob.MsoSs_AMNT,
                                  ob.MsoNf_AMNT,
                                  CASE
                                   WHEN ISNULL(ob.Chrg_QNTY, 0) > 0
                                    THEN @Lc_ChargingCase_TEXT
                                   WHEN ISNULL(ob.Chrg_QNTY, 0) = 0
                                        AND ISNULL(ob.Arrears_AMNT, 0) > 0
                                    THEN @Lc_ArrearsonlyCase_TEXT
                                   ELSE @Lc_NotchargingOrArrearsCase_TEXT
                                  END AS CaseChargingArrears_CODE,
                                  ac.CaseExempt_INDC
                             FROM sord_tab AS so WITH (INDEX(0))
                                  LEFT OUTER JOIN (SELECT ob.Case_IDNO,
                                                          ob.OrderSeq_NUMB,
                                                          ISNULL(MAX(ob.ExpectToPay_CODE), @Lc_Space_TEXT) AS ExpectToPay_CODE,
                                                          -- 13619 - GT payment on arrears frequency displays on IWO as One Time Only - Starts
                                                          ROUND(ISNULL(SUM(CASE ob.FreqPeriodic_CODE
                                                                              WHEN @Lc_Daily_TEXT
                                                                               THEN (ob.ExpectToPay_AMNT * 365) / 12
                                                                              WHEN @Lc_Weekly_TEXT
                                                                               THEN (ob.ExpectToPay_AMNT * 52) / 12
                                                                              WHEN @Lc_Monthly_TEXT
                                                                               THEN (ob.ExpectToPay_AMNT * 12) / 12
                                                                              WHEN @Lc_Biweekly_TEXT
                                                                               THEN (ob.ExpectToPay_AMNT * 26) / 12
                                                                              WHEN @Lc_Semimonthly_TEXT
                                                                               THEN (ob.ExpectToPay_AMNT * 24) / 12
                                                                              WHEN @Lc_Annual_TEXT
                                                                               THEN (ob.ExpectToPay_AMNT / 12)
                                                                              ELSE ob.ExpectToPay_AMNT
                                                                             END), 0), 2) AS ExpectToPay_AMNT,
														  -- 13619 - GT payment on arrears frequency displays on IWO as One Time Only - Ends
                                                          ROUND(ISNULL(SUM(CASE
                                                                            WHEN ob.Active_INDC = @Lc_Yes_INDC
                                                                                 AND ob.CsMsSs_INDC = @Lc_Yes_INDC
                                                                                 AND ob.FreqPeriodic_CODE != @Lc_Onetime_TEXT
                                                                             THEN
                                                                             CASE ob.FreqPeriodic_CODE
                                                                              WHEN @Lc_Daily_TEXT
                                                                               THEN (ob.Periodic_AMNT * 365) / 12
                                                                              WHEN @Lc_Weekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 52) / 12
                                                                              WHEN @Lc_Monthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 12) / 12
                                                                              WHEN @Lc_Biweekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 26) / 12
                                                                              WHEN @Lc_Semimonthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 24) / 12
                                                                              WHEN @Lc_Annual_TEXT
                                                                               THEN (ob.Periodic_AMNT / 12)
                                                                              ELSE ob.Periodic_AMNT
                                                                             END
                                                                            ELSE 0
                                                                           END), 0), 2) AS Mso_AMNT,
                                                          ROUND(ISNULL(SUM(CASE
                                                                            WHEN ob.Csms_INDC = @Lc_Yes_INDC
                                                                                 AND ob.FreqPeriodic_CODE != @Lc_Onetime_TEXT
                                                                             THEN
                                                                             CASE ob.FreqPeriodic_CODE
                                                                              WHEN @Lc_Daily_TEXT
                                                                               THEN (ob.Periodic_AMNT * 365) / 12
                                                                              WHEN @Lc_Weekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 52) / 12
                                                                              WHEN @Lc_Monthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 12) / 12
                                                                              WHEN @Lc_Biweekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 26) / 12
                                                                              WHEN @Lc_Semimonthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 24) / 12
                                                                              WHEN @Lc_Annual_TEXT
                                                                               THEN (ob.Periodic_AMNT / 12)
                                                                              ELSE ob.Periodic_AMNT
                                                                             END
                                                                            ELSE 0
                                                                           END), 0), 2) AS MsoCsms_AMNT,
                                                          ROUND(ISNULL(SUM(CASE
                                                                            WHEN (ob.OblCs_INDC = @Lc_Yes_INDC)
                                                                                 AND ob.Active_INDC = @Lc_Yes_INDC
                                                                                 AND ob.FreqPeriodic_CODE != @Lc_Onetime_TEXT
                                                                             THEN
                                                                             CASE ob.FreqPeriodic_CODE
                                                                              WHEN @Lc_Daily_TEXT
                                                                               THEN (ob.Periodic_AMNT * 365) / 12
                                                                              WHEN @Lc_Weekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 52) / 12
                                                                              WHEN @Lc_Monthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 12) / 12
                                                                              WHEN @Lc_Biweekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 26) / 12
                                                                              WHEN @Lc_Semimonthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 24) / 12
                                                                              WHEN @Lc_Annual_TEXT
                                                                               THEN (ob.Periodic_AMNT / 12)
                                                                              ELSE ob.Periodic_AMNT
                                                                             END
                                                                            ELSE 0
                                                                           END), 0), 2) AS MsoCs_AMNT,
                                                          ROUND(ISNULL(SUM(CASE
                                                                            WHEN (ob.OblMs_INDC = @Lc_Yes_INDC)
                                                                                 AND ob.Active_INDC = @Lc_Yes_INDC
                                                                                 AND ob.FreqPeriodic_CODE != @Lc_Onetime_TEXT
                                                                             THEN
                                                                             CASE ob.FreqPeriodic_CODE
                                                                              WHEN @Lc_Daily_TEXT
                                                                               THEN (ob.Periodic_AMNT * 365) / 12
                                                                              WHEN @Lc_Weekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 52) / 12
                                                                              WHEN @Lc_Monthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 12) / 12
                                                                              WHEN @Lc_Biweekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 26) / 12
                                                                              WHEN @Lc_Semimonthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 24) / 12
                                                                              WHEN @Lc_Annual_TEXT
                                                                               THEN (ob.Periodic_AMNT / 12)
                                                                              ELSE ob.Periodic_AMNT
                                                                             END
                                                                            ELSE 0
                                                                           END), 0), 2) AS MsoMs_AMNT,
                                                          ROUND(ISNULL(SUM(CASE
                                                                            WHEN ob.OblSs_INDC = @Lc_Yes_INDC
                                                                                 AND ob.Active_INDC = @Lc_Yes_INDC
                                                                                 AND ob.FreqPeriodic_CODE != @Lc_Onetime_TEXT
                                                                             THEN
                                                                             CASE ob.FreqPeriodic_CODE
                                                                              WHEN @Lc_Daily_TEXT
                                                                               THEN (ob.Periodic_AMNT * 365) / 12
                                                                              WHEN @Lc_Weekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 52) / 12
                                                                              WHEN @Lc_Monthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 12) / 12
                                                                              WHEN @Lc_Biweekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 26) / 12
                                                                              WHEN @Lc_Semimonthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 24) / 12
                                                                              WHEN @Lc_Annual_TEXT
                                                                               THEN (ob.Periodic_AMNT / 12)
                                                                              ELSE ob.Periodic_AMNT
                                                                             END
                                                                            ELSE 0
                                                                           END), 0), 2) AS MsoSs_AMNT,
                                                          ROUND(ISNULL(SUM(CASE
                                                                            WHEN ob.OblNf_INDC = @Lc_Yes_INDC
                                                                                 AND ob.Active_INDC = @Lc_Yes_INDC
                                                                                 AND ob.FreqPeriodic_CODE != @Lc_Onetime_TEXT
                                                                             THEN
                                                                             CASE ob.FreqPeriodic_CODE
                                                                              WHEN @Lc_Daily_TEXT
                                                                               THEN (ob.Periodic_AMNT * 365) / 12
                                                                              WHEN @Lc_Weekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 52) / 12
                                                                              WHEN @Lc_Monthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 12) / 12
                                                                              WHEN @Lc_Biweekly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 26) / 12
                                                                              WHEN @Lc_Semimonthly_TEXT
                                                                               THEN (ob.Periodic_AMNT * 24) / 12
                                                                              WHEN @Lc_Annual_TEXT
                                                                               THEN (ob.Periodic_AMNT / 12)
                                                                              ELSE ob.Periodic_AMNT
                                                                             END
                                                                            ELSE 0
                                                                           END), 0), 2) AS MsoNf_AMNT,
                                                          ROUND(ISNULL(SUM(ISNULL(ISNULL((ls.OweTotNaa_AMNT - ls.AppTotNaa_AMNT), 0) + ISNULL((ls.OweTotPaa_AMNT - ls.AppTotPaa_AMNT), 0) + ISNULL((ls.OweTotTaa_AMNT - ls.AppTotTaa_AMNT), 0) + ISNULL((ls.OweTotCaa_AMNT - ls.AppTotCaa_AMNT), 0) + ISNULL((ls.OweTotUpa_AMNT - ls.AppTotUpa_AMNT), 0) + ISNULL((ls.OweTotUda_AMNT - ls.AppTotUda_AMNT), 0) + ISNULL((ls.OweTotIvef_AMNT - ls.AppTotIvef_AMNT), 0) + ISNULL((ls.OweTotNffc_AMNT - ls.AppTotNffc_AMNT), 0) + ISNULL((ls.OweTotMedi_AMNT - ls.AppTotMedi_AMNT), 0) + ISNULL((ls.OweTotNonIvd_AMNT - ls.AppTotNonIvd_AMNT), 0) - (ls.OweTotCurSup_AMNT - ls.AppTotCurSup_AMNT + CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                WHEN ls.MtdCurSupOwed_AMNT < ls.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 THEN ls.AppTotCurSup_AMNT - ls.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               END), 0)), 0), 2)AS FullArrears_AMNT,
                                                          ROUND(ISNULL(SUM(ISNULL((ls.OweTotNaa_AMNT - ls.AppTotNaa_AMNT), 0) + ISNULL((ls.OweTotPaa_AMNT - ls.AppTotPaa_AMNT), 0) + ISNULL((ls.OweTotTaa_AMNT - ls.AppTotTaa_AMNT), 0) + ISNULL((ls.OweTotCaa_AMNT - ls.AppTotCaa_AMNT), 0) + ISNULL((ls.OweTotUpa_AMNT - ls.AppTotUpa_AMNT), 0) + ISNULL((ls.OweTotUda_AMNT - ls.AppTotUda_AMNT), 0) + ISNULL((ls.OweTotIvef_AMNT - ls.AppTotIvef_AMNT), 0) + ISNULL((ls.OweTotNffc_AMNT - ls.AppTotNffc_AMNT), 0) + ISNULL((ls.OweTotMedi_AMNT - ls.AppTotMedi_AMNT), 0) + ISNULL((ls.OweTotNonIvd_AMNT - ls.AppTotNonIvd_AMNT), 0)), 0), 2) AS RegArrears_AMNT,
                                                          ROUND(ISNULL(SUM(CASE
                                                                            WHEN ob.CsMsSs_INDC = @Lc_Yes_INDC
                                                                             THEN ISNULL((ls.OweTotNaa_AMNT - ls.AppTotNaa_AMNT), 0) + ISNULL((ls.OweTotPaa_AMNT - ls.AppTotPaa_AMNT), 0) + ISNULL((ls.OweTotTaa_AMNT - ls.AppTotTaa_AMNT), 0) + ISNULL((ls.OweTotCaa_AMNT - ls.AppTotCaa_AMNT), 0) + ISNULL((ls.OweTotUpa_AMNT - ls.AppTotUpa_AMNT), 0) + ISNULL((ls.OweTotUda_AMNT - ls.AppTotUda_AMNT), 0) + ISNULL((ls.OweTotIvef_AMNT - ls.AppTotIvef_AMNT), 0) + ISNULL((ls.OweTotNffc_AMNT - ls.AppTotNffc_AMNT), 0) + ISNULL((ls.OweTotMedi_AMNT - ls.AppTotMedi_AMNT), 0) + ISNULL((ls.OweTotNonIvd_AMNT - ls.AppTotNonIvd_AMNT), 0) - (ls.OweTotCurSup_AMNT - ls.AppTotCurSup_AMNT + CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                WHEN ls.MtdCurSupOwed_AMNT < ls.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 THEN ls.AppTotCurSup_AMNT - ls.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               END)
                                                                            ELSE 0
                                                                           END), 0), 2) AS Arrears_AMNT,
                                                          ROUND(ISNULL(SUM(CASE
                                                                            WHEN ob.Csms_INDC = @Lc_Yes_INDC
                                                                             THEN ISNULL((ls.OweTotNaa_AMNT - ls.AppTotNaa_AMNT), 0) + ISNULL((ls.OweTotPaa_AMNT - ls.AppTotPaa_AMNT), 0) + ISNULL((ls.OweTotTaa_AMNT - ls.AppTotTaa_AMNT), 0) + ISNULL((ls.OweTotCaa_AMNT - ls.AppTotCaa_AMNT), 0) + ISNULL((ls.OweTotUpa_AMNT - ls.AppTotUpa_AMNT), 0) + ISNULL((ls.OweTotUda_AMNT - ls.AppTotUda_AMNT), 0) + ISNULL((ls.OweTotIvef_AMNT - ls.AppTotIvef_AMNT), 0) + ISNULL((ls.OweTotNffc_AMNT - ls.AppTotNffc_AMNT), 0) + ISNULL((ls.OweTotMedi_AMNT - ls.AppTotMedi_AMNT), 0) + ISNULL((ls.OweTotNonIvd_AMNT - ls.AppTotNonIvd_AMNT), 0) - (ls.OweTotCurSup_AMNT - ls.AppTotCurSup_AMNT + CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                WHEN ls.MtdCurSupOwed_AMNT < ls.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 THEN ls.AppTotCurSup_AMNT - ls.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               END)
                                                                            ELSE 0
                                                                           END), 0), 2) AS ArrearsCsms_AMNT,
                                                          SUM(CASE
                                                               WHEN ob.Active_INDC = @Lc_Yes_INDC
                                                                    AND ob.CsMsSs_INDC = @Lc_Yes_INDC
                                                                    AND ob.Periodic_AMNT > 0
                                                                THEN 1
                                                               ELSE 0
                                                              END) AS Chrg_QNTY,
                                                          ISNULL(MAX(ob.OblCs_INDC), 0) AS CsObligationExist_INDC,
                                                          ISNULL(MAX(ob.OblMs_INDC), 0) AS MsObligationExist_INDC,
                                                          ISNULL(MAX(ob.OblSs_INDC), 0) AS SsObligationExist_INDC,
                                                          ISNULL(MAX(ob.OblNf_INDC), 0) AS NfObligationExist_INDC,
                                                          ISNULL(MAX(ob.Active_INDC), 0) AS CurrObleExists_INDC,
                                                          CASE MAX(CASE
                                                                    WHEN ob.Active_INDC = @Lc_Yes_INDC
                                                                         AND ob.CsMsSs_INDC = @Lc_Yes_INDC
                                                                     THEN ob.DecFreqPeriodic_QNTY
                                                                    ELSE -1
                                                                   END)
                                                           WHEN 52
                                                            THEN @Lc_Weekly_TEXT
                                                           WHEN 26
                                                            THEN @Lc_Biweekly3_TEXT
                                                           WHEN 24
                                                            THEN @Lc_Semimonthly_TEXT
                                                           WHEN 12
                                                            THEN @Lc_Monthly_TEXT
                                                           WHEN 4
                                                            THEN @Lc_Quarterly_TEXT
                                                           WHEN 1
                                                            THEN @Lc_Annual_TEXT
                                                           WHEN 0
                                                            THEN @Lc_OnRequest_TEXT
                                                           ELSE @Lc_Weekly_TEXT
                                                          END AS FreqLeastOble_CODE,
                                                          MAX(CAST(CASE
                                                                    WHEN ob.Active_INDC = @Lc_Yes_INDC
                                                                         AND ob.CsMsSs_INDC = @Lc_Yes_INDC
                                                                     THEN ob.NextPayLeastOble_DATE
                                                                    ELSE @Ld_Low_DATE
                                                                   END AS DATETIME2)) AS NextPayLeastOble_DATE,
                                                          MAX(CAST(CASE
                                                                    WHEN ob.Active_INDC = @Lc_Yes_INDC
                                                                         AND ob.FreqPeriodic_CODE IN (@Lc_Daily_TEXT, @Lc_Weekly_TEXT, @Lc_Monthly_TEXT, @Lc_Biweekly_TEXT, @Lc_Semimonthly_TEXT)
                                                                     THEN ob.BeginObligation_DATE
                                                                    ELSE @Ld_Low_DATE
                                                                   END AS DATETIME2)) AS BeginObligationRecent_DATE,
                                                                   ROUND (ISNULL(SUM(ls2.MissedCurSup_AMNT), 0), 2) AS MissedCurSup_AMNT
                                                     FROM oble_tab AS ob WITH (INDEX(0))
                                                          LEFT OUTER JOIN (SELECT l.Case_IDNO,
                                                                                  l.OrderSeq_NUMB,
                                                                                  l.ObligationSeq_NUMB,
                                                                                  l.SupportYearMonth_NUMB,
                                                                                  l.TypeWelfare_CODE,
                                                                                  l.TransactionCurSup_AMNT,
                                                                                  l.OweTotCurSup_AMNT,
                                                                                  l.AppTotCurSup_AMNT,
                                                                                  l.MtdCurSupOwed_AMNT,
                                                                                  l.TransactionExptPay_AMNT,
                                                                                  l.OweTotExptPay_AMNT,
                                                                                  l.AppTotExptPay_AMNT,
                                                                                  l.TransactionNaa_AMNT,
                                                                                  l.OweTotNaa_AMNT,
                                                                                  l.AppTotNaa_AMNT,
                                                                                  l.TransactionPaa_AMNT,
                                                                                  l.OweTotPaa_AMNT,
                                                                                  l.AppTotPaa_AMNT,
                                                                                  l.TransactionTaa_AMNT,
                                                                                  l.OweTotTaa_AMNT,
                                                                                  l.AppTotTaa_AMNT,
                                                                                  l.TransactionCaa_AMNT,
                                                                                  l.OweTotCaa_AMNT,
                                                                                  l.AppTotCaa_AMNT,
                                                                                  l.TransactionUpa_AMNT,
                                                                                  l.OweTotUpa_AMNT,
                                                                                  l.AppTotUpa_AMNT,
                                                                                  l.TransactionUda_AMNT,
                                                                                  l.OweTotUda_AMNT,
                                                                                  l.AppTotUda_AMNT,
                                                                                  l.TransactionIvef_AMNT,
                                                                                  l.OweTotIvef_AMNT,
                                                                                  l.AppTotIvef_AMNT,
                                                                                  l.TransactionMedi_AMNT,
                                                                                  l.OweTotMedi_AMNT,
                                                                                  l.AppTotMedi_AMNT,
                                                                                  l.TransactionNffc_AMNT,
                                                                                  l.OweTotNffc_AMNT,
                                                                                  l.AppTotNffc_AMNT,
                                                                                  l.TransactionNonIvd_AMNT,
                                                                                  l.OweTotNonIvd_AMNT,
                                                                                  l.AppTotNonIvd_AMNT,
                                                                                  l.Batch_DATE,
                                                                                  l.SourceBatch_CODE,
                                                                                  l.Batch_NUMB,
                                                                                  l.SeqReceipt_NUMB,
                                                                                  l.Receipt_DATE,
                                                                                  l.Distribute_DATE,
                                                                                  l.TypeRecord_CODE,
                                                                                  l.EventFunctionalSeq_NUMB,
                                                                                  l.EventGlobalSeq_NUMB,
                                                                                  l.TransactionFuture_AMNT,
                                                                                  l.AppTotFuture_AMNT,
                                                                                  l.CheckRecipient_ID,
                                                                                  l.CheckRecipient_CODE,
                                                                                  l.row_num,
                                                                                  l.Current_INDC
                                                                             FROM lsup_tab AS l
                                                                            WHERE l.Current_INDC = @Lc_Yes_INDC) AS ls
                                                           ON ob.Case_IDNO = ls.Case_IDNO
                                                              AND ob.OrderSeq_NUMB = ls.OrderSeq_NUMB
                                                              AND ob.ObligationSeq_NUMB = ls.ObligationSeq_NUMB                                                            
                                                      LEFT OUTER JOIN (SELECT ls2.Case_IDNO,
                                                                              ls2.OrderSeq_NUMB,
                                                                              ls2.ObligationSeq_NUMB,
                                                                              ROUND (ISNULL(SUM(ls2.OweTotCurSup_AMNT - ls2.AppTotCurSup_AMNT), 0), 2) AS MissedCurSup_AMNT
                                                                         FROM (SELECT l.Case_IDNO,
                                                                                      l.OrderSeq_NUMB,
                                                                                      l.ObligationSeq_NUMB,
                                                                                      l.OweTotCurSup_AMNT,
                                                                                      l.AppTotCurSup_AMNT,
                                                                                      l.SupportYearMonth_NUMB,
                                                                                      ROW_NUMBER() OVER(partition BY l.Case_IDNO, l.OrderSeq_NUMB, l.ObligationSeq_NUMB ORDER BY L.SupportYearMonth_NUMB DESC, L.EventGlobalSeq_NUMB DESC) rnm
                                                                                 FROM lsup_tab AS l                                                                                
                                                                                WHERE l.SupportYearMonth_NUMB <= @Ln_SupportYearMonth_NUMB) AS ls2
                                                                        WHERE rnm = 1
                                                                        GROUP BY LS2.Case_IDNO,
                                                                                 LS2.OrderSeq_NUMB,
                                                                                 LS2.ObligationSeq_NUMB) ls2
                                                       ON ob.Case_IDNO = ls2.Case_IDNO
                                                          AND ob.OrderSeq_NUMB = ls2.OrderSeq_NUMB
                                                          AND ob.ObligationSeq_NUMB = ls2.ObligationSeq_NUMB
                                                    GROUP BY ob.Case_IDNO,
                                                             ob.OrderSeq_NUMB) AS ob
                                   ON so.Case_IDNO = ob.Case_IDNO
                                      AND so.OrderSeq_NUMB = ob.OrderSeq_NUMB								 
                                  LEFT OUTER JOIN (SELECT n.Case_IDNO,
                                                          n.OrderSeq_NUMB,
                                                          CASE
                                                           WHEN COUNT(1) >= 1
                                                            THEN @Lc_Yes_INDC
                                                           ELSE @Lc_No_INDC
                                                          END AS CaseExempt_INDC
                                                     FROM ACEN_Y1 AS n WITH (INDEX(0))
                                                    WHERE n.StatusEnforce_CODE = @Lc_StatusExempt_CODE
                                                      AND @Ad_Run_DATE BETWEEN n.BeginExempt_DATE AND n.EndExempt_DATE
                                                      AND n.BeginExempt_DATE <> @Ld_Low_DATE
                                                      AND n.EndValidity_DATE = @Ld_High_DATE
                                                    GROUP BY n.Case_IDNO,
                                                             n.OrderSeq_NUMB) AS ac
                                   ON so.Case_IDNO = ac.Case_IDNO
                                      AND so.OrderSeq_NUMB = ac.OrderSeq_NUMB) AS S
           ON C.Case_IDNO = S.Case_IDNO
          LEFT OUTER JOIN (SELECT cm.Case_IDNO,
                                  cm.MemberMci_IDNO,
                                  cm.CaseRelationship_CODE,
                                  cm.CaseMemberStatus_CODE,
                                  ns.MemberSsn_NUMB,
                                  ns.TypePrimary_CODE,
                                  ns.Enumeration_CODE,
                                  br.Bankruptcy_INDC,
                                  br.Filed_DATE,
                                  br.Discharge_DATE,
                                  br.Dismissed_DATE,
                                  rc.ReceiptLast_DATE,
                                  rc.TotToDistributeMtd_AMNT,
                                  rc.DistributeLast_DATE,
                                  ir.SeqReceipt_NUMB,
                                  ir.Source_CODE,
                                  ir.ToDistribute_AMNT,
                                  ir.PaymentYtd_AMNT,
                                  ir.TotMtdColl_AMNT,
                                  ir.LastRegIden_DATE AS LastIdenPaymentReceived_DATE,
                                  md.Incarceration_DATE,
                                  md.Institutionalized_DATE,
                                  CASE
									WHEN md.MaxRelease_DATE NOT IN (@Ld_Low_DATE, @Ld_High_DATE)
										AND md.MaxRelease_DATE < md.Release_DATE
									THEN md.MaxRelease_DATE
										WHEN md.Release_DATE != @Ld_Low_DATE 
									THEN md.Release_DATE
										ELSE @Ld_High_DATE
									END AS Release_DATE,
                                  dm.Deceased_DATE,
                                  dm.Last_NAME,
                                  dm.First_NAME,
                                  dm.Middle_NAME,
                                  dm.Suffix_NAME,
                                  dm.Birth_DATE,
                                  dm.MeansTestedInc_INDC,
                                  na.Line1_ADDR,
                                  na.Line2_ADDR, 
                                  na.City_ADDR,
                                  na.State_ADDR,
                                  na.Zip_ADDR,
                                  na.Country_ADDR,
                                  0 Phone_NUMB,
                                  na.Status_CODE,
                                  na.NcpInstateResidence_INDC,
                                  na.AddrExists_INDC,
                                  ne.Status_CODE AS StatusNe_CODE,
                                  pl.DrLicenseExist_INDC,
                                  mi.Status_CODE AS InsuranceExistsNcp_INDC
                             FROM cmem_ncp_tab AS cm
                                  LEFT OUTER JOIN ssn_tab AS ns
                                   ON cm.MemberMci_IDNO = ns.MemberMci_IDNO
                                  LEFT OUTER JOIN ahis_tab AS na
                                   ON cm.MemberMci_IDNO = na.MemberMci_IDNO
                                  LEFT OUTER JOIN ehis_tab AS ne
                                   ON cm.MemberMci_IDNO = ne.MemberMci_IDNO
                                  LEFT OUTER JOIN bnkr_tab AS br
                                   ON cm.MemberMci_IDNO = br.MemberMci_IDNO
                                  LEFT OUTER JOIN (SELECT r.PayorMCI_IDNO,c.CASE_IDNO,
                                                          ISNULL(MAX(r.Receipt_DATE), @Ld_Low_DATE) AS ReceiptLast_DATE,
                                                          SUM(CASE
                                                               WHEN (r.ToDistribute_AMNT > 0
                                                                     AND r.Receipt_DATE >= DATEADD(D, -30, @Ad_Run_DATE))
                                                                THEN r.ToDistribute_AMNT
                                                               ELSE 0
                                                              END) AS TotToDistributeMtd_AMNT,
                                                          MAX(CAST(CASE
                                                                    WHEN r.ToDistribute_AMNT > 0
                                                                     THEN r.Distribute_DATE
                                                                    ELSE @Ld_Low_DATE
                                                                   END AS DATETIME2)) AS DistributeLast_DATE
                                                     FROM RCTH_VALID_TAB AS r, LSUP_Y1 c, CMEM_Y1 AS cm
                                                    WHERE r.SourceReceipt_CODE NOT IN (@Lc_ReceiptSrcAc_CODE, @Lc_ReceiptSrcAn_CODE)
                                                            AND r.Receipt_AMNT > 0   
															AND cm.MemberMci_IDNO = r.PayorMCI_IDNO 
															AND cm.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT,@Lc_RelationshipCasePutFather_TEXT)
															AND cm.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
															AND cm.Case_IDNO = c.Case_IDNO
															AND r.Batch_DATE = c.Batch_DATE
															AND r.SourceBatch_CODE = c.SourceBatch_CODE
															AND r.Batch_NUMB = c.Batch_NUMB
															AND r.SeqReceipt_NUMB = c.SeqReceipt_NUMB
															AND c.Batch_DATE != @Ld_Low_DATE
															AND r.Distribute_DATE != @Ld_Low_DATE
															AND c.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE                                                 
                                                    GROUP BY r.PayorMCI_IDNO,c.CASE_IDNO) AS rc
                                   ON  cm.MemberMci_IDNO = rc.PayorMCI_IDNO
                                   AND cm.CASE_IDNO = rc.CASE_IDNO
                                  LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                                          fci.PayorMCI_IDNO,
                                                          fci.SeqReceipt_NUMB,
                                                          fci.Receipt_DATE AS LastRegIden_DATE,
                                                          fci.Source_CODE,
                                                          fci.ToDistribute_AMNT,
                                                          fci.PaymentYtd_AMNT,
                                                          fci.TotMtdColl_AMNT
                                                     FROM (SELECT a.Case_IDNO,
                                                                  a.PayorMCI_IDNO,
                                                                  a.SeqReceipt_NUMB,
                                                                  a.Receipt_DATE,
                                                                  CASE
                                                                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcAdminretirement_CODE, @Lc_ReceiptSrcAdminsalary_CODE, @Lc_ReceiptSrcAdminvendorpymt_CODE)
                                                                    THEN @Lc_SourceT1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcBond_CODE
                                                                    THEN @Lc_SourceB1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcDisabilityinsur_CODE
                                                                    THEN @Lc_SourceI1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcEmployerwage_CODE
                                                                    THEN @Lc_SourceW1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcInterstativdreg_CODE
                                                                    THEN @Lc_SourceF1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcInterstativdfee_CODE
                                                                    THEN @Lc_SourceE1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcSpecialCollection_CODE
                                                                    THEN @Lc_SourceT1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcJudgment_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCheck_CODE, @Lc_RemitTypeCashierscheck_CODE, @Lc_RemitTypeForeigncurrency_CODE)
                                                                    THEN @Lc_SourceK1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcJudgment_CODE
                                                                        AND a.TypeRemittance_CODE = @Lc_RemitTypeMoneyorder_CODE
                                                                    THEN @Lc_SourceM1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcJudgment_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCash_CODE, @Lc_RemitTypeCountycash_CODE)
                                                                    THEN @Lc_SourceC1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcJudgment_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCreditcard_CODE, @Lc_RemitTypeEft_CODE)
                                                                    THEN @Lc_SourceG1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcLevyFidm_CODE
                                                                    THEN @Lc_SourceV1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcLottery_CODE
                                                                        AND a.TypeRemittance_CODE = @Lc_RemitTypeCheck_CODE
                                                                    THEN @Lc_SourceK1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcReleaseAmount_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCheck_CODE, @Lc_RemitTypeCashierscheck_CODE, @Lc_RemitTypeForeigncurrency_CODE)
                                                                    THEN @Lc_SourceK1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcReleaseAmount_CODE
                                                                        AND a.TypeRemittance_CODE = @Lc_RemitTypeMoneyorder_CODE
                                                                    THEN @Lc_SourceM1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcReleaseAmount_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCash_CODE, @Lc_RemitTypeCountycash_CODE)
                                                                    THEN @Lc_SourceC1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcReleaseAmount_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCreditcard_CODE, @Lc_RemitTypeEft_CODE)
                                                                    THEN @Lc_SourceG1_CODE
                                                                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcCentralpayroll_CODE, @Lc_ReceiptSrcQdro_CODE)
                                                                    THEN @Lc_SourceW1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcRegularPayment_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCheck_CODE, @Lc_RemitTypeCashierscheck_CODE, @Lc_RemitTypeForeigncurrency_CODE)
                                                                    THEN @Lc_SourceK1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcRegularPayment_CODE
                                                                        AND a.TypeRemittance_CODE = @Lc_RemitTypeMoneyorder_CODE
                                                                    THEN @Lc_SourceM1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcRegularPayment_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCash_CODE, @Lc_RemitTypeCountycash_CODE)
                                                                    THEN @Lc_SourceC1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcRegularPayment_CODE
                                                                        AND a.TypeRemittance_CODE IN (@Lc_RemitTypeCreditcard_CODE, @Lc_RemitTypeEft_CODE)
                                                                    THEN @Lc_SourceG1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcHomesteadRebate_CODE
                                                                    THEN @Lc_SourceH1_CODE
                                                                   WHEN a.SourceReceipt_CODE IN (@Lc_ReceiptSrcSaverRebate_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE)
                                                                    THEN @Lc_SourceS1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcUib_CODE
                                                                    THEN @Lc_SourceU1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcVoluntary_CODE
                                                                    THEN @Lc_SourceN1_CODE
                                                                   WHEN a.SourceReceipt_CODE = @Lc_ReceiptSrcCsln_CODE
                                                                    THEN @Lc_SourceI1_CODE
                                                                   ELSE @Lc_Space_TEXT
                                                                  END AS Source_CODE,
                                                                  a.ToDistribute_AMNT,
                                                                  SUM(CASE
                                                                       WHEN a.Receipt_DATE BETWEEN @Ld_CurrentYearSt_DATE AND @Ld_CurrentYearEnd_DATE
                                                                        THEN ISNULL(a.ToDistribute_AMNT, 0)
                                                                       ELSE 0
                                                                      END) OVER(PARTITION BY a.Case_IDNO, a.PayorMCI_IDNO) AS PaymentYtd_AMNT,
                                                                  SUM(CASE
                                                                       WHEN a.Receipt_DATE BETWEEN @Ld_CurrentMonthSt_DATE AND @Ld_CurrentMonthEnd_DATE
                                                                        THEN ISNULL(a.ToDistribute_AMNT, 0)
                                                                       ELSE 0
                                                                      END) OVER(PARTITION BY a.Case_IDNO, a.PayorMCI_IDNO) AS TotMtdColl_AMNT,
                                                                  ROW_NUMBER() OVER(PARTITION BY a.PayorMCI_IDNO ORDER BY a.EventGlobalBeginSeq_NUMB DESC, a.Receipt_DATE DESC, a.SeqReceipt_NUMB DESC) AS rnm
                                                             FROM RCTH_VALID_TAB AS a  WITH (INDEX(0))
                                                            WHERE a.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                                                              AND a.SourceReceipt_CODE NOT IN (@Lc_ReceiptSrcAc_CODE, @Lc_ReceiptSrcAn_CODE)) AS fci                                                              
                                                    WHERE fci.rnm = 1) AS ir
                                   ON cm.MemberMci_IDNO = ir.PayorMCI_IDNO
                                  LEFT OUTER JOIN mdet_tab AS md
                                   ON cm.MemberMci_IDNO = md.MemberMci_IDNO
                                  LEFT OUTER JOIN plic_tab AS pl
                                   ON cm.MemberMci_IDNO = pl.MemberMci_IDNO
                                  LEFT OUTER JOIN mem_ins_tab AS mi
                                   ON cm.MemberMci_IDNO = mi.MemberMci_IDNO,
                                  DEMO_Y1 AS dm
                            WHERE cm.MemberMci_IDNO = dm.MemberMci_IDNO) AS ncp
           ON C.Case_IDNO = ncp.Case_IDNO
          LEFT OUTER JOIN (SELECT cm.Case_IDNO,
                                  cm.MemberMci_IDNO,
                                  cm.CaseRelationship_CODE,
                                  cm.CaseMemberStatus_CODE,
                                  ns.MemberSsn_NUMB,
                                  ns.TypePrimary_CODE,
                                  ns.Enumeration_CODE,
                                  dm.Deceased_DATE,
                                  dm.Last_NAME,
                                  dm.First_NAME,
                                  dm.Middle_NAME,
                                  dm.Suffix_NAME,
                                  dm.Birth_DATE,
                                  dm.MeansTestedInc_INDC,
                                  na.Line1_ADDR,
                                  na.Line2_ADDR,
                                  na.City_ADDR,
                                  na.State_ADDR,
                                  na.Zip_ADDR,
                                  na.Country_ADDR,
                                  0 Phone_NUMB,
                                  na.Status_CODE,
                                  na.NcpInstateResidence_INDC AS CpInStateResidence_INDC,
                                  na.AddrExists_INDC,
                                  pl.DrLicenseExist_INDC,
                                  mi.Status_CODE AS InsuranceExistsCp_INDC
                             FROM cmem_cp_tab AS cm
                                  LEFT OUTER JOIN ssn_tab AS ns
                                   ON cm.MemberMci_IDNO = ns.MemberMci_IDNO
                                  LEFT OUTER JOIN ahis_tab AS na
                                   ON cm.MemberMci_IDNO = na.MemberMci_IDNO
                                  LEFT OUTER JOIN mem_ins_tab AS mi
                                   ON cm.MemberMci_IDNO = mi.MemberMci_IDNO
                                  LEFT OUTER JOIN plic_tab AS pl
                                   ON cm.MemberMci_IDNO = pl.MemberMci_IDNO,
                                  DEMO_Y1 AS dm
                            WHERE cm.MemberMci_IDNO = dm.MemberMci_IDNO) AS cp
           ON C.Case_IDNO = cp.Case_IDNO
          LEFT OUTER JOIN (SELECT n.Case_IDNO,
                                  MAX(CAST(CASE
                                            WHEN n.ActivityMinor_CODE = @Lc_MinorActivityEmancipation_CODE
                                             THEN n.Entered_DATE
                                            ELSE @Ld_Low_DATE
                                           END AS DATETIME2)) AS MinorEmani_DATE,
                                  MAX(CAST(CASE
                                            WHEN n.ActivityMinor_CODE = @Lc_MinorActivityIrsci_CODE
                                             THEN n.Entered_DATE
                                            ELSE @Ld_Low_DATE
                                           END AS DATETIME2)) AS MinorIrsci_DATE,
                                  MAX(CAST(CASE
                                            WHEN n.ActivityMinor_CODE = @Lc_MinorActivityDelqn_CODE
                                             THEN n.Entered_DATE
                                            ELSE @Ld_Low_DATE
                                           END AS DATETIME2)) AS MinorDelqn_DATE
                             FROM DMNR_Y1 AS n WITH (INDEX(0))
                            GROUP BY n.Case_IDNO) AS mnr
           ON C.Case_IDNO = mnr.Case_IDNO
          LEFT OUTER JOIN (SELECT d.Case_IDNO,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS ArenExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS CrptExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorCsln_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS CslnExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS FidmExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS ImiwExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorLint_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS LintExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorQdro_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS QdroExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorLsnr_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS LsnrExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorNmsn_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS NmsnExempt_INDC,
                                  MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorPsoc_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS PsocExempt_INDC,                                      
                                    MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorCrim_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS CrimExempt_INDC,   
                                   MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorLien_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS LienExempt_INDC,                                     
									MAX(CASE
                                       WHEN d.ActivityMajor_CODE = @Lc_ActivityMajorSeqo_CODE
                                            AND d.Status_CODE = @Lc_RemedyStatusExempt_CODE
                                            AND d.BeginExempt_DATE != @Ld_Low_DATE
                                            AND @Ad_Run_DATE BETWEEN d.BeginExempt_DATE AND d.EndExempt_DATE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS SeqoExempt_INDC,   
                                  MAX(CASE
                                       WHEN d.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            AND d.ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS CrptStrt_INDC,
                                  MAX(CASE
                                       WHEN d.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            AND d.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS CcloStrt_INDC,
                                  MAX(CASE
                                       WHEN d.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            AND d.ActivityMajor_CODE = @Lc_ActivityMajorLint_CODE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS LintStrt_INDC,
                                  MAX(CASE
                                       WHEN d.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            AND d.ActivityMajor_CODE = @Lc_ActivityMajorOgco_CODE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS OgcoStrt_INDC,
                                  MAX(CASE
                                       WHEN d.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            AND d.ActivityMajor_CODE = @Lc_ActivityMajorPsoc_CODE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS PsocStrt_INDC,
                                  MAX(CASE
                                       WHEN d.Status_CODE = @Lc_RemedyStatusStart_CODE
                                            AND d.ActivityMajor_CODE = @Lc_ActivityMajorRevw_CODE
                                        THEN @Lc_Yes_INDC
                                       ELSE @Lc_No_INDC
                                      END) AS RevwStrt_INDC
                             FROM DMJR_Y1 AS d WITH (INDEX(0))
                            GROUP BY d.Case_IDNO) AS mjr
           ON C.Case_IDNO = mjr.Case_IDNO
          LEFT OUTER JOIN (SELECT a.Case_IDNO,
                                  a.CaseWelfare_IDNO,
                                  a.MultiIva_INDC,
                                  a.DefraPrevMonth_AMNT
                             FROM (SELECT b.Case_IDNO,
                                          b.CaseWelfare_IDNO,
                                          CASE
                                           WHEN b.Count_QNTY > 1
                                            THEN @Lc_Yes_INDC
                                           ELSE @Lc_No_INDC
                                          END AS MultiIva_INDC,
                                          a.DefraPrevMonth_AMNT,
                                          b.rnm
                                     FROM (SELECT m.CaseWelfare_IDNO,
                                                  m.Case_IDNO,
                                                  COUNT (m.CaseWelfare_IDNO) OVER (PARTITION BY m.Case_IDNO) Count_QNTY,
                                                  ROW_NUMBER () OVER (PARTITION BY m.Case_IDNO ORDER BY m.Start_DATE DESC, m.CaseWelfare_IDNO DESC ) rnm
                                             FROM MHIS_Y1 AS m WITH (INDEX(0))
                                            WHERE @Ad_Run_DATE BETWEEN m.Start_DATE AND m.End_DATE
                                              AND m.CaseWelfare_IDNO != 0) AS b
                                          LEFT OUTER JOIN (SELECT a.CaseWelfare_IDNO,
                                                                  SUM(a.Defra_AMNT) AS DefraPrevMonth_AMNT
                                                             FROM IVMG_Y1 AS a
                                                            WHERE a.WelfareYearMonth_NUMB = @Ln_PrevWelfare_DTYM
                                                            GROUP BY a.CaseWelfare_IDNO) AS a
                                           ON b.CaseWelfare_IDNO = a.CaseWelfare_IDNO) AS a
                            WHERE a.rnm = 1) AS W
           ON C.Case_IDNO = W.Case_IDNO
          LEFT OUTER JOIN (SELECT a.Case_IDNO,
                                  b.Disburse_DATE AS CheckLastCp_DATE,
                                  b.Disburse_AMNT AS CheckLastCp_AMNT
                             FROM (SELECT a.Case_IDNO,
                                          a.CheckRecipient_ID,
                                          a.CheckRecipient_CODE,
                                          a.Disburse_DATE,
                                          a.DisburseSeq_NUMB,
                                          ROW_NUMBER() OVER(PARTITION BY a.Case_IDNO ORDER BY a.Disburse_DATE DESC, a.DisburseSeq_NUMB DESC, a.DisburseSubSeq_NUMB DESC) AS rnm
                                     FROM DSBL_Y1 AS a WITH (INDEX(0))
                                    WHERE a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
                                      AND a.TypeDisburse_CODE <> @Lc_DisbursementTypeRefund_CODE) AS a,
                                  DSBH_Y1 AS b WITH (INDEX(0))
                            WHERE a.rnm = 1
                              AND a.CheckRecipient_ID = b.CheckRecipient_ID
                              AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                              AND a.Disburse_DATE = b.Disburse_DATE
                              AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                              AND b.EndValidity_DATE = @Ld_High_DATE) AS d
           ON C.Case_IDNO = d.Case_IDNO
          LEFT OUTER JOIN (SELECT i.Case_IDNO,
                                  1 AS Interstate_QNTY
                             FROM ICAS_Y1 AS i WITH (INDEX(0)),
                                  (SELECT b.Case_IDNO,
                                          b.IVDOutOfStateFips_CODE
                                     FROM CSPR_Y1 AS b
                                    WHERE b.ExchangeMode_INDC = @Lc_ExchangeModePaper_TEXT
                                      AND b.StatusRequest_CODE = @Lc_ReqStatusSuccessSent_CODE
                                      AND b.Function_CODE = @Lc_FunctionEnforcement_CODE
                                      AND b.Action_CODE = @Lc_ActionRequest_CODE
                                      AND b.Reason_CODE IN (@Lc_FarRegfsomodenfstagy_CODE, @Lc_FarRegoffsomodenfobl_CODE, @Lc_FarRefsomodenfobligr_CODE, @Lc_FarRegfsoenfobligor_CODE,
                                                            @Lc_FarRegfsoenfobligee_CODE, @Lc_FarRegfsoenfstagency_CODE)
                                      AND b.EndValidity_DATE = @Ld_High_DATE
                                   UNION
                                   SELECT a.Case_IDNO,
                                          a.IVDOutOfStateFips_CODE
                                     FROM (SELECT b.Case_IDNO,
                                                  b.IVDOutOfStateFips_CODE,
                                                  b.IoDirection_CODE,
                                                  b.Function_CODE,
                                                  b.Action_CODE,
                                                  b.Reason_CODE,
                                                  b.Transaction_DATE,
                                                  ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO, b.IVDOutOfStateFips_CODE, b.IoDirection_CODE, b.Function_CODE, b.Action_CODE, b.Reason_CODE ORDER BY b.Transaction_DATE DESC) AS rnm
                                             FROM CTHB_Y1 AS b
                                            WHERE b.IoDirection_CODE = @Lc_InterstateDirectionOutput_TEXT
                                              AND b.Function_CODE = @Lc_FunctionEnforcement_CODE
                                              AND b.Action_CODE = @Lc_ActionRequest_CODE
                                              AND b.Reason_CODE IN (@Lc_FarRegfsomodenfstagy_CODE, @Lc_FarRegoffsomodenfobl_CODE, @Lc_FarRefsomodenfobligr_CODE, @Lc_FarRegfsoenfobligor_CODE,
                                                                    @Lc_FarRegfsoenfobligee_CODE, @Lc_FarRegfsoenfstagency_CODE)) AS a
                                    WHERE a.rnm = 1
                                      AND a.Transaction_DATE >= ISNULL((SELECT MAX(h.Transaction_DATE)
                                                                          FROM CTHB_Y1 AS h
                                                                         WHERE h.Case_IDNO = a.Case_IDNO
                                                                           AND h.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE
                                                                           AND h.IoDirection_CODE = @Lc_InterstateDirectionInput_TEXT
                                                                           AND h.Function_CODE = @Lc_FunctionEnforcement_CODE
                                                                           AND h.Action_CODE = @Lc_ActionAcknowledgment_CODE
                                                                           AND h.Reason_CODE = @Lc_ReasonAnoad_CODE), @Ld_Low_DATE)) AS c
                            WHERE c.Case_IDNO = i.Case_IDNO
                              AND c.IVDOutOfStateFips_CODE = i.IVDOutOfStateFips_CODE
                              AND i.RespondInit_CODE = @Lc_RespondInitInitiate_TEXT
                              AND i.Status_CODE = @Lc_CaseStatusOpen_CODE
                              AND i.EndValidity_DATE = @Ld_High_DATE
                            GROUP BY i.Case_IDNO) AS i
           ON C.Case_IDNO = i.Case_IDNO
          LEFT OUTER JOIN (SELECT i.Case_IDNO,
                                  @Lc_Yes_INDC AS InterstateEligibleRevw_INDC
                             FROM ICAS_Y1 AS i WITH (INDEX(0)),
                                  (SELECT b.Case_IDNO,
                                          b.IVDOutOfStateFips_CODE
                                     FROM CSPR_Y1 AS b
                                    WHERE b.ExchangeMode_INDC = @Lc_ExchangeModePaper_TEXT
                                      AND b.StatusRequest_CODE = @Lc_ReqStatusSuccessSent_CODE
                                      AND b.Function_CODE = @Lc_FunctionEnforcement_CODE
                                      AND b.Action_CODE = @Lc_ActionRequest_CODE
                                      AND b.Reason_CODE IN (@Lc_FarRegfsoenfobligor_CODE, @Lc_FarRegfsoenfobligee_CODE, @Lc_FarRegfsoenfstagency_CODE)
                                      AND b.EndValidity_DATE = @Ld_High_DATE
                                   UNION
                                   SELECT a.Case_IDNO,
                                          a.IVDOutOfStateFips_CODE
                                     FROM (SELECT b.Case_IDNO,
                                                  b.IVDOutOfStateFips_CODE,
                                                  b.IoDirection_CODE,
                                                  b.Function_CODE,
                                                  b.Action_CODE,
                                                  b.Reason_CODE,
                                                  b.Transaction_DATE,
                                                  ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO, b.IVDOutOfStateFips_CODE, b.IoDirection_CODE, b.Function_CODE, b.Action_CODE, b.Reason_CODE ORDER BY b.Transaction_DATE DESC) AS rnm
                                             FROM CTHB_Y1 AS b
                                            WHERE b.IoDirection_CODE = @Lc_InterstateDirectionInput_TEXT
                                              AND b.Function_CODE = @Lc_FunctionEnforcement_CODE
                                              AND b.Action_CODE = @Lc_ActionRequest_CODE
                                              AND b.Reason_CODE NOT IN (@Lc_FarRegfsoenfobligor_CODE, @Lc_FarRegfsoenfobligee_CODE, @Lc_FarRegfsoenfstagency_CODE)) AS a
                                    WHERE a.rnm = 1) AS c
                            WHERE c.Case_IDNO = i.Case_IDNO
                              AND c.IVDOutOfStateFips_CODE = i.IVDOutOfStateFips_CODE
                              AND i.Status_CODE = @Lc_CaseStatusOpen_CODE
                              AND i.RespondInit_CODE = @Lc_RespondInitResponding_TEXT
                              AND i.EndValidity_DATE = @Ld_High_DATE
                              AND @Ad_Run_DATE BETWEEN i.Effective_DATE AND i.End_DATE
                            GROUP BY i.Case_IDNO) AS i2
           ON C.Case_IDNO = i2.Case_IDNO          
          LEFT OUTER JOIN (SELECT fci.Case_IDNO,
                                  ISNULL(MAX(LastRegularPaymentReceived_DATE), @Ld_Low_DATE) AS LastRegularPaymentReceived_DATE,
                                  SUM(fci.Lsup_PaymentLastReceived_AMNT) AS Lsup_PaymentLastReceived_AMNT
                             FROM (SELECT cm.Case_IDNO,
										  c.Batch_DATE,
										  MAX(c.Batch_DATE) OVER(PARTITION BY c.Case_IDNO)  AS MAXBatch_DATE, 
                                          ISNULL((CASE
                                                   WHEN cm.CaseRelationship_CODE = @Lc_RelationshipCaseNcp_TEXT
                                                    THEN (c.TransactionNaa_AMNT + c.TransactionPaa_AMNT + c.TransactionTaa_AMNT + c. TransactionCaa_AMNT + c.TransactionUpa_AMNT + c.TransactionUda_AMNT + c.TransactionIvef_AMNT + c.TransactionNffc_AMNT + c.TransactionNonIvd_AMNT + c.TransactionMedi_AMNT)
                                                  END), 0) AS Lsup_PaymentLastReceived_AMNT,
                                          ROW_NUMBER() OVER(PARTITION BY c.Case_IDNO,c.ObligationSeq_NUMB ORDER BY r.Batch_DATE DESC, r.Batch_NUMB DESC, r.SeqReceipt_NUMB DESC, c.EventGlobalSeq_NUMB DESC,cm.Case_IDNO, r.SourceBatch_CODE) AS RowNum,
                                          MAX(ISNULL((CASE
                                                       WHEN r.SourceReceipt_CODE IN ('CD', --DIRECT PAYMENT CREDIT
                                                                                     'DB', --DISABILITY INSURANCE
                                                                                     'EW', --EMPLOYER WAGE
                                                                                     'RE', --REGULAR PAYMENT FROM NCP
                                                                                     'UC', --UNEMPLOYMENT COMPENSATION (UIB)
                                                                                     'VN', -- VOLUNTARY
                                                                                     'LS'--LUMP SUM
                                                                                    )
                                                            AND cm.MemberMci_IDNO = r.PayorMCI_IDNO
                                                        THEN c.Distribute_DATE
                                                      END), @Ld_Low_DATE)) OVER (PARTITION BY cm.Case_IDNO) LastRegularPaymentReceived_DATE
                                     FROM RCTH_VALID_TAB AS r,
                                          cmem_ncp_tab AS cm,
                                          LSUP_y1 AS c
                                    WHERE (r.Case_IDNO = cm.Case_IDNO
                                            OR PayorMCI_IDNO = cm.Membermci_idno)
                                      AND r.Batch_DATE = c.Batch_DATE
                                      AND r.SourceBatch_CODE = c.SourceBatch_CODE
                                      AND r.Batch_NUMB = c.Batch_NUMB
                                      AND r.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                                      AND cm.Case_IDNO = c.Case_IDNO
                                      AND c.Batch_DATE != @Ld_Low_DATE
                                      AND r.Distribute_DATE != @Ld_Low_DATE
                                      AND c.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE) fci
                            WHERE RowNum = 1
                            AND Batch_DATE = MAXBatch_DATE
                            GROUP BY fci.Case_IDNO) rk
           ON C.Case_IDNO = rk.Case_IDNO

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
   SET @As_Error_DESC = @Lc_Space_TEXT
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + @As_Error_DESC + '. Error EXECUTE Location - ' + @As_Sql_TEXT + '. Error List KEY - ' + @As_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_Error_DESC=@Ls_Err_Description_TEXT;
  END CATCH;
 END



GO
