/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_MEMBER_WORKER_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_MEMBER_WORKER_DETAILS
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_GEN_NOTICES$SP_GET_MEMBER_WORKER_DETAILS gets worker details form USEM_V1
						and insert that in to a local table #NoticeElementsData_P1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_MEMBER_WORKER_DETAILS]
 
  @Ac_Worker_ID				CHAR(30), 
  @Ac_Msg_CODE				CHAR(5) OUTPUT,
  @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
     
AS  
BEGIN   
 SET NOCOUNT ON;
    
	DECLARE  
			@Ls_ErrorDesc_TEXT				VARCHAR(4000),
			@Ls_Sql_TEXT					VARCHAR(100) = '',
            @Ls_Sqldata_TEXT				VARCHAR (1000) = '',
            @Ls_ErrorMesg_TEXT				VARCHAR(4000),
            @Ls_Error_CODE					VARCHAR(18),
            @Ls_Errorproc_NAME				VARCHAR(75),
            @Ld_High_DATE					DATETIME,
            @Lc_StatusSuccess_CODE			CHAR, 
			@Ls_Routine_TEXT				VARCHAR(60)='BATCH_GEN_NOTICES$SP_GET_MEMBER_WORKER_DETAILS',
			@Lc_StatusFailed_CODE			CHAR, 
			@Ls_Err_Description_TEXT		VARCHAR(4000),
			@Lc_Space_TEXT					CHAR=' ';
		   
		            
            SET @Ld_High_DATE='12-31-9999';
            SET @Lc_StatusSuccess_CODE='S';
			SET @Lc_StatusFailed_CODE='F';
			
   
 BEGIN TRY 
   
		 SET @Ls_Sql_TEXT = 'SELECT DEMO_V1 ';

		 SET @Ls_Sqldata_TEXT = ' Worker_IDNO: ' + ISNULL(@Ac_Worker_ID, '');	
		 
 
   INSERT INTO #NoticeElementsData_P1(Element_NAME,Element_VALUE)    
   (
		SELECT tag_name, tag_value from  
		   (   
			 SELECT    
					 CONVERT(VARCHAR(100),first_name) WORKER_FIRST_NAME,  
					 CONVERT(VARCHAR(100),last_name) WORKER_LAST_NAME ,  
					 CONVERT(VARCHAR(100),TransactionEvent_SEQ) WORKER_TRANSACTION_EVENT_SEQ  
		      
			from   
				 (  
					  SELECT   
					  First_NAME,  
					  Last_NAME,  
					  TransactionEvent_SEQ   
					  FROM USEM_V1    
					  WHERE Worker_IDNO  = @Ac_Worker_ID 
					  AND EndValidity_DATE = @Ld_High_DATE) a              
				 ) up  
			UNPIVOT   
				 (tag_value FOR tag_name IN (WORKER_FIRST_NAME,
											 WORKER_LAST_NAME,
											 WORKER_TRANSACTION_EVENT_SEQ))  
				 as pvt)  ;
      
   
			  IF @@ROWCOUNT=0
				BEGIN
					RAISERROR (50001, 16, 1);
				END
			 ELSE
				 BEGIN
					SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
				 END	
    END TRY    
    
 BEGIN CATCH   
			  SET @Ls_Sql_TEXT='INSERT WORKER DETAILS TO TEMP TABLE'
			  SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
				 IF Error_Number () = 50001
					BEGIN
						SET @Ls_Err_Description_TEXT =
							'Error in '
						  + ISNULL(Error_Procedure(),'SP_GET_MEMBER_WORKER_DETAILS')
						  + ' Procedure'
						  + '. Error Desc - '
						  + @Ls_ErrorDesc_TEXT
						  + '. Error Execute Location - '
						  + @ls_sql_TEXT
						  + '. Error List Key - '
						  + @Ls_Sqldata_TEXT;
					END
				ELSE
					BEGIN
						SET @Ls_Err_Description_TEXT =
							'Error in '
						  +ISNULL( Error_Procedure (),'SP_GET_MEMBER_WORKER_DETAILS')
						  + ' Procedure'
						  + '. Error Desc - '
						  + Substring (Error_Message (), 1, 200)
						  + '. Error Line No - '
						  + Cast (Error_Line () AS VARCHAR)
						  + '. Error Number - '
						  + Cast (Error_Number () AS VARCHAR)
						  + '. Error Execute Location - '
						  + @ls_sql_TEXT
						  + '. Error List Key - '
						  + @Ls_Sqldata_TEXT;
		            
					END
				SET @As_DescriptionError_TEXT=@Ls_Err_Description_TEXT ;
				
		     
		     
 END CATCH    
END     

GO
