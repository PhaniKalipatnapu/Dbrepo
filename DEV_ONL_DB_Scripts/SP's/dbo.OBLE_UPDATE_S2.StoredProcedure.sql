/****** Object:  StoredProcedure [dbo].[OBLE_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_UPDATE_S2] (
 @An_Case_IDNO            NUMERIC(6, 0),
 @An_OrderSeq_NUMB        NUMERIC(2, 0),
 @An_ObligationSeq_NUMB   NUMERIC(2, 0),
 @Ad_BeginObligation_DATE DATE,
 @Ad_EndObligation_DATE   DATE,
 @Ad_AccrualLast_DATE     DATE,
 @Ad_AccrualNext_DATE     DATE
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_UPDATE_S2
  *     DESCRIPTION       : Update the Accural Last and Next date in OBLE_Y1 for Case ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 21-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE OBLE_Y1
     SET AccrualLast_DATE = @Ad_AccrualLast_DATE,
         AccrualNext_DATE = @Ad_AccrualNext_DATE
   WHERE Case_IDNO = @An_Case_IDNO
     AND OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND ObligationSeq_NUMB = @An_ObligationSeq_NUMB
     AND BeginObligation_DATE = @Ad_BeginObligation_DATE
     AND EndObligation_DATE = @Ad_EndObligation_DATE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB =@@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF OBLE_UPDATE_S2

GO
