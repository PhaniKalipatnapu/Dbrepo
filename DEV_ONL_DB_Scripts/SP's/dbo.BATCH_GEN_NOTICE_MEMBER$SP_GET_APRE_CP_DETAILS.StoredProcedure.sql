/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_CP_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_CP_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Cp Apre Demo details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_DEMO_DETAILS
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_CP_DETAILS]   
 @An_Application_IDNO		NUMERIC(15), 
 @Ac_Msg_CODE				CHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT  
AS    
BEGIN
    SET NOCOUNT ON;    
  DECLARE  @Lc_StatusSuccess_CODE  CHAR = 'S',
           @Lc_StatusFailed_CODE   CHAR = 'F',
           @Lc_CPPrefix_TEXT       CHAR(2) = 'CP';
  DECLARE  @Ln_MemberMci_IDNO        NUMERIC(10),
           @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_Sql_TEXT              VARCHAR(1000),
           @Ls_Err_Description_TEXT  VARCHAR(4000);
  BEGIN TRY   
		SET @As_DescriptionError_TEXT='';      
		 SET @Ls_Sql_TEXT = 'SELECT APCM_Y1 ';
		 SET @Ls_Sqldata_TEXT = ' Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR), '');
		 
		 SET @Ln_MemberMci_IDNO = dbo.BATCH_COMMON$SF_GET_APRECPMEMBERFORACTIVECASE(@An_Application_IDNO);		
		 
		IF @Ln_MemberMci_IDNO <> 0 OR @Ln_MemberMci_IDNO IS NOT NULL
			BEGIN
				 EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_DEMO_DETAILS   
								 @An_MemberMci_IDNO		   = @Ln_MemberMci_IDNO,
								 @As_Prefix_TEXT		   = @Lc_CPPrefix_TEXT,
								 @Ac_Msg_CODE			   = @Ac_Msg_CODE OUTPUT,  
								 @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
				 IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
					BEGIN
						RAISERROR(50001,16,1);
					END
			END
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE ;
    END TRY            
    BEGIN CATCH
     DECLARE @Li_Error_NUMB					INT = ERROR_NUMBER (),
			  @Li_ErrorLine_NUMB		    INT =  ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @As_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
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
