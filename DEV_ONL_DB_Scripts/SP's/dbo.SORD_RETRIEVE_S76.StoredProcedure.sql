/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S76]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S76]
(
	@An_Case_IDNO				NUMERIC(6,0),
	@Ai_Count_QNTY				INT,
	@Ac_WorkerUpdate_ID			CHAR(30),
	@Ad_StatusCurrent_DATE		DATE,
	@Ad_End_DATE				DATE,
	@Ad_Update_DTTM				DATETIME,
	@Ad_OrderEffective_DATE		DATE OUTPUT,
	@Ad_OrderIssued_DATE		DATE OUTPUT
)
AS
 
/*                                                                                   
  *     PROCEDURE NAME    : SORD_RETRIEVE_S76                                          
  *     DESCRIPTION       : This procedure is used to retrieve the Order details for expedited process.
  *     DEVELOPED BY      : IMP TEAM                                              
  *     DEVELOPED ON      : 03/07/2012
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
  */
BEGIN
 
	 SELECT @Ad_OrderEffective_DATE = NULL,
			@Ad_OrderIssued_DATE    = NULL;
 
	DECLARE @Li_Zero_NUMB					INT      = 0,
			@Lc_TypeOrderV_CODE				CHAR(1)  = 'V',
			@Lc_WorkerUpdateCONVERSION_CODE CHAR(30) = 'CONVERSION',
			@Ld_ThreeYrsOld_DATE			DATE = DATEADD(MM,-36,@Ad_End_DATE);
			 
	SELECT @Ad_OrderIssued_DATE		= b.OrderIssued_DATE,
		   @Ad_OrderEffective_DATE	= b.OrderEffective_DATE
	  FROM SORD_Y1 b
	 WHERE b.Case_IDNO = @An_Case_IDNO
	   AND b.TypeOrder_CODE <> @Lc_TypeOrderV_CODE
	   AND (CASE @Ai_Count_QNTY
				 WHEN @Li_Zero_NUMB 
					 THEN b.OrderEffective_DATE
				 ELSE b.OrderIssued_DATE 
			END
			) <= @Ld_ThreeYrsOld_DATE
	   AND b.EventGlobalBeginSeq_NUMB =(SELECT MAX (x.EventGlobalBeginSeq_NUMB)
										  FROM SORD_Y1 x
										 WHERE x.Case_IDNO = b.Case_IDNO
										   AND x.OrderSeq_NUMB = b.OrderSeq_NUMB
										   AND (CASE @Ai_Count_QNTY
													WHEN @Li_Zero_NUMB 
														THEN x.OrderEffective_DATE
													ELSE x.BeginValidity_DATE
											    END)>=(CASE @Ac_WorkerUpdate_ID
														  WHEN @Lc_WorkerUpdateCONVERSION_CODE 
															 THEN @Ad_StatusCurrent_DATE
														 ELSE @Ad_Update_DTTM
													   END
														));
 
END --End Of Procedure SORD_RETRIEVE_S76
 

GO
