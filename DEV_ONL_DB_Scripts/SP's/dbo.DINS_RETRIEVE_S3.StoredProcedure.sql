/****** Object:  StoredProcedure [dbo].[DINS_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE [dbo].[DINS_RETRIEVE_S3]  (  
     @An_MemberMci_IDNO		 	NUMERIC(10,0),  
     @An_OthpInsurance_IDNO		NUMERIC(9,0) ,  
     @Ac_InsuranceGroupNo_TEXT	CHAR(25)     ,  
     @Ac_PolicyInsNo_TEXT		CHAR(20)     ,  
     @Ad_Begin_DATE				DATE         ,  
     @Ad_End_DATE				DATE               
     )  
AS  
  
/*  
 *     PROCEDURE NAME    : DINS_RETRIEVE_S3  
 *     DESCRIPTION       : Retrieve County Name by deriving it from last name, first name and middle initial of the Member, Members social security number, Members date of birth from Member Demographics table and retrieve Dependent's ID for whom the insurance is provided, Indicators such as Insurance Coverage Indicator as Y, Participant is eligible for Dental Insurance, Participant is eligible for Medical Insurance, Participant is eligible for Vision Insurance, Participant is eligible for Mental Insurance, Participant is eligible for Prescription Drugs, Date on which the Insurance was Verified, Verified status code, Unique Sequence Number that will be generated for any given Transaction on the Table, etc., from Dependant Insurance table for Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant, Date from the which the Insurance Policy Starts, Date at which the Insurance Policy Ends and for the given Unique number assigned by the system to the participant ( This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent) whose Dependent Member (for whom the insurance is provided) exists in Member Demographics table and exists in Case Members table as an Active Member for the Open (O) Case in Case Details table for the given Member in Case Members table who is an Active Non-Custodial Parent (A) / Custodial Parent (C).
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 18-OCT-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
    BEGIN  
  
      DECLARE  
         @Lc_StatusCaseOpen_CODE            CHAR(1) = 'O',   
         @Lc_No_INDC                        CHAR(1) = 'N',   
         @Lc_Yes_INDC                       CHAR(1) = 'Y',   
         @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',   
         @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',   
         @Lc_Space_TEXT                     CHAR(1) = ' ',   
         @Lc_CaseMembeStatusActive_CODE    	CHAR(1) = 'A',   
         @Ld_High_DATE                  	DATE	= '12/31/9999',
         @Lc_Empty_TEXT						CHAR(1)	='';
          
        SELECT DISTINCT
         DN.ChildMCI_IDNO, 
         DN.Begin_DATE ,  
         DN.End_DATE,  
         DN.WorkerUpdate_ID ,  
         DN.DentalIns_INDC ,  
         DN.MedicalIns_INDC ,  
         DN.VisionIns_INDC ,  
         DN.MentalIns_INDC ,  
         DN.PrescptIns_INDC ,  
         DN.DescriptionOthers_TEXT ,  
         DN.Status_DATE,   
         DN.Status_CODE,   
         DN.TransactionEventSeq_NUMB,    
         @Lc_Yes_INDC AS InsCoveredFlag_INDC,           
         D.Last_NAME,  
         D.First_NAME,  
         D.Middle_NAME ,  
         D.MemberSsn_NUMB,   
         D.Birth_DATE,  
         CM.Case_IDNO         
      FROM DINS_Y1 DN JOIN CMEM_Y1 CM 
      ON DN.ChildMCI_IDNO = CM.MemberMci_IDNO
      JOIN DEMO_Y1 D 
      ON D.MemberMci_IDNO = CM.MemberMci_IDNO
      WHERE   
         DN.MemberMci_IDNO = @An_MemberMci_IDNO AND   
         CM.Case_IDNO IN   
         (  
            SELECT x.Case_IDNO  
            FROM CMEM_Y1 x JOIN CASE_Y1 v  
            ON v.Case_IDNO = x.Case_IDNO 
            WHERE v.StatusCase_CODE = @Lc_StatusCaseOpen_CODE AND   
     		   x.MemberMci_IDNO = @An_MemberMci_IDNO AND   
               x.CaseRelationship_CODE IN ( @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE ) AND   
               x.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE  
         ) AND   
         CM.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE AND   
         DN.OthpInsurance_IDNO = @An_OthpInsurance_IDNO AND   
         DN.EndValidity_DATE = @Ld_High_DATE AND   
         ISNULL(DN.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT) AND   
         ISNULL(DN.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT) AND             
         CM.MemberMci_IDNO != @An_MemberMci_IDNO AND   
         DN.Begin_DATE BETWEEN @Ad_Begin_DATE AND ISNULL(@Ad_End_DATE, @Ld_High_DATE) AND   
         DN.End_DATE BETWEEN @Ad_Begin_DATE AND ISNULL(@Ad_End_DATE, @Ld_High_DATE)  
       UNION  
      SELECT DISTINCT
      	 CM.MemberMci_IDNO, 
      	 NULL AS Begin_DATE,   
         NULL AS End_DATE,   
         CM.WorkerUpdate_ID,   
         @Lc_No_INDC AS DentalIns_INDC,   
         @Lc_No_INDC AS MedicalIns_INDC,   
         @Lc_No_INDC AS VisionIns_INDC,   
         @Lc_No_INDC AS MentalIns_INDC,   
         @Lc_No_INDC AS PrescptIns_INDC,   
         @Lc_Space_TEXT AS DescriptionOthers_TEXT,   
         NULL AS Status_DATE,   
         @Lc_Empty_TEXT AS Status_CODE,   
         CM.TransactionEventSeq_NUMB,    
         @Lc_No_INDC AS InsCoveredFlag_INDC,             
         D.Last_NAME ,  
         D.First_NAME ,  
         D.Middle_NAME,   
         D.MemberSsn_NUMB,   
         D.Birth_DATE,  
         CM.Case_IDNO         
      FROM CMEM_Y1 CM JOIN DEMO_Y1 D  
      ON D.MemberMci_IDNO = CM.MemberMci_IDNO 
      WHERE   
         CM.MemberMci_IDNO NOT IN   
         (  
            SELECT DISTINCT i.ChildMCI_IDNO  
            FROM DINS_Y1 i  
            WHERE   
               i.MemberMci_IDNO = @An_MemberMci_IDNO AND   
               i.OthpInsurance_IDNO = @An_OthpInsurance_IDNO AND   
               ISNULL(i.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT) AND   
               ISNULL(i.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT) AND   
               i.EndValidity_DATE = @Ld_High_DATE AND   
               i.Begin_DATE BETWEEN @Ad_Begin_DATE AND ISNULL(@Ad_End_DATE, @Ld_High_DATE) AND   
               i.End_DATE BETWEEN @Ad_Begin_DATE AND ISNULL(@Ad_End_DATE, @Ld_High_DATE)  
         ) AND   
         CM.Case_IDNO IN   
         (  
            SELECT x.Case_IDNO  
            FROM CMEM_Y1 x JOIN CASE_Y1 v 
            ON v.Case_IDNO = x.Case_IDNO 
            WHERE v.StatusCase_CODE = @Lc_StatusCaseOpen_CODE AND   
               x.CaseRelationship_CODE IN ( @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE ) AND   
               x.MemberMci_IDNO = @An_MemberMci_IDNO AND   
               x.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE  
         ) AND   
         CM.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE AND   
         CM.MemberMci_IDNO != @An_MemberMci_IDNO;  
  
                    
END  -- End of DINS_RETRIEVE_S3 


GO
