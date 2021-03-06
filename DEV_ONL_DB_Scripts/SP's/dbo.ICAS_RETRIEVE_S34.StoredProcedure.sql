/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S34]    
  	(
     @An_MemberMci_IDNO		 NUMERIC(10,0)                
    )
AS  
  
/*  
 *     PROCEDURE NAME    : ICAS_RETRIEVE_S34  
 *     DESCRIPTION       : Retrieve Respond Init Code (Interstate Indicator), Interstate Case State, Interstate Case County, Interstate Case FIPS Code and Other State Case ID from Interstate Cases table and retrieve the Case from Case Members table for the Active (A) Dependant (D) Member whose Case is Open (O) in Interstate Cases table and Case Details table with Respond Init Code equal to Initiation (I) / Responding (R).
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 14-OCT-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
    BEGIN  
  
      DECLARE  
         @Lc_StatusCaseOpen_CODE 			CHAR(1) = 'O',   
         @Lc_CaseRelationshipCp_CODE 		CHAR(1) = 'C',
         @Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'N',
         @Lc_CaseRelationshipPutFather_CODE	CHAR(1) = 'P',   
         @Lc_RespondInitInitiate_CODE 		CHAR(1) = 'I', 
         @Lc_RespondInitC_CODE              CHAR(1) = 'C',
         @Lc_RespondInitT_CODE              CHAR(1) = 'T',
         @Lc_RespondInitS_CODE              CHAR(1) = 'S',
         @Lc_RespondInitY_CODE              CHAR(1) = 'Y',  
         @Lc_RespondInitResponding_CODE 	CHAR(1) = 'R',   
         @Lc_CaseMembeStatusrActive_CODE 	CHAR(1) = 'A',   
         @Ld_High_DATE 						DATE = '12/31/9999';  
          
        SELECT cm.Case_IDNO, 
        	ic.IVDOutOfStateFips_CODE,
        	ic.IVDOutOfStateCase_ID,
        	ISNULL(ic.IVDOutOfStateOfficeFips_CODE, '00') AS IVDOutOfStateOfficeFips_CODE,
        	ISNULL(ic.IVDOutOfStateCountyFips_CODE, '000') AS IVDOutOfStateCountyFips_CODE, 
         	ic.RespondInit_CODE           
      FROM CMEM_Y1 cm JOIN ICAS_Y1  ic
      ON cm.Case_IDNO = ic.Case_IDNO
      JOIN CASE_Y1 c  
      ON  c.Case_IDNO = cm.Case_IDNO AND   
      c.Case_IDNO = ic.Case_IDNO
      WHERE   
         cm.MemberMci_IDNO = @An_MemberMci_IDNO AND   
         cm.CaseMemberStatus_CODE = @Lc_CaseMembeStatusrActive_CODE AND   
         c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE AND   
         ic.Status_CODE = @Lc_StatusCaseOpen_CODE AND   
         ic.EndValidity_DATE = @Ld_High_DATE AND   
         cm.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE) AND   
         c.RespondInit_CODE IN ( @Lc_RespondInitInitiate_CODE,@Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE, @Lc_RespondInitResponding_CODE, @Lc_RespondInitS_CODE,@Lc_RespondInitY_CODE)  
      ORDER BY Case_IDNO;  
                      
END  -- End of ICAS_RETRIEVE_S34
 

GO
