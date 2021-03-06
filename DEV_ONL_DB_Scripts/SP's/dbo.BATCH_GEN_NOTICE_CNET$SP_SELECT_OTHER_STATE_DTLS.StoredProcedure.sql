/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_SELECT_OTHER_STATE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_SELECT_OTHER_STATE_DTLS
Programmer Name	:	IMP Team.
Description		:	Procedure fetches the other state details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_SELECT_OTHER_STATE_DTLS]
(
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @As_Prefix_TEXT			VARCHAR(100),
 @An_Case_IDNO              NUMERIC(6),
 @Ac_Recipient_ID           CHAR(10),
 @An_MemberMci_IDNO			NUMERIC(10),
 @Ad_Run_DATE               DATE,
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusCaseMemberActive_CODE     CHAR(1) = 'A',
           @Lc_RelationshipCaseCp_TEXT         CHAR(1) = 'C',
           @Lc_RelationshipCaseNcp_TEXT        CHAR(1) = 'A',
           @Lc_RelationshipCasePutFather_TEXT  CHAR(1) = 'P',
           @Lc_CaseStatusOpen_CODE             CHAR(1) = 'O',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_Space_TEXT                      CHAR(1) = ' ',
		   @Ls_IVDOutOfStateFips_Tribal_CODE   CHAR(2) = '90',
           @Lc_Fips_CODE                       CHAR(5) = '00000',
           @Ls_Procedure_NAME                  VARCHAR(100) = ' BATCH_GEN_NOTICE_CNET$SP_SELECT_OTHER_STATE_DTLS ',
           @Ld_High_DATE                       DATE = '12/31/9999'

  DECLARE  @Ln_RowCount_QNTY					INT = 0,
           @Lc_PetitionerValue_TEXT				CHAR(100),
           @Ls_Sql_TEXT							VARCHAR(200),
           @Ls_Sqldata_TEXT						VARCHAR(4000);
           /* @An_MemberMci_IDNO expects RespondentMci_IDNO value */
 
BEGIN TRY
	SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO , '')  AS CHAR)
						 + 'IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') 
						 + ' Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(10)) 
						 + ' MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10));
    
    SET @Ls_Sql_TEXT = 'CREATE NDEL_P1';
     DECLARE @Ndel_P1 TABLE
			  (
				 Element_NAME    VARCHAR(100),
				 Element_Value   VARCHAR(100)
			  );

	SET @Ls_Sql_TEXT = 'SELECT ICAS_Y1 ';
	
    INSERT INTO @Ndel_P1 (Element_NAME, Element_Value)
   (SELECT Element_NAME, Element_Value
      FROM (SELECT CAST(IVDOutOfStateCase_ID AS VARCHAR(100)) AS IVDOutOfStateCase_ID,
                   CAST(Fips_CODE AS VARCHAR(100)) AS Fips_CODE,
                   CAST(File_ID AS VARCHAR(100)) AS File_ID,
                   CAST(Petitioner_NAME AS VARCHAR(100)) AS Petitioner_NAME,
                   CAST(FostercareOption_TEXT AS VARCHAR(100)) AS FostercareOption_TEXT,
                   CAST(Respondent_NAME AS VARCHAR(100)) AS Respondent_NAME,
                   CAST(PetitionerSsn_NUMB AS VARCHAR(100)) AS PetitionerSsn_NUMB,
                   CAST(RespondentSsn_NUMB AS VARCHAR(100)) AS RespondentSsn_NUMB,
                   CAST(Petitioner_TribalAffiliations_CODE AS VARCHAR(100)) AS Petitioner_TribalAffiliations_CODE,
                   CAST(Respondent_TribalAffiliations_CODE AS VARCHAR(100)) AS Respondent_TribalAffiliations_CODE
              FROM (SELECT TOP 1 a.IVDOutOfStateCase_ID AS IVDOutOfStateCase_ID,
						   CASE WHEN @Ac_IVDOutOfStateFips_CODE = @Ls_IVDOutOfStateFips_Tribal_CODE
						   THEN 
							  @Ac_Recipient_ID
						   ELSE
                           a.IVDOutOfStateFips_CODE + a.IVDOutOfStateCountyFips_CODE 
								+ a.IVDOutOfStateOfficeFips_CODE 
						    END AS Fips_CODE,
                           a.IVDOutOfStateFile_ID AS IVDOutOfStateFile_ID,
                           a.IVDOutOfStateFile_ID AS File_ID,
                           a.Petitioner_NAME AS Petitioner_NAME,
                           @Lc_Space_TEXT AS FostercareOption_TEXT,
                           a.Respondent_NAME AS Respondent_NAME,
                           dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE('CSNT','TRIB', dp.TribalAffiliations_CODE) AS Petitioner_TribalAffiliations_CODE,
                           dp.MemberSsn_NUMB AS PetitionerSsn_NUMB,
						   dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE('CSNT','TRIB', dr.TribalAffiliations_CODE) AS Respondent_TribalAffiliations_CODE,
                           dr.MemberSsn_NUMB AS RespondentSsn_NUMB
                      FROM ICAS_Y1 AS a 
							LEFT OUTER JOIN DEMO_Y1 dr 
								ON a.RespondentMci_IDNO = dr.MemberMci_IDNO
							LEFT OUTER JOIN DEMO_Y1 dp
								ON a.PetitionerMci_IDNO = dp.MemberMci_IDNO
                     WHERE a.IVDOutOfStateFips_CODE = ISNULL(@Ac_IVDOutOfStateFips_CODE, '')
                       AND a.Case_IDNO = @An_Case_IDNO
                       AND RespondentMci_IDNO = @An_MemberMci_IDNO
                       AND a.EndValidity_DATE = @Ld_High_DATE
                       AND @Ad_Run_DATE BETWEEN a.Effective_DATE AND a.End_DATE
                       AND a.Status_CODE = @Lc_CaseStatusOpen_CODE) f) 
                       up UNPIVOT (Element_Value FOR Element_NAME IN (  IVDOutOfStateCase_ID, 
																		Fips_CODE, 
																		File_ID, 
																		Petitioner_NAME, 
																		FostercareOption_TEXT, 
																		Respondent_NAME, 
																		PetitionerSsn_NUMB, 
																		RespondentSsn_NUMB,
																		Petitioner_TribalAffiliations_CODE,
																		Respondent_TribalAffiliations_CODE
																		) ) AS pvt); 
	
   SET @Ln_RowCount_QNTY = @@ROWCOUNT;
  
   IF (@Ln_RowCount_QNTY != 0)
	BEGIN
			SET @Ls_Sql_TEXT = 'UPDATE @Ndel_P1';
			
			UPDATE @Ndel_P1
            SET Element_NAME = @As_Prefix_TEXT + '_'+ Element_NAME
            WHERE Element_NAME IN ('IVDOutOfStateCase_ID', 'Fips_CODE', 'File_ID');
            
            SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
			
			INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
            SELECT t.Element_NAME, t.Element_Value
              FROM @Ndel_P1 t;
	END
   ELSE
   BEGIN
		SET @Ls_Sql_TEXT = 'SELECT CMEM_DEMO - 1';
		INSERT INTO @Ndel_P1 (Element_NAME, Element_Value)
			(SELECT Element_NAME, Element_Value
			FROM (SELECT CAST(IVDOutOfStateCase_ID AS VARCHAR(100)) AS IVDOutOfStateCase_ID,
						 CAST(Fips_CODE AS VARCHAR(100)) AS Fips_CODE,
						 CAST(Petitioner_NAME AS VARCHAR(100)) AS Petitioner_NAME,
						 CAST(FostercareOption_TEXT AS VARCHAR(100)) AS FostercareOption_TEXT,
						 CAST(PetitionerSsn_NUMB AS VARCHAR(100)) AS PetitionerSsn_NUMB,
						 CAST(Petitioner_TribalAffiliations_CODE AS VARCHAR(100)) AS Petitioner_TribalAffiliations_CODE
					FROM  (SELECT @Lc_Space_TEXT AS IVDOutOfStateCase_ID,
							CASE WHEN @Ac_IVDOutOfStateFips_CODE = @Ls_IVDOutOfStateFips_Tribal_CODE
							   THEN 
								  @Ac_Recipient_ID
							   ELSE
							   ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + @Lc_Fips_CODE 
								END AS Fips_CODE,
								 LTRIM(RTRIM(dbo.BATCH_GEN_NOTICE_CNET$SF_GET_MEMBER_NAME(d.MemberMci_IDNO))) AS Petitioner_NAME,
								 @Lc_Space_TEXT AS FostercareOption_TEXT,
								 d.MemberSsn_NUMB PetitionerSsn_NUMB,
								 dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE('CSNT','TRIB', d.TribalAffiliations_CODE) Petitioner_TribalAffiliations_CODE
							FROM CMEM_Y1 AS c, DEMO_Y1 AS d
						   WHERE c.Case_IDNO = @An_Case_IDNO
							 AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
							 AND c.CaseRelationship_CODE = @Lc_RelationshipCaseCp_TEXT
							 AND c.MemberMci_IDNO = d.MemberMci_IDNO) f) up 
						 UNPIVOT (Element_Value FOR Element_NAME IN (IVDOutOfStateCase_ID, Fips_CODE,
																Petitioner_NAME, FostercareOption_TEXT, PetitionerSsn_NUMB ) ) AS pvt);

		SET @Ls_Sql_TEXT = 'SELECT CMEM_DEMO - 2';
		INSERT INTO @Ndel_P1 (Element_NAME, Element_Value)
			(SELECT Element_NAME,
					Element_Value
			 FROM (SELECT CAST(Respondent_NAME AS VARCHAR(100)) AS Respondent_NAME,
						  CAST(RespondentSsn_NUMB AS VARCHAR(100)) AS RespondentSsn_NUMB,
						  CAST(Respondent_TribalAffiliations_CODE AS VARCHAR(100)) AS Respondent_TribalAffiliations_CODE
					FROM (SELECT LTRIM(RTRIM((dbo.BATCH_GEN_NOTICE_CNET$SF_GET_MEMBER_NAME(d.MemberMci_IDNO)))) AS Respondent_NAME,
									d.MemberSsn_NUMB RespondentSsn_NUMB,
									dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE('CSNT','TRIB', d.TribalAffiliations_CODE) Respondent_TribalAffiliations_CODE
							FROM CMEM_Y1 AS c,
                             DEMO_Y1 AS d
                       WHERE c.Case_IDNO = @An_Case_IDNO
                         AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                         AND c.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                         AND c.MemberMci_IDNO = d.MemberMci_IDNO) f) up 
                     UNPIVOT (Element_Value FOR Element_NAME IN (Respondent_NAME, RespondentSsn_NUMB ) ) AS pvt);

         SET @Ls_Sql_TEXT = 'UPDATE @Ndel_P1';
         SELECT @Lc_PetitionerValue_TEXT = Element_Value
			FROM @Ndel_P1
			WHERE Element_NAME = 'Petitioner_NAME';

		 UPDATE @Ndel_P1
            SET Element_NAME = @As_Prefix_TEXT + '_'+ Element_NAME
            WHERE Element_NAME IN ('IVDOutOfStateCase_ID', 'Fips_CODE', 'File_ID');
		 

         SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
         INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
            SELECT t.Element_NAME, t.Element_Value
              FROM @Ndel_P1 t;
   END;

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
            END;

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;

GO
