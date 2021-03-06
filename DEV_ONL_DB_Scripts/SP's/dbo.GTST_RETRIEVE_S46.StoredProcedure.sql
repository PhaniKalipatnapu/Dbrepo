/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S46]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S46]
(  
     @An_Case_IDNO                            NUMERIC(6)  ,  
     @An_MemberMci_IDNO                       NUMERIC(10)          
 )  
AS  
  
/*  
*      PROCEDURE NAME    : GTST_RETRIEVE_S46  
 *     DESCRIPTION       : This sp will retrieve Member mci and schedule number  of NCP record  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  
   BEGIN  
  
      DECLARE  
         @Lc_TestReslutConducted_CODE CHAR(1) = 'K',  
         @Lc_TestReslutCancel_CODE    CHAR(1) = 'C',  
         @Lc_CaseRealtionshipNcp_CODE  CHAR(1) ='A',  
         @Lc_CaseRealtionshipPf_CODE  CHAR(1) ='P',  
         @Lc_CaseMemberStatusActive_CODE  CHAR(1) ='A',  
         @Ld_High_DATE     DATE    = '12/31/9999',  
         @Lc_TestReslutFailedToAppear_CODE  CHAR(1)='F';  
           
      SELECT  Schedule_NUMB   
				FROM GTST_Y1 g  
				WHERE g.Case_IDNO = @An_Case_IDNO  
				AND g.MemberMci_IDNO IN (SELECT MemberMci_IDNO   
												FROM CMEM_Y1 c  
												WHERE c.case_idno=@An_Case_IDNO  
												AND c.caserelationship_code IN (@Lc_CaseRealtionshipNcp_CODE,@Lc_CaseRealtionshipPf_CODE)   
												AND c.casememberstatus_code=@Lc_CaseMemberStatusActive_CODE)  
				AND g.EndValidity_DATE=@Ld_High_DATE 
				AND g.TestResult_CODE NOT IN (@Lc_TestReslutConducted_CODE,@Lc_TestReslutCancel_CODE)  
				AND NOT EXISTS ( SELECT 1 
										FROM GTST_Y1 s 
										WHERE s.Case_IDNO = @An_Case_IDNO  
										AND s.Schedule_NUMB  = g.Schedule_NUMB  
										AND s.MemberMci_IDNO = @An_MemberMci_IDNO    
										AND s.EndValidity_DATE=@Ld_High_DATE    
										AND s.TestResult_CODE NOT IN (@Lc_TestReslutCancel_CODE,@Lc_TestReslutFailedToAppear_CODE) );
                
          
END  --- END GTST_RETRIEVE_S46
  

GO
