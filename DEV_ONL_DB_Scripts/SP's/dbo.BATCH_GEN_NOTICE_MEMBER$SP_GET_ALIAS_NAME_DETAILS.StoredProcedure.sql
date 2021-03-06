/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_ALIAS_NAME_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_ALIAS_NAME_DETAILS
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_ALIAS_NAME_DETAILS] (
   @An_MemberMci_IDNO                 NUMERIC (10),
   @Ac_Msg_CODE                       VARCHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT
   )
AS
   BEGIN
      DECLARE
         @Ld_High_DATE DATE = '12/31/9999',
         @Lc_StatusSuccess_CODE CHAR (1) = 'S',
         @Ls_StatusNoDataFound_CODE CHAR (1) = 'N',
         @Lc_StatusFailed_CODE CHAR (1) = 'F',
         @Ls_TypeAliasA1_CODE CHAR (1) = 'A',
         @Ls_MsgZ1_CODE CHAR (1) = 'Z',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_ALIAS_NAME_DETAILS',
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (400),
         @Ls_DescriptionError_TEXT VARCHAR (4000),
         @Ln_RowCount_NUMB NUMERIC(1),
         @Lc_ncp_alias_stat_yes_CODE CHAR(1) = '',
         @Lc_ncp_alias_stat_no_CODE CHAR(1) = 'X';

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         SET @Ls_Sqldata_TEXT =  ' MemberMci_IDNO = ' + ISNULL (CAST (@An_MemberMci_IDNO AS CHAR(50)), '');
         SET @Ls_Sql_TEXT = 'SELECT AKAX_V1';

         INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
            (SELECT pvt.Element_NAME, pvt.Element_Value
               FROM (SELECT CONVERT (VARCHAR (70), a.AliasFml_NAME) AS NCP_FML_ALIAS_NAME,
                            CONVERT (VARCHAR (70), a.LastAlias_NAME) AS LastAlias_NAME,
                            CONVERT (VARCHAR (70), a.FirstAlias_NAME) AS FirstAlias_NAME,
                            CONVERT (VARCHAR (70), a.MiddleAlias_NAME) AS MiddleAlias_NAME
							-- 12051 - CR0234 ENF-39 PSOC Form Mapping Changes 20130710 - Fix - START
                       FROM (SELECT ( a.FirstAlias_NAME
                                     + ' '
                                     + a.MiddleAlias_NAME
                                     + ' '
                                     + a.LastAlias_NAME
                                     + ' '
                                     + a.SuffixAlias_NAME)
                                       AS AliasFml_NAME,
							-- 12051 - CR0234 ENF-39 PSOC Form Mapping Changes 20130710 - Fix - END
                                    a.LastAlias_NAME,
                                    a.FirstAlias_NAME,
                                    a.MiddleAlias_NAME
                               FROM AKAX_Y1 a
                              WHERE     a.MemberMci_IDNO = @An_MemberMci_IDNO
                                    AND a.TypeAlias_CODE = @Ls_TypeAliasA1_CODE
                                    AND a.EndValidity_DATE = @Ld_High_DATE
                                    AND a.Sequence_NUMB =
                                           (SELECT MAX (b.Sequence_NUMB)
                                              FROM AKAX_Y1 b
                                             WHERE     a.MemberMci_IDNO = b.MemberMci_IDNO
                                                   AND a.TypeAlias_CODE = b.TypeAlias_CODE
                                                   AND a.EndValidity_DATE = b.EndValidity_DATE)) a) up UNPIVOT (Element_Value FOR Element_NAME IN (NCP_FML_ALIAS_NAME, LastAlias_NAME, FirstAlias_NAME, MiddleAlias_NAME)) AS pvt);

		 SET @Ln_RowCount_NUMB = @@ROWCOUNT;

		 IF @Ln_RowCount_NUMB != 0
		  BEGIN
		   SET @Lc_ncp_alias_stat_yes_CODE = 'X';
		   SET @Lc_ncp_alias_stat_no_CODE = '';
		  END
		 
		 INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
			  (SELECT pvt.Element_NAME, pvt.Element_Value
                 FROM (SELECT CONVERT (VARCHAR (70), a.NCP_ALIAS_STAT_YES) AS NCP_ALIAS_STAT_YES,
                              CONVERT (VARCHAR (70), a.NCP_ALIAS_STAT_NO) AS NCP_ALIAS_STAT_NO
                         FROM (SELECT @Lc_ncp_alias_stat_yes_CODE AS NCP_ALIAS_STAT_YES, @Lc_ncp_alias_stat_no_CODE AS NCP_ALIAS_STAT_NO) a
                      )up UNPIVOT (Element_Value FOR Element_Name IN( NCP_ALIAS_STAT_YES, NCP_ALIAS_STAT_NO)) AS pvt);
		 
		 SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         DECLARE @Li_Error_NUMB INT = ERROR_NUMBER ()
               , @Li_ErrorLine_NUMB INT = ERROR_LINE ();

         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;


         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB       = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END

GO
