/****** Object:  StoredProcedure [dbo].[MMCI_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[MMCI_RETRIEVE_S4]    
(  
     @An_MemberMci_IDNO numeric(10, 0),  
     @Ad_Update_DTTM Datetime2 OUTPUT       
)              
AS  
  
/*  
 *     PROCEDURE NAME    : MMCI_RETRIEVE_S4  
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
       
Select        
        @Ad_Update_DTTM = Update_DTTM    
          
         From MMCI_Y1  
         Where   
  MemberMci_IDNO    =  @An_MemberMci_IDNO      
      
 END; --End of PLIC_INSERT_S1.select * from mmci_y1   



GO
