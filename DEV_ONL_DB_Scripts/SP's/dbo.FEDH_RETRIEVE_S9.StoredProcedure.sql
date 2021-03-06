/****** Object:  StoredProcedure [dbo].[FEDH_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE  [dbo].[FEDH_RETRIEVE_S9]  
    (
     @An_MemberMci_IDNO	NUMERIC(10,0)
    )              
AS

/*
 *     PROCEDURE NAME    : FEDH_RETRIEVE_S9
 *     DESCRIPTION       : Retrieve tax year using membermci_idno.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 03-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN
   
      SELECT X.TaxYear_NUMB
        FROM(SELECT a.TaxYear_NUMB
               FROM FEDH_Y1 a
              WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
              UNION
             SELECT a.TaxYear_NUMB
               FROM HFEDH_Y1 a
              WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
            ) X
    ORDER BY X.TaxYear_NUMB DESC;

END;  --END OF FEDH_RETRIEVE_S9

GO
