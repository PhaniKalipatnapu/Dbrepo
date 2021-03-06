/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_TRANSACTION_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_TRANSACTION_DATA 
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_TRANSACTION_DATA is 
					  to store the delinquent NCPs from internal table to main table for
					  after competing all the exclusions as well as Pre-Submission Exclusions.
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_TRANSACTION_DATA] (
 @Ad_Run_DATE              DATE,
 @Ad_LastRun_DATE          DATE,
 @Ac_Job_ID                CHAR(7),
 @An_TaxYear_NUMB          NUMERIC(4),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_TypeTranModification_CODE CHAR(1) = 'M',
          @Lc_TypeTranReplace_CODE      CHAR(1) = 'R',
          @Lc_TypeTranAddCase_CODE      CHAR(1) = 'A',
          @Lc_TypeTranName_CODE         CHAR(1) = 'B',
          @Lc_TypeTranNew_CODE          CHAR(1) = 'F',
          @Lc_TypeTranCaseId_CODE       CHAR(1) = 'C',
          @Lc_TypeTranDelete_CODE       CHAR(1) = 'D',
          @Lc_TypeTranLocalCode_CODE    CHAR(1) = 'L',
          @Lc_TypeTranStatePayment_CODE CHAR(1) = 'S',
          @Lc_TypeTranAddress_CODE      CHAR(1) = 'Z',
          @Lc_TypeTranI_CODE            CHAR(1) = 'I',
          @Lc_ActionI_CODE              CHAR(1) = 'I',
          @Lc_TypeTranP_CODE            CHAR(1) = 'P',
          @Lc_TypeTranX_CODE            CHAR(1) = 'X',
          @Lc_No_INDC                   CHAR(1) = 'N',
          @Lc_Yes_INDC                  CHAR(1) = 'Y',
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_SystemExclusion_CODE      CHAR(1) = 'S',
          @Lc_RequestN_CODE             CHAR(1) = 'N',
          @Lc_StateSubmitDE_CODE        CHAR(2) = 'DE',
          @Lc_PreExclusionsAd_CODE      CHAR(2) = 'AD',
          @Lc_ExclusionsAdm_CODE        CHAR(4) = 'ADM ',
          @Lc_ExclusionsRet_CODE        CHAR(4) = 'RET ',
          @Lc_ExclusionsSal_CODE        CHAR(4) = 'SAL ',
          @Lc_ExclusionsVen_CODE        CHAR(4) = 'VEN ',
          @Lc_ExclusionsPas_CODE        CHAR(4) = 'PAS ',
          @Lc_ExclusionsIns_CODE        CHAR(4) = 'INS ',
          @Lc_ExclusionsTax_CODE        CHAR(4) = 'TAX ',
          @Lc_ExclusionsDck_CODE        CHAR(4) = 'DCK ',
          @Lc_ExclusionsFin_CODE        CHAR(4) = 'FIN ',
          @Lc_TableIdTaxi_CODE          CHAR(4) = 'TAXI',
          @Lc_TableIdYear_CODE          CHAR(4) = 'YEAR',
          @Lc_Job_ID                    CHAR(7) = @Ac_Job_ID,
          @Lc_BatchRunUser_TEXT         CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME            VARCHAR(100) = 'SP_SAVE_TRANSACTION_DATA',
          @Ld_High_DATE                 DATE = '12/31/9999',
          @Ld_Low_DATE                  DATE = '01/01/0001',
          @Ld_Run_DATE                  DATE = @Ad_Run_DATE,
          @Ld_LastRun_DATE              DATE = @Ad_LastRun_DATE;
  DECLARE @Ln_Zero_NUMB                NUMERIC = 0,
          @Ln_TaxYear_NUMB             NUMERIC(4) = @An_TaxYear_NUMB,
          @Ln_EventFunctionalSeq_NUMB  NUMERIC(4) = 0,
          @Ln_Error_NUMB               NUMERIC(11, 0),
          @Ln_ErrorLine_NUMB           NUMERIC(11, 0),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Li_FetchStatus_QNTY         SMALLINT,
          @Lc_Msg_CODE                 CHAR(5) = '',
          @Lc_State_ADDR               CHAR(2),
          @Lc_Country_ADDR             CHAR(2),
          @Lc_Zip_ADDR                 CHAR(15),
          @Lc_City_ADDR                CHAR(28),
          @Ls_Line1_ADDR               VARCHAR(50),
          @Ls_Line2_ADDR               VARCHAR(50),
          @Ls_ErrorMessage_TEXT        VARCHAR(200),
          @Ls_Sql_TEXT                 VARCHAR(200),
          @Ls_Sqldata_TEXT             VARCHAR(1000),
          @Ls_DescriptionError_TEXT    VARCHAR(4000);
  DECLARE @Ln_FedhMemberCur_MemberMci_IDNO NUMERIC(10);
  DECLARE @Ln_SequenceCur_MemberMci_IDNO           NUMERIC(10),
          @Ln_SequenceCur_MemberSsn_NUMB           NUMERIC (9),
          @Lc_SequenceCur_TypeArrear_CODE          CHAR(2),
          @Ln_SequenceCur_ArrearIdentifier_IDNO    NUMERIC (11),
          @Lc_SequenceCur_TypeTransaction_CODE     CHAR(2),
          @Ls_SequenceCur_Last_NAME                VARCHAR(100),
          @Ls_SequenceCur_First_NAME               VARCHAR(100),
          @Ls_SequenceCur_Middle_NAME              VARCHAR(100),
          @Ln_SequenceCur_Arrear_AMNT              NUMERIC(11, 2),
          @Lc_SequenceCur_ExcludePas_CODE          CHAR(1),
          @Lc_SequenceCur_ExcludeFin_CODE          CHAR(1),
          @Lc_SequenceCur_ExcludeIrs_CODE          CHAR(1),
          @Lc_SequenceCur_ExcludeAdm_CODE          CHAR(1),
          @Lc_SequenceCur_ExcludeRet_CODE          CHAR(1),
          @Lc_SequenceCur_ExcludeSal_CODE          CHAR(1),
          @Lc_SequenceCur_ExcludeDebt_CODE         CHAR(1),
          @Lc_SequenceCur_ExcludeVen_CODE          CHAR(1),
          @Lc_SequenceCur_ExcludeIns_CODE          CHAR(1),
          @Ln_SequenceCur_TaxYear_NUMB             NUMERIC(4),
          @Ld_SequenceCur_SubmitLast_DATE          DATE,
          @Ln_SequenceCur_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_SequenceCur_Fips_CODE                CHAR(10);

  CREATE TABLE #FedhKey_P1
   (
     MemberMci_IDNO           NUMERIC(10),
     TypeArrear_CODE          CHAR(1),
     TypeTransaction_CODE     CHAR(1),
     SubmitLast_DATE          DATE,
     TransactionEventSeq_NUMB NUMERIC(19),
     TaxYear_NUMB             NUMERIC(4),
     CountyFips_CODE          CHAR(3),
     ArrearIdentifier_IDNO    CHAR(6),
     ExcludePas_CODE          CHAR(1),
     ExcludeFin_CODE          CHAR(1),
     ExcludeIrs_CODE          CHAR(1),
     ExcludeAdm_CODE          CHAR(1),
     ExcludeRet_CODE          CHAR(1),
     ExcludeSal_CODE          CHAR(1),
     ExcludeDebt_CODE         CHAR(1),
     ExcludeVen_CODE          CHAR(1),
     ExcludeIns_CODE          CHAR(1),
     Certified_DATE           DATE,
     Transaction_AMNT         NUMERIC(11, 2),
     Last_NAME                CHAR(20),
     First_NAME               CHAR(16),
     Middle_NAME              CHAR(20),
     MemberSsn_NUMB           NUMERIC(9),
     Case_IDNO                NUMERIC(6)
   );

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT - FEDH_Y1';
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   /*
   Move all the records from FEDH to hist where trans type is M and amt = 0 and no
   record exists in PIFMS_Y1 for the ssn/member id
   */
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB)
   SELECT a.MemberMci_IDNO,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.SubmitLast_DATE,
          a.TransactionEventSeq_NUMB,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a
    WHERE a.TypeTransaction_CODE IN (@Lc_TypeTranModification_CODE, @Lc_TypeTranReplace_CODE)
      AND a.Arrear_AMNT = @Ln_Zero_NUMB
      AND a.RejectInd_INDC = @Lc_No_INDC
      AND NOT EXISTS (SELECT 1
                        FROM PIFMS_Y1 b
                       WHERE b.MemberSsn_NUMB = a.MemberSsn_NUMB
                         AND b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.TypeArrear_CODE = a.TypeArrear_CODE)
      AND EXISTS (SELECT 1
                    FROM PIFMS_Y1 c
                   WHERE c.MemberSsn_NUMB = a.MemberSsn_NUMB
                     AND c.MemberMci_IDNO <> a.MemberMci_IDNO
                     AND c.TypeArrear_CODE = a.TypeArrear_CODE);

   SET @Ls_Sql_TEXT = 'INSERT - HFEDH_Y1';
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

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
   SELECT a.MemberMci_IDNO,
          a.MemberSsn_NUMB,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.Last_NAME,
          a.First_NAME,
          a.Middle_NAME,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.City_ADDR,
          a.State_ADDR,
          a.Zip_ADDR,
          a.ArrearIdentifier_IDNO,
          a.Arrear_AMNT,
          a.SubmitLast_DATE,
          a.ExcludePas_CODE,
          a.ExcludeFin_CODE,
          a.ExcludeIrs_CODE,
          a.ExcludeAdm_CODE,
          a.ExcludeRet_CODE,
          a.ExcludeSal_CODE,
          a.ExcludeDebt_CODE,
          a.ExcludeVen_CODE,
          a.ExcludeIns_CODE,
          a.RejectInd_INDC,
          a.CountyFips_CODE,
          a.BeginValidity_DATE,
          @Ad_Run_DATE AS EndValidity_DATE,
          a.WorkerUpdate_ID,
          a.Update_DTTM,
          a.TransactionEventSeq_NUMB,
          a.ReqPreOffset_CODE,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB
AND NOT EXISTS(SELECT 1 FROM HFEDH_Y1 X
WHERE X.MemberMci_IDNO = a.MemberMci_IDNO
AND X.SubmitLast_DATE = a.SubmitLast_DATE
AND X.TaxYear_NUMB = a.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = a.TypeArrear_CODE
AND X.TypeTransaction_CODE = a.TypeTransaction_CODE)
      

   SET @Ls_Sql_TEXT = 'DELETE - FEDH_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE a
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB;

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   /* 
   Move all the Records from FEDH_Y1 to History where the Transaction Types
   are in 'B', 'C', 'L' and 'Z'. 
   */
   SET @Ls_Sql_TEXT = 'SELECT - FEDH_Y1 1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB)
   SELECT a.MemberMci_IDNO,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.SubmitLast_DATE,
          a.TransactionEventSeq_NUMB,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a
    WHERE a.TypeTransaction_CODE IN (@Lc_TypeTranName_CODE, @Lc_TypeTranCaseId_CODE, @Lc_TypeTranLocalCode_CODE, @Lc_TypeTranStatePayment_CODE,
                                     @Lc_TypeTranAddress_CODE, @Lc_TypeTranReplace_CODE)
      AND a.RejectInd_INDC = @Lc_No_INDC;

   SET @Ls_Sql_TEXT = 'INSERT - HFEDH_Y1';
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

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
   SELECT a.MemberMci_IDNO,
          a.MemberSsn_NUMB,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.Last_NAME,
          a.First_NAME,
          a.Middle_NAME,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.City_ADDR,
          a.State_ADDR,
          a.Zip_ADDR,
          a.ArrearIdentifier_IDNO,
          a.Arrear_AMNT,
          a.SubmitLast_DATE,
          a.ExcludePas_CODE,
          a.ExcludeFin_CODE,
          a.ExcludeIrs_CODE,
          a.ExcludeAdm_CODE,
          a.ExcludeRet_CODE,
          a.ExcludeSal_CODE,
          a.ExcludeDebt_CODE,
          a.ExcludeVen_CODE,
          a.ExcludeIns_CODE,
          a.RejectInd_INDC,
          a.CountyFips_CODE,
          a.BeginValidity_DATE,
          @Ad_Run_DATE AS EndValidity_DATE,
          a.WorkerUpdate_ID,
          a.Update_DTTM,
          a.TransactionEventSeq_NUMB,
          a.ReqPreOffset_CODE,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB
      AND NOT EXISTS (SELECT 1
                        FROM HFEDH_Y1 X
                       WHERE X.MemberMci_IDNO = a.MemberMci_IDNO
                         AND X.SubmitLast_DATE = a.SubmitLast_DATE
                         AND X.TaxYear_NUMB = a.TaxYear_NUMB
                         AND X.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
                         AND X.TypeArrear_CODE = a.TypeArrear_CODE
                         AND X.TypeTransaction_CODE = a.TypeTransaction_CODE);

   SET @Ls_Sql_TEXT = 'DELETE - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM FEDH_Y1
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB;

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   /*   
   Move the R Transaction Record to History, if M and R Transactions went in last submission.
   Keep the M Transaction Record in Main table.   
   */
   SET @Ls_Sql_TEXT = 'SELECT - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB)
   SELECT a.MemberMci_IDNO,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.SubmitLast_DATE,
          a.TransactionEventSeq_NUMB,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a
    WHERE a.TypeTransaction_CODE = @Lc_TypeTranReplace_CODE
      AND a.RejectInd_INDC = @Lc_No_INDC
      AND EXISTS (SELECT 1
                    FROM FEDH_Y1 b
                   WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                     AND b.TypeArrear_CODE = a.TypeArrear_CODE
                     AND b.TypeTransaction_CODE IN (@Lc_TypeTranModification_CODE, @Lc_TypeTranAddCase_CODE)
                     AND b.RejectInd_INDC = @Lc_No_INDC);

   SET @Ls_Sql_TEXT = 'INSERT - HFEDH_Y1';
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

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
   SELECT a.MemberMci_IDNO,
          a.MemberSsn_NUMB,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.Last_NAME,
          a.First_NAME,
          a.Middle_NAME,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.City_ADDR,
          a.State_ADDR,
          a.Zip_ADDR,
          a.ArrearIdentifier_IDNO,
          a.Arrear_AMNT,
          a.SubmitLast_DATE,
          a.ExcludePas_CODE,
          a.ExcludeFin_CODE,
          a.ExcludeIrs_CODE,
          a.ExcludeAdm_CODE,
          a.ExcludeRet_CODE,
          a.ExcludeSal_CODE,
          a.ExcludeDebt_CODE,
          a.ExcludeVen_CODE,
          a.ExcludeIns_CODE,
          a.RejectInd_INDC,
          a.CountyFips_CODE,
          a.BeginValidity_DATE,
          @Ad_Run_DATE AS EndValidity_DATE,
          a.WorkerUpdate_ID,
          a.Update_DTTM,
          a.TransactionEventSeq_NUMB,
          a.ReqPreOffset_CODE,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB
      AND NOT EXISTS (SELECT 1
                        FROM HFEDH_Y1 X
                       WHERE X.MemberMci_IDNO = a.MemberMci_IDNO
                         AND X.SubmitLast_DATE = a.SubmitLast_DATE
                         AND X.TaxYear_NUMB = a.TaxYear_NUMB
                         AND X.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
                         AND X.TypeArrear_CODE = a.TypeArrear_CODE
                         AND X.TypeTransaction_CODE = a.TypeTransaction_CODE);

   -- Delete the R Transaction, if M Transaction Exists
   SET @Ls_Sql_TEXT = 'DELETE - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM FEDH_Y1
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB;

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   /*
   	Find and Move old records to history leaving the recent records as is
   	if there are multiple transaction records for the same arrear type in IFMS
   */
   SET @Ls_Sql_TEXT = 'MOVE OLD RECORDS FROM MULTIPLE TRANSACTION RECORDS FOR THE SAME ARREAR TYPE FROM IFMS TO HISTORY';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO HIFMS_Y1
   SELECT M.MemberMci_IDNO,
          M.Case_IDNO,
          M.MemberSsn_NUMB,
          M.Last_NAME,
          M.First_NAME,
          M.Middle_NAME,
          M.TaxYear_NUMB,
          M.TypeArrear_CODE,
          M.Transaction_AMNT,
          M.SubmitLast_DATE,
          M.TypeTransaction_CODE,
          M.CountyFips_CODE,
          M.Certified_DATE,
          M.StateAdministration_CODE,
          M.ExcludeIrs_CODE,
          M.ExcludeAdm_CODE,
          M.ExcludeFin_CODE,
          M.ExcludePas_CODE,
          M.ExcludeRet_CODE,
          M.ExcludeSal_CODE,
          M.ExcludeDebt_CODE,
          M.ExcludeVen_CODE,
          M.ExcludeIns_CODE,
          M.WorkerUpdate_ID,
          M.Update_DTTM,
          M.TransactionEventSeq_NUMB
     FROM (SELECT Row_NUMB = ROW_NUMBER() OVER (PARTITION BY A.MemberMci_IDNO, A.Case_IDNO, A.TypeArrear_CODE ORDER BY A.MemberMci_IDNO, A.Case_IDNO, A.TypeArrear_CODE, A.SubmitLast_DATE DESC),
                  A.*
             FROM IFMS_Y1 A
            WHERE 1 < (SELECT COUNT(DISTINCT(B.TypeTransaction_CODE))
                         FROM IFMS_Y1 B
                        WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                          AND B.Case_IDNO = A.Case_IDNO
                          AND B.TypeArrear_CODE = A.TypeArrear_CODE
                          AND B.TypeTransaction_CODE IN ('A', 'M', 'D'))
              AND A.TypeTransaction_CODE IN ('A', 'M', 'D')) M
    WHERE M.Row_NUMB > 1
      AND NOT EXISTS(SELECT 1
                       FROM HIFMS_Y1 X
                      WHERE X.Case_IDNO = M.Case_IDNO
                        AND X.MemberMci_IDNO = M.MemberMci_IDNO
                        AND X.SubmitLast_DATE = M.SubmitLast_DATE
                        AND X.TaxYear_NUMB = M.TaxYear_NUMB
                        AND X.TransactionEventSeq_NUMB = M.TransactionEventSeq_NUMB
                        AND X.TypeArrear_CODE = M.TypeArrear_CODE
                        AND X.TypeTransaction_CODE = M.TypeTransaction_CODE)

   SET @Ls_Sql_TEXT = 'DELETE OLD RECORDS FROM MULTIPLE TRANSACTION RECORDS FOR THE SAME ARREAR TYPE FROM IFMS';
   SET @Ls_Sqldata_TEXT = '';

   DELETE M
     FROM (SELECT Row_NUMB = ROW_NUMBER() OVER (PARTITION BY A.MemberMci_IDNO, A.Case_IDNO, A.TypeArrear_CODE ORDER BY A.MemberMci_IDNO, A.Case_IDNO, A.TypeArrear_CODE, A.SubmitLast_DATE DESC),
                  A.*
             FROM IFMS_Y1 A
            WHERE 1 < (SELECT COUNT(DISTINCT(B.TypeTransaction_CODE))
                         FROM IFMS_Y1 B
                        WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                          AND B.Case_IDNO = A.Case_IDNO
                          AND B.TypeArrear_CODE = A.TypeArrear_CODE
                          AND B.TypeTransaction_CODE IN ('A', 'M', 'D'))
              AND A.TypeTransaction_CODE IN ('A', 'M', 'D')) M
    WHERE M.Row_NUMB > 1

 /*
    Move old R records from IFMS to History
 */
         
     SET @Ls_Sql_TEXT = 'INSERT R RECORDS FROM IFMS TO HIFMS_Y1';
     SET @Ls_SqlData_TEXT = '';
INSERT INTO HIFMS_Y1
SELECT A.* FROM IFMS_Y1 A 
WHERE A.TypeTransaction_CODE = 'R'
AND EXISTS(SELECT 1 FROM IFMS_Y1 X 
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.Case_IDNO = A.Case_IDNO
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE <> A.TypeTransaction_CODE)
AND EXISTS(SELECT 1 FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE <> A.TypeTransaction_CODE
AND X.RejectInd_INDC = 'N')
AND NOT EXISTS(SELECT 1 FROM HIFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

     SET @Ls_Sql_TEXT = 'DELETE R RECORDS FROM IFMS_Y1';
     SET @Ls_SqlData_TEXT = '';
DELETE A
FROM IFMS_Y1 A 
WHERE A.TypeTransaction_CODE = 'R'
AND EXISTS(SELECT 1 FROM IFMS_Y1 X 
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.Case_IDNO = A.Case_IDNO
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE <> A.TypeTransaction_CODE)
AND EXISTS(SELECT 1 FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE <> A.TypeTransaction_CODE
AND X.RejectInd_INDC = 'N')

   /*    
   ADD Transaction Process. If the PIFMS_Y1 has records with CD_Action 'I' for all cases and
   arrear for that member, BEGIN it should be an 'ADD' for the Member and Arrear. Note that the TypeTransaction_CODE
   value of FEDH_Y1 is 'F' instead of 'A'. Because some existing records having 'A' wrongly.
   It the process tries to insert with the same combination, will create a UNIQUE constraint problem. 
   */
   DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
    SELECT MemberMci_IDNO,
           MemberSsn_NUMB,
           TypeArrear_CODE,
           Last_NAME,
           First_NAME,
           Middle_NAME,
           SUM (a.Transaction_AMNT) AS Transaction_AMNT,
           MIN (a.ExcludePas_CODE) AS ExcludePas_CODE,
           MIN (a.ExcludeFin_CODE) AS ExcludeFin_CODE,
           MIN (a.ExcludeIrs_CODE) AS ExcludeIrs_CODE,
           MIN (a.ExcludeAdm_CODE) AS ExcludeAdm_CODE,
           MIN (a.ExcludeRet_CODE) AS ExcludeRet_CODE,
           MIN (a.ExcludeSal_CODE) AS ExcludeSal_CODE,
           MIN (a.ExcludeDebt_CODE) AS ExcludeDebt_CODE,
           MIN (a.ExcludeVen_CODE) AS ExcludeVen_CODE,
           MIN (a.ExcludeIns_CODE) AS ExcludeIns_CODE
      FROM (SELECT b.MemberMci_IDNO,
                   b.MemberSsn_NUMB,
                   b.Last_NAME,
                   b.First_NAME,
                   b.Middle_NAME,
                   b.TypeArrear_CODE,
                   b.Transaction_AMNT,
                   b.ExcludeIrs_CODE,
                   b.ExcludePas_CODE,
                   b.ExcludeFin_CODE,
                   b.ExcludeIns_CODE,
                   b.ExcludeVen_CODE,
                   b.ExcludeDebt_CODE,
                   b.ExcludeSal_CODE,
                   b.ExcludeRet_CODE,
                   b.ExcludeAdm_CODE
              FROM PIFMS_Y1 b
             WHERE NOT EXISTS (SELECT 1
                                 FROM FEDH_Y1 c
                                WHERE c.MemberSsn_NUMB = b.MemberSsn_NUMB
                                  AND c.TypeArrear_CODE = b.TypeArrear_CODE
                                  AND c.TypeTransaction_CODE IN (@Lc_TypeTranAddCase_CODE, @Lc_TypeTranModification_CODE, @Lc_TypeTranReplace_CODE))
               AND TypeTransaction_CODE = @Lc_TypeTranI_CODE) a
     GROUP BY a.MemberMci_IDNO,
              a.MemberSsn_NUMB,
              a.TypeArrear_CODE,
              a.Last_NAME,
              a.First_NAME,
              a.Middle_NAME;

   OPEN Sequence_CUR;

   FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE (@Li_FetchStatus_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT - FEDH';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranNew_CODE, '') + ', Last_NAME = ' + ISNULL(@Ls_SequenceCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Ls_SequenceCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Ls_SequenceCur_Middle_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearIdentifier_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Arrear_AMNT = ' + ISNULL(CAST(@Ln_SequenceCur_Arrear_AMNT AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludePas_CODE, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeFin_CODE, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIrs_CODE, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeAdm_CODE, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeRet_CODE, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeSal_CODE, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeDebt_CODE, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeVen_CODE, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIns_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '');

     INSERT INTO FEDH_Y1
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
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  ReqPreOffset_CODE,
                  TaxYear_NUMB)
     SELECT @Ln_SequenceCur_MemberMci_IDNO AS MemberMci_IDNO,
            @Ln_SequenceCur_MemberSsn_NUMB AS MemberSsn_NUMB,
            @Lc_SequenceCur_TypeArrear_CODE AS TypeArrear_CODE,
            @Lc_TypeTranNew_CODE AS TypeTransaction_CODE,
            @Ls_SequenceCur_Last_NAME AS Last_NAME,
            @Ls_SequenceCur_First_NAME AS First_NAME,
            @Ls_SequenceCur_Middle_NAME AS Middle_NAME,
            @Lc_Space_TEXT AS Line1_ADDR,
            @Lc_Space_TEXT AS Line2_ADDR,
            @Lc_Space_TEXT AS City_ADDR,
            @Lc_Space_TEXT AS State_ADDR,
            @Lc_Space_TEXT AS Zip_ADDR,
            @Ln_Zero_NUMB AS ArrearIdentifier_IDNO,
            @Ln_SequenceCur_Arrear_AMNT AS Arrear_AMNT,
            @Ad_Run_DATE AS SubmitLast_DATE,
            @Lc_SequenceCur_ExcludePas_CODE AS ExcludePas_CODE,
            @Lc_SequenceCur_ExcludeFin_CODE AS ExcludeFin_CODE,
            @Lc_SequenceCur_ExcludeIrs_CODE AS ExcludeIrs_CODE,
            @Lc_SequenceCur_ExcludeAdm_CODE AS ExcludeAdm_CODE,
            @Lc_SequenceCur_ExcludeRet_CODE AS ExcludeRet_CODE,
            @Lc_SequenceCur_ExcludeSal_CODE AS ExcludeSal_CODE,
            @Lc_SequenceCur_ExcludeDebt_CODE AS ExcludeDebt_CODE,
            @Lc_SequenceCur_ExcludeVen_CODE AS ExcludeVen_CODE,
            @Lc_SequenceCur_ExcludeIns_CODE AS ExcludeIns_CODE,
            @Lc_No_INDC AS RejectInd_INDC,
            @Lc_Space_TEXT AS CountyFips_CODE,
            @Ad_Run_DATE AS BeginValidity_DATE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
            @Lc_Space_TEXT AS ReqPreOffset_CODE,
            @An_TaxYear_NUMB AS TaxYear_NUMB

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   ---------------------------------------Addres Validation Start--------------------------------------
   /*    Address Update for ADD Transaction.  */
   SET @Ls_Sql_TEXT = 'SELECT - AHIS';

   DECLARE FedhMember_CUR INSENSITIVE CURSOR FOR
    SELECT MemberMci_IDNO
      FROM FEDH_Y1 a
     WHERE TypeTransaction_CODE = @Lc_TypeTranNew_CODE
       AND RejectInd_INDC = @Lc_No_INDC
       --AND dbo.BATCH_COMMON$SF_GET_ADDRESS (a.MemberMci_IDNO, @Ad_Run_DATE) = @Lc_Yes_INDC;
       AND EXISTS(SELECT 1
                    FROM AHIS_Y1 X
                   WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                     AND X.TypeAddress_CODE IN ('M', 'R', 'C')
                     AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                     AND X.Status_CODE = 'Y')

   SET @Ls_Sql_TEXT = 'Open FedhMember_CUR';

   OPEN FedhMember_CUR;

   SET @Ls_Sql_TEXT = 'FETCH FedhMember_CUR';

   FETCH NEXT FROM FedhMember_CUR INTO @Ln_FedhMemberCur_MemberMci_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'While loop 1';

   --loop through
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     --SET @Ls_Sql_TEXT = 'SELECT - AHIS_Y1';
     --SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FedhMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');
     --EXECUTE BATCH_COMMON$SP_GET_ADDRESS
     -- @An_MemberMci_IDNO        = @Ln_FedhMemberCur_MemberMci_IDNO,
     -- @Ad_Run_DATE              = @Ad_Run_DATE,
     -- @As_Line1_ADDR            = @Ls_Line1_ADDR OUTPUT,
     -- @As_Line2_ADDR            = @Ls_Line2_ADDR OUTPUT,
     -- @Ac_City_ADDR             = @Lc_City_ADDR OUTPUT,
     -- @Ac_State_ADDR            = @Lc_State_ADDR OUTPUT,
     -- @Ac_Zip_ADDR              = @Lc_Zip_ADDR OUTPUT,
     -- @Ac_Country_ADDR          = @Lc_Country_ADDR OUTPUT,
     -- @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
     -- @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
     --IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
     -- BEGIN
     --  RAISERROR (50001,16,1);
     -- END;
     --SET @Ls_Sql_TEXT = 'UPDATE - FEDH_Y1';
     --SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FedhMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranNew_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '');
     --UPDATE FEDH_Y1
     --   SET Line1_ADDR = SUBSTRING (@Ls_Line1_ADDR, 1, 30),
     --       Line2_ADDR = SUBSTRING (@Ls_Line2_ADDR, 1, 30),
     --       City_ADDR = SUBSTRING (@Lc_City_ADDR, 1, 25),
     --       State_ADDR = @Lc_State_ADDR,
     --       Zip_ADDR = SUBSTRING (@Lc_Zip_ADDR, 1, 9)
     -- WHERE MemberMci_IDNO = @Ln_FedhMemberCur_MemberMci_IDNO
     --   AND TypeTransaction_CODE = @Lc_TypeTranNew_CODE
     --   AND RejectInd_INDC = @Lc_No_INDC;
     UPDATE A
        SET A.Line1_ADDR = B.Line1_ADDR,
            A.Line2_ADDR = B.Line2_ADDR,
            A.City_ADDR = B.City_ADDR,
            A.State_ADDR = B.State_ADDR,
            A.Zip_ADDR = B.Zip_ADDR
       FROM FEDH_Y1 A,
            (SELECT Row_NUMB = ROW_NUMBER() OVER (PARTITION BY Y.MemberMci_IDNO ORDER BY Y.Priority_NUMB, Y.End_DATE DESC),
                    Y.*
               FROM (SELECT CASE
                             WHEN X.TypeAddress_CODE = 'M'
                              THEN 1
                             WHEN X.TypeAddress_CODE = 'R'
                              THEN 2
                             WHEN X.TypeAddress_CODE = 'C'
                              THEN 3
                            END AS Priority_NUMB,
                            X.*
                       FROM AHIS_Y1 X
                      WHERE X.MemberMci_IDNO = @Ln_FedhMemberCur_MemberMci_IDNO
                        AND X.TypeAddress_CODE IN ('M', 'R', 'C')
                        AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                        AND X.Status_CODE = 'Y') Y) B
      WHERE A.MemberMci_IDNO = @Ln_FedhMemberCur_MemberMci_IDNO
        AND A.TypeTransaction_CODE = @Lc_TypeTranNew_CODE
        AND A.RejectInd_INDC = @Lc_No_INDC
        AND B.MemberMci_IDNO = A.MemberMci_IDNO
        AND B.Row_NUMB = 1
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

     SET @Ls_Sql_TEXT = 'FETCH FedhMember_CUR-2';

     FETCH NEXT FROM FedhMember_CUR INTO @Ln_FedhMemberCur_MemberMci_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE FedhMember_CUR;

   DEALLOCATE FedhMember_CUR;

   /* 
   Select the member who dosen't having the addres from both AHIS_Y1 and HAHIS_Y1  .
   Except the FIN becuase FIN we hava to sEND doesn't having the address.
   */
   SET @Ls_Sql_TEXT = 'SELECT - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE)
   SELECT MemberMci_IDNO,
          TypeArrear_CODE
     FROM FEDH_Y1 A
    WHERE TypeTransaction_CODE = @Lc_TypeTranNew_CODE
      AND SubmitLast_DATE = @Ad_Run_DATE
      --AND dbo.BATCH_COMMON$SF_GET_ADDRESS (MemberMci_IDNO, @Ad_Run_DATE) = @Lc_No_INDC
      --AND (ExcludeIrs_CODE = @Lc_No_INDC
      --      OR ExcludePas_CODE = @Lc_No_INDC
      --      OR ExcludeAdm_CODE = @Lc_No_INDC
      --      OR ExcludeRet_CODE = @Lc_No_INDC
      --      OR ExcludeSal_CODE = @Lc_No_INDC
      --      OR ExcludeVen_CODE = @Lc_No_INDC
      --      OR ExcludeIns_CODE = @Lc_No_INDC
      --      OR ExcludeDebt_CODE = @Lc_No_INDC);
      AND NOT EXISTS(SELECT 1
                       FROM AHIS_Y1 X
                      WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                        AND X.TypeAddress_CODE IN ('M', 'R', 'C')
                        AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                        AND X.Status_CODE = 'Y')

   ---- Update those addres null records in FEDH table to system exclusion.
   --SET @Ls_Sql_TEXT = 'UPDATE - FEDH';
   --SET @Ls_Sqldata_TEXT = '';
   --UPDATE a
   --   SET a.ExcludeIrs_CODE = CASE a.ExcludeIrs_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeIrs_CODE
   --                           END,
   --       a.ExcludePas_CODE = CASE a.ExcludePas_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludePas_CODE
   --                           END,
   --       a.ExcludeAdm_CODE = CASE a.ExcludeAdm_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeAdm_CODE
   --                           END,
   --       a.ExcludeIns_CODE = CASE a.ExcludeIns_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeIns_CODE
   --                           END,
   --       a.ExcludeDebt_CODE = CASE a.ExcludeDebt_CODE
   --                             WHEN @Lc_No_INDC
   --                              THEN @Lc_SystemExclusion_CODE
   --                             ELSE a.ExcludeDebt_CODE
   --                            END,
   --       a.ExcludeSal_CODE = CASE a.ExcludeSal_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeSal_CODE
   --                           END,
   --       a.ExcludeRet_CODE = CASE a.ExcludeRet_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeRet_CODE
   --                           END,
   --       a.ExcludeVen_CODE = CASE a.ExcludeVen_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeVen_CODE
   --                           END
   --  FROM FEDH_Y1 a,
   --       #FedhKey_P1 f
   -- WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
   --   AND a.TypeArrear_CODE = f.TypeArrear_CODE;
   ---- Update those addres null records in PIFMS_Y1 table to system exclusion.
   --SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   --SET @Ls_Sqldata_TEXT = 'ExcludeIrs_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_No_INDC, '');
   --UPDATE a
   --   SET a.ExcludeIrs_CODE = CASE a.ExcludeIrs_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeIrs_CODE
   --                           END,
   --       a.ExcludePas_CODE = CASE a.ExcludePas_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludePas_CODE
   --                           END,
   --       a.ExcludeAdm_CODE = CASE a.ExcludeAdm_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeAdm_CODE
   --                           END,
   --       a.ExcludeIns_CODE = CASE a.ExcludeIns_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeIns_CODE
   --                           END,
   --       a.ExcludeDebt_CODE = CASE a.ExcludeDebt_CODE
   --                             WHEN @Lc_No_INDC
   --                              THEN @Lc_SystemExclusion_CODE
   --                             ELSE a.ExcludeDebt_CODE
   --                            END,
   --       a.ExcludeSal_CODE = CASE a.ExcludeSal_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeSal_CODE
   --                           END,
   --       a.ExcludeRet_CODE = CASE a.ExcludeRet_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeRet_CODE
   --                           END,
   --       a.ExcludeVen_CODE = CASE a.ExcludeVen_CODE
   --                            WHEN @Lc_No_INDC
   --                             THEN @Lc_SystemExclusion_CODE
   --                            ELSE a.ExcludeVen_CODE
   --                           END
   --  FROM PIFMS_Y1 a,
   --       #FedhKey_P1 f
   -- WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
   --   AND a.TypeArrear_CODE = f.TypeArrear_CODE
   --   AND (a.ExcludeIrs_CODE = @Lc_No_INDC
   --         OR a.ExcludePas_CODE = @Lc_No_INDC
   --         OR a.ExcludeAdm_CODE = @Lc_No_INDC
   --         OR a.ExcludeRet_CODE = @Lc_No_INDC
   --         OR a.ExcludeSal_CODE = @Lc_No_INDC
   --         OR a.ExcludeVen_CODE = @Lc_No_INDC
   --         OR a.ExcludeIns_CODE = @Lc_No_INDC
   --         OR a.ExcludeDebt_CODE = @Lc_No_INDC);
   -- Update those addres null records in IRSA_Y1 table to pre submission exclusin as "AD"
   SET @Ls_Sql_TEXT = 'UPDATE - IRSA_Y1';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE a
      SET a.PreEdit_CODE = @Lc_PreExclusionsAd_CODE,
          a.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
          a.Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
     FROM IRSA_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO

   --SET @Ls_Sqldata_TEXT = '';
   --DELETE FROM #FedhKey_P1;
   ---- Select MemberMci_IDNO who dosen't having the address while the "ADD" transaction
   --SET @Ls_Sql_TEXT = 'SELECT - FEDH_Y1';
   --SET @Ls_Sqldata_TEXT = '';
   --INSERT INTO #FedhKey_P1
   --            (MemberMci_IDNO,
   --             TypeArrear_CODE)
   --SELECT a.MemberMci_IDNO,
   --       a.TypeArrear_CODE
   --  FROM (SELECT MemberMci_IDNO,
   --               TypeArrear_CODE,
   --               MIN (ExcludeIrs_CODE) ExcludeIrs_CODE,
   --               MIN (ExcludePas_CODE) ExcludePas_CODE,
   --               MIN (ExcludeFin_CODE) ExcludeFin_CODE,
   --               MIN (ExcludeAdm_CODE) ExcludeAdm_CODE,
   --               MIN (ExcludeIns_CODE) ExcludeIns_CODE,
   --               MIN (ExcludeRet_CODE) ExcludeRet_CODE,
   --               MIN (ExcludeSal_CODE) ExcludeSal_CODE,
   --               MIN (ExcludeVen_CODE) ExcludeVen_CODE,
   --               MIN (ExcludeDebt_CODE) ExcludeDebt_CODE
   --          FROM FEDH_Y1
   --         WHERE TypeTransaction_CODE = @Lc_TypeTranNew_CODE
   --           AND SubmitLast_DATE = @Ad_Run_DATE
   --         GROUP BY MemberMci_IDNO,
   --                  TypeArrear_CODE) a
   -- WHERE ExcludeIrs_CODE <> @Lc_No_INDC
   --   AND ExcludePas_CODE <> @Lc_No_INDC
   --   AND ExcludeAdm_CODE <> @Lc_No_INDC
   --   AND ExcludeIns_CODE <> @Lc_No_INDC
   --   AND ExcludeRet_CODE <> @Lc_No_INDC
   --   AND ExcludeSal_CODE <> @Lc_No_INDC
   --   AND ExcludeVen_CODE <> @Lc_No_INDC
   --   AND ExcludeDebt_CODE <> @Lc_No_INDC
   --   AND ExcludeFin_CODE <> @Lc_No_INDC;
   -- Delete those addresss null members from PIFMS_Y1 table
   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE a
     FROM PIFMS_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE;

   -- Delete those addresss null members from FEDH table
   SET @Ls_Sql_TEXT = 'DELETE - FEDH';
   SET @Ls_Sqldata_TEXT = 'SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranNew_CODE, '');

   DELETE a
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.SubmitLast_DATE = @Ad_Run_DATE
      AND a.TypeTransaction_CODE = @Lc_TypeTranNew_CODE;

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   -- Delete the all records from PIFMS_Y1 table where all exclusions set to System exclusions.
   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranI_CODE, '');

   DELETE FROM PIFMS_Y1
    WHERE TypeTransaction_CODE = @Lc_TypeTranI_CODE
      AND ExcludeIrs_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE)
      AND ExcludePas_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE)
      AND ExcludeAdm_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE)
      AND ExcludeRet_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE)
      AND ExcludeSal_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE)
      AND ExcludeVen_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE)
      AND ExcludeIns_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE)
      AND ExcludeDebt_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE)
      AND ExcludeFin_CODE IN (@Lc_Yes_INDC, @Lc_SystemExclusion_CODE);

   --------------------------------Address Validation End------------------------------------------------
   -- Calculate the member level arrear amount from PIFMS_Y1
   SET @Ls_Sql_TEXT = 'SELECT - FEDH,PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                Transaction_AMNT)
   SELECT a.MemberMci_IDNO,
          a.TypeArrear_CODE,
          SUM(ISNULL(b.Transaction_AMNT, 0)) AS Transaction_AMNT
     FROM FEDH_Y1 a
          LEFT OUTER JOIN PIFMS_Y1 b
           ON a.MemberMci_IDNO = b.MemberMci_IDNO
              AND a.TypeArrear_CODE = b.TypeArrear_CODE
    WHERE a.SubmitLast_DATE = @Ad_Run_DATE
      AND a.TypeTransaction_CODE = @Lc_TypeTranNew_CODE
      AND a.RejectInd_INDC = @Lc_No_INDC
    GROUP BY a.MemberMci_IDNO,
             a.TypeArrear_CODE;

   -- Update the member arrear into FEDH table
   SET @Ls_Sql_TEXT = 'UPDATE - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE FEDH_Y1
      SET Arrear_AMNT = f.Transaction_AMNT
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

   SET @Ls_Sqldata_TEXT = '';

   DELETE #FedhKey_P1;

   -- Delete the member from FEDH_Y1 table if the ADD transaction having the arrear amt 0
   SET @Ls_Sql_TEXT = 'DELETE - FEDH';
   SET @Ls_Sqldata_TEXT = 'Arrear_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranNew_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '');

   DELETE FROM FEDH_Y1
    WHERE Arrear_AMNT = @Ln_Zero_NUMB
      AND SubmitLast_DATE = @Ad_Run_DATE
      AND TypeTransaction_CODE = @Lc_TypeTranNew_CODE
      AND RejectInd_INDC = @Lc_No_INDC;

   -- Move the existing Records to History, if ADD transaction exists in the Current Run
   SET @Ls_Sql_TEXT = 'SELECT - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB)
   SELECT a.MemberMci_IDNO,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.SubmitLast_DATE,
          a.TransactionEventSeq_NUMB,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a,
          (SELECT DISTINCT
                  MemberMci_IDNO,
                  TypeArrear_CODE
             FROM PIFMS_Y1
            WHERE TypeTransaction_CODE = @Lc_TypeTranI_CODE
           EXCEPT
           SELECT DISTINCT
                  MemberMci_IDNO,
                  TypeArrear_CODE
             FROM PIFMS_Y1
            WHERE TypeTransaction_CODE > @Lc_TypeTranI_CODE) b
    WHERE a.SubmitLast_DATE < @Ad_Run_DATE
      AND b.MemberMci_IDNO = a.MemberMci_IDNO
      AND b.TypeArrear_CODE = a.TypeArrear_CODE;

   -- Insert into federal history table if the memeber previous run is ADD exists
   SET @Ls_Sql_TEXT = 'INSERT - HFEDH_Y1';
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

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
   SELECT a.MemberMci_IDNO,
          a.MemberSsn_NUMB,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.Last_NAME,
          a.First_NAME,
          a.Middle_NAME,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.City_ADDR,
          a.State_ADDR,
          a.Zip_ADDR,
          a.ArrearIdentifier_IDNO,
          a.Arrear_AMNT,
          a.SubmitLast_DATE,
          a.ExcludePas_CODE,
          a.ExcludeFin_CODE,
          a.ExcludeIrs_CODE,
          a.ExcludeAdm_CODE,
          a.ExcludeRet_CODE,
          a.ExcludeSal_CODE,
          a.ExcludeDebt_CODE,
          a.ExcludeVen_CODE,
          a.ExcludeIns_CODE,
          a.RejectInd_INDC,
          a.CountyFips_CODE,
          a.BeginValidity_DATE,
          @Ad_Run_DATE AS EndValidity_DATE,
          a.WorkerUpdate_ID,
          a.Update_DTTM,
          a.TransactionEventSeq_NUMB,
          a.ReqPreOffset_CODE,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB
      AND NOT EXISTS (SELECT 1
                        FROM HFEDH_Y1 X
                       WHERE X.MemberMci_IDNO = a.MemberMci_IDNO
                         AND X.SubmitLast_DATE = a.SubmitLast_DATE
                         AND X.TaxYear_NUMB = a.TaxYear_NUMB
                         AND X.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
                         AND X.TypeArrear_CODE = a.TypeArrear_CODE
                         AND X.TypeTransaction_CODE = a.TypeTransaction_CODE);

   -- Delete those previous a"ADD" transaction member from FEDH_Y1 table
   SET @Ls_Sql_TEXT = 'DELETE - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM FEDH_Y1
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB;

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   /*
   We are marke it TypeTransaction_CODE as "F" for record manipulation purpose but we we need to
   send the  transaction as "A".
   So update the FEDH table  transaction type "F" to "A".
   */
   SET @Ls_Sql_TEXT = 'UPDATE - FEDH';
   SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranNew_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   UPDATE A
      SET TypeTransaction_CODE = @Lc_TypeTranAddCase_CODE
    FROM FEDH_Y1 A
   WHERE TypeTransaction_CODE = @Lc_TypeTranNew_CODE
      AND RejectInd_INDC = @Lc_No_INDC
      AND SubmitLast_DATE = @Ad_Run_DATE
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

   /*  
   We need to the take care of if the more than one case having the same amount BEGIN check
   the OrderIssued_DATE in SORD_Y1 table.
   */
   SET @Ls_Sql_TEXT = 'SELECT -FEDH,IRSA_Y1,SORD_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB,
                CountyFips_CODE,
                ArrearIdentifier_IDNO)
   SELECT a.MemberMci_IDNO,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.SubmitLast_DATE,
          a.TransactionEventSeq_NUMB,
          a.TaxYear_NUMB,
          (RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(CAST(ISNULL(b.County_IDNO, '') AS VARCHAR))), 3)) AS CountyFips_CODE,
          b.Case_IDNO
     FROM FEDH_Y1 a,
          IRSA_Y1 b
    WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.TypeTransaction_CODE = @Lc_TypeTranAddCase_CODE
      AND a.SubmitLast_DATE = @Ad_Run_DATE
      AND b.Case_IDNO = (SELECT g.Case_IDNO
                           FROM (SELECT a.MemberMci_IDNO,
                                        a.Case_IDNO,
                                        a.Transaction_AMNT,
                                        a.TypeArrear_CODE,
                                        c.OrderIssued_DATE,
                                        ROW_NUMBER () OVER (PARTITION BY a.MemberMci_IDNO, a.TypeArrear_CODE ORDER BY a.Transaction_AMNT DESC, c.OrderIssued_DATE) rn
                                   FROM PIFMS_Y1 a,
                                        SORD_Y1 c
                                  WHERE a.Case_IDNO = c.Case_IDNO
                                    AND c.EndValidity_DATE = @Ld_High_DATE) g
                          WHERE g.MemberMci_IDNO = a.MemberMci_IDNO
                            AND TypeArrear_CODE = a.TypeArrear_CODE
                            AND rn = 1);

   -- Update the those records arrear identifier and fips code into FEDH table
   SET @Ls_Sql_TEXT = 'UPDATE - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE a
      SET a.ArrearIdentifier_IDNO = f.ArrearIdentifier_IDNO,
          a.CountyFips_CODE = f.CountyFips_CODE
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   /*
   DELETE Transaction Process.
   Select the member who's having the Arrear_AMNT less than or equal to zero
   */
   SET @Ls_Sql_TEXT = 'SELECTT - FEDH';
   -- Code modified to send the latest exclusion indicator information to IRS    
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB,
                ExcludeIrs_CODE,
                ExcludePas_CODE,
                ExcludeFin_CODE,
                ExcludeAdm_CODE,
                ExcludeRet_CODE,
                ExcludeSal_CODE,
                ExcludeVen_CODE,
                ExcludeDebt_CODE,
                ExcludeIns_CODE)
   SELECT a.MemberMci_IDNO,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.SubmitLast_DATE,
          a.TransactionEventSeq_NUMB,
          a.TaxYear_NUMB,
          z.ExcludeIrs_CODE,
          z.ExcludePas_CODE,
          z.ExcludeFin_CODE,
          z.ExcludeAdm_CODE,
          z.ExcludeRet_CODE,
          z.ExcludeSal_CODE,
          z.ExcludeVen_CODE,
          z.ExcludeDebt_CODE,
          z.ExcludeIns_CODE
     FROM FEDH_Y1 a,
          (SELECT MemberMci_IDNO,
                  TypeArrear_CODE,
                  MIN (ExcludeIrs_CODE) ExcludeIrs_CODE,
                  MIN (ExcludePas_CODE) ExcludePas_CODE,
                  MIN (ExcludeFin_CODE) ExcludeFin_CODE,
                  MIN (ExcludeAdm_CODE) ExcludeAdm_CODE,
                  MIN (ExcludeRet_CODE) ExcludeRet_CODE,
                  MIN (ExcludeSal_CODE) ExcludeSal_CODE,
                  MIN (ExcludeVen_CODE) ExcludeVen_CODE,
                  MIN (ExcludeDebt_CODE) ExcludeDebt_CODE,
                  MIN (ExcludeIns_CODE) ExcludeIns_CODE
             FROM PIFMS_Y1
            GROUP BY MemberMci_IDNO,
                     TypeArrear_CODE
           HAVING SUM (Transaction_AMNT) <= @Ln_Zero_NUMB) z
    WHERE z.MemberMci_IDNO = a.MemberMci_IDNO
      AND z.TypeArrear_CODE = a.TypeArrear_CODE
      AND a.TypeTransaction_CODE <> @Lc_TypeTranDelete_CODE;

   -- Insert those records into HFEDH_Y1 table
   SET @Ls_Sql_TEXT = 'INSERT - HFEDH_Y1';
   SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

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
   SELECT a.MemberMci_IDNO,
          a.MemberSsn_NUMB,
          a.TypeArrear_CODE,
          a.TypeTransaction_CODE,
          a.Last_NAME,
          a.First_NAME,
          a.Middle_NAME,
          a.Line1_ADDR,
          a.Line2_ADDR,
          a.City_ADDR,
          a.State_ADDR,
          a.Zip_ADDR,
          a.ArrearIdentifier_IDNO,
          a.Arrear_AMNT,
          a.SubmitLast_DATE,
          a.ExcludePas_CODE,
          a.ExcludeFin_CODE,
          a.ExcludeIrs_CODE,
          a.ExcludeAdm_CODE,
          a.ExcludeRet_CODE,
          a.ExcludeSal_CODE,
          a.ExcludeDebt_CODE,
          a.ExcludeVen_CODE,
          a.ExcludeIns_CODE,
          a.RejectInd_INDC,
          a.CountyFips_CODE,
          a.BeginValidity_DATE,
          @Ad_Run_DATE AS EndValidity_DATE,
          a.WorkerUpdate_ID,
          a.Update_DTTM,
          a.TransactionEventSeq_NUMB,
          a.ReqPreOffset_CODE,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
      AND a.SubmitLast_DATE = f.SubmitLast_DATE
      AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
      AND a.TaxYear_NUMB = f.TaxYear_NUMB
      AND NOT EXISTS (SELECT 1
                        FROM HFEDH_Y1 X
                       WHERE X.MemberMci_IDNO = a.MemberMci_IDNO
                         AND X.SubmitLast_DATE = a.SubmitLast_DATE
                         AND X.TaxYear_NUMB = a.TaxYear_NUMB
                         AND X.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
                         AND X.TypeArrear_CODE = a.TypeArrear_CODE
                         AND X.TypeTransaction_CODE = a.TypeTransaction_CODE);

   DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
    SELECT f.MemberMci_IDNO,
           f.TypeArrear_CODE,
           f.TypeTransaction_CODE,
           f.SubmitLast_DATE,
           f.TransactionEventSeq_NUMB,
           f.TaxYear_NUMB
      FROM #FedhKey_P1 f;

   OPEN Sequence_CUR;

   FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Lc_SequenceCur_TypeArrear_CODE, @Lc_SequenceCur_TypeTransaction_CODE, @Ld_SequenceCur_SubmitLast_DATE, @Ln_SequenceCur_TransactionEventSeq_NUMB, @Ln_SequenceCur_TaxYear_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE (@Li_FetchStatus_QNTY = 0)
    BEGIN
     -- Update those records as "D" transaction
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'UPDATE - FEDH';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_SequenceCur_TypeTransaction_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_SequenceCur_SubmitLast_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_TransactionEventSeq_NUMB AS VARCHAR), '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_TaxYear_NUMB AS VARCHAR), '');

     UPDATE a
        SET a.TypeTransaction_CODE = @Lc_TypeTranDelete_CODE,
            a.Arrear_AMNT = @Ln_Zero_NUMB,
            a.Line1_ADDR = @Lc_Space_TEXT,
            a.Line2_ADDR = @Lc_Space_TEXT,
            a.City_ADDR = @Lc_Space_TEXT,
            a.State_ADDR = @Lc_Space_TEXT,
            a.Zip_ADDR = @Lc_Space_TEXT,
            a.ExcludeIrs_CODE = f.ExcludeIrs_CODE,
            a.ExcludePas_CODE = f.ExcludePas_CODE,
            a.ExcludeFin_CODE = f.ExcludeFin_CODE,
            a.ExcludeIns_CODE = f.ExcludeIns_CODE,--13179
            a.ExcludeAdm_CODE = f.ExcludeAdm_CODE,
            a.ExcludeRet_CODE = f.ExcludeRet_CODE,
            a.ExcludeSal_CODE = f.ExcludeSal_CODE,
            a.ExcludeVen_CODE = f.ExcludeVen_CODE,
            a.ExcludeDebt_CODE = f.ExcludeDebt_CODE,
            a.SubmitLast_DATE = @Ad_Run_DATE,
            a.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            a.BeginValidity_DATE = @Ad_Run_DATE,
            a.Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
            a.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
            a.TaxYear_NUMB = @An_TaxYear_NUMB
       FROM FEDH_Y1 a,
            #FedhKey_P1 f
      WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
        AND a.TypeArrear_CODE = f.TypeArrear_CODE
        AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
        AND a.SubmitLast_DATE = f.SubmitLast_DATE
        AND a.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
        AND a.TaxYear_NUMB = f.TaxYear_NUMB
        AND a.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
        AND a.TypeArrear_CODE = @Lc_SequenceCur_TypeArrear_CODE
        AND a.TypeTransaction_CODE = @Lc_SequenceCur_TypeTransaction_CODE
        AND a.SubmitLast_DATE = @Ld_SequenceCur_SubmitLast_DATE
        AND a.TransactionEventSeq_NUMB = @Ln_SequenceCur_TransactionEventSeq_NUMB
        AND a.TaxYear_NUMB = @Ln_SequenceCur_TaxYear_NUMB
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

     /*
     check in fedh if the other type that has reject indictor YES has any A/M/D record with reject indictor NO
     if not, move such records to history both from fedh and ifms
     */
     IF EXISTS(SELECT 1
                 FROM FEDH_Y1 A
                WHERE A.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
                  AND A.TypeArrear_CODE <> @Lc_SequenceCur_TypeArrear_CODE
                  AND A.RejectInd_INDC = 'Y'
                  AND NOT EXISTS(SELECT 1
                                   FROM FEDH_Y1 X
                                  WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                    AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                    AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                                    AND X.RejectInd_INDC = @Lc_No_INDC)
                  AND EXISTS(SELECT 1
                               FROM RJDT_Y1 X
                              WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                AND X.TransactionType_CODE = A.TypeTransaction_CODE
                                AND X.EndValidity_DATE = '9999-12-31'
                                AND X.Reject1_CODE = '38'))
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT INTO HIFMS';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE <> ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '')

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
        WHERE M.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
          AND M.TypeArrear_CODE <> @Lc_SequenceCur_TypeArrear_CODE
          AND EXISTS(SELECT 1
                       FROM FEDH_Y1 A
                      WHERE A.MemberMci_IDNO = M.MemberMci_IDNO
                        AND A.TypeArrear_CODE = M.TypeArrear_CODE
                        AND A.RejectInd_INDC = 'Y'
                        AND NOT EXISTS(SELECT 1
                                         FROM FEDH_Y1 X
                                        WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                          AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                          AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                                          AND X.RejectInd_INDC = @Lc_No_INDC)
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
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE <> ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '')

       DELETE M
         FROM IFMS_Y1 M
        WHERE M.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
          AND M.TypeArrear_CODE <> @Lc_SequenceCur_TypeArrear_CODE
          AND EXISTS(SELECT 1
                       FROM FEDH_Y1 A
                      WHERE A.MemberMci_IDNO = M.MemberMci_IDNO
                        AND A.TypeArrear_CODE = M.TypeArrear_CODE
                        AND A.RejectInd_INDC = 'Y'
                        AND NOT EXISTS(SELECT 1
                                         FROM FEDH_Y1 X
                                        WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                          AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                          AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                                          AND X.RejectInd_INDC = @Lc_No_INDC)
                        AND EXISTS(SELECT 1
                                     FROM RJDT_Y1 X
                                    WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                      AND X.TypeArrear_CODE = A.TypeArrear_CODE
                                      AND X.TransactionType_CODE = A.TypeTransaction_CODE
                                      AND X.EndValidity_DATE = '9999-12-31'
                                      AND X.Reject1_CODE = '38'))

       SET @Ls_Sql_TEXT = 'INSERT INTO HFEDH_Y1';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE <> ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '')

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
        WHERE A.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
          AND A.TypeArrear_CODE <> @Lc_SequenceCur_TypeArrear_CODE
          AND A.RejectInd_INDC = 'Y'
          AND NOT EXISTS(SELECT 1
                           FROM FEDH_Y1 X
                          WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                            AND X.TypeArrear_CODE = A.TypeArrear_CODE
                            AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                            AND X.RejectInd_INDC = @Lc_No_INDC)
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
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE <> ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '')

       DELETE A
         FROM FEDH_Y1 A
        WHERE A.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
          AND A.TypeArrear_CODE <> @Lc_SequenceCur_TypeArrear_CODE
          AND A.RejectInd_INDC = 'Y'
          AND NOT EXISTS(SELECT 1
                           FROM FEDH_Y1 X
                          WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                            AND X.TypeArrear_CODE = A.TypeArrear_CODE
                            AND X.TypeTransaction_CODE IN ('A', 'M', 'D')
                            AND X.RejectInd_INDC = @Lc_No_INDC)
          AND EXISTS(SELECT 1
                       FROM RJDT_Y1 X
                      WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                        AND X.TypeArrear_CODE = A.TypeArrear_CODE
                        AND X.TransactionType_CODE = A.TypeTransaction_CODE
                        AND X.EndValidity_DATE = '9999-12-31'
                        AND X.Reject1_CODE = '38')
      END

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Lc_SequenceCur_TypeArrear_CODE, @Lc_SequenceCur_TypeTransaction_CODE, @Ld_SequenceCur_SubmitLast_DATE, @Ln_SequenceCur_TransactionEventSeq_NUMB, @Ln_SequenceCur_TaxYear_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   -- Insert the case level details into IFMS_Y1 table for "ADD" transaction
   SET @Ls_Sql_TEXT = 'PROCEDURE CALL - SP_SAVE_CHANGES';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Action_CODE = ' + ISNULL(@Lc_TypeTranI_CODE, '') + ', Msg_CODE = ' + ISNULL(@Lc_Msg_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_IFMS
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ac_Action_CODE           = @Lc_ActionI_CODE,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   /*
   Delete the insert(I) records from PIFMS_Y1 table if the member dose not having the
   A/M/R reords in FEDH
   */
   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranI_CODE, '');

   DELETE FROM PIFMS_Y1
     FROM PIFMS_Y1 a
    WHERE TypeTransaction_CODE = @Lc_TypeTranI_CODE
      AND NOT EXISTS (SELECT 1
                        FROM FEDH_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.TypeArrear_CODE = a.TypeArrear_CODE
                         AND b.TypeTransaction_CODE IN (@Lc_TypeTranAddCase_CODE, @Lc_TypeTranModification_CODE, @Lc_TypeTranReplace_CODE));

   /*
   Updating the Certified_DATE of PIFMS_Y1 table as the existing Certified_DATE from IFMS_Y1, if last
   transaction was not a 'Delete'. That is at least one record exists in IFMS_Y1 with non-zero for
   that Member and Arrear.
   */
   SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1 , IFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                Case_IDNO,
                TypeArrear_CODE,
                SubmitLast_DATE,
                Certified_DATE)
   SELECT a.MemberMci_IDNO,
          a.Case_IDNO,
          a.TypeArrear_CODE,
          a.SubmitLast_DATE,
          b.Certified_DATE
     FROM PIFMS_Y1 a,
          (SELECT MemberMci_IDNO,
                  TypeArrear_CODE,
                  MIN (Certified_DATE) Certified_DATE
             FROM IFMS_Y1
            GROUP BY MemberMci_IDNO,
                     TypeArrear_CODE
           HAVING SUM(Transaction_AMNT) > @Ln_Zero_NUMB) b
    WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
      AND b.TypeArrear_CODE = a.TypeArrear_CODE;

   -- Update PIFMS_Y1 Certified_DATE as previous ran certified date using the IFMS_Y1 table
   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE PIFMS_Y1
      SET Certified_DATE = f.Certified_DATE
     FROM PIFMS_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeArrear_CODE = f.TypeArrear_CODE
      AND a.Case_IDNO = f.Case_IDNO
      AND a.SubmitLast_DATE = f.SubmitLast_DATE

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   -- Set the remining records to high date.
   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'Certified_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '');

   UPDATE A
      SET Certified_DATE = @Ld_High_DATE
    FROM PIFMS_Y1 A
   WHERE Certified_DATE = @Ld_Low_DATE

   -- Update Cases that are having 0 Arrears as the Exclusion Indicators as 'S'.
   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'Transaction_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');

   UPDATE A
      SET ExcludeIrs_CODE = CASE ExcludeIrs_CODE
                             WHEN @Lc_No_INDC
                              THEN @Lc_SystemExclusion_CODE
                             ELSE ExcludeIrs_CODE
                            END,
          ExcludePas_CODE = CASE ExcludePas_CODE
                             WHEN @Lc_No_INDC
                              THEN @Lc_SystemExclusion_CODE
                             ELSE ExcludePas_CODE
                            END,
          ExcludeFin_CODE = CASE ExcludeFin_CODE
                             WHEN @Lc_No_INDC
                              THEN @Lc_SystemExclusion_CODE
                             ELSE ExcludeFin_CODE
                            END,
          ExcludeAdm_CODE = CASE ExcludeAdm_CODE
                             WHEN @Lc_No_INDC
                              THEN @Lc_SystemExclusion_CODE
                             ELSE ExcludeAdm_CODE
                            END,
          ExcludeVen_CODE = CASE ExcludeVen_CODE
                             WHEN @Lc_No_INDC
                              THEN @Lc_SystemExclusion_CODE
                             ELSE ExcludeVen_CODE
                            END,
          ExcludeIns_CODE = CASE ExcludeIns_CODE
                             WHEN @Lc_No_INDC
                              THEN @Lc_SystemExclusion_CODE
                             ELSE ExcludeIns_CODE
                            END,
          ExcludeRet_CODE = CASE ExcludeRet_CODE
                             WHEN @Lc_No_INDC
                              THEN @Lc_SystemExclusion_CODE
                             ELSE ExcludeRet_CODE
                            END,
          ExcludeSal_CODE = CASE ExcludeSal_CODE
                             WHEN @Lc_No_INDC
                              THEN @Lc_SystemExclusion_CODE
                             ELSE ExcludeSal_CODE
                            END,
          ExcludeDebt_CODE = CASE ExcludeDebt_CODE
                              WHEN @Lc_No_INDC
                               THEN @Lc_SystemExclusion_CODE
                              ELSE ExcludeDebt_CODE
                             END
    FROM PIFMS_Y1 A
   WHERE Transaction_AMNT = @Ln_Zero_NUMB

   -------------------------------------------L Transaction Start-----------------------------------------------------
   DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           F.MemberMci_IDNO,
           F.MemberSsn_NUMB,
           F.Last_NAME,
           F.First_NAME,
           F.Middle_NAME,
           F.TypeArrear_CODE,
           F.ArrearIdentifier_IDNO,
           G.Arrear_AMNT,
           G.ExcludePas_CODE,
           G.ExcludeFin_CODE,
           G.ExcludeIrs_CODE,
           G.ExcludeAdm_CODE,
           G.ExcludeRet_CODE,
           G.ExcludeSal_CODE,
           G.ExcludeDebt_CODE,
           G.ExcludeVen_CODE,
           G.ExcludeIns_CODE,
           F.CountyFips_CODE
      FROM (SELECT C.MemberMci_IDNO,
                   C.MemberSsn_NUMB,
                   C.Last_NAME,
                   C.First_NAME,
                   C.Middle_NAME,
                   C.TypeArrear_CODE,
                   C.Case_IDNO AS ArrearIdentifier_IDNO,
                   RIGHT(('000' + LTRIM(RTRIM(C.CountySubmitted_IDNO))), 3) AS CountyFips_CODE
              FROM (SELECT Row_NUMB = ROW_NUMBER() OVER(PARTITION BY A.MemberMci_IDNO, A.TypeArrear_CODE ORDER BY A.Transaction_AMNT DESC, B.OrderIssued_DATE),
                           B.OrderIssued_DATE,
                           A.MemberMci_IDNO,
                           A.MemberSsn_NUMB,
                           A.Last_NAME,
                           A.First_NAME,
                           A.Middle_NAME,
                           A.TypeArrear_CODE,
                           A.Case_IDNO,
                           A.CountySubmitted_IDNO
                      FROM PIFMS_Y1 A,
                           SORD_Y1 B
                     WHERE A.TypeTransaction_CODE <> 'D'
                       AND B.Case_IDNO = A.Case_IDNO
                       AND B.EndValidity_DATE = '12/31/9999') C
             WHERE C.Row_NUMB = 1) F,
           (SELECT MemberMci_IDNO,
                   TypeArrear_CODE,
                   SUM (a.Transaction_AMNT) AS Arrear_AMNT,
                   MIN (a.ExcludePas_CODE) AS ExcludePas_CODE,
                   MIN (a.ExcludeFin_CODE) AS ExcludeFin_CODE,
                   MIN (a.ExcludeIrs_CODE) AS ExcludeIrs_CODE,
                   MIN (a.ExcludeAdm_CODE) AS ExcludeAdm_CODE,
                   MIN (a.ExcludeRet_CODE) AS ExcludeRet_CODE,
                   MIN (a.ExcludeSal_CODE) AS ExcludeSal_CODE,
                   MIN (a.ExcludeDebt_CODE) AS ExcludeDebt_CODE,
                   MIN (a.ExcludeVen_CODE) AS ExcludeVen_CODE,
                   MIN (a.ExcludeIns_CODE) AS ExcludeIns_CODE
              FROM PIFMS_Y1 a
             WHERE a.TypeTransaction_CODE <> 'D'
             GROUP BY a.MemberMci_IDNO,
                      a.TypeArrear_CODE
            HAVING SUM(ISNULL(a.Transaction_AMNT, 0)) > 0) G,
           FEDH_Y1 H
     WHERE G.MemberMci_IDNO = F.MemberMci_IDNO
       AND G.TypeArrear_CODE = F.TypeArrear_CODE
       AND H.MemberMci_IDNO = G.MemberMci_IDNO
       AND H.TypeArrear_CODE = G.TypeArrear_CODE
       AND H.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                  FROM FEDH_Y1 X
                                 WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
                                   AND X.TypeArrear_CODE = H.TypeArrear_CODE
                                   AND X.SubmitLast_DATE < @Ad_Run_DATE)
       AND H.TypeTransaction_CODE IN ('A', 'M')
       AND RIGHT(('000' + LTRIM(RTRIM(H.CountyFips_CODE))), 3) <> RIGHT(('000' + LTRIM(RTRIM(F.CountyFips_CODE))), 3)

   OPEN Sequence_CUR;

   FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Lc_SequenceCur_TypeArrear_CODE, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE (@Li_FetchStatus_QNTY = 0)
    BEGIN
     -- FIPS Identifier Change Transaction Process.
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT - FEDH';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranLocalCode_CODE, '') + ', Last_NAME = ' + ISNULL(@Ls_SequenceCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Ls_SequenceCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Ls_SequenceCur_Middle_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearIdentifier_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_ArrearIdentifier_IDNO AS VARCHAR), '') + ', Arrear_AMNT = ' + ISNULL(CAST(@Ln_SequenceCur_Arrear_AMNT AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludePas_CODE, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeFin_CODE, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIrs_CODE, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeAdm_CODE, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeRet_CODE, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeSal_CODE, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeDebt_CODE, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeVen_CODE, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIns_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_SequenceCur_Fips_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '');

     INSERT INTO FEDH_Y1
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
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  ReqPreOffset_CODE,
                  TaxYear_NUMB)
     SELECT @Ln_SequenceCur_MemberMci_IDNO AS MemberMci_IDNO,
            @Ln_SequenceCur_MemberSsn_NUMB AS MemberSsn_NUMB,
            @Lc_SequenceCur_TypeArrear_CODE AS TypeArrear_CODE,
            @Lc_TypeTranLocalCode_CODE AS TypeTransaction_CODE,
            @Ls_SequenceCur_Last_NAME AS Last_NAME,
            @Ls_SequenceCur_First_NAME AS First_NAME,
            @Ls_SequenceCur_Middle_NAME AS Middle_NAME,
            @Lc_Space_TEXT AS Line1_ADDR,
            @Lc_Space_TEXT AS Line2_ADDR,
            @Lc_Space_TEXT AS City_ADDR,
            @Lc_Space_TEXT AS State_ADDR,
            @Lc_Space_TEXT AS Zip_ADDR,
            @Ln_SequenceCur_ArrearIdentifier_IDNO AS ArrearIdentifier_IDNO,
            @Ln_SequenceCur_Arrear_AMNT AS Arrear_AMNT,
            @Ad_Run_DATE AS SubmitLast_DATE,
            @Lc_SequenceCur_ExcludePas_CODE AS ExcludePas_CODE,
            @Lc_SequenceCur_ExcludeFin_CODE AS ExcludeFin_CODE,
            @Lc_SequenceCur_ExcludeIrs_CODE AS ExcludeIrs_CODE,
            @Lc_SequenceCur_ExcludeAdm_CODE AS ExcludeAdm_CODE,
            @Lc_SequenceCur_ExcludeRet_CODE AS ExcludeRet_CODE,
            @Lc_SequenceCur_ExcludeSal_CODE AS ExcludeSal_CODE,
            @Lc_SequenceCur_ExcludeDebt_CODE AS ExcludeDebt_CODE,
            @Lc_SequenceCur_ExcludeVen_CODE AS ExcludeVen_CODE,
            @Lc_SequenceCur_ExcludeIns_CODE AS ExcludeIns_CODE,
            @Lc_No_INDC AS RejectInd_INDC,
            @Lc_SequenceCur_Fips_CODE AS CountyFips_CODE,
            @Ad_Run_DATE AS BeginValidity_DATE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
            @Lc_Space_TEXT AS ReqPreOffset_CODE,
            @An_TaxYear_NUMB AS TaxYear_NUMB

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Lc_SequenceCur_TypeArrear_CODE, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   -----------------------------------------L Transaction End-----------------------------------------------------
   -----------------------------------------M Transaction Start-----------------------------------------------------
   -- Select the records from PIFMS_Y1 table , For chenages of Arrear and Exclusions
   DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           F.MemberMci_IDNO,
           F.MemberSsn_NUMB,
           F.Last_NAME,
           F.First_NAME,
           F.Middle_NAME,
           F.TypeArrear_CODE,
           F.ArrearIdentifier_IDNO,
           G.Arrear_AMNT,
           G.ExcludePas_CODE,
           G.ExcludeFin_CODE,
           G.ExcludeIrs_CODE,
           G.ExcludeAdm_CODE,
           G.ExcludeRet_CODE,
           G.ExcludeSal_CODE,
           G.ExcludeDebt_CODE,
           G.ExcludeVen_CODE,
           G.ExcludeIns_CODE,
           F.CountyFips_CODE,
           H.SubmitLast_DATE,
           H.TypeTransaction_CODE
      FROM (SELECT C.MemberMci_IDNO,
                   C.MemberSsn_NUMB,
                   C.Last_NAME,
                   C.First_NAME,
                   C.Middle_NAME,
                   C.TypeArrear_CODE,
                   C.Case_IDNO AS ArrearIdentifier_IDNO,
                   RIGHT(('000' + LTRIM(RTRIM(C.CountySubmitted_IDNO))), 3) AS CountyFips_CODE
              FROM (SELECT Row_NUMB = ROW_NUMBER() OVER(PARTITION BY A.MemberMci_IDNO, A.TypeArrear_CODE ORDER BY A.Transaction_AMNT DESC, B.OrderIssued_DATE),
                           B.OrderIssued_DATE,
                           A.MemberMci_IDNO,
                           A.MemberSsn_NUMB,
                           A.Last_NAME,
                           A.First_NAME,
                           A.Middle_NAME,
                           A.TypeArrear_CODE,
                           A.Case_IDNO,
                           A.CountySubmitted_IDNO
                      FROM PIFMS_Y1 A,
                           SORD_Y1 B
                     WHERE A.TypeTransaction_CODE <> 'D'
                       AND B.Case_IDNO = A.Case_IDNO
                       AND B.EndValidity_DATE = '12/31/9999') C
             WHERE C.Row_NUMB = 1) F,
           (SELECT MemberMci_IDNO,
                   TypeArrear_CODE,
                   SUM (a.Transaction_AMNT) AS Arrear_AMNT,
                   MIN (a.ExcludePas_CODE) AS ExcludePas_CODE,
                   MIN (a.ExcludeFin_CODE) AS ExcludeFin_CODE,
                   MIN (a.ExcludeIrs_CODE) AS ExcludeIrs_CODE,
                   MIN (a.ExcludeAdm_CODE) AS ExcludeAdm_CODE,
                   MIN (a.ExcludeRet_CODE) AS ExcludeRet_CODE,
                   MIN (a.ExcludeSal_CODE) AS ExcludeSal_CODE,
                   MIN (a.ExcludeDebt_CODE) AS ExcludeDebt_CODE,
                   MIN (a.ExcludeVen_CODE) AS ExcludeVen_CODE,
                   MIN (a.ExcludeIns_CODE) AS ExcludeIns_CODE
              FROM PIFMS_Y1 a
             WHERE a.TypeTransaction_CODE <> 'D'
             GROUP BY a.MemberMci_IDNO,
                      a.TypeArrear_CODE
            HAVING SUM(ISNULL(a.Transaction_AMNT, 0)) > 0) G,
           FEDH_Y1 H
     WHERE G.MemberMci_IDNO = F.MemberMci_IDNO
       AND G.TypeArrear_CODE = F.TypeArrear_CODE
       AND H.MemberMci_IDNO = G.MemberMci_IDNO
       AND H.TypeArrear_CODE = G.TypeArrear_CODE
       AND H.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                  FROM FEDH_Y1 X
                                 WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
                                   AND X.TypeArrear_CODE = H.TypeArrear_CODE
                                   AND X.SubmitLast_DATE < @Ad_Run_DATE)
       AND H.TypeTransaction_CODE IN ('A', 'M')
       AND H.Arrear_AMNT <> G.Arrear_AMNT
       AND ABS(H.Arrear_AMNT - G.Arrear_AMNT) > 25

   OPEN Sequence_CUR;

   FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Lc_SequenceCur_TypeArrear_CODE, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE, @Ld_SequenceCur_SubmitLast_DATE, @Lc_SequenceCur_TypeTransaction_CODE

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE (@Li_FetchStatus_QNTY = 0)
    BEGIN
     -- Modify Arrears Transaction Process.
     SET @Ls_Sql_TEXT = 'INSERT - HFEDH_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_SequenceCur_SubmitLast_DATE AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_SequenceCur_TypeTransaction_CODE, '')

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
     SELECT a.MemberMci_IDNO,
            a.MemberSsn_NUMB,
            a.TypeArrear_CODE,
            a.TypeTransaction_CODE,
            a.Last_NAME,
            a.First_NAME,
            a.Middle_NAME,
            a.Line1_ADDR,
            a.Line2_ADDR,
            a.City_ADDR,
            a.State_ADDR,
            a.Zip_ADDR,
            a.ArrearIdentifier_IDNO,
            a.Arrear_AMNT,
            a.SubmitLast_DATE,
            a.ExcludePas_CODE,
            a.ExcludeFin_CODE,
            a.ExcludeIrs_CODE,
            a.ExcludeAdm_CODE,
            a.ExcludeRet_CODE,
            a.ExcludeSal_CODE,
            a.ExcludeDebt_CODE,
            a.ExcludeVen_CODE,
            a.ExcludeIns_CODE,
            a.RejectInd_INDC,
            a.CountyFips_CODE,
            a.BeginValidity_DATE,
            @Ad_Run_DATE AS EndValidity_DATE,
            a.WorkerUpdate_ID,
            a.Update_DTTM,
            a.TransactionEventSeq_NUMB,
            a.ReqPreOffset_CODE,
            a.TaxYear_NUMB
       FROM FEDH_Y1 a
      WHERE A.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
        AND A.TypeArrear_CODE = @Lc_SequenceCur_TypeArrear_CODE
        AND A.SubmitLast_DATE = @Ld_SequenceCur_SubmitLast_DATE
        AND A.TypeTransaction_CODE = @Lc_SequenceCur_TypeTransaction_CODE
AND NOT EXISTS(SELECT 1 FROM HFEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)        

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_No_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'DELETE - FEDH';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_SequenceCur_SubmitLast_DATE AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_SequenceCur_TypeTransaction_CODE, '')

     DELETE FROM FEDH_Y1
      WHERE MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
        AND TypeArrear_CODE = @Lc_SequenceCur_TypeArrear_CODE
        AND SubmitLast_DATE = @Ld_SequenceCur_SubmitLast_DATE
        AND TypeTransaction_CODE = @Lc_SequenceCur_TypeTransaction_CODE

     SET @Ls_Sql_TEXT = 'INSERT - FEDH';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranModification_CODE, '') + ', Last_NAME = ' + ISNULL(@Ls_SequenceCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Ls_SequenceCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Ls_SequenceCur_Middle_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearIdentifier_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_ArrearIdentifier_IDNO AS VARCHAR), '') + ', Arrear_AMNT = ' + ISNULL(CAST(@Ln_SequenceCur_Arrear_AMNT AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludePas_CODE, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeFin_CODE, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIrs_CODE, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeAdm_CODE, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeRet_CODE, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeSal_CODE, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeDebt_CODE, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeVen_CODE, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIns_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_SequenceCur_Fips_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '');

     INSERT INTO FEDH_Y1
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
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  ReqPreOffset_CODE,
                  TaxYear_NUMB)
     SELECT @Ln_SequenceCur_MemberMci_IDNO AS MemberMci_IDNO,
            @Ln_SequenceCur_MemberSsn_NUMB AS MemberSsn_NUMB,
            @Lc_SequenceCur_TypeArrear_CODE AS TypeArrear_CODE,
            @Lc_TypeTranModification_CODE AS TypeTransaction_CODE,
            @Ls_SequenceCur_Last_NAME AS Last_NAME,
            @Ls_SequenceCur_First_NAME AS First_NAME,
            @Ls_SequenceCur_Middle_NAME AS Middle_NAME,
            @Lc_Space_TEXT AS Line1_ADDR,
            @Lc_Space_TEXT AS Line2_ADDR,
            @Lc_Space_TEXT AS City_ADDR,
            @Lc_Space_TEXT AS State_ADDR,
            @Lc_Space_TEXT AS Zip_ADDR,
            @Ln_SequenceCur_ArrearIdentifier_IDNO AS ArrearIdentifier_IDNO,
            @Ln_SequenceCur_Arrear_AMNT AS Arrear_AMNT,
            @Ad_Run_DATE AS SubmitLast_DATE,
            @Lc_SequenceCur_ExcludePas_CODE AS ExcludePas_CODE,
            @Lc_SequenceCur_ExcludeFin_CODE AS ExcludeFin_CODE,
            @Lc_SequenceCur_ExcludeIrs_CODE AS ExcludeIrs_CODE,
            @Lc_SequenceCur_ExcludeAdm_CODE AS ExcludeAdm_CODE,
            @Lc_SequenceCur_ExcludeRet_CODE AS ExcludeRet_CODE,
            @Lc_SequenceCur_ExcludeSal_CODE AS ExcludeSal_CODE,
            @Lc_SequenceCur_ExcludeDebt_CODE AS ExcludeDebt_CODE,
            @Lc_SequenceCur_ExcludeVen_CODE AS ExcludeVen_CODE,
            @Lc_SequenceCur_ExcludeIns_CODE AS ExcludeIns_CODE,
            @Lc_No_INDC AS RejectInd_INDC,
            @Lc_SequenceCur_Fips_CODE AS CountyFips_CODE,
            @Ad_Run_DATE AS BeginValidity_DATE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
            @Lc_Space_TEXT AS ReqPreOffset_CODE,
            @An_TaxYear_NUMB AS TaxYear_NUMB

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Lc_SequenceCur_TypeArrear_CODE, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE, @Ld_SequenceCur_SubmitLast_DATE, @Lc_SequenceCur_TypeTransaction_CODE

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   ------------------------------------M Transaction End-----------------------------------------------------
   SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_OTHER_TRANSACTION_DATA';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', LastRun_DATE = ' + ISNULL(CAST(@Ld_LastRun_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_TaxYear_NUMB AS VARCHAR), '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_OTHER_TRANSACTION_DATA
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_LastRun_DATE          = @Ld_LastRun_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   --SET @Ls_Sql_TEXT = 'SELECT - FEDH FOR B TRANS FOR 17';
   --SET @Ls_Sqldata_TEXT = '';
   --INSERT INTO #FedhKey_P1
   --            (MemberMci_IDNO,
   --             TypeArrear_CODE,
   --             TypeTransaction_CODE,
   --             SubmitLast_DATE,
   --             TransactionEventSeq_NUMB,
   --             TaxYear_NUMB)
   --SELECT x.MemberMci_IDNO,
   --       x.TypeArrear_CODE,
   --       x.TypeTransaction_CODE,
   --       x.SubmitLast_DATE,
   --       x.TransactionEventSeq_NUMB,
   --       x.TaxYear_NUMB
   --  FROM (SELECT s.MemberMci_IDNO,
   --               s.TypeArrear_CODE,
   --               s.TypeTransaction_CODE,
   --               s.SubmitLast_DATE,
   --               s.TransactionEventSeq_NUMB,
   --               s.TaxYear_NUMB,
   --               ROW_NUMBER () OVER (PARTITION BY s.MemberMci_IDNO, s.TypeArrear_CODE ORDER BY s.SubmitLast_DATE DESC) seq
   --          FROM FEDH_Y1 s,
   --               (SELECT DISTINCT
   --                       MemberMci_IDNO,
   --                       TypeArrear_CODE
   --                  FROM RJDT_Y1 r
   --                 WHERE r.TransactionType_CODE = 'B'
   --                   AND r.TypeReject1_CODE = @Lc_TypeTranAddCase_CODE
   --                   AND r.EndValidity_DATE = @Ld_High_DATE
   --                   AND NOT EXISTS (SELECT 1
   --                                     FROM FEDH_Y1 s
   --                                    WHERE s.MemberMci_IDNO = r.MemberMci_IDNO
   --                                      AND s.TypeArrear_CODE = r.TypeArrear_CODE
   --                                      AND s.TypeTransaction_CODE = @Lc_TypeTranName_CODE)) b
   --         WHERE s.MemberMci_IDNO = b.MemberMci_IDNO
   --           AND s.TypeArrear_CODE = b.TypeArrear_CODE) x
   -- WHERE x.seq = 1;
   --DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
   -- SELECT f.MemberMci_IDNO,
   --        f.TypeArrear_CODE,
   --        f.TypeTransaction_CODE,
   --        f.SubmitLast_DATE,
   --        f.TransactionEventSeq_NUMB,
   --        f.TaxYear_NUMB
   --   FROM #FedhKey_P1 f;
   --OPEN Sequence_CUR;
   --FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Lc_SequenceCur_TypeArrear_CODE, @Lc_SequenceCur_TypeTransaction_CODE, @Ld_SequenceCur_SubmitLast_DATE, @Ln_SequenceCur_TransactionEventSeq_NUMB, @Ln_SequenceCur_TaxYear_NUMB;
   --SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   ----
   --WHILE (@Li_FetchStatus_QNTY = 0)
   -- BEGIN
   --  -- Insert those rejected B transaction records to FEDH_Y1 table
   --  SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');
   --  EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
   --   @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
   --   @Ac_Process_ID               = @Ac_Job_ID,
   --   @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
   --   @Ac_Note_INDC                = @Lc_No_INDC,
   --   @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
   --   @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
   --   @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
   --   @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
   --  IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
   --   BEGIN
   --    RAISERROR (50001,16,1);
   --   END
   --  SET @Ls_Sql_TEXT = 'INSERT - FEDH_Y1 FOR B TRANS FOR 17';
   --  SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranName_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '');
   --  INSERT INTO FEDH_Y1
   --              (MemberMci_IDNO,
   --               MemberSsn_NUMB,
   --               TypeArrear_CODE,
   --               TypeTransaction_CODE,
   --               Last_NAME,
   --               First_NAME,
   --               Middle_NAME,
   --               Line1_ADDR,
   --               Line2_ADDR,
   --               City_ADDR,
   --               State_ADDR,
   --               Zip_ADDR,
   --               ArrearIdentifier_IDNO,
   --               Arrear_AMNT,
   --               SubmitLast_DATE,
   --               ExcludePas_CODE,
   --               ExcludeFin_CODE,
   --               ExcludeIrs_CODE,
   --               ExcludeAdm_CODE,
   --               ExcludeRet_CODE,
   --               ExcludeSal_CODE,
   --               ExcludeDebt_CODE,
   --               ExcludeVen_CODE,
   --               ExcludeIns_CODE,
   --               RejectInd_INDC,
   --               CountyFips_CODE,
   --               BeginValidity_DATE,
   --               WorkerUpdate_ID,
   --               Update_DTTM,
   --               TransactionEventSeq_NUMB,
   --               ReqPreOffset_CODE,
   --               TaxYear_NUMB)
   --  SELECT b.MemberMci_IDNO,
   --         b.MemberSsn_NUMB,
   --         b.TypeArrear_CODE,
   --         @Lc_TypeTranName_CODE AS TypeTransaction_CODE,
   --         b.Last_NAME,
   --         b.First_NAME,
   --         b.Middle_NAME,
   --         @Lc_Space_TEXT AS Line1_ADDR,
   --         @Lc_Space_TEXT AS Line2_ADDR,
   --         @Lc_Space_TEXT AS City_ADDR,
   --         @Lc_Space_TEXT AS State_ADDR,
   --         @Lc_Space_TEXT AS Zip_ADDR,
   --         b.ArrearIdentifier_IDNO,
   --         b.Arrear_AMNT,
   --         @Ad_Run_DATE AS SubmitLast_DATE,
   --         b.ExcludePas_CODE,
   --         b.ExcludeFin_CODE,
   --         b.ExcludeIrs_CODE,
   --         b.ExcludeAdm_CODE,
   --         b.ExcludeRet_CODE,
   --         b.ExcludeSal_CODE,
   --         b.ExcludeDebt_CODE,
   --         b.ExcludeVen_CODE,
   --         b.ExcludeIns_CODE,
   --         @Lc_No_INDC AS RejectInd_INDC,
   --         b.CountyFips_CODE,
   --         @Ld_Low_DATE AS BeginValidity_DATE,
   --         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
   --         dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
   --         @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
   --         @Lc_Space_TEXT AS ReqPreOffset_CODE,
   --         @An_TaxYear_NUMB AS TaxYear_NUMB
   --    FROM FEDH_Y1 b,
   --         #FedhKey_P1 f
   --   WHERE b.MemberMci_IDNO = f.MemberMci_IDNO
   --     AND b.TypeArrear_CODE = f.TypeArrear_CODE
   --     AND b.TypeTransaction_CODE = f.TypeTransaction_CODE
   --     AND b.SubmitLast_DATE = f.SubmitLast_DATE
   --     AND b.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
   --     AND b.TaxYear_NUMB = f.TaxYear_NUMB
   --     AND b.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
   --     AND b.TypeArrear_CODE = @Lc_SequenceCur_TypeArrear_CODE
   --     AND b.TypeTransaction_CODE = @Lc_SequenceCur_TypeTransaction_CODE
   --     AND b.SubmitLast_DATE = @Ld_SequenceCur_SubmitLast_DATE
   --     AND b.TransactionEventSeq_NUMB = @Ln_SequenceCur_TransactionEventSeq_NUMB
   --     AND b.TaxYear_NUMB = @Ln_SequenceCur_TaxYear_NUMB;
   --  FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Lc_SequenceCur_TypeArrear_CODE, @Lc_SequenceCur_TypeTransaction_CODE, @Ld_SequenceCur_SubmitLast_DATE, @Ln_SequenceCur_TransactionEventSeq_NUMB, @Ln_SequenceCur_TaxYear_NUMB;
   --  SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- END;
   --CLOSE Sequence_CUR;
   --DEALLOCATE Sequence_CUR;
   --SET @Ls_Sql_TEXT = 'DELETE - RJDT_Y1 FOR B TRANS FOR 17';
   --SET @Ls_Sqldata_TEXT = 'TransactionType_CODE = ' + ISNULL('B', '') + ', TypeReject1_CODE = ' + ISNULL(@Lc_TypeTranAddCase_CODE, '');
   --UPDATE RJDT_Y1
   --   SET EndValidity_DATE = @Ad_Run_DATE,
   --       WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
   --       Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   -- WHERE TransactionType_CODE = 'B'
   --   AND TypeReject1_CODE = @Lc_TypeTranAddCase_CODE;
  /*
  Insert all the transactions records to EINCP_Y1 table
  */
   /*
   Process Year Need to be year tax +1 - Start
   */
   SET @Ls_Sqldata_TEXT = 'Table_ID = ' + ISNULL(@Lc_TableIdTaxi_CODE, '') + ', TableSub_ID = ' + ISNULL(@Lc_TableIdYear_CODE, '');
   SET @Ln_TaxYear_NUMB = @Ln_TaxYear_NUMB + 1
   SET @Ls_Sql_TEXT = 'DELETE - EINCP_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM EINCP_Y1;

   SET @Ls_Sql_TEXT = 'INSERT - EINCP_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO EINCP_Y1
               (StateSubmit_CODE,
                County_IDNO,
                MemberSsn_NUMB,
                Case_IDNO,
                Last_NAME,
                First_NAME,
                Arrears_AMNT,
                TypeTransaction_CODE,
                TypeCase_CODE,
                StateTransfer_CODE,
                LocalTransfer_CODE,
                ProcessYear_NUMB,
                Line1_ADDR,
                Line2_ADDR,
                City_ADDR,
                State_ADDR,
                Zip_ADDR,
                Issued_DATE,
                Exclusion_CODE,
                Request_CODE)
   SELECT @Lc_StateSubmitDE_CODE AS StateSubmit_CODE,
          MIN (CountyFips_CODE) AS County_IDNO,
          MemberSsn_NUMB,
          MIN(MemberMci_IDNO) AS Case_IDNO,
          MIN (Last_NAME) AS Last_NAME,
          MIN (LEFT(LTRIM(RTRIM(First_NAME)), 15)) AS First_NAME,
          SUBSTRING (CAST(SUM (Arrear_AMNT) AS VARCHAR), 1, 8) AS Arrears_AMNT,
          TypeTransaction_CODE,
          TypeArrear_CODE,
          @Lc_Space_TEXT AS StateTransfer_CODE,
          @Lc_Space_TEXT AS LocalTransfer_CODE,
          CASE
           WHEN TypeTransaction_CODE = @Lc_TypeTranStatePayment_CODE
            THEN TaxYear_NUMB + 1
           ELSE @Ln_TaxYear_NUMB
          END AS ProcessYear_NUMB,
          MIN(CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(Line1_ADDR, '')))) > 0
                THEN SUBSTRING(Line1_ADDR, 1, 30)
               ELSE @Lc_Space_TEXT
              END) AS Line1_ADDR,
          MIN(CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(Line2_ADDR, '')))) > 0
                THEN SUBSTRING(Line2_ADDR, 1, 30)
               ELSE @Lc_Space_TEXT
              END) AS Line2_ADDR,
          MIN(CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(City_ADDR, '')))) > 0
                THEN SUBSTRING(City_ADDR, 1, 25)
               ELSE @Lc_Space_TEXT
              END) AS City_ADDR,
          MIN(CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(State_ADDR, '')))) > 0
                THEN SUBSTRING(State_ADDR, 1, 2)
               ELSE @Lc_Space_TEXT
              END) AS State_ADDR,
          MIN(CASE
               WHEN LEN(LTRIM(RTRIM(ISNULL(Zip_ADDR, '')))) > 0
                THEN SUBSTRING(Zip_ADDR, 1, 9)
               ELSE @Lc_Space_TEXT
              END) AS Zip_ADDR,
          CASE
           WHEN TypeTransaction_CODE = 'A'
            THEN (ISNULL ((SELECT TOP 1 CONVERT(VARCHAR(8), MAX(CAST(A.Request_DTTM AS DATE)), 112)
                             FROM NRRQ_Y1 A,
                                  DEMO_Y1 B
                            WHERE B.MemberSsn_NUMB = S.MemberSsn_NUMB
                              AND A.Recipient_ID = RIGHT(('0000000000' + LTRIM(RTRIM(B.MemberMci_IDNO))), 10)
                              AND A.Notice_ID = 'ENF-24'), ISNULL ((SELECT TOP 1 CONVERT(VARCHAR(8), MIN(A.SubmitLast_DATE), 112)
                                                                      FROM FEDH_Y1 A,
                                                                           DEMO_Y1 B
                                                                     WHERE B.MemberSsn_NUMB = S.MemberSsn_NUMB
                                                                       AND A.MemberMci_IDNO = B.MemberMci_IDNO
                                                                       AND UPPER(LTRIM(RTRIM(A.WorkerUpdate_ID))) = 'CONVERSION'), ISNULL ((SELECT TOP 1 CONVERT(VARCHAR(8), MIN(A.SubmitLast_DATE), 112)
                                                                                                                                              FROM HFEDH_Y1 A,
                                                                                                                                                   DEMO_Y1 B
                                                                                                                                             WHERE B.MemberSsn_NUMB = S.MemberSsn_NUMB
                                                                                                                                               AND A.MemberMci_IDNO = B.MemberMci_IDNO
                                                                                                                                               AND UPPER(LTRIM(RTRIM(A.WorkerUpdate_ID))) = 'CONVERSION'), ' '))))
           ELSE ' '
          END AS Issued_DATE,
          CASE
           WHEN MIN (ExcludeAdm_CODE) = @Lc_No_INDC
            THEN @Lc_Space_TEXT
           ELSE @Lc_ExclusionsAdm_CODE
          END + CASE
                 WHEN MIN (ExcludeRet_CODE) = @Lc_No_INDC
                  THEN @Lc_Space_TEXT
                 ELSE @Lc_ExclusionsRet_CODE
                END + CASE
                       WHEN MIN (ExcludeVen_CODE) = @Lc_No_INDC
                        THEN @Lc_Space_TEXT
                       ELSE @Lc_ExclusionsVen_CODE
                      END + CASE
                             WHEN MIN (ExcludeSal_CODE) = @Lc_No_INDC
                              THEN @Lc_Space_TEXT
                             ELSE @Lc_ExclusionsSal_CODE
                            END + CASE
                                   WHEN MIN (ExcludeIrs_CODE) = @Lc_No_INDC
                                    THEN @Lc_Space_TEXT
                                   ELSE @Lc_ExclusionsTax_CODE
                                  END + CASE
                                         WHEN MIN (ExcludePas_CODE) = @Lc_No_INDC
                                          THEN @Lc_Space_TEXT
                                         ELSE @Lc_ExclusionsPas_CODE
                                        END + CASE
                                               WHEN MIN (ExcludeFin_CODE) = @Lc_No_INDC
                                                THEN @Lc_Space_TEXT
                                               ELSE @Lc_ExclusionsFin_CODE
                                              END + CASE
                                                     WHEN MIN (ExcludeDebt_CODE) = @Lc_No_INDC
                                                      THEN @Lc_Space_TEXT
                                                     ELSE @Lc_ExclusionsDck_CODE
                                                    END + CASE
                                                           WHEN MIN (ExcludeIns_CODE) = @Lc_No_INDC
                                                            THEN @Lc_Space_TEXT
                                                           ELSE @Lc_ExclusionsIns_CODE
                                                          END AS Exclusion_CODE,
          @Lc_RequestN_CODE AS Request_CODE
     FROM FEDH_Y1 s
    WHERE SubmitLast_DATE = @Ad_Run_DATE
    GROUP BY MemberSsn_NUMB,
             TypeTransaction_CODE,
             TypeArrear_CODE,
             TaxYear_NUMB;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('Local', 'FedhMember_CUR') IN (0, 1)
    BEGIN
     CLOSE FedhMember_CUR;

     DEALLOCATE FedhMember_CUR;
    END

   IF CURSOR_STATUS('Local', 'Sequence_CUR') IN (0, 1)
    BEGIN
     CLOSE Sequence_CUR;

     DEALLOCATE Sequence_CUR;
    END

   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
