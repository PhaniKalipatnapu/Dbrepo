/****** Object:  StoredProcedure [dbo].[PARM_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PARM_RETRIEVE_S11]  

AS

/*
 *     PROCEDURE NAME    : PARM_RETRIEVE_S11
 *     DESCRIPTION       : Retrieving the job parameter details 
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 03-AUG-2011
 *     MODIFIED BY       :  
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999';
         
      SELECT P.Job_ID, 
             P.DescriptionJob_TEXT 
      FROM PARM_Y1 P
      WHERE P.EndValidity_DATE = @Ld_High_DATE
      ORDER BY P.DescriptionJob_TEXT;  
                            
END;--End of PARM_RETRIEVE_S11


GO
