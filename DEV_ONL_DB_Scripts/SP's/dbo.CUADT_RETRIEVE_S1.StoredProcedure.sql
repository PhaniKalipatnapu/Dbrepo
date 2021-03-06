/****** Object:  StoredProcedure [dbo].[CUADT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE PROCEDURE [dbo].[CUADT_RETRIEVE_S1]
 	( 
		@An_MemberMci_IDNO      NUMERIC(10,0)
 	)
 AS
 
 /*
  *     PROCEDURE NAME    : CUADT_RETRIEVE_S1
  *     DESCRIPTION       : It Retrieve the Account Activity Details from CRUDT_Y1 based on the MemberMci.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
 
     SELECT u.Screen_ID,
		u.Blocked_INDC,
		u.Reason_CODE,
		u.DescriptionComments_TEXT,
		u.WorkerUpdate_ID,
		u.Update_DTTM   	
	FROM 
		CRUDT_Y1 r JOIN CUADT_Y1 u
	ON
	r.IamUser_id=U.IamUser_id
	WHERE
	r.MemberMci_idno=@An_MemberMci_IDNO;

END; --End of CUADT_RETRIEVE_S1

GO
