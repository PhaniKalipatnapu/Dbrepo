USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'DescriptionComments_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'InState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'Csenet_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'InboundOutbound_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'Field_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'Block_NAME'

GO
/****** Object:  Table [dbo].[RefConvertCsenetCodes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefConvertCsenetCodes_T1]
GO
/****** Object:  Table [dbo].[RefConvertCsenetCodes_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefConvertCsenetCodes_T1](
	[Block_NAME] [varchar](50) NOT NULL,
	[Field_NAME] [varchar](70) NOT NULL,
	[InboundOutbound_CODE] [char](1) NOT NULL,
	[Csenet_CODE] [char](20) NOT NULL,
	[InState_CODE] [char](20) NOT NULL,
	[DescriptionComments_TEXT] [varchar](50) NOT NULL,
 CONSTRAINT [CSEC_I1] PRIMARY KEY CLUSTERED 
(
	[Block_NAME] ASC,
	[Field_NAME] ASC,
	[InboundOutbound_CODE] ASC,
	[Csenet_CODE] ASC,
	[InState_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Block name that requires the conversion.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'Block_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Field name that requires the conversion with in the  block.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'Field_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'To identify the conversion required for   inbound or outbound transactions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'InboundOutbound_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'This field is used to indicate the value of CSENET code that needs to be transformed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'Csenet_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'This field is used to indicate the DACSES code that needs to be transformed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'InState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Remarks.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1', @level2type=N'COLUMN',@level2name=N'DescriptionComments_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This reference table is used to convert CSENET codes to NJ codes for incoming transactions and vice versa for outgoing transactions' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefConvertCsenetCodes_T1'
GO
