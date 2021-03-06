/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GENTC_RSLTS_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------------------------------------------------------------------
 Procedure Name   :BATCH_GEN_NOTICE_EST_ENF$SP_GENTC_RSLTS_DTLS
 Programmer Name  : IMP Team
 Description      :This procedure gets the genetic test result whether it is either positive or negative and Probability percentage.
 Frequency        :
 Developed On     : 02-AUG-2011
 Called By        : BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On        :
-----------------------------------------------------------------------------------------------------------------------
 Modified By      :
 Modified On      :
 Version No       : 1.0
----------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GENTC_RSLTS_DTLS](
 @An_Case_IDNO             NUMERIC(6),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_CheckBoxValue_TEXT CHAR(1) = 'X',
          @Lc_TestResult_Include_CODE CHAR(1) = 'I',
		  @Lc_TestResult_Exclude_CODE CHAR(1) = 'X', 
		  @Lc_Active_CaseMemberStatus_CODE CHAR(1) = 'A',
		  @Lc_Dependent_CaseRelationship_CODE CHAR(1) = 'D',
          @Ls_Sql_TEXT           VARCHAR(200) = 'SELECT GTST_Y1 DMNR_Y1',
          @Ls_SqlData_TEXT       VARCHAR(400) = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + 'MajorIntSeq_NUMB= ' + CAST(@An_MajorIntSeq_NUMB AS VARCHAR),
          @Ld_Low_DATE           DATE = '01/01/0001',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Probability_PCT    NUMERIC(5, 2) = NULL,
		  @Ln_Schedule_NUMB		 NUMERIC(10),
          @Lc_TestResultPositive_CODE CHAR(1) = '',
          @Lc_TestResultNegative_CODE CHAR(1) = '',
          @Ls_DescriptionError_TEXT   VARCHAR(4000);

  BEGIN TRY
  -- Defect 12800 - CR0296 EST-10 and 11 Paternity Test Results 20131023 Fix - Start –
      SELECT @Ln_Schedule_NUMB = MAX(s.Schedule_NUMB) 
				FROM SWKS_Y1 s JOIN DMNR_Y1 d 
				ON s.Schedule_NUMB = d.Schedule_NUMB
				AND d.Case_IDNO = @An_Case_IDNO
				AND d.Case_IDNO = s.Case_IDNO 
				AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
				
       SELECT @Ln_Probability_PCT = MAX(g.Probability_PCT)
		 FROM GTST_Y1 g
		WHERE g.Case_IDNO = @An_Case_IDNO
		  AND g.Schedule_NUMB = @Ln_Schedule_NUMB
		  AND g.TestResult_CODE = @Lc_TestResult_Include_CODE
		  AND g.ResultsReceived_DATE NOT IN (@Ld_Low_DATE, @Ld_High_DATE)
		  AND g.EndValidity_DATE = @Ld_High_DATE
		  AND EXISTS (SELECT 1 FROM GTST_Y1 AS t 
			  LEFT OUTER JOIN DEMO_Y1 AS a 
					ON a.MemberMci_IDNO = t.MemberMci_IDNO
			  INNER JOIN CMEM_Y1 AS b
					ON  b.MemberMci_IDNO = t.MemberMci_IDNO
			 AND b.Case_IDNO		= @An_Case_IDNO
			 AND b.CaseRelationship_CODE = @Lc_Dependent_CaseRelationship_CODE
			 AND b.CaseMemberStatus_CODE = @Lc_Active_CaseMemberStatus_CODE);
      				

   SELECT @Lc_TestResultNegative_CODE = @Lc_CheckBoxValue_TEXT
		FROM GTST_Y1 AS g 
			  LEFT OUTER JOIN DEMO_Y1 AS a 
					ON a.MemberMci_IDNO = g.MemberMci_IDNO
			  INNER JOIN CMEM_Y1 AS b
					ON  b.MemberMci_IDNO = g.MemberMci_IDNO
					AND b.Case_IDNO		= @An_Case_IDNO
					AND b.CaseRelationship_CODE = @Lc_Dependent_CaseRelationship_CODE
					AND b.CaseMemberStatus_CODE = @Lc_Active_CaseMemberStatus_CODE
		   WHERE g.Case_IDNO = @An_Case_IDNO
				 AND g.TestResult_CODE = @Lc_TestResult_Exclude_CODE
				 AND g.EndValidity_DATE = @Ld_High_DATE
				 AND g.Schedule_NUMB = @Ln_Schedule_NUMB   
				 
			 
   SELECT @Lc_TestResultPositive_CODE = @Lc_CheckBoxValue_TEXT
		FROM GTST_Y1 AS g 
			  LEFT OUTER JOIN DEMO_Y1 AS a 
					ON a.MemberMci_IDNO = g.MemberMci_IDNO
			  INNER JOIN CMEM_Y1 AS b
					ON  b.MemberMci_IDNO = g.MemberMci_IDNO
					AND b.Case_IDNO		= @An_Case_IDNO
					AND b.CaseRelationship_CODE = @Lc_Dependent_CaseRelationship_CODE
					AND b.CaseMemberStatus_CODE = @Lc_Active_CaseMemberStatus_CODE
		   WHERE g.Case_IDNO = @An_Case_IDNO
				 AND g.TestResult_CODE = @Lc_TestResult_Include_CODE
				 AND g.EndValidity_DATE = @Ld_High_DATE
				 AND g.Schedule_NUMB = @Ln_Schedule_NUMB   

	-- Defect 12800 - CR0296 EST-10 and 11 Paternity Test Results 20131023 Fix - End –				 
   
   SET @Ls_Sql_TEXT = 'SELECT #NoticeElementsData_P1 ';
   SET @Ls_Sqldata_TEXT = '  Element_NAME = ' ;
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT pvt.Element_NAME,
           pvt.Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(70), ISNULL(@Ln_Probability_PCT, 0)) AS genetic_probability_pct,
                   CONVERT(VARCHAR(70), @Lc_TestResultPositive_CODE) AS genetic_result_positive_code,
                   CONVERT(VARCHAR(70), @Lc_TestResultNegative_CODE) AS genetic_result_negative_code) up UNPIVOT (Element_VALUE FOR Element_NAME IN ( genetic_probability_pct, genetic_result_positive_code, genetic_result_negative_code)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
