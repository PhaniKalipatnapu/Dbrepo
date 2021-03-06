/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_WRK_NAME_RS028]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_WRK_NAME_RS028
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get Worker Name of Role RS028 from USEM_V1
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_WRK_NAME_RS028]
 @An_Case_IDNO             NUMERIC( 6 ),
 @Ac_Msg_CODE              CHAR OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(MAX) OUTPUT
AS
 BEGIN
  DECLARE @Lc_StatusFailed_CODE      CHAR,
          @Lc_StatusNoDataFound_CODE CHAR,
          @Lc_StatusSuccess_CODE     CHAR,
          @Ls_DoubleSpace_TEXT       VARCHAR(2) = '  ',
          @Ls_Routine_TEXT           VARCHAR(100),
          @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400),
          @Ls_MemberMci_IDNO         VARCHAR(10),
          @Ld_Run_DATE               DATETIME2,
          @Ld_High_DATE              DATETIME2 = '12/31/9999',
          @Ls_Role_RSO18_IDNO        VARCHAR(5) ='RS028',
          @Ls_WorkerNameTag_TEXT     VARCHAR(20) = 'NAME_RS028_ROLE',
          @Ls_DESyst_TEXT            VARCHAR(5) ='DCSES',
          @Ls_Err_Description_TEXT   VARCHAR(4000);

  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';

  BEGIN TRY
   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT @Ls_WorkerNameTag_TEXT AS Tag_name,
          (First_NAME + ' ' + Last_NAME) AS Name
     FROM USEM_Y1
    WHERE Worker_ID = (SELECT TOP 1 Worker_ID
                         FROM USRL_Y1
                        WHERE Office_IDNO = (SELECT County_IDNO
                                               FROM CASE_Y1
                                              WHERE Case_IDNO = @An_Case_IDNO)
                          AND Role_ID = @Ls_Role_RSO18_IDNO
                          AND EndValidity_DATE = @Ld_High_DATE);

    SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error in ' + ERROR_PROCEDURE () + ' Procedure' + '. Error Desc - ' + @As_DescriptionError_TEXT + '. Error Execute Location - ' + @Ls_Sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error in ' + ERROR_PROCEDURE () + ' Procedure' + '. Error Desc - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
