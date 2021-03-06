USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'Agency_EML'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyFax_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyCountry_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'ServerPath_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'Agency_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'

GO
/****** Object:  Table [dbo].[ApreAgency_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[ApreAgency_T1]
GO
/****** Object:  Table [dbo].[ApreAgency_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApreAgency_T1](
	[Application_IDNO] [numeric](15, 0) NOT NULL,
	[Agency_IDNO] [numeric](9, 0) NOT NULL,
	[ServerPath_NAME] [varchar](60) NOT NULL,
	[AgencyLine1_ADDR] [varchar](50) NOT NULL,
	[AgencyLine2_ADDR] [varchar](50) NOT NULL,
	[AgencyCity_ADDR] [char](28) NOT NULL,
	[AgencyState_ADDR] [char](2) NOT NULL,
	[AgencyZip_ADDR] [char](15) NOT NULL,
	[AgencyCountry_ADDR] [char](2) NOT NULL,
	[AgencyPhone_NUMB] [numeric](15, 0) NOT NULL,
	[AgencyFax_NUMB] [numeric](15, 0) NOT NULL,
	[Agency_EML] [varchar](100) NOT NULL,
	[MemberMCI_IDNO] [numeric](10, 0) NOT NULL,
 CONSTRAINT [APAG_I1] PRIMARY KEY CLUSTERED 
(
	[Application_IDNO] ASC,
	[MemberMCI_IDNO] ASC,
	[Agency_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies the system assigned number to the application' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'Application_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the system assigned number to the agency' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'Agency_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Agencies name that has collected child support on behalf of the   applicant''s children' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'ServerPath_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Agency''s address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Agency''s address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'City of the agency''s address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'State of the agency''s address. For the possible values please refer the table MaintenanceRef_T1: STAT/STAT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Zip of the agency''s address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Country of the agency''s address. Values are obtained from REFM (CTRY/CTRY).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyCountry_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Agency''s telephone number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Agency''s fax number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'AgencyFax_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Agency''s email address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'Agency_EML'
GO
EXEC sys.sp_addextendedproperty @name=N'2', @value=N'Identifies the system assigned number to the Member.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1', @level2type=N'COLUMN',@level2name=N'MemberMCI_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Stores agency details, which have collected child support payments on behalf of NCP''s child /Children.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApreAgency_T1'
GO
