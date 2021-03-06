/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_VALIDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_VALIDATE
Programmer Name	:	IMP Team.
Description		:	This procedure will validate the loaded transactions with FAR validation specifications.
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INIT_TRAN
Called On		:	BATCH_COMMON$SP_BATE_LOG
					BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_VALIDATE]
 @Ad_Run_DATE              DATE,
 @Ac_Job_ID                CHAR(7),
 @Ac_StatusRequest_CODE    CHAR(2),
 @As_Process_NAME          VARCHAR(100),
 @Ac_Status_CODE           CHAR(2),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_DirectionOutput_CODE     CHAR(1) = 'O',
          @Lc_ErrorTypeError_CODE      CHAR(1) = 'E',
          @Lc_StatusFailed_CODE        CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE       CHAR(1) = 'S',
          @Lc_OthpEmployer_CODE        CHAR(1) = 'E',
          @Lc_ReqStatusBatchError_CODE CHAR(2) = 'BE',
          @Lc_LowdateYyyymmdd_TEXT     CHAR(10) = '01/01/0001',
          @Ls_Procedure_NAME           VARCHAR(100) = 'SP_CSENET_VALIDATE',
          @Ld_High_DATE                DATE = '12/31/9999',
          @Lb_Validation_BIT           BIT = 1;
  DECLARE @Li_Error_NUMB          INT = 0,
          @Li_ErrorLine_NUMB      INT = 0,
          @Li_Zero_NUMB           INT = 0,
          @Li_Cur_QNTY            INT = 0,
          @Li_Count_NUMB          INT,
          @Li_FetchStatus_NUMB    SMALLINT,
          @Li_FetchValStatus_NUMB SMALLINT,
          @Li_Rowcount_QNTY       SMALLINT,
          @Lc_Empty_TEXT          CHAR(1) = '',
          @Lc_OthStateFips_CODE   CHAR(2),
          @Lc_Msg_CODE            CHAR(5),
          @Ls_TempVar_TEXT        VARCHAR(100) = '',
          @Ls_ParmDefinition_TEXT VARCHAR(100),
          @Ls_SqlExcp_TEXT        VARCHAR(1000),
          @Ls_Sql_TEXT            VARCHAR(2000),
          @Ls_Where_TEXT          VARCHAR(2000),
          @Ls_ErrorDesc_TEXT      VARCHAR(2000),
          @Ls_Sqldata_TEXT        VARCHAR(4000),
          @Ld_Generated_DATE      DATE;
  DECLARE @Lc_HeaderCur_Reason_CODE            CHAR(5),
          @Lc_HeaderCur_Action_CODE            CHAR(1),
          @Lc_HeaderCur_Function_CODE          CHAR(3),
          @Lc_HeaderCur_Message_ID             CHAR(12),
          @Lc_HeaderCur_TransHeader_IDNO       CHAR(12),
          @Ld_HeaderCur_Transaction_DATE       DATE,
          @Lc_HeaderCur_IVDOutOfStateFips_CODE CHAR(2),
          @Lc_HeaderCur_Attachments_INDC       CHAR(1),
          @Lc_HeaderCur_Case_IDNO              CHAR(6);
  DECLARE @Ls_CnValCur_Column_NAME     VARCHAR(50),
          @Lc_CnValCur_Table_NAME      CHAR(30),
          @Ls_CnValCur_ComplexVal_TEXT VARCHAR(1000),
          @Lc_CnValCur_ColVal_CODE     CHAR(1),
          @Ls_CnValCur_Remarks_TEXT    VARCHAR(2000);

  BEGIN TRY
   DECLARE Header_CUR INSENSITIVE CURSOR FOR
    SELECT a.Reason_CODE,
           a.Action_CODE,
           a.Function_CODE,
           a.Message_ID,
           a.TransHeader_IDNO,
           a.Transaction_DATE,
           a.IVDOutOfStateFips_CODE,
           a.Attachments_INDC,
           a.Case_IDNO
      FROM ETHBL_Y1 a,
           CSPR_Y1 b
     WHERE b.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                   WHEN ''
                                    THEN '0'
                                   ELSE a.Message_ID
                                  END) AS NUMERIC)
       AND a.Transaction_DATE = b.Generated_DATE
       AND a.End_DATE = @Ad_Run_DATE
       AND b.StatusRequest_CODE = @Ac_StatusRequest_CODE
       AND b.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'OPEN Header_CUR';

   OPEN Header_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Header_CUR - 1';

   FETCH NEXT FROM Header_CUR INTO @Lc_HeaderCur_Reason_CODE, @Lc_HeaderCur_Action_CODE, @Lc_HeaderCur_Function_CODE, @Lc_HeaderCur_Message_ID, @Lc_HeaderCur_TransHeader_IDNO, @Ld_HeaderCur_Transaction_DATE, @Lc_HeaderCur_IVDOutOfStateFips_CODE, @Lc_HeaderCur_Attachments_INDC, @Lc_HeaderCur_Case_IDNO;

   SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

   -- Validate the Successfully Loaded records
   WHILE @Li_FetchStatus_NUMB = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT CVAL_Y1';
     SET @Ls_Sqldata_TEXT = 'Action_CODE = ' + ISNULL(@Lc_HeaderCur_Action_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_HeaderCur_Function_CODE, '');

     SELECT @Li_Count_NUMB = COUNT(1)
       FROM CVAL_Y1 a
      WHERE a.Action_CODE = @Lc_HeaderCur_Action_CODE
        AND a.Function_CODE = @Lc_HeaderCur_Function_CODE
        AND a.IoDirection_CODE IN (@Lc_DirectionOutput_CODE, @Lc_Space_TEXT);

     SET @Lb_Validation_BIT = 1;

     IF (EXISTS (SELECT TOP 1 *
                   FROM CVAL_Y1 a
                  WHERE a.Action_CODE = @Lc_HeaderCur_Action_CODE
                    AND a.Function_CODE = @Lc_HeaderCur_Function_CODE
                    AND a.IoDirection_CODE IN (@Lc_DirectionOutput_CODE, @Lc_Space_TEXT)))
      BEGIN
       DECLARE CnVal_CUR INSENSITIVE CURSOR FOR
        SELECT a.Column_NAME AS Column_NAME,
               REPLACE(UPPER(a.Table_NAME), 'LOAD', 'EXTRACT') AS Table_NAME,
               a.ComplexValidation_TEXT,
               a.ColumnValidation_CODE AS ColValidation_CODE,
               a.Remarks_TEXT
          FROM CVAL_Y1 a
         WHERE a.Action_CODE = @Lc_HeaderCur_Action_CODE
           AND a.Function_CODE = @Lc_HeaderCur_Function_CODE
           AND a.IoDirection_CODE IN (@Lc_DirectionOutput_CODE, @Lc_Space_TEXT);

       SET @Ls_Sql_TEXT = 'OPEN CnVal_CUR';

       OPEN CnVal_CUR;

       SET @Ls_Sql_TEXT = 'FETCH CnVal_CUR - 1';

       FETCH NEXT FROM CnVal_CUR INTO @Ls_CnValCur_Column_NAME, @Lc_CnValCur_Table_NAME, @Ls_CnValCur_ComplexVal_TEXT, @Lc_CnValCur_ColVal_CODE, @Ls_CnValCur_Remarks_TEXT;

       SET @Li_FetchValStatus_NUMB = @@FETCH_STATUS;

       -- Execute all the validations for the FAR combination
       WHILE @Li_FetchValStatus_NUMB = 0
        BEGIN
         SET @Li_Cur_QNTY = @Li_Cur_QNTY + 1;
         SET @Ls_SqlExcp_TEXT = 'SELECT CSPR_Y1 ' + ISNULL(@Lc_HeaderCur_Message_ID, '');
         SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         SELECT @Lc_OthStateFips_CODE = a.IVDOutOfStateFips_CODE,
                @Ld_Generated_DATE = a.Generated_DATE
           FROM CSPR_Y1 a
          WHERE a.Request_IDNO = CAST(@Lc_HeaderCur_Message_ID AS NUMERIC)
            AND a.EndValidity_DATE = @Ld_High_DATE;

         IF UPPER(@Ls_CnValCur_Column_NAME) LIKE '%_AMNT'
          BEGIN
           SET @Ls_Where_TEXT = ' CASE ' + @Ls_CnValCur_Column_NAME + ' WHEN 0 THEN ''' + @Lc_Space_TEXT + ''' ELSE ' + @Ls_CnValCur_Column_NAME + ' END ';
          END;
         ELSE IF UPPER(@Ls_CnValCur_Column_NAME) LIKE '%_DATE'
          BEGIN
           SET @Ls_Where_TEXT = ' CASE ' + @Ls_CnValCur_Column_NAME + ' WHEN CAST(''' + @Lc_LowdateYyyymmdd_TEXT + ''' AS DATETIME2) THEN ''' + @Lc_Space_TEXT + ''' ELSE ' + @Ls_CnValCur_Column_NAME + ' END ';
          END;
         ELSE
          SET @Ls_Where_TEXT = @Ls_CnValCur_Column_NAME;

         IF (@Lc_CnValCur_ColVal_CODE LIKE 'R')
          BEGIN
           SET @Ls_SqlExcp_TEXT = 'SIMPLE VALIDATION';
           SET @Ls_Sql_TEXT = N'SELECT Ls_SqlOut_TEXT = (SELECT 1 FROM ' + @Lc_CnValCur_Table_NAME + ' WHERE TransHeader_IDNO=' + @Lc_HeaderCur_TransHeader_IDNO + ' AND Transaction_DATE=''' + CAST (@Ld_HeaderCur_Transaction_DATE AS VARCHAR) + ''' AND IVDOutOfStateFips_CODE=' + @Lc_HeaderCur_IVDOutOfStateFips_CODE + ' AND  ' + ISNULL(@Ls_Where_TEXT, 'NULL') + ' IS NULL)';
           SET @Ls_ParmDefinition_TEXT = N'@Ls_SqlOut_TEXT VARCHAR(3) OUTPUT';
          END;
         ELSE
          BEGIN
           SET @Ls_CnValCur_ComplexVal_TEXT = REPLACE(@Ls_CnValCur_ComplexVal_TEXT, ':Reason_CODE', @Lc_HeaderCur_Reason_CODE);
           SET @Ls_CnValCur_ComplexVal_TEXT = REPLACE(@Ls_CnValCur_ComplexVal_TEXT, ':Attachment_INDC', @Lc_HeaderCur_Attachments_INDC);
           SET @Ls_CnValCur_ComplexVal_TEXT = REPLACE(@Ls_CnValCur_ComplexVal_TEXT, ':Attachments_INDC', @Lc_HeaderCur_Attachments_INDC);
           SET @Ls_SqlExcp_TEXT = 'COMPLEX VALIDATION CHECKING  Attachment_INDC AND Reason_CODE';
           SET @Ls_Sql_TEXT = N'SELECT @Ls_SqlOut_TEXT = (SELECT COUNT(1) FROM ' + ISNULL(@Lc_CnValCur_Table_NAME, '') + ' WHERE TransHeader_IDNO=' + ISNULL(@Lc_HeaderCur_TransHeader_IDNO, '') + ' AND Transaction_DATE=''' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ''' AND IVDOutOfStateFips_CODE=' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '') + ' AND  ' + ISNULL (@Ls_Where_TEXT, 'NULL') + ' IS NULL AND ' + ISNULL(@Ls_CnValCur_ComplexVal_TEXT, '') + ')';
           SET @Ls_ParmDefinition_TEXT = N'@Ls_SqlOut_TEXT VARCHAR(3) OUTPUT';
          END;

         IF (@Ls_TempVar_TEXT IS NULL
              OR LTRIM(@Ls_TempVar_TEXT) = '')
          BEGIN
           SET @Ls_TempVar_TEXT = '0';
          END;

         IF (CAST(@Ls_TempVar_TEXT AS INT) > 0)
          BEGIN
           SET @As_DescriptionError_TEXT = ISNULL(@Ls_SqlExcp_TEXT, '') + ' FAILED - ' + ISNULL(@Ls_CnValCur_Column_NAME, '') + ' IS REQUIRED IN ' + ISNULL(@Lc_CnValCur_Table_NAME, '') + ' FOR THE FAR COMBINATION ' + ISNULL (@Lc_HeaderCur_Function_CODE, '') + ' ' + ISNULL(@Lc_HeaderCur_Action_CODE, '') + ' ' + ISNULL(@Lc_HeaderCur_Reason_CODE, '');

           EXECUTE BATCH_COMMON$SP_BATE_LOG
            @As_Process_NAME             = @As_Process_NAME,
            @As_Procedure_NAME           = @Ls_Procedure_NAME,
            @Ac_Job_ID                   = @Ac_Job_ID,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
            @An_Line_NUMB                = 4917,
            @Ac_Error_CODE               = @Ls_Sql_TEXT,
            @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT,
            @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
            @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionErrorOut_TEXT = @Ls_ErrorDesc_TEXT OUTPUT;

           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END;

           SET @Lb_Validation_BIT = 0;
          END;

         SET @Ls_Sql_TEXT = 'FETCH CnVal_CUR - 2';

         FETCH NEXT FROM CnVal_CUR INTO @Ls_CnValCur_Column_NAME, @Lc_CnValCur_Table_NAME, @Ls_CnValCur_ComplexVal_TEXT, @Lc_CnValCur_ColVal_CODE, @Ls_CnValCur_Remarks_TEXT;

         SET @Li_FetchValStatus_NUMB = @@FETCH_STATUS;
        END;

       IF CURSOR_STATUS('LOCAL', 'CnVal_CUR') IN (0, 1)
        BEGIN
         CLOSE CnVal_CUR;

         DEALLOCATE CnVal_CUR;
        END;

       IF @Lb_Validation_BIT = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 FOR ERROR';
         SET @Ls_Sqldata_TEXT = 'Action_CODE = ' + ISNULL(@Lc_HeaderCur_Action_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_HeaderCur_Function_CODE, '') + ', Request_IDNO = ' + ISNULL(@Lc_HeaderCur_Message_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Lc_ReqStatusBatchError_CODE
          WHERE Action_CODE = @Lc_HeaderCur_Action_CODE
            AND Function_CODE = @Lc_HeaderCur_Function_CODE
            AND Request_IDNO = @Lc_HeaderCur_Message_ID
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @As_DescriptionError_TEXT = 'CSPR_Y1 UPDATE FAILED';

           RAISERROR(50001,16,1);
          END;
        END;
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 - 1';
         SET @Ls_Sqldata_TEXT = 'Action_CODE = ' + ISNULL(@Lc_HeaderCur_Action_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_HeaderCur_Function_CODE, '') + ', Request_IDNO = ' + ISNULL(@Lc_HeaderCur_Message_ID, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

         UPDATE CSPR_Y1
            SET StatusRequest_CODE = @Ac_Status_CODE
          WHERE Action_CODE = @Lc_HeaderCur_Action_CODE
            AND Function_CODE = @Lc_HeaderCur_Function_CODE
            AND Request_IDNO = @Lc_HeaderCur_Message_ID
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Li_Rowcount_QNTY = @@ROWCOUNT;

         IF @Li_Rowcount_QNTY = 0
          BEGIN
           SET @As_DescriptionError_TEXT = 'CSPR_Y1 UPDATE FAILED';

           RAISERROR(50001,16,1);
          END;
        END;
      END;
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE CSPR_Y1 - 2';
       SET @Ls_Sqldata_TEXT = 'Action_CODE = ' + ISNULL(@Lc_HeaderCur_Action_CODE, '') + ', Function_CODE = ' + ISNULL(@Lc_HeaderCur_Function_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

       UPDATE CSPR_Y1
          SET StatusRequest_CODE = @Ac_Status_CODE
        WHERE Action_CODE = @Lc_HeaderCur_Action_CODE
          AND Function_CODE = @Lc_HeaderCur_Function_CODE
          AND Request_IDNO = CAST(@Lc_HeaderCur_Message_ID AS NUMERIC)
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF @Li_Rowcount_QNTY = 0
        BEGIN
         SET @As_DescriptionError_TEXT = 'CSPR_Y1 UPDATE FAILED';

         RAISERROR(50001,16,1);
        END;
      END;

     SET @Ls_Sql_TEXT = 'FETCH Header_CUR - 2';

     FETCH NEXT FROM Header_CUR INTO @Lc_HeaderCur_Reason_CODE, @Lc_HeaderCur_Action_CODE, @Lc_HeaderCur_Function_CODE, @Lc_HeaderCur_Message_ID, @Lc_HeaderCur_TransHeader_IDNO, @Ld_HeaderCur_Transaction_DATE, @Lc_HeaderCur_IVDOutOfStateFips_CODE, @Lc_HeaderCur_Attachments_INDC, @Lc_HeaderCur_Case_IDNO;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Header_CUR') IN (0, 1)
    BEGIN
     CLOSE Header_CUR;

     DEALLOCATE Header_CUR;
    END;

   -- CSPR is updating as batch Error or Validation success after validating all columns
   SET @Ls_Sql_TEXT = 'INSERT INTO CSENET HEADER BLOCK - ALL VALIDATED RECORDS';
   SET @Ls_Sqldata_TEXT = 'Trans3Printed_INDC = ' + ISNULL(@Lc_Space_TEXT, '');

   INSERT CTHB_Y1
          (Message_ID,
           IoDirection_CODE,
           StateFips_CODE,
           CountyFips_CODE,
           OfficeFips_CODE,
           IVDOutOfStateCase_ID,
           IVDOutOfStateFips_CODE,
           IVDOutOfStateCountyFips_CODE,
           IVDOutOfStateOfficeFips_CODE,
           CsenetTran_ID,
           Function_CODE,
           Action_CODE,
           Reason_CODE,
           Case_IDNO,
           TranStatus_CODE,
           AttachDue_DATE,
           InterstateFrmsPrint_CODE,
           TimeSent_DATE,
           Due_DATE,
           Response_DATE,
           Overdue_CODE,
           WorkerUpdate_ID,
           Transaction_DATE,
           ActionResolution_DATE,
           Attachments_INDC,
           CaseData_QNTY,
           Ncp_QNTY,
           NcpLoc_QNTY,
           Participant_QNTY,
           Order_QNTY,
           Collection_QNTY,
           Info_QNTY,
           End_DATE,
           CsenetVersion_ID,
           ErrorReason_CODE,
           Received_DTTM,
           RejectReason_CODE,
           Transaction_IDNO,
           ExchangeMode_CODE,
           Trans3Printed_INDC)
   SELECT DISTINCT
          a.Message_ID,
          ISNULL(a.IoDirection_CODE, @Lc_DirectionOutput_CODE) AS IoDirection_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.StateFips_CODE)), 2) AS StateFips_CODE,
          RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(a.CountyFips_CODE)), 3) AS CountyFips_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.OfficeFips_CODE)), 2) AS OfficeFips_CODE,
          a.IVDOutOfStateCase_ID,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(a.IVDOutOfStateCountyFips_CODE)), 3) AS IVDOutOfStateCountyFips_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateOfficeFips_CODE)), 2) AS IVDOutOfStateOfficeFips_CODE,
          a.CsenetTran_ID,
          a.Function_CODE,
          a.Action_CODE,
          a.Reason_CODE,
          a.Case_IDNO,
          a.TranStatus_CODE,
          a.AttachDue_DATE,
          a.InterstateFrmsPrint_CODE,
          a.TimeSent_DATE,
          a.Due_DATE,
          a.Response_DATE,
          a.Overdue_CODE,
          a.WorkerUpdate_ID,
          a.Transaction_DATE,
          a.ActionResolution_DATE,
          a.Attachments_INDC,
          a.CaseData_QNTY,
          a.Ncp_QNTY,
          a.NcpLoc_QNTY,
          a.Participant_QNTY,
          a.Order_QNTY,
          a.Collection_QNTY,
          a.Info_QNTY,
          a.End_DATE,
          a.CsenetVersion_ID,
          a.ErrorReason_CODE,
          a.Received_DTTM,
          a.RejectReason_CODE,
          a.TransHeader_IDNO,
          a.ExchangeMode_CODE,
          @Lc_Space_TEXT AS Trans3Printed_INDC
     FROM ETHBL_Y1 a,
          CSPR_Y1 c
    WHERE c.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                  WHEN ''
                                   THEN '0'
                                  ELSE a.Message_ID
                                 END) AS NUMERIC)
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'UPDATE TRANSHEADER_IDNO IN CSPR';
   SET @Ls_Sqldata_TEXT = 'StatusRequest_CODE = ' + ISNULL(@Ac_Status_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '');

   UPDATE c
      SET c.TransHeader_IDNO = b.TransHeader_IDNO
     FROM ETHBL_Y1 a,
          CTHB_Y1 b,
          CSPR_Y1 c
    WHERE c.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                  WHEN ''
                                   THEN '0'
                                  ELSE a.Message_ID
                                 END) AS NUMERIC)
      AND b.Transaction_IDNO = a.TransHeader_IDNO
      AND b.Message_ID = a.Message_ID
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSENET CASE BLOCK - ALL VALIDATED RECORDS';
   SET @Ls_Sqldata_TEXT = '';

   INSERT CSDB_Y1
          (TransHeader_IDNO,
           IVDOutOfStateFips_CODE,
           Transaction_DATE,
           TypeCase_CODE,
           StatusCase_CODE,
           PaymentLine1_ADDR,
           PaymentLine2_ADDR,
           PaymentCity_ADDR,
           PaymentState_ADDR,
           PaymentZip_ADDR,
           Last_NAME,
           First_NAME,
           Middle_NAME,
           Suffix_NAME,
           ContactLine1_ADDR,
           ContactLine2_ADDR,
           ContactCity_ADDR,
           ContactState_ADDR,
           ContactZip_ADDR,
           ContactPhone_NUMB,
           PhoneExtensionCount_NUMB,
           RespondingFile_ID,
           Fax_NUMB,
           Contact_EML,
           InitiatingFile_ID,
           AcctSendPaymentsBankNo_TEXT,
           SendPaymentsRouting_ID,
           StateWithCej_CODE,
           PayFipsSt_CODE,
           PayFipsCnty_CODE,
           PayFipsSub_CODE,
           NondisclosureFinding_INDC)
   SELECT DISTINCT
          a.TransHeader_IDNO,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          a.Transaction_DATE,
          b.TypeCase_CODE,
          b.StatusCase_CODE,
          b.PaymentLine1_ADDR,
          b.PaymentLine2_ADDR,
          b.PaymentCity_ADDR,
          b.PaymentState_ADDR,
          b.PaymentZip_ADDR,
          b.Last_NAME,
          b.First_NAME,
          ISNULL(b.Middle_NAME, @Lc_Space_TEXT) AS Middle_NAME,
          b.Suffix_NAME,
          b.ContactLine1_ADDR,
          b.ContactLine2_ADDR,
          b.ContactCity_ADDR,
          b.ContactState_ADDR,
          b.ContactZip_ADDR,
          ISNULL(b.ContactPhone_NUMB, @Li_Zero_NUMB) AS ContactPhone_NUMB,
          ISNULL(b.PhoneExtensionCount_NUMB, @Li_Zero_NUMB) AS PhoneExtensionCount_NUMB,
          b.RespondingFile_ID,
          ISNULL(b.Fax_NUMB, @Li_Zero_NUMB) AS Fax_NUMB,
          b.Contact_EML,
          b.InitiatingFile_ID,
          b.AcctSendPaymentsBankNo_TEXT,
          b.SendPaymentsRouting_ID,
          b.StateWithCej_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.PayFipsSt_CODE)), 2) AS PayFipsSt_CODE,
          RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(b.PayFipsCnty_CODE)), 3) AS PayFipsCnty_CODE,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(b.PayFipsSub_CODE)), 2) AS PayFipsSub_CODE,
          b.NondisclosureFinding_INDC
     FROM CTHB_Y1 a,
          ECDBL_Y1 b,
          CSPR_Y1 c
    WHERE c.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                  WHEN ''
                                   THEN '0'
                                  ELSE a.Message_ID
                                 END) AS NUMERIC)
      AND c.Request_IDNO = b.TransHeader_IDNO
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSENET NCP BLOCK - ALL VALIDATED RECORDS';
   SET @Ls_Sqldata_TEXT = '';

   INSERT CNCB_Y1
          (TransHeader_IDNO,
           IVDOutOfStateFips_CODE,
           Transaction_DATE,
           MemberMci_IDNO,
           Last_NAME,
           First_NAME,
           Middle_NAME,
           Suffix_NAME,
           MemberSsn_NUMB,
           Birth_DATE,
           Race_CODE,
           MemberSex_CODE,
           PlaceOfBirth_NAME,
           FtHeight_TEXT,
           InHeight_TEXT,
           DescriptionWeightLbs_TEXT,
           ColorHair_CODE,
           ColorEyes_CODE,
           DistinguishingMarks_TEXT,
           Alias1Ssn_NUMB,
           Alias2Ssn_NUMB,
           PossiblyDangerous_INDC,
           Maiden_NAME,
           FatherOrMomMaiden_NAME)
   SELECT DISTINCT
          a.TransHeader_IDNO,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          a.Transaction_DATE,
          CAST((CASE LTRIM(b.MemberMci_IDNO)
                 WHEN ''
                  THEN '0'
                 ELSE b.MemberMci_IDNO
                END) AS NUMERIC) AS MemberMci_IDNO,
          b.Last_NAME,
          b.First_NAME,
          ISNULL(b.Middle_NAME, @Lc_Space_TEXT) AS Middle_NAME,
          b.Suffix_NAME,
          CAST((CASE LTRIM(b.MemberSsn_NUMB)
                 WHEN ''
                  THEN '0'
                 ELSE b.MemberSsn_NUMB
                END) AS NUMERIC) AS MemberSsn_NUMB,
          b.Birth_DATE,
          b.Race_CODE,
          b.MemberSex_CODE,
          b.PlaceOfBirth_NAME,
          b.FtHeight_TEXT,
          b.InHeight_TEXT,
          b.DescriptionWeightLbs_TEXT,
          b.ColorHair_CODE,
          b.ColorEyes_CODE,
          b.DistinguishingMarks_TEXT,
          CAST((CASE LTRIM(b.Alias1Ssn_NUMB)
                 WHEN ''
                  THEN '0'
                 ELSE b.Alias1Ssn_NUMB
                END) AS NUMERIC) AS Alias1Ssn_NUMB,
          CAST((CASE LTRIM(b.Alias2Ssn_NUMB)
                 WHEN ''
                  THEN '0'
                 ELSE b.Alias2Ssn_NUMB
                END) AS NUMERIC) AS Alias2Ssn_NUMB,
          b.PossiblyDangerous_INDC,
          b.Maiden_NAME,
          b.FatherOrMomMaiden_NAME
     FROM CTHB_Y1 a,
          ENBLK_Y1 b,
          CSPR_Y1 c
    WHERE c.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                  WHEN ''
                                   THEN '0'
                                  ELSE a.Message_ID
                                 END) AS NUMERIC)
      AND a.Message_ID = b.TransHeader_IDNO
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSENET NCP-LOCATE BLOCK - ALL VALIDATED RECORDS';
   SET @Ls_Sqldata_TEXT = 'LastEmployerEin_ID = ' + ISNULL(@Lc_Space_TEXT, '');

   INSERT CNLB_Y1
          (TransHeader_IDNO,
           IVDOutOfStateFips_CODE,
           Transaction_DATE,
           ResidentialLine1_ADDR,
           ResidentialLine2_ADDR,
           ResidentialCity_ADDR,
           ResidentialState_ADDR,
           ResidentialZip_ADDR,
           MailingLine1_ADDR,
           MailingLine2_ADDR,
           MailingCity_ADDR,
           MailingState_ADDR,
           MailingZip_ADDR,
           EffectiveResidential_DATE,
           EndResidential_DATE,
           ResidentialConfirmed_CODE,
           EffectiveMailing_DATE,
           EndMailing_DATE,
           MailingConfirmed_CODE,
           HomePhone_NUMB,
           WorkPhone_NUMB,
           DriversLicenseState_CODE,
           DriversLicenseNo_TEXT,
           Alias1First_NAME,
           Alias1Middle_NAME,
           Alias1Last_NAME,
           Alias1Suffix_NAME,
           Alias2First_NAME,
           Alias2Middle_NAME,
           Alias2Last_NAME,
           Alias2Suffix_NAME,
           Alias3First_NAME,
           Alias3Middle_NAME,
           Alias3Last_NAME,
           Alias3Suffix_NAME,
           SpouseLast_NAME,
           SpouseFirst_NAME,
           SpouseMiddle_NAME,
           SpouseSuffix_NAME,
           Occupation_TEXT,
           EmployerEin_ID,
           Employer_NAME,
           EmployerLine1_ADDR,
           EmployerLine2_ADDR,
           EmployerCity_ADDR,
           EmployerState_ADDR,
           EmployerZip_ADDR,
           EmployerPhone_NUMB,
           EffectiveEmployer_DATE,
           EndEmployer_DATE,
           EmployerConfirmed_INDC,
           WageQtr_CODE,
           WageYear_NUMB,
           Wage_AMNT,
           InsCarrier_NAME,
           PolicyInsNo_TEXT,
           LastResidentialLine1_ADDR,
           LastResidentialLine2_ADDR,
           LastResidentialCity_ADDR,
           LastResidentialState_ADDR,
           LastResidentialZip_ADDR,
           LastResAddress_DATE,
           LastMailLine1_ADDR,
           LastMailLine2_ADDR,
           LastMailCity_ADDR,
           LastMailState_ADDR,
           LastMailZip_ADDR,
           LastMailAddress_DATE,
           LastEmployerEin_ID,
           LastEmployer_NAME,
           LastEmployer_DATE,
           LastEmployerLine1_ADDR,
           LastEmployerLine2_ADDR,
           LastEmployerCity_ADDR,
           LastEmployerState_ADDR,
           LastEmployerZip_ADDR,
           LastEmployerEffective_DATE,
           Employer2Ein_ID,
           Employer2_NAME,
           Employer2Line1_ADDR,
           Employer2Line2_ADDR,
           Employer2City_ADDR,
           Employer2State_ADDR,
           Employer2Zip_ADDR,
           Employer2Phone_NUMB,
           EffectiveEmployer2_DATE,
           EndEmployer2_DATE,
           Employer2Confirmed_INDC,
           Wage2Qtr_CODE,
           Wage2Year_NUMB,
           Wage2_AMNT,
           Employer3Ein_ID,
           Employer3_NAME,
           Employer3Line1_ADDR,
           Employer3Line2_ADDR,
           Employer3City_ADDR,
           Employer3State_ADDR,
           Employer3Zip_ADDR,
           Employer3Phone_NUMB,
           EffectiveEmployer3_DATE,
           EndEmployer3_DATE,
           Employer3Confirmed_INDC,
           Wage3Qtr_CODE,
           Wage3Year_NUMB,
           Wage3_AMNT,
           ProfessionalLicenses_TEXT)
   SELECT DISTINCT
          a.TransHeader_IDNO,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          a.Transaction_DATE,
          b.ResidentialLine1_ADDR,
          b.ResidentialLine2_ADDR,
          b.ResidentialCity_ADDR,
          b.ResidentialState_ADDR,
          b.ResidentialZip1_ADDR + b.ResidentialZip2_ADDR AS ResidentialZip_ADDR,
          b.MailingLine1_ADDR,
          b.MailingLine2_ADDR,
          b.MailingCity_ADDR,
          b.MailingState_ADDR,
          b.MailingZip1_ADDR + b.MailingZip2_ADDR AS MailingZip_ADDR,
          b.EffectiveResidential_DATE,
          b.EndResidential_DATE,
          b.ResidentialConfirmed_CODE,
          b.EffectiveMailing_DATE,
          b.EndMailing_DATE,
          b.MailingConfirmed_CODE,
          CASE LTRIM(b.HomePhone_NUMB)
           WHEN ''
            THEN 0
           ELSE CAST(b.HomePhone_NUMB AS NUMERIC)
          END AS HomePhone_NUMB,
          CASE LTRIM(b.WorkPhone_NUMB)
           WHEN ''
            THEN 0
           ELSE CAST(b.WorkPhone_NUMB AS NUMERIC)
          END AS WorkPhone_NUMB,
          b.DriversLicenseState_CODE,
          b.DriversLicenseNo_TEXT,
          b.Alias1First_NAME,
          b.Alias1Middle_NAME,
          b.Alias1Last_NAME,
          b.Alias1Suffix_NAME,
          b.Alias2First_NAME,
          b.Alias2Middle_NAME,
          b.Alias2Last_NAME,
          b.Alias2Suffix_NAME,
          b.Alias3First_NAME,
          b.Alias3Middle_NAME,
          b.Alias3Last_NAME,
          b.Alias3Suffix_NAME,
          b.SpouseLast_NAME,
          b.SpouseFirst_NAME,
          b.SpouseMiddle_NAME,
          b.SpouseSuffix_NAME,
          b.Occupation_TEXT,
          b.EmployerEin_ID,
          b.Employer_NAME,
          b.EmployerLine1_ADDR,
          b.EmployerLine2_ADDR,
          b.EmployerCity_ADDR,
          b.EmployerState_ADDR,
          b.EmployerZip1_ADDR + b.EmployerZip2_ADDR AS EmployerZip_ADDR,
          CASE LTRIM(b.EmployerPhone_NUMB)
           WHEN ''
            THEN 0
           ELSE CAST(b.EmployerPhone_NUMB AS NUMERIC)
          END AS EmployerPhone_NUMB,
          b.EffectiveEmployer_DATE,
          b.EndEmployer_DATE,
          b.EmployerConfirmed_INDC,
          b.WageQtr_CODE,
          CASE LTRIM(b.WageYear_NUMB)
           WHEN ''
            THEN 0
           ELSE CAST(b.WageYear_NUMB AS NUMERIC)
          END AS WageYear_NUMB,
          CASE LTRIM(b.Wage_AMNT)
           WHEN ''
            THEN 0
           ELSE CAST(b.Wage_AMNT AS NUMERIC)
          END AS Wage_AMNT,
          b.InsCarrier_NAME,
          b.PolicyInsNo_TEXT,
          b.LastResidentialLine1_ADDR,
          b.LastResidentialLine2_ADDR,
          b.LastResidentialCity_ADDR,
          b.LastResidentialState_ADDR,
          b.LastResidentialZip1_ADDR + b.LastResidentialZip2_ADDR AS LastResidentialZip_ADDR,
          b.LastResAddress_DATE,
          b.LastMailLine1_ADDR,
          b.LastMailLine2_ADDR,
          b.LastMailCity_ADDR,
          b.LastMailState_ADDR,
          b.LastMailZip1_ADDR + b.LastMailZip2_ADDR AS LastMailZip_ADDR,
          b.LastMailAddress_DATE,
          @Lc_Space_TEXT AS LastEmployerEin_ID,
          b.LastEmployer_NAME,
          b.LastEmployer_DATE,
          b.LastEmployerLine1_ADDR,
          b.LastEmployerLine2_ADDR,
          b.LastEmployerCity_ADDR,
          b.LastEmployerState_ADDR,
          b.LastEmployerZip1_ADDR + b.LastEmployerZip2_ADDR AS LastEmployerZip_ADDR,
          b.LastEmployerEffective_DATE,
          b.Employer2Ein_ID,
          b.Employer2_NAME,
          b.Employer2Line1_ADDR,
          b.Employer2Line2_ADDR,
          b.Employer2City_ADDR,
          b.Employer2State_ADDR,
          b.Employer2Zip1_ADDR + b.Employer2Zip2_ADDR AS Employer2Zip_ADDR,
          CASE LTRIM(b.Employer2Phone_NUMB)
           WHEN ''
            THEN 0
           ELSE CAST(b.Employer2Phone_NUMB AS NUMERIC)
          END AS Employer2Phone_NUMB,
          b.EffectiveEmployer2_DATE,
          b.EndEmployer2_DATE,
          b.Employer2Confirmed_INDC,
          b.Wage2Qtr_CODE,
          CASE LTRIM(b.Wage2Year_NUMB)
           WHEN ''
            THEN 0
           ELSE CAST(b.Wage2Year_NUMB AS NUMERIC)
          END AS Wage2Year_NUMB,
          CASE LTRIM(b.Wage2_AMNT)
           WHEN ''
            THEN 0
           ELSE CAST(b.Wage2_AMNT AS NUMERIC)
          END AS Wage2_AMNT,
          b.Employer3Ein_ID,
          b.Employer3_NAME,
          b.Employer3Line1_ADDR,
          b.Employer3Line2_ADDR,
          b.Employer3City_ADDR,
          b.Employer3State_ADDR,
          b.Employer3Zip1_ADDR + b.Employer3Zip2_ADDR AS Employer3Zip_ADDR,
          CASE LTRIM(b.Employer3Phone_NUMB)
           WHEN ''
            THEN 0
           ELSE CAST(b.Employer3Phone_NUMB AS NUMERIC)
          END AS Employer3Phone_NUMB,
          b.EffectiveEmployer3_DATE,
          b.EndEmployer3_DATE,
          b.Employer3Confirmed_INDC,
          b.Wage3Qtr_CODE,
          CASE LTRIM(b.Wage3Year_NUMB)
           WHEN ''
            THEN 0
           ELSE CAST(b.Wage3Year_NUMB AS NUMERIC)
          END AS Wage3Year_NUMB,
          CASE LTRIM(b.Wage3_AMNT)
           WHEN ''
            THEN 0
           ELSE CAST(b.Wage3_AMNT AS NUMERIC)
          END AS Wage3_AMNT,
          b.ProfessionalLicenses_TEXT
     FROM CTHB_Y1 a,
          ENLBL_Y1 b,
          CSPR_Y1 c
    WHERE c.Request_IDNO = (CASE LTRIM(a.Message_ID)
                             WHEN ''
                              THEN '0'
                             ELSE a.Message_ID
                            END)
      AND a.Message_ID = b.TransHeader_IDNO
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'UPDATE LAST EMPLOYER EIN_ID';
   SET @Ls_Sqldata_TEXT = '';

   UPDATE a
      SET LastEmployerEin_ID = ISNULL((SELECT TOP 1 Fein_IDNO
                                         FROM OTHP_Y1 b
                                        WHERE b.OtherParty_Name = a.LastEmployer_NAME
                                          AND b.Line1_ADDR = a.LastEmployerLine1_ADDR
                                          AND b.Line2_ADDR = a.LastEmployerLine2_ADDR
                                          AND b.City_addr = a.LastEmployerCity_ADDR
                                          AND b.State_Addr = a.LastEmployerState_ADDR
                                          AND b.Zip_Addr = a.LastEmployerZip_ADDR
                                          AND b.EndValidity_date = @Ld_High_DATE
                                          AND b.TypeOthp_code = @Lc_OthpEmployer_CODE), '0')
     FROM CNLB_Y1 a
    WHERE a.LastEmployer_NAME <> @Lc_Empty_TEXT
      AND a.LastEmployerLine1_ADDR <> @Lc_Empty_TEXT;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSENET PARTICIPANT BLOCK - ALL VALIDATED RECORDS';
   SET @Ls_Sqldata_TEXT = '';

   INSERT CPTB_Y1
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
           ParticipantZip_ADDR,
           Employer_NAME,
           EmployerLine1_ADDR,
           EmployerLine2_ADDR,
           EmployerCity_ADDR,
           EmployerState_ADDR,
           EmployerZip_ADDR,
           EinEmployer_ID,
           ConfirmedAddress_INDC,
           ConfirmedAddress_DATE,
           ConfirmedEmployer_INDC,
           ConfirmedEmployer_DATE,
           WorkPhone_NUMB,
           PlaceOfBirth_NAME,
           ChildStateResidence_CODE,
           ChildPaternityStatus_CODE)
   SELECT DISTINCT
          CAST((CASE LTRIM(a.TransHeader_IDNO)
                 WHEN ''
                  THEN '0'
                 ELSE a.TransHeader_IDNO
                END) AS NUMERIC) AS TransHeader_IDNO,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          a.Transaction_DATE,
          CAST((CASE LTRIM(b.BlockSeq_NUMB)
                 WHEN ''
                  THEN '0'
                 ELSE b.BlockSeq_NUMB
                END) AS NUMERIC) AS BlockSeq_NUMB,
          CAST((CASE LTRIM(b.MemberMci_IDNO)
                 WHEN ''
                  THEN '0'
                 ELSE b.MemberMci_IDNO
                END) AS NUMERIC) AS MemberMci_IDNO,
          b.Last_NAME,
          b.First_NAME,
          b.Middle_NAME,
          b.Suffix_NAME,
          b.Birth_DATE,
          CAST((CASE LTRIM(b.MemberSsn_NUMB)
                 WHEN ''
                  THEN '0'
                 ELSE b.MemberSsn_NUMB
                END) AS NUMERIC) AS MemberSsn_NUMB,
          b.MemberSex_CODE,
          b.Race_CODE,
          b.Relationship_CODE,
          b.ParticipantStatus_CODE,
          b.ChildRelationshipNcp_CODE,
          b.ParticipantLine1_ADDR,
          b.ParticipantLine2_ADDR,
          b.ParticipantCity_ADDR,
          b.ParticipantState_ADDR,
          b.ParticipantZip1_ADDR + b.ParticipantZip2_ADDR AS ParticipantZip_ADDR,
          b.Employer_NAME,
          b.EmployerLine1_ADDR,
          b.EmployerLine2_ADDR,
          b.EmployerCity_ADDR,
          b.EmployerState_ADDR,
          b.EmployerZip1_ADDR + b.EmployerZip2_ADDR AS EmployerZip_ADDR,
          b.EinEmployer_ID,
          b.ConfirmedAddress_INDC,
          b.ConfirmedAddress_DATE,
          b.ConfirmedEmployer_INDC,
          b.ConfirmedEmployer_DATE,
          CAST((CASE LTRIM(b.WorkPhone_NUMB)
                 WHEN ''
                  THEN '0'
                 ELSE b.WorkPhone_NUMB
                END) AS NUMERIC) AS WorkPhone_NUMB,
          b.PlaceOfBirth_NAME,
          b.ChildStateResidence_CODE,
          b.ChildPaternityStatus_CODE
     FROM CTHB_Y1 a,
          EPBLK_Y1 b,
          CSPR_Y1 c
    WHERE c.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                  WHEN ''
                                   THEN '0'
                                  ELSE a.Message_ID
                                 END) AS NUMERIC)
      AND a.Message_ID = b.TransHeader_IDNO
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSENET ORDER BLOCK - ALL VALIDATED RECORDS';
   SET @Ls_Sqldata_TEXT = '';

   INSERT CORB_Y1
          (TransHeader_IDNO,
           IVDOutOfStateFips_CODE,
           Transaction_DATE,
           BlockSeq_NUMB,
           StFipsOrder_CODE,
           CntyFipsOrder_CODE,
           SubFipsOrder_CODE,
           CsenetOrder_ID,
           FilingOrder_DATE,
           TypeOrder_CODE,
           DebtType_CODE,
           OrderFreq_CODE,
           OrderFreq_AMNT,
           OrderEffective_DATE,
           OrderEnd_DATE,
           OrderCancel_DATE,
           FreqOrderArrears_CODE,
           FreqOrderArrears_AMNT,
           OrderArrearsTotal_AMNT,
           ArrearsAfdcFrom_DATE,
           ArrearsAfdcThru_DATE,
           ArrearsAfdc_AMNT,
           ArrearsNonAfdcFrom_DATE,
           ArrearsNonAfdcThru_DATE,
           ArrearsNonAfdc_AMNT,
           FosterCareFrom_DATE,
           FosterCareThru_DATE,
           FosterCare_AMNT,
           MedicalFrom_DATE,
           MedicalThru_DATE,
           Medical_AMNT,
           MedicalOrdered_INDC,
           TribunalCaseNo_TEXT,
           OfLastPayment_DATE,
           ControllingOrderFlag_CODE,
           NewOrderFlag_INDC,
           File_ID)
   SELECT DISTINCT
          a.TransHeader_IDNO,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          a.Transaction_DATE,
          b.BlockSeq_NUMB,
          b.StFipsOrder_CODE,
          b.CntyFipsOrder_CODE,
          b.SubFipsOrder_CODE,
          b.Order_IDNO,
          b.FilingOrder_DATE,
          b.TypeOrder_CODE,
          b.DebtType_CODE,
          b.OrderFreq_CODE,
          b.OrderFreq_AMNT,
          b.OrderEffective_DATE,
          b.OrderEnd_DATE,
          b.OrderCancel_DATE,
          b.FreqOrderArrears_CODE,
          b.FreqOrderArrears_AMNT,
          b.OrderArrearsTotal_AMNT,
          b.ArrearsAfdcFrom_DATE,
          b.ArrearsAfdcThru_DATE,
          b.ArrearsAfdc_AMNT,
          b.ArrearsNonAfdcFrom_DATE,
          b.ArrearsNonAfdcThru_DATE,
          b.ArrearsNonAfdc_AMNT,
          b.FosterCareFrom_DATE,
          b.FosterCareThru_DATE,
          b.FosterCare_AMNT,
          b.MedicalFrom_DATE,
          b.MedicalThru_DATE,
          b.Medical_AMNT,
          b.MedicalOrdered_INDC,
          b.TribunalCaseNo_TEXT,
          b.OfLastPayment_DATE,
          b.ControllingOrderFlag_CODE,
          b.NewOrderFlag_INDC,
          b.File_ID
     FROM CTHB_Y1 a,
          EOBLK_Y1 b,
          CSPR_Y1 c
    WHERE c.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                  WHEN ''
                                   THEN '0'
                                  ELSE a.Message_ID
                                 END) AS NUMERIC)
      AND a.Message_ID = b.TransHeader_IDNO
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSENET COLLECTION BLOCK - ALL VALIDATED RECORDS';
   SET @Ls_Sqldata_TEXT = '';

   INSERT CCLB_Y1
          (TransHeader_IDNO,
           IVDOutOfStateFips_CODE,
           Transaction_DATE,
           BlockSeq_NUMB,
           Collection_DATE,
           Posting_DATE,
           Payment_AMNT,
           PaymentSource_CODE,
           PaymentMethod_CODE,
           Rdfi_ID,
           RdfiAcctNo_TEXT)
   SELECT DISTINCT
          a.TransHeader_IDNO,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          a.Transaction_DATE,
          b.BlockSeq_NUMB,
          b.Collection_DATE,
          b.Posting_DATE,
          b.Payment_AMNT,
          b.PaymentSource_CODE,
          b.PaymentMethod_CODE,
          b.Rdfi_ID,
          b.RdfiAcctNo_TEXT
     FROM CTHB_Y1 a,
          ECBLK_Y1 b,
          CSPR_Y1 c
    WHERE c.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                  WHEN ''
                                   THEN '0'
                                  ELSE a.Message_ID
                                 END) AS NUMERIC)
      AND a.Message_ID = b.TransHeader_IDNO
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'INSERT INTO CSENET INFORMATION BLOCK - ALL VALIDATED RECORDS';
   SET @Ls_Sqldata_TEXT = '';

   INSERT CFOB_Y1
          (TransHeader_IDNO,
           IVDOutOfStateFips_CODE,
           Transaction_DATE,
           StatusChange_CODE,
           CaseNew_ID,
           InfoLine1_TEXT,
           InfoLine2_TEXT,
           InfoLine3_TEXT,
           InfoLine4_TEXT,
           InfoLine5_TEXT)
   SELECT DISTINCT
          a.TransHeader_IDNO,
          RIGHT(REPLICATE('0', 2) + LTRIM(RTRIM(a.IVDOutOfStateFips_CODE)), 2) AS IVDOutOfStateFips_CODE,
          a.Transaction_DATE,
          b.StatusChange_CODE,
          b.CaseNew_ID,
          ISNULL(b.InfoLine1_TEXT, @Lc_Space_TEXT) AS InfoLine1_TEXT,
          ISNULL(b.InfoLine2_TEXT, @Lc_Space_TEXT) AS InfoLine2_TEXT,
          ISNULL(b.InfoLine3_TEXT, @Lc_Space_TEXT) AS InfoLine3_TEXT,
          ISNULL(b.InfoLine4_TEXT, @Lc_Space_TEXT) AS InfoLine4_TEXT,
          ISNULL(b.InfoLine5_TEXT, @Lc_Space_TEXT) AS InfoLine5_TEXT
     FROM CTHB_Y1 a,
          EIBLK_Y1 b,
          CSPR_Y1 c
    WHERE c.Request_IDNO = CAST((CASE LTRIM(a.Message_ID)
                                  WHEN ''
                                   THEN '0'
                                  ELSE a.Message_ID
                                 END) AS NUMERIC)
      AND a.Message_ID = b.TransHeader_IDNO
      AND c.StatusRequest_CODE = @Ac_Status_CODE
      AND c.EndValidity_DATE = @Ld_High_DATE;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'Header_CUR') IN (0, 1)
    BEGIN
     CLOSE Header_CUR;

     DEALLOCATE Header_CUR;
    END;

   IF CURSOR_STATUS('LOCAL', 'CnVal_CUR') IN (0, 1)
    BEGIN
     CLOSE CnVal_CUR;

     DEALLOCATE CnVal_CUR;
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

   SET @As_DescriptionError_TEXT = @As_DescriptionError_TEXT;
  END CATCH;
 END;


GO
