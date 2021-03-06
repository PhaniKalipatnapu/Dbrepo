/****** Object:  StoredProcedure [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_PETITION_REQUEST]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure  Name	     : BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_PETITION_REQUEST
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_PETITION_REQUEST reads the data from the temporary table received from 
					   the family court to update with the petition tracking information into DECSS system for DCSE filed petitions. 
					   Also updates NCP filed petition related information received from family court into the DECSS system.
Frequency			 : Daily
Developed On		 : 05/10/2011
Called By			 : None
Called On			 : BATCH_COMMON$SP_GET_BATCH_DETAILS,BATCH_COMMON$SP_BSTL_LOG,BATCH_COMMON$SP_UPDATE_PARM_DATE,BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY,BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT,BATCH_COMMON$SP_BATE_LOG,BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
----------------------------------------------------------------------------------------------------------------------------------					   
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_PETITION_REQUEST]
AS
 BEGIN
  SET NOCOUNT ON;
    DECLARE @Ln_County1_IDNO                          NUMERIC(1) = 1,
            @Ln_County3_IDNO                          NUMERIC(1) = 3,
            @Ln_County5_IDNO                          NUMERIC(1) = 5,
            @Lc_StatusFailed_CODE                     CHAR	  = 'F',
            @Lc_Yes_INDC                              CHAR    = 'Y',
            @Lc_Note_INDC                             CHAR(1) = 'N',
            @Lc_ErrorTypeError_CODE                   CHAR(1) = 'E',
            @Lc_TypeError_CODE                        CHAR(1) = ' ',
            @Lc_StatusSuccess_CODE                    CHAR(1) = 'S',
            @Lc_StatusAbnormalend_CODE                CHAR(1) = 'A',
            @Lc_NcpType_CODE                          CHAR(1) = 'A',
            @Lc_PfType_CODE                           CHAR(1) = 'P',
            @Lc_CpType_CODE                           CHAR(1) = 'C',
            @Lc_DependentType_CODE					  CHAR(1) = 'D',
            @Lc_CaseMemberStatusA_CODE                CHAR(1) = 'A',
            @Lc_TypeOthp_CODE                         CHAR(1) = 'C',
            @Lc_TypeActivity_CODE                     CHAR(1) = 'H',
            @Lc_TypeTestS_CODE                        CHAR(1) = 'S',
            @Lc_CaseStatusOpen_CODE                   CHAR(1) = 'O',
            @Lc_SchdGeneticTestHearingB_CODE          CHAR(1) = 'B',
            @Lc_SchdConferenceC_CODE                  CHAR(1) = 'C',
            @Lc_SchdHearingH_CODE                     CHAR(1) = 'H',
            @Lc_SchdMediationHearingM_CODE            CHAR(1) = 'M',
            @Lc_SchdTeleconferenceT_CODE              CHAR(1) = 'T',
            @Lc_SchdPretrialP_CODE                    CHAR(1) = 'P',
            @Lc_SrvcAffidavitAppearance_CODE          CHAR(1) = 'A',
            @Lc_SrvcCertifiedMail_CODE                CHAR(1) = 'C',
            @Lc_SrvcHandDeliveredCourt_CODE           CHAR(1) = 'H',
            @Lc_SrvcSentLongArm_CODE                  CHAR(1) = 'L',
            @Lc_SrvcLocalNewsPaper_CODE               CHAR(1) = 'N',
            @Lc_SrvcPersonalService_CODE              CHAR(1) = 'P',
            @Lc_SrvcRegularMail_CODE                  CHAR(1) = 'M',
            @Lc_SrvcRegisteredMail_CODE               CHAR(1) = 'R',
            @Lc_SrvcAttorney_CODE                     CHAR(1) = 'S',
            @Lc_SrvcCertifiedPublications_CODE        CHAR(1) = 'B',
            @Lc_SrvcAwaitResponse_CODE                CHAR(1) = 'V',
            @Lc_SrvcServiceNotSent_CODE               CHAR(1) = 'X',
            @Lc_ServiceResult_CODE                    CHAR(1) = ' ', 
            @Lc_ServicePositive_CODE                  CHAR(1) = 'P',
            @Lc_ServiceNegative_CODE                  CHAR(1) = 'N',
            @Lc_FinalDispositionYes_CODE              CHAR(1) = 'Y',
            @Lc_FinalDispositionNo_CODE               CHAR(1) = 'N',
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
            @Lc_SchdCommissioner_CODE                 CHAR(2) = 'CO',
            @Lc_SchdMaster_CODE                       CHAR(2) = 'MS',
            @Lc_SchdMediation_CODE                    CHAR(2) = 'MA',
            @Lc_SchdGeneticTestBt_CODE                CHAR(2) = 'BT',
            @Lc_SchdHearingTentativeHt_CODE           CHAR(2) = 'HT',
            @Lc_SchdMediationHearingTentativeMt_CODE  CHAR(2) = 'MT',
            @Lc_SchdJudge_CODE                        CHAR(2) = 'JU',
            @Lc_MinorReasonDescriptionFa_CODE         CHAR(2) = 'FA',
            @Lc_MinorReasonDescriptionPn_CODE         CHAR(2) = 'PN',
            @Lc_MinorReasonDescriptionSc_CODE         CHAR(2) = 'SC',
            @Lc_MinorReasonDescriptionNd_CODE         CHAR(2) = 'ND',
            @Lc_MinorReasonDescriptionNo_CODE         CHAR(2) = 'NO',
            @Lc_MinorReasonDescriptionTe_CODE         CHAR(2) = 'TE',
            @Lc_MinorReasonDescriptionTr_CODE         CHAR(2) = 'TR',
            @Lc_MinorReasonDescriptionCg_CODE         CHAR(2) = 'CG',
            @Lc_MinorReasonDescriptionSy_CODE         CHAR(2) = 'SY',
            -- 13633 - LabCorp and Family Court changes to increase success rate - START -
            @Lc_MinorReasonDescriptionSh_CODE         CHAR(2) = 'SH',
            -- 13633 - LabCorp and Family Court changes to increase success rate - END
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
            @Lc_PetitionSchd_CODE                     CHAR(4) = 'SCHD',
            @Lc_PetitionFild_CODE                     CHAR(4) = 'FILD',
            @Lc_PetitionSrvc_CODE                     CHAR(4) = 'SRVC',
            @Lc_PetitionApfl_CODE                     CHAR(4) = 'APFL',
            @Lc_PetitionTypePetn_CODE                 CHAR(4) = 'PETN',
            @Lc_PetitionTypePetp_CODE                 CHAR(4) = 'PETP',
            @Lc_PetitionTypePetl_CODE                 CHAR(4) = 'PETL', 
            @Lc_PetitionTypeSvn_CODE                  CHAR(4) = 'SVN',
            @Lc_ErrorE0085_CODE						  CHAR(5) = 'E0085',
            @Lc_ErrorE0145_CODE                       CHAR(5) = 'E0145',
            @Lc_ErrorE1380_CODE                       CHAR(5) = 'E1380',
            @Lc_ErrorE1381_CODE                       CHAR(5) = 'E1381',
            @Lc_ErrorE1385_CODE                       CHAR(5) = 'E1385',
            @Lc_ErrorE1386_CODE                       CHAR(5) = 'E1386',
            @Lc_ErrorE1387_CODE                       CHAR(5) = 'E1387',
            @Lc_ErrorE1388_CODE                       CHAR(5) = 'E1388',
            @Lc_ErrorE1389_CODE                       CHAR(5) = 'E1389',
            @Lc_ErrorE1390_CODE                       CHAR(5) = 'E1390',
            @Lc_ErrorE1391_CODE                       CHAR(5) = 'E1391',
            @Lc_ErrorE1392_CODE                       CHAR(5) = 'E1392',
            @Lc_ErrorE1393_CODE                       CHAR(5) = 'E1393',
            @Lc_ErrorE1394_CODE                       CHAR(5) = 'E1394',
            @Lc_ErrorE1395_CODE                       CHAR(5) = 'E1395',
            @Lc_ErrorE1396_CODE                       CHAR(5) = 'E1396',
            @Lc_ErrorE1397_CODE                       CHAR(5) = 'E1397',
            @Lc_ErrorE1398_CODE                       CHAR(5) = 'E1398',
            @Lc_ErrorE1399_CODE                       CHAR(5) = 'E1399',
            @Lc_ErrorE1400_CODE                       CHAR(5) = 'E1400',
            @Lc_ErrorE1401_CODE                       CHAR(5) = 'E1401',
            @Lc_ErrorE1402_CODE                       CHAR(5) = 'E1402',
            @Lc_ErrorE1403_CODE                       CHAR(5) = 'E1403',
            @Lc_BateErrorUnknown_CODE				  CHAR(5) = 'E1424',
            @Lc_ErrorE1977_CODE                       CHAR(5) = 'E1977',
            @Lc_ErrorE1978_CODE						  CHAR(5) = 'E1978',
            @Lc_ErrorE1980_CODE						  CHAR(5) = 'E1980',
            @Lc_DispositionDismi_CODE                 CHAR(5) = 'DISMI',
            @Lc_DispositionDwop_CODE                  CHAR(5) = 'DWOP',
            @Lc_DispositionStdis_CODE                 CHAR(5) = 'STDIS',
            @Lc_DispositionVdism_CODE                 CHAR(5) = 'VDISM',
            @Lc_DispositionDismm_CODE                 CHAR(5) = 'DISMM',
            @Lc_DispositionVd_CODE                    CHAR(5) = 'VD',
            @Lc_DispositionVdcc_CODE                  CHAR(5) = 'VDCC',
            @Lc_DispositionHcont_CODE                 CHAR(5) = 'HCONT',
            @Lc_DispositionHresc_CODE                 CHAR(5) = 'HRESC',
            @Lc_DispositionIconc_CODE                 CHAR(5) = 'ICONC',
            @Lc_DispositionIconj_CODE                 CHAR(5) = 'ICONJ',
            @Lc_DispositionIconm_CODE                 CHAR(5) = 'ICONM',
            @Lc_DispositionIconr_CODE                 CHAR(5) = 'ICONR',
            @Lc_DispositionImmc_CODE                  CHAR(5) = 'IMMC',
            @Lc_DispositionMcont_CODE                 CHAR(5) = 'MCONT',
            @Lc_DispositionMresc_CODE                 CHAR(5) = 'MRESC',
            @Lc_DispositionSchc_CODE                  CHAR(5) = 'SCHC',
            @Lc_DispositionSchj_CODE                  CHAR(5) = 'SCHJ',
            @Lc_DispositionSchm_CODE                  CHAR(5) = 'SCHM',
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
            @Lc_JobProcessPetition_ID                 CHAR(7) = 'DEB8066',
            @Lc_Job_ID                                CHAR(7) = 'DEB8066',
            @Lc_Successful_TEXT                       CHAR(20) = 'SUCCESSFUL',
            @Lc_BatchRunUser_TEXT                     CHAR(30) = 'BATCH',
            @Lc_Parmdateproblem_TEXT                  CHAR(30) = 'PARM DATE PROBLEM',
            @Ls_Court_NAME                            VARCHAR(50) = '%FAMILY COURT%',
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
            @Ln_Exists_NUMB							  NUMERIC(1) = 0,
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
            --13751 - Code changed as part of CR0454 to add file number to DCKT_Y1, DPRS_Y1 tables, if it doesn't exist in DECSS -START-
            @Li_FdemApflCount_QNTY						  SMALLINT,
            --13751 - Code changed as part of CR0454 to add file number to DCKT_Y1, DPRS_Y1 tables, if it doesn't exist in DECSS -END-
            @Lc_Space_TEXT							  CHAR(1) = '',
            @Lc_ServiceMethod_CODE					  CHAR(1) = '',
            @Lc_ServiceFailureReason_CODE			  CHAR(1) = '',
            @Lc_PetitinerPresent_INDC				  CHAR(1) = '',
            @Lc_RespondentPresent_INDC				  CHAR(1) = '',
            @Lc_MedicalCoverage_INDC				  CHAR(1) = '',
            @Lc_FinalDisposition_CODE				  CHAR(1) = '',
            @Lc_DocumentSource_CODE					  CHAR(1) = '',
            @Lc_ApflPetitionerMi_NAME				  CHAR(1) = '',
            @Lc_ApflRespondentMi_NAME				  CHAR(1) = '',
            @Lc_UpdateMinorActivity_INDC			  CHAR(1) = '',
            @Lc_InsertCaseJournal_INDC				  CHAR(1) = '',
            @Lc_Msg_CODE							  CHAR(5) = '',
            @Lc_SchdUnit_CODE						  CHAR(2) = '',
            @Lc_SchdHh_TIME							  CHAR(2) = '',
            @Lc_SchdMm_TIME							  CHAR(2) = '',
            @Lc_ApptStatus_CODE						  CHAR(2) = '',
            @Lc_ServiceState_ADDR					  CHAR(2) = '',
            @Lc_ReasonStatus_CODE					  CHAR(2) = '',
            @Lc_MinorReasonDescription_CODE			  CHAR(2) = '',
            @Lc_ServiceZip2_ADDR					  CHAR(4) = '',
            @Lc_ActivityMajor_CODE					  CHAR(4) = '',
            @Lc_Status_CODE							  CHAR(4) = '',
            @Lc_BateError_CODE						  CHAR(5) = '',
            @Lc_Schd_TIME							  CHAR(5) = '',
            @Lc_SchdHearingType_CODE				  CHAR(5) = '',
            @Lc_ServiceZip1_ADDR					  CHAR(5) = '',
            @Lc_Disposition_CODE					  CHAR(5) = '',
            @Lc_ActivityMinorNext_CODE				  CHAR(5) = '',
            @Lc_ActivityMinor_CODE					  CHAR(5) = '',
            @Lc_SchdOfficer_CODE					  CHAR(7) = '',
            @Lc_DispositionOfficer_CODE				  CHAR(7) = '',
            @Lc_Schd_DATE							  CHAR(8) = '',
            @Lc_SchdFormat_DATE						  CHAR(8) = '',
            @Lc_Service_DATE						  CHAR(8) = '',
            @Lc_ServiceFormat_DATE					  CHAR(8),
            @Lc_PetitionActionFormat_DATE			  CHAR(8) = '',
            @Lc_DispositionDate_TEXT				  CHAR(8) = '',
            @Lc_ApflActionFiled_DATE				  CHAR(8) = '',
            @Lc_ApflActionFiledFormat_DATE			  CHAR(8) = '',
            @Lc_Petition_KEY						  CHAR(8) = '',
            @Lc_ApflPetitionerSsn_NUMB				  CHAR(9) = '',
            @Lc_ApflRespondentSsn_NUMB				  CHAR(9) = '',
            @Lc_ApflPetitionerMci_IDNO				  CHAR(10) = '',
            @Lc_ApflRespondentMci_IDNO				  CHAR(10) = '',
            @Lc_FamilyCourtFile_ID					  CHAR(10) = '',
            @Lc_CaseFamilyCourtFile_ID				  CHAR(10) = '',
            @Lc_ServiceZip_ADDR						  CHAR(15) = '',
            @Lc_ServiceCity_ADDR					  CHAR(16) = '',
            @Lc_ApflPetitionerFirst_NAME			  CHAR(16) = '',
            @Lc_ApflRespondentFirst_NAME			  CHAR(16) = '',
            @Lc_ApflPetitionerLast_NAME				  CHAR(20) = '',
            @Lc_ApflRespondentLast_NAME				  CHAR(20) = '',
            @Lc_SchdOfficer_NAME					  CHAR(29) = '',
            @Lc_DispositionOfficer_NAME				  CHAR(29) = '',
            @Lc_SchdDescription_TEXT				  CHAR(40) = '',
            @Lc_DispositionDescription_TEXT			  CHAR(40) = '',
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
    --Cursor variable declaration 
  DECLARE  @Ln_FcPetRespCur_Seq_IDNO				  NUMERIC(19),
           @Lc_FcPetRespCur_PetitionDispType_CODE	  CHAR(4),
           @Lc_FcPetRespCur_PetitionIdno_TEXT		  CHAR(7),
           @Lc_FcPetRespCur_PetitionSequenceIdno_TEXT CHAR(2),
           @Lc_FcPetRespCur_CaseIdno_TEXT			  CHAR(6),
           @Lc_FcPetRespCur_PetitionType_CODE		  CHAR(4),
           @Lc_FcPetRespCur_PetitionAction_DATE		  CHAR(8),
           @Lc_FcPetRespCur_FamilyCourtFile_ID		  CHAR(10),
           @Ls_FcPetRespCur_RecordTypeData_TEXT		  VARCHAR(198),
           @Ln_FcPetRespCur_Case_IDNO				  NUMERIC(6) = 0,
           @Ln_FcPetRespCur_Petition_IDNO			  NUMERIC(7) = 0;
  -- Cursor declaration for petition response details from the temporary table 
  DECLARE  FcPetResp_CUR INSENSITIVE CURSOR FOR
   SELECT  f.Seq_IDNO,
           f.PetitionDispType_CODE,
           f.Petition_IDNO,
           f.PetitionSequence_IDNO,
           f.Case_IDNO,
           f.PetitionType_CODE,
           f.PetitionAction_DATE,
           f.FamilyCourtFile_ID,
           f.RecordTypeData_TEXT
     FROM  LFCPR_Y1 f 
    WHERE  f.Process_INDC = 'N'
    ORDER BY Seq_IDNO;

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
   SET @Lc_Job_ID = @Lc_JobProcessPetition_ID;
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
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
   -- Check if restart key exists in Restart table.
   /*
   SET @Ls_Sql_TEXT = 'CHECK KEY EXISTS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '');

   SELECT @Ln_Line_NUMB = CAST(r.RestartKey_TEXT AS FLOAT)
     FROM RSTL_Y1 r
    WHERE r.Job_ID = @Lc_Job_ID
      AND r.Run_DATE = @Ld_Run_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
   IF @Li_Rowcount_QNTY = 0
    BEGIN
     SET @Ln_Cur_QNTY = 0;
    END
   ELSE
    BEGIN
     SET @Ln_Cur_QNTY = @Ln_Line_NUMB;
    END
   SET @Ls_Sql_TEXT = 'DELETE DUPLICATE BATE_Y1 RECORDS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ',  EffectiveRun_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Line_NUMB = ' + ISNULL (CAST(@Ln_Cur_QNTY AS VARCHAR), '');
   DELETE BATE_Y1
    WHERE Job_ID = @Lc_Job_ID
      AND EffectiveRun_DATE = @Ld_Run_DATE
      AND Line_NUMB > @Ln_Cur_QNTY; 
   */   
   -- Transaction begins 
   SET @Ls_Sql_TEXT = 'TRASACTION BEGINS';
   SET @Ls_Sqldata_TEXT = '';
   BEGIN TRANSACTION FCPETITION_BATCH_RESPONSE;
   SET @Ls_Sql_TEXT = 'OPEN FAMILY COURT PETITION RESPONSE CURSOR ';
   SET @Ls_Sqldata_TEXT = '';
   OPEN FcPetResp_CUR;

   SET @Ls_Sql_TEXT = 'FETCH FAMILY COURT PETITION RESPONSE CURSOR ';
   SET @Ls_Sqldata_TEXT = '';
   FETCH NEXT FROM FcPetResp_CUR INTO @Ln_FcPetRespCur_Seq_IDNO, @Lc_FcPetRespCur_PetitionDispType_CODE, @Lc_FcPetRespCur_PetitionIdno_TEXT, @Lc_FcPetRespCur_PetitionSequenceIdno_TEXT, @Lc_FcPetRespCur_CaseIdno_TEXT, @Lc_FcPetRespCur_PetitionType_CODE, @Lc_FcPetRespCur_PetitionAction_DATE, @Lc_FcPetRespCur_FamilyCourtFile_ID, @Ls_FcPetRespCur_RecordTypeData_TEXT;
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Process the records in the cursor
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SAVEFCPETITION_BATCH_RESPONSE; 
     -- Do the error check of the family court interface record
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
     SET @Ln_Forum_IDNO = 0;
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     SET @Ls_Sql_TEXT = 'PetitionIdno_TEXT - Conversion';
	 SET @Ls_Sqldata_TEXT = 'PetitionIdno_TEXT = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT;
	 SET @Ls_BateRecord_TEXT = 'Sequence Idno = ' + CAST(@Ln_FcPetRespCur_Seq_IDNO AS VARCHAR) + ', FcPetitionDispType_CODE = ' + ISNULL(@Lc_FcPetRespCur_PetitionDispType_CODE, '') + ', FcPetion_IDNO = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + ', FcCase_IDNO = ' + ISNULL(@Lc_FcPetRespCur_CaseIdno_TEXT, '') + ', FcPetitionType_CODE = ' + ISNULL(@Lc_FcPetRespCur_PetitionType_CODE, '') + ', FcFile_IDNO = ' + ISNULL (@Lc_FcPetRespCur_FamilyCourtFile_ID, '') + ', Record Type Data = ' +@Ls_FcPetRespCur_RecordTypeData_TEXT;
     IF ISNUMERIC(@Lc_FcPetRespCur_PetitionIdno_TEXT) = 1
        AND ISNUMERIC(@Lc_FcPetRespCur_CaseIdno_TEXT) = 1
      BEGIN
       SET @Ln_FcPetRespCur_Petition_IDNO = CAST(@Lc_FcPetRespCur_PetitionIdno_TEXT AS NUMERIC);
       SET @Ln_FcPetRespCur_Case_IDNO = CAST(@Lc_FcPetRespCur_CaseIdno_TEXT AS NUMERIC);
      END
     ELSE
		BEGIN
			SET @Lc_BateError_CODE = @Lc_ErrorE0085_CODE;
			RAISERROR (50001, 16, 1); 
		END
	 --If the petition idno is not a valid value, generate an error into BATE_Y1 and skip the record
     IF ISNULL(@Ln_FcPetRespCur_Petition_IDNO, 0) = 0
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1380_CODE; 
       GOTO lx_exception;
      END
     --If the case number not found, generate an error into BATE_Y1 and skip the record 
     IF ISNULL(@Ln_FcPetRespCur_Case_IDNO, 0) = 0
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1381_CODE; 
       GOTO lx_exception;
      END
     ELSE
      BEGIN
       SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
         FROM CASE_Y1 a
        WHERE a.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
          AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE; 
       IF @Ln_Exists_NUMB = 0
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1381_CODE;  
         GOTO lx_exception;
        END
      END
     -- Code added for CR0192 for processing the petition type records of 'SVN'
     -- We should not receive any records with petition type of 'SVN' and disposition type of 'SRVC', 'APFL', write these records into BATE_Y1 table
     IF @Lc_FcPetRespCur_PetitionType_CODE =  @Lc_PetitionTypeSvn_CODE
     AND @Lc_FcPetRespCur_PetitionDispType_CODE IN (@Lc_PetitionSrvc_CODE, @Lc_PetitionApfl_CODE)
       BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1980_CODE; 
         GOTO lx_exception;
       END  
     
     IF  @Lc_FcPetRespCur_PetitionType_CODE =  @Lc_PetitionTypeSvn_CODE
       BEGIN
         
         EXECUTE BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_SVN_RECORDS
          @An_Case_IDNO							= @Ln_FcPetRespCur_Case_IDNO,
          @An_Petition_IDNO						= @Ln_FcPetRespCur_Petition_IDNO,
          @Ac_PetitionActionDate_TEXT			= @Lc_FcPetRespCur_PetitionAction_DATE,
		  @Ac_FamilyCourtFile_ID				= @Lc_FcPetRespCur_FamilyCourtFile_ID,
		  @As_RecordTypeData_TEXT				= @Ls_FcPetRespCur_RecordTypeData_TEXT,
		  @Ac_PetitionDispType_CODE				= @Lc_FcPetRespCur_PetitionDispType_CODE,
		  @Ac_PetitionType_CODE                 = @Lc_FcPetRespCur_PetitionType_CODE,
		  @Ac_Job_ID							= @Lc_JobProcessPetition_ID,
          @Ad_Run_DATE                          = @Ld_Run_DATE,
		  @Ac_Msg_CODE							= @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT				= @Ls_DescriptionError_TEXT OUTPUT;
         
         IF @Lc_Msg_CODE		= @Lc_StatusFailed_CODE
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
		 -- skip the rest of the process if petition type is 'SVN'
		 SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
		 GOTO lx_exception;   
        END  
     
     -- CR0192 code end
     -- Validate petition type returned, Check the filed record errors 
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionFild_CODE
     
        BEGIN 
         SET @Ls_Sql_TEXT = 'Family Court FILD record  error check';
		 SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT;
         SELECT TOP 1 @Ln_Exists_NUMB = COUNT(1)
           FROM FDEM_Y1 
           WHERE Petition_IDNO = @Ln_FcPetRespCur_Petition_IDNO
             AND DocReference_CODE = @Lc_FcPetRespCur_PetitionType_CODE;
         IF @Ln_Exists_NUMB <> 0
          BEGIN
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE0145_CODE;  
           GOTO lx_exception; 
          END
        END 
     -- Check the scheduling errors 
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionSchd_CODE
      BEGIN
       -- SCHD ERRORS
       SET @Ls_Sql_TEXT = 'Family Court SCHD record  error check';
	   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT;
       SET @Lc_SchdOfficer_NAME = '';
       SET @Lc_SchdUnit_CODE = '';
       SET @Lc_SchdOfficer_CODE = '';
       SET @Lc_Schd_DATE = '';
       SET @Lc_SchdFormat_DATE = '';
       SET @Lc_SchdHh_TIME = '';
       SET @Lc_SchdMm_TIME = '';
       SET @Lc_SchdHearingType_CODE = '';
       SET @Lc_SchdDescription_TEXT = '';
       SET @Lc_SchdOfficer_CODE = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 1, 7);
       SET @Lc_Schd_TIME = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 45, 5);
       SET @Lc_SchdHh_TIME = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 45, 2);
       SET @Lc_SchdMm_TIME = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 48, 2);
       SET @Lc_SchdHearingType_CODE = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 52, 5);
       SET @Lc_SchdDescription_TEXT = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 57, 40);
       SET @Lc_SchdOfficer_NAME = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 8, 29);
       IF ISNULL(@Lc_SchdOfficer_NAME, '') = ''
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1385_CODE;  
         GOTO lx_exception;
        END
 
	   IF ISNULL(@Lc_SchdOfficer_CODE, '') = ''
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1385_CODE;  
         GOTO lx_exception;
        END
       SET @Lc_SchdUnit_CODE = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 50, 2);
       IF ISNULL(@Lc_SchdUnit_CODE, '') = ''
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1387_CODE;  
         GOTO lx_exception;
        END
       IF @Lc_SchdUnit_CODE NOT IN (@Lc_SchdCommissioner_CODE, @Lc_SchdMaster_CODE, @Lc_SchdMediation_CODE, @Lc_SchdGeneticTestBt_CODE, @Lc_SchdJudge_CODE)
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1387_CODE; 
         GOTO lx_exception;
        END
       SET @Lc_Schd_DATE = SUBSTRING (@ls_FcPetRespCur_RecordTypeData_TEXT, 37, 8);
       IF ISNULL(@Lc_Schd_DATE, '') = ''
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1386_CODE; 
         GOTO lx_exception;
        END
       SET @Lc_SchdFormat_DATE = SUBSTRING(@Lc_Schd_DATE, 5, 4) + LEFT(@Lc_Schd_DATE,2) + SUBSTRING(@Lc_Schd_DATE, 3, 2);
       IF (SELECT ISDATE (@Lc_SchdFormat_DATE)) <> 1
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1386_CODE; 
         GOTO lx_exception;
        END
      END
     -- Check the servicing errors
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionSrvc_CODE
      BEGIN
       --SRVC ERROR 
       SET @Ls_Sql_TEXT = 'Family Court SRVC record  error check';
	   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT;
       SET @Lc_ServiceMethod_CODE = '';
       SET @Lc_ServiceMethod_CODE = SUBSTRING(@ls_FcPetRespCur_RecordTypeData_TEXT, 1, 1);
       IF ISNULL(@Lc_ServiceMethod_CODE, '') = ''
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1388_CODE; 
         GOTO lx_exception;
        END

       IF @Lc_ServiceMethod_CODE NOT IN (@Lc_SrvcAffidavitAppearance_CODE, @Lc_SrvcCertifiedMail_CODE, @Lc_SrvcHandDeliveredCourt_CODE, @Lc_SrvcSentLongArm_CODE,
                                         @Lc_SrvcLocalNewsPaper_CODE, @Lc_SrvcPersonalService_CODE, @Lc_SrvcRegularMail_CODE, @Lc_SrvcRegisteredMail_CODE,
                                         @Lc_SrvcAttorney_CODE, @Lc_SrvcCertifiedPublications_CODE, @Lc_SrvcAwaitResponse_CODE, @Lc_SrvcServiceNotSent_CODE)
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1388_CODE; 
         GOTO lx_exception;
        END
       SET @Lc_ServiceResult_CODE = '';
       SET @Lc_ServiceResult_CODE = SUBSTRING(@ls_FcPetRespCur_RecordTypeData_TEXT, 2, 1);
       IF ISNULL (@Lc_ServiceResult_CODE, '') = ''
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1389_CODE;  
         GOTO lx_exception;
        END

       IF @Lc_ServiceResult_CODE NOT IN (@Lc_ServicePositive_CODE, @Lc_ServiceNegative_CODE)
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1389_CODE; 
         GOTO lx_exception;
        END
       SET @Lc_Service_DATE = '';
       SET @Lc_Service_DATE = SUBSTRING(@ls_FcPetRespCur_RecordTypeData_TEXT, 44, 8);
       IF ISNULL (@Lc_Service_DATE, '') = ''
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1390_CODE;  
         GOTO lx_exception;
        END
       SET @Lc_ServiceFormat_DATE = SUBSTRING(@Lc_Service_DATE, 5, 4) + LEFT(@Lc_Service_DATE,2) + SUBSTRING(@Lc_Service_DATE, 3, 2);
       IF (SELECT ISDATE (@Lc_ServiceFormat_DATE)) <> 1
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1390_CODE;  
         GOTO lx_exception;
        END
       -- Check for service date is future date then move the record into BATE_Y1 
       IF CAST(@Lc_ServiceFormat_DATE AS DATETIME2) > @Ld_Start_DATE
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1390_CODE;
         GOTO lx_exception;
        END
      END
     -- Check the disposition errors 
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionDisp_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'Family Court DISP record  error check';
	   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT;
       SET @Lc_FinalDisposition_CODE = '';
       SET @Lc_FinalDisposition_CODE = SUBSTRING (@ls_FcPetRespCur_RecordTypeData_TEXT, 94, 1);
       IF @Lc_FinalDisposition_CODE NOT IN (@Lc_FinalDispositionYes_CODE, @Lc_FinalDispositionNo_CODE)
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1391_CODE;  
         GOTO lx_exception;
        END
       SET @Lc_Disposition_CODE = ' ';
       SET @Lc_Disposition_CODE = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 45, 5);
       SET @Lc_DispositionDescription_TEXT = '';
       SET @Lc_DispositionDescription_TEXT = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 50, 40);
       IF (ISNULL (@Lc_Disposition_CODE, '') =  ''
            OR ISNULL(@Lc_DispositionDescription_TEXT, '') =  '')
         BEGIN
			SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
			SET @Lc_BateError_CODE = @Lc_ErrorE1392_CODE; 
			GOTO lx_exception;
        END
	  END
     -- Check Ap filed errors ('APFL') 
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionApfl_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'Family Court APFL record  error check';
	   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT;
       SET @Lc_ApflPetitionerMci_IDNO = ' ';
       SET @Lc_ApflPetitionerLast_NAME = ' ';
       SET @Lc_ApflPetitionerFirst_NAME = '';
       SET @Lc_ApflPetitionerMi_NAME = '';
       SET @Lc_ApflPetitionerMci_IDNO = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 57, 10);
       IF ISNUMERIC(@Lc_ApflPetitionerMci_IDNO) <> 1
        BEGIN 
         SET @Lc_ApflPetitionerMci_IDNO = '0000000000'
        END
	   SET @Lc_ApflPetitionerLast_NAME = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 11, 20);
       SET @Lc_ApflPetitionerFirst_NAME = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 31, 16);
       SET @Lc_ApflPetitionerMi_NAME = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 47, 1);
       SET @Lc_ApflPetitionerSsn_NUMB = '';
       SET @Lc_ApflPetitionerSsn_NUMB = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 48, 9);
       SET @Lc_ApflRespondentMci_IDNO = '';
       SET @Lc_ApflRespondentLast_NAME = '';
       SET @Lc_ApflRespondentSsn_NUMB = '';
       SET @Lc_ApflRespondentFirst_NAME = '';
       SET @Lc_ApflRespondentMi_NAME = '';
       SET @Lc_ApflRespondentMci_IDNO = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 113, 10);
       IF ISNUMERIC(@Lc_ApflRespondentMci_IDNO) <> 1
        BEGIN 
         SET @Lc_ApflRespondentMci_IDNO = '0000000000'
        END
       SET @Lc_ApflRespondentLast_NAME = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 67, 20);
       SET @Lc_ApflRespondentFirst_NAME = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 87, 16);
       SET @Lc_ApflRespondentMi_NAME = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 103, 1);
       SET @Lc_ApflRespondentSsn_NUMB = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 104, 9);
       SET @Lc_ApflActionFiled_DATE = '';
       SET @Lc_ApflActionFiledFormat_DATE = '';
       SET @Lc_ApflActionFiled_DATE = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 123, 8);
       SET @Lc_ApflActionFiledFormat_DATE = '20' + SUBSTRING(@Lc_ApflActionFiled_DATE, 7, 2) + LEFT(@Lc_ApflActionFiled_DATE,2) + SUBSTRING(@Lc_ApflActionFiled_DATE, 4, 2);
       -- Check for valid action filed date
       IF ISNULL (@Lc_ApflActionFiledFormat_DATE, '') = ''
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1400_CODE;
         GOTO lx_exception;
        END
	   IF (SELECT ISDATE (@Lc_ApflActionFiledFormat_DATE)) <> 1
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1400_CODE;
         GOTO lx_exception;
        END
       -- Check the APFL filing record already exists in DECSS
       SET @Ls_Sql_TEXT = 'Reading FDEM table for APFL record';
	   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + 'Apfl PetitionerMci_IDNO = ' + ISNULL(@Lc_ApflPetitionerMci_IDNO, '') + 'Apfl RespondentMic_IDNO = ' + ISNULL(@Lc_ApflRespondentMci_IDNO, '');
       SELECT @Ln_Exists_NUMB = COUNT(1)
         FROM FDEM_Y1 a
        WHERE a.Case_IDNO			= @Ln_FcPetRespCur_Case_IDNO
		  AND a.Petition_IDNO		= @Ln_FcPetRespCur_Petition_IDNO
		  AND a.Petitioner_IDNO     = @Lc_ApflPetitionerMci_IDNO
		  AND a.Respondent_IDNO     = @Lc_ApflRespondentMci_IDNO
		  AND a.Filed_DATE          = @Lc_ApflActionFiledFormat_DATE
		  AND a.TypeDoc_CODE        = @Lc_DocumentTypeP_CODE
		  AND SourceDoc_CODE		= @Lc_DocumentSourceF_CODE;
	   IF @Ln_Exists_NUMB <> 0
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1403_CODE;
         GOTO lx_exception;
        END 
       -- Check the petiiton number already exists in DECSS
       SELECT @Ln_Exists_NUMB = COUNT(1)
         FROM FDEM_Y1 a 
        WHERE a.Petition_IDNO		= @Ln_FcPetRespCur_Petition_IDNO
	   IF @Ln_Exists_NUMB <> 0
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1393_CODE;
         GOTO lx_exception;
        END
       -- Petitioners's MCI and Last name are missing
       IF @Lc_ApflPetitionerMci_IDNO = '0000000000'
          AND ISNULL (@Lc_ApflPetitionerLast_NAME, '') = ' '
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1394_CODE;
         GOTO lx_exception;
        END
       IF @Lc_ApflPetitionerMci_IDNO = '0000000000'
          AND (ISNULL (@Lc_ApflPetitionerSsn_NUMB, '') = ''
           OR @Lc_ApflPetitionerSsn_NUMB = '000000000')
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1395_CODE;
         GOTO lx_exception;
        END
       IF @Lc_ApflPetitionerMci_IDNO = '0000000000'
          AND (SELECT(ISNUMERIC (@Lc_ApflPetitionerSsn_NUMB))) <> 1
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1395_CODE;
         GOTO lx_exception;
        END
       IF @Lc_ApflPetitionerMci_IDNO = '0000000000'
         AND (SELECT(ISNUMERIC (@Lc_ApflPetitionerSsn_NUMB))) = 1
        BEGIN
         SELECT @Ln_Exists_NUMB = COUNT(1)
           FROM CMEM_Y1 c,
                DEMO_Y1 d
          WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
            AND c.MemberMci_IDNO = d.MemberMci_IDNO
            AND c.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
            AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE
            AND d.MemberSsn_NUMB = @Lc_ApflPetitionerSsn_NUMB;
         IF @Ln_Exists_NUMB = 0
          BEGIN
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE1399_CODE;
           GOTO lx_exception;
          END
        END
       IF @Lc_ApflRespondentMci_IDNO = '0000000000'
          AND ISNULL (@Lc_ApflRespondentLast_NAME, '') = ' '
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1396_CODE;
         GOTO lx_exception;
        END
       IF @Lc_ApflRespondentMci_IDNO = '0000000000'
          AND (SELECT(ISNUMERIC (@Lc_ApflRespondentSsn_NUMB))) <> 1
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE1397_CODE;
         GOTO lx_exception;
        END
       IF @Lc_ApflRespondentMci_IDNO = '0000000000'
         AND (SELECT(ISNUMERIC (@Lc_ApflRespondentSsn_NUMB))) = 1
        BEGIN
         SELECT @Ln_Exists_NUMB = COUNT(1)
           FROM CMEM_Y1 c,
                DEMO_Y1 d
          WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
            AND c.MemberMci_IDNO = d.MemberMci_IDNO
            AND c.CaseRelationship_CODE = @Lc_CaseRelationshipClient_CODE
            AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE
            AND d.MemberSsn_NUMB = @Lc_ApflRespondentSsn_NUMB;
         IF @Ln_Exists_NUMB = 0
          BEGIN
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE1398_CODE;
           GOTO lx_exception;
          END
        END
       -- Check the petitioner name and ncp name on the case are same on the case 	
       IF @Lc_ApflPetitionerMci_IDNO = '0000000000'
        BEGIN
         SELECT @Ln_Exists_NUMB = COUNT(1)
           FROM CMEM_Y1 c,
                DEMO_Y1 d
          WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
            AND c.MemberMci_IDNO = d.MemberMci_IDNO
            AND c.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
            AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE
            AND d.MemberSsn_NUMB = @Lc_ApflPetitionerSsn_NUMB
            AND d.Last_NAME = UPPER(@Lc_ApflPetitionerLast_NAME);
         IF @Ln_Exists_NUMB = 0
          BEGIN
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE1401_CODE;
           GOTO lx_exception;
          END
        END
       -- Check the respondent name and client name are same on the case
       IF @Lc_ApflRespondentMci_IDNO = '0000000000'
        BEGIN
         SELECT @Ln_Exists_NUMB = COUNT(1)
           FROM CMEM_Y1 c,
                DEMO_Y1 d
          WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
            AND c.MemberMci_IDNO = d.MemberMci_IDNO
            AND c.CaseRelationship_CODE = @Lc_CaseRelationshipClient_CODE
            AND c.CaseMemberStatus_CODE = @Lc_CaseMemberActive_CODE
            AND d.MemberSsn_NUMB = @Lc_ApflRespondentSsn_NUMB
            AND d.Last_NAME = UPPER(@Lc_ApflRespondentLast_NAME);
         IF @Ln_Exists_NUMB = 0
          BEGIN
           SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
           SET @Lc_BateError_CODE = @Lc_ErrorE1402_CODE;
           GOTO lx_exception;
          END
        END
      END
     -- Process petition response type 'FILD' records
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionFild_CODE
      BEGIN
       
       SET @Ls_Sql_TEXT = 'Process FILD  records';
	   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + 'FILD Major Seq NUMB = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR) + 'FC File ID = ' + ISNULL(@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
       SET @Lc_Petition_KEY = '';
       SET @Ln_MajorIntSeq_NUMB = 0;
       SET @Ln_Petitioner_IDNO = 0;
       SET @Ln_Respondent_IDNO = 0;
       SET @Ln_Forum_IDNO = 0;
       SET @Lc_Petition_KEY = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 81, 8);
       IF ISNUMERIC(@Lc_Petition_KEY) <> 1 
		BEGIN
			SET @Ln_PetitionKey_IDNO = 0;
		END
	   ELSE
		BEGIN
			SET @Ln_PetitionKey_IDNO = CAST(LTRIM(RTRIM(@Lc_Petition_KEY)) AS NUMERIC);
		END
       SET @Ln_MajorIntSeq_NUMB = @Ln_PetitionKey_IDNO;
      
       -- CR 310 Changes start
       IF @Ln_MajorIntSeq_NUMB = @Ln_Zero_NUMB
         BEGIN
          SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
		  SET @Lc_BateError_CODE = @Lc_ErrorE1977_CODE;
          RAISERROR(50001,16,1);
         END
       -- CR 310 End
       SET @Ls_DescriptionNote_TEXT = '';
       SET @Ls_DescriptionNote_TEXT = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 1, 80);
       --Convert the petition action date in CCYYMMDD format from the incoming MMDDCCYY format        
         SET @Lc_PetitionActionFormat_DATE = SUBSTRING(@Lc_FcPetRespCur_PetitionAction_DATE, 5, 4) + LEFT(@Lc_FcPetRespCur_PetitionAction_DATE,2) + SUBSTRING(@Lc_FcPetRespCur_PetitionAction_DATE, 3, 2);
         SET @Ld_PetitionAction_DATE = @Lc_PetitionActionFormat_DATE;
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

       EXECUTE BATCH_EST_INCOMING_FC_RTPR$SP_PROCESS_FILD_RECORDS
          @An_Case_IDNO							= @Ln_FcPetRespCur_Case_IDNO,
          @An_MajorIntSeq_NUMB					= @Ln_MajorIntSeq_NUMB,
          @An_Petition_IDNO						= @Ln_FcPetRespCur_Petition_IDNO,
          @Ad_PetitionAction_DATE				= @Ld_PetitionAction_DATE,
          @An_TransactionEventSeq_NUMB			= @Ln_TransactionEventSeq_NUMB,
          @Ac_FcPetRespCur_FamilyCourtFile_ID	= @Lc_FcPetRespCur_FamilyCourtFile_ID,
          @Ad_Start_DATE                        = @Ld_Start_DATE,
          @Ac_PetitionType_CODE					= @Lc_FcPetRespCur_PetitionType_CODE,
          @Ac_Job_ID							= @Lc_JobProcessPetition_ID,
          @As_DescriptionNote_TEXT				= @Ls_DescriptionNote_TEXT,
          @Ad_Run_DATE                          = @Ld_Run_DATE,
          @Ac_Msg_CODE							= @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT				= @Ls_DescriptionError_TEXT OUTPUT;
       IF @Lc_Msg_CODE		= @Lc_StatusFailed_CODE
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
      
     -- Process petition response type 'SCHD' records
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionSchd_CODE
      BEGIN
       SET @Ld_BeginSch_DTTM   = CAST(CAST(@Lc_SchdFormat_DATE AS DATE) AS DATETIME) + CAST(@Lc_Schd_TIME AS TIME);
       SET @Ld_EndSch_DTTM     = CAST(CAST(@Lc_SchdFormat_DATE AS DATE) AS DATETIME) + CAST(@Lc_Schd_TIME AS TIME) + CAST('00:30' AS TIME);
       IF SUBSTRING(@Lc_FcPetRespCur_FamilyCourtFile_ID, 1, 2) = @Lc_CountyCn_CODE
		BEGIN
			SET @Ls_OthpCounty_NAME = @Ls_CountyNewCastleFc_NAME;
			SET @Ln_County_IDNO = @Ln_County3_IDNO;
		END
	   ELSE
		IF SUBSTRING(@Lc_FcPetRespCur_FamilyCourtFile_ID, 1, 2) = @Lc_CountyCs_CODE
			BEGIN
			 SET @Ls_OthpCounty_NAME = @Ls_CountySussexFc_NAME;
			 SET @Ln_County_IDNO = @Ln_County5_IDNO;
		   END
		ELSE
			IF SUBSTRING(@Lc_FcPetRespCur_FamilyCourtFile_ID, 1, 2) = @Lc_CountyCk_CODE
				BEGIN
					SET @Ls_OthpCounty_NAME = @Ls_CountyKentFc_NAME;
					SET @Ln_County_IDNO = @Ln_County1_IDNO;
				END
			ELSE
				BEGIN
					-- GET CASE COUNTY FROM THE CASE TABLE
					SELECT  @Ln_County_IDNO = COUNTY_IDNO 
					 FROM CASE_Y1 c 
					 WHERE c.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO;
					IF @Ln_County_IDNO = @Ln_County1_IDNO
						BEGIN
							SET @Ls_OthpCounty_NAME = @Ls_CountyKentFc_NAME;
						END
					ELSE
						IF @Ln_County_IDNO = @Ln_County3_IDNO
							BEGIN 
								SET @Ls_OthpCounty_NAME = @Ls_CountyNewCastleFc_NAME;
							END
						ELSE
							IF @Ln_County_IDNO = @Ln_County5_IDNO
								BEGIN
									SET @Ls_OthpCounty_NAME = @Ls_CountySussexFc_NAME;
								END
							ELSE
								IF @Ln_County_IDNO = @Ln_County1_IDNO
									BEGIN
										SET @Ls_OthpCounty_NAME = @Ls_CountyKentFc_NAME;
									END
								ELSE
									BEGIN
										SET @Ls_OthpCounty_NAME = @Ls_CountyNewCastleFc_NAME;
									END
				END
			
       SELECT TOP 1 @Ln_Othp_IDNO = v.OtherParty_IDNO
         FROM OTHP_Y1 v
         WHERE v.County_IDNO   = @Ln_County_IDNO
          AND v.TypeOthp_CODE = @Lc_TypeOthp_CODE
          AND v.OtherParty_NAME LIKE @Ls_Court_NAME;
       -- Get the sequence number
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
       SET @Ls_Note1_TEXT = '';
       SET @Ls_Note2_TEXT = '';
       SET @Ls_Note3_TEXT = '';
       SET @Ls_Note1_TEXT  = 'Scheduling Information has been received outside of the activity chain. Review Scheduling Details link for more information.';
       SET @Ls_Note2_TEXT  = 'Review the data below and proceed accordingly:' + ' Scheduling Unit:' + @Lc_SchdUnit_CODE + ' Proceding Type:' + @Lc_SchdHearingType_CODE 
       + 'Case ID:' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ' File Number:' + @Lc_FcPetRespCur_FamilyCourtFile_ID 
	   + ' Petition Number:' + @Lc_FcPetRespCur_PetitionIdno_TEXT  + ' Event Start Date:' + @Lc_Schd_DATE + ' Start Time:' + @Lc_Schd_TIME
	   + ' Officiating ID/Officer Code:' + @Lc_SchdOfficer_CODE + ' Officer Name:' + @Lc_SchdOfficer_NAME +  ' Notes: ' + @Lc_SchdDescription_TEXT;
	   SET @Ls_Note3_TEXT = 'Scheduling Information received on an NCP filed petition. View the Scheduling Details for more information.';
	   SET @Ls_DescriptionNote_TEXT = '';
       SET @Ls_DescriptionNote_TEXT = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 57, 40);
	   SET @Ls_Sql_TEXT = 'READING FDEM_Y1 TABLE IN SCHD REPONSE RECORD';
       SET @Ls_Sqldata_TEXT = 'Case IDNO  = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', File Number = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + ', Petition Number = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
       SELECT TOP 1 @Ln_MajorIntSeq_NUMB = m.MajorIntSEQ_NUMB,
                    @Lc_DocumentSource_CODE = m.SourceDoc_CODE,
                    @Ln_Respondent_IDNO   =  m.Respondent_IDNO,
                    @Ln_Petitioner_IDNO   =  m.Petitioner_IDNO
                    
         FROM FDEM_Y1 m
        WHERE m.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
          AND m.File_ID = @Lc_FcPetRespCur_FamilyCourtFile_ID
          AND m.Petition_IDNO = @Ln_FcPetRespCur_Petition_IDNO;
		
        -- CR 310 Changes start
       SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
       
       IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
         BEGIN
          SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
		  SET @Lc_BateError_CODE = @Lc_ErrorE1978_CODE;
          RAISERROR(50001,16,1);
         END
       -- CR 310 End
       
       SET @Ls_Sql_TEXT = 'READING DMNR_Y1 TABLE IN SCHD REPONSE RECORD';
       SET @Ls_Sqldata_TEXT = 'Case IDNO  = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', File Number = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + ', Petition Number = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
       SELECT TOP 1 @Lc_ActivityMinor_CODE = n.ActivityMinor_CODE,
                    @Lc_ReasonStatus_CODE = n.ReasonStatus_CODE,
                    @Lc_Status_CODE = n.Status_CODE,
                    @Ln_MinorIntSeq_NUMB = n.MinorIntSeq_NUMB,
                    @Lc_ActivityMajor_CODE = n.ActivityMajor_CODE,
                    @Ln_OrderSeq_NUMB          = n.OrderSeq_NUMB,
                    @Ln_Schedule_NUMB      = n.Schedule_NUMB,
                    @Ln_Forum_IDNO         = n.Forum_IDNO,
                    @Ln_Topic_IDNO         = n.Topic_IDNO
         FROM DMNR_Y1 n
        WHERE n.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
          AND n.MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
          AND n.ActivityMajor_CODE IN (@Lc_MajorActivityEstp_CODE, @Lc_MajorActivityMapp_CODE, @Lc_MajorActivityRofo_CODE)
        ORDER BY MinorIntSeq_NUMB DESC;
       SET @Li_Rowcount_QNTY = @@ROWCOUNT;
       SET @Ls_Schedule_MemberMci_IDNO = CAST(@Ln_Respondent_IDNO AS VARCHAR) + ',' + CAST(@Ln_Petitioner_IDNO AS VARCHAR);
       SELECT @Ls_Schedule_MemberMci_IDNO = COALESCE(@Ls_Schedule_MemberMci_IDNO + ',', ' ') + CAST(MemberMci_IDNO AS VARCHAR) FROM CMEM_Y1 WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO 
               AND CaseRelationship_CODE = @Lc_DependentType_CODE AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE;
       IF (@Li_Rowcount_QNTY = @Ln_Zero_NUMB
            OR @Lc_DocumentSource_CODE = @Lc_DocumentSourceF_CODE)
        BEGIN
         -- If no data found, generate information alert to the worker 
         IF @Lc_DocumentSource_CODE = @Lc_DocumentSourceF_CODE
          -- Generate ap filed case journal entry SRFNP
            BEGIN
				
		/* code for creating SRFNP unscheduled proceeding for ap filed petitions at family court */
								
				SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE Srfnp';
				SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'File_ID  = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + 'PetitionIdno_TEXT = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
				
				EXECUTE BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE
					@An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
				    @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
				    @An_MemberMci_IDNO           = @Ln_Respondent_IDNO, 
				    @An_Forum_IDNO               = @Ln_Zero_NUMB,
				    @An_Topic_IDNO               = @Ln_Zero_NUMB,
				    @An_MajorIntSeq_NUMB         = @Ln_Zero_NUMB,
				    @An_MinorIntSeq_NUMB         = @Ln_Zero_NUMB,
				    @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
				    @Ac_ActivityMinor_CODE       = @Lc_MinorActivitySrfnp_CODE,
				    @Ac_ReasonStatus_CODE        = @Lc_MinorReasonDescriptionSy_CODE,
				    @As_DescriptionNote_TEXT     = @Ls_Note3_TEXT,
				    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
				    @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
				    @Ad_Run_DATE                 = @Ld_Run_DATE,
				    @As_Process_ID               = @Lc_Job_ID,
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
					RAISERROR(50001,16,1);
				  END
				-- Update the minor SRFNP Major Int Seq Number to FDEM_Y1 Major Int Seq number for the same petition
								
				SET @Ls_Sql_TEXT = 'Reading DMNR table for SRFNP minor created in above step';
				SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'File_ID  = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + 'PetitionIdno_TEXT = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
				SELECT TOP 1 @Ln_MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
				  FROM DMNR_Y1 n
				  WHERE n.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
				  AND n.ActivityMinor_CODE = @Lc_MinorActivitySrfnp_CODE
				  AND n.ActivityMajor_CODE = @Lc_MajorActivityCase_CODE
				  AND n.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB;
				
				SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				IF @Li_Rowcount_QNTY <> @Ln_Zero_NUMB
				  BEGIN 
				    SET @Ls_Sql_TEXT = 'Updating the table FDEM_Y1 for SCHD record';
					SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'File_ID  = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + 'PetitionIdno_TEXT = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
				    UPDATE FDEM_Y1
				     SET MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
				    WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
					  AND File_ID = @Lc_FcPetRespCur_FamilyCourtFile_ID
					  AND Petition_IDNO = @Ln_FcPetRespCur_Petition_IDNO;
					 SET @Li_Rowcount_QNTY = @@ROWCOUNT;
					 IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'FDEM_Y1 TABLE UPDATE FAILED';
						RAISERROR(50001,16,1);
					  END 
				  END 
			END
         ELSE
          BEGIN
           -- Generate other case journal entry
			SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_INSERT_ACTIVITY Pfsrf';
			SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'File_ID  = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + 'PetitionIdno_TEXT = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
			
			EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
					@An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
					@An_MemberMci_IDNO           = @Ln_Respondent_IDNO,
					@Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
					@Ac_ActivityMinor_CODE       = @Lc_MinorActivityPfsrf_CODE,
					@As_DescriptionNote_TEXT     = @Ls_Note2_TEXT,
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
       ELSE
        BEGIN
         -- Update the minor activity and move the activity chain
         --Condition 1 & 2
         -- 13633 - LabCorp and Family Court changes to increase success rate - START -
         IF @Lc_ActivityMinor_CODE IN (@Lc_MinorActivityAschd_CODE, @Lc_ActivityMinorFamup_CODE, @Lc_ActivityMinorAordd_CODE)
         -- 13633 - LabCorp and Family Court changes to increase success rate - END -
            AND @Lc_Status_CODE = @Lc_MinorStatusStart_CODE 
          BEGIN
           -- Call common routine for updating the minor activity diary
           --13633 - LabCorp and Family Court changes to increase success rate - START -
           IF @Lc_ActivityMinor_CODE = @Lc_ActivityMinorAordd_CODE
            BEGIN 
			 SET @Lc_MinorReasonDescription_CODE = @Lc_MinorReasonDescriptionSh_CODE;
			END
		   ELSE
		  -- 13633 - LabCorp and Family Court changes to increase success rate - END -
		    BEGIN	 
             IF @Lc_SchdHearingType_CODE IN (@Lc_SchdGeneticTestBt_CODE, @Lc_SchdHearingTentativeHt_CODE,@Lc_SchdMediationHearingTentativeMt_CODE)
				BEGIN
					IF @Lc_ActivityMajor_CODE = @Lc_MajorActivityMapp_CODE
					   BEGIN 
					    SET @Lc_MinorReasonDescription_CODE = @Lc_MinorReasonDescriptionTr_CODE;
					   END
					ELSE
					 BEGIN    
						SET @Lc_MinorReasonDescription_CODE = @Lc_MinorReasonDescriptionTe_CODE;
					 END
				END
			 ELSE
				IF @Lc_SchdHearingType_CODE IN (@Lc_SchdGeneticTestHearingB_CODE,@Lc_SchdConferenceC_CODE,@Lc_SchdHearingH_CODE,@Lc_SchdMediationHearingM_CODE,
												@Lc_SchdTeleconferenceT_CODE,@Lc_SchdPretrialP_CODE)
					BEGIN
						SET @Lc_MinorReasonDescription_CODE = @Lc_MinorReasonDescriptionCg_CODE;
					END
			END
			-- Check an existing scheduling record for this minor
			--If found, update the appointment status to conducted ('CN')
			IF @Ln_Schedule_NUMB  <> @Ln_Zero_NUMB
				BEGIN
					SET @Ls_Sql_TEXT = 'UPDATE SWKS_Y1 TABLE ';
					SET @Ls_SqlData_TEXT = 'Case IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', Schedule Number = ' + CAST(@Ln_Schedule_NUMB AS VARCHAR);
					SELECT TOP 1 @Lc_ApptStatus_CODE = s.ApptStatus_CODE
					FROM SWKS_Y1 s
					WHERE s.Schedule_NUMB = @Ln_Schedule_NUMB;
					SET @Li_Rowcount_QNTY = @@ROWCOUNT;
					IF @Li_Rowcount_QNTY <> @Ln_Zero_NUMB
						BEGIN
							UPDATE SWKS_Y1 
							SET ApptStatus_CODE = @Lc_ApptStatusCn_CODE
							WHERE Schedule_NUMB = @Ln_Schedule_NUMB;
							SET @Li_Rowcount_QNTY = @@ROWCOUNT;
							IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
								BEGIN
									RAISERROR (50001, 16, 1);
								END
						END
				END
				        
				SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_INSERT_ACTIVITY ';
				SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'File_ID  = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + 'PetitionIdno_TEXT = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
			
				EXECUTE BATCH_COMMON$SP_UPDATE_MINOR_INSERT_SCHEDULE
					@An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
				    @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
				    @An_MemberMci_IDNO           = @Ln_Respondent_IDNO, 
				    @An_Forum_IDNO               = @Ln_Forum_IDNO,
				    @An_Topic_IDNO               = @Ln_Topic_IDNO,
				    @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
				    @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
				    @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
				    @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
				    @Ac_ReasonStatus_CODE        = @Lc_MinorReasonDescription_CODE,
				    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
				    @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
				    @Ad_Run_DATE                 = @Ld_Run_DATE,
				    @As_Process_ID               = @Lc_Job_ID,
				    @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
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
				   RAISERROR(50001,16,1);
				  END
		  END
         ELSE
          BEGIN
           -- Generate the information alert for the worker for petition tracking was out of sync PFSRF
           --Condition 3 
			SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_INSERT_ACTIVITY Pfsrf 2';
			SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'File_ID  = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + 'PetitionIdno_TEXT = ' + CAST(@Ln_FcPetRespCur_Petition_IDNO AS VARCHAR);
			EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
					@An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
					@An_MemberMci_IDNO           = @Ln_Respondent_IDNO,
					@Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
					@Ac_ActivityMinor_CODE       = @Lc_MinorActivityPfsrf_CODE,
					@As_DescriptionNote_TEXT     = @Ls_Note2_TEXT,
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
						--SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY 1 FAILED';
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
     -- Process petition response type 'SRVC' records 
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionSrvc_CODE
      BEGIN
       -- Set the cursor data for servicing into local variables.
       SET @Ls_Sql_TEXT = 'Processing SRVC  records';
	   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') +  'FC File ID = ' + ISNULL(@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
       SET @Lc_UpdateMinorActivity_INDC = 'N';
       SET @Lc_InsertCaseJournal_INDC = 'N';
       SET @Lc_ServiceMethod_CODE = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 1, 1);
       SET @Lc_ServiceResult_CODE = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 2, 1);
       SET @Lc_ServiceFailureReason_CODE = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 3, 1);
       SET @Ls_ServiceNotes_TEXT = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 4, 40);
       SET @Lc_Service_DATE = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 44, 8);
       SET @Ls_ServiceLine1_ADDR = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 52, 31); 
       SET @Ls_ServiceLine2_ADDR = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 83, 31); 
       SET @Lc_ServiceCity_ADDR = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 114, 16); 
       SET @Lc_ServiceState_ADDR = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 130, 2); 
       SET @Lc_ServiceZip1_ADDR = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 132, 5);  
       SET @Lc_ServiceZip2_ADDR = SUBSTRING(@Ls_FcPetRespCur_RecordTypeData_TEXT, 137, 4);  
       SET @Ld_Service_DATE = @Lc_ServiceFormat_DATE;
       IF ISNULL (@Lc_ServiceZip2_ADDR, '') <> ''
        BEGIN
         SET @Lc_ServiceZip_ADDR = @Lc_ServiceZip1_ADDR + '-' + @Lc_ServiceZip2_ADDR;
        END
       ELSE
        BEGIN
         SET @Lc_ServiceZip_ADDR = @Lc_ServiceZip1_ADDR;
        END
       -- Format the note for case journal or minor activity update
       SET @Ls_Note_TEXT = '';
       SET @Ls_Note1_TEXT =  '';
       SET @Ls_Note2_TEXT = '';
       SET @Ls_Note3_TEXT = '';
       -- 13603 Start
       SET @Ln_MemberMci_IDNO = 0;
       -- 13603 End
       SET @Ls_Note3_TEXT = 'Service results have been received for Petition Number ' + @Lc_FcPetRespCur_PetitionIdno_TEXT + ' outside of the activity chain.' + ' Review the FDEM record for more information ';
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
       SET @Ln_MajorIntSeq_NUMB = 0;
       SELECT TOP 1 @Ln_MajorIntSeq_NUMB = m.MajorIntSEQ_NUMB,
					@Ln_MemberMci_IDNO  = m.Respondent_IDNO,
					@Ld_PetitionAction_DATE = m.Filed_DATE,
					@Ln_MinorIntSeq_NUMB = m.MinorIntSeq_NUMB
         FROM FDEM_Y1 m
        WHERE m.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
          AND m.File_ID = @Lc_FcPetRespCur_FamilyCourtFile_ID
          AND m.Petition_IDNO = @Ln_FcPetRespCur_Petition_IDNO;
       -- If no FDEM records found in the system, move the record to the exception 
       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY <> @Ln_Zero_NUMB
        BEGIN
         -- Create a case journal entry, skip the rest of the process    
         --Update the service information table 
           SET @Ls_Sql_TEXT = 'READING DEMO TABLE FOR FULL DISPLY NAME' ;
           SET @Ls_Sqldata_TEXT = 'RESPONDENTMCI_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR) ;
           SELECT @Ls_FullDisplay_NAME = D.FullDisplay_NAME
             FROM DEMO_Y1 d
             WHERE d.MemberMci_IDNO = @Ln_MemberMci_IDNO;
           SET @Li_Rowcount_QNTY = @@ROWCOUNT;
           IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB 
			BEGIN 
				SET @Ls_FullDisplay_NAME = 'Respondent on petition';
			END
		   SET @Ls_Sql_TEXT = 'READING REFM TABLE FOR FULL DISPLY NAME' ;
           SET @Ls_Sqldata_TEXT = 'TABLE ID = ' + 'FMIS ' + ', SUB TABLE ID = ' + 'SERE ';
           SELECT @Ls_SereDescriptionValue_TEXT = DescriptionValue_TEXT
			 FROM REFM_Y1 r
			 WHERE r.Table_ID = 'FMIS' and r.TableSub_ID = 'SERE' AND r.Value_CODE = @Lc_ServiceResult_CODE;
		   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
           IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB 
			BEGIN 
				SET @Ls_SereDescriptionValue_TEXT = '';
			END
		   SET @Ls_Sql_TEXT = 'READING REFM TABLE FOR FULL DISPLY NAME' ;
           SET @Ls_Sqldata_TEXT = 'TABLE ID = ' + 'FMIS ' + ', SUB TABLE ID = ' + 'SRFF ';
           SELECT @Ls_SrffDescriptionValue_TEXT = DescriptionValue_TEXT
			 FROM REFM_Y1 r
			 WHERE r.Table_ID = 'FMIS' and r.TableSub_ID = 'SRFF' AND r.Value_CODE = @Lc_ServiceFailureReason_CODE;
		   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
           IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB 
			BEGIN 
				SET @Ls_SrffDescriptionValue_TEXT = '';
			END	               		   
		   SET @Ls_Note1_TEXT = 'The attempt of service on ' + @Ls_FullDisplay_NAME + ' at ' + @Ls_ServiceLine1_ADDR + ' ' + @Ls_ServiceLine2_ADDR + '' + @Lc_ServiceCity_ADDR + '' + @Lc_ServiceState_ADDR + ' ' + @Lc_ServiceZip_ADDR + 'for Petition ' + @Lc_FcPetRespCur_PetitionIdno_TEXT
       			+ ' has been ' + @Ls_SereDescriptionValue_TEXT + '. The FAMIS user added these ' + 'additional comments: ' + @Ls_ServiceNotes_TEXT;
			SET @Ls_Note2_TEXT = 'The attempt of service on ' + @Ls_FullDisplay_NAME + ' at ' + @Ls_ServiceLine1_ADDR + ' ' + @Ls_ServiceLine2_ADDR + '' + @Lc_ServiceCity_ADDR + '' + @Lc_ServiceState_ADDR + ' ' + @Lc_ServiceZip_ADDR + 'for Petition ' + @Lc_FcPetRespCur_PetitionIdno_TEXT + ' has been ' + @Ls_SereDescriptionValue_TEXT + '. Reason for failure is ' + @Ls_SrffDescriptionValue_TEXT + '. The FAMIS user added these ' + 'additional comments: ' + @Ls_ServiceNotes_TEXT;
			
		   SET @Ls_Sql_TEXT = 'Calling ProcedureBATCH_EST_INCOMING_FC_RTPR$SP_UPDATE_FSRT';
		   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + 'FILD Major Seq NUMB = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR) + 'FC File ID = ' + ISNULL(@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
	   
		   EXECUTE BATCH_EST_INCOMING_FC_RTPR$SP_UPDATE_FSRT
				@An_Case_IDNO                 = @Ln_FcPetRespCur_Case_IDNO,
				@Ac_File_ID                   = @Lc_FcPetRespCur_FamilyCourtFile_ID,
				@An_MajorIntSeq_NUMB          = @Ln_MajorIntSeq_NUMB,
				@An_MinorIntSeq_NUMB          = @Ln_MinorIntSeq_NUMB,
				@An_Petition_IDNO             = @Ln_FcPetRespCur_Petition_IDNO,
				@Ac_ServiceMethod_CODE        = @Lc_ServiceMethod_CODE,
				@Ac_ServiceResult_CODE        = @Lc_ServiceResult_CODE,
				@Ac_ServiceFailureReason_CODE = @Lc_ServiceFailureReason_CODE,
				@As_ServiceLine1_ADDR         = @Ls_ServiceLine1_ADDR,
				@As_ServiceLine2_ADDR         = @Ls_ServiceLine2_ADDR,
				@Ac_ServiceCity_ADDR          = @Lc_ServiceCity_ADDR,
				@Ac_ServiceState_ADDR         = @Lc_ServiceState_ADDR,
				@Ac_ServiceZip_ADDR           = @Lc_ServiceZip_ADDR,
				@As_ServiceNotes_TEXT         = @Ls_ServiceNotes_TEXT,
				@Ad_Run_DATE                  = @Ld_Run_DATE,
				@Ad_Service_DATE              = @Ld_Service_DATE,
				@Ad_PetitionAction_DATE		  = @Ld_PetitionAction_DATE,
				@An_TransactionEventSeq_NUMB  = @Ln_TransactionEventSeq_NUMB,
				@Ac_Msg_code                  = @Lc_Msg_code OUTPUT,
				@As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT OUTPUT;
	        
		   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
			BEGIN
			 RAISERROR(50001,16,1);
			END
		   
		   SET @Ls_Sql_TEXT = 'Reading DMNR_Y1 Table';
		   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + 'FILD Major Seq NUMB = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR) + 'FC File ID = ' + ISNULL(@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
		   SELECT TOP 1 @Lc_ActivityMinor_CODE = n.ActivityMinor_CODE,
                    @Lc_ReasonStatus_CODE = n.ReasonStatus_CODE,
                    @Lc_ActivityMajor_CODE = n.ActivityMajor_CODE,
                    @Ln_OrderSeq_NUMB = n.OrderSeq_NUMB,
                    @Ln_Topic_IDNO = n.Topic_IDNO,
                    @Ln_Forum_IDNO = n.Forum_IDNO,
                    @Lc_Status_CODE = n.Status_CODE,
                    @Ln_MinorIntSeq_NUMB = n.MinorIntSeq_NUMB
			FROM DMNR_Y1 n
			WHERE n.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
			AND n.MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
			AND n.ActivityMajor_CODE IN (@Lc_MajorActivityEstp_CODE, @Lc_MajorActivityRofo_CODE) 
			ORDER BY MinorIntSeq_NUMB DESC;

		   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
			IF @Li_Rowcount_QNTY <> @Ln_Zero_NUMB
			  BEGIN
         
				IF @Lc_ActivityMinor_CODE = @Lc_MinorActivityAserr_CODE
				AND @Lc_Status_CODE = @Lc_MinorStatusStart_CODE
				  BEGIN
           -- Call the update the minor activity procedure to move the activity chain
					SET @Lc_UpdateMinorActivity_INDC = 'Y';

					IF @Lc_ServiceResult_CODE = 'P'
						BEGIN
							SET @Lc_MinorReasonDescription_CODE = @Lc_MinorReasonDescriptionSc_CODE;
						END
					ELSE
						BEGIN
							SET @Lc_MinorReasonDescription_CODE = @Lc_MinorReasonDescriptionNd_CODE;
						END
         
				  END
				ELSE 
					BEGIN
							SET @Lc_InsertCaseJournal_INDC = 'Y';
					END
			  END
       
			ELSE
				BEGIN
					SET @Lc_InsertCaseJournal_INDC = 'Y';
				END
	    END
	   ELSE
		  BEGIN
			SET @Lc_InsertCaseJournal_INDC = 'Y';
		  END
      
       -- Call the update minor activity procedure, if the flag is set 
       IF @Lc_UpdateMinorActivity_INDC = 'Y'
        BEGIN
         SET @Ls_Note_TEXT = '';
         IF @Lc_MinorReasonDescription_CODE = @Lc_MinorReasonDescriptionSc_CODE
          BEGIN
           SET @Ls_Note_TEXT = @Ls_Note1_TEXT;
          END
         ELSE IF @Lc_MinorReasonDescription_CODE = @Lc_MinorReasonDescriptionNd_CODE
          BEGIN
           SET @Ls_Note_TEXT = @Ls_Note2_TEXT;
          END
         
         SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY';
		 SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + 'FILD Major Seq NUMB = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR) + 'FC File ID = ' + ISNULL(@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
		 
         EXECUTE BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
          @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
          @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @An_Forum_IDNO               = @Ln_Forum_IDNO,
          @An_Topic_IDNO               = @Ln_Topic_IDNO,
          @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
          @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
          @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
          @Ac_ReasonStatus_CODE        = @Lc_MinorReasonDescription_CODE,
          @As_DescriptionNote_TEXT	   = @Ls_Note_TEXT,
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

       -- Call the insert activity procedure, if the flag is set 
       IF @Lc_InsertCaseJournal_INDC = 'Y'
        BEGIN
         SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_INSERT_ACTIVITY';
		 SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + 'FILD Major Seq NUMB = ' + 'FC File ID = ' + ISNULL(@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
		 
         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_MinorActivityPsrrf_CODE,
          @As_DescriptionNote_TEXT     = @Ls_Note3_TEXT,
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
       -- Check for negative service result and service failure reason is not ncp evading, create case journal entry
       IF @Lc_ServiceResult_CODE = 'N'
          AND @Lc_ServiceFailureReason_CODE <> 'E'
        BEGIN
         
         SET @Ls_Sql_TEXT = 'Calling Procedure BATCH_COMMON$SP_INSERT_ACTIVITY';
		 SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + 'FILD Major Seq NUMB = ' + 'FC File ID = ' + ISNULL(@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_MinorActivityNegse_CODE,
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
     -- Process petition response type 'DISP' records 
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionDisp_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'Processing DISP  records';
	   SET @Ls_Sqldata_TEXT = 'CASE NUMBER = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + 'PetitionIdno_TEXT = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + 'FILD Major Seq NUMB = ' + 'FC File ID = ' + ISNULL(@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
       
--Initializing some more variables for bug 13568
	   SELECT @Ln_TransactionEventSeq_NUMB = 0, @Ln_MajorIntSeq_NUMB = 0, @Lc_DocumentSource_CODE = '', @Ln_MemberMci_IDNO = 0, @Lc_ActivityMinor_CODE = '', 
				@Lc_ReasonStatus_CODE = '', @Ln_OrderSeq_NUMB = 0, @Ln_Topic_IDNO = 0, @Ln_Forum_IDNO = 0, @Lc_Status_CODE = '', @Ln_MinorIntSeq_NUMB = 0, @Lc_ActivityMajor_CODE = '', 
				@Ln_Schedule_NUMB = 0, @Lc_MinorReasonDescription_CODE = '', @Ls_Note_TEXT = '';
       
       -- Assign values from the string for disposition type response from family court
       SET @Lc_InsertCaseJournal_INDC = 'N';
       SET @Lc_UpdateMinorActivity_INDC = 'N';
       SET @Lc_DispositionOfficer_CODE = '';
       SET @Lc_DispositionOfficer_NAME = '';
       SET @Lc_DispositionDate_TEXT = '';
       SET @Lc_FinalDisposition_CODE = '';
       SET @Lc_Disposition_CODE = '';
       SET @Lc_PetitinerPresent_INDC = '';
       SET @Lc_RespondentPresent_INDC = '';
       SET @Lc_MedicalCoverage_INDC = '';
       SET @Lc_DispositionDescription_TEXT = '';
       SET @Lc_DispositionOfficer_CODE = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 1, 7);
       SET @Lc_DispositionOfficer_NAME = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 8, 29);
       SET @Lc_DispositionDate_TEXT = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 37, 8);
       SET @Lc_Disposition_CODE = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 45, 5);
       SET @Lc_DispositionDescription_TEXT = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 50, 40);
       SET @Lc_PetitinerPresent_INDC = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 90, 1);
       SET @Lc_RespondentPresent_INDC = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 91, 1);
       SET @Lc_MedicalCoverage_INDC = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 92, 1);
       SET @Lc_FinalDisposition_CODE = SUBSTRING (@Ls_FcPetRespCur_RecordTypeData_TEXT, 94, 1);
       -- Populate the note line for case jounal entries
       SET @Ls_Note1_TEXT = '';
       SET @Ls_Note2_TEXT = '';
       SET @Ls_Note1_TEXT = 'The Petition ' + @Lc_FcPetRespCur_PetitionIdno_TEXT + ' has had a final disposition entered. The disposition outcome is ' + @Lc_DispositionDescription_TEXT + '.' + ' The outcome code entered in FAMIS was ' + @Lc_Disposition_CODE + '. ' + '<BR/>' + '<BR/>' + @Lc_DispositionOfficer_NAME + ' approved the disposition on ' + @Lc_DispositionDate_TEXT + '. ' + '<BR/>' + '<BR/>' + ' Petitioner Present : ' + @Lc_PetitinerPresent_INDC + '<BR/>' + ' Respondent Present: ' + @Lc_RespondentPresent_INDC + '<BR/>' + '<BR/>' +  'Medical Coverage Ordered: ' + @Lc_MedicalCoverage_INDC;
       SET @Ls_Note2_TEXT = 'The Petition ' + @Lc_FcPetRespCur_PetitionIdno_TEXT  + ' has had a disposition entered, but not a Final Disposition. ' + 'The disposition outcome is ' + @Lc_DispositionDescription_TEXT + '.' + ' The outcome code entered in FAMIS was ' + @Lc_Disposition_CODE + '. ' + '<BR/>' + '<BR/>' + @Lc_DispositionOfficer_NAME + ' approved the disposition on ' + @Lc_DispositionDate_TEXT + '.' + '<BR/>' + '<BR/>' + ' Petitioner Present:' + @Lc_PetitinerPresent_INDC + '<BR/>' + ' Respondent Present:' + @Lc_RespondentPresent_INDC + '. ' +  '<BR/>' + '<BR/>' + 'Medical Coverage Ordered: ' + @Lc_MedicalCoverage_INDC;
       SET @Ls_Note5_TEXT = '';
       SET @Ls_Note5_TEXT = 'The Petition ' + @Lc_FcPetRespCur_PetitionIdno_TEXT  + ' has had a final disposition ' + 'entered. The disposition outcome is ' + @Lc_DispositionDescription_TEXT + '.' + ' The outcome code entered in FAMIS was ' + @Lc_Disposition_CODE + '. ' + '<BR/>' + '<BR/>' + @Lc_DispositionOfficer_NAME + ' approved the disposition on ' + @Lc_DispositionDate_TEXT + '. ' + '<BR/>' + '<BR/>' + ' Petitioner Present: ' + @Lc_PetitinerPresent_INDC + '<BR/>' + ' Respondent Present: ' + @Lc_RespondentPresent_INDC + '<BR/>' + '<BR/>' + 'Medical Coverage Ordered: ' + @Lc_MedicalCoverage_INDC;
       SET @Ls_Note6_TEXT = '';
       SET @Ls_Note6_TEXT = 'The Petition ' + @Lc_FcPetRespCur_PetitionIdno_TEXT  + ' has had a disposition ' + 'entered, but not a Final Disposition. ' + 'The disposition outcome is ' + @Lc_DispositionDescription_TEXT + '.' + ' The outcome code entered in FAMIS was ' + @Lc_Disposition_CODE + '. ' + '<BR/>' + '<BR/>' + @Lc_DispositionOfficer_NAME + ' approved the disposition on ' + @Lc_DispositionDate_TEXT + '.' + '<BR/>' + '<BR/>' + ' Petitioner Present: ' + @Lc_PetitinerPresent_INDC + '<BR/>' + ' Respondent Present: ' + @Lc_RespondentPresent_INDC + '<BR/>' + '<BR/>' + ' Medical Coverage Ordered: ' + @Lc_MedicalCoverage_INDC;

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
       -- 13602 Start 
       SET @Ln_MemberMci_IDNO = 0; 
       -- 13602 end
       SELECT TOP 1 @Ln_MajorIntSeq_NUMB = m.MajorIntSEQ_NUMB,
                    @Lc_DocumentSource_CODE = m.SourceDoc_CODE,
                    @Ln_MemberMci_IDNO      = m.Respondent_IDNO
         FROM FDEM_Y1 m
        WHERE m.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
          AND m.File_ID = @Lc_FcPetRespCur_FamilyCourtFile_ID
          AND m.Petition_IDNO = @Ln_FcPetRespCur_Petition_IDNO;

       IF @Lc_DocumentSource_CODE = @Lc_DocumentSourceF_CODE
        BEGIN
         -- If the document source is Family Court for AP filed petitions, Generate a case journal entry
         IF @Lc_FinalDisposition_CODE = @Lc_FinalDispositionYes_CODE
          BEGIN
           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_MinorActivityFdinf_CODE,
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
         ELSE
          BEGIN
           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_MinorActivityNfdnf_CODE,
            @As_DescriptionNote_TEXT     = @Ls_Note2_TEXT,
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
       ELSE IF @Lc_DocumentSource_CODE = @Lc_DocumentSourceD_CODE
        BEGIN
         SELECT TOP 1 @Lc_ActivityMinor_CODE = n.ActivityMinor_CODE,
                      @Lc_ReasonStatus_CODE = n.ReasonStatus_CODE,
                      @Ln_OrderSeq_NUMB			= n.OrderSeq_NUMB,
                      @Ln_Topic_IDNO        = n.Topic_IDNO,
                      @Ln_Forum_IDNO        = n.Forum_IDNO,
                      @Lc_Status_CODE = n.Status_CODE,
                      @Ln_MinorIntSeq_NUMB = n.MinorIntSeq_NUMB,
                      @Ln_MajorIntSeq_NUMB = n.MajorIntSeq_NUMB,
                      @Lc_ActivityMajor_CODE = n.ActivityMajor_CODE,
                      @Ln_Schedule_NUMB = n.Schedule_NUMB
           FROM DMNR_Y1 n
          WHERE n.Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
            AND n.MajorIntSEQ_NUMB = @Ln_MajorIntSeq_NUMB
            AND n.ActivityMajor_CODE IN (@Lc_MajorActivityEstp_CODE, @Lc_MajorActivityMapp_CODE, @Lc_MajorActivityRofo_CODE)
          ORDER BY MinorIntSeq_NUMB DESC;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY <> @Ln_Zero_NUMB
          BEGIN
           -- Update the SWKS_Y1 table with the hearing conducted 
           SET @Ls_Sql_TEXT = 'UPDATE OF SWKS_Y1 TABLE ';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', FamilyCourtFile_IDNO = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + ', Petition_IDNO = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT;
           					
           IF @Ln_Schedule_NUMB <> @Ln_Zero_NUMB
			BEGIN
			   UPDATE SWKS_Y1
				  SET ApptStatus_CODE = @Lc_ApptStatusCd_CODE
				WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
				  AND ActivityMajor_CODE = @Lc_ActivityMajor_CODE
				  AND Schedule_NUMB = @Ln_Schedule_NUMB ;
	           
			   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
			   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
				BEGIN
				 SET @Ls_DescriptionError_TEXT = 'SWKS_Y1 TABLE UPDATE FAILED';
				 RAISERROR(50001,16,1);
				END
			END
          
           IF @Lc_ActivityMajor_CODE = @Lc_MajorActivityEstp_CODE
            BEGIN
             IF @Lc_ActivityMinor_CODE = @Lc_ActivityMinorAordd_CODE
                AND @Lc_Status_CODE = @Lc_MinorStatusStart_CODE
              BEGIN
               -- Complete the minor activity
               SET @Lc_UpdateMinorActivity_INDC = 'Y';
              END 
             ELSE
              BEGIN
               -- Create the case journal entry
               -- Move all the required values for case major activity
               SET @Lc_InsertCaseJournal_INDC = 'Y';
              END
            END
           ELSE IF @Lc_ActivityMajor_CODE IN ( @Lc_MajorActivityMapp_CODE, @Lc_MajorActivityRofo_CODE)
            BEGIN
             IF @Lc_ActivityMinor_CODE = @Lc_ActivityMinorFamup_CODE
                AND @Lc_Status_CODE = @Lc_MinorStatusStart_CODE
              BEGIN
               -- Complete the minor activity
               SET @Lc_UpdateMinorActivity_INDC = 'Y';
              END
             ELSE
              BEGIN
               -- Create the case journal entry
               SET @Lc_InsertCaseJournal_INDC = 'Y';
              END
            END
           ELSE
            BEGIN
             -- Case journal entries 
             SET @Lc_InsertCaseJournal_INDC = 'Y';
            END
          END
         ELSE
          BEGIN
           -- No minor activity exists, case journal entry needed 
		   SET @Lc_InsertCaseJournal_INDC = 'Y';
          END
        END
       ELSE
        BEGIN
         -- Write the error no fdem entry found
         -- Case journal entry
  			IF @Lc_FinalDisposition_CODE = @Lc_FinalDispositionYes_CODE
			  BEGIN
			   EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
				@An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
				@An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
				@Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
				@Ac_ActivityMinor_CODE       = @Lc_MinorActivityFdinf_CODE,
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
			ELSE
			  BEGIN
			   EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
				@An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
				@An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
				@Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
				@Ac_ActivityMinor_CODE       = @Lc_MinorActivityNfdnf_CODE,
				@As_DescriptionNote_TEXT     = @Ls_Note2_TEXT,
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

       IF @Lc_UpdateMinorActivity_INDC = 'Y'
        BEGIN
         IF @Lc_FinalDisposition_CODE = @Lc_FinalDispositionYes_CODE
          BEGIN
           SET @Ls_Note_TEXT = @Ls_Note5_TEXT;
           IF @Lc_ActivityMajor_CODE IN ( @Lc_MajorActivityMapp_CODE, @Lc_MajorActivityEstp_CODE)
			  BEGIN 
				SET @Lc_MinorReasonDescription_CODE = 'CI';
			  END
		   ELSE
			  -- Set the reason description for ROFO major
			  BEGIN
				SET @Lc_MinorReasonDescription_CODE = 'RP';	
			  END
          END
         ELSE
          BEGIN
           SET @Lc_MinorReasonDescription_CODE = 'CJ';
           SET @Ls_Note_TEXT = @Ls_Note6_TEXT;
          END

         EXECUTE BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
          @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
          @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
          @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
          @An_Forum_IDNO               = @Ln_Forum_IDNO,
          @An_Topic_IDNO               = @Ln_Topic_IDNO,
          @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
          @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
          @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
          @Ac_ReasonStatus_CODE        = @Lc_MinorReasonDescription_CODE,
          @As_DescriptionNote_TEXT	   = @Ls_Note_TEXT,
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

       IF @Lc_InsertCaseJournal_INDC = 'Y'
        BEGIN
         
         IF @Lc_FinalDisposition_CODE = @Lc_FinalDispositionYes_CODE
          BEGIN
           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_MinorActivityPfdrf_CODE,
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
         ELSE
          BEGIN
           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_MinorActivityPnfdf_CODE,
            @As_DescriptionNote_TEXT     = @Ls_Note2_TEXT,
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
      IF (@Lc_Disposition_CODE IN (@Lc_DispositionDismi_CODE, @Lc_DispositionDwop_CODE, @Lc_DispositionStdis_CODE, @Lc_DispositionVdism_CODE,
                                     @Lc_DispositionDismm_CODE, @Lc_DispositionVd_CODE, @Lc_DispositionVdcc_CODE)
         AND @Lc_FcPetRespCur_PetitionType_CODE IN (@Lc_PetitionTypePetn_CODE,@Lc_PetitionTypePetp_CODE,@Lc_PetitionTypePetl_CODE))
          BEGIN
            EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
            @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
            @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_MinorActivityRopdp_CODE,  
            @Ac_Subsystem_CODE           = @Lc_SubsystemEst_CODE,
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
     -- Process petition response type 'APFL' records 
     IF @Lc_FcPetRespCur_PetitionDispType_CODE = @Lc_PetitionApfl_CODE
      BEGIN
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
       SET @Ln_MajorIntSeq_NUMB = 0;
       -- 13602 Start
       SET @Ln_MemberMci_IDNO = 0;
       -- 13602 End
       --13751 - Code changed as part of CR0454 to add file number to DCKT_Y1, DPRS_Y1 tables, if it doesn't exist in DECSS -START-
       SET @Li_FdemApflCount_QNTY = 0;
       SELECT @Li_FdemApflCount_QNTY = COUNT(1)
         FROM FDEM_Y1 
         WHERE Case_IDNO = @Ln_FcPetRespCur_Case_IDNO
           AND EndValidity_DATE = @Ld_High_DATE 
       --13751 - Code changed as part of CR0454 to add file number to DCKT_Y1, DPRS_Y1 tables, if it doesn't exist in DECSS -START-    
       SET @Ln_MemberMci_IDNO	= @Lc_ApflPetitionerMci_IDNO;  
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 3';
       SET @Ls_Sqldata_TEXT = 'Case IDNO = ' + CAST(@Ln_FcPetRespCur_Case_IDNO AS VARCHAR) + ', Family Court File Id = ' + @Lc_FcPetRespCur_FamilyCourtFile_ID + ', Petition Number = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT;
      
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
           
            SELECT   @Ln_FcPetRespCur_Case_IDNO AS Case_IDNO,
                     @Lc_FcPetRespCur_FamilyCourtFile_ID AS File_ID,
                     @Lc_FcPetRespCur_PetitionType_CODE AS DocReference_CODE,
                     @Lc_DocumentTypeP_CODE AS TypeDoc_CODE,
                     @Lc_DocumentSourceF_CODE AS SourceDoc_CODE,
                     @Lc_ApflActionFiledFormat_DATE AS Filed_DATE,
                     @Ld_Run_DATE AS BeginValidity_DATE,
                     @Ld_High_DATE AS EndValidity_DATE,
                     @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
                     @Ld_Start_DATE AS Update_DTTM,
                     @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
                     @Lc_Yes_INDC AS FdemDisplay_INDC,
                     @Lc_Space_TEXT AS ApprovedBy_CODE,
                     @Lc_ApflPetitionerMci_IDNO AS Petitioner_IDNO,
                     @Lc_ApflRespondentMci_IDNO AS Respondent_IDNO,
                     @Lc_FcPetRespCur_PetitionIdno_TEXT AS Petition_IDNO,
                     @Ln_Zero_NUMB AS Order_IDNO,
                     @Ln_MajorIntSeq_NUMB AS MajorIntSeq_NUMB,
                     @Ln_Zero_NUMB AS MinorIntSeq_NUMB ;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;
       IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'FDEM_Y1 INSERT FAILED ';
         RAISERROR(50001,16,1);
        END
       -- Create case journal entry NFFRF for the case 
       SET @Ls_Sql_TEXT = 'READING REFM TABLE FOR FULL DISPLY NAME' ;
           SET @Ls_Sqldata_TEXT = 'TABLE ID = ' + 'FMIS ' + ', SUB TABLE ID = ' + 'FDOC';
           SELECT @Ls_FdocDescriptionValue_TEXT = DescriptionValue_TEXT
			 FROM REFM_Y1 r
			 WHERE r.Table_ID = 'FMIS' and r.TableSub_ID = 'FDOC' AND Value_CODE = @Lc_FcPetRespCur_PetitionType_CODE;
		   SET @Li_Rowcount_QNTY = @@ROWCOUNT;
           IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB 
			BEGIN 
				SET @Ls_FdocDescriptionValue_TEXT = '';
			END
       SET @Ls_Note_TEXT = 'NCP, ' + @Lc_ApflPetitionerFirst_NAME + @Lc_ApflPetitionerLast_NAME + ', has filed a ' + @Ls_FdocDescriptionValue_TEXT + ', Petition Number ' + @Lc_FcPetRespCur_PetitionIdno_TEXT + ', against the CP, ' + @Lc_ApflRespondentFirst_NAME + @Lc_ApflRespondentLast_NAME + ' on ' + @Lc_ApflActionFiled_DATE + '.';

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_FcPetRespCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_MinorActivityNffrf_CODE,
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
      --13751 - Code changed as part of CR0454 to add file number to DCKT_Y1, DPRS_Y1 tables, if it doesn't exist in DECSS -START-
       IF @Li_FdemApflCount_QNTY = @Ln_Zero_NUMB
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
				         @Lc_ApflActionFiledFormat_DATE AS Filed_DATE,
				         @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
				         @Ld_Run_DATE AS BeginValidity_DATE,
				         @Ln_TransactionEventSeq_NUMB AS EventGlobalBeginSeq_NUMB,
				         @Ld_Start_DATE AS Update_DTTM
				   FROM CASE_Y1 c 
				   WHERE c.Case_IDNO =  @Ln_FcPetRespCur_Case_IDNO);

				   SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
		
				   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO DCKT FAILED FOR APFL RECORD';
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
				     AND ((m.MemberMci_IDNO IN (@Lc_ApflPetitionerMci_IDNO, @Lc_ApflRespondentMci_IDNO))
				         OR
				          (m.CaseRelationship_CODE = 'D'))
				     AND m.CaseMemberStatus_CODE = 'A');
				     
				   SET @Li_Rowcount_QNTY = @@ROWCOUNT; 
				   
				   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
					  BEGIN
						SET @Ls_DescriptionError_TEXT = 'INSERT INTO DPRS FAILED FOR APFL RECORD';
						RAISERROR (50001, 16, 1);
					  END
          END
        END  	          				  	      	
      --13751 - Code changed as part of CR0454 to add file number to DCKT_Y1, DPRS_Y1 tables, if it doesn't exist in DECSS -END-
      END
      
     LX_EXCEPTION:;
     
     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
       SET @Ls_Record_TEXT = 'Sequence Idno = ' + CAST(@Ln_FcPetRespCur_Seq_IDNO AS VARCHAR) + ' PetitionDispType_CODE = ' + ISNULL(@Lc_FcPetRespCur_PetitionDispType_CODE, '') + ', Petition_IDNO = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '')  + ', PetitionSequence_IDNO = ' + ISNULL(@Lc_FcPetRespCur_PetitionSequenceIdno_TEXT, '') + ', Case_IDNO = ' + CAST(ISNULL (@Ln_FcPetRespCur_Case_IDNO, 0) AS VARCHAR) + ', PetitionType_CODE = ' + ISNULL (@Lc_FcPetRespCur_PetitionType_CODE, '') + ', PetitionAction_DATE = ' + ISNULL (@Lc_FcPetRespCur_PetitionAction_DATE, '') + ', FamilyCourtFile_IDNO = ' + ISNULL (@Lc_FcPetRespCur_FamilyCourtFile_ID, '') + ', FamilyCourtRecordTypeData_TEXT = ' + ISNULL (@Ls_FcPetRespCur_RecordTypeData_TEXT, '');
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
	   SET @Ls_Sqldata_TEXT = 'Job Number = ' + @Lc_Job_ID ;
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
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
	   	   ROLLBACK TRANSACTION SAVEFCPETITION_BATCH_RESPONSE;
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
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_BateErrorUnknown_CODE;
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
       SET @Ls_Sqldata_TEXT = 'FcPetitionDispType_CODE = ' + ISNULL(@Lc_FcPetRespCur_PetitionDispType_CODE, '') + ', FcPetion_IDNO = ' + ISNULL(@Lc_FcPetRespCur_PetitionIdno_TEXT, '') + ', FcCase_IDNO = ' + ISNULL(@Lc_FcPetRespCur_CaseIdno_TEXT, '') + ', FcPetitionType_CODE = ' + ISNULL(@Lc_FcPetRespCur_PetitionType_CODE, '') + ', FcFile_IDNO = ' + ISNULL (@Lc_FcPetRespCur_FamilyCourtFile_ID, '');
       SET @Ls_BateRecord_TEXT = @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
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
     -- Update the records in the LFCPR_Y1 table for these errors with the process indicator 
     -- value to 'Y', so that these records will not be picked up in the sord screen for the worker view
     SET @Ls_Sql_TEXT = 'UPDATING THE PROCESS INDICATOR IN LFCPR_Y1';
     SET @Ls_Sqldata_TEXT = 'Sequence Idno = ' + CAST(@Ln_FcPetRespCur_Seq_IDNO AS VARCHAR) + ', Petition Idno = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT + ', Case Idno = ' +  @Lc_FcPetRespCur_CaseIdno_TEXT;
     
     UPDATE LFCPR_Y1
          SET Process_INDC = @Lc_Yes_INDC
        WHERE Seq_IDNO = @Ln_FcPetRespCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;
     IF @Li_RowCount_QNTY = 0
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LoadFcOrderDetails_T1';
         RAISERROR(50001,16,1);
        END
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Ac_Job_ID = ' + ISNULL (@Lc_Job_ID, '') + ', Ad_Run_DATE = ' + ISNULL (CAST(@Ld_Run_DATE AS VARCHAR), '') + ', As_RestartKey_TEXT = ' + ISNULL (CAST(@Ln_Cur_QNTY AS VARCHAR), '');
       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cur_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
       COMMIT TRANSACTION FCPETITION_BATCH_RESPONSE; -- 1
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       BEGIN TRANSACTION FCPETITION_BATCH_RESPONSE; -- 2
       SET @Ln_CommitFreq_QNTY = 0;
      END
      
     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD';
     SET @Ls_Sqldata_TEXT = 'Sequence Idno = ' + CAST(@Ln_FcPetRespCur_Seq_IDNO AS VARCHAR) + ', Petition Idno = ' + @Lc_FcPetRespCur_PetitionIdno_TEXT + ', Case Idno = ' +  @Lc_FcPetRespCur_CaseIdno_TEXT;
     --SELECT 'BEFORE UPDATING THE PROCESS INDICATOR ';
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION FCPETITION_BATCH_RESPONSE;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = @Ls_Err0003_TEXT;
       RAISERROR (50001,16,1);
      END
   	 SET @Ls_Sql_TEXT = 'ADDING THE PROCESSED RECORD COUNT';
	 SET @Ls_Sqldata_TEXT = 'Sequence Number = ' + CAST(@Ln_FcPetRespCur_Seq_IDNO AS VARCHAR);
	 SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
     FETCH NEXT FROM FcPetResp_CUR INTO @Ln_FcPetRespCur_Seq_IDNO, @Lc_FcPetRespCur_PetitionDispType_CODE, @Lc_FcPetRespCur_PetitionIdno_TEXT, @Lc_FcPetRespCur_PetitionSequenceIdno_TEXT, @Lc_FcPetRespCur_CaseIdno_TEXT, @Lc_FcPetRespCur_PetitionType_CODE, @Lc_FcPetRespCur_PetitionAction_DATE, @Lc_FcPetRespCur_FamilyCourtFile_ID, @Ls_FcPetRespCur_RecordTypeData_TEXT;
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE FcPetResp_CUR;
   DEALLOCATE FcPetResp_CUR;
   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job Number = ' + @Lc_Job_ID ;
   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
   -- --Update the Log in BSTL_Y1 as the Job is suceeded
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job Number = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
  
   COMMIT TRANSACTION FCPETITION_BATCH_RESPONSE;
  END TRY

  BEGIN CATCH
   --If Trasaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION FCPETITION_BATCH_RESPONSE;
    END
   IF CURSOR_STATUS ('local', 'FcPetResp_CUR') IN (0, 1)
    BEGIN
     CLOSE FcPetResp_CUR;
     DEALLOCATE FcPetResp_CUR;
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
