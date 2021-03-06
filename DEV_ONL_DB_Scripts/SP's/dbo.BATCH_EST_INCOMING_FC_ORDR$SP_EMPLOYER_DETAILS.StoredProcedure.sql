/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_ORDR$SP_EMPLOYER_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_EST_INCOMING_FC_ORDR$SP_EMPLOYER_DETAILS

Programmer Name		 : IMP Team

Description			 : The procedure BATCH_EST_INCOMING_FC_ORDR$SP_EMPLOYER_DETAILS deletes all the processed 
					   records from the intermediate table, reads the petition response type records 'EMPL' from the 
					   intermediate table and the employer OTHP ID provided will be added to the member's EHIS record,
					   if the OTHP ID does not exist already on EHIS for the member. The process indicator
					   will be updated to 'Y' for each processed record in the intermediate table.   																				  
								
	
Frequency			 : Daily

Developed On		 : 05/02/2011

Called By			 : None

Called on			 : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION,
					   BATCH_COMMON$SP_EMPLOYER_UPDATE
					   
---------------------------------------------------------------------------------------------------------------------------------					   
Modified By			 : 

Modified On			 :

Version No			 : 1.0
---------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_ORDR$SP_EMPLOYER_DETAILS]
 @Ac_Job_ID                CHAR(7),
 @Ad_Run_DATE              DATE,
 @As_Process_NAME          VARCHAR(100),
 @An_Process_QNTY          NUMERIC(5) OUTPUT,
 @An_Exception_QNTY        NUMERIC(5) OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  -- Common Variables
  DECLARE  @Lc_StatusFailed_CODE				CHAR(1) = 'F',
           @Lc_Yes_INDC							CHAR(1) = 'Y',
           @Lc_ErrorTypeError_CODE				CHAR(1) = 'E',
           @Lc_CaseStatusOpen_CODE				CHAR(1) = 'O',
           @Lc_MsgE1_CODE						CHAR(1) = 'E',
           @Lc_StatusSuccess_CODE				CHAR(1) = 'S',
           @Lc_SourceVerifiedT_CODE             CHAR(1) = 'T',
           @Lc_TypeOthpE_CODE                   CHAR(1) = 'E',
           @Lc_IncomeTypeEm_CODE				CHAR(2) = 'EM',
           @Lc_SourceLocateCot_CODE				CHAR(3) = 'COT',
           @Lc_ErrorE0145_CODE					CHAR(5) = 'E0145',
           @Lc_ErrorE0540_CODE                  CHAR(5) = 'E0540',
           @Lc_ErrorE0640_CODE					CHAR(5) = 'E0640',
           @Lc_ErrorE1094_CODE					CHAR(5) = 'E1094',
           @Lc_ErrorE1380_CODE					CHAR(5) = 'E1380',
           @Lc_ErrorE1381_CODE					CHAR(5) = 'E1381',
           @Lc_ErrorE0009_CODE					CHAR(5) = 'E0009',
           @Lc_ErrorE0907_CODE					CHAR(5) = 'E0907',
           @Lc_BatchFamis_TEXT					CHAR(8) = 'FAMIS',
           @Lc_ProcessFcOrdr_ID					CHAR(8) = 'FC_ORDER',
           @Ls_Procedure_NAME					VARCHAR(100) = 'SP_EMPLOYER_DETAILS',
           @Ld_High_DATE						DATE = '12/31/9999',
           @Ld_Low_DATE							DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB						NUMERIC(1) = 0,
		   @Ln_Exists_NUMB						NUMERIC(1) = 0,
           @Ln_Zero_AMNT						NUMERIC(1) = 0,
           @Ln_CommitFreq_QNTY					NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY			NUMERIC(5) = 0,
           @Ln_Cur_QNTY							NUMERIC(10,0) = 0,
           @Ln_Error_NUMB						NUMERIC(11),
           @Ln_ErrorLine_NUMB					NUMERIC(11),
           @Li_FetchStatus_QNTY					SMALLINT, 
           @Li_RowCount_QNTY					SMALLINT,
           @Lc_Space_TEXT						CHAR(1) = '',
           @Lc_TypeError_CODE					CHAR(1) = ' ',
           @Lc_Msg_CODE							CHAR(5),
           @Lc_Error_CODE						CHAR(5) = ' ',
           @Ls_Sql_TEXT							VARCHAR(100) = '',
           @Ls_CursorLoc_TEXT					VARCHAR(200) = ' ',
           @Ls_Sqldata_TEXT						VARCHAR(1000) = '',
           @Ls_Record_TEXT						VARCHAR(3200) = '',
           @Ls_DescriptionError_TEXT			VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT				VARCHAR(4000) = '',
           @Ld_Start_DATE						DATETIME2;
  -- Cursor variable declaration 
  DECLARE @Ln_FcEmplDetCur_Seq_IDNO              NUMERIC(19),
          @Lc_FcEmplDetCur_Rec_ID                CHAR(4),
          @Lc_FcEmplDetCur_PetitionIdno_TEXT     CHAR(7),
          @Lc_FcEmplDetCur_PetitionSequenceIdno_TEXT CHAR(2),
          @Lc_FcEmplDetCur_CaseIdno_TEXT         CHAR(6),
          @Lc_FcEmplDetCur_PetitionType_CODE     CHAR(4),
          @Lc_FcEmplDetCur_PetitionAction_DATE   CHAR(8),
          @Lc_FcEmplDetCur_FamilyCourtFile_ID    CHAR(10),
          @Lc_FcEmplDetCur_MemberMciIdno_TEXT    CHAR(10),
          @Lc_FcEmplDetCur_EmployerOthpIdno_TEXT CHAR(9),
          @Lc_FcEmplDetCur_EmployerEinIdno_TEXT  CHAR(9),
          
          @Ln_FcEmplDetCur_Case_IDNO             NUMERIC(6),
          @Ln_FcEmplDetCur_Petition_IDNO         NUMERIC(7),
          @Ln_FcEmplDetCur_MemberMci_IDNO        NUMERIC(10),
          @Ln_FcEmplDetCur_EmployerOthp_IDNO     NUMERIC(9);
  -- Cursor declaration for the employer details from the temporary table 
  DECLARE FcEmplDet_Cur INSENSITIVE CURSOR FOR
   SELECT b.Seq_IDNO,
          b.Rec_ID,
          b.Petition_IDNO,
          b.PetitionSequence_IDNO,
          b.Case_IDNO,
          b.PetitionType_CODE,
          b.PetitionAction_DATE,
          b.FamilyCourtFile_ID,
          b.MemberMci_IDNO,
          b.EmployerOthp_IDNO,
          b.EmployerEin_IDNO
     FROM LFEMP_Y1 b
    WHERE b.Process_INDC = 'N'
    ORDER BY Seq_IDNO;

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
    SET @Ln_Cur_QNTY = @Ln_Zero_NUMB;
   SET @Ls_Sql_TEXT = 'OPENING FAMILY COURT EMPLOYER DETAILS CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Ac_Job_ID;

   OPEN FcEmplDet_Cur;

   SET @Ls_Sql_TEXT = 'FETCHING FAMILY COURT EMPLOYER DETAILS CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Ac_Job_ID;

   FETCH NEXT FROM FcEmplDet_Cur INTO @Ln_FcEmplDetCur_Seq_IDNO, @Lc_FcEmplDetCur_Rec_ID, @Lc_FcEmplDetCur_PetitionIdno_TEXT, @Lc_FcEmplDetCur_PetitionSequenceIdno_TEXT, @Lc_FcEmplDetCur_CaseIdno_TEXT, @Lc_FcEmplDetCur_PetitionType_CODE, @Lc_FcEmplDetCur_PetitionAction_DATE, @Lc_FcEmplDetCur_FamilyCourtFile_ID, @Lc_FcEmplDetCur_MemberMciIdno_TEXT, @Lc_FcEmplDetCur_EmployerOthpIdno_TEXT, @Lc_FcEmplDetCur_EmployerEinIdno_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Process all the employer records from the load table LFEMP_Y1
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1; 
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     SET @Lc_Error_CODE     = @Lc_Space_TEXT;
     IF ISNUMERIC(@Lc_FcEmplDetCur_PetitionIdno_TEXT) = 1
      BEGIN
       SET @Ln_FcEmplDetCur_Petition_IDNO = @Lc_FcEmplDetCur_PetitionIdno_TEXT;
      END
     ELSE
	  BEGIN		
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_Error_CODE = @Lc_ErrorE1380_CODE;

       GOTO lx_exception;
      END

     IF ISNUMERIC(@Lc_FcEmplDetCur_CaseIdno_TEXT) <> 1
      
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_Error_CODE = @Lc_ErrorE1381_CODE;

       GOTO lx_exception;
      END
     ELSE
      BEGIN
       SET @Ln_FcEmplDetCur_Case_IDNO = @Lc_FcEmplDetCur_CaseIdno_TEXT;
       SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
         FROM CASE_Y1 a
        WHERE Case_IDNO = @Ln_FcEmplDetCur_Case_IDNO
          AND StatusCase_CODE = @Lc_CaseStatusOpen_CODE; 
       
       IF @Ln_Exists_NUMB = @Ln_Zero_NUMB
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_Error_CODE = @Lc_ErrorE1381_CODE;

         GOTO lx_exception;
        END
      END

     IF ISNUMERIC (@Lc_FcEmplDetCur_MemberMciIdno_TEXT) = 1
      BEGIN
		SET @Ln_FcEmplDetCur_MemberMci_IDNO = @Lc_FcEmplDetCur_MemberMciIdno_TEXT;
	  END
	 ELSE 
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_Error_CODE = @Lc_ErrorE0009_CODE;

       GOTO lx_exception;
      END

	 IF ISNUMERIC (@Lc_FcEmplDetCur_EmployerOthpIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcEmplDetCur_EmployerOthp_IDNO = @Lc_FcEmplDetCur_EmployerOthpIdno_TEXT;
		END
	 ELSE
		BEGIN
			SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
			SET @Lc_Error_CODE = @Lc_ErrorE0540_CODE;
			GOTO lx_exception;
		END
		
     -- Check the received member exists in DEMO_Y1, If not exists move the record to BATE_Y1 table with error code E0907
     SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
       FROM DEMO_Y1 d
       WHERE d.MemberMci_IDNO = @Ln_FcEmplDetCur_MemberMci_IDNO;
     IF @Ln_Exists_NUMB = @Ln_Zero_NUMB
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_Error_CODE = @Lc_ErrorE0907_CODE;

         GOTO lx_exception;
        END
     -- Check the othp id received from the court exists in DECSS OTHP_Y1, If not exists move the record to BATE_Y1 with error code e0540
     SET @Ls_Sql_TEXT = 'READING OTHP_Y1 TABLE ';
     SET @Ls_SqlData_TEXT = 'MemberMci_IDNO = ' + @Lc_FcEmplDetCur_MemberMciIdno_TEXT + ', EmployerOthp_IDNO = ' + CAST(@Ln_FcEmplDetCur_EmployerOthp_IDNO AS VARCHAR);
     SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
       FROM OTHP_Y1 O 
       WHERE o.OtherParty_IDNO = @Ln_FcEmplDetCur_EmployerOthp_IDNO
         AND o.TypeOthp_CODE   = @Lc_TypeOthpE_CODE
         AND O.Endvalidity_DATE = @Ld_High_DATE;
     IF @Ln_Exists_NUMB = @Ln_Zero_NUMB
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_Error_CODE = @Lc_ErrorE0540_CODE;

         GOTO lx_exception;
        END
       
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + @Lc_FcEmplDetCur_MemberMciIdno_TEXT + ', EmployerOthp_IDNO = ' + CAST(@Ln_FcEmplDetCur_EmployerOthp_IDNO AS VARCHAR);

     EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
      @An_MemberMci_IDNO             = @Ln_FcEmplDetCur_MemberMci_IDNO,
      @An_OthpPartyEmpl_IDNO         = @Ln_FcEmplDetCur_EmployerOthp_IDNO,
      @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
      @Ac_Status_CODE                = @Lc_Yes_INDC,
      @Ad_Status_DATE                = @Ad_Run_DATE,
      @Ac_TypeIncome_CODE            = @Lc_IncomeTypeEm_CODE,
      @Ac_SourceLocConf_CODE         = @Lc_SourceVerifiedT_CODE,
      @Ad_Run_DATE                   = @Ad_Run_DATE,
      @Ad_BeginEmployment_DATE       = @Ad_Run_DATE,
      @Ad_EndEmployment_DATE         = @Ld_High_DATE,
      @An_IncomeGross_AMNT           = @Ln_Zero_AMNT,
      @An_IncomeNet_AMNT             = @Ln_Zero_AMNT,
      @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
      @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
      @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
      @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
      @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
      @Ac_SourceLoc_CODE             = @Lc_SourceLocateCot_CODE,
      @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
      @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
      @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
      @Ad_EligCoverage_DATE          = @Ld_Low_DATE,
      @An_CostInsurance_AMNT         = @Ln_Zero_AMNT,
      @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
      @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
      @Ac_SignedOnWorker_ID          = @Lc_BatchFamis_TEXT,
      @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
      @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
      @Ac_Process_ID                 = @Lc_ProcessFcOrdr_ID,
      @An_OfficeSignedOn_IDNO        = @Ln_Zero_NUMB,
      @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;
     
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		 BEGIN
			
			RAISERROR (50001,16,1);
		 END
	   ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			   BEGIN
				SET @Lc_TypeError_CODE = dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE)
				IF  @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE
				  BEGIN 
					
					RAISERROR (50001,16,1);
				  END 
				ELSE
				  BEGIN
					
					SET @Lc_Error_CODE = @Lc_Msg_CODE;
				  END
			   END

     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F', 'I','W')
      BEGIN
              
       SET @Ls_Record_TEXT = 'Row_IDNO = ' + CAST(@Ln_FcEmplDetCur_Seq_IDNO AS VARCHAR) + ', Rec_ID = ' + ISNULL(@Lc_FcEmplDetCur_Rec_ID, '') + ', Petition_IDNO = ' + CAST(@Ln_FcEmplDetCur_Petition_IDNO AS VARCHAR) + ', PetitionSequence_IDNO = ' + ISNULL (@Lc_FcEmplDetCur_PetitionSequenceIdno_TEXT, ' ') + ', Case_IDNO = ' + ISNULL(@Lc_FcEmplDetCur_CaseIdno_TEXT, '') + ', PetitionType_CODE = ' + ISNULL (@Lc_FcEmplDetCur_PetitionType_CODE, '') + ', PetitionAction_DATE = ' + ISNULL (@Lc_FcEmplDetCur_PetitionAction_DATE, '') + ', FamilyCourtFile_IDNO = ' + ISNULL (@Lc_FcEmplDetCur_FamilyCourtFile_ID, '') + ', MemberMci_IDNO = ' + ISNULL (@Lc_FcEmplDetCur_MemberMciIdno_TEXT, '') + ', EmployerOthp_IDNO = ' + ISNULL (@Lc_FcEmplDetCur_EmployerOthpIdno_TEXT, '') + ', EmployerEin_ID = ' + ISNULL(@Lc_FcEmplDetCur_EmployerEinIdno_TEXT, '');
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + @Lc_FcEmplDetCur_MemberMciIdno_TEXT + ', EmployerOthp_IDNO = ' + CAST(@Ln_FcEmplDetCur_EmployerOthp_IDNO AS VARCHAR);

       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @As_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_Error_CODE,
        @As_DescriptionError_TEXT    = @Ls_Record_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT INTO BATE_Y1  FAILED FOR FC ORDER ';
         RAISERROR(50001,16,1);
        END
       
       IF @Lc_Msg_CODE =  @Lc_MsgE1_CODE
         BEGIN 
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END
      END

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_Sql_TEXT = 'UPDATING LFEMP_Y1 TABLE';
	 SET @Ls_Sqldata_TEXT = 'Sequence_IDNO = ' + CAST(@Ln_FcEmplDetCur_Seq_IDNO AS VARCHAR);
     UPDATE LFEMP_Y1
        SET Process_INDC = @Lc_Yes_INDC
      WHERE Seq_IDNO = @Ln_FcEmplDetCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LoadFcEmployerDetails_T1';
       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcEmplDet_Cur INTO @Ln_FcEmplDetCur_Seq_IDNO, @Lc_FcEmplDetCur_Rec_ID, @Lc_FcEmplDetCur_PetitionIdno_TEXT, @Lc_FcEmplDetCur_PetitionSequenceIdno_TEXT, @Lc_FcEmplDetCur_CaseIdno_TEXT, @Lc_FcEmplDetCur_PetitionType_CODE, @Lc_FcEmplDetCur_PetitionAction_DATE, @Lc_FcEmplDetCur_FamilyCourtFile_ID, @Lc_FcEmplDetCur_MemberMciIdno_TEXT, @Lc_FcEmplDetCur_EmployerOthpIdno_TEXT, @Lc_FcEmplDetCur_EmployerEinIdno_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcEmplDet_Cur;

   DEALLOCATE FcEmplDet_Cur;
   
   SET @An_Process_QNTY = @Ln_CommitFreq_QNTY;
   SET @An_Exception_QNTY = @Ln_ExceptionThreshold_QNTY;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcEmplDet_Cur') IN (0, 1)
    BEGIN
     CLOSE FcEmplDet_Cur;

     DEALLOCATE FcEmplDet_Cur;
    END
  
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT ; 
  END CATCH;
 END


GO
