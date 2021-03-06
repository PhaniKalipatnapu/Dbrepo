/****** Object:  StoredProcedure [dbo].[APAG_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APAG_RETRIEVE_S2](
 @An_Application_IDNO NUMERIC(15),
 @An_MemberMci_IDNO   NUMERIC(10),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*                                                                                                                                         
 *     PROCEDURE NAME    : APAG_RETRIEVE_S2                                                                                                   
  *     DESCRIPTION       : Insert values in Member Demographics.                                                                           
  *     DEVELOPED BY      : IMP Team                                                                                                      
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                     
  *     MODIFIED BY       :                                                                                                                 
  *     MODIFIED ON       :                                                                                                                 
  *     VERSION NO        : 1                                                                                                               
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APAG_Y1 AG
   WHERE AG.Application_IDNO = @An_Application_IDNO
     AND AG.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; --End of APAG_RETRIEVE_S2


GO
