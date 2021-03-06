/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_DEFENDENT_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_DEFENDENT_DTLS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_DEFENDENT_DTLS](
 @An_Case_IDNO				CHAR(6),
 @Ad_Run_DATE				DATE,
 @Ac_Notice_ID				CHAR(8) = NULL,
 @Ac_Msg_CODE				CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  DECLARE @Lc_First_NAME            CHAR(16),
          @Lc_Last_NAME             CHAR(20),
          @Lc_Middle_NAME           CHAR(20),
          @Ls_Defendant_IDNO        VARCHAR(10),
          @Lc_CaseRelationship_CODE CHAR(1),
          @Ls_ObligationStatus_CODE VARCHAR(2),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_Routine_TEXT          VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_GET_DEFENDENT_DTLS',
          @Ls_StatusSuccess_CODE    CHAR(1) ='S',
          @Ls_StatusFailed_CODE     CHAR(1) = 'F',
          @Ls_DoubleSpace_TEXT      VARCHAR(2) = '  '

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ' Notice_ID =' + @Ac_Notice_ID + ' Run_DATE =' + CAST(@Ad_Run_DATE AS VARCHAR);

   EXECUTE BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS
    @An_Case_IDNO            = @An_Case_IDNO,
    @As_LitigantOption_TEXT  = 'D',
    @Ad_Run_DATE             = @Ad_Run_DATE,
    @Ac_Notice_ID            = @Ac_Notice_ID,
    @As_First_NAME           = @Lc_First_NAME OUTPUT,
    @As_Last_NAME            = @Lc_Last_NAME OUTPUT,
    @As_Middle_NAME          = @Lc_Middle_NAME OUTPUT,
    @As_Litigant_IDNO        = @Ls_Defendant_IDNO OUTPUT,
    @Ac_CaseRelationship_CODE= @Lc_CaseRelationship_CODE OUTPUT,
    @As_ObligationStatus_CODE= @Ls_ObligationStatus_CODE OUTPUT,
    @Ac_Msg_CODE             = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT           = @As_DescriptionError_TEXT OUTPUT;

   IF(@Ac_Msg_CODE = @Ls_StatusFailed_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS FAILED';

     RAISERROR(50001,16,1);
    END

   INSERT INTO #NoticeElementsData_P1
               (pvt.Element_NAME,
                pvt.Element_Value)
   (SELECT Element_NAME,
           Element_Value
      FROM (SELECT CONVERT(VARCHAR(100), DEFENDANT_NAME) AS DEFENDANT_NAME,
                   CONVERT(VARCHAR(100), OPTION_DEFENDANT) AS OPTION_DEFENDANT,
                   CONVERT(VARCHAR(100), DEFENDANT_IDNO) AS DEFENDANT_IDNO
              FROM (SELECT @Lc_First_NAME + ' ' + @Lc_Middle_NAME + ' ' + @Lc_Last_NAME AS DEFENDANT_NAME,
                           @Ls_ObligationStatus_CODE AS OPTION_DEFENDANT,
                           @Ls_Defendant_IDNO AS DEFENDANT_IDNO) f)up
                  UNPIVOT (Element_Value FOR Element_NAME IN ( DEFENDANT_NAME, OPTION_DEFENDANT, DEFENDANT_IDNO )) AS pvt);

   IF(LEN(@Ls_Defendant_IDNO) = 10)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + @An_Case_IDNO + 'DEFENDANT_IDNO =' + @Ls_Defendant_IDNO;

     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS
      @An_MemberMci_IDNO = @Ls_Defendant_IDNO,
      @As_Prefix_TEXT    = 'DEFENDANT',
      @Ac_Msg_CODE       = @Ac_Msg_CODE,
      @As_DescriptionError_TEXT     = @As_DescriptionError_TEXT;

     IF(@Ac_Msg_CODE = @Ls_StatusFailed_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS FAILED';

       RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + @An_Case_IDNO + 'DEFENDANT_IDNO =' + @Ls_Defendant_IDNO;

     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO = @Ls_Defendant_IDNO,
      @As_Prefix_TEXT     = 'DEFENDANT',
      @Ac_Msg_CODE        = @Ac_Msg_CODE,
      @As_DescriptionError_TEXT      = @As_DescriptionError_TEXT;

     IF(@Ac_Msg_CODE = @Ls_StatusFailed_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS FAILED';

       RAISERROR(50001,16,1);
      END
    END
  END TRY

  BEGIN CATCH
   DECLARE @Ln_Errornumber_NUMB INT;
   DECLARE @Ls_Errormessage_TEXT NVARCHAR(4000);
   DECLARE @Ln_ErrorLine_NUMB INT;

   SET @Ac_Msg_CODE = @Ls_StatusFailed_CODE;
   SET @Ln_Errornumber_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_Errormessage_TEXT = ISNULL(@As_DescriptionError_TEXT, '') + SUBSTRING(ERROR_MESSAGE(), 1, 200);
   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Sql_TEXT, '') + ISNULL (@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Errormessage_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@Ls_Sqldata_TEXT, '') + ISNULL(@Ls_DoubleSpace_TEXT, '') + ISNULL(@As_DescriptionError_TEXT, '');
  END CATCH
 END


GO
