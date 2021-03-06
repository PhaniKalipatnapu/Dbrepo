/****** Object:  StoredProcedure [dbo].[UNOT_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UNOT_RETRIEVE_S4](                                         
     @An_EventGlobalSeq_NUMB		 NUMERIC(19),           
     @As_DescriptionNote_TEXT        VARCHAR(4000) OUTPUT
     )
AS                                                                            
/*                                                                            
 *     PROCEDURE NAME   : UNOT_RETRIEVE_S4                                    
 *     DESCRIPTION      : This function is used to get the log notes for the given sequence event global.                                                  
 *     DEVELOPED BY     : IMP Team                                         
 *     DEVELOPED ON     : 12/10/2011                                      
 *     MODIFIED BY      :                                                    
 *     MODIFIED ON      :                                                    
 *     VERSION NO       : 1                                                  
 */                                                                            
   BEGIN                                                                      
      SET @As_DescriptionNote_TEXT = NULL;                                            

      SELECT @As_DescriptionNote_TEXT = UN.DescriptionNote_TEXT                     
        FROM UNOT_Y1  UN                                                     
       WHERE UN.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;                    
                                                                              
END; --End Of Procedure UNOT_RETRIEVE_S4                                                                            
                                                                              

GO
