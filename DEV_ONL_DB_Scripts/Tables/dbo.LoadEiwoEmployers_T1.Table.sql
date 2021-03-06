USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Aka_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'FeinStatus_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'FeinStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Employer_EML'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerPhoneExtension_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Contact_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'IwoStart_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
/****** Object:  Table [dbo].[LoadEiwoEmployers_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadEiwoEmployers_T1]
GO
/****** Object:  Table [dbo].[LoadEiwoEmployers_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadEiwoEmployers_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Fein_IDNO] [char](9) NOT NULL,
	[IwoStart_DATE] [char](10) NOT NULL,
	[Employer_NAME] [varchar](65) NOT NULL,
	[EmployerLine1_ADDR] [char](40) NOT NULL,
	[EmployerLine2_ADDR] [char](40) NOT NULL,
	[EmployerCity_ADDR] [char](25) NOT NULL,
	[EmployerState_ADDR] [char](2) NOT NULL,
	[EmployerZip_ADDR] [char](10) NOT NULL,
	[Contact_NAME] [char](40) NOT NULL,
	[EmployerPhone_NUMB] [char](10) NOT NULL,
	[EmployerPhoneExtension_NUMB] [char](5) NOT NULL,
	[Employer_EML] [varchar](65) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[AlternateLine1_ADDR] [char](40) NOT NULL,
	[AlternateLine2_ADDR] [char](40) NOT NULL,
	[AlternateCity_ADDR] [char](25) NOT NULL,
	[AlternateState_ADDR] [char](2) NOT NULL,
	[AlternateZip_ADDR] [char](10) NOT NULL,
	[FeinStatus_CODE] [char](1) NOT NULL,
	[FeinStatus_DATE] [char](10) NOT NULL,
	[Aka_NAME] [varchar](65) NOT NULL,
 CONSTRAINT [LEEMP_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer/withholder''s FEIN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which e-IWO starts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'IwoStart_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer outreach or customer service contact name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line 1 of the employer outreach or customer service contact''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line 2 of the employer outreach or customer service contact''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer outreach or customer service contact''s city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer outreach or customer service contact''s State code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer outreach or customer service contact ZIP Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Business contact full name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Contact_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer contact phone number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer contact phone number Extension.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'EmployerPhoneExtension_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer contact e-mail address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Employer_EML'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer''s optional Line1 Address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer''s optional Line2 Address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer''s optional City ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer''s optional State' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer''s optional Zip' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'AlternateZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Fein Status Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'FeinStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Fein Inactive date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'FeinStatus_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Organization Alias Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1', @level2type=N'COLUMN',@level2name=N'Aka_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used in BATCH_ENF_EIWO_UPDATES batch to load the e-IWO FEIN file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoEmployers_T1'
GO
