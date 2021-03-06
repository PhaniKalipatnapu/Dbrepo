USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntFcrTransKeys_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntFcrTransKeys_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntFcrTransKeys_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntFcrTransKeys_T1', @level2type=N'COLUMN',@level2name=N'TransType_CODE'

GO
/****** Object:  Table [dbo].[IntFcrTransKeys_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntFcrTransKeys_T1]
GO
/****** Object:  Table [dbo].[IntFcrTransKeys_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntFcrTransKeys_T1](
	[TransType_CODE] [char](2) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies transaction type. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntFcrTransKeys_T1', @level2type=N'COLUMN',@level2name=N'TransType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the IVD Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntFcrTransKeys_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A unique number assigned to each participant in the system.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntFcrTransKeys_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used as a intermediate table in BATCH_LOC_EXT_FCR package to store Transaction key values.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntFcrTransKeys_T1'
GO
