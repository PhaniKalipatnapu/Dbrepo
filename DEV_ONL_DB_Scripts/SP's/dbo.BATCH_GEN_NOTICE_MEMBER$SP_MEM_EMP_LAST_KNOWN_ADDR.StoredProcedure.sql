/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_MEM_EMP_LAST_KNOWN_ADDR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_MEM_EMP_LAST_KNOWN_ADDR
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_MEM_EMP_LAST_KNOWN_ADDR] (
   @An_MemberMci_IDNO                 NUMERIC (10),
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS
   BEGIN
      DECLARE
         @Ls_VerificationStatusBad_CODE CHAR (1) = 'B',
         @Ld_High_DATE DATE = '12/31/9999',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Ls_StatusNoDataFound_CODE CHAR (1) = 'N',
         @Ls_DoubleSpace_TEXT VARCHAR (2) = '  ',
         @Lc_StatusFailed_CODE CHAR = 'F',
         @Ls_TypeOthpE1_CODE CHAR (1) = 'E',
         @Ls_MsgZ1_CODE CHAR (1) = 'Z',
         @Ls_DescriptionError_TEXT VARCHAR (4000),
         @Ls_Procedure_NAME VARCHAR (100)
            = 'BATCH_GEN_NOTICE_MEMBER$SP_MEM_EMP_LAST_KNOWN_ADDR ',
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (400),
         @Ln_OthpPartyEmpl_IDNO NUMERIC (9);

      BEGIN TRY
         --Remove once we have data for lkc emp address'
        
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         SET @Ls_Sqldata_TEXT =
                ' MemberMci_IDNO = '
                + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR), '');
         SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
         SET @Ls_Sqldata_TEXT =
                ' OtherParty_IDNO = '
                + ISNULL (CAST (@Ln_OthpPartyEmpl_IDNO AS CHAR), '');
         SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';

         WITH Emp_CTE
                 AS (SELECT a.OthpPartyEmpl_IDNO,
                            a.Status_CODE,
                            a.Status_DATE
                       FROM (SELECT e.OthpPartyEmpl_IDNO,
                                    e.Status_CODE,
                                    e.Status_DATE,
                                    ROW_NUMBER ()
                                    OVER (
                                       PARTITION BY e.MemberMci_IDNO
                                       ORDER BY
                                          e.Status_CODE DESC,
                                          e.EndEmployment_DATE DESC,
                                          e.TransactionEventSeq_NUMB DESC)
                                       AS Row_NUMB
                               FROM EHIS_Y1 e
                              WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                                    AND e.Status_CODE <> @Ls_VerificationStatusBad_CODE) a
                      WHERE a.Row_NUMB = 1)
         INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
            (SELECT pvt.Element_NAME, pvt.Element_VALUE
               FROM (SELECT CONVERT (VARCHAR (100), OtherParty_NAME) AS LAST_KNOWN_EMP_NAME,
                            CONVERT (VARCHAR (100), Attn_ADDR)		 AS LAST_KNOWN_EMP_Attn_ADDR,
                            CONVERT (VARCHAR (100), Line1_ADDR)      AS LAST_KNOWN_EMP_Line1_ADDR,
                            CONVERT (VARCHAR (100), Line2_ADDR)      AS LAST_KNOWN_EMP_Line2_ADDR,
                            CONVERT (VARCHAR (100), City_ADDR)       AS LAST_KNOWN_EMP_City_ADDR,
                            CONVERT (VARCHAR (100), State_ADDR)      AS  LAST_KNOWN_EMP_State_ADDR,
                            CONVERT (VARCHAR (100), Zip_ADDR)        AS  LAST_KNOWN_EMP_Zip_ADDR,
                            CONVERT (VARCHAR (100), Country_ADDR)    AS  LAST_KNOWN_EMP_Country_ADDR,
                            CONVERT (VARCHAR (100), Phone_NUMB)      AS  LAST_KNOWN_EMP_Phone_NUMB,
                            CONVERT (VARCHAR (100), Fax_NUMB)        AS  LAST_KNOWN_EMP_Fax_NUMB,
                            CONVERT (VARCHAR (100), Fein_IDNO)       AS  LAST_KNOWN_EMP_Fein_IDNO,
                            CONVERT (VARCHAR (100), Status_CODE)     AS  LAST_KNOWN_EMP_Status_CODE,
                            CONVERT (VARCHAR (100), OthpPartyEmpl_IDNO) AS  OthpPartyEmpl_IDNO,
                            CONVERT (VARCHAR (100), Status_DATE)        AS  LAST_KNOWN_EMP_Status_DATE
                       FROM (SELECT o.OtherParty_NAME,
                                    o.Attn_ADDR,
                                    o.Line1_ADDR,
                                    o.Line2_ADDR,
                                    o.City_ADDR,
                                    o.State_ADDR,
                                    o.Zip_ADDR,
                                    CASE WHEN RTRIM(o.Country_ADDR)= 'US' THEN '' ELSE RTRIM(o.Country_ADDR) END Country_ADDR,
                                    o.Phone_NUMB,
                                    o.Fax_NUMB,
                                    o.Fein_IDNO,
                                    CASE
                                       WHEN e.Status_CODE = 'Y' THEN 'X'
                                       ELSE ' '
                                    END
                                       Status_CODE,
                                    e.OthpPartyEmpl_IDNO,
                                    e.Status_DATE
                               FROM    Emp_CTE E
                                    JOIN
                                       OTHP_Y1 o
                                    ON o.OtherParty_IDNO =
                                          E.OthpPartyEmpl_IDNO
                              WHERE o.TypeOthp_CODE = @Ls_TypeOthpE1_CODE
                                    AND o.EndValidity_DATE = @Ld_High_DATE) a) up 
                                    UNPIVOT (Element_VALUE FOR Element_NAME IN (
                                     LAST_KNOWN_EMP_NAME,
                                     LAST_KNOWN_EMP_Attn_ADDR,
                                     LAST_KNOWN_EMP_Line1_ADDR, 
                                     LAST_KNOWN_EMP_Line2_ADDR, 
                                     LAST_KNOWN_EMP_City_ADDR,
                                     LAST_KNOWN_EMP_State_ADDR, 
                                     LAST_KNOWN_EMP_Zip_ADDR, 
                                     LAST_KNOWN_EMP_Country_ADDR,
                                     LAST_KNOWN_EMP_Phone_NUMB, 
                                     LAST_KNOWN_EMP_Fax_NUMB, 
                                     LAST_KNOWN_EMP_Fein_IDNO,
                                     LAST_KNOWN_EMP_Status_CODE, 
                                     OthpPartyEmpl_IDNO, 
                                     LAST_KNOWN_EMP_Status_DATE)) AS pvt);

        
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
