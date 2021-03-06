/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S96]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S96] (
 @An_OtherParty_IDNO NUMERIC(9, 0),
 @An_Fein_IDNO       NUMERIC(9, 0),
 @As_OtherParty_NAME VARCHAR(60) OUTPUT,
 @As_Line1_ADDR      VARCHAR(50) OUTPUT,
 @As_Line2_ADDR      VARCHAR(50) OUTPUT,
 @Ac_City_ADDR       CHAR(28) OUTPUT,
 @Ac_Zip_ADDR        CHAR(15) OUTPUT,
 @Ac_State_ADDR      CHAR(2) OUTPUT,
 @Ac_Country_ADDR    CHAR(2) OUTPUT,
 @An_County_IDNO     NUMERIC(3, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S96
  *     DESCRIPTION       : Retrieve Other Party Residence address for a Other Party Federal number and Other Party number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_City_ADDR = NULL,
         @Ac_Country_ADDR = NULL,
         @As_Line1_ADDR = NULL,
         @As_Line2_ADDR = NULL,
         @Ac_State_ADDR = NULL,
         @Ac_Zip_ADDR = NULL,
         @An_County_IDNO = NULL,
         @As_OtherParty_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Li_Zero_NUMB SMALLINT = 0;

  SELECT TOP 1 @As_OtherParty_NAME = O.OtherParty_NAME,
               @As_Line1_ADDR = O.Line1_ADDR,
               @As_Line2_ADDR = O.Line2_ADDR,
               @Ac_City_ADDR = O.City_ADDR,
               @Ac_State_ADDR = O.State_ADDR,
               @Ac_Zip_ADDR = O.Zip_ADDR,
               @Ac_Country_ADDR = O.Country_ADDR,
               @An_County_IDNO = O.County_IDNO
    FROM OTHP_Y1 O
   WHERE O.EndValidity_DATE = @Ld_High_DATE
     AND O.OtherParty_IDNO = ISNULL(@An_OtherParty_IDNO, O.OtherParty_IDNO) 
     AND O.Fein_IDNO = ISNULL(@An_Fein_IDNO, O.Fein_IDNO);
 END; -- END OF OTHP_RETRIEVE_S96


GO
