/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE$SP_GET_YNGST_CHILD_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE$SP_GET_YNGST_CHILD_DTLS
Programmer Name	:	IMP Team.
Description		:	The function BATCH_GEN_NOTICE$SF_GET_YNGST_CHILD_DTLS gets youngest child details
Frequency		:	
Developed On	:	2/17/2012
Called By		:	BATCH_GEN_NOTICES$SP_GET_SUBELEMENTS
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE$SP_GET_YNGST_CHILD_DTLS] (
 @An_Case_IDNO             NUMERIC (6),
 @An_OtherParty_IDNO	   NUMERIC (10),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR (1) = 'S',
          @Lc_StatusFailed_CODE  CHAR (1) = 'F',
          @Ls_Procedure_NAME     VARCHAR (75) = 'BATCH_GEN_NOTICE$SP_GET_YNGST_CHILD_DTLS ';
  DECLARE @Li_Error_NUMB            INT,
          @Li_ErrorLine_NUMB        INT,
          @Ls_Sql_TEXT              VARCHAR (100) = '',
          @Ls_Sqldata_TEXT          VARCHAR (1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR (4000) ='';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@An_Case_IDNO AS VARCHAR (6)), '');

   WITH Child_CTE
        AS (SELECT d.Birth_DATE,
                   d.Last_NAME,
                   d.First_NAME,
                   d.Middle_NAME,
                   d.Suffix_NAME,
                   ROW_NUMBER () OVER (ORDER BY d.Birth_DATE DESC) AS Row_NUMB
              FROM DEMO_Y1 d
                   JOIN CMEM_Y1 CM
                    ON CM.MemberMci_IDNO = D.MemberMci_IDNO
             WHERE CM.Case_IDNO = @An_Case_IDNO
               AND CM.CaseRelationship_CODE = 'D'
               AND CM.CaseMemberStatus_CODE = 'A'
               AND CM.MemberMci_IDNO = @An_OtherParty_IDNO)
   INSERT INTO #NoticeElementsData_P1
		 (Element_NAME,
		  Element_Value
		 )
   (SELECT pvt.Element_NAME,
           pvt.Element_Value
      FROM (SELECT CONVERT (VARCHAR (100), d.Birth_DATE) AS YNGST_CHILD_BIRTH_DATE,
                   CONVERT (VARCHAR (100), d.First_NAME) AS YNGST_CHILD_FIRST_NAME,
                   CONVERT (VARCHAR (100), d.Middle_NAME) AS YNGST_CHILD_MIDDLE_NAME,
                   CONVERT (VARCHAR (100), d.Last_NAME) AS YNGST_CHILD_LAST_NAME,
                   CONVERT (VARCHAR (100), d.Suffix_NAME) AS YNGST_CHILD_SUFFIX_NAME,
                   CONVERT (VARCHAR (100), DATEADD (DAY, -1, DATEADD (YEAR, 18, d.Birth_DATE)), 101) AS YNGST_CHILD_DAY_BEFORE_18_BIRTH_DATE,
                   CONVERT (VARCHAR (100), DATEADD (YEAR, 18, d.Birth_DATE), 101) AS YNGST_CHILD_18_BIRTH_DATE
              FROM (SELECT d.Birth_DATE,
                           d.Last_NAME,
                           d.First_NAME,
                           d.Middle_NAME,
                           d.Suffix_NAME
                      FROM Child_CTE D
                     WHERE Row_NUMB = 1) D) Up UNPIVOT (Element_Value FOR Element_NAME IN (YNGST_CHILD_DAY_BEFORE_18_BIRTH_DATE, YNGST_CHILD_BIRTH_DATE, YNGST_CHILD_FIRST_NAME, YNGST_CHILD_MIDDLE_NAME, YNGST_CHILD_LAST_NAME, YNGST_CHILD_SUFFIX_NAME, YNGST_CHILD_18_BIRTH_DATE) ) pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
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
