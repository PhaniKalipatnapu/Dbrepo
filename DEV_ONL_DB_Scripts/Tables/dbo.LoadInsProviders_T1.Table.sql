USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyLocation_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyCarrier_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Normalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Phone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'ZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'StateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'CityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Line2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Line1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'

GO
/****** Object:  Table [dbo].[LoadInsProviders_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadInsProviders_T1]
GO
/****** Object:  Table [dbo].[LoadInsProviders_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadInsProviders_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Employer_NAME] [varchar](45) NOT NULL,
	[Line1Old_ADDR] [char](25) NOT NULL,
	[Line2Old_ADDR] [char](25) NOT NULL,
	[CityOld_ADDR] [char](20) NOT NULL,
	[StateOld_ADDR] [char](2) NOT NULL,
	[ZipOld_ADDR] [char](15) NOT NULL,
	[Phone_NUMB] [char](10) NOT NULL,
	[Normalization_CODE] [char](1) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
	[InsCompanyCarrier_CODE] [char](5) NOT NULL,
	[InsCompanyLocation_CODE] [char](4) NOT NULL,
 CONSTRAINT [LIPRO_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Insurance Company name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Employer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address Line 1 of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Line1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address Line 2 of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Line2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address City of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'CityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address State of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'StateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address ZIP code of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'ZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The phone number of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Phone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies address normalization status. Possible values are N - NORMALIZED U - UNNORMALIZED I - INVALID INPUT ADDRESS Z - INVALID INPUT ZIP S - INVALID INPUT STATE C - INVALID INPUT CITY F - ADDRESS NOT FOUND M - MULTIPLE MATCH FOUND D - DECLINED BY USER.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Normalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address Line 1 of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address Line 2 of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address City of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address State of the Insurance Company. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address ZIP code of the Insurance Company.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the record is processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance Company Carrier Code  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyCarrier_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Insurance Company Location Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1', @level2type=N'COLUMN',@level2name=N'InsCompanyLocation_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used in BATCH_ENF_INCOMING_MEDICAID_TPL - MPT Load and Process batch programs to load Medical Provider data into DECSS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadInsProviders_T1'
GO
