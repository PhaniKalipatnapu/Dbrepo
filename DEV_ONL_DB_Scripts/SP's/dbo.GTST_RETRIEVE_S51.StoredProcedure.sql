/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S51]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S51]  
(  
     @An_Case_IDNO            NUMERIC(6)           ,  
     @An_Schedule_NUMB        NUMERIC(10)          ,  
     @Ac_Exists_INDC          CHAR(1)      OUTPUT    
 )  
AS  
/*  
*      PROCEDURE NAME    : GTST_RETRIEVE_S51  
 *     DESCRIPTION       : This sp will retrieve Member mci and schedule number  of NCP record  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-AUG-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
  
   BEGIN  
  
      DECLARE  
         @Lc_TestReslutScheduled_CODE CHAR(1) = 'S',  
         @Lc_CaseRealtionshipDep_CODE  CHAR(1) ='D',  
         @Lc_CaseMemberStatusActive_CODE  CHAR(1) ='A',  
         @Lc_TestReslutConducted_CODE CHAR(1) = 'K',    
         @Lc_TestReslutCancel_CODE    CHAR(1) = 'C',    
         @Lc_TestReslutFailedToAppear_CODE    CHAR(1) = 'F',    
         @Ld_High_DATE     DATE    = '12/31/9999',  
         @Lc_Yes_TEXT   CHAR(1) = 'Y',      
         @Lc_No_TEXT    CHAR(1) = 'N';      
           
         SET @Ac_Exists_INDC = @Lc_No_TEXT;      
           
        SELECT  @Ac_Exists_INDC = @Lc_Yes_TEXT    
    FROM  GTST_Y1 g  
    WHERE g.Schedule_Numb = @An_Schedule_NUMB  
    AND g.MemberMci_Idno IN (SELECT Membermci_idno   
            FROM CMEM_Y1   
             WHERE Case_idno =@An_Case_IDNO  
             AND  caserelationship_code=@Lc_CaseRealtionshipDep_CODE  
             AND casememberstatus_code=@Lc_CaseMemberStatusActive_CODE)  
      AND g.TestResult_CODE NOT IN (@Lc_TestReslutConducted_CODE,@Lc_TestReslutCancel_CODE,@Lc_TestReslutFailedToAppear_CODE)    
      AND g.Endvalidity_Date =@Ld_High_DATE  
      AND g.TestResult_Code  =@Lc_TestReslutScheduled_CODE ;  
  
END ;  -- GTST_RETRIEVE_S51
GO
