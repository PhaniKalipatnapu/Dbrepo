/****** Object:  StoredProcedure [dbo].[POBL_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POBL_RETRIEVE_S2]  
	(
     @An_Case_IDNO			NUMERIC(6,0),
     @An_OrderSeq_NUMB		NUMERIC(2,0),
     @Ac_Exists_INDC        CHAR(1)		OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : POBL_RETRIEVE_S2
 *     DESCRIPTION       : This procedure returns the obligations existance indication for obligation type CS from OBLE_Y1 / POBL_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		SET @Ac_Exists_INDC = 'N';
     DECLARE
         @Lc_ProcessS_CODE			CHAR(1) = 'S',
		 @Lc_ProcessL_CODE			CHAR(1) = 'L',
		 @Lc_Yes_INDC				CHAR(1) = 'Y',
		 @Lc_DebtTypeChildSupp_CODE CHAR(2) = 'CS',
         @Ld_High_DATE				DATE	= '12/31/9999', 
         @Ld_Current_DATE			DATE    = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

     SELECT  @Ac_Exists_INDC = Exists_INDC
     FROM (
       SELECT @Lc_Yes_INDC AS Exists_INDC
			FROM PSRD_Y1 S
			JOIN POBL_Y1 B
		ON S.Record_NUMB = B.Record_NUMB
		WHERE S.Case_IDNO = @An_Case_IDNO
		AND   S.Process_CODE = @Lc_ProcessS_CODE
		AND   B.Process_CODE = @Lc_ProcessL_CODE
		AND   B.TypeDebt_CODE = @Lc_DebtTypeChildSupp_CODE
		UNION 
	  SELECT @Lc_Yes_INDC AS Exists_INDC
		FROM OBLE_Y1  a
      WHERE a.Case_IDNO = @An_Case_IDNO 
      AND   a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
      AND   a.TypeDebt_CODE = @Lc_DebtTypeChildSupp_CODE 
      AND  (( a.BeginObligation_DATE <= @Ld_Current_DATE 
			  AND a.EndObligation_DATE = (SELECT MAX(d.EndObligation_DATE)
											FROM OBLE_Y1  d
										   WHERE d.Case_IDNO = a.Case_IDNO 
											AND  d.OrderSeq_NUMB = a.OrderSeq_NUMB 
											AND  d.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
											AND  d.BeginObligation_DATE <= @Ld_Current_DATE 
											AND  d.EndValidity_DATE = @Ld_High_DATE ))			  
			OR ( a.BeginObligation_DATE > @Ld_Current_DATE 
				AND a.EndObligation_DATE =( SELECT MIN(d.EndObligation_DATE) 
											FROM OBLE_Y1 d
										   WHERE d.Case_IDNO = a.Case_IDNO 
										   AND   d.OrderSeq_NUMB = a.OrderSeq_NUMB 
										   AND   d.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
										   AND   d.BeginObligation_DATE > @Ld_Current_DATE 
										   AND   d.EndValidity_DATE = @Ld_High_DATE) 
					AND NOT EXISTS (SELECT 1 
									FROM OBLE_Y1 d
								 WHERE d.Case_IDNO = a.Case_IDNO 
								 AND   d.OrderSeq_NUMB = a.OrderSeq_NUMB 
								 AND   d.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
								 AND   d.BeginObligation_DATE <= @Ld_Current_DATE 
								 AND   d.EndValidity_DATE = @Ld_High_DATE ))) 
		AND a.EndValidity_DATE = @Ld_High_DATE ) a;
                  
END; --END OF POBL_RETRIEVE_S2


GO
