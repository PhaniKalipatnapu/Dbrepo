/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S5] (  
 @Ac_StateFips_CODE CHAR(2)  
 )  
AS  
 /*  
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S5  
  *     DESCRIPTION       : Retrieves the FIPS Name and County for a Specified Addresses  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 04-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
 BEGIN  
  DECLARE @Ld_High_DATE              DATE = '12/31/9999',  
          @Lc_SubTypeAddressCo1_CODE CHAR(3) = 'C01',  
          @Lc_SubTypeAddressFrc_CODE CHAR(3) = 'FRC',  
          @Lc_SubTypeAddressIvd_CODE CHAR(3) = 'IVD',  
          @Lc_SubTypeAddressT01_CODE CHAR(3) = 'T01',  
          @Lc_TypeAddressInt_CODE    CHAR(3) = 'INT',  
          @Lc_TypeAddressLoc_CODE    CHAR(3) = 'LOC',  
          @Lc_TypeAddressSta_CODE    CHAR(3) = 'STA',
          @Lc_TypeAddressTrb_CODE    CHAR(3) = 'TRB',
          @Li_One_NUMB				 INT     = 1 ;  
  
  SELECT DISTINCT Y.CountyFips_CODE,  
         Y.Fips_NAME  
    FROM (SELECT DISTINCT X.CountyFips_CODE,  
                 X.Fips_NAME,  
                 X.row_num  
            FROM (SELECT DISTINCT F.CountyFips_CODE,  
                         F.Fips_NAME,  
                         ROW_NUMBER () OVER (PARTITION BY F.CountyFips_CODE ORDER BY F.CountyFips_CODE DESC)AS row_num,  
                         ROW_NUMBER() OVER (ORDER BY F.CountyFips_CODE)AS ORD_ROWNUM  
                    FROM FIPS_Y1 F  
                   WHERE ((F.TypeAddress_CODE = @Lc_TypeAddressLoc_CODE  
                           AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressCo1_CODE)  
                           OR (F.TypeAddress_CODE = @Lc_TypeAddressSta_CODE  
                               AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressIvd_CODE)  
                           OR (F.TypeAddress_CODE = @Lc_TypeAddressInt_CODE  
                               AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE)
                            OR(F.TypeAddress_CODE = @Lc_TypeAddressTrb_CODE  
                               AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressT01_CODE ))  
                     AND F.StateFips_CODE = @Ac_StateFips_CODE  
                     AND F.EndValidity_DATE = @Ld_High_DATE) AS X  
           WHERE X.row_num = @Li_One_NUMB) AS Y  
   ORDER BY Fips_NAME;  
 END; -- END OF FIPS_RETRIEVE_S5  
  


GO
