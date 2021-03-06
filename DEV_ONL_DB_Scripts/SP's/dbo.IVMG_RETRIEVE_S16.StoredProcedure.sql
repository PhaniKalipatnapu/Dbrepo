/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S16] (
 @An_CaseWelfare_IDNO	NUMERIC(10, 0),
 @Ai_Count_QNTY			INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S16
  *     DESCRIPTION       : Checks if given Case Welfare is Foster Care or Non Federal Foster Case.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
 SET @Ai_Count_QNTY = NULL;
 
  DECLARE @Lc_WelfareTypeIveFosterCare_TEXT        CHAR(1) = 'F';

	SELECT @Ai_Count_QNTY = count(1)
	FROM IVMG_Y1 A, GLEV_Y1 G
	WHERE A.CaseWelfare_IDNO = @An_CaseWelfare_IDNO  
		AND A.WelfareElig_CODE IN ( @Lc_WelfareTypeIveFosterCare_TEXT ) 
		AND G.EventGlobalSeq_NUMB = A.EventGlobalSeq_NUMB;


 END; -- End of IVMG_RETRIEVE_S16

GO
