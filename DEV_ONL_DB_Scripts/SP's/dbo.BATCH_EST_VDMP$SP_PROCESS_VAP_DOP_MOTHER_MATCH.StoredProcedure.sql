/****** Object:  StoredProcedure [dbo].[BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MOTHER_MATCH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MOTHER_MATCH
Programmer Name	:	IMP Team.
Description		:	This batch program runs when there was no match found initially during the Child First process.
Frequency		:	'WEEKLY'
Developed On	:	3/16/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_MOTHER_MATCH]
 @Ac_Job_ID                   CHAR(7),
 @An_ChildMemberMci_IDNO      NUMERIC,
 @An_ChildMemberSsn_NUMB      NUMERIC,
 @An_MotherMemberMci_IDNO     NUMERIC,
 @An_MotherMemberSsn_NUMB     NUMERIC,
 @An_FatherMemberMci_IDNO     NUMERIC,
 @An_FatherMemberSsn_NUMB     NUMERIC,
 @Ac_DopAttached_CODE         CHAR(1),
 @Ac_ChildBirthCertificate_ID CHAR(7),
 @Ac_ChildFirst_NAME          CHAR(16),
 @Ac_MotherFirst_NAME         CHAR(16),
 @Ac_FatherFirst_NAME         CHAR(16),
 @Ac_ChildLast_NAME           CHAR(20),
 @Ac_MotherLast_NAME          CHAR(20),
 @Ac_FatherLast_NAME          CHAR(20),
 @Ad_ChildBirth_DATE          DATE,
 @Ad_MotherBirth_DATE         DATE,
 @Ad_FatherBirth_DATE         DATE,
 @Ad_MotherSignature_DATE     DATE,
 @Ad_FatherSignature_DATE     DATE,
 @Ad_Run_DATE                 DATE,
 @Ac_Goto_CODE                CHAR(7) OUTPUT,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_FourPoints_NUMB           NUMERIC = 4,
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_DOPAttachedYes_CODE       CHAR(1) = 'Y',
          @Lc_DOPAttachedNo_CODE        CHAR(1) = 'N',
          @Lc_DepCaseRelationship_CODE  CHAR(1) = 'D',
          @Lc_CPCaseRelationship_CODE   CHAR(1) = 'C',
          @Lc_NCPCaseRelationship_CODE  CHAR(1) = 'A',
          @Lc_PNCPCaseRelationship_CODE CHAR(1) = 'P',
          @Lc_No_INDC                   CHAR(1) = 'N',
          @Lc_MTRMemberSex_CODE         CHAR(1) = 'F',
          @Lc_FTRMemberSex_CODE         CHAR(1) = 'M',
          @Lc_StateDisestablish_CODE    CHAR(2) = ' ',
          @Lc_DopTypeDocument_CODE      CHAR(3) = 'DOP',
          @Lc_Relation_Mother_CODE      CHAR(3) = 'MTR',
          @Lc_Relation_Father_CODE      CHAR(3) = 'FTR',
          @Lc_Job_ID                    CHAR(7) = @Ac_Job_ID,
          @Ls_Procedure_NAME            VARCHAR(100) = 'SP_PROCESS_VAP_DOP_MOTHER_MATCH',
          @Ld_Disestablish_DATE         DATE = NULL,
          @Ld_Low_DATE                  DATE = '01/01/0001',
          @Ld_High_DATE                 DATE = '12/31/9999';
  DECLARE @Ln_ChildPointsCounter_NUMB                           NUMERIC = 0,
          @Ln_ParentPointsCounter_NUMB                          NUMERIC = 0,
          @Ln_RowsCount_QNTY                                    NUMERIC,
          @Ln_ChildDemo_MemberMci_IDNO                          NUMERIC,
          @Ln_ChildDemo_MemberSsn_NUMB                          NUMERIC,
          @Ln_MotherDemo_MemberMci_IDNO                         NUMERIC,
          @Ln_MotherDemo_MemberSsn_NUMB                         NUMERIC,
          @Ln_EstFatherDemo_MemberMci_IDNO                      NUMERIC,
          @Ln_EstFatherDemo_MemberSsn_NUMB                      NUMERIC,
          @Ln_DisEstFatherDemo_MemberMci_IDNO                   NUMERIC,
          @Ln_VappCur_DisFatherMemberMci_IDNO                   NUMERIC,
          @Ln_VappCur_DisFatherMemberSsn_NUMB                   NUMERIC,
          @Ln_Error_NUMB                                        NUMERIC(11),
          @Ln_ErrorLine_NUMB                                    NUMERIC(11),
          @Li_CaseFetchStatus_QNTY                              INT,
          @Li_DemoFetchStatus_QNTY                              INT,
          @Li_DepandantFetchStatus_QNTY                         INT,
          @Li_ParentFetchStatus_QNTY                            INT,
          @Li_ParentFirstProcessParentDataMatchPointMother_QNTY INT = 0,
          @Li_ParentFirstProcessChildDataMatchPoint_QNTY        INT = 0,
          @Li_ParentFirstProcessParentDataMatchPoint_QNTY       INT = 0,
          @Lc_Empty_TEXT                                        CHAR = '',
          @Lc_MTRCaseRelationship_CODE                          CHAR(1),
          @Lc_EFTRCaseRelationship_CODE                         CHAR(1),
          @Lc_DisEstablishedFather_CODE                         CHAR(1),
          @Lc_MatchFound_INDC                                   CHAR(1) = 'N',
          @Lc_MotherDemo_Suffix_NAME                            CHAR(4),
          @Lc_EstFatherDemo_Suffix_NAME                         CHAR(4),
          @Lc_DisEstFatherDemo_Suffix_NAME                      CHAR(4),
          @Lc_Msg_CODE                                          CHAR(5) = '',
          @Lc_ChildDemo_First_NAME                              CHAR(16),
          @Lc_MotherDemo_First_NAME                             CHAR(16),
          @Lc_EstFatherDemo_First_NAME                          CHAR(16),
          @Lc_DisEstFatherDemo_First_NAME                       CHAR(16),
          @Lc_VappCur_DisFatherFirst_NAME                       CHAR(16),
          @Lc_ChildDemo_BirthCertificate_ID                     CHAR(20),
          @Lc_ChildDemo_Last_NAME                               CHAR(20),
          @Lc_MotherDemo_Last_NAME                              CHAR(20),
          @Lc_MotherDemo_Middle_NAME                            CHAR(20),
          @Lc_EstFatherDemo_Last_NAME                           CHAR(20),
          @Lc_EstFatherDemo_Middle_NAME                         CHAR(20),
          @Lc_DisEstFatherDemo_Last_NAME                        CHAR(20),
          @Lc_DisEstFatherDemo_Middle_NAME                      CHAR(20),
          @Lc_VappCur_DisFatherLast_NAME                        CHAR(20),
          @Ls_Sql_TEXT                                          VARCHAR(100),
          @Ls_Sqldata_TEXT                                      VARCHAR(1000),
          @Ls_ErrorMessage_TEXT                                 VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT                             VARCHAR(4000),
          @Ld_DOPMotherSig_DATE                                 DATE,
          @Ld_DOPFatherSig_DATE                                 DATE,
          @Ld_UpdateEstDate_DATE                                DATE,
          @Ld_ChildDemo_Birth_DATE                              DATE,
          @Ld_MotherDemo_Birth_DATE                             DATE,
          @Ld_EstFatherDemo_Birth_DATE                          DATE,
          @Ld_VappCur_DisFatherBirth_DATE                       DATE,
          @Lb_DemoMultipleMatch_BIT                             BIT = 0,
          @Lb_UpdateMTRDemoVapp_BIT                             BIT = 0,
          @Lb_UpdateFTRDemoVapp_BIT                             BIT = 0,
          @Lb_UpdateDFTRDemoVapp_BIT                            BIT = 0;
  DECLARE @Ln_CaseDupMtrCur_Case_IDNO            NUMERIC,
          @Ln_DemoDupMtrCur_MemberMci_IDNO       NUMERIC,
          @Ln_DepDupMtrCur_MemberMci_IDNO        NUMERIC,
          @Ln_ParDupMtrCur_MemberMci_IDNO        NUMERIC,
          @Lc_ParDupMtrCur_MemberSex_CODE        CHAR(1),
          @Lc_ParDupMtrCur_CaseRelationship_CODE CHAR(1),
          @Lc_DepDupMtrCur_CPRelChild_CODE       CHAR(3),
          @Lc_DepDupMtrCur_NCPRelChild_CODE      CHAR(3);
  DECLARE @Ln_CaseSglMtrCur_Case_IDNO            NUMERIC,
          @Ln_DepSglMtrCur_MemberMci_IDNO        NUMERIC,
          @Ln_ParSglMtrCur_MemberMci_IDNO        NUMERIC,
          @Lc_ParSglMtrCur_MemberSex_CODE        CHAR(1),
          @Lc_ParSglMtrCur_CaseRelationship_CODE CHAR(1),
          @Lc_DepSglMtrCur_CPRelChild_CODE       CHAR(3),
          @Lc_DepSglMtrCur_NCPRelChild_CODE      CHAR(3);

  BEGIN TRY
   SELECT @Ln_MotherDemo_MemberMci_IDNO = 0,
          @Li_ParentFirstProcessParentDataMatchPointMother_QNTY = 0,
          @Lb_DemoMultipleMatch_BIT = 0,
          @Li_ParentFirstProcessParentDataMatchPoint_QNTY = 0,
          @Ln_DemoDupMtrCur_MemberMci_IDNO = 0,
          @Li_DemoFetchStatus_QNTY = -1,
          @Lc_MatchFound_INDC = @Lc_No_INDC,
          @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
          @Ln_CaseDupMtrCur_Case_IDNO = 0,
          @Li_CaseFetchStatus_QNTY = -1,
          @Ln_DepDupMtrCur_MemberMci_IDNO = 0,
          @Lc_DepDupMtrCur_CPRelChild_CODE = '',
          @Lc_DepDupMtrCur_NCPRelChild_CODE = '',
          @Li_DepandantFetchStatus_QNTY = -1,
          @Ln_ChildDemo_MemberMci_IDNO = 0,
          @Ln_ChildDemo_MemberSsn_NUMB = 0,
          @Lc_ChildDemo_BirthCertificate_ID = '',
          @Lc_ChildDemo_Last_NAME = '',
          @Lc_ChildDemo_First_NAME = '',
          @Ld_ChildDemo_Birth_DATE = @Ld_Low_DATE,
          @Ln_ParDupMtrCur_MemberMci_IDNO = 0,
          @Lc_ParDupMtrCur_CaseRelationship_CODE = '',
          @Lc_ParDupMtrCur_MemberSex_CODE = '',
          @Li_ParentFetchStatus_QNTY = -1,
          @Ln_CaseSglMtrCur_Case_IDNO = 0,
          @Li_CaseFetchStatus_QNTY = -1,
          @Ln_DepSglMtrCur_MemberMci_IDNO = 0,
          @Lc_DepSglMtrCur_CPRelChild_CODE = '',
          @Lc_DepSglMtrCur_NCPRelChild_CODE = '',
          @Li_DepandantFetchStatus_QNTY = -1,
          @Ln_ParSglMtrCur_MemberMci_IDNO = 0,
          @Lc_ParSglMtrCur_CaseRelationship_CODE = '',
          @Lc_ParSglMtrCur_MemberSex_CODE = '',
          @Li_ParentFetchStatus_QNTY = -1,
          @Lc_MTRCaseRelationship_CODE = '',
          @Ln_MotherDemo_MemberMci_IDNO = 0,
          @Ln_MotherDemo_MemberSsn_NUMB = 0,
          @Lc_MotherDemo_Last_NAME = '',
          @Lc_MotherDemo_First_NAME = '',
          @Lc_MotherDemo_Middle_NAME = '',
          @Lc_MotherDemo_Suffix_NAME = '',
          @Ld_MotherDemo_Birth_DATE = @Ld_Low_DATE,
          @Ln_RowsCount_QNTY = 0,
          @Lb_UpdateMTRDemoVapp_BIT = 0,
          @Lc_EFTRCaseRelationship_CODE = '',
          @Ln_EstFatherDemo_MemberMci_IDNO = 0,
          @Ln_EstFatherDemo_MemberSsn_NUMB = 0,
          @Lc_EstFatherDemo_Last_NAME = '',
          @Lc_EstFatherDemo_First_NAME = '',
          @Lc_EstFatherDemo_Middle_NAME = '',
          @Lc_EstFatherDemo_Suffix_NAME = '',
          @Ld_EstFatherDemo_Birth_DATE = @Ld_Low_DATE,
          @Lb_UpdateFTRDemoVapp_BIT = 0,
          @Ln_VappCur_DisFatherMemberMci_IDNO = 0,
          @Lc_VappCur_DisFatherLast_NAME = '',
          @Lc_VappCur_DisFatherFirst_NAME = '',
          @Ld_VappCur_DisFatherBirth_DATE = @Ld_Low_DATE,
          @Ln_VappCur_DisFatherMemberSsn_NUMB = 0,
          @Ln_DisEstFatherDemo_MemberMci_IDNO = 0,
          @Lc_DisEstFatherDemo_Last_NAME = '',
          @Lc_DisEstFatherDemo_First_NAME = '',
          @Lc_DisEstFatherDemo_Middle_NAME = '',
          @Lc_DisEstFatherDemo_Suffix_NAME = '',
          @Lb_UpdateDFTRDemoVapp_BIT = 0,
          @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
          @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
          @Lc_StateDisestablish_CODE = '',
          @Lc_DisEstablishedFather_CODE = '',
          @Ld_UpdateEstDate_DATE = @Ld_Low_DATE,
          @Ld_Disestablish_DATE = @Ld_Low_DATE

   IF @An_MotherMemberMci_IDNO > 0
      AND (ISNUMERIC(@An_MotherMemberMci_IDNO) = 1
           AND EXISTS(SELECT 1
                        FROM DEMO_Y1 d
                       WHERE MemberMci_IDNO = @An_MotherMemberMci_IDNO
                         AND EXISTS (SELECT 1
                                       FROM CMEM_Y1 X
                                      WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                        AND X.CaseRelationship_CODE <> 'D'
                                        AND X.CaseMemberStatus_CODE = 'A')))
    BEGIN
     SET @Ls_Sql_TEXT = 'Select DEMO details of Mother';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MotherMemberMci_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

     SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO
       FROM DEMO_Y1 d
      WHERE d.MemberMci_IDNO = @An_MotherMemberMci_IDNO
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 X
                     WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                       AND X.CaseRelationship_CODE <> 'D'
                       AND X.CaseMemberStatus_CODE = 'A');

     SET @Li_ParentFirstProcessParentDataMatchPointMother_QNTY += 4; --Mother MCI 			= 4 points
     INSERT INTO #MfpMatchPointQntyInfo_P1
                 (ChildBirthCertificate_ID,
                  MotherMemberMci_IDNO,
                  MotherDataMatchPoint_QNTY)
          VALUES ( @Ac_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                   @An_MotherMemberMci_IDNO,--MotherMemberMci_IDNO
                   @Li_ParentFirstProcessParentDataMatchPointMother_QNTY --MotherDataMatchPoint_QNTY
     )
    END
   ELSE IF @An_MotherMemberSsn_NUMB > 0
      AND (ISNUMERIC(@An_MotherMemberSsn_NUMB) = 1
           AND EXISTS (SELECT 1
                         FROM DEMO_Y1 d
                        WHERE d.MemberSsn_NUMB = @An_MotherMemberSsn_NUMB
                          AND EXISTS (SELECT 1
                                        FROM CMEM_Y1 X
                                       WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                         AND X.CaseRelationship_CODE <> 'D'
                                         AND X.CaseMemberStatus_CODE = 'A')))
    BEGIN
     SET @Ls_Sql_TEXT = 'Select DEMO details of Mother';
     SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@An_MotherMemberSsn_NUMB AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

     SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO
       FROM DEMO_Y1 d
      WHERE d.MemberSsn_NUMB = @An_MotherMemberSsn_NUMB
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 X
                     WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                       AND X.CaseRelationship_CODE <> 'D'
                       AND X.CaseMemberStatus_CODE = 'A');

     SET @Li_ParentFirstProcessParentDataMatchPointMother_QNTY += 4; --Mother SSN 			= 4 points
     INSERT INTO #MfpMatchPointQntyInfo_P1
                 (ChildBirthCertificate_ID,
                  MotherMemberMci_IDNO,
                  MotherMemberSsn_NUMB,
                  MotherDataMatchPoint_QNTY)
          VALUES ( @Ac_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                   @Ln_MotherDemo_MemberMci_IDNO,--MotherMemberMci_IDNO
                   @An_MotherMemberSsn_NUMB,--MotherMemberSsn_NUMB
                   @Li_ParentFirstProcessParentDataMatchPointMother_QNTY --MotherDataMatchPoint_QNTY
     )
    END
   ELSE IF (LEN(LTRIM(RTRIM(@Ac_MotherLast_NAME))) > 0
       AND LEN(LTRIM(RTRIM(@Ac_MotherFirst_NAME))) > 0)
      AND 1 < (SELECT COUNT(DISTINCT(d.MemberMci_IDNO))
                 FROM DEMO_Y1 d
                WHERE Last_NAME = @Ac_MotherLast_NAME
                  AND First_NAME = @Ac_MotherFirst_NAME
                  AND EXISTS (SELECT 1
                                FROM CMEM_Y1 X
                               WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                 AND X.CaseRelationship_CODE <> 'D'
                                 AND X.CaseMemberStatus_CODE = 'A'))
    BEGIN
     SET @Lb_DemoMultipleMatch_BIT =1;

     DECLARE DemoDupMtr_CUR INSENSITIVE CURSOR FOR
      SELECT d.MemberMci_IDNO
        FROM DEMO_Y1 d
       WHERE Last_NAME = @Ac_MotherLast_NAME
         AND First_NAME = @Ac_MotherFirst_NAME
         AND EXISTS (SELECT 1
                       FROM CMEM_Y1 X
                      WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                        AND X.CaseRelationship_CODE <> 'D'
                        AND X.CaseMemberStatus_CODE = 'A');

     SET @Li_ParentFirstProcessParentDataMatchPointMother_QNTY += 2; --Mother Last Name 			= 2 points
     SET @Li_ParentFirstProcessParentDataMatchPointMother_QNTY += 1; --Mother First Name			= 1 point	
     INSERT INTO #MfpMatchPointQntyInfo_P1
                 (ChildBirthCertificate_ID,
                  MotherLast_NAME,
                  MotherFirst_NAME,
                  MotherDataMatchPoint_QNTY)
          VALUES ( @Ac_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                   @Ac_MotherLast_NAME,--MotherLast_NAME
                   @Ac_MotherFirst_NAME,--MotherFirst_NAME
                   @Li_ParentFirstProcessParentDataMatchPointMother_QNTY --MotherDataMatchPoint_QNTY
     )
    END
   ELSE IF (LEN(LTRIM(RTRIM(@Ac_MotherLast_NAME))) > 0
       AND LEN(LTRIM(RTRIM(@Ac_MotherFirst_NAME))) > 0)
      AND 1 = (SELECT COUNT(DISTINCT(d.MemberMci_IDNO))
                 FROM DEMO_Y1 d
                WHERE Last_NAME = @Ac_MotherLast_NAME
                  AND First_NAME = @Ac_MotherFirst_NAME
                  AND EXISTS (SELECT 1
                                FROM CMEM_Y1 X
                               WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                 AND X.CaseRelationship_CODE <> 'D'
                                 AND X.CaseMemberStatus_CODE = 'A'))
    BEGIN
     SET @Lb_DemoMultipleMatch_BIT =0;
     SET @Ls_Sqldata_TEXT = 'Last_NAME = ' + ISNULL(@Ac_MotherLast_NAME, '') + ', First_NAME = ' + ISNULL(@Ac_MotherFirst_NAME, '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

     SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO
       FROM DEMO_Y1 d
      WHERE Last_NAME = @Ac_MotherLast_NAME
        AND First_NAME = @Ac_MotherFirst_NAME
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 X
                     WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                       AND X.CaseRelationship_CODE <> 'D'
                       AND X.CaseMemberStatus_CODE = 'A');

     SET @Li_ParentFirstProcessParentDataMatchPointMother_QNTY += 2; --Mother Last Name 			= 2 points
     SET @Li_ParentFirstProcessParentDataMatchPointMother_QNTY += 1; --Mother First Name			= 1 point	
     INSERT INTO #MfpMatchPointQntyInfo_P1
                 (ChildBirthCertificate_ID,
                  MotherMemberMci_IDNO,
                  MotherLast_NAME,
                  MotherFirst_NAME,
                  MotherDataMatchPoint_QNTY)
          VALUES ( @Ac_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                   @Ln_MotherDemo_MemberMci_IDNO,--MotherMemberMci_IDNO
                   @Ac_MotherLast_NAME,--MotherLast_NAME
                   @Ac_MotherFirst_NAME,--MotherFirst_NAME
                   @Li_ParentFirstProcessParentDataMatchPointMother_QNTY --MotherDataMatchPoint_QNTY
     )
    END
   ELSE
    BEGIN
     SET @Ac_Goto_CODE = 'BEGIN_FATHER_PROCESS';

     GOTO END_MOTHER_PROCESS;
    END

   SELECT @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY

   IF(@Lb_DemoMultipleMatch_BIT = 1)
    BEGIN
     SELECT @Ln_DemoDupMtrCur_MemberMci_IDNO = 0,
            @Li_DemoFetchStatus_QNTY = -1,
            @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
            @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
            @Lc_MatchFound_INDC = @Lc_No_INDC

     SET @Ls_Sql_TEXT ='OPEN DemoDupMtr_CUR 1';

     OPEN DemoDupMtr_CUR;

     SET @Ls_Sql_TEXT ='FETCH DemoDupMtr_CUR 1';

     FETCH NEXT FROM DemoDupMtr_CUR INTO @Ln_DemoDupMtrCur_MemberMci_IDNO;

     SET @Li_DemoFetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT ='WHILE DemoDupMtr_CUR 1';

     -- Process each demo record found
     WHILE @Li_DemoFetchStatus_QNTY = 0
           AND @Lc_MatchFound_INDC = 'N'
      BEGIN
       IF EXISTS(SELECT 1
                   FROM #MfpMatchPointQntyInfo_P1 A
                  WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                    AND A.MotherMemberMci_IDNO IS NULL)
        BEGIN
         UPDATE #MfpMatchPointQntyInfo_P1
            SET MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
        END
       ELSE
        BEGIN
         INSERT INTO #MfpMatchPointQntyInfo_P1
                     (ChildBirthCertificate_ID,
                      MotherMemberMci_IDNO,
                      MotherLast_NAME,
                      MotherFirst_NAME,
                      MotherDataMatchPoint_QNTY)
         SELECT TOP 1 A.ChildBirthCertificate_ID,
                      @Ln_DemoDupMtrCur_MemberMci_IDNO AS MotherMemberMci_IDNO,
                      A.MotherLast_NAME,
                      A.MotherFirst_NAME,
                      A.MotherDataMatchPoint_QNTY
           FROM #MfpMatchPointQntyInfo_P1 A
          WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
        END

       SELECT @Ln_CaseDupMtrCur_Case_IDNO = 0,
              @Li_CaseFetchStatus_QNTY = -1,
              @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
              @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
              @Lc_MatchFound_INDC = @Lc_No_INDC

       SET @Ls_Sql_TEXT ='CaseDupMtr_CUR 1';

       DECLARE CaseDupMtr_CUR INSENSITIVE CURSOR FOR
        SELECT c.Case_IDNO
          FROM CMEM_Y1 c
         WHERE c.MemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
           AND c.CaseRelationship_CODE <> 'D'
           AND c.CaseMemberStatus_CODE = 'A'
           AND EXISTS (SELECT 1
                         FROM CASE_Y1 X
                        WHERE X.Case_IDNO = c.Case_IDNO
                          AND X.StatusCase_CODE = 'O');

       SET @Ls_Sql_TEXT ='OPEN CaseDupMtr_CUR 1';

       OPEN CaseDupMtr_CUR;

       SET @Ls_Sql_TEXT ='FETCH CaseDupMtr_CUR 1';

       FETCH NEXT FROM CaseDupMtr_CUR INTO @Ln_CaseDupMtrCur_Case_IDNO;

       SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT ='WHILE CaseDupMtr_CUR 1';

       -- Process each case for the selected dependant
       WHILE @Li_CaseFetchStatus_QNTY = 0
             AND @Lc_MatchFound_INDC = 'N'
        BEGIN
         IF EXISTS(SELECT 1
                     FROM #MfpMatchPointQntyInfo_P1 A
                    WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                      AND A.MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
                      AND A.MotherCase_IDNO IS NULL)
          BEGIN
           UPDATE #MfpMatchPointQntyInfo_P1
              SET MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
            WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
          END
         ELSE
          BEGIN
           INSERT INTO #MfpMatchPointQntyInfo_P1
                       (ChildBirthCertificate_ID,
                        MotherMemberMci_IDNO,
                        MotherLast_NAME,
                        MotherFirst_NAME,
                        MotherCase_IDNO,
                        MotherDataMatchPoint_QNTY)
           SELECT TOP 1 A.ChildBirthCertificate_ID,
                        A.MotherMemberMci_IDNO,
                        A.MotherLast_NAME,
                        A.MotherFirst_NAME,
                        @Ln_CaseDupMtrCur_Case_IDNO AS MotherCase_IDNO,
                        A.MotherDataMatchPoint_QNTY
             FROM #MfpMatchPointQntyInfo_P1 A
            WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND A.MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
          END

         SELECT @Ln_DepDupMtrCur_MemberMci_IDNO = 0,
                @Lc_DepDupMtrCur_CPRelChild_CODE = '',
                @Lc_DepDupMtrCur_NCPRelChild_CODE = '',
                @Li_DepandantFetchStatus_QNTY = -1,
                @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
                @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
                @Lc_MatchFound_INDC = @Lc_No_INDC

         SET @Ls_Sql_TEXT ='SET DepDupMtr_CUR 1';

         DECLARE DepDupMtr_CUR INSENSITIVE CURSOR FOR
          SELECT c.MemberMci_IDNO,
                 c.CpRelationshipToChild_CODE,
                 c.NcpRelationshipToChild_CODE
            FROM CMEM_Y1 c
           WHERE c.Case_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
             AND c.CaseRelationship_CODE = @Lc_DepCaseRelationship_CODE
             AND c.CaseMemberStatus_CODE = 'A';

         SET @Ls_Sql_TEXT ='OPEN DepDupMtr_CUR 1';

         OPEN DepDupMtr_CUR;

         SET @Ls_Sql_TEXT ='FETCH DepDupMtr_CUR 1';

         FETCH NEXT FROM DepDupMtr_CUR INTO @Ln_DepDupMtrCur_MemberMci_IDNO, @Lc_DepDupMtrCur_CPRelChild_CODE, @Lc_DepDupMtrCur_NCPRelChild_CODE;

         SET @Li_DepandantFetchStatus_QNTY = @@FETCH_STATUS;
         SET @Ls_Sql_TEXT ='WHILE DepDupMtr_CUR 1';

         -- Process each depandant
         WHILE @Li_DepandantFetchStatus_QNTY = 0
          BEGIN
           SELECT @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
                  @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
                  @Lc_MatchFound_INDC = @Lc_No_INDC

           IF EXISTS(SELECT 1
                       FROM #MfpMatchPointQntyInfo_P1 A
                      WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                        AND A.MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
                        AND A.MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
                        AND A.ChildMemberMci_IDNO IS NULL)
            BEGIN
             UPDATE #MfpMatchPointQntyInfo_P1
                SET ChildMemberMci_IDNO = @Ln_DepDupMtrCur_MemberMci_IDNO,
                    CpRelationshipToChild_CODE = @Lc_DepDupMtrCur_CPRelChild_CODE,
                    NcpRelationshipToChild_CODE = @Lc_DepDupMtrCur_NCPRelChild_CODE
              WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                AND MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
                AND MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
            END
           ELSE
            BEGIN
             INSERT INTO #MfpMatchPointQntyInfo_P1
                         (ChildBirthCertificate_ID,
                          MotherMemberMci_IDNO,
                          MotherLast_NAME,
                          MotherFirst_NAME,
                          MotherCase_IDNO,
                          ChildMemberMci_IDNO,
                          CpRelationshipToChild_CODE,
                          NcpRelationshipToChild_CODE,
                          MotherDataMatchPoint_QNTY)
             SELECT TOP 1 A.ChildBirthCertificate_ID,
                          A.MotherMemberMci_IDNO,
                          A.MotherLast_NAME,
                          A.MotherFirst_NAME,
                          A.MotherCase_IDNO,
                          @Ln_DepDupMtrCur_MemberMci_IDNO AS ChildMemberMci_IDNO,
                          @Lc_DepDupMtrCur_CPRelChild_CODE AS CpRelationshipToChild_CODE,
                          @Lc_DepDupMtrCur_NCPRelChild_CODE AS NcpRelationshipToChild_CODE,
                          A.MotherDataMatchPoint_QNTY
               FROM #MfpMatchPointQntyInfo_P1 A
              WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                AND A.MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
                AND A.MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
            END

           SET @Ln_ChildPointsCounter_NUMB =0;
           SET @Ls_Sql_TEXT = 'Select DEMO details of Dependant';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DepDupMtrCur_MemberMci_IDNO AS VARCHAR), '');

           SELECT @Ln_ChildDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                  @Ln_ChildDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                  @Lc_ChildDemo_BirthCertificate_ID = ISNULL((SELECT ISNULL(x.BirthCertificate_ID, '')
                                                                FROM MPAT_Y1 x
                                                               WHERE x.MemberMci_IDNO = d.MemberMci_IDNO), ''),
                  @Lc_ChildDemo_Last_NAME = d.Last_NAME,
                  @Lc_ChildDemo_First_NAME = d.First_NAME,
                  @Ld_ChildDemo_Birth_DATE = d.Birth_DATE
             FROM DEMO_Y1 d
            WHERE d.MemberMci_IDNO = @Ln_DepDupMtrCur_MemberMci_IDNO;

           UPDATE #MfpMatchPointQntyInfo_P1
              SET ChildLast_NAME = @Lc_ChildDemo_Last_NAME,
                  ChildFirst_NAME = @Lc_ChildDemo_First_NAME,
                  ChildBirth_DATE = @Ld_ChildDemo_Birth_DATE,
                  ChildMemberSsn_NUMB = @Ln_ChildDemo_MemberSsn_NUMB,
                  ChildDemoBirthCertificate_ID = @Lc_ChildDemo_BirthCertificate_ID
            WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
              AND MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
              AND ChildMemberMci_IDNO = @Ln_DepDupMtrCur_MemberMci_IDNO

           IF((ISNULL(@An_ChildMemberMci_IDNO, 0) > 0
                OR ISNULL(@Ln_ChildDemo_MemberMci_IDNO, 0) > 0)
              AND @An_ChildMemberMci_IDNO = @Ln_ChildDemo_MemberMci_IDNO)
            BEGIN
             SET @Ln_ChildPointsCounter_NUMB = @Ln_ChildPointsCounter_NUMB + @Ln_FourPoints_NUMB;
             SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 4; --MCI 				= 4 points
            END
           ELSE IF ((LEN(LTRIM(RTRIM(ISNULL(@Ac_ChildBirthCertificate_ID, '')))) > 0
                 OR LEN(LTRIM(RTRIM(ISNULL(@Lc_ChildDemo_BirthCertificate_ID, '')))) > 0)
               AND @Ac_ChildBirthCertificate_ID = @Lc_ChildDemo_BirthCertificate_ID)
            BEGIN
             SET @Ln_ChildPointsCounter_NUMB = @Ln_ChildPointsCounter_NUMB + @Ln_FourPoints_NUMB;
             SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 4; --Birth Certificate 			= 4 points					
            END
           ELSE IF ((ISNULL(@An_ChildMemberSsn_NUMB, 0) > 0
                 OR ISNULL(@Ln_ChildDemo_MemberSsn_NUMB, 0) > 0)
               AND @An_ChildMemberSsn_NUMB = @Ln_ChildDemo_MemberSsn_NUMB)
            BEGIN
             SET @Ln_ChildPointsCounter_NUMB = @Ln_ChildPointsCounter_NUMB + @Ln_FourPoints_NUMB;
             SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 4; --SSN 				= 4 points					
            END
           ELSE
            BEGIN
             IF (LEN(LTRIM(RTRIM(ISNULL(@Ac_ChildLast_NAME, '')))) > 0
                  OR LEN(LTRIM(RTRIM(ISNULL(@Lc_ChildDemo_Last_NAME, '')))) > 0)
                AND @Ac_ChildLast_NAME = @Lc_ChildDemo_Last_NAME
              BEGIN
               SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 2; --Last Name 				= 2 points
              END

             IF (LEN(LTRIM(RTRIM(ISNULL(@Ac_ChildFirst_NAME, '')))) > 0
                  OR LEN(LTRIM(RTRIM(ISNULL(@Lc_ChildDemo_First_NAME, '')))) > 0)
                AND @Ac_ChildFirst_NAME = @Lc_ChildDemo_First_NAME
              BEGIN
               SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 1; --First Name				= 1 point
              END

             IF (ISNULL(@Ad_ChildBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
                  OR ISNULL(@Ld_ChildDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
                AND @Ad_ChildBirth_DATE = @Ld_ChildDemo_Birth_DATE
              BEGIN
               SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 2; --DOB 				= 2 points
              END
            END;

           UPDATE #MfpMatchPointQntyInfo_P1
              SET ChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY
            WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
              AND MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
              AND ChildMemberMci_IDNO = @Ln_DepDupMtrCur_MemberMci_IDNO

           SET @Ls_Sql_TEXT ='FETCH NEXT DepDupMtr_CUR 2';

           FETCH NEXT FROM DepDupMtr_CUR INTO @Ln_DepDupMtrCur_MemberMci_IDNO, @Lc_DepDupMtrCur_CPRelChild_CODE, @Lc_DepDupMtrCur_NCPRelChild_CODE;

           SET @Li_DepandantFetchStatus_QNTY = @@FETCH_STATUS;
          END

         CLOSE DepDupMtr_CUR;

         DEALLOCATE DepDupMtr_CUR;

         NEXTPRT:;

         SELECT @Ln_ParDupMtrCur_MemberMci_IDNO = 0,
                @Lc_ParDupMtrCur_CaseRelationship_CODE = '',
                @Lc_ParDupMtrCur_MemberSex_CODE = '',
                @Li_ParentFetchStatus_QNTY = -1,
                @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
                @Lc_MatchFound_INDC = @Lc_No_INDC

           SELECT @Lc_MTRCaseRelationship_CODE = '',
                  @Ln_MotherDemo_MemberMci_IDNO = 0,
                  @Ln_MotherDemo_MemberSsn_NUMB = 0,
                  @Lc_MotherDemo_Last_NAME = '',
                  @Lc_MotherDemo_First_NAME = '',
                  @Lc_MotherDemo_Middle_NAME = '',
                  @Lc_MotherDemo_Suffix_NAME = '',
                  @Ld_MotherDemo_Birth_DATE = @Ld_Low_DATE,
                  @Ln_RowsCount_QNTY = 0,
                  @Lb_UpdateMTRDemoVapp_BIT = 0,
                  @Lc_EFTRCaseRelationship_CODE = '',
                  @Ln_EstFatherDemo_MemberMci_IDNO = 0,
                  @Ln_EstFatherDemo_MemberSsn_NUMB = 0,
                  @Lc_EstFatherDemo_Last_NAME = '',
                  @Lc_EstFatherDemo_First_NAME = '',
                  @Lc_EstFatherDemo_Middle_NAME = '',
                  @Lc_EstFatherDemo_Suffix_NAME = '',
                  @Ld_EstFatherDemo_Birth_DATE = @Ld_Low_DATE,
                  @Lb_UpdateFTRDemoVapp_BIT = 0,
                  @Ln_VappCur_DisFatherMemberMci_IDNO = 0,
                  @Lc_VappCur_DisFatherLast_NAME = '',
                  @Lc_VappCur_DisFatherFirst_NAME = '',
                  @Ld_VappCur_DisFatherBirth_DATE = @Ld_Low_DATE,
                  @Ln_VappCur_DisFatherMemberSsn_NUMB = 0,
                  @Ln_DisEstFatherDemo_MemberMci_IDNO = 0,
                  @Lc_DisEstFatherDemo_Last_NAME = '',
                  @Lc_DisEstFatherDemo_First_NAME = '',
                  @Lc_DisEstFatherDemo_Middle_NAME = '',
                  @Lc_DisEstFatherDemo_Suffix_NAME = '',
                  @Lb_UpdateDFTRDemoVapp_BIT = 0,
                  @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
                  @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
                  @Lc_StateDisestablish_CODE = '',
                  @Lc_DisEstablishedFather_CODE = '',
                  @Ld_UpdateEstDate_DATE = @Ld_Low_DATE,
                  @Ld_Disestablish_DATE = @Ld_Low_DATE

         SET @Ln_ParentPointsCounter_NUMB = 0;
         SET @Ls_Sql_TEXT ='SET ParDupMtr_CUR 1';

         DECLARE ParDupMtr_CUR INSENSITIVE CURSOR FOR
          SELECT c.MemberMci_IDNO,
                 c.CaseRelationship_CODE,
                 d.MemberSex_CODE
            FROM CMEM_Y1 c
                 JOIN DEMO_Y1 d
                  ON c.MemberMci_IDNO = d.MemberMci_IDNO
           WHERE Case_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
             AND CaseRelationship_CODE IN (@Lc_CPCaseRelationship_CODE, @Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
             AND CaseMemberStatus_CODE = 'A';

         SET @Ls_Sql_TEXT ='OPEN ParDupMtr_CUR 1';

         OPEN ParDupMtr_CUR;

         SET @Ls_Sql_TEXT ='FETCH ParDupMtr_CUR 1';

         FETCH NEXT FROM ParDupMtr_CUR INTO @Ln_ParDupMtrCur_MemberMci_IDNO, @Lc_ParDupMtrCur_CaseRelationship_CODE, @Lc_ParDupMtrCur_MemberSex_CODE;

         SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
         SET @Ls_Sql_TEXT ='WHILE Parent_CUR 1';

         -- Process parents records from the matched case of the dependant
         WHILE @Li_ParentFetchStatus_QNTY = 0
          BEGIN
           IF(@Lc_DepDupMtrCur_CPRelChild_CODE = @Lc_Relation_Mother_CODE
              AND @Lc_ParDupMtrCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
              AND @Lc_ParDupMtrCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
            BEGIN
             SET @Lc_MTRCaseRelationship_CODE = @Lc_ParDupMtrCur_CaseRelationship_CODE;
             SET @Ls_Sql_TEXT ='Select Mother details from DEMO 1';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupMtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                    @Lc_MotherDemo_First_NAME = d.First_NAME,
                    @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParDupMtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateMTRDemoVapp_BIT = 1;
              END
            END
           ELSE IF(@Lc_DepDupMtrCur_CPRelChild_CODE = @Lc_Relation_Father_CODE
              AND @Lc_ParDupMtrCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
              AND @Lc_ParDupMtrCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
            BEGIN
             SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParDupMtrCur_CaseRelationship_CODE;

             IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
              BEGIN
               SET @Ls_Sql_TEXT ='Select EstFather details from DEMO 1';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupMtrCur_MemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                      @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                      @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_ParDupMtrCur_MemberMci_IDNO;

               SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

               IF(@Ln_RowsCount_QNTY = 0)
                BEGIN
                 SET @Lb_UpdateFTRDemoVapp_BIT =1;
                END

               SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Mother First Process 1';
               SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

               SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                      @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                      @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                      @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                      @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
                 FROM VAPP_Y1 v
                WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
                  AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

               SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 1';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_DisFatherMemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_DisEstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Lc_DisEstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_DisEstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_DisEstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_DisEstFatherDemo_Suffix_NAME = d.Suffix_NAME
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;

               SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

               IF(@Ln_RowsCount_QNTY = 0)
                BEGIN
                 SET @Lb_UpdateDFTRDemoVapp_BIT =1;
                END
              END
             ELSE IF (@Ac_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
              BEGIN
               SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 2';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupMtrCur_MemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                      @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                      @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_ParDupMtrCur_MemberMci_IDNO;

               SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

               IF(@Ln_RowsCount_QNTY = 0)
                BEGIN
                 SET @Lb_UpdateFTRDemoVapp_BIT =1;
                END
              END
            END

           IF(@Lc_DepDupMtrCur_NCPRelChild_CODE = @Lc_Relation_Mother_CODE
              AND @Lc_ParDupMtrCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
              AND @Lc_ParDupMtrCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
            BEGIN
             SET @Lc_MTRCaseRelationship_CODE = @Lc_ParDupMtrCur_CaseRelationship_CODE;
             SET @Ls_Sql_TEXT ='Select Mother details from DEMO 2';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupMtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                    @Lc_MotherDemo_First_NAME = d.First_NAME,
                    @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParDupMtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateMTRDemoVapp_BIT =1;
              END
            END
           ELSE IF(@Lc_DepDupMtrCur_NCPRelChild_CODE = @Lc_Relation_Father_CODE
              AND @Lc_ParDupMtrCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
              AND @Lc_ParDupMtrCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
            BEGIN
             SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParDupMtrCur_CaseRelationship_CODE;

             IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
              BEGIN
               SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 3';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupMtrCur_MemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                      @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                      @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_ParDupMtrCur_MemberMci_IDNO;

               SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

               IF(@Ln_RowsCount_QNTY = 0)
                BEGIN
                 SET @Lb_UpdateFTRDemoVapp_BIT =1;
                END

               SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Mother First Process 2';
               SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

               SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                      @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                      @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                      @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                      @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
                 FROM VAPP_Y1 v
                WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
                  AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

               SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 2';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_DisFatherMemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_DisEstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Lc_DisEstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_DisEstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_DisEstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_DisEstFatherDemo_Suffix_NAME = d.Suffix_NAME
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;

               SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

               IF(@Ln_RowsCount_QNTY = 0)
                BEGIN
                 SET @Lb_UpdateDFTRDemoVapp_BIT =1;
                END
              END
             ELSE IF (@Ac_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
              BEGIN
               SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 4';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupMtrCur_MemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                      @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                      @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_ParDupMtrCur_MemberMci_IDNO;

               SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

               IF(@Ln_RowsCount_QNTY = 0)
                BEGIN
                 SET @Lb_UpdateFTRDemoVapp_BIT =1;
                END
              END
            END

           SET @Ls_Sql_TEXT ='FETCH NEXT ParDupMtr_CUR 2';

           FETCH NEXT FROM ParDupMtr_CUR INTO @Ln_ParDupMtrCur_MemberMci_IDNO, @Lc_ParDupMtrCur_CaseRelationship_CODE, @Lc_ParDupMtrCur_MemberSex_CODE;

           SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
          END

         CLOSE ParDupMtr_CUR;

         DEALLOCATE ParDupMtr_CUR;

         SET @Ls_Sql_TEXT ='Verify NCP Mother details with DEMO in Mother First Process 1';

         IF((ISNULL(@Ln_MotherDemo_MemberMci_IDNO, 0) > 0
              OR ISNULL(@An_MotherMemberMci_IDNO, 0) > 0)
            AND @Ln_MotherDemo_MemberMci_IDNO = @An_MotherMemberMci_IDNO)
          BEGIN
           SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 4; --Mother MCI 			= 4 points
          END
         ELSE IF ((ISNULL(@Ln_MotherDemo_MemberSsn_NUMB, 0) > 0
               OR ISNULL(@An_MotherMemberSsn_NUMB, 0) > 0)
             AND @Ln_MotherDemo_MemberSsn_NUMB = @An_MotherMemberSsn_NUMB)
          BEGIN
           SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 4; --Mother SSN 			= 4 points
          END
         ELSE
          BEGIN
           IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Last_NAME, '')))) > 0
                OR LEN(LTRIM(RTRIM(ISNULL(@Ac_MotherLast_NAME, '')))) > 0)
              AND @Lc_MotherDemo_Last_NAME = @Ac_MotherLast_NAME
            BEGIN
             SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 2; --Mother Last Name 			= 2 points
            END

           IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_First_NAME, '')))) > 0
                OR LEN(LTRIM(RTRIM(ISNULL(@Ac_MotherFirst_NAME, '')))) > 0)
              AND @Lc_MotherDemo_First_NAME = @Ac_MotherFirst_NAME
            BEGIN
             SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 1; --Mother First Name			= 1 point
            END

           IF (ISNULL(@Ld_MotherDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
                OR ISNULL(@Ad_MotherBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
              AND @Ld_MotherDemo_Birth_DATE = @Ad_MotherBirth_DATE
            BEGIN
             SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 2; --Mother DOB 			= 2 points
            END
          END;

         SET @Ls_Sql_TEXT ='Verify NCP EstFather details with DEMO in Mother First Process 1';

         IF((ISNULL(@Ln_EstFatherDemo_MemberMci_IDNO, 0) > 0
              OR ISNULL(@An_FatherMemberMci_IDNO, 0) > 0)
            AND @Ln_EstFatherDemo_MemberMci_IDNO = @An_FatherMemberMci_IDNO)
          BEGIN
           SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 4; --Father MCI	 			= 4 points
          END
         ELSE IF ((ISNULL(@Ln_EstFatherDemo_MemberSsn_NUMB, 0) > 0
               OR ISNULL(@An_FatherMemberSsn_NUMB, 0) > 0)
             AND @Ln_EstFatherDemo_MemberSsn_NUMB = @An_FatherMemberSsn_NUMB)
          BEGIN
           SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 4; --Father SSN 			= 4 points
          END
         ELSE
          BEGIN
           IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Last_NAME, '')))) > 0
                OR LEN(LTRIM(RTRIM(ISNULL(@Ac_FatherLast_NAME, '')))) > 0)
              AND @Lc_EstFatherDemo_Last_NAME = @Ac_FatherLast_NAME
            BEGIN
             SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 2; --Father Last Name 			= 2 points
            END

           IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_First_NAME, '')))) > 0
                OR LEN(LTRIM(RTRIM(ISNULL(@Ac_FatherFirst_NAME, '')))) > 0)
              AND @Lc_EstFatherDemo_First_NAME = @Ac_FatherFirst_NAME
            BEGIN
             SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 1; --Father First Name			= 1 point
            END

           IF (ISNULL(@Ld_EstFatherDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
                OR ISNULL(@Ad_FatherBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
              AND @Ld_EstFatherDemo_Birth_DATE = @Ad_FatherBirth_DATE
            BEGIN
             SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 2; --Father DOB 			= 2 points
            END
          END;

         UPDATE #MfpMatchPointQntyInfo_P1
            SET ParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPoint_QNTY
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
            AND MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO

         SELECT @Li_ParentFirstProcessChildDataMatchPoint_QNTY = MAX(ISNULL(A.ChildDataMatchPoint_QNTY, 0))
           FROM #MfpMatchPointQntyInfo_P1 A
          WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND A.MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
            AND A.MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO

SELECT TOP 1 @Ln_ChildDemo_MemberMci_IDNO = A.ChildMemberMci_IDNO
FROM #MfpMatchPointQntyInfo_P1 A
WHERE A.ChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY AND 
LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
          AND A.MotherMemberMci_IDNO = @Ln_DemoDupMtrCur_MemberMci_IDNO
          AND A.MotherCase_IDNO = @Ln_CaseDupMtrCur_Case_IDNO
ORDER BY A.ChildMemberMci_IDNO DESC

         IF(@Li_ParentFirstProcessChildDataMatchPoint_QNTY >= 4
            AND @Li_ParentFirstProcessParentDataMatchPoint_QNTY >= 4)
          BEGIN
           SET @Lc_MatchFound_INDC = 'Y';
           SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '');

           UPDATE #VappMappPointQntyInfo_P1
              SET ParentFirstProcessChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY,
                  ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPoint_QNTY,
                  MatchFound_INDC = @Lc_MatchFound_INDC
            WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID;

           IF(@Lb_UpdateMTRDemoVapp_BIT = 1)
            BEGIN
             SET @Ln_MotherDemo_MemberMci_IDNO = @An_MotherMemberMci_IDNO;
             SET @Lc_MotherDemo_Last_NAME = @Ac_MotherLast_NAME;
             SET @Lc_MotherDemo_First_NAME = @Ac_MotherFirst_NAME;
             SET @Lc_MotherDemo_Middle_NAME = @Lc_Empty_TEXT;
             SET @Lc_MotherDemo_Suffix_NAME = @Lc_Empty_TEXT;
            END

           IF(@Lb_UpdateFTRDemoVapp_BIT = 1)
            BEGIN
             SET @Ln_EstFatherDemo_MemberMci_IDNO = @An_FatherMemberMci_IDNO;
             SET @Lc_EstFatherDemo_Last_NAME = @Ac_FatherLast_NAME;
             SET @Lc_EstFatherDemo_First_NAME = @Ac_FatherFirst_NAME;
             SET @Lc_EstFatherDemo_Middle_NAME = @Lc_Empty_TEXT;
             SET @Lc_EstFatherDemo_Suffix_NAME = @Lc_Empty_TEXT;
            END

           IF(@Lb_UpdateDFTRDemoVapp_BIT = 1)
            BEGIN
             SET @Ln_DisEstFatherDemo_MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;
             SET @Lc_DisEstFatherDemo_Last_NAME = @Lc_VappCur_DisFatherLast_NAME;
             SET @Lc_DisEstFatherDemo_First_NAME = @Lc_VappCur_DisFatherFirst_NAME;
             SET @Lc_DisEstFatherDemo_Middle_NAME = @Lc_Empty_TEXT;
             SET @Lc_DisEstFatherDemo_Suffix_NAME = @Lc_Empty_TEXT;
            END

           IF NOT EXISTS(SELECT 1
                           FROM VAPP_Y1
                          WHERE TypeDocument_CODE = @Lc_DopTypeDocument_CODE
                            AND ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID)
            BEGIN
             SET @Ls_Sqldata_TEXT = '';

             SELECT @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
                    @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
                    @Lc_StateDisestablish_CODE = ' ';
            END
           ELSE
            BEGIN
             SET @Ls_Sql_TEXT = 'SET UPDATE MATCH DATA - 1'
             SET @Ls_Sqldata_TEXT = 'TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '');

             SELECT @Ld_DOPMotherSig_DATE = v.MotherSignature_DATE,
                    @Ld_DOPFatherSig_DATE = v.FatherSignature_DATE,
                    @Lc_StateDisestablish_CODE = 'DE',
                    @Lc_DisEstablishedFather_CODE = CASE
                                                     WHEN @Lb_UpdateDFTRDemoVapp_BIT = 1
                                                      THEN
                                                      CASE
                                                       WHEN ISNULL(v.FatherMemberMci_IDNO, 0) > 0
                                                        THEN
                                                        CASE
                                                         WHEN EXISTS (SELECT 1
                                                                        FROM CMEM_Y1 A
                                                                       WHERE A.MemberMci_IDNO = v.FatherMemberMci_IDNO)
                                                          THEN (SELECT ISNULL(A.CaseRelationship_CODE, 'O')
                                                                  FROM CMEM_Y1 A
                                                                 WHERE A.MemberMci_IDNO = v.FatherMemberMci_IDNO)
                                                         ELSE 'O'
                                                        END
                                                       ELSE 'O'
                                                      END
                                                     ELSE ' '
                                                    END
               FROM VAPP_Y1 v
              WHERE TypeDocument_CODE = @Lc_DopTypeDocument_CODE
                AND ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID;
            END

           IF(@Ad_MotherSignature_DATE > @Ad_FatherSignature_DATE)
            BEGIN
             SET @Ld_UpdateEstDate_DATE = @Ad_MotherSignature_DATE;
            END
           ELSE
            SET @Ld_UpdateEstDate_DATE = @Ad_FatherSignature_DATE;

           IF(@Ld_DOPMotherSig_DATE > @Ld_DOPFatherSig_DATE)
            BEGIN
             IF(@Ld_DOPMotherSig_DATE > @Ld_UpdateEstDate_DATE)
              BEGIN
               SET @Ld_UpdateEstDate_DATE = @Ld_DOPMotherSig_DATE;
              END

             SET @Ld_Disestablish_DATE = @Ld_DOPMotherSig_DATE;
            END
           ELSE
            BEGIN
             IF(@Ld_DOPFatherSig_DATE > @Ld_UpdateEstDate_DATE)
              BEGIN
               SET @Ld_UpdateEstDate_DATE = @Ld_DOPFatherSig_DATE;
              END

             SET @Ld_Disestablish_DATE = @Ld_DOPFatherSig_DATE;
            END

           SELECT @Ln_EstFatherDemo_MemberMci_IDNO = CASE
                                                      WHEN ISNULL(@Ln_EstFatherDemo_MemberMci_IDNO, 0) = 0
                                                       THEN @An_FatherMemberMci_IDNO
                                                      ELSE @Ln_EstFatherDemo_MemberMci_IDNO
                                                     END,
                  @Lc_EstFatherDemo_Last_NAME = CASE
                                                 WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Last_NAME, '')))) = 0
                                                  THEN @Ac_FatherLast_NAME
                                                 ELSE @Lc_EstFatherDemo_Last_NAME
                                                END,
                  @Lc_EstFatherDemo_First_NAME = CASE
                                                  WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_First_NAME, '')))) = 0
                                                   THEN @Ac_FatherFirst_NAME
                                                  ELSE @Lc_EstFatherDemo_First_NAME
                                                 END,
                  @Lc_EstFatherDemo_Middle_NAME = CASE
                                                   WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Middle_NAME, '')))) = 0
                                                    THEN @Lc_Empty_TEXT
                                                   ELSE @Lc_EstFatherDemo_Middle_NAME
                                                  END,
                  @Lc_EstFatherDemo_Suffix_NAME = CASE
                                                   WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Suffix_NAME, '')))) = 0
                                                    THEN @Lc_Empty_TEXT
                                                   ELSE @Lc_EstFatherDemo_Suffix_NAME
                                                  END,
                  @Lc_EFTRCaseRelationship_CODE = CASE
                                                   WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EFTRCaseRelationship_CODE, '')))) = 0
                                                    THEN 'O'
                                                   ELSE @Lc_EFTRCaseRelationship_CODE
                                                  END,
                  @Ln_MotherDemo_MemberMci_IDNO = CASE
                                                   WHEN ISNULL(@Ln_MotherDemo_MemberMci_IDNO, 0) = 0
                                                    THEN @An_MotherMemberMci_IDNO
                                                   ELSE @Ln_MotherDemo_MemberMci_IDNO
                                                  END,
                  @Lc_MotherDemo_Last_NAME = CASE
                                              WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Last_NAME, '')))) = 0
                                               THEN @Ac_MotherLast_NAME
                                              ELSE @Lc_MotherDemo_Last_NAME
                                             END,
                  @Lc_MotherDemo_First_NAME = CASE
                                               WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_First_NAME, '')))) = 0
                                                THEN @Ac_MotherFirst_NAME
                                               ELSE @Lc_MotherDemo_First_NAME
                                              END,
                  @Lc_MotherDemo_Middle_NAME = CASE
                                                WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Middle_NAME, '')))) = 0
                                                 THEN @Lc_Empty_TEXT
                                                ELSE @Lc_MotherDemo_Middle_NAME
                                               END,
                  @Lc_MotherDemo_Suffix_NAME = CASE
                                                WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Suffix_NAME, '')))) = 0
                                                 THEN @Lc_Empty_TEXT
                                                ELSE @Lc_MotherDemo_Suffix_NAME
                                               END,
                  @Lc_MTRCaseRelationship_CODE = CASE
                                                  WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MTRCaseRelationship_CODE, '')))) = 0
                                                   THEN 'O'
                                                  ELSE @Lc_MTRCaseRelationship_CODE
                                                 END,
                  @Ln_DisEstFatherDemo_MemberMci_IDNO = CASE
                                                         WHEN ISNULL(@Ln_DisEstFatherDemo_MemberMci_IDNO, 0) = 0
                                                          THEN @Ln_VappCur_DisFatherMemberMci_IDNO
                                                         ELSE @Ln_DisEstFatherDemo_MemberMci_IDNO
                                                        END,
                  @Lc_DisEstFatherDemo_Last_NAME = CASE
                                                    WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Last_NAME, '')))) = 0
                                                     THEN @Lc_VappCur_DisFatherLast_NAME
                                                    ELSE @Lc_DisEstFatherDemo_Last_NAME
                                                   END,
                  @Lc_DisEstFatherDemo_First_NAME = CASE
                                                     WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_First_NAME, '')))) = 0
                                                      THEN @Lc_VappCur_DisFatherFirst_NAME
                                                     ELSE @Lc_DisEstFatherDemo_First_NAME
                                                    END,
                  @Lc_DisEstFatherDemo_Middle_NAME = CASE
                                                      WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Middle_NAME, '')))) = 0
                                                       THEN @Lc_Empty_TEXT
                                                      ELSE @Lc_DisEstFatherDemo_Middle_NAME
                                                     END,
                  @Lc_DisEstFatherDemo_Suffix_NAME = CASE
                                                      WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Suffix_NAME, '')))) = 0
                                                       THEN @Lc_Empty_TEXT
                                                      ELSE @Lc_DisEstFatherDemo_Suffix_NAME
                                                     END

           SET @Ls_Sql_TEXT = 'BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH - 1';
           SET @Ls_Sqldata_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildDemo_MemberMci_IDNO AS VARCHAR), '') + ', EstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_EstFatherDemo_MemberMci_IDNO AS VARCHAR), '') + ', DisEstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_DisEstFatherDemo_MemberMci_IDNO AS VARCHAR), '') + ', EstablishedMotherMci_IDNO = ' + ISNULL(CAST(@Ln_MotherDemo_MemberMci_IDNO AS VARCHAR), '') + ', DopAttached_CODE = ' + ISNULL(@Ac_DopAttached_CODE, '') + ', EstablishedMother_CODE = ' + ISNULL(@Lc_MTRCaseRelationship_CODE, '') + ', EstablishedFather_CODE = ' + ISNULL(@Lc_EFTRCaseRelationship_CODE, '') + ', DisEstablishedFather_CODE = ' + ISNULL(@Lc_DisEstablishedFather_CODE, '') + ', EstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_EstFatherDemo_Suffix_NAME, '') + ', DisEstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Suffix_NAME, '') + ', EstablishedMotherSuffix_NAME = ' + ISNULL(@Lc_MotherDemo_Suffix_NAME, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', EstablishedFatherFirst_NAME = ' + ISNULL(@Lc_EstFatherDemo_First_NAME, '') + ', DisEstablishedFatherFirst_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_First_NAME, '') + ', EstablishedMotherFirst_NAME = ' + ISNULL(@Lc_MotherDemo_First_NAME, '') + ', EstablishedFatherLast_NAME = ' + ISNULL(@Lc_EstFatherDemo_Last_NAME, '') + ', EstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_EstFatherDemo_Middle_NAME, '') + ', DisEstablishedFatherLast_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Last_NAME, '') + ', DisEstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Middle_NAME, '') + ', EstablishedMotherLast_NAME = ' + ISNULL(@Lc_MotherDemo_Last_NAME, '') + ', EstablishedMotherMiddle_NAME = ' + ISNULL(@Lc_MotherDemo_Middle_NAME, '') + ', PaternityEst_DATE = ' + ISNULL(CAST(@Ld_UpdateEstDate_DATE AS VARCHAR), '') + ', Disestablish_DATE = ' + ISNULL(CAST(@Ld_Disestablish_DATE AS VARCHAR), '') + ', StateDisestablish_CODE = ' + ISNULL(@Lc_StateDisestablish_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

           EXECUTE BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH
            @Ac_Job_ID                          = @Lc_Job_ID,
            @An_ChildMemberMci_IDNO             = @Ln_ChildDemo_MemberMci_IDNO,
            @An_EstablishedFatherMci_IDNO       = @Ln_EstFatherDemo_MemberMci_IDNO,
            @An_DisEstablishedFatherMci_IDNO    = @Ln_DisEstFatherDemo_MemberMci_IDNO,
            @An_EstablishedMotherMci_IDNO       = @Ln_MotherDemo_MemberMci_IDNO,
            @Ac_DopAttached_CODE                = @Ac_DopAttached_CODE,
            @Ac_EstablishedMother_CODE          = @Lc_MTRCaseRelationship_CODE,
            @Ac_EstablishedFather_CODE          = @Lc_EFTRCaseRelationship_CODE,
            @Ac_DisEstablishedFather_CODE       = @Lc_DisEstablishedFather_CODE,
            @Ac_EstablishedFatherSuffix_NAME    = @Lc_EstFatherDemo_Suffix_NAME,
            @Ac_DisEstablishedFatherSuffix_NAME = @Lc_DisEstFatherDemo_Suffix_NAME,
            @Ac_EstablishedMotherSuffix_NAME    = @Lc_MotherDemo_Suffix_NAME,
            @Ac_ChildBirthCertificate_ID        = @Ac_ChildBirthCertificate_ID,
            @Ac_EstablishedFatherFirst_NAME     = @Lc_EstFatherDemo_First_NAME,
            @Ac_DisEstablishedFatherFirst_NAME  = @Lc_DisEstFatherDemo_First_NAME,
            @Ac_EstablishedMotherFirst_NAME     = @Lc_MotherDemo_First_NAME,
            @Ac_EstablishedFatherLast_NAME      = @Lc_EstFatherDemo_Last_NAME,
            @Ac_EstablishedFatherMiddle_NAME    = @Lc_EstFatherDemo_Middle_NAME,
            @Ac_DisEstablishedFatherLast_NAME   = @Lc_DisEstFatherDemo_Last_NAME,
            @Ac_DisEstablishedFatherMiddle_NAME = @Lc_DisEstFatherDemo_Middle_NAME,
            @Ac_EstablishedMotherLast_NAME      = @Lc_MotherDemo_Last_NAME,
            @Ac_EstablishedMotherMiddle_NAME    = @Lc_MotherDemo_Middle_NAME,
            @Ad_PaternityEst_DATE               = @Ld_UpdateEstDate_DATE,
            @Ad_Disestablish_DATE               = @Ld_Disestablish_DATE,
            @Ac_StateDisestablish_CODE          = @Lc_StateDisestablish_CODE,
            @Ad_Run_DATE                        = @Ad_Run_DATE,
            @Ac_Msg_CODE                        = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT           = @Ls_DescriptionError_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

             RAISERROR(50001,16,1);
            END

           CLOSE CaseDupMtr_CUR;

           DEALLOCATE CaseDupMtr_CUR;

           CLOSE DemoDupMtr_CUR;

           DEALLOCATE DemoDupMtr_CUR;

           GOTO EXIT_MFP_DUPLICATE_LOOP;
          END

         SET @Ls_Sql_TEXT ='FETCH NEXT CaseDupMtr_CUR 2';

         FETCH NEXT FROM CaseDupMtr_CUR INTO @Ln_CaseDupMtrCur_Case_IDNO;

         SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE CaseDupMtr_CUR;

       DEALLOCATE CaseDupMtr_CUR;

       SET @Ls_Sql_TEXT ='FETCH NEXT DemoDupMtr_CUR 2';

       FETCH NEXT FROM DemoDupMtr_CUR INTO @Ln_DemoDupMtrCur_MemberMci_IDNO;

       SET @Li_DemoFetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE DemoDupMtr_CUR;

     DEALLOCATE DemoDupMtr_CUR;

     EXIT_MFP_DUPLICATE_LOOP:;

     SET @Ls_Sql_TEXT = 'SELECT #VappMappPointQntyInfo_P1';
     SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '');

     SELECT @Li_ParentFirstProcessChildDataMatchPoint_QNTY = A.ParentFirstProcessChildDataMatchPoint_QNTY,
            @Li_ParentFirstProcessParentDataMatchPoint_QNTY = A.ParentFirstProcessParentDataMatchPoint_QNTY,
            @Lc_MatchFound_INDC = A.MatchFound_INDC
       FROM #VappMappPointQntyInfo_P1 A
      WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID;

     IF @Lc_MatchFound_INDC = 'Y'
        AND @Li_ParentFirstProcessChildDataMatchPoint_QNTY >= 4
        AND @Li_ParentFirstProcessParentDataMatchPoint_QNTY >= 4
      BEGIN
       SET @Ac_Goto_CODE = 'NEXT_RECORD';

       GOTO END_MOTHER_PROCESS;
      END
     ELSE
      BEGIN
       SET @Ac_Goto_CODE = 'BEGIN_FATHER_PROCESS';

       GOTO END_MOTHER_PROCESS;
      END;
    END
   ELSE
    BEGIN
     SELECT @Ln_CaseSglMtrCur_Case_IDNO = 0,
            @Li_CaseFetchStatus_QNTY = -1,
            @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
            @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
            @Lc_MatchFound_INDC = @Lc_No_INDC

     SET @Ls_Sql_TEXT ='SET CaseSglMtr_CUR 2';

     DECLARE CaseSglMtr_CUR INSENSITIVE CURSOR FOR
      SELECT c.Case_IDNO
        FROM CMEM_Y1 c
       WHERE c.MemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
         AND c.CaseRelationship_CODE <> 'D'
         AND c.CaseMemberStatus_CODE = 'A'
         AND EXISTS (SELECT 1
                       FROM CASE_Y1 X
                      WHERE X.Case_IDNO = c.Case_IDNO
                        AND X.StatusCase_CODE = 'O');

     SET @Ls_Sql_TEXT ='OPEN CaseSglMtr_CUR 2';

     OPEN CaseSglMtr_CUR;

     SET @Ls_Sql_TEXT ='FETCH CaseSglMtr_CUR 2';

     FETCH NEXT FROM CaseSglMtr_CUR INTO @Ln_CaseSglMtrCur_Case_IDNO;

     SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT ='WHILE CaseSglMtr_CUR 2';

     --WHILE CaseSglMtr_CUR 2
     WHILE @Li_CaseFetchStatus_QNTY = 0
           AND @Lc_MatchFound_INDC = 'N'
      BEGIN
       IF EXISTS(SELECT 1
                   FROM #MfpMatchPointQntyInfo_P1 A
                  WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                    AND A.MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
                    AND A.MotherCase_IDNO IS NULL)
        BEGIN
         UPDATE #MfpMatchPointQntyInfo_P1
            SET MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
        END
       ELSE
        BEGIN
         INSERT INTO #MfpMatchPointQntyInfo_P1
                     (ChildBirthCertificate_ID,
                      MotherMemberMci_IDNO,
                      MotherLast_NAME,
                      MotherFirst_NAME,
                      MotherMemberSsn_NUMB,
                      MotherCase_IDNO,
                      MotherDataMatchPoint_QNTY)
         SELECT TOP 1 A.ChildBirthCertificate_ID,
                      A.MotherMemberMci_IDNO,
                      A.MotherLast_NAME,
                      A.MotherFirst_NAME,
                      A.MotherMemberSsn_NUMB,
                      @Ln_CaseSglMtrCur_Case_IDNO AS MotherCase_IDNO,
                      A.MotherDataMatchPoint_QNTY
           FROM #MfpMatchPointQntyInfo_P1 A
          WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND A.MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
        END

       SELECT @Ln_DepSglMtrCur_MemberMci_IDNO = 0,
              @Lc_DepSglMtrCur_CPRelChild_CODE = '',
              @Lc_DepSglMtrCur_NCPRelChild_CODE = '',
              @Li_DepandantFetchStatus_QNTY = -1,
              @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
              @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
              @Lc_MatchFound_INDC = @Lc_No_INDC

       SET @Ls_Sql_TEXT ='SET DepSglMtr_CUR 2';

       DECLARE DepSglMtr_CUR INSENSITIVE CURSOR FOR
        SELECT c.MemberMci_IDNO,
               c.CpRelationshipToChild_CODE,
               c.NcpRelationshipToChild_CODE
          FROM CMEM_Y1 c
         WHERE c.Case_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
           AND c.CaseRelationship_CODE = @Lc_DepCaseRelationship_CODE
           AND c.CaseMemberStatus_CODE = 'A';

       SET @Ls_Sql_TEXT ='OPEN DepSglMtr_CUR 2';

       OPEN DepSglMtr_CUR;

       SET @Ls_Sql_TEXT ='FETCH DepSglMtr_CUR 2';

       FETCH NEXT FROM DepSglMtr_CUR INTO @Ln_DepSglMtrCur_MemberMci_IDNO, @Lc_DepSglMtrCur_CPRelChild_CODE, @Lc_DepSglMtrCur_NCPRelChild_CODE;

       SET @Li_DepandantFetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT ='WHILE DepSglMtr_CUR 2';

       -- Process each depandant
       WHILE @Li_DepandantFetchStatus_QNTY = 0
        BEGIN
         SELECT @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
                @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
                @Lc_MatchFound_INDC = @Lc_No_INDC

         IF EXISTS(SELECT 1
                     FROM #MfpMatchPointQntyInfo_P1 A
                    WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                      AND A.MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
                      AND A.MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
                      AND A.ChildMemberMci_IDNO IS NULL)
          BEGIN
           UPDATE #MfpMatchPointQntyInfo_P1
              SET ChildMemberMci_IDNO = @Ln_DepSglMtrCur_MemberMci_IDNO,
                  CpRelationshipToChild_CODE = @Lc_DepSglMtrCur_CPRelChild_CODE,
                  NcpRelationshipToChild_CODE = @Lc_DepSglMtrCur_NCPRelChild_CODE
            WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
              AND MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
          END
         ELSE
          BEGIN
           INSERT INTO #MfpMatchPointQntyInfo_P1
                       (ChildBirthCertificate_ID,
                        MotherMemberMci_IDNO,
                        MotherLast_NAME,
                        MotherFirst_NAME,
                        MotherMemberSsn_NUMB,
                        MotherCase_IDNO,
                        ChildMemberMci_IDNO,
                        CpRelationshipToChild_CODE,
                        NcpRelationshipToChild_CODE,
                        MotherDataMatchPoint_QNTY)
           SELECT TOP 1 A.ChildBirthCertificate_ID,
                        A.MotherMemberMci_IDNO,
                        A.MotherLast_NAME,
                        A.MotherFirst_NAME,
                        A.MotherMemberSsn_NUMB,
                        A.MotherCase_IDNO,
                        @Ln_DepSglMtrCur_MemberMci_IDNO AS ChildMemberMci_IDNO,
                        @Lc_DepSglMtrCur_CPRelChild_CODE AS CpRelationshipToChild_CODE,
                        @Lc_DepSglMtrCur_NCPRelChild_CODE AS NcpRelationshipToChild_CODE,
                        A.MotherDataMatchPoint_QNTY
             FROM #MfpMatchPointQntyInfo_P1 A
            WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND A.MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
              AND A.MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
          END

         SET @Ln_ChildPointsCounter_NUMB =0;
         SET @Ls_Sql_TEXT = 'Select DEMO details of Dependant 1';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DepSglMtrCur_MemberMci_IDNO AS VARCHAR), '');

         SELECT @Ln_ChildDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                @Ln_ChildDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                @Lc_ChildDemo_BirthCertificate_ID = ISNULL((SELECT ISNULL(x.BirthCertificate_ID, '')
                                                              FROM MPAT_Y1 x
                                                             WHERE x.MemberMci_IDNO = d.MemberMci_IDNO), ''),
                @Lc_ChildDemo_Last_NAME = d.Last_NAME,
                @Lc_ChildDemo_First_NAME = d.First_NAME,
                @Ld_ChildDemo_Birth_DATE = d.Birth_DATE
           FROM DEMO_Y1 d
          WHERE d.MemberMci_IDNO = @Ln_DepSglMtrCur_MemberMci_IDNO;

         UPDATE #MfpMatchPointQntyInfo_P1
            SET ChildLast_NAME = @Lc_ChildDemo_Last_NAME,
                ChildFirst_NAME = @Lc_ChildDemo_First_NAME,
                ChildBirth_DATE = @Ld_ChildDemo_Birth_DATE,
                ChildMemberSsn_NUMB = @Ln_ChildDemo_MemberSsn_NUMB,
                ChildDemoBirthCertificate_ID = @Lc_ChildDemo_BirthCertificate_ID
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
            AND MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
            AND ChildMemberMci_IDNO = @Ln_DepSglMtrCur_MemberMci_IDNO

         IF((ISNULL(@An_ChildMemberMci_IDNO, 0) > 0
              OR ISNULL(@Ln_ChildDemo_MemberMci_IDNO, 0) > 0)
            AND @An_ChildMemberMci_IDNO = @Ln_ChildDemo_MemberMci_IDNO)
          BEGIN
           SET @Ln_ChildPointsCounter_NUMB = @Ln_ChildPointsCounter_NUMB + @Ln_FourPoints_NUMB;
           SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 4; --MCI 				= 4 points
          END
         ELSE IF ((LEN(LTRIM(RTRIM(ISNULL(@Ac_ChildBirthCertificate_ID, '')))) > 0
               OR LEN(LTRIM(RTRIM(ISNULL(@Lc_ChildDemo_BirthCertificate_ID, '')))) > 0)
             AND @Ac_ChildBirthCertificate_ID = @Lc_ChildDemo_BirthCertificate_ID)
          BEGIN
           SET @Ln_ChildPointsCounter_NUMB = @Ln_ChildPointsCounter_NUMB + @Ln_FourPoints_NUMB;
           SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 4; --Birth Certificate 			= 4 points					
          END
         ELSE IF ((ISNULL(@An_ChildMemberSsn_NUMB, 0) > 0
               OR ISNULL(@Ln_ChildDemo_MemberSsn_NUMB, 0) > 0)
             AND @An_ChildMemberSsn_NUMB = @Ln_ChildDemo_MemberSsn_NUMB)
          BEGIN
           SET @Ln_ChildPointsCounter_NUMB = @Ln_ChildPointsCounter_NUMB + @Ln_FourPoints_NUMB;
           SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 4; --SSN 				= 4 points				
          END
         ELSE
          BEGIN
           IF (LEN(LTRIM(RTRIM(ISNULL(@Ac_ChildLast_NAME, '')))) > 0
                OR LEN(LTRIM(RTRIM(ISNULL(@Lc_ChildDemo_Last_NAME, '')))) > 0)
              AND @Ac_ChildLast_NAME = @Lc_ChildDemo_Last_NAME
            BEGIN
             SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 2; --Last Name 				= 2 points
            END

           IF (LEN(LTRIM(RTRIM(ISNULL(@Ac_ChildFirst_NAME, '')))) > 0
                OR LEN(LTRIM(RTRIM(ISNULL(@Lc_ChildDemo_First_NAME, '')))) > 0)
              AND @Ac_ChildFirst_NAME = @Lc_ChildDemo_First_NAME
            BEGIN
             SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 1; --First Name				= 1 point
            END

           IF (ISNULL(@Ad_ChildBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
                OR ISNULL(@Ld_ChildDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
              AND @Ad_ChildBirth_DATE = @Ld_ChildDemo_Birth_DATE
            BEGIN
             SET @Li_ParentFirstProcessChildDataMatchPoint_QNTY += 2; --DOB 				= 2 points
            END
          END;

         UPDATE #MfpMatchPointQntyInfo_P1
            SET ChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
            AND MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
            AND ChildMemberMci_IDNO = @Ln_DepSglMtrCur_MemberMci_IDNO

         SET @Ls_Sql_TEXT ='FETCH NEXT DepSglMtr_CUR 2';

         FETCH NEXT FROM DepSglMtr_CUR INTO @Ln_DepSglMtrCur_MemberMci_IDNO, @Lc_DepSglMtrCur_CPRelChild_CODE, @Lc_DepSglMtrCur_NCPRelChild_CODE;

         SET @Li_DepandantFetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE DepSglMtr_CUR;

       DEALLOCATE DepSglMtr_CUR;

       NEXTPRT1:;

       SELECT @Ln_ParSglMtrCur_MemberMci_IDNO = 0,
              @Lc_ParSglMtrCur_CaseRelationship_CODE = '',
              @Lc_ParSglMtrCur_MemberSex_CODE = '',
              @Li_ParentFetchStatus_QNTY = -1,
              @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointMother_QNTY,
              @Lc_MatchFound_INDC = @Lc_No_INDC

         SELECT @Lc_MTRCaseRelationship_CODE = '',
                @Ln_MotherDemo_MemberMci_IDNO = 0,
                @Ln_MotherDemo_MemberSsn_NUMB = 0,
                @Lc_MotherDemo_Last_NAME = '',
                @Lc_MotherDemo_First_NAME = '',
                @Lc_MotherDemo_Middle_NAME = '',
                @Lc_MotherDemo_Suffix_NAME = '',
                @Ld_MotherDemo_Birth_DATE = @Ld_Low_DATE,
                @Ln_RowsCount_QNTY = 0,
                @Lb_UpdateMTRDemoVapp_BIT = 0,
                @Lc_EFTRCaseRelationship_CODE = '',
                @Ln_EstFatherDemo_MemberMci_IDNO = 0,
                @Ln_EstFatherDemo_MemberSsn_NUMB = 0,
                @Lc_EstFatherDemo_Last_NAME = '',
                @Lc_EstFatherDemo_First_NAME = '',
                @Lc_EstFatherDemo_Middle_NAME = '',
                @Lc_EstFatherDemo_Suffix_NAME = '',
                @Ld_EstFatherDemo_Birth_DATE = @Ld_Low_DATE,
                @Lb_UpdateFTRDemoVapp_BIT = 0,
                @Ln_VappCur_DisFatherMemberMci_IDNO = 0,
                @Lc_VappCur_DisFatherLast_NAME = '',
                @Lc_VappCur_DisFatherFirst_NAME = '',
                @Ld_VappCur_DisFatherBirth_DATE = @Ld_Low_DATE,
                @Ln_VappCur_DisFatherMemberSsn_NUMB = 0,
                @Ln_DisEstFatherDemo_MemberMci_IDNO = 0,
                @Lc_DisEstFatherDemo_Last_NAME = '',
                @Lc_DisEstFatherDemo_First_NAME = '',
                @Lc_DisEstFatherDemo_Middle_NAME = '',
                @Lc_DisEstFatherDemo_Suffix_NAME = '',
                @Lb_UpdateDFTRDemoVapp_BIT = 0,
                @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
                @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
                @Lc_StateDisestablish_CODE = '',
                @Lc_DisEstablishedFather_CODE = '',
                @Ld_UpdateEstDate_DATE = @Ld_Low_DATE,
                @Ld_Disestablish_DATE = @Ld_Low_DATE

       SET @Ln_ParentPointsCounter_NUMB = 0;
       SET @Ls_Sql_TEXT ='SET ParSglMtr_CUR 2';

       DECLARE ParSglMtr_CUR INSENSITIVE CURSOR FOR
        SELECT c.MemberMci_IDNO,
               c.CaseRelationship_CODE,
               d.MemberSex_CODE
          FROM CMEM_Y1 c
               JOIN DEMO_Y1 d
                ON c.MemberMci_IDNO = d.MemberMci_IDNO
         WHERE Case_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
           AND CaseRelationship_CODE IN (@Lc_CPCaseRelationship_CODE, @Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
           AND CaseMemberStatus_CODE = 'A';

       SET @Ls_Sql_TEXT ='OPEN ParSglMtr_CUR 2';

       OPEN ParSglMtr_CUR;

       SET @Ls_Sql_TEXT ='FETCH ParSglMtr_CUR 2';

       FETCH NEXT FROM ParSglMtr_CUR INTO @Ln_ParSglMtrCur_MemberMci_IDNO, @Lc_ParSglMtrCur_CaseRelationship_CODE, @Lc_ParSglMtrCur_MemberSex_CODE;

       SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT ='WHILE Parent_CUR 2';

       -- Process parents records from the matched case of the dependant
       WHILE @Li_ParentFetchStatus_QNTY = 0
        BEGIN
         IF(@Lc_DepSglMtrCur_CPRelChild_CODE = @Lc_Relation_Mother_CODE
            AND @Lc_ParSglMtrCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
            AND @Lc_ParSglMtrCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
          BEGIN
           SET @Lc_MTRCaseRelationship_CODE = @Lc_ParSglMtrCur_CaseRelationship_CODE;
           SET @Ls_Sql_TEXT ='Select Mother details from DEMO 2';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglMtrCur_MemberMci_IDNO AS VARCHAR), '');

           SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                  @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                  @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                  @Lc_MotherDemo_First_NAME = d.First_NAME,
                  @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                  @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                  @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
             FROM DEMO_Y1 d
            WHERE d.MemberMci_IDNO = @Ln_ParSglMtrCur_MemberMci_IDNO;

           SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

           IF(@Ln_RowsCount_QNTY = 0)
            BEGIN
             SET @Lb_UpdateMTRDemoVapp_BIT = 1;
            END
          END
         ELSE IF(@Lc_DepSglMtrCur_CPRelChild_CODE = @Lc_Relation_Father_CODE
            AND @Lc_ParSglMtrCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
            AND @Lc_ParSglMtrCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
          BEGIN
           SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParSglMtrCur_CaseRelationship_CODE;

           IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
            BEGIN
             SET @Ls_Sql_TEXT ='Select EstFather details from DEMO 2';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglMtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParSglMtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateFTRDemoVapp_BIT =1;
              END

             SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Father First Process 2';
             SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

             SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                    @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                    @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                    @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                    @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
               FROM VAPP_Y1 v
              WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
                AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

             SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 2';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_DisFatherMemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_DisEstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Lc_DisEstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_DisEstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_DisEstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_DisEstFatherDemo_Suffix_NAME = d.Suffix_NAME
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateDFTRDemoVapp_BIT =1;
              END
            END
           ELSE IF (@Ac_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
            BEGIN
             SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 3';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglMtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParSglMtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateFTRDemoVapp_BIT =1;
              END
            END
          END

         IF(@Lc_DepSglMtrCur_NCPRelChild_CODE = @Lc_Relation_Mother_CODE
            AND @Lc_ParSglMtrCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
            AND @Lc_ParSglMtrCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
          BEGIN
           SET @Lc_MTRCaseRelationship_CODE = @Lc_ParSglMtrCur_CaseRelationship_CODE;
           SET @Ls_Sql_TEXT ='Select Mother details from DEMO 3';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglMtrCur_MemberMci_IDNO AS VARCHAR), '');

           SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                  @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                  @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                  @Lc_MotherDemo_First_NAME = d.First_NAME,
                  @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                  @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                  @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
             FROM DEMO_Y1 d
            WHERE d.MemberMci_IDNO = @Ln_ParSglMtrCur_MemberMci_IDNO;

           SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

           IF(@Ln_RowsCount_QNTY = 0)
            BEGIN
             SET @Lb_UpdateMTRDemoVapp_BIT =1;
            END
          END
         ELSE IF(@Lc_DepSglMtrCur_NCPRelChild_CODE = @Lc_Relation_Father_CODE
            AND @Lc_ParSglMtrCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
            AND @Lc_ParSglMtrCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
          BEGIN
           SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParSglMtrCur_CaseRelationship_CODE;

           IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
            BEGIN
             SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 4';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglMtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParSglMtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateFTRDemoVapp_BIT =1;
              END

             SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Father First Process 3';
             SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

             SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                    @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                    @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                    @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                    @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
               FROM VAPP_Y1 v
              WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
                AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

             SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 3';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_VappCur_DisFatherMemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_DisEstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Lc_DisEstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_DisEstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_DisEstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_DisEstFatherDemo_Suffix_NAME = d.Suffix_NAME
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateDFTRDemoVapp_BIT =1;
              END
            END
           ELSE IF (@Ac_DopAttached_CODE = @Lc_DOPAttachedNo_CODE)
            BEGIN
             SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 5';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglMtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParSglMtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateFTRDemoVapp_BIT =1;
              END
            END
          END

         SET @Ls_Sql_TEXT ='FETCH NEXT ParSglMtr_CUR 2';

         FETCH NEXT FROM ParSglMtr_CUR INTO @Ln_ParSglMtrCur_MemberMci_IDNO, @Lc_ParSglMtrCur_CaseRelationship_CODE, @Lc_ParSglMtrCur_MemberSex_CODE;

         SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE ParSglMtr_CUR;

       DEALLOCATE ParSglMtr_CUR;

       SET @Ls_Sql_TEXT ='Verify NCP Mother details with DEMO in Father First Process 2';

       IF((ISNULL(@Ln_MotherDemo_MemberMci_IDNO, 0) > 0
            OR ISNULL(@An_MotherMemberMci_IDNO, 0) > 0)
          AND @Ln_MotherDemo_MemberMci_IDNO = @An_MotherMemberMci_IDNO)
        BEGIN
         SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
         SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 4; --Mother MCI 			= 4 points
        END
       ELSE IF ((ISNULL(@Ln_MotherDemo_MemberSsn_NUMB, 0) > 0
             OR ISNULL(@An_MotherMemberSsn_NUMB, 0) > 0)
           AND @Ln_MotherDemo_MemberSsn_NUMB = @An_MotherMemberSsn_NUMB)
        BEGIN
         SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
         SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 4; --Mother SSN 			= 4 points					
        END
       ELSE
        BEGIN
         IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Last_NAME, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Ac_MotherLast_NAME, '')))) > 0)
            AND @Lc_MotherDemo_Last_NAME = @Ac_MotherLast_NAME
          BEGIN
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 2; --Mother Last Name 			= 2 points
          END

         IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_First_NAME, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Ac_MotherFirst_NAME, '')))) > 0)
            AND @Lc_MotherDemo_First_NAME = @Ac_MotherFirst_NAME
          BEGIN
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 1; --Mother First Name			= 1 point
          END

         IF (ISNULL(@Ld_MotherDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
              OR ISNULL(@Ad_MotherBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
            AND @Ld_MotherDemo_Birth_DATE = @Ad_MotherBirth_DATE
          BEGIN
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 2; --Mother DOB 			= 2 points
          END
        END;

       SET @Ls_Sql_TEXT ='Verify NCP EstFather details with DEMO in Father First Process 2';

       IF((ISNULL(@Ln_EstFatherDemo_MemberMci_IDNO, 0) > 0
            OR ISNULL(@An_FatherMemberMci_IDNO, 0) > 0)
          AND @Ln_EstFatherDemo_MemberMci_IDNO = @An_FatherMemberMci_IDNO)
        BEGIN
         SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
         SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 4; --Father MCI	 			= 4 points
        END
       ELSE IF ((ISNULL(@Ln_EstFatherDemo_MemberSsn_NUMB, 0) > 0
             OR ISNULL(@An_FatherMemberSsn_NUMB, 0) > 0)
           AND @Ln_EstFatherDemo_MemberSsn_NUMB = @An_FatherMemberSsn_NUMB)
        BEGIN
         SET @Ln_ParentPointsCounter_NUMB = @Ln_ParentPointsCounter_NUMB + @Ln_FourPoints_NUMB;
         SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 4; --Father SSN 			= 4 points					
        END
       ELSE
        BEGIN
         IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Last_NAME, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Ac_FatherLast_NAME, '')))) > 0)
            AND @Lc_EstFatherDemo_Last_NAME = @Ac_FatherLast_NAME
          BEGIN
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 2; --Father Last Name 			= 2 points
          END

         IF (LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_First_NAME, '')))) > 0
              OR LEN(LTRIM(RTRIM(ISNULL(@Ac_FatherFirst_NAME, '')))) > 0)
            AND @Lc_EstFatherDemo_First_NAME = @Ac_FatherFirst_NAME
          BEGIN
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 1; --Father First Name			= 1 point
          END

         IF (ISNULL(@Ld_EstFatherDemo_Birth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE)
              OR ISNULL(@Ad_FatherBirth_DATE, '') NOT IN (@Ld_High_DATE, '01/01/1900', @Ld_Low_DATE))
            AND @Ld_EstFatherDemo_Birth_DATE = @Ad_FatherBirth_DATE
          BEGIN
           SET @Li_ParentFirstProcessParentDataMatchPoint_QNTY += 2; --Father DOB 			= 2 points
          END
        END;

       UPDATE #MfpMatchPointQntyInfo_P1
          SET ParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPoint_QNTY
        WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
          AND MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
          AND MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO

       SELECT @Li_ParentFirstProcessChildDataMatchPoint_QNTY = MAX(ISNULL(A.ChildDataMatchPoint_QNTY, 0))
         FROM #MfpMatchPointQntyInfo_P1 A
        WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
          AND A.MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
          AND A.MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO

SELECT TOP 1 @Ln_ChildDemo_MemberMci_IDNO = A.ChildMemberMci_IDNO
FROM #MfpMatchPointQntyInfo_P1 A
WHERE A.ChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY AND 
LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
          AND A.MotherMemberMci_IDNO = @Ln_MotherDemo_MemberMci_IDNO
          AND A.MotherCase_IDNO = @Ln_CaseSglMtrCur_Case_IDNO
ORDER BY A.ChildMemberMci_IDNO DESC

       IF(@Li_ParentFirstProcessChildDataMatchPoint_QNTY >= 4
          AND @Li_ParentFirstProcessParentDataMatchPoint_QNTY >= 4)
        BEGIN
         SET @Lc_MatchFound_INDC = 'Y';
         SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '');

         UPDATE #VappMappPointQntyInfo_P1
            SET ParentFirstProcessChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY,
                ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPoint_QNTY,
                MatchFound_INDC = @Lc_MatchFound_INDC
          WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID;

         IF(@Lb_UpdateMTRDemoVapp_BIT = 1)
          BEGIN
           SET @Ln_MotherDemo_MemberMci_IDNO = @An_MotherMemberMci_IDNO;
           SET @Lc_MotherDemo_Last_NAME = @Ac_MotherLast_NAME;
           SET @Lc_MotherDemo_First_NAME = @Ac_MotherFirst_NAME;
           SET @Lc_MotherDemo_Middle_NAME = @Lc_Empty_TEXT;
           SET @Lc_MotherDemo_Suffix_NAME = @Lc_Empty_TEXT;
          END

         IF(@Lb_UpdateFTRDemoVapp_BIT = 1)
          BEGIN
           SET @Ln_EstFatherDemo_MemberMci_IDNO = @An_FatherMemberMci_IDNO;
           SET @Lc_EstFatherDemo_Last_NAME = @Ac_FatherLast_NAME;
           SET @Lc_EstFatherDemo_First_NAME = @Ac_FatherFirst_NAME;
           SET @Lc_EstFatherDemo_Middle_NAME = @Lc_Empty_TEXT;
           SET @Lc_EstFatherDemo_Suffix_NAME = @Lc_Empty_TEXT;
          END

         IF(@Lb_UpdateDFTRDemoVapp_BIT = 1)
          BEGIN
           SET @Ln_DisEstFatherDemo_MemberMci_IDNO = @Ln_VappCur_DisFatherMemberMci_IDNO;
           SET @Lc_DisEstFatherDemo_Last_NAME = @Lc_VappCur_DisFatherLast_NAME;
           SET @Lc_DisEstFatherDemo_First_NAME = @Lc_VappCur_DisFatherFirst_NAME;
           SET @Lc_DisEstFatherDemo_Middle_NAME = @Lc_Empty_TEXT;
           SET @Lc_DisEstFatherDemo_Suffix_NAME = @Lc_Empty_TEXT;
          END

         IF NOT EXISTS(SELECT 1
                         FROM VAPP_Y1
                        WHERE TypeDocument_CODE = @Lc_DopTypeDocument_CODE
                          AND ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID)
          BEGIN
           SET @Ls_Sqldata_TEXT = '';

           SELECT @Ld_DOPMotherSig_DATE = @Ld_Low_DATE,
                  @Ld_DOPFatherSig_DATE = @Ld_Low_DATE,
                  @Lc_StateDisestablish_CODE = ' ';
          END
         ELSE
          BEGIN
           SET @Ls_Sql_TEXT = 'SET UPDATE MATCH DATA - 2'
           SET @Ls_Sqldata_TEXT = 'TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '');

           SELECT @Ld_DOPMotherSig_DATE = v.MotherSignature_DATE,
                  @Ld_DOPFatherSig_DATE = v.FatherSignature_DATE,
                  @Lc_StateDisestablish_CODE = 'DE',
                  @Lc_DisEstablishedFather_CODE = CASE
                                                   WHEN @Lb_UpdateDFTRDemoVapp_BIT = 1
                                                    THEN
                                                    CASE
                                                     WHEN ISNULL(v.FatherMemberMci_IDNO, 0) > 0
                                                      THEN
                                                      CASE
                                                       WHEN EXISTS (SELECT 1
                                                                      FROM CMEM_Y1 A
                                                                     WHERE A.MemberMci_IDNO = v.FatherMemberMci_IDNO)
                                                        THEN (SELECT ISNULL(A.CaseRelationship_CODE, 'O')
                                                                FROM CMEM_Y1 A
                                                               WHERE A.MemberMci_IDNO = v.FatherMemberMci_IDNO)
                                                       ELSE 'O'
                                                      END
                                                     ELSE 'O'
                                                    END
                                                   ELSE ' '
                                                  END
             FROM VAPP_Y1 v
            WHERE TypeDocument_CODE = @Lc_DopTypeDocument_CODE
              AND ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID;
          END

         IF(@Ad_MotherSignature_DATE > @Ad_FatherSignature_DATE)
          BEGIN
           SET @Ld_UpdateEstDate_DATE = @Ad_MotherSignature_DATE;
          END
         ELSE
          SET @Ld_UpdateEstDate_DATE = @Ad_FatherSignature_DATE;

         IF(@Ld_DOPMotherSig_DATE > @Ld_DOPFatherSig_DATE)
          BEGIN
           IF(@Ld_DOPMotherSig_DATE > @Ld_UpdateEstDate_DATE)
            BEGIN
             SET @Ld_UpdateEstDate_DATE = @Ld_DOPMotherSig_DATE;
            END

           SET @Ld_Disestablish_DATE = @Ld_DOPMotherSig_DATE;
          END
         ELSE
          BEGIN
           IF(@Ld_DOPFatherSig_DATE > @Ld_UpdateEstDate_DATE)
            BEGIN
             SET @Ld_UpdateEstDate_DATE = @Ld_DOPFatherSig_DATE;
            END

           SET @Ld_Disestablish_DATE = @Ld_DOPFatherSig_DATE;
          END

         SELECT @Ln_EstFatherDemo_MemberMci_IDNO = CASE
                                                    WHEN ISNULL(@Ln_EstFatherDemo_MemberMci_IDNO, 0) = 0
                                                     THEN @An_FatherMemberMci_IDNO
                                                    ELSE @Ln_EstFatherDemo_MemberMci_IDNO
                                                   END,
                @Lc_EstFatherDemo_Last_NAME = CASE
                                               WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Last_NAME, '')))) = 0
                                                THEN @Ac_FatherLast_NAME
                                               ELSE @Lc_EstFatherDemo_Last_NAME
                                              END,
                @Lc_EstFatherDemo_First_NAME = CASE
                                                WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_First_NAME, '')))) = 0
                                                 THEN @Ac_FatherFirst_NAME
                                                ELSE @Lc_EstFatherDemo_First_NAME
                                               END,
                @Lc_EstFatherDemo_Middle_NAME = CASE
                                                 WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Middle_NAME, '')))) = 0
                                                  THEN @Lc_Empty_TEXT
                                                 ELSE @Lc_EstFatherDemo_Middle_NAME
                                                END,
                @Lc_EstFatherDemo_Suffix_NAME = CASE
                                                 WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EstFatherDemo_Suffix_NAME, '')))) = 0
                                                  THEN @Lc_Empty_TEXT
                                                 ELSE @Lc_EstFatherDemo_Suffix_NAME
                                                END,
                @Lc_EFTRCaseRelationship_CODE = CASE
                                                 WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_EFTRCaseRelationship_CODE, '')))) = 0
                                                  THEN 'O'
                                                 ELSE @Lc_EFTRCaseRelationship_CODE
                                                END,
                @Ln_MotherDemo_MemberMci_IDNO = CASE
                                                 WHEN ISNULL(@Ln_MotherDemo_MemberMci_IDNO, 0) = 0
                                                  THEN @An_MotherMemberMci_IDNO
                                                 ELSE @Ln_MotherDemo_MemberMci_IDNO
                                                END,
                @Lc_MotherDemo_Last_NAME = CASE
                                            WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Last_NAME, '')))) = 0
                                             THEN @Ac_MotherLast_NAME
                                            ELSE @Lc_MotherDemo_Last_NAME
                                           END,
                @Lc_MotherDemo_First_NAME = CASE
                                             WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_First_NAME, '')))) = 0
                                              THEN @Ac_MotherFirst_NAME
                                             ELSE @Lc_MotherDemo_First_NAME
                                            END,
                @Lc_MotherDemo_Middle_NAME = CASE
                                              WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Middle_NAME, '')))) = 0
                                               THEN @Lc_Empty_TEXT
                                              ELSE @Lc_MotherDemo_Middle_NAME
                                             END,
                @Lc_MotherDemo_Suffix_NAME = CASE
                                              WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MotherDemo_Suffix_NAME, '')))) = 0
                                               THEN @Lc_Empty_TEXT
                                              ELSE @Lc_MotherDemo_Suffix_NAME
                                             END,
                @Lc_MTRCaseRelationship_CODE = CASE
                                                WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_MTRCaseRelationship_CODE, '')))) = 0
                                                 THEN 'O'
                                                ELSE @Lc_MTRCaseRelationship_CODE
                                               END,
                @Ln_DisEstFatherDemo_MemberMci_IDNO = CASE
                                                       WHEN ISNULL(@Ln_DisEstFatherDemo_MemberMci_IDNO, 0) = 0
                                                        THEN @Ln_VappCur_DisFatherMemberMci_IDNO
                                                       ELSE @Ln_DisEstFatherDemo_MemberMci_IDNO
                                                      END,
                @Lc_DisEstFatherDemo_Last_NAME = CASE
                                                  WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Last_NAME, '')))) = 0
                                                   THEN @Lc_VappCur_DisFatherLast_NAME
                                                  ELSE @Lc_DisEstFatherDemo_Last_NAME
                                                 END,
                @Lc_DisEstFatherDemo_First_NAME = CASE
                                                   WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_First_NAME, '')))) = 0
                                                    THEN @Lc_VappCur_DisFatherFirst_NAME
                                                   ELSE @Lc_DisEstFatherDemo_First_NAME
                                                  END,
                @Lc_DisEstFatherDemo_Middle_NAME = CASE
                                                    WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Middle_NAME, '')))) = 0
                                                     THEN @Lc_Empty_TEXT
                                                    ELSE @Lc_DisEstFatherDemo_Middle_NAME
                                                   END,
                @Lc_DisEstFatherDemo_Suffix_NAME = CASE
                                                    WHEN LEN(LTRIM(RTRIM(ISNULL(@Lc_DisEstFatherDemo_Suffix_NAME, '')))) = 0
                                                     THEN @Lc_Empty_TEXT
                                                    ELSE @Lc_DisEstFatherDemo_Suffix_NAME
                                                   END

         SET @Ls_Sql_TEXT = 'BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH - 2';
         SET @Ls_Sqldata_TEXT = 'ChildMemberMci_IDNO = ' + ISNULL(CAST(@Ln_ChildDemo_MemberMci_IDNO AS VARCHAR), '') + ', EstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_EstFatherDemo_MemberMci_IDNO AS VARCHAR), '') + ', DisEstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_DisEstFatherDemo_MemberMci_IDNO AS VARCHAR), '') + ', EstablishedMotherMci_IDNO = ' + ISNULL(CAST(@Ln_MotherDemo_MemberMci_IDNO AS VARCHAR), '') + ', DopAttached_CODE = ' + ISNULL(@Ac_DopAttached_CODE, '') + ', EstablishedMother_CODE = ' + ISNULL(@Lc_MTRCaseRelationship_CODE, '') + ', EstablishedFather_CODE = ' + ISNULL(@Lc_EFTRCaseRelationship_CODE, '') + ', DisEstablishedFather_CODE = ' + ISNULL(@Lc_DisEstablishedFather_CODE, '') + ', EstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_EstFatherDemo_Suffix_NAME, '') + ', DisEstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Suffix_NAME, '') + ', EstablishedMotherSuffix_NAME = ' + ISNULL(@Lc_MotherDemo_Suffix_NAME, '') + ', ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', EstablishedFatherFirst_NAME = ' + ISNULL(@Lc_EstFatherDemo_First_NAME, '') + ', DisEstablishedFatherFirst_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_First_NAME, '') + ', EstablishedMotherFirst_NAME = ' + ISNULL(@Lc_MotherDemo_First_NAME, '') + ', EstablishedFatherLast_NAME = ' + ISNULL(@Lc_EstFatherDemo_Last_NAME, '') + ', EstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_EstFatherDemo_Middle_NAME, '') + ', DisEstablishedFatherLast_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Last_NAME, '') + ', DisEstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_DisEstFatherDemo_Middle_NAME, '') + ', EstablishedMotherLast_NAME = ' + ISNULL(@Lc_MotherDemo_Last_NAME, '') + ', EstablishedMotherMiddle_NAME = ' + ISNULL(@Lc_MotherDemo_Middle_NAME, '') + ', PaternityEst_DATE = ' + ISNULL(CAST(@Ld_UpdateEstDate_DATE AS VARCHAR), '') + ', Disestablish_DATE = ' + ISNULL(CAST(@Ld_Disestablish_DATE AS VARCHAR), '') + ', StateDisestablish_CODE = ' + ISNULL(@Lc_StateDisestablish_CODE, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '');

         EXECUTE BATCH_EST_VDMP$SP_PROCESS_UPDATE_MATCH
          @Ac_Job_ID                          = @Lc_Job_ID,
          @An_ChildMemberMci_IDNO             = @Ln_ChildDemo_MemberMci_IDNO,
          @An_EstablishedFatherMci_IDNO       = @Ln_EstFatherDemo_MemberMci_IDNO,
          @An_DisEstablishedFatherMci_IDNO    = @Ln_DisEstFatherDemo_MemberMci_IDNO,
          @An_EstablishedMotherMci_IDNO       = @Ln_MotherDemo_MemberMci_IDNO,
          @Ac_DopAttached_CODE                = @Ac_DopAttached_CODE,
          @Ac_EstablishedMother_CODE          = @Lc_MTRCaseRelationship_CODE,
          @Ac_EstablishedFather_CODE          = @Lc_EFTRCaseRelationship_CODE,
          @Ac_DisEstablishedFather_CODE       = @Lc_DisEstablishedFather_CODE,
          @Ac_EstablishedFatherSuffix_NAME    = @Lc_EstFatherDemo_Suffix_NAME,
          @Ac_DisEstablishedFatherSuffix_NAME = @Lc_DisEstFatherDemo_Suffix_NAME,
          @Ac_EstablishedMotherSuffix_NAME    = @Lc_MotherDemo_Suffix_NAME,
          @Ac_ChildBirthCertificate_ID        = @Ac_ChildBirthCertificate_ID,
          @Ac_EstablishedFatherFirst_NAME     = @Lc_EstFatherDemo_First_NAME,
          @Ac_DisEstablishedFatherFirst_NAME  = @Lc_DisEstFatherDemo_First_NAME,
          @Ac_EstablishedMotherFirst_NAME     = @Lc_MotherDemo_First_NAME,
          @Ac_EstablishedFatherLast_NAME      = @Lc_EstFatherDemo_Last_NAME,
          @Ac_EstablishedFatherMiddle_NAME    = @Lc_EstFatherDemo_Middle_NAME,
          @Ac_DisEstablishedFatherLast_NAME   = @Lc_DisEstFatherDemo_Last_NAME,
          @Ac_DisEstablishedFatherMiddle_NAME = @Lc_DisEstFatherDemo_Middle_NAME,
          @Ac_EstablishedMotherLast_NAME      = @Lc_MotherDemo_Last_NAME,
          @Ac_EstablishedMotherMiddle_NAME    = @Lc_MotherDemo_Middle_NAME,
          @Ad_PaternityEst_DATE               = @Ld_UpdateEstDate_DATE,
          @Ad_Disestablish_DATE               = @Ld_Disestablish_DATE,
          @Ac_StateDisestablish_CODE          = @Lc_StateDisestablish_CODE,
          @Ad_Run_DATE                        = @Ad_Run_DATE,
          @Ac_Msg_CODE                        = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT           = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

           RAISERROR(50001,16,1);
          END

         CLOSE CaseSglMtr_CUR;

         DEALLOCATE CaseSglMtr_CUR;

         GOTO EXIT_MFP_SINGLE_LOOP;
        END

       SET @Ls_Sql_TEXT ='FETCH NEXT CaseSglMtr_CUR';

       FETCH NEXT FROM CaseSglMtr_CUR INTO @Ln_CaseSglMtrCur_Case_IDNO;

       SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE CaseSglMtr_CUR;

     DEALLOCATE CaseSglMtr_CUR;

     EXIT_MFP_SINGLE_LOOP:;

     SET @Ls_Sql_TEXT = 'SELECT #VappMappPointQntyInfo_P1';
     SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '');

     SELECT @Li_ParentFirstProcessChildDataMatchPoint_QNTY = A.ParentFirstProcessChildDataMatchPoint_QNTY,
            @Li_ParentFirstProcessParentDataMatchPoint_QNTY = A.ParentFirstProcessParentDataMatchPoint_QNTY,
            @Lc_MatchFound_INDC = A.MatchFound_INDC
       FROM #VappMappPointQntyInfo_P1 A
      WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID;

     IF @Lc_MatchFound_INDC = 'Y'
        AND @Li_ParentFirstProcessChildDataMatchPoint_QNTY >= 4
        AND @Li_ParentFirstProcessParentDataMatchPoint_QNTY >= 4
      BEGIN
       SET @Ac_Goto_CODE = 'NEXT_RECORD';

       GOTO END_MOTHER_PROCESS;
      END
     ELSE
      BEGIN
       SET @Ac_Goto_CODE = 'BEGIN_FATHER_PROCESS';

       GOTO END_MOTHER_PROCESS;
      END;
    END

   END_MOTHER_PROCESS:;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('Local', 'DepDupMtr_CUR') IN (0, 1)
    BEGIN
     CLOSE DepDupMtr_CUR;

     DEALLOCATE DepDupMtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'ParDupMtr_CUR') IN (0, 1)
    BEGIN
     CLOSE ParDupMtr_CUR;

     DEALLOCATE ParDupMtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'CaseDupMtr_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseDupMtr_CUR;

     DEALLOCATE CaseDupMtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'DemoDupMtr_CUR') IN (0, 1)
    BEGIN
     CLOSE DemoDupMtr_CUR;

     DEALLOCATE DemoDupMtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'DepSglMtr_CUR') IN (0, 1)
    BEGIN
     CLOSE DepSglMtr_CUR;

     DEALLOCATE DepSglMtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'ParSglMtr_CUR') IN (0, 1)
    BEGIN
     CLOSE ParSglMtr_CUR;

     DEALLOCATE ParSglMtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'CaseSglMtr_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseSglMtr_CUR;

     DEALLOCATE CaseSglMtr_CUR;
    END

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
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
