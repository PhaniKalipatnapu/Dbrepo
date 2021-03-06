/****** Object:  StoredProcedure [dbo].[FIPS_RETRIEVE_S25]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FIPS_RETRIEVE_S25] (
 @Ac_Fips_CODE      CHAR(7),
 @Ac_StateFips_CODE CHAR(2),
 @Ac_State_ADDR     CHAR(2)  OUTPUT,
 @Ac_Fips_NAME      CHAR(40) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : FIPS_RETRIEVE_S25  
  *     DESCRIPTION       : Retrieving the state address and Fips name;  
  *     DEVELOPED BY      : IMP TEAM  
  *     DEVELOPED ON      : 02-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @Ac_State_ADDR = NULL,
         @Ac_Fips_NAME  = NULL;

  DECLARE @Ld_High_DATE                  DATE    = '12/31/9999',
          @Lc_TypeAddressState_CODE      CHAR(3) = 'STA',
          @Lc_TypeAddressInterstate_CODE CHAR(3) = 'INT',
          @Lc_TypeAddressTribal_CODE	 CHAR(3) = 'TRB',
          @Lc_SubTypeAddressCrg_CODE     CHAR(3) = 'CRG',
          @Lc_SubTypeAddressFrc_CODE     CHAR(3) = 'FRC',
		  @Lc_SubTypeAddressT01_CODE     CHAR(3) = 'T01',
		  @Ld_Current_DATE               DATE    = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT @Ac_State_ADDR = F.State_ADDR,
         @Ac_Fips_NAME  = F.Fips_NAME
    FROM FIPS_Y1 F
   WHERE F.Fips_CODE                = @Ac_Fips_CODE
	 AND ((f.TypeAddress_CODE       = @Lc_TypeAddressTribal_CODE
          AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressT01_CODE)
      OR (f.TypeAddress_CODE        = @Lc_TypeAddressInterstate_CODE
         AND f.SubTypeAddress_CODE  = @Lc_SubTypeAddressFrc_CODE)
      OR (f.TypeAddress_CODE        = @Lc_TypeAddressState_CODE
         AND f.SubTypeAddress_CODE  = @Lc_SubTypeAddressCrg_CODE))
      AND (@Ac_StateFips_CODE IS NULL
           OR (@Ac_StateFips_CODE IS NOT NULL
               AND F.StateFips_CODE = @Ac_StateFips_CODE))
      AND F.BeginValidity_DATE <= @Ld_Current_DATE
      AND F.EndValidity_DATE    = @Ld_High_DATE;
                             
 END; --End of FIPS_RETRIEVE_S25 

GO
