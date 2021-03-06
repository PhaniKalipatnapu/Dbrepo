/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_IRS_RECON$SP_EXTRACT_IRS_RECON]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_OUTGOING_IRS_RECON$SP_EXTRACT_IRS_RECON
Programmer Name   : IMP Team
Description       : This batch extracts the case reconciliation file to be submitted to IRS.
Frequency         : Annually
Developed On      : 07/19/2011
Called BY         : None
Called On		  : BATCH_COMMON$SP_GET_BATCH_DETAILS ,
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_EXTRACT_DATA,
                    BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 0.01
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_IRS_RECON$SP_EXTRACT_IRS_RECON]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_CaseStatusOpen_CODE         CHAR(1) = 'O',
          @Lc_StatusAbnormalend_CODE      CHAR(1) = 'A',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_No_INDC                     CHAR(1) = 'N',
          @Lc_ErrrorTypeW_CODE            CHAR(1) = 'W',
          @Lc_TransactionTypeAddCase_CODE CHAR(1) = 'A',
          @Lc_TransactionTypeDelete_CODE  CHAR(1) = 'D',
          @Lc_TransactionTypestate_CODE   CHAR(1) = 'S',
          @Lc_CaseTypeTanf_CODE           CHAR(1) = 'A',
          @Lc_CaseTypeNonTanf_CODE        CHAR(1) = 'N',
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_Msg_CODE                    CHAR(1) = ' ',
          @Lc_StateInState_CODE           CHAR(2) = 'DE',
          @Lc_Control_TEXT                CHAR(3) = 'CTL',
          @Lc_ExclusionsAdm_CODE		  CHAR(4) = 'ADM ',
          @Lc_ExclusionsRet_CODE          CHAR(4) = 'RET ',
          @Lc_ExclusionsSal_CODE          CHAR(4) = 'SAL ',
          @Lc_ExclusionsVen_CODE          CHAR(4) = 'VEN ',
          @Lc_ExclusionsPas_CODE          CHAR(4) = 'PAS ',
          @Lc_ExclusionsIns_CODE          CHAR(4) = 'INS ',
          @Lc_ExclusionsTax_CODE          CHAR(4) = 'TAX ',
          @Lc_ExclusionsDck_CODE          CHAR(4) = 'DCK ',
          @Lc_ExclusionsFin_CODE          CHAR(4) = 'FIN ',
          @Lc_BatchRunUser_TEXT           CHAR(5) = 'BATCH',
          @Lc_ErrrorE0944_CODE            CHAR(5) = 'E0944',
          @Lc_Notice_ID					  CHAR(6) = 'ENF-24',
          @Lc_Job_ID                      CHAR(7) = 'DEB9020',
          @Lc_Successful_TEXT             CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT        VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME              VARCHAR(100) = 'SP_EXTRACT_IRS_RECON',
          @Ls_Process_NAME                VARCHAR(100) = 'BATCH_ENF_OUTGOING_IRS_RECON';
  DECLARE @Ln_Zero_NUMB                   NUMERIC(1) = 0,
          @Ln_ProcessYear_NUMB            NUMERIC(4),
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_TanfCount_NUMB              NUMERIC(9),
          @Ln_NonTanfCount_NUMB           NUMERIC(9),
          @Ln_Error_NUMB                  NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(10),
          @Ln_Tanf_AMNT                   NUMERIC(11, 0),
          @Ln_NonTanf_AMNT                NUMERIC(11, 0),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(19) = 0,
          @Lc_FileTotRecCount_TEXT        CHAR(7),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_Query_TEXT                  VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'TEMP TABLE CREATION';
   SET @Ls_Sqldata_TEXT = 'Job Id = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtIrsRecon_P1
    (
      Record_TEXT VARCHAR(245)
    );

   BEGIN TRANSACTION OUTGOING_IRSRECON;

   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job Id = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job Id = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   SET @Ln_ProcessYear_NUMB = DATEPART(YEAR, @Ld_Run_DATE);
   SET @Ls_Sql_TEXT = 'DELETE EIREC_Y1';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE EIREC_Y1;

   SET @Ls_Sql_TEXT ='BULK INSERT INTO EIREC_Y1 TABLE - 1, Verifying in FEDH_Y1 table';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO EIREC_Y1
               (SubmitState_CODE,
                County_IDNO,
                MemberSsn_NUMB,
                Case_IDNO,
                Last_NAME,
                First_NAME,
                Arrears_AMNT,
                TransType_CODE,
                TypeCase_CODE,
                ProcessYear_NUMB,
                Issued_DATE,
                Exclusion_CODE)
   SELECT t.SubmitState_CODE,
          t.County_IDNO,
          t.MemberSsn_NUMB,
          t.Case_IDNO,
          t.Last_NAME,
          t.First_NAME,
          RIGHT(ISNULL(FLOOR(t.Arrears_AMNT), @Ln_Zero_NUMB), 8) Arrears_AMNT,
          t.TransType_CODE,
          t.TypeCase_CODE,
          @Ln_ProcessYear_NUMB AS ProcessYear_NUMB,
          ISNULL(CONVERT(VARCHAR, t.Issued_DATE, 112), CONVERT(VARCHAR, t.SubmitLast_DATE, 112)) AS Issued_DATE,
          t.Exclusion_CODE
     FROM (SELECT DISTINCT
                  f.MemberMci_IDNO AS MemberMci_IDNO,
                  @Lc_StateInState_CODE AS SubmitState_CODE,
                  f.CountyFips_CODE AS County_IDNO,
                  f.MemberSsn_NUMB AS MemberSsn_NUMB,
                  f.MemberMci_IDNO AS Case_IDNO,
                  UPPER(REPLACE(f.Last_NAME, '''','')) AS Last_NAME,
                  UPPER(f.First_NAME) AS First_NAME,
                  f.Arrear_AMNT AS Arrears_AMNT,
                  @Lc_TransactionTypeAddCase_CODE AS TransType_CODE,
                  f.TypeArrear_CODE AS TypeCase_CODE,
                  f.TaxYear_NUMB AS TaxYear_NUMB,
                  n.Request_DTTM AS Issued_DATE,
                  f.SubmitLast_DATE AS SubmitLast_DATE,
				  CASE
					WHEN f.ExcludeAdm_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsAdm_CODE
					END 
				+ CASE
					WHEN f.ExcludeRet_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsRet_CODE
					END 
				+ CASE
					WHEN f.ExcludeVen_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsVen_CODE
					END 
				+ CASE
					WHEN f.ExcludeSal_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsSal_CODE
					END 
				+ CASE
					WHEN f.ExcludeIrs_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsTax_CODE
					END 
				+ CASE
					WHEN f.ExcludePas_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsPas_CODE
					END 
				+ CASE
					WHEN f.ExcludeFin_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsFin_CODE
					END 
				+ CASE
					WHEN f.ExcludeDebt_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsDck_CODE
					END 
				+ CASE
					WHEN f.ExcludeIns_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsIns_CODE
					END AS Exclusion_CODE
             FROM FEDH_Y1 f
                  JOIN ENSD_Y1 e ON e.NcpPf_IDNO = f.MemberMci_IDNO
									  AND e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
									  AND e.Arrears_AMNT > @Ln_Zero_NUMB
                  LEFT JOIN (SELECT a.Recipient_ID,
                                    a.Request_DTTM
                               FROM (SELECT CAST(Recipient_ID AS NUMERIC) AS Recipient_ID,
                                            CAST(Request_DTTM AS DATE) AS Request_DTTM,
                                            ROW_NUMBER() OVER (PARTITION BY CAST(Recipient_ID AS NUMERIC) ORDER BY Request_DTTM DESC) AS RowNum
                                       FROM NRRQ_Y1 m
                                      WHERE ISNUMERIC(m.Recipient_ID) = 1
										 AND m.Notice_ID = @Lc_Notice_ID) a
                              WHERE a.RowNum = 1) n
                   ON f.MemberMci_IDNO = n.Recipient_ID
				
            WHERE NOT EXISTS (SELECT 1
                                FROM FEDH_Y1 h
                               WHERE h.TypeTransaction_CODE IN (@Lc_TransactionTypeDelete_CODE, @Lc_TransactionTypestate_CODE)
                                 AND f.MemberMci_IDNO = h.MemberMci_IDNO
                                 AND f.TypeArrear_CODE = h.TypeArrear_CODE
                                 AND h.SubmitLast_DATE = (SELECT MAX (D.SubmitLast_DATE)
                                                            FROM FEDH_Y1 d
                                                           WHERE d.MemberMci_IDNO = h.MemberMci_IDNO
                                                             AND d.TypeArrear_CODE = h.TypeArrear_CODE))
              AND f.TypeArrear_CODE IN (@Lc_CaseTypeTanf_CODE, @Lc_CaseTypeNonTanf_CODE)
              AND f.SubmitLast_DATE = (SELECT MAX (d.SubmitLast_DATE)
                                         FROM FEDH_Y1 d
                                        WHERE d.MemberMci_IDNO = f.MemberMci_IDNO
                                          AND d.TypeArrear_CODE = f.TypeArrear_CODE)
              AND (f.RejectInd_INDC = @Lc_No_INDC
                   AND NOT EXISTS (SELECT 1
                                     FROM HFEDH_Y1 l
                                    WHERE l.MemberMci_IDNO = f.MemberMci_IDNO
                                      AND l.TypeArrear_CODE = f.TypeArrear_CODE
                                      AND l.TypeTransaction_CODE = f.TypeTransaction_CODE
                                      AND l.SubmitLast_DATE = f.SubmitLast_DATE
                                      AND l.TaxYear_NUMB = f.TaxYear_NUMB
                                      AND l.RejectInd_INDC = @Lc_Yes_INDC))) t;

   SET @Ls_Sql_TEXT ='BULK INSERT INTO #Historyfedh_P1 FROM HFEDH_Y1 table';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
 
   SELECT t.SubmitState_CODE,
          t.County_IDNO,
          t.MemberSsn_NUMB,
          t.Case_IDNO,
          t.Last_NAME,
          t.First_NAME,
          RIGHT(ISNULL(FLOOR(t.Arrears_AMNT), @Ln_Zero_NUMB), 8) Arrears_AMNT,
          t.TransType_CODE,
          t.TypeCase_CODE,
          @Ln_ProcessYear_NUMB AS ProcessYear_NUMB,
          t.SubmitLast_DATE,
          t.Exclusion_CODE
     INTO #Historyfedh_P1
     FROM (SELECT j.MemberMci_IDNO AS MemberMci_IDNO,
                  @Lc_StateInState_CODE AS SubmitState_CODE,
                  j.CountyFips_CODE AS County_IDNO,
                  j.MemberSsn_NUMB AS MemberSsn_NUMB,
                  j.MemberMci_IDNO AS Case_IDNO,
                  UPPER(REPLACE(j.Last_NAME, '''','')) AS Last_NAME,
                  UPPER(j.First_NAME) AS First_NAME,
                  j.Arrear_AMNT AS Arrears_AMNT,
                  @Lc_TransactionTypeAddCase_CODE AS TransType_CODE,
                  j.TypeArrear_CODE AS TypeCase_CODE,
                  j.TaxYear_NUMB AS TaxYear_NUMB,
                  j.SubmitLast_DATE AS SubmitLast_DATE,
				  CASE
					WHEN j.ExcludeAdm_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsAdm_CODE
					END 
				+ CASE
					WHEN j.ExcludeRet_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsRet_CODE
					END 
				+ CASE
					WHEN j.ExcludeVen_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsVen_CODE
					END 
				+ CASE
					WHEN j.ExcludeSal_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsSal_CODE
					END 
				+ CASE
					WHEN j.ExcludeIrs_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsTax_CODE
					END 
				+ CASE
					WHEN j.ExcludePas_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsPas_CODE
					END 
				+ CASE
					WHEN j.ExcludeFin_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsFin_CODE
					END 
				+ CASE
					WHEN j.ExcludeDebt_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsDck_CODE
					END 
				+ CASE
					WHEN j.ExcludeIns_CODE = @Lc_No_INDC
					THEN @Lc_Space_TEXT
					ELSE @Lc_ExclusionsIns_CODE
					END AS Exclusion_CODE
             FROM HFEDH_Y1 j
            WHERE j.Arrear_AMNT > 0
              AND j.TypeTransaction_CODE NOT IN (@Lc_TransactionTypeDelete_CODE, @Lc_TransactionTypestate_CODE)
              AND TransactionEventSeq_NUMB = (SELECT MAX (TransactionEventSeq_NUMB)
                                                FROM HFEDH_Y1 F
                                               WHERE f.MemberMci_IDNO = j.MemberMci_IDNO
                                                 AND f.TypeArrear_CODE = j.TypeArrear_CODE
                                                 AND (f.RejectInd_INDC = @Lc_No_INDC
                                                      AND EXISTS (SELECT 1
                                                                    FROM FEDH_Y1 l
                                                                   WHERE l.MemberMci_IDNO = f.MemberMci_IDNO
                                                                     AND l.TypeArrear_CODE = f.TypeArrear_CODE
                                                                     AND l.TypeTransaction_CODE NOT IN (@Lc_TransactionTypeAddCase_CODE, @Lc_TransactionTypeDelete_CODE, @Lc_TransactionTypestate_CODE)
                                                                     AND l.Arrear_AMNT > 0
                                                                     AND l.RejectInd_INDC = @Lc_Yes_INDC
                                                                  UNION
                                                                  SELECT 1
                                                                    FROM FEDH_Y1 m
                                                                   WHERE m.MemberMci_IDNO = f.MemberMci_IDNO
                                                                     AND m.TypeArrear_CODE = f.TypeArrear_CODE
                                                                     AND m.TypeTransaction_CODE NOT IN (@Lc_TransactionTypeAddCase_CODE, @Lc_TransactionTypeDelete_CODE, @Lc_TransactionTypestate_CODE)
                                                                     AND m.RejectInd_INDC = @Lc_No_INDC
                                                                     AND EXISTS (SELECT 1
                                                                                   FROM HFEDH_Y1 n
                                                                                  WHERE n.MemberMci_IDNO = m.MemberMci_IDNO
                                                                                    AND n.TypeArrear_CODE = m.TypeArrear_CODE
                                                                                    AND n.SubmitLast_DATE = m.SubmitLast_DATE
                                                                                    AND n.TypeTransaction_CODE = m.TypeTransaction_CODE
                                                                                    AND n.TaxYear_NUMB = m.TaxYear_NUMB
                                                                                    AND n.RejectInd_INDC = @Lc_Yes_INDC)))
                                                 AND (f.RejectInd_INDC = @Lc_No_INDC
                                                      AND NOT EXISTS (SELECT 1
                                                                        FROM FEDH_Y1 a
                                                                       WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
                                                                         AND a.TypeArrear_CODE = f.TypeArrear_CODE
                                                                         AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
                                                                         AND a.SubmitLast_DATE = f.SubmitLast_DATE
                                                                         AND a.TaxYear_NUMB = f.TaxYear_NUMB
                                                                         AND a.RejectInd_INDC = @Lc_Yes_INDC))
                                                 AND NOT EXISTS (SELECT 1
                                                                   FROM HFEDH_Y1 a
                                                                  WHERE a.MemberMci_IDNO = f.MemberMci_IDNO
                                                                    AND a.TypeArrear_CODE = f.TypeArrear_CODE
                                                                    AND a.TypeTransaction_CODE = f.TypeTransaction_CODE
                                                                    AND a.SubmitLast_DATE = f.SubmitLast_DATE
                                                                    AND a.TaxYear_NUMB = f.TaxYear_NUMB
                                                                    AND a.RejectInd_INDC = @Lc_Yes_INDC))) t;
   SET @Ls_Sql_TEXT ='BULK INSERT INTO EIREC_Y1 TABLE - 2, Verifying in HFEDH_Y1 table';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   
   INSERT INTO EIREC_Y1
				   (SubmitState_CODE,
					County_IDNO,
					MemberSsn_NUMB,
					Case_IDNO,
					Last_NAME,
					First_NAME,
					Arrears_AMNT,
					TransType_CODE,
					TypeCase_CODE,
					ProcessYear_NUMB,
					Issued_DATE,
					Exclusion_CODE)
   SELECT DISTINCT a.SubmitState_CODE,
					a.County_IDNO,
					a.MemberSsn_NUMB,
					a.Case_IDNO,
					a.Last_NAME,
					a.First_NAME,
					a.Arrears_AMNT,
					a.TransType_CODE,
					a.TypeCase_CODE,
					a.ProcessYear_NUMB,
					ISNULL(CONVERT(VARCHAR, n.Request_DTTM, 112), CONVERT(VARCHAR, a.SubmitLast_DATE, 112)) AS Issued_DATE,
					a.Exclusion_CODE
			FROM #Historyfedh_P1 a
			JOIN ENSD_Y1 e ON e.NcpPf_IDNO = a.Case_IDNO
				AND e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
				AND e.Arrears_AMNT > @Ln_Zero_NUMB
            LEFT JOIN (SELECT a.Recipient_ID,
							a.Request_DTTM
					   FROM (SELECT CAST(Recipient_ID AS NUMERIC) AS Recipient_ID,
									CAST(Request_DTTM AS DATE) AS Request_DTTM,
									ROW_NUMBER() OVER (PARTITION BY CAST(Recipient_ID AS NUMERIC) ORDER BY Request_DTTM DESC) AS RowNum
							   FROM NRRQ_Y1 m
							  WHERE ISNUMERIC(m.Recipient_ID) = 1
								AND m.Notice_ID = @Lc_Notice_ID) a
					  WHERE a.RowNum = 1)n
			ON a.Case_IDNO = n.Recipient_ID;

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM EIREC_Y1 a);

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO EXTRACT';
     SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrrorTypeW_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ln_TanfCount_NUMB = ISNULL((SELECT COUNT(1)
                                      FROM EIREC_Y1 a
                                     WHERE a.TypeCase_CODE = @Lc_CaseTypeTanf_CODE), @Ln_Zero_NUMB);
   SET @Ln_NonTanfCount_NUMB = ISNULL((SELECT COUNT(1)
                                         FROM EIREC_Y1 a
                                        WHERE a.TypeCase_CODE = @Lc_CaseTypeNonTanf_CODE), @Ln_Zero_NUMB);
   SET @Ln_Tanf_AMNT = ISNULL((SELECT SUM(CAST(a.Arrears_AMNT AS NUMERIC))
                                 FROM EIREC_Y1 a
                                WHERE a.TypeCase_CODE = @Lc_CaseTypeTanf_CODE), 0);
   SET @Ln_NonTanf_AMNT = ISNULL((SELECT SUM(CAST(a.Arrears_AMNT AS NUMERIC))
                                    FROM EIREC_Y1 a
                                   WHERE a.TypeCase_CODE = @Lc_CaseTypeNonTanf_CODE), 0);
   SET @Ls_Sql_TEXT = 'INSERT DETAIL RECORD INTO ##ExtIrsRecon_P1';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtIrsRecon_P1
               (Record_TEXT)
   SELECT (CONVERT(CHAR(2), SubmitState_CODE) + CONVERT(CHAR(3), County_IDNO) + RIGHT(('000000000' + LTRIM(RTRIM(MemberSsn_NUMB))), 9) + CONVERT(CHAR(15), CASE_IDNO) + CONVERT(CHAR(20), Last_NAME) + CONVERT(CHAR(15), First_NAME) + RIGHT(('00000000' + LTRIM(RTRIM(Arrears_AMNT))), 8) + CONVERT(CHAR(1), TransType_CODE) + CONVERT(CHAR(1), TypeCase_CODE) + REPLICATE(@Lc_Space_TEXT, 5) + CONVERT(CHAR(4), ProcessYear_NUMB) + REPLICATE(@Lc_Space_TEXT, 96) + CONVERT(CHAR(8), Issued_DATE) + CONVERT(CHAR(40), Exclusion_CODE) + REPLICATE(@Lc_Space_TEXT, 18)) Record_TEXT
     FROM EIREC_Y1 a;

   SET @Lc_FileTotRecCount_TEXT = RIGHT(('0000000' + LTRIM(RTRIM(@Ln_ProcessedRecordCount_QNTY))), 7);
   SET @Ls_Sql_TEXT = 'INSERT Trailer record into ##ExtIrsRecon_P1';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtIrsRecon_P1
               (Record_TEXT)
   SELECT CONVERT(CHAR(2), @Lc_StateInState_CODE) + @Lc_Control_TEXT + RIGHT(('000000000' + LTRIM(RTRIM(@Ln_TanfCount_NUMB))), 9) + RIGHT(('000000000' + LTRIM(RTRIM(@Ln_NonTanfCount_NUMB))), 9) + RIGHT(('00000000000' + LTRIM(RTRIM(@Ln_Tanf_AMNT))), 11) + RIGHT(('00000000000' + LTRIM(RTRIM(@Ln_NonTanf_AMNT))), 11) + REPLICATE(@Lc_Space_TEXT, 200) Record_TEXT;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtIrsRecon_P1 ORDER BY Record_TEXT';
   SET @Ls_Sql_TEXT = 'EXTRACT DATA';
   SET @Ls_Sqldata_TEXT = ' FILE Location = ' + @Ls_FileLocation_TEXT + ', Ls_File_NAME = ' + @Ls_File_NAME + ', Query TEXT = ' + @Ls_Query_TEXT;

   COMMIT TRANSACTION OUTGOING_IRSRECON;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION OUTGOING_IRSRECON;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST (@Ld_Run_DATE AS VARCHAR) + ', START DATE = ' + CAST (@Ld_Start_DATE AS VARCHAR) + ', PACKAGE NAME = ' + @Ls_Process_NAME + ', PROCEDURE NAME = ' + @Ls_Procedure_NAME + ', CURSOR LOCATION = ' + @Ls_CursorLocation_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP ##ExtIrsRecon_P1 TABLE';
   SET @Ls_Sqldata_TEXT= 'Job Id = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE ##ExtIrsRecon_P1;
   DROP TABLE #Historyfedh_P1;

   COMMIT TRANSACTION OUTGOING_IRSRECON;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION OUTGOING_IRSRECON;
    END

   IF OBJECT_ID('tempdb..##ExtIrsRecon_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtIrsRecon_P1;
    END

   IF OBJECT_ID('tempdb..#Historyfedh_P1') IS NOT NULL
    BEGIN
     DROP TABLE #Historyfedh_P1;
    END
    
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
