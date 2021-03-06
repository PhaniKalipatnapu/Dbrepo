/****** Object:  View [dbo].[UCMEM_V1]    Script Date: 4/10/2015 3:12:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
    
CREATE VIEW [dbo].[UCMEM_V1] (    
   Case_IDNO,     
   MemberMci_IDNO,     
   CaseRelationship_CODE,     
   CaseMemberStatus_CODE,     
   CpRelationshipToChild_CODE,     
   NcpRelationshipToChild_CODE,     
   BenchWarrant_INDC,  
   Applicant_CODE,     
   BeginValidity_DATE,     
   EndValidity_DATE,     
   WorkerUpdate_ID,     
   TransactionEventSeq_NUMB,     
   Update_DTTM)    
AS     
       
   SELECT     
      CaseMembers_T1.Case_IDNO,     
      CaseMembers_T1.MemberMci_IDNO,     
      CaseMembers_T1.CaseRelationship_CODE,     
      CaseMembers_T1.CaseMemberStatus_CODE,     
      CaseMembers_T1.CpRelationshipToChild_CODE,     
      CaseMembers_T1.NcpRelationshipToChild_CODE,     
      CaseMembers_T1.BenchWarrant_INDC,     
      CaseMembers_T1.Applicant_CODE,  
      CaseMembers_T1.BeginValidity_DATE,     
      '31-DEC-9999' AS EndValidity_DATE,     
      CaseMembers_T1.WorkerUpdate_ID,     
      CaseMembers_T1.TransactionEventSeq_NUMB ,     
      CaseMembers_T1.Update_DTTM    
   FROM dbo.CaseMembers_T1    
    UNION ALL    
   SELECT     
      CaseMembersHist_T1.Case_IDNO,     
      CaseMembersHist_T1.MemberMci_IDNO,     
      CaseMembersHist_T1.CaseRelationship_CODE,     
      CaseMembersHist_T1.CaseMemberStatus_CODE,     
      CaseMembersHist_T1.CpRelationshipToChild_CODE,     
      CaseMembersHist_T1.NcpRelationshipToChild_CODE,     
      CaseMembersHist_T1.BenchWarrant_INDC,  
      CaseMembersHist_T1.Applicant_CODE,          
      CaseMembersHist_T1.BeginValidity_DATE,     
      CaseMembersHist_T1.EndValidity_DATE,     
      CaseMembersHist_T1.WorkerUpdate_ID,     
      CaseMembersHist_T1.TransactionEventSeq_NUMB,     
      CaseMembersHist_T1.Update_DTTM    
   FROM dbo.CaseMembersHist_T1    
    
GO
