/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_SELECT_DE_FIPS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_SELECT_DE_FIPS
Programmer Name	:	IMP Team.
Description		:	Procedure fetches the DE state FIPS.
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICE_CM$SP_GENERATE_NOTICE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_SELECT_DE_FIPS]
(
 @An_Case_IDNO             NUMERIC(6),
 @As_Prefix_TEXT           VARCHAR(70) = 'InstateFips',
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
)
AS
 BEGIN
 
  DECLARE  @Ls_CaseStatusOpen_CODE  CHAR(1) = 'O',
           @Lc_StatusSuccess_CODE   CHAR(1) = 'S',
           @Lc_StatusFailed_CODE    CHAR(1) = 'F',
           @Lc_DoubleSpace_TEXT     CHAR(2) = '  ',
           @Lc_DeStateFips_CODE     CHAR(2) = '10',
           @Lc_Office00_CODE        CHAR(2) = '00',
           @Ls_Procedure_NAME       VARCHAR(100) = ' BATCH_GEN_NOTICE_CNET.BATCH_GEN_NOTICE_CNET$SP_SELECT_DE_FIPS ';
           
  DECLARE  @Ls_Sql_TEXT              VARCHAR(200),
           @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_Err_Description_TEXT  VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6))
   SET @Ls_Sql_TEXT = 'SELECT CASE_Y1 '

   IF @As_Prefix_TEXT IS NULL OR @As_Prefix_TEXT = ''
	BEGIN
		SET @As_Prefix_TEXT = 'InstateFips';
	END
   
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   SELECT @As_Prefix_TEXT, 
		 (@Lc_DeStateFips_CODE + RIGHT(REPLICATE('0', 3) + CAST(c.County_IDNO AS VARCHAR), 3) 
				+ @Lc_Office00_CODE) AS Fips_CODE
     FROM CASE_Y1 c
    WHERE c.Case_IDNO = @An_Case_IDNO
      AND c.StatusCase_CODE = @Ls_CaseStatusOpen_CODE;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE (),
            @Ls_DescriptionError_TEXT VARCHAR (4000);

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;

GO
