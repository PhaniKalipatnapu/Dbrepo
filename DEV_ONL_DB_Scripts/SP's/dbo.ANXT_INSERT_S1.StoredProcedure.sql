/****** Object:  StoredProcedure [dbo].[ANXT_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_INSERT_S1] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Reason_CODE              CHAR(2),
 @An_ParallelSeq_QNTY         NUMERIC(3, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_ActivityOrder_QNTY       NUMERIC(3, 0),
 @An_ReasonOrder_QNTY         NUMERIC(3, 0),
 @Ac_RespManSys_CODE          CHAR(1),
 @Ac_ActivityMajorNext_CODE   CHAR(4),
 @Ac_ActivityMinorNext_CODE   CHAR(5),
 @Ac_Group_ID                 CHAR(5),
 @Ac_GroupNext_ID             CHAR(5),
 @Ac_Function1_CODE           CHAR(3),
 @Ac_Action1_CODE             CHAR(1),
 @Ac_Reason1_CODE             CHAR(5),
 --@As_Procedure1_NAME          VARCHAR(75),
 @Ac_Function2_CODE           CHAR(3),
 @Ac_Action2_CODE             CHAR(1),
 @Ac_Reason2_CODE             CHAR(5),
 --@As_Procedure2_NAME          VARCHAR(75),
 @Ac_Error_CODE               CHAR(18),
 @As_Procedure_NAME           VARCHAR(100),
 @Ac_NavigateTo_CODE          CHAR(4),
 @As_CsenetComment1_TEXT      VARCHAR(300),
 @As_CsenetComment2_TEXT      VARCHAR(300),
 @Ac_Alert_CODE               CHAR(5),
 @Ac_ScannedDocuments_INDC    CHAR(1),
 @Ac_RejectionReason_INDC     CHAR(1),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
 *      PROCEDURE NAME    : ANXT_INSERT_S1
  *     DESCRIPTION       : Inserts the retrieved Major and Minor activity documents which was retrieved using generated sequence transaction number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Systemdate_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT ANXT_Y1
         (ActivityMajor_CODE,
          ActivityMinor_CODE,
          ActivityOrder_QNTY,
          Reason_CODE,
          ReasonOrder_QNTY,
          ParallelSeq_QNTY,
          RespManSys_CODE,
          ActivityMajorNext_CODE,
          ActivityMinorNext_CODE,
          Group_ID,
          GroupNext_ID,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          Function1_CODE,
          Action1_CODE,
          Reason1_CODE,
          Function2_CODE,
          Action2_CODE,
          Reason2_CODE,
          Error_CODE,
          Procedure_NAME,
          NavigateTo_CODE,
          CsenetComment1_TEXT,
          CsenetComment2_TEXT,
          Alert_CODE,
          ScannedDocuments_INDC,
          RejectionReason_INDC)
  VALUES ( @Ac_ActivityMajor_CODE,
           @Ac_ActivityMinor_CODE,
           @An_ActivityOrder_QNTY,
           @Ac_Reason_CODE,
           @An_ReasonOrder_QNTY,
           @An_ParallelSeq_QNTY,
           @Ac_RespManSys_CODE,
           @Ac_ActivityMajorNext_CODE,
           @Ac_ActivityMinorNext_CODE,
           @Ac_Group_ID,
           @Ac_GroupNext_ID,
           @Ld_Systemdate_DTTM,
           @Ld_Systemdate_DTTM,
           @Ac_SignedOnWorker_ID,
           @Ld_Systemdate_DTTM,
           @An_TransactionEventSeq_NUMB,
           @Ac_Function1_CODE,
           @Ac_Action1_CODE,
           @Ac_Reason1_CODE,
           --@As_Procedure1_NAME,
           @Ac_Function2_CODE,
           @Ac_Action2_CODE,
           @Ac_Reason2_CODE,
           --@As_Procedure2_NAME,
           @Ac_Error_CODE,
           @As_Procedure_NAME,
           @Ac_NavigateTo_CODE,
           @As_CsenetComment1_TEXT,
           @As_CsenetComment2_TEXT,
           @Ac_Alert_CODE,
           @Ac_ScannedDocuments_INDC,
           @Ac_RejectionReason_INDC );
 END; -- End of ANXT_INSERT_S1


GO
