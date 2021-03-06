USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'6' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'ValidationSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Remarks_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'ComplexValidation_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'ColumnValidation_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'5' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'IoDirection_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'CsenetField_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Column_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Table_NAME'

GO
/****** Object:  Table [dbo].[RefCsenetValidations_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefCsenetValidations_T1]
GO
/****** Object:  Table [dbo].[RefCsenetValidations_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefCsenetValidations_T1](
	[Table_NAME] [char](30) NOT NULL,
	[Column_NAME] [varchar](70) NOT NULL,
	[CsenetField_TEXT] [varchar](50) NOT NULL,
	[IoDirection_CODE] [char](1) NOT NULL,
	[Function_CODE] [char](3) NOT NULL,
	[Action_CODE] [char](1) NOT NULL,
	[ColumnValidation_CODE] [char](1) NOT NULL,
	[ComplexValidation_TEXT] [varchar](1000) NOT NULL,
	[Remarks_TEXT] [varchar](328) NOT NULL,
	[ValidationSeq_NUMB] [numeric](2, 0) NOT NULL,
 CONSTRAINT [CVAL_I1] PRIMARY KEY CLUSTERED 
(
	[Table_NAME] ASC,
	[Column_NAME] ASC,
	[IoDirection_CODE] ASC,
	[Function_CODE] ASC,
	[Action_CODE] ASC,
	[ValidationSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Block table name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Table_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Block table column name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Column_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'CSENET field name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'CsenetField_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'IN /OUT transaction direction. Possible values are I or O.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'IoDirection_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Function code. This is a reference table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Function_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'5', @value=N'Action code. This is a reference table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Action_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Validation required or not. Possible values will be  determined in the subsequent technical design.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'ColumnValidation_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Validation condition for this field.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'ComplexValidation_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Description.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'Remarks_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'6', @value=N'Sequence number for  Validation conditions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1', @level2type=N'COLUMN',@level2name=N'ValidationSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This Reference table is used to carry out transaction validations at  Data block/Function/Action level' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefCsenetValidations_T1'
GO
