/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S20] 
( 
	@An_Case_IDNO				NUMERIC(6,0),
	@Ad_Begin_DATE				DATE,
	@Ad_End_DATE				DATE,
	@Ac_DpCovered_INDC			CHAR(1)		OUTPUT
)   
AS
/*
 *     PROCEDURE NAME    : EHIS_RETRIEVE_S20
 *     DESCRIPTION       : This procedure is used to retrieve the dependent coverage indication for Medical support details according to the given input.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN	
	    SET @Ac_DpCovered_INDC			= NULL;

	DECLARE @Ld_High_DATE				DATE    = '12/31/9999',
	        @Lc_InsOrderedA_CODE			CHAR(1) = 'A',
	        @Lc_InsOrderedU_CODE			CHAR(1) = 'U',
	        @Lc_InsOrderedC_CODE			CHAR(1) = 'C',
	        @Lc_InsOrderedO_CODE			CHAR(1) = 'O',
	        @Lc_InsOrderedB_CODE			CHAR(1) = 'B',
	        @Lc_InsOrderedD_CODE			CHAR(1) = 'D',
	        @Lc_CaseMemberStatusA_CODE		CHAR(1) = 'A',
	        @Lc_CaseRelationshipC_CODE		CHAR(1) = 'C',
	        @Lc_CaseRelationshipA_CODE		CHAR(1) = 'A',
	        @Lc_Status_CODE					CHAR(1) = 'Y',
	        @Lc_EmployerPrime_INDC			CHAR(1) = 'Y';
	
			 SELECT TOP 1 @Ac_DpCovered_INDC	= e.DpCoverageAvlb_INDC
			   FROM EHIS_Y1 e JOIN CMEM_Y1 c 
				 ON e.MemberMci_IDNO = c.MemberMci_IDNO
				    JOIN (SELECT CASE 
								  WHEN s.InsOrdered_Code IN (@Lc_InsOrderedA_CODE,@Lc_InsOrderedU_CODE)
									THEN @Lc_InsOrderedA_CODE
								  WHEN s.InsOrdered_Code IN (@Lc_InsOrderedC_CODE,@Lc_InsOrderedO_CODE)
									THEN @Lc_InsOrderedC_CODE
								  WHEN S.InsOrdered_Code IN (@Lc_InsOrderedB_CODE,@Lc_InsOrderedD_CODE)
									THEN @Lc_InsOrderedB_CODE
							     END InsOrdered_Code, 
							     s.Case_IDNO 
						    FROM SORD_Y1 s 
						   WHERE s.Case_IDNO = @An_Case_IDNO
						     AND s.OrderEnt_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE) a
			     ON c.Case_IDNO = a.Case_IDNO
			  WHERE ((a.InsOrdered_Code = @Lc_InsOrderedB_CODE 
					  AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipC_CODE,@Lc_CaseRelationshipA_CODE))
					OR c.CaseRelationship_CODE = a.InsOrdered_Code)
			    AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
			    AND e.EndEmployment_DATE = @Ld_High_DATE
			    AND e.EmployerPrime_INDC = @Lc_EmployerPrime_INDC
			    AND e.Status_Code = @Lc_Status_CODE
		   ORDER BY e.BeginEmployment_DATE DESC;
                      
END;  --END OF EHIS_RETRIEVE_S20


GO
