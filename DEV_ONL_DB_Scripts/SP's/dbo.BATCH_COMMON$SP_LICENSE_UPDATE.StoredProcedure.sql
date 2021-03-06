/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_LICENSE_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 -----------------------------------------------------------------------------------------------------------------------------------------------
 Procedure Name      : BATCH_COMMON$SP_LICENSE_UPDATE
 Programmer Name	 : IMP Team
 Description		 : This is the common batch to update the license information
 Frequency           : DAILY
 Developed On        : 04/12/2011
 Called BY           : None
 Called On			 : 
 ----------------------------------------------------------------------------------------------------------------------------------------------
 Modified BY         :
 Modified On         :
 Version No          : 1.0
 ----------------------------------------------------------------------------------------------------------------------------------------------
 */
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_LICENSE_UPDATE] (
 @Ac_Job_ID                   CHAR(7),
 @Ac_LicenseNo_TEXT           CHAR(25),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_TypeLicense_CODE         CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_LicenseStatus_CODE       CHAR(1),
 @Ac_IssuingState_CODE        CHAR(2),
 @Ad_IssueLicense_DATE        DATE,
 @Ad_ExpireLicense_DATE       DATE = NULL,
 @Ad_SuspLicense_DATE         DATE = NULL,
 @An_OtherParty_IDNO          NUMERIC(10),
 @Ac_SourceVerified_CODE      CHAR(3),
 @Ac_Profession_CODE          CHAR(3) = NULL,
 @As_Business_NAME            VARCHAR(50) = NULL,
 @As_Trade_NAME               VARCHAR(50) = NULL,
 @Ad_Run_DATE                 DATE,
 @Ac_Process_ID               CHAR(10),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_LicenseStatusA_CODE     CHAR(1) = 'A',
          @Lc_Status_CODECG_CODE      CHAR(2) = 'CG',
          @Lc_Status_CODEVP_CODE      CHAR(2) = 'VP',
          @Lc_Subsystem_CODE          CHAR(3) = 'LOC',
          @Lc_SourceVerifiedDmv_CODE  CHAR(3) = 'DMV',
          @Lc_ActivityMajor_CODE      CHAR(4) = 'CASE',
          @Lc_ActivityMinorRNEWL_CODE CHAR(5) = 'RNEWL',
          @Ld_Run_DATE                DATE = @Ad_Run_DATE,
          @Ld_High_DATE               DATE = '12/31/9999',
          @Ld_Low_DATE                DATE = '01/01/0001';
  DECLARE @Ln_Case_IDNO             NUMERIC(6),
          @Ln_RowCount_NUMB         NUMERIC(10) = 0,
          @Ln_Error_NUMB            NUMERIC(10),
          @Ln_ErrorLine_NUMB        NUMERIC(10),
          @Ln_FetchStatus_NUMB      NUMERIC(10),
          @Ln_Topic_IDNO            NUMERIC(19),
          @Lc_LicenseStatusOld_CODE CHAR(1),
          @Lc_Status_CODE           CHAR(2),
          @Lc_Msg_CODE              CHAR(5),
          @Ls_Procedure_NAME        VARCHAR(100),
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionNote_TEXT  VARCHAR(4000) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000),
          @Ld_Systemdatetime_DTTM   DATETIME2;
  DECLARE @Ln_CaseMemberCur_Case_IDNO      NUMERIC(6),
          @Ln_CaseMemberCur_MemberMci_IDNO NUMERIC(10);

  BEGIN TRY
   SET @Ld_Systemdatetime_DTTM = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

   IF @Ac_LicenseStatus_CODE = @Lc_LicenseStatusA_CODE
    BEGIN
     SET @Lc_Status_CODE = @Lc_Status_CODECG_CODE;
    END
   ELSE
    BEGIN
     SET @Lc_Status_CODE = @Lc_Status_CODEVP_CODE;
    END

   SET @Ls_Sql_TEXT = 'ASSINGING LICENSE STATUS';
   SET @Ls_Sqldata_TEXT = 'LicenseNo_TEXT = ' + ISNULL(@Ac_LicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Ac_TypeLicense_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   SELECT @Lc_LicenseStatusOld_CODE = LicenseStatus_CODE
     FROM PLIC_Y1 PL
    WHERE 1 = (SELECT CASE
                       WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) = 0
                        THEN
                        CASE
                         WHEN UPPER(LTRIM(RTRIM(ISNULL(PL.LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Ac_LicenseNo_TEXT)))
                          THEN 1
                         ELSE 0
                        END
                       WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) > 0
                        THEN
                        CASE
                         WHEN ISNUMERIC(ISNULL(PL.LicenseNo_TEXT, '')) > 0
                          THEN
                          CASE
                           WHEN CAST(ISNULL(PL.LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Ac_LicenseNo_TEXT AS NUMERIC)
                            THEN 1
                           ELSE 0
                          END
                         ELSE 0
                        END
                       ELSE 0
                      END)
      AND PL.MemberMci_IDNO = @An_MemberMci_IDNO
      AND PL.TypeLicense_CODE = @Ac_TypeLicense_CODE
      AND PL.EndValidity_DATE = @Ld_High_DATE;

   /* No License exists for the member */
   IF NOT EXISTS (SELECT 1
                    FROM PLIC_Y1 PL
                   WHERE 1 = (SELECT CASE
                                      WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) = 0
                                       THEN
                                       CASE
                                        WHEN UPPER(LTRIM(RTRIM(ISNULL(PL.LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Ac_LicenseNo_TEXT)))
                                         THEN 1
                                        ELSE 0
                                       END
                                      WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) > 0
                                       THEN
                                       CASE
                                        WHEN ISNUMERIC(ISNULL(PL.LicenseNo_TEXT, '')) > 0
                                         THEN
                                         CASE
                                          WHEN CAST(ISNULL(PL.LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Ac_LicenseNo_TEXT AS NUMERIC)
                                           THEN 1
                                          ELSE 0
                                         END
                                        ELSE 0
                                       END
                                      ELSE 0
                                     END)
                     AND PL.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND PL.TypeLicense_CODE = @Ac_TypeLicense_CODE
                     AND PL.EndValidity_DATE = @Ld_High_DATE)
    BEGIN
     -- Insert the License Information in PLIC_Y1 if the license number is not found
     SET @Ls_DescriptionNote_TEXT = 'License Type = ' + @Ac_TypeLicense_CODE + ', License Number = ' +@Ac_LicenseNo_TEXT + ', Issuing State = ' + @Ac_IssuingState_CODE;
     SET @Ls_Sql_TEXT = 'INSERT INTO PLIC TABLE';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Ac_TypeLicense_CODE, '') + ', LicenseNo_TEXT = ' + ISNULL(@Ac_LicenseNo_TEXT, '') + ', IssuingState_CODE = ' + ISNULL(@Ac_IssuingState_CODE, '') + ', LicenseStatus_CODE = ' + ISNULL(@Ac_LicenseStatus_CODE, '') + ', OthpLicAgent_IDNO = ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR), '') + ', IssueLicense_DATE = ' + ISNULL(CAST(@Ad_IssueLicense_DATE AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Ac_LicenseStatus_CODE, '') + ', Status_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', SourceVerified_CODE = ' + ISNULL(@Ac_SourceVerified_CODE, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID, '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Systemdatetime_DTTM AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '');

     INSERT PLIC_Y1
            (MemberMci_IDNO,
             TypeLicense_CODE,
             LicenseNo_TEXT,
             IssuingState_CODE,
             LicenseStatus_CODE,
             OthpLicAgent_IDNO,
             IssueLicense_DATE,
             ExpireLicense_DATE,
             SuspLicense_DATE,
             Status_CODE,
             Status_DATE,
             SourceVerified_CODE,
             BeginValidity_DATE,
             EndValidity_DATE,
             WorkerUpdate_ID,
             Update_DTTM,
             TransactionEventSeq_NUMB,
             Profession_CODE,
             Business_NAME,
             Trade_NAME)
     SELECT @An_MemberMci_IDNO,--MemberMci_IDNO
            @Ac_TypeLicense_CODE,--TypeLicense_CODE
            @Ac_LicenseNo_TEXT,--LicenseNo_TEXT
            @Ac_IssuingState_CODE,--IssuingState_CODE
            @Ac_LicenseStatus_CODE,--LicenseStatus_CODE
            @An_OtherParty_IDNO,--OthpLicAgent_IDNO
            @Ad_IssueLicense_DATE,--IssueLicense_DATE
            ISNULL(@Ad_ExpireLicense_DATE, @Ld_High_DATE),--ExpireLicense_DATE
--13755 - MLIC suspended dates not being cleared after license restoration -START-             
            CASE 
             WHEN @Ac_LicenseStatus_CODE = 'I'
              THEN
              CASE LTRIM(RTRIM(ISNULL(@Ac_SourceVerified_CODE, '')))
               WHEN @Lc_SourceVerifiedDmv_CODE
                THEN ISNULL(@Ad_SuspLicense_DATE, @Ld_Run_DATE)
               ELSE ISNULL(@Ad_SuspLicense_DATE, @Ld_Low_DATE)
              END
             ELSE @Ld_Low_DATE
            END AS SuspLicense_DATE,
--13755 - MLIC suspended dates not being cleared after license restoration -END-             
            @Lc_Status_CODE,--Status_CODE
            @Ad_Run_DATE,--Status_DATE
            @Ac_SourceVerified_CODE,--SourceVerified_CODE
            @Ad_Run_DATE,--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @Ac_SignedOnWorker_ID,--WorkerUpdate_ID
            @Ld_Systemdatetime_DTTM,--Update_DTTM
            @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
            ISNULL(@Ac_Profession_CODE, @Lc_Space_TEXT),--Profession_CODE
            ISNULL(@As_Business_NAME, @Lc_Space_TEXT),--Business_NAME
            ISNULL(@As_Trade_NAME, @Lc_Space_TEXT) --Trade_NAME
     SET @Ln_RowCount_NUMB = @@ROWCOUNT;

     IF @Ln_RowCount_NUMB = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO PLIC TABLE FAILED';

       RAISERROR(50001,16,1);
      END

     -- Insert activity for each open active member
     -- Cursor For Member and Case Details
     DECLARE CaseMember_CUR INSENSITIVE CURSOR FOR
      SELECT CM.Case_IDNO,
             CM.MemberMci_IDNO
        FROM CMEM_Y1 CM
             JOIN CASE_Y1 C
              ON C.Case_IDNO = CM.Case_IDNO
       WHERE CM.MemberMci_IDNO = @An_MemberMci_IDNO
         AND CM.CaseMemberStatus_CODE = 'A'
         AND CM.CaseRelationship_CODE IN ('A', 'C', 'P')
         AND C.StatusCase_CODE = 'O';

     SET @Ls_Sql_TEXT = 'OPEN CaseMember_CUR';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR);

     OPEN CaseMember_CUR;

     SET @Ls_Sql_TEXT = 'FETCH CaseMember_CUR - 1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR);

     FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

     SET @Ln_FetchStatus_NUMB = @@FETCH_STATUS;

     -- FETCH EACH CASE FOR THE MEMBER
     WHILE @Ln_FetchStatus_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT ='BATCH_COMMON$SP_INSERT_ACTIVITY';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_CaseMemberCur_MemberMci_IDNO AS VARCHAR), '') + ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorRNEWL_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '') + ', WorkerUpdate_ID = ' + ISNULL('BATCH', '') + ', WorkerDelegate_ID = ' + ISNULL(' ', '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '');

       --Case Journal Entry For the request
       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_CaseMemberCur_Case_IDNO,
        @An_MemberMci_IDNO           = @Ln_CaseMemberCur_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
        @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorRNEWL_CODE,
        @As_DescriptionNote_TEXT     = @Ls_DescriptionNote_TEXT,
        @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = 'BATCH',
        @Ac_WorkerDelegate_ID        = ' ',
        @Ac_Job_ID                   = @Ac_Job_ID,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF (@Lc_Msg_CODE = @Lc_StatusFailed_CODE)
        BEGIN
         RAISERROR (50001,16,1);
        END;

       FETCH NEXT FROM CaseMember_CUR INTO @Ln_CaseMemberCur_Case_IDNO, @Ln_CaseMemberCur_MemberMci_IDNO;

       SET @Ln_FetchStatus_NUMB = @@FETCH_STATUS;
      END;

     CLOSE CaseMember_CUR;

     DEALLOCATE CaseMember_CUR;
    END

   IF (@Lc_LicenseStatusOld_CODE <> @Ac_LicenseStatus_CODE)
    BEGIN
     /* No Active chain Exists for the member */
     IF NOT EXISTS(SELECT 1
                     FROM DMJR_Y1 MJ
                          INNER JOIN PLIC_Y1 P
                           ON P.LicenseNo_TEXT = MJ.Reference_ID
                              AND P.TypeLicense_CODE = MJ.TypeReference_CODE
                    WHERE 1 = (SELECT CASE
                                       WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) = 0
                                        THEN
                                        CASE
                                         WHEN UPPER(LTRIM(RTRIM(ISNULL(P.LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Ac_LicenseNo_TEXT)))
                                          THEN 1
                                         ELSE 0
                                        END
                                       WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) > 0
                                        THEN
                                        CASE
                                         WHEN ISNUMERIC(ISNULL(P.LicenseNo_TEXT, '')) > 0
                                          THEN
                                          CASE
                                           WHEN CAST(ISNULL(P.LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Ac_LicenseNo_TEXT AS NUMERIC)
                                            THEN 1
                                           ELSE 0
                                          END
                                         ELSE 0
                                        END
                                       ELSE 0
                                      END)
                      AND P.TypeLicense_CODE = @Ac_TypeLicense_CODE
                      AND P.MemberMci_IDNO = @An_MemberMci_IDNO
                      AND P.EndValidity_DATE = @Ld_High_DATE
                      AND MJ.ActivityMajor_CODE = 'LSNR'
                      AND MJ.Status_CODE = 'STRT')
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE PLIC TABLE - 1';
       SET @Ls_Sqldata_TEXT = 'LicenseNo_TEXT = ' + ISNULL(@Ac_LicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Ac_TypeLicense_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE PLIC_Y1
          SET LicenseStatus_CODE = @Ac_LicenseStatus_CODE,
--13755 - MLIC suspended dates not being cleared after license restoration -START-                                     
              SuspLicense_DATE = CASE 
                                  WHEN @Ac_LicenseStatus_CODE = 'I'
                                   THEN
                                   CASE LTRIM(RTRIM(ISNULL(@Ac_SourceVerified_CODE, '')))
                                    WHEN @Lc_SourceVerifiedDmv_CODE
                                     THEN ISNULL(@Ad_SuspLicense_DATE, @Ld_Run_DATE)
                                    ELSE ISNULL(@Ad_SuspLicense_DATE, @Ld_Low_DATE)
                                   END
                                  ELSE @Ld_Low_DATE
                                 END,
--13755 - MLIC suspended dates not being cleared after license restoration -END-                                    
              WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
              BeginValidity_DATE = @Ad_Run_DATE,
              Update_DTTM = @Ld_Systemdatetime_DTTM,
              TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
       OUTPUT DELETED.MemberMci_IDNO,
              DELETED.TypeLicense_CODE,
              DELETED.LicenseNo_TEXT,
              DELETED.IssuingState_CODE,
              DELETED.LicenseStatus_CODE,
              DELETED.OthpLicAgent_IDNO,
              DELETED.IssueLicense_DATE,
              DELETED.ExpireLicense_DATE,
              DELETED.SuspLicense_DATE,
              DELETED.Status_CODE,
              DELETED.Status_DATE,
              DELETED.SourceVerified_CODE,
              DELETED.BeginValidity_DATE,
              @Ad_Run_DATE AS EndValidity_DATE,
              DELETED.WorkerUpdate_ID,
              DELETED.Update_DTTM,
              DELETED.TransactionEventSeq_NUMB,
              DELETED.Profession_CODE,
              DELETED.Business_NAME,
              DELETED.Trade_NAME
       INTO PLIC_Y1
        WHERE 1 = (SELECT CASE
                           WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) = 0
                            THEN
                            CASE
                             WHEN UPPER(LTRIM(RTRIM(ISNULL(LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Ac_LicenseNo_TEXT)))
                              THEN 1
                             ELSE 0
                            END
                           WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) > 0
                            THEN
                            CASE
                             WHEN ISNUMERIC(ISNULL(LicenseNo_TEXT, '')) > 0
                              THEN
                              CASE
                               WHEN CAST(ISNULL(LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Ac_LicenseNo_TEXT AS NUMERIC)
                                THEN 1
                               ELSE 0
                              END
                             ELSE 0
                            END
                           ELSE 0
                          END)
          AND MemberMci_IDNO = @An_MemberMci_IDNO
          AND TypeLicense_CODE = @Ac_TypeLicense_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_NUMB = @@ROWCOUNT;

       IF @Ln_RowCount_NUMB = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE INTO PLIC TABLE FAILED';

         RAISERROR(50001,16,1);
        END
      END
     /* LSNR chain in suspend mode, receive active status */
     ELSE IF(@Ac_LicenseStatus_CODE = 'A')
      BEGIN
       IF EXISTS(SELECT 1
                   FROM DMJR_Y1 MJ
                        INNER JOIN PLIC_Y1 P
                         ON P.LicenseNo_TEXT = MJ.Reference_ID
                            AND P.TypeLicense_CODE = MJ.TypeReference_CODE
                        INNER JOIN DMNR_Y1 MN
                         ON MJ.Case_IDNO = MN.Case_IDNO
                            AND MJ.MajorIntSEQ_NUMB = MN.MajorIntSEQ_NUMB
                            AND MJ.OrderSeq_NUMB = MN.OrderSeq_NUMB
                  WHERE 1 = (SELECT CASE
                                     WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) = 0
                                      THEN
                                      CASE
                                       WHEN UPPER(LTRIM(RTRIM(ISNULL(P.LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Ac_LicenseNo_TEXT)))
                                        THEN 1
                                       ELSE 0
                                      END
                                     WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) > 0
                                      THEN
                                      CASE
                                       WHEN ISNUMERIC(ISNULL(P.LicenseNo_TEXT, '')) > 0
                                        THEN
                                        CASE
                                         WHEN CAST(ISNULL(P.LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Ac_LicenseNo_TEXT AS NUMERIC)
                                          THEN 1
                                         ELSE 0
                                        END
                                       ELSE 0
                                      END
                                     ELSE 0
                                    END)
                    AND P.TypeLicense_CODE = @Ac_TypeLicense_CODE
                    AND P.MemberMci_IDNO = @An_MemberMci_IDNO
                    AND P.EndValidity_DATE = @Ld_High_DATE
                    AND MJ.ActivityMajor_CODE = 'LSNR'
                    AND MJ.Status_CODE = 'STRT'
                    AND MN.ActivityMinor_CODE = 'MOFRE')
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE PLIC TABLE - 2';
         SET @Ls_Sqldata_TEXT = 'LicenseNo_TEXT = ' + ISNULL(@Ac_LicenseNo_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', TypeLicense_CODE = ' + ISNULL(@Ac_TypeLicense_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE PLIC_Y1
            SET LicenseStatus_CODE = 'A',
--13755 - MLIC suspended dates not being cleared after license restoration -START-            
                SuspLicense_DATE = @Ld_Low_DATE,
--13755 - MLIC suspended dates not being cleared after license restoration -END-                
                WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
                BeginValidity_DATE = @Ad_Run_DATE,
                Update_DTTM = @Ld_Systemdatetime_DTTM,
                TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
         OUTPUT DELETED.MemberMci_IDNO,
                DELETED.TypeLicense_CODE,
                DELETED.LicenseNo_TEXT,
                DELETED.IssuingState_CODE,
                DELETED.LicenseStatus_CODE,
                DELETED.OthpLicAgent_IDNO,
                DELETED.IssueLicense_DATE,
                DELETED.ExpireLicense_DATE,
                DELETED.SuspLicense_DATE,
                DELETED.Status_CODE,
                DELETED.Status_DATE,
                DELETED.SourceVerified_CODE,
                DELETED.BeginValidity_DATE,
                @Ad_Run_DATE AS EndValidity_DATE,
                DELETED.WorkerUpdate_ID,
                DELETED.Update_DTTM,
                DELETED.TransactionEventSeq_NUMB,
                DELETED.Profession_CODE,
                DELETED.Business_NAME,
                DELETED.Trade_NAME
         INTO PLIC_Y1
          WHERE 1 = (SELECT CASE
                             WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) = 0
                              THEN
                              CASE
                               WHEN UPPER(LTRIM(RTRIM(ISNULL(LicenseNo_TEXT, '')))) = UPPER(LTRIM(RTRIM(@Ac_LicenseNo_TEXT)))
                                THEN 1
                               ELSE 0
                              END
                             WHEN ISNUMERIC(@Ac_LicenseNo_TEXT) > 0
                              THEN
                              CASE
                               WHEN ISNUMERIC(ISNULL(LicenseNo_TEXT, '')) > 0
                                THEN
                                CASE
                                 WHEN CAST(ISNULL(LicenseNo_TEXT, '') AS NUMERIC) = CAST(@Ac_LicenseNo_TEXT AS NUMERIC)
                                  THEN 1
                                 ELSE 0
                                END
                               ELSE 0
                              END
                             ELSE 0
                            END)
            AND MemberMci_IDNO = @An_MemberMci_IDNO
            AND TypeLicense_CODE = @Ac_TypeLicense_CODE
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_NUMB = @@ROWCOUNT;

         IF @Ln_RowCount_NUMB = 0
          BEGIN
           SET @Ls_ErrorMessage_TEXT = 'UPDATE INTO PLIC TABLE FAILED';

           RAISERROR(50001,16,1);
          END
        END
      END
    END

   SET @Ac_Msg_CODE = 'S';
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('LOCAL', 'CaseMember_Cur') IN (0, 1)
    BEGIN
     CLOSE CaseMember_Cur;

     DEALLOCATE CaseMember_Cur;
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
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END 

GO
