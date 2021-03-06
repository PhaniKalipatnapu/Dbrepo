USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'MediumDisburse_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'CheckReplace_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'Worker_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'Disburse_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'StatusCheck_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'Disburse_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'

GO
/****** Object:  Table [dbo].[TmpChkvPopUp_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[TmpChkvPopUp_P1]
GO
/****** Object:  Table [dbo].[TmpChkvPopUp_P1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TmpChkvPopUp_P1](
	[Check_NUMB] [numeric](19, 0) NOT NULL,
	[Disburse_DATE] [date] NOT NULL,
	[StatusCheck_CODE] [char](2) NOT NULL,
	[Disburse_AMNT] [numeric](11, 2) NOT NULL,
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[Worker_ID] [char](30) NOT NULL,
	[CheckReplace_NUMB] [numeric](13, 0) NOT NULL,
	[MediumDisburse_CODE] [char](1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'TheCheck Number that has been sent to the Fund Receipient for this Disbursement process happened on this day.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'Check_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The actual date when Payment is sent to the Fund Recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'Disburse_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is an Internal identifier to monitor the status of the checks Issued by the system to the check Recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'StatusCheck_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Amount sent to check recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'Disburse_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the check recipient type.Valid Values are as follows:1 - MCI of the member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the DACSES worker.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'Worker_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The check number of the physical check that was issued to the check Reciepient as a replacement, against the original check if the original is voded or Stop payment issued..' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'CheckReplace_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is an Indicator for how payment are made check , Electronic Deposit or Store Value Card..' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1', @level2type=N'COLUMN',@level2name=N'MediumDisburse_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is global temporary table that is used to store and display information on the Disbursement tracking details from the DSBV screen for each disbursement' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TmpChkvPopUp_P1'
GO
