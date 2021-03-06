/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S99]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S99] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S99
  *     DESCRIPTION       : 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Yes_TEXT			CHAR(1)	= 'Y';
  DECLARE @Lc_TypeDebtCs_CODE	CHAR(2)	= 'CS';
  DECLARE @Li_Zero_NUMB			INT		= 0;
  DECLARE @Ld_High_DATE			DATE = '12/31/9999';
  DECLARE @Ld_Current_DATE		DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  

	SELECT
		A.Last_NAME,
		A.First_NAME,
		A.Middle_NAME,
		MAX(D.BeginValidity_DATE) AS Begin_DATE,
		COUNT(1) OVER() AS RowCount_NUMB
	FROM  DEMO_Y1 A,
		OBLE_Y1 O,
		SORD_Y1 D 
	WHERE	 D.Case_IDNO  = @An_Case_IDNO
		AND	D.OrderEnd_DATE  > @Ld_Current_DATE
		AND	D.EndValidity_DATE  = @Ld_High_DATE
		AND	D.Case_IDNO  = O.Case_IDNO
		AND	D.OrderSeq_NUMB  = O.OrderSeq_NUMB
		AND	O.TypeDebt_CODE  = @Lc_TypeDebtCs_CODE
		AND	D.MedicalOnly_INDC  <> @Lc_Yes_TEXT
		AND	@Ld_Current_DATE  BETWEEN O.BeginObligation_DATE  AND  O.EndObligation_DATE
		AND	O.EndValidity_DATE  = @Ld_High_DATE
		AND	O.Periodic_AMNT  > @Li_Zero_NUMB
		AND	O.MemberMci_IDNO  = A.MemberMci_IDNO
	GROUP BY A.Last_NAME,
		A.First_NAME,
		A.Middle_NAME;

					
 END; --End Of DEMO_RETRIEVE_S99

GO
