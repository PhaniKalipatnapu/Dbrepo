/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_OBLIGOR_BODY_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_OBLIGOR_BODY_DETAILS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_OBLIGOR_BODY_DETAILS] (
 @An_NcpMemberMci_IDNO     NUMERIC (10),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_TableGenr_IDNO     CHAR(4) = 'GENR',
          @Lc_TableSubGen2_IDNO  CHAR(4) = 'GEN2',
          @Lc_TableSubRace_IDNO  CHAR(4) = 'RACE',
          @Lc_TableDemo_IDNO     CHAR(4) = 'DEMO',
          @Lc_TableSubHair_IDNO  CHAR(4) = 'HAIR',
          @Lc_TableSubEyec_IDNO  CHAR(4) = 'EYEC',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_BODY_DETAILS';
  DECLARE 
          @Lc_MemberHeight_TEXT       CHAR(10),
          @Lc_MemberWeight_TEXT       CHAR(10),
          @Lc_IdentfnMarks_TEXT       CHAR(40),
          @Ls_MemberSex_TEXT          VARCHAR(70),
          @Ls_MemberRace_TEXT         VARCHAR(70),
          @Ls_MemberHairColor_TEXT    VARCHAR(70),
          @Ls_MemberEyeColor_TEXT     VARCHAR(70),
          @Ls_Sql_TEXT                VARCHAR(100),
          @Ls_DescriptionProfile_TEXT VARCHAR(200),
          @Ls_Sqldata_TEXT            VARCHAR(1000),
          @Ls_DescriptionError_TEXT   VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF (@An_NcpMemberMci_IDNO IS NOT NULL
       AND @An_NcpMemberMci_IDNO > 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1 AND DEMO_Y1 ';
     SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST (@An_NcpMemberMci_IDNO AS VARCHAR (10)), '');

     SELECT @Ls_MemberSex_TEXT= dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableGenr_IDNO, @Lc_TableSubGen2_IDNO, D.MemberSex_CODE),
            @Ls_MemberRace_TEXT= dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableGenr_IDNO, @Lc_TableSubRace_IDNO, D.Race_CODE),
            @Lc_MemberHeight_TEXT = D.DescriptionHeight_TEXT,
            @Lc_MemberWeight_TEXT = D.DescriptionWeightLbs_TEXT,
            @Ls_MemberHairColor_TEXT = dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableDemo_IDNO, @Lc_TableSubHair_IDNO, D.ColorHair_CODE),
            @Ls_MemberEyeColor_TEXT = dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableDemo_IDNO, @Lc_TableSubEyec_IDNO, D.ColorEyes_CODE),
            @Ls_DescriptionProfile_TEXT = ISNULL(PA.DescriptionProfile_TEXT, ''),
            @Lc_IdentfnMarks_TEXT = D.DescriptionIdentifyingMarks_TEXT
       FROM DEMO_Y1 D
            LEFT OUTER JOIN MPAT_Y1 PA
             ON PA.MemberMci_IDNO = D.MemberMci_IDNO
      WHERE D.MemberMci_IDNO = @An_NcpMemberMci_IDNO;

     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     (SELECT pvt.Element_NAME,
             pvt.Element_Value
        FROM (SELECT CONVERT (VARCHAR (100), OBLIGOR_SEX) OBLIGOR_SEX_CODE,
                     CONVERT (VARCHAR (100), OBLIGOR_RACE) OBLIGOR_RACE_CODE,
                     CONVERT (VARCHAR (100), OBLIGOR_HEIGHT) OBLIGOR_HEIGHT_TEXT,
                     CONVERT (VARCHAR (100), OBLIGOR_WEIGHT) OBLIGOR_WEIGHT_TEXT,
                     CONVERT (VARCHAR (100), OBLIGOR_EYE_COLOR) OBLIGOR_EYE_COLOR_CODE,
                     CONVERT (VARCHAR (100), OBLIGOR_DESCRIPTION_PROFILE_TEXT) OBLIGOR_DESCRIPTION_PROFILE_TEXT,
                     CONVERT (VARCHAR (100), OBLIGOR_ID_MARKS) OBLIGOR_ID_MARKS_TEXT,
                     CONVERT (VARCHAR (100), OBLIGOR_HAIR_COLOR) OBLIGOR_HAIR_COLOR_CODE
                FROM (SELECT @Ls_MemberSex_TEXT AS OBLIGOR_SEX,
                             @Ls_MemberRace_TEXT AS OBLIGOR_RACE,
                             @Lc_MemberHeight_TEXT AS OBLIGOR_HEIGHT,
                             @Lc_MemberWeight_TEXT AS OBLIGOR_WEIGHT,
                             @Ls_MemberEyeColor_TEXT AS OBLIGOR_EYE_COLOR,
                             @Ls_DescriptionProfile_TEXT AS OBLIGOR_DESCRIPTION_PROFILE_TEXT,
                             @Ls_MemberHairColor_TEXT AS OBLIGOR_HAIR_COLOR,
                             @Lc_IdentfnMarks_TEXT AS OBLIGOR_ID_MARKS) h) up UNPIVOT (Element_Value FOR Element_NAME IN (OBLIGOR_SEX_CODE, OBLIGOR_RACE_CODE, OBLIGOR_HEIGHT_TEXT, OBLIGOR_WEIGHT_TEXT, OBLIGOR_EYE_COLOR_CODE, OBLIGOR_DESCRIPTION_PROFILE_TEXT, OBLIGOR_ID_MARKS_TEXT, OBLIGOR_HAIR_COLOR_CODE)) AS pvt);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

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
  END CATCH
 END


GO
