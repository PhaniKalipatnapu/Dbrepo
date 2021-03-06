/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS
Programmer Name		 : IMP Team
Description			 : The procedure inserts record into VFPRJ table if
                       the fcr acknowledge code for a record is REJCT.
Frequency			 : Daily
Developed On		 : 04/07/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_CASE_ACK_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_PERSON_ACK_DETAILS
Called On			 : 
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_INSERT_REJCT_DETAILS]
 @Ad_Run_DATE              DATE,
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_Action_CODE           CHAR(1),
 @Ac_Error1_CODE           CHAR(5),
 @Ac_Error2_CODE           CHAR(5),
 @Ac_Error3_CODE           CHAR(5),
 @Ac_Error4_CODE           CHAR(5),
 @Ac_Error5_CODE           CHAR(5),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_Space_TEXT          CHAR(1) = ' ',
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_Reject_CODE         CHAR(1) = 'R',
           @Ls_Procedure_NAME      VARCHAR(60) = 'SP_INSERT_REJCT_DETAILS',
           @Ld_Low_DATE            DATE = '01/01/0001';
  DECLARE  @Ln_Exists_NUMB         NUMERIC(1) = 0,
		   @Ln_Error_NUMB          NUMERIC(11),
           @Ln_ErrorLine_NUMB      NUMERIC(11),
           @Li_RowCount_QNTY       SMALLINT,
           @Ls_Sql_TEXT            VARCHAR(100),
           @Ls_Sqldata_TEXT        VARCHAR(1000),
           @Ls_ErrorMessage_TEXT   VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE IN FPRJ_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR (10)), 0) + ', Action_CODE = ' + ISNULL(@Ac_Action_CODE, '');
  
   SELECT @Ln_Exists_NUMB = COUNT(1)
     FROM FPRJ_Y1 f
    WHERE f.Case_IDNO = @An_Case_IDNO
      AND f.MemberMci_IDNO = @An_MemberMci_IDNO;

   IF @Ln_Exists_NUMB = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT INTO FPRJ_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), 0) +  ', MemberMci_IDNO = ' + ISNULL (CAST(@An_MemberMci_IDNO AS VARCHAR), 0);

     INSERT FPRJ_Y1
            (Case_IDNO,
             MemberMci_IDNO,
             Action_CODE,
             Reject_CODE,
             Transmitted_DATE,
             Received_DATE,
             Error1_CODE,
             Error2_CODE,
             Error3_CODE,
             Error4_CODE,
             Error5_CODE)
     VALUES ( @An_Case_IDNO, -- Case_IDNO
              @An_MemberMci_IDNO, -- MemberMci_IDNO
              @Ac_Action_CODE, -- Action_CODE
              @Lc_Reject_CODE, -- Reject_CODE
              @Ld_Low_DATE, -- Transmitted_DATE
              @Ad_Run_DATE, -- Received_DATE
              ISNULL(@Ac_Error1_CODE, @Lc_Space_TEXT),  -- Error1_CODE
              ISNULL(@Ac_Error2_CODE, @Lc_Space_TEXT),  -- Error2_CODE
              ISNULL(@Ac_Error3_CODE, @Lc_Space_TEXT),  -- Error3_CODE
              ISNULL(@Ac_Error4_CODE, @Lc_Space_TEXT),  -- Error4_CODE
              ISNULL(@Ac_Error5_CODE, @Lc_Space_TEXT)); -- Error5_CODE

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT FAILED FADT_Y1';

       RAISERROR(50001,16,1);
      END
    END
   ELSE
    BEGIN
     SET @Ls_Sql_TEXT = 'UPDATE FPRJ_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), 0);

     UPDATE FPRJ_Y1
        SET Action_CODE = @Ac_Action_CODE,
            Reject_CODE = @Lc_Reject_CODE,
            Transmitted_DATE = @Ld_Low_DATE,
            Received_DATE = @Ad_Run_DATE,
            Error1_CODE = ISNULL(@Ac_Error1_CODE, @Lc_Space_TEXT),
            Error2_CODE = ISNULL(@Ac_Error2_CODE, @Lc_Space_TEXT),
            Error3_CODE = ISNULL(@Ac_Error3_CODE, @Lc_Space_TEXT),
            Error4_CODE = ISNULL(@Ac_Error4_CODE, @Lc_Space_TEXT),
            Error5_CODE = ISNULL(@Ac_Error5_CODE, @Lc_Space_TEXT)
      WHERE FPRJ_Y1.Case_IDNO = @An_Case_IDNO
        AND FPRJ_Y1.MemberMci_IDNO = @An_MemberMci_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FAILED FPRJ_Y1';

       RAISERROR(50001,16,1);
      END
    END

   -- Set the status code to success and error description to spaces
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   --Set Error Description
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

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
