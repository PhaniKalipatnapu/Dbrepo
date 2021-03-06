USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'ParentIveParty_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Parent_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'WorkPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Worker_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'FatherTprDecision_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'FatherTpr_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MotherTprDecision_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MotherTpr_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Determination_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Determination_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Removal_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'FatherCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MotherCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'IveParty_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadIveUpdate_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadIveUpdate_T1]
GO
/****** Object:  Table [dbo].[LoadIveUpdate_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadIveUpdate_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](1) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[IveParty_IDNO] [char](10) NOT NULL,
	[MotherCase_IDNO] [char](10) NOT NULL,
	[FatherCase_IDNO] [char](10) NOT NULL,
	[Removal_DATE] [char](8) NOT NULL,
	[Determination_DATE] [char](8) NOT NULL,
	[Determination_CODE] [char](1) NOT NULL,
	[MotherTpr_INDC] [char](1) NOT NULL,
	[MotherTprDecision_DATE] [char](8) NOT NULL,
	[FatherTpr_INDC] [char](1) NOT NULL,
	[FatherTprDecision_DATE] [char](8) NOT NULL,
	[Worker_NAME] [char](40) NOT NULL,
	[WorkPhone_NUMB] [char](10) NOT NULL,
	[Parent_NAME] [char](40) NOT NULL,
	[ParentIveParty_IDNO] [char](10) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[Birth_DATE] [char](8) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LFIVE_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies uniquely the loaded IV-E agency data' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Detail Record Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies Child MCI number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies Child Foster care PID number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'IveParty_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies Mother Case number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MotherCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies Father Case number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'FatherCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Removal date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Removal_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Determination Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Determination_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Determination code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Determination_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates termination of parental rights for Mother.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MotherTpr_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Mother termination parental rights date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MotherTprDecision_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates termination of parental rights for Father.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'FatherTpr_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Father termination of parental rights date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'FatherTprDecision_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Worker name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Worker_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Worker phone number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'WorkPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Mother name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Parent_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Identifies Parent PID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'ParentIveParty_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Mother SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Mother DOB' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'The date on which incoming file from IV-E agency is loaded' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates the process status.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Read incoming files from IV-E agency and loads into  temporary table in DACSES.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveUpdate_T1'
GO
