/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR
Programmer Name	:	IMP Team.
Description		:	The procedure reads the data from the Load table and inserts the data into Pending Referrals tables.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Called On		:	BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR] (
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_ReasonForPending_CODE CHAR(2),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_FetchStatus_QNTY           SMALLINT = 0,
          @Li_RowsCount_QNTY             SMALLINT = 0,
          @Lc_ProcessN_CODE              CHAR(1) = 'N',
          @Lc_Note_INDC                  CHAR(1) = 'N',
          @Lc_CaseRelationshipCp_CODE    CHAR(1) = 'C',
          @Lc_CaseRelationshipChild_CODE CHAR(1) = 'D',
          @Lc_CaseRelationshipNcpP_CODE  CHAR(1) = 'P',
          @Lc_Space_TEXT                 CHAR(1) = ' ',
          @Lc_StatusFailed_CODE          CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
          @Lc_TypeWelfareTANF_CODE       CHAR(1) = 'A',
          @Lc_Percenatage_TEXT           CHAR(1) = '%',
          @Lc_TypeWelfareMedicaid_CODE   CHAR(1) = 'M',
          @Lc_TypeWelfareNonTanf_CODE    CHAR(1) = 'N',
          @Lc_PurchaseOfCare_CODE        CHAR(1) = 'C',
          @Lc_Msg_CODE                   CHAR(5) = ' ',
          @Lc_BatchRunUser_TEXT          CHAR(5) = 'BATCH',
          @Ls_Procedure_NAME             VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_CPDR',
          @Ls_Sql_TEXT                   VARCHAR(2000) = ' ',
          @Ls_ErrorMessage_TEXT          VARCHAR(4000) = ' ',
          @Ls_DescriptionError_TEXT      VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT               VARCHAR(5000) = ' ',
          @Ld_Low_DATE                   DATE = '01/01/0001';
  DECLARE @Ln_Zero_NUMB                NUMERIC(1) = 0,
          @Ln_ErrorLine_NUMB           NUMERIC(11) = 0,
          @Ln_Error_NUMB               NUMERIC(11) = 0,
          @Ln_TransactionEventSeq_NUMB NUMERIC(18, 0) = 0,
          @Ld_Current_DTTM             DATETIME2;
  --CURSOR VARIABLE DECLARATION
  DECLARE @Ln_CpdrCur_Seq_IDNO             NUMERIC(10),
          @Lc_CpdrCur_CaseWelfareIdno_TEXT CHAR(10),
          @Lc_CpdrCur_CpMciIdno_TEXT       CHAR(10),
          @Lc_CpdrCur_NcpMciIdno_TEXT      CHAR(10),
          @Lc_CpdrCur_AgSequenceNumb_TEXT  CHAR(4),
          @Ld_CpdrCur_FileLoad_DATE        DATE;
  DECLARE @Ln_CpdrCurAgSequence_NUMB  NUMERIC(4),
          @Ln_CpdrCurCaseWelfare_IDNO NUMERIC(10),
          @Ln_CpdrCurCpMci_IDNO       NUMERIC(10),
          @Ln_CpdrCurNcpMci_IDNO      NUMERIC(10);

  BEGIN TRY
   --Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'GET BATCH START DATE';
   SET @Ls_Sqldata_TEXT = ' JOB ID = ' + ISNULL(@Ac_Job_ID, '');
   SET @Ld_Current_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   --CURSOR STARTS
   DECLARE CPDR_CUR INSENSITIVE CURSOR FOR
    SELECT DISTINCT
           MIN(a.Seq_IDNO) AS Seq_IDNO,
           a.CaseWelfare_IDNO,
           a.CpMci_IDNO,
           a.NcpMci_IDNO,
           a.AgSequence_NUMB,
           a.FileLoad_DATE
      FROM LIVAR_Y1 a
     WHERE a.Seq_IDNO IN (SELECT t.Seq_IDNO
                            FROM ##TempSeqIdno_P1 t)
     GROUP BY a.CaseWelfare_IDNO,
              a.AgSequence_NUMB,
              a.FileLoad_DATE,
              a.NcpMci_IDNO,
              a.CpMci_IDNO;

   SET @Ls_Sql_TEXT = 'OPEN CPDR_CUR';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   OPEN CPDR_CUR;

   SET @Ls_Sql_TEXT = 'FETCH CPDR_CUR - 1';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   FETCH NEXT FROM CPDR_CUR INTO @Ln_CpdrCur_Seq_IDNO, @Lc_CpdrCur_CaseWelfareIdno_TEXT, @Lc_CpdrCur_CpMciIdno_TEXT, @Lc_CpdrCur_NcpMciIdno_TEXT, @Lc_CpdrCur_AgSequenceNumb_TEXT, @Ld_CpdrCur_FileLoad_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --Creates CPDR entry based on the criteria matched on the incoming referral for the DECSES worker to analyze the case.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'CHECK FOR KEY MEMBER IDENTIFIER';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     IF (ISNUMERIC (@Lc_CpdrCur_CaseWelfareIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_CpdrCur_CpMciIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_CpdrCur_NcpMciIdno_TEXT) = 0
          OR ISNUMERIC (@Lc_CpdrCur_AgSequenceNumb_TEXT) = 0)
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INVALID VALUE';

       RAISERROR (50001,16,1);
      END
     ELSE
      BEGIN
       SET @Ln_CpdrCurCaseWelfare_IDNO = CAST(@Lc_CpdrCur_CaseWelfareIdno_TEXT AS NUMERIC);
       SET @Ln_CpdrCurCpMci_IDNO = CAST(@Lc_CpdrCur_CpMciIdno_TEXT AS NUMERIC);
       SET @Ln_CpdrCurNcpMci_IDNO = CAST(@Lc_CpdrCur_NcpMciIdno_TEXT AS NUMERIC);
       SET @Ln_CpdrCurAgSequence_NUMB = CAST(@Lc_CpdrCur_AgSequenceNumb_TEXT AS NUMERIC);
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT - 1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Process_ID = ' + ISNULL(@Ac_Job_ID, '') + ', EffectiveEvent_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Note_INDC = ' + ISNULL(@Lc_Note_INDC, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL('0', '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Ac_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_Note_INDC,
      @An_EventFunctionalSeq_NUMB  = 0,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END

     --PRCA_Y1
     SET @Ls_Sql_TEXT = 'INSERT PRCA_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CpdrCur_Seq_IDNO AS VARCHAR), '') + ', ReasonForPending_CODE = ' + ISNULL(@Ac_ReasonForPending_CODE, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Current_DTTM AS VARCHAR), '') + ', ReferralProcess_CODE = ' + ISNULL(@Lc_ProcessN_CODE, '') + ', Application_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

     INSERT PRCA_Y1
            (CaseWelfare_IDNO,
             AgSequence_NUMB,
             ReferralReceived_DATE,
             StatusCase_CODE,
             IntactFamilyStatus_CODE,
             WelfareCaseCounty_IDNO,
             ReasonForPending_CODE,
             WorkerUpdate_ID,
             Update_DTTM,
             ReferralProcess_CODE,
             Application_IDNO,
             TransactionEventSeq_NUMB)
     SELECT DISTINCT
            a.CaseWelfare_IDNO,
            a.AgSequence_NUMB,
            a.FileLoad_DATE AS ReferralReceived_DATE,
            a.StatusCase_CODE,
            a.IntactFamilyStatus_CODE,
            a.WelfareCaseCounty_IDNO,
            @Ac_ReasonForPending_CODE AS ReasonForPending_CODE,
            @Lc_BatchRunUser_TEXT AS WorkerUpdate_ID,
            @Ld_Current_DTTM AS Update_DTTM,
            @Lc_ProcessN_CODE AS ReferralProcess_CODE,
            @Ln_Zero_NUMB AS Application_IDNO,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       FROM LIVAR_Y1 a
      WHERE a.Seq_IDNO = @Ln_CpdrCur_Seq_IDNO;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT PRCA_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     --PRDE_Y1
     SET @Ls_Sql_TEXT = 'INSERT PRDE_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CpdrCur_Seq_IDNO AS VARCHAR), '') + ', ReferralReceived_DATE = ' + ISNULL(CAST(@Ld_CpdrCur_FileLoad_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '');

     INSERT PRDE_Y1
            (CaseWelfare_IDNO,
             AgSequence_NUMB,
             ReferralReceived_DATE,
             Program_CODE,
             SubProgram_CODE,
             MemberElig_DATE,
             CaseRelationship_CODE,
             MemberMci_IDNO,
             First_NAME,
             Middle_NAME,
             Last_NAME,
             Suffix_NAME,
             Birth_DATE,
             MemberSsn_NUMB,
             MemberSex_CODE,
             Race_CODE,
             ChildPaternityStatus_CODE,
             CpRelationshipToChild_CODE,
             NcpRelationshipToChild_CODE,
             TransactionEventSeq_NUMB)
     SELECT DISTINCT
            x.CaseWelfare_IDNO,
            x.AgSequence_NUMB,
            @Ld_CpdrCur_FileLoad_DATE AS ReferralReceived_DATE,
            x.Program_CODE,
            x.SubProgram_CODE,
            CASE
             WHEN ISDATE(x.MemberElig_DATE) = @Ln_Zero_NUMB
              THEN @Ld_Low_DATE
             ELSE x.MemberElig_DATE
            END AS MemberElig_DATE,
            x.CaseRelationship_CODE,
            x.MemberMci_IDNO,
            x.First_NAME,
            x.Middle_NAME,
            x.Last_NAME,
            x.Suffix_NAME,
            CASE
             WHEN ISDATE(x.Birth_DATE) = @Ln_Zero_NUMB
              THEN @Ld_Low_DATE
             ELSE x.Birth_DATE
            END AS Birth_DATE,
            x.Ssn_NUMB AS MemberSsn_NUMB,
            x.Sex_CODE AS MemberSex_CODE,
            ISNULL(dbo.BATCH_FIN_IVA_UPDATES$SF_GET_RACE_CODE_ONE_CHAR(x.Race_CODE), @Lc_Space_TEXT) AS Race_CODE,
            x.ChildPaternityStatus_CODE,
            x.CpRelationshipToChild_CODE,
            x.NcpRelationshipToChild_CODE,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       FROM (SELECT DISTINCT
                    a.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                    a.AgSequence_NUMB AS AgSequence_NUMB,
                    a.Program_CODE AS Program_CODE,
                    a.SubProgram_CODE AS SubProgram_CODE,
                    a.ChildElig_DATE AS MemberElig_DATE,
                    @Lc_CaseRelationshipChild_CODE AS CaseRelationship_CODE,
                    a.ChildMci_IDNO AS MemberMci_IDNO,
                    a.ChildFirst_NAME AS First_NAME,
                    a.ChildMiddle_NAME AS Middle_NAME,
                    a.ChildLast_NAME AS Last_NAME,
                    a.ChildSuffix_NAME AS Suffix_NAME,
                    a.ChildBirth_DATE AS Birth_DATE,
                    a.ChildSsn_NUMB AS Ssn_NUMB,
                    a.ChildSex_CODE AS Sex_CODE,
                    a.ChildRace_CODE AS Race_CODE,
                    a.ChildPaternityStatus_CODE AS ChildPaternityStatus_CODE,
                    a.CpRelationshipToChild_CODE AS CpRelationshipToChild_CODE,
                    a.NcpRelationshipToChild_CODE AS NcpRelationshipToChild_CODE
               FROM LIVAR_Y1 a
              WHERE a.SEQ_IDNO = @Ln_CpdrCur_Seq_IDNO
                 OR (a.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                     AND a.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                     AND a.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                     AND a.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                     AND a.SEQ_IDNO IN (SELECT t.Seq_IDNO
                                          FROM ##TempSeqIdno_P1 t))
             UNION
             SELECT DISTINCT
                    ld.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                    ld.AgSequence_NUMB AS AgSequence_NUMB,
                    lr.Program_CODE AS Program_CODE,
                    lr.SubProgram_CODE AS SubProgram_CODE,
                    lr.MemberElig_DATE AS MemberElig_DATE,
                    @Lc_CaseRelationshipCp_CODE AS CaseRelationship_CODE,
                    ld.MemberMci_IDNO AS MemberMci_IDNO,
                    ld.First_NAME AS First_NAME,
                    ld.Middle_NAME AS Middle_NAME,
                    ld.Last_NAME AS Last_NAME,
                    ld.Suffix_NAME AS Suffix_NAME,
                    ld.Birth_DATE AS Birth_DATE,
                    ld.Ssn_NUMB AS Ssn_NUMB,
                    ld.Sex_CODE AS Sex_CODE,
                    ld.Race_CODE AS Race_CODE,
                    @Lc_Space_TEXT AS ChildPaternityStatus_CODE,
                    @Lc_Space_TEXT AS CpRelationshipToChild_CODE,
                    @Lc_Space_TEXT AS NcpRelationshipToChild_CODE
               FROM (SELECT TOP 1 a.Program_CODE AS Program_CODE,
                                  a.SubProgram_CODE AS SubProgram_CODE,
                                  CASE
                                   WHEN a.Program_CODE LIKE @Lc_TypeWelfareTANF_CODE + @Lc_Percenatage_TEXT
                                    THEN @Lc_TypeWelfareTANF_CODE
                                   WHEN a.Program_CODE LIKE @Lc_TypeWelfareMedicaid_CODE + @Lc_Percenatage_TEXT
                                    THEN @Lc_TypeWelfareMedicaid_CODE
                                   WHEN a.Program_CODE LIKE @Lc_PurchaseOfCare_CODE + @Lc_Percenatage_TEXT
                                    THEN @Lc_TypeWelfareNonTanf_CODE
                                  END AS TypeWelfare_CODE,
                                  a.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                                  a.AgSequence_NUMB AS AgSequence_NUMB,
                                  a.ChildElig_DATE AS MemberElig_DATE,
                                  a.CpMci_IDNO AS CpMci_IDNO
                       FROM LIVAR_Y1 a
                      WHERE a.SEQ_IDNO = @Ln_CpdrCur_Seq_IDNO
                         OR (a.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                             AND a.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                             AND a.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                             AND a.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                             AND a.SEQ_IDNO IN (SELECT t.Seq_IDNO
                                                  FROM ##TempSeqIdno_P1 t))
                      ORDER BY TypeWelfare_CODE)lr,
                    (SELECT b.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                            b.AgSequence_NUMB AS AgSequence_NUMB,
                            b.CpMci_IDNO AS MemberMci_IDNO,
                            b.CpFirst_NAME AS First_NAME,
                            b.CpMiddle_NAME AS Middle_NAME,
                            b.CpLast_NAME AS Last_NAME,
                            b.CpSuffix_NAME AS Suffix_NAME,
                            b.CpBirth_DATE AS Birth_DATE,
                            b.CpSsn_NUMB AS Ssn_NUMB,
                            b.CpSex_CODE AS Sex_CODE,
                            b.CpRace_CODE AS Race_CODE
                       FROM LIVAD_Y1 b
                      WHERE b.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                        AND b.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                        AND b.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                        AND b.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                        AND b.FileLoad_DATE = @Ld_CpdrCur_FileLoad_DATE)ld
              WHERE lr.CaseWelfare_IDNO = ld.CaseWelfare_IDNO
                AND lr.CpMci_IDNO = ld.MemberMci_IDNO
                AND lr.AgSequence_NUMB = ld.AgSequence_NUMB
             UNION
             SELECT b.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                    b.AgSequence_NUMB AS AgSequence_NUMB,
                    @Lc_Space_TEXT AS Program_CODE,
                    @Lc_Space_TEXT AS SubProgram_CODE,
                    @Lc_Space_TEXT AS MemberElig_DATE,
                    @Lc_CaseRelationshipNcpP_CODE AS CaseRelationship_CODE,
                    b.NcpMci_IDNO AS MemberMci_IDNO,
                    b.NcpFirst_NAME AS First_NAME,
                    b.NcpMiddle_NAME AS Middle_NAME,
                    b.NcpLast_NAME AS Last_NAME,
                    b.NcpSuffix_NAME AS Suffix_NAME,
                    b.NcpBirth_DATE AS Birth_DATE,
                    b.NcpSsn_NUMB AS Ssn_NUMB,
                    b.NcpSex_CODE AS Sex_CODE,
                    b.NcpRace_CODE AS Race_CODE,
                    @Lc_Space_TEXT AS ChildPaternityStatus_CODE,
                    @Lc_Space_TEXT AS CpRelationshipToChild_CODE,
                    @Lc_Space_TEXT AS NcpRelationshipToChild_CODE
               FROM LIVAD_Y1 b
              WHERE b.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                AND b.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                AND b.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                AND b.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                AND b.FileLoad_DATE = @Ld_CpdrCur_FileLoad_DATE)x;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT PRDE_Y1 FAILED';

       RAISERROR(50001,16,1);
      END
     
	 --PRAH_Y1
	 IF NOT EXISTS (SELECT 1
                      FROM PRAH_Y1 a
                     WHERE a.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                       AND a.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                       AND a.MemberMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                       AND a.ReferralReceived_DATE = @Ld_CpdrCur_FileLoad_DATE)
         OR NOT EXISTS (SELECT 1
                          FROM PRAH_Y1 a
                         WHERE a.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                           AND a.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                           AND a.MemberMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                           AND a.ReferralReceived_DATE = @Ld_CpdrCur_FileLoad_DATE)
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT PRAH_Y1';
       SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CpdrCur_Seq_IDNO AS VARCHAR), '') + ', ReferralReceived_DATE = ' + ISNULL(CAST(@Ld_CpdrCur_FileLoad_DATE AS VARCHAR), '');

       INSERT PRAH_Y1
              (CaseWelfare_IDNO,
               AgSequence_NUMB,
               ReferralReceived_DATE,
               MemberMci_IDNO,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR)
       SELECT DISTINCT
              x.CaseWelfare_IDNO,
              x.AgSequence_NUMB,
              @Ld_CpdrCur_FileLoad_DATE AS ReferralReceived_DATE,
              x.MemberMci_IDNO,
              x.Line1_ADDR,
              x.Line2_ADDR,
              x.City_ADDR,
              x.State_ADDR,
              x.Zip_ADDR
         FROM (SELECT DISTINCT
                      b.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                      b.AgSequence_NUMB AS AgSequence_NUMB,
                      b.CpMci_IDNO AS MemberMci_IDNO,
                      b.CpLine1_ADDR AS Line1_ADDR,
                      b.CpLine2_ADDR AS Line2_ADDR,
                      b.CpCity_ADDR AS City_ADDR,
                      b.CpState_ADDR AS State_ADDR,
                      b.CpZip_ADDR AS Zip_ADDR
                 FROM LIVAD_Y1 b
                WHERE b.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                  AND b.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                  AND b.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                  AND b.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                  AND b.FileLoad_DATE = @Ld_CpdrCur_FileLoad_DATE
               UNION
               SELECT DISTINCT
                      b.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                      b.AgSequence_NUMB AS AgSequence_NUMB,
                      b.NcpMci_IDNO AS MemberMci_IDNO,
                      b.NcpLine1_ADDR AS Line1_ADDR,
                      b.NcpLine2_ADDR AS Line2_ADDR,
                      b.NcpCity_ADDR AS City_ADDR,
                      b.NcpState_ADDR AS State_ADDR,
                      b.NcpZip_ADDR AS Zip_ADDR
                 FROM LIVAD_Y1 b
                WHERE b.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                  AND b.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                  AND b.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                  AND b.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                  AND b.FileLoad_DATE = @Ld_CpdrCur_FileLoad_DATE)x
        WHERE NOT EXISTS (SELECT 1
                            FROM PRAH_Y1 a
                           WHERE x.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                             AND x.AgSequence_NUMB = a.AgSequence_NUMB
                             AND x.MemberMci_IDNO = a.MemberMci_IDNO
                             AND a.ReferralReceived_DATE = @Ld_CpdrCur_FileLoad_DATE);

       SET @Li_RowsCount_QNTY = @@ROWCOUNT;

       IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT PRAH_Y1 FAILED';

         RAISERROR(50001,16,1);
        END
      END
     
	 --PREH_Y1
	 IF NOT EXISTS (SELECT 1
                      FROM PREH_Y1 a
                     WHERE a.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                       AND a.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                       AND a.MemberMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                       AND a.ReferralReceived_DATE = @Ld_CpdrCur_FileLoad_DATE)
         OR NOT EXISTS (SELECT 1
                          FROM PREH_Y1 a
                         WHERE a.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                           AND a.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                           AND a.MemberMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                           AND a.ReferralReceived_DATE = @Ld_CpdrCur_FileLoad_DATE)
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT PREH_Y1';
       SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CpdrCur_Seq_IDNO AS VARCHAR), '') + ', ReferralReceived_DATE = ' + ISNULL(CAST(@Ld_CpdrCur_FileLoad_DATE AS VARCHAR), '');

       INSERT PREH_Y1
              (CaseWelfare_IDNO,
               AgSequence_NUMB,
               ReferralReceived_DATE,
               MemberMci_IDNO,
               Employer_NAME,
               Fein_IDNO,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR)
       SELECT DISTINCT
              x.CaseWelfare_IDNO,
              x.AgSequence_NUMB,
              @Ld_CpdrCur_FileLoad_DATE AS ReferralReceived_DATE,
              x.MemberMci_IDNO,
              x.Employer_NAME,
              x.Fein_IDNO,
              x.Line1_ADDR,
              x.Line2_ADDR,
              x.City_ADDR,
              x.State_ADDR,
              x.Zip_ADDR
         FROM (SELECT DISTINCT
                      b.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                      b.AgSequence_NUMB AS AgSequence_NUMB,
                      b.CpMci_IDNO AS MemberMci_IDNO,
                      b.CpEmployer_NAME AS Employer_NAME,
                      b.CpEmployerFein_IDNO AS Fein_IDNO,
                      b.CpEmployerLine1_ADDR AS Line1_ADDR,
                      b.CpEmployerLine2_ADDR AS Line2_ADDR,
                      b.CpEmployerCity_ADDR AS City_ADDR,
                      b.CpEmployerState_ADDR AS State_ADDR,
                      b.CpEmployerZip_ADDR AS Zip_ADDR
                 FROM LIVAD_Y1 b
                WHERE b.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                  AND b.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                  AND b.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                  AND b.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                  AND b.FileLoad_DATE = @Ld_CpdrCur_FileLoad_DATE
               UNION
               SELECT DISTINCT
                      b.CaseWelfare_IDNO AS CaseWelfare_IDNO,
                      b.AgSequence_NUMB AS AgSequence_NUMB,
                      b.NcpMci_IDNO AS MemberMci_IDNO,
                      b.NcpEmployer_NAME AS Employer_NAME,
                      b.NcpEmployerFEIN_IDNO AS Fein_IDNO,
                      b.NcpEmployerLine1_ADDR AS Line1_ADDR,
                      b.NcpEmployerLine2_ADDR AS Line2_ADDR,
                      b.NcpEmployerCity_ADDR AS City_ADDR,
                      b.NcpEmployerState_ADDR AS State_ADDR,
                      b.NcpEmployerZip_ADDR AS Zip_ADDR
                 FROM LIVAD_Y1 b
                WHERE b.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
                  AND b.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
                  AND b.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
                  AND b.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB
                  AND b.FileLoad_DATE = @Ld_CpdrCur_FileLoad_DATE)x
        WHERE NOT EXISTS (SELECT 1
                            FROM PREH_Y1 a
                           WHERE x.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                             AND x.AgSequence_NUMB = a.AgSequence_NUMB
                             AND x.MemberMci_IDNO = a.MemberMci_IDNO
                             AND a.ReferralReceived_DATE = @Ld_CpdrCur_FileLoad_DATE);
  
       SET @Li_RowsCount_QNTY = @@ROWCOUNT;
  
       IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
        BEGIN
         SET @Ls_DescriptionError_TEXT = 'INSERT PREH_Y1 FAILED';
  
         RAISERROR(50001,16,1);
        END
	 END

     --PRSO_Y1
     SET @Ls_Sql_TEXT = 'INSERT PRSO_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_CpdrCur_Seq_IDNO AS VARCHAR), '') + ', ReferralReceived_DATE = ' + ISNULL(CAST(@Ld_CpdrCur_FileLoad_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@Ln_TransactionEventSeq_NUMB AS VARCHAR), '') + ', CaseWelfare_IDNO = ' + ISNULL(CAST(@Ln_CpdrCurCaseWelfare_IDNO AS VARCHAR), '') + ', CpMci_IDNO = ' + ISNULL(CAST(@Ln_CpdrCurCpMci_IDNO AS VARCHAR), '') + ', NcpMci_IDNO = ' + ISNULL(CAST(@Ln_CpdrCurNcpMci_IDNO AS VARCHAR), '') + ', AgSequence_NUMB = ' + ISNULL(CAST(@Ln_CpdrCurAgSequence_NUMB AS VARCHAR), '');

     INSERT PRSO_Y1
            (CaseWelfare_IDNO,
             AgSequence_NUMB,
             ReferralReceived_DATE,
             NcpInsuranceProvider_NAME,
             NcpPolicyInsNo_TEXT,
             OrderSeq_NUMB,
             OrderIssued_DATE,
             Order_AMNT,
             FreqPay_CODE,
             PaymentType_CODE,
             PaymentLastReceived_AMNT,
             PaymentLastReceived_DATE,
             TotalArrears_AMNT,
             PaymentDue_DATE,
             TransactionEventSeq_NUMB)
     SELECT DISTINCT
            l.CaseWelfare_IDNO,
            l.AgSequence_NUMB,
            @Ld_CpdrCur_FileLoad_DATE AS ReferralReceived_DATE,
            l.NcpInsuranceProvider_NAME,
            l.NcpPolicyInsNo_TEXT,
            l.OrderSeq_NUMB,
            CASE
             WHEN ISDATE(l.OrderIssued_DATE) = @Ln_Zero_NUMB
              THEN @Ld_Low_DATE
             ELSE l.OrderIssued_DATE
            END AS OrderIssued_DATE,
            l.Order_AMNT,
            l.FreqPay_CODE,
            l.PaymentType_CODE,
            l.PaymentLastReceived_AMNT,
            CASE
             WHEN ISDATE(l.PaymentLastReceived_DATE) = @Ln_Zero_NUMB
              THEN @Ld_Low_DATE
             ELSE l.PaymentLastReceived_DATE
            END AS PaymentLastReceived_DATE,
            l.TotalArrears_AMNT,
            l.PaymentDue_DATE,
            @Ln_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       FROM LIVAD_Y1 l
      WHERE l.CaseWelfare_IDNO = @Ln_CpdrCurCaseWelfare_IDNO
        AND l.CpMci_IDNO = @Ln_CpdrCurCpMci_IDNO
        AND l.NcpMci_IDNO = @Ln_CpdrCurNcpMci_IDNO
        AND l.AgSequence_NUMB = @Ln_CpdrCurAgSequence_NUMB;

     SET @Li_RowsCount_QNTY = @@ROWCOUNT;

     IF @Li_RowsCount_QNTY = @Ln_Zero_NUMB
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'INSERT PRSO_Y1 FAILED';

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM CPDR_CUR INTO @Ln_CpdrCur_Seq_IDNO, @Lc_CpdrCur_CaseWelfareIdno_TEXT, @Lc_CpdrCur_CpMciIdno_TEXT, @Lc_CpdrCur_NcpMciIdno_TEXT, @Lc_CpdrCur_AgSequenceNumb_TEXT, @Ld_CpdrCur_FileLoad_DATE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE CPDR_CUR;

   DEALLOCATE CPDR_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   -- CURSOR_STATUS implementation:
   IF CURSOR_STATUS ('LOCAL', 'CPDR_CUR') IN (0, 1)
    BEGIN
     CLOSE CPDR_CUR;

     DEALLOCATE CPDR_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
