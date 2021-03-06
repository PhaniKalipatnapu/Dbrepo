/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S62]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S62](
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*                                                                                                                                                                                                                              
 *     PROCEDURE NAME     : DEMO_RETRIEVE_S62                                                                                                                                                                                     
  *     DESCRIPTION       : Retrieve Name of the Member from Member Demographics, Address details, Case Relation details and Date of Birth, Member SSN, Member Sex for the given Case ID and order by Member Case Relation.      
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                           
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                                                                          
  *     MODIFIED BY       :                                                                                                                                                                                                      
  *     MODIFIED ON       :                                                                                                                                                                                                      
  *     VERSION NO        : 1                                                                                                                                                                                                    
 */
 BEGIN
  DECLARE @Lc_AddrCity_CODE  CHAR(9) = 'City_ADDR',
          @Lc_AddrLine1_CODE CHAR(10) = 'Line1_ADDR',
          @Lc_AddrLine2_CODE CHAR(10) = 'Line2_ADDR',
          @Lc_AddrState_CODE CHAR(10) = 'State_ADDR',
          @Lc_AddrZip_CODE   CHAR(8) = 'Zip_ADDR';

  SELECT X.First_NAME,
         X.Middle_NAME,
         X.Last_NAME,
         X.Suffix_NAME,
         X.Line1_ADDR,
         X.Line2_ADDR,
         X.City_ADDR,
         X.State_ADDR,
         X.Zip_ADDR,
         X.CaseRelationship_CODE,
         X.CpRelationshipToChild_CODE,
         X.NcpRelationshipToChild_CODE,
         X.CaseMemberStatus_CODE,
         X.PaternityEst_CODE,
         X.FamilyViolence_INDC,
         X.MemberSsn_NUMB,
         X.Birth_DATE,
         X.MemberSex_CODE,
         X.Race_CODE,
         X.MemberMci_IDNO,
         X.TransactionEventSeqLockVcmem_NUMB,
         X.TransactionEventSeqLockVdemo_NUMB,
         X.Individual_IDNO,
         X.TypeFamilyViolence_CODE,
         X.FamilyViolence_DATE,
         X.ReasonMemberStatus_CODE
    FROM (SELECT D.First_NAME,
                 D.Middle_NAME,
                 D.Last_NAME,
                 D.Suffix_NAME,
                 dbo.BATCH_COMMON$SF_GET_AHIS_DTLS(@Lc_AddrLine1_CODE, C.MemberMci_IDNO) AS Line1_ADDR,
                 dbo.BATCH_COMMON$SF_GET_AHIS_DTLS(@Lc_AddrLine2_CODE, C.MemberMci_IDNO) AS Line2_ADDR,
                 dbo.BATCH_COMMON$SF_GET_AHIS_DTLS(@Lc_AddrCity_CODE, C.MemberMci_IDNO) AS City_ADDR,
                 dbo.BATCH_COMMON$SF_GET_AHIS_DTLS(@Lc_AddrState_CODE, C.MemberMci_IDNO) AS State_ADDR,
                 dbo.BATCH_COMMON$SF_GET_AHIS_DTLS(@Lc_AddrZip_CODE, C.MemberMci_IDNO) AS Zip_ADDR,
                 C.CaseRelationship_CODE,
                 C.CpRelationshipToChild_CODE,
                 C.NcpRelationshipToChild_CODE,
                 C.CaseMemberStatus_CODE,
                 M.PaternityEst_CODE,
                 C.FamilyViolence_INDC,
                 d.MemberSsn_NUMB,
                 d.Birth_DATE,
                 d.MemberSex_CODE,
                 d.Race_CODE,
                 C.MemberMci_IDNO,
                 C.TransactionEventSeq_NUMB AS TransactionEventSeqLockVcmem_NUMB,
                 D.TransactionEventSeq_NUMB AS TransactionEventSeqLockVdemo_NUMB,
                 D.Individual_IDNO,
                 C.TypeFamilyViolence_CODE,
                 C.FamilyViolence_DATE,
                 C.ReasonMemberStatus_CODE
            FROM DEMO_Y1 D
                 LEFT OUTER JOIN MPAT_Y1 M
                  ON (M.MemberMci_IDNO = D.MemberMci_IDNO)
                 JOIN CMEM_Y1 C
                  ON (D.MemberMci_IDNO = C.MemberMci_IDNO)
                 JOIN CASE_Y1 C1
                  ON (C.Case_IDNO = C1.Case_IDNO)
           WHERE C1.Case_IDNO = @An_Case_IDNO) AS X
   ORDER BY X.CaseRelationship_CODE;
 END; --End of DEMO_RETRIEVE_S62

GO
