/****** Object:  StoredProcedure [dbo].[CHLD_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   
CREATE PROCEDURE [dbo].[CHLD_RETRIEVE_S7] (   
     @Ac_CheckRecipient_ID		CHAR(10)				,  
     @An_Sequence_NUMB		 	NUMERIC(11,0)	 OUTPUT          
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : CHLD_RETRIEVE_S7  
 *     DESCRIPTION       : Retrieves the sequence number for given check recipient id. 
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 29-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
    BEGIN  
  
      SET @An_Sequence_NUMB = NULL;  
  
      SELECT @An_Sequence_NUMB = (ISNULL(MAX(c.Sequence_NUMB), 0) + 1)  
      FROM CHLD_Y1 c 
      WHERE CheckRecipient_ID = @Ac_CheckRecipient_ID;  
  
                    
END ; --End of CHLD_RETRIEVE_S7


GO
