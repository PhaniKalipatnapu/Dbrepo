/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_ORDER_INFO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_GEN_NOTICES$SP_ORDER_INFO
Programmer Name		: IMP Team
Description 	    : This Procedure is used to retrieve the Order information.
Frequency			:
Developed On		: 01/20/2011
Called By			: BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On	        : 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_ORDER_INFO]
 @An_Case_IDNO             NUMERIC(6),
 @An_OrderSeq_NUMB         NUMERIC(15),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_TableStat_ID       CHAR(4) = 'STAT',
          @Lc_TableSubStat_ID    CHAR(4) = 'STAT',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_ORDER_INFO',
          @Ld_Highdate_DATE      DATE= '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = ' SELECT SORD_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Order_SEQ = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '');

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), Order_IDNO) Order_NUMB,
                   CONVERT(VARCHAR(100), SourceOrdered_CODE) SourceOrdered_CODE,
                   CONVERT(VARCHAR(100), OrderEffective_DATE) OrderEffective_DATE,
                   CONVERT(VARCHAR(100), OrderEnt_DATE) OrderEnt_DATE,
                   CONVERT(VARCHAR(100), OrderEnt_Day) OrderEnt_Day,
                   CONVERT(VARCHAR(100), OrderEnt_Month) OrderEnt_Month,
                   CONVERT(VARCHAR(100), OrderEnt_Year) OrderEnt_Year,
                   CONVERT(VARCHAR(100), OrderEnd_DATE) OrderEnd_DATE,
                   CONVERT(VARCHAR(100), OrderIssued_DATE) OrderIssued_DATE,
                   CONVERT(VARCHAR(100), TypeOrder_CODE) TypeOrder_CODE,
                   ISNULL(CONVERT(VARCHAR(100), StateControl_CODE), '') Curr_Order_Court_State_text
              FROM (SELECT a.Order_IDNO,
                           a.SourceOrdered_CODE,
                           a.OrderEffective_DATE,
                           CONVERT(VARCHAR, a.OrderEnt_DATE, 101) AS OrderEnt_DATE,
                           CONVERT(VARCHAR, a.OrderEnd_DATE, 101) AS OrderEnd_DATE,
                           DAY(OrderEnt_DATE) AS OrderEnt_Day,
                           MONTH(OrderEnt_DATE) AS OrderEnt_Month,
                           YEAR(OrderEnt_DATE) AS OrderEnt_Year,
                           a.OrderIssued_DATE,
                           a.TypeOrder_CODE,
                           (SELECT DescriptionValue_TEXT
                              FROM REFM_Y1 r
                             WHERE r.Value_CODE = a.StateControl_CODE
                               AND r.TableSub_ID = @Lc_TableStat_ID
                               AND r.Table_ID = @Lc_TableSubStat_ID) AS StateControl_CODE
                      FROM SORD_Y1  a
                     WHERE a.Case_IDNO = @An_Case_IDNO
                       AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB
                       AND a.EndValidity_DATE = @Ld_Highdate_DATE)a) up UNPIVOT (tag_value FOR tag_name IN ( Order_NUMB, SourceOrdered_CODE, OrderEffective_DATE, OrderEnt_DATE, OrderEnd_DATE, OrderEnt_Day, OrderEnt_Month, OrderEnt_Year, OrderIssued_DATE, TypeOrder_CODE, Curr_Order_Court_State_text)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER(),
          @Ln_ErrorLine_NUMB = ERROR_LINE(),
          @Ls_DescriptionError_TEXT = 'INSERT_#NoticeElementsData_P1 FAILED';

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
