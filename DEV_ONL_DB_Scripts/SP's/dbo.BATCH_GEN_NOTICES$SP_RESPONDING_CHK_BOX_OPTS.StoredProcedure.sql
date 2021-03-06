/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_RESPONDING_CHK_BOX_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_RESPONDING_CHK_BOX_OPTS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_RESPONDING_CHK_BOX_OPTS] (
 @Ac_Notice_ID             CHAR(8),
 @Ac_Function_CODE         CHAR(3),
 @Ac_Action_CODE           CHAR(1),
 @Ac_Reason_CODE           CHAR(5),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_Empty_TEXT				 CHAR(1) = '',
		  @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_CheckBoxChecked_CODE       CHAR(1) = 'X',
          @Lc_ActionRequest_CODE         CHAR(1) = 'R',
          @Lc_ActionU1_CODE              CHAR(1) = 'U',
          @Lc_ActionProvide_CODE         CHAR(1) = 'P',
          @Lc_FunctionPaternity_CODE     CHAR(3) = 'PAT',
          @Lc_FunctionEstablishment_CODE CHAR(3) = 'EST',
          @Lc_FunctionEnforcement_CODE   CHAR(3) = 'ENF',
          @Lc_FunctionMsc_CODE           CHAR(3) = 'MSC',
          @Lc_ReasonSrpat_CODE           CHAR(5) = 'SRPAT',
          @Lc_ReasonSrord_CODE           CHAR(5) = 'SRORD',
          @Lc_ReasonErfso_CODE           CHAR(5) = 'ERFSO',
          @Lc_ReasonErmeo_CODE           CHAR(5) = 'ERMEO',
          @Lc_ReasonErreg_CODE           CHAR(5) = 'ERREG',
          @Lc_ReasonErreo_CODE           CHAR(5) = 'ERREO',
          @Lc_ReasonErres_CODE           CHAR(5) = 'ERRES',
          @Lc_ReasonErfsm_CODE           CHAR(5) = 'ERFSM',
          @Lc_ReasonErfss_CODE           CHAR(5) = 'ERFSS',
          @Lc_ReasonErmee_CODE           CHAR(5) = 'ERMEE',
          @Lc_ReasonErmem_CODE           CHAR(5) = 'ERMEM',
          @Lc_ReasonSromc_CODE           CHAR(5) = 'SROMC',
          @Lc_ReasonSrooc_CODE           CHAR(5) = 'SROOC',
          @Lc_ReasonSropp_CODE           CHAR(5) = 'SROPP',
          @Lc_ReasonSross_CODE           CHAR(5) = 'SROSS',
          @Lc_ReasonErall_CODE           CHAR(5) = 'ERALL',
          @Lc_ReasonErexo_CODE           CHAR(5) = 'EREXO',
          @Lc_ReasonErarr_CODE           CHAR(5) = 'ERARR',
          @Lc_ReasonSrmod_CODE           CHAR(5) = 'SRMOD',
          @Lc_ReasonSradj_CODE           CHAR(5) = 'SRADJ',
          @Lc_ReasonErwag_CODE           CHAR(5) = 'ERWAG',
          @Lc_ReasonGspad_CODE           CHAR(5) = 'GSPAD',
          @Lc_ReasonErtxr_CODE           CHAR(5) = 'ERTXR',
          @Lc_ReasonGrpay_CODE           CHAR(5) = 'GRPAY',
          @Lc_NoticeInt01_ID             CHAR(8) = 'INT-01',
          @Ls_Procedure_NAME             VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_RESPONDING_CHK_BOX_OPTS';
  DECLARE @Lc_CheckBox1_TEXT			 CHAR(1) = '',
          @Lc_CheckBox2_TEXT			 CHAR(1) = '',
          @Lc_CheckBox3_TEXT			 CHAR(1) = '',
          @Lc_CheckBox4_TEXT			 CHAR(1) = '',
          @Lc_CheckBox5_TEXT			 CHAR(1) = '',
          @Lc_CheckBox6_TEXT			 CHAR(1) = '',
          @Lc_CheckBox7_TEXT			 CHAR(1) = '',
          @Lc_CheckBox8_TEXT			 CHAR(1) = '',
          @Lc_CheckBox9_TEXT			 CHAR(1) = '',
          @Lc_CheckBox11_TEXT			 CHAR(1) = '',
          @Lc_CheckBox12_TEXT			 CHAR(1) = '',
          @Lc_CheckBox13_TEXT			 CHAR(1) = '',
          @Lc_CheckBox14_TEXT			 CHAR(1) = '',
          @Lc_CheckBox15_TEXT			 CHAR(1) = '',
          @Lc_CheckBox16_TEXT			 CHAR(1) = '',
          @Lc_CheckBox17_TEXT			 CHAR(1) = '',
          @Lc_CheckBox18_TEXT			 CHAR(1) = '',
          @Lc_CheckBox19_TEXT			 CHAR(1) = '',
          @Lc_CheckBox20_TEXT			 CHAR(1) = '',
          @Lc_CheckBox21_TEXT			 CHAR(1) = '',
          @Lc_CheckBox22_TEXT			 CHAR(1) = '',
          @Lc_CheckBox23_TEXT			 CHAR(1) = '',
          @Ls_Sql_TEXT					 VARCHAR(100),
          @Ls_Sqldata_TEXT				 VARCHAR(1000),
          @Ls_DescriptionError_TEXT		 VARCHAR(4000);

   BEGIN TRY
     SET @Ac_Reason_CODE = ISNULL(@Ac_Reason_CODE, @Lc_Empty_TEXT);

   IF (@Ac_Notice_ID = @Lc_NoticeInt01_ID)
    BEGIN
    -- 13737 - CR0439 INT-01 UIFSA Transmittal 1 Changes Requested by Workers 20141120 - START
     IF (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
              AND @Ac_Action_CODE = @Lc_ActionRequest_CODE
              AND @Ac_Reason_CODE = @Lc_ReasonSrpat_CODE)
      BEGIN
       SET @Lc_CheckBox1_TEXT = @Lc_CheckBoxChecked_CODE;
       SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxChecked_CODE;
       SET @Lc_CheckBox5_TEXT = @Lc_CheckBoxChecked_CODE;
	  
       INSERT INTO #NoticeElementsData_P1
                   (Element_NAME,
                    Element_Value)
       (SELECT Element_NAME,
               Element_Value
          FROM (SELECT CONVERT(VARCHAR(100), CHK_PAT_OPT) CHK_PAT_OPT_CODE,
                       CONVERT(VARCHAR(100), CHK_EST_OPT) CHK_EST_OPT_CODE,
                       CONVERT(VARCHAR(100), CHK_CS_MS_OPT) CHK_CS_MS_OPT_CODE
                  FROM (SELECT @Lc_CheckBox1_TEXT AS CHK_PAT_OPT,
                               @Lc_CheckBox3_TEXT AS CHK_EST_OPT,
                               @Lc_CheckBox5_TEXT AS CHK_CS_MS_OPT ) f)up 
                               UNPIVOT (Element_Value FOR Element_NAME IN ( CHK_PAT_OPT_CODE, CHK_EST_OPT_CODE, CHK_CS_MS_OPT_CODE )) AS pvt);
       RETURN;
      END

     IF (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
         AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
         AND @Ac_Reason_CODE = @Lc_ReasonSrord_CODE)
      BEGIN
       SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxChecked_CODE;
       SET @Lc_CheckBox5_TEXT = @Lc_CheckBoxChecked_CODE;

       INSERT INTO #NoticeElementsData_P1
                   (Element_NAME,
                    Element_Value)
       (SELECT Element_NAME,
               Element_Value
          FROM (SELECT CONVERT(VARCHAR(100), CHK_EST_OPT)CHK_EST_OPT_CODE, 
                       CONVERT(VARCHAR(100), CHK_CS_MS_OPT)CHK_CS_MS_OPT_CODE
                  FROM (SELECT @Lc_CheckBox3_TEXT AS CHK_EST_OPT,
                               @Lc_CheckBox5_TEXT AS CHK_CS_MS_OPT) f)up 
                               UNPIVOT (Element_Value FOR Element_NAME IN ( CHK_EST_OPT_CODE , CHK_CS_MS_OPT_CODE )) AS pvt);

       RETURN;
      END
    END
    -- 13737 - CR0439 INT-01 UIFSA Transmittal 1 Changes Requested by Workers 20141120 - END

   IF (@Ac_Function_CODE = @Lc_FunctionPaternity_CODE
       AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
       AND @Ac_Reason_CODE = @Lc_Empty_TEXT)
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
       AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
       AND @Ac_Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErmeo_CODE, @Lc_ReasonErreg_CODE, @Lc_ReasonErreo_CODE,
                               @Lc_ReasonErres_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE, @Lc_ReasonErmee_CODE, @Lc_ReasonErmem_CODE))
    BEGIN
     SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
      AND @Ac_Reason_CODE IN (@Lc_ReasonErreg_CODE, @Lc_ReasonErreo_CODE, @Lc_ReasonErres_CODE)
    BEGIN
     SET @Lc_CheckBox4_TEXT = @Lc_CheckBoxChecked_CODE;
    END
   
   IF (@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
       AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
       AND @Ac_Reason_CODE IN (@Lc_ReasonErmeo_CODE, @Lc_ReasonErmee_CODE, @Lc_ReasonErmem_CODE))
    BEGIN
     SET @Lc_CheckBox6_TEXT = @Lc_CheckBoxChecked_CODE;
    END
   IF @Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
       AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
       AND @Ac_Reason_CODE IN (@Lc_ReasonSropp_CODE)
    BEGIN
     SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxChecked_CODE;
     SET @Lc_CheckBox7_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
       AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
       AND @Ac_Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErfsm_CODE, @Lc_ReasonErfss_CODE))
    BEGIN
     SET @Lc_CheckBox8_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
       AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
       AND @Ac_Reason_CODE = @Lc_ReasonSromc_CODE)
    BEGIN
     SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxChecked_CODE;
     SET @Lc_CheckBox9_TEXT = @Lc_CheckBoxChecked_CODE;
    END

  
   IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
      AND @Ac_Reason_CODE IN (@Lc_ReasonErreg_CODE, @Lc_ReasonErmeo_CODE, @Lc_ReasonErfsm_CODE)
    BEGIN
     SET @Lc_CheckBox13_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
      AND @Ac_Reason_CODE IN (@Lc_ReasonErfso_CODE, @Lc_ReasonErreo_CODE, @Lc_ReasonErmem_CODE)
    BEGIN
     SET @Lc_CheckBox14_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
      AND @Ac_Reason_CODE IN (@Lc_ReasonErres_CODE, @Lc_ReasonErmee_CODE, @Lc_ReasonErfss_CODE)
    BEGIN
     SET @Lc_CheckBox15_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
      AND @Ac_Reason_CODE IN (@Lc_ReasonErall_CODE, @Lc_ReasonErexo_CODE)
    BEGIN  
    SET @Lc_CheckBox16_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
      AND @Ac_Reason_CODE IN (@Lc_ReasonErarr_CODE, @Lc_ReasonErexo_CODE)
     BEGIN 
     SET @Lc_CheckBox17_TEXT = @Lc_CheckBoxChecked_CODE;
     END
   IF @Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
      AND @Ac_Reason_CODE IN (@Lc_ReasonSrmod_CODE)
    BEGIN  
    SET @Lc_CheckBox18_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
       AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
       AND @Ac_Reason_CODE = @Lc_ReasonErwag_CODE)
       OR (@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
           AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
           AND @Ac_Reason_CODE = @Lc_ReasonErall_CODE)
    BEGIN       
    SET @Lc_CheckBox19_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF @Ac_Function_CODE = @Lc_FunctionMsc_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionProvide_CODE)
      AND @Ac_Reason_CODE = @Lc_ReasonGspad_CODE
    SET @Lc_CheckBox20_TEXT = @Lc_CheckBoxChecked_CODE;

   IF @Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
      AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionU1_CODE)
      AND @Ac_Reason_CODE = @Lc_ReasonErtxr_CODE
    BEGIN  
    SET @Lc_CheckBox21_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   IF (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
       AND @Ac_Action_CODE IN (@Lc_ActionProvide_CODE)
       AND @Ac_Reason_CODE = @Lc_ReasonGspad_CODE)
       OR (@Ac_Function_CODE = @Lc_FunctionMsc_CODE
           AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE)
           AND @Ac_Reason_CODE = @Lc_ReasonGrpay_CODE)
    BEGIN       
    SET @Lc_CheckBox22_TEXT = @Lc_CheckBoxChecked_CODE;
    END

   
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT Element_NAME,
           Element_Value
      FROM (SELECT CONVERT(VARCHAR(1), CHK_PAT_OPT) CHK_PAT_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_FSO_OPT) CHK_FSO_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_EST_OPT) CHK_EST_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_ENF_OPT) CHK_ENF_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_CS_MS_OPT) CHK_CS_MS_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_MOD_ENF_OPT) CHK_MOD_ENF_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_RET_CS_OPT) CHK_RET_CS_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_MOD_OPT) CHK_MOD_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_MS_OPT) CHK_MS_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_OBLIGOR_OPT) CHK_OBLIGOR_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_OBLIGEE_OPT) CHK_OBLIGEE_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_STATE_OPT) CHK_STATE_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_ENF_RESP_OPT) CHK_ENF_RESP_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_COL_ARR_OPT) CHK_COL_ARR_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_MOD_RESP_OPT) CHK_MOD_RESP_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_IW_OPT) CHK_IW_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_CHG_PAYEE_OPT) CHK_CHG_PAYEE_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_ADMN_RW_TAX_OFFSET_OPT) CHK_ADMN_RW_TAX_OFFSET_OPT_CODE,
                   CONVERT(VARCHAR(1), CHK_RDIR_PYMT_OBLIGEE_ST_OPT) CHK_RDIR_PYMT_OBLIGEE_ST_OPT_CODE
               FROM (SELECT @Lc_CheckBox1_TEXT AS CHK_PAT_OPT,
                           @Lc_CheckBox2_TEXT AS CHK_FSO_OPT,
                           @Lc_CheckBox3_TEXT AS CHK_EST_OPT,
                           @Lc_CheckBox4_TEXT AS CHK_ENF_OPT,
                           @Lc_CheckBox5_TEXT AS CHK_CS_MS_OPT,
                           @Lc_CheckBox6_TEXT AS CHK_MOD_ENF_OPT,
                           @Lc_CheckBox7_TEXT AS CHK_RET_CS_OPT,
                           @Lc_CheckBox8_TEXT AS CHK_MOD_OPT,
                           @Lc_CheckBox9_TEXT AS CHK_MS_OPT,
                           @Lc_CheckBox13_TEXT AS CHK_OBLIGOR_OPT,
                           @Lc_CheckBox14_TEXT AS CHK_OBLIGEE_OPT,
                           @Lc_CheckBox15_TEXT AS CHK_STATE_OPT,
                           @Lc_CheckBox16_TEXT AS CHK_ENF_RESP_OPT,
                           @Lc_CheckBox17_TEXT AS CHK_COL_ARR_OPT,
                           @Lc_CheckBox18_TEXT AS CHK_MOD_RESP_OPT,
                           @Lc_CheckBox19_TEXT AS CHK_IW_OPT,
                           @Lc_CheckBox20_TEXT AS CHK_CHG_PAYEE_OPT,
                           @Lc_CheckBox21_TEXT AS CHK_ADMN_RW_TAX_OFFSET_OPT,
                           @Lc_CheckBox22_TEXT AS CHK_RDIR_PYMT_OBLIGEE_ST_OPT) f)up UNPIVOT (Element_Value FOR Element_NAME IN ( CHK_PAT_OPT_CODE, CHK_FSO_OPT_CODE, CHK_EST_OPT_CODE, CHK_ENF_OPT_CODE, CHK_CS_MS_OPT_CODE, CHK_MOD_ENF_OPT_CODE, CHK_RET_CS_OPT_CODE, CHK_MOD_OPT_CODE, CHK_MS_OPT_CODE,  CHK_OBLIGOR_OPT_CODE, CHK_OBLIGEE_OPT_CODE, CHK_STATE_OPT_CODE, CHK_ENF_RESP_OPT_CODE, CHK_COL_ARR_OPT_CODE, CHK_MOD_RESP_OPT_CODE, CHK_IW_OPT_CODE, CHK_CHG_PAYEE_OPT_CODE, CHK_ADMN_RW_TAX_OFFSET_OPT_CODE, CHK_RDIR_PYMT_OBLIGEE_ST_OPT_CODE)) AS pvt);

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
