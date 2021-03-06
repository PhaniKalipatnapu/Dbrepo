/****** Object:  StoredProcedure [dbo].[EHIS_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE PROCEDURE [dbo].[EHIS_RETRIEVE_S7] (                                                                                               
 @An_MemberMci_IDNO				NUMERIC(10,0),                                               
 @Ac_OtherParty_NAME			VARCHAR(60),
 @Ad_BeginEmployment_DATE		DATE,
 @An_OthpPartyEmpl_IDNO			NUMERIC(9) OUTPUT
 )                                                                     
AS                                                                                                                                   
                                                                                                                                     
/*                                                                                                                                   
 *     PROCEDURE NAME    : EHIS_RETRIEVE_S7                                                                                           
 *     DESCRIPTION       : Retrieves the Otherparty id for the respective transaction sequence number.            
 *     DEVELOPED BY      : IMP Team                                                                                                
 *     DEVELOPED ON      : 04-OCT-2011                                                                                               
 *     MODIFIED BY       :                                                                                                           
 *     MODIFIED ON       :                                                                                                           
 *     VERSION NO        : 1                                                                                                         
*/     

BEGIN           

DECLARE @Ld_High_DATE DATE     = '12/31/9999';    

	SELECT TOP 1 @An_OthpPartyEmpl_IDNO = a.OthpPartyEmpl_IDNO 
	 FROM EHIS_Y1  a 
	      JOIN 
	      OTHP_Y1 B 
	      ON (a.OthpPartyEmpl_IDNO = B.OtherParty_IDNO)  
	WHERE MemberMci_IDNO = @An_MemberMci_IDNO
	AND b.OtherParty_NAME = @Ac_OtherParty_NAME
	AND a.BeginEmployment_DATE = @Ad_BeginEmployment_DATE 
	AND b.EndValidity_DATE = @Ld_High_DATE;                                 
                                                                                                                                     
		                                                                                                                                  
END; --END OF EHIS_RETRIEVE_S7                                                                                                                                  

GO
