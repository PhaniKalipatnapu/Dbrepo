/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S21] (
 @An_MemberMci_IDNO          NUMERIC(10, 0),
 @Ac_CaseRelationship_CODE   CHAR(1),
 @Ai_Count_QNTY              INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S21
  *     DESCRIPTION       : Retrieve the record count from Case Members table for given Member ID and Case Relation.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 C
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.CaseRelationship_CODE = @Ac_CaseRelationship_CODE;
 END; -- END OF CMEM_RETRIEVE_S21

GO
