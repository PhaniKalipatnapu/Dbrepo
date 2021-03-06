/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ADDRESS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ADDRESS]
	 @An_MemberMci_IDNO        NUMERIC(10),
	 @Ac_TypeAddress_CODE      CHAR(1),
	 @Ad_Run_DATE              DATE,
	 @Ac_Msg_CODE              CHAR(5) OUTPUT,
	 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 
	BEGIN
	SET NOCOUNT ON;
	    DECLARE  @Lc_VerificationStatusGood_CODE     CHAR(1) = 'Y',
           @Lc_VerificationStatusPending_CODE  CHAR(1) = 'P',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_TypeP1_ADDR                     CHAR(1) = 'P',
           @Lc_TypeS1_ADDR                     CHAR(1) = 'S',
           @Lc_TypeM1_ADDR                     CHAR(1) = 'M',
           @Lc_TypeE1_ADDR                     CHAR(1) = 'E',
           @Lc_Space_TEXT					   CHAR(1) = ' ',
           @Ld_High_DATE                       DATE = '12/31/9999';
  DECLARE  @Li_Error_NUMB   		 INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB        INT =  ERROR_LINE (),
           @Ls_Routine_TEXT          VARCHAR(100),
           @Ls_Sql_TEXT              VARCHAR(200),
           @Ls_ErrorMesg_TEXT        VARCHAR(400),
           @Ls_Sqldata_TEXT          VARCHAR(400),
           @Ls_Err_Description_TEXT  VARCHAR(4000);

	BEGIN TRY
		SET @Ac_Msg_CODE = NULL;
		SET @As_DescriptionError_TEXT = NULL;
		SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ADDRESS ';
	   
		

		IF @Ac_TypeAddress_CODE IN ('M', 'R', 'C', 'T') 
			BEGIN
				 SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1';
				 SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') +', '+' TypeAddress_CODE = ' + ISNULL(@Ac_TypeAddress_CODE, '');
				 
				 INSERT INTO #NoticeElementsData_P1
							 (Element_NAME,
							  Element_VALUE)
				 (SELECT tag_name,
						 tag_value
					FROM (SELECT CONVERT(VARCHAR(100), a.Attn_ADDR) Recipient_Attn_ADDR,
								 CONVERT(VARCHAR(100), a.Line1_ADDR) Recipient_Line1_ADDR,
								 CONVERT(VARCHAR(100), a.Line2_ADDR) Recipient_Line2_ADDR,
								 CONVERT(VARCHAR(100), a.City_ADDR) Recipient_City_ADDR,
								 CONVERT(VARCHAR(100), a.State_ADDR) Recipient_State_ADDR,
								 CONVERT(VARCHAR(100), a.Zip_ADDR) Recipient_Zip_ADDR,
								 CONVERT(VARCHAR(100), a.Country_ADDR) Recipient_country_ADDR,
								 CONVERT(VARCHAR(100), a.LocationSource_CODE) Source_CODE,
								 CONVERT(VARCHAR(100), a.SourceReceived_DATE) Received_DATE
							FROM (SELECT RTRIM(a.Attn_ADDR) + @Lc_Space_TEXT AS Attn_ADDR,
										 RTRIM(a.Line1_ADDR) + @Lc_Space_TEXT AS Line1_ADDR,
										 RTRIM(a.Line2_ADDR) + @Lc_Space_TEXT AS Line2_ADDR,
										 RTRIM(a.City_ADDR) AS City_ADDR,
										 @Lc_Space_TEXT  + RTRIM(a.State_ADDR) + @Lc_Space_TEXT AS State_ADDR,
										 RTRIM(a.Zip_ADDR) AS Zip_ADDR,
										 @Lc_Space_TEXT + RTRIM(a.Country_ADDR) AS Country_ADDR,
										 (SELECT LSRC_Y1.Source_NAME
											FROM LSRC_Y1
										   WHERE LSRC_Y1.SourceLoc_CODE = a.SourceLoc_CODE) LocationSource_CODE,
										 a.SourceReceived_DATE
									FROM AHIS_Y1 a
								   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
									 AND a.TypeAddress_CODE = @Ac_TypeAddress_CODE
									 AND ((a.Status_CODE = @Lc_VerificationStatusGood_CODE)
										   OR (a.Status_CODE = @Lc_VerificationStatusPending_CODE
											   AND NOT EXISTS (SELECT 1 AS expr
																 FROM AHIS_Y1
																WHERE AHIS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
																  AND AHIS_Y1.TypeAddress_CODE = @Ac_TypeAddress_CODE
																  AND AHIS_Y1.Status_CODE = @Lc_VerificationStatusGood_CODE
																  AND @Ad_Run_DATE BETWEEN AHIS_Y1.Begin_DATE AND AHIS_Y1.End_DATE)
											   AND a.TransactionEventSeq_NUMB IN (SELECT MAX(AHIS_Y1.TransactionEventSeq_NUMB) AS expr
																					FROM AHIS_Y1
																				   WHERE AHIS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
																					 AND AHIS_Y1.TypeAddress_CODE = @Ac_TypeAddress_CODE
																					 AND AHIS_Y1.Status_CODE = @Lc_VerificationStatusPending_CODE
																					 AND @Ad_Run_DATE BETWEEN AHIS_Y1.Begin_DATE AND AHIS_Y1.End_DATE
																					)))
									 AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE) a) up UNPIVOT (tag_value FOR tag_name IN ( Recipient_Attn_ADDR, Recipient_Line1_ADDR, Recipient_Line2_ADDR, Recipient_City_ADDR, Recipient_State_ADDR, Recipient_Zip_ADDR, Recipient_country_ADDR, Source_CODE, Received_DATE )) AS pvt);
				
			END
		ELSE IF @Ac_TypeAddress_CODE = @Lc_TypeE1_ADDR
			 BEGIN
				  SET @Ls_Sql_TEXT = 'UPDATE @NoticeElements_P1'; 
				  SET @Ls_Sqldata_TEXT = '  ';
				  INSERT INTO #NoticeElementsData_P1
							  (Element_NAME,
							   Element_VALUE)
				  (SELECT tag_name,
						  tag_value
					 FROM (SELECT CONVERT(VARCHAR(100), Attn_ADDR) Recipient_Attn_ADDR,
								  CONVERT(VARCHAR(100), Line1_ADDR) Recipient_Line1_ADDR,
								  CONVERT(VARCHAR(100), Line2_ADDR) Recipient_Line2_ADDR,
								  CONVERT(VARCHAR(100), City_ADDR) Recipient_City_ADDR,
								  CONVERT(VARCHAR(100), State_ADDR) Recipient_State_ADDR,
								  CONVERT(VARCHAR(100), Zip_ADDR) Recipient_Zip_ADDR,
								  CONVERT(VARCHAR(100), Country_ADDR) Recipient_country_ADDR,
								  CONVERT(VARCHAR(100), LocationSource_CODE) Source_CODE,
								  CONVERT(VARCHAR(100), SourceReceived_DATE) Received_date
							 FROM (SELECT RTRIM(o.Attn_ADDR) + ' ' AS Attn_ADDR,
										  RTRIM(o.Line1_ADDR) + ' ' AS Line1_ADDR,
										  RTRIM(o.Line2_ADDR) + ' ' AS Line2_ADDR,
										  RTRIM(o.City_ADDR) + ' ' AS City_ADDR,
										  ' ' + RTRIM(o.State_ADDR) + ' ' AS State_ADDR,
										  RTRIM(o.Zip_ADDR) AS Zip_ADDR,
										  ' ' + RTRIM(o.Country_ADDR) AS Country_ADDR,
										  (SELECT LSRC_Y1.Source_NAME
											 FROM LSRC_Y1
											WHERE LSRC_Y1.SourceLoc_CODE = e.SourceLoc_CODE) LocationSource_CODE,
										  e.SourceReceived_DATE
									 FROM EHIS_Y1 AS e,
										  OTHP_Y1 AS o
									WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
									  AND o.OtherParty_IDNO = e.OthpPartyEmpl_IDNO
									  AND ((e.Status_CODE = @Lc_VerificationStatusGood_CODE)
											OR (e.Status_CODE = @Lc_VerificationStatusPending_CODE
												AND NOT EXISTS (SELECT 1 AS expr
																  FROM EHIS_Y1
																 WHERE EHIS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
																   AND EHIS_Y1.Status_CODE = @Lc_VerificationStatusGood_CODE
																   AND @Ad_Run_DATE BETWEEN EHIS_Y1.BeginEmployment_DATE AND EHIS_Y1.EndEmployment_DATE)))
									  AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
									  AND o.EndValidity_DATE = @Ld_High_DATE) a) up UNPIVOT (tag_value FOR tag_name IN ( Recipient_Attn_ADDR, Recipient_Line1_ADDR, Recipient_Line2_ADDR, Recipient_City_ADDR, Recipient_State_ADDR, Recipient_Zip_ADDR, Recipient_country_ADDR, Source_CODE, Received_date )) AS pvt)
			    
			END
	   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
   BEGIN
      SET @As_DescriptionError_TEXT =
       SUBSTRING (ERROR_MESSAGE (), 1, 200);
   END
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Routine_TEXT,
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
