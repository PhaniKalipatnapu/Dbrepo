/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S39]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S39] ( 
     @Ac_Fips_CODE		 CHAR(7),
     @Ai_Count_QNTY      INT	OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : FIPS_RETRIEVE_S39
 *     DESCRIPTION       : This procedure returns the count of FIPS existing in FIPS_Y1 for state fips code.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN
     SET @Ai_Count_QNTY = NULL;

     DECLARE 
		 @Li_One_NUMB						INT     = 1,
		 @Li_Two_NUMB						INT     = 2,
		 @Lc_AddressSubTypeFrc_CODE		CHAR(3) = 'FRC', 
		 @Lc_TypeOfficeInternational_CODE	CHAR(3) = 'INT',
		 @Ld_High_DATE						DATE	= '12/31/9999';
    
     SELECT @Ai_Count_QNTY = COUNT(1)
       FROM FIPS_Y1 a
     WHERE a.StateFips_CODE		 = SUBSTRING(@Ac_Fips_CODE,@Li_One_NUMB,@Li_Two_NUMB) 
       AND a.TypeAddress_CODE	 = @Lc_TypeOfficeInternational_CODE 
       AND a.SubTypeAddress_CODE = @Lc_AddressSubTypeFrc_CODE 
	   AND a.EndValidity_DATE	 = @Ld_High_DATE;

 END;--END OF FIPS_RETRIEVE_S39


GO
