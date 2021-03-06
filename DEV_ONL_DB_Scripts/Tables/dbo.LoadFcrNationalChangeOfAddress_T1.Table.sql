USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaRetSt_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaReturnSort_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLineTravel_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaRoute_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaCheck_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaDelPoint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine3Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ComMailRecvAgen_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'LocAddConvSys_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'MoveType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'AddressChangeEffYearMonth_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'NewReturnNcoa_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnSort_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnLineTravel_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnRoute_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnCheck_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnDeliveryPoint_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnLine3_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'NcoaResponse_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'UserField_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Ncoa_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadFcrNationalChangeOfAddress_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadFcrNationalChangeOfAddress_T1]
GO
/****** Object:  Table [dbo].[LoadFcrNationalChangeOfAddress_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadFcrNationalChangeOfAddress_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](2) NOT NULL,
	[Ncoa_CODE] [char](1) NOT NULL,
	[StateFips_CODE] [char](2) NOT NULL,
	[First_NAME] [char](16) NOT NULL,
	[Middle_NAME] [char](16) NOT NULL,
	[Last_NAME] [char](30) NOT NULL,
	[SubLine1_ADDR] [char](40) NOT NULL,
	[SubLine2_ADDR] [char](40) NOT NULL,
	[SubCity_ADDR] [char](20) NOT NULL,
	[SubState_ADDR] [char](2) NOT NULL,
	[SubZip_ADDR] [char](9) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[MemberMci_IDNO] [char](15) NOT NULL,
	[UserField_NAME] [char](15) NOT NULL,
	[NcoaResponse_CODE] [char](2) NOT NULL,
	[ReturnLine1_ADDR] [varchar](50) NOT NULL,
	[ReturnLine2_ADDR] [varchar](50) NOT NULL,
	[ReturnLine3_ADDR] [varchar](50) NOT NULL,
	[ReturnCity_ADDR] [char](30) NOT NULL,
	[ReturnState_ADDR] [char](2) NOT NULL,
	[ReturnZip_ADDR] [char](9) NOT NULL,
	[ReturnDeliveryPoint_CODE] [char](2) NOT NULL,
	[ReturnCheck_CODE] [char](1) NOT NULL,
	[ReturnRoute_CODE] [char](4) NOT NULL,
	[ReturnLineTravel_CODE] [char](4) NOT NULL,
	[ReturnSort_CODE] [char](1) NOT NULL,
	[NewReturnNcoa_CODE] [char](2) NOT NULL,
	[AddressChangeEffYearMonth_NUMB] [char](6) NOT NULL,
	[MoveType_CODE] [char](1) NOT NULL,
	[LocAddConvSys_CODE] [char](1) NOT NULL,
	[ComMailRecvAgen_INDC] [char](1) NOT NULL,
	[CoaLine1Old_ADDR] [varchar](50) NOT NULL,
	[CoaLine2Old_ADDR] [varchar](50) NOT NULL,
	[CoaLine3Old_ADDR] [varchar](50) NOT NULL,
	[CoaCityOld_ADDR] [char](30) NOT NULL,
	[CoaStateOld_ADDR] [char](2) NOT NULL,
	[CoaZipOld_ADDR] [char](9) NOT NULL,
	[CoaDelPoint_CODE] [char](2) NOT NULL,
	[CoaCheck_CODE] [char](1) NOT NULL,
	[CoaRoute_CODE] [char](4) NOT NULL,
	[CoaLineTravel_CODE] [char](4) NOT NULL,
	[CoaReturnSort_CODE] [char](1) NOT NULL,
	[CoaRetSt_CODE] [char](2) NOT NULL,
	[CoaNormalization_CODE] [char](1) NOT NULL,
	[CoaLine1_ADDR] [varchar](50) NOT NULL,
	[CoaLine2_ADDR] [varchar](50) NOT NULL,
	[CoaCity_ADDR] [char](28) NOT NULL,
	[CoaState_ADDR] [char](2) NOT NULL,
	[CoaZip_ADDR] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LFNCA_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Address verification.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'To indicate the response record from FCR /NCOA interface.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Ncoa_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Must contain Delaware FIPS code. Possible value is 10.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'StateFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member First name submitted by state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Middle name submitted by state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Last name submitted by state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Submitted address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Submitted address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Submitted address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Submitted address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Submitted address zip.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'SubZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member SSN.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member MCI number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'User field contains the information that was submitted on the request record to the FCR.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'UserField_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Ncoa response code contains one of the following' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'NcoaResponse_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCOA Return line1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCOA Return line2 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCOA Return line3 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnLine3_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCOA Return City address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCOA Return State address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCOA Return Zip address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'standardized street address delivery point digits from the NCOA vendor.   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnDeliveryPoint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'check digit used for POSTNET barcode, for the standardized address.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnCheck_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'carrier route code used for POSTNET barcode, for the standardized address.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnRoute_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line of travel (LOT) used for POSTNET barcode, for the standardized address.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnLineTravel_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The field contains the LOT ascending or descending sort flag, for the standardized address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ReturnSort_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains one of the following' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'NewReturnNcoa_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the date the address change became effective from the NCOA database.   The format is CCYYMM.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'AddressChangeEffYearMonth_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field identifies the type of move.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'MoveType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains one of the following Locatable Address Conversion System' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'LocAddConvSys_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates one of the following Commercial Mail Receiving Agency (CMRA)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'ComMailRecvAgen_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Change of address (COA) street address line 1 from the NCOA database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Change of address street address line 2 from the NCOA database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Change of address street address line 3 from the NCOA database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine3Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Change of address city name from the NCOA database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Change of address state code from the NCOA database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Change of address Zip Code from the NCOA database.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Delivery point digits for generating a delivery point barcode, for the change of address.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaDelPoint_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Check code used for POSTNET barcode, for the change of address.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaCheck_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Carrier route code for the change of address. This field is used for POSTNET bar-coding.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaRoute_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Line of travel (LOT) number for carrier route mailings, for the change of address. This field   is used for POSTNET bar-coding.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLineTravel_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field contains the LOT ascending or descending sort flag, for the change of address.    ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaReturnSort_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'It contains the  FIPS code for the State receiving the response.   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaRetSt_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Change of address normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized NCOA line1 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized NCOA line2 , line3 address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized NCOA city address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized NCOA state address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Normalized NCOA zip address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'CoaZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date file was loaded into the table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the record was processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Reads the response files coming from the Federal Case Registry (FCR) and loads the data into temporary tables.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadFcrNationalChangeOfAddress_T1'
GO
