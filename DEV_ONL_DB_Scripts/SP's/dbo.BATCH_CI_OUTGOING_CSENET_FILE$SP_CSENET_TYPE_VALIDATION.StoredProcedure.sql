/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_TYPE_VALIDATION]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_TYPE_VALIDATION
Programmer Name	:	IMP Team.
Description		:	This procedure is used to check the data type of the data loaded into Extract tables.
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
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_TYPE_VALIDATION]
 @Ac_StatusRequest_CODE    CHAR(2),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_ErrorLine_NUMB           INT = 0,
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_ReqStatusBatchError_CODE CHAR(2) = 'BE',
          @Ls_Procedure_NAME           VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_TYPE_VALIDATION',
          @Ld_High_DATE                DATE = '12/31/9999';
  DECLARE @Ln_TransHeadCur_Request_IDNO             NUMERIC(9),
          @Ln_TransHeadCur_TransHeader_IDNO         NUMERIC(12),
          @Li_Error_NUMB                            INT = 0,
          @Li_FetchStatus_NUMB                      INT,
          @Ls_Sql_TEXT                              VARCHAR(100),
          @Ls_TransHeadCur_DescriptionComments_TEXT VARCHAR(1000),
          @Ls_Sqldata_TEXT                          VARCHAR(4000),
          @Ls_DescriptionError_TEXT                 VARCHAR(4000);

  BEGIN TRY
   SET @Ac_StatusRequest_CODE = ISNULL(@Ac_StatusRequest_CODE, 'LS');
   SET @Ls_Sql_TEXT = 'VALIDATE ETHBL';

   -- Validate ETHBL_Y1
   DECLARE TransHead_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           b.Request_IDNO AS Request_IDNO,
           CASE
            WHEN LTRIM(a.StateFips_CODE) != ''
             THEN (CASE ISNUMERIC(LTRIM(RTRIM(a.StateFips_CODE)))
                    WHEN 0
                     THEN 'Invalid FIPS State ' + a.StateFips_CODE
                   END)
            ELSE ''
           END + CASE
                  WHEN LTRIM(a.CountyFips_CODE) != ''
                   THEN (CASE ISNUMERIC(LTRIM(RTRIM(a.CountyFips_CODE)))
                          WHEN 0
                           THEN 'Invalid FIPS County ' + a.CountyFips_CODE
                         END)
                  ELSE ''
                 END + CASE
                        WHEN LTRIM(a.IVDOutOfStateFips_CODE) != ''
                         THEN (CASE ISNUMERIC(LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)))
                                WHEN 0
                                 THEN 'Invalid Other Fips State ' + a.IVDOutOfStateFips_CODE
                               END)
                        ELSE ''
                       END + CASE
                              WHEN LTRIM(a.IVDOutOfStateCountyFips_CODE) != ''
                               THEN (CASE ISNUMERIC(LTRIM(RTRIM(a.IVDOutOfStateCountyFips_CODE)))
                                      WHEN 0
                                       THEN 'Invalid Other Fips County ' + a.IVDOutOfStateCountyFips_CODE
                                     END)
                              ELSE ''
                             END AS DescriptionComments_TEXT
      FROM ETHBL_Y1 a,
           CSPR_Y1 b
     WHERE a.Message_ID = b.Request_IDNO
       AND b.StatusRequest_CODE = @Ac_StatusRequest_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN TransHead_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   OPEN TransHead_CUR;

   SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 1';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Update StatusRequest to Batch Error
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     IF LTRIM(@Ls_TransHeadCur_DescriptionComments_TEXT) != ''
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 STATUS CODE - 1';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_TransHeadCur_Request_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE Request_IDNO = @Ln_TransHeadCur_Request_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;
      END;

     SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 2';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'TransHead_CUR') IN (0, 1)
    BEGIN
     CLOSE TransHead_CUR;

     DEALLOCATE TransHead_CUR;
    END;

   SET @Ls_Sql_TEXT = 'VALIDATE ECDBL';

   -- Validate ECDBL_Y1
   DECLARE TransHead_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           b.Request_IDNO AS Request_IDNO,
           CASE
            WHEN LTRIM(c.PaymentZip_ADDR) != ''
             THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.PaymentZip_ADDR)))
                    WHEN 0
                     THEN 'Invalid Zip Payment ' + c.PaymentZip_ADDR
                   END)
            ELSE ''
           END + CASE
                  WHEN LTRIM(c.ContactZip_ADDR) != ''
                   THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.ContactZip_ADDR)))
                          WHEN 0
                           THEN 'Invalid Zip - Contact ' + c.ContactZip_ADDR
                         END)
                  ELSE ''
                 END + CASE
                        WHEN LTRIM(c.AcctSendPaymentsBankNo_TEXT) != ''
                         THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.AcctSendPaymentsBankNo_TEXT)))
                                WHEN 0
                                 THEN 'Invalid Bank Acc No ' + c.AcctSendPaymentsBankNo_TEXT
                               END)
                        ELSE ''
                       END + CASE
                              WHEN LTRIM(c.SendPaymentsRouting_ID) != ''
                               THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.SendPaymentsRouting_ID)))
                                      WHEN 0
                                       THEN 'Invalid Payment routing ' + c.SendPaymentsRouting_ID
                                     END)
                              ELSE ''
                             END + CASE
                                    WHEN LTRIM(c.PayFipsSt_CODE) != ''
                                     THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.PayFipsSt_CODE)))
                                            WHEN 0
                                             THEN 'Invalid Fips State ' + c.PayFipsSt_CODE
                                           END)
                                    ELSE ''
                                   END + CASE
                                          WHEN LTRIM(c.PayFipsCnty_CODE) != ''
                                           THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.PayFipsCnty_CODE)))
                                                  WHEN 0
                                                   THEN 'Invalid Fips County ' + c.PayFipsCnty_CODE
                                                 END)
                                          ELSE ''
                                         END AS DescriptionComments_TEXT
      FROM ETHBL_Y1 a,
           CSPR_Y1 b,
           ECDBL_Y1 c
     WHERE a.Message_ID = b.Request_IDNO
       AND a.TransHeader_IDNO = c.TransHeader_IDNO
       AND b.StatusRequest_CODE = @Ac_StatusRequest_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN TransHead_CUR - 2';
   SET @Ls_Sqldata_TEXT = '';

   OPEN TransHead_CUR;

   SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 3';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Update StatusRequest to Batch Error
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     IF LTRIM(@Ls_TransHeadCur_DescriptionComments_TEXT) != ''
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 STATUS CODE - 2';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_TransHeadCur_Request_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE Request_IDNO = @Ln_TransHeadCur_Request_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;
      END;

     SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 4';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'TransHead_CUR') IN (0, 1)
    BEGIN
     CLOSE TransHead_CUR;

     DEALLOCATE TransHead_CUR;
    END;

   SET @Ls_Sql_TEXT = 'VALIDATE ENBLK';

   -- Validate ENBLK_Y1
   DECLARE TransHead_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           b.Request_IDNO AS Request_IDNO,
           CASE
            WHEN LTRIM(c.MemberSsn_NUMB) != ''
             THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.MemberSsn_NUMB)))
                    WHEN 0
                     THEN 'Invalid MemberSsn_NUMB ' + c.MemberSsn_NUMB
                   END)
            ELSE ''
           END + CASE
                  WHEN LTRIM(c.FtHeight_TEXT) != ''
                   THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.FtHeight_TEXT)))
                          WHEN 0
                           THEN 'Invalid height ft value ' + c.FtHeight_TEXT
                         END)
                  ELSE ''
                 END + CASE
                        WHEN LTRIM(c.InHeight_TEXT) != ''
                         THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.InHeight_TEXT)))
                                WHEN 0
                                 THEN 'Invalid height IN value ' + c.InHeight_TEXT
                               END)
                        ELSE ''
                       END + CASE
                              WHEN LTRIM(c.DescriptionWeightLbs_TEXT) != ''
                               THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.DescriptionWeightLbs_TEXT)))
                                      WHEN 0
                                       THEN 'Invalid weight value ' + c.DescriptionWeightLbs_TEXT
                                     END)
                              ELSE ''
                             END + CASE
                                    WHEN LTRIM(c.Alias1Ssn_NUMB) != ''
                                     THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.Alias1Ssn_NUMB)))
                                            WHEN 0
                                             THEN 'Invalid alias ssn1 ' + c.Alias1Ssn_NUMB
                                           END)
                                    ELSE ''
                                   END + CASE
                                          WHEN LTRIM(c.Alias2Ssn_NUMB) != ''
                                           THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.Alias2Ssn_NUMB)))
                                                  WHEN 0
                                                   THEN 'Invalid alias ssn2 ' + c.Alias2Ssn_NUMB
                                                 END)
                                          ELSE ''
                                         END AS DescriptionComments_TEXT
      FROM ETHBL_Y1 a,
           CSPR_Y1 b,
           ENBLK_Y1 c
     WHERE a.Message_ID = b.Request_IDNO
       AND a.TransHeader_IDNO = c.TransHeader_IDNO
       AND b.StatusRequest_CODE = @Ac_StatusRequest_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN TransHead_CUR - 3';
   SET @Ls_Sqldata_TEXT = '';

   OPEN TransHead_CUR;

   SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 5';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Update StatusRequest to Batch Error
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     IF LTRIM(@Ls_TransHeadCur_DescriptionComments_TEXT) != ''
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 STATUS CODE - 3';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_TransHeadCur_Request_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE CSPR_Y1.Request_IDNO = @Ln_TransHeadCur_Request_IDNO
          AND CSPR_Y1.EndValidity_DATE = @Ld_High_DATE;
      END;

     SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 6';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'TransHead_CUR') IN (0, 1)
    BEGIN
     CLOSE TransHead_CUR;

     DEALLOCATE TransHead_CUR;
    END;

   SET @Ls_Sql_TEXT = 'VALIDATE ENLBL';

   -- Validate ENLBL_Y1
   DECLARE TransHead_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           b.Request_IDNO AS Request_IDNO,
           CASE
            WHEN LTRIM(c.ResidentialZip1_ADDR) != ''
             THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.ResidentialZip1_ADDR)))
                    WHEN 0
                     THEN 'Invalid Resi zip1 ' + c.ResidentialZip1_ADDR
                   END)
            ELSE ''
           END + CASE
                  WHEN LTRIM(c.ResidentialZip2_ADDR) != ''
                   THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.ResidentialZip2_ADDR)))
                          WHEN 0
                           THEN 'Invalid Resi zip2 ' + c.ResidentialZip2_ADDR
                         END)
                  ELSE ''
                 END + CASE
                        WHEN LTRIM(c.MailingZip1_ADDR) != ''
                         THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.MailingZip1_ADDR)))
                                WHEN 0
                                 THEN 'Invalid Mail zip1 ' + c.MailingZip1_ADDR
                               END)
                        ELSE ''
                       END + CASE
                              WHEN LTRIM(c.MailingZip2_ADDR) != ''
                               THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.MailingZip2_ADDR)))
                                      WHEN 0
                                       THEN 'Invalid Mail zip2 ' + c.MailingZip2_ADDR
                                     END)
                              ELSE ''
                             END + CASE
                                    WHEN LTRIM(c.EmployerEin_ID) != ''
                                     THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.EmployerEin_ID)))
                                            WHEN 0
                                             THEN 'Invalid Employer EIN ' + c.EmployerEin_ID
                                           END)
                                    ELSE ''
                                   END + CASE
                                          WHEN LTRIM(c.EmployerZip1_ADDR) != ''
                                           THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.EmployerZip1_ADDR)))
                                                  WHEN 0
                                                   THEN 'Invalid EMP Zip1 ' + c.EmployerZip1_ADDR
                                                 END)
                                          ELSE ''
                                         END + CASE
                                                WHEN LTRIM(c.EmployerZip2_ADDR) != ''
                                                 THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.EmployerZip2_ADDR)))
                                                        WHEN 0
                                                         THEN 'Invalid EMP Zip2 ' + c.EmployerZip2_ADDR
                                                       END)
                                                ELSE ''
                                               END + CASE
                                                      WHEN LTRIM(c.WageQtr_CODE) != ''
                                                       THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.WageQtr_CODE)))
                                                              WHEN 0
                                                               THEN 'Invalid Wage Qtr ' + c.WageQtr_CODE
                                                             END)
                                                      ELSE ''
                                                     END + CASE
                                                            WHEN LTRIM(c.WageYear_NUMB) != ''
                                                             THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.WageYear_NUMB)))
                                                                    WHEN 0
                                                                     THEN 'Invalid Wage YEAR ' + c.WageYear_NUMB
                                                                   END)
                                                            ELSE ''
                                                           END + CASE
                                                                  WHEN LTRIM(c.Wage2Qtr_CODE) != ''
                                                                   THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.Wage2Qtr_CODE)))
                                                                          WHEN 0
                                                                           THEN 'Invalid Wage2 Qtr ' + c.Wage2Qtr_CODE
                                                                         END)
                                                                  ELSE ''
                                                                 END + CASE
                                                                        WHEN LTRIM(c.Wage2Year_NUMB) != ''
                                                                         THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.Wage2Year_NUMB)))
                                                                                WHEN 0
                                                                                 THEN 'Invalid Wage2 YEAR ' + c.Wage2Year_NUMB
                                                                               END)
                                                                        ELSE ''
                                                                       END + CASE
                                                                              WHEN LTRIM(c.Wage3Qtr_CODE) != ''
                                                                               THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.Wage3Qtr_CODE)))
                                                                                      WHEN 0
                                                                                       THEN 'Invalid Wage3 Qtr ' + c.Wage3Qtr_CODE
                                                                                     END)
                                                                              ELSE ''
                                                                             END + CASE
                                                                                    WHEN LTRIM(c.Wage3Year_NUMB) != ''
                                                                                     THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.Wage3Year_NUMB)))
                                                                                            WHEN 0
                                                                                             THEN 'Invalid Wage3 YEAR ' + c.Wage3Year_NUMB
                                                                                           END)
                                                                                    ELSE ''
                                                                                   END AS DescriptionComments_TEXT
      FROM ETHBL_Y1 a,
           CSPR_Y1 b,
           ENLBL_Y1 c
     WHERE a.Message_ID = b.Request_IDNO
       AND a.TransHeader_IDNO = c.TransHeader_IDNO
       AND b.StatusRequest_CODE = @Ac_StatusRequest_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN TransHead_CUR - 4';
   SET @Ls_Sqldata_TEXT = '';

   OPEN TransHead_CUR;

   SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 7';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Update StatusRequest to Batch Error
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     IF LTRIM(@Ls_TransHeadCur_DescriptionComments_TEXT) != ''
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 STATUS CODE - 4';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_TransHeadCur_Request_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE CSPR_Y1.Request_IDNO = @Ln_TransHeadCur_Request_IDNO
          AND CSPR_Y1.EndValidity_DATE = @Ld_High_DATE;
      END;

     SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 8';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'TransHead_CUR') IN (0, 1)
    BEGIN
     CLOSE TransHead_CUR;

     DEALLOCATE TransHead_CUR;
    END;

   SET @Ls_Sql_TEXT = 'VALIDATE EPBLK';

   -- Validate EPBLK_Y1
   DECLARE TransHead_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           b.Request_IDNO AS Request_IDNO,
           CASE
            WHEN LTRIM(c.MemberSsn_NUMB) != ''
             THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.MemberSsn_NUMB)))
                    WHEN 0
                     THEN 'Invalid MemberSsn_NUMB ' + c.MemberSsn_NUMB
                   END)
            ELSE ''
           END + CASE
                  WHEN LTRIM(c.ParticipantZip1_ADDR) != ''
                   THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.ParticipantZip1_ADDR)))
                          WHEN 0
                           THEN 'Invalid part zip1 ' + c.ParticipantZip1_ADDR
                         END)
                  ELSE ''
                 END + CASE
                        WHEN LTRIM(c.ParticipantZip2_ADDR) != ''
                         THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.ParticipantZip2_ADDR)))
                                WHEN 0
                                 THEN 'Invalid part zip2 ' + c.ParticipantZip2_ADDR
                               END)
                        ELSE ''
                       END + CASE
                              WHEN LTRIM(c.EmployerZip1_ADDR) != ''
                               THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.EmployerZip1_ADDR)))
                                      WHEN 0
                                       THEN 'Invalid emp zip1 ' + c.EmployerZip1_ADDR
                                     END)
                              ELSE ''
                             END + CASE
                                    WHEN LTRIM(c.EmployerZip2_ADDR) != ''
                                     THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.EmployerZip2_ADDR)))
                                            WHEN 0
                                             THEN 'Invalid emp zip2 ' + c.EmployerZip2_ADDR
                                           END)
                                    ELSE ''
                                   END AS DescriptionComments_TEXT
      FROM ETHBL_Y1 a,
           CSPR_Y1 b,
           EPBLK_Y1 c
     WHERE a.Message_ID = b.Request_IDNO
       AND a.TransHeader_IDNO = c.TransHeader_IDNO
       AND b.StatusRequest_CODE = @Ac_StatusRequest_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN TransHead_CUR - 5';
   SET @Ls_Sqldata_TEXT = '';

   OPEN TransHead_CUR;

   SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 9';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Update StatusRequest to Batch Error
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     IF LTRIM(@Ls_TransHeadCur_DescriptionComments_TEXT) != ''
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 STATUS CODE - 5';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_TransHeadCur_Request_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE CSPR_Y1.Request_IDNO = @Ln_TransHeadCur_Request_IDNO
          AND CSPR_Y1.EndValidity_DATE = @Ld_High_DATE;
      END;

     SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 10';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'TransHead_CUR') IN (0, 1)
    BEGIN
     CLOSE TransHead_CUR;

     DEALLOCATE TransHead_CUR;
    END;

   SET @Ls_Sql_TEXT = 'VALIDATE EOBLK';

   -- Validate EOBLK_Y1
   DECLARE TransHead_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           b.Request_IDNO AS Request_IDNO,
           CASE
            WHEN LTRIM(c.StFipsOrder_CODE) != ''
             THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.StFipsOrder_CODE)))
                    WHEN 0
                     THEN 'Invalid ORDER FIPS State ' + c.StFipsOrder_CODE
                   END)
            ELSE ''
           END + CASE
                  WHEN LTRIM(c.CntyFipsOrder_CODE) != ''
                   THEN (CASE ISNUMERIC(LTRIM(RTRIM(c.CntyFipsOrder_CODE)))
                          WHEN 0
                           THEN 'Invalid ORDER FIPS County ' + c.CntyFipsOrder_CODE
                         END)
                  ELSE ''
                 END AS DescriptionComments_TEXT
      FROM ETHBL_Y1 a,
           CSPR_Y1 b,
           EOBLK_Y1 c
     WHERE b.Request_IDNO = CAST(a.Message_ID AS NUMERIC)
       AND a.TransHeader_IDNO = c.TransHeader_IDNO
       AND b.StatusRequest_CODE = @Ac_StatusRequest_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN TransHead_CUR - 6';
   SET @Ls_Sqldata_TEXT = '';

   OPEN TransHead_CUR;

   SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 11';
   SET @Ls_Sqldata_TEXT = '';

   FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Update StatusRequest to Batch Error
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     IF LTRIM(@Ls_TransHeadCur_DescriptionComments_TEXT) != ''
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 STATUS CODE - 6';
       SET @Ls_Sqldata_TEXT = 'Request_IDNO = ' + ISNULL(CAST(@Ln_TransHeadCur_Request_IDNO AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
        WHERE CSPR_Y1.Request_IDNO = @Ln_TransHeadCur_Request_IDNO
          AND CSPR_Y1.EndValidity_DATE = @Ld_High_DATE;
      END;

     SET @Ls_Sql_TEXT = 'FETCH TransHead_CUR - 12';
     SET @Ls_Sqldata_TEXT = '';

     FETCH NEXT FROM TransHead_CUR INTO @Ln_TransHeadCur_TransHeader_IDNO, @Ln_TransHeadCur_Request_IDNO, @Ls_TransHeadCur_DescriptionComments_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'TransHead_CUR') IN (0, 1)
    BEGIN
     CLOSE TransHead_CUR;

     DEALLOCATE TransHead_CUR;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'TransHead_CUR') IN (0, 1)
    BEGIN
     CLOSE TransHead_CUR;

     DEALLOCATE TransHead_CUR;
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
