USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'NewOrderFlag_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OfLastPayment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalOrdered_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Medical_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalThru_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalFrom_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCare_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCareThru_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCareFrom_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdcThru_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdcFrom_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdc_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdcThru_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdcFrom_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderArrearsTotal_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FreqOrderArrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FreqOrderArrears_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderCancel_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderEnd_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderEffective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderFreq_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderFreq_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'DebtType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FilingOrder_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'SubFipsOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CntyFipsOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'StFipsOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'

GO
/****** Object:  Table [dbo].[LoadOrderBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadOrderBlocks_T1]
GO
/****** Object:  Table [dbo].[LoadOrderBlocks_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[LoadOrderBlocks_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[TransHeader_IDNO] [char](12) NOT NULL,
	[IVDOutOfStateFips_CODE] [char](2) NOT NULL,
	[Transaction_DATE] [char](8) NOT NULL,
	[BlockSeq_NUMB] [char](2) NOT NULL,
	[StFipsOrder_CODE] [char](2) NOT NULL,
	[CntyFipsOrder_CODE] [char](3) NOT NULL,
	[SubFipsOrder_CODE] [char](2) NOT NULL,
	[Order_IDNO] [char](17) NOT NULL,
	[FilingOrder_DATE] [char](8) NOT NULL,
	[TypeOrder_CODE] [char](1) NOT NULL,
	[DebtType_CODE] [char](2) NOT NULL,
	[OrderFreq_CODE] [char](1) NOT NULL,
	[OrderFreq_AMNT] [char](12) NOT NULL,
	[OrderEffective_DATE] [char](8) NOT NULL,
	[OrderEnd_DATE] [char](8) NOT NULL,
	[OrderCancel_DATE] [char](8) NOT NULL,
	[FreqOrderArrears_CODE] [char](1) NOT NULL,
	[FreqOrderArrears_AMNT] [char](12) NOT NULL,
	[OrderArrearsTotal_AMNT] [char](12) NOT NULL,
	[ArrearsAfdcFrom_DATE] [char](8) NOT NULL,
	[ArrearsAfdcThru_DATE] [char](8) NOT NULL,
	[ArrearsAfdc_AMNT] [char](12) NOT NULL,
	[ArrearsNonAfdcFrom_DATE] [char](8) NOT NULL,
	[ArrearsNonAfdcThru_DATE] [char](8) NOT NULL,
	[ArrearsNonAfdc_AMNT] [char](12) NOT NULL,
	[FosterCareFrom_DATE] [char](8) NOT NULL,
	[FosterCareThru_DATE] [char](8) NOT NULL,
	[FosterCare_AMNT] [char](12) NOT NULL,
	[MedicalFrom_DATE] [char](8) NOT NULL,
	[MedicalThru_DATE] [char](8) NOT NULL,
	[Medical_AMNT] [char](12) NOT NULL,
	[MedicalOrdered_INDC] [char](1) NOT NULL,
	[TribunalCaseNo_TEXT] [char](17) NOT NULL,
	[OfLastPayment_DATE] [char](8) NOT NULL,
	[ControllingOrderFlag_CODE] [char](1) NOT NULL,
	[NewOrderFlag_INDC] [char](1) NOT NULL,
	[File_ID] [char](17) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL
) ON [PRIMARY]
SET ANSI_PADDING ON
ALTER TABLE [dbo].[LoadOrderBlocks_T1] ADD [Process_INDC] [char](1) NOT NULL
 CONSTRAINT [LOBLK_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The link to the TRANSACTION_HEADER_BLOCK record that holds the corresponding CSENet Transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TransHeader_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State FIPS for the state with which you are communicating.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'IVDOutOfStateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Transaction Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Transaction_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the occurrence of the number of orders received in the file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'BlockSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State in which the order was established. The Order-FIPS-State field must contain valid FIPS codes based on the jurisdiction table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'StFipsOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County in which the order was established. The Order-FIPS-County field must contain valid FIPS codes based on the jurisdiction table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'CntyFipsOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The value of the "sub" portion of the FIPS code will not be edited.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'SubFipsOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The order ID refers to the local identification assigned to this order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date that the order was established.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FilingOrder_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the type of support order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the type of debt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'DebtType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the frequency of payment. This field is required if the Order-Freq-Amount is greater than zero.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderFreq_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The dollar amount owed per each frequency above.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderFreq_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date that obligations start to accrue.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderEffective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date that the obligations terminate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderEnd_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date that the order was canceled.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderCancel_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the frequency of arrears payment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FreqOrderArrears_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The dollar amount that must be paid to arrears at the frequency ordered.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FreqOrderArrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of the arrears.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OrderArrearsTotal_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Order-Arrears-Total-Amount can equal zero dollars.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdcFrom_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start date of the period to which the TANF arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdcThru_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the period to which the TANF arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsAfdc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of the TANF arrears balance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdcFrom_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start date of the period to which the Non-TANF arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdcThru_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the period to which the Non-TANF arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'ArrearsNonAfdc_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of the Non-TANF arrears balance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCareFrom_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start date of the period to which the Foster Care arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCareThru_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the period to which the Foster Care arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'FosterCare_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The start date of the period to which the medical arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalFrom_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the period to which the medical arrears apply.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalThru_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The total dollar amount of the Foster Care arrears balance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Medical_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Medical coverage was ordered. Required for EST and ENF Responses. Also required for PAT Responses if the order type is not equal to P.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'MedicalOrdered_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of the last payment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'OfLastPayment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the New Order Flag.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'NewOrderFlag_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if the record is processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a staging table to hold data for Order Data Block and carry out validations for inbound CSENET transaction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadOrderBlocks_T1'
GO
