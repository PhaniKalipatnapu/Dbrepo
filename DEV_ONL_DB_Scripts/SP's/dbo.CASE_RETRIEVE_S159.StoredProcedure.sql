/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S159]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S159](
 @An_Case_IDNO NUMERIC(6, 0) OUTPUT
 )
AS
/*  
 *     PROCEDURE NAME    : CASE_RETRIEVE_S159  
 *     DESCRIPTION       : Retrieve the Case ID.  
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 02-MAR-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */
 BEGIN
 
  SET @An_Case_IDNO = null;
  
  DECLARE @Lc_StatusCaseOpen_CODE			CHAR(1)		= 'O';

  SELECT @An_Case_IDNO = Min(C.Case_IDNO)
  FROM CASE_Y1 C
  WHERE C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE;
  
 END; --End of CASE_RETRIEVE_S159


GO
