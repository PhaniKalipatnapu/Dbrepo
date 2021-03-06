/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_DE_SDU_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_DE_SDU_ADDRESS
Programmer Name	:	IMP Team.
Description		:	This procedure returns Delaware SDU address
Frequency		:	
Developed On	:	4/19/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_DE_SDU_ADDRESS] (
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Li_Error_NUMB         INT = NULL,
          @Li_ErrorLine_NUMB     INT = NULL,
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F';
  DECLARE @Lc_Fips_ID               CHAR(7) = '',
          @Lc_Fips_Zip_ADDR         CHAR(15) = '',
          @Lc_Fips_City_ADDR        CHAR(28) = '',
          @Lc_Fips_NAME             CHAR(40) = '',
          @Ls_Fips_Line1_ADDR       VARCHAR(50) = '',
          @Ls_Fips_Line2_ADDR       VARCHAR(50) = '',
          @Ls_Fips_State_ADDR       VARCHAR(70) = '',
          @Ls_Procedure_NAME        VARCHAR(100) = '',
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_Sqldata_TEXT          VARCHAR(400) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICES$SP_GET_DE_SDU_ADDRESS';
   SET @Lc_Fips_ID = '1000000';
   SET @Lc_Fips_Name = 'Division of Child Support Enforcement';
   SET @Ls_Fips_Line1_ADDR = 'P.O. Box 12287';
   SET @Ls_Fips_Line2_ADDR = '';
   SET @Lc_Fips_City_ADDR = 'Wilmington';
   SET @Ls_Fips_State_ADDR = 'Delaware';
   SET @Lc_Fips_Zip_ADDR = '19850';
   SET @Ls_Sql_TEXT = 'SELECT FIPS_ADDRESS';
   SET @Ls_Sqldata_TEXT = 'Fips_ID = ' + ISNULL(@Lc_Fips_ID, '');

   INSERT INTO #NoticeElementsData_P1
               (Element_Name,
                Element_Value)
   (SELECT Element_Name,
           Element_Value
      FROM (SELECT CAST(a.sdu_fips_code AS VARCHAR(100)) sdu_fips_code,
                   CAST(a.sdu_name AS VARCHAR(100)) sdu_name,
                   CAST(a.sdu_line1_addr AS VARCHAR(100)) sdu_line1_addr,
                   CAST(a.sdu_line2_addr AS VARCHAR(100)) sdu_line2_addr,
                   CAST(a.sdu_city_addr AS VARCHAR(100)) sdu_city_addr,
                   CAST(a.sdu_state_addr AS VARCHAR(100)) sdu_state_addr,
                   CAST(a.sdu_zip_addr AS VARCHAR(100)) sdu_zip_addr
              FROM (SELECT @Lc_Fips_ID sdu_fips_code,
                           @Lc_Fips_Name sdu_name,
                           @Ls_Fips_Line1_ADDR AS sdu_line1_addr,
                           @Ls_Fips_Line2_ADDR sdu_line2_addr,
                           RTRIM(@Lc_Fips_City_ADDR) AS sdu_city_addr,
                           ' ' + RTRIM(@Ls_Fips_State_ADDR) + ' ' AS sdu_state_addr,
                           RTRIM(@Lc_Fips_Zip_ADDR) AS sdu_zip_addr) a)up UNPIVOT (Element_Value FOR Element_Name IN( sdu_fips_code, sdu_name, sdu_line1_addr, sdu_line2_addr, sdu_city_addr, sdu_state_addr, sdu_zip_addr ) ) AS pvt);

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
    @As_Procedure_NAME       = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT    = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT             = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT         = @Ls_SqlData_TEXT,
    @An_Error_NUMB           = @Li_Error_NUMB,
    @An_ErrorLine_NUMB       = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT= @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
