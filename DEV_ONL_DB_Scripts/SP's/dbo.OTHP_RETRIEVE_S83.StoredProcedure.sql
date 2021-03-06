/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S83]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S83] (
 @An_OtherParty_IDNO NUMERIC(9, 0),
 @Ac_TypeOthp_CODE   CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S83
  *     DESCRIPTION       : Retrieve Other Party Type for an Other Party number, Other Party Residing State, and Other Party Type.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 07-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_TypeOthp_CODE = NULL;

  DECLARE @Ld_High_DATE        DATE = '12/31/9999',
          @Lc_TypeOthpLab_CODE CHAR(1) = 'L',
          @Lc_StateDe_ADDR     CHAR(2) = 'DE';

  SELECT @Ac_TypeOthp_CODE = O.TypeOthp_CODE
    FROM OTHP_Y1 O
   WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
     AND ((O.State_ADDR = @Lc_StateDe_ADDR
           AND O.TypeOthp_CODE = @Lc_TypeOthpLab_CODE)
           OR O.TypeOthp_CODE != @Lc_TypeOthpLab_CODE)
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; --END OF  OTHP_RETRIEVE_S83



GO
