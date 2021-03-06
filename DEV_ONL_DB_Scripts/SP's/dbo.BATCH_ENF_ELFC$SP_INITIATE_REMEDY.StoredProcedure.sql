/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_INITIATE_REMEDY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_ELFC$SP_INITIATE_REMEDY
Programmer Name		: IMP Team
Description			: The procedure BATCH_ENF_ELFC$SP_INITIATE_REMEDY
Frequency			: 
Developed On		: 07/07/2011
Called BY			: BATCH_ENF_ELFC$SP_CHECK_INSERT, BATCH_ENF_EMON$SP_SYSTEM_UPDATE, BATCH_ENF_EMON$SP_UPDATE_COOPERATION_ESTP,
					  BATCH_ENF_EMON$SP_UPDATE_COOPERATION_GTST, BATCH_ENF_EMON$SP_INITIATE_REMEDY, BATCH_COMMON$SP_ADDRESS_UPDATE
					  BATCH_COMMON$SP_INSERT_ACTIVITY and BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Called On	        : BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE, BATCH_COMMON$SP_ALERT_WORKER and BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_INITIATE_REMEDY](
 @Ac_TypeChange_CODE          CHAR(2),
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_OthpSource_IDNO          NUMERIC(10),
 @Ac_TypeOthpSource_CODE      CHAR(1),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_Subsystem_CODE           CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Worker_ID                CHAR(30),
 @Ad_Run_DATE                 DATE = NULL,
 @Ac_TypeReference_CODE       CHAR(5) = ' ',
 @Ac_Reference_ID             CHAR(30) = ' ',
 @Ac_Process_ID               CHAR(10),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(MAX) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_AdvanceTheChain5600_NUMB		INT			= 5600,
		  @Ln_MemberMciUnidentified_IDNO	NUMERIC(10)	= 999995,
          @Lc_Space_TEXT					CHAR(1)		= ' ',
          @Lc_CaseStatusOpen_CODE			CHAR(1)		= 'O',
          @Lc_StatusNoDataFound_CODE		CHAR(1)		= 'N',
          @Lc_EnforcementStatusOpen_CODE	CHAR(1)		= 'O',
          @Lc_StatusSuccess_CODE			CHAR(1)		= 'S',
          @Lc_MsgKeydatanotfound_CODE		CHAR(1)		= 'K',
          @Lc_StatusFailed_CODE				CHAR(1)		= 'F',
          @Lc_No_INDC						CHAR(1)		= 'N',
          @Lc_Yes_INDC						CHAR(1)		= 'Y',
          @Lc_StatusLocateLocated_CODE		CHAR(1)		= 'L',
          @Lc_TypeCaseNonIVD_CODE			CHAR(1)		= 'H',
          @Lc_CaseRelationshipNcp_CODE		CHAR(1)		= 'A',
          @Lc_CaseRelationshipPf_CODE		CHAR(1)		= 'P',
          @Lc_CaseRelationshipDep_CODE		CHAR(1)		= 'D',
          @Lc_CaseMemberStatusActive_CODE	CHAR(1)		= 'A',
          @Lc_MessageT_CODE					CHAR(1)		= 'T',
          @Lc_RespondInitN_CODE				CHAR(1)		= 'N',
          @Lc_RespondInitR_CODE				CHAR(1)		= 'R',
          @Lc_RespondInitS_CODE				CHAR(1)		= 'S',
          @Lc_RespondInitY_CODE				CHAR(1)		= 'Y',
          @Lc_SubsystemEnforcement_TEXT		CHAR(2)		= 'EN',
          @Lc_SubsystemEstablishment_TEXT	CHAR(2)		= 'ES',
          @Lc_RemedyStatusReasonBi_CODE		CHAR(2)		= 'BI',
          @Lc_TypeDebtChildSupport_CODE		CHAR(2)		= 'CS',
          @Lc_TypeDebtMedicalSupport_CODE	CHAR(2)		= 'MS',
          @Lc_TypeChangeLs_CODE				CHAR(2)		= 'LS',
          @Lc_TypeChangeCa_CODE				CHAR(2)		= 'CA',
          @Lc_TypeChangeRa_CODE				CHAR(2)		= 'RA',
          @Lc_TypeChangeRe_CODE				CHAR(2)		= 'RE',
          @Lc_TypeChangeRm_CODE				CHAR(2)		= 'RM', 
          @Lc_TypeChangeRn_CODE				CHAR(2)		= 'RN',
          @Lc_TypeChangeCc_CODE				CHAR(2)		= 'CC',
          @Lc_ReasonStatusZa_CODE			CHAR(2)		= 'ZA',
		  @Lc_ReasonStatusCq_CODE			CHAR(2)		= 'CQ',
		  @Lc_ReasonStatusOa_CODE			CHAR(2)		= 'OA',
		  @Lc_ReasonStatusOb_CODE			CHAR(2)		= 'OB',
		  @Lc_ReasonStatusOe_CODE			CHAR(2)		= 'OE',
		  @Lc_ReasonStatusOf_CODE			CHAR(2)		= 'OF',
          @Lc_RemedyStatusStart_CODE		CHAR(4)		= 'STRT',
          @Lc_RemedyStatusExempt_CODE		CHAR(4)		= 'EXMT',
          @Lc_ActivityMajorEstp_CODE		CHAR(4)		= 'ESTP',
          @Lc_ActivityMajorCrpt_CODE		CHAR(4)		= 'CRPT',
          @Lc_ActivityMajorImiw_CODE		CHAR(4)		= 'IMIW',
          @Lc_ActivityMajorLsnr_CODE		CHAR(4)		= 'LSNR',
          @Lc_ProcessCcrt_ID				CHAR(4)		= 'CCRT',
          -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Starts
          @Lc_ActivityMajorCpls_CODE		CHAR(4)		= 'CPLS',
          @Lc_ErrorE0027_CODE				CHAR(5)		= 'E0027',
          -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Ends
          @Lc_ErrorE0073_CODE				CHAR(5)		= 'E0073',
          @Lc_ErrorE0026_CODE				CHAR(5)		= 'E0026',
          @Lc_JobIVa_ID						CHAR(7)		= 'DEB9902',
          @Ls_Routine_TEXT					VARCHAR(75) = 'BATCH_ENF_ELFC.BATCH_ENF_ELFC$SP_INITIATE_REMEDY',
          @Ld_Low_DATE						DATE		= '01/01/0001',
          @Ld_High_DATE						DATE		= '12/31/9999';
  DECLARE @Ln_Rowcount_QNTY					NUMERIC,
          @Ln_Error_NUMB					NUMERIC,
          @Ln_QNTY							NUMERIC(4),
          @Ln_MajorIntSeq_NUMB				NUMERIC(5),
          @Ln_MinorIntSeq_NUMB				NUMERIC(5),
          @Ln_Forum_IDNO					NUMERIC(10),
          @Ln_Topic_IDNO					NUMERIC(10),
          @Ln_ErrorLine_NUMB				NUMERIC(11),
          @Ln_TransactionEventSeq_NUMB		NUMERIC(19),
          @Lc_ReasonStatus_CODE				CHAR(2)		= '',
          @Lc_TypeReference_CODE			CHAR(5),
          @Lc_ActivityMinor_CODE			CHAR(5),
          @Lc_Reference_ID					CHAR(30),
          @Ls_Sql_TEXT						VARCHAR(100),
          @Ls_SqlData_TEXT					VARCHAR(1000),
          @Ls_DescriptionError_TEXT			VARCHAR(MAX) = '',
          @Ld_DueActivity_DATE				DATE,
          @Ld_DueAlertWarn_DATE				DATE;

  BEGIN TRY
   
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Lc_TypeReference_CODE = ISNULL(@Ac_TypeReference_CODE, @Lc_Space_TEXT);
   SET @Lc_Reference_ID = ISNULL(@Ac_Reference_ID, @Lc_Space_TEXT);
   SET @Ls_Sql_TEXT = 'SELECT CASE OPEN IN ENSD_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS CHAR(6)), '');

   SELECT @Ln_QNTY = COUNT(*)
     FROM CASE_Y1 c
    WHERE c.Case_IDNO = @An_Case_IDNO
      AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

   IF @Ln_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0073_CODE;
     SET @As_DescriptionError_TEXT = 'Case is not open';
     RETURN;
    END

  
   IF @Ac_ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
    BEGIN
		-- 13703 - Establishment Process chains start where the PF MCI on the case is 999995 – UNKNOWN ABSENT PARENT - Start
		IF @An_OthpSource_IDNO = @Ln_MemberMciUnidentified_IDNO
		BEGIN
			SET @Ac_Msg_CODE = @Lc_ErrorE0026_CODE;
			SET @As_DescriptionError_TEXT = 'Update not allowed for MCI 999995 - UNIDENTIFIED ABSENT PARENT';
			RETURN;
		END
		-- 13703 - Establishment Process chains start where the PF MCI on the case is 999995 – UNKNOWN ABSENT PARENT - End
		
		SELECT @Ln_QNTY = COUNT(1)
		  FROM CASE_Y1 c 
		  JOIN CMEM_Y1 n
		    ON n.Case_IDNO = c.Case_IDNO
		   AND n.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
		   AND n.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
		 WHERE c.Case_IDNO = @An_Case_IDNO
		   AND c.TypeCase_CODE != @Lc_TypeCaseNonIVD_CODE
		   AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
		   AND c.RespondInit_CODE IN (@Lc_RespondInitN_CODE,@Lc_RespondInitR_CODE,@Lc_RespondInitS_CODE,@Lc_RespondInitY_CODE)
		   AND NOT EXISTS (SELECT 1
							 FROM DMJR_Y1 j
							 WHERE j.Case_IDNO = c.Case_IDNO
							   AND j.OthpSource_IDNO = n.MemberMci_IDNO
							   AND j.MemberMci_IDNO = n.MemberMci_IDNO
							   AND j.ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
							   AND j.Status_CODE = @Lc_RemedyStatusStart_CODE)
			AND EXISTS (SELECT 1
							FROM LSTT_Y1 l
						  WHERE l.MemberMci_IDNO = n.MemberMci_IDNO
							AND l.StatusLocate_CODE = @Lc_StatusLocateLocated_CODE
							AND l.EndValidity_DATE = @Ld_High_DATE)
			AND EXISTS (SELECT 1
						  FROM CMEM_Y1 m
						 WHERE Case_IDNO = c.Case_IDNO
						   AND CaseRelationship_CODE = @Lc_CaseRelationshipDep_CODE
						   AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
						   AND NOT EXISTS (SELECT 1
											 FROM OBLE_Y1 o
											WHERE o.Case_IDNO = m.Case_IDNO
											  AND o.EndValidity_DATE =  @Ld_High_DATE
											  AND o.MemberMci_IDNO = m.MemberMci_IDNO
											  AND o.TypeDebt_CODE IN (@Lc_TypeDebtChildSupport_CODE, @Lc_TypeDebtMedicalSupport_CODE)))
			-- 13716 - CPRO - CR0429 ESTP Should Not Start Automatically on Medicaid Only Cases - START
			AND ( NOT EXISTS (SELECT 1
							   FROM SORD_Y1 s
						      WHERE s.Case_IDNO = c.Case_IDNO
						        AND s.EndValidity_DATE = @Ld_High_DATE
						        AND CASE WHEN s.MedicalOnly_INDC = @Lc_No_INDC
									     THEN s.MedicalOnly_INDC
									     ELSE c.MedicalOnly_INDC
									END = @Lc_Yes_INDC)
				  OR EXISTS ( SELECT 1
								FROM CMEM_Y1 m
							   WHERE m.Case_IDNO = c.Case_IDNO
							     AND m.CaseRelationship_CODE = @Lc_CaseRelationshipDep_CODE
								 AND m.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
								 AND m.BeginValidity_DATE = @Ad_Run_DATE
								 AND @Ac_Process_ID IN (@Lc_ProcessCcrt_ID, @Lc_JobIVa_ID)) );
			-- 13716 - CPRO - CR0429 ESTP Should Not Start Automatically on Medicaid Only Cases - END
		                   
		IF @Ln_QNTY = 0
		BEGIN
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
			SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
			RETURN;
		END
    END
    
    -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Starts
    -- Check whether more than one Putative Father active in the Case for CPLS chain.
    IF @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCpls_CODE
		AND 1 < (SELECT COUNT(1)
				   FROM CMEM_Y1 c
				  WHERE c.Case_IDNO = @An_Case_IDNO
				    AND c.CaseRelationship_CODE = @Lc_CaseRelationshipPf_CODE
				    AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
    BEGIN
		SET @Ac_Msg_CODE = @Lc_ErrorE0027_CODE;
		SET @As_DescriptionError_TEXT = 'Cannot start remedy when more than one active PF exists on the case';
		RETURN;
    END
    -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Ends
    
    /*If activity already exists in Active mode then dont initiate again*/
     SET @Ls_Sql_TEXT = 'ELFC0107A 1: SELECT DMJR_Y1 EXISTS';
     IF EXISTS (
				SELECT 1 FROM DMJR_Y1 d
						WHERE d.Case_IDNO = @An_Case_IDNO
						  AND d.OrderSeq_NUMB = @An_OrderSeq_NUMB
						  AND d.MemberMci_IDNO = @An_MemberMci_IDNO
						  AND ( d.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
								OR ( @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE, @Lc_ActivityMajorCpls_CODE)
										AND d.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE, @Lc_ActivityMajorCpls_CODE))
							  )
						  AND d.Subsystem_CODE = @Ac_Subsystem_CODE
						  AND d.OthpSource_IDNO = @An_OthpSource_IDNO 
						  AND d.TypeOthpSource_CODE = @Ac_TypeOthpSource_CODE	  
						  AND d.Reference_ID = @Ac_Reference_ID
						  AND (d.TypeReference_CODE = @Ac_TypeReference_CODE OR ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE)
						  AND d.Status_CODE IN (@Lc_RemedyStatusStart_CODE,@Lc_RemedyStatusExempt_CODE)
				)
		BEGIN
			-- Return sucesses when activity already inititated
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
			SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
			
			RETURN;
		END
    

   IF @Ac_Subsystem_CODE = @Lc_SubsystemEnforcement_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'ELFC0107A : SELECT ACEN_Y1 EXISTS';
     SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', StatusEnforce_CODE = ' + ISNULL(@Lc_EnforcementStatusOpen_CODE, '');

     SELECT @Ln_QNTY = COUNT(Case_IDNO)
       FROM ACEN_Y1 n
      WHERE n.Case_IDNO = @An_Case_IDNO
        AND n.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND n.EndValidity_DATE = @Ld_High_DATE
        AND n.StatusEnforce_CODE = @Lc_EnforcementStatusOpen_CODE;

     IF @Ln_QNTY = 0 
      BEGIN
       SET @Ac_Msg_CODE = 'I0097';
       SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'ELFC0107B : CASE IS NOT OPEN IN ACEN_Y1' + ' ' + ISNULL(@Ls_SqlData_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');

       RETURN;
      END
    END
   ELSE IF @Ac_Subsystem_CODE = @Lc_SubsystemEstablishment_TEXT
    BEGIN
     SET @Ls_Sql_TEXT = 'ELFC0107C : SELECT ACES_Y1 EXISTS';
     SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', StatusEstablish_CODE = ' + ISNULL(@Lc_EnforcementStatusOpen_CODE, '');

     SELECT @Ln_QNTY = COUNT(Case_IDNO)
       FROM ACES_Y1 s
      WHERE s.Case_IDNO = @An_Case_IDNO
        AND s.EndValidity_DATE = @Ld_High_DATE
        AND s.StatusEstablish_CODE = @Lc_EnforcementStatusOpen_CODE;

     IF @Ln_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = 'E0131';
       SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'ELFC0107D : CASE IS NOT OPEN IN ACES_Y1' + ' ' + ISNULL(@Ls_SqlData_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');

       RETURN;
      END
    END

   SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
  
   SET @Ls_Sql_TEXT = 'ELFC0108 : SELECT NEXT MajorIntSeq_NUMB FROM DMJR_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');

   SELECT @Ln_MajorIntSeq_NUMB = ISNULL(MAX(j.MajorIntSeq_NUMB), 0) + 1
     FROM DMJR_Y1 j
    WHERE j.Case_IDNO = @An_Case_IDNO;

   SET @Ls_Sql_TEXT = 'ELFC0109 : INSERT DMJR_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Ac_Subsystem_CODE, '') + ', TypeOthpSource_CODE = ' + ISNULL(@Ac_TypeOthpSource_CODE, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_OthpSource_IDNO AS VARCHAR(10)), '') + ', TypeReference_CODE = ' + ISNULL(@Lc_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Lc_Reference_ID, '') + ', Run_Date = ' + CAST(@Ad_Run_Date AS VARCHAR) + ', Worker_ID = ' + @Ac_Worker_ID;

   INSERT DMJR_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           MajorIntSeq_NUMB,
           MemberMci_IDNO,
           ActivityMajor_CODE,
           Subsystem_CODE,
           TypeOthpSource_CODE,
           OthpSource_IDNO,
           Entered_DATE,
           Status_DATE,
           Status_CODE,
           ReasonStatus_CODE,
           BeginExempt_DATE,
           EndExempt_DATE,
           TotalTopics_QNTY,
           PostLastPoster_IDNO,
           UserLastPoster_ID,
           SubjectLastPoster_TEXT,
           LastPost_DTTM,
           BeginValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB,
           TypeReference_CODE,
           Reference_ID)
   VALUES ( @An_Case_IDNO,--Case_IDNO               
            ISNULL(@An_OrderSeq_NUMB, 0),--OrderSeq_NUMB           
            @Ln_MajorIntSeq_NUMB,--MajorIntSeq_NUMB        
            @An_MemberMci_IDNO,--MemberMci_IDNO          
            @Ac_ActivityMajor_CODE,--ActivityMajor_CODE      
            @Ac_Subsystem_CODE,--Subsystem_CODE          
            ISNULL(@Ac_TypeOthpSource_CODE, @Lc_Space_TEXT),--TypeOthpSource_CODE     
            ISNULL(@An_OthpSource_IDNO, 0),--OthpSource_IDNO         
            @Ad_Run_DATE,--Entered_DATE            
            @Ld_High_DATE,--Status_DATE             
            @Lc_RemedyStatusStart_CODE,--Status_CODE             
            @Lc_RemedyStatusReasonBi_CODE,--ReasonStatus_CODE       
            @Ld_Low_DATE,--BeginExempt_DATE        
            @Ld_Low_DATE,--EndExempt_DATE          
            0,--TotalTopics_QNTY        
            0,--PostLastPoster_IDNO     
            @Lc_Space_TEXT,--UserLastPoster_ID       
            @Lc_Space_TEXT,--SubjectLastPoster_TEXT  
            @Ld_Low_DATE,--LastPost_DTTM           
            @Ad_Run_DATE,--BeginValidity_DATE      
            @Ac_Worker_ID,--WorkerUpdate_ID         
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM             
            @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
            @Lc_TypeReference_CODE,--TypeReference_CODE      
            @Lc_Reference_ID); --Reference_ID            
   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @As_DescriptionError_TEXT = 'DMJR_Y1 INSERT FAILED';
     RAISERROR (50001,16,1);
    END

   SET @Ln_Forum_IDNO = SCOPE_IDENTITY();
   
   SET @Ls_Sql_TEXT = 'SELECT NEXT Topic_IDNO SEQUENCE VALUE';
   SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;


   INSERT INTO ITOPC_Y1
               (Entered_DATE)
        VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() --Entered_DATE
   );

   SET @Ln_Topic_IDNO = @@IDENTITY;

   
   SET @Ls_Sql_TEXT = 'ELFC0111 : SELECT FIRST ACTIVITY DETAILS OF REMEDY FROM ANXT_Y1';
   SET @Ls_SqlData_TEXT = ' ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '');

   SELECT @Lc_ActivityMinor_CODE = n.ActivityMinor_CODE
     FROM ANXT_Y1 n,
          AMNR_Y1 a
    WHERE n.ActivityMinor_CODE = a.ActivityMinor_CODE
      AND n.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
      AND n.ActivityOrder_QNTY = 1
      AND n.ReasonOrder_QNTY = 1
      AND n.EndValidity_DATE = @Ld_High_DATE
      AND a.EndValidity_DATE = @Ld_High_DATE
    ORDER BY n.ActivityOrder_QNTY,
             n.ReasonOrder_QNTY;

   -- 13570 Procedure name correction	- Start
   SET @Ls_Sql_TEXT = 'ELFC0112 : BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE - 1';
   -- 13570 Procedure name correction	- End
   SET @Ls_SqlData_TEXT = ' ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

   DECLARE @Ld_Temp_DATE DATE;

   SET @Ld_Temp_DATE = dbo.BATCH_COMMON$SF_GET_DURATION_START_DATE (@An_Case_IDNO, @Ln_MajorIntSeq_NUMB, @Lc_ActivityMinor_CODE, NULL, @Ad_Run_DATE);

   EXECUTE BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE
    @Ac_ActivityMinor_CODE    = @Lc_ActivityMinor_CODE,
    @Ad_Run_DATE              = @Ld_Temp_DATE,
    @Ad_DueActivity_DATE      = @Ld_DueActivity_DATE OUTPUT,
    @Ad_DueAlertWarn_DATE     = @Ld_DueAlertWarn_DATE OUTPUT,
    @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'ELFC0112 : BATCH_COMMON_GETS$SP_GET_DUE_ALERT_DATE - 1 FAILED' + ' ' + ISNULL(@Ls_SqlData_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
     RETURN;
    END

 
   SET @Ls_Sql_TEXT = 'ELFC0113 :SELECT MinorIntSeq_NUMB FROM UDMNR_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '');

   SELECT @Ln_MinorIntSeq_NUMB = ISNULL(MAX(MinorIntSeq_NUMB), 0) + 1
     FROM UDMNR_V1 A
    WHERE Case_IDNO = @An_Case_IDNO
      AND MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB;

   SET @Ls_Sql_TEXT = 'ELFC0114 : INSERT DMNR_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', MajorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR), '') + ', MinorIntSeq_NUMB = ' + ISNULL(CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '');

   INSERT DMNR_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           MajorIntSeq_NUMB,
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
   VALUES ( @An_Case_IDNO,--Case_IDNO               
            ISNULL(@An_OrderSeq_NUMB, 0),--OrderSeq_NUMB           
            @Ln_MajorIntSeq_NUMB,--MajorIntSeq_NUMB        
            @Ln_MinorIntSeq_NUMB,--MinorIntSeq_NUMB        
            @An_MemberMci_IDNO,--MemberMci_IDNO          
            @Lc_ActivityMinor_CODE,--ActivityMinor_CODE      
            @Lc_Space_TEXT,--ActivityMinorNext_CODE  
            @Ad_Run_DATE,--Entered_DATE            
            @Ld_DueActivity_DATE,--Due_DATE                
            @Ld_High_DATE,--Status_DATE             
            @Lc_RemedyStatusStart_CODE,--Status_CODE             
            @Lc_Space_TEXT,--ReasonStatus_CODE       
            0,--Schedule_NUMB           
            @Ln_Forum_IDNO,--Forum_IDNO              
            @Ln_Topic_IDNO,--Topic_IDNO              
            0,--TotalReplies_QNTY       
            0,--TotalViews_QNTY         
            0,--PostLastPoster_IDNO     
            @Ac_Worker_ID,--UserLastPoster_ID       
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--LastPost_DTTM           
            CASE
             WHEN @Ld_DueAlertWarn_DATE < @Ad_Run_DATE
              THEN @Ad_Run_DATE
             ELSE @Ld_DueAlertWarn_DATE
            END,--AlertPrior_DATE         
            @Ad_Run_DATE,--BeginValidity_DATE      
            @Ac_Worker_ID,--WorkerUpdate_ID         
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM             
            @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
            @Lc_Space_TEXT,--WorkerDelegate_ID       
            @Ac_Subsystem_CODE,--Subsystem_CODE          
            @Ac_ActivityMajor_CODE); --ActivityMajor_CODE      

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_Sql_TEXT, '') + ISNULL(@Lc_Space_TEXT, '') + 'DMNR_Y1 INSERT FAILED' + ISNULL(@Lc_Space_TEXT, '') + ISNULL(@Ls_SqlData_TEXT, '');
     RETURN;
    END
    
   IF  @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCrpt_CODE
	BEGIN
		   SET @Ls_Sql_TEXT = 'ELFC0118 - 1 : BATCH_COMMON$SP_INSERT_CBOR';
		   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') 
								+ ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') 
								+ ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') 
								+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') 
								+ ', Worker_ID = ' + ISNULL(@Ac_Worker_ID, '') 
								+ ',  Support_INDC = E';
							  

			EXECUTE  BATCH_COMMON$SP_INSERT_CBOR				
			@An_Case_IDNO                = @An_Case_IDNO,
			@An_MemberMci_IDNO           = @An_MemberMci_IDNO,
			@An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
			@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
			@An_WorkerUpdate_ID          = @Ac_Worker_ID,
			@Ad_Run_DATE                 = @Ad_Run_DATE,
			@Ac_Support_INDC			 = 'E', ---> Insert from ELFC Process
			@Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;	
				
			IF @Ac_Msg_CODE	 <> @Lc_StatusSuccess_CODE
			BEGIN
				SET @Ls_Sql_TEXT = 'Error In BATCH_COMMON$SP_INSERT_CBOR ';
				RAISERROR (50001,16,1);
			END
		END					
		    

   SET @Ls_Sql_TEXT = 'ELFC0118 : BATCH_COMMON$SP_ALERT_WORKER';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Subsystem_CODE = ' + ISNULL(@Ac_Subsystem_CODE, '') + ', CD_ACTIVITY_MAJOR = ' + ISNULL(@Ac_ActivityMajor_CODE, '') + ', CD_ACTIVITY_MINOR = ' + ISNULL(@Lc_ActivityMinor_CODE, '') + ', CD_REASON_STATUS = ' + '' + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Worker_ID = ' + ISNULL(@Ac_Worker_ID, '') + ', ReasonStatus_CODE = ' + ISNULL(@Lc_ReasonStatus_CODE, '');

   EXECUTE BATCH_COMMON$SP_ALERT_WORKER
    @An_Case_IDNO                = @An_Case_IDNO,
    @Ac_Subsystem_CODE           = @Ac_Subsystem_CODE,
    @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
    @Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
    @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
    @An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
    @Ac_SignedonWorker_ID        = @Ac_Worker_ID,
    @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
    @Ad_Run_DATE                 = @Ad_Run_DATE,
    @Ac_Job_ID                   = @Ac_Process_ID,
    @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'ELFC0118 : BATCH_COMMON$SP_ALERT_WORKER FAILED' + ' ' + ISNULL(@Ls_SqlData_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
     RETURN;
    END

   IF @Ld_DueActivity_DATE = @Ad_Run_DATE
    BEGIN
     IF @Ac_TypeChange_CODE IN (@Lc_TypeChangeLs_CODE, @Lc_TypeChangeCa_CODE, @Lc_TypeChangeRa_CODE, @Lc_TypeChangeRe_CODE,
                                @Lc_TypeChangeRm_CODE, @Lc_TypeChangeRn_CODE,@Lc_TypeChangeCc_CODE)
      BEGIN
       IF @Ac_TypeChange_CODE = @Lc_TypeChangeLs_CODE
        BEGIN
         SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusZa_CODE;
        END
       ELSE IF @Ac_TypeChange_CODE = @Lc_TypeChangeCa_CODE
        BEGIN
         SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusCq_CODE;
        END
       ELSE IF @Ac_TypeChange_CODE = @Lc_TypeChangeRa_CODE
        BEGIN
         SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusOa_CODE;
        END
       ELSE IF @Ac_TypeChange_CODE = @Lc_TypeChangeRe_CODE
        BEGIN
         SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusOb_CODE;
        END
       ELSE IF @Ac_TypeChange_CODE = @Lc_TypeChangeRm_CODE
        BEGIN
         SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusOe_CODE;
        END
       ELSE IF @Ac_TypeChange_CODE = @Lc_TypeChangeRn_CODE
        BEGIN
         SET @Lc_ReasonStatus_CODE = @Lc_ReasonStatusOf_CODE;
        END
       ELSE IF @Ac_TypeChange_CODE = @Lc_TypeChangeCc_CODE
        BEGIN
         SET @Lc_ReasonStatus_CODE = @Lc_Reference_ID;
        END
      END
     ELSE
      SET @Lc_ReasonStatus_CODE = dbo.BATCH_ENF_EMON$SF_GET_REASON (@An_Case_IDNO, @An_OrderSeq_NUMB, @An_MemberMci_IDNO, @An_OthpSource_IDNO, @Ac_ActivityMajor_CODE, @Lc_ActivityMinor_CODE, @Ln_MajorIntSeq_NUMB, @Ad_Run_DATE, @Ad_Run_DATE, @Ld_DueActivity_DATE, @Ln_TransactionEventSeq_NUMB,
                                  @Lc_Reference_ID);

     IF @Lc_ReasonStatus_CODE != ''
      BEGIN
		   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT';
		   SET @Ls_SqlData_TEXT = @Lc_Space_TEXT;

		   EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
			@Ac_Worker_ID                = @Ac_Worker_ID,
			@Ac_Process_ID               = @Ac_Process_ID,
			@Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
			@Ac_Note_INDC                = @Lc_No_INDC,
			@An_EventFunctionalSeq_NUMB  = @Li_AdvanceTheChain5600_NUMB,
			@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
			@Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

		   IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
			BEGIN
			 SET @As_DescriptionError_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT FAILED'+ ' '+ISNULL(@As_DescriptionError_TEXT,'');
			 RAISERROR (50001,16,1);
			END

		   SET @Ls_Sql_TEXT = 'EMON010 : BATCH_COMMON.SP_UPDATE_MINOR_ACTIVITY';
		   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR) + ', Forum_IDNO = ' + CAST(@Ln_Forum_IDNO AS VARCHAR) + ', MajorIntSeq_NUMB = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR) + ', MinorIntSeq_NUMB = ' + CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR) + ', ActivityMajor_CODE = ' + @Ac_ActivityMajor_CODE + ', ActivityMinor_CODE = ' + @Lc_ActivityMinor_CODE + ', ReasonStatus_CODE = ' + @Lc_ReasonStatus_CODE + ', Worker_ID = ' + @Ac_Worker_ID + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS CHAR (10));

		   EXECUTE BATCH_COMMON$SP_UPDATE_MINOR_ACTIVITY
			@An_Case_IDNO                = @An_Case_IDNO,
			@An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
			@An_MemberMci_IDNO           = @An_MemberMci_IDNO,
			@An_Forum_IDNO               = @Ln_Forum_IDNO,
			@An_Topic_IDNO               = @Ln_Topic_IDNO,
			@An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
			@An_MinorIntSeq_NUMB         = @Ln_MinorIntSeq_NUMB,
			@Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
			@Ac_ActivityMinor_CODE       = @Lc_ActivityMinor_CODE,
			@Ac_ReasonStatus_CODE        = @Lc_ReasonStatus_CODE,
			@An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
			@Ac_WorkerUpdate_ID          = @Ac_Worker_ID,
			@Ad_Run_DATE                 = @Ad_Run_DATE,
			@Ac_Process_ID               = @Ac_Process_ID,
			@Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

		   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
		   BEGIN
				SET @As_DescriptionError_TEXT = 'BATCH_COMMON.SP_UPDATE_MINOR_ACTIVITY FAILED' + ' ' + @Ls_SqlData_TEXT + ' ' + ISNULL(@As_DescriptionError_TEXT,'');
				RAISERROR (50001,16,1);
		   END
		END
	END
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   IF @Ac_Msg_CODE IS NULL
       OR @Ac_Msg_CODE = ''
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
