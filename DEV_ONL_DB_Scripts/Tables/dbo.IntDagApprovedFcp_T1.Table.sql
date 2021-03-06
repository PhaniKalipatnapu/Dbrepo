USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'MergedPdf_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'MergePdf_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'GeneratePdf_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'Barcode_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Table [dbo].[IntDagApprovedFcp_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IntDagApprovedFcp_T1]
GO
/****** Object:  Table [dbo].[IntDagApprovedFcp_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IntDagApprovedFcp_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[County_IDNO] [numeric](3, 0) NOT NULL,
	[MajorIntSeq_NUMB] [numeric](5, 0) NOT NULL,
	[ActivityMajor_CODE] [char](4) NOT NULL,
	[ReasonStatus_CODE] [char](2) NOT NULL,
	[Barcode_NUMB] [numeric](12, 0) NOT NULL,
	[GeneratePdf_INDC] [char](1) NOT NULL,
	[MergePdf_INDC] [char](1) NOT NULL,
	[MergedPdf_NAME] [char](27) NOT NULL,
 CONSTRAINT [PDAFP_I1] PRIMARY KEY CLUSTERED 
(
	[Barcode_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the Cases in DAG Approved Case Petitions that are generated for the DACSES Case' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Cases in DAG Approved Case Petitions that are generated for the DACSES Case' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The County in which the Case is created. Values are obtained from REFM (RJCT/CNTY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The system generated sequence number for the Remedy and Case / Order combination.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'MajorIntSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Code within the system for the Major Activity. Possible values are ESTP - Establishment Process Activity Chain, MAPP - Motion and Petition Process Activity Chain' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'ActivityMajor_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Reason for updating the current Minor Activity. Values are obtained from REFM (CPRO/REAS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'ReasonStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique ID created by the system while each notice was generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'Barcode_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates that Pdf has been generated. Possible values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'GeneratePdf_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates that Pdf has been merged. Possible values are obtained from REFM (YSNO/YSNO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'MergePdf_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Merged Pdf File Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1', @level2type=N'COLUMN',@level2name=N'MergedPdf_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Table to load DAG approved Case Petitions to be sent to Family Court' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IntDagApprovedFcp_T1'
GO
