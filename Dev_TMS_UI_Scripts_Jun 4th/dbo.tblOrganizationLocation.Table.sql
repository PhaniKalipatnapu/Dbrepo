/****** Object:  Table [tblOrganizationLocation]    Script Date: 5/28/2015 10:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tblOrganizationLocation](
	[Location_IDNO] [int] IDENTITY(1,1) NOT NULL,
	[LocationType_CODE] [varchar](2) NULL,
	[Organization_ID] [varchar](8) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NULL,
	[City_ADDR] [varchar](28) NULL,
	[State_ADDR] [varchar](2) NULL,
	[Zip_CODE] [varchar](15) NULL,
	[County_CODE] [varchar](2) NULL,
	[OfficePhone_NUMB] [varchar](15) NULL,
	[CellPhone_NUMB] [varchar](15) NULL,
	[OtherPhone_NUMB] [varchar](15) NULL,
	[FaxPhone_NUMB] [varchar](15) NULL,
	[Website_TEXT] [varchar](150) NULL,
	[Contact_EML] [varchar](150) NULL,
	[TimeZone_CODE] [varchar](10) NULL,
	[Comments_TEXT] [varchar](8000) NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NULL,
	[WorkerUpdate_ID] [varchar](8) NULL,
 CONSTRAINT [PK_tblOrganizationLocation] PRIMARY KEY CLUSTERED 
(
	[Location_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [tblOrganizationLocation]  WITH CHECK ADD  CONSTRAINT [FK_tblOrganizationLocation_Organization_ID] FOREIGN KEY([Organization_ID])
REFERENCES [tblOrganization] ([Organization_ID])
GO
ALTER TABLE [tblOrganizationLocation] CHECK CONSTRAINT [FK_tblOrganizationLocation_Organization_ID]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the organization location ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Location_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It indicate Location code Ex: mailing address,branch address. Table_ID:LOCT / TableSub_ID:TYPE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'LocationType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unique id for the particular Organization, Organization Starts with "ORG", Example "ORG00001"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Organization_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the address Line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the address Line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the city name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'State name ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the zipcode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Zip_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'county code ... Table_ID:COPT / TableSub_ID:COPT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'County_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Office phone number for the organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'OfficePhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cell phone number for the organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'CellPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Other phone number for the organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'OtherPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fax number for the organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'FaxPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Websit address for the organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Website_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact email address ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Contact_EML'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the Time zone for the organization...Table_ID:TIME / TableSub_ID:ZONE' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'TimeZone_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comments text for the organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Comments_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Begin date for the Record, The record is valid from the Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sequence number for the particular transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'date time on whic the Record is modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'worker id who is responsible for the Modification of the Record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'It contains the organization locations details' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblOrganizationLocation'
GO
