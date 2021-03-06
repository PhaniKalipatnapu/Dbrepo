/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_INSURANCE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_INSURANCE_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Apre case management details from APCM_Y1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_INSURANCE_DTLS]
 @An_MemberMci_IDNO			NUMERIC(10),
 @An_Application_IDNO		NUMERIC(15), 
 @Ac_Msg_CODE				CHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT  
AS    
BEGIN
      SET NOCOUNT ON;
    
  DECLARE  @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Ls_Routine_TEXT        VARCHAR(60) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_INSURANCE_DTLS';           
  DECLARE  
           @Ln_MedicalOthpIns_NUMB   NUMERIC(9),
           @Ln_CpMemberMci_IDNO      NUMERIC(10),
           @Li_Error_NUMB			 INT,
		   @Li_ErrorLine_NUMB		 INT,
           @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_Sql_TEXT              VARCHAR(1000),
           @Ls_Err_Description_TEXT  VARCHAR(4000),
           @Ld_High_DATE             DATETIME2;
  BEGIN TRY 
		SET @As_DescriptionError_TEXT=''
  		SET @Ls_Sql_TEXT = 'SELECT APMI_Y1';
		SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '');
		 
		 IF @An_MemberMci_IDNO IS NOT NULL AND @An_MemberMci_IDNO <> 0
			BEGIN
				INSERT INTO #NoticeElementsData_P1(Element_NAME,Element_value)
				(SELECT tag_name, tag_value FROM    
					 (   
				SELECT 
					CONVERT(VARCHAR(100), a.MedicalPolicyInsNo_TEXT) CP_HEALTH_INSURANCE_POLICY_NUMBER,
					CONVERT(VARCHAR(100), a.MedicalMonthlyPremium_AMNT) CP_HEALTH_INSURANCE_MONTHLY_PREMIUM_AMNT,
					CONVERT(VARCHAR(100), ISNULL(a.MedicalOthpIns_IDNO,0)) MEDICAL_INSURANCE_IDNO,
					CONVERT(VARCHAR(100), a.DentalMonthlyPremium_AMNT) CP_DENTAL_INSURANCE_MONTHLY_PREMIUM_AMNT,
					CONVERT(VARCHAR(100), ISNULL(a.DentalOthpIns_IDNO,0)) DENTAL_INSURANCE_IDNO,
					CONVERT(VARCHAR(100), a.DentalPolicyInsNo_TEXT) CP_DENTAL_INSURANCE_POLICY_NUMBER
				FROM 
				(
					SELECT ap.MedicalPolicyInsNo_TEXT,
						   ap.MedicalMonthlyPremium_AMNT,
						   ap.MedicalOthpIns_IDNO,
						   ap.DentalMonthlyPremium_AMNT,
						   ap.DentalOthpIns_IDNO ,
						   ap.DentalPolicyInsNo_TEXT 
					 FROM APMI_Y1 ap
					WHERE MemberMci_IDNO = @An_MemberMci_IDNO 
					AND Application_IDNO = @An_Application_IDNO)a
					 ) up    
					UNPIVOT     
					(tag_value FOR tag_name IN (CP_HEALTH_INSURANCE_POLICY_NUMBER,
												CP_HEALTH_INSURANCE_MONTHLY_PREMIUM_AMNT,
												MEDICAL_INSURANCE_IDNO,
												CP_DENTAL_INSURANCE_MONTHLY_PREMIUM_AMNT,
												DENTAL_INSURANCE_IDNO,
												CP_DENTAL_INSURANCE_POLICY_NUMBER
						  ))    
					AS pvt);
			END
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE ;    
    END TRY            
    BEGIN CATCH    
		 SET @Li_Error_NUMB	 = ERROR_NUMBER ();
		 SET @Li_ErrorLine_NUMB =  ERROR_LINE ();
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Routine_TEXT,
                                                       @As_ErrorMessage_TEXT = @As_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
    END CATCH    
    
END

GO
