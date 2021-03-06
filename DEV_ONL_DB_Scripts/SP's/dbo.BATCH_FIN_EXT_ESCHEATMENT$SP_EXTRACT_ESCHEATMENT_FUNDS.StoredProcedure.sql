/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_ESCHEATMENT$SP_EXTRACT_ESCHEATMENT_FUNDS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_EXT_ESCHEATMENT$SP_EXTRACT_ESCHEATMENT_FUNDS
Programmer Name 	: IMP Team
Description			: The purpose of this process is to send a file with the escheated
					  funds to treasury.
					  Batch program will run on last business day prior to 10th April of every year
Frequency			: 'ANNUALLY' 
Developed On		: 01/27/2012
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_ESCHEATMENT$SP_EXTRACT_ESCHEATMENT_FUNDS]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE            CHAR (1) = 'S',
           @Lc_Space_TEXT                    CHAR (1) = ' ',
           @Lc_StatusFailed_CODE             CHAR (1) = 'F',
           @Lc_StatusAbnormalend_CODE        CHAR (1) = 'A',
           @Lc_HolderTr_CODE                 CHAR (1) = '1',
           @Lc_HolderReportType_CODE         CHAR (1) = 'R',
           @Lc_HolderReportFormat_TEXT       CHAR (1) = 'R',
           @Lc_OwnerTr_CODE                  CHAR (1) = '2',
           @Lc_PropOwnerType_CODE            CHAR (1) = 'P',
           @Lc_SummaryTr9_CODE               CHAR (1) = '9',
           @Lc_Filler_TEXT                   CHAR (1) = ' ',
           @Lc_TypeOthpO_CODE				 CHAR (1) = 'O',
           @Lc_TypeOthp3_CODE				 CHAR (1) = '3',
           @Lc_Zero_TEXT					 CHAR (1) = '0',
           @Lc_PropInterestFlag_INDC		 CHAR (1) = 'N',
           @Lc_HolderIncorporatedState_CODE  CHAR (2) = 'DE',
           @Lc_PropDeductionType_CODE        CHAR (2) = 'ZZ',
           @Lc_PropAdditionType_CODE         CHAR (2) = 'ZZ',
           @Lc_PropRelationshipSo_CODE		 CHAR (2) = 'SO',
		   @Lc_PropOwnerTypeOt_CODE			 CHAR (2) = 'OT',
		   @Lc_PropOwnerTypeAg_CODE			 CHAR (2) = 'AG',
		   @Lc_HolderRptNumber_TEXT			 CHAR (2) = '01',
		   @Lc_HolderTaxidExt_TEXT           CHAR (4) = '0001',
           @Lc_PropPropertyType_CODE         CHAR (4) = 'CT04',
           @Lc_BateErrorE1424_CODE			 CHAR (5) = 'E1424',
           @Lc_Job_ID                        CHAR (7) = 'DEB8610',
           @Lc_CheckRecipient999999983_ID	 CHAR (9) = '999999983',
           @Lc_Aggregate_TEXT				 CHAR (9) = 'AGGREGATE',
           @Lc_Successful_TEXT               CHAR (20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT             CHAR (30) = 'BATCH',
           @Ls_Sql_TEXT                      VARCHAR (100) = ' ',
           @Ls_Process_NAME                  VARCHAR (100) = 'BATCH_FIN_EXT_ESCHEATMENT',
           @Ls_Procedure_NAME                VARCHAR (100) = 'SP_EXTRACT_ESCHEATMENT_FUNDS',
           @Ls_CursorLoc_TEXT                VARCHAR (200) = ' ',
           @Ls_Sqldata_TEXT                  VARCHAR (1000) = ' ',
           @Ld_High_DATE                     DATE = '12/31/9999',
           @Ld_Low_DATE						 DATE = '01/01/0001';
  DECLARE  @Ln_CommitFreqParm_QNTY               NUMERIC (5),
           @Ln_ExceptionThresholdParm_QNTY       NUMERIC (5),
           @Ln_Rowcount_NUMB                 NUMERIC (7),
           @Ln_MemberSsn_NUMB                NUMERIC (9),
           @Ln_Holder_Fein_IDNO				 NUMERIC (9),
           @Ln_MemberMci_IDNO                NUMERIC (10),
           @Ln_FetchStatus_QNTY              NUMERIC (10),
           @Ln_Error_NUMB                    NUMERIC (10),
           @Ln_ErrorLine_NUMB                NUMERIC (10),
           @Ln_Cursor_QNTY                   NUMERIC (11) = 0,
           @Ln_EscheatedOwner_AMNT           NUMERIC (11,2) = 0,
           @Ln_DisburseReport_AMNT			 NUMERIC (11,2) = 0,
           @Ln_Holder_QNTY                   NUMERIC (11) = 0,
           @Ln_Owner_QNTY                    NUMERIC (11) = 0,
           @Ln_ProcessedRecordCount_QNTY	 NUMERIC (11) = 0,
           @Ln_Phone_NUMB                    NUMERIC (15),
           @Ln_Holder_Fax_NUMB				 NUMERIC(15),   
           @Lc_PropOwnerTypeOtAg_CODE		 CHAR (2),   
           @Lc_State_ADDR                    CHAR (2),
           @Lc_Country_ADDR                  CHAR (2),
           @Lc_Holder_State_ADDR			 CHAR (2),
           @Lc_Msg_CODE                      CHAR (3),
           @Lc_Suffix_NAME                   CHAR (4),
           @Lc_BateError_CODE                CHAR (5),
           @Lc_Title_NAME                    CHAR (8),
           @Lc_Zip_ADDR                      CHAR (15),
           @Lc_First_NAME                    CHAR (16),
           @Lc_Last_NAME                     CHAR (20),
           @Lc_Middle_NAME                   CHAR (20),
           @Lc_City_ADDR                     CHAR (28),
           @Lc_Holder_City_ADDR				 CHAR (28),
           @Ls_File_NAME                     VARCHAR (50),
           @Ls_Line1_ADDR                    VARCHAR (50),
           @Ls_Line2_ADDR                    VARCHAR (50),
           @Ls_Line3_ADDR                    VARCHAR (50),
           @Ls_Holder_OtherParty_NAME		 VARCHAR (60),
           @Ls_FileLocation_TEXT             VARCHAR (80),
           @Ls_CursorLocation_TEXT           VARCHAR (200) = '',
           @Ls_HolderRecord_TEXT             VARCHAR (625) = '',
           @Ls_OwnerRecord_TEXT              VARCHAR (625),
           @Ls_SummaryRecord_TEXT            VARCHAR (625) = '',
           @Ls_BcpCommand_TEXT               VARCHAR (1000),
           @Ls_DescriptionError_TEXT         VARCHAR (3000),
           @Ls_ErrorMessage_TEXT			 VARCHAR (4000),
           @Ld_Birth_DATE                    DATE,
           @Ld_LastRun_DATE                  DATE,
           @Ld_Run_DATE                      DATE,
           @Ld_Start_DATE                    DATETIME2;
   DECLARE @Ln_OwnerCur_PayorMCI_IDNO		 NUMERIC(10),
           @Ln_OwnerCur_Disburse_AMNT		 NUMERIC(11, 2);
  BEGIN TRY
  
   -- Drop temporary table if exists
   IF OBJECT_ID('tempdb..##ExtEscheat_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtEscheat_P1;
    END
    
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
   
   /*
   	Get the run date and last run date from PARM_Y1 (Parameters table) and validate that the 
   	batch program was not executed for the run date, by ensuring that the run date is different 
   	from the last run date in the PARM table.  Otherwise, an error message to that effect will 
   	be written into Batch Status Log (BSTL) screen / Batch Status Log (BSTL_Y1) table and 
   	terminate the process.
   */
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
   
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';
     RAISERROR(50001,16,1);
    END

   BEGIN TRANSACTION ExtractEscheatement;
   --Delete the records from the temporary tables EEHOL_Y1 and EEOWN_Y1.
   SET @Ls_Sql_TEXT = 'DELETE EEOWN_Y1';
   SET @Ls_Sqldata_TEXT = '';
   DELETE FROM EEOWN_Y1;

   SET @Ls_Sql_TEXT = 'DELETE EEHOL_Y1';
   SET @Ls_Sqldata_TEXT = '';
   DELETE FROM EEHOL_Y1;

   SET @Ls_Sql_TEXT ='CREATE TEMPORARY TABLE ##ExtEscheat_P1';
   SET @Ls_Sqldata_TEXT = '';
   CREATE TABLE ##ExtEscheat_P1
    (
      Record_TEXT VARCHAR(625)
    );
    
	 /*
		Get the company details (Name of the company, Address of the Company, FEIN, Standard Industrial Classification code 
		and date on which the company was incorporated) and Contact persons' name and address from OTHP_Y1 by matching the 
		TypeOthp_CODE = 'B - ESCHEATMENT AGENCY' State of Delaware, Delaware State Escheator, 
		Unclaimed Property Division, P.O. Box 8931, Wilmington DE 19801 (OTHP ID is yet to be determined) 
		and move the data to the temporary table EEHOL_Y1.  
    */
    
      SET @Ls_Sql_TEXT = 'INSERT EEHOL_Y1';
      SET @Ls_Sqldata_TEXT = 'TypeOthp_CODE = ' + @Lc_TypeOthpO_CODE + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');
      INSERT INTO EEHOL_Y1
             (Fein_IDNO,
              OtherParty_NAME,
              City_ADDR,
              State_ADDR,
              Fax_NUMB)
      SELECT a.Fein_IDNO,
            SUBSTRING(a.OtherParty_NAME,1,25) AS OtherParty_NAME, 
            a.City_ADDR,
            a.State_ADDR,
            SUBSTRING(CAST(LEFT((LTRIM(RTRIM(ISNULL(a.Fax_NUMB, '0'))) + REPLICATE('0', 15)), 15) AS CHAR(15)),4,7) AS Fax_NUMB
       FROM OTHP_Y1 a
      WHERE a.TypeOthp_CODE = @Lc_TypeOthpO_CODE
        AND a.OtherParty_IDNO = @Lc_CheckRecipient999999983_ID
        AND a.EndValidity_DATE = @Ld_High_DATE;
        
      SET @Ln_Rowcount_NUMB = @@ROWCOUNT;

      IF @Ln_Rowcount_NUMB = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT EEHOL_Y1 FAILED ';
        RAISERROR(50001,16,1);
       END
     
     SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
     SET @Ls_Sqldata_TEXT = 'TypeOthp_CODE = ' + @Lc_TypeOthpO_CODE + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');  
	 SELECT @Ln_Holder_Fein_IDNO = a.Fein_IDNO,
            @Ls_Holder_OtherParty_NAME = a.OtherParty_NAME,
            @Lc_Holder_City_ADDR = a.City_ADDR,
            @Lc_Holder_State_ADDR = a.State_ADDR,
            @Ln_Holder_Fax_NUMB = SUBSTRING(CAST(LEFT((LTRIM(RTRIM(ISNULL(a.Fax_NUMB, '0'))) + REPLICATE('0', 15)), 15) AS CHAR(15)),4,7)
       FROM OTHP_Y1 a
      WHERE a.TypeOthp_CODE = @Lc_TypeOthpO_CODE
        AND a.OtherParty_IDNO = @Lc_CheckRecipient999999983_ID
        AND a.EndValidity_DATE = @Ld_High_DATE;
        
      SET @Ln_Holder_QNTY = @Ln_Holder_QNTY + 1;
      SET @Ls_Sql_TEXT = 'WRITE HOLDER RECORD IN FILE ';
      SET @Ls_Sqldata_TEXT = 'HolderCount_QNTY = ' + ISNULL(CAST(@Ln_Holder_QNTY AS VARCHAR), '');
      SET @Ls_HolderRecord_TEXT = ISNULL(@Lc_HolderTr_CODE, 0)	-- TR-CODE
      + RIGHT((REPLICATE(@Lc_Zero_TEXT, 9) + LTRIM(RTRIM(@Ln_Holder_Fein_IDNO ))), 9)	-- HOLDER-TAX ID
      + @Lc_HolderTaxidExt_TEXT		-- HOLDER-TAXID-EXT
      + CONVERT(VARCHAR(4),@Ld_Run_DATE,112) -- HOLDER-RPT-YEAR
      + @Lc_HolderReportType_CODE   -- HOLDER-RPT-TYPE
      + @Lc_HolderRptNumber_TEXT    -- HOLDER-RPT-NUMBER
      + @Lc_HolderReportFormat_TEXT -- HOLDER-RPT-FORMAT
      + REPLICATE(@Lc_Zero_TEXT, 4) -- HOLDER-SIC-CODE
      + @Lc_HolderIncorporatedState_CODE -- HOLDER-INCORPORATED-STATE
      + REPLICATE(@Lc_Zero_TEXT, 4) -- HOLDER-INC-DATE-CCYY
      + REPLICATE(@Lc_Zero_TEXT, 2) -- HOLDER-INC-DATE-MM
      + REPLICATE(@Lc_Zero_TEXT, 2) -- HOLDER-INC-DATE-DD
      + CAST(LEFT((LTRIM(RTRIM('Delaware Child Support System')) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) -- HOLDER-NAME
      + CAST(LEFT((LTRIM(RTRIM('Newcastle')) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30))	-- HOLDER-CITY
      + CAST(LEFT((LTRIM(RTRIM('Newcastle')) + REPLICATE(@Lc_Space_TEXT, 20)), 20) AS CHAR(20))	-- HOLDER-COUNTY
      + @Lc_HolderIncorporatedState_CODE -- HOLDER-STATE
      + REPLICATE(@Lc_Filler_TEXT, 40) -- HOLDER-CONTACT1-NAME
      + REPLICATE(@Lc_Filler_TEXT, 30) -- HOLDER-CONTACT1-ADDR1
      + REPLICATE(@Lc_Filler_TEXT, 30) -- HOLDER-CONTACT1-ADDR2
      + REPLICATE(@Lc_Filler_TEXT, 30) -- HOLDER-CONTACT1-ADDR3
      + REPLICATE(@Lc_Filler_TEXT, 30) -- HOLDER-CONTACT1-CITY
      + REPLICATE(@Lc_Filler_TEXT, 2)  -- HOLDER-CONTACT1-STATE
      + REPLICATE(@Lc_Filler_TEXT, 9)  -- HOLDER-CONTACT1-ZIP
      + REPLICATE(@Lc_Filler_TEXT, 3)  -- HOLDER-CONTACT1-COUNTRY
      + REPLICATE(@Lc_Zero_TEXT, 3)	   -- HOLDER-CONTACT1-TEL-AC
      + REPLICATE(@Lc_Zero_TEXT, 7)	   -- HOLDER-CONTACT1-TEL-NBR
      + REPLICATE(@Lc_Zero_TEXT, 4)    -- HOLDER-CONTACT1-TELEXTENSION
      + REPLICATE(@Lc_Filler_TEXT, 50) -- HOLDER-CONTACT1-EMAIL
      + REPLICATE(@Lc_Filler_TEXT, 40) -- HOLDER-CONTACT2-NAME
      + REPLICATE(@Lc_Filler_TEXT, 30) -- HHOLDER-CONTACT2-ADDR1
      + REPLICATE(@Lc_Filler_TEXT, 30) -- HOLDER-CONTACT2-ADDR2
      + REPLICATE(@Lc_Filler_TEXT, 30) -- HOLDER-CONTACT2-ADDR3
      + REPLICATE(@Lc_Filler_TEXT, 30) -- HOLDER-CONTACT2-CITY
      + REPLICATE(@Lc_Filler_TEXT, 2)  -- HOLDER-CONTACT2-STATE
      + REPLICATE(@Lc_Zero_TEXT, 9)    -- HOLDER-CONTACT2-ZIP
      + REPLICATE(@Lc_Filler_TEXT, 3)  -- HOLDER-CONTACT2-COUNTRY
      + REPLICATE(@Lc_Zero_TEXT, 3)    -- HOLDER-CONTACT2-TEL-AC
      + REPLICATE(@Lc_Zero_TEXT, 7)    -- HOLDER-CONTACT2-TEL-NBR
      + REPLICATE(@Lc_Zero_TEXT, 4)    -- HOLDER-CONTACT2-TELEXTENSION
      + REPLICATE(@Lc_Filler_TEXT, 50) -- HOLDER-CONTACT2-EMAIL
      + REPLICATE(@Lc_Zero_TEXT, 3)    -- HOLDER-FAX-AC
      + CAST(LEFT((LTRIM(RTRIM(ISNULL(@Ln_Holder_Fax_NUMB, @Lc_Zero_TEXT))) + REPLICATE(@Lc_Zero_TEXT, 7)), 7) AS CHAR(7)) -- HOLDER-FAX-NBR
      + REPLICATE(@Lc_Zero_TEXT, 6)    -- HOLDER-NAICS-CODE 
      + REPLICATE(@Lc_Filler_TEXT, 5) ;  -- FILLER
      
      SET @Ls_Sql_TEXT = 'INSERT BATCH_HOLDER_RECORD INTO ##ExtEscheat_P1';
	  SET @Ls_Sqldata_TEXT = 'HolderRecord_TEXT = ' + @Ls_HolderRecord_TEXT;
      INSERT INTO ##ExtEscheat_P1 ( Record_TEXT )
           VALUES ( @Ls_HolderRecord_TEXT  -- Record_TEXT
				  );
  	  
   /*
		Get the escheated funds from the Disbursement Detail Log (DSBL_Y1) and Disbursement Header Log (DSBH_Y1) tables using the following conditions:
			From DSBL_Y1 and DSBH_Y1 tables:
			Calculate the sum of all disbursement amounts where Check-Recipient-Id is equal to 
			"999999983" for Delaware State Escheator  and Check Recipient Code equal to 3 - Other Party

		--	Get Owner Record for Identified Receipts
		Get the Payors MCI Number from Receipt (RCTH_Y1) table by matching the data in Disbursement Detail Log (DSBL_Y1) table:
			From RCTH_Y1 and DSBL_Y1 tables:	
				Payor ID is retrieved using the Receipt Number from DSBL_Y1 table
   */
   DECLARE 
   Owner_CUR INSENSITIVE CURSOR FOR
   SELECT y.PayorMCI_IDNO,
                   SUM(z.Disburse_AMNT)  Disburse_AMNT
      FROM (SELECT a.Batch_DATE,
                   a.Batch_NUMB,
                   a.SourceBatch_CODE,
                   a.SeqReceipt_NUMB,
                   SUM(a.Disburse_AMNT)  Disburse_AMNT
              FROM DSBL_Y1  a
             WHERE a.Disburse_DATE BETWEEN @Ld_LastRun_DATE AND @Ld_Run_DATE
             AND EXISTS (
                               SELECT 1
                                 FROM DSBH_Y1 b
                                WHERE b.CheckRecipient_ID = @Lc_CheckRecipient999999983_ID
                                  AND b.CheckRecipient_CODE = @Lc_TypeOthp3_CODE
                                  AND a.CheckRecipient_ID = b.CheckRecipient_ID
                                  AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                                  AND a.Disburse_DATE = b.Disburse_DATE
                                  AND a.DisburseSeq_NUMB = b.DisburseSeq_NUMB
                                  AND b.EndValidity_DATE = @Ld_High_DATE)
             GROUP BY a.Batch_DATE,
                      a.Batch_NUMB,
                      a.SourceBatch_CODE,
                      a.SeqReceipt_NUMB)  z,
           RCTH_Y1 y
     WHERE y.Batch_DATE = z.Batch_DATE
       AND y.SourceBatch_CODE = z.SourceBatch_CODE
       AND y.Batch_NUMB = z.Batch_NUMB
       AND y.SeqReceipt_NUMB = z.SeqReceipt_NUMB
       AND y.EventGlobalBeginSeq_NUMB = (SELECT MAX(x.EventGlobalBeginSeq_NUMB)
                                           FROM RCTH_Y1 x
                                          WHERE y.Batch_DATE = x.Batch_DATE
                                            AND y.SourceBatch_CODE = x.SourceBatch_CODE
                                            AND y.Batch_NUMB = x.Batch_NUMB
                                            AND y.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                            AND x.EndValidity_DATE = @Ld_High_DATE)
       AND y.EndValidity_DATE = @Ld_High_DATE
     GROUP BY y.PayorMCI_IDNO;
   
   OPEN Owner_CUR;

   FETCH NEXT FROM Owner_CUR INTO @Ln_OwnerCur_PayorMCI_IDNO, @Ln_OwnerCur_Disburse_AMNT;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Processing the owner records for Receipts that were on Disbursement Hold
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
     SET @Ls_CursorLoc_TEXT = 'PayorMCI_IDNO = ' + ISNULL(CAST(@Ln_OwnerCur_PayorMCI_IDNO AS VARCHAR), '') + ', Cursor_QNTY = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '');
     SET @Ln_MemberMci_IDNO = @Ln_OwnerCur_PayorMCI_IDNO;
     SET @Ls_Sql_TEXT = 'SELECT DATA FROM DEMO_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '');

     BEGIN
      /* Get the Name Last, Name First, Name Middle, Name Suffix, Name Title and DOB from DEMO_Y1 by 
      	joining the MCI Number field with the PayorMci_IDNO from RCTH_Y1. */
      SELECT @Lc_Last_NAME = d.Last_NAME,
             @Lc_First_NAME = d.First_NAME,
             @Lc_Middle_NAME = d.Middle_NAME,
             @Lc_Suffix_NAME = d.Suffix_NAME,
             @Lc_Title_NAME = d.Title_NAME,
             @Ld_Birth_DATE = d.Birth_DATE
        FROM DEMO_Y1 d
       WHERE d.MemberMci_IDNO = @Ln_MemberMci_IDNO;

      SET @Ln_Rowcount_NUMB = @@ROWCOUNT;

      IF @Ln_Rowcount_NUMB = 0
       BEGIN
        SET @Lc_Last_NAME = @Lc_Space_TEXT;
        SET @Lc_First_NAME = @Lc_Space_TEXT;
        SET @Lc_Middle_NAME = @Lc_Space_TEXT;
        SET @Lc_Suffix_NAME = @Lc_Space_TEXT;
        SET @Lc_Title_NAME = @Lc_Space_TEXT;
        SET @Ld_Birth_DATE = @Ld_Low_DATE;
        SET @Ls_Line1_ADDR = @Lc_Space_TEXT;
        SET @Ls_Line2_ADDR = @Lc_Space_TEXT;
        SET @Ls_Line3_ADDR = @Lc_Space_TEXT;
        SET @Lc_City_ADDR = @Lc_Space_TEXT;
        SET @Lc_State_ADDR = @Lc_Space_TEXT;
        SET @Lc_Zip_ADDR = @Lc_Space_TEXT;
        SET @Lc_Country_ADDR = @Lc_Space_TEXT;
        SET @Ln_Phone_NUMB = 0;
       END

      /*
      	Get the verified SSN of the Payor from MSSN_Y1 table, if there is no verified primary found, 
      	get unverified primary SSN from MSSN_Y1. 
      	If there is no un-verified primary found, get verified ITIN from MSSN_Y1.
      */
      SET @Ls_Sql_TEXT = 'Select Verified MemberSsn_NUMB ';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '');
      SET @Ln_MemberSsn_NUMB = dbo.BATCH_COMMON$SF_GET_VERIFIED_SSN_ITIN (@Ln_MemberMci_IDNO);

      IF @Ln_MemberSsn_NUMB = 0
       BEGIN
        SET @Ln_MemberSsn_NUMB = 0;
       END

      /*
		  Get Payor address from AHIS_Y1 table using the common 
		  routine which uses the address hierarchy
      */
      SET @Ls_Sql_TEXT = 'PROCEDURE Call - BATCH_COMMON$SP_GET_ADDRESS 1';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '');
      
      EXECUTE BATCH_COMMON$SP_GET_ADDRESS 
       @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
       @Ad_Run_DATE              = @Ld_Run_DATE,
       @As_Line1_ADDR            = @Ls_Line1_ADDR OUTPUT,
       @As_Line2_ADDR            = @Ls_Line2_ADDR OUTPUT,
       @Ac_City_ADDR             = @Lc_City_ADDR OUTPUT,
       @Ac_State_ADDR            = @Lc_State_ADDR OUTPUT,
       @Ac_Zip_ADDR              = @Lc_Zip_ADDR OUTPUT,
       @Ac_Country_ADDR          = @Lc_Country_ADDR OUTPUT,
       @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        RAISERROR(50001,16,1);
       END
	  SET @Ls_Line3_ADDR = @Lc_Space_TEXT;
	  SET @Lc_PropOwnerTypeOtAg_CODE = @Lc_PropOwnerTypeOT_CODE;
	  IF @Ln_MemberMci_IDNO = 0
		BEGIN
			SET @Lc_Last_NAME = @Lc_Aggregate_TEXT;
			SET @Lc_PropOwnerTypeOtAg_CODE = @Lc_PropOwnerTypeAg_CODE;
		END	
	  /*
       Move the escheated funds data retrieved (Sum of Disburse_AMNT from DSBL_Y1 table derived in above step) 
       to the temporary table EEOWN_Y1
       */	
      SET @Ls_Sql_TEXT = 'INSERT EEOWN_Y1 ';
      SET @Ls_Sqldata_TEXT = 'Last_NAME = ' + ISNULL(@Lc_Last_NAME, @Lc_Space_TEXT) + ', First_NAME = ' + ISNULL(@Lc_First_NAME, @Lc_Space_TEXT) + ', Middle_NAME = ' +  ISNULL(SUBSTRING(@Lc_Middle_NAME, 1, 10), @Lc_Space_TEXT) + ', Suffix_NAME = ' + ISNULL(@Lc_Suffix_NAME, @Lc_Space_TEXT) + ', Title_NAME = ' + ISNULL(SUBSTRING(@Lc_Title_NAME, 1, 6), @Lc_Space_TEXT) + ', Birth_DATE = ' + ISNULL(REPLACE(CONVERT (VARCHAR(10),@Ld_Birth_DATE, 101), '/',''), @Lc_Space_TEXT) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@Ln_MemberSsn_NUMB AS VARCHAR), @Lc_Space_TEXT) + ', Escheated_AMNT = ' + CAST((@Ln_OwnerCur_Disburse_AMNT * 100) AS VARCHAR) + ', Line1_ADDR = ' + ISNULL(SUBSTRING(@Ls_Line1_ADDR, 1, 30), @Lc_Space_TEXT) + ', Line2_ADDR = ' + ISNULL(SUBSTRING(@Ls_Line2_ADDR, 1, 30), @Lc_Space_TEXT) + ', Line3_ADDR = ' + ISNULL(SUBSTRING(@Ls_Line3_ADDR, 1, 30), @Lc_Space_TEXT) + ', City_ADDR = ' + ISNULL(@Lc_City_ADDR, @Lc_Space_TEXT) + ', State_ADDR = ' + ISNULL(@Lc_State_ADDR, @Lc_Space_TEXT) + ', Zip_ADDR = ' + ISNULL(SUBSTRING(@Lc_Zip_ADDR, 1, 9), @Lc_Space_TEXT) + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, @Lc_Space_TEXT);
      INSERT EEOWN_Y1
              (Last_NAME,
               First_NAME,
               Middle_NAME,
               Suffix_NAME,
               Title_NAME,
               Birth_DATE,
               MemberSsn_NUMB,
               Escheated_AMNT,
               Line1_ADDR,
               Line2_ADDR,
               Line3_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               Country_ADDR)
       VALUES ( ISNULL(@Lc_Last_NAME, @Lc_Space_TEXT),--Last_NAME
                ISNULL(@Lc_First_NAME, @Lc_Space_TEXT),--First_NAME
                ISNULL(SUBSTRING(@Lc_Middle_NAME, 1, 10), @Lc_Space_TEXT),--Middle_NAME
                ISNULL(@Lc_Suffix_NAME, @Lc_Space_TEXT),--Suffix_NAME
                ISNULL(SUBSTRING(@Lc_Title_NAME, 1, 6), @Lc_Space_TEXT),--Title_NAME
                ISNULL(REPLACE(CONVERT (VARCHAR(10),@Ld_Birth_DATE, 101), '/','') , @Lc_Space_TEXT),--Birth_DATE
                ISNULL(CAST(@Ln_MemberSsn_NUMB AS VARCHAR), @Lc_Space_TEXT),--MemberSsn_NUMB
                RIGHT( REPLICATE(@Lc_Zero_TEXT, 10) + CONVERT(VARCHAR(20), CAST(ROUND(ISNULL(@Ln_OwnerCur_Disburse_AMNT, 0), 2) * 100 AS BIGINT)), 10),--Escheated_AMNT
                ISNULL(SUBSTRING(@Ls_Line1_ADDR, 1, 30), @Lc_Space_TEXT),--Line1_ADDR
                ISNULL(SUBSTRING(@Ls_Line2_ADDR, 1, 30), @Lc_Space_TEXT),--Line2_ADDR
                ISNULL(SUBSTRING(@Ls_Line3_ADDR, 1, 30), @Lc_Space_TEXT),--Line3_ADDR
                ISNULL(@Lc_City_ADDR, @Lc_Space_TEXT),--City_ADDR
                ISNULL(@Lc_State_ADDR, @Lc_Space_TEXT),--State_ADDR
                ISNULL(SUBSTRING(@Lc_Zip_ADDR, 1, 9), @Lc_Space_TEXT),--Zip_ADDR
                ISNULL(@Lc_Country_ADDR, @Lc_Space_TEXT)--Country_ADDR
                );

       SET @Ln_Rowcount_NUMB = @@ROWCOUNT;

       IF @Ln_Rowcount_NUMB = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT EEOWN_Y1 FAILED 1';
         RAISERROR(50001,16,1);
        END

       SET @Ln_EscheatedOwner_AMNT = @Ln_EscheatedOwner_AMNT + @Ln_OwnerCur_Disburse_AMNT;
       SET @Ln_Holder_QNTY = @Ln_Holder_QNTY + 1;
       SET @Ln_Owner_QNTY = @Ln_Owner_QNTY + 1;
       SET @Ls_OwnerRecord_TEXT = NULL;
       SET @Ls_Sql_TEXT = 'WRITE OWNER RECORD ';
       SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), '');
       SET @Ls_OwnerRecord_TEXT = @Lc_OwnerTr_CODE -- TR-CODE
       + ISNULL(RIGHT( REPLICATE(@Lc_Zero_TEXT, 6) + CONVERT(VARCHAR(20), @Ln_Owner_QNTY), 6), '') -- PROP-SEQUENCE-NUMBER
       + @Lc_PropOwnerType_CODE -- PROP-OWNER-TYPE
       + @Lc_Space_TEXT -- PROP-NAME-ID
       + CAST(LEFT((LTRIM(RTRIM(@Lc_Last_NAME)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) -- PROP-OWNER-NAME-LAST
       + CAST(LEFT((LTRIM(RTRIM(@Lc_First_NAME)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) -- PROP-OWNER-NAME-FIRST
       + CAST(LEFT((LTRIM(RTRIM(@Lc_Middle_NAME)) + REPLICATE(@Lc_Space_TEXT, 10)), 10) AS CHAR(10)) -- PROP- OWNER-NAMEMIDDLE
       + CAST(LEFT((LTRIM(RTRIM(@Lc_Filler_TEXT)) + REPLICATE(@Lc_Space_TEXT, 10)), 10) AS CHAR(10)) -- PROP- OWNER-NAMEPREFIX
       + CAST(LEFT((LTRIM(RTRIM(@Lc_Suffix_NAME)) + REPLICATE(@Lc_Space_TEXT, 10)), 10) AS CHAR(10)) -- PROP- OWNER-NAMESUFFIX
       + CAST(LEFT((LTRIM(RTRIM(@Lc_Title_NAME)) + REPLICATE(@Lc_Space_TEXT, 6)), 6) AS CHAR(6)) -- PROP- OWNER-NAME-TITLE
       + CAST(LEFT((LTRIM(RTRIM(@Ls_Line1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) -- PROP- OWNER-ADDRESS1
       + CAST(LEFT((LTRIM(RTRIM(@Ls_Line2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) -- PROP- OWNER-ADDRESS2
       + CAST(LEFT((LTRIM(RTRIM(@Ls_Line3_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) -- PROP- OWNER-ADDRESS3
       + CAST(LEFT((LTRIM(RTRIM(@Lc_City_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) -- PROP- OWNER-CITY
       + CAST(LEFT((LTRIM(RTRIM(@Lc_Filler_TEXT)) + REPLICATE(@Lc_Space_TEXT, 20)), 20) AS CHAR(20)) -- PROP- OWNER-COUNTY
       + CAST(LEFT((LTRIM(RTRIM(ISNULL(@Lc_State_ADDR, @Lc_Space_TEXT))) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) --PROP- OWNER-STATE
       + CAST(LEFT((LTRIM(RTRIM(ISNULL(@Lc_Zip_ADDR, @Lc_Space_TEXT))) + REPLICATE(@Lc_Space_TEXT, 9)), 9) AS CHAR(9)) -- PROP- OWNER-ZIP
       + CAST(LEFT((LTRIM(RTRIM(ISNULL(@Lc_Country_ADDR, @Lc_Space_TEXT))) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3)) -- PROP- OWNER-COUNTRY
       + CAST(LEFT((LTRIM(RTRIM(ISNULL(CAST(@Ln_MemberSsn_NUMB AS VARCHAR), '0'))) + REPLICATE('0', 9)), 9) AS CHAR(9)) -- PROP- OWNER-TAXID
       + REPLICATE(@Lc_Filler_TEXT, 2) -- PROP- OWNER-TAXID-EXT 
       + RIGHT( REPLICATE(@Lc_Zero_TEXT, 4) + CONVERT(VARCHAR(4),@Ld_Birth_DATE,112), 4) -- PROP- OWNER-DOB-CCYY
       + RIGHT( REPLICATE(@Lc_Zero_TEXT, 2) + SUBSTRING(CONVERT(VARCHAR(8),@Ld_Birth_DATE,112),5,2), 2) -- PROP- OWNER-DOB-MM 
       + RIGHT( REPLICATE(@Lc_Zero_TEXT, 2) + SUBSTRING(CONVERT(VARCHAR(8),@Ld_Birth_DATE,112),7,2), 2) -- PROP- OWNER-DOB-DD
       + REPLICATE(@Lc_Zero_TEXT, 4) -- PROP-ST-TRANS-DATECCYY
       + REPLICATE(@Lc_Zero_TEXT, 2) -- PROP- ST-TRANS-DATE-MM
       + REPLICATE(@Lc_Zero_TEXT, 2) -- PROP- ST-TRANS-DATE-DD
       + REPLICATE(@Lc_Zero_TEXT, 4) -- PROP-EN-TRANS-DATECCYY
       + REPLICATE(@Lc_Zero_TEXT, 2) -- PROP-EN-TRANS-DATE-MM
       + REPLICATE(@Lc_Zero_TEXT, 2) -- PROP-EN-TRANS-DATE-DD
       + @Lc_PropPropertyType_CODE -- PROP-PROPERTY-TYPE
       + RIGHT( REPLICATE(@Lc_Zero_TEXT, 10) + CONVERT(VARCHAR(20), CAST(ROUND(ISNULL(@Ln_OwnerCur_Disburse_AMNT, 0), 2) * 100 AS BIGINT)), 10) -- PROP-AMOUNT-REPORTED
       + @Lc_PropDeductionType_CODE -- PROP-DEDUCTION-TYPE
       + REPLICATE(@Lc_Zero_TEXT, 10) -- PROP-DEDUCTION-AMOUNT
       + REPLICATE(@Lc_Zero_TEXT, 10) -- PROP-AMOUNT-ADVERTISED
       + @Lc_PropAdditionType_CODE -- PROP-ADDITION-TYPE
       + REPLICATE(@Lc_Zero_TEXT, 10) -- PROP-ADDITION-AMOUNT
       + @Lc_PropAdditionType_CODE -- PROP-DELETION TYPE
       + REPLICATE(@Lc_Zero_TEXT, 10) -- PROP-DELETION-AMOUNT
       + RIGHT( REPLICATE(@Lc_Zero_TEXT, 10) + CONVERT(VARCHAR(20), CAST(ROUND(ISNULL(@Ln_OwnerCur_Disburse_AMNT, 0), 2) * 100 AS BIGINT)), 10) -- PROP-AMOUNT-REMITTED
       + @Lc_PropInterestFlag_INDC -- PROP-INTEREST-FLAG
       + REPLICATE(@Lc_Zero_TEXT, 7) -- PROP-INTEREST-RATE
       + REPLICATE(@Lc_Filler_TEXT, 25) -- PROP-STOCK-ISSUE-NAME
       + REPLICATE(@Lc_Filler_TEXT, 9) -- PROP-STOCK-CUSIP
       + REPLICATE(@Lc_Zero_TEXT, 12) -- PROP-NUMBER-OF-SHARES
       + REPLICATE(@Lc_Zero_TEXT, 12) -- PROP-ADD-SHARES
       + REPLICATE(@Lc_Zero_TEXT, 12) -- PROP-DEL-SHARES
       + REPLICATE(@Lc_Zero_TEXT, 12) -- PROP-REM-SHARES
       + REPLICATE(@Lc_Filler_TEXT, 25) -- PROP-NEXCHANGEDISSUE-NAME
       + REPLICATE(@Lc_Filler_TEXT, 9) -- PROP-UNEXCHANGED-USIP
       + REPLICATE(@Lc_Zero_TEXT, 12)  --PROP-UNEXCHANGEDSHARES
       + REPLICATE(@Lc_Filler_TEXT, 20)-- PROP-ACCT-NUMBER
       + REPLICATE(@Lc_Filler_TEXT, 20)-- PROP-CHECK-NUMBER
       + REPLICATE(@Lc_Filler_TEXT, 50)-- PROP-DESCRIPTION
       + @Lc_PropRelationshipSo_CODE -- PROP-RELATIONSHIP-CODE
       + @Lc_PropOwnerTypeOtAg_CODE -- PROP-OWNER-TYPE-CODE
       + REPLICATE(@Lc_Filler_TEXT, 21) ; -- FILLER
       SET @Ls_Sql_TEXT = 'INSERT BATCH_OWNER_RECORD INTO ##ExtEscheat_P1';
	   SET @Ls_Sqldata_TEXT = 'Record_TEXT = ' + @Ls_OwnerRecord_TEXT;	
	   
       INSERT INTO ##ExtEscheat_P1 ( Record_TEXT )
            VALUES ( @Ls_OwnerRecord_TEXT -- Record_TEXT
					);
     END
	 
     FETCH NEXT FROM Owner_CUR INTO @Ln_OwnerCur_PayorMCI_IDNO, @Ln_OwnerCur_Disburse_AMNT;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Owner_CUR;

   DEALLOCATE Owner_CUR;
   
   /*
   	Create summary records using the data from the temporary tables EEHOL_Y1 and EEOWN_Y1.
		Calculate total number of owner records in EEOWN_Y1 table. 
		Calculate total number of records (Holder + Owner + Summary)
		Calculate the sum of Escheated_AMNT (amount reported) in EEOWN_Y1 table

   */	
   IF @Ln_Owner_QNTY > 0 
    BEGIN
     SET @Ln_Holder_QNTY = @Ln_Holder_QNTY + 1;
     SET @Ls_SummaryRecord_TEXT = ISNULL(@Lc_SummaryTr9_CODE, '') -- TR-CODE
     + RIGHT((REPLICATE(@Lc_Zero_TEXT, 6) + LTRIM(RTRIM(@Ln_Holder_QNTY))), 6)	-- SUMM-NBR-OFRECORDS
     + RIGHT((REPLICATE(@Lc_Zero_TEXT, 6) + LTRIM(RTRIM(@Ln_Owner_QNTY))), 6) -- SUMM-NBR-OF-PROPERTIES
     + RIGHT( REPLICATE(@Lc_Zero_TEXT, 12) + CONVERT(VARCHAR(20), CAST(ROUND(ISNULL(@Ln_EscheatedOwner_AMNT, 0), 2) * 100 AS BIGINT)), 12) -- SUMM-AMOUNT-REPORTED
     + RIGHT( REPLICATE(@Lc_Zero_TEXT, 12) + CONVERT(VARCHAR(20), CAST(ROUND(ISNULL(@Ln_DisburseReport_AMNT, 0), 2) * 100 AS BIGINT)), 12) -- SUMM-DEDUCTION-AMOUNT
     + RIGHT( REPLICATE(@Lc_Zero_TEXT, 12) + CONVERT(VARCHAR(20), CAST(ROUND(ISNULL(@Ln_DisburseReport_AMNT, 0), 2) * 100 AS BIGINT)), 12) -- SUMM-AMOUNT-ADVERTISED
     + REPLICATE(@Lc_Zero_TEXT, 12)	-- SUMM-ADDITION-AMOUNT
     + REPLICATE(@Lc_Zero_TEXT, 12)	-- SUMM-DELETION-AMOUNT
     + RIGHT( REPLICATE(@Lc_Zero_TEXT, 12) + CONVERT(VARCHAR(20), CAST(ROUND(ISNULL(@Ln_EscheatedOwner_AMNT, 0), 2) * 100 AS BIGINT)), 12)	-- SUMM-AMOUNT-REMITTED
     + REPLICATE(@Lc_Zero_TEXT, 14)	-- SUMM-NBR-OF-SHARES
     + REPLICATE(@Lc_Zero_TEXT, 14)	-- SUMM-SHARES-ADD
     + REPLICATE(@Lc_Zero_TEXT, 14)	-- SUMM-SHARES-DEL
     + REPLICATE(@Lc_Zero_TEXT, 14)	-- SUMM-SHARES-REMITTED
     + CONVERT (CHAR(1), @Lc_Space_TEXT) -- SUMM-NEGATIVE-REPORT
     + CONVERT (CHAR(20), @Lc_Space_TEXT) -- SUMM-SOFTWARE-VERSION
     + CONVERT (CHAR(20), @Lc_Space_TEXT) -- SUMM-CREATOR
     + CONVERT (CHAR(70), @Lc_Space_TEXT) -- SUMM-CREATOR-CONTACT
     + CONVERT (CHAR(373), @Lc_Space_TEXT); -- FILLER
     
     SET @Ls_Sql_TEXT = 'INSERT BATCH_OWNER_RECORD SUMMARY INTO ##ExtEscheat_P1';
     SET @Ls_Sqldata_TEXT = 'SummaryRecord_TEXT = ' + @Ls_SummaryRecord_TEXT;
     INSERT INTO ##ExtEscheat_P1 ( Record_TEXT )
          VALUES ( @Ls_SummaryRecord_TEXT -- Record_TEXT
          );
    END
   
   COMMIT TRANSACTION ExtractEscheatement;
   
   SET @Ls_BcpCommand_TEXT = 'SELECT Record_TEXT FROM ##ExtEscheat_P1 ORDER BY 1 ASC';
   
   SET @Ls_Sql_TEXT='BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT +', File_NAME = ' + @Ls_File_NAME + ', Query_TEXT = ' + @Ls_BcpCommand_TEXT;
   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_BcpCommand_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
   
   SET @Ln_ProcessedRecordCount_QNTY =  @Ln_Holder_QNTY ;
  
   -- Update the parameter table with the job run date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the Status of job in BSTL_Y1 as Success	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLocation_TEXT = ' + @Ls_CursorLocation_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ListKey_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   --Drop temperoray Table
   SET @Ls_Sql_TEXT = 'DROP ##ExtEscheat_P1 TABLE';
   SET @Ls_Sqldata_TEXT = '';
   DROP TABLE ##ExtEscheat_P1;
  END TRY

  BEGIN CATCH
   --Drop temporary table if exists
   IF OBJECT_ID('tempdb..##ExtEscheat_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtEscheat_P1;
    END

   --Commit the Transaction 		
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ExtractEscheatement;
    END
   
   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS ('LOCAL', 'Owner_CUR') IN (0, 1)
    BEGIN
     CLOSE Owner_CUR;
     DEALLOCATE Owner_CUR;
    END;
    
    IF CURSOR_STATUS ('LOCAL', 'OwnerDisb_CUR') IN (0, 1)
    BEGIN
     CLOSE OwnerDisb_CUR;
     DEALLOCATE OwnerDisb_CUR;
    END;
   	
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

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLocation_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
