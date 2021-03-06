USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadStateQuarterlyWage_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadStateQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadStateQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadStateQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
/****** Object:  Table [dbo].[LoadStateQuarterlyWage_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadStateQuarterlyWage_T1]
GO
/****** Object:  Table [dbo].[LoadStateQuarterlyWage_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[LoadStateQuarterlyWage_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](2) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](16) NOT NULL,
	[Last_NAME] [char](30) NOT NULL,
	[Wage_AMNT] [char](11) NOT NULL,
	[YearQtr_NUMB] [char](5) NOT NULL,
	[Fein_IDNO] [char](9) NOT NULL,
	[Sein_IDNO] [char](12) NOT NULL,
	[Employer_NAME] [varchar](45) NOT NULL,
	[EmployerLine1Old_ADDR] [char](40) NOT NULL,
	[EmployerLine2Old_ADDR] [char](40) NOT NULL,
	[EmployerLine3Old_ADDR] [char](40) NOT NULL,
	[EmployerCityOld_ADDR] [char](25) NOT NULL,
	[EmployerStateOld_ADDR] [char](2) NOT NULL,
	[EmployerZip1Old_ADDR] [char](5) NOT NULL,
	[EmployerZip2Old_ADDR] [char](4) NOT NULL,
	[ForeignEmployerCountry_ADDR] [char](2) NOT NULL,
	[ForeignEmployer_NAME] [char](25) NOT NULL,
	[ForeignEmployerZip_ADDR] [char](15) NOT NULL,
	[EmployerOptionalLine1_ADDR] [char](40) NOT NULL,
	[EmployerOptionalLine2_ADDR] [char](40) NOT NULL,
	[EmployerOptionalLine3_ADDR] [char](40) NOT NULL,
	[EmployerOptionalCity_ADDR] [char](25) NOT NULL,
	[EmployerOptionalState_ADDR] [char](2) NOT NULL,
	[EmployerOptionalZip1_ADDR] [char](5) NOT NULL,
	[EmployerOptionalZip2_ADDR] [char](4) NOT NULL,
	[EmployerOptionalCountry_ADDR] [char](2) NOT NULL,
	[ForeignEmployerOptional_NAME] [char](25) NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [ForeignEmployerOptionalZip_ADDR] [char](15) NOT NULL
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [LocationNormalization_CODE] [char](1) NOT NULL
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [EmployerLine1_ADDR] [varchar](50) NOT NULL
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [EmployerLine2_ADDR] [varchar](50) NOT NULL
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [EmployerLine3_ADDR] [varchar](50) NOT NULL
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [EmployerCity_ADDR] [char](28) NOT NULL
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [EmployerState_ADDR] [char](2) NOT NULL
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [EmployerZip1_ADDR] [char](15) NOT NULL
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [EmployerZip2_ADDR] [char](15) NOT NULL
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [FileLoad_DATE] [date] NOT NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[LoadStateQuarterlyWage_T1] ADD [Process_INDC] [char](1) NOT NULL
 CONSTRAINT [LSQWA_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employee First name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadStateQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employee Last Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadStateQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the record is processed or not' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadStateQuarterlyWage_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Table is the temporary load table which holds the employee quarterly wage information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadStateQuarterlyWage_T1'
GO
