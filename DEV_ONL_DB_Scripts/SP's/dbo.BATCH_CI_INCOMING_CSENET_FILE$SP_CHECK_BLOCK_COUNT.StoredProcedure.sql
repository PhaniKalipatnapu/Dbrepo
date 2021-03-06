/****** Object:  StoredProcedure [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_CHECK_BLOCK_COUNT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_INCOMING_CSENET_FILE$SP_CHECK_BLOCK_COUNT
Programmer Name	:	IMP Team.
Description		:	This procedure is used to insert BATE Entry for Invalid CSENET entries
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_INCOMING_CSENET_FILE$SP_CHECK_BLOCK_COUNT]
 @Ac_Job_ID                CHAR(7),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Yes_INDC                CHAR(1) = 'Y',
          @Lc_TypeError_CODE          CHAR(1) = 'E',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_No_INDC                 CHAR(1) = 'N',
          @Lc_DuplicateX1_INDC        CHAR(1) = 'X',
          @Lc_ErrorAddNotsuccess_CODE CHAR(5) = 'E0113',
          @Ls_Procedure_NAME          VARCHAR(100) = 'BATCH_CI_INCOMING_CSENET_FILE$SP_CHECK_BLOCK_COUNT';
  DECLARE @Ln_FetchStatus_QNTY      NUMERIC,
          @Ln_Value_QNTY            NUMERIC(10) = 0,
          @Ln_Case_QNTY             NUMERIC(10) = 0,
          @Ln_Ncp_QNTY              NUMERIC(10) = 0,
          @Ln_Locate_QNTY           NUMERIC(10) = 0,
          @Ln_Part_QNTY             NUMERIC(10) = 0,
          @Ln_Order_QNTY            NUMERIC(10) = 0,
          @Ln_Coll_QNTY             NUMERIC(10) = 0,
          @Ln_Info_QNTY             NUMERIC(10) = 0,
          @Li_Error_NUMB            INT,
          @Li_ErrorLine_NUMB        INT,
          @Li_Zero_NUMB             SMALLINT = 0,
          @Lc_Msg_CODE              CHAR(5),
          @Ls_Table_TEXT            VARCHAR(60),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ls_Sqldata_TEXT          VARCHAR(4000) = '',
          @Ls_Temp_TEXT             VARCHAR(8000);
  DECLARE @Ln_HeaderCur_TransHeader_IDNO       NUMERIC(12),
          @Ld_HeaderCur_Transaction_DATE       DATE,
          @Lc_HeaderCur_IVDOutOfStateFips_CODE CHAR(2),
          @Li_HeaderCur_CaseData_QNTY          INT,
          @Li_HeaderCur_Ncp_QNTY               INT,
          @Li_HeaderCur_NcpLoc_QNTY            INT,
          @Li_HeaderCur_Participant_QNTY       INT,
          @Li_HeaderCur_Order_QNTY             INT,
          @Li_HeaderCur_Collection_QNTY        INT,
          @Li_HeaderCur_Info_QNTY              INT,
          @Ld_HeaderCur_CSENETTransaction_DATE DATE;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_CI_INCOMING_CSENET_FILE$SP_CHECK_BLOCK_COUNT';

   DECLARE Header_CUR INSENSITIVE CURSOR FOR
    SELECT a.TransHeader_IDNO,
           a.Transaction_DATE,
           a.IVDOutOfStateFips_CODE,
           CAST(a.CaseData_QNTY AS INTEGER) AS CaseData_QNTY,
           CAST(a.Ncp_QNTY AS INTEGER) AS Ncp_QNTY,
           CAST(a.NcpLoc_QNTY AS INTEGER) AS NcpLoc_QNTY,
           CAST(a.Participant_QNTY AS INTEGER) AS Participant_QNTY,
           CAST(a.Order_QNTY AS INTEGER) AS Order_QNTY,
           CAST(a.Collection_QNTY AS INTEGER) AS Collection_QNTY,
           CAST(a.Info_QNTY AS INTEGER) AS Info_QNTY,
           CONVERT(DATE, a.Transaction_DATE, 101) AS CSENETTransaction_DATE
      FROM LTHBL_Y1 a
     WHERE a.Process_INDC = @Lc_Yes_INDC
       AND (CAST(a.CaseData_QNTY AS INTEGER) > @Li_Zero_NUMB
             OR CAST(a.Ncp_QNTY AS INTEGER) > @Li_Zero_NUMB
             OR CAST(a.NcpLoc_QNTY AS INTEGER) > @Li_Zero_NUMB
             OR CAST(a.Participant_QNTY AS INTEGER) > @Li_Zero_NUMB
             OR CAST(a.Order_QNTY AS INTEGER) > @Li_Zero_NUMB
             OR CAST(a.Collection_QNTY AS INTEGER) > @Li_Zero_NUMB
             OR CAST(a.Info_QNTY AS INTEGER) > @Li_Zero_NUMB);

   OPEN Header_CUR;

   FETCH NEXT FROM Header_CUR INTO @Ln_HeaderCur_TransHeader_IDNO, @Ld_HeaderCur_Transaction_DATE, @Lc_HeaderCur_IVDOutOfStateFips_CODE, @Li_HeaderCur_CaseData_QNTY, @Li_HeaderCur_Ncp_QNTY, @Li_HeaderCur_NcpLoc_QNTY, @Li_HeaderCur_Participant_QNTY, @Li_HeaderCur_Order_QNTY, @Li_HeaderCur_Collection_QNTY, @Li_HeaderCur_Info_QNTY, @Ld_HeaderCur_CSENETTransaction_DATE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Validate the Block Quantity and the record number in each block
   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Ln_Value_QNTY = @Li_Zero_NUMB;
     SET @Ln_Case_QNTY = @Li_Zero_NUMB;
     SET @Ln_Ncp_QNTY = @Li_Zero_NUMB;
     SET @Ln_Locate_QNTY = @Li_Zero_NUMB;
     SET @Ln_Part_QNTY = @Li_Zero_NUMB;
     SET @Ln_Order_QNTY = @Li_Zero_NUMB;
     SET @Ln_Coll_QNTY = @Li_Zero_NUMB;
     SET @Ln_Info_QNTY = @Li_Zero_NUMB;

     IF @Li_HeaderCur_CaseData_QNTY > @Li_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'CASE DATA BLOCK COUNT';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       SELECT @Ln_Case_QNTY = COUNT(1)
         FROM CSDB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       IF (@Ln_Case_QNTY < @Li_HeaderCur_CaseData_QNTY)
        BEGIN
         SET @Ls_Table_TEXT = 'CSDB_Y1 ';
        END;
      END;

     IF @Li_HeaderCur_Ncp_QNTY > @Li_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'NCP DATA BLOCK COUNT';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       SELECT @Ln_Ncp_QNTY = COUNT(1)
         FROM CNCB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       IF (@Ln_Ncp_QNTY < @Li_HeaderCur_Ncp_QNTY)
        BEGIN
         SET @Ls_Table_TEXT = ISNULL(@Ls_Table_TEXT, '') + ',CNCB_Y1 ';
        END;
      END;

     IF @Li_HeaderCur_NcpLoc_QNTY > @Li_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'NCP LOCATE DATA BLOCK COUNT';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       SELECT @Ln_Locate_QNTY = COUNT(1)
         FROM CNLB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       IF (@Ln_Locate_QNTY < @Li_HeaderCur_NcpLoc_QNTY)
        BEGIN
         SET @Ls_Table_TEXT = ISNULL(@Ls_Table_TEXT, '') + ',CNLB_Y1 ';
        END;
      END;

     IF @Li_HeaderCur_Participant_QNTY > @Li_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'PARTICIPANT DATA BLOCK COUNT';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       SELECT @Ln_Part_QNTY = COUNT(1)
         FROM CPTB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       IF (@Ln_Part_QNTY < @Li_HeaderCur_Participant_QNTY)
        BEGIN
         SET @Ls_Table_TEXT = ISNULL(@Ls_Table_TEXT, '') + ',CPTB_Y1 ';
        END;
      END;

     IF @Li_HeaderCur_Order_QNTY > @Li_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'ORDER DATA BLOCK COUNT';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       SELECT @Ln_Order_QNTY = COUNT(1)
         FROM CORB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       IF (@Ln_Order_QNTY < @Li_HeaderCur_Order_QNTY)
        BEGIN
         SET @Ls_Table_TEXT = ISNULL(@Ls_Table_TEXT, '') + ',CORB_Y1 ';
        END;
      END;

     IF @Li_HeaderCur_Collection_QNTY > @Li_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'COLLECTION DATA BLOCK COUNT';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       SELECT @Ln_Coll_QNTY = COUNT(1)
         FROM CCLB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       IF (@Ln_Coll_QNTY < @Li_HeaderCur_Collection_QNTY)
        BEGIN
         SET @Ls_Table_TEXT = ISNULL(@Ls_Table_TEXT, '') + ',CCLB_Y1 ';
        END;
      END;

     IF @Li_HeaderCur_Info_QNTY > @Li_Zero_NUMB
      BEGIN
       SET @Ls_Sql_TEXT = 'INFO DATA BLOCK COUNT';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       SELECT @Ln_Info_QNTY = COUNT(1)
         FROM CFOB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       IF (@Ln_Info_QNTY < @Li_HeaderCur_Info_QNTY)
        BEGIN
         SET @Ls_Table_TEXT = ISNULL(@Ls_Table_TEXT, '') + ',CFOB_Y1 ';
        END;
      END;

     IF (@Ln_Case_QNTY < @Li_HeaderCur_CaseData_QNTY
          OR @Ln_Ncp_QNTY < @Li_HeaderCur_Ncp_QNTY
          OR @Ln_Locate_QNTY < @Li_HeaderCur_NcpLoc_QNTY
          OR @Ln_Part_QNTY < @Li_HeaderCur_Participant_QNTY
          OR @Ln_Order_QNTY < @Li_HeaderCur_Order_QNTY
          OR @Ln_Coll_QNTY < @Li_HeaderCur_Collection_QNTY
          OR @Ln_Info_QNTY < @Li_HeaderCur_Info_QNTY)
      BEGIN
       SET @Ls_Temp_TEXT = ISNULL(@Ls_Sql_TEXT, '') + ' ALL RECORD NOT INSERTED ' + ISNULL(@Ls_Table_TEXT, '');
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_COMMON$SP_BATE_LOG';
       SET @Ls_Sqldata_TEXT = 'Procedure_NAME = ' + ISNULL(@Ls_Procedure_NAME, '') + ', Job_ID = ' + ISNULL(@Ac_Job_ID, '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', TypeError_CODE = ' + ISNULL(@Lc_TypeError_CODE, '') + ', Line_NUMB = ' + ISNULL(CAST(@Ln_Value_QNTY AS VARCHAR), '') + ', Error_CODE = ' + ISNULL(@Lc_ErrorAddNotsuccess_CODE, '') + ', DescriptionError_TEXT = ' + ISNULL(@Ls_Temp_TEXT, '') + ', ListKey_TEXT = ' + ISNULL(@Ls_Sqldata_TEXT, '');

       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = 'BATCH_CI_INCOMING_CSENET_FILE',
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
        @An_Line_NUMB                = @Ln_Value_QNTY,
        @Ac_Error_CODE               = @Lc_ErrorAddNotsuccess_CODE,
        @As_DescriptionError_TEXT    = @Ls_Temp_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END;

       SET @Ls_Sql_TEXT = 'UPDATE LTHBL_Y1 Process_INDC TO N';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       UPDATE LTHBL_Y1
          SET Process_INDC = @Lc_No_INDC
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_Transaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE
          AND Process_INDC <> @Lc_DuplicateX1_INDC;

       SET @Ls_Sql_TEXT = 'UPDATE LCDBL_Y1 Process_INDC TO N';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       UPDATE LCDBL_Y1
          SET Process_INDC = @Lc_No_INDC
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_Transaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE
          AND Process_INDC <> @Lc_DuplicateX1_INDC;

       SET @Ls_Sql_TEXT = 'UPDATE LNBLK_Y1 Process_INDC TO N';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       UPDATE LNBLK_Y1
          SET Process_INDC = @Lc_No_INDC
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_Transaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE
          AND Process_INDC <> @Lc_DuplicateX1_INDC;

       SET @Ls_Sql_TEXT = 'UPDATE LNBLK_Y1 Process_INDC TO N';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       UPDATE LNLBL_Y1
          SET Process_INDC = @Lc_No_INDC
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_Transaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE
          AND Process_INDC <> @Lc_DuplicateX1_INDC;

       SET @Ls_Sql_TEXT = 'UPDATE LPBLK_Y1 Process_INDC TO N';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       UPDATE LPBLK_Y1
          SET Process_INDC = @Lc_No_INDC
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_Transaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE
          AND Process_INDC <> @Lc_DuplicateX1_INDC;

       SET @Ls_Sql_TEXT = 'UPDATE LOBLK_Y1 Process_INDC TO N';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       UPDATE LOBLK_Y1
          SET Process_INDC = @Lc_No_INDC
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_Transaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE
          AND Process_INDC <> @Lc_DuplicateX1_INDC;

       SET @Ls_Sql_TEXT = 'UPDATE LCBLK_Y1 Process_INDC TO N';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       UPDATE LCBLK_Y1
          SET Process_INDC = @Lc_No_INDC
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_Transaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE
          AND Process_INDC <> @Lc_DuplicateX1_INDC;

       SET @Ls_Sql_TEXT = 'UPDATE LIBLK_Y1 Process_INDC TO N';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_Transaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       UPDATE LIBLK_Y1
          SET Process_INDC = @Lc_No_INDC
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_Transaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE
          AND Process_INDC <> @Lc_DuplicateX1_INDC;

       SET @Ls_Sql_TEXT = 'DELETE CTHB_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       DELETE CTHB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       SET @Ls_Sql_TEXT = 'DELETE CSDB_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       DELETE CSDB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       SET @Ls_Sql_TEXT = 'DELETE CNCB_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       DELETE CNCB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       SET @Ls_Sql_TEXT = 'DELETE CNLB_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       DELETE CNLB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       SET @Ls_Sql_TEXT = 'DELETE CPTB_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       DELETE CPTB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       SET @Ls_Sql_TEXT = 'DELETE CORB_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       DELETE CORB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       SET @Ls_Sql_TEXT = 'DELETE CCLB_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       DELETE CCLB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;

       SET @Ls_Sql_TEXT = 'DELETE CFOB_Y1';
       SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@Ln_HeaderCur_TransHeader_IDNO AS VARCHAR), '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ld_HeaderCur_CSENETTransaction_DATE AS VARCHAR), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_HeaderCur_IVDOutOfStateFips_CODE, '');

       DELETE CFOB_Y1
        WHERE TransHeader_IDNO = @Ln_HeaderCur_TransHeader_IDNO
          AND Transaction_DATE = @Ld_HeaderCur_CSENETTransaction_DATE
          AND IVDOutOfStateFips_CODE = @Lc_HeaderCur_IVDOutOfStateFips_CODE;
      END;

     FETCH NEXT FROM Header_CUR INTO @Ln_HeaderCur_TransHeader_IDNO, @Ld_HeaderCur_Transaction_DATE, @Lc_HeaderCur_IVDOutOfStateFips_CODE, @Li_HeaderCur_CaseData_QNTY, @Li_HeaderCur_Ncp_QNTY, @Li_HeaderCur_NcpLoc_QNTY, @Li_HeaderCur_Participant_QNTY, @Li_HeaderCur_Order_QNTY, @Li_HeaderCur_Collection_QNTY, @Li_HeaderCur_Info_QNTY, @Ld_HeaderCur_CSENETTransaction_DATE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   IF CURSOR_STATUS('LOCAL', 'Header_CUR') IN (0, 1)
    BEGIN
     CLOSE Header_CUR;

     DEALLOCATE Header_CUR;
    END;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'Header_CUR') IN (0, 1)
    BEGIN
     CLOSE Header_CUR;

     DEALLOCATE Header_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
