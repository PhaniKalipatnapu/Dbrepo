/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_JAH_NAME]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_JAH_NAME
Programmer Name	:	IMP Team.
Description		:	This procedure fetches joint account holder name details
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_JAH_NAME] (
 @An_Case_IDNO             NUMERIC(6),
 @An_NcpMemberMci_IDNO     NUMERIC(10),
 @An_OtherParty_IDNO       NUMERIC(9),
 @Ac_ActivityMajor_CODE    CHAR(4),
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_Status_Y_CODE      CHAR(1) = 'Y',
          @Lc_JointAcct_INDC     CHAR(1) = 'Y',
          @Lc_JAHName_TEXT       CHAR(23) = 'joint_account_hldr_name',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ls_Procedure_NAME       VARCHAR(100),
          @Ls_Sql_TEXT             VARCHAR(200),
          @Ls_Sqldata_TEXT         VARCHAR(400),
          @Ls_Err_Description_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'SELECT ASFN_Y1_DMJR_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', MajorIntSeq_NUMB = ' + CAST(@An_MajorIntSeq_NUMB AS VARCHAR(5)) + ', ActivityMajor_CODE = ' + @Ac_ActivityMajor_CODE + ', OtherParty_IDNO = ' + CAST(@An_OtherParty_IDNO AS VARCHAR(10)) + ', NcpMemberMci_IDNO = ' + CAST(@An_NcpMemberMci_IDNO AS VARCHAR(10));

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT @Lc_JAHName_TEXT,
           NameAcctSecondaryNo_TEXT
      FROM ASFN_Y1 a
     WHERE a.MemberMci_IDNO = @An_NcpMemberMci_IDNO
       AND a.EndValidity_DATE = @Ld_High_DATE
       AND LTRIM(RTRIM(CAST(a.othpinsfin_idno AS VARCHAR(20)))) + LTRIM(RTRIM(a.accountassetno_text)) = (SELECT LTRIM(RTRIM(CAST(OthpSource_IDNO AS VARCHAR(20)))) + LTRIM(RTRIM(Reference_ID))
                                                                                                           FROM DMJR_Y1 d
                                                                                                          WHERE d.Case_IDNO = @An_Case_IDNO
                                                                                                            AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
                                                                                                            AND d.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                                                                                                            AND d.OthpSource_IDNO = @An_OtherParty_IDNO)
       AND a.Status_CODE = @Lc_Status_Y_CODE
       AND a.JointAcct_INDC = @Lc_JointAcct_INDC);

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
