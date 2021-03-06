/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_INSERT_CASE_PAYOR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_INSERT_CASE_PAYOR
Programmer Name		: IMP Team
Description			: This procedure is used to insert esem entry for Payor
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_INSERT_CASE_PAYOR](
 @An_EntityPayor_IDNO        NUMERIC(10),
 @An_EventFunctionalSeq_NUMB NUMERIC(4),
 @An_EventGlobalSeq_NUMB     NUMERIC(19),
 @Ac_Msg_CODE                CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_StatusSuccess_CODE             CHAR(1) = 'S',
          @Lc_StatusFailure_CODE             CHAR(1) = 'F',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Ls_Routine_TEXT                   VARCHAR(60) = 'BATCH_COMMON$SP_CREATE_SDER_HOLD';
  DECLARE @Ln_Rowcount_QNTY         NUMERIC,
          @Ln_Error_NUMB            NUMERIC,
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(400),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = '';

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   -- Insert NCP/PF all case as entity 
   SET @Ls_Sql_TEXT = 'SELECT_INSERT_VESEM';
   SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = CASE' + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@An_EventFunctionalSeq_NUMB AS VARCHAR), '') + ', ID_ENTITY_CASE = ' + ISNULL (CAST(@An_EntityPayor_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE IN ( ' + @Lc_CaseRelationshipNcp_CODE + ', ' + @Lc_CaseRelationshipPutFather_CODE + ') , CaseMemberStatus_CODE = ' + @Lc_CaseMemberStatusActive_CODE;
   INSERT ESEM_Y1
          (Entity_ID,
           TypeEntity_CODE,
           EventFunctionalSeq_NUMB,
           EventGlobalSeq_NUMB)
   SELECT C.Case_IDNO AS Entity_ID,
          'CASE' AS TypeEntity_CODE,
          @An_EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,
          @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB
     FROM CASE_Y1 C
          JOIN CMEM_Y1 CM
           ON C.Case_IDNO = CM.Case_IDNO
    WHERE CM.MemberMci_IDNO = @An_EntityPayor_IDNO
      AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
      AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

   SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

   IF @Ln_Rowcount_QNTY = 0
    BEGIN
     SET @Ls_ErrorMessage_TEXT = 'SELECT_INSERT_ESEM FAILED';

     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailure_CODE;
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
