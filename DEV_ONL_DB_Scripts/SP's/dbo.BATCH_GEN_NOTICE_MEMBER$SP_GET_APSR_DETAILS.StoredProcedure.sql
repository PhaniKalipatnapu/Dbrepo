/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APSR_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APSR_DETAILS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APSR_DETAILS]   
(
 @An_Application_IDNO		NUMERIC(15),
 @An_CpMemberMci_IDNO		NUMERIC(10), 
 @Ac_Msg_CODE				CHAR(5) OUTPUT,  
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT  
 )
AS 
BEGIN
 SET NOCOUNT ON;
  
  DECLARE  @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Ls_Routine_TEXT                 VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_APSR_DETAILS',
           @Ld_High_DATE                    DATE = '12/31/9999';
  
  DECLARE  @Li_Error_NUMB			 INT,
		   @Li_ErrorLine_NUMB		 INT,
		   @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_Sql_TEXT              VARCHAR(1000),
           @Ls_Err_Description_TEXT  VARCHAR(4000);
           
  BEGIN TRY 

		 SET @As_DescriptionError_TEXT = '';       
		 SET @Ls_Sql_TEXT = 'SELECT APCS_Y1 ';
		 SET @Ls_Sqldata_TEXT = ' Applcation_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR(15)), '');
		 
			INSERT INTO #NoticeElementsData_P1
			             (Element_NAME , 
			              Element_Value)
			 (SELECT tag_name, tag_value FROM  
			   (   
			   SELECT 
					CAST(a.CP_CS_ORDER_EXISTS_INDC_YES AS VARCHAR(100)) CP_CS_ORDER_EXISTS_YES_CODE,
					CAST(a.CP_CS_ORDER_EXISTS_INDC_NO AS VARCHAR(100)) CP_CS_ORDER_EXISTS_NO_CODE,   
					CAST(a.SupportOrderedCourt_TEXT AS VARCHAR(100)) SERVICE_TYPE_CODE,
					CAST(a.ChildSupportCounty_NAME AS VARCHAR(100)) SERVICE_COUNTY_ADDR,
					CAST(a.ChildSupportState_CODE AS VARCHAR(100)) SERVICE_STATE_ADDR											
			   FROM   
				(SELECT (CASE WHEN P.ChildSupportOrderExists_INDC = 'Y' THEN 'X' ELSE ''END) CP_CS_ORDER_EXISTS_INDC_YES,
						(CASE WHEN P.ChildSupportOrderExists_INDC = 'N' THEN 'X' ELSE ''END) CP_CS_ORDER_EXISTS_INDC_NO,
						P.SupportOrderedCourt_TEXT,
						P.ChildSupportCounty_NAME,
						P.ChildSupportState_CODE
				 FROM APSR_Y1 P
				WHERE P.Application_IDNO = @An_Application_IDNO
				AND MemberMci_IDNO = @An_CpMemberMci_IDNO
				)a
				   ) up  
				 UNPIVOT   
				 (tag_value FOR tag_name IN (CP_CS_ORDER_EXISTS_YES_CODE,
											 CP_CS_ORDER_EXISTS_NO_CODE,
											 SERVICE_TYPE_CODE,
											 SERVICE_COUNTY_ADDR,
											 SERVICE_STATE_ADDR
											))  
				 AS pvt);
       
	 SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE ;    
    END TRY            
    BEGIN CATCH        
         SET @Li_Error_NUMB	= ERROR_NUMBER ();
		 SET @Li_ErrorLine_NUMB	= ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @As_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
