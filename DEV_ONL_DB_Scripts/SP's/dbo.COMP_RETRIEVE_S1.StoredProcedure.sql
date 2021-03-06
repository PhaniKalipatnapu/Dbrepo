/****** Object:  StoredProcedure [dbo].[COMP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE PROCEDURE [dbo].[COMP_RETRIEVE_S1] (  
	 @An_OrderSeq_NUMB		     NUMERIC(2,0),
     @An_Case_IDNO	             NUMERIC(6,0),
     @Ad_From_DATE		         DATE,  
     @Ad_To_DATE		         DATE ,      
     @Ac_OrderedParty_CODE		 CHAR(1),   
     @Ac_ComplianceStatus_CODE	 CHAR(2),  
     @Ac_ComplianceType_CODE	 CHAR(2),
     @Ai_RowFrom_NUMB            INT = 1,  
     @Ai_RowTo_NUMB              INT = 10      
)
AS    
/*  
 *     PROCEDURE NAME    : COMP_RETRIEVE_S1  
 *     DESCRIPTION       : Retrieves the compliance schedule details for a case. 
 *     DEVELOPED BY      : IMP TEAM 
 *     DEVELOPED ON      : 17-JAN-2012
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
BEGIN  
      DECLARE   @Ld_High_DATE	 DATE = '12/31/9999';
          
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
			 Y.TransactionEventSeq_NUMB ,   
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
					 X.TransactionEventSeq_NUMB,   
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
							 a.TransactionEventSeq_NUMB,   
							 COUNT(1) OVER() AS row_count,   
							 ROW_NUMBER() OVER(ORDER BY a.Effective_DATE DESC, a.TransactionEventSeq_NUMB DESC) AS ORD_ROWNUM  
						FROM COMP_Y1 a  JOIN  SORD_Y1 b
						  ON a.OrderSeq_NUMB = b.OrderSeq_NUMB    
						 AND a.Case_IDNO              = b.Case_IDNO
					   WHERE a.Case_IDNO              = @An_Case_IDNO   
						 AND (a.ComplianceType_CODE   = @Ac_ComplianceType_CODE 
								OR @Ac_ComplianceType_CODE IS NULL)    
						 AND (a.ComplianceStatus_CODE = @Ac_ComplianceStatus_CODE 
								OR @Ac_ComplianceStatus_CODE IS NULL)  
						 AND (a.OrderedParty_CODE     = @Ac_OrderedParty_CODE 
								OR @Ac_OrderedParty_CODE IS NULL)    
				   		 AND (a.Effective_DATE        >= ISNULL(@Ad_From_DATE, a.Effective_DATE) 
				   				AND a.Effective_DATE <= ISNULL(@Ad_To_DATE, a.Effective_DATE))    
						 AND (a.OrderSeq_NUMB         = @An_OrderSeq_NUMB 
								OR @An_OrderSeq_NUMB IS NULL) 
						 AND a.EndValidity_DATE       = @Ld_High_DATE    
						 AND b.EndValidity_DATE       = @Ld_High_DATE  
				   )   X  
				WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB  
			 )   Y  
		  WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB  
	ORDER BY ORD_ROWNUM;  
                    
END;  -- END OF COMP_RETRIEVE_S1

GO
