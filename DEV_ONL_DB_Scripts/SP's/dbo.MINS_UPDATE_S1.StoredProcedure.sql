/****** Object:  StoredProcedure [dbo].[MINS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MINS_UPDATE_S1](
 @An_MemberMci_IDNO                NUMERIC(10, 0),
 @An_OthpInsurance_IDNO            NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT         CHAR(25),
 @Ac_PolicyInsNo_TEXT              CHAR(20),
 @Ad_Begin_DATE                    DATE,
 @Ad_End_DATE                      DATE,
 @Ad_Status_DATE                   DATE,
 @Ac_Status_CODE                   CHAR(2),
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
 @An_TransactionEventSeqNew_NUMB   NUMERIC(19, 0),
 @Ac_PolicyAnnivMonth_CODE         CHAR(2),
 @Ac_InsuranceGroupNoNew_TEXT      CHAR(25),
 @Ac_PolicyInsNoNew_TEXT           CHAR(20)
 )
AS
 /*
  *     PROCEDURE NAME    : MINS_UPDATE_S1
  *     DESCRIPTION       : Logically delete the record in Member Insurance table for Unique number assigned by the system to the participant, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant, Date from the which the Insurance Policy Starts and End Validity Date equal to High Date (31-DEC-9999).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 18-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_Current_DTTM      DATETIME2= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10),
          @Lc_Space_TEXT        CHAR(1)=' ',
          @Lc_No_INDC           CHAR(1)='N';

  UPDATE MINS_Y1
     SET EndValidity_DATE = @Ld_Current_DTTM
  OUTPUT @An_MemberMci_IDNO,
         @An_OthpInsurance_IDNO,
         @Ac_InsuranceGroupNoNew_TEXT,
         @Ac_PolicyInsNoNew_TEXT,
         @Ad_Begin_DATE,
         @Ad_End_DATE,
         @Lc_Space_TEXT AS InsSource_CODE,
         @Ac_Status_CODE,
         @Ad_Status_DATE,
         @Ac_SourceVerified_CODE,
         @Ac_PolicyHolderRelationship_CODE,
         @Lc_Space_TEXT AS TypePolicy_CODE,
         @Ac_EmployerPaid_INDC,
         @Lc_Space_TEXT AS DescriptionCoverage_TEXT,
         @An_MonthlyPremium_AMNT,
         @Lc_Space_TEXT AS Contact_NAME,
         @Lc_No_INDC AS SpecialNeeds_INDC,
         @Lc_No_INDC AS OtherIns_INDC,
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
         @Ld_Current_DTTM AS BeginValidity_DATE,
         @Ld_High_DATE AS EndValidity_DATE,
         @Ac_SignedOnWorker_ID,
         @Ld_Current_DTTM AS Update_DTTM,
         @An_TransactionEventSeqNew_NUMB,
         @Ac_PolicyAnnivMonth_CODE
  INTO MINS_Y1
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND InsuranceGroupNo_TEXT = @Ac_InsuranceGroupNo_TEXT
     AND PolicyInsNo_TEXT = @Ac_PolicyInsNo_TEXT
     AND Begin_DATE = @Ad_Begin_DATE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END -- End of MINS_UPDATE_S1

GO
