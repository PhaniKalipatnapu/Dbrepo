/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_VALIDATE_IFMS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_VALIDATE_IFMS
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_VALIDATE_IFMS is 
					  to validate the eligiblity of members/cases
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_VALIDATE_IFMS] (
 @As_RestartKey_TEXT       VARCHAR(200),
 @An_TaxYear_NUMB          NUMERIC(4),
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Arrear25_AMNT         NUMERIC(2) = 25,
          @Ln_45Days_NUMB           NUMERIC(2) = 45,
          @Ln_Arrear150_AMNT        NUMERIC(3) = 150,
          @Ln_Arrear500_AMNT        NUMERIC(3) = 500,
          @Ln_Arrear2500_AMNT       NUMERIC(4) = 2500,
          @Lc_Spce_TEXT             CHAR(1) = ' ',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_Success_CODE          CHAR(1) = 'S',
          @Lc_SysExclusion_CODE     CHAR(1) = 'S',
          @Lc_Yes_TEXT              CHAR(1) = 'Y',
          @Lc_No_TEXT               CHAR(1) = 'N',
          @Lc_CaseTypeA_CODE        CHAR(1) = 'A',
          @Lc_CaseTypeN_CODE        CHAR(1) = 'N',
          @Lc_ArrearTypeA_CODE      CHAR(1) = 'A',
          @Lc_ArrearTypeN_CODE      CHAR(1) = 'N',
          @Lc_TypeTranscI_CODE      CHAR(1) = 'I',
          @Lc_TypeTranscU_CODE      CHAR(1) = 'U',
          @Lc_TypeTranscD_CODE      CHAR(1) = 'D',
          @Lc_TypeTranscX_CODE      CHAR(1) = 'X',
          @Lc_CurrentActnU_CODE     CHAR(1) = 'U',
          @Lc_CurrentActnI_CODE     CHAR(1) = 'I',
          @Lc_AliasTypeT_CODE       CHAR(1) = 'T',
          @Lc_Ascii45_CODE          CHAR(2) = '45',
          @Lc_Ascii65_CODE          CHAR(2) = '65',
          @Lc_Ascii90_CODE          CHAR(2) = '90',
          @Lc_TypeBankruptcy_CODE   CHAR(2) = '13',
          @Lc_PreEditCS_CODE        CHAR(2) = 'CS',
          @Lc_PreEditAR_CODE        CHAR(2) = 'AR',
          @Lc_PreEditSN_CODE        CHAR(2) = 'SN',
          @Lc_PreEditMN_CODE        CHAR(2) = 'MN',
          @Lc_PreEditLN_CODE        CHAR(2) = 'LN',
          @Lc_PreEditFN_CODE        CHAR(2) = 'FN',
          @Lc_Reject38_CODE         CHAR(2) = '38',
          @Lc_Reject39_CODE         CHAR(2) = '39',
          @Lc_Reject19_CODE         CHAR(2) = '19',
          @Lc_Reject17_CODE         CHAR(2) = '17',
          @Lc_Reject12_CODE         CHAR(2) = '12',
          @Lc_Reject06_CODE         CHAR(2) = '06',
          @Lc_Reject08_CODE         CHAR(2) = '08',
          @Lc_SourceBatchSPC_CODE   CHAR(3) = 'SPC',
          @Lc_StatusSTRT_CODE       CHAR(4) = 'STRT',
          @Lc_StatusEXMT_CODE       CHAR(4) = 'EXMT',
          @Lc_ActiveMjrCCLO_CODE    CHAR(4) = 'CCLO',
          @Lc_ActiveMjrCSLN_CODE    CHAR(4) = 'CSLN',
          @Lc_RestartKeyVal1_CODE   CHAR(5) = 'VAL1',
          @Lc_RestartKeyVal1A_CODE  CHAR(5) = 'VAL1A',
          @Lc_RestartKeyVal1B_CODE  CHAR(5) = 'VAL1B',
          @Lc_RestartKeyVal2_CODE   CHAR(5) = 'VAL2',
          @Lc_RestartKeyVal3_CODE   CHAR(5) = 'VAL3',
          @Lc_RestartKeyVal4_CODE   CHAR(5) = 'VAL4',
          @Lc_RestartKeyVal5_CODE   CHAR(5) = 'VAL5',
          @Lc_RestartKeyVal6_CODE   CHAR(5) = 'VAL6',
          @Lc_RestartKeyVal7_CODE   CHAR(5) = 'VAL7',
          @Lc_RestartKeyVal8_CODE   CHAR(5) = 'VAL8',
          @Lc_RestartKeyVal9_CODE   CHAR(5) = 'VAL9',
          @Lc_RestartKeyVal10_CODE  CHAR(5) = 'VAL10',
          @Lc_RestartKeyVal11_CODE  CHAR(5) = 'VAL11',
          --@Lc_RestartKeyVal14_CODE  CHAR(5) = 'VAL14',
          --@Lc_RestartKeyVal15_CODE  CHAR(5) = 'VAL15',
          --@Lc_RestartKeyVal16_CODE  CHAR(5) = 'VAL16',
          --@Lc_RestartKeyVal18_CODE  CHAR(5) = 'VAL18',
          --@Lc_RestartKeyVal19_CODE  CHAR(5) = 'VAL19',
          --@Lc_RestartKeyVal20_CODE  CHAR(5) = 'VAL20',
          @Lc_RestartKeyVal21_CODE  CHAR(5) = 'VAL21',
          --@Lc_RestartKeyVal22_CODE  CHAR(5) = 'VAL22',
          --@Lc_RestartKeyVal23_CODE  CHAR(5) = 'VAL23',
          @Lc_RestartKeyVal24_CODE  CHAR(5) = 'VAL24',
          @Lc_RestartKeyVal25_CODE  CHAR(5) = 'VAL25',
          @Lc_RestartKeyVal26_CODE  CHAR(5) = 'VAL26',
          @Lc_RestartKeyVal27_CODE  CHAR(5) = 'VAL27',
          @Lc_RestartKeyVal28_CODE  CHAR(5) = 'VAL28',
          @Lc_RestartKeyVal29_CODE  CHAR(5) = 'VAL29',
          --@Lc_RestartKeyVal30_CODE  CHAR(5) = 'VAL30',
          --@Lc_RestartKeyVal31_CODE  CHAR(5) = 'VAL31',
          --@Lc_RestartKeyVal32_CODE  CHAR(5) = 'VAL32',
          --@Lc_RestartKeyVal33_CODE  CHAR(5) = 'VAL33',
          --@Lc_RestartKeyVal34_CODE  CHAR(5) = 'VAL34',
          --@Lc_RestartKeyVal35_CODE  CHAR(5) = 'VAL35',
          --@Lc_RestartKeyVal36_CODE  CHAR(5) = 'VAL36',
          --@Lc_RestartKeyVal37_CODE  CHAR(5) = 'VAL37',
          --@Lc_RestartKeyVal38_CODE  CHAR(5) = 'VAL38',
          --@Lc_RestartKeyVal39_CODE  CHAR(5) = 'VAL39',
          --@Lc_RestartKeyVal40_CODE  CHAR(5) = 'VAL40',
          --@Lc_RestartKeyVal41_CODE  CHAR(5) = 'VAL41',
          @Lc_RestartKeyValEnd_CODE CHAR(6) = 'VALEND',
          @Lc_Job_ID                CHAR(7) = @Ac_Job_ID,
          @Lc_BatchRunUser_TEXT     CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME        VARCHAR(100) = 'SP_VALIDATE_IFMS',
          @Ld_High_DATE             DATE = '12/31/9999',
          @Ld_Low_DATE              DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                NUMERIC(1) = 0,
          @Ln_TaxYear_NUMB             NUMERIC(4) = @An_TaxYear_NUMB,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_Count_QNTY               NUMERIC(19) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY         SMALLINT,
          @Lc_Msg_CODE                 CHAR(5) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(200),
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ls_Sql_TEXT                 VARCHAR(4000),
          @Ls_Sqldata_TEXT             VARCHAR(4000),
          @Ld_Run_DATE                 DATE,
          @Ld_Create_DATE              DATETIME2;
  DECLARE @Ln_RjdtRejectCur_MemberMci_IDNO       NUMERIC(10),
          @Lc_RjdtRejectCur_TypeArrear_CODE      CHAR(1),
          @Lc_RjdtRejectCur_TransactionType_CODE CHAR(1);

  BEGIN TRY
   SET @Ld_Run_DATE = @Ad_Run_DATE;
   SET @Lc_Job_ID = @Ac_Job_ID;
   SET @Ld_Create_DATE = ISNULL(@Ld_Create_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

   IF @As_RestartKey_TEXT = @Lc_RestartKeyVal1_CODE
    BEGIN
     GOTO VAL1;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal1A_CODE
    BEGIN
     GOTO VAL1A;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal1B_CODE
    BEGIN
     GOTO VAL1B;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal2_CODE
    BEGIN
     GOTO VAL2;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal3_CODE
    BEGIN
     GOTO VAL3;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal4_CODE
    BEGIN
     GOTO VAL4;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal5_CODE
    BEGIN
     GOTO VAL5;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal6_CODE
    BEGIN
     GOTO VAL6;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal7_CODE
    BEGIN
     GOTO VAL7;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal8_CODE
    BEGIN
     GOTO VAL8;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal9_CODE
    BEGIN
     GOTO VAL9;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal10_CODE
    BEGIN
     GOTO VAL10;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal11_CODE
    BEGIN
     GOTO VAL11;
    END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal14_CODE
   -- BEGIN
   --  GOTO VAL14;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal15_CODE
   -- BEGIN
   --  GOTO VAL15;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal16_CODE
   -- BEGIN
   --  GOTO VAL16;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal18_CODE
   -- BEGIN
   --  GOTO VAL18;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal19_CODE
   -- BEGIN
   --  GOTO VAL19;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal20_CODE
   -- BEGIN
   --  GOTO VAL20;
   -- END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal21_CODE
    BEGIN
     GOTO VAL21;
    END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal22_CODE
   -- BEGIN
   --  GOTO VAL22;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal23_CODE
   -- BEGIN
   --  GOTO VAL23;
   -- END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal24_CODE
    BEGIN
     GOTO VAL24;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal25_CODE
    BEGIN
     GOTO VAL25;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal26_CODE
    BEGIN
     GOTO VAL26;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal27_CODE
    BEGIN
     GOTO VAL27;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal28_CODE
    BEGIN
     GOTO VAL28;
    END
   ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal29_CODE
    BEGIN
     GOTO VAL29;
    END

   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal30_CODE
   -- BEGIN
   --  GOTO VAL30;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal31_CODE
   -- BEGIN
   --  GOTO VAL31;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal32_CODE
   -- BEGIN
   --  GOTO VAL32;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal33_CODE
   -- BEGIN
   --  GOTO VAL33;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal34_CODE
   -- BEGIN
   --  GOTO VAL34;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal35_CODE
   -- BEGIN
   --  GOTO VAL35;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal36_CODE
   -- BEGIN
   --  GOTO VAL36;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal37_CODE
   -- BEGIN
   --  GOTO VAL37;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal38_CODE
   -- BEGIN
   --  GOTO VAL38;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal39_CODE
   -- BEGIN
   --  GOTO VAL39;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal40_CODE
   -- BEGIN
   --  GOTO VAL40;
   -- END
   --ELSE IF @As_RestartKey_TEXT = @Lc_RestartKeyVal41_CODE
   -- BEGIN
   --  GOTO VAL41;
   -- END
   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal1A_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal1A_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL1A:;

   SET @Ls_Sql_TEXT = 'INSERT - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_CaseTypeA_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranscI_CODE, '') + ', Certified_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', StateAdministration_CODE = ' + ISNULL(@Lc_Spce_TEXT, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', Submit_INDC = ' + ISNULL(@Lc_Yes_TEXT, '') + ', CurrentAction_INDC = ' + ISNULL(@Lc_CurrentActnI_CODE, '');

   INSERT INTO PIFMS_Y1
               (MemberMci_IDNO,
                Case_IDNO,
                MemberSsn_NUMB,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                TaxYear_NUMB,
                TypeArrear_CODE,
                Transaction_AMNT,
                SubmitLast_DATE,
                TypeTransaction_CODE,
                CountySubmitted_IDNO,
                Certified_DATE,
                StateAdministration_CODE,
                ExcludeIrs_CODE,
                ExcludeAdm_CODE,
                ExcludeFin_CODE,
                ExcludePas_CODE,
                ExcludeRet_CODE,
                ExcludeSal_CODE,
                ExcludeDebt_CODE,
                ExcludeVen_CODE,
                ExcludeIns_CODE,
                Submit_INDC,
                CurrentAction_INDC)
   SELECT a.MemberMci_IDNO,
          a.Case_IDNO,
          a.MemberSsn_NUMB,
          b.Last_NAME,
          b.First_NAME,
          b.Middle_NAME,
          @An_TaxYear_NUMB AS TaxYear_NUMB,
          @Lc_CaseTypeA_CODE AS TypeArrear_CODE,
          FLOOR(a.TanfArrear_AMNT) AS Transaction_AMNT,
          @Ld_Run_DATE AS SubmitLast_DATE,
          @Lc_TypeTranscI_CODE AS TypeTransaction_CODE,
          a.County_IDNO AS CountySubmitted_IDNO,
          @Ld_Low_DATE AS Certified_DATE,
          @Lc_Spce_TEXT AS StateAdministration_CODE,
          @Lc_No_TEXT AS ExcludeIrs_CODE,
          @Lc_No_TEXT AS ExcludeAdm_CODE,
          @Lc_No_TEXT AS ExcludeFin_CODE,
          @Lc_No_TEXT AS ExcludePas_CODE,
          @Lc_No_TEXT AS ExcludeRet_CODE,
          @Lc_No_TEXT AS ExcludeSal_CODE,
          @Lc_SysExclusion_CODE AS ExcludeDebt_CODE,
          @Lc_No_TEXT AS ExcludeVen_CODE,
          @Lc_No_TEXT AS ExcludeIns_CODE,
          @Lc_Yes_TEXT AS Submit_INDC,
          @Lc_CurrentActnI_CODE AS CurrentAction_INDC
     FROM IRSA_Y1 a,
          DEMO_Y1 b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.PreEdit_CODE != @Lc_PreEditCS_CODE
AND NOT EXISTS(SELECT 1 FROM PIFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = @Ld_Run_DATE
AND X.TypeArrear_CODE = @Lc_CaseTypeA_CODE)      
    ORDER BY a.MemberMci_IDNO,
             a.Case_IDNO;

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal1B_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal1B_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL1B:;

   /*
      Inserting the Non-TANF Arrear into PIFMS_Y1 table from
     IRSA_Y1 table. The Exclusion Indicator values will be converted into
     'N' if it is 'S', so that the process will check the eligiblity for each exclusion.
      */
   SET @Ls_Sql_TEXT = 'INSERT - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_CaseTypeN_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranscI_CODE, '') + ', Certified_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', StateAdministration_CODE = ' + ISNULL(@Lc_Spce_TEXT, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', Submit_INDC = ' + ISNULL(@Lc_Yes_TEXT, '') + ', CurrentAction_INDC = ' + ISNULL(@Lc_CurrentActnI_CODE, '');

   INSERT INTO PIFMS_Y1
               (MemberMci_IDNO,
                Case_IDNO,
                MemberSsn_NUMB,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                TaxYear_NUMB,
                TypeArrear_CODE,
                Transaction_AMNT,
                SubmitLast_DATE,
                TypeTransaction_CODE,
                CountySubmitted_IDNO,
                Certified_DATE,
                StateAdministration_CODE,
                ExcludeIrs_CODE,
                ExcludeAdm_CODE,
                ExcludeFin_CODE,
                ExcludePas_CODE,
                ExcludeRet_CODE,
                ExcludeSal_CODE,
                ExcludeDebt_CODE,
                ExcludeVen_CODE,
                ExcludeIns_CODE,
                Submit_INDC,
                CurrentAction_INDC)
   SELECT a.MemberMci_IDNO,
          a.Case_IDNO,
          a.MemberSsn_NUMB,
          b.Last_NAME,
          b.First_NAME,
          b.Middle_NAME,
          @An_TaxYear_NUMB AS TaxYear_NUMB,
          @Lc_CaseTypeN_CODE AS TypeArrear_CODE,
          FLOOR(a.NonTanfArrear_AMNT) AS Transaction_AMNT,
          @Ld_Run_DATE AS SubmitLast_DATE,
          @Lc_TypeTranscI_CODE AS TypeTransaction_CODE,
          a.County_IDNO AS CountySubmitted_IDNO,
          @Ld_Low_DATE AS Certified_DATE,
          @Lc_Spce_TEXT AS StateAdministration_CODE,
          @Lc_No_TEXT AS ExcludeIrs_CODE,
          @Lc_No_TEXT AS ExcludeAdm_CODE,
          @Lc_No_TEXT AS ExcludeFin_CODE,
          @Lc_No_TEXT AS ExcludePas_CODE,
          @Lc_No_TEXT AS ExcludeRet_CODE,
          @Lc_No_TEXT AS ExcludeSal_CODE,
          @Lc_SysExclusion_CODE AS ExcludeDebt_CODE,
          @Lc_No_TEXT AS ExcludeVen_CODE,
          @Lc_No_TEXT AS ExcludeIns_CODE,
          @Lc_Yes_TEXT AS Submit_INDC,
          @Lc_CurrentActnI_CODE AS CurrentAction_INDC
     FROM IRSA_Y1 a,
          DEMO_Y1 b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.PreEdit_CODE != @Lc_PreEditCS_CODE
AND NOT EXISTS(SELECT 1 FROM PIFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = @Ld_Run_DATE
AND X.TypeArrear_CODE = @Lc_CaseTypeN_CODE)      
    ORDER BY a.MemberMci_IDNO,
             a.Case_IDNO;

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal1_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal1_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL1:;

   /*
    PIFMS_Y1 exclusions indications are updated IF any manual exclusions indecator set by TAXI screen
    TEXC_Y1 table
    */
   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   WITH TexcUpdate_Tab
        AS (SELECT a.Case_IDNO,
                   a.MemberMci_IDNO,
                   a.ExcludeIrs_INDC,
                   a.ExcludeAdm_INDC,
                   a.ExcludeIns_INDC,
                   a.ExcludeSal_INDC,
                   a.ExcludeRet_INDC,
                   a.ExcludeVen_INDC,
                   --a.ExcludeDebt_INDC,
                   a.ExcludeFin_INDC,
                   a.ExcludePas_INDC
              FROM TEXC_Y1 a
             WHERE EXISTS (SELECT 1
                             FROM PIFMS_Y1 b
                            WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                              AND b.Case_IDNO = a.Case_IDNO)
               AND @Ld_Run_DATE BETWEEN a.Effective_DATE AND a.End_DATE
               AND (a.ExcludeIrs_INDC != @Lc_No_TEXT
                     OR a.ExcludeAdm_INDC != @Lc_No_TEXT
                     OR a.ExcludeIns_INDC != @Lc_No_TEXT
                     OR a.ExcludeSal_INDC != @Lc_No_TEXT
                     OR a.ExcludeRet_INDC != @Lc_No_TEXT
                     OR a.ExcludeVen_INDC != @Lc_No_TEXT
                     --OR a.ExcludeDebt_INDC != @Lc_No_TEXT
                     OR a.ExcludeFin_INDC != @Lc_No_TEXT
                     OR a.ExcludePas_INDC != @Lc_No_TEXT)
               AND a.EndValidity_DATE = @Ld_High_DATE)
   UPDATE q
      SET q.ExcludeIrs_CODE = b.ExcludeIrs_INDC,
          q.ExcludeAdm_CODE = b.ExcludeAdm_INDC,
          q.ExcludeIns_CODE = b.ExcludeIns_INDC,
          q.ExcludeSal_CODE = b.ExcludeSal_INDC,
          q.ExcludeRet_CODE = b.ExcludeRet_INDC,
          q.ExcludeVen_CODE = b.ExcludeVen_INDC,
          --q.ExcludeDebt_CODE = b.ExcludeDebt_INDC,
          q.ExcludeFin_CODE = b.ExcludeFin_INDC,
          q.ExcludePas_CODE = b.ExcludePas_INDC
     FROM PIFMS_Y1 q,
          TexcUpdate_Tab b
    WHERE q.MemberMci_IDNO = b.MemberMci_IDNO
      AND q.Case_IDNO = b.Case_IDNO
      

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal2_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal2_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL2:;

   -- If DECSS received the reject code 19 or 38 then extract batch 
   -- should moniter the IRS receipts. If DECSS received the IRS receipts then following process 
   -- should change reject indicator.
   DECLARE RjdtReject_CUR INSENSITIVE CURSOR FOR
    SELECT MemberMci_IDNO,
           TypeArrear_CODE,
           TransactionType_CODE
      FROM RJDT_Y1 a
     WHERE Reject1_CODE IN (@Lc_Reject38_CODE, @Lc_Reject19_CODE)
       AND EndValidity_DATE = @Ld_High_DATE
       AND EXISTS (SELECT 1
                     FROM FEDH_Y1 c
                    WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                      AND c.TypeArrear_CODE = a.TypeArrear_CODE
                      AND c.RejectInd_INDC = @Lc_Yes_TEXT)
       AND EXISTS (SELECT 1
                     FROM RCTH_Y1 b
                    WHERE a.MemberMci_IDNO = b.PayorMCI_IDNO
                      AND a.TypeArrear_CODE = b.Tanf_CODE
                      AND SourceBatch_CODE = @Lc_SourceBatchSPC_CODE
                      AND EndValidity_DATE = @Ld_High_DATE
                      AND Receipt_DATE >= a.Rejected_DATE);

   OPEN RjdtReject_CUR;

   FETCH NEXT FROM RjdtReject_CUR INTO @Ln_RjdtRejectCur_MemberMci_IDNO, @Lc_RjdtRejectCur_TypeArrear_CODE, @Lc_RjdtRejectCur_TransactionType_CODE;

   SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;

   --loop through
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'MOVE - HFEDH';
     SET @Ls_Sqldata_TEXT = '';

     INSERT INTO HFEDH_Y1
                 (MemberMci_IDNO,
                  MemberSsn_NUMB,
                  TypeArrear_CODE,
                  TypeTransaction_CODE,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Line1_ADDR,
                  Line2_ADDR,
                  City_ADDR,
                  State_ADDR,
                  Zip_ADDR,
                  ArrearIdentifier_IDNO,
                  Arrear_AMNT,
                  SubmitLast_DATE,
                  ExcludePas_CODE,
                  ExcludeFin_CODE,
                  ExcludeIrs_CODE,
                  ExcludeAdm_CODE,
                  ExcludeRet_CODE,
                  ExcludeSal_CODE,
                  ExcludeDebt_CODE,
                  ExcludeVen_CODE,
                  ExcludeIns_CODE,
                  RejectInd_INDC,
                  CountyFips_CODE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  ReqPreOffset_CODE,
                  TaxYear_NUMB)
     SELECT h.MemberMci_IDNO,
            h.MemberSsn_NUMB,
            h.TypeArrear_CODE,
            h.TypeTransaction_CODE,
            h.Last_NAME,
            h.First_NAME,
            h.Middle_NAME,
            h.Line1_ADDR,
            h.Line2_ADDR,
            h.City_ADDR,
            h.State_ADDR,
            h.Zip_ADDR,
            h.ArrearIdentifier_IDNO,
            h.Arrear_AMNT,
            h.SubmitLast_DATE,
            h.ExcludePas_CODE,
            h.ExcludeFin_CODE,
            h.ExcludeIrs_CODE,
            h.ExcludeAdm_CODE,
            h.ExcludeRet_CODE,
            h.ExcludeSal_CODE,
            h.ExcludeDebt_CODE,
            h.ExcludeVen_CODE,
            h.ExcludeIns_CODE,
            h.RejectInd_INDC,
            h.CountyFips_CODE,
            h.BeginValidity_DATE,
            @Ld_Run_DATE,
            @Lc_BatchRunUser_TEXT,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
            h.TransactionEventSeq_NUMB,
            h.ReqPreOffset_CODE,
            h.TaxYear_NUMB
       FROM FEDH_Y1 h
      WHERE h.MemberMci_IDNO = @Ln_RjdtRejectCur_MemberMci_IDNO
        AND h.TypeTransaction_CODE = @Lc_RjdtRejectCur_TransactionType_CODE
        AND h.TypeArrear_CODE = @Lc_RjdtRejectCur_TypeArrear_CODE
AND NOT EXISTS(SELECT 1 FROM HFEDH_Y1 X
WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)

     -- Update the SORD_Y1 with the NEXT REVIEW date
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_TEXT, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_TEXT,
      @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE - VFEDH FOR 38 19';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_RjdtRejectCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_RjdtRejectCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_RjdtRejectCur_TransactionType_CODE, '');

     UPDATE A
        SET RejectInd_INDC = @Lc_No_TEXT,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
      FROM FEDH_Y1 A
     WHERE MemberMci_IDNO = @Ln_RjdtRejectCur_MemberMci_IDNO
        AND TypeArrear_CODE = @Lc_RjdtRejectCur_TypeArrear_CODE
        AND TypeTransaction_CODE = @Lc_RjdtRejectCur_TransactionType_CODE
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_RjdtRejectCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_RjdtRejectCur_TypeArrear_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ln_Count_QNTY = COUNT (1)
       FROM RJCS_Y1
      WHERE MemberMci_IDNO = @Ln_RjdtRejectCur_MemberMci_IDNO
        AND TypeArrear_CODE = @Lc_RjdtRejectCur_TypeArrear_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Count_QNTY >= 1
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE VRJCS';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_RjdtRejectCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_RjdtRejectCur_TypeArrear_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE a
          SET EndValidity_DATE = CAST(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS DATE),
              WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
              Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
         FROM RJCS_Y1 a
        WHERE MemberMci_IDNO = @Ln_RjdtRejectCur_MemberMci_IDNO
          AND TypeArrear_CODE = @Lc_RjdtRejectCur_TypeArrear_CODE
          AND EndValidity_DATE = @Ld_High_DATE
          
      END;

     SET @Ls_Sql_TEXT = 'UPDATE RJDT';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_RjdtRejectCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_RjdtRejectCur_TypeArrear_CODE, '') + ', TransactionType_CODE = ' + ISNULL(@Lc_RjdtRejectCur_TransactionType_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     UPDATE A
        SET EndValidity_DATE = CAST(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS DATE),
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
      FROM RJDT_Y1 A
     WHERE MemberMci_IDNO = @Ln_RjdtRejectCur_MemberMci_IDNO
        AND TypeArrear_CODE = @Lc_RjdtRejectCur_TypeArrear_CODE
        AND TransactionType_CODE = @Lc_RjdtRejectCur_TransactionType_CODE
        AND EndValidity_DATE = @Ld_High_DATE

     SET @Ls_Sql_TEXT = 'FETCH RjdtReject_CUR 2';

     FETCH NEXT FROM RjdtReject_CUR INTO @Ln_RjdtRejectCur_MemberMci_IDNO, @Lc_RjdtRejectCur_TypeArrear_CODE, @Lc_RjdtRejectCur_TransactionType_CODE;

     SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;
    END;

   CLOSE RjdtReject_CUR;

   DEALLOCATE RjdtReject_CUR;

   --reset the reject indc in fedh from y to n for records that are rejected with codes that are unhandled in irs batch
   SET @Ls_Sql_TEXT = 'PROCEDURE CALL - SP_AUTO_RESPONSE - 0';
   SET @Ls_Sqldata_TEXT = 'Error_CODE = ' + ISNULL(@Lc_Reject08_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE
    @Ac_Error_CODE            = @Lc_Reject08_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Sql_TEXT = @Ls_Sql_TEXT + ' - FAILED';

     RAISERROR (50001,16,1);
    END

   /*
      Updating the CD_Action column of Int_IFMS_Y1 table as 'U', if that Member, Case and
      Arrear Type exists in IFMS_Y1 with non-zero value. That is in last submission the process
      sent either Add, Mod or Replace. Otherwise the case should be considered as new for this current run.
      Updating the U trans compare with IFMS_Y1 case level not member level.
   */
   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   /*In case level table we need to store the arrear amount so we are putting the another one
   condition for transaction type is not equal delete (Reming records we consider as modification)
   */
   SET @Ls_Sqldata_TEXT = 'RejectInd_INDC = ' + ISNULL(@Lc_Yes_TEXT, '');

   UPDATE PIFMS_Y1
      SET TypeTransaction_CODE = @Lc_TypeTranscU_CODE,
          CurrentAction_INDC = @Lc_CurrentActnU_CODE
     FROM PIFMS_Y1 a,
          IFMS_Y1 b
    WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
      AND b.Case_IDNO = a.Case_IDNO
      AND b.TypeArrear_CODE = a.TypeArrear_CODE
      AND b.TypeTransaction_CODE != @Lc_TypeTranscD_CODE
      AND b.Transaction_AMNT > @Ln_Zero_NUMB
      -- Update Process records should exists with reject_ind as 'Y'		
      AND NOT EXISTS (SELECT 1
                        FROM FEDH_Y1 c
                       WHERE c.MemberMci_IDNO = b.MemberMci_IDNO
                         AND c.TypeArrear_CODE = b.TypeArrear_CODE
                         AND c.TaxYear_NUMB = b.TaxYear_NUMB
                         AND c.RejectInd_INDC = @Lc_Yes_TEXT)

   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranscI_CODE, '') + ', Iwn_INDC = ' + ISNULL(@Lc_Yes_TEXT, '');

   DELETE a
     FROM PIFMS_Y1 a,
          IRSA_Y1 b
    WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
      AND b.Case_IDNO = a.Case_IDNO
      AND a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND b.Iwn_INDC = @Lc_Yes_TEXT;

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal3_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal3_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL3:;

   -- Update  the TAX name If it's exists in AKAX table, selecting the latest tax name in VAKAX table.		
   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeAlias_CODE = ' + ISNULL(@Lc_AliasTypeT_CODE, '') + ', TypeAlias_CODE = ' + ISNULL(@Lc_AliasTypeT_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE d
      SET d.Last_NAME = a.LastAlias_NAME,
          d.First_NAME = a.FirstAlias_NAME,
          d.Middle_NAME = a.MiddleAlias_NAME
     FROM PIFMS_Y1 d,
          AKAX_Y1 a
    WHERE a.TypeAlias_CODE = @Lc_AliasTypeT_CODE
      AND d.MemberMci_IDNO = a.MemberMci_IDNO
      AND TransactionEventSeq_NUMB = (SELECT MAX (TransactionEventSeq_NUMB)
                                        FROM AKAX_Y1 c
                                       WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                         AND c.TypeAlias_CODE = @Lc_AliasTypeT_CODE
                                         AND c.EndValidity_DATE = @Ld_High_DATE)
      AND a.EndValidity_DATE = @Ld_High_DATE

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal4_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal4_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL4:;

   /*
   	Skip the cases if the combined arrears is less than or equal to 25
   	Here we are checking the case level Eligiblity for newly added case for new member or existing member
   */
   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   WITH UpdatePifms_Tab
        AS (SELECT a.MemberMci_IDNO
              FROM PIFMS_Y1 a,
                   IRSA_Y1 c
             WHERE a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND NOT EXISTS(SELECT 1
                                FROM PIFMS_Y1 b
                               WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND b.TypeTransaction_CODE = @Lc_TypeTranscU_CODE)
               AND a.MemberMci_IDNO = c.MemberMci_IDNO
             GROUP BY a.MemberMci_IDNO
            HAVING SUM (Transaction_AMNT) < @Ln_Arrear25_AMNT)
   UPDATE c
      SET c.PreEdit_CODE = @Lc_PreEditAR_CODE
     FROM IRSA_Y1 c,
          UpdatePifms_Tab b
    WHERE c.MemberMci_IDNO = b.MemberMci_IDNO

   SET @Ls_Sqldata_TEXT = '';

   WITH UpdatePifms_Tab
        AS (SELECT a.MemberMci_IDNO
              FROM PIFMS_Y1 a,
                   IRSA_Y1 c
             WHERE a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND NOT EXISTS (SELECT 1
                                 FROM PIFMS_Y1 b
                                WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                  AND b.TypeTransaction_CODE = @Lc_TypeTranscU_CODE)
               AND a.MemberMci_IDNO = c.MemberMci_IDNO
             GROUP BY a.MemberMci_IDNO
            HAVING SUM (Transaction_AMNT) < @Ln_Arrear25_AMNT)
   DELETE a
     FROM PIFMS_Y1 a,
          UpdatePifms_Tab b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO;

   /*
   	Total TANF arrears is less than &150 and NOT-TANF arrears is less than the $500 BEGIN insert the
   	Record into IRSA with Pre_Edit as 'AR' if the member having both TANF and NON-TANF cases.
   */
   SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE c
      SET c.PreEdit_CODE = @Lc_PreEditAR_CODE
     FROM IRSA_Y1 c,
          (SELECT MemberMci_IDNO
             FROM PIFMS_Y1 a
            WHERE a.TypeArrear_CODE = @Lc_ArrearTypeA_CODE
              AND a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
              AND a.ExcludeIrs_CODE = 'N'
              AND NOT EXISTS(SELECT 1
                               FROM PIFMS_Y1 b
                              WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                AND b.TypeTransaction_CODE = @Lc_TypeTranscU_CODE)
            GROUP BY a.MemberMci_IDNO
           HAVING SUM (a.Transaction_AMNT) < @Ln_Arrear150_AMNT) z,
          (SELECT MemberMci_IDNO
             FROM PIFMS_Y1 a
            WHERE a.TypeArrear_CODE = @Lc_ArrearTypeN_CODE
              AND a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
              AND a.ExcludeIrs_CODE = 'N'
              AND NOT EXISTS(SELECT 1
                               FROM PIFMS_Y1 b
                              WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                AND b.TypeTransaction_CODE = @Lc_TypeTranscU_CODE)
            GROUP BY a.MemberMci_IDNO
           HAVING SUM (a.Transaction_AMNT) < @Ln_Arrear500_AMNT) y
    WHERE z.MemberMci_IDNO = y.MemberMci_IDNO
      AND c.MemberMci_IDNO = z.MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'DELETE PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE c
     FROM PIFMS_Y1 c,
          (SELECT MemberMci_IDNO
             FROM PIFMS_Y1 a
            WHERE a.TypeArrear_CODE = @Lc_ArrearTypeA_CODE
              AND a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
              AND a.ExcludeIrs_CODE = 'N'
              AND NOT EXISTS(SELECT 1
                               FROM PIFMS_Y1 b
                              WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                AND b.TypeTransaction_CODE = @Lc_TypeTranscU_CODE)
            GROUP BY a.MemberMci_IDNO
           HAVING SUM (a.Transaction_AMNT) < @Ln_Arrear150_AMNT) z,
          (SELECT MemberMci_IDNO
             FROM PIFMS_Y1 a
            WHERE a.TypeArrear_CODE = @Lc_ArrearTypeN_CODE
              AND a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
              AND a.ExcludeIrs_CODE = 'N'
              AND NOT EXISTS(SELECT 1
                               FROM PIFMS_Y1 b
                              WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                AND b.TypeTransaction_CODE = @Lc_TypeTranscU_CODE)
            GROUP BY a.MemberMci_IDNO
           HAVING SUM (a.Transaction_AMNT) < @Ln_Arrear500_AMNT) y
    WHERE z.MemberMci_IDNO = y.MemberMci_IDNO
      AND c.MemberMci_IDNO = z.MemberMci_IDNO;

   /*
   	Delete the case if that case is not eligible for $25 for existing member in IRS process
   	Suppose if the member having only one arrear type case.
   */
   SET @Ls_Sql_TEXT = 'SELECT PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   WITH PifmsDelete_Tab
        AS (SELECT MemberMci_IDNO,
                   Case_IDNO
              FROM PIFMS_Y1 a
             WHERE a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND 1 = (SELECT COUNT(DISTINCT(b.TypeArrear_CODE))
                          FROM PIFMS_Y1 b
                         WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                           AND b.Case_IDNO = a.Case_IDNO)
             GROUP BY MemberMci_IDNO,
                      Case_IDNO
            HAVING SUM (Transaction_AMNT) < @Ln_Arrear25_AMNT)
   DELETE a
     FROM PIFMS_Y1 a,
          PifmsDelete_Tab b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.Case_IDNO = b.Case_IDNO;

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal5_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal5_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL5:;

   /*
   	Suppose If the member SSN changed and that member went last RUN BEGIN we need
   	to send Delete (D) transaction first and sent to Add (A) transaction next run.
   */
   SET @Ls_Sql_TEXT = 'UPDATE - IFMS';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE a
      SET a.Transaction_AMNT = (SELECT DISTINCT
                                       @Ln_Zero_NUMB
                                  FROM IFMS_Y1 b
                                 WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                   AND b.MemberSsn_NUMB <> a.MemberSsn_NUMB
                                   AND b.Transaction_AMNT > @Ln_Zero_NUMB),
          a.MemberSsn_NUMB = (SELECT MAX(b.MemberSsn_NUMB)
                                FROM IFMS_Y1 b
                               WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND b.MemberSsn_NUMB <> a.MemberSsn_NUMB
                                 AND b.Transaction_AMNT > @Ln_Zero_NUMB)
     FROM PIFMS_Y1 a
    WHERE EXISTS(SELECT 1
                   FROM IFMS_Y1 b
                  WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                    AND b.MemberSsn_NUMB <> a.MemberSsn_NUMB
                    AND b.Transaction_AMNT > @Ln_Zero_NUMB)

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal6_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal6_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL6:;

   /*
   	Below things we are handling the Auto response for IRS Rejected record with reject type
   	as Auto.
   */
   SET @Ls_Sql_TEXT = 'PROCEDURE CALL - SP_AUTO_RESPONSE - 1';
   SET @Ls_Sqldata_TEXT = 'Error_CODE = ' + ISNULL(@Lc_Reject12_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE
    @Ac_Error_CODE            = @Lc_Reject12_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Sql_TEXT = @Ls_Sql_TEXT + ' - FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PROCEDURE CALL - SP_AUTO_RESPONSE - 2';
   SET @Ls_Sqldata_TEXT = 'Error_CODE = ' + ISNULL(@Lc_Reject06_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE
    @Ac_Error_CODE            = @Lc_Reject06_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Sql_TEXT = @Ls_Sql_TEXT + ' - FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PROCEDURE CALL - SP_AUTO_RESPONSE - 3';
   SET @Ls_Sqldata_TEXT = 'Error_CODE = ' + ISNULL(@Lc_Reject39_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE
    @Ac_Error_CODE            = @Lc_Reject39_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Sql_TEXT = @Ls_Sql_TEXT + ' - FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'PROCEDURE CALL - SP_AUTO_RESPONSE - 4';
   SET @Ls_Sqldata_TEXT = 'Error_CODE = ' + ISNULL(@Lc_Reject17_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE
    @Ac_Error_CODE            = @Lc_Reject17_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_Sql_TEXT = @Ls_Sql_TEXT + ' - FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal7_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal7_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL7:;

   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   -- Delete the member if the member got rejection from last transaction
   SET @Ls_Sqldata_TEXT = 'RejectInd_INDC = ' + ISNULL(@Lc_Yes_TEXT, '');

   DELETE a
     FROM PIFMS_Y1 a,
          FEDH_Y1 b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.TypeArrear_CODE = b.TypeArrear_CODE
      AND b.RejectInd_INDC = @Lc_Yes_TEXT;

   /*
   check in fedh if the member that has reject indictor YES has any A/M/D record for the same arrear type with reject indictor NO
   if not, move such records to history both from fedh and ifms
   */
   IF EXISTS(SELECT 1
               FROM FEDH_Y1 A
              WHERE A.RejectInd_INDC = 'Y'
                AND NOT EXISTS(SELECT 1
                                 FROM FEDH_Y1 X
                                WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                  AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                  AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                                  AND X.RejectInd_INDC = 'N')
                AND EXISTS(SELECT 1
                             FROM RJDT_Y1 X
                            WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                              AND X.TypeArrear_CODE = A.TypeArrear_CODE
                              AND X.TransactionType_CODE = A.TypeTransaction_CODE
                              AND X.EndValidity_DATE = '9999-12-31'
                              AND X.Reject1_CODE = '38'))
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO HIFMS';
     SET @Ls_SqlData_TEXT = ''

     INSERT INTO HIFMS_Y1
     SELECT MemberMci_IDNO,
            Case_IDNO,
            MemberSsn_NUMB,
            Last_NAME,
            First_NAME,
            Middle_NAME,
            TaxYear_NUMB,
            TypeArrear_CODE,
            Transaction_AMNT,
            SubmitLast_DATE,
            TypeTransaction_CODE,
            CountyFips_CODE,
            Certified_DATE,
            StateAdministration_CODE,
            ExcludeIrs_CODE,
            ExcludeAdm_CODE,
            ExcludeFin_CODE,
            ExcludePas_CODE,
            ExcludeRet_CODE,
            ExcludeSal_CODE,
            ExcludeDebt_CODE,
            ExcludeVen_CODE,
            ExcludeIns_CODE,
            WorkerUpdate_ID,
            Update_DTTM,
            TransactionEventSeq_NUMB
       FROM IFMS_Y1 M
      WHERE EXISTS(SELECT 1
                     FROM FEDH_Y1 A
                    WHERE A.MemberMci_IDNO = M.MemberMci_IDNO
                      AND A.TypeArrear_CODE = M.TypeArrear_CODE
                      AND A.RejectInd_INDC = 'Y'
                      AND NOT EXISTS(SELECT 1
                                       FROM FEDH_Y1 X
                                      WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                        AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                        AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                                        AND X.RejectInd_INDC = 'N')
                      AND EXISTS(SELECT 1
                                   FROM RJDT_Y1 X
                                  WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                    AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                    AND X.TransactionType_CODE = A.TypeTransaction_CODE
                                    AND X.EndValidity_DATE = '9999-12-31'
                                    AND X.Reject1_CODE = '38'))
AND NOT EXISTS(SELECT 1 FROM HIFMS_Y1 X
WHERE X.Case_IDNO = M.Case_IDNO
AND X.MemberMci_IDNO = M.MemberMci_IDNO
AND X.SubmitLast_DATE = M.SubmitLast_DATE
AND X.TaxYear_NUMB = M.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = M.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = M.TypeArrear_CODE
AND X.TypeTransaction_CODE = M.TypeTransaction_CODE)

     SET @Ls_Sql_TEXT = 'DELETE FROM IFMS_Y1';
     SET @Ls_SqlData_TEXT = ''

     DELETE M
       FROM IFMS_Y1 M
      WHERE EXISTS(SELECT 1
                     FROM FEDH_Y1 A
                    WHERE A.MemberMci_IDNO = M.MemberMci_IDNO
                      AND A.TypeArrear_CODE = M.TypeArrear_CODE
                      AND A.RejectInd_INDC = 'Y'
                      AND NOT EXISTS(SELECT 1
                                       FROM FEDH_Y1 X
                                      WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                        AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                        AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                                        AND X.RejectInd_INDC = 'N')
                      AND EXISTS(SELECT 1
                                   FROM RJDT_Y1 X
                                  WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                    AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                    AND X.TransactionType_CODE = A.TypeTransaction_CODE
                                    AND X.EndValidity_DATE = '9999-12-31'
                                    AND X.Reject1_CODE = '38'))

     SET @Ls_Sql_TEXT = 'INSERT INTO HFEDH_Y1';
     SET @Ls_SqlData_TEXT = ''

     INSERT INTO HFEDH_Y1
     SELECT MemberMci_IDNO,
            MemberSsn_NUMB,
            TypeArrear_CODE,
            TypeTransaction_CODE,
            Last_NAME,
            First_NAME,
            Middle_NAME,
            Line1_ADDR,
            Line2_ADDR,
            City_ADDR,
            State_ADDR,
            Zip_ADDR,
            ArrearIdentifier_IDNO,
            Arrear_AMNT,
            SubmitLast_DATE,
            ExcludePas_CODE,
            ExcludeFin_CODE,
            ExcludeIrs_CODE,
            ExcludeAdm_CODE,
            ExcludeRet_CODE,
            ExcludeSal_CODE,
            ExcludeDebt_CODE,
            ExcludeVen_CODE,
            ExcludeIns_CODE,
            RejectInd_INDC,
            CountyFips_CODE,
            BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            WorkerUpdate_ID,
            Update_DTTM,
            TransactionEventSeq_NUMB,
            ReqPreOffset_CODE,
            TaxYear_NUMB
       FROM FEDH_Y1 A
      WHERE A.RejectInd_INDC = 'Y'
        AND NOT EXISTS(SELECT 1
                         FROM FEDH_Y1 X
                        WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                          AND X.TypeArrear_CODE = A.TypeArrear_CODE
                          AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                          AND X.RejectInd_INDC = 'N')
        AND EXISTS(SELECT 1
                     FROM RJDT_Y1 X
                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                      AND X.TypeArrear_CODE = A.TypeArrear_CODE
                      AND X.TransactionType_CODE = A.TypeTransaction_CODE
                      AND X.EndValidity_DATE = '9999-12-31'
                      AND X.Reject1_CODE = '38')
        AND NOT EXISTS (SELECT 1
                          FROM HFEDH_Y1 X
                         WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                           AND X.SubmitLast_DATE = A.SubmitLast_DATE
                           AND X.TaxYear_NUMB = A.TaxYear_NUMB
                           AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
                           AND X.TypeArrear_CODE = A.TypeArrear_CODE
                           AND X.TypeTransaction_CODE = A.TypeTransaction_CODE);

     SET @Ls_Sql_TEXT = 'DELETE FROM FEDH_Y1';
     SET @Ls_SqlData_TEXT = ''

     DELETE A
       FROM FEDH_Y1 A
      WHERE A.RejectInd_INDC = 'Y'
        AND NOT EXISTS(SELECT 1
                         FROM FEDH_Y1 X
                        WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                          AND X.TypeArrear_CODE = A.TypeArrear_CODE
                          AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                          AND X.RejectInd_INDC = 'N')
        AND EXISTS(SELECT 1
                     FROM RJDT_Y1 X
                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                      AND X.TypeArrear_CODE = A.TypeArrear_CODE
                      AND X.TransactionType_CODE = A.TypeTransaction_CODE
                      AND X.EndValidity_DATE = '9999-12-31'
                      AND X.Reject1_CODE = '38')
    END

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal8_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal8_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL8:;

   -- SSN Numeric Validation		  
   SET @Ls_Sql_TEXT = 'UPDATE - VIRSA';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE b
      SET b.PreEdit_CODE = @Lc_PreEditSN_CODE
     FROM PIFMS_Y1 a,
          IRSA_Y1 b
    WHERE dbo.BATCH_COMMON$SF_VERIFY_SSN (a.MemberSsn_NUMB) = @Lc_No_TEXT
      AND a.MemberMci_IDNO = b.MemberMci_IDNO


   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE a
     FROM PIFMS_Y1 a,
          IRSA_Y1 b
    WHERE dbo.BATCH_COMMON$SF_VERIFY_SSN (a.MemberSsn_NUMB) = @Lc_No_TEXT
      AND a.MemberMci_IDNO = b.MemberMci_IDNO;

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal9_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal9_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   ---------------------------------------start IRS check------------------------------------------------------------
   VAL9:;

   /*
      Suppose if the ncp got the money from IRS but still it's not distributed, so we need to
      minus that amount to the arrear amt even its HOLD
   */
   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal10_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal10_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL10:;

   /*
   	Update the manual exclusions in irsa table.
   	We are checking for manual exclusions only for IRS.
   */
   SET @Ls_Sql_TEXT = 'UPDATE - VIRSA';
   SET @Ls_Sqldata_TEXT = 'ExcludeIrs_INDC = ' + ISNULL(@Lc_Yes_TEXT, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE c
      SET c.PreEdit_CODE = @Lc_PreEditMN_CODE
     FROM TEXC_Y1 a,
          IRSA_Y1 c
    WHERE a.ExcludeIrs_INDC = @Lc_Yes_TEXT
      AND @Ld_Run_DATE BETWEEN a.Effective_DATE AND a.End_DATE
      AND EXISTS(SELECT 1
                   FROM PIFMS_Y1 b
                  WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                    AND b.Case_IDNO = a.Case_IDNO)
      AND a.EndValidity_DATE = @Ld_High_DATE
      AND a.Case_IDNO = c.Case_IDNO

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal11_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal11_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL11:;

   ----o	Arrears equal to or greater than the $150 TANF/Foster Care and $500 Non-TANF including CS, MS, and SS. 
   WITH PifmsArrears
        AS (SELECT DISTINCT
                   A.Case_IDNO
              FROM PIFMS_Y1 A
             WHERE A.ExcludeIrs_CODE = 'N'
               AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND A.TypeArrear_CODE = @Lc_ArrearTypeA_CODE
               AND EXISTS(SELECT 1
                            FROM PIFMS_Y1 B
                           WHERE B.Case_IDNO = A.Case_IDNO
                             AND B.TypeArrear_CODE = @Lc_ArrearTypeA_CODE
                             AND B.ExcludeIrs_CODE = 'N'
                             AND B.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
                           GROUP BY B.Case_IDNO,
                                    B.TypeArrear_CODE
                          HAVING SUM(B.Transaction_AMNT) < @Ln_Arrear150_AMNT))
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A,
          PifmsArrears B
    WHERE A.Case_IDNO = B.Case_IDNO
      AND A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND A.TypeArrear_CODE = @Lc_ArrearTypeA_CODE

   ;WITH PifmsArrears
        AS (SELECT DISTINCT
                   A.Case_IDNO
              FROM PIFMS_Y1 A
             WHERE A.ExcludeIrs_CODE = 'N'
               AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND A.TypeArrear_CODE = @Lc_ArrearTypeN_CODE
               AND EXISTS(SELECT 1
                            FROM PIFMS_Y1 B
                           WHERE B.Case_IDNO = A.Case_IDNO
                             AND B.TypeArrear_CODE = @Lc_ArrearTypeN_CODE
                             AND B.ExcludeIrs_CODE = 'N'
                             AND B.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
                           GROUP BY B.Case_IDNO,
                                    B.TypeArrear_CODE
                          HAVING SUM(B.Transaction_AMNT) < @Ln_Arrear500_AMNT))
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A,
          PifmsArrears B
    WHERE A.Case_IDNO = B.Case_IDNO
      AND A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND A.TypeArrear_CODE = @Lc_ArrearTypeN_CODE

   --/* 
   --	Select the member who dosen't having the addres from both AHIS_Y1 and HAHIS_Y1.
   --	Except the FIN becuase FIN we hava to send if doesn't having the address.
   --*/
   --SET @Ls_Sql_TEXT = 'SELECT - FEDH';
   --SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranscI_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_No_TEXT, '');
   --UPDATE a
   --   SET ExcludeIrs_CODE = CASE
   --                          WHEN ExcludeIrs_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeIrs_CODE
   --                         END,
   --       ExcludePas_CODE = CASE
   --                          WHEN ExcludePas_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludePas_CODE
   --                         END,
   --       ExcludeAdm_CODE = CASE
   --                          WHEN ExcludeAdm_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeAdm_CODE
   --                         END,
   --       ExcludeIns_CODE = CASE
   --                          WHEN ExcludeIns_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeIns_CODE
   --                         END,
   --       ExcludeDebt_CODE = CASE
   --                           WHEN ExcludeDebt_CODE = @Lc_No_TEXT
   --                            THEN @Lc_SysExclusion_CODE
   --                           ELSE ExcludeDebt_CODE
   --                          END,
   --       ExcludeSal_CODE = CASE
   --                          WHEN ExcludeSal_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeSal_CODE
   --                         END,
   --       ExcludeRet_CODE = CASE
   --                          WHEN ExcludeRet_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeRet_CODE
   --                         END,
   --       ExcludeVen_CODE = CASE
   --                          WHEN ExcludeVen_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeVen_CODE
   --                         END
   --  FROM PIFMS_Y1 a
   -- WHERE TypeTransaction_CODE = @Lc_TypeTranscI_CODE
   --   AND SubmitLast_DATE = @Ld_Run_DATE
   --   AND dbo.BATCH_COMMON$SF_GET_ADDRESS (MemberMci_IDNO, @Ld_Run_DATE) = @Lc_No_TEXT
   --   AND (ExcludeIrs_CODE <> 'S'
   --         OR ExcludePas_CODE = @Lc_No_TEXT
   --         OR ExcludeAdm_CODE = @Lc_No_TEXT
   --         OR ExcludeRet_CODE = @Lc_No_TEXT
   --         OR ExcludeSal_CODE = @Lc_No_TEXT
   --         OR ExcludeVen_CODE = @Lc_No_TEXT
   --         OR ExcludeIns_CODE = @Lc_No_TEXT
   --         OR ExcludeDebt_CODE = @Lc_No_TEXT);
   /*
   	Delinquency equal to one month's support obligation (Source: During JAD, State provided this comment)
   */
   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal27_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal27_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL27:;

   SET @Ls_Sqldata_TEXT = '';

   WITH PifmsArrears
        AS (SELECT C.Case_IDNO
              FROM (SELECT A.Case_IDNO,
                           SUM(A.Transaction_AMNT) CurArrears_AMNT
                      FROM PIFMS_Y1 A
                     WHERE A.ExcludeIrs_CODE = 'N'
                       AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
                     GROUP BY A.Case_IDNO) C
             WHERE (C.CurArrears_AMNT < dbo.BATCH_COMMON$SF_GET_OBLIGATION_AMT(C.Case_IDNO, @Ld_Run_DATE)))
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A,
          PifmsArrears B
    WHERE A.Case_IDNO = B.Case_IDNO
      AND A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE

   /*
   	CP has a verified mailing address or Last known court address, Active Direct Deposit, or Stored Value Card (Source: During JAD, State provided this comment)
   */
   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal28_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal28_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL28:;

   SET @Ls_Sqldata_TEXT = '';

   WITH PifmsSkipCase
        AS (SELECT A.Case_IDNO
              FROM PIFMS_Y1 A
             WHERE A.ExcludeIrs_CODE = 'N'
               AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND EXISTS(SELECT 1
                            FROM CMEM_Y1 B
                           WHERE B.Case_IDNO = A.Case_IDNO
                             AND B.CaseRelationship_CODE = 'C'
                             AND B.CaseMemberStatus_CODE = 'A'
                             AND (NOT EXISTS (SELECT 1
                                                FROM AHIS_Y1 X
                                               WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                                                 AND X.TypeAddress_CODE IN ('M', 'C')
                                                 AND X.End_DATE = @Ld_High_DATE
                                                 AND X.Status_CODE = 'Y')
                                  AND NOT EXISTS (SELECT 1
                                                    FROM EFTR_Y1 X
                                                   WHERE X.CheckRecipient_ID = B.MemberMci_IDNO
                                                     AND X.CheckRecipient_CODE = '1'
                                                     AND X.StatusEft_CODE = 'AC'
                                                     AND X.EndValidity_DATE = @Ld_High_DATE)
                                  AND NOT EXISTS (SELECT 1
                                                    FROM DCRS_Y1 X
                                                   WHERE X.CheckRecipient_ID = B.MemberMci_IDNO
                                                     AND X.Status_CODE = 'A'
                                                     AND X.EndValidity_DATE = @Ld_High_DATE))))
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A,
          PifmsSkipCase B
    WHERE A.Case_IDNO = B.Case_IDNO
      AND A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE

   /*
   	A Case Closure activity chain does not exist in Active mode (Source: During JAD, State provided this comment)
   */
   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal29_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal29_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL29:;

   SET @Ls_Sqldata_TEXT = '';

   WITH PifmsSkipCase
        AS (SELECT A.Case_IDNO
              FROM PIFMS_Y1 A
             WHERE A.ExcludeIrs_CODE = 'N'
               AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND EXISTS(SELECT 1
                            FROM DMJR_Y1 B
                           WHERE B.Case_IDNO = A.Case_IDNO
                             AND B.ActivityMajor_CODE = @Lc_ActiveMjrCCLO_CODE
                             AND B.Status_CODE = @Lc_StatusSTRT_CODE))
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A,
          PifmsSkipCase B
    WHERE A.Case_IDNO = B.Case_IDNO
      AND A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE

   --o	Valid court order
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND NOT EXISTS (SELECT 1
                        FROM SORD_Y1 X
                       WHERE X.Case_IDNO = A.Case_IDNO
                         AND @Ad_Run_DATE BETWEEN X.OrderEffective_DATE AND X.OrderEnd_DATE
                         AND X.EndValidity_DATE = '12/31/9999')

   --o	The case is marked â€˜Instateâ€™ or â€˜Initiating Intergovernmentalâ€™ 
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND NOT EXISTS (SELECT 1
                        FROM CASE_Y1 X
                       WHERE X.Case_IDNO = A.Case_IDNO
                         AND X.StatusCase_CODE = 'O'
                         AND X.TypeCase_CODE <> 'H'
                         AND (X.RespondInit_CODE = 'N'
                               OR (X.RespondInit_CODE IN ('C', 'I', 'T')
                                   AND EXISTS (SELECT 1
                                                 FROM ICAS_Y1 Y
                                                WHERE Y.Case_IDNO = X.Case_IDNO
                                                  AND Y.Status_CODE = 'O'
                                                  AND Y.End_DATE = '12/31/9999'
                                                  AND Y.EndValidity_DATE = '12/31/9999'))))

   --o	NCP has a verified mailing address or last known court address 
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND NOT EXISTS (SELECT 1
                        FROM AHIS_Y1 X
                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                         AND X.TypeAddress_CODE IN ('M', 'C')
                         AND X.End_DATE = @Ld_High_DATE
                         AND X.Status_CODE = 'Y')

   --o	A confirmed good primary Social Security Number or confirmed good ITN is recorded on the DEMO - Member Demographics screen for the NCP
   UPDATE A
      SET ExcludeIrs_CODE = @Lc_SysExclusion_CODE,
          ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
          ExcludeRet_CODE = @Lc_SysExclusion_CODE,
          ExcludeSal_CODE = @Lc_SysExclusion_CODE,
          ExcludeVen_CODE = @Lc_SysExclusion_CODE,
          ExcludeDebt_CODE = @Lc_SysExclusion_CODE,
          ExcludeFin_CODE = @Lc_SysExclusion_CODE,
          ExcludeIns_CODE = @Lc_SysExclusion_CODE,
          ExcludePas_CODE = @Lc_SysExclusion_CODE
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND NOT EXISTS (SELECT 1
                        FROM MSSN_Y1 X
                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                         AND X.TypePrimary_CODE IN ('P', 'I')
                         AND X.Enumeration_CODE = 'Y'
                         AND X.EndValidity_DATE = '12/31/9999')

   ---------------------------------------------End IRS Check--------------------------------------------------------
   ---------------------------------------------Start ADM Check--------------------------------------------------------
   ----o	The combined arrears (TANF/Foster Care + NTANF) become greater than or equal to $150 including CS, MS and SS
   --WITH PifmsArrears
   --     AS (SELECT B.Case_IDNO
   --           FROM (SELECT A.Case_IDNO,
   --                        SUM(A.Transaction_AMNT) CurArrears_AMNT
   --                   FROM PIFMS_Y1 A
   --                  WHERE A.ExcludeIrs_CODE <> 'S'
   --                    AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --                  GROUP BY A.Case_IDNO) B
   --          WHERE B.CurArrears_AMNT < 150)
   --UPDATE A
   --   SET ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeRet_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeSal_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeVen_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsArrears B
   -- WHERE B.Case_IDNO = A.Case_IDNO;
   --/*
   --	Delinquency equal to one month's support obligation (Source: During JAD, State provided this comment)
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal30_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal30_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL30:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsArrears
   --     AS (SELECT B.Case_IDNO
   --           FROM (SELECT A.Case_IDNO,
   --                        SUM(A.Transaction_AMNT) CurArrears_AMNT
   --                   FROM PIFMS_Y1 A
   --                  WHERE A.ExcludeIrs_CODE <> 'S'
   --                    AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --                  GROUP BY A.Case_IDNO) B
   --          WHERE B.CurArrears_AMNT < dbo.BATCH_COMMON$SF_GET_OBLIGATION_AMT(B.Case_IDNO, @Ld_Run_DATE))
   --UPDATE A
   --   SET ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeRet_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeSal_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeVen_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsArrears B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   --/*
   --	For 'RET', NCP does not have 'VP' as a confirmed good employer on EHIS (Source: During JAD, State provided this comment)
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal31_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal31_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL31:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipMember
   --     AS (SELECT A.MemberMci_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeIrs_CODE <> 'S'
   --            AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --            AND A.ExcludeRet_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM EHIS_Y1 B
   --                        WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
   --                          AND B.TypeIncome_CODE = 'VP'
   --                          AND @Ld_Run_DATE BETWEEN B.BeginEmployment_DATE AND B.EndEmployment_DATE))
   --UPDATE A
   --   SET ExcludeRet_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipMember B
   -- WHERE A.MemberMci_IDNO = B.MemberMci_IDNO;
   --/*
   --	CP has a verified mailing address or Last known court address, Active Direct Deposit, or Stored Value Card (Source: During JAD, State provided this comment)
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal32_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal32_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL32:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT A.Case_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeIrs_CODE <> 'S'
   --            AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM CMEM_Y1 B
   --                        WHERE B.Case_IDNO = A.Case_IDNO
   --                          AND B.CaseRelationship_CODE = 'C'
   --                          AND B.CaseMemberStatus_CODE = 'A'
   --                          AND (NOT EXISTS (SELECT 1
   --                                             FROM AHIS_Y1 X
   --                                            WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
   --                                              AND X.TypeAddress_CODE IN ('M', 'C')
   --                                              AND X.End_DATE = @Ld_High_DATE
   --                                              AND X.Status_CODE = 'Y')
   --                               AND NOT EXISTS (SELECT 1
   --                                                 FROM EFTR_Y1 X
   --                                                WHERE X.CheckRecipient_ID = B.MemberMci_IDNO
   --                                                  AND X.CheckRecipient_CODE = '1'
   --                                                  AND X.StatusEft_CODE = 'AC'
   --                                                  AND X.EndValidity_DATE = @Ld_High_DATE)
   --                               AND NOT EXISTS (SELECT 1
   --                                                 FROM DCRS_Y1 X
   --                                                WHERE X.CheckRecipient_ID = B.MemberMci_IDNO
   --                                                  AND X.Status_CODE = 'A'
   --                                                  AND X.EndValidity_DATE = @Ld_High_DATE))))
   --UPDATE A
   --   SET ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeRet_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeSal_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeVen_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipCase B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   --/*
   --	A Case Closure activity chain does not exist in Active mode (Source: During JAD, State provided this comment)
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal33_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal33_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL33:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT A.Case_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeIrs_CODE <> 'S'
   --            AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM DMJR_Y1 B
   --                        WHERE B.Case_IDNO = A.Case_IDNO
   --                          AND B.ActivityMajor_CODE = @Lc_ActiveMjrCCLO_CODE
   --                          AND B.Status_CODE = @Lc_StatusSTRT_CODE))
   --UPDATE A
   --   SET ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeRet_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeSal_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeVen_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipCase B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   ----o	Valid court order
   --UPDATE A
   --   SET ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeRet_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeSal_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeVen_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM SORD_Y1 X
   --                    WHERE X.Case_IDNO = A.Case_IDNO
   --                      AND @Ad_Run_DATE BETWEEN X.OrderEffective_DATE AND X.OrderEnd_DATE
   --                      AND X.EndValidity_DATE = '12/31/9999')
   ----o	The case is marked â€˜Instateâ€™ or â€˜Initiating Intergovernmentalâ€™ 
   --UPDATE A
   --   SET ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeRet_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeSal_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeVen_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM CASE_Y1 X
   --                    WHERE X.Case_IDNO = A.Case_IDNO
   --                      AND X.StatusCase_CODE = 'O'
   --                      AND X.TypeCase_CODE <> 'H'
   --                      AND (X.RespondInit_CODE = 'N'
   --                            OR (X.RespondInit_CODE IN ('C', 'I', 'T')
   --                                AND EXISTS (SELECT 1
   --                                              FROM ICAS_Y1 Y
   --                                             WHERE Y.Case_IDNO = X.Case_IDNO
   --                                               AND Y.Status_CODE = 'O'
   --                                               AND Y.End_DATE = '12/31/9999'
   --                                               AND Y.EndValidity_DATE = '12/31/9999'))))
   ----o	NCP has a verified mailing address or last known court address 
   --UPDATE A
   --   SET ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeRet_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeSal_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeVen_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM AHIS_Y1 X
   --                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND X.TypeAddress_CODE IN ('M', 'C')
   --                      AND X.End_DATE = @Ld_High_DATE
   --                      AND X.Status_CODE = 'Y')
   ----o	A confirmed good primary Social Security Number or confirmed good ITN is recorded on the DEMO - Member Demographics screen for the NCP
   --UPDATE A
   --   SET ExcludeAdm_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeRet_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeSal_CODE = @Lc_SysExclusion_CODE,
   --       ExcludeVen_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludeAdm_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM MSSN_Y1 X
   --                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND X.TypePrimary_CODE IN ('P', 'I')
   --                      AND X.Enumeration_CODE = 'Y'
   --                      AND X.EndValidity_DATE = '12/31/9999')
   ---------------------------------------------End ADM Check--------------------------------------------------------
   ---------------------------------------------Start FIN ,INS ,ADM and DCKCheck------------------------------------------------------
   --/*
   --	The case is not marked enforcement exempt (Source: During JAD, State provided this comment)
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal34_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal34_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL34:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT A.Case_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeFin_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM ACEN_Y1 B
   --                        WHERE B.Case_IDNO = A.Case_IDNO
   --                          AND B.StatusEnforce_CODE = 'E'
   --                          AND @Ld_Run_DATE BETWEEN B.BeginExempt_DATE AND B.EndExempt_DATE
   --                          AND B.EndValidity_DATE = @Ld_High_DATE))
   --UPDATE A
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipCase B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   --/*
   --	The case is not marked exempt from the FIDM remedy (Source: During JAD, State provided this comment) 
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal35_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal35_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL35:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT A.Case_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeFin_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM DMJR_Y1 B
   --                        WHERE B.Case_IDNO = A.Case_IDNO
   --                          AND B.ActivityMajor_CODE = 'FIDM'
   --                          AND B.Status_CODE = 'EXMT'
   --                          AND @Ld_Run_DATE BETWEEN B.BeginExempt_DATE AND B.EndExempt_DATE))
   --UPDATE A
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipCase B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   --/*
   --	For current charging obligation case,  arrears are greater than or equal to $1000 including CS, MS, and SS and no voluntary payments made in last 60 calendar days (Source: During JAD, State provided this comment) 
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal36_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal36_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL36:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsArrears
   --     AS (SELECT B.Case_IDNO
   --           FROM (SELECT A.Case_IDNO,
   --                        SUM(A.Transaction_AMNT) CurArrears_AMNT
   --                   FROM PIFMS_Y1 A
   --                  WHERE A.ExcludeFin_CODE = @Lc_No_TEXT
   --                  GROUP BY A.Case_IDNO) B
   --          WHERE (B.CurArrears_AMNT < 1000
   --              OR NOT EXISTS(SELECT 1
   --                              FROM OBLE_Y1 X
   --                             WHERE X.Case_IDNO = B.Case_IDNO
   --                               AND X.Periodic_AMNT > 0
   --                               AND X.TypeDebt_CODE IN ('CS', 'MS', 'SS')
   --                               AND @Ld_Run_DATE BETWEEN X.BeginObligation_DATE AND X.EndObligation_DATE
   --                               AND X.EndValidity_DATE = @Ld_High_DATE)
   --              OR dbo.BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SF_NUM_REGULAR_PAYMENTS (B.Case_IDNO, DATEADD(D, -60, @Ld_Run_DATE), @Ld_Run_DATE) >= 1))
   --UPDATE A
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsArrears B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   --/*
   --	For arrears only case with arrear obligation, the arrears can be less than $1000 including CS, MS, and SS and no voluntary payments made in the past 12 months (Source: During JAD, State provided this comment) 
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal37_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal37_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL37:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsArrears
   --     AS (SELECT B.Case_IDNO
   --           FROM (SELECT A.Case_IDNO,
   --                        SUM(A.Transaction_AMNT) CurArrears_AMNT
   --                   FROM PIFMS_Y1 A
   --                  WHERE A.ExcludeFin_CODE = @Lc_No_TEXT
   --                  GROUP BY A.Case_IDNO) B
   --          WHERE (B.CurArrears_AMNT < 0
   --              OR NOT EXISTS(SELECT 1
   --                              FROM OBLE_Y1 X
   --                             WHERE X.Case_IDNO = B.Case_IDNO
   --                               AND X.Periodic_AMNT = 0
   --                               AND X.ExpectToPay_AMNT > 0
   --                               AND X.TypeDebt_CODE IN ('CS', 'MS', 'SS')
   --                               AND X.EndValidity_DATE = @Ld_High_DATE)
   --              OR dbo.BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SF_NUM_REGULAR_PAYMENTS (B.Case_IDNO, DATEADD(D, -365, @Ld_Run_DATE), @Ld_Run_DATE) >= 1))
   --UPDATE A
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsArrears B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   --/*
   --	A Case Closure activity chain does not exist in Active mode (Source: During JAD, State provided this comment)
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal38_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal38_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL38:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT A.Case_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeFin_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM DMJR_Y1 B
   --                        WHERE B.Case_IDNO = A.Case_IDNO
   --                          AND B.ActivityMajor_CODE = @Lc_ActiveMjrCCLO_CODE
   --                          AND B.Status_CODE = @Lc_StatusSTRT_CODE))
   --UPDATE A
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipCase B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   ----o	The NCP is not in active Chapter 13 bankruptcy 
   --UPDATE a
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 a
   -- WHERE a.ExcludeFin_CODE = @Lc_No_TEXT
   --   AND EXISTS(SELECT 1
   --                FROM BNKR_Y1 b
   --               WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
   --                 AND b.TypeBankruptcy_CODE = @Lc_TypeBankruptcy_CODE
   --                 AND @Ld_Run_DATE BETWEEN BeginBankruptcy_DATE AND EndBankruptcy_DATE
   --                 AND Filed_DATE != @Ld_Low_DATE);
   ----o	Original court order issue date was 45 calendar days before the system date. 
   --WITH PifmsSkip
   --     AS (SELECT Case_IDNO
   --           FROM PIFMS_Y1 a
   --          WHERE a.ExcludeFin_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM SORD_Y1 c
   --                        WHERE c.Case_IDNO = a.Case_IDNO
   --                          AND DATEDIFF(D, c.OrderIssued_DATE, @Ld_Run_DATE) < @Ln_45Days_NUMB
   --                          AND c.EventGlobalBeginSeq_NUMB = (SELECT MIN(EventGlobalBeginSeq_NUMB)
   --                                                              FROM SORD_Y1 d
   --                                                             WHERE d.Case_IDNO = c.Case_IDNO
   --                                                               AND d.EndValidity_DATE = @Ld_High_DATE)
   --                          AND c.EndValidity_DATE = @Ld_High_DATE))
   --UPDATE a
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 a,
   --       PifmsSkip b
   -- WHERE a.Case_IDNO = b.Case_IDNO;
   ----o	The case is marked â€˜Instateâ€™ or â€˜Initiating Intergovernmentalâ€™ 
   --UPDATE A
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeFin_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM CASE_Y1 X
   --                    WHERE X.Case_IDNO = A.Case_IDNO
   --                      AND X.StatusCase_CODE = 'O'
   --                      AND X.TypeCase_CODE <> 'H'
   --                      AND (X.RespondInit_CODE = 'N'
   --                            OR (X.RespondInit_CODE IN ('C', 'I', 'T')
   --                                AND EXISTS (SELECT 1
   --                                              FROM ICAS_Y1 Y
   --                                             WHERE Y.Case_IDNO = X.Case_IDNO
   --                                               AND Y.Status_CODE = 'O'
   --                                               AND Y.End_DATE = '12/31/9999'
   --                                               AND Y.EndValidity_DATE = '12/31/9999'))))
   ----o	A confirmed good primary Social Security Number or confirmed good ITN is recorded on the DEMO - Member Demographics screen for the NCP
   --UPDATE A
   --   SET ExcludeFin_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeFin_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM MSSN_Y1 X
   --                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND X.TypePrimary_CODE IN ('P', 'I')
   --                      AND X.Enumeration_CODE = 'Y'
   --                      AND X.EndValidity_DATE = '12/31/9999')
   ------------------------------------------------End FIN Check-----------------------------------------------------
   ----------------------------------------------Start INS check---------------------------------------------------	
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal14_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal14_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL14:;
   --SET @Ls_Sql_TEXT = 'SELECT - ID_MEMBE';
   --SET @Ls_Sqldata_TEXT = 'ExcludeIns_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_No_TEXT, '') + ', TypeBankruptcy_CODE = ' + ISNULL(@Lc_TypeBankruptcy_CODE, '');
   --UPDATE a
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 a
   -- WHERE a.ExcludeIns_CODE = @Lc_No_TEXT
   --   AND a.ExcludeIrs_CODE <> 'S'
   --   AND EXISTS(SELECT 1
   --                FROM BNKR_Y1 b
   --               WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
   --                 AND b.TypeBankruptcy_CODE = @Lc_TypeBankruptcy_CODE
   --                 AND @Ld_Run_DATE BETWEEN BeginBankruptcy_DATE AND EndBankruptcy_DATE
   --                 AND Filed_DATE != @Ld_Low_DATE);
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal15_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal15_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL15:;
   --/*
   --	Skip the cases for arrears calculation if the difference between the dt_run and dt_order_issued from
   --	the SORD_Y1 table is less than 45 calendar days. 
   --*/
   --SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkip
   --     AS (SELECT Case_IDNO
   --           FROM PIFMS_Y1 a
   --          WHERE a.ExcludeIns_CODE = @Lc_No_TEXT
   --            AND a.ExcludeIrs_CODE <> 'S'
   --            AND EXISTS(SELECT 1
   --                         FROM SORD_Y1 c
   --                        WHERE c.Case_IDNO = a.Case_IDNO
   --                          AND DATEDIFF(D, c.OrderIssued_DATE, @Ld_Run_DATE) < @Ln_45Days_NUMB
   --                          AND c.EventGlobalBeginSeq_NUMB = (SELECT MIN(EventGlobalBeginSeq_NUMB)
   --                                                              FROM SORD_Y1 d
   --                                                             WHERE d.Case_IDNO = c.Case_IDNO
   --                                                               AND d.EndValidity_DATE = @Ld_High_DATE)
   --                          AND c.EndValidity_DATE = @Ld_High_DATE))
   --UPDATE a
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 a,
   --       PifmsSkip b
   -- WHERE a.Case_IDNO = b.Case_IDNO;
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal16_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal16_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL16:;
   ---- Skip the cases If a case closure activity chain exists in active mode in DMJR_Y1 table
   --SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT Case_IDNO
   --           FROM PIFMS_Y1 a
   --          WHERE a.ExcludeIns_CODE = @Lc_No_TEXT
   --            AND a.ExcludeIrs_CODE <> 'S'
   --            AND EXISTS(SELECT 1
   --                         FROM DMJR_Y1 c
   --                        WHERE c.Case_IDNO = a.Case_IDNO
   --                          AND c.ActivityMajor_CODE = @Lc_ActiveMjrCCLO_CODE
   --                          AND c.Status_CODE = @Lc_StatusSTRT_CODE))
   --UPDATE a
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 a,
   --       PifmsSkipCase b
   -- WHERE a.Case_IDNO = b.Case_IDNO;
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal18_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal18_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL18:;
   ---- Skip the cases in DMJR_Y1 table csln exemt indicator is set in DMJR_Y1
   --SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipDmjr
   --     AS (SELECT Case_IDNO
   --           FROM PIFMS_Y1 a
   --          WHERE a.ExcludeIns_CODE = @Lc_No_TEXT
   --            AND a.ExcludeIrs_CODE <> 'S'
   --            AND EXISTS(SELECT 1
   --                         FROM DMJR_Y1 c
   --                        WHERE c.Case_IDNO = a.Case_IDNO
   --                          AND c.ActivityMajor_CODE = @Lc_ActiveMjrCSLN_CODE
   --                          AND c.Status_CODE = @Lc_StatusEXMT_CODE
   --                          AND (@Ld_Run_DATE BETWEEN c.BeginExempt_DATE AND c.EndExempt_DATE)))
   --UPDATE a
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 a,
   --       PifmsSkipDmjr b
   -- WHERE a.Case_IDNO = b.Case_IDNO;
   --/*
   --	The case is not marked enforcement exempt (Source: During JAD, State provided this comment)
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal39_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal39_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL39:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT A.Case_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeIrs_CODE <> 'S'
   --            AND A.ExcludeIns_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM ACEN_Y1 B
   --                        WHERE B.Case_IDNO = A.Case_IDNO
   --                          AND B.StatusEnforce_CODE = 'E'
   --                          AND @Ld_Run_DATE BETWEEN B.BeginExempt_DATE AND B.EndExempt_DATE
   --                          AND B.EndValidity_DATE = @Ld_High_DATE))
   --UPDATE A
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipCase B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   --/*
   --	The case is not marked exempt from the FIDM remedy (Source: During JAD, State provided this comment) 
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal40_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal40_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL40:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT A.Case_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeIrs_CODE <> 'S'
   --            AND A.ExcludeIns_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM DMJR_Y1 B
   --                        WHERE B.Case_IDNO = A.Case_IDNO
   --                          AND B.ActivityMajor_CODE IN ('CSLN', 'LIEN')
   --                          AND B.Status_CODE = 'EXMT'
   --                          AND @Ld_Run_DATE BETWEEN B.BeginExempt_DATE AND B.EndExempt_DATE))
   --UPDATE A
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipCase B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   ----o	Arrears are greater than or equal to $500 including CS, MS, and SS 
   ----o	No voluntary payments in the last 60 calendar days
   --WITH PifmsArrear
   --     AS (SELECT b.Case_IDNO
   --           FROM (SELECT Case_IDNO,
   --                        SUM (Transaction_AMNT) AS CurArrears_AMNT
   --                   FROM PIFMS_Y1 A
   --                  WHERE ExcludeIrs_CODE <> 'S'
   --                    AND ExcludeIns_CODE = @Lc_No_TEXT
   --                  GROUP BY Case_IDNO)b
   --          WHERE (b.CurArrears_AMNT < 500
   --              OR dbo.BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SF_NUM_REGULAR_PAYMENTS (b.Case_IDNO, DATEADD(D, -60, @Ld_Run_DATE), @Ld_Run_DATE) >= 1))
   --UPDATE a
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 a,
   --       PifmsArrear b
   -- WHERE a.Case_IDNO = b.Case_IDNO
   ----o	The case is marked â€˜Instateâ€™ or â€˜Initiating Intergovernmentalâ€™ 
   --UPDATE A
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludeIns_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM CASE_Y1 X
   --                    WHERE X.Case_IDNO = A.Case_IDNO
   --                      AND X.StatusCase_CODE = 'O'
   --                      AND X.TypeCase_CODE <> 'H'
   --                      AND (X.RespondInit_CODE = 'N'
   --                            OR (X.RespondInit_CODE IN ('C', 'I', 'T')
   --                                AND EXISTS (SELECT 1
   --                                              FROM ICAS_Y1 Y
   --                                             WHERE Y.Case_IDNO = X.Case_IDNO
   --                                               AND Y.Status_CODE = 'O'
   --                                               AND Y.End_DATE = '12/31/9999'
   --                                               AND Y.EndValidity_DATE = '12/31/9999'))))
   ----o	A confirmed good primary Social Security Number or confirmed good ITN is recorded on the DEMO - Member Demographics screen for the NCP
   --UPDATE A
   --   SET ExcludeIns_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludeIns_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM MSSN_Y1 X
   --                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND X.TypePrimary_CODE IN ('P', 'I')
   --                      AND X.Enumeration_CODE = 'Y'
   --                      AND X.EndValidity_DATE = '12/31/9999')
   ---------------------------------------------End INS Check------------------------------------------------------		
   ---------------------------------------------Start PAS Check------------------------------------------------------		
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal19_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal19_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL19:;
   ----o	$2500 in combined arrears including CS, MS and SS. 
   ----o	No payment in 60 calendar days 
   --WITH PifmsArrear
   --     AS (SELECT b.Case_IDNO
   --           FROM (SELECT Case_IDNO,
   --                        SUM (Transaction_AMNT) AS CurArrears_AMNT
   --                   FROM PIFMS_Y1 A
   --                  WHERE ExcludeIrs_CODE <> 'S'
   --                    AND ExcludePas_CODE = @Lc_No_TEXT
   --                  GROUP BY Case_IDNO)b
   --          WHERE (b.CurArrears_AMNT < @Ln_Arrear2500_AMNT
   --              OR dbo.BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SF_NUM_REGULAR_PAYMENTS (b.Case_IDNO, DATEADD(D, -60, @Ld_Run_DATE), @Ld_Run_DATE) >= 1))
   --UPDATE a
   --   SET ExcludePas_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 a,
   --       PifmsArrear b
   -- WHERE a.Case_IDNO = b.Case_IDNO
   --/*
   --	A Case Closure activity chain does not exist in Active mode (Source: During JAD, State provided this comment)
   --*/
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal41_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal41_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL41:;
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsSkipCase
   --     AS (SELECT A.Case_IDNO
   --           FROM PIFMS_Y1 A
   --          WHERE A.ExcludeIrs_CODE <> 'S'
   --            AND A.ExcludePas_CODE = @Lc_No_TEXT
   --            AND EXISTS(SELECT 1
   --                         FROM DMJR_Y1 B
   --                        WHERE B.Case_IDNO = A.Case_IDNO
   --                          AND B.ActivityMajor_CODE = @Lc_ActiveMjrCCLO_CODE
   --                          AND B.Status_CODE = @Lc_StatusSTRT_CODE))
   --UPDATE A
   --   SET ExcludePas_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsSkipCase B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   ----o	Delinquency equal to one monthâ€™s support obligation 
   --WITH PifmsArrears
   --     AS (SELECT b.Case_IDNO
   --           FROM (SELECT Case_IDNO,
   --                        SUM (Transaction_AMNT) AS CurArrears_AMNT
   --                   FROM PIFMS_Y1 A
   --                  WHERE ExcludeIrs_CODE <> 'S'
   --                    AND ExcludePas_CODE = @Lc_No_TEXT
   --                  GROUP BY Case_IDNO)b
   --          WHERE b.CurArrears_AMNT < dbo.BATCH_COMMON$SF_GET_OBLIGATION_AMT(b.Case_IDNO, @Ld_Run_DATE))
   --UPDATE A
   --   SET ExcludePas_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A,
   --       PifmsArrears B
   -- WHERE A.Case_IDNO = B.Case_IDNO;
   ----o	Valid court order
   --UPDATE A
   --   SET ExcludePas_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludePas_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM SORD_Y1 X
   --                    WHERE X.Case_IDNO = A.Case_IDNO
   --                      AND @Ad_Run_DATE BETWEEN X.OrderEffective_DATE AND X.OrderEnd_DATE
   --                      AND X.EndValidity_DATE = '12/31/9999')
   ----o	The case is marked â€˜Instateâ€™ or â€˜Initiating Intergovernmentalâ€™ 
   --UPDATE A
   --   SET ExcludePas_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludePas_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM CASE_Y1 X
   --                    WHERE X.Case_IDNO = A.Case_IDNO
   --                      AND X.StatusCase_CODE = 'O'
   --                      AND X.TypeCase_CODE <> 'H'
   --                      AND (X.RespondInit_CODE = 'N'
   --                            OR (X.RespondInit_CODE IN ('C', 'I', 'T')
   --                                AND EXISTS (SELECT 1
   --                                              FROM ICAS_Y1 Y
   --                                             WHERE Y.Case_IDNO = X.Case_IDNO
   --                                               AND Y.Status_CODE = 'O'
   --                                               AND Y.End_DATE = '12/31/9999'
   --                                               AND Y.EndValidity_DATE = '12/31/9999'))))
   ----o	NCP has a verified mailing address or last known court address 
   --UPDATE A
   --   SET ExcludePas_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludePas_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM AHIS_Y1 X
   --                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND X.TypeAddress_CODE IN ('M', 'C')
   --                      AND X.End_DATE = @Ld_High_DATE
   --                      AND X.Status_CODE = 'Y')
   ----o	A confirmed good primary Social Security Number or confirmed good ITN is recorded on the DEMO - Member Demographics screen for the NCP
   --UPDATE A
   --   SET ExcludePas_CODE = @Lc_SysExclusion_CODE
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE <> 'S'
   --   AND A.ExcludePas_CODE = @Lc_No_TEXT
   --   AND NOT EXISTS (SELECT 1
   --                     FROM MSSN_Y1 X
   --                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND X.TypePrimary_CODE IN ('P', 'I')
   --                      AND X.Enumeration_CODE = 'Y'
   --                      AND X.EndValidity_DATE = '12/31/9999')
   ----------------------------------------------End of PAS-------------------------------------------------------		
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal20_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal20_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL20:;
   --/*
   --	This Below query ,we are Systematically exclude those member with previous run is FIDM only but this
   --	it's Eligible to NON-FIDM but those member dosen't having the address in AHIS or HAHIS table.So
   --	we exclude those member.
   --	1)First alias table "Y" , we are checking the IFMS_Y1 and PIFMS_Y1 table . In IFMS_Y1 previous run all the
   --	  NONFIDM FOP's are either S/Y but in current run it's any one of the4 FOP is eligble for NO FIDM.
   --	2)Second alias 'YY' , we taking the PIFMS_Y1 member having the enformcement hierarchy.
   --	3) We are putting the outer join in  y table  with YY.ssn is NULL. we getting the excepted results.
   --*/
   --SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1,AHIS,HAHIS';
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsIfmsTab
   --     AS (SELECT y.MemberSsn_NUMB,
   --                y.TypeArrear_CODE
   --           FROM (SELECT b.MemberSsn_NUMB,
   --                        b.TypeArrear_CODE
   --                   FROM PIFMS_Y1 b
   --                        RIGHT JOIN IFMS_Y1 c
   --                         ON b.MemberSsn_NUMB = c.MemberSsn_NUMB
   --                            AND b.Case_IDNO = c.Case_IDNO
   --                            AND b.TypeArrear_CODE = c.TypeArrear_CODE
   --                  WHERE b.MemberSsn_NUMB = c.MemberSsn_NUMB
   --                    AND b.Case_IDNO = c.Case_IDNO
   --                    AND b.TypeArrear_CODE = c.TypeArrear_CODE
   --                  GROUP BY b.MemberSsn_NUMB,
   --                           b.TypeArrear_CODE
   --                 HAVING (MIN (c.ExcludeIrs_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludePas_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeAdm_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeRet_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeVen_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeSal_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeIns_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeDebt_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeFin_CODE) = @Lc_No_TEXT)
   --                        AND (MIN (b.ExcludeIrs_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludePas_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeAdm_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeRet_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeVen_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeSal_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeIns_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeDebt_CODE) = @Lc_No_TEXT)
   --                        AND ISNULL (SUM (c.Transaction_AMNT), 0) > 0) y
   --                LEFT JOIN (SELECT c.MemberSsn_NUMB,
   --                                  c.TypeArrear_CODE
   --                             FROM PIFMS_Y1 c
   --                            WHERE dbo.BATCH_COMMON$SF_GET_ADDRESS (c.MemberMci_IDNO, @Ld_Run_DATE) = @Lc_Yes_TEXT) yy
   --                 ON y.MemberSsn_NUMB = yy.MemberSsn_NUMB
   --                    AND y.TypeArrear_CODE = yy.TypeArrear_CODE
   --          WHERE y.MemberSsn_NUMB = yy.MemberSsn_NUMB
   --            AND y.TypeArrear_CODE = yy.TypeArrear_CODE
   --            AND yy.MemberSsn_NUMB = @Ln_Zero_NUMB)
   --UPDATE p
   --   SET ExcludeIrs_CODE = CASE
   --                          WHEN ExcludeIrs_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeIrs_CODE
   --                         END,
   --       ExcludePas_CODE = CASE
   --                          WHEN ExcludePas_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludePas_CODE
   --                         END,
   --       ExcludeAdm_CODE = CASE
   --                          WHEN ExcludeAdm_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeAdm_CODE
   --                         END,
   --       ExcludeRet_CODE = CASE
   --                          WHEN ExcludeRet_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeRet_CODE
   --                         END,
   --       ExcludeSal_CODE = CASE
   --                          WHEN ExcludeSal_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeSal_CODE
   --                         END,
   --       ExcludeVen_CODE = CASE
   --                          WHEN ExcludeVen_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeVen_CODE
   --                         END,
   --       ExcludeIns_CODE = CASE
   --                          WHEN ExcludeIns_CODE = @Lc_No_TEXT
   --                           THEN @Lc_SysExclusion_CODE
   --                          ELSE ExcludeIns_CODE
   --                         END,
   --       ExcludeDebt_CODE = CASE
   --                           WHEN ExcludeDebt_CODE = @Lc_No_TEXT
   --                            THEN @Lc_SysExclusion_CODE
   --                           ELSE ExcludeDebt_CODE
   --                          END
   --  FROM PIFMS_Y1 p,
   --       PifmsIfmsTab c
   -- WHERE p.MemberSsn_NUMB = c.MemberSsn_NUMB
   --   AND p.TypeArrear_CODE = c.TypeArrear_CODE;
   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal21_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal21_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL21:;

   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1 - 2';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE a
      SET Transaction_AMNT = 0
     FROM PIFMS_Y1 a
    WHERE ExcludeIrs_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeAdm_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeVen_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeSal_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeRet_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeIns_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeDebt_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludePas_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeFin_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)

   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal22_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal22_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL22:;
   --/*   
   --	If the Last submission was FIDM only and the current run includes either TAX ADM,VEN,RET etc.. the
   --	process should send a Delete Transaction in this RUN and an ADD in the next run. To do that
   --	the following UPDATE statement updates the Transaction_AMNT as 0 if the above condition met.
   --	Selecting the records which is eligeble for FIDM to NON FIDM
   --*/
   --SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsIfmsTab
   --     AS (SELECT y.MemberMci_IDNO,
   --                y.TypeArrear_CODE
   --           FROM PIFMS_Y1 b,
   --                (SELECT b.MemberMci_IDNO,
   --                        b.TypeArrear_CODE
   --                   FROM PIFMS_Y1 b
   --                        RIGHT JOIN IFMS_Y1 c
   --                         ON b.MemberMci_IDNO = c.MemberMci_IDNO
   --                            AND b.Case_IDNO = c.Case_IDNO
   --                            AND b.TypeArrear_CODE = c.TypeArrear_CODE
   --                  WHERE b.MemberMci_IDNO = c.MemberMci_IDNO
   --                    AND b.Case_IDNO = c.Case_IDNO
   --                    AND b.TypeArrear_CODE = c.TypeArrear_CODE
   --                  GROUP BY b.MemberMci_IDNO,
   --                           b.TypeArrear_CODE
   --                 HAVING (MIN (c.ExcludeIrs_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludePas_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeAdm_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeRet_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeVen_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeSal_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeIns_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeDebt_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                         AND MIN (c.ExcludeFin_CODE) = @Lc_No_TEXT)
   --                        AND (MIN (b.ExcludeIrs_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludePas_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeAdm_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeRet_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeVen_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeSal_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeIns_CODE) = @Lc_No_TEXT
   --                              OR MIN (b.ExcludeDebt_CODE) = @Lc_No_TEXT)
   --                        AND ISNULL (SUM (c.Transaction_AMNT), 0) > 0) y
   --          WHERE y.MemberMci_IDNO = b.MemberMci_IDNO
   --            AND y.TypeArrear_CODE = b.TypeArrear_CODE)
   --UPDATE a
   --   SET Transaction_AMNT = 0
   --  FROM PIFMS_Y1 a,
   --       PifmsIfmsTab b
   -- WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
   --   AND a.TypeArrear_CODE = b.TypeArrear_CODE;
   --SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal23_CODE, '');
   --EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
   -- @As_RestartKey_TEXT       = @Lc_RestartKeyVal23_CODE,
   -- @Ac_Job_ID                = @Lc_Job_ID,
   -- @Ad_Run_DATE              = @Ld_Run_DATE,
   -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
   -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
   --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   -- BEGIN
   --  RAISERROR (50001,16,1);
   -- END
   --VAL23:;
   ---- Selecting the Records whicheveer records Eliglble to NON-FIDM to FIDM .   
   --SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   --SET @Ls_Sqldata_TEXT = '';
   --WITH PifmsIfmsTabEli
   --     AS (SELECT y.MemberMci_IDNO,
   --                y.TypeArrear_CODE
   --           FROM PIFMS_Y1 b,
   --                (SELECT b.MemberMci_IDNO,
   --                        b.TypeArrear_CODE
   --                   FROM PIFMS_Y1 b
   --                        RIGHT JOIN IFMS_Y1 c
   --                         ON b.MemberMci_IDNO = c.MemberMci_IDNO
   --                            AND b.Case_IDNO = c.Case_IDNO
   --                            AND b.TypeArrear_CODE = c.TypeArrear_CODE
   --                  WHERE b.MemberMci_IDNO = c.MemberMci_IDNO
   --                    AND b.Case_IDNO = c.Case_IDNO
   --                    AND b.TypeArrear_CODE = c.TypeArrear_CODE
   --                  GROUP BY b.MemberMci_IDNO,
   --                           b.TypeArrear_CODE
   --                 HAVING (MIN (c.ExcludeIrs_CODE) = @Lc_No_TEXT
   --                          OR MIN (c.ExcludePas_CODE) = @Lc_No_TEXT
   --                          OR MIN (c.ExcludeAdm_CODE) = @Lc_No_TEXT
   --                          OR MIN (c.ExcludeRet_CODE) = @Lc_No_TEXT
   --                          OR MIN (c.ExcludeVen_CODE) = @Lc_No_TEXT
   --                          OR MIN (c.ExcludeSal_CODE) = @Lc_No_TEXT
   --                          OR MIN (c.ExcludeIns_CODE) = @Lc_No_TEXT
   --                          OR MIN (c.ExcludeDebt_CODE) = @Lc_No_TEXT)
   --                        AND (MIN (b.ExcludeIrs_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                             AND MIN (b.ExcludePas_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                             AND MIN (b.ExcludeAdm_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                             AND MIN (b.ExcludeRet_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                             AND MIN (b.ExcludeVen_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                             AND MIN (b.ExcludeSal_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                             AND MIN (b.ExcludeIns_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                             AND MIN (b.ExcludeDebt_CODE) IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
   --                             AND MIN (b.ExcludeFin_CODE) = @Lc_No_TEXT)
   --                        AND ISNULL (SUM (c.Transaction_AMNT), 0) > 0) y
   --          WHERE y.MemberMci_IDNO = b.MemberMci_IDNO
   --            AND y.TypeArrear_CODE = b.TypeArrear_CODE)
   ---- We are setting those records amt as  0 , because we need to send D transaction for those NON-FIDM to FIDM records.
   --UPDATE a
   --   SET Transaction_AMNT = 0
   --  FROM PIFMS_Y1 a,
   --       PifmsIfmsTabEli b
   -- WHERE Transaction_AMNT = 0
   --   AND a.MemberMci_IDNO = b.MemberMci_IDNO
   --   AND a.TypeArrear_CODE = b.TypeArrear_CODE;
   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal24_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal24_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL24:;

   -- Delete Members having Arrear and Ceritified Amount as 0
   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   WITH PifmsHavArrTab
        AS (SELECT a.MemberMci_IDNO,
                   z.TypeArrear_CODE
              FROM PIFMS_Y1 a,
                   (SELECT c.MemberMci_IDNO,
                           c.TypeArrear_CODE
                      FROM IFMS_Y1 b
                           LEFT JOIN PIFMS_Y1 c
                            ON b.MemberMci_IDNO = c.MemberMci_IDNO
                               AND b.TypeArrear_CODE = c.TypeArrear_CODE
                               AND b.Case_IDNO = c.Case_IDNO
                     WHERE b.MemberMci_IDNO = c.MemberMci_IDNO
                       AND b.TypeArrear_CODE = c.TypeArrear_CODE
                       AND b.Case_IDNO = c.Case_IDNO
                     GROUP BY c.MemberMci_IDNO,
                              c.TypeArrear_CODE
                    HAVING ISNULL (SUM (c.Transaction_AMNT), @Ln_Zero_NUMB) <= @Ln_Zero_NUMB
                           AND ISNULL (SUM (b.Transaction_AMNT), @Ln_Zero_NUMB) = @Ln_Zero_NUMB) z
             WHERE z.MemberMci_IDNO = a.MemberMci_IDNO
               AND z.TypeArrear_CODE = a.TypeArrear_CODE)
   DELETE a
     FROM PIFMS_Y1 a,
          PifmsHavArrTab b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.TypeArrear_CODE = b.TypeArrear_CODE;

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal25_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal25_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL25:;

   /*    
   									$25 Arrear Difference Check.
   		
   	The following Update statement includes all the Cases from TAXI screen
   	to check the $25 difference between the Certified Amount and the Arrear, even though they does not
   	exist in FEDH Screen with > 0 amount. Previously the update statement took some cases twice from TAXI
   	because of the non-existence in FEDH, and the arrear amounts are doubled, resulting 'M' Transaction went.
   	The Update statement has been changed by including the Outer Join in the sub-query.
   */
   SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   WITH PifmForArr_Tab
        AS (SELECT c.MemberMci_IDNO,
                   c.Case_IDNO,
                   c.TypeArrear_CODE
              FROM IFMS_Y1 b
                   LEFT JOIN PIFMS_Y1 c
                    ON b.MemberMci_IDNO = c.MemberMci_IDNO
                       AND b.TypeArrear_CODE = c.TypeArrear_CODE
                       AND b.Case_IDNO = c.Case_IDNO
                       AND b.Transaction_AMNT <> @Ln_Zero_NUMB
                       AND b.TypeTransaction_CODE <> @Lc_TypeTranscD_CODE
             WHERE b.MemberMci_IDNO = c.MemberMci_IDNO
               AND b.TypeArrear_CODE = c.TypeArrear_CODE
               AND b.Case_IDNO = c.Case_IDNO
               AND b.Transaction_AMNT <> @Ln_Zero_NUMB
               AND b.TypeTransaction_CODE <> @Lc_TypeTranscD_CODE
             GROUP BY c.MemberMci_IDNO,
                      c.Case_IDNO,
                      c.TypeArrear_CODE
            HAVING ISNULL (SUM (b.Transaction_AMNT), @Ln_Zero_NUMB) > @Ln_Zero_NUMB
                   AND SUM (c.Transaction_AMNT) > @Ln_Zero_NUMB
                   AND ABS (SUM (b.Transaction_AMNT) - SUM (c.Transaction_AMNT)) < @Ln_Arrear25_AMNT)
   UPDATE a
      SET TypeTransaction_CODE = @Lc_TypeTranscX_CODE
     FROM PIFMS_Y1 a,
          PifmForArr_Tab b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.Case_IDNO = b.Case_IDNO
      AND a.TypeArrear_CODE = b.TypeArrear_CODE

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyVal26_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyVal26_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   VAL26:;

   /*
   	Name Update. If the first four characters of the Last Name contains any special characters,
   	the FED will rejects the records. To prevent that, we check the name and put the pre exclussion indicator
   	for that one.
   */
   SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   WITH PifmTransLastName_Tab
        AS (SELECT a.MemberMci_IDNO
              FROM PIFMS_Y1 a,
                   (SELECT MemberMci_IDNO,
                           MAX (TypeTransaction_CODE) TypeTransaction_CODE,
                           TypeArrear_CODE
                      FROM PIFMS_Y1 b
                     WHERE CAST(LEFT(LTRIM(RTRIM(ISNULL(SUBSTRING (b.Last_NAME, 1, 4), ''))) + REPLICATE('X', 4), 4) AS CHAR(4)) != dbo.BATCH_COMMON_SCALAR$SF_TRANSLATE_VARCHAR(SUBSTRING (b.Last_NAME, 1, 4), '`~!@#$%^&*()_=+{}[]|\:;"''<,.>/'' ''?0123456789', 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
                     GROUP BY MemberMci_IDNO,
                              TypeArrear_CODE) z
             WHERE a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND a.MemberMci_IDNO = z.MemberMci_IDNO
               AND a.TypeArrear_CODE = z.TypeArrear_CODE
               AND z.TypeTransaction_CODE <= @Lc_TypeTranscI_CODE)
   UPDATE a
      SET a.PreEdit_CODE = @Lc_PreEditLN_CODE
     FROM IRSA_Y1 a,
          PifmTransLastName_Tab b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   WITH PifmTransLastName_Tab
        AS (SELECT a.MemberMci_IDNO
              FROM PIFMS_Y1 a,
                   (SELECT MemberMci_IDNO,
                           MAX (TypeTransaction_CODE) TypeTransaction_CODE,
                           TypeArrear_CODE
                      FROM PIFMS_Y1 b
                     WHERE CAST(LEFT(LTRIM(RTRIM(ISNULL(SUBSTRING (b.Last_NAME, 1, 4), ''))) + REPLICATE('X', 4), 4) AS CHAR(4)) != dbo.BATCH_COMMON_SCALAR$SF_TRANSLATE_VARCHAR(SUBSTRING (b.Last_NAME, 1, 4), '`~!@#$%^&*()_=+{}[]|\:;"''<,.>/'' ''?0123456789', 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
                     GROUP BY MemberMci_IDNO,
                              TypeArrear_CODE) z
             WHERE a.TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND a.MemberMci_IDNO = z.MemberMci_IDNO
               AND a.TypeArrear_CODE = z.TypeArrear_CODE
               AND z.TypeTransaction_CODE <= @Lc_TypeTranscI_CODE)
   DELETE a
     FROM PIFMS_Y1 a,
          PifmTransLastName_Tab b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'UPDATE - IRSA';
   SET @Ls_Sqldata_TEXT = '';

   WITH PifmsIrsaCd_Tab
        AS (SELECT MemberMci_IDNO
              FROM PIFMS_Y1 a
             WHERE TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND NOT EXISTS(SELECT 1
                                FROM PIFMS_Y1 c
                               WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND c.TypeArrear_CODE = a.TypeArrear_CODE
                                 AND c.TypeTransaction_CODE > @Lc_TypeTranscI_CODE)
               AND EXISTS(SELECT 1
                            FROM PIFMS_Y1 b
                           WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                             AND b.TypeArrear_CODE = a.TypeArrear_CODE
                             AND (ASCII (UPPER (SUBSTRING (b.First_NAME, 1, 1))) NOT BETWEEN @Lc_Ascii65_CODE AND @Lc_Ascii90_CODE
                                  AND ASCII (UPPER (SUBSTRING (a.First_NAME, 1, 1))) <> @Lc_Ascii45_CODE)))
   UPDATE a
      SET PreEdit_CODE = @Lc_PreEditFN_CODE
     FROM IRSA_Y1 a,
          PifmsIrsaCd_Tab b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   WITH PifmsIrsaCd_Tab
        AS (SELECT MemberMci_IDNO
              FROM PIFMS_Y1 a
             WHERE TypeTransaction_CODE = @Lc_TypeTranscI_CODE
               AND NOT EXISTS(SELECT 1
                                FROM PIFMS_Y1 c
                               WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND c.TypeArrear_CODE = a.TypeArrear_CODE
                                 AND c.TypeTransaction_CODE > @Lc_TypeTranscI_CODE)
               AND EXISTS(SELECT 1
                            FROM PIFMS_Y1 b
                           WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                             AND b.TypeArrear_CODE = a.TypeArrear_CODE
                             AND (ASCII (UPPER (SUBSTRING (b.First_NAME, 1, 1))) NOT BETWEEN @Lc_Ascii65_CODE AND @Lc_Ascii90_CODE
                                  AND ASCII (UPPER (SUBSTRING (a.First_NAME, 1, 1))) <> @Lc_Ascii45_CODE)))
   DELETE a
     FROM PIFMS_Y1 a,
          PifmsIrsaCd_Tab b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranscI_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   DELETE FROM PIFMS_Y1
    WHERE TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND Transaction_AMNT = @Ln_Zero_NUMB;

   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranscI_CODE, '');

   DELETE PIFMS_Y1
    WHERE TypeTransaction_CODE = @Lc_TypeTranscI_CODE
      AND ExcludeIrs_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeAdm_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeVen_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeSal_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeRet_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeIns_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeDebt_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludePas_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE)
      AND ExcludeFin_CODE IN (@Lc_Yes_TEXT, @Lc_SysExclusion_CODE);

   SET @Ls_Sqldata_TEXT = 'RestartKey_TEXT = ' + ISNULL(@Lc_RestartKeyValEnd_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_JOB_RESTART
    @As_RestartKey_TEXT       = @Lc_RestartKeyValEnd_CODE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_Success_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('LOCAL', 'RjdtReject_CUR') IN (0, 1)
    BEGIN
     CLOSE RjdtReject_CUR;

     DEALLOCATE RjdtReject_CUR;
    END

   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
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

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
