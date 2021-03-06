/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_CLAIM_NUMBER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CM$SP_GET_CLAIM_NUMBER
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CM$SP_GET_CLAIM_NUMBER] 
		@An_MajorIntSeq_NUMB                   NUMERIC(5),
		@An_Case_IDNO                          NUMERIC(6),
		@Ac_Msg_CODE						   CHAR(5) OUTPUT,
		@As_DescriptionError_TEXT			   VARCHAR(MAX) OUTPUT
 
AS
 BEGIN
  DECLARE @Ld_Highdate_DATE           DATETIME2(0) = '12/31/9999',
          @Lc_StatusSuccess_CODE      CHAR = 'S',
          @Lc_StatusFailed_CODE       CHAR = 'F',
          @Ls_DoubleSpace_TEXT        VARCHAR(2) = '  ',
          @Ls_Routine_TEXT            VARCHAR(400) = 'BATCH_GEN_NOTICE_CM$SP_GET_CLAIM_NUMBER',
          @Ls_Sql_TEXT                VARCHAR(400) = NULL,
          @Ls_Sqldata_TEXT            VARCHAR(4000) = NULL,
          @Ls_Err_Description_TEXT    VARCHAR(4000) = '',
          @Ln_ExpectToPay_AMNT		  NUMERIC(11,2)=0,	
		  @Ln_Periodic_AMNT			  NUMERIC(11,2)=0,		
		  @Ln_ExpectToPay1_AMNT       NUMERIC(11,2)=0,	
		  @Ln_Periodic1_AMNT	      NUMERIC(11,2)=0,	
		  @Ln_RecentOblicationBegin_DATE DATE,
		  @Ln_InitialOblicationBegin_DATE DATE,
		  @Ld_Run_DATE					  DATE;

     
   BEGIN TRY

   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Routine_TEXT = ' BATCH_GEN_NOTICE_CM$SP_GET_CLAIM_NUMBER';
   SET @Ls_Sql_TEXT = ' SELECT dmjr_y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO ' + CAST(ISNULL(@An_Case_IDNO, 0) AS CHAR) ;
	 
		 INSERT INTO #NoticeElementsData_P1
				   (Element_NAME,
					Element_VALUE)
		   (SELECT tag_name,tag_value
			  FROM 
			  (SELECT CONVERT(VARCHAR(100), Claim_Number) Claim_Number
				FROM(
						  SELECT Reference_ID AS Claim_Number
							FROM dmjr_y1
						   WHERE MajorIntSeq_NUMB	= @An_MajorIntSeq_NUMB
							 AND Case_IDNO			= @An_Case_IDNO
					)a) up 
				UNPIVOT (tag_value FOR tag_name IN ( 
													Claim_Number 
													)) AS pvt);
	          
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error in ' + ERROR_PROCEDURE () + ' Procedure' + '. Error Desc - ' + @As_DescriptionError_TEXT + '. Error Execute Location - ' + @Ls_Sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error in ' + ERROR_PROCEDURE () + ' Procedure' + '. Error Desc - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
