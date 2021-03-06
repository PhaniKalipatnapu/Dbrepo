/****** Object:  StoredProcedure [dbo].[R2527_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[R2527_RETRIEVE_S1](
 @Ad_BeginFiscal_DATE DATE,
 @Ad_EndFiscal_DATE   DATE,
 @Ac_TypeReport_CODE  CHAR(1),
 @An_Line_NUMB        NUMERIC(3, 0),
 @Ac_TypeAsst_CODE    CHAR(1),
 @An_County_IDNO      NUMERIC(3, 0),
 @Ac_Worker_ID        CHAR(30),
 @Ai_RowFrom_NUMB     INT = 1,
 @Ai_RowTo_NUMB       INT = 10
 )
AS
 /*  
 *     PROCEDURE NAME    : R2527_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the collections involved in the cases for the line_no 25,27,36  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 27-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Li_Zero_NUMB SMALLINT = 0;

  SELECT C.Worker_ID,
         C.Batch_DATE,
         C.SourceBatch_CODE,
         C.Batch_NUMB,
         C.SeqReceipt_NUMB,
         C.Case_IDNO,
         C.ObligationKey_ID,
         C.PayorMCI_IDNO,
         C.Trans_DATE,
         C.Trans_AMNT,
         C.LookIn_TEXT,
         C.County_IDNO,
         C.RowCount_NUMB
    FROM (SELECT B.Worker_ID,
                 B.Batch_DATE,
                 B.SourceBatch_CODE,
                 B.Batch_NUMB,
                 B.SeqReceipt_NUMB,
                 B.Case_IDNO,
                 B.ObligationKey_ID,
                 B.PayorMCI_IDNO,
                 B.Trans_DATE,
                 B.Trans_AMNT,
                 B.LookIn_TEXT,
                 B.County_IDNO,
                 B.RowCount_NUMB,
                 B.ORD_ROWNUM AS Row_num
            FROM (SELECT a.Worker_ID,
                         a.Batch_DATE,
                         a.SourceBatch_CODE,
                         a.Batch_NUMB,
                         a.SeqReceipt_NUMB,
                         a.Case_IDNO,
                         a.ObligationKey_ID,
                         a.PayorMCI_IDNO,
                         a.Trans_DATE,
                         a.Trans_AMNT,
                         a.LookIn_TEXT,
                         a.County_IDNO,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Case_IDNO, a.Trans_DATE, a.ObligationKey_ID) AS ORD_ROWNUM
                    FROM R2527_Y1 a
                   WHERE a.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
                     AND a.EndFiscal_DATE = @Ad_EndFiscal_DATE
                     AND a.TypeReport_CODE = @Ac_TypeReport_CODE
                     AND a.Line_NUMB = @An_Line_NUMB
                     AND a.TypeAsst_CODE = ISNULL(@Ac_TypeAsst_CODE, a.TypeAsst_CODE)
                     AND a.County_IDNO = ISNULL(@An_County_IDNO, a.County_IDNO)
                     AND a.Worker_ID = ISNULL(@Ac_Worker_ID, a.Worker_ID)) B
           WHERE B.ORD_ROWNUM <= @Ai_RowTo_NUMB
              OR @Ai_RowTo_NUMB = @Li_Zero_NUMB) C
   WHERE C.Row_num >= @Ai_RowFrom_NUMB
      OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB;
 END; --- End of R2527_RETRIEVE_S1


GO
