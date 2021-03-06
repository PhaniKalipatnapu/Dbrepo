/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_APPLICATION_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_APPLICATION_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Application details from APCS_Y1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_APPLICATION_DETAILS](
 @An_Application_IDNO      NUMERIC(15),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) ='S',
          @Lc_StatusFailed_CODE  CHAR(1) ='F',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICE$SP_GET_APPLICATION_DETAILS',
          @Ld_High_DATE          DATE ='12/31/9999',
          @Ld_Low_DATE           DATE ='01/01/0001';
  DECLARE @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_Sql_TEXT              VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000) ='';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT APCS_Y1 ';
   SET @Ls_Sqldata_TEXT = ' Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR(15)), '');
  INSERT INTO #NoticeElementsData_P1(
                Element_NAME,
                Element_VALUE)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), a.AppReq_DATE) AS App_Requested_DATE,
                   CONVERT(VARCHAR(100), a.AppSenT_DATE) AS App_Sent_DATE,
                   CONVERT(VARCHAR(100), a.AppRetd_DATE) AS App_Received_DATE,
                   CONVERT(VARCHAR(100), a.AddressPfaProtection_Yes_CODE) AS AddressPfaProtection_Yes_CODE,
                   CONVERT(VARCHAR(100), a.AddressPfaProtection_No_CODE) AS AddressPfaProtection_No_CODE,
                   CONVERT(VARCHAR(100), a.InformationReleaseRisk_Yes_CODE) AS InformationReleaseRisk_Yes_CODE,
                   CONVERT(VARCHAR(100), a.InformationReleaseRisk_No_CODE) AS InformationReleaseRisk_No_CODE,
                   CONVERT(VARCHAR(100), a.ChildBirthCertificateStatus_At_CODE) AS ChildBirthCertificateStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.ChildBirthCertificateStatus_Tp_CODE) AS ChildBirthCertificateStatus_Tp_CODE,
                   CONVERT(VARCHAR(100), a.PaternityAcknowledgmentStatus_At_CODE) AS PaternityAcknowledgmentStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.PaternityAcknowledgmentStatus_Tp_CODE) AS PaternityAcknowledgmentStatus_Tp_CODE,
                   CONVERT(VARCHAR(100), a.ModifiedSupportOrderDecreeStatus_At_CODE) AS ModifiedSupportOrderDecreeStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.ModifiedSupportOrderDecreeStatus_Tp_CODE) AS ModifiedSupportOrderDecreeStatus_Tp_CODE,
                   CONVERT(VARCHAR(100), a.PaymentArrearsStatementStatus_At_CODE) AS PaymentArrearsStatementStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.PaymentArrearsStatementStatus_Tp_CODE) AS PaymentArrearsStatementStatus_Tp_CODE,
                   CONVERT(VARCHAR(100), a.MarriedDivorceDecreeStatus_At_CODE) AS MarriedDivorceDecreeStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.MarriedDivorceDecreeStatus_Tp_CODE) AS MarriedDivorceDecreeStatus_Tp_CODE,
                   CONVERT(VARCHAR(100), a.MemberSocialSecurityCardStatus_At_CODE) AS MemberSocialSecurityCardStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.MemberSocialSecurityCardStatus_Tp_CODE) AS MemberSocialSecurityCardStatus_Tp_CODE,
                   CONVERT(VARCHAR(100), a.PreventAddressReleaseStatus_At_CODE) AS PreventAddressReleaseStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.PreventAddressReleaseStatus_Tp_CODE) AS PreventAddressReleaseStatus_Tp_CODE,
                   CONVERT(VARCHAR(100), a.PayStubW2FormStatus_At_CODE) AS PayStubW2FormStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.PayStubW2FormStatus_Tp_CODE) AS PayStubW2FormStatus_Tp_CODE,
                   CONVERT(VARCHAR(100), a.MedicalInsuranceCardStatus_At_CODE) AS MedicalInsuranceCardStatus_At_CODE,
                   CONVERT(VARCHAR(100), a.MedicalInsuranceCardStatus_Tp_CODE) AS MedicalInsuranceCardStatus_Tp_CODE
              FROM (SELECT CASE WHEN p.AppReq_DATE = @Ld_Low_DATE THEN CONVERT (VARCHAR(10),'') ELSE LEFT(CONVERT(VARCHAR , p.AppReq_DATE ,120) ,10)END AS AppReq_DATE,
                           CASE WHEN p.AppSenT_DATE = @Ld_Low_DATE THEN CONVERT (VARCHAR(10),'') ELSE LEFT(CONVERT(VARCHAR ,p.AppSenT_DATE ,120) ,10) END AS AppSenT_DATE,
                           CASE WHEN p.AppRetd_DATE = @Ld_Low_DATE THEN '' ELSE LEFT(CONVERT(VARCHAR ,p.AppRetd_DATE,120) ,10) END AS AppRetd_DATE,
                           (CASE
                             WHEN p.AddressPfaProtection_INDC = 'Y'
                              THEN 'X'
                             ELSE ''
                            END) AddressPfaProtection_Yes_CODE,
                           (CASE
                             WHEN p.AddressPfaProtection_INDC = 'N'
                              THEN 'X'
                             ELSE ''
                            END) AddressPfaProtection_No_CODE,
                           (CASE
                             WHEN p.InformationReleaseRisk_INDC = 'Y'
                              THEN 'X'
                             ELSE ''
                            END) InformationReleaseRisk_Yes_CODE,
                           (CASE
                             WHEN p.InformationReleaseRisk_INDC = 'N'
                              THEN 'X'
                             ELSE ''
                            END) InformationReleaseRisk_No_CODE,
                           (CASE
                             WHEN p.ChildBirthCertificateStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) ChildBirthCertificateStatus_At_CODE,
                           (CASE
                             WHEN p.ChildBirthCertificateStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) ChildBirthCertificateStatus_Tp_CODE,
                           (CASE
                             WHEN p.PaternityAcknowledgmentStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) PaternityAcknowledgmentStatus_At_CODE,
                           (CASE
                             WHEN p.PaternityAcknowledgmentStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) PaternityAcknowledgmentStatus_Tp_CODE,
                           (CASE
                             WHEN p.ModifiedSupportOrderDecreeStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) ModifiedSupportOrderDecreeStatus_At_CODE,
                           (CASE
                             WHEN p.ModifiedSupportOrderDecreeStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) ModifiedSupportOrderDecreeStatus_Tp_CODE,
                           (CASE
                             WHEN p.PaymentArrearsStatementStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) PaymentArrearsStatementStatus_At_CODE,
                           (CASE
                             WHEN p.PaymentArrearsStatementStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) PaymentArrearsStatementStatus_Tp_CODE,
                           (CASE
                             WHEN p.MarriedDivorceDecreeStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) MarriedDivorceDecreeStatus_At_CODE,
                           (CASE
                             WHEN p.MarriedDivorceDecreeStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) MarriedDivorceDecreeStatus_Tp_CODE,
                           (CASE
                             WHEN p.MemberSocialSecurityCardStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) MemberSocialSecurityCardStatus_At_CODE,
                           (CASE
                             WHEN p.MemberSocialSecurityCardStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) MemberSocialSecurityCardStatus_Tp_CODE,
                           (CASE
                             WHEN p.PreventAddressReleaseStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) PreventAddressReleaseStatus_At_CODE,
                           (CASE
                             WHEN p.PreventAddressReleaseStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) PreventAddressReleaseStatus_Tp_CODE,
                           (CASE
                             WHEN p.PayStubW2FormStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) PayStubW2FormStatus_At_CODE,
                           (CASE
                             WHEN p.PayStubW2FormStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) PayStubW2FormStatus_Tp_CODE,
                           (CASE
                             WHEN p.MedicalInsuranceCardStatus_CODE = 'A'
                              THEN 'X'
                             ELSE ''
                            END) MedicalInsuranceCardStatus_At_CODE,
                           (CASE
                             WHEN p.MedicalInsuranceCardStatus_CODE = 'T'
                              THEN 'X'
                             ELSE ''
                            END) MedicalInsuranceCardStatus_Tp_CODE
                      FROM APCS_Y1 p
                     WHERE Application_IDNO = @An_Application_IDNO
                       AND EndValidity_DATE = @Ld_High_DATE)a)up UNPIVOT (tag_value FOR tag_name IN (App_Requested_DATE, App_Sent_DATE, App_Received_DATE, AddressPfaProtection_Yes_CODE, AddressPfaProtection_No_CODE, InformationReleaseRisk_Yes_CODE, InformationReleaseRisk_No_CODE, ChildBirthCertificateStatus_At_CODE, ChildBirthCertificateStatus_Tp_CODE, PaternityAcknowledgmentStatus_At_CODE, PaternityAcknowledgmentStatus_Tp_CODE, ModifiedSupportOrderDecreeStatus_At_CODE, ModifiedSupportOrderDecreeStatus_Tp_CODE, PaymentArrearsStatementStatus_At_CODE, PaymentArrearsStatementStatus_Tp_CODE, MarriedDivorceDecreeStatus_At_CODE, MarriedDivorceDecreeStatus_Tp_CODE, MemberSocialSecurityCardStatus_At_CODE, MemberSocialSecurityCardStatus_Tp_CODE, PreventAddressReleaseStatus_At_CODE, PreventAddressReleaseStatus_Tp_CODE, PayStubW2FormStatus_At_CODE, PayStubW2FormStatus_Tp_CODE, MedicalInsuranceCardStatus_At_CODE, MedicalInsuranceCardStatus_Tp_CODE )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
