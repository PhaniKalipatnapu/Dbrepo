/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_ATTORNEY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_ATTORNEY
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Cp attorney details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	BATCH_COMMON$SF_GETCPATTORNEY
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_ATTORNEY](
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Notice_ID			   CHAR(8),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_Prefix_TEXT        CHAR(7) = 'CP_ATTY',
          @Ls_Routine_TEXT       VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_ATTORNEY',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_OtherParty_IDNO       NUMERIC(9),
          @Li_Error_NUMB            INT,
          @Li_ErrorLine_NUMB        INT,
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF @An_Case_IDNO IS NOT NULL
      AND @An_Case_IDNO <> 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_ATTORNEY_DETAILS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');
     IF @Ac_Notice_ID != 'CSI-01'
		BEGIN
			SET @Ln_OtherParty_IDNO = dbo.BATCH_COMMON$SF_GETCPATTORNEY(@An_Case_IDNO, @Ad_Run_DATE);
		END
	 ELSE
		BEGIN
			SELECT @Ln_OtherParty_IDNO = OthpAtty_IDNO
			  FROM APCM_Y1
			 WHERE Application_IDNO = (SELECT Application_IDNO FROM CASE_Y1 WHERE Case_IDNO = @An_Case_IDNO)
			   AND CaseRelationship_CODE = 'C'
			   AND EndValidity_DATE = @Ld_High_DATE;
		END

     IF @Ln_OtherParty_IDNO IS NOT NULL
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';
       SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@Ln_OtherParty_IDNO AS VARCHAR), '');

       EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
        @An_OtherParty_IDNO       = @Ln_OtherParty_IDNO,
        @As_Prefix_TEXT           = @Lc_Prefix_TEXT,
        @Ac_Msg_CODE              = @Ac_Msg_CODE,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR(50001,16,1);
        END
      END

     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
