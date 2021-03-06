/****** Object:  StoredProcedure [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR
Programmer Name 	: IMP Team
Description			: This Procedure is used to assign the Distributed amount to the Appropriate Bucket
Frequency			: 'DAILY'
Developed On		: 04/12/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_REG_DISTRIBUTION$SP_EXPT_ARR]
 @An_Case_IDNO              NUMERIC(6),
 @An_OrderSeq_NUMB          NUMERIC(2),
 @An_ObligationSeq_NUMB     NUMERIC(2),
 @An_TransactionExpt_AMNT   NUMERIC (11, 2),
 @An_TransactionPaa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_TransactionNaa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_TransactionUda_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_TransactionCaa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_TransactionUpa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_TransactionTaa_AMNT    NUMERIC(11, 2) OUTPUT,
 @An_TransactionIvef_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_TransactionNffc_AMNT   NUMERIC(11, 2) OUTPUT,
 @An_TransactionNonIvd_AMNT NUMERIC(11, 2) OUTPUT,
 @An_TransactionMedi_AMNT   NUMERIC(11, 2) OUTPUT,
 @Ac_Msg_CODE               CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusSuccess_CODE     CHAR (1) = 'S',
           @Lc_StatusFailed_CODE      CHAR (1) = 'F',
           @Lc_PaaTypeBucket_CODE     CHAR (5) = 'APAA',
           @Lc_NaaTypeBucket_CODE     CHAR (5) = 'ANAA',
           @Lc_CaaTypeBucket_CODE     CHAR (5) = 'ACAA',
           @Lc_UpaTypeBucket_CODE     CHAR (5) = 'AUPA',
           @Lc_TaaTypeBucket_CODE     CHAR (5) = 'ATAA',
           @Lc_UdaTypeBucket_CODE     CHAR (5) = 'AUDA',
           @Lc_MediTypeBucket_CODE    CHAR (5) = 'AMEDI',
           @Lc_IvefTypeBucket_CODE    CHAR (5) = 'AIVEF',
           @Lc_NffcTypeBucket_CODE    CHAR (5) = 'ANFFC',
           @Lc_NonIvdTypeBucket_CODE  CHAR (5) = 'ANIVD',
           @Ls_Procedure_NAME         VARCHAR (100) = 'SP_EXPT_ARR';
  DECLARE  @Ln_Error_NUMB               NUMERIC (11),
           @Ln_ErrorLine_NUMB           NUMERIC (11),
           @Ln_TransactionExpt_AMNT     NUMERIC (11,2),
           @Li_FetchStatus_QNTY         SMALLINT,
           @Ls_Sql_TEXT                 VARCHAR (100) = '',
           @Ls_Sqldata_TEXT             VARCHAR (1000) = '',
           @Ls_ErrorMessage_TEXT        VARCHAR (4000) = '';
  DECLARE  @Lc_ExptCurTypeBucket_CODE  CHAR (5),
		   @Ln_ExptCurExpt_AMNT        NUMERIC (11,2);
  DECLARE Expt_CUR INSENSITIVE CURSOR FOR
   SELECT p.TypeBucket_CODE,
          p.Expt_AMNT
     FROM #Texpt_P1 p
    WHERE p.Case_IDNO = @An_Case_IDNO
      AND p.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND p.ObligationSeq_NUMB = @An_ObligationSeq_NUMB
      AND p.Expt_AMNT > 0
    ORDER BY p.PrDistribute_QNTY;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ln_TransactionExpt_AMNT = @An_TransactionExpt_AMNT;
   
   SET @Ls_Sql_TEXT = 'OPEN Expt_CUR';  
   SET @Ls_Sqldata_TEXT = ''; 
   OPEN Expt_CUR;

   BEGIN
    SET @Ls_Sql_TEXT = 'FETCH Expt_CUR - 1';    
    SET @Ls_Sqldata_TEXT = ''; 
    
    FETCH NEXT FROM Expt_CUR INTO @Lc_ExptCurTypeBucket_CODE,@Ln_ExptCurExpt_AMNT;

    SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    
    SET @Ls_Sql_TEXT = 'WHILE LOOP';    
    SET @Ls_Sqldata_TEXT = ''; 
    
    --Loop Started
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
      SET @Ls_Sql_TEXT = 'Paa_AMNT BUCKET';      
      SET @Ls_Sqldata_TEXT = ''; 
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_PaaTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 1';  
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionPaa_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 2';  
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionPaa_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'NAA BUCKET';  
      SET @Ls_Sqldata_TEXT = '';
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_NaaTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 3';  
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionNaa_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 4';  
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionNaa_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'Caa_AMNT BUCKET';      
      SET @Ls_Sqldata_TEXT = '';
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_CaaTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 5';  
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionCaa_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 6';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionCaa_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'UPA BUCKET';      
      SET @Ls_Sqldata_TEXT = '';
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_UpaTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 7';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionUpa_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 8';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionUpa_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'Taa_AMNT BUCKET';   
      SET @Ls_Sqldata_TEXT = '';
         
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_TaaTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 9';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionTaa_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 10';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionTaa_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'UDA BUCKET';      
      SET @Ls_Sqldata_TEXT = '';
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_UdaTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 11';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionUda_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 12';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionUda_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'MEDI BUCKET';      
      SET @Ls_Sqldata_TEXT = '';
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_MediTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 13';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionMedi_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 14';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionMedi_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'Ivef_AMNT BUCKET';      
      SET @Ls_Sqldata_TEXT = '';
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_IvefTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 15';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionIvef_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 16';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionIvef_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'NFFC BUCKET';      
      SET @Ls_Sqldata_TEXT = '';
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_NffcTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 17';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionNffc_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 18';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionNffc_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'NIVD BUCKET';      
      SET @Ls_Sqldata_TEXT = '';
      
      IF @Lc_ExptCurTypeBucket_CODE = @Lc_NonIvdTypeBucket_CODE
       BEGIN
        IF @Ln_TransactionExpt_AMNT >= @Ln_ExptCurExpt_AMNT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 19';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionNonIvd_AMNT = @Ln_ExptCurExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = @Ln_TransactionExpt_AMNT - @Ln_ExptCurExpt_AMNT;
         END
        ELSE
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT @An_TransactionPaa_AMNT, @Ln_TransactionExpt_AMNT - 20';
          SET @Ls_Sqldata_TEXT = '';

          SELECT @An_TransactionNonIvd_AMNT = @Ln_TransactionExpt_AMNT,
                 @Ln_TransactionExpt_AMNT = 0;
         END
       END

      SET @Ls_Sql_TEXT = 'FETCH Expt_CUR - 2';      
      SET @Ls_Sqldata_TEXT = '';
      
      FETCH NEXT FROM Expt_CUR INTO @Lc_ExptCurTypeBucket_CODE,@Ln_ExptCurExpt_AMNT;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END

   CLOSE Expt_CUR;

   DEALLOCATE Expt_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('LOCAL', 'Expt_CUR') IN (0, 1)
    BEGIN
     CLOSE Expt_CUR;

     DEALLOCATE Expt_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

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
