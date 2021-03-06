/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_OFFSET_PROCESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_OFFSET_PROCESS
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_OFFSET_PROCESS is 
					  to insert into ISTX_Y1 and preoffset table
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_OFFSET_PROCESS]
 @Ad_Run_DATE              DATE,
 @An_TaxYear_NUMB          NUMERIC(4),
 @Ac_Job_ID                CHAR(07),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
          @Lc_StatusFailed_CODE   CHAR(1) = 'F',
          @Lc_TypeError_CODE      CHAR(1) = 'E',
          @Lc_BateErrorE1424_CODE CHAR(5) = 'E1424',
          @Lc_Job_ID              CHAR(7) = @Ac_Job_ID,
          @Ls_Procedure_NAME      VARCHAR(100) = 'SP_OFFSET_PROCESS',
          @Ls_Process_NAME        VARCHAR(100) = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET',
          @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE @Ln_RecordCount_QNTY      NUMERIC(10, 0) = 0,
          @Ln_TaxYear_NUMB          NUMERIC(4) = @An_TaxYear_NUMB,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Li_FetchStatus_QNTY      SMALLINT,
          @Lc_Empty_TEXT            CHAR = '',
          @Lc_Msg_CODE              CHAR(5),
          @Lc_TypeTransaction_CODE  CHAR(1),
          @Lc_BateError_CODE        CHAR(5),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ls_BateRecord_TEXT       VARCHAR(4000),
          @Ld_Run_DATE              DATE = @Ad_Run_DATE;
  DECLARE @Ln_OffsetCur_MemberMci_IDNO        NUMERIC(10),
          @Ln_OffsetCur_Case_IDNO             NUMERIC(6),
          @Ln_OffsetCur_NonTanfArrear_AMNT    NUMERIC(11, 2),
          @Ln_OffsetCur_TanfArrear_AMNT       NUMERIC(11, 2),
          @Lc_OffsetCur_NonTanfCertified_INDC CHAR(01),
          @Lc_OffsetCur_TanfCertified_INDC    CHAR(01),
          @Ld_OffsetCur_Notice_DATE           DATE,
          @Ln_OffsetCur_MemberSsn_NUMB        NUMERIC(09),
          @Lc_OffsetCur_County_CODE           CHAR(3);
  DECLARE Offset_CUR INSENSITIVE CURSOR FOR
   SELECT B.MemberMci_IDNO,
          A.County_CODE,
          A.Case_IDNO,
          A.MemberSsn_NUMB,
          B.TanfArrear_AMNT,
          B.NonTanfArrear_AMNT,
          B.NonTanfCertified_INDC,
          B.TanfCertified_INDC,
          B.Notice_DATE
     FROM #GetEligibleCases_P1 A,
          #CalculateCaseArrears_P1 B
    WHERE A.Case_IDNO = B.Case_IDNO
      AND A.MemberMci_IDNO = B.MemberMci_IDNO
    ORDER BY A.MemberMci_IDNO,
             A.Case_IDNO;

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'OPEN Offset_CUR';

   OPEN Offset_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Offset_CUR - 1';

   FETCH NEXT FROM Offset_CUR INTO @Ln_OffsetCur_MemberMci_IDNO, @Lc_OffsetCur_County_CODE, @Ln_OffsetCur_Case_IDNO, @Ln_OffsetCur_MemberSsn_NUMB, @Ln_OffsetCur_TanfArrear_AMNT, @Ln_OffsetCur_NonTanfArrear_AMNT, @Lc_OffsetCur_NonTanfCertified_INDC, @Lc_OffsetCur_TanfCertified_INDC, @Ld_OffsetCur_Notice_DATE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH Offset_CUR';

   --
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     BEGIN TRY
      SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
      SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
      SET @Ls_BateRecord_TEXT = 'MemberMci_IDNO = ' + CAST(@Ln_OffsetCur_MemberMci_IDNO AS VARCHAR) + ', CountyFips_CODE = ' + @Lc_OffsetCur_County_CODE + ', Case_IDNO = ' + CAST(@Ln_OffsetCur_Case_IDNO AS VARCHAR) + ', MemberSsn_NUMB = ' + CAST(@Ln_OffsetCur_MemberSsn_NUMB AS VARCHAR) + ', TanfArrear_AMNT = ' + CAST(@Ln_OffsetCur_TanfArrear_AMNT AS VARCHAR) + ', NonTanfArrear_AMNT = ' + CAST(@Ln_OffsetCur_NonTanfArrear_AMNT AS VARCHAR) + ', NonTanfCertified_INDC = ' + @Lc_OffsetCur_NonTanfCertified_INDC + ', TanfCertified_INDC = ' + @Lc_OffsetCur_TanfCertified_INDC + ', Notice_DATE = ' + CAST(@Ld_OffsetCur_Notice_DATE AS VARCHAR);
      SET @Ls_Sql_TEXT = 'CHECK FOR PREOFFSET NOTICE';

      IF (((@Ln_OffsetCur_NonTanfArrear_AMNT + @Ln_OffsetCur_TanfArrear_AMNT) >= 150
           AND ((@Lc_OffsetCur_NonTanfCertified_INDC = 'N'
                 AND @Lc_OffsetCur_TanfCertified_INDC = 'N'
                 AND @Ld_OffsetCur_Notice_DATE = @Ld_High_DATE)
                 OR (NOT EXISTS (SELECT 1
                                   FROM ISTX_Y1 X
                                  WHERE X.Case_IDNO = @Ln_OffsetCur_Case_IDNO
                                    AND X.MemberMci_IDNO = @Ln_OffsetCur_MemberMci_IDNO))
                 OR (EXISTS (SELECT 1
                               FROM ISTX_Y1 X
                              WHERE X.Case_IDNO = @Ln_OffsetCur_Case_IDNO
                                AND X.MemberMci_IDNO = @Ln_OffsetCur_MemberMci_IDNO
                                AND 0 >= ISNULL ((SELECT SUM(ISNULL(C.Transaction_AMNT, 0))
                                                    FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY A.MemberMci_IDNO, A.Case_IDNO, A.TypeArrear_CODE ORDER BY A.MemberMci_IDNO, A.Case_IDNO, A.SubmitLast_DATE DESC ),
                                                                 A.*
                                                            FROM ISTX_Y1 A
                                                           WHERE A.MemberMci_IDNO = X.MemberMci_IDNO
                                                             AND A.Case_IDNO = X.Case_IDNO) C
                                                   WHERE C.Row_NUMB = 1
                                                   GROUP BY C.MemberMci_IDNO,
                                                            C.Case_IDNO), 0))
                     AND (@Lc_OffsetCur_NonTanfCertified_INDC = 'N'
                           OR @Lc_OffsetCur_TanfCertified_INDC = 'N'))))
           OR ((@Ln_OffsetCur_NonTanfArrear_AMNT + @Ln_OffsetCur_TanfArrear_AMNT) > 0
               AND EXISTS (SELECT 1
                             FROM ISTX_Y1 X
                            WHERE X.Case_IDNO = @Ln_OffsetCur_Case_IDNO
                              AND X.MemberMci_IDNO = @Ln_OffsetCur_MemberMci_IDNO
                              AND 0 < ISNULL ((SELECT SUM(ISNULL(C.Transaction_AMNT, 0))
                                                 FROM (SELECT Row_NUMB = ROW_NUMBER() OVER ( PARTITION BY A.MemberMci_IDNO, A.Case_IDNO, A.TypeArrear_CODE ORDER BY A.MemberMci_IDNO, A.Case_IDNO, A.SubmitLast_DATE DESC ),
                                                              A.*
                                                         FROM ISTX_Y1 A
                                                        WHERE A.MemberMci_IDNO = X.MemberMci_IDNO
                                                          AND A.Case_IDNO = X.Case_IDNO) C
                                                WHERE C.Row_NUMB = 1
                                                GROUP BY C.MemberMci_IDNO,
                                                         C.Case_IDNO), 0))
               AND DATEDIFF(D, @Ld_OffsetCur_Notice_DATE, @Ld_Run_DATE) >= 365
               AND (@Lc_OffsetCur_NonTanfCertified_INDC = 'Y'
                     OR @Lc_OffsetCur_TanfCertified_INDC = 'Y')))
       BEGIN
        SET @Lc_TypeTransaction_CODE = 'L';
        SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_PREOFFSET';
        SET @Ls_SqlData_TEXT = '';

        EXEC BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_PREOFFSET
         @An_MemberMci_IDNO        = @Ln_OffsetCur_MemberMci_IDNO,
         @An_Case_IDNO             = @Ln_OffsetCur_Case_IDNO,
         @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
         @Ad_Run_DATE              = @Ld_Run_DATE,
         @An_MemberSsn_NUMB        = @Ln_OffsetCur_MemberSsn_NUMB,
         @An_NonTanfArrear_AMNT    = @Ln_OffsetCur_NonTanfArrear_AMNT,
         @An_TanfArrear_AMNT       = @Ln_OffsetCur_TanfArrear_AMNT,
         @Ac_NonTanfCertified_INDC = @Lc_OffsetCur_NonTanfCertified_INDC,
         @Ac_TanfCertified_INDC    = @Lc_OffsetCur_TanfCertified_INDC,
         @Ac_TypeTransaction_CODE  = @Lc_TypeTransaction_CODE,
         @Ac_CountyFips_CODE       = @Lc_OffsetCur_County_CODE,
         @Ac_Job_ID                = @Lc_Job_ID,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END;
       END
      ELSE
       BEGIN
        SET @Ls_Sql_TEXT = 'BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_CERTIFICATION';
        SET @Ls_SqlData_TEXT = '';

        EXEC BATCH_ENF_OUTGOING_STATE_TAX_OFFSET$SP_INSERT_CERTIFICATION
         @An_MemberMci_IDNO        = @Ln_OffsetCur_MemberMci_IDNO,
         @An_Case_IDNO             = @Ln_OffsetCur_Case_IDNO,
         @An_TaxYear_NUMB          = @Ln_TaxYear_NUMB,
         @Ad_Run_DATE              = @Ld_Run_DATE,
         @An_MemberSsn_NUMB        = @Ln_OffsetCur_MemberSsn_NUMB,
         @An_NonTanfArrear_AMNT    = @Ln_OffsetCur_NonTanfArrear_AMNT,
         @An_TanfArrear_AMNT       = @Ln_OffsetCur_TanfArrear_AMNT,
         @Ac_NonTanfCertified_INDC = @Lc_OffsetCur_NonTanfCertified_INDC,
         @Ac_TanfCertified_INDC    = @Lc_OffsetCur_TanfCertified_INDC,
         @Ad_Notice_DATE           = @Ld_OffsetCur_Notice_DATE,
         @Ac_CountyFips_CODE       = @Lc_OffsetCur_County_CODE,
         @Ac_Job_ID                = @Lc_Job_ID,
         @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

        IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
          SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

          RAISERROR(50001,16,1);
         END;
       END
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

      SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';

      EXECUTE BATCH_COMMON$SP_BATE_LOG
       @As_Process_NAME             = @Ls_Process_NAME,
       @As_Procedure_NAME           = @Ls_Procedure_NAME,
       @Ac_Job_ID                   = @Lc_Job_ID,
       @Ad_Run_DATE                 = @Ld_Run_DATE,
       @Ac_TypeError_CODE           = @Lc_TypeError_CODE,
       @An_Line_NUMB                = @Ln_RecordCount_QNTY,
       @Ac_Error_CODE               = @Lc_BateError_CODE,
       @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT,
       @As_ListKey_TEXT             = @Ls_BateRecord_TEXT,
       @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
       @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

      IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
       BEGIN
        SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

        RAISERROR(50001,16,1);
       END;
     END CATCH;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM Offset_CUR - 2';

     FETCH NEXT FROM Offset_CUR INTO @Ln_OffsetCur_MemberMci_IDNO, @Lc_OffsetCur_County_CODE, @Ln_OffsetCur_Case_IDNO, @Ln_OffsetCur_MemberSsn_NUMB, @Ln_OffsetCur_TanfArrear_AMNT, @Ln_OffsetCur_NonTanfArrear_AMNT, @Lc_OffsetCur_NonTanfCertified_INDC, @Lc_OffsetCur_TanfCertified_INDC, @Ld_OffsetCur_Notice_DATE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   SET @Ls_Sql_TEXT = 'CLOSE Offset_CUR';

   CLOSE Offset_CUR;

   SET @Ls_Sql_TEXT = 'DEALLOCATE Offset_CUR';

   DEALLOCATE Offset_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Empty_TEXT;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS('Local', 'Offset_CUR') IN (0, 1)
    BEGIN
     CLOSE Offset_CUR;

     DEALLOCATE Offset_CUR;
    END;

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
 END;


GO
