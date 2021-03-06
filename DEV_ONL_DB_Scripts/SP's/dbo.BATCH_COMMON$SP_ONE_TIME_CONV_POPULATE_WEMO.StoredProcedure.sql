/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_ONE_TIME_CONV_POPULATE_WEMO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_ONE_TIME_CONV_POPULATE_WEMO
Programmer Name 	: IMP Team
Description			: The procedure used to read data from IVMG table and prorate the grant & populate it in WEMO table
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_ONE_TIME_CONV_POPULATE_WEMO]
 @Ad_Run_DATE DATE
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_COMMON$SP_ONE_TIME_CONV_POPULATE_WEMO';
  DECLARE @Ln_CommitFreq_QNTY           NUMERIC(5) = 0,
          @Ln_CursorCount_QNTY          NUMERIC(9) = 0,
          @Ln_TotalEligRecordCount_QNTY NUMERIC(9) = 0,
          @Ln_Error_NUMB                NUMERIC(11),
          @Ln_ErrorLine_NUMB            NUMERIC(11),
          @Ln_FetchStatus_QNTY          INT,
          @Lc_Msg_CODE                  CHAR(1),
          @Ls_Sql_TEXT                  VARCHAR(100),
          @Ls_Sqldata_TEXT              VARCHAR(1000),
          @Ls_ErrorMessage_TEXT         VARCHAR(4000),
          @Ls_DescriptionError_TEXT     VARCHAR(4000),
          @Ld_Start_DATE                DATETIME,
          @Ld_End_DATE                  DATETIME;
  DECLARE @Ln_IvmgCur_CaseWelfare_IDNO      NUMERIC(10),
          @Ln_IvmgCur_MemberMci_IDNO        NUMERIC(10),
          @Ln_IvmgCur_WelfareYearMonth_NUMB NUMERIC(6),
          @Ln_IvmgCur_Seq_IDNO              NUMERIC(19);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()

   --Check if temporary table exists drop the table
   IF OBJECT_ID('tempdb..#TmpIvmg_P1') IS NOT NULL
    BEGIN
     DROP TABLE #TmpIvmg_P1;
    END

   CREATE TABLE #TmpIvmg_P1
    (
      Seq_IDNO              NUMERIC(19),
      CaseWelfare_IDNO      NUMERIC(10),
      MemberMci_IDNO        NUMERIC(10),
      WelfareYearMonth_NUMB NUMERIC(6),
      Process_INDC          CHAR(1),
      Thread_NUMB           NUMERIC(15)
    );

   SET @Ls_Sql_TEXT = 'INSERT #TmpIvmg_P1';
   SET @Ls_Sqldata_TEXT = '';

   INSERT INTO #TmpIvmg_P1
   SELECT ROW_NUMBER() OVER (ORDER BY Record_NUMB) Seq_IDNO,
          CaseWelfare_IDNO,
          MemberMCI_IDNO,
          WelfareYearMonth_NUMB,
          Process_INDC,
          0 Thread_NUMB
     FROM (SELECT CaseWelfare_IDNO,
                  MemberMCI_IDNO,
                  'N' Process_INDC,
                  SUBSTRING(CONVERT(VARCHAR(6), @Ad_Run_DATE, 112), 1, 6) WelfareYearMonth_NUMB,
                  0 Record_NUMB
             FROM (SELECT CaseWelfare_IDNO,
                          A.MemberMCI_IDNO
                     FROM MHIS_Y1 A,
                          CMEM_Y1 B
                    WHERE CaseWelfare_IDNO <> 0
                      AND A.Case_IDNO = B.Case_IDNO
                      AND A.MemberMCI_IDNO = B.MemberMCI_IDNO
                      AND CaseRelationship_CODE = 'C'
                      AND CaseMemberStatus_CODE = 'A'
                    GROUP BY A.CaseWelfare_IDNO,
                             A.MemberMCI_IDNO) A)B;

   DECLARE Ivmg_Cur CURSOR LOCAL FOR
    SELECT Seq_IDNO,
           CaseWelfare_IDNO,
           MemberMCI_IDNO,
           WelfareYearMonth_NUMB
      FROM #TmpIvmg_P1 a
     WHERE Process_INDC = 'N'
     ORDER BY Seq_IDNO;

   SET @Ls_Sql_TEXT = 'SELECT #TmpIvmg_P1 - 1';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_TotalEligRecordCount_QNTY = COUNT(1)
     FROM #TmpIvmg_P1 a
    WHERE Process_INDC = 'N';

   SET @Ls_Sql_TEXT = 'OPEN Ivmg_Cur';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Ivmg_Cur;

   SET @Ls_Sql_TEXT = 'FETCH Ivmg_Cur -1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Ivmg_Cur INTO @Ln_IvmgCur_Seq_IDNO, @Ln_IvmgCur_CaseWelfare_IDNO, @Ln_IvmgCur_MemberMci_IDNO, @Ln_IvmgCur_WelfareYearMonth_NUMB;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN TRANSACTION WemoTran

   SET @Ls_Sql_TEXT = 'WHILE -1'

   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_CursorCount_QNTY = @Ln_CursorCount_QNTY + 1
     SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG'
     SET @Ls_Sqldata_TEXT = 'WELFER CASE Seq_IDNO ' + CAST(@Ln_IvmgCur_CaseWelfare_IDNO AS VARCHAR) + 'MONTH WELFARE ' + CAST(@Ln_IvmgCur_WelfareYearMonth_NUMB AS VARCHAR) + 'Record No ' + CAST(@Ln_IvmgCur_Seq_IDNO AS VARCHAR);

     EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG
      @An_CaseWelfare_IDNO      = @Ln_IvmgCur_CaseWelfare_IDNO,
      @An_CpMci_IDNO            = @Ln_IvmgCur_MemberMci_IDNO,
      @An_WelfareYearMonth_NUMB = @Ln_IvmgCur_WelfareYearMonth_NUMB,
      @Ac_SignedOnWorker_ID     = 'DECSS',
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Job_ID				= 'ONETIME',
	  @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1)
      END;

     SET @Ls_Sql_TEXT = 'UPDATE CONV_STEP2_TMPIVMG'
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO ' + CAST(@Ln_IvmgCur_Seq_IDNO AS VARCHAR) + ', = CaseWelfare_IDNO ' + CAST(@Ln_IvmgCur_CaseWelfare_IDNO AS VARCHAR) + ', = MemberMCI_IDNO ' + CAST(@Ln_IvmgCur_MemberMci_IDNO AS VARCHAR);

     UPDATE #TmpIvmg_P1
        SET Process_INDC = 'Y'
      WHERE Seq_IDNO = @Ln_IvmgCur_Seq_IDNO
        AND CaseWelfare_IDNO = @Ln_IvmgCur_CaseWelfare_IDNO
        AND MemberMCI_IDNO = @Ln_IvmgCur_MemberMci_IDNO;

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     IF @Ln_CommitFreq_QNTY >= 1000
      BEGIN
       SET @Ln_CommitFreq_QNTY = 0;

       COMMIT TRANSACTION WemoTran

       BEGIN TRANSACTION WemoTran
      
      END;

     SET @Ls_Sql_TEXT = 'FETCH Ivmg_Cur -2'
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Ivmg_Cur INTO @Ln_IvmgCur_Seq_IDNO, @Ln_IvmgCur_CaseWelfare_IDNO, @Ln_IvmgCur_MemberMci_IDNO, @Ln_IvmgCur_WelfareYearMonth_NUMB;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Ivmg_Cur;

   DEALLOCATE Ivmg_Cur;

   COMMIT TRANSACTION WemoTran;

   SET @Ld_End_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   SELECT 'Success' Status_CODE,
          StartTime,
          EndTime,
          CAST(DATEDIFF(hh, 0, DtDiff) AS VARCHAR) + ' Hours:' + CAST (DATEPART(minute, DtDiff) AS VARCHAR) + ' Minutes:' + CAST (DATEPART(second, DtDiff) AS VARCHAR) + ' Seconds' TimeTaken,
          @Ln_CursorCount_QNTY NoOfRecordsProcessed
     FROM (SELECT DtDiff = EndTime - StartTime,
                  a.*
             FROM (SELECT StartTime = @Ld_Start_DATE,
                          EndTime = @Ld_End_DATE) a) b
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION WemoTran;
    END

   --Check if temporary table exists drop the table
   IF OBJECT_ID('tempdb..#TmpIvmg_P1') IS NOT NULL
    BEGIN
     DROP TABLE #TmpIvmg_P1;
    END

   IF CURSOR_STATUS ('LOCAL', 'Ivmg_Cur') IN (0, 1)
    BEGIN
     CLOSE Ivmg_Cur

     DEALLOCATE Ivmg_Cur
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END; 

GO
