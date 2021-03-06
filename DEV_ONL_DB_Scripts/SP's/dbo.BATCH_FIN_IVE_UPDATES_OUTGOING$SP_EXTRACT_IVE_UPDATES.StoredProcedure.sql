/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_UPDATES_OUTGOING$SP_EXTRACT_IVE_UPDATES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_FIN_IVE_UPDATES_OUTGOING$SP_EXTRACT_IVE_UPDATES
Programmer Name   : IMP Team
Description       : This process sents the details of member who changes their application status,MCI number,name, paternity status and
					when there is a new child support order date to FACTS.
Frequency         : DAILY
Developed On      : 
Called BY         : None
Called On		  : BATCH_COMMON$SP_GET_BATCH_DETAILS2,
                    BATCH_COMMON$BSTL_LOG,
                    BATCH_COMMON$SP_EXTRACT_DATA,
                    BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 0.01
----------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_UPDATES_OUTGOING$SP_EXTRACT_IVE_UPDATES]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_UnKnownMci_IDNO				  NUMERIC(6) = 999995,
		  @Lc_StatusFailed_CODE               CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE          CHAR(1) = 'A',
          @Lc_RelationshipCaseNcp_CODE        CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE  CHAR(1) = 'P',
          @Lc_RelationshipCaseDep_CODE        CHAR(1) = 'D',
          @Lc_MemberActiveStatus_CODE         CHAR(1) = 'A',
          @Lc_MemberInActiveStatus_CODE       CHAR(1) = 'I',
          @Lc_DetailRecord_CODE               CHAR(1) = 'D',
          @Lc_Trailer_CODE                    CHAR(1) = 'T',
          @Lc_TypeErrorWarning_CODE           CHAR(1) = 'W',
          @Lc_HeaderRecord_CODE               CHAR(1) = 'H',
          @Lc_StatusOpen_CODE				  CHAR(1) = 'O',
          @Lc_StatusClosed_CODE               CHAR(1) = 'C',
          @Lc_AddressConfimedStatus_CODE      CHAR(1) = 'Y',
          @Lc_AddrresPendingStatus_CODE       CHAR(1) = 'P',
          @Lc_IVEFosterCareCaseType_CODE      CHAR(1) = 'F',
          @Lc_NonFederalFosterCareCase_CODE   CHAR(1) = 'J',
          @Lc_ApplicationStatusCompleted_CODE CHAR(1) = 'C',
          @Lc_ApplicationStatusPending_CODE   CHAR(1) = 'P',
          @Lc_ApplicationFosterPending_CODE   CHAR(1) = 'F',
          @Lc_ApplicationStatusCreated_CODE   CHAR(1) = 'C',
          @Lc_ApplicationStatusFiledPet_CODE  CHAR(1) = 'F',
          @Lc_ApplicationStatusEstPater_CODE  CHAR(1) = 'E',
          @Lc_ApplicationStatusScheduled_CODE CHAR(1) = 'S',
          @Lc_ApplicationStatusOrderEst_CODE  CHAR(1) = 'O',
          @Lc_MailingAddress_CODE             CHAR(1) = 'M',
          @Lc_CurrentAddress_CODE             CHAR(1) = 'C',
          @Lc_ResidAddress_CODE               CHAR(1) = 'R',
          @Lc_LastKnownAddress_CODE           CHAR(1) = 'L',
          @Lc_ReasonApplnStatus_CODE          CHAR(2) = 'AS',
          @Lc_ReasonChildNameChg_CODE         CHAR(2) = 'CN',
          @Lc_ReasonParentNameChg_CODE        CHAR(2) = 'PN',
          @Lc_ReasonChildMciChg_CODE          CHAR(2) = 'CM',
          @Lc_ReasonParentMciChg_CODE         CHAR(2) = 'PM',
          @Lc_ReasonParentCaseCloser_CODE     CHAR(2) = 'CC',
          @Lc_ReasonSupportOrderDateChg_CODE  CHAR(2) = 'SO',
          @Lc_FiledPetitionReasonPj_CODE      CHAR(2) = 'PJ',
          @Lc_FiledPetitionReasonCg_CODE      CHAR(2) = 'CG',
          @Lc_ChildSupportType_CODE           CHAR(2) = 'CS',
          @Lc_AppointmentScheduled_CODE       CHAR(2) = 'SC',
          @Lc_DacesMethodEstablishBc_CODE     CHAR(2) = 'BC',
          @Lc_DacesMethodEstablishOt_CODE     CHAR(2) = 'OT',
          @Lc_DacesMethodEstablishCs_CODE     CHAR(2) = 'CS',
          @Lc_DacesMethodEstablishCu_CODE     CHAR(2) = 'CU',
          @Lc_DacesMethodEstablishPd_CODE     CHAR(2) = 'PD',
          @Lc_DacesMethodEstablishVp_CODE     CHAR(2) = 'VP',
          @Lc_FactsMethodEstablishAo_CODE     CHAR(2) = 'AO',
          @Lc_FactsMethodEstablishUk_CODE     CHAR(2) = 'UK',
          @Lc_FactsMethodEstablishCo_CODE     CHAR(2) = 'CO',
          @Lc_FactsMethodEstablishCj_CODE     CHAR(2) = 'CJ',
          @Lc_FactsMethodEstablishAh_CODE     CHAR(2) = 'AH',
          @Lc_SourceLocIrs_CODE               CHAR(3) = 'IRS',
          @Lc_SourceLocFidm_CODE              CHAR(3) = 'FID',
          @Lc_SourceLocFcr_CODE               CHAR(3) = 'FCR',
          @Lc_SourceLocNdhn_CODE              CHAR(3) = 'NDH',
          @Lc_NcpFather_CODE                  CHAR(3) = 'FTR',
          @Lc_NcpMother_CODE                  CHAR(3) = 'MTR',
          @Lc_StatusComp_CODE                 CHAR(4) = 'COMP',
          @Lc_BatchRunUser_TEXT               CHAR(5) = 'BATCH',
          @Lc_ErrorE0944_CODE                 CHAR(5) = 'E0944',
          @Lc_ActivityMinorAdagr_CODE         CHAR(5) = 'ADAGR',
          @Lc_ActivityMinorAschd_CODE         CHAR(5) = 'ASCHD',
          -- 13747 adding minor activity code = 'ISORD' -START-
          @Lc_ActivityMinorIsord_CODE         CHAR(5) = 'ISORD',
          -- 13747 adding minor activity code = 'ISORD' -END-
          @Lc_Job_ID                          CHAR(7) = 'DEB8088',
          @Lc_LowDate_TEXT                    CHAR(8) = '19000101',
          @Lc_LowDate1_TEXT                   CHAR(8) = '00010101',
          @Lc_Successful_TEXT                 CHAR(20) = 'SUCCESSFUL',
          @Ls_ParmDateProblem_TEXT            VARCHAR(50) = 'PARM DATE PROBLEM',
          @Ls_Process_NAME                    VARCHAR(100) = 'BATCH_FIN_IVE_UPDATES_OUTGOING',
          @Ls_Procedure_NAME                  VARCHAR(100) = 'SP_EXTRACT_IVE_UPDATES',
          @Ld_Low_DATE                        DATE = '01/01/1900',
          @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB                   NUMERIC = 0,
          @Ln_CommitFreqParm_QNTY         NUMERIC(5) = 0,
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(6) = 0,
          @Ln_Error_NUMB                  NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB              NUMERIC(10) = 0,
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_Msg_CODE                    CHAR(1),
          @Ls_File_NAME                   VARCHAR(50),
          @Ls_FileLocation_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLoc_TEXT              VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_BcpCommand_TEXT             VARCHAR(1000),
          @Ls_ErrorMessage_TEXT           VARCHAR(4000),
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Start_DATE                  DATETIME2;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;
   SET @Ld_Start_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ls_Sql_TEXT ='CREATE TEMPORARY TABLE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + @Lc_Job_ID;

   CREATE TABLE ##ExtractIVE_P1
    (
      Seq_IDNO    NUMERIC IDENTITY(1, 1),
      Record_TEXT VARCHAR(474)
    );

   SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT='JOB ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_File_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = @Ls_ParmDateProblem_TEXT;
   SET @Ls_Sqldata_TEXT = ' RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = @Ls_ParmDateProblem_TEXT;

     RAISERROR (50001,16,1);
    END;

   BEGIN TRANSACTION EXTRACTIVE_OUTGOING;

   SET @Ls_Sql_TEXT = 'DELETE FROM EFIVE_Y1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DELETE FROM EFIVE_Y1;

   IF OBJECT_ID('tempdb..#IveCaseMemberDetails_P1') IS NOT NULL
    BEGIN
     DROP TABLE #IveCaseMemberDetails_P1;
    END

   SET @Ls_Sql_TEXT='INSERT INTO EFIVE_Y1 WITH Application status (P - Pending) - 1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   WITH PendingApplication_Status
        AS (SELECT DISTINCT
                   a.Application_IDNO,
                   CAST(a.ChildDfsCase_IDNO AS VARCHAR) AS ChildDfsCase_IDNO,
                   CAST(a.ChildIveParty_IDNO AS VARCHAR) AS ChildIveParty_IDNO,
                   CASE WHEN a.ChildMci_IDNO < 0 
                        THEN 0
                       ELSE CAST(a.ChildMci_IDNO AS VARCHAR)
                   END AS ChildMci_IDNO,
                   CAST(a.ChildSsn_NUMB AS VARCHAR) AS ChildSsn_NUMB,
                   a.Child_NAME,
                   b.CaseRelationship_CODE,
                   a.NcpRelation_CODE,
                   CAST(a.ChildDfsCase_IDNO AS VARCHAR) AS NcpDfsCase_IDNO,
                   CASE WHEN b.MemberMci_IDNO < 0 
                        THEN 0
                       ELSE CAST(b.MemberMci_IDNO AS VARCHAR)
                   END AS NcpMci_IDNO,
                   CAST(ISNULL(c.IveParty_IDNO, 0) AS VARCHAR) AS NcpIveParty_IDNO,
                   SUBSTRING(LTRIM(RTRIM(c.Last_NAME)) + ', ' + LTRIM(RTRIM(c.First_NAME)) + ' ' + LTRIM(RTRIM(c.Middle_NAME)) + ' ' + LTRIM(RTRIM(c.Suffix_NAME)), 1, 24) AS Ncp_NAME,
                   CASE WHEN ISNULL(r.Line1_ADDR, @Lc_Space_TEXT) = @Lc_Space_TEXT 
						THEN @Lc_Space_TEXT
					   ELSE @Lc_CurrentAddress_CODE 
				   END AS NcpAddress_CODE,
				   ISNULL(SUBSTRING(LTRIM(RTRIM(r.Line1_ADDR)), 1, 31), @Lc_Space_TEXT) AS NcpLine1_ADDR,
                   ISNULL(SUBSTRING(LTRIM(RTRIM(r.Line2_ADDR)), 1, 31), @Lc_Space_TEXT) AS NcpLine2_ADDR,
                   ISNULL(SUBSTRING(LTRIM(RTRIM(r.State_ADDR)), 1, 2), @Lc_Space_TEXT) AS NcpState_ADDR,
                   ISNULL(SUBSTRING(LTRIM(RTRIM(r.City_ADDR)), 1, 16), @Lc_Space_TEXT) AS NcpCity_ADDR,
                   ISNULL(REPLACE(r.Zip_ADDR, '-', ''), @Lc_Space_TEXT) AS NcpZip_ADDR,
                   CONVERT(VARCHAR(8), ISNULL(a.NcpDfsCaseOpen_DATE, @Lc_Space_TEXT), 112) AS NcpDfsCaseOpen_DATE
              FROM (SELECT DISTINCT
                           a.Application_IDNO AS Application_IDNO,
                           b.Membermci_IDNo AS ChildMci_IDNO,
                           ISNULL(c.IveParty_IDNO, d.WelfareMemberMci_IDNO) AS ChildIveParty_IDNO,
                           SUBSTRING(LTRIM(RTRIM(c.Last_NAME)) + ', ' + LTRIM(RTRIM(c.First_NAME)) + ' ' + LTRIM(RTRIM(c.Middle_NAME)) + ' ' + LTRIM(RTRIM(c.Suffix_NAME)), 1, 24) AS Child_NAME,
                           c.MemberSsn_NUMB AS ChildSsn_NUMB,
                           d.CaseWelfare_IDNO AS ChildDfsCase_IDNO,
                           b.NcpRelationshipToChild_CODE AS NcpRelation_CODE,
                           d.Begin_DATE AS NcpDfsCaseOpen_DATE
                      FROM APCS_Y1 a,
                           APCM_Y1 b,
                           APDM_Y1 c,
                           APMH_Y1 d
                     WHERE a.TypeCase_CODE IN (@Lc_IVEFosterCareCaseType_CODE, @Lc_NonFederalFosterCareCase_CODE)
                       AND d.TypeWelfare_CODE IN (@Lc_IVEFosterCareCaseType_CODE, @Lc_NonFederalFosterCareCase_CODE)
                       AND a.Application_IDNO = b.Application_IDNO
                       AND a.Application_IDNO = c.Application_IDNO
                       AND a.Application_IDNO = d.Application_IDNO
                       AND b.MemberMci_IDNO = d.MemberMci_IDNO
                       AND b.MemberMci_IDNO = c.MemberMci_IDNO
                       AND b.CaseRelationship_CODE = @Lc_RelationshipCaseDep_CODE
                       AND a.EndValidity_DATE = @Ld_High_DATE
                       AND b.EndValidity_DATE = @Ld_High_DATE
                       AND c.EndValidity_DATE = @Ld_High_DATE
                       AND d.EndValidity_DATE = @Ld_High_DATE
                       AND a.ApplicationStatus_CODE = @Lc_ApplicationFosterPending_CODE
                       AND b.NcpRelationshipToChild_CODE IN (@Lc_NcpFather_CODE, @Lc_NcpMother_CODE)
                       AND a.Application_DATE > @Ld_LastRun_DATE
                       AND d.EndValidity_DATE = @Ld_High_DATE
                       AND a.Application_IDNO NOT IN (SELECT b.Application_IDNO
                                                        FROM APCS_Y1 b
                                                       WHERE b.ApplicationStatus_CODE = @Lc_ApplicationStatusCompleted_CODE)) a,
                   APDM_Y1 c,
                   APCM_Y1 b
                   LEFT JOIN (SELECT j.Application_IDNO,
                                     j.MemberMci_IDNO,
                                     j.Line1_ADDR,
                                     j.Line2_ADDR,
                                     j.State_ADDR,
                                     j.City_ADDR,
                                     j.Zip_ADDR
                                FROM APAH_Y1 j
                               WHERE j.EndValidity_DATE = @Ld_High_DATE)r
                    ON b.Application_IDNO = r.Application_IDNO
                       AND b.MemberMci_IDNO = r.MemberMci_IDNO
             WHERE a.Application_IDNO = c.Application_IDNO
               AND a.Application_IDNO = b.Application_IDNO
               AND c.EndValidity_DATE = @Ld_High_DATE
               AND b.EndValidity_DATE = @Ld_High_DATE
               AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
               AND b.MemberMci_IDNO = c.MemberMci_IDNO)
   INSERT INTO EFIVE_Y1
               (Rec_ID,
                TypeReason_CODE,
                ChildMci_IDNO,
                ChildIveParty_IDNO,
                Child_NAME,
                ChildSsn_NUMB,
                ChildDfsCase_IDNO,
                ApplicationStatus_CODE,
                ChildPaternityEst_INDC,
                PaternityEst_DATE,
                MethodEstablish_CODE,
                CseOrder_DATE,
                MotherCase_IDNO,
                MotherDfsCase_IDNO,
                MotherMci_IDNO,
                MotherIveParty_IDNO,
                Mother_NAME,
                MotherOrder_AMNT,
                MotherPaymentLast_DATE,
                MotherPaymentLast_AMNT,
                MotherAddress_CODE,
                MotherLine1_ADDR,
                MotherLine2_ADDR,
                MotherState_ADDR,
                MotherCity_ADDR,
                MotherZip1_ADDR,
                MotherZip2_ADDR,
                MotherDfsCaseOpen_DATE,
                FatherCase_IDNO,
                FatherDfsCase_IDNO,
                FatherMci_IDNO,
                FatherIveParty_IDNO,
                Father_NAME,
                FatherOrder_AMNT,
                FatherPaymentLast_DATE,
                FatherPaymentLast_AMNT,
                FatherAddress_CODE,
                FatherLine1_ADDR,
                FatherLine2_ADDR,
                FatherState_ADDR,
                FatherCity_ADDR,
                FatherZip1_ADDR,
                FatherZip2_ADDR,
                FatherDfsCaseOpen_DATE)
   SELECT DISTINCT
          @Lc_DetailRecord_CODE AS Rec_ID,
          @Lc_ReasonApplnStatus_CODE AS TypeReason_CODE,
          a.ChildMci_IDNO,
          a.ChildIveParty_IDNO,
          a.Child_NAME,
          a.ChildSsn_NUMB,
          a.ChildDfsCase_IDNO,
          @Lc_ApplicationStatusPending_CODE AS ApplicationStatus_CODE,
          @Lc_Space_TEXT AS ChildPaternityEst_INDC,
          @Lc_Space_TEXT AS PaternityEst_DATE,
          @Lc_Space_TEXT AS MethodEstablish_CODE,
          @Lc_Space_TEXT AS CseOrder_DATE,
          @Lc_Space_TEXT AS MotherCase_IDNO,
          ISNULL(a.NcpDfsCase_IDNO, @Lc_Space_TEXT) AS MotherDfsCase_IDNO,
          ISNULL(a.NcpMci_IDNO, @Lc_Space_TEXT) AS MotherMci_IDNO,
          ISNULL(a.NcpIveParty_IDNO, @Lc_Space_TEXT) AS MotherIveParty_IDNO,
          ISNULL(a.Ncp_NAME, @Lc_Space_TEXT) AS Mother_NAME,
          @Lc_Space_TEXT AS MotherOrder_AMNT,
          @Lc_Space_TEXT AS MotherPaymentLast_DATE,
          @Lc_Space_TEXT AS MotherPaymentLast_AMNT,
          ISNULL(a.NcpAddress_CODE, @Lc_Space_TEXT) AS MotherAddress_CODE,
          ISNULL(a.NcpLine1_ADDR, @Lc_Space_TEXT) AS MotherLine1_ADDR,
          ISNULL(a.NcpLine2_ADDR, @Lc_Space_TEXT) AS MotherLine2_ADDR,
          ISNULL(a.NcpState_ADDR, @Lc_Space_TEXT) AS MotherState_ADDR,
          ISNULL(a.NcpCity_ADDR, @Lc_Space_TEXT) AS MotherCity_ADDR,
          SUBSTRING(ISNULL(a.NcpZip_ADDR, @Lc_Space_TEXT), 1, 5) AS MotherZip1_ADDR,
          SUBSTRING(ISNULL(a.NcpZip_ADDR, @Lc_Space_TEXT), 6, 4) AS MotherZip2_ADDR,
          a.NcpDfsCaseOpen_DATE AS MotherDfsCaseOpen_DATE,
          @Lc_Space_TEXT AS FatherCase_IDNO,
          @Lc_Space_TEXT AS FatherDfsCase_IDNO,
          @Lc_Space_TEXT AS FatherMci_IDNO,
          @Lc_Space_TEXT AS FatherIveParty_IDNO,
          @Lc_Space_TEXT AS Father_NAME,
          @Lc_Space_TEXT AS FatherOrder_AMNT,
          @Lc_Space_TEXT AS FatherPaymentLast_DATE,
          @Lc_Space_TEXT AS FatherPaymentLast_AMNT,
          @Lc_Space_TEXT AS FatherAddress_CODE,
          @Lc_Space_TEXT AS FatherLine1_ADDR,
          @Lc_Space_TEXT AS FatherLine2_ADDR,
          @Lc_Space_TEXT AS FatherState_ADDR,
          @Lc_Space_TEXT AS FatherCity_ADDR,
          @Lc_Space_TEXT AS FatherZip1_ADDR,
          @Lc_Space_TEXT AS FatherZip2_ADDR,
          @Lc_Space_TEXT AS FatherDfsCaseOpen_DATE
     FROM PendingApplication_Status a
    WHERE NcpRelation_CODE = @Lc_NcpMother_CODE
   UNION
   SELECT DISTINCT
          @Lc_DetailRecord_CODE AS Rec_ID,
          @Lc_ReasonApplnStatus_CODE AS TypeReason_CODE,
          b.ChildMci_IDNO,
          b.ChildIveParty_IDNO,
          b.Child_NAME,
          b.ChildSsn_NUMB,
          b.ChildDfsCase_IDNO,
          @Lc_ApplicationStatusPending_CODE AS ApplicationStatus_CODE,
          @Lc_Space_TEXT AS ChildPaternityEst_INDC,
          @Lc_Space_TEXT AS PaternityEst_DATE,
          @Lc_Space_TEXT AS MethodEstablish_CODE,
          @Lc_Space_TEXT AS CseOrder_DATE,
          @Lc_Space_TEXT AS MotherCase_IDNO,
          @Lc_Space_TEXT AS MotherDfsCase_IDNO,
          @Lc_Space_TEXT AS MotherMci_IDNO,
          @Lc_Space_TEXT AS MotherIveParty_IDNO,
          @Lc_Space_TEXT AS Mother_NAME,
          @Lc_Space_TEXT AS MotherOrder_AMNT,
          @Lc_Space_TEXT AS MotherPaymentLast_DATE,
          @Lc_Space_TEXT AS MotherPaymentLast_AMNT,
          @Lc_Space_TEXT AS MotherAddress_CODE,
          @Lc_Space_TEXT AS MotherLine1_ADDR,
          @Lc_Space_TEXT AS MotherLine2_ADDR,
          @Lc_Space_TEXT AS MotherState_ADDR,
          @Lc_Space_TEXT AS MotherCity_ADDR,
          @Lc_Space_TEXT AS MotherZip1_ADDR,
          @Lc_Space_TEXT AS MotherZip2_ADDR,
          @Lc_Space_TEXT AS MotherDfsCaseOpen_DATE,
          @Lc_Space_TEXT AS FatherCase_IDNO,
          ISNULL(b.NcpDfsCase_IDNO, @Lc_Space_TEXT) AS FatherDfsCase_IDNO,
          ISNULL(b.NcpMci_IDNO, @Lc_Space_TEXT) AS FatherMci_IDNO,
          ISNULL(b.NcpIveParty_IDNO, @Lc_Space_TEXT) AS FatherIveParty_IDNO,
          ISNULL(b.Ncp_NAME, @Lc_Space_TEXT) AS Father_NAME,
          @Lc_Space_TEXT AS FatherOrder_AMNT,
          @Lc_Space_TEXT AS FatherPaymentLast_DATE,
          @Lc_Space_TEXT AS FatherPaymentLast_AMNT,
          ISNULL(b.NcpAddress_CODE, @Lc_Space_TEXT) AS FatherAddress_CODE,
          ISNULL(b.NcpLine1_ADDR, @Lc_Space_TEXT) AS FatherLine1_ADDR,
          ISNULL(b.NcpLine2_ADDR, @Lc_Space_TEXT) AS FatherLine2_ADDR,
          ISNULL(b.NcpState_ADDR, @Lc_Space_TEXT) AS FatherState_ADDR,
          ISNULL(b.NcpCity_ADDR, @Lc_Space_TEXT) AS FatherCity_ADDR,
          SUBSTRING(ISNULL(b.NcpZip_ADDR, @Lc_Space_TEXT), 1, 5) AS FatherZip1_ADDR,
          SUBSTRING(ISNULL(b.NcpZip_ADDR, @Lc_Space_TEXT), 6, 4) AS FatherZip2_ADDR,
          b.NcpDfsCaseOpen_DATE AS FatherDfsCaseOpen_DATE
     FROM PendingApplication_Status b
    WHERE NcpRelation_CODE = @Lc_NcpFather_CODE

   SET @Ls_Sql_TEXT = 'INSERT EFIVE_Y1 TABLE Application Status - 2';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   WITH Application_Status
        AS (SELECT @Lc_DetailRecord_CODE AS Rec_ID,
                   @Lc_ReasonApplnStatus_CODE AS ReasonStatus_CODE,
                   CAST(ChildMci_IDNO AS VARCHAR) AS ChildMci_IDNO,
                   CAST(ChildIveParty_IDNO AS VARCHAR) AS ChildIveParty_IDNO,
                   Child_NAME,
                   CAST(ChildSsn_NUMB AS VARCHAR) AS ChildSsn_NUMB,
                   CAST(ChildDfsCase_IDNO AS VARCHAR) AS ChildDfsCase_IDNO,
                   CASE
                    WHEN a.Opened_DATE > @Ld_LastRun_DATE
                         AND a.Opened_DATE <= @Ld_Run_DATE
                     THEN @Lc_ApplicationStatusCreated_CODE
                    -- 13747 Checking if any order established -START- 
                    WHEN EXISTS (SELECT 1
                                   FROM DMNR_Y1 n
                                  WHERE n.Case_IDNO = c.Case_IDNO
                                    AND n.Status_DATE > @Ld_LastRun_DATE
                                    AND n.Status_CODE = @Lc_StatusComp_CODE
                                    AND n.ActivityMinor_CODE = @Lc_ActivityMinorIsord_CODE)
					-- 13747 Checking if any order established -END- 
                     THEN @Lc_ApplicationStatusOrderEst_CODE                     
                    WHEN EXISTS (SELECT 1
                                   FROM DMNR_Y1 n
                                  WHERE n.Case_IDNO = c.Case_IDNO
                                    AND n.MemberMci_IDNO = d.MemberMci_IDNO
                                    AND n.Status_DATE > @Ld_LastRun_DATE
                                    AND n.Status_CODE = @Lc_StatusComp_CODE
                                    AND n.ActivityMinor_CODE = @Lc_ActivityMinorAschd_CODE
                                    AND n.ReasonStatus_CODE = @Lc_FiledPetitionReasonCg_CODE)
                     THEN @Lc_ApplicationStatusScheduled_CODE
                    WHEN EXISTS (SELECT 1
                                   FROM DMNR_Y1 n
                                  WHERE n.Case_IDNO = c.Case_IDNO
                                    AND n.MemberMci_IDNO = d.MemberMci_IDNO
                                    AND n.Status_DATE > @Ld_LastRun_DATE
                                    AND n.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                    AND n.ReasonStatus_CODE = @Lc_FiledPetitionReasonPj_CODE)
                     THEN @Lc_ApplicationStatusFiledPet_CODE
                    WHEN ((ISNULL(PaternityEst_DATE, @Ld_Low_DATE) > @Ld_LastRun_DATE
                            OR EXISTS (SELECT 1
                                         FROM MPAT_Y1 m,
                                              HMPAT_Y1 h
                                        WHERE m.MemberMci_IDNO = a.ChildMci_IDNO
                                          AND m.MemberMci_IDNO = h.MemberMci_IDNO
                                          AND m.PaternityEst_DATE <> h.PaternityEst_DATE
                                          AND h.EndValidity_DATE > @Ld_LastRun_DATE
                                          AND h.EndValidity_DATE <= @Ld_Run_DATE))
                           OR ((EXISTS (SELECT 1
                                          FROM MPAT_Y1 m
                                         WHERE m.MemberMci_IDNO = a.ChildMci_IDNO
                                           AND m.Disestablish_DATE > @Ld_LastRun_DATE))
                                OR (EXISTS (SELECT 1
                                              FROM MPAT_Y1 m,
                                                   HMPAT_Y1 h
                                             WHERE m.MemberMci_IDNO = a.ChildMci_IDNO
                                               AND m.MemberMci_IDNO = h.MemberMci_IDNO
                                               AND m.Disestablish_DATE <> h.Disestablish_DATE
                                               AND h.EndValidity_DATE > @Ld_LastRun_DATE
                                               AND h.EndValidity_DATE <= @Ld_Run_DATE))))
                     THEN @Lc_ApplicationStatusEstPater_CODE
                   END AS ApplicationStatus_CODE,
                   CAST(a.ChildPaternityEst_INDC AS VARCHAR) AS ChildPaternityEst_INDC,
                   CONVERT(VARCHAR(8), ISNULL(a.PaternityEst_DATE, @Lc_Space_TEXT), 112) AS PaternityEst_DATE,
                   CAST(a.MethodEstablish_CODE AS VARCHAR) AS MethodEstablish_CODE,
                   CONVERT(VARCHAR(8), ISNULL(sr.OrderEffective_DATE, @Ld_Low_DATE), 112) AS CseOrder_DATE,
                   CAST(c.Case_IDNO AS VARCHAR) AS NcpCase_IDNO,
                   CAST(a.ChildDfsCase_IDNO AS VARCHAR) AS NcpDfsCase_IDNO,
                   CAST(d.MemberMci_IDNO AS VARCHAR) AS NcpMci_IDNO,
                   CAST(d.IveParty_IDNO AS VARCHAR) AS NcpIveParty_IDNO,
                   SUBSTRING(LTRIM(RTRIM(d.Last_NAME)) + ', ' + LTRIM(RTRIM(d.First_NAME)) + ' ' + LTRIM(RTRIM(d.Middle_NAME)) + ' ' + LTRIM(RTRIM(d.Suffix_NAME)), 1, 24) AS Ncp_NAME,
                   CAST(ISNULL(o.Order_AMNT, '0.00') AS VARCHAR(12)) AS NcpOrder_AMNT,
                   CONVERT(VARCHAR(8), ISNULL(r.Receipt_DATE, @Lc_Space_TEXT), 112) AS NcpPaymentLast_DATE,
                   CAST(ISNULL(r.Receipt_AMNT, '0.00') AS VARCHAR(12)) AS NcpPaymentLast_AMNT,
                   CASE
                    WHEN h.Status_CODE = @Lc_AddressConfimedStatus_CODE
                     THEN @Lc_CurrentAddress_CODE
                    WHEN h.Status_CODE = @Lc_AddrresPendingStatus_CODE
                     THEN @Lc_LastKnownAddress_CODE
                    ELSE @Lc_Space_TEXT
                   END AS NcpAddress_CODE,
                   ISNULL(SUBSTRING(h.Line1_ADDR, 1, 31), @Lc_Space_TEXT) AS NcpLine1_ADDR,
                   ISNULL(SUBSTRING(h.Line2_ADDR, 1, 31), @Lc_Space_TEXT) AS NcpLine2_ADDR,
                   ISNULL(SUBSTRING(h.City_ADDR, 1, 16), @Lc_Space_TEXT) AS NcpCity_ADDR,
                   ISNULL(SUBSTRING(h.State_ADDR, 1, 2), @Lc_Space_TEXT) AS NcpState_ADDR,
                   ISNULL(h.Zip_ADDR, @Lc_Space_TEXT) AS NcpZip_ADDR,
                   CONVERT(VARCHAR(8), a.Start_DATE, 112) AS NcpDfsCaseOpen_DATE,
                   a.NcpRelationshipToChild_CODE
              FROM (SELECT m.MemberMci_IDNO AS ChildMci_IDNO,
                           d.IveParty_IDNO AS ChildIveParty_IDNO,
                           SUBSTRING(LTRIM(RTRIM(d.Last_NAME)) + ', ' + LTRIM(RTRIM(d.First_NAME)) + ' ' + LTRIM(RTRIM(d.Middle_NAME)) + ' ' + LTRIM(RTRIM(d.Suffix_NAME)), 1, 24) AS Child_NAME,
                           d.MemberSsn_NUMB AS ChildSsn_NUMB,
                           s.CaseWelfare_IDNO AS ChildDfsCase_IDNO,
                           ISNULL(p.PaternityEst_INDC, @Lc_Space_TEXT) AS ChildPaternityEst_INDC,
                           ISNULL(p.PaternityEst_DATE, @Ld_Low_DATE) AS PaternityEst_DATE,
                           CASE ISNULL(p.PaternityEst_CODE, @Lc_Space_TEXT)
                            WHEN @Lc_Space_TEXT
                             THEN @Lc_Space_TEXT
                            WHEN @Lc_DacesMethodEstablishBc_CODE
                             THEN @Lc_FactsMethodEstablishAo_CODE
                            WHEN @Lc_DacesMethodEstablishOt_CODE
                             THEN @Lc_FactsMethodEstablishUk_CODE
                            WHEN @Lc_DacesMethodEstablishCs_CODE
                             THEN @Lc_FactsMethodEstablishCo_CODE
                            WHEN @Lc_DacesMethodEstablishCu_CODE
                             THEN @Lc_FactsMethodEstablishUk_CODE
                            WHEN @Lc_DacesMethodEstablishPd_CODE
                             THEN @Lc_FactsMethodEstablishCj_CODE
                            WHEN @Lc_DacesMethodEstablishVp_CODE
                             THEN @Lc_FactsMethodEstablishAh_CODE
                            ELSE ISNULL(p.PaternityEst_CODE, @Lc_Space_TEXT)
                           END AS MethodEstablish_CODE,
                           s.Start_DATE,
                           s.Case_IDNO,
                           m.NcpRelationshipToChild_CODE,
                           e.Opened_DATE
                      FROM CMEM_Y1 m,
                           MHIS_Y1 s,
                           CASE_Y1 e,
                           DEMO_Y1 d
                           LEFT JOIN MPAT_Y1 p
                            ON p.MemberMci_IDNO = d.MemberMci_IDNO
                     WHERE s.MemberMci_IDNO = d.MemberMci_IDNO
                       AND m.Case_IDNO = s.Case_IDNO
                       AND m.MemberMci_IDNO = d.MemberMci_IDNO
                       AND m.CaseRelationship_CODE = @Lc_RelationshipCaseDep_CODE
                       AND m.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
                       AND m.NcpRelationshipToChild_CODE IN (@Lc_NcpMother_CODE, @Lc_NcpFather_CODE)
                       AND m.Case_IDNO = e.Case_IDNO
                       AND s.End_DATE = @Ld_High_DATE
                       AND e.TypeCase_CODE IN (@Lc_IVEFosterCareCaseType_CODE, @Lc_NonFederalFosterCareCase_CODE)) a
                   LEFT JOIN (SELECT c.Case_IDNO,
                                     c.MemberMci_IDNO,
                                     c.Periodic_AMNT AS Order_AMNT
                                FROM OBLE_Y1 c
                               WHERE c.TypeDebt_CODE = @Lc_ChildSupportType_CODE
                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                 AND c.EndObligation_DATE = @Ld_High_DATE) o
                    ON a.Case_IDNO = o.Case_IDNO 
                       AND a.ChildMci_IDNO = o.MemberMci_IDNO,                       
                   CMEM_Y1 c
                   LEFT JOIN (SELECT a.NcpPf_IDNO AS PayorMci_IDNO,
                                     a.Case_IDNO,
                                     a.ReceiptLast_DATE AS Receipt_DATE,
                                     a.PaymentLastReceived_AMNT AS Receipt_AMNT
                                FROM ENSD_Y1 a
							  ) r
                    ON c.MemberMci_IDNO = r.PayorMci_IDNO
                       AND c.Case_IDNO = r.Case_IDNO,
                   CASE_Y1 s
                   LEFT JOIN SORD_Y1 sr
                    ON sr.Case_IDNO = s.Case_IDNO
                       AND sr.EndValidity_DATE = @Ld_High_DATE,
                   DEMO_Y1 d
                   LEFT JOIN (SELECT MemberMci_IDNO,
                                     TypeAddress_CODE,
                                     Begin_DATE,
                                     End_DATE,
                                     Line1_ADDR,
                                     Line2_ADDR,
                                     City_ADDR,
                                     State_ADDR,
                                     Zip_ADDR,
                                     Status_CODE
                                FROM AHIS_Y1 a
                               WHERE @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                 AND Status_CODE = @Lc_AddressConfimedStatus_CODE
                                 AND TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                 AND SourceLoc_CODE IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE)
                                 AND TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                                   FROM AHIS_Y1 x
                                                                  WHERE a.MemberMci_IDNO = x.MemberMci_IDNO
                                                                    AND x.TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                                                    AND x.Status_CODE = @Lc_AddressConfimedStatus_CODE
                                                                    AND SourceLoc_CODE IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE)
                                                                    AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE)
                              UNION
                              SELECT MemberMci_IDNO,
                                     TypeAddress_CODE,
                                     Begin_DATE,
                                     End_DATE,
                                     Line1_ADDR,
                                     Line2_ADDR,
                                     City_ADDR,
                                     State_ADDR,
                                     Zip_ADDR,
                                     Status_CODE
                                FROM AHIS_Y1 a
                               WHERE @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                 AND Status_CODE IN (@Lc_AddrresPendingStatus_CODE, @Lc_AddressConfimedStatus_CODE)
                                 AND TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                 AND SourceLoc_CODE NOT IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE)
                                 AND MemberMci_IDNO NOT IN (SELECT MEMBERMCI_IDNO
                                                              FROM AHIS_Y1 b
                                                             WHERE @Ld_Run_DATE BETWEEN b.Begin_DATE AND b.End_DATE
                                                               AND b.Status_CODE = @Lc_AddressConfimedStatus_CODE
                                                               AND b.MemberMci_IDNO = a.MemberMci_IDNO
                                                               AND b.TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                                               AND b.SourceLoc_CODE IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE))
                                 AND TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                                   FROM AHIS_Y1 x
                                                                  WHERE a.MemberMci_IDNO = x.MemberMci_IDNO
                                                                    AND x.TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                                                    AND Status_CODE IN (@Lc_AddrresPendingStatus_CODE, @Lc_AddressConfimedStatus_CODE)
                                                                    AND SourceLoc_CODE NOT IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE)
                                                                    AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE)) h
                    ON d.MemberMci_IDNO = h.MemberMci_IDNO
             WHERE c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
               AND c.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
               AND s.StatusCase_CODE = @Lc_StatusOpen_CODE
               AND s.Case_IDNO = c.Case_IDNO
               AND a.Case_IDNO = c.Case_IDNO
               AND d.MemberMci_IDNO = c.MemberMci_IDNO
               AND s.TypeCase_CODE IN (@Lc_IVEFosterCareCaseType_CODE, @Lc_NonFederalFosterCareCase_CODE)
               AND ((a.Opened_DATE > @Ld_LastRun_DATE
                     AND a.Opened_DATE <= @Ld_Run_DATE)
                     OR (EXISTS (SELECT 1
                                   FROM DMNR_Y1 n
                                  WHERE N.Case_IDNO = c.Case_IDNO
                                    AND N.MemberMci_IDNO = d.MemberMci_IDNO
                                    AND N.Status_DATE > @Ld_LastRun_DATE
                                    AND N.ActivityMinor_CODE = @Lc_ActivityMinorAdagr_CODE
                                    AND N.ReasonStatus_CODE = @Lc_FiledPetitionReasonPj_CODE))
                     OR (EXISTS (SELECT 1
                                   FROM DMNR_Y1 n
                                  WHERE n.Case_IDNO = c.Case_IDNO
                                    AND n.MemberMci_IDNO = d.MemberMci_IDNO
                                    AND n.Status_DATE > @Ld_LastRun_DATE
                                    AND n.Status_CODE = @Lc_StatusComp_CODE
                                    AND n.ActivityMinor_CODE = @Lc_ActivityMinorAschd_CODE
                                    AND n.ReasonStatus_CODE = @Lc_FiledPetitionReasonCg_CODE))
                     -- 13747 Checking if any order established -START- 
                     OR (EXISTS (SELECT 1
                                   FROM DMNR_Y1 n
                                  WHERE n.Case_IDNO = c.Case_IDNO
                                    AND n.Status_DATE > @Ld_LastRun_DATE
                                    AND n.Status_CODE = @Lc_StatusComp_CODE
                                    AND n.ActivityMinor_CODE = @Lc_ActivityMinorIsord_CODE))
					 -- 13747 Checking if any order established -END-                                     
                     OR ((PaternityEst_DATE > @Ld_LastRun_DATE
                           OR EXISTS (SELECT 1
                                        FROM MPAT_Y1 m,
                                             HMPAT_Y1 h
                                       WHERE m.MemberMci_IDNO = a.ChildMci_IDNO
                                         AND m.MemberMci_IDNO = h.MemberMci_IDNO
                                         AND m.PaternityEst_DATE <> h.PaternityEst_DATE
                                         AND h.EndValidity_DATE > @Ld_LastRun_DATE
                                         AND h.EndValidity_DATE <= @Ld_Run_DATE))
                          OR ((EXISTS (SELECT 1
                                         FROM MPAT_Y1 m
                                        WHERE m.MemberMci_IDNO = a.ChildMci_IDNO
                                          AND m.Disestablish_DATE > @Ld_LastRun_DATE))
                               OR (EXISTS (SELECT 1
                                             FROM MPAT_Y1 m,
                                                  HMPAT_Y1 h
                                            WHERE m.MemberMci_IDNO = a.ChildMci_IDNO
                                              AND m.MemberMci_IDNO = h.MemberMci_IDNO
                                              AND m.Disestablish_DATE <> h.Disestablish_DATE
                                              AND h.EndValidity_DATE > @Ld_LastRun_DATE
                                              AND h.EndValidity_DATE <= @Ld_Run_DATE))))))
   INSERT INTO EFIVE_Y1
               (Rec_ID,
                TypeReason_CODE,
                ChildMci_IDNO,
                ChildIveParty_IDNO,
                Child_NAME,
                ChildSsn_NUMB,
                ChildDfsCase_IDNO,
                ApplicationStatus_CODE,
                ChildPaternityEst_INDC,
                PaternityEst_DATE,
                MethodEstablish_CODE,
                CseOrder_DATE,
                MotherCase_IDNO,
                MotherDfsCase_IDNO,
                MotherMci_IDNO,
                MotherIveParty_IDNO,
                Mother_NAME,
                MotherOrder_AMNT,
                MotherPaymentLast_DATE,
                MotherPaymentLast_AMNT,
                MotherAddress_CODE,
                MotherLine1_ADDR,
                MotherLine2_ADDR,
                MotherState_ADDR,
                MotherCity_ADDR,
                MotherZip1_ADDR,
                MotherZip2_ADDR,
                MotherDfsCaseOpen_DATE,
                FatherCase_IDNO,
                FatherDfsCase_IDNO,
                FatherMci_IDNO,
                FatherIveParty_IDNO,
                Father_NAME,
                FatherOrder_AMNT,
                FatherPaymentLast_DATE,
                FatherPaymentLast_AMNT,
                FatherAddress_CODE,
                FatherLine1_ADDR,
                FatherLine2_ADDR,
                FatherState_ADDR,
                FatherCity_ADDR,
                FatherZip1_ADDR,
                FatherZip2_ADDR,
                FatherDfsCaseOpen_DATE)
   SELECT DISTINCT
          a.Rec_ID,
          a.ReasonStatus_CODE,
          a.ChildMci_IDNO AS ChildMci_IDNO,
          a.ChildIveParty_IDNO AS ChildIveParty_IDNO,
          a.Child_NAME AS Child_NAME,
          a.ChildSsn_NUMB AS ChildSsn_NUMB,
          a.ChildDfsCase_IDNO AS ChildDfsCase_IDNO,
          a.ApplicationStatus_CODE AS ApplicationStatus_CODE,
          a.ChildPaternityEst_INDC AS ChildPaternityEst_INDC,
          a.PaternityEst_DATE AS PaternityEst_DATE,
          a.MethodEstablish_CODE AS MethodEstablish_CODE,
          a.CseOrder_DATE AS CseOrder_DATE,
          a.NcpCase_IDNO AS MotherCase_IDNO,
          a.NcpDfsCase_IDNO AS MotherDfsCase_IDNO,
          a.NcpMci_IDNO AS MotherMci_IDNO,
          a.NcpIveParty_IDNO AS MotherIveParty_IDNO,
          a.Ncp_NAME AS Mother_NAME,
          a.NcpOrder_AMNT AS MotherOrder_AMNT,
          a.NcpPaymentLast_DATE AS MotherPaymentLast_DATE,
          a.NcpPaymentLast_AMNT AS MotherPaymentLast_AMNT,
          a.NcpAddress_CODE AS MotherAddress_CODE,
          a.NcpLine1_ADDR AS MotherLine1_ADDR,
          a.NcpLine2_ADDR AS MotherLine2_ADDR,
          a.NcpState_ADDR AS MotherState_ADDR,
          a.NcpCity_ADDR AS MotherCity_ADDR,
          SUBSTRING(a.NcpZip_ADDR, 1, 5) AS MotherZip1_ADDR,
          SUBSTRING(a.NcpZip_ADDR, 6, 4) AS MotherZip2_ADDR,
          a.NcpDfsCaseOpen_DATE AS MotherDfsCaseOpen_DATE,
          @Lc_Space_TEXT AS FatherCase_IDNO,
          @Lc_Space_TEXT AS FatherDfsCase_IDNO,
          @Lc_Space_TEXT AS FatherMci_IDNO,
          @Lc_Space_TEXT AS FatherIveParty_IDNO,
          @Lc_Space_TEXT AS Father_NAME,
          @Lc_Space_TEXT AS FatherOrder_AMNT,
          @Lc_Space_TEXT AS FatherPaymentLast_DATE,
          @Lc_Space_TEXT AS FatherPaymentLast_AMNT,
          @Lc_Space_TEXT AS FatherAddress_CODE,
          @Lc_Space_TEXT AS FatherLine1_ADDR,
          @Lc_Space_TEXT AS FatherLine2_ADDR,
          @Lc_Space_TEXT AS FatherState_ADDR,
          @Lc_Space_TEXT AS FatherCity_ADDR,
          @Lc_Space_TEXT AS FatherZip1_ADDR,
          @Lc_Space_TEXT AS FatherZip2_ADDR,
          @Lc_Space_TEXT AS FatherDfsCaseOpen_DATE
     FROM Application_Status a
    WHERE a.NcpRelationshipToChild_CODE = @Lc_NcpMother_CODE
   UNION
   SELECT DISTINCT
          a.Rec_ID,
          a.ReasonStatus_CODE,
          a.ChildMci_IDNO AS ChildMci_IDNO,
          a.ChildIveParty_IDNO AS ChildIveParty_IDNO,
          a.Child_NAME AS Child_NAME,
          a.ChildSsn_NUMB AS ChildSsn_NUMB,
          a.ChildDfsCase_IDNO AS ChildDfsCase_IDNO,
          a.ApplicationStatus_CODE AS ApplicationStatus_CODE,
          a.ChildPaternityEst_INDC AS ChildPaternityEst_INDC,
          a.PaternityEst_DATE AS PaternityEst_DATE,
          a.MethodEstablish_CODE AS MethodEstablish_CODE,
          a.CseOrder_DATE AS CseOrder_DATE,
          @Lc_Space_TEXT AS MotherCase_IDNO,
          @Lc_Space_TEXT AS MotherDfsCase_IDNO,
          @Lc_Space_TEXT AS MotherMci_IDNO,
          @Lc_Space_TEXT AS MotherIveParty_IDNO,
          @Lc_Space_TEXT AS Mother_NAME,
          @Lc_Space_TEXT AS MotherOrder_AMNT,
          @Lc_Space_TEXT AS MotherPaymentLast_DATE,
          @Lc_Space_TEXT AS MotherPaymentLast_AMNT,
          @Lc_Space_TEXT AS MotherAddress_CODE,
          @Lc_Space_TEXT AS MotherLine1_ADDR,
          @Lc_Space_TEXT AS MotherLine2_ADDR,
          @Lc_Space_TEXT AS MotherState_ADDR,
          @Lc_Space_TEXT AS MotherCity_ADDR,
          @Lc_Space_TEXT AS MotherZip1_ADDR,
          @Lc_Space_TEXT AS MotherZip2_ADDR,
          @Lc_Space_TEXT AS MotherDfsCaseOpen_DATE,
          a.NcpCase_IDNO AS FatherCase_IDNO,
          a.NcpDfsCase_IDNO AS FatherDfsCase_IDNO,
          a.NcpMci_IDNO AS FatherMci_IDNO,
          a.NcpIveParty_IDNO AS FatherIveParty_IDNO,
          a.Ncp_NAME AS Father_NAME,
          a.NcpOrder_AMNT AS FatherOrder_AMNT,
          a.NcpPaymentLast_DATE AS FatherPaymentLast_DATE,
          a.NcpPaymentLast_AMNT AS FatherPaymentLast_AMNT,
          a.NcpAddress_CODE AS FatherAddress_CODE,
          a.NcpLine1_ADDR AS FatherLine1_ADDR,
          a.NcpLine2_ADDR AS FatherLine2_ADDR,
          a.NcpState_ADDR AS FatherState_ADDR,
          a.NcpCity_ADDR AS FatherCity_ADDR,
          SUBSTRING(a.NcpZip_ADDR, 1, 5) AS FatherZip1_ADDR,
          SUBSTRING(a.NcpZip_ADDR, 6, 4) AS FatherZip2_ADDR,
          a.NcpDfsCaseOpen_DATE AS FatherDfsCaseOpen_DATE
     FROM Application_Status a
    WHERE a.NcpRelationshipToChild_CODE = @Lc_NcpFather_CODE

   SET @Ls_Sql_TEXT = 'INSERT EFIVE_Y1 TABLE - 3 ';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   WITH Ive_Case_Member_Details
        AS (SELECT a.ChildMci_IDNO,
                   a.ChildIveParty_IDNO,
                   a.Child_NAME,
                   a.ChildSsn_NUMB,
                   a.ChildDfsCase_IDNO,
                   a.ChildPaternityEst_INDC,
                   a.PaternityEst_DATE,
                   a.MethodEstablish_CODE,
                   ISNULL(sr.OrderEffective_DATE, @Ld_Low_DATE) AS CseOrder_DATE,
                   a.NcpRelationshipToChild_CODE,
                   c.Case_IDNO AS NcpCase_IDNO,
                   a.ChildDfsCase_IDNO AS NcpDfsCase_IDNO,
                   d.MemberMci_IDNO AS NcpMci_IDNO,
                   d.IveParty_IDNO AS NcpIveParty_IDNO,
                   SUBSTRING(LTRIM(RTRIM(d.Last_NAME)) + ', ' + LTRIM(RTRIM(d.First_NAME)) + ' ' + LTRIM(RTRIM(d.Middle_NAME)) + ' ' + LTRIM(RTRIM(d.Suffix_NAME)), 1, 24) AS Ncp_NAME,
                   o.Order_AMNT AS NcpOrder_AMNT,
                   r.Receipt_DATE AS NcpPaymentLast_DATE,
                   r.Receipt_AMNT AS NcpPaymentLast_AMNT,
                   CASE
                    WHEN h.Status_CODE = @Lc_AddressConfimedStatus_CODE
                     THEN @Lc_CurrentAddress_CODE
                    WHEN h.Status_CODE = @Lc_AddrresPendingStatus_CODE
                     THEN @Lc_LastKnownAddress_CODE
                    ELSE @Lc_Space_TEXT
                   END AS NcpAddress_CODE,
                   h.Line1_ADDR AS NcpLine1_ADDR,
                   h.Line2_ADDR AS NcpLine2_ADDR,
                   h.City_ADDR AS NcpCity_ADDR,
                   h.State_ADDR AS NcpState_ADDR,
                   h.Zip_ADDR AS NcpZip_ADDR,
                   a.Start_DATE AS NcpDfsCaseOpen_DATE
              FROM (SELECT m.MemberMci_IDNO AS ChildMci_IDNO,
                           d.IveParty_IDNO AS ChildIveParty_IDNO,
                           SUBSTRING(LTRIM(RTRIM(d.Last_NAME)) + ', ' + LTRIM(RTRIM(d.First_NAME)) + ' ' + LTRIM(RTRIM(d.Middle_NAME)) + ' ' + LTRIM(RTRIM(d.Suffix_NAME)), 1, 24) AS Child_NAME,
                           d.MemberSsn_NUMB AS ChildSsn_NUMB,
                           s.CaseWelfare_IDNO AS ChildDfsCase_IDNO,
                           ISNULL(p.PaternityEst_INDC, @Lc_Space_TEXT) AS ChildPaternityEst_INDC,
                           ISNULL(p.PaternityEst_DATE, @Ld_Low_DATE) AS PaternityEst_DATE,
                           CASE ISNULL(p.PaternityEst_CODE, @Lc_Space_TEXT)
                            WHEN @Lc_Space_TEXT
                             THEN @Lc_Space_TEXT
                            WHEN @Lc_DacesMethodEstablishBc_CODE
                             THEN @Lc_FactsMethodEstablishAo_CODE
                            WHEN @Lc_DacesMethodEstablishOt_CODE
                             THEN @Lc_FactsMethodEstablishUk_CODE
                            WHEN @Lc_DacesMethodEstablishCs_CODE
                             THEN @Lc_FactsMethodEstablishCo_CODE
                            WHEN @Lc_DacesMethodEstablishCu_CODE
                             THEN @Lc_FactsMethodEstablishUk_CODE
                            WHEN @Lc_DacesMethodEstablishPd_CODE
                             THEN @Lc_FactsMethodEstablishCj_CODE
                            WHEN @Lc_DacesMethodEstablishVp_CODE
                             THEN @Lc_FactsMethodEstablishAh_CODE
                            ELSE ISNULL(p.PaternityEst_CODE, @Lc_Space_TEXT)
                           END AS MethodEstablish_CODE,
                           s.Start_DATE,
                           s.Case_IDNO,
                           NcpRelationshipToChild_CODE
                      FROM CMEM_Y1 m,
                           MHIS_Y1 s,
                           CASE_Y1 e,
                           DEMO_Y1 d
                           LEFT JOIN MPAT_Y1 p
                            ON p.MemberMci_IDNO = d.MemberMci_IDNO
                     WHERE s.MemberMci_IDNO = d.MemberMci_IDNO
                       AND m.Case_IDNO = s.Case_IDNO
                       AND m.MemberMci_IDNO = d.MemberMci_IDNO
                       AND m.CaseRelationship_CODE = @Lc_RelationshipCaseDep_CODE
                       AND m.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
                       AND m.Case_IDNO = e.Case_IDNO
                       AND s.End_DATE = @Ld_High_DATE
                       AND e.TypeCase_CODE IN (@Lc_IVEFosterCareCaseType_CODE, @Lc_NonFederalFosterCareCase_CODE)) a
                   LEFT JOIN (SELECT c.Case_IDNO,
                                     c.MemberMci_IDNO,
                                     c.Periodic_AMNT AS Order_AMNT
                                FROM OBLE_Y1 c
                               WHERE c.TypeDebt_CODE = @Lc_ChildSupportType_CODE
                                 AND c.EndValidity_DATE = @Ld_High_DATE
                                 AND c.EndObligation_DATE = @Ld_High_DATE) o
                    ON a.Case_IDNO = o.Case_IDNO 
                       AND a.ChildMci_IDNO = o.MemberMci_IDNO,                        
                   CMEM_Y1 c
                   LEFT JOIN (SELECT a.NcpPf_IDNO AS PayorMci_IDNO,
                                     a.Case_IDNO,
                                     a.ReceiptLast_DATE AS Receipt_DATE,
                                     a.PaymentLastReceived_AMNT AS Receipt_AMNT
                                FROM ENSD_Y1 a
							  ) r
                    ON c.MemberMci_IDNO = r.PayorMci_IDNO
                       AND c.Case_IDNO = r.Case_IDNO,
                   CASE_Y1 s
                   LEFT JOIN SORD_Y1 sr
                    ON sr.Case_IDNO = s.Case_IDNO
                       AND sr.EndValidity_DATE = @Ld_High_DATE,
                   DEMO_Y1 d
                   LEFT JOIN (SELECT MemberMci_IDNO,
                                     TypeAddress_CODE,
                                     Begin_DATE,
                                     End_DATE,
                                     Line1_ADDR,
                                     Line2_ADDR,
                                     City_ADDR,
                                     State_ADDR,
                                     Zip_ADDR,
                                     Status_CODE
                                FROM AHIS_Y1 a
                               WHERE @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                 AND Status_CODE = @Lc_AddressConfimedStatus_CODE
                                 AND TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                 AND SourceLoc_CODE IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE)
                                 AND TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                                   FROM AHIS_Y1 x
                                                                  WHERE a.MemberMci_IDNO = x.MemberMci_IDNO
                                                                    AND x.TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                                                    AND x.Status_CODE = @Lc_AddressConfimedStatus_CODE
                                                                    AND SourceLoc_CODE IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE)
                                                                    AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE)
                              UNION
                              SELECT MemberMci_IDNO,
                                     TypeAddress_CODE,
                                     Begin_DATE,
                                     End_DATE,
                                     Line1_ADDR,
                                     Line2_ADDR,
                                     City_ADDR,
                                     State_ADDR,
                                     Zip_ADDR,
                                     Status_CODE
                                FROM AHIS_Y1 a
                               WHERE @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
                                 AND Status_CODE IN (@Lc_AddrresPendingStatus_CODE, @Lc_AddressConfimedStatus_CODE)
                                 AND TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                 AND SourceLoc_CODE NOT IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE)
                                 AND MEMBERMCI_IDNO NOT IN (SELECT MEMBERMCI_IDNO
                                                              FROM AHIS_Y1 b
                                                             WHERE @Ld_Run_DATE BETWEEN b.Begin_DATE AND b.End_DATE
                                                               AND b.Status_CODE = @Lc_AddressConfimedStatus_CODE
                                                               AND b.MemberMci_IDNO = a.MemberMci_IDNO
                                                               AND b.TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                                               AND b.SourceLoc_CODE IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE))
                                 AND TransactionEventSeq_NUMB = (SELECT MAX(TransactionEventSeq_NUMB)
                                                                   FROM AHIS_Y1 x
                                                                  WHERE a.MemberMci_IDNO = x.MemberMci_IDNO
                                                                    AND x.TypeAddress_CODE IN (@Lc_MailingAddress_CODE, @Lc_ResidAddress_CODE)
                                                                    AND Status_CODE IN (@Lc_AddrresPendingStatus_CODE, @Lc_AddressConfimedStatus_CODE)
                                                                    AND SourceLoc_CODE NOT IN (@Lc_SourceLocIrs_CODE, @Lc_SourceLocFidm_CODE, @Lc_SourceLocFcr_CODE, @Lc_SourceLocNdhn_CODE)
                                                                    AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE)) h
                    ON d.MemberMci_IDNO = h.MemberMci_IDNO
             WHERE c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
               AND c.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
               AND s.Case_IDNO = c.Case_IDNO
               AND a.Case_IDNO = c.Case_IDNO
               AND d.MemberMci_IDNO = c.MemberMci_IDNO
               AND ( s.StatusCase_CODE = @Lc_Statusopen_CODE
                     OR (s.StatusCase_CODE = @Lc_StatusClosed_CODE
						 AND s.StatusCurrent_DATE > @Ld_LastRun_DATE
						 AND s.StatusCurrent_DATE <= @Ld_Run_DATE)
					)
               AND s.TypeCase_CODE IN (@Lc_IVEFosterCareCaseType_CODE, @Lc_NonFederalFosterCareCase_CODE))
   SELECT CAST(ChildMci_IDNO AS VARCHAR) AS ChildMci_IDNO,
          CAST(ChildIveParty_IDNO AS VARCHAR) AS ChildIveParty_IDNO,
          SUBSTRING(Child_NAME, 1, 24) AS Child_NAME,
          CAST(ChildSsn_NUMB AS VARCHAR) AS ChildSsn_NUMB,
          CAST(ChildDfsCase_IDNO AS VARCHAR) AS ChildDfsCase_IDNO,
          ISNULL(ChildPaternityEst_INDC, @Lc_Space_TEXT) AS ChildPaternityEst_INDC,
          CONVERT(CHAR, ISNULL(PaternityEst_DATE, @Lc_Space_TEXT), 112) AS PaternityEst_DATE,
          ISNULL(MethodEstablish_CODE, @Lc_Space_TEXT) AS MethodEstablish_CODE,
          CONVERT(CHAR, ISNULL(CseOrder_DATE, @Lc_Space_TEXT), 112) AS CseOrder_DATE,
          CAST(ISNULL(MotherCase_IDNO, @Ln_Zero_NUMB) AS VARCHAR) AS MotherCase_IDNO,
          CAST(ISNULL(MotherDfsCase_IDNO, @Ln_Zero_NUMB) AS VARCHAR) AS MotherDfsCase_IDNO,
          CAST(ISNULL(MotherMci_IDNO, @Ln_Zero_NUMB) AS VARCHAR) AS MotherMci_IDNO,
          CAST(ISNULL(MotherIveParty_IDNO, @Ln_Zero_NUMB) AS VARCHAR) AS MotherIveParty_IDNO,
          ISNULL(SUBSTRING(Mother_NAME, 1, 24), @Lc_Space_TEXT) AS Mother_NAME,
          CAST(ISNULL(MotherOrder_AMNT, @Ln_Zero_NUMB) AS VARCHAR) AS MotherOrder_AMNT,
          CONVERT(CHAR, ISNULL(MotherPaymentLast_DATE, @Lc_Space_TEXT), 112) AS MotherPaymentLast_DATE,
          CAST(ISNULL(MotherPaymentLast_AMNT, @Ln_Zero_NUMB) AS VARCHAR) AS MotherPaymentLast_AMNT,
          ISNULL(MotherAddress_CODE, @Lc_Space_TEXT) AS MotherAddress_CODE,
          ISNULL(SUBSTRING(MotherLine1_ADDR, 1, 31), @Lc_Space_TEXT) AS MotherLine1_ADDR,
          ISNULL(SUBSTRING(MotherLine2_ADDR, 1, 31), @Lc_Space_TEXT) AS MotherLine2_ADDR,
          ISNULL(MotherState_ADDR, @Lc_Space_TEXT) AS MotherState_ADDR,
          ISNULL(SUBSTRING(MotherCity_ADDR, 1, 16), @Lc_Space_TEXT) AS MotherCity_ADDR,
          ISNULL(MotherZip_ADDR, @Lc_Space_TEXT) AS MotherZip_ADDR,
          CONVERT(CHAR, ISNULL(MotherDfsCaseOpen_DATE, @Lc_Space_TEXT), 112) AS MotherDfsCaseOpen_DATE,
          CAST(ISNULL(FatherCase_IDNO, @Ln_Zero_NUMB) AS VARCHAR) AS FatherCase_IDNO,
          CAST(ISNULL(FatherDfsCase_IDNO, @Ln_Zero_NUMB) AS VARCHAR) AS FatherDfsCase_IDNO,
          CAST(ISNULL(FatherMci_IDNO, @Ln_Zero_NUMB) AS VARCHAR) AS FatherMci_IDNO,
          CAST(ISNULL(FatherIveParty_IDNO, @Ln_Zero_NUMB) AS VARCHAR) AS FatherIveParty_IDNO,
          ISNULL(SUBSTRING(Father_NAME, 1, 24), @Lc_Space_TEXT) AS Father_NAME,
          CAST(ISNULL(FatherOrder_AMNT, @Ln_Zero_NUMB) AS VARCHAR) AS FatherOrder_AMNT,
          CONVERT(CHAR, ISNULL(FatherPaymentLast_DATE, @Lc_Space_TEXT), 112) AS FatherPaymentLast_DATE,
          CAST(ISNULL(FatherPaymentLast_AMNT, @Ln_Zero_NUMB) AS VARCHAR) AS FatherPaymentLast_AMNT,
          ISNULL(FatherAddress_CODE, @Lc_Space_TEXT) AS FatherAddress_CODE,
          ISNULL(SUBSTRING(FatherLine1_ADDR, 1, 31), @Lc_Space_TEXT) AS FatherLine1_ADDR,
          ISNULL(SUBSTRING(FatherLine2_ADDR, 1, 31), @Lc_Space_TEXT) AS FatherLine2_ADDR,
          ISNULL(FatherState_ADDR, @Lc_Space_TEXT) AS FatherState_ADDR,
          ISNULL(SUBSTRING(FatherCity_ADDR, 1, 16), @Lc_Space_TEXT) AS FatherCity_ADDR,
          ISNULL(FatherZip_ADDR, @Lc_Space_TEXT) AS FatherZip_ADDR,
          CONVERT(CHAR, ISNULL(FatherDfsCaseOpen_DATE, @Lc_Space_TEXT), 112) AS FatherDfsCaseOpen_DATE
     INTO #IveCaseMemberDetails_P1
     FROM (SELECT ChildMci_IDNO AS ChildMci_IDNO,
                  ChildIveParty_IDNO AS ChildIveParty_IDNO,
                  Child_NAME AS Child_NAME,
                  ChildSsn_NUMB AS ChildSsn_NUMB,
                  ChildDfsCase_IDNO AS ChildDfsCase_IDNO,
                  ChildPaternityEst_INDC AS ChildPaternityEst_INDC,
                  PaternityEst_DATE AS PaternityEst_DATE,
                  MethodEstablish_CODE AS MethodEstablish_CODE,
                  CseOrder_DATE AS CseOrder_DATE,
                  NcpCase_IDNO AS MotherCase_IDNO,
                  NcpDfsCase_IDNO AS MotherDfsCase_IDNO,
                  NcpMci_IDNO AS MotherMci_IDNO,
                  NcpIveParty_IDNO AS MotherIveParty_IDNO,
                  Ncp_NAME AS Mother_NAME,
                  NcpOrder_AMNT AS MotherOrder_AMNT,
                  NcpPaymentLast_DATE AS MotherPaymentLast_DATE,
                  NcpPaymentLast_AMNT AS MotherPaymentLast_AMNT,
                  NcpAddress_CODE AS MotherAddress_CODE,
                  NcpLine1_ADDR AS MotherLine1_ADDR,
                  NcpLine2_ADDR AS MotherLine2_ADDR,
                  NcpCity_ADDR AS MotherCity_ADDR,
                  NcpState_ADDR AS MotherState_ADDR,
                  NcpZip_ADDR AS MotherZip_ADDR,
                  NcpDfsCaseOpen_DATE AS MotherDfsCaseOpen_DATE,
                  0 AS FatherCase_IDNO,
                  0 AS FatherDfsCase_IDNO,
                  0 AS FatherMci_IDNO,
                  0 AS FatherIveParty_IDNO,
                  @Lc_Space_TEXT AS Father_NAME,
                  0.00 AS FatherOrder_AMNT,
                  @Lc_Space_TEXT AS FatherPaymentLast_DATE,
                  0.00 AS FatherPaymentLast_AMNT,
                  @Lc_Space_TEXT AS FatherAddress_CODE,
                  @Lc_Space_TEXT AS FatherLine1_ADDR,
                  @Lc_Space_TEXT AS FatherLine2_ADDR,
                  @Lc_Space_TEXT AS FatherCity_ADDR,
                  @Lc_Space_TEXT AS FatherState_ADDR,
                  @Lc_Space_TEXT AS FatherZip_ADDR,
                  @Lc_Space_TEXT AS FatherDfsCaseOpen_DATE
             FROM Ive_Case_Member_Details
            WHERE NcpRelationshipToChild_CODE = @Lc_NcpMother_CODE
           UNION
           SELECT ChildMci_IDNO AS ChildMci_IDNO,
                  ChildIveParty_IDNO AS ChildIveParty_IDNO,
                  Child_NAME AS Child_NAME,
                  ChildSsn_NUMB AS ChildSsn_NUMB,
                  ChildDfsCase_IDNO AS ChildDfsCase_IDNO,
                  ChildPaternityEst_INDC AS ChildPaternityEst_INDC,
                  PaternityEst_DATE AS PaternityEst_DATE,
                  MethodEstablish_CODE AS MethodEstablish_CODE,
                  CseOrder_DATE AS CseOrder_DATE,
                  0 AS MotherCase_IDNO,
                  0 AS MotherDfsCase_IDNO,
                  0 AS MotherMci_IDNO,
                  0 AS MotherIveParty_IDNO,
                  @Lc_Space_TEXT AS Mother_NAME,
                  0.00 AS MotherOrder_AMNT,
                  @Lc_Space_TEXT AS MotherPaymentLast_DATE,
                  0.00 AS MotherPaymentLast_AMNT,
                  @Lc_Space_TEXT AS MotherAddress_CODE,
                  @Lc_Space_TEXT AS MotherLine1_ADDR,
                  @Lc_Space_TEXT AS MotherLine2_ADDR,
                  @Lc_Space_TEXT AS MotherCity_ADDR,
                  @Lc_Space_TEXT AS MotherState_ADDR,
                  @Lc_Space_TEXT AS MotherZip_ADDR,
                  @Lc_Space_TEXT AS MotherDfsCaseOpen_DATE,
                  NcpCase_IDNO AS FatherCase_IDNO,
                  NcpDfsCase_IDNO AS FatherDfsCase_IDNO,
                  NcpMci_IDNO AS FatherMci_IDNO,
                  NcpIveParty_IDNO AS FatherIveParty_IDNO,
                  Ncp_NAME AS Father_NAME,
                  NcpOrder_AMNT AS FatherOrder_AMNT,
                  NcpPaymentLast_DATE AS FatherPaymentLast_DATE,
                  NcpPaymentLast_AMNT AS FatherPaymentLast_AMNT,
                  NcpAddress_CODE AS FatherAddress_CODE,
                  NcpLine1_ADDR AS FatherLine1_ADDR,
                  NcpLine2_ADDR AS FatherLine2_ADDR,
                  NcpCity_ADDR AS FatherCity_ADDR,
                  NcpState_ADDR AS FatherState_ADDR,
                  NcpZip_ADDR AS FatherZip_ADDR,
                  NcpDfsCaseOpen_DATE AS FatherDfsCaseOpen_DATE
             FROM Ive_Case_Member_Details
            WHERE NcpRelationshipToChild_CODE = @Lc_NcpFather_CODE) A

   SET @Ls_Sql_TEXT = 'INSERT EFIVE_Y1 TABLE TypeReason_CODE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO EFIVE_Y1
               (Rec_ID,
                TypeReason_CODE,
                ChildMci_IDNO,
                ChildIveParty_IDNO,
                Child_NAME,
                ChildSsn_NUMB,
                ChildDfsCase_IDNO,
                ApplicationStatus_CODE,
                ChildPaternityEst_INDC,
                PaternityEst_DATE,
                MethodEstablish_CODE,
                CseOrder_DATE,
                MotherCase_IDNO,
                MotherDfsCase_IDNO,
                MotherMci_IDNO,
                MotherIveParty_IDNO,
                Mother_NAME,
                MotherOrder_AMNT,
                MotherPaymentLast_DATE,
                MotherPaymentLast_AMNT,
                MotherAddress_CODE,
                MotherLine1_ADDR,
                MotherLine2_ADDR,
                MotherState_ADDR,
                MotherCity_ADDR,
                MotherZip1_ADDR,
                MotherZip2_ADDR,
                MotherDfsCaseOpen_DATE,
                FatherCase_IDNO,
                FatherDfsCase_IDNO,
                FatherMci_IDNO,
                FatherIveParty_IDNO,
                Father_NAME,
                FatherOrder_AMNT,
                FatherPaymentLast_DATE,
                FatherPaymentLast_AMNT,
                FatherAddress_CODE,
                FatherLine1_ADDR,
                FatherLine2_ADDR,
                FatherState_ADDR,
                FatherCity_ADDR,
                FatherZip1_ADDR,
                FatherZip2_ADDR,
                FatherDfsCaseOpen_DATE)
   SELECT DISTINCT
          @Lc_DetailRecord_CODE AS Rec_ID,
          @Lc_ReasonChildNameChg_CODE AS TypeReason_CODE,
          ChildMci_IDNO,
          ChildIveParty_IDNO,
          Child_NAME,
          ChildSsn_NUMB,
          ChildDfsCase_IDNO,
          @Lc_Space_TEXT AS ApplicationStatus_CODE,
          ChildPaternityEst_INDC,
          PaternityEst_DATE,
          MethodEstablish_CODE,
          CseOrder_DATE,
          MotherCase_IDNO,
          MotherDfsCase_IDNO,
          MotherMci_IDNO,
          MotherIveParty_IDNO,
          Mother_NAME,
          MotherOrder_AMNT,
          MotherPaymentLast_DATE,
          MotherPaymentLast_AMNT,
          MotherAddress_CODE,
          MotherLine1_ADDR,
          MotherLine2_ADDR,
          MotherState_ADDR,
          MotherCity_ADDR,
          SUBSTRING(MotherZip_ADDR, 1, 5) AS MotherZip1_ADDR,
          SUBSTRING(MotherZip_ADDR, 6, 4) AS MotherZip2_ADDR,
          MotherDfsCaseOpen_DATE,
          FatherCase_IDNO,
          FatherDfsCase_IDNO,
          FatherMci_IDNO,
          FatherIveParty_IDNO,
          Father_NAME,
          FatherOrder_AMNT,
          FatherPaymentLast_DATE,
          FatherPaymentLast_AMNT,
          FatherAddress_CODE,
          FatherLine1_ADDR,
          FatherLine2_ADDR,
          FatherState_ADDR,
          FatherCity_ADDR,
          SUBSTRING(FatherZip_ADDR, 1, 5) AS FatherZip1_ADDR,
          SUBSTRING(FatherZip_ADDR, 6, 4) AS FatherZip2_ADDR,
          FatherDfsCaseOpen_DATE
     FROM #IveCaseMemberDetails_P1 a
    WHERE EXISTS (SELECT 1
                    FROM DEMO_Y1 b
                   WHERE b.MemberMci_IDNO = CAST(a.ChildMci_IDNO AS NUMERIC)
                     AND b.BeginValidity_DATE > @Ld_LastRun_DATE
                     AND b.BeginValidity_DATE <= @Ld_Run_DATE
                     AND (LTRIM (RTRIM (b.Last_NAME)) != (SELECT TOP 1 LTRIM (RTRIM (c.Last_NAME))
                                                            FROM HDEMO_Y1 c
                                                           WHERE c.MemberMci_IDNO = b.MemberMci_IDNO
                                                             AND c.EndValidity_DATE > @Ld_LastRun_DATE
                                                             AND c.EndValidity_DATE <= @Ld_Run_DATE)
                           OR LTRIM (RTRIM (b.First_NAME)) != (SELECT TOP 1 LTRIM (RTRIM (c.First_NAME))
                                                                 FROM HDEMO_Y1 c
                                                                WHERE c.MemberMci_IDNO = b.MemberMci_IDNO
                                                                  AND c.EndValidity_DATE > @Ld_LastRun_DATE
                                                                  AND c.EndValidity_DATE <= @Ld_Run_DATE)))
	 AND EXISTS (SELECT 1 
				   FROM CASE_Y1 f
				  WHERE f.Case_IDNO IN (CAST(a.MotherCase_IDNO AS NUMERIC), CAST(a.FatherCase_IDNO AS NUMERIC))
				    AND f.StatusCase_CODE = @Lc_Statusopen_CODE)                                                                 
   UNION
   SELECT DISTINCT
          @Lc_DetailRecord_CODE,
          @Lc_ReasonParentNameChg_CODE,
          ChildMci_IDNO,
          ChildIveParty_IDNO,
          Child_NAME,
          ChildSsn_NUMB,
          ChildDfsCase_IDNO,
          @Lc_Space_TEXT AS ApplicationStatus_CODE,
          ChildPaternityEst_INDC,
          PaternityEst_DATE,
          MethodEstablish_CODE,
          CseOrder_DATE,
          MotherCase_IDNO,
          MotherDfsCase_IDNO,
          MotherMci_IDNO,
          MotherIveParty_IDNO,
          Mother_NAME,
          MotherOrder_AMNT,
          MotherPaymentLast_DATE,
          MotherPaymentLast_AMNT,
          MotherAddress_CODE,
          MotherLine1_ADDR,
          MotherLine2_ADDR,
          MotherState_ADDR,
          MotherCity_ADDR,
          SUBSTRING(MotherZip_ADDR, 1, 5),
          SUBSTRING(MotherZip_ADDR, 6, 4),
          MotherDfsCaseOpen_DATE,
          FatherCase_IDNO,
          FatherDfsCase_IDNO,
          FatherMci_IDNO,
          FatherIveParty_IDNO,
          Father_NAME,
          FatherOrder_AMNT,
          FatherPaymentLast_DATE,
          FatherPaymentLast_AMNT,
          FatherAddress_CODE,
          FatherLine1_ADDR,
          FatherLine2_ADDR,
          FatherState_ADDR,
          FatherCity_ADDR,
          SUBSTRING(FatherZip_ADDR, 1, 5),
          SUBSTRING(FatherZip_ADDR, 6, 4),
          FatherDfsCaseOpen_DATE
     FROM #IveCaseMemberDetails_P1 i
    WHERE EXISTS (SELECT 1
                    FROM DEMO_Y1 b
                   WHERE b.MemberMci_IDNO IN (CAST(i.MotherMci_IDNO AS NUMERIC), CAST(i.FatherMci_IDNO AS NUMERIC))
                     AND b.BeginValidity_DATE > @Ld_LastRun_DATE
                     AND b.BeginValidity_DATE <= @Ld_Run_DATE
                     AND (LTRIM (RTRIM (b.Last_NAME)) != (SELECT TOP 1 LTRIM (RTRIM (c.Last_NAME))
                                                            FROM HDEMO_Y1 c
                                                           WHERE c.MemberMci_IDNO = b.MemberMci_IDNO
                                                             AND c.EndValidity_DATE > @Ld_LastRun_DATE
                                                             AND c.EndValidity_DATE <= @Ld_Run_DATE)
                           OR LTRIM (RTRIM (b.First_NAME)) != (SELECT TOP 1 LTRIM (RTRIM (c.First_NAME))
                                                                 FROM HDEMO_Y1 c
                                                                WHERE c.MemberMci_IDNO = b.MemberMci_IDNO
                                                                  AND c.EndValidity_DATE > @Ld_LastRun_DATE
                                                                  AND c.EndValidity_DATE <= @Ld_Run_DATE)))
	 AND EXISTS (SELECT 1 
				   FROM CASE_Y1 f
				  WHERE f.Case_IDNO IN (CAST(i.MotherCase_IDNO AS NUMERIC), CAST(i.FatherCase_IDNO AS NUMERIC))
				    AND f.StatusCase_CODE = @Lc_Statusopen_CODE)                                                                       
   UNION
   SELECT DISTINCT
          @Lc_DetailRecord_CODE,
          @Lc_ReasonChildMciChg_CODE,
          ChildMci_IDNO,
          ChildIveParty_IDNO,
          Child_NAME,
          ChildSsn_NUMB,
          ChildDfsCase_IDNO,
          @Lc_Space_TEXT AS ApplicationStatus_CODE,
          ChildPaternityEst_INDC,
          PaternityEst_DATE,
          MethodEstablish_CODE,
          CseOrder_DATE,
          MotherCase_IDNO,
          MotherDfsCase_IDNO,
          MotherMci_IDNO,
          MotherIveParty_IDNO,
          Mother_NAME,
          MotherOrder_AMNT,
          MotherPaymentLast_DATE,
          MotherPaymentLast_AMNT,
          MotherAddress_CODE,
          MotherLine1_ADDR,
          MotherLine2_ADDR,
          MotherState_ADDR,
          MotherCity_ADDR,
          SUBSTRING(MotherZip_ADDR, 1, 5),
          SUBSTRING(MotherZip_ADDR, 6, 4),
          MotherDfsCaseOpen_DATE,
          FatherCase_IDNO,
          FatherDfsCase_IDNO,
          FatherMci_IDNO,
          FatherIveParty_IDNO,
          Father_NAME,
          FatherOrder_AMNT,
          FatherPaymentLast_DATE,
          FatherPaymentLast_AMNT,
          FatherAddress_CODE,
          FatherLine1_ADDR,
          FatherLine2_ADDR,
          FatherState_ADDR,
          FatherCity_ADDR,
          SUBSTRING(FatherZip_ADDR, 1, 5),
          SUBSTRING(FatherZip_ADDR, 6, 4),
          FatherDfsCaseOpen_DATE
     FROM #IveCaseMemberDetails_P1 m
    WHERE EXISTS (SELECT 1
                    FROM DEMO_Y1 b
                   WHERE b.MemberMci_IDNO = CAST(m.ChildMci_IDNO AS NUMERIC)
                     AND b.MemberMci_IDNO IN (SELECT MemberMciPrimary_IDNO
                                                FROM MMRG_Y1 g
                                               WHERE b.MemberMci_IDNO = g.MemberMciPrimary_IDNO
                                                 AND g.BeginValidity_DATE > @Ld_LastRun_DATE
                                                 AND g.BeginValidity_DATE <= @Ld_Run_DATE))
	 AND EXISTS (SELECT 1 
				   FROM CASE_Y1 f
				  WHERE f.Case_IDNO IN (CAST(m.MotherCase_IDNO AS NUMERIC), CAST(m.FatherCase_IDNO AS NUMERIC))
				    AND f.StatusCase_CODE = @Lc_Statusopen_CODE)                                                   
   UNION
   SELECT DISTINCT
          @Lc_DetailRecord_CODE,
          @Lc_ReasonParentMciChg_CODE,
          ChildMci_IDNO,
          ChildIveParty_IDNO,
          Child_NAME,
          ChildSsn_NUMB,
          ChildDfsCase_IDNO,
          @Lc_Space_TEXT AS ApplicationStatus_CODE,
          ChildPaternityEst_INDC,
          PaternityEst_DATE,
          MethodEstablish_CODE,
          CseOrder_DATE,
          MotherCase_IDNO,
          MotherDfsCase_IDNO,
          MotherMci_IDNO,
          MotherIveParty_IDNO,
          Mother_NAME,
          MotherOrder_AMNT,
          MotherPaymentLast_DATE,
          MotherPaymentLast_AMNT,
          MotherAddress_CODE,
          MotherLine1_ADDR,
          MotherLine2_ADDR,
          MotherState_ADDR,
          MotherCity_ADDR,
          SUBSTRING(MotherZip_ADDR, 1, 5),
          SUBSTRING(MotherZip_ADDR, 6, 4),
          MotherDfsCaseOpen_DATE,
          FatherCase_IDNO,
          FatherDfsCase_IDNO,
          FatherMci_IDNO,
          FatherIveParty_IDNO,
          Father_NAME,
          FatherOrder_AMNT,
          FatherPaymentLast_DATE,
          FatherPaymentLast_AMNT,
          FatherAddress_CODE,
          FatherLine1_ADDR,
          FatherLine2_ADDR,
          FatherState_ADDR,
          FatherCity_ADDR,
          SUBSTRING(FatherZip_ADDR, 1, 5),
          SUBSTRING(FatherZip_ADDR, 6, 4),
          FatherDfsCaseOpen_DATE
     FROM #IveCaseMemberDetails_P1 m
    WHERE EXISTS (SELECT 1 
				   FROM CASE_Y1 f
				  WHERE f.Case_IDNO IN (CAST(m.MotherCase_IDNO AS NUMERIC), CAST(m.FatherCase_IDNO AS NUMERIC))
				    AND f.StatusCase_CODE = @Lc_Statusopen_CODE)
	  AND (EXISTS (SELECT 1
                    FROM DEMO_Y1 b
                   WHERE b.MemberMci_IDNO IN (CAST(m.MotherMci_IDNO AS NUMERIC), CAST(m.FatherMci_IDNO AS NUMERIC))
                     AND b.MemberMci_IDNO IN (SELECT MemberMciPrimary_IDNO
                                                FROM MMRG_Y1 g
                                               WHERE b.MemberMci_IDNO = g.MemberMciPrimary_IDNO
                                                 AND g.BeginValidity_DATE > @Ld_LastRun_DATE
                                                 AND g.BeginValidity_DATE <= @Ld_Run_DATE))
          OR                                          
		   EXISTS (SELECT 1 
		            FROM CMEM_Y1 u
		           WHERE u.Case_IDNO IN (CAST(m.MotherCase_IDNO AS NUMERIC), CAST(m.FatherCase_IDNO AS NUMERIC))
		             AND u.MemberMci_IDNO IN (CAST(m.MotherMci_IDNO AS NUMERIC), CAST(m.FatherMci_IDNO AS NUMERIC))
		             AND u.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
		             AND u.CaseMemberStatus_CODE = @Lc_MemberActiveStatus_CODE
		             AND u.BeginValidity_DATE > @Ld_LastRun_DATE
		             AND EXISTS (SELECT 1
		                           FROM CMEM_Y1 n
		                          WHERE n.Case_IDNO = u.Case_IDNO
		                           AND n.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
		                           AND n.MemberMci_IDNO = @Ln_UnKnownMci_IDNO
		                           AND n.CaseMemberStatus_CODE = @Lc_MemberInActiveStatus_CODE
		                           AND n.BeginValidity_DATE > @Ld_LastRun_DATE
		                           )
		           )
		   
		  )                                               
	 
   UNION
   SELECT DISTINCT
          @Lc_DetailRecord_CODE,
          @Lc_ReasonParentCaseCloser_CODE,
          ChildMci_IDNO,
          ChildIveParty_IDNO,
          Child_NAME,
          ChildSsn_NUMB,
          ChildDfsCase_IDNO,
          @Lc_Space_TEXT AS ApplicationStatus_CODE,
          ChildPaternityEst_INDC,
          PaternityEst_DATE,
          MethodEstablish_CODE,
          CseOrder_DATE,
          MotherCase_IDNO,
          MotherDfsCase_IDNO,
          MotherMci_IDNO,
          MotherIveParty_IDNO,
          Mother_NAME,
          MotherOrder_AMNT,
          MotherPaymentLast_DATE,
          MotherPaymentLast_AMNT,
          MotherAddress_CODE,
          MotherLine1_ADDR,
          MotherLine2_ADDR,
          MotherState_ADDR,
          MotherCity_ADDR,
          SUBSTRING(MotherZip_ADDR, 1, 5),
          SUBSTRING(MotherZip_ADDR, 6, 4),
          MotherDfsCaseOpen_DATE,
          FatherCase_IDNO,
          FatherDfsCase_IDNO,
          FatherMci_IDNO,
          FatherIveParty_IDNO,
          Father_NAME,
          FatherOrder_AMNT,
          FatherPaymentLast_DATE,
          FatherPaymentLast_AMNT,
          FatherAddress_CODE,
          FatherLine1_ADDR,
          FatherLine2_ADDR,
          FatherState_ADDR,
          FatherCity_ADDR,
          SUBSTRING(FatherZip_ADDR, 1, 5),
          SUBSTRING(FatherZip_ADDR, 6, 4),
          FatherDfsCaseOpen_DATE
     FROM #IveCaseMemberDetails_P1 m
    WHERE EXISTS (SELECT 1
                    FROM CASE_Y1 c
                   WHERE c.Case_IDNO IN (CAST(m.MotherCase_IDNO AS NUMERIC), CAST(m.FatherCase_IDNO AS NUMERIC))
                     AND c.StatusCase_CODE = @Lc_StatusClosed_CODE
                     AND c.StatusCurrent_DATE > @Ld_LastRun_DATE
                     AND c.StatusCurrent_DATE <= @Ld_Run_DATE)
   UNION
   SELECT DISTINCT
          @Lc_DetailRecord_CODE,
          @Lc_ReasonSupportOrderDateChg_CODE,
          ChildMci_IDNO,
          ChildIveParty_IDNO,
          Child_NAME,
          ChildSsn_NUMB,
          ChildDfsCase_IDNO,
          @Lc_Space_TEXT AS ApplicationStatus_CODE,
          ChildPaternityEst_INDC,
          PaternityEst_DATE,
          MethodEstablish_CODE,
          CseOrder_DATE,
          MotherCase_IDNO,
          MotherDfsCase_IDNO,
          MotherMci_IDNO,
          MotherIveParty_IDNO,
          Mother_NAME,
          MotherOrder_AMNT,
          MotherPaymentLast_DATE,
          MotherPaymentLast_AMNT,
          MotherAddress_CODE,
          MotherLine1_ADDR,
          MotherLine2_ADDR,
          MotherState_ADDR,
          MotherCity_ADDR,
          SUBSTRING(MotherZip_ADDR, 1, 5),
          SUBSTRING(MotherZip_ADDR, 6, 4),
          MotherDfsCaseOpen_DATE,
          FatherCase_IDNO,
          FatherDfsCase_IDNO,
          FatherMci_IDNO,
          FatherIveParty_IDNO,
          Father_NAME,
          FatherOrder_AMNT,
          FatherPaymentLast_DATE,
          FatherPaymentLast_AMNT,
          FatherAddress_CODE,
          FatherLine1_ADDR,
          FatherLine2_ADDR,
          FatherState_ADDR,
          FatherCity_ADDR,
          SUBSTRING(FatherZip_ADDR, 1, 5),
          SUBSTRING(FatherZip_ADDR, 6, 4),
          FatherDfsCaseOpen_DATE
     FROM #IveCaseMemberDetails_P1 m
    WHERE EXISTS (SELECT 1
                    FROM (SELECT s.Case_IDNO,
                                 s.OrderSeq_NUMB,
                                 s.OrderIssued_DATE
                            FROM SORD_Y1 s
                           WHERE s.Case_IDNO IN (CAST(m.MotherCase_IDNO AS NUMERIC), CAST(m.FatherCase_IDNO AS NUMERIC))
                             AND s.EndValidity_DATE > @Ld_LastRun_DATE
                             AND s.EndValidity_DATE <= @Ld_Run_DATE) h,
                         (SELECT s.Case_IDNO,
                                 s.OrderSeq_NUMB,
                                 s.OrderIssued_DATE
                            FROM SORD_Y1 s
                           WHERE Case_IDNO IN (CAST(m.MotherCase_IDNO AS NUMERIC), CAST(m.FatherCase_IDNO AS NUMERIC))
                             AND EndValidity_DATE = @Ld_High_DATE
                             AND @Ld_Run_DATE BETWEEN OrderEffective_DATE AND OrderEnd_DATE) c
                   WHERE h.Case_IDNO = c.Case_IDNO
                     AND h.OrderSeq_NUMB = c.OrderSeq_NUMB
                     AND h.OrderIssued_DATE != c.OrderIssued_DATE)
	 AND EXISTS (SELECT 1 
				   FROM CASE_Y1 f
				  WHERE f.Case_IDNO IN (CAST(m.MotherCase_IDNO AS NUMERIC), CAST(m.FatherCase_IDNO AS NUMERIC))
				    AND f.StatusCase_CODE = @Lc_Statusopen_CODE);

   SET @Ln_ProcessedRecordCount_QNTY = (SELECT COUNT(1)
                                          FROM EFIVE_Y1 a);

   IF @Ln_ProcessedRecordCount_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeErrorWarning_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorE0944_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorWarning_CODE,
      @An_Line_NUMB                = @Ln_ProcessedRecordCount_QNTY,
      @Ac_Error_CODE               = @Lc_ErrorE0944_CODE,
      @As_DescriptionError_TEXT    = @Lc_Space_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'INSERT HEADER RECORD INTO ##ExtractIVE_P1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractIVE_P1
               (Record_TEXT)
   SELECT @Lc_HeaderRecord_CODE + CONVERT(CHAR(8), @Ld_Run_DATE, 112) + REPLICATE(@Lc_Space_TEXT, 465) AS Record_TEXT;

   SET @Ls_Sql_TEXT = 'INSERT DETAIL RECORD INTO ##ExtractIVE_P1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   INSERT INTO ##ExtractIVE_P1
               (Record_TEXT)
   SELECT CONVERT(CHAR(1), Rec_ID) + CONVERT(CHAR(2), TypeReason_CODE) + RIGHT(('0000000000' + LTRIM(RTRIM(ChildMci_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(ChildIveParty_IDNO))), 10) + CONVERT(CHAR(24), Child_NAME) + RIGHT(('000000000' + LTRIM(RTRIM(ChildSsn_NUMB))), 9) + RIGHT(('0000000000' + LTRIM(RTRIM(ChildDfsCase_IDNO))), 10) + CONVERT(CHAR(1), ApplicationStatus_CODE) + CONVERT(CHAR(1), ChildPaternityEst_INDC) + CONVERT(CHAR(8), CASE WHEN PaternityEst_DATE IN (@Lc_LowDate_TEXT, @Lc_LowDate1_TEXT)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                     THEN @Lc_Space_TEXT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ELSE PaternityEst_DATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                               END) + CONVERT(CHAR(2), MethodEstablish_CODE) + CONVERT(CHAR(8), CASE WHEN CseOrder_DATE IN (@Lc_LowDate_TEXT, @Lc_LowDate1_TEXT)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      THEN @Lc_Space_TEXT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ELSE CseOrder_DATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                END) + RIGHT (('0000000000' + LTRIM(RTRIM(MotherCase_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(MotherDfsCase_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(MotherMci_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(MotherIveParty_IDNO))), 10) + CONVERT(CHAR(24), Mother_NAME) + RIGHT(('++++++++++++' + LTRIM(RTRIM(MotherOrder_AMNT))), 12) + CONVERT(CHAR(8), CASE WHEN MotherPaymentLast_DATE IN (@Lc_LowDate_TEXT, @Lc_LowDate1_TEXT)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     THEN @Lc_Space_TEXT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ELSE MotherPaymentLast_DATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               END) + RIGHT (('++++++++++++' + LTRIM(RTRIM(MotherPaymentLast_AMNT))), 12) + CONVERT(CHAR(1), MotherAddress_CODE) + CONVERT(CHAR(31), MotherLine1_ADDR) + CONVERT(CHAR(31), MotherLine2_ADDR) + CONVERT(CHAR(2), MotherState_ADDR) + CONVERT(CHAR(16), MotherCity_ADDR) + CONVERT(CHAR(5), MotherZip1_ADDR) + CONVERT(CHAR(4), MotherZip2_ADDR) + CONVERT(CHAR(8), CASE WHEN MotherDfsCaseOpen_DATE IN (@Lc_LowDate_TEXT, @Lc_LowDate1_TEXT)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        THEN @Lc_Space_TEXT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ELSE MotherDfsCaseOpen_DATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  END) + RIGHT(('0000000000' + LTRIM(RTRIM(FatherCase_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(FatherDfsCase_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(FatherMci_IDNO))), 10) + RIGHT(('0000000000' + LTRIM(RTRIM(FatherIveParty_IDNO))), 10) + CONVERT(CHAR(24), Father_NAME) + RIGHT(('++++++++++++' + LTRIM(RTRIM(FatherOrder_AMNT))), 12) + CONVERT(CHAR(8), CASE WHEN FatherPaymentLast_DATE IN (@Lc_LowDate_TEXT, @Lc_LowDate1_TEXT)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     THEN @Lc_Space_TEXT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 ELSE FatherPaymentLast_DATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                END) + RIGHT (('++++++++++++' + LTRIM(RTRIM(FatherPaymentLast_AMNT))), 12) + CONVERT(CHAR(1), FatherAddress_CODE) + CONVERT(CHAR(31), FatherLine1_ADDR) + CONVERT(CHAR(31), FatherLine2_ADDR) + CONVERT(CHAR(2), FatherState_ADDR) + CONVERT(CHAR(16), FatherCity_ADDR) + CONVERT(CHAR(5), FatherZip1_ADDR) + CONVERT(CHAR(4), FatherZip2_ADDR) + CONVERT(CHAR( 8), CASE WHEN FatherDfsCaseOpen_DATE IN (@Lc_LowDate_TEXT, @Lc_LowDate1_TEXT)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          THEN @Lc_Space_TEXT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ELSE FatherDfsCaseOpen_DATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    END) AS Record_TEXT
     FROM EFIVE_Y1 a;

   SET @Ls_Sql_TEXT ='INSERT TRAILER RECORD INTO ##ExtractIVE_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'FILE RECORD COUNT = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);

   INSERT INTO ##ExtractIVE_P1
               (Record_TEXT)
   SELECT @Lc_Trailer_CODE + RIGHT(('0000000000' + LTRIM(RTRIM(@Ln_ProcessedRecordCount_QNTY))), 10) + REPLICATE(@Lc_Space_TEXT, 463) AS Record_TEXT;

   SET @Ls_Sql_TEXT = 'EXTRACT TO FILE';
   SET @Ls_BcpCommand_TEXT = 'SELECT Record_TEXT FROM ##ExtractIVE_P1 ORDER BY Seq_IDNO';
   SET @Ls_Sqldata_TEXT ='QUERY = ' + @Ls_BcpCommand_TEXT;

   COMMIT TRANSACTION EXTRACTIVE_OUTGOING;

   SET @Ls_Sql_TEXT='BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT = 'FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@Ls_File_NAME, '') + ', Query_TEXT = ' + ISNULL(@Ls_BcpCommand_TEXT, '');

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

   BEGIN TRANSACTION EXTRACTIVE_OUTGOING;

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

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Start_DATE = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', Process_NAME = ' + ISNULL(@Ls_Process_NAME, '') + ', Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', CursorLocation_TEXT = ' + ISNULL(@Ls_CursorLoc_TEXT, '') + ', ExecLocation_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Lc_Successful_TEXT, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_DescriptionError_TEXT, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusSuccess_CODE, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', ProcessedRecordCount_QNTY = ' + ISNULL(CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE ##ExtractIVE_P1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE ##ExtractIVE_P1;

   SET @Ls_Sql_TEXT = 'DROP TEMP TABLE #IveCaseMemberDetails_P1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   DROP TABLE #IveCaseMemberDetails_P1;

   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   COMMIT TRANSACTION EXTRACTIVE_OUTGOING;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION EXTRACTIVE_OUTGOING;
    END

   IF OBJECT_ID('tempdb..##ExtractIVE_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractIVE_P1;
    END

   IF OBJECT_ID('tempdb..#IveCaseMemberDetails_P1') IS NOT NULL
    BEGIN
     DROP TABLE #IveCaseMemberDetails_P1;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

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
    @An_ProcessedRecordCount_QNTY = @Ln_Zero_NUMB;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END;


GO
