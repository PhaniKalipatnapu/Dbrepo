/****** Object:  StoredProcedure [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDATE]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_BI_MAPCM$SP_PROCESS_BIDATE
Programmer Name	:	IMP Team.
Description		:	It loads date values for past 12 months into the BDATE_Y1 table.
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
CREATE PROCEDURE [dbo].[BATCH_BI_MAPCM$SP_PROCESS_BIDATE] 
 @An_RecordCount_NUMB	   NUMERIC(6) OUTPUT, 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY      INT = 0,
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_Space_TEXT         CHAR(1) = ' ',
          @Lc_BateError_CODE     CHAR(5) = 'E0944',
          @Lc_Job_ID             CHAR(7) = 'DEB0810',
          @Lc_Process_NAME       CHAR(14) = 'BATCH_BI_MAPCM',
          @Ls_Procedure_NAME     VARCHAR(50) = 'SP_PROCESS_BIDATE';
  DECLARE @Ln_Zero_NUMB             NUMERIC(1) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_TypeError_CODE        CHAR(1),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Begin_DATE            DATE,
          @Ld_End_DATE              DATE,
          @Ld_Start_DATE            DATETIME2;

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ld_End_DATE = CONVERT(VARCHAR(11), dbo.BATCH_COMMON_SCALAR$SF_LAST_DAY(@Ld_Start_DATE), 112);
   SET @Ld_Begin_DATE = DATEADD(m, -13, @Ld_End_DATE);

   BEGIN
    SET @Ls_Sql_TEXT = 'DELETE FROM BPDATE_Y1';
    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

    DELETE FROM BPDATE_Y1;

    -- Generate date details for the past 12 months from run date.
    WHILE CAST(CONVERT(VARCHAR(8), @Ld_Begin_DATE, 112) AS NUMERIC(8)) <= CAST(CONVERT(VARCHAR(8), @Ld_End_DATE, 112) AS NUMERIC(8))
     BEGIN
      BEGIN
       IF CAST(SUBSTRING(CONVERT(VARCHAR(8), @Ld_Begin_DATE, 112), 7, 2) AS NUMERIC(2)) = 1
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT INTO BPDATE_Y1';
         SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

         INSERT BPDATE_Y1
                (Begin_DATE,
                 End_DATE,
                 MonthFull_NAME,
                 Quarter_NAME,
                 Year_NAME,
                 DayOfMonth_NAME,
                 SupportYearMonth_NUMB)
         VALUES ( @Ld_Begin_DATE,-- Begin_DATE
                  @Ld_Begin_DATE,-- End_DATE
                  UPPER(SUBSTRING(CONVERT(VARCHAR(11), @Ld_Begin_DATE, 106), 4, 3)),-- MonthFull_NAME
                  CASE
                   WHEN CAST(SUBSTRING(CONVERT(VARCHAR(11), @Ld_Begin_DATE, 101), 1, 2) AS NUMERIC) BETWEEN 1 AND 3
                    THEN 1
                   WHEN CAST(SUBSTRING(CONVERT(VARCHAR(11), @Ld_Begin_DATE, 101), 1, 2) AS NUMERIC) BETWEEN 4 AND 6
                    THEN 2
                   WHEN CAST(SUBSTRING(CONVERT(VARCHAR(11), @Ld_Begin_DATE, 101), 1, 2) AS NUMERIC) BETWEEN 7 AND 9
                    THEN 3
                   WHEN CAST(SUBSTRING(CONVERT(VARCHAR(11), @Ld_Begin_DATE, 101), 1, 2) AS NUMERIC) BETWEEN 10 AND 12
                    THEN 4
                  END,-- Quarter_NAME
                  SUBSTRING(CONVERT(VARCHAR(11), @Ld_Begin_DATE, 106), 8, 4),-- Year_NAME
                  SUBSTRING(CONVERT(VARCHAR(11), @Ld_Begin_DATE, 106), 1, 2),-- DayOfMonth_NAME
                  CAST(SUBSTRING(CONVERT(VARCHAR(6), @Ld_Begin_DATE, 112), 1, 6) AS NUMERIC(6))-- SupportYearMonth_NUMB
         );
        END

       SET @Li_RowCount_QNTY = @Li_RowCount_QNTY + 1;
       SET @Ld_Begin_DATE = DATEADD(D, 1, @Ld_Begin_DATE);
      END
     END
    
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

    SET @Ls_Sql_TEXT = 'UPDATE BPDATE_Y1';
    SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

    UPDATE BPDATE_Y1
       SET End_DATE = ISNULL((SELECT DATEADD(D, -1, z.Begin_DATE)
                                FROM BPDATE_Y1 z
                               WHERE z.DateRecordSeq_IDNO = a.DateRecordSeq_IDNO + 1), @Ld_End_DATE)
      FROM BPDATE_Y1 a;
   END

   SET @Ls_Sql_TEXT = 'DELETE FROM BDATE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   DELETE FROM BDATE_Y1;

   SET @Ls_Sql_TEXT = 'INSERT INTO BDATE_Y1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   INSERT INTO BDATE_Y1
               (Begin_DATE,
                End_DATE,
                MonthFull_NAME,
                Quarter_NAME,
                Year_NAME,
                DayOfMonth_NAME,
                SupportYearMonth_NUMB)
   SELECT a.Begin_DATE,
          a.End_DATE,
          a.MonthFull_NAME,
          a.Quarter_NAME,
          a.Year_NAME,
          a.DayOfMonth_NAME,
          a.SupportYearMonth_NUMB
     FROM BPDATE_Y1 a;

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
  END TRY

  BEGIN CATCH
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
  END CATCH
 END 

GO
