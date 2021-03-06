/****** Object:  StoredProcedure [dbo].[MMCI_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[MMCI_RETRIEVE_S5]    
(  
	@An_MemberMci_IDNO numeric(10, 0),  
	@Ac_Last_NAME CHAR(20) OUTPUT,
	@Ac_First_NAME CHAR(16) OUTPUT,
	@Ac_Middle_NAME CHAR(20) OUTPUT,
	@Ac_Suffix_NAME CHAR(4) OUTPUT,
	@Ad_Birth_DATE date OUTPUT,
	@Ac_MemberSex_CODE CHAR(1) OUTPUT,    
	@Ac_Race_CODE CHAR(2) OUTPUT,    
	@Ac_MaritalStatus_CODE CHAR(2) OUTPUT,    
	@Ac_FullDisplay_NAME CHAR(60) OUTPUT,  
	@An_MemberSsn_NUMB numeric(9, 0) OUTPUT,    
	@Ad_Deceased_DATE  date OUTPUT,     
	@Ac_BirthIndicator_CODE CHAR(3) OUTPUT,  
	@Ac_Religion_CODE CHAR(2) OUTPUT,    
	@Ac_CitizenShip_CODE CHAR(1) OUTPUT,   
	@Ac_School_CODE CHAR(5) OUTPUT,     
	@Ad_Update_DTTM DATE OUTPUT,
	@As_Line1_ADDR varCHAR(50) OUTPUT,    
	@As_Line2_ADDR varCHAR(50) OUTPUT,    
	@Ac_City_ADDR CHAR(28) OUTPUT,    
	@Ac_ApartmentNumber_ADDR CHAR(5) OUTPUT,    
	@An_County_IDNO numeric(3,0) OUTPUT,   
	@Ac_Zip_ADDR CHAR(10) OUTPUT,    
	@Ac_ZipSuffix_ADDR CHAR(10) OUTPUT,    
	@Ac_State_ADDR CHAR(2) OUTPUT,    
	@An_HomePhone_NUMB  numeric(10) OUTPUT 
)              
AS  
  
/*  
 *     PROCEDURE NAME    : MMCI_RETRIEVE_S5  
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
        	@Ac_Last_NAME = Last_NAME,
			@Ac_First_NAME = First_NAME,
			@Ac_Middle_NAME = Middle_NAME,
			@Ac_Suffix_NAME = Suffix_NAME,
			@Ad_Birth_DATE = Birth_DATE,
			@Ac_MemberSex_CODE = MemberSex_CODE,
			@Ac_Race_CODE = Race_CODE,
			@Ac_MaritalStatus_CODE = MaritalStatus_CODE,
			@Ac_FullDisplay_NAME = FullDisplay_NAME,
			@An_MemberSsn_NUMB = MemberSsn_NUMB,
			@Ad_Deceased_DATE = Deceased_DATE,
			@Ac_BirthIndicator_CODE = BirthIndicator_CODE,
			@Ac_Religion_CODE = Religion_CODE,
			@Ac_CitizenShip_CODE = CitizenShip_CODE,
			@Ac_School_CODE = School_CODE,
			@Ad_Update_DTTM = Update_DTTM,
			@As_Line1_ADDR = Line1_ADDR ,
			@As_Line2_ADDR = Line2_ADDR,
			@Ac_City_ADDR = City_ADDR,
			@Ac_ApartmentNumber_ADDR = ApartmentNumber_ADDR,
			@An_County_IDNO = County_IDNO,
			@Ac_Zip_ADDR = Zip_ADDR,
			@Ac_ZipSuffix_ADDR = ZipSuffix_ADDR,
			@Ac_State_ADDR = State_ADDR,
			@An_HomePhone_NUMB = HomePhone_NUMB
         From MMCI_Y1  
         Where   
  MemberMci_IDNO    =  @An_MemberMci_IDNO      
      
 END; -- SP_HELPTEXT MMCI_INSERT_S1
  
 
GO
