/****** Object:  StoredProcedure [dbo].[POBL_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[POBL_RETRIEVE_S1] (
	 @An_Case_IDNO		NUMERIC(6,0),
	 @Ac_Exists_INDC	CHAR(1)			OUTPUT     
    )
AS
/*
 *     PROCEDURE NAME    : POBL_RETRIEVE_S1
 *     DESCRIPTION       : Retrieve the Existing indication of new obligations from POBL_Y1 which obligation not in OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		SET @Ac_Exists_INDC   =  'N';
		
    DECLARE
		@Lc_ProcessS_CODE	CHAR(1) = 'S',
		@Lc_ProcessL_CODE	CHAR(1) = 'L',
		@Ld_High_DATE		DATE	= '12/31/9999';
    
		SELECT @Ac_Exists_INDC = 'Y'
			FROM PSRD_Y1 S
			JOIN POBL_Y1 B
		   ON S.Record_NUMB	 = B.Record_NUMB
		WHERE S.Case_IDNO	 = @An_Case_IDNO
		AND   S.Process_CODE = @Lc_ProcessS_CODE
		AND   B.Process_CODE = @Lc_ProcessL_CODE
		AND NOT EXISTS (SELECT 1 
						FROM OBLE_Y1  O
						WHERE O.Case_IDNO		 = S.Case_IDNO
						AND   O.TypeDebt_CODE	 = B.TypeDebt_CODE						
						AND   O.EndValidity_DATE = @Ld_High_DATE);
							
END; --END OF POBL_RETRIEVE_S1 									


GO
