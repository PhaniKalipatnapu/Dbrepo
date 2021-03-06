USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error5_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error4_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error3_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error2_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error1_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Received_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Transmitted_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Reject_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[FcrPendingRejects_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FcrPendingRejects_T1]
GO
/****** Object:  Table [dbo].[FcrPendingRejects_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FcrPendingRejects_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Reject_CODE] [char](1) NOT NULL,
	[Transmitted_DATE] [date] NOT NULL,
	[Received_DATE] [date] NOT NULL,
	[Error1_CODE] [char](5) NOT NULL,
	[Error2_CODE] [char](5) NOT NULL,
	[Error3_CODE] [char](5) NOT NULL,
	[Error4_CODE] [char](5) NOT NULL,
	[Error5_CODE] [char](5) NOT NULL,
 CONSTRAINT [FPRJ_I1] PRIMARY KEY CLUSTERED 
(
	[Action_CODE] ASC,
	[Case_IDNO] ASC,
	[MemberMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique identifier for case of Participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique identifier for a Participant in a case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'identifies action code. Possible values are A for Add, C for Change, D for Delete, L for Locate and T for Terminate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies reject indicator. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Reject_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies date transmitted.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Transmitted_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies date received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Received_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies error code1. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error1_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies error code2. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error2_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies error code3. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error3_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies error code4. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error4_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies error code5. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1', @level2type=N'COLUMN',@level2name=N'Error5_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to store the FCR rejects (transaction level).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FcrPendingRejects_T1'
GO
