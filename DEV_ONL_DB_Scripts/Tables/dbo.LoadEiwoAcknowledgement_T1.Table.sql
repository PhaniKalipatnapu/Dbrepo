USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'MultiIWOState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'CorrectFein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'MultipleError_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'SecondError_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'FirstError_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'PhoneNcp_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'DescriptionLumpSumPay_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'LumpSumPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'LumpSumPay_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'ZipNewEmployer_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'StateNewEmployer_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'CityNewEmployer_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Line2NewEmployer_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Line1NewEmployer_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'NewEmployer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'FinalPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'FinalPayment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'ZipNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'StateNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'CityNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Line2Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Line1Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Termination_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'RejReason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Disp_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'DocTrackNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'SuffixNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'DocumentAction_CODE'

GO
/****** Object:  Table [dbo].[LoadEiwoAcknowledgement_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadEiwoAcknowledgement_T1]
GO
/****** Object:  Table [dbo].[LoadEiwoAcknowledgement_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadEiwoAcknowledgement_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[DocumentAction_CODE] [char](3) NOT NULL,
	[Case_IDNO] [char](15) NOT NULL,
	[Fein_IDNO] [char](9) NOT NULL,
	[LastNcp_NAME] [char](20) NOT NULL,
	[FirstNcp_NAME] [char](15) NOT NULL,
	[MiddleNcp_NAME] [char](15) NOT NULL,
	[SuffixNcp_NAME] [char](4) NOT NULL,
	[NcpSsn_NUMB] [char](9) NOT NULL,
	[DocTrackNo_TEXT] [char](30) NOT NULL,
	[Order_IDNO] [char](30) NOT NULL,
	[Disp_CODE] [char](2) NOT NULL,
	[RejReason_CODE] [char](3) NOT NULL,
	[Termination_DATE] [char](8) NOT NULL,
	[Line1Ncp_ADDR] [char](25) NOT NULL,
	[Line2Ncp_ADDR] [char](25) NOT NULL,
	[CityNcp_ADDR] [char](22) NOT NULL,
	[StateNcp_ADDR] [char](2) NOT NULL,
	[ZipNcp_ADDR] [char](9) NOT NULL,
	[FinalPayment_DATE] [char](8) NOT NULL,
	[FinalPay_AMNT] [char](11) NOT NULL,
	[NewEmployer_NAME] [varchar](57) NOT NULL,
	[Line1NewEmployer_ADDR] [char](25) NOT NULL,
	[Line2NewEmployer_ADDR] [char](25) NOT NULL,
	[CityNewEmployer_ADDR] [char](22) NOT NULL,
	[StateNewEmployer_ADDR] [char](2) NOT NULL,
	[ZipNewEmployer_ADDR] [char](9) NOT NULL,
	[LumpSumPay_DATE] [char](8) NOT NULL,
	[LumpSumPay_AMNT] [char](11) NOT NULL,
	[DescriptionLumpSumPay_TEXT] [char](35) NOT NULL,
	[PhoneNcp_NUMB] [char](10) NOT NULL,
	[FirstError_NAME] [char](32) NOT NULL,
	[SecondError_NAME] [char](32) NOT NULL,
	[MultipleError_CODE] [char](1) NOT NULL,
	[CorrectFein_IDNO] [char](9) NOT NULL,
	[MultiIWOState_CODE] [char](2) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LEACK_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the type of IWO document
AMD - Amended
LUM - Lump Sum
ORG - Original
TRM - Termination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'DocumentAction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Case ID associated with the record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer/withholder''s FEIN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Fein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP first name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP middle name or initial.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP name suffix.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'SuffixNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Social Security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'NcpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A number assigned by the entity sending the document that uniquely identifies the document' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'DocTrackNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A unique identifier that is associated with a specific child support obligation within a case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Order_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether a record was accepted or rejected by the employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Disp_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The reason an e-IWO record was rejected by an employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'RejReason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date that an employee left or was terminated by an employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Termination_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line1 of NCP address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Line1Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line2 of NCP address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Line2Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP City address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'CityNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP State address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'StateNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Zip Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'ZipNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date of the final payment sent to the SDU.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'FinalPayment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount of the final payment sent to the SDU.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'FinalPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer outreach or customer service contact name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'NewEmployer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line 1 of the employer outreach or customer service contact''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Line1NewEmployer_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line 2 of the employer outreach or customer service contact''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Line2NewEmployer_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer outreach or customer service contact''s city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'CityNewEmployer_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer outreach or customer service contact''s State code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'StateNewEmployer_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Employer outreach or customer service contact ZIP Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'ZipNewEmployer_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date an employer anticipates that a Lump Sum Payment will be disbursed to an employee.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'LumpSumPay_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'An amount the employer intends to issue as a Lump Sum Payment to the employee.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'LumpSumPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The type of Lump Sum Payment that will be disbursed to an employee.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'DescriptionLumpSumPay_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Phone Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'PhoneNcp_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the first field that did not pass the e-IWO edits.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'FirstError_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Name of the second field that did not pass the e-IWO edits.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'SecondError_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates that a record has more than two errors.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'MultipleError_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the actual FEIN under which the employee is working.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'CorrectFein_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the state code for instances in which an employer already has an IWO in place for the employee, and the IWO just received is a duplicate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'MultiIWOState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if processed otherwise N.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used in BATCH_ENF_EIWO_UPDATES batch to load the e-IWO acknowledgement file.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadEiwoAcknowledgement_T1'
GO
