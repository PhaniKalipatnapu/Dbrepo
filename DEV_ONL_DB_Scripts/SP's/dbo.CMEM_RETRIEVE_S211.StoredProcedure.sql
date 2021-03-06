/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S211]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S211] (
 @An_MemberMci_IDNO NUMERIC(10, 0), 
 @An_Case_IDNO      NUMERIC(6, 0) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S211  
  *     DESCRIPTION       : Retrieves the case details for the respective member. 
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 21-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  SELECT @An_Case_IDNO = NULL

  DECLARE @Lc_StatusCaseOpen_CODE     CHAR(1) = 'O',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT @An_Case_IDNO = MIN(C.Case_IDNO)
  FROM CMEM_Y1 C JOIN CASE_Y1 A
	ON C.Case_IDNO = A.Case_IDNO
  WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
	AND A.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;
         
 END; -- End Of CMEM_RETRIEVE_S211

GO
