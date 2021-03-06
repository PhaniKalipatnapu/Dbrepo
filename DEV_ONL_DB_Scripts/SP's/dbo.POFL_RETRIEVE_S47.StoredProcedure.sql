/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S47]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S47] (              
 @Ad_Transaction_DATE	DATE	,              
 @Ac_Reason_CODE		CHAR(2)	,              
 @Ac_Status_CODE		CHAR(1)              
 )              
 AS              
 /*      
 *     PROCEDURE NAME    : POFL_RETRIEVE_S47      
 *     DESCRIPTION       : Retrieve balance summary for transaction date,reason code 
 *     DEVELOPED BY      : IMP Team      
 *     DEVELOPED ON      : 19-OCT-2011      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
*/      
   BEGIN              
     DECLARE            
      @Lc_RecoupmentPayeeSdu_CODE	CHAR(1) = 'D',              
      @Lc_TypeRecoupmentR_CODE		CHAR(1) = 'R',              
      @Lc_RecoupmentPayeeState_CODE CHAR(1) = 'S',              
      @Lc_StatusPending_CODE		CHAR(1) = 'P',              
      @Lc_StatusActive_CODE			CHAR(1) = 'A',
      @Li_ZERO_NUMB					SMALLINT = 0 ,
      @Li_One_NUMB					SMALLINT = 1; 
    
   SELECT  ISNULL (SUM (Z.PendTotOffset_AMNT),@Li_Zero_NUMB) PendTotOffset_AMNT,              
           SUM (CASE              
                   WHEN Z.PendTotOffset_AMNT > @Li_Zero_NUMB              
                      THEN  @Li_One_NUMB          
                   ELSE @Li_Zero_NUMB             
                END) PendTotOffset_QNTY,              
           ISNULL (SUM (Z.AccessTotOverpay_AMNT), @Li_Zero_NUMB)  AccessTotOverpay_AMNT,              
           SUM (CASE              
                   WHEN Z.AccessTotOverpay_AMNT >  @Li_Zero_NUMB              
                      THEN  @Li_One_NUMB             
                   ELSE  @Li_Zero_NUMB             
                END) AccessTotOverpay_QNTY 
      FROM  (
			SELECT c.CheckRecipient_ID, 
				   c.CheckRecipient_CODE, 
				   c.Case_IDNO,              
				   c.Reason_CODE, 
				   c.Unique_IDNO, 
				   c.Transaction_DATE,              
				   c.PendTotOffset_AMNT,              
                   ISNULL ((c.AssessTotOverpay_AMNT - c.RecTotOverpay_AMNT), @Li_Zero_NUMB ) AccessTotOverpay_AMNT              
              FROM   (
		    SELECT b.CheckRecipient_ID,              
                   b.CheckRecipient_CODE, 
                   b.Case_IDNO, 
                   b.Reason_CODE,              
                   b.Unique_IDNO, 
                   b.Transaction_DATE,              
                   ISNULL (b.PendTotOffset_AMNT,  @Li_Zero_NUMB)  PendTotOffset_AMNT,              
                   ISNULL(b.AssessTotOverpay_AMNT, @Li_Zero_NUMB) AssessTotOverpay_AMNT,              
                   ISNULL (b.RecTotOverpay_AMNT,  @Li_Zero_NUMB) RecTotOverpay_AMNT,              
                   ROW_NUMBER () OVER (PARTITION BY b.CheckRecipient_ID, b.CheckRecipient_CODE             
                      ORDER BY b.Unique_IDNO DESC)  rnk              
                 FROM  (
						SELECT DISTINCT  a.CheckRecipient_ID,              
                           a.CheckRecipient_CODE, 
                           a.Case_IDNO, 
                           a.Reason_CODE,              
                           a.Unique_IDNO, 
                           a.Transaction_DATE,              
                           a.PendTotOffset_AMNT,              
                           a.AssessTotOverpay_AMNT,              
                           a.RecTotOverpay_AMNT
                           FROM POFL_Y1 a  
						  WHERE a.Transaction_DATE <=  @Ad_Transaction_DATE             
                          AND (   a.TypeRecoupment_CODE <> @Lc_TypeRecoupmentR_CODE           
                               OR (    a.TypeRecoupment_CODE =  @Lc_TypeRecoupmentR_CODE       
                                   AND a.RecoupmentPayee_CODE IN (@Lc_RecoupmentPayeeState_CODE ,@Lc_RecoupmentPayeeSdu_CODE )              
                                  )              
					)) b) c 
					WHERE rnk = @Li_One_NUMB 
				    AND  c.Reason_CODE =ISNULL(@Ac_Reason_CODE , c.Reason_CODE ) 
					AND ( ( @Ac_Status_CODE = @Lc_StatusPending_CODE              
							AND ( c.PendTotOffset_AMNT <> @Li_Zero_NUMB)
						    ) 
						 OR (  @Ac_Status_CODE = @Lc_StatusActive_CODE  
						  AND  ( ( c.AssessTotOverpay_AMNT - c.RecTotOverpay_AMNT) <> @Li_Zero_NUMB)  
						  ) 
                          OR ( @Ac_Status_CODE IS NULL
							  AND (   c.PendTotOffset_AMNT !=  @Li_Zero_NUMB               
                                   OR c.AssessTotOverpay_AMNT != @Li_Zero_NUMB               
                                   OR c.RecTotOverpay_AMNT != @Li_Zero_NUMB )  
                              )
                         )  ) z ; 
				             
 END;	--END OF POFL_RETRIEVE_S47

GO
