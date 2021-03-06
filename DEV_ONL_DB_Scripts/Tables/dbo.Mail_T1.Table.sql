USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'AlertStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSEQ_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSEQ_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Create_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'TypeAlert_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'PriorityAlert_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'CSW_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'ECM_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Locate_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Enforcement_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Establishment_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Intergovernmental_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'NOT NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Initiation_NUMB'

GO
/****** Object:  Table [dbo].[Mail_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[Mail_T1]
GO
/****** Object:  Table [dbo].[Mail_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Mail_T1](
	[Initiation_NUMB] [numeric](10, 0) NOT NULL,
	[Intergovernmental_NUMB] [numeric](10, 0) NOT NULL,
	[Establishment_NUMB] [numeric](10, 0) NOT NULL,
	[Enforcement_NUMB] [numeric](10, 0) NOT NULL,
	[Locate_NUMB] [numeric](10, 0) NOT NULL,
	[ECM_NUMB] [numeric](10, 0) NOT NULL,
	[CSW_NUMB] [numeric](10, 0) NOT NULL,
	[PriorityAlert_NUMB] [numeric](1, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[ActivityMinor_CODE] [char](5) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[TypeAlert_CODE] [char](5) NOT NULL,
	[Create_DATE] [date] NOT NULL,
	[MajorIntSEQ_NUMB] [numeric](5, 0) NOT NULL,
	[MinorIntSEQ_NUMB] [numeric](5, 0) NOT NULL,
	[AlertStatus_CODE] [char](5) NOT NULL,
 CONSTRAINT [MAIL_I1] PRIMARY KEY CLUSTERED 
(
	[Worker_ID] ASC,
	[PriorityAlert_NUMB] ASC,
	[Create_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'Alert count for Case Initiation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Initiation_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'Alert count for Intergovernmental.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Intergovernmental_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'Alert count for Establishment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Establishment_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'Alert count for Enforcement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Enforcement_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'Alert count for Locate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Locate_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'Alert count for ECM.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'ECM_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'Alert count for CSW.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'CSW_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'This column displays the priority level of the alert.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'PriorityAlert_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'The case id of the member for whom the remedy is being enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'The Code within the system for the Minor Activity. Values are obtained from REFM (WRKL/REFT)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'Stores the worker id who created or modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'The member id for whom the minor activity has been inserted for the remedy enforced.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'It displays the type of an alert. REFM values will be  provided in subsequent Technical designs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'TypeAlert_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'The effective date from which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'Create_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'The system generated sequence number for the Remedy and Case or Order combination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSEQ_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'The system generated sequence number for every new minor activity within the same major activity sequence.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'MinorIntSEQ_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'NOT NULL', @value=N'It displays the status of an alert. REFM values will be  provided in subsequent Technical designs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1', @level2type=N'COLUMN',@level2name=N'AlertStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the details of alerts' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Mail_T1'
GO
