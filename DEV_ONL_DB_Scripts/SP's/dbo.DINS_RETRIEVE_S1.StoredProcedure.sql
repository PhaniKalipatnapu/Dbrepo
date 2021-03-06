/****** Object:  StoredProcedure [dbo].[DINS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_RETRIEVE_S1](
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @An_OthpInsurance_IDNO    NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT CHAR(25),
 @Ac_PolicyInsNo_TEXT      CHAR(20)
 )
AS
 /*
  *     PROCEDURE NAME    : DINS_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Unique ID Assigned to the Member and Unique ID generated for the Case from Case Members table, retrieve County Name by deriving it from last name, first name and middle initial of the Member, Members social security number, Members date of birth from Member Demographics table and retrieve Indicators such as Participant is eligible for Dental Insurance, Participant is eligible for Medical Insurance, Participant is eligible for Vision Insurance, Participant is eligible for Mental Insurance and Participant is eligible for Prescription Drugs, etD., from Dependant Insurance table for Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant and for Unique number assigned by the system to the participant whose Dependent Member (for whom the insurance is provided) exists in Member Demographics table and exists in Case Members table as an Active Member for the Open (O) Case in Case Details table for the given Member in Case Members table who is an Active Non-Custodial Parent (A) / Custodial Parent (C).
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

  SELECT DISTINCT DN.Begin_DATE,
         DN.TransactionEventSeq_NUMB,
         DN.End_DATE,
         DN.Status_DATE,
         DN.MedicalIns_INDC,
         DN.DentalIns_INDC,
         DN.VisionIns_INDC,
         DN.PrescptIns_INDC,
         DN.MentalIns_INDC,
         DN.DescriptionOthers_TEXT,
         DN.Status_CODE,
         DN.WorkerUpdate_ID,
         CM.Case_IDNO,
         CM.MemberMci_IDNO,
         D.Last_NAME,
         D.First_NAME,
         D.Middle_NAME,
         D.MemberSsn_NUMB,
         D.Birth_DATE
    FROM DINS_Y1 DN
         JOIN CMEM_Y1 CM
          ON DN.ChildMCI_IDNO = CM.MemberMci_IDNO
         JOIN DEMO_Y1 D
          ON D.MemberMci_IDNO = CM.MemberMci_IDNO
   WHERE DN.MemberMci_IDNO = @An_MemberMci_IDNO
     AND CM.Case_IDNO IN (SELECT x.Case_IDNO
                            FROM CMEM_Y1 x
                                 JOIN CASE_Y1 v
                                  ON v.Case_IDNO = x.Case_IDNO
                           WHERE v.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                             AND x.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND x.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE)
                             AND x.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE)
     AND CM.CaseMemberStatus_CODE = @Lc_CaseMembeStatusActive_CODE
     AND DN.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND DN.EndValidity_DATE = @Ld_High_DATE
     AND ISNULL(DN.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)
     AND ISNULL(DN.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT);
 END -- End of DINS_RETRIEVE_S1

GO
