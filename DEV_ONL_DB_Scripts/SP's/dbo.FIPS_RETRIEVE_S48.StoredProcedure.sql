/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S48]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S48] (
 @Ac_Fips_CODE CHAR(7),
 @Ac_Fips_NAME CHAR(40) OUTPUT
 )
AS
 /*  
 *     PROCEDURE NAME    : FIPS_RETRIEVE_S48  
 *     DESCRIPTION       : It is used to get the file name for the given fips code.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 03-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_High_DATE   DATE='12/31/9999';

  SELECT @Ac_Fips_NAME = Fips_NAME
    FROM FIPS_Y1
   WHERE Fips_CODE = @Ac_Fips_CODE
     AND EndValidity_DATE = @Ld_High_DATE;
 END; --End of FIPS_RETRIEVE_S48



GO
