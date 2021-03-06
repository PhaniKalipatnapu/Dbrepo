/****** Object:  StoredProcedure [dbo].[ANXT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_RETRIEVE_S1] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_ActivityMinorNext_CODE CHAR(5),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ANXT_RETRIEVE_S1
  *     DESCRIPTION       : This procedure checks whether Worker notes is entered required or not for a particular step of activity chain.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE  DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM ANXT_Y1 a
         JOIN RARE_Y1 r
          ON a.ActivityMajor_CODE = r.ActivityMajor_CODE
             AND a.ActivityMinor_CODE = r.ActivityMinor_CODE
             AND a.Reason_CODE = r.Reason_CODE
             AND a.ActivityMinorNext_CODE = r.ActivityMinorNext_CODE
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND r.Notice_ID = @Lc_Space_TEXT
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ANXT_RETRIEVE_S1


GO
