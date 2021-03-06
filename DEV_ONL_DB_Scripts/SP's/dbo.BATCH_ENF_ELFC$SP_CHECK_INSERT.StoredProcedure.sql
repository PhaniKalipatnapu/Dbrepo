/****** Object:  StoredProcedure [dbo].[BATCH_ENF_ELFC$SP_CHECK_INSERT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_ENF_ELFC$SP_CHECK_INSERT
Programmer Name		: IMP Team
Description			: This procedure make calls to sf_check_eligibility, sp_insert_activity and sp_initiate_remedy.
Frequency			: 
Developed On		: 04/06/2011
Called BY			: BATCH_ENF_ELFC$SP_PROCESS_ELFC
Called On	        : BATCH_COMMON$SP_INSERT_ACTIVITY and BATCH_ENF_ELFC$SP_INITIATE_REMEDY
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_ELFC$SP_CHECK_INSERT]
 @Ac_TypeChange_CODE          CHAR(2),
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC(10),
 @Ac_TypeOthpSource_CODE      CHAR(1),
 @An_OthpSource_IDNO          NUMERIC(10),
 @Ac_TypeReference_CODE       CHAR(4),
 @Ac_Reference_ID             CHAR(30),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Worker_ID                CHAR(30),
 @Ad_Run_DATE                 DATE,
 @Ac_InProcess_ID             CHAR(10),
 @Ac_Process_ID               CHAR(10),
 @Ac_Msg_CODE                 CHAR(5)		OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(MAX)	OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Yes_INDC							CHAR(1)			= 'Y',
          @Lc_Space_TEXT						CHAR(1)			= ' ',
          @Lc_No_INDC							CHAR(1)			= 'N',
          @Lc_StatusSuccess_CODE				CHAR(1)			= 'S',
          @Lc_StatusFailed_CODE					CHAR(1)			= 'F',          
          @Lc_TypeChangeIr_CODE					CHAR(2)			= 'IR',
          @Lc_TypeChangeDl_CODE					CHAR(2)			= 'DL',
          @Lc_TypeChangeMm_CODE					CHAR(2)			= 'MM',          
		  @Lc_TypeChangeSm_CODE					CHAR(2)			= 'SM',
		  @Lc_TypeChangeTm_CODE					CHAR(2)			= 'TM',
		  @Lc_TypeChangeYe_CODE					CHAR(2)			= 'YE',  
		  @Lc_TypeChangeLo_CODE					CHAR(2)			= 'LO',
          @Lc_TypeChangeIl_CODE					CHAR(2)			= 'IL',
          @Lc_SubsystemEnforcement_CODE			CHAR(2)			= 'EN',
          @Lc_SubsystemCaseManagement_CODE		CHAR(2)			= 'CM',
          @Lc_SubsystemLocate_CODE				CHAR(2)			= 'LO',
          @Lc_ActivityMajorCsln_CODE			CHAR(4)			= 'CSLN',
          @Lc_ActivityMajorFidm_CODE			CHAR(4)			= 'FIDM',
          @Lc_ActivityMajorImiw_CODE			CHAR(4)			= 'IMIW',
          @Lc_ActivityMajorLien_CODE			CHAR(4)			= 'LIEN',
          @Lc_ActivityMajorCase_CODE			CHAR(4)			= 'CASE',
          @Lc_ActivityMajorCclo_CODE			CHAR(4)			= 'CCLO',
          @Lc_ActivityMinorLocaa_CODE			CHAR(5)			= 'LOCAA',
          @Lc_ActivityMinorIrsci_CODE			CHAR(5)			= 'IRSCI',
          @Lc_MsgI0116_CODE						CHAR(5)			= 'I0116',
          @Lc_MsgE1199_CODE						CHAR(5)			= 'E1199',          
          @Lc_JobElfcDaily_ID					CHAR(7)			= 'DEB0660',
          @Lc_JobElfcWeekly_ID					CHAR(7)			= 'DEB5410',
          @Lc_JobElfcMonthly_ID					CHAR(7)			= 'DEB7600',
          @Lc_Notice_ID							CHAR(8)			= '',
          @Lc_BatchRunUser_TEXT					CHAR(30)		= 'BATCH',
          @Ls_Routine_TEXT						VARCHAR(75)		= 'BATCH_ENF_ELFC$SP_CHECK_INSERT',
          @Ld_Highdate_DATE						DATE			= '12/31/9999';
  DECLARE @Ln_OrderSeq_NUMB						NUMERIC(2),
          @Ln_Topic_IDNO						NUMERIC(10),
          @Ln_Error_NUMB						NUMERIC(10)		= 0,
          @Ln_ErrorLine_NUMB					NUMERIC(10)		= 0,
          @Lc_RemedyEligible_INDC				CHAR(1),
          @Lc_Stop_INDC							CHAR(1),
          @Lc_Subsystem_CODE					CHAR(2),
          @Lc_ActivityMinor_CODE				CHAR(5),
          @Ls_Sql_TEXT							VARCHAR(100),
          @Ls_Sqldata_TEXT						VARCHAR(1000);

  BEGIN TRY
    
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;

   IF @Ac_ActivityMajor_CODE != @Lc_ActivityMajorCase_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'ELFC062 : GET Subsystem_CODE AND Stop_INDC FROM AMJR_Y1';
     SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '');

     SELECT @Lc_Subsystem_CODE = j.Subsystem_CODE,
            @Lc_Stop_INDC = j.Stop_INDC
       FROM AMJR_Y1 j
      WHERE j.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
        AND j.EndValidity_DATE = @Ld_Highdate_DATE;

     IF @Lc_Stop_INDC = @Lc_Yes_INDC
      BEGIN
       SET @Ac_Msg_CODE = @Lc_MsgE1199_CODE;
       SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'IND STOP IS YES ON ACTV, SO THE REMEDY SHOULD NOT BE INITIATED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
       RETURN;
      END
    END

   -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Starts
   IF (@Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorCsln_CODE, @Lc_ActivityMajorFidm_CODE, @Lc_ActivityMajorImiw_CODE,@Lc_ActivityMajorLien_CODE )
		AND @Ac_InProcess_ID NOT IN (@Lc_JobElfcWeekly_ID, @Lc_JobElfcDaily_ID, @Lc_JobElfcMonthly_ID))
   -- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Ends
    BEGIN
     SET @Ls_Sql_TEXT = 'ELFC061 : BATCH_ENF_ELFC$SF_CHECK_ELIGIBILITY';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', Order_SEQ = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS CHAR(1)), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_OthpSource_IDNO AS CHAR(10)), '') + ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '') + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS CHAR(10));
     SET @Lc_RemedyEligible_INDC = dbo.BATCH_ENF_ELFC$SF_CHECK_ELIGIBILITY(@An_Case_IDNO, @An_OrderSeq_NUMB, @An_MemberMci_IDNO, @An_OthpSource_IDNO, @Ac_ActivityMajor_CODE, @Ad_Run_DATE, @Ac_Reference_ID);

     IF @Lc_RemedyEligible_INDC = @Lc_No_INDC
      BEGIN
       SET @Ac_Msg_CODE = @Lc_MsgI0116_CODE;
       SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT + @Lc_Space_TEXT + 'CASE IS NOT ELIGIBLE TO BE INITIATED' + @Lc_Space_TEXT + ISNULL (@Ls_Sqldata_TEXT, '');
       RETURN;
      END
    END
   ELSE
    SET @Lc_RemedyEligible_INDC = @Lc_Yes_INDC;

   IF @Lc_RemedyEligible_INDC = @Lc_Yes_INDC
    BEGIN
     IF @Ac_TypeChange_CODE IN (@Lc_TypeChangeIr_CODE,@Lc_TypeChangeDl_CODE,@Lc_TypeChangeSm_CODE,@Lc_TypeChangeTm_CODE,@Lc_TypeChangeYe_CODE,@Lc_TypeChangeIl_CODE,@Lc_TypeChangeMm_CODE, @Lc_TypeChangeLo_CODE)
      BEGIN
		IF @Ac_TypeChange_CODE = @Lc_TypeChangeIr_CODE
			BEGIN
				SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorIrsci_CODE;
				SET @Lc_Subsystem_CODE = @Lc_SubsystemEnforcement_CODE;
			END
		ELSE IF @Ac_TypeChange_CODE = @Lc_TypeChangeLo_CODE
			BEGIN
				SET @Lc_ActivityMinor_CODE = @Lc_ActivityMinorLocaa_CODE;
				SET @Lc_Subsystem_CODE = @Lc_SubsystemLocate_CODE;
			END
		ELSE IF @Ac_TypeChange_CODE IN (@Lc_TypeChangeDl_CODE,@Lc_TypeChangeSm_CODE,@Lc_TypeChangeTm_CODE,@Lc_TypeChangeYe_CODE,@Lc_TypeChangeIl_CODE,@Lc_TypeChangeMm_CODE)
			BEGIN	
				SET @Lc_Subsystem_CODE = @Lc_SubsystemEnforcement_CODE;
				SET @Lc_ActivityMinor_CODE = SUBSTRING(@Ac_Reference_ID,0,CHARINDEX('~',@Ac_Reference_ID));
				SET @Lc_Notice_ID = RTRIM(LTRIM(SUBSTRING(@Ac_Reference_ID,CHARINDEX('~',@Ac_Reference_ID) + 1,LEN(@Ac_Reference_ID))));
				IF @Ac_TypeChange_CODE = @Lc_TypeChangeMm_CODE
				   SET @Ac_Reference_ID = CAST(@An_MemberMci_IDNO AS VARCHAR)
				ELSE
					SET @Ac_Reference_ID = @Lc_Space_TEXT;
			END 

       SET @Ls_Sql_TEXT = 'ELFC063 : BATCH_COMMON$SP_INSERT_ACTIVITY';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '') + ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '') + ', ActivityMinor_CODE = ' + ISNULL(@Lc_ActivityMinor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS CHAR(19)), '') + ', WorkerUpdate_IDNO = ' + @Lc_BatchRunUser_TEXT + ', TypeReference_CODE = ' + ISNULL(@Ac_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Ac_Reference_ID, '') + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS CHAR(10));

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO               = @An_Case_IDNO,
        @An_MemberMci_IDNO          = @An_MemberMci_IDNO,
        @Ac_ActivityMajor_CODE      = @Ac_ActivityMajor_CODE,
        @Ac_ActivityMinor_CODE      = @Lc_ActivityMinor_CODE,
        @Ac_Subsystem_CODE          = @Lc_Subsystem_CODE,
        @An_TransactionEventSeq_NUMB= @An_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID         = @Lc_BatchRunUser_TEXT,
        @Ac_WorkerDelegate_ID       = @Lc_Space_TEXT,
        @Ad_Run_DATE                = @Ad_Run_DATE,
        @Ac_Notice_ID				= @Lc_Notice_ID,
        @Ac_TypeReference_CODE      = @Ac_TypeReference_CODE,
        @Ac_Reference_ID            = @Ac_Reference_ID,
        @An_OthpSource_IDNO         = @An_OthpSource_IDNO,
        @An_OrderSeq_NUMB			= @An_OrderSeq_NUMB,
		@Ac_Job_ID					= @Ac_Process_ID,
        @An_Topic_IDNO              = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + 'ELFC063 : BATCH_COMMON$SP_INSERT_ACTIVITY FAILED' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
         RETURN;
        END
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'ELFC064 : BATCH_ENF_ELFC$SP_INITIATE_REMEDY';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', Order_SEQ = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS CHAR(1)), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS CHAR(10)), '') + ', TypeOthpSource_CODE = ' + ISNULL(@Ac_TypeOthpSource_CODE, '') + ', OthpSource_IDNO = ' + ISNULL(CAST(@An_OthpSource_IDNO AS CHAR(10)), '') + ', ActivityMajor_CODE = ' + ISNULL(@Ac_ActivityMajor_CODE, '') + ', Subsystem_CODE = ' + ISNULL(@Lc_Subsystem_CODE, '') + ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS NVARCHAR(max)), '') + ', WorkerUpdate_IDNO = ' + ISNULL(@Ac_Worker_ID, '') + ', TypeReference_CODE = ' + ISNULL(@Ac_TypeReference_CODE, '') + ', Reference_ID = ' + ISNULL(@Ac_Reference_ID, '') + ', TypeChange_CODE = ' + ISNULL(@Ac_TypeChange_CODE, '') + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS CHAR(10));

       SELECT @Ln_OrderSeq_NUMB = CASE @Ac_ActivityMajor_CODE
                                   WHEN @Lc_ActivityMajorCclo_CODE
                                    THEN 0
                                   ELSE @An_OrderSeq_NUMB
                                  END;

       EXECUTE BATCH_ENF_ELFC$SP_INITIATE_REMEDY
        @Ac_TypeChange_CODE          = @Ac_TypeChange_CODE,
        @An_Case_IDNO                = @An_Case_IDNO,
        @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
        @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
        @An_OthpSource_IDNO          = @An_OthpSource_IDNO,
        @Ac_TypeOthpSource_CODE      = @Ac_TypeOthpSource_CODE,
        @Ac_ActivityMajor_CODE       = @Ac_ActivityMajor_CODE,
        @Ac_Subsystem_CODE           = @Lc_Subsystem_CODE,
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ac_Worker_ID                = @Ac_Worker_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeReference_CODE       = @Ac_TypeReference_CODE,
        @Ac_Reference_ID             = @Ac_Reference_ID,
        @Ac_Process_ID               = @Ac_Process_ID,
        @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
			SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + 'ELFC064 : BATCH_ENF_ELFC$SP_INITIATE_REMEDY FAILED' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
			RETURN;
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  
  END CATCH
 END


GO
