/****** Object:  StoredProcedure [dbo].[PARM_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PARM_RETRIEVE_S2]
AS
 /*  
 *      PROCEDURE NAME    : PARM_RETRIEVE_S2  
  *     DESCRIPTION       : Retrieve distinct Package Name.  
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT DISTINCT a.Process_NAME
    FROM PARM_Y1 a
   ORDER BY a.Process_NAME;
 END; --End of PARM_RETRIEVE_S2


GO
