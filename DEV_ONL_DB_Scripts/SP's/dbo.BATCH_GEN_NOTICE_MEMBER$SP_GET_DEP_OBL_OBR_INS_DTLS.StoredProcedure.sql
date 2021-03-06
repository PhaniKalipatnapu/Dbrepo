/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_DEP_OBL_OBR_INS_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_DEP_OBL_OBR_INS_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_DEP_OBL_OBR_INS_DTLS]
(
	 @An_Case_IDNO				NUMERIC(6),
	 @Ad_RUN_DATE				DATE,
	 @Ac_Msg_CODE				CHAR(5) OUTPUT,
	 @As_DescriptionError_TEXT	VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

   DECLARE @Lc_StatusCaseMemberActive_CODE  CHAR(1) = 'A',
           @Lc_InsuranceOrderedCpOnly_TEXT  CHAR(1) = 'C',
           @Lc_Space_TEXT                   CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Lc_InsOrdered_B_TEXT            CHAR(1) = 'B',
           @Lc_InsOrdered_D_TEXT            CHAR(1) = 'D',
           @Lc_InsOrdered_A_TEXT            CHAR(1) = 'A',
           @Lc_InsOrdered_U_TEXT            CHAR(1) = 'U',
           @Lc_InsOrdered_C_TEXT            CHAR(1) = 'C',
           @Lc_InsOrdered_O_TEXT            CHAR(1) = 'O',
           @Lc_RelationshipCaseDp_TEXT      CHAR(1) = 'D',
           @Lc_CheckBoxX1_TEXT              CHAR(1) = 'X',
           @Lc_Status_CODE                  CHAR(1) = 'Y',
           @Lc_Employer_INDC                CHAR(1) = 'N',
           @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_OBL_OBR_INS_DTLS ',
           @Ld_High_DATE                    DATE = '12/31/9999';
           
  DECLARE  @Ln_Value_QNTY					INT,
           @Lc_CoverageChildOblrX1_TEXT		CHAR(1),
           @Lc_CoverageChildObleX1_TEXT		CHAR(1),
           @Ls_Sql_TEXT						VARCHAR(200),
           @Ls_Sqldata_TEXT					VARCHAR(400);

  BEGIN TRY
   SET @Lc_CoverageChildOblrX1_TEXT = '';
   SET @Lc_CoverageChildObleX1_TEXT = '';
   
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
 
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6))
   SET @Ls_Sql_TEXT = 'SELECT VCMEM_VSORD_VMINS_VDINS:'
 
     SELECT @Ln_Value_QNTY = COUNT(1)
       FROM MINS_Y1 M
      WHERE M.MemberMci_IDNO IN (SELECT a.MemberMci_IDNO
                                         FROM DINS_Y1 AS a
                                        WHERE a.ChildMCI_IDNO IN (SELECT c.MemberMci_IDNO
                                                                    FROM CMEM_Y1 AS c,
                                                                         SORD_Y1 AS s
                                                                   WHERE c.Case_IDNO = @An_Case_IDNO
                                                                     AND c.Case_IDNO = s.Case_IDNO
                                                                     AND s.CoverageMedical_CODE IN (@Lc_InsOrdered_B_TEXT,@Lc_InsOrdered_D_TEXT, 
																									@Lc_InsOrdered_A_TEXT,@Lc_InsOrdered_U_TEXT)
                                                                     AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                                                                     AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                                                     AND s.EndValidity_DATE = @Ld_High_DATE)
                                          AND a.EndValidity_DATE = @Ld_High_DATE)
		AND M.EmployerPaid_INDC != 'Y'
        AND M.EndValidity_DATE = @Ld_High_DATE;
    
    IF @Ln_Value_QNTY > 0 
     BEGIN
      SET @Lc_CoverageChildOblrX1_TEXT = @Lc_CheckBoxX1_TEXT;
      SET @Lc_CoverageChildObleX1_TEXT = @Lc_Space_TEXT;
     END
    ELSE
     BEGIN
      SET @Lc_CoverageChildOblrX1_TEXT = @Lc_Space_TEXT;
      SET @Lc_CoverageChildObleX1_TEXT = @Lc_Space_TEXT;
     END
    
		INSERT INTO #NoticeElementsData_P1
					   (Element_NAME,
						Element_Value)
		   (SELECT tag_name,
				   tag_value
			  FROM (SELECT CONVERT(VARCHAR(100), FOR_DEP_OBLIGOR_CODE) FOR_DEP_OBLIGOR_CODE
					  FROM (SELECT @Lc_CoverageChildOblrX1_TEXT AS FOR_DEP_OBLIGOR_CODE) h)up 
			UNPIVOT (tag_value FOR tag_name IN ( FOR_DEP_OBLIGOR_CODE )) AS pvt);
			
			
			SELECT @Ln_Value_QNTY = COUNT(1)
			   FROM MINS_Y1 M
			  WHERE M.MemberMci_IDNO IN (SELECT a.MemberMci_IDNO
												 FROM DINS_Y1 AS a
												WHERE a.ChildMCI_IDNO IN (SELECT c.MemberMci_IDNO
																			FROM CMEM_Y1 AS c,
																				 SORD_Y1 AS s
																		   WHERE c.Case_IDNO = @An_Case_IDNO
																			 AND c.Case_IDNO = s.Case_IDNO
																			 AND s.CoverageMedical_CODE IN (@Lc_InsOrdered_B_TEXT,@Lc_InsOrdered_D_TEXT, @Lc_InsOrdered_A_TEXT,@Lc_InsOrdered_U_TEXT)
																			 AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
																			 AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
																			 AND s.EndValidity_DATE = @Ld_High_DATE)
												  AND a.EndValidity_DATE = @Ld_High_DATE)
				AND EmployerPaid_INDC = 'Y'
				AND EXISTS(SELECT 1 FROM EHIS_Y1 E 
								WHERE E.MemberMCI_IDNO = M.MemberMCI_IDNO 
								  AND E.OthpPartyEmpl_IDNO = M.OthpEmployer_IDNO 
								  AND @Ad_RUN_DATE BETWEEN E.BeginEmployment_DATE AND E.EndEmployment_DATE 
								  AND Status_CODE = @Lc_Status_CODE)
				AND M.EndValidity_DATE = @Ld_High_DATE;
    
    SET @Lc_CoverageChildOblrX1_TEXT = '';
    SET @Lc_CoverageChildObleX1_TEXT = '';

    IF @Ln_Value_QNTY > 0 
     BEGIN
      SET @Lc_CoverageChildOblrX1_TEXT = @Lc_CheckBoxX1_TEXT;
      SET @Lc_CoverageChildObleX1_TEXT = @Lc_Space_TEXT;
     END
    ELSE
     BEGIN
      SET @Lc_CoverageChildOblrX1_TEXT = @Lc_Space_TEXT;
      SET @Lc_CoverageChildObleX1_TEXT = @Lc_Space_TEXT;
     END
    
    INSERT INTO #NoticeElementsData_P1
					   (Element_NAME,
						Element_Value)
		   (SELECT tag_name,
				   tag_value
			  FROM (SELECT CONVERT(VARCHAR(100), FOR_DEP_OBLIGOR_EMP_CODE) FOR_DEP_OBLIGOR_EMP_CODE
					  FROM (SELECT @Lc_CoverageChildOblrX1_TEXT AS FOR_DEP_OBLIGOR_EMP_CODE) h)up 
			UNPIVOT (tag_value FOR tag_name IN ( FOR_DEP_OBLIGOR_EMP_CODE )) AS pvt);
    
    -- OBLIGEE
     SELECT @Ln_Value_QNTY = COUNT(1)
       FROM MINS_Y1 M
      WHERE M.MemberMci_IDNO IN (SELECT a.MemberMci_IDNO
                                         FROM DINS_Y1 AS a
                                        WHERE a.ChildMCI_IDNO IN (SELECT c.MemberMci_IDNO
                                                                    FROM CMEM_Y1 AS c,
                                                                         SORD_Y1 AS s
                                                                   WHERE c.Case_IDNO = @An_Case_IDNO
                                                                     AND c.Case_IDNO = s.Case_IDNO
                                                                     AND s.CoverageMedical_CODE IN (@Lc_InsOrdered_B_TEXT,@Lc_InsOrdered_D_TEXT, 
																									@Lc_InsOrdered_C_TEXT,@Lc_InsOrdered_O_TEXT)
                                                                     AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                                                                     AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                                                                     AND s.EndValidity_DATE = @Ld_High_DATE)
                                          AND a.EndValidity_DATE = @Ld_High_DATE)
        AND M.EmployerPaid_INDC != 'Y'
        AND M.EndValidity_DATE = @Ld_High_DATE;


    SET @Lc_CoverageChildOblrX1_TEXT = '';
    SET @Lc_CoverageChildObleX1_TEXT = '';
    
    IF @Ln_Value_QNTY > 0 
     BEGIN
      SET @Lc_CoverageChildOblrX1_TEXT = @Lc_CheckBoxX1_TEXT;
      SET @Lc_CoverageChildObleX1_TEXT = @Lc_Space_TEXT;
     END
    ELSE
     BEGIN
      SET @Lc_CoverageChildOblrX1_TEXT = @Lc_Space_TEXT;
      SET @Lc_CoverageChildObleX1_TEXT = @Lc_Space_TEXT;
     END
    
		INSERT INTO #NoticeElementsData_P1
					   (Element_NAME,
						Element_Value)
		   (SELECT tag_name,
				   tag_value
			  FROM (SELECT CONVERT(VARCHAR(100), FOR_DEP_OBLIGEE_CODE) FOR_DEP_OBLIGEE_CODE
					  FROM (SELECT @Lc_CoverageChildOblrX1_TEXT AS FOR_DEP_OBLIGEE_CODE) h)up 
			UNPIVOT (tag_value FOR tag_name IN ( FOR_DEP_OBLIGEE_CODE )) AS pvt);
      
      
      	SELECT @Ln_Value_QNTY = COUNT(1)
			   FROM MINS_Y1 M
			  WHERE M.MemberMci_IDNO IN (SELECT a.MemberMci_IDNO
												 FROM DINS_Y1 AS a
												WHERE a.ChildMCI_IDNO IN (SELECT c.MemberMci_IDNO
																			FROM CMEM_Y1 AS c,
																				 SORD_Y1 AS s
																		   WHERE c.Case_IDNO = @An_Case_IDNO
																			 AND c.Case_IDNO = s.Case_IDNO
																			 AND s.CoverageMedical_CODE IN (@Lc_InsOrdered_B_TEXT,@Lc_InsOrdered_D_TEXT, 
																											@Lc_InsOrdered_C_TEXT,@Lc_InsOrdered_O_TEXT)
																			 AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
																			 AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
																			 AND s.EndValidity_DATE = @Ld_High_DATE)
												  AND a.EndValidity_DATE = @Ld_High_DATE)
				AND EmployerPaid_INDC = 'Y'
				AND EXISTS(SELECT 1 FROM EHIS_Y1 E 
								WHERE E.MemberMCI_IDNO = M.MemberMCI_IDNO 
								  AND E.OthpPartyEmpl_IDNO = M.OthpEmployer_IDNO 
								  AND @Ad_RUN_DATE BETWEEN E.BeginEmployment_DATE AND E.EndEmployment_DATE 
								  AND Status_CODE = @Lc_Status_CODE)
				AND M.EndValidity_DATE = @Ld_High_DATE;

    SET @Lc_CoverageChildOblrX1_TEXT = '';
    SET @Lc_CoverageChildObleX1_TEXT = '';
    
    IF @Ln_Value_QNTY > 0 
     BEGIN
      SET @Lc_CoverageChildOblrX1_TEXT = @Lc_CheckBoxX1_TEXT;
      SET @Lc_CoverageChildObleX1_TEXT = @Lc_Space_TEXT;
     END
    ELSE
     BEGIN
      SET @Lc_CoverageChildOblrX1_TEXT = @Lc_Space_TEXT;
      SET @Lc_CoverageChildObleX1_TEXT = @Lc_Space_TEXT;
     END
    
    INSERT INTO #NoticeElementsData_P1
					   (Element_NAME,
						Element_Value)
		   (SELECT tag_name,
				   tag_value
			  FROM (SELECT CONVERT(VARCHAR(100), FOR_DEP_OBLIGEE_EMP_CODE) FOR_DEP_OBLIGEE_EMP_CODE
					  FROM (SELECT @Lc_CoverageChildOblrX1_TEXT AS FOR_DEP_OBLIGEE_EMP_CODE) h)up 
			UNPIVOT (tag_value FOR tag_name IN ( FOR_DEP_OBLIGEE_EMP_CODE )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE (),
            @Ls_DescriptionError_TEXT VARCHAR (4000);

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
END

GO
