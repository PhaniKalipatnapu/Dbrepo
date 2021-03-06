/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S75]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S75]
(
	@Ac_WorkerUpdate_ID		CHAR(30),
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@Ad_Update_DTTM			DATETIME,
	@Ad_StatusCurrent_DATE	DATE,
	@An_Case_IDNO			NUMERIC(6,0),
	@Ad_Disposition_DATE	DATE OUTPUT
)
AS
/*                                                                                     
  *     PROCEDURE NAME    : SORD_RETRIEVE_S75                                            
  *     DESCRIPTION       : This procedure is used to retrieve the disposition date.  
  *     DEVELOPED BY      : IMP TEAM                                                
  *     DEVELOPED ON      : 03/09/2012  
  *     MODIFIED BY       :                                                             
  *     MODIFIED ON       :                                                             
  *     VERSION NO        : 1                                                           
  */
BEGIN
 
		SET @Ad_Disposition_DATE = NULL;
 
	DECLARE @Ld_High_DATE					DATE	= '12/31/9999',
			@Ld_Low_DATE					DATE	= '01/01/0001',
		    @Lc_ServiceResultP_CODE		    CHAR(1) = 'P',
		    @Lc_ServiceResultN_CODE		    CHAR(1) = 'N',
            @Lc_ReasonStatusDB_CODE         CHAR(2) = 'DB',
            @Lc_StatusCOMP_CODE             CHAR(4) = 'COMP',
            @Lc_ActivityMajorESTP_CODE      CHAR(4) = 'ESTP',
            @Lc_ActivityMajorCASE_CODE      CHAR(4) = 'CASE',
            @Lc_ActivityMinorROPDP_CODE     CHAR(4) = 'ROPDP',
		    @Lc_ActivityMinorANDDI_CODE     CHAR(5) = 'ANDDI',
			@Lc_WorkerUpdateCONVERSION_CODE CHAR(30)= 'CONVERSION';
 

	  
	  SELECT @Ad_Disposition_DATE = ISNULL((SELECT TOP 1 b.OrderIssued_DATE
			  FROM SORD_Y1 b
			 WHERE b.Case_IDNO = @An_Case_IDNO
			   AND b.OrderIssued_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE
			   AND b.EventGlobalBeginSeq_NUMB =
									(SELECT MIN (x.EventGlobalBeginSeq_NUMB)
									   FROM SORD_Y1 x
									  WHERE x.Case_IDNO = b.Case_IDNO
										AND x.OrderSeq_NUMB = b.OrderSeq_NUMB
										AND x.OrderIssued_DATE >= CASE @Ac_WorkerUpdate_ID
																  WHEN  @Lc_WorkerUpdateCONVERSION_CODE 
																	THEN @Ad_StatusCurrent_DATE
																 ELSE @Ad_Update_DTTM
															   END
												  )),											
				 (SELECT TOP 1 b.Status_DATE 
						  FROM DMNR_Y1 b JOIN FSRT_Y1 f
							ON b.Case_IDNO = f.Case_IDNO
						   AND b.Case_IDNO = @An_Case_IDNO
						   AND b.Status_CODE = @Lc_StatusCOMP_CODE
						   AND f.EndValidity_DATE = @Ld_High_DATE
						   AND ((b.ActivityMajor_CODE = @Lc_ActivityMajorESTP_CODE
									AND b.ActivityMinor_CODE = @Lc_ActivityMinorANDDI_CODE 
									AND b.ReasonStatus_CODE = @Lc_ReasonStatusDB_CODE
									AND f.ServiceResult_CODE = @Lc_ServiceResultN_CODE)
								OR (b.ActivityMajor_CODE = @Lc_ActivityMajorCASE_CODE  
									AND b.ActivityMinor_CODE = @Lc_ActivityMinorROPDP_CODE 
									AND f.ServiceResult_CODE = @Lc_ServiceResultP_CODE))
						   AND (SELECT MAX(d.Service_DATE) 
								  FROM FSRT_Y1 d 
								 WHERE d.Case_IDNO = @An_Case_IDNO
								   AND d.EndValidity_DATE = @Ld_High_DATE) <= @Ad_End_DATE));
	 
END --End Of Procedure SORD_RETRIEVE_S75
 

GO
