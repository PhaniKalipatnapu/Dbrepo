/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_SUPPORT_ORDER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_SUPPORT_ORDER
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_SUPPORT_ORDER] (
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_OrderTypeVoluntary_CODE CHAR(1) = 'V',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_CheckBoxCheckValue_TEXT CHAR(1) = 'X',
          @Ls_Procedure_NAME          VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_SUPPORT_ORDER ',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE @Ln_Value_QNTY       NUMERIC(11) = 0,
          @Lc_CheckBox1_TEXT   CHAR(1),
          @Lc_CheckBox2_TEXT   CHAR(1),
          @Ls_Sql_TEXT         VARCHAR(200),
          @Ls_Sqldata_TEXT     VARCHAR(400),
          @Ld_OrderIssued_DATE DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ls_Sql_TEXT = 'SELECT SORD_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');
   
   SELECT @Ln_Value_QNTY = COUNT(1)
     FROM SORD_Y1 a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.TypeOrder_CODE <> @Lc_OrderTypeVoluntary_CODE
      AND a.OrderEnd_DATE >= @Ad_Run_DATE
      AND a.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Value_QNTY = 0
    BEGIN
     SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;
     SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxCheckValue_TEXT;
    END
   ELSE
    BEGIN
     SELECT TOP 1 @Ld_OrderIssued_DATE = OrderIssued_DATE
       FROM SORD_Y1 s
      WHERE s.Case_IDNO = @An_Case_IDNO
        AND s.TypeOrder_CODE <> @Lc_OrderTypeVoluntary_CODE
        AND s.OrderEnd_DATE >= @Ad_Run_DATE
        AND s.EndValidity_DATE = @Ld_High_DATE;

     IF @Ld_OrderIssued_DATE IS NOT NULL
      BEGIN
       SET @Lc_CheckBox1_TEXT = @Lc_CheckBoxCheckValue_TEXT;
       SET @Lc_CheckBox2_TEXT = @Lc_Space_TEXT;
      END
     ELSE
      BEGIN
       SET @Lc_CheckBox1_TEXT = @Lc_Space_TEXT;
       SET @Lc_CheckBox2_TEXT = @Lc_CheckBoxCheckValue_TEXT;
      END
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), SUPPORT_ORDER_EXIST_YES_CODE) SUPPORT_ORDER_EXIST_YES_CODE,
                   CONVERT(VARCHAR(100), SUPPORT_ORDER_EXIST_NO_CODE) SUPPORT_ORDER_EXIST_NO_CODE
              FROM (SELECT @Lc_CheckBox1_TEXT AS SUPPORT_ORDER_EXIST_YES_CODE,
                           @Lc_CheckBox2_TEXT AS SUPPORT_ORDER_EXIST_NO_CODE) h)up UNPIVOT (tag_value FOR tag_name IN ( SUPPORT_ORDER_EXIST_YES_CODE, SUPPORT_ORDER_EXIST_NO_CODE )) AS pvt);

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
 END


GO
