/****** Object:  StoredProcedure [dbo].[DINS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_UPDATE_S1](
 @An_MemberMci_IDNO              NUMERIC(10, 0),
 @An_OthpInsurance_IDNO          NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT       CHAR(25),
 @Ac_PolicyInsNo_TEXT            CHAR(20),
 @An_ChildMCI_IDNO               NUMERIC(10, 0),
 @Ad_Begin_DATE                  DATE,
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID           CHAR(30),
 @An_TransactionEventSeqNew_NUMB NUMERIC(19, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : DINS_UPDATE_S1    
  *     DESCRIPTION       : Logically delete the record in Dependant Insurance table for Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent), Dependent's ID for whom the insurance is provided, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant and Date from the which the Insurance Policy Starts with End Validity Date equal to High Date (31-DEC-9999).
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 19-OCT-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Ld_Current_DTTM      DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  UPDATE DINS_Y1
     SET EndValidity_DATE = @Ld_Current_DTTM
  OUTPUT DELETED.MemberMci_IDNO,
         DELETED.OthpInsurance_IDNO,
         DELETED.InsuranceGroupNo_TEXT,
         DELETED.PolicyInsNo_TEXT,
         DELETED.ChildMCI_IDNO,
         DELETED.Begin_DATE,
         @Ld_Current_DTTM AS End_DATE,
         DELETED.Status_DATE,
         DELETED.MedicalIns_INDC,
         DELETED.DentalIns_INDC,
         DELETED.VisionIns_INDC,
         DELETED.PrescptIns_INDC,
         DELETED.MentalIns_INDC,
         DELETED.DescriptionOthers_TEXT,
         DELETED.Status_CODE,
         DELETED.NonQualified_CODE,
         DELETED.InsSource_CODE,
         @Ld_Current_DTTM AS BeginValidity_DATE,
         @Ld_Current_DTTM AS EndValidity_DATE,
         @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
         @Ld_Current_DTTM AS Update_DTTM,
         @An_TransactionEventSeqNew_NUMB AS TransactionEventSeq_NUMB
  INTO DINS_Y1
   WHERE DINS_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
     AND DINS_Y1.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND DINS_Y1.InsuranceGroupNo_TEXT = @Ac_InsuranceGroupNo_TEXT
     AND DINS_Y1.PolicyInsNo_TEXT = @Ac_PolicyInsNo_TEXT
     AND DINS_Y1.ChildMCI_IDNO = @An_ChildMCI_IDNO
     AND DINS_Y1.Begin_DATE = @Ad_Begin_DATE
     AND DINS_Y1.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END -- End of DINS_UPDATE_S1

GO
