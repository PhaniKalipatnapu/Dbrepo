/****** Object:  Table [tblServiceMaster]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblServiceMaster](
	[Service_ID] [varchar](8) NOT NULL,
	[Organization_ID] [varchar](8) NOT NULL,
	[Service_NAME] [varchar](150) NOT NULL,
	[Description_TEXT] [varchar](4000) NULL,
	[ServiceCost_CODE] [char](1) NULL,
	[ServiceCost_AMT] [numeric](9, 2) NULL,
	[ServiceInfo_TEXT] [varchar](4000) NULL,
	[ServiceEnroll_TEXT] [varchar](4000) NULL,
	[ServiceURL_TEXT] [char](150) NULL,
	[ServiceRequirement_TEXT] [varchar](4000) NULL,
	[LanguageEnglish_INDC] [char](1) NULL,
	[LanguageSpanish_INDC] [char](1) NULL,
	[LanguageSign_INDC] [char](1) NULL,
	[LanguageOthers_TEXT] [varchar](50) NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblServiceMaster] PRIMARY KEY CLUSTERED 
(
	[Service_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [tblServiceMaster]  WITH CHECK ADD  CONSTRAINT [FK_tblServiceMaster_Organization_ID] FOREIGN KEY([Organization_ID])
REFERENCES [tblOrganization] ([Organization_ID])
GO
ALTER TABLE [tblServiceMaster] CHECK CONSTRAINT [FK_tblServiceMaster_Organization_ID]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the corresponding services' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'Service_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the particular Organization, Organization Starts with "ORG", Example "ORG00001"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'Organization_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the corresponding name for the service' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'Service_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the description text for the service' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'Description_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the service have fee or cost.. Table_ID:FEEA / TableSub_ID:FEEA' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'ServiceCost_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the cost for the service' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'ServiceCost_AMT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the service information text ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'ServiceInfo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the enrollment text for the service' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'ServiceEnroll_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the attachment text url' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'ServiceURL_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the service requirment text ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'ServiceRequirement_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the indication for language is english' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'LanguageEnglish_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the indication for language is Spanish' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'LanguageSpanish_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the indication for Sign language ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'LanguageSign_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the Description for Other language ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'LanguageOthers_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Begin date for the Record, The record is valid from the Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sequence number for the particular transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date time on whic the Record is modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'worker id who is responsible for the Modification of the Record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains information about the services Ex : name ,id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServiceMaster'
GO
