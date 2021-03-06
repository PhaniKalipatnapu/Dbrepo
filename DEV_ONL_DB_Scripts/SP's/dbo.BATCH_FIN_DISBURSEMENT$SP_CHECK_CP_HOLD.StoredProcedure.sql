/****** Object:  StoredProcedure [dbo].[BATCH_FIN_DISBURSEMENT$SP_CHECK_CP_HOLD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    :	BATCH_FIN_DISBURSEMENT$SP_CHECK_CP_HOLD
Programmer Name   :	Imp Team
Description       :	Procedure to find out whether any hold instruction available for the CP recipient.
Frequency         :	'DAILY'
Developed On      :	01/31/2012
Called BY         :	BATCH_FIN_DISBURSEMENT$SP_DISB_RECOUP
Called On		  :	NONE
-------------------------------------------------------------------------------------------------------------------						
Modified BY       :
Modified On       :
Version No        :	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_DISBURSEMENT$SP_CHECK_CP_HOLD]
 @An_Remaining_AMNT             NUMERIC (11, 2) OUTPUT,
 @Ac_Msg_CODE                   CHAR(1) OUTPUT,
 @Ab_ChldQueried_BIT            BIT OUTPUT,
 @Ac_ChldChkRecipient_ID        CHAR(10) OUTPUT,
 @Ac_CheckRecipient_ID          CHAR(10) OUTPUT,
 @Ac_ChldChkRecipient_CODE      CHAR (1) OUTPUT,
 @Ac_CheckRecipient_CODE        CHAR(1) OUTPUT,
 @An_Case_IDNO                  NUMERIC(6) OUTPUT,
 @Ad_Expire_DATE                DATE OUTPUT,
 @Ac_Reason_CODE                CHAR(5) OUTPUT,
 @Ad_Run_DATE                   DATE OUTPUT,
 @Ab_ChldExists_BIT             BIT OUTPUT,
 @An_OrderSeq_NUMB              NUMERIC(2) OUTPUT,
 @An_ObligationSeq_NUMB         NUMERIC(2) OUTPUT,
 @Ad_Batch_DATE                 DATE OUTPUT,
 @Ac_SourceBatch_CODE           CHAR(3) OUTPUT,
 @An_Batch_NUMB                 NUMERIC(4) OUTPUT,
 @An_SeqReceipt_NUMB            NUMERIC(6) OUTPUT,
 @An_EventGlobalSupportSeq_NUMB NUMERIC(19) OUTPUT,
 @Ac_TypeDisburse_CODE          CHAR(5) OUTPUT,
 @An_EventGlobalSeq_NUMB        NUMERIC(19) OUTPUT,
 @Ad_Disburse_DATE              DATE OUTPUT,
 @An_DisburseSeq_NUMB           NUMERIC(4) OUTPUT,
 @As_DescriptionError_TEXT      VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_PayeeHold1960_NUMB      INT = 1960,
          @Lc_Space_TEXT              CHAR = ' ',
          @Lc_RecipientTypeFips_CODE  CHAR(1) = '2',
          @Lc_RecipientTypeCpNcp_CODE CHAR(1) = '1',
          @Lc_RelationshipCaseCp_CODE CHAR(1) = 'C',
          @Lc_No_INDC                 CHAR(1) = 'N',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusH_CODE            CHAR(1) = 'H',
          @Lc_TypeHoldP_IDNO          CHAR(1) = 'P',
          @Lc_TypeEntityRctno_CODE    CHAR(30) = 'RCTNO',
          @Lc_TypeEntityCase_CODE     CHAR(30) = 'CASE',
          @Lc_TypeEntityRcpid_CODE    CHAR(30) = 'RCPID',
          @Lc_TypeEntityRcpcd_CODE    CHAR(30) = 'RCPCD',
          @Ls_Procedure_NAME          VARCHAR(100) = 'SP_CHECK_CP_HOLD',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE @Ln_RowCurrent_NUMB   NUMERIC(5) = 0,
          @Ln_Error_NUMB        NUMERIC(11),
          @Ln_ErrorLine_NUMB    NUMERIC(11),
          @Li_Rowcount_QNTY     SMALLINT,
          @Ls_Sql_TEXT          VARCHAR(100) = '',
          @Ls_Sqldata_TEXT      VARCHAR(1000) = '',
          @Ls_ErrorMessage_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';

   IF NOT @Ab_ChldQueried_BIT != 0
    BEGIN
     SET @Ac_ChldChkRecipient_ID = @Ac_CheckRecipient_ID;
     SET @Ac_ChldChkRecipient_CODE = @Ac_CheckRecipient_CODE;

     IF @Ac_CheckRecipient_CODE = @Lc_RecipientTypeFips_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT_CMEM_Y1 CD CHECK RCPT 2';
       SET @Ls_Sqldata_TEXT = '';

       SELECT TOP 1 @Ac_ChldChkRecipient_ID = x.MemberMci_IDNO,
                      @Ac_ChldChkRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE
         FROM (SELECT a.MemberMci_IDNO,
                      a.CaseMemberStatus_CODE
                 FROM CMEM_Y1 a
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.CaseRelationship_CODE = @Lc_RelationshipCaseCp_CODE) AS x
        ORDER BY 2;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         RAISERROR (50001,16,1);
        END;
      END;

     SET @Ls_Sql_TEXT = 'SELECT CHLD CASE LEVEL';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (@Ac_ChldChkRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_ChldChkRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '');

     SELECT @Ad_Expire_DATE = x.Expiration_DATE,
            @Ac_Reason_CODE = x.ReasonHold_CODE,
            @Ln_RowCurrent_NUMB = x.rn
       FROM (SELECT c.Expiration_DATE,
                    c.ReasonHold_CODE,
                    ROW_NUMBER () OVER ( PARTITION BY c.CheckRecipient_ID, c.CheckRecipient_CODE ORDER BY c.Expiration_DATE DESC) AS rn
               FROM CHLD_Y1 c
              WHERE c.CheckRecipient_ID = @Ac_ChldChkRecipient_ID
                AND c.CheckRecipient_CODE = @Ac_ChldChkRecipient_CODE
                AND c.Case_IDNO = @An_Case_IDNO
                AND @Ad_Run_DATE BETWEEN c.Effective_DATE AND DATEADD (D, -1, c.Expiration_DATE)
                AND c.EndValidity_DATE = @Ld_High_DATE) AS x
      WHERE x.rn = 1;

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;
     SET @Ab_ChldExists_BIT = 1;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT CHLD RECIPIENT LEVEL';
       SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL (@Ac_ChldChkRecipient_ID, '') + ', CheckRecipient_CODE = ' + ISNULL (@Ac_ChldChkRecipient_CODE, '');

       SELECT @Ad_Expire_DATE = x.Expiration_DATE,
              @Ac_Reason_CODE = x.ReasonHold_CODE
         FROM (SELECT c.Expiration_DATE,
                      c.ReasonHold_CODE,
                      ROW_NUMBER () OVER ( PARTITION BY c.CheckRecipient_ID, c.CheckRecipient_CODE ORDER BY c.Expiration_DATE DESC) AS rn
                 FROM CHLD_Y1 c
                WHERE c.CheckRecipient_ID = @Ac_ChldChkRecipient_ID
                  AND c.CheckRecipient_CODE = @Ac_ChldChkRecipient_CODE
                  AND c.Case_IDNO = 0
                  AND @Ad_Run_DATE BETWEEN c.Effective_DATE AND DATEADD (D, -1, c.Expiration_DATE)
                  AND c.EndValidity_DATE = @Ld_High_DATE) AS x
        WHERE x.rn = 1;

       SET @Li_Rowcount_QNTY = @@ROWCOUNT;
       SET @Ab_ChldExists_BIT = 1;

       IF (@Li_Rowcount_QNTY = 0)
        BEGIN
         SET @Ab_ChldExists_BIT = 0;
        END;
      END;
    END;

   IF @Ab_ChldExists_BIT != 0
    BEGIN
     SET @Ls_Sql_TEXT = 'INSERT_DHLD_CP_HOLD';
     SET @Ls_Sqldata_TEXT = 'CheckRecipient_ID = ' + ISNULL(CAST(@Ac_CheckRecipient_ID AS VARCHAR), '') + ', CheckRecipient_CODE = ' + ISNULL(@Ac_CheckRecipient_CODE, '') + ', Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR), '') + ', ObligationSeq_NUMB = ' + ISNULL(CAST(@An_ObligationSeq_NUMB AS VARCHAR), '') + ', Batch_DATE = ' + ISNULL(CAST(@Ad_Batch_DATE AS VARCHAR), '') + ', SourceBatch_CODE = ' + ISNULL(@Ac_SourceBatch_CODE, '') + ', Batch_NUMB = ' + ISNULL(CAST(@An_Batch_NUMB AS VARCHAR), '') + ', SeqReceipt_NUMB = ' + ISNULL(CAST(@An_SeqReceipt_NUMB AS VARCHAR), '') + ', EventGlobalSupportSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSupportSeq_NUMB AS VARCHAR), '') + ', TypeDisburse_CODE = ' + ISNULL(@Ac_TypeDisburse_CODE, '') + ', Transaction_AMNT = ' + ISNULL(CAST(@An_Remaining_AMNT AS VARCHAR), '') + ', Status_CODE = ' + ISNULL(@Lc_StatusH_CODE, '') + ', TypeHold_CODE = ' + ISNULL(@Lc_TypeHoldP_IDNO, '') + ', ProcessOffset_INDC = ' + ISNULL(@Lc_No_INDC, '') + ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', Release_DATE = ' + ISNULL(CAST(@Ad_Expire_DATE AS VARCHAR), '') + ', BeginValidity_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR), '') + ', EndValidity_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', EventGlobalEndSeq_NUMB = ' + ISNULL('0', '') + ', Disburse_DATE = ' + ISNULL(CAST(@Ad_Disburse_DATE AS VARCHAR), '') + ', DisburseSeq_NUMB = ' + ISNULL(CAST(@An_DisburseSeq_NUMB AS VARCHAR), '') + ', StatusEscheat_DATE = ' + ISNULL(CAST(@Ld_High_DATE AS VARCHAR), '') + ', StatusEscheat_CODE = ' + ISNULL(@Lc_Space_TEXT, '');

     INSERT DHLD_Y1
            (CheckRecipient_ID,
             CheckRecipient_CODE,
             Case_IDNO,
             OrderSeq_NUMB,
             ObligationSeq_NUMB,
             Batch_DATE,
             SourceBatch_CODE,
             Batch_NUMB,
             SeqReceipt_NUMB,
             EventGlobalSupportSeq_NUMB,
             TypeDisburse_CODE,
             Transaction_AMNT,
             Status_CODE,
             TypeHold_CODE,
             ReasonStatus_CODE,
             ProcessOffset_INDC,
             Transaction_DATE,
             Release_DATE,
             BeginValidity_DATE,
             EndValidity_DATE,
             EventGlobalBeginSeq_NUMB,
             EventGlobalEndSeq_NUMB,
             Disburse_DATE,
             DisburseSeq_NUMB,
             StatusEscheat_DATE,
             StatusEscheat_CODE)
     VALUES (@Ac_CheckRecipient_ID,--CheckRecipient_ID
             @Ac_CheckRecipient_CODE,--CheckRecipient_CODE
             @An_Case_IDNO,--Case_IDNO
             @An_OrderSeq_NUMB,--OrderSeq_NUMB
             @An_ObligationSeq_NUMB,--ObligationSeq_NUMB
             @Ad_Batch_DATE,--Batch_DATE
             @Ac_SourceBatch_CODE,--SourceBatch_CODE
             @An_Batch_NUMB,--Batch_NUMB
             @An_SeqReceipt_NUMB,--SeqReceipt_NUMB
             @An_EventGlobalSupportSeq_NUMB,--EventGlobalSupportSeq_NUMB
             @Ac_TypeDisburse_CODE,--TypeDisburse_CODE
             @An_Remaining_AMNT,--Transaction_AMNT
             @Lc_StatusH_CODE,--Status_CODE
             @Lc_TypeHoldP_IDNO,--TypeHold_CODE
             ISNULL (@Ac_Reason_CODE, ' '),--ReasonStatus_CODE
             @Lc_No_INDC,--ProcessOffset_INDC
             @Ad_Run_DATE,--Transaction_DATE
             @Ad_Expire_DATE,--Release_DATE
             @Ad_Run_DATE,--BeginValidity_DATE
             @Ld_High_DATE,--EndValidity_DATE
             @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
             0,--EventGlobalEndSeq_NUMB
             @Ad_Disburse_DATE,--Disburse_DATE
             @An_DisburseSeq_NUMB,--DisburseSeq_NUMB
             @Ld_High_DATE,--StatusEscheat_DATE
             @Lc_Space_TEXT --StatusEscheat_CODE
		);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_DHLD_CP_HOLD FAILED';

       RAISERROR (50001,16,1);
      END;

     SET @Ls_Sql_TEXT = 'INSERT_PESEM_CP_HOLD';
     SET @Ls_Sqldata_TEXT = 'EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRctno_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');

     INSERT PESEM_Y1
            (Entity_ID,
             EventGlobalSeq_NUMB,
             TypeEntity_CODE,
             EventFunctionalSeq_NUMB)
     VALUES ( dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (@Ad_Batch_DATE, @Ac_SourceBatch_CODE, @An_Batch_NUMB, @An_SeqReceipt_NUMB),--Entity_ID
              @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
              @Lc_TypeEntityRctno_CODE,--TypeEntity_CODE
              @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
     );

     SET @Ls_Sql_TEXT = 'INSERT_PESEM_CP_HOLD';
     SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityCase_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');

     INSERT PESEM_Y1
            (Entity_ID,
             EventGlobalSeq_NUMB,
             TypeEntity_CODE,
             EventFunctionalSeq_NUMB)
     VALUES (@An_Case_IDNO,--Entity_ID
             @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
             @Lc_TypeEntityCase_CODE,--TypeEntity_CODE
             @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
     );

     SET @Ls_Sql_TEXT = 'INSERT_PESEM_CP_HOLD';
     SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(@Ac_ChldChkRecipient_ID, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRcpid_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');

     INSERT PESEM_Y1
            (Entity_ID,
             EventGlobalSeq_NUMB,
             TypeEntity_CODE,
             EventFunctionalSeq_NUMB)
     VALUES (@Ac_ChldChkRecipient_ID,--Entity_ID
             @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
             @Lc_TypeEntityRcpid_CODE,--TypeEntity_CODE
             @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
     );

     SET @Ls_Sql_TEXT = 'INSERT_PESEM_CP_HOLD';
     SET @Ls_Sqldata_TEXT = 'Entity_ID = ' + ISNULL(@Ac_ChldChkRecipient_CODE, '') + ', EventGlobalSeq_NUMB = ' + ISNULL(CAST(@An_EventGlobalSeq_NUMB AS VARCHAR), '') + ', TypeEntity_CODE = ' + ISNULL(@Lc_TypeEntityRcpcd_CODE, '') + ', EventFunctionalSeq_NUMB = ' + ISNULL(CAST(@Li_PayeeHold1960_NUMB AS VARCHAR), '');

     INSERT PESEM_Y1
            (Entity_ID,
             EventGlobalSeq_NUMB,
             TypeEntity_CODE,
             EventFunctionalSeq_NUMB)
     VALUES (@Ac_ChldChkRecipient_CODE,--Entity_ID
             @An_EventGlobalSeq_NUMB,--EventGlobalSeq_NUMB
             @Lc_TypeEntityRcpcd_CODE,--TypeEntity_CODE
             @Li_PayeeHold1960_NUMB --EventFunctionalSeq_NUMB
     );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF (@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'INSERT_PESEM_CP_HOLD FAILED';

       RAISERROR (50001,16,1);
      END;

     SET @An_Remaining_AMNT = 0;
    END;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
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
  END CATCH;
 END


GO
