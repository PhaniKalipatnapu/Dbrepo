/****** Object:  StoredProcedure [dbo].[MINS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MINS_INSERT_S1](
 @An_MemberMci_IDNO                NUMERIC(10, 0),
 @An_OthpInsurance_IDNO            NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT         CHAR(25),
 @Ac_PolicyInsNo_TEXT              CHAR(20),
 @Ad_Begin_DATE                    DATE,
 @Ad_End_DATE                      DATE,
 @Ac_Status_CODE                   CHAR(2),
 @Ad_Status_DATE                   DATE,
 @Ac_SourceVerified_CODE           CHAR(3),
 @Ac_PolicyHolderRelationship_CODE CHAR(2),
 @Ac_EmployerPaid_INDC             CHAR(1),
 @An_MonthlyPremium_AMNT           NUMERIC(11, 2),
 @As_DescriptionOtherIns_TEXT      VARCHAR(50),
 @Ac_MedicalIns_INDC               CHAR(1),
 @An_CoPay_AMNT                    NUMERIC(11, 2),
 @Ac_DentalIns_INDC                CHAR(1),
 @Ac_VisionIns_INDC                CHAR(1),
 @Ac_PrescptIns_INDC               CHAR(1),
 @Ac_MentalIns_INDC                CHAR(1),
 @An_OthpEmployer_IDNO             NUMERIC(9, 0),
 @Ac_NonQualified_CODE             CHAR(1),
 @As_PolicyHolder_NAME             VARCHAR(62),
 @An_PolicyHolderSsn_NUMB          NUMERIC(9, 0),
 @Ad_BirthPolicyHolder_DATE        DATE,
 @Ac_SignedOnWorker_ID             CHAR(30),
 @An_TransactionEventSeq_NUMB      NUMERIC(19, 0),
 @Ac_PolicyAnnivMonth_CODE         CHAR(2)
 )
AS
 /*  
  *     PROCEDURE NAME    : MINS_INSERT_S1  
  *     DESCRIPTION       : Insert Member Insurance details with the SET values such as Policy Holder Name, SSN and DOB for Unique number assigned by the system to the participant, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant, etc., into Member Insurance table.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 12-OCT-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Lc_No_INDC      CHAR(1)='N',
          @Ld_Current_DTTM DATETIME2= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE    DATE ='12/31/9999',
          @Lc_Space_TEXT   CHAR(1)=' ';

  INSERT MINS_Y1
         (MemberMci_IDNO,
          OthpInsurance_IDNO,
          InsuranceGroupNo_TEXT,
          PolicyInsNo_TEXT,
          Begin_DATE,
          End_DATE,
          InsSource_CODE,
          Status_CODE,
          Status_DATE,
          SourceVerified_CODE,
          PolicyHolderRelationship_CODE,
          TypePolicy_CODE,
          EmployerPaid_INDC,
          DescriptionCoverage_TEXT,
          MonthlyPremium_AMNT,
          Contact_NAME,
          SpecialNeeds_INDC,
          OtherIns_INDC,
          DescriptionOtherIns_TEXT,
          MedicalIns_INDC,
          CoPay_AMNT,
          DentalIns_INDC,
          VisionIns_INDC,
          PrescptIns_INDC,
          MentalIns_INDC,
          OthpEmployer_IDNO,
          NonQualified_CODE,
          PolicyHolder_NAME,
          PolicyHolderSsn_NUMB,
          BirthPolicyHolder_DATE,
          BeginValidity_DATE,
          EndValidity_DATE,
          WorkerUpdate_ID,
          Update_DTTM,
          TransactionEventSeq_NUMB,
          PolicyAnnivMonth_CODE)
  VALUES ( @An_MemberMci_IDNO,
           @An_OthpInsurance_IDNO,
           @Ac_InsuranceGroupNo_TEXT,
           @Ac_PolicyInsNo_TEXT,
           @Ad_Begin_DATE,
           @Ad_End_DATE,
           @Lc_Space_TEXT,
           @Ac_Status_CODE,
           @Ad_Status_DATE,
           @Ac_SourceVerified_CODE,
           @Ac_PolicyHolderRelationship_CODE,
           @Lc_Space_TEXT,
           @Ac_EmployerPaid_INDC,
           @Lc_Space_TEXT,
           @An_MonthlyPremium_AMNT,
           @Lc_Space_TEXT,
           @Lc_No_INDC,
           @Lc_No_INDC,
           @As_DescriptionOtherIns_TEXT,
           @Ac_MedicalIns_INDC,
           @An_CoPay_AMNT,
           @Ac_DentalIns_INDC,
           @Ac_VisionIns_INDC,
           @Ac_PrescptIns_INDC,
           @Ac_MentalIns_INDC,
           @An_OthpEmployer_IDNO,
           @Ac_NonQualified_CODE,
           @As_PolicyHolder_NAME,
           @An_PolicyHolderSsn_NUMB,
           @Ad_BirthPolicyHolder_DATE,
           @Ld_Current_DTTM,
           @Ld_High_DATE,
           @Ac_SignedOnWorker_ID,
           @Ld_Current_DTTM,
           @An_TransactionEventSeq_NUMB,
           @Ac_PolicyAnnivMonth_CODE);
 END -- End of MINS_INSERT_S1

GO
