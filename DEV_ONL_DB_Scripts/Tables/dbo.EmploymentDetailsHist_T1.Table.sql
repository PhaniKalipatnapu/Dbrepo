USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'PlsLastSearch_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'LimitCcpa_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'InsReasonable_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EligCoverage_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'DpCovered_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EmployerPrime_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'DpCoverageAvlb_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FreqInsurance_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'CostInsurance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'InsProvider_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'SourceLocConf_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'SourceReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FreqPay_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FreqIncome_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'IncomeGross_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'IncomeNet_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionOccupation_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'TypeIncome_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EndEmployment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginEmployment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'OthpPartyEmpl_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[EmploymentDetailsHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[EmploymentDetailsHist_T1]
GO
/****** Object:  Table [dbo].[EmploymentDetailsHist_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmploymentDetailsHist_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[OthpPartyEmpl_IDNO] [numeric](9, 0) NOT NULL,
	[BeginEmployment_DATE] [date] NOT NULL,
	[EndEmployment_DATE] [date] NOT NULL,
	[TypeIncome_CODE] [char](2) NOT NULL,
	[DescriptionOccupation_TEXT] [char](32) NOT NULL,
	[IncomeNet_AMNT] [numeric](11, 2) NOT NULL,
	[IncomeGross_AMNT] [numeric](11, 2) NOT NULL,
	[FreqIncome_CODE] [char](1) NOT NULL,
	[FreqPay_CODE] [char](1) NOT NULL,
	[SourceLoc_CODE] [char](3) NOT NULL,
	[SourceReceived_DATE] [date] NOT NULL,
	[Status_CODE] [char](1) NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[SourceLocConf_CODE] [char](3) NOT NULL,
	[InsProvider_INDC] [char](1) NOT NULL,
	[CostInsurance_AMNT] [numeric](11, 2) NOT NULL,
	[FreqInsurance_CODE] [char](1) NOT NULL,
	[DpCoverageAvlb_INDC] [char](1) NOT NULL,
	[EmployerPrime_INDC] [char](1) NOT NULL,
	[DpCovered_INDC] [char](1) NOT NULL,
	[EligCoverage_DATE] [date] NOT NULL,
	[InsReasonable_INDC] [char](1) NOT NULL,
	[LimitCcpa_INDC] [char](1) NOT NULL,
	[PlsLastSearch_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [HEHIS_I1] PRIMARY KEY CLUSTERED 
(
	[BeginEmployment_DATE] ASC,
	[MemberMci_IDNO] ASC,
	[OthpPartyEmpl_IDNO] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the system to the participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique number assigned by the system to the employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'OthpPartyEmpl_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Indicates the Date on which the Participant started working with the Employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginEmployment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Participant terminated the employment with the Employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EndEmployment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Income Type of the Employer. Values are obtained from REFM (EHIS/SOIT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'TypeIncome_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Occupation of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'DescriptionOccupation_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Participants Net Income.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'IncomeNet_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Participants Gross Income.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'IncomeGross_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Frequency at which Participant''s gross wage is paid. Values are obtained from REFM (EHIS/WAGE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FreqIncome_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the frequency at which the employer pays the NCP. Values are obtained from REFM (FRQA/FRQ3).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FreqPay_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the source of the employment information for the source of income record. Values are obtained from REFM (EHIS/SRCE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Information Source was received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'SourceReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the code of the Information Source. Values are obtained from REFM (CONF/CON1, CONF/CONF).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Employment was verified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Once info is received, this is the source type that verifies this information. Could be Post master, NCP or CP. Values are obtained from REFM (EHIS/SRCE, EHIS/VERF).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'SourceLocConf_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Insurance Coverage is available for the Participant. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'InsProvider_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Insurance cost of the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'CostInsurance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Cost Frequency of the Insurance. Values are obtained from REFM (FRQA/FRQ3).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'FreqInsurance_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Dependent Coverage is available on the Insurance. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'DpCoverageAvlb_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Employer is the Primary Employer of the Participant. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EmployerPrime_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Dependents are covered on this Insurance. This can be done only if the coverage is available. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'DpCovered_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date from which the Insurance Coverage is available for the Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EligCoverage_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Insurance is available at Reasonable Cost to the Participant. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'InsReasonable_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the amount being withheld from wages for insurance is in compliance with the Consumer''s Credit Protection Act. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'LimitCcpa_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the last search was made on parent locator service.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'PlsLastSearch_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This tables stores the history information of the employer''s details for a given member DCN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmploymentDetailsHist_T1'
GO
