/****** Object:  StoredProcedure [dbo].[MINS_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MINS_RETRIEVE_S11] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_OthpInsurance_IDNO       NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT    CHAR(25),
 @Ac_PolicyInsNo_TEXT         CHAR(20),
 @Ad_Begin_DATE               DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ad_End_DATE                 DATE OUTPUT,
 @Ac_Status_CODE              CHAR(2) OUTPUT,
 @As_DescriptionOtherIns_TEXT VARCHAR(50) OUTPUT,
 @Ac_MedicalIns_INDC          CHAR(1) OUTPUT,
 @Ac_DentalIns_INDC           CHAR(1) OUTPUT,
 @Ac_VisionIns_INDC           CHAR(1) OUTPUT,
 @Ac_PrescptIns_INDC          CHAR(1) OUTPUT,
 @Ac_MentalIns_INDC           CHAR(1) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : MINS_RETRIEVE_S11    
  *     DESCRIPTION       : Retrieve Indicators such as Participant is eligible for Dental Insurance, Participant is eligible for Medical Insurance, Participant is eligible for Vision Insurance, Participant is eligible for Mental Insurance, Participant is eligible for Prescription Drugs, Description of the Other Insurance Information, Code of the Verification Status and Unique Sequence Number that will be generated for any given Transaction on the Table from Member Insurance table for Unique number assigned by the system to the participant, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant and Date from which the Insurance Policy Starts with End Validity Date equal to High Date (31-DEC-9999).
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 13-OCT-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SELECT @An_TransactionEventSeq_NUMB = NULL,
         @Ad_End_DATE = NULL,
         @Ac_Status_CODE = NULL,
         @As_DescriptionOtherIns_TEXT = NULL,
         @Ac_MedicalIns_INDC = NULL,
         @Ac_DentalIns_INDC = NULL,
         @Ac_VisionIns_INDC = NULL,
         @Ac_PrescptIns_INDC = NULL,
         @Ac_MentalIns_INDC = NULL;

  DECLARE @Lc_Space_TEXT CHAR(1)= ' ',
          @Ld_High_DATE  DATE = '12/31/9999';

  SELECT TOP 1 @An_TransactionEventSeq_NUMB = MI.TransactionEventSeq_NUMB,
               @Ad_End_DATE = MI.End_DATE,
               @Ac_Status_CODE = MI.Status_CODE,
               @As_DescriptionOtherIns_TEXT = MI.DescriptionOtherIns_TEXT,
               @Ac_MedicalIns_INDC = MI.MedicalIns_INDC,
               @Ac_DentalIns_INDC = MI.DentalIns_INDC,
               @Ac_VisionIns_INDC = MI.VisionIns_INDC,
               @Ac_PrescptIns_INDC = MI.PrescptIns_INDC,
               @Ac_MentalIns_INDC = MI.MentalIns_INDC
    FROM MINS_Y1 MI
   WHERE MI.MemberMci_IDNO = @An_MemberMci_IDNO
     AND MI.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND ISNULL(MI.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)
     AND ISNULL(MI.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT)
     AND MI.Begin_DATE = @Ad_Begin_DATE
     AND MI.EndValidity_DATE = @Ld_High_DATE;
 END -- End of MINS_RETRIEVE_S11

GO
