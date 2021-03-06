/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_CASE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_CASE
Programmer Name	:	IMP Team.
Description		:	This procedure loads all case data blocks in to extract_case_data_blocks table FOR each row of pending_request table
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INIT_TRAN
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_CASE]
 @An_Case_IDNO             NUMERIC(6),
 @Ac_StateFips_CODE        CHAR(2),
 @An_TransHeader_IDNO      NUMERIC(12),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ErrorLine_NUMB               INT = 0,
          @Lc_Space_TEXT                   CHAR(1) = ' ',
          @Lc_CaseStatusOpen_CODE          CHAR(1) = 'O',
          @Lc_StatusNoDataFound_CODE       CHAR(1) = 'N',
          @Lc_RespondingState_CODE         CHAR(1) = 'R',
          @Lc_RespondingInternational_CODE CHAR(1) = 'Y',
          @Lc_RespondingTribal_CODE        CHAR(1) = 'S',
          @Lc_Hyphen_TEXT                  CHAR(1) = '-',
          @Lc_Yes_INDC                     CHAR(1) = 'Y',
          @Lc_No_TEXT                      CHAR(1) = 'N',
          @Lc_RelationshipCaseCp_TEXT      CHAR(1) = 'C',
          @Lc_RelationshipCaseDp_TEXT      CHAR(1) = 'D',
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_TypeCaseA1_IDNO              CHAR(1) = 'A',
          @Lc_TypeCaseS1_IDNO              CHAR(1) = 'S',
          @Lc_TypeCaseN1_IDNO              CHAR(1) = 'N',
          @Lc_TypeCaseM1_IDNO              CHAR(1) = 'M',
          @Lc_TypeCase_IDNO                CHAR(1) = ' ',
          @Lc_StatusCase_CODE              CHAR(1) = ' ',
          @Lc_NondisclosureFinding_TEXT    CHAR(1) = ' ',
          @Lc_CaseCategoryFn_CODE          CHAR(2) = 'FN',
          @Lc_CaseCategoryMo_CODE          CHAR(2) = 'MO',
          @Lc_AddrStatePayment_CODE        CHAR(2) = ' ',
          @Lc_ContactState_ADDR            CHAR(2) = ' ',
          @Lc_StateWithCej_CODE            CHAR(2) = ' ',
          @Lc_PayFipsSt_CODE               CHAR(2) = ' ',
          @Lc_PayFipsSub_CODE              CHAR(2) = '00',
          @Lc_AddressTypeState_CODE        CHAR(3) = 'STA',
          @Lc_AddressSubTypeSdu_CODE       CHAR(3) = 'SDU',
          @Lc_PayFipsCnty_CODE             CHAR(3) = ' ',
          @Lc_Suffix_NAME                  CHAR(4) = ' ',
          @Lc_PaymentZip_ADDR              CHAR(9) = ' ',
          @Lc_ContactZip_ADDR              CHAR(9) = ' ',
          @Lc_SendPaymentsRouting_CODE     CHAR(10) = ' ',
          @Lc_First_NAME                   CHAR(16) = ' ',
          @Lc_RespondingFile_ID            CHAR(17) = ' ',
          @Lc_InitiatingFile_ID            CHAR(17) = ' ',
          @Lc_PaymentCity_ADDR             CHAR(18) = ' ',
          @Lc_ContactCity_ADDR             CHAR(18) = ' ',
          @Lc_Last_NAME                    CHAR(20) = ' ',
          @Lc_Middle_NAME                  CHAR(20) = ' ',
          @Lc_AcctSendPaymentsBank_TEXT    CHAR(20) = ' ',
          @Lc_PaymentLine1_ADDR            CHAR(25) = ' ',
          @Lc_PaymentLine2_ADDR            CHAR(25) = ' ',
          @Lc_ContactLine1_ADDR            CHAR(25) = ' ',
          @Lc_ContactLine2_ADDR            CHAR(25) = ' ',
          @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_CASE',
          @Ls_Contact_EML                  VARCHAR(100) = ' ',
          @Ld_High_DATE                    DATE = '12/31/9999';
  DECLARE @Ln_Office_IDNO                NUMERIC(3),
          @Ln_ContactPhoneExtension_NUMB NUMERIC(6) = 0,
          @Ln_ContactPhone_NUMB          NUMERIC(10, 0) = 0,
          @Ln_Fax_NUMB                   NUMERIC(15) = 0,
          @Li_Error_NUMB                 INT = 0,
          @Li_Rowcount_QNTY              INT,
          @Lc_Empty_TEXT                 CHAR(1) = '',
          @Lc_CaseTypeCsenet_CODE        CHAR(1),
          @Lc_RespondInit_CODE           CHAR(1),
          @Lc_CaseCategory_CODE          CHAR(2),
          @Lc_OthStateFips_CODE          CHAR(2),
          @Lc_Worker_ID                  CHAR(30),
          @Ls_Sql_TEXT                   VARCHAR(2000),
          @Ls_Sqldata_TEXT               VARCHAR(4000),
          @Ld_Generated_DATE             DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT CSPR_Y1 - CASE data Block';
   SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Lc_OthStateFips_CODE = a.IVDOutOfStateFips_CODE,
          @Ld_Generated_DATE = a.Generated_DATE
     FROM CSPR_Y1 a
    WHERE a.Request_IDNO = CAST(@An_TransHeader_IDNO AS NUMERIC(12))
      AND a.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'SELECT CASE TYPE AND Status_CODE';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', StatusCase_CODE = ' + ISNULL(@Lc_CaseStatusOpen_CODE, '');

   SELECT @Lc_TypeCase_IDNO = a.TypeCase_CODE,
          @Lc_StatusCase_CODE = a.StatusCase_CODE,
          @Lc_CaseCategory_CODE = a.CaseCategory_CODE,
          @Lc_InitiatingFile_ID = a.File_ID,
          @Lc_PayFipsCnty_CODE = a.County_IDNO,
          @Lc_Worker_ID = a.Worker_ID,
          @Ln_Office_IDNO = a.Office_IDNO,
          @Lc_RespondInit_CODE = a.RespondInit_CODE
     FROM CASE_Y1 a
    WHERE a.Case_IDNO = @An_Case_IDNO;

   -- Bug 12959 : Open condition removed to get values of closed cases.
   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @As_DescriptionError_TEXT = 'NO CASE INFORMATION FOUND';
     SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;

     RAISERROR(50001,16,1);
    END;

   IF (@Lc_RespondInit_CODE = @Lc_RespondingState_CODE
        OR @Lc_RespondInit_CODE = @Lc_RespondingInternational_CODE
        OR @Lc_RespondInit_CODE = @Lc_RespondingTribal_CODE)
    BEGIN
     SET @Lc_RespondingFile_ID = @Lc_InitiatingFile_ID;
     SET @Lc_InitiatingFile_ID = @Lc_Space_TEXT;
    END;

   SET @Ls_Sql_TEXT = 'SELECT CONTACT ADDRESS ' + CAST(@An_Case_IDNO AS VARCHAR);
   SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_Worker_ID, '') + ', BeginEmployment_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Office_IDNO = ' + ISNULL(CAST(@Ln_Office_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT DISTINCT
          @Lc_ContactLine1_ADDR = SUBSTRING(g.Line1_ADDR, 1, 25),
          @Lc_ContactLine2_ADDR = SUBSTRING(g.Line2_ADDR, 1, 25),
          @Lc_ContactCity_ADDR = SUBSTRING(g.City_ADDR, 1, 18),
          @Lc_ContactState_ADDR = g.State_ADDR,
          @Lc_ContactZip_ADDR = SUBSTRING(REPLACE(g.Zip_ADDR, @Lc_Hyphen_TEXT, @Lc_Empty_TEXT), 1, 9),
          @Ln_ContactPhone_NUMB = CAST(SUBSTRING(CAST(g.Phone_NUMB AS VARCHAR), 1, 10) AS NUMERIC),
          @Lc_Last_NAME = SUBSTRING(e.Last_NAME, 1, 21),
          @Lc_First_NAME = SUBSTRING(e.First_NAME, 1, 16),
          @Lc_Middle_NAME = SUBSTRING(e.Middle_NAME, 1, 16),
          @Lc_Suffix_NAME = SUBSTRING(e.Suffix_NAME, 1, 3),
          @Ln_Fax_NUMB = CAST(SUBSTRING(CAST(g.Fax_NUMB AS VARCHAR), 1, 10) AS NUMERIC),
          @Ls_Contact_EML = g.Contact_EML
     FROM USEM_Y1 e,
          OFIC_Y1 f,
          OTHP_Y1 g
    WHERE e.Worker_ID = @Lc_Worker_ID
      AND e.EndValidity_DATE = @Ld_High_DATE
      AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
      AND f.Office_IDNO = @Ln_Office_IDNO
      AND f.EndValidity_DATE = @Ld_High_DATE
      AND g.OtherParty_IDNO = f.OtherParty_IDNO
      AND g.EndValidity_DATE = @Ld_High_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @As_DescriptionError_TEXT = 'NO CASE ADDRESS FOUND FOR :CASE ' + CAST(@An_Case_IDNO AS VARCHAR) + ', WORKER:' + @Lc_Worker_ID + ', OFFICE:' + CAST(@Ln_Office_IDNO AS VARCHAR) + ', RUNDATE:' + CAST(@Ad_Run_DATE AS VARCHAR);
     SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;
    END;

   SET @Ls_Sql_TEXT = 'SELECT PAYMENT ADDRESS ' + CAST(@An_Case_IDNO AS VARCHAR);
   SET @Ls_Sqldata_TEXT = 'StateFips_CODE = ' + ISNULL(@Ac_StateFips_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_AddressTypeState_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_AddressSubTypeSdu_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Lc_PaymentLine1_ADDR = SUBSTRING(a.Line1_ADDR, 1, 25),
          @Lc_PaymentLine2_ADDR = SUBSTRING(a.Line2_ADDR, 1, 25),
          @Lc_PaymentCity_ADDR = SUBSTRING(a.City_ADDR, 1, 18),
          @Lc_AddrStatePayment_CODE = a.State_ADDR,
          @Lc_PaymentZip_ADDR = SUBSTRING(REPLACE(a.Zip_ADDR, @Lc_Hyphen_TEXT, @Lc_Empty_TEXT), 1, 9),
          @Lc_PayFipsSt_CODE = a.StateFips_CODE,
          @Lc_PayFipsCnty_CODE = a.CountyFips_CODE,
          @Lc_PayFipsSub_CODE = a.OfficeFips_CODE
     FROM FIPS_Y1 a
    WHERE a.StateFips_CODE = @Ac_StateFips_CODE
      AND a.TypeAddress_CODE = @Lc_AddressTypeState_CODE
      AND a.SubTypeAddress_CODE = @Lc_AddressSubTypeSdu_CODE
      AND a.EndValidity_DATE = @Ld_High_DATE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @As_DescriptionError_TEXT = 'NO PAYMENT ADDRES FOUND FOR : ' + CAST(@An_Case_IDNO AS VARCHAR) + ' AS_CD_STATE_FIPS ' + ISNULL(@Ac_StateFips_CODE, '');
     SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;
    END;

   SET @Ls_Sql_TEXT = 'INSERT CASE DATA BLOCK RECORD';
   SET @Ls_Sqldata_TEXT = 'TypeCase_IDNO = ' + ISNULL(CAST(@Lc_TypeCase_IDNO AS VARCHAR), '') + 'CaseCategory_CODE = ' + ISNULL(@Lc_CaseCategory_CODE, '');

   IF @Lc_TypeCase_IDNO = @Lc_TypeCaseA1_IDNO
      AND @Lc_CaseCategory_CODE = @Lc_CaseCategoryFn_CODE
    BEGIN
     SET @Lc_CaseTypeCsenet_CODE = @Lc_TypeCaseS1_IDNO;
    END;
   ELSE IF @Lc_TypeCase_IDNO = @Lc_TypeCaseN1_IDNO
      AND @Lc_CaseCategory_CODE = @Lc_CaseCategoryMo_CODE
    BEGIN
     SET @Lc_CaseTypeCsenet_CODE = @Lc_TypeCaseM1_IDNO;
    END;
   ELSE
    BEGIN
     SET @Lc_CaseTypeCsenet_CODE = @Lc_TypeCase_IDNO;
    END;

   SET @Ls_Sql_TEXT = 'SELECT NondisclosureFinding_TEXT';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', FamilyViolence_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   SELECT @Lc_NondisclosureFinding_TEXT = CASE
                                           WHEN COUNT(1) > 0
                                            THEN @Lc_Yes_INDC
                                           ELSE @Lc_No_TEXT
                                          END
     FROM CMEM_Y1 a,
          DEMO_Y1 b
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.MemberMci_IDNO = b.MemberMci_IDNO
      AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseCp_TEXT, @Lc_RelationshipCaseDp_TEXT)
      AND a.FamilyViolence_INDC = @Lc_Yes_INDC;

   SET @Ls_Sql_TEXT = 'INSERT ECDBL_Y1';
   SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_StateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_Generated_DATE AS VARCHAR), '') + ', TypeCase_CODE = ' + ISNULL(@Lc_CaseTypeCsenet_CODE, '') + ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCase_CODE, '') + ', PaymentState_ADDR = ' + ISNULL(@Lc_AddrStatePayment_CODE, '') + ', PaymentZip_ADDR = ' + ISNULL(@Lc_PaymentZip_ADDR, '') + ', Last_NAME = ' + ISNULL(@Lc_Last_NAME, '') + ', First_NAME = ' + ISNULL(@Lc_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_Middle_NAME, '') + ', Suffix_NAME = ' + ISNULL(@Lc_Suffix_NAME, '') + ', ContactState_ADDR = ' + ISNULL(@Lc_ContactState_ADDR, '') + ', ContactZip_ADDR = ' + ISNULL(@Lc_ContactZip_ADDR, '') + ', PhoneExtensionCount_NUMB = ' + ISNULL(CAST(@Ln_ContactPhoneExtension_NUMB AS VARCHAR), '') + ', RespondingFile_ID = ' + ISNULL(@Lc_RespondingFile_ID, '') + ', Fax_NUMB = ' + ISNULL(CAST(@Ln_Fax_NUMB AS VARCHAR), '') + ', Contact_EML = ' + ISNULL(@Ls_Contact_EML, '') + ', InitiatingFile_ID = ' + ISNULL(@Lc_InitiatingFile_ID, '') + ', AcctSendPaymentsBankNo_TEXT = ' + ISNULL(@Lc_AcctSendPaymentsBank_TEXT, '') + ', SendPaymentsRouting_ID = ' + ISNULL(@Lc_SendPaymentsRouting_CODE, '') + ', StateWithCej_CODE = ' + ISNULL(@Lc_StateWithCej_CODE, '') + ', PayFipsSt_CODE = ' + ISNULL(@Lc_PayFipsSt_CODE, '') + ', PayFipsCnty_CODE = ' + ISNULL(@Lc_PayFipsCnty_CODE, '') + ', PayFipsSub_CODE = ' + ISNULL(@Lc_PayFipsSub_CODE, '');

   INSERT ECDBL_Y1
          (TransHeader_IDNO,
           IVDOutOfStateFips_CODE,
           Transaction_DATE,
           TypeCase_CODE,
           StatusCase_CODE,
           PaymentLine1_ADDR,
           PaymentLine2_ADDR,
           PaymentCity_ADDR,
           PaymentState_ADDR,
           PaymentZip_ADDR,
           Last_NAME,
           First_NAME,
           Middle_NAME,
           Suffix_NAME,
           ContactLine1_ADDR,
           ContactLine2_ADDR,
           ContactCity_ADDR,
           ContactState_ADDR,
           ContactZip_ADDR,
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
           NondisclosureFinding_INDC)
   VALUES ( @An_TransHeader_IDNO,
            @Ac_StateFips_CODE,
            @Ld_Generated_DATE,--Transaction_DATE
            @Lc_CaseTypeCsenet_CODE,--TypeCase_CODE
            @Lc_StatusCase_CODE,
            CASE
             WHEN @Lc_PaymentLine1_ADDR IS NULL
              THEN @Lc_Space_TEXT
             ELSE SUBSTRING(@Lc_PaymentLine1_ADDR, 1, 25)
            END,
            CASE
             WHEN @Lc_PaymentLine2_ADDR IS NULL
              THEN @Lc_Space_TEXT
             ELSE SUBSTRING(@Lc_PaymentLine2_ADDR, 1, 25)
            END,
            CASE
             WHEN @Lc_PaymentCity_ADDR IS NULL
              THEN @Lc_Space_TEXT
             ELSE SUBSTRING(@Lc_PaymentCity_ADDR, 1, 18)
            END,
            @Lc_AddrStatePayment_CODE,--PaymentState_ADDR
            @Lc_PaymentZip_ADDR,
            @Lc_Last_NAME,
            @Lc_First_NAME,
            @Lc_Middle_NAME,
            @Lc_Suffix_NAME,
            CASE
             WHEN @Lc_ContactLine1_ADDR IS NULL
              THEN @Lc_Space_TEXT
             ELSE SUBSTRING(@Lc_ContactLine1_ADDR, 1, 25)
            END,
            CASE
             WHEN @Lc_ContactLine2_ADDR IS NULL
              THEN @Lc_Space_TEXT
             ELSE SUBSTRING(@Lc_ContactLine2_ADDR, 1, 25)
            END,
            CASE
             WHEN @Lc_ContactCity_ADDR IS NULL
              THEN @Lc_Space_TEXT
             ELSE SUBSTRING(@Lc_ContactCity_ADDR, 1, 18)
            END,
            @Lc_ContactState_ADDR,
            @Lc_ContactZip_ADDR,
            CASE LEN(CAST(@Ln_ContactPhone_NUMB AS VARCHAR))
             WHEN 10
              THEN @Ln_ContactPhone_NUMB
             ELSE 0
            END,
            @Ln_ContactPhoneExtension_NUMB,
            @Lc_RespondingFile_ID,
            @Ln_Fax_NUMB,
            @Ls_Contact_EML,
            @Lc_InitiatingFile_ID,
            @Lc_AcctSendPaymentsBank_TEXT,
            @Lc_SendPaymentsRouting_CODE,
            @Lc_StateWithCej_CODE,
            @Lc_PayFipsSt_CODE,
            @Lc_PayFipsCnty_CODE,
            @Lc_PayFipsSub_CODE,
            CASE @Lc_NondisclosureFinding_TEXT
             WHEN @Lc_Empty_TEXT
              THEN @Lc_No_TEXT
             ELSE @Lc_NondisclosureFinding_TEXT
            END );

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT CASE DATA BLOCK RECORD FAILED';
     SET @As_DescriptionError_TEXT = 'CASE BLOCK DATA NOT INSERTED.';

     RAISERROR(50001,16,1);
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH;
 END;


GO
