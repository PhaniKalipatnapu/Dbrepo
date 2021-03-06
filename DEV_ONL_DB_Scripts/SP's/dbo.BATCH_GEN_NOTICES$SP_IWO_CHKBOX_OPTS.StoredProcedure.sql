/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_IWO_CHKBOX_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_IWO_CHKBOX_OPTS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to check ENF-01 ORIGINAL INCOME WITHHOLDING, AMENDED IWO, TERMINATION of IWO
						NSOII -> OX	ORIGINAL
						MPCOA -> CK	AMENDED
						MPCOA -> GR/NZ	TERMINATED
Frequency		:	
Developed On	:	4/19/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_IWO_CHKBOX_OPTS] (
 @Ac_ActivityMajor_CODE    CHAR(4),
 @Ac_ActivityMinor_CODE    CHAR(5),
 @Ac_ReasonStatus_CODE     CHAR(2),
 @Ac_PrintMethod_CODE      CHAR(1),
 @Ac_Job_ID                CHAR(7),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Li_Error_NUMB              INT = NULL,
          @Li_ErrorLine_NUMB          INT = NULL,
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_CheckBoxCheckValue_TEXT CHAR(1) = 'X',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_PrintMethodView_CODE    CHAR(1) = 'V',
          @Lc_ReasonStatusOx_CODE     CHAR(2) = 'OX',
          @Lc_ReasonStatusCk_CODE     CHAR(2) = 'CK',
          @Lc_ReasonStatusGr_CODE     CHAR(2) = 'GR',
          @Lc_ReasonStatusNz_CODE     CHAR(2) = 'NZ',
          @Lc_Screen_ID               CHAR(4) = 'NPRO',
          @Lc_ActivityMajorImiw_CODE  CHAR(4) = 'IMIW',
          @Lc_ActivityMinorNsoii_CODE CHAR(5) = 'NSOII',
          @Lc_ActivityMinorMpcoa_CODE CHAR(5) = 'MPCOA',
          @Lc_ActivityMinorIniiwh_CODE CHAR(5) = 'INIWH',
          @Lc_ActivityMinorNopri_CODE CHAR(5) = 'NOPRI',
          @Ls_Procedure_NAME          VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_IWO_CHKBOX_OPTS',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE @Lc_CheckBox1_TEXT        CHAR(1),
          @Lc_CheckBox2_TEXT        CHAR(1),
          @Lc_CheckBox3_TEXT        CHAR(1),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_CheckBox1_TEXT = '';
   SET @Lc_CheckBox2_TEXT = '';
   SET @Lc_CheckBox3_TEXT = '';
   SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1';


   IF @Ac_ActivityMinor_CODE = @Lc_ActivityMinorNopri_CODE AND @Ac_Job_ID = @Lc_Screen_ID
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;
     SET @Lc_CheckBox2_TEXT = @Lc_Space_TEXT;
     SET @Lc_CheckBox3_TEXT = @Lc_Space_TEXT;
    END
   IF @Ac_ActivityMinor_CODE = @Lc_ActivityMinorNopri_CODE AND @Ac_Job_ID <> @Lc_Screen_ID
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;
     SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Lc_CheckBox3_TEXT = @Lc_Space_TEXT;
    END
   ELSE
    BEGIN
    
     IF (@Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE)
         AND @Ac_ActivityMinor_CODE IN (@Lc_ActivityMinorNsoii_CODE,@Lc_ActivityMinorIniiwh_CODE)
         AND @Ac_ReasonStatus_CODE = @Lc_ReasonStatusOx_CODE)
      BEGIN
       SET @Lc_CheckBox1_TEXT = @Lc_CheckBoxCheckValue_TEXT;
       SET @Lc_CheckBox2_TEXT = @Lc_Space_TEXT;
       SET @Lc_CheckBox3_TEXT = @Lc_Space_TEXT;
      END
     ELSE IF (@Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE)
         AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorMpcoa_CODE
         AND @Ac_ReasonStatus_CODE = @Lc_ReasonStatusCk_CODE)
      BEGIN
       SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;
       SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxCheckValue_TEXT;
       SET @Lc_CheckBox3_TEXT = @Lc_Space_TEXT;
      END
     ELSE
      BEGIN
      -- 13129 - CR0345 IWO Process Changes 20131226 - Fix - Start
       IF (@Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE)
           AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorMpcoa_CODE
           AND @Ac_ReasonStatus_CODE = @Lc_ReasonStatusGr_CODE)
           OR (@Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE)
               AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorMpcoa_CODE
               AND @Ac_ReasonStatus_CODE = @Lc_ReasonStatusNz_CODE)
           OR (@Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE)  
               AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorNsoii_CODE  
               AND @Ac_ReasonStatus_CODE = @Lc_ReasonStatusNz_CODE)
	 -- 13129 - CR0345 IWO Process Changes 20131226 - Fix - End
        BEGIN
         SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;
         SET @Lc_CheckBox2_TEXT = @Lc_Space_TEXT;
         SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxCheckValue_TEXT;
        END
      END
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_Name,
                Element_Value)
   (SELECT Element_Name,
           Element_Value
      FROM (SELECT CAST(a.CHK_BOX_1 AS VARCHAR(1)) iwo_original_opt_code,
                   CAST(a.CHK_BOX_2 AS VARCHAR(1)) iwo_amended_opt_code,
                   CAST(a.CHK_BOX_3 AS VARCHAR(1)) iwo_terminate_opt_code
              FROM (SELECT @Lc_CheckBox1_TEXT CHK_BOX_1,
                           @Lc_CheckBox2_TEXT CHK_BOX_2,
                           @Lc_CheckBox3_TEXT CHK_BOX_3) a)up UNPIVOT (Element_Value FOR Element_Name IN( iwo_original_opt_code, iwo_amended_opt_code, iwo_terminate_opt_code)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
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
