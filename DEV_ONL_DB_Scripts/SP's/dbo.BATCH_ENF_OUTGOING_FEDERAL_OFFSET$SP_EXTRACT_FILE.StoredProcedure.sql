/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_FILE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_FILE
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_FILE is 
					  to extract file to be sent to IRS
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
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_EXTRACT_FILE] (
 @As_File_NAME             VARCHAR(60) = '',
 @As_FileLocation_TEXT     VARCHAR(80) = '',
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE   CHAR(1) = 'S',
          @Lc_StatusFailed_CODE    CHAR(1) = 'F',
          @Lc_TypeCaseNonTanf_CODE CHAR(1) = 'N',
          @Lc_TypeCaseTanf_CODE    CHAR(1) = 'A',
          @Lc_Space_TEXT           CHAR(1) = ' ',
          @Lc_StateInState_CODE    CHAR(2) = 'DE',
          @Ls_Procedure_NAME       VARCHAR(100) = 'SP_EXTRACT_FILE';
  DECLARE @Ln_Tanf_QNTY             NUMERIC = 0,
          @Ln_NonTanf_QNTY          NUMERIC = 0,
          @Ln_RecordCount_QNTY      NUMERIC = 0,
          @Ln_Tanf_AMNT             NUMERIC = 0,
          @Ln_NonTanf_AMNT          NUMERIC = 0,
          @Ln_ErrorLine_NUMB        NUMERIC(11, 2),
          @Ln_Error_NUMB            NUMERIC(11),
          @Li_FetchStatus_QNTY      SMALLINT,
          @Lc_Empty_TEXT            CHAR = '',
          @Ls_DescriptionError_TEXT VARCHAR(MAX),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(2000),
          @Ls_ErrorDesc_TEXT        VARCHAR(1000),
          @Ls_Query_TEXT            VARCHAR(1000) = '',
          @Ls_Returnvalue_TEXT      VARCHAR(4000),
          @Ls_Errormessage_TEXT     VARCHAR(4000) = '',
          @Ls_BateRecord_TEXT       VARCHAR(4000) = '',
          @Ls_Record_TEXT           VARCHAR(8000);
  DECLARE @Lc_ExtractNcpCur_TypeTransaction_CODE CHAR(1),
          @Lc_ExtractNcpCur_TypeCase_CODE        CHAR(1),
          @Lc_ExtractNcpCur_Request_CODE         CHAR(1),
          @Lc_ExtractNcpCur_StateSubmit_CODE     CHAR(2),
          @Lc_ExtractNcpCur_State_ADDR           CHAR(2),
          @Lc_ExtractNcpCur_County_IDNO          CHAR(3),
          @Lc_ExtractNcpCur_ProcessYear_NUMB     CHAR(4),
          @Lc_ExtractNcpCur_Arrears_AMNT         CHAR(8),
          @Lc_ExtractNcpCur_Issued_DATE          CHAR(8),
          @Lc_ExtractNcpCur_MemberSsn_NUMB       CHAR(9),
          @Lc_ExtractNcpCur_Zip_ADDR             CHAR(9),
          @Lc_ExtractNcpCur_Case_IDNO            CHAR(15),
          @Lc_ExtractNcpCur_First_NAME           CHAR(15),
          @Lc_ExtractNcpCur_Last_NAME            CHAR(20),
          @Lc_ExtractNcpCur_City_ADDR            CHAR(25),
          @Lc_ExtractNcpCur_Line1_ADDR           CHAR(30),
          @Lc_ExtractNcpCur_Line2_ADDR           CHAR(30),
          @Lc_ExtractNcpCur_Exclusion_CODE       CHAR(40);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'CREATE ##ExtractIrsTaxOffset_P1';

   CREATE TABLE ##ExtractIrsTaxOffset_P1
    (
      Seq_IDNO    NUMERIC IDENTITY(1, 1),
      Record_TEXT CHAR(245)
    );

   SET @Ls_Sql_TEXT = 'DECLARE ExtractNcp_Cur';

   DECLARE ExtractNcp_Cur INSENSITIVE CURSOR FOR
    SELECT E.StateSubmit_CODE,
           E.County_IDNO,
           E.MemberSsn_NUMB,
           E.Case_IDNO,
           E.Last_NAME,
           E.First_NAME,
           E.Arrears_AMNT,
           E.TypeTransaction_CODE,
           E.TypeCase_CODE,
           E.ProcessYear_NUMB,
           E.Line1_ADDR,
           E.Line2_ADDR,
           E.City_ADDR,
           E.State_ADDR,
           E.Zip_ADDR,
           E.Issued_DATE,
           E.Exclusion_CODE,
           E.Request_CODE
      FROM EINCP_Y1 E;

   SET @Ls_Sql_TEXT = 'OPEN ExtractNcp_Cur';

   OPEN ExtractNcp_Cur;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM ExtractNcp_Cur - 1';

   FETCH NEXT FROM ExtractNcp_Cur INTO @Lc_ExtractNcpCur_StateSubmit_CODE, @Lc_ExtractNcpCur_County_IDNO, @Lc_ExtractNcpCur_MemberSsn_NUMB, @Lc_ExtractNcpCur_Case_IDNO, @Lc_ExtractNcpCur_Last_NAME, @Lc_ExtractNcpCur_First_NAME, @Lc_ExtractNcpCur_Arrears_AMNT, @Lc_ExtractNcpCur_TypeTransaction_CODE, @Lc_ExtractNcpCur_TypeCase_CODE, @Lc_ExtractNcpCur_ProcessYear_NUMB, @Lc_ExtractNcpCur_Line1_ADDR, @Lc_ExtractNcpCur_Line2_ADDR, @Lc_ExtractNcpCur_City_ADDR, @Lc_ExtractNcpCur_State_ADDR, @Lc_ExtractNcpCur_Zip_ADDR, @Lc_ExtractNcpCur_Issued_DATE, @Lc_ExtractNcpCur_Exclusion_CODE, @Lc_ExtractNcpCur_Request_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH ExtractNcp_Cur';

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
     SET @Ls_BateRecord_TEXT = 'ExtractNcp - CURSOR COUNT - ' + CAST(@Ln_RecordCount_QNTY AS VARCHAR) + ', StateSubmit_CODE = ' + @Lc_ExtractNcpCur_StateSubmit_CODE + ', County_IDNO = ' + @Lc_ExtractNcpCur_County_IDNO + ', MemberSsn_NUMB = ' + @Lc_ExtractNcpCur_MemberSsn_NUMB + ', Case_IDNO = ' + @Lc_ExtractNcpCur_Case_IDNO + ', Last_NAME = ' + @Lc_ExtractNcpCur_Last_NAME + ', First_NAME = ' + @Lc_ExtractNcpCur_First_NAME + ', Arrears_AMNT = ' + @Lc_ExtractNcpCur_Arrears_AMNT + ', TypeTransaction_CODE = ' + @Lc_ExtractNcpCur_TypeTransaction_CODE + ', TypeCase_CODE = ' + @Lc_ExtractNcpCur_TypeCase_CODE + ', ProcessYear_NUMB = ' + @Lc_ExtractNcpCur_ProcessYear_NUMB + ', Line1_ADDR = ' + @Lc_ExtractNcpCur_Line1_ADDR + ', Line2_ADDR = ' + @Lc_ExtractNcpCur_Line2_ADDR + ', City_ADDR = ' + @Lc_ExtractNcpCur_City_ADDR + ', State_ADDR = ' + @Lc_ExtractNcpCur_State_ADDR + ', Zip_ADDR = ' + @Lc_ExtractNcpCur_Zip_ADDR + ', Issued_DATE = ' + @Lc_ExtractNcpCur_Issued_DATE + ', Exclusion_CODE = ' + @Lc_ExtractNcpCur_Exclusion_CODE + ', Request_CODE = ' + @Lc_ExtractNcpCur_Request_CODE;

     IF ISNUMERIC(@Lc_ExtractNcpCur_Arrears_AMNT) = 0
      BEGIN
       SET @Lc_ExtractNcpCur_Arrears_AMNT = '0';
      END;

     IF @Lc_ExtractNcpCur_TypeCase_CODE = @Lc_TypeCaseTanf_CODE
      BEGIN
       SET @Ln_Tanf_QNTY = @Ln_Tanf_QNTY + 1;
       SET @Ln_Tanf_AMNT = @Ln_Tanf_AMNT + CAST(@Lc_ExtractNcpCur_Arrears_AMNT AS NUMERIC);
      END
     ELSE
      BEGIN
       IF @Lc_ExtractNcpCur_TypeCase_CODE = @Lc_TypeCaseNonTanf_CODE
        BEGIN
         SET @Ln_NonTanf_QNTY = @Ln_NonTanf_QNTY + 1;
         SET @Ln_NonTanf_AMNT = @Ln_NonTanf_AMNT + CAST(@Lc_ExtractNcpCur_Arrears_AMNT AS NUMERIC);
        END
       ELSE
        BEGIN
         SET @Ls_ErrorDesc_TEXT = 'INVALID CASE TYPE';

         RAISERROR(50001,16,1);
        END
      END

     SET @Ls_Returnvalue_TEXT = NULL;
     SET @Ls_Returnvalue_TEXT = ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_StateSubmit_CODE, 1, 2))) + REPLICATE(' ', 2)), 2) AS CHAR(2)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_County_IDNO, 1, 3))) + REPLICATE(' ', 3)), 3) AS CHAR(3)), '') + ISNULL((RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(@Lc_ExtractNcpCur_MemberSsn_NUMB)), 9)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_Case_IDNO, 1, 15))) + REPLICATE(' ', 15)), 15) AS CHAR(15)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_Last_NAME, 1, 20))) + REPLICATE(' ', 20)), 20) AS CHAR(20)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_First_NAME, 1, 15))) + REPLICATE(' ', 15)), 15) AS CHAR(15)), '') + ISNULL((RIGHT(REPLICATE('0', 8) + LTRIM(RTRIM(CAST(@Lc_ExtractNcpCur_Arrears_AMNT AS NUMERIC))), 8)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_TypeTransaction_CODE, 1, 1))) + REPLICATE(' ', 1)), 1) AS CHAR(1)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_TypeCase_CODE, 1, 1))) + REPLICATE(' ', 1)), 1) AS CHAR(1)), '') + REPLICATE(@Lc_Space_TEXT, 5) + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_ProcessYear_NUMB, 1, 4))) + REPLICATE(' ', 4)), 4) AS CHAR(4)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_Line1_ADDR, 1, 30))) + REPLICATE(' ', 30)), 30) AS CHAR(30)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_Line2_ADDR, 1, 30))) + REPLICATE(' ', 30)), 30) AS CHAR(30)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_City_ADDR, 1, 25))) + REPLICATE(' ', 25)), 25) AS CHAR(25)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_State_ADDR, 1, 2))) + REPLICATE(' ', 2)), 2) AS CHAR(2)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_Zip_ADDR, 1, 9))) + REPLICATE(' ', 9)), 9) AS CHAR(9)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_Issued_DATE, 1, 8))) + REPLICATE(' ', 8)), 8) AS CHAR(8)), '') + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_Exclusion_CODE, 1, 40))) + REPLICATE(' ', 40)), 40) AS CHAR(40)), '') + REPLICATE(@Lc_Space_TEXT, 17) + ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_ExtractNcpCur_Request_CODE, 1, 1))) + REPLICATE(' ', 1)), 1) AS CHAR(1)), '');
     SET @Ls_Record_TEXT = ISNULL(@Ls_Returnvalue_TEXT, '');
     SET @Ls_Sqldata_TEXT = 'Record_TEXT = ' + ISNULL(@Ls_Record_TEXT, '');

     INSERT INTO ##ExtractIrsTaxOffset_P1
                 (Record_TEXT)
          VALUES ( @Ls_Record_TEXT --Record_TEXT
     );

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM ExtractNcp_Cur - 2';
     SET @Ls_SqlData_TEXT = 'Cursor Previous Record = ' + SUBSTRING(@Ls_BateRecord_TEXT, 1, 970);

     FETCH NEXT FROM ExtractNcp_Cur INTO @Lc_ExtractNcpCur_StateSubmit_CODE, @Lc_ExtractNcpCur_County_IDNO, @Lc_ExtractNcpCur_MemberSsn_NUMB, @Lc_ExtractNcpCur_Case_IDNO, @Lc_ExtractNcpCur_Last_NAME, @Lc_ExtractNcpCur_First_NAME, @Lc_ExtractNcpCur_Arrears_AMNT, @Lc_ExtractNcpCur_TypeTransaction_CODE, @Lc_ExtractNcpCur_TypeCase_CODE, @Lc_ExtractNcpCur_ProcessYear_NUMB, @Lc_ExtractNcpCur_Line1_ADDR, @Lc_ExtractNcpCur_Line2_ADDR, @Lc_ExtractNcpCur_City_ADDR, @Lc_ExtractNcpCur_State_ADDR, @Lc_ExtractNcpCur_Zip_ADDR, @Lc_ExtractNcpCur_Issued_DATE, @Lc_ExtractNcpCur_Exclusion_CODE, @Lc_ExtractNcpCur_Request_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE ExtractNcp_Cur';

   CLOSE ExtractNcp_Cur;

   SET @Ls_Sql_TEXT = 'DEALLOCATE ExtractNcp_Cur';

   DEALLOCATE ExtractNcp_Cur;

   SET @Ls_Returnvalue_TEXT = NULL;
   SET @Ls_Returnvalue_TEXT = ISNULL(CAST(LEFT((LTRIM(RTRIM(SUBSTRING(@Lc_StateInState_CODE, 1, 2))) + REPLICATE(' ', 2)), 2) AS CHAR(2)), '') + 'CTL' + ISNULL((RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(CAST(@Ln_Tanf_QNTY AS VARCHAR))), 9)), '') + ISNULL((RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(CAST(@Ln_NonTanf_QNTY AS VARCHAR))), 9)), '') + ISNULL((RIGHT(REPLICATE('0', 11) + LTRIM(RTRIM(CAST(@Ln_Tanf_AMNT AS VARCHAR))), 11)), '') + ISNULL((RIGHT(REPLICATE('0', 11) + LTRIM(RTRIM(CAST(@Ln_NonTanf_AMNT AS VARCHAR))), 11)), '') + REPLICATE(@Lc_Space_TEXT, 200);
   SET @Ls_Record_TEXT = ISNULL(@Ls_Returnvalue_TEXT, '');
   SET @Ls_Sqldata_TEXT = 'Record_TEXT = ' + ISNULL(@Ls_Record_TEXT, '');

   INSERT INTO ##ExtractIrsTaxOffset_P1
               (Record_TEXT)
        VALUES ( @Ls_Record_TEXT --Record_TEXT
   );

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractIrsTaxOffset_P1 ORDER BY Seq_IDNO';
   SET @Ls_Sql_TEXT = 'Extract Data';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + ISNULL(@As_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@As_File_NAME, '') + ', Query_TEXT = ' + ISNULL(@Ls_Query_TEXT, '');

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @As_FileLocation_TEXT,
    @As_File_NAME             = @As_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;

   DROP TABLE ##ExtractIrsTaxOffset_P1;
  END TRY

  BEGIN CATCH
   IF OBJECT_ID('tempdb..##ExtractIrsTaxOffset_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractIrsTaxOffset_P1;
    END

   IF CURSOR_STATUS('Local', 'ExtractNcp_Cur') IN (0, 1)
    BEGIN
     CLOSE ExtractNcp_Cur;

     DEALLOCATE ExtractNcp_Cur;
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
