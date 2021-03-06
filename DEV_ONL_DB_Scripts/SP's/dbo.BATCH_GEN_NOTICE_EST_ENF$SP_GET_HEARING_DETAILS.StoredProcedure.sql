/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_HEARING_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
---------------------------------------------------------
 Procedure Name      :BATCH_GEN_NOTICE_EST_ENF$SP_GET_HEARING_DETAILS
 Programmer Name     : IMP Team
 Description         :This procedure gets the Scheduling Hearing Details like old scheduling date, Begin Scheduling time and genetic location details
 Frequency           :
 Developed On        :02-08-2011
 Called By           : BATCH_COMMON$SP_FORMAT_BUILD_XML
 Called On           :BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
---------------------------------------------------------
 Modified By         :
 Modified On         :
 Version No          : 1.0 
---------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_EST_ENF$SP_GET_HEARING_DETAILS] (
 @An_Case_IDNO             NUMERIC(6),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @An_MinorIntSeq_NUMB      NUMERIC(5),
 @Ac_PrintMethod_CODE      CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB          SMALLINT = 0,
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_Prefix_TEXT        CHAR(11) = 'GENETIC_LOC',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICE_EST_ENF$SP_GET_HEARING_DETAILS',
          @Ld_Schedule_DATE         DATE = NULL;
  DECLARE @Ln_MajorIntSeq_NUMB      NUMERIC(5),
          @Ln_MinorIntSeq_NUMB      NUMERIC(5),
          @Ln_Case_IDNO             NUMERIC(6),
          @Ln_OthpLocation_IDNO     NUMERIC(9) = 0,
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_BeginSch_DTTM         DATETIME2;

  BEGIN TRY
   SET @Ln_Case_IDNO = ISNULL(@An_Case_IDNO, 0);
   SET @Ln_MajorIntSeq_NUMB = ISNULL(@An_MajorIntSeq_NUMB, 0);

   IF @Ac_PrintMethod_CODE = 'V'
    BEGIN
     SELECT @Ln_MinorIntSeq_NUMB = ISNULL(@An_MinorIntSeq_NUMB, 0);
    END
   ELSE
    BEGIN
     SELECT @Ln_MinorIntSeq_NUMB = ISNULL(@An_MinorIntSeq_NUMB - 1, 0);
    END

   SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1';
   SET @Ls_SqlData_TEXT = 'Case_IDNO = ' + CAST(@Ln_Case_IDNO AS VARCHAR) + ', MajorIntSeq_NUMB = ' + CAST(@Ln_MajorIntSeq_NUMB AS VARCHAR) + ', MinorIntSeq_NUMB = ' + CAST(@Ln_MinorIntSeq_NUMB AS VARCHAR);

   SELECT TOP 1 @Ln_OthpLocation_IDNO = s.OthpLocation_IDNO,
                @Ld_Schedule_DATE = s.Schedule_DATE,
                @Ld_BeginSch_DTTM = s.BeginSch_DTTM
     FROM SWKS_Y1 s
    WHERE s.Schedule_NUMB = (SELECT MAX(d.Schedule_NUMB)
                               FROM DMNR_Y1 d
                              WHERE d.Case_IDNO = @Ln_Case_IDNO
                                AND d.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB
                                AND d.MinorIntSeq_NUMB <= @Ln_MinorIntSeq_NUMB)
      AND Worker_ID != '';
	  
   IF (@Ld_Schedule_DATE IS NOT NULL)
    BEGIN
     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_VALUE)
     SELECT 'old_schedule_date' AS Element_NAME,
            CONVERT(VARCHAR(10), @Ld_Schedule_DATE, 101) AS Element_VALUE
     UNION
     SELECT 'old_begin_sch_dttm' AS Element_NAME,
            CASE WHEN CAST(CONVERT(VARCHAR(4), @Ld_BeginSch_DTTM, 112) AS NUMERIC) != 1900 THEN SUBSTRING(CONVERT(VARCHAR, CAST(@Ld_BeginSch_DTTM AS DATETIME2), 131), 12, 5)  + ' '  + SUBSTRING(CONVERT(VARCHAR, CAST(@Ld_BeginSch_DTTM AS DATETIME2), 131), 28, 2) ELSE '' END AS Element_VALUE;
    END;

   SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
   SET @Ls_SqlData_TEXT = '@Ln_OthpLocation_IDNO = ' + ISNULL(CAST(@Ln_OthpLocation_IDNO AS VARCHAR(9)), '');

   IF (@Ln_OthpLocation_IDNO <> @Li_Zero_NUMB)
    BEGIN
     EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
      @An_OtherParty_IDNO       = @Ln_OthpLocation_IDNO,
      @As_Prefix_TEXT           = @Lc_Prefix_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
      BEGIN
       RAISERROR(50001,16,1);

       RETURN;
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

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
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
