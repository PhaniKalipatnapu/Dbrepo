USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'PreEdit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'Iwn_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'ActualNonTanfArrear_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'ActualTanfArrear_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'NonTanfArrear_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'TanfArrear_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
/****** Object:  Table [dbo].[ArrearCertAmountIrs_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ArrearCertAmountIrs_T1]
GO
/****** Object:  Table [dbo].[ArrearCertAmountIrs_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ArrearCertAmountIrs_T1](
	[MemberMci_IDNO] [numeric](10, 0) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[TanfArrear_AMNT] [numeric](11, 2) NOT NULL,
	[NonTanfArrear_AMNT] [numeric](11, 2) NOT NULL,
	[ActualTanfArrear_AMNT] [numeric](11, 2) NOT NULL,
	[ActualNonTanfArrear_AMNT] [numeric](11, 2) NOT NULL,
	[Iwn_INDC] [char](1) NOT NULL,
	[PreEdit_CODE] [char](2) NOT NULL,
	[County_IDNO] [numeric](3, 0) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [IRSA_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[MemberMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The ID value of the MCI generated uniquely by the system for which the exemptions are stored.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'SSN of the member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the TANF arrears for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'TanfArrear_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the NON-TANF arrears for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'NonTanfArrear_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the actual TANF arrears for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'ActualTanfArrear_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the actual NON TANF arrears for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'ActualNonTanfArrear_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the Income Withholding Indicator for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'Iwn_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the pre exclusion reason code for the case. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'PreEdit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will store the County number for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to calculate the arrears to be submitted for the IRS. Also this tables stores the Pre exclusion reason code for the member' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ArrearCertAmountIrs_T1'
GO
