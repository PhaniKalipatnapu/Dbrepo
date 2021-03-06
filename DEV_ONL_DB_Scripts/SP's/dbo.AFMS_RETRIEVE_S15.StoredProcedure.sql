/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S15] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_ActivityMajorNext_CODE CHAR(4),
 @Ac_ActivityMinorNext_CODE CHAR(5),
 @Ac_Notice_ID              CHAR(8),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AFMS_RETRIEVE_S15
  *     DESCRIPTION       : Return record count if the number of recipients exists for a document i.e. for the given Major and Minor Activity code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 08-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM (SELECT A.recipient_code,
                 A.typeservice_code
            FROM AFMS_Y1 A
           WHERE A.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
             AND A.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
             AND A.Reason_CODE = @Ac_Reason_CODE
             AND A.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
             AND A.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
             AND A.Notice_ID = @Ac_Notice_ID
             AND A.EndValidity_DATE = @Ld_High_DATE
           GROUP BY A.recipient_code,
                    A.typeservice_code) AS A;
 END; --End Of AFMS_RETRIEVE_S15

GO
