/****** Object:  StoredProcedure [dbo].[FORM_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FORM_RETRIEVE_S8] (
@Ac_Notice_ID     CHAR(8),
@Ai_Count_QNTY    INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : FORM_RETRIEVE_S8  
  *     DESCRIPTION       : Retrieve the record count for the Notice ID to check whether filenet document is linked or not.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 22-JUN-2012  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;
    
  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM FORM_Y1          
   WHERE FORM_Y1.Notice_ID = @Ac_Notice_ID
 END; --End of FORM_RETRIEVE_S8  


GO
