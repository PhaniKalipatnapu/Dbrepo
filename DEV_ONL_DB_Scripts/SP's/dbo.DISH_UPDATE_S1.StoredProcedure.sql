/****** Object:  StoredProcedure [dbo].[DISH_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DISH_UPDATE_S1] (
 @An_CasePayorMCI_IDNO        NUMERIC(10, 0),
 @Ac_TypeHold_CODE            CHAR(1),
 @Ac_SourceHold_CODE          CHAR(2),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @Ac_ReasonHold_CODE          CHAR(4),
 @An_Sequence_NUMB            NUMERIC(11, 0),
 @An_EventGlobalEndSeq_NUMB   NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DISH_UPDATE_S1
  *     DESCRIPTION       : Updates the DistributionHold table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 27-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Ld_High_DATE         DATE ='12/31/9999',
          @Ld_Current_DATE      DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE DISH_Y1
     SET EndValidity_DATE = @Ld_Current_DATE,
         EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB
   WHERE CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
     AND Sequence_NUMB = @An_Sequence_NUMB
     AND TypeHold_CODE = @Ac_TypeHold_CODE
     AND SourceHold_CODE = @Ac_SourceHold_CODE
     AND ReasonHold_CODE = @Ac_ReasonHold_CODE
     AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END of DISH_UPDATE_S1

GO
