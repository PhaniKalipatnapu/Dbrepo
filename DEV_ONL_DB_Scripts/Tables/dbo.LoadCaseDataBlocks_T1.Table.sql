USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'CountCdNormalization_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Normalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'NondisclosureFinding_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'PayFipsSub_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'PayFipsCnty_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'PayFipsSt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Fax_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'PhoneExtensionCount_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[LoadCaseDataBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadCaseDataBlocks_T1]
GO
/****** Object:  Table [dbo].[LoadCaseDataBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[LoadCaseDataBlocks_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[TransHeader_IDNO] [char](12) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[Transaction_DATE] [char](8) NOT NULL,
	[TypeCase_CODE] [char](1) NOT NULL,
	[StatusCase_CODE] [char](1) NOT NULL,
	[PaymentLine1Old_ADDR] [char](25) NOT NULL,
	[PaymentLine2Old_ADDR] [char](25) NOT NULL,
	[PaymentCityOld_ADDR] [char](18) NOT NULL,
	[PaymentStateOld_ADDR] [char](2) NOT NULL,
	[PaymentZipOld_ADDR] [char](9) NOT NULL,
	[Last_NAME] [char](21) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](16) NOT NULL,
	[Suffix_NAME] [char](3) NOT NULL,
	[ContactLine1Old_ADDR] [char](25) NOT NULL,
	[ContactLine2Old_ADDR] [char](25) NOT NULL,
	[ContactCityOld_ADDR] [char](18) NOT NULL,
	[ContactStateOld_ADDR] [char](2) NOT NULL,
	[ContactZipOld_ADDR] [char](9) NOT NULL,
	[ContactPhone_NUMB] [char](10) NOT NULL,
	[PhoneExtensionCount_NUMB] [char](6) NOT NULL,
	[RespondingFile_ID] [char](17) NOT NULL,
	[Fax_NUMB] [char](10) NOT NULL,
	[Contact_EML] [char](35) NOT NULL,
	[InitiatingFile_ID] [char](17) NOT NULL,
	[AcctSendPaymentsBankNo_TEXT] [char](20) NOT NULL,
	[SendPaymentsRouting_ID] [char](10) NOT NULL,
	[StateWithCej_CODE] [char](2) NOT NULL,
	[PayFipsSt_CODE] [char](2) NOT NULL,
	[PayFipsCnty_CODE] [char](3) NOT NULL,
	[PayFipsSub_CODE] [char](2) NOT NULL,
	[NondisclosureFinding_INDC] [char](1) NOT NULL,
	[Normalization_CODE] [char](2) NOT NULL,
	[PaymentLine1_ADDR] [varchar](50) NOT NULL,
	[PaymentLine2_ADDR] [varchar](50) NOT NULL,
	[PaymentCity_ADDR] [char](28) NOT NULL,
	[PaymentState_ADDR] [char](2) NOT NULL,
	[PaymentZip_ADDR] [char](10) NOT NULL,
	[CountCdNormalization_QNTY] [char](2) NOT NULL,
	[ContactLine1_ADDR] [varchar](50) NOT NULL,
	[ContactLine2_ADDR] [varchar](50) NOT NULL,
	[ContactCity_ADDR] [char](28) NOT NULL,
	[ContactState_ADDR] [char](2) NOT NULL,
	[ContactZip_ADDR] [char](10) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LCDBL_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The link to the TRANSACTION_HEADER_BLOCK record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Type of case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether a case is open or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The last name of person who should be contacted about the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The first name of person who should be contacted about the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The middle name of person who should be contacted about the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name suffix of person who should be contacted about the case. Ex. III, Jr etc.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Phone Extension of the Contact.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'PhoneExtensionCount_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Fax number of the Contact.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Fax_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Payment-FIPS-County must contain valid FIPS Code numbers based on the jurisdiction table downloaded from the IRG. This always refers to the 3rd, 4th, and 5th digits of your FIPS code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'PayFipsSt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Payment-FIPS-County must contain valid FIPS Code numbers based on the jurisdiction table downloaded from the IRG. This always refers to the 3rd, 4th, and 5th digits of your FIPS code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'PayFipsCnty_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The value of the ''sub'' portion of the FIPS code will not be edited.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'PayFipsSub_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies if case is to be handled confidentially.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'NondisclosureFinding_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator for the Normalized Address to which payments are mailed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Normalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator for the Normalized Address of the Contact.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'CountCdNormalization_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the record is processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a staging table to hold data for Case Data Block and carry out validations for inbound CSENET transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadCaseDataBlocks_T1'
GO
