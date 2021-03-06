/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S15](
 @An_Application_IDNO      NUMERIC(15, 0),
 @Ac_CaseRelationship_CODE CHAR(1)
 )
AS
 /*                                                                                                                                                           
  *     PROCEDURE NAME    : APDM_RETRIEVE_S15                                                                                                                  
  *     DESCRIPTION       : Retrieve Member Demographic details at the time of Application Received for an Application ID and Member ID.                                                                                                                                      
  *     DEVELOPED BY      : IMP Team                                                                                                                        
  *     DEVELOPED ON      : 11-AUG-2011                                                                                                                       
  *     MODIFIED BY       :                                                                                                                                   
  *     MODIFIED ON       :                                                                                                                                   
  *     VERSION NO        : 1                                                                                                                                 
 */
 BEGIN
  DECLARE @Lc_RelationshipCaseNcp_CODE CHAR(1) = 'A',
          @Lc_RelationshipCasePf_CODE  CHAR(1) = 'P',
          @Ld_High_DATE                DATE = '12/31/9999';

  SELECT A.Last_NAME,
         A.First_NAME,
         A.Middle_NAME,
         A.Suffix_NAME,
         A.MotherMaiden_NAME,
         A.MemberSsn_NUMB,
         A.Birth_DATE,
         A.MemberMci_IDNO,
         A.Deceased_DATE,
         A.BirthCity_NAME,
         A.BirthState_CODE,
         A1.FamilyViolence_INDC,
         A1.FamilyViolence_DATE,
         A.MemberSex_CODE,
         A.AlienRegistn_ID,
         A.Race_CODE,
         A.ColorHair_CODE,
         A.ColorEyes_CODE,
         SUBSTRING(A.DescriptionHeight_TEXT, 1, 1) DescriptionHeightFt_TEXT,
         SUBSTRING(A.DescriptionHeight_TEXT, 2, 2) DescriptionHeightIn_TEXT,
         A.TypeProblem_CODE,
         A.Language_CODE,
         A.Interpreter_INDC,
         A.HomePhone_NUMB,
         A.CellPhone_NUMB,
         A.Contact_EML,
         A.LicenseDriverNo_TEXT,
         A.LicenseIssueState_CODE,
         A.MilitaryBranch_CODE,
         A.SuffixAlias_NAME,
         A.FirstAlias_NAME,
         A.LastAlias_NAME,
         A.MiddleAlias_NAME,
         A.TransactionEventSeq_NUMB,
         A.MilitaryEnd_DATE,
         A.DescriptionWeightLbs_TEXT,
         A1.TypeFamilyViolence_CODE,
         A.CurrentMilitary_INDC,
         A.MilitaryStart_DATE,
         A.EverIncarcerated_INDC,
         A.IncarceratedFrom_DATE,
         A.IncarceratedTo_DATE,
         A.OtherIncome_INDC,
         A.OtherIncomeType_CODE,
         A.OtherIncome_AMNT,
         A.IncomeFrequency_CODE,
         A.NcpProvideChildInsurance_INDC,
         A.OthpInst_IDNO,
         A.IveParty_IDNO,
         A.DirectSupportPay_INDC,
         A.EverReceivedMedicaid_INDC,
         A.ChildCoveredInsurance_INDC,
         A2.ApplicationStatus_CODE
    FROM APDM_Y1 A
         JOIN APCM_Y1 A1
          ON (A.Application_IDNO = A1.Application_IDNO
              AND A.MemberMci_IDNO = A1.MemberMci_IDNO)
         JOIN APCS_Y1 A2
          ON (A.Application_IDNO = A2.Application_IDNO)
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND ((@Ac_CaseRelationship_CODE IS NOT NULL
           AND A1.CaseRelationship_CODE = @Ac_CaseRelationship_CODE)
           OR (@Ac_CaseRelationship_CODE IS NULL
               AND A1.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePf_CODE)))
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A1.EndValidity_DATE = @Ld_High_DATE
     AND A2.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of APDM_RETRIEVE_S15


GO
