/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S26]  
(
     @Ac_Fips_CODE		 CHAR(7),
     @Ac_Fips_NAME       CHAR(40)    OUTPUT,
     @Ac_State_ADDR		 CHAR(2)	 OUTPUT
 )
AS
/*
*     PROCEDURE NAME    : FIPS_RETRIEVE_S26
*     DESCRIPTION       : Retrieves State Address and Fips Name for the given Fips Code
*     DEVELOPED BY      : IMP Team
*     DEVELOPED ON      : 02-AUG-2011
*     MODIFIED BY       : 
*     MODIFIED ON       : 
*     VERSION NO        : 1
*/BEGIN
	SELECT @Ac_Fips_NAME = NULL,
		@Ac_State_ADDR = NULL;
	
	DECLARE
         @Ld_High_DATE               DATE = '12/31/9999', 
         @Lc_SubTypeAddressCol_CODE  CHAR(3) = 'COL', 
         @Lc_SubTypeAddressFrc_CODE  CHAR(3) = 'FRC', 
         @Lc_SubTypeAddressSdu_CODE  CHAR(3) = 'SDU', 
         @Lc_TypeAddressInt_CODE     CHAR(3) = 'INT', 
         @Lc_TypeAddressLocate_CODE  CHAR(3) = 'LOC', 
         @Lc_TypeAddressState_CODE   CHAR(3) = 'STA';
        
      SELECT TOP 1  @Ac_Fips_NAME = F.Fips_NAME,
				   @Ac_State_ADDR = F.State_ADDR
      FROM FIPS_Y1 F
      WHERE F.Fips_CODE = @Ac_Fips_CODE 
      AND ((F.TypeAddress_CODE = @Lc_TypeAddressState_CODE 
      AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressSdu_CODE) 
      OR (F.TypeAddress_CODE = @Lc_TypeAddressLocate_CODE 
      AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressCol_CODE) 
      OR (F.TypeAddress_CODE = @Lc_TypeAddressInt_CODE 
      AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE)) 
      AND F.EndValidity_DATE = @Ld_High_DATE;

                  
END;--End of FIPS_RETRIEVE_S26	


GO
