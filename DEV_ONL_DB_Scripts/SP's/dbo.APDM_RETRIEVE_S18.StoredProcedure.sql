/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S18](
 @An_Application_IDNO NUMERIC(15, 0)
 )
AS
 /*                                                                                                                                                                   
 *     PROCEDURE NAME    : APDM_RETRIEVE_S18                                                                                                                          
  *     DESCRIPTION       : Retrieve Member Demographics details at the time of Application received for an Application ID and Member Type is Dependent.                                                                                                                                   
  *     DEVELOPED BY      : IMP Team                                                                                                                                
  *     DEVELOPED ON      : 30-AUG-2011                                                                                                                               
  *     MODIFIED BY       :                                                                                                                                           
  *     MODIFIED ON       :                                                                                                                                           
  *     VERSION NO        : 1                                                                                                                                         
 */
 BEGIN
  DECLARE @Lc_RelationshipCaseDp_CODE CHAR(1) = 'D',
          @Ld_High_DATE               DATE = '12/31/9999';

  SELECT X.MemberMci_IDNO,
         X.Last_NAME,
         X.First_NAME,
         X.Middle_NAME,
         X.Suffix_NAME,
         X.PaternityEst_INDC,
         X.PaternityEst_CODE,
         X.PaternityEst_DATE,
         X.Birth_DATE,
         X.BirthCity_NAME,
         X.BirthState_CODE,
         X.MemberSsn_NUMB,
         X.Race_CODE,
         X.MemberSex_CODE,
         X.CpRelationshipToChild_CODE,
         X.NcpRelationshipToChild_CODE,
         X.ResideCounty_IDNO,
         X.TypeWelfare_CODE,
         X.FilePaternity_ID,
         X.CaseWelfare_IDNO,
         X.Begin_DATE,
         X.End_DATE,
         X.CreateMemberMci_CODE,
         X.TransactionEventSeqVapcm_NUMB,
         X.TransactionEventSeqVapdm_NUMB,
         X.TransactionEventSeqVapmh_NUMB,
         x.ConceptionCity_NAME,
         x.ConceptionState_CODE,
         X.EstablishedMother_CODE,
         X.EstablishedFather_CODE,
         x.FatherNameOnBirthCertificate_INDC,
         X.MothermarriedDuringChildBirth_INDC,
         X.HusbandIsNotFather_INDC,
         X.Divorce_INDC,
         X.Divorce_DATE,
         X.DivorceCounty_NAME,
         x.StateDivorce_CODE,
         X.PaternityEstablishedByOrder_INDC,
         X.TypeOrder_CODE,
         X.GeneticTesting_INDC,
         X.AdditionalNotes_TEXT,
         x.EstablishedMotherFirst_NAME,
         x.EstablishedMotherLast_NAME,
         x.EstablishedMotherMiddle_NAME,
         x.EstablishedMotherSuffix_NAME,
         x.EstablishedFatherFirst_NAME,
         x.EstablishedFatherLast_NAME,
         x.EstablishedFatherMiddle_NAME,
         x.EstablishedFatherSuffix_NAME,
         x.EstablishedMotherMci_IDNO,
         x.EstablishedFatherMci_IDNO,
         x.HusbandFirst_NAME,
         x.HusbandLast_NAME,
         x.HusbandMiddle_NAME,
         x.HusbandSuffix_NAME,
         x.MarriedDuringChildBirthHusband_NAME,
         x.MarriageDuringChildBirth_DATE,
         x.MarriageDuringChildBirthCounty_NAME,
         x.MarriageDuringChildBirthState_CODE,
         x.EstablishedParentsMarriage_DATE,
         x.EstablishedParentsMarriageCounty_NAME,
         x.EstablishedParentsMarriageState_CODE,
         x.ChildParentDivorce_DATE,
         X.ChildParentDivorceCounty_NAME,
         x.ChildParentDivorceState_CODE,
         x.IveParty_IDNO,
         X.BirthCountry_CODE,
         X.ApplicationStatus_CODE
    FROM (SELECT A.MemberMci_IDNO,
                 A.Last_NAME,
                 A.First_NAME,
                 A.Middle_NAME,
                 A.Suffix_NAME,
                 A.PaternityEst_INDC,
                 A.PaternityEst_CODE,
                 A.PaternityEst_DATE,
                 A.Birth_DATE,
                 A.BirthCity_NAME,
                 A.BirthState_CODE,
                 A.MemberSsn_NUMB,
                 A.Race_CODE,
                 A.MemberSex_CODE,
                 A1.CpRelationshipToChild_CODE,
                 A1.NcpRelationshipToChild_CODE,
                 A.ResideCounty_IDNO,
                 A2.TypeWelfare_CODE,
                 A.FilePaternity_ID,
                 A2.CaseWelfare_IDNO,
                 A2.Begin_DATE,
                 A2.End_DATE,
                 A1.CreateMemberMci_CODE,
                 A1.TransactionEventSeq_NUMB AS TransactionEventSeqVapcm_NUMB,
                 A.TransactionEventSeq_NUMB AS TransactionEventSeqVapdm_NUMB,
                 A2.TransactionEventSeq_NUMB AS TransactionEventSeqVapmh_NUMB,
                 A.ConceptionCity_NAME,
                 A.ConceptionState_CODE,
                 A.EstablishedMother_CODE,
                 A.EstablishedFather_CODE,
                 A.FatherNameOnBirthCertificate_INDC,
                 A.MothermarriedDuringChildBirth_INDC,
                 A.HusbandIsNotFather_INDC,
                 A.Divorce_INDC,
                 A.Divorce_DATE,
                 A.DivorceCounty_NAME,
                 A.StateDivorce_CODE,
                 A.PaternityEstablishedByOrder_INDC,
                 A.TypeOrder_CODE,
                 A.GeneticTesting_INDC,
                 A.AdditionalNotes_TEXT,
                 A.EstablishedMotherFirst_NAME,
                 A.EstablishedMotherLast_NAME,
                 A.EstablishedMotherMiddle_NAME,
                 A.EstablishedMotherSuffix_NAME,
                 A.EstablishedFatherFirst_NAME,
                 A.EstablishedFatherLast_NAME,
                 A.EstablishedFatherMiddle_NAME,
                 A.EstablishedFatherSuffix_NAME,
                 A.EstablishedMotherMci_IDNO,
                 A.EstablishedFatherMci_IDNO,
                 A.HusbandFirst_NAME,
                 A.HusbandLast_NAME,
                 A.HusbandMiddle_NAME,
                 A.HusbandSuffix_NAME,
                 A.MarriedDuringChildBirthHusband_NAME,
                 A.MarriageDuringChildBirth_DATE,
                 A.MarriageDuringChildBirthCounty_NAME,
                 A.MarriageDuringChildBirthState_CODE,
                 A.EstablishedParentsMarriage_DATE,
                 A.EstablishedParentsMarriageCounty_NAME,
                 A.EstablishedParentsMarriageState_CODE,
                 A.ChildParentDivorce_DATE,
                 A.ChildParentDivorceCounty_NAME,
                 A.ChildParentDivorceState_CODE,
                 A.IveParty_IDNO,
                 A.BirthCountry_CODE,
                 A3.ApplicationStatus_CODE
            FROM APDM_Y1 A
                 JOIN APCM_Y1 A1
                  ON (A.MemberMci_IDNO = A1.MemberMci_IDNO
                      AND A.Application_IDNO = A1.Application_IDNO)
                 JOIN APCS_Y1 A3
                  ON (A.Application_IDNO = A3.Application_IDNO)
                 LEFT OUTER JOIN APMH_Y1 A2
                  ON (A1.MemberMci_IDNO = A2.MemberMci_IDNO
                      AND A1.Application_IDNO = A2.Application_IDNO
                      AND A2.EndValidity_DATE = @Ld_High_DATE)
           WHERE A1.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
             AND A1.Application_IDNO = @An_Application_IDNO
             AND A1.EndValidity_DATE = @Ld_High_DATE
             AND A.EndValidity_DATE = @Ld_High_DATE
             AND A3.EndValidity_DATE = @Ld_High_DATE) AS X;
 END; -- End Of APDM_RETRIEVE_S18

GO
