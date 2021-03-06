USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Owner_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'OwnerSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'OwnerPrefixSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'SupLiftRequest_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'OwnerShipType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Business_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Trade_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Business_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'TaxPayor_IDNO'

GO
/****** Object:  Table [dbo].[ExtractDor_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractDor_T1]
GO
/****** Object:  Table [dbo].[ExtractDor_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractDor_T1](
	[Rec_ID] [char](1) NOT NULL,
	[TaxPayor_IDNO] [char](10) NOT NULL,
	[Suffix_NAME] [char](3) NOT NULL,
	[Business_NAME] [char](32) NOT NULL,
	[Trade_NAME] [char](32) NOT NULL,
	[Business_CODE] [char](3) NOT NULL,
	[OwnerShipType_CODE] [char](2) NOT NULL,
	[LicenseNo_TEXT] [char](10) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[SupLiftRequest_DATE] [char](8) NOT NULL,
	[OwnerPrefixSsn_NUMB] [char](1) NOT NULL,
	[OwnerSsn_NUMB] [char](9) NOT NULL,
	[Owner_NAME] [char](32) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Tax payer ID provided by DOR. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'TaxPayor_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' second part of the primary key to Sole proprietor license' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' DOR business name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Business_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' DOR trade name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Trade_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' DOR business code of NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Business_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' DOR ownership type of NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'OwnerShipType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' DOR license number of NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Member Id number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' DOR license suspension lift request date from DACSES for the NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'SupLiftRequest_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' SSN prefix which is always 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'OwnerPrefixSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' NCP SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'OwnerSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Ncp Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1', @level2type=N'COLUMN',@level2name=N'Owner_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Extract Ncp  License Details for Suspension Or Lift' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractDor_T1'
GO
