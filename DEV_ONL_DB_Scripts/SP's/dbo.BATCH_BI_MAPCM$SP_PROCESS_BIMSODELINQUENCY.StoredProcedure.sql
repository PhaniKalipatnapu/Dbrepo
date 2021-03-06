/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIMSODELINQUENCY]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIMSODELINQUENCY
Programmer Name	:	IMP Team.
Description		:	This process checks for cases that are delinquent in MSO and Collections.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIMSODELINQUENCY]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT, 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY            INT = 0,
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_No_TEXT                  CHAR(1) = 'N',
          @Lc_Yes_TEXT                 CHAR(1) = 'Y',
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_TypeError_CODE           CHAR(1) = 'E',
          @Lc_Pending_CODE             CHAR(1) = 'P',
          @Lc_DebtTypeChildSupp_CODE   CHAR(2) = 'CS',
          @Lc_DebtTypeMedicalSupp_CODE CHAR(2) = 'MS',
          @Lc_DebtTypeSpousalSupp_CODE CHAR(2) = 'SS',
          @Lc_BateError_CODE           CHAR(5) = 'E0944',
          @Lc_Job_ID                   CHAR(7) = 'DEB0845',
          @Lc_Process_NAME             CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME           VARCHAR(50) = 'SP_PROCESS_BIMSODELINQUENCY';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
		  @Ln_MaxBsltLength_NUMB	NUMERIC(6) = 999999,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BPDLNQ_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPDLNQ_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPDLNQ_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPDLNQ_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           SupportYearMonth_NUMB,
           End_DATE,
           TotMso_AMNT,
           AppMtdCs_AMNT,
           Arrears_AMNT)
   SELECT b.Case_IDNO,
          b.OrderSeq_NUMB,
          b.ObligationSeq_NUMB,
          b.SupportYearMonth_NUMB,
          t.End_DATE,
          b.TotMso_AMNT,
          ISNULL(m.AppMtdCs_AMNT, @Ln_Zero_NUMB) AS AppMtdCs_AMNT,
          ISNULL(n.Arrears_AMNT, @Ln_Zero_NUMB) AS Arrears_AMNT
     FROM (SELECT x.Case_IDNO,
                  x.OrderSeq_NUMB,
                  x.ObligationSeq_NUMB,
                  x.SupportYearMonth_NUMB,
                  x.TotMso_AMNT
             FROM (SELECT b.Case_IDNO,
                          b.OrderSeq_NUMB,
                          b.ObligationSeq_NUMB,
                          b.SupportYearMonth_NUMB,
                          ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO, b.OrderSeq_NUMB, b.ObligationSeq_NUMB, b.SupportYearMonth_NUMB ORDER BY b.SupportYearMonth_NUMB DESC) AS rnm,
                          SUM(b.TotMso_AMNT) OVER(PARTITION BY b.Case_IDNO, b.OrderSeq_NUMB, b.ObligationSeq_NUMB, b.SupportYearMonth_NUMB) AS TotMso_AMNT
                     FROM BPMSOD_Y1 b) AS x
            WHERE x.rnm = 1) AS b
          LEFT OUTER JOIN (SELECT x.Case_IDNO,
                                  x.OrderSeq_NUMB,
                                  x.ObligationSeq_NUMB,
                                  x.SupportYearMonth_NUMB,
                                  x.AppMtdCs_AMNT
                             FROM (SELECT b.Case_IDNO,
                                          b.OrderSeq_NUMB,
                                          b.ObligationSeq_NUMB,
                                          b.SupportYearMonth_NUMB,
                                          ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO, b.OrderSeq_NUMB, b.ObligationSeq_NUMB, b.SupportYearMonth_NUMB ORDER BY b.SupportYearMonth_NUMB DESC) AS rnm,
                                          SUM(b.AppMtdCs_AMNT) OVER(PARTITION BY b.Case_IDNO, b.OrderSeq_NUMB, b.ObligationSeq_NUMB, b.SupportYearMonth_NUMB) AS AppMtdCs_AMNT
                                     FROM BPAPPL_Y1 b) AS x
                            WHERE x.rnm = 1) AS m
           ON b.Case_IDNO = m.Case_IDNO
              AND b.OrderSeq_NUMB = m.OrderSeq_NUMB
              AND b.ObligationSeq_NUMB = m.ObligationSeq_NUMB
              AND b.SupportYearMonth_NUMB = m.SupportYearMonth_NUMB
          LEFT OUTER JOIN (SELECT x.Case_IDNO,
                                  x.OrderSeq_NUMB,
                                  x.ObligationSeq_NUMB,
                                  x.SupportYearMonth_NUMB,
                                  x.Arrears_AMNT
                             FROM (SELECT b.Case_IDNO,
                                          b.OrderSeq_NUMB,
                                          b.ObligationSeq_NUMB,
                                          b.SupportYearMonth_NUMB,
                                          ROW_NUMBER() OVER(PARTITION BY b.Case_IDNO, b.OrderSeq_NUMB, b.ObligationSeq_NUMB, b.SupportYearMonth_NUMB ORDER BY b.SupportYearMonth_NUMB DESC) AS rnm,
                                          SUM(b.TanfArrear_AMNT + b.NonTanfArrear_AMNT + b.IvefArrear_AMNT + b.MedicAidArrear_AMNT + b.NffcArrear_AMNT + b.NffmArrear_AMNT) OVER(PARTITION BY b.Case_IDNO, b.OrderSeq_NUMB, b.ObligationSeq_NUMB, b.SupportYearMonth_NUMB) AS Arrears_AMNT
                                     FROM BPLSUP_Y1 b) AS x
                            WHERE x.rnm = 1) AS n
           ON b.Case_IDNO = n.Case_IDNO
              AND b.OrderSeq_NUMB = n.OrderSeq_NUMB
              AND b.ObligationSeq_NUMB = n.ObligationSeq_NUMB
              AND b.SupportYearMonth_NUMB = n.SupportYearMonth_NUMB,
          BPDATE_Y1 t,
          BPOBLE_Y1 a
    WHERE b.SupportYearMonth_NUMB = t.SupportYearMonth_NUMB
      AND b.Case_IDNO = a.Case_IDNO
      AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
      AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
      AND (a.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeMedicalSupp_CODE)
            OR (a.TypeDebt_CODE = @Lc_DebtTypeSpousalSupp_CODE
                AND EXISTS (SELECT 1
                              FROM BPOBLE_Y1 x
                             WHERE x.Case_IDNO = a.Case_IDNO
                               AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
                               AND x.TypeDebt_CODE = @Lc_DebtTypeChildSupp_CODE)));

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DELETE FROM BPDLNC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPDLNC_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPDLNC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPDLNC_Y1
          (Case_IDNO,
           SupportYearMonth_NUMB,
           Mso_CODE,
           Collection_INDC)
   SELECT x.Case_IDNO,
          x.SupportYearMonth_NUMB,
          CASE
           WHEN ((x.TotMso_AMNT - x.AppMtdCs_AMNT) > @Ln_Zero_NUMB
                  OR x.Arrears_AMNT > @Ln_Zero_NUMB)
            THEN @Lc_No_TEXT
           ELSE @Lc_Yes_TEXT
          END AS Mso_CODE,
          CASE
           WHEN x.AppMtdCs_AMNT = @Ln_Zero_NUMB
            THEN @Lc_No_TEXT
           WHEN x.AppMtdCs_AMNT < x.TotMso_AMNT
            THEN @Lc_Pending_CODE
           ELSE @Lc_Yes_TEXT
          END AS Collection_INDC
     FROM (SELECT a.Case_IDNO,
                  a.SupportYearMonth_NUMB,
                  a.End_DATE,
                  SUM(a.TotMso_AMNT) TotMso_AMNT,
                  SUM(a.AppMtdCs_AMNT) AppMtdCs_AMNT,
                  SUM(a.Arrears_AMNT) Arrears_AMNT
             FROM BPDLNQ_Y1 a
            GROUP BY a.Case_IDNO,
                     a.SupportYearMonth_NUMB,
                     a.End_DATE) AS x;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END   

   SET @Ls_Sql_TEXT = 'DELETE TABLE BDLNQ_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BDLNQ_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BDLNQ_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BDLNQ_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           SupportYearMonth_NUMB,
           End_DATE,
           TotMso_AMNT,
           AppMtdCs_AMNT,
           Arrears_AMNT)
   SELECT a.Case_IDNO,
          a.OrderSeq_NUMB,
          a.ObligationSeq_NUMB,
          a.SupportYearMonth_NUMB,
          a.End_DATE,
          a.TotMso_AMNT,
          a.AppMtdCs_AMNT,
          a.Arrears_AMNT
     FROM BPDLNQ_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'DELETE FROM BDLNC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BDLNC_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BDLNC_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BDLNC_Y1
          (Case_IDNO,
           SupportYearMonth_NUMB,
           Mso_CODE,
           Collection_INDC)
   SELECT a.Case_IDNO,
          a.SupportYearMonth_NUMB,
          a.Mso_CODE,
          a.Collection_INDC
     FROM BPDLNC_Y1 a;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF (@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Lc_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_BateError_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Start_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

	IF(@An_RecordCount_NUMB > @Ln_MaxBsltLength_NUMB)
    BEGIN
	 SET @An_RecordCount_NUMB = @Ln_MaxBsltLength_NUMB;
	END  
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    SET @An_RecordCount_NUMB = 0;
    SET @Ln_Error_NUMB = ERROR_NUMBER ();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
    SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
   END
  END CATCH
 END 

GO
