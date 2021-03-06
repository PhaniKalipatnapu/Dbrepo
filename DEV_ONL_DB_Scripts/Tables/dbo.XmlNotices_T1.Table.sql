USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'XmlNotices_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'XmlNotices_T1', @level2type=N'COLUMN',@level2name=N'Xml_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'XmlNotices_T1', @level2type=N'COLUMN',@level2name=N'Barcode_NUMB'

GO
/****** Object:  Table [dbo].[XmlNotices_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[XmlNotices_T1]
GO
/****** Object:  Table [dbo].[XmlNotices_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XmlNotices_T1](
	[Barcode_NUMB] [numeric](12, 0) NOT NULL,
	[Xml_TEXT] [varchar](max) NOT NULL,
 CONSTRAINT [NXML_I1] PRIMARY KEY CLUSTERED 
(
	[Barcode_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'A unique no. stored in this field which is generated in the process of notice generation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'XmlNotices_T1', @level2type=N'COLUMN',@level2name=N'Barcode_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Object to store the notice generation data in the xml format.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'XmlNotices_T1', @level2type=N'COLUMN',@level2name=N'Xml_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores the values of the data elements in an XML format that have to be displayed for each notice that are in pending status or waiting to be printed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'XmlNotices_T1'
GO
