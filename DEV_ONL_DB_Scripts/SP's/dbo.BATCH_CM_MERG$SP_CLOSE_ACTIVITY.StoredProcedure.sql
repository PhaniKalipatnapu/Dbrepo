/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_CLOSE_ACTIVITY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_MERG$SP_CLOSE_ACTIVITY
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	DAILY
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_CLOSE_ACTIVITY]
 @As_Case_IDNO                NUMERIC(9),
 @An_OrderSeq_NUMB            NUMERIC(9),
 @An_MajorIntSeq_NUMB         NUMERIC(9),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @As_WorkerUpdate_ID          CHAR(30),
 @Ad_Run_DATE                 DATETIME2(0),
 @Ac_Msg_CODE                 CHAR(3) OUTPUT,
 @As_DescriptionError_TEXT               VARCHAR OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Ls_Procedure_NAME        VARCHAR(100) ='SP_CLOSE_ACTIVITY',
          @Ls_Package_NAME          VARCHAR(100) ='BATCH_CM_MERG$SP_CLOSE_ACTIVITY',
          @Ls_Successful_INDC       VARCHAR (20) = 'SUCCESSFUL',
          @Lc_StatusSuccess_CODE    CHAR (1) = 'S',
          @Ls_BatchRunUser_TEXT     VARCHAR(5) = 'BATCH',
          @Ls_Yes_TEXT              CHAR(1) = 'Y',
          @Ls_No_TEXT               CHAR(1) = 'N',
          @Ld_HighDate_DATE         DATETIME2(0) = '12/31/9999',
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ls_Routine_TEXT          VARCHAR(100) = 'SP_CLOSE_ACTIVITY',
          @Lc_Null_TEXT             CHAR(1) = '',
          @Lc_Successful_TEXT       CHAR(20) = 'SUCCESSFUL',
          @Lc_Space_TEXT            CHAR(1) = ' ',
          @Ld_Run_DATE              DATETIME2(0),
          @Lc_Msg_CODE              CHAR(1),
          @Ls_Error_DESC            VARCHAR(4000),
          @Ls_DescriptionError_TEXT VARCHAR (4000),
          @Ls_ErrorDesc_TEXT        VARCHAR(4000),
          @Ls_Case_IDNO             VARCHAR(10),
          @Ln_TransEventSeq_NUMB    NUMERIC(19, 0),
          @Lc_Error_CODE            CHAR(5),
          @Ln_TopicVal_SEQ          NUMERIC(19, 0),
          @Ln_Topic_IDNO            NUMERIC(19, 0),
          @Ln_MinorIntSeq_NUMB      NUMERIC(19, 0);

  BEGIN TRY
   SET @Ld_Run_DATE = @Ad_Run_DATE;
   SET @Ls_Sql_TEXT ='UPDATE VDMJR COMPLETE STATUS ';
   SET @Ls_Sqldata_TEXT = 'ID_CASE' + CAST(@As_Case_IDNO AS CHAR) + 'SEQ_MAJOR_INT' + CAST(@An_MajorIntSeq_NUMB AS CHAR) + 'SEQ_ORDER' + CAST(@An_OrderSeq_NUMB AS CHAR);

   UPDATE DMJR_Y1
      SET status_code = 'COMP',
          status_date = @Ld_Run_DATE,
          beginvalidity_date = @Ld_Run_DATE,
          workerupdate_id = @As_WorkerUpdate_ID,
          update_dttm = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          transactioneventseq_numb = @An_TransactionEventSeq_NUMB
    WHERE case_idno = @As_Case_IDNO
      AND orderseq_numb = @An_OrderSeq_NUMB
      AND majorintseq_numb = @An_MajorIntSeq_NUMB;

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ac_Msg_CODE = 'F';
     SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + @Ls_Sql_TEXT + ' ' + 'UPDATE VDMJR FAILED' + ' ' + @Ls_Sqldata_TEXT;

     RAISERROR(50001,16,1);
    END;

   SET @Ls_Sql_TEXT ='SELECT SEQ_MAJOR_INT VDMNR 1 ';

   SELECT @Ln_MinorIntSeq_NUMB = MAX(minorintseq_numb)
     FROM DMNR_Y1
    WHERE case_idno = @As_Case_IDNO
      AND majorintseq_numb = @An_MajorIntSeq_NUMB
      AND orderseq_numb = @An_OrderSeq_NUMB
      AND status_code = 'STRT';

   SET @Ls_Sql_TEXT ='SELECT SEQ_TOPIC VDMNR 1 ';

   BEGIN TRANSACTION

   DELETE FROM identseqtopic_t1;

   INSERT INTO identseqtopic_t1
        VALUES(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

   SELECT @Ln_TopicVal_SEQ = seq_idno
     FROM identseqtopic_t1;

   COMMIT TRANSACTION

   SELECT @Ln_Topic_IDNO = @Ln_TopicVal_SEQ;

   -- Updating with the rmdcy activity   
   SET @Ls_Sql_TEXT = 'UPDATE_INSERT_MINOR_ACTIVITY_RMDCY ';
   SET @Ls_Sqldata_TEXT = 'ID_CASE' + CAST(@As_Case_IDNO AS CHAR) + 'SEQ_MAJOR_INT' + CAST(@An_MajorIntSeq_NUMB AS CHAR) + 'SEQ_ORDER' + CAST(@An_OrderSeq_NUMB AS CHAR);

   UPDATE DMNR_Y1
      SET activityminornext_code = 'RMDCY',
          status_date = @Ld_Run_DATE,
          status_code = 'COMP',
          reasonstatus_code = 'SY',
          beginvalidity_date = @Ld_Run_DATE,
          workerupdate_id = @As_WorkerUpdate_ID,
          update_dttm = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          transactioneventseq_numb = @An_TransactionEventSeq_NUMB
    WHERE case_idno = @As_Case_IDNO
      AND majorintseq_numb = @An_MajorIntSeq_NUMB
      AND orderseq_numb = @An_OrderSeq_NUMB
      AND minorintseq_numb = @Ln_MinorIntSeq_NUMB;

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ac_Msg_CODE = 'F';
     SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + @Ls_Sql_TEXT + ' ' + 'UPDATE VDMNR FAILED' + ' ' + @Ls_Sqldata_TEXT;

     RAISERROR(50001,16,1);
    END;

   -- Inserting the rmdcy activity    
   SET @Ls_Sql_TEXT = 'INSERT_MINOR_ACTIVITY_RMDCY ';
   SET @Ls_Sqldata_TEXT = 'ID_CASE' + CAST(@As_Case_IDNO AS CHAR) + 'SEQ_MAJOR_INT' + CAST(@An_MajorIntSeq_NUMB AS CHAR) + 'SEQ_ORDER' + CAST(@An_OrderSeq_NUMB AS CHAR);

   INSERT INTO DMNR_Y1
               (case_idno,
                orderseq_numb,
                majorintseq_numb,
                minorintseq_numb,
                membermci_idno,
                activityminor_code,
                activityminornext_code,
                entered_date,
                due_date,
                status_date,
                status_code,
                reasonstatus_code,
                schedule_numb,
                forum_idno,
                topic_idno,
                totalreplies_qnty,
                totalviews_qnty,
                postlastposter_idno,
                userlastposter_id,
                lastpost_dttm,
                alertprior_date,
                beginvalidity_date,
                workerupdate_id,
                update_dttm,
                transactioneventseq_numb,
                workerdelegate_id,
                activitymajor_code,
                subsystem_code)
   SELECT case_idno,
          orderseq_numb,
          majorintseq_numb,
          minorintseq_numb + 1,
          membermci_idno,
          'RMDCY',
          ' ',
          @Ad_Run_DATE,
          @Ad_Run_DATE,
          @Ad_Run_DATE,
          'COMP',
          'SY',
          0,
          forum_idno,
          @Ln_Topic_IDNO,
          0,
          0,
          0,
          @As_WorkerUpdate_ID,
          dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ad_Run_DATE,
          @Ad_Run_DATE,
          @As_WorkerUpdate_ID,
          dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          transactioneventseq_numb,
          workerdelegate_id,
          activitymajor_code,
          subsystem_code
     FROM DMNR_Y1
    WHERE case_idno = @As_Case_IDNO
      AND majorintseq_numb = @An_MajorIntSeq_NUMB
      AND orderseq_numb = @An_OrderSeq_NUMB
      AND minorintseq_numb = @Ln_MinorIntSeq_NUMB;

   IF @@ROWCOUNT = 0
    BEGIN
     SET @Ac_Msg_CODE = 'F';
     SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + @Ls_Sql_TEXT + ' ' + 'INSERT VDMNR FAILED' + ' ' + @Ls_Sqldata_TEXT;

     RAISERROR(50001,16,1);
    END;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = 'F';
   SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + @Ls_Sql_TEXT + ' ' + @Ls_Sqldata_TEXT;

   RETURN;
  END CATCH
 END


GO
