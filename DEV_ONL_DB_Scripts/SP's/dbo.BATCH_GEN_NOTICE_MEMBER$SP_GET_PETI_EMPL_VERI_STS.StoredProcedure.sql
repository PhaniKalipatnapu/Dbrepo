/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_PETI_EMPL_VERI_STS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_PETI_EMPL_VERI_STS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_PETI_EMPL_VERI_STS]
   @An_Case_IDNO                      NUMERIC (6),
   @Ad_Run_DATE                       DATE,
   @Ac_Msg_CODE                       CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT
AS
   BEGIN
      SET  NOCOUNT ON;

      DECLARE
         @Lc_EmployedStatusX1_CODE VARCHAR (1),
         @Lc_EmployedStatusN1_CODE VARCHAR (1),
         @Lc_DescriptionOccupation_TEXT CHAR (32),
         @Lc_CaseRelationshipCp_CODE CHAR (1) = 'C',
         @Lc_StatusCaseMemberActive_CODE CHAR (1) = 'A',
         @Ls_Yes_TEXT CHAR (1) = 'Y',
         @Ls_Space_TEXT CHAR (1) = ' ',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Ls_StatusNoDataFound_CODE CHAR (1) = 'N',
         @Ls_CheckBoxX1_TEXT CHAR (1) = 'X',
         @Ls_Routine_TEXT VARCHAR (100),
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (1000),
         @Ls_DescriptionError_TEXT VARCHAR (4000),
         @Lc_Status_CODE CHAR (1);

      BEGIN TRY
         SET @Lc_EmployedStatusX1_CODE = NULL;
         SET @Lc_EmployedStatusN1_CODE = NULL;
         SET @Lc_DescriptionOccupation_TEXT = NULL;
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_PETI_EMPL_VERI_STS ';
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL (CAST (@An_Case_IDNO AS VARCHAR (6)), '');
         SET @Ls_Sql_TEXT = 'SELECT CASE_Y1CMEM_Y1 EHIS_Y1';

         SELECT @Lc_Status_CODE = e.Status_CODE,
                @Lc_DescriptionOccupation_TEXT = e.DescriptionOccupation_TEXT
           FROM EHIS_Y1 e
                JOIN CMEM_Y1 m
                   ON     e.MemberMci_IDNO = m.MemberMci_IDNO
                      AND m.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
                      AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
                JOIN CASE_Y1 c
                   ON c.Case_IDNO = m.Case_IDNO
          WHERE c.Case_IDNO = @An_Case_IDNO
                AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE;

         IF @Lc_Status_CODE = @Ls_Yes_TEXT
            BEGIN
               SET @Lc_EmployedStatusX1_CODE = @Ls_CheckBoxX1_TEXT;
               SET @Lc_EmployedStatusN1_CODE = @Ls_Space_TEXT;
            END
         ELSE
            BEGIN
               SET @Lc_EmployedStatusN1_CODE = @Ls_CheckBoxX1_TEXT;
               SET @Lc_EmployedStatusX1_CODE = @Ls_Space_TEXT;
            END

         INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
            (SELECT pvt.Element_NAME, pvt.Element_Value
               FROM (SELECT CONVERT (VARCHAR (100), PETITIONER_DESC_OCCUPATION)
                               PETITIONER_DESC_OCCUPATION,
                            CONVERT (VARCHAR (100), PETITIONER_EMPLOYED_NO) PETITIONER_EMPLOYED_NO,
                            CONVERT (VARCHAR (100), PETITIONER_EMPLOYED_YES)
                               PETITIONER_EMPLOYED_YES
                       FROM (SELECT @Lc_DescriptionOccupation_TEXT AS PETITIONER_DESC_OCCUPATION,
                                    @Lc_EmployedStatusX1_CODE AS PETITIONER_EMPLOYED_NO,
                                    @Lc_EmployedStatusN1_CODE AS PETITIONER_EMPLOYED_YES) h) up 
                                    UNPIVOT (Element_Value FOR Element_NAME IN (PETITIONER_DESC_OCCUPATION, PETITIONER_EMPLOYED_NO, PETITIONER_EMPLOYED_YES)) AS pvt);

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         DECLARE @Li_Error_NUMB INT = ERROR_NUMBER (), @Li_ErrorLine_NUMB INT = ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Sql_TEXT,
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
