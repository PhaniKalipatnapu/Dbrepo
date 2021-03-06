/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_NCP_LOCATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_NCP_LOCATE
Programmer Name	:	IMP Team.
Description		:	This procedure loads NCP loc data IN to extract_ncp_locate_blocks table FOR each row of pENDing_request table
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
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_NCP_LOCATE]
 @An_Case_IDNO             NUMERIC(6),
 @An_TransHeader_IDNO      NUMERIC(12),
 @Ac_StateFips_CODE        CHAR(2),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ad_Start_DATE            DATE,
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_StatusNoDataFound_CODE      CHAR(1) = 'N',
          @Lc_ActionProvide_CODE          CHAR(1) = 'P',
          @Lc_InsTypeInsurers_CODE        CHAR(1) = 'I',
          @Lc_RelationshipCaseDp_TEXT     CHAR(1) = 'D',
          @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A',
          @Lc_Mailing_ADDR                CHAR(1) = 'M',
          @Lc_VerificationStatusGood_CODE CHAR(1) = 'Y',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_Residential_ADDR            CHAR(1) = 'R',
          @Lc_TypeOthpE1_IDNO             CHAR(1) = 'E',
          @Lc_TypeOthpM1_IDNO             CHAR(1) = 'M',
          @Lc_EmployerConfirmed_INDC      CHAR(1) = ' ',
          @Lc_WageQtr_TEXT                CHAR(1) = ' ',
          @Lc_Employer2Confirmed_INDC     CHAR(1) = ' ',
          @Lc_Wage2Qtr_TEXT               CHAR(1) = ' ',
          @Lc_Employer3Confirmed_INDC     CHAR(1) = ' ',
          @Lc_Wage3Qtr_TEXT               CHAR(1) = ' ',
          @Lc_ResidentialConfirmed_TEXT   CHAR(1) = ' ',
          @Lc_MailingConfirmed_TEXT       CHAR(1) = ' ',
          @Lc_StateInState_CODE           CHAR(2) = 'DE',
          @Lc_IncomeTypeEmployer_CODE     CHAR(2) = 'EM',
          @Lc_StatusGood_CODE             CHAR(2) = 'CG',
          @Lc_TypeIncomeMl_IDNO           CHAR(2) = 'ML',
          @Lc_DriversLicenseState_CODE    CHAR(2) = ' ',
          @Lc_EmployerState_CODE          CHAR(2) = ' ',
          @Lc_LastResState_CODE           CHAR(2) = ' ',
          @Lc_LastMailState_CODE          CHAR(2) = ' ',
          @Lc_LastEmployerState_CODE      CHAR(2) = ' ',
          @Lc_Employer2State_CODE         CHAR(2) = ' ',
          @Lc_Employer3State_CODE         CHAR(2) = ' ',
          @Lc_ResidentialState_CODE       CHAR(2) = ' ',
          @Lc_MailingState_CODE           CHAR(2) = ' ',
          @Lc_FunctionManagestcases_CODE  CHAR(3) = 'MSC',
          @Lc_Alias1Suffix_TEXT           CHAR(3) = ' ',
          @Lc_Alias2Suffix_TEXT           CHAR(3) = ' ',
          @Lc_Alias3Suffix_TEXT           CHAR(3) = ' ',
          @Lc_SpouseSuffix_TEXT           CHAR(3) = ' ',
          @Lc_EmployerZip2_TEXT           CHAR(4) = ' ',
          @Lc_WageYear_TEXT               CHAR(4) = ' ',
          @Lc_LastResZip2_TEXT            CHAR(4) = ' ',
          @Lc_LastMailZip2_TEXT           CHAR(4) = ' ',
          @Lc_LastEmployerZip2_TEXT       CHAR(4) = ' ',
          @Lc_Employer2Zip2_TEXT          CHAR(4) = ' ',
          @Lc_Wage2Year_TEXT              CHAR(4) = ' ',
          @Lc_Employer3Zip2_TEXT          CHAR(4) = ' ',
          @Lc_Wage3Year_TEXT              CHAR(4) = ' ',
          @Lc_ResidentialZip2_TEXT        CHAR(4) = ' ',
          @Lc_MailingZip2_TEXT            CHAR(4) = ' ',
		  @Lc_TypeLicenceDr_IDNO          CHAR(5) = 'DR',
          @Lc_EmployerZip1_TEXT           CHAR(5) = ' ',
          @Lc_LastResZip1_TEXT            CHAR(5) = ' ',
          @Lc_LastMailZip1_TEXT           CHAR(5) = ' ',
          @Lc_LastEmployerZip1_TEXT       CHAR(5) = ' ',
          @Lc_Employer2Zip1_TEXT          CHAR(5) = ' ',
          @Lc_Employer3Zip1_TEXT          CHAR(5) = ' ',
          @Lc_ResidentialZip1_TEXT        CHAR(5) = ' ',
          @Lc_MailingZip1_TEXT            CHAR(5) = ' ',
          @Lc_ReasonGsmad_CODE            CHAR(5) = 'GSMAD',
          @Lc_ReasonGsmde_CODE            CHAR(5) = 'GSMDE',
          @Lc_EmployerEin_TEXT            CHAR(9) = ' ',
          @Lc_Employer2Ein_TEXT           CHAR(9) = ' ',
          @Lc_Employer3Ein_TEXT           CHAR(9) = ' ',
          @Lc_Alias1First_TEXT            CHAR(16) = ' ',
          @Lc_Alias1Middle_TEXT           CHAR(16) = ' ',
          @Lc_Alias2First_TEXT            CHAR(16) = ' ',
          @Lc_Alias2Middle_TEXT           CHAR(16) = ' ',
          @Lc_Alias3First_TEXT            CHAR(16) = ' ',
          @Lc_Alias3Middle_TEXT           CHAR(16) = ' ',
          @Lc_SpouseFirst_TEXT            CHAR(16) = ' ',
          @Lc_SpouseMiddle_TEXT           CHAR(16) = ' ',
          @Lc_EmployerCity_TEXT           CHAR(18) = ' ',
          @Lc_LastResCity_TEXT            CHAR(18) = ' ',
          @Lc_LastMailCity_TEXT           CHAR(18) = ' ',
          @Lc_LastEmployerCity_TEXT       CHAR(18) = ' ',
          @Lc_Employer2City_TEXT          CHAR(18) = ' ',
          @Lc_Employer3City_TEXT          CHAR(18) = ' ',
          @Lc_ResidentialCity_TEXT        CHAR(18) = ' ',
          @Lc_MailingCity_TEXT            CHAR(18) = ' ',
          @Lc_DriversLicense_TEXT         CHAR(20) = ' ',
          @Lc_PolicyInsNo_TEXT            CHAR(20) = ' ',
          @Lc_Alias1Last_TEXT             CHAR(21) = ' ',
          @Lc_Alias2Last_TEXT             CHAR(21) = ' ',
          @Lc_Alias3Last_TEXT             CHAR(21) = ' ',
          @Lc_SpouseLast_TEXT             CHAR(21) = ' ',
          @Lc_EmployerLine1_ADDR          CHAR(25) = ' ',
          @Lc_EmployerLine2_ADDR          CHAR(25) = ' ',
          @Lc_LastResidentialLine1_ADDR   CHAR(25) = ' ',
          @Lc_LastResidentialLine2_ADDR   CHAR(25) = ' ',
          @Lc_LastMailLine1_ADDR          CHAR(25) = ' ',
          @Lc_LastMailLine2_ADDR          CHAR(25) = ' ',
          @Lc_LastEmployerLine1_ADDR      CHAR(25) = ' ',
          @Lc_LastEmployerLine2_ADDR      CHAR(25) = ' ',
          @Lc_Employer2Line1_ADDR         CHAR(25) = ' ',
          @Lc_Employer2Line2_ADDR         CHAR(25) = ' ',
          @Lc_Employer3Line1_ADDR         CHAR(25) = ' ',
          @Lc_Employer3Line2_ADDR         CHAR(25) = ' ',
          @Lc_ResidentialLine1_ADDR       CHAR(25) = ' ',
          @Lc_ResidentialLine2_ADDR       CHAR(25) = ' ',
          @Lc_MailingLine1_ADDR           CHAR(25) = ' ',
          @Lc_MailingLine2_ADDR           CHAR(25) = ' ',
          @Lc_Occupation_TEXT             CHAR(32) = ' ',
          @Lc_InsCarrier_NAME             CHAR(36) = ' ',
          @Lc_LastEmployer_TEXT           CHAR(40) = ' ',
          @Lc_Employer2_NAME              CHAR(40) = ' ',
          @Lc_Employer3_NAME              CHAR(40) = ' ',
          @Ls_ProfessionalLicenses_TEXT   VARCHAR(50) = ' ',
          @Ls_Employer_NAME               VARCHAR(60) = ' ',
          @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_NCP_LOCATE',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Ld_EffectiveEmployer_DATE      DATE = '01/01/0001',
          @Ld_EndEmployer_DATE            DATE = '01/01/0001',
          @Ld_LastResAddress_DATE         DATE = '01/01/0001',
          @Ld_LastMailAddress_DATE        DATE = '01/01/0001',
          @Ld_LastEmployer_DATE           DATE = '01/01/0001',
          @Ld_LastEmployerEffective_DATE  DATE = '01/01/0001',
          @Ld_EffectiveEmployer2_DATE     DATE = '01/01/0001',
          @Ld_EndEmployer2_DATE           DATE = '01/01/0001',
          @Ld_EffectiveEmployer3_DATE     DATE = '01/01/0001',
          @Ld_EndEmployer3_DATE           DATE = '01/01/0001',
          @Ld_EffectiveResidential_DATE   DATE = '01/01/0001',
          @Ld_EndResidential_DATE         DATE = '01/01/0001',
          @Ld_EffectiveMailing_DATE       DATE = '01/01/0001',
          @Ld_EndMailing_DATE             DATE = '01/01/0001';
  DECLARE @Ln_Member_IDNO           NUMERIC(10) = 0,
          @Ln_EmployerPhone_NUMB    NUMERIC(10) = 0,
          @Ln_Employer2Phone_NUMB   NUMERIC(10) = 0,
          @Ln_Employer3Phone_NUMB   NUMERIC(10) = 0,
          @Ln_Wage_AMNT             NUMERIC(11, 2) = 0,
          @Ln_Wage2_AMNT            NUMERIC(11, 2) = 0,
          @Ln_Wage3_AMNT            NUMERIC(11, 2) = 0,
          @Ln_HomePhone_NUMB        NUMERIC(15) = 0,
          @Ln_WorkPhone_NUMB        NUMERIC(15) = 0,
          @Li_ErrorLine_NUMB        INT = 0,
          @Li_FoundData_NUMB        INT = 0,
          @Li_AliasRow_QNTY         INT,
          @Li_EmplCurRow_QNTY       INT,
          @Li_Error_NUMB            INT = 0,
          @Li_FetchStatus_NUMB      SMALLINT,
          @Li_Rowcount_QNTY         SMALLINT,
          @Lc_Action_CODE           CHAR(1),
          @Lc_TypeOthp_IDNO         CHAR(1),
          @Lc_OthStateFips_CODE     CHAR(2),
          @Lc_Function_CODE         CHAR(3),
          @Lc_Reason_CODE           CHAR(5),
          @Lc_Msg_CODE              CHAR(5) = '',
          @Ls_Sql_TEXT              VARCHAR(2000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ls_Sqldata_TEXT          VARCHAR(4000),
          @Ld_Generated_DATE        DATE,
          @Alias_CUR                CURSOR,
          @Empl_CUR                 CURSOR;
  DECLARE @Lc_AliasCur_First_NAME  CHAR(15),
          @Lc_AliasCur_Mi_NAME     CHAR(20),
          @Lc_AliasCur_Last_NAME   CHAR(20),
          @Lc_AliasCur_Suffix_NAME CHAR(4);
  DECLARE @Lc_EmplCur_OtherParty_TEXT CHAR(9),
          @Ld_EmplCur_Begin_DATE      DATE,
          @Ld_EmplCur_End_DATE        DATE,
          @Lc_EmplCur_TypeIncome_CODE CHAR(2),
          @Lc_EmplCur_Occupation_TEXT CHAR(32),
          @Lc_EmplCur_Status_CODE     CHAR(1);

  BEGIN TRY
   SET @Ln_Member_IDNO = @An_MemberMci_IDNO;
   SET @Ls_Sql_TEXT = 'SELECT CSPR_Y1 - NCP LOCATE DATA BLOCK ' + CAST(@An_Case_IDNO AS VARCHAR);
   SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Lc_OthStateFips_CODE = a.IVDOutOfStateFips_CODE,
          @Ld_Generated_DATE = a.Generated_DATE,
          @Lc_Function_CODE = a.Function_CODE,
          @Lc_Action_CODE = a.Action_CODE,
          @Lc_Reason_CODE = a.Reason_CODE
     FROM CSPR_Y1 a
    WHERE a.Request_IDNO = CAST(@An_TransHeader_IDNO AS INT)
      AND a.EndValidity_DATE = @Ld_High_DATE;

   IF EXISTS (SELECT TOP 1 1
                FROM AHIS_Y1 a
               WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
                 AND a.TypeAddress_CODE = @Lc_Residential_ADDR
                 AND a.End_DATE > @Ad_Start_DATE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT RESIDENTIAL ADDRESS FROM AHIS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '');

     SELECT TOP (1) @Lc_ResidentialLine1_ADDR = SUBSTRING(fci.Line1_ADDR, 1, 25),
                    @Lc_ResidentialLine2_ADDR = SUBSTRING(fci.Line2_ADDR, 1, 25),
                    @Lc_ResidentialCity_TEXT = SUBSTRING(fci.City_ADDR, 1, 18),
                    @Lc_ResidentialState_CODE = fci.State_ADDR,
                    @Lc_ResidentialZip1_TEXT = fci.Zip1_ADDR,
                    @Lc_ResidentialZip2_TEXT = fci.Zip2_ADDR,
                    @Ld_EffectiveResidential_DATE = fci.Begin_DATE,
                    @Ld_EndResidential_DATE = fci.End_DATE,
                    @Lc_ResidentialConfirmed_TEXT = fci.Status_CODE
       FROM (SELECT a.Line1_ADDR,
                    a.Line2_ADDR,
                    a.City_ADDR,
                    a.State_ADDR,
                    SUBSTRING(a.Zip_ADDR, 1, 5) AS Zip1_ADDR,
                    SUBSTRING(REPLACE(a.Zip_ADDR, '-', ''), 6, 4) AS Zip2_ADDR,
                    a.Begin_DATE,
                    a.End_DATE,
                    a.Status_CODE
               FROM AHIS_Y1 a
              WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
                AND a.TypeAddress_CODE = @Lc_Residential_ADDR
                AND a.End_DATE > CONVERT(DATE, @Ad_Start_DATE, 102)
                AND a.Begin_DATE = (SELECT MAX(b.Begin_DATE)
                                      FROM AHIS_Y1 b
                                     WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                       AND b.TypeAddress_CODE = a.TypeAddress_CODE
                                       AND b.Status_CODE = a.Status_CODE
                                       AND b.End_DATE > CONVERT(DATE, @Ad_Start_DATE, 102))) AS fci
      ORDER BY fci.Status_CODE DESC;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'RESIDENTIAL ADDRESS NOT FOUND IN AHIS_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
       SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
      END;
     ELSE
      BEGIN
       SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;
      END;
    END; -- End IF

   IF (@Lc_Function_CODE = @Lc_FunctionManagestcases_CODE
       AND @Lc_Action_CODE = @Lc_ActionProvide_CODE
       AND (@Lc_Reason_CODE = @Lc_ReasonGsmad_CODE
             OR @Lc_Reason_CODE = @Lc_ReasonGsmde_CODE))
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECTS DETAILS FROM DINS_Y1 ';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_RelationshipCaseDp_TEXT, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_StatusCaseMemberActive_CODE, '');

     SELECT TOP 1 @Lc_PolicyInsNo_TEXT = ISNULL(a.PolicyInsNo_TEXT, @Lc_Space_TEXT),
                  @Lc_InsCarrier_NAME = ISNULL(SUBSTRING(o.OtherParty_NAME, 1, 36), @Lc_Space_TEXT)
       FROM DINS_Y1 a,
            CSPR_Y1 b,
            CMEM_Y1 c,
            OTHP_Y1 o
      WHERE b.Case_IDNO = @An_Case_IDNO
        AND c.Case_IDNO = b.Case_IDNO
        AND c.MemberMci_IDNO = a.ChildMCI_IDNO
        AND b.Request_IDNO = @An_TransHeader_IDNO
        AND ((ISNUMERIC(b.InsCarrier_NAME) = 0
              AND (o.OtherParty_NAME = b.InsCarrier_NAME
                   AND a.OthpInsurance_IDNO = o.OtherParty_IDNO))
              OR (ISNUMERIC(b.InsCarrier_NAME) = 1
                  AND (a.OthpInsurance_IDNO = CASE ISNUMERIC(b.InsCarrier_NAME)
                                               WHEN 1
                                                THEN b.InsCarrier_NAME
                                               ELSE NULL
                                              END
                       AND a.OthpInsurance_IDNO = o.OtherParty_IDNO)))
        AND o.TypeOthp_CODE = @Lc_InsTypeInsurers_CODE
        AND o.EndValidity_DATE = @Ld_High_DATE
        AND a.PolicyInsNo_TEXT = b.InsPolicyNo_TEXT
        AND a.MemberMci_IDNO = @Ln_Member_IDNO
        AND a.BeginValidity_DATE <= CONVERT(DATE, b.Generated_DATE, 101)
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND b.EndValidity_DATE = @Ld_High_DATE
        AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
        AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSURANCE INFORMATION NOT FOUND IN MINS_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
       SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
      END;
     ELSE
      BEGIN
       SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;
      END;
    END;
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECTS INSURANCE DETAILS FROM MINS_Y1 ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Lc_PolicyInsNo_TEXT = ISNULL(a.PolicyInsNo_TEXT, @Lc_Space_TEXT),
            @Lc_InsCarrier_NAME = ISNULL(SUBSTRING((SELECT o.OtherParty_NAME
                                                      FROM OTHP_Y1 o
                                                     WHERE o.OtherParty_IDNO = a.OthpInsurance_IDNO
                                                       AND o.TypeOthp_CODE = @Lc_InsTypeInsurers_CODE
                                                       AND o.EndValidity_DATE = @Ld_High_DATE), 1, 36), @Lc_Space_TEXT)
       FROM MINS_Y1 a
      WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.Status_CODE = 'CG'
        AND a.End_DATE > @Ad_Run_DATE
        AND a.Begin_DATE = (SELECT MAX(e.Begin_DATE)
                              FROM MINS_Y1 e
                             WHERE e.MemberMci_IDNO = a.MemberMci_IDNO
                               AND e.Status_CODE = a.Status_CODE
                               AND e.End_DATE = a.End_DATE
                               AND e.EndValidity_DATE = @Ld_High_DATE)
        AND a.TransactionEventSeq_NUMB = (SELECT MAX(f.TransactionEventSeq_NUMB)
                                            FROM MINS_Y1 f
                                           WHERE f.MemberMci_IDNO = a.MemberMci_IDNO
                                             AND f.Status_CODE = a.Status_CODE
                                             AND f.Begin_DATE = a.Begin_DATE
                                             AND f.End_DATE = a.End_DATE
                                             AND f.EndValidity_DATE = @Ld_High_DATE);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSURANCE INFORMATION NOT FOUND IN MINS_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
       SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
      END;
     ELSE
      BEGIN
       SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;
      END;
    END;

   SET @Ls_Sql_TEXT = 'SELECT THE NCP MAILING ADDRESS FROM AHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '');

   SELECT TOP (1) @Lc_MailingLine1_ADDR = SUBSTRING(fci.Line1_ADDR, 1, 25),
                  @Lc_MailingLine2_ADDR = SUBSTRING(fci.Line2_ADDR, 1, 25),
                  @Lc_MailingCity_TEXT = SUBSTRING(fci.City_ADDR, 1, 18),
                  @Lc_MailingState_CODE = fci.State_ADDR,
                  @Lc_MailingZip1_TEXT = fci.Zip1_ADDR,
                  @Lc_MailingZip2_TEXT = fci.Zip2_ADDR,
                  @Ld_EffectiveMailing_DATE = fci.Begin_DATE,
                  @Ld_EndMailing_DATE = fci.End_DATE,
                  @Lc_MailingConfirmed_TEXT = fci.Status_CODE
     FROM (SELECT a.Line1_ADDR,
                  a.Line2_ADDR,
                  a.City_ADDR,
                  a.State_ADDR,
                  SUBSTRING(a.Zip_ADDR, 1, 5) AS Zip1_ADDR,
                  SUBSTRING(REPLACE(a.Zip_ADDR, '-', ''), 6, 4) AS Zip2_ADDR,
                  a.Begin_DATE,
                  a.End_DATE,
                  a.Status_CODE
             FROM AHIS_Y1 a
            WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
              AND a.TypeAddress_CODE = @Lc_Mailing_ADDR
              AND a.End_DATE > CONVERT(DATE, @Ad_Start_DATE, 102)
              AND a.TransactionEventSeq_NUMB = (SELECT MAX(b.TransactionEventSeq_NUMB)
                                                  FROM AHIS_Y1 b
                                                 WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                                                   AND b.TypeAddress_CODE = a.TypeAddress_CODE
                                                   AND b.Status_CODE = a.Status_CODE
                                                   AND b.End_DATE > CONVERT(DATE, @Ad_Start_DATE, 102))) AS fci
    ORDER BY fci.Status_CODE DESC;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'MAILING ADDRESS NOT FOUND IN AHIS_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
     SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
    END;
   ELSE
    BEGIN
     SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;
    END;

   SET @Ls_Sql_TEXT = 'SELECTS THE NCP LAST RES ADDRESS FROM AHIS_Y1 ';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_Residential_ADDR, '') + ', Status_CODE = ' + ISNULL(@Lc_VerificationStatusGood_CODE, '');

   SELECT @Lc_LastResidentialLine1_ADDR = SUBSTRING(a.Line1_ADDR, 1, 25),
          @Lc_LastResidentialLine2_ADDR = SUBSTRING(a.Line2_ADDR, 1, 25),
          @Lc_LastResCity_TEXT = SUBSTRING(a.City_ADDR, 1, 18),
          @Lc_LastResState_CODE = a.State_ADDR,
          @Lc_LastResZip1_TEXT = SUBSTRING(a.Zip_ADDR, 1, 5),
          @Lc_LastResZip2_TEXT = SUBSTRING(REPLACE(a.Zip_ADDR, '-', ''), 6, 4),
          @Ld_LastResAddress_DATE = a.End_DATE
     FROM AHIS_Y1 a
    WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
      AND a.TypeAddress_CODE = @Lc_Residential_ADDR
      AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
      AND a.End_DATE <= @Ad_Run_DATE
      AND a.End_DATE = (SELECT MAX(b.End_DATE)
                          FROM AHIS_Y1 b
                         WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                           AND b.TypeAddress_CODE = a.TypeAddress_CODE
                           AND b.Status_CODE = a.Status_CODE
                           AND b.End_DATE <= @Ad_Run_DATE)
      AND a.TransactionEventSeq_NUMB = (SELECT MAX(c.TransactionEventSeq_NUMB)
                                          FROM AHIS_Y1 c
                                         WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                           AND c.TypeAddress_CODE = a.TypeAddress_CODE
                                           AND c.Status_CODE = a.Status_CODE
                                           AND c.End_DATE = a.End_DATE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NCP LAST RES ADDRESS NOT FOUND IN AHIS_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
     SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
    END;
   ELSE
    BEGIN
     SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;
    END;

   SET @Ls_Sql_TEXT = 'SELECTS THE NCP LAST MAILING ADDRESS FROM AHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_VerificationStatusGood_CODE, '');

   SELECT @Lc_LastMailLine1_ADDR = SUBSTRING(a.Line1_ADDR, 1, 25),
          @Lc_LastMailLine2_ADDR = SUBSTRING(a.Line2_ADDR, 1, 25),
          @Lc_LastMailCity_TEXT = SUBSTRING(a.City_ADDR, 1, 18),
          @Lc_LastMailState_CODE = a.State_ADDR,
          @Lc_LastMailZip1_TEXT = SUBSTRING(a.Zip_ADDR, 1, 5),
          @Lc_LastMailZip2_TEXT = SUBSTRING(REPLACE(a.Zip_ADDR, '-', ''), 6, 4),
          @Ld_LastMailAddress_DATE = a.End_DATE
     FROM AHIS_Y1 a
    WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
      AND a.TypeAddress_CODE IN (@Lc_Mailing_ADDR)
      AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
      AND a.End_DATE <= @Ad_Run_DATE
      AND a.End_DATE = (SELECT MAX(b.End_DATE)
                          FROM AHIS_Y1 b
                         WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                           AND b.TypeAddress_CODE = a.TypeAddress_CODE
                           AND b.Status_CODE = a.Status_CODE
                           AND b.End_DATE <= @Ad_Run_DATE)
      AND a.TransactionEventSeq_NUMB = (SELECT MAX(c.TransactionEventSeq_NUMB)
                                          FROM AHIS_Y1 c
                                         WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                           AND c.TypeAddress_CODE = a.TypeAddress_CODE
                                           AND c.Status_CODE = a.Status_CODE
                                           AND c.End_DATE = a.End_DATE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NCP LAST MAILING ADDRESS NOT FOUND IN AHIS_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
     SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
    END;
   ELSE
    BEGIN
     SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;
    END;

   SET @Ls_Sql_TEXT = 'SELECTS THE NCP LICENCE DETAILS FROM PLIC_Y1 FROM THE STATE ';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenceDr_IDNO, '') + ', Status_CODE = ' + ISNULL(@Lc_StatusGood_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', IssuingState_CODE = ' + ISNULL(@Lc_StateInState_CODE, '');

   SELECT TOP 1 @Lc_DriversLicense_TEXT = a.LicenseNo_TEXT,
                @Lc_DriversLicenseState_CODE = @Lc_StateInState_CODE
     FROM PLIC_Y1 a
    WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
      AND a.TypeLicense_CODE = @Lc_TypeLicenceDr_IDNO
      AND a.Status_CODE = @Lc_StatusGood_CODE
      AND a.EndValidity_DATE = @Ld_High_DATE
      AND a.IssuingState_CODE = @Lc_StateInState_CODE;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECTS THE NCP LICENCE DETAILS FROM PLIC_Y1 NOT IN THE STATE ';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusGood_CODE, '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenceDr_IDNO, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusGood_CODE, '') + ', TypeLicense_CODE = ' + ISNULL(@Lc_TypeLicenceDr_IDNO, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT TOP 1 @Lc_DriversLicense_TEXT = a.LicenseNo_TEXT,
                  @Lc_DriversLicenseState_CODE = a.IssuingState_CODE
       FROM PLIC_Y1 a
      WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
        AND a.Status_CODE = @Lc_StatusGood_CODE
        AND a.TypeLicense_CODE = @Lc_TypeLicenceDr_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.IssuingState_CODE <> @Lc_StateInState_CODE
        AND a.TransactionEventSeq_NUMB = (SELECT MAX(b.TransactionEventSeq_NUMB)
                                            FROM PLIC_Y1 b
                                           WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                                             AND b.Status_CODE = @Lc_StatusGood_CODE
                                             AND b.TypeLicense_CODE = @Lc_TypeLicenceDr_IDNO
                                             AND b.EndValidity_DATE = @Ld_High_DATE
                                             AND b.IssuingState_CODE <> @Lc_StateInState_CODE);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Lc_DriversLicense_TEXT = @Lc_Space_TEXT;
       SET @Lc_DriversLicenseState_CODE = @Lc_Space_TEXT;
      END;
    END;

   -- Only 10 digits Phone number will be considered as valid to avoid CSENET Error
   -- Driver license fetched from PLIC table instead of DEMO table
   SET @Ls_Sql_TEXT = 'SELECTS THE NCP DETAILS FROM DEMO_Y1 ';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '');

   SELECT @Ln_HomePhone_NUMB = CAST(SUBSTRING(CAST(a.HomePhone_NUMB AS VARCHAR), 1, 10) AS NUMERIC),
          @Ln_WorkPhone_NUMB = CAST(SUBSTRING(CAST(a.WorkPhone_NUMB AS VARCHAR), 1, 10) AS NUMERIC),
          @Lc_SpouseLast_TEXT = SUBSTRING(a.Spouse_NAME, 1, 16),
          @Lc_SpouseFirst_TEXT = SUBSTRING(a.Spouse_NAME, 17, 16),
          @Lc_SpouseMiddle_TEXT = SUBSTRING(a.Spouse_NAME, 33, 5),
          @Lc_SpouseSuffix_TEXT = SUBSTRING(a.Spouse_NAME, 38, 3)
     FROM DEMO_Y1 a
    WHERE a.MemberMci_IDNO = @Ln_Member_IDNO;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NO DATA FOUND IN DEMO_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
     SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
    END
   ELSE
    BEGIN
     SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;
    END;

   IF (EXISTS (SELECT TOP 1 1
                 FROM AKAX_Y1 a
                WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
                  AND a.EndValidity_DATE = @Ld_High_DATE))
    BEGIN
     SET @Li_AliasRow_QNTY = 0;
     SET @Alias_CUR = CURSOR
     FOR SELECT a.FirstAlias_NAME,
                a.MiddleAlias_NAME,
                a.LastAlias_NAME,
                a.SuffixAlias_NAME
           FROM AKAX_Y1 a
          WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
            AND a.EndValidity_DATE = @Ld_High_DATE
          ORDER BY a.TransactionEventSeq_NUMB DESC;
     SET @Ls_Sql_TEXT = 'OPEN @Alias_CUR';
     SET @Ls_Sqldata_TEXT = '';

     OPEN @Alias_CUR;

     SET @Ls_Sql_TEXT = 'CURSOR LREF_CUR_ALIAS TO SELECT ALIAS FROM AKAX_Y1';
     SET @Ls_Sql_TEXT = 'FETCH @Alias_CUR - 1';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM @Alias_CUR INTO @Lc_AliasCur_First_NAME, @Lc_AliasCur_Mi_NAME, @Lc_AliasCur_Last_NAME, @Lc_AliasCur_Suffix_NAME;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
     SET @Li_AliasRow_QNTY = 0;

     -- Set Alias1, Alias2 and Alias3
     WHILE (@Li_FetchStatus_NUMB = 0)
      BEGIN
       SET @Li_AliasRow_QNTY = @Li_AliasRow_QNTY + 1;

       IF @Li_AliasRow_QNTY = 1
        BEGIN
         SET @Lc_Alias1First_TEXT = @Lc_AliasCur_First_NAME;
         SET @Lc_Alias1Middle_TEXT = SUBSTRING(@Lc_AliasCur_Mi_NAME, 1, 16);
         SET @Lc_Alias1Last_TEXT = @Lc_AliasCur_Last_NAME;
         SET @Lc_Alias1Suffix_TEXT = @Lc_AliasCur_Suffix_NAME;
        END;
       ELSE IF @Li_AliasRow_QNTY = 2
        BEGIN
         SET @Lc_Alias2First_TEXT = @Lc_AliasCur_First_NAME;
         SET @Lc_Alias2Middle_TEXT = SUBSTRING(@Lc_AliasCur_Mi_NAME, 1, 16);
         SET @Lc_Alias2Last_TEXT = @Lc_AliasCur_Last_NAME;
         SET @Lc_Alias2Suffix_TEXT = @Lc_AliasCur_Suffix_NAME;
        END;
       ELSE IF @Li_AliasRow_QNTY = 3
        BEGIN
         SET @Lc_Alias3First_TEXT = @Lc_AliasCur_First_NAME;
         SET @Lc_Alias3Middle_TEXT = SUBSTRING(@Lc_AliasCur_Mi_NAME, 1, 16);
         SET @Lc_Alias3Last_TEXT = @Lc_AliasCur_Last_NAME;
         SET @Lc_Alias3Suffix_TEXT = @Lc_AliasCur_Suffix_NAME;
        END;

       SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;
       SET @Ls_Sql_TEXT = 'FETCH @Alias_CUR - 2';
       SET @Ls_Sqldata_TEXT = '';

       FETCH NEXT FROM @Alias_CUR INTO @Lc_AliasCur_First_NAME, @Lc_AliasCur_Mi_NAME, @Lc_AliasCur_Last_NAME, @Lc_AliasCur_Suffix_NAME;

       SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
      END; -- End While loop

     IF CURSOR_STATUS('LOCAL', '@Alias_CUR') IN (0, 1)
      BEGIN
       CLOSE @Alias_CUR;

       DEALLOCATE @Alias_CUR;
      END;
    END;

   -- EM and ML records needs to be taken for Employer details
   SET @Li_EmplCurRow_QNTY = 0;
   SET @Empl_CUR = CURSOR
   FOR SELECT TOP 3 a.OthpPartyEmpl_IDNO,
                    a.BeginEmployment_DATE,
                    a.EndEmployment_DATE,
                    a.TypeIncome_CODE,
                    a.DescriptionOccupation_TEXT,
                    a.Status_CODE
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
          AND @Ad_Run_DATE BETWEEN a.BeginEmployment_DATE AND a.EndEmployment_DATE
          AND a.TypeIncome_CODE IN (@Lc_IncomeTypeEmployer_CODE, @Lc_TypeIncomeMl_IDNO)
          AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
        ORDER BY CASE a.EndEmployment_DATE
                  WHEN @Ld_High_DATE
                   THEN 1
                  ELSE 2
                 END,
                 a.EmployerPrime_INDC DESC,
                 a.BeginEmployment_DATE DESC,
                 a.TransactionEventSeq_NUMB DESC;
   SET @Ls_Sql_TEXT = 'OPEN @Empl_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN @Empl_CUR;

   SET @Ls_Sql_TEXT = 'FETCH @Empl_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM @Empl_CUR INTO @Lc_EmplCur_OtherParty_TEXT, @Ld_EmplCur_Begin_DATE, @Ld_EmplCur_End_DATE, @Lc_EmplCur_TypeIncome_CODE, @Lc_EmplCur_Occupation_TEXT, @Lc_EmplCur_Status_CODE;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Set Employer, Employer2 and Employer3
   WHILE (@Li_FetchStatus_NUMB = 0)
    BEGIN
     SET @Li_EmplCurRow_QNTY = @Li_EmplCurRow_QNTY + 1;

     IF @Lc_EmplCur_TypeIncome_CODE = @Lc_IncomeTypeEmployer_CODE
      BEGIN
       SET @Lc_TypeOthp_IDNO = @Lc_TypeOthpE1_IDNO;
      END
     ELSE
      BEGIN
       SET @Lc_TypeOthp_IDNO = @Lc_TypeOthpM1_IDNO;
      END;

     SET @Li_FoundData_NUMB = @Li_FoundData_NUMB + 1;

     IF @Li_EmplCurRow_QNTY = 1
      BEGIN
       -- This block will fill the  EMPLOYER  Details if not found fill the default values
       SET @Ls_Sql_TEXT = 'INSIDE CURSOR @Empl_CUR ROWCOUNT 1';
       SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Lc_EmplCur_OtherParty_TEXT, '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_IDNO, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Lc_EmployerEin_TEXT = a.Fein_IDNO,
              @Ls_Employer_NAME = a.OtherParty_NAME,
              @Lc_EmployerLine1_ADDR = SUBSTRING(a.Line1_ADDR, 1, 25),
              @Lc_EmployerLine2_ADDR = SUBSTRING(a.Line2_ADDR, 1, 25),
              @Lc_EmployerCity_TEXT = SUBSTRING(a.City_ADDR, 1, 18),
              @Lc_EmployerState_CODE = a.State_ADDR,
              @Lc_EmployerZip1_TEXT = SUBSTRING(a.Zip_ADDR, 1, 5),
              @Lc_EmployerZip2_TEXT = SUBSTRING(REPLACE(a.Zip_ADDR, '-', ''), 6, 4),
              @Ln_EmployerPhone_NUMB = CAST(SUBSTRING(CAST(a.Phone_NUMB AS VARCHAR), 1, 10) AS NUMERIC),
              @Ld_EffectiveEmployer_DATE = @Ld_EmplCur_Begin_DATE,
              @Ld_EndEmployer_DATE = @Ld_EmplCur_End_DATE,
              @Lc_EmployerConfirmed_INDC = @Lc_EmplCur_Status_CODE,
              @Lc_Occupation_TEXT = @Lc_EmplCur_Occupation_TEXT
         FROM OTHP_Y1 a
        WHERE a.OtherParty_IDNO = @Lc_EmplCur_OtherParty_TEXT
          AND a.TypeOthp_CODE = @Lc_TypeOthp_IDNO
          AND a.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'NO EMPLOYER DATA FOUND IN OTHP_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
         SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
        END;
      END;
     ELSE IF @Li_EmplCurRow_QNTY = 2
      BEGIN
       SET @Ls_Sql_TEXT = 'INSIDE CURSOR @Empl_CUR ROWCOUND 2';
       SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Lc_EmplCur_OtherParty_TEXT, '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_IDNO, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Lc_Employer2Ein_TEXT = ISNULL(a.Fein_IDNO, a.Sein_IDNO),
              @Lc_Employer2_NAME = a.OtherParty_NAME,
              @Lc_Employer2Line1_ADDR = SUBSTRING(a.Line1_ADDR, 1, 25),
              @Lc_Employer2Line2_ADDR = SUBSTRING(a.Line2_ADDR, 1, 25),
              @Lc_Employer2City_TEXT = SUBSTRING(a.City_ADDR, 1, 18),
              @Lc_Employer2State_CODE = a.State_ADDR,
              @Lc_Employer2Zip1_TEXT = SUBSTRING(a.Zip_ADDR, 1, 5),
              @Lc_Employer2Zip2_TEXT = SUBSTRING(REPLACE(a.Zip_ADDR, '-', ''), 6, 4),
              @Ln_Employer2Phone_NUMB = CAST(SUBSTRING(CAST(a.Phone_NUMB AS VARCHAR), 1, 10) AS NUMERIC),
              @Ld_EffectiveEmployer2_DATE = @Ld_EmplCur_Begin_DATE,
              @Ld_EndEmployer2_DATE = @Ld_EmplCur_End_DATE,
              @Lc_Employer2Confirmed_INDC = @Lc_EmplCur_Status_CODE
         FROM OTHP_Y1 a
        WHERE a.OtherParty_IDNO = @Lc_EmplCur_OtherParty_TEXT
          AND a.TypeOthp_CODE = @Lc_TypeOthp_IDNO
          AND a.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'NO EMPLOYER2 DATA FOUND IN OTHP_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
         SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
        END;
      END;
     ELSE IF @Li_EmplCurRow_QNTY = 3
      BEGIN
       -- This block will fill the  EMPLOYER  3 Details if not found fill the default values
       SET @Ls_Sql_TEXT = 'INSIDE CURSOR @Empl_CUR ROWCOUND 2';
       SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Lc_EmplCur_OtherParty_TEXT, '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_IDNO, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Lc_Employer3Ein_TEXT = ISNULL(a.Fein_IDNO, a.Sein_IDNO),
              @Lc_Employer3_NAME = a.OtherParty_NAME,
              @Lc_Employer3Line1_ADDR = SUBSTRING(a.Line1_ADDR, 1, 25),
              @Lc_Employer3Line2_ADDR = SUBSTRING(a.Line2_ADDR, 1, 25),
              @Lc_Employer3City_TEXT = SUBSTRING(a.City_ADDR, 1, 18),
              @Lc_Employer3State_CODE = a.State_ADDR,
              @Lc_Employer3Zip1_TEXT = SUBSTRING(a.Zip_ADDR, 1, 5),
              @Lc_Employer3Zip2_TEXT = SUBSTRING(REPLACE(a.Zip_ADDR, '-', ''), 6, 4),
              @Ln_Employer3Phone_NUMB = CAST(SUBSTRING(CAST(a.Phone_NUMB AS VARCHAR), 1, 10) AS NUMERIC),
              @Ld_EffectiveEmployer3_DATE = @Ld_EmplCur_Begin_DATE,
              @Ld_EndEmployer3_DATE = @Ld_EmplCur_End_DATE,
              @Lc_Employer3Confirmed_INDC = @Lc_EmplCur_Status_CODE
         FROM OTHP_Y1 a
        WHERE a.OtherParty_IDNO = @Lc_EmplCur_OtherParty_TEXT
          AND a.TypeOthp_CODE = @Lc_TypeOthp_IDNO
          AND a.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'NO EMPLOYER3 DATA FOUND IN OTHP_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
         SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
        END;
      END;

     SET @Ls_Sql_TEXT = 'FETCH @Empl_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM @Empl_CUR INTO @Lc_EmplCur_OtherParty_TEXT, @Ld_EmplCur_Begin_DATE, @Ld_EmplCur_End_DATE, @Lc_EmplCur_TypeIncome_CODE, @Lc_EmplCur_Occupation_TEXT, @Lc_EmplCur_Status_CODE;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   CLOSE @Empl_CUR;

   DEALLOCATE @Empl_CUR;

   -- This block will fill the LAST EMPLOYER Details if not found fill the default values
   SET @Ls_Sql_TEXT = 'SELECT LAST EMPLOYENT FROM EHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_Member_IDNO AS VARCHAR), '') + ', TypeIncome_CODE = ' + ISNULL(@Lc_IncomeTypeEmployer_CODE, '') + ', Status_CODE = ' + ISNULL(@Lc_VerificationStatusGood_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Lc_LastEmployer_TEXT = b.OtherParty_NAME,
          @Lc_LastEmployerLine1_ADDR = SUBSTRING(b.Line1_ADDR, 1, 25),
          @Lc_LastEmployerLine2_ADDR = SUBSTRING(b.Line2_ADDR, 1, 25),
          @Lc_LastEmployerCity_TEXT = SUBSTRING(b.City_ADDR, 1, 18),
          @Lc_LastEmployerState_CODE = b.State_ADDR,
          @Lc_LastEmployerZip1_TEXT = SUBSTRING(b.Zip_ADDR, 1, 5),
          @Lc_LastEmployerZip2_TEXT = SUBSTRING(REPLACE(b.Zip_ADDR, '-', ''), 6, 4),
          @Ld_LastEmployerEffective_DATE = a.BeginEmployment_DATE,
          @Ld_LastEmployer_DATE = a.EndEmployment_DATE
     FROM EHIS_Y1 a,
          OTHP_Y1 b
    WHERE a.MemberMci_IDNO = @Ln_Member_IDNO
      AND a.TypeIncome_CODE = @Lc_IncomeTypeEmployer_CODE
      AND a.OthpPartyEmpl_IDNO = b.OtherParty_IDNO
      AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
      AND a.EndEmployment_DATE <= @Ad_Run_DATE
      AND b.EndValidity_DATE = @Ld_High_DATE
      AND a.EndEmployment_DATE = (SELECT MAX(c.EndEmployment_DATE)
                                    FROM EHIS_Y1 c
                                   WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                     AND c.Status_CODE = a.Status_CODE
                                     AND c.EndEmployment_DATE <= @Ad_Run_DATE)
      AND a.TransactionEventSeq_NUMB = (SELECT MAX(d.TransactionEventSeq_NUMB)
                                          FROM EHIS_Y1 d
                                         WHERE d.MemberMci_IDNO = a.MemberMci_IDNO
                                           AND d.Status_CODE = a.Status_CODE
                                           AND d.BeginEmployment_DATE = a.BeginEmployment_DATE
                                           AND d.EndEmployment_DATE = a.EndEmployment_DATE);

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NO EMPLOYER DATA FOUND IN OTHP_Y1 FOR MEMBER: ' + CAST(@Ln_Member_IDNO AS VARCHAR);
     SET @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE;
    END;

   IF @Li_FoundData_NUMB = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NO INFORMATION FOUND FOR ' + CAST(@Ln_Member_IDNO AS VARCHAR);
     SET @Ls_Sql_TEXT = CAST(@Ln_Member_IDNO AS VARCHAR) + 'NCP MEMBER,EMPLOYER INFORMATION NOT FOUND AND NOT INSERTED.';

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT = 'INSERTS THE NCP MEMBER,EMPLOYER DETAILS INTO NCP_LOCATE_BLOCKS FROM AHIS_Y1, EHIS_Y1, OTHP_Y1';
   SET @Ls_Sqldata_TEXT = 'HomePhone_NUMB = ' + ISNULL(CAST(@Ln_HomePhone_NUMB AS VARCHAR), '') + ', WorkPhone_NUMB = ' + ISNULL(CAST(@Ln_WorkPhone_NUMB AS VARCHAR), '') + ', DriversLicenseState_CODE = ' + ISNULL(@Lc_DriversLicenseState_CODE, '') + ', DriversLicenseNo_TEXT = ' + ISNULL(@Lc_DriversLicense_TEXT, '') + ', Alias1First_NAME = ' + ISNULL(@Lc_Alias1First_TEXT, '') + ', Alias1Middle_NAME = ' + ISNULL(@Lc_Alias1Middle_TEXT, '') + ', Alias1Last_NAME = ' + ISNULL(@Lc_Alias1Last_TEXT, '') + ', Alias1Suffix_NAME = ' + ISNULL(@Lc_Alias1Suffix_TEXT, '') + ', Alias2First_NAME = ' + ISNULL(@Lc_Alias2First_TEXT, '') + ', Alias2Middle_NAME = ' + ISNULL(@Lc_Alias2Middle_TEXT, '') + ', Alias2Last_NAME = ' + ISNULL(@Lc_Alias2Last_TEXT, '') + ', Alias2Suffix_NAME = ' + ISNULL(@Lc_Alias2Suffix_TEXT, '') + ', Alias3First_NAME = ' + ISNULL(@Lc_Alias3First_TEXT, '') + ', Alias3Middle_NAME = ' + ISNULL(@Lc_Alias3Middle_TEXT, '') + ', Alias3Last_NAME = ' + ISNULL(@Lc_Alias3Last_TEXT, '') + ', Alias3Suffix_NAME = ' + ISNULL(@Lc_Alias3Suffix_TEXT, '') + ', SpouseLast_NAME = ' + ISNULL(@Lc_SpouseLast_TEXT, '') + ', SpouseFirst_NAME = ' + ISNULL(@Lc_SpouseFirst_TEXT, '') + ', SpouseMiddle_NAME = ' + ISNULL(@Lc_SpouseMiddle_TEXT, '') + ', SpouseSuffix_NAME = ' + ISNULL(@Lc_SpouseSuffix_TEXT, '') + ', Occupation_TEXT = ' + ISNULL(@Lc_Occupation_TEXT, '') + ', EmployerEin_ID = ' + ISNULL(@Lc_EmployerEin_TEXT, '') + ', Employer_NAME = ' + ISNULL(@Ls_Employer_NAME, '') + ', EmployerLine1_ADDR = ' + ISNULL(@Lc_EmployerLine1_ADDR, '') + ', EmployerLine2_ADDR = ' + ISNULL(@Lc_EmployerLine2_ADDR, '') + ', EmployerCity_ADDR = ' + ISNULL(@Lc_EmployerCity_TEXT, '') + ', EmployerState_ADDR = ' + ISNULL(@Lc_EmployerState_CODE, '') + ', EmployerZip1_ADDR = ' + ISNULL(@Lc_EmployerZip1_TEXT, '') + ', EmployerZip2_ADDR = ' + ISNULL(@Lc_EmployerZip2_TEXT, '') + ', EmployerPhone_NUMB = ' + ISNULL(CAST(@Ln_EmployerPhone_NUMB AS VARCHAR), '') + ', EffectiveEmployer_DATE = ' + ISNULL(CAST(@Ld_EffectiveEmployer_DATE AS VARCHAR), '') + ', EndEmployer_DATE = ' + ISNULL(CAST(@Ld_EndEmployer_DATE AS VARCHAR), '') + ', EmployerConfirmed_INDC = ' + ISNULL(@Lc_EmployerConfirmed_INDC, '') + ', WageQtr_CODE = ' + ISNULL(@Lc_WageQtr_TEXT, '') + ', WageYear_NUMB = ' + ISNULL(@Lc_WageYear_TEXT, '') + ', Wage_AMNT = ' + ISNULL(CAST(@Ln_Wage_AMNT AS VARCHAR), '') + ', LastResidentialLine1_ADDR = ' + ISNULL(@Lc_LastResidentialLine1_ADDR, '') + ', LastResidentialLine2_ADDR = ' + ISNULL(@Lc_LastResidentialLine2_ADDR, '') + ', LastResidentialCity_ADDR = ' + ISNULL(@Lc_LastResCity_TEXT, '') + ', LastResidentialState_ADDR = ' + ISNULL(@Lc_LastResState_CODE, '') + ', LastResidentialZip1_ADDR = ' + ISNULL(@Lc_LastResZip1_TEXT, '') + ', LastResidentialZip2_ADDR = ' + ISNULL(@Lc_LastResZip2_TEXT, '') + ', LastResAddress_DATE = ' + ISNULL(CAST(@Ld_LastResAddress_DATE AS VARCHAR), '') + ', LastMailLine1_ADDR = ' + ISNULL(@Lc_LastMailLine1_ADDR, '') + ', LastMailLine2_ADDR = ' + ISNULL(@Lc_LastMailLine2_ADDR, '') + ', LastMailCity_ADDR = ' + ISNULL(@Lc_LastMailCity_TEXT, '') + ', LastMailState_ADDR = ' + ISNULL(@Lc_LastMailState_CODE, '') + ', LastMailZip1_ADDR = ' + ISNULL(@Lc_LastMailZip1_TEXT, '') + ', LastMailZip2_ADDR = ' + ISNULL(@Lc_LastMailZip2_TEXT, '') + ', LastMailAddress_DATE = ' + ISNULL(CAST(@Ld_LastMailAddress_DATE AS VARCHAR), '') + ', LastEmployer_NAME = ' + ISNULL(@Lc_LastEmployer_TEXT, '') + ', LastEmployer_DATE = ' + ISNULL(CAST(@Ld_LastEmployer_DATE AS VARCHAR), '') + ', LastEmployerLine1_ADDR = ' + ISNULL(@Lc_LastEmployerLine1_ADDR, '') + ', LastEmployerLine2_ADDR = ' + ISNULL(@Lc_LastEmployerLine2_ADDR, '') + ', LastEmployerCity_ADDR = ' + ISNULL(@Lc_LastEmployerCity_TEXT, '') + ', LastEmployerState_ADDR = ' + ISNULL(@Lc_LastEmployerState_CODE, '') + ', LastEmployerZip1_ADDR = ' + ISNULL(@Lc_LastEmployerZip1_TEXT, '') + ', LastEmployerZip2_ADDR = ' + ISNULL(@Lc_LastEmployerZip2_TEXT, '') + ', LastEmployerEffective_DATE = ' + ISNULL(CAST(@Ld_LastEmployerEffective_DATE AS VARCHAR), '') + ', Employer2Ein_ID = ' + ISNULL(@Lc_Employer2Ein_TEXT, '') + ', Employer2_NAME = ' + ISNULL(@Lc_Employer2_NAME, '') + ', Employer2Line1_ADDR = ' + ISNULL(@Lc_Employer2Line1_ADDR, '') + ', Employer2Line2_ADDR = ' + ISNULL(@Lc_Employer2Line2_ADDR, '') + ', Employer2City_ADDR = ' + ISNULL(@Lc_Employer2City_TEXT, '') + ', Employer2State_ADDR = ' + ISNULL(@Lc_Employer2State_CODE, '') + ', Employer2Zip1_ADDR = ' + ISNULL(@Lc_Employer2Zip1_TEXT, '') + ', Employer2Zip2_ADDR = ' + ISNULL(@Lc_Employer2Zip2_TEXT, '') + ', Employer2Phone_NUMB = ' + ISNULL(CAST(@Ln_Employer2Phone_NUMB AS VARCHAR), '') + ', EffectiveEmployer2_DATE = ' + ISNULL(CAST(@Ld_EffectiveEmployer2_DATE AS VARCHAR), '') + ', EndEmployer2_DATE = ' + ISNULL(CAST(@Ld_EndEmployer2_DATE AS VARCHAR), '') + ', Employer2Confirmed_INDC = ' + ISNULL(@Lc_Employer2Confirmed_INDC, '') + ', Wage2Qtr_CODE = ' + ISNULL(@Lc_Wage2Qtr_TEXT, '') + ', Wage2Year_NUMB = ' + ISNULL(@Lc_Wage2Year_TEXT, '') + ', Wage2_AMNT = ' + ISNULL(CAST(@Ln_Wage2_AMNT AS VARCHAR), '') + ', Employer3Ein_ID = ' + ISNULL(@Lc_Employer3Ein_TEXT, '') + ', Employer3_NAME = ' + ISNULL(@Lc_Employer3_NAME, '') + ', Employer3Line1_ADDR = ' + ISNULL(@Lc_Employer3Line1_ADDR, '') + ', Employer3Line2_ADDR = ' + ISNULL(@Lc_Employer3Line2_ADDR, '') + ', Employer3City_ADDR = ' + ISNULL(@Lc_Employer3City_TEXT, '') + ', Employer3State_ADDR = ' + ISNULL(@Lc_Employer3State_CODE, '') + ', Employer3Zip1_ADDR = ' + ISNULL(@Lc_Employer3Zip1_TEXT, '') + ', Employer3Zip2_ADDR = ' + ISNULL(@Lc_Employer3Zip2_TEXT, '') + ', Employer3Phone_NUMB = ' + ISNULL(CAST(@Ln_Employer3Phone_NUMB AS VARCHAR), '') + ', EffectiveEmployer3_DATE = ' + ISNULL(CAST(@Ld_EffectiveEmployer3_DATE AS VARCHAR), '') + ', EndEmployer3_DATE = ' + ISNULL(CAST(@Ld_EndEmployer3_DATE AS VARCHAR), '') + ', Employer3Confirmed_INDC = ' + ISNULL(@Lc_Employer3Confirmed_INDC, '') + ', Wage3Qtr_CODE = ' + ISNULL(@Lc_Wage3Qtr_TEXT, '') + ', Wage3Year_NUMB = ' + ISNULL(@Lc_Wage3Year_TEXT, '') + ', Wage3_AMNT = ' + ISNULL(CAST(@Ln_Wage3_AMNT AS VARCHAR), '') + ', ProfessionalLicenses_TEXT = ' + ISNULL(@Ls_ProfessionalLicenses_TEXT, '') + ', TransHeader_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_StateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_Generated_DATE AS VARCHAR), '') + ', ResidentialLine1_ADDR = ' + ISNULL(@Lc_ResidentialLine1_ADDR, '') + ', ResidentialLine2_ADDR = ' + ISNULL(@Lc_ResidentialLine2_ADDR, '') + ', ResidentialCity_ADDR = ' + ISNULL(@Lc_ResidentialCity_TEXT, '') + ', ResidentialState_ADDR = ' + ISNULL(@Lc_ResidentialState_CODE, '') + ', ResidentialZip1_ADDR = ' + ISNULL(@Lc_ResidentialZip1_TEXT, '') + ', ResidentialZip2_ADDR = ' + ISNULL(@Lc_ResidentialZip2_TEXT, '') + ', MailingLine1_ADDR = ' + ISNULL(@Lc_MailingLine1_ADDR, '') + ', MailingLine2_ADDR = ' + ISNULL(@Lc_MailingLine2_ADDR, '') + ', MailingCity_ADDR = ' + ISNULL(@Lc_MailingCity_TEXT, '') + ', MailingState_ADDR = ' + ISNULL(@Lc_MailingState_CODE, '') + ', MailingZip1_ADDR = ' + ISNULL(@Lc_MailingZip1_TEXT, '') + ', MailingZip2_ADDR = ' + ISNULL(@Lc_MailingZip2_TEXT, '') + ', EffectiveResidential_DATE = ' + ISNULL(CAST(@Ld_EffectiveResidential_DATE AS VARCHAR), '') + ', EndResidential_DATE = ' + ISNULL(CAST(@Ld_EndResidential_DATE AS VARCHAR), '') + ', ResidentialConfirmed_CODE = ' + ISNULL(@Lc_ResidentialConfirmed_TEXT, '') + ', EffectiveMailing_DATE = ' + ISNULL(CAST(@Ld_EffectiveMailing_DATE AS VARCHAR), '') + ', EndMailing_DATE = ' + ISNULL(CAST(@Ld_EndMailing_DATE AS VARCHAR), '') + ', MailingConfirmed_CODE = ' + ISNULL(@Lc_MailingConfirmed_TEXT, '');

   INSERT ENLBL_Y1
          (HomePhone_NUMB,
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
           EmployerLine1_ADDR,
           EmployerLine2_ADDR,
           EmployerCity_ADDR,
           EmployerState_ADDR,
           EmployerZip1_ADDR,
           EmployerZip2_ADDR,
           EmployerPhone_NUMB,
           EffectiveEmployer_DATE,
           EndEmployer_DATE,
           EmployerConfirmed_INDC,
           WageQtr_CODE,
           WageYear_NUMB,
           Wage_AMNT,
           InsCarrier_NAME,
           PolicyInsNo_TEXT,
           LastResidentialLine1_ADDR,
           LastResidentialLine2_ADDR,
           LastResidentialCity_ADDR,
           LastResidentialState_ADDR,
           LastResidentialZip1_ADDR,
           LastResidentialZip2_ADDR,
           LastResAddress_DATE,
           LastMailLine1_ADDR,
           LastMailLine2_ADDR,
           LastMailCity_ADDR,
           LastMailState_ADDR,
           LastMailZip1_ADDR,
           LastMailZip2_ADDR,
           LastMailAddress_DATE,
           LastEmployer_NAME,
           LastEmployer_DATE,
           LastEmployerLine1_ADDR,
           LastEmployerLine2_ADDR,
           LastEmployerCity_ADDR,
           LastEmployerState_ADDR,
           LastEmployerZip1_ADDR,
           LastEmployerZip2_ADDR,
           LastEmployerEffective_DATE,
           Employer2Ein_ID,
           Employer2_NAME,
           Employer2Line1_ADDR,
           Employer2Line2_ADDR,
           Employer2City_ADDR,
           Employer2State_ADDR,
           Employer2Zip1_ADDR,
           Employer2Zip2_ADDR,
           Employer2Phone_NUMB,
           EffectiveEmployer2_DATE,
           EndEmployer2_DATE,
           Employer2Confirmed_INDC,
           Wage2Qtr_CODE,
           Wage2Year_NUMB,
           Wage2_AMNT,
           Employer3Ein_ID,
           Employer3_NAME,
           Employer3Line1_ADDR,
           Employer3Line2_ADDR,
           Employer3City_ADDR,
           Employer3State_ADDR,
           Employer3Zip1_ADDR,
           Employer3Zip2_ADDR,
           Employer3Phone_NUMB,
           EffectiveEmployer3_DATE,
           EndEmployer3_DATE,
           Employer3Confirmed_INDC,
           Wage3Qtr_CODE,
           Wage3Year_NUMB,
           Wage3_AMNT,
           ProfessionalLicenses_TEXT,
           TransHeader_IDNO,
           IVDOutOfStateFips_CODE,
           Transaction_DATE,
           ResidentialLine1_ADDR,
           ResidentialLine2_ADDR,
           ResidentialCity_ADDR,
           ResidentialState_ADDR,
           ResidentialZip1_ADDR,
           ResidentialZip2_ADDR,
           MailingLine1_ADDR,
           MailingLine2_ADDR,
           MailingCity_ADDR,
           MailingState_ADDR,
           MailingZip1_ADDR,
           MailingZip2_ADDR,
           EffectiveResidential_DATE,
           EndResidential_DATE,
           ResidentialConfirmed_CODE,
           EffectiveMailing_DATE,
           EndMailing_DATE,
           MailingConfirmed_CODE)
   VALUES ( @Ln_HomePhone_NUMB,--HomePhone_NUMB
            @Ln_WorkPhone_NUMB,--WorkPhone_NUMB
            @Lc_DriversLicenseState_CODE,--DriversLicenseState_CODE
            @Lc_DriversLicense_TEXT,--DriversLicenseNo_TEXT
            @Lc_Alias1First_TEXT,--Alias1First_NAME
            @Lc_Alias1Middle_TEXT,--Alias1Middle_NAME
            @Lc_Alias1Last_TEXT,--Alias1Last_NAME
            @Lc_Alias1Suffix_TEXT,--Alias1Suffix_NAME
            @Lc_Alias2First_TEXT,--Alias2First_NAME
            @Lc_Alias2Middle_TEXT,--Alias2Middle_NAME
            @Lc_Alias2Last_TEXT,--Alias2Last_NAME
            @Lc_Alias2Suffix_TEXT,--Alias2Suffix_NAME
            @Lc_Alias3First_TEXT,--Alias3First_NAME
            @Lc_Alias3Middle_TEXT,--Alias3Middle_NAME
            @Lc_Alias3Last_TEXT,--Alias3Last_NAME
            @Lc_Alias3Suffix_TEXT,--Alias3Suffix_NAME
            @Lc_SpouseLast_TEXT,--SpouseLast_NAME
            @Lc_SpouseFirst_TEXT,--SpouseFirst_NAME
            @Lc_SpouseMiddle_TEXT,--SpouseMiddle_NAME
            @Lc_SpouseSuffix_TEXT,--SpouseSuffix_NAME
            @Lc_Occupation_TEXT,--Occupation_TEXT
            @Lc_EmployerEin_TEXT,--EmployerEin_ID
            @Ls_Employer_NAME,--Employer_NAME
            @Lc_EmployerLine1_ADDR,--EmployerLine1_ADDR
            @Lc_EmployerLine2_ADDR,--EmployerLine2_ADDR
            @Lc_EmployerCity_TEXT,--EmployerCity_ADDR
            @Lc_EmployerState_CODE,--EmployerState_ADDR
            @Lc_EmployerZip1_TEXT,--EmployerZip1_ADDR
            @Lc_EmployerZip2_TEXT,--EmployerZip2_ADDR
            @Ln_EmployerPhone_NUMB,--EmployerPhone_NUMB
            @Ld_EffectiveEmployer_DATE,--EffectiveEmployer_DATE
            @Ld_EndEmployer_DATE,--EndEmployer_DATE
            @Lc_EmployerConfirmed_INDC,--EmployerConfirmed_INDC
            @Lc_WageQtr_TEXT,--WageQtr_CODE
            @Lc_WageYear_TEXT,--WageYear_NUMB
            @Ln_Wage_AMNT,--Wage_AMNT
            ISNULL(@Lc_InsCarrier_NAME, @Lc_Space_TEXT),--InsCarrier_NAME
            ISNULL(@Lc_PolicyInsNo_TEXT, @Lc_Space_TEXT),--PolicyInsNo_TEXT
            @Lc_LastResidentialLine1_ADDR,--LastResidentialLine1_ADDR
            @Lc_LastResidentialLine2_ADDR,--LastResidentialLine2_ADDR
            @Lc_LastResCity_TEXT,--LastResidentialCity_ADDR
            @Lc_LastResState_CODE,--LastResidentialState_ADDR
            @Lc_LastResZip1_TEXT,--LastResidentialZip1_ADDR
            @Lc_LastResZip2_TEXT,--LastResidentialZip2_ADDR
            @Ld_LastResAddress_DATE,--LastResAddress_DATE
            @Lc_LastMailLine1_ADDR,--LastMailLine1_ADDR
            @Lc_LastMailLine2_ADDR,--LastMailLine2_ADDR
            @Lc_LastMailCity_TEXT,--LastMailCity_ADDR
            @Lc_LastMailState_CODE,--LastMailState_ADDR
            @Lc_LastMailZip1_TEXT,--LastMailZip1_ADDR
            @Lc_LastMailZip2_TEXT,--LastMailZip2_ADDR
            @Ld_LastMailAddress_DATE,--LastMailAddress_DATE
            @Lc_LastEmployer_TEXT,--LastEmployer_NAME
            @Ld_LastEmployer_DATE,--LastEmployer_DATE
            @Lc_LastEmployerLine1_ADDR,--LastEmployerLine1_ADDR
            @Lc_LastEmployerLine2_ADDR,--LastEmployerLine2_ADDR
            @Lc_LastEmployerCity_TEXT,--LastEmployerCity_ADDR
            @Lc_LastEmployerState_CODE,--LastEmployerState_ADDR
            @Lc_LastEmployerZip1_TEXT,--LastEmployerZip1_ADDR
            @Lc_LastEmployerZip2_TEXT,--LastEmployerZip2_ADDR
            @Ld_LastEmployerEffective_DATE,--LastEmployerEffective_DATE
            @Lc_Employer2Ein_TEXT,--Employer2Ein_ID
            @Lc_Employer2_NAME,--Employer2_NAME
            @Lc_Employer2Line1_ADDR,--Employer2Line1_ADDR
            @Lc_Employer2Line2_ADDR,--Employer2Line2_ADDR
            @Lc_Employer2City_TEXT,--Employer2City_ADDR
            @Lc_Employer2State_CODE,--Employer2State_ADDR
            @Lc_Employer2Zip1_TEXT,--Employer2Zip1_ADDR
            @Lc_Employer2Zip2_TEXT,--Employer2Zip2_ADDR
            @Ln_Employer2Phone_NUMB,--Employer2Phone_NUMB
            @Ld_EffectiveEmployer2_DATE,--EffectiveEmployer2_DATE
            @Ld_EndEmployer2_DATE,--EndEmployer2_DATE
            @Lc_Employer2Confirmed_INDC,--Employer2Confirmed_INDC
            @Lc_Wage2Qtr_TEXT,--Wage2Qtr_CODE
            @Lc_Wage2Year_TEXT,--Wage2Year_NUMB
            @Ln_Wage2_AMNT,--Wage2_AMNT
            @Lc_Employer3Ein_TEXT,--Employer3Ein_ID
            @Lc_Employer3_NAME,--Employer3_NAME
            @Lc_Employer3Line1_ADDR,--Employer3Line1_ADDR
            @Lc_Employer3Line2_ADDR,--Employer3Line2_ADDR
            @Lc_Employer3City_TEXT,--Employer3City_ADDR
            @Lc_Employer3State_CODE,--Employer3State_ADDR
            @Lc_Employer3Zip1_TEXT,--Employer3Zip1_ADDR
            @Lc_Employer3Zip2_TEXT,--Employer3Zip2_ADDR
            @Ln_Employer3Phone_NUMB,--Employer3Phone_NUMB
            @Ld_EffectiveEmployer3_DATE,--EffectiveEmployer3_DATE
            @Ld_EndEmployer3_DATE,--EndEmployer3_DATE
            @Lc_Employer3Confirmed_INDC,--Employer3Confirmed_INDC
            @Lc_Wage3Qtr_TEXT,--Wage3Qtr_CODE
            @Lc_Wage3Year_TEXT,--Wage3Year_NUMB
            @Ln_Wage3_AMNT,--Wage3_AMNT
            @Ls_ProfessionalLicenses_TEXT,--ProfessionalLicenses_TEXT
            @An_TransHeader_IDNO,--TransHeader_IDNO
            @Ac_StateFips_CODE,--IVDOutOfStateFips_CODE
            @Ld_Generated_DATE,--Transaction_DATE
            @Lc_ResidentialLine1_ADDR,--ResidentialLine1_ADDR
            @Lc_ResidentialLine2_ADDR,--ResidentialLine2_ADDR
            @Lc_ResidentialCity_TEXT,--ResidentialCity_ADDR
            @Lc_ResidentialState_CODE,--ResidentialState_ADDR
            @Lc_ResidentialZip1_TEXT,--ResidentialZip1_ADDR
            @Lc_ResidentialZip2_TEXT,--ResidentialZip2_ADDR
            @Lc_MailingLine1_ADDR,--MailingLine1_ADDR
            @Lc_MailingLine2_ADDR,--MailingLine2_ADDR
            @Lc_MailingCity_TEXT,--MailingCity_ADDR
            @Lc_MailingState_CODE,--MailingState_ADDR
            @Lc_MailingZip1_TEXT,--MailingZip1_ADDR
            @Lc_MailingZip2_TEXT,--MailingZip2_ADDR
            @Ld_EffectiveResidential_DATE,--EffectiveResidential_DATE
            @Ld_EndResidential_DATE,--EndResidential_DATE
            @Lc_ResidentialConfirmed_TEXT,--ResidentialConfirmed_CODE
            @Ld_EffectiveMailing_DATE,--EffectiveMailing_DATE
            @Ld_EndMailing_DATE,--EndMailing_DATE
            @Lc_MailingConfirmed_TEXT --MailingConfirmed_CODE
   );

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF (@Li_Rowcount_QNTY = 0)
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'NCP MEMBER,EMPLOYER INFORMATION NOT FOUND FOR : ' + CAST(@Ln_Member_IDNO AS VARCHAR);

     RAISERROR(50001,16,1);
    END;

   IF @Lc_Msg_CODE != ''
    BEGIN
     SET @Ac_Msg_CODE = @Lc_Msg_CODE;
     SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', '@Alias_CUR') IN (0, 1)
    BEGIN
     CLOSE @Alias_CUR;

     DEALLOCATE @Alias_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', '@Empl_CUR') IN (0, 1)
    BEGIN
     CLOSE @Empl_CUR;

     DEALLOCATE @Empl_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

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
