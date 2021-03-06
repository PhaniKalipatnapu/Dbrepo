/****** Object:  StoredProcedure [dbo].[NOST_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOST_RETRIEVE_S4]
(
 @Ac_Worker_ID  CHAR(30)
)
AS
 /*  
  *     PROCEDURE NAME    : NOST_RETRIEVE_S4  
  *     DESCRIPTION       : Retrieve the Pin text for the worker.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12/12/2011
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1.0
 */
 BEGIN
  SELECT Pin_TEXT
    FROM NOST_Y1 N
   WHERE N.Worker_ID = @Ac_Worker_ID
   UNION 
   SELECT Pin_TEXT
    FROM HNOST_Y1 N
   WHERE N.Worker_ID = @Ac_Worker_ID
   ;
 END


GO
