/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_CASE_PAYEE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_CASE_PAYEE
Programmer Name		: IMP Team
Description			: This procedure is used to insert esem entry for Payee
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_CASE_PAYEE] (
 @Ac_CheckRecipient_ID       CHAR(10),
 @Ac_CheckRecipient_CODE     CHAR(1),
 @Ad_Disburse_DATE           DATE,
 @An_DisburseSeq_NUMB        NUMERIC(4),
 @An_EventFunctionalSeq_NUMB NUMERIC(4),
 @An_EventGlobalSeq_NUMB     NUMERIC(19),
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_DisbursementHoldInstruction1980_NUMB INT = 1980,
          @Li_RecoupmentInstruction2220_NUMB       INT = 2220,
          @Li_VoidNoReIssue1720_NUMB               INT = 1720,
          @Li_StopNoReIssue1730_NUMB               INT = 1730,
          @Li_StopReIssue1740_NUMB                 INT = 1740,
          @Li_VoidReIssue1750_NUMB                 INT = 1750,
          @Li_StopEft1760_NUMB                     INT = 1760,
          @Li_EftRejection1770_NUMB                INT = 1770,
          @Li_CheckCashed1800_NUMB                 INT = 1800,
          @Lc_CaseRelationshipCp_CODE              CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE             CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE       CHAR(1) = 'P',
          @Ls_Routine_TEXT                         VARCHAR(60) = 'BATCH_COMMON$SP_INSERT_CASE_PAYEE';
  DECLARE @Ln_Error_NUMB            NUMERIC,
          @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(400),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

/* if event is 1980 - DISBURSEMENT HOLD INSTRUCTION, 2220 -	RECOUPMENT INSTRUCTION, add check Receipirent case as functional event */
   IF @An_EventFunctionalSeq_NUMB IN (@Li_DisbursementHoldInstruction1980_NUMB, @Li_RecoupmentInstruction2220_NUMB)
    BEGIN
   SET @Ls_Sql_TEXT = 'SELECT INSERT ESEM_Y1 - 1';
   SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE  CASE' + '  EventGlobalSeq_NUMB = ' + ISNULL (CAST (@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@An_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', CheckRecipient_ID = ' + ISNULL (CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_CheckRecipient_CODE, '') + ', Disburse_DATE = ' + ISNULL (CAST (@Ad_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL (CAST (@An_DisburseSeq_NUMB AS VARCHAR), '');
   
     INSERT ESEM_Y1
            (Entity_ID,
             TypeEntity_CODE,
             EventFunctionalSeq_NUMB,
             EventGlobalSeq_NUMB)
     SELECT CM.Case_IDNO AS Entity_ID,
            'CASE' AS TypeEntity_CODE,
            @An_EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
            @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB
       FROM CMEM_Y1 CM
      WHERE CM.MemberMci_IDNO = @Ac_CheckRecipient_ID
        AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE, @Lc_CaseRelationshipCp_CODE);

     SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

     IF(@Ln_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT INTO ESEM_Y1 FAILED - 1';
       
       RAISERROR (50001,16,1);
      END
    END
   ELSE
    BEGIN
     IF @An_EventFunctionalSeq_NUMB IN (1710, @Li_VoidNoReIssue1720_NUMB, @Li_StopNoReIssue1730_NUMB, @Li_StopReIssue1740_NUMB,
                                        @Li_VoidReIssue1750_NUMB, @Li_StopEft1760_NUMB, @Li_EftRejection1770_NUMB, 1780,
                                        1790, @Li_CheckCashed1800_NUMB)
      BEGIN
	   SET @Ls_Sql_TEXT = 'SELECT INSERT ESEM_Y1 - 2';
       SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL('CASE','')+ ', EventGlobalSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST( @An_EventFunctionalSeq_NUMB AS VARCHAR ),'') + ', Check recipient Id = ' +  @Ac_CheckRecipient_ID + ', Check recipient code = ' +  @Ac_CheckRecipient_CODE + ', Disburse Date = ' + CAST(@Ad_Disburse_DATE AS VARCHAR) + ', Disburse Sequence Number' + CAST(@An_DisburseSeq_NUMB AS VARCHAR);
       INSERT ESEM_Y1
              (Entity_ID,
               TypeEntity_CODE,
               EventGlobalSeq_NUMB,
               EventFunctionalSeq_NUMB)
       (SELECT DISTINCT
               D.Case_IDNO AS Entity_ID,
               'CASE' AS TypeEntity_CODE,
               @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
               @An_EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB
          FROM DSBL_Y1 D
         WHERE D.CheckRecipient_ID = @Ac_CheckRecipient_ID
           AND D.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
           AND D.Disburse_DATE = @Ad_Disburse_DATE
           AND D.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
           );

       SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Ln_Rowcount_QNTY = 0)
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO ESEM_Y1 FAILED - 2';
         
         RAISERROR (50001,16,1);
        END
      END
    END

   SET @Ac_Msg_CODE = 'S';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = 'F';
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
