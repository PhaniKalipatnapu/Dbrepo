/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_UPDATE_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_IVA_UPDATES$SP_UPDATE_ADDRESS
Programmer Name   :	Imp Team
Description       :	This process Updates the Address Information for the member in incoming referral from IVA.
Frequency         :	DAILY
Developed On      :	12/29/2011
Called By         :	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Called On		  :	BATCH_COMMON$SP_ADDRESS_UPDATE,
					BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
-------------------------------------------------------------------------------------------------------------------						
Modified By       :
Modified On       :
Version No        :	0.01
--------------------------------------------------------------------------------------------------------------------
*/
-- TO DO :: Please uncomment the sections with the tag 
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_UPDATE_ADDRESS] (
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ad_Run_DATE                 DATE,
 @Ac_Job_ID                   CHAR(7),
 @Ac_AddrNormalization_CODE   CHAR(1),
 @As_Line1_ADDR               VARCHAR(50),
 @As_Line2_ADDR               VARCHAR(50),
 @Ac_City_ADDR                CHAR(28),
 @Ac_State_ADDR               CHAR(2),
 @Ac_Zip_ADDR                 CHAR(15),
 @Ac_SourceVerified_CODE      CHAR(3),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_Msg_CODE                 CHAR(1) = ' ',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_MailingTypeAddress_CODE  CHAR(1) = 'M',
          @Lc_VerificationStatusP_CODE CHAR(1) = 'P',
          @Lc_MemberSourceLoc_CODE     CHAR(3) = 'IVA',
          @Lc_BatchRunUser_TEXT        CHAR(5) = 'BATCH',
          @Ls_Procedure_NAME           VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_UPDATE_ADDRESS',
          @Ls_Sql_TEXT                 VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT    VARCHAR(4000) = ' ',
          @Ls_ErrorMessage_TEXT        VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT             VARCHAR(5000) = ' ',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_ErrorLine_NUMB NUMERIC(11) = 0,
          @Ln_Error_NUMB     NUMERIC(11) = 0;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ADDRESS_UPDATE';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
    @An_MemberMci_IDNO                   = @An_MemberMci_IDNO,
    @Ad_Run_DATE                         = @Ad_Run_DATE,
    @Ac_TypeAddress_CODE                 = @Lc_MailingTypeAddress_CODE,
    @Ad_Begin_DATE                       = @Ad_Run_DATE,
    @Ad_End_DATE                         = @Ld_High_DATE,
    @As_Line1_ADDR                       = @As_Line1_ADDR,
    @As_Line2_ADDR                       = @As_Line2_ADDR,
    @Ac_City_ADDR                        = @Ac_City_ADDR,
    @Ac_State_ADDR                       = @Ac_State_ADDR,
    @Ac_Zip_ADDR                         = @Ac_Zip_ADDR,
    @Ac_SourceLoc_CODE                   = @Lc_MemberSourceLoc_CODE,
    @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
    @Ad_Status_DATE                      = @Ad_Run_DATE,
    @Ac_Status_CODE                      = @Lc_VerificationStatusP_CODE,
    @Ac_SourceVerified_CODE              = @Ac_SourceVerified_CODE,
    @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
    @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
    @Ac_Process_ID                       = @Ac_Job_ID,
    @Ac_SignedOnWorker_ID                = @Lc_BatchRunUser_TEXT,
    @An_TransactionEventSeq_NUMB         = @An_TransactionEventSeq_NUMB,
    @Ac_Normalization_CODE               = @Ac_AddrNormalization_CODE,
    @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
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

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
