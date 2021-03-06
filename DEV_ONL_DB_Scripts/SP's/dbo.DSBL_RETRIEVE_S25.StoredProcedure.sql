/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		 		
CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S25](
  @Ad_From_DATE   		DATE,
  @Ad_To_DATE     		DATE,
  @Ac_ReasonStatus_CODE	CHAR(4),
  @Ac_RefundsTo_CODE    CHAR(3),
  @Ai_RowFrom_NUMB     	INT = 1,
  @Ai_RowTo_NUMB       	INT = 10
 )
 AS
 
/*  
 *     PROCEDURE NAME    : DSBL_RETRIEVE_S25
 *     DESCRIPTION       : The authorized worker can view the refund or demand details for all the refunds processed for the specified date range.     
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 21-NOV-2011
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  

BEGIN  
   
	DECLARE
		@Li_Zero_NUMB					INT		= 0,
		@Lc_RecipientTypeCpNcp_CODE		CHAR(1) = '1',
        @Lc_RecipientTypeFIPS_CODE		CHAR(1) = '2',
        @Lc_RecipientTypeOTHP_CODE   	CHAR(1) = '3',
        @Lc_ReceiptSourceCF_CODE        CHAR(2) = 'CF',     
        @Lc_ReceiptSourceCR_CODE        CHAR(2) = 'CR',
        @Lc_RefundsCPP_CODE				CHAR(3)	= 'CPP',
        @Lc_RefundsFPI_CODE				CHAR(3)	= 'FPI',
        @Lc_RefundsFPU_CODE         	CHAR(3)	= 'FPU',
        @Lc_RefundsNCP_CODE				CHAR(3)	= 'NCP',
        @Lc_RefundsOTP_CODE				CHAR(3)	= 'OTP',
        @Lc_DisbursementTypeRefund_CODE	CHAR(5) = 'REFND', 
        @Lc_DisbursementTypeRothp_CODE 	CHAR(5) = 'ROTHP',
        @Ld_High_DATE       			DATE	= '12/31/9999';
    DECLARE
        @Ld_Current_DATE                DATE    = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();


	SELECT X.CheckRecipient_ID,
	       DBO.BATCH_COMMON$SF_GET_RECIPIENT_NAME(X.CheckRecipient_ID,X.CheckRecipient_CODE) AS RecipientName_TEXT,
	       X.Case_IDNO, 
	       X.Issue_DATE,
	       X.Disburse_AMNT,
	       X.Check_NUMB,
	       X.Worker_ID,
	       X.ReasonStatus_CODE, 
	       SumTotCount_NUMB,
	       SumTot_AMNT, 
	       RowCount_NUMB, 
	       (SELECT TOP 1 U.Supervisor_ID 
	         FROM USRL_Y1 U
	          WHERE U.Worker_ID = X.Worker_ID 
	           AND U.EndValidity_DATE = @Ld_High_DATE  
	           AND U.Expire_DATE > CONVERT(DATE,@Ld_Current_DATE)) AS Supervisor_ID
	   FROM(SELECT Y.CheckRecipient_CODE, 
	               Y.CheckRecipient_ID, 
	               Y.Case_IDNO, 
	               Y.Issue_DATE,
	               Y.Disburse_AMNT, 
	               Y.Check_NUMB, 
	               Y.Worker_ID,
	               Y.ReasonStatus_CODE,
	               Y.SumTotCount_NUMB,
	               Y.SumTot_AMNT, 
	               Y.RowCount_NUMB,
	               Y.ORD_ROWNUM
	          FROM(SELECT z.CheckRecipient_CODE, 
	                      z.CheckRecipient_ID, 
	                      z.Case_IDNO,
	                      z.Issue_DATE, 
	                      z.Disburse_AMNT, 
	                      z.Check_NUMB, 
	                      z.Worker_ID,
	                      z.ReasonStatus_CODE,
	                      COUNT (1) OVER () AS SumTotCount_NUMB,
	                      SUM (Disburse_AMNT) OVER () SumTot_AMNT,
	                      COUNT(1) OVER() AS RowCount_NUMB,  
	                      ROW_NUMBER() OVER(ORDER BY CheckRecipient_ID,Check_NUMB) AS ORD_ROWNUM
					   FROM (SELECT c.CheckRecipient_CODE, 
	                                c.CheckRecipient_ID,
	                                c.Case_IDNO, 
	                                a.Issue_DATE, 
	                                c.Disburse_AMNT,
	                                a.Check_NUMB, 
	                                g.Worker_ID,
	                                r.ReasonStatus_CODE
	                             FROM DSBH_Y1 a 
	                             		JOIN DSBL_Y1 c
                         					ON  a.CheckRecipient_ID = c.CheckRecipient_ID
                            					AND a.CheckRecipient_CODE = c.CheckRecipient_CODE
                            					AND a.Disburse_DATE = c.Disburse_DATE
                            					AND a.DisburseSeq_NUMB = c.DisburseSeq_NUMB
	                                 	JOIN RCTH_Y1 r
	                                 		ON r.Batch_DATE = c.Batch_DATE
				                                AND r.SourceBatch_CODE = c.SourceBatch_CODE
				                                AND r.Batch_NUMB = c.Batch_NUMB
				                                AND r.SeqReceipt_NUMB = c.SeqReceipt_NUMB
				                                AND r.EventGlobalBeginSeq_NUMB = c.EventGlobalSupportSeq_NUMB
	                                  	JOIN GLEV_Y1 g
	                                  		ON c.EventGlobalSupportSeq_NUMB = g.EventGlobalSeq_NUMB	                                			
	                                WHERE c.Disburse_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
	                                AND a.EndValidity_DATE = @Ld_High_DATE
	                                AND c.TypeDisburse_CODE IN(@Lc_DisbursementTypeRefund_CODE,@Lc_DisbursementTypeRothp_CODE )
	                                AND (@Ac_RefundsTo_CODE IS NULL 
	                                      OR (@Ac_RefundsTo_CODE = @Lc_RefundsCPP_CODE 
	                                        AND r.SourceReceipt_CODE IN(@Lc_ReceiptSourceCF_CODE,@Lc_ReceiptSourceCR_CODE)
	                                        AND c.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE)
	                                      OR(@Ac_RefundsTo_CODE = @Lc_RefundsFPI_CODE 
	                                        AND c.TypeDisburse_CODE = @Lc_DisbursementTypeRefund_CODE
	                                        AND c.CheckRecipient_CODE = @Lc_RecipientTypeFIPS_CODE)
	                                      OR(@Ac_RefundsTo_CODE = @Lc_RefundsFPU_CODE
	                                        AND c.TypeDisburse_CODE = @Lc_DisbursementTypeRothp_CODE
	                                        AND c.CheckRecipient_CODE = @Lc_RecipientTypeFIPS_CODE) 
	                                      OR(@Ac_RefundsTo_CODE = @Lc_RefundsNCP_CODE
	                                        AND r.SourceReceipt_CODE NOT IN(@Lc_ReceiptSourceCF_CODE,@Lc_ReceiptSourceCR_CODE)
	                                        AND c.CheckRecipient_CODE =@Lc_RecipientTypeCpNcp_CODE)
	                                      OR(@Ac_RefundsTo_CODE = @Lc_RefundsOTP_CODE
	                                        AND c.CheckRecipient_CODE = @Lc_RecipientTypeOTHP_CODE)
	                                    )
	                                
	                                AND (@Ac_ReasonStatus_CODE IS NULL
	                                             OR r.ReasonStatus_CODE = @Ac_ReasonStatus_CODE
	                                     )
	                          )Z 
	                    )Y
	                    WHERE (ORD_ROWNUM <= @Ai_RowTo_NUMB) 
	                       OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
	             )X
	            WHERE (ORD_ROWNUM >= @Ai_RowFrom_NUMB) 
	               OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB);
	               
	END; --END OF DSBL_RETRIEVE_S25                
	

GO
