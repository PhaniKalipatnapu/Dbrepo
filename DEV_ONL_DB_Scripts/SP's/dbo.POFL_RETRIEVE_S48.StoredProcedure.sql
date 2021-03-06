/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S48]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S48] (                
@Ad_Transaction_DATE	DATE		,                
@Ac_Reason_CODE		    CHAR(2)		,                
@Ac_Status_CODE		    CHAR(1)		,  
@Ai_RowFrom_NUMB		INT = 1		,                
@Ai_RowTo_NUMB			INT = 10	
)                
AS                
      
/*      
 *     PROCEDURE NAME    : POFL_RETRIEVE_S48      
 *     DESCRIPTION       : Retrirve balance details for  transaction date,reason code and status code      
 *     DEVELOPED BY      : IMP Team       
 *     DEVELOPED ON      : 19-oct-2011      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
*/      
       
 BEGIN                
  DECLARE                 
    @Li_Zero_NUMB					SMALLINT = 0,
    @Li_One_NUMB					SMALLINT = 1,              
    @Lc_RecoupmentPayeeSdu_CODE		CHAR(1) = 'D',                
    @Lc_TypeRecoupmentR_CODE		CHAR(1) = 'R',                
    @Lc_RecoupmentPayeeState_CODE	CHAR(1) = 'S',                
    @Lc_StatusPending_CODE			CHAR(1) = 'P',                
    @Lc_StatusActive_CODE			CHAR(1) = 'A';
    
       SELECT      X.CheckRecipient_ID,
                   X.CheckRecipient_CODE,
                   X.Case_IDNO, 
                   X.Transaction_DATE,
                   X.PendTotOffset_AMNT, 
                   X.AssessTotOverpay_AMNT, 
                   X.RecTotOverpay_AMNT,                 
                   dbo.BATCH_COMMON_GETS$SF_GET_RECIPIENT_NAME                
                                                 (X.CheckRecipient_ID,                
                                                  X.CheckRecipient_CODE                
                                                 ) CheckRecipient_NAME,
                   g.Worker_ID,     
                   X.RowCount_NUMB        
        FROM (              
				SELECT	 Y.Reason_CODE ,
						 Y.Transaction_DATE,
						 Y.CheckRecipient_ID,                
						 Y.CheckRecipient_CODE, 
						 Y.PendTotOffset_AMNT,                
						 Y.AssessTotOverpay_AMNT, 
						 Y.RecTotOverpay_AMNT,
						 Y.Active_AMNT,                
						 Y.Case_IDNO,             
						 Y.TypeRecoupment_CODE,
						 Y.RowCount_NUMB,
						 Y.row_num,                
						 Y.EventGlobalSeq_NUMB                          
                            FROM (
									SELECT  a.Reason_CODE , 
                                         a.Transaction_DATE,
                                         a.CheckRecipient_ID,                
                                         a.CheckRecipient_CODE, 
                                         a.PendTotOffset_AMNT,                
                                         a.AssessTotOverpay_AMNT, 
                                         a.RecTotOverpay_AMNT, 
                                         a.Active_AMNT,                
                                         a.Case_IDNO,             
                                         a.TypeRecoupment_CODE,          
                                         COUNT(1) OVER() RowCount_NUMB,          
										 ROW_NUMBER () OVER (ORDER BY a.CheckRecipient_ID, a.CheckRecipient_CODE) row_num,                
                                         a.EventGlobalSeq_NUMB                
                                    FROM (SELECT z.Reason_CODE ,
                                                 z.Transaction_DATE, 
                                                 z.CheckRecipient_ID,                
												 z.CheckRecipient_CODE, 
												 z.PendTotOffset_AMNT,                
                                                 z.AssessTotOverpay_AMNT, 
                                                 z.RecTotOverpay_AMNT,                
                                                 z.Active_AMNT, 
                                                 z.Case_IDNO,                
                                                 z.RecoupmentPayee_CODE,             
                                                 z.TypeRecoupment_CODE,                
                                                 z.EventGlobalSeq_NUMB,                 
                                                 ROW_NUMBER () OVER (PARTITION BY z.CheckRecipient_ID, z.CheckRecipient_CODE, z.RecoupmentPayee_CODE, z.TypeRecoupment_CODE                
                                                 ORDER BY Unique_IDNO DESC) rnk                
											 FROM(
													SELECT DISTINCT	 p.Reason_CODE,                
														 p.Transaction_DATE,                
														 p.CheckRecipient_ID,                
														 p.CheckRecipient_CODE, 
														 p.Unique_IDNO,                
														 p.PendTotOffset_AMNT    ,                
														 p.AssessTotOverpay_AMNT,                
														 (  p.AssessTotOverpay_AMNT  - p.RecTotOverpay_AMNT ) Active_AMNT,                
														 p.Case_IDNO,
														 p.RecTotOverpay_AMNT,                
														 p.RecoupmentPayee_CODE ,                
														 p.TypeRecoupment_CODE,               
														 p.EventGlobalSeq_NUMB  
											   FROM POFL_Y1 p 
											  WHERE p.Transaction_DATE <= @Ad_Transaction_DATE
											  ) z )a 
											  WHERE rnk = @Li_One_NUMB 
											  AND (   a.PendTotOffset_AMNT > @Li_Zero_NUMB 
											       OR a.Active_AMNT >  @Li_Zero_NUMB)
											 AND (   a.TypeRecoupment_CODE <> @Lc_TypeRecoupmentR_CODE           
												   OR (    a.TypeRecoupment_CODE =  @Lc_TypeRecoupmentR_CODE       
													   AND a.RecoupmentPayee_CODE IN (@Lc_RecoupmentPayeeState_CODE ,@Lc_RecoupmentPayeeSdu_CODE )              
													  )
												 ) 
					   						 AND((	@Ac_Status_CODE = @Lc_StatusPending_CODE 
					   								 AND  (a.PendTotOffset_AMNT > @Li_Zero_NUMB )
					   								 )                
                                                 OR(	@Ac_Status_CODE = @Lc_StatusActive_CODE 
													 AND (  (a.AssessTotOverpay_AMNT - a.RecTotOverpay_AMNT) >@Li_Zero_NUMB )    
													 )
												OR  (	 @Ac_Status_CODE IS NULL
													AND (   a.PendTotOffset_AMNT != @Li_Zero_NUMB               
														OR a.AssessTotOverpay_AMNT != @Li_Zero_NUMB                 
														OR a.RecTotOverpay_AMNT != @Li_Zero_NUMB                
														) 
													)    
												)
										   AND a.Reason_CODE =ISNULL(@Ac_Reason_CODE , a.Reason_CODE ) 
												) Y 
												WHERE (row_num <= @Ai_RowTo_NUMB) 
												   OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB) 
											) X
												JOIN  GLEV_Y1 g
														ON                
															X.EventGlobalSeq_NUMB = g.EventGlobalSeq_NUMB
										WHERE ( row_num >= @Ai_RowFrom_NUMB) 
										   OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
										ORDER BY X.CheckRecipient_ID, X.CheckRecipient_CODE;
                                         
 END;	--END OF POFL_RETRIEVE_S48

GO
