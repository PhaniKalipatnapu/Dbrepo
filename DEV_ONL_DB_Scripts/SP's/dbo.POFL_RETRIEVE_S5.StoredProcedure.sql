/****** Object:  StoredProcedure [dbo].[POFL_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POFL_RETRIEVE_S5]  (
 @Ac_CheckRecipient_CODE	CHAR(1)		,
 @Ad_From_DATE				DATE		,
 @Ad_To_DATE				DATE		,
 @Ai_RowFrom_NUMB        	INT	= 1		,
 @Ai_RowTo_NUMB          	INT	= 10     
 )
AS

/*
 *     PROCEDURE NAME    : POFL_RETRIEVE_S5
 *     DESCRIPTION       : Retrieve the details of payments that have been recouped for the date range.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

      DECLARE
         @Ld_High_DATE		DATE	 = '12/31/9999', 
         @Li_Zero_NUMB    	SMALLINT = 0 ;

      SELECT Y.CheckRecipient_ID ,
			 Y.CheckRecipient_CODE, 
			 Y.Case_IDNO , 
			 Y.Transaction_DATE ,
			 Y.Batch_DATE, 
			 Y.SourceBatch_CODE, 
			 Y.Batch_NUMB, 
			 Y.SeqReceipt_NUMB, 
			 Y.Person_NAME, 
			 Y.Receipt_DATE , 
			 Y.RecOverAdvance_AMNT ,
            (
               SELECT COUNT(1)
               FROM (
                     SELECT a.Batch_DATE, 
                         a.Batch_NUMB, 
                         a.SeqReceipt_NUMB, 
                         a.SourceBatch_CODE
                     FROM POFL_Y1  a
                     WHERE  a.Transaction_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE  
                        AND(a.RecOverpay_AMNT + a.RecAdvance_AMNT > @Li_Zero_NUMB)  
                        AND a.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE, a.CheckRecipient_CODE) 
                     GROUP BY 
                        a.Batch_DATE, 
                        a.SourceBatch_CODE, 
                        a.Batch_NUMB, 
                        a.SeqReceipt_NUMB, 
                        a.Transaction_DATE, 
                        a.CheckRecipient_ID, 
                        a.CheckRecipient_CODE, 
                        a.Case_IDNO, 
                        a.TypeRecoupment_CODE
                  )   Z
            )  RowCount_NUMB
      FROM (
        SELECT X.Transaction_DATE, 
               X.Batch_DATE, 
               X.SourceBatch_CODE, 
               X.Batch_NUMB, 
               X.SeqReceipt_NUMB, 
               X.Receipt_DATE, 
               X.CheckRecipient_ID, 
               X.CheckRecipient_CODE,
               X.Person_NAME, 
               X.Case_IDNO, 
               X.TypeRecoupment_CODE, 
               X.RecOverAdvance_AMNT, 
               X.ORD_ROWNUM AS row_num
            FROM (
                  SELECT DISTINCT a.Batch_DATE, 
                     a.SourceBatch_CODE, 
                     a.Batch_NUMB, 
                     a.SeqReceipt_NUMB, 
                     a.Transaction_DATE, 

                        (
                           SELECT  TOP 1 z.Receipt_DATE
                           FROM RCTH_Y1  z
                           WHERE z.Batch_DATE = a.Batch_DATE  
                             AND z.Batch_NUMB = a.Batch_NUMB  
                             AND z.SourceBatch_CODE = a.SourceBatch_CODE  
                             AND z.SeqReceipt_NUMB = a.SeqReceipt_NUMB  
                             AND z.EndValidity_DATE = @Ld_High_DATE
                        ) AS Receipt_DATE, 
                     a.CheckRecipient_ID ,
                     a.CheckRecipient_CODE, 
                     dbo.BATCH_COMMON$SF_GET_MASKED_RECIPIENT_NAME(a.CheckRecipient_ID, a.CheckRecipient_CODE) AS Person_NAME, 
                     a.Case_IDNO, 
                     a.TypeRecoupment_CODE, 
                     ISNULL(SUM(a.RecOverpay_AMNT + a.RecAdvance_AMNT), @Li_Zero_NUMB) AS RecOverAdvance_AMNT,
                     ROW_NUMBER() OVER(
                        ORDER BY a.Transaction_DATE) AS ORD_ROWNUM
                  FROM POFL_Y1  a
                  WHERE a.Transaction_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
                    AND(a.RecOverpay_AMNT + a.RecAdvance_AMNT > @Li_Zero_NUMB)  
                    AND a.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE, a.CheckRecipient_CODE)  
                  GROUP BY 
                     a.Batch_DATE, 
                     a.SourceBatch_CODE, 
                     a.Batch_NUMB, 
                     a.SeqReceipt_NUMB, 
                     a.Transaction_DATE, 
                     a.CheckRecipient_ID, 
                     a.CheckRecipient_CODE, 
                     a.Case_IDNO, 
                     a.TypeRecoupment_CODE
               )  X
            WHERE (X.ORD_ROWNUM <= @Ai_RowTo_NUMB) 
				OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
         )  Y
      WHERE (Y.row_num >= @Ai_RowFrom_NUMB) 
		OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB);
                  
END;   --END OF POFL_RETRIEVE_S5  


GO
