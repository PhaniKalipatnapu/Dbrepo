/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS]
(
 @An_MemberMci_IDNO NUMERIC(10),
 @An_Case_IDNO      NUMERIC(6),
 @Ac_Parent_INDC    CHAR(1),
 @Ac_Msg_CODE       CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT     VARCHAR(4000) OUTPUT
)
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_Space_TEXT						CHAR(1)			= ' ',
           @Lc_VerificationStatusGood_CODE		CHAR(1)			= 'Y',
           @Lc_VerificationStatusPending_CODE	CHAR(1)			= 'P',
           @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
           @Lc_StatusFailed_CODE				CHAR(1)			= 'F',
           @Lc_CheckBoxX_TEXT					CHAR(1)			= 'X',
           @Ls_PrimResidence_ADDR				CHAR(1)			= 'M',
           @Lc_RelationshipToChildF_CODE		CHAR(1)			= 'F',
           @Lc_RelationshipToChildM_CODE		CHAR(1)			= 'M',
           @Lc_RelationshipToChildG_CODE		CHAR(1)			= 'G',
           @Lc_CaseRelationshipCp_CODE			CHAR(1)			= 'C',
           @Lc_CaseRelationshipDp_CODE			CHAR(1)			= 'D',
           @Lc_CaseRelationshipNcp_CODE			CHAR(1)			= 'A',
           @Lc_CaseMemberStatusActive_CODE		CHAR(1)			= 'A',
           @Lc_RelationshipCasePutFather_TEXT	CHAR(1)			= 'P',
           @Lc_StatusMaritalApplicantMa_CODE	CHAR(2)			= 'MA',
           @Lc_StatusMaritalApplicantDi_CODE	CHAR(2)			= 'DI',
           @Lc_StatusMaritalApplicantSp_CODE	CHAR(2)			= 'SP',
           @Lc_StatusMaritalApplicantWo_CODE	CHAR(2)			= 'WO',
           @Lc_StatusMaritalApplicantNm_CODE	CHAR(2)			= 'NM',
           @Lc_StatusMaritalApplicantCu_CODE	CHAR(2)			= 'CU',
           @Lc_StatusMaritalApplicantSn_CODE	CHAR(2)			= 'SN',
           @Ls_Procedure_NAME					VARCHAR(100)	= 'BATCH_GEN_NOTICE_MEMBER$SP_GET_FAT_OR_MOT_DETAILS';
           
  DECLARE  @Ln_Value_QNTY						NUMERIC(4),
           @Lc_StatMartopt1_TEXT				CHAR(1)			= '',
           @Lc_StatMartopt2_TEXT				CHAR(1)			= '',
           @Lc_StatMartopt3_TEXT				CHAR(1)			= '',
           @Lc_StatMartopt4_TEXT				CHAR(1)			= '',
           @Lc_StatMartopt5_TEXT				CHAR(1)			= '',
           @Lc_StatMartopt6_TEXT				CHAR(1)			= '',
           @Lc_StatMartopt7_TEXT				CHAR(1)			= '',
           @Lc_HomeInd_ADDR						CHAR(1)			= '',
           @Lc_MemberSex_CODE					CHAR(1)			= '',
           @Lc_CaseRelationship_CODE			CHAR(1)			= '',
           @Lc_MomObligor_TEXT					CHAR(1)			= '',
           @Lc_FatherObligee_TEXT				CHAR(1)			= '',
           @Lc_FatherObligor_TEXT				CHAR(1)			= '',
           @Lc_MomObligee_TEXT					CHAR(1)			= '',
           @Lc_CaretakerOpt_TEXT				CHAR(1)			= '',
           @Lc_StatusMarital_CODE				CHAR(2)			= '',
           @Lc_DescriptionRace_CODE				CHAR(30)		= '',
           @Ls_CaretakerRelationship_TEXT		VARCHAR(70)		='',
           @Ls_Sql_TEXT							VARCHAR(200),
           @Ls_Sqldata_TEXT						VARCHAR(400),
           @Ls_DescriptionError_TEXT			VARCHAR(4000)	= ''
           
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '');
   SET @Ls_Sql_TEXT = 'SELECT_VDEMO';

   SELECT @Lc_StatusMarital_CODE = d.StateMarriage_CODE
     FROM DEMO_Y1 d
    WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO;

   IF @Lc_StatusMarital_CODE IN (@Lc_StatusMaritalApplicantMa_CODE)
      BEGIN
		SET @Lc_StatMartopt1_TEXT = @Lc_CheckBoxX_TEXT;
	  END
   ELSE IF @Lc_StatusMarital_CODE IN (@Lc_StatusMaritalApplicantDi_CODE)
	  BEGIN
		SET @Lc_StatMartopt2_TEXT = @Lc_CheckBoxX_TEXT;
	  END
   ELSE IF @Lc_StatusMarital_CODE IN (@Lc_StatusMaritalApplicantSp_CODE)
	  BEGIN
		SET @Lc_StatMartopt3_TEXT = @Lc_CheckBoxX_TEXT;
	  END
   ELSE IF @Lc_StatusMarital_CODE IN (@Lc_StatusMaritalApplicantWo_CODE)
	  BEGIN	
		SET @Lc_StatMartopt4_TEXT = @Lc_CheckBoxX_TEXT;
	  END
   ELSE IF @Lc_StatusMarital_CODE IN (@Lc_StatusMaritalApplicantNm_CODE)
      BEGIN
		SET @Lc_StatMartopt5_TEXT = @Lc_CheckBoxX_TEXT;
	  END
   ELSE IF @Lc_StatusMarital_CODE IN (@Lc_StatusMaritalApplicantCu_CODE)
	  BEGIN
		SET @Lc_StatMartopt6_TEXT = @Lc_CheckBoxX_TEXT;
	  END
   ELSE IF @Lc_StatusMarital_CODE IN (@Lc_StatusMaritalApplicantSn_CODE)
	  BEGIN
		SET @Lc_StatMartopt7_TEXT = @Lc_CheckBoxX_TEXT;
	  END
   ELSE
     BEGIN
		 SET @Lc_StatMartopt1_TEXT = @Lc_Space_TEXT;
		 SET @Lc_StatMartopt2_TEXT = @Lc_Space_TEXT;
		 SET @Lc_StatMartopt3_TEXT = @Lc_Space_TEXT;
		 SET @Lc_StatMartopt4_TEXT = @Lc_Space_TEXT;
		 SET @Lc_StatMartopt5_TEXT = @Lc_Space_TEXT;
		 SET @Lc_StatMartopt6_TEXT = @Lc_CheckBoxX_TEXT
		 SET @Lc_StatMartopt7_TEXT = @Lc_Space_TEXT;
	 END
 
   SET @Ls_Sql_TEXT = 'SELECT_VDEMO';

   SELECT @Ln_Value_QNTY = COUNT(1)
     FROM AHIS_Y1
    WHERE AHIS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
      AND AHIS_Y1.TypeAddress_CODE IN (@Ls_PrimResidence_ADDR)
      AND AHIS_Y1.Status_CODE IN (@Lc_VerificationStatusGood_CODE, @Lc_VerificationStatusPending_CODE)

   IF @Ln_Value_QNTY = 1
	 BEGIN
		SET @Lc_HomeInd_ADDR = @Lc_CheckBoxX_TEXT;
	 END
   ELSE
	 BEGIN
		SET @Lc_HomeInd_ADDR = @Lc_Space_TEXT;
	 END

   IF (@Ac_Parent_INDC = @Lc_RelationshipToChildF_CODE)
    BEGIN
     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     (SELECT tag_name,
             tag_value
        FROM (SELECT CONVERT(VARCHAR(100), FATHER_CHK_STATUS_MARITAL_MARRIED) FATHER_CHK_STATUS_MARITAL_MARRIED_CODE,
                     CONVERT(VARCHAR(100), FATHER_CHK_STATUS_MARITAL_DIVORCED) FATHER_CHK_STATUS_MARITAL_DIVORCED_CODE,
                     CONVERT(VARCHAR(100), FATHER_CHK_STATUS_MARITAL_SEP) FATHER_CHK_STATUS_MARITAL_SEP_CODE,
                     CONVERT(VARCHAR(100), FATHER_CHK_STATUS_MARITAL_LEGSEP) FATHER_CHK_STATUS_MARITAL_LEGSEP_CODE,
                     CONVERT(VARCHAR(100), FATHER_CHK_STATUS_MARITAL_LIVIN) FATHER_CHK_STATUS_MARITAL_LIVIN_CODE,
                     CONVERT(VARCHAR(100), FATHER_CHK_STATUS_MARITAL_UNKNOWN) FATHER_CHK_STATUS_MARITAL_UNKNOWN_CODE,
                     CONVERT(VARCHAR(100), FATHER_CHK_STATUS_MARITAL_SINGLE) FATHER_CHK_STATUS_MARITAL_SINGLE_CODE,
                     CONVERT(VARCHAR(100), HOME_CHK_IND_ADDR) HOME_CHK_IND_ADDR_CODE
                FROM (SELECT
                     @Lc_StatMartopt1_TEXT AS FATHER_CHK_STATUS_MARITAL_MARRIED,
                     @Lc_StatMartopt2_TEXT AS FATHER_CHK_STATUS_MARITAL_DIVORCED,
                     @Lc_StatMartopt3_TEXT AS FATHER_CHK_STATUS_MARITAL_SEP,
                     @Lc_StatMartopt4_TEXT AS FATHER_CHK_STATUS_MARITAL_LEGSEP,
                     @Lc_StatMartopt5_TEXT AS FATHER_CHK_STATUS_MARITAL_LIVIN,
                     @Lc_StatMartopt6_TEXT AS FATHER_CHK_STATUS_MARITAL_UNKNOWN,
                     @Lc_StatMartopt7_TEXT AS FATHER_CHK_STATUS_MARITAL_SINGLE,
                     @Lc_HomeInd_ADDR AS HOME_CHK_IND_ADDR) h)up 
             UNPIVOT (tag_value FOR tag_name IN (	FATHER_CHK_STATUS_MARITAL_MARRIED_CODE, 
													FATHER_CHK_STATUS_MARITAL_DIVORCED_CODE, 
													FATHER_CHK_STATUS_MARITAL_SEP_CODE, 
													FATHER_CHK_STATUS_MARITAL_LEGSEP_CODE, 
													FATHER_CHK_STATUS_MARITAL_LIVIN_CODE, 
													FATHER_CHK_STATUS_MARITAL_UNKNOWN_CODE, 
													FATHER_CHK_STATUS_MARITAL_SINGLE_CODE, 
													HOME_CHK_IND_ADDR_CODE )) AS pvt);

     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) 
						  + 'RELATION_TO_DEP =' + ISNULL(@Ac_Parent_INDC, '');

     SELECT DISTINCT
            @Lc_CaseRelationship_CODE = c.CaseRelationship_CODE
      FROM CMEM_Y1 c
      WHERE c.Case_IDNO = @An_Case_IDNO
        AND c.MemberMci_IDNO = @An_MemberMci_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

     IF (@Lc_CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_RelationshipCasePutFather_TEXT))
      BEGIN
		   SET @Lc_FatherObligor_TEXT	= @Lc_CheckBoxX_TEXT;
		   SET @Lc_FatherObligee_TEXT	= @Lc_Space_TEXT;
      END
     ELSE IF (@Lc_CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE))
      BEGIN
		   SET @Lc_FatherObligor_TEXT	= @Lc_Space_TEXT;
		   SET @Lc_FatherObligee_TEXT	= @Lc_CheckBoxX_TEXT;
      END
      
     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     (SELECT tag_name,
             tag_value
        FROM (SELECT CONVERT(VARCHAR(100), FATHER_OBLIGOR_OPT) FATHER_OBLIGOR_OPT_CODE,
                     CONVERT(VARCHAR(100), FATHER_OBLIGEE_OPT) FATHER_OBLIGEE_OPT_CODE
                FROM (SELECT @Lc_FatherObligor_TEXT AS FATHER_OBLIGOR_OPT,
                             @Lc_FatherObligee_TEXT AS FATHER_OBLIGEE_OPT
                             WHERE NOT EXISTS (SELECT 1 FROM #NoticeElementsData_P1 
													WHERE LTRIM(RTRIM(Element_NAME)) IN ('FATHER_OBLIGOR_OPT_CODE','FATHER_OBLIGEE_OPT_CODE'))
													) h)up 
      UNPIVOT (tag_value FOR tag_name IN ( FATHER_OBLIGOR_OPT_CODE, FATHER_OBLIGEE_OPT_CODE )) AS pvt);
    END
   ELSE IF (@Ac_Parent_INDC = @Lc_RelationshipToChildM_CODE)
    BEGIN
     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     (SELECT tag_name,
             tag_value
        FROM (SELECT CONVERT(VARCHAR(100), MOM_CHK_STATUS_MARITAL_MARRIED) MOM_CHK_STATUS_MARITAL_MARRIED_CODE,
                     CONVERT(VARCHAR(100), MOM_CHK_STATUS_MARITAL_DIVORCED) MOM_CHK_STATUS_MARITAL_DIVORCED_CODE,
                     CONVERT(VARCHAR(100), MOM_CHK_STATUS_MARITAL_SEP) MOM_CHK_STATUS_MARITAL_SEP_CODE,
                     CONVERT(VARCHAR(100), MOM_CHK_STATUS_MARITAL_LEGSEP) MOM_CHK_STATUS_MARITAL_LEGSEP_CODE,
                     CONVERT(VARCHAR(100), MOM_CHK_STATUS_MARITAL_LIVIN) MOM_CHK_STATUS_MARITAL_LIVIN_CODE,
                     CONVERT(VARCHAR(100), MOM_CHK_STATUS_MARITAL_UNKNOWN) MOM_CHK_STATUS_MARITAL_UNKNOWN_CODE,
                     CONVERT(VARCHAR(100), MOM_CHK_STATUS_MARITAL_SINGLE) MOM_CHK_STATUS_MARITAL_SINGLE_CODE,
                     CONVERT(VARCHAR(100), MOM_HOME_CHK_IND_ADDR) MOM_HOME_CHK_IND_ADDR_CODE
                FROM (SELECT @Lc_StatMartopt1_TEXT AS MOM_CHK_STATUS_MARITAL_MARRIED,
                             @Lc_StatMartopt2_TEXT AS MOM_CHK_STATUS_MARITAL_DIVORCED,
                             @Lc_StatMartopt3_TEXT AS MOM_CHK_STATUS_MARITAL_SEP,
                             @Lc_StatMartopt4_TEXT AS MOM_CHK_STATUS_MARITAL_LEGSEP,
                             @Lc_StatMartopt5_TEXT AS MOM_CHK_STATUS_MARITAL_LIVIN,
                             @Lc_StatMartopt6_TEXT AS MOM_CHK_STATUS_MARITAL_UNKNOWN,
                             @Lc_StatMartopt7_TEXT AS MOM_CHK_STATUS_MARITAL_SINGLE,
                             @Lc_HomeInd_ADDR AS MOM_HOME_CHK_IND_ADDR) h)up 
          UNPIVOT (tag_value FOR tag_name IN (  MOM_CHK_STATUS_MARITAL_MARRIED_CODE, 
												MOM_CHK_STATUS_MARITAL_DIVORCED_CODE, 
												MOM_CHK_STATUS_MARITAL_SEP_CODE, 
												MOM_CHK_STATUS_MARITAL_LEGSEP_CODE, 
												MOM_CHK_STATUS_MARITAL_LIVIN_CODE, 
												MOM_CHK_STATUS_MARITAL_UNKNOWN_CODE, 
												MOM_CHK_STATUS_MARITAL_SINGLE_CODE, 
												MOM_HOME_CHK_IND_ADDR_CODE )) AS pvt);

     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + 'RELATION_TO_DEP =' + ISNULL(@Ac_Parent_INDC, '');

     SELECT DISTINCT
            @Lc_CaseRelationship_CODE = C.CaseRelationship_CODE
       FROM CMEM_Y1 C
      WHERE C.Case_IDNO = @An_Case_IDNO
        AND C.MemberMci_IDNO = @An_MemberMci_IDNO
        AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

     IF (@Lc_CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_RelationshipCasePutFather_TEXT))
      BEGIN
		   SET @Lc_MomObligor_TEXT		= @Lc_CheckBoxX_TEXT;
		   SET @Lc_MomObligee_TEXT		= @Lc_Space_TEXT;
      END
     ELSE IF (@Lc_CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE))
      BEGIN
		   SET @Lc_MomObligee_TEXT		= @Lc_CheckBoxX_TEXT;
		   SET @Lc_MomObligor_TEXT		= @Lc_Space_TEXT;
      END

     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     (SELECT tag_name,
             tag_value
        FROM (SELECT CONVERT(VARCHAR(100), MOM_OBLIGOR_OPT) MOM_OBLIGOR_OPT_CODE,
                     CONVERT(VARCHAR(100), MOM_OBLIGEE_OPT) MOM_OBLIGEE_OPT_CODE
                FROM (SELECT @Lc_MomObligor_TEXT AS MOM_OBLIGOR_OPT,
                             @Lc_MomObligee_TEXT AS MOM_OBLIGEE_OPT
                              WHERE NOT EXISTS (SELECT 1 FROM #NoticeElementsData_P1 
													WHERE LTRIM(RTRIM(Element_NAME)) IN ('MOM_OBLIGOR_OPT_CODE','MOM_OBLIGEE_OPT_CODE'))
                             ) h)up 
      UNPIVOT (tag_value FOR tag_name IN (	MOM_OBLIGOR_OPT_CODE, 
											MOM_OBLIGEE_OPT_CODE )) AS pvt);
    END
    
   ELSE IF (@Ac_Parent_INDC = @Lc_RelationshipToChildG_CODE)
    BEGIN 

     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + 'RELATION_TO_DEP =' + ISNULL(@Ac_Parent_INDC, '');
  
     IF @An_MemberMci_IDNO IS NOT NULL AND @An_MemberMci_IDNO != 0 
	   BEGIN
			 SELECT TOP 1 
					@Lc_CaseRelationship_CODE = C.CaseRelationship_CODE,
					@Ls_CaretakerRelationship_TEXT = dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE('FMLY','RELA', CpRelationShipToChild_CODE)
			   FROM CMEM_Y1 C
			  WHERE C.Case_IDNO = @An_Case_IDNO
				AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
				AND CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE;
	  END
	IF (@Lc_CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE)
      BEGIN
		
       IF(@An_MemberMci_IDNO IS NOT NULL AND @An_MemberMci_IDNO != 0) 
        BEGIN
			 SET @Lc_CaretakerOpt_TEXT = @Lc_CheckBoxX_TEXT;
			INSERT INTO #NoticeElementsData_P1
							 (Element_NAME,
							  Element_Value)
			 (SELECT Element_NAME,
					 Element_Value
					FROM (SELECT 
								 CONVERT(VARCHAR(100), CARETAKER_OPT_CODE) CARETAKER_OPT_CODE,
								 CONVERT(VARCHAR(100), caretaker_legal_guardian_opt_code) caretaker_legal_guardian_opt_code,
								 CONVERT(VARCHAR(100), caretaker_rel_to_dep_code) caretaker_rel_to_dep_code
							FROM (SELECT 
										 @Lc_CaretakerOpt_TEXT AS CARETAKER_OPT_CODE,
										 @Lc_CheckBoxX_TEXT AS caretaker_legal_guardian_opt_code,
										 @Ls_CaretakerRelationship_TEXT AS caretaker_rel_to_dep_code
										 ) h)up 
					  UNPIVOT (Element_Value FOR Element_NAME IN (  
												CARETAKER_OPT_CODE,
												caretaker_legal_guardian_opt_code,
												caretaker_rel_to_dep_code
												)) AS pvt);
        END
      END
    END
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
      SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;
         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =   SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
