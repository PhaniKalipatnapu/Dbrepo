/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S20] (
@Ac_SourceReceipt_CODE	CHAR(2)		,
@Ad_From_DATE			DATE		,
@Ad_To_DATE				DATE		,
@Ai_RowFrom_NUMB      	INT = 1		,
@Ai_RowTo_NUMB			INT = 10	
)                        	
AS

/*
 *     PROCEDURE NAME    : RCTH_RETRIEVE_S20
 *     DESCRIPTION       : Retrieve Receipt details for a receipt source between given dates
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

      DECLARE
         @Lc_StatusBatchReconciled_CODE	CHAR(1) = 'R'			, 
         @Lc_BackOutN_INDC				CHAR(1) = 'N'			, 
         @Lc_RePostN_INDC				CHAR(1) = 'N'			,
         @Lc_SourceBatch102_CODE		CHAR(3) = '102'			,
         @Ld_High_DATE					DATE    = '12/31/9999'	, 
         @Li_Zero_NUMB					SMALLINT= 0 ;
        
        SELECT	 Z.Batch_DATE,
				 Z.SourceBatch_CODE,
				 Z.Batch_NUMB ,
				 Z.SeqReceipt_NUMB ,
				 Z.TypeRemittance_CODE ,
				 Z.Case_IDNO , 
				 Z.PayorMCI_IDNO , 
				 Z.ToDistribute_AMNT , 
				 Z.CheckNo_Text ,
				 Z.Receipt_DATE ,
				 D.MemberSsn_NUMB ,
				 D.Last_NAME,
				 D.First_NAME,
				 D.Middle_NAME,
				 D.Suffix_NAME ,
				 D.Restricted_INDC,
				 (SELECT TOP 1 UR.HighProfile_INDC
				   FROM USRT_Y1 UR
				  WHERE UR.MemberMci_IDNO = Z.PayorMCI_IDNO
					AND UR.EndValidity_DATE = @Ld_High_DATE)AS HighProfile_INDC,
				 Z.RowCount_NUMB 
      FROM ( 
       SELECT  Y.Batch_DATE,
               Y.SourceBatch_CODE,
               Y.Batch_NUMB,
               Y.SeqReceipt_NUMB ,
               Y.TypeRemittance_CODE, 
               Y.ToDistribute_AMNT, 
               Y.CheckNo_Text,
               Y.Receipt_DATE,
               Y.Case_IDNO, 
               Y.PayorMCI_IDNO, 
               Y.ORD_ROWNUM, 
               Y.RowCount_NUMB
            FROM ( 
              SELECT a.Batch_DATE,
                     a.SourceBatch_CODE ,
                     a.Batch_NUMB ,
                     a.SeqReceipt_NUMB , 
                     a.TypeRemittance_CODE , 
                     SUM(a.ToDistribute_AMNT) AS ToDistribute_AMNT, 
                     a.Receipt_DATE , 
                     a.CheckNo_Text , 
                     a.Case_IDNO, 
                     a.PayorMCI_IDNO , 
                     COUNT(1) OVER() AS RowCount_NUMB, 
                     ROW_NUMBER() OVER(ORDER BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB) AS ORD_ROWNUM
                  FROM (
                        SELECT r.Batch_DATE, 
							   r.Batch_NUMB, 
							   r.SourceBatch_CODE
                        FROM RBAT_Y1 r
                        WHERE r.StatusBatch_CODE = @Lc_StatusBatchReconciled_CODE  
                        AND r.BeginValidity_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE 
                        AND r.RePost_INDC = @Lc_RePostN_INDC  
                        AND r.EndValidity_DATE = @Ld_High_DATE
                     )  x
                     JOIN RCTH_Y1 a 
						ON  x.Batch_DATE = a.Batch_DATE 
						AND x.Batch_NUMB = a.Batch_NUMB 
						AND x.SourceBatch_CODE = a.SourceBatch_CODE 
                  WHERE a.BackOut_INDC = @Lc_BackOutN_INDC 
                  AND a.SourceReceipt_CODE = @Ac_SourceReceipt_CODE 
                  AND a.EndValidity_DATE = @Ld_High_DATE 
                  AND a.SourceBatch_CODE != @Lc_SourceBatch102_CODE
                  GROUP BY 
                     a.Batch_DATE, 
                     a.SourceBatch_CODE, 
                     a.Batch_NUMB, 
                     a.SeqReceipt_NUMB, 
                     a.TypeRemittance_CODE, 
                     a.SourceReceipt_CODE, 
                     a.Receipt_DATE, 
                     a.CheckNo_Text, 
                     a.Case_IDNO, 
                     a.PayorMCI_IDNO                     
               )   Y
            WHERE Y.ORD_ROWNUM <= @Ai_RowTo_NUMB	
              OR @Ai_RowTo_NUMB = @Li_Zero_NUMB    
         )   Z LEFT OUTER JOIN DEMO_Y1 D 
                        ON D.MemberMci_IDNO = Z.PayorMCI_IDNO
      WHERE (Z.ORD_ROWNUM >= @Ai_RowFrom_NUMB)	
		 OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)    
ORDER BY ORD_ROWNUM;
				                  
END;   --END OF RCTH_RETRIEVE_S20 


GO
