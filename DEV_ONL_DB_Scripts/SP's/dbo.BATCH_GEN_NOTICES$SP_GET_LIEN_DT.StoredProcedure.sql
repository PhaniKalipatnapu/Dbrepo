/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_LIEN_DT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_LIEN_DT
Programmer Name	:	IMP Team.
Description		:	This procedure is used to fetch the Lien Date element value
Frequency		:	
Developed On	:	4/19/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_LIEN_DT](
 @An_Case_IDNO             NUMERIC(6),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @Ac_Notice_ID             CHAR(8),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_StatusFailed_CODE			CHAR(1)		= 'F',
          @Lc_StatusSuccess_CODE		CHAR(1)		= 'S',
          @Lc_ReasonStatusFi_CODE		CHAR(2)		= 'FI',	
          @Lc_ReasonStatusLw_CODE		CHAR(2)		= 'LW',
          @Lc_ReasonStatusLp_CODE		CHAR(2)		= 'LP',
          @Lc_ReasonStatusPx_CODE		CHAR(2)		= 'PX',
          @Lc_ActivityMajorFidm_CODE	CHAR(4)		= 'FIDM',
          @Lc_ActivityMajorLien_CODE	CHAR(4)		= 'LIEN',
          @Lc_StatusStart_CODE			CHAR(4)		= 'STRT',
          @Lc_ActivityMinorEcfla_CODE	CHAR(5)		= 'ECFLA',
          @Lc_ActivityMinorPcsln_CODE	CHAR(5)		= 'PCSLN',
          @Lc_NoticeEnf41_ID			CHAR(6)		= 'ENF-41',
          @Lc_NoticeEnf43_ID			CHAR(6)		= 'ENF-43',
          @Lc_NoticeEnf46_ID			CHAR(6)		= 'ENF-46',
          @Lc_NoticeEnf47_ID			CHAR(6)		= 'ENF-47',
          @Lc_NoticeEnf48_ID			CHAR(6)		= 'ENF-48',
          @Lc_NoticeEnf53_ID			CHAR(6)		= 'ENF-53',
          @Lc_NoticeEnf55_ID			CHAR(6)		= 'ENF-55',
          @Lc_NoticeEnf56_ID			CHAR(6)		= 'ENF-56',
          @Lc_NoticeEnf57_ID			CHAR(6)		= 'ENF-57',
          @Ls_Procedure_NAME			VARCHAR(100)= 'BATCH_GEN_NOTICES$SP_GET_LIEN_DT';
          
  DECLARE @Li_Error_NUMB				INT,
          @Li_ErrorLine_NUMB			INT,
          @Ls_Sql_TEXT					VARCHAR(100)	= '',
          @Ls_Sqldata_TEXT				VARCHAR(400)	= '',
          @Ls_DescriptionError_TEXT		VARCHAR(4000)	= '',
          @Ld_Status_DATE				DATE;

  BEGIN TRY
   IF @Ac_Notice_ID IN (@Lc_NoticeEnf41_ID, @Lc_NoticeEnf43_ID, @Lc_NoticeEnf53_ID)
    BEGIN
     SELECT @Ld_Status_DATE = Status_DATE
       FROM DMNR_Y1 dm
      WHERE dm.Case_IDNO = @An_Case_IDNO
        AND dm.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
        AND dm.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE
        AND dm.ActivityMinor_CODE = @Lc_ActivityMinorEcfla_CODE
        AND dm.ReasonStatus_CODE = @Lc_ReasonStatusFi_CODE;
        
        IF(ISNULL(@Ld_Status_DATE,'') = '')
      BEGIN
        SELECT @Ld_Status_DATE = Entered_DATE 
          FROM DMJR_Y1 dj  
         WHERE dj.Case_IDNO = @An_Case_IDNO  
          AND dj.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB  
          AND dj.ActivityMajor_CODE = @Lc_ActivityMajorFidm_CODE  
      END 
    END
   ELSE IF @Ac_Notice_ID IN (@Lc_NoticeEnf46_ID, @Lc_NoticeEnf47_ID, @Lc_NoticeEnf48_ID)
    BEGIN
     SELECT @Ld_Status_DATE = Status_DATE
       FROM DMNR_Y1 d
      WHERE d.Case_IDNO = @An_Case_IDNO
        AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
        AND d.ActivityMajor_CODE = @Lc_ActivityMajorLien_CODE
        AND d.ActivityMinor_CODE = @Lc_ActivityMinorPcsln_CODE
        AND d.ReasonStatus_CODE IN (@Lc_ReasonStatusLw_CODE, @Lc_ReasonStatusLp_CODE, @Lc_ReasonStatusPx_CODE);
    END
  ELSE IF  @Ac_Notice_ID IN (@Lc_NoticeEnf56_ID, @Lc_NoticeEnf57_ID)
    BEGIN
     SELECT @Ld_Status_DATE = Generate_dttm
             FROM NRRQ_Y1 n
            WHERE n.Notice_ID = @Lc_NoticeEnf55_ID
               AND n.Case_IDNO = @An_Case_IDNO ;
    END
    SET @Ls_Sql_TEXT =' #NoticeElementsData_P1 ';
    SET @Ls_Sqldata_TEXT =' Element_Value = '+''; 
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
        VALUES('lien_date',
               CONVERT(CHAR(10), @Ld_Status_DATE, 101));

   SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Li_Error_NUMB = ERROR_NUMBER(),
          @Li_ErrorLine_NUMB = ERROR_LINE();

   IF ERROR_NUMBER () <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
