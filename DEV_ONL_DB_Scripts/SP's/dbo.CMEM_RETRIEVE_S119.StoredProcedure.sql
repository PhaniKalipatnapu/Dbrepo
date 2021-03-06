/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S119]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S119](
 @An_MemberMci_IDNO     NUMERIC(10, 0),
 @An_Case_IDNO			NUMERIC(6, 0) OUTPUT
 )
AS
/*  
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S119  
 *     DESCRIPTION       : Retrieve the MAX Case ID on given Member ID.  
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 04-JUN-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */
 BEGIN
 
  SET @An_Case_IDNO = null;
  
  DECLARE @Lc_CaseMemberStatus_CODE			CHAR(1)		= 'A',
          @Lc_StatusCaseOpen_CODE			CHAR(1)		= 'O';

  SELECT @An_Case_IDNO = MAX(CM.Case_IDNO)
  FROM CMEM_Y1 CM
  JOIN CASE_Y1 CA 
	ON CM.Case_IDNO = CA.Case_IDNO AND CA.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
  WHERE CM.MemberMci_IDNO = @An_MemberMci_IDNO
        AND CM.CaseMemberStatus_Code = @Lc_CaseMemberStatus_CODE;
  
 END; --End of CMEM_RETRIEVE_S119


GO
