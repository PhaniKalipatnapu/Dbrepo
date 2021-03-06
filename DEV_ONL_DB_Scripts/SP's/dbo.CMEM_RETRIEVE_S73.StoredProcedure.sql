/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S73]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S73] (
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S73    
  *     DESCRIPTION       : Retrieve Open Case for a given Member.   
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 12-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
 DECLARE @Lc_OpenCase_TEXT CHAR(1) = 'O';
		 
 SELECT C.Case_IDNO
 FROM CMEM_Y1 C
 WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
	AND EXISTS(
		SELECT 1
		FROM CASE_Y1 A
		WHERE C.Case_IDNO = A.Case_IDNO)
 ORDER BY C.Case_IDNO;
 END; --End of CMEM_RETRIEVE_S71


GO
