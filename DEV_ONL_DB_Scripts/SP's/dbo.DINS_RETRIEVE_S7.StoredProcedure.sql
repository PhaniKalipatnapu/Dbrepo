/****** Object:  StoredProcedure [dbo].[DINS_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_RETRIEVE_S7](
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @An_OthpInsurance_IDNO    NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT CHAR(25),
 @Ac_PolicyInsNo_TEXT      CHAR(20)
 )
AS
 /*  
  *     PROCEDURE NAME    : DINS_RETRIEVE_S7  
  *     DESCRIPTION       : Retrieve Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent), Dependent's ID for whom the insurance is provided, Date from the which the Insurance Policy Starts, Date at which the Insurance Policy Ends, Indicators such as Participant is eligible for Dental Insurance, Participant is eligible for Medical Insurance, Participant is eligible for Vision Insurance, Participant is eligible for Mental Insurance, Participant is eligible for Prescription Drugs, Description of the other Type of Coverage available for the Participant and Unique Sequence Number that will be generated for any given Transaction on the Table from Dependant Insurance table for Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant, End Validity Date equal to High Date (31-DEC-9999) and for the given Unique number assigned by the system to the participant ( This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent) whose Dependent Member (for whom the insurance is provided) exists in Member Demographics table and exists in Case Members table as an Active Member for the Open (O) Case in Case Details table for the given Member in Case Members table who is an Active Non-Custodial Parent (A) / Custodial Parent (C).
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 12-OCT-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE        CHAR(1) = 'O',
          @Lc_CaseRelationshipCp_CODE    CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE   CHAR(1) = 'A',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_CaseMembeStatusActive_CODE CHAR(1) = 'A',
          @Ld_High_DATE                  DATE = '12/31/9999';

  SELECT DISTINCT DI.MemberMci_IDNO,
         DI.ChildMCI_IDNO,
         DI.Begin_DATE,
         DI.End_DATE,
         DI.DentalIns_INDC,
         DI.MedicalIns_INDC,
         DI.VisionIns_INDC,
         DI.MentalIns_INDC,
         DI.PrescptIns_INDC,
         DI.DescriptionOthers_TEXT,
         DI.TransactionEventSeq_NUMB
    FROM DINS_Y1 DI
         JOIN CMEM_Y1 CM
          ON CM.MemberMci_IDNO = DI.ChildMCI_IDNO
         JOIN DEMO_Y1 D
          ON D.MemberMci_IDNO = CM.MemberMci_IDNO
   WHERE DI.MemberMci_IDNO = @An_MemberMci_IDNO
     AND CM.Case_IDNO IN (SELECT x.Case_IDNO
                            FROM CMEM_Y1 x
                                 JOIN CASE_Y1 v
                                  ON v.Case_IDNO = x.Case_IDNO
                           WHERE v.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                             AND x.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND x.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE)
                             AND x.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE)
     AND CM.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE
     AND DI.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND DI.EndValidity_DATE = @Ld_High_DATE
     AND ISNULL(DI.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)
     AND ISNULL(DI.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT)
     AND CM.MemberMci_IDNO != @An_MemberMci_IDNO;
 END -- End of DINS_RETRIEVE_S7

GO
