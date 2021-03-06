/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_SUPPRESS_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_SUPPRESS_NOTICE
Programmer Name		: IMP Team
Description			: This procedure is used suppress notice generation using input process id, notice id
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 0.1
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_SUPPRESS_NOTICE]
 @Ac_Notice_ID             CHAR(8),
 @Ac_Process_ID            CHAR(10),
 @Ac_StatusNotice_CODE     CHAR(1),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
BEGIN
 SET NOCOUNT ON;
  DECLARE  @Ln_One_NUMB                   NUMERIC(1) = 1,
           @Lc_StatusSuccess_CODE         CHAR(1) = 'S',
           @Lc_No_INDC                    CHAR(1) = 'N',
           @Lc_StatusFailed_CODE          CHAR(1) = 'F',
           @Lc_StatusNoticePending_CODE   CHAR(1) = 'P',
           @Lc_StatusNoticeReferred_CODE  CHAR(1) = 'R',
           @Ls_Routine_TEXT               VARCHAR(60) = 'BATCH_COMMON$SP_SUPPRESS_NOTICE';
  DECLARE  @Ln_Value_QNTY           NUMERIC(10) = 0,
           @Ln_Error_NUMB			NUMERIC(11),
           @Ln_ErrorLine_NUMB		NUMERIC(11),
           @Li_Rowcount_QNTY        SMALLINT,
           @Ls_Sql_TEXT             VARCHAR(200),
           @Ls_Sqldata_TEXT         VARCHAR(1000),
           @Ls_ErrorMessage_TEXT    VARCHAR(4000) = '';
           
  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   SET @Ls_Sql_TEXT = 'SELECT NMRQ_Y1';
   SET @Ls_Sqldata_TEXT = 'Notice_ID = ' + ISNULL (@Ac_Notice_ID, '') + ' Process_ID = ' + ISNULL (@Ac_Process_ID, '') + ' StatusNotice_CODE = ' + ISNULL (@Ac_StatusNotice_CODE, '');

   SELECT @Ln_Value_QNTY = COUNT (1)
     FROM NMRQ_Y1 n
    WHERE n.Notice_ID = @Ac_Notice_ID
      AND n.StatusNotice_CODE IN (@Lc_StatusNoticePending_CODE, @Lc_StatusNoticeReferred_CODE)
      AND EXISTS (SELECT 1
                    FROM GLEC_Y1 g
                   WHERE n.TransactionEventSeq_NUMB = g.TransactionEventSeq_NUMB
                     AND g.Process_ID = @Ac_Process_ID);
                  
   IF @Ln_Value_QNTY >= @Ln_One_NUMB
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE NMRQ_Y1 ';
     SET @Ls_Sqldata_TEXT = 'Notice_ID = ' + ISNULL (@Ac_Notice_ID, '') + ' Process_ID = ' + ISNULL (@Ac_Process_ID, '') + ' StatusNotice_CODE = ' + ISNULL (@Ac_StatusNotice_CODE, '');

     UPDATE NMRQ_Y1
        SET StatusNotice_CODE = @Ac_StatusNotice_CODE
       FROM NMRQ_Y1 a
      WHERE a.Notice_ID = @Ac_Notice_ID
        AND a.Barcode_NUMB IN (SELECT n.Barcode_NUMB
                                 FROM NMRQ_Y1 n
                                WHERE n.Notice_ID = @Ac_Notice_ID
                                  AND n.StatusNotice_CODE IN (@Lc_StatusNoticePending_CODE, @Lc_StatusNoticeReferred_CODE)
                                  AND EXISTS (SELECT 1
                                                FROM GLEC_Y1 g
                                               WHERE n.TransactionEventSeq_NUMB = g.TransactionEventSeq_NUMB
                                                 AND g.Process_ID = @Ac_Process_ID));

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE NOT SUCCESSFUL';

       RAISERROR (50001,16,1);
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_No_INDC;
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Routine_TEXT,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
      
  END CATCH
 END


GO
