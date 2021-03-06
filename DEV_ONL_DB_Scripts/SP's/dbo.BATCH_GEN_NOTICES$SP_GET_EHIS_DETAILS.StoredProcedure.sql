/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_EHIS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_EHIS_DETAILS] (
   @An_MemberMci_IDNO                 NUMERIC (10),
   @An_OtherParty_IDNO                NUMERIC (9),
   @Ad_Run_DATE                       DATE,
   @As_Prefix_TEXT                    VARCHAR (100),
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS
   /*
   ------------------------------------------------------------------------------------------------------------------------------
   Procedure Name  : BATCH_GEN_NOTICES$SP_GET_EHIS_DETAILS
   Programmer Name : IMP Team
   Description     : The procedure is used to obtain the employer details.
   Frequency       :
   Developed On    : 01/20/2011
   Called BY       : None
   Called On       :
   -------------------------------------------------------------------------------------------------------------------------------
   Modified BY     :
   Modified On  :
   Version No  : 1.0
   --------------------------------------------------------------------------------------------------------------------------------
   */

   BEGIN
      SET  NOCOUNT ON;
      DECLARE
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Lc_Addr_Verified_yes_INDC CHAR (1) = 'Y',
         @Lc_PrimaryEmp_yes_INDC CHAR (1) = 'Y',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICES$SP_GET_EHIS_DETAILS',
         @Ls_DescriptionError_TEXT VARCHAR (4000) = '',
         @Lc_TableFrqa_ID       CHAR(6)='FRQA',
         @Lc_TableSubFrq1_ID   CHAR(6)='FRQ1';
      DECLARE
         @Ln_Error_NUMB NUMERIC (11),
         @Ln_ErrorLine_NUMB NUMERIC (11),
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (400);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         IF( @As_Prefix_TEXT = NULL) 
         BEGIN
            SET @As_Prefix_TEXT ='NCP';
         END

         IF (    @An_MemberMci_IDNO IS NOT NULL
             AND @An_MemberMci_IDNO > 0
             AND @An_OtherParty_IDNO IS NOT NULL
             AND @An_OtherParty_IDNO > 0)
            BEGIN
               SET @Ls_Sql_TEXT = 'INSERT @NoticeElements_P1';
               SET @Ls_Sqldata_TEXT =
                        'MemberMci_IDNO =	'
                      + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR (10)), '')
                      + ', OthpPartyEmpl_IDNO = '
                      + ISNULL (CAST (@An_OtherParty_IDNO AS VARCHAR), '')
                      + ', Run_DATE = '
                      + ISNULL (CAST (@Ad_Run_DATE AS VARCHAR (10)), '');

               DECLARE @NoticeElements_P1 TABLE
                                          (
                                             Element_NAME    VARCHAR (100),
                                             Element_VALUE   VARCHAR (100)
                                          );

               INSERT INTO @NoticeElements_P1 (Element_NAME, Element_Value)
                  (SELECT pvt.Element_NAME, pvt.Element_Value
                     FROM (SELECT CONVERT (VARCHAR (100), a.IncomeGross_AMNT) AS GROSS_WAGE_AMNT,
                                  CONVERT (VARCHAR (100), a.FreqPay_CODE) AS PYMT_FREQ_CODE,
                                  CONVERT (VARCHAR (100), a.Status_DATE, 101) AS EMP_VER_DATE,
                                  CONVERT (VARCHAR (100), a.SourceLoc_CODE) AS EMP_VER_SOURCE_CODE,
                                  CONVERT (VARCHAR (100), a.DescriptionOCCUPATION_TEXT)
                                     AS OCCUPATION_TEXT
                               FROM (SELECT e.IncomeGross_AMNT,
                                          dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableFrqa_ID, @Lc_TableSubFrq1_ID, e.FreqPay_CODE)FreqPay_CODE,
                                          e.Status_DATE,
                                          CASE WHEN e.SourceLocConf_CODE != '' THEN 'X' ELSE '' END SourceLoc_CODE,
                                          e.DescriptionOCCUPATION_TEXT
                                       FROM EHIS_Y1 e
                                    WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
                                          AND e.OthpPartyEmpl_IDNO = @An_OtherParty_IDNO
                                          AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE
                                                               AND e.EndEmployment_DATE
                                          AND e.Status_CODE = @Lc_Addr_Verified_yes_INDC) a)
                                           up UNPIVOT (Element_Value FOR
                                             Element_NAME IN (GROSS_WAGE_AMNT, PYMT_FREQ_CODE, EMP_VER_DATE,
                                             EMP_VER_SOURCE_CODE, OCCUPATION_TEXT)) AS pvt);

               SET @Ls_Sql_TEXT = 'INSERT @NoticeElements_P1';
               SET @Ls_Sqldata_TEXT = ' Element_NAME = ' + @As_Prefix_TEXT;


               INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
               SELECT @As_Prefix_TEXT + '_' + TE.Element_NAME AS Element_NAME, TE.Element_VALUE
                 FROM @NoticeElements_P1 TE;
            END;
            SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
                @Ln_Error_NUMB = ERROR_NUMBER (),
                @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF ERROR_NUMBER () <> 50001
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB       = @Ln_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Ln_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;
         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END;

GO
