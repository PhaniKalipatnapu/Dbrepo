USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'WelfareCaseCounty_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'ChildEligibility_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'SubProgram_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'Program_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'ChildMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadTanfTermination_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadTanfTermination_T1]
GO
/****** Object:  Table [dbo].[LoadTanfTermination_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadTanfTermination_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[CaseWelfare_IDNO] [char](10) NOT NULL,
	[CpMci_IDNO] [char](10) NOT NULL,
	[NcpMci_IDNO] [char](10) NOT NULL,
	[ChildMci_IDNO] [char](10) NOT NULL,
	[Program_CODE] [char](3) NOT NULL,
	[SubProgram_CODE] [char](1) NOT NULL,
	[AgSequence_NUMB] [char](4) NOT NULL,
	[ChildEligibility_DATE] [char](8) NOT NULL,
	[WelfareCaseCounty_IDNO] [char](3) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LTNFT_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies record uniquely.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Welfare Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Cp MCI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Ncp MCI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'NcpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Child MCI.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'ChildMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Program code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'Program_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Sub Program code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'SubProgram_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates DSS Assistance Group Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'AgSequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Child eligibility date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'ChildEligibility_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates welfare case county code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'WelfareCaseCounty_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which file is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the status of the process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Loads the TANF termination records into table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadTanfTermination_T1'
GO
