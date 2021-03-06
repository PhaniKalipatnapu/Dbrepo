/****** Object:  View [dbo].[UEHIS_V1]    Script Date: 4/10/2015 3:12:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE VIEW [dbo].[UEHIS_V1] (  
   MemberMci_IDNO,   
   OthpPartyEmpl_IDNO,   
   BeginEmployment_DATE,   
   EndEmployment_DATE,   
   TypeIncome_CODE,   
   DescriptionOccupation_TEXT,   
   IncomeNet_AMNT,   
   IncomeGross_AMNT,   
   FreqIncome_CODE,   
   FreqPay_CODE,   
   SourceLoc_CODE,   
   SourceReceived_DATE,   
   Status_CODE,   
   Status_DATE,   
   SourceLocConf_CODE,   
   InsProvider_INDC,   
   CostInsurance_AMNT,   
   FreqInsurance_CODE,   
   DpCoverageAvlb_INDC,   
   EmployerPrime_INDC,   
   DpCovered_INDC,   
   EligCoverage_DATE,   
   InsReasonable_INDC,   
   LimitCcpa_INDC,   
   PlsLastSearch_DATE,   
   BeginValidity_DATE,   
   EndValidity_DATE,   
   WorkerUpdate_ID,   
   Update_DTTM,   
   TransactionEventSEQ_NUMB)  
AS   
     
    SELECT   
      EmploymentDetails_T1.MemberMci_IDNO,   
      EmploymentDetails_T1.OthpPartyEmpl_IDNO,   
      EmploymentDetails_T1.BeginEmployment_DATE,   
      EmploymentDetails_T1.EndEmployment_DATE,   
      EmploymentDetails_T1.TypeIncome_CODE,   
      EmploymentDetails_T1.DescriptionOccupation_TEXT,   
      EmploymentDetails_T1.IncomeNet_AMNT,   
      EmploymentDetails_T1.IncomeGross_AMNT,   
      EmploymentDetails_T1.FreqIncome_CODE,   
      EmploymentDetails_T1.FreqPay_CODE,   
      EmploymentDetails_T1.SourceLoc_CODE,   
      EmploymentDetails_T1.SourceReceived_DATE,   
      EmploymentDetails_T1.Status_CODE,   
      EmploymentDetails_T1.Status_DATE,   
      EmploymentDetails_T1.SourceLocConf_CODE,   
      EmploymentDetails_T1.InsProvider_INDC,   
      EmploymentDetails_T1.CostInsurance_AMNT,   
      EmploymentDetails_T1.FreqInsurance_CODE,   
      EmploymentDetails_T1.DpCoverageAvlb_INDC,   
      EmploymentDetails_T1.EmployerPrime_INDC,   
      EmploymentDetails_T1.DpCovered_INDC,   
      EmploymentDetails_T1.EligCoverage_DATE,   
      EmploymentDetails_T1.InsReasonable_INDC,   
      EmploymentDetails_T1.LimitCcpa_INDC,   
      EmploymentDetails_T1.PlsLastSearch_DATE,   
      EmploymentDetails_T1.BeginValidity_DATE,   
      '31-DEC-9999' AS EndValidity_DATE,   
      EmploymentDetails_T1.WorkerUpdate_ID,   
      EmploymentDetails_T1.Update_DTTM,   
      EmploymentDetails_T1.TransactionEventSeq_NUMB   
   FROM dbo.EmploymentDetails_T1  
    UNION ALL  
   SELECT   
      EmploymentDetailsHist_T1.MemberMci_IDNO,   
      EmploymentDetailsHist_T1.OthpPartyEmpl_IDNO,   
      EmploymentDetailsHist_T1.BeginEmployment_DATE,   
      EmploymentDetailsHist_T1.EndEmployment_DATE,   
      EmploymentDetailsHist_T1.TypeIncome_CODE,   
      EmploymentDetailsHist_T1.DescriptionOccupation_TEXT,   
      EmploymentDetailsHist_T1.IncomeNet_AMNT,   
      EmploymentDetailsHist_T1.IncomeGross_AMNT,   
      EmploymentDetailsHist_T1.FreqIncome_CODE,   
      EmploymentDetailsHist_T1.FreqPay_CODE,   
      EmploymentDetailsHist_T1.SourceLoc_CODE,   
      EmploymentDetailsHist_T1.SourceReceived_DATE,   
      EmploymentDetailsHist_T1.Status_CODE,   
      EmploymentDetailsHist_T1.Status_DATE,   
      EmploymentDetailsHist_T1.SourceLocConf_CODE,   
      EmploymentDetailsHist_T1.InsProvider_INDC,   
      EmploymentDetailsHist_T1.CostInsurance_AMNT,   
      EmploymentDetailsHist_T1.FreqInsurance_CODE,   
      EmploymentDetailsHist_T1.DpCoverageAvlb_INDC,   
      EmploymentDetailsHist_T1.EmployerPrime_INDC,   
      EmploymentDetailsHist_T1.DpCovered_INDC,   
      EmploymentDetailsHist_T1.EligCoverage_DATE,   
      EmploymentDetailsHist_T1.InsReasonable_INDC,   
      EmploymentDetailsHist_T1.LimitCcpa_INDC,   
      EmploymentDetailsHist_T1.PlsLastSearch_DATE,   
      EmploymentDetailsHist_T1.BeginValidity_DATE,   
      EmploymentDetailsHist_T1.EndValidity_DATE,   
      EmploymentDetailsHist_T1.WorkerUpdate_ID,   
      EmploymentDetailsHist_T1.Update_DTTM,   
      EmploymentDetailsHist_T1.TransactionEventSeq_NUMB  
   FROM dbo.EmploymentDetailsHist_T1  
  

GO
