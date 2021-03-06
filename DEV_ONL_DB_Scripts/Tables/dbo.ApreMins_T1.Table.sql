USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'DentalMonthlyPremium_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'DentalOthpIns_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'DentalPolicyInsNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'MedicalMonthlyPremium_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'MedicalPolicyInsNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'MedicalOthpIns_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'

GO
/****** Object:  Table [dbo].[ApreMins_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ApreMins_T1]
GO
/****** Object:  Table [dbo].[ApreMins_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApreMins_T1](
	[Application_IDNO] [numeric](15, 0) NOT NULL,
	[MemberMCI_IDNO] [numeric](10, 0) NOT NULL,
	[MedicalOthpIns_IDNO] [numeric](9, 0) NOT NULL,
	[MedicalPolicyInsNo_TEXT] [char](20) NOT NULL,
	[MedicalMonthlyPremium_AMNT] [numeric](11, 2) NOT NULL,
	[DentalPolicyInsNo_TEXT] [char](20) NOT NULL,
	[DentalOthpIns_IDNO] [numeric](9, 0) NOT NULL,
	[DentalMonthlyPremium_AMNT] [numeric](11, 2) NOT NULL,
 CONSTRAINT [APMI_I1] PRIMARY KEY CLUSTERED 
(
	[Application_IDNO] ASC,
	[MemberMCI_IDNO] ASC,
	[MedicalOthpIns_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the system assigned number to the application' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the system assigned number to the Member' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Identifies the system assigned number to the Other Party' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'MedicalOthpIns_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant Medical policy number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'MedicalPolicyInsNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Amount Paid Monthly towards the Medical Insurance Premium' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'MedicalMonthlyPremium_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Participant is eligible for Medical Insurance' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'DentalPolicyInsNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Participant is eligible for Dental Insurance' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'DentalOthpIns_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Amount Paid Monthly towards the Dental Insurance Premium.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1', @level2type=N'COLUMN',@level2name=N'DentalMonthlyPremium_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the Member Insurance details of the Client that is given at time of Application. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreMins_T1'
GO
