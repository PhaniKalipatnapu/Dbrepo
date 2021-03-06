/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_CHECK$SP_PROCESS_CHECK_PRINTING]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_EXT_CHECK$SP_PROCESS_CHECK_PRINTING

Programmer Name		: IMP Team

Description	     	: Extracts all check disbursements requiring check number assignment from DSBH_Y1 and assigns 
					  check numbers sequentially by incrementing the last used check number.
					  And generates Portable Document Format (PDF) files for each check and sends them to IRM for
					  printing

Frequency			: Daily

Developed On		: 4/12/2011

Called By			:

Called On			:

--------------------------------------------------------------------------------------------------------------------
Modified By			:

Modified On			:

Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_CHECK$SP_PROCESS_CHECK_PRINTING]
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT                          CHAR(1) = ' ',
          @Lc_DisburseMediumCpCheck_TEXT          CHAR(1) = 'C',
          @Lc_StatusFailed_CODE                   CHAR(1) = 'F',
          @Lc_TypeErrorError_CODE                 CHAR(1) = 'E',
          @Lc_Mailing_CODE                        CHAR(1) = 'M',
          @Lc_VerificationStatusGood_CODE         CHAR(1) = 'Y',
          @Lc_Yes_INDC                            CHAR(1) = 'Y',
          @Lc_No_INDC                             CHAR(1) = 'N',
          @Lc_RecipientTypeCpNcp_CODE             CHAR(1) = '1',
          @Lc_RecipientTypeFips_CODE              CHAR(1) = '2',
          @Lc_RecipientTypeOthp_CODE              CHAR(1) = '3',
          @Lc_Zero_TEXT                           CHAR(1) = '0',
          @Lc_StatusCaseMemberActive_CODE         CHAR(1) = 'A',
          @Lc_RelationshipCaseNcp_CODE            CHAR(1) = 'A',
          @Lc_RelationshipCasePutFather_CODE      CHAR(1) = 'P',
          @Lc_StatusSuccess_CODE                  CHAR(1) = 'S',
          @Lc_StatusAbnormalEnd_CODE              CHAR(1) = 'A',
          @Lc_TypeOthpOffice_CODE                 CHAR(1) = 'O',
          @Lc_TaxJointJ_CODE                      CHAR(1) = 'J',
          @Lc_ErrorTypeWarning_CODE               CHAR(1) = 'W',
          @Lc_StatusOpen_CODE                     CHAR(1) = 'O',
          @Lc_DisburseStatusOutstanding_CODE      CHAR(2) = 'OU',
          @Lc_CountryUs_CODE                      CHAR(2) = 'US',
          @Lc_StatusReceiptSpecialCollection_CODE CHAR(2) = 'SC',
          @Lc_AddressTypeState_CODE               CHAR(3) = 'STA',
          @Lc_AddressSubTypeSdu_CODE              CHAR(3) = 'SDU',
          @Lc_AddressTypeInt_CODE                 CHAR(3) = 'INT',
          @Lc_AddressSubTypeFrc_CODE              CHAR(3) = 'FRC',
          @Lc_SourceBatchSpecialCollection_CODE   CHAR(3) = 'SPC',
          @Lc_TableCtry_ID                        CHAR(4) = 'CTRY',
          @Lc_ByHundred_TEXT                      CHAR(4) = '/100',
          @Lc_TableOthp_ID                        CHAR(4) = 'OTHP',
          @Lc_TableRtyp_ID                        CHAR(4) = 'RTYP',
          @Lc_TransSystemRecovery_CODE            CHAR(4) = 'SREC',
          @Lc_TransReversalDecreaseRecovery_CODE  CHAR(4) = 'RDCR',
          @Lc_WordAndwithspace_TEXT               CHAR(5) = ' AND ',
          @Lc_DisbursementTypeRefund_CODE         CHAR(5) = 'REFND',
          @Lc_BateErrorUnknown_CODE               CHAR(5) = 'E1424',
          @Lc_RecordNotFoundInAhisE0539_CODE      CHAR(5) = 'E0539',
          @Lc_ErrorE0925_CODE                     CHAR(5) = 'E0925',
          @Lc_ErrorE0712_CODE                     CHAR(5) = 'E0712',
          @Lc_ErrorE0631_CODE                     CHAR(5) = 'E0631',
          @Lc_NoRecordsToProcess_CODE             CHAR(5) = 'E0944',
          @Lc_Job_ID                              CHAR(7) = 'DEB0630',
          @Lc_Successful_TEXT                     CHAR(20) = 'SUCCESSFUL',
          @Lc_Procedure_NAME                      CHAR(30) = 'SP_PROCESS_CHECK_PRINTING',
          @Lc_Process_NAME                        CHAR(30) = 'BATCH_FIN_EXT_CHECK',
          @Lc_BatchRunUser_TEXT                   CHAR(30) = 'BATCH',
          @Ld_High_DATE                           DATE = '12/31/9999',
          @Ld_Start_DATE                          DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_FetchStatus_QNTY            NUMERIC(1),
          @Ln_CommitFreqParm_QNTY         NUMERIC(5),
          @Ln_ExceptionThreshold_QNTY     NUMERIC(5),
          @Ln_ExceptionThresholdParm_QNTY NUMERIC(5),
          @Ln_CommitFreq_QNTY             NUMERIC(5) = 0,
          @Ln_Case_IDNO                   NUMERIC(6),
          @Ln_Error_NUMB                  NUMERIC(10),
          @Ln_ErrorLine_NUMB              NUMERIC(10),
          @Ln_DsbhCursorIndex_QNTY        NUMERIC(10) = 0,
          @Ln_ProcessedRecordCount_QNTY   NUMERIC(11),
          @Ln_RecoveredTot_AMNT           NUMERIC(11, 2)=0,
          @Ln_Check_NUMB                  NUMERIC(19) =0,
          @Ln_EventGlobalSeq_NUMB         NUMERIC(19, 0),
          @Li_Rowcount_QNTY               SMALLINT,
          @Lc_Msg_CODE                    CHAR(1)='',
          @Lc_TaxJoint_CODE               CHAR(1),
          @Lc_TypeError_CODE              CHAR(1),
          @Lc_AddrState_CODE              CHAR(2),
          @Lc_Country_ADDR                CHAR(2),
          @Lc_CountyFips_CODE             CHAR(3),
          @Lc_TypeDisburse_CODE           CHAR(5),
          @Lc_BateError_CODE              CHAR(5),
          @Lc_FeesTaken_TEXT              CHAR(8)='',
          @Lc_NoCheck_TEXT                CHAR(8),
          @Lc_CheckAmount_TEXT            CHAR(10),
          @Lc_Misc_ID                     CHAR(11),
          @Lc_Zip_ADDR                    CHAR(15),
          @Lc_IVDOutOfStateCase_ID        CHAR(15),
          @Lc_City_ADDR                   CHAR(28),
          @Lc_Country_NAME                CHAR(32),
          @Lc_Line4_ADDR                  CHAR(35),
          @Lc_Line3_ADDR                  CHAR(35),
          @Lc_TaxJoint_NAME               CHAR(35),
          @Ls_CityStateZip_ADDR           VARCHAR(47),
          @Ls_Line1_ADDR                  VARCHAR(50),
          @Ls_Line2_ADDR                  VARCHAR(50),
          @Ls_Ncp_NAME                    VARCHAR(58),
          @Ls_Payee_NAME                  VARCHAR(58),
          @Ls_CheckLiteralAmount_TEXT     VARCHAR(61),
          @Ls_Sql_TEXT                    VARCHAR(200) = '',
          @Ls_CursorLocation_TEXT         VARCHAR(200) = '',
          @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT           VARCHAR(4000) = '',
          @Ls_DescriptionError_TEXT       VARCHAR(4000),
          @Ls_BateRecord_TEXT             VARCHAR(4000) = '',
          @Ld_Run_DATE                    DATE,
          @Ld_LastRun_DATE                DATE,
          @Ld_Batch_DATE                  DATE;
  DECLARE @Lc_DsbhCur_CheckRecipient_ID        CHAR(10),
          @Lc_DsbhCur_CheckRecipient_CODE      CHAR(1),
          @Ld_DsbhCur_Disburse_DATE            DATE,
          @Ln_DsbhCur_DisburseSeq_NUMB         NUMERIC (5),
          @Lc_DsbhCur_MediumDisburse_CODE      CHAR(1),
          @Ln_DsbhCur_Disburse_AMNT            NUMERIC(11, 2),
          @Ln_DsbhCur_Check_NUMB               NUMERIC(19),
          @Lc_DsbhCur_StatusCheck_CODE         CHAR(2),
          @Ld_DsbhCur_StatusCheck_DATE         DATE,
          @Lc_DsbhCur_ReasonStatus_CODE        CHAR(2),
          @Ln_DsbhCur_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Ln_DsbhCur_EventGlobalEndSeq_NUMB   NUMERIC(19),
          @Ld_DsbhCur_BeginValidity_DATE       DATE,
          @Ld_DsbhCur_EndValidity_DATE         DATE,
          @Ld_DsbhCur_Issue_DATE               DATE,
          @Lc_DsbhCur_Misc_ID                  CHAR(11);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'GET BATCH_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID;

   EXECUTE BATCH_COMMON$SP_GET_BATCH_DETAILS
    @Ac_Job_ID                  = @Lc_Job_ID,
    @Ad_Run_DATE                = @Ld_Run_DATE OUTPUT,
    @Ad_LastRun_DATE            = @Ld_LastRun_DATE OUTPUT,
    @An_CommitFreq_QNTY         = @Ln_CommitFreqParm_QNTY OUTPUT,
    @An_ExceptionThreshold_QNTY = @Ln_ExceptionThresholdParm_QNTY OUTPUT,
    @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT   = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END;

   /*
   Get the current run date and last run date from Parameters (PARM_Y1 )table, and validate that the batch program
   was not executed for the current run date, by ensuring that the run date is different from the last run date in 
   the PARM_Y1 table
   */
   SET @Ls_Sql_TEXT = 'PARM DATE CHECK';
   SET @Ls_Sqldata_TEXT = 'Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', LastRun_DATE = ' + CAST(@Ld_LastRun_DATE AS VARCHAR);

   IF DATEADD(D, 1, @Ld_LastRun_DATE) > @Ld_Run_DATE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'PARM DATE PROBLEM';

     RAISERROR (50001,16,1);
    END;

   /*
   Create the check number by selecting the last check number from the DSBH_Y1 table 
   */
   SET @Ls_Sql_TEXT = 'SELECT LATEST CHECKNO,CONTROLNO';
   SET @Ls_Sqldata_TEXT='';

   SELECT @Ln_Check_NUMB = ISNULL(MAX(a.Check_NUMB), 0),
          @Lc_Misc_ID = ISNULL(CAST(MAX(CAST(ISNULL(a.Misc_ID, @Lc_Zero_TEXT) AS NUMERIC(11))) AS VARCHAR), @Lc_Zero_TEXT)
     FROM DSBH_Y1 a
    WHERE a.Misc_ID <> @Lc_Space_TEXT;

   IF @Ln_Check_NUMB < 19999999
    BEGIN
     SET @Ln_Check_NUMB =19999999;
    END

   SET @Ls_Sql_TEXT = 'DELETE ECHCK_Y1';
   SET @Ls_Sqldata_TEXT ='yes_INDC = ' + @Lc_yes_INDC;

   DELETE FROM ECHCK_Y1
    WHERE Process_INDC = @Lc_yes_INDC;

   /*
   Select the check disbursements from DSBV/DSBH_Y1 table 
   */
   SET @Ls_Sql_TEXT = 'SELECT FROM DSBH_CUR';
   SET @Ls_Sqldata_TEXT ='';

   DECLARE Dsbh_CUR INSENSITIVE CURSOR FOR
    SELECT a.CheckRecipient_ID,
           a.CheckRecipient_CODE,
           a.Disburse_DATE,
           a.DisburseSeq_NUMB,
           a.MediumDisburse_CODE,
           a.Disburse_AMNT,
           a.Check_NUMB,
           a.StatusCheck_CODE,
           a.StatusCheck_DATE,
           a.ReasonStatus_CODE,
           a.EventGlobalBeginSeq_NUMB,
           a.EventGlobalEndSeq_NUMB,
           a.BeginValidity_DATE,
           a.EndValidity_DATE,
           a.Issue_DATE,
           a.Misc_ID
      FROM DSBH_Y1 a
     WHERE a.MediumDisburse_CODE = @Lc_DisburseMediumCpCheck_TEXT
       AND a.StatusCheck_CODE = @Lc_DisburseStatusOutstanding_CODE
       AND a.Check_NUMB = 0
       AND a.Disburse_DATE <= @Ld_Run_DATE
       AND a.EndValidity_DATE = @Ld_High_DATE
     ORDER BY a.CheckRecipient_ID,
              a.CheckRecipient_CODE,
              a.Disburse_DATE,
              a.DisburseSeq_NUMB;

   BEGIN TRANSACTION ExtractCheck;

   SET @Ls_Sql_TEXT='OPEN Dsbh_CUR';
   SET @Ls_Sqldata_TEXT ='';

   OPEN Dsbh_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Dsbh_CUR - 1';
   SET @Ls_Sqldata_TEXT ='';

   FETCH NEXT FROM Dsbh_CUR INTO @Lc_DsbhCur_CheckRecipient_ID, @Lc_DsbhCur_CheckRecipient_CODE, @Ld_DsbhCur_Disburse_DATE, @Ln_DsbhCur_DisburseSeq_NUMB, @Lc_DsbhCur_MediumDisburse_CODE, @Ln_DsbhCur_Disburse_AMNT, @Ln_DsbhCur_Check_NUMB, @Lc_DsbhCur_StatusCheck_CODE, @Ld_DsbhCur_StatusCheck_DATE, @Lc_DsbhCur_ReasonStatus_CODE, @Ln_DsbhCur_EventGlobalBeginSeq_NUMB, @Ln_DsbhCur_EventGlobalEndSeq_NUMB, @Ld_DsbhCur_BeginValidity_DATE, @Ld_DsbhCur_EndValidity_DATE, @Ld_DsbhCur_Issue_DATE, @Lc_DsbhCur_Misc_ID;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   BEGIN
    --Generate FIN-06 Notice
    WHILE @Ln_FetchStatus_QNTY = 0
     BEGIN
      BEGIN TRY
       SET @Lc_BateError_CODE =@Lc_BateErrorUnknown_CODE;
       SET @Ln_DsbhCursorIndex_QNTY = @Ln_DsbhCursorIndex_QNTY + 1;
       SET @Ls_CursorLocation_TEXT = ' DsbhCursorIndex_QNTY = ' + ISNULL(CAST(@Ln_DsbhCursorIndex_QNTY AS VARCHAR), '');
       SET @Ls_BateRecord_TEXT = ' CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR), '') + ', MediumDisburse_CODE = ' + @Lc_DsbhCur_MediumDisburse_CODE + ', Disburse_AMNT = ' + CAST(@Ln_DsbhCur_Disburse_AMNT AS VARCHAR) + ', Check_NUMB = ' + CAST(@Ln_DsbhCur_Check_NUMB AS VARCHAR) + ', StatusCheck_CODE = ' + @Lc_DsbhCur_StatusCheck_CODE + ', StatusCheck_DATE = ' + CAST(@Ld_DsbhCur_StatusCheck_DATE AS VARCHAR) + ', ReasonStatus_CODE = ' + @Lc_DsbhCur_ReasonStatus_CODE + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_DsbhCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', EventGlobalEndSeq_NUMB = ' + CAST(@Ln_DsbhCur_EventGlobalEndSeq_NUMB AS VARCHAR) + ', BeginValidity_DATE = ' + CAST(@Ld_DsbhCur_BeginValidity_DATE AS VARCHAR) + ', EndValidity_DATE = ' + CAST(@Ld_DsbhCur_EndValidity_DATE AS VARCHAR) + ', Issue_DATE = ' + CAST(@Ld_DsbhCur_Issue_DATE AS VARCHAR) + ', Misc_ID = ' + @Lc_DsbhCur_Misc_ID;
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeWarning_CODE;
       SET @Ls_Line1_ADDR = @Lc_Space_TEXT;
       SET @Ls_Line2_ADDR = @Lc_Space_TEXT;
       SET @Lc_Line3_ADDR = @Lc_Space_TEXT;
       SET @Lc_Line4_ADDR = @Lc_Space_TEXT;
       SET @Ls_CityStateZip_ADDR = @Lc_Space_TEXT;
       SET @Ls_Ncp_NAME = @Lc_Space_TEXT;
       SET @Ln_Case_IDNO = 0;
       SET @Ld_Batch_DATE =NULL;
       SET @Ln_RecoveredTot_AMNT =0;

       IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
        BEGIN
         --Get Check payee name
         SET @Ls_Sql_TEXT = 'GET CHECK PAYEE NAME';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '');

         SELECT @Ls_Payee_NAME = LTRIM(RTRIM(a.First_NAME)) + ' ' + LTRIM(RTRIM(Middle_NAME)) + ' ' + LTRIM(RTRIM(a.Last_NAME))
           FROM DEMO_Y1 a
          WHERE a.MemberMci_IDNO = CAST(@Lc_DsbhCur_CheckRecipient_ID AS NUMERIC);

         /*
         For NCP refunds: If the disbursement is the result of an original receipt being refunded that was
         from an IRS Joint Tax collection, the system will use the Tax Return Intercept Program (TRIP) address
         that was received in the special collections file and stored in the backend of the system
         */
         SET @Ls_Sql_TEXT = 'GET REFUND IRS  ADDRESS';
         SET @Ls_Sqldata_TEXT = ' CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_DsbhCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR), '') + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', DisbursementTypeRefund_CODE = ' + @Lc_DisbursementTypeRefund_CODE + ', SourceBatchSpecialCollection_CODE = ' + @Lc_SourceBatchSpecialCollection_CODE + ', StatusReceiptSpecialCollection_CODE = ' + @Lc_StatusReceiptSpecialCollection_CODE;

         SELECT TOP 1 @Ls_Line1_ADDR = C.Line1_ADDR,
                      @Ls_Line2_ADDR = C.Line2_ADDR,
                      @Lc_City_ADDR = C.City_ADDR,
                      @Lc_AddrState_CODE = C.State_ADDR,
                      @Lc_Zip_ADDR = c.Zip_ADDR,
                      @Lc_Country_ADDR = C.Country_ADDR,
                      @Lc_CountyFips_CODE = @Lc_Space_TEXT
           FROM DSBL_Y1 a,
                RCTH_Y1 b,
                TADR_Y1 c
          WHERE a.CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
            AND a.CheckRecipient_CODE = @Lc_DsbhCur_CheckRecipient_CODE
            AND a.Disburse_DATE = @Ld_DsbhCur_Disburse_DATE
            AND a.DisburseSeq_NUMB = @Ln_DsbhCur_DisburseSeq_NUMB
            AND a.TypeDisburse_CODE = @Lc_DisbursementTypeRefund_CODE
            AND a.DisburseSubSeq_NUMB = 1
            AND a.Batch_DATE = b.Batch_DATE
            AND a.Batch_NUMB = b.Batch_NUMB
            AND a.SourceBatch_CODE = b.SourceBatch_CODE
            AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
            AND b.EndValidity_DATE = @Ld_High_DATE
            AND b.SourceBatch_CODE = @Lc_SourceBatchSpecialCollection_CODE
            AND b.SourceReceipt_CODE = @Lc_StatusReceiptSpecialCollection_CODE
            AND C.Batch_DATE = b.Batch_DATE
            AND C.SourceBatch_CODE = b.SourceBatch_CODE
            AND C.Batch_NUMB = b.Batch_NUMB
            AND c.SeqReceipt_NUMB = b.SeqReceipt_NUMB;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           /*
           Get the mailing address from the Address History (AHIS_Y1) table if the recipient is either a Custodial Parent (CP)
           or Non-Custodial Parent (NCP).  Identify the recipient using the Check Recipient Code of '1' in DSBV/DSBH_Y1 table for
           the CP/NCP
           */
           SET @Ls_Sql_TEXT = 'SELECT MEMBER ADDRESS';
           SET @Ls_Sqldata_TEXT = ' CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', Mailing_CODE = ' + @Lc_Mailing_CODE + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', VerificationStatusGood_CODE = ' + @Lc_VerificationStatusGood_CODE;

           SELECT TOP 1 @Ls_Line1_ADDR = a.Line1_ADDR,
                        @Ls_Line2_ADDR = a.Line2_ADDR,
                        @Lc_City_ADDR = a.City_ADDR,
                        @Lc_AddrState_CODE = a.State_ADDR,
                        @Lc_Zip_ADDR = a.Zip_ADDR,
                        @Lc_Country_ADDR = a.Country_ADDR,
                        @Lc_CountyFips_CODE = @Lc_Space_TEXT
             FROM AHIS_Y1 a
            WHERE a.MemberMci_IDNO = CAST(@Lc_DsbhCur_CheckRecipient_ID AS NUMERIC)
              AND a.TypeAddress_CODE = @Lc_Mailing_CODE
              AND @Ld_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
              AND a.End_DATE = @Ld_High_DATE
              AND a.Status_CODE = @Lc_VerificationStatusGood_CODE;

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             /*
             If no address found in AHIS_Y1 table then write error message in BATE_Y1 table, 
             'E0539 – Record not found in AHIS'
             */
             SET @Lc_BateError_CODE = @Lc_RecordNotFoundInAhisE0539_CODE;
             SET @Ls_ErrorMessage_TEXT = 'Record not found in AHIS';

             RAISERROR (50001,16,1);
            END
          END
        END -- RecipientType Cp or Ncp
       ELSE IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
        BEGIN
         /*
             Get the mailing address from the Federal Information Processing Standard (FIPS) Reference Codes (FIPS_Y1)
             table if the recipient is an agency.  Identify the recipient using the Check Recipient Code of '2' 
             in DSBV/DSBH_Y1 table for the agency
         */
         SET @Ls_Sql_TEXT = 'SELECT AGENCY ADDRESS';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', AddressTypeState_CODE = ' + @Lc_AddressTypeState_CODE + ', AddressSubTypeSdu_CODE = ' + @Lc_AddressSubTypeSdu_CODE + ', AddressTypeInt_CODE = ' + @Lc_AddressTypeInt_CODE + ', AddressSubTypeFrc_CODE = ' + @Lc_AddressSubTypeFrc_CODE + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

         SELECT @Ls_Payee_NAME = c.Fips_NAME,
                @Ls_Line1_ADDR = c.Line1_ADDR,
                @Ls_Line2_ADDR = c.Line2_ADDR,
                @Lc_City_ADDR = c.City_ADDR,
                @Lc_AddrState_CODE = c.State_ADDR,
                @Lc_Zip_ADDR = c.Zip_ADDR,
                @Lc_Country_ADDR = c.Country_ADDR,
                @Lc_CountyFips_CODE = c.CountyFips_CODE
           FROM FIPS_Y1 c
          WHERE c.Fips_CODE = @Lc_DsbhCur_CheckRecipient_ID
            AND ((c.TypeAddress_CODE = @Lc_AddressTypeState_CODE
                  AND c.SubTypeAddress_CODE = @Lc_AddressSubTypeSdu_CODE)
                  --International FIPS for funds recipient
                  OR (c.TypeAddress_CODE = @Lc_AddressTypeInt_CODE
                      AND c.SubTypeAddress_CODE = @Lc_AddressSubTypeFrc_CODE))
            AND c.EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           /*
           If agency address record not found in FIPS then write 'E0925 - Agency address record not found in FIPS' 
           into BATE_Y1 table
           */
           SET @Lc_BateError_CODE = @Lc_ErrorE0925_CODE;
           SET @Ls_ErrorMessage_TEXT = 'Agency address record not found in FIPS';

           RAISERROR (50001,16,1);
          END
        END -- Recipient Type Fips
       ELSE IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeOthp_CODE
        BEGIN
         /*
         Get the mailing address from the Other Party (OTHP) screen/Other Party (OTHP_Y1) table if the recipient
         is an other party.  Identify the recipient using the Check Recipient Code of '3' in DSBV/DSBH_Y1 table
         for the other party
         */
         SET @Ls_Sql_TEXT = 'SELECT OTHER PARTY ADDRESS';
         SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', TypeOthpOffice_CODE = ' + @Lc_TypeOthpOffice_CODE + ', TableOthp_ID = ' + @Lc_TableOthp_ID + ', TableRtyp_ID = ' + @Lc_TableRtyp_ID + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

         SELECT @Ls_Payee_NAME = e.OtherParty_NAME,
                @Ls_Line1_ADDR = e.Line1_ADDR,
                @Ls_Line2_ADDR = e.Line2_ADDR,
                @Lc_City_ADDR = e.City_ADDR,
                @Lc_AddrState_CODE = e.State_ADDR,
                @Lc_Country_ADDR = e.Country_ADDR,
                @Lc_Zip_ADDR = e.Zip_ADDR,
                @Lc_CountyFips_CODE = e.County_IDNO
           FROM OTHP_Y1 e
          WHERE e.OtherParty_IDNO = CAST(@Lc_DsbhCur_CheckRecipient_ID AS NUMERIC)
                --Allow refund to All othp types defined in OTHP/RTYP plus the county refunds type O
                AND e.TypeOthp_CODE IN (SELECT @Lc_TypeOthpOffice_CODE
                                        UNION ALL
                                        SELECT a.Value_CODE
                                          FROM REFM_Y1 a
                                         WHERE a.Table_ID = @Lc_TableOthp_ID
                                           AND a.TableSub_ID = @Lc_TableRtyp_ID)
                AND e.EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           /*
           If no OTHP record found for the check recipient then write error message 'E0540 - Record not found in OTHP'
           in BATE_Y1 table. 
           */
           SET @Lc_BateError_CODE = @Lc_ErrorE0712_CODE;
           SET @Ls_ErrorMessage_TEXT = 'Record not found in OTHP';

           RAISERROR (50001,16,1);
          END

         IF LTRIM(RTRIM(@Ls_Line1_ADDR)) = ''
          BEGIN
           /*
           If OTHP record found but there is no Other Party Address then 
           'E0712 - No other party address exists for this ID' is written into BATE_Y1 table
                  */
           SET @Lc_BateError_CODE = @Lc_ErrorE0712_CODE;
           SET @Ls_ErrorMessage_TEXT = 'No other party address exists for this ID';

           RAISERROR (50001,16,1);
          END
        END -- Recipient Type Othp

       ---Get country name if not US.
       IF ISNULL(LTRIM(RTRIM(@Lc_Country_ADDR)), @Lc_CountryUs_CODE) = @Lc_CountryUs_CODE
        BEGIN
         SET @Lc_Country_NAME = @Lc_Space_TEXT;
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'GET COUNTRY NAME';
         SET @Ls_Sqldata_TEXT = ', TableCtry_ID = ' + @Lc_TableCtry_ID + ', TableCtry_ID = ' + @Lc_TableCtry_ID + ', Country_ADDR = ' + @Lc_Country_ADDR;
         SET @Lc_Country_NAME = dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE(@Lc_TableCtry_ID, @Lc_TableCtry_ID, @Lc_Country_ADDR);
        END

       SET @Ls_Sql_TEXT = 'GET ADDRESS LINE 3 - CONCATENATE CITY STATE ZIP';
       SET @Ls_Sqldata_TEXT = ', City_ADDR = ' + @Lc_City_ADDR + ', AddrState_CODE = ' + @Lc_AddrState_CODE + ', Zip_ADDR = ' + @Lc_Zip_ADDR;

       SELECT @Ls_CityStateZip_ADDR = SUBSTRING(LTRIM(RTRIM(@Lc_City_ADDR)) + ' ' + LTRIM(RTRIM(@Lc_AddrState_CODE)) + ' ' + (CASE
                                                                                                                               WHEN @Lc_Zip_ADDR <> ''
                                                                                                                                    AND LEN(LTRIM(RTRIM(@Lc_Zip_ADDR))) = 9
                                                                                                                                    AND @Lc_Country_ADDR = 'US'
                                                                                                                                THEN SUBSTRING(LTRIM(RTRIM(@Lc_Zip_ADDR)), 1, 5) + '-' + SUBSTRING(LTRIM(RTRIM(@Lc_Zip_ADDR)), 6, 4)
                                                                                                                               ELSE @Lc_Zip_ADDR
                                                                                                                              END), 1, 32);

       --Get addresss lines for check print 
       SET @Ls_Line1_ADDR = @Ls_Line1_ADDR;
       SET @Ls_Line2_ADDR = @Ls_Line2_ADDR;
       SET @Lc_Line3_ADDR = @Ls_CityStateZip_ADDR;
       SET @Lc_Line4_ADDR = @Lc_Country_NAME;
       ---Get Receipt_T1 details from RCTH_Y1
       SET @Ls_Sql_TEXT = 'GET Case_IDNO, Receipt DATE';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_DsbhCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR), '') + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       SELECT TOP 1 @Lc_TaxJoint_NAME = b.TaxJoint_NAME,
                    @Lc_TaxJoint_CODE = b.TaxJoint_CODE,
                    @Ln_EventGlobalSeq_NUMB = a.EventGlobalSupportSeq_NUMB,
                    @Ln_Case_IDNO = a.Case_IDNO,
                    @Lc_TypeDisburse_CODE = a.TypeDisburse_CODE,
                    @Ld_Batch_DATE = b.Batch_DATE
         FROM DSBL_Y1 a
              LEFT OUTER JOIN RCTH_Y1 b
               ON a.Batch_DATE = b.Batch_DATE
                  AND a.Batch_NUMB = b.Batch_NUMB
                  AND a.SourceBatch_CODE = b.SourceBatch_CODE
                  AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                  AND b.EndValidity_DATE = @Ld_High_DATE
        WHERE a.CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
          AND a.CheckRecipient_CODE = @Lc_DsbhCur_CheckRecipient_CODE
          AND a.Disburse_DATE = @Ld_DsbhCur_Disburse_DATE
          AND a.DisburseSeq_NUMB = @Ln_DsbhCur_DisburseSeq_NUMB
          AND a.DisburseSubSeq_NUMB = 1;

       SET @Ls_Sql_TEXT = 'GET Fees Taken Amount';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Lc_DsbhCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR), '') + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       SELECT @Ln_RecoveredTot_AMNT = ISNULL (SUM(ISNULL(b.Transaction_AMNT, 0)), 0)
         FROM CPFL_Y1 b
        WHERE Transaction_CODE IN (@Lc_TransSystemRecovery_CODE, @Lc_TransReversalDecreaseRecovery_CODE)
          AND EXISTS (SELECT 1
                        FROM DSBL_Y1 a
                       WHERE a.CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
                         AND a.CheckRecipient_CODE = @Lc_DsbhCur_CheckRecipient_CODE
                         AND a.Disburse_DATE = @Ld_DsbhCur_Disburse_DATE
                         AND a.DisburseSeq_NUMB = @Ln_DsbhCur_DisburseSeq_NUMB
                         AND a.Batch_DATE = b.Batch_DATE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND a.CheckRecipient_ID = CAST(b.MemberMci_IDNO AS VARCHAR)
                         AND a.Case_IDNO = b.Case_IDNO);

       IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
        BEGIN
         ---Check for the Case_IDNO of recipient    
         IF @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
            AND @Ln_Case_IDNO = 0
          --Added putative Father for relation case check 
          BEGIN
           SET @Ls_Sql_TEXT = 'GET Case_IDNO FOR THE CHECK RECIPIENT TYPE 1';
           SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', StatusCaseMemberActive_CODE = ' + @Lc_StatusCaseMemberActive_CODE + ', RelationshipCaseNcp_CODE = ' + @Lc_RelationshipCaseNcp_CODE + ', RelationshipCasePutFather_CODE = ' + @Lc_RelationshipCasePutFather_CODE;

           SELECT TOP 1 @Ln_Case_IDNO = a.Case_IDNO
             FROM CMEM_Y1 a
            WHERE a.MemberMci_IDNO = CAST(@Lc_DsbhCur_CheckRecipient_ID AS NUMERIC)
              AND a.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
              AND a.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE);

           SET @Li_Rowcount_QNTY = @@ROWCOUNT;

           IF @Li_Rowcount_QNTY = 0
            BEGIN
             SET @Ln_Case_IDNO = 0;
            END
          END

         IF @Lc_TypeDisburse_CODE = @Lc_DisbursementTypeRefund_CODE
            AND @Lc_DsbhCur_CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
            AND @Lc_TaxJoint_CODE = @Lc_TaxJointJ_CODE
            AND @Lc_TaxJoint_NAME <> @Lc_Space_TEXT
          BEGIN
           SET @Ls_Payee_NAME = ISNULL(LTRIM(RTRIM(@Lc_TaxJoint_NAME)), @Ls_Payee_NAME);
          END
        END

       SET @Ls_Ncp_NAME = @Lc_Space_TEXT;
       --Get NCP /Pf Name  Added putative Father for relation case check 
       SET @Ls_Sql_TEXT = 'SELECT OBLIGOR NAME';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR) + ', RelationshipCaseNcp_CODE = ' + @Lc_RelationshipCaseNcp_CODE + ', RelationshipCasePutFather_CODE = ' + @Lc_RelationshipCasePutFather_CODE + ', StatusCaseMemberActive_CODE = ' + @Lc_StatusCaseMemberActive_CODE;

       SELECT @Ls_Ncp_NAME = LTRIM(RTRIM(a.First_NAME)) + ' ' + LTRIM(RTRIM(a.Middle_NAME)) + ' ' + LTRIM (RTRIM (a.Last_NAME))
         FROM DEMO_Y1 a
        WHERE a.MemberMci_IDNO = (SELECT TOP 1 b.MemberMci_IDNO
                                    FROM CMEM_Y1 b
                                   WHERE b.Case_IDNO = @Ln_Case_IDNO
                                     AND b.CaseRelationship_CODE IN (@Lc_RelationshipCaseNcp_CODE, @Lc_RelationshipCasePutFather_CODE)
                                     AND B.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE);

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_Ncp_NAME = @Lc_Space_TEXT;
        END

       /*
            Insert the check disbursement address details for disbursing the check in the Disbursement Address Log (DADR_Y1)
            table to view the disbursement details in DSBV
            */
       SET @Ls_Sql_TEXT = 'INSERT INTO DADR_Y1';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL(@Lc_DsbhCur_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR), '') + ', Line1_ADDR = ' + @Ls_Line1_ADDR + ', Line2_ADDR = ' + @Ls_Line2_ADDR + ', City_ADDR = ' + @Lc_City_ADDR + ', AddrState_CODE = ' + @Lc_AddrState_CODE + ', Zip_ADDR = ' + @Lc_Zip_ADDR + ', Country_ADDR = ' + @Lc_Country_ADDR + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_DsbhCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', Space_TEXT = ' + @Lc_Space_TEXT;

       INSERT DADR_Y1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               Disburse_DATE,
               DisburseSeq_NUMB,
               TypeAddress_CODE,
               Attn_ADDR,
               Line1_ADDR,
               Line2_ADDR,
               City_ADDR,
               State_ADDR,
               Zip_ADDR,
               Country_ADDR,
               EventGlobalSeq_NUMB)
       VALUES ( @Lc_DsbhCur_CheckRecipient_ID,--CheckRecipient_ID
                @Lc_DsbhCur_CheckRecipient_CODE,--CheckRecipient_CODE
                @Ld_DsbhCur_Disburse_DATE,--Disburse_DATE
                @Ln_DsbhCur_DisburseSeq_NUMB,--DisburseSeq_NUMB
                @Lc_Space_TEXT,--TypeAddress_CODE
                @Lc_Space_TEXT,--Attn_ADDR
                @Ls_Line1_ADDR,--Line1_ADDR
                @Ls_Line2_ADDR,--Line2_ADDR
                @Lc_City_ADDR,--City_ADDR
                @Lc_AddrState_CODE,--State_ADDR
                @Lc_Zip_ADDR,--Zip_ADDR
                @Lc_Country_ADDR,--Country_ADDR
                @Ln_DsbhCur_EventGlobalBeginSeq_NUMB ); --EventGlobalSeq_NUMB
       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO DADR_Y1 FAILED';

         RAISERROR (50001,16,1);
        END

       SET @Lc_IVDOutOfStateCase_ID =@Lc_Space_TEXT;
       SET @Ls_Sql_TEXT = 'SELECT ICAS';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', StatusOpen_CODE =' + @Lc_StatusOpen_CODE;

       SELECT @Lc_IVDOutOfStateCase_ID = IVDOutOfStateCase_ID
         FROM ICAS_Y1 c
        WHERE c.Case_IDNO = @Ln_Case_IDNO
          AND Status_CODE = @Lc_StatusOpen_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

       IF LTRIM(RTRIM(@Ls_Line1_ADDR)) = ''
        BEGIN
         /*
         
         'E0631 - First line of address is required
                */
         SET @Lc_BateError_CODE = @Lc_ErrorE0631_CODE;
         SET @Ls_ErrorMessage_TEXT = 'First line of address is required';

         RAISERROR (50001,16,1);
        END

       IF LTRIM(RTRIM(@Ls_Line2_ADDR)) = ''
        BEGIN
         SET @Ls_Line2_ADDR = @Ls_CityStateZip_ADDR;
         SET @Lc_Line3_ADDR = @Lc_Country_NAME;
         SET @Lc_Line4_ADDR = @Lc_Space_TEXT;
        END

       IF LTRIM(RTRIM(@Lc_Line3_ADDR)) = ''
        BEGIN
         SET @Lc_Line3_ADDR = @Lc_Country_NAME;
         SET @Lc_Line4_ADDR = @Lc_Space_TEXT;
        END

       --Convert check Amount into $**,**9.99 Format
       SET @Lc_CheckAmount_TEXT = '$' + RIGHT('*********' + (LTRIM(RTRIM(CAST(@Ln_DsbhCur_Disburse_AMNT AS CHAR(9))))), 9);
       SET @Lc_FeesTaken_TEXT = '$' + RIGHT('*********' + (LTRIM(RTRIM(CAST(@Ln_RecoveredTot_AMNT AS CHAR(7))))), 7);
       --Convert Check Amount into words
       SET @Ls_CheckLiteralAmount_TEXT = CASE FLOOR(@Ln_DsbhCur_Disburse_AMNT)
                                          WHEN 0
                                           THEN @Lc_Zero_TEXT
                                          ELSE LTRIM(RTRIM(dbo.BATCH_FIN_EXT_CHECK$SF_GET_NUM_WORDS (@Ln_DsbhCur_Disburse_AMNT)))
                                         END + @Lc_WordAndwithspace_TEXT + RIGHT('00' + CONVERT(VARCHAR(2), CAST(((@Ln_DsbhCur_Disburse_AMNT * 100)% 100) AS NUMERIC(2))), 2) + @Lc_ByHundred_TEXT + '*************************************************************';
       /*
       Create the check number by selecting the last check number from the DSBH_Y1 table and incrementing it by
       one for each individual check. Update the Check Number field in DSBV/ DSBH_Y1 table for the check 
         disbursements.
         Find the maximum control number created in DSBV/DSBH_Y1, increment it by one, and update the Control
         Number field on DSBH_Y1 table, which can be viewed on DSBV
       
       */
       SET @Ls_Sql_TEXT = 'GENERATE_CHECK_NO';
       SET @Ls_Sqldata_TEXT ='Misc_ID = ' + CAST(@Lc_Misc_ID AS VARCHAR) + ', Check_NUMB = ' + CAST(@Ln_Check_NUMB AS VARCHAR);
       SET @Lc_Misc_ID = CAST ((CAST(@Lc_Misc_ID AS NUMERIC(11)) + 1) AS VARCHAR);
       SET @Ln_Check_NUMB = @Ln_Check_NUMB + 1;
       ---pad with zeros.
       SET @Lc_DsbhCur_Misc_ID = RIGHT(REPLICATE(@Lc_Zero_TEXT, 11) + CONVERT(VARCHAR(11), @Lc_Misc_ID), 11);
       SET @Lc_NoCheck_TEXT = RIGHT(REPLICATE(@Lc_Zero_TEXT, 8) + CONVERT(VARCHAR(8), CAST(@Ln_Check_NUMB AS VARCHAR)), 8);
       /*
         	Update the Check Status Date field with PROCESS-DATE in DSBV/DSBH_Y1 for the check disbursements.
       */
       SET @Ls_Sql_TEXT = 'UPDATE CHECK_NUMB,ISSUE_DATE,Misc_ID IN DSBH_Y1';
       SET @Ls_Sqldata_TEXT= 'CheckRecipient_ID = ' + @Lc_DsbhCur_CheckRecipient_ID + ', CheckRecipient_CODE = ' + @Lc_DsbhCur_CheckRecipient_CODE + ', Disburse_DATE = ' + CAST(@Ld_DsbhCur_Disburse_DATE AS VARCHAR) + ', DisburseSeq_NUMB = ' + CAST(@Ln_DsbhCur_DisburseSeq_NUMB AS VARCHAR) + ', EventGlobalBeginSeq_NUMB = ' + CAST(@Ln_DsbhCur_EventGlobalBeginSeq_NUMB AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', Check_NUMB = ' + CAST(@Ln_Check_NUMB AS VARCHAR) + ', Misc_ID = ' + @Lc_DsbhCur_Misc_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

       UPDATE DSBH_Y1
          SET Check_NUMB = @Ln_Check_NUMB,
              Misc_ID = @Lc_DsbhCur_Misc_ID,
              Issue_DATE = @Ld_Run_DATE
        WHERE CheckRecipient_ID = @Lc_DsbhCur_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_DsbhCur_CheckRecipient_CODE
          AND Disburse_DATE = @Ld_DsbhCur_Disburse_DATE
          AND DisburseSeq_NUMB = @Ln_DsbhCur_DisburseSeq_NUMB
          AND EventGlobalBeginSeq_NUMB = @Ln_DsbhCur_EventGlobalBeginSeq_NUMB
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'UPDATE DSBH_Y1 FAILED ';

         RAISERROR (50001,16,1);
        END

       --Insert extracted and formated data into ECHCK_Y1 table.
       SET @Ls_Sql_TEXT = 'INSERT INTO ECHCK_Y1';
       SET @Ls_Sqldata_TEXT = 'Check_NUMB = ' + @Lc_NoCheck_TEXT + ', Check_DATE = ' + CONVERT(CHAR(10), @Ld_Run_DATE, 101) + ', Check_AMNT = ' + @Lc_CheckAmount_TEXT + ', Payee_NAME = ' + UPPER(@Ls_Payee_NAME) + ', Payor_NAME = ' + UPPER(@Ls_Ncp_NAME) + ', Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR) + ', Line1_ADDR = ' + UPPER(@Ls_Line1_ADDR) + ', Line2_ADDR = ' + UPPER(@Ls_Line2_ADDR) + ', Line3_ADDR = ' + UPPER(@Lc_Line3_ADDR) + ', Line4_ADDR = ' + UPPER(@Lc_Line4_ADDR) + ', CheckAmountLiteral_TEXT = ' + @Ls_CheckLiteralAmount_TEXT + ', IVDOutOfStateCase_ID = ' + @Lc_IVDOutOfStateCase_ID + ', Batch_DATE = ' + CAST(@Ld_Batch_DATE AS VARCHAR) + ', FeesTaken_TEXT = ' + @Lc_FeesTaken_TEXT + ',  No_INDC = ' + @Lc_No_INDC + ', Misc_ID = ' + @Lc_DsbhCur_Misc_ID;

       INSERT ECHCK_Y1
              (Check_NUMB,
               Check_DATE,
               Receipt_DATE,
               Check_AMNT,
               Payee_NAME,
               Payor_NAME,
               Case_IDNO,
               IVDOutOfStateCase_ID,
               PaymentBatch_CODE,
               FeesTaken_AMNT,
               Line1_ADDR,
               Line2_ADDR,
               Line3_ADDR,
               Line4_ADDR,
               CheckAmountLiteral_TEXT,
               Process_INDC)
       VALUES ( RIGHT(@Lc_NoCheck_TEXT, 8),--Check_NUMB
                CONVERT(CHAR(10), @Ld_Run_DATE, 101),--Check_DATE
                ISNULL(CONVERT(CHAR(10), @Ld_Batch_DATE, 101), ''),--Receipt_DATE
                @Lc_CheckAmount_TEXT,--Check_AMNT	
                UPPER(REPLACE(@Ls_Payee_NAME, @Lc_Space_TEXT + @Lc_Space_TEXT, @Lc_Space_TEXT)),--Payee_NAME
                ISNULL(UPPER(REPLACE(@Ls_Ncp_NAME, @Lc_Space_TEXT + @Lc_Space_TEXT, @Lc_Space_TEXT)), ''),--Payor_NAME
                CAST(@Ln_Case_IDNO AS VARCHAR),--Case_IDNO
                ISNULL(CAST(@Lc_IVDOutOfStateCase_ID AS VARCHAR), ''),--IVDOutOfStateCase_ID
                @Lc_DsbhCur_Misc_ID,--PaymentBatch_CODE
                @Lc_FeesTaken_TEXT,--FeesTaken_AMNT
                UPPER(@Ls_Line1_ADDR),--Line1_ADDR
                UPPER(@Ls_Line2_ADDR),--Line2_ADDR
                UPPER(@Lc_Line3_ADDR),--Line3_ADDR
                UPPER(@Lc_Line4_ADDR),--Line4_ADDR
                LEFT(REPLACE(@Ls_CheckLiteralAmount_TEXT, @Lc_Space_TEXT + @Lc_Space_TEXT, @Lc_Space_TEXT), 80),--CheckAmountLiteral_TEXT
                @Lc_No_INDC --Process_INDC
       );

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT ECHCK_Y1 FAILED ';

         RAISERROR (50001,16,1);
        END

       IF @Ln_CommitFreqParm_QNTY <> 0
          AND @Ln_CommitFreq_QNTY >= @Ln_CommitFreqParm_QNTY
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
         SET @Ls_Sqldata_TEXT= 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', NoCheck_TEXT = ' + @Lc_NoCheck_TEXT;

         EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
          @Ac_Job_ID                = @Lc_Job_ID,
          @Ad_Run_DATE              = @Ld_Run_DATE,
          @As_RestartKey_TEXT       = @Lc_NoCheck_TEXT,
          @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END

         COMMIT TRANSACTION ExtractCheck;

         BEGIN TRANSACTION ExtractCheck;

         SET @Ln_ProcessedRecordCount_QNTY = @Ln_DsbhCursorIndex_QNTY;
         SET @Ln_CommitFreq_QNTY = 0;
        END

       SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
      END TRY

      BEGIN CATCH
       SET @Ln_Error_NUMB = ERROR_NUMBER();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE();

       IF @Ln_Error_NUMB <> 50001
        BEGIN
         SET @Lc_TypeError_CODE=@Lc_TypeErrorError_CODE;
         SET @Lc_Msg_CODE = @Lc_BateErrorUnknown_CODE;
         SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
        END

       EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
        @As_Procedure_NAME        = @Lc_Procedure_NAME,
        @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
        @As_Sql_TEXT              = @Ls_Sql_TEXT,
        @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
        @An_Error_NUMB            = @Ln_Error_NUMB,
        @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
        @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 1';
       SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_TypeError_CODE + ', CursorLocation_TEXT = ' + @Ls_CursorLocation_TEXT + ', BateError_CODE = ' + @Lc_Msg_CODE + ', DescriptionError_TEXT = ' + @Ls_ErrorMessage_TEXT + ', BateRecord_TEXT = ' + @Ls_BateRecord_TEXT;

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Lc_Process_NAME,
        @As_Procedure_NAME           = @Lc_Procedure_NAME,
        @Ac_Job_ID                   = @Lc_Job_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_DsbhCursorIndex_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
        @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
      END CATCH

      ---If exception threshold level exceeds Terminate the Process. 
      SET @Ls_Sql_TEXT = 'Threshold Level Reached';
      SET @Ls_Sqldata_TEXT ='ExceptionThreshold_QNTY = ' + CAST(@Ln_ExceptionThreshold_QNTY AS VARCHAR) + ', ExceptionThresholdParm_QNTY = ' + CAST(@Ln_ExceptionThresholdParm_QNTY AS VARCHAR);

      IF (@Ln_ExceptionThreshold_QNTY > @Ln_ExceptionThresholdParm_QNTY)
       BEGIN
        SET @Ls_ErrorMessage_TEXT = 'EXCEPTION THRESHOLD EXCEEDED';

        RAISERROR (50001,16,1);
       END

      SET @Ls_Sql_TEXT = 'FETCH CheckCur - 2';
      SET @Ls_Sqldata_TEXT= '';

      FETCH NEXT FROM Dsbh_CUR INTO @Lc_DsbhCur_CheckRecipient_ID, @Lc_DsbhCur_CheckRecipient_CODE, @Ld_DsbhCur_Disburse_DATE, @Ln_DsbhCur_DisburseSeq_NUMB, @Lc_DsbhCur_MediumDisburse_CODE, @Ln_DsbhCur_Disburse_AMNT, @Ln_DsbhCur_Check_NUMB, @Lc_DsbhCur_StatusCheck_CODE, @Ld_DsbhCur_StatusCheck_DATE, @Lc_DsbhCur_ReasonStatus_CODE, @Ln_DsbhCur_EventGlobalBeginSeq_NUMB, @Ln_DsbhCur_EventGlobalEndSeq_NUMB, @Ld_DsbhCur_BeginValidity_DATE, @Ld_DsbhCur_EndValidity_DATE, @Ld_DsbhCur_Issue_DATE, @Lc_DsbhCur_Misc_ID;

      SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE Dsbh_CUR;

   DEALLOCATE Dsbh_CUR;

   SET @Ln_ProcessedRecordCount_QNTY = @Ln_DsbhCursorIndex_QNTY;

   IF @Ln_DsbhCursorIndex_QNTY = 0
    BEGIN
     -- Log if no record to process
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG - 2';
     SET @Ls_Sqldata_TEXT = 'Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', TypeError_CODE = ' + @Lc_ErrorTypeWarning_CODE + ', DsbhCursorIndex_QNTY = ' + CAST(@Ln_DsbhCursorIndex_QNTY AS VARCHAR) + ', NoRecordsToProcess_CODE = ' + @Lc_NoRecordsToProcess_CODE + ', ErrorMessage_TEXT = ' + @Ls_ErrorMessage_TEXT + ', Sqldata_TEXT = ' + @Ls_Sqldata_TEXT;
     SET @Ls_ErrorMessage_TEXT ='No Records To Process';

     EXECUTE BATCH_COMMON$SP_BATE_LOG
      @As_Process_NAME             = @Lc_Process_NAME,
      @As_Procedure_NAME           = @Lc_Procedure_NAME,
      @Ac_Job_ID                   = @Lc_Job_ID,
      @Ad_Run_DATE                 = @Ld_Run_DATE,
      @Ac_TypeError_CODE           = @Lc_ErrorTypeWarning_CODE,
      @An_Line_NUMB                = @Ln_DsbhCursorIndex_QNTY,
      @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT,
      @Ac_Error_CODE               = @Lc_NoRecordsToProcess_CODE,
      @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionErrorOut_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END;
    END;

   -- Update the parameter table with the job run date as the current system date
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_UPDATE_PARM_DATE';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR);

   EXECUTE BATCH_COMMON$SP_UPDATE_PARM_DATE
    @Ac_Job_ID                = @Lc_Job_ID,
    @Ad_Run_DATE              = @Ld_Run_DATE,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR (50001,16,1);
    END

   -- Log the Status of job in BSTL_Y1 as Success	
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BSTL_LOG';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + @Lc_Job_ID + ', Start_DATE = ' + CAST(@Ld_Start_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ld_Run_DATE AS VARCHAR) + ', Process_NAME = ' + @Lc_Process_NAME + ', Procedure_NAME = ' + @Lc_Procedure_NAME + ', Successful_TEXT = ' + @Lc_Successful_TEXT + ', ProcessedRecordCount_QNTY = ' + CAST(@Ln_ProcessedRecordCount_QNTY AS VARCHAR) + ', StatusSuccess_CODE = ' + @Lc_StatusSuccess_CODE + ', BatchRunUser_TEXT = ' + @Lc_BatchRunUser_TEXT + ', Space_TEXT = ' + @Lc_Space_TEXT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Lc_Successful_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY,
    @As_ListKey_TEXT              = @Lc_Successful_TEXT,
    @As_DescriptionError_TEXT     = @Lc_Space_TEXT,
    @Ac_Status_CODE               = @Lc_StatusSuccess_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   COMMIT TRANSACTION ExtractCheck;
  END TRY

  BEGIN CATCH
   --Commit the Transaction 		
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION ExtractCheck;
    END

   IF CURSOR_STATUS ('LOCAL', 'Dsbh_CUR') IN (0, 1)
    BEGIN
     CLOSE Dsbh_CUR;

     DEALLOCATE Dsbh_CUR;
    END;

   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   EXECUTE BATCH_COMMON$SP_BSTL_LOG
    @Ad_Run_DATE                  = @Ld_Run_DATE,
    @Ad_Start_DATE                = @Ld_Start_DATE,
    @Ac_Job_ID                    = @Lc_Job_ID,
    @As_Process_NAME              = @Lc_Process_NAME,
    @As_Procedure_NAME            = @Lc_Procedure_NAME,
    @As_CursorLocation_TEXT       = @Lc_Space_TEXT,
    @As_ExecLocation_TEXT         = @Ls_Sql_TEXT,
    @As_ListKey_TEXT              = @Ls_Sqldata_TEXT,
    @An_ProcessedRecordCount_QNTY = @Ln_DsbhCursorIndex_QNTY,
    @As_DescriptionError_TEXT     = @Ls_DescriptionError_TEXT,
    @Ac_Status_CODE               = @Lc_StatusAbnormalend_CODE,
    @Ac_Worker_ID                 = @Lc_BatchRunUser_TEXT;

   RAISERROR (@Ls_DescriptionError_TEXT,16,1);
  END CATCH
 END


GO
