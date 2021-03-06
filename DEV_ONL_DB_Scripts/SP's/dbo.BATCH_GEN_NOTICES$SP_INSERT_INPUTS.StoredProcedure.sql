/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_INSERT_INPUTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_INSERT_INPUTS
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_GEN_NOTICES$SP_INSERT_INPUTS  Inserts data into Local table for accessability
					  through out the BATCH_GEN_NOTICES Procedures.
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$FORMAT_AND_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_INSERT_INPUTS]
 @Ac_Notice_ID             VARCHAR(8),
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Worker_ID             CHAR(30),
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_OthpSource_IDNO       VARCHAR(10),
 @Ac_Msg_CODE              VARCHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ls_ErrorDesc_TEXT           VARCHAR(4000),
          @Ls_Sql_TEXT                 VARCHAR(1000) = '',
          @Ls_Sqldata_TEXT             VARCHAR(400) = '',
          @Lc_TransOtherState_INDC     CHAR(1),
          @Ln_TransHeader_IDNO         NUMERIC(12),
          @Ln_Request_IDNO             NUMERIC(12),
          @Lc_OthpStateFips_CODE       CHAR(2),
          @Ld_Transaction_DATE         DATE,
          @Ls_DescriptionError_TEXT    VARCHAR(4000),
          @Ls_ErrorMesg_TEXT           VARCHAR(4000),
          @Ls_Error_CODE               VARCHAR(18),
          @Ls_Errorproc_NAME           VARCHAR(75),
          @Ls_InputParam_TEXT          VARCHAR(100),
          @Ls_InputParameterValue_TEXT VARCHAR(300),
          @Lc_TransOtherStateI_INDC    CHAR(1) = 'I',
          @Lc_Space_Text               CHAR(1) = '',
          @Lc_Input_INDC               CHAR,
          @Lc_StatusSuccess_CODE       CHAR,
          @Lc_StatusFailed_CODE        CHAR,
          @Ld_Request_DTTM			   DATE;
          
		 DECLARE @NoticeElementsData_P1 TABLE(
               Element_NAME  VARCHAR(150),
               Element_VALUE VARCHAR(MAX));          

  SET @Lc_Input_INDC = 'I';
  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';
 
  BEGIN TRY

  SET @Ls_ErrorDesc_TEXT = 'Insert into Temp Table @NoticeElementsData_P1';
	INSERT INTO @NoticeElementsData_P1 
	SELECT Element_NAME,Element_VALUE FROM #NoticeElementsData_P1; 
  
	
   IF @Ac_Notice_ID LIKE 'INT-%'
	BEGIN
	   SET @Ln_TransHeader_IDNO = (SELECT Element_VALUE AS Element_VALUE
									 FROM @NoticeElementsData_P1
									WHERE Element_NAME = 'TransHeader_IDNO');
	   SET @Ln_Request_IDNO = (SELECT Element_VALUE AS Element_VALUE
	                                 FROM @NoticeElementsData_P1
	                                WHERE Element_NAME = 'request_idno');

	   IF @Ln_TransHeader_IDNO IS NOT NULL
		   AND @Ln_TransHeader_IDNO <> 0 OR @Ln_Request_IDNO IS NOT NULL 
		   AND @Ln_Request_IDNO <> 0
		BEGIN 
			 IF EXISTS (SELECT 1
						  FROM CTHB_Y1
						 WHERE TransHeader_IDNO = @Ln_TransHeader_IDNO
						   AND IoDirection_CODE = 'I')
				BEGIN
					 INSERT INTO @NoticeElementsData_P1
								 (Element_NAME,
								  Element_VALUE)
					 (SELECT tag_name,
							 tag_value
						FROM (SELECT CONVERT(VARCHAR(100),  CONVERT(varchar, Transaction_DATE, 101)) Transaction_DATE,
									 CONVERT(VARCHAR(100), IVDOutOfStateFips_CODE) OthpStateFips_CODE,
									 CONVERT(VARCHAR(100), IVDOutOfStateFips_CODE + IVDOutOfStateCountyFips_CODE + IVDOutOfStateOfficeFips_CODE) From_Initiate_Id_Fips,
									 CONVERT(VARCHAR(100), IoDirection_CODE) TransOtherState_INDC,
									 CONVERT(VARCHAR(100), Function_CODE) Function_CODE,
									 CONVERT(VARCHAR(100), Action_CODE) Action_CODE,
									 CONVERT(VARCHAR(100), Reason_CODE) Reason_CODE,
									 CONVERT(VARCHAR(100), CONVERT(varchar, ActionResolution_DATE, 101)) Event_DATE
								FROM (SELECT Transaction_DATE,
											 IVDOutOfStateFips_CODE,
											 IVDOutOfStateCountyFips_CODE,
											 IVDOutOfStateOfficeFips_CODE,
											 IoDirection_CODE,
											 Function_CODE,
											 Action_CODE,
											 Reason_CODE,
											 CASE WHEN CAST(CONVERT(VARCHAR(4), ActionResolution_DATE, 112) AS NUMERIC) != 1 THEN  CONVERT(VARCHAR(10), ActionResolution_DATE, 101) ELSE @Lc_Space_Text END AS ActionResolution_DATE
									FROM CTHB_Y1
									   WHERE TransHeader_IDNO = @Ln_TransHeader_IDNO) a) up 
							UNPIVOT (tag_value FOR tag_name IN ( Transaction_DATE, OthpStateFips_CODE, From_Initiate_Id_Fips, TransOtherState_INDC, 
																 Function_CODE, Action_CODE, Reason_CODE,Event_DATE)) AS pvt)
				END
			ELSE IF EXISTS (SELECT 1
							  FROM CSPR_Y1
							 WHERE Request_IDNO = @Ln_Request_IDNO)
				BEGIN
					INSERT INTO @NoticeElementsData_P1
								 (Element_NAME,
								  Element_VALUE)
					 (SELECT tag_name,
							 tag_value
						FROM (SELECT CONVERT(VARCHAR(100),CONVERT(varchar, Transaction_DATE, 101)) Transaction_DATE,
									 CONVERT(VARCHAR(100), IVDOutOfStateFips_CODE) OthpStateFips_CODE,
									 CONVERT(VARCHAR(100), IoDirection_CODE) TransOtherState_INDC,
									 CONVERT(VARCHAR(100), Function_CODE) Function_CODE,
									 CONVERT(VARCHAR(100), Action_CODE) Action_CODE,
									 CONVERT(VARCHAR(100), Reason_CODE) Reason_CODE
								FROM (SELECT Generated_DATE AS Transaction_DATE,
											 IVDOutOfStateFips_CODE,
											 'O' AS IoDirection_CODE,
											 Function_CODE,
											 Action_CODE,
											 Reason_CODE
										FROM CSPR_Y1
									   WHERE Request_IDNO = @Ln_Request_IDNO) a) up 
							UNPIVOT (tag_value FOR tag_name IN ( Transaction_DATE, OthpStateFips_CODE, TransOtherState_INDC, 
																 Function_CODE, Action_CODE, Reason_CODE)) AS pvt)
																 
				END
			ELSE
				BEGIN
					SET @Ac_Msg_CODE = 'F';
					SET @As_DescriptionError_TEXT = CAST(@Ln_TransHeader_IDNO AS VARCHAR) + ' TransHeader_IDNO As InBound in CTHB / Request_IDNO As OutBound in CSPR Not Found';
				END
				
		   SET @Lc_TransOtherState_INDC=(SELECT CONVERT(VARCHAR(5), Element_VALUE) AS Element_VALUE
										   FROM @NoticeElementsData_P1
										  WHERE Element_NAME = 'TransOtherState_INDC');
										  
		   SET @Ld_Transaction_DATE=(SELECT CONVERT(DATE, Element_VALUE) AS Element_VALUE
									   FROM @NoticeElementsData_P1
									  WHERE Element_NAME = 'Transaction_DATE');
									  
		  SET @Ln_TransHeader_IDNO = (SELECT Element_VALUE AS Element_VALUE
										FROM @NoticeElementsData_P1
									   WHERE Element_NAME = 'TransHeader_IDNO');
										
		   SET @Lc_OthpStateFips_CODE=(SELECT CONVERT(CHAR(2), Element_VALUE) AS Element_VALUE
										 FROM @NoticeElementsData_P1
										WHERE Element_NAME = 'OthpStateFips_CODE');										
		  
		END
	   ELSE IF @Ln_TransHeader_IDNO = 0
		BEGIN
			INSERT INTO @NoticeElementsData_P1
				VALUES('TransOtherState_INDC', 'O');
			
			SET @Ld_Request_DTTM =(SELECT CONVERT(VARCHAR(10), Element_VALUE, 101)
										   FROM @NoticeElementsData_P1
										  WHERE Element_NAME = 'Request_DTTM');
			
			INSERT INTO @NoticeElementsData_P1
				VALUES('Transaction_DATE', @Ld_Request_DTTM);
			
			SET @Lc_TransOtherState_INDC = 'O';
		END;
	   
	   
		SET @Ls_ErrorDesc_TEXT = 'TRUNCATE Table #NoticeElementsData_P1';              
	   
	    TRUNCATE TABLE #NoticeElementsData_P1;
                    
      SET @Ls_ErrorDesc_TEXT = 'Insert into Local Table #NoticeElementsData_P1';              
                              
      INSERT INTO #NoticeElementsData_P1
      SELECT Element_NAME,Element_VALUE FROM @NoticeElementsData_P1;
	   
	  
	   IF @Lc_TransOtherState_INDC IN ('I', 'O')
		BEGIN
		   EXECUTE BATCH_GEN_NOTICE_CNET$SP_SELECT_DE_FIPS
						  @An_Case_IDNO             = @An_Case_IDNO,
						  @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
						  @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
		END;

	   
		 EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_DEP_RELATED_MEMBER
		  @An_Case_IDNO             = @An_Case_IDNO,
		  @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
		  @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT

		 IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
		  RETURN;
		
	END
	
   
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE
  END TRY

  BEGIN CATCH
   
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE(), 'SP_INSERT_INPUTS') + ' Procedure' + '. Error Desc - ' + @Ls_ErrorDesc_TEXT + '. Error Execute Location - ' + @ls_sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE (), 'SP_INSERT_INPUTS') + ' Procedure' + '. Error Desc - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error Execute Location - ' + @ls_sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
