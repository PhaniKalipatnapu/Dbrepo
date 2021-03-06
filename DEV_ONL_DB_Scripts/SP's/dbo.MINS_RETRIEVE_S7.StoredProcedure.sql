/****** Object:  StoredProcedure [dbo].[MINS_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MINS_RETRIEVE_S7](
 @An_OthpInsurance_IDNO       NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT    CHAR(25),
 @Ac_PolicyInsNo_TEXT         CHAR(20),
 @Ad_Begin_DATE               DATE,
 @Ac_Status_CODE              CHAR(2),
 @An_ChildMCI_IDNO            NUMERIC(10, 0),
 @Ad_End_DATE                 DATE OUTPUT,
 @Ad_Status_DATE              DATE OUTPUT,
 @Ac_SourceVerified_CODE      CHAR(3) OUTPUT,
 @An_MonthlyPremium_AMNT      NUMERIC(11, 2) OUTPUT,
 @As_DescriptionOtherIns_TEXT VARCHAR(50) OUTPUT,
 @Ac_MedicalIns_INDC          CHAR(1) OUTPUT,
 @An_CoPay_AMNT               NUMERIC(11, 2) OUTPUT,
 @Ac_DentalIns_INDC           CHAR(1) OUTPUT,
 @Ac_VisionIns_INDC           CHAR(1) OUTPUT,
 @Ac_PrescptIns_INDC          CHAR(1) OUTPUT,
 @Ac_MentalIns_INDC           CHAR(1) OUTPUT,
 @An_OthpEmployer_IDNO        NUMERIC(9, 0) OUTPUT,
 @Ac_NonQualified_CODE        CHAR(1) OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @Ac_PolicyAnnivMonth_CODE    CHAR(2) OUTPUT,
 @Ad_BeginIns_DATE            DATE OUTPUT,
 @Ad_EndIns_DATE              DATE OUTPUT,
 @Ac_StatusOut_CODE			  CHAR(2) OUTPUT,
 @Ac_MedicalInsDep_INDC       CHAR(1) OUTPUT,
 @Ac_DentalInsDep_INDC        CHAR(1) OUTPUT,
 @Ac_VisionInsDep_INDC        CHAR(1) OUTPUT,
 @Ac_PrescptInsDep_INDC       CHAR(1) OUTPUT,
 @Ac_MentalInsDep_INDC        CHAR(1) OUTPUT,
 @As_DescriptionOthers_TEXT   VARCHAR(50) OUTPUT,
 @As_OtherParty_NAME          VARCHAR(60) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MINS_RETRIEVE_S7
  *     DESCRIPTION       : Retrieve Employer ID by deriving it from Employer ID of Member Insurance table and Name of the Other Party from Other Party table whose Unique System Assigned number for the Other Party equal to the Employer ID of Member Insurance table, Date at which the Insurance Policy Ends, Amount Paid Monthly towards the Insurance Premium, Code of the Source Verified, Non-Qualified Insurance of the Member, Date on which the Policy was Verified,  Code of the Verification Status, Co-Pay Amount paid towards Insurance, the month when the policy has to be renewed and Indicators such as Participant is eligible for Dental Insurance, Participant is eligible for Medical Insurance, Participant is eligible for Vision Insurance, Participant is eligible for Mental Insurance, Participant is eligible for Prescription Drugs and Description of the Other Insurance Information from Member Insurance table and retrieve Date from the which the Insurance Policy Starts, Date at which the Insurance Policy Ends, Indicators such as Participant is eligible for Dental Insurance, Participant is eligible for Medical Insurance, Participant is eligible for Vision Insurance, Participant is eligible for Mental Insurance, Participant is eligible for Prescription Drugs and Description of the Other Insurance Information for the Dependent Member (for whom the insurance is provided) from Dependant Insurance table for the Date from the which the Insurance Policy Starts with Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent), Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance and Policy Number of the Participant existing in Member Insurance table for the given Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant and Code of the Verification Status. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 19-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ad_End_DATE = NULL,
         @Ad_Status_DATE = NULL,
         @Ac_SourceVerified_CODE = NULL,
         @An_MonthlyPremium_AMNT = NULL,
         @As_DescriptionOtherIns_TEXT = NULL,
         @Ac_MedicalIns_INDC = NULL,
         @An_CoPay_AMNT = NULL,
         @Ac_DentalIns_INDC = NULL,
         @Ac_VisionIns_INDC = NULL,
         @Ac_PrescptIns_INDC = NULL,
         @Ac_MentalIns_INDC = NULL,
         @An_OthpEmployer_IDNO = NULL,
         @Ac_NonQualified_CODE = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ac_PolicyAnnivMonth_CODE = NULL,
         @Ad_BeginIns_DATE = NULL,
         @Ad_EndIns_DATE = NULL,
         @Ac_StatusOut_CODE = NULL,
         @Ac_MedicalInsDep_INDC = NULL,
         @Ac_DentalInsDep_INDC = NULL,
         @Ac_VisionInsDep_INDC = NULL,
         @Ac_PrescptInsDep_INDC = NULL,
        @Ac_MentalInsDep_INDC = NULL,
         @As_DescriptionOthers_TEXT = NULL,
         @As_OtherParty_NAME = NULL;

  DECLARE @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE  DATE = '12/31/9999';

  SELECT @Ad_End_DATE = X.End_DATE,
         @Ad_Status_DATE = X.Status_DATE,
         @Ac_SourceVerified_CODE = X.SourceVerified_CODE,
         @An_MonthlyPremium_AMNT = X.MonthlyPremium_AMNT,
         @As_DescriptionOtherIns_TEXT = X.DescriptionOtherIns_TEXT,
         @Ac_MedicalIns_INDC = X.MedicalIns_INDC,
         @An_CoPay_AMNT = X.CoPay_AMNT,
         @Ac_DentalIns_INDC = X.DentalIns_INDC,
         @Ac_VisionIns_INDC = X.VisionIns_INDC,
         @Ac_PrescptIns_INDC = X.PrescptIns_INDC,
         @Ac_MentalIns_INDC = X.MentalIns_INDC,
         @An_OthpEmployer_IDNO = X.OthpEmployer_IDNO,
         @Ac_NonQualified_CODE = X.NonQualified_CODE,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID,
         @Ac_PolicyAnnivMonth_CODE = X.PolicyAnnivMonth_CODE,
         @Ad_BeginIns_DATE = X.InsBegin_DATE,
         @Ad_EndIns_DATE = X.InsEnd_DATE,
         @Ac_StatusOut_CODE = X.VerificationStatus_CODE,
         @Ac_MedicalInsDep_INDC = X.DepMedicalIns_INDC,
         @Ac_DentalInsDep_INDC = X.DepDentalIns_INDC,
         @Ac_PrescptInsDep_INDC = X.DepPrescptIns_INDC,
         @Ac_VisionInsDep_INDC = X.DepVisionIns_INDC,
        @Ac_MentalInsDep_INDC = X.DepMentalIns_INDC,
         @As_DescriptionOthers_TEXT = X.DescriptionOthers_TEXT,
         @As_OtherParty_NAME = X.OtherParty_NAME
    FROM (SELECT MI.OthpEmployer_IDNO,
                 (SELECT o.OtherParty_NAME
                    FROM OTHP_Y1 o
                   WHERE o.OtherParty_IDNO = MI.OthpEmployer_IDNO
                     AND o.EndValidity_DATE = @Ld_High_DATE) AS OtherParty_NAME,
                 MI.End_DATE,
                 MI.MonthlyPremium_AMNT,
                 MI.SourceVerified_CODE,
                 MI.NonQualified_CODE,
                 MI.Status_DATE,
                 MI.Status_CODE AS VerificationStatus_CODE,
                 MI.WorkerUpdate_ID,
                 MI.CoPay_AMNT,
                 MI.PolicyAnnivMonth_CODE,
                 MI.DentalIns_INDC,
                 MI.MedicalIns_INDC,
                 MI.VisionIns_INDC,
                 MI.MentalIns_INDC,
                 MI.PrescptIns_INDC,
                 MI.DescriptionOtherIns_TEXT,
                 DI.Begin_DATE AS InsBegin_DATE,
                 DI.End_DATE AS InsEnd_DATE,
                 DI.DentalIns_INDC AS DepDentalIns_INDC,
                 DI.MedicalIns_INDC AS DepMedicalIns_INDC,
                 DI.VisionIns_INDC AS DepVisionIns_INDC,
                 DI.MentalIns_INDC AS DepMentalIns_INDC,
                 DI.PrescptIns_INDC AS DepPrescptIns_INDC,
                 DI.DescriptionOthers_TEXT
            FROM MINS_Y1 MI
                 JOIN DINS_Y1 DI
                  ON MI.MemberMci_IDNO = DI.MemberMci_IDNO
                     AND MI.OthpInsurance_IDNO = DI.OthpInsurance_IDNO
                     AND MI.InsuranceGroupNo_TEXT = DI.InsuranceGroupNo_TEXT
                     AND MI.PolicyInsNo_TEXT = DI.PolicyInsNo_TEXT
                     AND MI.EndValidity_DATE = DI.EndValidity_DATE
           WHERE DI.ChildMCI_IDNO = @An_ChildMCI_IDNO
             AND MI.Status_CODE = ISNULL(@Ac_Status_CODE, MI.Status_CODE)
             AND MI.EndValidity_DATE = @Ld_High_DATE
             AND MI.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
             AND ISNULL(MI.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)
             AND ISNULL(MI.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT)
             AND DI.Begin_DATE = @Ad_Begin_DATE) AS X;
 END -- End of MINS_RETRIEVE_S7

GO
