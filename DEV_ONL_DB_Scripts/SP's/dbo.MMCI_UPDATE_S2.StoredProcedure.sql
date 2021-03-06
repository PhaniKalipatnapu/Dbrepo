/****** Object:  StoredProcedure [dbo].[MMCI_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[MMCI_UPDATE_S2]      
(    
     @An_MemberMci_IDNO numeric(10, 0),    
  @Ac_MemberSex_CODE CHAR(1) ,    
  @Ac_Race_CODE CHAR(2) ,    
  @Ad_Birth_DATE date ,    
  @Ac_MaritalStatus_CODE CHAR(2) ,    
  @Ac_Religion_CODE CHAR(2) ,    
  @An_MemberSsn_NUMB numeric(9, 0) ,    
  @An_County_IDNO numeric(3,0),    
  @Ac_CitizenShip_CODE CHAR(1),    
  @Ac_School_CODE CHAR(5) ,    
  @Ad_Deceased_DATE  date ,    
  @Ac_BirthIndicator_CODE CHAR(3) ,    
  @As_Line1_ADDR varCHAR(50) ,    
  @As_Line2_ADDR varCHAR(50) ,    
  @Ac_City_ADDR CHAR(28) ,    
  @Ac_ApartmentNumber_ADDR CHAR(5) ,    
  @Ac_Zip_ADDR CHAR(10) ,    
  @Ac_ZipSuffix_ADDR CHAR(10) ,    
  @Ac_State_ADDR CHAR(2) ,    
  @An_HomePhone_NUMB  numeric(15, 0)    
           
         
         
     )                
AS    
    
/*    
 *     PROCEDURE NAME    : MMCI_UPDATE_S2    
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
     SET   
    MemberSex_CODE=ISNULL(@Ac_MemberSex_CODE,MemberSex_CODE),    
    Race_CODE=ISNULL(@Ac_Race_CODE,Race_CODE),    
    Birth_DATE=ISNULL(@Ad_Birth_DATE,Birth_DATE),    
    MaritalStatus_CODE=ISNULL(@Ac_MaritalStatus_CODE,MaritalStatus_CODE),    
    Religion_CODE=ISNULL(@Ac_Religion_CODE,Religion_CODE),    
    MemberSsn_NUMB=ISNULL(@An_MemberSsn_NUMB,MemberSsn_NUMB),    
    County_IDNO=ISNULL(@An_County_IDNO,County_IDNO),    
    CitizenShip_CODE=ISNULL(@Ac_CitizenShip_CODE,CitizenShip_CODE),    
    School_CODE=ISNULL(@Ac_School_CODE,School_CODE),    
    Deceased_DATE=ISNULL(@Ad_Deceased_DATE,Deceased_DATE),    
    BirthIndicator_CODE=ISNULL(@Ac_BirthIndicator_CODE,BirthIndicator_CODE),    
    Line1_ADDR=ISNULL(@As_Line1_ADDR,Line1_ADDR),    
    Line2_ADDR=ISNULL(@As_Line2_ADDR,Line2_ADDR),    
    City_ADDR=ISNULL(@Ac_City_ADDR,City_ADDR),    
    ApartmentNumber_ADDR=ISNULL(@Ac_ApartmentNumber_ADDR,ApartmentNumber_ADDR),    
    Zip_ADDR=ISNULL(@Ac_Zip_ADDR,Zip_ADDR),    
    ZipSuffix_ADDR=ISNULL(@Ac_ZipSuffix_ADDR,ZipSuffix_ADDR),    
    State_ADDR=ISNULL(@Ac_State_ADDR,State_ADDR),    
    HomePhone_NUMB=ISNULL(@An_HomePhone_NUMB,HomePhone_NUMB),    
    Update_DTTM = @Ld_Current_DATE    
  
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO;    
        
 END; --End of PLIC_INSERT_S1.       



GO
