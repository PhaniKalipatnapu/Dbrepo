/****** Object:  StoredProcedure [dbo].[FSRT_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FSRT_RETRIEVE_S6] 
( 
	@An_Case_IDNO			NUMERIC(6,0),
	@Ad_Begin_DATE			DATE,
	@Ad_End_DATE			DATE,
	@Ad_Service_DATE		DATE OUTPUT
)  
AS
/*
 *     PROCEDURE NAME    : FSRT_RETRIEVE_S6
 *     DESCRIPTION       : This procedure is used to retrieve the service date.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 03-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
		SET @Ad_Service_DATE			= NULL;
		
	DECLARE @Lc_StatusCOMP_CODE				CHAR(4) = 'COMP',
			@Lc_ActivityMajorESTP_CODE		CHAR(4) = 'ESTP',
			@Lc_ActivityMinorRSDHG_CODE		CHAR(5) = 'RSDHG';
	 
	 SELECT @Ad_Service_DATE = f.Service_DATE
	   FROM DMJR_Y1 a JOIN DMNR_Y1 b
		 ON b.Case_IDNO				= a.Case_IDNO
		AND b.OrderSeq_NUMB			= a.OrderSeq_NUMB
		AND b.MajorIntSeq_NUMB		= a.MajorIntSeq_NUMB
		    JOIN FSRT_Y1 f
		 ON f.Case_IDNO = a.Case_IDNO
		AND f.MajorIntSeq_NUMB = a.MajorIntSeq_NUMB
	  WHERE a.Case_IDNO				= @An_Case_IDNO
		AND a.ActivityMajor_CODE	= @Lc_ActivityMajorESTP_CODE
		AND b.ActivityMinor_CODE	= @Lc_ActivityMinorRSDHG_CODE
		AND b.Status_CODE			= @Lc_StatusCOMP_CODE
		AND b.Status_DATE BETWEEN @Ad_Begin_DATE AND @Ad_End_DATE;
	                      
END;  --END OF FSRT_RETRIEVE_S6


GO
