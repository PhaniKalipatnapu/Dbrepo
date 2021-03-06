/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S33]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S33] (
      @An_Case_IDNO		 NUMERIC(6,0),
      @An_OrderSeq_NUMB	 NUMERIC(2,0)                   
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S33
 *     DESCRIPTION       : Retrieve the Obligation details that to display in obligation grid for entry and modification screen function.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN
      DECLARE
         @Lc_RelationshipCaseCp_CODE		CHAR(1) = 'C', 
         @Lc_RelationshipCaseDp_CODE		CHAR(1) = 'D', 
         @Lc_StatusCaseMemberActive_CODE	CHAR(1) = 'A',          
         @Lc_ObleLevel_CODE					CHAR(1) = 'O', 
         @Lc_PreviewN_CODE					CHAR(1) = 'N',
         @Lc_TypeDebtNF_CODE				CHAR(2) = 'NF',
         @Ld_High_DATE						DATE	= '12/31/9999',
         @Ld_Current_DATE					DATE	=  DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT d.Last_NAME,  	   
               d.Suffix_NAME,
               d.First_NAME, 
               d.Middle_NAME, 
			   a.MemberMci_IDNO, 
			   a.TypeDebt_CODE, 
			   a.Fips_CODE, 
			   a.CheckRecipient_ID, 
			   a.FreqPeriodic_CODE, 
			   a.Periodic_AMNT, 
			   a.BeginObligation_DATE, 
			   a.EndObligation_DATE,  
			   dbo.Batch_Common$SF_GET_OBLEARREARS(a.Case_IDNO,a.OrderSeq_NUMB,a.ObligationSeq_NUMB,a.TypeDebt_CODE,@Lc_ObleLevel_CODE,@Lc_PreviewN_CODE) AS Arrears_AMNT, 
			   dbo.Batch_Common$SF_GET_ALLOCATED_IND(a.Case_IDNO, a.OrderSeq_NUMB, a.TypeDebt_CODE) AS AllocatedInd_INDC,
			   a.ObligationSeq_NUMB, 
			   SUBSTRING(a.TypeDebt_CODE, 2, 1) AS OrderByDebt_CODE, 
			   a.CheckRecipient_CODE 
		  FROM OBLE_Y1 a 
		       JOIN CMEM_Y1 b
            ON b.Case_IDNO = a.Case_IDNO 
           AND b.MemberMci_IDNO = a.MemberMci_IDNO
               JOIN DEMO_Y1 d
		    ON d.MemberMci_IDNO = a.MemberMci_IDNO
         WHERE a.Case_IDNO = @An_Case_IDNO 
           AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
           AND a.TypeDebt_CODE <> @Lc_TypeDebtNF_CODE
           AND a.EndValidity_DATE = @Ld_High_DATE 
           AND (( a.BeginObligation_DATE <= @Ld_Current_DATE 
			       AND a.EndObligation_DATE =(SELECT MAX(d.EndObligation_DATE)
											   FROM OBLE_Y1 d
								 			  WHERE d.Case_IDNO = a.Case_IDNO 
												AND d.OrderSeq_NUMB = a.OrderSeq_NUMB 
												AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
												AND d.BeginObligation_DATE <= @Ld_Current_DATE 
												AND d.EndValidity_DATE = @Ld_High_DATE)) 
			     OR (a.BeginObligation_DATE > @Ld_Current_DATE 
			           AND a.EndObligation_DATE =(SELECT MIN(d.EndObligation_DATE)
													 FROM OBLE_Y1 d
													WHERE d.Case_IDNO = a.Case_IDNO 
													  AND d.OrderSeq_NUMB = a.OrderSeq_NUMB 
													  AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
													  AND d.BeginObligation_DATE >@Ld_Current_DATE 
													  AND d.EndValidity_DATE = @Ld_High_DATE) 
	                   AND NOT EXISTS ( SELECT 1 
										 FROM OBLE_Y1 d
										WHERE d.Case_IDNO = a.Case_IDNO 
										AND d.OrderSeq_NUMB = a.OrderSeq_NUMB 
										AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
										AND d.BeginObligation_DATE <= @Ld_Current_DATE
										AND d.EndValidity_DATE = @Ld_High_DATE))) 					 
           AND b.CaseRelationship_CODE IN ( @Lc_RelationshipCaseCp_CODE, @Lc_RelationshipCaseDp_CODE ) 
           AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
       ORDER BY OrderByDebt_CODE DESC;
                  
END; --END OF OBLE_RETRIEVE_S33


GO
