/****** Object:  StoredProcedure [dbo].[RBAT_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RBAT_RETRIEVE_S4] (
 @Ac_SourceBatch_CODE CHAR(3),
 @An_Batch_NUMB       NUMERIC(4, 0),
 @Ac_StatusBatch_CODE CHAR(1),
 @Ac_RePost_INDC      CHAR(1),
 @Ad_From_DATE        DATE,
 @Ad_To_DATE          DATE,
 @Ai_RowFrom_NUMB     INT=1,
 @Ai_RowTo_NUMB       INT=10

 )
AS
 /*
 *      PROCEDURE NAME    : RBAT_RETRIEVE_S4
  *     DESCRIPTION       :Procedure to query Batch details
                           that have a status of 'Reconciled' and 'Unreconciled'and populate
                           the CBAT display grid for a specific Batch Date, Batch Number ,
                           Deposit Source , Repost Indicator and Batch Status.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE ='12/31/9999',
          @Li_One_NUMB  SMALLINT =-1;

  SELECT Y.Batch_DATE,
         Y.SourceBatch_CODE,
         Y.Batch_NUMB,
         Y.EventGlobalBeginSeq_NUMB,
         Y.CtControlReceipt_QNTY,        
         Y.CtActualReceipt_QNTY,
         Y.ControlReceipt_AMNT,
         Y.ActualReceipt_AMNT,
         Y.Receipt_DATE,
         Y.StatusBatch_CODE,
         Y.Worker_ID,
         Y.RePost_INDC,
         Y.CtControlTrans_QNTY,
         Y.CtActualTrans_QNTY,         
         RowCount_NUMB
    FROM (SELECT a.Batch_DATE,
                 a.SourceBatch_CODE,
                 a.Batch_NUMB,
                 a.StatusBatch_CODE,
                 a.Receipt_DATE,
                 a.CtControlTrans_QNTY,
                 a.CtControlReceipt_QNTY,
                 a.CtActualTrans_QNTY,
                 a.CtActualReceipt_QNTY,
                 a.ControlReceipt_AMNT,
                 a.ActualReceipt_AMNT,
                 g.Worker_ID,
                 a.RePost_INDC,
                 a.EventGlobalBeginSeq_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER( ORDER BY a.Batch_DATE DESC, a.Batch_NUMB DESC) AS ORD_ROWNUM
            FROM RBAT_Y1 a
                 JOIN GLEV_Y1 g
                  ON(g.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           WHERE a.EndValidity_DATE = @Ld_High_DATE
             AND a.Batch_DATE BETWEEN ISNULL(@Ad_From_DATE, DATEADD(D, @Li_One_NUMB, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())) AND ISNULL(@Ad_To_DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
             AND a.RePost_INDC = ISNULL(@Ac_RePost_INDC, a.RePost_INDC)
             AND a.Batch_NUMB = ISNULL(@An_Batch_NUMB, a.Batch_NUMB)
             AND a.SourceBatch_CODE = ISNULL(@Ac_SourceBatch_CODE, a.SourceBatch_CODE)
             AND a.StatusBatch_CODE = ISNULL(@Ac_StatusBatch_CODE, a.StatusBatch_CODE)) Y
   WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB
     AND Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY ORD_ROWNUM;
 END; --End of RBAT_RETRIEVE_S4


GO
