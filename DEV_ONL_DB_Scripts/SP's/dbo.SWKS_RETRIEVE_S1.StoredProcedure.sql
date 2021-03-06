/****** Object:  StoredProcedure [dbo].[SWKS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SWKS_RETRIEVE_S1] (
     @An_Case_IDNO		NUMERIC(6,0),
     @Ac_Exists_INDC	CHAR(1)	OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : SWKS_RETRIEVE_S1
 *     DESCRIPTION       : Checking whether given Case_ID in Scheduled status.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN



	DECLARE @Lc_ScheduleStatusRs_CODE	CHAR(2) = 'RS', 
			@Lc_ScheduleStatusSc_CODE	CHAR(2) = 'SC',
			@Lc_No_TEXT					CHAR(1)	= 'N',
			@Lc_Yes_TEXT				CHAR(1)	= 'Y';
			
	SET @Ac_Exists_INDC = @Lc_No_TEXT;
        
	SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
	  FROM SWKS_Y1 S
	 WHERE S.Case_IDNO = @An_Case_IDNO 
	   AND S.ApptStatus_CODE IN ( @Lc_ScheduleStatusSc_CODE, @Lc_ScheduleStatusRs_CODE );

                  
END; --END OF SWKS_RETRIEVE_S1

GO
