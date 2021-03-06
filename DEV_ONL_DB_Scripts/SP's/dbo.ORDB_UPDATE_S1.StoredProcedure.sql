/****** Object:  StoredProcedure [dbo].[ORDB_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ORDB_UPDATE_S1] (
 @An_Case_IDNO                   NUMERIC(6, 0),
 @An_OrderSeq_NUMB               NUMERIC(2, 0),
 @Ac_TypeDebt_CODE               CHAR(2),
 @Ac_Allocated_INDC              CHAR(1),
 @An_Order_AMNT                  NUMERIC(11, 2),
 @An_EventGlobalBeginSeqNew_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : ORDB_UPDATE_S1
  *     DESCRIPTION       : updating the allocated indication and order amount for case id in ORDB_Y1
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Li_Zero_NUMB         SMALLINT = 0,
          @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE ORDB_Y1
     SET Allocated_INDC = @Ac_Allocated_INDC,
         Order_AMNT = ISNULL(@An_Order_AMNT, @Li_Zero_NUMB),
         BeginValidity_DATE = @Ld_Current_DATE,
         EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeqNew_NUMB
  OUTPUT DELETED.Case_IDNO,
         DELETED.OrderSeq_NUMB,
         DELETED.TypeDebt_CODE,
         DELETED.Allocated_INDC,
         DELETED.Order_AMNT,
         DELETED.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         DELETED.EventGlobalBeginSeq_NUMB,
         @An_EventGlobalBeginSeqNew_NUMB AS EventGlobalEndSeq_NUMB
  INTO ORDB_Y1
   WHERE Case_IDNO = @An_Case_IDNO
     AND OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND TypeDebt_CODE = @Ac_TypeDebt_CODE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF ORDB_UPDATE_S1

GO
