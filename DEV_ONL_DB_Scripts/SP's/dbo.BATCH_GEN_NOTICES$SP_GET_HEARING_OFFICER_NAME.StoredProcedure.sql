/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_HEARING_OFFICER_NAME]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_HEARING_OFFICER_NAME] (
 @An_OthpLocation_IDNO     NUMERIC (9),
 @Ac_SwksWorker_ID         CHAR (30),
 @Ad_Run_DATE			   DATE,
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 /*
 ------------------------------------------------------------------------------------------------------------------------------
 Procedure Name   : BATCH_GEN_NOTICES$SP_GET_HEARING_OFFICER_NAME
 Programmer Name  : IMP Team
 Description      : The procedure is used to obtain hearing officer name.
 Frequency        :
 Developed On     : 01/20/2011
 Called BY        : None
 Called On        :
 -------------------------------------------------------------------------------------------------------------------------------
 Modified BY      :
 Modified On      :
 Version No       : 1.0
 --------------------------------------------------------------------------------------------------------------------------------
 */
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT			CHAR = ' ',
		  @Lc_StatusFailed_CODE     CHAR = 'F',
          @Lc_StatusSuccess_CODE    CHAR = 'S',
          @Lc_Prefix_TEXT           CHAR(11) = 'GENETIC_LOC',
          @Ld_High_DATE				DATE = '12/31/9999',
          @Ls_Procedure_NAME        VARCHAR (100) = 'BATCH_GEN_NOTICES$SP_GET_HEARING_OFFICER_NAME';
          
  DECLARE @Ln_Error_NUMB     NUMERIC (11),
          @Ln_ErrorLine_NUMB NUMERIC (11),
          @Ls_Sql_TEXT       VARCHAR (100),
          @Ls_Sqldata_TEXT   VARCHAR (400),
          @Ls_DescriptionError_TEXT VARCHAR (4000) = '';  
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF (@Ac_SwksWorker_ID IS NOT NULL
       AND @Ac_SwksWorker_ID != '')
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT #NoticeElementsData_P1 ';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO =	' + ISNULL (CAST (@An_OthpLocation_IDNO AS VARCHAR), '');

     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_VALUE)
     SELECT 'sch_cnty_selection_code' AS Element_NAME,
            (CASE 
              WHEN o.Office_IDNO = 1
               THEN 'b'
              WHEN o.Office_IDNO IN (3, 99)
               THEN 'a'
              WHEN o.Office_IDNO = 5
               THEN 'c'
             END) AS Element_VALUE
       FROM OFIC_Y1 o
      WHERE o.OtherParty_IDNO = @An_OthpLocation_IDNO
        AND o.EndValidity_DATE = @Ld_High_DATE
        AND EXISTS (SELECT 1
                      FROM OTHP_Y1 o1
                     WHERE o1.OtherParty_IDNO = O.OtherParty_IDNO
                       AND o1.EndValidity_DATE =  @Ld_High_DATE);

     SET @Ls_Sql_TEXT = ' INSERT #NoticeElementsData_P1 ';
     SET @Ls_Sqldata_TEXT = 'Worker_ID =	' + ISNULL (CAST (@Ac_SwksWorker_ID AS VARCHAR), '');

     INSERT #NoticeElementsData_P1
            (Element_NAME,
             Element_VALUE)
     SELECT 'hearing_officer_name' AS Element_NAME,
            (SELECT (  ISNULL (LTRIM (RTRIM (e.First_NAME)), '')
					+ @Lc_Space_TEXT + ISNULL (LTRIM (RTRIM (e.Last_NAME)), '')) 
              FROM USEM_Y1 e
             WHERE e.Worker_ID = @Ac_SwksWorker_ID
               AND e.EndValidity_DATE = @Ld_High_DATE
               AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE) AS Element_VALUE;
            
     SET @Ls_Sql_TEXT = ' INSERT #NoticeElementsData_P1 ';
     SET @Ls_Sqldata_TEXT = 'Worker_ID =	' + ISNULL (CAST (@Ac_SwksWorker_ID AS VARCHAR), '');
     
     INSERT #NoticeElementsData_P1
            (Element_NAME,
             Element_VALUE)
     SELECT 'hearing_officer_sso_id' AS Element_NAME,
            @Ac_SwksWorker_ID AS Element_VALUE;

     SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
     SET @Ls_SqlData_TEXT = '@Ln_OthpLocation_IDNO = ' + ISNULL(CAST(@An_OthpLocation_IDNO AS VARCHAR(9)), '');

     IF (@An_OthpLocation_IDNO <> 0)
      BEGIN
       EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
        @An_OtherParty_IDNO       = @An_OthpLocation_IDNO,
        @As_Prefix_TEXT           = @Lc_Prefix_TEXT,
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR(50001,16,1);

         RETURN;
        END
      END
    END;

   SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER (),
          @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF ERROR_NUMBER () <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
