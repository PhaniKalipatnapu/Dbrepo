/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S43]  (
     @Ac_FipsFilter_CODE CHAR(7) ,
     @Ac_State_CODE      CHAR(2)     OUTPUT,
     @Ac_Fips_CODE		 CHAR(7)	 OUTPUT,
     @Ac_Fips_NAME		 CHAR(40)	 OUTPUT
      )
AS

/*
 *     PROCEDURE NAME    : FIPS_RETRIEVE_S43
 *     DESCRIPTION       : Retrieves the State code and Fips Name for the given Fips Code.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/30/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

   BEGIN

      SELECT @Ac_Fips_CODE    = NULL,
             @Ac_Fips_NAME    = NULL,
             @Ac_State_CODE   = NULL;

      DECLARE
         @Ld_High_DATE                   DATE    = '12/31/9999', 
         @Lc_TypeAddressInterstate_CODE  CHAR(3) = 'INT',
         @Lc_SubTypeAddressFrc_CODE      CHAR(3) = 'FRC',
         @Lc_TypeAddressTribal_CODE	     CHAR(3) = 'TRB',
         @Lc_SubTypeAddressT01_CODE      CHAR(3) = 'T01',
         @Lc_TypeAddressState_CODE       CHAR(3) = 'STA',
         @Lc_SubTypeAddressCrg_CODE      CHAR(3) = 'CRG';
          
		  
        
        SELECT @Ac_Fips_CODE  = F.Fips_CODE, 
			   @Ac_Fips_NAME  = F.Fips_NAME,
			   @Ac_State_CODE = S.State_CODE 
          FROM FIPS_Y1 F
          LEFT OUTER JOIN STAT_Y1 S
            ON S.StateFips_CODE           = SUBSTRING(F.Fips_CODE, 1, 2)
		 WHERE ((F.TypeAddress_CODE        = @Lc_TypeAddressInterstate_CODE 
				AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE) 
			OR (F.TypeAddress_CODE        = @Lc_TypeAddressTribal_CODE 
			   AND F.SubTypeAddress_CODE  = @Lc_SubTypeAddressT01_CODE)
			OR (F.TypeAddress_CODE        = @Lc_TypeAddressState_CODE 
			   AND F.SubTypeAddress_CODE  = @Lc_SubTypeAddressCrg_CODE)) 
		   AND F.EndValidity_DATE         = @Ld_High_DATE 
		   AND F.Fips_CODE                = @Ac_FipsFilter_CODE
      ORDER BY F.Fips_CODE,F.Fips_NAME;
END--END FIPS_RETRIEVE_S43


GO
