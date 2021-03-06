USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'HomePhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'FamilyViolence_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Person_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Race_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'IvaCase_ID'

GO
/****** Object:  Table [dbo].[PendingMembers_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[PendingMembers_T1]
GO
/****** Object:  Table [dbo].[PendingMembers_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingMembers_T1](
	[IvaCase_ID] [char](10) NOT NULL,
	[Last_NAME] [char](20) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](20) NOT NULL,
	[MemberSsn_NUMB] [numeric](9, 0) NOT NULL,
	[Birth_DATE] [date] NOT NULL,
	[MemberSex_CODE] [char](1) NOT NULL,
	[Race_CODE] [char](1) NOT NULL,
	[Line1_ADDR] [varchar](50) NOT NULL,
	[Line2_ADDR] [varchar](50) NOT NULL,
	[City_ADDR] [char](28) NOT NULL,
	[State_ADDR] [char](2) NOT NULL,
	[Zip_ADDR] [char](15) NOT NULL,
	[Person_CODE] [char](2) NOT NULL,
	[GoodCause_CODE] [char](1) NOT NULL,
	[FamilyViolence_INDC] [char](1) NOT NULL,
	[WorkerUpdate_ID] [char](30) NOT NULL,
	[TransactionEventSeq_NUMB] [numeric](19, 0) NOT NULL,
	[Update_DTTM] [datetime2](7) NOT NULL,
	[HomePhone_NUMB] [numeric](15, 0) NOT NULL,
	[Begin_DATE] [date] NOT NULL,
	[TypeWelfare_CODE] [char](1) NOT NULL,
 CONSTRAINT [PNMB_I1] PRIMARY KEY CLUSTERED 
(
	[IvaCase_ID] ASC,
	[TransactionEventSeq_NUMB] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Indicates the IVA Case ID.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'IvaCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members Last Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members Date of Birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members Sex.  Values are obtained from REFM (GENR/GEN2).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Members Race. Values are obtained from REFM (GENR/RACE).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Race_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Line1 of the Members Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Line1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Line2 of the Members Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Line2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the City of the Members Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'City_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the State of the Members Address. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'State_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Zip of the Members Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Zip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Person Status. Values to be determined in the subsequent Technical designs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Person_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Good Cause Code. Values are obtained from REFM (CCRT/GOOD).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Family Violence Indicator. Values are obtained from REFM (YSNO/YSNO).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'FamilyViolence_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the worker ID who created/modified this record.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'WorkerUpdate_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Unique Sequence Number that will be generated for any given transaction on the Table. This field is used for checking concurrency at the time of online transaction updates.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'TransactionEventSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the effective Date with Time at which this record was inserted / modified in this table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Update_DTTM'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member''s home phone number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'HomePhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Begin Date of the Public Assistance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'Begin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Welfare Type. Values are obtained from REFM (MHIS/PGTY).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1', @level2type=N'COLUMN',@level2name=N'TypeWelfare_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table used to store the information about the members in the pending cases.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PendingMembers_T1'
GO
