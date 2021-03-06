/****** Object:  StoredProcedure [dbo].[AFMS_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_INSERT_S1] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Reason_CODE              CHAR(2),
 @Ac_ActivityMajorNext_CODE   CHAR(4),
 @Ac_ActivityMinorNext_CODE   CHAR(5),
 @Ac_Notice_ID                CHAR(8),
 @Ac_Recipient_CODE           CHAR(2),
 @Ac_TypeService_CODE         CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_ApprovalRequired_INDC    CHAR(1),
 @Ac_TypeEditNotice_CODE      CHAR(1),
 @An_NoticeOrder_NUMB         NUMERIC(3, 0),
 @An_RecipientSeq_NUMB        NUMERIC(3, 0),
 @Ac_PrintMethod_CODE         CHAR(2),
 @Ac_Mask_INDC                CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : AFMS_INSERT_S1
  *     DESCRIPTION       : Insert the Activity form master reference details when Notice is required and no need to mask the confidential data.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT INTO AFMS_Y1
              (ActivityMinor_CODE,
               Notice_ID,
               BeginValidity_DATE,
               EndValidity_DATE,
               WorkerUpdate_ID,
               Update_DTTM,
               TransactionEventSeq_NUMB,
               TypeEditNotice_CODE,
               ApprovalRequired_INDC,
               ActivityMajor_CODE,
               Reason_CODE,
               ActivityMajorNext_CODE,
               ActivityMinorNext_CODE,
               NoticeOrder_NUMB,
               Recipient_CODE,
               RecipientSeq_NUMB,
               TypeService_CODE,
               PrintMethod_CODE,
               Mask_INDC)
       VALUES ( @Ac_ActivityMinor_CODE,
                @Ac_Notice_ID,
                @Ld_Systemdatetime_DTTM,
                @Ld_High_DATE,
                @Ac_SignedOnWorker_ID,
                @Ld_Systemdatetime_DTTM,
                @An_TransactionEventSeq_NUMB,
                @Ac_TypeEditNotice_CODE,
                @Ac_ApprovalRequired_INDC,
                @Ac_ActivityMajor_CODE,
                @Ac_Reason_CODE,
                @Ac_ActivityMajorNext_CODE,
                @Ac_ActivityMinorNext_CODE,
                @An_NoticeOrder_NUMB,
                @Ac_Recipient_CODE,
                @An_RecipientSeq_NUMB,
                @Ac_TypeService_CODE,
                @Ac_PrintMethod_CODE,
                ISNULL((SELECT TOP 1 Mask_INDC
									   FROM AFMS_Y1 a  
										   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE  
											 AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE  
											 AND a.Reason_CODE = @Ac_Reason_CODE  
											 AND a.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE  
											 AND a.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE  
											 AND a.Notice_ID = @Ac_Notice_ID  
											 AND a.EndValidity_DATE = @Ld_High_DATE),@Ac_Mask_INDC));
 END; --End Of AFMS_INSERT_S1


GO
