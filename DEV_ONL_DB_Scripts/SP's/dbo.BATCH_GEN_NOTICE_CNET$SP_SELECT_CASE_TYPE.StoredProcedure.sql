/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_SELECT_CASE_TYPE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_SELECT_CASE_TYPE
Programmer Name	:	IMP Team.
Description		:	
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_SELECT_CASE_TYPE]
(
	 @An_Case_IDNO              NUMERIC(6),
	 @Ac_IVDOutOfStateFips_CODE CHAR(2),
	 @An_TransHeader_IDNO       NUMERIC(12),
	 @Ad_Transaction_DATE       DATE,
	 @Ac_Msg_CODE               CHAR(5) OUTPUT,
	 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Lc_CaseStatusOpen_CODE                CHAR(1) = 'O',
           @Lc_RespondInitResponding_TEXT         CHAR(1) = 'R',
           @Lc_RespondTrabal_TEXT				  CHAR(1) = 'S',
           @Lc_RespondInternational_TEXT          CHAR(1) = 'Y',
           @Lc_StatusSuccess_CODE                 CHAR(1) = 'S',
           @Lc_StatusFailed_CODE                  CHAR(1) = 'F',
           @Lc_CheckBoxChecked_TEXT               CHAR(1) = 'X',
           @Lc_TypeCaseTanf_CODE                  CHAR(1) = 'A',
           @Lc_TypeCaseIveFostercare_CODE         CHAR(1) = 'F',
           @Lc_CaseCategoryNonFedFostercare_CODE  CHAR(1) = 'J',
           @Lc_TypeCaseNonTanf_CODE               CHAR(1) = 'N',
           @Lc_TypeCaseNonIvd_CODE                CHAR(1) = 'H',
           @Lc_CaseCategoryMedical_CODE           CHAR(2) = 'MO',
           @Ls_Routine_TEXT                       VARCHAR(100) = 'BATCH_GEN_NOTICE_CNET$SP_SELECT_CASE_TYPE ',
           @Ld_High_DATE                          DATE = '12/31/9999';
           
  DECLARE  @Lc_RespondInit_CODE            CHAR(1),
           @Lc_TypeCase_CODE               CHAR(1),
           @Lc_CheckBox1_TEXT              CHAR(1) = '',
           @Lc_CheckBox2_TEXT              CHAR(1) = '',
           @Lc_CheckBox3_TEXT              CHAR(1) = '',
           @Lc_CheckBox4_TEXT              CHAR(1) = '',
           @Lc_CheckBox5_TEXT              CHAR(1) = '',
           @Lc_CheckBox6_TEXT              CHAR(1) = '',
           @Lc_CaseCategory_CODE           CHAR(2),
           @Ls_Sql_TEXT                    VARCHAR(200),
           @Ls_Sqldata_TEXT                VARCHAR(400);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 ';
   SET @Ls_Sqldata_TEXT = '  Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6));
   
	IF (@An_Case_IDNO IS NOT NULL AND @An_Case_IDNO != 0)
	   BEGIN
			 SELECT @Lc_RespondInit_CODE = a.RespondInit_CODE,
					@Lc_TypeCase_CODE = a.TypeCase_CODE,
					@Lc_CaseCategory_CODE = a.CaseCategory_CODE
			   FROM CASE_Y1 a
			  WHERE a.Case_IDNO = @An_Case_IDNO
				AND a.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;
			
			IF @Lc_RespondInit_CODE IN ( @Lc_RespondInitResponding_TEXT, @Lc_RespondTrabal_TEXT, @Lc_RespondInternational_TEXT)
				BEGIN
				    SET @Ls_Sql_TEXT = 'SELECT ICAS_Y1 '; 
					SET @Ls_Sqldata_TEXT = '  Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR);
							 SELECT @Lc_TypeCase_CODE = a.IVDOutOfStateTypeCase_CODE
							   FROM ICAS_Y1 a
							  WHERE a.Case_IDNO = @An_Case_IDNO
								AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
								AND a.EndValidity_DATE = @Ld_High_DATE
								AND a.Status_CODE = @Lc_CaseStatusOpen_CODE;
				END
		END		
	ELSE IF @An_Case_IDNO IS NULL OR @An_Case_IDNO = 0
		BEGIN
		      SET @Ls_Sql_TEXT = 'SELECT CSDB_Y1 ';
			  SET @Ls_Sqldata_TEXT = ' TransHeader_IDNO = ' + CAST(ISNULL(@An_TransHeader_IDNO, 0) AS VARCHAR(12))
								   + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE,'')
								   + ', Transaction_DATE = ' + CAST(@Ad_Transaction_DATE AS VARCHAR(10));
   			  SELECT @Lc_TypeCase_CODE = a.TypeCase_CODE
			   FROM CSDB_Y1 a
			  WHERE a.TransHeader_IDNO = @An_TransHeader_IDNO
				AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
				AND a.Transaction_DATE = @Ad_Transaction_DATE;
		END
		
			 
						IF @Lc_TypeCase_CODE = @Lc_TypeCaseTanf_CODE --'A'
							BEGIN
								SET @Lc_CheckBox1_TEXT = @Lc_CheckBoxChecked_TEXT;
							END
						ELSE IF (@Lc_TypeCase_CODE = @Lc_TypeCaseIveFostercare_CODE OR @Lc_TypeCase_CODE = @Lc_CaseCategoryNonFedFostercare_CODE)
							BEGIN
								SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxChecked_TEXT;
							END
						ELSE IF @Lc_TypeCase_CODE = @Lc_TypeCaseNonTanf_CODE AND @Lc_CaseCategory_CODE = @Lc_CaseCategoryMedical_CODE
							BEGIN
								SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxChecked_TEXT;
							END
						ELSE IF @Lc_TypeCase_CODE = @Lc_TypeCaseNonTanf_CODE 
							AND EXISTS
							   (SELECT 1
									FROM MHIS_Y1 a
									WHERE a.TypeWelfare_CODE IN (@Lc_TypeCaseTanf_CODE, @Lc_TypeCaseIveFostercare_CODE, 
															@Lc_CaseCategoryNonFedFostercare_CODE)
								  AND a.Case_IDNO = @An_Case_IDNO
								  )
							BEGIN
								SET @Lc_CheckBox4_TEXT = @Lc_CheckBoxChecked_TEXT;
							END
						ELSE IF @Lc_TypeCase_CODE = @Lc_TypeCaseNonTanf_CODE AND NOT EXISTS
							   (SELECT 1
								FROM MHIS_Y1 a
								WHERE a.TypeWelfare_CODE NOT IN (@Lc_TypeCaseTanf_CODE, @Lc_TypeCaseIveFostercare_CODE, 
													@Lc_CaseCategoryNonFedFostercare_CODE)
								  AND a.Case_IDNO = @An_Case_IDNO
								  )
							BEGIN
								SET @Lc_CheckBox5_TEXT = @Lc_CheckBoxChecked_TEXT;
							END
						ELSE IF @Lc_TypeCase_CODE = @Lc_TypeCaseNonIvd_CODE
							BEGIN
								SET @Lc_CheckBox6_TEXT = @Lc_CheckBoxChecked_TEXT;
							END
						ELSE
							BEGIN
								SET @Lc_CheckBox5_TEXT = @Lc_CheckBoxChecked_TEXT;
							END
			
   INSERT INTO #NoticeElementsData_P1
       (Element_NAME, 
        Element_Value)
   (SELECT Element_NAME, Element_Value
      FROM (SELECT CAST(@Lc_CheckBox1_TEXT AS VARCHAR) AS CaseTypeTanfOpt_CODE,
                   CAST(@Lc_CheckBox2_TEXT AS VARCHAR) AS CaseTypeFosterOpt_CODE,
                   CAST(@Lc_CheckBox3_TEXT AS VARCHAR) AS CaseTypeMediOpt_CODE,
                   CAST(@Lc_CheckBox4_TEXT AS VARCHAR) AS CaseTypeFasstOpt_CODE,
                   CAST(@Lc_CheckBox5_TEXT AS VARCHAR) AS CaseTypeNnnOpt_CODE,
                   CAST(@Lc_CheckBox6_TEXT AS VARCHAR) AS CaseTypeNonIvdOpt_CODE) up UNPIVOT 
							(Element_Value FOR Element_NAME IN (
											CaseTypeTanfOpt_CODE, 
											CaseTypeFosterOpt_CODE, 
											CaseTypeMediOpt_CODE, 
											CaseTypeFasstOpt_CODE, 
											CaseTypeNnnOpt_CODE, 
											CaseTypeNonIvdOpt_CODE
									)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE ();
         DECLARE @Ls_DescriptionError_TEXT VARCHAR(4000);

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END;

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Routine_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END

GO
