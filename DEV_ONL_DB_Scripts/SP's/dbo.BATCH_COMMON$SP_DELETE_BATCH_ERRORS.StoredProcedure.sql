/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_DELETE_BATCH_ERRORS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_DELETE_BATCH_ERRORS
Programmer Name		: IMP Team
Description			: This procedure is used delete the old records form the batch_error table.
                      When Job id is passed as an input argument, particular batch error will be deleted from VBATE
                      table refering REFM_Y1 entry.
                      When Job id is not passed, then all the batch errors will be deleted from the BATE_Y1 table refering
                      VREFM entries. By default id_table is BATE , id_table_sub is the job id and cd_value is the error
                      code.
                      For deletion, the DAYS entry in the REFM_Y1 is referred for the Job id. If not present by default it
                      will take 30. By default id_table is DAYS , id_table_sub is the job id and cd_value is no. of days
                      to keep records in BATE_Y1.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_DELETE_BATCH_ERRORS]
 @Ac_Job_ID                CHAR(7),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_BateDeleteDuration_NUMB NUMERIC(2) = 30,
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_InStateb_TEXT           CHAR(3) = 'DEB',
          @Lc_Days_TEXT               CHAR(4) = 'DAYS',
          @Lc_Bate_TEXT               CHAR(4) = 'BATE',
          @Ls_Routine_TEXT            VARCHAR(60) = 'BATCH_COMMON$SP_DELETE_BATCH_ERRORS',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_DELETE_BATCH_ERRORS';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_Value_QNTY            NUMERIC(10) = 0,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ac_Job_ID = ISNULL (@Ac_Job_ID, '');
   
   IF dbo.BATCH_COMMON_SCALAR$SF_TRIM2_NULL_VARCHAR (@Ac_Job_ID) IS NOT NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_DELETE_BATCH_ERRORS';
     SET @Ls_Sqldata_TEXT = 'Table_ID = ' + ISNULL(@Lc_Bate_TEXT,'');
     
     SELECT @Ln_Value_QNTY = COUNT (1)
       FROM REFM_Y1 b
      WHERE b.Table_ID = @Lc_Bate_TEXT
        AND ISNULL (@Lc_InStateb_TEXT, '') + ISNULL (b.TableSub_ID, '') = @Ac_Job_ID;

     IF @Ln_Value_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'JOB NOT AVAIBALE IN REFM_Y1';

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'DELETE BATE_Y1 - 1';
     SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID,'')+ ', Table_ID = ' + ISNULL(@Lc_Bate_TEXT,'')+ ', Table_ID = ' + ISNULL(@Lc_Days_TEXT,'');
     
     DELETE BATE_Y1
       FROM BATE_Y1 a
      WHERE a.Job_ID = @Ac_Job_ID
        AND a.Error_CODE IN (SELECT b.Value_CODE
                               FROM REFM_Y1 b
                              WHERE b.Table_ID = @Lc_Bate_TEXT
                                AND ISNULL (@Lc_InStateb_TEXT, '') + ISNULL (b.TableSub_ID, '') = @Ac_Job_ID
                                AND a.EffectiveRun_DATE < dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE (dbo.BATCH_COMMON_SCALAR$SF_DATEADD (-CAST (ISNULL ((SELECT c.Value_CODE
                                                                                                                                                       FROM REFM_Y1 c
                                                                                                                                                      WHERE c.Table_ID = @Lc_Days_TEXT
                                                                                                                                                        AND ISNULL (@Lc_InStateb_TEXT, '') + ISNULL (c.TableSub_ID, '') = @Ac_Job_ID), @Ln_BateDeleteDuration_NUMB) AS FLOAT (53)), dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())));
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'DELETE BATE_Y1 - 2';
     SET @Ls_Sqldata_TEXT = 'Table_ID = ' + ISNULL(@Lc_Bate_TEXT,'')+ ', Table_ID = ' + ISNULL(@Lc_Days_TEXT,'');
     
     DELETE BATE_Y1
       FROM BATE_Y1 AS a
      WHERE EXISTS (SELECT 1
                      FROM REFM_Y1 b
                     WHERE b.Table_ID = @Lc_Bate_TEXT
                       AND ISNULL (@Lc_InStateb_TEXT, '') + ISNULL (b.TableSub_ID, '') = a.Job_ID
                       AND a.Error_CODE = b.Value_CODE
                       AND a.EffectiveRun_DATE < DATEADD(D,- CAST (ISNULL ((SELECT c.Value_CODE
																			   FROM REFM_Y1 c
																			  WHERE c.Table_ID = @Lc_Days_TEXT
																				AND ISNULL (@Lc_InStateb_TEXT, '') + ISNULL (c.TableSub_ID, '') = a.Job_ID), @Ln_BateDeleteDuration_NUMB) AS NUMERIC ), dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())));
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
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
