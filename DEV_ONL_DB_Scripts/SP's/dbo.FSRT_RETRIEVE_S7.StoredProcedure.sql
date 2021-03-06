/****** Object:  StoredProcedure [dbo].[FSRT_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FSRT_RETRIEVE_S7] 
( 
	@An_Case_IDNO					NUMERIC(6,0),
	@Ad_UnsuccessfulService_DATE	DATE	OUTPUT,
	@Ac_UnsuccessfulService_CODE	CHAR(1)	OUTPUT
)  
AS
/*
 *     PROCEDURE NAME    : FSRT_RETRIEVE_S7
 *     DESCRIPTION       : This procedure is used to retrieve the UnsuccessfulService date and code.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 03-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
	 SELECT @Ad_UnsuccessfulService_DATE		 = NULL,
			@Ac_UnsuccessfulService_CODE		 = NULL;
		
	DECLARE @Lc_ServiceResultN_CODE			CHAR(1) = 'N',
			@Lc_ActivityMajorESTP_CODE		CHAR(4) = 'ESTP';
	 
	 SELECT @Ad_UnsuccessfulService_DATE = f.Service_DATE,
			@Ac_UnsuccessfulService_CODE = f.ServiceFailureReason_CODE
	   FROM DMJR_Y1 a JOIN FSRT_Y1 f
		 ON f.Case_IDNO = a.Case_IDNO
		AND f.MajorIntSeq_NUMB = a.MajorIntSeq_NUMB
	  WHERE a.Case_IDNO				= @An_Case_IDNO
		AND a.ActivityMajor_CODE	= @Lc_ActivityMajorESTP_CODE
		AND f.ServiceResult_CODE    = @Lc_ServiceResultN_CODE;
	                      
END;  --END OF FSRT_RETRIEVE_S7


GO
