/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S22](  
     @An_Case_IDNO		 NUMERIC(6,0),
     @An_WelfareMemberMci_IDNO NUMERIC(10,0) OUTPUT,
     @An_CaseWelfare_IDNO NUMERIC(10,0) OUTPUT
     )
AS

/*
*     PROCEDURE NAME    : MHIS_RETRIEVE_S22
 *     DESCRIPTION       : Retrieve Distinct Case Welfare Idno and Member Welfare Idno for a Case Idno, Welfare Case Idno is Not Null and Not Empty.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 12/14/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
      SELECT DISTINCT TOP 1 @An_CaseWelfare_IDNO = MH.CaseWelfare_IDNO, 
                     @An_WelfareMemberMci_IDNO=  MH.WelfareMemberMci_IDNO
      FROM MHIS_Y1 MH
      WHERE  MH.Case_IDNO = @An_Case_IDNO 
         AND MH.CaseWelfare_IDNO > 0;
                  
END

GO
