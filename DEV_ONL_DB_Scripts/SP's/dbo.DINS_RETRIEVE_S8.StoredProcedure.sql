/****** Object:  StoredProcedure [dbo].[DINS_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_RETRIEVE_S8](
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_OthpInsurance_IDNO       NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT    CHAR(25),
 @Ac_PolicyInsNo_TEXT         CHAR(20),
 @An_ChildMCI_IDNO            NUMERIC(10, 0),
 @Ad_Begin_DATE               DATE,
 @Ad_End_DATE                 DATE OUTPUT,
 @Ac_MedicalIns_INDC          CHAR(1) OUTPUT,
 @Ac_DentalIns_INDC           CHAR(1) OUTPUT,
 @Ac_VisionIns_INDC           CHAR(1) OUTPUT,
 @Ac_PrescptIns_INDC          CHAR(1) OUTPUT,
 @Ac_MentalIns_INDC           CHAR(1) OUTPUT,
 @As_DescriptionOthers_TEXT   VARCHAR(50) OUTPUT,
 @Ac_Status_CODE              CHAR(2) OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DINS_RETRIEVE_S8
  *     DESCRIPTION       : Retrieve Indicators such as Participant is eligible for Dental Insurance, Participant is eligible for Medical Insurance, Participant is eligible for Vision Insurance, Participant is eligible for Mental Insurance, Participant is eligible for Prescription Drugs, Description of the other Type of Coverage available for the Participant, Date from the which the Insurance Policy Starts, Date at which the Insurance Policy Ends, Verified status code and Unique Sequence Number that will be generated for any given Transaction on the Table from Dependant Insurance table for Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent), Dependent's ID for whom the insurance is provided, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant and Date from the which the Insurance Policy Starts with End Validity Date equal to High Date (31-DEC-9999). 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ac_DentalIns_INDC = NULL,
         @Ac_MedicalIns_INDC = NULL,
         @Ac_MentalIns_INDC = NULL,
         @Ac_PrescptIns_INDC = NULL,
         @Ac_VisionIns_INDC = NULL,
         @Ad_End_DATE = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @As_DescriptionOthers_TEXT = NULL,
         @Ac_Status_CODE = NULL;

  DECLARE @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE  DATE = '12/31/9999';

  SELECT TOP 1 @Ad_End_DATE = DI.End_DATE,
               @Ac_DentalIns_INDC = DI.DentalIns_INDC,
               @Ac_MedicalIns_INDC = DI.MedicalIns_INDC,
               @Ac_VisionIns_INDC = DI.VisionIns_INDC,
               @Ac_MentalIns_INDC = DI.MentalIns_INDC,
               @Ac_PrescptIns_INDC = DI.PrescptIns_INDC,
               @As_DescriptionOthers_TEXT = DI.DescriptionOthers_TEXT,
               @Ac_Status_CODE = DI.Status_CODE,
               @An_TransactionEventSeq_NUMB = DI.TransactionEventSeq_NUMB
    FROM DINS_Y1 DI
   WHERE DI.MemberMci_IDNO = @An_MemberMci_IDNO
     AND DI.ChildMCI_IDNO = @An_ChildMCI_IDNO
     AND DI.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND ISNULL(DI.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)
     AND ISNULL(DI.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT)
     AND DI.Begin_DATE = ISNULL(@Ad_Begin_DATE, DI.Begin_DATE)
     AND DI.EndValidity_DATE = @Ld_High_DATE;
 END -- End of DINS_RETRIEVE_S8

GO
