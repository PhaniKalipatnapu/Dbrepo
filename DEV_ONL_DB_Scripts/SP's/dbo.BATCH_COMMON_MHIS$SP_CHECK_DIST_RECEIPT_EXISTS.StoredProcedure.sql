/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_MHIS$SP_CHECK_DIST_RECEIPT_EXISTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*  
--------------------------------------------------------------------------------------------------------------------  
Procedure Name  : BATCH_COMMON_MHIS$SP_CHECK_DIST_RECEIPT_EXISTS
Programmer Name : IMP Team  
Description		: Check Dist Receipt Exists
Frequency		:   
Developed On	: 04/12/2011
Called By		: 
Called On		:  
--------------------------------------------------------------------------------------------------------------------  
Modified By		:  
Modified On		:  
Version No		: 1.0   
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_MHIS$SP_CHECK_DIST_RECEIPT_EXISTS]
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @An_Case_IDNO             NUMERIC(6, 0),
 @Ad_Start_DATE            DATETIME2(0),
 @Ad_End_DATE              DATETIME2(0),
 @Ac_TypeWelfare_CODE      CHAR(1),
 @Ac_LastRec_TEXT          CHAR(1),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  DECLARE  @Li_ManuallyDistributeReceipt1810_NUMB  INT = 1810,
           @Li_ReceiptDistributed1820_NUMB         INT = 1820,
           @Li_FutureHoldRelease1825_NUMB          INT = 1825,
           @Lc_RecordExists_TEXT                   CHAR(1) = 'N',
           @Lc_MemberStatus_CODE                   CHAR(1) = 'N',
           @Lc_MsgDistRecp_CODE                    CHAR(1) = 'R',
           @Lc_CaseRelationshipDp_CODE             CHAR(1) = 'D',
           @Lc_StatusFailed_CODE                   CHAR(1) = 'F',
           @Lc_CaseMemberStatusActive_CODE         CHAR(1) = 'A',
           @Lc_TypeRecordOriginal_CODE             CHAR(1) = 'O',
           @Lc_Yes_INDC                            CHAR(1) = 'Y',
           @Lc_DateFormatYyyymm_CODE               CHAR(6) = 'YYYYMM',
           @Ls_Procedure_NAME                      VARCHAR(100) = 'SP_CHECK_DIST_RECEIPT_EXISTS',
           @Ld_High_DATE                           DATE = '12/31/9999',
           @Ld_Low_DATE                            DATE = '01/01/0001';
  DECLARE  @Ln_FetchStatus_NUMB            NUMERIC,
           @Ln_RowCount_QNTY               NUMERIC,
           @Ln_Error_NUMB                  NUMERIC(11,0),
           @Ln_ErrorLine_NUMB              NUMERIC(11,0),
           @Ls_Routine_TEXT                VARCHAR(60),
           @Ls_Sql_TEXT                    VARCHAR(100),
           @Ls_Sqldata_TEXT                VARCHAR(200),
           @Ld_Receipt_DATE                DATE,
           @Ld_End_DATE                    DATE,
           @Ld_Start_DATE                  DATETIME2;
  DECLARE  @Lc_PgmTypCur_TypeWelfare_CODE  CHAR(1);           

  BEGIN TRY
   SET @Ac_Msg_CODE = 'S';
   SET @As_DescriptionError_TEXT = '';

   DECLARE PgmTyp_CUR INSENSITIVE CURSOR FOR
    SELECT MH.TYPEWELFARE_CODE
      FROM MHIS_Y1 MH
     WHERE MH.MEMBERMCI_IDNO = @An_MemberMci_IDNO
       AND MH.CASE_IDNO = @An_Case_IDNO
       AND (@Ad_Start_DATE BETWEEN MH.START_DATE AND MH.END_DATE
             OR @Ad_End_DATE BETWEEN MH.START_DATE AND MH.END_DATE);

   SET @Ls_Routine_TEXT = 'Sp_check_dist_receipt_exists';
   SET @Ld_End_DATE = ISNULL(@Ad_End_DATE, @Ld_High_DATE);

   IF @Ac_LastRec_TEXT = 'Y'
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT MHIS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

     SELECT @Ld_Start_DATE = ISNULL(MIN(MH.Start_DATE), @Ad_Start_DATE)
       FROM MHIS_Y1 MH
      WHERE MH.MemberMci_IDNO = @An_MemberMci_IDNO
        AND MH.Case_IDNO = @An_Case_IDNO
        AND MH.Start_DATE < @Ad_Start_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ld_Start_DATE = @Ad_Start_DATE;
      END
     ELSE
      BEGIN
       IF @Ld_Start_DATE < @Ad_Start_DATE
        BEGIN
         IF @Ad_End_DATE = @Ld_High_DATE
          BEGIN
           SET @Ld_End_DATE = DATEADD(D, -1, @Ad_Start_DATE);
          END

         SET @Lc_MemberStatus_CODE = 'Y';

         GOTO Checkrcpts;
        END
      END

     OPEN PgmTyp_CUR;

     FETCH NEXT FROM PgmTyp_CUR INTO @Lc_PgmTypCur_TypeWelfare_CODE;

     SET @Ln_FetchStatus_NUMB = @@FETCH_STATUS;

     --
     WHILE @Ln_FetchStatus_NUMB = 0
      BEGIN
       SET @Lc_RecordExists_TEXT = 'Y';

       IF @Lc_PgmTypCur_TypeWelfare_CODE != @Ac_TypeWelfare_CODE
        BEGIN
         SET @Lc_MemberStatus_CODE = 'Y';
        END

       FETCH NEXT FROM PgmTyp_CUR INTO @Lc_PgmTypCur_TypeWelfare_CODE;

       SET @Ln_FetchStatus_NUMB = @@FETCH_STATUS;
      END

     CLOSE PgmTyp_CUR;

     DEALLOCATE PgmTyp_CUR;

     IF @Lc_RecordExists_TEXT = 'N'
      BEGIN
       SET @Lc_MemberStatus_CODE = 'Y';
      END

     CHECKRCPTS:;

     IF @Lc_MemberStatus_CODE = 'N'
      BEGIN
       SET @Ac_Msg_CODE = 'S';
      END
     ELSE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_LSUP,SELECT_OBLE';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipDp_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

       SELECT TOP 1 @Ld_Receipt_DATE = b.Receipt_DATE
         FROM OBLE_Y1 a,
              LSUP_Y1 b
        WHERE a.Case_IDNO = @An_Case_IDNO
          AND (a.MemberMci_IDNO = @An_MemberMci_IDNO
                OR a.MemberMci_IDNO IN (SELECT c.MemberMci_IDNO
                                          FROM CMEM_Y1 c
                                         WHERE c.Case_IDNO = @An_Case_IDNO
                                           AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
                                           AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE))
          AND a.BeginObligation_DATE = (SELECT MAX(c.BeginObligation_DATE)
                                          FROM OBLE_Y1 c
                                         WHERE c.Case_IDNO = a.Case_IDNO
                                           AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                           AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                           AND c.EndValidity_DATE = @Ld_High_DATE)
          AND a.EndValidity_DATE = @Ld_High_DATE
          AND b.Case_IDNO = @An_Case_IDNO
          AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
          AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
          AND b.Batch_DATE <> @Ld_Low_DATE
          AND b.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB, @Li_FutureHoldRelease1825_NUMB)
          AND b.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
          AND ((CAST(b.SupportYearMonth_NUMB AS VARCHAR(MAX)) = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(b.Distribute_DATE, @Lc_DateFormatYyyymm_CODE)
                AND (b.Distribute_DATE BETWEEN @Ad_Start_DATE AND ISNULL(@Ad_End_DATE, dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()))))
                OR (CAST(b.SupportYearMonth_NUMB AS VARCHAR(MAX)) != dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(b.Distribute_DATE, @Lc_DateFormatYyyymm_CODE)
                    AND b.SupportYearMonth_NUMB BETWEEN dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ad_Start_DATE, @Lc_DateFormatYyyymm_CODE) AND dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(ISNULL(@Ad_End_DATE, dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())), @Lc_DateFormatYyyymm_CODE)))
          AND NOT EXISTS (SELECT 1
                            FROM RCTH_Y1 d
                           WHERE d.Batch_DATE = b.Batch_DATE
                             AND d.SourceBatch_CODE = b.SourceBatch_CODE
                             AND d.Batch_NUMB = b.Batch_NUMB
                             AND d.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                             AND d.EndValidity_DATE = @Ld_High_DATE
                             AND d.BackOut_INDC = @Lc_Yes_INDC);

       IF @Ld_Receipt_DATE IS NOT NULL
        BEGIN
         SET @Ac_Msg_CODE = @Lc_MsgDistRecp_CODE;
        END
       ELSE
        BEGIN
         IF @Ld_Receipt_DATE = NULL
          BEGIN
           IF @Ac_LastRec_TEXT = 'Y'
              AND @Ad_End_DATE = @Ld_High_DATE
              AND @Lc_MemberStatus_CODE = 'N'
              AND @Ld_Start_DATE = @Ad_Start_DATE
            BEGIN
             OPEN PgmTyp_CUR;

             FETCH NEXT FROM PgmTyp_CUR INTO @Lc_PgmTypCur_TypeWelfare_CODE;

             SET @Ln_FetchStatus_NUMB = @@FETCH_STATUS;

             --
             WHILE @Ln_FetchStatus_NUMB = 0
              BEGIN
               SET @Lc_RecordExists_TEXT = 'Y';

               IF @Lc_PgmTypCur_TypeWelfare_CODE != @Ac_TypeWelfare_CODE
                BEGIN
                 SET @Lc_MemberStatus_CODE = 'Y';
                END

               FETCH NEXT FROM PgmTyp_CUR INTO @Lc_PgmTypCur_TypeWelfare_CODE;

               SET @Ln_FetchStatus_NUMB = @@FETCH_STATUS;
              END

             CLOSE PgmTyp_CUR;

             DEALLOCATE PgmTyp_CUR;

             IF @Lc_RecordExists_TEXT = 'N'
              BEGIN
               SET @Lc_MemberStatus_CODE = 'Y';
              END

             IF @Lc_MemberStatus_CODE = 'N'
              BEGIN
               SET @Ac_Msg_CODE = 'S';
              END
             ELSE
              BEGIN
               SET @Ls_Sql_TEXT = 'SELECT_LSUP,SELECT_OBLE';
               SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', CaseRelationship_CODE = ' + ISNULL(@Lc_CaseRelationshipDp_CODE, '') + ', CaseMemberStatus_CODE = ' + ISNULL(@Lc_CaseMemberStatusActive_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', TypeRecord_CODE = ' + ISNULL(@Lc_TypeRecordOriginal_CODE, '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', BackOut_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

               SELECT TOP 1 @Ld_Receipt_DATE = b.Receipt_DATE
                 FROM OBLE_Y1 a,
                      LSUP_Y1 b
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND (a.MemberMci_IDNO = @An_MemberMci_IDNO
                        OR a.MemberMci_IDNO IN (SELECT c.MemberMci_IDNO
                                                  FROM CMEM_Y1 c
                                                 WHERE c.Case_IDNO = @An_Case_IDNO
                                                   AND c.CaseRelationship_CODE = @Lc_CaseRelationshipDp_CODE
                                                   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE))
                  AND a.BeginObligation_DATE = (SELECT MAX(c.BeginObligation_DATE)
                                                  FROM OBLE_Y1 c
                                                 WHERE c.Case_IDNO = a.Case_IDNO
                                                   AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                   AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                   AND c.EndValidity_DATE = @Ld_High_DATE)
                  AND a.EndValidity_DATE = @Ld_High_DATE
                  AND b.Case_IDNO = @An_Case_IDNO
                  AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                  AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                  AND b.Batch_DATE <> @Ld_Low_DATE
                  AND b.EventFunctionalSeq_NUMB IN (@Li_ManuallyDistributeReceipt1810_NUMB, @Li_ReceiptDistributed1820_NUMB, @Li_FutureHoldRelease1825_NUMB)
                  AND b.TypeRecord_CODE = @Lc_TypeRecordOriginal_CODE
                  AND ((CAST(b.SupportYearMonth_NUMB AS VARCHAR(max)) = dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(b.Distribute_DATE, @Lc_DateFormatYyyymm_CODE)
                        AND (b.Distribute_DATE BETWEEN @Ad_Start_DATE AND ISNULL(@Ad_End_DATE, dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()))))
                        OR (CAST(b.SupportYearMonth_NUMB AS VARCHAR(max)) != dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(b.Distribute_DATE, @Lc_DateFormatYyyymm_CODE)
                            AND b.SupportYearMonth_NUMB BETWEEN dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ad_Start_DATE, @Lc_DateFormatYyyymm_CODE) AND dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(ISNULL(@Ad_End_DATE, dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME())), @Lc_DateFormatYyyymm_CODE)))
                  AND NOT EXISTS (SELECT 1
                                    FROM RCTH_Y1 d
                                   WHERE d.Batch_DATE = b.Batch_DATE
                                     AND d.SourceBatch_CODE = b.SourceBatch_CODE
                                     AND d.Batch_NUMB = b.Batch_NUMB
                                     AND d.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                                     AND d.EndValidity_DATE = @Ld_High_DATE
                                     AND d.BackOut_INDC = @Lc_Yes_INDC);

               IF @Ld_Receipt_DATE IS NULL
                BEGIN
                 SET @Ac_Msg_CODE = 'S';
                END
              END
            END
           ELSE
            BEGIN
             SET @Ac_Msg_CODE = 'S';
            END
          END
        END
      END
    END
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('LOCAL', 'PgmTyp_CUR') IN (0, 1)
    BEGIN
     CLOSE PgmTyp_CUR;

     DEALLOCATE PgmTyp_CUR;
    END

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
  END CATCH
 END 

GO
