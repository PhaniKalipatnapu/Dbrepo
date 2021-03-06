/****** Object:  StoredProcedure [dbo].[UCAT_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UCAT_RETRIEVE_S5](
 @Ai_RowFrom_NUMB	INT=1, 
 @Ai_RowTo_NUMB		INT=10             
)
AS                                                           

/* 
 *     PROCEDURE NAME    : UCAT_RETRIEVE_S5
 *     DESCRIPTION       : Retrieveing the attributes Of Un-Distributed Collections codes.
 *     DEVELOPED BY      : IMP Team   
 *     DEVELOPED ON      : 03-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

  DECLARE @Ld_High_DATE	DATE = '12/31/9999';
        
  SELECT Y.Udc_CODE , 
         Y.TransactionEventSeq_NUMB,  
         Y.HoldLevel_CODE , 
         Y.Initiate_CODE , 
         Y.NumDaysHold_QNTY , 
         Y.Hold_AMNT , 
         Y.NumDaysRefund_QNTY , 
         Y.ManualBackOut_INDC , 
         Y.ManualRelease_INDC , 
         Y.AutomaticRelease_INDC , 
         Y.ManualRefund_INDC , 
         Y.AutomaticRefund_INDC, 
         Y.ExtendResearch_INDC , 
         Y.ErDuration_QNTY , 
         Y.NumUdcLine_IDNO ,  
         Y.Alert_INDC , 
         Y.AlertDuration_QNTY,
         Y.RowCount_NUMB 
      FROM(SELECT X.Udc_CODE, 
                  X.HoldLevel_CODE, 
                  X.Initiate_CODE, 
                  X.NumDaysHold_QNTY, 
                  X.ManualRelease_INDC, 
                  X.AutomaticRelease_INDC, 
                  X.ManualRefund_INDC, 
                  X.AutomaticRefund_INDC, 
                  X.NumDaysRefund_QNTY, 
                  X.ExtendResearch_INDC, 
                  X.ErDuration_QNTY, 
                  X.Alert_INDC, 
                  X.AlertDuration_QNTY, 
                  X.NumUdcLine_IDNO, 
                  X.Hold_AMNT, 
                  X.ManualBackOut_INDC, 
                  X.RowCount_NUMB, 
                  X.TransactionEventSeq_NUMB, 
                  X.Row_NUMB 
      FROM(SELECT a.Udc_CODE, 
                  a.HoldLevel_CODE, 
                  a.Initiate_CODE, 
                  a.NumDaysHold_QNTY, 
                  a.ManualRelease_INDC, 
                  a.AutomaticRelease_INDC, 
                  a.ManualRefund_INDC, 
                  a.AutomaticRefund_INDC, 
                  a.NumDaysRefund_QNTY, 
                  a.ExtendResearch_INDC, 
                  a.ErDuration_QNTY , 
                  a.Alert_INDC, 
                  a.AlertDuration_QNTY, 
                  a.NumUdcLine_IDNO, 
                  a.Hold_AMNT, 
                  a.ManualBackOut_INDC, 
                  COUNT(1) OVER() AS RowCount_NUMB, 
                  a.TransactionEventSeq_NUMB, 
                  ROW_NUMBER() OVER(
                        ORDER BY a.Udc_CODE) AS Row_NUMB
               FROM UCAT_Y1 a
             WHERE a.EndValidity_DATE = @Ld_High_DATE
               )  X
            WHERE X.Row_NUMB <= @Ai_RowTo_NUMB
         )  Y
      WHERE Y.Row_NUMB >= @Ai_RowFrom_NUMB
ORDER BY Row_NUMB;
                  
END--End Of UCAT_RETRIEVE_S5


GO
