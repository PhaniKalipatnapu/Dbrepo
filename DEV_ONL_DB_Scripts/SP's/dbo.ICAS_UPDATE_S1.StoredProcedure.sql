/****** Object:  StoredProcedure [dbo].[ICAS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_UPDATE_S1] (
 @An_Case_IDNO                NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE   CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @As_Petitioner_NAME          VARCHAR(65),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*                                                          
 *     PROCEDURE NAME    : ICAS_UPDATE_S1 
 *     DESCRIPTION       : Logically delete the record in Interstate Cases table for the retrieved IVD Open (O) Case and retrieved Interstate Case State.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DTTM      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Lc_StatusOpen_CODE   CHAR(1) = 'O',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE ICAS_Y1
     SET TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
         Update_DTTM = @Ld_Current_DTTM,
         WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
         BeginValidity_DATE = @Ld_Current_DTTM,
         Petitioner_NAME = @As_Petitioner_NAME
  OUTPUT DELETED.Case_IDNO,
         DELETED.IVDOutOfStateCase_ID,
         DELETED.IVDOutOfStateFips_CODE,
         DELETED.IVDOutOfStateOfficeFips_CODE,
         DELETED.IVDOutOfStateCountyFips_CODE,
         DELETED.Status_CODE,
         DELETED.Effective_DATE,
         DELETED.End_DATE,
         DELETED.RespondInit_CODE,
         DELETED.ControlByCrtOrder_INDC,
         DELETED.ContOrder_DATE,
         DELETED.ContOrder_ID,
         DELETED.IVDOutOfStateFile_ID,
         DELETED.Petitioner_NAME,
         DELETED.ContactFirst_NAME,
         DELETED.Respondent_NAME,
         DELETED.ContactLast_NAME,
         DELETED.ContactMiddle_NAME,
         DELETED.PhoneContact_NUMB,
         DELETED.Referral_DATE,
         DELETED.Contact_EML,
         DELETED.FaxContact_NUMB,
         DELETED.File_ID,
         DELETED.County_IDNO,
         DELETED.IVDOutOfStateTypeCase_CODE,
         DELETED.Create_DATE,
         DELETED.Worker_ID,
         DELETED.Update_DTTM,
         DELETED.WorkerUpdate_ID,
         DELETED.TransactionEventSeq_NUMB,
         @Ld_Current_DTTM AS EndValidity_DATE,
         DELETED.BeginValidity_DATE,
         DELETED.Reason_CODE,
         DELETED.RespondentMci_IDNO,
         DELETED.PetitionerMci_IDNO,
         DELETED.DescriptionComments_TEXT
  INTO ICAS_Y1
   WHERE Case_IDNO = @An_Case_IDNO
     AND EndValidity_DATE = @Ld_High_DATE
     AND IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND Status_CODE = @Lc_StatusOpen_CODE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- End Of ICAS_UPDATE_S1

GO
