USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'DentalIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'NULL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'MedicalIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'DependantMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'

GO
/****** Object:  Table [dbo].[ApreDins_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ApreDins_T1]
GO
/****** Object:  Table [dbo].[ApreDins_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApreDins_T1](
	[Application_IDNO] [numeric](15, 0) NOT NULL,
	[MemberMCI_IDNO] [numeric](10, 0) NOT NULL,
	[DependantMci_IDNO] [numeric](10, 0) NOT NULL,
	[MedicalIns_INDC] [char](1) NOT NULL,
	[DentalIns_INDC] [char](1) NOT NULL,
 CONSTRAINT [APDI_I1] PRIMARY KEY CLUSTERED 
(
	[Application_IDNO] ASC,
	[MemberMCI_IDNO] ASC,
	[DependantMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the system assigned number to the application' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the system assigned number to the Member' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Identifies the system assigned number to the Dependent for whom the insurance is provided' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'DependantMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates whether the Participant is eligible for Medical Insurance. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'MedicalIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'NULL', @value=N'Indicates whether the Participant is eligible for Dental Insurance. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1', @level2type=N'COLUMN',@level2name=N'DentalIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Tables stores the Dependent Details that are associated with the Insurance provided   by the CP/NCP/Third Party given at time of Application.  This table stores valid records as   well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreDins_T1'
GO
