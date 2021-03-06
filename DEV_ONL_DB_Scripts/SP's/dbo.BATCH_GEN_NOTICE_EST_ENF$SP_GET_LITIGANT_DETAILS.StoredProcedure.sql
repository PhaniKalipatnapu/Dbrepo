/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS]
 @An_Case_IDNO             CHAR(6),
 @As_LitigantOption_TEXT   VARCHAR(MAX),
 @Ad_Run_DATE              DATE,
 @Ac_Notice_ID             CHAR(8) = NULL,
 @As_First_NAME            CHAR(16) OUTPUT,
 @As_Last_NAME             CHAR(20) OUTPUT,
 @As_Middle_NAME           CHAR(20) OUTPUT,
 @As_Litigant_IDNO         VARCHAR(MAX) OUTPUT,
 @Ac_CaseRelationship_CODE CHAR(1) OUTPUT,
 @As_ObligationStatus_CODE VARCHAR(MAX) OUTPUT,
 @Ac_Msg_CODE              VARCHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR OUTPUT
AS
 BEGIN
  DECLARE @Ld_High_DATE                      DATE = '12/31/9999',
          @Ls_CaseStatusOpen_CODE            CHAR(1) = 'O',
          @Ls_WelfareTypeTanf_CODE           CHAR(1) = 'A',
          @Ls_WelfareTypeNonIve_CODE         CHAR(1) = 'F',
          @Ls_WelfareTypeFosterCare_CODE     CHAR(1) = 'J',
          @Ls_WelfareTypeNonTanf_CODE        CHAR(1) = 'N',
          @Ls_RelationshipCaseCp_TEXT        CHAR(1) = 'C',
          @Ls_Space_TEXT                     CHAR = ' ',
          @Ls_RelationshipCaseNcp_TEXT       CHAR(1) = 'A',
          @Ls_RelationshipCasePutFather_TEXT CHAR(1) = 'P',
          @Ls_Null_TEXT                      CHAR = '',
          @Ls_StatusSuccess_CODE             CHAR = 'S',
          @Ls_StatusNoDataFound_CODE         CHAR = 'N',
          @Ls_DoubleSpace_TEXT               VARCHAR(2) = '  ',
          @Ls_StatusFailed_CODE              CHAR = 'F',
          @Ls_TypePartyP1_CODE               VARCHAR(3) = 'P',
          @Ls_TypePartyCpl_CODE              VARCHAR(3) = 'CPL',
          @Ls_TypePartyPl_CODE               VARCHAR(3) = 'PL',
          @Ls_TypePartyD1_CODE               VARCHAR(3) = 'D',
          @Ls_TypePartyCof_CODE              VARCHAR(3) = 'COF',
          @Ls_TypePartyDf_CODE               VARCHAR(3) = 'DF',
          @Ls_TableNotc_IDNO                 VARCHAR(4) = 'NOTC',
          @Ls_TableSubDckt_IDNO              VARCHAR(4) = 'DCKT',
          @Ls_NoticeCs_IDNO                  VARCHAR(2) = 'Cs_AMNT',
          @Ls_CaseCategoryMn_TEXT            VARCHAR(2) = 'MN',
          @Ls_RelationshipCaseE1_CODE        CHAR(1) = 'E',
          @Ls_TypePartyIp_CODE               VARCHAR(3) = 'IP',
          @Ls_TypeOthpO1_CODE                CHAR(1) = 'O',
          @Ls_ObligeeObo_TEXT                VARCHAR(3) = 'OBO',
          @Ls_RelationshipCaseO1_CODE        CHAR(1) = 'O',
          @Ls_MsgZ1_CODE                     CHAR(1) = 'Z',
          @Ln_OthpParty_IDNO                 NUMERIC(9),
          @Ls_Routine_TEXT                   VARCHAR(100),
          @Ls_Sql_TEXT                       VARCHAR(200),
          @Ls_Sqldata_TEXT                   VARCHAR(400),
          @Lc_File_ID                        CHAR(15),
          @Ls_Petitioner_NAME                VARCHAR(65),
          @Ls_Ip_NAME                        VARCHAR(60),
          @Ls_LitigantOption1_TEXT           VARCHAR(3),
          @Ls_LitigantOptn2_TEXT             VARCHAR(3),
          @Ln_Value_QNTY                     NUMERIC(5) = 0,
          @Lc_TypeCase_CODE                  CHAR(1),
          @Ln_CwaCpl_QNTY                    NUMERIC(5) = 0,
          @Lc_CaseCategory_CODE              CHAR(2),
          @Lc_StatusFailed_CODE              VARCHAR(1) = 'F'

  BEGIN TRY
   SET @As_First_NAME = NULL;
   SET @As_Last_NAME = NULL;
   SET @As_Middle_NAME = NULL;
   SET @As_Litigant_IDNO = NULL;
   SET @Ac_CaseRelationship_CODE = NULL;
   SET @As_ObligationStatus_CODE = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_EST_ENF.BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS ';

   IF @As_LitigantOption_TEXT = @Ls_TypePartyP1_CODE
    BEGIN
     SET @Ls_LitigantOption1_TEXT = @Ls_TypePartyCpl_CODE;
     SET @Ls_LitigantOptn2_TEXT = @Ls_TypePartyPl_CODE;
    END
   ELSE
    BEGIN
     IF @As_LitigantOption_TEXT = @Ls_TypePartyD1_CODE
      BEGIN
       SET @Ls_LitigantOption1_TEXT = @Ls_TypePartyCof_CODE;
       SET @Ls_LitigantOptn2_TEXT = @Ls_TypePartyDf_CODE;
      END
    END

   SELECT @Ln_Value_QNTY = COUNT(*)
     FROM REFM_Y1
    WHERE REFM_Y1.Table_ID = @Ls_TableNotc_IDNO
      AND REFM_Y1.TableSub_ID = @Ls_TableSubDckt_IDNO
      AND ISNULL(@Ls_NoticeCs_IDNO, '') + ISNULL(REFM_Y1.Value_CODE, '') = @Ac_Notice_ID;

   IF @Ln_Value_QNTY = 0
       OR @Ac_Notice_ID IS NULL
    BEGIN--B2
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '');
     SET @Ls_Sql_TEXT = 'SELECT_VCASE_VDPRS';

     SELECT TOP 1 @Lc_File_ID = c.File_ID,
                  @As_Litigant_IDNO = p.DocketPerson_IDNO,
                  @Ls_Petitioner_NAME = p.File_NAME
       FROM DPRS_Y1 AS p,
            CASE_Y1 AS c
      WHERE c.Case_IDNO = @An_Case_IDNO
        AND c.File_ID = p.File_ID
        AND SUBSTRING(p.TypePerson_CODE, 1, 2) = @Ls_LitigantOptn2_TEXT
        AND p.EndValidity_DATE = @Ld_High_DATE
        AND p.EffectiveEnd_DATE = @Ld_High_DATE
        AND c.StatusCase_CODE = @Ls_CaseStatusOpen_CODE;

     SET @Ls_Sql_TEXT = 'SELECT_VCASE';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

     SELECT @Lc_TypeCase_CODE = CASE_Y1.TypeCase_CODE,
            @Lc_CaseCategory_CODE = CASE_Y1.CaseCategory_CODE
       FROM CASE_Y1
      WHERE CASE_Y1.Case_IDNO = @An_Case_IDNO
        AND CASE_Y1.StatusCase_CODE = @Ls_CaseStatusOpen_CODE;

     IF @Lc_TypeCase_CODE IN (@Ls_WelfareTypeTanf_CODE, @Ls_WelfareTypeNonIve_CODE, @Ls_WelfareTypeFosterCare_CODE)
      BEGIN
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '');
       SET @Ls_Sql_TEXT = 'SELECT_VCASE_VDPRS3'

       SELECT @Ln_CwaCpl_QNTY = COUNT(1)
         FROM DPRS_Y1 AS p,
              CASE_Y1 AS c
        WHERE c.Case_IDNO = @An_Case_IDNO
          AND c.File_ID = p.File_ID
          AND SUBSTRING(p.TypePerson_CODE, 1, 3) = @Ls_LitigantOption1_TEXT
          AND p.EndValidity_DATE = @Ld_High_DATE
          AND p.EffectiveEnd_DATE = @Ld_High_DATE
          AND c.StatusCase_CODE = @Ls_CaseStatusOpen_CODE
          AND LEN(LTRIM(RTRIM(p.DocketPerson_IDNO))) = 9

       IF @Ln_CwaCpl_QNTY > 0
        BEGIN
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '');
         SET @Ls_Sql_TEXT = 'SELECT_VCASE_VDPRS4';

         SELECT TOP 1 @Lc_File_ID = c.File_ID,
                      @As_Litigant_IDNO = p.DocketPerson_IDNO,
                      @Ls_Petitioner_NAME = p.File_NAME
           FROM DPRS_Y1 AS p,
                CASE_Y1 AS c
          WHERE c.Case_IDNO = @An_Case_IDNO
            AND c.File_ID = p.File_ID
            AND SUBSTRING(p.TypePerson_CODE, 1, 3) = @Ls_LitigantOption1_TEXT
            AND p.EndValidity_DATE = @Ld_High_DATE
            AND p.EffectiveEnd_DATE = @Ld_High_DATE
            AND c.StatusCase_CODE = @Ls_CaseStatusOpen_CODE
            AND LEN(LTRIM(RTRIM(p.DocketPerson_IDNO))) = 9;
        END
      END

     
     IF (LEN(@As_Litigant_IDNO) = 9
          OR @Ln_CwaCpl_QNTY > 0)
        AND (@Ls_LitigantOption1_TEXT = @Ls_TypePartyCpl_CODE
              OR @Ls_LitigantOptn2_TEXT = @Ls_TypePartyPl_CODE)
      BEGIN--B3
       IF (@Lc_TypeCase_CODE IN (@Ls_WelfareTypeTanf_CODE, @Ls_WelfareTypeNonIve_CODE, @Ls_WelfareTypeFosterCare_CODE)
            OR (@Lc_TypeCase_CODE = @Ls_WelfareTypeNonTanf_CODE
                AND @Lc_CaseCategory_CODE = @Ls_CaseCategoryMn_TEXT))
        BEGIN --B4
         SET @Ac_CaseRelationship_CODE = @Ls_RelationshipCaseCp_TEXT;
         SET @As_ObligationStatus_CODE = @Ls_RelationshipCaseE1_CODE;
         SET @As_First_NAME = NULL;
         SET @As_Middle_NAME = NULL;
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '');
         SET @Ls_Sql_TEXT = 'SELECT_VCMEM_VDPRS1';

         SELECT @Ls_Ip_NAME = CASE
                               WHEN LTRIM(RTRIM(p.File_NAME)) IS NULL
                                THEN (SELECT ISNULL(DEMO_Y1.Last_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.First_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.Middle_NAME, '') AS expr
                                        FROM DEMO_Y1
                                       WHERE DEMO_Y1.MemberMci_IDNO = c.MemberMci_IDNO)
                               ELSE p.File_NAME
                              END
           FROM DPRS_Y1 AS p,
                CMEM_Y1 AS c
          WHERE p.File_ID = @Lc_File_ID
            AND c.Case_IDNO = @An_Case_IDNO
            AND c.MemberMci_IDNO = p.DocketPerson_IDNO
            AND c.CaseRelationship_CODE = @Ls_RelationshipCaseCp_TEXT
            AND p.TypePerson_CODE = @Ls_TypePartyIp_CODE
            AND p.EndValidity_DATE = @Ld_High_DATE
            AND p.EffectiveEnd_DATE = @Ld_High_DATE;

         IF(@@ROWCOUNT = 0)
          BEGIN --B5
           SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '')
           SET @Ls_Sql_TEXT = 'SELECT_VCMEM_VDPRS2';

           SELECT @Ls_Ip_NAME = CASE
                                 WHEN LTRIM(RTRIM(P.File_NAME)) IS NULL
                                  THEN (SELECT ISNULL(Last_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(First_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(Middle_NAME, '') AS expr
                                          FROM DEMO_Y1
                                         WHERE DEMO_Y1.MemberMci_IDNO = c.MemberMci_IDNO)
                                 ELSE p.File_NAME
                                END
             FROM DPRS_Y1 AS p,
                  CMEM_Y1 AS c
            WHERE p.File_ID = @Lc_File_ID
              AND c.Case_IDNO = @An_Case_IDNO
              AND c.MemberMci_IDNO = p.DocketPerson_IDNO
              AND c.CaseRelationship_CODE IN (@Ls_RelationshipCaseCp_TEXT, @Ls_RelationshipCaseNcp_TEXT)
              AND p.TypePerson_CODE = @Ls_TypePartyCpl_CODE
              AND p.EndValidity_DATE = @Ld_High_DATE
              AND p.EffectiveEnd_DATE = @Ld_High_DATE;
          END--B5

         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '');
         SET @Ls_Sql_TEXT = 'SELECT_VOTHP';

         SELECT @Ls_Petitioner_NAME = OTHP_Y1.OtherParty_NAME
           FROM OTHP_Y1
          WHERE OTHP_Y1.OtherParty_IDNO = @As_Litigant_IDNO
            AND OTHP_Y1.TypeOthp_CODE = @Ls_TypeOthpO1_CODE
            AND OTHP_Y1.EndValidity_DATE = @Ld_High_DATE;

         SELECT @As_Last_NAME = SUBSTRING(ISNULL(@Ls_Petitioner_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(@Ls_ObligeeObo_TEXT, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(@Ls_Ip_NAME, ''), 1, 99);
        END--B4
       ELSE
        BEGIN--B6
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '');
         SET @Ls_Sql_TEXT = 'SELECT_VCASE_VDPRS_VCMEM_2 ';

         SELECT @Ac_CaseRelationship_CODE = c.CaseRelationship_CODE,
                @As_ObligationStatus_CODE = CASE c.CaseRelationship_CODE
                                             WHEN @Ls_RelationshipCaseNcp_TEXT
                                              THEN @Ls_RelationshipCaseO1_CODE
                                             WHEN @Ls_RelationshipCasePutFather_TEXT
                                              THEN @Ls_RelationshipCaseO1_CODE
                                             WHEN @Ls_RelationshipCaseCp_TEXT
                                              THEN @Ls_RelationshipCaseE1_CODE
                                            END,
                @As_Last_NAME = CASE
                                 WHEN dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR(p.File_NAME) IS NULL
                                  THEN (SELECT ISNULL(DEMO_Y1.Last_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.First_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.Middle_NAME, '') AS expr
                                          FROM DEMO_Y1
                                         WHERE DEMO_Y1.MemberMci_IDNO = c.MemberMci_IDNO)
                                 ELSE p.File_NAME
                                END,
                @As_First_NAME = @Ls_Null_TEXT,
                @As_Middle_NAME = @Ls_Null_TEXT,
                @As_Litigant_IDNO = p.DocketPerson_IDNO
           FROM CASE_Y1 AS s,
                DPRS_Y1 AS p,
                CMEM_Y1 AS c
          WHERE s.Case_IDNO = @An_Case_IDNO
            AND s.StatusCase_CODE = @Ls_CaseStatusOpen_CODE
            AND s.File_ID = p.File_ID
            AND p.EndValidity_DATE = @Ld_High_DATE
            AND p.EffectiveEnd_DATE = @Ld_High_DATE
            AND p.TypePerson_CODE IN (@Ls_LitigantOption1_TEXT, @Ls_LitigantOptn2_TEXT)
            AND p.EffectiveEnd_DATE = @Ld_High_DATE
            AND s.Case_IDNO = c.Case_IDNO
            AND c.CaseRelationship_CODE IN (@Ls_RelationshipCaseNcp_TEXT, @Ls_RelationshipCaseCp_TEXT, @Ls_RelationshipCasePutFather_TEXT)
            AND p.DocketPerson_IDNO = c.MemberMci_IDNO;
        END--B6
      END-- --B4 IF ENDS
     ELSE --B3 ELSE FOR IF
      BEGIN --B7
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '');
       SET @Ls_Sql_TEXT = 'SELECT_VCASE_VDPRS_VCMEM_3 ';

       SELECT @Ac_CaseRelationship_CODE = c.CaseRelationship_CODE,
              @As_ObligationStatus_CODE = CASE c.CaseRelationship_CODE
                                           WHEN @Ls_RelationshipCaseNcp_TEXT
                                            THEN @Ls_RelationshipCaseO1_CODE
                                           WHEN @Ls_RelationshipCasePutFather_TEXT
                                            THEN @Ls_RelationshipCaseO1_CODE
                                           WHEN @Ls_RelationshipCaseCp_TEXT
                                            THEN @Ls_RelationshipCaseE1_CODE
                                          END,
              @As_Last_NAME = CASE
                               WHEN LTRIM(RTRIM(p.File_NAME)) IS NULL
                                THEN (SELECT ISNULL(DEMO_Y1.Last_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.First_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.Middle_NAME, '') AS expr
                                        FROM DEMO_Y1
                                       WHERE DEMO_Y1.MemberMci_IDNO = c.MemberMci_IDNO)
                               ELSE p.File_NAME
                              END,
              @As_First_NAME = @Ls_Null_TEXT,
              @As_Middle_NAME = @Ls_Null_TEXT,
              @As_Litigant_IDNO = p.DocketPerson_IDNO
         FROM CASE_Y1 AS s,
              DPRS_Y1 AS p,
              CMEM_Y1 AS c
        WHERE s.Case_IDNO = @An_Case_IDNO
          AND s.StatusCase_CODE = @Ls_CaseStatusOpen_CODE
          AND s.File_ID = p.File_ID
          AND p.EndValidity_DATE = @Ld_High_DATE
          AND p.EffectiveEnd_DATE = @Ld_High_DATE
          AND p.TypePerson_CODE IN (@Ls_LitigantOption1_TEXT, @Ls_LitigantOptn2_TEXT)
          AND p.EffectiveEnd_DATE = @Ld_High_DATE
          AND s.Case_IDNO = c.Case_IDNO
          AND c.CaseRelationship_CODE IN (@Ls_RelationshipCaseNcp_TEXT, @Ls_RelationshipCaseCp_TEXT, @Ls_RelationshipCasePutFather_TEXT)
          AND p.DocketPerson_IDNO = c.MemberMci_IDNO

       IF(@@ROWCOUNT = 0)
        BEGIN --B8
         SET @Ls_Sql_TEXT = 'SELECT_VCASE';
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

         SELECT @Lc_TypeCase_CODE = CASE_Y1.TypeCase_CODE
           FROM CASE_Y1
          WHERE CASE_Y1.Case_IDNO = @An_Case_IDNO
            AND CASE_Y1.StatusCase_CODE = @Ls_CaseStatusOpen_CODE

         IF @Lc_TypeCase_CODE IN (@Ls_WelfareTypeTanf_CODE, @Ls_WelfareTypeNonIve_CODE, @Ls_WelfareTypeFosterCare_CODE)
            AND (@Ls_LitigantOption1_TEXT = @Ls_TypePartyCpl_CODE
                  OR @Ls_LitigantOptn2_TEXT = @Ls_TypePartyPl_CODE)
          BEGIN --B9
           SET @Ac_CaseRelationship_CODE = @Ls_RelationshipCaseCp_TEXT;
           SET @As_ObligationStatus_CODE = @Ls_RelationshipCaseE1_CODE;
           SET @As_First_NAME = NULL;
           SET @As_Middle_NAME = NULL;
           SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '');
           SET @Ls_Sql_TEXT = 'SELECT_VCMEM_VDPRS1';

           SELECT @Ls_Ip_NAME = CASE
                                 WHEN LTRIM(RTRIM(p.File_NAME)) IS NULL
                                  THEN (SELECT ISNULL(DEMO_Y1.Last_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.First_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.Middle_NAME, '') AS expr
                                          FROM DEMO_Y1
                                         WHERE DEMO_Y1.MemberMci_IDNO = c.MemberMci_IDNO)
                                 ELSE p.File_NAME
                                END
             FROM DPRS_Y1 AS p,
                  CMEM_Y1 AS c
            WHERE p.File_ID = @Lc_File_ID
              AND c.Case_IDNO = @An_Case_IDNO
              AND c.MemberMci_IDNO = p.DocketPerson_IDNO
              AND c.CaseRelationship_CODE = @Ls_RelationshipCaseCp_TEXT
              AND p.TypePerson_CODE = @Ls_TypePartyIp_CODE
              AND p.EndValidity_DATE = @Ld_High_DATE
              AND p.EffectiveEnd_DATE = @Ld_High_DATE

           SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '');
           SET @Ls_Sql_TEXT = 'SELECT_VOTHP';

           SELECT @Ls_Petitioner_NAME = OTHP_Y1.OtherParty_NAME
             FROM OTHP_Y1
            WHERE OTHP_Y1.OtherParty_IDNO IN (SELECT DPRS_Y1.DocketPerson_IDNO
                                                FROM DPRS_Y1
                                               WHERE DPRS_Y1.File_ID = @Lc_File_ID
                                                 AND DPRS_Y1.EndValidity_DATE = @Ld_High_DATE
                                                 AND DPRS_Y1.EffectiveEnd_DATE = @Ld_High_DATE
                                                 AND DPRS_Y1.TypePerson_CODE = @Ls_TypePartyCpl_CODE
                                                 AND dbo.BATCH_COMMON_SCALAR$SF_LENGTH_VARCHAR(DPRS_Y1.DocketPerson_IDNO) = 9)
              AND OTHP_Y1.TypeOthp_CODE = @Ls_TypeOthpO1_CODE
              AND OTHP_Y1.EndValidity_DATE = @Ld_High_DATE

           SELECT @As_Last_NAME = SUBSTRING(ISNULL(@Ls_Petitioner_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(@Ls_ObligeeObo_TEXT, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(@Ls_Ip_NAME, ''), 1, 99)
          END--B9
        END
      END-- FOR ELSE
    END
   ELSE --B2
    BEGIN
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '');
     SET @Ls_Sql_TEXT = 'SELECT_VCASE_VDPRS1';

     SELECT @Ac_CaseRelationship_CODE = (SELECT c.CaseRelationship_CODE
                                           FROM CMEM_Y1 AS c
                                          WHERE c.Case_IDNO = SSMAROWNUM.Case_IDNO
                                            AND c.CaseRelationship_CODE IN (@Ls_RelationshipCaseNcp_TEXT, @Ls_RelationshipCaseCp_TEXT, @Ls_RelationshipCasePutFather_TEXT)
                                            AND SSMAROWNUM.DocketPerson_IDNO = c.MemberMci_IDNO),
            @As_ObligationStatus_CODE = (SELECT CASE c.CaseRelationship_CODE
                                                 WHEN @Ls_RelationshipCaseNcp_TEXT
                                                  THEN @Ls_RelationshipCaseO1_CODE
                                                 WHEN @Ls_RelationshipCasePutFather_TEXT
                                                  THEN @Ls_RelationshipCaseO1_CODE
                                                 WHEN @Ls_RelationshipCaseCp_TEXT
                                                  THEN @Ls_RelationshipCaseE1_CODE
                                                END AS expr
                                           FROM CMEM_Y1 AS c
                                          WHERE c.Case_IDNO = SSMAROWNUM.Case_IDNO
                                            AND c.CaseRelationship_CODE IN (@Ls_RelationshipCaseNcp_TEXT, @Ls_RelationshipCaseCp_TEXT, @Ls_RelationshipCasePutFather_TEXT)
                                            AND SSMAROWNUM.DocketPerson_IDNO = c.MemberMci_IDNO),
            @As_Last_NAME = CASE
                             WHEN (SSMAROWNUM.File_NAME) IS NULL
                              THEN (SELECT ISNULL(d.Last_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(d.First_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(d.Middle_NAME, '') AS expr
                                      FROM DEMO_Y1 AS d,
                                           CMEM_Y1 AS c
                                     WHERE d.MemberMci_IDNO = c.MemberMci_IDNO
                                       AND c.Case_IDNO = SSMAROWNUM.Case_IDNO
                                       AND c.CaseRelationship_CODE IN (@Ls_RelationshipCaseNcp_TEXT, @Ls_RelationshipCaseCp_TEXT, @Ls_RelationshipCasePutFather_TEXT)
                                       AND SSMAROWNUM.DocketPerson_IDNO = c.MemberMci_IDNO)
                             ELSE SSMAROWNUM.File_NAME
                            END,
            @As_First_NAME = @Ls_Null_TEXT,
            @As_Middle_NAME = @Ls_Null_TEXT,
            @As_Litigant_IDNO = SSMAROWNUM.DocketPerson_IDNO,
            @Lc_File_ID = SSMAROWNUM.File_ID,
            @Ls_Petitioner_NAME = SSMAROWNUM.File_NAME
       FROM (SELECT Case_IDNO,
                    DocketPerson_IDNO,
                    File_NAME,
                    File_ID,
                    StatusCase_CODE,
                    File_ID$2,
                    EndValidity_DATE,
                    TypePerson_CODE,
                    EffectiveEnd_DATE,
                    ROW_NUMBER() OVER( ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
               FROM (SELECT s.Case_IDNO,
                            p.DocketPerson_IDNO,
                            p.File_NAME,
                            s.File_ID,
                            s.StatusCase_CODE,
                            p.File_ID AS File_ID$2,
                            p.EndValidity_DATE,
                            p.TypePerson_CODE,
                            p.EffectiveEnd_DATE,
                            0 AS SSMAPSEUDOCOLUMN
                       FROM CASE_Y1 AS s,
                            DPRS_Y1 AS p
                      WHERE s.Case_IDNO = @An_Case_IDNO
                        AND s.StatusCase_CODE = @Ls_CaseStatusOpen_CODE
                        AND s.File_ID = p.File_ID
                        AND p.EndValidity_DATE = @Ld_High_DATE
                        AND p.TypePerson_CODE = @Ls_LitigantOptn2_TEXT
                        AND p.EffectiveEnd_DATE = @Ld_High_DATE
                        AND 1 = 1) AS SSMAPSEUDO) AS SSMAROWNUM
      WHERE SSMAROWNUM.Case_IDNO = @An_Case_IDNO
        AND SSMAROWNUM.StatusCase_CODE = @Ls_CaseStatusOpen_CODE
        AND SSMAROWNUM.File_ID = SSMAROWNUM.File_ID
        AND SSMAROWNUM.EndValidity_DATE = @Ld_High_DATE
        AND SSMAROWNUM.TypePerson_CODE = @Ls_LitigantOptn2_TEXT
        AND SSMAROWNUM.EffectiveEnd_DATE = @Ld_High_DATE
        AND SSMAROWNUM.ROWNUM <= 1

     IF LEN(@As_Litigant_IDNO) = 9
        AND (@Ls_LitigantOption1_TEXT = @Ls_TypePartyCpl_CODE
              OR @Ls_LitigantOptn2_TEXT = @Ls_TypePartyPl_CODE)
      BEGIN--B11
       SET @Ac_CaseRelationship_CODE = @Ls_RelationshipCaseCp_TEXT;
       SET @As_ObligationStatus_CODE = @Ls_RelationshipCaseE1_CODE;
       SET @As_First_NAME = NULL;
       SET @As_Middle_NAME = NULL;
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' TypePerson_CODE = ' + ISNULL(@Ls_TypePartyIp_CODE, '');
       SET @Ls_Sql_TEXT = 'SELECT_VDPRS1';

       SELECT @Ls_Ip_NAME = CASE
                             WHEN (p.File_NAME) IS NULL
                              THEN (SELECT ISNULL(d.Last_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(d.First_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(d.Middle_NAME, '') AS expr
                                      FROM DEMO_Y1 AS d,
                                           CMEM_Y1 AS c
                                     WHERE c.Case_IDNO IN (SELECT CASE_Y1.Case_IDNO
                                                             FROM CASE_Y1
                                                            WHERE CASE_Y1.File_ID = p.File_ID
                                                              AND CASE_Y1.StatusCase_CODE = @Ls_CaseStatusOpen_CODE)
                                       AND c.CaseRelationship_CODE = @Ls_RelationshipCaseCp_TEXT
                                       AND d.MemberMci_IDNO = c.MemberMci_IDNO
                                       AND c.MemberMci_IDNO = p.DocketPerson_IDNO)
                             ELSE p.File_NAME
                            END
         FROM DPRS_Y1 AS p
        WHERE p.File_ID = @Lc_File_ID
          AND p.TypePerson_CODE = @Ls_TypePartyIp_CODE
          AND p.EndValidity_DATE = @Ld_High_DATE
          AND p.EffectiveEnd_DATE = @Ld_High_DATE

       IF(@@ROWCOUNT = 0)
        BEGIN--B12
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '');
         SET @Ls_Sql_TEXT = 'SELECT_VCMEM_VDPRS2';

         SELECT @Ls_Ip_NAME = CASE
                               WHEN (SSMAROWNUM.File_NAME) IS NULL
                                THEN (SELECT ISNULL(DEMO_Y1.Last_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.First_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(DEMO_Y1.Middle_NAME, '') AS expr
                                        FROM DEMO_Y1
                                       WHERE DEMO_Y1.MemberMci_IDNO = SSMAROWNUM.MemberMci_IDNO)
                               ELSE SSMAROWNUM.File_NAME
                              END
           FROM (SELECT File_NAME,
                        MemberMci_IDNO,
                        File_ID,
                        Case_IDNO,
                        DocketPerson_IDNO,
                        CaseRelationship_CODE,
                        TypePerson_CODE,
                        EndValidity_DATE,
                        EffectiveEnd_DATE,
                        ROW_NUMBER() OVER( ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
                   FROM (SELECT p.File_NAME,
                                c.MemberMci_IDNO,
                                p.File_ID,
                                c.Case_IDNO,
                                p.DocketPerson_IDNO,
                                c.CaseRelationship_CODE,
                                p.TypePerson_CODE,
                                p.EndValidity_DATE,
                                p.EffectiveEnd_DATE,
                                0 AS SSMAPSEUDOCOLUMN
                           FROM DPRS_Y1 AS p,
                                CMEM_Y1 AS c
                          WHERE p.File_ID = @Lc_File_ID
                            AND c.Case_IDNO = @An_Case_IDNO
                            AND c.MemberMci_IDNO = p.DocketPerson_IDNO
                            AND c.CaseRelationship_CODE IN (@Ls_RelationshipCaseCp_TEXT, @Ls_RelationshipCaseNcp_TEXT)
                            AND p.TypePerson_CODE = @Ls_TypePartyCpl_CODE
                            AND p.EndValidity_DATE = @Ld_High_DATE
                            AND p.EffectiveEnd_DATE = @Ld_High_DATE
                            AND 1 = 1) AS SSMAPSEUDO) AS SSMAROWNUM
          WHERE SSMAROWNUM.File_ID = @Lc_File_ID
            AND SSMAROWNUM.Case_IDNO = @An_Case_IDNO
            AND SSMAROWNUM.MemberMci_IDNO = SSMAROWNUM.DocketPerson_IDNO
            AND SSMAROWNUM.CaseRelationship_CODE IN (@Ls_RelationshipCaseCp_TEXT, @Ls_RelationshipCaseNcp_TEXT)
            AND SSMAROWNUM.TypePerson_CODE = @Ls_TypePartyCpl_CODE
            AND SSMAROWNUM.EndValidity_DATE = @Ld_High_DATE
            AND SSMAROWNUM.EffectiveEnd_DATE = @Ld_High_DATE
            AND SSMAROWNUM.ROWNUM <= 1
        END--B12

       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ' LITIGANT_OPTN = ' + ISNULL(@As_LitigantOption_TEXT, '') + 'ID_LITIGANT=' + ISNULL(@As_Litigant_IDNO, '')
       SET @Ls_Sql_TEXT = 'SELECT_VOTHP';

       SELECT @Ls_Petitioner_NAME = OTHP_Y1.OtherParty_NAME
         FROM OTHP_Y1
        WHERE OTHP_Y1.OtherParty_IDNO = @As_Litigant_IDNO
          AND OTHP_Y1.TypeOthp_CODE = @Ls_TypeOthpO1_CODE
          AND OTHP_Y1.EndValidity_DATE = @Ld_High_DATE

       SELECT @As_Last_NAME = SUBSTRING(ISNULL(@Ls_Petitioner_NAME, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(@Ls_ObligeeObo_TEXT, '') + ISNULL(@Ls_Space_TEXT, '') + ISNULL(@Ls_Ip_NAME, ''), 1, 99)
      END--B11
    END

   SET @Ac_Msg_CODE = @Ls_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Ln_Errornumber_NUMB INT;
   DECLARE @Ls_Errormessage_TEXT NVARCHAR(4000);
   DECLARE @Ln_ErrorLine_NUMB INT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Errornumber_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_Errormessage_TEXT = ISNULL(@As_DescriptionError_TEXT, '') + SUBSTRING(ERROR_MESSAGE(), 1, 200);
   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Sql_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Errormessage_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@As_DescriptionError_TEXT, '');
  END CATCH
 END


GO
