/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BICASH]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BICASH
Programmer Name	:	IMP Team.
Description		:	This process loads Case history details.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BICASH]
 @An_RecordCount_NUMB      NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY  INT = 0,
          @Lc_Space_TEXT     CHAR(1) = ' ',
          @Lc_Failed_CODE    CHAR(1) = 'F',
          @Lc_Success_CODE   CHAR(1) = 'S',
          @Lc_TypeError_CODE CHAR(1) = 'E',
          @Lc_BateError_CODE CHAR(5) = 'E0944',
          @Lc_Job_ID         CHAR(7) = 'DEB0840',
          @Lc_Process_NAME   CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME VARCHAR(50) = 'SP_PROCESS_BICASH';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'DELETE FROM BPCASH_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BPCASH_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BPCASH_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT BPCASH_Y1
          (Case_IDNO,
           SupportYearMonth_NUMB,
           EndOfMonth_DATE,
           YearMonth_NUMB,
           Orderby_NUMB,
           CpArrear_AMNT,
           IvAArrear_AMNT,
           AppCs_AMNT,
           AppCpArr_AMNT,
           AppIvaArr_AMNT,
           Mso_AMNT,
           UnpaidMso_AMNT,
           UndistCollection_AMNT,
           UndistCollectionMonth_AMNT,
           IveArrear_AMNT)
   SELECT DISTINCT
          x.Case_IDNO,
          x.SupportYearMonth_NUMB,
          x.EndOfMonth_DATE,
          x.YearMonth_NUMB,
          x.Orderby_NUMB,
          ISNULL(l.CpArrear_AMNT, @Ln_Zero_NUMB) AS CpArrear_AMNT,
          ISNULL(l.IvA1Arrear_AMNT, @Ln_Zero_NUMB) AS IvAArrear_AMNT,
          ISNULL(a.AppCs_AMNT, @Ln_Zero_NUMB) AS AppCs_AMNT,
          ISNULL(a.AppCpArr_AMNT, @Ln_Zero_NUMB) AS AppCpArr_AMNT,
          ISNULL(a.AppIvaArr_AMNT, @Ln_Zero_NUMB) AS AppIvaArr_AMNT,
          ISNULL(m.TotMso_AMNT, @Ln_Zero_NUMB) AS Mso_AMNT,
          DIFFERENCE(ISNULL(m.TotMso_AMNT, @Ln_Zero_NUMB), ISNULL(a.AppCs_AMNT, @Ln_Zero_NUMB)) AS UnpaidMso_AMNT,
          ISNULL(u.UndistCollection_AMNT, @Ln_Zero_NUMB) AS UndistCollection_AMNT,
          ISNULL(u.UndistCollection_AMNT, @Ln_Zero_NUMB) AS UndistCollectionMonth_AMNT,
          ISNULL(l.IveArrear_AMNT, @Ln_Zero_NUMB) AS IveArrear_AMNT
     FROM (SELECT a.Case_IDNO,
                  a.MemberMci_IDNO,
                  b.SupportYearMonth_NUMB,
                  b.End_DATE AS EndOfMonth_DATE,
                  b.SupportYearMonth_NUMB AS YearMonth_NUMB,
                  b.DateRecordSeq_IDNO AS Orderby_NUMB
             FROM BPCASE_Y1 a,
                  BPDATE_Y1 b) AS x,
          (SELECT x.Case_IDNO,
                  x.SupportYearMonth_NUMB,
                  x.CpArrear_AMNT,
                  x.IvA1Arrear_AMNT,
                  x.IveArrear_AMNT
             FROM (SELECT z.Case_IDNO,
                          z.SupportYearMonth_NUMB,
                          SUM(z.CpArrear_AMNT) AS CpArrear_AMNT,
                          SUM(z.IvA1Arrear_AMNT) AS IvA1Arrear_AMNT, 
                          SUM(z.IvefArrear_AMNT) AS IveArrear_AMNT
                     FROM BPLSUP_Y1 z
                    GROUP BY z.Case_IDNO,
                             z.SupportYearMonth_NUMB) AS x) AS l,
          (SELECT DISTINCT
                  x.Case_IDNO,
                  x.SupportYearMonth_NUMB,
                  x.AppCs_AMNT,
                  x.AppCpArr_AMNT,
                  x.AppIvaArr_AMNT
             FROM (SELECT z.Case_IDNO,
                          z.SupportYearMonth_NUMB,
                          SUM(z.AppMtdCs_AMNT) OVER (PARTITION BY Case_IDNO, SupportYearMonth_NUMB) AS AppCs_AMNT,
                          SUM(z.AppMtdCpArr_AMNT) OVER (PARTITION BY Case_IDNO, SupportYearMonth_NUMB) AS AppCpArr_AMNT,
                          SUM(z.AppMtdIvaArr_AMNT) OVER (PARTITION BY Case_IDNO, SupportYearMonth_NUMB) AS AppIvaArr_AMNT
                     FROM BPAPPL_Y1 z
                    GROUP BY z.Case_IDNO,
                             z.SupportYearMonth_NUMB,
                             z.AppMtdCs_AMNT,
                             z.AppMtdCpArr_AMNT,
                             z.AppMtdIvaArr_AMNT) AS x) AS a,
          (SELECT DISTINCT
                  x.Case_IDNO,
                  x.SupportYearMonth_NUMB,
                  x.TotMso_AMNT
             FROM (SELECT z.Case_IDNO,
                          z.SupportYearMonth_NUMB,
                          SUM(z.TotMso_AMNT) OVER (PARTITION BY Case_IDNO, SupportYearMonth_NUMB) AS TotMso_AMNT
                     FROM BPMSOD_Y1 z
                    WHERE z.Case_IDNO IN (SELECT DISTINCT
                                                 bc.Case_IDNO
                                            FROM BPCASE_Y1 bc)
                    GROUP BY z.Case_IDNO,
                             z.SupportYearMonth_NUMB,
                             z.TotMso_AMNT) AS x) AS m,
          (SELECT DISTINCT
                  x.Case_IDNO,
                  x.SupportYearMonth_NUMB,
                  x.UndistCollection_AMNT
             FROM (SELECT z.Case_IDNO,
                          z.SupportYearMonth_NUMB,
                          SUM (z.UndistCollection_AMNT) OVER (PARTITION BY Case_IDNO, SupportYearMonth_NUMB) AS UndistCollection_AMNT
                     FROM (SELECT a.Case_IDNO,
                                  CAST(SUBSTRING(CONVERT(VARCHAR(6), b.Receipt_DATE, 112), 1, 6) AS NUMERIC(6)) AS SupportYearMonth_NUMB,
                                  b.UndistCollection_AMNT
                             FROM BPCASE_Y1 a,
                                  BPUCOL_Y1 b
                            WHERE (a.Case_IDNO = b.Case_IDNO
                                    OR (LTRIM(RTRIM(b.Case_IDNO)) IS NULL
                                        AND a.MemberMci_IDNO = b.PayorMCI_IDNO))
                              AND b.Receipt_DATE IS NOT NULL) AS z
                    GROUP BY z.Case_IDNO,
                             z.SupportYearMonth_NUMB,
                             z.UndistCollection_AMNT) AS x) AS u
    WHERE x.Case_IDNO = l.Case_IDNO
      AND x.SupportYearMonth_NUMB = l.SupportYearMonth_NUMB
      AND x.Case_IDNO = a.Case_IDNO
      AND x.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB
      AND x.Case_IDNO = m.Case_IDNO
      AND x.SupportYearMonth_NUMB = m.SupportYearMonth_NUMB
      AND x.Case_IDNO = u.Case_IDNO
      AND x.SupportYearMonth_NUMB = u.SupportYearMonth_NUMB;

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

     IF @Lc_Msg_CODE = @Lc_Failed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @An_RecordCount_NUMB = @An_RecordCount_NUMB + @Li_RowCount_QNTY;
  END TRY

  BEGIN CATCH
   BEGIN
    SET @Ac_Msg_CODE = @Lc_Failed_CODE;
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
