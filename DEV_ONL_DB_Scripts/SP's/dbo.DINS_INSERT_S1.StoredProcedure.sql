/****** Object:  StoredProcedure [dbo].[DINS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_INSERT_S1](
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_OthpInsurance_IDNO       NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT    CHAR(25),
 @Ac_PolicyInsNo_TEXT         CHAR(20),
 @An_ChildMCI_IDNO            NUMERIC(10, 0),
 @Ad_Begin_DATE               DATE,
 @Ad_End_DATE                 DATE,
 @Ac_MedicalIns_INDC          CHAR(1),
 @Ac_DentalIns_INDC           CHAR(1),
 @Ac_VisionIns_INDC           CHAR(1),
 @Ac_PrescptIns_INDC          CHAR(1),
 @Ac_MentalIns_INDC           CHAR(1),
 @As_DescriptionOthers_TEXT   VARCHAR(50),
 @Ac_Status_CODE              CHAR(2),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DINS_INSERT_S1
  *     DESCRIPTION       : Insert Dependant Insurance details with new Sequence Event Transaction, Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent), Dependent's ID for whom the insurance is provided, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant, etc., into Dependant Insurance table. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 13-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 DECLARE @Ld_Current_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         @Lc_Space_TEXT   CHAR(1) = ' ',
         @Lc_No_INDC      CHAR(1) ='N',
         @Ld_High_DATE    DATE = '12/31/9999';

 BEGIN
  INSERT DINS_Y1
         (MemberMci_IDNO,
          OthpInsurance_IDNO,
          InsuranceGroupNo_TEXT,
          PolicyInsNo_TEXT,
          ChildMCI_IDNO,
          Begin_DATE,
          End_DATE,
          Status_DATE,
          MedicalIns_INDC,
          DentalIns_INDC,
          VisionIns_INDC,
          PrescptIns_INDC,
          MentalIns_INDC,
          DescriptionOthers_TEXT,
          Status_CODE,
          NonQualified_CODE,
          InsSource_CODE,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB)
  VALUES ( @An_MemberMci_IDNO,
           @An_OthpInsurance_IDNO,
           @Ac_InsuranceGroupNo_TEXT,
           @Ac_PolicyInsNo_TEXT,
           @An_ChildMCI_IDNO,
           @Ad_Begin_DATE,
           @Ad_End_DATE,
           @Ld_Current_DTTM,
           @Ac_MedicalIns_INDC,
           @Ac_DentalIns_INDC,
           @Ac_VisionIns_INDC,
           @Ac_PrescptIns_INDC,
           @Ac_MentalIns_INDC,
           @As_DescriptionOthers_TEXT,
           @Ac_Status_CODE,
           @Lc_No_INDC,
           @Lc_Space_TEXT,
           @Ld_Current_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Current_DTTM,
           @An_TransactionEventSeq_NUMB );
 END -- End of DINS_INSERT_S1

GO
