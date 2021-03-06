/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_DR_LICENSE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_DR_LICENSE_DTLS](  
 @An_MemberMci_IDNO				NUMERIC(10), 
 @Ad_Run_DATE                   DATE , 
 @As_Prefix_TEXT				VARCHAR(50),  
 @Ac_Msg_CODE					CHAR(1) OUTPUT,  
 @As_DescriptionError_TEXT		VARCHAR(4000) OUTPUT  
)  
AS  
/*
------------------------------------------------------------------------------------------------------------------------------
Procedure Name   : BATCH_GEN_NOTICES$SP_GET_DR_LICENSE_DTLS
Programmer Name  : IMP Team
Description      : The procedure is used to obtain the driver license details.
Frequency        : 
Developed On     : 01/20/2011
Called BY        : None
Called On        :
-------------------------------------------------------------------------------------------------------------------------------
Modified BY      :
Modified On      :
Version No       : 1.0
--------------------------------------------------------------------------------------------------------------------------------
*/

BEGIN  
SET NOCOUNT ON;
 DECLARE @Lc_LicenceStatusActive_CODE		CHAR(1)			= 'A',  
		 @Lc_LicenceStatusInActive_CODE     CHAR(1)			= 'I',
		 @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',   
		 @Lc_StatusFailed_CODE				CHAR(1)			= 'F',   
		 @Lc_LicenceTypeDr_CODE				CHAR(2)			= 'DR',  
		 @Lc_StatusCodeCg_CODE				CHAR(2)			= 'CG',
		 @Lc_NoticeEnf39_ID					CHAR(8)         = 'ENF-39',
		 @Lc_Notice_ID						CHAR(8)			= '',
		 @Lc_Element_Name					CHAR(10)		= 'Notice_ID',
		 @Ls_Procedure_NAME					VARCHAR(100) 	= 'BATCH_GEN_NOTICES$SP_GET_DR_LICENSE_DTLS',
         @Ls_DescriptionError_TEXT    		VARCHAR(4000) 	= '',
		 @Ld_High_DATE						DATE			= '12/31/9999';
		
		 
 DECLARE @Ln_Error_NUMB              NUMERIC(11),
		 @Ln_ErrorLine_NUMB          NUMERIC(11),
		 @Ls_Sql_TEXT				 VARCHAR(200),
		 @Ls_Sqldata_TEXT			 VARCHAR(400);
	
    
 BEGIN TRY  
   
   SET @Ac_Msg_CODE = NULL;  
   SET @As_DescriptionError_TEXT = NULL; 
           
	-- 12051 - CR0234 ENF-39 PSOC Form Mapping Changes 20130710 - Fix - START
	SET @Ls_Sql_TEXT = 'SELECT #NoticeElementsData_P1';
	SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@Lc_Element_Name AS VARCHAR), '');

	SELECT @Lc_Notice_ID = Element_VALUE 
		FROM #NoticeElementsData_P1 
		WHERE Element_NAME = @Lc_Element_Name
	-- 12051 - CR0234 ENF-39 PSOC Form Mapping Changes 20130710 - Fix - END
					
    SET @Ls_Sql_TEXT = 'INSERT @NoticeElements_P1';
	SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '');						
							
	DECLARE @NoticeElements_P1 TABLE
                                    (
                                       Element_NAME    VARCHAR (100),
                                       Element_VALUE   VARCHAR (100)
                                    );						
   -- 12051 - CR0234 ENF-39 PSOC Form Mapping Changes 20130710 - Fix - START
   INSERT INTO @NoticeElements_P1 (Element_NAME,Element_VALUE)     
								  (SELECT Element_NAME, Element_VALUE FROM    
									(     
									SELECT      
										  CONVERT(VARCHAR(100),a.LicenseNo_TEXT) AS DR_LICENSE_NO_TEXT,    
										  CONVERT(VARCHAR(100),a.IssuingState_CODE) AS DR_LICENSE_ISSUING_STATE_CODE
											FROM  (  
												SELECT  TOP 1
														p.LicenseNo_TEXT,  
														p.IssuingState_CODE  
												  FROM PLIC_Y1 p  
												 WHERE p.MemberMci_IDNO = @An_MemberMci_IDNO  
												   AND p.TypeLicense_CODE =  @Lc_LicenceTypeDr_CODE
												   AND p.Status_CODE = @Lc_StatusCodeCg_CODE
												   AND p.ExpireLicense_DATE > @Ad_Run_DATE
												   AND (p.LicenseStatus_CODE = @Lc_LicenceStatusActive_CODE OR (@Lc_Notice_ID = @Lc_NoticeEnf39_ID AND p.LicenseStatus_CODE IN(@Lc_LicenceStatusInActive_CODE)))
												   AND p.EndValidity_DATE = @Ld_High_DATE
												   AND p.IssueLicense_DATE = (SELECT MAX(p.IssueLicense_DATE)
																			  FROM PLIC_Y1 p   
																			 WHERE p.MemberMci_IDNO = @An_MemberMci_IDNO
																			   AND p.TypeLicense_CODE = @Lc_LicenceTypeDr_CODE
																			   AND p.Status_CODE = @Lc_StatusCodeCg_CODE
																			   AND p.ExpireLicense_DATE > @Ad_Run_DATE
																			   AND (p.LicenseStatus_CODE = @Lc_LicenceStatusActive_CODE OR (@Lc_Notice_ID = @Lc_NoticeEnf39_ID AND p.LicenseStatus_CODE IN(@Lc_LicenceStatusInActive_CODE)))
																			   AND p.EndValidity_DATE = @Ld_High_DATE ))a  
									 ) up    
								   UNPIVOT     
									   (Element_VALUE FOR Element_NAME IN 
									   (DR_LICENSE_NO_TEXT,  
										DR_LICENSE_ISSUING_STATE_CODE)
										)
								   AS Pvt);
		-- 12051 - CR0234 ENF-39 PSOC Form Mapping Changes 20130710 - Fix - END
				
				SET @Ls_Sql_TEXT = 'INSERT @NoticeElements_P1';
				SET @Ls_Sqldata_TEXT = ' Element_NAME = ' + @As_Prefix_TEXT;   
				
				UPDATE @NoticeElements_P1
            	SET Element_NAME = @As_Prefix_TEXT + '_' + Element_NAME;
            	
            	  INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
           		  SELECT TE.Element_NAME, TE.Element_VALUE
           		  FROM @NoticeElements_P1 TE;	
           		  
  	SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
   	END TRY  
	
 BEGIN CATCH  
  		SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
		  	   @Ln_Error_NUMB = ERROR_NUMBER(),
   		  	   @Ln_ErrorLine_NUMB = ERROR_LINE();
   		  	   
      IF ERROR_NUMBER () <> 50001  
      BEGIN  
      SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
      END
      EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    					    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    					    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    					    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    					    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    					    @An_Error_NUMB            = @Ln_Error_NUMB,
    					    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    					    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;	
	 SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;  
     END CATCH  
END;


GO
