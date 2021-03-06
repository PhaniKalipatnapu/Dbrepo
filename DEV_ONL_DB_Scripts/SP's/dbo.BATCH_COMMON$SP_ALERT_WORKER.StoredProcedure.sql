/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_ALERT_WORKER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_ALERT_WORKER
Programmer Name		: IMP Team
Description			: This procedure is used to assign a worker for an alert
Frequency			: 
Developed On		: 04/12/2011
Called BY			: 
Called ON	: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_ALERT_WORKER]
 @An_Case_IDNO                CHAR(6),
 @Ac_Subsystem_CODE           CHAR(2)		= ' ',
 @Ac_ActivityMajor_CODE       CHAR(4)		= ' ',
 @Ac_ActivityMinor_CODE       CHAR(5)		= ' ',
 @Ac_ReasonStatus_CODE        CHAR(2)		= ' ',
 @An_MajorIntSeq_NUMB         NUMERIC(5)	= 0,
 @An_MinorIntSeq_NUMB         NUMERIC(5)	= 0,
 @Ac_SignedonWorker_ID        CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(10),
 @Ad_Run_DATE                 DATE,
 @Ac_Role_ID                  CHAR(5)		= ' ',
 @An_OfficeTo_IDNO            NUMERIC(3)	= -1,
 @Ac_Job_ID                   CHAR(7),
 @Ac_CurrentWorker_ID         CHAR(30)		= ' ',
 @Ac_Worker_ID                CHAR(30)		= ' ',
 @As_DescriptionNote_TEXT     VARCHAR(4000) = ' ',
 @Ac_Msg_CODE                 CHAR(5)		OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
 
 SET NOCOUNT ON;
  CREATE TABLE #PrimaryRole_P1
   (
     Role_ID CHAR(5)
   );

  DECLARE  @Lc_StatusFailed_CODE		CHAR(1)			= 'F',
           @Lc_StatusSuccess_CODE		CHAR(1)			= 'S',
           @Lc_SupervisorAlert_CODE		CHAR(1)			= 'S',
           @Lc_Yes_INDC					CHAR(1)			= 'Y',
           @Lc_No_INDC					CHAR(1)			= 'N',
           @Lc_InformOldWorker_INDC		CHAR(1)			= 'N',
           @Lc_Acrl_INDC				CHAR(1)			= 'N',
           @Lc_CursorOpened_INDC		CHAR(1)			= 'N',
           @Lc_CaseStatusOpen_CODE		CHAR(1)			= 'O',
           @Lc_ActivityMajorCase_CODE	CHAR(4)			= 'CASE',
           @Ls_Procedure_NAME			VARCHAR(30)		= 'BATCH_COMMON$SP_ALERT_WORKER',
           @Ld_High_DATE				DATE			= '12/31/9999';
  DECLARE  @Ln_Case_Count_NUMB          NUMERIC(2)		= 0,
           @Ln_Office_IDNO              NUMERIC(3)		= 0,
           @Ln_OfficeTo_IDNO            NUMERIC(3)		= 0,
           @Ln_Usrl_Count_NUMB          NUMERIC(5)		= 0,
           @Ln_IcasCount_NUMB			NUMERIC(5)		= 0,
           @Ln_Error_NUMB               NUMERIC(11),
           @Ln_ErrorLine_NUMB           NUMERIC(11),
           @Li_FetchStatus_QNTY			INT,
           @Lc_ActionAlert_CODE         CHAR(1),
           @Lc_Null_TEXT                CHAR(1)			= '',
           @Lc_ActivityMinor_CODE       CHAR(5),
           @Lc_Role_ID                  CHAR(5),
           @Lc_CsenetReason_CODE        CHAR(5),
           @Lc_Case_Worker_ID           CHAR(30)		= '',
           @Ls_Sql_TEXT                 VARCHAR(100)	= '',
           @Ls_Sqldata_TEXT             VARCHAR(1000)	= '';

 DECLARE @Ln_AcrlCur_Office_IDNO NUMERIC(9),
		 @Lc_RoleCur_Role_ID	CHAR(5) ;
  BEGIN TRY
   SET @Ln_Office_IDNO = -1;
   SET @Ln_OfficeTo_IDNO = -1;
  
   -- RS002 Central Registry Manager (Responding interstate case
   SET @Ls_Sql_TEXT = 'INSERT INTO #PrimaryRole_P1';
   
   INSERT INTO #PrimaryRole_P1
               (Role_ID)
        VALUES ('RS002'),
			   ('RC005'),
			   ('RT001'),
			   ('RE001'),
			   ('RS016'),
			   ('RP004');
			  
   IF @Ac_ActivityMinor_CODE != ''
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT ActivityMinor_CODE FROM ANXT_Y1';
     SET @Ls_Sqldata_TEXT = ' ActivityMajor_CODE: ' + @Ac_ActivityMajor_CODE + ' ActivityMinor_CODE: ' + @Ac_ActivityMinor_CODE + ' Reason_CODE: ' + @Ac_ReasonStatus_CODE;

     SELECT @Lc_ActivityMinor_CODE = CASE
                                      WHEN @Ac_ReasonStatus_CODE != ''
                                       THEN (SELECT an.ActivityMinorNext_CODE
                                               FROM ANXT_Y1 an
                                              WHERE an.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                                                AND an.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                                                AND an.Reason_CODE = @Ac_ReasonStatus_CODE
                                                AND an.EndValidity_DATE = @Ld_High_DATE)
                                      ELSE @Ac_ActivityMinor_CODE
                                     END;

     IF ISNULL(@Lc_ActivityMinor_CODE,'') = ''
      BEGIN
       SET @Ac_Msg_CODE = 'E0058';
       SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_ALERT_WORKER' + ' PROCEDURE ' + '. Error DESC - ' + 'No Data Found in ANXT_Y1 ' + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + ' . Error List KEY - ' + @Ls_Sqldata_TEXT;

       RETURN;
      END

     SET @Ls_Sql_TEXT = 'SELECT ActionAlert_CODE FROM AMNR_Y1';
     SET @Ls_Sqldata_TEXT = @Ls_Sqldata_TEXT + 'ActivityMinor_CODE = ' + @Lc_ActivityMinor_CODE;

     SELECT @Lc_ActionAlert_CODE = an.ActionAlert_CODE
       FROM AMNR_Y1 an
      WHERE an.ActivityMinor_CODE = @Lc_ActivityMinor_CODE
        AND an.EndValidity_DATE = @Ld_High_DATE;

     IF ISNULL(@Lc_ActionAlert_CODE,'') = ''
      BEGIN
       SET @Ac_Msg_CODE = 'E0058';
       SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_ALERT_WORKER' + ' PROCEDURE ' + '. Error DESC - ' + 'No Data Found in AMNR_Y1 ' + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + ' . Error List KEY - ' + @Ls_Sqldata_TEXT;
       RETURN;
      END

     IF @Lc_ActionAlert_CODE = @Lc_No_INDC
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
       RETURN;
      END

      SET @Ls_Sql_TEXT = 'SELECT ACRL_Y1 For Case Worker Alert';
      -- 13595 - Role-based alerts are not going to the associated role but to the assigned caseworker - Start
      IF EXISTS ( SELECT 1
                        FROM ACRL_Y1 a
                       WHERE a.WorkerAssign_INDC = @Lc_Yes_INDC
						 AND a.Role_ID = ''
                         AND a.Category_CODE = @Ac_Subsystem_CODE
                         AND a.SubCategory_CODE = @Ac_ActivityMajor_CODE
                         AND a.ActivityMinor_CODE = @Lc_ActivityMinor_CODE
                         AND a.EndValidity_DATE = @Ld_High_DATE)
       BEGIN
      
		  SET @Ls_Sql_TEXT = 'UPDATE DMNR_Y1 for WorkerDelegate_ID Case Worker Alert';
		  UPDATE d
			SET d.WorkerDelegate_ID = c.Worker_ID
		   FROM DMNR_Y1 d
		   JOIN CASE_Y1 c
			 ON c.Case_IDNO = @An_Case_IDNO
			AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
		  WHERE d.Case_IDNO = @An_Case_IDNO
			AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
			AND d.MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
			AND d.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB;
      
		  IF @@ROWCOUNT = 0
		  BEGIN
			SET @As_DescriptionError_TEXT = 'DMNR_Y1 UPDATE for WorkerDelegate_ID Case Worker Alert Failed';
			RAISERROR(50001,16,1);
		  END
		  SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
		  RETURN;
	   END
	   -- 13595 - Role-based alerts are not going to the associated role but to the assigned caseworker - End
    END

   IF @Ac_Job_ID != 'USEM'
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT Worker_ID FROM CASE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6));

     SELECT @Lc_Case_Worker_ID = an.Worker_ID,
            @Ln_Office_IDNO = Office_IDNO
       FROM CASE_Y1 an
      WHERE an.Case_IDNO = @An_Case_IDNO
        AND an.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

     IF ISNULL(@Ln_Office_IDNO,-1) = -1
      BEGIN
       SET @Ac_Msg_CODE = 'E0058';
       SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_ALERT_WORKER' + ' PROCEDURE' + '. Error DESC - ' + 'No Data Found With Open Case in CASE_Y1' + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
       RETURN;
      END
    END

   IF @Ac_Job_ID = 'RSTR'
    BEGIN
     IF EXISTS (SELECT 1
                  FROM USRT_Y1 t
                 WHERE t.Case_IDNO = @An_Case_IDNO
                   AND t.Familial_INDC = @Lc_Yes_INDC
                   AND t.EndValidity_DATE = @Ld_High_DATE
                   AND t.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
				   AND NOT EXISTS (SELECT 1
									FROM CWRK_Y1 c
								   WHERE c.Case_IDNO = @An_Case_IDNO
									 AND c.Office_IDNO = @Ln_Office_IDNO
									 AND c.Effective_DATE <= @Ad_Run_DATE
									 AND c.Expire_DATE > @Ad_Run_DATE
									 AND c.EndValidity_DATE = @Ld_High_DATE
									 AND c.Worker_ID = t.Worker_ID))
        BEGIN
         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
         RETURN;
        END
    END

   -- ASMT ( Transfer Case To Another County)
   IF (@An_OfficeTo_IDNO != -1
       AND @An_OfficeTo_IDNO != @Ln_Office_IDNO
       AND @Ac_Job_ID != 'USEM')
    BEGIN
		SET @Ln_OfficeTo_IDNO = @An_OfficeTo_IDNO;
    END
   ELSE IF @Ac_Job_ID = 'USEM'
    BEGIN
     SET @Ln_OfficeTo_IDNO = @An_OfficeTo_IDNO;
     SET @Ln_Office_IDNO = @An_OfficeTo_IDNO;
     SET @Lc_Case_Worker_ID = @Ac_CurrentWorker_ID;
    END
   ELSE
    BEGIN
     SET @Ln_OfficeTo_IDNO = @Ln_Office_IDNO;
    END

   IF (@Ac_Subsystem_CODE != ''
		AND @Ac_ActivityMajor_CODE != ''
		AND @Lc_ActivityMinor_CODE != '')
    BEGIN
     DECLARE Acrl_Cur INSENSITIVE CURSOR FOR
      SELECT @Ln_Office_IDNO AS Office_IDNO,
             CASE
              WHEN WorkerAssign_INDC = @Lc_SupervisorAlert_CODE
               THEN @Lc_SupervisorAlert_CODE
              ELSE Role_ID
             END AS Role_ID,
             @An_Case_IDNO AS Case_IDNO
        FROM ACRL_Y1 ar
       WHERE ar.Category_CODE = @Ac_Subsystem_CODE
         AND ar.SubCategory_CODE = @Ac_ActivityMajor_CODE
         AND ar.ActivityMinor_CODE = @Lc_ActivityMinor_CODE
         AND ar.WorkerAssign_INDC != @Lc_No_INDC
         AND ar.EndValidity_DATE = @Ld_High_DATE;

     SET @Lc_Acrl_INDC = @Lc_Yes_INDC;
    END
   ELSE IF @Ac_Job_ID = 'ASMT'
      AND @An_OfficeTo_IDNO != -1
    BEGIN
     DECLARE Acrl_Cur INSENSITIVE CURSOR FOR
      SELECT Office_IDNO,
             Role_ID,
             Case_IDNO
        FROM CWRK_Y1 cw
       WHERE cw.Case_IDNO = @An_Case_IDNO
		 AND cw.EndValidity_DATE = @Ld_High_DATE
         AND (cw.Office_IDNO = @Ln_Office_IDNO
               OR @Ln_Office_IDNO = -1)
         AND (cw.Role_ID = @Ac_Role_ID
               OR @Ac_Role_ID = '')
         AND (cw.Worker_ID = @Ac_CurrentWorker_ID
               OR @Ac_CurrentWorker_ID = '')
         AND cw.Effective_DATE <= @Ad_Run_DATE
         AND cw.Expire_DATE > @Ad_Run_DATE;
    END
   ELSE IF @Ac_Job_ID = 'USEM'
    BEGIN
     DECLARE Acrl_Cur INSENSITIVE CURSOR FOR
      SELECT Office_IDNO,
             Role_ID,
             Case_IDNO
        FROM CWRK_Y1 cw
       WHERE cw.EndValidity_DATE = @Ld_High_DATE
		 AND cw.Effective_DATE <= @Ad_Run_DATE
         AND cw.Expire_DATE > @Ad_Run_DATE
         AND (cw.Office_IDNO = @Ln_Office_IDNO
               OR @Ln_Office_IDNO = -1 )
         AND (@Ac_Role_ID = cw.Role_ID
               OR @Ac_Role_ID = '')
         AND (cw.Worker_ID = @Ac_CurrentWorker_ID
               OR @Ac_CurrentWorker_ID = '')
         AND EXISTS (SELECT 1
                       FROM CASE_Y1 c
                      WHERE c.Case_IDNO = cw.Case_IDNO
                        AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE);
    END
   ELSE
    BEGIN
     DECLARE Acrl_Cur INSENSITIVE CURSOR FOR
      SELECT @Ln_Office_IDNO AS Office_IDNO,
             @Ac_Role_ID AS Role_ID,
             @An_Case_IDNO AS Case_IDNO;
    END

   OPEN Acrl_Cur;

   FETCH NEXT FROM Acrl_Cur INTO @Ln_AcrlCur_Office_IDNO, @Ac_Role_ID, @An_Case_IDNO;
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   -- FETCH EACH RECORD
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Lc_CursorOpened_INDC = @Lc_Yes_INDC;
      IF @Ac_Job_ID NOT IN('ASMT', 'USEM')
      BEGIN
       SET @Ac_Worker_ID = '';
      END

     IF (@Ac_Role_ID = ''
         AND @Ac_Worker_ID = ''
         AND @Ac_Job_ID != 'RSTR'
         AND @Lc_Acrl_INDC = 'N')
      BEGIN
       SET @Ac_Msg_CODE = 'E0058';
       SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_ALERT_WORKER' + ' PROCEDURE' + '. Error DESC - ' + 'ROLE_ID AND/OR WORKER_ID IS NOT SENT AS INPUT.';

       RETURN;
      END

	 /*When alert generating for Primary Role, Old Role need to be endated*/
	 IF EXISTS (SELECT 1 FROM #PrimaryRole_P1 WHERE Role_ID = @Ac_Role_ID)  
		AND ISNULL(@Lc_Case_Worker_ID,'') <> ' '
		BEGIN
			SELECT @Lc_Role_ID = Role_ID
                        FROM CWRK_Y1 c
                       WHERE c.Worker_ID = @Lc_Case_Worker_ID
						 AND c.Case_IDNO = @An_Case_IDNO
                         AND c.Office_IDNO = @Ln_Office_IDNO
                         AND c.EndValidity_DATE = @Ld_High_DATE
                         AND c.Effective_DATE <= @Ad_Run_DATE
                         AND c.Expire_DATE > @Ad_Run_DATE;
             IF @Ac_Worker_ID = ''
				AND @Ac_Job_ID NOT IN ('ASMT','RSTR','CPRO')
				AND @Ac_SignedonWorker_ID != 'BATCH'
				AND @Lc_Role_ID = @Ac_Role_ID
			 BEGIN
				SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
				RETURN;
			 END
			 
		END
	 ELSE
		BEGIN
			SET @Lc_Role_ID = @Ac_Role_ID;
		END
	
     SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_GET_ALERT_WORKER_ID';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6))+ ', Case_Worker_ID = ' + ISNULL(@Lc_Case_Worker_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @Ln_OfficeTo_IDNO AS VARCHAR ),'')+ ', Run_DATE = ' + CAST( @Ad_Run_DATE AS CHAR(10))+ ', SignedonWorker_ID = ' + @Ac_SignedonWorker_ID+ ', Acrl_INDC = ' + ISNULL(@Lc_Acrl_INDC,'')+ ', Job_ID = ' + @Ac_Job_ID;
     EXECUTE BATCH_COMMON$SP_GET_ALERT_WORKER_ID
      @An_Case_IDNO             = @An_Case_IDNO,
      @Ac_Case_Worker_ID        = @Lc_Case_Worker_ID,
      @An_Office_IDNO           = @Ln_OfficeTo_IDNO,
      @Ac_Role_ID               = @Ac_Role_ID OUTPUT,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_SignedonWorker_ID     = @Ac_SignedonWorker_ID,
      @Ac_Acrl_INDC             = @Lc_Acrl_INDC,
      @Ac_Job_ID                = @Ac_Job_ID,
      @Ac_Worker_ID             = @Ac_Worker_ID OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       SET @Ln_Error_NUMB = ERROR_NUMBER();
       SET @Ln_ErrorLine_NUMB = ERROR_LINE();

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION';
       SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL('BATCH_COMMON$SP_ALERT_WORKER','')+ ', ErrorMessage_TEXT = ' + ISNULL(@As_DescriptionError_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'')+ ', Error_NUMB = ' + ISNULL(CAST( @Ln_Error_NUMB AS VARCHAR ),'')+ ', ErrorLine_NUMB = ' + ISNULL(CAST( @Ln_ErrorLine_NUMB AS VARCHAR ),'');
       
       EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
        @As_Procedure_NAME        = 'BATCH_COMMON$SP_ALERT_WORKER',
        @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
        @As_Sql_TEXT              = @Ls_Sql_TEXT,
        @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
        @An_Error_NUMB            = @Ln_Error_NUMB,
        @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
        @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

       RETURN;
      END

     IF @Ac_Job_ID IN ('ASMT', 'USEM', 'RSTR', 'ISIN')
        AND @Ac_Worker_ID != @Lc_Case_Worker_ID
      BEGIN
       SET @Lc_InformOldWorker_INDC = @Lc_Yes_INDC;
      END

     -- Ac_Worker_ID will be either as Input or Case Worker(CASE_Y1)/Role Worker(CWRK_Y1) will be assigned to the variable
     IF ((ISNULL(@Ac_Worker_ID,'') != ''
          AND ISNULL(@Ac_Role_ID,'') != '')
          OR (@Lc_Acrl_INDC = @Lc_Yes_INDC
              AND ISNULL(@Ac_Worker_ID,'') != ''))
      BEGIN
       IF @Ac_Job_ID = 'RSTR'
        BEGIN
         DECLARE Role_Cur INSENSITIVE CURSOR FOR
          SELECT Role_ID,
                 Role_ID
            FROM CWRK_Y1 c
           WHERE c.EndValidity_DATE = @Ld_High_DATE
             AND @Ad_Run_DATE BETWEEN c.Effective_DATE AND c.Expire_DATE
             AND c.Case_IDNO = @An_Case_IDNO
             AND c.Office_IDNO = @Ln_AcrlCur_Office_IDNO
             AND c.Worker_ID = @Lc_Case_Worker_ID;
        END
       ELSE
        BEGIN
         DECLARE Role_Cur INSENSITIVE CURSOR FOR
          SELECT @Lc_Role_ID AS Role_ID,
                 @Ac_Role_ID AS RoleTo_ID;
        END

       OPEN Role_Cur;

       FETCH NEXT FROM Role_Cur INTO @Lc_RoleCur_Role_ID, @Ac_Role_ID;
       
       SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	   -- FETCH EACH RECORD
       WHILE @Li_FetchStatus_QNTY = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'CASE COUNT - 1'; 
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6))+ ', Worker_ID = ' + ISNULL(@Ac_Worker_ID,'');
         SELECT @Ln_Case_Count_NUMB = COUNT(1)
           FROM CASE_Y1 c
          WHERE Case_IDNO = @An_Case_IDNO
            AND Worker_ID = @Ac_Worker_ID
            AND StatusCase_CODE = @Lc_CaseStatusOpen_CODE;

         SET @Ls_Sql_TEXT = 'ICAS CASE COUNT - 2'; 
         
         SELECT @Ln_IcasCount_NUMB = COUNT(1)
           FROM ICAS_Y1 c
          WHERE Case_IDNO = @An_Case_IDNO
            AND EndValidity_DATE = @Ld_High_DATE
            AND Status_CODE = @Lc_CaseStatusOpen_CODE
            AND IVDOutOfStateCase_ID != @Lc_Null_TEXT
            AND Create_DATE < @Ad_Run_DATE;
         -- When Office id is modified
         IF @An_OfficeTo_IDNO != -1
            AND @Ac_Job_ID != 'USEM'
          BEGIN
           SET @Lc_CsenetReason_CODE = 'GSFIP';
          END
         -- When primary role and case worker is being changed and more than 1 open isin records exist for the same state that is being added
         ELSE IF @Lc_RoleCur_Role_ID IN (SELECT Role_ID
                              FROM #PrimaryRole_P1)
            AND @Ln_Case_Count_NUMB = 0
            AND @Ln_IcasCount_NUMB > 0
          BEGIN
           SET @Lc_CsenetReason_CODE = 'GSWKR';
          END

         SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR),'')+ ', Office_IDNO = ' + ISNULL(CAST( @Ln_AcrlCur_Office_IDNO AS VARCHAR ),'')+ ', OfficeTo_IDNO = ' + ISNULL(CAST( @Ln_OfficeTo_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Lc_RoleCur_Role_ID,'')+ ', RoleTo_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', Current_Worker_ID = ' + ISNULL(@Lc_Case_Worker_ID,'')+ ', Assigned_Worker_ID = ' + ISNULL(@Ac_Worker_ID,'')+ ', CsenetReason_CODE = ' + ISNULL(@Lc_CsenetReason_CODE,'')+ ', MajorIntSeq_NUMB = ' + ISNULL(CAST( @An_MajorIntSeq_NUMB AS VARCHAR ),'')+ ', MinorIntSeq_NUMB = ' + ISNULL(CAST( @An_MinorIntSeq_NUMB AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedonWorker_ID,'')+ ', InformOldWorker_INDC = ' + ISNULL(@Lc_InformOldWorker_INDC,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'');

         EXECUTE BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER
          @An_Case_IDNO                = @An_Case_IDNO,
          @An_Office_IDNO              = @Ln_AcrlCur_Office_IDNO,
          @An_OfficeTo_IDNO            = @Ln_OfficeTo_IDNO,
          @Ac_Role_ID                  = @Lc_RoleCur_Role_ID,
          @Ac_RoleTo_ID                = @Ac_Role_ID,
          @Ac_Current_Worker_ID        = @Lc_Case_Worker_ID,
          @Ac_Assigned_Worker_ID       = @Ac_Worker_ID,
          @Ac_CsenetReason_CODE        = @Lc_CsenetReason_CODE,
          @An_MajorIntSeq_NUMB         = @An_MajorIntSeq_NUMB,
          @An_MinorIntSeq_NUMB         = @An_MinorIntSeq_NUMB,
          @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_Job_ID                   = @Ac_Job_ID,
          @Ac_SignedOnWorker_ID        = @Ac_SignedonWorker_ID,
          @Ac_InformOldWorker_INDC     = @Lc_InformOldWorker_INDC,
          @As_DescriptionNote_TEXT     = @As_DescriptionNote_TEXT,
          @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

         IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
          BEGIN
           SET @Ln_Error_NUMB = ERROR_NUMBER();
           SET @Ln_ErrorLine_NUMB = ERROR_LINE();
           
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GET_ERROR_DESCRIPTION - 2';
           SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL('BATCH_COMMON$SP_ALERT_WORKER','')+ ', ErrorMessage_TEXT = ' + ISNULL(@As_DescriptionError_TEXT,'')+ ', Sql_TEXT = ' + ISNULL(@Ls_Sql_TEXT,'')+ ', Sqldata_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT,'')+ ', Error_NUMB = ' + ISNULL(CAST( @Ln_Error_NUMB AS VARCHAR ),'')+ ', ErrorLine_NUMB = ' + ISNULL(CAST( @Ln_ErrorLine_NUMB AS VARCHAR ),'');

           EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
            @As_Procedure_NAME        = 'BATCH_COMMON$SP_ALERT_WORKER',
            @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
            @As_Sql_TEXT              = @Ls_Sql_TEXT,
            @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
            @An_Error_NUMB            = @Ln_Error_NUMB,
            @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
            @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

           RETURN;
          END
		IF @Ac_Job_ID IN ('ASMT')
				 AND @An_OfficeTo_IDNO != -1
				SET @Ac_Worker_ID = '';
		
         FETCH NEXT FROM Role_Cur INTO @Lc_RoleCur_Role_ID, @Ac_Role_ID;
         SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
        END

       CLOSE Role_Cur;

       DEALLOCATE Role_Cur;
      END
     ELSE
      BEGIN
       SET @Ac_Msg_CODE = 'E0058';
       SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_ALERT_WORKER' + ' PROCEDURE ' + '. Error DESC - ' + 'Worker_ID AND/OR Role_ID IS EMPTY OR NULL.';

       RETURN;
      END

     FETCH NEXT FROM Acrl_Cur INTO @Ln_AcrlCur_Office_IDNO, @Ac_Role_ID, @An_Case_IDNO;
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Acrl_Cur;

   DEALLOCATE Acrl_Cur;

   IF @Lc_CursorOpened_INDC = @Lc_No_INDC
      AND @Lc_Acrl_INDC = @Lc_No_INDC
    BEGIN
     SET @Ac_Msg_CODE = 'E0944';
     SET @As_DescriptionError_TEXT = 'No Record(s) to Process';

     RETURN;
    END
   ELSE IF @Lc_CursorOpened_INDC = @Lc_No_INDC
      AND @Lc_Acrl_INDC = @Lc_Yes_INDC
    BEGIN
     SET @Ls_Sql_TEXT = '';
     SET @Ls_Sqldata_TEXT = 'Category_CODE = ' + ISNULL(@Ac_Subsystem_CODE,'')+ ', SubCategory_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE,'')+ ', WorkerAssign_INDC = ' + ISNULL(@Lc_No_INDC,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
     
     SELECT @Ac_Role_ID = Role_ID
       FROM ACRL_Y1 ar
      WHERE ar.Category_CODE = @Ac_Subsystem_CODE
        AND ar.SubCategory_CODE = @Ac_ActivityMajor_CODE
        AND ar.ActivityMinor_CODE = @Lc_ActivityMinor_CODE
        AND ar.WorkerAssign_INDC = @Lc_No_INDC
        AND ar.EndValidity_DATE = @Ld_High_DATE;

     SET @Ls_Sql_TEXT = '';
     SET @Ls_Sqldata_TEXT = 'Office_IDNO = ' + ISNULL(CAST( @Ln_Office_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', EndValidity_DATE = ' + ISNULL(CAST( @Ld_High_DATE AS VARCHAR ),'');
     
     SELECT @Ln_Usrl_Count_NUMB = COUNT(1)
       FROM USRL_Y1 ur
      WHERE ur.Office_IDNO = @Ln_Office_IDNO
        AND ur.Role_ID = @Ac_Role_ID
        AND ur.Effective_DATE <= @Ad_Run_DATE
        AND ur.Expire_DATE > @Ad_Run_DATE
        AND ur.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Usrl_Count_NUMB = 0
      BEGIN
       SET @Ac_Msg_CODE = 'E1354';
       SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_ALERT_WORKER' + ' PROCEDURE' + '. Error DESC - ' + 'NO WORKER FOR THE GIVEN ROLE AND COUNTY. ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;

       RETURN;
      END;
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   BEGIN
   IF CURSOR_STATUS('Local', 'Role_Cur') IN (0,1)
	BEGIN
		CLOSE Role_Cur;
		DEALLOCATE Role_Cur;
	END   

   IF CURSOR_STATUS('Local', 'Acrl_Cur') IN (0,1)
	BEGIN
		CLOSE Acrl_Cur;
		DEALLOCATE Acrl_Cur;
	END   
   
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    SET @Ln_Error_NUMB = ERROR_NUMBER();
    SET @Ln_ErrorLine_NUMB = ERROR_LINE();
    IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

    EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
     @As_Procedure_NAME        = @Ls_Procedure_NAME,
     @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
     @As_Sql_TEXT              = @Ls_Sql_TEXT,
     @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
     @An_Error_NUMB            = @Ln_Error_NUMB,
     @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
     @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
   END
  END CATCH
 END


GO
