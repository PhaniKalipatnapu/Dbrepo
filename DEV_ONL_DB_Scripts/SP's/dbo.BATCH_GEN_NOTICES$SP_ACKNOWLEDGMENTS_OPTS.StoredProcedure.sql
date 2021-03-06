/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_ACKNOWLEDGMENTS_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_ACKNOWLEDGMENTS_OPTS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_ACKNOWLEDGMENTS_OPTS] (
 @Ac_Function_CODE         CHAR(3),
 @Ac_Action_CODE           CHAR(1),
 @Ac_Reason_CODE           CHAR(5),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                 CHAR = ' ',
          @Lc_StatusSuccess_CODE         CHAR = 'S',
          @Lc_StatusFailed_CODE          CHAR = 'F',
          @Lc_CheckBoxCheckValue_TEXT    CHAR(1) = 'X',
          @Lc_ActionA1_CODE              CHAR(1) = 'A',
          @Lc_ActionR1_CODE              CHAR(1) = 'R',
          @Lc_FunctionEnforcement_CODE   CHAR(3) = 'ENF',
          @Lc_FunctionEstablishment_CODE CHAR(3) = 'EST',
          @Lc_FunctionPaternity_CODE     CHAR(3) = 'PAT',
          @Lc_ReasonAnoad_CODE           CHAR(5) = 'ANOAD',
          @Lc_ReasonAadin_CODE           CHAR(5) = 'AADIN',
          @Lc_ReasonErarr_CODE           CHAR(5) = 'ERARR',
          @Lc_ReasonErall_CODE           CHAR(5) = 'ERALL',
          @Lc_ReasonErfso_CODE           CHAR(5) = 'ERFSO',
          @Lc_ReasonErmeo_CODE           CHAR(5) = 'ERMEO',
          @Lc_ReasonErreg_CODE           CHAR(5) = 'ERREG',
          @Lc_ReasonErres_CODE           CHAR(5) = 'ERRES',
          @Lc_ReasonErreo_CODE           CHAR(5) = 'ERREO',
          @Lc_ReasonErwag_CODE           CHAR(5) = 'ERWAG',
          @Lc_ReasonErexo_CODE           CHAR(5) = 'EREXO',
          @Lc_ReasonErfsm_CODE           CHAR(5) = 'ERFSM',
          @Lc_ReasonErfss_CODE           CHAR(5) = 'ERFSS',
          @Lc_ReasonErmee_CODE           CHAR(5) = 'ERMEE',
          @Lc_ReasonErmem_CODE           CHAR(5) = 'ERMEM',
          @Lc_ReasonSradj_CODE           CHAR(5) = 'SRADJ',
          @Lc_ReasonSrmod_CODE           CHAR(5) = 'SRMOD',
          @Lc_ReasonSromc_CODE           CHAR(5) = 'SROMC',
          @Lc_ReasonSrooc_CODE           CHAR(5) = 'SROOC',
          @Lc_ReasonSropp_CODE           CHAR(5) = 'SROPP',
          @Lc_ReasonSrord_CODE           CHAR(5) = 'SRORD',
          @Lc_ReasonSross_CODE           CHAR(5) = 'SROSS',
          @Ls_Procedure_NAME             VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_ACKNOWLEDGMENTS_OPTS';
  DECLARE @Lc_CheckBox1_TEXT        CHAR(1) = '',
          @Lc_CheckBox2_TEXT        CHAR(1) = '',
          @Lc_CheckBox3_TEXT        CHAR(1) = '',
          @Lc_CheckBox4_TEXT        CHAR(1) = '',
          @Lc_CheckBox5_TEXT        CHAR(1) = '',
          @Lc_CheckBox6_TEXT        CHAR(1) = '',
          @Lc_CheckBox7_TEXT        CHAR(1) = '',
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   
   IF (@Ac_Function_CODE IN (@Lc_FunctionEnforcement_CODE, @Lc_FunctionEstablishment_CODE, @Lc_FunctionPaternity_CODE)
       AND @Ac_Action_CODE = @Lc_ActionA1_CODE 
       AND @Ac_Reason_CODE = @Lc_ReasonAnoad_CODE)
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END

   IF (@Ac_Function_CODE IN (@Lc_FunctionEnforcement_CODE, @Lc_FunctionEstablishment_CODE, @Lc_FunctionPaternity_CODE)
       AND @Ac_Action_CODE = @Lc_ActionA1_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonAadin_CODE)
    BEGIN
     SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
       AND @Ac_Action_CODE = @Lc_ActionR1_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonErarr_CODE)
    BEGIN
     SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
       AND @Ac_Action_CODE = @Lc_ActionR1_CODE
       AND @Ac_Reason_CODE IN (@Lc_ReasonErarr_CODE, @Lc_ReasonErall_CODE, @Lc_ReasonErfso_CODE, @Lc_ReasonErmeo_CODE,
                               @Lc_ReasonErreg_CODE, @Lc_ReasonErres_CODE, @Lc_ReasonErreo_CODE, @Lc_ReasonErwag_CODE,
                               @Lc_ReasonErexo_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE, @Lc_ReasonErmee_CODE, @Lc_ReasonErmem_CODE))
       OR (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
           AND @Ac_Action_CODE = @Lc_ActionR1_CODE
           AND @Ac_Reason_CODE IN (@Lc_ReasonSradj_CODE, @Lc_ReasonSrmod_CODE))
    BEGIN
     SET @Lc_CheckBox4_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
       AND @Ac_Action_CODE = @Lc_ActionR1_CODE
       AND @Ac_Reason_CODE IN (@Lc_ReasonSromc_CODE, @Lc_ReasonSrooc_CODE, @Lc_ReasonSropp_CODE, @Lc_ReasonSrord_CODE, @Lc_ReasonSross_CODE))
       OR (@Ac_Function_CODE = @Lc_FunctionPaternity_CODE
           AND @Ac_Action_CODE = @Lc_ActionR1_CODE
           AND @Ac_Reason_CODE = @Lc_Space_TEXT)
       OR (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
           AND @Ac_Action_CODE = @Lc_ActionR1_CODE
           AND @Ac_Reason_CODE IN (@Lc_ReasonSradj_CODE, @Lc_ReasonSrmod_CODE))
    BEGIN
     SET @Lc_CheckBox5_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
       AND @Ac_Action_CODE = @Lc_ActionR1_CODE
       AND @Ac_Reason_CODE IN (@Lc_ReasonSromc_CODE, @Lc_ReasonSrooc_CODE, @Lc_ReasonSropp_CODE, @Lc_ReasonSrord_CODE, @Lc_ReasonSross_CODE))
       OR (@Ac_Function_CODE = @Lc_FunctionPaternity_CODE
           AND @Ac_Action_CODE = @Lc_ActionR1_CODE
           AND @Ac_Reason_CODE = @Lc_Space_TEXT)
       OR (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
           AND @Ac_Action_CODE = @Lc_ActionR1_CODE
           AND @Ac_Reason_CODE IN (@Lc_ReasonSradj_CODE, @Lc_ReasonSrmod_CODE))
    BEGIN
     SET @Lc_CheckBox6_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionPaternity_CODE
       AND @Ac_Action_CODE = @Lc_ActionR1_CODE
       AND @Ac_Reason_CODE = @Lc_Space_TEXT)
    BEGIN
     SET @Lc_CheckBox7_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT Element_NAME,
           Element_Value
      FROM (SELECT CONVERT(VARCHAR(100), CHK_RECD_NO_INF_NEEDED_OPT) CHK_RECD_NO_INF_NEEDED_OPT_CODE,
                   CONVERT(VARCHAR(100), CHK_RECD_INF_NEEDED_OPT) CHK_RECD_INF_NEEDED_OPT_CODE,
                   CONVERT(VARCHAR(100), CHK_ARR_DOC_OPT) CHK_ARR_DOC_OPT_CODE,
                   CONVERT(VARCHAR(100), CHK_SUPP_ORD_OPT) CHK_SUPP_ORD_OPT_CODE,
                   CONVERT(VARCHAR(100), CHK_UNI_SUPP_PET_OPT) CHK_UNI_SUPP_PET_OPT_CODE,
                   CONVERT(VARCHAR(100), CHK_GEN_TEST_OPT) CHK_GEN_TEST_OPT_CODE,
                   CONVERT(VARCHAR(100), CHK_AFD_SUP_EST_PAT_OPT) CHK_AFD_SUP_EST_PAT_OPT_CODE
              FROM (SELECT @Lc_CheckBox1_TEXT AS CHK_RECD_NO_INF_NEEDED_OPT,
                           @Lc_CheckBox2_TEXT AS CHK_RECD_INF_NEEDED_OPT,
                           @Lc_CheckBox3_TEXT AS CHK_ARR_DOC_OPT,
                           @Lc_CheckBox4_TEXT AS CHK_SUPP_ORD_OPT,
                           @Lc_CheckBox5_TEXT AS CHK_UNI_SUPP_PET_OPT,
                           @Lc_CheckBox6_TEXT AS CHK_GEN_TEST_OPT,
                           @Lc_CheckBox7_TEXT AS CHK_AFD_SUP_EST_PAT_OPT) h)up UNPIVOT (Element_Value FOR Element_NAME IN ( CHK_RECD_NO_INF_NEEDED_OPT_CODE, CHK_RECD_INF_NEEDED_OPT_CODE, CHK_ARR_DOC_OPT_CODE, CHK_SUPP_ORD_OPT_CODE, CHK_UNI_SUPP_PET_OPT_CODE, CHK_GEN_TEST_OPT_CODE, CHK_AFD_SUP_EST_PAT_OPT_CODE )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT,
           @Li_ErrorLine_NUMB INT;

   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

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
