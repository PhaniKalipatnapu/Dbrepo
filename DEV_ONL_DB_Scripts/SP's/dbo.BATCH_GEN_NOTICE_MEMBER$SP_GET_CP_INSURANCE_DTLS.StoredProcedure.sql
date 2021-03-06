/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_INSURANCE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_INSURANCE_DTLS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_INSURANCE_DTLS]  
 @An_Application_IDNO  NUMERIC(15),   
 @Ac_Msg_CODE    VARCHAR(5) OUTPUT,    
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT    
AS      
BEGIN  
      SET NOCOUNT ON;  
      
DECLARE      
  @Ld_High_DATE      DATETIME2,  
  @Ls_SQLString_TEXT    VARCHAR(MAX),      
  @Lc_StatusSuccess_CODE   CHAR,   
  @Ls_SqlQuery_TEXT     VARCHAR(MAX),  
  @Ls_Routine_TEXT     VARCHAR(60)='BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_INSURANCE_DTLS',  
  @Ls_Sql_TEXT      VARCHAR(1000),   
  @Ls_Sqldata_TEXT     VARCHAR(400),  
  @Lc_StatusFailed_CODE    CHAR,   
  @Ls_Err_Description_TEXT   VARCHAR(4000),  
  @Ln_Zero_NUMB      NUMERIC=0,  
  @Lc_Space_TEXT     CHAR=' ',  
  @Ln_Rowcount_QNTY     NUMERIC(2),  
  @Ln_CpMemberMci_IDNO    NUMERIC(10),  
  @Ln_MedicalOthpIns_NUMB   NUMERIC(9),  
  @Ln_DentalOthpIns_NUMB   NUMERIC(9),  
  @Ls_Prefix_TEXT     VARCHAR(100)  
   
         
  SET @Ld_High_DATE='12-31-9999';       
  SET @Lc_StatusSuccess_CODE = 'S';  
  SET @Lc_StatusFailed_CODE = 'F' ;  
  SET @Ln_Zero_NUMB = 0;  
  SET @As_DescriptionError_TEXT=''  
    
    
  BEGIN TRY   
         
         
  SET @Ls_Sql_TEXT = 'SELECT APCS_Y1 ';  
  
   SET @Ls_Sqldata_TEXT = ' Applcation_IDNO: ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), '');  
     
   IF @An_Application_IDNO IS NOT NULL  
   BEGIN  
      
     SET @Ls_Sql_TEXT = 'SELECT APCM_Y1';  
  
      SET @Ls_Sqldata_TEXT = 'Application_IDNO =' + ISNULL(CAST(@An_Application_IDNO AS CHAR), '');  
        
      SET @Ln_CpMemberMci_IDNO = dbo.BATCH_COMMON$SF_GET_APRENCPMEMBERFORACTIVECASE(@An_Application_IDNO)  
                    
   END  
   IF @Ln_CpMemberMci_IDNO <> 0 or @Ln_CpMemberMci_IDNO <> NULL  
   BEGIN  
		SET @Ls_Sql_TEXT = 'SELECT MINS_Y1';  
  
        SET @Ls_Sqldata_TEXT = 'Application_IDNO =' + ISNULL(CAST(@An_Application_IDNO AS CHAR), '') +' '+'MemberMci_IDNO =' + ISNULL(CAST(@Ln_CpMemberMci_IDNO AS CHAR), ''); 
        
        EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_INSURANCE_DTLS  
          @An_MemberMci_IDNO    = @Ln_CpMemberMci_IDNO,  
          @An_Application_IDNO  = @An_Application_IDNO,  
          @As_Prefix_TEXT       = 'CP',  
          @Ac_Msg_CODE          = @Ac_Msg_CODE OUTPUT,    
          @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
              
			IF @Ac_Msg_CODE != @Lc_StatusFailed_CODE 
			BEGIN
				RETURN;
			END 	
     
    SET @Ln_MedicalOthpIns_NUMB = (SELECT Element_value   
             FROM #NoticeElementsData_P1  
             WHERE ELement_NAME = 'MEDICAL_INSURANCE_IDNO')  
               
    SET @Ln_DentalOthpIns_NUMB = (SELECT Element_value   
             FROM #NoticeElementsData_P1  
             WHERE ELement_NAME = 'DENTAL_INSURANCE_IDNO')         
               
    IF  @Ln_MedicalOthpIns_NUMB <> 0  
     BEGIN  
      SET @Ls_Prefix_TEXT = 'CP_HEALTH_INSURANCE_COMPANY'  
     END  
    ELSE IF @Ln_DentalOthpIns_NUMB <> 0  
     BEGIN  
      SET @Ls_Prefix_TEXT = 'CP_DENTAL_INSURANCE_COMPANY'  
     END  
      
     IF @Ln_MedicalOthpIns_NUMB <> 0 OR @Ln_MedicalOthpIns_NUMB IS NOT NULL
		 BEGIN   
		 SET @Ls_Sql_TEXT = 'SELECT MINS_Y1';  
  
          SET @Ls_Sqldata_TEXT = 'Application_IDNO =' + ISNULL(CAST(@An_Application_IDNO AS CHAR), '') +' '+'MedicalOthpIns_NUMB =' + ISNULL(CAST(@Ln_MedicalOthpIns_NUMB AS CHAR), ''); 
		 
		  EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS  
		   @An_OtherParty_IDNO = @Ln_MedicalOthpIns_NUMB,  
		   @As_Prefix_TEXT     = @Ls_Prefix_TEXT,  
		   @Ac_Msg_CODE  = @Ac_Msg_CODE OUTPUT,  
		   @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT  
       
		 IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE  
		   RETURN ;    
	       
		SET @Ln_Rowcount_QNTY = @@ROWCOUNT;  
	        
		 IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB  
			BEGIN
				SET @Ac_Msg_CODE = 'E0058';
				SET @Ls_Err_Description_TEXT = 'Error IN '+ ERROR_PROCEDURE ()+ ' PROCEDURE'+ '. Error DESC - '+ @As_DescriptionError_TEXT+ '. Error EXECUTE Location - '+ @Ls_Sql_TEXT+ '. Error List KEY - '+ @Ls_Sqldata_TEXT;
				SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT
				RETURN;  
			END 
		 END
	END 
	ELSE
		BEGIN
			SET @Ac_Msg_CODE = 'E0058';
			 SET @Ls_Err_Description_TEXT = 'Error IN '+ ERROR_PROCEDURE ()+ ' PROCEDURE'+ '. Error DESC - '+ @As_DescriptionError_TEXT+ '. Error EXECUTE Location - '+ @Ls_Sql_TEXT+ '. Error List KEY - '+ @Ls_Sqldata_TEXT;
				SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT+' '+ 'Error Description :'+' MemberMci IDNO is NULL ' ;
				RETURN;
			RETURN;
		END  
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE ; 
    
      
    END TRY      
          
    BEGIN CATCH      
      
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;  
       
   IF ERROR_NUMBER () = 50001  
   BEGIN  
    SET @Ls_Err_Description_TEXT =  
      'Error IN '  
       + ERROR_PROCEDURE ()  
       + ' PROCEDURE'  
       + '. Error DESC - '  
       + @As_DescriptionError_TEXT  
       + '. Error EXECUTE Location - '  
       + @Ls_Sql_TEXT  
       + '. Error List KEY - '  
       + @Ls_Sqldata_TEXT;  
   END  
   ELSE  
   BEGIN  
  
      SET @Ls_Err_Description_TEXT =  
      'Error IN '  
       + ERROR_PROCEDURE ()  
       + ' PROCEDURE'  
       + '. Error DESC - '  
       + SUBSTRING (ERROR_MESSAGE (), 1, 200)  
       + '. Error Line No - '  
       + CAST (ERROR_LINE () AS VARCHAR)  
       + '. Error Number - '  
       + CAST (ERROR_NUMBER () AS VARCHAR);  
  
     
      
   END  
   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;     
   END CATCH      
      
END      
   


GO
