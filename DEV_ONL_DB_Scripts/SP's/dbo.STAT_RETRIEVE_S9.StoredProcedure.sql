/****** Object:  StoredProcedure [dbo].[STAT_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[STAT_RETRIEVE_S9]
AS
 /*                                                                                                                                         
  *     PROCEDURE NAME    : STAT_RETRIEVE_S9                                                                                                 
  *     DESCRIPTION       : Retrieve the State code, Fips State Code, and State name for a State Fips Code that is equal to Null or Empty.  
  *     DEVELOPED BY      : IMP Team                                                                                                      
  *     DEVELOPED ON      : 02-SEP-2011                                                                                                     
  *     MODIFIED BY       :                                                                                                                 
  *     MODIFIED ON       :                                                                                                                 
  *     VERSION NO        : 1                                                                                                               
  */
 BEGIN
  DECLARE @Lc_Space_TEXT                    CHAR(1) = ' ',
          @Lc_Statefips00_CODE              CHAR(2)= '00',
          @Lc_Statefips90_CODE              CHAR(2)= '90',
          @Lc_TypeAddressInternational_CODE CHAR(3)= 'INT',
          @Lc_TypeAddressTribal_CODE        CHAR(3) = 'TRB';

  SELECT S.State_CODE,
         S.State_NAME,
         S.StateFips_CODE
    FROM STAT_Y1 S
   WHERE (S.StateFips_CODE != NULL
           OR S.StateFips_CODE <> @Lc_Space_TEXT)
     AND S.StateFips_CODE BETWEEN @Lc_Statefips00_CODE AND @Lc_Statefips90_CODE
     AND S.StateFips_CODE NOT IN (SELECT F.StateFips_CODE
                                    FROM FIPS_Y1 F
                                   WHERE F.TypeAddress_CODE IN (@Lc_TypeAddressInternational_CODE, @Lc_TypeAddressTribal_CODE))
   ORDER BY State_NAME;
 END; --End of STAT_RETRIEVE_S9

GO
