/****** Object:  StoredProcedure [dbo].[RBAT_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RBAT_UPDATE_S2] (
 @Ad_Batch_DATE                  DATE,
 @Ac_SourceBatch_CODE            CHAR(3),
 @An_Batch_NUMB                  NUMERIC(4, 0),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0),
 @An_CtControlReceipt_QNTY       NUMERIC(3, 0),
 @An_CtActualReceipt_QNTY        NUMERIC(3, 0),
 @An_ControlReceipt_AMNT         NUMERIC(11, 2),
 @An_ActualReceipt_AMNT          NUMERIC(11, 2),
 @Ac_StatusBatch_CODE            CHAR(1),
 @An_CtControlTrans_QNTY         NUMERIC(3, 0),
 @An_CtActualTrans_QNTY          NUMERIC(3, 0),
 @Ac_SourceReceipt_CODE          CHAR(2),
 @Ac_TypeRemittance_CODE         CHAR(3),
 @Ad_Receipt_DATE                DATE,
 @Ac_RePost_INDC                 CHAR(1)
 )
AS
 /*                                                                                                                                                                                                                                                                                                                  
  *     PROCEDURE NAME    : RBAT_UPDATE_S2                                                                                                                                                                                                                                                                            
  *     DESCRIPTION       : Procedure To Update The Receipt Details Based On BatchDate,SourceBatchCode,BatchNUMB,
                            GlobalEventSeq And Also To Maintain History Record.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                                                               
  *     DEVELOPED ON      : 13-OCT-2011                                                                                                                                                                                                                                                                              
  *     MODIFIED BY       :                                                                                                                                                                                                                                                                                          
  *     MODIFIED ON       :                                                                                                                                                                                                                                                                                          
  *     VERSION NO        : 1                                                                                                                                                                                                                                                                                        
 */
 BEGIN
  DECLARE @Ld_High_DATE    DATE ='12/31/9999',
          @Ld_Current_DATE DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE RBAT_Y1
     SET SourceReceipt_CODE = @Ac_SourceReceipt_CODE,
         TypeRemittance_CODE = @Ac_TypeRemittance_CODE,
         Receipt_DATE = @Ad_Receipt_DATE,
         Repost_INDC = @Ac_RePost_INDC,
         CtControlReceipt_QNTY = @An_CtControlReceipt_QNTY,
         CtActualReceipt_QNTY = @An_CtActualReceipt_QNTY,
         ControlReceipt_AMNT = @An_ControlReceipt_AMNT,
         ActualReceipt_AMNT = @An_ActualReceipt_AMNT,
         StatusBatch_CODE = @Ac_StatusBatch_CODE,
         CtControlTrans_QNTY = @An_CtControlTrans_QNTY,
         CtActualTrans_QNTY = @An_CtActualTrans_QNTY,
         EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB,
         BeginValidity_DATE = @Ld_Current_DATE
  OUTPUT DELETED.Batch_DATE,
         DELETED.SourceBatch_CODE,
         DELETED.Batch_NUMB,
         DELETED.SourceReceipt_CODE,
         DELETED.CtControlReceipt_QNTY,
         DELETED.CtActualReceipt_QNTY,
         DELETED.ControlReceipt_AMNT,
         DELETED.ActualReceipt_AMNT,
         DELETED.TypeRemittance_CODE,
         DELETED.Receipt_DATE,
         DELETED.StatusBatch_CODE,
         DELETED.RePost_INDC,
         DELETED.EventGlobalBeginSeq_NUMB,
         @An_EventGlobalBeginSeq_NUMB AS EventGlobalEndSeq_NUMB,
         DELETED.BeginValidity_DATE,
         @Ld_Current_DATE AS EndValidity_DATE,
         DELETED.CtControlTrans_QNTY,
         DELETED.CtActualTrans_QNTY
  INTO RBAT_Y1
   WHERE Batch_DATE = @Ad_Batch_DATE
     AND SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND Batch_NUMB = @An_Batch_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF Procedure RBAT_UPDATE_S2                                                                                                                                                                                                                                                                                                                 

GO
