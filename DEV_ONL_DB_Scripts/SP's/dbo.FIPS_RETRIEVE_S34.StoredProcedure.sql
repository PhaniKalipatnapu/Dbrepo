/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S34] (
 @Ac_StateFips_CODE  CHAR(2),
 @Ac_CountyFips_CODE CHAR(3),
 @Ac_OfficeFips_CODE CHAR(2),
 @Ac_Fips_NAME       CHAR(40) OUTPUT,
 @As_Line1_ADDR      VARCHAR(50) OUTPUT,
 @As_Line2_ADDR      VARCHAR(50) OUTPUT,
 @Ac_City_ADDR       CHAR(28) OUTPUT,
 @Ac_State_ADDR      CHAR(2) OUTPUT,
 @Ac_Country_ADDR    CHAR(2) OUTPUT,
 @Ac_Zip_ADDR        CHAR(15) OUTPUT,
 @An_Phone_NUMB      NUMERIC(15, 0) OUTPUT,
 @An_Fax_NUMB        NUMERIC(15, 0) OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : FIPS_RETRIEVE_S34
  *     DESCRIPTION       : Retrieve FIPS Name for a FIPS Idno and Address Type.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Fips_NAME = NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_City_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @An_Phone_NUMB = NULL,
         @An_Fax_NUMB = NULL;

  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_AddressTypeLocate_CODE CHAR(3) = 'LOC',
          @Lc_AddressTypeState_CODE  CHAR(3) = 'STA',
          @Lc_CountyFipsCentral_CODE CHAR(3) = '000',
          @Lc_StateFipsUsMax_CODE    CHAR(2) = '99',
          @Lc_IntSubTypeAddress_CODE CHAR(3) = 'FRC',
          @Lc_IntTypeAddress_CODE    CHAR(3) = 'INT',
          @Lc_LocSubAddr_CODE        CHAR(3) = 'C01',
          @Lc_StaCentReg_CODE        CHAR(3) = 'CRG';

  SELECT @Ac_Fips_NAME = f.Fips_NAME,
         @As_Line1_ADDR = f.Line1_ADDR,
         @As_Line2_ADDR = f.Line2_ADDR,
         @Ac_City_ADDR = f.City_ADDR,
         @Ac_State_ADDR = f.State_ADDR,
         @Ac_Zip_ADDR = f.Zip_ADDR,
         @Ac_Country_ADDR = f.Country_ADDR,
         @An_Phone_NUMB = f.Phone_NUMB,
         @An_Fax_NUMB = f.Fax_NUMB
    FROM FIPS_Y1 f
   WHERE f.StateFips_CODE = @Ac_StateFips_CODE
     AND f.CountyFips_CODE = @Ac_CountyFips_CODE
     AND f.OfficeFips_CODE = @Ac_OfficeFips_CODE
     AND (@Ac_StateFips_CODE <= @Lc_StateFipsUsMax_CODE
          AND (@Ac_CountyFips_CODE = @Lc_CountyFipsCentral_CODE
               AND f.TypeAddress_CODE = @Lc_AddressTypeState_CODE
               AND f.SubTypeAddress_CODE = @Lc_StaCentReg_CODE)
           OR (@Ac_CountyFips_CODE <> @Lc_CountyFipsCentral_CODE
               AND f.TypeAddress_CODE = @Lc_AddressTypeLocate_CODE
               AND f.SubTypeAddress_CODE = @Lc_LocSubAddr_CODE)
           OR (@Ac_StateFips_CODE > @Lc_StateFipsUsMax_CODE
               AND f.TypeAddress_CODE = @Lc_IntTypeAddress_CODE
               AND f.SubTypeAddress_CODE = @Lc_IntSubTypeAddress_CODE))
     AND f.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF FIPS_RETRIEVE_S34

GO
