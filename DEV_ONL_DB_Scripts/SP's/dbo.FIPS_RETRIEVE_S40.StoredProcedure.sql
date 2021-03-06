/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S40]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S40]  

AS
/*
 *      PROCEDURE NAME   : FIPS_RETRIEVE_S40
 *     DESCRIPTION       : This procedure is returns the fips code form FIPS_Y1 while inserting new obligations.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
      DECLARE 
			  @Lc_DEStateFips_CODE		 CHAR(2) = '10',
			  @Lc_AddressSubTypeFrc_CODE CHAR(3) = 'FRC', 
			  @Lc_AddressSubTypeSdu_CODE CHAR(3) = 'SDU', 
			  @Lc_AddressTypeInt_CODE	 CHAR(3) = 'INT', 
			  @Lc_AddressTypeState_CODE	 CHAR(3) = 'STA',
			  @Ld_High_DATE				 DATE	 = '12/31/9999';
        
      SELECT DISTINCT a.Fips_CODE 
      	FROM FIPS_Y1 a
       WHERE a.StateFips_CODE = @Lc_DEStateFips_CODE 
         AND ( ( a.TypeAddress_CODE = @Lc_AddressTypeState_CODE 
				AND a.SubTypeAddress_CODE = @Lc_AddressSubTypeSdu_CODE )
			  OR( a.TypeAddress_CODE = @Lc_AddressTypeInt_CODE 
				  AND a.SubTypeAddress_CODE = @Lc_AddressSubTypeFrc_CODE ) ) 
          AND a.EndValidity_DATE = @Ld_High_DATE;

END;--END OF FIPS_RETRIEVE_S40


GO
