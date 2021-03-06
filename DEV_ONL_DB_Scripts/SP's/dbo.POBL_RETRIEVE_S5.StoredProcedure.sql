/****** Object:  StoredProcedure [dbo].[POBL_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[POBL_RETRIEVE_S5]
	(
	 @Ac_TypeDebt_CODE  CHAR(2),
	 @An_Case_IDNO		NUMERIC(6,0)	 
    )
AS
/*
 *     PROCEDURE NAME    : POBL_RETRIEVE_S5
 *     DESCRIPTION       : It retreive the obligation details from POBL_Y1 and OBLE_Y1
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
	
		DECLARE
			@Lc_Yes_INDC			CHAR(1) = 'Y',
			@Lc_ProcessS_CODE		CHAR(1) = 'S',
			@Lc_ProcessL_CODE		CHAR(1) = 'L',
			@Lc_ReasonChangeOM_CODE	CHAR(2) = 'OM',
			@Ld_High_DATE			DATE	= '12/31/9999';
   
			SELECT 	B.Effective_DATE AS BeginObligation_DATE,
					B.End_DATE AS EndObligation_DATE,
					B.Periodic_AMNT,
					B.FreqPeriodic_CODE,
					@Lc_ReasonChangeOM_CODE AS ReasonChange_CODE,
					B.Record_NUMB,
					B.PayBack_INDC 	    
					FROM PSRD_Y1 S
					JOIN POBL_Y1 B
			ON S.Record_NUMB = B.Record_NUMB
			WHERE S.CASE_IDNO = @An_Case_IDNO
			AND	  S.Process_CODE = @Lc_ProcessS_CODE
			AND   B.TypeDebt_CODE = @Ac_TypeDebt_CODE
			AND	  B.Process_CODE = @Lc_ProcessL_CODE
			AND   B.PayBack_INDC <> @Lc_Yes_INDC 
			AND   EXISTS (SELECT 1 
						FROM OBLE_Y1  O
						WHERE O.Case_IDNO		 = S.Case_IDNO
						AND   O.TypeDebt_CODE	 = B.TypeDebt_CODE						
						AND   O.EndValidity_DATE = @Ld_High_DATE) 
			ORDER BY B.TypeDebt_CODE;

END; --End of POBL_RETRIEVE_S5;


GO
