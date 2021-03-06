/****** Object:  StoredProcedure [dbo].[MINS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MINS_RETRIEVE_S2](
 @An_MemberMci_IDNO                NUMERIC(10, 0),
 @An_OthpEmployer_IDNO             NUMERIC(9, 0),
 @Ac_Status_CODE                   CHAR(2),
 @Ai_Row_NUMB                  INT,
 @An_OthpInsurance_IDNO            NUMERIC(9, 0) OUTPUT,
 @Ac_InsuranceGroupNo_TEXT         CHAR(25) OUTPUT,
 @Ac_PolicyInsNo_TEXT              CHAR(20) OUTPUT,
 @Ad_Begin_DATE                    DATE OUTPUT,
 @Ad_End_DATE                      DATE OUTPUT,
 @Ac_StatusOut_CODE                CHAR(2) OUTPUT,
 @Ad_Status_DATE                   DATE OUTPUT,
 @Ac_SourceVerified_CODE           CHAR(3) OUTPUT,
 @Ac_PolicyHolderRelationship_CODE CHAR(2) OUTPUT,
 @An_MonthlyPremium_AMNT           NUMERIC(11, 2) OUTPUT,
 @As_DescriptionOtherIns_TEXT      VARCHAR(50) OUTPUT,
 @Ac_MedicalIns_INDC               CHAR(1) OUTPUT,
 @An_CoPay_AMNT                    NUMERIC(11, 2) OUTPUT,
 @Ac_DentalIns_INDC                CHAR(1) OUTPUT,
 @Ac_VisionIns_INDC                CHAR(1) OUTPUT,
 @Ac_PrescptIns_INDC               CHAR(1) OUTPUT,
 @Ac_MentalIns_INDC                CHAR(1) OUTPUT,
 @An_OthpEmployerOut_IDNO          NUMERIC(9, 0) OUTPUT,
 @Ac_NonQualified_CODE             CHAR(1) OUTPUT,
 @As_PolicyHolder_NAME             VARCHAR(62) OUTPUT,
 @An_PolicyHolderSsn_NUMB          NUMERIC(9, 0) OUTPUT,
 @Ad_BirthPolicyHolder_DATE        DATE OUTPUT,
 @Ad_BeginValidity_DATE            DATE OUTPUT,
 @Ad_EndValidity_DATE              DATE OUTPUT,
 @Ac_WorkerUpdate_ID               CHAR(30) OUTPUT,
 @An_TransactionEventSeq_NUMB      NUMERIC(19, 0) OUTPUT,
 @Ac_PolicyAnnivMonth_CODE         CHAR(2) OUTPUT,
 @As_OtherParty_NAME               VARCHAR(60) OUTPUT,
 @Ac_Last_NAME                     CHAR(20) OUTPUT,
 @Ac_First_NAME                    CHAR(16) OUTPUT,
 @Ac_Middle_NAME                   CHAR(20) OUTPUT,
 @Ac_Suffix_NAME                   CHAR(4) OUTPUT,
 @An_MemberSsn_NUMB                NUMERIC(9, 0) OUTPUT,
 @Ad_Birth_DATE                    DATE OUTPUT,
 @An_RowCount_NUMB                 NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MINS_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Relation to the Policy holder, Group number of the Participant Insurance, Policy Number of the Participant, Code of the Source Verified, Non-Qualified Insurance of the Member, Code of the Verification Status, Co-Pay Amount paid towards Insurance, month when the policy has to be renewed and Indicators such as Participant is eligible for Dental Insurance, Participant is eligible for Medical Insurance, Participant is eligible for Vision Insurance, Participant is eligible for Mental Insurance, Participant is eligible for Prescription Drugs and Description of the Other Insurance Information from Member Insurance table for Unique number assigned by the system to the participant that exists in Member Demographics table, Employer ID, Code of the Verification Status with End Validity Date equal to High Date (31-DEC-9999).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_OthpInsurance_IDNO = NULL,
         @Ac_InsuranceGroupNo_TEXT = NULL,
         @Ac_PolicyInsNo_TEXT = NULL,
         @Ad_Begin_DATE = NULL,
         @Ad_End_DATE = NULL,
         @Ac_StatusOut_CODE = NULL,
         @Ad_Status_DATE = NULL,
         @Ac_SourceVerified_CODE = NULL,
         @Ac_PolicyHolderRelationship_CODE = NULL,
         @An_MonthlyPremium_AMNT = NULL,
         @As_DescriptionOtherIns_TEXT = NULL,
         @Ac_MedicalIns_INDC = NULL,
         @An_CoPay_AMNT = NULL,
         @Ac_DentalIns_INDC = NULL,
         @Ac_VisionIns_INDC = NULL,
         @Ac_PrescptIns_INDC = NULL,
         @Ac_MentalIns_INDC = NULL,
         @An_OthpEmployerOut_IDNO = NULL,
         @Ac_NonQualified_CODE = NULL,
         @As_PolicyHolder_NAME = NULL,
         @An_PolicyHolderSsn_NUMB = NULL,
         @Ad_BirthPolicyHolder_DATE = NULL,
         @Ad_BeginValidity_DATE = NULL,
         @Ad_EndValidity_DATE = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @Ac_PolicyAnnivMonth_CODE = NULL,
         @As_OtherParty_NAME = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @An_MemberSsn_NUMB = NULL,
         @Ad_Birth_DATE = NULL,
         @An_RowCount_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_OthpInsurance_IDNO = X.OthpInsurance_IDNO,
         @Ac_InsuranceGroupNo_TEXT = X.InsuranceGroupNo_TEXT,
         @Ac_PolicyInsNo_TEXT = X.PolicyInsNo_TEXT,
         @Ad_Begin_DATE = X.Begin_DATE,
         @Ad_End_DATE = X.End_DATE,
         @Ac_StatusOut_CODE = X.Status_CODE,
         @Ad_Status_DATE = X.Status_DATE,
         @Ac_SourceVerified_CODE = X.SourceVerified_CODE,
         @Ac_PolicyHolderRelationship_CODE = X.PolicyHolderRelationship_CODE,
         @An_MonthlyPremium_AMNT = X.MonthlyPremium_AMNT,
         @As_DescriptionOtherIns_TEXT = X.DescriptionOtherIns_TEXT,
         @Ac_MedicalIns_INDC = X.MedicalIns_INDC,
         @An_CoPay_AMNT = X.CoPay_AMNT,
         @Ac_DentalIns_INDC = X.DentalIns_INDC,
         @Ac_VisionIns_INDC = X.VisionIns_INDC,
         @Ac_PrescptIns_INDC = X.PrescptIns_INDC,
         @Ac_MentalIns_INDC = X.MentalIns_INDC,
         @An_OthpEmployerOut_IDNO = X.OthpEmployer_IDNO,
         @Ac_NonQualified_CODE = X.NonQualified_CODE,
         @As_PolicyHolder_NAME = X.PolicyHolder_NAME,
         @An_PolicyHolderSsn_NUMB = X.PolicyHolderSsn_NUMB,
         @Ad_BirthPolicyHolder_DATE = X.BirthPolicyHolder_DATE,
         @Ad_BeginValidity_DATE = X.BeginValidity_DATE,
         @Ad_EndValidity_DATE = X.EndValidity_DATE,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID,
         @An_TransactionEventSeq_NUMB = X.TransactionEventSeq_NUMB,
         @Ac_PolicyAnnivMonth_CODE = X.PolicyAnnivMonth_CODE,
         @As_OtherParty_NAME = X.OtherParty_NAME,
         @Ac_Last_NAME = X.Last_NAME,
         @Ac_Suffix_NAME = X.Suffix_NAME,
         @Ac_First_NAME = X.First_NAME,
         @Ac_Middle_NAME = X.Middle_NAME,
         @An_MemberSsn_NUMB = X.MemberSsn_NUMB,
         @Ad_Birth_DATE = X.Birth_DATE,
         @An_RowCount_NUMB = X.row_count
    FROM (SELECT MI.PolicyHolderRelationship_CODE,
                 MI.PolicyHolder_NAME,
                 D.Last_NAME,
                 D.Suffix_NAME,
                 D.First_NAME,
                 D.Middle_NAME,
                 MI.PolicyHolderSsn_NUMB,
                 D.MemberSsn_NUMB,
                 MI.BirthPolicyHolder_DATE,
                 D.Birth_DATE,
                 MI.OthpInsurance_IDNO,
                 MI.OthpEmployer_IDNO,
                 (SELECT OTH.OtherParty_NAME
                    FROM OTHP_Y1 OTH
                   WHERE OTH.OtherParty_IDNO = MI.OthpEmployer_IDNO
                     AND OTH.EndValidity_DATE = @Ld_High_DATE)AS OtherParty_NAME,
                 MI.InsuranceGroupNo_TEXT,
                 MI.Begin_DATE,
                 MI.WorkerUpdate_ID,
                 MI.PolicyInsNo_TEXT,
                 MI.End_DATE,
                 MI.MonthlyPremium_AMNT,
                 MI.NonQualified_CODE,
                 MI.Status_DATE,
                 MI.Status_CODE,
                 MI.SourceVerified_CODE,
                 MI.CoPay_AMNT,
                 MI.PolicyAnnivMonth_CODE,
                 MI.DentalIns_INDC,
                 MI.MedicalIns_INDC,
                 MI.VisionIns_INDC,
                 MI.MentalIns_INDC,
                 MI.PrescptIns_INDC,
                 MI.DescriptionOtherIns_TEXT,
                 MI.EndValidity_DATE,
                 MI.BeginValidity_DATE,
                 MI.TransactionEventSeq_NUMB,
                 ROW_NUMBER() OVER( ORDER BY Begin_DATE DESC) AS RecRank_NUMB,
                 COUNT(1) OVER() AS row_count,
                 ROW_NUMBER() OVER( ORDER BY MI.Begin_DATE DESC) AS ORD_ROWNUM
            FROM MINS_Y1 MI
                 JOIN DEMO_Y1 D
                  ON MI.MemberMci_IDNO = D.MemberMci_IDNO
           WHERE MI.MemberMci_IDNO = @An_MemberMci_IDNO
             AND MI.OthpEmployer_IDNO = ISNULL(@An_OthpEmployer_IDNO, MI.OthpEmployer_IDNO)
             AND MI.EndValidity_DATE = @Ld_High_DATE
             AND MI.Status_CODE = ISNULL(@Ac_Status_CODE, MI.Status_CODE)) AS X
   WHERE X.RecRank_NUMB = @Ai_Row_NUMB;
 END -- End of MINS_RETRIEVE_S2 

GO
