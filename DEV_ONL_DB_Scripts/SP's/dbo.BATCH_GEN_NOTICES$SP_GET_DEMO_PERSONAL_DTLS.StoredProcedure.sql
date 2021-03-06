/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_DEMO_PERSONAL_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_DEMO_PERSONAL_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get member Personal Address details from Demo_Y1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_DEMO_PERSONAL_DTLS]
 @An_MemberMci_IDNO        VARCHAR( 10),
 @As_Prefix_TEXT           VARCHAR(100),
 @Ac_Msg_CODE              CHAR(5)		 OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN

  DECLARE  @Lc_StatusSuccess_CODE	CHAR(1) = 'S',
           @Lc_StatusFailed_CODE	CHAR(1) = 'F',
           @Lc_CheckBoxValue_CODE	CHAR(1) = 'X',
           @Lc_Empty_TEXT			CHAR(1) = '',
           @Lc_LanguageEnglish_CODE	CHAR(2) = 'EN',
           @Lc_TableGENR_ID			CHAR(4) = 'GENR',
           @Lc_TableSubLANG_ID		CHAR(4) = 'LANG',
           @Ls_Routine_TEXT			VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_DEMO_PERSONAL_DTLS',
           @Ls_Sql_TEXT				VARCHAR(200) = 'SELECT DEMO_Y1',
           @Ls_Sqldata_TEXT			VARCHAR(400) = 'MEMBER_IDNO =',
           @Ld_High_DATE			DATE = '12/31/9999';

  DECLARE  @Ls_DescriptionError_TEXT  VARCHAR(4000);  
          
  DECLARE @NoticeElements_P1 TABLE  
            (  
               Element_NAME    VARCHAR (150),  
               Element_VALUE   VARCHAR (4000)  
            );  

  BEGIN TRY
  
	   SET @Ac_Msg_CODE = NULL;
	   SET @As_DescriptionError_TEXT = NULL;


		SET @Ls_Sql_TEXT = 'Insert @NoticeElements_P1';  
		SET @Ls_Sqldata_TEXT = ' An_MemberMci_IDNO = ' + CAST(ISNULL(@An_MemberMci_IDNO, 0) AS VARCHAR(10));   
	    
	   INSERT INTO @NoticeElements_P1(Element_NAME,Element_VALUE)  
		SELECT Element_NAME, Element_VALUE 
		FROM  
		(SELECT    
				CAST(b.Language_Spoken_TEXT AS VARCHAR(100)) Language_Spoken_Text,  
				CAST(b.Language_CODE_Yes_Code AS VARCHAR(100)) Language_Code_Yes_Code ,    
				CAST(b.Language_CODE_No_Code AS VARCHAR(100)) Language_Code_No_Code 					
				FROM   
				( 
				   SELECT 
				   (CASE WHEN a.Language_CODE_Yes_Code = @Lc_CheckBoxValue_CODE 
							THEN a.Language_CODE 
						 ELSE @Lc_Empty_TEXT 
					END)Language_Spoken_TEXT,
					a.Language_CODE_Yes_Code,
					a.Language_CODE_No_Code
				   FROM
				   ( 
						SELECT (CASE WHEN d.Language_CODE != @Lc_Empty_TEXT AND d.Language_CODE IS NOT NULL AND Language_CODE != @Lc_LanguageEnglish_CODE
										THEN @Lc_CheckBoxValue_CODE 
									 ELSE @Lc_Empty_TEXT 
								END) Language_CODE_Yes_Code,
							   (CASE WHEN d.Language_CODE = @Lc_Empty_TEXT OR d.Language_CODE IS NULL OR Language_CODE = @Lc_LanguageEnglish_CODE
										THEN @Lc_CheckBoxValue_CODE 
									 ELSE @Lc_Empty_TEXT 
								END) Language_CODE_No_Code,
								dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_TableGENR_ID, @Lc_TableSubLANG_ID, d.Language_CODE) as Language_CODE
						FROM DEMO_Y1 d
					   WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO
					)a 
				)b) up  
		UNPIVOT   
			 (Element_VALUE FOR Element_NAME IN (Language_Spoken_Text,
										 Language_Code_Yes_Code ,
										 Language_Code_No_Code 
										))  
										 AS pvt ;
								
		SET @Ls_Sql_TEXT = 'UPDATE @NoticeElements_P1';  
		SET @Ls_Sqldata_TEXT = ' @Prefix_TEXT = ' + @As_Prefix_TEXT;                             
	           
		UPDATE @NoticeElements_P1  
				SET Element_NAME = @As_Prefix_TEXT + '_' + Element_NAME;  
	  
		INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)  
				SELECT TE.Element_NAME, TE.Element_VALUE  
				  FROM @NoticeElements_P1 TE;  
	              
	   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
   DECLARE @Li_Error_NUMB					INT = ERROR_NUMBER (),
		   @Li_ErrorLine_NUMB				INT = ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END
         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END

GO
