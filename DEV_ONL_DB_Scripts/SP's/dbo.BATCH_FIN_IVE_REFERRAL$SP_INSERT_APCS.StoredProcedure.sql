/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCS
Programmer Name		 : IMP Team
Description			 : The procedure inserts application case data into the application case table
Frequency			 : Daily
Developed On		 : 11/02/2011
Called By			 : 
Called On			 : BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCS]
 @An_Application_IDNO                      NUMERIC(15),
 @Ad_Application_DATE                      DATE,
 @Ad_BeginValidity_DATE                    DATE,
 @Ad_EndValidity_DATE                      DATE,
 @Ad_Update_DTTM                           DATETIME2,
 @Ac_WorkerUpdate_ID                       CHAR(30),
 @An_TransactionEventSeq_NUMB              NUMERIC(19),
 @Ac_TypeCase_CODE                         CHAR(1),
 @Ad_Opened_DATE                           DATE,
 @Ac_StatusCase_CODE                       CHAR(1),
 @Ad_StatusCurrent_DATE                    DATE,
 @Ac_RsnStatusCase_CODE                    CHAR(2),
 @An_County_IDNO                           NUMERIC(3),
 @Ac_SourceRfrl_CODE                       CHAR(3),
 @Ac_Restricted_INDC                       CHAR(1),
 @Ac_MedicalOnly_INDC                      CHAR(1),
 @Ac_GoodCause_CODE                        CHAR(1),
 @Ad_GoodCause_DATE                        DATE,
 @Ac_NonCoop_CODE                          CHAR(1),
 @Ad_NonCoop_DATE                          DATE,
 @Ac_IvdApplicant_CODE                     CHAR(3),
 @Ad_AppReq_DATE                           DATE,
 @Ad_AppSent_DATE                          DATE,
 @Ad_AppRetd_DATE                          DATE,
 @Ad_AppSigned_DATE                        DATE,
 @Ac_RsnFeeWaived_CODE                     CHAR(2),
 @As_DescriptionComments_TEXT              VARCHAR(200),
 @Ac_ApplicationStatus_CODE                CHAR(1),
 @Ac_RespondInit_CODE                      CHAR(1),
 @Ad_Referral_DATE                         DATE,
 @Ac_CaseCategory_CODE                     CHAR(2),
 @Ac_ApplicationFee_CODE                   CHAR(1),
 @Ad_FeePaid_DATE                          DATE,
 @Ac_ServiceRequested_CODE                 CHAR(1),
 @Ac_File_ID                               CHAR(10),
 @An_CaseWelfare_IDNO                      NUMERIC(10),
 @Ac_TypeWelfare_CODE                      CHAR(1),
 @Ac_AttorneyState_CODE                    CHAR(2),
 @Ac_AttorneyCounty_NAME                   CHAR(40),
 @Ac_FeeCheckNo_TEXT                       CHAR(20),
 @Ac_StatusEnforce_CODE                    CHAR(4),
 @Ac_ServiceState_CODE                     CHAR(2),
 @Ac_ServiceCounty_NAME                    CHAR(40),
 @Ac_Service_CODE                          CHAR(1),
 @Ac_ChildSupportOrMedicalAssistance_INDC  CHAR(1),
 @Ac_AttorneyCourt_TEXT                    CHAR(40),
 @Ac_MedicalInsuranceCardStatus_CODE       CHAR(1),
 @Ac_PayStubW2FormStatus_CODE              CHAR(1),
 @Ac_PreventAddressReleaseStatus_CODE      CHAR(1),
 @Ac_MemberSocialSecurityCardStatus_CODE   CHAR(1),
 @Ac_MarriedDivorceDecreeStatus_CODE       CHAR(1),
 @Ac_PaymentArrearsStatementStatus_CODE    CHAR(1),
 @Ac_ModifiedSupportOrderDecreeStatus_CODE CHAR(1),
 @Ac_ChildBirthCertificateStatus_CODE      CHAR(1),
 @Ac_InformationReleaseRisk_INDC           CHAR(1),
 @Ac_AddressPfaProtection_INDC             CHAR(1),
 @Ac_PaternityAcknowledgmentStatus_CODE    CHAR(1),
 @Ac_Msg_CODE                              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT                 VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusFailed_CODE		CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE		CHAR(1) = 'S',
           @Ls_Procedure_NAME			VARCHAR(60) = 'SP_PROCESS_INSERT_APCS',
           @Ld_Low_DATE					DATE = '01/01/0001';
  DECLARE  @Ln_Zero_NUMB				NUMERIC(1) = 0,
           @Ln_Error_NUMB				NUMERIC(11),
           @Ln_ErrorLine_NUMB			NUMERIC(11),
           @Li_RowCount_QNTY			SMALLINT,
           @Lc_Space_TEXT				CHAR(1) = ' ',
           @Lc_Exception_CODE			CHAR(1) = '',
           @Ls_Sql_TEXT					VARCHAR(100),
           @Ls_Sqldata_TEXT				VARCHAR(1000),
           @Ls_DescriptionError_TEXT	VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT		VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = ' ';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_Exception_CODE = '';
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'INSERT INTO APCS_Y1 TABLE ';
   SET @Ls_Sqldata_TEXT = 'APPLICATION IDNO = ' + CAST(@An_Application_IDNO AS VARCHAR(19)) + ', APPLICATION DATE = ' + CAST(@Ad_Application_DATE AS VARCHAR(10));

   INSERT INTO APCS_Y1
               (Application_IDNO,
                Application_DATE,
                BeginValidity_DATE,
                EndValidity_DATE,
                Update_DTTM,
                WorkerUpdate_ID,
                TransactionEventSeq_NUMB,
                TypeCase_CODE,
                Opened_DATE,
                StatusCase_CODE,
                StatusCurrent_DATE,
                RsnStatusCase_CODE,
                County_IDNO,
                SourceRfrl_CODE,
                Restricted_INDC,
                MedicalOnly_INDC,
                GoodCause_CODE,
                GoodCause_DATE,
                NonCoop_CODE,
                NonCoop_DATE,
                IvdApplicant_CODE,
                AppReq_DATE,
                AppSent_DATE,
                AppRetd_DATE,
                AppSigned_DATE,
                RsnFeeWaived_CODE,
                DescriptionComments_TEXT,
                ApplicationStatus_CODE,
                RespondInit_CODE,
                Referral_DATE,
                CaseCategory_CODE,
                ApplicationFee_CODE,
                FeePaid_DATE,
                ServiceRequested_CODE,
                [File_ID],
                CaseWelfare_IDNO,
                TypeWelfare_CODE,
                AttorneyState_CODE,
                AttorneyCounty_NAME,
                FeeCheckNo_TEXT,
                StatusEnforce_CODE,
                ServiceState_CODE,
                ServiceCounty_NAME,
                Service_CODE,
                ChildSupportOrMedicalAssistance_INDC,
                AttorneyCourt_TEXT,
                MedicalInsuranceCardStatus_CODE,
                PayStubW2FormStatus_CODE,
                PreventAddressReleaseStatus_CODE,
                MemberSocialSecurityCardStatus_CODE,
                MarriedDivorceDecreeStatus_CODE,
                PaymentArrearsStatementStatus_CODE,
                ModifiedSupportOrderDecreeStatus_CODE,
                ChildBirthCertificateStatus_CODE,
                InformationReleaseRisk_INDC,
                AddressPfaProtection_INDC,
                PaternityAcknowledgmentStatus_CODE,
                TransHeader_IDNO,
                StateFips_CODE,
                Transaction_DATE)
        VALUES ( @An_Application_IDNO, -- Application_IDNO
                 @Ad_Application_DATE, --Application_DATE
                 @Ad_BeginValidity_DATE, --BeginValidity_DATE
                 @Ad_EndValidity_DATE, --EndValidity_DATE
                 @Ad_Update_DTTM, --Update_DTTM
                 ISNULL(@Ac_WorkerUpdate_ID, @Lc_Space_TEXT),--WorkerUpdate_ID
                 @An_TransactionEventSeq_NUMB, -- TransactionEventSeq_NUMB
                 ISNULL(@Ac_TypeCase_CODE, @Lc_Space_TEXT), -- TypeCase_CODE
                 @Ad_Opened_DATE, -- Opened_DATE
                 ISNULL(@Ac_StatusCase_CODE, @Lc_Space_TEXT), -- StatusCase_CODE
                 @Ad_StatusCurrent_DATE, --StatusCurrent_DATE
                 ISNULL(@Ac_RsnStatusCase_CODE, @Lc_Space_TEXT), -- RsnStatusCase_CODE
                 @An_County_IDNO, --County_IDNO
                 ISNULL(@Ac_SourceRfrl_CODE, @Lc_Space_TEXT), -- SourceRfrl_CODE
                 ISNULL(@Ac_Restricted_INDC, @Lc_Space_TEXT), -- Restricted_INDC
                 ISNULL(@Ac_MedicalOnly_INDC, @Lc_Space_TEXT), -- MedicalOnly_INDC
                 ISNULL(@Ac_GoodCause_CODE, @Lc_Space_TEXT), -- GoodCause_CODE
                 @Ad_GoodCause_DATE, -- GoodCause_DATE
                 ISNULL(@Ac_NonCoop_CODE, @Lc_Space_TEXT), -- NonCoop_CODE
                 @Ad_NonCoop_DATE, -- NonCoop_DATE
                 ISNULL(@Ac_IvdApplicant_CODE, @Lc_Space_TEXT), -- IvdApplicant_CODE
                 @Ad_AppReq_DATE, -- AppReq_DATE
                 @Ad_AppSent_DATE, -- AppSent_DATE
                 @Ad_AppRetd_DATE, -- AppRetd_DATE
                 @Ad_AppSigned_DATE, -- AppSigned_DATE
                 ISNULL(@Ac_RsnFeeWaived_CODE, @Lc_Space_TEXT), --RsnFeeWaived_CODE
                 ISNULL(@As_DescriptionComments_TEXT, @Lc_Space_TEXT), -- DescriptionComments_TEXT
                 ISNULL(@Ac_ApplicationStatus_CODE, @Lc_Space_TEXT), -- ApplicationStatus_CODE
                 ISNULL(@Ac_RespondInit_CODE, @Lc_Space_TEXT), -- RespondInit_CODE
                 @Ad_Referral_DATE, -- Referral_DATE
                 ISNULL(@Ac_CaseCategory_CODE, @Lc_Space_TEXT), -- CaseCategory_CODE
                 ISNULL(@Ac_ApplicationFee_CODE, @Lc_Space_TEXT), --ApplicationFee_CODE 
                 @Ad_FeePaid_DATE, -- FeePaid_DATE
                 ISNULL(@Ac_ServiceRequested_CODE, @Lc_Space_TEXT), -- ServiceRequested_CODE
                 ISNULL(@Ac_File_ID, @Lc_Space_TEXT), --File_ID
                 @An_CaseWelfare_IDNO, -- CaseWelfare_IDNO
                 ISNULL(@Ac_TypeWelfare_CODE, @Lc_Space_TEXT), -- TypeWelfare_CODE
                 ISNULL(@Ac_AttorneyState_CODE, @Lc_Space_TEXT), -- AttorneyState_CODE
                 ISNULL(@Ac_AttorneyCounty_NAME, @Lc_Space_TEXT), -- AttorneyCounty_NAME
                 ISNULL(@Ac_FeeCheckNo_TEXT, @Lc_Space_TEXT), -- FeeCheckNo_TEXT
                 ISNULL(@Ac_StatusEnforce_CODE, @Lc_Space_TEXT), -- StatusEnforce_CODE
                 ISNULL(@Ac_ServiceState_CODE, @Lc_Space_TEXT), -- ServiceState_CODE
                 ISNULL(@Ac_ServiceCounty_NAME, @Lc_Space_TEXT), -- ServiceCounty_NAME 
                 ISNULL(@Ac_Service_CODE, @Lc_Space_TEXT), -- Service_CODE
                 ISNULL(@Ac_ChildSupportOrMedicalAssistance_INDC, @Lc_Space_TEXT), -- ChildSupportOrMedicalAssistance_INDC
                 ISNULL(@Ac_AttorneyCourt_TEXT, @Lc_Space_TEXT), -- AttorneyCourt_TEXT
                 ISNULL(@Ac_MedicalInsuranceCardStatus_CODE, @Lc_Space_TEXT), -- MedicalInsuranceCardStatus_CODE
                 ISNULL(@Ac_PayStubW2FormStatus_CODE, @Lc_Space_TEXT), -- PayStubW2FormStatus_CODE
                 ISNULL(@Ac_PreventAddressReleaseStatus_CODE, @Lc_Space_TEXT), -- PreventAddressReleaseStatus_CODE
                 ISNULL(@Ac_MemberSocialSecurityCardStatus_CODE, @Lc_Space_TEXT), -- MemberSocialSecurityCardStatus_CODE
                 ISNULL(@Ac_MarriedDivorceDecreeStatus_CODE, @Lc_Space_TEXT), -- MarriedDivorceDecreeStatus_CODE
                 ISNULL(@Ac_PaymentArrearsStatementStatus_CODE, @Lc_Space_TEXT), -- PaymentArrearsStatementStatus_CODE
                 ISNULL(@Ac_ModifiedSupportOrderDecreeStatus_CODE, @Lc_Space_TEXT),--ModifiedSupportOrderDecreeStatus_CODE
                 ISNULL(@Ac_ChildBirthCertificateStatus_CODE, @Lc_Space_TEXT), -- ChildBirthCertificateStatus_CODE
                 ISNULL(@Ac_InformationReleaseRisk_INDC, @Lc_Space_TEXT), -- InformationReleaseRisk_INDC
                 ISNULL(@Ac_AddressPfaProtection_INDC, @Lc_Space_TEXT), -- AddressPfaProtection_INDC
                 ISNULL(@Ac_PaternityAcknowledgmentStatus_CODE, @Lc_Space_TEXT),-- PaternityAcknowledgmentStatus_CODE
                 @Ln_Zero_NUMB, -- TransHeader_IDNO
                 @Lc_Space_TEXT, -- StateFips_CODE
                 @Ld_Low_DATE); --Transaction_DATE

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT INTO APCS_Y1 FAILED ';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   --Set Error Description
   SET @Ls_ErrorMessage_TEXT = @As_DescriptionError_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
