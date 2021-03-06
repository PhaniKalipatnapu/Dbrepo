/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_ARRS_START_END_DATES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_ARRS_START_END_DATES
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_ARRS_START_END_DATES]  
 @An_Case_IDNO				NUMERIC(6),  
 @Ac_Msg_CODE				VARCHAR(1) OUTPUT,  
 @As_DescriptionError_TEXT	VARCHAR OUTPUT  
AS  
 BEGIN  
  DECLARE @Ld_High_DATE              DATE = '12/31/9999',  
          @Ls_StatusSuccess_CODE     CHAR = 'S',  
          @Ls_StatusNoDataFound_CODE CHAR = 'N',  
          @Ls_DoubleSpace_TEXT       VARCHAR(2) = '  ',  
          @Ls_StatusFailed_CODE      CHAR = 'F',  
          @Ls_DateFormatYyyymm_TEXT  VARCHAR(7) = 'YYYY/MM',  
          @Ls_MsgZ1_CODE             CHAR(1) = 'Z',  
          @Ls_Routine_TEXT           VARCHAR(100),  
          @Ls_Sql_TEXT               VARCHAR(200),  
          @Ls_Sqldata_TEXT           VARCHAR(1000),  
          @Ld_OrderEnd_DATE          DATE,  
          @Ld_OrderEnt_DATE          DATE;  
  
  BEGIN TRY  
   SET @Ld_OrderEnd_DATE = NULL;  
   SET @Ld_OrderEnt_DATE = NULL;  
   SET @Ac_Msg_CODE = NULL;  
   SET @As_DescriptionError_TEXT = NULL;  
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_FIN.BATCH_GEN_NOTICE_FIN$SP_ARRS_START_END_DATES ';  
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS CHAR), '');  
   SET @Ls_Sql_TEXT = 'SELECT LSUP_Y1';  
  
   SELECT @Ld_OrderEnd_DATE = CAST(LTRIM(RTRIM(CAST(MAX(c.SupportYearMonth_NUMB) AS CHAR))) + '01' AS DATETIME),  
          @Ld_OrderEnt_DATE = CAST(LTRIM(RTRIM(CAST(MIN(c.SupportYearMonth_NUMB) AS CHAR))) + '01' AS DATETIME)  
     FROM LSUP_Y1 AS c  
    WHERE c.Case_IDNO = @An_Case_IDNO  
      AND c.OrderSeq_NUMB IN (SELECT DISTINCT  
                                     b.OrderSeq_NUMB  
                                FROM SORD_Y1 AS b  
                               WHERE b.Case_IDNO = c.Case_IDNO  
                                 AND b.EndValidity_DATE = @Ld_High_DATE);  
  
   INSERT INTO #NoticeElementsData_P1  
               (Element_NAME,  
                Element_Value)  
   (SELECT tag_name,  
           tag_value  
      FROM (SELECT CONVERT(VARCHAR(100), DT_ARRS_TO) DT_ARRS_TO,  
                   CONVERT(VARCHAR(100), DT_ARRS_FROM) DT_ARRS_FROM  
              FROM (SELECT @Ld_OrderEnd_DATE AS DT_ARRS_TO,  
                           @Ld_OrderEnt_DATE AS DT_ARRS_FROM) f)up UNPIVOT (tag_value FOR tag_name IN ( DT_ARRS_TO, DT_ARRS_FROM )) AS pvt);  
  
   SET @Ac_Msg_CODE = @Ls_StatusSuccess_CODE;  
  END TRY  
  
  BEGIN CATCH  
   DECLARE @Ln_Errornumber_NUMB INT/*TODO: Arg/Var Names need to analyzed and changed Manually*/;  
   DECLARE @Ls_Errormessage_TEXT NVARCHAR(4000);  
   DECLARE @Ln_ErrorLine_NUMB INT;  
  
   SET @Ac_Msg_CODE = @Ls_StatusFailed_CODE;  
   SET @Ln_Errornumber_NUMB = ERROR_NUMBER();  
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();  
   SET @Ls_Errormessage_TEXT = ISNULL(@As_DescriptionError_TEXT, '') + SUBSTRING(ERROR_MESSAGE(), 1, 200);  
   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Sql_TEXT, '') + ISNULL (@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Errormessage_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@As_DescriptionError_TEXT, '');  
  END CATCH  
 END  



GO
