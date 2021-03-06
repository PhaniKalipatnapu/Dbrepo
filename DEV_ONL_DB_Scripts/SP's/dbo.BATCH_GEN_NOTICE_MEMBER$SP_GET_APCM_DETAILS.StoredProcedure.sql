/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APCM_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APCM_DETAILS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APCM_DETAILS]
 (	
	 @An_Application_IDNO			NUMERIC(15), 
	 @Ac_Msg_CODE					CHAR(5)			OUTPUT,  
	 @As_DescriptionError_TEXT		VARCHAR(4000)	OUTPUT  
 )
AS    
BEGIN
 SET NOCOUNT ON;
    
  DECLARE  @Li_Error_NUMB        INT = NULL,
           @Li_ErrorLine_NUMB    INT = NULL,
           @Lc_CheckBox1_X_TEXT  CHAR(1) = 'X',
           @Lc_Table_ID          CHAR(4) = 'MRLT',
           @Lc_TableSub_ID       CHAR(4) = 'STAT';
           
   DECLARE 
           @Lc_CaseRelationship_C_CODE    CHAR(1),
           @Lc_Empty_TEXT                 CHAR(1) = '',
           @Lc_StatusSuccess_CODE         CHAR(1),
           @Lc_StatusFailed_CODE          CHAR(1),
           @Lc_RelationshipToNcp_NM_CODE  CHAR(2),
           @Lc_RelationshipToNcp_MA_CODE  CHAR(2),
           @Lc_RelationshipToNcp_SP_CODE  CHAR(2),
           @Lc_RelationshipToNcp_DI_CODE  CHAR(2),
           @Lc_RelationshipToNcp_WO_CODE  CHAR(2),
           @Lc_RelationshipToNcp_CU_CODE  CHAR(2),
           @Ls_Procedure_NAME             VARCHAR(100) = '',
           @Ls_Sqldata_TEXT               VARCHAR(400),
           @Ls_Sql_TEXT                   VARCHAR(1000),
           @Ls_DescriptionError_TEXT      VARCHAR(4000),
           @Ld_High_DATE                  DATE;

  BEGIN TRY 

		SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_APCM_DETAILS';	
		SET @Ld_High_DATE						= '12/31/9999';     
		SET @Lc_StatusSuccess_CODE				= 'S';
		SET @Lc_StatusFailed_CODE				= 'F' ;
		SET @As_DescriptionError_TEXT			= '';
		SET @Lc_RelationshipToNcp_NM_CODE		= 'NM'; 
		SET @Lc_RelationshipToNcp_SP_CODE		= 'SP';
		SET @Lc_RelationshipToNcp_DI_CODE		= 'DI';
		SET @Lc_RelationshipToNcp_WO_CODE		= 'WO';
		SET @Lc_RelationshipToNcp_CU_CODE		= 'CU';
		SET @Lc_RelationshipToNcp_MA_CODE		= 'MA';
		SET @Lc_CaseRelationship_C_CODE			= 'C';
		
		SET @Ls_Sql_TEXT = 'SELECT APCS_Y1 ';
		SET @Ls_Sqldata_TEXT = ' Applcation_IDNO = ' + CAST(ISNULL(@An_Application_IDNO, 0) AS VARCHAR(15));
		 
		INSERT INTO #NoticeElementsData_P1(Element_NAME,Element_Value)
			 (SELECT Element_NAME, Element_Value FROM  
			   (   
			   SELECT    
				CAST(a.CP_RelationshipToNcp_Code_NM AS VARCHAR(100))    cp_relationshipToNcp_nm_code,
				CAST(a.CP_RelationshipToNcp_Code_MA AS VARCHAR(100))    cp_relationshipToNcp_ma_code,
				CAST(a.CP_RelationshipToNcp_Code_SP AS VARCHAR(100))    cp_relationshipTtoNcp_sp_code,
				CAST(a.CP_RelationshipToNcp_Code_DI  AS VARCHAR(100))   cp_relationshipTtoNcp_di_code,
				CAST(a.CP_RelationshipToNcp_Code_WOCU AS VARCHAR(100))  cp_relationshipTtoNcp_wocu_code,
				CAST(a.CPRelationshipToNcp_CODE AS VARCHAR(100))		cpRelationshipToNcp_text
			   FROM   
				( SELECT  
						(CASE WHEN m.CpRelationshipToNcp_CODE = @Lc_RelationshipToNcp_NM_CODE 
								THEN @Lc_CheckBox1_X_TEXT 
							  ELSE @Lc_Empty_TEXT 
						 END) CP_RelationshipToNcp_Code_NM,
						(CASE WHEN m.CpRelationshipToNcp_CODE = @Lc_RelationshipToNcp_MA_CODE 
								THEN @Lc_CheckBox1_X_TEXT 
							  ELSE @Lc_Empty_TEXT 
					     END) CP_RelationshipToNcp_Code_MA,
						(CASE WHEN m.CpRelationshipToNcp_CODE = @Lc_RelationshipToNcp_SP_CODE 
								THEN @Lc_CheckBox1_X_TEXT 
							  ELSE @Lc_Empty_TEXT 
					     END) CP_RelationshipToNcp_Code_SP,
						(CASE WHEN m.CpRelationshipToNcp_CODE = @Lc_RelationshipToNcp_DI_CODE 
								THEN @Lc_CheckBox1_X_TEXT 
							  ELSE @Lc_Empty_TEXT 
						 END) CP_RelationshipToNcp_Code_DI,
						(CASE WHEN m.CpRelationshipToNcp_CODE IN (@Lc_RelationshipToNcp_WO_CODE, 
																  @Lc_RelationshipToNcp_CU_CODE) 
								THEN @Lc_CheckBox1_X_TEXT 
							  ELSE @Lc_Empty_TEXT 
						 END) CP_RelationshipToNcp_Code_WOCU,
						 (SELECT r.DescriptionValue_TEXT 
								FROM REFM_Y1 r
							WHERE r.Table_ID = @Lc_Table_ID
							  AND r.TableSub_ID = @Lc_TableSub_ID
							  AND r.Value_CODE = m.CpRelationshipToNcp_CODE) AS CPRelationshipToNcp_CODE
				FROM APCM_Y1 m
			  WHERE m.application_IDNO		= @An_Application_IDNO
				AND m.CaseRelationship_CODE	= @Lc_CaseRelationship_C_CODE
				AND m.EndValidity_DATE		= @Ld_High_DATE)A
				   ) up  
				 UNPIVOT   
				 (Element_Value FOR Element_NAME IN (
													cp_relationshipToNcp_nm_code,
													cp_relationshipToNcp_ma_code,
													cp_relationshipTtoNcp_sp_code,
													cp_relationshipTtoNcp_di_code,
													cp_relationshipTtoNcp_wocu_code,
													cpRelationshipToNcp_text
											))  
				 AS pvt);
 			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE ;
    END TRY    
    BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
    END CATCH
END    

GO
