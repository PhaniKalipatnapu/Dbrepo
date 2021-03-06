/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APEH]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_INSERT_APEH
Programmer Name		 : IMP Team
Description			 : The procedure inserts application employment history data into the application employment history table. 
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
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APEH]
 @An_Application_IDNO         NUMERIC(15),
 @An_MemberMci_IDNO           NUMERIC(10),
 @An_OthpEmpl_IDNO            NUMERIC(9),
 @Ac_FreqIncome_CODE          CHAR(1),
 @Ac_TypeIncome_CODE          CHAR(2),
 @An_IncomeGross_AMNT         NUMERIC(11, 2),
 @Ad_BeginEmployment_DATE     DATE,
 @Ad_EndEmployment_DATE       DATE,
 @Ac_ContactWork_INDC         CHAR(1),
 @Ad_BeginValidity_DATE       DATE,
 @Ad_EndValidity_DATE         DATE,
 @Ad_Update_DTTM              DATE,
 @Ac_WorkerUpdate_ID          CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_TypeOccupation_CODE      CHAR(3),
 @Ad_EmployerAddressAsOf_DATE DATE,
 @Ac_MemberAddress_CODE       CHAR(1),
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusFailed_CODE	  CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE	  CHAR(1) = 'S',
           @Ls_Procedure_NAME		  VARCHAR(60) = 'SP_PROCESS_INSERT_APEH';
  DECLARE  @Ln_Zero_NUMB              NUMERIC(1) = 0,
           @Ln_Error_NUMB             NUMERIC(11),
           @Ln_ErrorLine_NUMB         NUMERIC(11),
           @Li_RowCount_QNTY          SMALLINT = 0,
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

   INSERT INTO APEH_Y1
               (Application_IDNO,
                MemberMci_IDNO,
                OthpEmpl_IDNO,
                FreqIncome_CODE,
                TypeIncome_CODE,
                IncomeGross_AMNT,
                BeginEmployment_DATE,
                EndEmployment_DATE,
                ContactWork_INDC,
                BeginValidity_DATE,
                EndValidity_DATE,
                Update_DTTM,
                WorkerUpdate_ID,
                TransactionEventSeq_NUMB,
                TypeOccupation_CODE,
                EmployerAddressAsOf_DATE,
                MemberAddress_CODE)
        VALUES ( @An_Application_IDNO, -- Application_IDNO
                 @An_MemberMci_IDNO, -- MemberMci_IDNO
                 @An_OthpEmpl_IDNO, -- OthpEmpl_IDNO
                 ISNULL(@Ac_FreqIncome_CODE, @Lc_Space_TEXT), --FreqIncome_CODE
                 ISNULL(@Ac_TypeIncome_CODE, @Lc_Space_TEXT), -- TypeIncome_CODE
                 @An_IncomeGross_AMNT, -- IncomeGross_AMNT
                 @Ad_BeginEmployment_DATE, --BeginEmployment_DATE
                 @Ad_EndEmployment_DATE, -- EndEmployment_DATE
                 ISNULL(@Ac_ContactWork_INDC, @Lc_Space_TEXT), -- ContactWork_INDC
                 @Ad_BeginValidity_DATE, -- BeginValidity_DATE
                 @Ad_EndValidity_DATE, -- EndValidity_DATE
                 @Ad_Update_DTTM, -- Update_DTTM
                 ISNULL(@Ac_WorkerUpdate_ID, @Lc_Space_TEXT), -- WorkerUpdate_ID
                 @An_TransactionEventSeq_NUMB, -- TransactionEventSeq_NUMB
                 ISNULL(@Ac_TypeOccupation_CODE, @Lc_Space_TEXT), --TypeOccupation_CODE
                 @Ad_EmployerAddressAsOf_DATE, -- EmployerAddressAsOf_DATE
                 ISNULL(@Ac_MemberAddress_CODE, @Lc_Space_TEXT)); -- MemberAddress_CODE

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'APEH_Y1 INSERT FAILED';

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
