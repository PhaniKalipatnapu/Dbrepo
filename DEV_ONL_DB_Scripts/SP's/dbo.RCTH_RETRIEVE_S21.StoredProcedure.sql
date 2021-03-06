/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S21] (
 @Ad_From_DATE	DATE	,
 @Ad_To_DATE	DATE
)                	
AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S21
 *     DESCRIPTION       : Retrieve Daily Gross summary Receipts Report for the given date period
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

      DECLARE
         @Lc_StatusBatchReconciled_CODE    	CHAR(1) = 'R', 
         @Lc_StatusReceiptEscheated_CODE   	CHAR(1) = 'E', 
         @Lc_StatusReceiptHeld_CODE        	CHAR(1) = 'H', 
         @Lc_StatusReceiptIdentified_CODE  	CHAR(1) = 'I', 
         @Lc_StatusReceiptOthpRefund_CODE  	CHAR(1) = 'O', 
         @Lc_StatusReceiptRefunded_CODE    	CHAR(1) = 'R', 
         @Lc_StatusReceiptUnidentified_CODE	CHAR(1) = 'U', 
         @Ld_High_DATE                 		DATE	= '12/31/9999', 
         @Li_Zero_NUMB                     	SMALLINT= 0, 
         @Lc_BackOutN_INDC              	CHAR(1) = 'N', 
         @Lc_RePostN_INDC               	CHAR(1) = 'N', 
         @Lc_SourceBatch102_CODE         	CHAR(3) = '102'; 
         
         
		SELECT   W.SourceReceipt_CODE, 
				 W.CountIdentified_QNTY, 
				 W.Identified_AMNT ,
				 W.CountUnidentified_QNTY, 
				 W.Unidentified_AMNT ,
				 W.CountTotal_QNTY, 
				 W.Total_AMNT ,
				 SUM(W.CountIdentified_QNTY ) OVER() AS GtCountIdentified_QNTY, 
				 SUM(W.Identified_AMNT ) OVER() AS GtIdentified_AMNT, 
				 SUM(W.CountUnidentified_QNTY ) OVER() AS GtCountUnidentified_QNTY, 
				 SUM(W.Unidentified_AMNT ) OVER() AS GtUnidentified_AMNT, 
				 SUM(W.CountTotal_QNTY ) OVER() AS GtCountTotal_QNTY, 
				 SUM(W.Total_AMNT ) OVER() AS GtAmountTotal_QNTY, 
				 COUNT(1) OVER() AS RowCount_NUMB
		FROM (
		  SELECT X.SourceReceipt_CODE, 
				 MAX (X.CountIdentified_QNTY)CountIdentified_QNTY, 
				 MAX (X.Identified_AMNT)Identified_AMNT ,
				 MAX (X.CountUnidentified_QNTY) CountUnidentified_QNTY, 
				 MAX (X.Unidentified_AMNT) Unidentified_AMNT ,
				 (MAX (X.CountIdentified_QNTY)+MAX (X.CountUnidentified_QNTY)) AS CountTotal_QNTY, 
				 (MAX (X.Identified_AMNT)+ MAX (X.Unidentified_AMNT) ) AS Total_AMNT 
			FROM (
			 SELECT Y.SourceReceipt_CODE,
                   MAX (CASE
                           WHEN Y.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                              THEN ICNT
                           ELSE @Li_Zero_NUMB
                        END) CountIdentified_QNTY,
                   SUM
                      (CASE
                          WHEN Y.StatusReceipt_CODE = @Lc_StatusReceiptIdentified_CODE
                             THEN ToDistribute_AMNT
                          ELSE @Li_Zero_NUMB
                       END
                      ) Identified_AMNT,
                   MAX (CASE
                           WHEN Y.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
                              THEN ICNT
                           ELSE @Li_Zero_NUMB
                        END) CountUnidentified_QNTY,
                   SUM
                      (CASE
                          WHEN Y.StatusReceipt_CODE = @Lc_StatusReceiptUnidentified_CODE
                             THEN ToDistribute_AMNT
                          ELSE @Li_Zero_NUMB
                       END
                      ) Unidentified_AMNT
                     FROM (
                     SELECT Z.SourceReceipt_CODE, 
							Z.StatusReceipt_CODE,
                            COUNT (Z.ICNT) ICNT,
                            SUM (Z.ToDistribute_AMNT) ToDistribute_AMNT
                        FROM (
                        SELECT   m.SourceReceipt_CODE,
                                       COUNT (1) ICNT,
                                       SUM(m.ToDistribute_AMNT ) ToDistribute_AMNT,
                                       m.StatusReceipt_CODE
                                  FROM (
                                  SELECT a.SourceReceipt_CODE,
                                               a.Batch_DATE, 
                                               a.Batch_NUMB,
                                               a.SourceBatch_CODE,
                                               a.SeqReceipt_NUMB,
                                               a.ToDistribute_AMNT,
                                               CASE
                                                  WHEN a.StatusReceipt_CODE =
                                                         @Lc_StatusReceiptUnidentified_CODE
                                                     THEN @Lc_StatusReceiptUnidentified_CODE
                                                  WHEN a.StatusReceipt_CODE =
                                                         @Lc_StatusReceiptEscheated_CODE
                                                  AND a.PayorMCI_IDNO =@Li_Zero_NUMB
                                                     THEN @Lc_StatusReceiptUnidentified_CODE
                                                  WHEN a.StatusReceipt_CODE IN
                                                         (@Lc_StatusReceiptHeld_CODE, @Lc_StatusReceiptRefunded_CODE, @Lc_StatusReceiptOthpRefund_CODE, @Lc_StatusReceiptIdentified_CODE)
                                                     THEN @Lc_StatusReceiptIdentified_CODE
                                                  WHEN a.StatusReceipt_CODE = @Lc_StatusReceiptEscheated_CODE
                                                  AND a.PayorMCI_IDNO <> @Li_Zero_NUMB
                                                     THEN @Lc_StatusReceiptIdentified_CODE
                                               END StatusReceipt_CODE 
                                          FROM RCTH_Y1 a
                                         WHERE EXISTS ( 
												SELECT 1
												  FROM RBAT_Y1 r
                                                          WHERE r.Batch_DATE = a.Batch_DATE
															AND r.Batch_NUMB = a.Batch_NUMB
															AND r.SourceBatch_CODE =a.SourceBatch_CODE
                                                            AND r.StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE
                                                            AND r.BeginValidity_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
                                                            AND r.RePost_INDC = @Lc_RePostN_INDC
                                                            AND r.EndValidity_DATE = @Ld_High_DATE )
                                           AND a.BackOut_INDC = @Lc_BackOutN_INDC
                                           AND a.EndValidity_DATE = @Ld_High_DATE
                                           AND a.SourceBatch_CODE != @Lc_SourceBatch102_CODE ) m
                              GROUP BY m.SourceReceipt_CODE,
                                       m.Batch_DATE,
                                       m.Batch_NUMB,
                                       m.SourceBatch_CODE,
                                       m.SeqReceipt_NUMB,
                                       StatusReceipt_CODE) Z
                    GROUP BY Z.SourceReceipt_CODE, Z.StatusReceipt_CODE)Y
          GROUP BY Y.SourceReceipt_CODE, Y.StatusReceipt_CODE)X
GROUP BY SourceReceipt_CODE ) W
ORDER BY SourceReceipt_CODE ;
                  
END;	--END OF RCTH_RETRIEVE_S21


GO
