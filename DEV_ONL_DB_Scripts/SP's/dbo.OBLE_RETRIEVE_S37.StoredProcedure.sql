/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S37]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S37]( 
		@An_Case_IDNO			 NUMERIC(6,0),
		@An_OrderSeq_NUMB		 NUMERIC(2,0),
		@Ac_TypeDebt_CODE		 CHAR(2),
		@An_TotPeriodic_AMNT     NUMERIC(11,2)   OUTPUT
	)
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S37
 *     DESCRIPTION       : This procedure is used to display the periodic amount in the debt and obligation grid for the current period of an obligation. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
      SET @An_TotPeriodic_AMNT = NULL;

      DECLARE
         @Li_Zero_NUMB		SMALLINT = 0,
         @Ld_High_DATE		DATE	 = '12/31/9999',
         @Ld_Current_DATE	DATE	 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

      SELECT @An_TotPeriodic_AMNT = ISNULL(SUM(a.Periodic_AMNT), @Li_Zero_NUMB)
		FROM OBLE_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO 
        AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
        AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
        AND a.EndValidity_DATE = @Ld_High_DATE 
        AND @Ld_Current_DATE BETWEEN a.BeginObligation_DATE AND a.EndObligation_DATE;

                  
END; -- END OF OBLE_RETRIEVE_S37


GO
