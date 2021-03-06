USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'Defra_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'DefraYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'Grant_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'GrantYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadTanfGrant_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadTanfGrant_T1]
GO
/****** Object:  Table [dbo].[LoadTanfGrant_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadTanfGrant_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[CaseWelfare_IDNO] [char](10) NOT NULL,
	[GrantYearMonth_NUMB] [char](8) NOT NULL,
	[Grant_AMNT] [char](9) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[DefraYearMonth_NUMB] [char](6) NOT NULL,
	[Defra_AMNT] [char](9) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LTGRA_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'System assigned number to uniquely identify a record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Welfare Case ID, Created at CP level when any one dependent of the CP is in welfare program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Grant year month of the Welfare Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'GrantYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'TANF Grant amount issued for that month.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'Grant_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies CP MCI number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the Defra year month of the Welfare Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'DefraYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will be used to store the DEFRA amount on the welfare case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'Defra_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Date file was loaded into the table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Loads the TANF grant payments of that current month into table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfGrant_T1'
GO
