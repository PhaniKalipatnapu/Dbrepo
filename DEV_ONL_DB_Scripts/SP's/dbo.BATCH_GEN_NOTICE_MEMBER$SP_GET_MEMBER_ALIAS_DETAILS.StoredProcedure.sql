/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS]
(
 @An_MemberMci_IDNO        NUMERIC(10),
 @As_Prefix_TEXT           VARCHAR(70),
 @Ac_Msg_CODE              VARCHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR OUTPUT
)
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_TypeAliasA1_CODE    CHAR(1) = 'A',
           @Ld_High_DATE           DATE = '12/31/9999';
           
  DECLARE  @Ls_Procedure_NAME         VARCHAR(100),
           @Ls_Sql_TEXT               VARCHAR(200),
           @Ls_Sqldata_TEXT           VARCHAR(1000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000);

  BEGIN TRY
	    SET @Ac_Msg_CODE = NULL;
	    SET @As_DescriptionError_TEXT = NULL;
	    SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS ';
	    SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + CAST(ISNULL(@An_MemberMci_IDNO,0) AS VARCHAR(10));
   
	    DECLARE @Ndel_P1 TABLE
				  (
					 Element_NAME    VARCHAR(100),
					 Element_Value   VARCHAR(100)
				  );
   
		SET @Ls_Sql_TEXT = 'SELECT_VAKAX';
   
		INSERT INTO @Ndel_P1 (Element_NAME,ELEMENT_VALUE)        
			(SELECT tag_name, tag_value FROM      
			  (       
			  SELECT        
		            
				CONVERT(VARCHAR(100),AliasFml_NAME )	AliasFml_NAME,   
				CONVERT(VARCHAR(100),FirstAlias_NAME )	FirstAlias_NAME,   
				CONVERT(VARCHAR(100),LastAlias_NAME )	LastAlias_NAME,   
				CONVERT(VARCHAR(100),TitleAlias_NAME )	TitleAlias_NAME,   
				CONVERT(VARCHAR(100),MaidenAlias_NAME ) MaidenAlias_NAME,   
				CONVERT(VARCHAR(100),MiddleAlias_NAME) MiddleAlias_NAME,   
				CONVERT(VARCHAR(100),SuffixAlias_NAME ) SuffixAlias_NAME   
				
				FROM  	(
						 SELECT  (a.LastAlias_NAME + ' ' +
								 a.FirstAlias_NAME + ' ' +
								 a.MiddleAlias_NAME) AS AliasFml_NAME,
								 a.LastAlias_NAME,
								 a.FirstAlias_NAME,
								 a.MiddleAlias_NAME,
								 a.TitleAlias_NAME AS TitleAlias_NAME ,  
								 a.MaidenAlias_NAME AS MaidenAlias_NAME, 
								 a.SuffixAlias_NAME AS SuffixAlias_NAME
						 FROM AKAX_Y1  AS a
						 WHERE 
								a.MemberMci_IDNO = @An_MemberMci_IDNO    
							AND a.TypeAlias_CODE = @Lc_TypeAliasA1_CODE 
							AND a.EndValidity_DATE = @Ld_High_DATE
							AND a.Sequence_NUMB = 
							(
							   SELECT MAX(b.Sequence_NUMB) AS expr
												   FROM AKAX_Y1  AS b
												   WHERE 
														  a.MemberMci_IDNO = b.MemberMci_IDNO 
													  AND a.TypeAlias_CODE = b.TypeAlias_CODE 
													  AND a.EndValidity_DATE = b.EndValidity_DATE))a 
									   ) up      
									 UNPIVOT       
									  (tag_value FOR tag_name IN (
												AliasFml_NAME,
												FirstAlias_NAME,
												LastAlias_NAME,
												TitleAlias_NAME,   
												MaidenAlias_NAME, 
												MiddleAlias_NAME,
												SuffixAlias_NAME
												))      
									  AS pvt) ;

   UPDATE @Ndel_P1
            SET Element_NAME = @As_Prefix_TEXT + '_' + Element_NAME;

   INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
            SELECT t.Element_NAME, t.Element_Value
              FROM @Ndel_P1 t;
              
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
 END TRY
 BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
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
