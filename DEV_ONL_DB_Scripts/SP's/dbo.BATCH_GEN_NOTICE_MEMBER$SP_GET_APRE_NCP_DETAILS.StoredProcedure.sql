/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_NCP_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_NCP_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Cp Apre Demo details
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_NCP_DETAILS] (
 @An_Application_IDNO      NUMERIC (15),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_RowCount_NUMB        INT = 0,
          @Li_CharIndexRow_NUMB    INT = 0,
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_CaseRelationShip_ncp_CODE CHAR(1) = 'A',
          @Lc_CaseRelationShip_pf_CODE  CHAR(1) = 'P',
          @Lc_NoticeCsi01_ID            CHAR(8) = 'CSI-01',
          @Ls_Routine_TEXT              VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_APRE_NCP_DETAILS',
          @Ls_Csi01Routine_TEXT         VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_APRE_NCP_DETAILS',
          @Ls_Csi01Routine1_TEXT        VARCHAR(100) = 'BATCH_GEN_NOTICE_FIN$SF_GET_ALSP_LIST',
          @Ld_High_DATE                 DATE = '12/31/9999';
          
 DECLARE  @Ls_Sqldata_TEXT         VARCHAR(400) = '',
          @Ls_Sql_TEXT             VARCHAR(1000) = '',
          @Ls_Result1_TEXT         VARCHAR(MAX) = '',
          @Ls_Result2_TEXT         VARCHAR(MAX) = '',
          @Ls_Output_TEXT          VARCHAR(MAX) = '';
DECLARE   @Li_FetchStatus_QNTY  INT,
          @Ls_ParenetELement_NAME  VARCHAR(150),
          @Ls_TotAmntList_TEXT     VARCHAR(400),
          @Ls_Err_Description_TEXT VARCHAR(4000);
 DECLARE  @Ln_GetNcpcur_Application_IDNO     NUMERIC(15),
          @Ln_GetNcpcur_MemberMci_IDNO       NUMERIC(10);
 DECLARE  @GetNcp_CUR              CURSOR;

  BEGIN TRY
   SET @As_DescriptionError_TEXT='';
   SET @Ac_Msg_CODE = '';
   SET @Ls_Sql_TEXT = 'SELECT  NDEL_Y1 ';
   SET @Ls_Sqldata_TEXT = ' Notice_ID = ' + @Lc_NoticeCsi01_ID;

   SELECT @Ls_ParenetELement_NAME = Element_NAME
     FROM NDEL_Y1 p
    WHERE p.Notice_ID = @Lc_NoticeCsi01_ID
      AND p.Procedure_NAME = @Ls_Routine_TEXT;

   SET @Ls_Sql_TEXT = 'SELECT  APCM_Y1 ';
   SET @Ls_Sqldata_TEXT = ' Application_IDNO = ' + ISNULL(CAST(@An_Application_IDNO AS VARCHAR(15)), '');
   SET @GetNcp_CUR = CURSOR
   FOR SELECT Application_IDNO,
              MemberMci_IDNO
         FROM APCM_Y1 a
        WHERE a.Application_IDNO = @An_Application_IDNO
          AND a.CaseRelationship_CODE IN (@Lc_CaseRelationShip_ncp_CODE, @Lc_CaseRelationShip_pf_CODE)
          AND a.EndValidity_DATE = @Ld_High_DATE;

   OPEN @GetNcp_CUR;

   FETCH NEXT FROM @GetNcp_CUR INTO @Ln_GetNcpcur_Application_IDNO, @Ln_GetNcpcur_MemberMci_IDNO;
   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   WHILE @Li_FetchStatus_QNTY  = 0
    BEGIN
     SET @Ls_TotAmntList_TEXT = '';
    DELETE FROM #NoticeElementsData_P1
      WHERE Element_name IN ('tot_owed_amnt', 'tot_balance_amnt', 'tot_paid_amnt')
        AND EXISTS (SELECT 1
                      FROM #NoticeElementsData_P1
                     WHERE Element_name IN ('tot_owed_amnt', 'tot_balance_amnt', 'tot_paid_amnt'));

     EXECUTE BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS
      @As_Proc_NAME             = @Ls_Csi01Routine_TEXT,
      @An_MemberMci_IDNO        = @Ln_GetNcpcur_MemberMci_IDNO,
      @An_Seq_NUMB              = 860,
      @As_Result_TEXT           = @Ls_Result1_TEXT OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RETURN;
      END

     SET @Li_RowCount_NUMB = @Li_RowCount_NUMB + 1;
     SET @Ls_Result1_TEXT = REPLACE(@Ls_Result1_TEXT, '</ncp_list>', '');
     SET @Li_CharIndexRow_NUMB = CHARINDEX('<row>', @Ls_Result1_TEXT);
     SET @Ls_Result1_TEXT = SUBSTRING(@Ls_Result1_TEXT, @Li_CharIndexRow_NUMB, LEN(@Ls_Result1_TEXT));
     SET @Li_CharIndexRow_NUMB = CHARINDEX('</row>', @Ls_Result1_TEXT);

     EXECUTE BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS
      @As_Proc_NAME             = @Ls_Csi01Routine1_TEXT,
      @An_MemberMci_IDNO        = @Ln_GetNcpcur_MemberMci_IDNO,
      @An_Seq_NUMB              = 1353,
      @As_Result_TEXT           = @Ls_Result2_TEXT OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     SELECT @Ls_TotAmntList_TEXT = COALESCE(@Ls_TotAmntList_TEXT, '') + '<' + p.Element_name + '>' + p.Element_value + '</' + p.Element_name + '>'
       FROM #NoticeElementsData_P1 p
      WHERE p.Element_name IN ('tot_owed_amnt', 'tot_balance_amnt', 'tot_paid_amnt');

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RETURN;
      END

     SET @Ls_Output_TEXT = @Ls_Output_TEXT + SUBSTRING(@Ls_Result1_TEXT, 1, @Li_CharIndexRow_NUMB - 1) + @Ls_TotAmntList_TEXT + @Ls_Result2_TEXT + '</row>'; --SUBSTRING(@Ls_Result1_TEXT, @Ln_CharIndexRow_NUMB, 500);
     FETCH NEXT FROM @GetNcp_CUR INTO @Ln_GetNcpcur_Application_IDNO, @Ln_GetNcpcur_MemberMci_IDNO;
     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS; 
    END

   CLOSE @GetNcp_CUR;

   DEALLOCATE @GetNcp_CUR;

   DELETE FROM #NoticeElementsData_P1 
    WHERE Element_name IN ('tot_owed_amnt', 'tot_balance_amnt', 'tot_paid_amnt')
      AND EXISTS (SELECT 1
                    FROM #NoticeElementsData_P1
                   WHERE Element_name IN ('tot_owed_amnt', 'tot_balance_amnt', 'tot_paid_amnt'));

   SET @Ls_Output_TEXT = '<' + @Ls_ParenetELement_NAME + '1 count = ''' + CAST(@Li_RowCount_NUMB AS VARCHAR) + '''>' + @Ls_Output_TEXT + '</' + @Ls_ParenetELement_NAME + '1>';

   INSERT INTO #NoticeElementsData_P1(
               Element_NAME, 
               Element_VALUE)
        VALUES (@Ls_ParenetELement_NAME,
                @Ls_Output_TEXT );

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
