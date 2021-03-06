/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_PUDM$SP_GET_OTHP_INFO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_LOC_OUTGOING_PUDM$SP_GET_OTHP_INFO
Programmer Name 	: IMP Team
Description			: The procedure BATCH_LOC_OUTGOING_PUDM$SP_GET_OTHP_INFO reads Other Party information from OTHP_Y1. 
Frequency			: 'QUATERLY'
Developed On		: 10/24/2011
Called BY			: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_PUDM$SP_GET_OTHP_INFO] (
 @Ad_Run_DATE                 DATE = NULL,
 @As_OtherParty_NAME          VARCHAR(60) = NULL OUTPUT,
 @An_OtherParty_IDNO          NUMERIC(9, 0) = NULL OUTPUT,
 @Ac_Attn_ADDR                CHAR(40) = NULL OUTPUT,
 @As_Line1_ADDR               VARCHAR(50) = NULL OUTPUT,
 @As_Line2_ADDR               VARCHAR(50) = NULL OUTPUT,
 @Ac_City_ADDR                CHAR(28) = NULL OUTPUT,
 @Ac_State_ADDR               CHAR(2) = NULL OUTPUT,
 @Ac_Zip_ADDR                 CHAR(15) = NULL OUTPUT,
 @Ac_Country_ADDR             CHAR(2) = NULL OUTPUT,
 @An_Phone_NUMB               NUMERIC(15) = NULL OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) = NULL OUTPUT,
 @Ad_Due_DATE                 DATE = NULL OUTPUT,
 @An_TransactionEventSeq_NUMB NUMERIC(19) = NULL OUTPUT,
 @As_Ivd_Director_NAME        VARCHAR(60) = NULL OUTPUT,
 @Ac_Msg_CODE                 CHAR (5) = '' OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR (4000) = '' OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT         CHAR = ' ',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_Role_ID            CHAR(10) = 'RS004',
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_GET_OTHP_INFO',
          @Ld_High_DATE          DATE = '12/31/9999';
  DECLARE @Ln_Zero_NUMB             NUMERIC = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Empty_TEXT            CHAR = '',
          @Ls_Sql_TEXT              VARCHAR(200) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ad_Run_DATE = ISNULL(@Ad_Run_DATE, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());
   SET @Ls_Sql_TEXT = 'SET DEFAULT VALUE';
   SET @Ls_Sqldata_TEXT = '';

   SELECT @Ac_Attn_ADDR = @Lc_Empty_TEXT,
          @As_Line1_ADDR = @Lc_Empty_TEXT,
          @As_Line2_ADDR = @Lc_Empty_TEXT,
          @Ac_City_ADDR = @Lc_Empty_TEXT,
          @Ac_State_ADDR = @Lc_Empty_TEXT,
          @Ac_Zip_ADDR = @Lc_Empty_TEXT,
          @Ac_Country_ADDR = @Lc_Empty_TEXT,
          @An_Phone_NUMB = @Ln_Zero_NUMB,
          @Ac_WorkerUpdate_ID = @Lc_Empty_TEXT,
          @Ad_Due_DATE = DATEADD(D, 30, @Ad_Run_DATE),
          @An_TransactionEventSeq_NUMB = 0,
          @As_Ivd_Director_NAME = @Lc_Empty_TEXT;

   SET @Ls_Sql_TEXT = 'SET AGENCY INFORMATION';
   SET @Ls_Sqldata_TEXT = 'OtherParty_IDNO = ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR), '') + ', OtherParty_NAME = ' + ISNULL(@As_OtherParty_NAME, '');

   SELECT @As_OtherParty_NAME = LTRIM(RTRIM(ISNULL(X.OtherParty_NAME, @Lc_Empty_TEXT))),
          @An_OtherParty_IDNO = ISNULL(X.OtherParty_IDNO, 0),
          @Ac_Attn_ADDR = LTRIM(RTRIM(ISNULL(X.Attn_ADDR, @Lc_Empty_TEXT))),
          @As_Line1_ADDR = LTRIM(RTRIM(ISNULL(X.Line1_ADDR, @Lc_Empty_TEXT))),
          @As_Line2_ADDR = LTRIM(RTRIM(ISNULL(X.Line2_ADDR, @Lc_Empty_TEXT))),
          @Ac_City_ADDR = LTRIM(RTRIM(ISNULL(X.City_ADDR, @Lc_Empty_TEXT))),
          @Ac_State_ADDR = LTRIM(RTRIM(ISNULL(X.State_ADDR, @Lc_Empty_TEXT))),
          @Ac_Zip_ADDR = LTRIM(RTRIM(ISNULL(X.Zip_ADDR, @Lc_Empty_TEXT))),
          @Ac_Country_ADDR = LTRIM(RTRIM(ISNULL(X.Country_ADDR, @Lc_Empty_TEXT))),
          @An_Phone_NUMB = ISNULL(X.Phone_NUMB, 0),
          @Ac_WorkerUpdate_ID = LTRIM(RTRIM(ISNULL(X.WorkerUpdate_ID, @Lc_Empty_TEXT))),
          @Ad_Due_DATE = DATEADD(D, 30, @Ad_Run_DATE),
          @An_TransactionEventSeq_NUMB = ISNULL((SELECT TOP 1 C.TransactionEventSeq_NUMB
                                                   FROM USRL_Y1 A,
                                                        USEM_Y1 B,
                                                        USES_Y1 C
                                                  WHERE A.Role_ID = @Lc_Role_ID
                                                    AND A.EndValidity_DATE = @Ld_High_DATE
                                                    AND A.Expire_DATE = @Ld_High_DATE
                                                    AND B.Worker_ID = A.Worker_ID
                                                    AND B.EndValidity_DATE = @Ld_High_DATE
                                                    AND C.Worker_ID = B.Worker_ID), 0),
          @As_Ivd_Director_NAME = ISNULL((SELECT TOP 1 CASE
                                                        WHEN LEN(LTRIM(RTRIM(ISNULL(B.First_NAME, '')))) = 0
                                                         THEN @Lc_Empty_TEXT
                                                        WHEN LEN(LTRIM(RTRIM(ISNULL(B.Last_NAME, '')))) = 0
                                                         THEN LTRIM(RTRIM(B.First_NAME))
                                                        WHEN LEN(LTRIM(RTRIM(ISNULL(B.Middle_NAME, '')))) = 0
                                                         THEN LTRIM(RTRIM(B.First_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(B.Last_NAME))
                                                        ELSE
                                                         CASE
                                                          WHEN LEN(LTRIM(RTRIM(ISNULL(B.Suffix_NAME, '')))) = 0
                                                           THEN LTRIM(RTRIM(B.First_NAME)) + @Lc_Space_TEXT + LEFT(LTRIM(RTRIM(B.Middle_NAME)), 1) + @Lc_Space_TEXT + LTRIM(RTRIM(B.Last_NAME))
                                                          ELSE LTRIM(RTRIM(B.First_NAME)) + @Lc_Space_TEXT + LEFT(LTRIM(RTRIM(B.Middle_NAME)), 1) + @Lc_Space_TEXT + LTRIM(RTRIM(B.Last_NAME)) + @Lc_Space_TEXT + LTRIM(RTRIM(B.Suffix_NAME))
                                                         END
                                                       END
                                            FROM USRL_Y1 A,
                                                 USEM_Y1 B
                                           WHERE A.Role_ID = @Lc_Role_ID
                                             AND A.EndValidity_DATE = @Ld_High_DATE
                                             AND A.Expire_DATE = @Ld_High_DATE
                                             AND B.Worker_ID = A.Worker_ID
                                             AND B.EndValidity_DATE = @Ld_High_DATE), '')
     FROM OTHP_Y1 X
    WHERE ((ISNULL(@An_OtherParty_IDNO, 0) > 0
        AND X.OtherParty_IDNO = @An_OtherParty_IDNO)
        OR (ISNULL(@An_OtherParty_IDNO, 0) = 0
            AND UPPER(LTRIM(RTRIM(X.OtherParty_NAME))) = UPPER(LTRIM(RTRIM(@As_OtherParty_NAME)))
            AND X.EndValidity_DATE = @Ld_High_DATE
            AND X.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(Y.TransactionEventSeq_NUMB)
                                                FROM OTHP_Y1 Y
                                               WHERE UPPER(LTRIM(RTRIM(Y.OtherParty_NAME))) = UPPER(LTRIM(RTRIM(X.OtherParty_NAME)))
                                                 AND Y.EndValidity_DATE = @Ld_High_DATE)));

   SELECT @As_OtherParty_NAME = ISNULL(@As_OtherParty_NAME, @Lc_Empty_TEXT),
          @An_OtherParty_IDNO = ISNULL(@An_OtherParty_IDNO, @Ln_Zero_NUMB);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
