USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Request_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Exclusion_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Issued_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'ProcessYear_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'LocalTransfer_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'StateTransfer_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'TypeTransaction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'StateSubmit_CODE'

GO
/****** Object:  Table [dbo].[ExtractIrsNcps_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ExtractIrsNcps_T1]
GO
/****** Object:  Table [dbo].[ExtractIrsNcps_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtractIrsNcps_T1](
	[StateSubmit_CODE] [char](2) NOT NULL,
	[County_IDNO] [char](3) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[Case_IDNO] [char](15) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[First_NAME] [char](15) NOT NULL,
	[Arrears_AMNT] [char](8) NOT NULL,
	[TypeTransaction_CODE] [char](1) NOT NULL,
	[TypeCase_CODE] [char](1) NOT NULL,
	[StateTransfer_CODE] [char](2) NOT NULL,
	[LocalTransfer_CODE] [char](3) NOT NULL,
	[ProcessYear_NUMB] [char](4) NOT NULL,
	[Line1_ADDR] [char](30) NOT NULL,
	[Line2_ADDR] [char](30) NOT NULL,
	[City_ADDR] [char](25) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](9) NOT NULL,
	[Issued_DATE] [char](8) NOT NULL,
	[Exclusion_CODE] [char](40) NOT NULL,
	[Request_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the submitting state code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'StateSubmit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the county to which the case is assigned.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the NCP participants social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Case ID associated with the record being viewed on the CASE Screen.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last name of the NCP participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the first name of the NCP participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Total arrear amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'A - Add/Certify Case B - Name Change C - Case Id Change D - Delete Case L - Local Code Change M - Arrear Amount Change R - Replace Exclusion Indicator Change S - State Payment T - Transfer for Administrative Review Z - Address Change.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'TypeTransaction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the type of case. A - Tanf, N - Non Tanf.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the transfer state code that was sent to OCSE by the state on the case submission and update record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'StateTransfer_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the transfer local code that was sent to OCSE by the state on the case submission and update record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'LocalTransfer_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Tax Year.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'ProcessYear_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address Line 1 of the NCP''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address Line 2 of the NCP''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address City of the NCP''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address State of the NCP''s address. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address ZIP code of the NCP''s address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Issue Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Issued_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'ADM - Administrative Offset,RET - Exclude Federal Retirement Offset, VEN - Exclude Vendor Payment/ Miscellneaous Offset, SAL - Exclude Federal Salary Offset, TAX - IRS Tax, PAS - Passport Denial, FIN - MS FIDM, DCK - Exclude Debt Check.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Exclusion_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field will indicate the pre-offset notice request.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1', @level2type=N'COLUMN',@level2name=N'Request_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used in BATCH_ENF_EXT_IRS to extract NCPs to IRS for FOP programs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtractIrsNcps_T1'
GO
