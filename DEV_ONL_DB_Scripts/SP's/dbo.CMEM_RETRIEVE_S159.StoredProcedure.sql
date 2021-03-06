/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S159]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S159] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S159
  *     DESCRIPTION       : Retrieves MemberMci for the given Case Idno.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT C.Case_IDNO,
         C.MemberMci_IDNO,
         C.CaseRelationship_CODE
    FROM CMEM_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
   ORDER BY CaseRelationship_CODE,
            MemberMci_IDNO DESC;
 END; -- END Of Procedure CMEM_RETRIEVE_S159

GO
