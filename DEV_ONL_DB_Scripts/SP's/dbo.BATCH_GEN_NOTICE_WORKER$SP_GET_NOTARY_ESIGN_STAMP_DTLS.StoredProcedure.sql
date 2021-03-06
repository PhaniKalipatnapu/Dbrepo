/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_NOTARY_ESIGN_STAMP_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_GEN_NOTICE_WORKER$SP_GET_NOTARY_ESIGN_STAMP_DTLS
Programmer Name		: IMP Team
Description 	    : This procedure is used to get the notary stamp related Details.
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

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_NOTARY_ESIGN_STAMP_DTLS]  
 @Ac_Worker_ID      		  CHAR(30),  
 @As_Pin_TEXT       		  VARCHAR(64), 
 @Ad_Run_DATE				  DATE,
 @As_EsignNotary_TEXT   	  VARCHAR(500) OUTPUT,
 @Ad_EsignNotary_DATE     	  DATE OUTPUT,
 @As_NotaryCnty_NAME		  VARCHAR(500) OUTPUT,
 @As_NotaryState_NAME		  VARCHAR(500) OUTPUT,
 @As_NotaryDay_TEXT           VARCHAR(10) OUTPUT,    
 @As_NotaryMonth_TEXT         VARCHAR(20) OUTPUT,  
 @An_NotaryYear_NUMB          NUMERIC(9) OUTPUT,  
 @As_EstampNotary_TEXT		  VARCHAR(500) OUTPUT,
 @As_EsignNotary_NAME  	      VARCHAR(500) OUTPUT,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,  
 @As_DescriptionError_TEXT    VARCHAR(MAX) OUTPUT  
AS  
 BEGIN 
 	DECLARE 
 		  @Li_Error_NUMB   			 INT = ERROR_NUMBER (),
          @Li_ErrorLine_NUMB         INT =  ERROR_LINE (),
 		  @Lc_StatusSuccess_CODE     CHAR(1) = 'S',  
          @Ls_StatusNoDataFound_CODE CHAR(1) = 'N',  
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Ld_High_DATE              DATE = '12/31/9999',
          @Ls_Procedure_NAME		 VARCHAR(100) =  'BATCH_GEN_NOTICE_WORKER$SP_GET_NOTARY_ESIGN_STAMP_DTLS';
	DECLARE          
          @Li_Record_QNTY			 SMALLINT,
          @Ls_Sql_TEXT               VARCHAR(100),  
          @Ls_Sqldata_TEXT           VARCHAR(400),  
          @Ls_DescriptionError_TEXT  VARCHAR(4000),
          @Ld_Run_DATE              DATE;

   BEGIN TRY 
    	  
   SET @Ac_Msg_CODE = NULL  
   SET @As_DescriptionError_TEXT = NULL  
   SET @Ld_Run_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  
   
   SELECT @Li_Record_QNTY = COUNT(1)
     FROM USEM_Y1 A 
          JOIN NOST_Y1 B
          ON A.Worker_ID = B.Worker_ID
          JOIN USES_Y1 C
          ON A.WORKER_ID = C.WORKER_ID
    WHERE A.Worker_ID = @Ac_Worker_ID
      AND B.Pin_TEXT = @As_Pin_TEXT  
      AND C.Esignature_BIN <> '' 
      AND A.EndValidity_DATE = @Ld_High_DATE;
      
    IF @Li_Record_QNTY > 0  
    BEGIN  
	 SELECT	@As_EsignNotary_TEXT = CONVERT(VARCHAR(500), TransactionEventSeq_NUMB) ,  
			@Ad_EsignNotary_DATE = Sysdate ,
			@As_EstampNotary_TEXT = CONVERT(VARCHAR(500), Notary_Stamp) ,
			@As_EsignNotary_NAME = ESIGN_NOTARY_NAME ,
			@As_NotaryCnty_NAME = County_Name,
			@As_NotaryState_NAME   = State_Name,
			@As_NotaryDay_TEXT = CONVERT(VARCHAR(10),dbo.BATCH_GEN_NOTICE_UTIL$SF_GET_TIDY_DAY(@Ld_Run_DATE)),       
		    @As_NotaryMonth_TEXT= CONVERT(VARCHAR(20),DATENAME (M, @Ld_Run_DATE)),  
			@An_NotaryYear_NUMB = CONVERT(NUMERIC(9),DATENAME (YEAR, @Ld_Run_DATE))
      FROM (SELECT C.TransactionEventSeq_NUMB,  
                   CONVERT(VARCHAR,dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),101) Sysdate,
                   (B.Line1_TEXT + '~' + B.Line2_TEXT + '~' + B.Line3_TEXT + ' ' + CASE WHEN B.Expiry_DATE = @Ld_High_DATE THEN ' ' ELSE CONVERT(VARCHAR(10),B.Expiry_DATE,101)END) AS Notary_Stamp,
                   (ISNULL(LTRIM(RTRIM(A.First_NAME)) ,'')  
			          + ' ' + ISNULL(LTRIM(RTRIM(A.Middle_NAME)) ,'')   
			          + ' ' + ISNULL(LTRIM(RTRIM(A.Last_NAME)) ,'')) ESIGN_NOTARY_NAME ,
			          lc.County_Name,
                      lc.State_Name 
              FROM USEM_Y1 A
		          JOIN NOST_Y1 B
		          ON A.Worker_ID = B.Worker_ID
		          JOIN USES_Y1 C
		          ON A.WORKER_ID = C.WORKER_ID
		       OUTER APPLY (
											SELECT TOP 1 co.County_Name AS County_Name , 'DE' AS State_Name 
												 FROM UASM_Y1 ua, COPT_Y1 co
												WHERE ua.Worker_ID = a.Worker_ID
												  AND ua.Office_IDNO = co.County_IDNO
												  AND @Ad_Run_DATE BETWEEN ua.Effective_DATE AND ua.Expire_DATE
												  AND ua.EndValidity_DATE = @Ld_High_DATE
												  ) lc
		    WHERE A.Worker_ID = @Ac_Worker_ID   
		      AND B.Pin_TEXT = @As_Pin_TEXT  
		      AND C.Esignature_BIN <> '' 
		      AND A.EndValidity_DATE = @Ld_High_DATE
		      )a  ;
		      
	  SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE  		      
    END  
  	ELSE
  	BEGIN
  		SET @Ac_Msg_CODE = @Ls_StatusNoDataFound_CODE
  		   IF ERROR_NUMBER () = 50001  
	    BEGIN  
	     SET @Ls_DescriptionError_TEXT = 'Error in ' + ERROR_PROCEDURE () + ' Procedure' + '. Error Desc - ' + @As_DescriptionError_TEXT + '. Error Execute Location - ' + @Ls_Sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;  
	    END  
	   ELSE  
	    BEGIN  
	    SET @Ls_DescriptionError_TEXT = 'Error in ' + ERROR_PROCEDURE () + ' Procedure' + '. Error Desc - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);  
	    END  
	  
	   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;     
  		
  	END
   
   
   END TRY
   
   BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   
   IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Li_Error_NUMB,
      @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      
      SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

  END CATCH
  
  END  

GO
