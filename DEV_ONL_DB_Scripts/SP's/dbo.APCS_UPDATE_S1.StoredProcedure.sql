/****** Object:  StoredProcedure [dbo].[APCS_UPDATE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_UPDATE_S1](
 @An_Application_IDNO                      NUMERIC(15),
 @Ac_SignedOnWorker_ID                     CHAR(30),
 @An_TransactionEventSeq_NUMB              NUMERIC(19),
 @An_NewTransactionEventSeq_NUMB           NUMERIC(19),
 @Ac_AddressPfaProtection_INDC             CHAR(1),
 @Ac_InformationReleaseRisk_INDC           CHAR(1),
 @Ac_ChildBirthCertificateStatus_CODE      CHAR(1),
 @Ac_ModifiedSupportOrderDecreeStatus_CODE CHAR(1),
 @Ac_PaymentArrearsStatementStatus_CODE    CHAR(1),
 @Ac_MarriedDivorceDecreeStatus_CODE       CHAR(1),
 @Ac_MemberSocialSecurityCardStatus_CODE   CHAR(1),
 @Ac_PayStubW2FormStatus_CODE              CHAR(1),
 @Ac_MedicalInsuranceCardStatus_CODE       CHAR(1),
 @Ac_ChildSupportOrMedicalAssistance_INDC  CHAR(1),
 @Ac_Service_CODE                          CHAR(1),
 @Ac_ServiceCounty_NAME                    CHAR(40),
 @Ac_ServiceState_CODE                     CHAR(2),
 @Ac_PreventAddressReleaseStatus_CODE      CHAR(1),
 @Ac_AttorneyCourt_TEXT                    CHAR(40),
 @Ac_StatusEnforce_CODE                    CHAR(4),
 @Ac_FeeCheckNo_TEXT                       CHAR(20),
 @Ac_PaternityAcknowledgmentStatus_CODE    CHAR(1),
 @Ac_AttorneyCounty_NAME                   CHAR(40),
 @Ac_AttorneyState_CODE                    CHAR(2),
 @An_TransHeader_IDNO                      NUMERIC(12, 0),
 @Ac_StateFips_CODE                        CHAR(2),
 @Ad_Transaction_DATE                      DATE,
 @An_CaseWelfare_IDNO                      NUMERIC(10),
 @Ac_TypeWelfare_CODE					   CHAR(1),
 @Ac_ApplicationStatus_CODE                CHAR(1)
 )
AS
 /*                                                                                                                                                                               
 *     PROCEDURE NAME    : APCS_UPDATE_S1                                                                                                                                         
  *     DESCRIPTION       : Logically delete the valid record for an Application ID when End Validity Date is equal to High Date.                                                                                                                                                                                                           
  *     DEVELOPED BY      : IMP Team                                                                                                                                            
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                           
  *     MODIFIED BY       :                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                     
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999',
          @Li_RowsAffected_NUMB   INT,
          @Lc_Space_TEXT          CHAR(1) = ' ';

  UPDATE APCS_Y1
     SET EndValidity_DATE = @Ld_Systemdatetime_DTTM
  OUTPUT @An_Application_IDNO,
         DELETED.Application_DATE,
         @Ld_Systemdatetime_DTTM,
         @Ld_High_DATE,
         @Ld_Systemdatetime_DTTM,
         @Ac_SignedOnWorker_ID,
         @An_NewTransactionEventSeq_NUMB,
         DELETED.TypeCase_CODE,
         DELETED.Opened_DATE,
         DELETED.StatusCase_CODE,
         DELETED.StatusCurrent_DATE,
         DELETED.RsnStatusCase_CODE,
         DELETED.County_IDNO,
         DELETED.SourceRfrl_CODE,
         DELETED.Restricted_INDC,
         DELETED.MedicalOnly_INDC,
         DELETED.GoodCause_CODE,
         DELETED.GoodCause_DATE,
         DELETED.NonCoop_CODE,
         DELETED.NonCoop_DATE,
         DELETED.IvdApplicant_CODE,
         DELETED.AppReq_DATE,
         DELETED.AppSent_DATE,
         DELETED.AppRetd_DATE,
         DELETED.AppSigned_DATE,
         DELETED.RsnFeeWaived_CODE,
         DELETED.DescriptionComments_TEXT,
         @Ac_ApplicationStatus_CODE,
         DELETED.RespondInit_CODE,
         DELETED.Referral_DATE,
         DELETED.CaseCategory_CODE,
         DELETED.ApplicationFee_CODE,
         DELETED.FeePaid_DATE,
         DELETED.ServiceRequested_CODE,
         DELETED.File_ID,
		 @An_CaseWelfare_IDNO,         
         @Ac_TypeWelfare_CODE,
         @Ac_AttorneyState_CODE,
         @Ac_AttorneyCounty_NAME,
         @Ac_FeeCheckNo_TEXT,
         @Ac_StatusEnforce_CODE,
         @Ac_ServiceState_CODE,
         @Ac_ServiceCounty_NAME,
         @Ac_Service_CODE,
         @Ac_ChildSupportOrMedicalAssistance_INDC,
         @Ac_AttorneyCourt_TEXT,
         @Ac_MedicalInsuranceCardStatus_CODE,
         @Ac_PayStubW2FormStatus_CODE,
         @Ac_PreventAddressReleaseStatus_CODE,
         @Ac_MemberSocialSecurityCardStatus_CODE,
         @Ac_MarriedDivorceDecreeStatus_CODE,
         @Ac_PaymentArrearsStatementStatus_CODE,
         @Ac_ModifiedSupportOrderDecreeStatus_CODE,
         @Ac_ChildBirthCertificateStatus_CODE,
         @Ac_InformationReleaseRisk_INDC,
         @Ac_AddressPfaProtection_INDC,
         @Ac_PaternityAcknowledgmentStatus_CODE,
         @An_TransHeader_IDNO,
         @Ac_StateFips_CODE,
         @Ad_Transaction_DATE
  INTO APCS_Y1
   WHERE Application_IDNO = @An_Application_IDNO
     AND EndValidity_DATE = @Ld_High_DATE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of APCS_UPDATE_S1

GO
