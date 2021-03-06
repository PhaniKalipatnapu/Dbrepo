/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_MAILING_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_MAILING_ADDRESS] (@An_MemberMci_IDNO                 NUMERIC (10),
															 @Ad_Run_DATE						DATE,
                                                             @As_Prefix_TEXT                    VARCHAR (50),
                                                             @Ac_Msg_CODE                       CHAR (5) OUTPUT,
                                                             @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS
   /*
   --------------------------------------------------------------------------------------------------------------------
   Procedure Name      : BATCH_GEN_NOTICE_CM$SP_GET_MAILING_ADDRESS
   Programmer Name     : IMP Team.
   Description         : This procedure is used to get address details from AHIS_V1
   Frequency           :
   Developed On        : 02-AUG-2011
   Called By           : BATCH_GEN_NOTICE_CM$SP_GET_CP_MAILING_ADDRESS
   Called On           :
   --------------------------------------------------------------------------------------------------------------------
   Modified By         :
   Modified On         :
   Version No          : 1.0
   --------------------------------------------------------------------------------------------------------------------
   */

   BEGIN
      DECLARE
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Ls_TypeAddressMailing_CODE CHAR (1) = 'M',
         @Ls_VerificationStatusGood_CODE CHAR (1) = 'Y',
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_CM$SP_GET_MAILING_ADDRESS ';
      DECLARE
         @Ls_MemberMci_IDNO VARCHAR (10),
         @Ls_Sql_TEXT VARCHAR (200) = 'SELECT AHIS_Y1',
         @Ls_SqlData_TEXT VARCHAR (400) = 'MemberMci_IDNO =' + ISNULL (CAST (@An_MemberMci_IDNO AS CHAR), ''),
         @Ls_DescriptionError_TEXT VARCHAR (4000) = '';
         
      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;

         IF (@An_MemberMci_IDNO IS NOT NULL AND @An_MemberMci_IDNO <> 0)
            BEGIN
         DECLARE @NoticeElementsData_P1 AS TABLE
          (
               Element_NAME  VARCHAR(100),
               Element_VALUE VARCHAR(100)
          );

               INSERT INTO @NoticeElementsData_P1 (Element_NAME, Element_VALUE)
                  (SELECT pvt.Element_NAME, pvt.Element_VALUE
                     FROM (SELECT CONVERT (VARCHAR (100), a.Attn_ADDR + ' ') AS Attn_ADDR,
                                  CONVERT (VARCHAR (100), a.Line1_ADDR + ' ') AS Line1_ADDR,
                                  CONVERT (VARCHAR (100), a.Line2_ADDR + ' ') AS Line2_ADDR,
                                  CONVERT (VARCHAR (100), a.City_ADDR + ' ') AS City_ADDR,
                                  CONVERT (VARCHAR (100), a.State_ADDR + ' ') AS State_ADDR,
                                  CONVERT (VARCHAR (100), a.Zip_ADDR) AS Zip_ADDR,
                                  CONVERT (VARCHAR (100), ' ' + a.Country_ADDR) AS Country_ADDR
                             FROM (SELECT RTRIM(a.Attn_ADDR) + ' ' AS Attn_ADDR,
                                          RTRIM(a.Line1_ADDR) + ' ' AS Line1_ADDR, 
										  RTRIM(a.Line2_ADDR) + ' ' AS Line2_ADDR,
										  RTRIM(a.City_ADDR) AS City_ADDR, 
										  ' ' + RTRIM(a.State_ADDR) + ' '  AS State_ADDR, 
										  RTRIM(a.Zip_ADDR) AS Zip_ADDR, 
										  ' ' + RTRIM(a.Country_ADDR) AS Country_ADDR
                                     FROM AHIS_Y1 a
                                    WHERE     a.MemberMci_IDNO = @An_MemberMci_IDNO
                                          AND a.TypeAddress_CODE = @Ls_TypeAddressMailing_CODE
                                          AND a.Status_CODE = @Ls_VerificationStatusGood_CODE
                                          AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE) a) 
                                          up UNPIVOT (Element_VALUE FOR Element_NAME IN (
                                                      Attn_ADDR, Line1_ADDR, Line2_ADDR, City_ADDR,
                                                      State_ADDR, Zip_ADDR, Country_ADDR)) AS pvt);

               INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
                  SELECT RTRIM (@As_Prefix_TEXT) + '_' + E.Element_NAME AS Element_NAME, E.Element_VALUE
                    FROM @NoticeElementsData_P1 E;

           
            END

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         DECLARE @Li_Error_NUMB INT = ERROR_NUMBER (), @Li_ErrorLine_NUMB INT = ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME      = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT   = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT            = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT        = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB          = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB      = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT ;
      END CATCH
   END

GO
