/****** Object:  View [dbo].[UMHIS_V1]    Script Date: 4/10/2015 3:12:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE VIEW [dbo].[UMHIS_V1] (  
   Case_IDNO,   
   Start_DATE,   
   End_DATE,   
   TypeWelfare_CODE,   
   CaseWelfare_IDNO,   
   WelfareMemberMci_IDNO,   
   CaseHead_INDC,   
   Reason_CODE,   
   EventGlobalBegin_SEQ,   
   EventGlobalEnd_SEQ,   
   BeginValidity_DATE,   
   EndValidity_DATE)  
AS   
     
   SELECT   
      MemberWelfareDetails_T1.Case_IDNO,   
      MemberWelfareDetails_T1.Start_DATE,   
      MemberWelfareDetails_T1.End_DATE,   
      MemberWelfareDetails_T1.TypeWelfare_CODE,   
      MemberWelfareDetails_T1.CaseWelfare_IDNO,   
      MemberWelfareDetails_T1.WelfareMemberMci_IDNO,   
      MemberWelfareDetails_T1.CaseHead_INDC,   
      MemberWelfareDetails_T1.Reason_CODE,   
      MemberWelfareDetails_T1.EventGlobalBeginSeq_NUMB,   
      MemberWelfareDetails_T1.EventGlobalEndSeq_NUMB ,   
      MemberWelfareDetails_T1.BeginValidity_DATE,   
      '31-dec-9999'  AS EndValidity_DATE  
   FROM dbo.MemberWelfareDetails_T1  
    UNION ALL  
   SELECT   
      MemberWelfareDetailsHist_T1.Case_IDNO,   
      MemberWelfareDetailsHist_T1.Start_DATE AS Start_DATE,   
      MemberWelfareDetailsHist_T1.End_DATE AS End_DATE,   
      MemberWelfareDetailsHist_T1.TypeWelfare_CODE,   
      MemberWelfareDetailsHist_T1.CaseWelfare_IDNO,   
      MemberWelfareDetailsHist_T1.WelfareMemberMci_IDNO,   
      MemberWelfareDetailsHist_T1.CaseHead_INDC,   
      MemberWelfareDetailsHist_T1.Reason_CODE,   
      MemberWelfareDetailsHist_T1.EventGlobalBeginSeq_NUMB ,   
      MemberWelfareDetailsHist_T1.EventGlobalEndSeq_NUMB,   
      MemberWelfareDetailsHist_T1.BeginValidity_DATE,   
      MemberWelfareDetailsHist_T1.EndValidity_DATE  
   FROM dbo.MemberWelfareDetailsHist_T1  
  

GO
