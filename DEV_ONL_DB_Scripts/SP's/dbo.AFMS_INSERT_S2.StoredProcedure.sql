/****** Object:  StoredProcedure [dbo].[AFMS_INSERT_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_INSERT_S2] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Reason_CODE              CHAR(2),
 @Ac_ActivityMajorNext_CODE   CHAR(4),
 @Ac_ActivityMinorNext_CODE   CHAR(5),
 @Ac_Notice_ID                CHAR(8),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : AFMS_INSERT_S2
  *     DESCRIPTION       : This Procedure used to insert worker who delete the form into form master table. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  INSERT AFMS_Y1
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
  SELECT AF.ActivityMinor_CODE,
         AF.Notice_ID,
         @Ld_Systemdatetime_DTTM,
         @Ld_Systemdatetime_DTTM,
         @Ac_SignedOnWorker_ID,
         @Ld_Systemdatetime_DTTM,
         @An_TransactionEventSeq_NUMB,
         AF.TypeEditNotice_CODE,
         AF.ApprovalRequired_INDC,
         AF.ActivityMajor_CODE,
         AF.Reason_CODE,
         AF.ActivityMajorNext_CODE,
         AF.ActivityMinorNext_CODE,
         AF.NoticeOrder_NUMB,
         AF.Recipient_CODE,
         AF.RecipientSeq_NUMB,
         AF.TypeService_CODE,
         AF.PrintMethod_CODE,
         AF.Mask_INDC
    FROM AFMS_Y1 AF
   WHERE AF.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND AF.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND AF.Reason_CODE = @Ac_Reason_CODE
     AND AF.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND AF.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND AF.Notice_ID = @Ac_Notice_ID
     AND AF.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of AFMS_INSERT_S2

GO
