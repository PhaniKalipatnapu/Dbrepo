/****** Object:  StoredProcedure [dbo].[BATCH_FIN_RELEASE_DISB_HOLD$SP_PROCESS_RELEASE_DISB_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_RELEASE_DISB_HOLD$SP_PROCESS_RELEASE_DISB_HOLD

Programmer Name 	: IMP Team

Description			: This procedure will release the Disbursement on CP Holds and Address Holds automatically.
					  The CP Holds records to release disbursment is obtained by selecting all the held disbursement 
					  records from DHLD_Y1 (DHLD screen/DHLD_Y1 table) with the hold type "P-CP Hold", and release 
					  date lesser than the current batch processing date.The Address Holds records to release disbursment 
					  is obtained by all the disbursement records on "A-Address hold, check the following tables
					  (Direct Deposit (EFTI screen/ EFTR_Y1 table),Stored Value Card (SVCI screen /DCRS_Y1 table),
					  Checks (AHIS screen/ AHIS_Y1 table)), to determine  if there are any new information
					  available to identify the disbursement medium for the recipient.

Frequency			: 'DAILY'

Developed On		: 11/29/2011

Called BY			: None

Called On			: BATCH_FIN_RELEASE_DISB_HOLD$SP_INSERT_ESEM,BATCH_COMMON$SP_GET_BATCH_DETAILS, 
					  BATCH_COMMON$SP_UPDATE_PARM_DATE,BATCH_COMMON$SP_BSTL_LOG,BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified BY			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_RELEASE_DISB_HOLD$SP_PROCESS_RELEASE_DISB_HOLD]
AS
 BEGIN
  SET NOCOUNT ON;

   DECLARE @Li_AddressHoldRelease2110_NUMB  INT = 2110,
           @Li_ReleasePayeeHold2120_NUMB    INT = 2120,
           @Lc_StatusFailed_CODE            CHAR (1) = 'F',
           @Lc_Space_TEXT                   CHAR (1) = ' ',
           @Lc_No_INDC                      CHAR (1) = 'N',
           @Lc_StatusRelease_CODE			CHAR (1) = 'R',
           @Lc_Yes_INDC                     CHAR (1) = 'Y',
           @Lc_StatusSuccess_CODE           CHAR (1) = 'S',
           @Lc_StatusAbnormalend_CODE       CHAR (1) = 'A',
           @Lc_TypeHoldCp_CODE              CHAR (1) = 'P',
           @Lc_TypeHoldAddress_CODE         CHAR (1) = 'A',
           @Lc_StatusH_CODE                 CHAR (1) = 'H',
           @Lc_TypeHoldP_CODE               CHAR (1) = 'P',
           @Lc_TypeHoldC_CODE               CHAR (1) = 'C',
           @Lc_TypeHoldI_CODE               CHAR (1) = 'I',
           @Lc_TypeAddressM_CODE            CHAR (1) = 'M',
           @Lc_CheckRecipientCpNcp_CODE     CHAR (1) = '1',
           @Lc_TypeOthpO_CODE               CHAR (1) = 'O',
           @Lc_TypeErrorE_CODE              CHAR (1) = 'E',
           @Lc_ReasSysReles_CODE            CHAR (2) = 'SR',
           @Lc_StatusEftAc_CODE             CHAR (2) = 'AC',
           @Lc_TypeAddressSTA_CODE          CHAR (3) = 'STA',
           @Lc_SubTypeAddressSDU_CODE       CHAR (3) = 'SDU',
           @Lc_TypeAddressINT_CODE          CHAR (3) = 'INT',
           @Lc_SubTypeAddressFRC_CODE       CHAR (3) = 'FRC',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and 13518 the Release Date in the DHLD_Y1 table is less than the Run Date Change - Start -
		   @Lc_InstitutionSCI_NAME			CHAR (3) = 'SCI',
		   @Lc_InstitutionFED_NAME			CHAR (3) = 'FED',
		   @Lc_InstitutionWCF_NAME			CHAR (3) = 'WCF',
		   @Lc_InstitutionDSH_NAME			CHAR (3) = 'DSH',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and 13518 the Release Date in the DHLD_Y1 table is less than the Run Date Change - End -
		   @Lc_ReasonStatusSDCI_CODE        CHAR (4) = 'SDCI',
           @Lc_ReasonStatusSDCA_CODE        CHAR (4) = 'SDCA',
           @Lc_ReasonStatusSDNA_CODE        CHAR (4) = 'SDNA',
           @Lc_ReasonStatusSDOA_CODE        CHAR (4) = 'SDOA',
           @Lc_ReasonStatusSDFA_CODE        CHAR (4) = 'SDFA',
           @Lc_TableOthp_ID                 CHAR (4) = 'OTHP',
           @Lc_TableSubRtyp_ID              CHAR (4) = 'RTYP',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and 13518 the Release Date in the DHLD_Y1 table is less than the Run Date Change - Start -
		   @Lc_InstitutionBWCI_NAME			CHAR (4) = 'BWCI',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and 13518 the Release Date in the DHLD_Y1 table is less than the Run Date Change - End -
		   @Lc_BateErrorE1424_CODE          CHAR (5) = 'E1424',
           @Lc_TypeDisburseRefnd_CODE       CHAR (5) = 'REFND',
           @Lc_TypeDisburseRothp_CODE       CHAR (5) = 'ROTHP',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and 13518 the Release Date in the DHLD_Y1 table is less than the Run Date Change - Start -
		   @Lc_InstitutionJTVCC_NAME		CHAR (5) = 'JTVCC',
		   @Lc_InstitutionHRYCI_NAME		CHAR (5) = 'HRYCI',
		   -- Bug 13518 - SDCI Hold based on 7 Facility names and 13518 the Release Date in the DHLD_Y1 table is less than the Run Date Change - End -
		   @Lc_Job_ID                       CHAR (7) = 'DEB0600',
           @Lc_Successful_TEXT              CHAR (20) = 'SUCCESSFUL',
           @Lc_BatchRunUser_TEXT            CHAR (30) = 'BATCH',
           @Lc_TypeEntityRctno_CODE         CHAR (30) = 'RCTNO',
           @Lc_TypeEntityCase_CODE          CHAR (30) = 'CASE',
           @Lc_TypeEntityRcpid_CODE         CHAR (30) = 'RCPID',
           @Lc_TypeEntityRcpcd_CODE         CHAR (30) = 'RCPCD',
           @Lc_TypeEntityReldt_CODE         CHAR (30) = 'RELDT',
           @Ls_Procedure_NAME               VARCHAR (100) = 'SP_PROCESS_RELEASE_DISB_HOLD',
           @Ls_Process_NAME                 VARCHAR (100) = 'BATCH_FIN_RELEASE_DISB_HOLD',
           @Ld_High_DATE                    DATE = '12/31/9999',
           @Ld_Low_DATE                     DATE = '01/01/0001';
  DECLARE  @Ln_EventFunctionalSeq_NUMB      NUMERIC (4),
           @Ln_Row_QNTY                     NUMERIC (5) = 0,
           @Ln_CommitFreq_QNTY              NUMERIC (5) = 0,
           @Ln_CommitFreqParm_QNTY          NUMERIC (5),
           @Ln_ExceptionThreshold_QNTY      NUMERIC (5) = 0,
           @Ln_ExceptionThresholdParm_QNTY  NUMERIC (5),
           @Ln_ProcessedRecordCount_QNTY	NUMERIC (6) = 0,
           @Ln_ProcessedRecordsCommit_QNTY  NUMERIC (6) = 0,
           @Ln_Rowcount_QNTY                NUMERIC (7),
           @Ln_Cursor_QNTY                  NUMERIC (10) = 0,
           @Ln_RowRctno_QNTY                NUMERIC (10),
           @Ln_RowCase_QNTY                 NUMERIC (10),
           @Ln_RowRcpid_QNTY                NUMERIC (10),
           @Ln_RowRcpcd_QNTY                NUMERIC (10),
           @Ln_RowReldt_QNTY                NUMERIC (10),
           @Ln_Error_NUMB                   NUMERIC (11),
           @Ln_ErrorLine_NUMB               NUMERIC (11),
           @Ln_EventGlobalSeq_NUMB          NUMERIC (19),
           @Li_FetchStatus_QNTY             SMALLINT,
           @Lc_Msg_CODE                     CHAR (1),
           @Lc_CaseFlag_INDC                CHAR (1),
           @Lc_RcpidFlag_INDC               CHAR (1),
           @Lc_RcpcdFlag_INDC               CHAR (1),
           @Lc_RcptFlag_INDC                CHAR (1),
           @Lc_ReldtFlag_INDC               CHAR (1),
           @Lc_TypeError_CODE               CHAR (1),
           @Lc_BateError_CODE               CHAR (5),
           @Lc_CheckRecipientPrev_ID        CHAR (10),
           @Lc_Receipt_TEXT                 CHAR (30),
           @Ls_CursorLoc_TEXT               VARCHAR (200),
           @Ls_Sql_TEXT                     VARCHAR (1000),
           @Ls_Sqldata_TEXT                 VARCHAR (4000),
           @Ls_ErrorMessage_TEXT            VARCHAR (4000),
           @Ls_DescriptionError_TEXT        VARCHAR (4000),
           @Ls_BateRecord_TEXT              VARCHAR (4000),
           @Ld_LastRun_DATE                 DATE,
           @Ld_Run_DATE                     DATE,
           @Ld_Start_DATE                   DATETIME2;
   DECLARE @Ln_DhldCur_Case_IDNO                  NUMERIC(6),
           @Ln_DhldCur_OrderSeq_NUMB              NUMERIC(2),
           @Ln_DhldCur_ObligationSeq_NUMB         NUMERIC(2),
           @Ld_DhldCur_Batch_DATE                 DATE,
           @Lc_DhldCur_SourceBatch_CODE           CHAR(3),
           @Ln_DhldCur_Batch_NUMB                 NUMERIC(4),
           @Ln_DhldCur_SeqReceipt_NUMB            NUMERIC(6),
           @Ld_DhldCur_Release_DATE               DATE,
           @Lc_DhldCur_TypeDisburse_CODE          CHAR(5),
           @Ln_DhldCur_Transaction_AMNT           NUMERIC(11, 2),
           @Lc_DhldCur_TypeHold_CODE              CHAR(1),
           @Lc_DhldCur_ProcessOffset_INDC         CHAR(1),
           @Lc_DhldCur_CheckRecipient_ID          CHAR(10),
           @Lc_DhldCur_CheckRecipient_CODE        CHAR(1),
           @Ln_DhldCur_EventGlobalBeginSeq_NUMB   NUMERIC(19),
           @Ln_DhldCur_EventGlobalSupportSeq_NUMB NUMERIC(19),
           @Lc_DhldCur_ReasonStatus_CODE          CHAR(4),
           @Ln_DhldCur_Unique_IDNO                NUMERIC(19),
           @Ld_DhldCur_Disburse_DATE              DATE,
           @Ln_DhldCur_DisburseSeq_NUMB           NUMERIC(4),
           @Lc_DhldCur_AhisRec_INDC				  CHAR(1);

  CREATE TABLE #Tesem_P1
   (
     TypeEntity_CODE         CHAR(5) NOT NULL,
     Entity_ID               CHAR(30) NOT NULL,
     EventFunctionalSeq_NUMB NUMERIC(4) NOT NULL
   );

  BEGIN TRY
   SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Lc_CheckRecipientPrev_ID = '';
   
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END
    
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'LastRun_DATE = ' + CAST(DATEADD(D, 1, @Ld_LastRun_DATE) AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);
   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END
    
   SET @Ls_Sql_TEXT = 'DELETE #Tesem_P1';
   SET @Ls_Sqldata_TEXT = '';
   DELETE FROM #Tesem_P1;	
   
   BEGIN TRANSACTION DISB_REL_TRANC;
   
	/*
	    Release CP Holds:
		Select all the held disbursement records from Log Disbursement Hold (DHLD) 
		screen/DHLD_Y1 table with the hold type "P-CP Hold", and release date lesser than 
		the current batch processing date.
		
		Release Address Holds:
		For all the disbursement records on "A-Address hold", check the following tables, 
		to determine if there is new information available to identify the disbursement 
		medium for the recipient.
			Direct Deposit (EFTR_Y1 table)
			Stored Value Card (DCRS_Y1 table)
			Checks (AHIS screen/ AHIS_Y1 table)

	*/
   DECLARE Dhld_CUR INSENSITIVE CURSOR FOR
    SELECT a.Case_IDNO,
           a.OrderSeq_NUMB,
           a.ObligationSeq_NUMB,
           a.Batch_DATE,
           a.SourceBatch_CODE,
           a.Batch_NUMB,
           a.SeqReceipt_NUMB,
           a.Release_DATE,
           a.TypeDisburse_CODE,
           a.Transaction_AMNT,
           a.TypeHold_CODE,
           a.ProcessOffset_INDC,
           a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.EventGlobalBeginSeq_NUMB,
           a.EventGlobalSupportSeq_NUMB,
           a.ReasonStatus_CODE,
           a.Unique_IDNO,
           a.Disburse_DATE,
           a.DisburseSeq_NUMB,
           a.AhisRec_INDC
      FROM (SELECT x.Case_IDNO,
				   x.OrderSeq_NUMB,
				   x.ObligationSeq_NUMB,
				   x.Batch_DATE,
				   x.SourceBatch_CODE,
				   x.Batch_NUMB,
				   x.SeqReceipt_NUMB,
				   x.Release_DATE,
				   x.TypeDisburse_CODE,
				   x.Transaction_AMNT,
				   x.TypeHold_CODE,
				   x.ProcessOffset_INDC,
				   x.CheckRecipient_ID,
				   x.CheckRecipient_CODE,
				   x.EventGlobalBeginSeq_NUMB,
				   x.EventGlobalSupportSeq_NUMB,
				   x.ReasonStatus_CODE,
				   x.Unique_IDNO,
				   x.Disburse_DATE,
				   x.DisburseSeq_NUMB,
				   x.Status_CODE,
				   x.EndValidity_DATE,
                   CASE
                    WHEN EXISTS(SELECT 1
                                  FROM AHIS_Y1 m
                                 WHERE m.TypeAddress_CODE = @Lc_TypeAddressM_CODE
                                   AND @Ld_Run_DATE BETWEEN m.Begin_DATE AND m.End_DATE
                                   AND m.End_DATE = @Ld_High_DATE
                                   AND m.Status_CODE = @Lc_Yes_INDC
                                   AND CAST(m.MemberMci_IDNO AS VARCHAR) = x.CheckRecipient_ID)
                     THEN 1
                    ELSE 0
                   END AhisRec_INDC
              FROM DHLD_Y1 x ) a
      WHERE a.Status_CODE = @Lc_StatusH_CODE
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND ((a.TypeHold_CODE IN (@Lc_TypeHoldP_CODE,@Lc_TypeHoldC_CODE,@Lc_TypeHoldI_CODE)
             AND a.Release_DATE < @Ld_Run_DATE
             -- Bug 13518 - SDCI Hold based on 7 Facility names and 13518 the Release Date in the DHLD_Y1 table is less than the Run Date Change - Start -
             AND a.ReasonStatus_CODE <> @Lc_ReasonStatusSDCI_CODE)
             OR (a.TypeHold_CODE = @Lc_TypeHoldP_CODE 
                AND a.Release_DATE < @Ld_Run_DATE 
                AND a.ReasonStatus_CODE = @Lc_ReasonStatusSDCI_CODE -- CP HOLD - CP INCARCERATED
                 /*
				  If the Institution Name starts with one of the 7 facilities listed below and the Release Date in the DHLD_Y1 table is less than the Run Date, 
				  select the disbursement for release by end dating the existing record and inserting a new record with the Status of 'R-Ready for disbursement' 
				  and Release Reason of 'SR-System Release'.
				    1. BWCI  - Delores Baylor -Women's Correctional Institution
					2. JTVCC - James T. Vaughn Correctional Institution
					3. SCI   - Sussex Correctional Institution
					4. FED   - Federal Institution
					5. WCF   - John L. Webb Correctional Facility
					6. HRYCI - Howard R. Young Correctional Institution
					7. DSH   - Delaware State Hospital

				 */
                 AND EXISTS (SELECT 1
                               FROM MDET_Y1 n
                              WHERE a.CheckRecipient_ID = CAST(n.MemberMci_IDNO AS VARCHAR)
                                AND LTRIM(RTRIM(SUBSTRING(n.Institution_NAME,1,5))) IN (@Lc_InstitutionBWCI_NAME,@Lc_InstitutionJTVCC_NAME,@Lc_InstitutionSCI_NAME,@Lc_InstitutionFED_NAME,@Lc_InstitutionWCF_NAME,@Lc_InstitutionHRYCI_NAME,@Lc_InstitutionDSH_NAME)
                                AND n.EndValidity_DATE = @Ld_High_DATE)
                                )
				-- Bug 13518 - SDCI Hold based on 7 Facility names and 13518 the Release Date in the DHLD_Y1 table is less than the Run Date Change - End -
             OR (a.TypeHold_CODE = @Lc_TypeHoldAddress_CODE
                 AND ((a.ReasonStatus_CODE = @Lc_ReasonStatusSDCA_CODE -- CP BAD ADDRESS
                       AND (a.AhisRec_INDC = 1
                             OR EXISTS (SELECT 1
                                          FROM EFTR_Y1 e
                                         WHERE a.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                                           AND a.TypeDisburse_CODE <> @Lc_TypeDisburseRefnd_CODE -- REFUNDED FROM IDENTIFIED
                                           AND e.CheckRecipient_ID = a.CheckRecipient_ID
                                           AND e.EndValidity_DATE = @Ld_High_DATE
                                           AND e.StatusEft_CODE = @Lc_StatusEftAc_CODE)
                             OR EXISTS (SELECT 1
                                          FROM DCRS_Y1 d
                                         WHERE a.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                                           AND a.TypeDisburse_CODE <> @Lc_TypeDisburseRefnd_CODE -- REFUNDED FROM IDENTIFIED
                                           AND d.CheckRecipient_ID = a.CheckRecipient_ID
                                           AND d.Status_CODE = @Lc_TypeHoldAddress_CODE
                                           AND d.EndValidity_DATE = @Ld_High_DATE)))
                       OR (a.ReasonStatus_CODE = @Lc_ReasonStatusSDNA_CODE -- NCP BAD ADDRESS
                           AND AhisRec_INDC = 1)
                       OR (a.ReasonStatus_CODE = @Lc_ReasonStatusSDFA_CODE -- FIPS NON EXISTING ADDRESS
                           AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE) -- REFND - REFUNDED FROM IDENTIFIED, ROTHP - REFUNDED FROM UNIDENTIFIED
                           AND (EXISTS (SELECT 1
                                          FROM EFTR_Y1 e
                                         WHERE e.CheckRecipient_ID = a.CheckRecipient_ID
                                           AND e.CheckRecipient_CODE = a.CheckRecipient_CODE
                                           AND a.TypeDisburse_CODE <> @Lc_TypeDisburseRefnd_CODE -- REFND - REFUNDED FROM IDENTIFIED
                                           AND e.EndValidity_DATE = @Ld_High_DATE
                                           AND e.StatusEft_CODE = @Lc_StatusEftAc_CODE)
                                 OR EXISTS (SELECT 1
                                              FROM FIPS_Y1 f
                                             WHERE f.Fips_CODE = a.CheckRecipient_ID
                                               AND ((f.TypeAddress_CODE = @Lc_TypeAddressSTA_CODE
                                                     AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressSDU_CODE)
                                                     OR (f.TypeAddress_CODE = @Lc_TypeAddressINT_CODE
                                                         AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressFRC_CODE))
                                               AND f.EndValidity_DATE = @Ld_High_DATE)))
                       OR (a.ReasonStatus_CODE = @Lc_ReasonStatusSDFA_CODE -- FIPS NON EXISTING ADDRESS
                           AND a.TypeDisburse_CODE IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE) -- REFND - REFUNDED FROM IDENTIFIED, ROTHP - REFUNDED FROM UNIDENTIFIED
                           AND EXISTS (SELECT 1
                                         FROM FIPS_Y1 f
                                        WHERE f.Fips_CODE = a.CheckRecipient_ID
                                          AND ((f.TypeAddress_CODE = @Lc_TypeAddressSTA_CODE
                                                AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressSDU_CODE)
                                                OR (f.TypeAddress_CODE = @Lc_TypeAddressINT_CODE
                                                    AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressFRC_CODE))
                                          AND f.EndValidity_DATE = @Ld_High_DATE))
                       OR (a.ReasonStatus_CODE = @Lc_ReasonStatusSDOA_CODE -- OTHP NON EXISTING ADDRESS
                           AND a.TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE) -- REFND - REFUNDED FROM IDENTIFIED, ROTHP - REFUNDED FROM UNIDENTIFIED
                           AND (EXISTS (SELECT 1
                                          FROM EFTR_Y1 e
                                         WHERE a.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                                           AND a.TypeDisburse_CODE <> @Lc_TypeDisburseRefnd_CODE -- REFND - REFUNDED FROM IDENTIFIED
                                           AND e.CheckRecipient_ID = a.CheckRecipient_ID
                                           AND e.EndValidity_DATE = @Ld_High_DATE
                                           AND e.StatusEft_CODE = @Lc_StatusEftAc_CODE)
                                 OR EXISTS (SELECT 1
                                              FROM OTHP_Y1 o
                                             WHERE o.OtherParty_IDNO = a.CheckRecipient_ID
                                               AND o.TypeOthp_CODE = @Lc_TypeOthpO_CODE
                                               AND o.EndValidity_DATE = @Ld_High_DATE)))
                       OR (a.ReasonStatus_CODE = @Lc_ReasonStatusSDOA_CODE -- OTHP NON EXISTING ADDRESS
                           AND a.TypeDisburse_CODE = @Lc_TypeDisburseRefnd_CODE -- REFND - REFUNDED FROM IDENTIFIED
                           AND EXISTS (SELECT 1
                                         FROM OTHP_Y1 o
                                        WHERE o.OtherParty_IDNO = a.CheckRecipient_ID
                                          AND o.TypeOthp_CODE = @Lc_TypeOthpO_CODE
                                          AND o.EndValidity_DATE = @Ld_High_DATE))
                       OR (a.ReasonStatus_CODE = @Lc_ReasonStatusSDOA_CODE -- OTHP NON EXISTING ADDRESS
                           AND a.TypeDisburse_CODE = @Lc_TypeDisburseRothp_CODE -- REFUNDED FROM UNIDENTIFIED
                           AND EXISTS (SELECT 1
                                         FROM OTHP_Y1 o
                                        WHERE o.OtherParty_IDNO = a.CheckRecipient_ID
                                          AND o.TypeOthp_CODE IN (SELECT r.Value_CODE
																	FROM REFM_Y1 r
																  WHERE r.Table_ID = @Lc_TableOthp_ID
																	AND r.TableSub_ID = @Lc_TableSubRtyp_ID)
                                          AND o.EndValidity_DATE = @Ld_High_DATE)))))
     ORDER BY a.CheckRecipient_ID,
              a.CheckRecipient_CODE,
              a.TypeHold_CODE;

   SET @Ls_Sql_TEXT = 'OPEN CURSOR Dhld_CUR';
   SET @Ls_Sqldata_TEXT = ' ';
   OPEN Dhld_CUR;
   SET @Ls_Sql_TEXT = 'FETCH Dhld_CUR 1';
   SET @Ls_Sqldata_TEXT = ' ';
   FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Ld_DhldCur_Release_DATE, @Lc_DhldCur_TypeDisburse_CODE, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_TypeHold_CODE, @Lc_DhldCur_ProcessOffset_INDC, @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Ln_DhldCur_EventGlobalBeginSeq_NUMB, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Lc_DhldCur_ReasonStatus_CODE, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB,@Lc_DhldCur_AhisRec_INDC;
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- Cursor loop started
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SAVE TRANSACTION DISB_REL_TRANC_SAVE;
      SET @Ls_ErrorMessage_TEXT = '';
      SET @Ls_BateRecord_TEXT = 'Case_IDNO = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR) + ', ObligationSeq_NUMB = ' + CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR) + ', Batch_DATE = ' + CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_DhldCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR) + ', Release_DATE = ' + CAST(@Ld_DhldCur_Release_DATE AS VARCHAR) + ', TypeDisburse_CODE = ' + @Lc_DhldCur_TypeDisburse_CODE + ', Transaction_AMNT = ' + CAST(@Ln_DhldCur_Transaction_AMNT AS VARCHAR) + ', TypeHold_CODE = ' + @Lc_DhldCur_TypeHold_CODE + ', ProcessOffset_INDC = ' + @Lc_DhldCur_ProcessOffset_INDC + ', CheckRecipient_ID = ' + @Lc_DhldCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_DhldCur_CheckRecipient_CODE + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_DhldCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', EventGlobalSupportSeq_NUMB = ' + CAST(@Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR) + ', ReasonStatus_CODE = ' + @Lc_DhldCur_ReasonStatus_CODE + ', Unique_IDNO = ' + CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR) + ', Disburse_DATE = ' + CAST(@Ld_DhldCur_Disburse_DATE AS VARCHAR) + ', DisburseSeq_NUMB = ' + CAST(@Ln_DhldCur_DisburseSeq_NUMB AS VARCHAR);
      SET @Lc_Receipt_TEXT = dbo.BATCH_COMMON$SF_GET_RECEIPT_NO(@Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB);
      SET @Ln_Cursor_QNTY = @Ln_Cursor_QNTY + 1;
      SET @Ls_CursorLoc_TEXT = 'CurCount_QNTY = ' + ISNULL(CAST(@Ln_Cursor_QNTY AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CONVERT(VARCHAR, @Ld_DhldCur_Batch_DATE, 101), '') + ', Batch_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL(CAST(@Lc_DhldCur_CheckRecipient_ID AS VARCHAR), '');
      IF @Lc_DhldCur_CheckRecipient_ID != @Lc_CheckRecipientPrev_ID
       BEGIN
        SELECT @Ln_Row_QNTY = COUNT(1)
          FROM #Tesem_P1 p;
          
        IF @Ln_Row_QNTY > 0
         BEGIN
          SET @Ls_Sql_TEXT = 'INSERT INTO ESEM_Y1 ';
          SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');

          INSERT INTO ESEM_Y1
               (TypeEntity_CODE,
                Entity_ID,
                EventFunctionalSeq_NUMB,
                EventGlobalSeq_NUMB)
			   SELECT a.TypeEntity_CODE,
					  a.Entity_ID,
					  a.EventFunctionalSeq_NUMB,
					  @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB
				 FROM #Tesem_P1 a;
           
           SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
		   IF @Ln_Rowcount_QNTY = 0
			BEGIN
			 SET @Ls_ErrorMessage_TEXT = 'INSERT_ESEM_Y1 FOR DHLD FAILED';
			 RAISERROR (50001,16,1);
			END;
			
			SET @Ls_Sql_TEXT = 'DELETE #Tesem_P1 - 1';
			SET @Ls_Sqldata_TEXT = '';
			DELETE FROM #Tesem_P1;
         END;

        IF @Lc_DhldCur_TypeHold_CODE = @Lc_TypeHoldCp_CODE
         BEGIN
          SET @Ln_EventFunctionalSeq_NUMB = @Li_ReleasePayeeHold2120_NUMB;
         END
        ELSE
         BEGIN
          SET @Ln_EventFunctionalSeq_NUMB = @Li_AddressHoldRelease2110_NUMB;
         END

        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
		SET @Ls_Sqldata_TEXT = 'EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', Process_ID = ' + @Lc_Job_ID + ', EffectiveEvent_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Note_INDC = ' + @Lc_No_INDC + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT;
        EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
         @An_EventFunctionalSeq_NUMB = @Ln_EventFunctionalSeq_NUMB,
         @Ac_Process_ID              = @Lc_Job_ID,
         @Ad_EffectiveEvent_DATE     = @Ld_Run_DATE,
         @Ac_Note_INDC               = @Lc_No_INDC,
         @Ac_Worker_ID               = @Lc_BatchRunUser_TEXT,
         @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
         @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          RAISERROR (50001,16,1);
         END

        SET @Lc_CheckRecipientPrev_ID = @Lc_DhldCur_CheckRecipient_ID;
       END
      /*
		Release these records from CP Holds,Address Hold by marking the current held records as end-dated 
		in the DHLD_Y1 table,  
	  */
      SET @Ls_Sql_TEXT = 'UPDATE_DHLD_Y1';
      SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', Case_IDNO = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR) + ', ObligationSeq_NUMB = ' + CAST(@Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR) + ', Unique_IDNO = ' + CAST(@Ln_DhldCur_Unique_IDNO AS VARCHAR);
      UPDATE DHLD_Y1
         SET EndValidity_DATE = @Ld_Run_DATE,
             EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
       WHERE Case_IDNO = @Ln_DhldCur_Case_IDNO
         AND OrderSeq_NUMB = @Ln_DhldCur_OrderSeq_NUMB
         AND ObligationSeq_NUMB = @Ln_DhldCur_ObligationSeq_NUMB
         AND Unique_IDNO = @Ln_DhldCur_Unique_IDNO;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
      
      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'UPDATE_DHLD_Y1 FAILED';
        RAISERROR (50001,16,1);
       END
	  -- Inserting a new record with the status as R-Ready for disbursement and Release reason as SR-System Release.
	  SET @Ls_Sql_TEXT = 'INSERT_DHLD_Y1';
      SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST(@Ln_DhldCur_OrderSeq_NUMB AS VARCHAR) + ', ObligationSeq_NUMB = ' + CAST( @Ln_DhldCur_ObligationSeq_NUMB AS VARCHAR) + ', Batch_DATE = ' + CAST(@Ld_DhldCur_Batch_DATE AS VARCHAR) + ', SourceBatch_CODE = ' + @Lc_DhldCur_SourceBatch_CODE + ', Batch_NUMB = ' + CAST( @Ln_DhldCur_Batch_NUMB AS VARCHAR) + ', SeqReceipt_NUMB = ' + CAST(@Ln_DhldCur_SeqReceipt_NUMB AS VARCHAR) + ', Transaction_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Release_DATE = ' + CAST( @Ld_Run_DATE AS VARCHAR) + ', TypeDisburse_CODE = ' + @Lc_DhldCur_TypeDisburse_CODE + ', Transaction_AMNT = ' + CAST(@Ln_DhldCur_Transaction_AMNT AS VARCHAR) + ', Status_CODE = ' + @Lc_StatusRelease_CODE + ', TypeHold_CODE = ' + @Lc_DhldCur_TypeHold_CODE + ', ProcessOffset_INDC = ' + @Lc_DhldCur_ProcessOffset_INDC + ', CheckRecipient_ID = ' + @Lc_DhldCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_DhldCur_CheckRecipient_CODE + ', TypeHold_CODE = ' + @Lc_DhldCur_TypeHold_CODE + ', EventGlobalSeq_NUMB = ' + CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR) + ', EventGlobalEndSeq_NUMB = 0 ' + ', EventGlobalSupportSeq_NUMB = ' + CAST(@Ln_DhldCur_EventGlobalSupportSeq_NUMB AS VARCHAR) + ', BeginValidity_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', Disburse_DATE = ' + CAST(@Ld_DhldCur_Disburse_DATE AS VARCHAR) + ', DisburseSeq_NUMB = ' + CAST(@Ln_DhldCur_DisburseSeq_NUMB AS VARCHAR) + ', StatusEscheat_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', StatusEscheat_CODE = ' + @Lc_Space_TEXT;
      INSERT DHLD_Y1
             (Case_IDNO,
              OrderSeq_NUMB,
              ObligationSeq_NUMB,
              Batch_DATE,
              SourceBatch_CODE,
              Batch_NUMB,
              SeqReceipt_NUMB,
              Transaction_DATE,
              Release_DATE,
              TypeDisburse_CODE,
              Transaction_AMNT,
              Status_CODE,
              TypeHold_CODE,
              ProcessOffset_INDC,
              CheckRecipient_ID,
              CheckRecipient_CODE,
              ReasonStatus_CODE,
              EventGlobalBeginSeq_NUMB,
              EventGlobalEndSeq_NUMB,
              EventGlobalSupportSeq_NUMB,
              BeginValidity_DATE,
              EndValidity_DATE,
              Disburse_DATE,
              DisburseSeq_NUMB,
              StatusEscheat_DATE,
              StatusEscheat_CODE)
      VALUES ( @Ln_DhldCur_Case_IDNO,--Case_IDNO
               @Ln_DhldCur_OrderSeq_NUMB,--OrderSeq_NUMB
               @Ln_DhldCur_ObligationSeq_NUMB,--ObligationSeq_NUMB
               @Ld_DhldCur_Batch_DATE,--Batch_DATE
               @Lc_DhldCur_SourceBatch_CODE,--SourceBatch_CODE
               @Ln_DhldCur_Batch_NUMB,--Batch_NUMB
               @Ln_DhldCur_SeqReceipt_NUMB,--SeqReceipt_NUMB
               @Ld_Run_DATE,--Transaction_DATE                    
               @Ld_Run_DATE,--Release_DATE                        
               @Lc_DhldCur_TypeDisburse_CODE,--TypeDisburse_CODE
               @Ln_DhldCur_Transaction_AMNT,--Transaction_AMNT
               @Lc_StatusRelease_CODE,--Status_CODE
               @Lc_DhldCur_TypeHold_CODE,--TypeHold_CODE
               @Lc_DhldCur_ProcessOffset_INDC,--ProcessOffset_INDC
               @Lc_DhldCur_CheckRecipient_ID,--CheckRecipient_ID
               @Lc_DhldCur_CheckRecipient_CODE,--CheckRecipient_CODE
               @Lc_ReasSysReles_CODE, --ReasonStatus_CODE
               @Ln_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
               0,--EventGlobalEndSeq_NUMB            
               @Ln_DhldCur_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
               @Ld_Run_DATE,--BeginValidity_DATE               
               @Ld_High_DATE,--EndValidity_DATE                
               @Ld_DhldCur_Disburse_DATE,--Disburse_DATE
               @Ln_DhldCur_DisburseSeq_NUMB,--DisburseSeq_NUMB
               @Ld_High_DATE,-- StatusEscheat_DATE              
               @Lc_Space_TEXT -- StatusEscheat_CODE               
      );

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      IF @Ln_Rowcount_QNTY = 0
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_Y1 FAILED';

        RAISERROR (50001,16,1);
       END
      SET @Lc_CaseFlag_INDC = @Lc_No_INDC;
      SET @Lc_RcpidFlag_INDC = @Lc_No_INDC;
      SET @Lc_RcpcdFlag_INDC = @Lc_No_INDC;
      SET @Lc_RcptFlag_INDC = @Lc_No_INDC;
      SET @Lc_ReldtFlag_INDC = @Lc_No_INDC;
      SET @Ls_Sql_TEXT = 'SELECT #Tesem_P1 - 1';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityRctno_CODE + ', Entity_ID = ' + @Lc_Receipt_TEXT;
      SELECT @Ln_RowRctno_QNTY = COUNT(1)
        FROM #Tesem_P1 p
       WHERE p.TypeEntity_CODE = @Lc_TypeEntityRctno_CODE
         AND p.Entity_ID = @Lc_Receipt_TEXT;
	  
	  SET @Ls_Sql_TEXT = 'SELECT #Tesem_P1 - 2';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityCase_CODE + ', Entity_ID = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR);	
      SELECT @Ln_RowCase_QNTY = COUNT(1)
        FROM #Tesem_P1 p
       WHERE p.TypeEntity_CODE = @Lc_TypeEntityCase_CODE
         AND p.Entity_ID = @Ln_DhldCur_Case_IDNO;
	  
	  SET @Ls_Sql_TEXT = 'SELECT #Tesem_P1 - 3';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityRcpid_CODE + ', Entity_ID = ' + @Lc_DhldCur_CheckRecipient_ID;	
      SELECT @Ln_RowRcpid_QNTY = COUNT(1)
        FROM #Tesem_P1 p
       WHERE p.TypeEntity_CODE = @Lc_TypeEntityRcpid_CODE
         AND p.Entity_ID = @Lc_DhldCur_CheckRecipient_ID;
	  
	  SET @Ls_Sql_TEXT = 'SELECT #Tesem_P1 - 4';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityRcpcd_CODE + ', Entity_ID = ' + @Lc_DhldCur_CheckRecipient_CODE;	
      SELECT @Ln_RowRcpcd_QNTY = COUNT(1)
        FROM #Tesem_P1 p
       WHERE p.TypeEntity_CODE = @Lc_TypeEntityRcpcd_CODE
         AND p.Entity_ID = @Lc_DhldCur_CheckRecipient_CODE;
	  
	  SET @Ls_Sql_TEXT = 'SELECT #Tesem_P1 - 5';
	  SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityReldt_CODE;		
      SELECT @Ln_RowReldt_QNTY = COUNT(1)
        FROM #Tesem_P1 p
       WHERE p.TypeEntity_CODE = @Lc_TypeEntityReldt_CODE;

      IF @Ln_RowRctno_QNTY > 0
       BEGIN
        SET @Lc_RcptFlag_INDC = @Lc_Yes_INDC;
       END

      IF @Ln_RowCase_QNTY > 0
       BEGIN
        SET @Lc_CaseFlag_INDC = @Lc_Yes_INDC;
       END

      IF @Ln_RowRcpid_QNTY > 0
       BEGIN
        SET @Lc_RcpidFlag_INDC = @Lc_Yes_INDC;
       END

      IF @Ln_RowRcpcd_QNTY > 0
       BEGIN
        SET @Lc_RcpcdFlag_INDC = @Lc_Yes_INDC;
       END

      IF @Ln_RowReldt_QNTY > 0
       BEGIN
        SET @Lc_ReldtFlag_INDC = @Lc_Yes_INDC;
       END
      IF @Lc_RcptFlag_INDC = @Lc_No_INDC
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT INTO #Tesem_P1 - 1';
        SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityRctno_CODE + ', Entity_ID = ' + @Lc_Receipt_TEXT + ', EventFunctionalSeq_NUMB = ' + CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR);
        INSERT INTO #Tesem_P1
                    (TypeEntity_CODE,
                     Entity_ID,
                     EventFunctionalSeq_NUMB)
             VALUES (@Lc_TypeEntityRctno_CODE, --TypeEntity_CODE
                     @Lc_Receipt_TEXT, --Entity_ID
                     @Ln_EventFunctionalSeq_NUMB );--EventFunctionalSeq_NUMB
       END;

      IF @Lc_CaseFlag_INDC = @Lc_No_INDC
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT INTO #Tesem_P1 - 2';
        SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityCase_CODE + ', Entity_ID = ' + CAST(@Ln_DhldCur_Case_IDNO AS VARCHAR) + ', EventFunctionalSeq_NUMB = ' + CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR);
        INSERT INTO #Tesem_P1
                    (TypeEntity_CODE,
                     Entity_ID,
                     EventFunctionalSeq_NUMB)
             VALUES (@Lc_TypeEntityCase_CODE,--TypeEntity_CODE
                     @Ln_DhldCur_Case_IDNO,--Entity_ID
                     @Ln_EventFunctionalSeq_NUMB);--EventFunctionalSeq_NUMB
       END;

      IF @Lc_RcpidFlag_INDC = @Lc_No_INDC
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT INTO #Tesem_P1 - 3';
        SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityRcpid_CODE + ', Entity_ID = ' + @Lc_DhldCur_CheckRecipient_ID + ', EventFunctionalSeq_NUMB = ' + CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR);
        INSERT INTO #Tesem_P1
                    (TypeEntity_CODE,
                     Entity_ID,
                     EventFunctionalSeq_NUMB)
             VALUES (@Lc_TypeEntityRcpid_CODE,--TypeEntity_CODE
                     @Lc_DhldCur_CheckRecipient_ID,--Entity_ID
                     @Ln_EventFunctionalSeq_NUMB);--EventFunctionalSeq_NUMB
       END;

      IF @Lc_RcpcdFlag_INDC = @Lc_No_INDC
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT INTO #Tesem_P1 - 4';
        SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityRcpcd_CODE + ', Entity_ID = ' + @Lc_DhldCur_CheckRecipient_CODE + ', EventFunctionalSeq_NUMB = ' + CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR);
        INSERT INTO #Tesem_P1
                    (TypeEntity_CODE,
                     Entity_ID,
                     EventFunctionalSeq_NUMB)
             VALUES (@Lc_TypeEntityRcpcd_CODE,--TypeEntity_CODE
                     @Lc_DhldCur_CheckRecipient_CODE,--Entity_ID
                     @Ln_EventFunctionalSeq_NUMB);--EventFunctionalSeq_NUMB
       END;

      IF @Lc_ReldtFlag_INDC = @Lc_No_INDC
       BEGIN
        SET @Ls_Sql_TEXT = 'INSERT INTO #Tesem_P1 - 5';
        SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + @Lc_TypeEntityReldt_CODE + ', Entity_ID = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', EventFunctionalSeq_NUMB = ' + CAST(@Ln_EventFunctionalSeq_NUMB AS VARCHAR);
        INSERT INTO #Tesem_P1
                    (TypeEntity_CODE,
                     Entity_ID,
                     EventFunctionalSeq_NUMB)
             VALUES (@Lc_TypeEntityReldt_CODE,--TypeEntity_CODE
                     @Ld_Run_DATE,--Entity_ID
                     @Ln_EventFunctionalSeq_NUMB);--EventFunctionalSeq_NUMB
       END;
       
      SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
      
      SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
	        
     END TRY

     BEGIN CATCH
      -- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	    BEGIN
	   	   ROLLBACK TRANSACTION DISB_REL_TRANC_SAVE;
		END
		ELSE
		BEGIN
		    SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + ' ' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
		END
	  
	  -- Check for Exception information to log the description text based on the error
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

      SET @Ls_BateRecord_TEXT = 'BateRecord_TEXT = ' + @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_Cursor_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
       @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

	  -- Checking if error type is 'E' then increment the threshold count
       IF @Lc_Msg_CODE = @Lc_TypeErrorE_CODE
        BEGIN
         SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
        END
       ELSE IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      
     END CATCH
     
     SET @Ls_Sql_TEXT = 'COMMIT FREQUENCY CHECK';
	 SET @Ls_Sqldata_TEXT = 'Cursor_QNTY = ' + ISNULL(CAST(@Ln_CommitFreq_QNTY AS VARCHAR),'') + ', CommitFreqParm_QNTY = ' + ISNULL(CAST(@Ln_CommitFreqParm_QNTY AS VARCHAR),'');
     IF @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
       BEGIN
       
        SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordsCommit_QNTY + @Ln_CommitFreqParm_QNTY;
        
        COMMIT TRANSACTION DISB_REL_TRANC;

        BEGIN TRANSACTION DISB_REL_TRANC;

        SET @Ln_CommitFreq_QNTY = 0;
       END;
     
     SET @Ls_Sql_TEXT = 'THRESHOLD COUNT CHECK';
     SET @Ls_Sqldata_TEXT = 'ExcpThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);
     IF @Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY
      BEGIN
       COMMIT TRANSACTION DISB_REL_TRANC;
       SET @Ln_ProcessedRecordsCommit_QNTY = @Ln_ProcessedRecordCount_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'EXCEPTION THRESHOLD REACHED';
       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'FETCH Dhld_CUR 2';
     SET @Ls_Sqldata_TEXT = ' ';
     
     FETCH NEXT FROM Dhld_CUR INTO @Ln_DhldCur_Case_IDNO, @Ln_DhldCur_OrderSeq_NUMB, @Ln_DhldCur_ObligationSeq_NUMB, @Ld_DhldCur_Batch_DATE, @Lc_DhldCur_SourceBatch_CODE, @Ln_DhldCur_Batch_NUMB, @Ln_DhldCur_SeqReceipt_NUMB, @Ld_DhldCur_Release_DATE, @Lc_DhldCur_TypeDisburse_CODE, @Ln_DhldCur_Transaction_AMNT, @Lc_DhldCur_TypeHold_CODE, @Lc_DhldCur_ProcessOffset_INDC, @Lc_DhldCur_CheckRecipient_ID, @Lc_DhldCur_CheckRecipient_CODE, @Ln_DhldCur_EventGlobalBeginSeq_NUMB, @Ln_DhldCur_EventGlobalSupportSeq_NUMB, @Lc_DhldCur_ReasonStatus_CODE, @Ln_DhldCur_Unique_IDNO, @Ld_DhldCur_Disburse_DATE, @Ln_DhldCur_DisburseSeq_NUMB,@Lc_DhldCur_AhisRec_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE Dhld_CUR;

   DEALLOCATE Dhld_CUR;
   
   IF @Ln_Cursor_QNTY > 0
   BEGIN
	   SET @Ls_Sql_TEXT = 'BATCH_FIN_RELEASE_DISB_HOLD$SP_INSERT_ESEM - 1';
	   SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST(@Ln_EventGlobalSeq_NUMB AS VARCHAR), '');
	   
	   INSERT INTO ESEM_Y1
               (TypeEntity_CODE,
                Entity_ID,
                EventFunctionalSeq_NUMB,
                EventGlobalSeq_NUMB)
			   SELECT a.TypeEntity_CODE,
					  a.Entity_ID,
					  a.EventFunctionalSeq_NUMB,
					  @Ln_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB
				 FROM #Tesem_P1 a;
           
          SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

		   IF @Ln_Rowcount_QNTY = 0
			BEGIN
			 SET @Ls_ErrorMessage_TEXT = 'INSERT_ESEM_Y1 FOR DHLD FAILED - 1';
			 RAISERROR (50001,16,1);
			END;
			
		 SET @Ls_Sql_TEXT = 'DELETE #Tesem_P1 - 2';
		 SET @Ls_Sqldata_TEXT = '';
		 DELETE FROM #Tesem_P1;

	END	
    
   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = ' BATCH_COMMON$SP_UPDATE_PARM_DATE ';
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
    
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Job_ID = ' + @Lc_Job_ID + ', Process_NAME = ' + @Ls_Process_NAME + ', Procedure_NAME = ' + @Ls_Procedure_NAME + ', CursorLoc_TEXT = ' + @Ls_CursorLoc_TEXT + ', ExecLocation_TEXT = ' + @Lc_Successful_TEXT + ', ListKey_TEXT = ' + @Lc_Successful_TEXT + ', DescriptionError_TEXT = ' + @Lc_Successful_TEXT + ', Status_CODE = ' + @Lc_StatusSuccess_CODE + ', Worker_ID = ' + @Lc_BatchRunUser_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR);
   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ad_Start_DATE            = @Ld_Start_DATE,
    @Ac_Job_ID                = @Lc_Job_ID,
    @As_Process_NAME          = @Ls_Process_NAME,
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_CursorLocation_TEXT   = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT     = @Lc_Successful_TEXT,
    @As_ListKey_TEXT          = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT = @Lc_Space_TEXT,
    @Ac_Status_CODE           = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID             = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
	
   COMMIT TRANSACTION DISB_REL_TRANC;
  END TRY

  BEGIN CATCH
  -- Check if active transaction exists for this session then rollback the transaction
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION DISB_REL_TRANC;
    END;
   -- Check if cursor is open close and deallocate it
   IF CURSOR_STATUS ('LOCAL', 'Dhld_CUR') IN (0, 1)
    BEGIN
     CLOSE Dhld_CUR;
     DEALLOCATE Dhld_CUR;
    END;
   -- Check for Exception information to log the description text based on the error
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
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordsCommit_QNTY;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH;
 END


GO
