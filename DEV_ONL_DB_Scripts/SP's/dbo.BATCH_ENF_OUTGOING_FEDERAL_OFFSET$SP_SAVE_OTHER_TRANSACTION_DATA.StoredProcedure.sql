/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_OTHER_TRANSACTION_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_OTHER_TRANSACTION_DATA 
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_OTHER_TRANSACTION_DATA is 
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_OTHER_TRANSACTION_DATA] (
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

  DECLARE @Lc_TypeTranModification_CODE      CHAR(1) = 'M',
          @Lc_TypeTranReplace_CODE           CHAR(1) = 'R',
          @Lc_TypeTranAddCase_CODE           CHAR(1) = 'A',
          @Lc_TypeTranName_CODE              CHAR(1) = 'B',
          @Lc_TypeTranCaseId_CODE            CHAR(1) = 'C',
          @Lc_TypeTranLocalCode_CODE         CHAR(1) = 'L',
          @Lc_TypeTranStatePayment_CODE      CHAR(1) = 'S',
          @Lc_TypeTranAddress_CODE           CHAR(1) = 'Z',
          @Lc_RecipientCpNcp_CODE            CHAR(1) = '1',
          @Lc_TypeTranX_CODE                 CHAR(1) = 'X',
          @Lc_TypeTranU_CODE                 CHAR(1) = 'U',
          @Lc_ActionU_CODE                   CHAR(1) = 'U',
          @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Lc_StatusReceiptRefund_CODE       CHAR(1) = 'R',
          @Lc_TypeCaseNontanf_CODE           CHAR(1) = 'N',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_StatusFailed_CODE              CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_SystemExclusion_CODE           CHAR(1) = 'S',
          @Lc_45Dys_CODE                     CHAR(2) = '45',
          @Lc_65Dys_CODE                     CHAR(2) = '65',
          @Lc_90Dys_CODE                     CHAR(2) = '90',
          @Lc_PreExclusionsLn_CODE           CHAR(2) = 'LN',
          @Lc_PreExclusionsFN_CODE           CHAR(2) = 'FN',
          @Lc_PreExclusionsAd_CODE           CHAR(2) = 'AD',
          @Lc_DisburseStatusCashed_CODE      CHAR(2) = 'CA',
          @Lc_DisburseStatusOutstanding_CODE CHAR(2) = 'OU',
          @Lc_DisburseStatusVoidReissue_CODE CHAR(2) = 'VR',
          @Lc_DisburseStatusVoidNoReis_CODE  CHAR(2) = 'VN',
          @Lc_DisburseStatusStopReissue_CODE CHAR(2) = 'SR',
          @Lc_DisburseStatusStopNoReis_CODE  CHAR(2) = 'SN',
          @Lc_SourceReceiptIr_CODE           CHAR(2) = 'IR',
          @Lc_SourceBatchIrs_CODE            CHAR(3) = 'IRS',
          @Lc_TransactionSrec_CODE           CHAR(4) = 'SREC',
          @Lc_TypeDisburseRefund_CODE        CHAR(5) = 'REFND',
          @Lc_Job_ID                         CHAR(7) = @Ac_Job_ID,
          @Lc_BatchRunUser_TEXT              CHAR(30) = 'BATCH',
          @Ls_Procedure_NAME                 VARCHAR(100) = 'SP_SAVE_OTHER_TRANSACTION_DATA',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE                       DATE = '01/01/0001',
          @Ld_Run_DATE                       DATE = @Ad_Run_DATE;
  DECLARE @Ln_Zero_NUMB                NUMERIC = 0,
          @Ln_TaxYear_NUMB             NUMERIC(4) = @An_TaxYear_NUMB,
          @Ln_EventFunctionalSeq_NUMB  NUMERIC(4) = 0,
          @Ln_Arrear_AMNT              NUMERIC(11, 2) = 0,
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
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ld_Min_DATE                 DATE;
  DECLARE @Ln_FedhMemberCur_TaxYear_NUMB     NUMERIC(4),
          @Ln_FedhMemberCur_MemberMci_IDNO   NUMERIC(10),
          @Ln_FedhMemberCur_Transaction_AMNT NUMERIC(11, 2),
          @Lc_FedhMemberCur_TypeArrear_CODE  CHAR(1);
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

  BEGIN TRY
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   ------------------------------------R Transaction Start---------------------------------------------------
   -- Select the record that only exclusion changes from FEDH table
   DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
    SELECT s.MemberMci_IDNO,
           s.MemberSsn_NUMB,
           s.TypeArrear_CODE,
           s.Last_NAME,
           s.First_NAME,
           s.Middle_NAME,
           s.ArrearIdentifier_IDNO,
           t.Arrear_AMNT,
           t.ExcludePas_CODE,
           t.ExcludeFin_CODE,
           t.ExcludeIrs_CODE,
           t.ExcludeAdm_CODE,
           t.ExcludeRet_CODE,
           t.ExcludeSal_CODE,
           t.ExcludeDebt_CODE,
           t.ExcludeVen_CODE,
           t.ExcludeIns_CODE,
           s.CountyFips_CODE,
           s.TaxYear_NUMB,
           s.TypeTransaction_CODE
      FROM (SELECT b.MemberMci_IDNO,
                   b.TypeArrear_CODE
              FROM (SELECT MemberMci_IDNO,
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
                      FROM IFMS_Y1
                     GROUP BY MemberMci_IDNO,
                              TypeArrear_CODE) c,
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
                     WHERE TypeTransaction_CODE = @Lc_TypeTranX_CODE
                     GROUP BY MemberMci_IDNO,
                              TypeArrear_CODE
                    HAVING SUM (Transaction_AMNT) > @Ln_Zero_NUMB) b
             WHERE b.MemberMci_IDNO = c.MemberMci_IDNO
               AND b.TypeArrear_CODE = c.TypeArrear_CODE
             GROUP BY b.MemberMci_IDNO,
                      b.TypeArrear_CODE
            HAVING CASE MIN (b.ExcludeIrs_CODE)
                    WHEN @Lc_Yes_INDC
                     THEN @Lc_SystemExclusion_CODE
                    ELSE MIN (b.ExcludeIrs_CODE)
                   END + CASE MIN (b.ExcludePas_CODE)
                          WHEN @Lc_Yes_INDC
                           THEN @Lc_SystemExclusion_CODE
                          ELSE MIN (b.ExcludePas_CODE)
                         END + CASE MIN (b.ExcludeFin_CODE)
                                WHEN @Lc_Yes_INDC
                                 THEN @Lc_SystemExclusion_CODE
                                ELSE MIN (b.ExcludeFin_CODE)
                               END + CASE MIN (b.ExcludeAdm_CODE)
                                      WHEN @Lc_Yes_INDC
                                       THEN @Lc_SystemExclusion_CODE
                                      ELSE MIN (b.ExcludeAdm_CODE)
                                     END + CASE MIN (b.ExcludeRet_CODE)
                                            WHEN @Lc_Yes_INDC
                                             THEN @Lc_SystemExclusion_CODE
                                            ELSE MIN (b.ExcludeRet_CODE)
                                           END + CASE MIN (b.ExcludeSal_CODE)
                                                  WHEN @Lc_Yes_INDC
                                                   THEN @Lc_SystemExclusion_CODE
                                                  ELSE MIN (b.ExcludeSal_CODE)
                                                 END + CASE MIN (b.ExcludeVen_CODE)
                                                        WHEN @Lc_Yes_INDC
                                                         THEN @Lc_SystemExclusion_CODE
                                                        ELSE MIN (b.ExcludeVen_CODE)
                                                       END + CASE MIN (b.ExcludeIns_CODE)
                                                              WHEN @Lc_Yes_INDC
                                                               THEN @Lc_SystemExclusion_CODE
                                                              ELSE MIN (b.ExcludeIns_CODE)
                                                             END <> CASE MIN (c.ExcludeIrs_CODE)
                                                                     WHEN @Lc_Yes_INDC
                                                                      THEN @Lc_SystemExclusion_CODE
                                                                     ELSE MIN (c.ExcludeIrs_CODE)
                                                                    END + CASE MIN (c.ExcludePas_CODE)
                                                                           WHEN @Lc_Yes_INDC
                                                                            THEN @Lc_SystemExclusion_CODE
                                                                           ELSE MIN (c.ExcludePas_CODE)
                                                                          END + CASE MIN (c.ExcludeFin_CODE)
                                                                                 WHEN @Lc_Yes_INDC
                                                                                  THEN @Lc_SystemExclusion_CODE
                                                                                 ELSE MIN (c.ExcludeFin_CODE)
                                                                                END + CASE MIN (c.ExcludeAdm_CODE)
                                                                                       WHEN @Lc_Yes_INDC
                                                                                        THEN @Lc_SystemExclusion_CODE
                                                                                       ELSE MIN (c.ExcludeAdm_CODE)
                                                                                      END + CASE MIN (c.ExcludeRet_CODE)
                                                                                             WHEN @Lc_Yes_INDC
                                                                                              THEN @Lc_SystemExclusion_CODE
                                                                                             ELSE MIN (c.ExcludeRet_CODE)
                                                                                            END + CASE MIN (c.ExcludeSal_CODE)
                                                                                                   WHEN @Lc_Yes_INDC
                                                                                                    THEN @Lc_SystemExclusion_CODE
                                                                                                   ELSE MIN (c.ExcludeSal_CODE)
                                                                                                  END + CASE MIN (c.ExcludeVen_CODE)
                                                                                                         WHEN @Lc_Yes_INDC
                                                                                                          THEN @Lc_SystemExclusion_CODE
                                                                                                         ELSE MIN (c.ExcludeVen_CODE)
                                                                                                        END + CASE MIN (c.ExcludeIns_CODE)
                                                                                                               WHEN @Lc_Yes_INDC
                                                                                                                THEN @Lc_SystemExclusion_CODE
                                                                                                               ELSE MIN (c.ExcludeIns_CODE)
                                                                                                              END
                   AND ISNULL (MIN (b.ExcludeIrs_CODE), @Lc_Space_TEXT) > @Lc_Space_TEXT
                   AND ISNULL (MIN (c.ExcludeIrs_CODE), @Lc_Space_TEXT) > @Lc_Space_TEXT) x,
           (SELECT MemberMci_IDNO,
                   TypeArrear_CODE,
                   SUM (Transaction_AMNT) Arrear_AMNT,
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
             WHERE TypeTransaction_CODE = @Lc_TypeTranX_CODE
             GROUP BY MemberMci_IDNO,
                      TypeArrear_CODE) t,
           FEDH_Y1 s
     WHERE x.MemberMci_IDNO = s.MemberMci_IDNO
       AND x.TypeArrear_CODE = s.TypeArrear_CODE
       AND t.MemberMci_IDNO = s.MemberMci_IDNO
       AND t.TypeArrear_CODE = s.TypeArrear_CODE
       AND s.TypeTransaction_CODE IN (@Lc_TypeTranAddCase_CODE, @Lc_TypeTranModification_CODE)
       AND NOT EXISTS(SELECT 1
                        FROM FEDH_Y1 X
                       WHERE X.MemberMci_IDNO = s.MemberMci_IDNO
                         AND X.TypeArrear_CODE = s.TypeArrear_CODE
                         AND X.TypeTransaction_CODE = 'R')
       AND s.SubmitLast_DATE < @Ad_Run_DATE;

   OPEN Sequence_CUR;

   FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE, @Ln_SequenceCur_TaxYear_NUMB, @Lc_SequenceCur_TypeTransaction_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE (@Li_FetchStatus_QNTY = 0)
    BEGIN
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
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranReplace_CODE, '') + ', Last_NAME = ' + ISNULL(@Ls_SequenceCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Ls_SequenceCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Ls_SequenceCur_Middle_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearIdentifier_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_ArrearIdentifier_IDNO AS VARCHAR), '') + ', Arrear_AMNT = ' + ISNULL(CAST(@Ln_SequenceCur_Arrear_AMNT AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludePas_CODE, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeFin_CODE, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIrs_CODE, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeAdm_CODE, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeRet_CODE, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeSal_CODE, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeDebt_CODE, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeVen_CODE, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIns_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_SequenceCur_Fips_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_TaxYear_NUMB AS VARCHAR), '');

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
            @Lc_TypeTranReplace_CODE AS TypeTransaction_CODE,
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
            @Ln_TaxYear_NUMB AS TaxYear_NUMB

     /*
     What the below statment do means , In validation part we mark it some of the records that dose not
     statisfy the minimum arrears differnce ($25) is "X". But those recors it may change only exclusions
     only because of that we are updating below statment.
     
     */
     SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
     SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranX_CODE, '');

     UPDATE PIFMS_Y1
        SET TypeTransaction_CODE = @Lc_TypeTranU_CODE
       FROM PIFMS_Y1 a
      WHERE a.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
        AND a.TypeArrear_CODE = @Lc_SequenceCur_TypeArrear_CODE
        AND a.TypeTransaction_CODE = @Lc_TypeTranX_CODE

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE, @Ln_SequenceCur_TaxYear_NUMB, @Lc_SequenceCur_TypeTransaction_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   /*
   Insert FEDH for R Transaction along with M Transaction
   */
   DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
    SELECT c.MemberMci_IDNO,
           c.MemberSsn_NUMB,
           c.TypeArrear_CODE,
           c.Last_NAME,
           c.First_NAME,
           c.Middle_NAME,
           c.ArrearIdentifier_IDNO,
           c.Arrear_AMNT,
           c.ExcludePas_CODE,
           c.ExcludeFin_CODE,
           c.ExcludeIrs_CODE,
           c.ExcludeAdm_CODE,
           c.ExcludeRet_CODE,
           c.ExcludeSal_CODE,
           c.ExcludeDebt_CODE,
           c.ExcludeVen_CODE,
           c.ExcludeIns_CODE,
           c.CountyFips_CODE,
           c.TaxYear_NUMB,
           c.TypeTransaction_CODE
      FROM (SELECT a.MemberMci_IDNO,
                   a.MemberSsn_NUMB,
                   a.TypeArrear_CODE,
                   a.Last_NAME,
                   a.First_NAME,
                   a.Middle_NAME,
                   a.ArrearIdentifier_IDNO,
                   a.Arrear_AMNT,
                   a.ExcludePas_CODE,
                   a.ExcludeFin_CODE,
                   a.ExcludeIrs_CODE,
                   a.ExcludeAdm_CODE,
                   a.ExcludeRet_CODE,
                   a.ExcludeSal_CODE,
                   a.ExcludeDebt_CODE,
                   a.ExcludeVen_CODE,
                   a.ExcludeIns_CODE,
                   a.CountyFips_CODE,
                   a.TaxYear_NUMB,
                   TypeTransaction_CODE
              FROM FEDH_Y1 a
             WHERE EXISTS(SELECT b.MemberMci_IDNO,
                                 b.TypeArrear_CODE
                            FROM (SELECT MemberMci_IDNO,
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
                                    FROM (SELECT MemberMci_IDNO,
                                                 TypeArrear_CODE,
                                                 ExcludeIrs_CODE,
                                                 ExcludePas_CODE,
                                                 ExcludeFin_CODE,
                                                 ExcludeAdm_CODE,
                                                 ExcludeRet_CODE,
                                                 ExcludeSal_CODE,
                                                 ExcludeVen_CODE,
                                                 ExcludeDebt_CODE,
                                                 ExcludeIns_CODE,
                                                 RANK () OVER (PARTITION BY MemberMci_IDNO, TypeArrear_CODE ORDER BY SubmitLast_DATE DESC) rank_num
                                            FROM IFMS_Y1)z
                                   WHERE rank_num = 1
                                   GROUP BY MemberMci_IDNO,
                                            TypeArrear_CODE) c,
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
                                   WHERE TypeTransaction_CODE < @Lc_TypeTranX_CODE
                                   GROUP BY MemberMci_IDNO,
                                            TypeArrear_CODE) b
                           WHERE b.MemberMci_IDNO = c.MemberMci_IDNO
                             AND b.TypeArrear_CODE = c.TypeArrear_CODE
                             AND b. MemberMci_IDNO = a.MemberMci_IDNO
                             AND b.TypeArrear_CODE = a.TypeArrear_CODE
                           GROUP BY b.MemberMci_IDNO,
                                    b.TypeArrear_CODE
                          HAVING CASE MIN (b.ExcludeIrs_CODE)
                                  WHEN @Lc_Yes_INDC
                                   THEN @Lc_SystemExclusion_CODE
                                  ELSE MIN (b.ExcludeIrs_CODE)
                                 END + CASE MIN (b.ExcludePas_CODE)
                                        WHEN @Lc_Yes_INDC
                                         THEN @Lc_SystemExclusion_CODE
                                        ELSE MIN (b.ExcludePas_CODE)
                                       END + CASE MIN (b.ExcludeFin_CODE)
                                              WHEN @Lc_Yes_INDC
                                               THEN @Lc_SystemExclusion_CODE
                                              ELSE MIN (b.ExcludeFin_CODE)
                                             END + CASE MIN (b.ExcludeAdm_CODE)
                                                    WHEN @Lc_Yes_INDC
                                                     THEN @Lc_SystemExclusion_CODE
                                                    ELSE MIN (b.ExcludeAdm_CODE)
                                                   END + CASE MIN (b.ExcludeRet_CODE)
                                                          WHEN @Lc_Yes_INDC
                                                           THEN @Lc_SystemExclusion_CODE
                                                          ELSE MIN (b.ExcludeRet_CODE)
                                                         END + CASE MIN (b.ExcludeSal_CODE)
                                                                WHEN @Lc_Yes_INDC
                                                                 THEN @Lc_SystemExclusion_CODE
                                                                ELSE MIN (b.ExcludeSal_CODE)
                                                               END + CASE MIN (b.ExcludeVen_CODE)
                                                                      WHEN @Lc_Yes_INDC
                                                                       THEN @Lc_SystemExclusion_CODE
                                                                      ELSE MIN (b.ExcludeVen_CODE)
                                                                     END + CASE MIN (b.ExcludeIns_CODE)
                                                                            WHEN @Lc_Yes_INDC
                                                                             THEN @Lc_SystemExclusion_CODE
                                                                            ELSE MIN (b.ExcludeIns_CODE)
                                                                           END <> CASE MIN (c.ExcludeIrs_CODE)
                                                                                   WHEN @Lc_Yes_INDC
                                                                                    THEN @Lc_SystemExclusion_CODE
                                                                                   ELSE MIN (c.ExcludeIrs_CODE)
                                                                                  END + CASE MIN (c.ExcludePas_CODE)
                                                                                         WHEN @Lc_Yes_INDC
                                                                                          THEN @Lc_SystemExclusion_CODE
                                                                                         ELSE MIN (c.ExcludePas_CODE)
                                                                                        END + CASE MIN (c.ExcludeFin_CODE)
                                                                                               WHEN @Lc_Yes_INDC
                                                                                                THEN @Lc_SystemExclusion_CODE
                                                                                               ELSE MIN (c.ExcludeFin_CODE)
                                                                                              END + CASE MIN (c.ExcludeAdm_CODE)
                                                                                                     WHEN @Lc_Yes_INDC
                                                                                                      THEN @Lc_SystemExclusion_CODE
                                                                                                     ELSE MIN (c.ExcludeAdm_CODE)
                                                                                                    END + CASE MIN (c.ExcludeRet_CODE)
                                                                                                           WHEN @Lc_Yes_INDC
                                                                                                            THEN @Lc_SystemExclusion_CODE
                                                                                                           ELSE MIN (c.ExcludeRet_CODE)
                                                                                                          END + CASE MIN (c.ExcludeSal_CODE)
                                                                                                                 WHEN @Lc_Yes_INDC
                                                                                                                  THEN @Lc_SystemExclusion_CODE
                                                                                                                 ELSE MIN (c.ExcludeSal_CODE)
                                                                                                                END + CASE MIN (c.ExcludeVen_CODE)
                                                                                                                       WHEN @Lc_Yes_INDC
                                                                                                                        THEN @Lc_SystemExclusion_CODE
                                                                                                                       ELSE MIN (c.ExcludeVen_CODE)
                                                                                                                      END + CASE MIN (c.ExcludeIns_CODE)
                                                                                                                             WHEN @Lc_Yes_INDC
                                                                                                                              THEN @Lc_SystemExclusion_CODE
                                                                                                                             ELSE MIN (c.ExcludeIns_CODE)
                                                                                                                            END)
               AND a.TypeTransaction_CODE = @Lc_TypeTranModification_CODE
               AND a.SubmitLast_DATE = @Ad_Run_DATE
               AND NOT EXISTS(SELECT 1
                                FROM FEDH_Y1 X
                               WHERE X.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND X.TypeArrear_CODE = a.TypeArrear_CODE
                                 AND X.TypeTransaction_CODE = 'R')) c
     ORDER BY c.MemberMci_IDNO,
              c.TypeArrear_CODE,
              c.TypeTransaction_CODE;

   OPEN Sequence_CUR;

   FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE, @Ln_SequenceCur_TaxYear_NUMB, @Lc_SequenceCur_TypeTransaction_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE (@Li_FetchStatus_QNTY = 0)
    BEGIN
     -- Insert FEDH for R Transaction along with M Transaction
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
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranReplace_CODE, '') + ', Last_NAME = ' + ISNULL(@Ls_SequenceCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Ls_SequenceCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Ls_SequenceCur_Middle_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearIdentifier_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_ArrearIdentifier_IDNO AS VARCHAR), '') + ', Arrear_AMNT = ' + ISNULL(CAST(@Ln_SequenceCur_Arrear_AMNT AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludePas_CODE, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeFin_CODE, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIrs_CODE, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeAdm_CODE, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeRet_CODE, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeSal_CODE, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeDebt_CODE, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeVen_CODE, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIns_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_SequenceCur_Fips_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_TaxYear_NUMB AS VARCHAR), '');

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
            @Lc_TypeTranReplace_CODE AS TypeTransaction_CODE,
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
            @Ln_TaxYear_NUMB AS TaxYear_NUMB

     SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
     SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranX_CODE, '');

     UPDATE PIFMS_Y1
        SET TypeTransaction_CODE = @Lc_TypeTranU_CODE
       FROM PIFMS_Y1 a
      WHERE a.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
        AND a.TypeArrear_CODE = @Lc_SequenceCur_TypeArrear_CODE
        AND a.TypeTransaction_CODE = @Lc_TypeTranX_CODE

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE, @Ln_SequenceCur_TaxYear_NUMB, @Lc_SequenceCur_TypeTransaction_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   ----------------------------------------R Transaction END----------------------------------------------------
   ----------------------------------------B Transaction Start--------------------------------------------------
   /*
   Name Change Transaction Process.
   Insert the B transaction records to FEDH_Y1 if member name changed
   */
   DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
    SELECT c.MemberMci_IDNO,
           c.MemberSsn_NUMB,
           c.TypeArrear_CODE,
           REPLACE(c.Last_NAME, '''', '') AS Last_NAME,
           c.First_NAME,
           c.Middle_NAME,
           c.ArrearIdentifier_IDNO,
           c.Arrear_AMNT,
           c.ExcludePas_CODE,
           c.ExcludeFin_CODE,
           c.ExcludeIrs_CODE,
           c.ExcludeAdm_CODE,
           c.ExcludeRet_CODE,
           c.ExcludeSal_CODE,
           c.ExcludeDebt_CODE,
           c.ExcludeVen_CODE,
           c.ExcludeIns_CODE,
           c.CountyFips_CODE,
           c.TaxYear_NUMB
      FROM (SELECT DISTINCT
                   b.MemberMci_IDNO,
                   b.MemberSsn_NUMB,
                   b.TypeArrear_CODE,
                   b.Last_NAME,
                   b.First_NAME,
                   b.Middle_NAME,
                   a.ArrearIdentifier_IDNO,
                   a.Arrear_AMNT,
                   b.ExcludePas_CODE,
                   b.ExcludeFin_CODE,
                   b.ExcludeIrs_CODE,
                   b.ExcludeAdm_CODE,
                   b.ExcludeRet_CODE,
                   b.ExcludeSal_CODE,
                   b.ExcludeDebt_CODE,
                   b.ExcludeVen_CODE,
                   b.ExcludeIns_CODE,
                   a.CountyFips_CODE,
                   a.TaxYear_NUMB
              FROM FEDH_Y1 a,
                   (SELECT b.MemberMci_IDNO,
                           b.MemberSsn_NUMB,
                           b.Last_NAME,
                           b.First_NAME,
                           b.Middle_NAME,
                           b.TypeArrear_CODE,
                           SUM (b.Transaction_AMNT) Transaction_AMNT,
                           MIN (b.ExcludeIrs_CODE) ExcludeIrs_CODE,
                           MIN (b.ExcludePas_CODE) ExcludePas_CODE,
                           MIN (b.ExcludeFin_CODE) ExcludeFin_CODE,
                           MIN (b.ExcludeAdm_CODE) ExcludeAdm_CODE,
                           MIN (b.ExcludeRet_CODE) ExcludeRet_CODE,
                           MIN (b.ExcludeSal_CODE) ExcludeSal_CODE,
                           MIN (b.ExcludeVen_CODE) ExcludeVen_CODE,
                           MIN (b.ExcludeDebt_CODE) ExcludeDebt_CODE,
                           MIN (b.ExcludeIns_CODE) ExcludeIns_CODE
                      FROM PIFMS_Y1 b
                     WHERE EXISTS (SELECT 1
                                     FROM IFMS_Y1 c
                                    WHERE c.MemberMci_IDNO = b.MemberMci_IDNO
                                      AND c.TypeArrear_CODE = b.TypeArrear_CODE
                                      AND c.SubmitLast_DATE = (SELECT MAX(SubmitLast_DATE)
                                                                 FROM IFMS_Y1 d
                                                                WHERE d.MemberMci_IDNO = c.MemberMci_IDNO
                                                                  AND d.TypeArrear_CODE = c.TypeArrear_CODE)
                                      AND NOT EXISTS(SELECT 1
                                                       FROM PIFMS_Y1 e
                                                      WHERE e.MemberMci_IDNO = c.MemberMci_IDNO
                                                        AND REPLACE(e.Last_NAME, '''', '') = REPLACE(c.Last_NAME, '''', '')
                                                        AND e.First_NAME = c.First_NAME))
                     GROUP BY b.MemberMci_IDNO,
                              b.MemberSsn_NUMB,
                              b.TypeArrear_CODE,
                              b.Last_NAME,
                              b.First_NAME,
                              b.Middle_NAME) b
             WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
               AND a.TypeArrear_CODE = b.TypeArrear_CODE) c
     ORDER BY c.MemberMci_IDNO,
              c.MemberSsn_NUMB,
              c.TypeArrear_CODE;

   OPEN Sequence_CUR;

   FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE, @Ln_SequenceCur_TaxYear_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE (@Li_FetchStatus_QNTY = 0)
    BEGIN
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
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranName_CODE, '') + ', Last_NAME = ' + ISNULL(@Ls_SequenceCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Ls_SequenceCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Ls_SequenceCur_Middle_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearIdentifier_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_ArrearIdentifier_IDNO AS VARCHAR), '') + ', Arrear_AMNT = ' + ISNULL(CAST(@Ln_SequenceCur_Arrear_AMNT AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludePas_CODE, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeFin_CODE, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIrs_CODE, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeAdm_CODE, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeRet_CODE, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeSal_CODE, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeDebt_CODE, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeVen_CODE, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIns_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_SequenceCur_Fips_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_TaxYear_NUMB AS VARCHAR), '');

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
            @Lc_TypeTranName_CODE AS TypeTransaction_CODE,
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
            @Ln_TaxYear_NUMB AS TaxYear_NUMB

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE, @Ln_SequenceCur_TaxYear_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   SET @Ls_Sql_TEXT = 'SELECT - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                Last_NAME,
                First_NAME,
                Middle_NAME)
   SELECT MemberMci_IDNO,
          REPLACE(Last_NAME, '''', '') AS Last_NAME,
          First_NAME,
          Middle_NAME
     FROM (SELECT MemberMci_IDNO,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  ROW_NUMBER () OVER (PARTITION BY MemberMci_IDNO ORDER BY arrear DESC) seq
             FROM (SELECT a.MemberMci_IDNO,
                          MIN (a.Last_NAME) Last_NAME,
                          MIN (a.First_NAME) First_NAME,
                          MIN (a.Middle_NAME) Middle_NAME,
                          SUM (a.Transaction_AMNT) arrear
                     FROM PIFMS_Y1 a,
                          (SELECT DISTINCT
                                  MemberMci_IDNO
                             FROM FEDH_Y1
                            WHERE TypeTransaction_CODE = @Lc_TypeTranName_CODE
                              AND SubmitLast_DATE = @Ad_Run_DATE) x
                    WHERE a.MemberMci_IDNO = x.MemberMci_IDNO
                      AND (ASCII (UPPER (SUBSTRING (a.First_NAME, 1, 1))) BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
                            OR ASCII (UPPER (SUBSTRING (a.First_NAME, 1, 1))) = @Lc_45Dys_CODE)
                      AND (ASCII (UPPER (SUBSTRING (a.Last_NAME, 1, 1))) BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
                            OR ASCII (UPPER (SUBSTRING (a.Last_NAME, 1, 1))) = @Lc_45Dys_CODE)
                      AND (ASCII (UPPER (SUBSTRING (a.Last_NAME, 2, 1))) BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
                            OR ASCII (UPPER (SUBSTRING (a.Last_NAME, 2, 1))) = @Lc_45Dys_CODE)
                      AND (ASCII (UPPER (SUBSTRING (a.Last_NAME, 3, 1))) BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
                            OR ASCII (UPPER (SUBSTRING (a.Last_NAME, 3, 1))) = @Lc_45Dys_CODE)
                      AND (ASCII (UPPER (SUBSTRING (a.Last_NAME, 4, 1))) BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
                            OR ASCII (UPPER (SUBSTRING (a.Last_NAME, 4, 1))) = @Lc_45Dys_CODE)
                    GROUP BY a.MemberMci_IDNO) s) y
    WHERE y.seq = 1;

   SET @Ls_Sql_TEXT = 'UPDATE PIFMS FOR NAME CHANGE TRANSACTION';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE a
      SET Last_NAME = f.Last_NAME,
          First_NAME = f.First_NAME,
          Middle_NAME = f.Middle_NAME
     FROM PIFMS_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'UPDATE FEDH FOR NAME CHANGE TRANSACTION';
   SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranName_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   UPDATE a
      SET Last_NAME = f.Last_NAME,
          First_NAME = f.First_NAME,
          Middle_NAME = f.Middle_NAME
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
      AND a.TypeTransaction_CODE = @Lc_TypeTranName_CODE
      AND a.SubmitLast_DATE = @Ad_Run_DATE
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   SET @Ls_Sql_TEXT = 'SELECT - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB)
   SELECT b.MemberMci_IDNO,
          b.TypeArrear_CODE,
          b.TypeTransaction_CODE,
          b.SubmitLast_DATE,
          b.TransactionEventSeq_NUMB,
          b.TaxYear_NUMB
     FROM FEDH_Y1 b
    WHERE b.TypeTransaction_CODE = @Lc_TypeTranName_CODE
      AND b.SubmitLast_DATE = @Ad_Run_DATE
      AND ((ASCII (UPPER (SUBSTRING (b.Last_NAME, 1, 1))) NOT BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
            AND ASCII (UPPER (SUBSTRING (b.Last_NAME, 1, 1))) <> @Lc_45Dys_CODE)
            OR (ASCII (UPPER (SUBSTRING (b.Last_NAME, 2, 1))) NOT BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
                AND ASCII (UPPER (SUBSTRING (b.Last_NAME, 2, 1))) <> @Lc_45Dys_CODE)
            OR (ASCII (UPPER (SUBSTRING (b.Last_NAME, 3, 1))) NOT BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
                AND ASCII (UPPER (SUBSTRING (b.Last_NAME, 3, 1))) <> @Lc_45Dys_CODE)
            OR (ASCII (UPPER (SUBSTRING (b.Last_NAME, 4, 1))) NOT BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
                AND ASCII (UPPER (SUBSTRING (b.Last_NAME, 4, 1))) <> @Lc_45Dys_CODE));

   SET @Ls_Sql_TEXT = 'UPDATE - IRSA_Y1';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE IRSA_Y1
      SET PreEdit_CODE = @Lc_PreExclusionsLn_CODE
     FROM IRSA_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'DELETE - FEDH_Y1';
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

   SET @Ls_Sql_TEXT = 'SELECT - FEDH_Y1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB)
   SELECT b.MemberMci_IDNO,
          b.TypeArrear_CODE,
          b.TypeTransaction_CODE,
          b.SubmitLast_DATE,
          b.TransactionEventSeq_NUMB,
          b.TaxYear_NUMB
     FROM FEDH_Y1 b
    WHERE b.TypeTransaction_CODE = @Lc_TypeTranName_CODE
      AND b.SubmitLast_DATE = @Ad_Run_DATE
      AND (ASCII (UPPER (SUBSTRING (b.First_NAME, 1, 1))) NOT BETWEEN @Lc_65Dys_CODE AND @Lc_90Dys_CODE
           AND ASCII (UPPER (SUBSTRING (b.First_NAME, 1, 1))) <> @Lc_45Dys_CODE);

   SET @Ls_Sql_TEXT = 'UPDATE _ IRSA_Y1';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE IRSA_Y1
      SET PreEdit_CODE = @Lc_PreExclusionsFN_CODE
     FROM IRSA_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'DELETE FEDH';
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

   SET @Ls_Sql_TEXT = 'UPDATE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranName_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranX_CODE, '');

   UPDATE PIFMS_Y1
      SET TypeTransaction_CODE = @Lc_TypeTranU_CODE
     FROM PIFMS_Y1 a
    WHERE EXISTS (SELECT 1
                    FROM FEDH_Y1 b
                   WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                     AND b.TypeArrear_CODE = a.TypeArrear_CODE
                     AND b.TypeTransaction_CODE = @Lc_TypeTranName_CODE
                     AND b.SubmitLast_DATE = @Ad_Run_DATE)
      AND a.TypeTransaction_CODE = @Lc_TypeTranX_CODE

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   ---------------------------------B Transaction End-------------------------------------------------
   ---------------------------------Z Transaction start-----------------------------------------------
   /*
   We have to submit the current verified good address if the address that was last sent is different
   */
   DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           F.MemberMci_IDNO,
           F.MemberSsn_NUMB,
           F.TypeArrear_CODE,
           F.Last_NAME,
           F.First_NAME,
           F.Middle_NAME,
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
            HAVING SUM(ISNULL(a.Transaction_AMNT, 0)) > 0) G
           LEFT OUTER JOIN FEDH_Y1 H
            ON H.MemberMci_IDNO = G.MemberMci_IDNO
               AND H.TypeArrear_CODE = G.TypeArrear_CODE
               AND (
               (H.TypeTransaction_CODE = 'A'
               AND H.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                          FROM FEDH_Y1 X
                                         WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
                                           AND X.TypeArrear_CODE = H.TypeArrear_CODE
                                           AND X.TypeTransaction_CODE = 'A'
                                           AND X.SubmitLast_DATE < @Ad_Run_DATE)
               AND H.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                          FROM FEDH_Y1 X
                                         WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
                                           AND X.TypeArrear_CODE = H.TypeArrear_CODE
                                           AND X.TypeTransaction_CODE = 'A'
                                           AND X.SubmitLast_DATE < @Ad_Run_DATE
                                           AND X.SubmitLast_DATE = H.SubmitLast_DATE))
                     OR (H.TypeTransaction_CODE = 'M'
                         AND UPPER(LTRIM(RTRIM(H.WorkerUpdate_ID))) = 'CONVERSION'))
           LEFT OUTER JOIN HFEDH_Y1 I
            ON I.MemberMci_IDNO = G.MemberMci_IDNO
               AND I.TypeArrear_CODE = G.TypeArrear_CODE
               AND (
               (I.TypeTransaction_CODE = 'A'
               AND I.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                          FROM HFEDH_Y1 X
                                         WHERE X.MemberMci_IDNO = I.MemberMci_IDNO
                                           AND X.TypeArrear_CODE = I.TypeArrear_CODE
                                           AND X.TypeTransaction_CODE = 'A'
                                           AND X.SubmitLast_DATE < @Ad_Run_DATE)
               AND I.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                          FROM HFEDH_Y1 X
                                         WHERE X.MemberMci_IDNO = I.MemberMci_IDNO
                                           AND X.TypeArrear_CODE = I.TypeArrear_CODE
                                           AND X.TypeTransaction_CODE = 'A'
                                           AND X.SubmitLast_DATE < @Ad_Run_DATE
                                           AND X.SubmitLast_DATE = I.SubmitLast_DATE))
                     OR (I.TypeTransaction_CODE = 'M'
                         AND UPPER(LTRIM(RTRIM(I.WorkerUpdate_ID))) = 'CONVERSION'))
     WHERE G.MemberMci_IDNO = F.MemberMci_IDNO
       AND G.TypeArrear_CODE = F.TypeArrear_CODE
       AND EXISTS (SELECT 1
                     FROM (SELECT x.MemberMci_IDNO,
                                  x.Line1_ADDR,
                                  x.Line2_ADDR,
                                  x.City_ADDR,
                                  x.State_ADDR,
                                  x.Zip_ADDR,
                                  x.Country_ADDR
                             FROM (
                                  --SELECT a.MemberMci_IDNO,
                                  --             UPPER (a.Line1_ADDR) AS Line1_ADDR,
                                  --             UPPER (a.Line2_ADDR) AS Line2_ADDR,
                                  --             UPPER (a.City_ADDR) AS City_ADDR,
                                  --             UPPER (a.State_ADDR) AS State_ADDR,
                                  --             a.Zip_ADDR AS Zip_ADDR,
                                  --             UPPER (a.Country_ADDR) AS Country_ADDR,
                                  --             ROW_NUMBER () OVER ( PARTITION BY a.MemberMci_IDNO ORDER BY a.Status_CODE DESC, a.TypeAddress_CODE, a.End_DATE DESC) AS Row_NUMB
                                  --        FROM AHIS_Y1 a
                                  --       WHERE a.MemberMci_IDNO = H.MemberMci_IDNO
                                  --         AND a.TypeAddress_CODE IN ('M', 'R')
                                  --         AND a.Status_CODE IN ('Y')
                                  --         AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                  SELECT Row_NUMB = ROW_NUMBER() OVER (PARTITION BY Y.MemberMci_IDNO ORDER BY Y.Priority_NUMB, Y.End_DATE DESC),
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
                                            WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
                                              AND X.TypeAddress_CODE IN ('M', 'R', 'C')
                                              AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                                              AND X.Status_CODE = 'Y') Y) AS x
                            WHERE x.Row_NUMB = 1) e
                    WHERE e.MemberMci_IDNO = H.MemberMci_IDNO
                      AND ((LEN(LTRIM(RTRIM(ISNULL(e.Line1_ADDR, '')))) > 0
                            AND UPPER(e.Line1_ADDR) <> UPPER(ISNULL(H.Line1_ADDR, ISNULL(I.Line1_ADDR, ''))))
                            OR (LEN(LTRIM(RTRIM(ISNULL(e.Line2_ADDR, '')))) > 0
                                AND UPPER(e.Line2_ADDR) <> UPPER(ISNULL(H.Line2_ADDR, ISNULL(I.Line2_ADDR, ''))))
                            OR (LEN(LTRIM(RTRIM(ISNULL(e.City_ADDR, '')))) > 0
                                AND UPPER(e.City_ADDR) <> UPPER(ISNULL(H.City_ADDR, ISNULL(I.City_ADDR, ''))))
                            OR (LEN(LTRIM(RTRIM(ISNULL(e.State_ADDR, '')))) > 0
                                AND UPPER(e.State_ADDR) <> UPPER(ISNULL(H.State_ADDR, ISNULL(I.State_ADDR, ''))))
                            OR (LEN(LTRIM(RTRIM(ISNULL(e.Zip_ADDR, '')))) > 0
                                AND UPPER(e.Zip_ADDR) <> UPPER(ISNULL(H.Zip_ADDR, ISNULL(I.Zip_ADDR, ''))))))

   OPEN Sequence_CUR;

   FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE (@Li_FetchStatus_QNTY = 0)
    BEGIN
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
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_SequenceCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranAddress_CODE, '') + ', Last_NAME = ' + ISNULL(@Ls_SequenceCur_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Ls_SequenceCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Ls_SequenceCur_Middle_NAME, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearIdentifier_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_ArrearIdentifier_IDNO AS VARCHAR), '') + ', Arrear_AMNT = ' + ISNULL(CAST(@Ln_SequenceCur_Arrear_AMNT AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludePas_CODE, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeFin_CODE, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIrs_CODE, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeAdm_CODE, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeRet_CODE, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeSal_CODE, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeDebt_CODE, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeVen_CODE, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_SequenceCur_ExcludeIns_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_SequenceCur_Fips_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_TaxYear_NUMB AS VARCHAR), '');

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
            @Lc_TypeTranAddress_CODE AS TypeTransaction_CODE,
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
            @Ln_TaxYear_NUMB AS TaxYear_NUMB

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_MemberSsn_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ls_SequenceCur_Last_NAME, @Ls_SequenceCur_First_NAME, @Ls_SequenceCur_Middle_NAME, @Ln_SequenceCur_ArrearIdentifier_IDNO, @Ln_SequenceCur_Arrear_AMNT, @Lc_SequenceCur_ExcludePas_CODE, @Lc_SequenceCur_ExcludeFin_CODE, @Lc_SequenceCur_ExcludeIrs_CODE, @Lc_SequenceCur_ExcludeAdm_CODE, @Lc_SequenceCur_ExcludeRet_CODE, @Lc_SequenceCur_ExcludeSal_CODE, @Lc_SequenceCur_ExcludeDebt_CODE, @Lc_SequenceCur_ExcludeVen_CODE, @Lc_SequenceCur_ExcludeIns_CODE, @Lc_SequenceCur_Fips_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   SET @Ls_Sql_TEXT = 'SELECT  - FEDH';

   DECLARE FedhMember_CUR INSENSITIVE CURSOR FOR
    SELECT MemberMci_IDNO
      FROM FEDH_Y1 a
     WHERE TypeTransaction_CODE = @Lc_TypeTranAddress_CODE
       AND RejectInd_INDC = @Lc_No_INDC
       AND SubmitLast_DATE = @Ad_Run_DATE
       --AND dbo.BATCH_COMMON$SF_GET_ADDRESS (a.MemberMci_IDNO, @Ad_Run_DATE) = @Lc_Yes_INDC;
       AND EXISTS(SELECT 1
                    FROM AHIS_Y1 X
                   WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                     AND X.TypeAddress_CODE IN ('M', 'R', 'C')
                     AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                     AND X.Status_CODE = 'Y')

   SET @Ls_Sql_TEXT = 'Open FedhMember_CUR -2';

   OPEN FedhMember_CUR;

   SET @Ls_Sql_TEXT = 'FETCH FedhMember_CUR-3';

   FETCH NEXT FROM FedhMember_CUR INTO @Ln_FedhMemberCur_MemberMci_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'While loop 2';

   --loop through
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     --SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ADDRESS';
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
     --SET @Ls_Sql_TEXT = 'UPDATE  - FEDH';
     --SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FedhMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranAddress_CODE, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '');
     --UPDATE a
     --   SET a.Line1_ADDR = SUBSTRING (@Ls_Line1_ADDR, 1, 30),
     --       a.Line2_ADDR = SUBSTRING (@Ls_Line2_ADDR, 1, 30),
     --       a.City_ADDR = SUBSTRING (@Lc_City_ADDR, 1, 25),
     --       a.State_ADDR = @Lc_State_ADDR,
     --       a.Zip_ADDR = SUBSTRING (@Lc_Zip_ADDR, 1, 9)
     --  FROM FEDH_Y1 a
     --WHERE a.MemberMci_IDNO = @Ln_FedhMemberCur_MemberMci_IDNO
     --  AND a.TypeTransaction_CODE = @Lc_TypeTranAddress_CODE
     --  AND a.RejectInd_INDC = @Lc_No_INDC;
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
        AND A.TypeTransaction_CODE = @Lc_TypeTranAddress_CODE
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

   -- Select the Z transaction with the NULL address from FEDH_Y1 table
   SET @Ls_Sql_TEXT = 'SELECT - FEDH';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB)
   SELECT b.MemberMci_IDNO,
          b.TypeArrear_CODE,
          b.TypeTransaction_CODE,
          b.SubmitLast_DATE,
          b.TransactionEventSeq_NUMB,
          b.TaxYear_NUMB
     FROM FEDH_Y1 b
    WHERE b.TypeTransaction_CODE = @Lc_TypeTranAddress_CODE
      AND b.SubmitLast_DATE = @Ad_Run_DATE
      --AND dbo.BATCH_COMMON$SF_GET_ADDRESS (b.MemberMci_IDNO, @Ad_Run_DATE) = @Lc_No_INDC;
      AND NOT EXISTS(SELECT 1
                       FROM AHIS_Y1 X
                      WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                        AND X.TypeAddress_CODE IN ('M', 'R', 'C')
                        AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                        AND X.Status_CODE = 'Y')

   -- Delete those NULL address from FEDH_Y1 table fro Z transaction
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

   -- Update the IRSA_Y1 table for pre-submission exclusion as for "AD"
   SET @Ls_Sql_TEXT = 'UPDATE - IRSA_Y1';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE IRSA_Y1
      SET PreEdit_CODE = @Lc_PreExclusionsAd_CODE
     FROM IRSA_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   -----------------------------------Z Transaction End-----------------------------------------------
   SET @Ls_Sql_TEXT = 'SELECT - FEDH FOR B TRANS FOR 17';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                TypeArrear_CODE,
                TypeTransaction_CODE,
                SubmitLast_DATE,
                TransactionEventSeq_NUMB,
                TaxYear_NUMB)
   SELECT x.MemberMci_IDNO,
          x.TypeArrear_CODE,
          x.TypeTransaction_CODE,
          x.SubmitLast_DATE,
          x.TransactionEventSeq_NUMB,
          x.TaxYear_NUMB
     FROM (SELECT s.MemberMci_IDNO,
                  s.TypeArrear_CODE,
                  s.TypeTransaction_CODE,
                  s.SubmitLast_DATE,
                  s.TransactionEventSeq_NUMB,
                  s.TaxYear_NUMB,
                  ROW_NUMBER () OVER (PARTITION BY s.MemberMci_IDNO, s.TypeArrear_CODE ORDER BY s.SubmitLast_DATE DESC) seq
             FROM FEDH_Y1 s,
                  (SELECT DISTINCT
                          MemberMci_IDNO,
                          TypeArrear_CODE
                     FROM RJDT_Y1 r
                    WHERE r.TransactionType_CODE = 'B'
                      AND r.TypeReject1_CODE = @Lc_TypeTranAddCase_CODE
                      AND r.EndValidity_DATE = @Ld_High_DATE
                      AND NOT EXISTS (SELECT 1
                                        FROM FEDH_Y1 s
                                       WHERE s.MemberMci_IDNO = r.MemberMci_IDNO
                                         AND s.TypeArrear_CODE = r.TypeArrear_CODE
                                         AND s.TypeTransaction_CODE = @Lc_TypeTranName_CODE)) b
            WHERE s.MemberMci_IDNO = b.MemberMci_IDNO
              AND s.TypeArrear_CODE = b.TypeArrear_CODE) x
    WHERE x.seq = 1;

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
     -- Insert those rejected B transaction records to FEDH_Y1 table
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

     SET @Ls_Sql_TEXT = 'INSERT - FEDH_Y1 FOR B TRANS FOR 17';
     SET @Ls_Sqldata_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranName_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '');

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
     SELECT b.MemberMci_IDNO,
            b.MemberSsn_NUMB,
            b.TypeArrear_CODE,
            @Lc_TypeTranName_CODE AS TypeTransaction_CODE,
            REPLACE(b.Last_NAME, '''', '') AS Last_NAME,
            b.First_NAME,
            b.Middle_NAME,
            @Lc_Space_TEXT AS Line1_ADDR,
            @Lc_Space_TEXT AS Line2_ADDR,
            @Lc_Space_TEXT AS City_ADDR,
            @Lc_Space_TEXT AS State_ADDR,
            @Lc_Space_TEXT AS Zip_ADDR,
            b.ArrearIdentifier_IDNO,
            b.Arrear_AMNT,
            @Ad_Run_DATE AS SubmitLast_DATE,
            'N' AS ExcludePas_CODE,
            'N' AS ExcludeFin_CODE,
            'N' AS ExcludeIrs_CODE,
            'N' AS ExcludeAdm_CODE,
            'N' AS ExcludeRet_CODE,
            'N' AS ExcludeSal_CODE,
            'S' AS ExcludeDebt_CODE,
            'N' AS ExcludeVen_CODE,
            'N' AS ExcludeIns_CODE,
            @Lc_No_INDC AS RejectInd_INDC,
            b.CountyFips_CODE,
            @Ld_Low_DATE AS BeginValidity_DATE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
            @Lc_Space_TEXT AS ReqPreOffset_CODE,
            @An_TaxYear_NUMB AS TaxYear_NUMB
       FROM FEDH_Y1 b,
            #FedhKey_P1 f
      WHERE b.MemberMci_IDNO = f.MemberMci_IDNO
        AND b.TypeArrear_CODE = f.TypeArrear_CODE
        AND b.TypeTransaction_CODE = f.TypeTransaction_CODE
        AND b.SubmitLast_DATE = f.SubmitLast_DATE
        AND b.TransactionEventSeq_NUMB = f.TransactionEventSeq_NUMB
        AND b.TaxYear_NUMB = f.TaxYear_NUMB
        AND b.MemberMci_IDNO = @Ln_SequenceCur_MemberMci_IDNO
        AND b.TypeArrear_CODE = @Lc_SequenceCur_TypeArrear_CODE
        AND b.TypeTransaction_CODE = @Lc_SequenceCur_TypeTransaction_CODE
        AND b.SubmitLast_DATE = @Ld_SequenceCur_SubmitLast_DATE
        AND b.TransactionEventSeq_NUMB = @Ln_SequenceCur_TransactionEventSeq_NUMB
        AND b.TaxYear_NUMB = @Ln_SequenceCur_TaxYear_NUMB
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = b.MemberMci_IDNO
AND X.SubmitLast_DATE = b.SubmitLast_DATE
AND X.TaxYear_NUMB = b.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = b.TypeArrear_CODE
AND X.TypeTransaction_CODE = b.TypeTransaction_CODE)        

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Lc_SequenceCur_TypeArrear_CODE, @Lc_SequenceCur_TypeTransaction_CODE, @Ld_SequenceCur_SubmitLast_DATE, @Ln_SequenceCur_TransactionEventSeq_NUMB, @Ln_SequenceCur_TaxYear_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Sequence_CUR;

   DEALLOCATE Sequence_CUR;

   SET @Ls_Sql_TEXT = 'DELETE - RJDT_Y1 FOR B TRANS FOR 17';
   SET @Ls_Sqldata_TEXT = 'TransactionType_CODE = ' + ISNULL('B', '') + ', TypeReject1_CODE = ' + ISNULL(@Lc_TypeTranAddCase_CODE, '');

   UPDATE A
      SET EndValidity_DATE = @Ad_Run_DATE,
          WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
          Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
    FROM RJDT_Y1 A
   WHERE TransactionType_CODE = 'B'
      AND TypeReject1_CODE = @Lc_TypeTranAddCase_CODE

   --move old records to history if there is changed info in fedh
   SET @Ls_Sql_TEXT = 'MOVE TO HFEDH IF THERE IS CHANGED INFO IN FEDH';
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
          ReqPreOffset_CODE,
          a.TaxYear_NUMB
     FROM FEDH_Y1 a
    WHERE EXISTS (SELECT 1
                    FROM FEDH_Y1 b
                   WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                     AND b.TypeArrear_CODE = a.TypeArrear_CODE
                     AND b.TypeTransaction_CODE IN (@Lc_TypeTranLocalCode_CODE, @Lc_TypeTranReplace_CODE, @Lc_TypeTranName_CODE, @Lc_TypeTranAddress_CODE)
                     AND b.SubmitLast_DATE = @Ad_Run_DATE)
      AND a.SubmitLast_DATE < @Ad_Run_DATE
      AND NOT EXISTS (SELECT 1
                        FROM HFEDH_Y1 X
                       WHERE X.MemberMci_IDNO = a.MemberMci_IDNO
                         AND X.SubmitLast_DATE = a.SubmitLast_DATE
                         AND X.TaxYear_NUMB = a.TaxYear_NUMB
                         AND X.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
                         AND X.TypeArrear_CODE = a.TypeArrear_CODE
                         AND X.TypeTransaction_CODE = a.TypeTransaction_CODE);

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = '';

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

   --Updating changed county fips code, arrear identifier, exclusion codes, name and address to all transaction records in fedh
   SET @Ls_Sql_TEXT = 'UPDATE CHANGED INFO TO ALL TRANSACTION RECORDS IN FEDH';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE a
      SET a.CountyFips_CODE = CASE
                               WHEN b.TypeTransaction_CODE IS NOT NULL
                                THEN b.CountyFips_CODE
                               ELSE a.CountyFips_CODE
                              END,
          a.ArrearIdentifier_IDNO = CASE
                                     WHEN b.TypeTransaction_CODE IS NOT NULL
                                      THEN b.ArrearIdentifier_IDNO
                                     ELSE a.ArrearIdentifier_IDNO
                                    END,
          a.ExcludePas_CODE = CASE
                               WHEN c.TypeTransaction_CODE IS NOT NULL
                                THEN c.ExcludePas_CODE
                               ELSE a.ExcludePas_CODE
                              END,
          a.ExcludeFin_CODE = CASE
                               WHEN c.TypeTransaction_CODE IS NOT NULL
                                THEN c.ExcludeFin_CODE
                               ELSE a.ExcludeFin_CODE
                              END,
          a.ExcludeIrs_CODE = CASE
                               WHEN c.TypeTransaction_CODE IS NOT NULL
                                THEN c.ExcludeIrs_CODE
                               ELSE a.ExcludeIrs_CODE
                              END,
          a.ExcludeAdm_CODE = CASE
                               WHEN c.TypeTransaction_CODE IS NOT NULL
                                THEN c.ExcludeAdm_CODE
                               ELSE a.ExcludeAdm_CODE
                              END,
          a.ExcludeRet_CODE = CASE
                               WHEN c.TypeTransaction_CODE IS NOT NULL
                                THEN c.ExcludeRet_CODE
                               ELSE a.ExcludeRet_CODE
                              END,
          a.ExcludeSal_CODE = CASE
                               WHEN c.TypeTransaction_CODE IS NOT NULL
                                THEN c.ExcludeSal_CODE
                               ELSE a.ExcludeSal_CODE
                              END,
          a.ExcludeDebt_CODE = CASE
                                WHEN c.TypeTransaction_CODE IS NOT NULL
                                 THEN c.ExcludeDebt_CODE
                                ELSE a.ExcludeDebt_CODE
                               END,
          a.ExcludeVen_CODE = CASE
                               WHEN c.TypeTransaction_CODE IS NOT NULL
                                THEN c.ExcludeVen_CODE
                               ELSE a.ExcludeVen_CODE
                              END,
          a.ExcludeIns_CODE = CASE
                               WHEN c.TypeTransaction_CODE IS NOT NULL
                                THEN c.ExcludeIns_CODE
                               ELSE a.ExcludeIns_CODE
                              END,
          a.Last_NAME = CASE
                         WHEN d.TypeTransaction_CODE IS NOT NULL
                          THEN REPLACE(d.Last_NAME, '''', '')
                         ELSE REPLACE(a.Last_NAME, '''', '')
                        END,
          a.First_NAME = CASE
                          WHEN d.TypeTransaction_CODE IS NOT NULL
                           THEN d.First_NAME
                          ELSE a.First_NAME
                         END,
          a.Middle_NAME = CASE
                           WHEN d.TypeTransaction_CODE IS NOT NULL
                            THEN d.Middle_NAME
                           ELSE a.Middle_NAME
                          END,
          a.Line1_ADDR = CASE
                          WHEN e.TypeTransaction_CODE IS NOT NULL
                           THEN e.Line1_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(a.Line1_ADDR, '')))) > 0
                           THEN a.Line1_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(I.Line1_ADDR, '')))) > 0
                           THEN I.Line1_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(J.Line1_ADDR, '')))) > 0
                           THEN J.Line1_ADDR
                          ELSE ''
                         END,
          a.Line2_ADDR = CASE
                          WHEN e.TypeTransaction_CODE IS NOT NULL
                           THEN e.Line2_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(a.Line2_ADDR, '')))) > 0
                           THEN a.Line2_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(I.Line2_ADDR, '')))) > 0
                           THEN I.Line2_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(J.Line2_ADDR, '')))) > 0
                           THEN J.Line2_ADDR
                          ELSE ''
                         END,
          a.City_ADDR = CASE
                         WHEN e.TypeTransaction_CODE IS NOT NULL
                          THEN e.City_ADDR
                         WHEN LEN(LTRIM(RTRIM(ISNULL(a.City_ADDR, '')))) > 0
                          THEN a.City_ADDR
                         WHEN LEN(LTRIM(RTRIM(ISNULL(I.City_ADDR, '')))) > 0
                          THEN I.City_ADDR
                         WHEN LEN(LTRIM(RTRIM(ISNULL(J.City_ADDR, '')))) > 0
                          THEN J.City_ADDR
                         ELSE ''
                        END,
          a.State_ADDR = CASE
                          WHEN e.TypeTransaction_CODE IS NOT NULL
                           THEN e.State_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(a.State_ADDR, '')))) > 0
                           THEN a.State_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(I.State_ADDR, '')))) > 0
                           THEN I.State_ADDR
                          WHEN LEN(LTRIM(RTRIM(ISNULL(J.State_ADDR, '')))) > 0
                           THEN J.State_ADDR
                          ELSE ''
                         END,
          a.Zip_ADDR = CASE
                        WHEN e.TypeTransaction_CODE IS NOT NULL
                         THEN e.Zip_ADDR
                        WHEN LEN(LTRIM(RTRIM(ISNULL(a.Zip_ADDR, '')))) > 0
                         THEN a.Zip_ADDR
                        WHEN LEN(LTRIM(RTRIM(ISNULL(I.Zip_ADDR, '')))) > 0
                         THEN I.Zip_ADDR
                        WHEN LEN(LTRIM(RTRIM(ISNULL(J.Zip_ADDR, '')))) > 0
                         THEN J.Zip_ADDR
                        ELSE ''
                       END,
          a.TransactionEventSeq_NUMB = CASE
                                        WHEN a.TypeTransaction_CODE IN (@Lc_TypeTranAddCase_CODE, @Lc_TypeTranModification_CODE)
                                         THEN @Ln_TransactionEventSeq_NUMB
                                        ELSE a.TransactionEventSeq_NUMB
                                       END,
          a.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT
     FROM FEDH_Y1 a
          LEFT OUTER JOIN (SELECT a.MemberMci_IDNO,
                                  a.TypeArrear_CODE,
                                  a.TypeTransaction_CODE,
                                  a.CountyFips_CODE,
                                  a.ArrearIdentifier_IDNO
                             FROM FEDH_Y1 a
                            WHERE a.TypeTransaction_CODE = @Lc_TypeTranLocalCode_CODE
                              AND a.SubmitLast_DATE = @Ad_Run_DATE
                              AND a.RejectInd_INDC = @Lc_No_INDC) b
           ON b.MemberMci_IDNO = a.MemberMci_IDNO
              AND b.TypeArrear_CODE = a.TypeArrear_CODE
          LEFT OUTER JOIN (SELECT a.MemberMci_IDNO,
                                  a.TypeArrear_CODE,
                                  a.TypeTransaction_CODE,
                                  a.ExcludePas_CODE,
                                  a.ExcludeFin_CODE,
                                  a.ExcludeIrs_CODE,
                                  a.ExcludeAdm_CODE,
                                  a.ExcludeRet_CODE,
                                  a.ExcludeSal_CODE,
                                  a.ExcludeDebt_CODE,
                                  a.ExcludeVen_CODE,
                                  a.ExcludeIns_CODE
                             FROM FEDH_Y1 a
                            WHERE a.TypeTransaction_CODE = @Lc_TypeTranReplace_CODE
                              AND a.SubmitLast_DATE = @Ad_Run_DATE
                              AND a.RejectInd_INDC = @Lc_No_INDC) c
           ON c.MemberMci_IDNO = a.MemberMci_IDNO
              AND c.TypeArrear_CODE = a.TypeArrear_CODE
          LEFT OUTER JOIN (SELECT a.MemberMci_IDNO,
                                  a.TypeArrear_CODE,
                                  a.TypeTransaction_CODE,
                                  a.Last_NAME,
                                  a.First_NAME,
                                  a.Middle_NAME
                             FROM FEDH_Y1 a
                            WHERE a.TypeTransaction_CODE = @Lc_TypeTranName_CODE
                              AND a.SubmitLast_DATE = @Ad_Run_DATE
                              AND a.RejectInd_INDC = @Lc_No_INDC) d
           ON d.MemberMci_IDNO = a.MemberMci_IDNO
              AND d.TypeArrear_CODE = a.TypeArrear_CODE
          LEFT OUTER JOIN (SELECT a.MemberMci_IDNO,
                                  a.TypeArrear_CODE,
                                  a.TypeTransaction_CODE,
                                  a.Line1_ADDR,
                                  a.Line2_ADDR,
                                  a.City_ADDR,
                                  a.State_ADDR,
                                  a.Zip_ADDR
                             FROM FEDH_Y1 a
                            WHERE a.TypeTransaction_CODE = @Lc_TypeTranAddress_CODE
                              AND a.SubmitLast_DATE = @Ad_Run_DATE
                              AND a.RejectInd_INDC = @Lc_No_INDC) e
           ON e.MemberMci_IDNO = a.MemberMci_IDNO
              AND e.TypeArrear_CODE = a.TypeArrear_CODE
          LEFT OUTER JOIN HFEDH_Y1 I
           ON I.MemberMci_IDNO = A.MemberMci_IDNO
              AND I.TypeArrear_CODE = A.TypeArrear_CODE
              AND I.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                         FROM HFEDH_Y1 X
                                        WHERE X.MemberMci_IDNO = I.MemberMci_IDNO
                                          AND X.TypeArrear_CODE = I.TypeArrear_CODE
                                          AND X.SubmitLast_DATE < @Ad_Run_DATE)
              AND I.TypeTransaction_CODE IN ('A', 'M')
          LEFT OUTER JOIN AHIS_Y1 J
           ON J.MemberMci_IDNO = A.MemberMci_IDNO
              AND J.TransactionEventSeq_NUMB = (SELECT L.TransactionEventSeq_NUMB
                                                  FROM (
                                                       --SELECT K.Line1_ADDR,
                                                       --             K.Line2_ADDR,
                                                       --             K.City_ADDR,
                                                       --             K.State_ADDR,
                                                       --             K.Zip_ADDR,
                                                       --             K.TransactionEventSeq_NUMB,
                                                       --             ROW_NUMBER () OVER ( PARTITION BY K.MemberMci_IDNO ORDER BY K.Status_CODE DESC, K.TypeAddress_CODE, K.End_DATE DESC) AS Row_NUMB
                                                       --        FROM AHIS_Y1 K
                                                       --       WHERE K.MemberMci_IDNO = J.MemberMci_IDNO
                                                       --         AND K.TypeAddress_CODE IN ('M', 'R')
                                                       --         AND K.Status_CODE IN ('Y')
                                                       --         AND @Ad_Run_DATE BETWEEN K.Begin_DATE AND K.End_DATE
                                                       SELECT Row_NUMB = ROW_NUMBER() OVER (PARTITION BY Y.MemberMci_IDNO ORDER BY Y.Priority_NUMB, Y.End_DATE DESC),
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
                                                                 WHERE X.MemberMci_IDNO = J.MemberMci_IDNO
                                                                   AND X.TypeAddress_CODE IN ('M', 'R', 'C')
                                                                   AND @Ad_Run_DATE BETWEEN X.Begin_DATE AND X.End_DATE
                                                                   AND X.Status_CODE = 'Y') Y) AS L
                                                 WHERE L.Row_NUMB = 1)
    WHERE a.TypeTransaction_CODE IN (@Lc_TypeTranAddCase_CODE, @Lc_TypeTranModification_CODE, @Lc_TypeTranReplace_CODE, @Lc_TypeTranLocalCode_CODE,
                                     @Lc_TypeTranName_CODE, @Lc_TypeTranAddress_CODE)
      AND EXISTS (SELECT 1
                    FROM FEDH_Y1 b
                   WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                     AND b.TypeArrear_CODE = a.TypeArrear_CODE
                     AND b.TypeTransaction_CODE IN (@Lc_TypeTranLocalCode_CODE, @Lc_TypeTranReplace_CODE, @Lc_TypeTranName_CODE, @Lc_TypeTranAddress_CODE)
                     AND b.SubmitLast_DATE = @Ad_Run_DATE
                     AND b.RejectInd_INDC = @Lc_No_INDC)
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

   SET @Ls_Sql_TEXT = 'DELETE L RECORDS FROM FEDH';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM FEDH_Y1
    WHERE TypeTransaction_CODE = @Lc_TypeTranLocalCode_CODE
      AND SubmitLast_DATE = @Ad_Run_DATE;

   -- Delete the records from PIFMS_Y1 table which dosen't match the arrears creteria
   SET @Ls_Sql_TEXT = 'DELETE - PIFMS_Y1';
   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM PIFMS_Y1
    WHERE TypeTransaction_CODE IN (@Lc_TypeTranX_CODE);

   -- Insert Intermediate table (PIFMS_Y1) to main table(IFMS_Y1) for calse level records.
   SET @Ls_Sql_TEXT = 'PROCEDURE CALL - SP_SAVE_IFMS';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Action_CODE = ' + ISNULL(@Lc_ActionU_CODE, '');

   EXECUTE BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_SAVE_IFMS
    @Ad_Run_DATE             = @Ld_Run_DATE,
    @Ac_Job_ID               = @Lc_Job_ID,
    @Ac_Action_CODE          = @Lc_ActionU_CODE,
    @An_TaxYear_NUMB         = @Ln_TaxYear_NUMB,
    @Ac_Msg_CODE             = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT=@Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   ------------------------------------- S Transaction start -------------------------------------
   DECLARE FedhMember_CUR INSENSITIVE CURSOR FOR
    SELECT CAST(CheckRecipient_ID AS NUMERIC),
           MIN (TaxYear_NUMB)
      FROM (SELECT DISTINCT
                   a.CheckRecipient_ID,
                   (SELECT TOP 1 YEAR(Check_DATE)TaxYear_NUMB
                      FROM RCTH_Y1 y
                     WHERE a.Batch_DATE = y.Batch_DATE
                       AND a.Batch_NUMB = y.Batch_NUMB
                       AND a.SourceBatch_CODE = y.SourceBatch_CODE
                       AND a.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                       AND y.EndValidity_DATE = @Ld_High_DATE) TaxYear_NUMB
              FROM DSBL_Y1 a,
                   DSBH_Y1 b
             WHERE b.CheckRecipient_ID = a.CheckRecipient_ID
               AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
               AND b.CheckRecipient_CODE = @Lc_RecipientCpNcp_CODE
               AND b.Disburse_DATE = a.Disburse_DATE
               AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB
               AND b.StatusCheck_CODE IN (@Lc_DisburseStatusCashed_CODE, @Lc_DisburseStatusOutstanding_CODE, @Lc_DisburseStatusVoidReissue_CODE, @Lc_DisburseStatusVoidNoReis_CODE,
                                          @Lc_DisburseStatusStopReissue_CODE, @Lc_DisburseStatusStopNoReis_CODE)
               AND a.SourceBatch_CODE = @Lc_SourceBatchIrs_CODE
               AND b.StatusCheck_DATE BETWEEN DATEADD(d, 1, @Ad_LastRun_DATE) AND @Ad_Run_DATE
               AND b.EndValidity_DATE = @Ld_High_DATE
               AND a.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
            UNION
            SELECT DISTINCT
                   PayorMCI_IDNO CheckRecipient_ID,
                   YEAR(Check_DATE) TaxYear_NUMB
              FROM RCTH_Y1 y
             WHERE y.EndValidity_DATE = @Ld_High_DATE
               AND y.BeginValidity_DATE BETWEEN DATEADD(d, 1, @Ad_LastRun_DATE) AND @Ad_Run_DATE
               AND y.SourceReceipt_CODE = @Lc_SourceReceiptIr_CODE
               AND y.BackOut_INDC = @Lc_Yes_INDC
               AND EXISTS (SELECT 1
                             FROM RCTH_Y1 i
                            WHERE y.Batch_DATE = i.Batch_DATE
                              AND y.SourceBatch_CODE = i.SourceBatch_CODE
                              AND y.Batch_NUMB = i.Batch_NUMB
                              AND y.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                              AND y.PayorMCI_IDNO = i.PayorMCI_IDNO
                              AND i.StatusReceipt_CODE = @Lc_StatusReceiptRefund_CODE
                              AND i.EndValidity_DATE = @Ld_High_DATE)
            UNION
            SELECT DISTINCT TOP 1
                   a.CheckRecipient_ID,
                   (SELECT YEAR(Check_DATE) TaxYear_NUMB
                      FROM RCTH_Y1 y
                     WHERE a.Batch_DATE = y.Batch_DATE
                       AND a.Batch_NUMB = y.Batch_NUMB
                       AND a.SourceBatch_CODE = y.SourceBatch_CODE
                       AND a.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                       AND y.EndValidity_DATE = @Ld_High_DATE) TaxYear_NUMB
              FROM POFL_Y1 a
             WHERE TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
               AND SourceBatch_CODE = @Lc_SourceBatchIrs_CODE
               AND Transaction_DATE BETWEEN DATEADD(d, 1, @Ad_LastRun_DATE) AND @Ad_Run_DATE
               AND CheckRecipient_CODE = @Lc_RecipientCpNcp_CODE
               AND Transaction_CODE = @Lc_TransactionSrec_CODE) TaxYear_NUMB
     GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'Open FedhMember_CUR-3';

   OPEN FedhMember_CUR;

   SET @Ls_Sql_TEXT = 'FETCH FedhMember_CUR-5';

   FETCH NEXT FROM FedhMember_CUR INTO @Ln_FedhMemberCur_MemberMci_IDNO, @Ln_FedhMemberCur_TaxYear_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'While loop 3';

   --loop through
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     DECLARE Sequence_CUR INSENSITIVE CURSOR FOR
      SELECT c.MemberMci_IDNO,
             c.TaxYear_NUMB,
             c.TypeArrear_CODE,
             c.Arrear_AMNT
        FROM (SELECT k.CheckRecipient_ID AS MemberMci_IDNO,
                     k.TaxYear_NUMB,
                     ISNULL(LTRIM(RTRIM(Tanf_CODE)), @Lc_TypeCaseNontanf_CODE) TypeArrear_CODE,
                     SUM (Disburse_AMNT) AS Arrear_AMNT
                FROM (SELECT a.CheckRecipient_ID,
                             (SELECT TOP 1 YEAR(Check_DATE)
                                FROM RCTH_Y1 y
                               WHERE a.Batch_DATE = y.Batch_DATE
                                 AND a.Batch_NUMB = y.Batch_NUMB
                                 AND a.SourceBatch_CODE = y.SourceBatch_CODE
                                 AND a.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                                 AND a.CheckRecipient_ID = y.PayorMCI_IDNO
                                 AND y.EndValidity_DATE = @Ld_High_DATE) TaxYear_NUMB,
                             (SELECT TOP 1 Tanf_CODE
                                FROM RCTH_Y1 y
                               WHERE a.Batch_DATE = y.Batch_DATE
                                 AND a.Batch_NUMB = y.Batch_NUMB
                                 AND a.SourceBatch_CODE = y.SourceBatch_CODE
                                 AND a.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                                 AND a.CheckRecipient_ID = y.PayorMCI_IDNO
                                 AND y.EndValidity_DATE = @Ld_High_DATE) Tanf_CODE,
                             a.Disburse_AMNT
                        FROM DSBL_Y1 a,
                             DSBH_Y1 b
                       WHERE b.CheckRecipient_ID = a.CheckRecipient_ID
                         AND b.CheckRecipient_ID = @Ln_FedhMemberCur_MemberMci_IDNO
                         AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
                         AND b.CheckRecipient_CODE = @Lc_RecipientCpNcp_CODE
                         AND b.Disburse_DATE = a.Disburse_DATE
                         AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB
                         AND b.StatusCheck_CODE IN (@Lc_DisburseStatusCashed_CODE, @Lc_DisburseStatusOutstanding_CODE)
                         AND a.SourceBatch_CODE = @Lc_SourceBatchIrs_CODE
                         AND b.StatusCheck_DATE BETWEEN @Ld_Min_DATE AND @Ad_Run_DATE
                         AND b.EndValidity_DATE = @Ld_High_DATE
                         AND a.TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                         AND NOT EXISTS (SELECT 1
                                           FROM RCTH_Y1 i
                                          WHERE a.Batch_DATE = i.Batch_DATE
                                            AND a.SourceBatch_CODE = i.SourceBatch_CODE
                                            AND a.Batch_NUMB = i.Batch_NUMB
                                            AND a.SeqReceipt_NUMB = i.SeqReceipt_NUMB
                                            AND a.CheckRecipient_ID = i.PayorMCI_IDNO
                                            AND i.BackOut_INDC = @Lc_Yes_INDC
                                            AND i.EndValidity_DATE = @Ld_High_DATE)
                      UNION ALL
                      SELECT a.CheckRecipient_ID,
                             (SELECT TOP 1 YEAR(Check_DATE)
                                FROM RCTH_Y1 y
                               WHERE a.Batch_DATE = y.Batch_DATE
                                 AND a.Batch_NUMB = y.Batch_NUMB
                                 AND a.SourceBatch_CODE = y.SourceBatch_CODE
                                 AND a.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                                 AND a.CheckRecipient_ID = y.PayorMCI_IDNO
                                 AND y.EndValidity_DATE = @Ld_High_DATE) TaxYear_NUMB,
                             (SELECT TOP 1 Tanf_CODE
                                FROM RCTH_Y1 y
                               WHERE a.Batch_DATE = y.Batch_DATE
                                 AND a.Batch_NUMB = y.Batch_NUMB
                                 AND a.SourceBatch_CODE = y.SourceBatch_CODE
                                 AND a.SeqReceipt_NUMB = y.SeqReceipt_NUMB
                                 AND a.CheckRecipient_ID = y.PayorMCI_IDNO
                                 AND y.EndValidity_DATE = @Ld_High_DATE) Tanf_CODE,
                             RecOverpay_AMNT AS Disburse_AMNT
                        FROM POFL_Y1 a
                       WHERE a.CheckRecipient_ID = @Ln_FedhMemberCur_MemberMci_IDNO
                         AND TypeDisburse_CODE = @Lc_TypeDisburseRefund_CODE
                         AND SourceBatch_CODE = @Lc_SourceBatchIrs_CODE
                         AND Transaction_DATE BETWEEN @Ld_Min_DATE AND @Ad_Run_DATE
                         AND CheckRecipient_CODE = @Lc_RecipientCpNcp_CODE
                         AND Transaction_CODE = @Lc_TransactionSrec_CODE)K
               GROUP BY k.CheckRecipient_ID,
                        k.TaxYear_NUMB,
                        k.Tanf_CODE)c;

     OPEN Sequence_CUR;

     FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_TaxYear_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ln_SequenceCur_Arrear_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

     --
     WHILE (@Li_FetchStatus_QNTY = 0)
      BEGIN
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

       SET @Ld_Min_DATE = CONVERT(DATE, '01-JAN-' + CAST(@Ln_FedhMemberCur_TaxYear_NUMB AS VARCHAR));
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SequenceCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_SequenceCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranStatePayment_CODE, '') + ', Last_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', First_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Middle_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line2_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', City_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', State_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Zip_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', ArrearIdentifier_IDNO = ' + ISNULL(@Lc_Space_TEXT, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', ExcludePas_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeFin_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeIrs_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeAdm_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeRet_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeSal_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeDebt_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeVen_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', ExcludeIns_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', RejectInd_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ReqPreOffset_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

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
              @Lc_Space_TEXT AS MemberSsn_NUMB,
              @Lc_SequenceCur_TypeArrear_CODE AS TypeArrear_CODE,
              @Lc_TypeTranStatePayment_CODE AS TypeTransaction_CODE,
              @Lc_Space_TEXT AS Last_NAME,
              @Lc_Space_TEXT AS First_NAME,
              @Lc_Space_TEXT AS Middle_NAME,
              @Lc_Space_TEXT AS Line1_ADDR,
              @Lc_Space_TEXT AS Line2_ADDR,
              @Lc_Space_TEXT AS City_ADDR,
              @Lc_Space_TEXT AS State_ADDR,
              @Lc_Space_TEXT AS Zip_ADDR,
              @Lc_Space_TEXT AS ArrearIdentifier_IDNO,
              FLOOR(@Ln_SequenceCur_Arrear_AMNT) AS Arrear_AMNT,
              @Ad_Run_DATE AS SubmitLast_DATE,
              @Lc_No_INDC AS ExcludePas_CODE,
              @Lc_No_INDC AS ExcludeFin_CODE,
              @Lc_No_INDC AS ExcludeIrs_CODE,
              @Lc_No_INDC AS ExcludeAdm_CODE,
              @Lc_No_INDC AS ExcludeRet_CODE,
              @Lc_No_INDC AS ExcludeSal_CODE,
              @Lc_No_INDC AS ExcludeDebt_CODE,
              @Lc_No_INDC AS ExcludeVen_CODE,
              @Lc_No_INDC AS ExcludeIns_CODE,
              @Lc_No_INDC AS RejectInd_INDC,
              @Lc_Space_TEXT AS CountyFips_CODE,
              @Ad_Run_DATE AS BeginValidity_DATE,
              @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
              dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
              @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
              @Lc_Space_TEXT AS ReqPreOffset_CODE,
              @Ln_SequenceCur_TaxYear_NUMB - 1 AS TaxYear_NUMB

       FETCH NEXT FROM Sequence_CUR INTO @Ln_SequenceCur_MemberMci_IDNO, @Ln_SequenceCur_TaxYear_NUMB, @Lc_SequenceCur_TypeArrear_CODE, @Ln_SequenceCur_Arrear_AMNT;

       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
      END;

     CLOSE Sequence_CUR;

     DEALLOCATE Sequence_CUR;

     SET @Ls_Sql_TEXT = 'FETCH FedhMember_CUR-6';

     FETCH NEXT FROM FedhMember_CUR INTO @Ln_FedhMemberCur_MemberMci_IDNO, @Ln_FedhMemberCur_TaxYear_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE FedhMember_CUR;

   DEALLOCATE FedhMember_CUR;

   -- Insert  PIFMS_Y1 - the previous 'S' transaction records from HFEDH_Y1 table
   DECLARE FedhMember_CUR INSENSITIVE CURSOR FOR
    SELECT a.MemberMci_IDNO,
           a.TypeArrear_CODE,
           a.TaxYear_NUMB,
           SUM(b.Arrear_AMNT)
      FROM FEDH_Y1 a,
           HFEDH_Y1 b
     WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
       AND a.TypeArrear_CODE = b.TypeArrear_CODE
       AND a.TaxYear_NUMB = b.TaxYear_NUMB
       AND a.SubmitLast_DATE = @Ad_Run_DATE
       AND b.TypeTransaction_CODE = @Lc_TypeTranStatePayment_CODE
       AND b.TypeTransaction_CODE = a.TypeTransaction_CODE
       AND b.TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                           FROM HFEDH_Y1 j
                                          WHERE j.MemberMci_IDNO = b.MemberMci_IDNO
                                            AND j.TypeArrear_CODE = b.TypeArrear_CODE
                                            AND j.TaxYear_NUMB = b.TaxYear_NUMB
                                            AND j.TypeTransaction_CODE = @Lc_TypeTranStatePayment_CODE)
     GROUP BY a.MemberMci_IDNO,
              a.TypeArrear_CODE,
              a.TaxYear_NUMB;

   -- Update the Previous S - Transaction amount latest records
   SET @Ls_Sql_TEXT = 'Open FedhMember_CUR-4';

   OPEN FedhMember_CUR;

   SET @Ls_Sql_TEXT = 'FETCH FedhMember_CUR-7';

   FETCH NEXT FROM FedhMember_CUR INTO @Ln_FedhMemberCur_MemberMci_IDNO, @Lc_FedhMemberCur_TypeArrear_CODE, @Ln_FedhMemberCur_TaxYear_NUMB, @Ln_FedhMemberCur_Transaction_AMNT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'While loop 4';

   --loop through
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FedhMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_FedhMemberCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranStatePayment_CODE, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_FedhMemberCur_TaxYear_NUMB AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

     SELECT @Ln_Arrear_AMNT = Arrear_AMNT
       FROM FEDH_Y1
      WHERE MemberMci_IDNO = @Ln_FedhMemberCur_MemberMci_IDNO
        AND TypeArrear_CODE = @Lc_FedhMemberCur_TypeArrear_CODE
        AND TypeTransaction_CODE = @Lc_TypeTranStatePayment_CODE
        AND TaxYear_NUMB = @Ln_FedhMemberCur_TaxYear_NUMB
        AND SubmitLast_DATE = @Ad_Run_DATE;

     IF @Ln_Arrear_AMNT = @Ln_FedhMemberCur_Transaction_AMNT
      BEGIN
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FedhMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_FedhMemberCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranStatePayment_CODE, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ln_FedhMemberCur_TaxYear_NUMB AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

       DELETE FROM FEDH_Y1
        WHERE MemberMci_IDNO = @Ln_FedhMemberCur_MemberMci_IDNO
          AND TypeArrear_CODE = @Lc_FedhMemberCur_TypeArrear_CODE
          AND TypeTransaction_CODE = @Lc_TypeTranStatePayment_CODE
          AND TaxYear_NUMB = @Ln_FedhMemberCur_TaxYear_NUMB
          AND SubmitLast_DATE = @Ad_Run_DATE;
      END;

     SET @Ls_Sql_TEXT = 'FETCH FedhMember_CUR-6';

     FETCH NEXT FROM FedhMember_CUR INTO @Ln_FedhMemberCur_MemberMci_IDNO, @Lc_FedhMemberCur_TypeArrear_CODE, @Ln_FedhMemberCur_TaxYear_NUMB, @Ln_FedhMemberCur_Transaction_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE FedhMember_CUR;

   DEALLOCATE FedhMember_CUR;

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   --S Transaction needs to sEND the check status is "OU" also - End
   -- SSN , NAME update  from the demo_y1 table
   SET @Ls_Sql_TEXT = 'SELECT demo_y1 - SSN,NAME';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #FedhKey_P1
               (MemberMci_IDNO,
                MemberSsn_NUMB,
                Last_NAME,
                FIRST_NAME,
                Middle_NAME)
   SELECT MemberMci_IDNO,
          MemberSsn_NUMB,
          Last_NAME,
          First_NAME,
          Middle_NAME
     FROM (SELECT a.MemberMci_IDNO,
                  dbo.BATCH_COMMON$SF_GET_VERIFIED_SSN_ITIN(a.MemberMci_IDNO) AS MemberSsn_NUMB,
                  b.Last_NAME,
                  b.First_NAME,
                  b.Middle_NAME
             FROM FEDH_Y1 a,
                  DEMO_Y1 b
            WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
              AND a.TypeTransaction_CODE = @Lc_TypeTranStatePayment_CODE) h
    WHERE MemberSsn_NUMB <> @Ln_Zero_NUMB;

   SET @Ls_Sql_TEXT = 'UPDATE PIFMS_Y1 - SSN,NAME';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE a
      SET a.MemberSsn_NUMB = f.MemberSsn_NUMB,
          a.First_NAME = f.FIRST_NAME,
          a.Last_NAME = f.Last_NAME,
          a.Middle_NAME = f.Middle_NAME
     FROM FEDH_Y1 a,
          #FedhKey_P1 f
    WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

   SET @Ls_Sqldata_TEXT = '';

   DELETE FROM #FedhKey_P1;

   --------------------------------------S Transaction End---------------------------------------------------------
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
