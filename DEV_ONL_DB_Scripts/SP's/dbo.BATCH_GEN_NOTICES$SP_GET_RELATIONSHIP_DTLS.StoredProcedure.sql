/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_RELATIONSHIP_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_GEN_NOTICES$SP_GET_RELATIONSHIP_DTLS
Programmer Name		: IMP Team
Description 	    : This procedure is used to get Case members relationships to child.
Frequency			:
Developed On		: 01/20/2011
Called By			: BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On	        : 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_RELATIONSHIP_DTLS]
 @An_Case_IDNO             NUMERIC( 6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
 DECLARE  @Lc_Empty_TEXT							CHAR(1) = '',
		  @Lc_StatusFailed_CODE 					CHAR(1) = 'F',
		  @Lc_StatusSuccess_CODE 					CHAR(1) = 'S',
		  @Lc_CaseRelationship_CODE					CHAR(1) = 'D',
		  @Lc_CaseMemberStatusActive_CODE			CHAR(1) = 'A',
		  @Lc_CheckBox_CODE							CHAR(1) = 'X',
		  @Lc_RelationshipToChildMtr_CODE			CHAR(3) = 'MTR', 
		  @Lc_RelationshipToChildFtr_CODE			CHAR(3) = 'FTR',
		  @Lc_CpRelationShipToChildFmly_CODE		CHAR(4) = 'FMLY',
		  @Lc_CpRelationShipToChildRela_CODE		CHAR(4) = 'RELA',
		  @Ls_Procedure_NAME						VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_RELATIONSHIP_DTLS';
  DECLARE @Ln_Error_NUMB							NUMERIC(11),
	      @Ln_ErrorLine_NUMB						NUMERIC(11),
		  @Ls_sql_TEXT 								VARCHAR(200),
		  @Ls_Sqldata_TEXT 							VARCHAR(400),
		  @Ls_DescriptionError_TEXT					VARCHAR(4000);
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNo, 0) AS VARCHAR);

   INSERT INTO #NoticeElementsData_P1
               (Element_Name,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT TOP 1 CONVERT(VARCHAR(100), CP_MOTHER_INDC) CP_MOTHER_INDC,
                   CONVERT(VARCHAR(100), CP_FATHER_INDC) CP_FATHER_INDC,
                   CONVERT(VARCHAR(100), CP_OTHER_SEL_INDC) CP_OTHER_SEL_INDC,
                   CONVERT(VARCHAR(100), REL_CP_TO_DEPENDENT_TEXT) REL_CP_TO_DEPENDENT_TEXT,
                   CONVERT(VARCHAR(100), NCP_MOTHER_INDC) NCP_MOTHER_INDC,
                   CONVERT(VARCHAR(100), NCP_FATHER_INDC) NCP_FATHER_INDC,
                   CONVERT(VARCHAR(100), CpRelationshipToChild_TEXT)  CpRelationshipToChild_TEXT,
                   CONVERT(VARCHAR(100), NCpRelationshipToChild_TEXT) NCpRelationshipToChild_TEXT
              FROM (SELECT  CASE
                            WHEN c.CpRelationshipToChild_CODE = @Lc_RelationshipToChildMtr_CODE
                             THEN @Lc_CheckBox_CODE
                            ELSE @Lc_Empty_TEXT
                           END CP_MOTHER_INDC,
                           CASE
                            WHEN c.CpRelationshipToChild_CODE = @Lc_RelationshipToChildFtr_CODE
                             THEN @Lc_CheckBox_CODE
                            ELSE @Lc_Empty_TEXT
                           END CP_FATHER_INDC,
                           CASE
                            WHEN c.CpRelationShipToChild_CODE NOT IN(@Lc_RelationshipToChildMtr_CODE, @Lc_RelationshipToChildFtr_CODE)
                             THEN @Lc_CheckBox_CODE
                            ELSE @Lc_Empty_TEXT
                           END CP_OTHER_SEL_INDC,
                           CASE
                            WHEN c.CpRelationShipToChild_CODE NOT IN(@Lc_RelationshipToChildMtr_CODE, @Lc_RelationshipToChildFtr_CODE)
                             THEN dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_CpRelationShipToChildFmly_CODE, @Lc_CpRelationShipToChildRela_CODE, CpRelationShipToChild_CODE)
                            ELSE @Lc_Empty_TEXT
                           END REL_CP_TO_DEPENDENT_TEXT,
                           dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_CpRelationShipToChildFmly_CODE, @Lc_CpRelationShipToChildRela_CODE, cpRelationshipToChild_CODE) CpRelationshipToChild_TEXT,
                           CASE
                            WHEN NcpRelationshipToChild_CODE = @Lc_RelationshipToChildMtr_CODE
                             THEN @Lc_CheckBox_CODE
                            ELSE @Lc_Empty_TEXT
                           END NCP_MOTHER_INDC,
                           CASE
                            WHEN NcpRelationshipToChild_CODE = @Lc_RelationshipToChildFtr_CODE
                             THEN @Lc_CheckBox_CODE
                            ELSE @Lc_Empty_TEXT
                           END NCP_FATHER_INDC,
                           dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_CpRelationShipToChildFmly_CODE, @Lc_CpRelationShipToChildRela_CODE, NcpRelationshipToChild_CODE) NCpRelationshipToChild_TEXT
                      FROM 
                           CMEM_Y1 c
                     WHERE c.CaseRelationship_CODE = @Lc_CaseRelationship_CODE
					 --13660 - LEG-329L populating with inactive child details Fix - Start
					   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE	
					 --13660 - LEG-329L populating with inactive child details Fix - End
                       AND c.Case_IDNO = @An_Case_IDNO)a) up 
			UNPIVOT (tag_value FOR tag_name IN (CP_MOTHER_INDC, 
												CP_FATHER_INDC, 
												CP_OTHER_SEL_INDC, 
												REL_CP_TO_DEPENDENT_TEXT, 
												NCP_MOTHER_INDC, 
												NCP_FATHER_INDC,
												CpRelationshipToChild_TEXT,
												NCpRelationshipToChild_TEXT  )) AS pvt)
;

       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
     
       END TRY
       
         BEGIN CATCH
				SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
   			    	   @Ln_Error_NUMB = ERROR_NUMBER(),
   					   @Ln_ErrorLine_NUMB = ERROR_LINE(),
   				       @Ls_DescriptionError_TEXT = 'INSERT_#NoticeElementsData_P1 FAILED'; 
   				       
   	IF (@Ln_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END  	  				       
					 EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    					@As_Procedure_NAME        = @Ls_Procedure_NAME,
    					@As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    					@As_Sql_TEXT              = @Ls_sql_TEXT,
    					@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    					@An_Error_NUMB            = @Ln_Error_NUMB,
    					@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    					@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
				SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
		END CATCH
END

GO
