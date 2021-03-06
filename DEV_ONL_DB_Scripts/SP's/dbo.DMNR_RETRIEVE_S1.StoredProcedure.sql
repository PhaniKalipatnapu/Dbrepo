/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S1]  
(
     @An_Case_IDNO					NUMERIC(6),
     @Ai_DateDiff_NUMB				INT,
     @Ai_Count_QNTY					INT OUTPUT
  )
AS

/*
 *     PROCEDURE NAME    : DMNR_RETRIEVE_S1
 *     DESCRIPTION       : This procedure is used to find how many times the Disapproved is completed in the Case Closure Activity for the given Case ID 
 *						   and within the time frame.
 *     DEVELOPED BY      : IMP Team.
 *     DEVELOPED ON      : 24-SEP-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */
   BEGIN
    DECLARE @Lc_ReasonStatusDd_CODE		CHAR(2)	= 'DD',
			@Lc_ActivityMajorCclo_CODE	CHAR(4)	= 'CCLO';
    DECLARE @Ld_Current_DATE			DATE	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

        SELECT @Ai_Count_QNTY = COUNT(1) 
		  FROM DMNR_Y1 d
		 WHERE d.Case_IDNO = @An_Case_IDNO
		   AND d.ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE
		   AND d.ReasonStatus_CODE = @Lc_ReasonStatusDd_CODE
		   AND d.Status_DATE >= DATEADD(D, -@Ai_DateDiff_NUMB ,@Ld_Current_DATE);
		   
	END; -- END OF DMNR_RETRIEVE_S1



GO
