/****** Object:  StoredProcedure [dbo].[DINS_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_UPDATE_S2](
 @An_MemberMci_IDNO              NUMERIC(10, 0),
 @An_OthpInsurance_IDNO          NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT       CHAR(25),
 @Ac_PolicyInsNo_TEXT            CHAR(20),
 @An_ChildMCI_IDNO               NUMERIC(10, 0),
 @Ad_Begin_DATE                  DATE,
 @Ad_BeginNew_DATE               DATE,
 @Ad_End_DATE                    DATE,
 @Ad_Status_DATE                 DATE,
 @Ac_MedicalIns_INDC             CHAR(1),
 @Ac_DentalIns_INDC              CHAR(1),
 @Ac_VisionIns_INDC              CHAR(1),
 @Ac_PrescptIns_INDC             CHAR(1),
 @Ac_MentalIns_INDC              CHAR(1),
 @As_DescriptionOthers_TEXT      VARCHAR(50),
 @An_TransactionEventSeq_NUMB    NUMERIC(19, 0),
 @Ad_EndValidity_DATE            DATE,
 @Ac_SignedOnWorker_ID           CHAR(30),
 @Ac_Status_CODE                 CHAR(2),
 @Ac_InsuranceGroupNoNew_TEXT    CHAR(25),
 @Ac_PolicyInsNoNew_TEXT         CHAR(20),
 @An_TransactionEventSeqNew_NUMB NUMERIC(19, 0)
 )
AS
 /*    
  *     PROCEDURE NAME    : DINS_UPDATE_S2    
  *     DESCRIPTION       : Logically delete the record in Dependant Insurance table for Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent), Dependent's ID for whom the insurance is provided, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant and Date from the which the Insurance Policy Starts with End Validity Date equal to High Date (31-DEC-9999).
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 12-OCT-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10),
          @Lc_No_INDC           CHAR(1) = 'N',
          @Lc_Space_TEXT        CHAR(1) =' ',
          @Ld_Current_DTTM      DATETIME2= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE ='12/31/9999';

  UPDATE DINS_Y1
     SET EndValidity_DATE = @Ad_EndValidity_DATE
  OUTPUT @An_MemberMci_IDNO AS MemberMci_IDNO,
         @An_OthpInsurance_IDNO AS OthpInsurance_IDNO,
         @Ac_InsuranceGroupNoNew_TEXT AS InsuranceGroupNo_TEXT,
         @Ac_PolicyInsNoNew_TEXT AS PolicyInsNo_TEXT,
         @An_ChildMCI_IDNO AS ChildMCI_IDNO,
         @Ad_BeginNew_DATE AS Begin_DATE,
         @Ad_End_DATE AS End_DATE,
         @Ad_Status_DATE AS Status_DATE,
         @Ac_MedicalIns_INDC AS MedicalIns_INDC,
         @Ac_DentalIns_INDC AS DentalIns_INDC,
         @Ac_VisionIns_INDC AS VisionIns_INDC,
         @Ac_PrescptIns_INDC AS PrescptIns_INDC,
         @Ac_MentalIns_INDC AS MentalIns_INDC,
         @As_DescriptionOthers_TEXT AS DescriptionOthers_TEXT,
         @Ac_Status_CODE AS Status_CODE,
         @Lc_No_INDC AS NonQualified_CODE,
         @Lc_Space_TEXT AS InsSource_CODE,
         @Ld_Current_DTTM AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
         @Ld_Current_DTTM AS Update_DTTM,
         @An_TransactionEventSeqNew_NUMB AS TransactionEventSeq_NUMB
  INTO DINS_Y1
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND InsuranceGroupNo_TEXT = @Ac_InsuranceGroupNo_TEXT
     AND PolicyInsNo_TEXT = @Ac_PolicyInsNo_TEXT
     AND ChildMCI_IDNO = @An_ChildMCI_IDNO
     AND Begin_DATE = @Ad_Begin_DATE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END -- End of DINS_UPDATE_S2

GO
