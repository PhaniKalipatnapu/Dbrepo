USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportCounty_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportEffective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportPayingFrequency_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupport_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'SupportOrderedCourt_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportOrderExists_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'PersonRepresentChildAsOwn_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'PaternityAcknowledgment_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'

GO
/****** Object:  Table [dbo].[ApreSord_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ApreSord_T1]
GO
/****** Object:  Table [dbo].[ApreSord_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApreSord_T1](
	[Application_IDNO] [numeric](15, 0) NOT NULL,
	[MemberMCI_IDNO] [numeric](10, 0) NOT NULL,
	[PaternityAcknowledgment_INDC] [char](1) NOT NULL,
	[PersonRepresentChildAsOwn_INDC] [char](1) NOT NULL,
	[ChildSupportOrderExists_INDC] [char](1) NOT NULL,
	[SupportOrderedCourt_TEXT] [char](40) NOT NULL,
	[ChildSupport_AMNT] [numeric](11, 2) NOT NULL,
	[ChildSupportPayingFrequency_CODE] [char](1) NOT NULL,
	[ChildSupportEffective_DATE] [date] NOT NULL,
	[ChildSupportCounty_NAME] [char](40) NOT NULL,
	[ChildSupportState_CODE] [char](2) NOT NULL,
 CONSTRAINT [APSR_I1] PRIMARY KEY CLUSTERED 
(
	[Application_IDNO] ASC,
	[MemberMCI_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the system assigned number to the application.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the system assigned number to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if voluntary Acknowledgement of Paternity signed. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'PaternityAcknowledgment_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if paternity has not been established, during the first two years of the child’s life, whether any man continuously live with the child and represent the child as his own. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'PersonRepresentChildAsOwn_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if there is an existing child support order for this child. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportOrderExists_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court where the order was signed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'SupportOrderedCourt_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Financial amount of the court order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupport_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Frequency ordered by court for child support payment. Values are obtained from REFM (FRQA/FRQ3)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportPayingFrequency_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Effective date of the court order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportEffective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County where the order was signed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportCounty_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State where the order was signed. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1', @level2type=N'COLUMN',@level2name=N'ChildSupportState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores support order details, which are collected on behalf of child.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreSord_T1'
GO
