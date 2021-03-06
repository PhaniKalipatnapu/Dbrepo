/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S45]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                              
CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S45] (
 @An_MemberMci_IDNO				NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @Ai_Count_QNTY		    		INT	 OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : MHIS_RETRIEVE_S45
 *     DESCRIPTION       : Retrieve the count of records from Member Welfare Details table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) and Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) with different Program Type and Member Status Valid (i.e. Current Date greater than Start Date and less than End Date) for both the Members. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

 BEGIN

      SET @Ai_Count_QNTY = NULL;

 DECLARE @Lc_WelfareTypeNonTanf_CODE		CHAR(1)		= 'N', 
 		 @Lc_WelfareTypeTanf_CODE 			CHAR(1)		= 'A',
 		 @Lc_CaseRelationshipPf_CODE		CHAR(1)		= 'P',
         @Lc_CaseRelationshipNcp_CODE		CHAR(1)		= 'A',
         @Ld_Current_DATE  					DATE		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
 SELECT @Ai_Count_QNTY = COUNT(1)
   FROM MHIS_Y1 sc
  -- 13549	Bug	Merg on line and batch edits are not consistent -- Starts
  WHERE sc.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
    AND NOT EXISTS (SELECT 1 
					  FROM CMEM_Y1 c 
					 WHERE c.Case_IDNO = sc.Case_IDNO 
					   AND c.MemberMci_IDNO = sc.MemberMci_IDNO 
					   AND c.CaseRelationship_CODE IN(@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPf_CODE))
    AND (
		  EXISTS (SELECT 1
					FROM MHIS_Y1 pr
				   WHERE pr.MemberMci_IDNO = @An_MemberMci_IDNO
					 AND pr.Case_IDNO !=  sc.Case_IDNO
					 AND NOT EXISTS (SELECT 1 
									  FROM CMEM_Y1 c 
									 WHERE c.Case_IDNO = pr.Case_IDNO 
									   AND c.MemberMci_IDNO = pr.MemberMci_IDNO 
									   AND c.CaseRelationship_CODE IN(@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPf_CODE)) 
				     AND @Ld_Current_DATE BETWEEN pr.Start_DATE AND pr.End_DATE 
					 AND @Ld_Current_DATE BETWEEN sc.Start_DATE AND sc.End_DATE
					 AND CASE pr.TypeWelfare_CODE
        					WHEN @Lc_WelfareTypeTanf_CODE THEN @Lc_WelfareTypeTanf_CODE
        					ELSE @Lc_WelfareTypeNonTanf_CODE
						 END <> 
						 CASE sc.TypeWelfare_CODE
							WHEN @Lc_WelfareTypeTanf_CODE THEN @Lc_WelfareTypeTanf_CODE
							ELSE @Lc_WelfareTypeNonTanf_CODE
						 END)
		-- 13624 - Unable to merge Non PA MCI to a IV-E MCI - Start
		OR EXISTS (SELECT 1
						FROM MHIS_Y1 pr
					   WHERE pr.MemberMci_IDNO = @An_MemberMci_IDNO
						 AND pr.Case_IDNO = sc.Case_IDNO
						 AND NOT EXISTS (SELECT 1 
										  FROM CMEM_Y1 c 
										 WHERE c.Case_IDNO = pr.Case_IDNO 
										   AND c.MemberMci_IDNO = pr.MemberMci_IDNO 
										   AND c.CaseRelationship_CODE IN(@Lc_CaseRelationshipNcp_CODE,@Lc_CaseRelationshipPf_CODE)) 
						 AND NOT EXISTS ( SELECT 1
											  FROM MHIS_Y1 p
											 WHERE p.MemberMci_IDNO = @An_MemberMci_IDNO
											   AND p.Case_IDNO = sc.Case_IDNO    
											   AND p.Start_DATE = sc.Start_DATE  
											   AND p.End_DATE = sc.End_DATE  
											   AND p.TypeWelfare_CODE = sc.TypeWelfare_CODE   
											   AND p.CaseWelfare_IDNO = sc.CaseWelfare_IDNO  
											   AND p.WelfareMemberMci_IDNO = sc.WelfareMemberMci_IDNO))  
		);
		-- 13624 - Unable to merge Non PA MCI to a IV-E MCI - End
	-- 13549	Bug	Merg on line and batch edits are not consistent -- Ends
END; --END OF MHIS_RETRIEVE_S45


GO
