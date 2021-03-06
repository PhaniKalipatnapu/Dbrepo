/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_TRANSACTION_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_TRANSACTION_ADDRESS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get address details from AHIS_Y1
Frequency		:	
Developed On	:	5/10/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_TRANSACTION_ADDRESS]
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE  @Lc_Space_TEXT  CHAR(1) = ' ',
		   @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_VerificationStatusGood_CODE  CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Lc_Mailing_ADDR                 CHAR(1) = 'M',
           @Lc_TypeAddress_Residence_CODE   CHAR(1) = 'R',
           @Lc_StatusPending_CODE           CHAR(1) = 'P',
           @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_GEN_NOTICE_CM$SP_GET_TRANSACTION_ADDRESS';

  DECLARE  @Li_Error_NUMB   		 INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB        INT =  ERROR_LINE ();

  DECLARE  @Ln_Record_QNTY           NUMERIC(2),
           @Ls_Sql_TEXT              VARCHAR(200) = '',
           @Ls_ErrorDesc_TEXT        VARCHAR(400) = '',
           @Ls_Sqldata_TEXT          VARCHAR(400) = '',
           @Ls_Err_Description_TEXT  VARCHAR(4000) = '',
           @Ld_Run_DATE              DATE;

  BEGIN TRY
   
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = '';
  
  
      SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1';
      SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '');
     
      DECLARE @NoticeElements_P1 TABLE
			( Element_NAME   VARCHAR(100),
			  Element_Value VARCHAR(100)
			);
			
	  INSERT INTO #NoticeElementsData_P1
	   (Element_NAME,
		Element_Value)
				   (SELECT pvt.Element_NAME, 
						  pvt.Element_Value 
						  FROM  
					   (   
					   SELECT    
						CONVERT(VARCHAR(100),a.Attn_ADDR) AS TransactionAttn_ADDR,  
						CONVERT(VARCHAR(100),a.Line1_ADDR)AS TransactionLine1_ADDR ,    
						CONVERT(VARCHAR(100),a.Line2_ADDR)AS TransactionLine2_ADDR ,  
						CONVERT(VARCHAR(100),a.City_ADDR) AS TransactionCity_ADDR,
						CONVERT(VARCHAR(100),a.State_ADDR)AS TransactionState_ADDR,  
						CONVERT(VARCHAR(100),a.Zip_ADDR) AS TransactionZip_ADDR ,    
						CONVERT(VARCHAR(100),a.Country_ADDR) AS TransactionCountry_ADDR ,  
						CONVERT(VARCHAR(100),a.SourceLoc_CODE) AS Source_CODE,  
						CONVERT(VARCHAR(100),a.Begin_DATE) AS ADDR_BEG_DT,
						CONVERT(VARCHAR(100),a.Status_CODE)AS Verified_addr_INDC,
						CONVERT(VARCHAR(100),a.verified_addr_yes_indc) AS verified_addr_yes_indc,
						CONVERT(VARCHAR(100),a.verified_addr_no_indc) AS verified_addr_no_indc,
						CONVERT(VARCHAR(100),a.Status_DATE) AS Addr_verified_DATE,
						CONVERT(VARCHAR(100),a.MailingAddress_CODE) AS MailingAddress_CODE,
						CONVERT(VARCHAR(100),a.ResidencialAddress_CODE) AS  ResidencialAddress_CODE,
						CONVERT(VARCHAR(100),a.lkcAddress_CODE) AS lkcAddress_CODE
					   FROM   
						(  
					   SELECT 
						  fci.Attn_ADDR AS Attn_ADDR, 
						  fci.Line1_ADDR AS Line1_ADDR, 
						  fci.Line2_ADDR AS Line2_ADDR, 
						  fci.City_ADDR AS City_ADDR, 
						  fci.State_ADDR AS State_ADDR, 
						  fci.Zip_ADDR AS Zip_ADDR, 
						  fci.Country_ADDR AS Country_ADDR, 
						  fci.SourceLoc_CODE AS SourceLoc_CODE, 
						  fci.Begin_DATE AS Begin_DATE, 
						  fci.Status_CODE AS Status_CODE,
						  CASE WHEN fci.Status_CODE = 'Y' THEN 'X'
							   ELSE ''
						  END verified_addr_yes_indc,
						  CASE WHEN fci.Status_CODE != 'Y' THEN 'X'
							   ELSE ''
						  END verified_addr_no_indc,
						  fci.Status_DATE AS Status_DATE,
						  CASE WHEN fci.Typeaddress_CODE = 'M' THEN 'X' ELSE '' END MailingAddress_CODE,
						  CASE WHEN fci.Typeaddress_CODE = 'R' THEN 'X' ELSE '' END ResidencialAddress_CODE,
						  CASE WHEN fci.Typeaddress_CODE = 'C' THEN 'X' ELSE '' END lkcAddress_CODE
					   FROM 
						  (
							SELECT RTRIM(a.Attn_ADDR) + @Lc_Space_TEXT AS Attn_ADDR, 
								   RTRIM(a.Line1_ADDR) + @Lc_Space_TEXT AS Line1_ADDR, 
								   RTRIM(a.Line2_ADDR) + @Lc_Space_TEXT AS Line2_ADDR, 
								   RTRIM(a.City_ADDR) AS City_ADDR, 
								   @Lc_Space_TEXT  + RTRIM(a.State_ADDR) + @Lc_Space_TEXT AS State_ADDR, 
								   RTRIM(a.Zip_ADDR) AS Zip_ADDR, 
								   @Lc_Space_TEXT + RTRIM(a.Country_ADDR) AS Country_ADDR,
								   (
									 SELECT LSRC_Y1.Source_NAME
									   FROM LSRC_Y1
									  WHERE LSRC_Y1.SourceLoc_CODE = a.SourceLoc_CODE
								   ) AS SourceLoc_CODE, 
								   a.Begin_DATE, 
								   a.Status_CODE,
								   a.Status_DATE,
								   a.TypeAddress_CODE
							  FROM AHIS_Y1 a
							  WHERE TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB)fci
					   )a
					) up  
					 UNPIVOT   
					 (Element_Value FOR Element_NAME IN (TransactionAttn_ADDR,
												 TransactionLine1_ADDR,
												 TransactionLine2_ADDR,
												 TransactionCity_ADDR,
												 TransactionState_ADDR,
												 TransactionZip_ADDR,
												 TransactionCountry_ADDR,        
												 Source_CODE,
												 ADDR_BEG_DT,
												 Verified_addr_INDC,
												 verified_addr_yes_indc,
												 verified_addr_no_indc,
												 Addr_verified_DATE,
												 MailingAddress_CODE,
												 ResidencialAddress_CODE,
												 lkcAddress_CODE
												))  
					 AS pvt);
						 
	  SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1'; 
	  SET @Ls_Sqldata_TEXT = '  ';	
	
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;  
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
   BEGIN
      SET @As_DescriptionError_TEXT =
       SUBSTRING (ERROR_MESSAGE (), 1, 200);
   END
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                @As_ErrorMessage_TEXT = @As_DescriptionError_TEXT,
                @As_Sql_TEXT = @Ls_Sql_TEXT,
                @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                @An_Error_NUMB = @Li_Error_NUMB,
                @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT ;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
