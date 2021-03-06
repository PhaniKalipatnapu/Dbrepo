USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Fax_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Phone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'SendDisbursement_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Sdu_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'UresaUifsa_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'CostRecovery_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Csenet_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'FeeCharge_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Country_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'ContactTitle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Fips_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'SubTypeAddress_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'TypeAddress_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'OfficeFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'

GO
/****** Object:  Index [FIPS_StateFips_CODE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [FIPS_StateFips_CODE_I1] ON [dbo].[RefFipsCodes_T1]
GO
/****** Object:  Table [dbo].[RefFipsCodes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefFipsCodes_T1]
GO
/****** Object:  Table [dbo].[RefFipsCodes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefFipsCodes_T1](
	[Fips_CODE] [char](7) NOT NULL,
	[StateFips_CODE] [char](2) NOT NULL,
	[CountyFips_CODE] [char](3) NOT NULL,
	[OfficeFips_CODE] [char](2) NOT NULL,
	[TypeAddress_CODE] [char](3) NOT NULL,
	[SubTypeAddress_CODE] [char](3) NOT NULL,
	[Fips_NAME] [char](40) NOT NULL,
	[ContactTitle_NAME] [char](40) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Country_ADDR] [char](2) NOT NULL,
	[FeeCharge_INDC] [char](1) NOT NULL,
	[Csenet_INDC] [char](1) NOT NULL,
	[CostRecovery_INDC] [char](1) NOT NULL,
	[UresaUifsa_CODE] [char](1) NOT NULL,
	[Sdu_INDC] [char](1) NOT NULL,
	[SendDisbursement_INDC] [char](1) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
	[Phone_NUMB] [numeric](15, 0) NOT NULL,
	[Fax_NUMB] [numeric](15, 0) NOT NULL,
 CONSTRAINT [FIPS_I1] PRIMARY KEY CLUSTERED 
(
	[Fips_CODE] ASC,
	[TypeAddress_CODE] ASC,
	[SubTypeAddress_CODE] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [FIPS_StateFips_CODE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [FIPS_StateFips_CODE_I1] ON [dbo].[RefFipsCodes_T1]
(
	[StateFips_CODE] ASC,
	[CountyFips_CODE] ASC,
	[OfficeFips_CODE] ASC,
	[EndValidity_DATE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Federal Information Processing Standard code of the state. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Fips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'FIPS State codes to be referenced for intergovernmental case locations.  Values are obtained from REFM (FIPS/STCD)  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County FIPS Code. Values are obtained from REFM (OTHP/CNTY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'CountyFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'FIPS office code as defined in Federal Information Processing Standards. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'OfficeFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Indicates the type of the FIPS. Values are obtained from REFM (CSEN/FIPT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'TypeAddress_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Indicates the sub type of the address under the above type. Values are obtained from REFM (CSEN/FFIP, CSEN/IFIP, CSEN/LFIP, and CSEN/SFIP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'SubTypeAddress_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Fips_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Contact Person at the Other State.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'ContactTitle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS Address Line1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS Address Line2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS City.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS State. Values are obtained from REFM (STAT/CANA, STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS Country. Values are obtained from REFM (CTRY/CTRY).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Country_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator to know whether the Fee is charged. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'FeeCharge_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator to know whether the FIPS State accepts CSENet Transaction. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Csenet_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator to know whether the Cost Recovery is involved. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'CostRecovery_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'URSEA or UIFSA Transmittal code. Values are obtained from REFM (IMCL/UIFS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'UresaUifsa_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the corresponding FIPS code receives payment or not. All State Fips code will have Y. All county FIPS will have N. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Sdu_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This indicates if disbursements can be sent to this County or not. Sometimes, due to an error or if the receiving state cannot receive any checks, DACSES should be able to stop payments on a temporary basis. Disbursement will check for this field. If it is Y, it will allow the check to be processed, if not, it will put on hold. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'SendDisbursement_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information is Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Unique Sequence Number that will be  generated for a Transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS Zip.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS Phone number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Phone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the FIPS Fax Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1', @level2type=N'COLUMN',@level2name=N'Fax_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the details on the Federal Information Processing Standards (FIPS) code for all the state and international child support offices. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefFipsCodes_T1'
GO
