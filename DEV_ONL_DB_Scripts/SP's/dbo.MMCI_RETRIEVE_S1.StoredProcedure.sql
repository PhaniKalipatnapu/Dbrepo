/****** Object:  StoredProcedure [dbo].[MMCI_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MMCI_RETRIEVE_S1]        
(      
     @An_MemberMci_IDNO numeric(10, 0),      
  @Ac_Last_NAME varCHAR(60) ,      
  @Ac_MemberSex_CODE CHAR(1) ,      
  @Ac_Race_CODE CHAR(2) ,      
  @Ad_Birth_DATE date ,       
  @An_MemberSsn_NUMB numeric(9, 0)      
  --@An_MemberMci_IDNO  numeric(10, 0) OUTPUT         
           
     )                  
AS      
      
/*      
 *     PROCEDURE NAME    : MMCI_RETRIEVE_S1      
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
         
          
           
Select      [FullDisplay_NAME]                
           ,[MemberSex_CODE]      
           ,[Race_CODE]      
           ,[BirthIndicator_CODE]      
           ,[Birth_DATE]      
           ,[Deceased_DATE]      
           ,MemberMci_IDNO      
           ,[MemberSsn_NUMB]      
           ,[Line1_ADDR]      
           ,[Line2_ADDR]      
           ,[Zip_ADDR]      
           ,[ZipSuffix_ADDR]      
         From MMCI_Y1      
         Where       
    MemberMci_IDNO    =  ISNULL(@An_MemberMci_IDNO,MemberMci_IDNO)   AND       
    (@Ac_Last_NAME IS NULL OR   
    @Ac_Last_NAME LIKE RTRIM(Last_NAME) + '%') AND  
   -- Last_NAME         LIKE  ISNULL(@Ac_Last_NAME ,  Last_NAME    )  AND      
    MemberSex_CODE    =  ISNULL(@Ac_MemberSex_CODE , MemberSex_CODE)  AND      
    Race_CODE         =  ISNULL(@Ac_Race_CODE   ,  Race_CODE   )  AND      
    Birth_DATE        =  ISNULL(@Ad_Birth_DATE  ,   Birth_DATE )      AND      
    MemberSsn_NUMB    =  ISNULL(@An_MemberSsn_NUMB ,   MemberSsn_NUMB)          
          
 END; --End of PLIC_INSERT_S1.select * from mmci_y1          
GO
