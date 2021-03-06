/****** Object:  StoredProcedure [dbo].[OTHX_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHX_RETRIEVE_S2] (
 @An_OtherParty_IDNO NUMERIC(9, 0),
 @Ac_TypeAddr_CODE   CHAR(2),
 @An_AddrOthp_IDNO   NUMERIC(9, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHX_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Other Party address for an other Party number and address type.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_AddrOthp_IDNO = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_AddrOthp_IDNO = O.AddrOthp_IDNO
    FROM OTHX_Y1 O
   WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
     AND O.TypeAddr_CODE = @Ac_TypeAddr_CODE
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF OTHX_RETRIEVE_S2



GO
