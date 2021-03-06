/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_OTHP]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_OTHP
Programmer Name		: IMP Team
Description			: This procedure is used to identify an existing or create a new OTHP ID for employment
					  information / Financial Institute information / Insurance company / Attorney received
                      via applicable interfaces using the OTHP de-duplicate process.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_OTHP]
 @Ad_Run_DATE                     DATE,
 @An_Fein_IDNO                    NUMERIC(9) = 0,
 @Ac_TypeOthp_CODE                CHAR(1),
 @As_OtherParty_NAME              VARCHAR(60),
 @Ac_Aka_NAME                     CHAR(30),
 @Ac_Attn_ADDR                    CHAR(40),
 @As_Line1_ADDR                   VARCHAR(50),
 @As_Line2_ADDR                   VARCHAR(50),
 @Ac_City_ADDR                    CHAR(28),
 @Ac_Zip_ADDR                     CHAR(15),
 @Ac_State_ADDR                   CHAR(2),
 @Ac_Fips_CODE                    CHAR(7),
 @Ac_Country_ADDR                 CHAR(2),
 @Ac_DescriptionContactOther_TEXT CHAR(30),
 @An_Phone_NUMB                   NUMERIC(15) = 0,
 @An_Fax_NUMB                     NUMERIC(15) = 0,
 @As_Contact_EML                  VARCHAR(100),
 @An_ReferenceOthp_IDNO           NUMERIC(10),
 @An_BarAtty_NUMB                 NUMERIC(10),
 @An_Sein_IDNO                    NUMERIC(12),
 @Ac_SourceLoc_CODE               CHAR(3),
 @Ac_WorkerUpdate_ID              CHAR(30),
 @An_DchCarrier_IDNO              NUMERIC(8) = 0,
 @Ac_Normalization_CODE           CHAR(1),
 @Ac_Process_ID                   CHAR(10),
 @An_OtherParty_IDNO              NUMERIC(9) OUTPUT,
 @Ac_Msg_CODE                     CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT        VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_Yes_INDC               CHAR(1) = 'Y',
          @Lc_No_INDC                CHAR(1) = 'N',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE     CHAR(1) = 'S',
          @Lc_TypeOthpE_CODE         CHAR(1) = 'E',
          @Lc_TypeOthpX_CODE         CHAR(1) = 'X',
          @Lc_TypeOthpM_CODE         CHAR(1) = 'M',
          @Lc_TypeOthpH_CODE         CHAR(1) = 'H',
          @Lc_TypeOthpI_CODE         CHAR(1) = 'I',
          @Lc_TypeOthpA_CODE         CHAR(1) = 'A',
          @Lc_TypeOthpP_CODE         CHAR(1) = 'P',
          @Lc_UnnormalizedU_INDC     CHAR(1) = 'U',
          @Lc_OthpExist_INDC         CHAR(1) = 'Y',
          @Lc_InsuranceProvided_INDC CHAR(1) = 'Y',
          @Lc_Nsf_INDC               CHAR(1) = 'N',
          @Lc_Verified_INDC          CHAR(1) = 'Y',
          @Lc_Note_INDC              CHAR(1) = ' ',
          @Lc_Eiwn_CODE              CHAR(1) = ' ',
          @Lc_Enmsn_INDC             CHAR(1) = ' ',
          @Lc_NmsnGen_INDC           CHAR(1) = ' ',
          @Lc_NmsnInst_INDC          CHAR(1) = ' ',
          @Lc_Tribal_INDC            CHAR(1) = ' ',
          @Lc_SendShort_INDC         CHAR(1) = ' ',
          @Lc_PpaEiwn_INDC           CHAR(1) = ' ',
          @Lc_CountryUs_CODE         CHAR(2) = 'US',
          @Lc_Tribal_CODE            CHAR(2) = ' ',
          @Lc_SourceLocIva_CODE      CHAR(3) = 'IVA',
          @Lc_SourceLocDoc_CODE      CHAR(3) = 'DOC',
          @Lc_SourceLocLwd_CODE      CHAR(3) = 'LWD',
          @Lc_SourceLocFpl_CODE      CHAR(3) = 'FPL',
          @Lc_SourceLocPut_CODE      CHAR(3) = 'PUT',
          @Lc_SourceLocOcs_CODE      CHAR(3) = 'OCS',
          @Lc_SourceLocFcr_CODE      CHAR(3) = 'FCR',
          @Lc_SourceLocDor_CODE      CHAR(3) = 'DOR',
          @Lc_SourceLocSnh_CODE      CHAR(3) = 'SNH',
          @Lc_SourceLocIve_CODE      CHAR(3) = 'IVE',
          @Lc_SourceLocOsa_CODE      CHAR(3) = 'OSA',
          @Lc_SourceInsurerMd_CODE   CHAR(3) = 'MED',
          @Lc_SourceInsurerCsl_CODE  CHAR(3) = 'CSL',
          @Lc_SourceInsurerDia_CODE  CHAR(3) = 'DIA',
          @Lc_TableStat_ID           CHAR(4) = 'STAT',
          @Lc_TableSubStat_ID        CHAR(4) = 'STAT',
          @Lc_TableOthp_ID           CHAR(4) = 'OTHP',
          @Lc_TableSubType_ID        CHAR(4) = 'TYPE',
          @Lc_ErrorE0606_CODE        CHAR(5) = 'E0606',
          @Lc_ErrorE0702_CODE        CHAR(5) = 'E0702',
          @Lc_ErrorE0542_CODE        CHAR(5) = 'E0542',
          @Lc_ErrorE0520_CODE        CHAR(5) = 'E0520',
          @Lc_ErrorE0540_CODE        CHAR(5) = 'E0540',
          @Lc_ErrorE0145_CODE        CHAR(5) = 'E0145',
          @Lc_ProcessFcrInsmatch_ID  CHAR(8) = 'FCR_IM',
          @Lc_RegNumeric_TEXT        CHAR(15) = '[[:DIGIT:]]+',
          @Lc_RegNotSpecialchar_TEXT CHAR(30) = '[^[:ALPHA:][:DIGIT:]-#./ ,'']',
          @Lc_Err0606_TEXT           CHAR(30) = 'INVALID ADDRESS',
          @Lc_Err0702_TEXT           CHAR(30) = 'INVALID CITY',
          @Lc_Err0542_TEXT           CHAR(30) = 'INVALID STATE',
          @Lc_Err0520_TEXT           CHAR(30) = 'INVALID ZIP',
          @Ls_OtherParty_NAME        VARCHAR(60) = ' ',
          @Ls_Procedure_NAME         VARCHAR(100) = 'BATCH_COMMON$SP_GET_OTHP',
          @Ls_DescriptionNotes_TEXT  VARCHAR(4000) = ' ',
          @Ld_High_DATE              DATE = '12/31/9999';
  DECLARE @Ln_Rowcount_QNTY            NUMERIC,
          @Ln_Exists_NUMB              NUMERIC(1) = 0,
          @Ln_County_IDNO              NUMERIC(3) = 0,
          @Ln_DchCarrier_IDNO          NUMERIC(8) = 0,
          @Ln_OtherParty_IDNO          NUMERIC(9) = 0,
          @Ln_Fein_IDNO                NUMERIC(9),
          @Ln_NewOtherParty_IDNO       NUMERIC(9) = 0,
          @Ln_ParentFein_IDNO          NUMERIC(9) = 0,
          @Ln_ReferenceOthp_IDNO       NUMERIC(10),
          @Ln_Error_NUMB               NUMERIC(11),
          @Ln_ErrorLine_NUMB           NUMERIC(11),
          @Ln_Phone_NUMB               NUMERIC(15) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(19),
          @Lc_TypeOthp_CODE            CHAR(1),
          @Lc_OtherParty2_NAME         CHAR(1),
          @Lc_State_ADDR               CHAR(2),
          @Lc_Country_ADDR             CHAR(2),
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_Zip_ADDR                 CHAR(15),
          @Lc_ZipShort_ADDR            CHAR(15),
          @Lc_City_ADDR                CHAR(28),
          @Lc_FilterCity_ADDR          CHAR(28),
          @Ls_Line1_ADDR               VARCHAR(50),
          @Ls_FilterLine1_ADDR         VARCHAR(50),
          @Ls_FilterLine2_ADDR         VARCHAR(50),
          @Ls_Sql_TEXT                 VARCHAR(100) = '',
          @Ls_Sqldata_TEXT             VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT        VARCHAR(2000);

  BEGIN TRY
   SET @An_OtherParty_IDNO = 0;
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_TypeOthp_CODE = ISNULL(LTRIM(RTRIM(@Ac_TypeOthp_CODE)), @Lc_Space_TEXT);
   SET @Ln_Fein_IDNO = @An_Fein_IDNO;
   SET @Ln_ReferenceOthp_IDNO = ISNULL(LTRIM(RTRIM(@An_ReferenceOthp_IDNO)), 0);
   SET @Ls_Line1_ADDR = ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@As_Line1_ADDR, @Lc_RegNotSpecialchar_TEXT, @Lc_Space_TEXT), @Lc_Space_TEXT);
   SET @Lc_City_ADDR = ISNULL (LTRIM(RTRIM (@Ac_City_ADDR)), @Lc_Space_TEXT);
   SET @Ls_FilterLine1_ADDR = ISNULL (LTRIM(RTRIM (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@As_Line1_ADDR, @Lc_RegNotSpecialchar_TEXT, @Lc_Space_TEXT))), @Lc_Space_TEXT);
   SET @Ls_FilterLine2_ADDR = ISNULL (LTRIM(RTRIM (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@As_Line2_ADDR, @Lc_RegNotSpecialchar_TEXT, @Lc_Space_TEXT))), @Lc_Space_TEXT);
   SET @Lc_FilterCity_ADDR = ISNULL (LTRIM(RTRIM (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@Ac_City_ADDR, @Lc_RegNotSpecialchar_TEXT, @Lc_Space_TEXT))), @Lc_Space_TEXT);
   SET @Lc_State_ADDR = ISNULL (LTRIM(RTRIM (@Ac_State_ADDR)), @Lc_Space_TEXT);
   SET @Lc_Zip_ADDR = ISNULL (LTRIM(RTRIM (@Ac_Zip_ADDR)), @Lc_Space_TEXT);
   SET @Lc_ZipShort_ADDR = SUBSTRING(@Lc_Zip_ADDR, 1, 5);
   SET @Lc_OtherParty2_NAME = SUBSTRING(LTRIM(RTRIM (@As_OtherParty_NAME)), 1, 1);
   SET @Lc_Country_ADDR = CASE
                           WHEN ISNULL(LTRIM(RTRIM(@Ac_Country_ADDR)), @Lc_Space_TEXT) = @Lc_Space_TEXT
                            THEN UPPER(@Lc_CountryUs_CODE)
                           ELSE UPPER(LTRIM(RTRIM(@Ac_Country_ADDR)))
                          END

   IF @Ln_Fein_IDNO <> 0
      AND @Lc_TypeOthp_CODE IN (@Lc_TypeOthpE_CODE)
    BEGIN
     SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO
       FROM OTHP_Y1 o
      WHERE o.Fein_IDNO = @Ln_Fein_IDNO
        AND o.TypeOthp_CODE = @Lc_TypeOthp_CODE
        AND o.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF @Ln_Rowcount_QNTY != 0
        AND @Ln_OtherParty_IDNO != 0
      BEGIN
       SET @An_OtherParty_IDNO = @Ln_OtherParty_IDNO;
       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
       SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;

       RETURN;
      END
    END

   -- Input Address Line 1 null validation
   IF ISNULL(LTRIM(RTRIM(@Ls_FilterLine1_ADDR)), @Lc_Space_TEXT) = @Lc_Space_TEXT
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0606_CODE;
     SET @Ls_ErrorMessage_TEXT = @Lc_Err0606_TEXT;

     RAISERROR (50001,16,1);
    END

   -- Input Address City null validation
   IF ISNULL(LTRIM(RTRIM(@Lc_FilterCity_ADDR)), @Lc_Space_TEXT) = @Lc_Space_TEXT
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0702_CODE;
     SET @Ls_ErrorMessage_TEXT = @Lc_Err0702_TEXT;

     RAISERROR (50001,16,1);
    END

   -- Input Address State null validation
   IF ISNULL(LTRIM(RTRIM(@Ac_State_ADDR)), @Lc_Space_TEXT) = @Lc_Space_TEXT
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0542_CODE;
     SET @Ls_ErrorMessage_TEXT = @Lc_Err0542_TEXT;

     RAISERROR (50001,16,1);
    END

   -- To add validation for ADDR_STATE
   IF @Lc_Country_ADDR = @Lc_CountryUs_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT VREFM1';
     SET @Ls_Sqldata_TEXT = 'Table_ID = ' + ISNULL(@Lc_TableStat_ID, '') + ', TableSub_ID = ' + ISNULL(@Lc_TableSubStat_ID, '') + ', Value_CODE = ' + ISNULL(@Lc_State_ADDR, '');

     SELECT @Ln_Exists_NUMB = COUNT (1)
       FROM REFM_Y1 r
      WHERE r.Table_ID = @Lc_TableStat_ID
        AND r.TableSub_ID = @Lc_TableSubStat_ID
        AND r.Value_CODE = @Lc_State_ADDR;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0542_CODE;
       SET @Ls_ErrorMessage_TEXT = @Lc_Err0542_TEXT;

       RAISERROR (50001,16,1);
      END
    END

   -- Input Address Zip null validation
   IF ISNULL(LTRIM(RTRIM(@Ac_Zip_ADDR)), @Lc_Space_TEXT) = @Lc_Space_TEXT
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0520_CODE;
     SET @Ls_ErrorMessage_TEXT = @Lc_Err0520_TEXT;

     RAISERROR (50001,16,1);
    END

   -- To remove hyphen in the zip code when country is US 
   IF @Lc_Country_ADDR = @Lc_CountryUs_CODE
    BEGIN
     SET @Lc_Zip_ADDR = REPLACE(@Lc_Zip_ADDR, '-', '');
    END

   -- To add validation for ADDR_ZIP
   IF (@Lc_Country_ADDR = @Lc_CountryUs_CODE)
      AND ((LEN (@Lc_Zip_ADDR) NOT IN (5, 9))
            OR (dbo.BATCH_COMMON$SF_ISVALIDNUMERIC (@Lc_Zip_ADDR) <> @Lc_Yes_INDC))
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0520_CODE;
     SET @Ls_ErrorMessage_TEXT = @Lc_Err0520_TEXT;

     RAISERROR (50001,16,1);
    END

   ---Check for existance of cd_type_othp in REFM_Y1.
   SET @Ls_Sql_TEXT = 'CHECK REFM VALUE FOR OTHP TYPE';
   SET @Ls_Sqldata_TEXT = 'Table_ID = ' + ISNULL(@Lc_TableOthp_ID, '') + ', TableSub_ID = ' + ISNULL(@Lc_TableSubType_ID, '') + ', Value_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '');

   SELECT @Ln_Exists_NUMB = COUNT (1)
     FROM REFM_Y1 r
    WHERE r.Table_ID = @Lc_TableOthp_ID
      AND r.TableSub_ID = @Lc_TableSubType_ID
      AND r.Value_CODE = @Lc_TypeOthp_CODE;

   IF @Ln_Exists_NUMB > 0
    BEGIN
     ---Check for FEIN and Other Party type: E - Employer, X - UIB,
     ---  M - Military, H - Financial Institution, I - Insurers .
     IF (@Ln_Fein_IDNO <> 0
         AND @Lc_TypeOthp_CODE IN (@Lc_TypeOthpE_CODE, @Lc_TypeOthpX_CODE, @Lc_TypeOthpM_CODE, @Lc_TypeOthpH_CODE, @Lc_TypeOthpI_CODE))
         --- For Other party type 'I -Insurers' Insert record into OTHP_Y1.
         OR (@Ln_Fein_IDNO = 0
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocLwd_CODE)
         OR (@Ln_Fein_IDNO = 0
             -- OSA -  INTERGOVERNMENTAL IV-D AGENCY
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocOsa_CODE)
         OR (@Ln_Fein_IDNO = 0
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocFpl_CODE)
         OR (@Ln_Fein_IDNO = 0
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocDoc_CODE)
         OR (@Ln_Fein_IDNO = 0
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocPut_CODE)
         OR (@Ln_Fein_IDNO = 0
             AND @Ac_SourceLoc_CODE = @Lc_SourceInsurerDia_CODE)
         OR (@Ln_Fein_IDNO = 0
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocIva_CODE)
         OR (@Lc_TypeOthp_CODE = @Lc_TypeOthpA_CODE
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocFcr_CODE
             AND @Ac_Process_ID = @Lc_ProcessFcrInsmatch_ID)
         OR (@Lc_TypeOthp_CODE = @Lc_TypeOthpP_CODE
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocDor_CODE)
         OR @Ac_SourceLoc_CODE = @Lc_SourceLocOcs_CODE
         OR @Ac_SourceLoc_CODE = @Lc_SourceLocSnh_CODE
         OR (@Ac_SourceLoc_CODE = @Lc_SourceLocIve_CODE
             AND @Lc_TypeOthp_CODE = @Lc_TypeOthpE_CODE)
         OR (@Lc_TypeOthp_CODE = @Lc_TypeOthpI_CODE
             AND @Ac_SourceLoc_CODE = @Lc_SourceLocFcr_CODE
             AND @Ac_Process_ID = @Lc_ProcessFcrInsmatch_ID)
         OR (@Lc_TypeOthp_CODE IN (@Lc_TypeOthpI_CODE, @Lc_TypeOthpE_CODE)
             AND @Ac_SourceLoc_CODE = @Lc_SourceInsurerMd_CODE)
         OR (@Lc_TypeOthp_CODE IN (@Lc_TypeOthpI_CODE)
             AND @Ac_SourceLoc_CODE = @Lc_SourceInsurerCsl_CODE)
      BEGIN
       ---Check for Insurers source -'Medicaid'
       IF (@Lc_TypeOthp_CODE IN (@Lc_TypeOthpI_CODE, @Lc_TypeOthpE_CODE)
           AND @Ac_SourceLoc_CODE = @Lc_SourceInsurerMd_CODE)
           OR (@Lc_TypeOthp_CODE IN (@Lc_TypeOthpI_CODE)
               AND @Ac_SourceLoc_CODE = @Lc_SourceInsurerCsl_CODE)
        BEGIN
         ---Get OtherParty_IDNO by using ReferenceOthp_IDNO.
         --To update OTHP if name,phno,DchCarrier_IDNO changes happens
         ---Get OtherParty_IDNO using fein and address.
         SET @Ls_Sql_TEXT = 'GET OtherParty_IDNO1';
         SET @Ls_Sqldata_TEXT = 'TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', City_ADDR = ' + ISNULL(@Lc_FilterCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_State_ADDR, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO,
                @Ln_Phone_NUMB = o.Phone_NUMB,
                @Ls_OtherParty_NAME = o.OtherParty_NAME,
                @Ln_DchCarrier_IDNO = o.DchCarrier_IDNO,
                @Ln_NewOtherParty_IDNO = o.NewOtherParty_IDNO,
                @Ln_ParentFein_IDNO = o.ParentFein_IDNO,
                @Lc_InsuranceProvided_INDC = o.InsuranceProvided_INDC,
                @Ln_County_IDNO = o.County_IDNO,
                @Lc_Nsf_INDC = o.Nsf_INDC,
                @Lc_Verified_INDC = o.Verified_INDC,
                @Lc_Note_INDC = o.Note_INDC,
                @Lc_Enmsn_INDC = o.Enmsn_INDC,
                @Lc_NmsnGen_INDC = o.NmsnGen_INDC,
                @Lc_NmsnInst_INDC = o.NmsnInst_INDC,
                @Lc_Tribal_CODE = o.Tribal_CODE,
                @Lc_Tribal_INDC = o.Tribal_INDC,
                @Lc_SendShort_INDC = o.SendShort_INDC,
                @Lc_PpaEiwn_INDC = o.PpaEiwn_INDC,
                @Ls_DescriptionNotes_TEXT = o.DescriptionNotes_TEXT
           FROM OTHP_Y1 o
          WHERE o.TypeOthp_CODE = @Lc_TypeOthp_CODE
            AND SUBSTRING(o.OtherParty_NAME, 1, 1) = @Lc_OtherParty2_NAME
            AND (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (o.Line1_ADDR, @Lc_RegNumeric_TEXT, ''), @Lc_Space_TEXT) = @Ls_Line1_ADDR)
            AND o.City_ADDR = @Lc_FilterCity_ADDR
            AND o.State_ADDR = @Lc_State_ADDR
            AND SUBSTRING(o.Zip_ADDR, 1, 5) = @Lc_ZipShort_ADDR
            AND o.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

         IF @Ln_Rowcount_QNTY = 1
          BEGIN
           SET @Ls_Sql_TEXT = 'GET OtherParty_IDNO2';
           SET @Ls_Sqldata_TEXT = 'ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_ReferenceOthp_IDNO AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', City_ADDR = ' + ISNULL(@Lc_FilterCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_State_ADDR, '');

           SELECT TOP 1 @Ln_Exists_NUMB = COUNT (1)
             FROM OTHP_Y1 o
            WHERE o.ReferenceOthp_IDNO = @Ln_ReferenceOthp_IDNO
              AND o.OtherParty_IDNO = @Ln_OtherParty_IDNO
              AND o.TypeOthp_CODE = @Lc_TypeOthp_CODE
              AND o.EndValidity_DATE = @Ld_High_DATE
              AND (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (@As_Line1_ADDR, @Lc_RegNumeric_TEXT, @Lc_Space_TEXT), @Lc_Space_TEXT) = @Ls_Line1_ADDR)
              AND o.City_ADDR = @Lc_FilterCity_ADDR
              AND o.State_ADDR = @Lc_State_ADDR
              AND SUBSTRING(o.Zip_ADDR, 1, 5) = @Lc_ZipShort_ADDR;

           IF @Ln_Exists_NUMB = 0
            BEGIN
             IF ISNULL(LTRIM(RTRIM(@As_OtherParty_NAME)), @Lc_Space_TEXT) <> @Lc_Space_TEXT
              BEGIN
               SET @Ls_Sql_TEXT = 'UPDATE OtherParty_IDNO1';
               SET @Ls_Sqldata_TEXT = 'ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_ReferenceOthp_IDNO AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

               UPDATE OTHP_Y1
                  SET EndValidity_DATE = ISNULL (@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
                WHERE OTHP_Y1.ReferenceOthp_IDNO = @Ln_ReferenceOthp_IDNO
                  AND OTHP_Y1.OtherParty_IDNO = @Ln_OtherParty_IDNO
                  AND OTHP_Y1.TypeOthp_CODE = @Lc_TypeOthp_CODE
                  AND OTHP_Y1.EndValidity_DATE = @Ld_High_DATE;

               SET @Lc_OthpExist_INDC = @Lc_No_INDC;
              END
            END
           ELSE
            BEGIN
             IF ISNULL(LTRIM(RTRIM(@As_OtherParty_NAME)), @Lc_Space_TEXT) <> @Lc_Space_TEXT
                AND ((@As_OtherParty_NAME <> @Ls_OtherParty_NAME)
                      -- Added NVL incase if calling program passes NULL values
                      OR (@Ln_Phone_NUMB <> @An_Phone_NUMB
                          AND @An_Phone_NUMB <> 0)
                      OR (@Ln_DchCarrier_IDNO <> ISNULL (@An_DchCarrier_IDNO, 0)
                          AND ISNULL(@An_DchCarrier_IDNO, 0) <> 0))
              BEGIN
               SET @Ls_Sql_TEXT = 'UPDATE OtherParty_IDNO2';
               SET @Ls_Sqldata_TEXT = 'ReferenceOthp_IDNO = ' + ISNULL(CAST(@Ln_ReferenceOthp_IDNO AS VARCHAR), '') + ', OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

               UPDATE OTHP_Y1
                  SET EndValidity_DATE = ISNULL (@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
                WHERE OTHP_Y1.ReferenceOthp_IDNO = @Ln_ReferenceOthp_IDNO
                  AND OTHP_Y1.OtherParty_IDNO = @Ln_OtherParty_IDNO
                  AND OTHP_Y1.TypeOthp_CODE = @Lc_TypeOthp_CODE
                  AND OTHP_Y1.EndValidity_DATE = @Ld_High_DATE;

               SET @Lc_OthpExist_INDC = @Lc_No_INDC;
              END
            END
          END
         ELSE IF @Ln_Rowcount_QNTY = 0
          BEGIN
           SET @Lc_OthpExist_INDC = @Lc_No_INDC;
          END
         ELSE
          BEGIN
           SET @Ac_Msg_CODE = @Lc_ErrorE0145_CODE;
           SET @Ls_ErrorMessage_TEXT = 'TOO MANY INSURER RECORDS IN OTHP';

           RAISERROR (50001,16,1);
          END
        END
       --To derive OtherParty_IDNO for the employers received through DE LWD.
       --First character of name other pary is used in the matching criteria if ID_FIN not received
       ELSE IF @Ln_Fein_IDNO = 0
          AND @Ac_SourceLoc_CODE = @Lc_SourceLocLwd_CODE
          AND @Lc_TypeOthp_CODE = @Lc_TypeOthpE_CODE
        BEGIN
         --Get OtherParty_IDNO using fein and address.
         SET @Ls_Sql_TEXT = 'GET OtherParty_IDNO3';
         SET @Ls_Sqldata_TEXT = 'TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', City_ADDR = ' + ISNULL(@Lc_FilterCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_State_ADDR, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO
           FROM OTHP_Y1 o
          WHERE SUBSTRING(o.OtherParty_NAME, 1, 1) = @Lc_OtherParty2_NAME
            AND o.TypeOthp_CODE = @Lc_TypeOthp_CODE
            AND (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (o.Line1_ADDR, @Lc_RegNumeric_TEXT, ''), @Lc_Space_TEXT) = @Ls_Line1_ADDR)
            AND o.City_ADDR = @Lc_FilterCity_ADDR
            AND o.State_ADDR = @Lc_State_ADDR
            AND SUBSTRING(o.Zip_ADDR, 1, 5) = @Lc_ZipShort_ADDR
            AND o.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

         IF @Ln_Rowcount_QNTY = 0
          BEGIN
           SET @Lc_OthpExist_INDC = @Lc_No_INDC;
          END
         ELSE IF @Ln_Rowcount_QNTY > 1
          BEGIN
           SET @Ac_Msg_CODE = @Lc_ErrorE0145_CODE;
           SET @Ls_ErrorMessage_TEXT = 'TOO MANY OTHP RECORDS';

           RAISERROR (50001,16,1);
          END
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'GET OtherParty_IDNO1';
         SET @Ls_Sqldata_TEXT = 'Fein_IDNO = ' + ISNULL(CAST(@Ln_Fein_IDNO AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', City_ADDR = ' + ISNULL(@Lc_FilterCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_State_ADDR, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO
           FROM OTHP_Y1 o
          WHERE o.Fein_IDNO = @Ln_Fein_IDNO
            AND o.TypeOthp_CODE = @Lc_TypeOthp_CODE
            AND (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (o.Line1_ADDR, @Lc_RegNumeric_TEXT, ''), @Lc_Space_TEXT) = @Ls_Line1_ADDR)
            AND o.City_ADDR = @Lc_FilterCity_ADDR
            AND o.State_ADDR = @Lc_State_ADDR
            AND SUBSTRING(o.Zip_ADDR, 1, 5) = @Lc_ZipShort_ADDR
            AND o.EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

         IF @Ln_Rowcount_QNTY = 0
          BEGIN
           SET @Lc_OthpExist_INDC = @Lc_No_INDC;
          END
         ELSE IF @Ln_Rowcount_QNTY > 1
          BEGIN
           SET @Ls_Sql_TEXT = 'GET MIN OtherParty_IDNO';
           SET @Ls_Sqldata_TEXT = 'Fein_IDNO = ' + ISNULL(CAST(@Ln_Fein_IDNO AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', City_ADDR = ' + ISNULL(@Lc_FilterCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_State_ADDR, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

           SELECT @Ln_OtherParty_IDNO = MIN (o.OtherParty_IDNO)
             FROM OTHP_Y1 o
            WHERE o.Fein_IDNO = @Ln_Fein_IDNO
              AND o.TypeOthp_CODE = @Lc_TypeOthp_CODE
              AND (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (o.Line1_ADDR, @Lc_RegNumeric_TEXT, ''), @Lc_Space_TEXT) = @Ls_Line1_ADDR)
              AND o.City_ADDR = @Lc_FilterCity_ADDR
              AND o.State_ADDR = @Lc_State_ADDR
              AND SUBSTRING(o.Zip_ADDR, 1, 5) = @Lc_ZipShort_ADDR
              AND o.EndValidity_DATE = @Ld_High_DATE;
          END
        END

       IF @Lc_OthpExist_INDC = @Lc_No_INDC
          ---Check for OtherParty_IDNO name and address for spaces
          AND (ISNULL(LTRIM(RTRIM(@As_OtherParty_NAME)), @Lc_Space_TEXT) = @Lc_Space_TEXT
                OR (ISNULL(LTRIM(RTRIM(@Ls_FilterLine1_ADDR)), @Lc_Space_TEXT) = @Lc_Space_TEXT
                    AND ISNULL(LTRIM(RTRIM(@Ls_FilterLine2_ADDR)), @Lc_Space_TEXT) = @Lc_Space_TEXT)
                OR @Lc_FilterCity_ADDR = @Lc_Space_TEXT
                OR @Lc_State_ADDR = @Lc_Space_TEXT
                OR @Lc_Zip_ADDR = @Lc_Space_TEXT)
        BEGIN
         SET @Ac_Msg_CODE = @Lc_ErrorE0540_CODE;
         SET @Ls_ErrorMessage_TEXT = 'NOT ENOUGH MINIMUM DATA TO CREATE OTHP REC';

         RAISERROR (50001,16,1);
        END
       ELSE
        BEGIN
         IF @Lc_OthpExist_INDC = @Lc_No_INDC
            AND ((@Ln_OtherParty_IDNO = 0
                   OR @Ln_OtherParty_IDNO = 0)
                  OR (@Lc_TypeOthp_CODE = @Lc_TypeOthpI_CODE
                      AND @Ac_SourceLoc_CODE = @Lc_SourceInsurerMd_CODE)
                  OR (@Lc_TypeOthp_CODE IN (@Lc_TypeOthpI_CODE)
                      AND @Ac_SourceLoc_CODE = @Lc_SourceInsurerCsl_CODE))
          BEGIN
           ---If other party FEIN, Name and Address exists
           ---Insert record into OTHP_Y1.
           IF @Ln_OtherParty_IDNO = 0
               OR @Ln_OtherParty_IDNO IS NULL
            BEGIN
             ---Generate OtherParty_IDNO
             SET @Ls_Sql_TEXT = 'GENERATE ID_OTHP';
             SET @Ls_Sqldata_TEXT = '';

             BEGIN TRANSACTION Iothp;

             DELETE FROM IOTHP_Y1;

             SET @Ls_Sql_TEXT = 'INSERT INTO IOTHP_Y1';
             SET @Ls_Sqldata_TEXT = '';

             INSERT INTO IOTHP_Y1
                         (Entered_DATE)
                  VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()--Entered_DATE
             );

             SET @Ls_Sql_TEXT = 'SELECT TransactionEventSeq_NUMB FROM IOTHP_Y1';
             SET @Ls_Sqldata_TEXT = '';

             SELECT @Ln_TransactionEventSeq_NUMB = i.Seq_IDNO
               FROM IOTHP_Y1 i;

             COMMIT TRANSACTION Iothp;

             SET @Ln_OtherParty_IDNO = @Ln_TransactionEventSeq_NUMB;
            END

           SET @Ls_Sql_TEXT = 'GENERATE TransactionEventSeq_NUMB';
           SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', Process_ID = ' + ISNULL(@Ac_Process_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(0 AS VARCHAR), '');

           EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
            @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
            @Ac_Process_ID               = @Ac_Process_ID,
            @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
            @Ac_Note_INDC                = @Lc_No_INDC,
            @An_EventFunctionalSeq_NUMB  = 0,
            @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             SET @Ac_Msg_CODE = @Lc_Msg_CODE;

             RAISERROR (50001,16,1);
            END

           -- Inserting the address in UPPER case in OTHP_Y1 table
           -- Trimmed the address fields
           SET @Ls_Sql_TEXT = 'INSERT INTO OTHP_Y1';
           SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '') + ', TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', Line1_ADDR = ' + ISNULL(@Ls_FilterLine1_ADDR, '') + ', Line2_ADDR = ' + ISNULL(@Ls_FilterLine2_ADDR, '') + ', City_ADDR = ' + ISNULL(@Lc_FilterCity_ADDR, '') + ', Country_ADDR = ' + ISNULL(@Lc_Country_ADDR, '') + ', Phone_NUMB = ' + ISNULL(CAST(@An_Phone_NUMB AS VARCHAR), '') + ', Fax_NUMB = ' + ISNULL(CAST(@An_Fax_NUMB AS VARCHAR), '') + ', NewOtherParty_IDNO = ' + ISNULL(CAST(@Ln_NewOtherParty_IDNO AS VARCHAR), '') + ', Fein_IDNO = ' + ISNULL(CAST(@Ln_Fein_IDNO AS VARCHAR), '') + ', ParentFein_IDNO = ' + ISNULL(CAST(@Ln_ParentFein_IDNO AS VARCHAR), '') + ', InsuranceProvided_INDC = ' + ISNULL(@Lc_InsuranceProvided_INDC, '') + ', Nsf_INDC = ' + ISNULL(@Lc_Nsf_INDC, '') + ', Verified_INDC = ' + ISNULL(@Lc_Verified_INDC, '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', Enmsn_INDC = ' + ISNULL(@Lc_Enmsn_INDC, '') + ', NmsnGen_INDC = ' + ISNULL(@Lc_NmsnGen_INDC, '') + ', NmsnInst_INDC = ' + ISNULL(@Lc_NmsnInst_INDC, '') + ', Tribal_CODE = ' + ISNULL(@Lc_Tribal_CODE, '') + ', Tribal_INDC = ' + ISNULL(@Lc_Tribal_INDC, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', PpaEiwn_INDC = ' + ISNULL(@Lc_PpaEiwn_INDC, '') + ', SendShort_INDC = ' + ISNULL(@Lc_SendShort_INDC, '') + ', DescriptionNotes_TEXT = ' + ISNULL(@Ls_DescriptionNotes_TEXT, '') + ', EportalSubscription_INDC = ' + ISNULL('', '') + ', ReceivePaperForms_INDC = ' + ISNULL('Y', '');

           INSERT OTHP_Y1
                  (OtherParty_IDNO,
                   TypeOthp_CODE,
                   OtherParty_NAME,
                   Aka_NAME,
                   Attn_ADDR,
                   Line1_ADDR,
                   Line2_ADDR,
                   City_ADDR,
                   Zip_ADDR,
                   State_ADDR,
                   Fips_CODE,
                   Country_ADDR,
                   DescriptionContactOther_TEXT,
                   Phone_NUMB,
                   Fax_NUMB,
                   ReferenceOthp_IDNO,
                   NewOtherParty_IDNO,
                   Fein_IDNO,
                   Contact_EML,
                   ParentFein_IDNO,
                   InsuranceProvided_INDC,
                   BarAtty_NUMB,
                   Sein_IDNO,
                   County_IDNO,
                   DchCarrier_IDNO,
                   Nsf_INDC,
                   Verified_INDC,
                   Note_INDC,
                   Eiwn_INDC,
                   Enmsn_INDC,
                   NmsnGen_INDC,
                   NmsnInst_INDC,
                   Tribal_CODE,
                   Tribal_INDC,
                   BeginValidity_DATE,
                   EndValidity_DATE,
                   WorkerUpdate_ID,
                   TransactionEventSeq_NUMB,
                   Update_DTTM,
                   PpaEiwn_INDC,
                   Normalization_CODE,
                   SendShort_INDC,
                   DescriptionNotes_TEXT,
                   EportalSubscription_INDC,
                   ReceivePaperForms_INDC)
           VALUES ( @Ln_OtherParty_IDNO,--OtherParty_IDNO
                    @Lc_TypeOthp_CODE,--TypeOthp_CODE
                    UPPER(ISNULL(LTRIM(RTRIM(@As_OtherParty_NAME)), @Lc_Space_TEXT)),--OtherParty_NAME
                    UPPER(ISNULL(LTRIM(RTRIM(@Ac_Aka_NAME)), @Lc_Space_TEXT)),--Aka_NAME
                    UPPER(ISNULL(LTRIM(RTRIM(@Ac_Attn_ADDR)), @Lc_Space_TEXT)),--Attn_ADDR
                    UPPER( @Ls_FilterLine1_ADDR),--Line1_ADDR
                    UPPER(@Ls_FilterLine2_ADDR),--Line2_ADDR
                    UPPER(@Lc_FilterCity_ADDR),--City_ADDR
                    UPPER(ISNULL(LTRIM(RTRIM(@Lc_Zip_ADDR)), @Lc_Space_TEXT)),--Zip_ADDR
                    UPPER(ISNULL(LTRIM(RTRIM(@Lc_State_ADDR)), @Lc_Space_TEXT)),--State_ADDR
                    UPPER(ISNULL(LTRIM(RTRIM(@Ac_Fips_CODE)), @Lc_Space_TEXT)),--Fips_CODE
                    UPPER(@Lc_Country_ADDR),--Country_ADDR
                    ISNULL(LTRIM(RTRIM(@Ac_DescriptionContactOther_TEXT)), @Lc_Space_TEXT),--DescriptionContactOther_TEXT
                    @An_Phone_NUMB,--Phone_NUMB
                    @An_Fax_NUMB,--Fax_NUMB
                    ISNULL(@An_ReferenceOthp_IDNO, 0),--ReferenceOthp_IDNO
                    @Ln_NewOtherParty_IDNO,--NewOtherParty_IDNO
                    @Ln_Fein_IDNO,--Fein_IDNO
                    ISNULL (@As_Contact_EML, @Lc_Space_TEXT),--Contact_EML
                    @Ln_ParentFein_IDNO,--ParentFein_IDNO
                    ISNULL(LTRIM(RTRIM(@Lc_InsuranceProvided_INDC)), @Lc_Yes_INDC),--InsuranceProvided_INDC
                    ISNULL (@An_BarAtty_NUMB, 0),--BarAtty_NUMB
                    ISNULL (@An_Sein_IDNO, 0),--Sein_IDNO
                    ISNULL (@Ln_County_IDNO, 0),--County_IDNO
                    ISNULL (@An_DchCarrier_IDNO, 0),--DchCarrier_IDNO
                    @Lc_Nsf_INDC,--Nsf_INDC
                    @Lc_Verified_INDC,--Verified_INDC
                    @Lc_Note_INDC,--Note_INDC
                    -- Code Modified to insert "N"  as default value for Eiwn_CODE
                    CASE
                     WHEN ISNULL(LTRIM(RTRIM(@Lc_Eiwn_CODE)), @Lc_Space_TEXT) = @Lc_Space_TEXT
                      THEN @Lc_No_INDC
                     ELSE LTRIM(RTRIM(@Lc_Eiwn_CODE))
                    END,--Eiwn_INDC
                    @Lc_Enmsn_INDC,--Enmsn_INDC
                    @Lc_NmsnGen_INDC,--NmsnGen_INDC
                    @Lc_NmsnInst_INDC,--NmsnInst_INDC
                    @Lc_Tribal_CODE,--Tribal_CODE
                    @Lc_Tribal_INDC,--Tribal_INDC
                    @Ad_Run_DATE,--BeginValidity_DATE
                    @Ld_High_DATE,--EndValidity_DATE
                    @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
                    @Ln_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                    dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
                    @Lc_PpaEiwn_INDC,--PpaEiwn_INDC
                    ISNULL (@Ac_Normalization_CODE, @Lc_UnnormalizedU_INDC),--Normalization_CODE
                    @Lc_SendShort_INDC,--SendShort_INDC
                    @Ls_DescriptionNotes_TEXT,--DescriptionNotes_TEXT
                    @Lc_No_INDC,--EportalSubscription_INDC
                    @Lc_Yes_INDC ); --ReceivePaperForms_INDC

           SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

           IF @Ln_Rowcount_QNTY = 0
            BEGIN
             SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
             SET @Ls_ErrorMessage_TEXT = 'OTHP_Y1 INSERT FAILED';

             RAISERROR (50001,16,1);
            END

           SET @An_OtherParty_IDNO = @Ln_OtherParty_IDNO;
          END
        END

       SET @An_OtherParty_IDNO = @Ln_OtherParty_IDNO;
      END
     ELSE
     ---Other party type Attorney
     IF @Lc_TypeOthp_CODE = @Lc_TypeOthpA_CODE
      BEGIN
       BEGIN
        ---Get OtherParty_IDNO for Attorney
        --Removed NVL function from the where clause while matching name_other_party
        SET @Ls_Sql_TEXT = 'GET ID_OTHP FOR ATTORNEY';
        SET @Ls_Sqldata_TEXT = 'TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', City_ADDR = ' + ISNULL(@Lc_FilterCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_State_ADDR, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

        SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO
          FROM OTHP_Y1 o
         WHERE o.TypeOthp_CODE = @Lc_TypeOthp_CODE
           AND SUBSTRING(o.OtherParty_NAME, 1, 1) = @Lc_OtherParty2_NAME
           AND o.Phone_NUMB = CASE
                               WHEN @An_Phone_NUMB = 0
                                THEN o.Phone_NUMB
                               ELSE @An_Phone_NUMB
                              END
           AND (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (o.Line1_ADDR, @Lc_RegNumeric_TEXT, ''), @Lc_Space_TEXT) = @Ls_Line1_ADDR)
           AND o.City_ADDR = @Lc_FilterCity_ADDR
           AND o.State_ADDR = @Lc_State_ADDR
           AND SUBSTRING(o.Zip_ADDR, 1, 5) = @Lc_ZipShort_ADDR
           AND o.EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        IF @Ln_Rowcount_QNTY = 0
         BEGIN
          SET @Ac_Msg_CODE = @Lc_ErrorE0540_CODE;
          SET @Ls_ErrorMessage_TEXT = 'RECORD NOT FOUND IN OTHP1';

          RAISERROR (50001,16,1);
         END
        ELSE IF @Ln_Rowcount_QNTY > 1
         BEGIN
          SET @Ac_Msg_CODE = @Lc_ErrorE0145_CODE;
          SET @Ls_ErrorMessage_TEXT = 'TOO MANY OTHP RECORDS';

          RAISERROR (50001,16,1);
         END
       END

       SET @An_OtherParty_IDNO = @Ln_OtherParty_IDNO;
      END
     ELSE
      BEGIN
       BEGIN
        SET @Ls_Sql_TEXT = 'GET OtherParty_IDNO2';
        SET @Ls_Sqldata_TEXT = 'TypeOthp_CODE = ' + ISNULL(@Lc_TypeOthp_CODE, '') + ', City_ADDR = ' + ISNULL(@Lc_FilterCity_ADDR, '') + ', State_ADDR = ' + ISNULL(@Lc_State_ADDR, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

        SELECT @Ln_OtherParty_IDNO = o.OtherParty_IDNO
          FROM OTHP_Y1 o
         WHERE o.TypeOthp_CODE = @Lc_TypeOthp_CODE
           AND SUBSTRING(o.OtherParty_NAME, 1, 1) = @Lc_OtherParty2_NAME
           AND (ISNULL (dbo.BATCH_COMMON_SCALAR$SF_REGEX_REPLACE (o.Line1_ADDR, @Lc_RegNumeric_TEXT, ''), @Lc_Space_TEXT) = @Ls_Line1_ADDR)
           AND o.City_ADDR = @Lc_FilterCity_ADDR
           AND o.State_ADDR = @Lc_State_ADDR
           AND SUBSTRING(o.Zip_ADDR, 1, 5) = @Lc_ZipShort_ADDR
           AND o.EndValidity_DATE = @Ld_High_DATE;

        SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

        IF @Ln_Rowcount_QNTY = 0
         BEGIN
          SET @Ac_Msg_CODE = @Lc_ErrorE0540_CODE;
          SET @Ls_ErrorMessage_TEXT = 'RECORD NOT FOUND IN OTHP';

          RAISERROR (50001,16,1);
         END
        ELSE IF @Ln_Rowcount_QNTY > 1
         BEGIN
          SET @Ac_Msg_CODE = @Lc_ErrorE0145_CODE;
          SET @Ls_ErrorMessage_TEXT = 'TOO MANY OTHP RECORDS';

          RAISERROR (50001,16,1);
         END
       END

       SET @An_OtherParty_IDNO = @Ln_OtherParty_IDNO;
      END

     SET @An_OtherParty_IDNO = @Ln_OtherParty_IDNO;
    END
   ELSE
    BEGIN
     SET @An_OtherParty_IDNO = 0;
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @Ls_ErrorMessage_TEXT = 'INVALID OTHER PARTY TYPE';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @An_OtherParty_IDNO = 0;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
