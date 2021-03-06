/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S42] (
     @Ac_Fips_CODE           CHAR(7),
     @Ac_TypeAddress_CODE    CHAR(3),
     @Ac_SubTypeAddress_CODE CHAR(3),
     @As_Line1_ADDR		     VARCHAR(50) OUTPUT,
     @As_Line2_ADDR		     VARCHAR(50) OUTPUT,
     @Ac_City_ADDR		     CHAR(28)	 OUTPUT,
     @Ac_State_ADDR          CHAR(2)     OUTPUT,
     @Ac_Zip_ADDR		     CHAR(15)	 OUTPUT   
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S42
  *     DESCRIPTION       : Gets the Row Count for the Given FIPS with specified addresses. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  
      


  DECLARE @Ld_High_DATE DATE = '12/31/9999';
  
   SELECT @As_Line1_ADDR  = NULL, 
         @As_Line2_ADDR    = NULL, 
         @Ac_City_ADDR     = NULL, 
         @Ac_State_ADDR    = NULL, 
         @Ac_Zip_ADDR      = NULL;

  SELECT @As_Line1_ADDR = F.Line1_ADDR, 
         @As_Line2_ADDR = F.Line2_ADDR, 
         @Ac_City_ADDR = F.City_ADDR, 
         @Ac_State_ADDR = F.State_ADDR, 
         @Ac_Zip_ADDR = F.Zip_ADDR
       
    FROM FIPS_Y1 F
   WHERE F.Fips_CODE = @Ac_Fips_CODE
     AND F.TypeAddress_CODE = @Ac_TypeAddress_CODE
     AND F.SubTypeAddress_CODE = @Ac_SubTypeAddress_CODE
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF FIPS_RETRIEVE_S42.
 

GO
