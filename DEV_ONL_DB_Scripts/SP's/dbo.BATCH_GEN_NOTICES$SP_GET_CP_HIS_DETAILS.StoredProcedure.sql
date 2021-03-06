/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_HIS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_CP_HIS_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Cp History details HDEMO_Y1
Frequency		:	
Developed On	:	4/19/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_CP_HIS_DETAILS](
 @An_CpMemberMci_IDNO      NUMERIC (10),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_GET_CP_HIS_DETAILS',
          @Ls_Sql_TEXT           VARCHAR (200) = 'SELECT HDEMO_Y1',
          @Ls_Sqldata_TEXT       VARCHAR (400) = 'Cp MemberMci IDNO : ' + ISNULL(CAST(@An_CpMemberMci_IDNO AS VARCHAR(10)), '');
  DECLARE @Ls_Err_Description_TEXT VARCHAR(4000);

  BEGIN TRY
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                ELEMENT_VALUE)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(20), opt_cp_name_change_yes) opt_cp_name_change_yes,
                   CONVERT(VARCHAR(20), opt_cp_name_change_no) opt_cp_name_change_no,
                   CONVERT(VARCHAR(20), CASE
                                         WHEN opt_cp_name_change_yes = 'X'
                                          THEN last_name
                                         ELSE ''
                                        END) cp_cur_last_name
              FROM (SELECT TOP 1 CASE
                                  WHEN HD.Last_NAME <> D.LAST_NAME
                                   THEN 'X'
                                  ELSE ''
                                 END opt_cp_name_change_yes,
                                 CASE
                                  WHEN (HD.Last_NAME = D.LAST_NAME
                                         OR HD.Last_NAME IS NULL)
                                   THEN 'X'
                                  ELSE ''
                                 END opt_cp_name_change_no,
                                 d.last_name
                      FROM DEMO_Y1 D
                           LEFT OUTER JOIN HDEMO_Y1 HD
                            ON HD.MemberMci_IDNO = D.MemberMci_IDNO
                     WHERE D.MemberMci_IDNO = @An_CpMemberMci_IDNO
                     ORDER BY HD.Update_DTTM DESC) AS fci) up UNPIVOT (tag_value FOR tag_name IN (opt_cp_name_change_yes, opt_cp_name_change_no, cp_cur_last_name)) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_Err_Description_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Err_Description_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
