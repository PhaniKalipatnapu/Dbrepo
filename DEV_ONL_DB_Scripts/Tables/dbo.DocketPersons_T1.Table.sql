USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'AssociatedMemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'AttorneyAttn_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'EffectiveEnd_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'EffectiveStart_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'File_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'DocketPerson_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'TypePerson_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
/****** Object:  Index [DPRS_OTHP_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DPRS_OTHP_I1] ON [dbo].[DocketPersons_T1]
GO
/****** Object:  Table [dbo].[DocketPersons_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[DocketPersons_T1]
GO
/****** Object:  Table [dbo].[DocketPersons_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DocketPersons_T1](
	[File_ID] [char](10) NOT NULL,
	[County_IDNO] [numeric](3, 0) NOT NULL,
	[TypePerson_CODE] [char](3) NOT NULL,
	[DocketPerson_IDNO] [numeric](10, 0) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[File_NAME] [varchar](60) NOT NULL,
	[EffectiveStart_DATE] [date] NOT NULL,
	[EffectiveEnd_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[AttorneyAttn_NAME] [varchar](60) NOT NULL,
	[AssociatedMemberMci_IDNO] [numeric](10, 0) NOT NULL,
 CONSTRAINT [DPRS_I1] PRIMARY KEY CLUSTERED 
(
	[File_ID] ASC,
	[County_IDNO] ASC,
	[TypePerson_CODE] ASC,
	[DocketPerson_IDNO] ASC,
	[AssociatedMemberMci_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [DPRS_OTHP_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DPRS_OTHP_I1] ON [dbo].[DocketPersons_T1]
(
	[DocketPerson_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Indicates the File Number assigned to the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Three char numeric county number, together with file-id is unique.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'The party type, either a member or other. Values are obtained from REFM (DPRS/ROLE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'TypePerson_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Specifies either which other-party or which member this is for.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'DocketPerson_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Member NCP Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'File_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The validity period end date for the information in this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'EffectiveStart_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The validity period beginning date for the information in this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'EffectiveEnd_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Unique Sequence Number that will be  generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Attorney Attention needed to save the Attorney Name when linking an Attorney Firm to the File ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'AttorneyAttn_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Unique ID assigned to the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1', @level2type=N'COLUMN',@level2name=N'AssociatedMemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Table stores the Members Associated to the File and their   Corresponding Roles. This table stores valid records as well as history   records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocketPersons_T1'
GO
