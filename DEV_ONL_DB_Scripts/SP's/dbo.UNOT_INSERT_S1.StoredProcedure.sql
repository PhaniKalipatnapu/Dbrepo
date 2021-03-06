/****** Object:  StoredProcedure [dbo].[UNOT_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UNOT_INSERT_S1]  (
     @An_EventGlobalSeq_NUMB		 NUMERIC(19,0),
     @An_EventGlobalApprovalSeq_NUMB		 NUMERIC(19,0),
     @As_DescriptionNote_TEXT          VARCHAR(4000) 
     ) 
AS

/*
*      PROCEDURE NAME    : UNOT_INSERT_S1
 *     DESCRIPTION       : Procedure is used to insert Note details in Unot table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
  INSERT UNOT_Y1
  	 (EventGlobalSeq_NUMB, 
  	  EventGlobalApprovalSeq_NUMB, 
  	  DescriptionNote_TEXT)
   VALUES (@An_EventGlobalSeq_NUMB, 
           @An_EventGlobalApprovalSeq_NUMB, 
           @As_DescriptionNote_TEXT);   
                 
END   --End of UNOT_INSERT_S1


GO
