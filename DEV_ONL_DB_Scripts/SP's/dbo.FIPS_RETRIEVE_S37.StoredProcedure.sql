/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S37]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S37] (
 @Ac_Fips_CODE       CHAR(7),
 @Ac_StateFips_CODE  CHAR(2),
 @Ac_CountyFips_CODE CHAR(3),
 @Ai_Count_QNTY      INT OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : FIPS_RETRIEVE_S37
  *     DESCRIPTION       : Retrieve the Row Count for a Fips Idno, Address Type, Sub Address Type, and State Fips Code thatÃ†s common between two tables.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE              DATE='12/31/9999',
          @Lc_AddressTypeLocate_CODE CHAR(3)='LOC',
          @Lc_AddressTypeState_CODE  CHAR(3)='STA',
          @Lc_CountyFipsCentral_CODE CHAR(3)='000',
          @Lc_StateFipsUsMax_CODE    CHAR(2)='99',
          @Lc_IntSubTypeAddress_CODE CHAR(3)='FRC',
          @Lc_IntTypeAddress_CODE    CHAR(3)='INT',
          @Lc_LocSubAddr_CODE        CHAR(3)='C01',
          @Lc_StaCentReg_CODE        CHAR(3)='CRG',
          @Lc_TrbTypeAddress_CODE    CHAR(3)='TRB',
          @Lc_TrbSubTypeAddress_CODE CHAR(3)='T01';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM FIPS_Y1 f
         JOIN STAT_Y1 s
          ON f.StateFips_CODE = s.StateFips_CODE
   WHERE f.Fips_CODE = @Ac_Fips_CODE
     AND s.StateFips_CODE = @Ac_StateFips_CODE
     AND (@Ac_StateFips_CODE <= @Lc_StateFipsUsMax_CODE
          AND (@Ac_CountyFips_CODE = @Lc_CountyFipsCentral_CODE
               AND f.TypeAddress_CODE = @Lc_AddressTypeState_CODE
               AND f.SubTypeAddress_CODE = @Lc_StaCentReg_CODE)
           OR (@Ac_CountyFips_CODE <> @Lc_CountyFipsCentral_CODE
               AND f.TypeAddress_CODE = @Lc_AddressTypeLocate_CODE
               AND f.SubTypeAddress_CODE = @Lc_LocSubAddr_CODE)
           OR (@Ac_StateFips_CODE > @Lc_StateFipsUsMax_CODE
               AND f.TypeAddress_CODE = @Lc_IntTypeAddress_CODE
               AND f.SubTypeAddress_CODE = @Lc_IntSubTypeAddress_CODE)
            OR ( f.TypeAddress_CODE = @Lc_TrbTypeAddress_CODE
               AND f.SubTypeAddress_CODE = @Lc_TrbSubTypeAddress_CODE))
     AND f.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF FIPS_RETRIEVE_S37

GO
