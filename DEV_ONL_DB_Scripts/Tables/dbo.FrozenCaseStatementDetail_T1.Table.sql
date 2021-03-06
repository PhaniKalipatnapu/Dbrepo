USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[FrozenCaseStatementDetail_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[FrozenCaseStatementDetail_T1]
GO
/****** Object:  Table [dbo].[FrozenCaseStatementDetail_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FrozenCaseStatementDetail_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[DetailHeader_TEXT] [varchar](115) NOT NULL,
	[Transaction_Date] [date] NOT NULL,
	[TransactionType_CODE] [char](4) NOT NULL,
	[DetailNotes_TEXT] [varchar](240) NOT NULL,
	[FromAccount_NUMB] [numeric](6, 0) NOT NULL,
	[ToAccount_NUMB] [numeric](6, 0) NOT NULL,
	[ToType_CODE] [char](4) NOT NULL,
	[ToAccount_NAME] [char](16) NOT NULL,
	[FromSubAccount_CODE] [char](6) NOT NULL,
	[TransactionApplied_AMNT] [numeric](11, 2) NOT NULL,
	[TransactionRemaining_AMNT] [numeric](11, 2) NOT NULL,
	[PermArrears_AMNT] [numeric](11, 2) NOT NULL,
	[CondArrears_AMNT] [numeric](11, 2) NOT NULL,
	[TempArrears_AMNT] [numeric](11, 2) NOT NULL,
	[NeverArrears_AMNT] [numeric](11, 2) NOT NULL,
	[UadArrears_AMNT] [numeric](11, 2) NOT NULL,
	[UapArrears_AMNT] [numeric](11, 2) NOT NULL,
 CONSTRAINT [FCDTL_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC,
	[DetailHeader_TEXT] ASC,
	[Transaction_Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [FROZEN]
) ON [FROZEN]

GO
SET ANSI_PADDING OFF
GO
