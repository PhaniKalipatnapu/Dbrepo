/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S65]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S65] (
 @An_Case_IDNO  NUMERIC(6),
 @Ai_Count_QNTY INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : SORD_RETRIEVE_S65
  *     DESCRIPTION       : Retrieve the SORD Count plus Obligation Count for the given Case (0 : No SORD, 1 : Only SORD and 2 : SORD and OBLE Both ).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  
  DECLARE @Lc_TypeOrderVoluntary_CODE CHAR(1)	= 'V',
          @Ld_High_DATE               DATE		= '12/31/9999';
  
  --13857 - CPRO - Can't generate  manual National Medical Support Notice on medical only cases - START
            
  SET @Ai_Count_QNTY = 0;

  SELECT TOP 1 @Ai_Count_QNTY = CASE WHEN o.Case_IDNO IS NULL 
									  THEN 1
									  ELSE 2 
								END
    FROM SORD_Y1 s
    LEFT JOIN OBLE_Y1 o
      ON s.Case_IDNO = o.Case_IDNO
      AND s.OrderSeq_NUMB = o.OrderSeq_NUMB
      AND o.EndValidity_DATE = @Ld_High_DATE
   WHERE s.Case_IDNO = @An_Case_IDNO
     AND s.TypeOrder_CODE != @Lc_TypeOrderVoluntary_CODE
     AND s.EndValidity_DATE = @Ld_High_DATE
     AND CONVERT(DATE, DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()) BETWEEN S.OrderEffective_DATE AND S.OrderEnd_DATE;

 END; --END OF SORD_RETRIEVE_S65

 --13857 - CPRO - Can't generate  manual National Medical Support Notice on medical only cases - END


GO
