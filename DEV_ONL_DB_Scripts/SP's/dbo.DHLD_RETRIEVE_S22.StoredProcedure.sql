/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE
	[dbo].[DHLD_RETRIEVE_S22]
		(
     		@An_Case_IDNO		        	NUMERIC(6,0),
     		@Ad_TransactionFrom_DATE    	DATE        ,
     		@Ad_TransactionTo_DATE      	DATE        ,
     		@An_TotDisbursementHeld_AMNT	NUMERIC(15,2) OUTPUT
     	)
 AS

/*
 *     PROCEDURE NAME    : DHLD_RETRIEVE_S22
 *     DESCRIPTION       : Retrieves the total transaction amount for the given case id, transaction date.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 14-SEP-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/
BEGIN

  SET @An_TotDisbursementHeld_AMNT = NULL;

  DECLARE
        @Lc_StatusReceiptHeld_CODE	CHAR(1)= 'H',
        @Ld_High_DATE          		DATE = '12/31/9999',
        @Li_Zero_NUMB         		SMALLINT = 0;

  SELECT @An_TotDisbursementHeld_AMNT = ISNULL(SUM(A.Transaction_AMNT), @Li_Zero_NUMB)
    FROM DHLD_Y1 A
   WHERE A.Case_IDNO = @An_Case_IDNO 
   AND A.Transaction_DATE BETWEEN @Ad_TransactionFrom_DATE AND @Ad_TransactionTo_DATE 
   AND A.Status_CODE = @Lc_StatusReceiptHeld_CODE 
   AND A.EndValidity_DATE = @Ld_High_DATE;


END;  --End of DHLD_RETRIEVE_S22


GO
