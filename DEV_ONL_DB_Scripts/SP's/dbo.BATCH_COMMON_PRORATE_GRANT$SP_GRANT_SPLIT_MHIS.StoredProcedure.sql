/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_MHIS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_MHIS
Programmer Name		: IMP Team
Description			: 
Frequency			: 
Developed On		:	04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_MHIS](
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_CaseWelfare_IDNO      NUMERIC(10 ),
 @Ad_Start_DATE            DATE,
 @Ac_LastRec_INDC          CHAR(1),
 @Ac_SignedOnWorker_ID     CHAR(30),
 @As_Screen_ID             CHAR(7) = '',
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 
  DECLARE @Ln_CpMci_IDNO										  NUMERIC(9),
		  @Ln_DEBMemberMci_IDNO									  NUMERIC(9) = 0,
		  @Ls_DebtTypeChildSupp_CODE                              CHAR(2) = 'CS',
          @Ls_DebtTypeSpousalSupp_CODE                            CHAR(2) = 'SS',
          @Ls_DebtTypeIntChildSupp_CODE                           CHAR(2) = 'CI',
          @Ls_DebtTypeIntSpousalSupp_CODE                         CHAR(2) = 'SI',
          @Ls_InStateFips_CODE                                    CHAR(2) = '10',
          @Ld_High_DATE                                           DATE = '12/31/9999',
          @Lc_StatusFailed_CODE                                   CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE                                  CHAR(1) = 'S',
          @Lc_StatusAbnormalend_CODE                              CHAR(1) = 'A',
          @Lc_WelfareTypeNonTanf_CODE                             CHAR(1) = 'N',
          @Lc_WelfareTypeMedicaid_CODE                            CHAR(1) = 'M',
          @Lc_No_INDC                                             CHAR(1) = 'N',
          @Lc_Yes_INDC                                            CHAR(1) = 'Y',
          @Lc_CaseRelationShipCP_CODE                             CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE						  CHAR(1) = 'A',
          @Li_TanfGrantSplitAfterParticipantStatusChange2750_NUMB INT = 2750,
          @Lc_Grantmhis_TEXT                                      CHAR(3) = 'GSM',
          @Lc_ScreenCmem_ID                                       CHAR(4) = 'CMEM',
          @Lc_Process_ID										  CHAR(10) = '',
		  @Ls_Procedure_NAME                                      VARCHAR(100) = 'BATCH_COMMON _PRORATE_GRANT$SP_GRANT_SPLIT_MHIS';
  DECLARE @Ls_Sql_TEXT                     VARCHAR(100),
          @Ls_Sqldata_TEXT                 VARCHAR(100),
          @Lc_Msg_CODE                     CHAR(1),
          @Ls_ErrorMessage_TEXT            VARCHAR(2000),
          @Ls_DescriptionError_TEXT        VARCHAR(4000),
          @Li_RowsAffected                 INT = 0,
          @Ln_While_QNTY                   NUMERIC(1) = 0,
          @Ln_Welf_QNTY                    NUMERIC(1) = 0,
          @Ln_Exist_DTYM                   NUMERIC(1) = 0,
          @Ln_EventGlobalSeq_NUMB          NUMERIC(19),
          @Ld_Start_DATE                   DATE ,
          @Ld_End_DATE                     DATE = @Ad_Run_DATE,
          @Ln_IvmgAdjust_AMNT              NUMERIC(11, 2) = 0,
          @Ln_AdjustYearMonth_NUMB         NUMERIC(6),
          @Ln_MtdAssistExpend_AMNT         NUMERIC(11, 2) = 0,
          @Ln_LtdAssistExpend_AMNT         NUMERIC(11, 2) = 0,
          @Ln_LtdAssistWemoRecoup_AMNT     NUMERIC(11, 2) = 0,
          @Ln_MtdAssistWemoRecoup_AMNT     NUMERIC(11, 2) = 0,
          @Ln_IvmgRecoup_AMNT              NUMERIC(11, 2) = 0,
          @Ln_AdjustRecoup_AMNT            NUMERIC(11, 2) = 0,
          @Ln_LtdAssistExpandWemo_AMNT     NUMERIC(11, 2) = 0,
          @Ln_TransactionAssistExpend_AMNT NUMERIC(11, 2) = 0,
          @Ln_ExpendMtd_AMNT               NUMERIC(11, 2) = 0,
          @Ln_RecoupMtd_AMNT               NUMERIC(11, 2) = 0,
          @Ls_WemoFlag_INDC                CHAR(1),
          @Ln_WelfareYearMonth_NUMB        NUMERIC(6) = 0,
          @Ln_Value2_NUMB                  NUMERIC(4) = 0,
          @Ln_LtdUrg_AMNT                  NUMERIC(11, 2) = 0,
          @Ln_MtdUrg_AMNT                  NUMERIC(11, 2) = 0,
          @Li_Fetch_Status                 INT =0,
          @Lc_Process_INDC                 CHAR(1);
   
     DECLARE @Ln_wemoCursor$Case_IDNO          NUMERIC(6),
             @Ln_wemoCursor$OrderSeq_NUMB      NUMERIC(3),
             @Ln_wemoCursor$ObligationSeq_NUMB NUMERIC(3),
             @Ln_wemoCursor$CaseWelfare_IDNO   NUMERIC(10),
             @Ln_wemoCursor$ArrPaid_AMNT       NUMERIC(11, 2),
             @Ln_wemoCursor$ArrRecoup_AMNT     NUMERIC(11, 2),
             @Ln_wemoCursor$ArrPaidMtd_AMNT    NUMERIC(11, 2),
             @Ln_wemoCursor$ArrRecoupMtd_AMNT  NUMERIC(11, 2),
             @Ln_wemoCursor$ArrPaidUrg_AMNT    NUMERIC(11, 2),
             @Ln_wemoCursor$ArrPaidMtdUrg_AMNT NUMERIC(11, 2);

   DECLARE @GrantData_Cursor$Case_IDNO          NUMERIC(6),
           @GrantData_Cursor$OrderSeq_NUMB      NUMERIC(3),
           @GrantData_Cursor$ObligationSeq_NUMB NUMERIC(3),
           @GrantData_Cursor$Support_DTYM       NUMERIC(6);
             
          
  DECLARE @Lt_GrantData_TAB TABLE (
   Seq_IDNO           SMALLINT IDENTITY(1, 1) NOT NULL,
   Case_IDNO          NUMERIC(6),
   OrderSeq_NUMB      NUMERIC(2),
   ObligationSeq_NUMB NUMERIC(2),
   MonthAdjust_NUMB   NUMERIC(6));

  CREATE TABLE #TPRCP_P1 
   (
     Seq_IDNO           NUMERIC(19),
     MemberMci_IDNO     NUMERIC(10),
     Case_IDNO          NUMERIC(6),
     OrderSeq_NUMB      NUMERIC(2),
     ObligationSeq_NUMB NUMERIC(2),
     TypeBucket_CODE    CHAR(5),
     CaseWelfare_IDNO   NUMERIC(10),
     ArrPaid_AMNT       NUMERIC(11, 2),
     ArrRecoup_AMNT     NUMERIC(11, 2),
     Rounded_AMNT       NUMERIC(11, 2),
     RoundedRecoup_AMNT NUMERIC(11, 2),
     ArrToBePaid_AMNT   NUMERIC(11, 2),
     ArrPaidMtd_AMNT    NUMERIC(11, 2),
     ArrRecoupMtd_AMNT  NUMERIC(11, 2),
     ArrPaidUrg_AMNT    NUMERIC(11, 2),
     ArrPaidMtdUrg_AMNT NUMERIC(11, 2)
   );

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_Process_ID = @Lc_Grantmhis_TEXT + @As_Screen_ID;
   
   SET @Ls_Sql_TEXT = 'GETTING CP MCI IDNO'
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR) + ', CaseWelfare_IDNO ' + ISNULL(CAST(@An_CaseWelfare_IDNO AS CHAR(10)), '') + 'WelfareYearMonth_NUMB ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS CHAR(6)), '');
   
   SET @Ln_CpMci_IDNO = ISNULL((SELECT MemberMci_IDNO 
							FROM CMEM_Y1 a
						   WHERE a.Case_IDNO = @An_Case_IDNO
						     AND a.CaseRelationship_CODE = @Lc_CaseRelationShipCP_CODE
						     AND a.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE),0);

   IF ((YEAR(@Ad_Start_DATE) * 100 + MONTH(@Ad_Start_DATE)) <= (YEAR(@Ad_Run_DATE) * 100 + MONTH(@Ad_Run_DATE)))
    BEGIN
     SET @Ld_Start_DATE = @Ld_End_DATE
    END
   ELSE
    BEGIN
     SET @Ld_Start_DATE = DATEADD(d, -DAY(@Ad_Start_DATE), DATEADD(m, 1, @Ad_Start_DATE)); -- LAST DAY OF MONTH
    END

   SET @Ls_Sql_TEXT = 'SELECT_MHIS_Y1';
   SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO ' + ISNULL(CAST(@An_CaseWelfare_IDNO AS CHAR(10)), '') + 'WelfareYearMonth_NUMB ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS CHAR(6)), '');

   IF (NOT EXISTS(SELECT 1
                    FROM MHIS_Y1 MH
                   WHERE MH.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND MH.Case_IDNO = @An_Case_IDNO
                     AND MH.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                     AND MH.Start_DATE <= @Ld_Start_DATE))
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_TanfGrantSplitAfterParticipantStatusChange2750_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_End_DATE,
      @Ac_Note_INDC               = @Lc_No_INDC,
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ  FAILED';

       RAISERROR(50001,16,1);
      END;

     -- BEGIN End Date Wemo for open Obligation
     WITH Oble_CTE(Case_IDNO, OrderSeq_NUMB, ObligationSEQ_NUMB)
          AS (SELECT DISTINCT
                     OB.Case_IDNO,
                     OB.OrderSeq_NUMB,
                     OB.ObligationSEQ_NUMB
                FROM OBLE_Y1 OB
               WHERE OB.Case_IDNO = @An_Case_IDNO
                 AND OB.MemberMci_IDNO = @An_MemberMci_IDNO
                 AND OB.TypeDebt_CODE IN ('CS', 'SS', 'CI', 'SI')
                 AND LEFT(OB.Fips_CODE, 2) = '10'
                 AND OB.EndValidity_DATE = @Ld_High_DATE)
                 
     UPDATE WEMO_Y1
        SET EndValidity_DATE = @Ld_End_DATE,
            EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
       FROM Oble_CTE C
            JOIN WEMO_Y1 W
             ON C.Case_IDNO = W.Case_IDNO
                AND C.OrderSeq_NUMB = W.OrderSeq_NUMB
                AND C.ObligationSEQ_NUMB = W.ObligationSEQ_NUMB
                AND W.EndValidity_DATE = @Ld_High_DATE;
    -- END End Date Wemo for open Obligation         
    END


   /* --------------------------<MAIN WHILE-LOOP START>-----------------------------------*/
   WHILE ((YEAR(@Ld_Start_DATE) * 100 + MONTH(@Ld_Start_DATE)) <= (YEAR(@Ld_End_DATE) * 100 + MONTH(@Ld_End_DATE)))
    BEGIN
     MAIN_WHILE_LOOP:

     SET @Ln_While_QNTY = @Ln_While_QNTY + 1;
     SET @Ln_AdjustYearMonth_NUMB = (YEAR(@Ld_Start_DATE) * 100 + MONTH(@Ld_Start_DATE));
     SET @Ls_Sql_TEXT = 'SELECT_IVMG_Y1';
     SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO ' + ISNULL(CAST(@An_CaseWelfare_IDNO AS VARCHAR), '') + '  WelfareYearMonth_NUMB ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS NVARCHAR(max)), '');
     SET @Ln_LtdUrg_AMNT = 0;
     SET @Ln_MtdUrg_AMNT = 0;

     SET @Ls_Sql_TEXT = 'SELECT_VIVMG';
     SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO ' + ISNULL(CAST(@An_CaseWelfare_IDNO AS VARCHAR), '');

     SELECT @Ln_IvmgAdjust_AMNT = ISNULL(a.LtdAssistExpend_AMNT, 0) - ISNULL(a.MtdAssistExpend_AMNT, 0),
            @Ln_AdjustRecoup_AMNT = ISNULL(a.LtdAssistRecoup_AMNT, 0) - ISNULL(a.MtdAssistRecoup_AMNT, 0),
            @Ln_ExpendMtd_AMNT = ISNULL(a.MtdAssistExpend_AMNT, 0),
            @Ln_RecoupMtd_AMNT = ISNULL(a.MtdAssistRecoup_AMNT, 0)
       FROM IVMG_Y1 a
      WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
        AND a.CpMcI_IDNO = @Ln_CpMci_IDNO
        AND a.WelfareElig_CODE = @Lc_StatusAbnormalend_CODE
        AND a.WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
        AND a.EventGlobalSeq_NUMB = (SELECT MAX(c.EventGlobalSeq_NUMB)
                                       FROM IVMG_Y1 AS c
                                      WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                        AND c.CpMcI_IDNO = @Ln_CpMci_IDNO
                                        AND c.WelfareElig_CODE = @Lc_StatusAbnormalend_CODE
                                        AND c.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

     SET @Li_RowsAffected = @@ROWCOUNT;
     SET @Ln_Exist_DTYM = 1;
     SET @Ln_LtdUrg_AMNT = @Ln_IvmgAdjust_AMNT - @Ln_AdjustRecoup_AMNT;
     SET @Ln_MtdUrg_AMNT = @Ln_ExpendMtd_AMNT - @Ln_RecoupMtd_AMNT;
     SET @Ln_IvmgAdjust_AMNT = @Ln_AdjustRecoup_AMNT;
     SET @Ln_ExpendMtd_AMNT = @Ln_RecoupMtd_AMNT;

     IF (@Li_RowsAffected = 0)
      BEGIN
       SET @Ln_IvmgAdjust_AMNT = 0;
       SET @Ln_AdjustRecoup_AMNT = 0;
       SET @Ln_Exist_DTYM = 0;
       SET @Ln_ExpendMtd_AMNT = 0;
       SET @Ln_RecoupMtd_AMNT = 0;
       SET @Ln_MtdUrg_AMNT = 0;
       SET @Ln_LtdUrg_AMNT = 0;

       SELECT @Ln_IvmgAdjust_AMNT = ISNULL(a.LtdAssistExpend_AMNT, 0),
              @Ln_AdjustRecoup_AMNT = ISNULL(a.LtdAssistRecoup_AMNT, 0)
         FROM IVMG_Y1 a
        WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
          AND a.CpMcI_IDNO = @Ln_CpMci_IDNO
          AND a.WelfareElig_CODE = @Lc_StatusAbnormalend_CODE
          AND a.WelfareYearMonth_NUMB = (SELECT MAX(b.WelfareYearMonth_NUMB)
                                           FROM IVMG_Y1 b
                                          WHERE b.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
                                            AND b.CpMcI_IDNO = @Ln_CpMci_IDNO
                                            AND b.WelfareElig_CODE = @Lc_StatusAbnormalend_CODE
                                            AND b.WelfareYearMonth_NUMB <= @Ln_AdjustYearMonth_NUMB)
          AND a.EventGlobalSeq_NUMB = (SELECT MAX(c.EventGlobalSeq_NUMB) AS expr
                                         FROM dbo.IVMG_Y1 AS c
                                        WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                          AND c.CpMcI_IDNO = @Ln_CpMci_IDNO
                                          AND c.WelfareElig_CODE = @Lc_StatusAbnormalend_CODE
                                          AND c.WelfareYearMonth_NUMB = a.WelfareYearMonth_NUMB);

			SET @Li_RowsAffected = @@ROWCOUNT;
			IF @Li_RowsAffected = 0
			BEGIN
				GOTO NEXT_FETCH;
			END
			ELSE
			BEGIN
				SET @Ln_LtdUrg_AMNT = @Ln_IvmgAdjust_AMNT - @Ln_AdjustRecoup_AMNT;
				SET @Ln_IvmgAdjust_AMNT = @Ln_AdjustRecoup_AMNT;
			END
      END

     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
     SET @Ls_Sqldata_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';

     EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
      @An_EventFunctionalSeq_NUMB = @Li_TanfGrantSplitAfterParticipantStatusChange2750_NUMB,
      @Ac_Process_ID              = @Lc_Process_ID,
      @Ad_EffectiveEvent_DATE     = @Ld_End_DATE,
      @Ac_Note_INDC               = 'N',
      @Ac_Worker_ID               = @Ac_SignedOnWorker_ID,
      @An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
      @Ac_Msg_CODE                = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ  FAILED';

       RAISERROR(50001,16,1)
      END

	 IF (@As_Screen_ID = 'MHIS')
		BEGIN
			SET @Ln_DEBMemberMci_IDNO = @An_MemberMci_IDNO;
		END
	ELSE 
		BEGIN
			SET @Ln_DEBMemberMci_IDNO = 0;
		END

     SET @Lc_Process_INDC = @Lc_No_INDC;
     SET @Ls_Sql_TEXT = 'SPKG_PRORATE_GRANT$SP_PRORATE_IVA_GRANT ';

     EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_PRORATE_IVA_GRANT
      @An_CaseWelfare_IDNO      = @An_CaseWelfare_IDNO,
	  @An_CpMci_IDNO		    = @Ln_CpMci_IDNO,
	  @An_DEBMemberMci_IDNO		= @Ln_DEBMemberMci_IDNO,
      @Ad_Start_DATE            = @Ld_Start_DATE,
      @An_WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB,
      @An_LtdExpend_AMNT        = @Ln_IvmgAdjust_AMNT OUTPUT,
      @An_LtdRecoup_AMNT        = @Ln_AdjustRecoup_AMNT OUTPUT,
      @An_LtdUrg_AMNT           = @Ln_LtdUrg_AMNT OUTPUT,
      @An_MtdExpend_AMNT        = @Ln_ExpendMtd_AMNT OUTPUT,
      @An_MtdRecoup_AMNT        = @Ln_RecoupMtd_AMNT OUTPUT,
      @An_MtdUrg_AMNT           = @Ln_MtdUrg_AMNT OUTPUT,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @Ac_Process_INDC          = @Lc_Process_INDC OUTPUT,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'SPKG_PRORATE_GRANT$SP_PRORATE_IVA_GRANT  FAILED';

       RAISERROR(50001,16,1)
      END

     IF @Lc_Process_INDC = @Lc_No_INDC
      BEGIN
       GOTO NEXT_FETCH;
      END

  DECLARE WemoCursor CURSOR LOCAL FORWARD_ONLY FOR
   SELECT PR.Case_IDNO,
          PR.OrderSeq_NUMB,
          PR.ObligationSeq_NUMB,
          PR.CaseWelfare_IDNO,
          ISNULL(SUM(PR.ArrPaid_AMNT), 0) AS ArrPaid_AMNT,
          ISNULL(SUM(PR.ArrRecoup_AMNT), 0) AS ArrRecoup_AMNT,
          ISNULL(SUM(PR.ArrPaidMtd_AMNT), 0) AS ArrPaidMtd_AMNT,
          ISNULL(SUM(PR.ArrRecoupMtd_AMNT), 0) AS ArrRecoupMtd_AMNT,
          ISNULL(SUM(PR.ArrPaidUrg_AMNT), 0) AS ArrPaidUrg_AMNT,
          ISNULL(SUM(PR.ArrPaidMtdUrg_AMNT), 0) AS ArrPaidMtdUrg_AMNT
     FROM #TPRCP_P1 PR
    GROUP BY PR.Case_IDNO,
             PR.OrderSeq_NUMB,
             PR.ObligationSeq_NUMB,
             PR.CaseWelfare_IDNO;

     OPEN WemoCursor;

     FETCH NEXT FROM WemoCursor INTO @Ln_wemoCursor$Case_IDNO, @Ln_wemoCursor$OrderSeq_NUMB, @Ln_wemoCursor$ObligationSeq_NUMB, @Ln_wemoCursor$CaseWelfare_IDNO, @Ln_wemoCursor$ArrPaid_AMNT, @Ln_wemoCursor$ArrRecoup_AMNT, @Ln_wemoCursor$ArrPaidMtd_AMNT, @Ln_wemoCursor$ArrRecoupMtd_AMNT, @Ln_wemoCursor$ArrPaidUrg_AMNT, @Ln_wemoCursor$ArrPaidMtdUrg_AMNT;

     WHILE (@Li_Fetch_Status = 0)
      BEGIN
       
	  IF (@As_Screen_ID = 'MHIS')
	  BEGIN 
	     SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG - 1';
	     SET @Ls_Sqldata_TEXT = 'CaseWelfare_IDNO = ' + CAST(@An_CaseWelfare_IDNO AS VARCHAR) + ', CpMci_IDNO = ' + CAST(@Ln_CpMci_IDNO AS VARCHAR) + ', WelfareYearMonth_NUMB = ' + CAST(@Ln_AdjustYearMonth_NUMB AS VARCHAR) + ', SignedOnWorker_ID = ' + @Ac_SignedOnWorker_ID + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR) + ', Job_ID = ' + @As_Screen_ID;
	     
	     EXECUTE BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG
			@An_CaseWelfare_IDNO		= @An_CaseWelfare_IDNO,
			@An_CpMci_IDNO				= @Ln_CpMci_IDNO,
			@An_WelfareYearMonth_NUMB	= @Ln_AdjustYearMonth_NUMB, 
			@Ac_SignedOnWorker_ID		= @Ac_SignedOnWorker_ID,  
			@Ad_Run_DATE				= @Ad_Run_DATE ,  
			@Ac_Job_ID					= @As_Screen_ID,  
			@Ac_Msg_CODE				= @Lc_Msg_CODE OUTPUT,
			@As_DescriptionError_TEXT	= @Ls_DescriptionError_TEXT OUTPUT
	      
		 IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
		  BEGIN
		   SET @Ls_Sql_TEXT = 'BATCH_COMMON_PRORATE_GRANT$SP_GRANT_SPLIT_IVMG  FAILED';

		   RAISERROR(50001,16,1)
		  END
	    
	  END 
	  ELSE
		BEGIN    
       SET @Ls_Sql_TEXT = 'SELECT_VWEMO1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO  ' + ISNULL(CONVERT(CHAR(6), @Ln_wemoCursor$Case_IDNO), '') + ' OrderSeq_NUMB  ' + ISNULL(CAST(@Ln_wemoCursor$OrderSeq_NUMB AS CHAR(4)), '') + ' ObligationSeq_NUMB  ' + ISNULL(CAST(@Ln_wemoCursor$ObligationSeq_NUMB AS CHAR(4)), '') + ' CaseWelfare_IDNO  ' + ISNULL(CAST(@Ln_wemoCursor$CaseWelfare_IDNO AS VARCHAR), '') + ' WelfareYearMonth_NUMB  ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS CHAR(6)), '');

       SELECT @Ln_MtdAssistExpend_AMNT = W.MtdAssistExpend_AMNT,
              @Ln_LtdAssistExpend_AMNT = W.LtdAssistExpend_AMNT,
              @Ln_MtdAssistWemoRecoup_AMNT = W.MtdAssistRecoup_AMNT,
              @Ln_LtdAssistWemoRecoup_AMNT = W.LtdAssistRecoup_AMNT
         FROM WEMO_Y1 W
        WHERE W.Case_IDNO = @Ln_wemoCursor$Case_IDNO
          AND W.OrderSeq_NUMB = @Ln_wemoCursor$OrderSeq_NUMB
          AND W.ObligationSeq_NUMB = @Ln_wemoCursor$ObligationSeq_NUMB
          AND W.CaseWelfare_IDNO = @Ln_wemoCursor$CaseWelfare_IDNO
          AND W.WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
          AND W.EndValidity_DATE = @Ld_High_DATE;

       SET @Li_RowsAffected = @@ROWCOUNT;

       IF (@Li_RowsAffected = 0)
        BEGIN
         SELECT @Ln_LtdAssistExpend_AMNT = a.LtdAssistExpend_AMNT,
                @Ln_LtdAssistWemoRecoup_AMNT = a.LtdAssistRecoup_AMNT
           FROM WEMO_Y1 a
          WHERE a.Case_IDNO = @Ln_wemoCursor$Case_IDNO
            AND a.OrderSeq_NUMB = @Ln_wemoCursor$OrderSeq_NUMB
            AND a.ObligationSeq_NUMB = @Ln_wemoCursor$ObligationSeq_NUMB
            AND a.CaseWelfare_IDNO = @Ln_wemoCursor$CaseWelfare_IDNO
            AND a.WelfareYearMonth_NUMB = (SELECT MAX(b.WelfareYearMonth_NUMB)
                                             FROM WEMO_Y1 b
                                            WHERE b.Case_IDNO = a.Case_IDNO
                                              AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                              AND b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
                                              AND b.WelfareYearMonth_NUMB <= @Ln_AdjustYearMonth_NUMB
                                              AND b.EndValidity_DATE = @Ld_High_DATE)
            AND a.EndValidity_DATE = @Ld_High_DATE;

         SET @Li_RowsAffected = @@ROWCOUNT;

         IF (@Li_RowsAffected = 0)
          BEGIN
           SET @Ln_MtdAssistExpend_AMNT = 0;
           SET @Ln_LtdAssistExpend_AMNT = 0;
           SET @Ln_MtdAssistWemoRecoup_AMNT = 0;
           SET @Ln_LtdAssistWemoRecoup_AMNT = 0;
           SET @Ln_IvmgRecoup_AMNT = 0;
          END
        END
        
       SET @Ls_Sql_TEXT = 'UPDATE_WEMO_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO  ' + ISNULL(CAST(@Ln_wemoCursor$Case_IDNO AS VARCHAR), '') + ' OrderSeq_NUMB  ' + ISNULL(CAST(@Ln_wemoCursor$OrderSeq_NUMB AS VARCHAR), '') + ' ObligationSeq_NUMB  ' + ISNULL(CAST(@Ln_wemoCursor$ObligationSeq_NUMB AS VARCHAR), '') + ' CaseWelfare_IDNO  ' + ISNULL(CAST(@Ln_wemoCursor$CaseWelfare_IDNO AS VARCHAR), '')+ ' WelfareYearMonth_NUMB  ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS VARCHAR), '')

       UPDATE WEMO_Y1
          SET EndValidity_DATE = @Ld_End_DATE,
              EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
        WHERE Case_IDNO = @Ln_wemoCursor$Case_IDNO
          AND OrderSeq_NUMB = @Ln_wemoCursor$OrderSeq_NUMB
          AND ObligationSeq_NUMB = @Ln_wemoCursor$ObligationSeq_NUMB
          AND CaseWelfare_IDNO = @Ln_wemoCursor$CaseWelfare_IDNO
          AND WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
          AND EndValidity_DATE = @Ld_High_DATE;

       SET @Li_RowsAffected = @@ROWCOUNT;

       IF @Li_RowsAffected != 0
           OR (@Li_RowsAffected = 0
               AND (@Ln_wemoCursor$ArrPaid_AMNT <> 0
                     OR @Ln_wemoCursor$ArrRecoup_AMNT <> 0
                     OR @Ln_wemoCursor$ArrPaidMtd_AMNT <> 0
                     OR @Ln_wemoCursor$ArrRecoupMtd_AMNT <> 0
                     OR @Ln_wemoCursor$ArrPaidUrg_AMNT <> 0
                     OR @Ln_wemoCursor$ArrPaidMtdUrg_AMNT <> 0))
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERT_WEMO_Y1';
         SET @Ls_Sqldata_TEXT = 'Case_IDNO ' + ISNULL(CAST(@Ln_wemoCursor$Case_IDNO AS CHAR(6)), '') + ' OrderSeq_NUMB  ' + ISNULL(CAST(@Ln_wemoCursor$OrderSeq_NUMB AS CHAR(2)), '') + ' ObligationSeq_NUMB  ' + ISNULL(CAST(@Ln_wemoCursor$ObligationSeq_NUMB AS CHAR(2)), '') + ' CaseWelfare_IDNO  ' + ISNULL(CAST(@Ln_wemoCursor$CaseWelfare_IDNO AS VARCHAR), '')+ '  WelfareYearMonth_NUMB  ' + ISNULL(CAST(@Ln_AdjustYearMonth_NUMB AS CHAR(6)), '');

         INSERT WEMO_Y1
                (Case_IDNO,
                 OrderSeq_NUMB,
                 ObligationSeq_NUMB,
                 CaseWelfare_IDNO,
                 WelfareYearMonth_NUMB,
                 MtdAssistExpend_AMNT,
                 TransactionAssistExpend_AMNT,
                 LtdAssistExpend_AMNT,
                 MtdAssistRecoup_AMNT,
                 TransactionAssistRecoup_AMNT,
                 LtdAssistRecoup_AMNT,
                 BeginValidity_DATE,
                 EndValidity_DATE,
                 EventGlobalBeginSeq_NUMB,
                 EventGlobalEndSeq_NUMB)
         VALUES ( @Ln_wemoCursor$Case_IDNO,
                  @Ln_wemoCursor$OrderSeq_NUMB,
                  @Ln_wemoCursor$ObligationSeq_NUMB,
                  @Ln_wemoCursor$CaseWelfare_IDNO,
                  @Ln_AdjustYearMonth_NUMB,
                  @Ln_wemoCursor$ArrPaidMtd_AMNT + @Ln_wemoCursor$ArrPaidMtdUrg_AMNT,
                  @Ln_wemoCursor$ArrPaid_AMNT - @Ln_LtdAssistExpend_AMNT + @Ln_wemoCursor$ArrPaidMtd_AMNT + @Ln_wemoCursor$ArrPaidMtdUrg_AMNT + @Ln_wemoCursor$ArrPaidUrg_AMNT,
                  @Ln_wemoCursor$ArrPaid_AMNT + @Ln_wemoCursor$ArrPaidMtd_AMNT + @Ln_wemoCursor$ArrPaidMtdUrg_AMNT + @Ln_wemoCursor$ArrPaidUrg_AMNT,
                  @Ln_wemoCursor$ArrRecoupMtd_AMNT,
                  @Ln_wemoCursor$ArrRecoup_AMNT - @Ln_LtdAssistWemoRecoup_AMNT + @Ln_wemoCursor$ArrRecoupMtd_AMNT,
                  @Ln_wemoCursor$ArrRecoup_AMNT + @Ln_wemoCursor$ArrRecoupMtd_AMNT,
                  @Ld_End_DATE,
                  @Ld_High_DATE,
                  @Ln_EventGlobalSeq_NUMB,
                  0);

		 SET @Li_RowsAffected = @@ROWCOUNT;

         IF @Li_RowsAffected = 0
          BEGIN
           SET @Ls_Sql_TEXT = 'INSERT_VWEMO1 FAILED';

           RAISERROR(50001,16,1);
          END
         END 

		END

       IF EXISTS(SELECT 1
                   FROM MHIS_Y1 b,
                        (SELECT TOP 1 OB.MemberMci_IDNO
                           FROM OBLE_Y1 OB
                          WHERE OB.Case_IDNO = @Ln_wemoCursor$Case_IDNO
                            AND OB.OrderSeq_NUMB = @Ln_wemoCursor$OrderSeq_NUMB
                            AND OB.ObligationSeq_NUMB = @Ln_wemoCursor$ObligationSeq_NUMB
                            AND OB.EndValidity_DATE = @Ld_High_DATE) AS a
                  WHERE b.Case_IDNO = @Ln_wemoCursor$Case_IDNO
                    AND b.MemberMci_IDNO = a.MemberMci_IDNO
                    AND @Ld_Start_DATE BETWEEN b.Start_DATE AND b.End_DATE 
                    AND b.TypeWelfare_CODE IN (@Lc_WelfareTypeNonTanf_CODE, @Lc_WelfareTypeMedicaid_CODE)
                    )
        BEGIN
         SET @Ls_WemoFlag_INDC = @Lc_Yes_INDC;

         INSERT INTO @Lt_GrantData_TAB
         SELECT @Ln_wemoCursor$Case_IDNO,
                @Ln_wemoCursor$OrderSeq_NUMB,
                @Ln_wemoCursor$ObligationSeq_NUMB,
                @Ln_AdjustYearMonth_NUMB
          WHERE NOT EXISTS (SELECT 1
                              FROM @Lt_GrantData_TAB grnt_tab
                             WHERE grnt_tab.Case_IDNO = @Ln_wemoCursor$Case_IDNO
                               AND grnt_tab.OrderSeq_NUMB = @Ln_wemoCursor$OrderSeq_NUMB
                               AND grnt_tab.ObligationSeq_NUMB = @Ln_wemoCursor$ObligationSeq_NUMB
                               AND grnt_tab.ObligationSeq_NUMB = @Ln_AdjustYearMonth_NUMB);

         SET @Li_RowsAffected = @@ROWCOUNT;

         IF @Li_RowsAffected = 0
          BEGIN
			SET @Ls_WemoFlag_INDC =@Lc_No_INDC
          END
        END;
     
     FETCH NEXT FROM WemoCursor INTO @Ln_wemoCursor$Case_IDNO, @Ln_wemoCursor$OrderSeq_NUMB, @Ln_wemoCursor$ObligationSeq_NUMB, @Ln_wemoCursor$CaseWelfare_IDNO, @Ln_wemoCursor$ArrPaid_AMNT, @Ln_wemoCursor$ArrRecoup_AMNT, @Ln_wemoCursor$ArrPaidMtd_AMNT, @Ln_wemoCursor$ArrRecoupMtd_AMNT, @Ln_wemoCursor$ArrPaidUrg_AMNT, @Ln_wemoCursor$ArrPaidMtdUrg_AMNT;

     SET @Li_Fetch_Status = @@FETCH_STATUS;
     END;
     CLOSE WemoCursor;

     DEALLOCATE WemoCursor;

	 IF (@As_Screen_ID != 'MHIS')
	   BEGIN
		 SET @Ls_Sql_TEXT = 'INSERT_ZERO_VWEMO'

		 INSERT WEMO_Y1
			   (Case_IDNO,
				OrderSeq_NUMB,
				ObligationSeq_NUMB,
				CaseWelfare_IDNO,
				WelfareYearMonth_NUMB,
				TransactionAssistExpend_AMNT,
				MtdAssistExpend_AMNT,
				LtdAssistExpend_AMNT,
				TransactionAssistRecoup_AMNT,
				MtdAssistRecoup_AMNT,
				LtdAssistRecoup_AMNT,
				EventGlobalBeginSeq_NUMB,
				EventGlobalEndSeq_NUMB,
				BeginValidity_DATE,
				EndValidity_DATE
				)
		 SELECT a.Case_IDNO,
				a.OrderSeq_NUMB,
				a.ObligationSeq_NUMB,
				a.CaseWelfare_IDNO,
				a.WelfareYearMonth_NUMB,
				0 AS TransactionAssistExpend_AMNT,
				0 AS MtdAssistExpend_AMNT,
				0 AS LtdAssistExpend_AMNT,
				0 AS TransactionAssistRecoup_AMNT,
				0 AS MtdAssistRecoup_AMNT,
				0 AS LtdAssistRecoup_AMNT,
				@Ln_EventGlobalSeq_NUMB AS EventGlobalBeginSeq_NUMB,
				0 AS EventGlobalEndSeq_NUMB,
				@Ld_End_DATE AS BeginValidity_DATE,
				@Ld_High_DATE AS EndValidity_DATE
		   FROM WEMO_Y1 a
		  WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
			AND a.WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
			AND a.EndValidity_DATE = @Ld_High_DATE
			AND a.WelfareYearMonth_NUMB = (SELECT MAX(c.WelfareYearMonth_NUMB)
											 FROM dbo.WEMO_Y1 AS c
											WHERE c.CaseWelfare_IDNO = a.CaseWelfare_IDNO
											  AND c.Case_IDNO = a.Case_IDNO
											  AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
											  AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
											  AND c.EndValidity_DATE = @Ld_High_DATE)
			AND NOT EXISTS (SELECT 1
							  FROM #TPRCP_P1 AS b
							 WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
							   AND b.Case_IDNO = a.Case_IDNO
							   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
							   AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
		  AND a.Case_IDNO IN ( SELECT Case_IDNO FROM CMEM_Y1 b
									WHERE b.MemberMci_IDNO = @Ln_CpMci_IDNO
									AND b.CaseRelationship_CODE = @Lc_CaseRelationShipCP_CODE
									AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE);
	                           
		 SET @Ls_Sql_TEXT = 'UPDATE_VWEMO2';

		 UPDATE a
			SET a.EndValidity_DATE = @Ld_End_DATE,
				a.EventGlobalEndSeq_NUMB = @Ln_EventGlobalSeq_NUMB
		   FROM WEMO_Y1 a
		  WHERE a.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
			AND a.WelfareYearMonth_NUMB = @Ln_AdjustYearMonth_NUMB
			AND a.EndValidity_DATE = @Ld_High_DATE
			AND a.EventGlobalBeginSeq_NUMB < @Ln_EventGlobalSeq_NUMB
			AND NOT EXISTS (SELECT 1
							  FROM #TPRCP_P1 AS b
							 WHERE b.CaseWelfare_IDNO = a.CaseWelfare_IDNO
							   AND b.Case_IDNO = a.Case_IDNO
							   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
							   AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
			AND a.Case_IDNO IN ( SELECT Case_IDNO FROM CMEM_Y1 b
								 WHERE b.MemberMci_IDNO = @Ln_CpMci_IDNO
								AND b.CaseRelationship_CODE = @Lc_CaseRelationShipCP_CODE
								AND b.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE);
	   END
 
	 DELETE TMEMB_Y1;

     DELETE TPRAT_Y1;

     DELETE TPRCP_Y1;

     NEXT_FETCH:

     SET @Ld_Start_DATE = DATEADD(m, 1, @Ld_Start_DATE)

     IF(YEAR(@Ld_Start_DATE) * 100 + MONTH(@Ld_Start_DATE)) = (YEAR(@Ld_End_DATE) * 100 + MONTH(@Ld_End_DATE))
      BEGIN
       SET @Ld_Start_DATE = @Ld_End_DATE
      END
    END-- loop
  
   IF @Ac_LastRec_INDC = @Lc_No_INDC
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;

     RETURN;
    END

   DECLARE GrantData_Cursor CURSOR FOR
    SELECT Case_IDNO,
           OrderSeq_NUMB,
           ObligationSeq_NUMB,
           MonthAdjust_NUMB
      FROM @Lt_GrantData_TAB;
      
   OPEN GrantData_Cursor

   FETCH NEXT FROM GrantData_Cursor INTO @GrantData_Cursor$Case_IDNO, @GrantData_Cursor$OrderSeq_NUMB, @GrantData_Cursor$ObligationSeq_NUMB, @GrantData_Cursor$Support_DTYM;
   
   SET @Li_Fetch_Status = @@FETCH_STATUS;

   WHILE (@Li_Fetch_Status = 0)
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REASSIGN_ARREARS';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO  ' + ISNULL(CAST(@GrantData_Cursor$Case_IDNO AS CHAR(6)), '') + ' OrderSeq_NUMB  ' + ISNULL(CAST(@GrantData_Cursor$OrderSeq_NUMB AS CHAR(4)), '') + ' ObligationSeq_NUMB ' + ISNULL(CAST(@GrantData_Cursor$ObligationSeq_NUMB AS CHAR(4)), '');

     EXECUTE BATCH_COMMON$SP_REASSIGN_ARREARS
      @An_Case_IDNO             = @GrantData_Cursor$Case_IDNO,
      @An_OrderSeq_NUMB         = @GrantData_Cursor$OrderSeq_NUMB,
      @An_ObligationSeq_NUMB    = @GrantData_Cursor$ObligationSeq_NUMB,
      @An_SupportYearMonth_NUMB = @GrantData_Cursor$Support_DTYM,
      @An_CpMci_IDNO			= @Ln_CpMci_IDNO,
      @An_EventGlobalSeq_NUMB   = @Ln_EventGlobalSeq_NUMB,
      @Ac_Screen_ID             = @Lc_ScreenCmem_ID,
      @Ad_Process_DATE			= @Ad_Run_DATE,
      @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

     IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_REASSIGN_ARREARS FAILED';

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM GrantData_Cursor INTO @GrantData_Cursor$Case_IDNO, @GrantData_Cursor$OrderSeq_NUMB, @GrantData_Cursor$ObligationSeq_NUMB, @GrantData_Cursor$Support_DTYM;

     SET @Li_Fetch_Status = @@FETCH_STATUS;
    END
     CLOSE GrantData_Cursor;

     DEALLOCATE GrantData_Cursor;

   DELETE FROM @Lt_GrantData_TAB;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('local', 'WemoCursor') IN (0, 1)
    BEGIN
     CLOSE WemoCursor;

     DEALLOCATE WemoCursor;
    END

   DECLARE @Ln_Error_NUMB     INT,
           @Ln_ErrorLine_NUMB INT;

   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB = 50001
    BEGIN
     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END
   ELSE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);

     EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
      @As_Procedure_NAME        = @Ls_Procedure_NAME,
      @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
      @As_Sql_TEXT              = @Ls_Sql_TEXT,
      @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
      @An_Error_NUMB            = @Ln_Error_NUMB,
      @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
      @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
