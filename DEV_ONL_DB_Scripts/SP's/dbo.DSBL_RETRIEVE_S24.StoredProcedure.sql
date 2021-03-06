/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S24](
 @Ad_From_DATE	DATE, 
 @Ad_To_DATE  	DATE
 )      
 
AS

/*  
 *     PROCEDURE NAME    : DSBL_RETRIEVE_S24
 *     DESCRIPTION       : Retrieve all the refunds processed for the specified date range. 
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
           @Lc_RecipientTypeOTHP_CODE		CHAR(1) = '3',
           @Lc_ReceiptSourceCF_CODE         CHAR(2) = 'CF',     
           @Lc_ReceiptSourceCR_CODE         CHAR(2) = 'CR', 
           @Lc_DisbursementTypeRefund_CODE	CHAR(5) = 'REFND', 
           @Lc_DisbursementTypeRothp_CODE 	CHAR(5) = 'ROTHP',
           @Lc_CheckRecipient_NUMB		    CHAR(9) = '999999900';

	SELECT  Cp_AMNT,
			Ncp_AMNT,
            Othp_AMNT, 
            FipsIdentified_AMNT, 
            FipsUnidentified_AMNT, 
            AgencyIdentified_AMNT,
            AgencyUnidentified_AMNT,
            TotCount_NUMB,
         	(Cp_AMNT + Ncp_AMNT + Othp_AMNT + FipsIdentified_AMNT + FipsUnidentified_AMNT + AgencyIdentified_AMNT + AgencyUnidentified_AMNT )AS Sum_AMNT,
         	SUM (Cp_AMNT) OVER() AS CpTot_AMNT,
         	SUM (Ncp_AMNT) OVER () AS NcpTot_AMNT, 
         	SUM (Othp_AMNT) OVER ()AS OthpTot_AMNT,
         	SUM (FipsIdentified_AMNT) OVER () AS FipsIdentifiedTot_AMNT,
         	SUM (FipsUnidentified_AMNT) OVER () AS FipsUnidentifiedTot_AMNT,
         	SUM (AgencyIdentified_AMNT) OVER() AS AgencyIdentifiedTot_AMNT,
            SUM (AgencyUnidentified_AMNT) OVER() AS AgencyUnidentifiedTot_AMNT,
         	SUM (TotCount_NUMB) OVER () AS SumTotCount_NUMB,
         	SUM (Cp_AMNT + Ncp_AMNT + Othp_AMNT + FipsIdentified_AMNT + FipsUnidentified_AMNT + AgencyIdentified_AMNT + AgencyUnidentified_AMNT ) OVER ()AS SumTot_AMNT
     FROM(SELECT ISNULL(SUM (Cp_AMNT), @Li_Zero_NUMB) AS Cp_AMNT,
     			 ISNULL(SUM (Ncp_AMNT), @Li_Zero_NUMB) AS Ncp_AMNT,
          		 ISNULL(SUM (Othp_AMNT), @Li_Zero_NUMB) AS Othp_AMNT,
          		 ISNULL(SUM (FipsIdentified_AMNT), @Li_Zero_NUMB) AS FipsIdentified_AMNT,
          		 ISNULL(SUM (FipsUnidentified_AMNT), @Li_Zero_NUMB) AS FipsUnidentified_AMNT,
          		 ISNULL(SUM (AgencyIdentified_AMNT), @Li_Zero_NUMB) AS AgencyIdentified_AMNT,
          		 ISNULL(SUM (AgencyUnidentified_AMNT), @Li_Zero_NUMB) AS AgencyUnidentified_AMNT,
          		 COUNT (1) AS TotCount_NUMB
       FROM (SELECT CASE WHEN c.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
       						AND	c.SourceReceipt_CODE IN(@Lc_ReceiptSourceCF_CODE,@Lc_ReceiptSourceCR_CODE)
                             THEN c.Disburse_AMNT
                         ELSE @Li_Zero_NUMB
                    END Cp_AMNT,       
       
       				CASE WHEN c.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
       				        AND	c.SourceReceipt_CODE NOT IN(@Lc_ReceiptSourceCF_CODE,@Lc_ReceiptSourceCR_CODE) 
                             THEN c.Disburse_AMNT
                         ELSE @Li_Zero_NUMB
                    END Ncp_AMNT,
                                                         
                    CASE WHEN c.CheckRecipient_CODE = @Lc_RecipientTypeOTHP_CODE
                           AND c.TypeDisburse_CODE IN ( @Lc_DisbursementTypeRefund_CODE, @Lc_DisbursementTypeRothp_CODE )
                           AND c.CheckRecipient_ID <= @Lc_CheckRecipient_NUMB
                            THEN c.Disburse_AMNT
                         ELSE @Li_Zero_NUMB
                    END Othp_AMNT,
                    
                    CASE WHEN c.CheckRecipient_CODE = @Lc_RecipientTypeFIPS_CODE
                           AND c.TypeDisburse_CODE = @Lc_DisbursementTypeRefund_CODE
                            THEN c.Disburse_AMNT
                         ELSE @Li_Zero_NUMB
                    END FipsIdentified_AMNT,
                    
                    CASE WHEN c.CheckRecipient_CODE = @Lc_RecipientTypeFIPS_CODE  
                            AND c.TypeDisburse_CODE = @Lc_DisbursementTypeRothp_CODE
                                THEN c.Disburse_AMNT
                          ELSE @Li_Zero_NUMB
                    END FipsUnidentified_AMNT,
                    
                    CASE WHEN c.CheckRecipient_CODE = @Lc_RecipientTypeOTHP_CODE
                           AND c.TypeDisburse_CODE =  @Lc_DisbursementTypeRefund_CODE
                           AND c.CheckRecipient_ID > @Lc_CheckRecipient_NUMB
                            THEN c.Disburse_AMNT
                         ELSE @Li_Zero_NUMB
                    END AgencyIdentified_AMNT,
                    
                    CASE WHEN c.CheckRecipient_CODE = @Lc_RecipientTypeOTHP_CODE
                           AND c.TypeDisburse_CODE =  @Lc_DisbursementTypeRothp_CODE
                           AND c.CheckRecipient_ID > @Lc_CheckRecipient_NUMB
                            THEN c.Disburse_AMNT
                         ELSE @Li_Zero_NUMB
                    END AgencyUnidentified_AMNT
                                   
             FROM (SELECT mt.TypeDisburse_CODE,
             			  mt.CheckRecipient_ID,
             			  mt.CheckRecipient_CODE,
             			  mt.Disburse_AMNT,
             			  mt.SourceReceipt_CODE
             			  
             			      FROM (SELECT c.TypeDisburse_CODE,
                                           c.CheckRecipient_ID,
                                           c.CheckRecipient_CODE,
                                           c.Disburse_AMNT,
                                           r.SourceReceipt_CODE
                                                                                                                                                                
                                      FROM DSBL_Y1 c
                                      	JOIN GLEV_Y1 g
                                      		ON c.EventGlobalSupportSeq_NUMB = g.EventGlobalSeq_NUMB
                                      	JOIN RCTH_Y1 r
                                      		ON r.Batch_DATE = c.Batch_DATE
											   AND r.SourceBatch_CODE = c.SourceBatch_CODE
		                                       AND r.Batch_NUMB = c.Batch_NUMB
		                                       AND r.SeqReceipt_NUMB = c.SeqReceipt_NUMB
		                                       AND r.EventGlobalBeginSeq_NUMB = c.EventGlobalSupportSeq_NUMB
                                     WHERE c.Disburse_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE 
                                       AND c.TypeDisburse_CODE IN (@Lc_DisbursementTypeRefund_CODE,@Lc_DisbursementTypeRothp_CODE )
                                    ) mt
                                ) c
                           )x 
         		 )y GROUP BY y.Cp_AMNT,
         		  	 y.Ncp_AMNT,
         			 y.Othp_AMNT,
         			 y.FipsIdentified_AMNT,
         			 y.FipsUnidentified_AMNT,
         			 y.AgencyIdentified_AMNT,
         			 y.AgencyUnidentified_AMNT,
         			 y.TotCount_NUMB;
         
END; --END OF DSBL_RETRIEVE_S24         


GO
