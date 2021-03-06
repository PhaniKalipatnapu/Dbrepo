/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_SORD_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_GET_SORD_DETAILS
Programmer Name	:	IMP Team.
Description		:	This function is used to Court details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_GET_SORD_DETAILS]
 @An_Case_IDNO             NUMERIC(6),
 @Ad_Run_DATE              DATE,
 @An_OrderSeq_NUMB         NUMERIC(5),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR OUTPUT
AS
 BEGIN
  DECLARE 
          @Ld_High_DATE            DATE = '12/31/9999',
          @Lc_StatusFailed_CODE    CHAR = 'F',
          @Lc_StatusSuccess_CODE   CHAR = 'S',
          @Ls_Procedure_NAME	   VARCHAR(100) = 'BATCH_GEN_NOTICE_FIN$SP_GET_SORD_DETAILS',
          @Ls_TableStat_ID		   VARCHAR(4),
          @Ls_TableSubStat_ID      VARCHAR(4),
          @Ls_Routine_TEXT         VARCHAR(100),
          @Ls_Sql_TEXT             VARCHAR(200),
          @Ls_Sqldata_TEXT         VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000)

  BEGIN TRY
   
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_TableStat_ID = ISNULL(@Ls_TableStat_ID, 'STAT');
   SET @Ls_TableSubStat_ID = ISNULL(@Ls_TableSubStat_ID, 'STAT');
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_FIN$SP_GET_SORD_DETAILS ';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS NVARCHAR (MAX)), '');
   SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1';

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                ELEMENT_VALUE)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), StateControl_CODE) curr_order_court_state
              FROM (SELECT (SELECT DescriptionValue_TEXT
                              FROM REFM_Y1
                             WHERE Value_CODE = x.StateControl_CODE
                               AND TableSub_ID = @Ls_TableStat_ID
                               AND Table_ID = @Ls_TableSubStat_ID) AS StateControl_CODE
                         FROM SORD_Y1 AS x
                             WHERE x.Case_IDNO = @An_Case_IDNO
                               AND x.OrderSeq_NUMB = @An_OrderSeq_NUMB
                               AND x.EndValidity_DATE = @Ld_High_DATE
                               ) AS fci) up 
                               UNPIVOT (tag_value FOR tag_name IN (curr_order_court_state)) AS pvt);
                        
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

 BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
          DECLARE   @Li_Error_NUMB INT = ERROR_NUMBER (),
                   @Li_ErrorLine_NUMB INT = ERROR_LINE ();
        
         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END



GO
