USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'InsSource_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'NonQualified_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'DescriptionOthers_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'MentalIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'PrescptIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'VisionIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'DentalIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'MedicalIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'ChildMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'PolicyInsNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'InsuranceGroupNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'OthpInsurance_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Index [DINS_MEMBER_STATUS_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DINS_MEMBER_STATUS_I1] ON [dbo].[DependantInsurance_T1]
GO
/****** Object:  Table [dbo].[DependantInsurance_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[DependantInsurance_T1]
GO
/****** Object:  Table [dbo].[DependantInsurance_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DependantInsurance_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[OthpInsurance_IDNO] [numeric](9, 0) NOT NULL,
	[InsuranceGroupNo_TEXT] [char](25) NOT NULL,
	[PolicyInsNo_TEXT] [char](20) NOT NULL,
	[ChildMCI_IDNO] [numeric](10, 0) NOT NULL,
	[Begin_DATE] [date] NOT NULL,
	[End_DATE] [date] NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[MedicalIns_INDC] [char](1) NOT NULL,
	[DentalIns_INDC] [char](1) NOT NULL,
	[VisionIns_INDC] [char](1) NOT NULL,
	[PrescptIns_INDC] [char](1) NOT NULL,
	[MentalIns_INDC] [char](1) NOT NULL,
	[DescriptionOthers_TEXT] [varchar](50) NOT NULL,
	[Status_CODE] [char](2) NOT NULL,
	[NonQualified_CODE] [char](1) NOT NULL,
	[InsSource_CODE] [char](3) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [DINS_I1] PRIMARY KEY CLUSTERED 
(
	[Begin_DATE] ASC,
	[InsuranceGroupNo_TEXT] ASC,
	[MemberMci_IDNO] ASC,
	[ChildMCI_IDNO] ASC,
	[OthpInsurance_IDNO] ASC,
	[PolicyInsNo_TEXT] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DINS_MEMBER_STATUS_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DINS_MEMBER_STATUS_I1] ON [dbo].[DependantInsurance_T1]
(
	[ChildMCI_IDNO] ASC,
	[Status_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the system to the participant. This is the MCI of the NCP or the CP by whom the insurance is provided to the dependent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique number assigned by the system to the Insurance Co. of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'OthpInsurance_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Group number of the Participant Insurance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'InsuranceGroupNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Policy Number of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'PolicyInsNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Dependent''s ID for whom the insurance is provided.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'ChildMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Date from which the Insurance Policy Starts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date at which the Insurance Policy Ends.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the Insurance was verified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Participant is eligible for Medical Insurance. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'MedicalIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Participant is eligible for Dental Insurance. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'DentalIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Participant is eligible for Vision Insurance. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'VisionIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Participant is eligible for Prescription Drugs. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'PrescptIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Participant is eligible for Mental Insurance. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'MentalIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description of the other Type of Coverage available for the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'DescriptionOthers_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Verified status code. Values are obtained from REFM (MDIN/PVST).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Non-Qualified Insurance of the Member (Family Care / Medicaid / Not Applicable). Values are obtained from REFM (MDIN/NOQU).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'NonQualified_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Source Code from where the Insurance was verified. Values are obtained from REFM (MDIN/SRCE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'InsSource_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The  Effective date up to which the Changed Information will be  Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'7', @value=N'Unique Sequence Number that will be  generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Table stores the Dependent Details that are associated with the Insurance provided by the CP/NCP/Third Party.  This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DependantInsurance_T1'
GO
