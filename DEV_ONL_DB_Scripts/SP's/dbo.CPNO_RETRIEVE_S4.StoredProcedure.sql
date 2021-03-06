/****** Object:  StoredProcedure [dbo].[CPNO_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[CPNO_RETRIEVE_S4] ( 
 @Ad_Batch_DATE				DATE,
 @An_Batch_NUMB         	NUMERIC(4,0),
 @Ac_CheckRecipient_CODE	CHAR(1),   
 @Ac_CheckRecipient_ID		CHAR(10),
 @An_SeqReceipt_NUMB		NUMERIC(6,0),
 @Ac_SourceBatch_CODE		CHAR(3),
 @Ai_RowFrom_NUMB       	INT = 1,      
 @Ai_RowTo_NUMB         	INT = 10    
 )
AS
 /*
  *     PROCEDURE NAME    : CPNO_RETRIEVE_S4
  *     DESCRIPTION       : Procedure is used to get the notices for the recipient from VCPNO table     
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 01-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
  BEGIN

    SELECT Y.Case_IDNO , 
           Y.Batch_DATE,
           Y.SourceBatch_CODE, 
           Y.Batch_NUMB, 
           Y.SeqReceipt_NUMB,
           Y.CheckRecipient_ID , 
           Y.Notice_ID , 
           Y.Notice_DATE , 
           Y.Transaction_AMNT , 
           Y.RowCount_NUMB 
   FROM (
         SELECT X.Case_IDNO, 
                X.Batch_DATE,
                X.SourceBatch_CODE, 
                X.Batch_NUMB, 
                X.SeqReceipt_NUMB,
                X.CheckRecipient_ID, 
                X.Notice_ID, 
                X.Notice_DATE, 
                X.Transaction_AMNT, 
                X.RowCount_NUMB, 
                X.ORD_ROWNUM 
        FROM (
              SELECT a.Case_IDNO, 
                     a.Batch_DATE,
                     a.SourceBatch_CODE, 
                     a.Batch_NUMB, 
                     a.SeqReceipt_NUMB,
                     a.CheckRecipient_ID, 
                     a.Notice_ID, 
                     a.Notice_DATE , 
                     a.Transaction_AMNT, 
                     COUNT(1) OVER() AS RowCount_NUMB, 
                     ROW_NUMBER() OVER(ORDER BY a.EventGlobalSeq_NUMB DESC) AS ORD_ROWNUM
                  FROM CPNO_Y1 a
                  WHERE 
                     a.CheckRecipient_ID = @Ac_CheckRecipient_ID 
                     AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE 
                     AND a.Batch_DATE = @Ad_Batch_DATE 
                     AND a.Batch_NUMB = @An_Batch_NUMB 
                     AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
                     AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
               )   X
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
         )   Y
      WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
      
ORDER BY ORD_ROWNUM;
               
END; --END OF CPNO_RETRIEVE_S4


GO
