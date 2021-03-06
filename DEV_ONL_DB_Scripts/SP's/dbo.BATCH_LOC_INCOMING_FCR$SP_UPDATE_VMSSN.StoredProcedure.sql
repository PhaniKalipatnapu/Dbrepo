/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN
Programmer Name		 : IMP Team
Description			 : The procedure updates the member SSN and date of birth in DEMO_Y1 table 
Frequency			 : Daily
Developed On		 : 04/07/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_PERSON_ACK_DETAILS
Called On			 : BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
					   BATCH_COMMON$SP_INSERT_ACTIVITY
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------

*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_UPDATE_VMSSN]
 @Ad_Run_DATE              DATE,
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_MemberSsn_NUMB        NUMERIC(9),
 @Ac_TypePrimarySsn_CODE   CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE				CHAR(1) = 'S',
           @Lc_VerificationStatusGood_CODE		CHAR(1) = 'Y',
           @Lc_TypePrimarySsn_CODE				CHAR(1) = 'P',
           @Lc_TypeSecondarySsn_CODE			CHAR(1) = 'S',
           @Lc_TypeTertiarySsn_CODE				CHAR(1) = 'T',
           @Lc_VerificationStatusPending_CODE	CHAR(1) = 'P',
           @Lc_StatusFailed_CODE				CHAR(1) = 'F',
           @Lc_CaseStatusOpen_CODE				CHAR(1) = 'O',
           @Lc_StatusCaseMemberActive_CODE		CHAR(1) = 'A',
           @Lc_VerificationSourceFcr_CODE		CHAR(1) = 'S',
           @Lc_Note_INDC						CHAR(1) = 'N',
           @Lc_SubsystemLoc_CODE				CHAR(3) = 'LO',
           @Lc_MajorActivityCase_CODE			CHAR(4) = 'CASE',
           @Lc_ActivityMinorFcrsn_CODE			CHAR(5) = 'FCRSN',
           @Lc_Job_ID							CHAR(7) = 'DEB0480',
           @Lc_BatchRunUser_TEXT				CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME					VARCHAR(60) = 'SP_UPDATE_VMSSN',
           @Ld_High_DATE						DATE = '12/31/9999';
  DECLARE  @Ln_QNTY								NUMERIC(2) = 0,
           @Ln_MemberSsn0_NUMB					NUMERIC(9) = 0,
           @Ln_Topic_NUMB						NUMERIC(10,0) = 0,
           @Ln_EventFunctionalSeq_NUMB			NUMERIC(10) = 0,
           @Ln_Error_NUMB						NUMERIC(11),
           @Ln_ErrorLine_NUMB					NUMERIC(11),
           @Ln_TransactionEventSeq_NUMB			NUMERIC(19),
           @Li_FetchStatus_QNTY					SMALLINT,
           @Li_RowCount_QNTY					SMALLINT,
           @Lc_Space_TEXT						CHAR(1) = '',
           @Lc_Enumeration_CODE					CHAR(1) = '',
           @Lc_TypeSsn_CODE						CHAR(1) = '',
           @Lc_EnumerationOld_CODE				CHAR(1) = '',
           @Lc_Msg_CODE							CHAR(5) = '',
           @Ls_Sql_TEXT							VARCHAR(100),
           @Ls_Sqldata_TEXT						VARCHAR(1000),
           @Ls_ErrorMessage_TEXT				VARCHAR(4000),
           @Ls_DescriptionError_TEXT			VARCHAR(4000);
  DECLARE @Ln_MemberCaseCur_Case_IDNO			NUMERIC(6);

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'CHECK IF THE MemberSsn_NUMB RECEIVED IS VALID';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR(9)), 0);

   IF @An_MemberSsn_NUMB = @Ln_MemberSsn0_NUMB
       OR LTRIM(RTRIM(@An_MemberSsn_NUMB)) IS NULL
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
     SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;

     RETURN;
    END

   SET @Ls_Sql_TEXT = 'CHECKS THE MemberSsn_NUMB HIERARCHY TO GET MemberSsn_NUMB TYPE';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), 0);

   SELECT @Ln_QNTY = COUNT(1)
     FROM MSSN_Y1 m
    WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
      AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
      AND m.TypePrimary_CODE = @Lc_TypePrimarySsn_CODE
      AND m.EndValidity_DATE = @Ld_High_DATE;

   SET @Lc_Enumeration_CODE = @Lc_VerificationStatusGood_CODE;
   SET @Lc_TypeSsn_CODE = @Lc_TypePrimarySsn_CODE;

   IF @Ln_QNTY > 0
       OR @Ac_TypePrimarySsn_CODE = @Lc_TypeSecondarySsn_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'CHECKS THE MemberSsn_NUMB HIERARCHY TO GET MemberSsn_NUMB FOR SECONDARY SSN';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), 0);
     SELECT @Ln_QNTY = COUNT(1)
       FROM MSSN_Y1 m
      WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
        AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
        AND m.TypePrimary_CODE = @Lc_TypeSecondarySsn_CODE
        AND m.EndValidity_DATE = @Ld_High_DATE;

     SET @Lc_Enumeration_CODE = @Lc_VerificationStatusGood_CODE;
     SET @Lc_TypeSsn_CODE = @Lc_TypeSecondarySsn_CODE;
     
     IF @Ln_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'CHECKS THE MemberSsn_NUMB HIERARCHY TO GET MemberSsn_NUMB FOR TERTIARY SSN';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), 0);
       SELECT @Ln_QNTY = COUNT(1)
         FROM MSSN_Y1 m
        WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
          AND m.Enumeration_CODE = @Lc_VerificationStatusGood_CODE
          AND m.TypePrimary_CODE = @Lc_TypeTertiarySsn_CODE
          AND m.EndValidity_DATE = @Ld_High_DATE;

       SET @Lc_Enumeration_CODE = @Lc_VerificationStatusGood_CODE;
       SET @Lc_TypeSsn_CODE = @Lc_TypeTertiarySsn_CODE;

       IF @Ln_QNTY > 0
        BEGIN
         SET @Lc_Enumeration_CODE = @Lc_VerificationStatusPending_CODE;
         SET @Lc_TypeSsn_CODE = @Ac_TypePrimarySsn_CODE;
        END
      END
    END

   SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberSsn_NUMB';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberSsn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR(9)), 0);

   SELECT TOP 1 @Ln_QNTY = 1,
                @Lc_EnumerationOld_CODE = Enumeration_CODE
     FROM MSSN_Y1 m
    WHERE MemberMci_IDNO = @An_MemberMci_IDNO
      AND MemberSsn_NUMB = @An_MemberSsn_NUMB
      AND EndValidity_DATE = @Ld_High_DATE;

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ln_QNTY = 0;
     SET @Lc_EnumerationOld_CODE = ' ';
    END

   IF ((@Ln_QNTY = 1
        AND (@Lc_EnumerationOld_CODE = @Lc_VerificationStatusPending_CODE
             AND @Lc_Enumeration_CODE = @Lc_VerificationStatusGood_CODE))
        OR @Ln_QNTY = 0)
    BEGIN
     IF @Ln_QNTY = 1
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE MSSN_Y1';
       SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), 0) + ', Ssn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), 0);

       UPDATE MSSN_Y1 
          SET EndValidity_DATE = @Ad_Run_DATE
        WHERE MSSN_Y1.MemberMci_IDNO = @An_MemberMci_IDNO
          AND MSSN_Y1.MemberSsn_NUMB = @An_MemberSsn_NUMB
          AND MSSN_Y1.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_RowCount_QNTY = @@ROWCOUNT;

       IF @Li_RowCount_QNTY = 0
        BEGIN
         
         SET @Ls_ErrorMessage_TEXT = 'UPDATE MSSN_Y1 FAILED.';

         RAISERROR(50001,16,1);
        END
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$BATCH_COMMON$SP_GENERATE_SEQ_TXN_EVENT 4';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Lc_Job_ID, '');

     EXECUTE BATCH_COMMON$SP_GEN_SEQ_TXN_EVENT
      @Ac_Worker_ID                = @Lc_BatchRunUser_TEXT,
      @Ac_Process_ID               = @Lc_Job_ID,
      @Ad_EffectiveEvent_DATE      = @Ad_Run_DATE,
      @Ac_Note_INDC                = @Lc_Note_INDC,
      @An_EventFunctionalSeq_NUMB  = @Ln_EventFunctionalSeq_NUMB,
      @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       
       SET @Ls_ErrorMessage_TEXT = 'SEQ_TXN_EVENT FAILED IN UPDATE_VMSSN';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'INSERT INTO MSSN_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), 0) + ', Ssn_NUMB = ' + ISNULL(CAST(@An_MemberSsn_NUMB AS VARCHAR), 0);

     INSERT MSSN_Y1
            (MemberMci_IDNO,
             MemberSsn_NUMB,
             Enumeration_CODE,
             TypePrimary_CODE,
             SourceVerify_CODE,
             Status_DATE,
             BeginValidity_DATE,
             EndValidity_DATE,
             WorkerUpdate_ID,
             TransactionEventSeq_NUMB,
             Update_DTTM)
     VALUES ( @An_MemberMci_IDNO, -- MemberMci_IDNO
              @An_MemberSsn_NUMB, -- MemberSsn_NUMB
              @Lc_Enumeration_CODE, -- Enumeration_CODE
              @Lc_TypeSsn_CODE, -- TypePrimary_CODE
              @Lc_VerificationSourceFcr_CODE, -- SourceVerify_CODE
              @Ad_Run_DATE, -- Status_DATE
              @Ad_Run_DATE, -- BeginValidity_DATE
              @Ld_High_DATE, -- EndValidity_DATE 
              @Lc_BatchRunUser_TEXT, -- WorkerUpdate_ID
              @Ln_TransactionEventSeq_NUMB, -- TransactionEventSeq_NUMB
              dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()); -- Update_DTTM

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO MSSN_Y1 FAILED.';

       RAISERROR(50001,16,1);
      END

     BEGIN
      DECLARE
      
      MemberCase_CUR INSENSITIVE CURSOR FOR
       SELECT c.Case_IDNO AS Case_IDNO
         FROM CMEM_Y1  m,
              CASE_Y1  c
        WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
          AND m.Case_IDNO = c.Case_IDNO
          AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE
          AND m.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

      OPEN MemberCase_CUR;

      FETCH NEXT FROM MemberCase_CUR INTO @Ln_MemberCaseCur_Case_IDNO;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	  -- Create a case journal entry for each case the member is active 
      WHILE @Li_FetchStatus_QNTY = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY1';
        SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@Ln_MemberCaseCur_Case_IDNO AS VARCHAR), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), 0) + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinorFcrsn_CODE, '');
       
        EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
         @An_Case_IDNO                = @Ln_MemberCaseCur_Case_IDNO,
         @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
         @Ac_ActivityMajor_CODE       = @Lc_MajorActivityCase_CODE,
         @Ac_ActivityMinor_CODE       = @Lc_ActivityMinorFcrsn_CODE,
         @Ac_Subsystem_CODE           = @Lc_SubsystemLoc_CODE,
         @An_TransactionEventSeq_NUMB = @Ln_TransactionEventSeq_NUMB,
         @Ac_WorkerUpdate_ID          = @Lc_BatchRunUser_TEXT,
         @An_Topic_IDNO               = @Ln_Topic_NUMB OUTPUT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
        
        IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
         BEGIN
          
          SET @Ls_ErrorMessage_TEXT = 'INSERT ACTIVITY FAILED.';

          RAISERROR(50001,16,1);
         END

        FETCH NEXT FROM MemberCase_CUR INTO @Ln_MemberCaseCur_Case_IDNO;

        SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
       END

      CLOSE MemberCase_CUR;

      DEALLOCATE MemberCase_CUR;
     END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('local', 'MemberCase_CUR') IN (0, 1)
    BEGIN
     CLOSE MemberCase_CUR;

     DEALLOCATE MemberCase_CUR;
    END

   IF @Lc_Msg_CODE IN (@Lc_StatusFailed_CODE, @Lc_Space_TEXT)
	BEGIN
		SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	END
   ELSE
	BEGIN
		SET @Ac_Msg_CODE = @Lc_Msg_CODE;
	END
      
   --Set Error Description
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
    
    SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
 
  END CATCH
 END


GO
