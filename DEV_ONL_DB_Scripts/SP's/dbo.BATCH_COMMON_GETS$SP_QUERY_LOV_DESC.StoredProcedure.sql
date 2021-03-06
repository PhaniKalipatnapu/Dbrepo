/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_GETS$SP_QUERY_LOV_DESC]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_GETS$SP_QUERY_LOV_DESC
Programmer Name		: IMP Team
Description			: Retrieve Description text based on the input
Frequency			: 
Developed On		: 04/12/2011
Called By			: NONE
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_GETS$SP_QUERY_LOV_DESC]
 @Ac_TypeLov_TEXT          CHAR(15),
 @Ac_Value_CODE            CHAR(5),
 @Ac_Table_ID              CHAR(4),
 @Ac_TableSub_ID           CHAR(4),
 @As_DescriptionValue_TEXT VARCHAR(70) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT               CHAR = ' ',
          @Lc_StatusSuccess_CODE       CHAR = 'S',
          @Lc_StatusNoDataFound_CODE   CHAR = 'N',
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_HyphenWithSpace_TEXT     CHAR(3) = ' - ',
          @Lc_TypeAddressState_CODE    CHAR(3) = 'STA',
          @Lc_TypeAddressLocate_CODE   CHAR(3) = 'LOC',
          @Lc_SubTypeAddressSdu_CODE   CHAR(3) = 'SDU',
          @Lc_TypeAddressInt_IDNO      CHAR(3) = 'INT',
          @Lc_SubTypeAddressFrc_CODE   CHAR(3) = 'FRC',
          @Lc_Fips_CODE                CHAR(7) = '00000',
          @Lc_Job_ID                   CHAR(7) = 'JOB_ID',
          @Lc_EditLovRefm_TEXT         CHAR(10) = 'REFM',
          @Lc_EditLovCounty_TEXT       CHAR(10) = 'COUNTY',
          @Lc_EditLovWorker_TEXT       CHAR(10) = 'WORKER',
          @Lc_EditLovOfic_TEXT         CHAR(10) = 'OFIC',
          @Lc_EditLovRole_TEXT         CHAR(10) = 'ROLE',
          @Lc_EditLovAmnr_TEXT         CHAR(10) = 'AMNR',
          @Lc_EditLovAmjr_TEXT         CHAR(10) = 'AMJR',
          @Lc_EditLovOthp_TEXT         CHAR(10) = 'OTHP',
          @Lc_EditLovArole_TEXT        CHAR(10) = 'AROLE',
          @Lc_EditLovResf_TEXT         CHAR(10) = 'RESF',
          @Lc_EditLovNotice_TEXT       CHAR(10) = 'NOTICE',
          @Lc_EditLovFips7_CODE        CHAR(10) = 'FIPS7',
          @Lc_TypeAddressCrg_CODE      CHAR(10) = 'CRG',
          @Lc_TypeAddressCo1_CODE      CHAR(10) = 'C01',
          @Lc_EditLovFipsCnty_CODE     CHAR(10) = 'FIPS_CNTY',
          @Lc_TypeAddressIvd_CODE      CHAR(10) = 'IVD',
          @Lc_InitiateUcatManual_TEXT  CHAR(10) = 'MANUAL',
          @Lc_EditLovStfipsStat_TEXT   CHAR(12) = 'STFIPS_STAT',
          @Lc_EditLovStfipsFips_TEXT   CHAR(12) = 'STFIPS_FIPS',
          @Lc_EditLovWorkerRefm_TEXT   CHAR(15) = 'WORKER_REFM',
          @Lc_EditLovFipsCntyOfic_CODE CHAR(15) = 'FIPS_CNTY_OFIC',
          @Lc_ManualUdc_TEXT           CHAR(15) = 'MANUAL_UDC',
          @Lc_FipsSdu_CODE             CHAR(15) = 'FIPS7_SDU',
          @Ls_Procedure_NAME           VARCHAR(100) = 'BATCH_COMMON_GETS$SP_QUERY_LOV_DESC',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_County_IDNO           NUMERIC = 0, 
		  @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Empty_TEXT            CHAR = '',
          @Ls_DescriptionValue_TEXT VARCHAR(70) = '',
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '',
          @Ls_Sqldata_TEXT          VARCHAR(4000) = '';

  BEGIN TRY
   SET @As_DescriptionValue_TEXT = '';
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   IF (@Ac_TypeLov_TEXT = @Lc_EditLovRefm_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT REFM_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Table_ID = ' + ISNULL(@Ac_Table_ID, '') + ', TableSub_ID = ' + ISNULL(@Ac_TableSub_ID, '') + ', Value_CODE = ' + ISNULL(@Ac_Value_CODE, '');

     SELECT @Ls_DescriptionValue_TEXT = a.DescriptionValue_TEXT
       FROM REFM_Y1 a
      WHERE a.Table_ID = @Ac_Table_ID
        AND a.TableSub_ID = @Ac_TableSub_ID
        AND a.Value_CODE = @Ac_Value_CODE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovCounty_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT COPT_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'County_IDNO = ' + ISNULL(@Ac_Value_CODE, '');

     SELECT @Ls_DescriptionValue_TEXT = c.County_NAME
       FROM COPT_Y1 c
      WHERE c.County_IDNO = @Ac_Value_CODE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovWorker_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT USEM_Y1 TABLE - 1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_Value_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = ISNULL(RTRIM(u.Last_NAME), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(RTRIM(u.Suffix_NAME), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(RTRIM(u.First_NAME), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(RTRIM(u.Middle_NAME), '')
       FROM USEM_Y1 u
      WHERE u.Worker_ID = @Ac_Value_CODE
        AND u.EndEmployment_DATE >= dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
        AND u.BeginEmployment_DATE <= dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
        AND u.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovWorkerRefm_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT USEM_Y1 TABLE - 2';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_Value_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Table_ID = ' + ISNULL(@Ac_Table_ID, '') + ', TableSub_ID = ' + ISNULL(@Ac_TableSub_ID, '');

     SELECT @Ls_DescriptionValue_TEXT = ISNULL(RTRIM(a.Last_NAME), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(RTRIM(a.Suffix_NAME), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(RTRIM(a.First_NAME), '') + ISNULL(@Lc_Space_TEXT, '') + ISNULL(RTRIM(a.Middle_NAME), '')
       FROM USEM_Y1 a
      WHERE a.Worker_ID = @Ac_Value_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND a.EndEmployment_DATE >= dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
        AND a.BeginEmployment_DATE <= dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
        AND EXISTS (SELECT b.Worker_ID
                      FROM USRL_Y1 b
                     WHERE a.Worker_ID = b.Worker_ID
                       AND b.Expire_DATE >= dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
                       AND b.Effective_DATE <= dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
                       AND b.EndValidity_DATE = @Ld_High_DATE
                       AND b.Role_ID IN (SELECT r.Value_CODE
                                           FROM REFM_Y1 r
                                          WHERE r.Table_ID = @Ac_Table_ID
                                            AND r.TableSub_ID = @Ac_TableSub_ID));
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovOfic_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT OFIC_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(@Ac_Value_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = o.Office_NAME
       FROM OFIC_Y1 o
      WHERE o.Office_IDNO = @Ac_Value_CODE
        AND o.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovRole_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT ROLE_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Role_ID = ' + ISNULL(@Ac_Value_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = r.Role_NAME
       FROM ROLE_Y1 r
      WHERE r.Role_ID = @Ac_Value_CODE
        AND r.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovAmnr_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT AMNR_Y1 TABLE - 1';
     SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Ac_Value_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = a.DescriptionActivity_TEXT
       FROM AMNR_Y1 a
      WHERE a.ActivityMinor_CODE = @Ac_Value_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovAmjr_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT AMJR_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Ac_Value_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = a.DescriptionActivity_TEXT
       FROM AMJR_Y1 a
      WHERE a.ActivityMajor_CODE = @Ac_Value_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovOthp_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(@Ac_Value_CODE, '') + ', TypeOthp_CODE = ' + ISNULL(@Ac_Table_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = o.OtherParty_NAME
       FROM OTHP_Y1 o
      WHERE o.OtherParty_IDNO = @Ac_Value_CODE
        AND (@Ac_Table_ID IS NULL
              OR (@Ac_Table_ID IS NOT NULL
                  AND o.TypeOthp_CODE = @Ac_Table_ID))
        AND o.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovArole_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT AMNR_Y1 TABLE - 2';
     SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE = ' + ISNULL(@Ac_Value_CODE, '') + ', Category_CODE = ' + ISNULL(@Ac_Table_ID, '') + ', SubCategory_CODE = ' + ISNULL(@Ac_TableSub_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = b.DescriptionActivity_TEXT
       FROM AMNR_Y1 b
      WHERE b.ActivityMinor_CODE = @Ac_Value_CODE
        AND EXISTS (SELECT 1
                      FROM ACRL_Y1 a
                     WHERE a.Category_CODE = @Ac_Table_ID
                       AND a.SubCategory_CODE = @Ac_TableSub_ID
                       AND a.ActivityMinor_CODE = b.ActivityMinor_CODE
                       AND a.EndValidity_DATE = @Ld_High_DATE)
        AND b.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovResf_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT RESF_Y1 , REFM_Y1 TABLES';
     SET @Ls_Sqldata_TEXT = 'Process_ID = ' + ISNULL(@Ac_Table_ID, '') + ', Type_CODE = ' + ISNULL(@Ac_TableSub_ID, '') + ', Reason_CODE = ' + ISNULL(@Ac_Value_CODE, '');

     SELECT @Ls_DescriptionValue_TEXT = b.DescriptionValue_TEXT
       FROM RESF_Y1 a,
            REFM_Y1 b
      WHERE a.Process_ID = @Ac_Table_ID
        AND a.Type_CODE = @Ac_TableSub_ID
        AND a.Reason_CODE = @Ac_Value_CODE
        AND b.Table_ID = a.Table_ID
        AND b.TableSub_ID = a.TableSub_ID
        AND b.Value_CODE = a.Reason_CODE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovNotice_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT NREF_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Notice_ID = ' + ISNULL(@Ac_Value_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = n.DescriptionNotice_TEXT
       FROM NREF_Y1 n
      WHERE n.Notice_ID = @Ac_Value_CODE
        AND n.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovStfipsStat_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT STAT_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'StateFips_CODE = ' + ISNULL(@Ac_Value_CODE, '');

     SELECT @Ls_DescriptionValue_TEXT = s.State_NAME
       FROM STAT_Y1 s
      WHERE s.StateFips_CODE = @Ac_Value_CODE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovStfipsFips_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT STAT_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'StateFips_CODE = ' + ISNULL(@Ac_Value_CODE, '');

     SELECT @Ls_DescriptionValue_TEXT = s.State_NAME
       FROM STAT_Y1 s
      WHERE s.StateFips_CODE = @Ac_Value_CODE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovFips7_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT FIPS_Y1 TABLE - 1';
     SET @Ls_Sqldata_TEXT = 'Fips_CODE = ' + ISNULL(@Ac_Value_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressState_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressCrg_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressLocate_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressCo1_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressInt_IDNO, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddressFrc_CODE, '') + ', StateFips_CODE = ' + ISNULL(@Ac_Table_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = ISNULL(f.State_ADDR, '') + ISNULL(@Lc_HyphenWithSpace_TEXT, '') + ISNULL(f.Fips_NAME, '')
       FROM FIPS_Y1 f
      WHERE f.Fips_CODE = @Ac_Value_CODE
        AND ((dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR(@Ac_Value_CODE, 3, 7) = @Lc_Fips_CODE
              AND f.TypeAddress_CODE = @Lc_TypeAddressState_CODE
              AND f.SubTypeAddress_CODE = @Lc_TypeAddressCrg_CODE)
              OR (dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR(@Ac_Value_CODE, 3, 7) <> @Lc_Fips_CODE
                  AND f.TypeAddress_CODE = @Lc_TypeAddressLocate_CODE
                  AND f.SubTypeAddress_CODE = @Lc_TypeAddressCo1_CODE)
              OR (f.TypeAddress_CODE = @Lc_TypeAddressInt_IDNO
                  AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE))
        AND (@Ac_Table_ID IS NULL
              OR (@Ac_Table_ID IS NOT NULL
                  AND f.StateFips_CODE = @Ac_Table_ID))
        AND f.BeginValidity_DATE <= dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())
        AND f.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovFipsCnty_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT FIPS_Y1 TABLE - 2';
     SET @Ls_Sqldata_TEXT = 'StateFips_CODE = ' + ISNULL(@Ac_Table_ID, '') + ', CountyFips_CODE = ' + ISNULL(@Ac_Value_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressState_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressIvd_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressLocate_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressCo1_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressInt_IDNO, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddressFrc_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT TOP 1 @Ls_DescriptionValue_TEXT = f.Fips_NAME
       FROM FIPS_Y1 f
      WHERE f.StateFips_CODE = @Ac_Table_ID
        AND f.CountyFips_CODE = @Ac_Value_CODE
        AND ((@Ac_Value_CODE = @Ln_County_IDNO
              AND f.TypeAddress_CODE = @Lc_TypeAddressState_CODE
              AND f.SubTypeAddress_CODE = @Lc_TypeAddressIvd_CODE)
              OR (@Ac_Value_CODE <> @Ln_County_IDNO
                  AND f.TypeAddress_CODE = @Lc_TypeAddressLocate_CODE
                  AND f.SubTypeAddress_CODE = @Lc_TypeAddressCo1_CODE)
              OR (f.TypeAddress_CODE = @Lc_TypeAddressInt_IDNO
                  AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE))
        AND f.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_EditLovFipsCntyOfic_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT FIPS_Y1 TABLE - 3';
     SET @Ls_Sqldata_TEXT = 'StateFips_CODE = ' + ISNULL(@Ac_Table_ID, '') + ', CountyFips_CODE = ' + ISNULL(@Ac_TableSub_ID, '') + ', OfficeFips_CODE = ' + ISNULL(@Ac_Value_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressState_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressCrg_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressLocate_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressCo1_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressInt_IDNO, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddressFrc_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = f.Fips_NAME
       FROM FIPS_Y1 f
      WHERE f.StateFips_CODE = @Ac_Table_ID
        AND f.CountyFips_CODE = @Ac_TableSub_ID
        AND f.OfficeFips_CODE = @Ac_Value_CODE
        AND ((@Ac_TableSub_ID = @Ln_County_IDNO
              AND f.TypeAddress_CODE = @Lc_TypeAddressState_CODE
              AND f.SubTypeAddress_CODE = @Lc_TypeAddressCrg_CODE)
              OR (@Ac_TableSub_ID <> @Ln_County_IDNO
                  AND f.TypeAddress_CODE = @Lc_TypeAddressLocate_CODE
                  AND f.SubTypeAddress_CODE = @Lc_TypeAddressCo1_CODE)
              OR (f.TypeAddress_CODE = @Lc_TypeAddressInt_IDNO
                  AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE))
        AND f.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_Job_ID)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT PARM_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Value_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = p.DescriptionJob_TEXT
       FROM PARM_Y1 p
      WHERE p.Job_ID = @Ac_Value_CODE
        AND p.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE IF (@Ac_TypeLov_TEXT = @Lc_ManualUdc_TEXT)
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT UCAT_Y1 TABLE';
     SET @Ls_Sqldata_TEXT = 'Udc_CODE = ' + ISNULL(@Ac_Value_CODE, '') + ', HoldLevel_CODE = ' + ISNULL(@Ac_Table_ID, '') + ', Initiate_CODE = ' + ISNULL(@Lc_InitiateUcatManual_TEXT, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

     SELECT @Ls_DescriptionValue_TEXT = (SELECT b.DescriptionValue_TEXT
                                           FROM REFM_Y1 b
                                          WHERE b.Table_ID = a.Table_ID
                                            AND b.TableSub_ID = a.TableSub_ID
                                            AND b.Value_CODE = a.Udc_CODE)
       FROM UCAT_Y1 a
      WHERE a.Udc_CODE = @Ac_Value_CODE
        AND (@Ac_Table_ID IS NULL
              OR a.HoldLevel_CODE = @Ac_Table_ID)
        AND a.Initiate_CODE = @Lc_InitiateUcatManual_TEXT
        AND a.EndValidity_DATE = @Ld_High_DATE;
    END
   ELSE
    BEGIN
     IF (@Ac_TypeLov_TEXT = @Lc_FipsSdu_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT FIPS_Y1 TABLE - 4';
       SET @Ls_Sqldata_TEXT = 'Fips_CODE = ' + ISNULL(@Ac_Value_CODE, '') + ', TypeAddress_CODE = ' + ISNULL(@Lc_TypeAddressState_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddressSdu_CODE, '') + ', StateFips_CODE = ' + ISNULL(@Ac_Table_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       SELECT @Ls_DescriptionValue_TEXT = ISNULL(f.State_ADDR, '') + ISNULL(@Lc_HyphenWithSpace_TEXT, '') + ISNULL(f.Fips_NAME, '')
         FROM FIPS_Y1 f
        WHERE f.Fips_CODE = @Ac_Value_CODE
          AND (dbo.BATCH_COMMON_SCALAR$SF_SUBSTR3_VARCHAR(@Ac_Value_CODE, 3, 7) = @Lc_Fips_CODE
               AND f.TypeAddress_CODE = @Lc_TypeAddressState_CODE
               AND f.SubTypeAddress_CODE = @Lc_SubTypeAddressSdu_CODE)
          AND (@Ac_Table_ID IS NULL
                OR (@Ac_Table_ID IS NOT NULL
                    AND f.StateFips_CODE = @Ac_Table_ID))
          AND f.EndValidity_DATE = @Ld_High_DATE;
      END
    END

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;
   SET @As_DescriptionValue_TEXT = @Ls_DescriptionValue_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;
     SET @As_DescriptionError_TEXT = '';
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

  END CATCH
 END;


GO
