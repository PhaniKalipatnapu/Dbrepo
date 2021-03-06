/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S129]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S129](
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @An_Case_IDNO      NUMERIC(6, 0),
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S129
  *     DESCRIPTION       : Retrieve the Dependant count of records from Case Members table for the retrieved Case whose Member is an Active (A) Dependant (D) and NOT equal to Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 18-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipDp_CODE    CHAR(1) = 'D',
          @Lc_CaseMembeStatusActive_CODE CHAR(1) = 'A';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 c
   WHERE c.Case_IDNO = @An_Case_IDNO
     AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
     AND c.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE
     AND c.MemberMci_IDNO <> @An_MemberMci_IDNO;
 END -- End of CMEM_RETRIEVE_S129

GO
