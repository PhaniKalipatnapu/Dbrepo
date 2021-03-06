USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'Obsolete_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorOut_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorIn_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'DescriptionFar_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'RefAssist_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'AutomaticUpdate_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'InfoBlock_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'CollectionBlock_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'OrderBlock_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'ParticipantBlock_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'NcpLocateBlock_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'NcpBlock_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'CaseBlock_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
/****** Object:  Table [dbo].[RefCsenetFarCombinations_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefCsenetFarCombinations_T1]
GO
/****** Object:  Table [dbo].[RefCsenetFarCombinations_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefCsenetFarCombinations_T1](
	[Function_CODE] [char](3) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[Reason_CODE] [char](5) NOT NULL,
	[CaseBlock_QNTY] [numeric](1, 0) NOT NULL,
	[NcpBlock_QNTY] [numeric](1, 0) NOT NULL,
	[NcpLocateBlock_QNTY] [numeric](1, 0) NOT NULL,
	[ParticipantBlock_QNTY] [numeric](1, 0) NOT NULL,
	[OrderBlock_QNTY] [numeric](1, 0) NOT NULL,
	[CollectionBlock_QNTY] [numeric](1, 0) NOT NULL,
	[InfoBlock_QNTY] [numeric](1, 0) NOT NULL,
	[AutomaticUpdate_INDC] [char](1) NOT NULL,
	[RefAssist_CODE] [char](2) NOT NULL,
	[DescriptionFar_TEXT] [varchar](1000) NOT NULL,
	[ActivityMinorIn_CODE] [char](5) NOT NULL,
	[ActivityMinorOut_CODE] [char](5) NOT NULL,
	[Obsolete_INDC] [char](1) NOT NULL,
 CONSTRAINT [CFAR_I1] PRIMARY KEY CLUSTERED 
(
	[Function_CODE] ASC,
	[Action_CODE] ASC,
	[Reason_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Stores the Function code for which this request is made. This is one of the components in the FAR combination. Valid values are available in REFM (INTS/FUNC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Stores the Action code for which this request is made. This is one of the components in the FAR combination. Valid values are available in REFM (INTS/ACTN).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Stores the Reason code for which this request is made. This is one of the components in the FAR combination. Valid values are available in REFM (INTS/FARC).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'Reason_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Case data Block Indicator. 0 indicates no records and any other number indicates the number of records expected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'CaseBlock_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Data Block Indicator. 0 indicates no records and any other number indicates the number of records expected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'NcpBlock_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Locate Block Indicator. 0 indicates no records and any other number indicates the number of records expected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'NcpLocateBlock_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Participant Block Indicator. 0 indicates no records and any other number indicates the number of records expected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'ParticipantBlock_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Order Block Indicator. 0 indicates no records and any other number indicates the number of records expected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'OrderBlock_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Collection Block Indicator. 0 indicates no records and any other number indicates the number of records expected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'CollectionBlock_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'0 indicates no records and any other number indicates the number of records expected.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'InfoBlock_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Systematic Update is there for this FAR Combination. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'AutomaticUpdate_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicator for Referral and Assist/Discovery. Valid values are available in REFM (IMCL/IACT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'RefAssist_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description for FAR Combination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'DescriptionFar_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the minor activity code for an inbound transaction to a given FAR combination. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorIn_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the minor activity code for an outbound transaction to a given FAR combination. Possible values are limited by values in AMNR table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'ActivityMinorOut_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Y if the FAR combination is Obsolete with new Federal standard. Possible values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1', @level2type=N'COLUMN',@level2name=N'Obsolete_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Reference table stores the Valid Function Action Reason combinations along with number of Blocks required, Referral/assist, and Alert information' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetFarCombinations_T1'
GO
