/****** Object:  StoredProcedure [dbo].[LSUP_RETRIEVE_S100]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSUP_RETRIEVE_S100](
	@Ad_Batch_DATE          DATE,
	@Ac_SourceBatch_CODE    CHAR(3),
	@An_Batch_NUMB          NUMERIC(4),
	@An_SeqReceipt_NUMB     NUMERIC(6),
	@An_EventGlobalSeq_NUMB NUMERIC(19)
)
AS
 /*                                                                                                                
  *     PROCEDURE NAME    :  LSUP_RETRIEVE_S100                                                                      
  *     DESCRIPTION       :  This Procedure is used to populate details for 'Distribution Details ' pop up.
  *                          The Distribution Details pop-up view displays the distribution details for the
  *                          receipt identified in the KEYFIELDS column on ELOG.                                                                                      
  *     DEVELOPED BY      :  IMP Team                                                                             
  *     DEVELOPED ON      :  01/12/2011                                                                            
  *     MODIFIED BY       :                                                                                        
  *     MODIFIED ON       :                                                                                        
  *     VERSION NO        :  1                                                                                      
  */
BEGIN
  
  DECLARE @Li_Three_NUMB                    INT      =  3,
		  @Li_Zero_NUMB                     SMALLINT =  0,
		  @Lc_No_INDC						CHAR(1)  = 'N',
          @Lc_Space_TEXT					CHAR(1)  = ' ',
          @Lc_WelfareTypeFosterCare_CODE	CHAR(1)  = 'J',
          @Lc_WelfareTypeMedicaid_CODE		CHAR(1)  = 'M',
          @Lc_WelfareTypeNonIvd_CODE		CHAR(1)  = 'H',
          @Lc_WelfareTypeNonIve_CODE		CHAR(1)  = 'F',
          @Lc_WelfareTypeTanf_CODE			CHAR(1)  = 'A',
          @Lc_TypeRecordOriginal_CODE       CHAR(1)  = 'O',
          @Lc_TypeDebit_CODE                CHAR(3)  = 'DS',
          @Ld_High_DATE				        DATE     = '12/31/9999';

  WITH CTE_TAB
       AS (SELECT l.Case_IDNO,
                  s.Order_IDNO,
                  o.MemberMci_IDNO,
                  o.TypeDebt_CODE,
                  o.Fips_CODE,
                  l.TypeWelfare_CODE,
                  l.Receipt_DATE,
                  ISNULL(dbo.BATCH_COMMON_GETS$SF_GET_MEMBER_NAME(o.MemberMci_IDNO), @Lc_Space_TEXT) AS Member_NAME,
                  l.TransactionCurSup_AMNT c01_CurSup_AMNT,
                  l.TransactionExptPay_AMNT c02_Expt_AMNT,
                  CAST((l.TransactionNaa_AMNT - CASE o.TypeDebt_CODE
                                                 WHEN @Lc_TypeDebit_CODE
                                                  THEN @Li_Zero_NUMB
                                                 ELSE
                                                  CASE l.TypeWelfare_CODE
                                                   WHEN @Lc_No_INDC
                                                    THEN l.TransactionCurSup_AMNT
                                                   WHEN @Lc_WelfareTypeMedicaid_CODE
                                                    THEN l.TransactionCurSup_AMNT
                                                   ELSE @Li_Zero_NUMB
                                                  END
                                                END) AS NUMERIC(11, 2)) c03_Naa_AMNT,
                  TransactionTaa_AMNT c04_Taa_AMNT,
                  CAST((TransactionPaa_AMNT - CASE o.TypeDebt_CODE
                                               WHEN @Lc_TypeDebit_CODE
                                                THEN @Li_Zero_NUMB
                                               ELSE
                                                CASE l.TypeWelfare_CODE
                                                 WHEN @Lc_WelfareTypeTanf_CODE
                                                  THEN l.TransactionCurSup_AMNT
                                                 ELSE @Li_Zero_NUMB
                                                END
                                              END) AS NUMERIC(11, 2)) c05_Paa_AMNT,
                  l.TransactionCaa_AMNT c06_Caa_AMNT,
                  l.TransactionUpa_AMNT c07_Upa_AMNT,
                  l.TransactionUda_AMNT c08_Uda_AMNT,
                  CAST((l.TransactionIvef_AMNT - CASE o.TypeDebt_CODE
                                                  WHEN @Lc_TypeDebit_CODE
                                                   THEN @Li_Zero_NUMB
                                                  ELSE
                                                   CASE l.TypeWelfare_CODE
                                                    WHEN @Lc_WelfareTypeNonIve_CODE
                                                     THEN l.TransactionCurSup_AMNT
                                                    ELSE @Li_Zero_NUMB
                                                   END
                                                 END) AS NUMERIC(11, 2)) c09_Ivef_AMNT,
                  CAST((l.TransactionMedi_AMNT - CASE o.TypeDebt_CODE
                                                  WHEN @Lc_TypeDebit_CODE
                                                   THEN l.TransactionCurSup_AMNT
                                                  ELSE @Li_Zero_NUMB
                                                 END) AS NUMERIC(11, 2)) c10_Medi_AMNT,
                  l.TransactionFuture_AMNT c11_Future_AMNT,
                  CAST((l.TransactionNffc_AMNT - CASE o.TypeDebt_CODE
                                                  WHEN @Lc_TypeDebit_CODE
                                                   THEN @Li_Zero_NUMB
                                                  ELSE
                                                   CASE l.TypeWelfare_CODE
                                                    WHEN @Lc_WelfareTypeFosterCare_CODE
                                                     THEN l.TransactionCurSup_AMNT
                                                    ELSE @Li_Zero_NUMB
                                                   END
                                                 END) AS NUMERIC(11, 2)) c12_Nffc_AMNT,
                  CAST((l.TransactionNonIvd_AMNT - CASE o.TypeDebt_CODE
                                                    WHEN @Lc_TypeDebit_CODE
                                                     THEN @Li_Zero_NUMB
                                                    ELSE
                                                     CASE l.TypeWelfare_CODE
                                                      WHEN @Lc_WelfareTypeNonIvd_CODE
                                                       THEN l.TransactionCurSup_AMNT
                                                      ELSE @Li_Zero_NUMB
                                                     END
                                                   END) AS NUMERIC(11, 2)) c13_NonIvd_AMNT,
                  (l.OweTotCurSup_AMNT - (l.AppTotCurSup_AMNT - l.TransactionCurSup_AMNT)) c01_BefDist_AMNT,
                  (l.OweTotExptPay_AMNT - (l.AppTotExptPay_AMNT - l.TransactionExptPay_AMNT)) c02_BefDist_AMNT,
                  (l.OweTotNaa_AMNT - (l.AppTotNaa_AMNT - l.TransactionNaa_AMNT)) c03_BefDist_AMNT,
                  (l.OweTotTaa_AMNT - (l.AppTotTaa_AMNT - l.TransactionTaa_AMNT)) c04_BefDist_AMNT,
                  (l.OweTotPaa_AMNT - (l.AppTotPaa_AMNT - l.TransactionPaa_AMNT)) c05_BefDist_AMNT,
                  (l.OweTotCaa_AMNT - (l.AppTotCaa_AMNT - l.TransactionCaa_AMNT)) c06_BefDist_AMNT,
                  (l.OweTotUpa_AMNT - (l.AppTotUpa_AMNT - l.TransactionUpa_AMNT)) c07_BefDist_AMNT,
                  (l.OweTotUda_AMNT - (l.AppTotUda_AMNT - l.TransactionUda_AMNT)) c08_BefDist_AMNT,
                  (l.OweTotIvef_AMNT - (l.AppTotIvef_AMNT - l.TransactionIvef_AMNT)) c09_BefDist_AMNT,
                  (l.OweTotMedi_AMNT - (l.AppTotMedi_AMNT - l.TransactionMedi_AMNT)) c10_BefDist_AMNT,
                  (l.OweTotMedi_AMNT - (l.OweTotMedi_AMNT - @Li_Zero_NUMB)) c11_BefDist_AMNT,
                  (l.OweTotNffc_AMNT - (l.AppTotNffc_AMNT - l.TransactionNffc_AMNT)) c12_BefDist_AMNT,
                  (l.OweTotNonIvd_AMNT - (l.AppTotNonIvd_AMNT - l.TransactionNonIvd_AMNT)) c13_BefDist_AMNT
             FROM LSUP_Y1  l 
                  JOIN 
                  OBLE_Y1  o 
                       ON l.Case_IDNO = o.Case_IDNO
                      AND l.OrderSeq_NUMB = o.OrderSeq_NUMB
                      AND l.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                 JOIN SORD_Y1  s
                   ON l.Case_IDNO = s.Case_IDNO
                  AND l.OrderSeq_NUMB = s.OrderSeq_NUMB
            WHERE l.Batch_DATE = @Ad_Batch_DATE
              AND l.SourceBatch_CODE = @Ac_SourceBatch_CODE
              AND l.Batch_NUMB = @An_Batch_NUMB
              AND l.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
              AND l.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
              AND l.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
              AND s.EndValidity_DATE = @Ld_High_DATE
              AND o.EndValidity_DATE = @Ld_High_DATE
              AND o.BeginObligation_DATE = (SELECT MAX(b.BeginObligation_DATE)
                                              FROM OBLE_Y1 b
                                             WHERE b.Case_IDNO = o.Case_IDNO
                                               AND b.OrderSeq_NUMB = o.OrderSeq_NUMB
                                               AND b.ObligationSeq_NUMB = o.ObligationSeq_NUMB
                                               AND b.EndValidity_DATE = @Ld_High_DATE))
  SELECT SUBSTRING(DistributedAs_CODE, 5, LEN(DistributedAs_CODE) - 9) AS DistributedAs_CODE,
         Case_IDNO,
         Order_IDNO,
         MemberMci_IDNO,
         TypeDebt_CODE,
         Fips_CODE,
         TypeWelfare_CODE,
         Receipt_DATE AS Distribute_DATE,
         Member_NAME,
         SUM(Distribute_AMNT) AS Distribute_AMNT,
         SUM(BalBeforeDist_AMNT) AS BalBeforeDist_AMNT
    FROM CTE_TAB  X
    UNPIVOT (Distribute_AMNT FOR DistributedAs_CODE IN 
                     (c01_CurSup_AMNT, c02_Expt_AMNT, c03_Naa_AMNT, c04_Taa_AMNT, c05_Paa_AMNT,
                        c06_Caa_AMNT, c07_Upa_AMNT, c08_Uda_AMNT, c09_Ivef_AMNT, c10_Medi_AMNT, 
                        c11_Future_AMNT, c12_Nffc_AMNT, c13_NonIvd_AMNT) 
                    ) AS  Y
    UNPIVOT (BalBeforeDist_AMNT FOR BalBeforeDist_CODE IN 
                        (c01_BefDist_AMNT,c02_BefDist_AMNT,c03_BefDist_AMNT,c04_BefDist_AMNT,c05_BefDist_AMNT,
                         c06_BefDist_AMNT,c07_BefDist_AMNT,c08_BefDist_AMNT,c09_BefDist_AMNT,c10_BefDist_AMNT,
                         c11_BefDist_AMNT,c12_BefDist_AMNT,c13_BefDist_AMNT) 
                    ) AS Z
   WHERE LEFT(BalBeforeDist_CODE, @Li_Three_NUMB) = LEFT(DistributedAs_CODE, @Li_Three_NUMB)
     AND Distribute_AMNT <> @Li_Zero_NUMB
   GROUP BY DistributedAs_CODE,
            Case_IDNO,
            Order_IDNO,
            MemberMci_IDNO,
            TypeDebt_CODE,
            Fips_CODE,
            TypeWelfare_CODE,
            Receipt_DATE,
            Member_NAME
   ORDER BY DistributedAs_CODE,
            Case_IDNO,
            Order_IDNO,
            MemberMci_IDNO,
            TypeDebt_CODE,
            Fips_CODE;
            
END; --End Of Procedure LSUP_RETRIEVE_S100 


GO
