/****** Object:  StoredProcedure [dbo].[NRRQ_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NRRQ_RETRIEVE_S16] 
( 
	@An_Case_IDNO				NUMERIC(6,0),
	@Ac_Notice_ID				CHAR(8),
	@Ad_Generate_DTTM			DATETIME OUTPUT,
	@As_OtherParty_NAME			VARCHAR(60) OUTPUT
)   
AS
/*
 *     PROCEDURE NAME    : NRRQ_RETRIEVE_S16
 *     DESCRIPTION       : Retrieves the generated date for source of income.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 05-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN	
	SET @Ad_Generate_DTTM			= NULL;
	SET @As_OtherParty_NAME			= NULL;

	DECLARE @Lc_RecipientSi_CODE		CHAR(2) = 'SI',
			@Li_Zero_NUMB				INT     = 0,
			@Ld_High_DATE				DATE = '12/31/9999';
	
	SELECT @Ad_Generate_DTTM = N.Generate_DTTM,
			@As_OtherParty_NAME = (SELECT OtherParty_NAME 
									FROM OTHP_Y1 
									WHERE OtherParty_IDNO = CAST(N.Recipient_ID AS CHAR(9))
									AND EndValidity_DATE = @Ld_High_DATE)		
	FROM (SELECT TOP 1 N.Generate_DTTM,
			N.Recipient_ID
			FROM  NRRQ_Y1 N 
			WHERE	 N.Notice_ID  = @Ac_Notice_ID
			AND	N.Recipient_CODE  = @Lc_RecipientSi_CODE
			AND	N.Case_IDNO  = @An_Case_IDNO
			AND ISNUMERIC(N.Notice_ID) = @Li_Zero_NUMB
			GROUP BY N.Generate_DTTM,
			N.Recipient_ID 
			ORDER BY N.Generate_DTTM DESC ) N 
                      
END;  --END OF NRRQ_RETRIEVE_S16


GO
