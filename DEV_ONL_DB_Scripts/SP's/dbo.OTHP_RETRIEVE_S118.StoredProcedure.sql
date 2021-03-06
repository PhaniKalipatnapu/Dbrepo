/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S118]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S118] (
 @An_OtherParty_IDNO NUMERIC(9, 0),
 @Ai_Count_QNTY      INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S118
  *     DESCRIPTION       : Retrieve Record Count for an Other Party Idno, Other Party Type Code and  End valitity should be high date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE      DATE = '12/31/9999',
          @Lc_TypeOthpE_CODE CHAR(1) = 'E';
          
  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM OTHP_Y1 o
   WHERE o.OtherParty_IDNO = @An_OtherParty_IDNO
     AND o.EndValidity_DATE = @Ld_High_DATE
     AND o.TypeOthp_CODE = @Lc_TypeOthpE_CODE;
 
  END; --END OF OTHP_RETRIEVE_S118


GO
