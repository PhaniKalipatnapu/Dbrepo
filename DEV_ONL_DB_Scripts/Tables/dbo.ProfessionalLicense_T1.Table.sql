USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Trade_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Business_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Profession_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'SourceVerified_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'SuspLicense_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'ExpireLicense_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'IssueLicense_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'OthpLicAgent_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'LicenseStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'IssuingState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'TypeLicense_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Index [PLIC_MEMBER_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [PLIC_MEMBER_I1] ON [dbo].[ProfessionalLicense_T1]
GO
/****** Object:  Table [dbo].[ProfessionalLicense_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ProfessionalLicense_T1]
GO
/****** Object:  Table [dbo].[ProfessionalLicense_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProfessionalLicense_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[TypeLicense_CODE] [char](5) NOT NULL,
	[LicenseNo_TEXT] [char](25) NOT NULL,
	[IssuingState_CODE] [char](2) NOT NULL,
	[LicenseStatus_CODE] [char](1) NOT NULL,
	[OthpLicAgent_IDNO] [numeric](9, 0) NOT NULL,
	[IssueLicense_DATE] [date] NOT NULL,
	[ExpireLicense_DATE] [date] NOT NULL,
	[SuspLicense_DATE] [date] NOT NULL,
	[Status_CODE] [char](2) NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[SourceVerified_CODE] [char](3) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Profession_CODE] [char](3) NOT NULL,
	[Business_NAME] [varchar](50) NOT NULL,
	[Trade_NAME] [varchar](50) NOT NULL,
 CONSTRAINT [PLIC_I1] PRIMARY KEY CLUSTERED 
(
	[LicenseNo_TEXT] ASC,
	[MemberMci_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC,
	[TypeLicense_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PLIC_MEMBER_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [PLIC_MEMBER_I1] ON [dbo].[ProfessionalLicense_T1]
(
	[MemberMci_IDNO] ASC,
	[TypeLicense_CODE] ASC,
	[EndValidity_DATE] DESC,
	[LicenseStatus_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the System to the Participants.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Indicates the License code type. Values are obtained from REFM (LICT/TYPE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'TypeLicense_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Indicates the License Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the State which Issued the License. Possible values are limited by values in STAT table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'IssuingState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Status of the License. Values are obtained from REFM (MLIC/LICS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'LicenseStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the ID of the Agency who issued the License.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'OthpLicAgent_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the License was issued.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'IssueLicense_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the License Expires.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'ExpireLicense_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the License was suspended.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'SuspLicense_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the status of a member’s address on AHIS. Values are obtained from REFM (CONF/CON1)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Verification date of the license.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the entity that confirmed the address. Values are obtained from REFM (AHIS/VERF).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'SourceVerified_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The information in any record is Valid only between the dates DT_BEG_VALIDITY and DT_END_VALIDITY. When any information is changed, then a new record is inserted with changed information and the DT_BEG_VALIDITY is the date from when the change will be  effective.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The information in any record is Valid only between the dates DT_BEG_VALIDITY and DT_END_VALIDITY. When any information is changed, then a new record is inserted with changed information and the DT_BEG_VALIDITY is the date from when the change will be  effective. DT_END_VALIDITY of the old record should have the DT_BEG_VALIDITY of the new record. DT_END_VALIDITY of the new record should have a high date (12/31/9999).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be  generated for a given Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Profession code are obtained from REFM (MLIC/PROF).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Profession_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The name of the business is provided by the Division of Revenue licensing agency' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Business_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Trade Name provided by the Division of Revenue licensing agency.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1', @level2type=N'COLUMN',@level2name=N'Trade_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the license details of the MCI’s present in the system.  This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProfessionalLicense_T1'
GO
