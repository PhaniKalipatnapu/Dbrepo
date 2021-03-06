/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S210]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S210] (    
     @An_PayorMci_IDNO				NUMERIC(10,0),  
     @Ac_Exists_INDC                CHAR(1) OUTPUT
     )              
AS    
/*  
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S210  
 *     DESCRIPTION       : Returns Y, if active dependents found in the Open cases of the given Payor with Active support .  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 02-OCT-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
 
BEGIN  
     
   DECLARE     
     @Lc_CaseRelationshipNcp_CODE		CHAR(1)		= 'A', 
     @Lc_CaseRelationshipPf_CODE		CHAR(1)		= 'P',
     @Lc_CaseRelationshipCp_CODE		CHAR(1)		= 'C',
     @Lc_CaseRelationshipDp_CODE		CHAR(1)		= 'D',
     @Lc_CaseMemberStatusActive_CODE	CHAR(1)		= 'A',
     @Lc_CaseStatusOpen_CODE			CHAR(1)		= 'O',
     @Ld_High_DATE    					DATE		= '12/31/9999',
  	 @Ld_Process_DATE					DATE		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  	 
  	SET @Ac_Exists_INDC					= 'N';
     	
	SELECT @Ac_Exists_INDC = 'Y'
	  FROM CMEM_Y1 b 
		   JOIN CASE_Y1 c 
		ON b.Case_IDNO			   = c.Case_IDNO
		   JOIN SORD_Y1 d
		ON c.Case_IDNO			   = d.Case_IDNO	
		   JOIN CMEM_Y1 e
		ON d.Case_IDNO			   = e.Case_IDNO  
	 WHERE b.MemberMci_IDNO		   = @An_PayorMci_IDNO 
	   AND b.CaseRelationship_CODE IN ( @Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE, @Lc_CaseRelationshipCp_CODE)	
	   AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
	   AND c.StatusCase_CODE	   = @Lc_CaseStatusOpen_CODE
	   AND @Ld_Process_DATE BETWEEN d.OrderEffective_DATE AND d.OrderEnd_DATE
	   AND d.EndValidity_DATE	   = @Ld_High_DATE	
	   AND e.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
	   AND e.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
	   
END;


GO
