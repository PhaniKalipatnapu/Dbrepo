/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_ALIAS_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_ALIAS_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_ALIAS_DTLS] (
 @An_MotherMci_IDNO         NUMERIC(10),
 @An_FatherMci_IDNO         NUMERIC(10),
 @An_CaretakerMci_IDNO      NUMERIC(10),
 @Ac_TransOtherState_INDC   CHAR(1),
 @An_TransHeader_IDNO       NUMERIC(12),
 @Ad_Transaction_DATE       DATE,
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  BEGIN TRY
   DECLARE @Lc_StatusFailed_CODE    CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE   CHAR(1) = 'S',
           @Lc_CnetTransaction_INDC CHAR(1) = 'I',
           @Ls_Procedure_NAME       VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_PARENT_GUARDIAN_ALIAS_DTLS',
           @Ld_High_DATE            DATE = '12/31/9999';
   DECLARE @Ls_Sql_TEXT              VARCHAR(200) = '',
           @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
           @Ls_DescriptionError_TEXT VARCHAR(4000);

   SET @An_MotherMci_IDNO = ISNULL(@An_MotherMci_IDNO, 0);
   SET @An_FatherMci_IDNO = ISNULL(@An_FatherMci_IDNO, 0);
   SET @An_CaretakerMci_IDNO = ISNULL(@An_CaretakerMci_IDNO, 0);

   
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS';
     SET @Ls_Sqldata_TEXT = 'MotherMCI_IDNO = ' + ISNULL(CONVERT(VARCHAR(MAX), @An_MotherMci_IDNO), '');

     EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS
      @An_MemberMci_IDNO        = @An_MotherMci_IDNO,
      @As_Prefix_TEXT           = 'MOM',
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
         RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS';
     SET @Ls_Sqldata_TEXT = 'FatherMCI_IDNO = ' + CAST(ISNULL(@An_FatherMci_IDNO, 0) AS VARCHAR);

     EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS
      @An_MemberMci_IDNO        = @An_FatherMci_IDNO,
      @As_Prefix_TEXT           = 'FATHER',
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
        RAISERROR(50001,16,1);
      END

     DECLARE @Ndel_P1 TABLE (
      Element_NAME  VARCHAR(100),
      Element_Value VARCHAR(100));

     SET @Ls_Sql_TEXT = 'SELECT_VAKAX';

     INSERT INTO @Ndel_P1
                 (Element_NAME,
                  ELEMENT_VALUE)
     (SELECT tag_name,
             tag_value
        FROM (SELECT CONVERT(VARCHAR(100), AliasFml_NAME) SecondAliasFml_NAME,
                     CONVERT(VARCHAR(100), FirstAlias_NAME) SecondFirstAlias_NAME,
                     CONVERT(VARCHAR(100), LastAlias_NAME) SecondLastAlias_NAME,
                     CONVERT(VARCHAR(100), TitleAlias_NAME) SecondTitleAlias_NAME,
                     CONVERT(VARCHAR(100), MaidenAlias_NAME) SecondMaidenAlias_NAME,
                     CONVERT(VARCHAR(100), MiddleAlias_NAME) SecondMiddleAlias_NAME,
                     CONVERT(VARCHAR(100), SuffixAlias_NAME) SecondSuffixAlias_NAME
                FROM (SELECT (a.LastAlias_NAME + ' ' + a.FirstAlias_NAME + ' ' + a.MiddleAlias_NAME) AS AliasFml_NAME,
                             a.LastAlias_NAME,
                             a.FirstAlias_NAME,
                             a.MiddleAlias_NAME,
                             a.TitleAlias_NAME AS TitleAlias_NAME,
                             a.MaidenAlias_NAME AS MaidenAlias_NAME,
                             a.SuffixAlias_NAME AS SuffixAlias_NAME
                        FROM AKAX_Y1  a
                       WHERE a.MemberMci_IDNO = @An_FatherMci_IDNO
                         AND a.TypeAlias_CODE = 'A'
                         AND a.EndValidity_DATE !=  @Ld_High_DATE
                         AND a.Sequence_NUMB = (SELECT MAX(b.Sequence_NUMB)-- AS expr
                                                  FROM AKAX_Y1 b
                                                 WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                                                   AND a.TypeAlias_CODE = b.TypeAlias_CODE
                                                   AND b.EndValidity_DATE !=  @Ld_High_DATE))a) up UNPIVOT (tag_value FOR tag_name IN ( SecondAliasFml_NAME, SecondFirstAlias_NAME, SecondLastAlias_NAME, SecondTitleAlias_NAME, SecondMaidenAlias_NAME, SecondMiddleAlias_NAME, SecondSuffixAlias_NAME )) AS pvt);

     UPDATE @Ndel_P1
        SET Element_NAME = 'FATHER' + '_' + Element_NAME;

     INSERT INTO #NoticeElementsData_P1
                 (Element_NAME,
                  Element_Value)
     SELECT t.Element_NAME,
            t.Element_Value
       FROM @Ndel_P1 t;

     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS';
     SET @Ls_Sqldata_TEXT = 'CaretakerMci_IDNO = ' + ISNULL(CONVERT(VARCHAR(MAX), @An_CaretakerMci_IDNO), '');

     EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_ALIAS_DETAILS
      @An_MemberMci_IDNO        = @An_CaretakerMci_IDNO,
      @As_Prefix_TEXT           = 'CARETAKER',
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF(@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
      BEGIN
        RAISERROR(50001,16,1);
      END
    END
   
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

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
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
