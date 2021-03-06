/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS
Programmer Name	:	IMP Team.
Description		:	This process Updates the Program Type and/or Add extra child in MHIS
Frequency		:	DAILY
Developed On	:	04/12/2012
Called By		:	BATCH_FIN_IVA_UPDATES$SP_PROCESS_UPDATE_IVA_REFERRALS,
					BATCH_FIN_IVA_UPDATES$SP_SKIP_UPDATE_IVA_REFERRALS,
Called On		:	BATCH_COMMON_MHIS$SP_PROCESS_MHIS,
					BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS] (
 @Ad_Run_DATE              DATE,
 @Ad_Start_DATE            DATE,
 @Ac_Job_ID                CHAR(7),
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_CaseWelfare_IDNO      NUMERIC(10),
 @Ac_TypeWelfare_CODE      CHAR(1),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  -- SET NOCOUNT ON After BEGIN Statement:
  SET NOCOUNT ON;

  -- Variable Declarations After SET NOCOUNT ON Statement:
  DECLARE @Li_FetchStatus_QNTY      SMALLINT = 0,
          @Lc_StatusFailed_CODE     CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE    CHAR(1) = 'S',
          @Lc_Msg_CODE              CHAR(1) = ' ',
          @Lc_ReasonPA_CODE         CHAR(2) = 'PA',
          @Lc_ReasonPR_CODE         CHAR(2) = 'PR',
          @Lc_BatchRunUser_TEXT     CHAR(5) = 'BATCH',
          @Ls_Procedure_NAME        VARCHAR(100) = 'BATCH_FIN_IVA_UPDATES$SP_UPDATE_MHIS',
          @Ls_Sql_TEXT              VARCHAR(2000) = ' ',
          @Ls_DescriptionError_TEXT VARCHAR(4000) = ' ',
          @Ls_ErrorMessage_TEXT     VARCHAR(4000) = ' ',
          @Ls_Sqldata_TEXT          VARCHAR(5000) = ' ',
          @Ld_High_DATE             DATE = '12/31/9999';
  DECLARE @Ln_ErrorLine_NUMB      NUMERIC(11) = 0,
          @Ln_Error_NUMB          NUMERIC(11) = 0,
          @Lc_Reason_CODE         CHAR(2) = '',
          @Ls_RhsMhisDataXML_TEXT VARCHAR(8000);
  -- CURSOR VARIABLE DECLARATION
  DECLARE @Ld_ChildMhisCur_Start_DATE       DATE,
          @Ld_ChildMhisCur_End_DATE         DATE,
          @Lc_ChildMhisCur_TypeWelfare_CODE CHAR(1),
          @Ln_ChildMhisCur_CaseWelfare_IDNO NUMERIC(10),
          @Lc_ChildMhisCur_Reason_CODE      CHAR(2);

  BEGIN TRY
   SET @Ls_RhsMhisDataXML_TEXT = '<Root>  
										<Record>  
											<Start_DATE>' + CAST(@Ad_Start_DATE AS VARCHAR) + '</Start_DATE>
											<End_DATE>' + CAST(@Ld_High_DATE AS VARCHAR) + '</End_DATE>  
											<TypeWelfare_CODE>' + @Ac_TypeWelfare_CODE + '</TypeWelfare_CODE>  
											<CaseWelfare_IDNO>' + CAST(@An_CaseWelfare_IDNO AS VARCHAR) + '</CaseWelfare_IDNO>  
											<WelfareMemberMci_IDNO>0</WelfareMemberMci_IDNO>  
											<Reason_CODE>' + @Lc_ReasonPA_CODE + '</Reason_CODE>  
										</Record>';

   DECLARE ChildMhis_CUR INSENSITIVE CURSOR FOR
    SELECT a.Start_DATE,
           a.End_DATE,
           a.TypeWelfare_CODE,
           a.CaseWelfare_IDNO,
           a.Reason_CODE
      FROM MHIS_Y1 a
     WHERE a.Case_IDNO = @An_Case_IDNO
       AND a.MemberMci_IDNO = @An_MemberMci_IDNO
     ORDER BY Start_DATE DESC;

   SET @Ls_Sql_TEXT = 'OPEN ChildMhis_CUR';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   OPEN ChildMhis_CUR;

   SET @Ls_Sql_TEXT = 'FETCH ChildMhis_CUR - 1';
   SET @Ls_Sqldata_TEXT ='Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   FETCH NEXT FROM ChildMhis_CUR INTO @Ld_ChildMhisCur_Start_DATE, @Ld_ChildMhisCur_End_DATE, @Lc_ChildMhisCur_TypeWelfare_CODE, @Ln_ChildMhisCur_CaseWelfare_IDNO, @Lc_ChildMhisCur_Reason_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   --To Form XML to pass it to Common Batch, Get all records in descending order and append to the main change record.
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Lc_Reason_CODE = @Lc_ChildMhisCur_Reason_CODE;

     IF @Ld_ChildMhisCur_End_DATE >= @Ad_Start_DATE
      BEGIN
       SET @Ld_ChildMhisCur_End_DATE = DATEADD (D, -1, @Ad_Start_DATE);
       SET @Lc_Reason_CODE = @Lc_ReasonPR_CODE;
      END

     SET @Ls_RhsMhisDataXML_TEXT = @Ls_RhsMhisDataXML_TEXT + '<Record>  
													<Start_DATE>' + CAST(@Ld_ChildMhisCur_Start_DATE AS VARCHAR) + '</Start_DATE>  
													<End_DATE>' + CAST(@Ld_ChildMhisCur_End_DATE AS VARCHAR) + '</End_DATE>  
													<TypeWelfare_CODE>' + @Lc_ChildMhisCur_TypeWelfare_CODE + '</TypeWelfare_CODE>  
													<CaseWelfare_IDNO>' + CAST(@Ln_ChildMhisCur_CaseWelfare_IDNO AS VARCHAR) + '</CaseWelfare_IDNO>  
													<WelfareMemberMci_IDNO>0</WelfareMemberMci_IDNO>  
													<Reason_CODE>' + @Lc_Reason_CODE + '</Reason_CODE>  
												</Record>';

     FETCH NEXT FROM ChildMhis_CUR INTO @Ld_ChildMhisCur_Start_DATE, @Ld_ChildMhisCur_End_DATE, @Lc_ChildMhisCur_TypeWelfare_CODE, @Ln_ChildMhisCur_CaseWelfare_IDNO, @Lc_ChildMhisCur_Reason_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE ChildMhis_CUR;

   DEALLOCATE ChildMhis_CUR;

   SET @Ls_RhsMhisDataXML_TEXT = @Ls_RhsMhisDataXML_TEXT + ' </Root>';
   SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON_MHIS$SP_PROCESS_MHIS';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', RhsMhisData_XML = ' + ISNULL(@Ls_RhsMhisDataXML_TEXT, '') + ', SignedOnWorker_ID = ' + ISNULL(@Lc_BatchRunUser_TEXT, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   EXECUTE BATCH_COMMON_MHIS$SP_PROCESS_MHIS
    @An_Case_IDNO             = @An_Case_IDNO,
    @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
    @As_RhsMhisData_XML       = @Ls_RhsMhisDataXML_TEXT,
    @Ac_SignedOnWorker_ID     = @Lc_BatchRunUser_TEXT,
    @Ad_Run_DATE              = @Ad_Run_DATE,
    @Ac_Job_ID                = @Ac_Job_ID,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   --CLOSE & DEALLOCATE CURSORS
   IF CURSOR_STATUS ('LOCAL', 'ChildMhis_CUR') IN (0, 1)
    BEGIN
     CLOSE ChildMhis_CUR;

     DEALLOCATE ChildMhis_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();
   SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   --Check for Exception information to log the description text based on the error
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
