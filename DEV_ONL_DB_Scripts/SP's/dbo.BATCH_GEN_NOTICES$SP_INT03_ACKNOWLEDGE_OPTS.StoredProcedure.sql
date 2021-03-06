/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_INT03_ACKNOWLEDGE_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_INT03_ACKNOWLEDGE_OPTS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_INT03_ACKNOWLEDGE_OPTS]
(
	 @Ac_Function_CODE			CHAR(3),
	 @Ac_Action_CODE			CHAR(1),
	 @Ac_Reason_CODE			CHAR(5),
	 @Ac_Msg_CODE				CHAR(5)			OUTPUT,
	 @As_DescriptionError_TEXT  VARCHAR(4000)	OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
           @Lc_StatusFailed_CODE           CHAR(1) = 'F',
           @Lc_CheckBoxCheckValue_TEXT     CHAR(1) = 'X',
           @Lc_ActionA1_CODE               CHAR(1) = 'A',
           @Lc_FunctionEnforcement_CODE    CHAR(3) = 'ENF',
           @Lc_FunctionEstablishment_CODE  CHAR(3) = 'EST',
           @Lc_FunctionPaternity_CODE      CHAR(3) = 'PAT',
           @Lc_ReasonAadin_CODE            CHAR(5) = 'AADIN',
           @Ls_Procedure_NAME              VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_INT03_ACKNOWLEDGE_OPTS';
           
  DECLARE  @Lc_InfoBlock_CODE         CHAR(1) = '',
           @Ls_Sql_TEXT               VARCHAR(200) = '',
           @Ls_Sqldata_TEXT           VARCHAR(1000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000);

  BEGIN TRY
	   SET @Ac_Msg_CODE = NULL;
	   SET @As_DescriptionError_TEXT = NULL;
	  
	   IF @Ac_Function_CODE IN (@Lc_FunctionEnforcement_CODE, @Lc_FunctionEstablishment_CODE, @Lc_FunctionPaternity_CODE)
		  AND @Ac_Action_CODE = @Lc_ActionA1_CODE
		  AND @Ac_Reason_CODE = @Lc_ReasonAadin_CODE
			  BEGIN
					SET @Lc_InfoBlock_CODE = @Lc_CheckBoxCheckValue_TEXT;
			  END
          SET @Ls_Sql_TEXT ='#NoticeElementsData_P1';
          SET @LS_SqlDATA_TEXT='Element_Value = '+ ISNULL(@Lc_InfoBlock_CODE,'');
      INSERT INTO #NoticeElementsData_P1
				   (Element_NAME,
					Element_Value)
		     VALUES('IND_INFO_BLOCK_CODE',
		             @Lc_InfoBlock_CODE);									
   	SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY    
  BEGIN CATCH    
		 SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;

         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

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
