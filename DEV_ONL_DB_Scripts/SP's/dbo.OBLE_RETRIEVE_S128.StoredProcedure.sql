/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S128]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S128]
(
	 @An_Case_IDNO					NUMERIC(6, 0),
	 @An_OrderSeq_NUMB				NUMERIC(2, 0),
	 @Ac_Fips_CODE					CHAR(7),
	 @Ac_TypeDebt_CODE				CHAR(2),
	 @An_Payback_AMNT				NUMERIC(11, 2)	OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S128
  *     DESCRIPTION       : Procedure to populate the payback information block in RHIS report
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-JAN-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
		  SELECT @An_Payback_AMNT = NULL;

		 DECLARE @Li_Zero_NUMB                 SMALLINT = 0,
				 @Ld_High_DATE                 DATE = '12/31/9999',
				 @Ld_System_DATE               DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

		SELECT @An_Payback_AMNT = SUM (X.ExpectToPay_AMNT)
			 FROM OBLE_Y1 X
		    WHERE X.Case_IDNO = @An_Case_IDNO
			  AND X.OrderSeq_NUMB = @An_OrderSeq_NUMB
			  AND X.Fips_CODE = ISNULL(@Ac_Fips_CODE,X.Fips_CODE)
			  AND X.TypeDebt_CODE = ISNULL(@Ac_TypeDebt_CODE,X.TypeDebt_CODE)
			  AND X.EndValidity_DATE = @Ld_High_DATE			 
		     AND   (     (     X.BeginObligation_DATE <= @Ld_System_DATE   
                 AND X.EndObligation_DATE =   
                        (  
                      SELECT MAX(b.EndObligation_DATE)  
                        FROM OBLE_Y1 b  
                       WHERE b.Case_IDNO = X.Case_IDNO   
                         AND b.OrderSeq_NUMB = X.OrderSeq_NUMB   
                         AND b.ObligationSeq_NUMB = X.ObligationSeq_NUMB   
                         AND b.BeginObligation_DATE <= @Ld_System_DATE   
                         AND b.EndValidity_DATE = @Ld_High_DATE  
                      )        
                 )   
                OR  (    X.BeginObligation_DATE > @Ld_System_DATE   
                     AND X.EndObligation_DATE =   
                        (  
                       SELECT MIN(b.EndObligation_DATE)  
                         FROM OBLE_Y1 b  
                        WHERE b.Case_IDNO = X.Case_IDNO   
                          AND b.OrderSeq_NUMB = X.OrderSeq_NUMB   
                          AND b.ObligationSeq_NUMB = X.ObligationSeq_NUMB   
                          AND b.BeginObligation_DATE > @Ld_System_DATE   
                          AND b.EndValidity_DATE = @Ld_High_DATE  
                         )   
                  AND NOT EXISTS   
                                (  
                      SELECT 1   
                        FROM OBLE_Y1 c  
                       WHERE c.Case_IDNO = X.Case_IDNO   
                         AND c.OrderSeq_NUMB = X.OrderSeq_NUMB   
                         AND c.ObligationSeq_NUMB = X.ObligationSeq_NUMB   
                         AND c.BeginObligation_DATE <= @Ld_System_DATE   
                         AND c.EndValidity_DATE = @Ld_High_DATE  
                                 )  
                 )  
                   )
			  AND X.ExpectToPay_AMNT > @Li_Zero_NUMB;
     
 END;--End of OBLE_RETRIEVE_S128

GO
