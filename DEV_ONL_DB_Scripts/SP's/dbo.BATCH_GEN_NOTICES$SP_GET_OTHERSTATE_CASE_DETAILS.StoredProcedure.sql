/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_OTHERSTATE_CASE_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name    : BATCH_GEN_NOTICES$SP_GET_OTHERSTATE_CASE_DETAILS
 Programmer Name   : IMP Team
 Description       : This Procedure is used to retrieve the other state case details.
 Frequency         :
 Developed On      : 01/20/2011
 Called By         : BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On         :
---------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        : 1.0 
---------------------------------------------------------
*/  
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_OTHERSTATE_CASE_DETAILS] (
 @An_Case_IDNO              NUMERIC(6),
 @An_OtherParty_IDNO        NUMERIC(10),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Run_DATE               DATE,
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusOpen_CODE    CHAR(1) = 'O',
          @Ls_Procedure_NAME     VARCHAR(100)= 'BATCH_GEN_NOTICES$SP_GET_OTHERSTATE_CASE_DETAILS',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ls_sql_TEXT       VARCHAR(200),
          @Ls_Sqldata_TEXT   VARCHAR(400);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_sql_TEXT = 'SELECT ICAS_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(10));

   IF (		@Ac_IVDOutOfStateFips_CODE IS NOT NULL
		AND @Ac_IVDOutOfStateFips_CODE != '0'
		AND @Ac_IVDOutOfStateFips_CODE != ''
	  )
    BEGIN
     INSERT INTO #NoticeElementsData_P1
                 (Element_Name,
                  Element_Value)
     (SELECT Element_Name,
             Element_Value
        FROM (SELECT CONVERT(VARCHAR(100), IVDOutOfStateCase_ID) OtherStateCase_IDNO,
                     CONVERT(VARCHAR(100), OtherState_Name) OtherState_Name
                FROM (SELECT DISTINCT
                             a.IVDOutOfStateCase_ID,
                             (SELECT State_NAME
                                FROM STAT_Y1 s
                               WHERE StateFips_CODE = a.IVDOutOfStateFips_CODE) AS OtherState_Name
                        FROM ICAS_Y1 a
                       WHERE a.Case_IDNO = @An_Case_IDNO
                         AND a.EndValidity_DATE = @Ld_High_DATE
                         AND a.Status_CODE = @Lc_StatusOpen_CODE
                         AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
                         AND @Ad_Run_DATE BETWEEN a.Effective_DATE AND a.End_DATE)h)up UNPIVOT (Element_Value FOR Element_Name IN ( OtherStateCase_IDNO, OtherState_Name )) AS pvt);
    END
   ELSE IF ( (		@Ac_IVDOutOfStateFips_CODE IS NULL
				OR  @Ac_IVDOutOfStateFips_CODE = '0'
				OR  @Ac_IVDOutOfStateFips_CODE = ''
			 )
			 AND @An_OtherParty_IDNO = 0
		   )
    BEGIN
	 INSERT INTO #NoticeElementsData_P1
                 (Element_Name,
                  Element_Value)
     (SELECT Element_Name,
             Element_Value
        FROM (SELECT CONVERT(VARCHAR(100), IVDOutOfStateCase_ID) OtherStateCase_IDNO,
                     CONVERT(VARCHAR(100), OtherState_Name) OtherState_Name
                FROM (SELECT DISTINCT TOP 1
                             a.IVDOutOfStateCase_ID,
                             (SELECT State_NAME
                                FROM STAT_Y1 s
                               WHERE StateFips_CODE = a.IVDOutOfStateFips_CODE) AS OtherState_Name
                        FROM ICAS_Y1 a
                       WHERE a.Case_IDNO = @An_Case_IDNO
                         AND a.EndValidity_DATE = @Ld_High_DATE
                         AND a.Status_CODE = @Lc_StatusOpen_CODE
                         AND @Ad_Run_DATE BETWEEN a.Effective_DATE AND a.End_DATE)h)up UNPIVOT (Element_Value FOR Element_Name IN ( OtherStateCase_IDNO, OtherState_Name )) AS pvt);
    END
   ELSE
    BEGIN
    SET @Ls_sql_TEXT = 'SELECT ICAS_Y1';
    SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(10));
     INSERT INTO #NoticeElementsData_P1
                 (Element_Name,
                  Element_Value)
     (SELECT Element_Name,
             Element_Value
        FROM (SELECT CONVERT(VARCHAR(100), IVDOutOfStateCase_ID) OtherStateCase_IDNO,
                     CONVERT(VARCHAR(100), OtherState_Name) OtherState_Name
                FROM (SELECT TOP 1
                             a.IVDOutOfStateCase_ID,
                             (SELECT State_NAME
                                FROM STAT_Y1 s
                               WHERE StateFips_CODE = a.IVDOutOfStateFips_CODE) AS OtherState_Name
                        FROM ICAS_Y1 a
                       WHERE a.Case_IDNO = @An_Case_IDNO
                         AND a.EndValidity_DATE = @Ld_High_DATE
                         AND a.Status_CODE = @Lc_StatusOpen_CODE
                         AND (@An_OtherParty_IDNO = a.PetitionerMci_IDNO
                               OR @An_OtherParty_IDNO = a.RespondentMci_IDNO)
                         AND @Ad_Run_DATE BETWEEN a.Effective_DATE AND a.End_DATE ORDER BY a.Referral_DATE DESC)h)up UNPIVOT (Element_Value FOR Element_Name IN ( OtherStateCase_IDNO, OtherState_Name )) AS pvt);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB            INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB        INT = ERROR_LINE ();
   DECLARE @Ls_DescriptionError_TEXT VARCHAR (4000);

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
