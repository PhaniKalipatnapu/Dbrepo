/****** Object:  StoredProcedure [dbo].[UNOT_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UNOT_UPDATE_S1] (
 @An_EventGlobalSeq_NUMB         NUMERIC(19, 0),
 @An_EventGlobalApprovalSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : UNOT_UPDATE_S1
  *     DESCRIPTION       : Updates the event global approval sequence number for the given event global sequence number
  *     DEVELOPED BY      : IMP team
  *     DEVELOPED ON      : 23-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE UNOT_Y1
     SET EventGlobalApprovalSeq_NUMB = @An_EventGlobalApprovalSeq_NUMB
   WHERE EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END -- End of UNOT_UPDATE_S1

GO
