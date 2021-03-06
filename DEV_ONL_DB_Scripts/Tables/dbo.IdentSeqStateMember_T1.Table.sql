USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqStateMember_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqStateMember_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqStateMember_T1', @level2type=N'COLUMN',@level2name=N'MemberSeq_IDNO'

GO
/****** Object:  Table [dbo].[IdentSeqStateMember_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IdentSeqStateMember_T1]
GO
/****** Object:  Table [dbo].[IdentSeqStateMember_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IdentSeqStateMember_T1](
	[MemberSeq_IDNO] [numeric](10, 0) IDENTITY(-1,-1) NOT NULL,
	[Entered_DATE] [date] NOT NULL,
 CONSTRAINT [IMEMB_I1] PRIMARY KEY CLUSTERED 
(
	[MemberSeq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'System assigned number to uniquely identify a member who doesn''t exist in DECSS. Identity seed is equal to -1 and  is decremented by 1. The range of values will be (minus 1) to (minus 7,999,999,999).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqStateMember_T1', @level2type=N'COLUMN',@level2name=N'MemberSeq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The date on which the new negative sequence number was generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqStateMember_T1', @level2type=N'COLUMN',@level2name=N'Entered_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Used to generate temporary Member Mci numbers for Members in tables APAG_Y1, APCM_Y1, APDM_Y1,  
APDI_Y1, APEH_Y1, ALSP_Y1, APMH_Y1, APMI_Y1, APSR_Y1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentSeqStateMember_T1'
GO
