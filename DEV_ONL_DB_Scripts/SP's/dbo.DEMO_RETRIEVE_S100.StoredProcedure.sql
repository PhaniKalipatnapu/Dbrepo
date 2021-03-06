/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S100]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S100] (
     @An_Case_IDNO		            NUMERIC(6,0),
     @An_OrderSeq_NUMB		        NUMERIC(2,0),
     @Ad_BeginObligation_DATE		DATE,
     @Ac_TypeDebt_CODE		        CHAR(2)
 )               
AS
/*
 *     PROCEDURE NAME    : DEMO_RETRIEVE_S100
 *     DESCRIPTION       : Retrieve the case member details from to display in pop up screen of non allocatd obj screen.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		  DECLARE @Lc_RelationshipCaseCp_CODE		CHAR(1) = 'C', 
				  @Lc_RelationshipCaseDp_CODE		CHAR(1) = 'D', 
				  @Lc_StatusCaseMemberActive_CODE	CHAR(1) = 'A';
	        
        SELECT a.MemberMci_IDNO ,
               b.Last_NAME,  	   
               b.Suffix_NAME,
               b.First_NAME, 
               b.Middle_NAME, 
         	   b.Birth_DATE , 
         	   b.Emancipation_DATE,
        	   b.MemberSsn_NUMB , 
         	   a.CaseRelationship_CODE ,   	   
         	   dbo.Batch_Common$SF_OBLE_ACTIVE( a.Case_IDNO, @An_OrderSeq_NUMB, a.MemberMci_IDNO, @Ac_TypeDebt_CODE, 
                                                @Ad_BeginObligation_DATE) AS Oble_INDC
          FROM CMEM_Y1   a
               JOIN DEMO_Y1   b
            ON a.MemberMci_IDNO = b.MemberMci_IDNO   
         WHERE a.Case_IDNO = @An_Case_IDNO 
         AND   a.CaseRelationship_CODE IN ( @Lc_RelationshipCaseDp_CODE,@Lc_RelationshipCaseCp_CODE ) 
         AND   a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE 	         
         ORDER BY b.Emancipation_DATE, a.CaseRelationship_CODE;
                  
END;--End of DEMO_RETRIEVE_S100 


GO
