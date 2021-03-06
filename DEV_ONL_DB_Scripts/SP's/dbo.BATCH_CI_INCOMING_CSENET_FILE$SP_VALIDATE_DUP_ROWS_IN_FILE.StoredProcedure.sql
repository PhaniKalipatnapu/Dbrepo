/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_VALIDATE_DUP_ROWS_IN_FILE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------
Procedure Name       : BATCH_CI_INCOMING_CSENET_FILE$SP_VALIDATE_DUP_ROWS_IN_FILE
Programmer Name      : IMP Team
Description          : To Find Duplicate Rows in the file AND Reject those transactions
Frequency            : DAILY
Developed On         :04/04/2011
Called By            : None
Called On            :
------------------------------------------------------------------------------------------
Modified By          :
Modified On          :
Version No           :  
----------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_VALIDATE_DUP_ROWS_IN_FILE] (
 @Ad_Start_DATE            DATE,
 @Ac_JobProcess_IDNO       CHAR(7),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE$SP_VALIDATE_DUP_ROWS_IN_FILE',
          @Lc_No_INDC               CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_LowDate_TEXT          CHAR(8) = '01/01/0001',
          @Lc_ErrorTypeError_CODE   CHAR(1) = 'E',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_DuplicateX1_INDC      CHAR(1) = 'X',
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(2000),
          @Ln_RowCount_QNTY         NUMERIC,
          @Ln_FetchStatus_QNTY      NUMERIC,
          @Lc_Msg_CODE              CHAR(5),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'DUPLICATE ROW CHECKING';
   SET @Ls_Sqldata_TEXT = 'Start_DATE: ' + CAST(@Ad_Start_DATE AS VARCHAR) + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   UPDATE A
      SET Process_INDC = @Lc_DuplicateX1_INDC
     FROM (SELECT TransHeader_IDNO,
                  Message_ID,
                  IoDirection_CODE,
                  StateFips_CODE,
                  CountyFips_CODE,
                  OfficeFips_CODE,
                  IVDOutOfStateCase_ID,
                  IVDOutOfStateFips_CODE,
                  IVDOutOfStateCountyFips_CODE,
                  IVDOutOfStateOfficeFips_CODE,
                  CsenetTran_ID,
                  Function_CODE,
                  Action_CODE,
                  Reason_CODE,
                  Case_IDNO,
                  Stored_DATE,
                  TranStatus_CODE,
                  Received_DATE,
                  ReceivedYearMonth_NUMB,
                  AttachDue_DATE,
                  SntToStHost_CODE,
                  ProcComplete_CODE,
                  InterstateFrmsPrint_CODE,
                  WorkerUpdate_ID,
                  Transaction_DATE,
                  ActionResolution_DATE,
                  Attachments_INDC,
                  CaseData_QNTY,
                  Ncp_QNTY,
                  NcpLoc_QNTY,
                  Participant_QNTY,
                  Order_QNTY,
                  Collection_QNTY,
                  Info_QNTY,
                  End_DATE,
                  CsenetVersion_ID,
                  ErrorReason_CODE,
                  Received_DTTM,
                  RejectReason_CODE,
                  Process_INDC
             FROM (SELECT TransHeader_IDNO,
                          Message_ID,
                          IoDirection_CODE,
                          StateFips_CODE,
                          CountyFips_CODE,
                          OfficeFips_CODE,
                          IVDOutOfStateCase_ID,
                          IVDOutOfStateFips_CODE,
                          IVDOutOfStateCountyFips_CODE,
                          IVDOutOfStateOfficeFips_CODE,
                          CsenetTran_ID,
                          Function_CODE,
                          Action_CODE,
                          Reason_CODE,
                          Case_IDNO,
                          Stored_DATE,
                          TranStatus_CODE,
                          Received_DATE,
                          ReceivedYearMonth_NUMB,
                          AttachDue_DATE,
                          SntToStHost_CODE,
                          ProcComplete_CODE,
                          InterstateFrmsPrint_CODE,
                          WorkerUpdate_ID,
                          Transaction_DATE,
                          ActionResolution_DATE,
                          Attachments_INDC,
                          CaseData_QNTY,
                          Ncp_QNTY,
                          NcpLoc_QNTY,
                          Participant_QNTY,
                          Order_QNTY,
                          Collection_QNTY,
                          Info_QNTY,
                          End_DATE,
                          CsenetVersion_ID,
                          ErrorReason_CODE,
                          Received_DTTM,
                          RejectReason_CODE,
                          Process_INDC,
                          ROW_NUMBER() OVER(PARTITION BY b.TransHeader_IDNO, b.Transaction_DATE, b.IVDOutOfStateFips_CODE ORDER BY Transaction_DATE) AS rno
                     FROM LTHBL_Y1 b
                    WHERE b.Process_INDC = @Lc_No_INDC) AS fci
            WHERE fci.rno <> 1) A;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Lc_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @Ls_DescriptionError_TEXT = ISNULL(@Ls_Sql_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '');
    END;

   SET @Ls_Sql_TEXT = 'DUPLICATE ROW CHECKING IN LCDBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Start_DATE: ' + CAST(@Ad_Start_DATE AS VARCHAR) + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   UPDATE A
      SET Process_INDC = @Lc_DuplicateX1_INDC
     FROM (SELECT TransHeader_IDNO,
                  IVDOutOfStateFips_CODE,
                  Transaction_DATE,
                  TypeCase_CODE,
                  StatusCase_CODE,
                  PaymentLine1Old_ADDR,
                  PaymentLine2Old_ADDR,
                  PaymentCityOld_ADDR,
                  PaymentStateOld_ADDR,
                  PaymentZipOld_ADDR,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Suffix_NAME,
                  ContactLine1Old_ADDR,
                  ContactLine2Old_ADDR,
                  ContactCityOld_ADDR,
                  ContactStateOld_ADDR,
                  ContactZipOld_ADDR,
                  ContactPhone_NUMB,
                  PhoneExtensionCount_NUMB,
                  RespondingFile_ID,
                  Fax_NUMB,
                  Contact_EML,
                  InitiatingFile_ID,
                  AcctSendPaymentsBankNo_TEXT,
                  SendPaymentsRouting_ID,
                  StateWithCej_CODE,
                  PayFipsSt_CODE,
                  PayFipsCnty_CODE,
                  PayFipsSub_CODE,
                  NondisclosureFinding_INDC,
                  Process_INDC,
                  Normalization_CODE,
                  PaymentLine1_ADDR,
                  PaymentLine2_ADDR,
                  PaymentCity_ADDR,
                  PaymentState_ADDR,
                  PaymentZip_ADDR,
                  CountCdNormalization_QNTY,
                  ContactLine1_ADDR,
                  ContactLine2_ADDR,
                  ContactCity_ADDR,
                  ContactState_ADDR,
                  ContactZip_ADDR
             FROM (SELECT TransHeader_IDNO,
                          IVDOutOfStateFips_CODE,
                          Transaction_DATE,
                          TypeCase_CODE,
                          StatusCase_CODE,
                          PaymentLine1Old_ADDR,
                          PaymentLine2Old_ADDR,
                          PaymentCityOld_ADDR,
                          PaymentStateOld_ADDR,
                          PaymentZipOld_ADDR,
                          Last_NAME,
                          First_NAME,
                          Middle_NAME,
                          Suffix_NAME,
                          ContactLine1Old_ADDR,
                          ContactLine2Old_ADDR,
                          ContactCityOld_ADDR,
                          ContactStateOld_ADDR,
                          ContactZipOld_ADDR,
                          ContactPhone_NUMB,
                          PhoneExtensionCount_NUMB,
                          RespondingFile_ID,
                          Fax_NUMB,
                          Contact_EML,
                          InitiatingFile_ID,
                          AcctSendPaymentsBankNo_TEXT,
                          SendPaymentsRouting_ID,
                          StateWithCej_CODE,
                          PayFipsSt_CODE,
                          PayFipsCnty_CODE,
                          PayFipsSub_CODE,
                          NondisclosureFinding_INDC,
                          Process_INDC,
                          Normalization_CODE,
                          PaymentLine1_ADDR,
                          PaymentLine2_ADDR,
                          PaymentCity_ADDR,
                          PaymentState_ADDR,
                          PaymentZip_ADDR,
                          CountCdNormalization_QNTY,
                          ContactLine1_ADDR,
                          ContactLine2_ADDR,
                          ContactCity_ADDR,
                          ContactState_ADDR,
                          ContactZip_ADDR,
                          ROW_NUMBER() OVER(PARTITION BY l.TransHeader_IDNO, l.Transaction_DATE, l.IVDOutOfStateFips_CODE ORDER BY Transaction_DATE) AS rno
                     FROM LCDBL_Y1 l
                    WHERE l.Process_INDC = @Lc_No_INDC) AS fci
            WHERE fci.rno <> 1) A;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END;

   SET @Ls_Sql_TEXT = 'DUPLICATE ROW CHECKING IN LNBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Start_DATE: ' + CAST(@Ad_Start_DATE AS VARCHAR) + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   UPDATE A
      SET Process_INDC = @Lc_DuplicateX1_INDC
     FROM (SELECT TransHeader_IDNO,
                  IVDOutOfStateFips_CODE,
                  Transaction_DATE,
                  MemberMci_IDNO,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Suffix_NAME,
                  MemberSsn_NUMB,
                  Birth_DATE,
                  Race_CODE,
                  MemberSex_CODE,
                  PlaceOfBirth_NAME,
                  FtHeight_TEXT,
                  InHeight_TEXT,
                  DescriptionWeightLbs_TEXT,
                  ColorHair_CODE,
                  ColorEyes_CODE,
                  DistinguishingMarks_TEXT,
                  Alias1Ssn_NUMB,
                  Alias2Ssn_NUMB,
                  PossiblyDangerous_INDC,
                  Maiden_NAME,
                  FatherOrMomMaiden_NAME,
                  Process_INDC
             FROM (SELECT TransHeader_IDNO,
                          IVDOutOfStateFips_CODE,
                          Transaction_DATE,
                          MemberMci_IDNO,
                          Last_NAME,
                          First_NAME,
                          Middle_NAME,
                          Suffix_NAME,
                          MemberSsn_NUMB,
                          Birth_DATE,
                          Race_CODE,
                          MemberSex_CODE,
                          PlaceOfBirth_NAME,
                          FtHeight_TEXT,
                          InHeight_TEXT,
                          DescriptionWeightLbs_TEXT,
                          ColorHair_CODE,
                          ColorEyes_CODE,
                          DistinguishingMarks_TEXT,
                          Alias1Ssn_NUMB,
                          Alias2Ssn_NUMB,
                          PossiblyDangerous_INDC,
                          Maiden_NAME,
                          FatherOrMomMaiden_NAME,
                          Process_INDC,
                          ROW_NUMBER() OVER(PARTITION BY l.TransHeader_IDNO, l.Transaction_DATE, l.IVDOutOfStateFips_CODE ORDER BY Transaction_DATE) AS rno
                     FROM LNBLK_Y1 l
                    WHERE l.Process_INDC = @Lc_No_INDC) AS fci
            WHERE fci.rno <> 1) A;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END;

   SET @Ls_Sql_TEXT = 'DUPLICATE ROW CHECKING IN LNLBL_Y1';
   SET @Ls_Sqldata_TEXT = 'Start_DATE: ' + CAST(@Ad_Start_DATE AS VARCHAR) + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   UPDATE A
      SET Process_INDC = @Lc_DuplicateX1_INDC
     FROM (SELECT TransHeader_IDNO,
                  IVDOutOfStateFips_CODE,
                  Transaction_DATE,
                  ResidentialLine1Old_ADDR,
                  ResidentialLine2Old_ADDR,
                  ResidentialCityOld_ADDR,
                  ResidentialStateOld_ADDR,
                  ResidentialZip1Old_ADDR,
                  ResidentialZip2Old_ADDR,
                  MailingLine1Old_ADDR,
                  MailingLine2Old_ADDR,
                  MailingCityOld_ADDR,
                  MailingStateOld_ADDR,
                  MailingZip1Old_ADDR,
                  MailingZip2Old_ADDR,
                  EffectiveResidential_DATE,
                  EndResidential_DATE,
                  ResidentialConfirmed_CODE,
                  EffectiveMailing_DATE,
                  EndMailing_DATE,
                  MailingConfirmed_CODE,
                  HomePhone_NUMB,
                  WorkPhone_NUMB,
                  DriversLicenseState_CODE,
                  DriversLicenseNo_TEXT,
                  Alias1First_NAME,
                  Alias1Middle_NAME,
                  Alias1Last_NAME,
                  Alias1Suffix_NAME,
                  Alias2First_NAME,
                  Alias2Middle_NAME,
                  Alias2Last_NAME,
                  Alias2Suffix_NAME,
                  Alias3First_NAME,
                  Alias3Middle_NAME,
                  Alias3Last_NAME,
                  Alias3Suffix_NAME,
                  SpouseLast_NAME,
                  SpouseFirst_NAME,
                  SpouseMiddle_NAME,
                  SpouseSuffix_NAME,
                  Occupation_TEXT,
                  EmployerEin_ID,
                  Employer_NAME,
                  EmployerLine1Old_ADDR,
                  EmployerLine2Old_ADDR,
                  EmployerCityOld_ADDR,
                  EmployerStateOld_ADDR,
                  EmployerZip1Old_ADDR,
                  EmployerZip2Old_ADDR,
                  EmployerPhone_NUMB,
                  EffectiveEmployer_DATE,
                  EndEmployer_DATE,
                  EmployerConfirmed_INDC,
                  WageQtr_CODE,
                  WageYear_NUMB,
                  Wage_AMNT,
                  InsCarrier_NAME,
                  PolicyInsNo_TEXT,
                  LastResLine1Old_ADDR,
                  LastResLine2Old_ADDR,
                  LastResCityOld_ADDR,
                  LastResStateOld_ADDR,
                  LastResZip1Old_ADDR,
                  LastResZip2Old_ADDR,
                  LastResAddress_DATE,
                  LastMailLine1Old_ADDR,
                  LastMailLine2Old_ADDR,
                  LastMailCityOld_ADDR,
                  LastMailStateOld_ADDR,
                  LastMailZip1Old_ADDR,
                  LastMailZip2Old_ADDR,
                  LastMailAddress_DATE,
                  LastEmployer_NAME,
                  LastEmployer_DATE,
                  LastEmployerLine1Old_ADDR,
                  LastEmployerLine2Old_ADDR,
                  LastEmployerCityOld_ADDR,
                  LastEmployerStateOld_ADDR,
                  LastEmployerZip1Old_ADDR,
                  LastEmployerZip2Old_ADDR,
                  LastEmployerEffective_DATE,
                  Employer2Ein_ID,
                  Employer2_NAME,
                  Employer2Line1Old_ADDR,
                  Employer2Line2Old_ADDR,
                  Employer2CityOld_ADDR,
                  Employer2StateOld_ADDR,
                  Employer2Zip1Old_ADDR,
                  Employer2Zip2Old_ADDR,
                  Employer2Phone_NUMB,
                  EffectiveEmployer2_DATE,
                  EndEmployer2_DATE,
                  Employer2Confirmed_INDC,
                  Wage2Qtr_CODE,
                  Wage2Year_NUMB,
                  Wage2_AMNT,
                  Employer3Ein_ID,
                  Employer3_NAME,
                  Employer3Line1Old_ADDR,
                  Employer3Line2Old_ADDR,
                  Employer3CityOld_ADDR,
                  Employer3StateOld_ADDR,
                  Employer3Zip1Old_ADDR,
                  Employer3Zip2Old_ADDR,
                  Employer3Phone_NUMB,
                  EffectiveEmployer3_DATE,
                  EndEmployer3_DATE,
                  Employer3Confirmed_INDC,
                  Wage3Qtr_CODE,
                  Wage3Year_NUMB,
                  Wage3_AMNT,
                  ProfessionalLicenses_TEXT,
                  Process_INDC,
                  ResNormalization_CODE,
                  ResidentialLine1_ADDR,
                  ResidentialLine2_ADDR,
                  ResidentialCity_ADDR,
                  ResidentialState_ADDR,
                  ResidentialZip_ADDR,
                  MailNormalization_CODE,
                  MailingLine1_ADDR,
                  MailingLine2_ADDR,
                  MailingCity_ADDR,
                  MailingState_ADDR,
                  MailingZip_ADDR,
                  EmpNormalization_CODE,
                  EmployerLine1_ADDR,
                  EmployerLine2_ADDR,
                  EmployerCity_ADDR,
                  EmployerState_ADDR,
                  EmployerZip_ADDR,
                  LastResNormalization_CODE,
                  LastResidentialLine1_ADDR,
                  LastResidentialLine2_ADDR,
                  LastResidentialCity_ADDR,
                  LastResidentialState_ADDR,
                  LastResZip_ADDR,
                  LastMailNormalization_CODE,
                  LastMailLine1_ADDR,
                  LastMailLine2_ADDR,
                  LastMailCity_ADDR,
                  LastMailState_ADDR,
                  LastMailZip_ADDR,
                  LastEmpNormalization_CODE,
                  LastEmployerLine1_ADDR,
                  LastEmployerLine2_ADDR,
                  LastEmployerCity_ADDR,
                  LastEmployerState_ADDR,
                  LastEmployerZip_ADDR,
                  Emp2Normalization_CODE,
                  Employer2Line1_ADDR,
                  Employer2Line2_ADDR,
                  Employer2City_ADDR,
                  Employer2State_ADDR,
                  Employer2Zip_ADDR,
                  Emp3Normalization_CODE,
                  Employer3Line1_ADDR,
                  Employer3Line2_ADDR,
                  Employer3City_ADDR,
                  Employer3State_ADDR,
                  Employer3Zip_ADDR
             FROM (SELECT TransHeader_IDNO,
                          IVDOutOfStateFips_CODE,
                          Transaction_DATE,
                          ResidentialLine1Old_ADDR,
                          ResidentialLine2Old_ADDR,
                          ResidentialCityOld_ADDR,
                          ResidentialStateOld_ADDR,
                          ResidentialZip1Old_ADDR,
                          ResidentialZip2Old_ADDR,
                          MailingLine1Old_ADDR,
                          MailingLine2Old_ADDR,
                          MailingCityOld_ADDR,
                          MailingStateOld_ADDR,
                          MailingZip1Old_ADDR,
                          MailingZip2Old_ADDR,
                          EffectiveResidential_DATE,
                          EndResidential_DATE,
                          ResidentialConfirmed_CODE,
                          EffectiveMailing_DATE,
                          EndMailing_DATE,
                          MailingConfirmed_CODE,
                          HomePhone_NUMB,
                          WorkPhone_NUMB,
                          DriversLicenseState_CODE,
                          DriversLicenseNo_TEXT,
                          Alias1First_NAME,
                          Alias1Middle_NAME,
                          Alias1Last_NAME,
                          Alias1Suffix_NAME,
                          Alias2First_NAME,
                          Alias2Middle_NAME,
                          Alias2Last_NAME,
                          Alias2Suffix_NAME,
                          Alias3First_NAME,
                          Alias3Middle_NAME,
                          Alias3Last_NAME,
                          Alias3Suffix_NAME,
                          SpouseLast_NAME,
                          SpouseFirst_NAME,
                          SpouseMiddle_NAME,
                          SpouseSuffix_NAME,
                          Occupation_TEXT,
                          EmployerEin_ID,
                          Employer_NAME,
                          EmployerLine1Old_ADDR,
                          EmployerLine2Old_ADDR,
                          EmployerCityOld_ADDR,
                          EmployerStateOld_ADDR,
                          EmployerZip1Old_ADDR,
                          EmployerZip2Old_ADDR,
                          EmployerPhone_NUMB,
                          EffectiveEmployer_DATE,
                          EndEmployer_DATE,
                          EmployerConfirmed_INDC,
                          WageQtr_CODE,
                          WageYear_NUMB,
                          Wage_AMNT,
                          InsCarrier_NAME,
                          PolicyInsNo_TEXT,
                          LastResLine1Old_ADDR,
                          LastResLine2Old_ADDR,
                          LastResCityOld_ADDR,
                          LastResStateOld_ADDR,
                          LastResZip1Old_ADDR,
                          LastResZip2Old_ADDR,
                          LastResAddress_DATE,
                          LastMailLine1Old_ADDR,
                          LastMailLine2Old_ADDR,
                          LastMailCityOld_ADDR,
                          LastMailStateOld_ADDR,
                          LastMailZip1Old_ADDR,
                          LastMailZip2Old_ADDR,
                          LastMailAddress_DATE,
                          LastEmployer_NAME,
                          LastEmployer_DATE,
                          LastEmployerLine1Old_ADDR,
                          LastEmployerLine2Old_ADDR,
                          LastEmployerCityOld_ADDR,
                          LastEmployerStateOld_ADDR,
                          LastEmployerZip1Old_ADDR,
                          LastEmployerZip2Old_ADDR,
                          LastEmployerEffective_DATE,
                          Employer2Ein_ID,
                          Employer2_NAME,
                          Employer2Line1Old_ADDR,
                          Employer2Line2Old_ADDR,
                          Employer2CityOld_ADDR,
                          Employer2StateOld_ADDR,
                          Employer2Zip1Old_ADDR,
                          Employer2Zip2Old_ADDR,
                          Employer2Phone_NUMB,
                          EffectiveEmployer2_DATE,
                          EndEmployer2_DATE,
                          Employer2Confirmed_INDC,
                          Wage2Qtr_CODE,
                          Wage2Year_NUMB,
                          Wage2_AMNT,
                          Employer3Ein_ID,
                          Employer3_NAME,
                          Employer3Line1Old_ADDR,
                          Employer3Line2Old_ADDR,
                          Employer3CityOld_ADDR,
                          Employer3StateOld_ADDR,
                          Employer3Zip1Old_ADDR,
                          Employer3Zip2Old_ADDR,
                          Employer3Phone_NUMB,
                          EffectiveEmployer3_DATE,
                          EndEmployer3_DATE,
                          Employer3Confirmed_INDC,
                          Wage3Qtr_CODE,
                          Wage3Year_NUMB,
                          Wage3_AMNT,
                          ProfessionalLicenses_TEXT,
                          Process_INDC,
                          ResNormalization_CODE,
                          ResidentialLine1_ADDR,
                          ResidentialLine2_ADDR,
                          ResidentialCity_ADDR,
                          ResidentialState_ADDR,
                          ResidentialZip_ADDR,
                          MailNormalization_CODE,
                          MailingLine1_ADDR,
                          MailingLine2_ADDR,
                          MailingCity_ADDR,
                          MailingState_ADDR,
                          MailingZip_ADDR,
                          EmpNormalization_CODE,
                          EmployerLine1_ADDR,
                          EmployerLine2_ADDR,
                          EmployerCity_ADDR,
                          EmployerState_ADDR,
                          EmployerZip_ADDR,
                          LastResNormalization_CODE,
                          LastResidentialLine1_ADDR,
                          LastResidentialLine2_ADDR,
                          LastResidentialCity_ADDR,
                          LastResidentialState_ADDR,
                          LastResZip_ADDR,
                          LastMailNormalization_CODE,
                          LastMailLine1_ADDR,
                          LastMailLine2_ADDR,
                          LastMailCity_ADDR,
                          LastMailState_ADDR,
                          LastMailZip_ADDR,
                          LastEmpNormalization_CODE,
                          LastEmployerLine1_ADDR,
                          LastEmployerLine2_ADDR,
                          LastEmployerCity_ADDR,
                          LastEmployerState_ADDR,
                          LastEmployerZip_ADDR,
                          Emp2Normalization_CODE,
                          Employer2Line1_ADDR,
                          Employer2Line2_ADDR,
                          Employer2City_ADDR,
                          Employer2State_ADDR,
                          Employer2Zip_ADDR,
                          Emp3Normalization_CODE,
                          Employer3Line1_ADDR,
                          Employer3Line2_ADDR,
                          Employer3City_ADDR,
                          Employer3State_ADDR,
                          Employer3Zip_ADDR,
                          ROW_NUMBER() OVER(PARTITION BY l.TransHeader_IDNO, l.Transaction_DATE, l.IVDOutOfStateFips_CODE ORDER BY Transaction_DATE) AS rno
                     FROM LNLBL_Y1 l
                    WHERE l.Process_INDC = @Lc_No_INDC) AS fci
            WHERE fci.rno <> 1) A;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END;

   SET @Ls_Sql_TEXT = 'DUPLICATE ROW CHECKING IN LPBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Start_DATE: ' + CAST(@Ad_Start_DATE AS VARCHAR) + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   UPDATE A
      SET Process_INDC = @Lc_DuplicateX1_INDC
     FROM (SELECT TransHeader_IDNO,
                  IVDOutOfStateFips_CODE,
                  Transaction_DATE,
                  BlockSeq_NUMB,
                  MemberMci_IDNO,
                  Last_NAME,
                  First_NAME,
                  Middle_NAME,
                  Suffix_NAME,
                  Birth_DATE,
                  MemberSsn_NUMB,
                  MemberSex_CODE,
                  Race_CODE,
                  Relationship_CODE,
                  ParticipantStatus_CODE,
                  ChildRelationshipNcp_CODE,
                  ParticipantLine1Old_ADDR,
                  ParticipantLine2Old_ADDR,
                  ParticipantCityOld_ADDR,
                  ParticipantStateOld_ADDR,
                  ParticipantZip1Old_ADDR,
                  ParticipantZip2Old_ADDR,
                  Employer_NAME,
                  EmployerLine1Old_ADDR,
                  EmployerLine2Old_ADDR,
                  EmployerCityOld_ADDR,
                  EmployerStateOld_ADDR,
                  EmployerZip1Old_ADDR,
                  EmployerZip2Old_ADDR,
                  EinEmployer_ID,
                  ConfirmedAddress_INDC,
                  ConfirmedAddress_DATE,
                  ConfirmedEmployer_INDC,
                  ConfirmedEmployer_DATE,
                  WorkPhone_NUMB,
                  PlaceOfBirth_NAME,
                  ChildStateResidence_CODE,
                  ChildPaternityStatus_CODE,
                  Process_INDC,
                  PartNormalization_CODE,
                  ParticipantLine1_ADDR,
                  ParticipantLine2_ADDR,
                  ParticipantCity_ADDR,
                  ParticipantState_ADDR,
                  ParticipantZip_ADDR,
                  EmpNormalization_CODE,
                  EmployerLine1_ADDR,
                  EmployerLine2_ADDR,
                  EmployerCity_ADDR,
                  EmployerState_ADDR,
                  EmployerZip_ADDR
             FROM (SELECT TransHeader_IDNO,
                          IVDOutOfStateFips_CODE,
                          Transaction_DATE,
                          BlockSeq_NUMB,
                          MemberMci_IDNO,
                          Last_NAME,
                          First_NAME,
                          Middle_NAME,
                          Suffix_NAME,
                          Birth_DATE,
                          MemberSsn_NUMB,
                          MemberSex_CODE,
                          Race_CODE,
                          Relationship_CODE,
                          ParticipantStatus_CODE,
                          ChildRelationshipNcp_CODE,
                          ParticipantLine1Old_ADDR,
                          ParticipantLine2Old_ADDR,
                          ParticipantCityOld_ADDR,
                          ParticipantStateOld_ADDR,
                          ParticipantZip1Old_ADDR,
                          ParticipantZip2Old_ADDR,
                          Employer_NAME,
                          EmployerLine1Old_ADDR,
                          EmployerLine2Old_ADDR,
                          EmployerCityOld_ADDR,
                          EmployerStateOld_ADDR,
                          EmployerZip1Old_ADDR,
                          EmployerZip2Old_ADDR,
                          EinEmployer_ID,
                          ConfirmedAddress_INDC,
                          ConfirmedAddress_DATE,
                          ConfirmedEmployer_INDC,
                          ConfirmedEmployer_DATE,
                          WorkPhone_NUMB,
                          PlaceOfBirth_NAME,
                          ChildStateResidence_CODE,
                          ChildPaternityStatus_CODE,
                          Process_INDC,
                          PartNormalization_CODE,
                          ParticipantLine1_ADDR,
                          ParticipantLine2_ADDR,
                          ParticipantCity_ADDR,
                          ParticipantState_ADDR,
                          ParticipantZip_ADDR,
                          EmpNormalization_CODE,
                          EmployerLine1_ADDR,
                          EmployerLine2_ADDR,
                          EmployerCity_ADDR,
                          EmployerState_ADDR,
                          EmployerZip_ADDR,
                          ROW_NUMBER() OVER(PARTITION BY l.TransHeader_IDNO, l.Transaction_DATE, l.IVDOutOfStateFips_CODE, l.BlockSeq_NUMB ORDER BY Transaction_DATE) AS rno
                     FROM LPBLK_Y1 l
                    WHERE l.Process_INDC = @Lc_No_INDC) AS fci
            WHERE fci.rno <> 1) A;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END;

   SET @Ls_Sql_TEXT = 'DUPLICATE ROW CHECKING IN LOBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Start_DATE: ' + CAST(@Ad_Start_DATE AS VARCHAR) + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   UPDATE A
      SET Process_INDC = @Lc_DuplicateX1_INDC
     FROM (SELECT TransHeader_IDNO,
                  IVDOutOfStateFips_CODE,
                  Transaction_DATE,
                  BlockSeq_NUMB,
                  StFipsOrder_CODE,
                  CntyFipsOrder_CODE,
                  SubFipsOrder_CODE,
                  Order_IDNO,
                  FilingOrder_DATE,
                  TypeOrder_CODE,
                  DebtType_CODE,
                  OrderFreq_CODE,
                  OrderFreq_AMNT,
                  OrderEffective_DATE,
                  OrderEnd_DATE,
                  OrderCancel_DATE,
                  FreqOrderArrears_CODE,
                  FreqOrderArrears_AMNT,
                  OrderArrearsTotal_AMNT,
                  ArrearsAfdcFrom_DATE,
                  ArrearsAfdcThru_DATE,
                  ArrearsAfdc_AMNT,
                  ArrearsNonAfdcFrom_DATE,
                  ArrearsNonAfdcThru_DATE,
                  ArrearsNonAfdc_AMNT,
                  FosterCareFrom_DATE,
                  FosterCareThru_DATE,
                  FosterCare_AMNT,
                  MedicalFrom_DATE,
                  MedicalThru_DATE,
                  Medical_AMNT,
                  MedicalOrdered_INDC,
                  TribunalCaseNo_TEXT,
                  OfLastPayment_DATE,
                  ControllingOrderFlag_CODE,
                  NewOrderFlag_INDC,
                  File_ID,
                  Process_INDC
             FROM (SELECT TransHeader_IDNO,
                          IVDOutOfStateFips_CODE,
                          Transaction_DATE,
                          BlockSeq_NUMB,
                          StFipsOrder_CODE,
                          CntyFipsOrder_CODE,
                          SubFipsOrder_CODE,
                          Order_IDNO,
                          FilingOrder_DATE,
                          TypeOrder_CODE,
                          DebtType_CODE,
                          OrderFreq_CODE,
                          OrderFreq_AMNT,
                          OrderEffective_DATE,
                          OrderEnd_DATE,
                          OrderCancel_DATE,
                          FreqOrderArrears_CODE,
                          FreqOrderArrears_AMNT,
                          OrderArrearsTotal_AMNT,
                          ArrearsAfdcFrom_DATE,
                          ArrearsAfdcThru_DATE,
                          ArrearsAfdc_AMNT,
                          ArrearsNonAfdcFrom_DATE,
                          ArrearsNonAfdcThru_DATE,
                          ArrearsNonAfdc_AMNT,
                          FosterCareFrom_DATE,
                          FosterCareThru_DATE,
                          FosterCare_AMNT,
                          MedicalFrom_DATE,
                          MedicalThru_DATE,
                          Medical_AMNT,
                          MedicalOrdered_INDC,
                          TribunalCaseNo_TEXT,
                          OfLastPayment_DATE,
                          ControllingOrderFlag_CODE,
                          NewOrderFlag_INDC,
                          File_ID,
                          Process_INDC,
                          ROW_NUMBER() OVER(PARTITION BY l.TransHeader_IDNO, l.Transaction_DATE, l.IVDOutOfStateFips_CODE, l.BlockSeq_NUMB ORDER BY Transaction_DATE) AS rno
                     FROM LOBLK_Y1 l
                    WHERE l.Process_INDC = @Lc_No_INDC) AS fci
            WHERE fci.rno <> 1) A;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END;

   SET @Ls_Sql_TEXT = 'DUPLICATE ROW CHECKING IN LCBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Start_DATE: ' + CAST(@Ad_Start_DATE AS VARCHAR) + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   UPDATE A
      SET Process_INDC = @Lc_DuplicateX1_INDC
     FROM (SELECT TransHeader_IDNO,
                  IVDOutOfStateFips_CODE,
                  Transaction_DATE,
                  BlockSeq_NUMB,
                  Collection_DATE,
                  Posting_DATE,
                  Payment_AMNT,
                  PaymentSource_CODE,
                  PaymentMethod_CODE,
                  Rdfi_ID,
                  RdfiAcctNo_TEXT,
                  Process_INDC
             FROM (SELECT TransHeader_IDNO,
                          IVDOutOfStateFips_CODE,
                          Transaction_DATE,
                          BlockSeq_NUMB,
                          Collection_DATE,
                          Posting_DATE,
                          Payment_AMNT,
                          PaymentSource_CODE,
                          PaymentMethod_CODE,
                          Rdfi_ID,
                          RdfiAcctNo_TEXT,
                          Process_INDC,
                          ROW_NUMBER() OVER(PARTITION BY l.TransHeader_IDNO, l.Transaction_DATE, l.IVDOutOfStateFips_CODE, l.BlockSeq_NUMB ORDER BY Transaction_DATE) AS rno
                     FROM LCBLK_Y1 l
                    WHERE l.Process_INDC = @Lc_No_INDC) AS fci
            WHERE fci.rno <> 1) A;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END;

   SET @Ls_Sql_TEXT = 'DUPLICATE ROW CHECKING IN LIBLK_Y1';
   SET @Ls_Sqldata_TEXT = 'Start_DATE: ' + CAST(@Ad_Start_DATE AS VARCHAR) + ', JobProcess_IDNO: ' + @Ac_JobProcess_IDNO + ', Run_DATE: ' + CAST(@Ad_Run_DATE AS VARCHAR);

   UPDATE A
      SET Process_INDC = @Lc_DuplicateX1_INDC
     FROM (SELECT TransHeader_IDNO,
                  IVDOutOfStateFips_CODE,
                  Transaction_DATE,
                  StatusChange_CODE,
                  CaseNew_ID,
                  InfoLine1_TEXT,
                  InfoLine2_TEXT,
                  InfoLine3_TEXT,
                  InfoLine4_TEXT,
                  InfoLine5_TEXT,
                  Process_INDC
             FROM (SELECT TransHeader_IDNO,
                          IVDOutOfStateFips_CODE,
                          Transaction_DATE,
                          StatusChange_CODE,
                          CaseNew_ID,
                          InfoLine1_TEXT,
                          InfoLine2_TEXT,
                          InfoLine3_TEXT,
                          InfoLine4_TEXT,
                          InfoLine5_TEXT,
                          Process_INDC,
                          ROW_NUMBER() OVER(PARTITION BY l.TransHeader_IDNO, l.Transaction_DATE, l.IVDOutOfStateFips_CODE ORDER BY Transaction_DATE) AS rno
                     FROM LIBLK_Y1 l
                    WHERE l.Process_INDC = @Lc_No_INDC) AS fci
            WHERE fci.rno <> 1) A;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END;

   DECLARE @Ln_DuplicateCur_TransHeader_IDNO       NUMERIC(12),
           @Ld_DuplicateCur_Transaction_DATE       DATE,
           @Lc_DuplicateCur_IVDOutOfStateFips_CODE CHAR(2),
           @Lc_DuplicateCur_Case_IDNO              CHAR(6),
           @Lc_DuplicateCur_Function_CODE          CHAR(3),
           @Lc_DuplicateCur_Action_CODE            CHAR(1),
           @Lc_DuplicateCur_Reason_CODE            CHAR(5);
   DECLARE Duplicate_CUR INSENSITIVE CURSOR FOR
    SELECT b.TransHeader_IDNO,
           (CAST((CASE LTRIM(b.Transaction_DATE)
                   WHEN ''
                    THEN @Lc_LowDate_TEXT
                   ELSE b.Transaction_DATE
                  END) AS DATETIME2)) AS Transaction_DATE,
           b.IVDOutOfStateFips_CODE,
           b.Case_IDNO,
           b.Function_CODE,
           b.Action_CODE,
           b.Reason_CODE
      FROM LTHBL_Y1 b
     WHERE b.Process_INDC = @Lc_No_INDC
       AND b.Stored_DATE = @Ad_Start_DATE
       AND EXISTS (SELECT TransHeader_IDNO,
                          Transaction_DATE,
                          IVDOutOfStateFips_CODE
                     FROM CTHB_Y1 A
                    WHERE A.TransHeader_IDNO = b.TransHeader_IDNO
                      AND A.Transaction_DATE = CAST((CASE LTRIM(b.Transaction_DATE)
                                                      WHEN ''
                                                       THEN @Lc_LowDate_TEXT
                                                      ELSE b.Transaction_DATE
                                                     END) AS DATETIME2)
                      AND A.IVDOutOfStateFips_CODE = b.IVDOutOfStateFips_CODE);

   OPEN Duplicate_CUR;

   FETCH NEXT FROM Duplicate_CUR INTO @Ln_DuplicateCur_TransHeader_IDNO, @Ld_DuplicateCur_Transaction_DATE, @Lc_DuplicateCur_IVDOutOfStateFips_CODE, @Lc_DuplicateCur_Case_IDNO, @Lc_DuplicateCur_Function_CODE, @Lc_DuplicateCur_Action_CODE, @Lc_DuplicateCur_Reason_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Bate entries for duplicate records
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATE_Y1 ENTRY FOR DUPLICATE';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO:' + ISNULL(@Ln_DuplicateCur_TransHeader_IDNO, '') + ' Transaction_DATE: ' + ISNULL(CAST(@Ld_DuplicateCur_Transaction_DATE AS VARCHAR), '') + ' IVDOutOfStateFips_CODE: ' + ISNULL(@Lc_DuplicateCur_IVDOutOfStateFips_CODE, '') + ' Case_IDNO =' + ISNULL(@Lc_DuplicateCur_Case_IDNO, '') + ' Function_CODE =' + ISNULL(@Lc_DuplicateCur_Function_CODE, '') + ' Action_CODE =' + ISNULL(@Lc_DuplicateCur_Action_CODE, '') + ' Reason_CODE =' + ISNULL(@Lc_DuplicateCur_Reason_CODE, '');

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = 'BATCH_CI_INCOMING_CSENET_FILE',
      @As_Procedure_NAME           = @Ls_Procedure_NAME,
      @Ac_Job_ID                   = @Ac_JobProcess_IDNO,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
      @An_Line_NUMB                = 1,
      @Ac_Error_CODE               = 'E0145',
      @As_DescriptionError_TEXT    = 'DUPLICATE TRANSACTION FOUND IN FILE ',
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END;

     FETCH NEXT FROM Duplicate_CUR INTO @Ln_DuplicateCur_TransHeader_IDNO, @Ld_DuplicateCur_Transaction_DATE, @Lc_DuplicateCur_IVDOutOfStateFips_CODE, @Lc_DuplicateCur_Case_IDNO, @Lc_DuplicateCur_Function_CODE, @Lc_DuplicateCur_Action_CODE, @Lc_DuplicateCur_Reason_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Duplicate_CUR') IN (0, 1)
    BEGIN
     CLOSE Duplicate_CUR;
     DEALLOCATE Duplicate_CUR;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'Duplicate_CUR') IN (0, 1)
    BEGIN
     CLOSE Duplicate_CUR;
     DEALLOCATE Duplicate_CUR;
    END;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER(),
           @Li_ErrorLine_NUMB INT = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
