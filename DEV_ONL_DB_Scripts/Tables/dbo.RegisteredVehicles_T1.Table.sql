USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'LienInitiated_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Lien_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'AccountLienNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'ValueAssessed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'CntyFipsAssess_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'StateAssess_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'OthpLien_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'ValueAsset_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Expired_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Issued_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'StateVehicle_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionAutoNoLic_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionAutoYear_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionAutoModel_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionAutoMake_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionVin_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'TitleNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'AssetSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Asset_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[RegisteredVehicles_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RegisteredVehicles_T1]
GO
/****** Object:  Table [dbo].[RegisteredVehicles_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RegisteredVehicles_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Asset_CODE] [char](3) NOT NULL,
	[AssetSeq_NUMB] [numeric](3, 0) NOT NULL,
	[SourceLoc_CODE] [char](3) NOT NULL,
	[TitleNo_TEXT] [char](15) NOT NULL,
	[DescriptionVin_TEXT] [char](20) NOT NULL,
	[DescriptionAutoMake_TEXT] [char](15) NOT NULL,
	[DescriptionAutoModel_TEXT] [char](15) NOT NULL,
	[DescriptionAutoYear_TEXT] [char](4) NOT NULL,
	[DescriptionAutoNoLic_TEXT] [char](10) NOT NULL,
	[StateVehicle_CODE] [char](2) NOT NULL,
	[Issued_DATE] [date] NOT NULL,
	[Expired_DATE] [date] NOT NULL,
	[ValueAsset_AMNT] [numeric](11, 2) NOT NULL,
	[OthpLien_IDNO] [numeric](9, 0) NOT NULL,
	[StateAssess_CODE] [char](2) NOT NULL,
	[CntyFipsAssess_CODE] [char](3) NOT NULL,
	[ValueAssessed_AMNT] [numeric](11, 2) NOT NULL,
	[AccountLienNo_TEXT] [char](15) NOT NULL,
	[Lien_AMNT] [numeric](11, 2) NOT NULL,
	[LienInitiated_INDC] [char](1) NOT NULL,
	[Status_CODE] [char](1) NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [ASRV_I1] PRIMARY KEY CLUSTERED 
(
	[Asset_CODE] ASC,
	[AssetSeq_NUMB] ASC,
	[MemberMci_IDNO] ASC,
	[SourceLoc_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the System to the MCI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Indicates Type of Asset. Values are obtained from REFM (MAST/REGV).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Asset_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique number generated for Each Asset.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'AssetSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Identifies the Verification Source Location. Values are obtained from REFM (MAST/SRCE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Vehicle Title Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'TitleNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Vehicle Identification number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionVin_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Make of the Vehicle.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionAutoMake_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Model of the Vehicle.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionAutoModel_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Year of the Vehicle.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionAutoYear_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'License Number of the Vehicle.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'DescriptionAutoNoLic_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the State of the License. Values are obtained from REFM (MAST/LSTA).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'StateVehicle_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the License was issued.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Issued_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Date on which the License Expires.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Expired_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Value of the Vehicle.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'ValueAsset_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The other party ID who is holding the LIEN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'OthpLien_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State code on which the Vehicle was assessed. Values are obtained from REFM (MAST/ASTA).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'StateAssess_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County FIPS where the Vehicle was assessed. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'CntyFipsAssess_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Assessed Value of the Vehicle.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'ValueAssessed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'LIEN Account Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'AccountLienNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'LIEN Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Lien_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether Lien is initiated or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'LienInitiated_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Verification Status code. Values are obtained from REFM (MAST/VSTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Vehicle was verified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Unique Sequence Number that will be generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the vehicle registration information of the member''s present in the system. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegisteredVehicles_T1'
GO
