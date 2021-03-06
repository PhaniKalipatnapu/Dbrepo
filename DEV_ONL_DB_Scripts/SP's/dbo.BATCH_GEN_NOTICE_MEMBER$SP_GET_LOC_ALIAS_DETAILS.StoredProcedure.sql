/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_LOC_ALIAS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_LOC_ALIAS_DETAILS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/10/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_LOC_ALIAS_DETAILS] (
   @An_MemberMci_IDNO                 NUMERIC (10),
   @As_Prefix_TEXT                    VARCHAR (70), 
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS
  BEGIN
   SET NOCOUNT ON;
      DECLARE
         @Lc_Space_TEXT CHAR (1) = ' ',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Lc_TypeAliasA1_CODE CHAR (1) = 'A',
         @Lc_TypeAliasM1_CODE CHAR (1) = 'M',
         @Lc_TypeAliasX1_CODE CHAR (1) = 'X',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_LOC_ALIAS_DETAILS',
         @Ld_High_DATE DATE = '12/31/9999';

      DECLARE
         @Li_RowCount_QNTY INT,
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (1000),
         @Ls_DescriptionError_TEXT VARCHAR (4000);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         SET @Ls_Sql_TEXT = 'SELECT_VAKAX';
         SET @Ls_Sqldata_TEXT =
                ' MemberMci_IDNO = ' + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR (10)), '');
        
        
         DECLARE @NDEL_P1 TABLE
                          (
                             Element_NAME    VARCHAR (150),
                             Element_VALUE   VARCHAR (100)
                          );

         
         INSERT INTO @NDEL_P1 
               (Element_NAME,
                Element_Value)
            (SELECT pvt.Element_NAME, pvt.Element_Value
               FROM (SELECT CONVERT (VARCHAR (70), AliasFml_NAME) FML_LOC_ALIAS_NAME,
							CONVERT (VARCHAR (70), FirstAlias_NAME)	FirstAlias_NAME,
							CONVERT (VARCHAR (70), MiddleAlias_NAME) MiddleAlias_NAME,
							CONVERT (VARCHAR (70), LastAlias_NAME)	LastAlias_NAME,
							
                            CONVERT (VARCHAR (70), CHECKBOX1) TypeAliasA1_CODE,
                            CONVERT (VARCHAR (70), CHECKBOX2) TypeAliasM1_CODE,
                            CONVERT (VARCHAR (70), CHECKBOX3) TypeAliasX1_CODE
                       FROM (SELECT   ISNULL ( (a.FirstAlias_NAME), '')
                                    + @Lc_Space_TEXT
                                    + ISNULL ( (a.MiddleAlias_NAME), '')
                                    + @Lc_Space_TEXT
                                    + ISNULL ( (a.LastAlias_NAME), '')
                                       AliasFml_NAME,
                                       a.FirstAlias_NAME,
                                       a.MiddleAlias_NAME,
                                       a.LastAlias_NAME,
                                    (CASE
                                        WHEN a.TypeAlias_CODE = @Lc_TypeAliasA1_CODE THEN 'X'
                                        ELSE ' '
                                     END)
                                       CHECKBOX1,
                                    (CASE
                                        WHEN a.TypeAlias_CODE = @Lc_TypeAliasM1_CODE THEN 'X'
                                        ELSE ' '
                                     END)
                                       CHECKBOX2,
                                    (CASE
                                        WHEN a.TypeAlias_CODE = @Lc_TypeAliasX1_CODE THEN 'X'
                                        ELSE ' '
                                     END)
                                       CHECKBOX3
                               FROM AKAX_Y1 a
                              WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
                                    AND a.TypeAlias_CODE IN
                                           (@Lc_TypeAliasA1_CODE, @Lc_TypeAliasM1_CODE)
                                    AND a.EndValidity_DATE = @Ld_High_DATE
                                    AND a.Sequence_NUMB =
                                           (SELECT MAX (b.Sequence_NUMB) --AS expr
                                              FROM AKAX_Y1  b
                                             WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                                                   AND b.TypeAlias_CODE IN
                                                          (@Lc_TypeAliasA1_CODE,
                                                           @Lc_TypeAliasM1_CODE)
                                                   AND a.EndValidity_DATE = b.EndValidity_DATE)) a) up 
                                                   UNPIVOT (Element_Value FOR Element_NAME IN (FML_LOC_ALIAS_NAME, FirstAlias_NAME, MiddleAlias_NAME, LastAlias_NAME,
                                                     TypeAliasA1_CODE, TypeAliasM1_CODE, TypeAliasX1_CODE)) AS pvt);

         SET @Li_RowCount_QNTY = @@ROWCOUNT;

         IF @Li_RowCount_QNTY = 0
            BEGIN
               INSERT INTO @NDEL_P1 
                         (Element_NAME,
                          ELEMENT_VALUE)
                  (SELECT Element_NAME, Element_Value
                     FROM (SELECT CONVERT (VARCHAR (70), AliasFml_NAME) AS FML_LOC_ALIAS_NAME,
                                  CONVERT (VARCHAR (70), CHECKBOX1) AS TypeAliasA1_CODE,
                                  CONVERT (VARCHAR (70), CHECKBOX1) AS TypeAliasM1_CODE,
                                  CONVERT (VARCHAR (70), CHECKBOX1) AS TypeAliasX1_CODE
                             FROM (SELECT AliasFml_NAME,
                                          (CASE
                                              WHEN b.AliasType_CODE = @Lc_TypeAliasA1_CODE THEN 'X'
                                              ELSE ' '
                                           END)
                                             CHECKBOX1,
                                          (CASE
                                              WHEN b.AliasType_CODE = @Lc_TypeAliasM1_CODE THEN 'X'
                                              ELSE ' '
                                           END)
                                             CHECKBOX2,
                                          (CASE
                                              WHEN b.AliasType_CODE = @Lc_TypeAliasX1_CODE THEN 'X'
                                              ELSE ' '
                                           END)
                                             CHECKBOX3
                                     FROM (SELECT d.MotherMaiden_NAME AS AliasFml_NAME,
                                                  (CASE
                                                      WHEN d.MotherMaiden_NAME =''
                                                      THEN
                                                         @Lc_TypeAliasX1_CODE
                                                      ELSE
                                                         @Lc_Space_TEXT
                                                   END)
                                                     AliasType_CODE
                                             FROM DEMO_Y1 d
                                            WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO) b) a) up UNPIVOT (Element_Value FOR Element_NAME IN (FML_LOC_ALIAS_NAME, TypeAliasA1_CODE, TypeAliasM1_CODE, TypeAliasX1_CODE)) AS pvt);
            END
         SET @Ls_Sql_TEXT='SELECT #NoticeElementsData_P1 ';
         SET @Ls_Sqldata_TEXT='Element_NAME = @As_Prefix_TEXT';
          INSERT INTO #NoticeElementsData_P1 
                      (Element_NAME,
                       Element_VALUE)
            SELECT RTRIM (@As_Prefix_TEXT) + '_' + TE.Element_NAME AS Element_NAME,
                   TE.Element_VALUE
              FROM @NDEL_P1 TE;

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         DECLARE @Ln_Error_NUMB NUMERIC (11), @Ln_ErrorLine_NUMB NUMERIC (11);

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
   END

GO
