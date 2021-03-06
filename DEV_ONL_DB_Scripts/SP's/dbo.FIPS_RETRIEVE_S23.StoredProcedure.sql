/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S23]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S23]  

AS

/*
 *     PROCEDURE NAME    : FIPS_RETRIEVE_S23
 *     DESCRIPTION       : It retieve the fips Information from Fips Table. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      DECLARE
         @Ld_High_DATE DATE = '12/31/9999', 
         @Lc_AddressSubTypeFrc_CODE CHAR(3) = 'FRC', 
         @Lc_AddressSubTypeSdu_CODE CHAR(3) = 'SDU', 
         @Lc_AddressTypeInt_CODE CHAR(3) = 'INT', 
         @Lc_AddressTypeState_CODE CHAR(3) = 'STA' ; 
                
        SELECT f.CountyFips_CODE , 
         UPPER(f.Fips_NAME) AS Fips_NAME , 
         f.StateFips_CODE , 
         f.OfficeFips_CODE , 
         f.TypeAddress_CODE , 
         f.SubTypeAddress_CODE , 
         f.State_ADDR , 
         f.Fips_CODE         
      FROM FIPS_Y1 f
      WHERE (  (f.TypeAddress_CODE = @Lc_AddressTypeState_CODE 
              AND f.SubTypeAddress_CODE = @Lc_AddressSubTypeSdu_CODE) 
              OR (f.TypeAddress_CODE = @Lc_AddressTypeInt_CODE 
                  AND f.SubTypeAddress_CODE = @Lc_AddressSubTypeFrc_CODE)
                  ) 
                  AND f.EndValidity_DATE = @Ld_High_DATE
      ORDER BY Fips_NAME;
                  
END;--End of FIPS_RETRIEVE_S23


GO
