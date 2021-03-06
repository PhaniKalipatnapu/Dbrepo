/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_CERTIFICATION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_CERTIFICATION
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_CERTIFICATION is 
					  to insert into #IstxData_P1
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_CERTIFICATION]
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_Case_IDNO             NUMERIC(6),
 @An_TaxYear_NUMB          NUMERIC(4),
 @Ad_Run_DATE              DATE,
 @An_MemberSsn_NUMB        NUMERIC(9),
 @An_NonTanfArrear_AMNT    NUMERIC(11, 2),
 @An_TanfArrear_AMNT       NUMERIC(11, 2),
 @Ac_NonTanfCertified_INDC CHAR(01),
 @Ac_TanfCertified_INDC    CHAR(01),
 @Ad_Notice_DATE           DATE,
 @Ac_CountyFips_CODE       CHAR(03),
 @Ac_Job_ID                CHAR(07),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_No_INDC            CHAR(1) = 'N',
          @Lc_BatchRunUser_TEXT  CHAR(5) = 'BATCH',
          @Lc_Job_ID             CHAR(7) = @Ac_Job_ID,
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_INSERT_CERTIFICATION',
          @Ld_Run_DATE           DATE = @Ad_Run_DATE;
  DECLARE @Ln_EventFunctionalSeq_NUMB  NUMERIC(4) = 0,
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB NUMERIC(19) = 0,
          @Lc_Empty_TEXT               CHAR = '',
          @Lc_Note_INDC                CHAR(1) = '',
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_TypeArrearN_CODE         CHAR(1) = '',
          @Lc_TypeArrearT_CODE         CHAR(1) = '',
          @Lc_TypeTransactionN_CODE    CHAR(1) = '',
          @Lc_TypeTransactionT_CODE    CHAR(1) = '',
          @Lc_TypeReferenceSto_CODE    CHAR(5) = 'STO',
          @Lc_ActivityMajorAren_CODE   CHAR(4) = 'AREN',
          @Lc_StatusStrt_CODE          CHAR(4) = 'STRT',
          @Ls_Sql_TEXT                 VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(200),
          @Ls_SqlData_TEXT             VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT    VARCHAR(4000);

  BEGIN TRY
   SET @Lc_TypeArrearN_CODE = '';
   SET @Lc_TypeArrearT_CODE = '';
   SET @Lc_TypeTransactionN_CODE = '';
   SET @Lc_TypeTransactionT_CODE = '';
   SET @Ls_Sql_TEXT = 'SET FOR DELETE (D) TRANSACTION';

   IF (@Ac_NonTanfCertified_INDC = 'Y'
       AND (@An_NonTanfArrear_AMNT = 0
             OR @An_MemberSsn_NUMB = 0))
    BEGIN
     SET @Lc_TypeTransactionN_CODE = 'D';
     SET @Lc_TypeArrearN_CODE = 'N';
    END

   IF (@Ac_TanfCertified_INDC = 'Y'
       AND (@An_TanfArrear_AMNT = 0
             OR @An_MemberSsn_NUMB = 0))
    BEGIN
     SET @Lc_TypeTransactionT_CODE = 'D';
     SET @Lc_TypeArrearT_CODE = 'A';
    END

   SET @Ls_Sql_TEXT = 'SET FOR UPDATE (C) TRANSACTION';

   IF (@Ac_NonTanfCertified_INDC = 'Y'
       AND @An_NonTanfArrear_AMNT > 0
       AND @An_MemberSsn_NUMB > 0
       AND @Lc_TypeTransactionN_CODE = ''
       AND EXISTS (SELECT 1
                     FROM ISTX_Y1 X
                    WHERE X.Case_IDNO = @An_Case_IDNO
                      AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND X.TypeArrear_CODE = 'N'
                      AND X.Transaction_AMNT <> @An_NonTanfArrear_AMNT
                      AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                 FROM ISTX_Y1 Y
                                                WHERE Y.Case_IDNO = X.Case_IDNO
                                                  AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                  AND Y.TypeArrear_CODE = X.TypeArrear_CODE)))
    BEGIN
     SET @Lc_TypeTransactionN_CODE = 'C';
     SET @Lc_TypeArrearN_CODE = 'N';
    END

   IF (@Ac_TanfCertified_INDC = 'Y'
       AND @An_TanfArrear_AMNT > 0
       AND @An_MemberSsn_NUMB > 0
       AND @Lc_TypeTransactionT_CODE = ''
       AND EXISTS (SELECT 1
                     FROM ISTX_Y1 X
                    WHERE X.Case_IDNO = @An_Case_IDNO
                      AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND X.TypeArrear_CODE = 'A'
                      AND X.Transaction_AMNT <> @An_TanfArrear_AMNT
                      AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                 FROM ISTX_Y1 Y
                                                WHERE Y.Case_IDNO = X.Case_IDNO
                                                  AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                  AND Y.TypeArrear_CODE = X.TypeArrear_CODE)))
    BEGIN
     SET @Lc_TypeTransactionT_CODE = 'C';
     SET @Lc_TypeArrearT_CODE = 'A';
    END

   SET @Ls_Sql_TEXT = 'SET FOR ADD (I) TRANSACTION';

   IF (@Ac_NonTanfCertified_INDC = 'N'
       AND @An_NonTanfArrear_AMNT > 0
       AND @An_MemberSsn_NUMB > 0
       AND @Lc_TypeTransactionN_CODE = ''
       AND (@An_NonTanfArrear_AMNT + @An_TanfArrear_AMNT) >= 150
       AND DATEDIFF(dd, @Ad_Notice_DATE, @Ad_Run_DATE) >= 35
       AND NOT EXISTS (SELECT 1
                         FROM DMJR_Y1 E
                        WHERE E.Case_IDNO = @An_Case_IDNO
                          AND E.MemberMci_IDNO = @An_MemberMci_IDNO
                          AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                          AND E.Status_CODE = @Lc_StatusStrt_CODE
                          AND E.TypeReference_CODE = @Lc_TypeReferenceSto_CODE))
    BEGIN
     SET @Lc_TypeTransactionN_CODE = 'I';
     SET @Lc_TypeArrearN_CODE = 'N';
    END

   IF (@Ac_TanfCertified_INDC = 'N'
       AND @An_TanfArrear_AMNT > 0
       AND @An_MemberSsn_NUMB > 0
       AND @Lc_TypeTransactionT_CODE = ''
       AND (@An_NonTanfArrear_AMNT + @An_TanfArrear_AMNT) >= 150
       AND DATEDIFF(dd, @Ad_Notice_DATE, @Ad_Run_DATE) >= 35
       AND NOT EXISTS (SELECT 1
                         FROM DMJR_Y1 E
                        WHERE E.Case_IDNO = @An_Case_IDNO
                          AND E.MemberMci_IDNO = @An_MemberMci_IDNO
                          AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                          AND E.Status_CODE = @Lc_StatusStrt_CODE
                          AND E.TypeReference_CODE = @Lc_TypeReferenceSto_CODE))
    BEGIN
     SET @Lc_TypeTransactionT_CODE = 'I';
     SET @Lc_TypeArrearT_CODE = 'A';
    END

   SET @Ls_Sql_TEXT = 'SET FOR ADMINISTRATIVE OFFSET (A) TRANSACTION';

   IF (@Ac_NonTanfCertified_INDC = 'N'
       AND @An_NonTanfArrear_AMNT > 0
       AND @An_MemberSsn_NUMB > 0
       AND @Lc_TypeTransactionN_CODE = ''
       AND (@An_NonTanfArrear_AMNT + @An_TanfArrear_AMNT) >= 150
       AND DATEDIFF(dd, @Ad_Notice_DATE, @Ad_Run_DATE) > 0
       AND EXISTS (SELECT 1
                     FROM ISTX_Y1 X
                    WHERE X.Case_IDNO = @An_Case_IDNO
                      AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND X.TypeArrear_CODE = 'N'
                      AND X.TypeTransaction_CODE = 'L'
                      AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                 FROM ISTX_Y1 Y
                                                WHERE Y.Case_IDNO = X.Case_IDNO
                                                  AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                  AND Y.TypeArrear_CODE = X.TypeArrear_CODE))
       AND EXISTS (SELECT 1
                     FROM DMJR_Y1 E
                    WHERE E.Case_IDNO = @An_Case_IDNO
                      AND E.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                      AND E.Status_CODE = @Lc_StatusStrt_CODE
                      AND E.TypeReference_CODE = @Lc_TypeReferenceSto_CODE))
    BEGIN
     SET @Lc_TypeTransactionN_CODE = 'A';
     SET @Lc_TypeArrearN_CODE = 'N';
    END

   IF (@Ac_TanfCertified_INDC = 'N'
       AND @An_TanfArrear_AMNT > 0
       AND @An_MemberSsn_NUMB > 0
       AND @Lc_TypeTransactionT_CODE = ''
       AND (@An_NonTanfArrear_AMNT + @An_TanfArrear_AMNT) >= 150
       AND DATEDIFF(dd, @Ad_Notice_DATE, @Ad_Run_DATE) > 0
       AND EXISTS (SELECT 1
                     FROM ISTX_Y1 X
                    WHERE X.Case_IDNO = @An_Case_IDNO
                      AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND X.TypeArrear_CODE = 'A'
                      AND X.TypeTransaction_CODE = 'L'
                      AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                 FROM ISTX_Y1 Y
                                                WHERE Y.Case_IDNO = X.Case_IDNO
                                                  AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                  AND Y.TypeArrear_CODE = X.TypeArrear_CODE))
       AND EXISTS (SELECT 1
                     FROM DMJR_Y1 E
                    WHERE E.Case_IDNO = @An_Case_IDNO
                      AND E.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                      AND E.Status_CODE = @Lc_StatusStrt_CODE
                      AND E.TypeReference_CODE = @Lc_TypeReferenceSto_CODE))
    BEGIN
     SET @Lc_TypeTransactionT_CODE = 'A';
     SET @Lc_TypeArrearT_CODE = 'A';
    END

   SET @Ls_Sql_TEXT = 'SET TYPE TRANSACTION CODE BASED ON OTHER ARREAR TYPE FOR THE SAME CASE';

   IF (@Ac_NonTanfCertified_INDC = 'N'
       AND @An_NonTanfArrear_AMNT > 0
       AND @An_MemberSsn_NUMB > 0
       AND @Lc_TypeTransactionN_CODE = ''
       AND (@An_NonTanfArrear_AMNT + @An_TanfArrear_AMNT) > 0
       AND DATEDIFF(dd, @Ad_Notice_DATE, @Ad_Run_DATE) > 0
       AND (NOT EXISTS (SELECT 1
                          FROM ISTX_Y1 X
                         WHERE X.Case_IDNO = @An_Case_IDNO
                           AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND X.TypeArrear_CODE = 'N')
             OR EXISTS (SELECT 1
                          FROM ISTX_Y1 X
                         WHERE X.Case_IDNO = @An_Case_IDNO
                           AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND X.TypeArrear_CODE = 'N'
                           AND X.TypeTransaction_CODE = 'D'
                           AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                      FROM ISTX_Y1 Y
                                                     WHERE Y.Case_IDNO = X.Case_IDNO
                                                       AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                       AND Y.TypeArrear_CODE = X.TypeArrear_CODE)))
       AND EXISTS (SELECT 1
                     FROM ISTX_Y1 X
                    WHERE X.Case_IDNO = @An_Case_IDNO
                      AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND X.TypeArrear_CODE = 'A'
                      AND X.TypeTransaction_CODE <> 'D'
                      AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                 FROM ISTX_Y1 Y
                                                WHERE Y.Case_IDNO = X.Case_IDNO
                                                  AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                  AND Y.TypeArrear_CODE = X.TypeArrear_CODE)))
    BEGIN
     SET @Lc_TypeTransactionN_CODE = (CASE
                                       WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_TypeTransactionT_CODE, '')))) > 0
                                        THEN
                                        CASE
                                         WHEN LTRIM(RTRIM(@Lc_TypeTransactionT_CODE)) IN ('C', 'D')
                                          THEN 'I'
                                         ELSE @Lc_TypeTransactionT_CODE
                                        END
                                       ELSE ISNULL ((SELECT X.TypeTransaction_CODE
                                                       FROM ISTX_Y1 X
                                                      WHERE X.Case_IDNO = @An_Case_IDNO
                                                        AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                                                        AND X.TypeArrear_CODE = 'A'
                                                        AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                                                   FROM ISTX_Y1 Y
                                                                                  WHERE Y.Case_IDNO = X.Case_IDNO
                                                                                    AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                                                    AND Y.TypeArrear_CODE = X.TypeArrear_CODE)), '')
                                      END);
     SET @Lc_TypeArrearN_CODE = 'N';
    END

   IF (@Ac_TanfCertified_INDC = 'N'
       AND @An_TanfArrear_AMNT > 0
       AND @An_MemberSsn_NUMB > 0
       AND @Lc_TypeTransactionT_CODE = ''
       AND (@An_NonTanfArrear_AMNT + @An_TanfArrear_AMNT) > 0
       AND DATEDIFF(dd, @Ad_Notice_DATE, @Ad_Run_DATE) > 0
       AND (NOT EXISTS (SELECT 1
                          FROM ISTX_Y1 X
                         WHERE X.Case_IDNO = @An_Case_IDNO
                           AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND X.TypeArrear_CODE = 'A')
             OR EXISTS (SELECT 1
                          FROM ISTX_Y1 X
                         WHERE X.Case_IDNO = @An_Case_IDNO
                           AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                           AND X.TypeArrear_CODE = 'A'
                           AND X.TypeTransaction_CODE = 'D'
                           AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                      FROM ISTX_Y1 Y
                                                     WHERE Y.Case_IDNO = X.Case_IDNO
                                                       AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                       AND Y.TypeArrear_CODE = X.TypeArrear_CODE)))
       AND EXISTS (SELECT 1
                     FROM ISTX_Y1 X
                    WHERE X.Case_IDNO = @An_Case_IDNO
                      AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND X.TypeArrear_CODE = 'N'
                      AND X.TypeTransaction_CODE <> 'D'
                      AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                 FROM ISTX_Y1 Y
                                                WHERE Y.Case_IDNO = X.Case_IDNO
                                                  AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                  AND Y.TypeArrear_CODE = X.TypeArrear_CODE)))
    BEGIN
     SET @Lc_TypeTransactionT_CODE = (CASE
                                       WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_TypeTransactionN_CODE, '')))) > 0
                                        THEN
                                        CASE
                                         WHEN LTRIM(RTRIM(@Lc_TypeTransactionN_CODE)) IN ('C', 'D')
                                          THEN 'I'
                                         ELSE @Lc_TypeTransactionN_CODE
                                        END
                                       ELSE ISNULL ((SELECT X.TypeTransaction_CODE
                                                       FROM ISTX_Y1 X
                                                      WHERE X.Case_IDNO = @An_Case_IDNO
                                                        AND X.MemberMci_IDNO = @An_MemberMci_IDNO
                                                        AND X.TypeArrear_CODE = 'N'
                                                        AND X.SubmitLast_DATE = (SELECT TOP 1 MAX(Y.SubmitLast_DATE)
                                                                                   FROM ISTX_Y1 Y
                                                                                  WHERE Y.Case_IDNO = X.Case_IDNO
                                                                                    AND Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                                                    AND Y.TypeArrear_CODE = X.TypeArrear_CODE)), '')
                                      END);
     SET @Lc_TypeArrearT_CODE = 'A';
    END

   IF ((LEN(LTRIM(RTRIM(@Lc_TypeArrearN_CODE))) > 0
        AND LEN(LTRIM(RTRIM(@Lc_TypeTransactionN_CODE))) > 0)
        OR (LEN(LTRIM(RTRIM(@Lc_TypeArrearT_CODE))) > 0
            AND LEN(LTRIM(RTRIM(@Lc_TypeTransactionT_CODE))) > 0))
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_SqlData_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '');

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

     SET @Ls_Sql_TEXT = 'CHECK NON-TANF ARREAR TYPE';

     IF @Lc_TypeArrearN_CODE = 'N'
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT INTO #IstxData_P1 - 1';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTransactionN_CODE, '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_TypeArrearN_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_NonTanfArrear_AMNT AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ExcludeState_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Ac_CountyFips_CODE, '');

       INSERT INTO #IstxData_P1
                   (MemberMci_IDNO,
                    Case_IDNO,
                    MemberSsn_NUMB,
                    TaxYear_NUMB,
                    TypeTransaction_CODE,
                    TypeArrear_CODE,
                    Transaction_AMNT,
                    SubmitLast_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB,
                    ExcludeState_CODE,
                    CountyFips_CODE)
            VALUES(@An_MemberMci_IDNO,--MemberMci_IDNO
                   @An_Case_IDNO,--Case_IDNO
                   @An_MemberSsn_NUMB,--MemberSsn_NUMB
                   @An_TaxYear_NUMB,--TaxYear_NUMB
                   @Lc_TypeTransactionN_CODE,--TypeTransaction_CODE
                   @Lc_TypeArrearN_CODE,--TypeArrear_CODE
                   @An_NonTanfArrear_AMNT,--Transaction_AMNT
                   CONVERT(CHAR(10), @Ad_Run_DATE, 110),--SubmitLast_DATE
                   @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                   CONVERT(CHAR(10), @Ad_Run_DATE, 110),--Update_DTTM
                   @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                   @Lc_No_INDC,--ExcludeState_CODE
                   @Ac_CountyFips_CODE --CountyFips_CODE
       );
      END

     SET @Ls_Sql_TEXT = 'CHECK TANF ARREAR TYPE';

     IF @Lc_TypeArrearT_CODE = 'A'
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT INTO #IstxData_P1 - 2';
       SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ', TaxYear_NUMB = ' + ISNULL(CAST(@An_TaxYear_NUMB AS VARCHAR), '') + ', TypeTransaction_CODE = ' + ISNULL(@Lc_TypeTransactionT_CODE, '') + ', TypeArrear_CODE = ' + ISNULL(@Lc_TypeArrearT_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_TanfArrear_AMNT AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ExcludeState_CODE = ' + ISNULL(@Lc_No_INDC, '') + ', CountyFips_CODE = ' + ISNULL(@Ac_CountyFips_CODE, '');

       INSERT INTO #IstxData_P1
                   (MemberMci_IDNO,
                    Case_IDNO,
                    MemberSsn_NUMB,
                    TaxYear_NUMB,
                    TypeTransaction_CODE,
                    TypeArrear_CODE,
                    Transaction_AMNT,
                    SubmitLast_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB,
                    ExcludeState_CODE,
                    CountyFips_CODE)
            VALUES(@An_MemberMci_IDNO,--MemberMci_IDNO
                   @An_Case_IDNO,--Case_IDNO
                   @An_MemberSsn_NUMB,--MemberSsn_NUMB
                   @An_TaxYear_NUMB,--TaxYear_NUMB
                   @Lc_TypeTransactionT_CODE,--TypeTransaction_CODE
                   @Lc_TypeArrearT_CODE,--TypeArrear_CODE
                   @An_TanfArrear_AMNT,--Transaction_AMNT
                   CONVERT(CHAR(10), @Ad_Run_DATE, 110),--SubmitLast_DATE
                   @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
                   CONVERT(CHAR(10), @Ad_Run_DATE, 110),--Update_DTTM
                   @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                   @Lc_No_INDC,--ExcludeState_CODE
                   @Ac_CountyFips_CODE --CountyFips_CODE
       );
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = ERROR_MESSAGE();
    END;

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
 END;


GO
