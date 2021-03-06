/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_CWRK_WORKER_ID]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_CWRK_WORKER_ID
Programmer Name		: IMP Team
Description			: This procedure is used to assign a worker for an alert
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_CWRK_WORKER_ID] (
 @An_Case_IDNO                NUMERIC(6),
 @Ac_Worker_ID                CHAR(30)		= ' ',
 @An_Office_IDNO              NUMERIC(3)	= 0,
 @An_OfficeTo_IDNO            NUMERIC(3),
 @Ac_Role_ID                  CHAR(5)		= ' ',
 @Ac_RoleTo_ID                CHAR(5),
 @An_TransactionEventSeq_NUMB NUMERIC(10),
 @Ad_Run_DATE                 DATE,
 @Ac_SignedonWorker_ID        CHAR(30),
 @Ac_Job_ID                   CHAR(7),
 @Ac_Msg_CODE                 CHAR(5)		OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE			CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
          @Lc_ErrorE0001_CODE			CHAR(5)			= 'E0001',
          @Lc_ErrorE0058_CODE			CHAR(5)			= 'E0058',
          @Lc_ErrorE0113_CODE			CHAR(5)			= 'E0113',
          @Lc_WorkerBatch_ID			CHAR(5)			= 'BATCH',
          @Lc_JobCaseReassignment_ID	CHAR(7)			= 'DEB5280',
          @Ls_Routine_TEXT				VARCHAR(60)		= 'BATCH_COMMON$SP_INSERT_CWRK_WORKER_ID',
          @Ld_High_DATE					DATE			= '12/31/9999';
  DECLARE @Ln_CwrkCount_NUMB			NUMERIC(2),
          @Ln_UsrlCount_NUMB			NUMERIC(2),
          @Ln_Error_NUMB				NUMERIC(9),
          @Ln_RowCount_QNTY				NUMERIC(9),
          @Ln_ErrorLine_NUMB			NUMERIC(11),
          @Lc_CurrentWorker_ID			CHAR(30),
          @Ls_Sql_TEXT					VARCHAR(100),
          @Ls_Sqldata_TEXT				VARCHAR(1000),
          @Ls_ErrorMessage_TEXT			VARCHAR(4000)	= '',
          @Ld_Expire_DATE				DATE,
          @Ld_Current_DTTM				DATETIME2		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  BEGIN TRY
   -- Get the current Worker that is assigned in CWRK_Y1 for the given case with the specified role and case county
   SET @Ls_Sql_TEXT = 'Validate Current Worker ID IN CWRK_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
   
   SELECT @Lc_CurrentWorker_ID = cw.Worker_ID
     FROM CWRK_Y1 cw
    WHERE cw.Case_IDNO = @An_Case_IDNO
      AND cw.Role_ID = @Ac_Role_ID
      AND cw.Office_IDNO = @An_Office_IDNO
      AND cw.Effective_DATE <= @Ad_Run_DATE
      AND cw.Expire_DATE > @Ad_Run_DATE
      AND cw.EndValidity_DATE = @Ld_High_DATE;

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Lc_CurrentWorker_ID = '';
    END

   IF @Lc_CurrentWorker_ID != ''
      AND ((@Lc_CurrentWorker_ID != @Ac_Worker_ID)
			OR (@Ac_Role_ID != @Ac_RoleTo_ID)
            OR (@Lc_CurrentWorker_ID = @Ac_Worker_ID
                AND @An_Office_IDNO != @An_OfficeTo_IDNO))
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE CWRK_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', Worker_ID = ' + ISNULL(@Lc_CurrentWorker_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

     UPDATE CWRK_Y1
        SET Expire_DATE = @Ad_Run_DATE
      WHERE Case_IDNO = @An_Case_IDNO
        AND Office_IDNO = @An_Office_IDNO
        AND Role_ID = @Ac_Role_ID
        AND Worker_ID = @Lc_CurrentWorker_ID
        AND EndValidity_DATE = @Ld_High_DATE
        AND Effective_DATE <= @Ad_Run_DATE
        AND Expire_DATE > @Ad_Run_DATE;

     IF @Ac_SignedonWorker_ID != @Lc_WorkerBatch_ID
        AND @Ac_Job_ID != 'CCRT-R'
        AND @@ROWCOUNT != 0
      BEGIN
       SET @Ls_Sql_TEXT = 'Validate Usrl Count NUMB in USRL_Y1';
       SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', Worker_ID = ' + ISNULL(@Lc_CurrentWorker_ID,'');
       
       SELECT @Ln_UsrlCount_NUMB = COUNT(1)
         FROM USRL_Y1 u
        WHERE u.Office_IDNO = @An_Office_IDNO
          AND u.Role_ID = @Ac_Role_ID
          AND u.Worker_ID = @Lc_CurrentWorker_ID
          AND u.Effective_DATE <= @Ad_Run_DATE
          AND u.Expire_DATE > @Ad_Run_DATE
          AND u.EndValidity_DATE = @Ld_High_DATE
          AND u.CasesAssigned_QNTY > 0;

       IF @Ln_UsrlCount_NUMB > 0
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE CasesAssigned_QNTY IN USRL_Y1';
         SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', Worker_ID = ' + ISNULL(@Lc_CurrentWorker_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');

         UPDATE USRL_Y1
            SET CasesAssigned_QNTY = CasesAssigned_QNTY - 1
          WHERE Office_IDNO = @An_Office_IDNO
            AND Role_ID = @Ac_Role_ID
            AND Worker_ID = @Lc_CurrentWorker_ID
            AND Effective_DATE <= @Ad_Run_DATE
            AND Expire_DATE > @Ad_Run_DATE
            AND EndValidity_DATE = @Ld_High_DATE;

         SET @Ln_RowCount_QNTY = @@ROWCOUNT;

         IF @Ln_RowCount_QNTY = 0
          BEGIN
           SET @Ac_Msg_CODE = @Lc_ErrorE0001_CODE;
           SET @As_DescriptionError_TEXT = 'Update USRL_Y1 Not Successful 1';
           RETURN;
          END
        END
      END
    END

   SET @Ls_Sql_TEXT = 'Validate Worker count from CWRK_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', Worker_ID = ' + ISNULL(@Ac_Worker_ID,'')+ ', Role_ID = ' + ISNULL(@Ac_RoleTo_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_OfficeTo_IDNO AS VARCHAR ),'');

   SELECT @Ln_CwrkCount_NUMB = COUNT(1)
     FROM CWRK_Y1 cw
    WHERE cw.Case_IDNO = @An_Case_IDNO
      AND cw.Worker_ID = @Ac_Worker_ID
      AND cw.Role_ID = @Ac_RoleTo_ID
      AND cw.Office_IDNO = @An_OfficeTo_IDNO
      AND cw.Effective_DATE <= @Ad_Run_DATE
      AND cw.Expire_DATE > @Ad_Run_DATE
      AND cw.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_CwrkCount_NUMB = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT Expire_DATE OF WORKER WITH THE SPECIFIED ROLE FROM USRL_Y1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_Worker_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_OfficeTo_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_RoleTo_ID,'');

     SELECT @Ld_Expire_DATE = ur.Expire_DATE
       FROM USRL_Y1 ur
      WHERE ur.Worker_ID = @Ac_Worker_ID
        AND ur.Office_IDNO = @An_OfficeTo_IDNO
        AND ur.Role_ID = @Ac_RoleTo_ID
        AND ur.Effective_DATE <= @Ad_Run_DATE
        AND ur.Expire_DATE > @Ad_Run_DATE
        AND ur.EndValidity_DATE = @Ld_High_DATE;

     IF @Ld_Expire_DATE = ''
         OR @Ld_Expire_DATE IS NULL
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0058_CODE;
       SET @As_DescriptionError_TEXT = 'No Data Found in USRL_Y1 ';

       RETURN;
      END

     SET @Ls_Sql_TEXT = 'INSERT Worker INTO CWRK_Y1';
     SET @Ls_Sqldata_TEXT = 'Worker_ID = ' + ISNULL(@Ac_Worker_ID,'')+ ', Case_IDNO = ' + CAST( @An_Case_IDNO AS CHAR(6) )+ ', Office_IDNO = ' + ISNULL(CAST( @An_OfficeTo_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_RoleTo_ID,'')+ ', Effective_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Expire_DATE = ' + ISNULL(CAST( @Ld_Expire_DATE AS VARCHAR ),'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedonWorker_ID,'');

     INSERT INTO CWRK_Y1
                 (Worker_ID,
                  Case_IDNO,
                  Office_IDNO,
                  Role_ID,
                  Effective_DATE,
                  Expire_DATE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  TransactionEventSeq_NUMB,
                  Update_DTTM,
                  WorkerUpdate_ID)
          VALUES( @Ac_Worker_ID,--Worker_ID
                  @An_Case_IDNO,--Case_IDNO
                  @An_OfficeTo_IDNO,--Office_IDNO
                  @Ac_RoleTo_ID,--Role_ID
                  @Ad_Run_DATE,--Effective_DATE
                  @Ld_Expire_DATE,--Expire_DATE
                  @Ad_Run_DATE,--BeginValidity_DATE
                  @Ld_High_DATE,--EndValidity_DATE
                  @An_TransactionEventSeq_NUMB,--TransactionEventSeq_NUMB
                  @Ld_Current_DTTM,--Update_DTTM
                  @Ac_SignedonWorker_ID); --WorkerUpdate_ID

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0113_CODE;
       SET @As_DescriptionError_TEXT = 'INSERT Worker INTO CWRK_Y1 not successful';

       RETURN;
      END
     -- 13573 Case reassignment batch populated incorrect total case load -- Start
	IF @Ac_Job_ID != @Lc_JobCaseReassignment_ID
	BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE CasesAssigned_QNTY IN USRL_Y1';
     SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(CAST( @An_OfficeTo_IDNO AS CHAR(6) ),'')+ ', Role_ID = ' + ISNULL(@Ac_RoleTo_ID,'')+ ', Worker_ID = ' + ISNULL(@Ac_Worker_ID,'');

     UPDATE USRL_Y1
        SET CasesAssigned_QNTY = CasesAssigned_QNTY + 1,
			BeginValidity_DATE = @Ad_Run_DATE,
			TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
			Update_DTTM = @Ld_Current_DTTM,
			WorkerUpdate_ID = @Ac_SignedonWorker_ID
      WHERE Office_IDNO = @An_OfficeTo_IDNO
        AND Role_ID = @Ac_RoleTo_ID
        AND Worker_ID = @Ac_Worker_ID
        AND Effective_DATE <= @Ad_Run_DATE
        AND Expire_DATE > @Ad_Run_DATE
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_ErrorE0001_CODE;
       SET @As_DescriptionError_TEXT = 'UPDATE CasesAssigned_QNTY IN USRL_Y1 not successful 2';

       RETURN;
      END
     END
     -- 13573 Case reassignment batch populated incorrect total case load -- End
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT ='';
  END TRY

  BEGIN CATCH
   BEGIN
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

   END
  END CATCH
 END



GO
