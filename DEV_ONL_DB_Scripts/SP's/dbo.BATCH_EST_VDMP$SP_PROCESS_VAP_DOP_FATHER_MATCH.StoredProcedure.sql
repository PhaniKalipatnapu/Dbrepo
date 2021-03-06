/****** Object:  StoredProcedure [dbo].[BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_FATHER_MATCH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_FATHER_MATCH
Programmer Name	:	IMP Team.
Description		:	This batch program runs when there was no match found during the Mother First process for Parent First process.
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
CREATE PROCEDURE [dbo].[BATCH_EST_VDMP$SP_PROCESS_VAP_DOP_FATHER_MATCH]
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
          @Ls_Procedure_NAME            VARCHAR(100) = 'SP_PROCESS_VAP_DOP_FATHER_MATCH',
          @Ld_Disestablish_DATE         DATE = NULL,
          @Ld_Low_DATE                  DATE = '01/01/0001',
          @Ld_High_date                 DATE = '12/31/9999';
  DECLARE @Ln_ChildPointsCounter_NUMB                           NUMERIC = 0,
          @Ln_ParentPointsCounter_NUMB                          NUMERIC = 0,
          @Ln_RowsCount_QNTY                                    NUMERIC,
          @Ln_ChildDemo_MemberMci_IDNO                          NUMERIC,
          @Ln_ChildDemo_MemberSsn_NUMB                          NUMERIC,
          @Ln_MotherDemo_MemberMci_IDNO                         NUMERIC,
          @Ln_MotherDemo_MemberSsn_NUMB                         NUMERIC,
          @Ln_FatherDemo_MemberMci_IDNO                         NUMERIC,
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
          @Li_ParentFirstProcessParentDataMatchPointFather_QNTY INT = 0,
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
  DECLARE @Ln_CaseDupFtrCur_Case_IDNO            NUMERIC,
          @Ln_DemoDupFtrCur_MemberMci_IDNO       NUMERIC,
          @Ln_DepDupFtrCur_MemberMci_IDNO        NUMERIC,
          @Ln_ParDupFtrCur_MemberMci_IDNO        NUMERIC,
          @Lc_ParDupFtrCur_MemberSex_CODE        CHAR(1),
          @Lc_ParDupFtrCur_CaseRelationship_CODE CHAR(1),
          @Lc_DepDupFtrCur_CPRelChild_CODE       CHAR(3),
          @Lc_DepDupFtrCur_NCPRelChild_CODE      CHAR(3);
  DECLARE @Ln_CaseSglFtrCur_Case_IDNO            NUMERIC,
          @Ln_DepSglFtrCur_MemberMci_IDNO        NUMERIC,
          @Ln_ParSglFtrCur_MemberMci_IDNO        NUMERIC,
          @Lc_ParSglFtrCur_MemberSex_CODE        CHAR(1),
          @Lc_ParSglFtrCur_CaseRelationship_CODE CHAR(1),
          @Lc_DepSglFtrCur_CPRelChild_CODE       CHAR(3),
          @Lc_DepSglFtrCur_NCPRelChild_CODE      CHAR(3);

  BEGIN TRY
   SELECT @Ln_FatherDemo_MemberMci_IDNO = 0,
          @Li_ParentFirstProcessParentDataMatchPointFather_QNTY = 0,
          @Lb_DemoMultipleMatch_BIT = 0,
          @Li_ParentFirstProcessParentDataMatchPoint_QNTY = 0,
          @Ln_DemoDupFtrCur_MemberMci_IDNO = 0,
          @Li_DemoFetchStatus_QNTY = -1,
          @Lc_MatchFound_INDC = @Lc_No_INDC,
          @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
          @Ln_CaseDupFtrCur_Case_IDNO = 0,
          @Li_CaseFetchStatus_QNTY = -1,
          @Ln_DepDupFtrCur_MemberMci_IDNO = 0,
          @Lc_DepDupFtrCur_CPRelChild_CODE = '',
          @Lc_DepDupFtrCur_NCPRelChild_CODE = '',
          @Li_DepandantFetchStatus_QNTY = -1,
          @Ln_ChildDemo_MemberMci_IDNO = 0,
          @Ln_ChildDemo_MemberSsn_NUMB = 0,
          @Lc_ChildDemo_BirthCertificate_ID = '',
          @Lc_ChildDemo_Last_NAME = '',
          @Lc_ChildDemo_First_NAME = '',
          @Ld_ChildDemo_Birth_DATE = @Ld_Low_DATE,
          @Ln_ParDupFtrCur_MemberMci_IDNO = 0,
          @Lc_ParDupFtrCur_CaseRelationship_CODE = '',
          @Lc_ParDupFtrCur_MemberSex_CODE = '',
          @Li_ParentFetchStatus_QNTY = -1,
          @Ln_CaseSglFtrCur_Case_IDNO = 0,
          @Li_CaseFetchStatus_QNTY = -1,
          @Ln_DepSglFtrCur_MemberMci_IDNO = 0,
          @Lc_DepSglFtrCur_CPRelChild_CODE = '',
          @Lc_DepSglFtrCur_NCPRelChild_CODE = '',
          @Li_DepandantFetchStatus_QNTY = -1,
          @Ln_ParSglFtrCur_MemberMci_IDNO = 0,
          @Lc_ParSglFtrCur_CaseRelationship_CODE = '',
          @Lc_ParSglFtrCur_MemberSex_CODE = '',
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

   IF @An_FatherMemberMci_IDNO > 0
      AND (ISNUMERIC(@An_FatherMemberMci_IDNO) = 1
           AND EXISTS (SELECT 1
                         FROM DEMO_Y1 d
                        WHERE MemberMci_IDNO = @An_FatherMemberMci_IDNO
                          AND EXISTS (SELECT 1
                                        FROM CMEM_Y1 X
                                       WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                         AND X.CaseRelationship_CODE <> 'D'
                                         AND X.CaseMemberStatus_CODE = 'A')))
    BEGIN
     SET @Ls_Sql_TEXT = 'Select DEMO details of Father';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_FatherMemberMci_IDNO AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

     SELECT @Ln_FatherDemo_MemberMci_IDNO = d.MemberMci_IDNO
       FROM DEMO_Y1 d
      WHERE d.MemberMci_IDNO = @An_FatherMemberMci_IDNO
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 X
                     WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                       AND X.CaseRelationship_CODE <> 'D'
                       AND X.CaseMemberStatus_CODE = 'A');

     SET @Li_ParentFirstProcessParentDataMatchPointFather_QNTY += 4; --Father MCI 			= 4 points	 					
     INSERT INTO #FfpMatchPointQntyInfo_P1
                 (ChildBirthCertificate_ID,
                  FatherMemberMci_IDNO,
                  FatherDataMatchPoint_QNTY)
          VALUES ( @Ac_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                   @An_FatherMemberMci_IDNO,--FatherMemberMci_IDNO
                   @Li_ParentFirstProcessParentDataMatchPointFather_QNTY --FatherDataMatchPoint_QNTY
     )
    END
   ELSE IF @An_FatherMemberSsn_NUMB > 0
      AND (ISNUMERIC(@An_FatherMemberSsn_NUMB) = 1
           AND EXISTS (SELECT 1
                         FROM DEMO_Y1 d
                        WHERE d.MemberSsn_NUMB = @An_FatherMemberSsn_NUMB
                          AND EXISTS (SELECT 1
                                        FROM CMEM_Y1 X
                                       WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                         AND X.CaseRelationship_CODE <> 'D'
                                         AND X.CaseMemberStatus_CODE = 'A')))
    BEGIN
     SET @Ls_Sql_TEXT = 'Select DEMO details of Father';
     SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(CAST(@An_FatherMemberSsn_NUMB AS VARCHAR), '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

     SELECT @Ln_FatherDemo_MemberMci_IDNO = d.MemberMci_IDNO
       FROM DEMO_Y1 d
      WHERE d.MemberSsn_NUMB = @An_FatherMemberSsn_NUMB
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 X
                     WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                       AND X.CaseRelationship_CODE <> 'D'
                       AND X.CaseMemberStatus_CODE = 'A');

     SET @Li_ParentFirstProcessParentDataMatchPointFather_QNTY += 4; --Father SSN 			= 4 points
     INSERT INTO #FfpMatchPointQntyInfo_P1
                 (ChildBirthCertificate_ID,
                  FatherMemberMci_IDNO,
                  FatherMemberSsn_NUMB,
                  FatherDataMatchPoint_QNTY)
          VALUES ( @Ac_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                   @Ln_FatherDemo_MemberMci_IDNO,--FatherMemberMci_IDNO
                   @An_FatherMemberSsn_NUMB,--FatherMemberSsn_NUMB
                   @Li_ParentFirstProcessParentDataMatchPointFather_QNTY --FatherDataMatchPoint_QNTY
     )
    END
   ELSE IF (LEN(LTRIM(RTRIM(@Ac_FatherLast_NAME))) > 0
       AND LEN(LTRIM(RTRIM(@Ac_FatherFirst_NAME))) > 0)
      AND 1 < (SELECT COUNT(DISTINCT(d.MemberMci_IDNO))
                 FROM DEMO_Y1 d
                WHERE Last_NAME = @Ac_FatherLast_NAME
                  AND First_NAME = @Ac_FatherFirst_NAME
                  AND EXISTS (SELECT 1
                                FROM CMEM_Y1 X
                               WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                 AND X.CaseRelationship_CODE <> 'D'
                                 AND X.CaseMemberStatus_CODE = 'A'))
    BEGIN
     SET @Lb_DemoMultipleMatch_BIT =1;

     DECLARE DemoDupFtr_CUR INSENSITIVE CURSOR FOR
      SELECT d.MemberMci_IDNO
        FROM DEMO_Y1 d
       WHERE Last_NAME = @Ac_FatherLast_NAME
         AND First_NAME = @Ac_FatherFirst_NAME
         AND EXISTS (SELECT 1
                       FROM CMEM_Y1 X
                      WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                        AND X.CaseRelationship_CODE <> 'D'
                        AND X.CaseMemberStatus_CODE = 'A');

     SET @Li_ParentFirstProcessParentDataMatchPointFather_QNTY += 2; --Father Last Name 			= 2 points
     SET @Li_ParentFirstProcessParentDataMatchPointFather_QNTY += 1; --Father First Name			= 1 point
     INSERT INTO #FfpMatchPointQntyInfo_P1
                 (ChildBirthCertificate_ID,
                  FatherLast_NAME,
                  FatherFirst_NAME,
                  FatherDataMatchPoint_QNTY)
          VALUES ( @Ac_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                   @Ac_FatherLast_NAME,--FatherLast_NAME
                   @Ac_FatherFirst_NAME,--FatherFirst_NAME
                   @Li_ParentFirstProcessParentDataMatchPointFather_QNTY --FatherDataMatchPoint_QNTY
     )
    END
   ELSE IF (LEN(LTRIM(RTRIM(@Ac_FatherLast_NAME))) > 0
       AND LEN(LTRIM(RTRIM(@Ac_FatherFirst_NAME))) > 0)
      AND 1 = (SELECT COUNT(DISTINCT(d.MemberMci_IDNO))
                 FROM DEMO_Y1 d
                WHERE Last_NAME = @Ac_FatherLast_NAME
                  AND First_NAME = @Ac_FatherFirst_NAME
                  AND EXISTS (SELECT 1
                                FROM CMEM_Y1 X
                               WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                                 AND X.CaseRelationship_CODE <> 'D'
                                 AND X.CaseMemberStatus_CODE = 'A'))
    BEGIN
     SET @Lb_DemoMultipleMatch_BIT =0;
     SET @Ls_Sqldata_TEXT = 'Last_NAME = ' + ISNULL(@Ac_FatherLast_NAME, '') + ', First_NAME = ' + ISNULL(@Ac_FatherFirst_NAME, '') + ', CaseMemberStatus_CODE = ' + ISNULL('A', '');

     SELECT @Ln_FatherDemo_MemberMci_IDNO = d.MemberMci_IDNO
       FROM DEMO_Y1 d
      WHERE Last_NAME = @Ac_FatherLast_NAME
        AND First_NAME = @Ac_FatherFirst_NAME
        AND EXISTS (SELECT 1
                      FROM CMEM_Y1 X
                     WHERE X.MemberMci_IDNO = d.MemberMci_IDNO
                       AND X.CaseRelationship_CODE <> 'D'
                       AND X.CaseMemberStatus_CODE = 'A');

     SET @Li_ParentFirstProcessParentDataMatchPointFather_QNTY += 2; --Father Last Name 			= 2 points
     SET @Li_ParentFirstProcessParentDataMatchPointFather_QNTY += 1; --Father First Name			= 1 point
     INSERT INTO #FfpMatchPointQntyInfo_P1
                 (ChildBirthCertificate_ID,
                  FatherMemberMci_IDNO,
                  FatherLast_NAME,
                  FatherFirst_NAME,
                  FatherDataMatchPoint_QNTY)
          VALUES ( @Ac_ChildBirthCertificate_ID,--ChildBirthCertificate_ID
                   @Ln_FatherDemo_MemberMci_IDNO,--FatherMemberMci_IDNO
                   @Ac_FatherLast_NAME,--FatherLast_NAME
                   @Ac_FatherFirst_NAME,--FatherFirst_NAME
                   @Li_ParentFirstProcessParentDataMatchPointFather_QNTY --FatherDataMatchPoint_QNTY
     )
    END
   ELSE
    BEGIN
     SET @Ls_Sqldata_TEXT = '';
     --SELECT 'No Match Found in FATHER Process, Moving to next eligible record.';
     SET @Ac_Goto_CODE = 'NEXT_RECORD';

     GOTO END_FATHER_PROCESS;
    END

   SELECT @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY

   IF(@Lb_DemoMultipleMatch_BIT = 1)
    BEGIN
     SELECT @Ln_DemoDupFtrCur_MemberMci_IDNO = 0,
            @Li_DemoFetchStatus_QNTY = -1,
            @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
            @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
            @Lc_MatchFound_INDC = @Lc_No_INDC

     SET @Ls_Sql_TEXT ='OPEN DemoDupFtr_CUR 3';

     OPEN DemoDupFtr_CUR;

     SET @Ls_Sql_TEXT ='FETCH DemoDupFtr_CUR 3';

     FETCH NEXT FROM DemoDupFtr_CUR INTO @Ln_DemoDupFtrCur_MemberMci_IDNO;

     SET @Li_DemoFetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT ='WHILE DemoDupFtr_CUR 3';

     --LOOP THROUGH DEMO CUR...
     WHILE @Li_DemoFetchStatus_QNTY = 0
           AND @Lc_MatchFound_INDC = 'N'
      BEGIN
       IF EXISTS(SELECT 1
                   FROM #FfpMatchPointQntyInfo_P1 A
                  WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                    AND A.FatherMemberMci_IDNO IS NULL)
        BEGIN
         UPDATE #FfpMatchPointQntyInfo_P1
            SET FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
        END
       ELSE
        BEGIN
         INSERT INTO #FfpMatchPointQntyInfo_P1
                     (ChildBirthCertificate_ID,
                      FatherMemberMci_IDNO,
                      FatherLast_NAME,
                      FatherFirst_NAME,
                      FatherDataMatchPoint_QNTY)
         SELECT TOP 1 A.ChildBirthCertificate_ID,
                      @Ln_DemoDupFtrCur_MemberMci_IDNO AS FatherMemberMci_IDNO,
                      A.FatherLast_NAME,
                      A.FatherFirst_NAME,
                      A.FatherDataMatchPoint_QNTY
           FROM #FfpMatchPointQntyInfo_P1 A
          WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
        END

       SELECT @Ln_CaseDupFtrCur_Case_IDNO = 0,
              @Li_CaseFetchStatus_QNTY = -1,
              @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
              @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
              @Lc_MatchFound_INDC = @Lc_No_INDC

       SET @Ls_Sql_TEXT ='SET CaseDupFtr_CUR 3';
       SET @Ls_Sqldata_TEXT = '';

       DECLARE CaseDupFtr_CUR INSENSITIVE CURSOR FOR
        SELECT c.Case_IDNO
          FROM CMEM_Y1 c
         WHERE c.MemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
           AND c.CaseRelationship_CODE <> 'D'
           AND c.CaseMemberStatus_CODE = 'A'
           AND EXISTS (SELECT 1
                         FROM CASE_Y1 X
                        WHERE X.Case_IDNO = c.Case_IDNO
                          AND X.StatusCase_CODE = 'O');

       SET @Ls_Sql_TEXT ='OPEN CaseDupFtr_CUR 3';
       SET @Ls_Sqldata_TEXT = '';

       OPEN CaseDupFtr_CUR;

       SET @Ls_Sql_TEXT ='FETCH CaseDupFtr_CUR 3';
       SET @Ls_Sqldata_TEXT = '';

       FETCH NEXT FROM CaseDupFtr_CUR INTO @Ln_CaseDupFtrCur_Case_IDNO;

       SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT ='WHILE CaseDupFtr_CUR 3';

       --WHILE CaseDupFtr_CUR 3
       WHILE @Li_CaseFetchStatus_QNTY = 0
             AND @Lc_MatchFound_INDC = 'N'
        BEGIN
         IF EXISTS(SELECT 1
                     FROM #FfpMatchPointQntyInfo_P1 A
                    WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                      AND A.FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
                      AND A.FatherCase_IDNO IS NULL)
          BEGIN
           UPDATE #FfpMatchPointQntyInfo_P1
              SET FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
            WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
          END
         ELSE
          BEGIN
           INSERT INTO #FfpMatchPointQntyInfo_P1
                       (ChildBirthCertificate_ID,
                        FatherMemberMci_IDNO,
                        FatherLast_NAME,
                        FatherFirst_NAME,
                        FatherCase_IDNO,
                        FatherDataMatchPoint_QNTY)
           SELECT TOP 1 A.ChildBirthCertificate_ID,
                        A.FatherMemberMci_IDNO,
                        A.FatherLast_NAME,
                        A.FatherFirst_NAME,
                        @Ln_CaseDupFtrCur_Case_IDNO AS FatherCase_IDNO,
                        A.FatherDataMatchPoint_QNTY
             FROM #FfpMatchPointQntyInfo_P1 A
            WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND A.FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
          END

         SELECT @Ln_DepDupFtrCur_MemberMci_IDNO = 0,
                @Lc_DepDupFtrCur_CPRelChild_CODE = '',
                @Lc_DepDupFtrCur_NCPRelChild_CODE = '',
                @Li_DepandantFetchStatus_QNTY = -1,
                @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
                @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
                @Lc_MatchFound_INDC = @Lc_No_INDC

         SET @Ls_Sql_TEXT ='SET DepDupFtr_CUR 3';

         DECLARE DepDupFtr_CUR INSENSITIVE CURSOR FOR
          SELECT c.MemberMci_IDNO,
                 c.CpRelationshipToChild_CODE,
                 c.NcpRelationshipToChild_CODE
            FROM CMEM_Y1 c
           WHERE c.Case_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
             AND c.CaseRelationship_CODE = @Lc_DepCaseRelationship_CODE
             AND c.CaseMemberStatus_CODE = 'A';

         SET @Ls_Sql_TEXT ='OPEN DepDupFtr_CUR 3';

         OPEN DepDupFtr_CUR;

         SET @Ls_Sql_TEXT ='FETCH DepDupFtr_CUR 3';

         FETCH NEXT FROM DepDupFtr_CUR INTO @Ln_DepDupFtrCur_MemberMci_IDNO, @Lc_DepDupFtrCur_CPRelChild_CODE, @Lc_DepDupFtrCur_NCPRelChild_CODE;

         SET @Li_DepandantFetchStatus_QNTY = @@FETCH_STATUS;
         SET @Ls_Sql_TEXT ='WHILE DepDupFtr_CUR 3';

         --WHILE Depandant_CUR 3
         WHILE @Li_DepandantFetchStatus_QNTY = 0
          BEGIN
           SELECT @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
                  @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
                  @Lc_MatchFound_INDC = @Lc_No_INDC

           IF EXISTS(SELECT 1
                       FROM #FfpMatchPointQntyInfo_P1 A
                      WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                        AND A.FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
                        AND A.FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
                        AND A.ChildMemberMci_IDNO IS NULL)
            BEGIN
             UPDATE #FfpMatchPointQntyInfo_P1
                SET ChildMemberMci_IDNO = @Ln_DepDupFtrCur_MemberMci_IDNO,
                    CpRelationshipToChild_CODE = @Lc_DepDupFtrCur_CPRelChild_CODE,
                    NcpRelationshipToChild_CODE = @Lc_DepDupFtrCur_NCPRelChild_CODE
              WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                AND FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
                AND FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
            END
           ELSE
            BEGIN
             INSERT INTO #FfpMatchPointQntyInfo_P1
                         (ChildBirthCertificate_ID,
                          FatherMemberMci_IDNO,
                          FatherLast_NAME,
                          FatherFirst_NAME,
                          FatherCase_IDNO,
                          ChildMemberMci_IDNO,
                          CpRelationshipToChild_CODE,
                          NcpRelationshipToChild_CODE,
                          FatherDataMatchPoint_QNTY)
             SELECT TOP 1 A.ChildBirthCertificate_ID,
                          A.FatherMemberMci_IDNO,
                          A.FatherLast_NAME,
                          A.FatherFirst_NAME,
                          A.FatherCase_IDNO,
                          @Ln_DepDupFtrCur_MemberMci_IDNO AS ChildMemberMci_IDNO,
                          @Lc_DepDupFtrCur_CPRelChild_CODE AS CpRelationshipToChild_CODE,
                          @Lc_DepDupFtrCur_NCPRelChild_CODE AS NcpRelationshipToChild_CODE,
                          A.FatherDataMatchPoint_QNTY
               FROM #FfpMatchPointQntyInfo_P1 A
              WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                AND A.FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
                AND A.FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
            END

           SET @Ln_ChildPointsCounter_NUMB =0;
           SET @Ls_Sql_TEXT = 'Select DEMO details of Dependant 3';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DepDupFtrCur_MemberMci_IDNO AS VARCHAR), '');

           SELECT @Ln_ChildDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                  @Ln_ChildDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                  @Lc_ChildDemo_BirthCertificate_ID = ISNULL((SELECT ISNULL(x.BirthCertificate_ID, '')
                                                                FROM MPAT_Y1 x
                                                               WHERE x.MemberMci_IDNO = d.MemberMci_IDNO), ''),
                  @Lc_ChildDemo_Last_NAME = d.Last_NAME,
                  @Lc_ChildDemo_First_NAME = d.First_NAME,
                  @Ld_ChildDemo_Birth_DATE = d.Birth_DATE
             FROM DEMO_Y1 d
            WHERE d.MemberMci_IDNO = @Ln_DepDupFtrCur_MemberMci_IDNO;

           UPDATE #FfpMatchPointQntyInfo_P1
              SET ChildLast_NAME = @Lc_ChildDemo_Last_NAME,
                  ChildFirst_NAME = @Lc_ChildDemo_First_NAME,
                  ChildBirth_DATE = @Ld_ChildDemo_Birth_DATE,
                  ChildMemberSsn_NUMB = @Ln_ChildDemo_MemberSsn_NUMB,
                  ChildDemoBirthCertificate_ID = @Lc_ChildDemo_BirthCertificate_ID
            WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
              AND FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
              AND ChildMemberMci_IDNO = @Ln_DepDupFtrCur_MemberMci_IDNO

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

           UPDATE #FfpMatchPointQntyInfo_P1
              SET ChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY
            WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
              AND FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
              AND ChildMemberMci_IDNO = @Ln_DepDupFtrCur_MemberMci_IDNO

           SET @Ls_Sql_TEXT ='FETCH NEXT DepDupFtr_CUR 3';

           FETCH NEXT FROM DepDupFtr_CUR INTO @Ln_DepDupFtrCur_MemberMci_IDNO, @Lc_DepDupFtrCur_CPRelChild_CODE, @Lc_DepDupFtrCur_NCPRelChild_CODE;

           SET @Li_DepandantFetchStatus_QNTY = @@FETCH_STATUS;
          END

         CLOSE DepDupFtr_CUR;

         DEALLOCATE DepDupFtr_CUR;

         NEXTPRT3:;

         SELECT @Ln_ParDupFtrCur_MemberMci_IDNO = 0,
                @Lc_ParDupFtrCur_CaseRelationship_CODE = '',
                @Lc_ParDupFtrCur_MemberSex_CODE = '',
                @Li_ParentFetchStatus_QNTY = -1,
                @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
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

         DECLARE ParDupFtr_CUR INSENSITIVE CURSOR FOR
          SELECT c.MemberMci_IDNO,
                 c.CaseRelationship_CODE,
                 d.MemberSex_CODE
            FROM CMEM_Y1 c
                 JOIN DEMO_Y1 d
                  ON c.MemberMci_IDNO = d.MemberMci_IDNO
           WHERE Case_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
             AND CaseRelationship_CODE IN (@Lc_CPCaseRelationship_CODE, @Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
             AND CaseMemberStatus_CODE = 'A';

         SET @Ls_Sql_TEXT ='OPEN ParDupFtr_CUR 3';

         OPEN ParDupFtr_CUR;

         SET @Ls_Sql_TEXT ='FETCH ParDupFtr_CUR 3';

         FETCH NEXT FROM ParDupFtr_CUR INTO @Ln_ParDupFtrCur_MemberMci_IDNO, @Lc_ParDupFtrCur_CaseRelationship_CODE, @Lc_ParDupFtrCur_MemberSex_CODE;

         SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
         SET @Ls_Sql_TEXT ='WHILE @Parent_CUR 3';

         -- Process parents in the selected case
         WHILE @Li_ParentFetchStatus_QNTY = 0
          BEGIN
           IF(@Lc_DepDupFtrCur_CPRelChild_CODE = @Lc_Relation_Mother_CODE
              AND @Lc_ParDupFtrCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
              AND @Lc_ParDupFtrCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
            BEGIN
             SET @Lc_MTRCaseRelationship_CODE = @Lc_ParDupFtrCur_CaseRelationship_CODE;
             SET @Ls_Sql_TEXT ='Select Mother details from DEMO 2';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupFtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                    @Lc_MotherDemo_First_NAME = d.First_NAME,
                    @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParDupFtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateMTRDemoVapp_BIT = 1;
              END
            END
           ELSE IF(@Lc_DepDupFtrCur_CPRelChild_CODE = @Lc_Relation_Father_CODE
              AND @Lc_ParDupFtrCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
              AND @Lc_ParDupFtrCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
            BEGIN
             SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParDupFtrCur_CaseRelationship_CODE;

             IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
              BEGIN
               SET @Ls_Sql_TEXT ='Select EstFather details from DEMO 2';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupFtrCur_MemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                      @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                      @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_ParDupFtrCur_MemberMci_IDNO;

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
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupFtrCur_MemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                      @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                      @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_ParDupFtrCur_MemberMci_IDNO;

               SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

               IF(@Ln_RowsCount_QNTY = 0)
                BEGIN
                 SET @Lb_UpdateFTRDemoVapp_BIT =1;
                END
              END
            END

           IF(@Lc_DepDupFtrCur_NCPRelChild_CODE = @Lc_Relation_Mother_CODE
              AND @Lc_ParDupFtrCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
              AND @Lc_ParDupFtrCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
            BEGIN
             SET @Lc_MTRCaseRelationship_CODE = @Lc_ParDupFtrCur_CaseRelationship_CODE;
             SET @Ls_Sql_TEXT ='Select Mother details from DEMO 3';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupFtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                    @Lc_MotherDemo_First_NAME = d.First_NAME,
                    @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParDupFtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateMTRDemoVapp_BIT =1;
              END
            END
           ELSE IF(@Lc_DepDupFtrCur_NCPRelChild_CODE = @Lc_Relation_Father_CODE
              AND @Lc_ParDupFtrCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
              AND @Lc_ParDupFtrCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
            BEGIN
             SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParDupFtrCur_CaseRelationship_CODE;

             IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
              BEGIN
               SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 4';
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupFtrCur_MemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                      @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                      @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_ParDupFtrCur_MemberMci_IDNO;

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
               SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParDupFtrCur_MemberMci_IDNO AS VARCHAR), '');

               SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                      @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                      @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                      @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                      @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                      @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                      @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
                 FROM DEMO_Y1 d
                WHERE d.MemberMci_IDNO = @Ln_ParDupFtrCur_MemberMci_IDNO;

               SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

               IF(@Ln_RowsCount_QNTY = 0)
                BEGIN
                 SET @Lb_UpdateFTRDemoVapp_BIT =1;
                END
              END
            END

           SET @Ls_Sql_TEXT ='FETCH NEXT ParDupFtr_CUR 2';

           FETCH NEXT FROM ParDupFtr_CUR INTO @Ln_ParDupFtrCur_MemberMci_IDNO, @Lc_ParDupFtrCur_CaseRelationship_CODE, @Lc_ParDupFtrCur_MemberSex_CODE;

           SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
          END

         CLOSE ParDupFtr_CUR;

         DEALLOCATE ParDupFtr_CUR;

         SET @Ls_Sql_TEXT ='Verify NCP Mother details with DEMO in Father First Process';

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

         SET @Ls_Sql_TEXT ='Verify NCP EstFather details with DEMO in Father First Process';

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

         UPDATE #FfpMatchPointQntyInfo_P1
            SET ParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPoint_QNTY
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
            AND FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO

         SELECT @Li_ParentFirstProcessChildDataMatchPoint_QNTY = MAX(ISNULL(A.ChildDataMatchPoint_QNTY, 0))
           FROM #FfpMatchPointQntyInfo_P1 A
          WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND A.FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
            AND A.FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO

SELECT TOP 1 @Ln_ChildDemo_MemberMci_IDNO = A.ChildMemberMci_IDNO
FROM #FfpMatchPointQntyInfo_P1 A
WHERE A.ChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY AND 
LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND A.FatherMemberMci_IDNO = @Ln_DemoDupFtrCur_MemberMci_IDNO
            AND A.FatherCase_IDNO = @Ln_CaseDupFtrCur_Case_IDNO
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
             SET @Ls_Sql_TEXT = 'SET UPDATE MATCH DATA - 1';
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

           CLOSE CaseDupFtr_CUR;

           DEALLOCATE CaseDupFtr_CUR;

           CLOSE DemoDupFtr_CUR;

           DEALLOCATE DemoDupFtr_CUR;

           GOTO EXIT_FFP_DUPLICATE_LOOP;
          END

         SET @Ls_Sql_TEXT ='FETCH NEXT CaseDupFtr_CUR 2';

         FETCH NEXT FROM CaseDupFtr_CUR INTO @Ln_CaseDupFtrCur_Case_IDNO;

         SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE CaseDupFtr_CUR;

       DEALLOCATE CaseDupFtr_CUR;

       SET @Ls_Sql_TEXT ='FETCH NEXT DemoDupFtr_CUR 2';

       FETCH NEXT FROM DemoDupFtr_CUR INTO @Ln_DemoDupFtrCur_MemberMci_IDNO;

       SET @Li_DemoFetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE DemoDupFtr_CUR;

     DEALLOCATE DemoDupFtr_CUR;

     EXIT_FFP_DUPLICATE_LOOP:;

     SET @Ac_Goto_CODE = 'NEXT_RECORD';

     GOTO END_FATHER_PROCESS;
    END
   ELSE
    BEGIN
     SELECT @Ln_CaseSglFtrCur_Case_IDNO = 0,
            @Li_CaseFetchStatus_QNTY = -1,
            @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
            @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
            @Lc_MatchFound_INDC = @Lc_No_INDC

     SET @Ls_Sql_TEXT ='SET CaseSglFtr_CUR 4';

     DECLARE CaseSglFtr_CUR INSENSITIVE CURSOR FOR
      SELECT c.Case_IDNO
        FROM CMEM_Y1 c
       WHERE c.MemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
         AND c.CaseRelationship_CODE <> 'D'
         AND c.CaseMemberStatus_CODE = 'A'
         AND EXISTS (SELECT 1
                       FROM CASE_Y1 X
                      WHERE X.Case_IDNO = c.Case_IDNO
                        AND X.StatusCase_CODE = 'O');

     SET @Ls_Sql_TEXT ='OPEN CaseSglFtr_CUR 4';

     OPEN CaseSglFtr_CUR;

     SET @Ls_Sql_TEXT ='FETCH CaseSglFtr_CUR 4';

     FETCH NEXT FROM CaseSglFtr_CUR INTO @Ln_CaseSglFtrCur_Case_IDNO;

     SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
     SET @Ls_Sql_TEXT ='WHILE CaseSglFtr_CUR 4';

     --WHILE CaseSglFtr_CUR 4
     WHILE @Li_CaseFetchStatus_QNTY = 0
           AND @Lc_MatchFound_INDC = 'N'
      BEGIN
       IF EXISTS(SELECT 1
                   FROM #FfpMatchPointQntyInfo_P1 A
                  WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                    AND A.FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
                    AND A.FatherCase_IDNO IS NULL)
        BEGIN
         UPDATE #FfpMatchPointQntyInfo_P1
            SET FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
        END
       ELSE
        BEGIN
         INSERT INTO #FfpMatchPointQntyInfo_P1
                     (ChildBirthCertificate_ID,
                      FatherMemberMci_IDNO,
                      FatherLast_NAME,
                      FatherFirst_NAME,
                      FatherMemberSsn_NUMB,
                      FatherCase_IDNO,
                      FatherDataMatchPoint_QNTY)
         SELECT TOP 1 A.ChildBirthCertificate_ID,
                      A.FatherMemberMci_IDNO,
                      A.FatherLast_NAME,
                      A.FatherFirst_NAME,
                      A.FatherMemberSsn_NUMB,
                      @Ln_CaseSglFtrCur_Case_IDNO AS FatherCase_IDNO,
                      A.FatherDataMatchPoint_QNTY
           FROM #FfpMatchPointQntyInfo_P1 A
          WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND A.FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
        END

       SELECT @Ln_DepSglFtrCur_MemberMci_IDNO = 0,
              @Lc_DepSglFtrCur_CPRelChild_CODE = '',
              @Lc_DepSglFtrCur_NCPRelChild_CODE = '',
              @Li_DepandantFetchStatus_QNTY = -1,
              @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
              @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
              @Lc_MatchFound_INDC = @Lc_No_INDC

       SET @Ls_Sql_TEXT ='SET DepSglFtr_CUR 4';

       DECLARE DepSglFtr_CUR INSENSITIVE CURSOR FOR
        SELECT c.MemberMci_IDNO,
               c.CpRelationshipToChild_CODE,
               c.NcpRelationshipToChild_CODE
          FROM CMEM_Y1 c
         WHERE c.Case_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
           AND c.CaseRelationship_CODE = @Lc_DepCaseRelationship_CODE
           AND c.CaseMemberStatus_CODE = 'A';

       SET @Ls_Sql_TEXT ='OPEN DepSglFtr_CUR 4';

       OPEN DepSglFtr_CUR;

       SET @Ls_Sql_TEXT ='FETCH DepSglFtr_CUR 4';

       FETCH NEXT FROM DepSglFtr_CUR INTO @Ln_DepSglFtrCur_MemberMci_IDNO, @Lc_DepSglFtrCur_CPRelChild_CODE, @Lc_DepSglFtrCur_NCPRelChild_CODE;

       SET @Li_DepandantFetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT ='WHILE DepSglFtr_CUR 4';

       --WHILE Depandant_CUR 4
       WHILE @Li_DepandantFetchStatus_QNTY = 0
        BEGIN
         SELECT @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
                @Li_ParentFirstProcessChildDataMatchPoint_QNTY = 0,
                @Lc_MatchFound_INDC = @Lc_No_INDC

         IF EXISTS(SELECT 1
                     FROM #FfpMatchPointQntyInfo_P1 A
                    WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
                      AND A.FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
                      AND A.FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
                      AND A.ChildMemberMci_IDNO IS NULL)
          BEGIN
           UPDATE #FfpMatchPointQntyInfo_P1
              SET ChildMemberMci_IDNO = @Ln_DepSglFtrCur_MemberMci_IDNO,
                  CpRelationshipToChild_CODE = @Lc_DepSglFtrCur_CPRelChild_CODE,
                  NcpRelationshipToChild_CODE = @Lc_DepSglFtrCur_NCPRelChild_CODE
            WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
              AND FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
          END
         ELSE
          BEGIN
           INSERT INTO #FfpMatchPointQntyInfo_P1
                       (ChildBirthCertificate_ID,
                        FatherMemberMci_IDNO,
                        FatherLast_NAME,
                        FatherFirst_NAME,
                        FatherMemberSsn_NUMB,
                        FatherCase_IDNO,
                        ChildMemberMci_IDNO,
                        CpRelationshipToChild_CODE,
                        NcpRelationshipToChild_CODE,
                        FatherDataMatchPoint_QNTY)
           SELECT TOP 1 A.ChildBirthCertificate_ID,
                        A.FatherMemberMci_IDNO,
                        A.FatherLast_NAME,
                        A.FatherFirst_NAME,
                        A.FatherMemberSsn_NUMB,
                        A.FatherCase_IDNO,
                        @Ln_DepSglFtrCur_MemberMci_IDNO AS ChildMemberMci_IDNO,
                        @Lc_DepSglFtrCur_CPRelChild_CODE AS CpRelationshipToChild_CODE,
                        @Lc_DepSglFtrCur_NCPRelChild_CODE AS NcpRelationshipToChild_CODE,
                        A.FatherDataMatchPoint_QNTY
             FROM #FfpMatchPointQntyInfo_P1 A
            WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
              AND A.FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
              AND A.FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
          END

         SET @Ln_ChildPointsCounter_NUMB =0;
         SET @Ls_Sql_TEXT = 'Select DEMO details of Dependant 4';
         SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_DepSglFtrCur_MemberMci_IDNO AS VARCHAR), '');

         SELECT @Ln_ChildDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                @Ln_ChildDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                @Lc_ChildDemo_BirthCertificate_ID = ISNULL((SELECT ISNULL(x.BirthCertificate_ID, '')
                                                              FROM MPAT_Y1 x
                                                             WHERE x.MemberMci_IDNO = d.MemberMci_IDNO), ''),
                @Lc_ChildDemo_Last_NAME = d.Last_NAME,
                @Lc_ChildDemo_First_NAME = d.First_NAME,
                @Ld_ChildDemo_Birth_DATE = d.Birth_DATE
           FROM DEMO_Y1 d
          WHERE d.MemberMci_IDNO = @Ln_DepSglFtrCur_MemberMci_IDNO;

         UPDATE #FfpMatchPointQntyInfo_P1
            SET ChildLast_NAME = @Lc_ChildDemo_Last_NAME,
                ChildFirst_NAME = @Lc_ChildDemo_First_NAME,
                ChildBirth_DATE = @Ld_ChildDemo_Birth_DATE,
                ChildMemberSsn_NUMB = @Ln_ChildDemo_MemberSsn_NUMB,
                ChildDemoBirthCertificate_ID = @Lc_ChildDemo_BirthCertificate_ID
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
            AND FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
            AND ChildMemberMci_IDNO = @Ln_DepSglFtrCur_MemberMci_IDNO

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

         UPDATE #FfpMatchPointQntyInfo_P1
            SET ChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY
          WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
            AND FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
            AND FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
            AND ChildMemberMci_IDNO = @Ln_DepSglFtrCur_MemberMci_IDNO

         SET @Ls_Sql_TEXT ='FETCH NEXT DepSglFtr_CUR 4';

         FETCH NEXT FROM DepSglFtr_CUR INTO @Ln_DepSglFtrCur_MemberMci_IDNO, @Lc_DepSglFtrCur_CPRelChild_CODE, @Lc_DepSglFtrCur_NCPRelChild_CODE;

         SET @Li_DepandantFetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE DepSglFtr_CUR;

       DEALLOCATE DepSglFtr_CUR;

       NEXTPRT2:;

       SELECT @Ln_ParSglFtrCur_MemberMci_IDNO = 0,
              @Lc_ParSglFtrCur_CaseRelationship_CODE = '',
              @Lc_ParSglFtrCur_MemberSex_CODE = '',
              @Li_ParentFetchStatus_QNTY = -1,
              @Li_ParentFirstProcessParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPointFather_QNTY,
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

       DECLARE ParSglFtr_CUR INSENSITIVE CURSOR FOR
        SELECT c.MemberMci_IDNO,
               c.CaseRelationship_CODE,
               d.MemberSex_CODE
          FROM CMEM_Y1 c
               JOIN DEMO_Y1 d
                ON c.MemberMci_IDNO = d.MemberMci_IDNO
         WHERE Case_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
           AND CaseRelationship_CODE IN (@Lc_CPCaseRelationship_CODE, @Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
           AND CaseMemberStatus_CODE = 'A';

       SET @Ls_Sql_TEXT ='OPEN ParSglFtr_CUR 4';

       OPEN ParSglFtr_CUR;

       SET @Ls_Sql_TEXT ='FETCH ParSglFtr_CUR 4';

       FETCH NEXT FROM ParSglFtr_CUR INTO @Ln_ParSglFtrCur_MemberMci_IDNO, @Lc_ParSglFtrCur_CaseRelationship_CODE, @Lc_ParSglFtrCur_MemberSex_CODE;

       SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
       SET @Ls_Sql_TEXT ='WHILE ParSglFtr_CUR 4';

       -- Process parents in the selected case
       WHILE @Li_ParentFetchStatus_QNTY = 0
        BEGIN
         IF(@Lc_DepSglFtrCur_CPRelChild_CODE = @Lc_Relation_Mother_CODE
            AND @Lc_ParSglFtrCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
            AND @Lc_ParSglFtrCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
          BEGIN
           SET @Lc_MTRCaseRelationship_CODE = @Lc_ParSglFtrCur_CaseRelationship_CODE;
           SET @Ls_Sql_TEXT ='Select Mother details from DEMO 3';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglFtrCur_MemberMci_IDNO AS VARCHAR), '');

           SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                  @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                  @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                  @Lc_MotherDemo_First_NAME = d.First_NAME,
                  @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                  @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                  @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
             FROM DEMO_Y1 d
            WHERE d.MemberMci_IDNO = @Ln_ParSglFtrCur_MemberMci_IDNO;

           SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

           IF(@Ln_RowsCount_QNTY = 0)
            BEGIN
             SET @Lb_UpdateMTRDemoVapp_BIT = 1;
            END
          END
         ELSE IF(@Lc_DepSglFtrCur_CPRelChild_CODE = @Lc_Relation_Father_CODE
            AND @Lc_ParSglFtrCur_CaseRelationship_CODE = @Lc_CPCaseRelationship_CODE
            AND @Lc_ParSglFtrCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
          BEGIN
           SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParSglFtrCur_CaseRelationship_CODE;

           IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
            BEGIN
             SET @Ls_Sql_TEXT ='Select EstFather details from DEMO 4';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglFtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParSglFtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateFTRDemoVapp_BIT =1;
              END

             SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Child First Process 3';
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
             SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 4';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglFtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParSglFtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateFTRDemoVapp_BIT =1;
              END
            END
          END

         IF(@Lc_DepSglFtrCur_NCPRelChild_CODE = @Lc_Relation_Mother_CODE
            AND @Lc_ParSglFtrCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
            AND @Lc_ParSglFtrCur_MemberSex_CODE = @Lc_MTRMemberSex_CODE)
          BEGIN
           SET @Lc_MTRCaseRelationship_CODE = @Lc_ParSglFtrCur_CaseRelationship_CODE;
           SET @Ls_Sql_TEXT ='Select Mother details from DEMO 4';
           SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglFtrCur_MemberMci_IDNO AS VARCHAR), '');

           SELECT @Ln_MotherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                  @Ln_MotherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                  @Lc_MotherDemo_Last_NAME = d.Last_NAME,
                  @Lc_MotherDemo_First_NAME = d.First_NAME,
                  @Lc_MotherDemo_Middle_NAME = d.Middle_NAME,
                  @Lc_MotherDemo_Suffix_NAME = d.Suffix_NAME,
                  @Ld_MotherDemo_Birth_DATE = d.Birth_DATE
             FROM DEMO_Y1 d
            WHERE d.MemberMci_IDNO = @Ln_ParSglFtrCur_MemberMci_IDNO;

           SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

           IF(@Ln_RowsCount_QNTY = 0)
            BEGIN
             SET @Lb_UpdateMTRDemoVapp_BIT =1;
            END
          END
         ELSE IF(@Lc_DepSglFtrCur_NCPRelChild_CODE = @Lc_Relation_Father_CODE
            AND @Lc_ParSglFtrCur_CaseRelationship_CODE IN (@Lc_NCPCaseRelationship_CODE, @Lc_PNCPCaseRelationship_CODE)
            AND @Lc_ParSglFtrCur_MemberSex_CODE = @Lc_FTRMemberSex_CODE)
          BEGIN
           SET @Lc_EFTRCaseRelationship_CODE = @Lc_ParSglFtrCur_CaseRelationship_CODE;

           IF(@Ac_DopAttached_CODE = @Lc_DOPAttachedYes_CODE)
            BEGIN
             SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 5';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglFtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParSglFtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateFTRDemoVapp_BIT =1;
              END

             SET @Ls_Sql_TEXT ='Select CP DisEstablished Father details from VAPP, in Child First Process 4';
             SET @Ls_Sqldata_TEXT = 'ChildBirthCertificate_ID = ' + ISNULL(@Ac_ChildBirthCertificate_ID, '') + ', TypeDocument_CODE = ' + ISNULL(@Lc_DopTypeDocument_CODE, '');

             SELECT @Ln_VappCur_DisFatherMemberMci_IDNO = v.FatherMemberMci_IDNO,
                    @Lc_VappCur_DisFatherLast_NAME = v.FatherLast_NAME,
                    @Lc_VappCur_DisFatherFirst_NAME = v.FatherFirst_NAME,
                    @Ld_VappCur_DisFatherBirth_DATE = v.FatherBirth_DATE,
                    @Ln_VappCur_DisFatherMemberSsn_NUMB = v.FatherMemberSsn_NUMB
               FROM VAPP_Y1 v
              WHERE ChildBirthCertificate_ID = @Ac_ChildBirthCertificate_ID
                AND TypeDocument_CODE = @Lc_DopTypeDocument_CODE;

             SET @Ls_Sql_TEXT ='Select DisEstablished Father details from DEMO 4';
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
             SET @Ls_Sql_TEXT ='Select Established Father details from DEMO 6';
             SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_ParSglFtrCur_MemberMci_IDNO AS VARCHAR), '');

             SELECT @Ln_EstFatherDemo_MemberMci_IDNO = d.MemberMci_IDNO,
                    @Ln_EstFatherDemo_MemberSsn_NUMB = d.MemberSsn_NUMB,
                    @Lc_EstFatherDemo_Last_NAME = d.Last_NAME,
                    @Lc_EstFatherDemo_First_NAME = d.First_NAME,
                    @Lc_EstFatherDemo_Middle_NAME = d.Middle_NAME,
                    @Lc_EstFatherDemo_Suffix_NAME = d.Suffix_NAME,
                    @Ld_EstFatherDemo_Birth_DATE = d.Birth_DATE
               FROM DEMO_Y1 d
              WHERE d.MemberMci_IDNO = @Ln_ParSglFtrCur_MemberMci_IDNO;

             SET @Ln_RowsCount_QNTY = @@ROWCOUNT;

             IF(@Ln_RowsCount_QNTY = 0)
              BEGIN
               SET @Lb_UpdateFTRDemoVapp_BIT =1;
              END
            END
          END

         SET @Ls_Sql_TEXT ='FETCH NEXT ParSglFtr_CUR';

         FETCH NEXT FROM ParSglFtr_CUR INTO @Ln_ParSglFtrCur_MemberMci_IDNO, @Lc_ParSglFtrCur_CaseRelationship_CODE, @Lc_ParSglFtrCur_MemberSex_CODE;

         SET @Li_ParentFetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE ParSglFtr_CUR;

       DEALLOCATE ParSglFtr_CUR;

       SET @Ls_Sql_TEXT ='Verify NCP Mother details with DEMO in Father First Process';

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

       SET @Ls_Sql_TEXT ='Verify NCP EstFather details with DEMO in Father First Process';

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

       UPDATE #FfpMatchPointQntyInfo_P1
          SET ParentDataMatchPoint_QNTY = @Li_ParentFirstProcessParentDataMatchPoint_QNTY
        WHERE LTRIM(RTRIM(ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
          AND FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
          AND FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO

       SELECT @Li_ParentFirstProcessChildDataMatchPoint_QNTY = MAX(ISNULL(A.ChildDataMatchPoint_QNTY, 0))
         FROM #FfpMatchPointQntyInfo_P1 A
        WHERE LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
          AND A.FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
          AND A.FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO

SELECT TOP 1 @Ln_ChildDemo_MemberMci_IDNO = A.ChildMemberMci_IDNO
FROM #FfpMatchPointQntyInfo_P1 A
WHERE A.ChildDataMatchPoint_QNTY = @Li_ParentFirstProcessChildDataMatchPoint_QNTY AND 
LTRIM(RTRIM(A.ChildBirthCertificate_ID)) = LTRIM(RTRIM(@Ac_ChildBirthCertificate_ID))
          AND A.FatherMemberMci_IDNO = @Ln_FatherDemo_MemberMci_IDNO
          AND A.FatherCase_IDNO = @Ln_CaseSglFtrCur_Case_IDNO
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
           SET @Ls_Sql_TEXT = 'SET UPDATE MATCH DATA - 2';
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

         CLOSE CaseSglFtr_CUR;

         DEALLOCATE CaseSglFtr_CUR;

         GOTO EXIT_FFP_SINGLE_LOOP;
        END

       SET @Ls_Sql_TEXT ='FETCH NEXT CaseSglFtr_CUR';

       FETCH NEXT FROM CaseSglFtr_CUR INTO @Ln_CaseSglFtrCur_Case_IDNO;

       SET @Li_CaseFetchStatus_QNTY = @@FETCH_STATUS;
      END

     CLOSE CaseSglFtr_CUR;

     DEALLOCATE CaseSglFtr_CUR;

     EXIT_FFP_SINGLE_LOOP:;

     SET @Ac_Goto_CODE = 'NEXT_RECORD';

     GOTO END_FATHER_PROCESS;
    END

   END_FATHER_PROCESS:;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('Local', 'DepDupFtr_CUR') IN (0, 1)
    BEGIN
     CLOSE DepDupFtr_CUR;

     DEALLOCATE DepDupFtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'ParDupFtr_CUR') IN (0, 1)
    BEGIN
     CLOSE ParDupFtr_CUR;

     DEALLOCATE ParDupFtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'CaseDupFtr_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseDupFtr_CUR;

     DEALLOCATE CaseDupFtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'DemoDupFtr_CUR') IN (0, 1)
    BEGIN
     CLOSE DemoDupFtr_CUR;

     DEALLOCATE DemoDupFtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'DepSglFtr_CUR') IN (0, 1)
    BEGIN
     CLOSE DepSglFtr_CUR;

     DEALLOCATE DepSglFtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'ParSglFtr_CUR') IN (0, 1)
    BEGIN
     CLOSE ParSglFtr_CUR;

     DEALLOCATE ParSglFtr_CUR;
    END

   IF CURSOR_STATUS ('Local', 'CaseSglFtr_CUR') IN (0, 1)
    BEGIN
     CLOSE CaseSglFtr_CUR;

     DEALLOCATE CaseSglFtr_CUR;
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
