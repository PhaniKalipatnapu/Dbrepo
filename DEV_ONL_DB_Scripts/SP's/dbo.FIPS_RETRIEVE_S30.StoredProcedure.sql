/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S30] (
 @Ac_StateFips_CODE  CHAR(2),
 @Ac_CountyFips_CODE CHAR(3),
 @Ac_OfficeFips_CODE CHAR(2),
 @Ac_Fips_NAME       CHAR(40) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S30
  *     DESCRIPTION       : Retrieving the FIPS name
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Fips_NAME = NULL;

  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_TypeAddressLocate_CODE CHAR(3) = 'LOC',
          @Lc_TypeAddressState_CODE  CHAR(3) = 'STA',
          @Lc_SubTypeAddressCo1_CODE CHAR(10) = 'C01',
          @Lc_SubTypeAddressCrg_CODE CHAR(10) = 'CRG',
          @Lc_SubTypeAddressFrc_CODE CHAR(3) = 'FRC',
          @Lc_TypeAddressInt_CODE    CHAR(3) = 'INT',
          @Lc_CountyFips_CODE        CHAR(3) = '000';

  SELECT @Ac_Fips_NAME = F.Fips_NAME
    FROM FIPS_Y1 F
   WHERE F.StateFips_CODE = @Ac_StateFips_CODE
     AND F.CountyFips_CODE = @Ac_CountyFips_CODE
     AND F.OfficeFips_CODE = @Ac_OfficeFips_CODE
     AND ((@Ac_CountyFips_CODE = @Lc_CountyFips_CODE
           AND F.TypeAddress_CODE = @Lc_TypeAddressState_CODE
           AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressCrg_CODE)
           OR (@Ac_CountyFips_CODE <> @Lc_CountyFips_CODE
               AND F.TypeAddress_CODE = @Lc_TypeAddressLocate_CODE
               AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressCo1_CODE)
           OR (F.TypeAddress_CODE = @Lc_TypeAddressInt_CODE
               AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE))
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF FIPS_RETRIEVE_S30


GO
