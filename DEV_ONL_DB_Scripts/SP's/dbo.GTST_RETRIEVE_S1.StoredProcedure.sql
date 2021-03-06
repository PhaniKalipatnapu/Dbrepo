/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S1]  
(
     @An_Case_IDNO              NUMERIC(6)     ,
     @An_MemberMci_IDNO         NUMERIC(10)    ,                                                             
     @Ai_RowFrom_NUMB           INT=1          ,
     @Ai_RowTo_NUMB             INT=10             
     )                                                        
AS

/*
 *     PROCEDURE NAME    : GTST_RETRIEVE_S1
 *     DESCRIPTION       : used to retrieve the getnetic test details for the given case_id or member_id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN

      DECLARE
         @Ld_High_DATE 				        DATE    = '12/31/9999', 
         @Lc_CaseRelationshipCp_CODE 	    CHAR(1) = 'C', 
         @Lc_CaseRelationshipNcp_CODE  	    CHAR(1) = 'A', 
         @Lc_CaseRelationshipPf_CODE 	    CHAR(1) = 'P', 
         @Lc_TestResultScheduled_CODE 	    CHAR(1) = 'S', 
         @Lc_TypeOthp_CODE 			        CHAR(1) = 'L', 
         @Lc_CaseMemberStatusActive_CODE 	CHAR(1) = 'A' , 
         @Lc_LocationState_CODE 			CHAR(2) = 'DE';
        
        
     
 SELECT Y.Last_NAME, 
         Y.Suffix_NAME,
         Y.First_NAME,
         Y.Middle_NAME,	
         Y.MemberMci_IDNO, 
         Y.Test_DATE , 
         Y.LocationState_CODE,
         Y.OthpLocation_IDNO,
         Y.OTHERPARTY_NAME,
         Y.Lab_NAME, 
         Y.CountyLocation_IDNO,
         Y.LocationState_CODE, 
         Y.Test_AMNT, 
         Y.PaidBy_NAME, 
         Y.Schedule_NUMB, 
         Y.WorkerUpdate_ID, 
         Y.TransactionEventSeq_NUMB, 
         Y.TypeTest_CODE, 
         Y.Case_IDNO , 
         Y.TestResult_CODE, 
         Y.RowCount_NUMB 
         FROM  (SELECT   X.Last_NAME, 
               X.Suffix_NAME,
               X.First_NAME,
               X.Middle_NAME,
               X.MemberMci_IDNO, 
               X.Test_DATE, 
               X.LocationState_CODE,
               X.OthpLocation_IDNO,
               X.OTHERPARTY_NAME,
               X.Lab_NAME,
               X.CountyLocation_IDNO,
               X.Test_AMNT, 
               X.PaidBy_NAME, 
               X.Schedule_NUMB, 
               X.WorkerUpdate_ID, 
               X.TransactionEventSeq_NUMB, 
               X.TypeTest_CODE, 
               X.Case_IDNO, 
               X.TestResult_CODE, 
               X.RowCount_NUMB , 
               X.ORD_ROWNUM 
               FROM (SELECT   a.Last_NAME, 
                     a.Suffix_NAME,
                     a.First_NAME,
                     a.Middle_NAME,
                     a.MemberMci_IDNO, 
                     a.Test_DATE, 
                     a.LocationState_CODE,
                     a.OthpLocation_IDNO,
                     a.OTHERPARTY_NAME,
                     a.Lab_NAME, 
                     a.CountyLocation_IDNO,
                     a.Test_AMNT, 
                     a.PaidBy_NAME, 
                     a.Schedule_NUMB, 
                     a.WorkerUpdate_ID, 
                     a.TransactionEventSeq_NUMB, 
                     a.TypeTest_CODE, 
                     a.Case_IDNO, 
                     a.TestResult_CODE, 
                     a.RowCount_NUMB , 
                     ROW_NUMBER() OVER(ORDER BY a.RESULT_NUM, a.Update_DTTM DESC) AS ORD_ROWNUM
                     FROM (SELECT b.Last_NAME   ,
                                  b.Suffix_NAME ,
								  b.First_NAME  ,
								  b.Middle_NAME ,
                                  a.MemberMci_IDNO, 
                                  a.Test_DATE, 
								  a.LocationState_CODE,
								  a.OthpLocation_IDNO,
                                  ( SELECT c.OtherParty_NAME
                                    FROM OTHP_Y1 c
                                    WHERE     c.OtherParty_IDNO = a.OthpLocation_IDNO 
                                          AND c.TypeOthp_CODE      = @Lc_TypeOthp_CODE 
                                          AND a.LocationState_CODE = @Lc_LocationState_CODE 
                                          AND a.EndValidity_DATE   = @Ld_High_DATE 
                                          AND c.EndValidity_DATE   = @Ld_High_DATE
                                  ) AS OTHERPARTY_NAME  , 
                                  a.Lab_NAME, 
                                  a.CountyLocation_IDNO,
								  a.Test_AMNT, 
								  a.PaidBy_NAME, 
								  a.Schedule_NUMB, 
								  a.WorkerUpdate_ID, 
								  a.TransactionEventSeq_NUMB, 
								  a.TypeTest_CODE, 
								  a.Case_IDNO, 
								  a.TestResult_CODE , 
								  CASE 
									WHEN a.TestResult_CODE = @Lc_TestResultScheduled_CODE THEN 1
								  ELSE 2
								  END AS result_num, 
								  a.Update_DTTM, 
								  COUNT(1) OVER() AS RowCount_NUMB 
								  FROM GTST_Y1 a JOIN DEMO_Y1 b
								      ON (a.MemberMci_IDNO = b.MemberMci_IDNO )
								  WHERE     a.Case_IDNO = ISNULL(@An_Case_IDNO, a.Case_IDNO) 
								  AND  a.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO, a.MemberMci_IDNO) 
								  AND  EXISTS (SELECT 1
												 FROM CMEM_Y1 d
												WHERE d.Case_IDNO = a.Case_IDNO 
												  AND d.MemberMci_IDNO = a.MemberMci_IDNO 
												  AND d.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
												  AND d.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipPf_CODE, @Lc_CaseRelationshipNcp_CODE  ) ) 
                                 AND a.EndValidity_DATE = @Ld_High_DATE
                     )   a
               )   X
        WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
         )   Y
  WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
ORDER BY ORD_ROWNUM;
                  
END  	-- End of GTST_RETRIEVE_S1;


GO
