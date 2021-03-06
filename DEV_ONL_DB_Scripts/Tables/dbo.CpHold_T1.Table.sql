USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'Sequence_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'Expiration_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'ReasonHold_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'

GO
/****** Object:  Table [dbo].[CpHold_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[CpHold_T1]
GO
/****** Object:  Table [dbo].[CpHold_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CpHold_T1](
	[CheckRecipient_ID] [char](10) NOT NULL,
	[CheckRecipient_CODE] [char](1) NOT NULL,
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[ReasonHold_CODE] [char](4) NOT NULL,
	[Effective_DATE] [date] NOT NULL,
	[Expiration_DATE] [date] NOT NULL,
	[EventGlobalBeginSeq_NUMB] [numeric](19, 0) NOT NULL,
	[EventGlobalEndSeq_NUMB] [numeric](19, 0) NOT NULL,
	[BeginValidity_DATE] [date] NOT NULL,
	[EndValidity_DATE] [date] NOT NULL,
	[Sequence_NUMB] [numeric](11, 0) NOT NULL,
 CONSTRAINT [CHLD_I1] PRIMARY KEY CLUSTERED 
(
	[CheckRecipient_CODE] ASC,
	[CheckRecipient_ID] ASC,
	[EventGlobalBeginSeq_NUMB] ASC,
	[ReasonHold_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'MCI of the member who received the disbursement check when the CD_TYPE_RECIPIENT = 1, OR the State Payment FIPS Code of the State that received the disbursement check when the CD_TYPE_RECIPIENT = 2, OR the OTHP ID of the entity that received the disbursement.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the check recipient type. Possible values are 1 - MCI of the Member 2 - State Payment FIPS Code of the State 3 - Other Party ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'CheckRecipient_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The IVD case specific to the disbursement hold for the CP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Identifies the reason code for the hold. Values are queried in REFM with ID_TABLE = DHLD, ID_TABLE_SUB = DHLD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'ReasonHold_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The effective date of the hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'Effective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The end date of the Hold.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'Expiration_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'The Global Event Sequence number for the corresponding DT_BEG_VALIDITY.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalBeginSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Global Event Sequence number for the corresponding DT_END_VALIDITY. This should be zero when the corresponding DT_END_VALIDITY is a high date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'EventGlobalEndSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date from when the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'BeginValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Effective date up to which the Changed Information will be Valid.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'EndValidity_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The sequential number identifying the number of holds for one CP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1', @level2type=N'COLUMN',@level2name=N'Sequence_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the manual disbursement hold instruction for a check recipient entered  by the user from HLDI screen. This table stores valid records as well as history records which follows the temporal model structure.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CpHold_T1'
GO
