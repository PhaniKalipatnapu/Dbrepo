USE [DEV_ONL_DB]
GO
EXEC sys.sp_dropextendedproperty @name=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherZip_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherState_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherCity_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLine2_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLine1_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherAddressNormalization_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'WorkerLast_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Monthly_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6FosterCareBegin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6FatherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6MotherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6MotherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Mother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6FatherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Father_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6PaternityEst_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6FedFunded_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6IveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Pid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Mci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Monthly_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5FosterCareBegin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5FatherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5MotherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5MotherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Mother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5FatherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Father_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5PaternityEst_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5FedFunded_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5IveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Pid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Mci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Monthly_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4FosterCareBegin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4FatherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4MotherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4MotherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Mother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4FatherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Father_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4PaternityEst_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4FedFunded_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4IveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Pid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Mci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Monthly_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3FosterCareBegin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3FatherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3MotherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3MotherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Mother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3FatherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Father_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3PaternityEst_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3FedFunded_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3IveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Pid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Mci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Monthly_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2FosterCareBegin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2FatherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2MotherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2MotherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Mother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2FatherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Father_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2PaternityEst_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2FedFunded_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2IveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Pid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Mci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Monthly_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1FosterCareBegin_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1FatherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1MotherIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1MotherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Mother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1FatherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Father_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1PaternityEst_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1FedFunded_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Birth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1IveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Ssn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Pid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Mci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherPaymentDue_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherArrearage_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLastPayment_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLastPayment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmpl_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmpl_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherRace_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherApNo_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherAddress_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherInsPolicy_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherIns_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherHealthIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherDeath_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherAlias_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherOtherSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherPrimarySsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherPid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Father_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherInformation_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherPaymentDue_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherArrearage_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLastPayment_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLastPayment_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmpl_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmpl_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherSex_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherRace_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherBirth_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherZipOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherStateOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherCityOld_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherApNo_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLine2Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLine1Old_ADDR'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherAddress_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherInsPolicy_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherIns_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherHealthIns_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherDeath_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherIveCase_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherAlias_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherOtherSsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherPrimarySsn_NUMB'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherPid_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherMci_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Mother_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherInformation_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtPaymentType_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderEffective_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderFrequency_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrder_AMNT'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderState_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderCity_NAME'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrder_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'File_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrder_INDC'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'ApplicationCounty_IDNO'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'IveCaseStatus_CODE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Approved_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Application_DATE'

GO
EXEC sys.sp_dropextendedproperty @name=N'Null' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'

GO
EXEC sys.sp_dropextendedproperty @name=N'1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'

GO
/****** Object:  Table [dbo].[LoadIveReferral_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
DROP TABLE [dbo].[LoadIveReferral_T1]
GO
/****** Object:  Table [dbo].[LoadIveReferral_T1]    Script Date: 4/7/2015 12:53:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoadIveReferral_T1](
	[Seq_IDNO] [numeric](19, 0) IDENTITY(1,1) NOT NULL,
	[Rec_ID] [char](1) NOT NULL,
	[Application_DATE] [char](8) NOT NULL,
	[Approved_DATE] [char](8) NOT NULL,
	[IveCaseStatus_CODE] [char](1) NOT NULL,
	[ApplicationCounty_IDNO] [char](3) NOT NULL,
	[CourtOrder_INDC] [char](1) NOT NULL,
	[File_ID] [char](10) NOT NULL,
	[CourtOrder_DATE] [char](8) NOT NULL,
	[CourtOrderCity_NAME] [char](15) NOT NULL,
	[CourtOrderState_CODE] [char](2) NOT NULL,
	[CourtOrder_AMNT] [char](10) NOT NULL,
	[CourtOrderFrequency_CODE] [char](5) NOT NULL,
	[CourtOrderEffective_INDC] [char](1) NOT NULL,
	[CourtPaymentType_CODE] [char](1) NOT NULL,
	[MotherInformation_INDC] [char](1) NOT NULL,
	[Mother_NAME] [char](24) NOT NULL,
	[MotherMci_IDNO] [char](10) NOT NULL,
	[MotherPid_IDNO] [char](10) NOT NULL,
	[MotherPrimarySsn_NUMB] [char](9) NOT NULL,
	[MotherOtherSsn_NUMB] [char](9) NOT NULL,
	[MotherAlias_NAME] [char](24) NOT NULL,
	[MotherIveCase_IDNO] [char](10) NOT NULL,
	[MotherDeath_DATE] [char](8) NOT NULL,
	[MotherHealthIns_INDC] [char](1) NOT NULL,
	[MotherIns_NAME] [char](15) NOT NULL,
	[MotherInsPolicy_ID] [char](15) NOT NULL,
	[MotherAddress_CODE] [char](1) NOT NULL,
	[MotherLine1Old_ADDR] [char](31) NOT NULL,
	[MotherLine2Old_ADDR] [char](31) NOT NULL,
	[MotherApNo_ADDR] [char](5) NOT NULL,
	[MotherCityOld_ADDR] [char](16) NOT NULL,
	[MotherStateOld_ADDR] [char](2) NOT NULL,
	[MotherZipOld_ADDR] [char](9) NOT NULL,
	[MotherBirth_DATE] [char](8) NOT NULL,
	[MotherRace_CODE] [char](2) NOT NULL,
	[MotherSex_CODE] [char](1) NOT NULL,
	[MotherEmpl_CODE] [char](1) NOT NULL,
	[MotherEmpl_NAME] [char](35) NOT NULL,
	[MotherEmplLine1Old_ADDR] [char](31) NOT NULL,
	[MotherEmplLine2Old_ADDR] [char](31) NOT NULL,
	[MotherEmplCityOld_ADDR] [char](16) NOT NULL,
	[MotherEmplStateOld_ADDR] [char](2) NOT NULL,
	[MotherEmplZipOld_ADDR] [char](9) NOT NULL,
	[MotherLastPayment_DATE] [char](8) NOT NULL,
	[MotherLastPayment_AMNT] [char](5) NOT NULL,
	[MotherArrearage_AMNT] [char](5) NOT NULL,
	[MotherPaymentDue_DATE] [char](8) NOT NULL,
	[FatherInformation_INDC] [char](1) NOT NULL,
	[Father_NAME] [char](24) NOT NULL,
	[FatherMci_IDNO] [char](10) NOT NULL,
	[FatherPid_IDNO] [char](10) NOT NULL,
	[FatherPrimarySsn_NUMB] [char](9) NOT NULL,
	[FatherOtherSsn_NUMB] [char](9) NOT NULL,
	[FatherAlias_NAME] [char](24) NOT NULL,
	[FatherIveCase_IDNO] [char](10) NOT NULL,
	[FatherDeath_DATE] [char](8) NOT NULL,
	[FatherHealthIns_INDC] [char](1) NOT NULL,
	[FatherIns_NAME] [char](15) NOT NULL,
	[FatherInsPolicy_ID] [char](15) NOT NULL,
	[FatherAddress_CODE] [char](1) NOT NULL,
	[FatherLine1Old_ADDR] [char](31) NOT NULL,
	[FatherLine2Old_ADDR] [char](31) NOT NULL,
	[FatherApNo_ADDR] [char](5) NOT NULL,
	[FatherCityOld_ADDR] [char](16) NOT NULL,
	[FatherStateOld_ADDR] [char](2) NOT NULL,
	[FatherZipOld_ADDR] [char](9) NOT NULL,
	[FatherBirth_DATE] [char](8) NOT NULL,
	[FatherRace_CODE] [char](2) NOT NULL,
	[FatherSex_CODE] [char](1) NOT NULL,
	[FatherEmpl_CODE] [char](1) NOT NULL,
	[FatherEmpl_NAME] [char](35) NOT NULL,
	[FatherEmplLine1Old_ADDR] [char](31) NOT NULL,
	[FatherEmplLine2Old_ADDR] [char](31) NOT NULL,
	[FatherEmplCityOld_ADDR] [char](16) NOT NULL,
	[FatherEmplStateOld_ADDR] [char](2) NOT NULL,
	[FatherEmplZipOld_ADDR] [char](9) NOT NULL,
	[FatherLastPayment_DATE] [char](8) NOT NULL,
	[FatherLastPayment_AMNT] [char](5) NOT NULL,
	[FatherArrearage_AMNT] [char](5) NOT NULL,
	[FatherPaymentDue_DATE] [char](8) NOT NULL,
	[Child1Mci_IDNO] [char](10) NOT NULL,
	[Child1Pid_IDNO] [char](10) NOT NULL,
	[Child1Ssn_NUMB] [char](9) NOT NULL,
	[Child1IveCase_IDNO] [char](10) NOT NULL,
	[Child1_NAME] [char](24) NOT NULL,
	[Child1Birth_DATE] [char](8) NOT NULL,
	[Child1FedFunded_INDC] [char](1) NOT NULL,
	[Child1PaternityEst_INDC] [char](1) NOT NULL,
	[Child1Father_NAME] [char](24) NOT NULL,
	[Child1FatherIveCase_IDNO] [char](10) NOT NULL,
	[Child1Mother_NAME] [char](24) NOT NULL,
	[Child1MotherIveCase_IDNO] [char](10) NOT NULL,
	[Child1MotherIns_INDC] [char](1) NOT NULL,
	[Child1FatherIns_INDC] [char](1) NOT NULL,
	[Child1FosterCareBegin_DATE] [char](8) NOT NULL,
	[Child1Monthly_AMNT] [char](10) NOT NULL,
	[Child2Mci_IDNO] [char](10) NOT NULL,
	[Child2Pid_IDNO] [char](10) NOT NULL,
	[Child2Ssn_NUMB] [char](9) NOT NULL,
	[Child2IveCase_IDNO] [char](10) NOT NULL,
	[Child2_NAME] [char](24) NOT NULL,
	[Child2Birth_DATE] [char](8) NOT NULL,
	[Child2FedFunded_INDC] [char](1) NOT NULL,
	[Child2PaternityEst_INDC] [char](1) NOT NULL,
	[Child2Father_NAME] [char](24) NOT NULL,
	[Child2FatherIveCase_IDNO] [char](10) NOT NULL,
	[Child2Mother_NAME] [char](24) NOT NULL,
	[Child2MotherIveCase_IDNO] [char](10) NOT NULL,
	[Child2MotherIns_INDC] [char](1) NOT NULL,
	[Child2FatherIns_INDC] [char](1) NOT NULL,
	[Child2FosterCareBegin_DATE] [char](8) NOT NULL,
	[Child2Monthly_AMNT] [char](10) NOT NULL,
	[Child3Mci_IDNO] [char](10) NOT NULL,
	[Child3Pid_IDNO] [char](10) NOT NULL,
	[Child3Ssn_NUMB] [char](9) NOT NULL,
	[Child3IveCase_IDNO] [char](10) NOT NULL,
	[Child3_NAME] [char](24) NOT NULL,
	[Child3Birth_DATE] [char](8) NOT NULL,
	[Child3FedFunded_INDC] [char](1) NOT NULL,
	[Child3PaternityEst_INDC] [char](1) NOT NULL,
	[Child3Father_NAME] [char](24) NOT NULL,
	[Child3FatherIveCase_IDNO] [char](10) NOT NULL,
	[Child3Mother_NAME] [char](24) NOT NULL,
	[Child3MotherIveCase_IDNO] [char](10) NOT NULL,
	[Child3MotherIns_INDC] [char](1) NOT NULL,
	[Child3FatherIns_INDC] [char](1) NOT NULL,
	[Child3FosterCareBegin_DATE] [char](8) NOT NULL,
	[Child3Monthly_AMNT] [char](10) NOT NULL,
	[Child4Mci_IDNO] [char](10) NOT NULL,
	[Child4Pid_IDNO] [char](10) NOT NULL,
	[Child4Ssn_NUMB] [char](9) NOT NULL,
	[Child4IveCase_IDNO] [char](10) NOT NULL,
	[Child4_NAME] [char](24) NOT NULL,
	[Child4Birth_DATE] [char](8) NOT NULL,
	[Child4FedFunded_INDC] [char](1) NOT NULL,
	[Child4PaternityEst_INDC] [char](1) NOT NULL,
	[Child4Father_NAME] [char](24) NOT NULL,
	[Child4FatherIveCase_IDNO] [char](10) NOT NULL,
	[Child4Mother_NAME] [char](24) NOT NULL,
	[Child4MotherIveCase_IDNO] [char](10) NOT NULL,
	[Child4MotherIns_INDC] [char](1) NOT NULL,
	[Child4FatherIns_INDC] [char](1) NOT NULL,
	[Child4FosterCareBegin_DATE] [char](8) NOT NULL,
	[Child4Monthly_AMNT] [char](10) NOT NULL,
	[Child5Mci_IDNO] [char](10) NOT NULL,
	[Child5Pid_IDNO] [char](10) NOT NULL,
	[Child5Ssn_NUMB] [char](9) NOT NULL,
	[Child5IveCase_IDNO] [char](10) NOT NULL,
	[Child5_NAME] [char](24) NOT NULL,
	[Child5Birth_DATE] [char](8) NOT NULL,
	[Child5FedFunded_INDC] [char](1) NOT NULL,
	[Child5PaternityEst_INDC] [char](1) NOT NULL,
	[Child5Father_NAME] [char](24) NOT NULL,
	[Child5FatherIveCase_IDNO] [char](10) NOT NULL,
	[Child5Mother_NAME] [char](24) NOT NULL,
	[Child5MotherIveCase_IDNO] [char](10) NOT NULL,
	[Child5MotherIns_INDC] [char](1) NOT NULL,
	[Child5FatherIns_INDC] [char](1) NOT NULL,
	[Child5FosterCareBegin_DATE] [char](8) NOT NULL,
	[Child5Monthly_AMNT] [char](10) NOT NULL,
	[Child6Mci_IDNO] [char](10) NOT NULL,
	[Child6Pid_IDNO] [char](10) NOT NULL,
	[Child6Ssn_NUMB] [char](9) NOT NULL,
	[Child6IveCase_IDNO] [char](10) NOT NULL,
	[Child6_NAME] [char](24) NOT NULL,
	[Child6Birth_DATE] [char](8) NOT NULL,
	[Child6FedFunded_INDC] [char](1) NOT NULL,
	[Child6PaternityEst_INDC] [char](1) NOT NULL,
	[Child6Father_NAME] [char](24) NOT NULL,
	[Child6FatherIveCase_IDNO] [char](10) NOT NULL,
	[Child6Mother_NAME] [char](24) NOT NULL,
	[Child6MotherIveCase_IDNO] [char](10) NOT NULL,
	[Child6MotherIns_INDC] [char](1) NOT NULL,
	[Child6FatherIns_INDC] [char](1) NOT NULL,
	[Child6FosterCareBegin_DATE] [char](8) NOT NULL,
	[Child6Monthly_AMNT] [char](10) NOT NULL,
	[WorkerLast_NAME] [char](9) NOT NULL,
	[MotherAddressNormalization_CODE] [char](1) NOT NULL,
	[MotherLine1_ADDR] [varchar](50) NOT NULL,
	[MotherLine2_ADDR] [varchar](50) NOT NULL,
	[MotherCity_ADDR] [char](28) NOT NULL,
	[MotherState_ADDR] [char](2) NOT NULL,
	[MotherZip_ADDR] [char](15) NOT NULL,
	[MotherEmplAddressNormalization_CODE] [char](1) NOT NULL,
	[MotherEmplLine1_ADDR] [varchar](50) NOT NULL,
	[MotherEmplLine2_ADDR] [varchar](50) NOT NULL,
	[MotherEmplCity_ADDR] [char](28) NOT NULL,
	[MotherEmplState_ADDR] [char](2) NOT NULL,
	[MotherEmplZip_ADDR] [char](15) NOT NULL,
	[FatherAddressNormalization_CODE] [char](1) NOT NULL,
	[FatherLine1_ADDR] [varchar](50) NOT NULL,
	[FatherLine2_ADDR] [varchar](50) NOT NULL,
	[FatherCity_ADDR] [char](28) NOT NULL,
	[FatherState_ADDR] [char](2) NOT NULL,
	[FatherZip_ADDR] [char](15) NOT NULL,
	[FatherEmplAddressNormalization_CODE] [char](1) NOT NULL,
	[FatherEmplLine1_ADDR] [varchar](50) NOT NULL,
	[FatherEmplLine2_ADDR] [varchar](50) NOT NULL,
	[FatherEmplCity_ADDR] [char](28) NOT NULL,
	[FatherEmplState_ADDR] [char](2) NOT NULL,
	[FatherEmplZip_ADDR] [char](15) NOT NULL,
	[FileLoad_DATE] [date] NOT NULL,
	[Process_INDC] [char](1) NOT NULL,
 CONSTRAINT [LIREF_I1] PRIMARY KEY CLUSTERED 
(
	[Seq_IDNO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
EXEC sys.sp_addextendedproperty @name=N'1', @value=N'Specifies the system generated sequence number to maintain uniqueness.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Seq_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Detailed record type. D - FACTS detailed record' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Rec_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Foster Care Application Date in CCYYMMD format' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Application_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Foster Care Approval Date in CCYYMMD format' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Approved_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Foster Care Case Status.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'IveCaseStatus_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'County from which application was received.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'ApplicationCounty_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates existing Court Order.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrder_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court file identification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'File_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court Order Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrder_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court Order City name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderCity_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court Order State code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderState_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court Order Amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrder_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court Order Frequency.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderFrequency_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates court order still in effect.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtOrderEffective_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Court order payment type.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'CourtPaymentType_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Mother Information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherInformation_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Mother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s MCI Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s PID number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherPid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s Primary SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherPrimarySsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s Other SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherOtherSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s Alias Name 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherAlias_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s – DFS Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s – Date of death' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherDeath_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates mother health/medical insurance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherHealthIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s health medical company name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherIns_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s health or medical policy number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherInsPolicy_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s address code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherAddress_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Street address Line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Street Address Line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Address Apartment number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherApNo_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Address City' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Address State' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Address Zip Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Birth date in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Race code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherRace_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Sex code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Employer Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmpl_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Employer Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmpl_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Employer Street Address Line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Employer Street Address Line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Employer City' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Employer State' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Employer Zip Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s date of Last Payment /Collection' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLastPayment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s amount of Last Payment/Collection' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLastPayment_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s amount of Arrearage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherArrearage_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s payment Due Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherPaymentDue_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Father Information.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherInformation_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Father_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s MCI Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherMci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s PID Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherPid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Primary SSN Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherPrimarySsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Other SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherOtherSsn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Alias Name 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherAlias_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s DFS Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father‘s Date of death' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherDeath_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates father health/medical insurance.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherHealthIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s health/Medical Company name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherIns_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s Insurance Policy Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherInsPolicy_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s address code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherAddress_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Street Address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Street Address Line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Address Apartment number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherApNo_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Address City' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Address State' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Address Zip Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Birth date in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherBirth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Race code.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherRace_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Sex code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherSex_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother’s Employer Indicator.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmpl_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Employer Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmpl_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Employer Street Address Line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplLine1Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Employer Street Address Line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplLine2Old_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Employer City' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplCityOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Employer State' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplStateOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father’s Employer Zip Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplZipOld_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s Date of Last Payment /Collection' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLastPayment_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s amount of Last Payment/Collection' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLastPayment_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s amount of Arrearage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherArrearage_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s Payment Due Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherPaymentDue_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 MCI Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Mci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 PID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Pid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 – DFS Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1IveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 Date of Birth in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the child’s placement Federally Funded or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1FedFunded_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Paternity has been established or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1PaternityEst_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 Father’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Father_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 DFS Father’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1FatherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 Mother’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Mother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 DFS Mother’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1MotherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child is covered by the Mother’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1MotherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child is covered by the Father’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1FatherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 Date Placed in Foster Care in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1FosterCareBegin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child1 Monthly Maintenance Payment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child1Monthly_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 MCI Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Mci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 PID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Pid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 – DFS Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2IveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 Date of Birth in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the child2 placement Federally Funded or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2FedFunded_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 Paternity has been established or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2PaternityEst_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 Father’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Father_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 DFS Father’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2FatherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 Mother’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Mother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 DFS Mother’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2MotherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child2 is covered by the Mother’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2MotherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child2 is covered by the Father’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2FatherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 Date Placed in Foster Care in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2FosterCareBegin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child2 Monthly Maintenance Payment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child2Monthly_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 MCI Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Mci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 PID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Pid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 – DFS Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3IveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 Date of Birth in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the child3 placement Federally Funded or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3FedFunded_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 Paternity has been established or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3PaternityEst_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 Father’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Father_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 DFS Father’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3FatherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 Mother’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Mother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 DFS Mother’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3MotherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child3 is covered by the Mother’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3MotherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child3 is covered by the Father’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3FatherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 Date Placed in Foster Care in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3FosterCareBegin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child3 Monthly Maintenance Payment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child3Monthly_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 MCI Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Mci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 PID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Pid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 – DFS Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4IveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 Date of Birth in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the child4 placement Federally Funded or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4FedFunded_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 Paternity has been established or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4PaternityEst_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 Father’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Father_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 DFS Father’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4FatherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 Mother’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Mother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 DFS Mother’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4MotherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child4 is covered by the Mother’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4MotherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child4 is covered by the Father’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4FatherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 Date Placed in Foster Care in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4FosterCareBegin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child4 Monthly Maintenance Payment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child4Monthly_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 MCI Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Mci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 PID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Pid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 – DFS Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5IveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 Date of Birth in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the child5 placement Federally Funded or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5FedFunded_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 Paternity has been established or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5PaternityEst_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 Father’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Father_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 DFS Father’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5FatherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 Mother’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Mother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 DFS Mother’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5MotherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child5 is covered by the Mother’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5MotherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child5 is covered by the Father’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5FatherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 Date Placed in Foster Care in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5FosterCareBegin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child5 Monthly Maintenance Payment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child5Monthly_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 MCI Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Mci_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 PID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Pid_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 SSN' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Ssn_NUMB'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 – DFS Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6IveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 Date of Birth in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Birth_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the child6 placement Federally Funded or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6FedFunded_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 Paternity has been established or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6PaternityEst_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 Father’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Father_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 DFS Father’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6FatherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 Mother’s Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Mother_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 DFS Mother’s Case Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6MotherIveCase_IDNO'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child6 is covered by the Mother’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6MotherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates Child6 is covered by the Father’s Insurance/Medical.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6FatherIns_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 Date Placed in Foster Care in CCYYMMDD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6FosterCareBegin_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Child6 Monthly Maintenance Payment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Child6Monthly_AMNT'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Worker’s Last Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'WorkerLast_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s address normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s normalized address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s normalized address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s normalized address city name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s normalized address state code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s normalized address Zip code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s employer addresses normalization code.  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s employer normalized address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s employer normalized address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s employer normalized address city name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s employer normalized address state code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Mother''s employer normalized address Zip code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'MotherEmplZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s address normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s normalized address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s normalized address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s normalized address city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s normalized address state code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s normalized address zip code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s employer addresses normalization code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplAddressNormalization_CODE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s employer normalized address line 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplLine1_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s employer normalized address line 2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplLine2_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s employer normalized address city name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplCity_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s employer normalized address state code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplState_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Father''s employer normalized address zip code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FatherEmplZip_ADDR'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Date file was loaded into the table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'FileLoad_DATE'
GO
EXEC sys.sp_addextendedproperty @name=N'Null', @value=N'Indicates the record was processed or not.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1', @level2type=N'COLUMN',@level2name=N'Process_INDC'
GO
EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'This table is used to load the IV-E referral data file from the Foster Care.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoadIveReferral_T1'
GO
