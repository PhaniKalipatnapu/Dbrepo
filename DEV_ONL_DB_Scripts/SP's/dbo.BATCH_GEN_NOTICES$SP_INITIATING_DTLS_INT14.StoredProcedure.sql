/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_INITIATING_DTLS_INT14]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_INITIATING_DTLS_INT14
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_INITIATING_DTLS_INT14] (
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Recipient_CODE        CHAR (2),
 @Ad_Run_DATE              DATE,
 @Ac_Notice_ID             CHAR(8),
 @Ac_InitiatingFips_ID     CHAR(7),
 @Ac_TransOtherState_INDC  CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS 
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_CnetTransactionI_INDC CHAR(1) = 'I',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Ls_Procedure_NAME        VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_INITIATING_DTLS_INT14',
          @Ls_Prefix_TEXT           VARCHAR(70) = 'FROM_AGENCY_INT14';
  DECLARE @Lc_Null_TEXT    CHAR(1) = '',
          @Ls_Sql_TEXT     VARCHAR(100),
          @Ls_Sqldata_TEXT VARCHAR(1000);

  BEGIN TRY
   IF(@Ac_TransOtherState_INDC <> @Lc_CnetTransactionI_INDC)
    BEGIN
     EXECUTE BATCH_GEN_NOTICE_CNET$SP_SELECT_DE_FIPS
      @An_Case_IDNO             = @An_Case_IDNO,
      @As_Prefix_TEXT           = 'FROM_AGENCY_INT14_FIPS_CODE',
      @Ac_Msg_CODE              = @Ac_Msg_CODE,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT;

     
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Notice_ID = ' + ISNULL(@Ac_Notice_ID, '');

     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS
      @An_Case_IDNO             = @An_Case_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Ls_Prefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
          RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS';
     SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', InitiatingFips_IDNO = ' + ISNULL(@Ac_InitiatingFips_ID,'')+ ', Notice_ID = ' + ISNULL(@Ac_Notice_ID,'');

     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS
      @Ac_Recipient_CODE        = @Ac_Recipient_CODE,
      @Ac_Recipient_ID          = @Ac_InitiatingFips_ID,
      @Ac_TypeAddress_CODE      = @Lc_Null_TEXT,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Ls_Prefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
         RAISERROR(50001,16,1);
      END

    
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB            INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB        INT = ERROR_LINE (),
           @Ls_DescriptionError_TEXT VARCHAR (4000);

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END


GO
