/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S29] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*                                                                            
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S29                                   
  *     DESCRIPTION       : Checks whether a member exist in demo.
  *     DEVELOPED BY      : IMP Team                                         
  *     DEVELOPED ON      : 16-AUG-2011                                        
  *     MODIFIED BY       :                                                    
  *     MODIFIED ON       :                                                    
  *     VERSION NO        : 1                                                  
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DEMO_Y1 D
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; --End Of DEMO_RETRIEVE_S29                                                                           

GO
