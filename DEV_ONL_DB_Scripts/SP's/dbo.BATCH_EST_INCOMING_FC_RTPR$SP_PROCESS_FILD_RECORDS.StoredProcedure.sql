/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_FILD_RECORDS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure  Name	     : BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_FILD_RECORDS
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_FILD_RECORDS processes the FILD response records 
                       received from the family court into the DECSS system.
 					   
Frequency			 : Daily
Developed On		 : 05/10/2011
Called By			 : BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_PETITION_REQUEST
Called On			 : 
----------------------------------------------------------------------------------------------------------------------------------					   
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_FILD_RECORDS]
   @An_Case_IDNO						NUMERIC(6),
   @An_MajorIntSeq_NUMB					NUMERIC(5, 0),
   @An_Petition_IDNO					NUMERIC(7),
   @Ad_PetitionAction_DATE				DATE,
   @An_TransactionEventSeq_NUMB			NUMERIC(19),
   @Ac_FcPetRespCur_FamilyCourtFile_ID	CHAR(10),
   @Ad_Start_DATE						DATETIME2,
   @Ac_PetitionType_CODE				CHAR(4),
   @Ac_Job_ID							CHAR(7),
   @Ad_Run_DATE							DATE,
   @As_DescriptionNote_TEXT				VARCHAR(4000),
   @Ac_Msg_CODE							CHAR(5)		   OUTPUT,
   @As_DescriptionError_TEXT			VARCHAR(4000)  OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
    DECLARE @Lc_StatusFailed_CODE                     CHAR	  = 'F',
            @Lc_Yes_INDC                              CHAR    = 'Y',
            @Lc_ErrorTypeError_CODE                   CHAR(1) = 'E',
            @Lc_TypeError_CODE                        CHAR(1) = ' ',
            @Lc_TypeOrderV_CODE                       CHAR(1) = 'V',
            @Lc_StatusSuccess_CODE                    CHAR(1) = 'S',
            @Lc_StatusAbnormalend_CODE                CHAR(1) = 'A',
            @Lc_NcpType_CODE                          CHAR(1) = 'A',
            @Lc_PfType_CODE                           CHAR(1) = 'P',
            @Lc_CpType_CODE                           CHAR(1) = 'C',
            @Lc_DependentType_CODE					  CHAR(1) = 'D',
            @Lc_CaseMemberStatusA_CODE                CHAR(1) = 'A',
            @Lc_TypeOthp_CODE                         CHAR(1) = 'C',
            @Lc_TypeActivity_CODE                     CHAR(1) = 'H',
            @Lc_CaseStatusOpen_CODE                   CHAR(1) = 'O',
            @Lc_DocumentTypeP_CODE                    CHAR(1) = 'P',
            @Lc_DocumentSourceD_CODE                  CHAR(1) = 'D',
            @Lc_DocumentSourceF_CODE                  CHAR(1) = 'F',
            @Lc_ServiceMethodP_CODE                   CHAR(1) = 'P',
            @Lc_CaseRelationshipClient_CODE           CHAR(1) = 'C',
            @Lc_CaseMemberActive_CODE                 CHAR(1) = 'A',
            @Lc_CaseMemberStatusActive_CODE           CHAR(1) = 'A',
            @Lc_CaseRelationshipNcp_CODE              CHAR(1) = 'A',
            @Lc_CaseRelationshipD_CODE                CHAR(1) = 'D',
            @Lc_CountyCn_CODE                         CHAR(2) = 'CN',
            @Lc_CountyCk_CODE                         CHAR(2) = 'CK',
            @Lc_CountyCs_CODE                         CHAR(2) = 'CS',
            @Lc_ApptStatusSc_CODE                     CHAR(2) = 'SC',
            @Lc_MinorReasonDescriptionFa_CODE         CHAR(2) = 'FA',
            @Lc_MinorReasonDescriptionPn_CODE         CHAR(2) = 'PN',
            @Lc_LocationStDe_CODE                     CHAR(2) = 'DE',
            @Lc_ApptStatusCn_CODE					  CHAR(2) = 'CN',
            @Lc_ApptStatusCd_CODE					  CHAR(2) = 'CD',
            @Lc_SubsystemCt_CODE					  CHAR(2) = 'CT',
            @Lc_SubsystemEst_CODE                     CHAR(2) = 'ES',
            @Lc_NcpTypePerson_CODE                    CHAR(3) = 'NCP',
            @Lc_CpTypePerson_CODE                     CHAR(3) = 'CP',
            @Lc_DependentTypePerson_CODE              CHAR(3) = 'CI',
            @Lc_MajorActivityCase_CODE                CHAR(4) = 'CASE',
            @Lc_MajorStatusStart_CODE                 CHAR(4) = 'STRT',
            @Lc_MinorStatusCmpl_CODE                  CHAR(4) = 'CMPL',
            @Lc_MajorActivityEstp_CODE                CHAR(4) = 'ESTP',
            @Lc_MajorActivityMapp_CODE                CHAR(4) = 'MAPP',
            @Lc_MajorActivityRofo_CODE                CHAR(4) = 'ROFO',
            @Lc_MinorStatusStart_CODE                 CHAR(4) = 'STRT',
            @Lc_PetitionDisp_CODE                     CHAR(4) = 'DISP',
            @Lc_PetitionFild_CODE                     CHAR(4) = 'FILD',
            @Lc_PetitionTypePetn_CODE                 CHAR(4) = 'PETN',
            @Lc_PetitionTypePetp_CODE                 CHAR(4) = 'PETP',
            @Lc_PetitionTypePetl_CODE                 CHAR(4) = 'PETL', 
            @Lc_BateErrorUnknown_CODE				  CHAR(5) = 'E1424',
            @Lc_MinorActivityPfrfe_CODE               CHAR(5) = 'PFRFE',
            @Lc_MinorActivityPfrfm_CODE               CHAR(5) = 'PFRFM',
            @Lc_MinorActivityPsrrf_CODE               CHAR(5) = 'PSRRF',
            @Lc_MinorActivityPfdrf_CODE               CHAR(5) = 'PFDRF',
            @Lc_MinorActivityPnfdf_CODE               CHAR(5) = 'PNFDF',
            @Lc_MinorActivityFdinf_CODE               CHAR(5) = 'FDINF',
            @Lc_MinorActivityNegse_CODE               CHAR(5) = 'NEGSE',
            @Lc_MinorActivityNfdnf_CODE               CHAR(5) = 'NFDNF',
            @Lc_MinorActivityNffrf_CODE               CHAR(5) = 'NFFRF',
            @Lc_MinorActivitySrfnp_CODE               CHAR(5) = 'SRFNP',
            @Lc_MinorActivityPfsrf_CODE               CHAR(5) = 'PFSRF',
            @Lc_MinorActivityRopdp_CODE               CHAR(5) = 'ROPDP',
            @Lc_MinorActivityUnspr_CODE               CHAR(5) = 'UNSPR',
            @Lc_MinorActivityAftbc_CODE               CHAR(5) = 'AFTBC',
            @Lc_MinorActivityAserr_CODE               CHAR(5) = 'ASERR',
            @Lc_MinorActivityDocnm_CODE               CHAR(5) = 'DOCNM',
            @Lc_MinorActivityAschd_CODE               CHAR(5) = 'ASCHD',
            @Lc_ActivityMinorFamup_CODE               CHAR(5) = 'FAMUP',
            @Lc_ActivityMinorAordd_CODE               CHAR(5) = 'AORDD',
            @Lc_ErrorE1977_CODE                       CHAR(5) = 'E1977',
            @Lc_JobProcessPetition_ID                 CHAR(7) = 'DEB8066',
            @Lc_Job_ID                                CHAR(7) = 'DEB8066',
            @Lc_Successful_TEXT                       CHAR(20) = 'SUCCESSFUL',
            @Lc_BatchRunUser_TEXT                     CHAR(30) = 'BATCH',
            @Lc_Parmdateproblem_TEXT                  CHAR(30) = 'PARM DATE PROBLEM',
            @Ls_CountyNewCastleFc_NAME                VARCHAR(50) = 'FAMILY COURT - NEW CASTLE COUNTY',
            @Ls_CountyKentFc_NAME                     VARCHAR(50) = 'FAMILY COURT - KENT COUNTY',
            @Ls_CountySussexFc_NAME                   VARCHAR(50) = 'FAMILY COURT - SUSSEX COUNTY',
            @Ls_Lab_NAME                              VARCHAR(60) = 'FAMILY COURT',
            @Ls_Procedure_NAME                        VARCHAR(100) = 'SP_PROCESS_PETITION_REQUEST',
            @Ls_Process_NAME                          VARCHAR(100) = 'BATCH_EST_INCOMING_FC_RTPR ',
            @Ls_Err0003_TEXT						  VARCHAR(100) = 'REACHED EXCEPTION THRESHOLD',
            @Ls_CursorLoc_TEXT                        VARCHAR(200) = ' ',
            @Ls_Record_TEXT                           VARCHAR(3200) = ' ',
            @Ld_Low_DATE							  DATE = '01/01/0001',
            @Ld_High_DATE                             DATE = '12/31/9999';
  DECLARE   @Ln_Zero_NUMB							  NUMERIC = 0,
            @Ln_Exists_NUMB							  NUMERIC(2) = 0,
            @Ln_OrderSeq_NUMB						  NUMERIC(2) = 0,
            @Ln_County_IDNO							  NUMERIC(3) = 0,
            @Ln_SeqEventFunctional_NUMB				  NUMERIC(4,0) = 0,
            @Ln_CommitFreq_QNTY						  NUMERIC(5) = 0,
            @Ln_CommitFreqParm_QNTY					  NUMERIC(5) = 0,
            @Ln_ExceptionThresholdParm_QNTY			  NUMERIC(5) = 0,
            @Ln_ExceptionThreshold_QNTY				  NUMERIC(5) = 0,
            @Ln_PetitionKey_IDNO					  NUMERIC(5) = 0,
            @Ln_MajorIntSeq_NUMB					  NUMERIC(5) = 0,
            @Ln_MinorIntSeq_NUMB					  NUMERIC(5) = 0,
            @Ln_ProcessedRecordCount_QNTY			  NUMERIC(6) = 0,
            @Ln_ProcessedRecordCountCommit_QNTY		  NUMERIC(6) = 0,
            @Ln_FcPetRespCur_Case_IDNO				  NUMERIC(6) = 0,
            @Ln_FcPetRespCur_Petition_IDNO			  NUMERIC(7) = 0,
            @Ln_Othp_IDNO							  NUMERIC(9) = 0,           
            @Ln_MemberMci_IDNO						  NUMERIC(10) = 0,
            @Ln_Cur_QNTY							  NUMERIC(10,0) = 0,
            @Ln_Line_NUMB							  NUMERIC(10,0) = 0,
            @Ln_Forum_IDNO							  NUMERIC(10,0) = 0,
            @Ln_Topic_IDNO							  NUMERIC(10,0) = 0,
            @Ln_Schedule_NUMB						  NUMERIC(10) = 0,
            @Ln_Petitioner_IDNO						  NUMERIC(10) = 0,
            @Ln_Respondent_IDNO						  NUMERIC(10) = 0,
            @Ln_Error_NUMB							  NUMERIC(11) = 0,
            @Ln_ErrorLine_NUMB						  NUMERIC(11) = 0,
            @Ln_TransactionEventSeq_NUMB			  NUMERIC(19) = 0,
            @Li_FetchStatus_QNTY					  SMALLINT,
            @Li_RowCount_QNTY						  SMALLINT,
            @Lc_Space_TEXT							  CHAR(1) = '',
            @Lc_ServiceMethod_CODE					  CHAR(1) = '',
            @Lc_ServiceFailureReason_CODE			  CHAR(1) = '',
            @Lc_PetitinerPresent_INDC				  CHAR(1) = '',
            @Lc_RespondentPresent_INDC				  CHAR(1) = '',
            @Lc_MedicalCoverage_INDC				  CHAR(1) = '',
            @Lc_DocumentSource_CODE					  CHAR(1) = '',
            @Lc_ApflPetitionerMi_NAME				  CHAR(1) = '',
            @Lc_ApflRespondentMi_NAME				  CHAR(1) = '',
            @Lc_UpdateMinorActivity_INDC			  CHAR(1) = '',
            @Lc_InsertCaseJournal_INDC				  CHAR(1) = '',
            @Lc_Msg_CODE							  CHAR(5) = '',
            @Lc_ApptStatus_CODE						  CHAR(2) = '',
            @Lc_ReasonStatus_CODE					  CHAR(2) = '',
            @Lc_MinorReasonDescription_CODE			  CHAR(2) = '',
            @Lc_ActivityMajor_CODE					  CHAR(4) = '',
            @Lc_Status_CODE							  CHAR(4) = '',
            @Lc_FcPetRespCur_PetitionType_CODE		  CHAR(4) = '',
            @Lc_BateError_CODE						  CHAR(5) = '',
            @Lc_ServiceZip1_ADDR					  CHAR(5) = '',
            @Lc_ActivityMinorNext_CODE				  CHAR(5) = '',
            @Lc_ActivityMinor_CODE					  CHAR(5) = '',
            @Lc_Service_DATE						  CHAR(8) = '',
            @Lc_ServiceFormat_DATE					  CHAR(8),
            @Lc_PetitionActionFormat_DATE			  CHAR(8) = '',
            @Lc_ApflActionFiled_DATE				  CHAR(8) = '',
            @Lc_ApflActionFiledFormat_DATE			  CHAR(8) = '',
            @Lc_Petition_KEY						  CHAR(8) = '',
            @Lc_ApflPetitionerSsn_NUMB				  CHAR(9) = '',
            @Lc_ApflRespondentSsn_NUMB				  CHAR(9) = '',
            @Lc_ApflPetitionerMci_IDNO				  CHAR(10) = '',
            @Lc_ApflRespondentMci_IDNO				  CHAR(10) = '',
            @Lc_FamilyCourtFile_ID					  CHAR(10) = '',
            @Lc_CaseFamilyCourtFile_ID				  CHAR(10) = '',
            @Lc_FcPetRespCur_FamilyCourtFile_ID       char(10) = '',
            @Lc_ServiceZip_ADDR						  CHAR(15) = '',
            @Lc_ServiceCity_ADDR					  CHAR(16) = '',
            @Lc_ApflPetitionerFirst_NAME			  CHAR(16) = '',
            @Lc_ApflRespondentFirst_NAME			  CHAR(16) = '',
            @Lc_ApflPetitionerLast_NAME				  CHAR(20) = '',
            @Lc_ApflRespondentLast_NAME				  CHAR(20) = '',
            @Ls_OthpCounty_NAME						  VARCHAR(50) = '',
            @Ls_ServiceLine1_ADDR					  VARCHAR(50) = '',
            @Ls_ServiceLine2_ADDR					  VARCHAR(50) = '',
            @Ls_FullDisplay_NAME					  VARCHAR(60) = '',
            @Ls_SereDescriptionValue_TEXT			  VARCHAR(70) = '',
            @Ls_SrffDescriptionValue_TEXT			  VARCHAR(70) = '',
            @Ls_FdocDescriptionValue_TEXT			  VARCHAR(70) = '',
            @Ls_Sql_TEXT							  VARCHAR(100) = '',
            @Ls_Schedule_MemberMci_IDNO				  VARCHAR(400) = '',
            @Ls_ServiceNotes_TEXT					  VARCHAR(1000) = '',
            @Ls_Sqldata_TEXT						  VARCHAR(1000) = '',
            @Ls_DescriptionError_TEXT				  VARCHAR(4000) = '',
            @Ls_DescriptionNote_TEXT				  VARCHAR(4000) = '',
            @Ls_Note_TEXT							  VARCHAR(4000) = '',
            @Ls_Note1_TEXT							  VARCHAR(4000) = '',
            @Ls_Note2_TEXT							  VARCHAR(4000) = '',
            @Ls_Note3_TEXT							  VARCHAR(4000) = '',
            @Ls_Note5_TEXT							  VARCHAR(4000) = '',
            @Ls_Note6_TEXT							  VARCHAR(4000) = '',
            @Ls_ErrorMessage_TEXT					  VARCHAR(4000) = '',
            @Ls_BateRecord_TEXT						  VARCHAR(4000) = '',
            @Ld_Run_DATE							  DATE,
            @Ld_Service_DATE						  DATE,
            @Ld_PetitionAction_DATE					  DATE,
            @Ld_Start_DATE							  DATETIME2,
            @Ld_LastRun_DATE						  DATETIME2,
            @Ld_BeginSch_DTTM						  DATETIME2,
            @Ld_EndSch_DTTM							  DATETIME2;
   
  BEGIN TRY
   
      BEGIN
       
       SET @Ln_Petitioner_IDNO = 0;
       SET @Ln_Respondent_IDNO = 0;
       SET @Ln_Forum_IDNO = 0;
       SET @Ln_MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
       SET @Ls_DescriptionNote_TEXT = '';
       SET @Ls_DescriptionNote_TEXT = @As_DescriptionNote_TEXT; 
       
       SET @Ln_FcPetRespCur_Case_IDNO = @An_Case_IDNO;
       SET @Ld_PetitionAction_DATE = @Ad_PetitionAction_DATE;
       SET @Ln_FcPetRespCur_Petition_IDNO = @An_Petition_IDNO;
       SET @Ld_Start_DATE = @Ad_Start_DATE;
       SET @Ld_Run_DATE = @Ad_Run_DATE;
       SET @Lc_FcPetRespCur_FamilyCourtFile_ID = @Ac_FcPetRespCur_FamilyCourtFile_ID;
       SET @Lc_FcPetRespCur_PetitionType_CODE =	@Ac_PetitionType_CODE;
       SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
       SET @Ls_Sql_TEXT = 'DMJR READ IN FILD PROCESS';
       SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', MAJOR INT SEQ NUM = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR);
       SELECT @Lc_ActivityMajor_CODE = m.ActivityMajor_CODE,
              @Ln_Respondent_IDNO = m.MemberMci_IDNO,
              @Ln_Forum_IDNO = m.Forum_IDNO
         FROM DMJR_Y1 m
        WHERE m.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
          AND m.MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
          AND m.Status_CODE = @Lc_MajorStatusStart_CODE
          AND m.MajorIntSEQ_NUMB > 0;
       -- Check the table read fetches any records or not
       SET @Li_RowCount_QNTY = @@ROWCOUNT;
       IF @Li_RowCount_QNTY = @Ln_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'DMJR_Y1 READ FAILED ';
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
		 SET @Lc_Msg_CODE = @Lc_ErrorE1977_CODE;
         RAISERROR(50001,16,1);
        END
       
       SET @Ls_Sql_TEXT = 'DMNR READ IN FILD PROCESS';
       SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', MAJOR INT SEQ NUM = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR); 
       SELECT TOP 1   @Ln_OrderSeq_NUMB = n.OrderSeq_NUMB,
                      @Ln_MinorIntSeq_NUMB = n.MinorIntSeq_NUMB
           FROM DMNR_Y1 n
          WHERE n.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
            AND n.MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
            AND n.ActivityMajor_CODE IN (@Lc_MajorActivityEstp_CODE, @Lc_MajorActivityRofo_CODE, @Lc_MajorActivityMapp_CODE)
          ORDER BY MinorIntSeq_NUMB DESC;
       -- Check the table read fetches any records or not
       SET @Li_RowCount_QNTY = @@ROWCOUNT;
       
       IF @Li_RowCount_QNTY = @Ln_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'DMNR_Y1 READ FAILED ';
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
		 SET @Lc_Msg_CODE = @Lc_ErrorE1977_CODE;
         RAISERROR(50001,16,1);
        END
       --Select client Mci number from the cmem table 
       
       SELECT @Ln_Petitioner_IDNO = c.memberMci_IDNO
         FROM CMEM_Y1 c
        WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
          AND c.CaseRelationship_CODE = @Lc_CaseRelationshipClient_CODE
          AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE;
       -- Check the table read fetches any records or not
       SET @Li_RowCount_QNTY = @@ROWCOUNT;
       IF @Li_RowCount_QNTY = @Ln_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'CMEM_Y1 READ FETCHES NO RECORDS ';
         RAISERROR(50001,16,1);
        END
       
       IF @Lc_ActivityMajor_CODE IN (@Lc_MajorActivityEstp_CODE, @Lc_MajorActivityMapp_CODE,@Lc_MajorActivityRofo_CODE)
        BEGIN
                  
         SELECT @Lc_FamilyCourtFile_ID = f.File_ID 
           FROM FDEM_Y1 f 
           WHERE f.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
             AND f.Petitioner_IDNO = @Ln_Petitioner_IDNO
             AND f.Respondent_IDNO = @Ln_Respondent_IDNO
             AND f.TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB) FROM FDEM_Y1 g WHERE g.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO) ;
         SET @Li_RowCount_QNTY = @@ROWCOUNT;
         
         IF ((@Li_RowCount_QNTY = @Ln_Zero_NUMB)
         OR 
           (@Li_RowCount_QNTY <>  @Ln_Zero_NUMB
            AND  LTRIM(RTRIM(@Lc_FamilyCourtFile_ID)) = @Lc_Space_TEXT))
			-- ADD THE NEW FILE NUMBER 
			BEGIN 
			  SELECT @Ln_Exists_NUMB =  COUNT(1)
			   FROM DCKT_Y1 d
			   WHERE d.File_id = @Lc_FcPetRespCur_FamilyCourtFile_ID;
			  IF @Ln_Exists_NUMB = @Ln_Zero_NUMB
				BEGIN
				 -- ADD THE FILE NUMBER 
				 INSERT INTO DCKT_Y1 
				     (File_ID,
				      County_IDNO,
				      FileType_CODE,
				      CaseTitle_NAME,
				      Filed_DATE,
				      WorkerUpdate_ID,
				      BeginValidity_DATE,
				      EventGlobalBeginSeq_NUMB,
				      Update_DTTM)
				 (SELECT @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID,
				         c.County_IDNO AS County_IDNO,
				         @Lc_Space_TEXT AS FileType_CODE,
				         @Lc_Space_TEXT AS CaseTitle_NAME,
				         @Ld_PetitionAction_DATE AS Filed_DATE,
				         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				         @Ld_Run_DATE AS BeginValidity_DATE,
				         @Ln_TransactionEventSeq_NUMB AS EventGlobalBeginSeq_NUMB,
				         @Ld_Start_DATE AS Update_DTTM
				   FROM CASE_Y1 c 
				   WHERE c.Case_IDNO =  @Ln_FcPetRespCur_Case_IDNO);
				   SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO DCKT FAILED';
						RAISERROR (50001, 16, 1);
					  END	      
				 
				 INSERT INTO DPRS_Y1
				     (File_ID,
				      County_IDNO,
				      TypePerson_CODE,
				      DocketPerson_IDNO,
				      WorkerUpdate_ID,
				      File_NAME,
				      EffectiveStart_DATE,
				      EffectiveEnd_DATE,
				      BeginValidity_DATE,
				      EndValidity_DATE,
				      TransactionEventSeq_NUMB,
				      Update_DTTM,
				      AttorneyAttn_NAME,
				      AssociatedMemberMci_IDNO)                           
				 (SELECT @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID,
				         c.County_IDNO AS County_IDNO,
				         CASE WHEN m.CaseRelationship_CODE IN (@Lc_NcpType_CODE, @Lc_PfType_CODE)
				              THEN @Lc_NcpTypePerson_CODE 
				              WHEN m.CaseRelationship_CODE = @Lc_CpType_CODE
				              THEN @Lc_CpTypePerson_CODE 
				              WHEN m.CaseRelationship_CODE = @Lc_DependentType_CODE
				              THEN @Lc_DependentTypePerson_CODE
				         END  AS TypePerson_CODE,
				         m.MemberMci_IDNO  AS DocketPerson_IDNO,
				         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				         d.FullDisplay_NAME AS File_NAME,
				         @Ld_Run_DATE AS EffectiveStart_DATE,
				         @Ld_High_DATE AS EndValidity_DATE,
				         @Ld_Run_DATE AS BeginValidity_DATE,
				         @Ld_High_DATE AS EndValidity_DATE,
				         @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
				         @Ld_Start_DATE AS Update_DTTM,
				         @Lc_Space_TEXT AS AttorneyAttn_NAME,
				         @Ln_Zero_NUMB AS AssociatedMemberMci_IDNO
				   FROM CASE_Y1 c, CMEM_Y1 m, DEMO_Y1 d
				   WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
				     AND c.Case_IDNO = m.Case_IDNO
				     AND m.MemberMci_IDNO = d.MemberMci_IDNO
				     AND ((m.MemberMci_IDNO IN (@Ln_Respondent_IDNO, @Ln_Petitioner_IDNO))
				         OR
				          (m.CaseRelationship_CODE = 'D'))
				     AND m.CaseMemberStatus_CODE = 'A');
				     
				   SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO DPRS FAILED';
						RAISERROR (50001, 16, 1);
					  END	          
		        END
		      ELSE 
				BEGIN  
				   SET @Ln_Exists_NUMB = @Ln_Zero_NUMB;
				   SELECT @Ln_Exists_NUMB =  COUNT(1)
					FROM DPRS_Y1 d
					WHERE d.File_id = @Lc_FcPetRespCur_FamilyCourtFile_ID
					  AND d.EndValidity_DATE = @Ld_High_DATE;
				  INSERT INTO DPRS_Y1
				     (File_ID,
				      County_IDNO,
				      TypePerson_CODE,
				      DocketPerson_IDNO,
				      WorkerUpdate_ID,
				      File_NAME,
				      EffectiveStart_DATE,
				      EffectiveEnd_DATE,
				      BeginValidity_DATE,
				      EndValidity_DATE,
				      TransactionEventSeq_NUMB,
				      Update_DTTM,
				      AttorneyAttn_NAME,
				      AssociatedMemberMci_IDNO)                           
				 (SELECT @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID,
				         c.County_IDNO AS County_IDNO,
				         CASE WHEN m.CaseRelationship_CODE IN (@Lc_NcpType_CODE, @Lc_PfType_CODE)
				              THEN @Lc_NcpTypePerson_CODE 
				              WHEN m.CaseRelationship_CODE = @Lc_CpType_CODE
				              THEN @Lc_CpTypePerson_CODE 
				              WHEN m.CaseRelationship_CODE = @Lc_DependentType_CODE
				              THEN @Lc_DependentTypePerson_CODE
				         END  AS TypePerson_CODE,
				         m.MemberMci_IDNO  AS DocketPerson_IDNO,
				         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				         d.FullDisplay_NAME AS File_NAME,
				         @Ld_Run_DATE AS EffectiveStart_DATE,
				         @Ld_High_DATE AS EndValidity_DATE,
				         @Ld_Run_DATE AS BeginValidity_DATE,
				         @Ld_High_DATE AS EndValidity_DATE,
				         @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
				         @Ld_Start_DATE AS Update_DTTM,
				         @Lc_Space_TEXT AS AttorneyAttn_NAME,
				         @Ln_Zero_NUMB AS AssociatedMemberMci_IDNO
				   FROM CASE_Y1 c, CMEM_Y1 m, DEMO_Y1 d
				   WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
				     AND c.Case_IDNO = m.Case_IDNO
				     AND m.MemberMci_IDNO = d.MemberMci_IDNO
				     AND ((m.MemberMci_IDNO IN (@Ln_Respondent_IDNO, @Ln_Petitioner_IDNO))
				         OR
				          (m.CaseRelationship_CODE = 'D'))
				     AND m.CaseMemberStatus_CODE = 'A'
				     AND m.MemberMci_IDNO NOT IN (SELECT DocketPerson_IDNO FROM DPRS_Y1 WHERE File_ID = @Lc_FcPetRespCur_FamilyCourtFile_ID
				                                                                          AND EndValidity_DATE = @Ld_High_DATE));
				   
				   -- If no records inserted into DPRS_Y1 table from above intert and no records exists in DPRS_Y1 for the File id, then only raise error  
				   SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				   
				   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				   AND @Ln_Exists_NUMB  = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO DPRS FAILED';
						RAISERROR (50001, 16, 1);
					  END	          
				END 
			END
		 ELSE
		  BEGIN  
			IF LTRIM(RTRIM(@Lc_FamilyCourtFile_ID)) <> LTRIM(RTRIM(@Lc_FcPetRespCur_FamilyCourtFile_ID))
			  BEGIN
				-- Change Existing file number
			   
			  SELECT @Ln_Exists_NUMB = COUNT(1)
			   FROM DCKT_Y1 d
			   WHERE d.File_id = @Lc_FcPetRespCur_FamilyCourtFile_ID;
			   IF @Ln_Exists_NUMB = @Ln_Zero_NUMB
			     BEGIN
				  -- Bug 13219 Start
				  -- Check the old file id for this case was already exists for another case in FDEM_Y1, Then do not archieve the DCKT_Y1 table. Insert a new row
				  -- into DCKT_Y1 table. Logically end date the DPRS_Y1 records for the current cases and insert new records in the DPRS_Y1 for the current file id
				  SELECT TOP 1 @Ln_Exists_NUMB = 1
				    FROM FDEM_Y1 f 
				   WHERE f.File_ID = LTRIM(RTRIM(@Lc_FamilyCourtFile_ID))
				     AND f.Case_IDNO <> @Ln_FcPetRespCur_Case_IDNO
				     AND f.EndValidity_DATE = @Ld_High_DATE;
				  IF @Ln_Exists_NUMB = @Ln_Zero_NUMB  
				   BEGIN 
				  -- Bug 13219 End 
				  -- Move the record from DCKT_Y1 into HDCKT_Y1 TABLE
				    INSERT INTO HDCKT_Y1
				  	  (File_ID,
				  	   County_IDNO,
				  	   FileType_CODE,
				  	   CaseTitle_NAME,
				  	   Filed_DATE,
				  	   WorkerUpdate_ID,
				  	   BeginValidity_DATE,
				  	   EventGlobalBeginSeq_NUMB,
				  	   Update_DTTM,
				  	   EndValidity_DATE,
				  	   EventGlobalEndSeq_NUMB)
				    (SELECT  d.File_ID,
				          d.County_IDNO,
				          d.FileType_CODE,
				          d.CaseTitle_NAME,
				          d.Filed_DATE,
				          d.WorkerUpdate_ID,
				          d.BeginValidity_DATE,
				          d.EventGlobalBeginSeq_NUMB,
				          @Ld_Start_DATE AS Update_DTTM,
				          @Ld_Run_DATE AS EndValidity_DATE,  
				          @Ln_TransactionEventSeq_NUMB AS EventGlobalEndSeq_NUMB
				    FROM DCKT_Y1 d
				    WHERE d.File_ID = @Lc_FamilyCourtFile_ID);
				     
				    SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				    IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO HDCKT FAILED';
						RAISERROR (50001, 16, 1);
					  END	                                                                   
				  -- Update the DCKT_Y1 table with the new file ID
					SELECT @Ln_County_IDNO = County_IDNO FROM CASE_Y1 WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO;
					UPDATE DCKT_Y1
					SET File_ID    =  @Lc_FcPetRespCur_FamilyCourtFile_ID,
					    County_IDNO = @Ln_County_IDNO,
					    Filed_DATE =  @Ld_PetitionAction_DATE,
					    BeginValidity_DATE = @Ld_Run_DATE,
					    EventGlobalBeginSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
					    WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
         				Update_DTTM = @Ld_Start_DATE
         			WHERE File_ID = @Lc_FamilyCourtFile_ID;
         			SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
					IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'UPDATE TO DCKT_Y1 FAILED';
						RAISERROR (50001, 16, 1);
					  END	      
				  -- Update the DPRS_Y1 TABLE
				    UPDATE DPRS_Y1 
				    SET EndValidity_DATE = @Ld_Run_DATE,
				      Update_DTTM      = @Ld_Start_DATE
				    WHERE File_ID = @Lc_FamilyCourtFile_ID;
				    SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
					 IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'UPDATE TO DPRS_Y1 FAILED';
						RAISERROR (50001, 16, 1);
					  END	          
				  -- Insert records into DPRS_Y1 table for the new file id received.
				    INSERT INTO DPRS_Y1
				     (File_ID,
				      County_IDNO,
				      TypePerson_CODE,
				      DocketPerson_IDNO,
				      WorkerUpdate_ID,
				      File_NAME,
				      EffectiveStart_DATE,
				      EffectiveEnd_DATE,
				      BeginValidity_DATE,
				      EndValidity_DATE,
				      TransactionEventSeq_NUMB,
				      Update_DTTM,
				      AttorneyAttn_NAME,
				      AssociatedMemberMci_IDNO)                           
				    (SELECT @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID,
				         c.County_IDNO AS County_IDNO,
				         CASE WHEN m.CaseRelationship_CODE IN (@Lc_NcpType_CODE, @Lc_PfType_CODE)
				              THEN @Lc_NcpTypePerson_CODE 
				              WHEN m.CaseRelationship_CODE = @Lc_CpType_CODE
				              THEN @Lc_CpTypePerson_CODE 
				              WHEN m.CaseRelationship_CODE = @Lc_DependentType_CODE
				              THEN @Lc_DependentTypePerson_CODE
				         END  AS TypePerson_CODE,
				         m.MemberMci_IDNO  AS DocketPerson_IDNO,
				         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				         d.FullDisplay_NAME AS File_NAME,
				         @Ld_Run_DATE AS EffectiveStart_DATE,
				         @Ld_High_DATE AS EndValidity_DATE,
				         @Ld_Run_DATE AS BeginValidity_DATE,
				         @Ld_High_DATE AS EndValidity_DATE,
				         @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
				         @Ld_Start_DATE AS Update_DTTM,
				         @Lc_Space_TEXT AS AttorneyAttn_NAME,
				         @Ln_Zero_NUMB AS AssociatedMemberMci_IDNO
				    FROM CASE_Y1 c, CMEM_Y1 m, DEMO_Y1 d
				    WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
				     AND c.Case_IDNO = m.Case_IDNO
				     AND m.MemberMci_IDNO = d.MemberMci_IDNO
				     AND ((m.MemberMci_IDNO IN (@Ln_Respondent_IDNO, @Ln_Petitioner_IDNO))
				         OR
				          (m.CaseRelationship_CODE = 'D'))
				     AND m.CaseMemberStatus_CODE = 'A');
				     
				    SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				    IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO DPRS FAILED';
						RAISERROR (50001, 16, 1);
					  END	          	    
				   END
				  -- Bug 13219 Start
				  ELSE
				  -- Insert new docket record for the file number, logical update the DPRS_Y1 records for that case members and insert new records into DPRS_Y1 for
				  -- the file ID and case members
				   BEGIN
				    INSERT INTO DCKT_Y1 
				     (File_ID,
				      County_IDNO,
				      FileType_CODE,
				      CaseTitle_NAME,
				      Filed_DATE,
				      WorkerUpdate_ID,
				      BeginValidity_DATE,
				      EventGlobalBeginSeq_NUMB,
				      Update_DTTM)
				    (SELECT @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID,
				         c.County_IDNO AS County_IDNO,
				         @Lc_Space_TEXT AS FileType_CODE,
				         @Lc_Space_TEXT AS CaseTitle_NAME,
				         @Ld_PetitionAction_DATE AS Filed_DATE,
				         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				         @Ld_Run_DATE AS BeginValidity_DATE,
				         @Ln_TransactionEventSeq_NUMB AS EventGlobalBeginSeq_NUMB,
				         @Ld_Start_DATE AS Update_DTTM
				    FROM CASE_Y1 c 
				    WHERE c.Case_IDNO =  @Ln_FcPetRespCur_Case_IDNO);
				    SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				    IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO DCKT FAILED';
						RAISERROR (50001, 16, 1);
					  END	      
				    -- Insert records into DPRS_Y1 table for the new file id received.
				    INSERT INTO DPRS_Y1
				     (File_ID,
				      County_IDNO,
				      TypePerson_CODE,
				      DocketPerson_IDNO,
				      WorkerUpdate_ID,
				      File_NAME,
				      EffectiveStart_DATE,
				      EffectiveEnd_DATE,
				      BeginValidity_DATE,
				      EndValidity_DATE,
				      TransactionEventSeq_NUMB,
				      Update_DTTM,
				      AttorneyAttn_NAME,
				      AssociatedMemberMci_IDNO)                           
				    (SELECT @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID,
				         c.County_IDNO AS County_IDNO,
				         CASE WHEN m.CaseRelationship_CODE IN (@Lc_NcpType_CODE, @Lc_PfType_CODE)
				              THEN @Lc_NcpTypePerson_CODE 
				              WHEN m.CaseRelationship_CODE = @Lc_CpType_CODE
				              THEN @Lc_CpTypePerson_CODE 
				              WHEN m.CaseRelationship_CODE = @Lc_DependentType_CODE
				              THEN @Lc_DependentTypePerson_CODE
				         END  AS TypePerson_CODE,
				         m.MemberMci_IDNO  AS DocketPerson_IDNO,
				         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				         d.FullDisplay_NAME AS File_NAME,
				         @Ld_Run_DATE AS EffectiveStart_DATE,
				         @Ld_High_DATE AS EndValidity_DATE,
				         @Ld_Run_DATE AS BeginValidity_DATE,
				         @Ld_High_DATE AS EndValidity_DATE,
				         @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
				         @Ld_Start_DATE AS Update_DTTM,
				         @Lc_Space_TEXT AS AttorneyAttn_NAME,
				         @Ln_Zero_NUMB AS AssociatedMemberMci_IDNO
				    FROM CASE_Y1 c, CMEM_Y1 m, DEMO_Y1 d
				    WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
				     AND c.Case_IDNO = m.Case_IDNO
				     AND m.MemberMci_IDNO = d.MemberMci_IDNO
				     AND ((m.MemberMci_IDNO IN (@Ln_Respondent_IDNO, @Ln_Petitioner_IDNO))
				         OR
				          (m.CaseRelationship_CODE = 'D'))
				     AND m.CaseMemberStatus_CODE = 'A');
				     
				    SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				    IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO DPRS FAILED';
						RAISERROR (50001, 16, 1);
					  END	          	    
				     
				   -- Bug 13219 End
				   END
				  -- Check the case table to update file id 
				  SELECT @Lc_CaseFamilyCourtFile_ID = c.File_ID
				    FROM CASE_Y1 c 
				    WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO;
				    IF LTRIM(RTRIM(@Lc_CaseFamilyCourtFile_ID)) <> @Lc_Space_TEXT
				       -- Move the record to the HCASE_Y1 TABLE 
				      BEGIN
						INSERT INTO HCASE_Y1
						    (Case_IDNO,
							 StatusCase_CODE,
							 TypeCase_CODE,
							 RsnStatusCase_CODE,
							 RespondInit_CODE,
							 SourceRfrl_CODE,
							 Opened_DATE,
							 Marriage_DATE,
							 Divorced_DATE,
							 StatusCurrent_DATE,
							 AprvIvd_DATE,
							 County_IDNO,
							 Office_IDNO,
							 AssignedFips_CODE,
							 GoodCause_CODE,
							 GoodCause_DATE,
							 Restricted_INDC,
							 MedicalOnly_INDC,
							 Jurisdiction_INDC,
							 IvdApplicant_CODE,
							 Application_IDNO,
							 AppSent_DATE,
							 AppReq_DATE,
							 AppRetd_DATE,
							 CpRelationshipToNcp_CODE,
							 Worker_ID,
							 AppSigned_DATE,
							 ClientLitigantRole_CODE,
							 DescriptionComments_TEXT,
							 NonCoop_CODE,
							 NonCoop_DATE,
							 BeginValidity_DATE,
							 EndValidity_DATE,
							 WorkerUpdate_ID,
							 TransactionEventSeq_NUMB,
							 Update_DTTM,
							 Referral_DATE,
							 CaseCategory_CODE,
							 File_ID,
							 ApplicationFee_CODE,
							 FeePaid_DATE,
							 ServiceRequested_CODE,
							 StatusEnforce_CODE,
							 FeeCheckNo_TEXT,
							 ReasonFeeWaived_CODE,
							 Intercept_CODE)
					     (SELECT Case_IDNO,
								StatusCase_CODE,
								TypeCase_CODE,
								RsnStatusCase_CODE,
								RespondInit_CODE,
								SourceRfrl_CODE,
								Opened_DATE,
								Marriage_DATE,
								Divorced_DATE,
								StatusCurrent_DATE,
								AprvIvd_DATE,
								County_IDNO,
								Office_IDNO,
								AssignedFips_CODE,
								GoodCause_CODE,
								GoodCause_DATE,
								Restricted_INDC,
								MedicalOnly_INDC,
								Jurisdiction_INDC,
								IvdApplicant_CODE,
								Application_IDNO,
								AppSent_DATE,
								AppReq_DATE,
								AppRetd_DATE,
								CpRelationshipToNcp_CODE,
								Worker_ID,
								AppSigned_DATE,
								ClientLitigantRole_CODE,
								DescriptionComments_TEXT,
								NonCoop_CODE,
								NonCoop_DATE,
								BeginValidity_DATE,
								@Ld_Run_DATE AS EndValidity_DATE,
								WorkerUpdate_ID,
								TransactionEventSeq_NUMB,
								Update_DTTM,
								Referral_DATE,
								CaseCategory_CODE,
								File_ID,
								ApplicationFee_CODE,
								FeePaid_DATE,
								ServiceRequested_CODE,
								StatusEnforce_CODE,
								FeeCheckNo_TEXT,
								ReasonFeeWaived_CODE,
								Intercept_CODE
						 FROM CASE_Y1 c
						 WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO);
	                     SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
						 IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
							BEGIN
								SET @Ls_DescriptionError_TEXT = 'INSERT INTO HCASE_Y1 FAILED';
								RAISERROR (50001, 16, 1);
							END	      
                       -- Update the case table for new file id 
				        UPDATE CASE_Y1 
				        SET File_ID = @Lc_FcPetRespCur_FamilyCourtFile_ID,
				           TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
				           WorkerUpdate_ID			=  @Lc_BatchRunUser_TEXT,                 
				           Update_DTTM              = @Ld_Start_DATE
				        WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO;
				        SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
						 IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
							BEGIN
								SET @Ls_DescriptionError_TEXT = 'Update TO CASE_Y1 FAILED';
								RAISERROR (50001, 16, 1);
							END	      
				      END
				  -- Check the SORD_Y1 table to update file id 
				  SELECT @Lc_CaseFamilyCourtFile_ID = s.File_ID
				    FROM sord_y1 s 
				    WHERE s.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
				      AND s.EndValidity_DATE = @Ld_High_DATE;
				    IF LTRIM(RTRIM(@Lc_CaseFamilyCourtFile_ID)) <> @Lc_Space_TEXT
				       
				      BEGIN
	                   UPDATE SORD_Y1
					    SET File_ID = @Ac_FcPetRespCur_FamilyCourtFile_ID,
         					WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
         					BeginValidity_DATE = @Ld_Start_DATE,
         					EventGlobalBeginSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         					EventGlobalEndSeq_NUMB = @Ln_Zero_NUMB
					   OUTPUT Deleted.Case_IDNO,
							  Deleted.OrderSeq_NUMB,
							  Deleted.Order_IDNO,
							  Deleted.File_ID,
							  Deleted.OrderEnt_DATE,
							  Deleted.OrderIssued_DATE,
							  Deleted.OrderEffective_DATE,
							  Deleted.OrderEnd_DATE,
							  Deleted.ReasonStatus_CODE,
							  Deleted.StatusOrder_CODE,
							  Deleted.StatusOrder_DATE,
							  Deleted.InsOrdered_CODE,
							  Deleted.MedicalOnly_INDC,
							  Deleted.Iiwo_CODE,
							  Deleted.NoIwReason_CODE,
							  Deleted.IwoInitiatedBy_CODE,
							  Deleted.GuidelinesFollowed_INDC,
							  Deleted.DeviationReason_CODE,
							  Deleted.DescriptionDeviationOthers_TEXT,
							  Deleted.OrderOutOfState_ID,
							  Deleted.CejStatus_CODE,
							  Deleted.CejFips_CODE,
							  Deleted.IssuingOrderFips_CODE,
							  Deleted.Qdro_INDC,
							  Deleted.UnreimMedical_INDC,
							  Deleted.CpMedical_PCT,
							  Deleted.NcpMedical_PCT,
							  Deleted.ParentingTime_PCT,
							  Deleted.NoParentingDays_QNTY,
							  Deleted.PetitionerAppeared_INDC,
							  Deleted.RespondentAppeared_INDC,
							  Deleted.OthersAppeared_INDC,
							  Deleted.PetitionerReceived_INDC,
							  Deleted.RespondentReceived_INDC,
							  Deleted.OthersReceived_INDC,
							  Deleted.PetitionerMailed_INDC,
							  Deleted.RespondentMailed_INDC,
							  Deleted.OthersMailed_INDC,
							  Deleted.PetitionerMailed_DATE,
							  Deleted.RespondentMailed_DATE,
							  Deleted.OthersMailed_DATE,
							  Deleted.CoverageMedical_CODE,
							  Deleted.CoverageDrug_CODE,
							  Deleted.CoverageMental_CODE,
							  Deleted.CoverageDental_CODE,
							  Deleted.CoverageVision_CODE,
							  Deleted.CoverageOthers_CODE,
							  Deleted.DescriptionCoverageOthers_TEXT,
							  Deleted.WorkerUpdate_ID,
							  Deleted.BeginValidity_DATE,
							  @Ld_Start_DATE AS EndValidity_DATE,
							  Deleted.EventGlobalBeginSeq_NUMB,
							  @Ln_TransactionEventSeq_NUMB AS EventGlobalEndSeq_NUMB,
							  Deleted.DescriptionParentingNotes_TEXT,
							  Deleted.LastIrscReferred_DATE,
							  Deleted.LastIrscUpdated_DATE,
							  Deleted.LastIrscReferred_AMNT,
							  Deleted.StatusControl_CODE,
						      Deleted.StateControl_CODE,
							  Deleted.OrderControl_ID,
							  Deleted.PetitionerAttorneyAppeared_INDC,
							  Deleted.RespondentAttorneyAppeared_INDC,
							  Deleted.PetitionerAttorneyReceived_INDC,
							  Deleted.RespondentAttorneyReceived_INDC,
							  Deleted.PetitionerAttorneyMailed_INDC,
							  Deleted.RespondentAttorneyMailed_INDC,
							  Deleted.PetitionerAttorneyMailed_DATE,
							  Deleted.RespondentAttorneyMailed_DATE,
							  Deleted.TypeOrder_CODE,
							  Deleted.ReviewRequested_DATE,
							  Deleted.NextReview_DATE,
							  Deleted.LastReview_DATE,
							  Deleted.LastNoticeSent_DATE,
							  Deleted.DirectPay_INDC,
							  Deleted.SourceOrdered_CODE,
							  -- 13650 - CR0420 The Commissioner and Judge fields are moved from DCKT_Y1 table to SORD_Y1 TABLE -START-
							  Deleted.Judge_ID,
							  Deleted.Commissioner_ID 
							  -- 13650 - CR0420 The Commissioner and Judge fields are moved from DCKT_Y1 table to SORD_Y1 TABLE -END-
					   INTO SORD_Y1 ( 
						Case_IDNO,
						OrderSeq_NUMB,
						Order_IDNO,
						File_ID,
						OrderEnt_DATE,
						OrderIssued_DATE,
						OrderEffective_DATE,
						OrderEnd_DATE,
						ReasonStatus_CODE,
						StatusOrder_CODE,
						StatusOrder_DATE,
						InsOrdered_CODE,
						MedicalOnly_INDC,
						Iiwo_CODE,
						NoIwReason_CODE,
						IwoInitiatedBy_CODE,
						GuidelinesFollowed_INDC,
						DeviationReason_CODE,
						DescriptionDeviationOthers_TEXT,
						OrderOutOfState_ID,
						CejStatus_CODE,
						CejFips_CODE,
						IssuingOrderFips_CODE,
						Qdro_INDC,
						UnreimMedical_INDC,
						CpMedical_PCT,
						NcpMedical_PCT,
						ParentingTime_PCT,
						NoParentingDays_QNTY,
						PetitionerAppeared_INDC,
						RespondentAppeared_INDC,
						OthersAppeared_INDC,
						PetitionerReceived_INDC,
						RespondentReceived_INDC,
						OthersReceived_INDC,
						PetitionerMailed_INDC,
						RespondentMailed_INDC,
						OthersMailed_INDC,
						PetitionerMailed_DATE,
						RespondentMailed_DATE,
						OthersMailed_DATE,
						CoverageMedical_CODE,
						CoverageDrug_CODE,
						CoverageMental_CODE,
						CoverageDental_CODE,
						CoverageVision_CODE,
						CoverageOthers_CODE,
						DescriptionCoverageOthers_TEXT,
						WorkerUpdate_ID,
						BeginValidity_DATE,
						EndValidity_DATE,
						EventGlobalBeginSeq_NUMB,
						EventGlobalEndSeq_NUMB,
						DescriptionParentingNotes_TEXT,
						LastIrscReferred_DATE,
						LastIrscUpdated_DATE,
						LastIrscReferred_AMNT,
						StatusControl_CODE,
						StateControl_CODE,
						OrderControl_ID,
						PetitionerAttorneyAppeared_INDC,
						RespondentAttorneyAppeared_INDC,
						PetitionerAttorneyReceived_INDC,
						RespondentAttorneyReceived_INDC,
						PetitionerAttorneyMailed_INDC,
						RespondentAttorneyMailed_INDC,
						PetitionerAttorneyMailed_DATE,
						RespondentAttorneyMailed_DATE,
						TypeOrder_CODE,
						ReviewRequested_DATE,
						NextReview_DATE,
						LastReview_DATE,
						LastNoticeSent_DATE,
						DirectPay_INDC,
						SourceOrdered_CODE,
						-- 13650 - CR0420 The Commissioner and Judge fields are moved from DCKT_Y1 table to SORD_Y1 TABLE -START-
						Judge_ID,
						Commissioner_ID
						-- 13650 - CR0420 The Commissioner and Judge fields are moved from DCKT_Y1 table to SORD_Y1 TABLE -END-
    				)
				   WHERE Case_IDNO = @An_Case_IDNO
      				 AND EndValidity_DATE = @Ld_High_DATE;
				  END    
				 END
			  END
		  END
		
         -- updating the sord_y1 for voluntary orders
         SELECT @Lc_CaseFamilyCourtFile_ID = s.File_ID
		   FROM sord_y1 s 
		   WHERE s.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
			 AND s.EndValidity_DATE = @Ld_High_DATE
			 AND s.Typeorder_CODE   = @Lc_TypeOrderV_CODE;
		 SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
		 IF @Li_Rowcount_QNTY <> @Ln_Zero_NUMB
            BEGIN 
			  IF LTRIM(RTRIM(@Lc_CaseFamilyCourtFile_ID)) = @Lc_Space_TEXT
                BEGIN
                   UPDATE SORD_Y1
				    SET File_ID = @Ac_FcPetRespCur_FamilyCourtFile_ID,
         				WorkerUpdate_ID = @Lc_BatchRunUser_TEXT,
         				BeginValidity_DATE = @Ld_Start_DATE,
         				EventGlobalBeginSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         				EventGlobalEndSeq_NUMB = @Ln_Zero_NUMB
					   OUTPUT Deleted.Case_IDNO,
							  Deleted.OrderSeq_NUMB,
							  Deleted.Order_IDNO,
							  Deleted.File_ID,
							  Deleted.OrderEnt_DATE,
							  Deleted.OrderIssued_DATE,
							  Deleted.OrderEffective_DATE,
							  Deleted.OrderEnd_DATE,
							  Deleted.ReasonStatus_CODE,
							  Deleted.StatusOrder_CODE,
							  Deleted.StatusOrder_DATE,
							  Deleted.InsOrdered_CODE,
							  Deleted.MedicalOnly_INDC,
							  Deleted.Iiwo_CODE,
							  Deleted.NoIwReason_CODE,
							  Deleted.IwoInitiatedBy_CODE,
							  Deleted.GuidelinesFollowed_INDC,
							  Deleted.DeviationReason_CODE,
							  Deleted.DescriptionDeviationOthers_TEXT,
							  Deleted.OrderOutOfState_ID,
							  Deleted.CejStatus_CODE,
							  Deleted.CejFips_CODE,
							  Deleted.IssuingOrderFips_CODE,
							  Deleted.Qdro_INDC,
							  Deleted.UnreimMedical_INDC,
							  Deleted.CpMedical_PCT,
							  Deleted.NcpMedical_PCT,
							  Deleted.ParentingTime_PCT,
							  Deleted.NoParentingDays_QNTY,
							  Deleted.PetitionerAppeared_INDC,
							  Deleted.RespondentAppeared_INDC,
							  Deleted.OthersAppeared_INDC,
							  Deleted.PetitionerReceived_INDC,
							  Deleted.RespondentReceived_INDC,
							  Deleted.OthersReceived_INDC,
							  Deleted.PetitionerMailed_INDC,
							  Deleted.RespondentMailed_INDC,
							  Deleted.OthersMailed_INDC,
							  Deleted.PetitionerMailed_DATE,
							  Deleted.RespondentMailed_DATE,
							  Deleted.OthersMailed_DATE,
							  Deleted.CoverageMedical_CODE,
							  Deleted.CoverageDrug_CODE,
							  Deleted.CoverageMental_CODE,
							  Deleted.CoverageDental_CODE,
							  Deleted.CoverageVision_CODE,
							  Deleted.CoverageOthers_CODE,
							  Deleted.DescriptionCoverageOthers_TEXT,
							  Deleted.WorkerUpdate_ID,
							  Deleted.BeginValidity_DATE,
							  @Ld_Start_DATE AS EndValidity_DATE,
							  Deleted.EventGlobalBeginSeq_NUMB,
							  @Ln_TransactionEventSeq_NUMB AS EventGlobalEndSeq_NUMB,
							  Deleted.DescriptionParentingNotes_TEXT,
							  Deleted.LastIrscReferred_DATE,
							  Deleted.LastIrscUpdated_DATE,
							  Deleted.LastIrscReferred_AMNT,
							  Deleted.StatusControl_CODE,
						      Deleted.StateControl_CODE,
							  Deleted.OrderControl_ID,
							  Deleted.PetitionerAttorneyAppeared_INDC,
							  Deleted.RespondentAttorneyAppeared_INDC,
							  Deleted.PetitionerAttorneyReceived_INDC,
							  Deleted.RespondentAttorneyReceived_INDC,
							  Deleted.PetitionerAttorneyMailed_INDC,
							  Deleted.RespondentAttorneyMailed_INDC,
							  Deleted.PetitionerAttorneyMailed_DATE,
							  Deleted.RespondentAttorneyMailed_DATE,
							  Deleted.TypeOrder_CODE,
							  Deleted.ReviewRequested_DATE,
							  Deleted.NextReview_DATE,
							  Deleted.LastReview_DATE,
							  Deleted.LastNoticeSent_DATE,
							  Deleted.DirectPay_INDC,
							  Deleted.SourceOrdered_CODE,
							  -- 13650 - CR0420 The Commissioner and Judge fields are moved from DCKT_Y1 table to SORD_Y1 TABLE -START-
							  Deleted.Judge_ID,
							  Deleted.Commissioner_ID 
							  -- 13650 - CR0420 The Commissioner and Judge fields are moved from DCKT_Y1 table to SORD_Y1 TABLE -END-
					   INTO SORD_Y1 ( 
						Case_IDNO,
						OrderSeq_NUMB,
						Order_IDNO,
						File_ID,
						OrderEnt_DATE,
						OrderIssued_DATE,
						OrderEffective_DATE,
						OrderEnd_DATE,
						ReasonStatus_CODE,
						StatusOrder_CODE,
						StatusOrder_DATE,
						InsOrdered_CODE,
						MedicalOnly_INDC,
						Iiwo_CODE,
						NoIwReason_CODE,
						IwoInitiatedBy_CODE,
						GuidelinesFollowed_INDC,
						DeviationReason_CODE,
						DescriptionDeviationOthers_TEXT,
						OrderOutOfState_ID,
						CejStatus_CODE,
						CejFips_CODE,
						IssuingOrderFips_CODE,
						Qdro_INDC,
						UnreimMedical_INDC,
						CpMedical_PCT,
						NcpMedical_PCT,
						ParentingTime_PCT,
						NoParentingDays_QNTY,
						PetitionerAppeared_INDC,
						RespondentAppeared_INDC,
						OthersAppeared_INDC,
						PetitionerReceived_INDC,
						RespondentReceived_INDC,
						OthersReceived_INDC,
						PetitionerMailed_INDC,
						RespondentMailed_INDC,
						OthersMailed_INDC,
						PetitionerMailed_DATE,
						RespondentMailed_DATE,
						OthersMailed_DATE,
						CoverageMedical_CODE,
						CoverageDrug_CODE,
						CoverageMental_CODE,
						CoverageDental_CODE,
						CoverageVision_CODE,
						CoverageOthers_CODE,
						DescriptionCoverageOthers_TEXT,
						WorkerUpdate_ID,
						BeginValidity_DATE,
						EndValidity_DATE,
						EventGlobalBeginSeq_NUMB,
						EventGlobalEndSeq_NUMB,
						DescriptionParentingNotes_TEXT,
						LastIrscReferred_DATE,
						LastIrscUpdated_DATE,
						LastIrscReferred_AMNT,
						StatusControl_CODE,
						StateControl_CODE,
						OrderControl_ID,
						PetitionerAttorneyAppeared_INDC,
						RespondentAttorneyAppeared_INDC,
						PetitionerAttorneyReceived_INDC,
						RespondentAttorneyReceived_INDC,
						PetitionerAttorneyMailed_INDC,
						RespondentAttorneyMailed_INDC,
						PetitionerAttorneyMailed_DATE,
						RespondentAttorneyMailed_DATE,
						TypeOrder_CODE,
						ReviewRequested_DATE,
						NextReview_DATE,
						LastReview_DATE,
						LastNoticeSent_DATE,
						DirectPay_INDC,
						SourceOrdered_CODE,
						-- 13650 - CR0420 The Commissioner and Judge fields are moved from DCKT_Y1 table to SORD_Y1 TABLE -START-
						Judge_ID,
						Commissioner_ID
						-- 13650 - CR0420 The Commissioner and Judge fields are moved from DCKT_Y1 table to SORD_Y1 TABLE -END-
    				)
				   WHERE Case_IDNO = @An_Case_IDNO
      				 AND EndValidity_DATE = @Ld_High_DATE;
      				 
                   SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				      BEGIN
						SET @Ls_DescriptionError_TEXT = 'Update TO SORD_Y1 FAILED';
						RAISERROR (50001, 16, 1);
					  END	      
                   
                   -- Update the File Id on case table also
                    SELECT @Lc_CaseFamilyCourtFile_ID = c.File_ID
				      FROM CASE_Y1 c 
				      WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO;
				    IF LTRIM(RTRIM(@Lc_CaseFamilyCourtFile_ID)) = @Lc_Space_TEXT
                      BEGIN
                        -- Update the case table for new file id 
				        UPDATE CASE_Y1 
				        SET File_ID = @Lc_FcPetRespCur_FamilyCourtFile_ID,
				           TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
				           WorkerUpdate_ID			=  @Lc_BatchRunUser_TEXT,                 
				           Update_DTTM              = @Ld_Start_DATE
				           
				          OUTPUT Deleted.Case_IDNO,
				                 Deleted.StatusCase_CODE,
								 Deleted.TypeCase_CODE,
								 Deleted.RsnStatusCase_CODE,
								 Deleted.RespondInit_CODE,
								 Deleted.SourceRfrl_CODE,
								 Deleted.Opened_DATE,
								 Deleted.Marriage_DATE,
								 Deleted.Divorced_DATE,
								 Deleted.StatusCurrent_DATE,
								 Deleted.AprvIvd_DATE,
								 Deleted.County_IDNO,
								 Deleted.Office_IDNO,
								 Deleted.AssignedFips_CODE,
								 Deleted.GoodCause_CODE,
								 Deleted.GoodCause_DATE,
								 Deleted.Restricted_INDC,
								 Deleted.MedicalOnly_INDC,
								 Deleted.Jurisdiction_INDC,
								 Deleted.IvdApplicant_CODE,
								 Deleted.Application_IDNO,
								 Deleted.AppSent_DATE,
								 Deleted.AppReq_DATE,
								 Deleted.AppRetd_DATE,
								 Deleted.CpRelationshipToNcp_CODE,
								 Deleted.Worker_ID,
								 Deleted.AppSigned_DATE,
								 Deleted.ClientLitigantRole_CODE,
								 Deleted.DescriptionComments_TEXT,
								 Deleted.NonCoop_CODE,
								 Deleted.NonCoop_DATE,
								 Deleted.BeginValidity_DATE,
								 @Ld_Run_DATE AS EndValidity_DATE,
								 Deleted.WorkerUpdate_ID,
								 Deleted.TransactionEventSeq_NUMB,
								 Deleted.Update_DTTM,
								 Deleted.Referral_DATE,
								 Deleted.CaseCategory_CODE,
								 Deleted.File_ID,
								 Deleted.ApplicationFee_CODE,
								 Deleted.FeePaid_DATE,
								 Deleted.ServiceRequested_CODE,
								 Deleted.StatusEnforce_CODE,
								 Deleted.FeeCheckNo_TEXT,
								 Deleted.ReasonFeeWaived_CODE,
								 Deleted.Intercept_CODE
				          INTO HCASE_Y1 (
				             Case_IDNO,
							 StatusCase_CODE,
							 TypeCase_CODE,
							 RsnStatusCase_CODE,
							 RespondInit_CODE,
							 SourceRfrl_CODE,
							 Opened_DATE,
							 Marriage_DATE,
							 Divorced_DATE,
							 StatusCurrent_DATE,
							 AprvIvd_DATE,
							 County_IDNO,
							 Office_IDNO,
							 AssignedFips_CODE,
							 GoodCause_CODE,
							 GoodCause_DATE,
							 Restricted_INDC,
							 MedicalOnly_INDC,
							 Jurisdiction_INDC,
							 IvdApplicant_CODE,
							 Application_IDNO,
							 AppSent_DATE,
							 AppReq_DATE,
							 AppRetd_DATE,
							 CpRelationshipToNcp_CODE,
							 Worker_ID,
							 AppSigned_DATE,
							 ClientLitigantRole_CODE,
							 DescriptionComments_TEXT,
							 NonCoop_CODE,
							 NonCoop_DATE,
							 BeginValidity_DATE,
							 EndValidity_DATE,
							 WorkerUpdate_ID,
							 TransactionEventSeq_NUMB,
							 Update_DTTM,
							 Referral_DATE,
							 CaseCategory_CODE,
							 File_ID,
							 ApplicationFee_CODE,
							 FeePaid_DATE,
							 ServiceRequested_CODE,
							 StatusEnforce_CODE,
							 FeeCheckNo_TEXT,
							 ReasonFeeWaived_CODE,
							 Intercept_CODE
							 )
				        WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO;
				        SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
						 IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
							BEGIN
								SET @Ls_DescriptionError_TEXT = 'Update TO CASE_Y1 FAILED';
								RAISERROR (50001, 16, 1);
							END	      
                      END
                END
            END                   
            
         SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO FDEM_Y1 TABLE ';
         SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);

         INSERT INTO FDEM_Y1
                     (Case_IDNO,
                      File_ID,
                      DocReference_CODE,
                      TypeDoc_CODE,
                      SourceDoc_CODE,
                      Filed_DATE,
                      BeginValidity_DATE,
                      EndValidity_DATE,
                      WorkerUpdate_ID,
                      Update_DTTM,
                      TransactionEventSeq_NUMB,
                      FdemDisplay_INDC,
                      ApprovedBy_CODE,
                      Petitioner_IDNO,
                      Respondent_IDNO,
                      Petition_IDNO,
                      Order_IDNO,
                      MajorIntSEQ_NUMB,
                      MinorIntSEQ_NUMB) 
              
              SELECT   @Ln_FcPetRespCur_Case_IDNO AS Case_IDNO,
                       @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID ,
                       @Lc_FcPetRespCur_PetitionType_CODE AS DocReference_CODE,
                       @Lc_DocumentTypeP_CODE AS TypeDoc_CODE,
                       @Lc_DocumentSourceD_CODE AS SourceDoc_CODE,
                       @Ld_PetitionAction_DATE AS Filed_DATE, 
                       @Ld_Run_DATE AS BeginValidity_DATE,
                       @Ld_High_DATE AS EndValidity_DATE,
                       @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                       @Ld_Start_DATE AS Update_DTTM, 
                       @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                       @Lc_Yes_INDC AS FdemDisplay_INDC,
                       @Lc_Space_TEXT AS ApprovedBy_CODE,
                       @Ln_Petitioner_IDNO AS Petitioner_IDNO,
                       @Ln_Respondent_IDNO AS Respondent_IDNO,
                       @Ln_FcPetRespCur_Petition_IDNO AS Petition_IDNO,
                       @Ln_OrderSeq_NUMB AS Order_IDNO,  
                       @Ln_MajorIntSeq_NUMB AS MajorIntSEQ_NUMB,
                       @Ln_MinorIntSeq_NUMB AS MinorIntSEQ_NUMB;  
         
         SET @Li_Rowcount_QNTY = @@ROWCOUNT;
         IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'FDEM_Y1 INSERT FAILED ';
           RAISERROR(50001,16,1);
          END
         -- Insert the data into new service tracking table
         SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO FDEM_Y1 TABLE ';
         SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
         --Servicing tracking information will be inserted for ESTP and ROFO majors only.
         IF @Lc_ActivityMajor_CODE IN (@Lc_MajorActivityEstp_CODE, @Lc_MajorActivityRofo_CODE)
			BEGIN
				INSERT INTO FSRT_Y1
                     (Case_IDNO,
                      File_ID,
                      MajorIntSEQ_NUMB,
                      MinorIntSeq_NUMB,
                      Petition_IDNO,
                      ServiceMethod_CODE,
                      ServiceResult_CODE,
                      ServiceFailureReason_CODE,
                      ProcessServer_DATE,
                      Service_DATE,
                      ServiceAttn_ADDR,
                      ServiceLine1_ADDR,
                      ServiceLine2_ADDR,
                      ServiceCity_ADDR,
                      ServiceState_ADDR,
                      ServiceZip_ADDR,
                      ServiceNotes_TEXT,
                      BeginValidity_DATE,
                      EndValidity_DATE,
                      WorkerUpdate_ID,
                      Update_DTTM,
                      TransactionEventSeq_NUMB,
                      ServiceCountry_ADDR)
				SELECT  @Ln_FcPetRespCur_Case_IDNO AS Case_IDNO,
                       @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID,
                       @Ln_MajorIntSeq_NUMB AS MajorIntSEQ_NUMB,
                       @Ln_MinorIntSeq_NUMB AS MinorIntSeq_NUMB,
                       @Ln_FcPetRespCur_Petition_IDNO AS Petition_IDNO,
                       @Lc_ServiceMethodP_CODE AS ServiceMethod_CODE,
                       @Lc_Space_TEXT AS ServiceResult_CODE,
                       @Lc_Space_TEXT AS ServiceFailureReason_CODE,
                       @Ld_PetitionAction_DATE AS ProcessServer_DATE,
                       @Ld_Low_DATE AS Service_DATE,
                       @Lc_Space_TEXT AS ServiceAttn_ADDR,
                       @Lc_Space_TEXT AS ServiceLine1_ADDR,
                       @Lc_Space_TEXT AS ServiceLine2_ADDR,
                       @Lc_Space_TEXT AS ServiceCity_ADDR,
                       @Lc_Space_TEXT AS ServiceState_ADDR,
                       @Lc_Space_TEXT AS ServiceZip_ADDR,
                       @Lc_Space_TEXT AS ServiceNotes_TEXT,
                       @Ld_Run_DATE   AS BeginValidity_DATE,
                       @Ld_High_DATE  AS EndValidity_DATE,
                       @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                       @Ld_Start_DATE AS Update_DTTM, 
                       @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                       @Lc_Space_TEXT AS ServiceCountry_ADDR;

				SET @Li_Rowcount_QNTY = @@ROWCOUNT;
				IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					BEGIN
						SET @Ls_DescriptionError_TEXT = 'FSRT_V1 INSERT FAILED ';
						RAISERROR(50001,16,1);
					END
			END
        END
       -- Update the minor activity chain with the petition number, file number and advance the chain
       IF @Lc_ActivityMajor_CODE IN (@Lc_MajorActivityEstp_CODE, @Lc_MajorActivityRofo_CODE)
        BEGIN
         -- Update establishment related minor activities
         SET @Ls_Note_TEXT = '';
         SET @Ls_Note_TEXT = 'File Number = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + ', and Petition Number = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR) + ', for the DECSS System Case = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', has been successfully created in the Family Court System.' + ' Service has been initiated on ' + CAST(@Ld_PetitionAction_DATE AS VARCHAR);
         -- 13602 Start
         SET @Ln_MemberMci_IDNO = 0; 
         -- 13602 End
         SELECT TOP 1 @Lc_ActivityMinor_CODE = n.ActivityMinor_CODE,
                      @Ln_MemberMci_IDNO = n.MemberMci_IDNO,
                      @Ln_OrderSeq_NUMB = n.OrderSeq_NUMB,
                      @Lc_ReasonStatus_CODE = n.ReasonStatus_CODE,
                      @Lc_Status_CODE = n.Status_CODE,
                      @Ln_Forum_IDNO  = n.Forum_IDNO,
                      @Ln_Topic_IDNO = n.Topic_IDNO,
                      @Ln_MinorIntSeq_NUMB = n.MinorIntSeq_NUMB
           FROM DMNR_Y1 n
          WHERE n.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
            AND n.MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
            AND n.ActivityMajor_CODE IN(@Lc_MajorActivityEstp_CODE, @Lc_MajorActivityRofo_CODE)
          ORDER BY MinorIntSeq_NUMB DESC;
         SET @Li_Rowcount_QNTY = @@ROWCOUNT;
         IF @Li_Rowcount_QNTY <> @Ln_Zero_NUMB
          BEGIN
           IF @Lc_ActivityMinor_CODE = @Lc_MinorActivityAftbc_CODE
              AND @Lc_Status_CODE = @Lc_MinorStatusStart_CODE
            BEGIN
             -- Call the update the minor activity procedure to move the activity chain
             EXECUTE BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
              @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
              @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
              @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
              @An_Forum_IDNO               = @Ln_Forum_IDNO,
              @An_Topic_IDNO               = @Ln_Topic_IDNO,
              @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
              @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
              @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
              @Ac_ActivityMinor_CODE       = @Lc_MinorActivityAftbc_CODE,
              @Ac_ReasonStatus_CODE        = @Lc_MinorReasonDescriptionFa_CODE,
              @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
              @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
              @Ad_Run_DATE                 = @Ld_Run_DATE,
              @Ac_Process_ID               = @Lc_Job_ID,
              @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

             IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               RAISERROR(50001,16,1);
              END
            END
           ELSE
            BEGIN
             -- Create the information alert to the worker
             EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
              @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
              @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
              @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
              @Ac_ActivityMinor_CODE       = @Lc_MinorActivityPfrfe_CODE,
              @As_DescriptionNote_TEXT     = @Ls_Note_TEXT,
              @Ac_Subsystem_CODE           = @Lc_SubsystemCt_CODE,
              @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
			  @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
              @Ad_Run_DATE                 = @Ld_Run_DATE,
              @Ac_Job_ID                   = @Lc_Job_ID,
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
          END
        END
       ELSE
       -- Update Motion and petition related minor activities
       IF @Lc_ActivityMajor_CODE = @Lc_MajorActivityMapp_CODE
        BEGIN
         SET @Ls_Note1_TEXT = 'Petition Number = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR) + ',for the DECSS System case = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', has been successfully created in the Family Court System.';
         SELECT TOP 1 @Lc_ActivityMinor_CODE = n.ActivityMinor_CODE,
                      @Ln_MemberMci_IDNO = n.MemberMci_IDNO,
                      @Ln_OrderSeq_NUMB = n.OrderSeq_NUMB,
                      @Lc_ReasonStatus_CODE = n.ReasonStatus_CODE,
                      @Lc_Status_CODE = n.Status_CODE,
                      @Ln_Forum_IDNO = n.Forum_IDNO,
                      @Ln_Topic_IDNO = n.Topic_IDNO,
                      @Ln_MinorIntSeq_NUMB = n.MinorIntSeq_NUMB
           FROM DMNR_Y1 n
          WHERE n.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
            AND n.MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
            AND n.ActivityMajor_CODE = @Lc_MajorActivityMapp_CODE
          ORDER BY MinorIntSeq_NUMB DESC;
         SET @Li_Rowcount_QNTY = @@ROWCOUNT;
         IF @Li_Rowcount_QNTY <> @Ln_Zero_NUMB
          BEGIN
           IF @Lc_ActivityMinor_CODE = @Lc_MinorActivityDocnm_CODE
              AND @Lc_Status_CODE = @Lc_MinorStatusStart_CODE
            BEGIN
             -- Call the update the minor activity procedure to move the activity chain
             EXECUTE BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
              @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
              @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
              @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
              @An_Forum_IDNO               = @Ln_Forum_IDNO,
              @An_Topic_IDNO               = @Ln_Topic_IDNO,
              @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
              @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
              @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
              @Ac_ActivityMinor_CODE       = @Lc_MinorActivityDocnm_CODE,
              @Ac_ReasonStatus_CODE        = @Lc_MinorReasonDescriptionPn_CODE,
              @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
              @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
              @Ad_Run_DATE                 = @Ld_Run_DATE,
              @Ac_Process_ID               = @Lc_Job_ID,
              @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
              @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
	
             IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
              BEGIN
               RAISERROR(50001,16,1);
              END
            END
           ELSE
            BEGIN
             -- Create the information alert to the worker
             EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
              @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
              @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
              @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
              @Ac_ActivityMinor_CODE       = @Lc_MinorActivityPfrfm_CODE,
              @As_DescriptionNote_TEXT     = @Ls_Note1_TEXT,  
              @Ac_Subsystem_CODE           = @Lc_SubsystemCt_CODE,
              @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
              @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
              @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
              @Ad_Run_DATE                 = @Ld_Run_DATE,
              @Ac_Job_ID                   = @Lc_Job_ID,
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
          END
        END
      END
    
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;  
       
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
