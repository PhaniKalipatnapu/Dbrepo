/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_ONE_TIME_CONV_POPULATE_WEMO_AFTER_DECSS_LIVE_BUG13130]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_ONE_TIME_CONV_POPULATE_WEMO_AFTER_DECSS_LIVE_BUG13130
Programmer Name 	: IMP Team
Description			: The procedure used to read data from IVMG table and prorate the grant & populate it in WEMO table
Frequency			: 'DAILY'
Developed On		: 02/03/2014
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_ONE_TIME_CONV_POPULATE_WEMO_AFTER_DECSS_LIVE_BUG13130]
 @Ad_Run_DATE DATE
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE				CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
          @Ls_Procedure_NAME				VARCHAR(100) = 'BATCH_COMMON$SP_ONE_TIME_CONV_POPULATE_WEMO_AFTER_DECSS_LIVE_BUG13130';
  DECLARE @Ln_CommitFreq_QNTY				NUMERIC(5) = 0,
          @Ln_CursorCount_QNTY				NUMERIC(9) = 0,
          @Ln_Error_NUMB					NUMERIC(11),
          @Ln_ErrorLine_NUMB				NUMERIC(11),
          @Ln_FetchStatus_QNTY				INT,
          @Lc_Msg_CODE						CHAR(1),
          @Ls_Sql_TEXT						VARCHAR(100),
          @Ls_Sqldata_TEXT					VARCHAR(1000),
          @Ls_ErrorMessage_TEXT				VARCHAR(4000),
          @Ls_DescriptionError_TEXT			VARCHAR(4000),
          @Ld_Start_DATE					DATETIME,
          @Ld_End_DATE						DATETIME;
  DECLARE @Ln_IvmgCur_CaseWelfare_IDNO      NUMERIC(10),
          @Ln_IvmgCur_CpMci_IDNO			NUMERIC(10),
          @Ln_IvmgCur_WelfareYearMonth_NUMB NUMERIC(6),
          @Ln_IvmgCur_UrgBalance_AMNT		NUMERIC(11,2),	
          @Ln_IvmgCur_Seq_IDNO              NUMERIC(19);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   SET @Ls_Sql_TEXT = '';
   SET @Ls_Sqldata_TEXT = '';

   DECLARE Ivmg_Cur INSENSITIVE CURSOR FOR
    SELECT  Seq_IDNO,
           CaseWelfare_IDNO,
           CpMci_IDNO,
           WelfareYearMonth_NUMB,
           UrgBalance_AMNT
      FROM IvmgWemo13130ProrateGrant_T1 a 
     WHERE Process_INDC = 'N' AND UrgBalance_AMNT <> 0
     ORDER BY Seq_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN Ivmg_Cur';
   SET @Ls_Sqldata_TEXT = '';

   OPEN Ivmg_Cur;

   SET @Ls_Sql_TEXT = 'FETCH Ivmg_Cur -1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM Ivmg_Cur INTO @Ln_IvmgCur_Seq_IDNO, @Ln_IvmgCur_CaseWelfare_IDNO, @Ln_IvmgCur_CpMci_IDNO, @Ln_IvmgCur_WelfareYearMonth_NUMB,@Ln_IvmgCur_UrgBalance_AMNT;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN TRANSACTION WemoTran

   SET @Ls_Sql_TEXT = 'WHILE -1'

   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
    
	 SET @Ln_CursorCount_QNTY = @Ln_CursorCount_QNTY + 1
 
 	 SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG'
	 SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IvmgCur_Seq_IDNO AS VARCHAR) + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvmgCur_CaseWelfare_IDNO AS VARCHAR) + ', CpMci_IDNO = ' + CAST(@Ln_IvmgCur_CpMci_IDNO AS VARCHAR) + ', WelfareYearMonth_NUMB = ' + CAST(@Ln_IvmgCur_WelfareYearMonth_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR);		
	 
	 EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG
	  @An_CaseWelfare_IDNO      = @Ln_IvmgCur_CaseWelfare_IDNO,
	  @An_CpMci_IDNO            = @Ln_IvmgCur_CpMci_IDNO,
	  @An_WelfareYearMonth_NUMB = @Ln_IvmgCur_WelfareYearMonth_NUMB,
	  @Ac_SignedOnWorker_ID     = 'DECSSIMP',
	  @Ad_Run_DATE              = @Ad_Run_DATE,
	  @Ac_Job_ID				= 'BUG13130',
	  @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
	  @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

	 IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
	  BEGIN
	   RAISERROR(50001,16,1)
	  END;

     SET @Ls_Sql_TEXT = 'UPDATE IvmgWemo13130ProrateGrant_T1'
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IvmgCur_Seq_IDNO AS VARCHAR) + ', CaseWelfare_IDNO = ' + CAST(@Ln_IvmgCur_CaseWelfare_IDNO AS VARCHAR) + ', CpMci_IDNO = ' + CAST(@Ln_IvmgCur_CpMci_IDNO AS VARCHAR);		

     UPDATE IvmgWemo13130ProrateGrant_T1
        SET Process_INDC = 'Y'
      WHERE Seq_IDNO = @Ln_IvmgCur_Seq_IDNO
        AND CaseWelfare_IDNO = @Ln_IvmgCur_CaseWelfare_IDNO
        AND CpMci_IDNO = @Ln_IvmgCur_CpMci_IDNO;

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     IF @Ln_CommitFreq_QNTY >= 1000
      BEGIN
       SET @Ln_CommitFreq_QNTY = 0;

       COMMIT TRANSACTION WemoTran

       BEGIN TRANSACTION WemoTran
      
      END;

     SET @Ls_Sql_TEXT = 'FETCH Ivmg_Cur -2'
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM Ivmg_Cur INTO @Ln_IvmgCur_Seq_IDNO, @Ln_IvmgCur_CaseWelfare_IDNO, @Ln_IvmgCur_CpMci_IDNO, @Ln_IvmgCur_WelfareYearMonth_NUMB,@Ln_IvmgCur_UrgBalance_AMNT;

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

   IF CURSOR_STATUS ('LOCAL', 'Ivmg_Cur') IN (0, 1)
    BEGIN
     CLOSE Ivmg_Cur

     DEALLOCATE Ivmg_Cur
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
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END; 

GO
