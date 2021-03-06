/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_ORDR$SP_PROCESS_ORDER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
----------------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_EST_INCOMING_FC_ORDR$SP_PROCESS_ORDER
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_EST_INCOMING_FC_ORDR$SP_PROCESS_ORDER deletes all the processed records from the intermediate 
					   table, reads petition response type records 'ORDR' from the intermediate table and record will be validated for any 
					   errors. If any errors found in the input record,the record will be moved to BATE table. and process indicator will 
					   be updated to 'Y'. If no errors found, the record will be kept in the intermediate table for worker view on the SORD 
					   screen for review and accepting the information into DECSS system.
Frequency			 : Daily
Developed On		 : 05/02/2011
Called By			 : None
Called On			 : BATCH_COMMON$SP_GET_BATCH_DETAILS,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_EST_INCOMING_FC_ORDER$SP_EMPLOYER_DETAILS,
					   BATCH_COMMON$SP_UPDATE_PARM_DATE,
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE,
					   BATCH_COMMON$SP_BATE_LOG,
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
----------------------------------------------------------------------------------------------------------------------------------------					   
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_ORDR$SP_PROCESS_ORDER]
AS
 BEGIN
  SET NOCOUNT ON;

  -- Common Variables
    DECLARE @Lc_StatusFailed_CODE							CHAR(1) = 'F',
            @Lc_Yes_INDC									CHAR(1) = 'Y',
            @Lc_ErrorTypeError_CODE							CHAR(1) = 'E',
            @Lc_CaseClientRelation_CODE						CHAR(1) = 'C',
            @Lc_CaseNcpRelation_CODE						CHAR(1) = 'A',
            @Lc_CasePfRelation_CODE                         CHAR(1) = 'P',
            @Lc_CaseRelationD_CODE							CHAR(1) = 'D',
            @Lc_CaseMemberActive_CODE						CHAR(1) = 'A',
            @Lc_TypeError_CODE								CHAR(1) = ' ',
            @Lc_CaseStatusOpen_CODE							CHAR(1) = 'O',
            @Lc_StatusSuccess_CODE							CHAR(1) = 'S',
            @Lc_StatusAbnormalend_CODE						CHAR(1) = 'A',
            @Lc_DocumentSourceF_CODE						CHAR(1) = 'F',
            @Lc_DocumentTypeO_CODE							CHAR(1) = 'O',
            @Lc_DocumentTypeP_CODE							CHAR(1) = 'P',
            @Lc_Note_INDC									CHAR(1) = 'N',
            @Lc_ValueN_CODE									CHAR(1) = 'N',
            @Lc_ValueY_CODE									CHAR(1) = 'Y',
            @Lc_CountyN_CODE								CHAR(1) = 'N',
            @Lc_CountyK_CODE								CHAR(1) = 'K',
            @Lc_CountyS_CODE								CHAR(1) = 'S',
            @Lc_ProcessL_CODE								CHAR(1) = 'L',
            @Lc_ValueS_CODE									CHAR(1)  = 'S',
            @Lc_ValueI_CODE									CHAR(1)  = 'I',
            @Lc_ValueJ_CODE									CHAR(1)  = 'J',
            @Lc_ValueH_CODE									CHAR(1)  = 'H',
            @Lc_ValueC_CODE									CHAR(1)  = 'C',
            @Lc_ValueD_CODE									CHAR(1)  = 'D',
            @Lc_Value1_CODE									CHAR(1) = '1',
            @Lc_Value2_CODE									CHAR(1) = '2',
            @Lc_Value3_CODE									CHAR(1) = '3',
            @Lc_HealthInsuranceA_CODE						CHAR(1) = 'A',
            @Lc_HealthInsuranceB_CODE						CHAR(1) = 'B',
            @Lc_HealthInsuranceF_CODE						CHAR(1) = 'F',
            @Lc_HealthInsuranceM_CODE						CHAR(1) = 'M',
            @Lc_HealthInsuranceN_CODE						CHAR(1) = 'N',
            @Lc_HealthInsuranceS_CODE						CHAR(1) = 'S',
            @Lc_DecssHealthInsuranceB_CODE					CHAR(1) = 'B',
            @Lc_DecssHealthInsuranceD_CODE					CHAR(1) = 'D',
            @Lc_DecssHealthInsuranceN_CODE					CHAR(1) = 'N',
            @Lc_DecssHealthInsuranceO_CODE					CHAR(1) = 'O',
            @Lc_DecssHealthInsuranceS_CODE					CHAR(1) = 'S',
            @Lc_DecssHealthInsuranceU_CODE					CHAR(1) = 'U',
            @Lc_FreqPeriodicM_CODE							CHAR(1) = 'M',
            @Lc_FreqPeriodicO_CODE							CHAR(1) = 'O',
            @Lc_TypeDebtCs_CODE								CHAR(2) = 'CS',
            @Lc_TypeDebtMs_CODE								CHAR(2) = 'MS',
            @Lc_TypeDebtSs_CODE								CHAR(2) = 'SS',
            @Lc_TypeDebtGt_CODE								CHAR(2) = 'GT',
            @Lc_RelationshipFtr_CODE						CHAR(3) = 'FTR',
            @Lc_RelationshipMtr_CODE						CHAR(3) = 'MTR',
            @Lc_SubsystemEst_CODE                           CHAR(3) = 'EST',
            @Lc_TableOabj_ID								CHAR(4) = 'OABJ',
            @Lc_TableOabc_ID								CHAR(4) = 'OABC',
            @Lc_TableSub_ID									CHAR(4) = 'FMIS',
            @Lc_MajorActivityCase_CODE						CHAR(4) = 'CASE',
            @Lc_PetitionTypeNoaa_CODE						CHAR(5) = 'NOAA',
            -- 13808 - Do not process duplicate orders received from the Family Court, write the record into BATE_Y1 and skip the record from processing - START -
            @Lc_ErrorE0145_CODE                             CHAR(5) = 'E0145',
            -- 13808 - Do not process duplicate orders received from the Family Court, write the record into BATE_Y1 and skip the record from processing - END -
            @Lc_ErrorE1380_CODE								CHAR(5) = 'E1380',
            @Lc_ErrorE1381_CODE								CHAR(5) = 'E1381',
            @Lc_ErrorE1382_CODE								CHAR(5) = 'E1382',
            @Lc_ErrorE1383_CODE								CHAR(5) = 'E1383',
            @Lc_ErrorE1384_CODE								CHAR(5) = 'E1384',
            @Lc_BateErrorE1424_CODE							CHAR (5) = 'E1424',
            @Lc_MinorActivityOrrff_CODE						CHAR(5) = 'ORRFF',
            @Lc_MinorActivityMorff_CODE                     CHAR(5) = 'MORFF',
            @Lc_MinorActivityConor_CODE                     CHAR(5) = 'CONOR',
            @Lc_JobProcessFcOrdr_ID							CHAR(7) = 'DEB8061',
            @Lc_Job_ID										CHAR(7) = 'DEB8061',
            @Lc_Successful_TEXT								CHAR(20) = 'SUCCESSFUL',
            @Lc_BatchRunUser_TEXT							CHAR(30) = 'BATCH',
            @Lc_Parmdateproblem_TEXT						CHAR(30) = 'PARM DATE PROBLEM',
            @Ls_Procedure_NAME								VARCHAR(100) = 'SP_PROCESS_ORDER',
            @Ls_Process_NAME								VARCHAR(100) = 'BATCH_EST_INCOMING_FC_ORDR',
            @Ld_High_DATE									DATE = '12/31/9999';
  DECLARE   @Ln_Zero_NUMB									NUMERIC(1) = 0,
		    @Ln_Exists_NUMB									NUMERIC(1) = 0,
		    @Ln_SeqEventFunctional_NUMB						NUMERIC(4,0) = 0,
            @Ln_Process_QNTY								NUMERIC(5,0) = 0,
            @Ln_Exception_QNTY								NUMERIC(5,0) = 0,
            @Ln_CommitFreq_QNTY								NUMERIC(5) = 0,
            @Ln_CommitFreqParm_QNTY							NUMERIC(5) = 0,
            @Ln_ExceptionThreshold_QNTY						NUMERIC(5) = 0,
            @Ln_ExceptionThresholdParm_QNTY					NUMERIC(5) = 0,
            @Ln_ProcessedRecordCount_QNTY					NUMERIC(6) = 0,
            @Ln_ProcessedRecordCountCommit_QNTY				NUMERIC(6) = 0,
            @Ln_Topic_IDNO									NUMERIC(10,0) = 0,
            @Ln_Cur_QNTY									NUMERIC(10,0) = 0,
            @Ln_Error_NUMB									NUMERIC(11),
            @Ln_ErrorLine_NUMB								NUMERIC(11),
            @Ln_TransactionEventSeq_NUMB					NUMERIC(19) = 0,
            @Li_FetchStatus_QNTY							SMALLINT,
            @Li_RowCount_QNTY								SMALLINT,
            -- 13808 - Do not process duplicate orders received from the Family Court, write the record into BATE_Y1 and skip the record from processing - START -
            @Li_FdemOrdrCount_QNTY							SMALLINT,
            @Li_PsrdOrdrCount_QNTY							SMALLINT,
            -- 13808 - Do not process duplicate orders received from the Family Court, write the record into BATE_Y1 and skip the record from processing - END -
            @Lc_Space_TEXT									CHAR(1) = ' ',
            @Lc_Error_CODE									CHAR(5) = ' ',
            @Lc_MinorActivity_CODE                          CHAR(5) = '',
            @Lc_BateError_CODE								CHAR(5) = '',
            @Lc_Msg_CODE									CHAR(5),
            @Lc_NcpRelationship_CODE						CHAR(3),
            @Lc_CpRelationship_CODE							CHAR(3),
            @Lc_PetitionActionFormat_DATE					CHAR(8) = '',
            @Lc_ArrearsEffectiveDate_TEXT                   CHAR(8) = '',
            @Ls_Sql_TEXT									VARCHAR(100) = '',
            @Ls_CursorLoc_TEXT								VARCHAR(200) = ' ',
            @Ls_Sqldata_TEXT								VARCHAR(1000) = '',
            @Ls_Record_TEXT									VARCHAR(3800) = '',
            @Ls_DescriptionError_TEXT						VARCHAR(4000) = '',
            @Ls_ErrorMessage_TEXT							VARCHAR(4000) = '',
            @Ls_Note_TEXT									VARCHAR(4000) = '',
            @Ls_BateRecord_TEXT								VARCHAR(4000) = '',
            @Ld_Run_DATE									DATE,
            @Ld_Start_DATE									DATETIME2,
            @Ld_LastRun_DATE								DATETIME2;

  -- Cursor variable declaration 
  DECLARE @Ln_FcOrderDetCur_Seq_IDNO						NUMERIC(19),
          @Lc_FcOrderDetCur_Rec_ID							CHAR(4),
          @Lc_FcOrderDetCur_PetitionIdno_TEXT				CHAR(7),
          @Lc_FcOrderDetCur_PetitionSequenceIdno_TEXT		CHAR(2),
          @Lc_FcOrderDetCur_CaseIdno_TEXT					CHAR(6),
          @Lc_FcOrderDetCur_PetitionType_CODE				CHAR(4),
          @Lc_FcOrderDetCur_PetitionActionDate_TEXT			CHAR(8),
          @Lc_FcOrderDetCur_FamilyCourtFile_ID				CHAR(10),
          @Lc_FcOrderDetCur_SupportOrderIdno_TEXT			CHAR(7),
          @Lc_FcOrderDetCur_HearingOfficer_ID				CHAR(9),
          @Lc_FcOrderDetCur_HearingDate_TEXT				CHAR(8),
          @Lc_FcOrderDetCur_ObligeeMciIdno_TEXT				CHAR(10),
          @Lc_FcOrderDetCur_ObligorMciIdno_TEXT				CHAR(10),
          @Lc_FcOrderDetCur_Form_ID							CHAR(3),
          @Lc_FcOrderDetCur_OrderStatus_CODE				CHAR(1),
          @Lc_FcOrderDetCur_PermanentOrder_INDC				CHAR(1),
          @Lc_FcOrderDetCur_DefaultOrder_INDC				CHAR(1),
          @Lc_FcOrderDetCur_IvdCase_INDC					CHAR(1),
          @Lc_FcOrderDetCur_WageAttachment_INDC				CHAR(1),
          @Lc_FcOrderDetCur_Payment_INDC					CHAR(1),
          @Lc_FcOrderDetCur_Contempt_INDC					CHAR(1),
          @Lc_FcOrderDetCur_EmployerProgam_INDC				CHAR(1),
          @Lc_FcOrderDetCur_Credit_CODE						CHAR(1),
          @Lc_FcOrderDetCur_Arrears_CODE					CHAR(2),
          @Lc_FcOrderDetCur_DocCommit_CODE					CHAR(1),
          @Lc_FcOrderDetCur_HealthInsurance_CODE			CHAR(1),
          @Lc_FcOrderDetCur_CalculationDeviation_CODE		CHAR(2),
          @Lc_FcOrderDetCur_CountyEmployerProgramIdno_TEXT	CHAR(1),
          @Lc_FcOrderDetCur_CurrentSupportAmnt_TEXT			CHAR(9),
          @Lc_FcOrderDetCur_ArrearsAmnt_TEXT				CHAR(9),
          @Lc_FcOrderDetCur_MedicalSupportAmnt_TEXT			CHAR(9),
          @Lc_FcOrderDetCur_SpousalSupportAmnt_TEXT			CHAR(9),
          @Lc_FcOrderDetCur_GeneticTestAmnt_TEXT			CHAR(9),
          @Lc_FcOrderDetCur_TotalObligationAmnt_TEXT		CHAR(10),
          @Lc_FcOrderDetCur_ArrearsBalanceAmnt_TEXT			CHAR(9),
          @Lc_FcOrderDetCur_TotalCreditAmnt_TEXT			CHAR(9),
          @Lc_FcOrderDetCur_ObligationEffectiveDate_TEXT	CHAR(8),
          @Lc_FcOrderDetCur_ArrearsEffectiveDate_TEXT		CHAR(8),
          @Lc_FcOrderDetCur_BalanceAsOfDate_TEXT			CHAR(8),
          @Lc_FcOrderDetCur_CreditEffectiveDate_TEXT		CHAR(8),
          @Lc_FcOrderDetCur_OutOfStateAgencyIdno_TEXT		CHAR(12),
          @Lc_FcOrderDetCur_ApprovedBy_ID					CHAR(7),
          @Lc_FcOrderDetCur_ApprovedDate_TEXT				CHAR(8), 
          @Lc_FcOrderDetCur_GeneticTestBalanceAmnt_TEXT		CHAR(9),
          @Lc_FcOrderDetCur_MedicalBalanceAmnt_TEXT			CHAR(9),
          @Lc_FcOrderDetCur_SpousalBalanceAmnt_TEXT			CHAR(9),
          @Lc_FcOrderDetCur_RelatedPetitionIdno_TEXT		CHAR(7),
          @Lc_FcOrderDetCur_OtherAmnt_TEXT					CHAR(9),
          @Lc_FcOrderDetCur_OtherAmountPurpose_TEXT			CHAR(40),
          @Ls_FcOrderDetCur_Detailed_TEXT					VARCHAR(4000),
          @Ln_FcOrderDetCur_Petition_IDNO					NUMERIC(7),
          @Ln_FcOrderDetCur_Case_IDNO						NUMERIC(6),
          @Ld_FcOrderDetCur_PetitionAction_DATE				DATE,
          @Ln_FcOrderDetCur_SupportOrder_IDNO				NUMERIC(7),
          @Ln_FcOrderDetCur_ObligeeMci_IDNO					NUMERIC(10),
          @Ln_FcOrderDetCur_ObligorMci_IDNO					NUMERIC(10),
          @Ln_FcOrderDetCur_CurrentSupport_AMNT				NUMERIC(11,2),
          @Ln_FcOrderDetCur_Arrears_AMNT					NUMERIC(11,2),
          @Ln_FcOrderDetCur_MedicalSupport_AMNT				NUMERIC(11,2),
          @Ln_FcOrderDetCur_SpousalSupport_AMNT				NUMERIC(11,2),
          @Ln_FcOrderDetCur_GeneticTest_AMNT				NUMERIC(11,2),
          @Ln_FcOrderDetCur_TotalObligation_AMNT			NUMERIC(11,2),
          @Ln_FcOrderDetCur_ArrearsBalance_AMNT				NUMERIC(11,2),
          @Ln_FcOrderDetCur_TotalCredit_AMNT				NUMERIC(11,2),
          @Ld_FcOrderDetCur_ObligationEffective_DATE		DATE,
          @Ld_FcOrderDetCur_ArrearsEffective_DATE			DATE,
          @Ld_FcOrderDetCur_Approved_DATE					DATE,
          @Ln_FcOrderDetCur_GeneticTestBalance_AMNT			NUMERIC(11,2),
          @Ln_FcOrderDetCur_MedicalBalance_AMNT				NUMERIC(11,2),
          @Ln_FcOrderDetCur_SpousalBalance_AMNT				NUMERIC(11,2),
          @Ln_FcOrderDetCur_Other_AMNT						NUMERIC(11,2);
  -- Cursor declaration for the order details from the temporary table 
  DECLARE FcOrderDet_Cur INSENSITIVE CURSOR FOR
   SELECT a.Seq_IDNO,
          a.Rec_ID,
          a.Petition_IDNO,
          a.PetitionSequence_IDNO,
          a.Case_IDNO,
          a.PetitionType_CODE,
          a.PetitionAction_DATE,
          a.FamilyCourtFile_ID,
          a.SupportOrder_IDNO,
          a.HearingOfficer_ID,
          a.Hearing_DATE,
          a.ObligeeMCI_IDNO,
          a.ObligorMci_IDNO,
          a.Form_ID,
          a.OrderStatus_CODE,
          a.PermanentOrder_INDC,
          a.DefaultOrder_INDC,
          a.IvdCase_INDC,
          a.WageAttachment_INDC,
          a.Payment_INDC,
          a.Contempt_INDC,
          a.EmployerProgam_INDC,
          a.Credit_CODE,
          a.Arrears_CODE,
          a.DocCommit_CODE,
          a.HealthInsurance_CODE,
          a.CalculationDeviation_CODE,
          a.CountyEmployerProgram_IDNO,
          a.CurrentSupport_AMNT,
          a.Arrears_AMNT,
          a.MedicalSupport_AMNT,
          a.SpousalSupport_AMNT,
          a.GeneticTest_AMNT,
          a.TotalObligation_AMNT,
          a.ArrearsBalance_AMNT,
          a.TotalCredit_AMNT,
          a.ObligationEffective_DATE,
          a.ArrearsEffective_DATE,
          a.BalanceAsOf_DATE,
          a.CreditEffective_DATE,
          a.OutOfStateAgency_IDNO,
          a.ApprovedBy_ID,
          a.Approved_DATE,
          a.GeneticTestBalance_AMNT,
          a.MedicalBalance_AMNT,
          a.SpousalBalance_AMNT,
          a.RelatedPetition_IDNO,
          a.Other_AMNT,
          a.OtherAmountPurpose_TEXT,
          a.detailed_TEXT
     FROM LFORD_Y1 a
    WHERE (a.Process_INDC = 'N'
      AND ((a.IvdCase_INDC = 'N'
      AND  a.Case_IDNO > 0)
      OR  (a.IvdCase_INDC = 'Y')))
    ORDER BY Seq_IDNO;

  BEGIN TRY
   
   SET @Ln_Cur_QNTY = ISNULL(@Ln_Cur_QNTY, 0);
   SET @Lc_Job_ID = @Lc_JobProcessFcOrdr_ID;
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   -- Selecting the Batch Start Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
   -- Selecting date run, date last run, commit freq, exception threshold details --
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   -- Validation 1:Check Whether the Job ran already on same day   
   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Lc_Parmdateproblem_TEXT;

     RAISERROR(50001,16,1);
    END

   -- Transaction begins 
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = '';
   BEGIN TRANSACTION FCORDR_BATCH_DETAILS;
   -- Call the sp which processes the employer records in the order information from the Family Court 
   SET @Ls_Sql_TEXT = 'BATCH_EST_INCOMING_FC_ORDER$SP_EMPLOYER_DETAILS';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
  
   EXECUTE BATCH_EST_INCOMING_FC_ORDR$SP_EMPLOYER_DETAILS
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @As_Process_NAME          = @Ls_Process_NAME,
    @An_Process_QNTY          = @Ln_Process_QNTY OUTPUT,
    @An_Exception_QNTY        = @Ln_Exception_QNTY OUTPUT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     
     RAISERROR(50001,16,1);
    END
  
   SET @Ln_CommitFreq_QNTY = @Ln_Zero_NUMB;
   SET @Ln_ExceptionThreshold_QNTY = @Ln_Zero_NUMB;
   SET @Ln_Cur_QNTY = @Ln_Zero_NUMB;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;
   SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + @Ln_Process_QNTY;
   SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + @Ln_Exception_QNTY;
   SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
   SET @Ls_Sql_TEXT = 'OPENING FAMILY COURT ORDER DETAILS CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   OPEN FcOrderDet_Cur;

   SET @Ls_Sql_TEXT = 'FETCHING FAMILY COURT ORDER DETAILS CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   FETCH NEXT FROM FcOrderDet_Cur INTO @Ln_FcOrderDetCur_Seq_IDNO, @Lc_FcOrderDetCur_Rec_ID, @Lc_FcOrderDetCur_PetitionIdno_TEXT, @Lc_FcOrderDetCur_PetitionSequenceIdno_Text, @Lc_FcOrderDetCur_CaseIdno_TEXT, @Lc_FcOrderDetCur_PetitionType_CODE, @Lc_FcOrderDetCur_PetitionActionDate_TEXT, @Lc_FcOrderDetCur_FamilyCourtFile_ID, @Lc_FcOrderDetCur_SupportOrderIdno_TEXT, @Lc_FcOrderDetCur_HearingOfficer_ID, @Lc_FcOrderDetCur_HearingDate_TEXT, @Lc_FcOrderDetCur_ObligeeMciIdno_TEXT, @Lc_FcOrderDetCur_ObligorMciIdno_TEXT, @Lc_FcOrderDetCur_Form_ID, @Lc_FcOrderDetCur_OrderStatus_CODE, @Lc_FcOrderDetCur_PermanentOrder_INDC, @Lc_FcOrderDetCur_DefaultOrder_INDC, @Lc_FcOrderDetCur_IvdCase_INDC, @Lc_FcOrderDetCur_WageAttachment_INDC, @Lc_FcOrderDetCur_Payment_INDC, @Lc_FcOrderDetCur_Contempt_INDC, @Lc_FcOrderDetCur_EmployerProgam_INDC, @Lc_FcOrderDetCur_Credit_CODE, @Lc_FcOrderDetCur_Arrears_CODE, @Lc_FcOrderDetCur_DocCommit_CODE, @Lc_FcOrderDetCur_HealthInsurance_CODE, @Lc_FcOrderDetCur_CalculationDeviation_CODE, @Lc_FcOrderDetCur_CountyEmployerProgramIdno_TEXT, @Lc_FcOrderDetCur_CurrentSupportAmnt_TEXT, @Lc_FcOrderDetCur_ArrearsAmnt_TEXT, @Lc_FcOrderDetCur_MedicalSupportAmnt_TEXT, @Lc_FcOrderDetCur_SpousalSupportAmnt_TEXT, @Lc_FcOrderDetCur_GeneticTestAmnt_TEXT, @Lc_FcOrderDetCur_TotalObligationAmnt_TEXT, @Lc_FcOrderDetCur_ArrearsBalanceAmnt_TEXT, @Lc_FcOrderDetCur_TotalCreditAmnt_TEXT, @Lc_FcOrderDetCur_ObligationEffectiveDate_TEXT, @Lc_FcOrderDetCur_ArrearsEffectiveDate_TEXT, @Lc_FcOrderDetCur_BalanceAsOfDate_TEXT, @Lc_FcOrderDetCur_CreditEffectiveDate_TEXT, @Lc_FcOrderDetCur_OutOfStateAgencyIdno_TEXT, @Lc_FcOrderDetCur_ApprovedBy_ID, @Lc_FcOrderDetCur_ApprovedDate_TEXT, @Lc_FcOrderDetCur_GeneticTestBalanceAmnt_TEXT, @Lc_FcOrderDetCur_MedicalBalanceAmnt_TEXT, @Lc_FcOrderDetCur_SpousalBalanceAmnt_TEXT, @Lc_FcOrderDetCur_RelatedPetitionIdno_TEXT, @Lc_FcOrderDetCur_OtherAmnt_TEXT, @Lc_FcOrderDetCur_OtherAmountPurpose_TEXT,@Ls_FcOrderDetCur_Detailed_TEXT;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process the order records in the load table
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
	 SAVE TRANSACTION SAVEFCORDR_BATCH_DETAILS;
     SET @Lc_TypeError_CODE = '';
     SET @Lc_Error_CODE     = @Lc_BateErrorE1424_CODE;
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Ls_Sql_TEXT = '';
     SET @Lc_ArrearsEffectiveDate_TEXT = '';
     SET @Ls_Sqldata_TEXT = 'FcRecordType_ID = ' + ISNULL(@Lc_FcOrderDetCur_Rec_ID, '') + ', FcPetion_IDNO = ' + ISNULL(@Lc_FcOrderDetCur_PetitionIdno_TEXT, '') + ', FcCase_IDNO = ' + ISNULL(@Lc_FcOrderDetCur_CaseIdno_TEXT, '') + ', FcPetitionType_CODE = ' + ISNULL(@Lc_FcOrderDetCur_PetitionType_CODE, '') + ', FcFile_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_FamilyCourtFile_ID, '');
     SET @Ls_BateRecord_TEXT = ' Rec_ID = ' + ISNULL(@Lc_FcOrderDetCur_Rec_ID, '') + ', Petition_IDNO = ' + ISNULL(@Lc_FcOrderDetCur_PetitionIdno_TEXT, '') + ', PetitionSequence_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_PetitionSequenceIdno_Text, ' ') + ', Case_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_CaseIdno_TEXT, '') + ', PetitionType_CODE = ' + ISNULL (@Lc_FcOrderDetCur_PetitionType_CODE, '') + ', PetitionAction_DATE = ' + ISNULL (@Lc_FcOrderDetCur_PetitionActionDate_TEXT, '') + ', FamilyCourtFile_ID = ' + ISNULL (@Lc_FcOrderDetCur_FamilyCourtFile_ID, '') + ', SupportOrder_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_SupportOrderIdno_TEXT, '') + ', HearingOfficer_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_HearingOfficer_ID, '') + ', Hearing_DATE = ' + ISNULL (@Lc_FcOrderDetCur_HearingDate_TEXT, '') + ', ClientMci_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_ObligeeMciIdno_TEXT, '') + ', NcpMci_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_ObligorMciIdno_TEXT, '') + ', Form_ID = ' + ISNULL (@Lc_FcOrderDetCur_Form_ID, '') + ', OrderStatus_CODE = ' + ISNULL (@Lc_FcOrderDetCur_OrderStatus_CODE, '') + ', PermanentOrder_INDC = ' + ISNULL (@Lc_FcOrderDetCur_PermanentOrder_INDC, '') + ', DefaultOrder_INDC = ' + ISNULL (@Lc_FcOrderDetCur_DefaultOrder_INDC, '') + ', IvdCase_INDC = ' + ISNULL (@Lc_FcOrderDetCur_IvdCase_INDC, '') + ', WageAttachment_INDC = ' + ISNULL (@Lc_FcOrderDetCur_WageAttachment_INDC, '') + ', Payment_INDC = ' + ISNULL (@Lc_FcOrderDetCur_Payment_INDC, '') + ', Contempt_INDC = ' + ISNULL (@Lc_FcOrderDetCur_Contempt_INDC, '') + ', EmployerProgram_INDC = ' + ISNULL (@Lc_FcOrderDetCur_EmployerProgam_INDC, '') + ', CreditAmount_INDC = ' + ISNULL (@Lc_FcOrderDetCur_Credit_CODE, '') + ', CurrentArrears_INDC = ' + ISNULL (@Lc_FcOrderDetCur_Arrears_CODE, '') + ', NcpCommitDoc_INDC = ' + ISNULL (@Lc_FcOrderDetCur_DocCommit_CODE, '') + ', HealthInsurance_INDC = ' + ISNULL (@Lc_FcOrderDetCur_HealthInsurance_CODE, '') + ', CalculationDeviation_CODE = ' + ISNULL (@Lc_FcOrderDetCur_CalculationDeviation_CODE, '') + ', CountyEmployerProgram_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_CountyEmployerProgramIdno_TEXT, '') + ', CurrentSupport_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_CurrentSupportAmnt_TEXT, '') + ', Arrears_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_ArrearsAmnt_TEXT, '') + ', MedicalSupport_Amnt = ' + ISNULL (@Lc_FcOrderDetCur_MedicalSupportAmnt_TEXT, '') + ', SpousalSupport_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_SpousalSupportAmnt_TEXT, '') + ', GeneticTest_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_GeneticTestAmnt_TEXT, '') + ', TotalObligation_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_TotalObligationAmnt_TEXT, '') + ', ArrearsBalance_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_ArrearsBalanceAmnt_TEXT, '') + ', TotalCredit_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_TotalCreditAmnt_TEXT, '') + ', ObligationEffective_DATE = ' + ISNULL (@Lc_FcOrderDetCur_ObligationEffectiveDate_TEXT, '') + ', ArrearsEffective_DATE = ' + ISNULL (@Lc_FcOrderDetCur_ArrearsEffectiveDate_TEXT, '') + ', BalanceAsOf_DATE = ' + ISNULL (@Lc_FcOrderDetCur_BalanceAsOfDate_Text, '') + ', CreditEffective_DATE = ' + ISNULL (@Lc_FcOrderDetCur_CreditEffectiveDate_TEXT, '') + ', OutOfStateAgency_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_OutOfStateAgencyIdno_TEXT, '') + ', AppovedBy_CODE = ' + ISNULL (@Lc_FcOrderDetCur_ApprovedBy_ID, '') + ', ApprovedBy_DATE = ' + ISNULL (@Lc_FcOrderDetCur_ApprovedDate_TEXT, '') + ', GeneticTestBalance_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_GeneticTestBalanceAmnt_TEXT, '') + ', MedicalBalance_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_MedicalBalanceAmnt_TEXT, '') + ', SpousalBalance_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_SpousalBalanceAmnt_TEXT, '') + ', RelatedPetition_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_RelatedPetitionIdno_TEXT, '') + ', Other_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_OtherAmnt_TEXT, '') + ', OtherAmountPurpose_TEXT = ' + ISNULL (@Lc_FcOrderDetCur_OtherAmountPurpose_TEXT, '');

     --If the case idno number is not numeric, generate an error message
     IF ISNUMERIC (@Lc_FcOrderDetCur_CaseIdno_TEXT) = 1
		BEGIN 
			SET @Ln_FcOrderDetCur_Case_IDNO = @Lc_FcOrderDetCur_CaseIdno_TEXT;
		END
	 ELSE
		BEGIN
			
			SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
			SET @Lc_Error_CODE = @Lc_ErrorE1381_CODE; 
			GOTO lx_exception;
        END
		
     --If the petition idno is not a valid value, generate an error into BATE_Y1 and skip the record
     IF ISNUMERIC (@Lc_FcOrderDetCur_PetitionIdno_TEXT) <> 1
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_Error_CODE = @Lc_ErrorE1380_CODE; 
       GOTO lx_exception;
	  END
     ELSE
	  BEGIN 
		SET @Ln_FcOrderDetCur_Petition_IDNO = @Lc_FcOrderDetCur_PetitionIdno_TEXT;	  
      END
     
     IF @Ln_FcOrderDetCur_Petition_IDNO = 0
		BEGIN 
		 SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
		 SET @Lc_Error_CODE = @Lc_ErrorE1380_CODE; 
         GOTO lx_exception;
        END
     ELSE
		BEGIN 
		  SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
		    FROM FDEM_Y1
		   WHERE Case_IDNO = @Ln_FcOrderDetCur_Case_IDNO
		     AND Petition_IDNO = @Ln_FcOrderDetCur_Petition_IDNO;
		   IF @Ln_Exists_NUMB = 0
		   AND @Lc_FcOrderDetCur_IvdCase_INDC = @Lc_ValueY_CODE
			BEGIN
			  SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
			  SET @Lc_Error_CODE = @Lc_ErrorE1380_CODE; 
			  GOTO lx_exception;
			END
        END   
        
       SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
         FROM CASE_Y1 a
        WHERE Case_IDNO = @Ln_FcOrderDetCur_Case_IDNO
          AND StatusCase_CODE = @Lc_CaseStatusOpen_CODE; 

       IF @Ln_Exists_NUMB = 0
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_Error_CODE = @Lc_ErrorE1381_CODE; 
         GOTO lx_exception;
        END
     
     -- Case number and client Mci is not found, generate an error into BATE_Y1, skip the record
     IF ISNUMERIC (@Lc_FcOrderDetCur_ObligeeMciIdno_TEXT) <> 1
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_Error_CODE = @Lc_ErrorE1382_CODE;

       GOTO lx_exception;
      END
     ELSE
      BEGIN
       SET @Ln_FcOrderDetCur_ObligeeMci_IDNO = @Lc_FcOrderDetCur_ObligeeMciIdno_TEXT;
       SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
         FROM CMEM_Y1 c
        WHERE Case_IDNO = @Ln_FcOrderDetCur_Case_IDNO
          AND CaseRelationship_CODE = @Lc_CaseClientRelation_CODE
          AND CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE
          AND MemberMci_IDNO		= @Ln_FcOrderDetCur_ObligeeMci_IDNO;

       IF @Ln_Exists_NUMB = 0
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_Error_CODE = @Lc_ErrorE1382_CODE;  
         GOTO lx_exception;
        END
      END

     -- Case number and ncp Mci is not found, generate an error into BATE_Y1, skip the record
     IF ISNUMERIC (@Lc_FcOrderDetCur_ObligorMciIdno_TEXT) <> 1
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_Error_CODE = @Lc_ErrorE1383_CODE;  
       GOTO lx_exception;
      END
     ELSE
      BEGIN
       SET @Ln_FcOrderDetCur_ObligorMci_IDNO = @Lc_FcOrderDetCur_ObligorMciIdno_TEXT;
       SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
         FROM CMEM_Y1 c
        WHERE Case_IDNO = @Ln_FcOrderDetCur_Case_IDNO
          AND CaseRelationship_CODE IN  (@Lc_CaseNcpRelation_CODE, @Lc_CasePfRelation_CODE)
          AND CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE
          AND MemberMci_IDNO		= @Ln_FcOrderDetCur_ObligorMci_IDNO;

       IF @Ln_Exists_NUMB = 0
       
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_Error_CODE = @Lc_ErrorE1383_CODE;

         GOTO lx_exception;
        END
      END

     -- If the order status is not 'O', generate an error into BATE_Y1 table and skip the record
     
     IF ISNULL(@Lc_FcOrderDetCur_OrderStatus_CODE, '') <> 'O'
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_Error_CODE = @Lc_ErrorE1384_CODE;

       GOTO lx_exception;
      END
      
     IF ISNUMERIC (@Lc_FcOrderDetCur_SupportOrderIdno_TEXT) <> 1 
		BEGIN 
			SET @Ln_FcOrderDetCur_SupportOrder_IDNO = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcOrderDetCur_SupportOrder_IDNO = @Lc_FcOrderDetCur_SupportOrderIdno_TEXT;
		END
     
	 -- 13808 - Do not process duplicate orders received from the Family Court, write the record into BATE_Y1 and skip the record from processing - START -
	 SET @Li_FdemOrdrCount_QNTY = @Ln_Zero_NUMB;
	 SET @Li_PsrdOrdrCount_QNTY = @Ln_Zero_NUMB;
	 
     SET @Ls_Sql_TEXT = 'READING FEDM_Y1 TABLE ';
     SET @Ls_Sqldata_TEXT = 'Case Number = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + '  ' + 'Order Number = ' + CAST(@Ln_FcOrderDetCur_SupportOrder_IDNO AS VARCHAR);
     SELECT @Li_FdemOrdrCount_QNTY = COUNT(1)
         FROM FDEM_Y1 
         WHERE Case_IDNO =  @Ln_FcOrderDetCur_Case_IDNO
           AND Order_IDNO = @Ln_FcOrderDetCur_SupportOrder_IDNO
           AND EndValidity_DATE = @Ld_High_DATE;
     
     SET @Ls_Sql_TEXT = 'READING PSRD_Y1 TABLE ';
     SET @Ls_Sqldata_TEXT = 'Case Number = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + '  ' + 'Order Number = ' + CAST(@Ln_FcOrderDetCur_SupportOrder_IDNO AS VARCHAR);
     SELECT @Li_PsrdOrdrCount_QNTY = COUNT(1)
         FROM PSRD_Y1 
         WHERE Case_IDNO = @Ln_FcOrderDetCur_Case_IDNO
           AND Order_IDNO = @Ln_FcOrderDetCur_SupportOrder_IDNO;
           
     IF  (@Li_FdemOrdrCount_QNTY <> @Ln_Zero_NUMB OR
         @Li_PsrdOrdrCount_QNTY <> @Ln_Zero_NUMB)
         BEGIN
          SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
		  SET @Lc_Error_CODE = @Lc_ErrorE0145_CODE;
          GOTO lx_exception;
         END      
	 -- 13808 - Do not process duplicate orders received from the Family Court, write the record into BATE_Y1 and skip the record from processing - END -
	 
	 -- Based on the discussion with Soujanya, Bob and Dinesh, the order batch will insert two fdem records for non iv-d cases from the family Court and one fdem
     -- record for the other orders 
     
	 -- Get the transaction next sequence number 
	 SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 3';
     SET @Ls_Sqldata_TEXT = 'Job Number = ' + @Lc_Job_ID;

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
		 @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_Note_INDC,
         @An_EventFunctionalSeq_NUMB  = @Ln_SeqEventFunctional_NUMB,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
           RAISERROR(50001,16,1);
        END
	 --Convert the petition action date in CCYYMMDD format from the incoming MMDDCCYY format        
      
     SET @Lc_PetitionActionFormat_DATE = SUBSTRING(@Lc_FcOrderDetCur_PetitionActionDate_TEXT, 5, 4) + LEFT(@Lc_FcOrderDetCur_PetitionActionDate_TEXT,2) + SUBSTRING(@Lc_FcOrderDetCur_PetitionActionDate_TEXT, 3, 2);
     SET @Ld_FcOrderDetCur_PetitionAction_DATE = @Lc_PetitionActionFormat_DATE;
     
     -- Convert the approved date into ccyymmdd format from the load table column
     SET @Ld_FcOrderDetCur_Approved_DATE = SUBSTRING(@Lc_FcOrderDetCur_ApprovedDate_TEXT, 5,4) + LEFT(@Lc_FcOrderDetCur_ApprovedDate_TEXT, 2) + SUBSTRING(@Lc_FcOrderDetCur_ApprovedDate_TEXT, 3, 2);
     -- Bug 13219, create FDEM record only if there is a valid record exist in FDEM_y1 table for Case number and File Number for the received order record.
     -- Bug 13219 Start
     SET @Ls_Sql_TEXT = 'READING FDEM_Y1 TABLE ';
     SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;
     SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
       FROM FDEM_Y1 f
      WHERE f.Case_idno			= @Ln_FcOrderDetCur_Case_IDNO
        AND f.File_ID			= @Lc_FcOrderDetCur_FamilyCourtFile_ID
        AND f.EndValidity_DATE	= @Ld_High_DATE;
     IF @Ln_Exists_NUMB <> @Ln_Zero_NUMB
       BEGIN 
     -- End Bug 13219    
		SET @Ls_Sql_TEXT = 'INSERT ORDER RECORD INTO FDEM_Y1 TABLE ';
		SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;

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
                      MajorIntSeq_NUMB,
                      MinorIntSeq_NUMB) 
              
              SELECT   @Ln_FcOrderDetCur_Case_IDNO AS Case_IDNO,
                       @Lc_FcOrderDetCur_FamilyCourtFile_ID AS File_ID ,
                       @Lc_FcOrderDetCur_Form_ID AS DocReference_CODE,
                       @Lc_DocumentTypeO_CODE AS TypeDoc_CODE,
                       @Lc_DocumentSourceF_CODE AS SourceDoc_CODE,
                       @Ld_FcOrderDetCur_Approved_DATE AS Filed_DATE, 
                       @Ld_Run_DATE AS BeginValidity_DATE,
                       @Ld_High_DATE AS EndValidity_DATE,
                       @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                       @Ld_Start_DATE AS Update_DTTM, 
                       @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                       @Lc_ValueY_CODE AS FdemDisplay_INDC,
                       ISNULL((SELECT TOP 1 LTRIM(RTRIM(DescriptionValue_TEXT))
						                 FROM REFM_Y1 r
						                 WHERE Table_ID = @Lc_TableOabc_ID 
										   AND TableSub_ID = @Lc_TableSub_ID  
										   AND Value_CODE = @Lc_FcOrderDetCur_ApprovedBy_ID), (ISNULL((SELECT TOP 1 LTRIM(RTRIM(DescriptionValue_TEXT))
						                 FROM REFM_Y1 r
						                 WHERE Table_ID = @Lc_TableOabj_ID 
										   AND TableSub_ID = @Lc_TableSub_ID  
										   AND Value_CODE = @Lc_FcOrderDetCur_ApprovedBy_ID), ''))) AS ApprovedBy_CODE,
                       @Ln_FcOrderDetCur_ObligeeMci_IDNO AS Petitioner_IDNO,
                       @Ln_FcOrderDetCur_ObligorMci_IDNO AS Respondent_IDNO,
                       @Ln_FcOrderDetCur_Petition_IDNO AS Petition_IDNO,
                       @Ln_FcOrderDetCur_SupportOrder_IDNO AS Order_IDNO,  
                       @Ln_Zero_NUMB AS MajorIntSeq_NUMB,
                       @Ln_Zero_NUMB AS MinorIntSeq_NUMB;  
         
         SET @Li_Rowcount_QNTY = @@ROWCOUNT;
                           
         IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
          BEGIN
           SET @Ls_DescriptionError_TEXT = 'FDEM_Y1 INSERT FAILED ';
           RAISERROR(50001,16,1);
          END
       -- Bug 13219 Start
       END
       -- Bug 13219 End 
     -- Check for non iv-d case 
     SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO FDEM_Y1 TABLE FOR NON IV-D CASE';
     SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;
	 IF @Lc_FcOrderDetCur_IvdCase_INDC = @Lc_ValueN_CODE
	   BEGIN 
	    SELECT @Ln_Exists_NUMB = COUNT(1)
	      FROM FDEM_Y1 f
	      WHERE f.Case_IDNO			= @Ln_FcOrderDetCur_Case_IDNO
	        AND f.TypeDoc_CODE		= @Lc_DocumentTypeP_CODE
	        AND f.Petition_IDNO     = @Ln_FcOrderDetCur_Petition_IDNO;
	    
	    IF @Ln_Exists_NUMB = 0    
		 BEGIN
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
                      MajorIntSeq_NUMB,
                      MinorIntSeq_NUMB) 
              
              SELECT   @Ln_FcOrderDetCur_Case_IDNO AS Case_IDNO,
                       @Lc_FcOrderDetCur_FamilyCourtFile_ID AS File_ID ,
                       @Lc_FcOrderDetCur_PetitionType_CODE AS DocReference_CODE,
                       @Lc_DocumentTypeP_CODE AS TypeDoc_CODE,
                       @Lc_DocumentSourceF_CODE AS SourceDoc_CODE,
                       @Ld_FcOrderDetCur_PetitionAction_DATE AS Filed_DATE, 
                       @Ld_Run_DATE AS BeginValidity_DATE,
                       @Ld_High_DATE AS EndValidity_DATE,
                       @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                       @Ld_Start_DATE AS Update_DTTM, 
                       @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                       @Lc_ValueY_CODE AS FdemDisplay_INDC,
                       @Lc_Space_TEXT AS ApprovedBy_CODE,
                       @Ln_FcOrderDetCur_ObligeeMci_IDNO AS Petitioner_IDNO,
                       @Ln_FcOrderDetCur_ObligorMci_IDNO AS Respondent_IDNO,
                       @Ln_FcOrderDetCur_Petition_IDNO AS Petition_IDNO,
                       @Ln_Zero_NUMB AS Order_IDNO,  
                       @Ln_Zero_NUMB AS MajorIntSeq_NUMB,
                       @Ln_Zero_NUMB AS MinorIntSeq_NUMB;  
         
			SET @Li_Rowcount_QNTY = @@ROWCOUNT;
                          
			IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				BEGIN
					SET @Ls_DescriptionError_TEXT = 'FDEM_Y1 INSERT FAILED ';
					RAISERROR(50001,16,1);
				END 
		 END
	   END
     -- Insert one record for pending sord      
     -- Insert into PSRD_Y1 
	 SET @Ls_Note_TEXT = '';
	 IF LTRIM(RTRIM(@Ls_FcOrderDetCur_Detailed_TEXT)) <> ''	
		BEGIN 
			SET @Ls_Note_TEXT  = 'The following are additional notes that were entered in FAMIS: ' + LTRIM(RTRIM(@Ls_FcOrderDetCur_Detailed_TEXT)) + '<BR/>' + '<BR/>';
		END
	 IF @Lc_FcOrderDetCur_HearingOfficer_ID <> ''
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' A hearing was held on ' +  @Lc_FcOrderDetCur_HearingDate_TEXT + ' before ' + LTRIM(RTRIM(@Lc_FcOrderDetCur_HearingOfficer_ID)) + '.' + '<BR/>' + '<BR/>' ;
		END 
	 
	 IF @Lc_FcOrderDetCur_Contempt_INDC = @Lc_ValueN_CODE 
		BEGIN 
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The Respondent was not found in Contempt.' + '<BR/>' + '<BR/>';
		END
	 ELSE
		IF @Lc_FcOrderDetCur_Contempt_INDC = @Lc_ValueY_CODE
			BEGIN	
				SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The Respondent was found in Contempt.' + '<BR/>' + '<BR/>';
			END
     
     IF @Lc_FcOrderDetCur_EmployerProgam_INDC = @Lc_ValueY_CODE
		BEGIN
			IF @Lc_FcOrderDetCur_CountyEmployerProgramIdno_TEXT = @Lc_CountyK_CODE
				BEGIN
					SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The 90 Day Employer Program has been ordered in Kent County.' + '<BR/>' + '<BR/>';
				END
			ELSE IF @Lc_FcOrderDetCur_CountyEmployerProgramIdno_TEXT = @Lc_CountyN_CODE
				BEGIN
					SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The 90 Day Employer Program has been ordered in New Castle County.' + '<BR/>' + '<BR/>';
				END
			ELSE IF @Lc_FcOrderDetCur_CountyEmployerProgramIdno_TEXT = @Lc_CountyS_CODE
				BEGIN
					SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The 90 Day Employer Program has been ordered in Sussex County.' + '<BR/>' + '<BR/>';
				END
		END
		
	 IF @Lc_FcOrderDetCur_Credit_CODE = @Lc_value1_CODE
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The total credit amount is per the DCSE Account Statement.' + '<BR/>' + '<BR/>';
		END
	 ELSE IF @Lc_FcOrderDetCur_Credit_CODE = @Lc_value2_CODE
		BEGIN 
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The total credit amount is established in this order.' + '<BR/>' + '<BR/>';
		END
	ELSE IF @Lc_FcOrderDetCur_Credit_CODE = @Lc_value3_CODE
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The total credit amount is to be calculated by DCSE.' + '<BR/>' + '<BR/>';
		END
	
	 IF @Lc_FcOrderDetCur_Arrears_CODE = @Lc_value1_CODE
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The total arrears amount is per the DCSE Account Statement.' + '<BR/>' + '<BR/>';
		END
	ELSE IF @Lc_FcOrderDetCur_Arrears_CODE = @Lc_Value2_CODE
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The total arrears amount is established in this order.' + '<BR/>' + '<BR/>';
		END
	ELSE IF @Lc_FcOrderDetCur_Arrears_CODE = @Lc_value3_CODE
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The total arrears amount is to be calculated by DCSE.' + '<BR/>' + '<BR/>';
		END
	 IF @Lc_FcOrderDetCur_DocCommit_CODE = @Lc_ValueS_CODE 
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The NCP’s commitment to the Department of Corrections has been suspended.' + '<BR/>' + '<BR/>';
		END
	 ELSE IF @Lc_FcOrderDetCur_DocCommit_CODE = @Lc_ValueC_CODE
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The NCP has had a Commitment to the Department of Corrections ordered.' + '<BR/>' + '<BR/>';
		END
     IF ISNUMERIC(@Lc_FcOrderDetCur_TotalObligationAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_TotalObligation_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_TotalObligation_AMNT = @Lc_FcOrderDetCur_TotalObligationAmnt_TEXT;
		END
     IF @Ln_FcOrderDetCur_TotalObligation_AMNT > 0 
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The total monthly support obligation amount was set to = ' + CAST(@Ln_FcOrderDetCur_TotalObligation_AMNT AS VARCHAR) + '.' + '<BR/>' + '<BR/>';
		END
	 
	 IF ISNUMERIC (@Lc_FcOrderDetCur_ArrearsBalanceAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_ArrearsBalance_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_ArrearsBalance_AMNT = @Lc_FcOrderDetCur_ArrearsBalanceAmnt_TEXT;
		END
	 
	 IF @Ln_FcOrderDetCur_ArrearsBalance_AMNT > 0 
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' Obligation data received from the FAMIS order indicates that: As of the date the order was created the arrears balance was set to = ' + CAST(@Ln_FcOrderDetCur_ArrearsBalance_AMNT AS VARCHAR) + '.' + '<BR/>' + '<BR/>';
		END 
     
     IF ISNUMERIC (@Lc_FcOrderDetCur_TotalCreditAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_TotalCredit_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_TotalCredit_AMNT = @Lc_FcOrderDetCur_TotalCreditAmnt_TEXT;
		END
	 IF @Ln_FcOrderDetCur_TotalCredit_AMNT > 0 
		OR ISNULL (@Lc_FcOrderDetCur_CreditEffectiveDate_TEXT, '') <> ''
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The NCP was credited a total of ' + CAST(@Ln_FcOrderDetCur_TotalCredit_AMNT AS VARCHAR) + ' on ' + @Lc_FcOrderDetCur_CreditEffectiveDate_TEXT + '. The balances have been calculated as of ' + @Lc_FcOrderDetCur_BalanceAsOfDate_TEXT + '.' + '<BR/>' + '<BR/>';
		END
		
	 IF ISNUMERIC(@Lc_FcOrderDetCur_MedicalBalanceAmnt_TEXT) <> 1
		BEGIN
			SET @Ln_FcOrderDetCur_MedicalBalance_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_MedicalBalance_AMNT = @Lc_FcOrderDetCur_MedicalBalanceAmnt_TEXT;
		END
		
	 IF @Ln_FcOrderDetCur_MedicalBalance_AMNT > 0
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The arrears owed towards the child’s medical expenses as been set at: ' + CAST(@Ln_FcOrderDetCur_MedicalBalance_AMNT AS VARCHAR) + '.' + '<BR/>' + '<BR/>';
		END
		
     IF ISNUMERIC(@Lc_FcOrderDetCur_SpousalBalanceAmnt_TEXT) <> 1
		BEGIN
			SET @Ln_FcOrderDetCur_SpousalBalance_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_SpousalBalance_AMNT = @Lc_FcOrderDetCur_SpousalBalanceAmnt_TEXT;
		END
	 IF @Ln_FcOrderDetCur_SpousalBalance_AMNT > 0 
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The arrears owed towards spousal support have been set at: ' + CAST(@Ln_FcOrderDetCur_SpousalBalance_AMNT AS VARCHAR) + '.' + '<BR/>' + '<BR/>';
		END
	 IF ISNULL (@Lc_FcOrderDetCur_RelatedPetitionIdno_TEXT, '') <> ''
	    AND    CAST(@Lc_FcOrderDetCur_RelatedPetitionIdno_TEXT AS NUMERIC) <> @Ln_Zero_NUMB 
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + ' The following are petitions that are related to the petition that underlies this support order: ' + @Lc_FcOrderDetCur_RelatedPetitionIdno_TEXT + '.' + '<BR/>' + '<BR/>';
		END
	 IF ISNUMERIC (@Lc_FcOrderDetCur_OtherAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_Other_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_Other_AMNT = @Lc_FcOrderDetCur_OtherAmnt_TEXT;
		END
	 IF @Ln_FcOrderDetCur_Other_AMNT > 0 
		BEGIN
			SET @Ls_Note_TEXT = @Ls_Note_TEXT + CAST(@Ln_FcOrderDetCur_Other_AMNT AS VARCHAR) + ' is to be paid monthly for ' + @Lc_FcOrderDetCur_OtherAmountPurpose_TEXT + '.' + '<BR/>' + '<BR/>';
		END
	    
     --Get the child relationship to the ncp and client from cmem_y1 table for the case
     SET @Ls_Sql_TEXT = 'READ CMEM_Y1 TABLE ';
     SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR); 
     
     SELECT TOP 1  @Lc_NcpRelationship_CODE		= NcpRelationshipToChild_CODE,
					 @Lc_CpRelationship_CODE	= CpRelationshipToChild_CODE 
					 FROM CMEM_Y1 c 
					 WHERE CASE_IDNO	= @Ln_FcOrderDetCur_Case_IDNO
					 AND CaseMemberStatus_CODE		= @Lc_CaseMemberActive_CODE
					  AND CaseRelationship_CODE		= @Lc_CaseRelationD_CODE;
	 SET @Li_RowCount_QNTY = @@ROWCOUNT;
	 IF @Li_RowCount_QNTY = @Ln_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'CMEM_Y1 READ FAILED ';
         RAISERROR(50001,16,1);
        END
     
     SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO PSRD_Y1 TABLE ';
     SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;
     INSERT INTO PSRD_Y1
                     (Case_IDNO,
                      Record_NUMB,
                      Order_IDNO,
                      File_ID,
                      OrderIssued_DATE,
                      StatusOrder_CODE,
                      InsOrdered_CODE,
                      Iiwo_CODE,
                      GuidelinesFollowed_INDC,
                      DeviationReason_CODE,
                      OrderOutOfState_ID,
                      TypeOrder_CODE,
                      DirectPay_INDC,
                      SourceOrdered_CODE,
                      Commissioner_ID,
                      Judge_ID,
                      SordNotes_TEXT,
                      Process_CODE,
                      Loaded_DATE,
                      WorkerUpdate_ID,
                      Update_DTTM) 
              
              SELECT   @Ln_FcOrderDetCur_Case_IDNO AS Case_IDNO,
                       @Ln_FcOrderDetCur_Seq_IDNO AS Record_NUMB ,
                       @Ln_FcOrderDetCur_SupportOrder_IDNO AS Order_IDNO,
                       @Lc_FcOrderDetCur_FamilyCourtFile_ID AS File_ID,
                       @Ld_FcOrderDetCur_Approved_DATE AS OrderIssued_DATE,
                       @Lc_FcOrderDetCur_OrderStatus_CODE AS StatusOrder_CODE,
                       CASE
						WHEN @Lc_FcOrderDetCur_HealthInsurance_CODE = @Lc_HealthInsuranceF_CODE THEN
							 CASE 
							  WHEN @Lc_NcpRelationship_CODE = @Lc_RelationshipFtr_CODE THEN @Lc_DecssHealthInsuranceU_CODE
							  WHEN @Lc_CpRelationship_CODE  = @Lc_RelationshipFtr_CODE THEN @Lc_DecssHealthInsuranceO_CODE
							 END
						WHEN @Lc_FcOrderDetCur_HealthInsurance_CODE = @Lc_HealthInsuranceM_CODE THEN 
							 CASE 
							  WHEN @Lc_NcpRelationship_CODE = @Lc_RelationshipMtr_CODE THEN @Lc_DecssHealthInsuranceU_CODE
							  WHEN @Lc_CpRelationship_CODE =  @Lc_RelationshipMtr_CODE THEN @Lc_DecssHealthInsuranceO_CODE
							 END
						WHEN @Lc_FcOrderDetCur_HealthInsurance_CODE = @Lc_HealthInsuranceB_CODE THEN @Lc_DecssHealthInsuranceD_CODE
						WHEN @Lc_FcOrderDetCur_HealthInsurance_CODE = @Lc_HealthInsuranceA_CODE THEN @Lc_DecssHealthInsuranceB_CODE
						WHEN @Lc_FcOrderDetCur_HealthInsurance_CODE = @Lc_HealthInsuranceN_CODE THEN @Lc_DecssHealthInsuranceN_CODE
						WHEN @Lc_FcOrderDetCur_HealthInsurance_CODE = @Lc_HealthInsuranceS_CODE THEN @Lc_DecssHealthInsuranceS_CODE
						ELSE @Lc_Space_TEXT
					   END AS InsOrdered_CODE,
                       
                       CASE 
						WHEN @Lc_FcOrderDetCur_WageAttachment_INDC = @Lc_ValueN_CODE THEN @Lc_ValueS_CODE
						WHEN @Lc_FcOrderDetCur_WageAttachment_INDC = @Lc_ValueY_CODE THEN @Lc_ValueI_CODE
						ELSE @Lc_Space_TEXT
					   END AS Iiwo_CODE,
                       
                       CASE
						WHEN @Lc_FcOrderDetCur_CalculationDeviation_CODE = @Lc_ValueN_CODE THEN @Lc_ValueY_CODE
						WHEN @Lc_FcOrderDetCur_CalculationDeviation_CODE = @Lc_ValueY_CODE THEN @Lc_ValueN_CODE
						ELSE @Lc_Space_TEXT
					   END AS GuidelinesFollowed_INDC,
					   
                       CASE 
						WHEN @Lc_FcOrderDetCur_CalculationDeviation_CODE = @Lc_ValueN_CODE THEN @Lc_Space_TEXT
						WHEN @Lc_FcOrderDetCur_CalculationDeviation_CODE <> @Lc_ValueN_CODE THEN @Lc_FcOrderDetCur_CalculationDeviation_CODE
						END  AS DeviationReason_CODE,
                       
                       @Lc_FcOrderDetCur_OutOfStateAgencyIdno_TEXT AS OrderOutOfState_ID,
                       CASE 
						WHEN @Lc_FcOrderDetCur_PermanentOrder_INDC = @Lc_ValueY_CODE THEN @Lc_ValueJ_CODE
						WHEN @Lc_FcOrderDetCur_PermanentOrder_INDC = @Lc_ValueN_CODE THEN @Lc_ValueI_CODE
					   END AS TypeOrder_CODE,
                       
                       CASE 
						WHEN @Lc_FcOrderDetCur_Payment_INDC = @Lc_ValueY_CODE THEN @Lc_ValueN_CODE
						WHEN @Lc_FcOrderDetCur_Payment_INDC = @Lc_ValueN_CODE THEN @Lc_ValueY_CODE
						ELSE @Lc_ValueN_CODE
					   END AS DirectPay_INDC, 
                       
                       CASE 
						WHEN @Lc_FcOrderDetCur_DefaultOrder_INDC = @Lc_ValueY_CODE THEN @Lc_ValueD_CODE
						WHEN @Lc_FcOrderDetCur_DefaultOrder_INDC = @Lc_ValueN_CODE THEN @Lc_ValueH_CODE
					   END AS SourceOrdered_CODE,
                       
                       ISNULL((SELECT TOP 1 LTRIM(RTRIM(DescriptionValue_TEXT))
						                 FROM REFM_Y1 r
						                 WHERE Table_ID = @Lc_TableOabc_ID 
										   AND TableSub_ID = @Lc_TableSub_ID  
										   AND Value_CODE = @Lc_FcOrderDetCur_ApprovedBy_ID), '') AS Commissioner_ID,
						
					   ISNULL((SELECT TOP 1 LTRIM(RTRIM(DescriptionValue_TEXT))
						                 FROM REFM_Y1 r
						                 WHERE Table_ID = @Lc_TableOabj_ID 
										   AND TableSub_ID = @Lc_TableSub_ID  
										   AND Value_CODE = @Lc_FcOrderDetCur_ApprovedBy_ID), '') AS Judge_ID,
                       
                       @Ls_Note_TEXT AS SordNotes_TEXT,
					   @Lc_ProcessL_CODE AS Process_CODE,
					   @Ld_Run_DATE AS Loaded_DATE,
					   @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
					   @Ld_Start_DATE AS Update_DTTM;	
     
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;
             
     IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
        BEGIN
          SET @Ls_DescriptionError_TEXT = 'PSRD_Y1 INSERT FAILED ';
          RAISERROR(50001,16,1);
        END
            
	-- Create the case journal entry, if the contempt flag is y
	IF @Lc_FcOrderDetCur_Contempt_INDC = @Lc_Yes_INDC
		BEGIN
		   SET @Lc_MinorActivity_CODE = @Lc_MinorActivityConor_CODE
		   EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
			@An_Case_IDNO                = @Ln_FcOrderDetCur_Case_IDNO,
			@An_MemberMci_IDNO           = @Ln_FcOrderDetCur_ObligorMci_IDNO,
			@Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
			@Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
			@As_DescriptionNote_TEXT     = @Lc_Space_TEXT,  
			@Ac_Subsystem_CODE           = @Lc_SubsystemEst_CODE,
			@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
			@Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
			@Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
			@Ad_Run_DATE                 = @Ld_Run_DATE,
			@Ac_Job_ID                   = @Lc_Job_ID,
			@An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
			@Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
           
		  IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
			BEGIN
			   SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
			   SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
               RAISERROR(50001,16,1);
            END
		  ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
				BEGIN
				 SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
				 SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				 RAISERROR (50001,16,1);
				END 		
			
		END	  
	
	 -- Insert inot POBL_Y1 
     -- Convert the Obligation effective date into ccyymmdd format from the load table column
     SET @Ld_FcOrderDetCur_ObligationEffective_DATE = SUBSTRING(@Lc_FcOrderDetCur_ObligationEffectiveDate_TEXT, 5,4) + LEFT(@Lc_FcOrderDetCur_ObligationEffectiveDate_TEXT, 2) + SUBSTRING(@Lc_FcOrderDetCur_ObligationEffectiveDate_TEXT, 3, 2);
     IF ISNUMERIC (@Lc_FcOrderDetCur_CurrentSupportAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_CurrentSupport_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_CurrentSupport_AMNT = @Lc_FcOrderDetCur_CurrentSupportAmnt_TEXT;
		END
	 -- Payment indicator is 'Y' means paid to DCSE, then create the POBLE_Y1 records
	 -- Payment indicator is 'N' means paid to CP, then do not create the OBLE_Y1 reords
	 IF @Ln_FcOrderDetCur_CurrentSupport_AMNT > 0
	    AND @Lc_FcOrderDetCur_Payment_INDC = @Lc_Yes_INDC
		BEGIN
			SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO POBL_Y1 TABLE FOR CURRENT SUPPORT ';
			SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;     
          	INSERT INTO POBL_Y1
						(Record_NUMB,
						 TypeDebt_CODE,
						 Fips_CODE,
						 Periodic_AMNT,
						 FreqPeriodic_CODE,
						 Effective_DATE,
						 End_DATE,
						 CheckRecipient_ID,
						 PayBack_INDC,
						 ReasonPayBack_CODE,
						 Process_CODE,
						 WorkerUpdate_ID,
						 Update_DTTM)
				SELECT  @Ln_FcOrderDetCur_Seq_IDNO AS Record_NUMB,
						@Lc_TypeDebtCs_CODE AS TypeDebt_CODE,
						@Lc_Space_TEXT AS Fips_CODE,
						@Ln_FcOrderDetCur_CurrentSupport_AMNT AS Periodic_AMNT,
						@Lc_FreqPeriodicM_CODE AS FreqPeriodic_CODE,
						@Ld_FcOrderDetCur_ObligationEffective_DATE AS Effective_DATE,
						@Ld_High_DATE AS End_DATE,
						@Lc_Space_TEXT AS CheckRecipient_ID,
						@Lc_ValueN_CODE AS PayBack_INDC,
						@Lc_Space_TEXT AS ReasonPayBack_CODE,
						@Lc_ProcessL_CODE AS Process_CODE,
						@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
						@Ld_Start_DATE AS Update_DTTM;
			SET @Li_Rowcount_QNTY = @@ROWCOUNT;	
			IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				BEGIN
					SET @Ls_DescriptionError_TEXT = 'POBL_Y1 INSERT FAILED ';
					RAISERROR(50001,16,1);
				END
		END
				
     IF ISNUMERIC (@Lc_FcOrderDetCur_ArrearsAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_Arrears_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_Arrears_AMNT = @Lc_FcOrderDetCur_ArrearsAmnt_TEXT;
		END
	 IF @Ln_FcOrderDetCur_Arrears_AMNT > 0
	    AND @Lc_FcOrderDetCur_Payment_INDC = @Lc_Yes_INDC
		BEGIN
			SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO POBL_Y1 TABLE FOR CS ARREARS';
			SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;     
          	INSERT INTO POBL_Y1
						(Record_NUMB,
						 TypeDebt_CODE,
						 Fips_CODE,
						 Periodic_AMNT,
						 FreqPeriodic_CODE,
						 Effective_DATE,
						 End_DATE,
						 CheckRecipient_ID,
						 PayBack_INDC,
						 ReasonPayBack_CODE,
						 Process_CODE,
						 WorkerUpdate_ID,
						 Update_DTTM)
				SELECT  @Ln_FcOrderDetCur_Seq_IDNO AS Record_NUMB,
						@Lc_TypeDebtCs_CODE AS TypeDebt_CODE,
						@Lc_Space_TEXT AS Fips_CODE, 
						@Ln_FcOrderDetCur_Arrears_AMNT AS Periodic_AMNT,
						@Lc_FreqPeriodicM_CODE AS FreqPeriodic_CODE,
						@Ld_FcOrderDetCur_ObligationEffective_DATE AS Effective_DATE,
						@Ld_High_DATE AS End_DATE,
						@Lc_Space_TEXT AS CheckRecipient_ID,
						@Lc_ValueY_CODE AS PayBack_INDC,
						CASE
						 WHEN @Lc_FcOrderDetCur_PetitionType_CODE <> @Lc_PetitionTypeNoaa_CODE THEN @Lc_ValueC_CODE
						 ELSE @Lc_ValueN_CODE
						END AS ReasonPayBack_CODE,
						@Lc_ProcessL_CODE AS Process_CODE,
						@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
						@Ld_Start_DATE AS Update_DTTM;
			SET @Li_Rowcount_QNTY = @@ROWCOUNT;	
			IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				BEGIN
					SET @Ls_DescriptionError_TEXT = 'POBL_Y1 INSERT FAILED ';
					RAISERROR(50001,16,1);
				END	
		END
			
     IF ISNUMERIC (@Lc_FcOrderDetCur_MedicalSupportAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_MedicalSupport_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_MedicalSupport_AMNT = @Lc_FcOrderDetCur_MedicalSupportAmnt_TEXT;
		END
	 IF @Ln_FcOrderDetCur_MedicalSupport_AMNT > 0
	    AND @Lc_FcOrderDetCur_Payment_INDC = @Lc_Yes_INDC
		BEGIN
			SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO POBL_Y1 TABLE FOR MEDICAL SUPPORT ';
			SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;     
          	INSERT INTO POBL_Y1
						(Record_NUMB,
						 TypeDebt_CODE,
						 Fips_CODE,
						 Periodic_AMNT,
						 FreqPeriodic_CODE,
						 Effective_DATE,
						 End_DATE,
						 CheckRecipient_ID,
						 PayBack_INDC,
						 ReasonPayBack_CODE,
						 Process_CODE,
						 WorkerUpdate_ID,
						 Update_DTTM)
				SELECT  @Ln_FcOrderDetCur_Seq_IDNO AS Record_NUMB,
						@Lc_TypeDebtMs_CODE AS TypeDebt_CODE,
						@Lc_Space_TEXT AS Fips_CODE,
						@Ln_FcOrderDetCur_MedicalSupport_AMNT AS Periodic_AMNT,
						@Lc_FreqPeriodicM_CODE AS FreqPeriodic_CODE,
						@Ld_FcOrderDetCur_ObligationEffective_DATE AS Effective_DATE,
						@Ld_High_DATE AS End_DATE,
						@Lc_Space_TEXT AS CheckRecipient_ID,
						@Lc_ValueN_CODE AS PayBack_INDC,
						@Lc_Space_TEXT AS ReasonPayBack_CODE,
						@Lc_ProcessL_CODE AS Process_CODE,
						@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
						@Ld_Start_DATE AS Update_DTTM;
			SET @Li_Rowcount_QNTY = @@ROWCOUNT;	
			IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				BEGIN
					SET @Ls_DescriptionError_TEXT = 'POBL_Y1 INSERT FAILED ';
					RAISERROR(50001,16,1);
				END	
		END
			
     IF ISNUMERIC (@Lc_FcOrderDetCur_SpousalSupportAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_SpousalSupport_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_SpousalSupport_AMNT = @Lc_FcOrderDetCur_SpousalSupportAmnt_TEXT;
		END
	 IF @Ln_FcOrderDetCur_SpousalSupport_AMNT > 0
	    AND @Lc_FcOrderDetCur_Payment_INDC = @Lc_Yes_INDC
		BEGIN
			SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO POBL_Y1 TABLE FOR SPOUSAL SUPPORT ';
			SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;     
          	INSERT INTO POBL_Y1
						(Record_NUMB,
						 TypeDebt_CODE,
						 Fips_CODE,
						 Periodic_AMNT,
						 FreqPeriodic_CODE,
						 Effective_DATE,
						 End_DATE,
						 CheckRecipient_ID,
						 PayBack_INDC,
						 ReasonPayBack_CODE,
						 Process_CODE,
						 WorkerUpdate_ID,
						 Update_DTTM)
				SELECT  @Ln_FcOrderDetCur_Seq_IDNO AS Record_NUMB,
						@Lc_TypeDebtSs_CODE AS TypeDebt_CODE,
						@Lc_Space_TEXT AS Fips_CODE,
						@Ln_FcOrderDetCur_SpousalSupport_AMNT AS Periodic_AMNT,
						@Lc_FreqPeriodicM_CODE AS FreqPeriodic_CODE,
						@Ld_FcOrderDetCur_ObligationEffective_DATE AS Effective_DATE,
						@Ld_High_DATE AS End_DATE,
						@Lc_Space_TEXT AS CheckRecipient_ID,
						@Lc_ValueN_CODE AS PayBack_INDC,
						@Lc_Space_TEXT AS ReasonPayBack_CODE,
						@Lc_ProcessL_CODE AS Process_CODE,
						@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
						@Ld_Start_DATE AS Update_DTTM;
			SET @Li_Rowcount_QNTY = @@ROWCOUNT;	
			IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				BEGIN
					SET @Ls_DescriptionError_TEXT = 'POBL_Y1 INSERT FAILED ';
					RAISERROR(50001,16,1);
				END		
        END
        
     -- Convert the Arrears effective date into ccyymmdd format from the load table column
     -- If the arrears effective date is blank, use the obligation effective date for the arrears effective date 
     
     SET @Lc_ArrearsEffectiveDate_TEXT = SUBSTRING(@Lc_FcOrderDetCur_ArrearsEffectiveDate_TEXT, 5,4) + LEFT(@Lc_FcOrderDetCur_ArrearsEffectiveDate_TEXT, 2) + SUBSTRING(@Lc_FcOrderDetCur_ArrearsEffectiveDate_TEXT, 3, 2);
     IF ISDATE (@Lc_ArrearsEffectiveDate_TEXT) <> 1
        BEGIN
			SET @Ld_FcOrderDetCur_ArrearsEffective_DATE = @Ld_FcOrderDetCur_ObligationEffective_DATE;
		END
	 ELSE
	    BEGIN 
			SET @Ld_FcOrderDetCur_ArrearsEffective_DATE = @Lc_ArrearsEffectiveDate_TEXT;
		END
     
     IF ISNUMERIC (@Lc_FcOrderDetCur_GeneticTestAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_GeneticTest_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_GeneticTest_AMNT = @Lc_FcOrderDetCur_GeneticTestAmnt_TEXT;
		END
	 IF @Ln_FcOrderDetCur_GeneticTest_AMNT > 0
	    AND @Lc_FcOrderDetCur_Payment_INDC = @Lc_Yes_INDC
		BEGIN
			SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO POBL_Y1 TABLE FOR SPOUSAL SUPPORT ';
			SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;     
          	INSERT INTO POBL_Y1
						(Record_NUMB,
						 TypeDebt_CODE,
						 Fips_CODE,
						 Periodic_AMNT,
						 FreqPeriodic_CODE,
						 Effective_DATE,
						 End_DATE,
						 CheckRecipient_ID,
						 PayBack_INDC,
						 ReasonPayBack_CODE,
						 Process_CODE,
						 WorkerUpdate_ID,
						 Update_DTTM)
				SELECT  @Ln_FcOrderDetCur_Seq_IDNO AS Record_NUMB,
						@Lc_TypeDebtGt_CODE AS TypeDebt_CODE,
						@Lc_Space_TEXT AS Fips_CODE,
						@Ln_FcOrderDetCur_GeneticTest_AMNT AS Periodic_AMNT,
						@Lc_FreqPeriodicM_CODE AS FreqPeriodic_CODE,
						@Ld_FcOrderDetCur_ArrearsEffective_DATE AS Effective_DATE,
						@Ld_High_DATE AS End_DATE,
						@Lc_Space_TEXT AS CheckRecipient_ID,
						@Lc_ValueY_CODE AS PayBack_INDC,
						@Lc_ValueC_CODE AS ReasonPayBack_CODE,
						@Lc_ProcessL_CODE AS Process_CODE,
						@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
						@Ld_Start_DATE AS Update_DTTM;
			SET @Li_Rowcount_QNTY = @@ROWCOUNT;	
			IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				BEGIN
					SET @Ls_DescriptionError_TEXT = 'POBL_Y1 INSERT FAILED ';
					RAISERROR(50001,16,1);
				END		
        END
     
     IF ISNUMERIC (@Lc_FcOrderDetCur_GeneticTestBalanceAmnt_TEXT) <> 1 
		BEGIN
			SET @Ln_FcOrderDetCur_GeneticTestBalance_AMNT = @Ln_Zero_NUMB;
		END
	 ELSE
		BEGIN
			SET @Ln_FcOrderDetCur_GeneticTestBalance_AMNT = @Lc_FcOrderDetCur_GeneticTestBalanceAmnt_TEXT;
		END
	 IF @Ln_FcOrderDetCur_GeneticTestBalance_AMNT > 0
	    AND @Lc_FcOrderDetCur_Payment_INDC = @Lc_Yes_INDC
		BEGIN
			SET @Ls_Sql_TEXT = 'INSERT NEW RECORD INTO POBL_Y1 TABLE FOR SPOUSAL SUPPORT ';
			SET @Ls_Sqldata_TEXT = 'CASE IDNO = ' + CAST(@Ln_FcOrderDetCur_Case_IDNO AS VARCHAR) + ', FAMILY COURT FILE ID = ' + @Lc_FcOrderDetCur_FamilyCourtFile_ID + ', PETITION IDNO = ' + @Lc_FcOrderDetCur_PetitionIdno_TEXT;     
          	INSERT INTO POBL_Y1
						(Record_NUMB,
						 TypeDebt_CODE,
						 Fips_CODE,
						 Periodic_AMNT,
						 FreqPeriodic_CODE,
						 Effective_DATE,
						 End_DATE,
						 CheckRecipient_ID,
						 PayBack_INDC,
						 ReasonPayBack_CODE,
						 Process_CODE,
						 WorkerUpdate_ID,
						 Update_DTTM)
				SELECT  @Ln_FcOrderDetCur_Seq_IDNO AS Record_NUMB,
						@Lc_TypeDebtGt_CODE AS TypeDebt_CODE,
						@Lc_Space_TEXT AS Fips_CODE,
						@Ln_FcOrderDetCur_GeneticTestBalance_AMNT AS Periodic_AMNT,
						@Lc_FreqPeriodicO_CODE AS FreqPeriodic_CODE,
						@Ld_FcOrderDetCur_ObligationEffective_DATE AS Effective_DATE,
						@Ld_High_DATE AS End_DATE,
						@Lc_Space_TEXT AS CheckRecipient_ID,
						@Lc_ValueN_CODE AS PayBack_INDC,
						@Lc_Space_TEXT AS ReasonPayBack_CODE,
						@Lc_ProcessL_CODE AS Process_CODE,
						@Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
						@Ld_Start_DATE AS Update_DTTM;
			SET @Li_Rowcount_QNTY = @@ROWCOUNT;	
			IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				BEGIN
					SET @Ls_DescriptionError_TEXT = 'POBL_Y1 INSERT FAILED ';
					RAISERROR(50001,16,1);
				END	
		END	
        
     -- Call insert activity to create alert ORRFF or MORFF
     SET @Lc_MinorActivity_CODE = @Lc_Space_TEXT;
     SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
         FROM SORD_Y1 s
        WHERE s.Case_IDNO = @Ln_FcOrderDetCur_Case_IDNO;
          
       IF @Ln_Exists_NUMB = @Ln_ZERO_NUMB
        BEGIN
         SET @Lc_MinorActivity_CODE = @Lc_MinorActivityOrrff_CODE;
        END
       ELSE
		BEGIN 
		 SET @Lc_MinorActivity_CODE = @Lc_MinorActivityMorff_CODE;
		END 
     EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
      @An_Case_IDNO                = @Ln_FcOrderDetCur_Case_IDNO,
      @An_MemberMci_IDNO           = @Ln_FcOrderDetCur_ObligorMci_IDNO,
      @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
      @Ac_ActivityMinor_CODE       = @Lc_MinorActivity_CODE,
      @As_DescriptionNote_TEXT     = @Lc_Space_TEXT,  
      @Ac_Subsystem_CODE           = @Lc_SubsystemEst_CODE,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
      @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
      @Ac_WorkerDelegate_ID        = @Lc_Space_TEXT,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
           
     IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		BEGIN
			RAISERROR(50001,16,1);
		END
				               
     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
       
       SET @Ls_Record_TEXT = ' Rec_ID = ' + ISNULL(@Lc_FcOrderDetCur_Rec_ID, '') + ', Petition_IDNO = ' + ISNULL(@Lc_FcOrderDetCur_PetitionIdno_TEXT, '') + ', PetitionSequence_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_PetitionSequenceIdno_Text, ' ') + ', Case_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_CaseIdno_TEXT, '') + ', PetitionType_CODE = ' + ISNULL (@Lc_FcOrderDetCur_PetitionType_CODE, '') + ', PetitionAction_DATE = ' + ISNULL (@Lc_FcOrderDetCur_PetitionActionDate_TEXT, '') + ', FamilyCourtFile_ID = ' + ISNULL (@Lc_FcOrderDetCur_FamilyCourtFile_ID, '') + ', SupportOrder_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_SupportOrderIdno_TEXT, '') + ', HearingOfficer_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_HearingOfficer_ID, '') + ', Hearing_DATE = ' + ISNULL (@Lc_FcOrderDetCur_HearingDate_TEXT, '') + ', ClientMci_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_ObligeeMciIdno_TEXT, '') + ', NcpMci_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_ObligorMciIdno_TEXT, '') + ', Form_ID = ' + ISNULL (@Lc_FcOrderDetCur_Form_ID, '') + ', OrderStatus_CODE = ' + ISNULL (@Lc_FcOrderDetCur_OrderStatus_CODE, '') + ', PermanentOrder_INDC = ' + ISNULL (@Lc_FcOrderDetCur_PermanentOrder_INDC, '') + ', DefaultOrder_INDC = ' + ISNULL (@Lc_FcOrderDetCur_DefaultOrder_INDC, '') + ', IvdCase_INDC = ' + ISNULL (@Lc_FcOrderDetCur_IvdCase_INDC, '') + ', WageAttachment_INDC = ' + ISNULL (@Lc_FcOrderDetCur_WageAttachment_INDC, '') + ', Payment_INDC = ' + ISNULL (@Lc_FcOrderDetCur_Payment_INDC, '') + ', Contempt_INDC = ' + ISNULL (@Lc_FcOrderDetCur_Contempt_INDC, '') + ', EmployerProgram_INDC = ' + ISNULL (@Lc_FcOrderDetCur_EmployerProgam_INDC, '') + ', CreditAmount_INDC = ' + ISNULL (@Lc_FcOrderDetCur_Credit_CODE, '') + ', CurrentArrears_INDC = ' + ISNULL (@Lc_FcOrderDetCur_Arrears_CODE, '') + ', NcpCommitDoc_INDC = ' + ISNULL (@Lc_FcOrderDetCur_DocCommit_CODE, '') + ', HealthInsurance_INDC = ' + ISNULL (@Lc_FcOrderDetCur_HealthInsurance_CODE, '') + ', CalculationDeviation_CODE = ' + ISNULL (@Lc_FcOrderDetCur_CalculationDeviation_CODE, '') + ', CountyEmployerProgram_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_CountyEmployerProgramIdno_TEXT, '') + ', CurrentSupport_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_CurrentSupportAmnt_TEXT, '') + ', Arrears_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_ArrearsAmnt_TEXT, '') + ', MedicalSupport_Amnt = ' + ISNULL (@Lc_FcOrderDetCur_MedicalSupportAmnt_TEXT, '') + ', SpousalSupport_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_SpousalSupportAmnt_TEXT, '') + ', GeneticTest_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_GeneticTestAmnt_TEXT, '') + ', TotalObligation_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_TotalObligationAmnt_TEXT, '') + ', ArrearsBalance_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_ArrearsBalanceAmnt_TEXT, '') + ', TotalCredit_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_TotalCreditAmnt_TEXT, '') + ', ObligationEffective_DATE = ' + ISNULL (@Lc_FcOrderDetCur_ObligationEffectiveDate_TEXT, '') + ', ArrearsEffective_DATE = ' + ISNULL (@Lc_FcOrderDetCur_ArrearsEffectiveDate_TEXT, '') + ', BalanceAsOf_DATE = ' + ISNULL (@Lc_FcOrderDetCur_BalanceAsOfDate_Text, '') + ', CreditEffective_DATE = ' + ISNULL (@Lc_FcOrderDetCur_CreditEffectiveDate_TEXT, '') + ', OutOfStateAgency_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_OutOfStateAgencyIdno_TEXT, '') + ', AppovedBy_CODE = ' + ISNULL (@Lc_FcOrderDetCur_ApprovedBy_ID, '') + ', ApprovedBy_DATE = ' + ISNULL (@Lc_FcOrderDetCur_ApprovedDate_TEXT, '') + ', GeneticTestBalance_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_GeneticTestBalanceAmnt_TEXT, '') + ', MedicalBalance_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_MedicalBalanceAmnt_TEXT, '') + ', SpousalBalance_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_SpousalBalanceAmnt_TEXT, '') + ', RelatedPetition_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_RelatedPetitionIdno_TEXT, '') + ', Other_AMNT = ' + ISNULL (@Lc_FcOrderDetCur_OtherAmnt_TEXT, '') + ', OtherAmountPurpose_TEXT = ' + ISNULL (@Lc_FcOrderDetCur_OtherAmountPurpose_TEXT, '');
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_Error_CODE,
        @As_DescriptionError_TEXT    = @Ls_Record_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         
         RAISERROR(50001,16,1);
        END
       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END
     END
     
    END TRY 
    
    BEGIN CATCH
	 BEGIN
		
       SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
       
       -- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	    BEGIN
	   	   ROLLBACK TRANSACTION SAVEFCORDR_BATCH_DETAILS;
		END
		ELSE
		BEGIN
		    SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
		END
       
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

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'FcRecordType_ID = ' + ISNULL(@Lc_FcOrderDetCur_Rec_ID, '') + ', FcPetion_IDNO = ' + ISNULL(@Lc_FcOrderDetCur_PetitionIdno_TEXT, '') + ', FcCase_IDNO = ' + ISNULL(@Lc_FcOrderDetCur_CaseIdno_TEXT, '') + ', FcPetitionType_CODE = ' + ISNULL(@Lc_FcOrderDetCur_PetitionType_CODE, '') + ', FcFile_IDNO = ' + ISNULL (@Lc_FcOrderDetCur_FamilyCourtFile_ID, '');

       SET @Ls_BateRecord_TEXT = @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_Error_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END
     END
	END CATCH
		

       /* Update the records in the LFORD_Y1 table for these errors with the process indicator 
          value to 'Y', so that these records will not be picked up in the sord screen for the worker view
       */
       SET @Ls_Sql_TEXT = 'LoadFcEmployerDetails_T1';
       SET @Ls_Sqldata_TEXT = 'Seq IDNO = ' + ISNULL (CAST(@Ln_FcOrderDetCur_Seq_IDNO AS VARCHAR), '');

       UPDATE LFORD_Y1
          SET Process_INDC = @Lc_Yes_INDC
        WHERE Seq_IDNO = @Ln_FcOrderDetCur_Seq_IDNO;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LFORD_Y1';
         RAISERROR(50001,16,1);
        END
       
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_Sql_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT =  'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
	   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cur_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'BATCH RESTART UPDATE FAILED ';
         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION FCORDR_BATCH_DETAILS; 
       
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       
	   BEGIN TRANSACTION FCORDR_BATCH_DETAILS; 

       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD ' ;
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ' ThresholdParm_QNTY = ' +  ISNULL(CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR(10)), '');

     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION FCORDR_BATCH_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_DescriptionError_TEXT = 'REACHED EXCEPTION THRESHOLD';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'ADDING THE PROCESSED RECORD COUNT';
	 SET @Ls_Sqldata_TEXT = 'Sequence Number = ' + CAST(@Ln_FcOrderDetCur_Seq_IDNO AS VARCHAR);
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
     
     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcOrderDet_Cur';
     SET @Ls_SqlData_TEXT = '';

     FETCH NEXT FROM FcOrderDet_Cur INTO @Ln_FcOrderDetCur_Seq_IDNO, @Lc_FcOrderDetCur_Rec_ID, @Lc_FcOrderDetCur_PetitionIdno_TEXT, @Lc_FcOrderDetCur_PetitionSequenceIdno_Text, @Lc_FcOrderDetCur_CaseIdno_TEXT, @Lc_FcOrderDetCur_PetitionType_CODE, @Lc_FcOrderDetCur_PetitionActionDate_TEXT, @Lc_FcOrderDetCur_FamilyCourtFile_ID, @Lc_FcOrderDetCur_SupportOrderIdno_TEXT, @Lc_FcOrderDetCur_HearingOfficer_ID, @Lc_FcOrderDetCur_HearingDate_TEXT, @Lc_FcOrderDetCur_ObligeeMciIdno_TEXT, @Lc_FcOrderDetCur_ObligorMciIdno_TEXT, @Lc_FcOrderDetCur_Form_ID, @Lc_FcOrderDetCur_OrderStatus_CODE, @Lc_FcOrderDetCur_PermanentOrder_INDC, @Lc_FcOrderDetCur_DefaultOrder_INDC, @Lc_FcOrderDetCur_IvdCase_INDC, @Lc_FcOrderDetCur_WageAttachment_INDC, @Lc_FcOrderDetCur_Payment_INDC, @Lc_FcOrderDetCur_Contempt_INDC, @Lc_FcOrderDetCur_EmployerProgam_INDC, @Lc_FcOrderDetCur_Credit_CODE, @Lc_FcOrderDetCur_Arrears_CODE, @Lc_FcOrderDetCur_DocCommit_CODE, @Lc_FcOrderDetCur_HealthInsurance_CODE, @Lc_FcOrderDetCur_CalculationDeviation_CODE, @Lc_FcOrderDetCur_CountyEmployerProgramIdno_TEXT, @Lc_FcOrderDetCur_CurrentSupportAmnt_TEXT, @Lc_FcOrderDetCur_ArrearsAmnt_TEXT, @Lc_FcOrderDetCur_MedicalSupportAmnt_TEXT, @Lc_FcOrderDetCur_SpousalSupportAmnt_TEXT, @Lc_FcOrderDetCur_GeneticTestAmnt_TEXT, @Lc_FcOrderDetCur_TotalObligationAmnt_TEXT, @Lc_FcOrderDetCur_ArrearsBalanceAmnt_TEXT, @Lc_FcOrderDetCur_TotalCreditAmnt_TEXT, @Lc_FcOrderDetCur_ObligationEffectiveDate_TEXT, @Lc_FcOrderDetCur_ArrearsEffectiveDate_TEXT, @Lc_FcOrderDetCur_BalanceAsOfDate_Text, @Lc_FcOrderDetCur_CreditEffectiveDate_TEXT, @Lc_FcOrderDetCur_OutOfStateAgencyIdno_TEXT, @Lc_FcOrderDetCur_ApprovedBy_ID, @Lc_FcOrderDetCur_ApprovedDate_TEXT, @Lc_FcOrderDetCur_GeneticTestBalanceAmnt_TEXT, @Lc_FcOrderDetCur_MedicalBalanceAmnt_TEXT, @Lc_FcOrderDetCur_SpousalBalanceAmnt_TEXT, @Lc_FcOrderDetCur_RelatedPetitionIdno_TEXT, @Lc_FcOrderDetCur_OtherAmnt_TEXT, @Lc_FcOrderDetCur_OtherAmountPurpose_TEXT,@Ls_FcOrderDetCur_Detailed_TEXT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcOrderDet_Cur;

   DEALLOCATE FcOrderDet_Cur;

   IF @Ln_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB
	  BEGIN 
		SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + @Ln_CommitFreq_QNTY;
	  END
   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';

     RAISERROR(50001,16,1);
    END
      
   -- --Update the Log in BSTL_Y1 as the Job is suceeded
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @LC_Successful_TEXT,
    @As_ListKey_TEXT          = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');
   
   COMMIT TRANSACTION FCORDR_BATCH_DETAILS;
   
  END TRY

  BEGIN CATCH
   --If Trasaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FCORDR_BATCH_DETAILS;
    END

   IF CURSOR_STATUS ('local', 'FcOrderDet_Cur') IN (0, 1)
    BEGIN
     CLOSE FcOrderDet_Cur;

     DEALLOCATE FcOrderDet_Cur;
    END
   
   --Set Error Description
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

   --Update the Log in BSTL_Y1 as the Job is failed.
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Ls_Sql_TEXT,
    @As_ListKey_TEXT          = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
