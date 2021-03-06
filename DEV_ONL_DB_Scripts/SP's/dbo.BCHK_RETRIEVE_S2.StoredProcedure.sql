/****** Object:  StoredProcedure [dbo].[BCHK_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BCHK_RETRIEVE_S2]  (
     @An_MemberMci_IDNO		 	 NUMERIC(10,0)			,
     @An_CountBadCheck_QNTY		 NUMERIC(3,0)	 OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : BCHK_RETRIEVE_S2
 *     DESCRIPTION       : Retrieves bad check count for a given membermci idno.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	
  SET @An_CountBadCheck_QNTY = NULL;

  SELECT @An_CountBadCheck_QNTY = ISNULL(MAX(a.CountBadCheck_QNTY), 0)
  FROM BCHK_Y1 a
  WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO;
                  
END; --End of BCHK_RETRIEVE_S2 


GO
