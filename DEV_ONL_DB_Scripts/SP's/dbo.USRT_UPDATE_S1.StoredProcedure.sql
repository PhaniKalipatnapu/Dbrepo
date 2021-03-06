/****** Object:  StoredProcedure [dbo].[USRT_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRT_UPDATE_S1] (
 @Ac_Worker_ID						CHAR(30),
 @An_Case_IDNO						NUMERIC(6, 0),
 @An_MemberMci_IDNO					NUMERIC(10, 0),
 @Ac_HighProfile_INDC				CHAR(1),
 @Ac_Familial_INDC					CHAR(1),
 @An_TransactionEventSeq_NUMB		NUMERIC(19),
 @Ac_SignedOnWorker_ID				CHAR(30),
 @Ad_End_DATE						DATE,
 @Ac_Reason_CODE					CHAR(1),
 @An_NewTransactionEventSeq_NUMB    NUMERIC(19)
 )
AS
 /*
 *     PROCEDURE NAME    : USRT_UPDATE_S1
 *     DESCRIPTION       : Modifies the restricted case details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 26-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;

  UPDATE USRT_Y1
     SET HighProfile_INDC		  = @Ac_HighProfile_INDC,
         Familial_INDC			  = @Ac_Familial_INDC,
         BeginValidity_DATE		  = @Ld_Current_DATE,
         TransactionEventSeq_NUMB = @An_NewTransactionEventSeq_NUMB,
		 Update_DTTM              = @Ld_Current_DTTM,
		 WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
		 End_DATE				  = @Ad_End_DATE,
		 Reason_CODE			  = @Ac_Reason_CODE
     OUTPUT Deleted.Worker_ID,
			Deleted.Case_IDNO,
			Deleted.MemberMci_IDNO,
			Deleted.HighProfile_INDC,
			Deleted.Familial_INDC,
			Deleted.BeginValidity_DATE,
			@Ld_Current_DATE AS EndValidity_DATE ,
			Deleted.TransactionEventSeq_NUMB,
			Deleted.Update_DTTM,
			Deleted.WorkerUpdate_ID,
			Deleted.End_DATE,
			Deleted.Reason_CODE
      INTO USRT_Y1       
   WHERE Case_IDNO = @An_Case_IDNO
     AND MemberMci_IDNO = @An_MemberMci_IDNO
     AND (@Ac_Worker_ID IS NULL
           OR Worker_ID = @Ac_Worker_ID)
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;

 END


GO
