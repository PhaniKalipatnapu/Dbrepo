/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_PROCESS_IVE_REFERRAL]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_PROCESS_IVE_REFERRAL
Programmer Name		 : IMP Team
Description			 : The procedure BATCH_FIN_IVE_REFERRAL$SP_PROCESS_IVE_REFERRAL reads the data from the temorary table, 
					   inserts the data into application tables for creating new cases or updates application tables 
					   with any new data for pending applications in the system.
Frequency			 : Daily
Developed On		 : 06/08/2011
Called By			 : None
Called On			 : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
					   BATCH_FIN_IVE_REFERRAL$SP_GET_APPLICATIONMEMBERID,
					   BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION,
					   BATCH_FIN_IVE_REFERRAL$SP_CREATE_CHILD_APPLICATIONS,
					   BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION,
					   BATCH_COMMON$SP_GET_ERROR_DESCRIPTION,
					   BATCH_COMMON$SP_BSTL_LOG,
					   BATCH_COMMON$SP_BATE_LOG,
					   BATCH_COMMON$SP_UPDATE_PARM_DATE
-----------------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
-----------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_PROCESS_IVE_REFERRAL]
AS
 BEGIN
  SET NOCOUNT ON;

    DECLARE @Ln_KentCounty_IDNO              NUMERIC(3) = 1,
           @Ln_NewCastleCounty_IDNO          NUMERIC(3) = 3,
           @Ln_SussexCounty_IDNO             NUMERIC(3) = 5,
           @Ln_MemberMciDfs_IDNO             NUMERIC(10) = 0000999998,
           @Lc_Mother_CODE                   CHAR(1) = 'M',
           @Lc_Father_CODE                   CHAR(1) = 'F',
           @Lc_SexF_CODE                     CHAR(1) = 'F',
           @Lc_SexM_CODE                     CHAR(1) = 'M',
           @Lc_ApplicationStatus_CODE        CHAR(1) = 'F',
           @Lc_ValueNo_INDC                  CHAR(1) = 'N',
           @Lc_Space_TEXT                    CHAR(1) = ' ',
           @Lc_StatusFailed_CODE             CHAR(1) = 'F',
           @Lc_ValueYes_INDC                 CHAR(1) = 'Y',
           @Lc_ErrorTypeError_CODE           CHAR(1) = 'E',
           @Lc_KentCounty_CODE               CHAR(1) = 'K',
           @Lc_NewCastleCounty_CODE          CHAR(1) = 'N',
           @Lc_SussexCounty_CODE             CHAR(1) = 'S',
           @Lc_MotherMatch_INDC              CHAR(1) = 'N',
           @Lc_MotherChildMatch_INDC         CHAR(1) = 'N',
           @Lc_FatherChildMatch_INDC         CHAR(1) = 'N',
           @Lc_FatherMatch_INDC              CHAR(1) = 'N',
           @Lc_MotherCreateApplication_INDC  CHAR(1) = 'N',
           @Lc_MotherUpdateApplication_INDC  CHAR(1) = 'N',
           @Lc_FatherCreateApplication_INDC  CHAR(1) = 'N',
           @Lc_FatherUpdateApplication_INDC  CHAR(1) = 'N',
           @Lc_UiMotherCreateApplication_INDC CHAR(1) = 'N',
           @Lc_UiFatherCreateApplication_INDC CHAR(1) = 'N',
           @Lc_MotherDeathDate_INDC          CHAR(1) = 'N',
           @Lc_FatherDeathDate_INDC          CHAR(1) = 'N',
           @Lc_StatusSuccess_CODE            CHAR(1) = 'S',
           @Lc_StatusAbnormalend_CODE        CHAR(1) = 'A',
           @Lc_IndNote_TEXT                  CHAR(1) = 'N',
           @Lc_BateErrorE1424_CODE			 CHAR(5) = 'E1424',
           @Lc_JobProcessIveReferral_ID      CHAR(7) = 'DEB1340',
           @Lc_Successful_TEXT               CHAR(20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT             CHAR(30) = 'BATCH',
           @Lc_Parmdateproblem_TEXT          CHAR(30) = 'PARM DATE PROBLEM',
           @Ls_Procedure_NAME                VARCHAR(100) = 'SP_PROCESS_IVE_REFERRAL',
           @Ls_Process_NAME                  VARCHAR(100) = 'BATCH_FIN_IVE_REFERRAL',
           @Ld_High_DATE                     DATE = '12/31/9999',
           @Ld_Low_DATE                      DATE = '01/01/0001';
  DECLARE  @Ln_Zeros_NUMB                    NUMERIC = 0,
           @Ln_Zero_NUMB                     NUMERIC(1) = 0,
           @Ln_FatherChildNoMatch_QNTY       NUMERIC(2) = 0,
           @Ln_MotherChildNoMatch_QNTY       NUMERIC(2) = 0,
           @Ln_County_IDNO                   NUMERIC(3) = 0,
           @Ln_CommitFreq_QNTY               NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY       NUMERIC(5) = 0,
           @Ln_CommitFreqParm_QNTY           NUMERIC(5) = 0,
           @Ln_ExceptionThresholdParm_QNTY   NUMERIC(5) = 0,
           @Ln_RestartLine_NUMB              NUMERIC(5,0),
           @Ln_ProcessedRecordCount_QNTY     NUMERIC(6) = 0,
           @Ln_MotherPrimarySsn_NUMB         NUMERIC(9) = 0,
           @Ln_FatherPrimarySsn_NUMB         NUMERIC(9) = 0,
           @Ln_Child1PrimarySsn_NUMB         NUMERIC(9) = 0,
           @Ln_Child2PrimarySsn_NUMB         NUMERIC(9) = 0,
           @Ln_Child3PrimarySsn_NUMB         NUMERIC(9) = 0,
           @Ln_Child4PrimarySsn_NUMB         NUMERIC(9) = 0,
           @Ln_Child5PrimarySsn_NUMB         NUMERIC(9) = 0,
           @Ln_Child6PrimarySsn_NUMB         NUMERIC(9) = 0,
           @Ln_MemberSsn_NUMB                NUMERIC(9) = 0,
           @Ln_RecordCount_QNTY              NUMERIC(10) = 0,
           @Ln_MemberMci_IDNO                NUMERIC(10) = 0,
           @Ln_ChildPid_IDNO                 NUMERIC(10) = 0,
           @Ln_Child1Mci_IDNO                NUMERIC(10) = 0,
           @Ln_Child2Mci_IDNO                NUMERIC(10) = 0,
           @Ln_Child3Mci_IDNO                NUMERIC(10) = 0,
           @Ln_Child4Mci_IDNO                NUMERIC(10) = 0,
           @Ln_Child5Mci_IDNO                NUMERIC(10) = 0,
           @Ln_Child6Mci_IDNO                NUMERIC(10) = 0,
           @Ln_Child1Pid_IDNO                NUMERIC(10) = 0,
           @Ln_Child2Pid_IDNO                NUMERIC(10) = 0,
           @Ln_Child3Pid_IDNO                NUMERIC(10) = 0,
           @Ln_Child4Pid_IDNO                NUMERIC(10) = 0,
           @Ln_Child5Pid_IDNO                NUMERIC(10) = 0,
           @Ln_Child6Pid_IDNO                NUMERIC(10) = 0,
           @Ln_Child1CaseWelfare_IDNO        NUMERIC(10) = 0,
           @Ln_Child2CaseWelfare_IDNO        NUMERIC(10) = 0,
           @Ln_Child3CaseWelfare_IDNO        NUMERIC(10) = 0,
           @Ln_Child4CaseWelfare_IDNO        NUMERIC(10) = 0,
           @Ln_Child5CaseWelfare_IDNO        NUMERIC(10) = 0,
           @Ln_Child6CaseWelfare_IDNO        NUMERIC(10) = 0,
           @Ln_IveCase_IDNO                  NUMERIC(10) = 0,
           @Ln_ChildMci_IDNO                 NUMERIC(10) = 0,
           @Ln_Error_NUMB                    NUMERIC(11),
           @Ln_ErrorLine_NUMB                NUMERIC(11),
           @Ln_Application_IDNO              NUMERIC(15) = 0,
           @Ln_MotherApplication_IDNO        NUMERIC(15) = 0,
           @Ln_FatherApplication_IDNO        NUMERIC(15) = 0,
           @Ln_TransactionEventSeq_NUMB      NUMERIC(19) = 0,
           @Ln_ProcessedRecordsCommit_QNTY   NUMERIC(19) = 0,
           @Li_LoopCount_QNTY                SMALLINT,
           @Li_ChildLoopCount_QNTY           SMALLINT,
           @Li_MotherMatchedCount_QNTY       SMALLINT,
           @Li_MotherLoop_QNTY               SMALLINT,
           @Li_FatherLoop_QNTY               SMALLINT,
           @Li_ChildFileCount_QNTY           SMALLINT,
           @Li_Count_QNTY                    SMALLINT,
           @Li_ChildTableCount_QNTY          SMALLINT,
           @Li_FatherMatchedCount_QNTY       SMALLINT,
           @Li_FetchStatus_QNTY              SMALLINT,
           @Li_SelectStatus_QNTY             SMALLINT,
           @Li_CmemCount_QNTY                SMALLINT,
           @Li_RowCount_QNTY                 SMALLINT,
           @Li_Comma_QNTY					 SMALLINT,
           @Li_SpaceCount_QNTY				 SMALLINT,
           @Lc_Race_CODE                     CHAR(1) = '',
           @Lc_MemberSex_CODE                CHAR(1) = '',
           @Lc_TypeAddress_CODE              CHAR(1) = '',
           @Lc_Normalization_CODE            CHAR(1) = '',
           @Lc_Sex_CODE                      CHAR(1) = '',
           @Lc_State_ADDR                    CHAR(2) = '',
           @Lc_Suffix_NAME                   CHAR(4) = '',
           @Lc_Msg_CODE                      CHAR(5) = '',
           @Lc_BateError_CODE                CHAR(5) = '',
           @Lc_Job_ID                        CHAR(7) = '',
           @Lc_Zip_ADDR                      CHAR(15) = '',
           @Lc_First_NAME                    CHAR(16) = '',
           @Lc_Last_NAME                     CHAR(20) = '',
           @Lc_Middle_NAME                   CHAR(20) = '',
           @Lc_MotherLast_NAME               CHAR(20) = '',
           @Lc_MotherFirst_NAME              CHAR(20) = '',
           @Lc_FatherLast_NAME               CHAR(20) = '',
           @Lc_FatherFirst_NAME              CHAR(20) = '',
           @Lc_Partial_NAME					 CHAR(24) = '',
           @Lc_City_ADDR                     CHAR(28) = '',
           @Lc_Attn_ADDR                     CHAR(40) = '',
           @Ls_Line1_ADDR                    VARCHAR(50) = '',
           @Ls_Line2_ADDR                    VARCHAR(50) = '',
           @Ls_Sql_TEXT                      VARCHAR(100) = '',
           @Ls_MotherMatchCases_TEXT         VARCHAR(100) = '',
           @Ls_FatherMatchCases_TEXT         VARCHAR(100) = '',
           @Ls_CursorLoc_TEXT                VARCHAR(200) = '',
           @Ls_Sqldata_TEXT                  VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT         VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT             VARCHAR(4000) = '',
           @Ls_BateRecord_TEXT               VARCHAR(4000) = '',
           @Ld_DfsBirth_DATE                 DATE,
           @Ld_Run_DATE                      DATE,
           @Ld_Start_DATE                    DATETIME2,
           @Ld_LastRun_DATE                  DATETIME2;

  CREATE TABLE #IveMother_Matched_Cases_P1
   (
     IveMotherCase_IDNO     NUMERIC (10) NOT NULL,
     IvdMotherCase_IDNO     NUMERIC (6) NOT NULL,
     IvdMotherNcpMci_IDNO   NUMERIC (10) NOT NULL,
     IvdMotherChildMci_IDNO NUMERIC (10) NOT NULL,
     MotherChildMatch_INDC  CHAR(1) NOT NULL
   );

  CREATE TABLE #IveFather_Matched_Cases_P1
   (
     IveFatherCase_IDNO     NUMERIC(10) NOT NULL,
     IvdFatherCase_IDNO     NUMERIC(6) NOT NULL,
     IvdFatherNcpMci_IDNO   NUMERIC (10) NOT NULL,
     IvdFatherChildMci_IDNO NUMERIC (10) NOT NULL,
     FatherChildMatch_INDC  CHAR(1) NOT NULL
   );

  CREATE TABLE #IveRefTo_Decss_MotherMatch_P1
   (
     ChildMci_IDNO NUMERIC(10) NOT NULL,
     Matched_INDC  CHAR(1) NOT NULL
   );

  CREATE TABLE #IveRefTo_Decss_FatherMatch_P1
   (
     ChildMci_IDNO NUMERIC(10) NOT NULL,
     Matched_INDC  CHAR(1) NOT NULL
   );
  CREATE TABLE #IveRefTo_Decss_PendingappsMatch_P1 
   (
    ChildMci_IDNO NUMERIC(10) NOT NULL,
    ChildPid_IDNO NUMERIC(10) NOT NULL,
    MotherMatch_INDC CHAR(1) NOT NULL,
    FatherMatch_INDC CHAR(1) NOT NULL
    ); 
   

  -- MtrMatch_CUR Cursor variabble declaration
  DECLARE @Ln_MtrMatchCur_IveMotherCase_IDNO				NUMERIC(10),
          @Ln_MtrMatchCur_IvdMotherCase_IDNO				NUMERIC(6),
          @Ln_MtrMatchCur_IvdMotherNcpMci_IDNO				NUMERIC(10),
          @Ln_MtrMatchCur_IvdMotherChildMci_IDNO			NUMERIC (10);
  -- FtrMatch_CUR Cursor variable declaration 
  DECLARE @Ln_FtrMatchCur_IveFatherCase_IDNO				NUMERIC(10),
          @Ln_FtrMatchCur_IvdFatherCase_IDNO				NUMERIC(6),
          @Ln_FtrMatchCur_IvdFatherNcpMci_IDNO				NUMERIC(10),
          @Ln_FtrMatchCur_IvdFatherChildMci_IDNO			NUMERIC (10);
  -- MhisIve_CUR Cursor variable declaration 
  DECLARE @Ln_MhisIveCur_Case_IDNO							NUMERIC(6),
          @Ln_MhisIveCur_CaseWelfare_IDNO					NUMERIC(10),
          @Lc_MhisIveCur_CaseMemberStatus_CODE				CHAR(1),
          @Lc_MhisIveCur_CaseRelationship_CODE				CHAR(1),
          @Ln_MhisIveCur_MemberMci_IDNO						NUMERIC(10),
          @Lc_MhisIveCur_StatusCase_CODE					CHAR(1),
          @Lc_MhisIveCur_Last_NAME							CHAR(20),
          @Lc_MhisIveCur_First_NAME							CHAR(16),
          @Ln_MhisIveCur_MemberSsn_NUMB						NUMERIC(9),
          @Ld_MhisIveCur_Birth_DATE							DATE,
          @Ln_MhisIveCur_IveParty_IDNO						NUMERIC(10),
          @Ln_MhisIveCur_ChildMemberMci_IDNO				NUMERIC(10);
  -- Cursor variable declaration
  DECLARE @Ln_IveRefCur_Seq_IDNO                            NUMERIC(19) = 0,
          @Lc_IveRefCur_Rec_ID                              CHAR(2),
          @Ld_IveRefCur_Application_DATE                    DATE,
          @Lc_IveRefCur_Approved_DATE                       CHAR(8),
          @Lc_IveRefCur_IveCaseStatus_CODE                  CHAR(1),
          @Lc_IveRefCur_ApplicationCounty_IDNO              CHAR(1),
          @Lc_IveRefCur_CourtOrder_INDC                     CHAR(1),
          @Lc_IveRefCur_File_ID                             CHAR(15),
          @Ld_IveRefCur_CourtOrder_DATE                     DATE,
          @Lc_IveRefCur_CourtOrderCity_NAME                 CHAR(15),
          @Lc_IveRefCur_CourtOrderState_CODE                CHAR(2),
          @Lc_IveRefCur_CourtOrder_AMNT                     CHAR(10),
          @Lc_IveRefCur_CourtOrderFrequency_CODE            CHAR(5),
          @Lc_IveRefCur_CourtOrderEffective_INDC            CHAR(1),
          @Lc_IveRefCur_CourtPaymentType_CODE               CHAR(1),
          @Lc_IveRefCur_MotherInformation_INDC              CHAR(1),
          @Lc_IveRefCur_Mother_NAME                         CHAR(24),
          @Lc_IveRefCur_MotherMci_IDNO                      CHAR(10),
          @Lc_IveRefCur_MotherPid_IDNO                      CHAR(10),
          @Lc_IveRefCur_MotherPrimarySsn_NUMB               CHAR(9),
          @Lc_IveRefCur_MotherOtherSsn_NUMB                 CHAR(9),
          @Lc_IveRefCur_MotherAlias_NAME                    CHAR(24),
          @Lc_IveRefCur_MotherIveCase_IDNO                  CHAR(10),
          @Lc_IveRefCur_MotherDeath_DATE                    CHAR(8),
          @Lc_IveRefCur_MotherHealthIns_INDC                CHAR(1),
          @Lc_IveRefCur_MotherInsPolicy_ID                  CHAR(15),
          @Lc_IveRefCur_MotherIns_NAME                      CHAR(15),
          @Lc_IveRefCur_MotherAddress_CODE                  CHAR(1),
          @Lc_IveRefCur_MotherAddressNormalization_CODE     CHAR(1),
          @Ls_IveRefCur_MotherLine1_ADDR                    VARCHAR(50),
          @Ls_IveRefCur_MotherLine2_ADDR                    VARCHAR(50),
          @Lc_IveRefCur_MotherCity_ADDR                     CHAR(28),
          @Lc_IveRefCur_MotherState_ADDR                    CHAR(2),
          @Lc_IveRefCur_MotherZip_ADDR                      CHAR(15),
          @Lc_IveRefCur_MotherBirth_DATE                    CHAR(8),
          @Lc_IveRefCur_MotherRace_CODE                     CHAR(2),
          @Lc_IveRefCur_MotherSex_CODE                      CHAR(1),
          @Lc_IveRefCur_MotherEmpl_CODE                     CHAR(1),
          @Lc_IveRefCur_MotherEmpl_NAME                     CHAR(35),
          @Lc_IveRefCur_MotherEmplAddressNormalization_CODE CHAR(1),
          @Ls_IveRefCur_MotherEmplLine1_ADDR                VARCHAR(50),
          @Ls_IveRefCur_MotherEmplLine2_ADDR                VARCHAR(50),
          @Lc_IveRefCur_MotherEmplCity_ADDR                 CHAR(28),
          @Lc_IveRefCur_MotherEmplState_ADDR                CHAR(2),
          @Lc_IveRefCur_MotherEmplZip_ADDR                  CHAR(15),
          @Lc_IveRefCur_MotherLastPayment_DATE              CHAR(8),
          @Lc_IveRefCur_MotherLastPayment_AMNT              CHAR(5),
          @Lc_IveRefCur_MotherArrearage_AMNT                CHAR(5),
          @Lc_IveRefCur_MotherPaymentDue_DATE               CHAR(8),
          @Lc_IveRefCur_FatherInformation_INDC              CHAR(1),
          @Lc_IveRefCur_Father_NAME                         CHAR(24),
          @Lc_IveRefCur_FatherMci_IDNO                      CHAR(10),
          @Lc_IveRefCur_FatherPid_IDNO                      CHAR(10),
          @Lc_IveRefCur_FatherPrimarySsn_NUMB               CHAR(9),
          @Lc_IveRefCur_FatherOtherSsn_NUMB                 CHAR(9),
          @Lc_IveRefCur_FatherAlias_NAME                    CHAR(24),
          @Lc_IveRefCur_FatherIveCase_IDNO                  CHAR(10),
          @Lc_IveRefCur_FatherDeath_DATE                    CHAR(8),
          @Lc_IveRefCur_FatherHealthIns_INDC                CHAR(1),
          @Lc_IveRefCur_FatherIns_NAME                      CHAR(15),
          @Lc_IveRefCur_FatherInsPolicy_ID                  CHAR(15),
          @Lc_IveRefCur_FatherAddress_CODE                  CHAR(1),
          @Lc_IveRefCur_FatherAddressNormalization_CODE     CHAR(1),
          @Ls_IveRefCur_FatherLine1_ADDR                    VARCHAR(50),
          @Ls_IveRefCur_FatherLine2_ADDR                    VARCHAR(50),
          @Lc_IveRefCur_FatherCity_ADDR                     CHAR(28),
          @Lc_IveRefCur_FatherState_ADDR                    CHAR(2),
          @Lc_IveRefCur_FatherZip_ADDR                      CHAR(15),
          @Lc_IveRefCur_FatherBirth_DATE                    CHAR(8),
          @Lc_IveRefCur_FatherRace_CODE                     CHAR(2),
          @Lc_IveRefCur_FatherSex_CODE                      CHAR(1),
          @Lc_IveRefCur_FatherEmpl_CODE                     CHAR(1),
          @Lc_IveRefCur_FatherEmpl_NAME                     CHAR(35),
          @Lc_IveRefCur_FatherEmplAddressNormalization_CODE CHAR(1),
          @Ls_IveRefCur_FatherEmplLine1_ADDR                VARCHAR(50),
          @Ls_IveRefCur_FatherEmplLine2_ADDR                VARCHAR(50),
          @Lc_IveRefCur_FatherEmplCity_ADDR                 CHAR(28),
          @Lc_IveRefCur_FatherEmplState_ADDR                CHAR(2),
          @Lc_IveRefCur_FatherEmplZip_ADDR                  CHAR(15),
          @Lc_IveRefCur_FatherLastPayment_DATE              CHAR(8),
          @Lc_IveRefCur_FatherLastPayment_AMNT              CHAR(5),
          @Lc_IveRefCur_FatherArrearage_AMNT                CHAR(5),
          @Lc_IveRefCur_FatherPaymentDue_DATE               CHAR(8),
          @Lc_IveRefCur_Child1Mci_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child1Pid_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child1Ssn_NUMB                      CHAR(9),
          @Lc_IveRefCur_Child1IveCase_IDNO                  CHAR(10),
          @Lc_IveRefCur_Child1_NAME                         CHAR(24),
          @Lc_IveRefCur_Child1Birth_DATE                    CHAR(8),
          @Lc_IveRefCur_Child1FedFunded_INDC                CHAR(1),
          @Lc_IveRefCur_Child1PaternityEst_INDC             CHAR(1),
          @Lc_IveRefCur_Child1Father_NAME                   CHAR(24),
          @Lc_IveRefCur_Child1FatherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child1Mother_NAME                   CHAR(24),
          @Lc_IveRefCur_Child1MotherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child1MotherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child1FatherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child1FosterCareBegin_DATE          CHAR(8),
          @Lc_IveRefCur_Child1Monthly_AMNT                  CHAR(10),
          @Lc_IveRefCur_Child2Mci_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child2Pid_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child2Ssn_NUMB                      CHAR(9),
          @Lc_IveRefCur_Child2IveCase_IDNO                  CHAR(10),
          @Lc_IveRefCur_Child2_NAME                         CHAR(24),
          @Lc_IveRefCur_Child2Birth_DATE                    CHAR(8),
          @Lc_IveRefCur_Child2FedFunded_INDC                CHAR(1),
          @Lc_IveRefCur_Child2PaternityEst_INDC             CHAR(1),
          @Lc_IveRefCur_Child2Father_NAME                   CHAR(24),
          @Lc_IveRefCur_Child2FatherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child2Mother_NAME                   CHAR(24),
          @Lc_IveRefCur_Child2MotherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child2MotherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child2FatherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child2FosterCareBegin_DATE          CHAR(8),
          @Lc_IveRefCur_Child2Monthly_AMNT                  CHAR(10),
          @Lc_IveRefCur_Child3Mci_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child3Pid_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child3Ssn_NUMB                      CHAR(9),
          @Lc_IveRefCur_Child3IveCase_IDNO                  CHAR(10),
          @Lc_IveRefCur_Child3_NAME                         CHAR(24),
          @Lc_IveRefCur_Child3Birth_DATE                    CHAR(8),
          @Lc_IveRefCur_Child3FedFunded_INDC                CHAR(1),
          @Lc_IveRefCur_Child3PaternityEst_INDC             CHAR(1),
          @Lc_IveRefCur_Child3Father_NAME                   CHAR(24),
          @Lc_IveRefCur_Child3FatherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child3Mother_NAME                   CHAR(24),
          @Lc_IveRefCur_Child3MotherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child3MotherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child3FatherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child3FosterCareBegin_DATE          CHAR(8),
          @Lc_IveRefCur_Child3Monthly_AMNT                  CHAR(10),
          @Lc_IveRefCur_Child4Mci_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child4Pid_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child4Ssn_NUMB                      CHAR(9),
          @Lc_IveRefCur_Child4IveCase_IDNO                  CHAR(10),
          @Lc_IveRefCur_Child4_NAME                         CHAR(24),
          @Lc_IveRefCur_Child4Birth_DATE                    CHAR(8),
          @Lc_IveRefCur_Child4FedFunded_INDC                CHAR(1),
          @Lc_IveRefCur_Child4PaternityEst_INDC             CHAR(1),
          @Lc_IveRefCur_Child4Father_NAME                   CHAR(24),
          @Lc_IveRefCur_Child4FatherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child4Mother_NAME                   CHAR(24),
          @Lc_IveRefCur_Child4MotherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child4MotherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child4FatherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child4FosterCareBegin_DATE          CHAR(8),
          @Lc_IveRefCur_Child4Monthly_AMNT                  CHAR(10),
          @Lc_IveRefCur_Child5Mci_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child5Pid_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child5Ssn_NUMB                      CHAR(9),
          @Lc_IveRefCur_Child5IveCase_IDNO                  CHAR(10),
          @Lc_IveRefCur_Child5_NAME                         CHAR(24),
          @Lc_IveRefCur_Child5Birth_DATE                    CHAR(8),
          @Lc_IveRefCur_Child5FedFunded_INDC                CHAR(1),
          @Lc_IveRefCur_Child5PaternityEst_INDC             CHAR(1),
          @Lc_IveRefCur_Child5Father_NAME                   CHAR(24),
          @Lc_IveRefCur_Child5FatherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child5Mother_NAME                   CHAR(24),
          @Lc_IveRefCur_Child5MotherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child5MotherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child5FatherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child5FosterCareBegin_DATE          CHAR(8),
          @Lc_IveRefCur_Child5Monthly_AMNT                  CHAR(10),
          @Lc_IveRefCur_Child6Mci_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child6Pid_IDNO                      CHAR(10),
          @Lc_IveRefCur_Child6Ssn_NUMB                      CHAR(9),
          @Lc_IveRefCur_Child6IveCase_IDNO                  CHAR(10),
          @Lc_IveRefCur_Child6_NAME                         CHAR(24),
          @Lc_IveRefCur_Child6Birth_DATE                    CHAR(8),
          @Lc_IveRefCur_Child6FedFunded_INDC                CHAR(1),
          @Lc_IveRefCur_Child6PaternityEst_INDC             CHAR(1),
          @Lc_IveRefCur_Child6Father_NAME                   CHAR(24),
          @Lc_IveRefCur_Child6FatherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child6Mother_NAME                   CHAR(24),
          @Lc_IveRefCur_Child6MotherIveCase_IDNO            CHAR(10),
          @Lc_IveRefCur_Child6MotherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child6FatherIns_INDC                CHAR(1),
          @Lc_IveRefCur_Child6FosterCareBegin_DATE          CHAR(8),
          @Lc_IveRefCur_Child6Monthly_AMNT                  CHAR(10);
  -- Cursor declaration for foster care referral details from the temporary table
  DECLARE IveRef_CUR INSENSITIVE CURSOR FOR
   SELECT i.Seq_IDNO,
          i.Rec_ID,
          i.Application_DATE,
          i.Approved_DATE,
          i.IveCaseStatus_CODE,
          i.ApplicationCounty_IDNO,
          i.CourtOrder_INDC,
          i.File_ID,
          i.CourtOrder_DATE,
          i.CourtOrderCity_NAME,
          i.CourtOrderState_CODE,
          i.CourtOrder_AMNT,
          i.CourtOrderFrequency_CODE,
          i.CourtOrderEffective_INDC,
          i.CourtPaymentType_CODE,
          i.MotherInformation_INDC,
          i.Mother_NAME,
          i.MotherMCI_IDNO,
          i.MotherPid_IDNO,
          i.MotherPrimarySsn_NUMB,
          i.MotherOtherSsn_NUMB,
          i.MotherAlias_NAME,
          i.MotherIveCase_IDNO,
          i.MotherDeath_DATE,
          i.MotherHealthIns_INDC,
          i.MotherIns_NAME,
          i.MotherInsPolicy_ID,
          i.MotherAddress_CODE,
          i.MotherAddressNormalization_CODE,
          i.MotherLine1_ADDR,
          i.MotherLine2_ADDR,
          i.MotherCity_ADDR,
          i.MotherState_ADDR,
          i.MotherZip_ADDR,
          i.MotherBirth_DATE,
          i.MotherRace_CODE,
          i.MotherSex_CODE,
          i.MotherEmpl_CODE,
          i.MotherEmpl_NAME,
          i.MotherEmplAddressNormalization_CODE,
          i.MotherEmplLine1_ADDR,
          i.MotherEmplLine2_ADDR,
          i.MotherEmplCity_ADDR,
          i.MotherEmplState_ADDR,
          i.MotherEmplZip_ADDR,
          i.MotherLastPayment_DATE,
          i.MotherLastPayment_AMNT,
          i.MotherArrearage_AMNT,
          i.MotherPaymentDue_DATE,
          i.FatherInformation_INDC,
          i.Father_NAME,
          i.FatherMCI_IDNO,
          i.FatherPid_IDNO,
          i.FatherPrimarySsn_NUMB,
          i.FatherOtherSsn_NUMB,
          i.FatherAlias_NAME,
          i.FatherIveCase_IDNO,
          i.FatherDeath_DATE,
          i.FatherHealthIns_INDC,
          i.FatherIns_NAME,
          i.FatherInsPolicy_ID,
          i.FatherAddress_CODE,
          i.FatherAddressNormalization_CODE,
          i.FatherLine1_ADDR,
          i.FatherLine2_ADDR,
          i.FatherCity_ADDR,
          i.FatherState_ADDR,
          i.FatherZip_ADDR,
          i.FatherBirth_DATE,
          i.FatherRace_CODE,
          i.FatherSex_CODE,
          i.FatherEmpl_CODE,
          i.FatherEmpl_NAME,
          i.FatherEmplAddressNormalization_CODE,
          i.FatherEmplLine1_ADDR,
          i.FatherEmplLine2_ADDR,
          i.FatherEmplCity_ADDR,
          i.FatherEmplState_ADDR,
          i.FatherEmplZip_ADDR,
          i.FatherLastPayment_DATE,
          i.FatherLastPayment_AMNT,
          i.FatherArrearage_AMNT,
          i.FatherPaymentDue_DATE,
          i.Child1Mci_IDNO,
          i.Child1Pid_IDNO,
          i.Child1Ssn_NUMB,
          i.Child1IveCase_IDNO,
          i.Child1_NAME,
          i.Child1Birth_DATE,
          i.Child1FedFunded_INDC,
          i.Child1PaternityEst_INDC,
          i.Child1Father_NAME,
          i.Child1FatherIveCase_IDNO,
          i.Child1Mother_NAME,
          i.Child1MotherIveCase_IDNO,
          i.Child1MotherIns_INDC,
          i.Child1FatherIns_INDC,
          i.Child1FosterCareBegin_DATE,
          i.Child1Monthly_AMNT,
          i.Child2Mci_IDNO,
          i.Child2Pid_IDNO,
          i.Child2Ssn_NUMB,
          i.Child2IveCase_IDNO,
          i.Child2_NAME,
          i.Child2Birth_DATE,
          i.Child2FedFunded_INDC,
          i.Child2PaternityEst_INDC,
          i.Child2Father_NAME,
          i.Child2FatherIveCase_IDNO,
          i.Child2Mother_NAME,
          i.Child2MotherIveCase_IDNO,
          i.Child2MotherIns_INDC,
          i.Child2FatherIns_INDC,
          i.Child2FosterCareBegin_DATE,
          i.Child2Monthly_AMNT,
          i.Child3Mci_IDNO,
          i.Child3Pid_IDNO,
          i.Child3Ssn_NUMB,
          i.Child3IveCase_IDNO,
          i.Child3_NAME,
          i.Child3Birth_DATE,
          i.Child3FedFunded_INDC,
          i.Child3PaternityEst_INDC,
          i.Child3Father_NAME,
          i.Child3FatherIveCase_IDNO,
          i.Child3Mother_NAME,
          i.Child3MotherIveCase_IDNO,
          i.Child3MotherIns_INDC,
          i.Child3FatherIns_INDC,
          i.Child3FosterCareBegin_DATE,
          i.Child3Monthly_AMNT,
          i.Child4Mci_IDNO,
          i.Child4Pid_IDNO,
          i.Child4Ssn_NUMB,
          i.Child4IveCase_IDNO,
          i.Child4_NAME,
          i.Child4Birth_DATE,
          i.Child4FedFunded_INDC,
          i.Child4PaternityEst_INDC,
          i.Child4Father_NAME,
          i.Child4FatherIveCase_IDNO,
          i.Child4Mother_NAME,
          i.Child4MotherIveCase_IDNO,
          i.Child4MotherIns_INDC,
          i.Child4FatherIns_INDC,
          i.Child4FosterCareBegin_DATE,
          i.Child4Monthly_AMNT,
          i.Child5Mci_IDNO,
          i.Child5Pid_IDNO,
          i.Child5Ssn_NUMB,
          i.Child5IveCase_IDNO,
          i.Child5_NAME,
          i.Child5Birth_DATE,
          i.Child5FedFunded_INDC,
          i.Child5PaternityEst_INDC,
          i.Child5Father_NAME,
          i.Child5FatherIveCase_IDNO,
          i.Child5Mother_NAME,
          i.Child5MotherIveCase_IDNO,
          i.Child5MotherIns_INDC,
          i.Child5FatherIns_INDC,
          i.Child5FosterCareBegin_DATE,
          i.Child5Monthly_AMNT,
          i.Child6Mci_IDNO,
          i.Child6Pid_IDNO,
          i.Child6Ssn_NUMB,
          i.Child6IveCase_IDNO,
          i.Child6_NAME,
          i.Child6Birth_DATE,
          i.Child6FedFunded_INDC,
          i.Child6PaternityEst_INDC,
          i.Child6Father_NAME,
          i.Child6FatherIveCase_IDNO,
          i.Child6Mother_NAME,
          i.Child6MotherIveCase_IDNO,
          i.Child6MotherIns_INDC,
          i.Child6FatherIns_INDC,
          i.Child6FosterCareBegin_DATE,
          i.Child6Monthly_AMNT
     FROM LIREF_Y1 i
    WHERE i.Process_INDC = 'N'
    ORDER BY Seq_IDNO;

  BEGIN TRY
   -- Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE FROM COMMON PROCEDURE ';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
   
   SET @Lc_Job_ID = @Lc_JobProcessIveReferral_ID; 
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   -- Selecting date run, date last run, commit freq, exception threshold details --
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Lc_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdPARM_QNTY OUTPUT,
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
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   BEGIN TRANSACTION IVEREFERRAL_BATCH_PROCESS;

   SET @Ls_Sql_TEXT = 'OPEN IVE REFERRAL RESPONSE CURSOR ';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   OPEN IveRef_CUR;

   SET @Ls_Sql_TEXT = 'FETCH IVE REFERRAL RESPONSE CURSOR ';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   FETCH NEXT FROM IveRef_CUR INTO @Ln_IveRefCur_Seq_IDNO, @Lc_IveRefCur_Rec_ID, @Ld_IveRefCur_Application_DATE, @Lc_IveRefCur_Approved_DATE, @Lc_IveRefCur_IveCaseStatus_CODE, @Lc_IveRefCur_ApplicationCounty_IDNO, @Lc_IveRefCur_CourtOrder_INDC, @Lc_IveRefCur_File_ID, @Ld_IveRefCur_CourtOrder_DATE, @Lc_IveRefCur_CourtOrderCity_NAME, @Lc_IveRefCur_CourtOrderState_CODE, @Lc_IveRefCur_CourtOrder_AMNT, @Lc_IveRefCur_CourtOrderFrequency_CODE, @Lc_IveRefCur_CourtOrderEffective_INDC, @Lc_IveRefCur_CourtPaymentType_CODE, @Lc_IveRefCur_MotherInformation_INDC, @Lc_IveRefCur_Mother_NAME, @Lc_IveRefCur_MotherMci_IDNO, @Lc_IveRefCur_MotherPid_IDNO, @Lc_IveRefCur_MotherPrimarySsn_NUMB, @Lc_IveRefCur_MotherOtherSsn_NUMB, @Lc_IveRefCur_MotherAlias_NAME, @Lc_IveRefCur_MotherIveCase_IDNO, @Lc_IveRefCur_MotherDeath_DATE, @Lc_IveRefCur_MotherHealthIns_INDC, @Lc_IveRefCur_MotherInsPolicy_ID, @Lc_IveRefCur_MotherIns_NAME, @Lc_IveRefCur_MotherAddress_CODE, @Lc_IveRefCur_MotherAddressNormalization_CODE, @Ls_IveRefCur_MotherLine1_ADDR, @Ls_IveRefCur_MotherLine2_ADDR, @Lc_IveRefCur_MotherCity_ADDR, @Lc_IveRefCur_MotherState_ADDR, @Lc_IveRefCur_MotherZip_ADDR, @Lc_IveRefCur_MotherBirth_DATE, @Lc_IveRefCur_MotherRace_CODE, @Lc_IveRefCur_MotherSex_CODE, @Lc_IveRefCur_MotherEmpl_CODE, @Lc_IveRefCur_MotherEmpl_NAME, @Lc_IveRefCur_MotherEmplAddressNormalization_CODE, @Ls_IveRefCur_MotherEmplLine1_ADDR, @Ls_IveRefCur_MotherEmplLine2_ADDR, @Lc_IveRefCur_MotherEmplCity_ADDR, @Lc_IveRefCur_MotherEmplState_ADDR, @Lc_IveRefCur_MotherEmplZip_ADDR, @Lc_IveRefCur_MotherLastPayment_DATE, @Lc_IveRefCur_MotherLastPayment_AMNT, @Lc_IveRefCur_MotherArrearage_AMNT, @Lc_IveRefCur_MotherPaymentDue_DATE, @Lc_IveRefCur_FatherInformation_INDC, @Lc_IveRefCur_Father_NAME, @Lc_IveRefCur_FatherMci_IDNO, @Lc_IveRefCur_FatherPid_IDNO, @Lc_IveRefCur_FatherPrimarySsn_NUMB, @Lc_IveRefCur_FatherOtherSsn_NUMB, @Lc_IveRefCur_FatherAlias_NAME, @Lc_IveRefCur_FatherIveCase_IDNO, @Lc_IveRefCur_FatherDeath_DATE, @Lc_IveRefCur_FatherHealthIns_INDC, @Lc_IveRefCur_FatherIns_NAME, @Lc_IveRefCur_FatherInsPolicy_ID, @Lc_IveRefCur_FatherAddress_CODE, @Lc_IveRefCur_FatherAddressNormalization_CODE, @Ls_IveRefCur_FatherLine1_ADDR, @Ls_IveRefCur_FatherLine2_ADDR, @Lc_IveRefCur_FatherCity_ADDR, @Lc_IveRefCur_FatherState_ADDR, @Lc_IveRefCur_FatherZip_ADDR, @Lc_IveRefCur_FatherBirth_DATE, @Lc_IveRefCur_FatherRace_CODE, @Lc_IveRefCur_FatherSex_CODE, @Lc_IveRefCur_FatherEmpl_CODE, @Lc_IveRefCur_FatherEmpl_NAME, @Lc_IveRefCur_FatherEmplAddressNormalization_CODE, @Ls_IveRefCur_FatherEmplLine1_ADDR, @Ls_IveRefCur_FatherEmplLine2_ADDR, @Lc_IveRefCur_FatherEmplCity_ADDR, @Lc_IveRefCur_FatherEmplState_ADDR, @Lc_IveRefCur_FatherEmplZip_ADDR, @Lc_IveRefCur_FatherLastPayment_DATE, @Lc_IveRefCur_FatherLastPayment_AMNT, @Lc_IveRefCur_FatherArrearage_AMNT, @Lc_IveRefCur_FatherPaymentDue_DATE, @Lc_IveRefCur_Child1Mci_IDNO, @Lc_IveRefCur_Child1Pid_IDNO, @Lc_IveRefCur_Child1Ssn_NUMB, @Lc_IveRefCur_Child1IveCase_IDNO, @Lc_IveRefCur_Child1_NAME, @Lc_IveRefCur_Child1Birth_DATE, @Lc_IveRefCur_Child1FedFunded_INDC, @Lc_IveRefCur_Child1PaternityEst_INDC, @Lc_IveRefCur_Child1Father_NAME, @Lc_IveRefCur_Child1FatherIveCase_IDNO, @Lc_IveRefCur_Child1Mother_NAME, @Lc_IveRefCur_Child1MotherIveCase_IDNO, @Lc_IveRefCur_Child1MotherIns_INDC, @Lc_IveRefCur_Child1FatherIns_INDC, @Lc_IveRefCur_Child1FosterCareBegin_DATE, @Lc_IveRefCur_Child1Monthly_AMNT, @Lc_IveRefCur_Child2Mci_IDNO, @Lc_IveRefCur_Child2Pid_IDNO, @Lc_IveRefCur_Child2Ssn_NUMB, @Lc_IveRefCur_Child2IveCase_IDNO, @Lc_IveRefCur_Child2_NAME, @Lc_IveRefCur_Child2Birth_DATE, @Lc_IveRefCur_Child2FedFunded_INDC, @Lc_IveRefCur_Child2PaternityEst_INDC, @Lc_IveRefCur_Child2Father_NAME, @Lc_IveRefCur_Child2FatherIveCase_IDNO, @Lc_IveRefCur_Child2Mother_NAME, @Lc_IveRefCur_Child2MotherIveCase_IDNO, @Lc_IveRefCur_Child2MotherIns_INDC, @Lc_IveRefCur_Child2FatherIns_INDC, @Lc_IveRefCur_Child2FosterCareBegin_DATE, @Lc_IveRefCur_Child2Monthly_AMNT, @Lc_IveRefCur_Child3Mci_IDNO, @Lc_IveRefCur_Child3Pid_IDNO, @Lc_IveRefCur_Child3Ssn_NUMB, @Lc_IveRefCur_Child3IveCase_IDNO, @Lc_IveRefCur_Child3_NAME, @Lc_IveRefCur_Child3Birth_DATE, @Lc_IveRefCur_Child3FedFunded_INDC, @Lc_IveRefCur_Child3PaternityEst_INDC, @Lc_IveRefCur_Child3Father_NAME, @Lc_IveRefCur_Child3FatherIveCase_IDNO, @Lc_IveRefCur_Child3Mother_NAME, @Lc_IveRefCur_Child3MotherIveCase_IDNO, @Lc_IveRefCur_Child3MotherIns_INDC, @Lc_IveRefCur_Child3FatherIns_INDC, @Lc_IveRefCur_Child3FosterCareBegin_DATE, @Lc_IveRefCur_Child3Monthly_AMNT, @Lc_IveRefCur_Child4Mci_IDNO, @Lc_IveRefCur_Child4Pid_IDNO, @Lc_IveRefCur_Child4Ssn_NUMB, @Lc_IveRefCur_Child4IveCase_IDNO, @Lc_IveRefCur_Child4_NAME, @Lc_IveRefCur_Child4Birth_DATE, @Lc_IveRefCur_Child4FedFunded_INDC, @Lc_IveRefCur_Child4PaternityEst_INDC, @Lc_IveRefCur_Child4Father_NAME, @Lc_IveRefCur_Child4FatherIveCase_IDNO, @Lc_IveRefCur_Child4Mother_NAME, @Lc_IveRefCur_Child4MotherIveCase_IDNO, @Lc_IveRefCur_Child4MotherIns_INDC, @Lc_IveRefCur_Child4FatherIns_INDC, @Lc_IveRefCur_Child4FosterCareBegin_DATE, @Lc_IveRefCur_Child4Monthly_AMNT, @Lc_IveRefCur_Child5Mci_IDNO, @Lc_IveRefCur_Child5Pid_IDNO, @Lc_IveRefCur_Child5Ssn_NUMB, @Lc_IveRefCur_Child5IveCase_IDNO, @Lc_IveRefCur_Child5_NAME, @Lc_IveRefCur_Child5Birth_DATE, @Lc_IveRefCur_Child5FedFunded_INDC, @Lc_IveRefCur_Child5PaternityEst_INDC, @Lc_IveRefCur_Child5Father_NAME, @Lc_IveRefCur_Child5FatherIveCase_IDNO, @Lc_IveRefCur_Child5Mother_NAME, @Lc_IveRefCur_Child5MotherIveCase_IDNO, @Lc_IveRefCur_Child5MotherIns_INDC, @Lc_IveRefCur_Child5FatherIns_INDC, @Lc_IveRefCur_Child5FosterCareBegin_DATE, @Lc_IveRefCur_Child5Monthly_AMNT, @Lc_IveRefCur_Child6Mci_IDNO, @Lc_IveRefCur_Child6Pid_IDNO, @Lc_IveRefCur_Child6Ssn_NUMB, @Lc_IveRefCur_Child6IveCase_IDNO, @Lc_IveRefCur_Child6_NAME, @Lc_IveRefCur_Child6Birth_DATE, @Lc_IveRefCur_Child6FedFunded_INDC, @Lc_IveRefCur_Child6PaternityEst_INDC, @Lc_IveRefCur_Child6Father_NAME, @Lc_IveRefCur_Child6FatherIveCase_IDNO, @Lc_IveRefCur_Child6Mother_NAME, @Lc_IveRefCur_Child6MotherIveCase_IDNO, @Lc_IveRefCur_Child6MotherIns_INDC, @Lc_IveRefCur_Child6FatherIns_INDC, @Lc_IveRefCur_Child6FosterCareBegin_DATE, @Lc_IveRefCur_Child6Monthly_AMNT;
   
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --Process ive referral records 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      -- First check both the parents information exists in the referral file by checking PID numbers are not zeros and 
      -- Member Mci number are not zeros.
      SAVE TRANSACTION SAVEIVE_PROCESS;

      SET @Lc_FatherCreateApplication_INDC = @Lc_ValueNo_INDC;
      SET @Lc_FatherUpdateApplication_INDC = @Lc_ValueNo_INDC;
      SET @Lc_UiFatherCreateApplication_INDC = @Lc_ValueNo_INDC;
      SET @Lc_MotherCreateApplication_INDC = @Lc_ValueNo_INDC;
      SET @Lc_MotherUpdateApplication_INDC = @Lc_ValueNo_INDC;
      SET @Lc_UiMotherCreateApplication_INDC = @Lc_ValueNo_INDC;
      --  UNKNOWN EXCEPTION IN BATCH
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ls_BateRecord_TEXT = 'Rec Id = ' + @Lc_IveRefCur_Rec_ID + ', Application Dt = ' + CAST(@Ld_IveRefCur_Application_DATE AS VARCHAR(10)) + ', Approved Dt = ' + @Lc_IveRefCur_Approved_DATE + ', Ive Case St Cd = ' + @Lc_IveRefCur_IveCaseStatus_CODE + ', County ID = ' + @Lc_IveRefCur_ApplicationCounty_IDNO + ', Ord Indc = ' + @Lc_IveRefCur_CourtOrder_INDC + ', File Id = ' + @Lc_IveRefCur_File_ID + ', Court Ord Dt = ' + CAST(@Ld_IveRefCur_CourtOrder_DATE AS VARCHAR(10)) + ', City Name = ' + @Lc_IveRefCur_CourtOrderCity_NAME + ', St Cd = ' + @Lc_IveRefCur_CourtOrderState_CODE + ', Order Amt = ' + @Lc_IveRefCur_CourtOrder_AMNT + ', Freq Cd = ' + @Lc_IveRefCur_CourtOrderFrequency_CODE + ', Ord Eff Indc = ' + @Lc_IveRefCur_CourtOrderEffective_INDC + ', Pmt Typ CD = ' + @Lc_IveRefCur_CourtPaymentType_CODE + ', Mother Indc = ' + @Lc_IveRefCur_MotherInformation_INDC + ', Name = ' + @Lc_IveRefCur_Mother_NAME + ', Mci Id = ' + @Lc_IveRefCur_MotherMci_IDNO + ', Pid Id = ' + @Lc_IveRefCur_MotherPid_IDNO + ', Primary Ssn = ' + @Lc_IveRefCur_MotherPrimarySsn_NUMB + ', Other Ssn = ' + @Lc_IveRefCur_MotherOtherSsn_NUMB + ', Alias Name = ' + @Lc_IveRefCur_MotherAlias_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_MotherIveCase_IDNO + ', Death Dt = ' + @Lc_IveRefCur_MotherDeath_DATE + ', Addr Normalization Cd = ' + @Lc_IveRefCur_MotherAddressNormalization_CODE + ', Addr Line1 = ' + @Ls_IveRefCur_MotherLine1_ADDR + ', Addr Line2 = ' + @Ls_IveRefCur_MotherLine2_ADDR + ', City = ' + @Lc_IveRefCur_MotherCity_ADDR + ', State = ' + @Lc_IveRefCur_MotherState_ADDR + ', Zip = ' + @Lc_IveRefCur_MotherZip_ADDR + ', Birth Dt = ' + @Lc_IveRefCur_MotherBirth_DATE + ', Race = ' + @Lc_IveRefCur_MotherRace_CODE + ', Sex Cd = ' + @Lc_IveRefCur_MotherSex_CODE + ', Empl Cd = ' + @Lc_IveRefCur_MotherEmpl_CODE + ', Empl Name = ' + @Lc_IveRefCur_MotherEmpl_NAME + ', Empl ADDR Normalization Cd = ' + @Lc_IveRefCur_MotherEmplAddressNormalization_CODE + ', Addr Line1 = ' + @Ls_IveRefCur_MotherEmplLine1_ADDR + ', Addr Line2 = ' + @Ls_IveRefCur_MotherEmplLine2_ADDR + ', City = ' + @Lc_IveRefCur_MotherEmplCity_ADDR + ', State = ' + @Lc_IveRefCur_MotherEmplState_ADDR + ', Zip = ' + @Lc_IveRefCur_MotherEmplZip_ADDR + ', Last Pmt dt = ' + @Lc_IveRefCur_MotherLastPayment_DATE + ', Last Pmt Amt = ' + @Lc_IveRefCur_MotherLastPayment_AMNT + ', Arrs Amt = ' + @Lc_IveRefCur_MotherArrearage_AMNT + ', Pmt Due Dt = ' + @Lc_IveRefCur_MotherPaymentDue_DATE + ', Father Indc = ' + @Lc_IveRefCur_FatherInformation_INDC + ', Name = ' + @Lc_IveRefCur_Father_NAME + ', Mci Id = ' + @Lc_IveRefCur_FatherMci_IDNO + ', Pid Id = ' + @Lc_IveRefCur_FatherPid_IDNO + ', Primary Ssn = ' + @Lc_IveRefCur_FatherPrimarySsn_NUMB + ', Other Ssn = ' + @Lc_IveRefCur_FatherOtherSsn_NUMB + ', Alias Name = ' + @Lc_IveRefCur_FatherAlias_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_FatherIveCase_IDNO + ', Death Dt = ' + @Lc_IveRefCur_FatherDeath_DATE + ', Addr Normalization Cd = ' + @Lc_IveRefCur_FatherAddressNormalization_CODE + ', Addr Line1 = ' + @Ls_IveRefCur_FatherLine1_ADDR + ', Addr Line2 = ' + @Ls_IveRefCur_FatherLine2_ADDR + ', City = ' + @Lc_IveRefCur_FatherCity_ADDR + ', State = ' + @Lc_IveRefCur_FatherState_ADDR + ', Zip = ' + @Lc_IveRefCur_FatherZip_ADDR + ', Birth Dt = ' + @Lc_IveRefCur_FatherBirth_DATE + ', Race = ' + @Lc_IveRefCur_FatherEmpl_NAME + ', Empl ADDR Normalization Cd = ' + @Lc_IveRefCur_FatherEmplAddressNormalization_CODE + ', Addr Line1 = ' + @Ls_IveRefCur_FatherEmplLine1_ADDR + ', Addr Line2 = ' + @Ls_IveRefCur_FatherEmplLine2_ADDR + ', City = ' + @Lc_IveRefCur_FatherEmplCity_ADDR + ', State = ' + @Lc_IveRefCur_FatherEmplState_ADDR + ', Zip = ' + @Lc_IveRefCur_FatherEmplZip_ADDR + ', Last Pmt dt = ' + @Lc_IveRefCur_FatherLastPayment_DATE   + ', Last Pmt Amt = ' + @Lc_IveRefCur_FatherLastPayment_AMNT + ', Arrs Amt = ' + @Lc_IveRefCur_FatherArrearage_AMNT + ', Pmt Due Dt = ' + @Lc_IveRefCur_FatherPaymentDue_DATE + ', Child1 Mci Id = ' + @Lc_IveRefCur_Child1Mci_IDNO + ', Pid Id = ' + @Lc_IveRefCur_Child1Pid_IDNO + ', Ssn = ' + @Lc_IveRefCur_Child1Ssn_NUMB + ', Ive Case Id = ' + @Lc_IveRefCur_Child1IveCase_IDNO + ', Name = ' + @Lc_IveRefCur_Child1_NAME + ', Dob = ' + @Lc_IveRefCur_Child1Birth_DATE + ', Funded Indc = ' + @Lc_IveRefCur_Child1FedFunded_INDC + ', Pat Est Indc = ' + @Lc_IveRefCur_Child1PaternityEst_INDC + ', Father Name = ' + @Lc_IveRefCur_Child1Father_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child1FatherIveCase_IDNO + ', Mother Name = ' + @Lc_IveRefCur_Child1Mother_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child1MotherIveCase_IDNO + ', Mother Ins Indc = ' + @Lc_IveRefCur_Child1MotherIns_INDC + ', Father Ins Indc = ' + @Lc_IveRefCur_Child1FatherIns_INDC + ', Care Beg Dt = ' + @Lc_IveRefCur_Child1FosterCareBegin_DATE + ', Monthly Amt = ' + @Lc_IveRefCur_Child1Monthly_AMNT + ', Child2 Mci Id = ' + @Lc_IveRefCur_Child2Mci_IDNO + ', Pid Id = ' + @Lc_IveRefCur_Child2Pid_IDNO + ', Ssn = ' + @Lc_IveRefCur_Child2Ssn_NUMB + ', Ive Case Id = ' + @Lc_IveRefCur_Child2IveCase_IDNO + ', Name = ' + @Lc_IveRefCur_Child2_NAME + ', Dob = ' + @Lc_IveRefCur_Child2Birth_DATE + ', Funded Indc = ' + @Lc_IveRefCur_Child2FedFunded_INDC + ', Pat Est Indc = ' + @Lc_IveRefCur_Child2PaternityEst_INDC + ', Father Name = ' + @Lc_IveRefCur_Child2Father_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child2FatherIveCase_IDNO + ', Mother Name = ' + @Lc_IveRefCur_Child2Mother_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child2MotherIveCase_IDNO + ', Mother Ins Indc = ' + @Lc_IveRefCur_Child2MotherIns_INDC + ', Father Ins Indc = ' + @Lc_IveRefCur_Child2FatherIns_INDC + ', Care Beg Dt = ' + @Lc_IveRefCur_Child2FosterCareBegin_DATE + ', Monthly Amt = ' + @Lc_IveRefCur_Child2Monthly_AMNT + ', Child3 Mci Id = ' + @Lc_IveRefCur_Child3Mci_IDNO + ', Pid Id = ' + @Lc_IveRefCur_Child3Pid_IDNO + ', Ssn = ' + @Lc_IveRefCur_Child3Ssn_NUMB + ', Ive Case Id = ' + @Lc_IveRefCur_Child3IveCase_IDNO + ', Name = ' + @Lc_IveRefCur_Child3_NAME + ', Dob = ' + @Lc_IveRefCur_Child3Birth_DATE + ', Funded Indc = ' + @Lc_IveRefCur_Child3FedFunded_INDC + ', Pat Est Indc = ' + @Lc_IveRefCur_Child3PaternityEst_INDC + ', Father Name = ' + @Lc_IveRefCur_Child3Father_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child3FatherIveCase_IDNO + ', Mother Name = ' + @Lc_IveRefCur_Child3Mother_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child3MotherIveCase_IDNO + ', Mother Ins Indc = ' + @Lc_IveRefCur_Child3MotherIns_INDC + ', Father Ins Indc = ' + @Lc_IveRefCur_Child3FatherIns_INDC + ', Care Beg Dt = ' + @Lc_IveRefCur_Child3FosterCareBegin_DATE + ', Monthly Amt = ' + @Lc_IveRefCur_Child3Monthly_AMNT + ', Child4 Mci Id = ' + @Lc_IveRefCur_Child4Mci_IDNO + ', Pid Id = ' + @Lc_IveRefCur_Child4Pid_IDNO + ', Ssn = ' + @Lc_IveRefCur_Child4Ssn_NUMB + ', Ive Case Id = ' + @Lc_IveRefCur_Child4IveCase_IDNO + ', Name = ' + @Lc_IveRefCur_Child4_NAME + ', Dob = ' + @Lc_IveRefCur_Child4Birth_DATE + ', Funded Indc = ' + @Lc_IveRefCur_Child4FedFunded_INDC + ', Pat Est Indc = ' + @Lc_IveRefCur_Child4PaternityEst_INDC + ', Father Name = ' + @Lc_IveRefCur_Child4Father_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child4FatherIveCase_IDNO + ', Mother Name = ' + @Lc_IveRefCur_Child4Mother_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child4MotherIveCase_IDNO + ', Mother Ins Indc = ' + @Lc_IveRefCur_Child4MotherIns_INDC + ', Father Ins Indc = ' + @Lc_IveRefCur_Child4FatherIns_INDC + ', Care Beg Dt = ' + @Lc_IveRefCur_Child4FosterCareBegin_DATE + ', Monthly Amt = ' + @Lc_IveRefCur_Child4Monthly_AMNT + ', Child5 Mci Id = ' + @Lc_IveRefCur_Child5Mci_IDNO + ', Pid Id = ' + @Lc_IveRefCur_Child5Pid_IDNO + ', Ssn = ' + @Lc_IveRefCur_Child5Ssn_NUMB + ', Ive Case Id = ' + @Lc_IveRefCur_Child5IveCase_IDNO + ', Name = ' + @Lc_IveRefCur_Child5_NAME + ', Dob = ' + @Lc_IveRefCur_Child5Birth_DATE + ', Funded Indc = ' + @Lc_IveRefCur_Child5FedFunded_INDC + ', Pat Est Indc = ' + @Lc_IveRefCur_Child5PaternityEst_INDC + ', Father Name = ' + @Lc_IveRefCur_Child5Father_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child5FatherIveCase_IDNO + ', Mother Name = ' + @Lc_IveRefCur_Child5Mother_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child5MotherIveCase_IDNO + ', Mother Ins Indc = ' + @Lc_IveRefCur_Child5MotherIns_INDC + ', Father Ins Indc = ' + @Lc_IveRefCur_Child5FatherIns_INDC + ', Care Beg Dt = ' + @Lc_IveRefCur_Child5FosterCareBegin_DATE + ', Monthly Amt = ' + @Lc_IveRefCur_Child5Monthly_AMNT + ', Child6 Mci Id = ' + @Lc_IveRefCur_Child6Mci_IDNO + ', Pid Id = ' + @Lc_IveRefCur_Child6Pid_IDNO + ', Ssn = ' + @Lc_IveRefCur_Child6Ssn_NUMB + ', Ive Case Id = ' + @Lc_IveRefCur_Child6IveCase_IDNO + ', Name = ' + @Lc_IveRefCur_Child6_NAME + ', Dob = ' + @Lc_IveRefCur_Child6Birth_DATE + ', Funded Indc = ' + @Lc_IveRefCur_Child6FedFunded_INDC + ', Pat Est Indc = ' + @Lc_IveRefCur_Child6PaternityEst_INDC + ', Father Name = ' + @Lc_IveRefCur_Child6Father_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child6FatherIveCase_IDNO + ', Mother Name = ' + @Lc_IveRefCur_Child6Mother_NAME + ', Ive Case Id = ' + @Lc_IveRefCur_Child6MotherIveCase_IDNO + ', Mother Ins Indc = ' + @Lc_IveRefCur_Child6MotherIns_INDC + ', Father Ins Indc = ' + @Lc_IveRefCur_Child6FatherIns_INDC + ', Care Beg Dt = ' + @Lc_IveRefCur_Child6FosterCareBegin_DATE + ', Monthly Amt = ' + @Lc_IveRefCur_Child6Monthly_AMNT;
      
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      
      -- Delete the data in the temporary tables
      SET @Ls_Sql_TEXT = 'DELETE THE DATA FROM THE TEMPORARY TABLE #IveMother_Matched_Cases_P1';
      SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

      DELETE FROM #IveMother_Matched_Cases_P1;

      SET @Ls_Sql_TEXT = 'DELETE THE DATA FROM THE TEMPORARY TABLE #IveFather_Matched_Cases_P1';
      SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

      DELETE FROM #IveFather_Matched_Cases_P1;

      SET @Ls_Sql_TEXT = 'DELETE THE DATA FROM THE TEMPORARY TABLE #IveRefTo_Decss_MotherMatch_P1';
      SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

      DELETE FROM #IveRefTo_Decss_MotherMatch_P1;

      SET @Ls_Sql_TEXT = 'DELETE THE DATA FROM THE TEMPORARY TABLE #IveRefTo_Decss_FatherMatch_P1';
      SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

      DELETE FROM #IveRefTo_Decss_FatherMatch_P1;
      
      SET @Ls_Sql_TEXT = 'DELETE THE DATA FROM THE TEMPORARY TABLE #IveRefTo_Decss_PendingappsMatch_P1';
      SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;
      DELETE FROM #IveRefTo_Decss_PendingappsMatch_P1

      -- Process mother information from foster care referral 
      -- If the date of death is blank or null, Do the following process 
      SET @Lc_MotherDeathDate_INDC = @Lc_ValueNo_INDC;
      SET @Lc_FatherDeathDate_INDC = @Lc_ValueNo_INDC;
      
      IF (@Lc_IveRefCur_MotherDeath_DATE IS NULL
           OR @Lc_IveRefCur_MotherDeath_DATE = ''
           OR @Lc_IveRefCur_MotherDeath_DATE = @Ln_Zeros_NUMB)
       BEGIN
        SET @Lc_MotherDeathDate_INDC = @Lc_ValueNo_INDC;
       END
      ELSE
       BEGIN
        SET @Lc_MotherDeathDate_INDC = @Lc_ValueYes_INDC;
       END

      --Process father information from foster care referral
     
      IF (@Lc_IveRefCur_FatherDeath_DATE IS NULL
           OR @Lc_IveRefCur_FatherDeath_DATE = ''
           OR @Lc_IveRefCur_FatherDeath_DATE = @Ln_Zeros_NUMB)
       BEGIN
        SET @Lc_FatherDeathDate_INDC = @Lc_ValueNo_INDC;
       END
      ELSE
       BEGIN
        SET @Lc_FatherDeathDate_INDC = @Lc_ValueYes_INDC;
       END

      SET @Lc_MotherMatch_INDC = @Lc_ValueNo_INDC;
      SET @Lc_FatherMatch_INDC = @Lc_ValueNo_INDC;
      SET @Lc_MotherChildMatch_INDC = @Lc_ValueNo_INDC;
      SET @Lc_FatherChildMatch_INDC = @Lc_ValueNo_INDC;
      SET @Ls_MotherMatchCases_TEXT = @Lc_Space_TEXT;
      SET @Ls_FatherMatchCases_TEXT = @Lc_Space_TEXT;
      SET @Li_LoopCount_QNTY = 1;
      -- Process mother and father information 
      IF @Lc_IveRefCur_MotherInformation_INDC = @Lc_ValueYes_INDC
         BEGIN 
          SET @Ln_IveCase_IDNO = @Lc_IveRefCur_MotherIveCase_IDNO;
          SET @Lc_Sex_CODE = @Lc_SexF_CODE;
          DECLARE MhisIve_CUR INSENSITIVE CURSOR FOR
          SELECT a.Case_IDNO,
                a.CaseWelfare_IDNO,
                c.CaseMemberStatus_CODE,
                c.CaseRelationship_CODE,
                c.MemberMci_IDNO,
                d.StatusCase_CODE,
                b.Last_Name,
                b.First_NAME,
                b.MemberSsn_NUMB,
                b.Birth_DATE,
                b.IveParty_IDNO,
                e.MemberMci_IDNO
           FROM MHIS_Y1 a,
                DEMO_Y1 b,
                CMEM_Y1 c,
                CASE_Y1 d,
                CMEM_Y1 e
          WHERE CaseWelfare_IDNO = @Ln_IveCase_IDNO
            AND a.Case_IDNO = c.Case_IDNO
            AND a.End_DATE = @Ld_High_DATE
            AND a.Case_IDNO = d.Case_IDNO
            AND d.StatusCase_CODE = 'O'
            AND c.CaseMemberStatus_CODE = 'A'
            AND c.CaseRelationship_CODE IN ('A', 'P')
            AND c.MemberMci_IDNO = b.MemberMci_IDNO
            AND b.MemberSex_CODE = @Lc_Sex_CODE
            AND a.Case_IDNO = e.Case_IDNO
            AND a.MemberMci_IDNO = e.MemberMci_IDNO
            AND e.CaseRelationship_CODE = 'D'
            AND e.CaseMemberStatus_CODE = 'A';
            
          SET @Ls_Sql_TEXT = 'OPEN MhisIve RESPONSE CURSOR ';
          SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

		  OPEN MhisIve_CUR;

          SET @Ls_Sql_TEXT = 'FETCH MhisIve RESPONSE CURSOR ';
          SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;
         
          FETCH NEXT FROM MhisIve_CUR INTO @Ln_MhisIveCur_Case_IDNO, @Ln_MhisIveCur_CaseWelfare_IDNO, @Lc_MhisIveCur_CaseMemberStatus_CODE, @Lc_MhisIveCur_CaseRelationship_CODE, @Ln_MhisIveCur_MemberMci_IDNO, @Lc_MhisIveCur_StatusCase_CODE, @Lc_MhisIveCur_Last_NAME, @Lc_MhisIveCur_First_NAME, @Ln_MhisIveCur_MemberSsn_NUMB, @Ld_MhisIveCur_Birth_DATE, @Ln_MhisIveCur_IveParty_IDNO, @Ln_MhisIveCur_ChildMemberMci_IDNO;
          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        -- Loop through mother information for MHIS_Y1  match
          WHILE @Li_FetchStatus_QNTY = 0
           BEGIN
            SET @Lc_MotherLast_NAME = '';
            SET @Lc_MotherFirst_NAME = '';
            SET @Lc_Partial_NAME = '';
            SET @Li_Comma_QNTY = @Ln_Zero_Numb;
            SET @Li_SpaceCount_QNTY = @Ln_Zero_NUMB;
            IF @Lc_IveRefCur_Mother_NAME <> ''
                OR @Lc_IveRefCur_Mother_NAME IS NOT NULL
             BEGIN
                SET @Li_Comma_QNTY = CHARINDEX(',', @Lc_IveRefCur_Mother_NAME);
				SET @Lc_MotherLast_NAME = LEFT(@Lc_IveRefCur_Mother_NAME, @Li_Comma_QNTY - 1);
				SET @Lc_Partial_NAME = SUBSTRING(@Lc_IveRefCur_Mother_NAME, @Li_Comma_QNTY + 2, LEN(@Lc_IveRefCur_Mother_NAME) - (@Li_Comma_QNTY + 1));
				SET @Li_SpaceCount_QNTY = CHARINDEX(' ', @Lc_IveRefCur_Mother_NAME);
				SET @Lc_MotherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_SpaceCount_QNTY - 1)
             END
            
            IF LTRIM(RTRIM(@Lc_IveRefCur_MotherPid_IDNO)) <> ''
               AND CAST(@Lc_IveRefCur_MotherPid_IDNO AS NUMERIC) <> @Ln_Zeros_NUMB
               AND @Ln_MhisIveCur_IveParty_IDNO = @Lc_IveRefCur_MotherPid_IDNO
             BEGIN
              IF @Lc_MotherMatch_INDC <> 'Y'
               BEGIN
                SET @Ls_MotherMatchCases_TEXT = @Ls_MotherMatchCases_TEXT + '';
                SET @Lc_MotherMatch_INDC = 'Y';
               END
             END
            ELSE IF LTRIM(RTRIM(@Lc_IveRefCur_MotherPrimarySsn_NUMB)) <> ''
               AND CAST(@Lc_IveRefCur_MotherPrimarySsn_NUMB AS NUMERIC) <> @Ln_Zeros_NUMB
               AND (@Lc_IveRefCur_Mother_NAME <> ''
                     OR @Lc_IveRefCur_Mother_NAME <> NULL)
               AND @Ln_MhisIveCur_MemberSsn_NUMB = @Lc_IveRefCur_MotherPrimarySsn_NUMB
               AND @Lc_MhisIveCur_Last_NAME = @Lc_MotherLast_NAME 
             BEGIN
              IF @Lc_MotherMatch_INDC <> 'Y'
               BEGIN
                SET @Lc_MotherMatch_INDC = 'Y';
               END
             END
            ELSE IF (@Lc_IveRefCur_Mother_NAME <> ''
                 OR @Lc_IveRefCur_Mother_NAME <> NULL)
               AND @Lc_IveRefCur_MotherBirth_DATE <> @Ld_Low_DATE
               AND @Lc_MhisIveCur_Last_NAME = @Lc_MotherLast_NAME 
               AND @Ld_MhisIveCur_Birth_DATE = @Lc_IveRefCur_MotherBirth_DATE
             BEGIN
              
              IF @Lc_MotherMatch_INDC <> 'Y'
               BEGIN
                SET @Lc_MotherMatch_INDC = 'Y';
               END
             END
            ELSE IF (@Lc_IveRefCur_Mother_NAME <> ''
                 OR @Lc_IveRefCur_Mother_NAME <> NULL)
               AND @Lc_IveRefCur_MotherBirth_DATE <> @Ld_Low_DATE
               AND @Lc_MhisIveCur_First_NAME = @Lc_MotherFirst_NAME 
               AND @Ld_MhisIveCur_Birth_DATE = @Lc_IveRefCur_MotherBirth_DATE
             BEGIN
              IF @Lc_MotherMatch_INDC <> 'Y'
               BEGIN
                SET @Lc_MotherMatch_INDC = 'Y';
               END
             END
            ELSE
            -- Mother information not matched
            IF @Lc_MotherMatch_INDC <> 'Y'
             BEGIN
              SET @Lc_MotherMatch_INDC = 'N';
             END

            IF @Lc_MotherMatch_INDC = 'Y'
             BEGIN
              SET @Ls_Sql_TEXT = 'INSERTING DATA INTO TEMPORARY TABLE #IveMother_Matched_Cases_P1' ;
              SET @Ls_Sqldata_TEXT = 'MOTHER_WELFARE_CASE_IDNO = ' + CAST(@Ln_MhisIveCur_CaseWelfare_IDNO AS VARCHAR) + ', MOTHER_IVD_CASE_IDNO = ' + CAST(@Ln_MhisIveCur_Case_IDNO AS VARCHAR) ;
              
              INSERT INTO #IveMother_Matched_Cases_P1
                          (IveMotherCase_IDNO,
                           IvdMotherCase_IDNO,
                           IvdMotherNcpMci_IDNO,
                           IvdMotherChildMci_IDNO,
                           MotherChildMatch_INDC)
                   VALUES (@Ln_MhisIveCur_CaseWelfare_IDNO, -- IveMotherCase_IDNO
                           @Ln_MhisIveCur_Case_IDNO, -- IvdMotherCase_IDNO
                           @Ln_MhisIveCur_MemberMci_IDNO, -- IvdMotherNcpMci_IDNO
                           @Ln_MhisIveCur_ChildMemberMci_IDNO, --IvdMotherChildMci_IDNO
                           @Lc_ValueNo_INDC); -- MotherChildMatch_INDC
             END
            FETCH NEXT FROM MhisIve_CUR INTO @Ln_MhisIveCur_Case_IDNO, @Ln_MhisIveCur_CaseWelfare_IDNO, @Lc_MhisIveCur_CaseMemberStatus_CODE, @Lc_MhisIveCur_CaseRelationship_CODE, @Ln_MhisIveCur_MemberMci_IDNO, @Lc_MhisIveCur_StatusCase_CODE, @Lc_MhisIveCur_Last_NAME, @Lc_MhisIveCur_First_NAME, @Ln_MhisIveCur_MemberSsn_NUMB, @Ld_MhisIveCur_Birth_DATE, @Ln_MhisIveCur_IveParty_IDNO, @Ln_MhisIveCur_ChildMemberMci_IDNO;

            SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
           END

          CLOSE MhisIve_CUR;
          DEALLOCATE MhisIve_CUR;   
         END
      
      IF @Lc_IveRefCur_FatherInformation_INDC = @Lc_ValueYes_INDC
         BEGIN 
          SET @Ln_IveCase_IDNO = @Lc_IveRefCur_FatherIveCase_IDNO;
          SET @Lc_Sex_CODE = @Lc_SexM_CODE;
          DECLARE MhisIve_CUR INSENSITIVE CURSOR FOR
         SELECT a.Case_IDNO,
                a.CaseWelfare_IDNO,
                c.CaseMemberStatus_CODE,
                c.CaseRelationship_CODE,
                c.MemberMci_IDNO,
                d.StatusCase_CODE,
                b.Last_Name,
                b.First_NAME,
                b.MemberSsn_NUMB,
                b.Birth_DATE,
                b.IveParty_IDNO,
                e.MemberMci_IDNO
           FROM MHIS_Y1 a,
                DEMO_Y1 b,
                CMEM_Y1 c,
                CASE_Y1 d,
                CMEM_Y1 e
          WHERE CaseWelfare_IDNO = @Ln_IveCase_IDNO
            AND a.Case_IDNO = c.Case_IDNO
            AND a.End_DATE = @Ld_High_DATE
            AND a.Case_IDNO = d.Case_IDNO
            AND d.StatusCase_CODE = 'O'
            AND c.CaseMemberStatus_CODE = 'A'
            AND c.CaseRelationship_CODE IN ('A', 'P')
            AND c.MemberMci_IDNO = b.MemberMci_IDNO
            AND b.MemberSex_CODE = @Lc_Sex_CODE
            AND a.Case_IDNO = e.Case_IDNO
            AND a.MemberMci_IDNO = e.MemberMci_IDNO
            AND e.CaseRelationship_CODE = 'D'
            AND e.CaseMemberStatus_CODE = 'A';
            
          SET @Ls_Sql_TEXT = 'OPEN MhisIve RESPONSE CURSOR ';
          SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

		  OPEN MhisIve_CUR;
		  SET @Ls_Sql_TEXT = 'FETCH MhisIve RESPONSE CURSOR ';
          SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;
         
          FETCH NEXT FROM MhisIve_CUR INTO @Ln_MhisIveCur_Case_IDNO, @Ln_MhisIveCur_CaseWelfare_IDNO, @Lc_MhisIveCur_CaseMemberStatus_CODE, @Lc_MhisIveCur_CaseRelationship_CODE, @Ln_MhisIveCur_MemberMci_IDNO, @Lc_MhisIveCur_StatusCase_CODE, @Lc_MhisIveCur_Last_NAME, @Lc_MhisIveCur_First_NAME, @Ln_MhisIveCur_MemberSsn_NUMB, @Ld_MhisIveCur_Birth_DATE, @Ln_MhisIveCur_IveParty_IDNO, @Ln_MhisIveCur_ChildMemberMci_IDNO;
          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        -- Loop through father information for MHIS_Y1  match
          WHILE @Li_FetchStatus_QNTY = 0
           BEGIN
            SET @Lc_FatherLast_NAME = '';
            SET @Lc_FatherFirst_NAME = '';
            SET @Lc_Partial_NAME = '';
            SET @Li_Comma_QNTY = @Ln_Zero_Numb;
            SET @Li_SpaceCount_QNTY = @Ln_Zero_NUMB;

            IF @Lc_IveRefCur_Father_NAME <> ''
                OR @Lc_IveRefCur_Father_NAME IS NOT NULL
             BEGIN
              	SET @Li_Comma_QNTY = CHARINDEX(',', @Lc_IveRefCur_Father_NAME);
				SET @Lc_FatherLast_NAME = LEFT(@Lc_IveRefCur_Father_NAME, @Li_Comma_QNTY - 1);
				SET @Lc_Partial_NAME = SUBSTRING(@Lc_IveRefCur_Father_NAME, @Li_Comma_QNTY + 2, LEN(@Lc_IveRefCur_Father_NAME) - (@Li_Comma_QNTY + 1));
				SET @Li_SpaceCount_QNTY = CHARINDEX(' ', @Lc_IveRefCur_Father_NAME);
				SET @Lc_FatherFirst_NAME = LEFT(@Lc_Partial_NAME, @Li_SpaceCount_QNTY - 1)
             END

            IF LTRIM(RTRIM(@Lc_IveRefCur_FatherPid_IDNO)) <> ''
               AND CAST(@Lc_IveRefCur_FatherPid_IDNO AS NUMERIC) <> @Ln_Zeros_NUMB
               AND @Ln_MhisIveCur_IveParty_IDNO = @Lc_IveRefCur_FatherPid_IDNO
             BEGIN
              IF @Lc_FatherMatch_INDC <> 'Y'
               BEGIN
                SET @Lc_FatherMatch_INDC = 'Y';
               END
              ELSE IF LTRIM(RTRIM(@Lc_IveRefCur_FatherPrimarySsn_NUMB)) <> ''
                 AND CAST(@Lc_IveRefCur_FatherPrimarySsn_NUMB AS NUMERIC) <> @Ln_Zeros_NUMB
                 AND (@Lc_IveRefCur_Father_NAME <> ''
                       OR @Lc_IveRefCur_Father_NAME <> NULL)
                 AND @Ln_MhisIveCur_MemberSsn_NUMB = @Lc_IveRefCur_FatherPrimarySsn_NUMB
                 AND @Lc_MhisIveCur_Last_NAME = @Lc_FatherLast_NAME 
               BEGIN
                IF @Lc_FatherMatch_INDC <> 'Y'
                 BEGIN
                  SET @Lc_FatherMatch_INDC = 'Y';
                 END
                ELSE IF (@Lc_IveRefCur_Father_NAME <> ''
                     OR @Lc_IveRefCur_Father_NAME <> NULL)
                   AND @Lc_IveRefCur_FatherBirth_DATE <> @Ld_Low_DATE
                   AND @Lc_MhisIveCur_Last_NAME = @Lc_FatherLast_NAME 
                   AND @Ld_MhisIveCur_Birth_DATE = @Lc_IveRefCur_FatherBirth_DATE
                 BEGIN
                  IF @Lc_FatherMatch_INDC <> 'Y'
                   BEGIN
                    SET @Lc_FatherMatch_INDC = 'Y';
                   END
                  ELSE IF (@Lc_IveRefCur_Father_NAME <> ''
                       OR @Lc_IveRefCur_Father_NAME <> NULL)
                     AND @Lc_IveRefCur_FatherBirth_DATE <> @Ld_Low_DATE
                     AND @Lc_MhisIveCur_First_NAME = @Lc_FatherFirst_NAME 
                     AND @Ld_MhisIveCur_Birth_DATE = @Lc_IveRefCur_FatherBirth_DATE
                   BEGIN
                    IF @Lc_FatherMatch_INDC <> 'Y'
                     BEGIN
                      SET @Lc_FatherMatch_INDC = 'Y';
                     END
                    ELSE
                    
                    IF @Lc_FatherMatch_INDC <> 'Y'
                     BEGIN
                      SET @Lc_FatherMatch_INDC = 'N';
                     END
                   END
                 END
               END
             END

            IF @Lc_FatherMatch_INDC = 'Y'
             BEGIN
              SET @Ls_Sql_TEXT = 'INSERTING DATA INTO TEMPORARY TABLE #IveFather_Matched_Cases_P1' ;
              SET @Ls_Sqldata_TEXT = 'FATHER_WELFARE_CASE_IDNO = ' + CAST(@Ln_MhisIveCur_CaseWelfare_IDNO AS VARCHAR) + ', FATHER_IVD_CASE_IDNO = ' + CAST(@Ln_MhisIveCur_Case_IDNO AS VARCHAR) ;
              INSERT INTO #IveFather_Matched_Cases_P1
                          (IveFatherCase_IDNO,
                           IvdFatherCase_IDNO,
                           IvdFatherNcpMci_IDNO,
                           IvdFatherChildMci_IDNO,
                           FatherChildMatch_INDC)
                   VALUES (@Ln_MhisIveCur_CaseWelfare_IDNO, --IveFatherCase_IDNO
                           @Ln_MhisIveCur_Case_IDNO, -- IvdFatherCase_IDNO
                           @Ln_MhisIveCur_MemberMci_IDNO, -- IvdFatherNcpMci_IDNO
                           @Ln_MhisIveCur_ChildMemberMci_IDNO, -- IvdFatherChildMci_IDNO
                           @Lc_ValueNo_INDC); -- FatherChildMatch_INDC
             END
            FETCH NEXT FROM MhisIve_CUR INTO @Ln_MhisIveCur_Case_IDNO, @Ln_MhisIveCur_CaseWelfare_IDNO, @Lc_MhisIveCur_CaseMemberStatus_CODE, @Lc_MhisIveCur_CaseRelationship_CODE, @Ln_MhisIveCur_MemberMci_IDNO, @Lc_MhisIveCur_StatusCase_CODE, @Lc_MhisIveCur_Last_NAME, @Lc_MhisIveCur_First_NAME, @Ln_MhisIveCur_MemberSsn_NUMB, @Ld_MhisIveCur_Birth_DATE, @Ln_MhisIveCur_IveParty_IDNO, @Ln_MhisIveCur_ChildMemberMci_IDNO;

			SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
           END
          CLOSE MhisIve_CUR;
          DEALLOCATE MhisIve_CUR; 
         END
 
      -- Check for the children on referral matches with any DECSS matched cases for mother or the farther
      
      SET @Lc_MotherMatch_INDC = 'N';
      SET @Lc_FatherMatch_INDC = 'N';
 
      SET @Ls_Sql_TEXT = 'SELECTING MOTHER MATCHED CASES FROM TEMP TABLE #IveMother_Matched_Cases_P1 ';
      SET @Ls_Sqldata_TEXT = 'MOTHER_WELFARE_CASE_IDNO = ' + CAST(@Ln_MhisIveCur_CaseWelfare_IDNO AS VARCHAR);
      SELECT @Li_MotherMatchedCount_QNTY = COUNT(1)
        FROM #IveMother_Matched_Cases_P1 p;

      IF @Li_MotherMatchedCount_QNTY > 0
       BEGIN
        SET @Lc_MotherMatch_INDC = 'Y';
       END
       
      SET @Ls_Sql_TEXT = 'SELECTING FATHER MATCHED CASES FROM TEMP TABLE #IveFather_Matched_Cases_P1';
      SET @Ls_Sqldata_TEXT = 'FATHER_WELFARE_CASE_IDNO = ' + CAST(@Ln_MhisIveCur_CaseWelfare_IDNO AS VARCHAR);
      SELECT @Li_FatherMatchedCount_QNTY = COUNT(1)
        FROM #IveFather_Matched_Cases_P1 p;

      IF @Li_FatherMatchedCount_QNTY > 0
       BEGIN
        SET @Lc_FatherMatch_INDC = 'Y';
       END

      IF @Lc_MotherMatch_INDC = 'Y' 
      AND @Lc_IveRefCur_MotherInformation_INDC = @Lc_ValueYes_INDC
       BEGIN
        SET @Li_ChildLoopCount_QNTY = 0;
        -- Process children in referral to match with mother case in DECSS
        WHILE @Li_ChildLoopCount_QNTY < 6
         BEGIN
          SET @Li_ChildLoopCount_QNTY = @Li_ChildLoopCount_QNTY + 1;
          SET @Ln_ChildMci_IDNO = 0;
         
          IF @Li_ChildLoopCount_QNTY = 1
           BEGIN
            IF @Lc_IveRefCur_Child1Mci_IDNO <> '' 
             BEGIN
              IF ISNUMERIC (@Lc_IveRefCur_Child1Mci_IDNO) = 1
               BEGIN
                SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child1Mci_IDNO;
               END
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 2
           BEGIN
            IF @Lc_IveRefCur_Child2Mci_IDNO <> '' 
             BEGIN
              IF ISNUMERIC (@Lc_IveRefCur_Child2Mci_IDNO) = 1
               BEGIN
                SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child2Mci_IDNO;
               END
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 3
           BEGIN
            IF @Lc_IveRefCur_Child3Mci_IDNO <> ''  
             BEGIN
              IF ISNUMERIC (@Lc_IveRefCur_Child3Mci_IDNO) = 1
               BEGIN
                SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child3Mci_IDNO;
               END
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 4
           BEGIN
          
            IF @Lc_IveRefCur_Child4Mci_IDNO <> '' 
             BEGIN
            
              IF ISNUMERIC (@Lc_IveRefCur_Child4Mci_IDNO) = 1
               BEGIN
                SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child4Mci_IDNO;
               END
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 5
           BEGIN
            IF @Lc_IveRefCur_Child5Mci_IDNO <> ''  
             BEGIN
              IF ISNUMERIC (@Lc_IveRefCur_Child5Mci_IDNO) = 1
               BEGIN
                SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child5Mci_IDNO;
               END
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 6
           BEGIN
            IF @Lc_IveRefCur_Child6Mci_IDNO <> '' 
             BEGIN
              IF ISNUMERIC (@Lc_IveRefCur_Child1Mci_IDNO) = 1
               BEGIN
                SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child6Mci_IDNO;
               END
             END
           END

          IF @Ln_ChildMci_IDNO <> 0
           BEGIN
            SET @Ls_Sql_TEXT = 'DATA INSERT INTO TEMPORARY TABLE #IveRefTo_Decss_MotherMatch_P1';
            SET @Ls_Sqldata_TEXT = 'CHILD_MCI_IDNO = ' + CAST(@Ln_ChildMci_IDNO AS VARCHAR);
            INSERT INTO #IveRefTo_Decss_MotherMatch_P1
                        (ChildMci_IDNO,
                         Matched_INDC)
                 VALUES (@Ln_ChildMci_IDNO, 
                         @Lc_ValueNo_INDC); 
           END
         END

        DECLARE MtrMatch_CUR INSENSITIVE CURSOR FOR
         SELECT IveMotherCase_IDNO,
                IvdMotherCase_IDNO,
                IvdMotherNcpMci_IDNO,
                IvdMotherChildMci_IDNO
           FROM #IveMother_Matched_Cases_P1 p
          WHERE IveMotherCase_IDNO = @Lc_IveRefCur_MotherIveCase_IDNO;

        SET @Ls_Sql_TEXT = 'OPEN MtrMatch CURSOR ';
        SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

        OPEN MtrMatch_CUR;

        SET @Ls_Sql_TEXT = 'FETCH MtrMatch CURSOR ';
        SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

        FETCH NEXT FROM MtrMatch_CUR INTO @Ln_MtrMatchCur_IveMotherCase_IDNO, @Ln_MtrMatchCur_IvdMotherCase_IDNO, @Ln_MtrMatchCur_IvdMotherNcpMci_IDNO, @Ln_MtrMatchCur_IvdMotherChildMci_IDNO;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        -- Process Mother / child matched data 
        WHILE @Li_FetchStatus_QNTY = 0 
         BEGIN
          SET @Li_MotherLoop_QNTY = @Li_MotherLoop_QNTY + 1;

          SELECT @Li_CmemCount_QNTY = COUNT(1)
            FROM #IveRefTo_Decss_MotherMatch_P1 p
           WHERE ChildMci_IDNO = @Ln_MtrMatchCur_IvdMotherChildMci_IDNO
             AND Matched_INDC = @Lc_ValueNo_INDC;

          IF @Li_CmemCount_QNTY <> 0
           BEGIN
            SET @Ls_Sql_TEXT = 'INSERTING DATA INTO TEMPRARY TABLE #IveRefTo_Decss_MotherMatch_P1';
            SET @Ls_Sqldata_TEXT = 'MOTHERMATCHED_CHILDMCI_IDNO = ' + CAST(@Ln_MtrMatchCur_IvdMotherChildMci_IDNO AS VARCHAR); 
            UPDATE #IveRefTo_Decss_MotherMatch_P1
               SET Matched_INDC = @Lc_ValueYes_INDC
             WHERE ChildMci_IDNO = @Ln_MtrMatchCur_IvdMotherChildMci_IDNO;
           END

          FETCH NEXT FROM MtrMatch_CUR INTO @Ln_MtrMatchCur_IveMotherCase_IDNO, @Ln_MtrMatchCur_IvdMotherCase_IDNO, @Ln_MtrMatchCur_IvdMotherNcpMci_IDNO, @Ln_MtrMatchCur_IvdMotherChildMci_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE MtrMatch_CUR;
        DEALLOCATE MtrMatch_CUR;
        
       SET @Ls_Sql_TEXT = 'SELECT DATA FROM TEMPRARY TABLE #IveRefTo_Decss_MotherMatch_P1';
       SET @Ls_Sqldata_TEXT = 'MOTHER_WELFARE_CASE_IDNO = ' + CAST(@Ln_MhisIveCur_CaseWelfare_IDNO AS VARCHAR);
        SELECT @Ln_MotherChildNoMatch_QNTY = COUNT(1)
          FROM #IveRefTo_Decss_MotherMatch_P1 p
         WHERE Matched_INDC = @Lc_ValueNo_INDC;

        IF @Ln_MotherChildNoMatch_QNTY = 0 --> 0
         BEGIN
          SET @Lc_MotherChildMatch_INDC = @Lc_ValueYes_INDC;
         END
       END
      
      -- Check for the children on referral matches with any DECSS matched cases for mother or the father
      IF @Lc_FatherMatch_INDC = 'Y'
      AND @Lc_IveRefCur_FatherInformation_INDC = @Lc_ValueYes_INDC 
       BEGIN
        
        SET @Li_ChildLoopCount_QNTY = 0;
        -- process to match children in referral with mother case in DECSS
        WHILE @Li_ChildLoopCount_QNTY < 6
         BEGIN
         
          SET @Li_ChildLoopCount_QNTY = @Li_ChildLoopCount_QNTY + 1;
          SET @Ln_ChildMci_IDNO = 0;

          IF @Li_ChildLoopCount_QNTY = 1
           BEGIN
            IF ISNUMERIC (@Lc_IveRefCur_Child1Mci_IDNO) = 1
             BEGIN
              SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child1Mci_IDNO;
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 2
           BEGIN
            IF ISNUMERIC (@Lc_IveRefCur_Child2Mci_IDNO) = 1
             BEGIN
              SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child2Mci_IDNO;
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 3
           BEGIN
            IF ISNUMERIC (@Lc_IveRefCur_Child3Mci_IDNO) = 1
             BEGIN
              SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child3Mci_IDNO;
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 4
           BEGIN
            IF ISNUMERIC (@Lc_IveRefCur_Child4Mci_IDNO) = 1
             BEGIN
              SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child4Mci_IDNO;
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 5
           BEGIN
            IF ISNUMERIC (@Lc_IveRefCur_Child5Mci_IDNO) = 1
             BEGIN
              SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child5Mci_IDNO;
             END
           END
          ELSE IF @Li_ChildLoopCount_QNTY = 6
           BEGIN
            IF ISNUMERIC (@Lc_IveRefCur_Child6Mci_IDNO) = 1
             BEGIN
              SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child6Mci_IDNO;
             END
           END

          IF @Ln_ChildMci_IDNO <> 0
           BEGIN
            SET @Ls_Sql_TEXT = 'DATA INSERT INTO TEMPORARY TABLE #IveRefTo_Decss_MotherMatch_P1';
            SET @Ls_Sqldata_TEXT = 'CHILD_MCI_IDNO = ' + CAST(@Ln_ChildMci_IDNO AS VARCHAR);
            INSERT INTO #IveRefTo_Decss_FatherMatch_P1
                        (ChildMci_IDNO,
                         Matched_INDC)
                 VALUES (@Ln_ChildMci_IDNO, 
                         @Lc_ValueNo_INDC); 
           END
         END

        DECLARE FtrMatch_CUR INSENSITIVE CURSOR FOR
         SELECT IveFatherCase_IDNO,
                IvdFatherCase_IDNO,
                IvdFatherNcpMci_IDNO,
                IvdFatherChildMci_IDNO
           FROM #IveFather_Matched_Cases_P1 p
          WHERE IveFatherCase_IDNO = @Lc_IveRefCur_FatherIveCase_IDNO;

        SET @Ls_Sql_TEXT = 'OPEN MtrMatch CURSOR ';
        SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

        OPEN FtrMatch_CUR;

        SET @Ls_Sql_TEXT = 'FETCH MtrMatch CURSOR ';
        SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

        FETCH NEXT FROM FtrMatch_CUR INTO @Ln_FtrMatchCur_IveFatherCase_IDNO, @Ln_FtrMatchCur_IvdFatherCase_IDNO, @Ln_FtrMatchCur_IvdFatherNcpMci_IDNO, @Ln_FtrMatchCur_IvdFatherChildMci_IDNO;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        -- Process father matched cases
        WHILE @Li_FetchStatus_QNTY = 0
         BEGIN
          SET @Li_FatherLoop_QNTY = @Li_FatherLoop_QNTY + 1;

          SELECT @Li_CmemCount_QNTY = COUNT(1)
            FROM #IveRefTo_Decss_FatherMatch_P1 p
           WHERE ChildMci_IDNO = @Ln_FtrMatchCur_IvdFatherChildMci_IDNO
             AND Matched_INDC = @Lc_ValueNo_INDC;

          IF @Li_CmemCount_QNTY <> 0
           BEGIN
            SET @Ls_Sql_TEXT = 'UPDATING THE TABLE #IveRefTo_Decss_FatherMatch_P1 ';
            SET @Ls_Sqldata_TEXT = 'FATHERMATCH_CHILDMCI_IDNO = ' + CAST(@Ln_FtrMatchCur_IvdFatherChildMci_IDNO AS VARCHAR);
            UPDATE #IveRefTo_Decss_FatherMatch_P1
               SET Matched_INDC = @Lc_ValueYes_INDC
             WHERE ChildMci_IDNO = @Ln_FtrMatchCur_IvdFatherChildMci_IDNO;
           END

          -- Process Father's cases for matching with the kids on the DECSS with the referral
          FETCH NEXT FROM FtrMatch_CUR INTO @Ln_FtrMatchCur_IveFatherCase_IDNO, @Ln_FtrMatchCur_IvdFatherCase_IDNO, @Ln_FtrMatchCur_IvdFatherNcpMci_IDNO, @Ln_FtrMatchCur_IvdFatherChildMci_IDNO;

          SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
         END

        CLOSE FtrMatch_CUR;
        DEALLOCATE FtrMatch_CUR;
        
       SET @Ls_Sql_TEXT = 'SELECT DATA FROM TEMPRARY TABLE ##IveRefTo_Decss_FatherMatch_P1';
       SET @Ls_Sqldata_TEXT = 'FATHER_WELFARE_CASE_IDNO = ' + ISNULL(@Lc_IveRefCur_FatherIveCase_IDNO, 0);
        SELECT @Ln_FatherChildNoMatch_QNTY = COUNT(1)
          FROM #IveRefTo_Decss_FatherMatch_P1 p
         WHERE Matched_INDC = @Lc_ValueNo_INDC;

        IF @Ln_FatherChildNoMatch_QNTY = 0 --> 0
         BEGIN
          SET @Lc_FatherChildMatch_INDC = @Lc_ValueYes_INDC;
         END
       END
      
      IF @Lc_MotherChildMatch_INDC = 'Y'
       BEGIN
        SET @Lc_MotherCreateApplication_INDC = @Lc_ValueNo_INDC;
       END
      ELSE
       BEGIN
        -- Check any pending applications exists for the mother. If pending applications exists, replace the applications
        -- If no pending applications exists, create the new application
        IF @Lc_IveRefCur_MotherInformation_INDC = @Lc_ValueYes_INDC
         BEGIN
          SET @Ln_MotherApplication_IDNO = @Ln_Zero_NUMB;
          SET @Lc_MotherUpdateApplication_INDC = @Lc_ValueNo_INDC;

          SET @Ls_Sql_TEXT = 'SELECT PENDING APPLICATION FROM APCS_Y1 TABLE ';
          SET @Ls_Sqldata_TEXT = 'MOTHER_IVECASE_IDNO = ' + ISNULL(@Lc_IveRefCur_MotherIveCase_IDNO, 0);
          SELECT @Ln_MotherApplication_IDNO = a.Application_IDNO
           FROM APCS_Y1 a,
               APDM_Y1 b
           WHERE a.CaseWelfare_IDNO = @Lc_IveRefCur_MotherIveCase_IDNO
             AND a.Application_IDNO = b.Application_IDNO
             AND a.EndValidity_DATE = @Ld_High_DATE
             AND a.ApplicationStatus_CODE = @Lc_ApplicationStatus_CODE
             AND b.IveParty_IDNO = @Lc_IveRefCur_MotherPid_IDNO;
        
          IF @Ln_MotherApplication_IDNO <> @Ln_Zero_NUMB
           AND CAST(@Lc_IveRefCur_MotherPid_IDNO AS NUMERIC) <> @Ln_Zero_NUMB
           BEGIN
          --Check mother date of death is populated and delete the existing application
            IF @Lc_MotherDeathDate_INDC = @Lc_ValueYes_INDC
             BEGIN
              SET @Lc_MotherUpdateApplication_INDC = @Lc_ValueNo_INDC;
              SET @Ls_Sql_TEXT = 'APCS TABLE READ FOR PENDING MOTHER APPLICATION';
              SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

              SELECT @Li_SelectStatus_QNTY = COUNT(1)
               FROM APCS_Y1 a
              WHERE Application_IDNO = @Ln_MotherApplication_IDNO;

              IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
               BEGIN
                SET @Ls_Sql_TEXT = 'APCS TABLE UPDATE FOR PENDING MOTHER APPLICATION';
                SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

                UPDATE APCS_Y1
                 SET EndValidity_DATE = @Ld_Run_DATE
                WHERE Application_IDNO = @Ln_MotherApplication_IDNO;
               END
             END
            ELSE
             BEGIN
              -- compare all the children on the referral are matching with the pending application, Then update the pending application
              -- If all the children in the incoming referral are not matching with the pending application, then do not update the existing application
              -- and create a new application for this referral
              INSERT INTO #IveRefTo_Decss_PendingappsMatch_P1
              SELECT MemberMci_IDNO,IveParty_IDNO, 'N', 'N'
                FROM APDM_Y1 
                WHERE Application_IDNO = @Ln_MotherApplication_IDNO
                  AND EndValidity_DATE = @Ld_High_DATE
                  AND EXISTS (SELECT 1 FROM APCM_Y1 WHERE Application_IDNO = @Ln_MotherApplication_IDNO
                                                      AND EndValidity_DATE = @Ld_High_DATE
                                                      AND CaseRelationship_CODE = 'D');
                                                      
              SET @Li_ChildLoopCount_QNTY = 0;
              SET @Li_ChildFileCount_QNTY = 0;
               WHILE @Li_ChildLoopCount_QNTY < 6
                BEGIN
                 SET @Li_ChildLoopCount_QNTY = @Li_ChildLoopCount_QNTY + 1;
				 SET @Ln_ChildMci_IDNO = 0;
				 SET @Ln_ChildPid_IDNO = 0;
				 IF @Li_ChildLoopCount_QNTY = 1
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child1Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child1Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child1Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child1Pid_IDNO;
                    END
				  END
				 ELSE IF @Li_ChildLoopCount_QNTY = 2 
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child2Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child2Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child2Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child2Pid_IDNO;
                    END
				  END
				 ELSE IF @Li_ChildLoopCount_QNTY = 3
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child3Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child3Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child3Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child3Pid_IDNO;
                    END
				  END
				 ELSE IF @Li_ChildLoopCount_QNTY = 4
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child4Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child4Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child4Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child4Pid_IDNO;
                    END
				  END 
				 ELSE IF @Li_ChildLoopCount_QNTY = 5
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child5Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child5Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child5Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child5Pid_IDNO;
                    END
				  END 
				 ELSE IF @Li_ChildLoopCount_QNTY = 6
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child5Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child5Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child5Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child5Pid_IDNO;
                    END
				  END
				 IF @Ln_ChildMci_IDNO <> 0
				 AND @Ln_ChildPid_IDNO <> 0
				  BEGIN
				   SET @Li_ChildFileCount_QNTY = @Li_ChildFileCount_QNTY + 1 ;
				   SELECT @Li_Count_QNTY = COUNT(1)
				     FROM #IveRefTo_Decss_PendingappsMatch_P1
				     WHERE ChildMci_IDNO = @Ln_ChildMci_IDNO
				      AND ChildPid_IDNO = @Ln_ChildPid_IDNO
				   IF @Li_Count_QNTY <> 0
				    BEGIN   
					 UPDATE #IveRefTo_Decss_PendingappsMatch_P1
				     SET MotherMatch_INDC = 'Y'
				     WHERE ChildMci_IDNO = @Ln_ChildMci_IDNO
				      AND ChildPid_IDNO = @Ln_ChildPid_IDNO
				    END
				  END
				END
              SELECT @Li_ChildTableCount_QNTY = COUNT(1)
                FROM #IveRefTo_Decss_PendingappsMatch_P1
                WHERE MotherMatch_indc = 'Y'
              IF @Li_ChildTableCount_QNTY =  @Li_ChildFileCount_QNTY 
               BEGIN 
                SET @Lc_MotherUpdateApplication_INDC = @Lc_ValueYes_INDC;
               END
              ELSE
               BEGIN
                SET @Ln_MotherApplication_IDNO = 0;
                SET @Lc_MotherCreateApplication_INDC = @Lc_ValueYes_INDC;
               END  
             END
           END
          ELSE
           BEGIN
            SET @Lc_MotherCreateApplication_INDC = @Lc_ValueYes_INDC;
            IF CAST(@Lc_IveRefCur_MotherPid_IDNO AS NUMERIC) = @Ln_Zero_NUMB
             BEGIN
              SET @Ln_MotherApplication_IDNO = 0;
             END
           END
         END
        ELSE
         BEGIN 
          SET @Lc_UiMotherCreateApplication_INDC = @Lc_ValueYes_INDC
         END     
       END

      -- Delete the rows created in mother match
      
      SET @Ls_Sql_TEXT = 'DELETE THE DATA FROM THE TEMPORARY TABLE #IveRefTo_Decss_PendingappsMatch_P1';
      SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;
      DELETE FROM #IveRefTo_Decss_PendingappsMatch_P1
      
      IF @Lc_FatherChildMatch_INDC = 'Y'
       BEGIN
        -- Ignore the father part of the application
        SET @Lc_FatherCreateApplication_INDC = @Lc_ValueNo_INDC;
       END
      ELSE
       BEGIN
        -- Check any pending applications exists for the father. If pending applications exists, replace the applications
        -- If no pending applications exists, create the new application
        IF @Lc_IveRefCur_FatherInformation_INDC = @Lc_ValueYes_INDC
         BEGIN
          SET @Ln_FatherApplication_IDNO = @Ln_Zero_NUMB;
          SET @Lc_FatherUpdateApplication_INDC = @Lc_ValueNo_INDC;

          SET @Ls_Sql_TEXT = 'SELECT PENDING APPLICATION FROM APCS_Y1 TABLE ';
          SET @Ls_Sqldata_TEXT = 'MOTHER_IVECASE_IDNO = ' + ISNULL(@Lc_IveRefCur_FatherIveCase_IDNO, 0);
          SELECT @Ln_FatherApplication_IDNO = a.Application_IDNO
            FROM APCS_Y1 a,
               APDM_Y1 b
           WHERE a.CaseWelfare_IDNO = @Lc_IveRefCur_FatherIveCase_IDNO
           AND a.Application_IDNO = b.Application_IDNO
           AND a.EndValidity_DATE = @Ld_High_DATE
           AND a.ApplicationStatus_CODE = @Lc_ApplicationStatus_CODE
           AND b.IveParty_IDNO = @Lc_IveRefCur_FatherPid_IDNO;
        
         IF @Ln_FatherApplication_IDNO <> @Ln_Zero_NUMB
           AND CAST(@Lc_IveRefCur_FatherPid_IDNO AS NUMERIC) <> @Ln_Zero_NUMB
          BEGIN
          --Check Father date of death is populated and delete the existing application
           IF @Lc_FatherDeathDate_INDC = @Lc_ValueYes_INDC
            BEGIN
             SET @Lc_FatherUpdateApplication_INDC = @Lc_ValueNo_INDC;
             SET @Ls_Sql_TEXT = 'APCS TABLE READ FOR PENDING FATHER APPLICATION';
             SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

             SELECT @Li_SelectStatus_QNTY = COUNT(1)
              FROM APCS_Y1 a
             WHERE Application_IDNO = @Ln_FatherApplication_IDNO;

             IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
              BEGIN
               SET @Ls_Sql_TEXT = 'APCS TABLE UPDATE FOR PENDING FATHER APPLICATION';
               SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

               UPDATE APCS_Y1
                 SET EndValidity_DATE = @Ld_Run_DATE
               WHERE Application_IDNO = @Ln_FatherApplication_IDNO;
              END
            END
           ELSE
            --BEGIN
             BEGIN
              -- compare all the children on the referral are matching with the pending application, Then update the pending application
              -- If all the children in the incoming referral are not matching with the pending application, then do not update the existing application
              -- and create a new application for this referral
              INSERT INTO #IveRefTo_Decss_PendingappsMatch_P1
              SELECT MemberMci_IDNO,IveParty_IDNO, 'N', 'N'
                FROM APDM_Y1 
                WHERE Application_IDNO = @Ln_FatherApplication_IDNO
                  AND EndValidity_DATE = @Ld_High_DATE
                  AND EXISTS (SELECT 1 FROM APCM_Y1 WHERE Application_IDNO = @Ln_FatherApplication_IDNO
                                                      AND EndValidity_DATE = @Ld_High_DATE
                                                      AND CaseRelationship_CODE = 'D');
                                                      
              SET @Li_ChildLoopCount_QNTY = 0;
              SET @Li_ChildFileCount_QNTY = 0;
               WHILE @Li_ChildLoopCount_QNTY < 6
                BEGIN
                 SET @Li_ChildLoopCount_QNTY = @Li_ChildLoopCount_QNTY + 1;
				 SET @Ln_ChildMci_IDNO = 0;
				 SET @Ln_ChildPid_IDNO = 0;
				 IF @Li_ChildLoopCount_QNTY = 1
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child1Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child1Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child1Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child1Pid_IDNO;
                    END
				  END
				 ELSE IF @Li_ChildLoopCount_QNTY = 2 
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child2Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child2Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child2Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child2Pid_IDNO;
                    END
				  END
				 ELSE IF @Li_ChildLoopCount_QNTY = 3
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child3Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child3Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child3Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child3Pid_IDNO;
                    END
				  END
				 ELSE IF @Li_ChildLoopCount_QNTY = 4
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child4Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child4Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child4Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child4Pid_IDNO;
                    END
				  END 
				 ELSE IF @Li_ChildLoopCount_QNTY = 5
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child5Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child5Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child5Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child5Pid_IDNO;
                    END
				  END 
				 ELSE IF @Li_ChildLoopCount_QNTY = 6
				  BEGIN
				   IF ISNUMERIC (@Lc_IveRefCur_Child5Mci_IDNO) = 1
					BEGIN
					 SET @Ln_ChildMci_IDNO = @Lc_IveRefCur_Child5Mci_IDNO;
                    END
                   IF ISNUMERIC (@Lc_IveRefCur_Child5Pid_IDNO) = 1
                    BEGIN
                     SET @Ln_ChildPid_IDNO = @Lc_IveRefCur_Child5Pid_IDNO;
                    END
				  END
				 IF @Ln_ChildMci_IDNO <> 0
				 AND @Ln_ChildPid_IDNO <> 0
				  BEGIN
				   SET @Li_ChildFileCount_QNTY = @Li_ChildFileCount_QNTY + 1 ;
				   SELECT @Li_Count_QNTY = COUNT(1)
				     FROM #IveRefTo_Decss_PendingappsMatch_P1
				     WHERE ChildMci_IDNO = @Ln_ChildMci_IDNO
				      AND ChildPid_IDNO = @Ln_ChildPid_IDNO
				   IF @Li_Count_QNTY <> 0
				    BEGIN   
					 UPDATE #IveRefTo_Decss_PendingappsMatch_P1
				     SET FatherMatch_INDC = 'Y'
				     WHERE ChildMci_IDNO = @Ln_ChildMci_IDNO
				      AND ChildPid_IDNO = @Ln_ChildPid_IDNO
				    END
				  END
				END
              SELECT @Li_ChildTableCount_QNTY = COUNT(1)
                FROM #IveRefTo_Decss_PendingappsMatch_P1
                WHERE FatherMatch_INDC = 'Y'
              IF @Li_ChildTableCount_QNTY =  @Li_ChildFileCount_QNTY 
               BEGIN 
                SET @Lc_FatherUpdateApplication_INDC = @Lc_ValueYes_INDC;
               END
              ELSE
               BEGIN
                SET @Ln_FatherApplication_IDNO = 0;
                SET @Lc_FatherCreateApplication_INDC = @Lc_ValueYes_INDC;
               END  
             END
           END
         ELSE
          BEGIN
           SET @Lc_FatherCreateApplication_INDC = @Lc_ValueYes_INDC;
           IF CAST(@Lc_IveRefCur_FatherPid_IDNO AS NUMERIC) = @Ln_Zero_NUMB
            BEGIN
             SET @Ln_FatherApplication_IDNO = 0;
            END 
          END
         END
        ELSE
         BEGIN 
          SET @Lc_UiFatherCreateApplication_INDC = @Lc_ValueYes_INDC
         END    
       END

      -- If pending application for mother exists, update mother application records end validity date with the current date
      IF @Lc_MotherUpdateApplication_INDC = @Lc_ValueYes_INDC
         AND @Lc_MotherDeathDate_INDC = @Lc_ValueNo_INDC
       BEGIN
        SET @Ls_Sql_TEXT = 'APCS TABLE READ FOR PENDING MOTHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APCS_Y1 a
         WHERE Application_IDNO = @Ln_MotherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APCS TABLE UPDATE FOR PENDING MOTHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

          UPDATE APCS_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_MotherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APCM TABLE READ FOR PENDING MOTHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APCM_Y1 a
         WHERE Application_IDNO = @Ln_MotherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APCM TABLE UPDATE FOR PENDING MOTHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

          UPDATE APCM_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_MotherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APDM TABLE READ FOR PENDING MOTHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APDM_Y1 a
         WHERE Application_IDNO = @Ln_MotherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APDM TABLE UPDATE FOR PENDING MOTHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

          UPDATE APDM_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_MotherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APMH TABLE READ FOR PENDING MOTHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APMH_Y1 a
         WHERE Application_IDNO = @Ln_MotherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APMH TABLE UPDATE FOR PENDING MOTHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

          UPDATE APMH_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_MotherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APAH TABLE READ FOR PENDING MOTHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APAH_Y1 a
         WHERE Application_IDNO = @Ln_MotherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APAH TABLE UPDATE FOR PENDING MOTHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

          UPDATE APAH_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_MotherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APEH TABLE READ FOR PENDING MOTHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APEH_Y1 a
         WHERE Application_IDNO = @Ln_MotherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APEH TABLE UPDATE FOR PENDING MOTHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_MotherApplication_IDNO AS VARCHAR);

          UPDATE APEH_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_MotherApplication_IDNO;
         END
       END

      -- If pending application for father exists, update father application records end validity date with current date
      IF @Lc_FatherUpdateApplication_INDC = @Lc_ValueYes_INDC
         AND @Lc_FatherDeathDate_INDC = @Lc_ValueNo_INDC
       BEGIN
        SET @Ls_Sql_TEXT = 'APCS TABLE READ FOR PENDING FATHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APCS_Y1 a
         WHERE Application_IDNO = @Ln_FatherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APCS TABLE UPDATE FOR PENDING FATHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

          UPDATE APCS_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_FatherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APCM TABLE READ FOR PENDING FATHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APCM_Y1 a
         WHERE Application_IDNO = @Ln_FatherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APCM TABLE UPDATE FOR PENDING FATHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

          UPDATE APCM_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_FatherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APDM TABLE READ FOR PENDING FATHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APDM_Y1 a
         WHERE Application_IDNO = @Ln_FatherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APDM TABLE UPDATE FOR PENDING FATHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

          UPDATE APDM_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_FatherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APMH TABLE READ FOR PENDING FATHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APMH_Y1 a
         WHERE Application_IDNO = @Ln_FatherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APMH TABLE UPDATE FOR PENDING FATHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

          UPDATE APMH_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_FatherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APAH TABLE READ FOR PENDING FATHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APAH_Y1 a
         WHERE Application_IDNO = @Ln_FatherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APAH TABLE UPDATE FOR PENDING FATHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

          UPDATE APAH_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_FatherApplication_IDNO;
         END

        SET @Ls_Sql_TEXT = 'APEH TABLE READ FOR PENDING FATHER APPLICATION';
        SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

        SELECT @Li_SelectStatus_QNTY = COUNT(1)
          FROM APEH_Y1 a
         WHERE Application_IDNO = @Ln_FatherApplication_IDNO;

        IF @Li_SelectStatus_QNTY <> @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'APEH TABLE UPDATE FOR PENDING FATHER APPLICATION';
          SET @Ls_Sqldata_TEXT = ' Application ID = ' + CAST(@Ln_FatherApplication_IDNO AS VARCHAR);

          UPDATE APEH_Y1
             SET EndValidity_DATE = @Ld_Run_DATE
           WHERE Application_IDNO = @Ln_FatherApplication_IDNO;
         END
       END
    
      --Get the Foster care agency address information for adding to the application tables 
      SET @Ls_Sql_TEXT = 'SELECTING DEMOGRAPHIC INFORMATION FOR DFS AS CLIENT MCI ';
      SET @Ls_Sqldata_TEXT = 'DFS_MEMBERMCI_IDNO = ' + CAST(@Ln_MemberMciDfs_IDNO AS VARCHAR);
      SELECT @Ln_MemberMci_IDNO = a.MemberMci_IDNO,
             @Lc_Race_CODE = a.Race_CODE,
             @Lc_First_NAME = a.First_NAME,
             @Lc_Last_NAME = a.Last_NAME,
             @Lc_Middle_NAME = a.Middle_NAME,
             @Lc_Suffix_NAME = a.Suffix_NAME,
             @Lc_MemberSex_CODE = a.MemberSex_CODE,
             @Ln_MemberSsn_NUMB = a.MemberSsn_NUMB,
             @Ld_DfsBirth_DATE = a.Birth_DATE,
             @Lc_TypeAddress_CODE = b.TypeAddress_CODE,
             @Ls_Line1_ADDR = b.Line1_ADDR,
             @Ls_Line2_ADDR = b.Line1_ADDR,
             @Lc_City_ADDR = b.City_ADDR,
             @Lc_State_ADDR = b.State_ADDR,
             @Lc_Zip_ADDR = b.Zip_ADDR,
             @Lc_Attn_ADDR = b.Attn_ADDR,
             @Lc_Normalization_CODE = b.Normalization_CODE
        FROM DEMO_Y1 a
             LEFT OUTER JOIN AHIS_Y1 b
              ON a.MemberMci_IDNO = b.MemberMci_IDNO
       WHERE a.MemberMci_IDNO = @Ln_MemberMciDfs_IDNO;
     
      -- Generate the transaction sequence number for creating application or updating the existing application
      IF (@Lc_MotherCreateApplication_INDC = 'Y'
           OR @Lc_MotherUpdateApplication_INDC = 'Y'
           OR @Lc_UiMotherCreateApplication_INDC = 'Y'
           OR @Lc_FatherCreateApplication_INDC = 'Y'
           OR @Lc_FatherUpdateApplication_INDC = 'Y'
           OR @Lc_UiFatherCreateApplication_INDC = 'Y')
         AND (@Lc_MotherDeathDate_INDC = 'N'
               OR @Lc_FatherDeathDate_INDC = 'N')
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
        SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

        EXEC BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
         @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
         @Ac_Process_ID               = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
         @Ac_Note_INDC                = @Lc_IndNote_TEXT,
         @An_EventFunctionalSeq_NUMB  = 0,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
       END
     
      IF @Lc_IveRefCur_ApplicationCounty_IDNO = @Lc_KentCounty_CODE
       BEGIN
        SET @Ln_County_IDNO = @Ln_KentCounty_IDNO;
       END
      ELSE IF @Lc_IveRefCur_ApplicationCounty_IDNO = @Lc_NewCastleCounty_CODE
       BEGIN
        SET @Ln_County_IDNO = @Ln_NewCastleCounty_IDNO;
       END
      ELSE IF @Lc_IveRefCur_ApplicationCounty_IDNO = @Lc_SussexCounty_CODE
       BEGIN
        SET @Ln_County_IDNO = @Ln_SussexCounty_IDNO;
       END

      --CHILD 1 NUMERIC CHECK 	
      IF @Lc_IveRefCur_Child1Mci_IDNO <> ' '
          OR @Lc_IveRefCur_Child1Mci_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child1Mci_IDNO) = 1
         BEGIN
          SET @Ln_Child1Mci_IDNO = @Lc_IveRefCur_Child1Mci_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child1Mci_IDNO = 0;
         
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child1Mci_IDNO = 0;
       
       END

      IF @Lc_IveRefCur_Child1Ssn_NUMB <> ''
          OR @Lc_IveRefCur_Child1Ssn_NUMB IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child1Ssn_NUMB) = 1
         BEGIN
          SET @Ln_Child1PrimarySsn_NUMB = @Lc_IveRefCur_Child1Ssn_NUMB;
         END
        ELSE
         BEGIN
          SET @Ln_Child1PrimarySsn_NUMB = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child1PrimarySsn_NUMB = 0;
       END

      IF @Lc_IveRefCur_Child1Pid_IDNO <> ''
          OR @Lc_IveRefCur_Child1Pid_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child1Pid_IDNO) = 1
         BEGIN
          SET @Ln_Child1Pid_IDNO = @Lc_IveRefCur_Child1Pid_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child1Pid_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child1Pid_IDNO = 0;
       END

      IF @Lc_IveRefCur_Child1IveCase_IDNO <> ''
          OR @Lc_IveRefCur_Child1IveCase_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child1IveCase_IDNO) = 1
         BEGIN
          SET @Ln_Child1CaseWelfare_IDNO = @Lc_IveRefCur_Child1IveCase_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child1CaseWelfare_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child1CaseWelfare_IDNO = 0;
       END

      -- CHILD 2 NUMERIC VALUE CHECK 
      IF @Lc_IveRefCur_Child2Mci_IDNO <> ' '
          OR @Lc_IveRefCur_Child2Mci_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child2Mci_IDNO) = 1
         BEGIN
          SET @Ln_Child2Mci_IDNO = @Lc_IveRefCur_Child2Mci_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child2Mci_IDNO = 0;
         
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child2Mci_IDNO = 0;
       
       END

      IF @Lc_IveRefCur_Child2Ssn_NUMB <> ''
          OR @Lc_IveRefCur_Child2Ssn_NUMB IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child2Ssn_NUMB) = 1
         BEGIN
          SET @Ln_Child2PrimarySsn_NUMB = @Lc_IveRefCur_Child2Ssn_NUMB;
         END
        ELSE
         BEGIN
          SET @Ln_Child2PrimarySsn_NUMB = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child2PrimarySsn_NUMB = 0;
       END

      IF @Lc_IveRefCur_Child2Pid_IDNO <> ''
          OR @Lc_IveRefCur_Child2Pid_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child2Pid_IDNO) = 1
         BEGIN
          SET @Ln_Child2Pid_IDNO = @Lc_IveRefCur_Child2Pid_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child2Pid_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child1Pid_IDNO = 0;
       END

      IF @Lc_IveRefCur_Child2IveCase_IDNO <> ''
          OR @Lc_IveRefCur_Child2IveCase_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child2IveCase_IDNO) = 1
         BEGIN
          SET @Ln_Child2CaseWelfare_IDNO = @Lc_IveRefCur_Child2IveCase_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child2CaseWelfare_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child2CaseWelfare_IDNO = 0;
       END

      -- CHILD 3 NUMERIC VALUE CHECK 
      IF @Lc_IveRefCur_Child3Mci_IDNO <> ' '
          OR @Lc_IveRefCur_Child3Mci_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child3Mci_IDNO) = 1
         BEGIN
          SET @Ln_Child3Mci_IDNO = @Lc_IveRefCur_Child3Mci_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child3Mci_IDNO = 0;
         
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child3Mci_IDNO = 0;
       
       END

      IF @Lc_IveRefCur_Child3Ssn_NUMB <> ''
          OR @Lc_IveRefCur_Child3Ssn_NUMB IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child3Ssn_NUMB) = 1
         BEGIN
          SET @Ln_Child3PrimarySsn_NUMB = @Lc_IveRefCur_Child3Ssn_NUMB;
         END
        ELSE
         BEGIN
          SET @Ln_Child3PrimarySsn_NUMB = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child3PrimarySsn_NUMB = 0;
       END

      IF @Lc_IveRefCur_Child3Pid_IDNO <> ''
          OR @Lc_IveRefCur_Child3Pid_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child3Pid_IDNO) = 1
         BEGIN
          SET @Ln_Child3Pid_IDNO = @Lc_IveRefCur_Child3Pid_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child3Pid_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child3Pid_IDNO = 0;
       END

      IF @Lc_IveRefCur_Child3IveCase_IDNO <> ''
          OR @Lc_IveRefCur_Child3IveCase_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child3IveCase_IDNO) = 1
         BEGIN
          SET @Ln_Child3CaseWelfare_IDNO = @Lc_IveRefCur_Child3IveCase_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child3CaseWelfare_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child3CaseWelfare_IDNO = 0;
       END

      --CHILD 4 NUMERIC VALUE CHECK 
      IF @Lc_IveRefCur_Child4Mci_IDNO <> ' '
          OR @Lc_IveRefCur_Child4Mci_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child4Mci_IDNO) = 1
         BEGIN
          SET @Ln_Child4Mci_IDNO = @Lc_IveRefCur_Child4Mci_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child4Mci_IDNO = 0;
         
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child4Mci_IDNO = 0;
       
       END

      IF @Lc_IveRefCur_Child4Ssn_NUMB <> ''
          OR @Lc_IveRefCur_Child4Ssn_NUMB IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child4Ssn_NUMB) = 1
         BEGIN
          SET @Ln_Child4PrimarySsn_NUMB = @Lc_IveRefCur_Child4Ssn_NUMB;
         END
        ELSE
         BEGIN
          SET @Ln_Child4PrimarySsn_NUMB = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child4PrimarySsn_NUMB = 0;
       END

      IF @Lc_IveRefCur_Child4Pid_IDNO <> ''
          OR @Lc_IveRefCur_Child4Pid_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child4Pid_IDNO) = 1
         BEGIN
          SET @Ln_Child4Pid_IDNO = @Lc_IveRefCur_Child4Pid_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child4Pid_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child4Pid_IDNO = 0;
       END

      IF @Lc_IveRefCur_Child4IveCase_IDNO <> ''
          OR @Lc_IveRefCur_Child4IveCase_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child4IveCase_IDNO) = 1
         BEGIN
          SET @Ln_Child4CaseWelfare_IDNO = @Lc_IveRefCur_Child4IveCase_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child4CaseWelfare_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child4CaseWelfare_IDNO = 0;
       END

      -- CHILD 5 NUMERIC VALUE CHECK 
      IF @Lc_IveRefCur_Child5Mci_IDNO <> ' '
          OR @Lc_IveRefCur_Child5Mci_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child5Mci_IDNO) = 1
         BEGIN
          SET @Ln_Child5Mci_IDNO = @Lc_IveRefCur_Child5Mci_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child5Mci_IDNO = 0;
         
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child5Mci_IDNO = 0;
       
       END

      IF @Lc_IveRefCur_Child5Ssn_NUMB <> ''
          OR @Lc_IveRefCur_Child5Ssn_NUMB IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child5Ssn_NUMB) = 1
         BEGIN
          SET @Ln_Child5PrimarySsn_NUMB = @Lc_IveRefCur_Child5Ssn_NUMB;
         END
        ELSE
         BEGIN
          SET @Ln_Child5PrimarySsn_NUMB = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child5PrimarySsn_NUMB = 0;
       END

      IF @Lc_IveRefCur_Child5Pid_IDNO <> ''
          OR @Lc_IveRefCur_Child5Pid_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child5Pid_IDNO) = 1
         BEGIN
          SET @Ln_Child5Pid_IDNO = @Lc_IveRefCur_Child5Pid_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child5Pid_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child5Pid_IDNO = 0;
       END

      IF @Lc_IveRefCur_Child5IveCase_IDNO <> ''
          OR @Lc_IveRefCur_Child5IveCase_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child5IveCase_IDNO) = 1
         BEGIN
          SET @Ln_Child5CaseWelfare_IDNO = @Lc_IveRefCur_Child5IveCase_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child5CaseWelfare_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child5CaseWelfare_IDNO = 0;
       END

      -- CHILD 6 NUMERIC VALUE CHECK
      IF @Lc_IveRefCur_Child6Mci_IDNO <> ' '
          OR @Lc_IveRefCur_Child6Mci_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child6Mci_IDNO) = 1
         BEGIN
          SET @Ln_Child6Mci_IDNO = @Lc_IveRefCur_Child6Mci_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child6Mci_IDNO = 0;
         
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child6Mci_IDNO = 0;
       
       END

      IF @Lc_IveRefCur_Child6Ssn_NUMB <> ''
          OR @Lc_IveRefCur_Child6Ssn_NUMB IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child6Ssn_NUMB) = 1
         BEGIN
          SET @Ln_Child6PrimarySsn_NUMB = @Lc_IveRefCur_Child6Ssn_NUMB;
         END
        ELSE
         BEGIN
          SET @Ln_Child6PrimarySsn_NUMB = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child6PrimarySsn_NUMB = 0;
       END

      IF @Lc_IveRefCur_Child6Pid_IDNO <> ''
          OR @Lc_IveRefCur_Child6Pid_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child6Pid_IDNO) = 1
         BEGIN
          SET @Ln_Child6Pid_IDNO = @Lc_IveRefCur_Child6Pid_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child6Pid_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child6Pid_IDNO = 0;
       END

      IF @Lc_IveRefCur_Child6IveCase_IDNO <> ''
          OR @Lc_IveRefCur_Child6IveCase_IDNO IS NOT NULL
       BEGIN
        IF ISNUMERIC (@Lc_IveRefCur_Child6IveCase_IDNO) = 1
         BEGIN
          SET @Ln_Child6CaseWelfare_IDNO = @Lc_IveRefCur_Child6IveCase_IDNO;
         END
        ELSE
         BEGIN
          SET @Ln_Child6CaseWelfare_IDNO = 0;
         END
       END
      ELSE
       BEGIN
        SET @Ln_Child6CaseWelfare_IDNO = 0;
       END
     
      IF (@Lc_MotherCreateApplication_INDC = 'Y'
           OR @Lc_MotherUpdateApplication_INDC = 'Y'
           OR @Lc_UiMotherCreateApplication_INDC = 'Y')
         AND @Lc_MotherDeathDate_INDC = 'N'
       BEGIN
        -- WRITE THE CODE FOR CREATING NEW APPLICATION 
        --First to create the row apcs table
        -- Get the application id from the common batch, if there was no existing application for the mother
        IF @Ln_MotherApplication_IDNO = @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_APPLICATIONID';
          SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

          EXECUTE BATCH_COMMON$SP_GET_APPLICATIONID 
             @An_Application_IDNO = @Ln_Application_IDNO OUTPUT;
         END
        ELSE
         BEGIN
          
          SET @Ln_Application_IDNO = @Ln_MotherApplication_IDNO;
         END
        
        --SELECT 'BEFORE MOTHER PRIMARY SSN CHECK '
        IF @Lc_IveRefCur_MotherPrimarySsn_NUMB <> '' 
         BEGIN
          IF ISNUMERIC (@Lc_IveRefCur_MotherPrimarySsn_NUMB) = 1
           BEGIN
            SET @Ln_MotherPrimarySsn_NUMB = @Lc_IveRefCur_MotherPrimarySsn_NUMB;
           END
          ELSE
           BEGIN
            SET @Ln_MotherPrimarySsn_NUMB = 0;
           END
         END
        ELSE
         BEGIN
          SET @Ln_MotherPrimarySsn_NUMB = 0;
         END

        IF @Lc_IveRefCur_MotherMci_IDNO = ''
            OR CAST(@Lc_IveRefCur_MotherMci_IDNO AS NUMERIC) = @Ln_Zeros_NUMB
         
         BEGIN
          -- Get the -ve number for the mother MCI
          SET @Ln_MemberMci_IDNO = 0;
         
         END
        ELSE
         BEGIN
          SET @Ln_MemberMci_IDNO = @Lc_IveRefCur_MotherMci_IDNO;
         END

        --Check mother Mci number is zero, get the negative sequence number for mother
        IF @Ln_MemberMci_IDNO = 0
        AND @Lc_UiMotherCreateApplication_INDC = @Lc_ValueNo_INDC
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_APPLICATIONID';
          SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;
          EXECUTE BATCH_COMMON$SP_GET_APPLICATIONMEMBERID 
           @An_MemberSeq_IDNO = @Ln_MemberMci_IDNO OUTPUT;
         END

         -- set default values for unidentified Mother application
        IF @Lc_UiMotherCreateApplication_INDC = @Lc_ValueYes_INDC
           BEGIN
             SET @Lc_IveRefCur_MotherIveCase_IDNO = @Ln_Zero_Numb;
             SET @Lc_IveRefCur_MotherPid_IDNO     = @Ln_Zero_NUMB;
           END
        SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION';
        SET @Ls_Sqldata_TEXT = ' APPLICATION_IDNO = ' + ISNULL(CAST(@Ln_Application_IDNO AS VARCHAR), 0) + ', PARENTMCI_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0);
        EXECUTE BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION
         @An_Application_IDNO                    = @Ln_Application_IDNO,
         @An_ParentMci_IDNO                      = @Ln_MemberMci_IDNO,
         @Ad_Run_DATE                            = @Ld_Run_DATE,
         @Ad_Update_DTTM                         = @Ld_Start_DATE,
         @An_TransactionEventSeq_NUMB            = @Ln_TransactionEventSeq_NUMB,
         @Ac_Parent_NAME                         = @Lc_IveRefCur_Mother_NAME,
         @Ac_ParentAlias_NAME                    = @Lc_IveRefCur_MotherAlias_NAME,
         @Ac_ParentSex_CODE                      = @Lc_IveRefCur_MotherSex_CODE,
         @An_ParentPrimarySsn_NUMB               = @Ln_MotherPrimarySsn_NUMB,
         @Ad_ParentBirth_DATE                    = @Lc_IveRefCur_MotherBirth_DATE,
         @Ac_Race_CODE                           = @Lc_IveRefCur_MotherRace_CODE,
         @An_ParentCaseWelfare_IDNO              = @Lc_IveRefCur_MotherIveCase_IDNO,
         @An_IvePartyParent_IDNO                 = @Lc_IveRefCur_MotherPid_IDNO,
         @Ac_FatherMother_CODE                   = @Lc_Mother_CODE,
         @Ac_StatusCase_CODE                     = @Lc_ApplicationStatus_CODE,
         @An_County_IDNO                         = @Ln_County_IDNO,
         @As_ParentLine1_ADDR                    = @Ls_IveRefCur_MotherLine1_ADDR,
         @As_ParentLine2_ADDR                    = @Ls_IveRefCur_MotherLine2_ADDR,
         @Ac_ParentCity_ADDR                     = @Lc_IveRefCur_MotherCity_ADDR,
         @Ac_ParentState_ADDR                    = @Lc_IveRefCur_MotherState_ADDR,
         @Ac_ParentZip_ADDR                      = @Lc_IveRefCur_MotherZip_ADDR,
         @Ac_ParentAddressNormalization_CODE     = @Lc_IveRefCur_MotherAddressNormalization_CODE,
         @Ac_ParentEmpl_NAME                     = @Lc_IveRefCur_MotherEmpl_NAME,
         @As_ParentEmplLine1_ADDR                = @Ls_IveRefCur_MotherEmplLine1_ADDR,
         @As_ParentEmplLine2_ADDR                = @Ls_IveRefCur_MotherEmplLine2_ADDR,
         @Ac_ParentEmplCity_ADDR                 = @Lc_IveRefCur_MotherEmplCity_ADDR,
         @Ac_ParentEmplState_ADDR                = @Lc_IveRefCur_MotherEmplState_ADDR,
         @Ac_ParentEmplZip_ADDR                  = @Lc_IveRefCur_MotherEmplZip_ADDR,
         @Ac_ParentEmplAddressNormalization_CODE = @Lc_IveRefCur_MotherEmplAddressNormalization_CODE,
         @Ac_ParentInformation_INDC              = @Lc_IveRefCur_MotherInformation_INDC,
         @Ac_Msg_CODE                            = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT               = @Ls_DescriptionError_TEXT OUTPUT;
          
        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
        
        -- Insert APCM APDM and APMH records for all the children in the referral for the mother application
        
        SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION';
        SET @Ls_Sqldata_TEXT = ' APPLICATION_IDNO = ' + ISNULL(CAST(@Ln_Application_IDNO AS VARCHAR), 0) + ', MOTHER_IVE_CASE_IDNO = ' + ISNULL(@Lc_IveRefCur_MotherIveCase_IDNO, 0);
        EXECUTE BATCH_FIN_IVE_REFERRAL$SP_CREATE_CHILD_APPLICATIONS
         @An_Application_IDNO         = @Ln_Application_IDNO,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ad_Update_DTTM              = @Ld_Start_DATE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @An_CaseWelfare_IDNO         = @Lc_IveRefCur_MotherIveCase_IDNO,
         @An_Child1Mci_IDNO           = @Ln_Child1Mci_IDNO,
         @Ac_Child1_NAME              = @Lc_IveRefCur_Child1_NAME,
         @Ac_Child1Father_NAME        = @Lc_IveRefCur_Child1Father_NAME,
         @Ac_Child1Mother_NAME        = @Lc_IveRefCur_Child1Mother_NAME,
         @An_Child1PrimarySsn_NUMB    = @Ln_Child1PrimarySsn_NUMB,
         @Ad_Child1Birth_DATE         = @Lc_IveRefCur_Child1Birth_DATE,
         @Ac_Child1PaternityEst_INDC  = @Lc_IveRefCur_Child1PaternityEst_INDC,
         @An_Child1Pid_IDNO           = @Ln_Child1Pid_IDNO,
         @Ac_Child1MotherIns_INDC     = @Lc_IveRefCur_Child1MotherIns_INDC,
         @An_Child1CaseWelfare_IDNO   = @Ln_Child1CaseWelfare_IDNO,
         @An_Child2Mci_IDNO           = @Ln_Child2Mci_IDNO,
         @Ac_Child2_NAME              = @Lc_IveRefCur_Child2_NAME,
         @Ac_Child2Father_NAME        = @Lc_IveRefCur_Child2Father_NAME,
         @Ac_Child2Mother_NAME        = @Lc_IveRefCur_Child2Mother_NAME,
         @An_Child2PrimarySsn_NUMB    = @Ln_Child2PrimarySsn_NUMB,
         @Ad_Child2Birth_DATE         = @Lc_IveRefCur_Child2Birth_DATE,
         @Ac_Child2PaternityEst_INDC  = @Lc_IveRefCur_Child2PaternityEst_INDC,
         @An_Child2Pid_IDNO           = @Ln_Child2Pid_IDNO,
         @Ac_Child2MotherIns_INDC     = @Lc_IveRefCur_Child2MotherIns_INDC,
         @An_Child2CaseWelfare_IDNO   = @Ln_Child2CaseWelfare_IDNO,
         @An_Child3Mci_IDNO           = @Ln_Child3Mci_IDNO,
         @Ac_Child3_NAME              = @Lc_IveRefCur_Child3_NAME,
         @Ac_Child3Father_NAME        = @Lc_IveRefCur_Child3Father_NAME,
         @Ac_Child3Mother_NAME        = @Lc_IveRefCur_Child3Mother_NAME,
         @An_Child3PrimarySsn_NUMB    = @Ln_Child3PrimarySsn_NUMB,
         @Ad_Child3Birth_DATE         = @Lc_IveRefCur_Child3Birth_DATE,
         @Ac_Child3PaternityEst_INDC  = @Lc_IveRefCur_Child3PaternityEst_INDC,
         @An_Child3Pid_IDNO           = @Ln_Child3Pid_IDNO,
         @Ac_Child3MotherIns_INDC     = @Lc_IveRefCur_Child3MotherIns_INDC,
         @An_Child3CaseWelfare_IDNO   = @Ln_Child3CaseWelfare_IDNO,
         @An_Child4Mci_IDNO           = @Ln_Child4Mci_IDNO,
         @Ac_Child4_NAME              = @Lc_IveRefCur_Child4_NAME,
         @Ac_Child4Father_NAME        = @Lc_IveRefCur_Child4Father_NAME,
         @Ac_Child4Mother_NAME        = @Lc_IveRefCur_Child4Mother_NAME,
         @An_Child4PrimarySsn_NUMB    = @Ln_Child4PrimarySsn_NUMB,
         @Ad_Child4Birth_DATE         = @Lc_IveRefCur_Child4Birth_DATE,
         @Ac_Child4PaternityEst_INDC  = @Lc_IveRefCur_Child4PaternityEst_INDC,
         @An_Child4Pid_IDNO           = @Ln_Child4Pid_IDNO,
         @Ac_Child4MotherIns_INDC     = @Lc_IveRefCur_Child4MotherIns_INDC,
         @An_Child4CaseWelfare_IDNO   = @Ln_Child4CaseWelfare_IDNO,
         @An_Child5Mci_IDNO           = @Ln_Child5Mci_IDNO,
         @Ac_Child5_NAME              = @Lc_IveRefCur_Child5_NAME,
         @Ac_Child5Father_NAME        = @Lc_IveRefCur_Child5Father_NAME,
         @Ac_Child5Mother_NAME        = @Lc_IveRefCur_Child5Mother_NAME,
         @An_Child5PrimarySsn_NUMB    = @Ln_Child5PrimarySsn_NUMB,
         @Ad_Child5Birth_DATE         = @Lc_IveRefCur_Child5Birth_DATE,
         @Ac_Child5PaternityEst_INDC  = @Lc_IveRefCur_Child5PaternityEst_INDC,
         @An_Child5Pid_IDNO           = @Ln_Child5Pid_IDNO,
         @Ac_Child5MotherIns_INDC     = @Lc_IveRefCur_Child5MotherIns_INDC,
         @An_Child5CaseWelfare_IDNO   = @Ln_Child5CaseWelfare_IDNO,
         @An_Child6Mci_IDNO           = @Ln_Child6Mci_IDNO,
         @Ac_Child6_NAME              = @Lc_IveRefCur_Child6_NAME,
         @Ac_Child6Father_NAME        = @Lc_IveRefCur_Child6Father_NAME,
         @Ac_Child6Mother_NAME        = @Lc_IveRefCur_Child6Mother_NAME,
         @An_Child6Primary_SSN        = @Ln_Child6PrimarySsn_NUMB,
         @Ad_Child6Birth_DATE         = @Lc_IveRefCur_Child6Birth_DATE,
         @Ac_Child6PaternityEst_INDC  = @Lc_IveRefCur_Child6PaternityEst_INDC,
         @An_Child6Pid_IDNO           = @Ln_Child6Pid_IDNO,
         @Ac_Child6MotherIns_INDC     = @Lc_IveRefCur_Child6MotherIns_INDC,
         @An_Child6CaseWelfare_IDNO   = @Ln_Child6CaseWelfare_IDNO,
         @Ac_FatherMother_CODE        = @Lc_Mother_CODE,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
        
        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        -- Create a Foster care client agency record in APCM, APDM, APAH tables
        -- Create application case member for the foster care agency 
        SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION';
        SET @Ls_Sqldata_TEXT = ' APPLICATION_IDNO = ' + ISNULL(CAST(@Ln_Application_IDNO AS VARCHAR), 0) + ', MemberMCIDFS_IDNO = ' + ISNULL(CAST(@Ln_MemberMciDfs_IDNO AS VARCHAR), 0);
        EXECUTE BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION
         @An_Application_IDNO         = @Ln_Application_IDNO,
         @An_MemberMciDfs_IDNO        = @Ln_MemberMciDfs_IDNO,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ad_Update_DTTM              = @Ld_Start_DATE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_First_NAME               = @Lc_First_NAME,
         @Ac_Last_NAME                = @Lc_Last_NAME,
         @Ac_Middle_NAME              = @Lc_Middle_NAME,
         @Ac_Suffix_NAME              = @Lc_Suffix_NAME,
         @Ac_MemberSex_CODE           = @Lc_MemberSex_CODE,
         @An_MemberSsn_NUMB           = @Ln_MemberSsn_NUMB,
         @Ad_DfsBirth_DATE            = @Ld_DfsBirth_DATE,
         @As_Line1_ADDR               = @Ls_Line1_ADDR,
         @As_Line2_ADDR               = @Ls_Line2_ADDR,
         @Ac_City_ADDR                = @Lc_City_ADDR,
         @Ac_State_ADDR               = @Lc_State_ADDR,
         @Ac_Zip_ADDR                 = @Lc_Zip_ADDR,
         @Ac_Race_CODE                = @Lc_Race_CODE,
         @Ac_Normalization_CODE       = @Lc_Normalization_CODE,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
        
        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
       
       END
     
      IF (@Lc_FatherCreateApplication_INDC = 'Y'
           OR @Lc_FatherUpdateApplication_INDC = 'Y'
           OR @Lc_UiFatherCreateApplication_INDC = 'Y')
         AND @Lc_FatherDeathDate_INDC = 'N' 
       BEGIN
        -- Create father application process 
        IF @Ln_FatherApplication_IDNO = @Ln_Zero_NUMB
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_APPLICATIONID';
          SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;

          EXEC BATCH_COMMON$SP_GET_APPLICATIONID @An_Application_IDNO = @Ln_Application_IDNO OUTPUT;
         END
        ELSE
         BEGIN
         
          SET @Ln_Application_IDNO = @Ln_FatherApplication_IDNO;
         END
        
        IF @Lc_IveRefCur_FatherPrimarySsn_NUMB <> '' 
         BEGIN
          IF ISNUMERIC (@Lc_IveRefCur_FatherPrimarySsn_NUMB) = 1
           BEGIN
            SET @Ln_FatherPrimarySsn_NUMB = @Lc_IveRefCur_FatherPrimarySsn_NUMB;
           END
          ELSE
           BEGIN
            SET @Ln_FatherPrimarySsn_NUMB = 0;
           END
         END
        ELSE
         BEGIN
          SET @Ln_FatherPrimarySsn_NUMB = 0;
         END

        IF @Lc_IveRefCur_FatherMci_IDNO = ''
            OR CAST(@Lc_IveRefCur_FatherMci_IDNO AS NUMERIC) = @Ln_Zeros_NUMB
         
         BEGIN
          -- Get the -ve number for the mother MCI
          SET @Ln_MemberMci_IDNO = 0;
         
         END
        ELSE
         BEGIN
          SET @Ln_MemberMci_IDNO = @Lc_IveRefCur_FatherMci_IDNO;
         END

        --Check father Mci number is zero, get the negative sequence number for father
        IF @Ln_MemberMci_IDNO = 0
        AND @Lc_UiFatherCreateApplication_INDC = @Lc_ValueNo_INDC
         BEGIN
          SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_APPLICATIONID';
          SET @Ls_Sqldata_TEXT = ' Job_ID = ' + @Lc_Job_ID;
          EXECUTE BATCH_COMMON$SP_GET_APPLICATIONMEMBERID 
            @An_MemberSeq_IDNO = @Ln_MemberMci_IDNO OUTPUT;
         END

        -- set default values for unidentified father application
        IF @Lc_UiFatherCreateApplication_INDC = @Lc_ValueYes_INDC
           BEGIN
             SET @Lc_IveRefCur_FatherIveCase_IDNO = @Ln_Zero_Numb;
             SET @Lc_IveRefCur_FatherPid_IDNO     = @Ln_Zero_NUMB;
           END
        SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION';
        SET @Ls_Sqldata_TEXT = ' APPLICATION_IDNO = ' + ISNULL(CAST(@Ln_Application_IDNO AS VARCHAR), 0) + ', PARENTMCI_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR), 0);
        EXECUTE BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION
         @An_Application_IDNO                    = @Ln_Application_IDNO,
         @An_ParentMci_IDNO                      = @Ln_MemberMci_IDNO,
         @Ad_Run_DATE                            = @Ld_Run_DATE,
         @Ad_Update_DTTM                         = @Ld_Start_DATE,
         @An_TransactionEventSeq_NUMB            = @Ln_TransactionEventSeq_NUMB,
         @Ac_Parent_NAME                         = @Lc_IveRefCur_Father_NAME,
         @Ac_ParentAlias_NAME                    = @Lc_IveRefCur_FatherAlias_NAME,
         @Ac_ParentSex_CODE                      = @Lc_IveRefCur_FatherSex_CODE,
         @An_ParentPrimarySsn_NUMB               = @Ln_FatherPrimarySsn_NUMB,
         @Ad_ParentBirth_DATE                    = @Lc_IveRefCur_FatherBirth_DATE,
         @Ac_Race_CODE                           = @Lc_IveRefCur_FatherRace_CODE,
         @An_ParentCaseWelfare_IDNO              = @Lc_IveRefCur_FatherIveCase_IDNO,
         @An_IvePartyParent_IDNO                 = @Lc_IveRefCur_FatherPid_IDNO,
         @Ac_FatherMother_CODE                   = @Lc_Father_CODE,
         @Ac_StatusCase_CODE                     = @Lc_ApplicationStatus_CODE,
         @An_County_IDNO                         = @Ln_County_IDNO,
         @As_ParentLine1_ADDR                    = @Ls_IveRefCur_FatherLine1_ADDR,
         @As_ParentLine2_ADDR                    = @Ls_IveRefCur_FatherLine2_ADDR,
         @Ac_ParentCity_ADDR                     = @Lc_IveRefCur_FatherCity_ADDR,
         @Ac_ParentState_ADDR                    = @Lc_IveRefCur_FatherState_ADDR,
         @Ac_ParentZip_ADDR                      = @Lc_IveRefCur_FatherZip_ADDR,
         @Ac_ParentAddressNormalization_CODE     = @Lc_IveRefCur_FatherAddressNormalization_CODE,
         @Ac_ParentEmpl_NAME                     = @Lc_IveRefCur_FatherEmpl_NAME,
         @As_ParentEmplLine1_ADDR                = @Ls_IveRefCur_FatherEmplLine1_ADDR,
         @As_ParentEmplLine2_ADDR                = @Ls_IveRefCur_FatherEmplLine2_ADDR,
         @Ac_ParentEmplCity_ADDR                 = @Lc_IveRefCur_FatherEmplCity_ADDR,
         @Ac_ParentEmplState_ADDR                = @Lc_IveRefCur_FatherEmplState_ADDR,
         @Ac_ParentEmplZip_ADDR                  = @Lc_IveRefCur_FatherEmplZip_ADDR,
         @Ac_ParentEmplAddressNormalization_CODE = @Lc_IveRefCur_FatherEmplAddressNormalization_CODE,
         @Ac_ParentInformation_INDC              = @Lc_IveRefCur_FatherInformation_INDC,
         @Ac_Msg_CODE                            = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT               = @Ls_DescriptionError_TEXT OUTPUT;
    
        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
        
        --Create child application entries for father case based on the referral information
        SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_CREATE_NCP_APPLICATION';
        SET @Ls_Sqldata_TEXT = ' APPLICATION_IDNO = ' + ISNULL(CAST(@Ln_Application_IDNO AS VARCHAR), 0) + ', MOTHER_IVE_CASE_IDNO = ' + ISNULL(@Lc_IveRefCur_FatherIveCase_IDNO, 0);
        EXECUTE BATCH_FIN_IVE_REFERRAL$SP_CREATE_CHILD_APPLICATIONS
         @An_Application_IDNO         = @Ln_Application_IDNO,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ad_Update_DTTM              = @Ld_Start_DATE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @An_CaseWelfare_IDNO         = @Lc_IveRefCur_FatherIveCase_IDNO,
         @An_Child1Mci_IDNO           = @Ln_Child1Mci_IDNO,
         @Ac_Child1_NAME              = @Lc_IveRefCur_Child1_NAME,
         @Ac_Child1Father_NAME        = @Lc_IveRefCur_Child1Father_NAME,
         @Ac_Child1Mother_NAME        = @Lc_IveRefCur_Child1Mother_NAME,
         @An_Child1PrimarySsn_NUMB    = @Ln_Child1PrimarySsn_NUMB,
         @Ad_Child1Birth_DATE         = @Lc_IveRefCur_Child1Birth_DATE,
         @Ac_Child1PaternityEst_INDC  = @Lc_IveRefCur_Child1PaternityEst_INDC,
         @An_Child1Pid_IDNO           = @Ln_Child1Pid_IDNO,
         @Ac_Child1MotherIns_INDC     = @Lc_IveRefCur_Child1FatherIns_INDC,
         @An_Child1CaseWelfare_IDNO   = @Ln_Child1CaseWelfare_IDNO,
         @An_Child2Mci_IDNO           = @Ln_Child2Mci_IDNO,
         @Ac_Child2_NAME              = @Lc_IveRefCur_Child2_NAME,
         @Ac_Child2Father_NAME        = @Lc_IveRefCur_Child2Father_NAME,
         @Ac_Child2Mother_NAME        = @Lc_IveRefCur_Child2Mother_NAME,
         @An_Child2PrimarySsn_NUMB    = @Ln_Child2PrimarySsn_NUMB,
         @Ad_Child2Birth_DATE         = @Lc_IveRefCur_Child2Birth_DATE,
         @Ac_Child2PaternityEst_INDC  = @Lc_IveRefCur_Child2PaternityEst_INDC,
         @An_Child2Pid_IDNO           = @Ln_Child2Pid_IDNO,
         @Ac_Child2MotherIns_INDC     = @Lc_IveRefCur_Child2FatherIns_INDC,
         @An_Child2CaseWelfare_IDNO   = @Ln_Child2CaseWelfare_IDNO,
         @An_Child3Mci_IDNO           = @Ln_Child3Mci_IDNO,
         @Ac_Child3_NAME              = @Lc_IveRefCur_Child3_NAME,
         @Ac_Child3Father_NAME        = @Lc_IveRefCur_Child3Father_NAME,
         @Ac_Child3Mother_NAME        = @Lc_IveRefCur_Child3Mother_NAME,
         @An_Child3PrimarySsn_NUMB    = @Ln_Child3PrimarySsn_NUMB,
         @Ad_Child3Birth_DATE         = @Lc_IveRefCur_Child3Birth_DATE,
         @Ac_Child3PaternityEst_INDC  = @Lc_IveRefCur_Child3PaternityEst_INDC,
         @An_Child3Pid_IDNO           = @Ln_Child3Pid_IDNO,
         @Ac_Child3MotherIns_INDC     = @Lc_IveRefCur_Child3FatherIns_INDC,
         @An_Child3CaseWelfare_IDNO   = @Ln_Child3CaseWelfare_IDNO,
         @An_Child4Mci_IDNO           = @Ln_Child4Mci_IDNO,
         @Ac_Child4_NAME              = @Lc_IveRefCur_Child4_NAME,
         @Ac_Child4Father_NAME        = @Lc_IveRefCur_Child4Father_NAME,
         @Ac_Child4Mother_NAME        = @Lc_IveRefCur_Child4Mother_NAME,
         @An_Child4PrimarySsn_NUMB    = @Ln_Child4PrimarySsn_NUMB,
         @Ad_Child4Birth_DATE         = @Lc_IveRefCur_Child4Birth_DATE,
         @Ac_Child4PaternityEst_INDC  = @Lc_IveRefCur_Child4PaternityEst_INDC,
         @An_Child4Pid_IDNO           = @Ln_Child4Pid_IDNO,
         @Ac_Child4MotherIns_INDC     = @Lc_IveRefCur_Child4FatherIns_INDC,
         @An_Child4CaseWelfare_IDNO   = @Ln_Child4CaseWelfare_IDNO,
         @An_Child5Mci_IDNO           = @Ln_Child5Mci_IDNO,
         @Ac_Child5_NAME              = @Lc_IveRefCur_Child5_NAME,
         @Ac_Child5Father_NAME        = @Lc_IveRefCur_Child5Father_NAME,
         @Ac_Child5Mother_NAME        = @Lc_IveRefCur_Child5Mother_NAME,
         @An_Child5PrimarySsn_NUMB    = @Ln_Child5PrimarySsn_NUMB,
         @Ad_Child5Birth_DATE         = @Lc_IveRefCur_Child5Birth_DATE,
         @Ac_Child5PaternityEst_INDC  = @Lc_IveRefCur_Child5PaternityEst_INDC,
         @An_Child5Pid_IDNO           = @Ln_Child5Pid_IDNO,
         @Ac_Child5MotherIns_INDC     = @Lc_IveRefCur_Child5FatherIns_INDC,
         @An_Child5CaseWelfare_IDNO   = @Ln_Child5CaseWelfare_IDNO,
         @An_Child6Mci_IDNO           = @Ln_Child6Mci_IDNO,
         @Ac_Child6_NAME              = @Lc_IveRefCur_Child6_NAME,
         @Ac_Child6Father_NAME        = @Lc_IveRefCur_Child6Father_NAME,
         @Ac_Child6Mother_NAME        = @Lc_IveRefCur_Child6Mother_NAME,
         @An_Child6Primary_SSN        = @Ln_Child6PrimarySsn_NUMB,
         @Ad_Child6Birth_DATE         = @Lc_IveRefCur_Child6Birth_DATE,
         @Ac_Child6PaternityEst_INDC  = @Lc_IveRefCur_Child6PaternityEst_INDC,
         @An_Child6Pid_IDNO           = @Ln_Child6Pid_IDNO,
         @Ac_Child6MotherIns_INDC     = @Lc_IveRefCur_Child6FatherIns_INDC,
         @An_Child6CaseWelfare_IDNO   = @Ln_Child6CaseWelfare_IDNO,
         @Ac_FatherMother_CODE        = @Lc_Father_CODE,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
        
        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        -- Create a Foster care client agency record in APCM, APDM, APAH tables
        -- Create application case member for the foster care agency 
        SET @Ls_Sql_TEXT = 'CALLING PROCEDURE BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION';
        SET @Ls_Sqldata_TEXT = ' APPLICATION_IDNO = ' + ISNULL(CAST(@Ln_Application_IDNO AS VARCHAR), 0) + ', MemberMCIDFS_IDNO = ' + ISNULL(CAST(@Ln_MemberMciDfs_IDNO AS VARCHAR), 0);
        EXECUTE BATCH_FIN_IVE_REFERRAL$SP_CREATE_CLIENT_APPLICATION
         @An_Application_IDNO         = @Ln_Application_IDNO,
         @An_MemberMciDfs_IDNO        = @Ln_MemberMciDfs_IDNO,
         @Ad_Run_DATE                 = @Ld_Run_DATE,
         @Ad_Update_DTTM              = @Ld_Start_DATE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_First_NAME               = @Lc_First_NAME,
         @Ac_Last_NAME                = @Lc_Last_NAME,
         @Ac_Middle_NAME              = @Lc_Middle_NAME,
         @Ac_Suffix_NAME              = @Lc_Suffix_NAME,
         @Ac_MemberSex_CODE           = @Lc_MemberSex_CODE,
         @An_MemberSsn_NUMB           = @Ln_MemberSsn_NUMB,
         @Ad_DfsBirth_DATE            = @Ld_DfsBirth_DATE,
         @As_Line1_ADDR               = @Ls_Line1_ADDR,
         @As_Line2_ADDR               = @Ls_Line2_ADDR,
         @Ac_City_ADDR                = @Lc_City_ADDR,
         @Ac_State_ADDR               = @Lc_State_ADDR,
         @Ac_Zip_ADDR                 = @Lc_Zip_ADDR,
         @Ac_Race_CODE                = @Lc_Race_CODE,
         @Ac_Normalization_CODE       = @Lc_Normalization_CODE,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
        
        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END
      
       END
     
   
     END TRY

     BEGIN CATCH
      IF CURSOR_STATUS ('local', 'MhisIve_CUR') IN (0, 1)
		BEGIN
			CLOSE MhisIve_CUR;
			DEALLOCATE MhisIve_CUR;
		END
	  IF CURSOR_STATUS ('local', 'MtrMatch_CUR') IN (0, 1)
		BEGIN
			CLOSE MtrMatch_CUR;
			DEALLOCATE MtrMatch_CUR;
		END
	  IF CURSOR_STATUS ('local', 'FtrMatch_CUR') IN (0, 1)
		BEGIN
			CLOSE FtrMatch_CUR;
			DEALLOCATE FtrMatch_CUR;
		END
	      
      SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

      -- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	     BEGIN
	   	  
	   	   ROLLBACK TRANSACTION SAVEIVE_PROCESS;
		 END
		ELSE
		 BEGIN
		    SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + '' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
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

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
      SET @Ls_Sqldata_TEXT = 'Application_ID = ' + CAST(@Ln_Application_IDNO AS VARCHAR(19)) + ', Transaction Event Id = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR(19));
      SET @Ls_BateRecord_TEXT = 'Bate Record = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
       @An_Line_NUMB                = @Ln_RecordCount_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
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
     END CATCH

     SET @Ls_Sql_TEXT = 'UPDATING THE PROCESS INDICATOR IN LIREF_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IveRefCur_Seq_IDNO AS VARCHAR);
     
     --Increment the processed record count by 1 	
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;

      --UPDATING THE PROCESS INDICATOR TO 'Y'
     UPDATE LIREF_Y1
        SET Process_INDC = @Lc_ValueYes_INDC
      WHERE Seq_IDNO = @Ln_IveRefCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'UPDATE FAILED LIREF_Y1';

       RAISERROR(50001,16,1);
      END

     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     -- If the commit frequency is reached, Reset the commit count, Commit the transaction completed until now.
     IF @Ln_CommitFreqParm_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL (@Lc_Job_ID, '') + ', RUN DATE = ' + ISNULL (CAST (@Ld_Run_DATE AS VARCHAR), '') + ', RESTART KEY = ' + ISNULL (CAST (@Ln_RecordCount_QNTY AS VARCHAR), '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Lc_Job_ID,
        @Ad_Run_DATE              = @Ld_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_RecordCount_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
       
       SET @Ls_Sql_TEXT = 'TRASACTION COMMITS - 2';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       COMMIT TRANSACTION IVEREFERRAL_BATCH_PROCESS;

       -- Number of records processed after reaching frquency committed , .	
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_Sql_TEXT = 'TRASACTION BEGINS - 3';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

       BEGIN TRANSACTION IVEREFERRAL_BATCH_PROCESS;

       --After Transaction is commited and again began set the commit frequencey to 0                        
       SET @Ln_CommitFreq_QNTY = 0;
      END;

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + CAST(@Ln_IveRefCur_Seq_IDNO AS VARCHAR);
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION IVEREFERRAL_BATCH_PROCESS;
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH NEXT RECORD FROM CURSOR - 2';
     SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT ;

     FETCH NEXT FROM IveRef_CUR INTO @Ln_IveRefCur_Seq_IDNO, @Lc_IveRefCur_Rec_ID, @Ld_IveRefCur_Application_DATE, @Lc_IveRefCur_Approved_DATE, @Lc_IveRefCur_IveCaseStatus_CODE, @Lc_IveRefCur_ApplicationCounty_IDNO, @Lc_IveRefCur_CourtOrder_INDC, @Lc_IveRefCur_File_ID, @Ld_IveRefCur_CourtOrder_DATE, @Lc_IveRefCur_CourtOrderCity_NAME, @Lc_IveRefCur_CourtOrderState_CODE, @Lc_IveRefCur_CourtOrder_AMNT, @Lc_IveRefCur_CourtOrderFrequency_CODE, @Lc_IveRefCur_CourtOrderEffective_INDC, @Lc_IveRefCur_CourtPaymentType_CODE, @Lc_IveRefCur_MotherInformation_INDC, @Lc_IveRefCur_Mother_NAME, @Lc_IveRefCur_MotherMci_IDNO, @Lc_IveRefCur_MotherPid_IDNO, @Lc_IveRefCur_MotherPrimarySsn_NUMB, @Lc_IveRefCur_MotherOtherSsn_NUMB, @Lc_IveRefCur_MotherAlias_NAME, @Lc_IveRefCur_MotherIveCase_IDNO, @Lc_IveRefCur_MotherDeath_DATE, @Lc_IveRefCur_MotherHealthIns_INDC, @Lc_IveRefCur_MotherInsPolicy_ID, @Lc_IveRefCur_MotherIns_NAME, @Lc_IveRefCur_MotherAddress_CODE, @Lc_IveRefCur_MotherAddressNormalization_CODE, @Ls_IveRefCur_MotherLine1_ADDR, @Ls_IveRefCur_MotherLine2_ADDR, @Lc_IveRefCur_MotherCity_ADDR, @Lc_IveRefCur_MotherState_ADDR, @Lc_IveRefCur_MotherZip_ADDR, @Lc_IveRefCur_MotherBirth_DATE, @Lc_IveRefCur_MotherRace_CODE, @Lc_IveRefCur_MotherSex_CODE, @Lc_IveRefCur_MotherEmpl_CODE, @Lc_IveRefCur_MotherEmpl_NAME, @Lc_IveRefCur_MotherEmplAddressNormalization_CODE, @Ls_IveRefCur_MotherEmplLine1_ADDR, @Ls_IveRefCur_MotherEmplLine2_ADDR, @Lc_IveRefCur_MotherEmplCity_ADDR, @Lc_IveRefCur_MotherEmplState_ADDR, @Lc_IveRefCur_MotherEmplZip_ADDR, @Lc_IveRefCur_MotherLastPayment_DATE, @Lc_IveRefCur_MotherLastPayment_AMNT, @Lc_IveRefCur_MotherArrearage_AMNT, @Lc_IveRefCur_MotherPaymentDue_DATE, @Lc_IveRefCur_FatherInformation_INDC, @Lc_IveRefCur_Father_NAME, @Lc_IveRefCur_FatherMci_IDNO, @Lc_IveRefCur_FatherPid_IDNO, @Lc_IveRefCur_FatherPrimarySsn_NUMB, @Lc_IveRefCur_FatherOtherSsn_NUMB, @Lc_IveRefCur_FatherAlias_NAME, @Lc_IveRefCur_FatherIveCase_IDNO, @Lc_IveRefCur_FatherDeath_DATE, @Lc_IveRefCur_FatherHealthIns_INDC, @Lc_IveRefCur_FatherIns_NAME, @Lc_IveRefCur_FatherInsPolicy_ID, @Lc_IveRefCur_FatherAddress_CODE, @Lc_IveRefCur_FatherAddressNormalization_CODE, @Ls_IveRefCur_FatherLine1_ADDR, @Ls_IveRefCur_FatherLine2_ADDR, @Lc_IveRefCur_FatherCity_ADDR, @Lc_IveRefCur_FatherState_ADDR, @Lc_IveRefCur_FatherZip_ADDR, @Lc_IveRefCur_FatherBirth_DATE, @Lc_IveRefCur_FatherRace_CODE, @Lc_IveRefCur_FatherSex_CODE, @Lc_IveRefCur_FatherEmpl_CODE, @Lc_IveRefCur_FatherEmpl_NAME, @Lc_IveRefCur_FatherEmplAddressNormalization_CODE, @Ls_IveRefCur_FatherEmplLine1_ADDR, @Ls_IveRefCur_FatherEmplLine2_ADDR, @Lc_IveRefCur_FatherEmplCity_ADDR, @Lc_IveRefCur_FatherEmplState_ADDR, @Lc_IveRefCur_FatherEmplZip_ADDR, @Lc_IveRefCur_FatherLastPayment_DATE, @Lc_IveRefCur_FatherLastPayment_AMNT, @Lc_IveRefCur_FatherArrearage_AMNT, @Lc_IveRefCur_FatherPaymentDue_DATE, @Lc_IveRefCur_Child1Mci_IDNO, @Lc_IveRefCur_Child1Pid_IDNO, @Lc_IveRefCur_Child1Ssn_NUMB, @Lc_IveRefCur_Child1IveCase_IDNO, @Lc_IveRefCur_Child1_NAME, @Lc_IveRefCur_Child1Birth_DATE, @Lc_IveRefCur_Child1FedFunded_INDC, @Lc_IveRefCur_Child1PaternityEst_INDC, @Lc_IveRefCur_Child1Father_NAME, @Lc_IveRefCur_Child1FatherIveCase_IDNO, @Lc_IveRefCur_Child1Mother_NAME, @Lc_IveRefCur_Child1MotherIveCase_IDNO, @Lc_IveRefCur_Child1MotherIns_INDC, @Lc_IveRefCur_Child1FatherIns_INDC, @Lc_IveRefCur_Child1FosterCareBegin_DATE, @Lc_IveRefCur_Child1Monthly_AMNT, @Lc_IveRefCur_Child2Mci_IDNO, @Lc_IveRefCur_Child2Pid_IDNO, @Lc_IveRefCur_Child2Ssn_NUMB, @Lc_IveRefCur_Child2IveCase_IDNO, @Lc_IveRefCur_Child2_NAME, @Lc_IveRefCur_Child2Birth_DATE, @Lc_IveRefCur_Child2FedFunded_INDC, @Lc_IveRefCur_Child2PaternityEst_INDC, @Lc_IveRefCur_Child2Father_NAME, @Lc_IveRefCur_Child2FatherIveCase_IDNO, @Lc_IveRefCur_Child2Mother_NAME, @Lc_IveRefCur_Child2MotherIveCase_IDNO, @Lc_IveRefCur_Child2MotherIns_INDC, @Lc_IveRefCur_Child2FatherIns_INDC, @Lc_IveRefCur_Child2FosterCareBegin_DATE, @Lc_IveRefCur_Child2Monthly_AMNT, @Lc_IveRefCur_Child3Mci_IDNO, @Lc_IveRefCur_Child3Pid_IDNO, @Lc_IveRefCur_Child3Ssn_NUMB, @Lc_IveRefCur_Child3IveCase_IDNO, @Lc_IveRefCur_Child3_NAME, @Lc_IveRefCur_Child3Birth_DATE, @Lc_IveRefCur_Child3FedFunded_INDC, @Lc_IveRefCur_Child3PaternityEst_INDC, @Lc_IveRefCur_Child3Father_NAME, @Lc_IveRefCur_Child3FatherIveCase_IDNO, @Lc_IveRefCur_Child3Mother_NAME, @Lc_IveRefCur_Child3MotherIveCase_IDNO, @Lc_IveRefCur_Child3MotherIns_INDC, @Lc_IveRefCur_Child3FatherIns_INDC, @Lc_IveRefCur_Child3FosterCareBegin_DATE, @Lc_IveRefCur_Child3Monthly_AMNT, @Lc_IveRefCur_Child4Mci_IDNO, @Lc_IveRefCur_Child4Pid_IDNO, @Lc_IveRefCur_Child4Ssn_NUMB, @Lc_IveRefCur_Child4IveCase_IDNO, @Lc_IveRefCur_Child4_NAME, @Lc_IveRefCur_Child4Birth_DATE, @Lc_IveRefCur_Child4FedFunded_INDC, @Lc_IveRefCur_Child4PaternityEst_INDC, @Lc_IveRefCur_Child4Father_NAME, @Lc_IveRefCur_Child4FatherIveCase_IDNO, @Lc_IveRefCur_Child4Mother_NAME, @Lc_IveRefCur_Child4MotherIveCase_IDNO, @Lc_IveRefCur_Child4MotherIns_INDC, @Lc_IveRefCur_Child4FatherIns_INDC, @Lc_IveRefCur_Child4FosterCareBegin_DATE, @Lc_IveRefCur_Child4Monthly_AMNT, @Lc_IveRefCur_Child5Mci_IDNO, @Lc_IveRefCur_Child5Pid_IDNO, @Lc_IveRefCur_Child5Ssn_NUMB, @Lc_IveRefCur_Child5IveCase_IDNO, @Lc_IveRefCur_Child5_NAME, @Lc_IveRefCur_Child5Birth_DATE, @Lc_IveRefCur_Child5FedFunded_INDC, @Lc_IveRefCur_Child5PaternityEst_INDC, @Lc_IveRefCur_Child5Father_NAME, @Lc_IveRefCur_Child5FatherIveCase_IDNO, @Lc_IveRefCur_Child5Mother_NAME, @Lc_IveRefCur_Child5MotherIveCase_IDNO, @Lc_IveRefCur_Child5MotherIns_INDC, @Lc_IveRefCur_Child5FatherIns_INDC, @Lc_IveRefCur_Child5FosterCareBegin_DATE, @Lc_IveRefCur_Child5Monthly_AMNT, @Lc_IveRefCur_Child6Mci_IDNO, @Lc_IveRefCur_Child6Pid_IDNO, @Lc_IveRefCur_Child6Ssn_NUMB, @Lc_IveRefCur_Child6IveCase_IDNO, @Lc_IveRefCur_Child6_NAME, @Lc_IveRefCur_Child6Birth_DATE, @Lc_IveRefCur_Child6FedFunded_INDC, @Lc_IveRefCur_Child6PaternityEst_INDC, @Lc_IveRefCur_Child6Father_NAME, @Lc_IveRefCur_Child6FatherIveCase_IDNO, @Lc_IveRefCur_Child6Mother_NAME, @Lc_IveRefCur_Child6MotherIveCase_IDNO, @Lc_IveRefCur_Child6MotherIns_INDC, @Lc_IveRefCur_Child6FatherIns_INDC, @Lc_IveRefCur_Child6FosterCareBegin_DATE, @Lc_IveRefCur_Child6Monthly_AMNT;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE IveRef_CUR;

   DEALLOCATE IveRef_CUR;
 
   --Update the Parameter Table with the Job Run Date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'JOB_ID = ' + @Lc_Job_ID ;

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
   SET @Ls_Sqldata_TEXT = 'JOB_ID = ' + @Lc_Job_ID ;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @LC_Successful_TEXT,
    @As_ListKey_TEXT              = @LC_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'JOB_ID = ' + @Lc_Job_ID ;

   COMMIT TRANSACTION IVEREFERRAL_BATCH_PROCESS;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('local', 'IveRef_CUR') IN (0, 1)
    BEGIN
     CLOSE IveRef_CUR;

     DEALLOCATE IveRef_CUR;
    END

   --If Trasaction is not commited, it rolls back
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION IVEREFERRAL_BATCH_PROCESS;
    END

   --Set Error Description
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

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
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
