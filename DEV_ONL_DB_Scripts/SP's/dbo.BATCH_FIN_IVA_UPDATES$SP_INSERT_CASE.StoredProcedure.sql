/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_CASE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_INSERT_CASE
Programmer Name	:	IMP Team.
Description		:	This process creates new case.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Called On		:	NONE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_CASE]
 @Ac_StatusCase_CODE          CHAR(1),
 @Ac_TypeCase_CODE            CHAR(1),
 @An_County_IDNO              NUMERIC(3),
 @Ad_FileLoad_DATE            DATE,
 @Ac_CaseCategory_CODE        CHAR(2),
 @Ac_ReasonFeeWaived_CODE     CHAR(2),
 @Ad_Run_DATE                 DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @An_Case_IDNO                NUMERIC(6, 0) OUTPUT,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB             SMALLINT = 0,
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_ApplicationFeeW_CODE  CHAR(1) = 'W',
          @Lc_SourceRfrlDss_CODE    CHAR(1) = 'S',
          @Lc_RespondInitN_CODE     CHAR(1) = 'N',
          @Lc_BatchRunUser_TEXT     CHAR(5) = 'BATCH',
          @Lc_AssignedFips_CODE     CHAR(7) = '',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CASE',
          @Ls_Sql_TEXT              VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT          VARCHAR(5000) = ' ',
          @Ld_Low_DATE              DATE = '01/01/0001',
          @Ld_Start_DATE            DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_Error_NUMB     NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB NUMERIC(11) = 0;

  BEGIN TRY
   SET @An_Case_IDNO = @Li_Zero_NUMB;
   --13667 - New cases since Implementation are printing blank DE FIPS addresses -- Start
   SET @Lc_AssignedFips_CODE = CASE
                                WHEN @An_County_IDNO = 1
                                 THEN '1000100'
                                WHEN @An_County_IDNO = 3
                                 THEN '1000300'
                                WHEN @An_County_IDNO = 5
                                 THEN '1000500'
                                WHEN @An_County_IDNO = 99
                                 THEN '1000000'
                               END;
   --13667 - New cases since Implementation are printing blank DE FIPS addresses -- End
   SET @Ls_Sql_TEXT = 'INSERT CASE_Y1';
   SET @Ls_Sqldata_TEXT = 'StatusCase_CODE = ' + ISNULL(@Ac_StatusCase_CODE, '') + ', TypeCase_CODE = ' + ISNULL(@Ac_TypeCase_CODE, '') + ', RsnStatusCase_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', RespondInit_CODE = ' + ISNULL(@Lc_RespondInitN_CODE, '') + ', SourceRfrl_CODE = ' + ISNULL(@Lc_SourceRfrlDss_CODE, '') + ', Opened_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Marriage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Divorced_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', StatusCurrent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', AprvIvd_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', County_IDNO = ' + ISNULL(CAST(@An_County_IDNO AS VARCHAR), '') + ', Office_IDNO = ' + ISNULL(CAST(@An_County_IDNO AS VARCHAR), '') + ', AssignedFips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', GoodCause_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', GoodCause_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Restricted_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', Intercept_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', MedicalOnly_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', Jurisdiction_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', IvdApplicant_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Application_IDNO = ' + ISNULL(CAST(@Li_Zero_NUMB AS VARCHAR), '') + ', AppSent_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', AppReq_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', AppRetd_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CpRelationshipToNcp_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', AppSigned_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ClientLitigantRole_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionComments_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', NonCoop_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', NonCoop_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', Referral_DATE = ' + ISNULL(CAST(@Ad_FileLoad_DATE AS VARCHAR), '') + ', CaseCategory_CODE = ' + ISNULL(@Ac_CaseCategory_CODE, '') + ', File_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', ApplicationFee_CODE = ' + ISNULL(@Lc_ApplicationFeeW_CODE, '') + ', FeePaid_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ServiceRequested_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', StatusEnforce_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FeeCheckNo_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReasonFeeWaived_CODE = ' + ISNULL(@Ac_ReasonFeeWaived_CODE, '');

   INSERT CASE_Y1
          (StatusCase_CODE,
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
   VALUES (@Ac_StatusCase_CODE,--StatusCase_CODE
           @Ac_TypeCase_CODE,--TypeCase_CODE
           @Lc_Space_TEXT,--RsnStatusCase_CODE
           @Lc_RespondInitN_CODE,--RespondInit_CODE
           @Lc_SourceRfrlDss_CODE,--SourceRfrl_CODE
           @Ad_Run_DATE,--Opened_DATE
           @Ld_Low_DATE,--Marriage_DATE
           @Ld_Low_DATE,--Divorced_DATE
           @Ad_Run_DATE,--StatusCurrent_DATE
           @Ld_Low_DATE,--AprvIvd_DATE
           @An_County_IDNO,--County_IDNO
           @An_County_IDNO,--Office_IDNO
           @Lc_AssignedFips_CODE,--AssignedFips_CODE
           @Lc_Space_TEXT,--GoodCause_CODE
           @Ld_Low_DATE,--GoodCause_DATE
           @Lc_Space_TEXT,--Restricted_INDC
           @Lc_Space_TEXT,--MedicalOnly_INDC
           @Lc_Space_TEXT,--Jurisdiction_INDC
           @Lc_Space_TEXT,--IvdApplicant_CODE
           @Li_Zero_NUMB,--Application_IDNO
           @Ld_Low_DATE,--AppSent_DATE
           @Ld_Low_DATE,--AppReq_DATE
           @Ld_Low_DATE,--AppRetd_DATE
           @Lc_Space_TEXT,--CpRelationshipToNcp_CODE
           @Lc_BatchRunUser_TEXT,--Worker_ID
           @Ld_Low_DATE,--AppSigned_DATE
           @Lc_Space_TEXT,--ClientLitigantRole_CODE
           @Lc_Space_TEXT,--DescriptionComments_TEXT
           @Lc_Space_TEXT,--NonCoop_CODE
           @Ld_Low_DATE,--NonCoop_DATE
           @Ad_Run_DATE,--BeginValidity_DATE
           @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
           @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
           @Ld_Start_DATE,--Update_DTTM
           @Ad_FileLoad_DATE,--Referral_DATE
           @Ac_CaseCategory_CODE,--CaseCategory_CODE
           @Lc_Space_TEXT,--File_ID
           @Lc_ApplicationFeeW_CODE,--ApplicationFee_CODE
           @Ld_Low_DATE,--FeePaid_DATE
           @Lc_Space_TEXT,--ServiceRequested_CODE
           @Lc_Space_TEXT,--StatusEnforce_CODE
           @Lc_Space_TEXT,--FeeCheckNo_TEXT
           @Ac_ReasonFeeWaived_CODE,--ReasonFeeWaived_CODE
           @Lc_Space_TEXT --Intercept_CODE
   );

   SET @An_Case_IDNO = @@IDENTITY;

   IF @An_Case_IDNO = @Li_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'CREATE CASE FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
