USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StatusEnforce_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SeqoExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LienExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CcloStrt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CrimExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'VerifiedNcpAddrExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'BalanceCurSup_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ObleMs_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ObleNf_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'RevwStrt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PsocStrt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OgcoStrt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LintStrt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CrptStrt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LicenseExistsCp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InsuranceExistsNcp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InsuranceExistsCp_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PhoneNcp_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PhoneCp_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastIdenPaymentReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'DistributeLast_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ExpectToPay_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TotToDistributeMtd_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ObleSs_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ObleCs_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'BeginObligationRecent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageOthers_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'IssuingOrderFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InterstateEligibleRevw_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseCategory_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NonCoop_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StatusCurrent_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'RsnStatusCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PsocExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NmsnExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LsnrExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'QdroExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LintExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ImiwExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FidmExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CslnExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CrptExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ArenExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LicenseExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MeansTestedInc_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SsObligationExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MsObligationExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CsObligationExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'VerCpAddrExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CpInStateResidence_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CountryCp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ZipCp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StateCp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CityCp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Line2Cp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Line1Cp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthCp_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SuffixCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddleCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastCp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmplExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpAddrExist_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpInstateResidence_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CountryNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ZipNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StateNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CityNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Line2Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Line1Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthNcp_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SuffixNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'VerifiedItinCpSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'VerifiedltinNcpOrpfSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageVision_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageMental_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageMedical_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageDrug_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageDental_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CejStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CejFips_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseChargingArrears_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Released_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Deceased_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Institutionalized_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Incarceration_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'WorkerCase_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MultiIva_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Filed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Discharge_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Dismissed_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'GenerateDelqn_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'GenerateEmancipation_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'GenerateIrsci_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderIssuedOrg_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastRegularPaymentReceived_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CheckLastCp_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NextPayLeastOble_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SourceReceiptLast_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TypePayback_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FreqLeastOble_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FreqPayback_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CheckLastCp_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'DefraPrevMonth_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TotMtdColl_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TotYtdColl_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ArrearsReg_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FullArrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseExempt_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ReceiptLast_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ArrearsCsms_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MsoCsms_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Mso_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Bankruptcy13_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseMemberStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderEnd_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderEffective_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastReview_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MedicalOnly_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Iiwo_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InsOrdered_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InterstateEligible_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpPfSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpPf_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
/****** Object:  Index [ENSD_NCP_PF_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ENSD_NCP_PF_I1] ON [dbo].[EnforcementStagingDetails_T1]
GO
/****** Object:  Index [ENSD_MEMBER_CP_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP INDEX [ENSD_MEMBER_CP_I1] ON [dbo].[EnforcementStagingDetails_T1]
GO
/****** Object:  Table [dbo].[EnforcementStagingDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[EnforcementStagingDetails_T1]
GO
/****** Object:  Table [dbo].[EnforcementStagingDetails_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EnforcementStagingDetails_T1](
	[Case_IDNO] [numeric](6, 0) NOT NULL,
	[NcpPf_IDNO] [numeric](10, 0) NOT NULL,
	[NcpPfSsn_NUMB] [numeric](9, 0) NOT NULL,
	[County_IDNO] [numeric](3, 0) NOT NULL,
	[TypeCase_CODE] [char](1) NOT NULL,
	[StatusCase_CODE] [char](1) NOT NULL,
	[RespondInit_CODE] [char](1) NOT NULL,
	[InterstateEligible_NUMB] [numeric](1, 0) NOT NULL,
	[InsOrdered_CODE] [char](1) NOT NULL,
	[Iiwo_CODE] [char](2) NOT NULL,
	[MedicalOnly_INDC] [char](1) NOT NULL,
	[LastReview_DATE] [date] NOT NULL,
	[OrderIssued_DATE] [date] NOT NULL,
	[OrderEffective_DATE] [date] NOT NULL,
	[OrderEnd_DATE] [date] NOT NULL,
	[TypeOrder_CODE] [char](1) NOT NULL,
	[CaseMemberStatus_CODE] [char](1) NOT NULL,
	[Bankruptcy13_INDC] [char](1) NOT NULL,
	[Mso_AMNT] [numeric](11, 2) NOT NULL,
	[Arrears_AMNT] [numeric](11, 2) NOT NULL,
	[MsoCsms_AMNT] [numeric](11, 2) NOT NULL,
	[ArrearsCsms_AMNT] [numeric](11, 2) NOT NULL,
	[ReceiptLast_DATE] [date] NOT NULL,
	[CaseExempt_INDC] [char](1) NOT NULL,
	[FullArrears_AMNT] [numeric](11, 2) NOT NULL,
	[ArrearsReg_AMNT] [numeric](11, 2) NOT NULL,
	[TotYtdColl_AMNT] [numeric](11, 2) NOT NULL,
	[TotMtdColl_AMNT] [numeric](11, 2) NOT NULL,
	[PaymentLastReceived_AMNT] [numeric](11, 2) NOT NULL,
	[DefraPrevMonth_AMNT] [numeric](11, 2) NOT NULL,
	[CheckLastCp_AMNT] [numeric](11, 2) NOT NULL,
	[FreqPayback_CODE] [char](1) NOT NULL,
	[FreqLeastOble_CODE] [char](1) NOT NULL,
	[TypePayback_CODE] [char](1) NOT NULL,
	[SourceReceiptLast_CODE] [char](2) NOT NULL,
	[NextPayLeastOble_DATE] [date] NOT NULL,
	[CheckLastCp_DATE] [date] NOT NULL,
	[LastRegularPaymentReceived_DATE] [date] NOT NULL,
	[CourtOrderIssuedOrg_DATE] [date] NOT NULL,
	[GenerateIrsci_DATE] [date] NOT NULL,
	[GenerateEmancipation_DATE] [date] NOT NULL,
	[GenerateDelqn_DATE] [date] NOT NULL,
	[Dismissed_DATE] [date] NOT NULL,
	[Discharge_DATE] [date] NOT NULL,
	[Filed_DATE] [date] NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[CaseWelfare_IDNO] [numeric](10, 0) NOT NULL,
	[MultiIva_INDC] [char](1) NOT NULL,
	[WorkerCase_ID] [char](30) NOT NULL,
	[Incarceration_DATE] [date] NOT NULL,
	[Institutionalized_DATE] [date] NOT NULL,
	[Deceased_DATE] [date] NOT NULL,
	[Released_DATE] [date] NOT NULL,
	[CaseChargingArrears_CODE] [char](1) NOT NULL,
	[CejFips_CODE] [char](7) NOT NULL,
	[CejStatus_CODE] [char](1) NOT NULL,
	[CoverageDental_CODE] [char](1) NOT NULL,
	[CoverageDrug_CODE] [char](1) NOT NULL,
	[CoverageMedical_CODE] [char](1) NOT NULL,
	[CoverageMental_CODE] [char](1) NOT NULL,
	[CoverageVision_CODE] [char](1) NOT NULL,
	[CpMci_IDNO] [numeric](10, 0) NOT NULL,
	[VerifiedltinNcpOrpfSsn_NUMB] [numeric](9, 0) NOT NULL,
	[VerifiedItinCpSsn_NUMB] [numeric](9, 0) NOT NULL,
	[LastNcp_NAME] [char](20) NOT NULL,
	[FirstNcp_NAME] [char](16) NOT NULL,
	[MiddleNcp_NAME] [char](20) NOT NULL,
	[SuffixNcp_NAME] [char](4) NOT NULL,
	[BirthNcp_DATE] [date] NOT NULL,
	[Line1Ncp_ADDR] [varchar](50) NOT NULL,
	[Line2Ncp_ADDR] [varchar](50) NOT NULL,
	[CityNcp_ADDR] [char](28) NOT NULL,
	[StateNcp_ADDR] [char](2) NOT NULL,
	[ZipNcp_ADDR] [char](15) NOT NULL,
	[CountryNcp_ADDR] [char](2) NOT NULL,
	[NcpInstateResidence_INDC] [char](1) NOT NULL,
	[NcpAddrExist_INDC] [char](1) NOT NULL,
	[NcpEmplExist_INDC] [char](1) NOT NULL,
	[LastCp_NAME] [char](20) NOT NULL,
	[FirstCp_NAME] [char](16) NOT NULL,
	[MiddleCp_NAME] [char](20) NOT NULL,
	[SuffixCp_NAME] [char](4) NOT NULL,
	[BirthCp_DATE] [date] NOT NULL,
	[Line1Cp_ADDR] [varchar](50) NOT NULL,
	[Line2Cp_ADDR] [varchar](50) NOT NULL,
	[CityCp_ADDR] [char](28) NOT NULL,
	[StateCp_ADDR] [char](2) NOT NULL,
	[ZipCp_ADDR] [char](15) NOT NULL,
	[CountryCp_ADDR] [char](2) NOT NULL,
	[CpInStateResidence_INDC] [char](1) NOT NULL,
	[VerCpAddrExist_INDC] [char](1) NOT NULL,
	[CsObligationExist_INDC] [char](1) NOT NULL,
	[MsObligationExist_INDC] [char](1) NOT NULL,
	[SsObligationExist_INDC] [char](1) NOT NULL,
	[MeansTestedInc_INDC] [char](1) NOT NULL,
	[LicenseExist_INDC] [char](1) NOT NULL,
	[ArenExempt_INDC] [char](1) NOT NULL,
	[CrptExempt_INDC] [char](1) NOT NULL,
	[CslnExempt_INDC] [char](1) NOT NULL,
	[FidmExempt_INDC] [char](1) NOT NULL,
	[ImiwExempt_INDC] [char](1) NOT NULL,
	[LintExempt_INDC] [char](1) NOT NULL,
	[QdroExempt_INDC] [char](1) NOT NULL,
	[LsnrExempt_INDC] [char](1) NOT NULL,
	[NmsnExempt_INDC] [char](1) NOT NULL,
	[PsocExempt_INDC] [char](1) NOT NULL,
	[RsnStatusCase_CODE] [char](2) NOT NULL,
	[StatusCurrent_DATE] [date] NOT NULL,
	[GoodCause_CODE] [char](1) NOT NULL,
	[NonCoop_CODE] [char](1) NOT NULL,
	[CaseCategory_CODE] [char](2) NOT NULL,
	[InterstateEligibleRevw_INDC] [char](1) NOT NULL,
	[OrderSeq_NUMB] [numeric](2, 0) NOT NULL,
	[IssuingOrderFips_CODE] [char](7) NOT NULL,
	[CoverageOthers_CODE] [char](1) NOT NULL,
	[BeginObligationRecent_DATE] [date] NOT NULL,
	[ObleCs_AMNT] [numeric](11, 2) NOT NULL,
	[ObleSs_AMNT] [numeric](11, 2) NOT NULL,
	[TotToDistributeMtd_AMNT] [numeric](11, 2) NOT NULL,
	[ExpectToPay_AMNT] [numeric](11, 2) NOT NULL,
	[DistributeLast_DATE] [date] NOT NULL,
	[LastIdenPaymentReceived_DATE] [date] NOT NULL,
	[PhoneCp_NUMB] [numeric](15, 0) NOT NULL,
	[PhoneNcp_NUMB] [numeric](15, 0) NOT NULL,
	[InsuranceExistsCp_INDC] [char](1) NOT NULL,
	[InsuranceExistsNcp_INDC] [char](1) NOT NULL,
	[LicenseExistsCp_INDC] [char](1) NOT NULL,
	[CrptStrt_INDC] [char](1) NOT NULL,
	[LintStrt_INDC] [char](1) NOT NULL,
	[OgcoStrt_INDC] [char](1) NOT NULL,
	[PsocStrt_INDC] [char](1) NOT NULL,
	[RevwStrt_INDC] [char](1) NOT NULL,
	[ObleNf_AMNT] [numeric](11, 2) NOT NULL,
	[ObleMs_AMNT] [numeric](11, 2) NOT NULL,
	[BalanceCurSup_AMNT] [numeric](11, 2) NOT NULL,
	[VerifiedNcpAddrExist_INDC] [char](1) NOT NULL,
	[CrimExempt_INDC] [char](1) NOT NULL,
	[CcloStrt_INDC] [char](1) NOT NULL,
	[LienExempt_INDC] [char](1) NOT NULL,
	[SeqoExempt_INDC] [char](1) NOT NULL,
	[StatusEnforce_CODE] [char](4) NOT NULL,
 CONSTRAINT [ENSD_I1] PRIMARY KEY CLUSTERED 
(
	[Case_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [ENSD_MEMBER_CP_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [ENSD_MEMBER_CP_I1] ON [dbo].[EnforcementStagingDetails_T1]
(
	[CpMci_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ENSD_NCP_PF_I1]    Script Date: 4/7/2015 12:53:07 PM ******/
CREATE NONCLUSTERED INDEX [ENSD_NCP_PF_I1] ON [dbo].[EnforcementStagingDetails_T1]
(
	[NcpPf_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Unique ID generated for the DACSES Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique number assigned by the system to the participant.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpPf_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Members social security number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpPfSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the County in which the Case is created.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'County_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Type of the Case. Values are obtained from REFM (WRKL/CTYP).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Status of the Case. Values are obtained from REFM (CSTS/CSTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StatusCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Case is Initiation or Responding. Values are obtained from REFM (WRKL/INTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'RespondInit_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Interstate case is eligible for initiating the remedy. 0 means not eligible, 1 means eligible.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InterstateEligible_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates who was ordered by court to provide the insurance. Values are obtained from REFM (SORD/INSO)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InsOrdered_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Code indicating that an immediate income withholding is provided for in the support order. Values are obtained from REFM (SORD/IWOR)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Iiwo_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the order is on Indicates the order is only for medical support obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MedicalOnly_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates when the Review and Adjustment was done previously.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastReview_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the date in which the support order was issued.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderIssued_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date from which the order in effective.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderEffective_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date in which Support Order ends.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderEnd_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Stores the order type code. Possible values are available in VREFM with id_table SORD and id_table_sub ORDT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TypeOrder_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Member Status on the Case. Values are obtained from REFM (GENR/MEMS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseMemberStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the chapter 13 Bankruptcy was filed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Bankruptcy13_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Monthly obligation amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Mso_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the arrears for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Arrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Monthly obligation amount for CS and MS debt types.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MsoCsms_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the arrears for the case for CS and MS debt types.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ArrearsCsms_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates when the last receipt was received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ReceiptLast_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case is exempt from initiating the Enforcement remedies.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the full arrear amount for the case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FullArrears_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the regular arrear amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ArrearsReg_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the current year to date payment.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TotYtdColl_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the current month to date collection.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TotMtdColl_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last payment received amount for Identified receipt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PaymentLastReceived_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the DEFRA Amount for previous month.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'DefraPrevMonth_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the CP Last check amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CheckLastCp_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the frequency of payback. Values are obtained from REFM (FRQA/FRQ3)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FreqPayback_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the least frequency. Values are obtained from REFM (FRQA/FRQ3) and REFM (FRQA/FRQ4)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FreqLeastOble_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the payback type. Values are obtained from REFM (OWIZ/PAYT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TypePayback_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the latest source of the receipt. Values are obtained from REFM (RCTS/RCTS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SourceReceiptLast_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the lowest next pay date from OBLE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NextPayLeastOble_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the CP Last check date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CheckLastCp_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last regular payment received from identified receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastRegularPaymentReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the original court order issue date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderIssuedOrg_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the date on when IRSCI minor activity is generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'GenerateIrsci_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the date on when EMANI minor activity is generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'GenerateEmancipation_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the date on when DELQN minor activity is generated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'GenerateDelqn_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Bankruptcy was dismissed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Dismissed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Bankruptcy was discharged.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Discharge_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Bankruptcy was filed.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Filed_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Specifies the docket (and county).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The Welfare CASE ID created at the CP level for the case, when the CP is on the welfare program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseWelfare_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Multiple IVA indicator. Y if more than one IVA case, N if single IVA case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MultiIva_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Worker ID who created the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'WorkerCase_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member was incarcerated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Incarceration_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member was institutionalized.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Institutionalized_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member was deceased.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Deceased_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Date on which the Member was released.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Released_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether case is Charging case or Arrear only case or Non Charging/Arrears cases. Possible values are C - Charging case, A - Arrear only case, N - Non Charging/Arrears cases.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseChargingArrears_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The control enforcement jurisdiction State FIPS of the case.  Values are obtained from REFM (FIPS/STCD)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CejFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The CEJ status code of the case. Values are obtained from REFM (SORD/CEJS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CejStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Dental coverage is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None. Possible values are C-CP, A-NCP, B-Both, N-none.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageDental_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Drug coverage is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None. Possible values are C-CP, A-NCP, B-Both, N-none.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageDrug_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Medical coverage is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None. Possible values are C-CP, A-NCP, B-Both, N-none.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageMedical_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Mental Health coverage is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None. Possible values are C-CP, A-NCP, B-Both, N-none.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageMental_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if Vision coverage is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None.  Possible values are C-CP, A-NCP, B-Both, N-none.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageVision_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Unique number assigned by the system to the Custodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CpMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Members (NCP/PF) Verified SSN/ITIN. Common SSN hierarchy is used to get this value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'VerifiedltinNcpOrpfSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Members (CP) Verified SSN/ITIN. Common SSN hierarchy is used to get this value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'VerifiedItinCpSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last name of the Noncustodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the first name of the Noncustodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Middle name of the Noncustodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddleNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Suffix of the Noncustodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SuffixNcp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Noncustodial Parent date of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthNcp_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Noncustodial Parent First Line of the Street Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Line1Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Noncustodial Parent Second Line of the Street Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Line2Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Noncustodial Parent Residing City.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CityNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Noncustodial Parent Residing State.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StateNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Noncustodial Parent Residing Zip Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ZipNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Noncustodial Parent Residing Country.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CountryNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Noncustodial Parent has New Jersey residential address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpInstateResidence_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Noncustodial Parent has confirmed good address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpAddrExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Noncustodial Parent has confirmed employer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NcpEmplExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last name of the Custodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the first name of the Custodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FirstCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Middle name of the Custodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MiddleCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Suffix of the Custodial Parent.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SuffixCp_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Custodial Parent date of birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'BirthCp_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Custodial Parent First Line of the Street Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Line1Cp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Custodial Parent Second Line of the Street Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'Line2Cp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Custodial Parent Residing City.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CityCp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Custodial Parent Residing State.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StateCp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Custodial Parent Residing Zip Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ZipCp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Custodial Parent Residing Country.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CountryCp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Custodial Parent has New Jersey residential address or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CpInStateResidence_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Custodial Parent has confirmed good address or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'VerCpAddrExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Child Support obligation is exist.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CsObligationExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has Medical Support Obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MsObligationExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has spousal Support Obligation.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SsObligationExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Member has Means Tested Income.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'MeansTestedInc_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the Noncustodial Parent has active driver license.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LicenseExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has AREN exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ArenExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has CRPT exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CrptExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has CSLN exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CslnExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has FIDM exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'FidmExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has IMIW exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ImiwExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has LINT exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LintExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has QDRO exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'QdroExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has LSNR exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LsnrExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has NMSN exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NmsnExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has PSOC exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PsocExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Status Case Reason. Values are obtained from REFM (CPRO/REAS).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'RsnStatusCase_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Current Status Date of the Case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StatusCurrent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Good Cause Code. Values are obtained from REFM (CCRT/GOOD)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'GoodCause_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Non Cooperation Indicator. Values are obtained from REFM (CCRT/NCOP)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'NonCoop_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Case Category. Values obtained from REFM (CCRT/CCTG).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CaseCategory_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has REVW remedy for interstate cases.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InterstateEligibleRevw_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates internal order sequence number created for a support order for a given case.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OrderSeq_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'The FIPS code of the state where the order was issued. Values are obtained from REFM (STAT/STAT).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'IssuingOrderFips_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates if there is any other coverage that is provided to the dependants on this Order. This will store as to who is providing the coverage, whether CP, NCP, Both or None. Possible values are C-CP, A-NCP, B-Both, N-none.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CoverageOthers_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Maximum begin obligation for a case, only within Weekly, Bi-Weekly, Semi- Monthly, and Monthly.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'BeginObligationRecent_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates CS the obligation amount to be collected for a given time period.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ObleCs_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates SS the obligation amount to be collected for a given time period.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ObleSs_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the total amt_to_distribute value for the case (both Identified and unidentified).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'TotToDistributeMtd_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the Expected payment amount for the court ordered arrears.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ExpectToPay_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the date on which the Receipt was distributed to Recipient.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'DistributeLast_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies the last payment received for identified receipts.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LastIdenPaymentReceived_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the CP Phone Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PhoneCp_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the NCP Phone Number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PhoneNcp_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Insurance exists for CP (Y/N).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InsuranceExistsCp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Insurance exists for NCP (Y/N).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'InsuranceExistsNcp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates license exists for CP (Y -Yes/ N- No).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LicenseExistsCp_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has CRPT status STRT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CrptStrt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has LINT status STRT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LintStrt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has OGCO status STRT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'OgcoStrt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has PSOC status STRT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'PsocStrt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has REVW status STRT.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'RevwStrt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates NCP Fees amount to be collected for a given time period.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ObleNf_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Medical support amount to be collected for a given time period.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'ObleMs_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Missed Current Support Amount.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'BalanceCurSup_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the Noncustodial Parent Verified Address Exists.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'VerifiedNcpAddrExist_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has State Criminal Prosecution as exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CrimExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has Case Closure status as start.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'CcloStrt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has Lien Activity Chain as exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'LienExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the case has Sequestration Orders as exempt.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'SeqoExempt_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'This field is used to identify the workable status of a case. Values are obtained from REFM (CCRT/ENST).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1', @level2type=N'COLUMN',@level2name=N'StatusEnforce_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table stores information on key entities such as case type, obligation details, arrears, enforcement specific indicators that are derived for all cases after the financial processing is completed on a daily basis. This table is further user by enforcement processing jobs to get the values directly for a case instead of searching the base tables to improve performance on those jobs. This will be flushed out on a daily basis and will be re-inserted as part of the daily process.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnforcementStagingDetails_T1'
GO
