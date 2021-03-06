/****** Object:  StoredProcedure [dbo].[COMP_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE  [dbo].[COMP_RETRIEVE_S5] (   
     @Ai_RowFrom_NUMB            INT = 1,  
     @Ai_RowTo_NUMB              INT = 10,    
     @An_Compliance_IDNO		 NUMERIC(19,0)
)          
AS    
/*  
 *     PROCEDURE NAME    : COMP_RETRIEVE_S5  
 *     DESCRIPTION       : Retrieves the compliance history details for the given compliance schedule number.
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 17-JAN-2012
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN    
     DECLARE @Ld_High_DATE	 DATE = '12/31/9999';  
          
      SELECT Y.Compliance_IDNO ,   
			 Y.Case_IDNO ,   
			 Y.File_ID ,   
			 Y.ComplianceType_CODE ,   
			 Y.ComplianceStatus_CODE ,   
			 Y.Effective_DATE ,   
			 Y.End_DATE ,   
			 Y.Entry_DATE ,   
			 Y.Compliance_AMNT ,   
			 Y.Freq_CODE ,    
			 Y.OrderedParty_CODE ,   
			 Y.WorkerUpdate_ID ,   
			 row_count AS RowCount_NUMB 
        FROM (SELECT X.Compliance_IDNO,   
				     X.Case_IDNO,   
				     X.File_ID,   
				     X.ComplianceType_CODE,   
				     X.ComplianceStatus_CODE,   
				     X.Effective_DATE,   
				     X.End_DATE,   
				     X.Entry_DATE,   
				     X.Compliance_AMNT,   
				     X.Freq_CODE,    
				     X.OrderedParty_CODE,   
				     X.WorkerUpdate_ID,   
				     X.ORD_ROWNUM ,   
				     X.row_count  
                FROM (SELECT a.Compliance_IDNO,   
							 a.Case_IDNO,   
							 b.File_ID,   
							 a.ComplianceType_CODE,   
							 a.ComplianceStatus_CODE,   
							 a.Effective_DATE,   
							 a.End_DATE,   
							 a.Entry_DATE,   
							 a.Compliance_AMNT,   
							 a.Freq_CODE,   
							 a.OrderedParty_CODE,   
							 a.WorkerUpdate_ID,   
							 COUNT(1) OVER() AS row_count,   
							 ROW_NUMBER() OVER(ORDER BY a.Compliance_IDNO DESC) AS ORD_ROWNUM  
					    FROM COMP_Y1   a  JOIN  SORD_Y1  b  
					      ON a.Case_IDNO = b.Case_IDNO 
						 AND a.OrderSeq_NUMB = b.OrderSeq_NUMB 
					   WHERE a.Compliance_IDNO = @An_Compliance_IDNO
						 AND a.EndValidity_DATE != @Ld_High_DATE 
						 AND b.EndValidity_DATE = @Ld_High_DATE  
               )   X  
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB  
         )   Y  
      WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB  
ORDER BY ORD_ROWNUM;  
                    
END  --END OF COMP_RETRIEVE_S5
  

GO
