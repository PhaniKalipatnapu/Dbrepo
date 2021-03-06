USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqApplication_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqApplication_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqApplication_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[IdentSeqApplication_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IdentSeqApplication_T1]
GO
/****** Object:  Table [dbo].[IdentSeqApplication_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IdentSeqApplication_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Entered_DATE] [date] NOT NULL
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqApplication_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqApplication_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Used to generate an internal sequence number in tables APAG_Y1, APCM_Y1, APDM_Y1, APDI_Y1, APEH_Y1, APIN_Y1, ALSP_Y1, APMC_Y1, APMH_Y1, APMI_Y1, APSR_Y1, CASE_Y1, WLOG_Y1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqApplication_T1'
GO
