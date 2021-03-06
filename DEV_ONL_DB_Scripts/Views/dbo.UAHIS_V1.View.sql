/****** Object:  View [dbo].[UAHIS_V1]    Script Date: 4/10/2015 3:12:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
      
CREATE VIEW [dbo].[UAHIS_V1] (      
   MemberMci_IDNO,       
   TypeAddress_CODE,       
   Begin_DATE,       
   End_DATE,       
   Attn_ADDR,       
   Line1_ADDR,       
   Line2_ADDR,        
   City_ADDR,       
   State_ADDR,       
   Zip_ADDR,       
   Country_ADDR,       
     
   SourceLoc_CODE,       
   SourceReceived_DATE,       
   Status_CODE,       
   Status_DATE,       
   SourceVerified_CODE,       
      
   DescriptionServiceDirection_TEXT,       
   PlsLoad_DATE,       
   BeginValidity_DATE,       
   EndValidity_DATE,       
   WorkerUpdate_ID,       
   Update_DTTM,       
   TransactionEventSeq_NUMB,       
   DescriptionComments_TEXT,       
   Normalization_CODE)      
AS       
         
     SELECT       
      AddressDetails_T1.MemberMci_IDNO,       
      AddressDetails_T1.TypeAddress_CODE,       
      AddressDetails_T1.Begin_DATE,       
      AddressDetails_T1.End_DATE,       
      AddressDetails_T1.Attn_ADDR,       
      AddressDetails_T1.Line1_ADDR,       
      AddressDetails_T1.Line2_ADDR,       
      AddressDetails_T1.City_ADDR,       
      AddressDetails_T1.State_ADDR,       
      AddressDetails_T1.Zip_ADDR,       
      AddressDetails_T1.Country_ADDR,       

      AddressDetails_T1.SourceLoc_CODE,       
      AddressDetails_T1.SourceReceived_DATE,       
      AddressDetails_T1.Status_CODE,       
      AddressDetails_T1.Status_DATE,       
      AddressDetails_T1.SourceVerified_CODE,       

      AddressDetails_T1.DescriptionServiceDirection_TEXT,       
      AddressDetails_T1.PlsLoad_DATE,       
      AddressDetails_T1.BeginValidity_DATE,       
      '31-DEC-9999' AS EndValidity_DATE,       
      AddressDetails_T1.WorkerUpdate_ID,       
      AddressDetails_T1.Update_DTTM,       
      AddressDetails_T1.TransactionEventSeq_NUMB,       
      AddressDetails_T1.DescriptionComments_TEXT,       
      AddressDetails_T1.Normalization_CODE      
   FROM dbo.AddressDetails_T1      
    UNION ALL      
   SELECT       
      AddressDetailsHist_T1.MemberMci_IDNO,       
      AddressDetailsHist_T1.TypeAddress_CODE,       
      AddressDetailsHist_T1.Begin_DATE,       
      AddressDetailsHist_T1.End_DATE,       
      AddressDetailsHist_T1.Attn_ADDR,       
      AddressDetailsHist_T1.Line1_ADDR,       
      AddressDetailsHist_T1.Line2_ADDR,    
      AddressDetailsHist_T1.City_ADDR,       
      AddressDetailsHist_T1.State_ADDR,       
      AddressDetailsHist_T1.Zip_ADDR,       
      AddressDetailsHist_T1.Country_ADDR,       

      AddressDetailsHist_T1.SourceLoc_CODE,       
      AddressDetailsHist_T1.SourceReceived_DATE,       
      AddressDetailsHist_T1.Status_CODE,       
      AddressDetailsHist_T1.Status_DATE,       
      AddressDetailsHist_T1.SourceVerified_CODE,       

      AddressDetailsHist_T1.DescriptionServiceDirection_TEXT,       
      AddressDetailsHist_T1.PlsLoad_DATE,       
      AddressDetailsHist_T1.BeginValidity_DATE,       
      AddressDetailsHist_T1.EndValidity_DATE,       
      AddressDetailsHist_T1.WorkerUpdate_ID,       
      AddressDetailsHist_T1.Update_DTTM,       
      AddressDetailsHist_T1.TransactionEventSeq_NUMB,       
      AddressDetailsHist_T1.DescriptionComments_TEXT,       
      AddressDetailsHist_T1.Normalization_CODE      
   FROM dbo.AddressDetailsHist_T1      
      
      
GO
