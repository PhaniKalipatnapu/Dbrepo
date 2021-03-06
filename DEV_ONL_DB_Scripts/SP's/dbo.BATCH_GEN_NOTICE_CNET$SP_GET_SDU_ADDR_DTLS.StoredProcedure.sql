/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	BATCH_GEN_NOTICE_CM$SP_GENERATE_NOTICE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS] 
(
   @Ac_StateFips_CODE                 CHAR(8),
   @Ac_TypeAddress_CODE               CHAR(3),
   @Ac_SubTypeAddress_CODE            CHAR(3),
   @As_Prefix_TEXT                    VARCHAR(100) = 'Agency',
   @Ac_Msg_CODE                       CHAR(5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR(4000) OUTPUT)
AS

BEGIN

  DECLARE  @Lc_StatusSuccess_CODE		  CHAR    = 'S',
           @Lc_StatusFailed_CODE		  CHAR	  = 'F',
		   @Lc_UnderScore				  CHAR    = '_',
		   @Lc_Space_TEXT				  CHAR    = ' ',
		   @Lc_CountyFips45_CODE		  CHAR(2) = '45',
		   @Lc_TypeAddressInt_CODE		  CHAR(3) = 'INT',
		   @Lc_SubTypeAddressFrc_CODE     CHAR(3) = 'FRC',
		   @Lc_PrefixAgency_TEXT		  CHAR(6)  = 'Agency', 
           @Ls_Procedure_NAME			  VARCHAR(100) = 'BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS ',
           @Ld_High_DATE				  DATE = '12/31/9999';
           
  DECLARE  @Ls_Sql_TEXT					  VARCHAR(200),
           @Ls_Sqldata_TEXT				  VARCHAR(400),
           @Ls_DescriptionError_TEXT	  VARCHAR(4000);

      BEGIN TRY
   
         SET @Ac_Msg_CODE = '';
         SET @As_DescriptionError_TEXT = '';
         
         SET @Ls_Sqldata_TEXT = '  StateFips_CODE = '
								+ ISNULL (@Ac_StateFips_CODE, '')
								+ ' TypeAddress_CODE = '
								+ ISNULL (@Ac_TypeAddress_CODE, '')
								+ ' SubTypeAddress_CODE = '
								+ ISNULL (@Ac_SubTypeAddress_CODE, '');
         SET @Ls_Sql_TEXT = 'SELECT FIPS_Y1 ';

         IF (@As_Prefix_TEXT IS NULL OR @As_Prefix_TEXT = '')
            BEGIN
               SET @As_Prefix_TEXT = @Lc_PrefixAgency_TEXT;
            END;

         DECLARE @Ndel_P1 TABLE
                          (
                             Element_NAME    VARCHAR(100),
                             Element_Value   VARCHAR(100)
                          );

          INSERT INTO @Ndel_P1 (Element_NAME, Element_Value)
            SELECT pvt.Element_NAME, pvt.Element_VALUE
              FROM (SELECT CAST (RTRIM(F.Fips_NAME) AS VARCHAR(50)) AS Fips_NAME,
						   CAST (RTRIM(F.Fips_NAME) AS VARCHAR(50)) AS NAME,
                           CAST (RTRIM(F.Line1_ADDR) + @Lc_Space_TEXT AS VARCHAR(50)) AS Line1_ADDR,
                           CAST (RTRIM(F.Line2_ADDR) + @Lc_Space_TEXT AS VARCHAR(50)) AS Line2_ADDR,
                           CAST (RTRIM(F.City_ADDR) AS VARCHAR(50)) AS City_ADDR,
                           CAST (@Lc_Space_TEXT + RTRIM(F.State_ADDR) + @Lc_Space_TEXT AS VARCHAR(50)) AS State_ADDR,
                           CAST (RTRIM(F.Country_ADDR) + @Lc_Space_TEXT AS VARCHAR(50))  AS Country_ADDR,
                           CAST (RTRIM(F.Zip_ADDR)+ @Lc_Space_TEXT AS VARCHAR(50)) AS Zip_ADDR,
                           CAST (F.Phone_NUMB AS VARCHAR(50)) AS Phone_NUMB,
                           CAST (F.Fax_NUMB AS VARCHAR(50)) AS Fax_NUMB,
                           CAST (F.Fips_CODE AS VARCHAR(50)) AS Fips_CODE
                      FROM FIPS_Y1 F
                     WHERE F.StateFips_CODE = SUBSTRING(CONVERT(VARCHAR(10), @Ac_StateFips_CODE), 1, 2)
        --                   AND (F.CountyFips_CODE = SUBSTRING(CONVERT(VARCHAR(10), @Ac_StateFips_CODE), 3,3) 
								--AND SUBSTRING(CONVERT(VARCHAR(10), @Ac_StateFips_CODE), 3,3)='45')
						   AND F.CountyFips_CODE = Case WHEN SUBSTRING(CONVERT(VARCHAR(10), @Ac_StateFips_CODE), 1, 2) = @Lc_CountyFips45_CODE THEN 
														SUBSTRING(CONVERT(VARCHAR(10), @Ac_StateFips_CODE), 3,3) 
													ELSE
														F.CountyFips_CODE
													END
								--13738 - CR0440 INT-02 UIFSA Transmittal 2 Changes Requested by Workers 20141120 - Fix - START
								AND ((F.TypeAddress_CODE = @Ac_TypeAddress_CODE
										AND F.SubTypeAddress_CODE = @Ac_SubTypeAddress_CODE)
										OR (F.TypeAddress_CODE = @Lc_TypeAddressInt_CODE AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE))
								--13738 - CR0440 INT-02 UIFSA Transmittal 2 Changes Requested by Workers 20141120 - Fix - END
                           AND F.EndValidity_DATE =  @Ld_High_DATE
                           ) U 
                           UNPIVOT (Element_VALUE FOR Element_NAME IN 
								(
                                   U.Fips_NAME, U.NAME, U.Line1_ADDR, U.Line2_ADDR, U.City_ADDR,
                                   U.State_ADDR, U.Country_ADDR, U.Zip_ADDR, U.Phone_NUMB,
                                   U.Fax_NUMB, U.Fips_CODE)) pvt;
 
         INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
            SELECT RTRIM(@As_Prefix_TEXT) + @Lc_UnderScore + T.Element_NAME AS Element_NAME, T.Element_Value
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
               SET @Ls_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
   END;

GO
