/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_NON_DISCLOSURE_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_NON_DISCLOSURE_OPTS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to fetch Parent Guardian and caretaker non Disclosure findings details
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_NON_DISCLOSURE_OPTS] (
 @An_Case_IDNO             NUMERIC (6),
 @An_MotherMci_IDNO        NUMERIC (10),
 @An_FatherMci_IDNO        NUMERIC (10),
 @An_CaretakerMci_IDNO     NUMERIC (10),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_Yes_INDC                  CHAR(1) = 'Y',
          @Lc_NonDisclosureChecked_CODE CHAR(1) = 'X',
          @Lc_MemberStatusActive_CODE   CHAR(1) = 'A',
          @Ls_Routine_TEXT              VARCHAR(100) = 'BATCH_GEN_NOTICE_CNET.BATCH_GEN_NOTICE_CNET$SP_GET_NON_DISCLOSURE_OPTS ';
  DECLARE @Lc_NonDisclosure_Mom_INDC        CHAR(1) = '',
          @Lc_NonDisclosure_Father_INDC     CHAR(1) = '',
          @Lc_NonDisclosure_Care_Taker_INDC CHAR(1) = '',
          @Ls_Sql_TEXT                      VARCHAR(200),
          @Ls_Sqldata_TEXT                  VARCHAR(1000),
          @Ls_DescriptionError_TEXT         VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF (@An_Case_IDNO IS NOT NULL
       AND @An_Case_IDNO > 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 ';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + 'CaseMemberStatus_CODE = ' + CAST(@Lc_MemberStatusActive_CODE AS VARCHAR);

     SELECT @Lc_NonDisclosure_Mom_INDC = MAX(A.NonDisclosure_Mom_INDC),
            @Lc_NonDisclosure_Father_INDC = MAX(A.NonDisclosure_Father_INDC),
            @Lc_NonDisclosure_Care_Taker_INDC = MAX(A.NonDisclosure_Care_Taker_INDC)
       FROM (SELECT CASE
                     WHEN a.MemberMci_IDNO = @An_MotherMci_IDNO
                          AND a.FamilyViolence_INDC = @Lc_Yes_INDC
                      THEN @Lc_NonDisclosureChecked_CODE
                     ELSE @Lc_Space_TEXT
                    END NonDisclosure_Mom_INDC,
                    CASE
                     WHEN a.MemberMci_IDNO = @An_FatherMci_IDNO
                          AND a.FamilyViolence_INDC = @Lc_Yes_INDC
                      THEN @Lc_NonDisclosureChecked_CODE
                     ELSE @Lc_Space_TEXT
                    END NonDisclosure_Father_INDC,
                    CASE
                     WHEN a.MemberMci_IDNO = @An_CaretakerMci_IDNO
                          AND a.FamilyViolence_INDC = @Lc_Yes_INDC
                      THEN @Lc_NonDisclosureChecked_CODE
                     ELSE @Lc_Space_TEXT
                    END NonDisclosure_Care_Taker_INDC
               FROM CMEM_Y1 a
              WHERE Case_IDNO = @An_Case_IDNO
                AND a.MemberMci_IDNO IN (@An_MotherMci_IDNO, @An_FatherMci_IDNO, @An_CaretakerMci_IDNO)
                AND a.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE)A;
    END

   SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1 ';
   SET @Ls_Sqldata_TEXT = 'IND_NON_DISCLOSURE_MOM_CODE = ' + CAST(@Lc_NonDisclosure_Mom_INDC AS VARCHAR) + 'IND_NON_DISCLOSURE_FATHER_CODE = ' + CAST(@Lc_NonDisclosure_Father_INDC AS VARCHAR) + 'IND_NON_DISCLOSURE_CARETAKER_CODE = ' + CAST(@Lc_NonDisclosure_Care_Taker_INDC AS VARCHAR);

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT (VARCHAR (100), IND_NON_DISCLOSURE_MOM_CODE) IND_NON_DISCLOSURE_MOM_CODE,
                   CONVERT (VARCHAR (100), IND_NON_DISCLOSURE_FATHER_CODE) IND_NON_DISCLOSURE_FATHER_CODE,
                   CONVERT (VARCHAR (100), IND_NON_DISCLOSURE_CARETAKER_CODE) IND_NON_DISCLOSURE_CARETAKER_CODE
              FROM (SELECT @Lc_NonDisclosure_Mom_INDC AS IND_NON_DISCLOSURE_MOM_CODE,
                           @Lc_NonDisclosure_Father_INDC AS IND_NON_DISCLOSURE_FATHER_CODE,
                           @Lc_NonDisclosure_Care_Taker_INDC AS IND_NON_DISCLOSURE_CARETAKER_CODE) h) up UNPIVOT (tag_value FOR tag_name IN (IND_NON_DISCLOSURE_MOM_CODE, IND_NON_DISCLOSURE_FATHER_CODE, IND_NON_DISCLOSURE_CARETAKER_CODE)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
