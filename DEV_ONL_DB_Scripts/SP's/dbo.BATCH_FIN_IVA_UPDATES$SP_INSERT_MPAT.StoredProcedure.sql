/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_MPAT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_INSERT_MPAT
Programmer Name	:	IMP Team.
Description		:	This process creates new case.
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS
Called On		:	NONE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_INSERT_MPAT]
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ad_Run_DATE                 DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  --SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  DECLARE @Ln_Zero_NUMB             SMALLINT = 0,
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_BatchRunUser_TEXT     CHAR(5) = 'BATCH',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_INSERT_MPAT',
          @Ls_Sql_TEXT              VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT          VARCHAR(5000) = ' ',
          @Ld_Low_DATE              DATE = '01/01/0001',
          @Ld_Start_DATE            DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ln_Rowcount_QNTY  NUMERIC,
          @Ln_Error_NUMB     NUMERIC(11) = 0,
          @Ln_ErrorLine_NUMB NUMERIC(11) = 0;

  BEGIN TRY
   --Selecting the Batch Start Time
   SET @Ls_Sql_TEXT = 'INSERT MPAT_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', BirthCertificate_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', Conception_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', ConceptionCity_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', ConceptionCounty_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', ConceptionState_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', ConceptionCountry_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedMother_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedMotherMci_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', EstablishedMotherLast_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedMotherFirst_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedMotherMiddle_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedMotherSuffix_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedFather_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', EstablishedFatherLast_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedFatherFirst_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', EstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', DisEstablishedFather_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', DisEstablishedFatherMci_IDNO = ' + ISNULL(CAST(@Ln_Zero_NUMB AS VARCHAR), '') + ', DisEstablishedFatherLast_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', DisEstablishedFatherFirst_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', DisEstablishedFatherMiddle_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', DisEstablishedFatherSuffix_NAME = ' + ISNULL(@Lc_Space_TEXT, '') + ', StateEstablish_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FileEstablish_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', PaternityEst_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', PaternityEst_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', StateDisestablish_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', FileDisestablish_ID = ' + ISNULL(@Lc_Space_TEXT, '') + ', MethodDisestablish_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', Disestablish_DATE = ' + ISNULL(CAST(@Ld_Low_DATE AS VARCHAR), '') + ', DescriptionProfile_TEXT = ' + ISNULL(@Lc_Space_TEXT, '') + ', VapImage_CODE = ' + ISNULL(@Lc_Space_TEXT, '') + ', WorkerUpdate_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Update_DTTM = ' + ISNULL(CAST(@Ld_Start_DATE AS VARCHAR), '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '');

   INSERT MPAT_Y1
          (MemberMci_IDNO,
           BirthCertificate_ID,
           BornOfMarriage_CODE,
           Conception_DATE,
           ConceptionCity_NAME,
           ConceptionCounty_IDNO,
           ConceptionState_CODE,
           ConceptionCountry_CODE,
           EstablishedMother_CODE,
           EstablishedMotherMci_IDNO,
           EstablishedMotherLast_NAME,
           EstablishedMotherFirst_NAME,
           EstablishedMotherMiddle_NAME,
           EstablishedMotherSuffix_NAME,
           EstablishedFather_CODE,
           EstablishedFatherMci_IDNO,
           EstablishedFatherLast_NAME,
           EstablishedFatherFirst_NAME,
           EstablishedFatherMiddle_NAME,
           EstablishedFatherSuffix_NAME,
           DisEstablishedFather_CODE,
           DisEstablishedFatherMci_IDNO,
           DisEstablishedFatherLast_NAME,
           DisEstablishedFatherFirst_NAME,
           DisEstablishedFatherMiddle_NAME,
           DisEstablishedFatherSuffix_NAME,
           PaternityEst_INDC,
           StatusEstablish_CODE,
           StateEstablish_CODE,
           FileEstablish_ID,
           PaternityEst_CODE,
           PaternityEst_DATE,
           StateDisestablish_CODE,
           FileDisestablish_ID,
           MethodDisestablish_CODE,
           Disestablish_DATE,
           DescriptionProfile_TEXT,
           QiStatus_CODE,
           VapImage_CODE,
           WorkerUpdate_ID,
           BeginValidity_DATE,
           Update_DTTM,
           TransactionEventSeq_NUMB)
   VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
            @Lc_Space_TEXT,--BirthCertificate_ID
            'U',--BornOfMarriage_CODE
            @Ld_Low_DATE,--Conception_DATE
            @Lc_Space_TEXT,--ConceptionCity_NAME
            @Ln_Zero_NUMB,--ConceptionCounty_IDNO
            @Lc_Space_TEXT,--ConceptionState_CODE
            @Lc_Space_TEXT,--ConceptionCountry_CODE
            @Lc_Space_TEXT,--EstablishedMother_CODE
            @Ln_Zero_NUMB,--EstablishedMotherMci_IDNO
            @Lc_Space_TEXT,--EstablishedMotherLast_NAME
            @Lc_Space_TEXT,--EstablishedMotherFirst_NAME
            @Lc_Space_TEXT,--EstablishedMotherMiddle_NAME
            @Lc_Space_TEXT,--EstablishedMotherSuffix_NAME
            @Lc_Space_TEXT,--EstablishedFather_CODE
            @Ln_Zero_NUMB,--EstablishedFatherMci_IDNO
            @Lc_Space_TEXT,--EstablishedFatherLast_NAME
            @Lc_Space_TEXT,--EstablishedFatherFirst_NAME
            @Lc_Space_TEXT,--EstablishedFatherMiddle_NAME
            @Lc_Space_TEXT,--EstablishedFatherSuffix_NAME
            @Lc_Space_TEXT,--DisEstablishedFather_CODE
            @Ln_Zero_NUMB,--DisEstablishedFatherMci_IDNO
            @Lc_Space_TEXT,--DisEstablishedFatherLast_NAME
            @Lc_Space_TEXT,--DisEstablishedFatherFirst_NAME
            @Lc_Space_TEXT,--DisEstablishedFatherMiddle_NAME
            @Lc_Space_TEXT,--DisEstablishedFatherSuffix_NAME
            'N',--PaternityEst_INDC
            'T',--StatusEstablish_CODE
            @Lc_Space_TEXT,--StateEstablish_CODE
            @Lc_Space_TEXT,--FileEstablish_ID
            @Lc_Space_TEXT,--PaternityEst_CODE
            @Ld_Low_DATE,--PaternityEst_DATE
            @Lc_Space_TEXT,--StateDisestablish_CODE
            @Lc_Space_TEXT,--FileDisestablish_ID
            @Lc_Space_TEXT,--MethodDisestablish_CODE
            @Ld_Low_DATE,--Disestablish_DATE
            @Lc_Space_TEXT,--DescriptionProfile_TEXT
            'N',--QiStatus_CODE
            @Lc_Space_TEXT,--VapImage_CODE
            @Lc_BatchRunUser_TEXT,--WorkerUpdate_ID
            @Ad_Run_DATE,--BeginValidity_DATE
            @Ld_Start_DATE,--Update_DTTM
            @An_TransactionEventSeq_NUMB --TransactionEventSeq_NUMB
   );

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT MPAT FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
