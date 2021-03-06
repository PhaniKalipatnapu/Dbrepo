/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S217]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[CMEM_RETRIEVE_S217] (
	 @An_Case_IDNO		NUMERIC(6,0),
	 @An_MemberMci_IDNO NUMERIC(10,0),	
	 @Ac_Exists_INDC	CHAR(1)			OUTPUT     
    )
AS
/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S217
 *     DESCRIPTION       : Retrieve the Existing indication of obligations from OBLE_Y1 for CP of the case.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		SET @Ac_Exists_INDC   =  'N';
		
    DECLARE
        @Lc_CaseRelationShipCP_CODE		CHAR(1) = 'C',
        @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A',
		@Lc_TypeDebtGT_CODE				CHAR(2) = 'GT',
		@Ld_High_DATE					DATE	= '12/31/9999';
    
								
	 SELECT @Ac_Exists_INDC = 'Y'
		FROM CMEM_Y1 C 
	WHERE C.Case_IDNO = @An_Case_IDNO
	  AND C.Case_IDNO = @An_MemberMci_IDNO	  	
	  AND C.CaseRelationShip_CODE = @Lc_CaseRelationShipCP_CODE
	  AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
	AND EXISTS (SELECT 1 
					FROM OBLE_Y1 O
				WHERE O.Case_IDNO = C.Case_IDNO
				  AND O.MemberMci_IDNO = C.MemberMci_IDNO
				  AND O.TypeDebt_CODE = @Lc_TypeDebtGT_CODE
				  AND O.EndValidity_DATE = @Ld_High_DATE );			  
				 
	
							
END; --END OF CMEM_RETRIEVE_S217								


GO
