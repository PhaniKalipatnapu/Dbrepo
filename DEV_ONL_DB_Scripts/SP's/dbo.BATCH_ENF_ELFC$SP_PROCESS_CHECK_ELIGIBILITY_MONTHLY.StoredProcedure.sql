/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_MONTHLY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*                                                                                                                                                                                                                                                                                                                                                                                                                          
--------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                                                                                                        
Procedure Name		: BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_MONTHLY
Programmer Name		: IMP Team                                                                                                                                                                                                                                                                  
Description			: This procedure checks the eligibility criteria of the remedies that are to be done monthly.                                                                                                                                                                                                                                                                                                         
Frequency			: 'MONTHLY'                                                                                                                                                                                                                                                                                                                                                                                         
Developed On		: 06/29/2011                                                                                                                                                                                                                                                                                                                                                                                       
Called BY			: None                                                                                                                                                                                                                                                                                                                                                                                                 
Called On	        : BATCH_COMMON$SP_GET_BATCH_DETAILS and BATCH_COMMON$SP_BSTL_LOG                                                                                                                                                                                                                                                                                                                                                                                                         
--------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                                                                                                        
Modified BY			:                                                                                                                                                                                                                                                                                                                                                                                                      
Modified On			:                                                                                                                                                                                                                                                                                                                                                                                                       
Version No			: 1.0                                                                                                                                                                                                                                                                                                                                                                                                          
--------------------------------------------------------------------------------------------------------------------                                                                                                                                                                                                                                                                                                        
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_MONTHLY]
AS
 BEGIN
  SET NOCOUNT ON;

    DECLARE @Lc_CaseStatusOpen_CODE                      CHAR(1)		= 'O',
			@Lc_CaseTypeNonIvd_CODE                      CHAR(1)		= 'H',
			@Lc_RespondInitInitiate_TEXT                 CHAR(1)		= 'I',
			@Lc_RespondInitInitiateIntrnl_TEXT           CHAR(1)		= 'C',
			@Lc_RespondInitInitiateTribal_TEXT           CHAR(1)		= 'T',
			@Lc_Space_TEXT                               CHAR(1)		= ' ',
			@Lc_OrderTypeVoluntary_CODE                  CHAR(1)		= 'V',
			@Lc_No_TEXT                                  CHAR(1)		= 'N',
			@Lc_StatusSuccess_CODE                       CHAR(1)		= 'S',
			@Lc_Yes_TEXT                                 CHAR(1)		= 'Y',
			@Lc_StatusFailed_CODE                        CHAR(1)		= 'F',
			@Lc_ErrorTypeError_CODE                      CHAR(1)		= 'E',
			@Lc_StatusAbnormalend_CODE                   CHAR(1)		= 'A',
			@Lc_NegPosPositive_CODE                      CHAR(1)		= 'P',
			@Lc_RespondInitRespondingState_CODE          CHAR(1)		= 'R',
			@Lc_RespondInitRespondingTribal_CODE         CHAR(1)		= 'S',
			@Lc_RespondInitRespondingInternational_CODE  CHAR(1)		= 'Y',
			@Lc_TypeChangeCr_CODE                        CHAR(2)		= 'CR',
			@Lc_SubsystemEnforcement_TEXT                CHAR(2)		= 'EN',
			@Lc_StateControlDe_CODE                      CHAR(2)		= 'DE',
			@Lc_TypeChangeDl_CODE                        CHAR(2)		= 'DL',
			@Lc_TypeChangeSm_CODE                        CHAR(2)		= 'SM',
			@Lc_TypeChangeTm_CODE                        CHAR(2)		= 'TM',
			@Lc_TypeChangeYe_CODE                        CHAR(2)		= 'YE',
			@Lc_TypeChangeCc_CODE                        CHAR(2)		= 'CC',
			@Lc_RemedyStatusStart_CODE                   CHAR(4)		= 'STRT',
			@Lc_MajorActivityCase_CODE                   CHAR(4)		= 'CASE',
			@Lc_ActivityMajorCclo_CODE                   CHAR(4)		= 'CCLO',
			@Lc_MajorActivityCrim_CODE                   CHAR(4)		= 'CRIM',
			@Lc_MajorActivityCrpt_CODE                   CHAR(4)		= 'CRPT',
			@Lc_MajorActivityCsln_CODE                   CHAR(4)		= 'CSLN',
			@Lc_MajorActivityEmnp_CODE                   CHAR(4)		= 'EMNP',
			@Lc_MajorActivityFidm_CODE                   CHAR(4)		= 'FIDM',
			@Lc_MajorActivityLien_CODE                   CHAR(4)		= 'LIEN',
			@Lc_MajorActivityLint_CODE                   CHAR(4)		= 'LINT',
			@Lc_MajorActivityLsnr_CODE                   CHAR(4)		= 'LSNR',
			@Lc_MajorActivityPsoc_CODE                   CHAR(4)		= 'PSOC',
			@Lc_MajorActivitySeqo_CODE                   CHAR(4)		= 'SEQO',
			@Lc_MinorActivityDelqn_CODE                  CHAR(5)		= 'DELQN',
			@Lc_MinorActivitySmnog_CODE                  CHAR(5)		= 'SMNOG',
			@Lc_MinorActivityTmnog_CODE                  CHAR(5)		= 'TMNOG',
			@Lc_MinorActivityFpnog_CODE                  CHAR(5)		= 'FPNOG',
			@Lc_ReasonErfso_CODE                         CHAR(5)		= 'ERFSO',
			@Lc_ReasonErfsm_CODE                         CHAR(5)		= 'ERFSM',
			@Lc_ReasonErfss_CODE                         CHAR(5)		= 'ERFSS',
			@Lc_NoticeFin33_ID                           CHAR(6)		= 'FIN-33',
			@Lc_NoticeFin34_ID                           CHAR(6)		= 'FIN-34',
			@Lc_NoticeFin35_ID                           CHAR(6)		= 'FIN-35',
			@Lc_Job_ID                                   CHAR(7)		= 'DEB7600',
			@Lc_NoticeEnf16_IDNO                         CHAR(8)		= 'ENF-16',
			@Lc_ErrorE1081_CODE                          CHAR(5)		= 'E1081',
			@Lc_ConversionUser_TEXT                      CHAR(10)		= 'CONVERSION',
			@Lc_Successful_INDC                          CHAR(20)		= 'SUCCESSFUL',
			@Lc_Err0003_TEXT                             CHAR(30)		= 'REACHED THRESHOLD',
			@Lc_BatchRunUser_TEXT                        CHAR(30)		= 'BATCH', 
			@Ls_Procedure_NAME                           VARCHAR(60)	= 'BATCH_ENF_ELFC$SP_PROCESS_CHECK_ELIGIBILITY_MONTHLY',
			@Ls_Package_NAME                             VARCHAR(100)	= 'BATCH_ENF_ELFC',
			@Ls_Routine_TEXT                             VARCHAR(100)	= 'SP_PROCESS_CHECK_ELIGIBILITY_MONTHLY',
			@Ld_High_DATE								 DATE			= '12/31/9999',
			@Ld_Low_DATE								 DATE			= '01/01/0001',
			@Ld_Current_DTTM                             DATETIME2		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE  @Ln_UserDefinedException_NUMB				NUMERIC(2)		= 0,
           @Ln_CommitFreqParm_QNTY						NUMERIC(5)		= 0,
           @Ln_ExceptionThresholdParm_QNTY				NUMERIC(5)		= 0,
           @Ln_ArrearsNoticeCur_QNTY					NUMERIC(9)		= 0,
           @Ln_Topic_NUMB								NUMERIC(10),
           @Ln_TransactionEventSeq_NUMB					NUMERIC(10),
           @Ln_CrptCount_NUMB							NUMERIC(10)		= 0,
           @Ln_DelqnCount_NUMB							NUMERIC(10)		= 0,
           @Ln_ArrearNoticeCount_NUMB					NUMERIC(10)		= 0,
           @Ln_Error_NUMB								NUMERIC(10)		= 0,
           @Ln_ErrorLine_NUMB							NUMERIC(10)		= 0,
           @Ln_TotalRecordCount_NUMB					NUMERIC(30)		= 0,
           @Li_FetchStatus_QNTY							SMALLINT,
           @Lc_Msg_CODE									CHAR(1),
           @Lc_MinorActivity_CODE						CHAR(5),
           @Ls_Sql_TEXT									VARCHAR(100),
           @Ls_CursorLoc_TEXT							VARCHAR(200),
           @Ls_Sqldata_TEXT								VARCHAR(1000),
           @Ls_DescriptionError_TEXT					VARCHAR(4000),
           @Ls_ErrorMessage_TEXT						VARCHAR(4000),
           @Ld_LastRun_DATE								DATETIME2,
           @Ld_Run_DATE									DATETIME2;

  DECLARE @Ln_EnfGenCur_Case_IDNO						NUMERIC(6),
          @Ln_EnfGenCur_NcpMci_IDNO						NUMERIC(10);
  DECLARE @Ln_ArrearsNoticeCur_Case_IDNO				NUMERIC(6),
          @Ln_ArrearsNoticeCur_NcpMci_IDNO				NUMERIC(10),
          @Ln_ArrearsNoticeCur_OrderSeq_NUMB			NUMERIC(5),
          @Lc_ArrearsNoticeCur_Notice_ID				CHAR(8);

  BEGIN TRY
   DECLARE @Ln_CommitFreq_QNTY							NUMERIC(5)		= 0,
           @Ln_ExceptionThreshold_QNTY					NUMERIC(5)		= 0,
           @Ln_DelnqCur_QNTY							NUMERIC(10)		= 0,
           @Ln_Topic_IDNO								NUMERIC(10)		= 0,
           @Lc_ProcessFlag_INDC							CHAR(1);

   SET @Ls_Sql_TEXT = 'ELFC097 : BATCH_COMMON$SP_GET_BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '');

   -- Fetching date run, date last run, commit freq, exception threshold details                                                                                                                                                                                                                                                                                                                                            
   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
      SET @Ls_Sql_TEXT = 'ELFC097A : BATCH_COMMON$SP_GET_BATCH_DETAILS FAILED';                                                                                                                                                                                                                                                                                                                                            
     RAISERROR (50001,16,1);
    END

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'PARM DATE PROBLEM';
     SET @Ls_Sql_TEXT = 'PARM DATE PROBLEM';
     SET @Ls_Sqldata_TEXT = @Ls_Sqldata_TEXT;
     RAISERROR (50001,16,1);
    END
  
   BEGIN TRANSACTION ElfcMonthlyTran;
      
   
   SET @Ls_Sql_TEXT = 'ELFC098 : DELQN - Enf16 BULK INSERT IN ELFC';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

	INSERT INTO ELFC_Y1 
		(MemberMci_IDNO,
		Case_IDNO,
		OrderSeq_NUMB,
		Process_ID,
		TypeChange_CODE,
		OthpSource_IDNO,
		NegPos_CODE,
		Create_DATE,
		Process_DATE,
		WorkerUpdate_ID,
		Update_DTTM,
		TransactionEventSeq_NUMB,
		TypeReference_CODE,
		Reference_ID)
	SELECT i.NcpMci_IDNO AS MemberMci_IDNO,
		   i.Case_IDNO AS Case_IDNO,
		   i.OrderSeq_NUMB AS OrderSeq_NUMB,
		   @Lc_Job_ID AS Process_ID,
		   i.TypeChange_CODE AS TypeChange_CODE,
		   0 AS OthpSource_IDNO,
		   i.NegPos_CODE AS NegPos_CODE,
		   @Ld_Run_DATE AS Create_DATE,
		   @Ld_High_DATE AS Process_DATE,
		   @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
		   @Ld_Run_DATE AS Update_DTTM,
		   0 AS TransactionEventSeq_NUMB,
		   ' ' AS TypeReference_CODE,
		   @Lc_MinorActivityDelqn_CODE + '~' + @Lc_NoticeEnf16_IDNO  AS Reference_ID
      FROM (SELECT a.NcpPf_IDNO AS NcpMci_IDNO,
					a.Case_IDNO,
					a.OrderSeq_NUMB,
                    @Lc_TypeChangeDl_CODE AS TypeChange_CODE,
                     @Lc_NegPosPositive_CODE AS NegPos_CODE                                                                                                                                                                                                                                                                                                                                                                 
              FROM ENSD_Y1 a
             -- Open Case                                                                                                                                                                                                                                                                                                                                                                                                   
             WHERE a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                   -- IV-D Case                                                                                                                                                                                                                                                                                                                                                                                             
                   AND a.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                   AND a.NcpPf_IDNO != 0
                   -- Non Voluntary order                                                                                                                                                                                                                                                                                                                                                                                   
                   AND a.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                   -- Active support order                                                                                                                                                                                                                                                                                                                                                                                  
                   AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
                   /* Case is not Initiating interstate OR if the case is Initiating interstate the referral type is not                                                                                                                                                                                                                                                                                                    
                   Registration for Modification only */
                   AND (a.RespondInit_CODE NOT IN (@Lc_RespondInitInitiateIntrnl_TEXT, @Lc_RespondInitInitiate_TEXT, @Lc_RespondInitInitiateTribal_TEXT)
                         OR (a.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
									   AND NOT EXISTS(SELECT 1
											FROM ICAS_Y1 x
										   WHERE x.Case_IDNO = a.Case_IDNO
											 AND x.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
											 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
											 AND x.EndValidity_DATE=@Ld_High_DATE)))
                   -- System Date is greater than or equal to the initial support court order date plus 60 calendar days                                                                                                                                                                                                                                                                                                    
                   AND a.CourtOrderIssuedOrg_DATE < DATEADD(D, -60, @Ld_Run_DATE)
                   -- Arrears are greater than or equal to one month support                                                                                                                                                                                                                                                                                                                                                
                   AND a.Arrears_AMNT >= a.Mso_AMNT
                   --Month’s current support should exists
                   AND a.Mso_AMNT > 0
                   -- Member is not in active chapter 13 bankruptcy                                                                                                                                                                                                                                                                                                                                                         
                   AND (a.Bankruptcy13_INDC = @Lc_No_TEXT
                         OR (a.Bankruptcy13_INDC = @Lc_Yes_TEXT
                             AND ((a.Dismissed_DATE != @Ld_Low_DATE
                                   AND @Ld_Run_DATE > a.Dismissed_DATE)
                                   OR (a.Discharge_DATE != @Ld_Low_DATE
                                       AND @Ld_Run_DATE > a.Discharge_DATE))))
                   -- Case is not exempt from enforcement                                                                                                                                                                                                                                                                                                                                                                   
                   AND a.CaseExempt_INDC = @Lc_No_TEXT
                   -- No Active Case Closure chain NCP as a source                                                                                                                                                                                                                                                                                                                                                                      
                   AND NOT EXISTS (SELECT 1
                                     FROM DMJR_Y1 e
                                    WHERE e.Case_IDNO = a.Case_IDNO
                                      AND e.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                      AND e.Status_CODE = @Lc_RemedyStatusStart_CODE)
                   -- Conversion Enforcement remedy not in active status
                   AND NOT EXISTS  (SELECT 1 FROM DMJR_Y1 m 
										WHERE m.WorkerUpdate_ID = @Lc_ConversionUser_TEXT
                                         AND m.Case_IDNO = a.Case_IDNO
                                         AND ActivityMajor_CODE in ( @Lc_MajorActivityCrim_CODE,
																	 @Lc_MajorActivityCrpt_CODE,
																	 @Lc_MajorActivityCsln_CODE,
																	 @Lc_MajorActivityEmnp_CODE,
																	 @Lc_MajorActivityFidm_CODE,
																	 @Lc_MajorActivityLien_CODE,
																	 @Lc_MajorActivityLint_CODE,
																	 @Lc_MajorActivityLsnr_CODE,
																	 @Lc_MajorActivityPsoc_CODE,
																	 @Lc_MajorActivitySeqo_CODE)
											AND m.Status_CODE = @Lc_RemedyStatusStart_CODE)
                   -- No Active Case Closure chain NCP as a source                                                                                                                                                                                                                                                                                                                                                                      
                   AND NOT EXISTS (SELECT 1
                                     FROM ELFC_Y1 b
                                    WHERE b.Case_IDNO = a.Case_IDNO
                                      AND b.TypeChange_CODE = @Lc_TypeChangeCc_CODE
                                      AND b.Process_DATE = @Ld_High_DATE)
                                                                                                                                                                                                                                                                                                                                                                   
                   AND (NOT EXISTS (SELECT 1
                                      FROM NRRQ_Y1 r
                                     WHERE r.Notice_ID = @Lc_NoticeEnf16_IDNO
                                       AND r.Case_IDNO = a.Case_IDNO
                                       AND r.Generate_DTTM < @Ld_Run_DATE)
                        AND NOT EXISTS (SELECT 1
                                          FROM NMRQ_Y1 r
                                         WHERE r.Notice_ID = @Lc_NoticeEnf16_IDNO
                                           AND r.Case_IDNO = a.Case_IDNO
                                           AND r.Request_DTTM < @Ld_Run_DATE)
                                                                                                                                                                                                                                                                                                                                                                   
                        AND NOT EXISTS (SELECT 1
                                          FROM UDMNR_V1 b
                                         WHERE b.Case_IDNO = a.Case_IDNO
                                           AND b.ActivityMinor_CODE = @Lc_MinorActivityDelqn_CODE
                                           AND b.Entered_DATE < @Ld_Run_DATE))
                        EXCEPT
						   SELECT i.MemberMci_IDNO,
								  i.Case_IDNO,
								  i.OrderSeq_NUMB,
								  i.TypeChange_CODE,
								  i.NegPos_CODE
							 FROM ELFC_Y1 i
							WHERE i.Process_DATE = @Ld_High_DATE
							  AND i.TypeChange_CODE = @Lc_TypeChangeDl_CODE                    
                        ) AS i;
	
	SET @Ln_DelqnCount_NUMB = @@ROWCOUNT;	
	
   SET @Ls_Sql_TEXT = 'ELFC099 : ARREARS NOTICES FROM ELFC MONTHLY';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   	
   ---6 month, 3 month and Zero Arrears Notices From ELFC Monthly
   INSERT INTO ELFC_Y1 
		(MemberMci_IDNO,
		Case_IDNO,
		OrderSeq_NUMB,
		Process_ID,
		TypeChange_CODE,
		OthpSource_IDNO,
		NegPos_CODE,
		Create_DATE,
		Process_DATE,
		WorkerUpdate_ID,
		Update_DTTM,
		TransactionEventSeq_NUMB,
		TypeReference_CODE,
		Reference_ID)
		SELECT MemberMci_IDNO,
				Case_IDNO,
				OrderSeq_NUMB,
				Process_ID,
				TypeChange_CODE,
				OthpSource_IDNO,
				NegPos_CODE,
				Create_DATE,
				Process_DATE,
				WorkerUpdate_ID,
				Update_DTTM,
				TransactionEventSeq_NUMB,
				TypeReference_CODE,
				Reference_ID
				FROM
				   (SELECT s.NcpMci_IDNO AS MemberMci_IDNO,
					   s.Case_IDNO AS Case_IDNO,
					   s.OrderSeq_NUMB AS OrderSeq_NUMB,
					   @Lc_Job_ID AS Process_ID,	   
					   CASE WHEN s.Notice_ID = @Lc_NoticeFin35_ID THEN @Lc_TypeChangeSm_CODE
							WHEN s.Notice_ID = @Lc_NoticeFin34_ID THEN @Lc_TypeChangeTm_CODE
							ELSE @Lc_TypeChangeYe_CODE END  AS TypeChange_CODE,
					   0 AS OthpSource_IDNO,
					   @Lc_NegPosPositive_CODE AS NegPos_CODE,
					   @Ld_Run_DATE AS Create_DATE,
					   @Ld_High_DATE AS Process_DATE,
					   @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
					   @Ld_Run_DATE AS Update_DTTM,
					   0 AS TransactionEventSeq_NUMB,
					   ' ' AS TypeReference_CODE,
					   CASE WHEN s.Notice_ID = @Lc_NoticeFin35_ID THEN @Lc_MinorActivitySmnog_CODE
							WHEN s.Notice_ID = @Lc_NoticeFin33_ID THEN @Lc_MinorActivityTmnog_CODE
							ELSE @Lc_MinorActivityFpnog_CODE END + '~' + s.Notice_ID  AS Reference_ID
						  FROM (
							SELECT DISTINCT
								   i.Case_IDNO,
								   i.NcpMci_IDNO,
								   i.OrderSeq_NUMB,
								   CASE
									WHEN i.FullArrears_AMNT <= 0
										 AND i.Fin_34_Notice_ID IS NULL
									 THEN @Lc_NoticeFin34_ID
									WHEN i.FullArrears_AMNT BETWEEN (i.ExpectToPay_AMNT * 2) AND (i.ExpectToPay_AMNT * 3)
										 AND i.Fin_33_Notice_ID IS NULL
									 THEN @Lc_NoticeFin33_ID
									WHEN i.FullArrears_AMNT BETWEEN (i.ExpectToPay_AMNT * 5) AND (i.ExpectToPay_AMNT * 6)
										 AND i.Fin_35_Notice_ID IS NULL
									 THEN @Lc_NoticeFin35_ID
								   END Notice_ID
							  FROM (SELECT a.NcpPf_IDNO AS NcpMci_IDNO,
										   a.OrderSeq_NUMB,
										   a.Case_IDNO AS Case_IDNO,
										   fin_33.Fin_33_Notice_ID AS Fin_33_Notice_ID,
										   fin_33.Fin_33_Generate_DTTM AS Fin_33_Generate_DTTM,
										   fin_34.Fin_34_Notice_ID AS Fin_34_Notice_ID,
										   fin_34.Fin_34_Generate_DTTM AS Fin_34_Generate_DTTM,
										   fin_35.Fin_35_Notice_ID AS Fin_35_Notice_ID,
										   fin_35.Fin_35_Generate_DTTM AS Fin_35_Generate_DTTM,
										   a.FullArrears_AMNT AS FullArrears_AMNT,
										   a.ExpectToPay_AMNT AS ExpectToPay_AMNT
									  FROM ENSD_Y1 a
										   INNER JOIN SORD_Y1 s
											ON a.Case_IDNO = s.Case_IDNO
										   LEFT OUTER JOIN (SELECT r.Case_IDNO,
																   r.Fin_33_Notice_ID,
																   r.Fin_33_Generate_DTTM
															  FROM (SELECT r.Case_IDNO,
																		   r.Fin_33_Notice_ID,
																		   r.Fin_33_Generate_DTTM,
																		   ROW_NUMBER() OVER(PARTITION BY r.Case_IDNO, r.Fin_33_Notice_ID ORDER BY r.Fin_33_Generate_DTTM DESC) rnm
																	  FROM (SELECT r.Case_IDNO Case_IDNO,
																				   r.Notice_ID Fin_33_Notice_ID,
																				   r.Generate_DTTM Fin_33_Generate_DTTM
																			  FROM NRRQ_Y1 r
																			 WHERE r.Notice_ID IN (@Lc_NoticeFin33_ID)
																			UNION ALL
																			SELECT r.Case_IDNO,
																				   r.Notice_ID,
																				   r.Request_DTTM
																			  FROM NMRQ_Y1 r
																			 WHERE r.Notice_ID IN (@Lc_NoticeFin33_ID)) AS r) AS r
															 WHERE r.rnm = 1) AS fin_33
											ON a.Case_IDNO = fin_33.Case_IDNO
										   LEFT OUTER JOIN (SELECT r.Case_IDNO,
																   r.Fin_34_Notice_ID,
																   r.Fin_34_Generate_DTTM
															  FROM (SELECT r.Case_IDNO,
																		   r.Fin_34_Notice_ID,
																		   r.Fin_34_Generate_DTTM,
																		   ROW_NUMBER() OVER(PARTITION BY r.Case_IDNO, r.Fin_34_Notice_ID ORDER BY r.Fin_34_Generate_DTTM DESC) rnm
																	  FROM (SELECT r.Case_IDNO Case_IDNO,
																				   r.Notice_ID Fin_34_Notice_ID,
																				   r.Generate_DTTM Fin_34_Generate_DTTM
																			  FROM NRRQ_Y1 r
																			 WHERE r.Notice_ID IN (@Lc_NoticeFin34_ID)
																			UNION ALL
																			SELECT r.Case_IDNO,
																				   r.Notice_ID,
																				   r.Request_DTTM
																			  FROM NMRQ_Y1 r
																			 WHERE r.Notice_ID IN (@Lc_NoticeFin34_ID)) AS r) AS r
															 WHERE r.rnm = 1) AS fin_34
											ON a.Case_IDNO = fin_34.Case_IDNO
										   LEFT OUTER JOIN (SELECT r.Case_IDNO,
																   r.Fin_35_Notice_ID,
																   r.Fin_35_Generate_DTTM
															  FROM (SELECT r.Case_IDNO,
																		   r.Fin_35_Notice_ID,
																		   r.Fin_35_Generate_DTTM,
																		   ROW_NUMBER() OVER(PARTITION BY r.Case_IDNO, r.Fin_35_Notice_ID ORDER BY r.Fin_35_Generate_DTTM DESC) rnm
																	  FROM (SELECT r.Case_IDNO Case_IDNO,
																				   r.Notice_ID Fin_35_Notice_ID,
																				   r.Generate_DTTM Fin_35_Generate_DTTM
																			  FROM NRRQ_Y1 r
																			 WHERE r.Notice_ID IN (@Lc_NoticeFin35_ID)
																			UNION ALL
																			SELECT r.Case_IDNO,
																				   r.Notice_ID,
																				   r.Request_DTTM
																			  FROM NMRQ_Y1 r
																			 WHERE r.Notice_ID IN (@Lc_NoticeFin35_ID)) AS r) AS r
															 WHERE r.rnm = 1) AS fin_35
											ON a.Case_IDNO = fin_35.Case_IDNO
									 -- Open Case
									 WHERE a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
										   -- IV-D Case
										   AND a.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
										   AND a.NcpPf_IDNO != 0
										   -- Non Voluntary order
										   AND a.TypeOrder_CODE NOT IN(@Lc_OrderTypeVoluntary_CODE,@Lc_Space_TEXT)
										   -- Active support order
										   AND @Ld_Run_DATE BETWEEN a.OrderEffective_DATE AND a.OrderEnd_DATE
										   --- Obligation Exists
										   AND a.FreqLeastOble_CODE <> @Lc_Space_TEXT
										   -- Controlling Order State is Delaware
										   AND s.StateControl_CODE = @Lc_StateControlDe_CODE
										   AND CaseChargingArrears_CODE != 'C'
										   -- Arrears are greater than six month Arrear payback amount
											AND a.FullArrears_AMNT BETWEEN 0 AND (a.ExpectToPay_AMNT * 6)
										   -- Arrears are greater than 0
										    AND a.FullArrears_AMNT > 0	
										   -- No Active Case Closure chain NCP as a source
										   AND NOT EXISTS (SELECT 1
															 FROM DMJR_Y1 e
															WHERE e.Case_IDNO = a.Case_IDNO
															  AND e.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
															  AND e.Status_CODE = @Lc_RemedyStatusStart_CODE)
										   -- No Active Case Closure chain NCP as a source
										   AND NOT EXISTS (SELECT 1
															 FROM ELFC_Y1 b
															WHERE b.Case_IDNO = a.Case_IDNO
															  AND b.TypeChange_CODE = @Lc_TypeChangeCc_CODE
															  AND b.Process_DATE = @Ld_High_DATE)) AS i)s 
										WHERE Notice_ID IS NOT NULL)a
						--- Code added to avoid dupliate insert
						WHERE NOT EXISTS (
							SELECT 1 FROM  ELFC_Y1 e
								WHERE e.Case_IDNO =  a.Case_IDNO
								  AND e.MemberMci_IDNO =  a.MemberMci_IDNO
								  AND e.OthpSource_IDNO = a.OthpSource_IDNO
								  AND e.Reference_ID =  a.Reference_ID
								  AND e.TypeChange_CODE = a.TypeChange_CODE
								  AND e.Process_DATE = @Ld_High_DATE)
						-- FIN-34 NOTICE SHOULD NOT GENERATE FOR Conversion one-time payment
						 AND ((a.TypeChange_CODE = @Lc_TypeChangeTm_CODE AND (SELECT COUNT(1)
									FROM OBLE_y1 c , GLEV_Y1 b 
									WHERE   c.CASE_IDNO = a.Case_IDNO
										AND c.EndValidity_DATE= @Ld_High_DATE
										AND c.EventGlobalBeginSeq_NUMB = b.EventGlobalSeq_NUMB
										AND ((c.FreqPeriodic_CODE = 'O' AND b.Worker_ID <> @Lc_ConversionUser_TEXT) 
												OR c.FreqPeriodic_CODE <> 'O'))>1)
								OR (a.TypeChange_CODE IN (@Lc_TypeChangeYe_CODE,@Lc_TypeChangeSm_CODE)));						

	SET @Ln_ArrearNoticeCount_NUMB = @@ROWCOUNT;
	
	-- 13782 - ELFC - CR0456 Modify Credit Reporting Eligibility Criteria - START -
	
	SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_CALCULATE_DELINQUENCY';
    SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS CHAR(10))+', LastRun_DATE = '+ CAST(@Ld_LastRun_DATE AS CHAR(10));
   
	EXEC BATCH_COMMON$SP_CALCULATE_DELINQUENCY
	@Ad_Run_DATE				=	@Ld_Run_DATE,
    @Ad_LastRun_DATE			=	@Ld_LastRun_DATE,
    @Ac_Msg_CODE				=	@Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT	=	@Ls_DescriptionError_TEXT OUTPUT;
    
    IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
		SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_CALCULATE_DELINQUENCY FAILED '+ISNULL(@Ls_DescriptionError_TEXT,'');
		RAISERROR (50001,16,1);
    END
                                                                                                                                                                                                                                                                                                                                                                                                   
   SET @Ls_Sql_TEXT = 'ELFC0105 : CRPT CREDIT BUREAU';
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   INSERT ELFC_Y1
          (MemberMci_IDNO,
           Case_IDNO,
           OrderSeq_NUMB,
           Process_ID,
           TypeChange_CODE,
           OthpSource_IDNO,
           NegPos_CODE,
           Create_DATE,
           Process_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
   SELECT fci.NcpPf_IDNO,
          fci.Case_IDNO,
          fci.OrderSeq_NUMB,
          @Lc_Job_ID AS Process_ID,
          fci.TypeChange_CODE,
          fci.NcpPf_IDNO,
          fci.NegPos_CODE,
          @Ld_Run_DATE AS Create_DATE,
          @Ld_High_DATE AS Process_DATE,
          @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
          @Ld_Current_DTTM AS Update_DTTM,
          0 AS TransactionEventSeq_NUMB,--@Ln_TransactionEventSeq_NUMB,                                                                                                                                                                                                                                                                                                                                                     
          @Lc_Space_TEXT AS TypeReference_CODE,
          @Lc_Space_TEXT AS Reference_ID
     FROM (SELECT e.NcpPf_IDNO,
                  e.Case_IDNO,
                  e.OrderSeq_NUMB,
                  @Lc_TypeChangeCr_CODE AS TypeChange_CODE,
                  @Lc_NegPosPositive_CODE AS NegPos_CODE
             FROM ENSD_Y1 e
             JOIN UMSO_Y1 u
               ON u.Case_IDNO = e.Case_IDNO
              AND u.Delinquency_AMNT >= ( e.Mso_AMNT + e.ExpectToPay_AMNT ) * 3.0
            -- Open Case                                                                                                                                                                                                                                                                                                                                                                                                    
            WHERE e.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
                  -- IV-D Case                                                                                                                                                                                                                                                                                                                                                                                              
                  AND e.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
                  -- Non Voluntary Order                                                                                                                                                                                                                                                                                                                                                                                    
                  AND e.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
                  -- Active Support Order                                                                                                                                                                                                                                                                                                                                                                                   
                  AND @Ld_Run_DATE BETWEEN e.OrderEffective_DATE AND e.OrderEnd_DATE
                  -- System Date is greater than or equal to the initial support court order date plus 60 calendar days                                                                                                                                                                                                                                                                                                     
                  AND e.CourtOrderIssuedOrg_DATE < DATEADD(D, -45, @Ld_Run_DATE)
                  -- Non end-dated address exist                                                                                                                                                                                                                                                                                                                                                                            
                  AND e.NcpAddrExist_INDC = @Lc_Yes_TEXT
                  -- Confirmed good SSN exist                                                                                                                                                                                                                                                                                                                                                                               
                  AND e.NcppfSsn_NUMB != 0
                  /* Case is not Initiating interstate OR if the case is Initiating interstate the referral type is not                                                                                                                                                                                                                                                                                                     
                  Registration for Modification only */
                  AND (e.RespondInit_CODE NOT IN (@Lc_RespondInitInitiateIntrnl_TEXT, @Lc_RespondInitInitiate_TEXT, @Lc_RespondInitInitiateTribal_TEXT)
                        OR (e.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
									   AND NOT EXISTS(SELECT 1
														FROM ICAS_Y1 x
													   WHERE x.Case_IDNO = e.Case_IDNO
														 AND x.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
														 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
														 AND x.EndValidity_DATE=@Ld_High_DATE)))
                  -- 13690 - Cases meeting Credit Bureau Reporting eligibility requirements are not being selected for Credit Reporting - Start
                  -- Arrears Amount should be greater than equal to 1000                                                                                                                                                                                                                                                                                                                                                      
                  AND e.Arrears_AMNT >= 1000
                  -- 13690 - Cases meeting Credit Bureau Reporting eligibility requirements are not being selected for Credit Reporting - End
                  -- Member is not in active chapter 13 bankruptcy                                                                                                                                                                                                                                                                                                                                                          
                  AND (e.Bankruptcy13_INDC = @Lc_No_TEXT
                         OR (e.Bankruptcy13_INDC = @Lc_Yes_TEXT
                            AND ((e.Dismissed_DATE != @Ld_Low_DATE
                                  AND @Ld_Run_DATE > e.Dismissed_DATE)
                                  OR (e.Discharge_DATE != @Ld_Low_DATE
                                      AND @Ld_Run_DATE > e.Discharge_DATE))))
                  -- Case is not exempt from enforcement                                                                                                                                                                                                                                                                                                                                                                    
                  AND e.CaseExempt_INDC = @Lc_No_TEXT
                  -- CRPT remedy is not exempted                                                                                                                                                                                                                                                                                                                                                                            
                  AND e.CrptExempt_INDC = @Lc_No_TEXT
                  AND EXISTS ( SELECT 1
								 FROM ACEN_Y1 c
								WHERE c.Case_IDNO = e.Case_IDNO
								  -- 13570 End Validity Condition added	- Start
								  AND c.EndValidity_DATE = @Ld_High_DATE
								  -- 13570 End Validity Condition added	- End
								  AND c.StatusEnforce_CODE = @Lc_CaseStatusOpen_CODE )
                  -- Case Closure chain is not in active mode                                                                                                                                                                                                                                                                                                                                                                           
                  AND NOT EXISTS (SELECT 1
                                    FROM DMJR_Y1 j
                                   WHERE j.Case_IDNO = e.Case_IDNO
                                     AND j.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                                     AND j.Status_CODE = @Lc_RemedyStatusStart_CODE)
                  -- No Active Case Closure chain NCP as a source                                                                                                                                                                                                                                                                                                                                                                       
                  AND NOT EXISTS (SELECT 1
                                    FROM ELFC_Y1 a
                                   WHERE a.Case_IDNO = e.Case_IDNO
                                     AND a.TypeChange_CODE = @Lc_TypeChangeCc_CODE
                                     AND a.Process_DATE = @Ld_High_DATE)
                  -- Credit Reporting chain does not exist in active mode                                                                                                                                                                                                                                                                                                                                                   
                  AND NOT EXISTS (SELECT 1
                                    FROM DMJR_Y1 j
                                   WHERE j.Case_IDNO = e.Case_IDNO
                                     AND j.MemberMci_IDNO = e.NcpPf_IDNO
                                     AND j.OthpSource_IDNO = e.NcpPf_IDNO
                                     AND j.ActivityMajor_CODE = @Lc_MajorActivityCrpt_CODE
                                     AND j.Status_CODE = @Lc_RemedyStatusStart_CODE)
           EXCEPT
           SELECT i.MemberMci_IDNO,
                  i.Case_IDNO,
                  i.OrderSeq_NUMB,
                  i.TypeChange_CODE,
                  i.NegPos_CODE
             FROM ELFC_Y1 i
            WHERE i.Process_DATE = @Ld_High_DATE
              AND i.TypeChange_CODE = @Lc_TypeChangeCr_CODE) AS fci;
              
   -- 13782 - ELFC - CR0456 Modify Credit Reporting Eligibility Criteria - END -

   SET @Ln_CrptCount_NUMB = @@ROWCOUNT;

   COMMIT TRANSACTION ElfcMonthlyTran;

   SET @Ls_Sql_TEXT = 'ELFC0106 : BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Lc_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ld_Run_DATE AS VARCHAR(max)), '');

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     IF LTRIM(RTRIM(@Ls_DescriptionError_TEXT)) = ''
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'ELFC0106A : BATCH_COMMON$SP_UPDATE_PARM_DATE FAILED';
       SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
      END

     RAISERROR (50001,16,1);
    END

	/*Total Record count*/
	SET @Ln_TotalRecordCount_NUMB = ISNULL(@Ln_DelqnCount_NUMB,0) + ISNULL(@Ln_ArrearNoticeCount_NUMB,0) + ISNULL(@Ln_CrptCount_NUMB,0);

   SET @Ls_CursorLoc_TEXT = 'BSTL LOG : ' + ISNULL(LEFT(CAST(@Ln_DelnqCur_QNTY AS VARCHAR(4000)) + REPLICATE(@Lc_Space_TEXT, 10), 10), '') + 'CRPT : ' + ISNULL (LEFT(CAST(@Ln_CrptCount_NUMB AS VARCHAR(4000)) + REPLICATE(@Lc_Space_TEXT, 10), 10), '');

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Current_DTTM,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Package_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Ls_CursorLoc_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_INDC,
    @As_ListKey_TEXT              = @Lc_Successful_INDC,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_TotalRecordCount_NUMB;
  END TRY

  BEGIN CATCH
   --Rollback the Transaction 		                                                                                                                                                                                                                                                                                                                                                                                            
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ElfcMonthlyTran;
    END

   IF CURSOR_STATUS('Local', 'EnfGen_CUR') IN (0, 1)
    BEGIN
     CLOSE EnfGen_CUR;

     DEALLOCATE EnfGen_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   --Check for Exception information to log the description text based on the error                                                                                                                                                                                                                                                                                                                                         
   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Current_DTTM,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Ls_Package_NAME,
    @As_Procedure_NAME            = @Ls_Routine_TEXT,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT,
    @An_ProcessedRecordCount_QNTY = 0;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
