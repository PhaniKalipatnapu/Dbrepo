/****** Object:  StoredProcedure [dbo].[BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_RESULT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_RESULT
Programmer Name	:	IMP Team.
Description		:	This process is to read file and load the LERES_Y1 table.
Frequency		:	
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	BATCH_COMMON$SP_GET_BATCH_DETAILS2 ,
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_UPDATE_PARM_DATE,
                    BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_INCOMING_EIWO$SP_LOAD_EIWO_RESULT]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE  CHAR(1) = 'A',
          @Lc_Process_INDC            CHAR(1) = 'N',
          @Lc_Yes_INDC                CHAR(1) = 'Y',
          @Lc_TypeErrorWarning_CODE   CHAR(1) = 'W',
          @Lc_FileHeaderRecord_TEXT   CHAR(3) = 'FHS',
          @Lc_FileTrailerRecord_TEXT  CHAR(3) = 'FTS',
          @Lc_BatchHeaderRecord_TEXT  CHAR(3) = 'BHS',
          @Lc_BatchTrailerRecord_TEXT CHAR(3) = 'BTS',
          @Lc_ErrorE0944_CODE         CHAR(5) = 'E0944',
          @Lc_BatchRunUser_TEXT       CHAR(5) = 'BATCH',
          @Lc_Job_ID                  CHAR(7) = 'DEB1300',
          @Lc_Successful_TEXT         CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT    VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_LOAD_EIWO_RESULT',
          @Ls_Process_NAME            VARCHAR(100) = 'BATCH_ENF_INCOMING_EIWO';
  DECLARE @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(5) = 0,
          @Ln_Error_NUMB                  NUMERIC(11),
          @Ln_ErrorLine_NUMB              NUMERIC(11),
          @Ln_TrailerRecordCount_NUMB     NUMERIC(11, 0),
          @Ln_RecordCount_NUMB            NUMERIC(11, 0),
          @Ln_BatchHeaderCount_NUMB       NUMERIC(11, 0),
          @Ln_BatchTrailerCount_NUMB      NUMERIC(11, 0),
          @Lc_Msg_CODE                    CHAR(1),
          @Lc_Space_TEXT                  CHAR(1) = '',
          @Ls_FileName_TEXT               VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_FileSource_TEXT             VARCHAR(130),
          @Ls_SqlStmnt_TEXT               VARCHAR(200),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_Start_DATE                  DATETIME2,
          @Ld_LastRun_DATE                DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = 'CREATE TEMP TABLE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   CREATE TABLE #LoadEiwoResult_P1
    (
      LineData_TEXT VARCHAR (2406)
    );

   -- Selecting Date Run, Date Last Run, Commit Freq, Exception Threshold details
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_TEXT OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   -- Validation 1:Check Whether the Job ran already on same day
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD (D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   --Assign the Source File Location
   SET @Ls_FileSource_TEXT = LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_TEXT));

   IF @Ls_FileSource_TEXT = @Lc_Space_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
     SET @Ls_Sqldata_TEXT = 'LAST Run_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
     SET @Ls_DescriptionError_TEXT = 'FILE LOCATION AND NAMES ARE NOT EXIST IN THE PARAMETER TABLE TO LOAD';

     RAISERROR (50001,16,1);
    END;

   -- Temp Load Table Preparations
   SET @Ls_Sql_TEXT = 'BULK INSERT INTO LOAD TABLE';
   SET @Ls_Sqldata_TEXT = '';
   SET @Ls_SqlStmnt_TEXT = 'BULK INSERT #LoadEiwoResult_P1 FROM  ''' + @Ls_FileSource_TEXT + '''';

   EXEC (@Ls_SqlStmnt_TEXT);

   SET @Ls_Sql_TEXT = 'BEGIN THE TRASACTION';
   SET @Ls_Sqldata_TEXT = '';

   --Transaction begins
   BEGIN TRANSACTION EiwoResultTran;

   SET @Ls_Sql_TEXT = 'CHECK FOR EMPTY INPUT FILE';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ln_RecordCount_NUMB = COUNT (1)
     FROM #LoadEiwoResult_P1 l;

   IF @Ln_RecordCount_NUMB != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT - TRAILER COUNT';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_TrailerRecordCount_NUMB = SUM(CAST((SUBSTRING (l.LineData_TEXT, 31, 5)) AS NUMERIC))
       FROM #LoadEiwoResult_P1 l
      WHERE SUBSTRING (l.LineData_TEXT, 1, 3) = @Lc_BatchTrailerRecord_TEXT;

     SET @Ls_Sql_TEXT = 'SELECT - TOTAL DETAILS COUNT';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_RecordCount_NUMB = COUNT (1)
       FROM #LoadEiwoResult_P1 l
      WHERE SUBSTRING (l.LineData_TEXT, 1, 3) NOT IN (@Lc_FileHeaderRecord_TEXT, @Lc_FileTrailerRecord_TEXT, @Lc_BatchHeaderRecord_TEXT, @Lc_BatchTrailerRecord_TEXT);

     SET @Ls_Sql_TEXT = 'CHECK FOR THE TOTAL RECORD COUNT AND RECORDS IN TRIALER';
     SET @Ls_Sqldata_TEXT = '';

     IF @Ln_RecordCount_NUMB != @Ln_TrailerRecordCount_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'NO. OF RECORDS IN BATCHES DOESNT MATCH WITH SUM OF DETAIL RECORDS' + '.DETAIL RECORD COUNT = ' + CAST (@Ln_RecordCount_NUMB AS VARCHAR) + '.TRAILER RECORD COUNT = ' + CAST (@Ln_TrailerRecordCount_NUMB AS VARCHAR);

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'Check FILE HEADER RECORD';
     SET @Ls_Sqldata_TEXT = '';

     IF NOT EXISTS (SELECT 1
                      FROM #LoadEiwoResult_P1
                     WHERE SUBSTRING (LineData_TEXT, 1, 3) = @Lc_FileHeaderRecord_TEXT)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'FILE HEADER RECORD NOT FOUND';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'Check FILE TRAILER RECORD';
     SET @Ls_Sqldata_TEXT = '';

     IF NOT EXISTS (SELECT 1
                      FROM #LoadEiwoResult_P1
                     WHERE SUBSTRING (LineData_TEXT, 1, 3) = @Lc_FileTrailerRecord_TEXT)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'FILE TRAILER RECORD NOT FOUND';

       RAISERROR(50001,16,1);
      END

     --Validation :Check for Record Count is same as Batch Records in Trailer.   
     SET @Ls_Sql_TEXT = 'Check for Record Count is same as Batch Records in header.';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_BatchHeaderCount_NUMB = COUNT(1)
       FROM #LoadEiwoResult_P1 l
      WHERE SUBSTRING(l.LineData_TEXT, 1, 3) = @Lc_BatchHeaderRecord_TEXT;

     SET @Ls_Sql_TEXT = 'Check for Record Count is same as Batch Records in Trailer.';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Ln_BatchTrailerCount_NUMB = COUNT(1)
       FROM #LoadEiwoResult_P1 l
      WHERE SUBSTRING(l.LineData_TEXT, 1, 3) = @Lc_BatchTrailerRecord_TEXT;

     SET @Ls_Sql_TEXT = 'Check BATCH HEADER AND TRAILERS ARE NOT EQUAL';
     SET @Ls_Sqldata_TEXT = '';

     IF @Ln_BatchHeaderCount_NUMB != @Ln_BatchTrailerCount_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH HEADER AND TRAILERS ARE NOT EQUAL';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'DELETE LERES_Y1';
     SET @Ls_Sqldata_TEXT = '';

     DELETE LERES_Y1
      WHERE Process_INDC = @Lc_Yes_INDC;

     SET @Ls_Sql_TEXT = 'INSERT INTO LERES_Y1';
     SET @Ls_Sqldata_TEXT = 'FileLoad_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Process_INDC = ' + ISNULL(@Lc_Process_INDC, '');

     INSERT LERES_Y1
            (DocumentAction_CODE,
             Document_DATE,
             NameIssuingState_NAME,
             IssuingJurisdiction_NAME,
             Case_IDNO,
             Employer_NAME,
             Line1Employer_ADDR,
             Line2Employer_ADDR,
             EmployerCity_ADDR,
             EmployerState_ADDR,
             EmployerZip_ADDR,
             Fein_IDNO,
             LastNcp_NAME,
             FirstNcp_NAME,
             MiddleNcp_NAME,
             SuffixNcp_NAME,
             NcpSsn_NUMB,
             BirthNcp_DATE,
             LastCp_NAME,
             FirstCp_NAME,
             MiddleCp_NAME,
             SuffixCp_NAME,
             IssuingTribunal_NAME,
             CurCs_AMNT,
             FreqCs_CODE,
             PaybackCs_AMNT,
             FreqPaybackCs_CODE,
             CurMs_AMNT,
             FreqMs_CODE,
             PaybackMs_AMNT,
             FreqPaybackMs_CODE,
             CurSs_AMNT,
             FreqSs_CODE,
             PaybackSs_AMNT,
             FreqPaybackSs_CODE,
             CurOt_AMNT,
             FreqOt_CODE,
             DescriptionReasonOt_TEXT,
             CurTotal_AMNT,
             FreqTotal_CODE,
             Arr12wkDue_INDC,
             WithheldWeekly_AMNT,
             WithheldBiweekly_AMNT,
             WithheldMonthly_AMNT,
             WithheldSemimonthly_AMNT,
             NameSendingState_NAME,
             DaysBeginWithhold_NUMB,
             IwoStart_DATE,
             DaysBeginPayment_NUMB,
             CcpaPercent_NUMB,
             Payee_NAME,
             Line1Payee_ADDR,
             Line2Payee_ADDR,
             CityPayee_ADDR,
             StatePayee_ADDR,
             ZipPayee_ADDR,
             FipsRemittance_CODE,
             NameStateOfficial_NAME,
             TitleStateOfficial_NAME,
             CopyEmployee_INDC,
             DescriptionPenaltyLiability_TEXT,
             DescriptionAntiDescrimination_TEXT,
             DescriptionWithholdLimitPayee_TEXT,
             EmployeeContact_NAME,
             PhoneEmployeeContact_NUMB,
             FaxEmployeeContact_NUMB,
             AddrEmployeeContact_TEXT,
             DocTrackNo_TEXT,
             Order_IDNO,
             EmployerContact_NAME,
             Line1EmployerContact_ADDR,
             Line2EmployerContact_ADDR,
             CityEmployerContact_ADDR,
             StateEmployerContact_ADDR,
             ZipEmployerContact_ADDR,
             PhoneEmployerContact_NUMB,
             FaxEmployerContact_NUMB,
             EmployerContact_ADDR,
             LastChild1_NAME,
             FirstChild1_NAME,
             MiddleChild1_NAME,
             SuffixChild1_NAME,
             BirthChild1_DATE,
             LastChild2_NAME,
             FirstChild2_NAME,
             MiddleChild2_NAME,
             SuffixChild2_NAME,
             BirthChild2_DATE,
             LastChild3_NAME,
             FirstChild3_NAME,
             MiddleChild3_NAME,
             SuffixChild3_NAME,
             BirthChild3_DATE,
             LastChild4_NAME,
             FirstChild4_NAME,
             MiddleChild4_NAME,
             SuffixChild4_NAME,
             BirthChild4_DATE,
             LastChild5_NAME,
             FirstChild5_NAME,
             MiddleChild5_NAME,
             SuffixChild5_NAME,
             BirthChild5_DATE,
             LastChild6_NAME,
             FirstChild6_NAME,
             MiddleChild6_NAME,
             SuffixChild6_NAME,
             BirthChild6_DATE,
             LumpSum_AMNT,
             Remittance_IDNO,
             FirstError_NAME,
             SecondError_NAME,
             MultipleError_CODE,
             ErrorFieldName_TEXT,
             FileLoad_DATE,
             Process_INDC)
     SELECT ISNULL (SUBSTRING(l.LineData_TEXT, 7, 3), @Lc_Space_TEXT) AS DocumentAction_CODE,-- Document Action Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 10, 8), @Lc_Space_TEXT) AS Document_DATE,-- Document Date
            ISNULL (SUBSTRING(l.LineData_TEXT, 18, 35), @Lc_Space_TEXT) AS NameIssuingState_NAME,-- Issuing State
            ISNULL (SUBSTRING(l.LineData_TEXT, 53, 35), @Lc_Space_TEXT) AS IssuingJurisdiction_NAME,-- Issuing Jurisdiction Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 88, 15), @Lc_Space_TEXT) AS Case_IDNO,-- Case_IDNO
            ISNULL (SUBSTRING(l.LineData_TEXT, 103, 57), @Lc_Space_TEXT) AS Employer_NAME,-- Employer Name,
            ISNULL (SUBSTRING(l.LineData_TEXT, 160, 25), @Lc_Space_TEXT) AS Line1Employer_ADDR,-- Employer Line1 Address
            ISNULL (SUBSTRING(l.LineData_TEXT, 185, 25), @Lc_Space_TEXT) AS Line2Employer_ADDR,-- Employer Line2 Address
            ISNULL (SUBSTRING(l.LineData_TEXT, 210, 22), @Lc_Space_TEXT) AS EmployerCity_ADDR,-- Employer City Address
            ISNULL (SUBSTRING(l.LineData_TEXT, 232, 2), @Lc_Space_TEXT) AS EmployerState_ADDR,-- Employer State Address
            ISNULL (SUBSTRING(l.LineData_TEXT, 234, 9), @Lc_Space_TEXT) AS EmployerZip_ADDR,-- Employer Zipcode1 and Ext Zipcode
            ISNULL (SUBSTRING(l.LineData_TEXT, 243, 9), @Lc_Space_TEXT) AS Fein_IDNO,-- Fein idno
            ISNULL (SUBSTRING(l.LineData_TEXT, 252, 20), @Lc_Space_TEXT) AS LastNcp_NAME,-- Ncp Last  Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 272, 15), @Lc_Space_TEXT) AS FirstNcp_NAME,-- Ncp First Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 287, 15), @Lc_Space_TEXT) AS MiddleNcp_NAME,-- Ncp Middle Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 302, 4), @Lc_Space_TEXT) AS SuffixNcp_NAME,-- Ncp Suffix Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 306, 9), @Lc_Space_TEXT) AS NcpSsn_NUMB,-- Ncp Member SSN
            ISNULL (SUBSTRING(l.LineData_TEXT, 315, 8), @Lc_Space_TEXT) AS BirthNcp_DATE,-- Ncp Date of Birth
            ISNULL (SUBSTRING(l.LineData_TEXT, 323, 57), @Lc_Space_TEXT) AS LastCp_NAME,-- Cp Last Name,
            ISNULL (SUBSTRING(l.LineData_TEXT, 380, 15), @Lc_Space_TEXT) AS FirstCp_NAME,-- Cp First Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 395, 15), @Lc_Space_TEXT) AS MiddleCp_NAME,-- Cp Middle Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 410, 4), @Lc_Space_TEXT) AS SuffixCp_NAME,-- Cp Suffix Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 414, 35), @Lc_Space_TEXT) AS IssuingTribunal_NAME,-- Issuing Tribunal Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 449, 11), @Lc_Space_TEXT) AS CurCs_AMNT,-- Cur Cs Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 460, 1), @Lc_Space_TEXT) AS FreqCs_CODE,-- Cs Freq Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 461, 11), @Lc_Space_TEXT) AS PaybackCs_AMNT,-- Payback Cs Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 472, 1), @Lc_Space_TEXT) AS FreqPaybackCs_CODE,-- Payback Cs Freq Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 473, 11), @Lc_Space_TEXT) AS CurMs_AMNT,-- Cur Ms Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 484, 1), @Lc_Space_TEXT) AS FreqMs_CODE,-- Ms Freq Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 485, 11), @Lc_Space_TEXT) AS PaybackMs_AMNT,-- Payback Cs Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 496, 1), @Lc_Space_TEXT) AS FreqPaybackMs_CODE,-- Payback Ms Freq Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 497, 11), @Lc_Space_TEXT) AS CurSs_AMNT,-- Cur SS Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 508, 1), @Lc_Space_TEXT) AS FreqSs_CODE,-- SS Freq Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 509, 11), @Lc_Space_TEXT) AS PaybackSs_AMNT,-- Payback SS Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 520, 1), @Lc_Space_TEXT) AS FreqPaybackSs_CODE,-- Payback SS Freq Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 521, 11), @Lc_Space_TEXT) AS CurOt_AMNT,-- Cur OT Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 532, 1), @Lc_Space_TEXT) AS FreqOt_CODE,-- OT Freq Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 533, 35), @Lc_Space_TEXT) AS DescriptionReasonOt_TEXT,-- OT Reason Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 568, 11), @Lc_Space_TEXT) AS CurTotal_AMNT,-- Total Cur Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 579, 1), @Lc_Space_TEXT) AS FreqTotal_CODE,-- Total Freq Code
            ISNULL (SUBSTRING(l.LineData_TEXT, 580, 1), @Lc_Space_TEXT) AS Arr12wkDue_INDC,-- Arrears 12wk Overdue Code 
            ISNULL (SUBSTRING(l.LineData_TEXT, 581, 11), @Lc_Space_TEXT) AS WithheldWeekly_AMNT,-- Weekly Withheld Amnt
            ISNULL (SUBSTRING(l.LineData_TEXT, 592, 11), @Lc_Space_TEXT) AS WithheldBiweekly_AMNT,-- Biweekly Withheld Amnt 
            ISNULL (SUBSTRING(l.LineData_TEXT, 603, 11), @Lc_Space_TEXT) AS WithheldMonthly_AMNT,-- Semi Monthly Withheld Amnt 
            ISNULL (SUBSTRING(l.LineData_TEXT, 614, 11), @Lc_Space_TEXT) AS WithheldSemimonthly_AMNT,-- Monthly  Withheld Amnt 
            ISNULL (SUBSTRING(l.LineData_TEXT, 625, 35), @Lc_Space_TEXT) AS NameSendingState_NAME,-- State Tribe Territory Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 660, 2), @Lc_Space_TEXT) AS DaysBeginWithhold_NUMB,-- No of Days Begin Withhold
            ISNULL (SUBSTRING(l.LineData_TEXT, 662, 8), @Lc_Space_TEXT) AS IwoStart_DATE,-- Iwo Start Date,
            ISNULL (SUBSTRING(l.LineData_TEXT, 670, 2), @Lc_Space_TEXT) AS DaysBeginPayment_NUMB,-- No of days Begin Payment
            ISNULL (SUBSTRING(l.LineData_TEXT, 672, 2), @Lc_Space_TEXT) AS CcpaPercent_NUMB,-- No_Ccpa_Percent
            ISNULL (SUBSTRING(l.LineData_TEXT, 674, 57), @Lc_Space_TEXT) AS Payee_NAME,-- Payee Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 731, 25), @Lc_Space_TEXT) AS Line1Payee_ADDR,-- Payee Line1 Address
            ISNULL (SUBSTRING(l.LineData_TEXT, 756, 25), @Lc_Space_TEXT) AS Line2Payee_ADDR,-- Payee Line2 Address
            ISNULL (SUBSTRING(l.LineData_TEXT, 781, 22), @Lc_Space_TEXT) AS CityPayee_ADDR,-- Payee City Address
            ISNULL (SUBSTRING(l.LineData_TEXT, 803, 2), @Lc_Space_TEXT) AS StatePayee_ADDR,-- Payee State Address,
            ISNULL (SUBSTRING(l.LineData_TEXT, 805, 9), @Lc_Space_TEXT) AS ZipPayee_ADDR,-- Payee zip code and ext zip code
            ISNULL (SUBSTRING(l.LineData_TEXT, 814, 7), @Lc_Space_TEXT) AS FipsRemittance_CODE,-- Fips Remittance code
            ISNULL (SUBSTRING(l.LineData_TEXT, 821, 70), @Lc_Space_TEXT) AS NameStateOfficial_NAME,-- State Official name
            ISNULL (SUBSTRING(l.LineData_TEXT, 891, 50), @Lc_Space_TEXT) AS TitleStateOfficial_NAME,-- State Official Title  
            ISNULL (SUBSTRING(l.LineData_TEXT, 942, 1), @Lc_Space_TEXT) AS CopyEmployee_INDC,-- Send Employee Copy Indicator 
            ISNULL (SUBSTRING(l.LineData_TEXT, 943, 160), @Lc_Space_TEXT) AS DescriptionPenaltyLiability_TEXT,-- Penalty Liability Info Text 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1103, 160), @Lc_Space_TEXT) AS DescriptionAntiDescrimination_TEXT,-- Anti discrimination Provisions Text
            ISNULL (SUBSTRING(l.LineData_TEXT, 1263, 160), @Lc_Space_TEXT) AS DescriptionWithholdLimitPayee_TEXT,-- Specific Payee Withholding Limits
            ISNULL (SUBSTRING(l.LineData_TEXT, 1423, 57), @Lc_Space_TEXT) AS EmployeeContact_NAME,-- Employee State Contact Name
            ISNULL (SUBSTRING(l.LineData_TEXT, 1480, 10), @Lc_Space_TEXT) AS PhoneEmployeeContact_NUMB,-- Employee State Contact Phone Number
            ISNULL (SUBSTRING(l.LineData_TEXT, 1490, 10), @Lc_Space_TEXT) AS FaxEmployeeContact_NUMB,-- Employee State Contact Fax Number
            ISNULL (SUBSTRING(l.LineData_TEXT, 1500, 48), @Lc_Space_TEXT) AS AddrEmployeeContact_TEXT,-- Employee State Contact Email Address 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1548, 30), @Lc_Space_TEXT) AS DocTrackNo_TEXT,-- Document Tracking Number 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1578, 30), @Lc_Space_TEXT) AS Order_IDNO,-- Order Identifier  
            ISNULL (SUBSTRING(l.LineData_TEXT, 1608, 57), @Lc_Space_TEXT) AS EmployerContact_NAME,-- Employer State Contact Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1665, 25), @Lc_Space_TEXT) AS Line1EmployerContact_ADDR,-- Employer State Contact Address Line 1 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1690, 25), @Lc_Space_TEXT) AS Line2EmployerContact_ADDR,-- Employer State Contact Address Line 2 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1715, 22), @Lc_Space_TEXT) AS CityEmployerContact_ADDR,-- Employer State Contact Address City Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1737, 2), @Lc_Space_TEXT) AS StateEmployerContact_ADDR,-- Employer State Contact Address State Code 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1739, 9), @Lc_Space_TEXT) AS ZipEmployerContact_ADDR,-- Employer State Contact Address ZIP Code and Ext Zip
            ISNULL (SUBSTRING(l.LineData_TEXT, 1748, 10), @Lc_Space_TEXT) AS PhoneEmployerContact_NUMB,-- Employer State Contact Phone Number 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1758, 10), @Lc_Space_TEXT) AS FaxEmployerContact_NUMB,-- Employer State Contact Fax Number 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1768, 48), @Lc_Space_TEXT) AS EmployerContact_ADDR,-- Employer State Contact Email Address Text 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1816, 20), @Lc_Space_TEXT) AS LastChild1_NAME,-- Child 1 Last Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1836, 15), @Lc_Space_TEXT) AS FirstChild1_NAME,-- Child 1 First Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1851, 15), @Lc_Space_TEXT) AS MiddleChild1_NAME,-- Child 1 Middle Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1866, 4), @Lc_Space_TEXT) AS SuffixChild1_NAME,-- Child 1 Suffix Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1870, 8), @Lc_Space_TEXT) AS BirthChild1_DATE,-- Child 1 Birth Date 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1878, 20), @Lc_Space_TEXT) AS LastChild2_NAME,-- Child 2 Last Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1898, 15), @Lc_Space_TEXT) AS FirstChild2_NAME,-- Child 2 First Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1913, 15), @Lc_Space_TEXT) AS MiddleChild2_NAME,-- Child 2 Middle Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1928, 4), @Lc_Space_TEXT) AS SuffixChild2_NAME,-- Child 2 Suffix Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1932, 8), @Lc_Space_TEXT) AS BirthChild2_DATE,-- Child 2 Birth Date 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1940, 20), @Lc_Space_TEXT) AS LastChild3_NAME,-- Child 3 Last Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1960, 15), @Lc_Space_TEXT) AS FirstChild3_NAME,-- Child 3 First Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1975, 15), @Lc_Space_TEXT) AS MiddleChild3_NAME,-- Child 3 Middle Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1990, 4), @Lc_Space_TEXT) AS SuffixChild3_NAME,-- Child 3 Suffix Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 1994, 8), @Lc_Space_TEXT) AS BirthChild3_DATE,-- Child 3 Birth Date 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2002, 20), @Lc_Space_TEXT) AS LastChild4_NAME,-- Child 4 Last Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2022, 15), @Lc_Space_TEXT) AS FirstChild4_NAME,-- Child 4 First Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2037, 15), @Lc_Space_TEXT) AS MiddleChild4_NAME,-- Child 4 Middle Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2052, 4), @Lc_Space_TEXT) AS SuffixChild4_NAME,-- Child 4 Suffix Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2056, 8), @Lc_Space_TEXT) AS BirthChild4_DATE,-- Child 4 Birth Date 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2064, 20), @Lc_Space_TEXT) AS LastChild5_NAME,-- Child 5 Last Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2084, 15), @Lc_Space_TEXT) AS FirstChild5_NAME,-- Child 5 First Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2099, 15), @Lc_Space_TEXT) AS MiddleChild5_NAME,-- Child 5 Middle Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2114, 4), @Lc_Space_TEXT) AS SuffixChild5_NAME,-- Child 5 Suffix Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2118, 8), @Lc_Space_TEXT) AS BirthChild5_DATE,-- Child 5 Birth Date 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2126, 20), @Lc_Space_TEXT) AS LastChild6_NAME,-- Child 6 Last Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2146, 15), @Lc_Space_TEXT) AS FirstChild6_NAME,-- Child 6 First Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2161, 15), @Lc_Space_TEXT) AS MiddleChild6_NAME,-- Child 6 Middle Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2176, 4), @Lc_Space_TEXT) AS SuffixChild6_NAME,-- Child 6 Suffix Name  
            ISNULL (SUBSTRING(l.LineData_TEXT, 2180, 8), @Lc_Space_TEXT) AS BirthChild6_DATE,-- Child 6 Birth Date 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2188, 11), @Lc_Space_TEXT) AS LumpSum_AMNT,-- Lump Sum Payment Amount 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2208, 20), @Lc_Space_TEXT) AS Remittance_IDNO,-- Remittance Identifier 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2253, 32), @Lc_Space_TEXT) AS FirstError_NAME,-- First Error Field Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2285, 32), @Lc_Space_TEXT) AS SecondError_NAME,-- Second Error Field Name 
            ISNULL (SUBSTRING(l.LineData_TEXT, 2317, 1), @Lc_Space_TEXT) AS MultipleError_CODE,-- Multiple Error Indicator
            ISNULL (SUBSTRING(h.LineData_TEXT, 63, 80), @Lc_Space_TEXT) AS ErrorFieldName_TEXT,--Error Field Name
            @Ld_Run_DATE AS FileLoad_DATE,-- File Load Date
            @Lc_Process_INDC AS Process_INDC -- Process Indicator
       FROM #LoadEiwoResult_P1 l
            LEFT OUTER JOIN #LoadEiwoResult_P1 h
             ON SUBSTRING(h.LineData_TEXT, 1, 3) IN (@Lc_BatchHeaderRecord_TEXT)
                AND CAST(ISNULL (SUBSTRING(l.LineData_TEXT, 243, 9), 0) AS NUMERIC) = CAST(ISNULL (SUBSTRING(h.LineData_TEXT, 31, 9), 0) AS NUMERIC)
      WHERE SUBSTRING(l.LineData_TEXT, 1, 3) NOT IN (@Lc_FileHeaderRecord_TEXT, @Lc_FileTrailerRecord_TEXT, @Lc_BatchHeaderRecord_TEXT, @Lc_BatchTrailerRecord_TEXT);

     SET @Ln_ProcessedRecordCount_QNTY = @@ROWCOUNT;
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'NO RECORDS TO UPDATE';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Sql_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Ls_Sql_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the Status of job in BSTL_Y1 as Success	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLocation_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   DROP TABLE #LoadEiwoResult_P1;

   COMMIT TRANSACTION EiwoResultTran;
  END TRY

  BEGIN CATCH
   --Rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EiwoResultTran;
    END

   --Drop temporary table if exists
   IF OBJECT_ID('tempdb..#LoadEiwoResult_P1') IS NOT NULL
    BEGIN
     DROP TABLE #LoadEiwoResult_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   -- Retrieve and log the Error Description.
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
