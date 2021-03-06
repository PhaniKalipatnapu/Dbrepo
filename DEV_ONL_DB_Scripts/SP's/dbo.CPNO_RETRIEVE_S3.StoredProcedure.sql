/****** Object:  StoredProcedure [dbo].[CPNO_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPNO_RETRIEVE_S3] (
 @An_Case_IDNO		 		NUMERIC(6,0),
 @Ac_CheckRecipient_CODE	CHAR(1),  
 @Ac_CheckRecipient_ID		CHAR(10),              
 @Ai_RowFrom_NUMB       	INT = 1 ,     
 @Ai_RowTo_NUMB         	INT = 10
 )
AS
 /* 
  *     PROCEDURE NAME    : CPNO_RETRIEVE_S3
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
                SELECT c.Case_IDNO , 
                       c.Batch_DATE, 
                       c.SourceBatch_CODE, 
                       c.Batch_NUMB, 
                       c.SeqReceipt_NUMB, 
                       c.CheckRecipient_ID , 
                       c.Notice_ID , 
                       c.Notice_DATE , 
                       c.Transaction_AMNT, 
                       COUNT(1) OVER() AS RowCount_NUMB, 
                       ROW_NUMBER() OVER( ORDER BY c.EventGlobalSeq_NUMB DESC) AS ORD_ROWNUM
                   FROM CPNO_Y1 c
                  WHERE c.CheckRecipient_ID = @Ac_CheckRecipient_ID 
                    AND c.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
                    AND c.Case_IDNO = ISNULL(@An_Case_IDNO,c.Case_IDNO)
               )   X
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
         )   Y
      WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
      
ORDER BY ORD_ROWNUM;
                  
END; --END OF CPNO_RETRIEVE_S3


GO
