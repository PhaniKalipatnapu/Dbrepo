/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S18]
(
	@An_Case_IDNO		NUMERIC(6,0),
	@Ad_SOIStatus_DATE	DATE OUTPUT
)
AS
 
/*                                                                                     
  *     PROCEDURE NAME    : EHIS_RETRIEVE_S18                                            
  *     DESCRIPTION       : This procedure is used to retrieve the Source of Income date.
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/09/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN
 
		SET @Ad_SOIStatus_DATE = NULL;
 
	DECLARE @Lc_CaseMemberStatusA_CODE	CHAR(1) = 'A',
			@Lc_Yes_INDC				CHAR(1) = 'Y';
 
	 SELECT @Ad_SOIStatus_DATE = MAX(e.SourceReceived_DATE) 
	   FROM EHIS_Y1 e JOIN CMEM_Y1 c
	 	ON e.MemberMci_IDNO			= c.MemberMci_IDNO
	  WHERE c.Case_IDNO				= @An_Case_IDNO
	    AND e.Status_CODE			= @Lc_Yes_INDC
	    AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE;
	 
END --End Of Procedure EHIS_RETRIEVE_S18
 

GO
