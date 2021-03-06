/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_VOL_PYMT_DATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_VOL_PYMT_DATE
Programmer Name	:	IMP Team.
Description		:	Fetches the Last voluntary payment date for ncp from RCTH_Y1
Frequency		:	
Developed On	:	4/19/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_VOL_PYMT_DATE](
	@An_Case_IDNO             NUMERIC(6),
	@An_NcpMemberMci_IDNO     NUMERIC(10),
	@Ac_Msg_CODE			  CHAR(1) OUTPUT,
	@As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
)
AS
BEGIN
	DECLARE @Li_Error_NUMB              NUMERIC(11),
			@Li_ErrorLine_NUMB			NUMERIC(11), 
			@Ld_Low_DATE				DATE = '01/01/0001',
			@Ld_High_DATE				DATE = '12/31/9999',
			@Lc_TypeRecordOriginal_CODE CHAR(1) = 'O',
			@Lc_StatusFailed_CODE		CHAR(1) = 'F',
			@Lc_StatusSuccess_CODE		CHAR(1) = 'S',
			@Lc_BackOutYes_INDC			CHAR(1) = 'Y',
			@Lc_SourceReceiptRE_CODE    CHAR(2) = 'RE',
			@Lc_SourceReceiptEW_CODE    CHAR(2) = 'EW';
	
	DECLARE	@Ls_Procedure_NAME        VARCHAR(100) = '',
			@Ls_Sql_TEXT              VARCHAR(200),
			@Ls_Sqldata_TEXT          VARCHAR(400),
			@Ls_DescriptionError_TEXT VARCHAR(4000);

BEGIN TRY
		SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICES$SP_GET_VOL_PYMT_DATE';
		SET @Ls_Sql_TEXT = 'SELECT LSUP_Y1';
		SET @Ls_Sqldata_TEXT = '@An_NcpMemberMci_IDNO :'+ CAST(@An_NcpMemberMci_IDNO AS VARCHAR(10)) + ', Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6));

	  INSERT INTO #NoticeElementsData_P1(ELEMENT_NAME,ELEMENT_VALUE)
		 (SELECT tag_name, tag_value from  
		   (   
		   SELECT    
			CONVERT(VARCHAR(100),LastRegularPaymentReceived_DATE) LAST_VOLUNTARY_PYMT_DATE
			FROM --13256 - CR0363 Last Payment From DACSES Not Populating on Forms 20140211 - Fix - Start
					(SELECT ISNULL(MAX(c.Distribute_DATE), (SELECT e.ReceiptLast_DATE FROM ENSD_Y1 e  WHERE e.Case_IDNO=@An_Case_IDNO)) AS LastRegularPaymentReceived_DATE
				 --13256 - CR0363 Last Payment From DACSES Not Populating on Forms 20140211 - Fix - End
						FROM RCTH_Y1 AS r,
						  LSUP_Y1 AS c
						WHERE r.PayorMci_IDNO = @An_NcpMemberMci_IDNO
						-- ENF-17 Criminal Non Support field mapping Fix - Start
						  AND r.SourceReceipt_CODE IN ( @Lc_SourceReceiptRE_CODE, @Lc_SourceReceiptEW_CODE )
						-- ENF-17 Criminal Non Support field mapping Fix - End
						  AND r.EndValidity_DATE = @Ld_High_DATE
						  AND NOT EXISTS (SELECT C.Batch_DATE,
												 C.Batch_NUMB,
												 C.SourceBatch_CODE,
												 C.SeqReceipt_NUMB
											FROM RCTH_Y1 c
										   WHERE C.Batch_DATE = r.Batch_DATE
											 AND C.Batch_NUMB = r.Batch_NUMB
											 AND C.SourceBatch_CODE = r.SourceBatch_CODE
											 AND C.SeqReceipt_NUMB = r.SeqReceipt_NUMB
											 AND c.BackOut_INDC = @Lc_BackOutYes_INDC
											 AND c.EndValidity_DATE = @Ld_High_DATE)
						  AND r.Batch_DATE = c.Batch_DATE
						  AND r.SourceBatch_CODE = c.SourceBatch_CODE
						  AND r.Batch_NUMB = c.Batch_NUMB
						  AND r.SeqReceipt_NUMB  = c.SeqReceipt_NUMB
						  AND c.Distribute_DATE != @Ld_Low_DATE
						  AND c.TypeRecord_CODE  = @Lc_TypeRecordOriginal_CODE)a
										) up  
										 UNPIVOT   
										 (tag_value FOR tag_name IN (LAST_VOLUNTARY_PYMT_DATE 
																	))  
										 AS pvt)
						SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
				
	END TRY

BEGIN CATCH

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
					 
END CATCH
END

GO
