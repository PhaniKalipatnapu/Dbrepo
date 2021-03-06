/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S72]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S72] 
( 
	@An_Case_IDNO			NUMERIC(6,0),
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@Ad_Order_DATE			DATE OUTPUT
)  
AS
/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S72
 *     DESCRIPTION       : This procedure is used to retrieve the Order date.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 03-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
		 SET @Ad_Order_DATE = NULL;
		 
     DECLARE @Ld_Low_DATE				DATE    = '01/01/0001',
			 @Lc_TypeOrderV_CODE		CHAR(1) = 'V';
	
	  SELECT @Ad_Order_DATE = ISNULL(a.OrderEffective_DATE,@Ld_Low_DATE)
	    FROM SORD_Y1 a
	   WHERE a.Case_IDNO = @An_Case_IDNO
		 AND a.TypeOrder_CODE <> @Lc_TypeOrderV_CODE
		 AND a.OrderEffective_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
		 AND a.EventGlobalBeginSeq_NUMB = (SELECT MIN(x.EventGlobalBeginSeq_NUMB )
											 FROM SORD_Y1 x
											WHERE x.Case_IDNO = a.Case_IDNO
											  AND x.OrderSeq_NUMB = a.OrderSeq_NUMB
											  AND a.OrderEffective_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
										  );
	                      
END;  --END OF SORD_RETRIEVE_S72


GO
