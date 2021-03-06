/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S101]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S101](  
     @Ad_Batch_DATE		         DATE  ,
     @Ac_SourceBatch_CODE		 CHAR(3) ,
     @An_Batch_NUMB              NUMERIC(4) ,
     @An_SeqReceipt_NUMB		 NUMERIC(6) ,
     @An_EventGlobalSeq_NUMB	 NUMERIC(19)
   ) 
            
AS
/*
 *     PROCEDURE NAME    : LSUP_RETRIEVE_S101
 *     DESCRIPTION       : This Procedure is used to populate data for 'Reverse And Repost' pop up. This
						   Pop up will show reversals and all associated events which occur as a result of
						   the reversal transaction, as a single event identified as 'Reverse and Repost'.
						   Balance will display the actual balance because of reversing all the receipts as
                           part of this bulk reversal.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      DECLARE
         @Li_ManuallyDistributeReceipt1810_NUMB INT = 1810,
         @Li_ReceiptDistributed1820_NUMB        INT = 1820,
         @Li_One_NUMB							INT		= 1,
         @Li_Two_NUMB							INT	    = 2,
         @Li_Three_NUMB							INT	    = 3,
         @Li_Four_NUMB							INT		= 4,
         @Li_Five_NUMB							INT		= 5,
         @Li_Six_NUMB							INT		= 6,
         @Li_Seven_NUMB							INT		= 7,
         @Li_Eight_NUMB							INT		= 8,
         @Li_Nine_NUMB							INT		= 9,
         @Li_Ten_NUMB							INT		= 10,
         @Li_Eleven_NUMB						INT		= 11,
         @Li_Twelve_NUMB						INT		= 12,
         @Li_Thirteen_NUMB						INT		= 13,
         @Li_Zero_NUMB                          SMALLINT=  0,
         @Lc_No_INDC							CHAR(1) = 'N', 
         @Lc_Yes_INDC							CHAR(1) = 'Y', 
         @Lc_Null_TEXT							CHAR(1) = '', 
         @Lc_Space_TEXT							CHAR(1) = ' ', 
         @Lc_StatusReceiptHeld_CODE				CHAR(1) = 'H', 
         @Lc_StatusReceiptIdentified_CODE		CHAR(1) = 'I', 
         @Lc_StatusReceiptRefunded_CODE			CHAR(1) = 'R', 
         @Lc_StatusReceiptUnidentified_CODE		CHAR(1) = 'U', 
         @Lc_WelfareTypeFosterCare_CODE			CHAR(1) = 'J', 
         @Lc_WelfareTypeMedicaid_CODE			CHAR(1) = 'M', 
         @Lc_WelfareTypeNonIvd_CODE				CHAR(1) = 'H', 
         @Lc_WelfareTypeNonIve_CODE				CHAR(1) = 'F', 
         @Lc_WelfareTypeTanf_CODE				CHAR(1) = 'A', 
         @Lc_TypeRecordOriginal_CODE			CHAR(1) = 'O',
         @Lc_CurrentSupport_CODE				CHAR(2) = 'CS',  
         @Lc_Ca_CODE							CHAR(2) = 'CA', 
         @Lc_Na_CODE							CHAR(2) = 'NA', 
         @Lc_Pa_CODE							CHAR(2) = 'PA', 
         @Lc_Ta_CODE							CHAR(2) = 'TA', 
         @Lc_TypeDebit_CODE					    CHAR(2) = 'DS', 
         @Lc_ReceiptSrcDirectPaymentCredit_CODE CHAR(2) = 'CD',
         @Lc_Uda_CODE							CHAR(3) = 'UDA', 
         @Lc_Upa_CODE							CHAR(3) = 'UPA',
         @Lc_Nffc_CODE							CHAR(4) = 'NFFC', 
         @Lc_Held_CODE							CHAR(4) = 'HELD', 
         @Lc_Ivef_CODE							CHAR(4) = 'IVEF', 
         @Lc_Medi_CODE							CHAR(4) = 'MEDI',
         @Lc_Expt_CODE							CHAR(4) = 'EXPT', 
         @Lc_Nivd_CODE							CHAR(4) = 'NIVD', 
         @Lc_Unidentified_CODE					CHAR(20) = 'UNIDENTIFIED', 
         @Lc_Future_CODE						CHAR(20) = 'FUTURE', 
         @Lc_NewReceipt_CODE					CHAR(20) = 'NEW RECEIPT', 
         @Lc_Refunded_CODE						CHAR(20) = 'REFUNDED',
         @Ld_High_DATE							DATE     = '12/31/9999';
     
    WITH Rrep_CTE
    AS (    
     SELECT X.DistributedAs_CODE, 
               X.Case_IDNO  ,
               X.Order_IDNO ,
               X.MemberMci_IDNO , 
               X.TypeDebt_CODE , 
               X.Fips_CODE , 
			   X.TypeWelfare_CODE, 
			   X.Receipt_DATE , 
			   X.PayorMCI_IDNO , 
			   SUM(X.Distribute_AMNT ) AS Distribute_AMNT, 
			   X.BalBeforeDist_AMNT 
      FROM 
         (
            SELECT 
               CASE a.Row_NUMB
                  WHEN 1  THEN @Lc_CurrentSupport_CODE
                  WHEN 2  THEN @Lc_Expt_CODE
                  WHEN 3  THEN @Lc_Na_CODE
                  WHEN 4  THEN @Lc_Ta_CODE
                  WHEN 5  THEN @Lc_Pa_CODE
                  WHEN 6  THEN @Lc_Ca_CODE
                  WHEN 7  THEN @Lc_Upa_CODE
                  WHEN 8  THEN @Lc_Uda_CODE
                  WHEN 9  THEN @Lc_Ivef_CODE
                  WHEN 10 THEN @Lc_Medi_CODE
                  WHEN 11 THEN @Lc_Future_CODE
                  WHEN 12 THEN @Lc_Nffc_CODE
                  WHEN 13 THEN @Lc_Nivd_CODE
               END AS DistributedAs_CODE, 
               X.Case_IDNO  ,
               X.Order_IDNO ,
               X.MemberMci_IDNO , 
               X.TypeDebt_CODE , 
               X.Fips_CODE , 
               X.TypeWelfare_CODE , 
               X.Receipt_DATE, 
               X.MemberMci_IDNO AS PayorMCI_IDNO, 
               CASE A.Row_NUMB
                  WHEN @Li_One_NUMB THEN X.TransactionCurSup_AMNT
                  WHEN @Li_Two_NUMB THEN X.TransactionExptPay_AMNT
                  WHEN @Li_Three_NUMB THEN X.TransactionNaa_AMNT - CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE CASE X.TypeWelfareOriginal_CODE
                        WHEN @Lc_No_INDC             THEN X.TransactionCurSup_AMNT
                        WHEN @Lc_WelfareTypeMedicaid_CODE THEN X.TransactionCurSup_AMNT
                        ELSE @Li_Zero_NUMB
                     END
                  END
                  WHEN @Li_Four_NUMB THEN X.TransactionTaa_AMNT
                  WHEN @Li_Five_NUMB THEN X.TransactionPaa_AMNT - CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE CASE X.TypeWelfareOriginal_CODE
                        WHEN @Lc_WelfareTypeTanf_CODE THEN X.TransactionCurSup_AMNT
                        ELSE @Li_Zero_NUMB
                     END
                  END
                  WHEN @Li_Six_NUMB THEN X.TransactionCaa_AMNT
                  WHEN @Li_Seven_NUMB THEN X.TransactionUpa_AMNT
                  WHEN @Li_Eight_NUMB THEN X.TransactionUda_AMNT
                  WHEN @Li_Nine_NUMB THEN X.TransactionIvef_AMNT - CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE CASE X.TypeWelfareOriginal_CODE
                        WHEN @Lc_WelfareTypeNonIve_CODE THEN X.TransactionCurSup_AMNT
                        ELSE @Li_Zero_NUMB
                     END
                  END
                  WHEN @Li_Ten_NUMB THEN X.TransactionMedi_AMNT - CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN X.TransactionCurSup_AMNT
                     ELSE @Li_Zero_NUMB
                  END
                  WHEN @Li_Eleven_NUMB THEN X.TransactionFuture_AMNT
                  WHEN @Li_Twelve_NUMB THEN X.TransactionNffc_AMNT - CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE CASE X.TypeWelfareOriginal_CODE
                        WHEN @Lc_WelfareTypeFosterCare_CODE THEN X.TransactionCurSup_AMNT
                        ELSE @Li_Zero_NUMB
                     END
                  END
                  WHEN @Li_Thirteen_NUMB THEN X.TransactionNonIvd_AMNT - CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE CASE X.TypeWelfareOriginal_CODE
                        WHEN @Lc_WelfareTypeNonIvd_CODE THEN X.TransactionCurSup_AMNT
                        ELSE @Li_Zero_NUMB
                     END
                  END
               END AS Distribute_AMNT, 
               CASE a.Row_NUMB
                  WHEN @Li_One_NUMB THEN (X.OweTotCurSup_AMNT - (X.AppTotCurSup_AMNT - X.TransactionCurSup_AMNT))
                  WHEN @Li_Two_NUMB THEN (X.OweTotExptPay_AMNT - (X.AppTotExptPay_AMNT - X.TransactionExptPay_AMNT))
                  WHEN @Li_Three_NUMB THEN (X.OweTotNaa_AMNT - (X.AppTotNaa_AMNT - X.TransactionNaa_AMNT))
                  WHEN @Li_Four_NUMB THEN (X.OweTotTaa_AMNT - (X.AppTotTaa_AMNT - X.TransactionTaa_AMNT))
                  WHEN @Li_Five_NUMB THEN (X.OweTotPaa_AMNT - (X.AppTotPaa_AMNT - X.TransactionPaa_AMNT))
                  WHEN @Li_Six_NUMB THEN (X.OweTotCaa_AMNT - (X.AppTotCaa_AMNT - X.TransactionCaa_AMNT))
                  WHEN @Li_Seven_NUMB THEN (X.OweTotUpa_AMNT - (X.AppTotUpa_AMNT - X.TransactionUpa_AMNT))
                  WHEN @Li_Eight_NUMB THEN (X.OweTotUda_AMNT - (X.AppTotUda_AMNT - X.TransactionUda_AMNT))
                  WHEN @Li_Nine_NUMB THEN (X.OweTotIvef_AMNT - (X.AppTotIvef_AMNT - X.TransactionIvef_AMNT))
                  WHEN @Li_Ten_NUMB THEN (X.OweTotMedi_AMNT - (X.AppTotMedi_AMNT - X.TransactionMedi_AMNT))
                  WHEN @Li_Eleven_NUMB THEN @Li_Zero_NUMB
                  WHEN @Li_Twelve_NUMB THEN (X.OweTotNffc_AMNT - (X.AppTotNffc_AMNT - X.TransactionNffc_AMNT))
                  WHEN @Li_Thirteen_NUMB THEN (X.OweTotNonIvd_AMNT - (X.AppTotNonIvd_AMNT - X.TransactionNonIvd_AMNT))
               END AS BalBeforeDist_AMNT, 
               a.Row_NUMB
            FROM 
               (SELECT 
                     l.Case_IDNO, 
                     l.OrderSeq_NUMB, 
                     l.ObligationSeq_NUMB, 
                     l.SupportYearMonth_NUMB, 
                     l.TypeWelfare_CODE, 
                     l.TransactionCurSup_AMNT, 
                     l.OweTotCurSup_AMNT, 
                     l.AppTotCurSup_AMNT, 
                     l.TransactionExptPay_AMNT, 
                     l.OweTotExptPay_AMNT, 
                     l.AppTotExptPay_AMNT, 
                     l.TransactionNaa_AMNT, 
                     l.OweTotNaa_AMNT, 
                     l.AppTotNaa_AMNT, 
                     l.TransactionPaa_AMNT, 
                     l.OweTotPaa_AMNT, 
                     l.AppTotPaa_AMNT, 
                     l.TransactionTaa_AMNT, 
                     l.OweTotTaa_AMNT, 
                     l.AppTotTaa_AMNT, 
                     l.TransactionCaa_AMNT, 
                     l.OweTotCaa_AMNT, 
                     l.AppTotCaa_AMNT, 
                     l.TransactionUpa_AMNT, 
                     l.OweTotUpa_AMNT, 
                     l.AppTotUpa_AMNT, 
                     l.TransactionUda_AMNT, 
                     l.OweTotUda_AMNT, 
                     l.AppTotUda_AMNT, 
                     l.TransactionIvef_AMNT, 
                     l.OweTotIvef_AMNT, 
                     l.AppTotIvef_AMNT, 
                     l.TransactionMedi_AMNT, 
                     l.OweTotMedi_AMNT, 
                     l.AppTotMedi_AMNT, 
                     l.TransactionFuture_AMNT, 
                     l.AppTotFuture_AMNT, 
                     l.TransactionNffc_AMNT, 
                     l.OweTotNffc_AMNT, 
                     l.AppTotNffc_AMNT, 
                     l.TransactionNonIvd_AMNT, 
                     l.OweTotNonIvd_AMNT, 
                     l.AppTotNonIvd_AMNT, 
                     l.Receipt_DATE, 
                     s.Order_IDNO, 
                     o.MemberMci_IDNO, 
                     o.TypeDebt_CODE, 
                     o.Fips_CODE, 
                     (SELECT TOP 1 LST.TypeWelfare_CODE
      					FROM LSUP_Y1 LST
      					WHERE LST.Case_IDNO = l.Case_IDNO 
				          AND LST.OrderSeq_NUMB = l.OrderSeq_NUMB 
				          AND LST.ObligationSeq_NUMB = l.ObligationSeq_NUMB 
				          AND LST.SupportYearMonth_NUMB = l.SupportYearMonth_NUMB 
				          AND LST.Batch_DATE = @Ad_Batch_DATE 
				          AND LST.SourceBatch_CODE = @Ac_SourceBatch_CODE 
				          AND LST.Batch_NUMB = @An_Batch_NUMB 
				          AND LST.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
				          AND LST.EventFunctionalSeq_NUMB IN ( @Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB ) 
				          AND LST.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE) AS TypeWelfareOriginal_CODE 
                  FROM LSUP_Y1 l
                     JOIN OBLE_Y1 o 
                     ON  l.Case_IDNO = o.Case_IDNO 
                    AND  l.OrderSeq_NUMB = o.OrderSeq_NUMB 
                    AND  l.ObligationSeq_NUMB = o.ObligationSeq_NUMB  
                    AND  o.EndValidity_DATE = @Ld_High_DATE   
                   JOIN  SORD_Y1 s
                     ON  l.Case_IDNO = s.Case_IDNO 
                    AND  l.OrderSeq_NUMB = s.OrderSeq_NUMB  
                    AND  s.EndValidity_DATE = @Ld_High_DATE   
                  WHERE l.Batch_DATE = @Ad_Batch_DATE 
                    AND l.SourceBatch_CODE = @Ac_SourceBatch_CODE 
                    AND l.Batch_NUMB = @An_Batch_NUMB 
                    AND l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
                    AND l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE 
                    AND l.EventGlobalSeq_NUMB >= @An_EventGlobalSeq_NUMB 
                    AND o.BeginObligation_DATE = 
                     (SELECT MAX(b.BeginObligation_DATE) 
                        FROM OBLE_Y1 b
                        WHERE b.Case_IDNO = o.Case_IDNO 
                          AND b.OrderSeq_NUMB = o.OrderSeq_NUMB 
                          AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB 
                          AND b.EndValidity_DATE = @Ld_High_DATE)) X  
                CROSS JOIN dbo.BATCH_COMMON$SF_GET_NUMBERS(1,14) a
            WHERE ((a.Row_NUMB = @Li_One_NUMB AND X.TransactionCurSup_AMNT != @Li_Zero_NUMB) 
               OR (a.Row_NUMB = @Li_Two_NUMB  AND X.TransactionExptPay_AMNT != @Li_Zero_NUMB) 
               OR (a.Row_NUMB = @Li_Three_NUMB  AND X.TransactionNaa_AMNT - 
                  CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE 
                        CASE X.TypeWelfareOriginal_CODE
                           WHEN @Lc_No_INDC THEN X.TransactionCurSup_AMNT
                           WHEN @Lc_WelfareTypeMedicaid_CODE THEN X.TransactionCurSup_AMNT
                           ELSE @Li_Zero_NUMB
                        END
                  END != @Li_Zero_NUMB) 
                  OR (a.Row_NUMB = @Li_Four_NUMB AND X.TransactionTaa_AMNT != @Li_Zero_NUMB) 
                  OR (a.Row_NUMB = @Li_Five_NUMB AND X.TransactionPaa_AMNT - 
                  CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE 
                        CASE X.TypeWelfareOriginal_CODE
                           WHEN @Lc_WelfareTypeTanf_CODE THEN X.TransactionCurSup_AMNT
                           ELSE @Li_Zero_NUMB
                        END
                  END != @Li_Zero_NUMB) OR 
                  (a.Row_NUMB = @Li_Six_NUMB AND X.TransactionCaa_AMNT != @Li_Zero_NUMB) 
               OR (a.Row_NUMB = @Li_Seven_NUMB AND X.TransactionUpa_AMNT != @Li_Zero_NUMB) 
               OR (a.Row_NUMB = @Li_Eight_NUMB AND X.TransactionUda_AMNT != @Li_Zero_NUMB) 
               OR (a.Row_NUMB = @Li_Nine_NUMB AND X.TransactionIvef_AMNT - 
                  CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE 
                        CASE X.TypeWelfareOriginal_CODE
                           WHEN @Lc_WelfareTypeNonIve_CODE THEN X.TransactionCurSup_AMNT
                           ELSE @Li_Zero_NUMB
                        END
                  END != @Li_Zero_NUMB) 
                  OR (a.Row_NUMB = @Li_Ten_NUMB AND X.TransactionMedi_AMNT - 
                  CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN X.TransactionCurSup_AMNT
                     ELSE @Li_Zero_NUMB
                  END != @Li_Zero_NUMB) 
                  OR (a.Row_NUMB = @Li_Eleven_NUMB AND X.TransactionFuture_AMNT != @Li_Zero_NUMB) 
                  OR (a.Row_NUMB = @Li_Twelve_NUMB AND X.TransactionNffc_AMNT - 
                  CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE 
                        CASE X.TypeWelfareOriginal_CODE
                           WHEN @Lc_WelfareTypeFosterCare_CODE THEN X.TransactionCurSup_AMNT
                           ELSE @Li_Zero_NUMB
                        END
                  END != @Li_Zero_NUMB) 
                  OR (a.Row_NUMB = @Li_Thirteen_NUMB AND X.TransactionNonIvd_AMNT - 
                  CASE X.TypeDebt_CODE
                     WHEN @Lc_TypeDebit_CODE THEN @Li_Zero_NUMB
                     ELSE 
                        CASE X.TypeWelfareOriginal_CODE
                           WHEN @Lc_WelfareTypeNonIvd_CODE THEN X.TransactionCurSup_AMNT
                           ELSE @Li_Zero_NUMB
                        END
                  END != @Li_Zero_NUMB))
         )  X
      GROUP BY 
         X.DistributedAs_CODE, 
         X.Case_IDNO  ,
         X.Order_IDNO ,
         X.MemberMci_IDNO , 
         X.TypeDebt_CODE , 
         X.Fips_CODE , 
         X.TypeWelfare_CODE, 
         X.Receipt_DATE, 
         X.PayorMCI_IDNO, 
         X.BalBeforeDist_AMNT
       UNION ALL
      SELECT 
         CASE l.StatusReceipt_CODE
            WHEN @Lc_StatusReceiptIdentified_CODE THEN @Lc_NewReceipt_CODE
            WHEN @Lc_StatusReceiptHeld_CODE THEN @Lc_Held_CODE
            WHEN @Lc_StatusReceiptUnidentified_CODE THEN @Lc_Unidentified_CODE
            WHEN @Lc_StatusReceiptRefunded_CODE THEN @Lc_Refunded_CODE
            ELSE @Lc_Null_TEXT
         END AS DistributedAs_CODE, 
               NULL AS Case_IDNO  ,
               NULL AS Order_IDNO ,
               l.PayorMCI_IDNO AS MemberMci_IDNO , 
               @Lc_Space_TEXT AS TypeDebt_CODE , 
               @Lc_Space_TEXT AS Fips_CODE ,
         @Lc_Space_TEXT AS TypeWelfare_CODE, 
         l.Receipt_DATE, 
         l.PayorMCI_IDNO , 
         l.ToDistribute_AMNT, 
         @Li_Zero_NUMB AS BalBeforeDist_AMNT
      FROM RCTH_Y1 l
      WHERE l.Batch_DATE = @Ad_Batch_DATE 
        AND l.SourceBatch_CODE = @Ac_SourceBatch_CODE 
        AND l.Batch_NUMB = @An_Batch_NUMB 
        AND l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
        AND l.SourceReceipt_CODE <> @Lc_ReceiptSrcDirectPaymentCredit_CODE 
        AND l.BackOut_INDC <> @Lc_Yes_INDC 
        AND l.EndValidity_DATE = @Ld_High_DATE 
        AND NOT EXISTS(
            SELECT 1 
            FROM LSUP_Y1 s
            WHERE l.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE 
              AND s.Batch_DATE = @Ad_Batch_DATE 
              AND s.SourceBatch_CODE = @Ac_SourceBatch_CODE 
              AND s.Batch_NUMB = @An_Batch_NUMB 
              AND s.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
              AND s.EventFunctionalSeq_NUMB IN ( @Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB )))	
		SELECT RE.DistributedAs_CODE, 
               RE.Case_IDNO  ,
               RE.Order_IDNO ,
               RE.MemberMci_IDNO , 
               RE.TypeDebt_CODE , 
               RE.Fips_CODE , 
			   RE.TypeWelfare_CODE, 
			   RE.Receipt_DATE , 
			   RE.PayorMCI_IDNO , 
			   D.Last_NAME ,
			   D.First_NAME ,
			   D.Middle_NAME ,
			   D.Suffix_NAME ,
			   RE.Distribute_AMNT, 
			   RE.BalBeforeDist_AMNT
			 FROM Rrep_CTE RE 
			   LEFT OUTER JOIN DEMO_Y1 D 
			   ON  RE.PayorMCI_IDNO = D.MemberMci_IDNO
	     ORDER BY RE.DistributedAs_CODE,
               RE.Case_IDNO  ,
			   RE.Order_IDNO ,
			   RE.MemberMci_IDNO , 
			   RE.TypeDebt_CODE , 
			   RE.Fips_CODE   ;
			   
END; --End Of Procdeure LSUP_RETRIEVE_S101 


GO
