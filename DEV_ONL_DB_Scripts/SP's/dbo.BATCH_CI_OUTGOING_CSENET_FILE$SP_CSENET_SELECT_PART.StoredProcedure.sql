/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_PART]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_PART
Programmer Name	:	IMP Team.
Description		:	This procedure loads all participant data into extract_part_data_blocks table FOR each case id
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
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_PART]
 @An_Case_IDNO             NUMERIC(6),
 @An_TransHeader_IDNO      NUMERIC(12),
 @Ac_StateFips_CODE        CHAR(2),
 @Ac_Function_CODE         CHAR(3),
 @Ac_Action_CODE           CHAR(1),
 @Ac_Reason_CODE           CHAR(5),
 @Ad_Run_DATE              DATE,
 @Ad_Start_DATE            DATE,
 @Ai_Participant_QNTY      INTEGER OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ErrorLine_NUMB              INT = 0,
          @Lc_Space_TEXT                  CHAR(1) = ' ',
          @Lc_ActionProvide_CODE          CHAR(1) = 'P',
          @Lc_RelationshipCaseCp_TEXT     CHAR(1) = 'C',
          @Lc_RelationshipCaseDp_TEXT     CHAR(1) = 'D',
          @Lc_StatusCaseMemberActive_CODE CHAR(1) = 'A',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_VerificationStatusGood_CODE CHAR(1) = 'Y',
          @Lc_StatusNoDataFound_CODE      CHAR(1) = 'N',
          @Lc_No_INDC                     CHAR(1) = 'N',
          @Lc_StatusFailed_CODE           CHAR(1) = 'F',
          @Lc_ActionRequest_CODE          CHAR(1) = 'R',
          @Lc_ActionUpdate_CODE           CHAR(1) = 'U',
          @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
          @Lc_Residential_ADDR            CHAR(1) = 'P',
          @Lc_Relationship_CODE           CHAR(1) = ' ',
          @Lc_ConfirmedAddress_INDC       CHAR(1) = ' ',
          @Lc_ConfirmedEmployer_INDC      CHAR(1) = ' ',
          @Lc_DependentPaternityStat_TEXT CHAR(1) = ' ',
          @Lc_IncomeTypeEmployer_CODE     CHAR(2) = 'EM',
          @Lc_ParticipantState_ADDR       CHAR(2) = ' ',
          @Lc_EmployerState_ADDR          CHAR(2) = ' ',
          @Lc_DependentChildStateRes_CODE CHAR(2) = ' ',
          @Lc_FunctionManagestcases_CODE  CHAR(3) = 'MSC',
          @Lc_FunctionEnforcement_CODE    CHAR(3) = 'ENF',
          @Lc_FunctionEstablishment_CODE  CHAR(3) = 'EST',
          @Lc_FunctionPaternity_CODE      CHAR(3) = 'PAT',
          @Lc_Suffix_NAME                 CHAR(4) = ' ',
          @Lc_ParticipantZip2_ADDR        CHAR(4) = ' ',
          @Lc_EmployerZip2_ADDR           CHAR(4) = ' ',
          @Lc_ParticipantZip1_ADDR        CHAR(5) = ' ',
          @Lc_EmployerZip1_ADDR           CHAR(5) = ' ',
          @Lc_ReasonGsmad_CODE            CHAR(7) = 'GSMAD',
          @Lc_ReasonGsmde_CODE            CHAR(7) = 'GSMDE',
          @Lc_MemberSsn_TEXT              CHAR(9) = ' ',
          @Lc_EinEmployer_TEXT            CHAR(9) = ' ',
          @Lc_First_NAME                  CHAR(16) = ' ',
          @Lc_ParticipantCity_ADDR        CHAR(18) = ' ',
          @Lc_EmployerCity_ADDR           CHAR(18) = ' ',
          @Lc_Last_NAME                   CHAR(20) = ' ',
          @Lc_Middle_NAME                 CHAR(20) = ' ',
          @Lc_ParticipantLine1_ADDR       CHAR(25) = ' ',
          @Lc_ParticipantLine2_ADDR       CHAR(25) = ' ',
          @Lc_EmployerLine1_ADDR          CHAR(25) = ' ',
          @Lc_EmployerLine2_ADDR          CHAR(25) = ' ',
          @Ls_Employer_NAME               VARCHAR(60) = ' ',
          @Ls_Procedure_NAME              VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_SELECT_PART',
          @Ld_Low_DATE                    DATE = '01/01/0001',
          @Ld_High_DATE                   DATE = '12/31/9999',
          @Ld_Birth_DATE                  DATE = '01/01/0001',
          @Ld_ConfirmedAddress_DATE       DATE = '01/01/0001',
          @Ld_ConfirmedEmployer_DATE      DATE = '01/01/0001';
  DECLARE @Li_Error_NUMB        INT = 0,
          @Li_Part_QNTY         INT = 0,
          @Li_Cp_QNTY           INT = 0,
          @Li_Child_QNTY        INT = 0,
          @Li_FetchStatus_NUMB  SMALLINT,
          @Li_Rowcount_QNTY     SMALLINT,
          @Lc_OthStateFips_CODE CHAR(2),
          @Ls_Sql_TEXT          VARCHAR(2000),
          @Ls_Sqldata_TEXT      VARCHAR(4000),
          @Ld_Generated_DATE    DATE,
          @SelectPart_CUR       CURSOR;
  --Cursor Variable Naming:
  DECLARE @Ln_SelectPartCur_MemberMci_IDNO              NUMERIC(10),
          @Lc_SelectPartCur_Last_NAME                   CHAR(20),
          @Lc_SelectPartCur_First_NAME                  CHAR(16),
          @Lc_SelectPartCur_Middle_NAME                 CHAR(20),
          @Lc_SelectPartCur_Suffix_NAME                 CHAR(4),
          @Ld_SelectPartCur_Birth_DATE                  DATE,
          @Ln_SelectPartCur_MemberSsn_NUMB              NUMERIC(9),
          @Lc_SelectPartCur_PaternityEstMethod_CODE     CHAR(3),
          @Ln_SelectPartCur_WorkPhone_NUMB              NUMERIC(15),
          @Lc_SelectPartCur_BirthCity_NAME              CHAR(28),
          @Lc_SelectPartCur_MemberSex_CODE              CHAR(1),
          @Lc_SelectPartCur_Race_CODE                   CHAR(1),
          @Lc_SelectPartCur_CaseMemberStatus_CODE       CHAR(1),
          @Lc_SelectPartCur_NcpRelationshipToChild_CODE CHAR(3),
          @Lc_SelectPartCur_CpRelationshipToChild_CODE  CHAR(3),
          @Lc_SelectPartCur_CaseRelationship_CODE       CHAR(1);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT CSPR_Y1 - PARTICIPANT  DATA BLOCK';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '');

   SELECT @Lc_OthStateFips_CODE = a.IVDOutOfStateFips_CODE,
          @Ld_Generated_DATE = a.Generated_DATE
     FROM CSPR_Y1 a
    WHERE a.Request_IDNO = CAST(@An_TransHeader_IDNO AS NUMERIC)
      AND a.EndValidity_DATE = @Ld_High_DATE;

   -- GSMAD - Medical insurance addition
   -- GSMDE - Medical insurance deletion
   -- Only DP is required for the Reason Code GSMAD And GSMDE
   -- There may be more than one employer for a member. So latest employer detail will be provided
   IF (@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE
       AND @Ac_Action_CODE = @Lc_ActionProvide_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGsmad_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SET CURSOR - 1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '');
     SET @SelectPart_CUR = CURSOR
     FOR SELECT DISTINCT
                a.ChildMCI_IDNO AS MemberMci_IDNO,
                d.Last_NAME,
                d.First_NAME,
                d.Middle_NAME,
                d.Suffix_NAME,
                d.Birth_DATE,
                d.MemberSsn_NUMB,
                e.PaternityEst_CODE,
                d.WorkPhone_NUMB,
                d.BirthCity_NAME,
                d.MemberSex_CODE,
                d.Race_CODE,
                c.CaseMemberStatus_CODE,
                c.NcpRelationshipToChild_CODE,
                c.CpRelationshipToChild_CODE,
                c.CaseRelationship_CODE AS CaseRelationship_CODE
           FROM DINS_Y1 a,
                CSPR_Y1 b,
                OTHP_Y1 o,
                CMEM_Y1 c
                LEFT OUTER JOIN DEMO_Y1 d
                 ON c.MemberMci_IDNO = d.MemberMci_IDNO
                LEFT OUTER JOIN MPAT_Y1 e
                 ON c.MemberMci_IDNO = e.MemberMci_IDNO
          WHERE b.Case_IDNO = @An_Case_IDNO
            AND c.Case_IDNO = b.Case_IDNO
            AND c.MemberMci_IDNO = a.ChildMCI_IDNO
            AND ((ISNUMERIC(b.InsCarrier_NAME) = 0
                  AND (o.OtherParty_NAME = b.InsCarrier_NAME
                       AND a.OthpInsurance_IDNO = o.OtherParty_IDNO))
                  OR (ISNUMERIC(b.InsCarrier_NAME) = 1
                      AND (a.OthpInsurance_IDNO = CASE ISNUMERIC(b.InsCarrier_NAME)
                                                   WHEN 1
                                                    THEN b.InsCarrier_NAME
                                                  END
                           AND a.OthpInsurance_IDNO = o.OtherParty_IDNO)))
            AND a.PolicyInsNo_TEXT = b.InsPolicyNo_TEXT
            AND a.BeginValidity_DATE <= CONVERT(DATE, b.Generated_DATE, 101)
            AND a.EndValidity_DATE = @Ld_High_DATE
            AND b.EndValidity_DATE = @Ld_High_DATE
            AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
            AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
            AND a.End_DATE >= @Ad_Run_DATE
            AND (a.MedicalIns_INDC = @Lc_Yes_INDC
                  OR a.DentalIns_INDC = @Lc_Yes_INDC
                  OR a.VisionIns_INDC = @Lc_Yes_INDC
                  OR a.PrescptIns_INDC = @Lc_Yes_INDC
                  OR a.MentalIns_INDC = @Lc_Yes_INDC)
          ORDER BY c.CaseRelationship_CODE;
    END;
   ELSE IF (@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE
       AND @Ac_Action_CODE = @Lc_ActionProvide_CODE
       AND @Ac_Reason_CODE = @Lc_ReasonGsmde_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SET CURSOR - 2';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '');
     SET @SelectPart_CUR = CURSOR
     FOR SELECT DISTINCT
                a.ChildMCI_IDNO AS MemberMci_IDNO,
                d.Last_NAME,
                d.First_NAME,
                d.Middle_NAME,
                d.Suffix_NAME,
                d.Birth_DATE,
                d.MemberSsn_NUMB,
                e.PaternityEst_CODE AS PaternityEst_CODE,
                d.WorkPhone_NUMB,
                d.BirthCity_NAME,
                d.MemberSex_CODE,
                d.Race_CODE,
                c.CaseMemberStatus_CODE,
                c.NcpRelationshipToChild_CODE,
                c.CpRelationshipToChild_CODE,
                c.CaseRelationship_CODE AS CaseRelationship_CODE
           FROM DINS_Y1 a,
                CSPR_Y1 b,
                OTHP_Y1 o,
                CMEM_Y1 c
                LEFT OUTER JOIN DEMO_Y1 d
                 ON c.MemberMci_IDNO = d.MemberMci_IDNO
                LEFT OUTER JOIN MPAT_Y1 e
                 ON c.MemberMci_IDNO = e.MemberMci_IDNO
          WHERE b.Case_IDNO = @An_Case_IDNO
            AND c.Case_IDNO = b.Case_IDNO
            AND ((ISNUMERIC(b.InsCarrier_NAME) = 0
                  AND (o.OtherParty_NAME = b.InsCarrier_NAME
                       AND a.OthpInsurance_IDNO = o.OtherParty_IDNO))
                  OR (ISNUMERIC(b.InsCarrier_NAME) = 1
                      AND (a.OthpInsurance_IDNO = CASE ISNUMERIC(b.InsCarrier_NAME)
                                                   WHEN 1
                                                    THEN b.InsCarrier_NAME
                                                  END
                           AND a.OthpInsurance_IDNO = o.OtherParty_IDNO)))
            AND a.PolicyInsNo_TEXT = b.InsPolicyNo_TEXT
            AND a.BeginValidity_DATE <= CONVERT(DATE, b.Generated_DATE, 101)
            AND a.EndValidity_DATE <> @Ld_High_DATE
            AND b.EndValidity_DATE = @Ld_High_DATE
            AND c.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
            AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
            AND a.End_DATE >= @Ad_Run_DATE
            AND c.MemberMci_IDNO = a.ChildMCI_IDNO
          ORDER BY c.CaseRelationship_CODE;
    END;
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'SET CURSOR - 3';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Request_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '');
     SET @SelectPart_CUR = CURSOR
     FOR SELECT DISTINCT
                b.MemberMci_IDNO AS MemberMci_IDNO,
                c.Last_NAME,
                c.First_NAME,
                c.Middle_NAME,
                c.Suffix_NAME,
                c.Birth_DATE,
                c.MemberSsn_NUMB AS MemberSsn_NUMB,
                d.PaternityEst_CODE AS PaternityEst_CODE,
                c.WorkPhone_NUMB,
                c.BirthCity_NAME,
                c.MemberSex_CODE AS MemberSex_CODE,
                c.Race_CODE,
                b.CaseMemberStatus_CODE AS CaseMemberStatus_CODE,
                b.NcpRelationshipToChild_CODE,
                b.CpRelationshipToChild_CODE AS CpRelationshipToChild_CODE,
                b.CaseRelationship_CODE
           FROM CMEM_Y1 b
                LEFT OUTER JOIN DEMO_Y1 c
                 ON b.MemberMci_IDNO = c.MemberMci_IDNO
                LEFT OUTER JOIN MPAT_Y1 d
                 ON b.MemberMci_IDNO = d.MemberMci_IDNO
          WHERE b.Case_IDNO = @An_Case_IDNO
            AND b.MemberMci_IDNO = c.MemberMci_IDNO
            AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseCp_TEXT, @Lc_RelationshipCaseDp_TEXT)
            AND b.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
          ORDER BY b.CaseRelationship_CODE;
    END;

   -- Cursor starts 		
   SET @Ls_Sql_TEXT = 'OPEN @SelectPart_CUR';
   SET @Ls_Sqldata_TEXT = '';

   OPEN @SelectPart_CUR;

   SET @Ls_Sql_TEXT = 'FETCH @SelectPart_CUR';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM @SelectPart_CUR INTO @Ln_SelectPartCur_MemberMci_IDNO, @Lc_SelectPartCur_Last_NAME, @Lc_SelectPartCur_First_NAME, @Lc_SelectPartCur_Middle_NAME, @Lc_SelectPartCur_Suffix_NAME, @Ld_SelectPartCur_Birth_DATE, @Ln_SelectPartCur_MemberSsn_NUMB, @Lc_SelectPartCur_PaternityEstMethod_CODE, @Ln_SelectPartCur_WorkPhone_NUMB, @Lc_SelectPartCur_BirthCity_NAME, @Lc_SelectPartCur_MemberSex_CODE, @Lc_SelectPartCur_Race_CODE, @Lc_SelectPartCur_CaseMemberStatus_CODE, @Lc_SelectPartCur_NcpRelationshipToChild_CODE, @Lc_SelectPartCur_CpRelationshipToChild_CODE, @Lc_SelectPartCur_CaseRelationship_CODE;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Insert participant list to the block
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     SET @Lc_ParticipantLine1_ADDR = @Lc_Space_TEXT;
     SET @Lc_ParticipantLine2_ADDR = @Lc_Space_TEXT;
     SET @Lc_ParticipantCity_ADDR = @Lc_Space_TEXT;
     SET @Lc_ParticipantState_ADDR = @Lc_Space_TEXT;
     SET @Lc_ParticipantZip1_ADDR = @Lc_Space_TEXT;
     SET @Lc_ParticipantZip2_ADDR = @Lc_Space_TEXT;
     SET @Ls_Employer_NAME = @Lc_Space_TEXT;
     SET @Lc_EmployerLine1_ADDR = @Lc_Space_TEXT;
     SET @Lc_EmployerLine2_ADDR = @Lc_Space_TEXT;
     SET @Lc_EmployerCity_ADDR = @Lc_Space_TEXT;
     SET @Lc_EmployerState_ADDR = @Lc_Space_TEXT;
     SET @Lc_EmployerZip1_ADDR = @Lc_Space_TEXT;
     SET @Lc_EmployerZip2_ADDR = @Lc_Space_TEXT;
     SET @Lc_EinEmployer_TEXT = @Lc_Space_TEXT;
     SET @Lc_ConfirmedAddress_INDC = @Lc_Space_TEXT;
     SET @Lc_ConfirmedEmployer_INDC = @Lc_Space_TEXT;
     SET @Ld_ConfirmedEmployer_DATE = @Ld_Low_DATE;
     SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
     SET @Li_Part_QNTY = @Li_Part_QNTY + 1;

     IF @Lc_SelectPartCur_CaseRelationship_CODE = @Lc_RelationshipCaseCp_TEXT
      BEGIN
       SET @Li_Cp_QNTY = @Li_Cp_QNTY + 1;
       SET @Ls_Sql_TEXT = 'SELECT EMPLOYER DETAILS FOR CP';
      END
     ELSE IF @Lc_SelectPartCur_CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
      BEGIN
       SET @Li_Child_QNTY = @Li_Child_QNTY + 1;
       SET @Ls_Sql_TEXT = 'SELECT EMPLOYER DETAILS FOR DP';
      END;

     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SelectPartCur_MemberMci_IDNO AS VARCHAR), '');

     SELECT TOP (1) @Ls_Employer_NAME = Z.Employer_NAME,
                    @Lc_EmployerLine1_ADDR = Z.EmployerLine1_ADDR,
                    @Lc_EmployerLine2_ADDR = Z.EmployerLine2_ADDR,
                    @Lc_EmployerCity_ADDR = Z.EmployerCity_ADDR,
                    @Lc_EmployerState_ADDR = Z.EmployerState_ADDR,
                    @Lc_EmployerZip1_ADDR = Z.zip1_employer,
                    @Lc_EmployerZip2_ADDR = Z.zip2_employer,
                    @Lc_EinEmployer_TEXT = Z.EinEmployer_ID,
                    @Lc_ConfirmedAddress_INDC = Z.address_verified,
                    @Lc_ConfirmedEmployer_INDC = Z.employer_status,
                    @Ld_ConfirmedEmployer_DATE = Z.ConfirmedEmployer_DATE
       FROM (SELECT SUBSTRING(f.OtherParty_NAME, 1, 40) AS Employer_NAME,
                    SUBSTRING(f.Line1_ADDR, 1, 25) AS EmployerLine1_ADDR,
                    SUBSTRING(f.Line2_ADDR, 1, 25) AS EmployerLine2_ADDR,
                    SUBSTRING(f.City_ADDR, 1, 18) AS EmployerCity_ADDR,
                    f.State_ADDR AS EmployerState_ADDR,
                    SUBSTRING(f.Zip_ADDR, 1, 5) AS zip1_employer,
                    SUBSTRING(REPLACE(f.Zip_ADDR, '-', ''), 6, 4) AS zip2_employer,
                    f.Fein_IDNO AS EinEmployer_ID,
                    f.Verified_INDC AS address_verified,
                    g.Status_CODE AS employer_status,
                    g.Status_DATE AS ConfirmedEmployer_DATE,
                    g.BeginEmployment_DATE,
                    g.TransactionEventSeq_NUMB
               FROM OTHP_Y1 f,
                    EHIS_Y1 g
              WHERE g.MemberMci_IDNO = @Ln_SelectPartCur_MemberMci_IDNO
                AND g.TypeIncome_CODE = @Lc_IncomeTypeEmployer_CODE
                AND g.OthpPartyEmpl_IDNO = f.OtherParty_IDNO
                AND g.Status_CODE = @Lc_VerificationStatusGood_CODE
                AND g.BeginEmployment_DATE <= CONVERT(DATE, @Ad_Start_DATE, 101)
                AND g.EndEmployment_DATE > CONVERT(DATE, @Ad_Start_DATE, 101)
                AND f.EndValidity_DATE = @Ld_High_DATE) AS Z
      ORDER BY Z.BeginEmployment_DATE DESC,
               Z.TransactionEventSeq_NUMB DESC;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       IF @Lc_SelectPartCur_CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
        BEGIN
         SET @Ls_Sql_TEXT = 'NO EMPLOYER DETAILS FOR DP';
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'NO EMPLOYER DETAILS FOR CP';
        END;

       SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;
      END;

     SET @Ls_Sql_TEXT = 'SELECT ADDRESS DETAILS FOR CP/DP';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SelectPartCur_MemberMci_IDNO AS VARCHAR), '');

     SELECT TOP (1) @Lc_ParticipantLine1_ADDR = Z.addr_line1_part,
                    @Lc_ParticipantLine2_ADDR = Z.addr_line2_part,
                    @Lc_ParticipantCity_ADDR = Z.addr_city_part,
                    @Lc_ParticipantState_ADDR = Z.State_ADDR,
                    @Lc_ParticipantZip1_ADDR = Z.Zip1_ADDR,
                    @Lc_ParticipantZip2_ADDR = Z.Zip2_ADDR
       FROM (SELECT SUBSTRING(e.Line1_ADDR, 1, 25) AS addr_line1_part,
                    SUBSTRING(e.Line2_ADDR, 1, 25) AS addr_line2_part,
                    SUBSTRING(e.City_ADDR, 1, 18) AS addr_city_part,
                    e.State_ADDR,
                    SUBSTRING(e.Zip_ADDR, 1, 5) AS Zip1_ADDR,
                    SUBSTRING(REPLACE(e.Zip_ADDR, '-', ''), 6, 4) AS Zip2_ADDR,
                    e.Begin_DATE,
                    e.TransactionEventSeq_NUMB
               FROM AHIS_Y1 e
              WHERE e.MemberMci_IDNO = @Ln_SelectPartCur_MemberMci_IDNO
                AND e.TypeAddress_CODE = @Lc_Residential_ADDR
                AND e.Status_CODE = @Lc_VerificationStatusGood_CODE
                AND e.End_DATE > CONVERT(DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 101)) AS Z
      ORDER BY Z.Begin_DATE DESC,
               Z.TransactionEventSeq_NUMB DESC;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       IF @Lc_SelectPartCur_CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
        BEGIN
         SET @Ls_Sql_TEXT = 'NO ADDRESS DETAILS FOUND FOR DP';
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'NO ADDRESS DETAILS FOUND  FOR CP';
        END;

       SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;
      END;

     IF (LTRIM(@Lc_DependentPaternityStat_TEXT) != '')
      BEGIN
       SET @Lc_DependentPaternityStat_TEXT = @Lc_SelectPartCur_PaternityEstMethod_CODE;
      END;

     SET @Ls_Sql_TEXT = 'INSERT EPBLK_Y1';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_TransHeader_IDNO AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_StateFips_CODE, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_Generated_DATE AS VARCHAR), '') + ', BlockSeq_NUMB = ' + ISNULL(CAST(@Li_Part_QNTY AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_SelectPartCur_MemberMci_IDNO AS VARCHAR), '') + ', MemberSex_CODE = ' + ISNULL(@Lc_SelectPartCur_MemberSex_CODE, '') + ', Race_CODE = ' + ISNULL(@Lc_SelectPartCur_Race_CODE, '') + ', ParticipantStatus_CODE = ' + ISNULL(@Lc_SelectPartCur_CaseMemberStatus_CODE, '') + ', ParticipantState_ADDR = ' + ISNULL(@Lc_ParticipantState_ADDR, '') + ', ParticipantZip1_ADDR = ' + ISNULL(@Lc_ParticipantZip1_ADDR, '') + ', ParticipantZip2_ADDR = ' + ISNULL(@Lc_ParticipantZip2_ADDR, '') + ', Employer_NAME = ' + ISNULL(@Ls_Employer_NAME, '') + ', EmployerLine1_ADDR = ' + ISNULL(@Lc_EmployerLine1_ADDR, '') + ', EmployerLine2_ADDR = ' + ISNULL(@Lc_EmployerLine2_ADDR, '') + ', EmployerCity_ADDR = ' + ISNULL(@Lc_EmployerCity_ADDR, '') + ', EmployerState_ADDR = ' + ISNULL(@Lc_EmployerState_ADDR, '') + ', EmployerZip1_ADDR = ' + ISNULL(@Lc_EmployerZip1_ADDR, '') + ', EmployerZip2_ADDR = ' + ISNULL(@Lc_EmployerZip2_ADDR, '') + ', EinEmployer_ID = ' + ISNULL(@Lc_EinEmployer_TEXT, '') + ', ConfirmedAddress_INDC = ' + ISNULL(@Lc_ConfirmedAddress_INDC, '') + ', ConfirmedAddress_DATE = ' + ISNULL(CAST(@Ld_ConfirmedAddress_DATE AS VARCHAR), '') + ', ConfirmedEmployer_DATE = ' + ISNULL(CAST(@Ld_ConfirmedEmployer_DATE AS VARCHAR), '') + ', WorkPhone_NUMB = ' + ISNULL(CAST(@Ln_SelectPartCur_WorkPhone_NUMB AS VARCHAR), '') + ', ChildStateResidence_CODE = ' + ISNULL(@Lc_DependentChildStateRes_CODE, '');

     INSERT EPBLK_Y1
            (TransHeader_IDNO,
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
             ParticipantLine1_ADDR,
             ParticipantLine2_ADDR,
             ParticipantCity_ADDR,
             ParticipantState_ADDR,
             ParticipantZip1_ADDR,
             ParticipantZip2_ADDR,
             Employer_NAME,
             EmployerLine1_ADDR,
             EmployerLine2_ADDR,
             EmployerCity_ADDR,
             EmployerState_ADDR,
             EmployerZip1_ADDR,
             EmployerZip2_ADDR,
             EinEmployer_ID,
             ConfirmedAddress_INDC,
             ConfirmedAddress_DATE,
             ConfirmedEmployer_INDC,
             ConfirmedEmployer_DATE,
             WorkPhone_NUMB,
             PlaceOfBirth_NAME,
             ChildStateResidence_CODE,
             ChildPaternityStatus_CODE)
     VALUES ( @An_TransHeader_IDNO,--TransHeader_IDNO
              @Ac_StateFips_CODE,--IVDOutOfStateFips_CODE
              @Ld_Generated_DATE,--Transaction_DATE
              @Li_Part_QNTY,--BlockSeq_NUMB
              @Ln_SelectPartCur_MemberMci_IDNO,--MemberMci_IDNO
              SUBSTRING(ISNULL(@Lc_SelectPartCur_Last_NAME, @Lc_Last_NAME), 1, 21),--Last_NAME
              SUBSTRING(ISNULL(@Lc_SelectPartCur_First_NAME, @Lc_First_NAME), 1, 16),--First_NAME
              SUBSTRING(ISNULL(@Lc_SelectPartCur_Middle_NAME, @Lc_Middle_NAME), 1, 16),--Middle_NAME
              SUBSTRING(ISNULL(@Lc_SelectPartCur_Suffix_NAME, @Lc_Suffix_NAME), 1, 3),--Suffix_NAME
              ISNULL(@Ld_SelectPartCur_Birth_DATE, @Ld_Birth_DATE),--Birth_DATE
              ISNULL(@Ln_SelectPartCur_MemberSsn_NUMB, @Lc_MemberSsn_TEXT),--MemberSsn_NUMB
              @Lc_SelectPartCur_MemberSex_CODE,--MemberSex_CODE
              @Lc_SelectPartCur_Race_CODE,--Race_CODE
              ISNULL(@Lc_SelectPartCur_CaseRelationship_CODE, @Lc_Relationship_CODE),--Relationship_CODE
              @Lc_SelectPartCur_CaseMemberStatus_CODE,--ParticipantStatus_CODE
              dbo.BATCH_CI_OUTGOING_CSENET_FILE$SF_CONVERT_CSENET_CODE('PARTICIPANT_DATA_BLOCKS', 'DEPENDENT_RELATION_NCP_CODE', 'O', ISNULL(@Lc_SelectPartCur_CpRelationshipToChild_CODE, '')),--ChildRelationshipNcp_CODE
              SUBSTRING(@Lc_ParticipantLine1_ADDR, 1, 25),--ParticipantLine1_ADDR
              SUBSTRING(@Lc_ParticipantLine2_ADDR, 1, 25),--ParticipantLine2_ADDR
              SUBSTRING(@Lc_ParticipantCity_ADDR, 1, 18),--ParticipantCity_ADDR
              @Lc_ParticipantState_ADDR,--ParticipantState_ADDR
              @Lc_ParticipantZip1_ADDR,--ParticipantZip1_ADDR
              @Lc_ParticipantZip2_ADDR,--ParticipantZip2_ADDR
              @Ls_Employer_NAME,--Employer_NAME
              @Lc_EmployerLine1_ADDR,--EmployerLine1_ADDR
              @Lc_EmployerLine2_ADDR,--EmployerLine2_ADDR
              @Lc_EmployerCity_ADDR,--EmployerCity_ADDR
              @Lc_EmployerState_ADDR,--EmployerState_ADDR
              @Lc_EmployerZip1_ADDR,--EmployerZip1_ADDR
              @Lc_EmployerZip2_ADDR,--EmployerZip2_ADDR
              @Lc_EinEmployer_TEXT,--EinEmployer_ID
              @Lc_ConfirmedAddress_INDC,--ConfirmedAddress_INDC
              @Ld_ConfirmedAddress_DATE,--ConfirmedAddress_DATE
              ISNULL(@Lc_ConfirmedEmployer_INDC, ''),--ConfirmedEmployer_INDC
              @Ld_ConfirmedEmployer_DATE,--ConfirmedEmployer_DATE
              @Ln_SelectPartCur_WorkPhone_NUMB,--WorkPhone_NUMB
              SUBSTRING(@Lc_SelectPartCur_BirthCity_NAME, 1, 25),--PlaceOfBirth_NAME
              @Lc_DependentChildStateRes_CODE,--ChildStateResidence_CODE
              CASE @Lc_DependentPaternityStat_TEXT
               WHEN @Lc_Space_TEXT
                THEN @Lc_No_INDC
               WHEN @Lc_SelectPartCur_PaternityEstMethod_CODE
                THEN @Lc_No_INDC
               ELSE @Lc_DependentPaternityStat_TEXT
              END --ChildPaternityStatus_CODE
     );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @As_DescriptionError_TEXT = 'INSERT EXTRACT PARTICIPANT BLOCKS FAILED';

       RAISERROR(50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'FETCH @SelectPart_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM @SelectPart_CUR INTO @Ln_SelectPartCur_MemberMci_IDNO, @Lc_SelectPartCur_Last_NAME, @Lc_SelectPartCur_First_NAME, @Lc_SelectPartCur_Middle_NAME, @Lc_SelectPartCur_Suffix_NAME, @Ld_SelectPartCur_Birth_DATE, @Ln_SelectPartCur_MemberSsn_NUMB, @Lc_SelectPartCur_PaternityEstMethod_CODE, @Ln_SelectPartCur_WorkPhone_NUMB, @Lc_SelectPartCur_BirthCity_NAME, @Lc_SelectPartCur_MemberSex_CODE, @Lc_SelectPartCur_Race_CODE, @Lc_SelectPartCur_CaseMemberStatus_CODE, @Lc_SelectPartCur_NcpRelationshipToChild_CODE, @Lc_SelectPartCur_CpRelationshipToChild_CODE, @Lc_SelectPartCur_CaseRelationship_CODE;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   CLOSE @SelectPart_CUR;

   DEALLOCATE @SelectPart_CUR;

   IF @Li_Part_QNTY = 0
    BEGIN
     SET @As_DescriptionError_TEXT = 'NO PARTICIPANT INFORMATION FOUND FOR : ' + CAST(@An_Case_IDNO AS VARCHAR);

     RAISERROR(50001,16,1);
    END;

   IF (@Ac_Function_CODE IN (@Lc_FunctionEnforcement_CODE, @Lc_FunctionEstablishment_CODE, @Lc_FunctionPaternity_CODE)
       AND @Ac_Action_CODE IN (@Lc_ActionRequest_CODE, @Lc_ActionUpdate_CODE)
       AND (@Li_Cp_QNTY = 0
             OR @Li_Child_QNTY = 0))
    BEGIN
     SET @As_DescriptionError_TEXT = 'ONE CP AND ONE DEP REQUIRED!  : ' + CAST(@An_Case_IDNO AS VARCHAR);

     RAISERROR(50001,16,1);
    END;

   IF @Li_Part_QNTY < @Ai_Participant_QNTY
    BEGIN
     SET @As_DescriptionError_TEXT = 'THIS CASE REQUIRES MINIMUM' + CAST(@Ai_Participant_QNTY AS VARCHAR) + ' PARTICIPANT BLOCKS : ' + CAST(@An_Case_IDNO AS VARCHAR);

     RAISERROR(50001,16,1);
    END;

   SET @Ai_Participant_QNTY = @Li_Part_QNTY;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('VARIABLE', '@SelectPart_CUR') IN (0, 1)
    BEGIN
     CLOSE @SelectPart_CUR;

     DEALLOCATE @SelectPart_CUR;
    END;

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
