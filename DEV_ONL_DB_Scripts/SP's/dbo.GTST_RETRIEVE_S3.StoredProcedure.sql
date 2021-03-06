/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
  
CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S3]  
(  
  	 @An_Case_IDNO      NUMERIC(6)       ,  
  	 @An_MemberMci_IDNO NUMERIC(10,0)    ,
  	 @An_Schedule_NUMB  NUMERIC(10,0)    ,             
     @Ai_RowFrom_NUMB   INT = 1          ,  
     @Ai_RowTo_NUMB     INT = 10           
 )  
AS                                                          
  
/*  
 *     PROCEDURE NAME    : GTST_RETRIEVE_S3  
 *     DESCRIPTION       : This Sp is used to retrieve the getnetic test results for the given case_id or member_id.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
  
   BEGIN  
  
      DECLARE  
         @Ld_High_DATE          DATE    = '12/31/9999',   
         @Lc_CaseRelationshipChild_CODE  CHAR(1) = 'D',
         @Lc_CaseMemberStatusActive_CODE CHAR(1)='A';  
                                                       
 SELECT  Y.MemberMci_IDNO,   
       	 Y.Case_IDNO,   
       	 Y.Last_NAME,  
       	 Y.Suffix_NAME,  
       	 Y.First_NAME,  
    	 Y.Middle_NAME,   
    	 Y.Test_DATE,   
    	 Y.TypeTest_CODE,   
    	 Y.ResultsReceived_DATE,   
    	 Y.TestResult_CODE,   
    	 Y.Probability_PCT,   
    	 Y.Schedule_NUMB,   
    	 Y.WorkerUpdate_ID,   
    	 Y.TransactionEventSeq_NUMB,
    	 Y.CaseRelationship_CODE   ,
    	 Y.RowCount_NUMB   
    	 FROM (SELECT   X.MemberMci_IDNO,   
        				X.Case_IDNO,   
        				X.Last_NAME,   
        				X.Suffix_NAME,  
        				X.First_NAME,  
        				X.Middle_NAME,  
        				X.Test_DATE,   
        				X.TypeTest_CODE,   
        				X.ResultsReceived_DATE,   
        				X.TestResult_CODE,   
        				X.Probability_PCT,   
        				X.Schedule_NUMB,   
        				X.WorkerUpdate_ID,   
        				X.TransactionEventSeq_NUMB,   
        				(SELECT CaseRelationship_CODE 
        								FROM CMEM_Y1 c 
										WHERE c.Case_IDNO=@An_Case_IDNO 
										AND c.MemberMci_IDNO=@An_MemberMci_IDNO
										AND c.CaseMemberStatus_CODE=@Lc_CaseMemberStatusActive_CODE) AS CaseRelationship_CODE,
        				X.RowCount_NUMB ,   
        				X.ORD_ROWNUM  
        				FROM (SELECT 	a.MemberMci_IDNO,   
            							a.Case_IDNO,   
            							b.Last_NAME   ,  
            							b.Suffix_NAME ,  
           								b.First_NAME  ,  
           								b.Middle_NAME ,      
           								a.Test_DATE,   
           								a.TypeTest_CODE,   
           								a.ResultsReceived_DATE,   
           								a.TestResult_CODE,   
           								a.Probability_PCT,   
           								a.Schedule_NUMB,   
           								a.WorkerUpdate_ID,   
           								a.TransactionEventSeq_NUMB,   
           								COUNT(1) OVER() AS RowCount_NUMB ,   
           								ROW_NUMBER() OVER(ORDER BY a.Update_DTTM DESC) AS ORD_ROWNUM  
           													 FROM GTST_Y1 a JOIN DEMO_Y1 b  
           								     				 ON ( a.MemberMci_IDNO = b.MemberMci_IDNO )  
           								 					 WHERE a.Case_IDNO = @An_Case_IDNO   
           								 					 AND EXISTS (SELECT 1  
           								    									FROM CMEM_Y1 c  
           								    									WHERE  c.Case_IDNO = a.Case_IDNO   
           								    									AND  c.MemberMci_IDNO = a.MemberMci_IDNO   
           								    									AND  c.CaseRelationship_CODE = @Lc_CaseRelationshipChild_CODE )   
            												 AND  a.Schedule_NUMB = @An_Schedule_NUMB  
            												 AND  a.EndValidity_DATE = @Ld_High_DATE )   X  
     		WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB )   Y  
      WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB  
ORDER BY ORD_ROWNUM;  
                   
END    --End of GTST_RETRIEVE_S3;  
  

GO
