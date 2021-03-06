/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_MEMBER_CLEARENCE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_MEMBER_CLEARENCE
Programmer Name		: IMP Team
Description			: Gets the Member Id with the input member information of Id_Member
                      (if available), SSN, First Name, Last Name, Middle Name, mem_sex, dt-birth.
                      It also gives the Mem_SSN or Name and exact,partial match or multiple,single match flag.
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_MEMBER_CLEARENCE]
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_MemberSsn_NUMB        NUMERIC(9),
 @Ac_First_NAME            CHAR(16),
 @Ac_Last_NAME             CHAR(20),
 @Ac_Middle_NAME           CHAR(20),
 @Ac_MemberSex_CODE        CHAR(1),
 @Ad_Birth_DATE            DATE,
 @An_MemberMciOut_IDNO     NUMERIC(10) OUTPUT,
 @Ac_MemberSsnMatch_INDC   CHAR(1) OUTPUT,
 @Ac_NameMatch_INDC        CHAR(1) OUTPUT,
 @Ac_ExactMatch_INDC       CHAR(1) OUTPUT,
 @Ac_MultMatch_INDC        CHAR(1) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_No_INDC                CHAR(1) = 'N',
          @Lc_Space_TEXT             CHAR(1) = ' ',
          @Lc_Yes_INDC               CHAR(1) = 'Y',
          @Lc_StatusNoDataFound_CODE CHAR(1) = 'N',
          @Lc_StringZero_TEXT        CHAR(1) = '0',
          @Lc_StatusFailed_CODE      CHAR(1) = 'F',
          @Lc_MemberSexUnknownU_CODE CHAR(1) = 'U',
          @Lc_LowA_NAME              CHAR(1) = 'A',
          @Lc_HighZ_NAME             CHAR(1) = 'Z',
          @Lc_Lowhyphen_TEXT         CHAR(1) = '_',
          @Lc_SingleMatchS_TEXT      CHAR(1) = 'S',
          @Lc_ExactMatchE_TEXT       CHAR(1) = 'E',
          @Lc_MultipleMatchM_TEXT    CHAR(1) = 'M',
          @Lc_PartialMatchP_TEXT     CHAR(1) = 'P',
          @Lc_MemberSexFemaleF_TEXT  CHAR(1) = 'F',
          @Lc_One_CODE               CHAR(1) = '1',
          @Lc_Two_CODE               CHAR(1) = '2',
          @Lc_Three_CODE             CHAR(1) = '3',
          @Ls_Routine_TEXT           VARCHAR(60) = 'BATCH_COMMON$SP_MEMBER_CLEARENCE',
          @Ld_Low_DATE               DATE = '01/01/0001',
          @Ld_High_DATE              DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB             NUMERIC,
          @Ln_RowCount_QNTY          NUMERIC,
          @Ln_Cur_NUMB               NUMERIC(6) = 0,
          @Ln_MemberMci_IDNO         NUMERIC(10),
          @Ln_ErrorLine_NUMB         NUMERIC(11),
          @Lc_Null_TEXT              CHAR(1) = '',
          @Lc_Blankkeys_TEXT         CHAR(1),
          @Lc_MemberSex_CODE         CHAR(1),
          @Lc_MclrMatchingFirst_NAME CHAR(15),
          @Lc_MclrLowMi_NAME         CHAR(20),
          @Lc_MclrHighMi_NAME        CHAR(20),
          @Lc_MclrMatchingLast_NAME  CHAR(20),
          @Ls_Sql_TEXT               VARCHAR(100),
          @Ls_Sqldata_TEXT           VARCHAR(1000),
          @Ls_ErrorMessage_TEXT      VARCHAR(4000) = '',
          @Ld_Birth_DATE             DATE;

  BEGIN TRY
   SET @An_MemberMciOut_IDNO = 0;
   SET @Ac_MemberSsnMatch_INDC = '';
   SET @Ac_NameMatch_INDC = '';
   SET @Ac_ExactMatch_INDC = '';
   SET @Ac_MultMatch_INDC = '';
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   /* Setting all the Output Parameters to Default values. If No match is found, then these values will be return.
   If match found, these values will be overwritten */
   SET @An_MemberMciOut_IDNO = 0;
   SET @Ac_MemberSsnMatch_INDC = @Lc_No_INDC;
   SET @Ac_NameMatch_INDC = @Lc_No_INDC;
   SET @Ac_ExactMatch_INDC = @Lc_No_INDC;
   SET @Ac_MultMatch_INDC = @Lc_No_INDC;
   SET @Ac_Msg_CODE = @Lc_Null_TEXT;
   SET @Lc_Blankkeys_TEXT = @Lc_No_INDC;
   SET @Lc_MclrLowMi_NAME = @Lc_Null_TEXT;
   SET @Lc_MclrHighMi_NAME = @Lc_Null_TEXT;

   IF (@Ad_Birth_DATE IS NULL
        OR @Ad_Birth_DATE = @Ld_Low_DATE)
    BEGIN
     SET @Ld_Birth_DATE = @Ld_High_DATE;
    END
   ELSE
    BEGIN
     SET @Ld_Birth_DATE = @Ad_Birth_DATE;
    END

   IF (LTRIM(RTRIM(@Ac_MemberSex_CODE)) = ''
        OR @Ac_MemberSex_CODE IS NULL)
    BEGIN
     SET @Lc_MemberSex_CODE = @Lc_MemberSexUnknownU_CODE;
    END
   ELSE
    BEGIN
     SET @Lc_MemberSex_CODE = @Ac_MemberSex_CODE;
    END

   IF (@An_MemberSsn_NUMB = 0
        OR ISNULL(LTRIM(RTRIM(@Ac_First_NAME)), @Lc_Space_TEXT) = @Lc_Space_TEXT
        OR ISNULL(LTRIM(RTRIM(@Ac_Last_NAME)), @Lc_Space_TEXT) = @Lc_Space_TEXT
        OR ISNULL(LTRIM(RTRIM(@Lc_MemberSex_CODE)), @Lc_Space_TEXT) = @Lc_MemberSexUnknownU_CODE
        OR @Ld_Birth_DATE = @Ld_High_DATE
        OR ISNULL(CONVERT(CHAR(4), @Ld_Birth_DATE, 112), 0) < 1900)
    BEGIN
     SET @Lc_Blankkeys_TEXT = @Lc_Yes_INDC;
    END

   --EXACT-MATCH - Begin
   IF ISNULL(LTRIM(RTRIM(@Ac_Middle_NAME)), @Lc_Space_TEXT) = @Lc_Space_TEXT
    BEGIN
     SET @Lc_MclrLowMi_NAME = @Lc_LowA_NAME;
     SET @Lc_MclrHighMi_NAME = @Lc_HighZ_NAME;
    END
   ELSE
    BEGIN
     SET @Lc_MclrLowMi_NAME = UPPER (@Ac_Middle_NAME);
     SET @Lc_MclrHighMi_NAME = UPPER (@Ac_Middle_NAME);
    END

   --first 7 charcters of Last_NAME match
   IF (LEN(REPLACE(RTRIM(@Ac_Last_NAME), ' ', '.')) > 7)
    BEGIN
     SET @Ls_Sql_TEXT = 'LAST NAME MATCH';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Lc_MclrMatchingLast_NAME = UPPER (REPLACE (@Ac_Last_NAME, ISNULL(SUBSTRING(@Ac_Last_NAME, 8, LEN(REPLACE(RTRIM(@Ac_Last_NAME), ' ', '.'))), ''), LEFT((LTRIM(RTRIM(@Lc_Lowhyphen_TEXT)) + REPLICATE(@Lc_Lowhyphen_TEXT, LEN(REPLACE(RTRIM(@Ac_Last_NAME), ' ', '.')) - 7)), LEN(REPLACE(RTRIM(@Ac_Last_NAME), ' ', '.')) - 7)));
    END
   ELSE
    BEGIN
     SET @Lc_MclrMatchingLast_NAME = UPPER (@Ac_Last_NAME);
    END

   --first 13 charcters of First_NAME match
   IF (LEN(REPLACE(RTRIM(@Ac_First_NAME), ' ', '.')) > 13)
    BEGIN
     SET @Ls_Sql_TEXT = 'LAST NAME MATCH WHERE FIRST NAME LENTH > 13';
     SET @Ls_Sqldata_TEXT = '';

     SELECT @Lc_MclrMatchingFirst_NAME = UPPER (REPLACE (@Ac_First_NAME, ISNULL(SUBSTRING(@Ac_First_NAME, 14, LEN(REPLACE(RTRIM(@Ac_First_NAME), ' ', '.'))), ''), LEFT((LTRIM(RTRIM(@Lc_Lowhyphen_TEXT)) + REPLICATE(@Lc_Lowhyphen_TEXT, LEN(REPLACE(RTRIM(@Ac_First_NAME), ' ', '.')) - 13)), LEN(REPLACE(RTRIM(@Ac_First_NAME), ' ', '.')) - 13)));
    END
   ELSE
    BEGIN
     SET @Lc_MclrMatchingFirst_NAME = UPPER (@Ac_First_NAME);
    END

   IF @Lc_Blankkeys_TEXT = @Lc_No_INDC
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;

     ----Start TRIM is added in the Middle_NAME
     ---Get the MemberMci_IDNO for MemberSsn_NUMB and Birth_DATE, MemberSex_CODE,Last_NAME, First_NAME
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1 FOR MemberSsn_NUMB, Birth_DATE, MemberSex_CODE,Last_NAME, First_NAME';
      SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL (CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL (CAST (@Ld_Birth_DATE AS NVARCHAR (10)), '') + ', Last_NAME = ' + ISNULL (@Lc_MclrMatchingLast_NAME, '') + ', First_NAME = ' + ISNULL (@Lc_MclrMatchingFirst_NAME, '');

      SELECT @Ln_RowCount_QNTY = COUNT (1),
             @Ln_MemberMci_IDNO = MAX (f.MemberMci_IDNO)
        FROM (SELECT DISTINCT
                     a.MemberMci_IDNO
                FROM DEMO_Y1 a,
                     MSSN_Y1 b
               WHERE b.MemberSsn_NUMB = @An_MemberSsn_NUMB
                 AND b.EndValidity_DATE = @Ld_High_DATE
                 AND a.MemberMci_IDNO = b.MemberMci_IDNO
                 AND a.Birth_DATE = @Ld_Birth_DATE
                 AND a.MemberSex_CODE = @Lc_MemberSex_CODE
                 AND a.Last_NAME LIKE @Lc_MclrMatchingLast_NAME
                 AND a.First_NAME LIKE @Lc_MclrMatchingFirst_NAME
                 AND (a.Middle_NAME BETWEEN @Lc_MclrLowMi_NAME AND @Lc_MclrHighMi_NAME
                       OR ISNULL(LTRIM(RTRIM(a.Middle_NAME)), @Lc_Space_TEXT) = @Lc_Space_TEXT)) AS f;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ln_RowCount_QNTY = 0;
       END

      IF @Ln_RowCount_QNTY = 1
       BEGIN
        IF @Ln_MemberMci_IDNO <> @An_MemberMci_IDNO
         BEGIN
          SET @Ac_MultMatch_INDC = @Lc_SingleMatchS_TEXT;
          SET @Ac_ExactMatch_INDC = @Lc_ExactMatchE_TEXT;
          SET @Ac_MemberSsnMatch_INDC = @Lc_Yes_INDC;
          SET @Ac_NameMatch_INDC = @Lc_Yes_INDC;
          SET @An_MemberMciOut_IDNO = @Ln_MemberMci_IDNO;

          RETURN;
         END
       END
      ELSE
       BEGIN
        IF @Ln_RowCount_QNTY > 1
         BEGIN
          SET @Ac_MultMatch_INDC = @Lc_MultipleMatchM_TEXT;
          SET @Ac_ExactMatch_INDC = @Lc_PartialMatchP_TEXT;
          SET @Ac_MemberSsnMatch_INDC = @Lc_Yes_INDC;
          SET @Ac_NameMatch_INDC = @Lc_Yes_INDC;
         END
       END

      --EXACT-MATCH - End
      --FEMALE-EXACT-MATCH - start                  
      IF @Ac_MultMatch_INDC = @Lc_No_INDC
       BEGIN
        IF @Ac_MemberSex_CODE = @Lc_MemberSexFemaleF_TEXT
         BEGIN
          SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1 FOR FEMALE';
          SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL (CAST(@An_MemberSsn_NUMB AS VARCHAR), '') + ', Birth_DATE = ' + ISNULL (CAST (@Ld_Birth_DATE AS NVARCHAR (10)), '') + ', First_NAME = ' + ISNULL (@Ac_First_NAME, '');

          SELECT @Ln_MemberMci_IDNO = MAX (c.MemberMci_IDNO),
                 @Ln_RowCount_QNTY = COUNT (1)
            FROM (SELECT DISTINCT
                         a.MemberMci_IDNO
                    FROM DEMO_Y1 a,
                         MSSN_Y1 b
                   WHERE b.MemberSsn_NUMB = @An_MemberSsn_NUMB
                     AND b.EndValidity_DATE = @Ld_High_DATE
                     AND a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND a.Birth_DATE = @Ld_Birth_DATE
                     AND a.MemberSex_CODE = @Lc_MemberSex_CODE
                     AND a.First_NAME = @Ac_First_NAME) AS c;

          SET @Ln_RowCount_QNTY = @@ROWCOUNT;

          IF @Ln_RowCount_QNTY = 0
           BEGIN
            SET @Ln_RowCount_QNTY = 0;
           END

          IF @Ln_RowCount_QNTY = 1
           BEGIN
            IF @Ln_MemberMci_IDNO <> @An_MemberMci_IDNO
             BEGIN
              SET @Ac_MultMatch_INDC = @Lc_SingleMatchS_TEXT;
              SET @Ac_ExactMatch_INDC = @Lc_ExactMatchE_TEXT;
              SET @Ac_MemberSsnMatch_INDC = @Lc_Yes_INDC;
              SET @Ac_NameMatch_INDC = @Lc_Yes_INDC;
              SET @An_MemberMciOut_IDNO = @Ln_MemberMci_IDNO;
             END
           END
          ELSE
           BEGIN
            IF @Ln_RowCount_QNTY > 1
             BEGIN
              SET @Ac_MultMatch_INDC = @Lc_MultipleMatchM_TEXT;
              SET @Ac_ExactMatch_INDC = @Lc_PartialMatchP_TEXT;
              SET @Ac_MemberSsnMatch_INDC = @Lc_Yes_INDC;
              SET @Ac_NameMatch_INDC = @Lc_Yes_INDC;
             END
           END
         END
       END
     END
    END

   --FEMALE-EXACT-MATCH - End
   --Partial Match starts.--
   --SSN-MATCH - start
   IF @Ac_MultMatch_INDC = @Lc_No_INDC
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StringZero_TEXT;

     IF @An_MemberSsn_NUMB <> 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MSSN_Y1';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_RowCount_QNTY = COUNT (1),
              @Ln_MemberMci_IDNO = MAX (a.MemberMci_IDNO)
         FROM (SELECT DISTINCT
                      m.MemberMci_IDNO
                 FROM MSSN_Y1 m
                WHERE m.MemberSsn_NUMB = @An_MemberSsn_NUMB
                  AND m.EndValidity_DATE = @Ld_High_DATE) AS a;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ln_RowCount_QNTY = 0;
        END

       IF @Ln_RowCount_QNTY = 1
        BEGIN
         IF @Ln_MemberMci_IDNO <> @An_MemberMci_IDNO
          BEGIN
           SET @Ac_MultMatch_INDC = @Lc_SingleMatchS_TEXT;
           SET @Ac_ExactMatch_INDC = @Lc_PartialMatchP_TEXT;
           SET @Ac_MemberSsnMatch_INDC = @Lc_Yes_INDC;
           SET @Ac_NameMatch_INDC = @Lc_No_INDC;
           SET @An_MemberMciOut_IDNO = @Ln_MemberMci_IDNO;
          END
        END
       ELSE
        BEGIN
         IF @Ln_RowCount_QNTY > 1
          BEGIN
           SET @Ac_MultMatch_INDC = @Lc_MultipleMatchM_TEXT;
           SET @Ac_ExactMatch_INDC = @Lc_PartialMatchP_TEXT;
           SET @Ac_MemberSsnMatch_INDC = @Lc_Yes_INDC;
           SET @Ac_NameMatch_INDC = @Lc_No_INDC;
          END
        END
      END
    END

   --SSN-MATCH - End
   --NAME-MATCH - Start
   IF @Ac_MultMatch_INDC = @Lc_No_INDC
    BEGIN
     SET @Ac_Msg_CODE = @Lc_One_CODE;

     IF @Ld_Birth_DATE = @Ld_High_DATE
         OR ISNULL(CONVERT(CHAR(4), @Ld_Birth_DATE, 112), 0) < 1900
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1 FOR name Match';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_MemberMci_IDNO = MAX (b.MemberMci_IDNO),
              @Ln_RowCount_QNTY = COUNT (1)
         FROM (SELECT DISTINCT
                      a.MemberMci_IDNO
                 FROM DEMO_Y1 a
                WHERE a.Last_NAME LIKE @Lc_MclrMatchingLast_NAME
                  AND a.First_NAME LIKE @Lc_MclrMatchingFirst_NAME
                  AND ((a.Middle_NAME BETWEEN @Lc_MclrLowMi_NAME AND @Lc_MclrHighMi_NAME)
                        OR LTRIM(RTRIM(a.Middle_NAME)) = '')) AS b;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ln_RowCount_QNTY = 0;
        END
      END
     ELSE
      BEGIN
       SET @Ac_Msg_CODE = @Lc_Two_CODE;
       SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1 FOR name AND dob Match';
       SET @Ls_Sqldata_TEXT = '';

       SELECT @Ln_MemberMci_IDNO = MAX (b.MemberMci_IDNO),
              @Ln_RowCount_QNTY = COUNT (1)
         FROM (SELECT DISTINCT
                      a.MemberMci_IDNO
                 FROM DEMO_Y1 a
                WHERE a.Last_NAME LIKE @Lc_MclrMatchingLast_NAME
                  AND a.First_NAME LIKE @Lc_MclrMatchingFirst_NAME
                  AND ((a.Middle_NAME BETWEEN @Lc_MclrLowMi_NAME AND @Lc_MclrHighMi_NAME)
                        OR LTRIM(RTRIM(a.Middle_NAME)) = '')
                  AND a.Birth_DATE = @Ld_Birth_DATE) AS b;

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF @Ln_RowCount_QNTY = 0
        BEGIN
         SET @Ln_RowCount_QNTY = 0;
        END
      END

     IF @Ln_RowCount_QNTY = 1
      BEGIN
       IF @Ln_MemberMci_IDNO <> @An_MemberMci_IDNO
        BEGIN
         SET @Ac_MultMatch_INDC = @Lc_SingleMatchS_TEXT;
         SET @Ac_ExactMatch_INDC = @Lc_PartialMatchP_TEXT;
         SET @Ac_MemberSsnMatch_INDC = @Lc_No_INDC;
         SET @Ac_NameMatch_INDC = @Lc_Yes_INDC;
         SET @An_MemberMciOut_IDNO = @Ln_MemberMci_IDNO;
        END
      END
     ELSE
      BEGIN
       IF @Ln_RowCount_QNTY > 1
        BEGIN
         SET @Ac_MultMatch_INDC = @Lc_MultipleMatchM_TEXT;
         SET @Ac_ExactMatch_INDC = @Lc_PartialMatchP_TEXT;
         SET @Ac_MemberSsnMatch_INDC = @Lc_No_INDC;
         SET @Ac_NameMatch_INDC = @Lc_Yes_INDC;
        END
      END
    END

   --NAME-MATCH - End
   --FEMALE-PARTIAL-MATCH --start
   IF @Ac_MultMatch_INDC = @Lc_No_INDC
    BEGIN
     SET @Ac_Msg_CODE = @Lc_Three_CODE;

     IF @Ac_MemberSex_CODE = @Lc_MemberSexFemaleF_TEXT
      BEGIN
       IF @Ld_Birth_DATE = @Ld_High_DATE
           OR ISNULL(CONVERT(CHAR(4), @Ld_Birth_DATE, 112), 0) < 1900
        BEGIN
         SET @Ls_Sql_TEXT = 'ASSIGN MEMBERMCI - 1';
         SET @Ls_Sqldata_TEXT = '';

         SELECT @Ln_MemberMci_IDNO = MAX (b.MemberMci_IDNO),
                @Ln_RowCount_QNTY = COUNT (1)
           FROM (SELECT DISTINCT
                        a.MemberMci_IDNO
                   FROM DEMO_Y1 a
                  WHERE a.First_NAME LIKE @Lc_MclrMatchingFirst_NAME
                    AND ((a.Middle_NAME BETWEEN @Lc_MclrLowMi_NAME AND @Lc_MclrHighMi_NAME)
                          OR LTRIM(RTRIM(a.Middle_NAME)) = '')) AS b;
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'ASSIGN MEMBERMCI - 2';
         SET @Ls_Sqldata_TEXT = '';

         SELECT @Ln_MemberMci_IDNO = MAX (b.MemberMci_IDNO),
                @Ln_RowCount_QNTY = COUNT (1)
           FROM (SELECT DISTINCT
                        a.MemberMci_IDNO
                   FROM DEMO_Y1 a
                  WHERE a.First_NAME LIKE @Lc_MclrMatchingFirst_NAME
                    AND ((a.Middle_NAME BETWEEN @Lc_MclrLowMi_NAME AND @Lc_MclrHighMi_NAME)
                          OR ISNULL(LTRIM(RTRIM(a.Middle_NAME)), @Lc_Space_TEXT) = @Lc_Space_TEXT)
                    AND a.Birth_DATE = @Ld_Birth_DATE) AS b;
        END

       IF @Ln_RowCount_QNTY = 1
        BEGIN
         IF @Ln_MemberMci_IDNO <> @An_MemberMci_IDNO
          BEGIN
           SET @Ac_MultMatch_INDC = @Lc_SingleMatchS_TEXT;
           SET @Ac_ExactMatch_INDC = @Lc_PartialMatchP_TEXT;
           SET @Ac_MemberSsnMatch_INDC = @Lc_No_INDC;
           SET @Ac_NameMatch_INDC = @Lc_Yes_INDC;
           SET @An_MemberMciOut_IDNO = @Ln_MemberMci_IDNO;
          END
        END
       ELSE
        BEGIN
         IF @Ln_RowCount_QNTY > 1
          BEGIN
           SET @Ac_MultMatch_INDC = @Lc_MultipleMatchM_TEXT;
           SET @Ac_ExactMatch_INDC = @Lc_PartialMatchP_TEXT;
           SET @Ac_MemberSsnMatch_INDC = @Lc_No_INDC;
           SET @Ac_NameMatch_INDC = @Lc_Yes_INDC;
          END
        END
      END
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
