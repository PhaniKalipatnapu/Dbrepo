/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_ENTITY_MATRIX]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*      
--------------------------------------------------------------------------------------------------------------------      
Procedure Name  : BATCH_COMMON$SP_ENTITY_MATRIX      
Programmer Name : IMP Team      
Description     :        
Frequency       :       
Developed On    : 04/12/2011
Called By       :      
Called On       :      
--------------------------------------------------------------------------------------------------------------------      
Modified By     :      
Modified On     :      
Version No      : 1.0       
--------------------------------------------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_ENTITY_MATRIX] (
 @An_EventGlobalSeq_NUMB           NUMERIC (19),
 @An_EventFunctionalSeq_NUMB       NUMERIC (4),
 @An_EntityCase_IDNO               NUMERIC (6),
 --13347 - Adding CpMci_IDNO exist condition for Member's Case in MHIS table -START-
 @An_EntityCpMci_IDNO			   NUMERIC (10) = NULL,
 --13347 - Adding CpMci_IDNO exist condition for Member's Case in MHIS table -End-
 @An_EntityCaseWelfare_IDNO        NUMERIC (10) = NULL,
 @An_EntityOrder_IDNO              NUMERIC (15) = NULL,
 @An_EntityMemberMci_IDNO          NUMERIC (10) = NULL,
 @An_EntityPayor_IDNO              NUMERIC (10) = NULL,
 @Ac_EntityCheckRecipient_ID       CHAR (10) = NULL,
 @Ac_EntityCheckRecipient_CODE     CHAR (1) = NULL,
 @Ac_EntityTypeDebt_CODE           CHAR (2) = NULL,
 @Ac_EntityFips_CODE               CHAR (7) = NULL,
 @Ac_EntityReceipt_ID              CHAR (27) = NULL,
 @Ac_EntityCheckNo_TEXT            CHAR (19) = NULL,
 @Ac_EntityRshld_ID                CHAR (5) = NULL,
 @An_EntityDisburseSeq_NUMB        NUMERIC (4) = NULL,
 @Ac_EntitySubject_ID              CHAR (30) = NULL,
 @Ac_EntityStatus_CODE             CHAR (1) = NULL,
 @Ad_EntityAccrual_DATE            DATE = NULL,
 @Ad_EntityReceipt_DATE            DATE = NULL,
 @Ad_EntityRelease_DATE            DATE = NULL,
 @Ad_EntityDisburse_DATE           DATE = NULL,
 @Ac_EntityActn_ID                 CHAR (30) = NULL,
 @An_EntityWelfareYearMonth_NUMB   NUMERIC (6) = NULL,
 @Ac_TypeWelfare_CODE              CHAR (1) = NULL,
 @Ac_EntityReasonOverpay_CODE      CHAR (2) = NULL,
 @Ad_EntityDistribute_DATE         DATE = NULL,
 @Ad_EntityHoldTransaction_DATE    DATE = NULL,
 @An_EntitySupportYearMonth_NUMB   NUMERIC (6) = NULL,
 @Ac_EntityObligation_ID           CHAR (20) = NULL,
 @Ac_EntityReasonBackOut_CODE      CHAR (2) = NULL,
 @Ac_EntityRefundReasonStatus_CODE CHAR (4) = NULL,
 @Ac_ReverseRangeReceipt_DATE      CHAR (21) = NULL,
 @Ac_Msg_CODE                      CHAR (1) OUTPUT,
 @As_DescriptionError_TEXT         VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_TanfGrantSplit2730_NUMB              INT = 2730,
          @Li_DisbursementHoldInstruction1980_NUMB INT = 1980,
          @Li_RecoupmentInstruction2220_NUMB       INT = 2220,
          @Li_DistributionHoldInstruction1880_NUMB INT = 1880,
          @Li_ReceiptOnHold1420_NUMB               INT = 1420,
          @Ln_Count_QNTY                           INT=0,
          @Lc_StatusSuccess_CODE                   CHAR(1) = 'S',
          @Lc_CaseRelationshipNcp_CODE             CHAR(1) = 'A',
          @Lc_StatusFailure_CODE                   CHAR(1) = 'F',
          @Lc_Space_TEXT                           CHAR(1) = ' ',
          @Ls_Routine_TEXT                         VARCHAR(100) = 'BATCH_COMMON$SP_ENTITY_MATRIX';
  DECLARE @Ln_FetchStatus_QNTY      NUMERIC,
          @Ln_EntityCase_IDNO       NUMERIC(6),
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_Msg_CODE              CHAR(1),
          @Lc_TypeEntity_CODE       CHAR(5),
          @Lc_Entity_ID             CHAR(30) = '',
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(200),
          @Ls_ErrorMessage_TEXT     VARCHAR(2000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ls_ErrorDesc_TEXT        VARCHAR(4000);

  -- ROAD MAP      
  -- CDREA 2215 -- CREC INITIATED NOTICE  --> ADDED AS --> @Ac_EntityReasonOverpay_CODE      
  -- DSTDT 1810 -- DISTRIBUTION DATE   --> ADDED AS --> @Ad_EntityDistribute_DATE      
  -- DTHLD 1840 -- DT_DISBURSEMENT_HOLD   --> ADDED AS --> @Ad_EntityHoldTransaction_DATE      
  -- MRLSE 1825 -- MONTH_RELEASE    --> ADDED AS --> @An_EntitySupportYearMonth_NUMB      
  -- OBLE 1810 -- OBLIGATION    --> ADDED AS --> @Ac_EntityObligation_ID  (NEED TO BE IN THIS FORMAT --> ( MemberMci_IDNO-TypeDebt_CODE-Fips_CODE ))      
  -- RCODE 1260 -- Reason Code    --> ADDED AS --> @Ac_EntityReasonBackOut_CODE      
  -- RESCD 1225 -- REQUEST REFUND   --> ADDED AS --> @Ac_EntityRefundReasonStatus_CODE      
  -- DTRNG 1260 -- DT_RANGE     --> ADDED AS --> @Ac_ReverseRangeReceipt_DATE (NEED TO BE IN THIS FORMAT --> (MM/DD/YYYY-MM/DD/YYYY))      
  SET @Ls_Sqldata_TEXT = ' EventGlobalSeq_NUMB = ' + ISNULL (CAST (@An_EventGlobalSeq_NUMB AS VARCHAR (19)), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@An_EventFunctionalSeq_NUMB AS VARCHAR (4)), '');

  IF (@An_EventFunctionalSeq_NUMB = 0)
   BEGIN
    SET @Ls_Sql_TEXT = 'EventFunctionalSeq_NUMB REQUIRED';

    RAISERROR (50001,16,1);
   END

  DECLARE Eema_CUR INSENSITIVE CURSOR FOR
   SELECT EVM.TypeEntity_CODE
     FROM EEMA_Y1 EVM
    WHERE EVM.EventFunctionalSeq_NUMB = @An_EventFunctionalSeq_NUMB;

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Ln_EntityCase_IDNO = CAST (@An_EntityCase_IDNO AS VARCHAR (6));
   SET @Ls_Sql_TEXT = 'OPEN Eema_CUR';

   OPEN Eema_CUR;

   SET @Ls_Sql_TEXT = 'FETCH Eema_CUR - 1';

   FETCH NEXT FROM Eema_CUR INTO @Lc_TypeEntity_CODE;

   SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;

   WHILE @Ln_FetchStatus_QNTY = 0
    BEGIN
     SET @Lc_TypeEntity_CODE = LTRIM (RTRIM (@Lc_TypeEntity_CODE));
     SET @Ls_Sql_TEXT = 'SP_INSERT_ESEM_Y1 ';
     SET @Ls_Sqldata_TEXT = 'TypeEntity_CODE = ' + ISNULL (CAST (@Lc_TypeEntity_CODE AS VARCHAR (10)), '') + ', EventGlobalSeq_NUMB = ' + ISNULL (CAST (@An_EventGlobalSeq_NUMB AS VARCHAR (19)), '') + ', EventFunctionalSeq_NUMB = ' + ISNULL (CAST (@An_EventFunctionalSeq_NUMB AS VARCHAR (4)), '');

     -- When functional entity is case call Case Payee or Case Payor Matrix      
     IF @Lc_TypeEntity_CODE = 'CASE'
      BEGIN
       IF @An_EventFunctionalSeq_NUMB IN (@Li_DisbursementHoldInstruction1980_NUMB, @Li_RecoupmentInstruction2220_NUMB, 1800)
        BEGIN
         EXECUTE BATCH_COMMON$SP_INSERT_CASE_PAYEE
          @Ac_CheckRecipient_ID       = @Ac_EntityCheckRecipient_ID,
          @Ac_CheckRecipient_CODE     = @Ac_EntityCheckRecipient_CODE,
          @Ad_Disburse_DATE           = @Ad_EntityDisburse_DATE,
          @An_DisburseSeq_NUMB        = @An_EntityDisburseSeq_NUMB,
          @An_EventFunctionalSeq_NUMB = @An_EventFunctionalSeq_NUMB,
          @An_EventGlobalSeq_NUMB     = @An_EventGlobalSeq_NUMB,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailure_CODE
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_CASE_PAYEE FAILED';

           RAISERROR (50001,16,1);
          END
        END -- End of Case functional event 1980, 2220      
       ELSE IF @An_EventFunctionalSeq_NUMB IN (@Li_DistributionHoldInstruction1880_NUMB, @Li_ReceiptOnHold1420_NUMB)
          AND (@Ln_EntityCase_IDNO = 0
                OR @Ln_EntityCase_IDNO = 0)
	BEGIN 
     SELECT @Ln_Count_QNTY = COUNT(1)  
         FROM rcth_y1
		WHERE SourceReceipt_CODE in('CR','CF')
		  AND StatusReceipt_CODE='H'
          AND Batch_DATE= SUBSTRING(@Ac_EntityReceipt_ID,1,10)
          AND SourceBatch_CODE=SUBSTRING(@Ac_EntityReceipt_ID,12,3)
          AND Batch_NUMB=SUBSTRING(@Ac_EntityReceipt_ID,16,4)
          AND SeqReceipt_NUMB=replace(SUBSTRING(@Ac_EntityReceipt_ID,21,7),'-','')
          AND payormci_idno=@An_EntityPayor_IDNO
          AND EndValidity_DATE='12/31/9999';
        IF @Ln_Count_QNTY>0 
          BEGIN
         INSERT ESEM_Y1  
          (Entity_ID,  
           TypeEntity_CODE,  
           EventFunctionalSeq_NUMB,  
           EventGlobalSeq_NUMB)  
		 SELECT C.Case_IDNO AS Entity_ID,  
			'CASE' AS TypeEntity_CODE,  
			@An_EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB,  
			@An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB  
		   FROM CASE_Y1 C  
		   JOIN CMEM_Y1 CM  
             ON C.Case_IDNO = CM.Case_IDNO  
          WHERE CM.MemberMci_IDNO = @An_EntityPayor_IDNO  
            AND CM.CaseRelationship_CODE IN ('C','A', 'P')  
            AND CM.CaseMemberStatus_CODE = 'A'; 
            
          IF (@@ROWCOUNT = 0)
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT_INSERT_CHKV FAILED';
           RAISERROR (50001,16,1);
          END
      END             
   ELSE  
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_CASE_PAYOR ';

         EXECUTE BATCH_COMMON$SP_INSERT_CASE_PAYOR
          @An_EntityPayor_IDNO        = @An_EntityPayor_IDNO,
          @An_EventFunctionalSeq_NUMB = @An_EventFunctionalSeq_NUMB,
          @An_EventGlobalSeq_NUMB     = @An_EventGlobalSeq_NUMB,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailure_CODE
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_CASE_PAYOR FAILED';

           RAISERROR (50001,16,1);
          END
        END--06/12/2013-changed
        
        
END --06/12/2013-change   END 
        
       ELSE IF (@An_EventFunctionalSeq_NUMB IN (@Li_TanfGrantSplit2730_NUMB)
           AND @An_EntityCase_IDNO = 0)
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_CASE_PAYOR ';

         INSERT INTO Esem_Y1
         SELECT DISTINCT
                CAST (a.Case_IDNO AS VARCHAR (6)),
                @Lc_TypeEntity_CODE,
                @An_EventFunctionalSeq_NUMB,
                @An_EventGlobalSeq_NUMB
           FROM MHIS_Y1 A
          WHERE A.CaseWelfare_IDNO = @An_EntityCaseWelfare_IDNO
            AND A.TypeWelfare_CODE = @Ac_TypeWelfare_CODE
            --13347 - Adding CpMci_IDNO exist condition for Member's Case in MHIS table -START-
            AND A.Case_IDNO IN ( SELECT c.Case_IDNO 
									FROM CMEM_Y1 c 
									WHERE c.MemberMci_Idno = @An_EntityCpMci_IDNO
									AND c.CaseRelationship_CODE = 'C'
									AND c.CaseMemberStatus_CODE = 'A' ) ;
		   --13347 - Adding CpMci_IDNO exist condition for Member's Case in MHIS table -End-	
        END
       ELSE
        BEGIN
         SET @Lc_Entity_ID = CAST (@An_EntityCase_IDNO AS VARCHAR (30));

         EXECUTE BATCH_COMMON$SP_INSERT_MATRIX
          @Ac_TypeEntity_CODE         = @Lc_TypeEntity_CODE,
          @Ac_Entity_ID               = @Lc_Entity_ID,
          @An_EventFunctionalSeq_NUMB = @An_EventFunctionalSeq_NUMB,
          @An_EventGlobalSeq_NUMB     = @An_EventGlobalSeq_NUMB,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
        END
      END
     ELSE IF @Lc_TypeEntity_CODE = 'RCTNO'
      BEGIN
       IF @An_EventFunctionalSeq_NUMB IN (1710, 1720, 1730, 1740,
                                          1750, 1760, 1770, 1780,
                                          1790, 1800)
        BEGIN
         INSERT ESEM_Y1
                (Entity_ID,
                 TypeEntity_CODE,
                 EventGlobalSeq_NUMB,
                 EventFunctionalSeq_NUMB)
         SELECT DISTINCT
                dbo.BATCH_COMMON$SF_GET_RECEIPT_NO (DS.Batch_DATE, DS.SourceBatch_CODE, DS.Batch_NUMB, DS.SeqReceipt_NUMB) AS Receipt_ID,
                'RCTNO' AS TypeEntity_CODE,
                @An_EventGlobalSeq_NUMB AS EventGlobalSeq_NUMB,
                @An_EventFunctionalSeq_NUMB AS EventFunctionalSeq_NUMB
           FROM DSBL_Y1 DS
          WHERE DS.CheckRecipient_ID = LTRIM (RTRIM (@Ac_EntityCheckRecipient_ID))
            AND DS.CheckRecipient_CODE = @Ac_EntityCheckRecipient_CODE
            AND DS.Disburse_DATE = @Ad_EntityDisburse_DATE
            AND DS.DisburseSeq_NUMB = @An_EntityDisburseSeq_NUMB;

         IF (@@ROWCOUNT = 0)
          BEGIN
           SET @Ls_Sql_TEXT = 'SELECT_INSERT_CHKV FAILED';

           RAISERROR (50001,16,1);
          END
        END
       ELSE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_MATRIX - 2';

         EXECUTE BATCH_COMMON$SP_INSERT_MATRIX
          @Ac_TypeEntity_CODE         = @Lc_TypeEntity_CODE,
          @Ac_Entity_ID               = @Ac_EntityReceipt_ID,
          @An_EventFunctionalSeq_NUMB = @An_EventFunctionalSeq_NUMB,
          @An_EventGlobalSeq_NUMB     = @An_EventGlobalSeq_NUMB,
          @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailure_CODE
          BEGIN
           SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_MATRIX FAILED';

           RAISERROR (50001,16,1);
          END
        END
      END
     ELSE
      BEGIN
       SELECT @Lc_Entity_ID = CASE
                               WHEN @Lc_TypeEntity_CODE = 'WCASE'
                                THEN CAST (@An_EntityCaseWelfare_IDNO AS VARCHAR (10))
                               WHEN @Lc_TypeEntity_CODE = 'ORDER'
                                THEN CAST (@An_EntityOrder_IDNO AS VARCHAR)
                               WHEN @Lc_TypeEntity_CODE = 'MEMBR'
                                THEN CAST (@An_EntityMemberMci_IDNO AS VARCHAR (10))
                               WHEN @Lc_TypeEntity_CODE = 'PAYOR'
                                THEN CAST (@An_EntityPayor_IDNO AS VARCHAR (10))
                               WHEN @Lc_TypeEntity_CODE = 'RCPID'
                                THEN @Ac_EntityCheckRecipient_ID
                               WHEN @Lc_TypeEntity_CODE = 'RCPCD'
                                THEN @Ac_EntityCheckRecipient_CODE
                               WHEN @Lc_TypeEntity_CODE = 'DEBT'
                                THEN @Ac_EntityTypeDebt_CODE
                               WHEN @Lc_TypeEntity_CODE = 'FIPS'
                                THEN @Ac_EntityFips_CODE
                               WHEN @Lc_TypeEntity_CODE = 'M_ADJ'
                                THEN CAST (@An_EntityWelfareYearMonth_NUMB AS VARCHAR (6))
                               WHEN @Lc_TypeEntity_CODE = 'DTACL'
                                THEN REPLACE (CONVERT (VARCHAR (10), @Ad_EntityAccrual_DATE, 101), '/', '') --'MMDDYYYY'      
                               WHEN @Lc_TypeEntity_CODE = 'RCTDT'
                                THEN REPLACE (CONVERT (VARCHAR (10), @Ad_EntityReceipt_DATE, 101), '/', '') --'MMDDYYYY'      
                               WHEN @Lc_TypeEntity_CODE = 'RELDT'
                                THEN REPLACE (CONVERT (VARCHAR (10), @Ad_EntityRelease_DATE, 101), '/', '') --'MMDDYYYY'      
                               WHEN @Lc_TypeEntity_CODE = 'DISDT'
                                THEN REPLACE (CONVERT (VARCHAR (10), @Ad_EntityDisburse_DATE, 101), '/', '') --'MMDDYYYY'      
                               WHEN @Lc_TypeEntity_CODE = 'CHKNO'
                                THEN
                                CASE @Ac_EntityCheckNo_TEXT
                                 WHEN @Lc_Space_TEXT
                                  THEN 'NOCHECK#'
                                 ELSE ISNULL (CAST (@Ac_EntityCheckNo_TEXT AS VARCHAR), 'NOCHECK#')
                                END
                               WHEN @Lc_TypeEntity_CODE = 'RSHLD'
                                THEN @Ac_EntityRshld_ID
                               WHEN @Lc_TypeEntity_CODE = 'DISEQ'
                                THEN CAST (@An_EntityDisburseSeq_NUMB AS VARCHAR)
                               WHEN @Lc_TypeEntity_CODE = 'SUBJ'
                                THEN @Ac_EntitySubject_ID
                               WHEN @Lc_TypeEntity_CODE = 'STAT'
                                THEN @Ac_EntityStatus_CODE
                               WHEN @Lc_TypeEntity_CODE = 'ACTN'
                                THEN @Ac_EntityActn_ID
                               WHEN @Lc_TypeEntity_CODE = 'CDREA'
                                THEN @Ac_EntityReasonOverpay_CODE
                               WHEN @Lc_TypeEntity_CODE = 'DSTDT'
                                THEN REPLACE (CONVERT (VARCHAR (10), @Ad_EntityDistribute_DATE, 101), '/', '') --'MMDDYYYY'      
                               WHEN @Lc_TypeEntity_CODE = 'DTHLD'
                                THEN REPLACE (CONVERT (VARCHAR (10), @Ad_EntityHoldTransaction_DATE, 101), '/', '') --'MMDDYYYY'      
                               WHEN @Lc_TypeEntity_CODE = 'MRLSE'
                                THEN CAST (@An_EntitySupportYearMonth_NUMB AS VARCHAR (6))
                               WHEN @Lc_TypeEntity_CODE = 'OBLE'
                                THEN @Ac_EntityObligation_ID
                               WHEN @Lc_TypeEntity_CODE = 'RCODE'
                                THEN @Ac_EntityReasonBackOut_CODE
                               WHEN @Lc_TypeEntity_CODE = 'RESCD'
                                THEN @Ac_EntityRefundReasonStatus_CODE
                               WHEN @Lc_TypeEntity_CODE = 'DTRNG'
                                THEN @Ac_ReverseRangeReceipt_DATE
                              END

       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_MATRIX - 3';

       EXECUTE BATCH_COMMON$SP_INSERT_MATRIX
        @Ac_TypeEntity_CODE         = @Lc_TypeEntity_CODE,
        @Ac_Entity_ID               = @Lc_Entity_ID,
        @An_EventFunctionalSeq_NUMB = @An_EventFunctionalSeq_NUMB,
        @An_EventGlobalSeq_NUMB     = @An_EventGlobalSeq_NUMB,
        @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailure_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_ENTITY_MATRIX FAILED';

         RAISERROR (50001,16,1);
        END
      END

     FETCH NEXT FROM Eema_CUR INTO @Lc_TypeEntity_CODE;

     SET @Ln_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   CLOSE Eema_CUR;

   DEALLOCATE Eema_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('local', 'Eema_CUR') IN (0, 1)
    BEGIN
     CLOSE Eema_CUR;

     DEALLOCATE Eema_CUR;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailure_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   --Check for Exception information to log the description text based on the error      
   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_ErrorDesc_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_ErrorDesc_TEXT;
  END CATCH
 END;


GO
