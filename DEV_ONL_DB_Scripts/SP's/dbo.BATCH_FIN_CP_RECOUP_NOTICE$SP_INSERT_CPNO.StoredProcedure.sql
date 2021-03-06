/****** Object:  StoredProcedure [dbo].[BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*-------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO
 Programmer Name	: IMP Team
 Description		: The procedure is used to insert the CP recoupments in CPNO_Y1 table
 Frequency			: 
 Developed On		: 4/11/2011
 Called By			: BATCH_FIN_CP_RECOUP_NOTICE$SP_PROCESS_GENERATE_CP_RECOUP_NOTICE
 Called On			:
 -------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No			: 1.0
-------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO]
 @Ac_CheckRecipient_ID     CHAR(10),
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Notice_ID             CHAR(8),
 @Ad_AppSigned_DATE        DATE,
 @Ad_Run_DATE              DATE,
 @Ad_LastRun_DATE		   DATE,
 @Ac_CheckRecipient_CODE   CHAR(1),
 @An_NoticeSeq_NUMB        NUMERIC(1),
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_WaitForResponce_NUMB				NUMERIC(2) = 30,
          @Lc_Yes_INDC							CHAR(1) = 'Y',
          @Lc_No_INDC							CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE				CHAR(1) = 'S',
          @Lc_StatusFailed_CODE					CHAR(1) = 'F',
          @Lc_TypeCaseNonIvd_CODE				CHAR(1) = 'H',
          @Lc_RespondInitInternational_CODE		CHAR(1) = 'Y',
          @Lc_RespondInitState_CODE				CHAR(1) = 'R',
          @Lc_RespondingTribal_CODE				CHAR(1) = 'S',
		  @Lc_DisburseStatusVoidNoReissue_CODE  CHAR (2) = 'VN',
          @Lc_DisburseStatusVoidReissue_CODE    CHAR (2) = 'VR',
          @Lc_DisburseStatusStopNoReissue_CODE  CHAR (2) = 'SN',
          @Lc_DisburseStatusStopReissue_CODE    CHAR (2) = 'SR',
		  @Lc_DisburseStatusRejectedEft_CODE    CHAR(2) = 'RE',
          @Lc_SecondOverPaymentNotice_IDNO		CHAR(6) = 'FIN-37',
          @Lc_FinalOverPaymentNotice_IDNO		CHAR(6) = 'FIN-38',
          @Lc_Err0001_TEXT						CHAR(25) = 'INSERT NOT SUCCESSFUL',
          @Lc_Err0002_TEXT						CHAR(25) = 'UPDATE NOT SUCCESSFUL',
          @Ls_Sql_TEXT							VARCHAR(100) = ' ',
          @Ls_Procedure_NAME					VARCHAR(100) = 'BATCH_FIN_CP_RECOUP_NOTICE$SP_INSERT_CPNO',
          @Ls_Sqldata_TEXT						VARCHAR(1000) = ' ',
          @Ld_Low_DATE							DATE = '01/01/0001',
          @Ld_High_DATE							DATE = '12/31/9999',
          @Ld_AppSigned_DATE					DATE = '01/01/2003';
  DECLARE @Ln_ErrorLine_NUMB					NUMERIC(11),
          @Ln_Error_NUMB						NUMERIC(11),
          @Ln_RowCount_QNTY						NUMERIC(11),
          @Ln_Transaction_AMNT					NUMERIC(11),
          @Ls_ErrorMessage_TEXT					VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'INSERT_CPNO - 1 ';
   SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ', Notice_ID = ' + ISNULL (@Ac_Notice_ID, '') + ', Yes_INDC = ' + @Lc_Yes_INDC + ', No_INDC = ' + @Lc_No_INDC + ', AppSigned_DATE = ' + CAST(@Ad_AppSigned_DATE AS VARCHAR) + ', AppSigned_DATE = ' + CAST(@Ld_AppSigned_DATE AS VARCHAR) + ', High_DATE= ' + CAST(@Ld_High_DATE AS VARCHAR) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', NoticeSeq_NUMB = ' + CAST(@An_NoticeSeq_NUMB AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@An_EventGlobalSeq_NUMB AS VARCHAR) + ', Low_DATE = ' + CAST(@Ld_Low_DATE AS VARCHAR);

   INSERT CPNO_Y1
          (CheckRecipient_ID,
           CheckRecipient_CODE,
           Case_IDNO,
           Batch_DATE,
           SourceBatch_CODE,
           Batch_NUMB,
           SeqReceipt_NUMB,
           Notice_ID,
           Notice_DATE,
           NoticeSeq_NUMB,
           Transaction_AMNT,
           CasePrior20030101_INDC,
           EventGlobalSeq_NUMB,
           StatusUpdate_DATE,
           EventGlobalUpdateSeq_NUMB,
           ReasonOverpay_CODE,
           Disburse_DATE)
   SELECT a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
          a.Case_IDNO,
          a.Batch_DATE,
          a.SourceBatch_CODE,
          a.Batch_NUMB,
          a.SeqReceipt_NUMB,
          @Ac_Notice_ID AS Notice_ID,
          @Ad_Run_DATE AS Notice_DATE,
          @An_NoticeSeq_NUMB AS NoticeSeq_NUMB,
          SUM (l.Disburse_AMNT) AS Transaction_AMNT,
          CASE
           WHEN @Ad_AppSigned_DATE < @Ld_AppSigned_DATE
            THEN @Lc_Yes_INDC
           ELSE @Lc_No_INDC
          END AS CasePrior20030101_INDC,
          @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
          @Ld_High_DATE AS StatusUpdate_DATE,
          0 AS EventGlobalUpdateSeq_NUMB,
          a.Reason_CODE,
          l.Disburse_DATE
     FROM POFL_Y1 a,
          DSBL_Y1 l
		
    WHERE l.Batch_DATE = a.Batch_DATE
      AND l.Batch_NUMB = a.Batch_NUMB
      AND l.SourceBatch_CODE = a.SourceBatch_CODE
      AND l.SeqReceipt_NUMB = a.SeqReceipt_NUMB
      AND l.Case_IDNO = a.Case_IDNO
	  -- BUG 13723 Fix - FIN-36,FIN-37,FIN-38 notices should exclude check status 'VR', 'VN','SR','SN', 'RE' -- Start --
	  ANd Exists(
	  SELECT 1 from DSBH_Y1 h
	  WHERE
	   l.CheckRecipient_ID=h.CheckRecipient_ID
	  AND l.CheckRecipient_CODE=h.CheckRecipient_CODE
	  ANd l.Disburse_DATE=h.Disburse_DATE
	  AND l.DisburseSeq_NUMB=h.DisburseSeq_NUMB
	  AND h.EndValidity_DATE=@Ld_High_DATE
	  AND h.StatusCheck_CODE NOT IN(
	  @Lc_DisburseStatusVoidNoReissue_CODE,
	  @Lc_DisburseStatusVoidReissue_CODE,  
	  @Lc_DisburseStatusStopNoReissue_CODE,
	  @Lc_DisburseStatusStopReissue_CODE,  
	  @Lc_DisburseStatusRejectedEft_CODE)    
	  )
	  -- BUG 13723 Fix - FIN-36,FIN-37,FIN-38 notices should exclude check status 'VR', 'VN','SR','SN', 'RE' -- End --
	  AND a.Case_IDNO = @An_Case_IDNO
      AND a.CheckRecipient_ID = @Ac_CheckRecipient_ID
      AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
      AND NOT EXISTS(SELECT 1
                       FROM CPNO_Y1 e
                      WHERE a.Case_IDNO = e.Case_IDNO
                        AND a.CheckRecipient_CODE = e.CheckRecipient_CODE
                        AND a.CheckRecipient_ID = e.CheckRecipient_ID
                        AND e.Batch_DATE = a.Batch_DATE
                        AND e.SourceBatch_CODE = a.SourceBatch_CODE
                        AND e. Batch_NUMB = a.Batch_NUMB
                        AND e. SeqReceipt_NUMB = a.SeqReceipt_NUMB)
       --BUG 13621 : The fin 36 is not generating when recoupment set up on Responding cases or Non IV-D cases.
       AND NOT EXISTS  ( SELECT 1
						 FROM CASE_Y1 C
						 WHERE C.Case_IDNO=a.Case_IDNO
						 AND( c.TypeCase_CODE  =@Lc_TypeCaseNonIvd_CODE
						   OR c.RespondInit_CODE IN(@Lc_RespondInitInternational_CODE,@Lc_RespondInitState_CODE,@Lc_RespondingTribal_CODE))
						 AND a.Transaction_DATE<= @Ad_LastRun_DATE
						 
						 )
      AND a.PendOffset_AMNT > 0
      AND a.Batch_DATE <> @Ld_Low_DATE
    GROUP BY a.CheckRecipient_ID,
             a.CheckRecipient_CODE,
             a.Case_IDNO,
             a.Batch_DATE,
             a.SourceBatch_CODE,
             a.Batch_NUMB,
             a.SeqReceipt_NUMB,
             a.Reason_CODE,
             l.Disburse_DATE;

   IF @Ac_Notice_ID IN (@Lc_SecondOverPaymentNotice_IDNO, @Lc_FinalOverPaymentNotice_IDNO)
    BEGIN
     IF EXISTS(SELECT 1
                 FROM CPNO_Y1 a
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.CheckRecipient_ID = @Ac_CheckRecipient_ID
                  AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
                  AND a.NoticeSeq_NUMB = @An_NoticeSeq_NUMB - 1
                  AND DATEDIFF(DAY, a.Notice_DATE, @Ad_Run_DATE) > @Ln_WaitForResponce_NUMB
                  AND a.StatusUpdate_DATE = @Ld_High_DATE)
      BEGIN
       /*
       The second notice (FIN-37 Second Notice of Overpayment of Support) is accumulative and will list the reversed receipts that were listed on the first notice, and any additional reversed receipts that have been reversed since the generation of the first notice up to and including
       the date of the generation of the second notice.
       
       The third notice FIN-38 Final Notice of Overpayment of Support is also accumulative and will list the reversed receipts that were listed on the first notice, the additional reversed receipts listed on the second notice and any additional reversed receipts that have been reversed since the 
       generation of the second notice up to and including the date of the generation of the third notice.
       */
       SET @Ls_Sql_TEXT = 'UPDATE_CPNO - 2 ';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ', NoticeSeq_NUMB = ' + CAST(@An_NoticeSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@An_EventGlobalSeq_NUMB AS VARCHAR) + ', WaitForResponce_NUMB = ' + CAST(@Ln_WaitForResponce_NUMB AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR);

       UPDATE CPNO_Y1
          SET StatusUpdate_DATE = @Ad_Run_DATE,
              EventGlobalUpdateSeq_NUMB = @An_EventGlobalSeq_NUMB
        WHERE Case_IDNO = @An_Case_IDNO
          AND CheckRecipient_ID = @Ac_CheckRecipient_ID
          AND CheckRecipient_CODE = @Ac_CheckRecipient_CODE
          AND NoticeSeq_NUMB = @An_NoticeSeq_NUMB - 1
          AND DATEDIFF(DAY, Notice_DATE, @Ad_Run_DATE) >= @Ln_WaitForResponce_NUMB
          AND StatusUpdate_DATE = @Ld_High_DATE;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         -- 'Update not successful'
         SET @Ls_ErrorMessage_TEXT = @Lc_Err0002_TEXT;

         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'INSERT_CPNO - 3';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL (CAST(@An_Case_IDNO AS VARCHAR), '') + ', Notice_ID = ' + ISNULL (@Ac_Notice_ID, '') + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', NoticeSeq_NUMB = ' + CAST(@An_NoticeSeq_NUMB AS VARCHAR) + ', Transaction_AMNT = ' + CAST(@Ln_Transaction_AMNT AS VARCHAR) + ', EventGlobalSeq_NUMB = ' + CAST(@An_EventGlobalSeq_NUMB AS VARCHAR) + ', High_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR) + ', WaitForResponce_NUMB = ' + CAST(@Ln_WaitForResponce_NUMB AS VARCHAR);

       INSERT CPNO_Y1
              (CheckRecipient_ID,
               CheckRecipient_CODE,
               Case_IDNO,
               Batch_DATE,
               SourceBatch_CODE,
               Batch_NUMB,
               SeqReceipt_NUMB,
               Notice_ID,
               Notice_DATE,
               NoticeSeq_NUMB,
               Transaction_AMNT,
               CasePrior20030101_INDC,
               EventGlobalSeq_NUMB,
               StatusUpdate_DATE,
               EventGlobalUpdateSeq_NUMB,
               ReasonOverpay_CODE,
               Disburse_DATE)
       SELECT a.CheckRecipient_ID,
              a.CheckRecipient_CODE,
              a.Case_IDNO,
              a.Batch_DATE,
              a.SourceBatch_CODE,
              a.Batch_NUMB,
              a.SeqReceipt_NUMB,
              @Ac_Notice_ID AS Notice_ID,
              @Ad_Run_DATE AS Notice_DATE,
              @An_NoticeSeq_NUMB NoticeSeq_NUMB,
              a.Transaction_AMNT,
              a.CasePrior20030101_INDC,
              @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
              @Ld_High_DATE AS StatusUpdate_DATE,
              0 AS EventGlobalUpdateSeq_NUMB,
              ReasonOverpay_CODE,
              Disburse_DATE
         FROM CPNO_Y1 a
        WHERE a.Case_IDNO = @An_Case_IDNO
          AND a.CheckRecipient_ID = @Ac_CheckRecipient_ID
          AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
          AND a.NoticeSeq_NUMB = @An_NoticeSeq_NUMB - 1
          AND DATEDIFF(DAY, Notice_DATE, @Ad_Run_DATE) > @Ln_WaitForResponce_NUMB
          AND a.StatusUpdate_DATE = @Ad_Run_DATE
          AND a.EventGlobalUpdateSeq_NUMB = @An_EventGlobalSeq_NUMB;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         -- 'Update not successful'
         SET @Ls_ErrorMessage_TEXT = @Lc_Err0001_TEXT;

         RAISERROR (50001,16,1);
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   --Check for Exception information to log the description text based on the error
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
