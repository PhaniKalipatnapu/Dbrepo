/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_TANF_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_TANF_DETAILS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_TANF_DETAILS]
(
	 @An_Case_IDNO				NUMERIC(6),
	 @Ad_Run_DATE				DATE,
	 @Ac_Msg_CODE				CHAR(5) OUTPUT,
	 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
)
AS
 BEGIN
	  SET NOCOUNT ON;

	  DECLARE  @Lc_StatusFailed_CODE           CHAR(1) = 'F',
			   @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
			   @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
			   @Lc_CaseRelationshipC_CODE	   CHAR(1) = 'C',
			   @Lc_TypeCaseN_CODE	           CHAR(1) = 'N',
			   @Lc_TypeCaseH_CODE	           CHAR(1) = 'H',
			   @Lc_TypeCaseA_CODE	           CHAR(1) = 'A',
			   @Lc_StatusCaseOpen_CODE	       CHAR(1) = 'O',
			   @Lc_State_CODE				   CHAR(2) = 'DE',
			   @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_TANF_DETAILS';
     DECLARE   @Ls_Sql_TEXT          VARCHAR(200),
			   @Ls_Sqldata_TEXT      VARCHAR(400); 
  BEGIN TRY
	   SET @Ac_Msg_CODE = '';
	   SET @As_DescriptionError_TEXT = '';
       SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 CMEM_Y1 MHIS_Y1';
 	   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');
    INSERT INTO #NoticeElementsData_P1
					   (Element_NAME,
						Element_Value)
		   (SELECT tag_name,
				   tag_value
			  FROM (SELECT CONVERT(VARCHAR(100), TANF_START_DATE) TANF_START_DATE,
						   CONVERT(VARCHAR(100), TANF_END_DATE) TANF_END_DATE,
						   CONVERT(VARCHAR(100), TANF_FIRST_MONTH_NUMB) TANF_FIRST_MONTH_NUMB,
						   CONVERT(VARCHAR(100), TANF_FIRST_YEAR_NUMB) TANF_FIRST_YEAR_NUMB,
						   CONVERT(VARCHAR(100), TANF_LAST_MONTH_NUMB) TANF_LAST_MONTH_NUMB,
						   CONVERT(VARCHAR(100), TANF_LAST_YEAR_NUMB) TANF_LAST_YEAR_NUMB,
						   CONVERT(VARCHAR(100), DE_STATE_CODE) DE_STATE_CODE,
						   CONVERT(VARCHAR(100), TANF_PAID_AMNT) TANF_PAID_AMNT
			FROM (
 						SELECT	@Lc_State_code DE_STATE_CODE,
 								H.START_DATE TANF_START_DATE , 
 								H.END_DATE  TANF_END_DATE,
								MONTH(H.START_DATE)AS TANF_FIRST_MONTH_NUMB, 
								YEAR(H.START_DATE) AS TANF_FIRST_YEAR_NUMB ,
								MONTH(END_DATE) AS TANF_LAST_MONTH_NUMB, 
								YEAR(END_DATE) AS TANF_LAST_YEAR_NUMB,
								(SELECT CASE WHEN c.TYPECASE_CODE  = @Lc_TypeCaseA_CODE
												THEN SUM(LtdAssistExpend_AMNT) 
											ELSE
												0
											END 
										FROM IVMG_Y1 i 
										WHERE i.casewelfare_IDNO = h.casewelfare_IDNO
											AND i.WelfareYearMonth_NUMB =
												(SELECT MAX(WelfareYearMonth_NUMB) FROM IVMG_Y1 IV
																WHERE IV.casewelfare_IDNO = I.casewelfare_IDNO)   ) 
								 AS TANF_PAID_AMNT 
						FROM  CASE_Y1 C, CMEM_Y1 M, MHIS_Y1 H 
						WHERE c.TypeCase_CODE NOT IN (@Lc_TypeCaseN_CODE,@Lc_TypeCaseH_CODE)
						AND C.CASE_IDNO = @An_CASE_IDNO
						AND H.CASE_IDNO = @An_CASE_IDNO
						AND C.Case_IDNO = M.CASE_IDNO
						AND C.StatusCase_CODE =  @Lc_StatusCaseOpen_CODE
						AND M.CaseRelationship_CODE = @Lc_CaseRelationshipC_CODE
						AND M.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
						AND M.MemberMci_IDNO = H.MemberMci_IDNO
						AND @Ad_Run_DATE >= M.BeginValidity_DATE
						AND @Ad_Run_DATE BETWEEN H.START_DATE AND H.END_DATE) h)up 
					UNPIVOT (tag_value FOR tag_name IN ( 
									TANF_START_DATE, 
									TANF_END_DATE,
									TANF_FIRST_MONTH_NUMB,
									TANF_FIRST_YEAR_NUMB, 
									TANF_LAST_MONTH_NUMB,
									TANF_LAST_YEAR_NUMB,
									DE_STATE_CODE,
									TANF_PAID_AMNT)) AS pvt);
 		    
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE ();
         DECLARE
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
