/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S15] (
 @Ac_StateFips_CODE  CHAR(2),
 @Ac_CountyFips_CODE CHAR(3),
 @Ai_Count_QNTY      INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S15  
  *     DESCRIPTION       : Gets the Row Count for a given FIPS State and Fips County with a specified addresses
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 17-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE              DATE = '12/31/9999',
          @Lc_SubTypeAddressCo1_CODE CHAR(3) = 'C01',
          @Lc_TypeAddressLoc_CODE    CHAR(3) = 'LOC';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM FIPS_Y1 F
   WHERE F.StateFips_CODE = @Ac_StateFips_CODE
     AND F.CountyFips_CODE = @Ac_CountyFips_CODE --
     AND F.TypeAddress_CODE = @Lc_TypeAddressLoc_CODE
     AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressCo1_CODE
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF FIPS_RETRIEVE_S15


GO
