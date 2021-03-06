USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'Misc_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'ReasonAction_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'TypeEft_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'Generate_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
/****** Object:  Index [DERR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [DERR_I1] ON [dbo].[DsbhEftInfoError_T1]
GO
/****** Object:  Table [dbo].[DsbhEftInfoError_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[DsbhEftInfoError_T1]
GO
/****** Object:  Table [dbo].[DsbhEftInfoError_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DsbhEftInfoError_T1](
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[Generate_DATE] [date] NOT NULL,
	[TypeEft_CODE] [char](1) NOT NULL,
	[ReasonAction_CODE] [char](3) NOT NULL,
	[Misc_ID] [char](11) NOT NULL,
	[EventGlobalSeq_NUMB] [numeric](19, 0) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DERR_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [DERR_I1] ON [dbo].[DsbhEftInfoError_T1]
(
	[CheckRecipient_ID] ASC,
	[CheckRecipient_CODE] ASC,
	[EventGlobalSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the check recipient type. Possible values are 1 - MCI of the member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the date the EFT generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'Generate_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the type of EFT that was sent. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'TypeEft_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The reason code for the EFT information’s current status. Possible values will be determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'ReasonAction_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This is the reference NO to give unique identification to an EFT transfer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'Misc_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Global Event Sequence number of the Event that caused this transaction.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a log table that stores the information on the EFT or Stored Value Card or Promote rejects from the Bank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DsbhEftInfoError_T1'
GO
