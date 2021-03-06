/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_MEM_LAST_KNOWN_ADDR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_MEM_LAST_KNOWN_ADDR
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_MEM_LAST_KNOWN_ADDR](
 @An_MemberMci_IDNO NUMERIC(10),
 @Ac_Msg_CODE       CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT     VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  DECLARE @Ls_VerificationStatusBad_CODE  CHAR = 'B',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Lc_StatusSuccess_CODE          CHAR = 'S',
          @Ls_StatusNoDataFound_CODE      CHAR = 'N',
          @Ls_DoubleSpace_TEXT            VARCHAR(2) = '  ',
          @Lc_StatusFailed_CODE           CHAR = 'F',
          @Lc_Residential_ADDR            CHAR(1)= 'R',          
          @Lc_Mailing_ADDR                CHAR(1)='M',
          @Lc_VerificationStatusGood_CODE CHAR = 'Y',
          @Lc_VerificationStatusBad_CODE  CHAR = 'B',
          @Lc_CheckBox_value              CHAR(1) = 'X',
          @Ls_TypeOthpE1_CODE             CHAR(1) = 'E',
          @Ls_MsgZ1_CODE                  CHAR(1) = 'Z',
          @Ls_Sql_TEXT                    CHAR(1) = ' ',
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_Procedure_NAME                VARCHAR(100) ='BATCH_GEN_NOTICE_MEMBER$SP_MEM_LAST_KNOWN_ADDR ',
          @Ls_Sqldata_TEXT                VARCHAR(400),
          @Ln_OthpPartyEmpl_IDNO          NUMERIC(9)

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR), '');
   SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1';
   
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT pvt.Element_NAME,
           pvt.Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(100), A.Mail_CODE)        AS LAST_KNOWN_Mail_CODE,
                   CONVERT(VARCHAR(100), A.Residential_CODE) AS LAST_KNOWN_Residential_CODE,
                   CONVERT(VARCHAR(100), A.Attn_ADDR)        AS LAST_KNOWN_Attn_ADDR,
                   CONVERT(VARCHAR(100), A.Line1_ADDR)       AS LAST_KNOWN_Line1_ADDR,
                   CONVERT(VARCHAR(100), A.Line2_ADDR)       AS LAST_KNOWN_Line2_ADDR,
                   CONVERT(VARCHAR(100), A.City_ADDR)        AS LAST_KNOWN_City_ADDR,
                   CONVERT(VARCHAR(100), A.State_ADDR)       AS LAST_KNOWN_State_ADDR,
                   CONVERT(VARCHAR(100), A.Zip_ADDR)         AS LAST_KNOWN_Zip_ADDR,
                   CONVERT(VARCHAR(100), A.Country_ADDR)     AS LAST_KNOWN_Country_ADDR,
                   CONVERT(VARCHAR(100), A.Verified_CODE)    AS LAST_KNOWN_ADDR_Verified_CODE,
                   CONVERT(VARCHAR(100), A.Status_DATE)      AS Status_DATE,
                   CONVERT(VARCHAR(100), A.Phone_NUMB)       AS LAST_KNOWN_ADDR_Phone_NUMB
              FROM (SELECT CASE
                            WHEN AH.TypeAddress_CODE = @Lc_Mailing_ADDR
                             THEN 'X'
                            ELSE ' '
                           END  Mail_CODE,
                           CASE
                            WHEN AH.TypeAddress_CODE = @Lc_Residential_ADDR
                             THEN  'X'
                            ELSE ' '
                           END Residential_CODE,
                           AH.Attn_ADDR,
                           AH.Line1_ADDR,
                           AH.Line2_ADDR,
                           AH.City_ADDR,
                           AH.State_ADDR,
                           AH.Zip_ADDR,
                           --AH.Country_ADDR,
						   CASE WHEN RTRIM(AH.Country_ADDR)= 'US' THEN '' ELSE RTRIM(AH.Country_ADDR) END Country_ADDR,
                           CASE
                            WHEN AH.Status_CODE = @Lc_VerificationStatusGood_CODE
                             THEN 'X'
                            ELSE ' '
                           END Verified_CODE,
                           AH.Status_DATE,
                           (SELECT ISNULL(D.HomePhone_NUMB, D.WorkPhone_NUMB) 
                              FROM DEMO_Y1 D
                             WHERE D.MemberMci_IDNO = AH.MemberMci_IDNO) AS  Phone_NUMB
                      FROM (SELECT A.MemberMci_IDNO ,
                                   A.TypeAddress_CODE,
                                   A.Attn_ADDR,
                                   A.Line1_ADDR,
                                   A.Line2_ADDR,
                                   A.City_ADDR,
                                   A.State_ADDR,
                                   A.Zip_ADDR,
                                   A.Country_ADDR,
                                   A.Status_CODE,
                                   A.Status_DATE,
                                   ROW_NUMBER() OVER ( 
                                      PARTITION BY MemberMci_IDNO ORDER BY Status_CODE DESC, End_DATE DESC, 
                                       TransactionEventSeq_NUMB DESC) Row_NUMB
                              FROM AHIS_Y1 A
                             WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
                               AND A.Status_CODE <> @Lc_VerificationStatusBad_CODE) AH
                     WHERE AH.Row_NUMB = 1)a) up UNPIVOT (Element_VALUE
                               FOR Element_NAME IN (LAST_KNOWN_Mail_CODE,
													LAST_KNOWN_Residential_CODE,
													LAST_KNOWN_Attn_ADDR,
													LAST_KNOWN_Line1_ADDR,
													LAST_KNOWN_Line2_ADDR,
													LAST_KNOWN_City_ADDR,
													LAST_KNOWN_State_ADDR,
													LAST_KNOWN_Zip_ADDR,
													LAST_KNOWN_Country_ADDR,
													LAST_KNOWN_ADDR_Verified_CODE,
													Status_DATE,
													LAST_KNOWN_ADDR_Phone_NUMB
									) ) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;

         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

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
  END CATCH
 END


GO
