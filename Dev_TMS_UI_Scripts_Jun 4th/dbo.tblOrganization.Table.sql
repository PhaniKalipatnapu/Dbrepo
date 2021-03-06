/****** Object:  Table [tblOrganization]    Script Date: 5/28/2015 10:15:26 PM ******/
CREATE TABLE [tblOrganization](
	[Organization_ID] [varchar](8) NOT NULL,
	[Organization_NAME] [varchar](150) NOT NULL,
	[OrganizationType_CODE] [varchar](2) NOT NULL,
	[OrganizationEIN_TEXT] [varchar](9) NULL,
	[FaithBased_INDC] [char](1) NULL,
	[Acceptance_INDC] [char](1) NULL,
	[Privacy_INDC] [char](1) NULL,
	[About_TEXT] [varchar](8000) NULL,
	[LogoURL_TEXT] [varchar](150) NULL,
	[Licensed_INDC] [char](1) NULL,
	[LicenseBy_NAME] [varchar](100) NULL,
	[LicensedURL_TEXT] [varchar](255) NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
	CONSTRAINT [PK_tblOrganization] PRIMARY KEY CLUSTERED 
	(
		[Organization_ID] ASC
	)
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the particular Organization, Organization Starts with "ORG", Example "ORG00001"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'Organization_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'corresponding name for the Organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'Organization_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type of the organization ex: non profit org.. Table_ID:ORGT / TableSub_ID:TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'OrganizationType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Employee Identification Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'OrganizationEIN_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indication for the organization is faith based' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'FaithBased_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indication for the user acceptance' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'Acceptance_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indication for the Orginization Address privacy' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'Privacy_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Text for the corresponding organization mission/about' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'About_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Organization server url text ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'LogoURL_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indication for the Organization is licensed or not' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'Licensed_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'License Provided by Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'LicenseBy_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'url text for the attached License Document File' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'LicensedURL_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Begin date for the Record, The record is valid from the Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sequence number for the particular transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date time on whic the Record is modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'worker id who is responsible for the Modification of the Record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the information about the organization Ex:name id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganization'
GO
