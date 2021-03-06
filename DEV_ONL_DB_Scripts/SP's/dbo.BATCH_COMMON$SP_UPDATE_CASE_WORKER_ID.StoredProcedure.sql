/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID
Programmer Name		: IMP Team
Description			: This procedure is used to assign a worker for an alert
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID]
 @An_Case_IDNO                NUMERIC(6),
 @Ac_Assigned_Worker_ID       CHAR(30) = ' ',
 @An_Office_IDNO              NUMERIC(3),
 @An_TransactionEventSeq_NUMB NUMERIC(10),
 @Ad_Run_DATE                 DATE,
 @Ac_SignedonWorker_ID        CHAR(30),
 @As_DescriptionNote_TEXT     VARCHAR(4000) = ' ',
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE			CHAR(1) = 'F',
		  @Lc_StatusSuccess_CODE		CHAR(1) = 'S',
		  @Lc_StatusOpen_CODE			CHAR(1) = 'O',
		  @Lc_Yes_INDC					CHAR(1) = 'Y',
		  @Lc_ErrorE0001_CODE			CHAR(5) = 'E0001',
		  @Lc_AssignedFipsKent_CODE		CHAR(7) = '1000100',	
		  @Lc_AssignedFipsNewC_CODE		CHAR(7) = '1000300',
		  @Lc_AssignedFipsSussex_CODE	CHAR(7) = '1000500',
		  @Lc_AssignedFipsCentral_CODE	CHAR(7) = '1000000',
		  @Ls_Routine_TEXT				VARCHAR(60) = 'BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID',
		  @Ld_High_DATE					DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB               NUMERIC,
		  @Ln_Office_IDNO              NUMERIC(3),
		  @Ln_Icas_Count_NUMB          NUMERIC(5),
		  @Ln_RowCount_QNTY            NUMERIC(5),
		  @Ln_TransactionEventSeq_NUMB NUMERIC(10),
		  @Ln_ErrorLine_NUMB           NUMERIC(11),
		  @Lc_AssignedFips_CODE		   CHAR(7),
		  @Lc_CaseWorker_ID            CHAR(30),
		  @Ls_Sql_TEXT                 VARCHAR(100),
		  @Ls_Sqldata_TEXT             VARCHAR(1000),
		  @Ls_ErrorMessage_TEXT        VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT FROM CASE_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Worker_ID = ' + @Ac_Assigned_Worker_ID;

   SELECT @Ln_TransactionEventSeq_NUMB = C.TransactionEventSeq_NUMB,
		  @Ln_Office_IDNO = C.Office_IDNO,
		  @Lc_CaseWorker_ID = C.Worker_ID
	 FROM CASE_Y1 C
	WHERE C.Case_IDNO = @An_Case_IDNO;

   IF @Lc_CaseWorker_ID != @Ac_Assigned_Worker_ID
	   OR @Ln_Office_IDNO != @An_Office_IDNO
	BEGIN
	 --13667 - New cases since Implementation are printing blank DE FIPS addresses -- Start
	 SET @Lc_AssignedFips_CODE = CASE 
									WHEN @An_Office_IDNO = 1 THEN @Lc_AssignedFipsKent_CODE
									WHEN @An_Office_IDNO = 3 THEN @Lc_AssignedFipsNewC_CODE
									WHEN @An_Office_IDNO = 5 THEN @Lc_AssignedFipsSussex_CODE
									WHEN @An_Office_IDNO = 99 THEN @Lc_AssignedFipsCentral_CODE
								   END;
	 --13667 - New cases since Implementation are printing blank DE FIPS addresses -- End

	 
	 IF @Ln_TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB
		AND @Ln_TransactionEventSeq_NUMB IS NOT NULL
	  BEGIN
	   SET @Ls_Sql_TEXT = 'INSERT INTO HCASE_Y1';
	   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', EndValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'') +', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR);

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
	   SELECT C.Case_IDNO,
			  C.StatusCase_CODE,
			  C.TypeCase_CODE,
			  C.RsnStatusCase_CODE,
			  C.RespondInit_CODE,
			  C.SourceRfrl_CODE,
			  C.Opened_DATE,
			  C.Marriage_DATE,
			  C.Divorced_DATE,
			  C.StatusCurrent_DATE,
			  C.AprvIvd_DATE,
			  C.County_IDNO,
			  C.Office_IDNO,
			  C.AssignedFips_CODE,
			  C.GoodCause_CODE,
			  C.GoodCause_DATE,
			  C.Restricted_INDC,
			  C.MedicalOnly_INDC,
			  C.Jurisdiction_INDC,
			  C.IvdApplicant_CODE,
			  C.Application_IDNO,
			  C.AppSent_DATE,
			  C.AppReq_DATE,
			  C.AppRetd_DATE,
			  C.CpRelationshipToNcp_CODE,
			  C.Worker_ID,
			  C.AppSigned_DATE,
			  C.ClientLitigantRole_CODE,
			  C.DescriptionComments_TEXT,
			  C.NonCoop_CODE,
			  C.NonCoop_DATE,
			  C.BeginValidity_DATE,
			  @Ad_Run_DATE AS EndValidity_DATE,
			  C.WorkerUpdate_ID,
			  C.TransactionEventSeq_NUMB,
			  C.Update_DTTM,
			  C.Referral_DATE,
			  C.CaseCategory_CODE,
			  C.File_ID,
			  C.ApplicationFee_CODE,
			  C.FeePaid_DATE,
			  C.ServiceRequested_CODE,
			  C.StatusEnforce_CODE,
			  C.FeeCheckNo_TEXT,
			  C.ReasonFeeWaived_CODE,
			  C.Intercept_CODE
		 FROM CASE_Y1 C
		WHERE C.Case_IDNO = @An_Case_IDNO
		  AND C.TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB;

	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

	   IF @Ln_RowCount_QNTY = 0
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_ErrorE0001_CODE;
		 SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID' + ' PROCEDURE ' + '. Error DESC - ' + 'Insert InTo HCASE_Y1 Not Successful' + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + ' . Error List KEY - ' + @Ls_Sqldata_TEXT;

		 RETURN;
		END

	   SET @Ls_Sql_TEXT = 'UPDATE Worker INTO CASE_Y1';
	   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @Ln_TransactionEventSeq_NUMB AS VARCHAR ),'');
	  
	   UPDATE CASE_Y1
		  SET Worker_ID = @Ac_Assigned_Worker_ID,
			  Office_IDNO = @An_Office_IDNO,
			  County_IDNO = @An_Office_IDNO,
			  AssignedFips_CODE = @Lc_AssignedFips_CODE,
			  TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
			  WorkerUpdate_ID = @Ac_SignedonWorker_ID,
			  BeginValidity_DATE = @Ad_Run_DATE,
			  Update_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
		WHERE Case_IDNO = @An_Case_IDNO
		  AND TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB;

	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

	   IF @Ln_RowCount_QNTY = 0
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_ErrorE0001_CODE;
		 SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID' + ' PROCEDURE ' + '. Error DESC - ' + 'Update InTo CASE_Y1 Not Successful' + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + ' . Error List KEY - ' + @Ls_Sqldata_TEXT;

		 RETURN;
		END
	  END
	 ELSE
	  BEGIN
	   SET @Ls_Sql_TEXT = 'UPDATE Worker INTO CASE_Y1';
	   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', TransactionEventSeq_NUMB = ' + CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR);

	   UPDATE CASE_Y1
		  SET Worker_ID = @Ac_Assigned_Worker_ID,
			  Office_IDNO = @An_Office_IDNO,
			  County_IDNO = @An_Office_IDNO,
			  AssignedFips_CODE = @Lc_AssignedFips_CODE
		WHERE Case_IDNO = @An_Case_IDNO
		  AND TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB;

	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

	   IF @Ln_RowCount_QNTY = 0
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_ErrorE0001_CODE;
		 SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID' + ' PROCEDURE ' + '. Error DESC - ' + 'Update InTo CASE_Y1 Not Successful' + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + ' . Error List KEY - ' + @Ls_Sqldata_TEXT;
		 RETURN;
		END
	  END
	END

   SET @Ls_Sql_TEXT = 'ASSINGING ICAS COUNT';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusOpen_CODE,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
   
   SELECT @Ln_Icas_Count_NUMB = COUNT(1)
	 FROM ICAS_Y1 I
	WHERE I.Case_IDNO = @An_Case_IDNO
	  AND I.Status_CODE = @Lc_StatusOpen_CODE
	  AND I.EndValidity_DATE = @Ld_High_DATE
	  AND (County_IDNO != @An_Office_IDNO
			OR Worker_ID != @Ac_Assigned_Worker_ID);

   IF @Ln_Icas_Count_NUMB > 0
	BEGIN
	 -- Updating ICAS_Y1 to represent the changes in worker and county
	 SET @Ls_Sql_TEXT = 'INSERT INTO ICAS_Y1';
	 SET @Ls_Sqldata_TEXT = 'County_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Worker_ID = ' + ISNULL(@Ac_Assigned_Worker_ID,'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedonWorker_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'');

	 INSERT INTO ICAS_Y1
				 (Case_IDNO,
				  IVDOutOfStateCase_ID,
				  IVDOutOfStateFips_CODE,
				  IVDOutOfStateOfficeFips_CODE,
				  IVDOutOfStateCountyFips_CODE,
				  Status_CODE,
				  Effective_DATE,
				  End_DATE,
				  RespondInit_CODE,
				  ControlByCrtOrder_INDC,
				  ContOrder_DATE,
				  ContOrder_ID,
				  IVDOutOfStateFile_ID,
				  Petitioner_NAME,
				  ContactFirst_NAME,
				  Respondent_NAME,
				  ContactLast_NAME,
				  ContactMiddle_NAME,
				  PhoneContact_NUMB,
				  Referral_DATE,
				  Contact_EML,
				  FaxContact_NUMB,
				  File_ID,
				  County_IDNO,
				  IVDOutOfStateTypeCase_CODE,
				  Create_DATE,
				  Worker_ID,
				  Update_DTTM,
				  WorkerUpdate_ID,
				  TransactionEventSeq_NUMB,
				  EndValidity_DATE,
				  BeginValidity_DATE,
				  Reason_CODE,
				  RespondentMci_IDNO,
				  PetitionerMci_IDNO,
				  DescriptionComments_TEXT)
	 SELECT IC.Case_IDNO,
			IC.IVDOutOfStateCase_ID,
			IC.IVDOutOfStateFips_CODE,
			IC.IVDOutOfStateOfficeFips_CODE,
			IC.IVDOutOfStateCountyFips_CODE,
			IC.Status_CODE,
			IC.Effective_DATE,
			IC.End_DATE,
			IC.RespondInit_CODE,
			IC.ControlByCrtOrder_INDC,
			IC.ContOrder_DATE,
			IC.ContOrder_ID,
			IC.IVDOutOfStateFile_ID,
			IC.Petitioner_NAME,
			IC.ContactFirst_NAME,
			IC.Respondent_NAME,
			IC.ContactLast_NAME,
			IC.ContactMiddle_NAME,
			IC.PhoneContact_NUMB,
			IC.Referral_DATE,
			IC.Contact_EML,
			IC.FaxContact_NUMB,
			IC.File_ID,
			@An_Office_IDNO AS County_IDNO,
			IC.IVDOutOfStateTypeCase_CODE,
			IC.Create_DATE,
			@Ac_Assigned_Worker_ID AS Worker_ID,
			dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS Update_DTTM,
			@Ac_SignedonWorker_ID AS WorkerUpdate_ID,
			@An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
			IC.EndValidity_DATE,
			@Ad_Run_DATE AS BeginValidity_DATE,
			IC.Reason_CODE,
			IC.RespondentMci_IDNO,
			IC.PetitionerMci_IDNO,
			IC.DescriptionComments_TEXT
	   FROM ICAS_Y1 IC
	  WHERE IC.Case_IDNO = @An_Case_IDNO
		AND IC.EndValidity_DATE = @Ld_High_DATE
		AND IC.Status_CODE = @Lc_StatusOpen_CODE
		AND (IC.County_IDNO != @An_Office_IDNO
			  OR IC.Worker_ID != @Ac_Assigned_Worker_ID)
		AND IC.TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB;

	 SET @Ln_RowCount_QNTY = @@ROWCOUNT;

	 IF @Ln_RowCount_QNTY != 0
	  BEGIN
	   SET @Ls_Sql_TEXT = 'EndValidate ICAS_Y1';
	   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusOpen_CODE,'');

	   UPDATE ICAS_Y1
		  SET EndValidity_DATE = @Ad_Run_DATE
		WHERE Case_IDNO = @An_Case_IDNO
		  AND EndValidity_DATE = @Ld_High_DATE
		  AND Status_CODE = @Lc_StatusOpen_CODE
		  AND (County_IDNO != @An_Office_IDNO
				OR Worker_ID != @Ac_Assigned_Worker_ID)
		  AND TransactionEventSeq_NUMB != @An_TransactionEventSeq_NUMB;

	   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

	   IF @Ln_RowCount_QNTY = 0
		BEGIN
		 SET @Ac_Msg_CODE = @Lc_ErrorE0001_CODE;
		 SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID' + ' PROCEDURE ' + '. Error DESC - ' + 'EndValidate ICAS_Y1 Not Successful' + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + ' . Error List KEY - ' + @Ls_Sqldata_TEXT;

		 RETURN;
		END
	  END

	 SET @Ls_Sql_TEXT = 'EndValidate ICAS_Y1';
	 SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', Status_CODE = ' + ISNULL(@Lc_StatusOpen_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'');

	 UPDATE ICAS_Y1
		SET Worker_ID = @Ac_Assigned_Worker_ID,
			County_IDNO = @An_Office_IDNO
	  WHERE Case_IDNO = @An_Case_IDNO
		AND EndValidity_DATE = @Ld_High_DATE
		AND Status_CODE = @Lc_StatusOpen_CODE
		AND (County_IDNO != @An_Office_IDNO
			  OR Worker_ID != @Ac_Assigned_Worker_ID)
		AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

	END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT= '';
  END TRY

  BEGIN CATCH
	SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	SET @Ln_Error_NUMB = ERROR_NUMBER();
	SET @Ln_ErrorLine_NUMB = ERROR_LINE();
	SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);

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
