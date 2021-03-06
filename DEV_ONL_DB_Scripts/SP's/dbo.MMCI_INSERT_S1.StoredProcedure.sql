/****** Object:  StoredProcedure [dbo].[MMCI_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MMCI_INSERT_S1]      
(    
     --@An_MemberMci_IDNO numeric(10, 0),    
  @Ac_Last_NAME CHAR(20) ,    
  @Ac_First_NAME CHAR(16) ,    
  @Ac_Middle_NAME CHAR(20) ,    
  @Ac_Suffix_NAME CHAR(4) ,     
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
  @An_HomePhone_NUMB  numeric(10, 0) ,    
  @An_MemberMci_IDNO  numeric(10, 0) OUTPUT    
  --@Ad_Update_DTTM datetime2(7)                
         
         
     )                
AS    
    
/*    
 *     PROCEDURE NAME    : MMCI_INSERT_S1    
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
 @Lc_Space_TEXT   CHAR(1)=' ',    
       
   @Ac_FullDisplay_NAME varCHAR(60) = (    
          LTRIM (RTRIM (@Ac_Last_NAME)) +    
          (    
           CASE WHEN LTRIM (RTRIM (@Ac_Suffix_NAME)) = '' THEN     
           ''     
           ELSE ' '     
           END    
          ) +    
          LTRIM (RTRIM (@Ac_Suffix_NAME)) + ', ' +    
          LTRIM (RTRIM (@Ac_First_NAME)) + ' ' +     
          LTRIM (RTRIM (@Ac_Middle_NAME))    
         );    
        
          
          
      INSERT [MMCI_Y1]    
           ([Last_NAME]    
           ,[First_NAME]    
           ,[Middle_NAME]    
           ,[Suffix_NAME]    
            ,[FullDisplay_NAME]    
           ,[MemberSex_CODE]    
           ,[Race_CODE]    
           ,[Birth_DATE]    
           ,[MaritalStatus_CODE]    
           ,[Religion_CODE]    
           ,[MemberSsn_NUMB]    
           ,[County_IDNO]    
           ,[CitizenShip_CODE]    
           ,[School_CODE]    
           ,[Deceased_DATE]    
           ,[BirthIndicator_CODE]    
           ,[Line1_ADDR]    
           ,[Line2_ADDR]    
           ,[City_ADDR]    
           ,[ApartmentNumber_ADDR]    
           ,[Zip_ADDR]    
           ,[ZipSuffix_ADDR]    
           ,[State_ADDR]    
           ,[HomePhone_NUMB]    
           ,[Update_DTTM])    
     VALUES    
           (    
    @Ac_Last_NAME ,     
    @Ac_First_NAME,    
    @Ac_Middle_NAME,     
    @Ac_Suffix_NAME,     
    @Ac_FullDisplay_NAME,    
    @Ac_MemberSex_CODE,     
    @Ac_Race_CODE ,    
    @Ad_Birth_DATE  ,    
    @Ac_MaritalStatus_CODE  ,    
    @Ac_Religion_CODE ,    
    @An_MemberSsn_NUMB  ,    
    @An_County_IDNO ,    
    @Ac_CitizenShip_CODE ,    
    @Ac_School_CODE  ,    
    @Ad_Deceased_DATE   ,    
    @Ac_BirthIndicator_CODE  ,    
    @As_Line1_ADDR  ,    
    @As_Line2_ADDR  ,    
    @Ac_City_ADDR  ,    
    @Ac_ApartmentNumber_ADDR ,    
    @Ac_Zip_ADDR  ,    
    @Ac_ZipSuffix_ADDR  ,    
    @Ac_State_ADDR  ,    
    @An_HomePhone_NUMB ,    
    @Ld_Current_DATE  );    
        
    SET @An_MemberMci_IDNO = @@IDENTITY;    
        
 END; --End of PLIC_INSERT_S1. 



GO
