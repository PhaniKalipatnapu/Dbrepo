/****** Object:  StoredProcedure [dbo].[RBAT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RBAT_RETRIEVE_S1] (
 @Ad_Batch_DATE            DATE,
 @Ac_SourceBatch_CODE      CHAR(3),
 @An_Batch_NUMB            NUMERIC(4, 0),
 @An_CtControlReceipt_QNTY NUMERIC(3, 0) OUTPUT,
 @An_CtActualReceipt_QNTY  NUMERIC(3, 0) OUTPUT,
 @An_ControlReceipt_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_ActualReceipt_AMNT    NUMERIC(11, 2) OUTPUT,
 @Ad_Receipt_DATE          DATE OUTPUT,
 @Ac_StatusBatch_CODE      CHAR(1) OUTPUT,
 @An_CtControlTrans_QNTY   NUMERIC(3, 0) OUTPUT,
 @An_CtActualTrans_QNTY    NUMERIC(3, 0) OUTPUT,
 @Ac_Worker_ID             CHAR(30) OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : RBAT_RETRIEVE_S1      
  *     DESCRIPTION       : Retrieving the batch details.      
  *     DEVELOPED BY      : IMP Team     
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT 
         @An_CtControlReceipt_QNTY = NULL,
         @An_CtActualReceipt_QNTY = NULL,
         @An_ControlReceipt_AMNT = NULL,
         @An_ActualReceipt_AMNT = NULL,
         @Ad_Receipt_DATE = NULL,
         @Ac_StatusBatch_CODE = NULL,
         @An_CtActualTrans_QNTY = NULL,
         @An_CtControlTrans_QNTY = NULL,
         @Ac_Worker_ID = NULL;

  SELECT TOP 1 @An_CtControlReceipt_QNTY = a.CtControlReceipt_QNTY,
               @An_CtActualReceipt_QNTY = a.CtActualReceipt_QNTY,
               @An_ControlReceipt_AMNT = a.ControlReceipt_AMNT,
               @An_ActualReceipt_AMNT = a.ActualReceipt_AMNT,
               @Ad_Receipt_DATE = a.Receipt_DATE,
               @Ac_StatusBatch_CODE = a.StatusBatch_CODE,
               @An_CtControlTrans_QNTY = a.CtControlTrans_QNTY,
               @An_CtActualTrans_QNTY = a.CtActualTrans_QNTY,
               @Ac_Worker_ID = b.Worker_ID
    FROM RBAT_Y1 a
         LEFT OUTER JOIN GLEV_Y1 b
          ON (b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
   WHERE a.Batch_DATE = @Ad_Batch_DATE
     AND a.Batch_NUMB = @An_Batch_NUMB
     AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of RBAT_RETRIEVE_S1  



GO
