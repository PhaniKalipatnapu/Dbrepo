/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH
Programmer Name		 : IMP Team
Description			 : The procedure inserts application member history data into application member history table.
Frequency			 : Daily
Developed On		 : 11/02/2011
Called By			 :
Called On			 : 
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APMH]
 @An_Application_IDNO         NUMERIC(15),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_TypeWelfare_CODE         CHAR(1),
 @Ad_Begin_DATE               DATE,
 @Ad_End_DATE                 DATE,
 @An_CaseWelfare_IDNO         NUMERIC(10),
 @Ad_BeginValidity_DATE       DATE,
 @Ad_EndValidity_DATE         DATE,
 @Ad_Update_DTTM              DATETIME2,
 @Ac_WorkerUpdate_ID          CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @An_WelfareMemberMci_IDNO    NUMERIC(10),
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusFailed_CODE	  CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE	  CHAR(1) = 'S',
           @Ls_Procedure_NAME		  VARCHAR(60) = 'SP_PROCESS_INSERT_APMH';
  DECLARE  @Ln_Zero_NUMB              NUMERIC(1) = 0,
           @Ln_Error_NUMB             NUMERIC(11),
           @Ln_ErrorLine_NUMB         NUMERIC(11),
           @Li_RowCount_QNTY          SMALLINT,
           @Lc_Space_TEXT			  CHAR(1) = ' ',
           @Lc_Exception_CODE         CHAR(1) = '',
           @Ls_Sql_TEXT               VARCHAR(100),
           @Ls_Sqldata_TEXT           VARCHAR(1000),
           @Ls_DescriptionError_TEXT  VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT      VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = ' ';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_Exception_CODE = '';
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'SELECT FROM FSRT_Y1 TABLE ';
   SET @Ls_Sqldata_TEXT = 'APPLICATION IDNO = ' + CAST(@An_Application_IDNO AS VARCHAR(15)) + ', MEMBERMCI IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10));

   INSERT INTO APMH_Y1
               (Application_IDNO,
                MemberMci_IDNO,
                TypeWelfare_CODE,
                Begin_DATE,
                End_DATE,
                CaseWelfare_IDNO,
                BeginValidity_DATE,
                EndValidity_DATE,
                Update_DTTM,
                WorkerUpdate_ID,
                TransactionEventSeq_NUMB,
                WelfareMemberMci_IDNO)
        VALUES ( @An_Application_IDNO, --Application_IDNO
                 @An_MemberMci_IDNO, --MemberMci_IDNO
                 ISNULL(@Ac_TypeWelfare_CODE, @Lc_Space_TEXT), -- TypeWelfare_CODE
                 @Ad_Begin_DATE, -- Begin_DATE
                 @Ad_End_DATE, -- End_DATE
                 @An_CaseWelfare_IDNO, --CaseWelfare_IDNO
                 @Ad_BeginValidity_DATE, -- BeginValidity_DATE
                 @Ad_EndValidity_DATE, -- EndValidity_DATE
                 @Ad_Update_DTTM, -- Update_DTTM
                 ISNULL(@Ac_WorkerUpdate_ID, @Lc_Space_TEXT), -- WorkerUpdate_ID
                 @An_TransactionEventSeq_NUMB, -- TransactionEventSeq_NUMB
                 @An_WelfareMemberMci_IDNO); -- WelfareMemberMci_IDNO

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'APMH_Y1 INSERT FAILED';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   --Set Error Description
   SET @Ls_ErrorMessage_TEXT = @As_DescriptionError_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
