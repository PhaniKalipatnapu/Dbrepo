/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_TERMINATE_INCOME_WITHHOLDING]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* --------------------------------------------------------------------------------------------------- 
Procedure Name    : BATCH_ENF_EMON$SP_TERMINATE_INCOME_WITHHOLDING
Programmer Name   : IMP Team 
Description       : This procedure is used to terminate income withholding
Frequency         : 
Developed On      : 01/05/2012
Called By         : BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On         : BATCH_ENF_EMON$SP_INSERT_IWEM
--------------------------------------------------------------------------------------------------- 
Modified By       : 
Modified On       : 
Version No        :  1.0
-------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_TERMINATE_INCOME_WITHHOLDING] (
 @An_Case_IDNO                NUMERIC(6),
 @An_MemberMci_IDNO           NUMERIC (10),
 @An_OthpSource_IDNO          NUMERIC(10) = NULL,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT				CHAR(1)			= ' ',
          @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
          @Lc_StatusFail_CODE			CHAR(1)			= 'F',
          @Lc_IwnStatusTerminated_CODE	CHAR(1)			= 'T',
          @Lc_IwnStatusActive_CODE		CHAR(1)			= 'A',
          @Lc_IwnStatusPending_CODE		CHAR(1)			= 'P',
          @Ls_Routine_TEXT				VARCHAR(75)		= 'BATCH_ENF_EMON$SP_TERMINATE_INCOME_WITHHOLDING',
          @Ld_High_DATE					DATE			= '12/31/9999';
          
  DECLARE @Ln_RowCount_QNTY				NUMERIC(5),
          @Ln_Error_NUMB				NUMERIC(11),
          @Ln_ErrorLine_NUMB			NUMERIC(11),
          @Ls_Sql_TEXT					VARCHAR(300),
          @Ls_SqlData_TEXT				VARCHAR(3000),
          @Ls_DescriptionError_TEXT		VARCHAR(4000),
          @Ld_System_DTTM				DATETIME2		= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  BEGIN TRY
  
   SET @An_OthpSource_IDNO = CASE WHEN @An_OthpSource_IDNO = 0
								  THEN NULL
								  ELSE @An_OthpSource_IDNO
							 END;
   SET @Ls_Sql_TEXT = ' BATCH_ENF_EMON$SP_TERMINATE_INCOME_WITHHOLDING INSERT IWEM_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', OthpSource_IDNO = ' + CAST(ISNULL(@An_OthpSource_IDNO,0) AS VARCHAR);
   SELECT @Ln_RowCount_QNTY = COUNT(1)
    FROM IWEM_Y1 A
    WHERE A.Case_IDNO = @An_Case_IDNO
      AND A.MemberMci_IDNO = @An_MemberMci_IDNO
      AND A.OthpEmployer_IDNO = ISNULL(@An_OthpSource_IDNO,A.OthpEmployer_IDNO)
      AND A.IwnStatus_CODE IN (@Lc_IwnStatusActive_CODE, @Lc_IwnStatusPending_CODE)
      AND A.End_DATE = @Ld_High_DATE
      AND A.EndValidity_DATE = @Ld_High_DATE;
      
   IF @Ln_RowCount_QNTY = 0
    BEGIN
	   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
	   SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;	
       RETURN;
    END;

   INSERT INTO IWEM_Y1
               (Case_IDNO,
                OrderSeq_NUMB,
                MemberMci_IDNO,
                Entered_DATE,
                End_DATE,
                OthpEmployer_IDNO,
                TypeSource_CODE,
                IwnPer_CODE,
                IwnStatus_CODE,
                CurCs_AMNT,
                CurMd_AMNT,
                CurSs_AMNT,
                CurOt_AMNT,
                Payback_AMNT,
                FreqCs_CODE,
                FreqMd_CODE,
                FreqSs_CODE,
                FreqOt_CODE,
                FreqPayback_CODE,
                ArrearAged_INDC,
                BeginValidity_DATE,
                EndValidity_DATE,
                WorkerUpdate_ID,
                Update_DTTM,
                TransactionEventSeq_NUMB)
   SELECT A.Case_IDNO,
          A.OrderSeq_NUMB,
          A.MemberMci_IDNO,
          A.Entered_DATE,
          @Ad_Run_DATE End_DATE,
          A.OthpEmployer_IDNO,
          A.TypeSource_CODE,
          A.IwnPer_CODE,          
          @Lc_IwnStatusTerminated_CODE IwnStatus_CODE,
          /* 13129 - EMON - CR0345 IWO Process Changes 20131226 - START */
          /* For termination show amount and frequency as blank in notice. */
          0 AS CurCs_AMNT,
          0 AS CurMd_AMNT,
          0 AS CurSs_AMNT,
          0 AS CurOt_AMNT,
          0 AS Payback_AMNT,
          @Lc_Space_TEXT AS FreqCs_CODE,
          @Lc_Space_TEXT AS FreqMd_CODE,
          @Lc_Space_TEXT AS FreqSs_CODE,
          @Lc_Space_TEXT AS FreqOt_CODE,
          @Lc_Space_TEXT AS FreqPayback_CODE,
          @Lc_Space_TEXT AS ArrearAged_INDC,
          /* 13129 - EMON - CR0345 IWO Process Changes 20131226 - END */
          @Ad_Run_DATE BeginValidity_DATE,
          @Ld_High_DATE EndValidity_DATE,
          @Ac_SignedOnWorker_ID WorkerUpdate_ID,
          @Ld_System_DTTM Update_DTTM,
          @An_TransactionEventSeq_NUMB TransactionEventSeq_NUMB
     FROM IWEM_Y1 A
    WHERE A.Case_IDNO = @An_Case_IDNO
      AND A.MemberMci_IDNO = @An_MemberMci_IDNO
      AND A.OthpEmployer_IDNO = ISNULL(@An_OthpSource_IDNO,A.OthpEmployer_IDNO)
      AND A.IwnStatus_CODE IN (@Lc_IwnStatusActive_CODE, @Lc_IwnStatusPending_CODE)
      AND A.End_DATE = @Ld_High_DATE
      AND A.EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ls_Sql_TEXT = ' BATCH_ENF_EMON$SP_TERMINATE_INCOME_WITHHOLDING INSERT IWEM_Y1';
   SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', OthpSource_IDNO = ' + CAST(ISNULL(@An_OthpSource_IDNO,0) AS VARCHAR);

   UPDATE IWEM_Y1
      SET End_DATE = @Ad_Run_DATE
    WHERE Case_IDNO = @An_Case_IDNO
      AND MemberMci_IDNO = @An_MemberMci_IDNO
      AND OthpEmployer_IDNO = ISNULL(@An_OthpSource_IDNO,OthpEmployer_IDNO)
      AND IwnStatus_CODE IN (@Lc_IwnStatusActive_CODE, @Lc_IwnStatusPending_CODE)
      AND End_DATE = @Ld_High_DATE
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFail_CODE;

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
