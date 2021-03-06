/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S6] ( 
 @Ac_CheckRecipient_CODE	CHAR(1)					,
 @Ad_From_DATE				DATE					,
 @Ad_To_DATE				DATE					,
 @An_ReceiptCnt_QNTY		NUMERIC(6,0)	OUTPUT	,
 @An_Recoup_AMNT         	NUMERIC(22,2)	OUTPUT
)     
     
AS

/*
 *     PROCEDURE NAME    : POFL_RETRIEVE_S6
 *     DESCRIPTION       : Retrieve the Total Amount of the  recoupment transactions ,Total number of the recoupment transaction  for the date range.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

      SELECT @An_ReceiptCnt_QNTY = NULL,
			 @An_Recoup_AMNT = NULL;

      DECLARE
         @Li_Zero_NUMB	SMALLINT = 0;

      SELECT @An_ReceiptCnt_QNTY = 
         (
            SELECT COUNT(1) 
            FROM (
                  SELECT a2.Batch_DATE, 
						 a2.Batch_NUMB, 
						 a2.SeqReceipt_NUMB, 
						 a2.SourceBatch_CODE
                  FROM POFL_Y1   a2
                  WHERE a2.Transaction_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE  
                    AND (a2.RecOverpay_AMNT + a2.RecAdvance_AMNT > @Li_Zero_NUMB)  
                    AND a2.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE, a2.CheckRecipient_CODE)  
                  GROUP BY 
                     a2.Batch_DATE, 
                     a2.SourceBatch_CODE, 
                     a2.Batch_NUMB, 
                     a2.SeqReceipt_NUMB, 
                     a2.Transaction_DATE,
                     a2.CheckRecipient_ID ,
                     a2.CheckRecipient_CODE, 
                     a2.Case_IDNO, 
                     a2.TypeRecoupment_CODE
               )  AS X
         ), 
         @An_Recoup_AMNT = ISNULL(SUM(a.RecOverpay_AMNT + a.RecAdvance_AMNT), @Li_Zero_NUMB)
      FROM POFL_Y1   a
      WHERE  a.Transaction_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE  
        AND (a.RecOverpay_AMNT + a.RecAdvance_AMNT > @Li_Zero_NUMB)  
        AND a.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE, a.CheckRecipient_CODE);
                  
END;  --END OF POFL_RETRIEVE_S6


GO
