/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S97]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S97] (
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ac_CaseRelationship_CODE CHAR(1)
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S97
  *     DESCRIPTION       : Retrieve aliases of First Name, Last Name and Middle Name for a given Case and Member Type.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT a.FirstAlias_NAME,
         a.MiddleAlias_NAME,
         a.LastAlias_NAME
    FROM CASE_Y1 c1
         JOIN CMEM_Y1 c2
          ON c2.Case_IDNO = c1.Case_IDNO
         JOIN AKAX_Y1 a
          ON c2.MemberMci_IDNO = a.MemberMci_IDNO
   WHERE c1.Case_IDNO = @An_Case_IDNO
     AND c2.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of CASE_RETRIEVE_S97

GO
