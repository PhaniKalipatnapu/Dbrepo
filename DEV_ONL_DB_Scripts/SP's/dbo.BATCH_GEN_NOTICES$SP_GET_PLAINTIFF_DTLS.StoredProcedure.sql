/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_PLAINTIFF_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_PLAINTIFF_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_PLAINTIFF_DTLS](
 @An_Case_IDNO				NUMERIC(6),
 @Ad_Run_DATE				DATE,
 @Ac_Notice_ID				CHAR(8) = NULL,
 @Ac_Msg_CODE				CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  DECLARE @Lc_StatusSuccess_CODE    CHAR(1) ='S',
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Ls_Procedure_NAME          VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_GET_PLAINTIFF_DTLS';
       
  DECLARE @Lc_First_NAME            CHAR(16),
          @Lc_Last_NAME             CHAR(20),
          @Lc_Middle_NAME           CHAR(20),
          @Ls_Plaintiff_IDNO        NUMERIC(10),
          @Lc_CaseRelationship_CODE CHAR(1),
          @Ls_ObligationStatus_CODE VARCHAR(2),
          @Ls_Sql_TEXT              VARCHAR(100),
          @Ls_Sqldata_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO,0)  AS VARCHAR)+ ' Notice_ID =' + @Ac_Notice_ID + ' Run_DATE =' + CAST(@Ad_Run_DATE AS VARCHAR);

   EXECUTE BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS
    @An_Case_IDNO            = @An_Case_IDNO,
    @As_LitigantOption_TEXT  = 'P',
    @Ad_Run_DATE             = @Ad_Run_DATE,
    @Ac_Notice_ID            = @Ac_Notice_ID,
    @As_First_NAME           = @Lc_First_NAME OUTPUT,
    @As_Last_NAME            = @Lc_Last_NAME OUTPUT,
    @As_Middle_NAME          = @Lc_Middle_NAME OUTPUT,
    @As_Litigant_IDNO        = @Ls_Plaintiff_IDNO OUTPUT,
    @Ac_CaseRelationship_CODE= @Lc_CaseRelationship_CODE OUTPUT,
    @As_ObligationStatus_CODE= @Ls_ObligationStatus_CODE OUTPUT,
    @Ac_Msg_CODE             = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT           = @As_DescriptionError_TEXT OUTPUT;

  
   IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_EST_ENF$SP_GET_LITIGANT_DETAILS FAILED';

     RAISERROR(50001,16,1);
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT pvt.Element_NAME,
           pvt.Element_Value
      FROM (SELECT CONVERT(VARCHAR(100), PLAINTIFF_NAME) PLAINTIFF_NAME,
                   CONVERT(VARCHAR(100), OPTION_PLAINTIFF) OPTION_PLAINTIFF,
                   CONVERT(VARCHAR(100), PLAINTIFF_IDNO) PLAINTIFF_IDNO
              FROM (SELECT @Lc_First_NAME + ' ' + @Lc_Middle_NAME + ' ' + @Lc_Last_NAME AS PLAINTIFF_NAME,
                           @Ls_ObligationStatus_CODE AS OPTION_PLAINTIFF,
                           @Ls_Plaintiff_IDNO AS PLAINTIFF_IDNO) f)up 
                           UNPIVOT (Element_Value FOR Element_NAME IN ( PLAINTIFF_NAME, OPTION_PLAINTIFF, PLAINTIFF_IDNO )) AS pvt);

   IF(LEN(@Ls_Plaintiff_IDNO) = 10)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO ,0)AS VARCHAR) + 'PLAINTIFF_IDNO =' + @Ls_Plaintiff_IDNO;

     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS
      @An_MemberMci_IDNO = @Ls_Plaintiff_IDNO,
      @As_Prefix_TEXT    = 'PLAINTIFF',
      @Ac_Msg_CODE       = @Ac_Msg_CODE,
      @As_DescriptionError_TEXT     = @As_DescriptionError_TEXT;

     IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS FAILED';

       RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO ,0)AS VARCHAR) + 'PLAINTIFF_IDNO =' + CAST(@Ls_Plaintiff_IDNO AS CHAR);

     EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO = @Ls_Plaintiff_IDNO,
      @As_Prefix_TEXT     = 'PLAINTIFF',
      @Ac_Msg_CODE        = @Ac_Msg_CODE,
      @As_DescriptionError_TEXT      = @As_DescriptionError_TEXT;

     IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS FAILED';

       RAISERROR(50001,16,1);
      END
    END
  END TRY

  BEGIN CATCH
    SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;

         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
    END CATCH
 END


GO
