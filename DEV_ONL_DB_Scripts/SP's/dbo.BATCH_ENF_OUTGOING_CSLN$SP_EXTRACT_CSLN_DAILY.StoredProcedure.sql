/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_CSLN$SP_EXTRACT_CSLN_DAILY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_CSLN$SP_EXTRACT_CSLN_DAILY
Programmer Name	:	IMP Team.
Description		:	The purpose of the batch program is to send file to CSLN vendor notifying them what action 
                          is to be taken based upon indicators values sent in the file. Selected case is active 
                          in CSLN enforcement remedy in the system.
Frequency		:	'DAILY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_CSLN$SP_EXTRACT_CSLN_DAILY]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_QNTY             SMALLINT = 0,
          @Lc_LastKnowCourtAddress_CODE CHAR(1) = 'C',
          @Lc_MailingAddress_CODE       CHAR(1) = 'M',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_StatusAbnormalend_CODE    CHAR(1) = 'A',
          @Lc_StringZero_TEXT           CHAR(1) = '0',
          @Lc_StringOne_TEXT            CHAR(1) = '1',
          @Lc_TypeAction1_CODE          CHAR(1) = '1',
          @Lc_TypeAction9_CODE          CHAR(1) = '9',
          @Lc_TypeAction4_CODE          CHAR(1) = '4',
          @Lc_TypeAction3_CODE          CHAR(1) = '3',
          @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_ConfirmedGood_CODE        CHAR(1) = 'Y',
          @Lc_TypeWarning_CODE          CHAR(1) = 'W',
          @Lc_Note_INDC                 CHAR(1) = 'N',  
          @Lc_State_CODE                CHAR(2) = 'DE',
          @Lc_ReasonStatusLm_CODE       CHAR(2) = 'LM',
          @Lc_ReasonStatusMt_CODE       CHAR(2) = 'MT',
          @Lc_ReasonStatusLl_CODE       CHAR(2) = 'LL',
          @Lc_ReasonStatusLj_CODE       CHAR(2) = 'LJ',
          @Lc_ReasonStatusRz_CODE       CHAR(2) = 'RZ',
          @Lc_ReasonStatusVl_CODE       CHAR(2) = 'VL',
          @Lc_ReasonStatusLk_CODE       CHAR(2) = 'LK',
          @Lc_ReasonStatusMf_CODE       CHAR(2) = 'MF',
          @Lc_SubsystemEn_CODE			CHAR(2) = 'EN',
          @Lc_ReasonStatusSy_CODE		CHAR(2) = 'SY',
          @Lc_ReasonStatusNy_CODE		CHAR(2) = 'NY',
          @Lc_SourceLocCsln_CODE        CHAR(3) = 'CSL',
          @Lc_StatusComplete_CODE       CHAR(4) = 'COMP',
          @Lc_StatusStart_CODE          CHAR(4) = 'STRT',
          @Lc_ActivityMajorCsLn_CODE    CHAR(4) = 'CSLN',
          @Lc_ActivityMinorCslnm_CODE   CHAR(5) = 'CSLNM',
          @Lc_ActivityMinorSadmh_CODE   CHAR(5) = 'SADMH',
          @Lc_ActivityMinorInfff_CODE   CHAR(5) = 'INFFF',
          @Lc_ActivityMinorRroah_CODE   CHAR(5) = 'RROAH',
          @Lc_ActivityMinorMosle_CODE   CHAR(5) = 'MOSLE',
          @Lc_ActivityMinorRfins_CODE   CHAR(5) = 'RFINS',
          @Lc_ActivityMinorAcdna_CODE   CHAR(5) = 'ACDNA',
          @Lc_ActivityMinorStcln_CODE   CHAR(5) = 'STCLN',
          @Lc_BatchRunUser_TEXT         CHAR(5) = 'BATCH',
          @Lc_BateErrorE0944_CODE       CHAR(5) = 'E0944',
          @Lc_Job_ID                    CHAR(7) = 'DEB6009',          
          @Lc_Successful_TEXT           CHAR(10) = 'SUCCESSFUL',
          @Lc_WorkerDelegate_ID         CHAR(30) = ' ',
          @Ls_Procedure_NAME            VARCHAR(50) = 'BATCH_ENF_OUTGOING_CSLN$SP_EXTRACT_CSLN_DAILY',
          @Ls_Process_NAME              VARCHAR(50) = 'BATCH_ENF_OUTGOING_CSLN',
          @Ld_High_DATE                 DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB						NUMERIC(1) = 0,
          @Ln_CommitFreqParm_QNTY			NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY	NUMERIC(5),
          @Ln_Topic_IDNO                    NUMERIC(10),
          @Ln_Error_NUMB					NUMERIC(11),
          @Ln_ErrorLine_NUMB				NUMERIC(11),   
          @Ln_TransactionEventSeq_NUMB      NUMERIC(19) = 0,
          @Ln_SeqUnique_IDNO                NUMERIC(19) = 0,       
          @Li_FetchStatus_QNTY              SMALLINT,
          @Lc_Msg_CODE						CHAR(1),
          @Lc_BateError_CODE				CHAR(5),          
          @Ls_FileName_NAME					VARCHAR(50),
          @Ls_FileLocation_TEXT				VARCHAR(80),
          @Ls_Sql_TEXT                      VARCHAR(100),
          @Ls_FileSource_TEXT               VARCHAR(130),
          @Ls_Sqldata_TEXT                  VARCHAR(1000),
          @Ls_Query_TEXT                    VARCHAR(1000),
          @Ls_ErrorMessage_TEXT             VARCHAR(4000),
          @Ls_DescriptionError_TEXT         VARCHAR(4000),          
          @Ld_Run_DATE                      DATE,
          @Ld_LastRun_DATE                  DATE,
          @Ld_Start_DATE                    DATETIME2(0);
  DECLARE @Ln_CaseMemberCur_Case_IDNO       NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO  NUMERIC(10);

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Lc_BateError_CODE = @Lc_BateErrorE0944_CODE;
   SET @Ls_Sql_TEXT = 'CREATE ##ExtCsln_P1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   CREATE TABLE ##ExtCsln_P1
    (
      Record_TEXT VARCHAR(900)
    );
   
   BEGIN TRANSACTION CSLN_DAILY;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS2';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS2
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @As_File_NAME               = @Ls_FileName_NAME OUTPUT,
    @As_FileLocation_TEXT       = @Ls_FileLocation_TEXT OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'RUN DATE AND LAST RUN DATE VALIDATION';
   SET @Ls_Sqldata_TEXT = 'LAST RUN DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR) + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   IF DATEADD(DAY, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';

     RAISERROR(50001,16,1);
    END
    
   SET @Ls_Sql_TEXT = 'FILE LOCATION AND NAME VALIDATION';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);   
   SET @Ls_FileSource_TEXT = ISNULL(LTRIM (RTRIM (@Ls_FileLocation_TEXT)) + LTRIM (RTRIM (@Ls_FileName_NAME)), @Lc_Space_TEXT);

   IF @Ls_FileSource_TEXT = @Lc_Space_TEXT
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INVALID FILE NAME AND FILE LOCATION';

     RAISERROR (50001,16,1);
    END;
    
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-
   SELECT x.NcpPf_IDNO MemberMci_IDNO,
          CAST(SUBSTRING(x.LastNcp_NAME, 1, 15) AS CHAR(15)) Last_NAME,
          CAST(SUBSTRING(x.FirstNcp_NAME, 1, 11) AS CHAR(11)) First_NAME,
          CAST(SUBSTRING(x.MiddleNcp_NAME, 1, 1) AS CHAR(1)) Middle_NAME,
          CAST(SUBSTRING(x.SuffixNcp_NAME, 1, 3) AS CHAR(3)) Suffix_NAME,
          x.MemberSsn_NUMB,
          CONVERT(VARCHAR(8), x.BirthNcp_DATE, 112) Birth_DATE,
          x.LkcaAttn_ADDR,
          CAST(SUBSTRING(x.LkcaLine1_ADDR, 1, 40) AS CHAR(40)) LkcaLine1_ADDR,
          CAST(SUBSTRING(x.LkcaLine2_ADDR, 1, 40) AS CHAR(40)) LkcaLine2_ADDR,
          x.LkcaCity_ADDR,
          x.LkcaState_ADDR,
          CAST(SUBSTRING(x.LkcaZip_ADDR, 1, 9) AS CHAR(9)) LkcaZip_ADDR,
          x.Attn_ADDR,
          CAST(SUBSTRING(x.Line1_ADDR, 1, 40) AS CHAR(40)) Line1_ADDR,
          CAST(SUBSTRING(x.Line2_ADDR, 1, 40) AS CHAR(40)) Line2_ADDR,
          x.City_ADDR,
          x.State_ADDR,
          CAST(SUBSTRING(x.Zip_ADDR, 1, 9) AS CHAR(9)) Zip_ADDR,
          x.HomePhone_NUMB,
          x.CellPhone_NUMB,
          CAST(x.InsCompany_IDNO AS CHAR(9)) InsCompany_IDNO,
          x.InsCompany_NAME,
          CAST(SUBSTRING(x.InsCompanyLine1_ADDR, 1, 40) AS CHAR(40)) InsCompanyLine1_ADDR,
          CAST(SUBSTRING(x.InsCompanyLine2_ADDR, 1, 40) AS CHAR(40)) InsCompanyLine2_ADDR,
          x.InsCompanyCity_ADDR,
          x.InsCompanyState_ADDR,
          CAST(SUBSTRING(x.InsCompanyZip_ADDR, 1, 9) AS CHAR(9)) InsCompanyZip_ADDR,
          x.InsClaim_NUMB,
          CAST(SUBSTRING(x.InsClaimType_CODE, 1, 1) AS CHAR(1)) InsClaimType_CODE,
          CONVERT(VARCHAR(8), x.InsClaimLoss_DATE, 112) InsClaimLoss_DATE,
          CASE
           WHEN (SELECT CHARINDEX(' ', x.InsConcatFirstLast_NAME, -1) - 1) > 0
            THEN (SELECT SUBSTRING(SUBSTRING(LTRIM(RTRIM(x.InsConcatFirstLast_NAME)), 1, CHARINDEX(' ', x.InsConcatFirstLast_NAME, -1) - 1), 1, 20))
           ELSE @Lc_Space_TEXT
          END InsContactFirst_NAME,
          CASE
           WHEN (SELECT CHARINDEX(' ', x.InsConcatFirstLast_NAME, -1) - 1) > 0
            THEN (SELECT SUBSTRING(SUBSTRING(LTRIM(RTRIM(x.InsConcatFirstLast_NAME)), CHARINDEX(' ', x.InsConcatFirstLast_NAME, -1), LEN(LTRIM(RTRIM(x.InsConcatFirstLast_NAME)))), 1, 30))
           ELSE @Lc_Space_TEXT
          END InsContactLast_NAME,
          CAST(x.InsContactPhone_NUMB AS CHAR(25)) InsContactPhone_NUMB,
          CAST(x.InsFaxContact_NUMB AS CHAR(25)) InsFaxContact_NUMB,
          x.Case_IDNO,
          x.File_ID,
          CONVERT(VARCHAR(8), x.OrderIssued_DATE, 112) OrderIssued_DATE,
          SUBSTRING(CAST(x.TotalArrears_AMNT AS CHAR(11)), 1, 8) TotalArrears_AMNT,
          x.TypeAction_CODE,
          x.Status_DATE,
		  x.MajorIntSeq_NUMB,
		  x.Forum_IDNO,
          x.Action_DATE
      INTO ##ExtTempCsln_P1
     FROM (SELECT DISTINCT
                  a.NcpPf_IDNO,
                  a.LastNcp_NAME,
                  a.FirstNcp_NAME,
                  a.MiddleNcp_NAME,
                  a.SuffixNcp_NAME,
                  d.MemberSsn_NUMB,
                  a.BirthNcp_DATE,
                  ISNULL(ahis.LkcaAttn_ADDR, @Lc_Space_TEXT) LkcaAttn_ADDR,
                  ISNULL(ahis.LkcaLine1_ADDR, @Lc_Space_TEXT) LkcaLine1_ADDR,
                  ISNULL(ahis.LkcaLine2_ADDR, @Lc_Space_TEXT) LkcaLine2_ADDR,
                  ISNULL(ahis.LkcaCity_ADDR, @Lc_Space_TEXT) LkcaCity_ADDR,
                  ISNULL(ahis.LkcaState_ADDR, @Lc_Space_TEXT) LkcaState_ADDR,
                  ISNULL(ahis.LkcaZip_ADDR, @Lc_Space_TEXT) LkcaZip_ADDR,
                  ISNULL(ahis.Attn_ADDR, @Lc_Space_TEXT) Attn_ADDR,
                  ISNULL(ahis.Line1_ADDR, @Lc_Space_TEXT) Line1_ADDR,
                  ISNULL(ahis.Line2_ADDR, @Lc_Space_TEXT) Line2_ADDR,
                  ISNULL(ahis.City_ADDR, @Lc_Space_TEXT) City_ADDR,
                  ISNULL(ahis.State_ADDR, @Lc_Space_TEXT) State_ADDR,
                  ISNULL(ahis.Zip_ADDR, @Lc_Space_TEXT) Zip_ADDR,
                  ISNULL(d.HomePhone_NUMB, @Lc_StringZero_TEXT) HomePhone_NUMB,
                  ISNULL(d.CellPhone_NUMB, @Lc_StringZero_TEXT) CellPhone_NUMB,
                  b.OtherParty_IDNO InsCompany_IDNO,
                  b.OtherParty_NAME InsCompany_NAME,
                  b.Line1_ADDR InsCompanyLine1_ADDR,
                  b.Line2_ADDR InsCompanyLine2_ADDR,
                  b.City_ADDR InsCompanyCity_ADDR,
                  b.State_ADDR InsCompanyState_ADDR,
                  b.Zip_ADDR InsCompanyZip_ADDR,
                  c.AccountAssetNo_TEXT InsClaim_NUMB,
                  c.AcctType_CODE InsClaimType_CODE,
                  c.ClaimLoss_DATE InsClaimLoss_DATE,
                  b.DescriptionContactOther_TEXT InsConcatFirstLast_NAME,
                  ISNULL(b.Phone_NUMB, @Lc_StringZero_TEXT) InsContactPhone_NUMB,
                  ISNULL(b.Fax_NUMB, @Lc_StringZero_TEXT) InsFaxContact_NUMB,
                  a.Case_IDNO,
                  g.Status_DATE,
                  g.ActivityMinor_CODE,
                  g.ReasonStatus_CODE,
				  g.MajorIntSeq_NUMB,
                  a.File_ID,
				  f.Forum_IDNO,
                  a.OrderIssued_DATE,
                  a.Arrears_AMNT TotalArrears_AMNT,
                  CASE
                   WHEN g.ActivityMinor_CODE = @Lc_ActivityMinorCslnm_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusLm_CODE
                    THEN @Lc_TypeAction1_CODE
                   WHEN g.ActivityMinor_CODE = @Lc_ActivityMinorMosle_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusLj_CODE
                    THEN @Lc_TypeAction3_CODE
                   ELSE
                    CASE
                     WHEN (SELECT COUNT(1)
                                    FROM (SELECT DISTINCT
                                                 x.MemberMci_IDNO,
                                                 x.Case_IDNO,
                                                 x.ActivityMajor_CODE,
                                                 x.Status_CODE,
                                                 (CAST(LTRIM(RTRIM(x.MemberMci_IDNO)) AS VARCHAR) + CAST(LTRIM(RTRIM(x.Reference_ID)) AS VARCHAR) + CAST(LTRIM(RTRIM(x.OthpSource_IDNO)) AS VARCHAR)) MemberClaim_NUMB
                                            FROM DMJR_Y1 x
                                           WHERE x.ActivityMajor_CODE = @Lc_ActivityMajorCsLn_CODE
                                             AND x.Status_CODE = @Lc_StatusStart_CODE
                                             AND x.MajorIntSeq_NUMB = (SELECT MAX(z.MajorIntSeq_NUMB)
                                                                         FROM DMJR_Y1 z
                                                                        WHERE z.Case_IDNO = x.Case_IDNO
                                                                          AND z.MemberMci_IDNO = x.MemberMci_IDNO
                                                                          AND z.ActivityMajor_CODE = x.ActivityMajor_CODE
                                                                          AND z.Status_CODE = x.Status_CODE)) ab
                                   WHERE ab.MemberMci_IDNO = a.NcpPf_IDNO
                                     AND ab.Case_IDNO != a.Case_IDNO
                                     AND ab.MemberClaim_NUMB = (CAST(LTRIM(RTRIM(a.NcpPf_IDNO)) AS VARCHAR) + CAST(LTRIM(RTRIM(f.Reference_ID)) AS VARCHAR) + CAST(LTRIM(RTRIM(f.OthpSource_IDNO)) AS VARCHAR))) >= 1
                      THEN @Lc_TypeAction9_CODE
                     ELSE @Lc_TypeAction4_CODE
                    END
                  END TypeAction_CODE,
                  @Lc_Space_TEXT Action_DATE              
             FROM ENSD_Y1 a,
                  OTHP_Y1 b,
                  ASFN_Y1 c,
                  DEMO_Y1 d,
                  DMJR_Y1 f,
                  DMNR_Y1 g,
                  (SELECT DISTINCT
                          e.NcpPf_IDNO MemberMci_IDNO,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN
                            CASE
                             WHEN cm.LkcaMailingSame_INDC = @Lc_StringOne_TEXT
                              THEN @Lc_Space_TEXT
                             ELSE cm.Attn_ADDR
                            END
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN m.Attn_ADDR
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           ELSE @Lc_Space_TEXT
                          END Attn_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN
                            CASE
                             WHEN cm.LkcaMailingSame_INDC = @Lc_StringOne_TEXT
                              THEN @Lc_Space_TEXT
                             ELSE cm.Line1_ADDR
                            END
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN m.Line1_ADDR
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           ELSE @Lc_Space_TEXT
                          END Line1_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN
                            CASE
                             WHEN cm.LkcaMailingSame_INDC = @Lc_StringOne_TEXT
                              THEN @Lc_Space_TEXT
                             ELSE cm.Line2_ADDR
                            END
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN m.Line2_ADDR
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           ELSE @Lc_Space_TEXT
                          END Line2_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN
                            CASE
                             WHEN cm.LkcaMailingSame_INDC = @Lc_StringOne_TEXT
                              THEN @Lc_Space_TEXT
                             ELSE cm.City_ADDR
                            END
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN m.City_ADDR
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           ELSE @Lc_Space_TEXT
                          END City_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN
                            CASE
                             WHEN cm.LkcaMailingSame_INDC = @Lc_StringOne_TEXT
                              THEN @Lc_Space_TEXT
                             ELSE cm.State_ADDR
                            END
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN m.State_ADDR
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           ELSE @Lc_Space_TEXT
                          END State_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN
                            CASE
                             WHEN cm.LkcaMailingSame_INDC = @Lc_StringOne_TEXT
                              THEN @Lc_Space_TEXT
                             ELSE cm.Zip_ADDR
                            END
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN m.Zip_ADDR
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           ELSE @Lc_Space_TEXT
                          END Zip_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN cm.LkcaAttn_ADDR
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN c.Attn_ADDR
                           ELSE @Lc_Space_TEXT
                          END LkcaAttn_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN cm.LkcaLine1_ADDR
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN c.Line1_ADDR
                           ELSE @Lc_Space_TEXT
                          END LkcaLine1_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN cm.LkcaLine2_ADDR
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN c.Line2_ADDR
                           ELSE @Lc_Space_TEXT
                          END LkcaLine2_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN cm.LkcaCity_ADDR
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN c.City_ADDR
                           ELSE @Lc_Space_TEXT
                          END LkcaCity_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN cm.LkcaState_ADDR
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN c.State_ADDR
                           ELSE @Lc_Space_TEXT
                          END LkcaState_ADDR,
                          CASE
                           WHEN e.NcpPf_IDNO = cm.MemberMci_IDNO
                            THEN cm.LkcaZip_ADDR
                           WHEN e.NcpPf_IDNO = m.MemberMci_IDNO
                            THEN @Lc_Space_TEXT
                           WHEN e.NcpPf_IDNO = c.MemberMci_IDNO
                            THEN c.Zip_ADDR
                           ELSE @Lc_Space_TEXT
                          END LkcaZip_ADDR
                     FROM ENSD_Y1 e
                          LEFT OUTER JOIN (SELECT DISTINCT
                                                  c.MemberMci_IDNO,
                                                  CASE
                                                   WHEN (LTRIM(RTRIM(c.Line1_ADDR)) + LTRIM(RTRIM(c.Line2_ADDR)) + LTRIM(RTRIM(c.City_ADDR)) + LTRIM(RTRIM(c.State_ADDR))) = (LTRIM(RTRIM(m.Line1_ADDR)) + LTRIM(RTRIM(m.Line2_ADDR)) + LTRIM(RTRIM(m.City_ADDR)) + LTRIM(RTRIM(m.State_ADDR)))
                                                    THEN @Lc_StringOne_TEXT
                                                   ELSE @Lc_StringZero_TEXT
                                                  END LkcaMailingSame_INDC,
                                                  m.Attn_ADDR,
                                                  m.Line1_ADDR,
                                                  m.Line2_ADDR,
                                                  m.City_ADDR,
                                                  m.State_ADDR,
                                                  m.Zip_ADDR,
                                                  c.Attn_ADDR LkcaAttn_ADDR,
                                                  c.Line1_ADDR LkcaLine1_ADDR,
                                                  c.Line2_ADDR LkcaLine2_ADDR,
                                                  c.City_ADDR LkcaCity_ADDR,
                                                  c.State_ADDR LkcaState_ADDR,
                                                  c.Zip_ADDR LkcaZip_ADDR,
                                                  c.End_DATE LkcaEnd_DATE
                                             FROM (SELECT y.MemberMci_IDNO,
                                                          y.Attn_ADDR,
                                                          y.Line1_ADDR,
                                                          y.Line2_ADDR,
                                                          y.City_ADDR,
                                                          y.State_ADDR,
                                                          y.Zip_ADDR,
                                                          y.End_DATE
                                                     FROM AHIS_Y1 y
                                                    WHERE y.TypeAddress_CODE = @Lc_MailingAddress_CODE
                                                      AND y.End_DATE = @Ld_High_DATE
                                                      AND y.Status_CODE = @Lc_ConfirmedGood_CODE) m,
                                                  (SELECT z.MemberMci_IDNO,
                                                          z.Attn_ADDR,
                                                          z.Line1_ADDR,
                                                          z.Line2_ADDR,
                                                          z.City_ADDR,
                                                          z.State_ADDR,
                                                          z.Zip_ADDR,
                                                          z.End_DATE
                                                     FROM AHIS_Y1 z
                                                    WHERE TypeAddress_CODE = @Lc_LastKnowCourtAddress_CODE
                                                      AND z.End_DATE = @Ld_High_DATE
                                                      AND z.Status_CODE = @Lc_ConfirmedGood_CODE) c
                                            WHERE c.MemberMci_IDNO = m.MemberMci_IDNO) cm
                           ON cm.MemberMci_IDNO = e.NcpPf_IDNO
                          LEFT OUTER JOIN (SELECT DISTINCT
                                                  z.MemberMci_IDNO,
                                                  z.Attn_ADDR,
                                                  z.Line1_ADDR,
                                                  z.Line2_ADDR,
                                                  z.City_ADDR,
                                                  z.State_ADDR,
                                                  z.Zip_ADDR,
                                                  z.End_DATE
                                             FROM AHIS_Y1 z
                                            WHERE z.MemberMci_IDNO NOT IN (SELECT MemberMci_IDNO
                                                                             FROM AHIS_Y1 x
                                                                            WHERE x.TypeAddress_CODE = @Lc_LastKnowCourtAddress_CODE
                                                                              AND x.End_DATE = @Ld_High_DATE
                                                                              AND x.Status_CODE = @Lc_ConfirmedGood_CODE)
                                              AND z.TypeAddress_CODE = @Lc_MailingAddress_CODE
                                              AND z.End_DATE = @Ld_High_DATE
                                              AND z.Status_CODE = @Lc_ConfirmedGood_CODE) m
                           ON m.MemberMci_IDNO = e.NcpPf_IDNO
                          LEFT OUTER JOIN (SELECT DISTINCT
                                                  z.MemberMci_IDNO,
                                                  z.Attn_ADDR,
                                                  z.Line1_ADDR,
                                                  z.Line2_ADDR,
                                                  z.City_ADDR,
                                                  z.State_ADDR,
                                                  z.Zip_ADDR,
                                                  z.End_DATE
                                             FROM AHIS_Y1 z
                                            WHERE z.MemberMci_IDNO NOT IN (SELECT MemberMci_IDNO
                                                                             FROM AHIS_Y1 x
                                                                            WHERE x.TypeAddress_CODE = @Lc_MailingAddress_CODE
                                                                              AND x.End_DATE = @Ld_High_DATE
                                                                              AND x.Status_CODE = @Lc_ConfirmedGood_CODE)
                                              AND z.TypeAddress_CODE = @Lc_LastKnowCourtAddress_CODE
                                              AND z.End_DATE = @Ld_High_DATE
                                              AND z.Status_CODE = @Lc_ConfirmedGood_CODE) c
                           ON c.MemberMci_IDNO = e.NcpPf_IDNO) AS ahis
            WHERE f.Case_IDNO = a.Case_IDNO 
              AND f.ActivityMajor_CODE = @Lc_ActivityMajorCsLn_CODE
              AND f.MajorIntSeq_NUMB IN (SELECT z.MajorIntSeq_NUMB
                                           FROM DMJR_Y1 z
                                          WHERE z.Case_IDNO = f.Case_IDNO
                                            AND z.MemberMci_IDNO = f.MemberMci_IDNO
                                            AND z.ActivityMajor_CODE = f.ActivityMajor_CODE)
              AND g.Case_IDNO = a.Case_IDNO        
              AND g.MemberMci_IDNO = a.NcpPf_IDNO 
              AND ((g.ActivityMinor_CODE = @Lc_ActivityMinorCslnm_CODE
                    AND g.ReasonStatus_CODE = @Lc_ReasonStatusLm_CODE
                    AND f.Status_CODE = @Lc_StatusStart_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorSadmh_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusMt_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorInfff_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusNy_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorRroah_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusLl_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorMosle_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusLj_CODE
                        AND f.Status_CODE = @Lc_StatusStart_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorMosle_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusRz_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorMosle_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusVl_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorMosle_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusLk_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorRfins_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusRz_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorRfins_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusVl_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorRfins_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusLk_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)
                    OR (g.ActivityMinor_CODE = @Lc_ActivityMinorAcdna_CODE
                        AND g.ReasonStatus_CODE = @Lc_ReasonStatusMf_CODE
                        AND f.Status_CODE = @Lc_StatusComplete_CODE)) 
              AND g.Status_CODE = @Lc_StatusComplete_CODE
              AND g.ActivityMajor_CODE = @Lc_ActivityMajorCsLn_CODE
              AND g.MajorIntSeq_NUMB = f.MajorIntSeq_NUMB
              AND d.MemberMci_IDNO = a.NcpPf_IDNO 
              AND f.MemberMci_IDNO = a.NcpPf_IDNO 
              AND c.MemberMci_IDNO = a.NcpPf_IDNO 
              AND c.AccountAssetNo_TEXT = f.Reference_ID 
              AND c.SourceLoc_CODE = @Lc_SourceLocCsln_CODE 
              -- 13848 - ECSLN - Duplicate records in the CSLN output table -START-
              AND c.OthpInsFin_IDNO = f.OthpSource_IDNO
              -- 13848 - ECSLN - Duplicate records in the CSLN output table -END-
              AND b.OtherParty_IDNO = f.OthpSource_IDNO 
              AND b.EndValidity_DATE = @Ld_High_DATE 
              AND ahis.MemberMci_IDNO = a.NcpPf_IDNO) AS x            
    ORDER BY x.NcpPf_IDNO;
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-
    
   SET @Ls_Sql_TEXT='DELETE ECSLN_Y1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   DELETE FROM ECSLN_Y1;

   SET @Ls_Sql_TEXT = 'INSERT NCP ECSLN_Y1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   INSERT INTO ECSLN_Y1
               (MemberMci_IDNO,
                Last_NAME,
                First_NAME,
                Middle_NAME,
                Suffix_NAME,
                MemberSsn_NUMB,
                Birth_DATE,
                LkcaAttn_ADDR,
                LkcaLine1_ADDR,
                LkcaLine2_ADDR,
                LkcaCity_ADDR,
                LkcaState_ADDR,
                LkcaZip_ADDR,
                Attn_ADDR,
                Line1_ADDR,
                Line2_ADDR,
                City_ADDR,
                State_ADDR,
                Zip_ADDR,
                HomePhone_NUMB,
                CellPhone_NUMB,
                InsCompany_IDNO,
                InsCompany_NAME,
                InsCompanyLine1_ADDR,
                InsCompanyLine2_ADDR,
                InsCompanyCity_ADDR,
                InsCompanyState_ADDR,
                InsCompanyZip_ADDR,
                InsClaim_NUMB,
                InsClaimType_CODE,
                InsClaimLoss_DATE,
                InsContactFirst_NAME,
                InsContactLast_NAME,
                InsContactPhone_NUMB,
                InsFaxContact_NUMB,
                Case_IDNO,
                File_ID,
                OrderIssued_DATE,
                TotalArrears_AMNT,
                TypeAction_CODE,
                Action_DATE)
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-
   SELECT   y.MemberMci_IDNO,
            y.Last_NAME,
            y.First_NAME,
            y.Middle_NAME,
            y.Suffix_NAME,
            y.MemberSsn_NUMB,
            y.Birth_DATE,
            y.LkcaAttn_ADDR,
            y.LkcaLine1_ADDR,
            y.LkcaLine2_ADDR,
            y.LkcaCity_ADDR,
            y.LkcaState_ADDR,
            y.LkcaZip_ADDR,
            y.Attn_ADDR,
            y.Line1_ADDR,
            y.Line2_ADDR,
            y.City_ADDR,
            y.State_ADDR,
            y.Zip_ADDR,
            y.HomePhone_NUMB,
            y.CellPhone_NUMB,
            y.InsCompany_IDNO,
            y.InsCompany_NAME,
            y.InsCompanyLine1_ADDR,
            y.InsCompanyLine2_ADDR,
            y.InsCompanyCity_ADDR,
            y.InsCompanyState_ADDR,
            y.InsCompanyZip_ADDR,
            y.InsClaim_NUMB,
            y.InsClaimType_CODE,
            y.InsClaimLoss_DATE,
            y.InsContactFirst_NAME,
            y.InsContactLast_NAME,
            y.InsContactPhone_NUMB,
            y.InsFaxContact_NUMB,
            y.Case_IDNO,
            y.File_ID,
            y.OrderIssued_DATE,
            y.TotalArrears_AMNT,
            y.TypeAction_CODE,
            y.Action_DATE
     FROM ##ExtTempCsln_P1 y
    WHERE y.Status_DATE = (SELECT MAX(Status_DATE) Status_DATE
						     FROM ##ExtTempCsln_P1 a
						    WHERE a.MemberMci_IDNO = y.MemberMci_IDNO						  
						      AND a.Case_IDNO = y.Case_IDNO)
	  -- 13848 - ECSLN - Duplicate records in the CSLN output table -START-
	  AND (y.Status_DATE > @Ld_LastRun_DATE AND y.Status_DATE <= @Ld_Run_DATE)
	  -- 13848 - ECSLN - Duplicate records in the CSLN output table -END-
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF(@Li_RowCount_QNTY = 0)
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'NO RECORD(S) TO PROCESS';

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION';
     SET @Ls_SqlData_TEXT = 'Procedure_NAME = ' + @Ls_Procedure_NAME + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', Error_NUMB = ' + CAST(@Ln_Error_NUMB AS VARCHAR)+ ', ErrorLine_NUMB = ' + CAST(@Ln_ErrorLine_NUMB AS VARCHAR);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
     SET @Ls_SqlData_TEXT = 'Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeWarning_CODE + ', Line_NUMB = ' + CAST(@Ln_Zero_NUMB AS VARCHAR) + ', Error_CODE = ' + @Lc_BateError_CODE + ', DescriptionError_TEXT = ' + @Ls_DescriptionError_TEXT + ', ListKey_TEXT = ' + @Ls_SqlData_TEXT;

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Ls_Process_NAME,
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeWarning_CODE,
      @An_Line_NUMB                = @Ln_Zero_NUMB,
      @Ac_Error_CODE               = @Lc_BateError_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_SqlData_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '');
   
   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
    @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
    @Ac_Process_ID               = @Lc_Job_ID,
    @Ad_EffectiveEvent_DATE      = @Ld_Run_DATE,
    @Ac_Note_INDC                = @Lc_Note_INDC,
    @An_EventFunctionalSeq_NUMB  = @Ln_Zero_NUMB,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
    @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
   
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END
   
   SET @Ls_Sql_TEXT = 'GET THE MAX OF TOPIC IDNO FROM ITOPC_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);		

   SELECT @Ln_SeqUnique_IDNO = ISNULL(MAX(a.Seq_IDNO), 0) 
     FROM ITOPC_Y1 a;
  
   IF @Ln_SeqUnique_IDNO = 0 
    BEGIN
	  SET @Ls_Sql_TEXT = 'INSERT ITOPC_Y1';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);   
	  
	  INSERT INTO ITOPC_Y1
			   (Entered_DATE)
		VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()--Entered_DATE
	  );   

	  SET @Ls_Sql_TEXT = 'GET THE MAX OF TOPIC IDNO FROM ITOPC_Y1 - 2';
	  SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '') + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
	 
      SELECT @Ln_SeqUnique_IDNO = ISNULL(MAX(a.Seq_IDNO), 0) 
	   FROM ITOPC_Y1 a;	   
		 
    END 
   
   SET @Ls_Sql_TEXT = 'INSERT CJNR_Y1';
   SET @Ls_SqlData_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '')+', ActivityMinor_CODE = '+ @Lc_ActivityMinorStcln_CODE + ', Run_DATE = '+ CAST( @Ld_Run_DATE  AS VARCHAR)+ ', StatusComplete_CODE = '+ @Lc_StatusComplete_CODE  +', ReasonStatusSy_CODE = '+ @Lc_ReasonStatusSy_CODE +', BatchRunUser_TEXT = '+ @Lc_BatchRunUser_TEXT +', SubsystemLo_CODE = '+@Lc_SubsystemEn_CODE  + ', ActivityMajorCase_CODE = '+ @Lc_ActivityMajorCsln_CODE +', StatusStart_CODE = '+ @Lc_StatusStart_CODE;
   
   WITH BulkInsert_CjnrItopc
   AS(
           -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-
    SELECT y.Case_IDNO AS Case_IDNO,
		   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-
		   0 AS OrderSeq_NUMB,
		   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-
		   y.MajorIntSEQ_NUMB AS MajorIntSEQ_NUMB,
		   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-
		   ISNULL((SELECT MAX(x.MinorIntSeq_NUMB)
		  		     FROM UDMNR_V1 x	
		   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-	   
		  	        WHERE y.Case_IDNO = x.Case_IDNO
		  		      AND y.MajorIntSEQ_NUMB = x.MajorIntSEQ_NUMB), 0) + ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO ORDER BY y.Case_IDNO) AS MinorIntSeq_NUMB,
		   y.MemberMci_IDNO AS MemberMci_IDNO,		
		   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-   
		   @Lc_ActivityMinorStcln_CODE AS ActivityMinor_CODE,
		   @Lc_Space_TEXT AS ActivityMinorNext_CODE,
		   @Ld_Run_DATE AS Entered_DATE,
		   @Ld_Run_DATE AS Due_DATE,
		   @Ld_Run_DATE AS Status_DATE,
		   @Lc_StatusComplete_CODE AS Status_CODE,		   
		   @Lc_ReasonStatusSy_CODE AS ReasonStatus_CODE, 
		   0 AS Schedule_NUMB,
		   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-
		   y.Forum_IDNO,
		   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-
		   0 AS NoTotalReplies_QNTY,
		   0 AS NoTotalViews_QNTY,
		   0 AS PostLastPoster_IDNO,
		   @Lc_BatchRunUser_TEXT AS UserLastPoster_ID,
		   dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS LastPost_DTTM,
		   @Ld_Run_DATE AS AlertPrior_DATE,
		   @Ld_Run_DATE AS BeginValidity_DATE,
		   @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
		   dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
		   @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
		   @Lc_Space_TEXT AS WorkerDelegate_ID,							  
		   @Lc_SubsystemEn_CODE AS Subsystem_CODE,
		   @Lc_ActivityMajorCsln_CODE AS ActivityMajor_CODE           
      FROM ##ExtTempCsln_P1 y
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-
    WHERE y.Status_DATE = (SELECT MAX(Status_DATE) Status_DATE
						     FROM ##ExtTempCsln_P1 a
						    WHERE a.MemberMci_IDNO = y.MemberMci_IDNO						  
						      AND a.Case_IDNO = y.Case_IDNO)
	  -- 13848 - ECSLN - Duplicate records in the CSLN output table -START-
	  AND (y.Status_DATE > @Ld_LastRun_DATE AND y.Status_DATE <= @Ld_Run_DATE)
	  -- 13848 - ECSLN - Duplicate records in the CSLN output table -END-
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-
   )

   INSERT INTO CJNR_Y1
		  (Case_IDNO,
		   OrderSeq_NUMB,
		   MajorIntSEQ_NUMB,
		   MinorIntSeq_NUMB,
		   MemberMci_IDNO,
		   ActivityMinor_CODE,
		   ActivityMinorNext_CODE,
		   Entered_DATE,
		   Due_DATE,
		   Status_DATE,
		   Status_CODE,
		   ReasonStatus_CODE,
		   Schedule_NUMB,
		   Forum_IDNO,
		   Topic_IDNO,
		   TotalReplies_QNTY,
		   TotalViews_QNTY,
		   PostLastPoster_IDNO,
		   UserLastPoster_ID,
		   LastPost_DTTM,
		   AlertPrior_DATE,
		   BeginValidity_DATE,
		   WorkerUpdate_ID,
		   Update_DTTM,
		   TransactionEventSeq_NUMB,
		   WorkerDelegate_ID,
		   Subsystem_CODE,
		   ActivityMajor_CODE)		
        OUTPUT @Ld_Run_DATE
		INTO ITOPC_Y1   
		SELECT Case_IDNO,
			   OrderSeq_NUMB,
			   MajorIntSEQ_NUMB,
			   MinorIntSeq_NUMB,
			   MemberMci_IDNO,
			   ActivityMinor_CODE,
			   ActivityMinorNext_CODE,
			   Entered_DATE,
			   Due_DATE,
			   Status_DATE,
			   Status_CODE,
			   ReasonStatus_CODE,
			   Schedule_NUMB,
			   Forum_IDNO,
			   @Ln_SeqUnique_IDNO + (ROW_NUMBER() OVER( ORDER BY TransactionEventSeq_NUMB)) AS Topic_IDNO,
			   NoTotalReplies_QNTY,
			   NoTotalViews_QNTY,
			   PostLastPoster_IDNO,
			   UserLastPoster_ID,
			   LastPost_DTTM,
			   AlertPrior_DATE,
			   BeginValidity_DATE,
			   WorkerUpdate_ID,	
			   Update_DTTM,
			   TransactionEventSeq_NUMB,
			   WorkerDelegate_ID,
			   Subsystem_CODE,
			   ActivityMajor_CODE
		  FROM BulkInsert_CjnrItopc;

   SET @Ls_Sql_TEXT = 'INSERT ##ExtCsln_P1';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   INSERT INTO ##ExtCsln_P1
               (Record_TEXT)
   SELECT (CAST(RIGHT((REPLICATE(@Lc_StringZero_TEXT, 10) + LTRIM(RTRIM(a.MemberMci_IDNO))), 10) AS CHAR(10)) + CAST(LEFT((LTRIM(RTRIM(a.Last_NAME)) + REPLICATE(@Lc_Space_TEXT, 15)), 15) AS CHAR(15)) + CAST(LEFT((LTRIM(RTRIM(a.First_NAME)) + REPLICATE(@Lc_Space_TEXT, 11)), 11) AS CHAR(11)) + CAST(LEFT((LTRIM(RTRIM(a.Middle_NAME)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1)) + CAST(LEFT((LTRIM(RTRIM(a.Suffix_NAME)) + REPLICATE(@Lc_Space_TEXT, 3)), 3) AS CHAR(3)) + CAST(RIGHT((REPLICATE(@Lc_StringZero_TEXT, 9) + LTRIM(RTRIM(a.MemberSsn_NUMB))), 9) AS CHAR(9)) + CAST(LEFT((LTRIM(RTRIM(a.Birth_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaAttn_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaLine1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaLine2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40)AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaCity_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaState_ADDR)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) + CAST(LEFT((LTRIM(RTRIM(a.LkcaZip_ADDR)) + REPLICATE(@Lc_Space_TEXT, 9)), 9) AS CHAR(9)) + CAST(LEFT((LTRIM(RTRIM(a.Attn_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.Line1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.Line2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.City_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.State_ADDR)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) + CAST(LEFT((LTRIM(RTRIM(a.Zip_ADDR)) + REPLICATE(@Lc_Space_TEXT, 9)), 9) AS CHAR(9)) + CAST(LEFT((LTRIM(RTRIM(a.HomePhone_NUMB)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25)) + CAST(LEFT((LTRIM(RTRIM(a.CellPhone_NUMB)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompany_NAME)) + REPLICATE(@Lc_Space_TEXT, 80)), 80) AS CHAR(80)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyLine1_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyLine2_ADDR)) + REPLICATE(@Lc_Space_TEXT, 40)), 40) AS CHAR(40)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyCity_ADDR)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyState_ADDR)) + REPLICATE(@Lc_Space_TEXT, 2)), 2) AS CHAR(2)) + CAST(LEFT((LTRIM(RTRIM(a.InsCompanyZip_ADDR)) + REPLICATE(@Lc_Space_TEXT, 9)), 9) AS CHAR(9)) + CAST(LEFT((LTRIM(RTRIM(a.InsClaim_NUMB)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.InsClaimType_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1)) + CAST(LEFT((LTRIM(RTRIM(a.InsClaimLoss_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8)) + CAST(LEFT((LTRIM(RTRIM(a.InsContactFirst_NAME)) + REPLICATE(@Lc_Space_TEXT, 20)), 20) AS CHAR(20)) + CAST(LEFT((LTRIM(RTRIM(a.InsContactLast_NAME)) + REPLICATE(@Lc_Space_TEXT, 30)), 30) AS CHAR(30)) + CAST(LEFT((LTRIM(RTRIM(a.InsContactPhone_NUMB)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25)) + CAST(LEFT((LTRIM(RTRIM(a.InsFaxContact_NUMB)) + REPLICATE(@Lc_Space_TEXT, 25)), 25) AS CHAR(25)) + CAST(LEFT((LTRIM(RTRIM(a.Case_IDNO)) + REPLICATE(@Lc_Space_TEXT, 6)), 6) AS CHAR(6)) + CAST(LEFT((LTRIM(RTRIM(a.File_ID)) + REPLICATE(@Lc_Space_TEXT, 11)), 11) AS CHAR(11)) + CAST(LEFT((LTRIM(RTRIM(a.OrderIssued_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8)) + @Lc_State_CODE + CAST(RIGHT((REPLICATE(@Lc_StringZero_TEXT, 8) + LTRIM(RTRIM(a.TotalArrears_AMNT))), 8) AS CHAR(8)) + CAST(LEFT((LTRIM(RTRIM(a.TypeAction_CODE)) + REPLICATE(@Lc_Space_TEXT, 1)), 1) AS CHAR(1)) + CAST(LEFT((LTRIM(RTRIM(a.Action_DATE)) + REPLICATE(@Lc_Space_TEXT, 8)), 8) AS CHAR(8)) + REPLICATE(@Lc_Space_TEXT, 87)) AS Record_TEXT
     FROM ECSLN_Y1 a
    ORDER BY a.MemberMci_IDNO;

   COMMIT TRANSACTION CSLN_DAILY;

   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtCsln_P1';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_Sqldata_TEXT ='FILE LOCATION = ' + @Ls_FileLocation_TEXT + ', FILE NAME = ' + @Ls_FileName_NAME + ', QUERY = ' + @Ls_Query_TEXT;

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_FileName_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   BEGIN TRANSACTION CSLN_DAILY;

   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

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
   SET @Ls_Sqldata_TEXT ='JOB ID = ' + @Lc_Job_ID + ', RUN DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', START DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', PACKAGE NAME = ' + @Ls_Process_NAME + ', PROCEDURE NAME = ' + @Ls_Procedure_NAME;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtCsln_P1 - 2';
   SET @Ls_Sqldata_TEXT = 'JOB ID = ' + ISNULL(@Lc_Job_ID, @Lc_Space_TEXT);

   DROP TABLE ##ExtCsln_P1;
   
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-
   DROP TABLE ##ExtTempCsln_P1;
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-

   COMMIT TRANSACTION CSLN_DAILY;
  END TRY

  BEGIN CATCH
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CSLN_DAILY;
    END

   IF OBJECT_ID('tempdb..##ExtCsln_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtCsln_P1;
    END
   
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -START-
   IF OBJECT_ID('tempdb..##ExtTempCsln_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtTempCsln_P1;
    END
   -- 13695 - ECSLN - Outgoing CSLN batch is not sending Notice of Release transactions -END-

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Process_NAME,
    @As_Procedure_NAME            = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_ErrorMessage_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Li_RowCount_QNTY;

   RAISERROR(@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END;


GO
