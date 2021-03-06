/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_REPOST_TRIP_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_REPOST_TRIP_ADDRESS
Programmer Name		: IMP Team
Description			: Insert Trip Address for the Receipt which is reposted to Same Payor MCI ID Number
Frequency			: 
Developed On		: 01/24/2014
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_REPOST_TRIP_ADDRESS] (
 @Ad_Batch_DATE               DATE,
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Batch_NUMB               NUMERIC(4),
 @An_SeqReceipt_NUMB          NUMERIC(6),
 @Ad_BatchOrig_DATE           DATE,
 @Ac_SourceBatchOrig_CODE     CHAR(3),
 @An_BatchOrig_NUMB           NUMERIC(4),
 @An_SeqReceiptOrig_NUMB      NUMERIC(6),
 @Ac_Msg_CODE                 CHAR(1)		OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
			@Lc_StatusFailed_CODE		CHAR(1)			= 'F',
			@Ls_Procedure_NAME			VARCHAR(50)		= 'BATCH_COMMON$SP_INSERT_REPOST_TRIP_ADDRESS',
			@Ld_High_DATE				DATE			= '12/31/9999';
	DECLARE @Ln_Rowcount_QNTY			NUMERIC(11),
			@Ln_PayorMci_IDNO			NUMERIC(10)		= 0,
			@Ln_Error_NUMB				NUMERIC(11),
			@Ln_ErrorLine_NUMB			NUMERIC(11),
			@Ls_Sql_TEXT				VARCHAR(200)	= '',
			@Ls_Sqldata_TEXT			VARCHAR(2000)	= '',
			@Ls_ErrorMessage_TEXT		VARCHAR(4000)	= '';

	BEGIN TRY

		SET @Ac_Msg_CODE = '';
		SET @As_DescriptionError_TEXT = '';

		SET @Ls_Sql_TEXT = 'SELECT TADR_Y1,RCTH_Y1';
		SET @Ls_Sqldata_TEXT = 'BatchOrig_DATE = ' + CAST(@Ad_BatchOrig_DATE AS VARCHAR )+ ', SourceBatchOrig_CODE = ' + @Ac_SourceBatchOrig_CODE+ ', BatchOrig_NUMB = ' + CAST( @An_BatchOrig_NUMB AS VARCHAR )+ ', SeqReceiptOrig_NUMB = ' + CAST( @An_SeqReceiptOrig_NUMB AS VARCHAR )
									+'Batch_DATE = ' + CAST( @Ad_Batch_DATE AS VARCHAR )+ ', SourceBatch_CODE = ' + @Ac_SourceBatch_CODE+ ', Batch_NUMB = ' + CAST( @An_Batch_NUMB AS VARCHAR )+ ', SeqReceipt_NUMB = ' + CAST( @An_SeqReceipt_NUMB AS VARCHAR );

		SELECT @Ln_PayorMci_IDNO = ISNULL(o.PayorMci_IDNO,0)
		 FROM TADR_Y1 t
		 JOIN RCTH_Y1 o
		   ON o.Batch_DATE = @Ad_BatchOrig_DATE
		  AND o.SourceBatch_CODE = @Ac_SourceBatchOrig_CODE
		  AND o.Batch_NUMB = @An_BatchOrig_NUMB
		  AND o.SeqReceipt_NUMB = @An_SeqReceiptOrig_NUMB
		  AND o.EndValidity_DATE = @Ld_High_DATE
		  AND o.Batch_DATE = t.Batch_DATE
		  AND o.SourceBatch_CODE = t.SourceBatch_CODE
		  AND o.Batch_NUMB = t.Batch_NUMB
		  AND o.SeqReceipt_NUMB = t.SeqReceipt_NUMB
		  AND t.MemberMci_IDNO = o.PayorMci_IDNO
		WHERE EXISTS (SELECT 1
						FROM RCTH_Y1 n
					   WHERE n.Batch_DATE = @Ad_Batch_DATE
						 AND n.SourceBatch_CODE = @Ac_SourceBatch_CODE
						 AND n.Batch_NUMB = @An_Batch_NUMB
						 AND n.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
						 AND n.EndValidity_DATE = @Ld_High_DATE
						 AND n.PayorMci_IDNO = o.PayorMci_IDNO);

		IF @Ln_PayorMci_IDNO != 0
		BEGIN
			SET @Ls_Sql_TEXT = 'INSERT TADR_Y1';

			INSERT TADR_Y1
			SELECT @Ad_Batch_DATE AS Batch_DATE,
				   @Ac_SourceBatch_CODE AS SourceBatch_CODE,
				   @An_Batch_NUMB AS Batch_NUMB,
				   @An_SeqReceipt_NUMB AS SeqReceipt_NUMB,
				   @Ln_PayorMci_IDNO,
				   t.Attn_ADDR,
				   t.Line1_ADDR,
				   t.Line2_ADDR,
				   t.City_ADDR,
				   t.State_ADDR,
				   t.Zip_ADDR,
				   t.Country_ADDR,
				   t.InjuredSpouse_INDC
			  FROM TADR_Y1 t
			 WHERE t.Batch_DATE = @Ad_BatchOrig_DATE
			   AND t.SourceBatch_CODE = @Ac_SourceBatchOrig_CODE
			   AND t.Batch_NUMB = @An_BatchOrig_NUMB
			   AND t.SeqReceipt_NUMB = @An_SeqReceiptOrig_NUMB;
				    
		   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

		   IF @Ln_RowCount_QNTY = 0
			BEGIN
			 SET @Ls_ErrorMessage_TEXT = 'INSERT INTO TADR_Y1 FAILED';
			 RAISERROR(50001,16,1);
			END
		END

		SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
	END TRY

	BEGIN CATCH
		SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
		SET @Ln_Error_NUMB = ERROR_NUMBER();
		SET @Ln_ErrorLine_NUMB = ERROR_LINE();

		IF @Ln_Error_NUMB <> 50001
		BEGIN
		SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
		END

		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
		@As_Sql_TEXT              = @Ls_Sql_TEXT,
		@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
		@An_Error_NUMB            = @Ln_Error_NUMB,
		@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
		@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
	END CATCH
END


GO
