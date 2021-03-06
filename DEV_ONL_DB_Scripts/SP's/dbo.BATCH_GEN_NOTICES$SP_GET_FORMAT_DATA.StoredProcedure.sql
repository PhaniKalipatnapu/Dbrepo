/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Program Name		: BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA  
Programmer Name		: IMP Team.
Description			: The procedure BATCH_GEN_NOTICES$SP_FORMAT_DATA gets the data that needs to be formatted and formats accordingly.
Frequency			: 
Developed On		: 
Called BY			: BATCH_GEN_NOTICES$SP_GET_DATA_FOR_FORMATTING
Called On       	: 
-------------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0		
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA]
 @As_Element_NAME          VARCHAR(100),
 @As_Element_VALUE         VARCHAR(300),
 @Ac_Format_CODE           CHAR(15),
 @Ac_Mask_INDC             CHAR(1),
 @As_FormattedResult_TEXT  VARCHAR(300) OUTPUT,
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ls_ErrorDesc_TEXT        VARCHAR(4000),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ld_High_DATE             DATE ='12/31/9999',
          @Ld_Low_DATE              DATE = '01/01/0001',
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ls_ErrorMesg_TEXT        VARCHAR(4000),
          @Lc_Error_CODE            CHAR(4),
          @Ls_Errorproc_NAME        VARCHAR(75),
          @Ls_Format_CODE_ssn4      VARCHAR(10),
		  @Ls_Format_CODE_ssn       VARCHAR(10),
          @Ls_Format_CODE_PHONE     VARCHAR(50),
          @Ls_Format_CODE_FAX       VARCHAR(50),
          @Ls_Format_CODE_FAX7       VARCHAR(50),
          @Ls_Format_CODE_MMDDYYYY  VARCHAR(50),
          @Ls_Format_CODE_TIME      VARCHAR(8),
          @Ls_Format_CODE_test      VARCHAR(10),
          @Lc_StatusFailed_CODE     CHAR(1),
          @Lc_StatusSuccess_CODE    CHAR(1),
          @Lc_Mask_INDC_Y           CHAR(1);

  SET @Ls_Format_CODE_ssn4 = 'SSN4';
  SET @Ls_Format_CODE_ssn = 'SSN';
  SET @Ls_Format_CODE_MMDDYYYY = 'MMDDYYYY'
  SET @Ls_Format_CODE_PHONE = 'PHONE'
  SET @Ls_Format_CODE_FAX = 'FAX'
  SET @Ls_Format_CODE_FAX7 = 'FAX7'
  SET @Ls_Format_CODE_TIME  = 'TIME'
  SET @Lc_StatusFailed_CODE = 'F';
  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_Mask_INDC_Y = 'Y'

  BEGIN TRY

   SET @As_Element_VALUE = LTRIM(RTRIM(@As_Element_VALUE));
   SET @As_FormattedResult_TEXT = '';
	
   IF @Ac_Format_CODE = @Ls_Format_CODE_ssn4 OR @Ac_Format_CODE = @Ls_Format_CODE_ssn
   BEGIN
		
		IF LEN(@As_Element_VALUE) < 9 AND (ISNUMERIC(@As_Element_VALUE)= 1 AND @As_Element_VALUE != 0)
		 BEGIN
		  SET @As_Element_VALUE = STUFF(@As_Element_VALUE, 1, 0, REPLICATE('0', 9 - LEN(@As_Element_VALUE)));
		 END
		 
		IF LEN(@As_Element_VALUE) = 9
		 BEGIN
		  IF @Ac_Format_CODE = @Ls_Format_CODE_ssn4
		   BEGIN
		    SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 1, 3) + '-' + SUBSTRING(@As_Element_VALUE, 4, 2) + '-' + SUBSTRING (@As_Element_VALUE, 6, 4)
		    SET @As_FormattedResult_TEXT = dbo.BATCH_COMMON$SF_GETMASKSSN(@As_FormattedResult_TEXT);
		   END
		  ELSE IF @Ac_Format_CODE = @Ls_Format_CODE_ssn AND LEN(@As_Element_VALUE) = 9
		   BEGIN
		    SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 1, 3) + '-' + SUBSTRING(@As_Element_VALUE, 4, 2) + '-' + SUBSTRING (@As_Element_VALUE, 6, 4)
		   END
		 END
		ELSE IF LEN(@As_Element_VALUE) = 0 OR (ISNUMERIC(@As_Element_VALUE)= 1  AND @As_Element_VALUE = 0)
		 BEGIN
		  SET @As_FormattedResult_TEXT = '';
		 END
    END
   ELSE IF @Ac_Format_CODE = @Ls_Format_CODE_PHONE
 BEGIN
     IF (@As_Element_VALUE IS NOT NULL
           AND @As_Element_VALUE != ''
           AND LEN(@As_Element_VALUE) != 0
        )
      BEGIN
       IF CAST(@As_Element_VALUE AS NUMERIC) != 0
        BEGIN
         IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 10
          BEGIN
           SET @As_FormattedResult_TEXT = '('+SUBSTRING(@As_Element_VALUE, 1, 3) + ')' + SUBSTRING(@As_Element_VALUE, 4, 3) + '-' + SUBSTRING (@As_Element_VALUE, 7, 4);
          END
         ELSE IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 7
          BEGIN
           SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 1, 3) + '-' + SUBSTRING(@As_Element_VALUE, 4, 4);
          END
         ELSE
          BEGIN
           IF @As_Element_NAME LIKE '%cnty_%phone_numb'
		    BEGIN
		     SET @As_Element_VALUE = STUFF(@As_Element_VALUE, 1, 0, REPLICATE('0', 7 - LEN(@As_Element_VALUE)));
		     SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 1, 3) + '-' + SUBSTRING(@As_Element_VALUE, 4, 4);
		    END
	       ELSE
		    BEGIN
		     SET @As_Element_VALUE = STUFF(@As_Element_VALUE, 1, 0, REPLICATE('0', 10 - LEN(@As_Element_VALUE)));
		     SET @As_FormattedResult_TEXT = '('+SUBSTRING(@As_Element_VALUE, 1, 3) + ')' + SUBSTRING(@As_Element_VALUE, 4, 3) + '-' + SUBSTRING (@As_Element_VALUE, 7, 4);
		    END
          END
        END
        END
        END
       
    ELSE IF @Ac_Format_CODE = @Ls_Format_CODE_FAX7
	BEGIN
      IF (@As_Element_VALUE IS NOT NULL
           AND @As_Element_VALUE != ''
           AND LEN(@As_Element_VALUE) != 0
        )
     BEGIN
         IF CAST(@As_Element_VALUE AS NUMERIC) != 0
        BEGIN
         IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 10
          BEGIN
           SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 4, 3) + '-' + SUBSTRING (@As_Element_VALUE, 7, 4);
          END
         ELSE IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 7
          BEGIN
           SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 1, 3) + '-' + SUBSTRING(@As_Element_VALUE, 4, 4);
          END
       ELSE IF CAST(@As_Element_VALUE AS NUMERIC) = 0
	    BEGIN
		 SET @As_FormattedResult_TEXT = '';
	    END
     END
      END
      END
   ELSE IF @Ac_Format_CODE = @Ls_Format_CODE_FAX
    BEGIN
     IF (@As_Element_VALUE IS NOT NULL
           AND @As_Element_VALUE != ''
           AND LEN(@As_Element_VALUE) != 0
        )
      BEGIN
       IF CAST(@As_Element_VALUE AS NUMERIC) != 0
        BEGIN
         IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 10
          BEGIN
           SET @As_FormattedResult_TEXT = '('+SUBSTRING(@As_Element_VALUE, 1, 3) + ')' + SUBSTRING(@As_Element_VALUE, 4, 3) + '-' + SUBSTRING (@As_Element_VALUE, 7, 4);
          END
         ELSE IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 7
          BEGIN
           SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 1, 3) + '-' + SUBSTRING(@As_Element_VALUE, 4, 4);
          END
     ELSE
	  BEGIN
	   SET @As_FormattedResult_TEXT = '';
	  END
	END
	END
	END
   ELSE IF @Ac_Format_CODE = @Ls_Format_CODE_MMDDYYYY
    BEGIN
	 IF (		@As_Element_VALUE IS NOT NULL
			AND @As_Element_VALUE != ''
			AND CAST(@As_Element_VALUE AS DATE) NOT IN (@Ld_High_DATE, @Ld_Low_DATE )
		)
	  BEGIN
		SET @As_FormattedResult_TEXT = CONVERT(VARCHAR(10),CAST(@As_Element_VALUE AS DATE),101);
	  END
	 ELSE
	  BEGIN
	   SET @As_FormattedResult_TEXT = '';
	  END
	END
   ELSE IF @Ac_Format_CODE = @Ls_Format_CODE_TIME
	BEGIN
	  IF (		@As_Element_VALUE IS NOT NULL
			AND @As_Element_VALUE != ''
		 )
	   BEGIN
		 SET @As_FormattedResult_TEXT = SUBSTRING(CONVERT(VARCHAR, CAST(@As_Element_VALUE AS DATETIME2), 131), 12, 5) 
									  + ' ' 
									  + SUBSTRING(CONVERT(VARCHAR, CAST(@As_Element_VALUE AS DATETIME2), 131), 28, 2);
	   END
	  ELSE
	   BEGIN
	    SET @As_FormattedResult_TEXT = '';
	   END
	 END
	 --13723 - CREC - Recoupment balances are displaying as doubled - Fix - Start
   ELSE IF @Ac_Format_CODE = 'AMT' -- Format: := '999999999.99'
    BEGIN
     IF @As_Element_VALUE = '' OR CAST(@As_Element_VALUE AS NUMERIC(11,2)) = 0
	  BEGIN
	   SET @As_FormattedResult_TEXT = '';
	  END
     ELSE
      BEGIN
       SET @As_FormattedResult_TEXT = CONVERT(VARCHAR,CAST((@As_Element_VALUE) AS MONEY), 0); 
      END
    END
   ELSE IF @Ac_Format_CODE = 'AMT_COMMA' --Format: '999,999,999.99';
    BEGIN
     IF @As_Element_VALUE = '' OR CAST(@As_Element_VALUE AS NUMERIC(11,2)) = 0
	  BEGIN
	   SET @As_FormattedResult_TEXT = '';
	  END
     ELSE
      BEGIN
       SET @As_FormattedResult_TEXT = CONVERT(VARCHAR,CAST((@As_Element_VALUE) AS MONEY), 1);
      END
      --13723 - CREC - Recoupment balances are displaying as doubled - Fix - End
    END 
    ELSE IF @Ac_Format_CODE = 'AMT_SPACE' 
    BEGIN
     IF @As_Element_VALUE = '' 
	  BEGIN
	   SET @As_FormattedResult_TEXT = '';
	  END
     ELSE
      BEGIN
       SET @As_FormattedResult_TEXT = CONVERT(VARCHAR,CAST((@As_Element_VALUE) AS MONEY), 1);
      END
    END      
   ELSE IF @Ac_Format_CODE = 'HEIGHT'
    BEGIN
     IF (		@As_Element_VALUE IS NOT NULL
			AND @As_Element_VALUE != ''
		 )
	   BEGIN
		SET @As_Element_VALUE = REPLACE(REPLACE(LTRIM(RTRIM(@As_Element_VALUE)), ' ', ''),'-','');
	            
		SET @As_FormattedResult_TEXT = SUBSTRING(LTRIM(RTRIM((@As_Element_VALUE))), 1, 1)
												+ ' feet ' ;
	     
		IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 3
		 BEGIN 
		  SET @As_FormattedResult_TEXT =  @As_FormattedResult_TEXT + SUBSTRING(@As_Element_VALUE, 2, 2)+ + ' inches ';   
		 END
		ELSE IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 2
		 BEGIN 
		  SET @As_FormattedResult_TEXT =  @As_FormattedResult_TEXT + SUBSTRING(@As_Element_VALUE, 2, 1)+ + ' inches ';   
		 END
		ELSE IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 1
		 BEGIN
		  SET @As_FormattedResult_TEXT =  @As_FormattedResult_TEXT + '0'+ + ' inches ';   
		 END
	   END
	  ELSE
	   BEGIN
	    SET @As_FormattedResult_TEXT = '';
	   END
    END
   ELSE IF @Ac_Format_CODE = 'WEIGHT'
    BEGIN
	 IF (		@As_Element_VALUE IS NOT NULL
			AND @As_Element_VALUE != ''
		 )
	   BEGIN
        SET @As_Element_VALUE = REPLACE(REPLACE(LTRIM(RTRIM((@As_Element_VALUE))),' ',''),'-','');
                
        SET @As_FormattedResult_TEXT = @As_Element_VALUE + ' lbs ';
       END  
     ELSE
      BEGIN
       SET @As_FormattedResult_TEXT = '';
      END
    END
   ELSE IF @Ac_Format_CODE = 'ZIP'
	BEGIN
	 IF (		@As_Element_VALUE IS NOT NULL
			AND @As_Element_VALUE != ''
		 )
      BEGIN
	   IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 9
		BEGIN
		 SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 1, 5) + '-' + SUBSTRING (@As_Element_VALUE, 6, 4);
		END
	   ELSE
		BEGIN
		 SET @As_FormattedResult_TEXT = @As_Element_VALUE;
		END
	  END
	 ELSE
	  BEGIN
	   SET @As_FormattedResult_TEXT = '';
	  END
	END
   ELSE IF @Ac_Format_CODE = 'EIN'
    BEGIN
	 IF (		@As_Element_VALUE IS NOT NULL
			AND @As_Element_VALUE != ''
		)
      BEGIN
	   IF LEN(LTRIM(RTRIM(@As_Element_VALUE))) = 9
		BEGIN
		 SET @As_FormattedResult_TEXT = SUBSTRING(@As_Element_VALUE, 1, 2) + '-' + SUBSTRING (@As_Element_VALUE, 3, 7);
		END
	   ELSE
		BEGIN
		 SET @As_FormattedResult_TEXT = @As_Element_VALUE;
		END
	  END
	 ELSE
	  BEGIN
	   SET @As_FormattedResult_TEXT = '';
	  END
	END
   ELSE
    BEGIN
     SET @As_FormattedResult_TEXT = @As_Element_VALUE;
    END
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ls_Sql_TEXT = 'GET FORMATTED DATA '

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE(), 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA') + ' PROCEDURE' + '. Error DESC - ' + @Ls_ErrorDesc_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE (), 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA') + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END

GO
