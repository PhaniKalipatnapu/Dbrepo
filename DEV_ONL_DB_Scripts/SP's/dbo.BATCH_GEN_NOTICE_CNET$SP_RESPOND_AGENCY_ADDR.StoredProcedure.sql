/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_RESPOND_AGENCY_ADDR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_RESPOND_AGENCY_ADDR
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_RESPOND_AGENCY_ADDR] (
   @An_Case_IDNO                      NUMERIC(6),
   @An_OrderSeq_NUMB                  NUMERIC(2),
   @Ac_Msg_CODE                       CHAR(5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR(4000) OUTPUT)
AS
   BEGIN
      SET  NOCOUNT ON;

      DECLARE
         @An_Three_NUMB INT = 3,
         @Ls_AddressTypeState_CODE VARCHAR(3) = 'STA',
         @Ls_AddressTypeLocate_CODE VARCHAR(3) = 'LOC',
         @As_AddressTypeCrg_CODE VARCHAR(3) = 'CRG',
         @As_AddressTypeC01_CODE VARCHAR(3) = 'C01',
         @Ld_High_DATE DATE = '12/31/9999',
         @Lc_StatusSuccess_CODE CHAR(1) = 'S',
         @Lc_StatusFailed_CODE CHAR(1) = 'F',
         @Lc_CentralFips_CODE CHAR(5) = '00000',
         @Ls_Procedure_NAME VARCHAR(100) = 'BATCH_GEN_NOTICE_CNET.BATCH_GEN_NOTICE_CNET$SP_RESPOND_AGENCY_ADDR ';

      DECLARE
         @Lc_LocalFips_CODE CHAR(5) = NULL,
         @Lc_SordIssuingOrderFips_CODE CHAR(7) = '',
         @Ls_Sql_TEXT VARCHAR(200),
         @Ls_Sqldata_TEXT VARCHAR(1000),
         @Ls_DescriptionError_TEXT VARCHAR(4000);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;

         SET @Ls_Sqldata_TEXT = 'Case_IDNO = '
                + CAST(@An_Case_IDNO AS VARCHAR)
                + ' @An_OrderSeq_NUMB = '
                + CAST (@An_OrderSeq_NUMB AS VARCHAR);
         SET @Ls_Sql_TEXT = 'SELECT SORD_Y1 ';

         SELECT @Lc_SordIssuingOrderFips_CODE = S.IssuingOrderFips_CODE,
                @Lc_LocalFips_CODE = SUBSTRING (S.IssuingOrderFips_CODE, 3, 5)
           FROM SORD_Y1 S
          WHERE     S.Case_IDNO = @An_Case_IDNO
                AND S.OrderSeq_NUMB = @An_OrderSeq_NUMB
                AND S.EndValidity_DATE = @Ld_High_DATE;

         SET @Ls_Sqldata_TEXT = ' Fips_CODE = ' + @Lc_SordIssuingOrderFips_CODE;
         SET @Ls_Sql_TEXT = 'SELECT FIPS_Y1 ';

         DECLARE @Ndel_P1 TABLE
                          (
                             Element_NAME    VARCHAR(100),
                             Element_Value   VARCHAR(100)
                          );

         INSERT INTO @Ndel_P1 (Element_NAME, Element_Value)
            SELECT pvt.Element_NAME, pvt.Element_VALUE
              FROM (SELECT CAST (F.Fips_NAME AS VARCHAR(50)) AS Fips_NAME,
                           CAST (F.Line1_ADDR AS VARCHAR(50)) AS Line1_ADDR,
                           CAST (F.Line2_ADDR AS VARCHAR(50)) AS Line2_ADDR,
                           CAST (F.City_ADDR AS VARCHAR(50)) AS City_ADDR,
                           CAST (F.State_ADDR AS VARCHAR(50)) AS State_ADDR,
                           CAST (RTRIM(F.Country_ADDR) AS VARCHAR(50))
                              AS Country_ADDR,
                           CAST (F.Zip_ADDR AS VARCHAR(50)) AS Zip_ADDR,
                           CAST (F.Phone_NUMB AS VARCHAR(50)) AS Phone_NUMB,
                           CAST (F.Fax_NUMB AS VARCHAR(50)) AS Fax_NUMB,
                           CAST (F.Fips_CODE AS VARCHAR(50)) AS Fips_CODE
                      FROM FIPS_Y1 F
                     WHERE F.Fips_CODE = @Lc_SordIssuingOrderFips_CODE
                           AND ( (@Lc_LocalFips_CODE = @Lc_CentralFips_CODE
                                  AND F.TypeAddress_CODE = @Ls_AddressTypeState_CODE
                                  AND F.SubTypeAddress_CODE = @As_AddressTypeCrg_CODE)
                                OR (@Lc_LocalFips_CODE != @Lc_CentralFips_CODE
                                    AND F.TypeAddress_CODE = @Ls_AddressTypeLocate_CODE
                                    AND F.SubTypeAddress_CODE = @As_AddressTypeC01_CODE))
                                ) U UNPIVOT (Element_VALUE FOR Element_NAME IN 
										(U.Fips_NAME, U.Line1_ADDR, U.Line2_ADDR, U.City_ADDR, 
										 U.State_ADDR, U.Country_ADDR, U.Zip_ADDR, U.Phone_NUMB, 
										 U.Fax_NUMB, U.Fips_CODE)) pvt;

         UPDATE @Ndel_P1
            SET Element_NAME = 'Tribunal' + Element_NAME;

         INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
            SELECT T.Element_NAME, T.Element_Value
              FROM @Ndel_P1 T;

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE ();

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
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH;
   END;


GO
