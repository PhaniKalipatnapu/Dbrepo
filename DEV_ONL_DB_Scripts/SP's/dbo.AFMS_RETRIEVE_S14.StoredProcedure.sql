/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S14] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Reason_CODE              CHAR(2),
 @Ac_ActivityMajorNext_CODE   CHAR(4),
 @Ac_ActivityMinorNext_CODE   CHAR(5),
 @Ac_Notice_ID                CHAR(8),
 @Ac_Recipient_CODE           CHAR(2),
 @Ac_TypeService_CODE         CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : AFMS_RETRIEVE_S14
  *     DESCRIPTION       : Get all the details for Activity Form Master Reference for the given event lock sequence is equal Unique Sequence Number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 08-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT a.ActivityMajor_CODE,
         a.ActivityMinor_CODE,
         a.Reason_CODE,
         a.ActivityMajorNext_CODE,
         a.ActivityMinorNext_CODE,
         a.Notice_ID,
         a.ApprovalRequired_INDC,
         a.TypeEditNotice_CODE,
         a.NoticeOrder_NUMB,
         a.RecipientSeq_NUMB,
         a.Mask_INDC
    FROM AFMS_Y1 a
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND a.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND a.Notice_ID = @Ac_Notice_ID
     AND a.TypeService_CODE = @Ac_TypeService_CODE
     AND a.Recipient_CODE = @Ac_Recipient_CODE
     AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
 END; --End of AFMS_RETRIEVE_S14


GO
