/****** Object:  StoredProcedure [dbo].[MMCI_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[MMCI_UPDATE_S1]      
(    
 @An_MemberMci_IDNO numeric(10, 0),    
 @Ac_Last_NAME CHAR(20) ,    
 @Ac_First_NAME CHAR(16) ,    
 @Ac_Middle_NAME CHAR(20) ,    
 @Ac_Suffix_NAME CHAR(4)                          
)                
AS    
    
/*    
 *     PROCEDURE NAME    : MMCI_UPDATE_S1    
 *     DESCRIPTION       : Insert mci information into mci table.    
 *     DEVELOPED BY      : IMP Team.    
 *     DEVELOPED ON      : 04-AUG-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
*/    
    
   BEGIN    
       
   DECLARE    
 @Ld_High_DATE  DATE ='12/31/9999',    
 @Ld_Current_DATE  DATE = getdate(),--dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),    
 @Li_Zero_NUMB    SMALLINT=0,    
 @Lc_Space_TEXT   CHAR(1)=' ';  
        
       
          
      UPDATE MMCI_Y1  
            SET Last_NAME = ISNULL(@Ac_Last_NAME,  Last_NAME),  
             First_NAME = ISNULL(@Ac_First_NAME, First_NAME ),  
             Middle_NAME = ISNULL(@Ac_Middle_NAME,  Middle_NAME),  
             Suffix_NAME = ISNULL(@Ac_Suffix_NAME,  Suffix_NAME),  
             FullDisplay_NAME = (    
          LTRIM (RTRIM (ISNULL(@Ac_Last_NAME, Last_NAME))) +    
          (    
           CASE WHEN LTRIM (RTRIM (ISNULL(@Ac_Suffix_NAME, Suffix_NAME))) = '' THEN     
           ''     
           ELSE ' '     
           END    
          ) +    
          LTRIM (RTRIM (ISNULL(@Ac_Suffix_NAME, Suffix_NAME))) + ', ' +    
          LTRIM (RTRIM (ISNULL(@Ac_First_NAME, First_NAME))) + ' ' +     
          LTRIM (RTRIM (ISNULL(@Ac_Middle_NAME, Middle_NAME)))    
         ),  
             Update_DTTM = @Ld_Current_DATE    
             WHERE MemberMci_IDNO = @An_MemberMci_IDNO    
        
 END; --End of PLIC_INSERT_S1.      -- SELECT * FROM MMCI_Y1  



GO
