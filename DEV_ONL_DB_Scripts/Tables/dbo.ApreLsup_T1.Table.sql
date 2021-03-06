USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'Paid_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'Owed_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'YearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'

GO
/****** Object:  Table [dbo].[ApreLsup_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ApreLsup_T1]
GO
/****** Object:  Table [dbo].[ApreLsup_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApreLsup_T1](
	[Application_IDNO] [numeric](15, 0) NOT NULL,
	[MemberMCI_IDNO] [numeric](10, 0) NOT NULL,
	[YearMonth_NUMB] [numeric](6, 0) NOT NULL,
	[Owed_AMNT] [numeric](11, 2) NOT NULL,
	[Paid_AMNT] [numeric](11, 2) NOT NULL,
 CONSTRAINT [ALSP_I1] PRIMARY KEY CLUSTERED 
(
	[Application_IDNO] ASC,
	[MemberMCI_IDNO] ASC,
	[YearMonth_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the system assigned number to the application' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the system assigned number to the Member' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Year and month of the payments that the CP has received directly from the NCP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'YearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount that was owed to the CP for the corresponding month' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'Owed_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount that was paid in the corresponding month' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1', @level2type=N'COLUMN',@level2name=N'Paid_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores the List of payments directly received from other agencies during the time of application submission.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreLsup_T1'
GO
