/****** Object:  StoredProcedure [dbo].[DINS_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_RETRIEVE_S6](
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @An_OthpInsurance_IDNO    NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT CHAR(25),
 @Ac_PolicyInsNo_TEXT      CHAR(20),
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ai_Count_QNTY            INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DINS_RETRIEVE_S6
  *     DESCRIPTION       : Retrieve the Dependant Insurance Covered count of records from Dependant Insurance table for Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent), Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant and Dependent's ID for whom the insurance is provided exists in Case Members table for the Case with Case Relation equal to  Dependant (D) and Member ID NOT equal to Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 19-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseRelationshipDp_CODE CHAR(1) = 'D',
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Ld_High_DATE               DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DINS_Y1 DI
   WHERE DI.MemberMci_IDNO = @An_MemberMci_IDNO
     AND DI.ChildMCI_IDNO IN (SELECT c.MemberMci_IDNO
                                FROM CMEM_Y1 c
                               WHERE c.Case_IDNO = @An_Case_IDNO
                                 AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
                                 AND c.MemberMci_IDNO <> @An_MemberMci_IDNO)
     AND DI.InsuranceGroupNo_TEXT = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)
     AND DI.PolicyInsNo_TEXT = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT)
     AND DI.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND DI.EndValidity_DATE = @Ld_High_DATE;
 END -- End of DINS_RETRIEVE_S6

GO
