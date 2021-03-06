/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S7] (
 @Ac_TypeAddress_CODE    CHAR(3),
 @Ac_SubTypeAddress_CODE CHAR(3)
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S7
  *     DESCRIPTION       : Gets State details for a type of the FIPS. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE 
  	@Ld_High_DATE DATE = '12/31/9999';

  SELECT DISTINCT F.StateFips_CODE,
         S.State_NAME,
         S.State_CODE
    FROM FIPS_Y1 F
         JOIN STAT_Y1 S
          ON F.StateFips_CODE = S.StateFips_CODE
   WHERE F.EndValidity_DATE = @Ld_High_DATE
     AND F.TypeAddress_CODE = @Ac_TypeAddress_CODE
     AND F.SubTypeAddress_CODE = @Ac_SubTypeAddress_CODE
   ORDER BY State_NAME;
 END; --END OF FIPS_RETRIEVE_S7


GO
