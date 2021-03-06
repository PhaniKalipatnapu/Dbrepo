USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingAptOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Billing_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Phone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceAptNoOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Title_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'HeaderSeq_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadPudm_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadPudm_T1]
GO
/****** Object:  Table [dbo].[LoadPudm_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadPudm_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[HeaderSeq_IDNO] [numeric](19, 0) NOT NULL,
	[Rec_ID] [char](2) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[Last_NAME] [char](13) NOT NULL,
	[First_NAME] [char](9) NOT NULL,
	[Middle_NAME] [char](1) NOT NULL,
	[Title_NAME] [char](1) NOT NULL,
	[ServiceLine1Old_ADDR] [char](31) NOT NULL,
	[ServiceAptNoOld_ADDR] [char](5) NOT NULL,
	[ServiceLine2Old_ADDR] [char](31) NOT NULL,
	[ServiceCityOld_ADDR] [char](16) NOT NULL,
	[ServiceStateOld_ADDR] [char](2) NOT NULL,
	[ServiceZipOld_ADDR] [char](9) NOT NULL,
	[Phone_NUMB] [char](10) NOT NULL,
	[Billing_NAME] [char](24) NOT NULL,
	[BillingLine1Old_ADDR] [char](31) NOT NULL,
	[BillingAptOld_ADDR] [char](5) NOT NULL,
	[BillingLine2Old_ADDR] [char](31) NOT NULL,
	[BillingCityOld_ADDR] [char](16) NOT NULL,
	[BillingStateOld_ADDR] [char](2) NOT NULL,
	[BillingZipOld_ADDR] [char](9) NOT NULL,
	[BillingPhone_NUMB] [char](10) NOT NULL,
	[Employer_NAME] [char](31) NOT NULL,
	[EmployerLine1Old_ADDR] [char](31) NOT NULL,
	[EmployerLine2Old_ADDR] [char](31) NOT NULL,
	[EmployerCityOld_ADDR] [char](16) NOT NULL,
	[EmployerStateOld_ADDR] [char](2) NOT NULL,
	[EmployerZipOld_ADDR] [char](9) NOT NULL,
	[EmployerPhone_NUMB] [char](10) NOT NULL,
	[ServiceAddressNormalization_CODE] [char](1) NOT NULL,
	[ServiceLine1_ADDR] [varchar](50) NOT NULL,
	[ServiceLine2_ADDR] [varchar](50) NOT NULL,
	[ServiceCity_ADDR] [char](28) NOT NULL,
	[ServiceState_ADDR] [char](2) NOT NULL,
	[ServiceZip_ADDR] [char](15) NOT NULL,
	[BillingAddressNormalization_CODE] [char](1) NOT NULL,
	[BillingLine1_ADDR] [varchar](50) NOT NULL,
	[BillingLine2_ADDR] [varchar](50) NOT NULL,
	[BillingCity_ADDR] [char](28) NOT NULL,
	[BillingState_ADDR] [char](2) NOT NULL,
	[BillingZip_ADDR] [char](15) NOT NULL,
	[EmployerAddressNormalization_CODE] [char](1) NOT NULL,
	[EmployerLine1_ADDR] [varchar](50) NOT NULL,
	[EmployerLine2_ADDR] [varchar](50) NOT NULL,
	[EmployerCity_ADDR] [char](28) NOT NULL,
	[EmployerState_ADDR] [char](2) NOT NULL,
	[EmployerZip_ADDR] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LPUDM_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies a record  uniquely.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Header sequence number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'HeaderSeq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Detail record type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Owner’‘s MCI number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s first name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s middle name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s title name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Title_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service line1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service apt No address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceAptNoOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service line2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service phone address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Phone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Billing_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing line1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s apt # address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingAptOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing line2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing phone number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'owner’‘s employer name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s employer line1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s employer line2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s employer city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s employer state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s employer zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s employer phone number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service address normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service line1 address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service apt No address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service city address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service state address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s service zip code address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'ServiceZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing address normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing line1 address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing apt No address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing city address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing state address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s billing zip code address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'BillingZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s Employer address normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s Employer line1 address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s Employer apt No address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s Employer city address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s Employer state address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Owner’‘s Employer zip code address normalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which incoming file from PUDM is loaded' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the process status.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Temporary load table contains all the DACSES NCP''s of locate match receieved from PUDM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadPudm_T1'
GO
