/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_CASE_ACK_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_CASE_ACK_DETAILS
Programmer Name		 : IMP Team
Description			 : The process reads the FCR CASE Acknowledge details
                       if the matching member is found for the record Updates
                       the FCR Audit(FADT_Y1) and Pending Rejects (FPRJ_Y1) tables 
Frequency			 : Daily
Developed On		 : 04/06/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT
					   BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS
					   BATCH_COMMON$SP_BATE_LOG
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
---------------------------------------------------------------------------------------------------------------------------------------	
Modified By			 : 
Modified On			 :
Version No			 : 1.0
---------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_CASE_ACK_DETAILS]
 @Ac_Job_ID                  CHAR(7),
 @Ad_Run_DATE                DATE,
 @As_Process_NAME            VARCHAR(100),
 @An_CommitFreq_QNTY         NUMERIC(5),
 @An_ExceptionThreshold_QNTY NUMERIC(5),
 @An_ProcessedRecordCount_QNTY NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE                CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_ErrorTypeError_CODE				CHAR(1) = 'E',
           @Lc_StatusNoDataFound_CODE			CHAR(1) = 'N',
           @Lc_StatusFailed_CODE				CHAR(1) = 'F',
           @Lc_ProcessY_INDC					CHAR(1) = 'Y',
           @Lc_ActionAdd_CODE					CHAR(1) = 'A',
           @Lc_ResponseAdd_CODE					CHAR(1) = 'A',
           @Lc_ActionChange_CODE				CHAR(1) = 'C',
           @Lc_ResponseChange_CODE				CHAR(1) = 'C',
           @Lc_ActionDelete_CODE				CHAR(1) = 'D',
           @Lc_ResponseDelete_CODE				CHAR(1) = 'D',
           @Lc_ResponseAddHold_CODE				CHAR(1) = 'P',
           @Lc_ResponseChangeHold_CODE			CHAR(1) = 'H',
           @Lc_ResponseDeleteHold_CODE			CHAR(1) = 'X',
           @Lc_ResponseAddReject_CODE			CHAR(1) = 'R',
           @Lc_ResponseChangeReject_CODE		CHAR(1) = 'E',
           @Lc_ResponseDeleteReject_CODE		CHAR(1) = 'F',
           @Lc_TypeErrorF1_IDNO					CHAR(1) = 'F',
           @Lc_ErrorE0890_CODE					CHAR(5) = 'E0890',
           @Lc_BateErrorE1424_CODE				CHAR(5) = 'E1424',
           @Lc_AcknowledgeAccept_CODE			CHAR(5) = 'AAAAA',
           @Lc_AcknowledgeHold_CODE				CHAR(5) = 'HOLDS',
           @Lc_AcknowledgeReject_CODE			CHAR(5) = 'REJCT',
           @Ls_Process_NAME						VARCHAR(60) = 'BATCH_LOC_INCOMING_FCR',
           @Ls_Procedure_NAME					VARCHAR(60) = 'SP_PROCESS_CASE_ACK_DETAILS',
           @Ld_Low_DATE							DATE = '01/01/0001';
  DECLARE  @Ln_Exists_NUMB						NUMERIC(1) = 0,
           @Ln_CommitFreq_QNTY					NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY			NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY		NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY  NUMERIC(6) = 0,
           @Ln_Zero_NUMB						NUMERIC(10) = 0,
           @Ln_Cur_QNTY							NUMERIC(10,0) = 0,
           @Ln_Error_NUMB						NUMERIC(11),
           @Ln_ErrorLine_NUMB					NUMERIC(11),
           @Li_FetchStatus_QNTY					SMALLINT,
           @Li_RowCount_QNTY					SMALLINT,
           @Lc_ReponseFcr_CODE					CHAR(1) = '',
           @Lc_TypeError_CODE					CHAR(1) = '',
           @Lc_Space_TEXT						CHAR(1) = '',
           @Lc_Msg_CODE							CHAR(5) = '',
           @Lc_BateError_CODE					CHAR(5) = '',
           @Ls_Sql_TEXT							VARCHAR(100),
           @Ls_CursorLoc_TEXT					VARCHAR(200) = '',
           @Ls_Sqldata_TEXT						VARCHAR(1000),
           @Ls_BateRecord_TEXT					VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT				VARCHAR(4000),
           @Ls_DescriptionError_TEXT			VARCHAR(4000) = '';

  DECLARE @Ln_FcrCaseAckCur_Seq_IDNO                 NUMERIC(19),
          @Lc_FcrCaseAckCur_Rec_ID                   CHAR(2),
          @Lc_FcrCaseAckCur_Action_CODE              CHAR(1),
          @Lc_FcrCaseAckCur_CaseIdno_TEXT            CHAR(6),
          @Lc_FcrCaseAckCur_TypeCase_CODE            CHAR(1),
          @Lc_FcrCaseAckCur_Order_INDC               CHAR(1),
          @Lc_FcrCaseAckCur_CountyIdno_TEXT          CHAR(3),
          @Lc_FcrCaseAckCur_CaseUserField_NUMB       CHAR(15),
          @Lc_FcrCaseAckCur_CasePrev_IDNO            CHAR(6),
          @Lc_FcrCaseAckCur_BatchNumb_TEXT           CHAR(6),
          @Lc_FcrCaseAckCur_CaseAcknowledgement_CODE CHAR(5),
          @Lc_FcrCaseAckCur_Error1_CODE              CHAR(5),
          @Lc_FcrCaseAckCur_Error2_CODE              CHAR(5),
          @Lc_FcrCaseAckCur_Error3_CODE              CHAR(5),
          @Lc_FcrCaseAckCur_Error4_CODE              CHAR(5),
          @Lc_FcrCaseAckCur_Error5_CODE              CHAR(5),
          
          @Ln_FcrCaseAckCur_Case_IDNO				 NUMERIC(6),
          @Ln_FcrCaseAckCur_County_IDNO              NUMERIC(3),
          @Ln_FcrCaseAckCur_Batch_NUMB               NUMERIC(6);

  DECLARE FcrCaseAck_CUR INSENSITIVE CURSOR FOR
   SELECT c.Seq_IDNO,
          c.Rec_ID,
          c.Action_CODE,
          ISNULL (LTRIM(RTRIM(c.Case_IDNO)), 0) AS Case_IDNO,
          c.TypeCase_CODE,
          c.Order_INDC,
          ISNULL (LTRIM(RTRIM(c.CountyFips_CODE)), '0') AS CountyFips_CODE,
          LTRIM(RTRIM(c.CaseUserField_NUMB)) AS CaseUserField_NUMB,
          LTRIM(RTRIM(c.CasePrev_IDNO)) AS CasePrev_IDNO,
          ISNULL (LTRIM(RTRIM(c.Batch_NUMB)), '0') AS Batch_NUMB,
          LTRIM(RTRIM(c.CaseAcknowledgement_CODE)) AS CaseAcknowledgement_CODE,
          LTRIM(RTRIM(c.Error1_CODE)) AS Error1_CODE,
          LTRIM(RTRIM(c.Error2_CODE)) AS Error2_CODE,
          LTRIM(RTRIM(c.Error3_CODE)) AS Error3_CODE,
          LTRIM(RTRIM(c.Error4_CODE)) AS Error4_CODE,
          LTRIM(RTRIM(c.Error5_CODE)) AS Error5_CODE
     FROM LFCAD_Y1 c
    WHERE c.Process_INDC = 'N'
    ORDER BY c.Batch_NUMB,
             c.Seq_IDNO;
  
  BEGIN TRY
   BEGIN TRANSACTION CASEACK_DETAILS;
   
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   SET @An_CommitFreq_QNTY = ISNULL (@An_CommitFreq_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL (@An_ExceptionThreshold_QNTY, 0);
   SET @Ln_Cur_QNTY = 0;
   SET @Ln_CommitFreq_QNTY = 0;
   SET @Ln_ExceptionThreshold_QNTY = 0;
   
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'CASE ACK CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');
  
   OPEN FcrCaseAck_CUR;

   FETCH NEXT FROM FcrCaseAck_CUR INTO @Ln_FcrCaseAckCur_Seq_IDNO, @Lc_FcrCaseAckCur_Rec_ID, @Lc_FcrCaseAckCur_Action_CODE, @Lc_FcrCaseAckCur_CaseIdno_TEXT, @Lc_FcrCaseAckCur_TypeCase_CODE, @Lc_FcrCaseAckCur_Order_INDC, @Lc_FcrCaseAckCur_CountyIdno_TEXT, @Lc_FcrCaseAckCur_CaseUserField_NUMB, @Lc_FcrCaseAckCur_CasePrev_IDNO, @Lc_FcrCaseAckCur_BatchNumb_TEXT, @Lc_FcrCaseAckCur_CaseAcknowledgement_CODE, @Lc_FcrCaseAckCur_Error1_CODE, @Lc_FcrCaseAckCur_Error2_CODE, @Lc_FcrCaseAckCur_Error3_CODE, @Lc_FcrCaseAckCur_Error4_CODE, @Lc_FcrCaseAckCur_Error5_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SAVECASEACK_DETAILS;
    
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Lc_TypeError_CODE = '';
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
    
     SET @Ls_CursorLoc_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrCaseAckCur_CaseIdno_TEXT, 0) + ', CaseAcknowledgement_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_CaseAcknowledgement_CODE, '') + ', CURSOR_COUNT = ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(12)), 0);
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF Case_IDNO IN FADT_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrCaseAckCur_CaseIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Action_CODE, '');
     SET @Ln_Exists_NUMB = 0;
     
     --Check Fcr case id number numeric
     IF ISNUMERIC(@Lc_FcrCaseAckCur_CaseIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrCaseAckCur_Case_IDNO = @Lc_FcrCaseAckCur_CaseIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrCaseAckCur_Case_IDNO = @Ln_Zero_NUMB;
		END
	 IF ISNUMERIC(@Lc_FcrCaseAckCur_CountyIdno_TEXT) = 1 
	   BEGIN 
	      SET @Ln_FcrCaseAckCur_County_IDNO = @Lc_FcrCaseAckCur_CountyIdno_TEXT;	
	   END
	 ELSE
	    BEGIN 
			SET @Ln_FcrCaseAckCur_County_IDNO = @Ln_Zero_NUMB;
		END
	 
	 IF ISNUMERIC(@Lc_FcrCaseAckCur_BatchNumb_TEXT) = 1 
	   BEGIN 
		  SET @Ln_FcrCaseAckCur_Batch_NUMB = @Lc_FcrCaseAckCur_BatchNumb_TEXT;
	   END
	 ELSE
		BEGIN 
			SET @Ln_FcrCaseAckCur_Batch_NUMB = @Ln_Zero_NUMB;
		END      
     SET @Ls_BateRecord_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrCaseAckCur_CaseIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Action_CODE, '') + ', CaseAcknowledgement_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_CaseAcknowledgement_CODE, '') + ', Error1_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error1_CODE, '') + ', Error2_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error2_CODE, '') + ', Error3_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error3_CODE, '') + ', Error4_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error4_CODE, '') + ', Error5_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error5_CODE, '');
    			
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM FADT_Y1 f
      WHERE f.Case_IDNO = @Ln_FcrCaseAckCur_Case_IDNO
        AND f.MemberMci_IDNO = @Ln_Zero_NUMB;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT_T1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrCaseAckCur_CaseIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Action_CODE, '');

       EXECUTE BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT
        @An_Case_IDNO             = @Ln_FcrCaseAckCur_Case_IDNO,
        @An_MemberMci_IDNO        = @Ln_Zero_NUMB,
        @Ac_Action_CODE           = @Lc_FcrCaseAckCur_Action_CODE,
        @Ac_TypeTrans_CODE        = @Lc_FcrCaseAckCur_Rec_ID,
        @Ac_TypeCase_CODE         = @Lc_FcrCaseAckCur_TypeCase_CODE,
        @An_County_IDNO           = @Ln_FcrCaseAckCur_County_IDNO,
        @Ac_Order_INDC            = @Lc_FcrCaseAckCur_Order_INDC,
        @An_MemberSsn_NUMB        = @Ln_Zero_Numb, 
        @Ad_Birth_DATE            = @Ld_Low_DATE,
        @Ac_Last_NAME             = @Lc_Space_TEXT,
        @Ac_First_NAME            = @Lc_Space_TEXT,
        @An_Batch_NUMB            = @Ln_FcrCaseAckCur_Batch_NUMB,
        @Ac_TypeParticipant_CODE  = @Lc_Space_TEXT,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusNoDataFound_CODE
        BEGIN
         SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
         SET @Lc_BateError_CODE = @Lc_ErrorE0890_CODE;

         -- Add record to the BATE_Y1 table and continue the process
         GOTO lx_exception;
        END
       ELSE
        BEGIN
         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           
           SET @Ls_ErrorMessage_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT1 FAILED ';

           RAISERROR(50001,16,1);
          END
        END
      END
     
     -- Check acknowledgement code and set the flag
     IF @Lc_FcrCaseAckCur_CaseAcknowledgement_CODE = @Lc_AcknowledgeAccept_CODE
      BEGIN
       -- Case change accepted 
       IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionAdd_CODE
        BEGIN
         SET @Lc_ReponseFcr_CODE = @Lc_ResponseAdd_CODE;
        END
       ELSE
        BEGIN
         IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionChange_CODE
          BEGIN
           SET @Lc_ReponseFcr_CODE = @Lc_ResponseChange_CODE;
          END
         ELSE
          BEGIN
           IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionDelete_CODE
            BEGIN
             SET @Lc_ReponseFcr_CODE = @Lc_ResponseDelete_CODE;
            END
          END
        END
      END
     ELSE
      BEGIN
       -- Case change on hold 	 
       IF @Lc_FcrCaseAckCur_CaseAcknowledgement_CODE = @Lc_AcknowledgeHold_CODE
        BEGIN
         IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionAdd_CODE
          BEGIN
           SET @Lc_ReponseFcr_CODE = @Lc_ResponseAddHold_CODE;
          END
         ELSE
          BEGIN
           IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionChange_CODE
            BEGIN
             SET @Lc_ReponseFcr_CODE = @Lc_ResponseChangeHold_CODE;
            END
           ELSE
            BEGIN
             IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionDelete_CODE
              BEGIN
               SET @Lc_ReponseFcr_CODE = @Lc_ResponseDeleteHold_CODE;
              END
            END
          END
        END
       ELSE
        -- Case change rejected 
        BEGIN
         IF @Lc_FcrCaseAckCur_CaseAcknowledgement_CODE = @Lc_AcknowledgeReject_CODE
          BEGIN
           IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionAdd_CODE
            BEGIN
             SET @Lc_ReponseFcr_CODE = @Lc_ResponseAddReject_CODE;
            END
           ELSE
            BEGIN
             IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionChange_CODE
              BEGIN
               SET @Lc_ReponseFcr_CODE = @Lc_ResponseChangeReject_CODE;
              END
             ELSE
              BEGIN
               IF @Lc_FcrCaseAckCur_Action_CODE = @Lc_ActionDelete_CODE
                BEGIN
                 SET @Lc_ReponseFcr_CODE = @Lc_ResponseDeleteReject_CODE;
                END
              END
            END

           SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS1';
           SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrCaseAckCur_CaseIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Action_CODE, '') + ', Error1_CODE = ' + ISNULL (@Lc_FcrCaseAckCur_Error1_CODE, '');

           EXECUTE BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS
            @Ad_Run_DATE              = @Ad_Run_DATE,
            @An_Case_IDNO             = @Ln_FcrCaseAckCur_Case_IDNO,
            @An_MemberMci_IDNO        = @Ln_Zero_NUMB,
            @Ac_Action_CODE           = @Lc_FcrCaseAckCur_Action_CODE,
            @Ac_Error1_CODE           = @Lc_FcrCaseAckCur_Error1_CODE,
            @Ac_Error2_CODE           = @Lc_FcrCaseAckCur_Error2_CODE,
            @Ac_Error3_CODE           = @Lc_FcrCaseAckCur_Error3_CODE,
            @Ac_Error4_CODE           = @Lc_FcrCaseAckCur_Error4_CODE,
            @Ac_Error5_CODE           = @Lc_FcrCaseAckCur_Error5_CODE,
            @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
           
           IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             SET @Ls_ErrorMessage_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS1 FAILED.';

             RAISERROR(50001,16,1);
            END
          END
        END
      END

     SET @Ls_Sql_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrCaseAckCur_CaseIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Action_CODE, '') + ', ResponseFcr_CODE = ' + ISNULL(@Lc_ReponseFcr_CODE, '');

     EXECUTE BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @An_Case_IDNO             = @Ln_FcrCaseAckCur_Case_IDNO,
      @An_MemberMci_IDNO        = @Ln_Zero_NUMB,
      @Ac_Response_CODE         = @Lc_ReponseFcr_CODE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
     
     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'BATCH_LOC_INCOMING_FCR$SP_UPDATE_ACK_DETAILS1 FAILED';

       RAISERROR(50001,16,1);
      END

     IF @Lc_FcrCaseAckCur_CaseAcknowledgement_CODE = @Lc_AcknowledgeReject_CODE
      BEGIN
       SET @Lc_TypeError_CODE = @Lc_TypeErrorF1_IDNO;
       SET @Lc_BateError_CODE = ISNULL(@Lc_FcrCaseAckCur_Error1_CODE, @Lc_FcrCaseAckCur_Error2_CODE);

       GOTO lx_exception;
      END

     LX_EXCEPTION:;

     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
      
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3 IN CASE ACK';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(@Lc_FcrCaseAckCur_CaseIdno_TEXT, 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Action_CODE, '') + ', CaseAcknowledgement_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_CaseAcknowledgement_CODE, '') + ', Error1_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error1_CODE, '') + ', Error2_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error2_CODE, '') + ', Error3_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error3_CODE, '') + ', Error4_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error4_CODE, '') + ', Error5_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error5_CODE, '');
       
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @Ls_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
       
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO BATE 1 FAILED';

         RAISERROR(50001,16,1);
        END
       
       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END 
       
      END;
     END TRY
     
     BEGIN CATCH
	  BEGIN 
		SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
		-- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	     BEGIN
	   	   ROLLBACK TRANSACTION SAVECASEACK_DETAILS;
		 END
		ELSE
		 BEGIN
		    SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + '' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
		 END 
		        
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
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
        SET @Ls_Sqldata_TEXT =  'Case_IDNO = ' + ISNULL(CAST(@Ln_FcrCaseAckCur_Case_IDNO AS VARCHAR), 0) + ', Action_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Action_CODE, '') + ', Acknowledge_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_CaseAcknowledgement_CODE, '') + ', Error1_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error1_CODE, '') + ', Error2_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error2_CODE, '') + ', Error3_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error3_CODE, '') + ', Error4_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error4_CODE, '') + ', Error5_CODE = ' + ISNULL(@Lc_FcrCaseAckCur_Error5_CODE, '');

        SET @Ls_BateRecord_TEXT = @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @As_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Ac_Job_ID,
         @Ad_Run_DATE                 = @Ad_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
         @An_Line_NUMB                = @Ln_Cur_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
         @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
        
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END
      END
	END CATCH
	
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;
     SET @Ls_Sql_TEXT = 'UPDATE LOAD_CASE_ACK_DETAILS';
      SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL (CAST(@Ln_FcrCaseAckCur_Seq_IDNO AS VARCHAR), '');

     --Update the process indicator 

     UPDATE LFCAD_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrCaseAckCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FAILED LFCAD_Y1';

       RAISERROR(50001,16,1);
      END
     
     -- Check for the commit frequency 
     SET @Ls_Sql_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL (@Ac_Job_ID, '');
     
     IF @An_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @An_CommitFreq_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Ac_Job_ID,
        @Ad_Run_DATE              = @Ad_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cur_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE FAILED';

         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION CASEACK_DETAILS; 

       BEGIN TRANSACTION CASEACK_DETAILS; 

       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION CASEACK_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');
      
       RAISERROR(50001,16,1);
      END

     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1;
     FETCH NEXT FROM FcrCaseAck_CUR INTO @Ln_FcrCaseAckCur_Seq_IDNO, @Lc_FcrCaseAckCur_Rec_ID, @Lc_FcrCaseAckCur_Action_CODE, @Lc_FcrCaseAckCur_CaseIdno_TEXT, @Lc_FcrCaseAckCur_TypeCase_CODE, @Lc_FcrCaseAckCur_Order_INDC, @Lc_FcrCaseAckCur_CountyIdno_TEXT, @Lc_FcrCaseAckCur_CaseUserField_NUMB, @Lc_FcrCaseAckCur_CasePrev_IDNO, @Lc_FcrCaseAckCur_BatchNumb_TEXT, @Lc_FcrCaseAckCur_CaseAcknowledgement_CODE, @Lc_FcrCaseAckCur_Error1_CODE, @Lc_FcrCaseAckCur_Error2_CODE, @Lc_FcrCaseAckCur_Error3_CODE, @Lc_FcrCaseAckCur_Error4_CODE, @Lc_FcrCaseAckCur_Error5_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END
   
   CLOSE FcrCaseAck_CUR;

   DEALLOCATE FcrCaseAck_CUR;

   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
      
   COMMIT TRANSACTION CASEACK_DETAILS;
  END TRY

  BEGIN CATCH
   
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;
   
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', 'FcrCaseAck_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrCaseAck_CUR;

     DEALLOCATE FcrCaseAck_CUR;
    END

   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION CASEACK_DETAILS;
    END

   -- --Set Error Description
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
