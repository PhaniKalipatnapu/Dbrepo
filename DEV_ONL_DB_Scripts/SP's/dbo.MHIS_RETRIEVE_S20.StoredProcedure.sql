/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S20]  
     @An_Case_IDNO					NUMERIC(6,0),
     @An_MemberMci_IDNO				NUMERIC(10,0),
     @An_WelfareMemberMci_IDNO		NUMERIC(10,0)	 OUTPUT,
     @An_CaseWelfare_IDNO			NUMERIC(10,0)	 OUTPUT
AS

/*
*     PROCEDURE NAME    : MHIS_RETRIEVE_S20
 *     DESCRIPTION       : Retrieve Distinct Case Welfare Idno and Member Welfare Idno for a Member Idno, Case Idno, and Welfare Type.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 20-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

      SET @An_WelfareMemberMci_IDNO = NULL;
      SET @An_CaseWelfare_IDNO = NULL;

      DECLARE
         @Ps_WelfareTypeTanf_CNST CHAR(1) = 'A';
        
        SELECT DISTINCT @An_CaseWelfare_IDNO = MH.CaseWelfare_IDNO, 
        @An_WelfareMemberMci_IDNO = MH.WelfareMemberMci_IDNO
      FROM MHIS_Y1 MH
      WHERE 
         MH.MemberMci_IDNO = @An_MemberMci_IDNO AND 
         MH.Case_IDNO = @An_Case_IDNO AND 
         MH.TypeWelfare_CODE = @Ps_WelfareTypeTanf_CNST;
                  
END


GO
