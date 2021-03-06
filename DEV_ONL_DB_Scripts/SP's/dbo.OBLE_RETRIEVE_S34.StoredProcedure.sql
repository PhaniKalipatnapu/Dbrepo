/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S34]
	(
	 @An_Case_IDNO		 NUMERIC(6,0),
     @An_MemberMci_IDNO	 NUMERIC(10,0),              
     @Ai_RowFrom_NUMB    INT    = 1,
     @Ai_RowTo_NUMB      INT    = 10
    )
AS
		
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S34
 *     DESCRIPTION       : Retrieve the Child Obligation Details to diplay in Pop up window for Case ID and Member ID.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 15-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

     DECLARE
         @Li_Zero_NUMB			  SMALLINT = 0, 
         @Lc_ObleLevel_CODE		  CHAR(1)  = 'O', 
         @Lc_PreviewN_CODE		  CHAR(1)  = 'N',
         @Ld_High_DATE			  DATE	   = '12/31/9999';
        
        SELECT Y.Case_IDNO, 
			   Y.MemberMci_IDNO,
			   Y.File_ID, 
			   Y.TypeDebt_CODE,
			   Y.Fips_CODE,
			   Y.BeginObligation_DATE, 
			   Y.EndObligation_DATE ,
			   Y.Periodic_AMNT ,
			   Y.FreqPeriodic_CODE, 
			   Y.Arrears_AMNT, 
			   Y.RowCount_NUMB
		FROM(SELECT X.Case_IDNO,
				    X.MemberMci_IDNO, 
					X.File_ID, 
					X.TypeDebt_CODE,
					X.Fips_CODE, 
					X.BeginObligation_DATE, 
					X.EndObligation_DATE, 
					X.Periodic_AMNT, 
					X.FreqPeriodic_CODE, 
					X.Arrears_AMNT, 
					X.ORD_ROWNUM AS rnm, 
					X.RowCount_NUMB
				FROM (SELECT DISTINCT a.Case_IDNO,
							a.MemberMci_IDNO, 
							b.File_ID, 
							a.TypeDebt_CODE,
							a.Fips_CODE, 
							a.BeginObligation_DATE, 
							a.EndObligation_DATE,                            
							ISNULL(a.Periodic_AMNT, @Li_Zero_NUMB) AS Periodic_AMNT, 
							a.FreqPeriodic_CODE, 
							dbo.Batch_Common$SF_GET_OBLEARREARS(a.Case_IDNO,a.OrderSeq_NUMB,a.ObligationSeq_NUMB,NULL,@Lc_ObleLevel_CODE,@Lc_PreviewN_CODE) AS Arrears_AMNT,
							COUNT(1) OVER() AS RowCount_NUMB, 
							ROW_NUMBER() OVER(ORDER BY a.Case_IDNO, b.Order_IDNO, a.TypeDebt_CODE) AS ORD_ROWNUM
							FROM OBLE_Y1 a JOIN SORD_Y1  b
						ON	  b.Case_IDNO	     = a.Case_IDNO 
						 AND  a.OrderSeq_NUMB    = b.OrderSeq_NUMB 
						WHERE a.MemberMci_IDNO   = @An_MemberMci_IDNO 
						 AND  a.Case_IDNO	     = @An_Case_IDNO 
						 AND  a.EndValidity_DATE = @Ld_High_DATE 
						 AND  b.EndValidity_DATE = @Ld_High_DATE
					) X
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
         ) Y
      WHERE Y.rnm >= @Ai_RowFrom_NUMB
ORDER BY RNM;

END; --END OF OBLE_RETRIEVE_S34


GO
