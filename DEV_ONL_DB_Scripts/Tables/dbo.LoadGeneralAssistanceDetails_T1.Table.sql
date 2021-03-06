USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'AddrNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadGeneralAssistanceDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadGeneralAssistanceDetails_T1]
GO
/****** Object:  Table [dbo].[LoadGeneralAssistanceDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadGeneralAssistanceDetails_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[AddrNormalization_CODE] [char](1) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LGADT_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the record uniquely.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Welfare Client MCI Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates address normalization status. Values are obtained from REFM (ADDR/NORM).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'AddrNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Client’s address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which file is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the status of the process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the eligible general assistance client details.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadGeneralAssistanceDetails_T1'
GO
