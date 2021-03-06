/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S7] (
 @An_CpMci_IDNO		 NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S7
  *     DESCRIPTION       : Retrieves the CaseWelfareIdno for a given member.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
BEGIN

	DECLARE @Lc_WelfareEligIva_CODE CHAR(1) = 'A';
        
	SELECT DISTINCT I.CaseWelfare_IDNO 
	FROM IVMG_Y1 I
	WHERE I.CpMci_IDNO = @An_CpMci_IDNO
		AND I.WelfareElig_CODE IN ( @Lc_WelfareEligIva_CODE );  
                  
END;-- End of IVMG_RETRIEVE_S7

GO
