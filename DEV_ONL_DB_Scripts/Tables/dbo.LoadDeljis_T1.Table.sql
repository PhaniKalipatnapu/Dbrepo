USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'EmployerNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'OfficerNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisZipNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisStateNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisCityNcp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine2Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine1Ncp_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'NcpNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisZipNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisStateNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisCityNcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine2NcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine1NcpOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerPhone_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficer_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisStatusInitiated_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisReleaseComments_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisRelease_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisTypeSentence_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisWorkRelease_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMaximumRelease_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisIncarceration_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisFacility_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisInstitution_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisWarrantClear_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisWarrantIssue_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisWarrant_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMatch_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisRace_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisIssuingState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisSuffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMiddle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisFirst_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Deljis_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Race_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'IssuingState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadDeljis_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadDeljis_T1]
GO
/****** Object:  Table [dbo].[LoadDeljis_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadDeljis_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[MemberMci_IDNO] [char](10) NOT NULL,
	[Last_NAME] [char](40) NOT NULL,
	[First_NAME] [char](40) NOT NULL,
	[Middle_NAME] [char](40) NOT NULL,
	[Suffix_NAME] [char](5) NOT NULL,
	[Birth_DATE] [char](8) NOT NULL,
	[IssuingState_CODE] [char](2) NOT NULL,
	[LicenseNo_TEXT] [char](12) NOT NULL,
	[MemberSsn_NUMB] [char](9) NOT NULL,
	[Race_CODE] [char](2) NOT NULL,
	[MemberSex_CODE] [char](1) NOT NULL,
	[Case_IDNO] [char](6) NOT NULL,
	[Deljis_IDNO] [char](8) NOT NULL,
	[DeljisFirst_NAME] [char](40) NOT NULL,
	[DeljisLast_NAME] [char](40) NOT NULL,
	[DeljisMiddle_NAME] [char](40) NOT NULL,
	[DeljisSuffix_NAME] [char](5) NOT NULL,
	[DeljisBirth_DATE] [char](8) NOT NULL,
	[DeljisIssuingState_CODE] [char](2) NOT NULL,
	[DeljisLicenseNo_TEXT] [char](25) NOT NULL,
	[DeljisMemberSsn_NUMB] [char](9) NOT NULL,
	[DeljisRace_CODE] [char](1) NOT NULL,
	[DeljisMemberSex_CODE] [char](1) NOT NULL,
	[DeljisMatch_CODE] [char](1) NOT NULL,
	[DeljisWarrant_INDC] [char](1) NOT NULL,
	[DeljisWarrantIssue_DATE] [char](8) NOT NULL,
	[DeljisWarrantClear_DATE] [char](8) NOT NULL,
	[DeljisLine1Old_ADDR] [char](30) NOT NULL,
	[DeljisLine2Old_ADDR] [char](30) NOT NULL,
	[DeljisCityOld_ADDR] [char](18) NOT NULL,
	[DeljisStateOld_ADDR] [char](2) NOT NULL,
	[DeljisZipOld_ADDR] [char](9) NOT NULL,
	[DeljisInstitution_CODE] [char](2) NOT NULL,
	[DeljisFacility_NAME] [varchar](50) NOT NULL,
	[DeljisIncarceration_DATE] [char](8) NOT NULL,
	[DeljisMaximumRelease_DATE] [char](6) NOT NULL,
	[DeljisWorkRelease_INDC] [char](8) NOT NULL,
	[DeljisTypeSentence_CODE] [char](1) NOT NULL,
	[DeljisRelease_DATE] [char](8) NOT NULL,
	[DeljisReleaseComments_TEXT] [char](15) NOT NULL,
	[DeljisStatusInitiated_DATE] [char](8) NOT NULL,
	[DeljisOfficer_NAME] [varchar](50) NOT NULL,
	[DeljisOfficerLine1Old_ADDR] [char](30) NOT NULL,
	[DeljisOfficerLine2Old_ADDR] [char](30) NOT NULL,
	[DeljisOfficerCityOld_ADDR] [char](30) NOT NULL,
	[DeljisOfficerStateOld_ADDR] [char](2) NOT NULL,
	[DeljisOfficerZipOld_ADDR] [char](9) NOT NULL,
	[DeljisOfficerPhone_NUMB] [char](10) NOT NULL,
	[DeljisLine1NcpOld_ADDR] [char](30) NOT NULL,
	[DeljisLine2NcpOld_ADDR] [char](30) NOT NULL,
	[DeljisCityNcpOld_ADDR] [char](18) NOT NULL,
	[DeljisStateNcpOld_ADDR] [char](2) NOT NULL,
	[DeljisZipNcpOld_ADDR] [char](9) NOT NULL,
	[DeljisEmployer_NAME] [char](40) NOT NULL,
	[DeljisEmployerLine1Old_ADDR] [char](30) NOT NULL,
	[DeljisEmployerLine2Old_ADDR] [char](30) NOT NULL,
	[DeljisEmployerCityOld_ADDR] [char](18) NOT NULL,
	[DeljisEmployerStateOld_ADDR] [char](2) NOT NULL,
	[DeljisEmployerZipOld_ADDR] [char](9) NOT NULL,
	[DeljisNormalization_CODE] [char](1) NOT NULL,
	[DeljisLine1_ADDR] [varchar](50) NOT NULL,
	[DeljisLine2_ADDR] [varchar](50) NOT NULL,
	[DeljisCity_ADDR] [char](28) NOT NULL,
	[DeljisState_ADDR] [char](2) NOT NULL,
	[DeljisZip_ADDR] [char](15) NOT NULL,
	[NcpNormalization_CODE] [char](1) NOT NULL,
	[DeljisLine1Ncp_ADDR] [varchar](50) NOT NULL,
	[DeljisLine2Ncp_ADDR] [varchar](50) NOT NULL,
	[DeljisCityNcp_ADDR] [char](28) NOT NULL,
	[DeljisStateNcp_ADDR] [char](2) NOT NULL,
	[DeljisZipNcp_ADDR] [char](15) NOT NULL,
	[OfficerNormalization_CODE] [char](1) NOT NULL,
	[DeljisOfficerLine1_ADDR] [varchar](50) NOT NULL,
	[DeljisOfficerLine2_ADDR] [varchar](50) NOT NULL,
	[DeljisOfficerCity_ADDR] [char](28) NOT NULL,
	[DeljisOfficerState_ADDR] [char](2) NOT NULL,
	[DeljisOfficerZip_ADDR] [char](15) NOT NULL,
	[EmployerNormalization_CODE] [char](1) NOT NULL,
	[DeljisEmployerLine1_ADDR] [varchar](50) NOT NULL,
	[DeljisEmployerLine2_ADDR] [varchar](50) NOT NULL,
	[DeljisEmployerCity_ADDR] [char](28) NOT NULL,
	[DeljisEmployerState_ADDR] [char](2) NOT NULL,
	[DeljisEmployerZip_ADDR] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LDLJS_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Identifies record uniquely.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Member IDNO.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'MemberMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Last_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member First Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'First_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Middle Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Middle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Suffix Name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Suffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Date of Birth.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member’s driver license state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'IssuingState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member’s driver license number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'LicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member’s Social Security Number (SSN).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'MemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member’s race.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Race_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member’s sex.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'MemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Member Case Id.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Case_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Identifies Identification Number issued by State Bureau.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Deljis_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'First Name of the Member when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisFirst_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Last Name of the Member when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Middle Name of the Member When DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMiddle_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Suffix Name of the Member when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisSuffix_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Birth Date of the Member when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Issuing State of the Member when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisIssuingState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' License Number of the member when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLicenseNo_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Member SSN when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMemberSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Race of the member when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisRace_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Member Sex When DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMemberSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Match when DELJIS submitting to DE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMatch_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether NCP has an outstanding warrant or CAPIAS.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisWarrant_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Warrant Issue Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisWarrantIssue_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP warrant clear date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisWarrantClear_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Line1 Address before parole.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Line2 Address before parole.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP City Address before parole.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP State  Address before parole.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Zip Address before parole.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Institution Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisInstitution_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Specific facility name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisFacility_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Inmate’s date of incarceration.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisIncarceration_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Inmates Maximum release date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisMaximumRelease_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Work release program.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisWorkRelease_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Sentence Type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisTypeSentence_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Inmate date of release.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisRelease_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Release Comments.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisReleaseComments_TEXT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Status Initiated Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisStatusInitiated_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officer’s last name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Probation or parole officers Old address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Probation or parole officers Old address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officers Old address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officers Old address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officers Old address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officer’s phone number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerPhone_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s Old known address line 1 (NCP''s address prior to entering prison, or address as reported to parole or probation officer).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine1NcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s known address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine2NcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s Old known address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisCityNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s Old known address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisStateNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s Old known address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisZipNcpOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s employer name or school name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployer_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s employer Old address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s employer Old address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s employer Old address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s employer Old address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s employer Old address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Normalization Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Normalized  Line1 Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Normalized Line2 Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Normalized City Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Normalized State  Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'NCP Normalized Zip Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Normalization code for the Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'NcpNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s known address line 1 (NCP''s address prior to entering prison, or address as reported to parole or probation officer).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine1Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s known address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisLine2Ncp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s known address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisCityNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Subject’s known address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisStateNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject’s known address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisZipNcp_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Normalization code for the Officer''s Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'OfficerNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officers Old address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Probation or parole officers Old address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officers address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officers address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Probation or parole officers address zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisOfficerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Normalization code for the Employer''s Address.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'EmployerNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s Employer''s address line 1.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s Employer''s address line 2.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s Employer''s address city.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s Employer''s address state.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N' Subject''s Employer''s addresses zip code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'DeljisEmployerZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'File Load Date.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates whether the record is processed or not ''Y'' /''N''.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This is the load table for Deljis Incoming batch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadDeljis_T1'
GO
