/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_NON_DISCLOSURE_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_GET_NON_DISCLOSURE_OPTS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_GET_NON_DISCLOSURE_OPTS] (
 @An_TransHeader_IDNO       NUMERIC(12),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ad_Run_DATE               DATE,
 @An_Case_IDNO              NUMERIC (6),
 @An_NcpMemberMci_IDNO      NUMERIC(10),
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
  BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                CHAR(1) = ' ',
          @Lc_CaseStatusOpen_CODE       CHAR(1) = 'O',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_Yes_INDC                  CHAR(1) = 'Y',
          @Lc_NonDisclosureChecked_CODE CHAR(1) = 'X',
          @Lc_MemberStatusActive_CODE   CHAR(1) = 'A', 
          @Lc_CaseRelationship_NCP      CHAR(1) ='A',
          @Lc_CaseRelationship_CP       CHAR(1) ='C',
          @Ls_Routine_TEXT              VARCHAR(100) = 'BATCH_GEN_NOTICE_CNET.BATCH_GEN_NOTICE_CNET$SP_GET_NON_DISCLOSURE_OPTS ',
          @Ld_High_DATE                 DATE = '12/31/9999';
  DECLARE @Lc_NonDisclosure_INDC    CHAR(1) = '',
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF (@An_Case_IDNO IS NOT NULL
       AND @An_Case_IDNO > 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 ';
     SET @Ls_Sqldata_TEXT = 'StateFips_CODE = ' + ISNULL (@Ac_IVDOutOfStateFips_CODE, '') + ', Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR);

      SELECT @Lc_NonDisclosure_INDC = @Lc_NonDisclosureChecked_CODE
		FROM CMEM_Y1 a
		WHERE a.Case_IDNO = @An_Case_IDNO
		AND a.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE
		AND a.CaseRelationship_CODE IN(@Lc_CaseRelationship_NCP,@Lc_CaseRelationship_CP)
		AND a.FamilyViolence_INDC = @Lc_Yes_INDC				
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CSDB_Y1 ';
     SET @Ls_Sqldata_TEXT = '  StateFips_CODE = ' + ISNULL (@Ac_IVDOutOfStateFips_CODE, '');

     SELECT @Lc_NonDisclosure_INDC = CASE
                                      WHEN a.NondisclosureFinding_INDC = @Lc_Yes_INDC
                                       THEN @Lc_NonDisclosureChecked_CODE
                                      ELSE @Lc_Space_TEXT
                                     END
       FROM CSDB_Y1 a
      WHERE a.TransHeader_IDNO = @An_TransHeader_IDNO
        AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
        AND a.Transaction_DATE = @Ad_Transaction_DATE;
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT (VARCHAR (100), IND_NON_DISCLOSURE_CODE) IND_NON_DISCLOSURE_CODE
              FROM (SELECT @Lc_NonDisclosure_INDC AS IND_NON_DISCLOSURE_CODE) h) up UNPIVOT (tag_value FOR tag_name IN (IND_NON_DISCLOSURE_CODE)) AS pvt);

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
