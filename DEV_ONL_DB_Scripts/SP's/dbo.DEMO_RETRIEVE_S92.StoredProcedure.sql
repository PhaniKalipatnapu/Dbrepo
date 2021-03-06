/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S92]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S92] (
 @An_MemberMci_IDNO				NUMERIC(10,0),
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),	
 @Ai_Count_QNTY		 			INT OUTPUT
 )                                             
AS

/*
 *     PROCEDURE NAME    : DEMO_RETRIEVE_S92
 *     DESCRIPTION       : Retrieve the count of records from Member Demographics table for the Member who is Active in Case Members table and equal to Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) or Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column). 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

 BEGIN

    SET @Ai_Count_QNTY = NULL;

 DECLARE @Lc_StatusCaseMemberActive_CODE	CHAR(1) = 'A';
        
 SELECT @Ai_Count_QNTY = COUNT(1)
   FROM DEMO_Y1 a
        JOIN
        CMEM_Y1 cm
     ON a.MemberMci_IDNO = cm.MemberMci_IDNO    
  WHERE a.MemberMci_IDNO IN ( @An_MemberMci_IDNO, @An_MemberMciSecondary_IDNO ) 
    AND cm.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;
     
END; --END OF DEMO_RETRIEVE_S92


GO
