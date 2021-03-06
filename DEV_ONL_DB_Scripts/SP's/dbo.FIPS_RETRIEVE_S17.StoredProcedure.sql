/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S17] (
 @Ac_Fips_CODE           CHAR(7),
 @Ac_TypeAddress_CODE    CHAR(3),
 @Ac_SubTypeAddress_CODE CHAR(3),
 @Ai_Count_QNTY          INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S17
  *     DESCRIPTION       : Retrieve the Row Count  for the given FIPS code and Type address code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 28-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_AddressSubTypeCol_CODE CHAR(3) = 'COL',
          @Lc_AddressSubTypeFrc_CODE CHAR(3) = 'FRC',
          @Lc_AddressSubTypeSdu_CODE CHAR(3) = 'SDU',
          @Lc_AddressTypeInt_CODE    CHAR(3) = 'INT',
          @Lc_AddressTypeLocate_CODE CHAR(3) = 'LOC',
          @Lc_AddressTypeState_CODE  CHAR(3) = 'STA';

  SELECT @Ai_Count_QNTY = COUNT(F.Fips_CODE)
    FROM FIPS_Y1 F
   WHERE F.Fips_CODE = @Ac_Fips_CODE
     AND ((@Ac_TypeAddress_CODE IS NULL
           AND ((F.TypeAddress_CODE = @Lc_AddressTypeState_CODE
                 AND F.SubTypeAddress_CODE = @Lc_AddressSubTypeSdu_CODE)
                 OR (F.TypeAddress_CODE = @Lc_AddressTypeLocate_CODE
                     AND F.SubTypeAddress_CODE = @Lc_AddressSubTypeCol_CODE)
                 OR (F.TypeAddress_CODE = @Lc_AddressTypeInt_CODE
                     AND F.SubTypeAddress_CODE = @Lc_AddressSubTypeFrc_CODE)))
           OR (@Ac_TypeAddress_CODE IS NOT NULL
               AND (F.TypeAddress_CODE = @Ac_TypeAddress_CODE
                    AND F.SubTypeAddress_CODE = @Ac_SubTypeAddress_CODE)))
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF FIPS_RETRIEVE_S17



GO
