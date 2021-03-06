/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S18](
 @An_Case_IDNO           NUMERIC(6),
 @An_EventGlobalSeq_NUMB NUMERIC(19)
 )
AS
 /*                                                                                                                    
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S18                                                                           
  *     DESCRIPTION       : This Procedure is used to populate data for Financial Note History pop-up view
                            displays the tracking details and the text of a financial note or adjustment
                            request created on the NOTE screen.                                                                                           
  *     DEVELOPED BY      : IMP Team                                                                                 
  *     DEVELOPED ON      : 12/09/2011                                                                            
  *     MODIFIED BY       :                                                                                            
  *     MODIFIED ON       :                                                                                            
  *     VERSION NO        : 1                                                                                          
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT a.Subject_CODE,
         a.WorkerCreated_ID,
         a.Start_DATE,
         a.Status_CODE,
         a.WorkerAssigned_ID,
         a.Office_IDNO,
         a.Due_DATE,
         a.WorkerUpdate_ID,
         a.BeginValidity_DATE,
         a.DescriptionNote_TEXT
    FROM NOTE_Y1  a
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE;

END; --End Of Procedure NOTE_RETRIEVE_S18   


GO
