/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S31]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S31] (
 @Ac_Fips_CODE      CHAR(7),
 @Ac_StateFips_CODE CHAR(2),
 @Ac_Fips_NAME      CHAR(40) OUTPUT,
 @Ac_State_ADDR     CHAR(2) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S31
  *     DESCRIPTION       : Retrieving the State and Fips name
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_State_ADDR = NULL,
         @Ac_Fips_NAME = NULL;

  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_SubTypeAddressSdu_CODE CHAR(3) = 'SDU',
          @Lc_TypeAddressState_CODE  CHAR(3) = 'STA',
          @Lc_Fips_CODE              CHAR(6) = '00000',
		  @Li_Three_NUMB             SMALLINT = 3,
		  @Li_Seven_NUMB             SMALLINT = 7;

  SELECT @Ac_Fips_NAME = F.Fips_NAME,
         @Ac_State_ADDR = F.State_ADDR
    FROM FIPS_Y1 F
   WHERE F.Fips_CODE = @Ac_Fips_CODE
     AND (SUBSTRING (@Ac_Fips_CODE, @Li_Three_NUMB, @Li_Seven_NUMB) = @Lc_Fips_CODE
          AND F.TypeAddress_CODE = @Lc_TypeAddressState_CODE
          AND SubTypeAddress_CODE = @Lc_SubTypeAddressSdu_CODE)
     AND (@Ac_StateFips_CODE IS NULL
           OR (@Ac_StateFips_CODE IS NOT NULL
               AND F.StateFips_CODE = @Ac_StateFips_CODE))
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; --END of FIPS_RETRIEVE_S31

GO
