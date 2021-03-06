/****** Object:  View [dbo].[UDCKT_V1]    Script Date: 4/10/2015 3:12:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UDCKT_V1] (  
   File_ID,   
   County_CODE,   
   FileType_CODE,   
   CaseTitle_NAME,   
   Filed_DATE,   
   WorkerUpdate_IDNO,   
   BeginValidity_DATE,   
   EndValidity_DATE,   
   EventGlobalBegin_SEQ,   
   EventGlobalEnd_SEQ,   
   Update_DTTM)  
AS   
     
  SELECT   
      Dockets_T1.File_ID,   
      Dockets_T1.County_IDNO,   
      Dockets_T1.FileType_CODE,   
      Dockets_T1.CaseTitle_NAME,   
      Dockets_T1.Filed_DATE,   
      Dockets_T1.WorkerUpdate_ID,   
      Dockets_T1.BeginValidity_DATE,   
      '31-DEC-9999' AS EndValidity_DATE,   
      Dockets_T1.EventGlobalBeginSeq_NUMB ,   
      0 AS EventGlobalEnd_SEQ,   
      Dockets_T1.Update_DTTM  
   FROM dbo.Dockets_T1  
    UNION ALL  
   SELECT   
      DocketsHist_T1.File_ID,   
      DocketsHist_T1.County_IDNO,   
      DocketsHist_T1.FileType_CODE,   
      DocketsHist_T1.CaseTitle_NAME,   
      DocketsHist_T1.Filed_DATE,   
      DocketsHist_T1.WorkerUpdate_ID,   
      DocketsHist_T1.BeginValidity_DATE,   
      DocketsHist_T1.EndValidity_DATE,   
      DocketsHist_T1.EventGlobalBeginSeq_NUMB,   
      DocketsHist_T1.EventGlobalEndSeq_NUMB,   
      DocketsHist_T1.Update_DTTM  
   FROM dbo.DocketsHist_T1  
  

GO
