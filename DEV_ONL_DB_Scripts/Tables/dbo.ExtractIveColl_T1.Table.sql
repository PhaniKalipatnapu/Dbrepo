USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'COMMENT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherCollected_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherCollected_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherPid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherCollected_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherCollected_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherPid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'Dependant_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'DependantSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'DependantPid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'DependantMCI_IDNO'

GO
/****** Object:  Table [dbo].[ExtractIveColl_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractIveColl_T1]
GO
/****** Object:  Table [dbo].[ExtractIveColl_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractIveColl_T1](
	[DependantMCI_IDNO] [char](10) NOT NULL,
	[DependantPid_IDNO] [char](10) NOT NULL,
	[DependantSsn_NUMB] [char](9) NOT NULL,
	[Dependant_NAME] [char](24) NOT NULL,
	[MotherCase_IDNO] [char](10) NOT NULL,
	[MotherMCI_IDNO] [char](10) NOT NULL,
	[MotherPid_IDNO] [char](10) NOT NULL,
	[MotherCollected_AMNT] [char](12) NOT NULL,
	[MotherCollected_DATE] [char](8) NOT NULL,
	[FatherCase_IDNO] [char](10) NOT NULL,
	[FatherMCI_IDNO] [char](10) NOT NULL,
	[FatherPid_IDNO] [char](10) NOT NULL,
	[FatherCollected_AMNT] [char](12) NOT NULL,
	[FatherCollected_DATE] [char](8) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is  Child''s MCI number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'DependantMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is Child''s Foster Care PID number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'DependantPid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is Child''s SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'DependantSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is Child''s truncated full name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'Dependant_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is  Mother''s Case Id Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is Mother''s MCI Id Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is Mother''s Foster Care PID Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherPid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Amount collected from Mother' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherCollected_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Date on which the amount collected from the Mother' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'MotherCollected_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is Father''s Case Id Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is Father''s MCI Id Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is Father''s PID Id Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherPid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the amount collected from Father' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherCollected_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the Date on which the amount collected from the Father' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1', @level2type=N'COLUMN',@level2name=N'FatherCollected_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'COMMENT', @value=N'This table is used to store the detailed collection information and it will be used to extract output file to IVE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIveColl_T1'
GO
