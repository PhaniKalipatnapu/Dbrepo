/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_FIN$SP_LAST_PAYMENT_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_FIN$SP_LAST_PAYMENT_DTLS
Programmer Name	:	IMP Team.
Description		:	Fetches the receipt amount of a specific case. It fetches the information at payer level from 
 					   rcth_y1 table then checks for amount_receipt and date_receipt for a specific case from lsup_y1
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_FIN$SP_LAST_PAYMENT_DTLS] (
 @An_Case_IDNO             NUMERIC(6),
 @An_NcpMemberMci_IDNO     NUMERIC(10),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Ln_EventFunctional1820Seq_NUMB NUMERIC(15) = 1820,
  @Li_Error_NUMB              INT = NULL,
          @Li_ErrorLine_NUMB          INT = NULL,
          
          @Li_EventFunctional1810_SEQ INT = 1810,
          @Lc_TypeRecordOriginal_CODE CHAR(1) = 'O',
          @Lc_Yes_TEXT                CHAR(1) = 'Y',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE @Ls_Procedure_NAME        VARCHAR(100) = '',
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Procedure_NAME = 'BATCH_GEN_NOTICE_FIN$SP_LAST_PAYMENT_DTLS';
   SET @Ls_Sql_TEXT = 'SELECT RCTH_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', NcpMci_IDNO = ' + CAST(ISNULL(@An_NcpMemberMci_IDNO, 0) AS VARCHAR(10));
  
     INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT Element_NAME,
           Element_Value
      FROM (SELECT CAST(f.LAST_PAYMENT_DATE AS VARCHAR(100)) LAST_PAYMENT_DATE,
                   CAST(f.LAST_PAYMENT_AMNT AS VARCHAR(100)) LAST_PAYMENT_AMNT
                   --13256 - CR0363 Last Payment From DACSES Not Populating on Forms 20140211 Fix - Start
              FROM (SELECT ISNULL(MAX(l.Receipt_DATE),(SELECT e.ReceiptLast_DATE FROM ENSD_Y1 e WHERE e.Case_IDNO=@An_Case_IDNO)) LAST_PAYMENT_DATE,
				   --13256 - CR0363 Last Payment From DACSES Not Populating on Forms 20140211 Fix - End
                           SUM(l.TransactionNaa_AMNT + l.TransactionTaa_AMNT + l.TransactionCaa_AMNT + l.TransactionPaa_AMNT + l.TransactionUpa_AMNT + l.TransactionUda_AMNT + l.TransactionIvef_AMNT + l.TransactionNffc_AMNT + l.TransactionNonIvd_AMNT + l.TransactionMedi_AMNT) LAST_PAYMENT_AMNT
                      FROM LSUP_Y1 l,
                           (SELECT Batch_DATE,
                                   Batch_NUMB,
                                   SourceBatch_CODE,
                                   SeqReceipt_NUMB
                              FROM (SELECT Batch_DATE,
										   Batch_NUMB,
										   SourceBatch_CODE,
										   SeqReceipt_NUMB,
                                           ROW_NUMBER() OVER(PARTITION BY PayorMCI_IDNO ORDER BY Receipt_DATE DESC, Batch_DATE DESC, SourceBatch_CODE DESC, Batch_NUMB DESC, SeqReceipt_NUMB DESC) rnk
                                      FROM Rcth_Y1 x
                                     WHERE x.PayorMci_IDNO = @An_NcpMemberMci_IDNO
                                       AND x.EndValidity_DATE = @Ld_High_DATE
                                       AND EXISTS (SELECT 1
                                                     FROM LSUP_Y1 b
                                                    WHERE b.Case_IDNO = @An_Case_IDNO
                                                      AND b.Batch_DATE = x.Batch_DATE
                                                      AND b.SourceBatch_CODE = x.SourceBatch_CODE
                                                      AND b.Batch_NUMB = x.Batch_NUMB
                                                      AND b.SeqReceipt_NUMB = x.SeqReceipt_NUMB
                                                      AND b.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                                                      AND b.EventFunctionalSeq_NUMB IN (@Ln_EventFunctional1820Seq_NUMB, @Li_EventFunctional1810_SEQ))
                                       AND NOT EXISTS (SELECT 1
                                                         FROM Rcth_Y1 zz
                                                        WHERE x.Batch_DATE = zz.Batch_DATE
                                                          AND x.Batch_NUMB = zz.Batch_NUMB
                                                          AND x.SourceBatch_CODE = zz.SourceBatch_CODE
                                                          AND x.SeqReceipt_NUMB = zz.SeqReceipt_NUMB
                                                          AND zz.BackOut_INDC = @Lc_Yes_TEXT
                                                          AND zz.EndValidity_DATE = @Ld_High_DATE)) y
                             WHERE rnk = 1) AS rc
                     WHERE l.Batch_DATE = rc.Batch_DATE
                       AND l.Batch_NUMB = rc.Batch_NUMB
                       AND l.SourceBatch_CODE = rc.SourceBatch_CODE
                       AND l.SeqReceipt_NUMB = rc.SeqReceipt_NUMB
                       AND l.Case_IDNO = @An_Case_IDNO
                       AND l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                       AND l.EventFunctionalSeq_NUMB IN (@Ln_EventFunctional1820Seq_NUMB, @Li_EventFunctional1810_SEQ)) f)up UNPIVOT (Element_Value FOR Element_NAME IN ( LAST_PAYMENT_DATE, LAST_PAYMENT_AMNT )) AS pvt);
   	
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
