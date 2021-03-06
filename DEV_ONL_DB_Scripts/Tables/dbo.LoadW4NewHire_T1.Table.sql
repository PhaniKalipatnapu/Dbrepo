USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'NormalizationEmployer_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Normalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCountryZip_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCountry_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCountry_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployeeCountryZip_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployeeCountry_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployeeCountry_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'FederalTaxVerification_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'FederalTaxType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Employer_Name'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'StateHire_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'LeftEmpTemp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Hire_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Zip2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Zip1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'StateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'CityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Line2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Line1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Last_Name'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadW4NewHire_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadW4NewHire_T1]
GO
/****** Object:  Table [dbo].[LoadW4NewHire_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadW4NewHire_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](1) NOT NULL,
	[Last_Name] [char](15) NOT NULL,
	[First_NAME] [char](15) NOT NULL,
	[Middle_NAME] [char](1) NOT NULL,
	[Line1Old_ADDR] [char](30) NOT NULL,
	[Line2Old_ADDR] [char](30) NOT NULL,
	[CityOld_ADDR] [char](15) NOT NULL,
	[StateOld_ADDR] [char](2) NOT NULL,
	[Zip1Old_ADDR] [char](5) NOT NULL,
	[Zip2Old_ADDR] [char](4) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[Hire_DATE] [char](8) NOT NULL,
	[LeftEmpTemp_INDC] [char](1) NOT NULL,
	[Birth_DATE] [char](8) NOT NULL,
	[MemberSex_CODE] [char](1) NOT NULL,
	[StateHire_CODE] [char](2) NOT NULL,
	[Employer_Name] [char](30) NOT NULL,
	[EmployerLine1Old_ADDR] [char](30) NOT NULL,
	[EmployerLine2Old_ADDR] [char](30) NOT NULL,
	[EmployerCityOld_ADDR] [char](15) NOT NULL,
	[EmployerStateOld_ADDR] [char](2) NOT NULL,
	[EmployerZip1Old_ADDR] [char](5) NOT NULL,
	[EmployerZip2Old_ADDR] [char](4) NOT NULL,
	[Fein_IDNO] [char](9) NOT NULL,
	[FederalTaxType_CODE] [char](1) NOT NULL,
	[FederalTaxVerification_CODE] [char](1) NOT NULL,
	[Batch_NUMB] [char](9) NOT NULL,
	[EmployeeCountry_CODE] [char](2) NOT NULL,
	[EmployeeCountry_NAME] [char](25) NOT NULL,
	[EmployeeCountryZip_CODE] [char](15) NOT NULL,
	[EmployerCountry_CODE] [char](2) NOT NULL,
	[EmployerCountry_NAME] [char](25) NOT NULL,
	[EmployerCountryZip_CODE] [char](15) NOT NULL,
	[Normalization_CODE] [char](1) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
	[NormalizationEmployer_CODE] [char](1) NOT NULL,
	[EmployerLine1_ADDR] [varchar](50) NOT NULL,
	[EmployerLine2_ADDR] [varchar](50) NOT NULL,
	[EmployerCity_ADDR] [char](28) NOT NULL,
	[EmployerState_ADDR] [char](2) NOT NULL,
	[EmployerZip_ADDR] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LW4NH_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This is a unique number to uniquely identify a record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Detail record type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Last_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire first name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire middle name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Line1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Line2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'CityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'StateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First 5 digits of new hire address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Zip1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last 4 digits new hire address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Zip2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of hiring.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Hire_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Left temporary employment indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'LeftEmpTemp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire sex code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'New hire state of work.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'StateHire_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Employer_Name'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer address line1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer address line2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First 5 digits of employer address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Last 4 digits employer address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer identification number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Federal  tax type code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'FederalTaxType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Federal tax verification code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'FederalTaxVerification_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Division of child support enforcement provided batch id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Batch_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employee country code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployeeCountry_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employee country name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployeeCountry_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employee country zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployeeCountryZip_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer country code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCountry_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer country name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCountry_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer country zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCountryZip_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Normalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized line 1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized line 2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer address normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'NormalizationEmployer_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized employer line 1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized employer line 2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized employer city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized employer state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized employer zip code address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'EmployerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which file is loaded.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the status of the process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'The process loads the W4 New Hire Data file into the temporary table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadW4NewHire_T1'
GO
