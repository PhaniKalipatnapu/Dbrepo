/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE 
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE is 
					  to handle the rejected records from IRS
					  Reject file with reject type as "A"
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_AUTO_RESPONSE] (
 @Ac_Error_CODE            CHAR(5),
 @Ac_Job_ID                CHAR(7),
 @Ad_Run_DATE              DATE,
 @An_TaxYear_NUMB          NUMERIC(4),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT        CHAR = ' ',
          @Lc_StatusFailed_CODE CHAR(1) = 'F',
          @Lc_Yes_INDC          CHAR(1) = 'Y',
          @Lc_No_INDC           CHAR(1) = 'N',
          @Lc_Success_CODE      CHAR(1) = 'S',
          @Lc_TypeTranscB_CODE  CHAR(1) = 'B',
          @Lc_TypeTranscD_CODE  CHAR(1) = 'D',
          @Lc_TypeTranscM_CODE  CHAR(1) = 'M',
          @Lc_TypeTranscI_CODE  CHAR(1) = 'I',
          @Lc_TypeTranscU_CODE  CHAR(1) = 'U',
          @Lc_TypeTranscS_CODE  CHAR(1) = 'S',
          @Lc_ArrearTypB_CODE   CHAR(1) = 'B',
          @Lc_RejectTypA_CODE   CHAR(1) = 'A',
          @Lc_Error06_CODE      CHAR(2) = '06',
          @Lc_Error12_CODE      CHAR(2) = '12',
          @Lc_Error17_CODE      CHAR(2) = '17',
          @Lc_Error39_CODE      CHAR(2) = '39',
          @Lc_TableTaxi_ID      CHAR(4) = 'TAXI',
          @Lc_TableSub_ID       CHAR(4) = 'YEAR',
          @Lc_BatchRunUser_TEXT CHAR(5) = 'BATCH',
          @Lc_Job_ID            CHAR(7) = @Ac_Job_ID,
          @Ls_Procedure_NAME    VARCHAR(100) = 'SP_AUTO_RESPONSE',
          @Ld_Run_DATE          DATE = @Ad_Run_DATE,
          @Ld_High_DATE         DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                NUMERIC = 0,
          @Ln_TaxYear_NUMB             NUMERIC(4) = @An_TaxYear_NUMB,
          @Ln_EventFunctionalSeq_NUMB  NUMERIC(4) = 0,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Ln_RowCount_NUMB            NUMERIC(19),
          @Li_FetchStatus_QNTY         SMALLINT,
          @Lc_Yes_TEXT                 CHAR(1),
          @Lc_Msg_CODE                 CHAR(5) = '',
          @Ls_Sql_TEXT                 VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(200),
          @Ls_SqlData_TEXT             VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT    VARCHAR(4000);
  DECLARE @Ln_AutoResCur_MemberSsn_NUMB       NUMERIC(9),
          @Ln_AutoResCur_MemberMci_IDNO       NUMERIC(10),
          @Lc_AutoResCur_TypeArrear_CODE      CHAR(1),
          @Lc_AutoResCur_TypeTransaction_CODE CHAR(1);
  DECLARE @Ln_IfmsCur_TaxYear_NUMB             NUMERIC(4),
          @Ln_IfmsCur_Case_IDNO                NUMERIC(6),
          @Ln_IfmsCur_MemberMci_IDNO           NUMERIC(10),
          @Ln_IfmsCur_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_IfmsCur_TypeArrear_CODE          CHAR(1),
          @Lc_IfmsCur_TypeTransaction_CODE     CHAR(1),
          @Ld_IfmsCur_SubmitLast_DATE          DATE;
  DECLARE @Ln_RjdtRjcsCur_Case_IDNO             NUMERIC(6),
          @Ln_RjdtRjcsCur_MemberSsn_NUMB        NUMERIC(9),
          @Ln_RjdtRjcsCur_MemberMci_IDNO        NUMERIC(10),
          @Ln_RjdtRjcsCur_ArrearIdentifier_IDNO NUMERIC(15),
          @Lc_RjdtRjcsCur_TypeArrear_CODE       CHAR(1),
          @Lc_RjdtRjcsCur_TransactionType_CODE  CHAR(1);
  DECLARE AutoRes_CUR INSENSITIVE CURSOR FOR
   SELECT s.MemberSsn_NUMB,
          s.TypeArrear_CODE,
          s.MemberMci_IDNO,
          s.TypeTransaction_CODE
     FROM FEDH_Y1 s,
          RJDT_Y1 r
    WHERE s.RejectInd_INDC = @Lc_Yes_INDC
      AND s.MemberMci_IDNO = r.MemberMci_IDNO
      AND s.TypeArrear_CODE = r.TypeArrear_CODE
      AND s.TypeTransaction_CODE = r.TransactionType_CODE
      AND (r.Reject1_CODE = @Ac_Error_CODE
            OR r.Reject2_CODE = @Ac_Error_CODE
            OR r.Reject3_CODE = @Ac_Error_CODE
            OR r.Reject4_CODE = @Ac_Error_CODE
            OR r.Reject5_CODE = @Ac_Error_CODE
            OR r.Reject6_CODE = @Ac_Error_CODE)
      AND r.EndValidity_DATE = @Ld_High_DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'OPEN AutoRes_CUR';

   OPEN AutoRes_CUR;

   SET @Ls_Sql_TEXT = 'FETCH AutoRes_CUR - 1';

   FETCH NEXT FROM AutoRes_CUR INTO @Ln_AutoResCur_MemberSsn_NUMB, @Lc_AutoResCur_TypeArrear_CODE, @Ln_AutoResCur_MemberMci_IDNO, @Lc_AutoResCur_TypeTransaction_CODE;

   SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT REJECTED RECORDS WITH CODES 06/39/17/12 INTO HFEDH_Y1';
     SET @Ls_SqlData_TEXT = '';

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
            @Ld_Run_DATE AS EndValidity_DATE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
            h.TransactionEventSeq_NUMB,
            h.ReqPreOffset_CODE,
            h.TaxYear_NUMB
       FROM FEDH_Y1 h
      WHERE h.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
        AND h.MemberSsn_NUMB = @Ln_AutoResCur_MemberSsn_NUMB
        AND h.TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE
        AND h.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
        AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                   FROM FEDH_Y1 e
                                  WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                    AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                    AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                    AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                    AND h.TaxYear_NUMB = e.TaxYear_NUMB)
        AND h.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB)
                                            FROM FEDH_Y1 e
                                           WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                             AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                             AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                             AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                             AND h.TaxYear_NUMB = e.TaxYear_NUMB
                                             AND h.SubmitLast_DATE = e.SubmitLast_DATE)
AND NOT EXISTS(SELECT 1 FROM HFEDH_Y1 X
WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)

     IF @Ac_Error_CODE = @Lc_Error06_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
       SET @Ls_Sqldata_TEXT = '';

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'UPDATE FEDH REJECTED RECORDS WITH CODES 06';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_AutoResCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_AutoResCur_TypeTransaction_CODE, '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '');

       UPDATE h
          SET h.RejectInd_INDC = @Lc_No_INDC,
              h.Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
              h.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              h.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
              h.TypeTransaction_CODE = @Lc_TypeTranscD_CODE,
              h.Arrear_AMNT = @Ln_Zero_NUMB,
              h.Line1_ADDR = @Lc_Space_TEXT,
              h.Line2_ADDR = @Lc_Space_TEXT,
              h.City_ADDR = @Lc_Space_TEXT,
              h.State_ADDR = @Lc_Space_TEXT,
              h.Zip_ADDR = @Lc_Space_TEXT,
              h.Submitlast_DATE = @Ld_Run_DATE
         FROM FEDH_Y1 h
        WHERE h.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
          AND h.MemberSsn_NUMB = @Ln_AutoResCur_MemberSsn_NUMB
          AND h.TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE
          AND h.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
          AND h.SubmitLast_DATE = (SELECT MAX(e.SubmitLast_DATE)
                                     FROM FEDH_Y1 e
                                    WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                      AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                      AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                      AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                      AND h.TaxYear_NUMB = e.TaxYear_NUMB)
          AND h.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB)
                                              FROM FEDH_Y1 e
                                             WHERE h.MemberMci_IDNO = e.MemberMci_IDNO
                                               AND h.MemberSsn_NUMB = e.MemberSsn_NUMB
                                               AND h.TypeTransaction_CODE = e.TypeTransaction_CODE
                                               AND h.TypeArrear_CODE = e.TypeArrear_CODE
                                               AND h.TaxYear_NUMB = e.TaxYear_NUMB
                                               AND h.SubmitLast_DATE = e.SubmitLast_DATE)
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)

       SET @Ln_RowCount_NUMB = @@ROWCOUNT;

       IF @Ln_RowCount_NUMB = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE FEDH_Y1 TABLE FAILED ';

         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'SELECT IFMS RECORDS FOR CODES 06';

       DECLARE Ifms_CUR INSENSITIVE CURSOR FOR
        SELECT a.Case_IDNO,
               a.MemberMci_IDNO,
               a.SubmitLast_DATE,
               a.TaxYear_NUMB,
               a.TransactionEventSeq_NUMB,
               a.TypeArrear_CODE,
               a.TypeTransaction_CODE
          FROM IFMS_Y1 a,
               (SELECT DISTINCT
                       s.MemberMci_IDNO,
                       s.TypeArrear_CODE
                  FROM FEDH_Y1 s
                 WHERE s.TypeTransaction_CODE = @Lc_TypeTranscD_CODE
                   AND SubmitLast_DATE = @Ld_Run_DATE) b
         WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
           AND b.TypeArrear_CODE = a.TypeArrear_CODE
           AND Transaction_AMNT <> @Ln_Zero_NUMB
         ORDER BY a.MemberMci_IDNO,
                  a.Case_IDNO,
                  a.TypeArrear_CODE,
                  a.SubmitLast_DATE;

       SET @Ls_Sql_TEXT = 'OPEN Ifms_CUR';

       OPEN Ifms_CUR;

       SET @Ls_Sql_TEXT = 'FETCH Ifms_CUR - 1';

       FETCH NEXT FROM Ifms_CUR INTO @Ln_IfmsCur_Case_IDNO, @Ln_IfmsCur_MemberMci_IDNO, @Ld_IfmsCur_SubmitLast_DATE, @Ln_IfmsCur_TaxYear_NUMB, @Ln_IfmsCur_TransactionEventSeq_NUMB, @Lc_IfmsCur_TypeArrear_CODE, @Lc_IfmsCur_TypeTransaction_CODE;

       SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;

       --
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'FETCH Ifms_CUR - 2';
         SET @Ls_SqlData_TEXT = '';

         INSERT INTO HIFMS_Y1
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
                      TransactionEventSeq_NUMB)
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
           FROM IFMS_Y1 H
          WHERE Case_IDNO = @Ln_IfmsCur_Case_IDNO
            AND MemberMci_IDNO = @Ln_IfmsCur_MemberMci_IDNO
            AND SubmitLast_DATE = @Ld_IfmsCur_SubmitLast_DATE
            AND TaxYear_NUMB = @Ln_IfmsCur_TaxYear_NUMB
            AND TransactionEventSeq_NUMB = @Ln_IfmsCur_TransactionEventSeq_NUMB
            AND TypeArrear_CODE = @Lc_IfmsCur_TypeArrear_CODE
AND NOT EXISTS(SELECT 1 FROM HIFMS_Y1 X
WHERE X.Case_IDNO = H.Case_IDNO
AND X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)

         FETCH NEXT FROM Ifms_CUR INTO @Ln_IfmsCur_Case_IDNO, @Ln_IfmsCur_MemberMci_IDNO, @Ld_IfmsCur_SubmitLast_DATE, @Ln_IfmsCur_TaxYear_NUMB, @Ln_IfmsCur_TransactionEventSeq_NUMB, @Lc_IfmsCur_TypeArrear_CODE, @Lc_IfmsCur_TypeTransaction_CODE;

         SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;
        END

       CLOSE Ifms_CUR;

       DEALLOCATE Ifms_CUR;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
       SET @Ls_Sqldata_TEXT = '';

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'UPDATE IFMS_Y1 FOR CERTIFIED DATE AS 12/31/9999 FOR DELETE TRANSACTION FOR CODE 06';
       SET @Ls_SqlData_TEXT = 'TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTranscD_CODE, '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE a
          SET a.TaxYear_NUMB = @Ln_TaxYear_NUMB,
              a.SubmitLast_DATE = @Ld_Run_DATE,
              a.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              a.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
              a.Certified_DATE = @Ld_High_DATE,
              a.Transaction_AMNT = @Ln_Zero_NUMB,
              a.Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
         FROM IFMS_Y1 a
        WHERE EXISTS (SELECT 1
                        FROM FEDH_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.TypeArrear_CODE = a.TypeArrear_CODE
                         AND b.TypeTransaction_CODE = @Lc_TypeTranscD_CODE
                         AND b.SubmitLast_DATE = @Ld_Run_DATE)
AND 1 = (SELECT COUNT(1) FROM IFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)

       SET @Ls_Sql_TEXT = 'DELETE - PIFMS';
       SET @Ls_SqlData_TEXT = 'DELETE PIFMS FOR DELETE TRANSACTIONS FOR CODE 06';

       DELETE PIFMS_Y1
         FROM PIFMS_Y1 a
        WHERE EXISTS (SELECT 1
                        FROM FEDH_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.TypeArrear_CODE = a.TypeArrear_CODE
                         AND b.TypeTransaction_CODE = @Lc_TypeTranscD_CODE
                         AND b.SubmitLast_DATE = @Ld_Run_DATE);
      END
     ELSE IF @Ac_Error_CODE = @Lc_Error17_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
       SET @Ls_Sqldata_TEXT = '';

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR (50001,16,1);
        END

       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_AutoResCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_AutoResCur_TypeTransaction_CODE, '');

       UPDATE H
          SET RejectInd_INDC = @Lc_No_INDC,
              TypeTransaction_CODE = CASE TypeTransaction_CODE
                                      WHEN @Lc_TypeTranscD_CODE
                                       THEN @Lc_TypeTranscM_CODE
                                      ELSE TypeTransaction_CODE
                                     END,
              Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
              TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              WorkerUpdate_ID = @Lc_BatchRunUser_TEXT
       FROM FEDH_Y1 H
        WHERE MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
          AND MemberSsn_NUMB = @Ln_AutoResCur_MemberSsn_NUMB
          AND TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
          AND TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)
          
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
       SET @Ls_Sqldata_TEXT = '';

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR (50001,16,1);
        END

       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_AutoResCur_MemberSsn_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_AutoResCur_TypeTransaction_CODE, '');

       UPDATE H
          SET RejectInd_INDC = @Lc_No_INDC,
              Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
              TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              WorkerUpdate_ID = @Lc_BatchRunUser_TEXT
       FROM FEDH_Y1 H
        WHERE MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
          AND MemberSsn_NUMB = @Ln_AutoResCur_MemberSsn_NUMB
          AND TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
          AND TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE
AND 1 = (SELECT COUNT(1) FROM FEDH_Y1 X
WHERE X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)
          
      END

     /*
     	 Reject Code 12 - Submitted Case not found the OCSE. So we are sending the Delete for this time
     
     	 Reject Code 39 - Attempt was made to switch a case from FIDM to NONO-FIDM or NON-FIDN to FIDM only
     	 without deleting the original case. So we are mark it amt as 0 ,that mean we are sending the D this time.
     
       */
     IF @Ac_Error_CODE IN (@Lc_Error12_CODE, @Lc_Error39_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE PIFMS FOR AMT_TRANS =0 FOR REJECTED RECORDS WITH CODES 06/39';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '');

       UPDATE H
          SET Transaction_AMNT = CASE @Lc_AutoResCur_TypeTransaction_CODE
                                  WHEN @Lc_TypeTranscD_CODE
                                   THEN Transaction_AMNT
                                  ELSE @Ln_Zero_NUMB
                                 END,
              TypeTransaction_CODE = CASE @Lc_AutoResCur_TypeTransaction_CODE
                                      WHEN @Lc_TypeTranscD_CODE
                                       THEN @Lc_TypeTranscI_CODE
                                      ELSE @Lc_TypeTranscU_CODE
                                     END
       FROM PIFMS_Y1 H
        WHERE MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
          AND TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
          
      END

     IF @Lc_AutoResCur_TypeTransaction_CODE = @Lc_TypeTranscD_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'CHECK IF A MATCHING D RECORD EXISTS IN IFMS FOR THE D RECORD IN FEDH';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '')

       IF EXISTS(SELECT 1
                   FROM FEDH_Y1 X
                  WHERE X.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
                    AND X.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
                    AND X.TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE
                    AND X.RejectInd_INDC = @Lc_No_INDC)
          AND NOT EXISTS(SELECT 1
                           FROM IFMS_Y1 X
                          WHERE X.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
                            AND X.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
                            AND X.TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE)
        BEGIN
         DECLARE @Ld_FedhSubmitLast_DATE  DATE = @Ld_Run_DATE,
                 @Ld_FedhTaxYear_NUMB     NUMERIC(4) = @Ln_TaxYear_NUMB,
                 @Lc_FedhExcludeIrs_CODE  CHAR(1) = @Lc_No_INDC,
                 @Lc_FedhExcludeAdm_CODE  CHAR(1) = @Lc_No_INDC,
                 @Lc_FedhExcludeFin_CODE  CHAR(1) = @Lc_No_INDC,
                 @Lc_FedhExcludePas_CODE  CHAR(1) = @Lc_No_INDC,
                 @Lc_FedhExcludeRet_CODE  CHAR(1) = @Lc_No_INDC,
                 @Lc_FedhExcludeSal_CODE  CHAR(1) = @Lc_No_INDC,
                 @Lc_FedhExcludeDebt_CODE CHAR(1) = @Lc_No_INDC,
                 @Lc_FedhExcludeVen_CODE  CHAR(1) = @Lc_No_INDC,
                 @Lc_FedhExcludeIns_CODE  CHAR(1) = @Lc_No_INDC

         SELECT @Ld_FedhSubmitLast_DATE = X.SubmitLast_DATE,
                @Ld_FedhTaxYear_NUMB = X.TaxYear_NUMB,
                @Lc_FedhExcludeIrs_CODE = X.ExcludeIrs_CODE,
                @Lc_FedhExcludeAdm_CODE = X.ExcludeAdm_CODE,
                @Lc_FedhExcludeFin_CODE = X.ExcludeFin_CODE,
                @Lc_FedhExcludePas_CODE = X.ExcludePas_CODE,
                @Lc_FedhExcludeRet_CODE = X.ExcludeRet_CODE,
                @Lc_FedhExcludeSal_CODE = X.ExcludeSal_CODE,
                @Lc_FedhExcludeDebt_CODE = X.ExcludeDebt_CODE,
                @Lc_FedhExcludeVen_CODE = X.ExcludeVen_CODE,
                @Lc_FedhExcludeIns_CODE = X.ExcludeIns_CODE
           FROM FEDH_Y1 X
          WHERE X.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
            AND X.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
            AND X.TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE
            AND X.RejectInd_INDC = @Lc_No_INDC

         IF EXISTS(SELECT 1
                     FROM IFMS_Y1 X
                    WHERE X.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
                      AND X.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE)
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT INTO HIFMS';
           SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '')

           INSERT INTO HIFMS_Y1
           SELECT *
             FROM IFMS_Y1 H
            WHERE MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
              AND TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
AND NOT EXISTS(SELECT 1 FROM HIFMS_Y1 X
WHERE X.Case_IDNO = H.Case_IDNO
AND X.MemberMci_IDNO = H.MemberMci_IDNO
AND X.SubmitLast_DATE = H.SubmitLast_DATE
AND X.TaxYear_NUMB = H.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = H.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = H.TypeArrear_CODE
AND X.TypeTransaction_CODE = H.TypeTransaction_CODE)

           SET @Ls_Sql_TEXT = 'DELETE FROM IFMS_Y1';
           SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '')

           DELETE FROM IFMS_Y1
            WHERE MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
              AND TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
              AND TypeTransaction_CODE NOT IN ('A', 'M')

/*
	check and delete old but latest record from ifms before update
	to avoid primary key violation error.
*/

SET @Ls_Sql_TEXT = 'DELETE OLD BUT LATEST RECORD FROM IFMS';
SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '')

IF EXISTS(SELECT 1 FROM (SELECT Row_NUMB = Row_NUMBER() OVER (PARTITION BY A.MemberMci_IDNO, A.Case_IDNO, A.TypeArrear_CODE ORDER BY A.SubmitLast_DATE DESC, A.TransactionEventSeq_NUMB DESC)
, A.*
FROM IFMS_Y1 A 
WHERE A.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
AND A.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
AND A.TypeTransaction_CODE IN ('A', 'M', 'D')) B
WHERE B.Row_NUMB > 1)
BEGIN
   DELETE B
   FROM
	(SELECT Row_NUMB = Row_NUMBER() OVER (PARTITION BY A.MemberMci_IDNO, A.Case_IDNO, A.TypeArrear_CODE ORDER BY A.SubmitLast_DATE DESC, A.TransactionEventSeq_NUMB DESC)
	, A.*
	FROM IFMS_Y1 A 
	WHERE A.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
	AND A.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
	AND A.TypeTransaction_CODE IN ('A', 'M', 'D')) B
	WHERE B.Row_NUMB > 1
END
           
           SET @Ls_Sql_TEXT = 'GET DATA FROM D RECORD IN FEDH';
           SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_AutoResCur_MemberMci_IDNO AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_AutoResCur_TypeArrear_CODE, '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_AutoResCur_TypeTransaction_CODE, '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@Ld_FedhTaxYear_NUMB AS VARCHAR), '') + ', SubmitLast_DATE = ' + ISNULL(CAST(@Ld_FedhSubmitLast_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')

           UPDATE A
              SET A.TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE,
                  A.TaxYear_NUMB = @Ld_FedhTaxYear_NUMB,
                  A.SubmitLast_DATE = @Ld_FedhSubmitLast_DATE,
                  A.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
                  A.WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
                  A.Certified_DATE = @Ld_High_DATE,
                  A.Transaction_AMNT = @Ln_Zero_NUMB,
                  A.ExcludeIrs_CODE = @Lc_FedhExcludeIrs_CODE,
                  A.ExcludeAdm_CODE = @Lc_FedhExcludeAdm_CODE,
                  A.ExcludeFin_CODE = @Lc_FedhExcludeFin_CODE,
                  A.ExcludePas_CODE = @Lc_FedhExcludePas_CODE,
                  A.ExcludeRet_CODE = @Lc_FedhExcludeRet_CODE,
                  A.ExcludeSal_CODE = @Lc_FedhExcludeSal_CODE,
                  A.ExcludeDebt_CODE = @Lc_FedhExcludeDebt_CODE,
                  A.ExcludeVen_CODE = @Lc_FedhExcludeVen_CODE,
                  A.ExcludeIns_CODE = @Lc_FedhExcludeIns_CODE,
                  A.Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
             FROM IFMS_Y1 A
            WHERE A.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
              AND A.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
              AND A.TypeTransaction_CODE IN ('A', 'M')
              AND EXISTS(SELECT 1
                           FROM FEDH_Y1 X
                          WHERE X.MemberMci_IDNO = @Ln_AutoResCur_MemberMci_IDNO
                            AND X.TypeArrear_CODE = @Lc_AutoResCur_TypeArrear_CODE
                            AND X.TypeTransaction_CODE = @Lc_AutoResCur_TypeTransaction_CODE
                            AND X.RejectInd_INDC = @Lc_No_INDC)
AND 1 = (SELECT COUNT(1) FROM IFMS_Y1 X
WHERE X.Case_IDNO = A.Case_IDNO
AND X.MemberMci_IDNO = A.MemberMci_IDNO
AND X.SubmitLast_DATE = A.SubmitLast_DATE
AND X.TaxYear_NUMB = A.TaxYear_NUMB
AND X.TransactionEventSeq_NUMB = A.TransactionEventSeq_NUMB
AND X.TypeArrear_CODE = A.TypeArrear_CODE
AND X.TypeTransaction_CODE = A.TypeTransaction_CODE)
                            
          END
        END
      END

     SET @Ls_Sql_TEXT = 'FETCH AutoRes_CUR - 2';

     FETCH NEXT FROM AutoRes_CUR INTO @Ln_AutoResCur_MemberSsn_NUMB, @Lc_AutoResCur_TypeArrear_CODE, @Ln_AutoResCur_MemberMci_IDNO, @Lc_AutoResCur_TypeTransaction_CODE;

     SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;
    END

   CLOSE AutoRes_CUR;

   DEALLOCATE AutoRes_CUR;

   SET @Ls_Sql_TEXT = 'SELECT - RJDT_Y1,RJCS_Y1';

   DECLARE RjdtRjcs_CUR INSENSITIVE CURSOR FOR
    SELECT r.MemberSsn_NUMB,
           r.ArrearIdentifier_IDNO,
           r.TypeArrear_CODE,
           r.TransactionType_CODE,
           r.MemberMci_IDNO,
           c.Case_IDNO
      FROM RJDT_Y1 r,
           RJCS_Y1 c
     WHERE r.MemberMci_IDNO = c.MemberMci_IDNO
       AND r.TypeArrear_CODE = c.TypeArrear_CODE
       AND r.TransactionType_CODE NOT IN (@Lc_TypeTranscS_CODE)
       AND (r.Reject1_CODE = @Ac_Error_CODE
             OR r.Reject2_CODE = @Ac_Error_CODE
             OR r.Reject3_CODE = @Ac_Error_CODE
             OR r.Reject4_CODE = @Ac_Error_CODE
             OR r.Reject5_CODE = @Ac_Error_CODE
             OR r.Reject6_CODE = @Ac_Error_CODE)
       AND r.EndValidity_DATE = @Ld_High_DATE
       AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN RjdtRjcs_CUR';

   OPEN RjdtRjcs_CUR;

   SET @Ls_Sql_TEXT = 'FETCH RjdtRjcs_CUR - 1';

   FETCH NEXT FROM RjdtRjcs_CUR INTO @Ln_RjdtRjcsCur_MemberSsn_NUMB, @Ln_RjdtRjcsCur_ArrearIdentifier_IDNO, @Lc_RjdtRjcsCur_TypeArrear_CODE, @Lc_RjdtRjcsCur_TransactionType_CODE, @Ln_RjdtRjcsCur_MemberMci_IDNO, @Ln_RjdtRjcsCur_Case_IDNO;

   SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE RJDT_Y1 WITH CODE 17 OR 06/39';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_RjdtRjcsCur_MemberMci_IDNO AS VARCHAR), '');

     UPDATE A
        SET EndValidity_DATE = @Ld_Run_DATE,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
      FROM RJDT_Y1 A
     WHERE MemberMci_IDNO = @Ln_RjdtRjcsCur_MemberMci_IDNO

     SET @Ls_Sql_TEXT = 'UPDATE RJCS_Y1 WITH CODE 17 OR 06/39';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_RjdtRjcsCur_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

     UPDATE a
        SET EndValidity_DATE = @Ld_Run_DATE,
            WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
            Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
       FROM RJCS_Y1 a
      WHERE Case_IDNO = @Ln_RjdtRjcsCur_Case_IDNO
        AND NOT EXISTS (SELECT 1
                          FROM RJDT_Y1 b
                         WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                           AND b.TypeArrear_CODE = a.TypeArrear_CODE
                           AND b.EndValidity_DATE = '12/31/9999')

     SET @Ls_Sql_TEXT = 'INSERT -RJDT_Y1 FOR REJECT CODE 17';

     IF @Ac_Error_CODE = @Lc_Error17_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
       SET @Ls_Sqldata_TEXT = '';

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Lc_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
        @Ac_Note_INDC                = @Lc_No_INDC,
        @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

         RAISERROR (50001,16,1);
        END

       SET @Ls_SqlData_TEXT = 'County_IDNO = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_RjdtRjcsCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_RjdtRjcsCur_MemberSsn_NUMB AS VARCHAR), '') + ', ArrearIdentifier_IDNO = ' + ISNULL(@Lc_ArrearTypB_CODE, '') + ', Last_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', First_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Arrear_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_RjdtRjcsCur_TypeArrear_CODE, '') + ', TransactionType_CODE = ' + ISNULL(@Lc_RjdtRjcsCur_TransactionType_CODE, '') + ', ExcludeIrs_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExcludeAdm_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExcludeFin_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExcludePas_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExcludeRet_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExcludeSal_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExcludeDebt_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExcludeVen_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', ExcludeIns_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', Rejected_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Reject1_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reject2_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reject3_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reject4_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reject5_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reject6_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeReject1_CODE = ' + ISNULL(@Lc_RejectTypA_CODE, '') + ', TypeReject2_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeReject3_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeReject4_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeReject5_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', TypeReject6_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

       INSERT INTO RJDT_Y1
                   (County_IDNO,
                    MemberMci_IDNO,
                    MemberSsn_NUMB,
                    ArrearIdentifier_IDNO,
                    Last_NAME,
                    First_NAME,
                    Arrear_AMNT,
                    TypeArrear_CODE,
                    TransactionType_CODE,
                    ExcludeIrs_INDC,
                    ExcludeAdm_INDC,
                    ExcludeFin_INDC,
                    ExcludePas_INDC,
                    ExcludeRet_INDC,
                    ExcludeSal_INDC,
                    ExcludeDebt_INDC,
                    ExcludeVen_INDC,
                    ExcludeIns_INDC,
                    Rejected_DATE,
                    Reject1_CODE,
                    Reject2_CODE,
                    Reject3_CODE,
                    Reject4_CODE,
                    Reject5_CODE,
                    Reject6_CODE,
                    TypeReject1_CODE,
                    TypeReject2_CODE,
                    TypeReject3_CODE,
                    TypeReject4_CODE,
                    TypeReject5_CODE,
                    TypeReject6_CODE,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB)
            SELECT @Ln_Zero_NUMB AS County_IDNO
                    ,@Ln_RjdtRjcsCur_MemberMci_IDNO AS MemberMci_IDNO
                    ,@Ln_RjdtRjcsCur_MemberSsn_NUMB AS MemberSsn_NUMB
                    ,@Ln_Zero_NUMB AS ArrearIdentifier_IDNO
                    ,@Lc_Space_TEXT AS Last_NAME
                    ,@Lc_Space_TEXT AS First_NAME
                    ,@Ln_Zero_NUMB AS Arrear_AMNT
                    ,@Lc_RjdtRjcsCur_TypeArrear_CODE AS TypeArrear_CODE
                    ,@Lc_TypeTranscB_CODE AS TransactionType_CODE
                    ,@Lc_Space_TEXT AS ExcludeIrs_INDC
                    ,@Lc_Space_TEXT AS ExcludeAdm_INDC
                    ,@Lc_Space_TEXT AS ExcludeFin_INDC
                    ,@Lc_Space_TEXT AS ExcludePas_INDC
                    ,@Lc_Space_TEXT AS ExcludeRet_INDC
                    ,@Lc_Space_TEXT AS ExcludeSal_INDC
                    ,@Lc_Space_TEXT AS ExcludeDebt_INDC
                    ,@Lc_Space_TEXT AS ExcludeVen_INDC
                    ,@Lc_Space_TEXT AS ExcludeIns_INDC
                    ,@Ld_Run_DATE AS Rejected_DATE
                    ,@Lc_Space_TEXT AS Reject1_CODE
                    ,@Lc_Space_TEXT AS Reject2_CODE
                    ,@Lc_Space_TEXT AS Reject3_CODE
                    ,@Lc_Space_TEXT AS Reject4_CODE
                    ,@Lc_Space_TEXT AS Reject5_CODE
                    ,@Lc_Space_TEXT AS Reject6_CODE
                    ,@Lc_RejectTypA_CODE AS TypeReject1_CODE
                    ,@Lc_Space_TEXT AS TypeReject2_CODE
                    ,@Lc_Space_TEXT AS TypeReject3_CODE
                    ,@Lc_Space_TEXT AS TypeReject4_CODE
                    ,@Lc_Space_TEXT AS TypeReject5_CODE
                    ,@Lc_Space_TEXT AS TypeReject6_CODE
                    ,@Ld_Run_DATE AS BeginValidity_DATE
                    ,@Ld_High_DATE AS EndValidity_DATE
                    ,@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID
                    ,dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM
                    ,@Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       
      END

     SET @Ls_Sql_TEXT = 'FETCH RjdtRjcs_CUR - 2';

     FETCH NEXT FROM RjdtRjcs_CUR INTO @Ln_RjdtRjcsCur_MemberSsn_NUMB, @Ln_RjdtRjcsCur_ArrearIdentifier_IDNO, @Lc_RjdtRjcsCur_TypeArrear_CODE, @Lc_RjdtRjcsCur_TransactionType_CODE, @Ln_RjdtRjcsCur_MemberMci_IDNO, @Ln_RjdtRjcsCur_Case_IDNO;

     SET @Li_FetchStatus_QNTY=@@FETCH_STATUS;
    END

   CLOSE RjdtRjcs_CUR;

   DEALLOCATE RjdtRjcs_CUR;

   SET @Ac_Msg_CODE = @Lc_Success_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('LOCAL', 'AutoRes_CUR') IN (0, 1)
    BEGIN
     CLOSE AutoRes_CUR;

     DEALLOCATE AutoRes_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'Ifms_CUR') IN (0, 1)
    BEGIN
     CLOSE Ifms_CUR;

     DEALLOCATE Ifms_CUR;
    END

   IF CURSOR_STATUS ('LOCAL', 'RjdtRjcs_CUR') IN (0, 1)
    BEGIN
     CLOSE RjdtRjcs_CUR;

     DEALLOCATE RjdtRjcs_CUR;
    END

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
