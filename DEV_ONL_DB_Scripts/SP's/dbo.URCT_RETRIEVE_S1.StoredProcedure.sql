/****** Object:  StoredProcedure [dbo].[URCT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[URCT_RETRIEVE_S1] ( 
     @Ad_Batch_DATE		             DATE,
	 @Ac_SourceBatch_CODE		     CHAR(3),
     @An_Batch_NUMB                  NUMERIC(4,0),
     @An_SeqReceipt_NUMB		     NUMERIC(6,0),     
     @As_Payor_NAME                  VARCHAR(71),
     @An_Bank_IDNO		             NUMERIC(10,0),
     @An_BankAcct_NUMB		         NUMERIC(17,0),
     @An_IdentifiedPayorMci_IDNO	 NUMERIC(10,0),
     @Ac_IdentificationStatus_CODE	 CHAR(1),
     @An_UnidentifiedSsn_NUMB		 NUMERIC(9,0),
     @Ac_SourceReceipt_CODE		     CHAR(2),
     @Ac_TypeRemittance_CODE	     CHAR(3),
     @An_Receipt_AMNT		         NUMERIC(11,2),
     @Ac_CheckNo_TEXT		         CHAR(18),
     @Ac_ReasonStatus_CODE           CHAR(4),
     @Ac_SourceBatchIn_CODE          CHAR(3),
     @Ad_From_DATE		             DATE,
     @Ad_To_DATE		             DATE,
     @Ac_SearchOption_CODE           CHAR(1),
     @Ai_RowFrom_NUMB                INT =1,
     @Ai_RowTo_NUMB                  INT =10     
     )
AS

/*
 *     PROCEDURE NAME    : URCT_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the Unidentified receipts between the given dates.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
   
    DECLARE
        @Ld_High_DATE                    DATE ='12/31/9999',
        @Ld_Current_DATE                 DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
        @Lc_IdentificationStatusA_CODE   CHAR(1) = 'A',
        @Lc_IdentificationStatusU_CODE   CHAR(1) = 'U',
        @Lc_IdentificationStatusI_CODE   CHAR(1) = 'I',
        @Lc_IdentificationStatusO_CODE   CHAR(1) = 'O',
        @Li_One_NUMB                     SMALLINT = 1,
        @Lc_NameSrchTypeD_CODE           CHAR(1) = 'D',
		@Li_Zero_NUMB					 SMALLINT= 0;
        
      SELECT X.Batch_DATE, 
		 X.SourceBatch_CODE, 
         X.Batch_NUMB, 
         X.SeqReceipt_NUMB, 
         X.IdentificationStatus_CODE, 
         X.Receipt_DATE, 
         X.Receipt_AMNT, 
         X.Payor_NAME, 
         X.CheckNo_TEXT, 
         X.TypeRemittance_CODE, 
         X.SourceReceipt_CODE, 
         X.EventGlobalBeginSeq_NUMB, 
         X.Remarks_TEXT, 
         X.RowCount_NUMB, 
         X.Total_AMNT 
      FROM ( SELECT c.Batch_DATE, 
               c.Batch_NUMB, 
               c.SeqReceipt_NUMB, 
               c.IdentificationStatus_CODE, 
               c.Receipt_DATE, 
               c.Receipt_AMNT, 
               c.Payor_NAME, 
               c.CheckNo_TEXT, 
               c.TypeRemittance_CODE, 
               c.SourceReceipt_CODE, 
               c.SourceBatch_CODE, 
               c.EventGlobalBeginSeq_NUMB, 
               c.Remarks_TEXT, 
               c.RowCount_NUMB, 
               c.Total_AMNT, 
               c.ORD_ROWNUM1 AS ORD_ROWNUM2
            FROM ( SELECT  a.Batch_DATE, 
                     a.SourceBatch_CODE, 
                     a.Batch_NUMB, 
                     a.SeqReceipt_NUMB, 
                     a.IdentificationStatus_CODE, 
                     a.Receipt_DATE, 
                     a.Receipt_AMNT, 
                     a.Payor_NAME, 
                     a.CheckNo_TEXT, 
                     a.TypeRemittance_CODE, 
                     a.SourceReceipt_CODE, 
                     a.EventGlobalBeginSeq_NUMB, 
                     a.Remarks_TEXT, 
                     a.ORD_ROWNUM, 
                     COUNT(1) OVER() AS RowCount_NUMB, 
                     SUM(CAST(a.Receipt_AMNT AS FLOAT(53))) OVER() AS Total_AMNT, 
                     ROW_NUMBER() OVER(
                        ORDER BY 
                           a.Batch_DATE DESC, 
                           a.SourceBatch_CODE, 
                           a.Batch_NUMB, 
                           a.SeqReceipt_NUMB) AS ORD_ROWNUM1
                  FROM(SELECT a.Batch_DATE , 
                           a.SourceBatch_CODE , 
                           a.Batch_NUMB , 
                           a.SeqReceipt_NUMB , 
                           a.IdentificationStatus_CODE , 
                           b.Receipt_DATE , 
                           b.Receipt_AMNT , 
                           a.Payor_NAME , 
                           b.CheckNo_TEXT , 
                           b.TypeRemittance_CODE , 
                           a.SourceReceipt_CODE , 
                           b.EventGlobalBeginSeq_NUMB,  
                           a.Remarks_TEXT, 
                           ROW_NUMBER() OVER(PARTITION BY b.Batch_DATE, b.Batch_NUMB, b.SourceBatch_CODE, b.SeqReceipt_NUMB
                              ORDER BY b.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                        FROM  URCT_Y1   a 
                              JOIN
                              RCTH_Y1   b
                            ON (
                                     a.Batch_DATE = b.Batch_DATE 
                                 AND a.Batch_NUMB = b.Batch_NUMB 
                                 AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                 AND a.SourceBatch_CODE = b.SourceBatch_CODE
                               )  
                                  
                        WHERE b.EndValidity_DATE = @Ld_High_DATE 
                         AND  a.EndValidity_DATE = @Ld_High_DATE 
                         AND  a.Batch_DATE BETWEEN ISNULL(@Ad_From_DATE, @Ad_Batch_DATE) AND ISNULL(@Ad_To_DATE,@Ld_Current_DATE) 
                         AND  (  (     @Ac_IdentificationStatus_CODE != @Lc_IdentificationStatusA_CODE 
                                  AND ( (    @Ac_IdentificationStatus_CODE = @Lc_IdentificationStatusU_CODE 
                                            AND a.IdentificationStatus_CODE = @Ac_IdentificationStatus_CODE
                                           ) 
                                       OR ((     @Ac_IdentificationStatus_CODE = @Lc_IdentificationStatusI_CODE 
                                             AND  a.IdentificationStatus_CODE IN ( @Lc_IdentificationStatusI_CODE, @Lc_IdentificationStatusO_CODE )) 
                                            ))) 
                               OR (@Ac_IdentificationStatus_CODE = @Lc_IdentificationStatusA_CODE)
                               ) 
                         AND (    @An_Receipt_AMNT IS NULL 
                              OR (     @An_Receipt_AMNT IS NOT NULL 
                                   AND b.Receipt_AMNT = @An_Receipt_AMNT
                                  )
                             ) 
                         AND (    @An_IdentifiedPayorMci_IDNO IS NULL 
                              OR (@An_IdentifiedPayorMci_IDNO IS NOT NULL 
                              AND a.IdentifiedPayorMci_IDNO = @An_IdentifiedPayorMci_IDNO)
                             ) 
                         AND (    @An_UnidentifiedSsn_NUMB IS NULL 
                              OR (    @An_UnidentifiedSsn_NUMB IS NOT NULL 
                                  AND a.UnidentifiedSsn_NUMB = @An_UnidentifiedSsn_NUMB
                                  )
                            ) 
                         AND (@Ad_Batch_DATE IS NULL 
                               OR (     a.Batch_DATE = @Ad_Batch_DATE 
                                   AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE 
                                   AND a.Batch_NUMB = @An_Batch_NUMB 
                                   AND a.SeqReceipt_NUMB LIKE @An_SeqReceipt_NUMB
                                  )
                              ) 
                         AND ( (     @As_Payor_NAME IS NOT NULL 
                                 AND @Ac_SearchOption_CODE = @Lc_NameSrchTypeD_CODE
								 AND SOUNDEX(a.Payor_NAME) = SOUNDEX(@As_Payor_NAME)  
                                ) 
                                OR(    @As_Payor_NAME IS NOT NULL 
                                   AND @Ac_SearchOption_CODE != @Lc_NameSrchTypeD_CODE 
                                   AND a.Payor_NAME LIKE @As_Payor_NAME
                                  ) 
                               OR 
                              (@As_Payor_NAME IS NULL)
                             ) 
                         AND (
                                (     @Ac_SourceReceipt_CODE IS NOT NULL 
                                  AND a.SourceReceipt_CODE = @Ac_SourceReceipt_CODE
                                 ) 
                               OR (@Ac_SourceReceipt_CODE IS NULL)
                             ) 
                         AND ((    @Ac_ReasonStatus_CODE IS NOT NULL 
                               AND b.ReasonStatus_CODE = @Ac_ReasonStatus_CODE
                               ) 
                             OR (@Ac_ReasonStatus_CODE IS NULL)
                             ) 
                         AND ((     @An_BankAcct_NUMB IS NOT NULL 
                                AND a.BankAcct_NUMB = @An_BankAcct_NUMB
                               ) 
                             OR (@An_BankAcct_NUMB IS NULL)
                             ) 
                         AND ( (    @An_Bank_IDNO IS NOT NULL 
                                AND a.Bank_IDNO = @An_Bank_IDNO
                               ) 
                                OR ( @An_Bank_IDNO IS NULL)
                             ) 
                         AND ( (    @Ac_CheckNo_TEXT IS NOT NULL 
                                AND b.CheckNo_TEXT = @Ac_CheckNo_TEXT
                               ) 
                              OR (@Ac_CheckNo_TEXT IS NULL)
                             ) 
                         AND ( (      @Ac_TypeRemittance_CODE IS NOT NULL 
                                 AND b.TypeRemittance_CODE = @Ac_TypeRemittance_CODE
                               ) 
                              OR (@Ac_TypeRemittance_CODE IS NULL)
                             ) 
                         AND ( (    @Ac_SourceBatchIn_CODE  IS NOT NULL 
                               AND b.SourceBatch_CODE = @Ac_SourceBatchIn_CODE 
                               ) 
                              OR (@Ac_SourceBatchIn_CODE  IS NULL)
                             ) 
                         )   a
                  WHERE a.ORD_ROWNUM = @Li_One_NUMB
               )   c
            WHERE c.ORD_ROWNUM1 <= @Ai_RowTo_NUMB 
               OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
         )   X
      WHERE X.ORD_ROWNUM2 >= @Ai_RowFrom_NUMB 
         OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
 ORDER BY ORD_ROWNUM2;

                  
END; --END OF URCT_RETRIEVE_S1


GO
