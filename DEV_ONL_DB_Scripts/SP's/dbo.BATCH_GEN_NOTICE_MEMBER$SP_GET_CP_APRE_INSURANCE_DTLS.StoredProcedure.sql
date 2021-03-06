/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_APRE_INSURANCE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_APRE_INSURANCE_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Apre case management details from APCM_Y1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
Called On		:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_INSURANCE_DTLS
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_APRE_INSURANCE_DTLS]  
	 @An_Application_IDNO  NUMERIC(15),   
	 @Ac_Msg_CODE		CHAR(5) OUTPUT,    
	 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT    
AS      
BEGIN  
	SET NOCOUNT ON;        
  DECLARE  @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Ls_Routine_TEXT        VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_APRE_INSURANCE_DTLS';
  DECLARE  
           @Ln_MedicalOthpIns_NUMB   NUMERIC(9),
           @Ln_DentalOthpIns_NUMB    NUMERIC(9),
           @Ln_CpMemberMci_IDNO      NUMERIC(10),
		   @Li_Error_NUMB			 INT,
		   @Li_ErrorLine_NUMB		 INT,
           @Ls_Prefix_TEXT			 VARCHAR(100),
           @Ls_Sql_TEXT              VARCHAR(200),
           @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_Err_Description_TEXT  VARCHAR(4000);
  BEGIN TRY            
  SET @As_DescriptionError_TEXT='';
  SET @Ls_Sql_TEXT = 'SELECT APCS_Y1'; 
  SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR(15)), '');  
     
   IF @An_Application_IDNO IS NOT NULL  AND @An_Application_IDNO <> 0
   BEGIN        
		SET @Ls_Sql_TEXT = 'SELECT APCM_Y1';    
        SET @Ls_Sqldata_TEXT = 'Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR(15)), '');                      
        SET @Ln_CpMemberMci_IDNO = DBO.BATCH_COMMON$SF_GET_APRECPMEMBERFORACTIVECASE(@An_Application_IDNO);                    
   END  
   IF @Ln_CpMemberMci_IDNO <> 0 AND @Ln_CpMemberMci_IDNO IS NOT NULL  
   BEGIN  
	 
	 EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_INSURANCE_DTLS  
				@An_Application_IDNO	  = @An_Application_IDNO,
				@An_MemberMci_IDNO		  = @Ln_CpMemberMci_IDNO,  
				@Ac_Msg_CODE			  = @Ac_Msg_CODE OUTPUT,    
				@As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;
				
		IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE  
			BEGIN
				RAISERROR(@Lc_StatusFailed_CODE, 16, 1); 	
			END   
     
    SET @Ln_MedicalOthpIns_NUMB = (SELECT Element_value   
             FROM #NoticeElementsData_P1  
             WHERE ELement_NAME = 'MEDICAL_INSURANCE_IDNO'); 
               
    SET @Ln_DentalOthpIns_NUMB = (SELECT Element_value   
             FROM #NoticeElementsData_P1  
             WHERE ELement_NAME = 'DENTAL_INSURANCE_IDNO');       
               
	IF  @Ln_MedicalOthpIns_NUMB <> 0  
		BEGIN  
			SET @Ls_Prefix_TEXT = 'CP_HEALTH_INSURANCE_COMPANY'; 
			
			EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS  
					   @An_OtherParty_IDNO		 = @Ln_MedicalOthpIns_NUMB,  
					   @As_Prefix_TEXT			 = @Ls_Prefix_TEXT,  
					   @Ac_Msg_CODE				 = @Ac_Msg_CODE OUTPUT,  
					   @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;  
			
			IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE  
				BEGIN
					RAISERROR(@Lc_StatusFailed_CODE, 16, 1); 	
				END  
		END  
	
	IF @Ln_DentalOthpIns_NUMB <> 0  
		BEGIN  
			SET @Ls_Prefix_TEXT = 'CP_DENTAL_INSURANCE_COMPANY'; 
			
			EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS  
					   @An_OtherParty_IDNO		 = @Ln_MedicalOthpIns_NUMB,  
					   @As_Prefix_TEXT			 = @Ls_Prefix_TEXT,  
					   @Ac_Msg_CODE				 = @Ac_Msg_CODE OUTPUT,  
					   @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;  
			
			IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE  
				BEGIN
					RAISERROR(@Lc_StatusFailed_CODE, 16, 1); 	
				END  
		END  
     	 
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
