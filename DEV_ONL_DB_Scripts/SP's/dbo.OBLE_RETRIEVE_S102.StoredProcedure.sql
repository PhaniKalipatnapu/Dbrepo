/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S102]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S102] (
     @An_Case_IDNO		     NUMERIC(6,0),
     @An_OrderSeq_NUMB		 NUMERIC(2,0),
     @An_Exists_NUMB         INT		   OUTPUT
)
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S102
 *     DESCRIPTION       : This procedure is returns the existance of the obligation in OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
         SET @An_Exists_NUMB = NULL;

	   DECLARE               
             @Lc_DebtTypeAlimony_CODE		CHAR(2) = 'AL', 
             @Lc_DebtTypeIntAlimony_CODE	CHAR(2) = 'AI',
             @Ld_High_DATE					DATE  = '12/31/9999',
             @Ld_Current_DATE				DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
      SELECT @An_Exists_NUMB = 1
        FROM OBLE_Y1  a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.TypeDebt_CODE IN ( @Lc_DebtTypeAlimony_CODE, @Lc_DebtTypeIntAlimony_CODE ) 
         AND @Ld_Current_DATE BETWEEN a.BeginObligation_DATE AND a.EndObligation_DATE 
         AND a.EndValidity_DATE = @Ld_High_DATE;

END;--End of OBLE_RETRIEVE_S102


GO
