/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S21] (
 @An_Case_IDNO             NUMERIC(6),
 @An_TotArrears_AMNT       NUMERIC(11, 2) OUTPUT,
 @An_TotAssignedArr_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_TotUnassignedArr_AMNT NUMERIC(11, 2) OUTPUT,
 @Ad_LastPay_DATE          DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : LSUP_RETRIEVE_S21
  *     DESCRIPTION       : Retrieve Total Arrears amount,Assigned Arrears amount ,Unassigned Arrears amount and Last Payment Date for a given Case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  -- 13256 - CR0363 Last Payment From DACSES Not Populating - Start
  DECLARE @Li_ManuallyDistributeReceipt1810_NUMB	INT			= 1810,
          @Li_ReceiptDistributed1820_NUMB			INT			= 1820,
          @Lc_BackOutYes_INDC						CHAR(1)		= 'Y',
          @Lc_TypeRecord_CODE						CHAR(1)		= 'O',
          @Ld_Low_DATE								DATE		= '01/01/0001',
          @Ld_High_DATE								DATE		= '12/31/9999';

  SELECT @An_TotArrears_AMNT = SUM((B.OweTotNaa_AMNT - B.AppTotNaa_AMNT) + (B.OweTotPaa_AMNT - B.AppTotPaa_AMNT) + (B.OweTotTaa_AMNT - B.AppTotTaa_AMNT) + (B.OweTotCaa_AMNT - B.AppTotCaa_AMNT) + (B.OweTotUpa_AMNT - B.AppTotUpa_AMNT) + (B.OweTotUda_AMNT - B.AppTotUda_AMNT) + (B.OweTotIvef_AMNT - B.AppTotIvef_AMNT) + (B.OweTotNffc_AMNT - B.AppTotNffc_AMNT) + (B.OweTotNonIvd_AMNT - B.AppTotNonIvd_AMNT) + (B.OweTotMedi_AMNT - B.AppTotMedi_AMNT)),
         @An_TotAssignedArr_AMNT = SUM((B.OweTotPaa_AMNT - B.AppTotPaa_AMNT) + (B.OweTotTaa_AMNT - B.AppTotTaa_AMNT) + (B.OweTotCaa_AMNT - B.AppTotCaa_AMNT)),
         @An_TotUnassignedArr_AMNT = SUM((B.OweTotNaa_AMNT - B.AppTotNaa_AMNT) + (B.OweTotUpa_AMNT - B.AppTotUpa_AMNT) + (B.OweTotUda_AMNT - B.AppTotUda_AMNT)),
         @Ad_LastPay_DATE = ISNULL((SELECT MAX(A.Receipt_DATE)
									   FROM LSUP_Y1 A
									  WHERE A.Case_IDNO = @An_Case_IDNO
										AND A.Batch_DATE <> @Ld_Low_DATE
										AND A.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB , @Li_ReceiptDistributed1820_NUMB)
										AND A.TypeRecord_CODE = @Lc_TypeRecord_CODE
										-- 13835 - CPRO - Last Payment Date on Case Summary Ribbon isn't correct. - START										
										AND A.Receipt_DATE >  MAX(e.ReceiptLast_DATE)
										-- 13835 - CPRO - Last Payment Date on Case Summary Ribbon isn't correct. - END
										AND NOT EXISTS (SELECT 1
														  FROM RCTH_Y1 B
														 WHERE B.Batch_DATE = A.Batch_DATE
														   AND B.SourceBatch_CODE = A.SourceBatch_CODE
														   AND B.Batch_NUMB = A.Batch_NUMB
														   AND B.SeqReceipt_NUMB = A.SeqReceipt_NUMB
														   AND B.EndValidity_DATE = @Ld_High_DATE
														   AND B.BackOut_INDC = @Lc_BackOutYes_INDC)),MAX(e.ReceiptLast_DATE))
    FROM ENSD_Y1 e
    LEFT JOIN LSUP_Y1 B
      ON B.Case_IDNO = @An_Case_IDNO
     AND B.SupportYearMonth_NUMB = (SELECT MAX (C.SupportYearMonth_NUMB)
                                      FROM LSUP_Y1 C
                                     WHERE B.Case_IDNO = C.Case_IDNO
                                       AND B.OrderSeq_NUMB = C.OrderSeq_NUMB
                                       AND B.ObligationSeq_NUMB = C.ObligationSeq_NUMB)
     AND B.EventGlobalSeq_NUMB = (SELECT MAX (D.EventGlobalSeq_NUMB)
                                    FROM LSUP_Y1 D
                                   WHERE B.Case_IDNO = D.Case_IDNO
                                     AND B.OrderSeq_NUMB = D.OrderSeq_NUMB
                                     AND B.ObligationSeq_NUMB = D.ObligationSeq_NUMB)
   WHERE e.Case_IDNO = @An_Case_IDNO;
   -- 13256 - CR0363 Last Payment From DACSES Not Populating - End
 END; --End of LSUP_RETRIEVE_S21

GO
