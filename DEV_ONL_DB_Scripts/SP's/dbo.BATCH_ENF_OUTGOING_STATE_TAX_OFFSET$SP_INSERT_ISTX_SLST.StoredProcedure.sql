/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_ISTX_SLST]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_ISTX_SLST
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_ISTX_SLST is 
					  to check and insert istx and slst data
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_ISTX_SLST]
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(07),
 @An_TaxYear_NUMB          NUMERIC(04),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT         CHAR = ' ',
          @Ln_TaxYear_NUMB       NUMERIC(4) = @An_TaxYear_NUMB,
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_Note_INDC          CHAR(1) = 'N',
          @Lc_InsertIstx_INDC    CHAR(1) = 'N',
          @Lc_BatchRunUser_TEXT  CHAR(5) = 'BATCH',
          @Lc_Job_ID             CHAR(7) = @Ac_Job_ID,
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_INSERT_ISTX_SLST',
          @Ls_Process_NAME       VARCHAR(100) = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET',
          @Ld_Run_DATE           DATE = @Ad_Run_DATE,
          @Ld_Low_DATE           DATE = '01/01/0001',
          @Ld_Empty_DATE         DATE = '01/01/1900',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                  NUMERIC = 0,
          @Ln_Case_IDNO                  NUMERIC(6) = 0,
          @Ln_Transaction_AMNT           NUMERIC(11, 2),
          @Ln_Error_NUMB                 NUMERIC(11),
          @Ln_ErrorLine_NUMB             NUMERIC(11),
          @Ln_TransactionA_AMNT          NUMERIC(11, 2),
          @Ln_TransactionN_AMNT          NUMERIC(11, 2),
          @Ln_PrevTransactionA_AMNT      NUMERIC(11, 2),
          @Ln_PrevTransactionN_AMNT      NUMERIC(11, 2),
          @Ln_TransactionEventSeq_NUMB   NUMERIC(19) = 0,
          @Li_FetchStatus_QNTY           SMALLINT,
          @Lc_Empty_TEXT                 CHAR = '',
          @Lc_TypeTransaction_CODE       CHAR(1),
          @Lc_TypeTransactionA_CODE      CHAR(1),
          @Lc_TypeTransactionN_CODE      CHAR(1),
          @Lc_PrevTypeTransactionA_CODE  CHAR(1),
          @Lc_PrevTypeTransactionN_CODE  CHAR(1),
          @Lc_State_ADDR                 CHAR(2) = '',
          @Lc_CountyFips_CODE            CHAR(3),
          @Lc_Msg_CODE                   CHAR(5) = '',
          @Lc_Zip_ADDR                   CHAR(15) = '',
          @Lc_City_ADDR                  CHAR(28) = '',
          @Ls_Line1_ADDR                 VARCHAR(50) = '',
          @Ls_Line2_ADDR                 VARCHAR(50) = '',
          @Ls_Sql_TEXT                   VARCHAR(100) = '',
          @Ls_SqlData_TEXT               VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT          VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT      VARCHAR(4000) = '',
          @Ld_SubmitLastA_DATE           DATE,
          @Ld_SubmitLastN_DATE           DATE,
          @Ld_PrevSubmitLastA_DATE       DATE,
          @Ld_PrevSubmitLastN_DATE       DATE,
          @Ld_PrevLSubmitLastA_DATE      DATE,
          @Ld_PrevLSubmitLastN_DATE      DATE,
          @Ld_LastNoticeSubmitLastA_DATE DATE,
          @Ld_LastNoticeSubmitLastN_DATE DATE,
          @Ld_Start_DATE                 DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'INSERT ISTX_Y1 <> L';
   SET @Ls_SqlData_TEXT = '';

   INSERT INTO ISTX_Y1
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
   SELECT A.MemberMci_IDNO,
          A.Case_IDNO,
          A.MemberSsn_NUMB,
          A.TaxYear_NUMB,
          A.TypeTransaction_CODE,
          A.TypeArrear_CODE,
          A.Transaction_AMNT,
          A.SubmitLast_DATE,
          A.WorkerUpdate_ID,
          A.Update_DTTM,
          A.TransactionEventSeq_NUMB,
          A.ExcludeState_CODE,
          RIGHT(('000' + LTRIM(RTRIM(A.CountyFips_CODE))), 3) AS CountyFips_CODE
     FROM #IstxData_P1 A
    WHERE A.TypeTransaction_CODE <> 'L';

   SET @Ls_Sql_TEXT = 'DELETE #IstxData_P1';

   DELETE FROM #IstxData_P1;

   DECLARE @Ln_InsStxDataCur_MemberMci_IDNO NUMERIC(10),
           @Ln_InsStxDataCur_Case_IDNO      NUMERIC(6)
   DECLARE InsStxData_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           A.MemberMci_IDNO,
           A.Case_IDNO
      FROM ISTX_Y1 A
     WHERE A.SubmitLast_DATE = @Ld_Run_DATE
     ORDER BY A.MemberMci_IDNO,
              A.Case_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN InsStxData_CUR';

   OPEN InsStxData_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM InsStxData_CUR - 1';

   FETCH NEXT FROM InsStxData_CUR INTO @Ln_InsStxDataCur_MemberMci_IDNO, @Ln_InsStxDataCur_Case_IDNO

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Lc_InsertIstx_INDC = 'N';
     SET @Ls_Sql_TEXT = 'CHECK AND SET ISTX DATA FOR SLST_Y1';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_InsStxDataCur_MemberMci_IDNO AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_InsStxDataCur_Case_IDNO AS VARCHAR)

     SELECT @Lc_InsertIstx_INDC = 'N',
            @Ld_PrevLSubmitLastA_DATE = @Ld_Low_DATE,
            @Ld_SubmitLastA_DATE = @Ld_Low_DATE,
            @Lc_TypeTransactionA_CODE = '',
            @Ln_TransactionA_AMNT = 0,
            @Ld_PrevLSubmitLastN_DATE = @Ld_Low_DATE,
            @Ld_SubmitLastN_DATE = @Ld_Low_DATE,
            @Lc_TypeTransactionN_CODE = '',
            @Ln_TransactionN_AMNT = 0,
            @Ld_PrevSubmitLastA_DATE = @Ld_Low_DATE,
            @Lc_PrevTypeTransactionA_CODE = '',
            @Ln_PrevTransactionA_AMNT = 0,
            @Ld_PrevSubmitLastN_DATE = @Ld_Low_DATE,
            @Lc_PrevTypeTransactionN_CODE = '',
            @Ln_PrevTransactionN_AMNT = 0,
            @Ld_LastNoticeSubmitLastA_DATE = @Ld_Low_DATE,
            @Ld_LastNoticeSubmitLastN_DATE = @Ld_Low_DATE

     SELECT @Ld_SubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                             FROM ISTX_Y1 X
                                            WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                              AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                              AND X.TypeArrear_CODE = 'A'), '')

     SELECT @Ld_SubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                             FROM ISTX_Y1 X
                                            WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                              AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                              AND X.TypeArrear_CODE = 'N'), '')

     SELECT @Lc_TypeTransactionA_CODE = ISNULL(A.TypeTransaction_CODE, ''),
            @Ln_TransactionA_AMNT = ISNULL(A.Transaction_AMNT, 0)
       FROM ISTX_Y1 A
      WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
        AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
        AND A.TypeArrear_CODE = 'A'
        AND A.SubmitLast_DATE = @Ld_SubmitLastA_DATE

     SELECT @Lc_TypeTransactionN_CODE = ISNULL(A.TypeTransaction_CODE, ''),
            @Ln_TransactionN_AMNT = ISNULL(A.Transaction_AMNT, 0)
       FROM ISTX_Y1 A
      WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
        AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
        AND A.TypeArrear_CODE = 'N'
        AND A.SubmitLast_DATE = @Ld_SubmitLastN_DATE

     SELECT @Ld_PrevSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                 FROM ISTX_Y1 X
                                                WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                  AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                  AND X.TypeArrear_CODE = 'A'
                                                  AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')

     SELECT @Ld_PrevSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                 FROM ISTX_Y1 X
                                                WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                  AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                  AND X.TypeArrear_CODE = 'N'
                                                  AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')

     SELECT @Lc_PrevTypeTransactionA_CODE = ISNULL(A.TypeTransaction_CODE, ''),
            @Ln_PrevTransactionA_AMNT = ISNULL(A.Transaction_AMNT, 0)
       FROM ISTX_Y1 A
      WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
        AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
        AND A.TypeArrear_CODE = 'A'
        AND A.SubmitLast_DATE = @Ld_PrevSubmitLastA_DATE

     SELECT @Lc_PrevTypeTransactionN_CODE = ISNULL(A.TypeTransaction_CODE, ''),
            @Ln_PrevTransactionN_AMNT = ISNULL(A.Transaction_AMNT, 0)
       FROM ISTX_Y1 A
      WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
        AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
        AND A.TypeArrear_CODE = 'N'
        AND A.SubmitLast_DATE = @Ld_PrevSubmitLastN_DATE

     IF ISNULL(@Lc_TypeTransactionA_CODE, '') IN ('D', '')
        AND ISNULL(@Lc_TypeTransactionN_CODE, '') IN ('D', '')
      BEGIN
       SET @Ls_Sql_TEXT = 'ALL ARREAR TYPES FOR THE CASE BECAME D';
       SET @Ls_SqlData_TEXT = '';
       SET @Lc_InsertIstx_INDC = 'Y';
      END
     ELSE IF NOT EXISTS(SELECT 1
                     FROM ISTX_Y1 A
                    WHERE A.TypeTransaction_CODE = 'L'
                      AND A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                      AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO)
      BEGIN
       SET @Ls_Sql_TEXT = 'NO L RECORD';
       SET @Ls_SqlData_TEXT = '';
       SET @Lc_InsertIstx_INDC = 'Y';
      END
     ELSE IF ISNULL(@Lc_TypeTransactionA_CODE, '') = 'L'
        AND ISNULL(@Lc_TypeTransactionN_CODE, '') = 'L'
      BEGIN
       SET @Ls_Sql_TEXT = 'BOTH ARREAR TYPES ARE L';
       SET @Ls_SqlData_TEXT = '';

       IF ISNULL(@Lc_TypeTransactionA_CODE, '') = 'L'
        BEGIN
         SELECT @Ld_PrevLSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                      FROM ISTX_Y1 X
                                                     WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                       AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                       AND X.TypeArrear_CODE = 'A'
                                                       AND X.TypeTransaction_CODE = 'L'
                                                       AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')

         IF ISNULL(@Ld_PrevLSubmitLastA_DATE, @Ld_Empty_DATE) = @Ld_Empty_DATE
          BEGIN
           SELECT @Ld_PrevLSubmitLastA_DATE = ISNULL((SELECT TOP 1 MIN(X.SubmitLast_DATE)
                                                        FROM ISTX_Y1 X
                                                       WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                         AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                         AND X.TypeArrear_CODE = 'A'
                                                         AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')
          END

         IF ISNULL(@Ld_PrevLSubmitLastA_DATE, @Ld_Empty_DATE) <> @Ld_Empty_DATE
            AND NOT EXISTS(SELECT 1
                             FROM ISTX_Y1 A
                            WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                              AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                              AND A.TypeArrear_CODE = 'A'
                              AND A.TypeTransaction_CODE = 'D'
                              AND A.SubmitLast_DATE BETWEEN @Ld_PrevLSubmitLastA_DATE AND @Ld_SubmitLastA_DATE)
            AND DATEDIFF(D, @Ld_PrevLSubmitLastA_DATE, @Ld_SubmitLastA_DATE) >= 365
          BEGIN
           SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT FOR A RECORD WHEN BOTH ARREAR TYPES ARE L';
           SET @Ls_SqlData_TEXT = '';

           IF @Ln_PrevTransactionA_AMNT <> @Ln_TransactionA_AMNT
            BEGIN
             SET @Lc_InsertIstx_INDC = 'Y';
             SET @Lc_TypeTransactionA_CODE = 'C';
            END
          END
        END

       IF ISNULL(@Lc_TypeTransactionN_CODE, '') = 'L'
        BEGIN
         SELECT @Ld_PrevLSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                      FROM ISTX_Y1 X
                                                     WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                       AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                       AND X.TypeArrear_CODE = 'N'
                                                       AND X.TypeTransaction_CODE = 'L'
                                                       AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')

         IF ISNULL(@Ld_PrevLSubmitLastN_DATE, @Ld_Empty_DATE) = @Ld_Empty_DATE
          BEGIN
           SELECT @Ld_PrevLSubmitLastN_DATE = ISNULL((SELECT TOP 1 MIN(X.SubmitLast_DATE)
                                                        FROM ISTX_Y1 X
                                                       WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                         AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                         AND X.TypeArrear_CODE = 'N'
                                                         AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')
          END

         IF ISNULL(@Ld_PrevLSubmitLastN_DATE, @Ld_Empty_DATE) <> @Ld_Empty_DATE
            AND NOT EXISTS(SELECT 1
                             FROM ISTX_Y1 A
                            WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                              AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                              AND A.TypeArrear_CODE = 'N'
                              AND A.TypeTransaction_CODE = 'D'
                              AND A.SubmitLast_DATE BETWEEN @Ld_PrevLSubmitLastN_DATE AND @Ld_SubmitLastN_DATE)
            AND DATEDIFF(D, @Ld_PrevLSubmitLastN_DATE, @Ld_SubmitLastN_DATE) >= 365
          BEGIN
           SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT FOR N RECORD WHEN BOTH ARREAR TYPES ARE L';
           SET @Ls_SqlData_TEXT = '';

           IF @Ln_PrevTransactionN_AMNT <> @Ln_TransactionN_AMNT
            BEGIN
             SET @Lc_InsertIstx_INDC = 'Y';
             SET @Lc_TypeTransactionN_CODE = 'C';
            END
          END
        END

       IF @Ld_SubmitLastA_DATE >= @Ld_SubmitLastN_DATE
        BEGIN
         IF DATEDIFF(D, @Ld_SubmitLastN_DATE, @Ld_SubmitLastA_DATE) >= 365
          BEGIN
           SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR A RECORD WHEN BOTH ARREAR TYPES ARE L';
           SET @Ls_SqlData_TEXT = '';

           IF @Ln_PrevTransactionA_AMNT <> @Ln_TransactionA_AMNT
            BEGIN
             SET @Lc_InsertIstx_INDC = 'Y';
             SET @Lc_TypeTransactionA_CODE = 'C';
            END
          END
        END
       ELSE IF @Ld_SubmitLastN_DATE >= @Ld_SubmitLastA_DATE
        BEGIN
         IF DATEDIFF(D, @Ld_SubmitLastA_DATE, @Ld_SubmitLastN_DATE) >= 365
          BEGIN
           SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR N RECORD WHEN BOTH ARREAR TYPES ARE L';
           SET @Ls_SqlData_TEXT = '';

           IF @Ln_PrevTransactionN_AMNT <> @Ln_TransactionN_AMNT
            BEGIN
             SET @Lc_InsertIstx_INDC = 'Y';
             SET @Lc_TypeTransactionN_CODE = 'C';
            END
          END
        END
      END
     ELSE IF ISNULL(@Lc_TypeTransactionA_CODE, '') <> 'L'
        AND ISNULL(@Lc_TypeTransactionN_CODE, '') <> 'L'
      BEGIN
       SET @Ls_Sql_TEXT = 'BOTH ARREAR TYPES ARE <> L';
       SET @Ls_SqlData_TEXT = '';
       SET @Lc_InsertIstx_INDC = 'Y';
      END
     ELSE IF ISNULL(@Lc_TypeTransactionA_CODE, '') = 'L'
         OR ISNULL(@Lc_TypeTransactionN_CODE, '') = 'L'
      BEGIN
       SET @Ls_Sql_TEXT = 'ONLY 1 ARREAR TYPE IS L';
       SET @Ls_SqlData_TEXT = '';

       IF ISNULL(@Lc_TypeTransactionA_CODE, '') = 'L'
        BEGIN
         SELECT @Ld_PrevLSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                      FROM ISTX_Y1 X
                                                     WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                       AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                       AND X.TypeArrear_CODE = 'A'
                                                       AND X.TypeTransaction_CODE = 'L'
                                                       AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')

         IF ISNULL(@Ld_PrevLSubmitLastA_DATE, @Ld_Empty_DATE) = @Ld_Empty_DATE
          BEGIN
           SELECT @Ld_PrevLSubmitLastA_DATE = ISNULL((SELECT TOP 1 MIN(X.SubmitLast_DATE)
                                                        FROM ISTX_Y1 X
                                                       WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                         AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                         AND X.TypeArrear_CODE = 'A'
                                                         AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE), '')
          END

         IF ISNULL(@Ld_PrevLSubmitLastA_DATE, @Ld_Empty_DATE) <> @Ld_Empty_DATE
            AND NOT EXISTS(SELECT 1
                             FROM ISTX_Y1 A
                            WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                              AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                              AND A.TypeArrear_CODE = 'A'
                              AND A.TypeTransaction_CODE = 'D'
                              AND A.SubmitLast_DATE BETWEEN @Ld_PrevLSubmitLastA_DATE AND @Ld_SubmitLastA_DATE)
            AND DATEDIFF(D, @Ld_PrevLSubmitLastA_DATE, @Ld_SubmitLastA_DATE) >= 365
          BEGIN
           SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT FOR A RECORD WHEN ONLY 1 ARREAR TYPE IS L';
           SET @Ls_SqlData_TEXT = '';

           IF @Ln_PrevTransactionA_AMNT <> @Ln_TransactionA_AMNT
            BEGIN
             SET @Lc_InsertIstx_INDC = 'Y';
             SET @Lc_TypeTransactionA_CODE = 'C';
            END
          END
         ELSE
          BEGIN
           SELECT @Lc_PrevTypeTransactionA_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                            FROM ISTX_Y1 A
                                                           WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                             AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                             AND A.TypeArrear_CODE = 'A'
                                                             AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                        FROM ISTX_Y1 X
                                                                                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                         AND X.Case_IDNO = A.Case_IDNO
                                                                                         AND X.TypeArrear_CODE = 'A'
                                                                                         AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE)), '')

           SELECT @Lc_PrevTypeTransactionN_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                            FROM ISTX_Y1 A
                                                           WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                             AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                             AND A.TypeArrear_CODE = 'N'
                                                             AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                        FROM ISTX_Y1 X
                                                                                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                         AND X.Case_IDNO = A.Case_IDNO
                                                                                         AND X.TypeArrear_CODE = 'N'
                                                                                         AND X.SubmitLast_DATE < @Ld_SubmitLastA_DATE)), '')

           IF @Lc_PrevTypeTransactionA_CODE IN ('D', '')
              AND @Lc_PrevTypeTransactionN_CODE IN ('D', '')
            BEGIN
             SET @Ls_Sql_TEXT = 'ALL ARREAR TYPES FOR THE CASE BECAME D WHEN ONLY A RECORD IS L';
             SET @Ls_SqlData_TEXT = '';
            END
           ELSE
            BEGIN
             SELECT @Ld_LastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                               FROM ISTX_Y1 X
                                                              WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                                AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                                AND X.TypeArrear_CODE = 'A'
                                                                AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

             SELECT @Ld_LastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                               FROM ISTX_Y1 X
                                                              WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                                AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                                AND X.TypeArrear_CODE = 'N'
                                                                AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

             IF @Ld_LastNoticeSubmitLastA_DATE <> '12/31/9999'
                AND @Ld_LastNoticeSubmitLastN_DATE <> '12/31/9999'
              BEGIN
               IF @Ld_LastNoticeSubmitLastA_DATE >= @Ld_LastNoticeSubmitLastN_DATE
                BEGIN
                 IF DATEDIFF(D, @Ld_LastNoticeSubmitLastN_DATE, @Ld_LastNoticeSubmitLastA_DATE) >= 365
                  BEGIN
                   SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR A RECORD WHEN ONLY A RECORD IS L';
                   SET @Ls_SqlData_TEXT = '';

                   IF @Ln_PrevTransactionA_AMNT <> @Ln_TransactionA_AMNT
                    BEGIN
                     SET @Lc_InsertIstx_INDC = 'Y';
                     SET @Lc_TypeTransactionA_CODE = 'C';
                    END
                  END
                END
               ELSE IF @Ld_LastNoticeSubmitLastN_DATE >= @Ld_LastNoticeSubmitLastA_DATE
                BEGIN
                 IF DATEDIFF(D, @Ld_LastNoticeSubmitLastA_DATE, @Ld_LastNoticeSubmitLastN_DATE) >= 365
                  BEGIN
                   SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR N RECORD WHEN ONLY A RECORD IS L';
                   SET @Ls_SqlData_TEXT = '';

                   IF @Ln_PrevTransactionN_AMNT <> @Ln_TransactionN_AMNT
                    BEGIN
                     SET @Lc_InsertIstx_INDC = 'Y';
                     SET @Lc_TypeTransactionN_CODE = 'C';
                    END
                  END
                END
              END
            END
          END
        END
       ELSE IF ISNULL(@Lc_TypeTransactionN_CODE, '') = 'L'
        BEGIN
         SELECT @Ld_PrevLSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                      FROM ISTX_Y1 X
                                                     WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                       AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                       AND X.TypeArrear_CODE = 'N'
                                                       AND X.TypeTransaction_CODE = 'L'
                                                       AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')

         IF ISNULL(@Ld_PrevLSubmitLastN_DATE, @Ld_Empty_DATE) = @Ld_Empty_DATE
          BEGIN
           SELECT @Ld_PrevLSubmitLastN_DATE = ISNULL((SELECT TOP 1 MIN(X.SubmitLast_DATE)
                                                        FROM ISTX_Y1 X
                                                       WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                         AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                         AND X.TypeArrear_CODE = 'N'
                                                         AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE), '')
          END

         IF ISNULL(@Ld_PrevLSubmitLastN_DATE, @Ld_Empty_DATE) <> @Ld_Empty_DATE
            AND NOT EXISTS(SELECT 1
                             FROM ISTX_Y1 A
                            WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                              AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                              AND A.TypeArrear_CODE = 'N'
                              AND A.TypeTransaction_CODE = 'D'
                              AND A.SubmitLast_DATE BETWEEN @Ld_PrevLSubmitLastN_DATE AND @Ld_SubmitLastN_DATE)
            AND DATEDIFF(D, @Ld_PrevLSubmitLastN_DATE, @Ld_SubmitLastN_DATE) >= 365
          BEGIN
           SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT FOR N RECORD WHEN ONLY 1 ARREAR TYPE IS L';
           SET @Ls_SqlData_TEXT = '';

           IF @Ln_PrevTransactionN_AMNT <> @Ln_TransactionN_AMNT
            BEGIN
             SET @Lc_InsertIstx_INDC = 'Y';
             SET @Lc_TypeTransactionN_CODE = 'C';
            END
          END
         ELSE
          BEGIN
           SELECT @Lc_PrevTypeTransactionA_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                            FROM ISTX_Y1 A
                                                           WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                             AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                             AND A.TypeArrear_CODE = 'A'
                                                             AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                        FROM ISTX_Y1 X
                                                                                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                         AND X.Case_IDNO = A.Case_IDNO
                                                                                         AND X.TypeArrear_CODE = 'A'
                                                                                         AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE)), '')

           SELECT @Lc_PrevTypeTransactionN_CODE = ISNULL((SELECT TOP 1 ISNULL(A.TypeTransaction_CODE, '')
                                                            FROM ISTX_Y1 A
                                                           WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                             AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                             AND A.TypeArrear_CODE = 'N'
                                                             AND A.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                                                        FROM ISTX_Y1 X
                                                                                       WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                                                         AND X.Case_IDNO = A.Case_IDNO
                                                                                         AND X.TypeArrear_CODE = 'N'
                                                                                         AND X.SubmitLast_DATE < @Ld_SubmitLastN_DATE)), '')

           IF @Lc_PrevTypeTransactionA_CODE IN ('D', '')
              AND @Lc_PrevTypeTransactionN_CODE IN ('D', '')
            BEGIN
             SET @Ls_Sql_TEXT = 'ALL ARREAR TYPES FOR THE CASE BECAME D WHEN ONLY N RECORD IS L';
             SET @Ls_SqlData_TEXT = '';
            END
           ELSE
            BEGIN
             SELECT @Ld_LastNoticeSubmitLastA_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                               FROM ISTX_Y1 X
                                                              WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                                AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                                AND X.TypeArrear_CODE = 'A'
                                                                AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

             SELECT @Ld_LastNoticeSubmitLastN_DATE = ISNULL((SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                               FROM ISTX_Y1 X
                                                              WHERE X.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
                                                                AND X.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
                                                                AND X.TypeArrear_CODE = 'N'
                                                                AND X.TypeTransaction_CODE = 'L'), '12/31/9999')

             IF @Ld_LastNoticeSubmitLastA_DATE <> '12/31/9999'
                AND @Ld_LastNoticeSubmitLastN_DATE <> '12/31/9999'
              BEGIN
               IF @Ld_LastNoticeSubmitLastA_DATE >= @Ld_LastNoticeSubmitLastN_DATE
                BEGIN
                 IF DATEDIFF(D, @Ld_LastNoticeSubmitLastN_DATE, @Ld_LastNoticeSubmitLastA_DATE) >= 365
                  BEGIN
                   SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR A RECORD WHEN ONLY N RECORD IS L';
                   SET @Ls_SqlData_TEXT = '';

                   IF @Ln_PrevTransactionA_AMNT <> @Ln_TransactionA_AMNT
                    BEGIN
                     SET @Lc_InsertIstx_INDC = 'Y';
                     SET @Lc_TypeTransactionA_CODE = 'C';
                    END
                  END
                END
               ELSE IF @Ld_LastNoticeSubmitLastN_DATE >= @Ld_LastNoticeSubmitLastA_DATE
                BEGIN
                 IF DATEDIFF(D, @Ld_LastNoticeSubmitLastA_DATE, @Ld_LastNoticeSubmitLastN_DATE) >= 365
                  BEGIN
                   SET @Ls_Sql_TEXT = 'ANNUAL NOTICE SENT only FOR N RECORD WHEN ONLY N RECORD IS L';
                   SET @Ls_SqlData_TEXT = '';

                   IF @Ln_PrevTransactionN_AMNT <> @Ln_TransactionN_AMNT
                    BEGIN
                     SET @Lc_InsertIstx_INDC = 'Y';
                     SET @Lc_TypeTransactionN_CODE = 'C';
                    END
                  END
                END
              END
            END
          END
        END
      END

     IF @Lc_InsertIstx_INDC = 'Y'
      BEGIN
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
       SELECT A.MemberMci_IDNO,
              A.Case_IDNO,
              A.MemberSsn_NUMB,
              A.TaxYear_NUMB,
              @Lc_TypeTransactionA_CODE AS TypeTransaction_CODE,
              A.TypeArrear_CODE,
              A.Transaction_AMNT,
              A.SubmitLast_DATE,
              A.WorkerUpdate_ID,
              A.Update_DTTM,
              A.TransactionEventSeq_NUMB,
              A.ExcludeState_CODE,
              A.CountyFips_CODE
         FROM ISTX_Y1 A
        WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
          AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
          AND A.TypeArrear_CODE = 'A'
          AND A.SubmitLast_DATE = @Ld_SubmitLastA_DATE;

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
       SELECT A.MemberMci_IDNO,
              A.Case_IDNO,
              A.MemberSsn_NUMB,
              A.TaxYear_NUMB,
              @Lc_TypeTransactionN_CODE AS TypeTransaction_CODE,
              A.TypeArrear_CODE,
              A.Transaction_AMNT,
              A.SubmitLast_DATE,
              A.WorkerUpdate_ID,
              A.Update_DTTM,
              A.TransactionEventSeq_NUMB,
              A.ExcludeState_CODE,
              A.CountyFips_CODE
         FROM ISTX_Y1 A
        WHERE A.MemberMci_IDNO = @Ln_InsStxDataCur_MemberMci_IDNO
          AND A.Case_IDNO = @Ln_InsStxDataCur_Case_IDNO
          AND A.TypeArrear_CODE = 'N'
          AND A.SubmitLast_DATE = @Ld_SubmitLastN_DATE;
      END;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CURSOR InsStxData_CUR - 2';

     FETCH NEXT FROM InsStxData_CUR INTO @Ln_InsStxDataCur_MemberMci_IDNO, @Ln_InsStxDataCur_Case_IDNO

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE InsStxData_CUR';

   CLOSE InsStxData_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE InsStxData_CUR';

   DEALLOCATE InsStxData_CUR;

   DECLARE @Ln_InsSlstDataCur_MemberMci_IDNO  NUMERIC(10) = 0,
           @Lc_InsSlstDataCur_TypeArrear_CODE CHAR(1)
   DECLARE InsSlstData_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           A.MemberMci_IDNO,
           A.TypeArrear_CODE
      FROM #IstxData_P1 A
     WHERE EXISTS(SELECT 1
                    FROM #IstxData_P1 X
                   WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                     AND X.TypeArrear_CODE = A.TypeArrear_CODE
                     AND X.SubmitLast_DATE = @Ld_Run_DATE)
     ORDER BY A.MemberMci_IDNO,
              A.TypeArrear_CODE;

   SET @Ls_Sql_TEXT = 'OPEN InsSlstData_CUR';

   OPEN InsSlstData_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM InsSlstData_CUR - 1';

   FETCH NEXT FROM InsSlstData_CUR INTO @Ln_InsSlstDataCur_MemberMci_IDNO, @Lc_InsSlstDataCur_TypeArrear_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SELECT @Ln_Case_IDNO = 0,
            @Lc_CountyFips_CODE = '',
            @Ln_Transaction_AMNT = 0,
            @Lc_TypeTransaction_CODE = '',
            @Ls_Line1_ADDR = '',
            @Ls_Line2_ADDR = '',
            @Lc_City_ADDR = '',
            @Lc_State_ADDR = '',
            @Lc_Zip_ADDR = ''

     SELECT @Ln_Case_IDNO = D.Case_IDNO,
            @Lc_CountyFips_CODE = RIGHT(('000' + LTRIM(RTRIM(ISNULL(X.County_IDNO, '0')))), 3)
       FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY C.MemberMci_IDNO, C.TypeArrear_CODE ORDER BY C.MemberMci_IDNO, C.TypeArrear_CODE, C.Transaction_AMNT DESC, Z.OrderIssued_DATE ),
                    C.*
               FROM #IstxData_P1 C,
                    SORD_Y1 Z
              WHERE C.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                           FROM #IstxData_P1 X
                                          WHERE X.MemberMci_IDNO = C.MemberMci_IDNO
                                            AND X.Case_IDNO = C.Case_IDNO
                                            AND X.TypeArrear_CODE = C.TypeArrear_CODE)
                AND C.MemberMci_IDNO = @Ln_InsSlstDataCur_MemberMci_IDNO
                AND Z.Case_IDNO = C.Case_IDNO
                AND Z.EndValidity_DATE = '12/31/9999'
                AND C.TypeArrear_CODE = @Lc_InsSlstDataCur_TypeArrear_CODE) D,
            CASE_Y1 X
      WHERE D.Row_NUMB = 1
        AND D.MemberMci_IDNO = @Ln_InsSlstDataCur_MemberMci_IDNO
        AND D.TypeArrear_CODE = @Lc_InsSlstDataCur_TypeArrear_CODE
        AND X.Case_IDNO = D.Case_IDNO

     SELECT @Ln_Transaction_AMNT = SUM(X.Transaction_AMNT)
       FROM #IstxData_P1 X
      WHERE X.MemberMci_IDNO = @Ln_InsSlstDataCur_MemberMci_IDNO
        AND X.TypeArrear_CODE = @Lc_InsSlstDataCur_TypeArrear_CODE
      GROUP BY X.MemberMci_IDNO,
               X.TypeArrear_CODE

     SELECT @Lc_TypeTransaction_CODE = CASE
                                        WHEN ISNULL(@Ln_Transaction_AMNT, 0) = 0
                                         THEN 'D'
                                        ELSE E.TypeTransaction_CODE
                                       END
       FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY D.MemberMci_IDNO, D.TypeArrear_CODE ORDER BY D.Priority_NUMB DESC ),
                    D.*
               FROM (SELECT Priority_NUMB = CASE C.TypeTransaction_CODE
                                             WHEN 'C'
                                              THEN 3
                                             WHEN 'I'
                                              THEN 2
                                             WHEN 'D'
                                              THEN 1
                                             ELSE 0
                                            END,
                            C.*
                       FROM #IstxData_P1 C
                      WHERE C.SubmitLast_DATE = (SELECT TOP 1 MAX(X.SubmitLast_DATE)
                                                   FROM #IstxData_P1 X
                                                  WHERE X.MemberMci_IDNO = C.MemberMci_IDNO
                                                    AND X.Case_IDNO = C.Case_IDNO
                                                    AND X.TypeArrear_CODE = C.TypeArrear_CODE)
                        AND C.MemberMci_IDNO = @Ln_InsSlstDataCur_MemberMci_IDNO
                        AND C.TypeArrear_CODE = @Lc_InsSlstDataCur_TypeArrear_CODE) D) E
      WHERE E.Row_NUMB = 1

     SELECT @Ls_Line1_ADDR = C.Line1_ADDR,
            @Ls_Line2_ADDR = C.Line2_ADDR,
            @Lc_City_ADDR = C.City_ADDR,
            @Lc_State_ADDR = C.State_ADDR,
            @Lc_Zip_ADDR = C.Zip_ADDR
       FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY B.MemberMci_IDNO ORDER BY B.Priority_NUMB DESC ),
                    B.*
               FROM (SELECT Priority_NUMB = CASE A.TypeAddress_CODE
                                             WHEN 'M'
                                              THEN 3
                                             WHEN 'C'
                                              THEN 2
                                             WHEN 'R'
                                              THEN 1
                                             ELSE 0
                                            END,
                            A.*
                       FROM AHIS_Y1 A
                      WHERE A.MemberMci_IDNO = @Ln_InsSlstDataCur_MemberMci_IDNO
                        AND A.TypeAddress_CODE IN ('M', 'R')
                        AND A.Status_CODE = 'Y'
                        AND A.End_DATE = '12/31/9999'
                        AND A.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(X.TransactionEventSeq_NUMB)
                                                            FROM AHIS_Y1 X
                                                           WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
                                                             AND X.TypeAddress_CODE = A.TypeAddress_CODE
                                                             AND X.Status_CODE = A.Status_CODE
                                                             AND X.End_DATE = '12/31/9999')) B) C
      WHERE C.Row_NUMB = 1

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
     SET @Ls_Sqldata_TEXT = '';

     EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
      @Ac_Note_INDC                = @Lc_Note_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (@Ls_DescriptionError_TEXT,16,1);
      END;

     SET @Ls_Sql_TEXT = 'INSERT SLST_Y1';
     SET @Ls_Sqldata_TEXT = '';

     INSERT INTO SLST_Y1
                 (MemberMci_IDNO,
                  TaxYear_NUMB,
                  MemberSsn_NUMB,
                  TypeArrear_CODE,
                  Case_IDNO,
                  CountyFips_CODE,
                  Arrears_AMNT,
                  TypeTransaction_CODE,
                  Ctrl_NAME,
                  Control_ID,
                  Record_ID,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Line1_ADDR,
                  Line2_ADDR,
                  City_ADDR,
                  State_ADDR,
                  Zip_ADDR,
                  SubmitLast_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB,
                  GenerateNotice_DATE)
     SELECT @Ln_InsSlstDataCur_MemberMci_IDNO AS MemberMci_IDNO,
            @Ln_TaxYear_NUMB AS TaxYear_NUMB,
            ISNULL(B.MemberSsn_NUMB, 0) AS MemberSsn_NUMB,
            @Lc_InsSlstDataCur_TypeArrear_CODE AS TypeArrear_CODE,
            @Ln_Case_IDNO AS Case_IDNO,
            @Lc_CountyFips_CODE AS CountyFips_CODE,
            @Ln_Transaction_AMNT AS Arrears_AMNT,
            @Lc_TypeTransaction_CODE AS TypeTransaction_CODE,
            SUBSTRING(B.Last_NAME, 1, 4) AS Ctrl_NAME,
            @Lc_Space_TEXT AS Control_ID,
            @Lc_Space_TEXT AS Record_ID,
            B.Last_NAME,
            B.First_NAME,
            B.Middle_NAME,
            @Ls_Line1_ADDR AS Line1_ADDR,
            @Ls_Line2_ADDR AS Line2_ADDR,
            @Lc_City_ADDR AS City_ADDR,
            @Lc_State_ADDR AS State_ADDR,
            @Lc_Zip_ADDR AS Zip_ADDR,
            @Ld_Run_DATE AS SubmitLast_DATE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            @Ld_Start_DATE AS Update_DTTM,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
            @Ld_Run_DATE AS GenerateNotice_DATE
       FROM DEMO_Y1 B
      WHERE B.MemberMci_IDNO = @Ln_InsSlstDataCur_MemberMci_IDNO;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM CURSOR InsSlstData_CUR - 2';

     FETCH NEXT FROM InsSlstData_CUR INTO @Ln_InsSlstDataCur_MemberMci_IDNO, @Lc_InsSlstDataCur_TypeArrear_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE InsSlstData_CUR';

   CLOSE InsSlstData_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE InsSlstData_CUR';

   DEALLOCATE InsSlstData_CUR;

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
