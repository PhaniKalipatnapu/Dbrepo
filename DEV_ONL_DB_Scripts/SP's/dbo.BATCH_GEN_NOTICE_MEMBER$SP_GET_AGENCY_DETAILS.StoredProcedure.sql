/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_AGENCY_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_AGENCY_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Agency details from APAG_Y1
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_AGENCY_DETAILS] (
 @An_Application_IDNO      NUMERIC(15),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Error_NUMB              INT = NULL,
          @Li_ErrorLine_NUMB          INT = NULL,
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_Space_TEXT              CHAR(1) = ' ';
          
  DECLARE @Ls_Procedure_NAME        VARCHAR(100) = '',
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(200),
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICES$SP_GET_AGENCY_DETAILS';
   SET @Ls_Sql_TEXT = 'SELECT Apag_Y1 ';
   SET @Ls_Sqldata_TEXT = ' Application_IDNO = ' + ISNULL (CAST(@An_Application_IDNO AS VARCHAR),0);

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT pvt.Element_NAME,
           pvt.Element_VALUE
      FROM (SELECT CAST(a.ServerPath_NAME AS VARCHAR(100))AGENCY_COLLECTED_SUPPORT,
                   CAST(a.AGENCY_ATTN_ADDR AS VARCHAR(100))AGENCY_ATTN_ADDR,
                   CAST(a.AgencyLine1_ADDR AS VARCHAR(100))AGENCY_LINE1_ADDR,
                   CAST(a.AgencyLine2_ADDR AS VARCHAR(100))AGENCY_LINE2_ADDR,
                   CAST(a.AgencyCity_ADDR AS VARCHAR(100))AGENCY_CITY_ADDR,
                   CAST(a.AgencyState_ADDR AS VARCHAR(100))AGENCY_STATE_ADDR,
                   CAST(a.AgencyZip_ADDR AS VARCHAR(100))AGENCY_ZIP_ADDR,
                   CAST(a.AgencyCountry_ADDR AS VARCHAR(100))AGENCY_COUNTRY_ADDR,
                   CAST(a.AgencyPhone_NUMB AS VARCHAR(100))AGENCY_PHONE_NUMB
              FROM (SELECT g.ServerPath_NAME,
                           @Lc_Space_TEXT AS AGENCY_ATTN_ADDR,
                           RTRIM(g.AgencyLine1_ADDR) + @Lc_Space_TEXT AS AgencyLine1_ADDR,
                           RTRIM(g.AgencyLine2_ADDR) + @Lc_Space_TEXT AS AgencyLine2_ADDR,
                           RTRIM(g.AgencyCity_ADDR) AS AgencyCity_ADDR,
                           @Lc_Space_TEXT + RTRIM(g.AgencyState_ADDR) + @Lc_Space_TEXT AS AgencyState_ADDR,
                           RTRIM(g.AgencyZip_ADDR) AS AgencyZip_ADDR,
                           @Lc_Space_TEXT + RTRIM(g.AgencyCountry_ADDR) AS AgencyCountry_ADDR,
                           g.AgencyPhone_NUMB
                      FROM APAG_Y1 g
                     WHERE g.Application_IDNO = @An_Application_IDNO
                       AND g.MemberMci_IDNO = @An_MemberMci_IDNO
                  )a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (AGENCY_COLLECTED_SUPPORT, AGENCY_ATTN_ADDR, AGENCY_LINE1_ADDR, AGENCY_LINE2_ADDR, AGENCY_CITY_ADDR, AGENCY_STATE_ADDR, AGENCY_ZIP_ADDR, AGENCY_COUNTRY_ADDR, AGENCY_PHONE_NUMB )) AS pvt);

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
