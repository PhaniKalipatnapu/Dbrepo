/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_ATTORNEY_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_ATTORNEY_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Cp Apre Demo details
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_ATTORNEY_DETAILS]   
 @An_Application_IDNO		NUMERIC(9), 
 @Ac_Msg_CODE				VARCHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT  
AS    
BEGIN
      SET NOCOUNT ON;
    
DECLARE  
  @Ln_MemberMci_IDNO			    NUMERIC(10),     
  @Ld_High_DATE						DATETIME,
  @Ls_SQLString_TEXT				VARCHAR(MAX),    
  @Lc_StatusSuccess_CODE			CHAR, 
  @Ls_Routine_TEXT					VARCHAR(60)='BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_ATTORNEY_DETAILS',
  @Ls_Sql_TEXT						VARCHAR(1000), 
  @Ls_Sqldata_TEXT					VARCHAR(400),
  @Lc_StatusFailed_CODE				CHAR, 
  @Ls_Err_Description_TEXT			VARCHAR(4000),
  @Ln_Zero_NUMB						NUMERIC=0,
  @Lc_Space_TEXT					CHAR=' ',
  @Ln_Rowcount_QNTY					NUMERIC(2);
       
  SET @Ld_High_DATE='12-31-9999';     
  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F' ;
  SET @Ln_Zero_NUMB = 0;
  SET @As_DescriptionError_TEXT='';
      

  BEGIN TRY 
     
		SET @Ls_Sql_TEXT = 'SELECT APCM_Y1 ';

		 SET @Ls_Sqldata_TEXT = ' Application_IDNO: ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), '');
		 
		SET @Ln_MemberMci_IDNO =dbo.BATCH_COMMON$SF_GET_APRE_CPATTORNEY(@An_Application_IDNO)
		
		EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS   
						 @An_OtherParty_IDNO	   = @Ln_MemberMci_IDNO,
						 @As_Prefix_TEXT		   = 'ATTORNEY',
						 @Ac_Msg_CODE			   = @Ac_Msg_CODE OUTPUT,  
						 @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT  
		IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
		RETURN ;
    
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
