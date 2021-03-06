/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S12] (
 @Ac_StateFips_CODE  CHAR(2),
 @Ac_CountyFips_CODE CHAR(3),
 @Ac_OfficeFips_CODE CHAR(2),
 @Ac_Fips_NAME       CHAR(40) OUTPUT
 )
AS
 /*
  *	PROCEDURE NAME    : FIPS_RETRIEVE_S12
  *  DESCRIPTION       : Retrieves the FIPS Name for a Given State ,County and Office. 
  *  DEVELOPED BY      : IMP Team
  *  DEVELOPED ON      : 09-AUG-2011
  *  MODIFIED BY       : 
  *  MODIFIED ON       : 
  *  VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Fips_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_Fips_NAME = F.Fips_NAME
    FROM FIPS_Y1 F
   WHERE F.StateFips_CODE = @Ac_StateFips_CODE
     AND F.CountyFips_CODE = @Ac_CountyFips_CODE
     AND F.OfficeFips_CODE = @Ac_OfficeFips_CODE
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF FIPS_RETRIEVE_S12


GO
