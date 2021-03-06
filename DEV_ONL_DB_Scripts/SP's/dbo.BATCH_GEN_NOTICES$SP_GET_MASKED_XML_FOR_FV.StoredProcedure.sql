/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_GENERATE_NOTICE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV] (
 @An_Case_IDNO				NUMERIC(6),
 @Ac_Notice_ID				CHAR(8),
 @Ac_Recipient_CODE			CHAR(2),
 @Ac_Recipient_ID			CHAR(10),
 @As_XmlInput_TEXT			VARCHAR(MAX),
 @As_XmlOut_TEXT			VARCHAR(MAX)  OUTPUT,
 @Ac_Msg_CODE				VARCHAR(5)	  OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT )
AS

 BEGIN
  SET NOCOUNT ON;

  DECLARE 
	
	@Lc_StatusSuccess_CODE				CHAR,
	@Lc_StatusFailed_CODE				CHAR,
	@Lc_CaseRelationshipCp_CODE			CHAR(1) = 'C',
	@Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A',
	@Lc_CaseRelationshipPf_CODE			CHAR(1) = 'P',
	@Lc_CaseMemberActiveStatus_CODE		CHAR(1) = 'A',  	
	@Lc_StatusCaseOpen_CODE				CHAR(1) = 'O',
	@Lc_TypeCaseFoster_CODE				CHAR(1) = 'F',
	@Lc_FamilyViolenceYes_INDC			CHAR(1) = 'Y',
	@Lc_TypeCaseNonFed_CODE				CHAR(1) = 'J',
	@Lc_LessThan_CODE					CHAR(1) = '<',
	@Lc_GreaterThan_CODE				CHAR(1) = '>',
	@Lc_Mask_Value						CHAR(1) = 'X',
	@Lc_CloseBrace_CODE					CHAR(2) = '</',
	@Lc_RecipientMc_CODE				CHAR(2) = 'MC',
	@Lc_RecipientMn_CODE				CHAR(2) = 'MN',
	@Lc_Legal_Notices				    CHAR(5) = 'LEG-%',
	@Lc_NoticeEst19_ID				    CHAR(8) = 'EST-19',
	@Lc_NoticeLeg154_ID				    CHAR(8) = 'LEG-154',
	@Lc_NoticeLeg385_ID				    CHAR(8) = 'LEG-385',
	@Lc_NoticeLeg421_ID				    CHAR(8) = 'LEG-421',
	@Lc_ElemCp_TEXT						CHAR(4) = 'cp_%',
	@Lc_ElemNcp_TEXT					CHAR(5) = 'ncp_%',
	@Lc_ElemChild_TEXT					CHAR(7) = 'child_%',
	@Ls_Elem_Cp_First_NAME				VARCHAR(100) = 'cp_first_name', 
	@Ls_Elem_Cp_Last_NAME				VARCHAR(100) = 'cp_last_name', 
	@Ls_Elem_Cp_Middle_NAME				VARCHAR(100) = 'cp_middle_name', 
	@Ls_Elem_Cp_Suffix_NAME 			VARCHAR(100) = 'cp_suffix_name', 
	@Ls_Elem_Cp_Birth_DATE				VARCHAR(100) = 'cp_birth_date',
	@Ls_Elem_Ncp_First_NAME				VARCHAR(100) = 'ncp_first_name', 
	@Ls_Elem_Ncp_Last_NAME				VARCHAR(100) = 'ncp_last_name', 
	@Ls_Elem_Ncp_Middle_NAME			VARCHAR(100) = 'ncp_middle_name', 
	@Ls_Elem_Ncp_Suffix_NAME			VARCHAR(100) = 'ncp_suffix_name', 
	@Ls_Elem_Ncp_Birth_DATE				VARCHAR(100) = 'ncp_birth_date',
	@Ls_Elem_Ncp_Ssn_NUMB				VARCHAR(100) = 'ncp_ssn_numb',
	@Ls_Elem_Child_Ssn_NUMB				VARCHAR(100) = 'child_ssn_numb',
	@Ls_ProcCp_Address					VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_ADDRESS',
	@Ls_ProcCp_Dtls						VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_DETAILS',
	@Ls_ProcCpemp_Dtls					VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_CP_EMPLOYER_DTLS',
	@Ls_ProcCpPrimEmp_Dtls				VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_CP_PRIMARY_EMP_DETAILS',
	@Ls_ProcCpNcpLkc_Address			VARCHAR(100) = 'BATCH_GEN_NOTICE_CM$SP_GET_NCP_LKC_ADDRESS',
	@Ls_ProcNcpPrimEmp_Dtls				VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_NCP_PRIMARY_EMP_DETAILS',
	@Ls_ProcNcp_Dtls					VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_NCP_DETAILS',
	@Ls_ProcNcpEmp_Dtls					VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_DTLS',
	@Ls_ProcNcp_Address					VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ADDRESS',
	@Ls_Procedure_NAME					VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV',
	@Ls_Element_NAME					VARCHAR(150),
	@Ls_ElementValue_TEXT				VARCHAR(150),
	@Ls_SqlData_TEXT					VARCHAR(400),
	@Ls_Sql_TEXT						VARCHAR(1000),
	@Ls_DescriptionError_TEXT			VARCHAR(4000),
	@recipientxml_text					VARCHAR(MAX) = ' ',
	@Ls_Output_TEXT						VARCHAR(MAX),
	@FamilyViolenceTags_CUR				CURSOR;
  
  DECLARE 
	@Ln_PositionStart_NUMB				NUMERIC(10),
	@Ln_PositionEnd_NUMB				NUMERIC(10),
	@Ln_SourceLength_NUMB				NUMERIC(10),
	@Li_Error_NUMB						NUMERIC(11),
    @Li_ErrorLine_NUMB					NUMERIC(11),
	@Lc_CpFamilyViolence_INDC			CHAR(1),
	@Lc_NcpFamilyViolence_INDC			CHAR(1),
	@Ls_Source_XML						VARCHAR(MAX);
  
	SET @Lc_StatusSuccess_CODE = 'S';
	SET @Lc_StatusFailed_CODE = 'F';

  BEGIN TRY
   
   SET @Ls_Source_XML = @As_XmlInput_TEXT;
   IF ISNUMERIC(@Ac_Recipient_ID) = 1
	BEGIN
	   IF @Ac_Notice_ID LIKE @Lc_Legal_Notices OR LTRIM(RTRIM(@Ac_Notice_ID)) = @Lc_NoticeEst19_ID
		BEGIN
			SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 - 1';
			SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', CaseRelationship_CODE = ' + CAST(ISNULL(@Lc_CaseRelationshipCp_CODE, 0) AS VARCHAR(1)) +  ', Notice_ID = ' + CAST(ISNULL(@Ac_Notice_ID, 0) AS VARCHAR(8));	
			
			--13617 CR0407 Revise Mapping for Petitioner in IV-E  Cases to OTHP Records20140825 - Fix - Start
			SELECT @Lc_CpFamilyViolence_INDC = FamilyViolence_INDC
			  FROM CMEM_Y1 
			 WHERE Case_IDNO = @An_Case_IDNO
			   AND CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
			   AND CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
			   AND NOT EXISTS ( SELECT 1 FROM CASE_Y1 
									WHERE Case_IDNO = @An_Case_IDNO 
										AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE 
										AND TypeCase_CODE IN(@Lc_TypeCaseFoster_CODE,@Lc_TypeCaseNonFed_CODE) AND LTRIM(RTRIM(@Ac_Notice_ID)) LIKE @Lc_Legal_Notices)
													
			SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 - 2';
			SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', Notice_ID = ' + CAST(ISNULL(@Ac_Notice_ID, 0) AS VARCHAR(8));							
			
			SELECT @Lc_NcpFamilyViolence_INDC = FamilyViolence_INDC
			  FROM CMEM_Y1
			 WHERE Case_IDNO = @An_Case_IDNO
			   AND CaseRelationship_CODE IN(@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPf_CODE)
			   AND CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE
			   AND NOT EXISTS ( SELECT 1 FROM CASE_Y1 
									WHERE Case_IDNO = @An_Case_IDNO 
										AND StatusCase_CODE = @Lc_StatusCaseOpen_CODE
										AND TypeCase_CODE IN(@Lc_TypeCaseFoster_CODE,@Lc_TypeCaseNonFed_CODE) AND LTRIM(RTRIM(@Ac_Notice_ID)) LIKE @Lc_Legal_Notices)
			--13617 CR0407 Revise Mapping for Petitioner in IV-E  Cases to OTHP Records20140825 - Fix - End
	
		   SET @Ls_Sql_TEXT = 'SELECT FamilyViolenceTags_CUR -1';
		   SET @FamilyViolenceTags_CUR = CURSOR FOR
				SELECT DISTINCT Element_NAME
				  FROM NDEL_Y1 
				 WHERE Procedure_NAME IN (@Ls_ProcCp_Address, @Ls_ProcCp_Dtls, @Ls_ProcCpemp_Dtls,@Ls_ProcCpPrimEmp_Dtls,@Ls_ProcCpNcpLkc_Address,@Ls_ProcNcpPrimEmp_Dtls,@Ls_ProcNcp_Dtls,@Ls_ProcNcpEmp_Dtls,@Ls_ProcNcp_Address)
				   AND (LTRIM(RTRIM(Notice_ID)) LIKE @Lc_Legal_Notices OR LTRIM(RTRIM(Notice_ID)) = @Lc_NoticeEst19_ID)
				   AND LTRIM(RTRIM(Notice_ID)) NOT IN (@Lc_NoticeLeg154_ID,@Lc_NoticeLeg385_ID, @Lc_NoticeLeg421_ID)
				   AND LTRIM(RTRIM(Element_NAME)) NOT IN (@Ls_Elem_Cp_First_NAME, @Ls_Elem_Cp_Last_NAME, @Ls_Elem_Cp_Middle_NAME, @Ls_Elem_Cp_Suffix_NAME, @Ls_Elem_Cp_Birth_DATE,@Ls_Elem_Ncp_First_NAME, @Ls_Elem_Ncp_Last_NAME, @Ls_Elem_Ncp_Middle_NAME, @Ls_Elem_Ncp_Suffix_NAME, @Ls_Elem_Ncp_Birth_DATE)
				 UNION
				SELECT @Ls_Elem_Ncp_Ssn_NUMB AS Element_NAME
				 UNION
				SELECT @Ls_Elem_Child_Ssn_NUMB AS Element_NAME;
				
		   SET  @Ls_Sql_TEXT = 'OPEN FamilyViolenceTags_CUR -1';					   
		   OPEN @FamilyViolenceTags_CUR;
		   
		   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FamilyViolenceTags_CUR - 1'; 		
		   FETCH NEXT FROM @FamilyViolenceTags_CUR INTO @Ls_Element_NAME;
		   WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @Ln_PositionStart_numb = 0;
				SET @Ln_PositionEnd_NUMB = 0;
				SET @Ln_SourceLength_NUMB = LEN(@Ls_Source_XML);
				
				SET @Ln_PositionStart_numb = CHARINDEX(@Lc_LessThan_CODE+@Ls_Element_NAME+@Lc_GreaterThan_CODE, @Ls_Source_XML, @Ln_positionStart_NUMB);
				
				WHILE @Ln_PositionStart_numb != 0
					BEGIN
						SET @Ln_PositionEnd_numb = CHARINDEX(@Lc_CloseBrace_CODE+@Ls_Element_NAME+@Lc_GreaterThan_CODE, @Ls_Source_XML, @Ln_positionStart_NUMB);
						
						SET @Ls_ElementValue_TEXT = SUBSTRING(@Ls_Source_XML, @Ln_PositionStart_numb + LEN(@Ls_Element_NAME) + 2, ((@Ln_PositionEnd_numb) - (@Ln_PositionStart_numb + LEN(@Ls_Element_NAME) + 2))) + '~';
						
						IF (	(@Lc_NcpFamilyViolence_INDC = @Lc_FamilyViolenceYes_INDC AND @Ls_Element_NAME LIKE @Lc_ElemNcp_TEXT)
      						 OR (@Lc_CpFamilyViolence_INDC = @Lc_FamilyViolenceYes_INDC AND (@Ls_Element_NAME LIKE @Lc_ElemCp_TEXT OR @Ls_Element_NAME LIKE @Lc_ElemChild_TEXT))
        				   )
							BEGIN
								SET @Ls_Source_XML = SUBSTRING(@Ls_Source_XML, 1, @Ln_PositionStart_numb + LEN(@Ls_Element_NAME) + 1) + 
													 dbo.BATCH_GEN_NOTICES$SF_GET_MASKED_DATA(@Ls_ElementValue_TEXT, @Lc_Mask_Value)
													 + SUBSTRING(@Ls_Source_XML, @Ln_PositionEnd_numb, (@Ln_SourceLength_NUMB - @Ln_PositionEnd_numb) + 1);
							END
						SET  @Ln_PositionStart_numb = @Ln_PositionStart_numb + LEN(@Lc_LessThan_CODE+@Ls_Element_NAME+@Lc_GreaterThan_CODE);
						SET @Ln_PositionStart_numb = CHARINDEX(@Lc_LessThan_CODE+@Ls_Element_NAME+@Lc_GreaterThan_CODE, @Ls_Source_XML, @Ln_PositionStart_numb);	
					END
				FETCH NEXT FROM @FamilyViolenceTags_CUR INTO @Ls_Element_NAME;
			END
			CLOSE @FamilyViolenceTags_CUR;
			DEALLOCATE @FamilyViolenceTags_CUR;
		END
	   ELSE
		BEGIN
			
			SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 - 3';
			SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', CaseRelationship_CODE = ' + CAST(ISNULL(@Lc_CaseRelationshipCp_CODE, 0) AS VARCHAR(1)) + ', Notice_ID = ' + CAST(ISNULL(@Ac_Notice_ID, 0) AS VARCHAR(8));	
			SELECT @Lc_CpFamilyViolence_INDC = FamilyViolence_INDC  
				FROM CMEM_Y1  
				WHERE Case_IDNO = @An_Case_IDNO  
				AND CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE  
				AND CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE; 
				 
			SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 - 4';
			SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', Notice_ID = ' + CAST(ISNULL(@Ac_Notice_ID, 0) AS VARCHAR(8));	
			SELECT @Lc_NcpFamilyViolence_INDC = FamilyViolence_INDC  
				FROM CMEM_Y1  
				WHERE Case_IDNO = @An_Case_IDNO  
				AND CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE  
				AND CaseMemberStatus_CODE = @Lc_CaseMemberActiveStatus_CODE;
			
			SET @Ls_Sql_TEXT = 'SELECT FamilyViolenceTags_CUR -2';
			SET @FamilyViolenceTags_CUR = CURSOR FOR
				SELECT @Ls_Elem_Child_Ssn_NUMB as Element_NAME;
			
			SET  @Ls_Sql_TEXT = 'OPEN FamilyViolenceTags_CUR -2';
			OPEN @FamilyViolenceTags_CUR;
			
			SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FamilyViolenceTags_CUR - 2';
		   FETCH NEXT FROM @FamilyViolenceTags_CUR INTO @Ls_Element_NAME;

		   WHILE @@FETCH_STATUS = 0
			BEGIN
				
				SET @Ln_PositionStart_numb = 0;
				SET @Ln_PositionEnd_NUMB = 0;
				SET @Ln_SourceLength_NUMB = LEN(@Ls_Source_XML);
				
				SET @Ln_PositionStart_numb = CHARINDEX(@Lc_LessThan_CODE+@Ls_Element_NAME+@Lc_GreaterThan_CODE, @Ls_Source_XML, @Ln_positionStart_NUMB);
				
				WHILE @Ln_PositionStart_numb != 0
					BEGIN
						SET @Ln_PositionEnd_numb = CHARINDEX(@Lc_CloseBrace_CODE+@Ls_Element_NAME+@Lc_GreaterThan_CODE, @Ls_Source_XML, @Ln_positionStart_NUMB);
						
						SET @Ls_ElementValue_TEXT = SUBSTRING(@Ls_Source_XML, @Ln_PositionStart_numb + LEN(@Ls_Element_NAME) + 2, ((@Ln_PositionEnd_numb) - (@Ln_PositionStart_numb + LEN(@Ls_Element_NAME) + 2))) + '~';
						
						IF (	(@Lc_NcpFamilyViolence_INDC = @Lc_FamilyViolenceYes_INDC AND @Ac_Recipient_CODE = @Lc_RecipientMc_CODE AND @Ls_Element_NAME LIKE @Lc_ElemNcp_TEXT)
							OR  (@Lc_CpFamilyViolence_INDC = @Lc_FamilyViolenceYes_INDC AND @Ac_Recipient_CODE = @Lc_RecipientMn_CODE AND (@Ls_Element_NAME LIKE @Lc_ElemCp_TEXT OR @Ls_Element_NAME LIKE @Lc_ElemChild_TEXT))
						   )
							BEGIN
								SET @Ls_Source_XML = SUBSTRING(@Ls_Source_XML, 1, @Ln_PositionStart_numb + LEN(@Ls_Element_NAME) + 1) + 
													 dbo.BATCH_GEN_NOTICES$SF_GET_MASKED_DATA(@Ls_ElementValue_TEXT, @Lc_Mask_Value)
													 + SUBSTRING(@Ls_Source_XML, @Ln_PositionEnd_numb, (@Ln_SourceLength_NUMB - @Ln_PositionEnd_numb) + 1);
							END
						SET  @Ln_PositionStart_numb = @Ln_PositionStart_numb + LEN(@Lc_LessThan_CODE+@Ls_Element_NAME+@Lc_GreaterThan_CODE);
						SET @Ln_PositionStart_numb = CHARINDEX(@Lc_LessThan_CODE+@Ls_Element_NAME+@Lc_GreaterThan_CODE, @Ls_Source_XML, @Ln_PositionStart_numb);	
					END
				FETCH NEXT FROM @FamilyViolenceTags_CUR INTO @Ls_Element_NAME;
			END
			CLOSE @FamilyViolenceTags_CUR;
			DEALLOCATE @FamilyViolenceTags_CUR;
		END
	   
	   SET @As_XmlOut_TEXT = @Ls_Source_XML;
	END
   ELSE
    BEGIN
		SET @As_XmlOut_TEXT = @As_XmlInput_TEXT;
    END
	
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
  
    IF CURSOR_STATUS ('LOCAL', '@FamilyViolenceTags_CUR') IN (0, 1)
    BEGIN
     CLOSE @FamilyViolenceTags_CUR
     
     DEALLOCATE @FamilyViolenceTags_CUR
    END	
    
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
   
  END CATCH
 END


GO
