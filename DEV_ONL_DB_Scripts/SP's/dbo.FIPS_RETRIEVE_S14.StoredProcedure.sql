/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S14] (  
 @Ac_StateFips_CODE    CHAR(2),  
 @Ac_TypeAddress_CODE  CHAR(3) OUTPUT,  
 @Ac_StateFipsOut_CODE CHAR(2) OUTPUT,  
 @Ac_State_ADDR        CHAR(2) OUTPUT,  
 @As_State_NAME        VARCHAR(60) OUTPUT  
 )  
AS  
 /*  
  * PROCEDURE NAME     : FIPS_RETRIEVE_S14  
  *  DESCRIPTION       : Retrieves State details of only the first record for a given State with specified addresses   
  *  DEVELOPED BY      : IMP Team  
  *  DEVELOPED ON      : 09-AUG-2011  
  *  MODIFIED BY       :   
  *  MODIFIED ON       :   
  *  VERSION NO        : 1  
 */  
 BEGIN  
  SELECT @Ac_StateFipsOut_CODE = NULL,  
         @As_State_NAME = NULL,  
         @Ac_TypeAddress_CODE = NULL,  
         @Ac_State_ADDR = NULL;  
  
  DECLARE @Ld_High_DATE              DATE = '12/31/9999',  
          @Lc_SubTypeAddressC01_CODE CHAR(3) = 'C01',  
          @Lc_SubTypeAddressFrc_CODE CHAR(3) = 'FRC',  
          @Lc_SubTypeAddressIvd_CODE CHAR(3) = 'IVD', 
          @Lc_SubTypeAddressT01_CODE CHAR(3) = 'T01',  
          @Lc_TypeAddressInt_CODE    CHAR(3) = 'INT',  
          @Lc_TypeAddressLoc_CODE    CHAR(3) = 'LOC',  
          @Lc_TypeAddressSta_CODE    CHAR(3) = 'STA',
          @Lc_TypeAddressTrb_CODE    CHAR(3) = 'TRB';  
  
  SELECT DISTINCT TOP 1 @Ac_StateFipsOut_CODE = F.StateFips_CODE,  
         @As_State_NAME = S.State_NAME,  
         @Ac_TypeAddress_CODE = F.TypeAddress_CODE,  
         @Ac_State_ADDR = F.State_ADDR  
    FROM FIPS_Y1 F  
         JOIN STAT_Y1 S  
          ON F.StateFips_CODE = S.StateFips_CODE  
   WHERE ((F.TypeAddress_CODE = @Lc_TypeAddressLoc_CODE  
           AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressC01_CODE)  
           OR (F.TypeAddress_CODE = @Lc_TypeAddressSta_CODE  
               AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressIvd_CODE)  
           OR (F.TypeAddress_CODE = @Lc_TypeAddressInt_CODE  
               AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE)
           OR( F.TypeAddress_CODE = @Lc_TypeAddressTrb_CODE  
               AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressT01_CODE ) )  
     AND F.StateFips_CODE = @Ac_StateFips_CODE  
     AND F.EndValidity_DATE = @Ld_High_DATE;  
 END; -- END OF FIPS_RETRIEVE_S14  
  

GO
