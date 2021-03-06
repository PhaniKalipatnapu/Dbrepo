/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_MEMBER_LICENCE_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name        :BATCH_GEN_NOTICE_EST_ENF$SP_MEMBER_LICENCE_OPTS
 Programmer Name       : IMP Team
 Description           :This procedure is used to categorize member licence details into any of the types licence holders Driving, Hunting, 
	     	               Fishing, Business and Professional.
 Frequency             :
 Developed On          :02-08-2011
 Called By             :BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On             :
---------------------------------------------------------
 Modified By           :
 Modified On           :
 Version No            : 1.0 
---------------------------------------------------------
*/  

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_MEMBER_LICENCE_OPTS](
 @An_MemberMci_IDNO			NUMERIC(10), 
 @Ac_Msg_CODE				CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_Empty_TEXT					CHAR(1) = ' ',
		  @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
          @Lc_StatusFailed_CODE				CHAR(1) = 'F',
          @Lc_CheckBoxValue_TEXT			CHAR(1) = 'X',
          @Lc_LicenseStatusActive_CODE		CHAR(1) = 'A',
          @Lc_StatusCg_CODE					CHAR(2) = 'CG',
          @Lc_TypeLicenseDr_CODE			CHAR(2) = 'DR',
          @Lc_IssuingStateDelaware_CODE		CHAR(2)	= 'DE',
          @Lc_TypeLicenseFis_CODE			CHAR(3) = 'FIS',
          @Lc_TypeLicenseHun_CODE			CHAR(3) = 'HUN',
          @Lc_TypeLicense1000_CODE			CHAR(4) = '1000',
          @Lc_TypeLicense8999_CODE			CHAR(4) = '8999',
          @Lc_TypeLicense9000_CODE			CHAR(4) = '9000',
          @Ls_Sql_TEXT						VARCHAR(200) = 'SELECT PLIC_Y1',
          @Ls_SqlData_TEXT					VARCHAR(400) = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR), ''),
          @Ld_High_DATE						DATE = '12/31/9999';
  DECLARE @Ls_DescriptionError_TEXT         VARCHAR(4000);
 BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(100), type_license_driving_code) type_license_driving_code,
				   CONVERT(VARCHAR(100), type_license_fishing_code) type_license_fishing_code,	
                   CONVERT(VARCHAR(100), type_license_hunting_code) type_license_hunting_code,
                   CONVERT(VARCHAR(100), type_license_business_code) type_license_business_code,
                   CONVERT(VARCHAR(100), type_license_professional_code) type_license_professional_code
              FROM ( SELECT (CASE
                             WHEN SUM(type_license_driving_code) > 0
                              THEN @Lc_CheckBoxValue_Text
                             ELSE @Lc_Empty_TEXT
                            END) type_license_driving_code,
                            (CASE
                             WHEN SUM(type_license_fishing_code) > 0
                              THEN @Lc_CheckBoxValue_Text
                             ELSE @Lc_Empty_TEXT
                            END) type_license_fishing_code,
                           (CASE
                             WHEN SUM(type_license_hunting_code) > 0
                              THEN @Lc_CheckBoxValue_Text
                             ELSE @Lc_Empty_TEXT
                            END) type_license_hunting_code,
                           (CASE
                             WHEN SUM(type_license_business_code) > 0
                              THEN @Lc_CheckBoxValue_Text
                             ELSE @Lc_Empty_TEXT
                            END) type_license_business_code,
                           (CASE
                             WHEN SUM(type_license_professional_code) > 0
                              THEN @Lc_CheckBoxValue_Text
                             ELSE @Lc_Empty_TEXT
                            END) type_license_professional_code
					  FROM (SELECT (CASE
									 WHEN p.TypeLicense_CODE = @Lc_TypeLicenseDr_CODE
									  THEN 1
									 ELSE 0
									END) type_license_driving_code,
									(CASE
									 WHEN p.TypeLicense_CODE = @Lc_TypeLicenseFis_CODE
									  THEN 1
									 ELSE 0
									END) type_license_fishing_code,
								   (CASE
									 WHEN p.TypeLicense_CODE = @Lc_TypeLicenseHun_CODE
									  THEN 1
									 ELSE 0
									END) type_license_hunting_code,
								   (CASE
									 WHEN	(	(	  LEN(RTRIM(p.TypeLicense_CODE)) BETWEEN  1 AND 3
												  AND p.TypeLicense_CODE NOT IN (@Lc_TypeLicenseDr_CODE, @Lc_TypeLicenseFis_CODE, @Lc_TypeLicenseHun_CODE)
												)
											 OR (	  p.TypeLicense_CODE >= @Lc_TypeLicense9000_CODE
												  AND p.TypeLicense_CODE NOT IN (@Lc_TypeLicenseDr_CODE, @Lc_TypeLicenseFis_CODE, @Lc_TypeLicenseHun_CODE)
												)
											)
									  THEN 1
									 ELSE 0
									END) type_license_business_code,
								   (CASE
									 WHEN (		p.TypeLicense_CODE BETWEEN @Lc_TypeLicense1000_CODE AND @Lc_TypeLicense8999_CODE
											AND p.TypeLicense_CODE NOT IN (@Lc_TypeLicenseDr_CODE, @Lc_TypeLicenseFis_CODE, @Lc_TypeLicenseHun_CODE)
										  )
									  THEN 1
									 ELSE 0
									END) type_license_professional_code
							  FROM PLIC_Y1 p
							 WHERE p.MemberMci_IDNO = @An_MemberMci_IDNO
							   AND p.EndValidity_DATE = @Ld_High_DATE
							   AND p.LicenseStatus_CODE = @Lc_LicenseStatusActive_CODE
							   AND p.Status_CODE = @Lc_StatusCg_CODE
							   AND p.IssuingState_CODE = @Lc_IssuingStateDelaware_CODE
							) a
				   )a 
		    ) up 
		UNPIVOT (Element_VALUE FOR Element_NAME IN (  type_license_driving_code,
													  type_license_fishing_code, 
													  type_license_hunting_code, 
													  type_license_business_code, 
													  type_license_professional_code )) AS pvt);
   
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE	@Li_Error_NUMB				INT = ERROR_NUMBER (),
			@Li_ErrorLine_NUMB		    INT =  ERROR_LINE ();
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         SET @Ls_DescriptionError_TEXT =  SUBSTRING (ERROR_MESSAGE (), 1, 200);
         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
