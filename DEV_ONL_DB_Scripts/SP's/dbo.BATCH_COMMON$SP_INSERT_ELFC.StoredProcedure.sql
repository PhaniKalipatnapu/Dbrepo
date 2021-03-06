/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_ELFC]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_ELFC
Programmer Name		: IMP Team
Description			: This procedure is used to insert record in ELFC_Y1 table.
Frequency			: 
Developed On		: 04/12/2011
Called By			: BATCH_ENF_INCOMING_CSLN$SP_UPDATE_ASFN, BATCH_ENF_INCOMING_DMV$SP_PROCESS_DMV, BATCH_ENF_INCOMING_FIDM$SP_UPDATE_ASFN
					  BATCH_FIN_REG_DISTRIBUTION$SP_INSERT_RCTH, BATCH_CM_CASE_CLOSURE_ELIG$SP_PROCESS_CASE_CLOSURE, BATCH_ENF_EMON$SP_SYSTEM_UPDATE
					  BATCH_LOC_INCOMING_FCR$SP_INSMATCH_DETAILS, BATCH_LOC_INCOMING_FCR$SP_MSFIDM_DETAILS,
					  BATCH_COMMON$SP_EMPLOYER_UPDATE, BATCH_LOC_INCOMING_DIA$SP_PROCESS_DIA, BATCH_CM_MERG$SP_EMPLOYER_MERGE, BATCH_COMMON$SP_DINS_UPDATE
					  BATCH_FIN_IVA_UPDATES$SP_CASE_MHIS_UPDATE, BATCH_CI_INCOMING_CSENET_FILE$SP_INSERT_CASECLOSURE, BATCH_COMMON$SP_LICENSE_UPDATE
Called On			: BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_ELFC](
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_OthpSource_IDNO          NUMERIC(10),
 @Ac_TypeChange_CODE          CHAR(2),
 @Ac_NegPos_CODE              CHAR(1),
 @Ac_Process_ID               CHAR(10),
 @Ad_Create_DATE              DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30)		= NULL,
 @Ac_SignedonWorker_ID        CHAR(30)		= NULL,
 @Ac_TypeReference_CODE       CHAR(5)		= ' ',
 @Ac_Reference_ID             CHAR(30)		= ' ',
 @Ac_Msg_CODE                 CHAR(5)		OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE
		@Lc_Space_TEXT									CHAR(1)		= ' ',
		@Lc_StatusFailed_CODE							CHAR(1)		= 'F',
		@Lc_StatusSuccess_CODE							CHAR(1)		= 'S',
		@Lc_NoteN_INDC									CHAR(1)		= 'N',
		@Lc_CaseStatusOpen_CODE							CHAR(1)		= 'O',
		@Lc_CaseTypeNonIvd_CODE							CHAR(1)		= 'H',
		@Lc_Yes_INDC									CHAR(1)		= 'Y',
		@Lc_No_INDC										CHAR(1)		= 'N',
		@Lc_OrderTypeVoluntary_CODE						CHAR(1)		= 'V',
		@Lc_RespondInitInitiate_TEXT					CHAR(1)		= 'I',
		@Lc_RespondInitInitiateIntrnl_TEXT				CHAR(1)		= 'C',
		@Lc_RespondInitInitiateTribal_TEXT				CHAR(1)		= 'T',
		@Lc_StatusY_CODE								CHAR(1)		= 'Y',
		@Lc_StatusP_CODE								CHAR(1)		= 'P',
		@Lc_IiwoC_CODE									CHAR(1)		= 'C',
		@Lc_IiwoI_CODE									CHAR(1)		= 'I',
		@Lc_TypeOthpG_CODE								CHAR(1)		= 'G',
		@Lc_RespondInitRespondingState_CODE				CHAR(1)		= 'R',
		@Lc_RespondInitRespondingTribal_CODE			CHAR(1)		= 'S',
		@Lc_RespondInitRespondingInternational_CODE		CHAR(1)		= 'Y',
		@Lc_StatusEnforceExempt_CODE					CHAR(1)		= 'E',
		@Lc_TypeChangeCc_CODE							CHAR(2)		= 'CC',
		@Lc_TypeChangeIw_CODE							CHAR(2)		= 'IW',
		@Lc_StateInState_CODE							CHAR(2)		= 'DE',
		@Lc_CaseCategoryPc_CODE							CHAR(2)		= 'PC',
		@Lc_CaseCategoryDp_CODE							CHAR(2)		= 'DP',
		@Lc_TypeIncomeEm_CODE							CHAR(2)		= 'EM',
		@Lc_TypeIncomeCs_CODE							CHAR(2)		= 'CS',
		@Lc_TypeIncomeDs_CODE							CHAR(2)		= 'DS',
		@Lc_TypeIncomeMb_CODE							CHAR(2)		= 'MB',
		@Lc_TypeIncomeMl_CODE							CHAR(2)		= 'ML',
		@Lc_TypeIncomeMr_CODE							CHAR(2)		= 'MR',
		@Lc_TypeIncomeRt_CODE							CHAR(2)		= 'RT',
		@Lc_TypeIncomeSe_CODE							CHAR(2)		= 'SE',
		@Lc_TypeIncomeSs_CODE							CHAR(2)		= 'SS',
		@Lc_TypeIncomeUi_CODE							CHAR(2)		= 'UI',
		@Lc_TypeIncomeUn_CODE							CHAR(2)		= 'UN',
		@Lc_TypeIncomeVp_CODE							CHAR(2)		= 'VP',
		@Lc_TypeIncomeWc_CODE							CHAR(2)		= 'WC',
		@Lc_RemedyStatusStart_CODE						CHAR(4)		= 'STRT',
		@Lc_ActivityMajorCclo_CODE						CHAR(4)		= 'CCLO',
		@Lc_ActivityMajorImiw_CODE						CHAR(4)		= 'IMIW',
		@Lc_ReasonErfso_CODE							CHAR(5)		= 'ERFSO',
		@Lc_ReasonErfsm_CODE							CHAR(5)		= 'ERFSM',
		@Lc_ReasonErfss_CODE							CHAR(5)		= 'ERFSS',
		@Ls_Routine_TEXT								VARCHAR(60)	= 'BATCH_COMMON$SP_INSERT_ELFC',
		@Ld_Low_DATE									DATE		= '01/01/0001',
		@Ld_High_DATE									DATE		= '12/31/9999';
	DECLARE 
		@Ln_Rowcount_QNTY								NUMERIC,
		@Ln_Error_NUMB									NUMERIC,
		@Ln_Value_QNTY									NUMERIC(11),
		@Ln_ErrorLine_NUMB								NUMERIC(11),
		@Ln_TransactionEventSeq_NUMB					NUMERIC(19),
		@Lc_Msg_CODE									CHAR(5),
		@Ls_Sql_TEXT									VARCHAR(100),
		@Ls_Sqldata_TEXT								VARCHAR(1000),
		@Ls_ErrorMessage_TEXT							VARCHAR(4000)= '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   IF(@Ac_SignedonWorker_ID IS NOT NULL)
    BEGIN
     SET @Ac_WorkerUpdate_ID = @Ac_SignedonWorker_ID;
    END

   SET @Ls_Sql_TEXT = 'SELECT ELFC_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', OthpSource_IDNO = ' + ISNULL(CAST( @An_OthpSource_IDNO AS VARCHAR ),'')+ ', NegPos_CODE = ' + ISNULL(@Ac_NegPos_CODE,'')+ ', TypeChange_CODE = ' + ISNULL(@Ac_TypeChange_CODE,'')+ ', TypeReference_CODE = ' + ISNULL(@Ac_TypeReference_CODE,'')+ ', Reference_ID = ' + ISNULL(@Ac_Reference_ID,'')+ ', Process_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

   SELECT @Ln_Value_QNTY = COUNT (Case_IDNO)
     FROM ELFC_Y1 e
    WHERE e.Case_IDNO = @An_Case_IDNO
      AND e.MemberMci_IDNO = @An_MemberMci_IDNO
      AND e.OthpSource_IDNO = @An_OthpSource_IDNO
      AND e.NegPos_CODE = @Ac_NegPos_CODE
      AND e.TypeChange_CODE = @Ac_TypeChange_CODE
      AND e.TypeReference_CODE = @Ac_TypeReference_CODE
      AND e.Reference_ID = @Ac_Reference_ID
      AND e.Process_DATE = @Ld_High_DATE;

   SET @Ln_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

   IF @Ln_Value_QNTY = 0
    BEGIN
     -- IW trigger insertion by extenal source is validated here to match all conditions exists in ELFC daily.
     IF @Ac_TypeChange_CODE = @Lc_TypeChangeIw_CODE
     BEGIN
		SELECT @Ln_Value_QNTY = 1
		  FROM CASE_Y1 a
		  JOIN SORD_Y1 s
			ON s.Case_IDNO = @An_Case_IDNO
		   AND s.Case_IDNO = a.Case_IDNO
		   AND s.Iiwo_CODE IN (@Lc_IiwoC_CODE, @Lc_IiwoI_CODE)
		   AND @Ad_Create_DATE BETWEEN s.OrderEffective_DATE AND s.OrderEnd_DATE
		   AND s.TypeOrder_CODE != @Lc_OrderTypeVoluntary_CODE
		   AND s.EndValidity_DATE = @Ld_High_DATE
          JOIN EHIS_Y1 e
           ON e.MemberMci_IDNO = @An_MemberMci_IDNO
              AND e.OthpPartyEmpl_IDNO = @An_OthpSource_IDNO
              AND e.LimitCcpa_INDC != @Lc_Yes_INDC
              AND (e.Status_CODE = @Lc_StatusY_CODE
					OR	(	e.Status_CODE = @Lc_StatusP_CODE
							AND s.Iiwo_CODE = @Lc_IiwoI_CODE
						)
				   )
              AND @Ad_Create_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
          JOIN OTHP_Y1 o
           ON o.OtherParty_IDNO = e.OthpPartyEmpl_IDNO
          AND o.EndValidity_DATE = @Ld_High_DATE
        WHERE a.Case_IDNO = @An_Case_IDNO 
		  AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
          AND (	(a.TypeCase_CODE = @Lc_CaseTypeNonIvd_CODE AND a.CaseCategory_CODE != @Lc_CaseCategoryDp_CODE) 
				OR a.TypeCase_CODE != @Lc_CaseTypeNonIvd_CODE
			  )
          AND (a.RespondInit_CODE NOT IN(@Lc_RespondInitInitiateIntrnl_TEXT, @Lc_RespondInitInitiate_TEXT, @Lc_RespondInitInitiateTribal_TEXT)
                OR (a.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
					   AND NOT EXISTS(SELECT 1
										FROM ICAS_Y1 x
									   WHERE x.Case_IDNO = a.Case_IDNO
										 AND x.RespondInit_CODE IN (@Lc_RespondInitRespondingState_CODE, @Lc_RespondInitRespondingTribal_CODE, @Lc_RespondInitRespondingInternational_CODE)
										 AND x.Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE,@Lc_ReasonErfss_CODE )
										 AND x.EndValidity_DATE=@Ld_High_DATE)))
         AND ((e.TypeIncome_CODE IN (@Lc_TypeIncomeEm_CODE, @Lc_TypeIncomeCs_CODE, @Lc_TypeIncomeMb_CODE, @Lc_TypeIncomeMl_CODE,
                                      @Lc_TypeIncomeMr_CODE, @Lc_TypeIncomeRt_CODE, @Lc_TypeIncomeSe_CODE, @Lc_TypeIncomeSs_CODE,
                                      @Lc_TypeIncomeUn_CODE, @Lc_TypeIncomeVp_CODE, @Lc_TypeIncomeWc_CODE))
                OR (e.TypeIncome_CODE IN (@Lc_TypeIncomeUi_CODE, @Lc_TypeIncomeDs_CODE)
                    AND o.State_ADDR != @Lc_StateInState_CODE)
                OR (o.TypeOthp_CODE = @Lc_TypeOthpG_CODE
                    AND o.PpaEiwn_INDC = @Lc_Yes_INDC))
          AND NOT EXISTS (SELECT 1
                            FROM DMJR_Y1 b
                           WHERE b.Case_IDNO = a.Case_IDNO
                             AND b.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
                             AND b.Status_CODE = @Lc_RemedyStatusStart_CODE)
          AND NOT EXISTS (SELECT 1
                            FROM ACEN_Y1 n
                           WHERE n.Case_IDNO = a.Case_IDNO
                             AND n.EndValidity_DATE = @Ld_High_DATE
                             AND n.StatusEnforce_CODE = @Lc_StatusEnforceExempt_CODE)
          AND NOT EXISTS (SELECT 1
                            FROM DMJR_Y1 j
                           WHERE j.Case_IDNO = a.Case_IDNO
							 AND j.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
                             AND @Ad_Create_DATE BETWEEN j.BeginExempt_DATE AND j.EndExempt_DATE)
          AND NOT EXISTS (SELECT 1
                            FROM ELFC_Y1 b
                           WHERE b.Case_IDNO = a.Case_IDNO
                             AND b.TypeChange_CODE = @Lc_TypeChangeCc_CODE
                             AND b.Process_DATE = @Ld_High_DATE)
          AND NOT EXISTS (SELECT 1
                            FROM DMJR_Y1 j
                           WHERE j.Case_IDNO = a.Case_IDNO
                             AND j.Reference_ID = @An_MemberMci_IDNO
                             AND j.OthpSource_IDNO = e.OthpPartyEmpl_IDNO
                             AND j.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
                             AND j.Status_CODE = @Lc_RemedyStatusStart_CODE);
								
		IF @Ln_Value_QNTY = 0
		BEGIN
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
			SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
			RETURN;
		END
     END
         
     IF @An_TransactionEventSeq_NUMB = 0
      BEGIN
       /* For the Screen which doesn't have the TransactionEventSeq_NUMB pass 0 so that the BATCH_COMMON$SP_INSERT_ELFC
       Procedure will take care of Generating the TransactionEventSeq_NUMB*/
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT';
       SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', EffectiveEvent_DATE = ' + ISNULL(CAST( @Ad_Create_DATE AS VARCHAR ),'')+ ', Note_INDC = ' + ISNULL(@Lc_NoteN_INDC,'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL('0','');

       EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
        @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ad_EffectiveEvent_DATE      = @Ad_Create_DATE,
        @Ac_Note_INDC                = @Lc_NoteN_INDC,
        @An_EventFunctionalSeq_NUMB  = 0,
        @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'INSERT ELFC_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', OrderSeq_NUMB = ' + ISNULL(CAST( @An_OrderSeq_NUMB AS VARCHAR ),'')+ ', Process_ID = ' + ISNULL(@Ac_Process_ID,'')+ ', TypeChange_CODE = ' + ISNULL(@Ac_TypeChange_CODE,'')+ ', OthpSource_IDNO = ' + ISNULL(CAST( @An_OthpSource_IDNO AS VARCHAR ),'')+ ', NegPos_CODE = ' + ISNULL(@Ac_NegPos_CODE,'')+ ', Create_DATE = ' + ISNULL(CAST( @Ad_Create_DATE AS VARCHAR ),'')+ ', Process_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'');

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
     VALUES (@An_MemberMci_IDNO,--MemberMci_IDNO
             @An_Case_IDNO,--Case_IDNO
             @An_OrderSeq_NUMB,--OrderSeq_NUMB
             @Ac_Process_ID,--Process_ID
             @Ac_TypeChange_CODE,--TypeChange_CODE
             @An_OthpSource_IDNO,--OthpSource_IDNO
             @Ac_NegPos_CODE,--NegPos_CODE
             @Ad_Create_DATE,--Create_DATE
             @Ld_High_DATE,--Process_DATE
             @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
             dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
             @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
             ISNULL(@Ac_TypeReference_CODE, ' '),--TypeReference_CODE
             ISNULL(@Ac_Reference_ID, ' ')); --Reference_ID
     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO ELFC_Y1 FAILED';
       RAISERROR (50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
