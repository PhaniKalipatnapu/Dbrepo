USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Mortgage_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'StateAssess_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'CntyFipsAssess_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Sold_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Balance_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'MortgageBalance_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Mortgage_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'LienInitiated_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'OthpLien_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'ValueAsset_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Purchase_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'ZipAsset_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'CountryAsset_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'StateAsset_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'CityAsset_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Line2Asset_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Line1Asset_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'AssetPageNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'AssetBookNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'AssetLotNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'AssetSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Asset_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[RealtyAssets_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RealtyAssets_T1]
GO
/****** Object:  Table [dbo].[RealtyAssets_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RealtyAssets_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Asset_CODE] [char](3) NOT NULL,
	[AssetSeq_NUMB] [numeric](3, 0) NOT NULL,
	[AssetLotNo_TEXT] [char](5) NOT NULL,
	[SourceLoc_CODE] [char](3) NOT NULL,
	[AssetBookNo_TEXT] [char](5) NOT NULL,
	[AssetPageNo_TEXT] [char](5) NOT NULL,
	[Line1Asset_ADDR] [varchar](50) NOT NULL,
	[Line2Asset_ADDR] [varchar](50) NOT NULL,
	[CityAsset_ADDR] [char](28) NOT NULL,
	[StateAsset_ADDR] [char](2) NOT NULL,
	[CountryAsset_ADDR] [char](2) NOT NULL,
	[ZipAsset_ADDR] [char](15) NOT NULL,
	[Purchase_DATE] [date] NOT NULL,
	[ValueAsset_AMNT] [numeric](11, 2) NOT NULL,
	[OthpLien_IDNO] [numeric](9, 0) NOT NULL,
	[LienInitiated_INDC] [char](1) NOT NULL,
	[Mortgage_AMNT] [numeric](11, 2) NOT NULL,
	[MortgageBalance_AMNT] [numeric](11, 2) NOT NULL,
	[Balance_DATE] [date] NOT NULL,
	[Sold_DATE] [date] NOT NULL,
	[Status_CODE] [char](1) NOT NULL,
	[Status_DATE] [date] NOT NULL,
	[CntyFipsAssess_CODE] [char](3) NOT NULL,
	[StateAssess_CODE] [char](2) NOT NULL,
	[Mortgage_INDC] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
 CONSTRAINT [ASRE_I1] PRIMARY KEY CLUSTERED 
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
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique number assigned by the System to the Participants.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Indicates Type of Asset. Values are obtained from REFM (MAST/RELP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Asset_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Unique number generated for Each Asset.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'AssetSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Asset Lot Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'AssetLotNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Identifies the Verification Source Location. Values are obtained from REFM (MAST/SRCE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'SourceLoc_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Asset Book Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'AssetBookNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Asset Page Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'AssetPageNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First Line of the Asset Street Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Line1Asset_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Second Line of the Asset Street Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Line2Asset_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'City of the Asset Location.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'CityAsset_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State of the Asset Location.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'StateAsset_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Country of the Asset Location.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'CountryAsset_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Zip of the Asset Location.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'ZipAsset_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the Asset was purchased.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Purchase_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Value of the Asset.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'ValueAsset_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Lien Holders ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'OthpLien_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether Lien is initiated or not. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'LienInitiated_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mortgage Amount of the Asset.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Mortgage_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Balance Mortgage Amount of the Asset.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'MortgageBalance_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Balance Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Balance_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the Asset was sold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Sold_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Verification Status. Values are obtained from REFM (MAST/VSTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Status_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date on which the Asset was verified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Status_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'FIPS of the Assessed Property. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'CntyFipsAssess_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State of the Assessed Property. Values are obtained from REFM (MAST/ASTA).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'StateAssess_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifier to know whether there is a Mortgage on the Asset. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Mortgage_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Unique Sequence Number that will be generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the asset information of the member''s present in the system. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RealtyAssets_T1'
GO
