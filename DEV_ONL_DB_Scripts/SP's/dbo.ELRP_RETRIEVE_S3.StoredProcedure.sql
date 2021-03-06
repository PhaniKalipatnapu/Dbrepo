/****** Object:  StoredProcedure [dbo].[ELRP_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELRP_RETRIEVE_S3]                                                             
(  
   @Ad_From_DATE			DATE,                                           
   @Ad_To_DATE				DATE,                                             
   @Ac_ReasonBackOut_CODE	CHAR(2),                                               
   @Ac_Worker_ID		 	CHAR(30),                                         
   @An_OffsetEstCnt_QNTY	NUMERIC(11)		OUTPUT,                                           
   @An_OffsetEst_AMNT       NUMERIC(11,2)	OUTPUT                                        
)
AS

/*
 *     PROCEDURE NAME    : ELRP_RETRIEVE_S3
 *     DESCRIPTION       : This procedure is used to display the Recoupments Established Count and Recoupments Established Amount details
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 
BEGIN

	DECLARE 
		@Ld_High_DATE DATE = '12/31/9999',
		@Lc_CaseRelationshipA_CODE CHAR(1) = 'A',
	 	@Lc_CaseMemberStatusA_CODE CHAR(1) = 'A',
	 	@Lc_BackOut_INDC	CHAR(1)	= 'Y',
	 	@Li_Zero_NUMB	SMALLINT	= 0;

 --13698 - RRAR - receiving Timeout Expired system error - Start 	

 SELECT	@An_OffsetEst_AMNT = ISNULL (SUM (a.PendOffset_AMNT + a.AssessOverpay_AMNT), 0)  ,
        @An_OffsetEstcnt_QNTY = COUNT (DISTINCT cast (a.Batch_DATE AS VARCHAR)
                     + cast (a.Batch_NUMB AS VARCHAR)
                     + cast (a.SeqReceipt_NUMB AS VARCHAR)
                     + cast (a.SourceBatch_CODE AS VARCHAR))              
 		FROM (SELECT a.PendOffset_AMNT,
              		 a.AssessOverpay_AMNT, 
            		 a.Batch_DATE, 
            a.Batch_NUMB,
            a.SeqReceipt_NUMB, 
            a.SourceBatch_CODE, 
            b.EventGlobalBeginSeq_NUMB
      	FROM RCTH_Y1 b 
			JOIN  POFL_Y1 a
				ON (    a.Batch_DATE = b.Batch_DATE
					AND a.SourceBatch_CODE = b.SourceBatch_CODE
					AND a.Batch_NUMB = b.Batch_NUMB
					AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
					AND a.EventGlobalSeq_NUMB = b.EventGlobalBeginSeq_NUMB
					)
      WHERE EXISTS ( SELECT 1 
						FROM ELRP_Y1 e
					  WHERE b.Batch_DATE = e.BatchOrig_DATE
						AND b.SourceBatch_CODE = e.SourceBatchOrig_CODE
						AND b.Batch_DATE = e.BatchOrig_DATE
						AND b.SeqReceipt_NUMB = e.SeqReceiptOrig_NUMB
						AND b.EventGlobalBeginSeq_NUMB = e.EventGlobalBackOutSeq_NUMB 
					)
		AND  a.Transaction_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
        AND  b.BackOut_INDC = @Lc_BackOut_INDC
        AND ISNULL(@Ac_ReasonBackOut_CODE, b.ReasonBackOut_CODE ) = b.ReasonBackOut_CODE
        AND b.EndValidity_DATE = @Ld_High_DATE
        AND a.AssessOverpay_AMNT + a.PendOffset_AMNT > @Li_Zero_NUMB) a
 WHERE @Ac_Worker_ID IS NULL
			OR   EXISTS ( SELECT 1 
						  FROM GLEV_Y1 g 
						  WHERE g.Worker_ID = @Ac_Worker_ID
						    AND a.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB
						  );

 --13698 - RRAR - receiving Timeout Expired system error - End
         
END -- END OF ELRP_RETRIEVE_S3
          
          
          


GO
