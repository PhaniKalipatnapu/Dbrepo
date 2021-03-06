/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S148]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S148](
 @Ad_Batch_DATE               DATE,
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19)
 )
AS
 /*                                                                    
  *    PROCEDURE NAME    : RCTH_RETRIEVE_S148                          
  *    DESCRIPTION       : This Procedure populates the data for 'Receipts on Hold Details ' pop up.
                           This pop up displays the  Receipts on Hold Details pop-up view displays all
                           receipts on hold associated with the Case ID entered for inquiry.                                          
  *    DEVELOPED BY      : IMP Team                                 
  *    DEVELOPED ON      : 30/11/2011                              
  *    MODIFIED BY       :                                            
  *    MODIFIED ON       :                                            
  *    VERSION NO        : 1                                          
  */
 BEGIN
  SELECT r.Case_IDNO,
         r.Receipt_DATE,
         r.TaxJoint_CODE,
         r.ReasonStatus_CODE,
         r.ToDistribute_AMNT AS Receipt_AMNT,
         g.Worker_ID,
         n.DescriptionNote_TEXT
    FROM RCTH_Y1 r
         JOIN GLEV_Y1 g
      ON r.EventGlobalBeginSeq_NUMB = g.EventGlobalSeq_NUMB
         LEFT OUTER JOIN UNOT_Y1 n
      ON n.EventGlobalSeq_NUMB = r.EventGlobalBeginSeq_NUMB
   WHERE r.Batch_DATE = @Ad_Batch_DATE
     AND r.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB;
     
 END; --End Of Procedure RCTH_RETRIEVE_S148


GO
