/****** Object:  StoredProcedure [dbo].[IVMG_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[IVMG_RETRIEVE_S17] (
 @An_CaseWelfare_IDNO	NUMERIC(10, 0),
 @Ac_WelfareElig_CODE	CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : IVMG_RETRIEVE_S17
  *     DESCRIPTION       : Retrieves the welfare type for the given case welfare.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
 SET @Ac_WelfareElig_CODE = NULL;

	SELECT TOP 1 @Ac_WelfareElig_CODE = A.WelfareElig_CODE
	FROM IVMG_Y1 A
	WHERE A.CaseWelfare_IDNO = @An_CaseWelfare_IDNO;


 END; -- End of IVMG_RETRIEVE_S17

GO
