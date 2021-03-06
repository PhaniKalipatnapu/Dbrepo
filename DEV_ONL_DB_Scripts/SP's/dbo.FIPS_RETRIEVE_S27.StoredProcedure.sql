/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S27]  (  
	 @Ac_Fips_CODE		CHAR(7)			  ,  
     @Ac_Fips_NAME		CHAR(40)	OUTPUT,
     @As_Line1_ADDR     VARCHAR(50) OUTPUT,  
     @As_Line2_ADDR     VARCHAR(50) OUTPUT,  
     @Ac_City_ADDR      CHAR(28)	OUTPUT,  
     @Ac_State_ADDR     CHAR(2)     OUTPUT,  
     @Ac_Zip_ADDR       CHAR(15)	OUTPUT 
     )  
AS  
  
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S27
  *     DESCRIPTION       : Retrieveing the FIPS Name and Address.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
   BEGIN  
  
      SELECT @Ac_Fips_NAME = NULL,
		  @As_Line1_ADDR   = NULL,   
          @As_Line2_ADDR   = NULL,   
          @Ac_City_ADDR    = NULL,   
          @Ac_State_ADDR   = NULL,   
          @Ac_Zip_ADDR     = NULL;  
  
      DECLARE  
         @Ld_High_DATE               DATE = '12/31/9999',   
         @Lc_AddressSubTypeFrc_CODE  CHAR(3) = 'FRC',   
         @Lc_AddressSubTypeSdu_CODE  CHAR(3) = 'SDU',   
         @Lc_AddressTypeInt_CODE     CHAR(3) = 'INT',   
         @Lc_AddressTypeState_CODE   CHAR(3) = 'STA';  
          
        SELECT @Ac_Fips_NAME = UPPER(f.Fips_NAME),
			   @As_Line1_ADDR = F.Line1_ADDR,   
			   @As_Line2_ADDR = F.Line2_ADDR,   
			   @Ac_City_ADDR = F.City_ADDR,   
			   @Ac_State_ADDR = F.State_ADDR,   
			   @Ac_Zip_ADDR = F.Zip_ADDR  
        FROM FIPS_Y1   f  
       WHERE f.Fips_CODE = @Ac_Fips_CODE   
        AND (    (    f.TypeAddress_CODE = @Lc_AddressTypeState_CODE   
                 AND f.SubTypeAddress_CODE = @Lc_AddressSubTypeSdu_CODE)   
             OR (     f.TypeAddress_CODE = @Lc_AddressTypeInt_CODE   
                  AND f.SubTypeAddress_CODE = @Lc_AddressSubTypeFrc_CODE  
                 )  
            )   
        AND f.EndValidity_DATE = @Ld_High_DATE;  
                    
END; --END OF FIPS_RETRIEVE_S27


GO
