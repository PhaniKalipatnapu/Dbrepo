/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S6] (
 @Ac_StateFips_CODE  CHAR(2),
 @Ac_CountyFips_CODE CHAR(3)
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S6
  *     DESCRIPTION       : Retrieves Office Details for a given State and Fips County. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  DECLARE 
  	@Ld_High_DATE               DATE = '12/31/9999';
          

  SELECT F.OfficeFips_CODE,
         F.Fips_NAME,
         F.TypeAddress_CODE,
         F.SubTypeAddress_CODE
   FROM FIPS_Y1 F
   WHERE F.StateFips_CODE = @Ac_StateFips_CODE
     AND F.CountyFips_CODE = @Ac_CountyFips_CODE
     AND F.EndValidity_DATE = @Ld_High_DATE
   ORDER BY Fips_NAME;
   
 END; -- END OF FIPS_RETRIEVE_S6


GO
