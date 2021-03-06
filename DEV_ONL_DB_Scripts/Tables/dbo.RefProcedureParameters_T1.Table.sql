USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'COMMENTS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'Output_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'DataType_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'ParameterPosition_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'Parameter_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'

GO
/****** Object:  Table [dbo].[RefProcedureParameters_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[RefProcedureParameters_T1]
GO
/****** Object:  Table [dbo].[RefProcedureParameters_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefProcedureParameters_T1](
	[Procedure_NAME] [varchar](100) NOT NULL,
	[Parameter_NAME] [varchar](100) NOT NULL,
	[ParameterPosition_NUMB] [numeric](5, 0) NOT NULL,
	[DataType_TEXT] [char](15) NOT NULL,
	[Output_INDC] [char](1) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
 CONSTRAINT [PPRM_I1] PRIMARY KEY CLUSTERED 
(
	[Procedure_NAME] ASC,
	[Parameter_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'This is the Procedure name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'Procedure_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the Procedure Input and Output parameters' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'Parameter_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indentifies Parameter Sequence' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'ParameterPosition_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Data Type of procedure parameters' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'DataType_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'"This Column defines weather the parameter defined in column Name is input or ouput
1-OUTPUT
0-INPUT"' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'Output_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies modified Worker IDNO' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Updated Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'COMMENTS', @value=N'This table stores the details of all inputs and output parameters of all stored procedures which are used to run procedures dynamically in BACTH_GEN_NOTICES. This table contains Proc_Name, Parameter Name, Is_output' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefProcedureParameters_T1'
GO
