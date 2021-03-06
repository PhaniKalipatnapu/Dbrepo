/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER
 Programmer Name	: IMP Team
 Description		: This procedure is used to update New Worker in all the appropriate tables while transfering the case to new worker 
					  or assigning a worker to a case for the given role for the first time				  
 Frequency			:
 Developed On		: 04/12/2011
 Called By			:
 Called On			:
------------------------------------------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No			: 0.1
------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER] (
 @An_Case_IDNO                NUMERIC(6),
 @An_Office_IDNO              NUMERIC(3),
 @An_OfficeTo_IDNO            NUMERIC(3),
 @Ac_Role_ID                  CHAR(5),
 @Ac_RoleTo_ID                CHAR(5),
 @Ac_Current_Worker_ID        CHAR(30)		= ' ',
 @Ac_Assigned_Worker_ID       CHAR(30)		= ' ',
 @Ac_CsenetReason_CODE        CHAR(5)		= ' ',
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_MinorIntSeq_NUMB         NUMERIC(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ad_Run_DATE                 DATE,
 @Ac_Job_ID                   CHAR(7),
 @Ac_SignedOnWorker_ID        CHAR(30),
 @Ac_InformOldWorker_INDC     CHAR(1),
 @As_DescriptionNote_TEXT     VARCHAR(4000) = ' ',
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE					CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
          @Lc_IcrtrMinorActivityInserted_INDC	CHAR(1)			= 'N',
          @Lc_RespondInitInstate_CODE			CHAR(1)			= 'N',
          @Lc_StatusCaseOpen_CODE				CHAR(1)			= 'O',
          @Lc_Yes_INDC							CHAR(1)			= 'Y',
          @Lc_No_INDC							CHAR(1)			= 'N',
          @Lc_SubsystemCM_CODE					CHAR(2)			= 'CM',
          @Lc_SubsystemIN_CODE					CHAR(2)			= 'IN',
          @Lc_JobRstr_ID						CHAR(4)			= 'RSTR',
          @Lc_ActivityMajorCase_CODE			CHAR(4)			= 'CASE',
          @Lc_ActivityMinorOLWRK_CODE			CHAR(5)			= 'OLWRK',
          @Lc_ActivityMinorICRTR_CODE			CHAR(5)			= 'ICRTR',
          @Lc_ActivityMinorNEWRK_CODE			CHAR(5)			= 'NEWRK',
          @Lc_ErrorE0058_CODE					CHAR(5)			= 'E0058',
          @Ls_Routine_TEXT						VARCHAR(60)		= 'BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER';
  DECLARE @Ln_Office_IDNO						NUMERIC(3),
          @Ln_InterstateCount_NUMB				NUMERIC(3),
          @Ln_Topic_IDNO						NUMERIC(10),
          @Ln_Error_NUMB						NUMERIC(11),
          @Ln_ErrorLine_NUMB					NUMERIC(11),
          @Lc_ResponInit_CODE					CHAR(1),
          @Lc_PrimaryRole_INDC					CHAR(1),
          @Lc_File_ID							CHAR(10),
          @Ls_Sql_TEXT							VARCHAR(100),
          @Ls_Sqldata_TEXT						VARCHAR(1000),
          @Ls_ErrorMessage_TEXT					VARCHAR(4000)	= '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   
   /* 13736 -  CASE REASSIGNMENT - CR0438 Revise Case Journal Entries 20141120 - START */
		SET @As_DescriptionNote_TEXT = 'The worker was changed from '+ ISNULL(LTRIM(@Ac_Current_Worker_ID),'')+' to '+ ISNULL(LTRIM(@Ac_Assigned_Worker_ID),'') +'. '+ISNULL(@As_DescriptionNote_TEXT,'');
   /* 13736 -  CASE REASSIGNMENT - CR0438 Revise Case Journal Entries 20141120 - END */
   
   SET @Lc_PrimaryRole_INDC = CASE WHEN EXISTS ( SELECT 1
													FROM #PrimaryRole_P1
												   WHERE Role_ID = @Ac_RoleTo_ID )
								   THEN @Lc_Yes_INDC
								   ELSE	@Lc_No_INDC
							  END;
   -- Ac_Worker_ID will be either as Input or Case Worker(CASE_Y1)/Role Worker(CWRK_Y1) will be assigned to the variable
   IF @Ac_Assigned_Worker_ID != ''
      AND @Ac_Assigned_Worker_ID IS NOT NULL
    BEGIN
     /* When a case is transferred to a different worker within the same county or another county, either in batch or manually
        via the ASMT screen , alert should be generated to old worker */
     IF (@Lc_PrimaryRole_INDC = @Lc_Yes_INDC
	     AND ( @Ac_Job_ID != @Lc_JobRstr_ID
				OR (@Ac_Job_ID = @Lc_JobRstr_ID
						AND @Ac_Current_Worker_ID != @Ac_Assigned_Worker_ID
					)
			 )
		)
      BEGIN
       IF @Ac_InformOldWorker_INDC = @Lc_Yes_INDC
          AND (@Ac_Current_Worker_ID != ''
               AND @Ac_Current_Worker_ID IS NOT NULL)
        BEGIN
         SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL('0','')+ ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorOLWRK_CODE,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCM_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerDelegate_ID = ' + ISNULL(@Ac_Current_Worker_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');

         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @An_Case_IDNO,
          @An_MemberMci_IDNO           = 0,
          @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorOLWRK_CODE,
          @Ac_Subsystem_CODE           = @Lc_SubsystemCM_CODE,
          @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
          @Ac_WorkerDelegate_ID        = @Ac_Current_Worker_ID,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
          /* 13736 -  CASE REASSIGNMENT - CR0438 Revise Case Journal Entries 20141120 - START */
          @As_DescriptionNote_TEXT     = @As_DescriptionNote_TEXT,
          /* 13736 -  CASE REASSIGNMENT - CR0438 Revise Case Journal Entries 20141120 - END */
          @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
          @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END
        END
      END

     IF @Ac_RoleTo_ID != ''
        AND @Ac_RoleTo_ID IS NOT NULL
      BEGIN
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_INSERT_CWRK_WORKER_ID';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Worker_ID = ' + ISNULL(@Ac_Assigned_Worker_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_Office_IDNO AS VARCHAR ),'')+ ', OfficeTo_IDNO = ' + ISNULL(CAST( @An_OfficeTo_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', RoleTo_ID = ' + ISNULL(@Ac_RoleTo_ID,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', SignedonWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', Job_ID = ' + ISNULL(@Ac_Job_ID,'');

       EXECUTE BATCH_COMMON$SP_INSERT_CWRK_WORKER_ID
        @An_Case_IDNO                = @An_Case_IDNO,
        @Ac_Worker_ID                = @Ac_Assigned_Worker_ID,
        @An_Office_IDNO              = @An_Office_IDNO,
        @An_OfficeTo_IDNO            = @An_OfficeTo_IDNO,
        @Ac_Role_ID                  = @Ac_Role_ID,
        @Ac_RoleTo_ID                = @Ac_RoleTo_ID,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_SignedonWorker_ID        = @Ac_SignedOnWorker_ID,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END

     IF ((@Ac_Job_ID != @Lc_JobRstr_ID)
          OR (@Ac_Job_ID = @Lc_JobRstr_ID
              AND @Ac_Current_Worker_ID != @Ac_Assigned_Worker_ID))
      BEGIN
      /* (Check Open Activities in DMNR and DelegateWorker_ID != @Lc_Assigned_Worker_ID and Alert has not been assigned by himself 
      	to him from WRKL screen and change the DelegateWorker_ID with Lc_Assigned_Worker_ID */
       -- Update DelegateWorker_ID in DMNR_Y1
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_BULKUPDATE_DMNR_DELEGATEWORKER_ID';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Role_ID = ' + ISNULL(@Ac_Role_ID,'')+ ', AssignedWorker_ID = ' + ISNULL(@Ac_Assigned_Worker_ID,'')+ ', MajorIntSeq_NUMB = ' + ISNULL(CAST( @An_MajorIntSeq_NUMB AS VARCHAR ),'')+ ', MinorIntSeq_NUMB = ' + ISNULL(CAST( @An_MinorIntSeq_NUMB AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', SignedOnWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'');

       EXECUTE BATCH_COMMON$SP_BULKUPDATE_DMNR_DELEGATEWORKER_ID
        @An_Case_IDNO                = @An_Case_IDNO,
        @Ac_Role_ID                  = @Ac_Role_ID,
        @Ac_AssignedWorker_ID        = @Ac_Assigned_Worker_ID,
        @An_MajorIntSeq_NUMB         = @An_MajorIntSeq_NUMB,
        @An_MinorIntSeq_NUMB         = @An_MinorIntSeq_NUMB,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

       IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END

       IF @Ac_CsenetReason_CODE != ''
          AND @Ac_CsenetReason_CODE IS NOT NULL
        BEGIN
         -- If Interstate Case Inform other state regarding worker and/or office changed
         SET @Ls_Sql_TEXT = 'ASSINGNING INTERSTATE COUNT NUMBER';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', StatusCase_CODE = ' + ISNULL(@Lc_StatusCaseOpen_CODE,'');
         
         SELECT @Ln_InterstateCount_NUMB = COUNT(1)
           FROM CASE_Y1 c
          WHERE c.Case_IDNO = @An_Case_IDNO
            AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
            AND c.RespondInit_CODE != @Lc_RespondInitInstate_CODE;

         IF @Ln_InterstateCount_NUMB > 0
          BEGIN
           SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_BULKINSERT_PENDING_REQUEST';
           SET @Ls_Sqldata_TEXT = '  Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', Reason_CODE = ' + @Ac_CsenetReason_CODE + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS VARCHAR) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Job_ID = ' + @Ac_Job_ID + ', SignedonWorker_ID = ' + @Ac_SignedOnWorker_ID;

           EXECUTE BATCH_COMMON$SP_BULKINSERT_PENDING_REQUEST
            @An_Case_IDNO                = @An_Case_IDNO,
            @Ac_Reason_CODE              = @Ac_CsenetReason_CODE,
            @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_Job_ID                   = @Ac_Job_ID,
            @Ac_SignedOnWorker_ID        = @Ac_SignedOnWorker_ID,
            @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

           IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END
          END
        END

       -- If Primary Role Change the Worker_ID in CASE_Y1
       IF (@Lc_PrimaryRole_INDC = @Lc_Yes_INDC)
        BEGIN
         SET @Ls_Sql_TEXT = 'ASSING OFFICE IDNO, FILE ID AND Respon Init CODE';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'');
         
         SELECT @Ln_Office_IDNO = c.Office_IDNO,
                @Lc_File_ID = c.File_ID,
                @Lc_ResponInit_CODE = c.RespondInit_CODE
           FROM CASE_Y1 c
          WHERE c.Case_IDNO = @An_Case_IDNO;

         IF @Lc_ResponInit_CODE != @Lc_RespondInitInstate_CODE
            AND @Ln_Office_IDNO = 99
            AND @An_Office_IDNO != 99
            AND @Lc_File_ID = ''
            AND @Ac_Assigned_Worker_ID != ''
            AND @Ac_Assigned_Worker_ID IS NOT NULL
          BEGIN
           SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL('0','')+ ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorICRTR_CODE,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemIN_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerDelegate_ID = ' + ISNULL(@Ac_Assigned_Worker_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'');

           EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
            @An_Case_IDNO                = @An_Case_IDNO,
            @An_MemberMci_IDNO           = 0,
            @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
            @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorICRTR_CODE,
            @Ac_Subsystem_CODE           = @Lc_SubsystemIN_CODE,
            @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
            @Ac_WorkerDelegate_ID        = @Ac_Assigned_Worker_ID,
            @Ad_Run_DATE                 = @Ad_Run_DATE,
            @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
            @As_DescriptionNote_TEXT     = @As_DescriptionNote_TEXT,
            @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
            @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

           IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
            BEGIN
             RAISERROR(50001,16,1);
            END

           SET @Lc_IcrtrMinorActivityInserted_INDC = @Lc_Yes_INDC;
          END

         SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Assigned_Worker_ID = ' + ISNULL(@Ac_Assigned_Worker_ID,'')+ ', Office_IDNO = ' + ISNULL(CAST( @An_OfficeTo_IDNO AS VARCHAR ),'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', SignedonWorker_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'');

         EXECUTE BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID
          @An_Case_IDNO                = @An_Case_IDNO,
          @Ac_Assigned_Worker_ID       = @Ac_Assigned_Worker_ID,
          @An_Office_IDNO              = @An_OfficeTo_IDNO,
          @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_SignedonWorker_ID        = @Ac_SignedOnWorker_ID,
          @As_DescriptionNote_TEXT     = @As_DescriptionNote_TEXT,
          @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END
        END

       IF (@Lc_PrimaryRole_INDC = @Lc_Yes_INDC
		  AND @Ac_InformOldWorker_INDC = @Lc_Yes_INDC
          AND @Lc_IcrtrMinorActivityInserted_INDC = @Lc_No_INDC)
        BEGIN
         /* When a case is transferred to a different worker within the same county or another county, either in batch or manually
          via the ASMT screen , alert should be generated to new worker */
         SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_UPDATE_CASE_WORKER_ID';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', MemberMci_IDNO = ' + ISNULL('0','')+ ', ActivityMajor_CODE = ' + ISNULL(@Lc_ActivityMajorCase_CODE,'')+ ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorNEWRK_CODE,'')+ ', Subsystem_CODE = ' + ISNULL(@Lc_SubsystemCM_CODE,'')+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST( @An_TransactionEventSeq_NUMB AS VARCHAR ),'')+ ', WorkerDelegate_ID = ' + ISNULL(@Ac_Assigned_Worker_ID,'')+ ', Run_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', WorkerUpdate_ID = ' + ISNULL(@Ac_SignedOnWorker_ID,'')+ ', DescriptionNote_TEXT = ' + ISNULL(@As_DescriptionNote_TEXT,'');

         EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
          @An_Case_IDNO                = @An_Case_IDNO,
          @An_MemberMci_IDNO           = 0,
          @Ac_ActivityMajor_CODE       = @Lc_ActivityMajorCase_CODE,
          @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorNEWRK_CODE,
          @Ac_Subsystem_CODE           = @Lc_SubsystemCM_CODE,
          @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
          @Ac_WorkerDelegate_ID        = @Ac_Assigned_Worker_ID,
          @Ad_Run_DATE                 = @Ad_Run_DATE,
          @Ac_WorkerUpdate_ID          = @Ac_SignedOnWorker_ID,
          @As_DescriptionNote_TEXT     = @As_DescriptionNote_TEXT,
          @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
          @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_ErrorMessage_TEXT OUTPUT;

         IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
          BEGIN
           RAISERROR(50001,16,1);
          END
        END
      END
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_ErrorE0058_CODE;
     SET @As_DescriptionError_TEXT = 'Error IN ' + 'BATCH_COMMON$SP_PROCESS_WORKER_TRANSFER' + ' PROCEDURE ' + '. Error DESC - ' + 'Worker_ID IS EMPTY OR NULL.';

     RETURN;
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

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
