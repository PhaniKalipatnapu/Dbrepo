/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_SVN_RECORDS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure  Name	     : BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_SVN_RECORDS
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_SVN_RECORDS processes the responses 
						'SVN' - Verified Notice of Income Attachment from the Family court interface.
					   
Frequency			 : Daily
Developed On		 : 04/02/2014
Called By			 : None
Called On			 : 
----------------------------------------------------------------------------------------------------------------------------------					   
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_SVN_RECORDS]
	@An_Case_IDNO							NUMERIC(6),
	@An_Petition_IDNO						NUMERIC(7),
	@Ac_PetitionActionDate_TEXT				CHAR(8),
	@Ac_FamilyCourtFile_ID					CHAR(10),
	@As_RecordTypeData_TEXT					VARCHAR(198),
	@Ac_PetitionDispType_CODE				CHAR(4),
	@Ac_PetitionType_CODE					CHAR(4),
	@Ac_Job_ID								CHAR(7),
    @Ad_Run_DATE							DATE,
    @Ac_Msg_CODE							CHAR(5)		   OUTPUT,
    @As_DescriptionError_TEXT				VARCHAR(4000)  OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
    DECLARE @Ln_County1_IDNO                          NUMERIC(1) = 1,
            @Ln_County3_IDNO                          NUMERIC(1) = 3,
            @Ln_County5_IDNO                          NUMERIC(1) = 5,
            @Lc_StatusFailed_CODE                     CHAR	  = 'F',
            @Lc_Note_INDC                             CHAR(1) = 'N',
            @Lc_StatusSuccess_CODE                    CHAR(1) = 'S',
            @Lc_ErrorTypeError_CODE                   CHAR(1) = 'E',
            @Lc_NcpType_CODE                          CHAR(1) = 'A',
            @Lc_PfType_CODE                           CHAR(1) = 'P',
            @Lc_CaseMemberStatusA_CODE                CHAR(1) = 'A',
            @Lc_TypeActivity_CODE                     CHAR(1) = 'H',
            @Lc_TypeOthp_CODE                         CHAR(1) = 'C',
            @Lc_TypeError_CODE                        CHAR(1) = ' ',
            @Lc_SubsystemEs_CODE                      CHAR(2) = 'ES',
            @Lc_MinorReasonDescriptionSy_CODE         CHAR(2) = 'SY',
            @Lc_ApptStatusSc_CODE                     CHAR(2) = 'SC',
            @Lc_CountyCn_CODE                         CHAR(2) = 'CN',
            @Lc_CountyCk_CODE                         CHAR(2) = 'CK',
            @Lc_CountyCs_CODE                         CHAR(2) = 'CS',
            @Lc_PetitionDisp_CODE                     CHAR(4) = 'DISP',
            @Lc_PetitionSchd_CODE                     CHAR(4) = 'SCHD',
            @Lc_PetitionFild_CODE                     CHAR(4) = 'FILD',
            @Lc_PetitionTypeSvn_CODE                  CHAR(4) = 'SVN',
            @Lc_MajorActivityCase_CODE                CHAR(4) = 'CASE',
            @Lc_MinorActivitySvnfi_CODE               CHAR(5) = 'SVNFI',
            @Lc_MinorActivitySvnsc_CODE               CHAR(5) = 'SVNSC',
            @Lc_MinorActivitySvndi_CODE               CHAR(5) = 'SVNDI',
            @Lc_BateErrorUnknown_CODE				  CHAR(5) = 'E1424',
            @Lc_BatchRunUser_TEXT                     CHAR(30) = 'BATCH',
            @Ls_Court_NAME                            VARCHAR(50) = '%FAMILY COURT%',
            @Ls_Lab_NAME                              VARCHAR(60) = 'FAMILY COURT',
            @Ls_Procedure_NAME                        VARCHAR(100) = 'SP_PROCESS_PETITION_REQUEST',
            @Ls_Process_NAME                          VARCHAR(100) = 'BATCH_EST_INCOMING_FC_RTPR ',
            @Ls_Err0003_TEXT						  VARCHAR(100) = 'REACHED EXCEPTION THRESHOLD',
            @Ls_CursorLoc_TEXT                        VARCHAR(200) = ' ',
            @Ls_Record_TEXT                           VARCHAR(3200) = ' ',
            @Ld_Low_DATE							  DATE = '01/01/0001',
            @Ld_High_DATE                             DATE = '12/31/9999';
  DECLARE   @Ln_Zero_NUMB							  NUMERIC = 0,
            @Ln_Exists_NUMB							  NUMERIC(1) = 0,
            @Ln_OrderSeq_NUMB						  NUMERIC(2) = 0,
            @Ln_County_IDNO							  NUMERIC(3) = 0,
            @Ln_SeqEventFunctional_NUMB				  NUMERIC(4,0) = 0,
            @Ln_Othp_IDNO							  NUMERIC(9) = 0, 
            @Ln_MemberMci_IDNO						  NUMERIC(10) = 0,
            @Ln_Schedule_NUMB						  NUMERIC(10) = 0,
            @Ln_Topic_IDNO							  NUMERIC(10,0) = 0,
            @Ln_Error_NUMB							  NUMERIC(11) = 0,
            @Ln_ErrorLine_NUMB						  NUMERIC(11) = 0,
            @Ln_TransactionEventSeq_NUMB			  NUMERIC(19) = 0,
            @Li_RowCount_QNTY						  SMALLINT,
            @Lc_Space_TEXT							  CHAR(1) = '',
            @Lc_FinalDisposition_CODE				  CHAR(1) = '',
            @Lc_PetitinerPresent_INDC				  CHAR(1) = '',
            @Lc_RespondentPresent_INDC				  CHAR(1) = '',
            @Lc_MedicalCoverage_INDC				  CHAR(1) = '',
            @Lc_WageAttachmentObtained_INDC			  CHAR(1) = '',
            @Lc_SchdUnit_CODE						  CHAR(2) = '',
            @Lc_SchdHh_TIME							  CHAR(2) = '',
            @Lc_SchdMm_TIME							  CHAR(2) = '',
            @Lc_Msg_CODE							  CHAR(5) = '',
            @Lc_Disposition_CODE					  CHAR(5) = '',
            @Lc_BateError_CODE						  CHAR(5) = '',
            @Lc_SchdHearingType_CODE				  CHAR(5) = '',
            @Lc_Schd_TIME							  CHAR(5) = '',
            @Lc_SchdOfficer_CODE					  CHAR(7) = '',
            @Lc_DispositionOfficer_CODE				  CHAR(7) = '',
            @Lc_Schd_DATE							  CHAR(8) = '',
            @Lc_SchdFormat_DATE						  CHAR(8) = '',
            @Lc_DispositionDate_TEXT				  CHAR(8) = '',
            @Lc_SchdOfficer_NAME					  CHAR(29) = '',
            @Lc_DispositionOfficer_NAME				  CHAR(29) = '',
            @Lc_SchdDescription_TEXT				  CHAR(40) = '',
            @Lc_DispositionDescription_TEXT			  CHAR(40) = '',
            @Ls_Sql_TEXT							  VARCHAR(100) = '',
            @Ls_Schedule_MemberMci_IDNO				  VARCHAR(400) = '',
            @Ls_Sqldata_TEXT						  VARCHAR(1000) = '',
            @Ls_DescriptionError_TEXT				  VARCHAR(4000) = '',
            @Ls_ErrorMessage_TEXT					  VARCHAR(4000) = '',
            @Ls_Note_TEXT							  VARCHAR(4000) = '',
            @Ld_BeginSch_DTTM						  DATETIME2,
            @Ld_EndSch_DTTM							  DATETIME2;
            
  
  BEGIN TRY
	
	BEGIN
	  
	  SET @Ln_MemberMci_IDNO = @Ln_Zero_NUMB;
	  SET @Ls_Sql_TEXT = 'Reading CMEM_Y1 Table for NCP/PF MCI Number';
      SET @Ls_Sqldata_TEXT = 'Case IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Family Court File Id = ' + @Ac_FamilyCourtFile_ID + ', Petition Number = ' + CAST(@An_Petition_IDNO AS VARCHAR);
	  SELECT TOP 1 @Ln_MemberMci_IDNO = c.MemberMci_IDNO 
	    FROM CMEM_Y1 c
	   WHERE c.Case_IDNO =  @An_Case_IDNO
	     AND c.CaseRelationship_CODE IN (@Lc_NcpType_CODE, @Lc_PfType_CODE)
	     AND c.CaseMemberStatus_CODE  = @Lc_CaseMemberStatusA_CODE;
	      
	  SET @Li_Rowcount_QNTY = @@ROWCOUNT;
	  IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB   
	   BEGIN 
	    SET @Ln_MemberMci_IDNO = @Ln_Zero_NUMB
	   END
      -- Get the transaction event sequence number 
      
	  EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
        @Ac_Process_ID               = @Ac_Job_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
        @Ac_Note_INDC                = @Lc_Note_INDC,
        @An_EventFunctionalSeq_NUMB  = @Ln_SeqEventFunctional_NUMB,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
	  
	  IF @Ac_PetitionDispType_CODE = @Lc_PetitionFild_CODE
	   BEGIN
	    SET @Ls_Note_TEXT = @Lc_Space_TEXT;
	    SET @Ls_Note_TEXT = 'Petition Number ' + CAST(@An_Petition_IDNO  AS VARCHAR) + ' for the DECSS case ' + CAST(@An_Case_IDNO AS VARCHAR) + ' has been successfully created in the Family Court System.'; 
	    -- Create the case journal entry SVNFI
	    
	    EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
         @An_Case_IDNO                = @An_Case_IDNO,
         @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
         @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
         @Ac_ActivityMinor_CODE       = @Lc_MinorActivitySvnfi_CODE,
         @As_DescriptionNote_TEXT     = @Ls_Note_TEXT,  
         @Ac_Subsystem_CODE           = @Lc_SubsystemEs_CODE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
         @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
         @Ad_Run_DATE                 = @Ad_Run_DATE,
         @Ac_Job_ID                   = @Ac_Job_ID,
         @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
			 SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
			 RAISERROR(50001,16,1);
			END
		ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		 BEGIN
		  SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
		  SET @Lc_BateError_CODE = @Lc_Msg_CODE;
		  RAISERROR (50001,16,1);
		 END
	   END 
	  ELSE IF @Ac_PetitionDispType_CODE = @Lc_PetitionSchd_CODE
	    BEGIN
	    -- -- Create the case journal entry SVNSC
	     SET @Ls_Note_TEXT = @Lc_Space_TEXT;
	     SET @Lc_SchdOfficer_NAME = '';
		 SET @Lc_SchdUnit_CODE = '';
		 SET @Lc_SchdOfficer_CODE = '';
		 SET @Lc_Schd_DATE = '';
		 SET @Lc_SchdFormat_DATE = '';
		 SET @Lc_SchdHh_TIME = '';
		 SET @Lc_SchdMm_TIME = '';
		 SET @Lc_SchdHearingType_CODE = '';
		 SET @Lc_SchdDescription_TEXT = '';
		 SET @Lc_SchdOfficer_CODE = SUBSTRING(@As_RecordTypeData_TEXT, 1, 7);
		 SET @Lc_Schd_TIME = SUBSTRING(@As_RecordTypeData_TEXT, 45, 5);
		 SET @Lc_SchdHh_TIME = SUBSTRING(@As_RecordTypeData_TEXT, 45, 2);
		 SET @Lc_SchdMm_TIME = SUBSTRING(@As_RecordTypeData_TEXT, 48, 2);
		 SET @Lc_SchdHearingType_CODE = SUBSTRING(@As_RecordTypeData_TEXT, 52, 5);
		 SET @Lc_SchdDescription_TEXT = SUBSTRING(@As_RecordTypeData_TEXT, 57, 40);
         SET @Lc_SchdOfficer_NAME = SUBSTRING(@As_RecordTypeData_TEXT, 8, 29);
         SET @Lc_SchdUnit_CODE = SUBSTRING(@As_RecordTypeData_TEXT, 50, 2);
         SET @Lc_Schd_DATE = SUBSTRING (@As_RecordTypeData_TEXT, 37, 8);
         SET @Lc_SchdFormat_DATE = SUBSTRING(@Lc_Schd_DATE, 5, 4) + LEFT(@Lc_Schd_DATE,2) + SUBSTRING(@Lc_Schd_DATE, 3, 2);
	     SET @Ls_Note_TEXT = @Lc_SchdDescription_TEXT;
	     SET @Ld_BeginSch_DTTM   = CAST(CAST(@Lc_SchdFormat_DATE AS DATE) AS DATETIME) + CAST(@Lc_Schd_TIME AS TIME);
		 SET @Ld_EndSch_DTTM     = CAST(CAST(@Lc_SchdFormat_DATE AS DATE) AS DATETIME) + CAST(@Lc_Schd_TIME AS TIME) + CAST('00:30' AS TIME);
	     --'Petition Number = ' + CAST(@An_Petition_IDNO  AS VARCHAR) + 'for the DECSS case = ' + CAST(@An_Case_IDNO AS VARCHAR) + ' has been successfully created in the Family Court System'; 
	     
	     IF SUBSTRING(@Ac_FamilyCourtFile_ID, 1, 2) = @Lc_CountyCn_CODE
		  BEGIN
			SET @Ln_County_IDNO = @Ln_County3_IDNO;
		  END
		 ELSE
		  IF SUBSTRING(@Ac_FamilyCourtFile_ID, 1, 2) = @Lc_CountyCs_CODE
			BEGIN
			 SET @Ln_County_IDNO = @Ln_County5_IDNO;
		   END
		  ELSE
			IF SUBSTRING(@Ac_FamilyCourtFile_ID, 1, 2) = @Lc_CountyCk_CODE
				BEGIN
					SET @Ln_County_IDNO = @Ln_County1_IDNO;
				END
			ELSE
				BEGIN
					-- GET CASE COUNTY FROM THE CASE TABLE
					SET @Ls_Sql_TEXT = 'Reading CASE_Y1 Table ';
					SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR);
					SELECT  @Ln_County_IDNO = COUNTY_IDNO 
					 FROM CASE_Y1 c 
					 WHERE c.Case_IDNO = @An_Case_IDNO;
					
				END
		 -- To select all the active members from the case	
		 SET @Ls_Sql_TEXT = 'Reading CMEM_Y1 Table ';
		 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR);
         SELECT @Ls_Schedule_MemberMci_IDNO = COALESCE(@Ls_Schedule_MemberMci_IDNO + ',', ' ') + CAST(MemberMci_IDNO AS VARCHAR) FROM CMEM_Y1 WHERE Case_IDNO = 319171
               AND CaseRelationship_CODE IN ('A', 'P', 'C','D') AND CaseMemberStatus_CODE = 'A';
         SELECT @Ls_Schedule_MemberMci_IDNO = RIGHT(@Ls_Schedule_MemberMci_IDNO,LEN(@Ls_Schedule_MemberMci_IDNO)-1) ;
              
         SET @Ls_Sql_TEXT = 'Reading OTHP_Y1 Table ';
		 SET @Ls_Sqldata_TEXT = 'County_IDNO = ' + CAST(@Ln_County_IDNO AS VARCHAR) + ' OthpType_CODE = ' + @Lc_TypeOthp_CODE + ' OtherParty_NAME Like ' + @Ls_Court_NAME;
         SELECT TOP 1 @Ln_Othp_IDNO = v.OtherParty_IDNO
          FROM OTHP_Y1 v
          WHERE v.County_IDNO   = @Ln_County_IDNO
          AND v.TypeOthp_CODE = @Lc_TypeOthp_CODE
          AND v.OtherParty_NAME LIKE @Ls_Court_NAME;
	      SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE SVNSC';
		  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + 'File_ID  = ' + @Ac_FamilyCourtFile_ID + 'PetitionIdno_TEXT = ' + CAST(@An_Petition_IDNO AS VARCHAR);
				
				EXECUTE BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE
					@An_Case_IDNO                = @An_Case_IDNO,
				    @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
				    @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO, 
				    @An_Forum_IDNO               = @Ln_Zero_NUMB,
				    @An_Topic_IDNO               = @Ln_Zero_NUMB,
				    @An_MajorIntSeq_NUMB         = @Ln_Zero_NUMB,
				    @An_MinorIntSeq_NUMB         = @Ln_Zero_NUMB,
				    @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
				    @Ac_ActivityMinor_CODE       = @Lc_MinorActivitySvnsc_CODE,
				    @Ac_ReasonStatus_CODE        = @Lc_MinorReasonDescriptionSy_CODE,
				    @As_DescriptionNote_TEXT     = @Ls_Note_TEXT,
				    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
				    @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
				    @Ad_Run_DATE                 = @Ad_Run_DATE,
				    @As_Process_ID               = @Ac_Job_ID,
				    @An_OthpLocation_IDNO		 = @Ln_Othp_IDNO,
					@Ac_WorkerDelegateTo_ID		 = @Lc_BatchRunUser_TEXT,
					@Ac_TypeActivity_CODE		 = @Lc_TypeActivity_CODE, 
					@Ad_Schedule_DATE            = @Lc_SchdFormat_DATE, 
					@Ad_BeginSch_DTTM            = @Ld_BeginSch_DTTM, 
					@Ad_EndSch_DTTM				 = @Ld_EndSch_DTTM, 
					@Ac_ApptStatus_CODE			 = @Lc_ApptStatusSc_CODE, 
					@Ac_ProceedingType_CODE		 = @Lc_SchdHearingType_CODE,
					@Ac_SchedulingUnit_CODE      = @Lc_SchdUnit_CODE,
					@Ac_ScheduleWorker_ID        = @Lc_SchdOfficer_CODE,
					@As_Schedule_MemberMci_IDNO	 = @Ls_Schedule_MemberMci_IDNO,
				    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
				    @An_Schedule_NUMB            = @Ln_Schedule_NUMB OUTPUT,
				    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

				 IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
				  BEGIN
					SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
					SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
					RAISERROR(50001,16,1);
				  END
				 ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
				  BEGIN
					SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
					SET @Lc_BateError_CODE = @Lc_Msg_CODE;
					RAISERROR (50001,16,1);
				  END	
	     
	    END
	   ELSE
	    IF @Ac_PetitionDispType_CODE = @Lc_PetitionDisp_CODE
	     BEGIN
	     -- -- Create the case journal entry SVNDI
	    
	      SET @Ls_Note_TEXT = @Lc_Space_TEXT;
	      SET @Lc_DispositionOfficer_CODE = '';
		  SET @Lc_DispositionOfficer_NAME = '';
		  SET @Lc_DispositionDate_TEXT = '';
		  SET @Lc_FinalDisposition_CODE = '';
		  SET @Lc_Disposition_CODE = '';
		  SET @Lc_PetitinerPresent_INDC = '';
		  SET @Lc_RespondentPresent_INDC = '';
		  SET @Lc_MedicalCoverage_INDC = '';
		  SET @Lc_DispositionDescription_TEXT = '';
		  SET @Lc_WageAttachmentObtained_INDC = '';
		  SET @Lc_DispositionOfficer_CODE = SUBSTRING (@As_RecordTypeData_TEXT, 1, 7);
		  SET @Lc_DispositionOfficer_NAME = SUBSTRING (@As_RecordTypeData_TEXT, 8, 29);
		  SET @Lc_DispositionDate_TEXT = SUBSTRING (@As_RecordTypeData_TEXT, 37, 8);
		  SET @Lc_Disposition_CODE = SUBSTRING (@As_RecordTypeData_TEXT, 45, 5);
		  
		  SET @Lc_DispositionDescription_TEXT = SUBSTRING (@As_RecordTypeData_TEXT, 50, 40);
          SET @Lc_PetitinerPresent_INDC = SUBSTRING (@As_RecordTypeData_TEXT, 90, 1);
		  SET @Lc_RespondentPresent_INDC = SUBSTRING (@As_RecordTypeData_TEXT, 91, 1);
		 
		  SET @Lc_MedicalCoverage_INDC = SUBSTRING (@As_RecordTypeData_TEXT, 92, 1);
		  SET @Lc_FinalDisposition_CODE = SUBSTRING (@As_RecordTypeData_TEXT, 94, 1);
	      SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_INSERT_ACTIVITY SVNDI';
	      
		  SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + 'File_ID  = ' + @Ac_FamilyCourtFile_ID + 'PetitionIdno_TEXT = ' + CAST(@An_Petition_IDNO AS VARCHAR);
		  SET @Ls_Note_TEXT = 'A Disposition record was received from Family Court which included the following information: ' + '<BR/>' + '<BR/>' +
		  'Petition Number: ' + CAST(@An_Petition_IDNO AS VARCHAR) + '<BR/>' + 'Disposition Officer Code: ' + @Lc_DispositionOfficer_CODE + '<BR/>' + 'Disposition Officer Name: ' + @Lc_DispositionOfficer_NAME + '<BR/>' +
		  'Disposition Date: ' + @Lc_DispositionDate_TEXT + '<BR/>' + 'Disposition Outcome Code: ' + @Lc_Disposition_CODE + '<BR/>' + 'Disposition Outcome Description: ' + @Lc_DispositionDescription_TEXT + '<BR/>' + 
		  'Petitioner Present Indicator: ' + @Lc_PetitinerPresent_INDC + '<BR/>' + 'Respondent Present Indicator: ' + @Lc_RespondentPresent_INDC + '<BR/>' + 'Medical Coverage Indicator: ' + @Lc_MedicalCoverage_INDC + '<BR/>' + 
		  'Wage Attachment Obtained Indicator: ' + @Lc_WageAttachmentObtained_INDC + '<BR/>' + 'Final Disposition Indicator: ' + @Lc_FinalDisposition_CODE; 
	    	      
	      EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
           @An_Case_IDNO                = @An_Case_IDNO,
           @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
           @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
           @Ac_ActivityMinor_CODE       = @Lc_MinorActivitySvndi_CODE,
           @As_DescriptionNote_TEXT     = @Ls_Note_TEXT,  
           @Ac_Subsystem_CODE           = @Lc_SubsystemEs_CODE,
           @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
           @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
           @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
           @Ad_Run_DATE                 = @Ad_Run_DATE,
           @Ac_Job_ID                   = @Ac_Job_ID,
           @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
           @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
          IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
			 SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
			 RAISERROR(50001,16,1);
			END
	      ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		   BEGIN
		    SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
		    SET @Lc_BateError_CODE = @Lc_Msg_CODE;
		    RAISERROR (50001,16,1);
		   END		
	     END
	       
	 
	  SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
     
	END 
       
     
  END TRY
  
  BEGIN CATCH
     --Set Error Description
            SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
            IF @Lc_Msg_CODE <> @Lc_StatusFailed_CODE
             AND @Lc_Msg_CODE <> @Lc_Space_TEXT  
              BEGIN 
                 SET @Ac_Msg_CODE = @Lc_Msg_CODE;
			  END	
            SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
			SET @Ln_Error_NUMB = ERROR_NUMBER ();
		    SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
		    IF @Ln_Error_NUMB <> 50001
		    
				BEGIN
					SET @Ls_ErrorMessage_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
				END
			EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION 
				@As_Procedure_NAME			= @Ls_Procedure_NAME,
                @As_ErrorMessage_TEXT		= @Ls_ErrorMessage_TEXT,
                @As_Sql_TEXT				= @Ls_Sql_TEXT,
                @As_Sqldata_TEXT			= @Ls_Sqldata_TEXT,
                @An_Error_NUMB				= @Ln_Error_NUMB,
                @An_ErrorLine_NUMB			= @Ln_ErrorLine_NUMB,
                @As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT; 
  
  END CATCH
 END

GO
