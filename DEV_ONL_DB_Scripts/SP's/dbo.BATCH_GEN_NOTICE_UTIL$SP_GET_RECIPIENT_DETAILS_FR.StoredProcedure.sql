/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name    :BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FR
 Programmer Name   : IMP Team
 Description       :The procedure BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FR gets the Member Recipient Details
 Frequency         :
 Developed On      :03/25/2011
 Called By         :BATCH_GEN_NOTICE_UTIL$EXEC_RECP_DETAILS_PROC
 Called On         :
---------------------------------------------------------
 Modified By       :
 Modified On       :
 Version No        :1.0
---------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FR]
 @An_Case_IDNO				NUMERIC(6),
 @Ac_Recipient_CODE			CHAR(2),
 @Ac_Receipt_ID				CHAR(27) = NULL,
 @Ac_PrintMethod_CODE		CHAR,
 @Ac_TypeService_CODE		CHAR,
 @Ac_Msg_CODE				CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
AS
 BEGIN
 SET NOCOUNT ON;
 DECLARE @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FR',
         @Ld_High_DATE      DATE = '12/31/9999';
 DECLARE @Lc_CaseRelationship_CP_CODE     CHAR,
         @Lc_CaseRelationship_NCP_CODE    CHAR,
         @Lc_CaseRelationship_PF_CODE     CHAR,
         @Lc_CaseMemberStatus_Active_CODE CHAR,
         @Lc_StatusApproval_CODE          CHAR,
         @Lc_StatusCase_Open_CODE         CHAR,
         @Lc_StatusSuccess_CODE           CHAR,
         @Lc_StatusFailed_CODE            CHAR,
         @Lc_CheckRecipient_ID			  VARCHAR(10),
         @Lc_CheckRecipient_CODE		  CHAR(1),
         @Ls_Sql_TEXT                     VARCHAR(100) = '',
         @Ls_Sqldata_TEXT                 VARCHAR(1000) = '',
         @Ls_DescriptionError_TEXT        VARCHAR(4000),
         @Get_Recipient_CUR				  CURSOR;

 SET @Lc_CaseRelationship_CP_CODE = 'C';
 SET @Lc_CaseRelationship_NCP_CODE = 'A';
 SET @Lc_CaseRelationship_PF_CODE= 'P';
 SET @Lc_CaseMemberStatus_Active_CODE = 'A';
 SET @Lc_StatusApproval_CODE = 'I';
 SET @Lc_StatusCase_Open_CODE = 'O';
 SET @Lc_StatusFailed_CODE = 'F';
 SET @Lc_StatusSuccess_CODE = 'S';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_DETAILS_FR';
   SET @Ls_Sqldata_TEXT = ' Recipient_CODE = ' + @Ac_Recipient_CODE 
						+ ', Receipt_ID = ' +  @Ac_Receipt_ID
						+ ', printMethod = ' + @Ac_PrintMethod_CODE + ', TypeService = ' + @Ac_TypeService_CODE;

   
   SET @Get_Recipient_CUR = CURSOR FOR
    SELECT DISTINCT checkRecipient_ID, CheckRecipient_CODE
	  FROM DSBL_Y1 l
	 WHERE (Case_IDNO = @An_Case_IDNO OR Case_IDNO = 0)
	   AND @Ac_Receipt_ID =	   CONVERT(VARCHAR(10), Batch_DATE, 101) 
							 + '-' + SourceBatch_CODE + '-' 
							 + CASE
								   WHEN LEN(CAST(Batch_NUMB AS VARCHAR(4))) < 4
									THEN STUFF(CAST(Batch_NUMB AS VARCHAR(4)), 1, 0, REPLICATE('0', 4 - LEN(CAST(Batch_NUMB AS VARCHAR(4)))))
								   ELSE CAST(Batch_NUMB AS VARCHAR(4))
								END + '-' 
							 + SUBSTRING(CASE
										   WHEN LEN(CAST(SeqReceipt_NUMB AS VARCHAR(6))) < 6
											THEN STUFF(CAST(SeqReceipt_NUMB AS VARCHAR(6)), 1, 0, REPLICATE('0', 6 - LEN(CAST(SeqReceipt_NUMB AS VARCHAR(6)))))
										   ELSE CAST(SeqReceipt_NUMB AS VARCHAR(6))
										 END, 1, 3) + '-' 
							 + SUBSTRING(CASE
										   WHEN LEN(CAST(SeqReceipt_NUMB AS VARCHAR(6))) < 6
											THEN STUFF(CAST(SeqReceipt_NUMB AS VARCHAR(6)), 1, 0, REPLICATE('0', 6 - LEN(CAST(SeqReceipt_NUMB AS VARCHAR(6)))))
										   ELSE CAST(SeqReceipt_NUMB AS VARCHAR(6))
										 END, 4, 3) 
	   AND EXISTS (SELECT 1
					 FROM DSBH_Y1 i
					WHERE i.CheckRecipient_ID = l.CheckRecipient_ID
					  AND i.CheckRecipient_CODE = l.CheckRecipient_CODE
					  AND i.MediumDisburse_CODE = 'C'
					  AND i.StatusCheck_CODE IN ('CA', 'OU')
					  AND i.EndValidity_DATE = @Ld_High_DATE);
   
   OPEN @Get_Recipient_CUR

   FETCH NEXT FROM @Get_Recipient_CUR INTO @Lc_CheckRecipient_ID, @Lc_CheckRecipient_CODE;

   WHILE @@FETCH_STATUS = 0
    BEGIN
		
	   IF @Lc_CheckRecipient_CODE = '1' 
		BEGIN
		   INSERT INTO #NoticeRecipients_P1
					   (Recipient_ID,
						Recipient_NAME,
						Recipient_CODE,
						PrintMethod_CODE,
						TypeService_CODE)
		   SELECT CASE
				   WHEN LEN(LTRIM(RTRIM(recipient_id))) < 10
					THEN STUFF(recipient_id, 1, 0, REPLICATE('0', 10 - LEN(recipient_id)))
				   ELSE recipient_id
				  END recipient_id,
				  Recipient_NAME,
				  Recipient_CODE,
				  Print_METHOD,
				  Type_SERVICE
			 FROM (SELECT (SUBSTRING(b.Recipient_NAME, 1, CHARINDEX(';', b.Recipient_NAME) - 1))recipient_id,
						  (SUBSTRING(b.Recipient_NAME, (CHARINDEX(';', b.Recipient_NAME) + 1), LEN(b.Recipient_NAME))) Recipient_NAME,
						  b.Recipient_CODE,
						  @Ac_PrintMethod_CODE AS Print_METHOD,
						  @Ac_TypeService_CODE AS Type_SERVICE
					 FROM(SELECT @Ac_Recipient_CODE + '_' + @Lc_CheckRecipient_CODE Recipient_CODE,
								 (CONVERT(VARCHAR(MAX), d.MemberMci_IDNO) + ';' + LTRIM(RTRIM(d.Last_NAME)) + ' ' + LTRIM(RTRIM(d.Suffix_NAME)) + ' ' + LTRIM(RTRIM(d.First_NAME)) + ' ' + LTRIM(RTRIM(d.Middle_NAME))) Recipient_NAME
							FROM DEMO_Y1 d
						   WHERE MemberMci_IDNO = @Lc_CheckRecipient_ID)b)c;
		END
	   ELSE IF @Lc_CheckRecipient_CODE = '3' 
		BEGIN
		   INSERT INTO #NoticeRecipients_P1
				   (Recipient_ID,
					Recipient_name,
					Recipient_code,
					PrintMethod_CODE,
					TypeService_CODE)
		   SELECT CASE
				   WHEN LEN(LTRIM(RTRIM(recipient_id))) < 9
					THEN STUFF(recipient_id, 1, 0, REPLICATE('0', 9 - LEN(recipient_id)))
				   ELSE recipient_id
				  END recipient_id,
				  Recipient_NAME,
				  Recipient_CODE,
				  Print_METHOD,
				  Type_SERVICE
			 FROM (SELECT (SUBSTRING(b.name_recipient, 1, CHARINDEX(';', b.name_recipient) - 1))recipient_id,
						  (SUBSTRING(b.name_recipient, (CHARINDEX(';', b.name_recipient) + 1), LEN(b.name_recipient))) Recipient_NAME,
						  b.cd_recipient AS Recipient_CODE,
						  @Ac_PrintMethod_CODE AS PRINT_METHOD,
						  @Ac_TypeService_CODE AS TYPE_SERVICE
					 FROM(SELECT @AC_Recipient_CODE + '_' + @Lc_CheckRecipient_CODE cd_recipient,
								 (CONVERT(VARCHAR(MAX), OtherParty_IDNO) + ';' + OtherParty_NAME) Name_recipient
							FROM OTHP_Y1 o
						   WHERE o.OtherParty_IDNO = @Lc_CheckRecipient_ID) b) c;
		END
	   ELSE IF @Lc_CheckRecipient_CODE = '2' 
		BEGIN
		   INSERT INTO #NoticeRecipients_P1
					   (Recipient_ID,
						Recipient_NAME,
						Recipient_CODE,
						PrintMethod_CODE,
						TypeService_CODE)
		   SELECT CASE
				   WHEN LEN(LTRIM(RTRIM(recipient_id))) < 7
					THEN STUFF(recipient_id, 1, 0, REPLICATE('0', 7 - LEN(recipient_id)))
				   ELSE recipient_id
				  END recipient_id,
				  Recipient_NAME,
				  Recipient_CODE,
				  Print_METHOD,
				  Type_SERVICE
			 FROM (SELECT (SUBSTRING(b.Recipient_NAME, 1, CHARINDEX(';', b.Recipient_NAME) - 1))recipient_id,
						  (SUBSTRING(b.Recipient_NAME, (CHARINDEX(';', b.Recipient_NAME) + 1), LEN(b.Recipient_NAME))) Recipient_NAME,
						  b.Recipient_CODE,
						  @Ac_PrintMethod_CODE AS Print_METHOD,
						  @Ac_TypeService_CODE AS Type_SERVICE
					 FROM (SELECT @Ac_Recipient_CODE + '_' + @Lc_CheckRecipient_CODE Recipient_CODE,
								  (  @Lc_CheckRecipient_ID + ';' + (SELECT State_NAME
																	 FROM STAT_Y1 s
																	WHERE s.StateFips_CODE = SUBSTRING(@Lc_CheckRecipient_ID, 1, 2))
								  ) Recipient_NAME)b)C;
		END
   
	 FETCH NEXT FROM @Get_Recipient_CUR INTO @Lc_CheckRecipient_ID, @Lc_CheckRecipient_CODE;
    END

   CLOSE @Get_Recipient_CUR;

   DEALLOCATE @Get_Recipient_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Ln_Error_NUMB NUMERIC (11), @Ln_ErrorLine_NUMB NUMERIC (11);

         SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
                @Ln_Error_NUMB = ERROR_NUMBER (),
                @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF ERROR_NUMBER () <> 50001
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB       = @Ln_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Ln_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;
         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
