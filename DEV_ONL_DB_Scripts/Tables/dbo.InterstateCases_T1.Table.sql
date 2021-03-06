USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'DescriptionComments_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'PetitionerMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'RespondentMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Create_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateTypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'FaxContact_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Contact_EML'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Referral_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'PhoneContact_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContactMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContactLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Respondent_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContactFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Petitioner_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFile_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContOrder_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContOrder_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ControlByCrtOrder_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[InterstateCases_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[InterstateCases_T1]
GO
/****** Object:  Table [dbo].[InterstateCases_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InterstateCases_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[IVDOutOfStateCase_ID] [char](15) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[IVDOutOfStateOfficeFips_CODE] [char](2) NOT NULL,
	[IVDOutOfStateCountyFips_CODE] [char](3) NOT NULL,
	[Status_CODE] [char](1) NOT NULL,
	[Effective_DATE] [date] NOT NULL,
	[End_DATE] [date] NOT NULL,
	[RespondInit_CODE] [char](1) NOT NULL,
	[ControlByCrtOrder_INDC] [char](1) NOT NULL,
	[ContOrder_DATE] [date] NOT NULL,
	[ContOrder_ID] [char](15) NOT NULL,
	[IVDOutOfStateFile_ID] [char](17) NOT NULL,
	[Petitioner_NAME] [varchar](65) NOT NULL,
	[ContactFirst_NAME] [char](30) NOT NULL,
	[Respondent_NAME] [varchar](65) NOT NULL,
	[ContactLast_NAME] [char](30) NOT NULL,
	[ContactMiddle_NAME] [char](30) NOT NULL,
	[PhoneContact_NUMB] [numeric](15, 0) NOT NULL,
	[Referral_DATE] [date] NOT NULL,
	[Contact_EML] [varchar](100) NOT NULL,
	[FaxContact_NUMB] [numeric](15, 0) NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[County_IDNO] [numeric](3, 0) NOT NULL,
	[IVDOutOfStateTypeCase_CODE] [char](1) NOT NULL,
	[Create_DATE] [date] NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[RespondentMci_IDNO] [numeric](10, 0) NOT NULL,
	[PetitionerMci_IDNO] [numeric](10, 0) NOT NULL,
	[DescriptionComments_TEXT] [varchar](1000) NOT NULL,
 CONSTRAINT [ICAS_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[IVDOutOfStateFips_CODE] ASC,
	[IVDOutOfStateFile_ID] ASC,
	[Reason_CODE] ASC,
	[RespondentMci_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Indicates the DACSES IVD Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Other State Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Indicates the Interstate Case State. Values are obtained from REFM (FIPS/STCD)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Interstate Case FIPS Code. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateOfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Interstate Case County. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateCountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the status of a member’s address on AHIS. Values are obtained from REFM (CONF/CON1)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Effective Date of the Interstate Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the End Date of the Interstate Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'End_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Case is Initiating or Responding Case. Values are obtained from REFM (INTS/CATG)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator for the Control by Court Order. Values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ControlByCrtOrder_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Control Order Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContOrder_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Control Order Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContOrder_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Other State Court Case Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFile_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Petitioner Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Petitioner_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the First Name of the Contact Person.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContactFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Respondent Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Respondent_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Last Name of the Contact Person.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContactLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Middle Name of the Contact Person.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'ContactMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Phone Number of the Contact Person.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'PhoneContact_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Referral Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Referral_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Email of the Contact Person.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Contact_EML'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Fax Number of the Contact Person.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'FaxContact_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the File Number assigned for the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the County Number of the Case. Values are obtained from REFM (OTHP/CNTY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Other State Case Type. Values are obtained from REFM (CSEN/ICST)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateTypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Record Creation Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Create_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Worker ID who created the Record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'7', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Reason Code. Values are obtained from REFM (INTS/FARC)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Respondent MCI ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'RespondentMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Petitioner MCI ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'PetitionerMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to hold any other comments about the inter-governmental referrals.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1', @level2type=N'COLUMN',@level2name=N'DescriptionComments_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Intergovernmental Cases - This table stores the cross reference between the Out state cases vs. the instate IV-D cases. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Inter Govermental Cases - This table stores the cross reference between the Out state cases vs the instate IV-D cases. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InterstateCases_T1'
GO
