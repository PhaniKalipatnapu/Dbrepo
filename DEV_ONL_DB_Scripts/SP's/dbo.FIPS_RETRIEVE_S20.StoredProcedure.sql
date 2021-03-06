/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S20] (
 @Ac_Country_ADDR CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S20
  *     DESCRIPTION       : Retrieve the State Address and State Code for the given Country. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT F.StateFips_CODE,
         F.State_ADDR
    FROM FIPS_Y1 F
   WHERE F.Country_ADDR = ISNULL(@Ac_Country_ADDR, F.Country_ADDR)
     AND F.EndValidity_DATE = @Ld_High_DATE
   ORDER BY F.State_ADDR;
 END; --End of FIPS_RETRIEVE_S20 

GO
