USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'TypeParticipant_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Sein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'DodStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'AgencyReporting_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'QtrReporting_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'SsnMatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Wage_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'TypeAddress_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'StateReporting_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[FcrQuarterlyWage_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FcrQuarterlyWage_T1]
GO
/****** Object:  Table [dbo].[FcrQuarterlyWage_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FcrQuarterlyWage_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[StateReporting_CODE] [char](2) NOT NULL,
	[TypeAddress_CODE] [char](1) NOT NULL,
	[Wage_AMNT] [numeric](11, 2) NOT NULL,
	[Fein_IDNO] [numeric](9, 0) NOT NULL,
	[SsnMatch_CODE] [char](1) NOT NULL,
	[QtrReporting_CODE] [char](5) NOT NULL,
	[AgencyReporting_NAME] [char](9) NOT NULL,
	[DodStatus_CODE] [char](1) NOT NULL,
	[Sein_IDNO] [numeric](12, 0) NOT NULL,
	[TypeParticipant_CODE] [char](2) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [FCRQ_I1] PRIMARY KEY CLUSTERED 
(
	[Fein_IDNO] ASC,
	[MemberMci_IDNO] ASC,
	[QtrReporting_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This field will contain the information on the record submitted for Locate processing or the Member ID stored on the FCR for a Proactive Match.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will contain the two-digit numeric FIPS Code of the state or territory that submitted the QW data to the NDNH. This field will be  blank if the QW was reported by a Federal agency or if the information is not available. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'StateReporting_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate the type of address provided. Possible values are 1 - Employer Address, 3 - Employer Optional Address and  Space -  No address provided.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'TypeAddress_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will contain the gross amount of wages an employer reports as paid to an employee during the reporting quarter. The last two positions are implied to be to the right of the decimal point. The default is zeroes. The last position is signed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Wage_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'This field will contain the employers Federal Employer Identification Number. This field will be  spaces if the information is not available.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate if the SSN contained in the record is the state-submitted SSN, or a corrected or multiple SSN. Possible values are C - Corrected SSN, M - Additional/Multiple SSN, V - State-submitted verified SSN, X - Multiple SSN from a corrected SSN and ‘A’ - Verified additional SSN/name combination. If this field is C, M,X or A, the SSN used in the match will be  in the Corrected/ Additional/Multiple SSN/Verified additional SSN field' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'SsnMatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Indicates the time period of the quarterly wages being sent in this record. The format is CCYYQ. CC = Century YY = Year Q = Reporting quarter. Possible values are 1 - January 1 through March 31, 2 - April 1 through June 30, 3 - July 1 through September 30 and 4 - October 1 through December 31. This field will be  spaces if the information is not available.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'QtrReporting_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will contain the code for the Federal agency that reported the quarterly wages. This field will be  blank if the QWs were reported by a state, territory or if the information is not available.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'AgencyReporting_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicate the status of an employee reported by DOD. Possible values are A - Active duty employee, C - Civilian employee, P - Pension/Retired employee and R - Reserve employee. This field will be  blank if the QW was reported by a Federal agency other than DOD, a state, territory or if the information is not available.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'DodStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will contain the State Employer Identification Number. This field will be  spaces if the State EIN was not supplied or is not available.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Sein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the persons Participant Type on the case. Possible values are CP - Custodial Party, NP - Non-custodial Parent, PF - Putative Father. If the NDNH Match Type is P, this field will contain the code from the Add or Change Transaction that generated the match. If the NDNH Match Type is N and the person is on multiple cases, the Participant Type that is returned will be  determined based on the following hierarchy: NP, PF and CP. If the NDNH Match Type is L, the field will be  spaces.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'TypeParticipant_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the actual date of transaction that happens for this action.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be  generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store Quarterly Wage Records from FCR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrQuarterlyWage_T1'
GO
