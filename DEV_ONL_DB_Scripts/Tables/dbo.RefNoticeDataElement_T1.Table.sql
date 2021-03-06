USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'OptionParentSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'ElementGroupMinRequired_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'ElementGroup_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'ParentSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'4' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Input_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'ElementGroupMaxRequired_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Format_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Mask_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Required_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'NoPointerDpKey_QNTY'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Seq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'TypeElement_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Element_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'

GO
/****** Object:  Index [NDEL_ID_NOTICE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [NDEL_ID_NOTICE_I1] ON [dbo].[RefNoticeDataElement_T1]
GO
/****** Object:  Table [dbo].[RefNoticeDataElement_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefNoticeDataElement_T1]
GO
/****** Object:  Table [dbo].[RefNoticeDataElement_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefNoticeDataElement_T1](
	[Notice_ID] [char](8) NOT NULL,
	[Element_NAME] [varchar](100) NOT NULL,
	[TypeElement_CODE] [char](5) NOT NULL,
	[Seq_NUMB] [numeric](11, 0) NOT NULL,
	[NoPointerDpKey_QNTY] [numeric](5, 0) NOT NULL,
	[Required_INDC] [char](1) NOT NULL,
	[Mask_INDC] [char](1) NOT NULL,
	[Format_CODE] [char](10) NOT NULL,
	[ElementGroupMaxRequired_NUMB] [numeric](5, 0) NOT NULL,
	[Procedure_NAME] [varchar](100) NOT NULL,
	[Input_CODE] [char](1) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[ParentSeq_NUMB] [numeric](5, 0) NOT NULL,
	[ElementGroup_NUMB] [numeric](2, 0) NULL,
	[ElementGroupMinRequired_NUMB] [numeric](5, 0) NULL,
	[OptionParentSeq_NUMB] [numeric](5, 0) NULL,
 CONSTRAINT [NDEL_I1] PRIMARY KEY CLUSTERED 
(
	[Notice_ID] ASC,
	[Element_NAME] ASC,
	[TypeElement_CODE] ASC,
	[Input_CODE] ASC,
	[ParentSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [NDEL_ID_NOTICE_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [NDEL_ID_NOTICE_I1] ON [dbo].[RefNoticeDataElement_T1]
(
	[Procedure_NAME] ASC
)
INCLUDE ( 	[Notice_ID],
	[Seq_NUMB]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique id assigned to the notices.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Notice_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Name of the data elements related to the notices.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Element_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'3', @value=N'Shows the type element name. Possible values are CP or NCP.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'TypeElement_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Used to get the data element.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Seq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Used to derive the values for the particular name element from another name element i.e. Mapped with seq no.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'NoPointerDpKey_QNTY'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether particular data element is needed to generate notice or not, values are obtained from REFM(YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Required_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether this data element has to be masked (redacted) on the form sent to this recipient if the case is a Family violence case, values are obtained from REFM(YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Mask_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Shows display format of the name element. Possible values are DATE, PHONE, AMT, SSN, ZIP. ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Format_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Maximum number of elements required in a group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'ElementGroupMaxRequired_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Contains the name of the procedure from which the respective data element values are coming.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'4', @value=N'Indicator used to specify whether the data element is a IN parameter or OUT, values are obtained from REFM(PARM/FILE)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Input_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the seq number for  element list parent in all notices.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'ParentSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies group number for set of options in notices.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'ElementGroup_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Minimun number of elements required in a group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'ElementGroupMinRequired_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Parent Seq Number of option' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1', @level2type=N'COLUMN',@level2name=N'OptionParentSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is a reference table to store the data elements used or derived for a given notice. All rows in this table are valid' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefNoticeDataElement_T1'
GO
