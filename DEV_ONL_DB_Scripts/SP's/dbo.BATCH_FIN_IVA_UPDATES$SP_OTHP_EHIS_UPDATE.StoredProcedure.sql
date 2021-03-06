/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE
Programmer Name	:	IMP Team.
Description		:	This process Updates the Other party and Employment information for the member in incoming referral from IVA.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Called On		:	BATCH_COMMON$SP_GET_OTHP,
					BATCH_COMMON$SP_EMPLOYER_UPDATE,
					BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE] (
 @An_MemberMci_IDNO         NUMERIC(10),
 @Ad_Run_DATE               DATE,
 @Ac_Job_ID                 CHAR(7),
 @As_OtherParty_NAME        VARCHAR(60),
 @An_Fein_IDNO              NUMERIC(9),
 @Ac_AddrNormalization_CODE CHAR(1),
 @As_Line1_ADDR             VARCHAR(50),
 @As_Line2_ADDR             VARCHAR(50),
 @Ac_City_ADDR              CHAR(28),
 @Ac_State_ADDR             CHAR(2),
 @Ac_Zip_ADDR               CHAR(15),
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_TypeErrorE_CODE          CHAR(1) = 'E',
          @Lc_TypeOthpEmployer_CODE    CHAR(1) = 'E',
          @Lc_VerificationStatusP_CODE CHAR(1) = 'P',
          @Lc_Country_ADDR             CHAR(2) = 'US',
          @Lc_TypeIncomeEm_CODE        CHAR(2) = 'EM',
          @Lc_MemberSourceLoc_CODE     CHAR(3) = 'IVA',
          @Lc_Msg_CODE                 CHAR(5) = ' ',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Ls_Procedure_NAME           VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_OTHP_EHIS_UPDATE',
          @Ls_Sql_TEXT                 VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT    VARCHAR(4000) = ' ',
          @Ls_ErrorMessage_TEXT        VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT             VARCHAR(5000) = ' ',
          @Ld_Low_DATE                 DATE = '01/01/0001',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB          NUMERIC(5) = 0,
          @Ln_OthpPartyEmpl_IDNO NUMERIC(9, 0),
          @Ln_ErrorLine_NUMB     NUMERIC(11) = 0,
          @Ln_Error_NUMB         NUMERIC(11) = 0;

  BEGIN TRY
   -- OTHP ID Insert, Employer address insertion
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_OTHP';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@An_Fein_IDNO AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthpEmployer_CODE, '') + ', OtherParty_NAME = ' + ISNULL(@As_OtherParty_NAME, '') + ', Aka_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', Attn_ADDR = ' + ISNULL(@Lc_Space_TEXT, '') + ', Line1_ADDR = ' + ISNULL(@As_Line1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@As_Line2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Ac_City_ADDR, '') + ', State_ADDR = ' + ISNULL(@Ac_State_ADDR, '') + ', Zip_ADDR = ' + ISNULL(@Ac_Zip_ADDR, '') + ', Fips_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', DescriptionContactOther_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Contact_EML = ' + ISNULL(@Lc_Space_TEXT, '') + ', ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', BarAtty_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', Sein_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_MemberSourceLoc_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Normalization_CODE = ' + ISNULL(@Ac_AddrNormalization_CODE, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '');

   EXECUTE BATCH_COMMON$SP_GET_OTHP
    @Ad_Run_DATE                     = @Ad_Run_DATE,
    @An_Fein_IDNO                    = @An_Fein_IDNO,
    @Ac_TypeOthp_CODE                = @Lc_TypeOthpEmployer_CODE,
    @As_OtherParty_NAME              = @As_OtherParty_NAME,
    @Ac_Aka_NAME                     = @Lc_Space_TEXT,
    @Ac_Attn_ADDR                    = @Lc_Space_TEXT,
    @As_Line1_ADDR                   = @As_Line1_ADDR,
    @As_Line2_ADDR                   = @As_Line2_ADDR,
    @Ac_City_ADDR                    = @Ac_City_ADDR,
    @Ac_State_ADDR                   = @Ac_State_ADDR,
    @Ac_Zip_ADDR                     = @Ac_Zip_ADDR,
    @Ac_Fips_CODE                    = @Lc_Space_TEXT,
    @Ac_Country_ADDR                 = @Lc_Country_ADDR,
    @Ac_DescriptionContactOther_TEXT = @Lc_Space_TEXT,
    @As_Contact_EML                  = @Lc_Space_TEXT,
    @An_ReferenceOthp_IDNO           = @Ln_Zero_NUMB,
    @An_BarAtty_NUMB                 = @Ln_Zero_NUMB,
    @An_Sein_IDNO                    = @Ln_Zero_NUMB,
    @Ac_SourceLoc_CODE               = @Lc_MemberSourceLoc_CODE,
    @Ac_WorkerUpdate_ID              = @Lc_BatchRunUser_TEXT,
    @Ac_Normalization_CODE           = @Ac_AddrNormalization_CODE,
    @Ac_Process_ID                   = @Ac_Job_ID,
    @An_OtherParty_IDNO              = @Ln_OthpPartyEmpl_IDNO OUTPUT,
    @Ac_Msg_CODE                     = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT        = @Ls_DescriptionError_TEXT OUTPUT;

   IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
        OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
            AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
    BEGIN
     RAISERROR(50001,16,1);
    END
   ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = 'BATCH_FIN_IVA_UPDATES',
      @As_Procedure_NAME           = 'SP_OTHP_EHIS_UPDATE',
      @Ac_Job_ID                   = @Ac_Job_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_TypeErrorE_CODE,
      @An_Line_NUMB                = 0,
      @Ac_Error_CODE               = @Lc_Msg_CODE,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
    END
   ELSE IF @Lc_Msg_CODE = @Lc_StatusSuccess_CODE
      AND @Ln_OthpPartyEmpl_IDNO > 0
    BEGIN
     -- Employer details Insertion.
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EMPLOYER_UPDATE';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', OthpPartyEmpl_IDNO = ' + ISNULL(CAST(@Ln_OthpPartyEmpl_IDNO AS VARCHAR), '') + ', SourceReceived_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_VerificationStatusP_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_TypeIncomeEm_CODE, '') + ', SourceLocConf_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndEmployment_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IncomeGross_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', IncomeNet_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqIncome_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FreqPay_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', LimitCcpa_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EmployerPrime_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsReasonable_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', SourceLoc_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', InsProvider_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCovered_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', DpCoverageAvlb_INDC = ' + ISNULL(@Lc_Space_TEXT, '') + ', EligCoverage_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', CostInsurance_AMNT = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', FreqInsurance_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DescriptionOccupation_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', PlsLastSearch_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '');

     EXECUTE BATCH_COMMON$SP_EMPLOYER_UPDATE
      @An_MemberMci_IDNO             = @An_MemberMci_IDNO,
      @An_OthpPartyEmpl_IDNO         = @Ln_OthpPartyEmpl_IDNO,
      @Ad_SourceReceived_DATE        = @Ad_Run_DATE,
      @Ac_Status_CODE                = @Lc_VerificationStatusP_CODE,
      @Ad_Status_DATE                = @Ad_Run_DATE,
      @Ac_TypeIncome_CODE            = @Lc_TypeIncomeEm_CODE,
      @Ac_SourceLocConf_CODE         = @Lc_Space_TEXT,
      @Ad_Run_DATE                   = @Ad_Run_DATE,
      @Ad_BeginEmployment_DATE       = @Ad_Run_DATE,
      @Ad_EndEmployment_DATE         = @Ld_High_DATE,
      @An_IncomeGross_AMNT           = @Ln_Zero_NUMB,
      @An_IncomeNet_AMNT             = @Ln_Zero_NUMB,
      @Ac_FreqIncome_CODE            = @Lc_Space_TEXT,
      @Ac_FreqPay_CODE               = @Lc_Space_TEXT,
      @Ac_LimitCcpa_INDC             = @Lc_Space_TEXT,
      @Ac_EmployerPrime_INDC         = @Lc_Space_TEXT,
      @Ac_InsReasonable_INDC         = @Lc_Space_TEXT,
      @Ac_SourceLoc_CODE             = @Lc_MemberSourceLoc_CODE,
      @Ac_InsProvider_INDC           = @Lc_Space_TEXT,
      @Ac_DpCovered_INDC             = @Lc_Space_TEXT,
      @Ac_DpCoverageAvlb_INDC        = @Lc_Space_TEXT,
      @Ad_EligCoverage_DATE          = @Ad_Run_DATE,
      @An_CostInsurance_AMNT         = @Ln_Zero_NUMB,
      @Ac_FreqInsurance_CODE         = @Lc_Space_TEXT,
      @Ac_DescriptionOccupation_TEXT = @Lc_Space_TEXT,
      @Ac_SignedOnWorker_ID          = @Lc_BatchRunUser_TEXT,
      @An_TransactionEventSeq_NUMB   = @Ln_Zero_NUMB,
      @Ad_PlsLastSearch_DATE         = @Ld_Low_DATE,
      @Ac_Process_ID                 = @Ac_Job_ID,
      @Ac_Msg_CODE                   = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT      = @Ls_DescriptionError_TEXT OUTPUT;

     IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE
          OR (@Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
              AND dbo.BATCH_COMMON$SF_GET_BATE_ERROR_TYPE(@Lc_Msg_CODE) = @Lc_TypeErrorE_CODE))
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_Msg_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = ISNULL(@Lc_Msg_CODE, @Lc_StatusFailed_CODE);
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
