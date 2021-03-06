/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S28] (
 @An_Fein_IDNO       NUMERIC(9, 0),
 @As_OtherParty_NAME VARCHAR(60) OUTPUT
 )
AS
 /*                                                                                              
 *     PROCEDURE NAME    : OTHP_RETRIEVE_S28                                                     
 *     DESCRIPTION       : Retrieves Other Party Name For the given Fein Id                                                                    
 *     DEVELOPED BY      : IMP Team                                                           
 *     DEVELOPED ON      : 02-SEP-2011                                                          
 *     MODIFIED BY       :                                                                      
 *     MODIFIED ON       :                                                                      
 *     VERSION NO        : 1                                                                    
 */
 BEGIN
  SET @As_OtherParty_NAME = NULL;

  DECLARE @Ld_High_DATE      DATE = '12/31/9999',
          @Lc_TypeOthpE_CODE CHAR(1) = 'E';

  SELECT TOP 1 @As_OtherParty_NAME = O.OtherParty_NAME
    FROM OTHP_Y1 O
   WHERE O.Fein_IDNO = @An_Fein_IDNO
     AND O.TypeOthp_CODE = @Lc_TypeOthpE_CODE
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of OTHP_RETRIEVE_S28                                                                                             

GO
