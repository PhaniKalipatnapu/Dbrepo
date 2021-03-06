/****** Object:  StoredProcedure [dbo].[MPAT_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MPAT_RETRIEVE_S6] (
 @An_MemberMci_IDNO      		NUMERIC(10, 0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10, 0),
 @Ai_Count_QNTY                 INT OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : MPAT_RETRIEVE_S6
 *     DESCRIPTION       : Retrieve the count of records from Member Demographics table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) and Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) with same Legal Paternity Status for both the Members.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

  SET @Ai_Count_QNTY = NULL;

 SELECT @Ai_Count_QNTY = COUNT(1)
   FROM MPAT_Y1 mp
        JOIN
        MPAT_Y1 ms
     ON mp.StatusEstablish_CODE = ms.StatusEstablish_CODE 
  WHERE mp.MemberMci_IDNO = @An_MemberMci_IDNO 
    AND ms.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;  
         
END; --END OF MPAT_RETRIEVE_S6


GO
