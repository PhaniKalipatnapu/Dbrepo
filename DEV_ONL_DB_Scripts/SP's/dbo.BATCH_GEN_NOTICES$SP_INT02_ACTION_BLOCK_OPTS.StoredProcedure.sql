/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_INT02_ACTION_BLOCK_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_INT02_ACTION_BLOCK_OPTS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_INT02_ACTION_BLOCK_OPTS] (
 @Ac_Function_CODE         CHAR(3),
 @Ac_Action_CODE           CHAR(1),
 @Ac_Reason_CODE           CHAR(5),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS  
 BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
   DECLARE @Lc_Space_TEXT               CHAR = ' ',
           @Lc_StatusSuccess_CODE       CHAR = 'S',
           @Lc_StatusFailed_CODE        CHAR = 'F',
           @Lc_CheckBoxCheckValue_TEXT  CHAR(1) = 'X',
           @Lc_ActionR1_CODE            CHAR(1) = 'R',
           @Lc_ActionP1_CODE            CHAR(1) = 'P',
           @Lc_FunctionMsc_CODE         CHAR(3) = 'MSC',
           @Lc_FunctionEnf_CODE         CHAR(3) = 'ENF',
           @Lc_FunctionEst_CODE         CHAR(3) = 'EST',
           @Lc_FunctionPat_CODE         CHAR(3) = 'PAT',
           @Lc_ReasonGrupd_CODE         CHAR(5) = 'GRUPD',
           @Lc_ReasonGsarr_CODE         CHAR(5) = 'GSARR',
           @Lc_ReasonGspud_CODE         CHAR(5) = 'GSPUD',
           @Lc_ReasonGspay_CODE         CHAR(5) = 'GSPAY',
           @Lc_ReasonGiher_CODE         CHAR(5) = 'GIHER',
           @Lc_ReasonSichs_CODE         CHAR(5) = 'SICHS',
           @Lc_ReasonPichs_CODE         CHAR(5) = 'PICHS',
           @Lc_ReasonGspad_CODE         CHAR(5) = 'GSPAD',
           @Lc_ReasonGsfwd_CODE         CHAR(5) = 'GSFWD',
           @Lc_ReasonGsfip_CODE         CHAR(5) = 'GSFIP',
           @Lc_ReasonGsfil_CODE         CHAR(5) = 'GSFIL',
           @Lc_ReasonSsest_CODE         CHAR(5) = 'SSEST';
   DECLARE @Ln_Value_QNTY            NUMERIC(2) = 0,
           @Lc_CheckBox1_TEXT        CHAR(1) ='',
           @Lc_CheckBox2_TEXT        CHAR(1) ='',
           @Lc_CheckBox3_TEXT        CHAR(1) ='',
           @Lc_CheckBox4_TEXT        CHAR(1) ='',
           @Lc_CheckBox5_TEXT        CHAR(1) = '',
           @Lc_CheckBox6_TEXT        CHAR(1) ='',
           @Lc_CheckBox7_TEXT        CHAR(1) ='',
           @Lc_CheckBox8_TEXT        CHAR(1) = '',
           @Lc_CheckBox9_TEXT        CHAR(1) ='',
           @Lc_CheckBox10_TEXT       CHAR(1) = '',
           @Ls_Procedure_NAME        VARCHAR(60),
           @Ls_Sql_TEXT              VARCHAR(200),
           @Ls_FarDescription_TEXT   VARCHAR(1000) = '',
           @Ls_Sqldata_TEXT          VARCHAR(1000),
           @Ls_DescriptionError_TEXT VARCHAR(4000);

   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICES$SP_INT02_ACTION_BLOCK_OPTS';
   SET @Ls_Sql_TEXT = ' CHECK FAR ';
   SET @Ls_Sqldata_TEXT = 'Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', Space_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '') + ', Space_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '');

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionR1_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGrupd_CODE)
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF (@Ac_Function_CODE IN(@Lc_FunctionEnf_CODE ,@Lc_FunctionEst_CODE)
       AND @Ac_Action_CODE = @Lc_ActionR1_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGsarr_CODE)
    BEGIN
     SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionP1_CODE
       AND @Ac_Reason_CODE IN (@Lc_ReasonGspud_CODE,@Lc_ReasonGrupd_CODE))
    BEGIN
     SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionP1_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGspay_CODE)
    BEGIN
     SET @Lc_CheckBox4_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF (@Ac_Function_CODE IN (@Lc_FunctionMsc_CODE, @Lc_FunctionEnf_CODE)
       AND @Ac_Action_CODE = @Lc_ActionP1_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGiher_CODE)
       OR (@Ac_Function_CODE IN (@Lc_FunctionEst_CODE)
           AND @Ac_Action_CODE = @Lc_ActionP1_CODE
           AND @Ac_Reason_CODE = @Lc_ReasonSichs_CODE)
       OR (@Ac_Function_CODE IN (@Lc_FunctionPat_CODE)
           AND @Ac_Action_CODE = @Lc_ActionP1_CODE
           AND @Ac_Reason_CODE = @Lc_ReasonPichs_CODE)
    BEGIN
     SET @Lc_CheckBox5_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionP1_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGspad_CODE)
    BEGIN
     SET @Lc_CheckBox6_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE = @Lc_ActionP1_CODE
       AND @Ac_Reason_CODE IN (@Lc_ReasonGsfwd_CODE, @Lc_ReasonGsfip_CODE))
    BEGIN
     SET @Lc_CheckBox7_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF (@Ac_Function_CODE IN (@Lc_FunctionEst_CODE,@Lc_FunctionEnf_CODE,@Lc_FunctionPat_CODE)
       AND @Ac_Action_CODE = @Lc_ActionP1_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGsfil_CODE)
    BEGIN
     SET @Lc_CheckBox8_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEst_CODE
       AND @Ac_Action_CODE = @Lc_ActionP1_CODE
       AND @Ac_Reason_CODE IN (@Lc_ReasonSsest_CODE))
    BEGIN
     SET @Lc_CheckBox9_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Ln_Value_QNTY = 1;
    END

   IF @Ln_Value_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = ' SELECT CFAR_Y1 ';
     SET @Ls_Sqldata_TEXT = 'Function_CODE = ' + ISNULL(@Ac_Function_CODE, '') + ', Space_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '') + ', Space_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE, '');

     SELECT @Ls_FarDescription_TEXT = a.DescriptionFar_TEXT,
            @Lc_CheckBox10_TEXT = @Lc_CheckBoxCheckValue_TEXT
       FROM CFAR_Y1 a
      WHERE a.Function_CODE = @Ac_Function_CODE
        AND a.Action_CODE = @Ac_Action_CODE
        AND a.Reason_CODE = @Ac_Reason_CODE;
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT Element_NAME,
           Element_Value
      FROM (SELECT CONVERT(VARCHAR(1000), CHK_STATUS_REQ_OPT) CHK_STATUS_REQ_OPT_CODE,
                   CONVERT(VARCHAR(1000), CHK_AREARAGE_RECON_OPT) CHK_AREARAGE_RECON_OPT_CODE,
                   CONVERT(VARCHAR(1000), CHK_STATUS_UPDATE_OPT) CHK_STATUS_UPDATE_OPT_CODE,
                   CONVERT(VARCHAR(1000), CHK_PAYE_RESPOND_OPT) CHK_PAYE_RESPOND_OPT_CODE,
                   CONVERT(VARCHAR(1000), CHK_NOTICE_HEARING_OPT) CHK_NOTICE_HEARING_OPT_CODE,
                   CONVERT(VARCHAR(1000), CHK_REDIRECT_OPT) CHK_REDIRECT_OPT_CODE,
                   CONVERT(VARCHAR(1000), CHK_CASE_FORWARD_OPT) CHK_CASE_FORWARD_OPT_CODE,
                   CONVERT(VARCHAR(1000), CHK_DOCU_FILED_OPT) CHK_DOCU_FILED_OPT_CODE,
                   CONVERT(VARCHAR(1000), CHK_ORDER_ISSUED_OPT) CHK_ORDER_ISSUED_OPT_CODE,
                   CONVERT(VARCHAR(1000), OTH_ST_FAR_DESC_OPT) OTH_ST_FAR_DESC_OPT_CODE,
                   CONVERT(VARCHAR(1000), OTH_ST_FAR_DESC_TEXT) OTH_ST_FAR_DESC_TEXT
              FROM (SELECT @Lc_CheckBox1_TEXT AS CHK_STATUS_REQ_OPT,
                           @Lc_CheckBox2_TEXT AS CHK_AREARAGE_RECON_OPT,
                           @Lc_CheckBox3_TEXT AS CHK_STATUS_UPDATE_OPT,
                           @Lc_CheckBox4_TEXT AS CHK_PAYE_RESPOND_OPT,
                           @Lc_CheckBox5_TEXT AS CHK_NOTICE_HEARING_OPT,
                           @Lc_CheckBox6_TEXT AS CHK_REDIRECT_OPT,
                           @Lc_CheckBox7_TEXT AS CHK_CASE_FORWARD_OPT,
                           @Lc_CheckBox8_TEXT AS CHK_DOCU_FILED_OPT,
                           @Lc_CheckBox9_TEXT AS CHK_ORDER_ISSUED_OPT,
                           @Lc_CheckBox10_TEXT AS OTH_ST_FAR_DESC_OPT,
                           @Ls_FarDescription_TEXT AS OTH_ST_FAR_DESC_TEXT) h)up UNPIVOT (Element_Value FOR Element_NAME IN ( CHK_STATUS_REQ_OPT_CODE, CHK_AREARAGE_RECON_OPT_CODE, CHK_STATUS_UPDATE_OPT_CODE, CHK_PAYE_RESPOND_OPT_CODE, CHK_NOTICE_HEARING_OPT_CODE, CHK_REDIRECT_OPT_CODE, CHK_CASE_FORWARD_OPT_CODE, CHK_DOCU_FILED_OPT_CODE, CHK_ORDER_ISSUED_OPT_CODE, OTH_ST_FAR_DESC_OPT_CODE, OTH_ST_FAR_DESC_TEXT )) AS pvt);

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
