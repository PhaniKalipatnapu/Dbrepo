/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_EMPLOYER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_EMPLOYER
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	4/19/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_EMPLOYER] (
   @An_MemberMci_IDNO                 NUMERIC (10),
   @As_Prefix_TEXT                    VARCHAR (70),
   @Ad_Run_DATE                       DATE,
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
    AS
   BEGIN
      SET  NOCOUNT ON;

      DECLARE
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Lc_Yes_TEXT CHAR (1) = 'Y',
         @Lc_StatusBad_CODE CHAR (1) = 'B',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_EMPLOYER';

      DECLARE
         @Ln_OthpPartyEmpl_IDNO NUMERIC (10) = NULL,
         @Lc_Status_CODE CHAR (1),
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (1000),
         @Ls_DescriptionError_TEXT VARCHAR (4000),
         @Lc_StatusDATE_TEXT VARCHAR(10);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;

         IF (@An_MemberMci_IDNO IS NOT NULL AND @An_MemberMci_IDNO != 0)
            BEGIN
               DECLARE @Ndel_P1 TABLE
                                (
                                   Element_NAME    VARCHAR (100),
                                   Element_Value   VARCHAR (100)
                                );


               SET @Ls_Sql_TEXT = 'SELECT EHIS_Y1';
               SET @Ls_Sqldata_TEXT =
                        ' MemberMci_IDNO = '
                      + CAST (ISNULL (@An_MemberMci_IDNO, 0) AS VARCHAR (10))
                      + ' Run_DATE = '
                      + CAST (@Ad_Run_DATE AS VARCHAR (10));
               SELECT TOP 1
                      @Ln_OthpPartyEmpl_IDNO = E.OthpPartyEmpl_IDNO,
                      @Lc_StatusDATE_TEXT = (CASE WHEN E.Status_CODE = 'Y' THEN CONVERT(VARCHAR(10), E.Status_DATE, 101) ELSE '' END),
                      @Lc_Status_CODE = (CASE WHEN E.Status_CODE = 'Y' THEN 'X' ELSE '' END)
                 FROM EHIS_Y1 AS e
                WHERE     e.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND e.EmployerPrime_INDC = @Lc_Yes_TEXT
                      AND e.OthpPartyEmpl_IDNO != 0
                      AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
                      AND e.Status_CODE != @Lc_StatusBad_CODE;

               INSERT INTO @Ndel_P1 (Element_NAME, Element_VALUE)
               VALUES ('OthpPartyEmpl_IDNO', CAST (@Ln_OthpPartyEmpl_IDNO AS VARCHAR (10)));

               INSERT INTO @Ndel_P1 (Element_NAME, Element_VALUE)
               VALUES ('Status_DATE', CAST (@Lc_StatusDATE_TEXT AS VARCHAR (10)));

               INSERT INTO @Ndel_P1 (Element_NAME, Element_VALUE)
               VALUES ('Status_CODE', @Lc_Status_CODE);

               INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
                  SELECT RTRIM (@As_Prefix_TEXT) + '_' + TE.Element_NAME AS Element_NAME,
                         TE.Element_VALUE
                    FROM @Ndel_P1 TE
                   WHERE Element_NAME IN ('Status_DATE', 'Status_CODE')
            END

         IF @Ln_OthpPartyEmpl_IDNO IS NOT NULL AND @Ln_OthpPartyEmpl_IDNO != 0
            BEGIN
               EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS @An_OtherParty_IDNO = @Ln_OthpPartyEmpl_IDNO,
                                                         @As_Prefix_TEXT   = @As_Prefix_TEXT,
                                                         @Ac_Msg_CODE = @Ac_Msg_CODE OUTPUT,
                                                         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT

               IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
                  RETURN;
            END

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;
         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB       = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END

GO
