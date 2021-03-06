USE [DEV_ONL_DB]
GO
/****** Object:  Table [dbo].[IVD_CHILD]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[IVD_CHILD]
GO
/****** Object:  Table [dbo].[IVD_CHILD]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IVD_CHILD](
	[#ISN] [varchar](50) NULL,
	[CHILD_ID] [varchar](50) NULL,
	[TIME_MODIFIED] [varchar](50) NULL,
	[USERID_MODIFIED] [varchar](50) NULL,
	[CHILD_SSN] [varchar](50) NULL,
	[CIS_RECIPIENT_NUMBER] [varchar](50) NULL,
	[CHIP_CLIENT_ID] [varchar](50) NULL,
	[TXX_CLIENT_ID] [varchar](50) NULL,
	[CIS_FAMILY_NUMBER] [varchar](50) NULL,
	[CHILD_FIRST_NAME] [varchar](50) NULL,
	[CHILD_MID_NAME] [varchar](50) NULL,
	[CHILD_LAST_NAME] [varchar](50) NULL,
	[CHILD_NAME_SUFFIX] [varchar](50) NULL,
	[CHILD_SEX] [varchar](50) NULL,
	[BIRTH_CITY] [varchar](50) NULL,
	[BIRTH_STATE] [varchar](50) NULL,
	[BIRTH_ZIP] [varchar](50) NULL,
	[CHILD_BIRTH_DATE] [varchar](50) NULL,
	[PARENTS_MARRIAGE_CITY] [varchar](50) NULL,
	[PARENTS_MARRIAGE_STATE] [varchar](50) NULL,
	[PARENTS_MARRIAGE_ZIP] [varchar](50) NULL,
	[BIO_FATHER_FIRST_NAME] [varchar](50) NULL,
	[BIO_FATHER_MID_NAME] [varchar](50) NULL,
	[BIO_FATHER_LAST_NAME] [varchar](50) NULL,
	[BIO_FATHER_NAME_SUFFIX] [varchar](50) NULL,
	[LEGAL_FATHER_FIRST_NAME] [varchar](50) NULL,
	[LEGAL_FATHER_MID_NAME] [varchar](50) NULL,
	[LEGAL_FATHER_LAST_NAME] [varchar](50) NULL,
	[LEGAL_FATHER_NAME_SUFFIX] [varchar](50) NULL,
	[DEATH_DATE] [varchar](50) NULL,
	[ADDITIONAL_FATHERS_AFDC] [varchar](50) NULL,
	[DOCTORS_NAME] [varchar](50) NULL,
	[POUNDS] [varchar](50) NULL,
	[OUNCES] [varchar](50) NULL,
	[PREGNANCY_DATE] [varchar](50) NULL,
	[DELIVERY_STATUS] [varchar](50) NULL,
	[IVA_ELIGIBILITY_DATE] [varchar](50) NULL,
	[SUPPORT_AMOUNT_SOUGHT] [varchar](50) NULL,
	[CHILD_RACE] [varchar](50) NULL,
	[PARENTS_MARRIAGE_DATE] [varchar](50) NULL,
	[FAMILY_VIOLENCE_INDICATOR] [varchar](50) NULL,
	[SSN_VERIFIED] [varchar](50) NULL,
	[CHILD_FCR_SSN] [varchar](50) NULL,
	[CHILD_FCR_SSN_VERIFICATION] [varchar](50) NULL,
	[CHILD_SSN_ORIGIN] [varchar](50) NULL,
	[CHILD_DISABILITY_INDICATOR] [varchar](50) NULL,
	[CHILD_SSN_SECURITY] [varchar](50) NULL,
	[PAT_ACK_INDICATOR] [varchar](50) NULL,
	[CHILD_ACTUAL_CONVERSION_DATE] [varchar](50) NULL,
	[CHILD_CONVERSION_STATUS] [varchar](50) NULL,
	[CHILD_INCORRECT_SSN] [varchar](50) NULL,
	[CAPSS_SVC_ID] [varchar](50) NULL,
	[BUDGET_GROUP_NUMBER] [varchar](50) NULL,
	[MEDICAID_LIF_INDICATOR] [varchar](50) NULL,
	[MEDICAID_ELIG_START_DATE] [varchar](50) NULL,
	[MEDICAID_ELIG_END_DATE] [varchar](50) NULL,
	[CAPSS_SVC_START_DATE] [varchar](50) NULL,
	[CAPSS_SVC_END_DATE] [varchar](50) NULL,
	[STATE_MOTHER_BECAME_PREGNANT] [varchar](50) NULL,
	[NCP_LIVED_WITH_CHILD_IN_SC] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
