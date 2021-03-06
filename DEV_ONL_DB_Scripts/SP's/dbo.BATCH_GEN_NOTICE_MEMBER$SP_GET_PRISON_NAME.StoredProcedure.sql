/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_PRISON_NAME]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_PRISON_NAME
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Prison Details for the Given Member MCI.
Frequency		:	
Developed On	:	5/10/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_PRISON_NAME]
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ad_Run_DATE			   DATETIME2,	
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE 
          @Lc_StatusSuccess_CODE      CHAR(1)= 'S',
          @Lc_StatusFailed_CODE       CHAR(1)= 'F',
          @Lc_Incarcerationvalue_CODE CHAR(1)= 'X',
          @Ls_Procedure_NAME          VARCHAR(100) ='BATCH_GEN_NOTICE_MEMBER$SP_GET_PRISON_NAME',
          @Ld_High_DATE               DATE ='12/31/9999',
          @Ld_Low_DATE                DATE ='01/01/0001';
  DECLARE 
          @Ln_Institution_IDNO        NUMERIC(9) = 0,
          @Ln_RowCount_NUMB           NUMERIC(10) = 0,
          @Ln_Error_NUMB              NUMERIC(11),
          @Ln_ErrorLine_NUMB          NUMERIC(11),
          @Lc_IncarcerationYes_INDC   CHAR(1)='',
          @Lc_IncarcerationNo_INDC    CHAR(1)='',
          @Lc_City_ADDR               CHAR(28)='',
          @Lc_Attn_ADDR               CHAR(40)= '',
          @Ls_OtherParty_NAME         VARCHAR(60) = '',
          @Ls_State_ADDR              VARCHAR(75)='',
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Release_DATE       DATE;

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'SELECT MDET_Y1';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + CAST(ISNULL(@An_MemberMci_IDNO, 0) AS VARCHAR);

	 -- ENF-17 Criminal Non Support field mapping Fix - Start
   SELECT @Ln_Institution_IDNO = m.Institution_IDNO,
          @Ld_Release_DATE = m.Release_DATE
     FROM MDET_Y1 m
    WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
      AND m.Incarceration_DATE NOT IN (@Ld_High_DATE, @Ld_Low_DATE)
      AND m.Institution_IDNO != 0
      AND m.EndValidity_DATE = @Ld_High_DATE
      AND m.Release_DATE >= @Ad_Run_DATE;  
      -- ENF-17 Criminal Non Support field mapping Fix - End

   SET @Ln_RowCount_NUMB = @@ROWCOUNT;

   IF @Ln_RowCount_NUMB > 0
    BEGIN
     SET @Lc_IncarcerationYes_INDC = @Lc_Incarcerationvalue_CODE;
    END
   ELSE
    BEGIN
     SET @Lc_IncarcerationNo_INDC = @Lc_Incarcerationvalue_CODE;
    END

   IF ISNULL(@Ln_Institution_IDNO, 0) != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
     SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + CAST(ISNULL(@Ln_Institution_IDNO, 0) AS VARCHAR);

     SELECT @Ls_OtherParty_NAME = o.OtherParty_NAME,
            @Lc_Attn_ADDR = o.Attn_ADDR,
            @Lc_City_ADDR = o.City_ADDR,
            @Ls_State_ADDR = o.State_ADDR
       FROM OTHP_Y1 o
      WHERE o.OtherParty_IDNO = @Ln_Institution_IDNO
        AND o.EndValidity_DATE = @Ld_High_DATE;
    END

   SET @Ls_Sql_TEXT = 'Select Prison Details';
   SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + CAST(ISNULL(@Ln_Institution_IDNO, 0) AS VARCHAR);

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), prison_name) prison_name,
                   CONVERT(VARCHAR(100), prison_attn_addr) prison_attn_addr,
                   CONVERT(VARCHAR(100), prison_City_addr) prison_City_addr,
                   CONVERT(VARCHAR(100), prison_State_addr) prison_State_addr,
                   ISNULL(CONVERT(VARCHAR(100), Release_DATE), '') Expected_IncarcerationRelease_date,
                   CONVERT(VARCHAR(100), IncarcerationYes_INDC) IncarcerationYes_INDC,
                   CONVERT(VARCHAR(100), IncarcerationNo_INDC) IncarcerationNo_INDC
              FROM (SELECT @Ls_OtherParty_NAME AS prison_name,
                           @Lc_Attn_ADDR AS prison_attn_addr,
                           @Lc_City_ADDR AS prison_City_addr,
                           @Ls_State_ADDR AS prison_State_addr,
                           @Ld_Release_DATE AS Release_DATE,
                           @Lc_IncarcerationYes_INDC AS IncarcerationYes_INDC,
                           @Lc_IncarcerationNo_INDC AS IncarcerationNo_INDC) h)up UNPIVOT (tag_value FOR tag_name IN ( prison_name, prison_attn_addr, prison_City_addr, prison_State_addr, Expected_IncarcerationRelease_date, IncarcerationYes_INDC, IncarcerationNo_INDC) ) AS pvt);

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
