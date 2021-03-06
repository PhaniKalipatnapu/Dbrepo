/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_REINSTATED_LICENSE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Program Name	:	BATCH_ENF_EMON$SP_REINSTATED_License

Programmer Name :	Protech Solutions, Inc.

Description		:	To insert PLIC_Y1.

Frequency		: 

Developed On	:

Called By		:	None

Called Procedures : 

Modified By		:

Modified On		:

Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_REINSTATED_LICENSE]
 @An_OthpSource_IDNO       NUMERIC(9),
 @Ac_TypeLicense_CODE      CHAR(4),
 @Ac_WorkerSignedOn_ID     CHAR(30),
 @An_TransactionEvent_Lock NUMERIC(9),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR OUTPUT
AS
 DECLARE @Ls_Routine                     VARCHAR(75) = 'BATCH_ENF_EMON$SP_REINSTATED_License',
         @Lc_Success_CODE                CHAR(1) = 'S',
         @Lc_Space_TEXT                  CHAR(1) = ' ',
         @Lc_StatusFailed_CODE           CHAR(1) = 'F',
         @Ld_HighDate_DATE               DATETIME2 (0) = '12/31/9999',
         @Ld_LowDate_DATE                DATETIME2 = '01/01/0001',
         @Lc_LicenseStatusActive_CODE    CHAR(1) = 'A',
         @Lc_LicenseStatusReinstate_CODE CHAR(1) = 'R',
         @Lc_LicenseStatusSuspend_CODE   CHAR(1) = 'S',
         @Ls_Sql_TEXT                    VARCHAR(50),
         @Ls_SqlData_TEXT                VARCHAR(400);

 BEGIN
  BEGIN TRY
   SET @Ls_Sql_TEXT = 'EMON166 : INSERT  PLIC_Y1';
   SET @Ls_SqlData_TEXT = 'MemberMci_IDNO' + ISNULL (CAST (@An_OthpSource_IDNO AS VARCHAR (10)), '') + 'TypeLicense_CODE :' + @Ac_TypeLicense_CODE + 'LicenseStatus_CODE :' + @Lc_LicenseStatusSuspend_CODE;

   INSERT INTO PLIC_Y1
               (MemberMci_IDNO,
                TypeLicense_CODE,
                LicenseNo_TEXT,
                IssuingState_CODE,
                LicenseStatus_CODE,
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
                TransactionEventSeq_NUMB)
   SELECT @An_OthpSource_IDNO MemberMci_IDNO,
          TypeLicense_CODE,
          LicenseNo_TEXT,
          IssuingState_CODE,
          @Lc_LicenseStatusReinstate_CODE LicenseStatus_CODE,
          IssueLicense_DATE,
          ExpireLicense_DATE,
          @Ld_LowDate_DATE SuspLicense_DATE,
          Status_CODE,
          Status_DATE,
          SourceVerified_CODE,
          @Ad_Run_DATE BeginValidity_DATE,
          @Ld_HighDate_DATE EndValidity_DATE,
          @Ac_WorkerSignedOn_ID WorkerUpdate_ID,
          GETDATE() Update_DTTM,
          @An_TransactionEvent_Lock TransactionEventSeq_NUMB
     FROM PLIC_Y1
    WHERE MemberMci_IDNO = @An_OthpSource_IDNO
      AND TypeLicense_CODE = @Ac_TypeLicense_CODE
      AND EndValidity_DATE = @Ld_HighDate_DATE
      AND LicenseStatus_CODE = @Lc_LicenseStatusSuspend_CODE;

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = @Ls_Routine + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'PLIC_Y1 INSERT FAILED' + @Lc_Space_TEXT + @Ls_SqlData_TEXT;

     RETURN;
    END

   SET @Ls_Sql_TEXT = 'EMON169 : UPDATE PLIC_Y1';
   SET @Ls_SqlData_TEXT = 'MemberMci_IDNO' + ISNULL (CAST (@An_OthpSource_IDNO AS VARCHAR (10)), '') + 'TypeLicense_CODE :' + @Ac_TypeLicense_CODE + 'LicenseStatus_CODE :' + @Lc_LicenseStatusSuspend_CODE;

   UPDATE PLIC_Y1
      SET EndValidity_DATE = @Ad_Run_DATE
    WHERE MemberMci_IDNO = @An_OthpSource_IDNO
      AND TypeLicense_CODE = @Ac_TypeLicense_CODE
      AND EndValidity_DATE = @Ld_HighDate_DATE
      AND LicenseStatus_CODE = @Lc_LicenseStatusSuspend_CODE;

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
     SET @As_DescriptionError_TEXT = @Ls_Routine + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'PLIC_Y1 UPDATE FAILED' + @Lc_Space_TEXT + @Ls_SqlData_TEXT;

     RETURN;
    END

   SET @Ac_Msg_CODE = @Lc_Success_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @As_DescriptionError_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_SqlData_TEXT;
    END
   ELSE
    BEGIN
     SET @As_DescriptionError_TEXT = 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END
  END CATCH;
 END


GO
