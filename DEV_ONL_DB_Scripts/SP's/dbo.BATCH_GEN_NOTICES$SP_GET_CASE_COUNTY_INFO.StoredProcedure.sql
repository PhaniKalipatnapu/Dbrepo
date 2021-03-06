/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CASE_COUNTY_INFO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_CASE_COUNTY_INFO
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get County Info OTHP_Y1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CASE_COUNTY_INFO](
 @An_Case_IDNO             NUMERIC (6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Cnty_NC_IDNO        INT = 3,
		  @Li_Cnty_IC_IDNO        INT = 99,
          @Li_Cnty_KC_IDNO        INT = 1,
          @Li_Cnty_SC_IDNO        INT = 5,
          @Lc_StatusFailed_CODE   CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
          @Lc_CaseStatusOpen_CODE CHAR (1) = 'O',
          @Ls_Procedure_NAME      VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_CASE_COUNTY_INFO',
          @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE @Ls_Sql_TEXT             VARCHAR (200),
          @Ls_Sqldata_TEXT         VARCHAR (400),
          @Ls_Err_Description_TEXT VARCHAR(4000);
  DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
          @Li_ErrorLine_NUMB INT = ERROR_LINE ();

  SET @Ls_Sql_TEXT = 'SELECT OTHP';
  SET @Ls_Sqldata_TEXT = 'Case IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

  BEGIN TRY
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT pvt.Element_NAME,
          pvt.Element_VALUE
     FROM (SELECT CONVERT(VARCHAR(70), case_cnty_selection) Case_Cnty_Selection_TEXT,
                  CONVERT(VARCHAR(70), OtherParty_NAME) County_NAME,
                  CONVERT(VARCHAR(70), Phone_NUMB) Case_Cnty_Phone_NUMB,
                  CONVERT(VARCHAR(70), Phone_NUMB) Cnty_Customer_Service_Phone_NUMB,
                  CONVERT(VARCHAR(70), Fax_NUMB) Fax_NUMB
             FROM (SELECT CASE
                           WHEN C.County_IDNO IN (@Li_Cnty_NC_IDNO, @Li_Cnty_IC_IDNO)
                            THEN 'a'
                           WHEN C.County_IDNO = @Li_Cnty_KC_IDNO
                            THEN 'b'
                           WHEN C.County_IDNO = @Li_Cnty_SC_IDNO
                            THEN 'c'
                          END AS case_cnty_selection,
                          N.County_NAME AS OtherParty_NAME,
                          CASE
                           WHEN LEN(CAST(Phone_NUMB AS VARCHAR)) = 10
                            THEN SUBSTRING(CAST(Phone_NUMB AS VARCHAR), 4, 7)
                           WHEN LEN(CAST(Phone_NUMB AS VARCHAR)) = 7
                            THEN Phone_NUMB
                           ELSE Phone_NUMB
                          END AS Phone_NUMB,
                          Fax_NUMB
                     FROM CASE_Y1 C
                          JOIN OFIC_Y1 F
                           ON F.County_IDNO = C.County_IDNO
                              AND F.EndValidity_DATE = @Ld_High_DATE
                          JOIN OTHP_Y1 O
                           ON O.OtherParty_IDNO = F.OtherParty_IDNO
                              AND O.EndValidity_DATE = @Ld_High_DATE
                          JOIN COPT_Y1 N
                           ON N.County_IDNO = F.County_IDNO
                    WHERE C.Case_IDNO = @An_Case_IDNO
                      AND C.StatusCase_CODE = @Lc_CaseStatusOpen_CODE) z) x UNPIVOT (Element_VALUE FOR Element_NAME IN (Case_Cnty_Selection_TEXT, County_NAME, Case_Cnty_Phone_NUMB, Cnty_Customer_Service_Phone_NUMB, Fax_NUMB)) AS pvt;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_Err_Description_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Err_Description_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
