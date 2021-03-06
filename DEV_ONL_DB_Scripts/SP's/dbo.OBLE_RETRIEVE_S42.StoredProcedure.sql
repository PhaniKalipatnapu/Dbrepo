/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S42]    
 (  
     @An_Case_IDNO    NUMERIC(6,0),  
     @An_OrderSeq_NUMB   NUMERIC(2,0),            
     @An_ObligationSeq_NUMB  NUMERIC(2,0)  OUTPUT  
    )  
AS  
/*  
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S42  
 *     DESCRIPTION       : Retrieve the maximum Obligation sequence number from OBLE_Y1 for Case_ID.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 19-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
   BEGIN  
  
      SET @An_ObligationSeq_NUMB = NULL;  
  
      DECLARE          @Li_Zero_NUMB SMALLINT = 0;  
      
		 SELECT @An_ObligationSeq_NUMB = ISNULL(MAX(O.ObligationSeq_NUMB), @Li_Zero_NUMB) + 1  
		  FROM OBLE_Y1 O  
		  WHERE O.Case_IDNO = @An_Case_IDNO   
		  AND   O.OrderSeq_NUMB = @An_OrderSeq_NUMB; 
    
                    
END; --END OF OBLE_RETRIEVE_S42  
  
GO
