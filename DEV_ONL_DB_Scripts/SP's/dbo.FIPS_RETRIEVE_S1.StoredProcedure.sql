/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S1] (
 @Ac_Fips_CODE           CHAR(7),
 @Ai_Count_QNTY          INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S1
  *     DESCRIPTION       : Gets the Row Count for the Given FIPS with specified addresses. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-JAN-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
      SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE                  DATE = '12/31/9999',
          @Lc_TypeAddressState_CODE      CHAR(3) = 'STA',
          @Lc_TypeAddressInterstate_CODE CHAR(3) = 'INT',
          @Lc_TypeAddressTribal_CODE	 CHAR(3) = 'TRB',
          @Lc_SubTypeAddressCrg_CODE     CHAR(3) = 'CRG',
          @Lc_SubTypeAddressFrc_CODE     CHAR(3) = 'FRC',
		  @Lc_SubTypeAddressT01_CODE     CHAR(3) = 'T01';

   SELECT @Ai_Count_QNTY = COUNT(1)
     FROM FIPS_Y1 F
    WHERE F.Fips_CODE = @Ac_Fips_CODE
      AND ((f.TypeAddress_CODE        = @Lc_TypeAddressTribal_CODE
		   AND f.SubTypeAddress_CODE  = @Lc_SubTypeAddressT01_CODE)
	   OR (f.TypeAddress_CODE         = @Lc_TypeAddressInterstate_CODE
           AND  f.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE)
       OR (f.TypeAddress_CODE         = @Lc_TypeAddressState_CODE
           AND f.SubTypeAddress_CODE  = @Lc_SubTypeAddressCrg_CODE))
      AND F.EndValidity_DATE          = @Ld_High_DATE;
 END; --END OF FIPS_RETRIEVE_S1



GO
