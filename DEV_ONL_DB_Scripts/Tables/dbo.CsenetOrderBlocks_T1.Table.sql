USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'NewOrderFlag_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ControllingOrderFlag_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OfLastPayment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TribunalCaseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalOrdered_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Medical_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalThru_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalFrom_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCare_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCareThru_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCareFrom_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdcThru_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdcFrom_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdcThru_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdcFrom_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderArrearsTotal_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FreqOrderArrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FreqOrderArrears_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderCancel_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderEnd_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderEffective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderFreq_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderFreq_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'DebtType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FilingOrder_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CsenetOrder_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'SubFipsOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CntyFipsOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'StFipsOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[CsenetOrderBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CsenetOrderBlocks_T1]
GO
/****** Object:  Table [dbo].[CsenetOrderBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CsenetOrderBlocks_T1](
	[TransHeader_IDNO] [numeric](12, 0) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[Transaction_DATE] [date] NOT NULL,
	[BlockSeq_NUMB] [numeric](2, 0) NOT NULL,
	[StFipsOrder_CODE] [char](2) NOT NULL,
	[CntyFipsOrder_CODE] [char](3) NOT NULL,
	[SubFipsOrder_CODE] [char](2) NOT NULL,
	[CsenetOrder_ID] [char](17) NOT NULL,
	[FilingOrder_DATE] [date] NOT NULL,
	[TypeOrder_CODE] [char](1) NOT NULL,
	[DebtType_CODE] [char](2) NOT NULL,
	[OrderFreq_CODE] [char](1) NOT NULL,
	[OrderFreq_AMNT] [numeric](11, 2) NOT NULL,
	[OrderEffective_DATE] [date] NOT NULL,
	[OrderEnd_DATE] [date] NOT NULL,
	[OrderCancel_DATE] [date] NOT NULL,
	[FreqOrderArrears_CODE] [char](1) NOT NULL,
	[FreqOrderArrears_AMNT] [numeric](11, 2) NOT NULL,
	[OrderArrearsTotal_AMNT] [numeric](11, 2) NOT NULL,
	[ArrearsAfdcFrom_DATE] [date] NOT NULL,
	[ArrearsAfdcThru_DATE] [date] NOT NULL,
	[ArrearsAfdc_AMNT] [numeric](11, 2) NOT NULL,
	[ArrearsNonAfdcFrom_DATE] [date] NOT NULL,
	[ArrearsNonAfdcThru_DATE] [date] NOT NULL,
	[ArrearsNonAfdc_AMNT] [numeric](11, 2) NOT NULL,
	[FosterCareFrom_DATE] [date] NOT NULL,
	[FosterCareThru_DATE] [date] NOT NULL,
	[FosterCare_AMNT] [numeric](11, 2) NOT NULL,
	[MedicalFrom_DATE] [date] NOT NULL,
	[MedicalThru_DATE] [date] NOT NULL,
	[Medical_AMNT] [numeric](11, 2) NOT NULL,
	[MedicalOrdered_INDC] [char](1) NOT NULL,
	[TribunalCaseNo_TEXT] [char](17) NOT NULL,
	[OfLastPayment_DATE] [date] NOT NULL,
	[ControllingOrderFlag_CODE] [char](1) NOT NULL,
	[NewOrderFlag_INDC] [char](1) NOT NULL,
	[File_ID] [char](15) NOT NULL,
 CONSTRAINT [CORB_I1] PRIMARY KEY CLUSTERED 
(
	[TransHeader_IDNO] ASC,
	[IVDOutOfStateFips_CODE] ASC,
	[Transaction_DATE] ASC,
	[BlockSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'The link to the TRANSACTION_HEADER_BLOCK record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'State FIPS for the state with which you are communicating. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'This is the occurrence of the number of orders received in the file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State in which the order was established. The Order-FIPS-State field must contain valid FIPS codes based on the jurisdiction table. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'StFipsOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County in which the order was established. The Order-FIPS-County field must contain valid FIPS codes based on the jurisdiction table. Possible values are limited by values in FIPS table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CntyFipsOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The value of the sub portion of the FIPS code will not be edited. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'SubFipsOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The order ID refers to the local identification assigned to this order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CsenetOrder_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date that the order was established.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FilingOrder_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the type of support order. Values are obtained from REFM (CSEN/CORD).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the type of debt. Values are obtained from REFM (CSEN/DBTY).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'DebtType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the frequency of payment. This field is required if the Order-Freq-Amount is greater than zero. Possible values are W for Weekly, B for Biweekly, S for Semi-Monthly, M for Monthly, Q for Quarterly, E for Semi-annually, A for Annually.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderFreq_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The dollar amount owed per each frequency above.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderFreq_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date that obligations start to accrue.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderEffective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date that the obligations terminate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderEnd_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date that the order was canceled.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderCancel_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the frequency of arrears payment. Values are obtained from REFM (FRQA/FRQ1).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FreqOrderArrears_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The dollar amount that must be paid to arrears at the frequency ordered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FreqOrderArrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of the arrears. The Order-Arrears-Total-Amount can equal zero dollars.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderArrearsTotal_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start date of the period to which the TANF arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdcFrom_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the period to which the TANF arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdcThru_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of the TANF arrears balance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start date of the period to which the Non-TANF arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdcFrom_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the period to which the Non-TANF arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdcThru_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of the Non-TANF arrears balance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start date of the period to which the Foster Care arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCareFrom_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the period to which the Foster Care arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCareThru_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of the Foster Care arrears balance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCare_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start date of the period to which the medical arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalFrom_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the period to which the medical arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalThru_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of medical arrears.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Medical_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Medical coverage was ordered. Required for EST and ENF Responses. Also required for PAT Responses if the order type is not equal to P. Valid values for this field are Y for Medical Coverage Ordered and N for Medical Coverage Not Ordered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalOrdered_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Tribunal Case Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TribunalCaseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of the last payment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OfLastPayment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the order is presumed or determined. Values are retrieved from REFM (CTRL/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ControllingOrderFlag_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator to denote whether it''s a New Order. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'NewOrderFlag_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Docket ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table hold data for Order Data Block  for incoming and outgoing CSENET transactions' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CsenetOrderBlocks_T1'
GO
