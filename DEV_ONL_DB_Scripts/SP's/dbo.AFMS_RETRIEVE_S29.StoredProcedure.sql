/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S29] (
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5),
 @Ac_Reason_CODE            CHAR(2),
 @Ac_ActivityMajorNext_CODE CHAR(4),
 @Ac_ActivityMinorNext_CODE CHAR(5),
 @Ac_Notice_ID              CHAR(8),
 @Ac_ApprovalRequired_INDC  CHAR(1) OUTPUT,
 @Ac_TypeEditNotice_CODE    CHAR(1) OUTPUT,
 @An_NoticeOrder_NUMB       NUMERIC(3, 0) OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : AFMS_RETRIEVE_S29
  *     DESCRIPTION       : Returns Approval Required Indication and Notice Edit Type for a Given Activity Chain Step
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 08-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_ApprovalRequired_INDC = NULL,
         @Ac_TypeEditNotice_CODE = NULL,
         @An_NoticeOrder_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_TypeEditNotice_CODE = a.TypeEditNotice_CODE,
               @Ac_ApprovalRequired_INDC = a.ApprovalRequired_INDC,
               @An_NoticeOrder_NUMB = a.NoticeOrder_NUMB
    FROM AFMS_Y1 a
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND a.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND a.Notice_ID = @Ac_Notice_ID
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of AFMS_RETRIEVE_S29

GO
