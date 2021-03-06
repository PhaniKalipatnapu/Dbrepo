/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S16] (
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S16
  *     DESCRIPTION       : Retrieve Open (O) Cases from Case Details table for the Member in Case Members table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_CaseStatusOpen_CODE CHAR(1) = 'O';

  SELECT c.Case_IDNO
    FROM CMEM_Y1 m
         JOIN CASE_Y1 c
          ON m.Case_IDNO = c.Case_IDNO
   WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
     AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;
 END; -- END of CASE_RETRIEVE_S16


GO
