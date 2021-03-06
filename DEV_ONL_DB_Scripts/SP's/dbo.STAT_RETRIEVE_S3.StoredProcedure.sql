/****** Object:  StoredProcedure [dbo].[STAT_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[STAT_RETRIEVE_S3] (
 @Ac_State_CODE     CHAR(5),
 @Ac_StateFips_CODE CHAR(2) OUTPUT,
 @As_State_NAME     VARCHAR(60) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : STAT_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve the StateName for the given StateCode Excluding International
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_State_NAME = NULL;
  SET @Ac_StateFips_CODE= NULL;

  DECLARE @Lc_Statefips00_CODE              CHAR(2)= '00',
          @Lc_Statefips90_CODE              CHAR(2)= '90',
          @Lc_TypeAddressInternational_CODE CHAR(3)= 'INT',
          @Lc_TypeAddressTribal_CODE        CHAR(3) = 'TRB';

  SELECT @As_State_NAME = a.State_NAME,
         @Ac_StateFips_CODE = a.StateFips_CODE
    FROM STAT_Y1 a
   WHERE a.State_CODE = @Ac_State_CODE
     AND a.StateFips_CODE BETWEEN @Lc_Statefips00_CODE AND @Lc_Statefips90_CODE
     AND a.StateFips_CODE NOT IN (SELECT f.StateFips_CODE
                                    FROM FIPS_Y1 f
                                   WHERE f.TypeAddress_CODE IN (@Lc_TypeAddressInternational_CODE, @Lc_TypeAddressTribal_CODE));
 END; --End Of STAT_RETRIEVE_S10


GO
