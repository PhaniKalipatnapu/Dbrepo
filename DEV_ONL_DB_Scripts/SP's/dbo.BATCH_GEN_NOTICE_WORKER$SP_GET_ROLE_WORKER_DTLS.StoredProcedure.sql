/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_ROLE_WORKER_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_WORKER$SP_GET_ROLE_WORKER_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Worker Name based on the role ID
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_WORKER$SP_GET_ROLE_WORKER_DTLS] (
 @An_CpMemberMci_IDNO      NUMERIC(10),
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Notice_ID             CHAR(8),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS 
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_Space_TEXT         CHAR(1) = ' ',
          @Lc_Rolers028_ID       CHAR(5) = 'RS028',
          @Lc_Rolers024_ID       CHAR(5) = 'RS024',
          @Lc_RolePrefix_TEXT    CHAR(5) = 'ROLE_',
          @Lc_RoleSuffix_TEXT    CHAR(5) = '_NAME',
          @Lc_Noticecsi06_ID     CHAR(8) = 'CSI-06',
          @Lc_Noticecsm13_ID     CHAR(8) = 'CSM-13',
          @Lc_Noticecsm14_ID     CHAR(8) = 'CSM-14',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_GEN_NOTICE_WORKER$SP_GET_ROLE_WORKER_DTLS',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Alpharange_TEXT       CHAR(3),
          @Lc_Role_ID               CHAR(5),
          @Ls_RoleWorker_NAME		VARCHAR(150),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF @Ac_Notice_ID = @Lc_Noticecsi06_ID
    BEGIN
     SET @Lc_Role_ID = @Lc_Rolers028_ID;
    END
   ELSE IF @Ac_Notice_ID IN (@Lc_Noticecsm13_ID, @Lc_Noticecsm14_ID)
    BEGIN
     SET @Lc_Role_ID = @Lc_Rolers024_ID;
    END

   SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1';
   SET @Ls_Sqldata_TEXT = 'CPMemberMci_IDNO  = ' + CAST(ISNULL(@An_CpMemberMci_IDNO, 0)AS VARCHAR(10));

   SELECT @Lc_Alpharange_TEXT = SUBSTRING(d.Last_NAME, 1, 3)
     FROM DEMO_Y1 d
    WHERE MemberMci_IDNO = @An_CpMemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'SELECT USEM_Y1 USRL_Y1 CASE_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', Notice_ID = ' + ISNULL(@Ac_Notice_ID, '') + ', Run_DATE = ' + CAST(ISNULL(@Ad_Run_DATE, '') AS VARCHAR);
   
   SELECT @Ls_RoleWorker_NAME = RTRIM(u.First_NAME) + @Lc_Space_TEXT + RTRIM(u.Middle_NAME) + @Lc_Space_TEXT + RTRIM(u.Last_NAME)
     FROM USEM_Y1 u
    WHERE u.Worker_ID = (SELECT TOP 1 r.Worker_ID
                           FROM USRL_Y1 r,CASE_Y1 c     
                          WHERE  @Lc_Alpharange_TEXT BETWEEN r.AlphaRangeFrom_CODE     
                        AND r.AlphaRangeTo_CODE
						AND c.Case_IDNO = @An_Case_IDNO
                        AND c.Office_idno = r.Office_idno
                        AND r.Role_ID = @Lc_Role_ID
                        AND @Ad_Run_DATE BETWEEN r.Effective_DATE AND r.Expire_DATE
                        AND r.EndValidity_DATE = @Ld_High_DATE)
                        AND u.EndValidity_DATE = @Ld_High_DATE;
   
   IF (@Ls_RoleWorker_NAME IS NULL OR @Ls_RoleWorker_NAME = '')
	BEGIN
		SELECT @Ls_RoleWorker_NAME = RTRIM(u.First_NAME) + @Lc_Space_TEXT + RTRIM(u.Middle_NAME) + @Lc_Space_TEXT + RTRIM(u.Last_NAME)
     FROM USEM_Y1 u
    WHERE u.Worker_ID = (SELECT TOP 1 r.Worker_ID
                           FROM USRL_Y1 r,CASE_Y1 c 
                          WHERE  r.Role_ID = @Lc_Role_ID
						  AND c.Case_IDNO = @An_Case_IDNO
                        AND c.Office_idno = r.Office_idno
							AND @Ad_Run_DATE BETWEEN r.Effective_DATE AND r.Expire_DATE
							AND r.EndValidity_DATE = @Ld_High_DATE)
							AND u.EndValidity_DATE = @Ld_High_DATE;
	END
   
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT @Lc_RolePrefix_TEXT + @Lc_Role_ID + @Lc_RoleSuffix_TEXT AS Element_NAME,
          @Ls_RoleWorker_NAME AS Element_VALUE;
   
    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT =SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
 END


GO
