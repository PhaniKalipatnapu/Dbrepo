/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_ADDRESS
Programmer Name		: IMP Team
Description			: This procedure gets the address from AHIS_Y1 table using the address hierarchy
					  1. Confirmed Good Mailing Address first
					  2. If no Confirmed Good Mailing, Confirmed Good Residence
					  3. If neither of the above, Last Mailing Address that is pending verification.
					  4. If none of the above then the Residence that is pending verification.
					  5. If none of the above, then most recent end dated Mailing
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
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_ADDRESS]
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ad_Run_DATE              DATE,
 @As_Line1_ADDR            VARCHAR(50) OUTPUT,
 @As_Line2_ADDR            VARCHAR(50) OUTPUT,
 @Ac_City_ADDR             CHAR(28) OUTPUT,
 @Ac_State_ADDR            CHAR(2) OUTPUT,
 @Ac_Zip_ADDR              CHAR(15) OUTPUT,
 @Ac_Country_ADDR          CHAR(2) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_TypeAddressMailing_CODE      CHAR(1) = 'M',
           @Lc_VerificationStatusGood_CODE  CHAR(1) = 'Y',
           @Lc_StatusNoDataFound_CODE       CHAR(1) = 'N',
           @Lc_Space_TEXT                   CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Lc_TypeAddressResidential_CODE  CHAR(1) = 'R',
           @Lc_VerStatusPending_ADDR        CHAR(1) = 'P',
           @Ls_Procedure_NAME               VARCHAR(100) = 'BATCH_COMMON$SP_GET_ADDRESS';
  DECLARE  @Ln_Rowcount_QNTY          NUMERIC,
           @Ln_Zero_NUMB              NUMERIC(1) = 0,
           @Ln_Error_NUMB             NUMERIC(11),
           @Ln_ErrorLine_NUMB         NUMERIC(11),
           @Ls_Sql_TEXT               VARCHAR(100),
           @Ls_Sqldata_TEXT           VARCHAR(4000),
           @Ls_ErrorMessage_TEXT      VARCHAR(4000);
           
  BEGIN TRY
   SET @As_Line1_ADDR = '';
   SET @As_Line2_ADDR = '';
   SET @Ac_City_ADDR = '';
   SET @Ac_State_ADDR = '';
   SET @Ac_Zip_ADDR = '';
   SET @Ac_Country_ADDR = '';
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';

   BEGIN
    SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1 1';
    SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Ad_Run_DATE = ' + ISNULL (CAST (@Ad_Run_DATE AS NVARCHAR (10)), '');

    SELECT @As_Line1_ADDR = b.Line1_ADDR,
           @As_Line2_ADDR = b.Line2_ADDR,
           @Ac_City_ADDR = b.City_ADDR,
           @Ac_State_ADDR = b.State_ADDR,
           @Ac_Zip_ADDR = b.Zip_ADDR,
           @Ac_Country_ADDR = b.Country_ADDR
      FROM (SELECT UPPER (a.Line1_ADDR) AS Line1_ADDR,
                   UPPER (a.Line2_ADDR) AS Line2_ADDR,
                   UPPER (a.City_ADDR) AS City_ADDR,
                   UPPER (a.State_ADDR) AS State_ADDR,
                   a.Zip_ADDR AS Zip_ADDR,
                   UPPER (a.Country_ADDR) AS Country_ADDR,
                   ROW_NUMBER () OVER ( PARTITION BY a.MemberMci_IDNO ORDER BY a.Status_CODE DESC, a.TypeAddress_CODE, a.End_DATE DESC) AS Row_NUMB
              FROM AHIS_Y1 a
             WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
               AND a.TypeAddress_CODE IN (@Lc_TypeAddressMailing_CODE, @Lc_TypeAddressResidential_CODE)
               AND a.Status_CODE IN (@Lc_VerificationStatusGood_CODE, @Lc_VerStatusPending_ADDR)
               AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE) AS b
     WHERE b.Row_NUMB = 1;

    SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

    IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1 2';
      SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Ad_Run_DATE = ' + ISNULL (CAST (@Ad_Run_DATE AS NVARCHAR (10)), '');

      SELECT @As_Line1_ADDR = c.Line1_ADDR,
             @As_Line2_ADDR = c.Line2_ADDR,
             @Ac_City_ADDR = c.City_ADDR,
             @Ac_State_ADDR = c.State_ADDR,
             @Ac_Zip_ADDR = c.Zip_ADDR,
             @Ac_Country_ADDR = c.Country_ADDR
        FROM (SELECT UPPER (b.Line1_ADDR) AS Line1_ADDR,
                     UPPER (b.Line2_ADDR) AS Line2_ADDR,
                     UPPER (b.City_ADDR) AS City_ADDR,
                     UPPER (b.State_ADDR) AS State_ADDR,
                     b.Zip_ADDR AS Zip_ADDR,
                     UPPER (b.Country_ADDR) AS Country_ADDR,
                     ROW_NUMBER () OVER ( PARTITION BY b.MemberMci_IDNO ORDER BY b.Status_CODE DESC, b.TypeAddress_CODE, b.End_DATE DESC) AS Row_NUMB
                FROM AHIS_Y1 b
               WHERE b.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND b.TypeAddress_CODE = @Lc_TypeAddressMailing_CODE
                 AND b.Status_CODE IN (@Lc_VerificationStatusGood_CODE, @Lc_VerStatusPending_ADDR)) AS c
       WHERE c.Row_NUMB = 1;

      SET @Ln_Rowcount_QNTY = @@ROWCOUNT;

      IF @Ln_Rowcount_QNTY = @Ln_Zero_NUMB
       BEGIN
        SET @Ac_Msg_CODE = @Lc_StatusNoDataFound_CODE;
        SET @As_DescriptionError_TEXT = 'NO ADDRESS FOUND';
        SET @As_Line1_ADDR = @Lc_Space_TEXT;
        SET @As_Line2_ADDR = @Lc_Space_TEXT;
        SET @Ac_City_ADDR = @Lc_Space_TEXT;
        SET @Ac_State_ADDR = @Lc_Space_TEXT;
        SET @Ac_Zip_ADDR = @Lc_Space_TEXT;
        SET @Ac_Country_ADDR = @Lc_Space_TEXT;

        RETURN;
       END
     END
   END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
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
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
