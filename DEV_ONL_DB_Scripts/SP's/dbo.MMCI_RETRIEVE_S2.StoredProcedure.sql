/****** Object:  StoredProcedure [dbo].[MMCI_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[MMCI_RETRIEVE_S2]      
(    
     @An_MemberMci_IDNO numeric(10, 0),    
     @An_MemberSsn_NUMB numeric(9, 0) ,    
  
     @Ac_Last_NAME CHAR(20) OUTPUT,    
  @Ac_First_NAME CHAR(16) OUTPUT,    
  @Ac_Middle_NAME CHAR(20) OUTPUT,    
  @Ac_Suffix_NAME CHAR(4)OUTPUT,      
  @Ad_Birth_DATE date  OUTPUT,     
  @Ac_MemberSex_CODE CHAR(1)  OUTPUT,      
  @Ac_Race_CODE CHAR(1)  OUTPUT,    
  @Ac_MaritalStatus_CODE CHAR(2)  OUTPUT    
    
         
     )                
AS    
    
/*    
 *     PROCEDURE NAME    : MMCI_RETRIEVE_S2    
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
        @Ac_Last_NAME =Last_NAME,    
  @Ac_First_NAME =First_NAME,    
  @Ac_Middle_NAME =Middle_NAME,    
  @Ac_Suffix_NAME =Suffix_NAME,      
  @Ad_Birth_DATE =Birth_DATE,     
  @Ac_MemberSex_CODE =MemberSex_CODE,      
  @Ac_Race_CODE =Race_CODE,    
  @Ac_MaritalStatus_CODE = MaritalStatus_CODE    
         From MMCI_Y1    
         Where     
    MemberMci_IDNO    =  @An_MemberMci_IDNO   AND    
    MemberSsn_NUMB = ISNULL(@An_MemberSsn_NUMB, MemberSsn_NUMB)          
        
 END; --End of PLIC_INSERT_S1.select * from mmci_y1        



GO
