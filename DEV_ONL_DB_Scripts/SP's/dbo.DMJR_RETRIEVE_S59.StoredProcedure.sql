/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S59]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S59] (
 @An_Case_IDNO          NUMERIC(6),
 @Ac_ActivityMajor_CODE CHAR(4),
 @An_OthpSource_IDNO    NUMERIC(10),
 @Ac_Reference_ID       CHAR(30),
 @Ai_Count_QNTY         INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S59
  *     DESCRIPTION       : Retrieve the record count of Forum ID for the given Case ID , Activity Major Code, Reference type and Other party Source ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
BEGIN
	-- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Start
	DECLARE @Lc_StatusStart_CODE			CHAR(4) = 'STRT',
			@Lc_ActivityMajorLsnr_CODE		CHAR(4) = 'LSNR',
			@Lc_ActivityMajorCpls_CODE		CHAR(4)	= 'CPLS';

	SELECT @Ai_Count_QNTY = COUNT(1)
	  FROM DMJR_Y1 b
	WHERE b.Case_IDNO = @An_Case_IDNO
	  AND b.Status_CODE = @Lc_StatusStart_CODE
	  AND ( b.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
			 OR ( @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
					AND b.ActivityMajor_CODE IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE) 
				)
		  )
	  AND b.OthpSource_IDNO = @An_OthpSource_IDNO
	  AND b.Reference_ID = @Ac_Reference_ID;
	 -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - End
END; --End of DMJR_RETRIEVE_S59


GO
