/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S49]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S49] (
 @Ac_State_ADDR CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S49
  *     DESCRIPTION       : Retrieve state Federal Information Processing standard Code and Name for a given State federal.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_AddressTypeInt_CODE    CHAR(3) = 'INT',
          @Lc_AddressSubTypeFrc_CODE CHAR(3) = 'FRC';

  SELECT F.Fips_CODE,
         F.Fips_NAME
    FROM FIPS_Y1 F
         JOIN STAT_Y1 S
          ON S.StateFips_CODE = F.StateFips_CODE
   WHERE F.State_ADDR = @Ac_State_ADDR
     AND F.TypeAddress_CODE = @Lc_AddressTypeInt_CODE
     AND F.SubTypeAddress_CODE = @Lc_AddressSubTypeFrc_CODE
     AND F.EndValidity_DATE = @Ld_High_DATE
   ORDER BY F.Fips_NAME;
 END; -- END OF FIPS_RETRIEVE_S49



GO
