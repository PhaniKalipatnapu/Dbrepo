/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_EST19_CHKBOX_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_EST19_CHKBOX_OPTS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to check EST-19
Frequency		:	
Developed On	:	3/16/2012
Called By		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_EST19_CHKBOX_OPTS] (
	 @An_Case_IDNO			   NUMERIC(6),
	 @Ac_ActivityMajor_CODE	   CHAR(4),
	 @Ac_ReasonStatus_CODE	   CHAR(2),
	 @An_MajorIntSeq_NUMB	   NUMERIC(5),	
	 @An_MinorIntSeq_NUMB	   NUMERIC(5),
	 @Ac_Msg_CODE			   CHAR(5)		 OUTPUT,  
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
          @Lc_ReasonStatusER_CODE     CHAR(2) = 'ER',
          @Lc_ReasonStatusEM_CODE     CHAR(2) = 'EM',
          @Lc_ReasonStatusRM_CODE     CHAR(2) = 'RM',
          @Ls_Procedure_NAME          VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_EST19_CHKBOX_OPTS';
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

   IF @An_MinorIntSeq_NUMB != 1
    BEGIN
     SELECT @Ac_ReasonStatus_CODE = ReasonStatus_CODE
       FROM DMNR_Y1 d
      WHERE d.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
        AND d.MinorIntSeq_NUMB = 1
        AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
        AND d.Case_IDNO = @An_Case_IDNO;
    END

   IF @Ac_ReasonStatus_CODE = @Lc_ReasonStatusER_CODE
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Lc_CheckBox2_TEXT = @Lc_Space_TEXT;
     SET @Lc_CheckBox3_TEXT = @Lc_Space_TEXT;
    END
   ELSE IF @Ac_ReasonStatus_CODE = @Lc_ReasonStatusEM_CODE
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;
     SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxCheckValue_TEXT;
     SET @Lc_CheckBox3_TEXT = @Lc_Space_TEXT;
    END
   ELSE IF @Ac_ReasonStatus_CODE = @Lc_ReasonStatusRM_CODE
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;
     SET @Lc_CheckBox2_TEXT = @Lc_Space_TEXT;
     SET @Lc_CheckBox3_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_Name,
                Element_Value)
   (SELECT Element_Name,
           Element_Value
      FROM (SELECT CAST(a.CHK_BOX_1 AS CHAR(1)) registration_enforcement_code,
                   CAST(a.CHK_BOX_2 AS CHAR(1)) enforcement_modification_code,
                   CAST(a.CHK_BOX_3 AS CHAR(1)) registration_modification_code
              FROM (SELECT @Lc_CheckBox1_TEXT CHK_BOX_1,
                           @Lc_CheckBox2_TEXT CHK_BOX_2,
                           @Lc_CheckBox3_TEXT CHK_BOX_3) a)up UNPIVOT (Element_Value FOR Element_Name IN( registration_enforcement_code, enforcement_modification_code, registration_modification_code )) AS pvt);

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
