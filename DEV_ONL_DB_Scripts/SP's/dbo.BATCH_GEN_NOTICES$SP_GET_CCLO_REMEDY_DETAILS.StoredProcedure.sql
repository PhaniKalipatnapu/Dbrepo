/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CCLO_REMEDY_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_CCLO_REMEDY_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get the active cclo activity from DMJR table
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CCLO_REMEDY_DETAILS]
	@An_Case_IDNO				NUMERIC(6),
	@Ac_Msg_CODE				CHAR (5) OUTPUT,
	@As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
AS
BEGIN
	SET NOCOUNT ON; 
	DECLARE 
       @Li_Error_NUMB			INT = ERROR_NUMBER (),
	   @Li_ErrorLine_NUMB		INT =  ERROR_LINE (),
	   @Lc_StatusFailed_CODE   CHAR = 'F',
	   @Lc_StatusSuccess_CODE  CHAR = 'S',
	   @Lc_ActivityMajor_CODE  CHAR(4) = 'CCLO',
	   @Lc_Status_CODE         CHAR(4) = 'STRT',
	   @Ls_Routine_TEXT        VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_CCLO_REMEDY_DETAILS';
	   
	DECLARE  @Ls_Sql_TEXT              VARCHAR(100),
	   @Ls_Sqldata_TEXT          VARCHAR(1000),
	   @Ls_Err_Description_TEXT  VARCHAR(4000);
		
		BEGIN TRY 
			SET @Ac_Msg_CODE = '';
			SET @As_DescriptionError_TEXT = '';
			SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_CCLO_REMEDY_DETAILS';
			SET   @Ls_Sqldata_TEXT	= 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');
			
			 INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                ELEMENT_VALUE)
				   (SELECT tag_name,
						   tag_value
					  FROM( SELECT CONVERT(VARCHAR(MAX), case_closure_reason) AS case_closure_reason_text,
							CONVERT(VARCHAR(MAX), fed_cit_closure_cd) AS fed_cit_closure_text 
							FROM (SELECT CASE 
										WHEN Reference_ID = 'NH' THEN
											'There is no longer a current support order and arrears are under $500 or unenforceable under state law.'						
										WHEN Reference_ID IN ('PB','FN') THEN
											'The non-custodial or putative father is deceased and no further action can be taken.'					
										WHEN Reference_ID IN ('PC','PK','PQ','PR') THEN
											'Paternity cannot be established.'						
										WHEN Reference_ID IN ('UB','UC') THEN
											'The non-custodial parent''s location is unknown and cannot be verified despite diligent efforts by DCSE.'	
										WHEN Reference_ID = 'IK' THEN
										    'The non-custodial parent is unable to pay child support for the duration of the child''s minority due to incarceration, institutionalization, or permanent disability.'					
										WHEN Reference_ID IN ('SN','UM') THEN
											'The non-custodial parent resides in, or is a citizen of a foreign country in which there is no reciprocity for the establishment and/or enforcement of child support.'					
										WHEN Reference_ID = 'IJ' THEN
										'DCSE has provided location-only services as requested.'						
									WHEN Reference_ID IN('IS','IU') THEN
										'There is no assignment to the State of medical support or support arrears, and case closure has been requested.'						
									WHEN Reference_ID = 'GV' THEN
										'There has been a finding of good cause and support services cannot proceed without possible harm to the child and/or caretaker.'						
									WHEN Reference_ID = 'UV' THEN
										'Cooperation is required to proceed with child support services, but DCSE has been unable to contact the custodial parent, despite at least one attempt via letter.'						
									WHEN Reference_ID = 'DI' THEN
										'Cooperation is required to proceed with child support services, but cooperation with DCSE is not required from the recipient of state assistance.'						
									WHEN Reference_ID = 'II' THEN
										'The initiating state has failed to take necessary action for DCSE to proceed with services.'
									ELSE ' ' END AS  case_closure_reason, 
								CASE 
									WHEN Reference_ID = 'NH' THEN
										'303.11(b)(1)'						
									WHEN Reference_ID IN ('PB','FN') THEN
										'303.11(b)(2)'						
									WHEN Reference_ID IN ('PC','PK','PQ','PR') THEN
										'303.11(b)(3)'						
									WHEN Reference_ID IN ('UB','UC') THEN
										'303.11(b)(4)'	
									WHEN Reference_ID = 'IK' THEN 
										'303.11(b)(5)'					
									--WHEN Reference_ID = 'DI' THEN 
										--'303.11(b)(5)'						
									WHEN Reference_ID IN ('SN','UM') THEN
										'303.11(b)(6)'						
									WHEN Reference_ID = 'IJ' THEN
										'303.11(b)(7)'						
									WHEN Reference_ID IN('IS','IU') THEN
										'303.11(b)(8)'						
									WHEN Reference_ID = 'GV' THEN
										'303.11(b)(9)'						
									WHEN Reference_ID = 'UV' THEN
										'303.11(b)(10)'						
									WHEN Reference_ID = 'DI' THEN
										'303.11(b)(11)'						
									WHEN Reference_ID = 'II' THEN
										'303.11(b)(12)'
									ELSE ' ' END AS fed_cit_closure_cd
								FROM DMJR_Y1 D
							WHERE Case_IDNO = @An_Case_IDNO AND
								ActivityMajor_CODE = @Lc_ActivityMajor_CODE AND
								Status_CODE = @Lc_Status_CODE )a ) up UNPIVOT (tag_value FOR tag_name IN (case_closure_reason_text, fed_cit_closure_text)) AS pvt);
		
		SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;			
	END TRY		
	BEGIN CATCH					
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
