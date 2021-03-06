/****** Object:  StoredProcedure [dbo].[FEDH_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[FEDH_RETRIEVE_S10]  
    (
     @An_MemberSsn_NUMB	NUMERIC(9,0)
    )               
AS

/*
 *     PROCEDURE NAME    : FEDH_RETRIEVE_S10
 *     DESCRIPTION       : Retrieve tax year using memberssn_numb.
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
             WHERE a.MemberSsn_NUMB = @An_MemberSsn_NUMB
             UNION
            SELECT a.TaxYear_NUMB
              FROM HFEDH_Y1 a
             WHERE a.MemberSsn_NUMB = @An_MemberSsn_NUMB
           ) X
    ORDER BY X.TaxYear_NUMB DESC;

END; --END OF FEDH_RETRIEVE_S10

GO
