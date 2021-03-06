/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE
Programmer Name   : IMP Team
Description       : This is used to close Case by using all active records
Frequency         :
Developed On      : 01/05/2012
Called By         : BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On         : BATCH_COMMON$SP_INSERT_PENDING_REQUEST and BATCH_COMMON$SP_UPDATE_CASE_DETAILS 
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC (10),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @An_MajorIntSeq_NUMB         NUMERIC(5),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ac_Process_ID               CHAR(10),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE				CHAR(1)		= 'S',
          @Lc_StatusFailed_CODE					CHAR(1)		= 'F',
          @Lc_Yes_INDC							CHAR(1)		= 'Y',
          @Lc_No_INDC							CHAR(1)		= 'N',
          @Lc_Space_TEXT						CHAR(1)		= ' ',
          @Lc_TypePostingPayor_CODE				CHAR(1)		= 'P',
          @Lc_CaseRelationshipNCP_CODE			CHAR(1)		= 'A',
          @Lc_CaseRelationshipPutFather_CODE	CHAR(1)		= 'P',
          @Lc_RespondInitC_CODE					CHAR(1)		= 'C',
		  @Lc_RespondInitI_CODE					CHAR(1)		= 'I',
		  @Lc_RespondInitT_CODE					CHAR(1)		= 'T',
		  @Lc_RespondInitN_CODE					CHAR(1)		= 'N',
		  @Lc_ActionAlertA_CODE					CHAR(1)		= 'A',
          @Lc_CaseMemberStatusActive_CODE		CHAR(1)		= 'A',
          @Lc_StatusCaseOpen_CODE				CHAR(1)		= 'O',
          @Lc_StatusCaseClosed_CODE				CHAR(1)		= 'C',
          @Lc_StatusCaseExempt_CODE				CHAR(1)		= 'E',
          @Lc_StatusEstablishOpen_CODE			CHAR(1)		= 'O',
          @Lc_StatusEnforcementOpen_CODE		CHAR(1)		= 'O',
          @Lc_StatusHeldReceipt_CODE			CHAR(1)		= 'H',
          @Lc_StatusComplete_CODE				CHAR(1)		= 'C',
          @Lc_ActionP_CODE						CHAR(1)		= 'P',
          @Lc_CaseCategory_CODE					CHAR(2)		= ' ',
          @Lc_ReceiptSrcAc_CODE					CHAR(2)		= 'AC',
          @Lc_ReceiptSrcAn_CODE					CHAR(2)		= 'AN',
          @Lc_StatusBatchComplete_CODE			CHAR(2)		= 'BC',
          @Lc_ReasonFirstActivity_CODE			CHAR(2)		= ' ',
          @Lc_ReasonStatusZn_CODE				CHAR(2)		= 'ZN',
          @Lc_FunctionMsc_CODE					CHAR(3)		= 'MSC',
          --13819 - CPRO - Case Closure chain would not advance because of active Federal Timer alerts - START - 
          @Lc_ProcessFdrl_ID					CHAR(4)		= 'FDRL',
          --13819 - CPRO - Case Closure chain would not advance because of active Federal Timer alerts - END - 
          @Lc_ProcessCpro_ID					CHAR(4)		= 'CPRO',
          @Lc_StatusStart_CODE					CHAR(4)		= 'STRT',
          @Lc_ReasonStatusSdna_CODE				CHAR(4)		= 'SDNA',
          @Lc_ActivityMajorCase_CODE			CHAR(4)		= 'CASE',
          @Lc_ReasonGsc18_CODE					CHAR(5)		= 'GSC18',
          @Lc_ActivityMinorWsccc_CODE			CHAR(5)		= 'WSCCC',
          @Lc_BatchrRunUser_ID					CHAR(30)	= 'BATCH',
          @Ls_Routine_TEXT						VARCHAR(50)	= 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE',
          @Ld_High_DATE							DATE		= '12/31/9999',
          @Ld_Low_DATE							DATE		= '01/01/0001',
          @Ld_Update_DTTM						DATETIME2	= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Li_Error_NUMB						INT,
          @Li_ErrorLine_NUMB					INT,
          @Li_FetchStatus_QNTY					SMALLINT,
          @Ln_RowCount_QNTY						NUMERIC,
          @Ln_Zero_NUMB							NUMERIC(1)			= 0,
          @Ln_TempValidation_QNTY				NUMERIC				= 0,
          @Ln_RecpNotDistributed_NUMB			NUMERIC(9)			= 0,
          @Ln_OrderSeq_NUMB						NUMERIC(9)			= 0,
          @Ln_RecepitHeld_NUMB					NUMERIC(9)			= 0,
          @Ln_ActiveSord_NUMB					NUMERIC(9)			= 0,
          @Ln_ChainStartStatus_NUMB				NUMERIC(9)			= 0,
          @Ln_ActionAlert_QNTY					NUMERIC(9)			= 0,
          @Ln_Arrears_AMNT						NUMERIC(11, 2)		= 0,
          @Lc_ReferLocate_INDC					CHAR(1)				= ' ',
          @Lc_RespondInit_CODE					CHAR(1),
          @Lc_GoodCause_CODE					CHAR(1),
          @Lc_NonCoop_CODE						CHAR(1),
          @Lc_RsnStatusCase_CODE				CHAR(2),
          @Lc_SourceRfrl_CODE					CHAR(3),
          @Lc_Reason_CODE						CHAR(5),
          @Lc_File_ID							CHAR(15),
          @Ls_Sql_TEXT							VARCHAR(300),
          @Ls_Sqldata_TEXT						VARCHAR(3000),
          @Ls_DescriptionError_TEXT				VARCHAR(4000),
          @Ld_GoodCause_DATE					DATE,
          @Ld_NonCoop_DATE						DATE;
          
  DECLARE @Lc_CsnetCur_RespondInit_CODE					CHAR(1),
		  @Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT       CHAR(2),
          @Lc_CsnetCur_IVDOutOfStateCountyFipsCode_TEXT CHAR(3),
          @Lc_CsnetCur_IVDOutOfStateOfficeFipsCode_TEXT CHAR(2),
          @Lc_CsnetCur_IVDOutOfStateCaseId_TEXT         CHAR(15);
  DECLARE Csnet_Cur INSENSITIVE CURSOR FOR
   SELECT DISTINCT i.RespondInit_CODE,
		  i.IVDOutOfStateFips_CODE,
          i.IVDOutOfStateCountyFips_CODE,
          i.IVDOutOfStateOfficeFips_CODE,
          i.IVDOutOfStateCase_ID
     FROM ICAS_Y1 i
    WHERE i.Case_IDNO = @An_Case_IDNO
      AND i.EndValidity_DATE = @Ld_High_DATE
      AND (i.Status_CODE = @Lc_StatusCaseOpen_CODE
	   OR
      (i.Status_CODE = @Lc_StatusCaseClosed_CODE
      AND i.End_DATE BETWEEN DATEADD(M, -3 ,@Ad_Run_DATE)  AND @Ld_High_DATE));

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE SELECT SORD_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');

   SELECT @Ln_OrderSeq_NUMB = MAX(OrderSeq_NUMB)
     FROM SORD_Y1 S
    WHERE Case_IDNO = @An_Case_IDNO;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE SELECT VRCTH';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', MemberMci_IDNO  = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '') + ', BackOut_INDC = ' + @Lc_Yes_INDC;

	   SELECT @Ln_RecpNotDistributed_NUMB = COUNT(1)
		 FROM (SELECT TOP 1 1 AS Cnt 
				 FROM RCTH_Y1 o
				WHERE o.Case_IDNO = @An_Case_IDNO
				  AND o.Distribute_DATE = @Ld_Low_DATE
				  AND o.EndValidity_DATE = @Ld_High_DATE
				  -- These RCTH_Y1 source should NOT be considered AS RCTH_Y1 sources, so they are excluded FROM query.
				  AND o.SourceReceipt_CODE NOT IN(@Lc_ReceiptSrcAc_CODE, @Lc_ReceiptSrcAn_CODE)
              AND NOT EXISTS (SELECT 1
                                FROM ELRP_Y1 i
                               WHERE o.Batch_DATE = i.BatchOrig_DATE
                                 AND o.SourceBatch_CODE = i.SourceBatchOrig_CODE
                                 AND o.Batch_NUMB = i.BatchOrig_NUMB
                                 AND o.SeqReceipt_NUMB = i.SeqReceiptOrig_NUMB)) a; 
		   IF (@Ln_RecpNotDistributed_NUMB = 0)
			BEGIN

				SELECT TOP 1 @Ln_TempValidation_QNTY = 1
				  WHERE EXISTS (SELECT 1
								  FROM CMEM_Y1 c
								 WHERE c.MemberMci_IDNO = @An_MemberMci_IDNO
								   AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNCP_CODE, @Lc_CaseRelationshipPutFather_CODE)
								   AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
					AND EXISTS (SELECT 1
						   FROM (SELECT COUNT(1) Count_QNTY
								   FROM CMEM_Y1 m,
										CASE_Y1 c
								  WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO
									AND m.Case_IDNO = c.Case_IDNO
									AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
								  GROUP BY m.MemberMci_IDNO) x
						  WHERE x.Count_QNTY = 1);

				 IF (@Ln_TempValidation_QNTY = 1)
				  BEGIN
				   SELECT TOP 1 @Ln_RecpNotDistributed_NUMB = 1
					 FROM RCTH_Y1 o
					WHERE o.PayorMCI_IDNO = @An_MemberMci_IDNO
					  AND o.Distribute_DATE = @Ld_Low_DATE
					  AND o.EndValidity_DATE = @Ld_High_DATE
					  AND o.TypePosting_CODE = @Lc_TypePostingPayor_CODE
					  AND o.Case_IDNO = 0
					  AND o.SourceReceipt_CODE NOT IN(@Lc_ReceiptSrcAc_CODE, @Lc_ReceiptSrcAn_CODE)
					  AND NOT EXISTS (SELECT 1
										FROM ELRP_Y1 i
									   WHERE o.Batch_DATE = i.BatchOrig_DATE
										 AND o.SourceBatch_CODE = i.SourceBatchOrig_CODE
										 AND o.Batch_NUMB = i.BatchOrig_NUMB
										 AND o.SeqReceipt_NUMB = i.SeqReceiptOrig_NUMB);
				  END;
				END;							 

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE SELECT VDHLD';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', MemberMci_IDNO  = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(5)), '') + ', Status_CODE = ' + @Lc_StatusHeldReceipt_CODE;

   SELECT @Ln_RecepitHeld_NUMB = COUNT(1)
     FROM DHLD_Y1 d
    WHERE d.Case_IDNO = @An_Case_IDNO
          -- CASE closure activity chains can have Seq_IDNO ORDER AS 0 OR 1. So, the below code has changed.
          AND d.OrderSeq_NUMB IN (@An_OrderSeq_NUMB, @Ln_OrderSeq_NUMB)
          AND Status_CODE = @Lc_StatusHeldReceipt_CODE
          -- Code changed FOR looking reason OF receipts hold IS NOT SDNA
          AND d.ReasonStatus_CODE != @Lc_ReasonStatusSdna_CODE
          AND EndValidity_DATE = @Ld_High_DATE;

   SELECT @Ln_ActiveSord_NUMB = COUNT(1)
     FROM SORD_Y1 d
    WHERE d.Case_IDNO = @An_Case_IDNO
          -- Case closure activity chains can have seq order as 0 or 1. So, the below code has changed.
          AND d.OrderSeq_NUMB IN (@An_OrderSeq_NUMB, @Ln_OrderSeq_NUMB)
          AND EndValidity_DATE = @Ld_High_DATE
          AND @Ad_Run_DATE < OrderEnd_DATE;

   SELECT @Ln_ChainStartStatus_NUMB = COUNT(1)
     FROM DMJR_Y1 j
    WHERE j.Case_IDNO = @An_Case_IDNO
      AND j.ActivityMajor_CODE NOT IN (@Ac_ActivityMajor_CODE, @Lc_ActivityMajorCase_CODE)
      AND j.Status_CODE = @Lc_StatusStart_CODE;

   -- Case Cloure - Check for Arrears at FCPRO
   SET @Ln_Arrears_AMNT = DBO.BATCH_COMMON$SF_GET_ARREARS(@An_Case_IDNO, CAST(CONVERT(VARCHAR(6), @Ad_Run_DATE, 112) AS NUMERIC));
   
   --13074 - CASE_CLOSURE - CR0342 Add a Validation to the Case Closure Chain - START -   
   SELECT @Ln_ActionAlert_QNTY = COUNT(1) 
	 FROM AMNR_Y1 a
	 JOIN DMNR_Y1 d 
	ON d.Case_IDNO = @An_Case_IDNO
	  AND d.ActivityMinor_CODE = a.ActivityMinor_CODE
	  AND d.Status_CODE = @Lc_StatusStart_CODE
      AND d.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
	WHERE a.ActionAlert_CODE = @Lc_ActionAlertA_CODE
      AND a.EndValidity_DATE = @Ld_High_DATE
      --13819 - CPRO - Case Closure chain would not advance because of active Federal Timer alerts - START - 
      AND NOT EXISTS ( SELECT 1
						FROM RESF_Y1 r
					   WHERE r.Process_ID = @Lc_ProcessFdrl_ID
						 AND r.Reason_CODE = d.ActivityMinor_CODE );
	  --13819 - CPRO - Case Closure chain would not advance because of active Federal Timer alerts - END - 
					

   IF @Ln_RecpNotDistributed_NUMB > 0
       OR @Ln_RecepitHeld_NUMB > 0
       OR @Ln_ActiveSord_NUMB > 0
       OR @Ln_ChainStartStatus_NUMB > 0
       OR @Ln_Arrears_AMNT > 0
       OR @Ln_ActionAlert_QNTY > 0
    BEGIN
     SET @Ac_Msg_CODE = 'E0788';
     SET @As_DescriptionError_TEXT = 'Check WRKL, CPRO, ELOG, SORD for open actions before closing case';
     RETURN;
    END
    --13074 - CASE_CLOSURE - CR0342 Add a Validation to the Case Closure Chain - END -

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE : SELECT VACES';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', StatusEstablish_CODE = ' + @Lc_StatusEstablishOpen_CODE;

   --- Establishment						  
   SELECT @Ln_Zero_NUMB = COUNT(1)
     FROM ACES_Y1 a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.StatusEstablish_CODE = @Lc_StatusEstablishOpen_CODE
      AND a.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Zero_NUMB > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE : UPDATE VACES';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(10)) + ', StatusEstablish_CODE = ' + @Lc_StatusEstablishOpen_CODE;

     UPDATE ACES_Y1
        SET EndValidity_DATE = @Ad_Run_DATE
     OUTPUT DELETED.Case_IDNO,
            DELETED.BeginEstablishment_DATE,
            @Lc_StatusComplete_CODE AS StatusEstablish_CODE,
            @Lc_StatusBatchComplete_CODE AS ReasonStatus_CODE,
            @Ad_Run_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            @Lc_BatchrRunUser_ID AS WorkerUpdate_ID,
            @Ld_Update_DTTM AS Update_DTTM,
            @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
     INTO ACES_Y1 (Case_IDNO, BeginEstablishment_DATE, StatusEstablish_CODE, ReasonStatus_CODE, BeginValidity_DATE, EndValidity_DATE, WorkerUpdate_ID, Update_DTTM, TransactionEventSeq_NUMB)
      WHERE Case_IDNO = @An_Case_IDNO
        AND StatusEstablish_CODE = @Lc_StatusEstablishOpen_CODE
        AND EndValidity_DATE = @Ld_High_DATE;


     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE : UPDATE VACES FAILED' + ' ' + @Ls_Sqldata_TEXT;

       RAISERROR (50001,16,1);
      END
    END

   --- ENFORCEMENT
   SELECT @Ln_Zero_NUMB = COUNT(1)
     FROM ACEN_Y1 a
    WHERE a.Case_IDNO = @An_Case_IDNO
      AND a.StatusEnforce_CODE IN(@Lc_StatusEnforcementOpen_CODE, @Lc_StatusCaseExempt_CODE)
      AND a.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Zero_NUMB > 0
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE : INSERT ACEN_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');

     INSERT INTO ACEN_Y1
                 (Case_IDNO,
                  OrderSeq_NUMB,
                  BeginEnforcement_DATE,
                  StatusEnforce_CODE,
                  ReasonStatus_CODE,
                  BeginExempt_DATE,
                  EndExempt_DATE,
                  BeginValidity_DATE,
                  EndValidity_DATE,
                  WorkerUpdate_ID,
                  Update_DTTM,
                  TransactionEventSeq_NUMB)
     SELECT a.Case_IDNO,
            a.OrderSeq_NUMB,
            a.BeginEnforcement_DATE,
            @Lc_StatusComplete_CODE AS StatusEnforce_CODE,
            @Lc_StatusBatchComplete_CODE AS ReasonStatus_CODE,
            @Ld_Low_DATE AS BeginExempt_DATE,
            @Ld_Low_DATE AS EndExempt_DATE,
            @Ad_Run_DATE AS BeginValidity_DATE,
            @Ld_High_DATE AS EndValidity_DATE,
            @Lc_BatchrRunUser_ID AS WorkerUpdate_ID,
            @Ld_Update_DTTM AS Update_DTTM,
            @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
       FROM ACEN_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE : INSERT ACEN_Y1 FAILED' + ' ' + @Ls_Sqldata_TEXT;

       RAISERROR (50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE : UPDATE ACEN_Y1';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Run_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(15)), '') + ', StatusEstablish_CODE = ' + ISNULL(CAST(@Lc_StatusEstablishOpen_CODE AS VARCHAR (4)), '');

     UPDATE ACEN_Y1
        SET EndValidity_DATE = @Ad_Run_DATE
      WHERE Case_IDNO = @An_Case_IDNO
        AND StatusEnforce_CODE IN(@Lc_StatusEnforcementOpen_CODE, @Lc_StatusCaseExempt_CODE)
        AND EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF @Ln_RowCount_QNTY = 0
      BEGIN
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
       SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE : UPDATE ACEN_Y1 FAILED' + ' ' + @Ls_Sqldata_TEXT;

       RAISERROR (50001,16,1);
      END
    END

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE SELECT CASE_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');

   SELECT @Lc_GoodCause_CODE = c.GoodCause_CODE,
          @Ld_GoodCause_DATE = c.GoodCause_DATE,
          @Lc_NonCoop_CODE = c.NonCoop_CODE,
          @Ld_NonCoop_DATE = c.NonCoop_DATE,
          @Lc_CaseCategory_CODE = c.CaseCategory_CODE,
          @Lc_File_ID = c.File_ID,
          @Lc_RespondInit_CODE = c.RespondInit_CODE
     FROM CASE_Y1 c
    WHERE c.Case_IDNO = @An_Case_IDNO;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE SELECT CASE FROM LSTT_Y1';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR(10)), '');

   SELECT @Lc_ReferLocate_INDC = ISNULL(l.ReferLocate_INDC, @Lc_Space_TEXT)
     FROM LSTT_Y1 l
    WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
      AND l.EndValidity_DATE = @Ld_High_DATE;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE SELECT CASE CLOSURE REASON FROM FOR CONVERSION RECORDS';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(5)), '') + ', MajorIntSEQ_NUMB = ' + ISNULL(CAST(@An_MajorIntSeq_NUMB AS VARCHAR(5)), '') + ', WorkerUpdate_ID = ' + ISNULL(CAST(@Ac_WorkerUpdate_ID AS VARCHAR(30)), '');

   SELECT @Lc_ReasonFirstActivity_CODE = MAX(d.Reference_ID)
     FROM DMJR_Y1 d
    WHERE d.Case_IDNO = @An_Case_IDNO
      AND d.MajorIntSEQ_NUMB = @An_MajorIntSeq_NUMB;

   IF LTRIM(RTRIM(@Lc_ReasonFirstActivity_CODE)) IS NULL
    BEGIN
     SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE SELECT DMNR';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', OrderSeq_NUMB = ' + ISNULL(CAST(@An_OrderSeq_NUMB AS VARCHAR(5)), '') + ', MajorIntSEQ_NUMB = ' + ISNULL(CAST(@An_MajorIntSeq_NUMB AS VARCHAR(5)), '') + ', WorkerUpdate_ID = ' + ISNULL(CAST(@Ac_WorkerUpdate_ID AS VARCHAR(30)), '');

     SELECT @Lc_ReasonFirstActivity_CODE = MAX(d.ReasonStatus_CODE)
       FROM DMNR_Y1 d
      WHERE d.Case_IDNO = @An_Case_IDNO
        AND d.MajorIntSEQ_NUMB = @An_MajorIntSeq_NUMB
        AND d.MinorIntSeq_NUMB = 1;

     IF @Lc_ReasonFirstActivity_CODE = @Lc_ReasonStatusZn_CODE
      BEGIN
       SELECT @Lc_ReasonFirstActivity_CODE = MAX(d.ReasonStatus_CODE)
         FROM DMNR_Y1 d
        WHERE d.Case_IDNO = @An_Case_IDNO
          AND d.MajorIntSEQ_NUMB = @An_MajorIntSeq_NUMB
          AND d.ActivityMinor_CODE = @Lc_ActivityMinorWsccc_CODE;
      END
    END
   
   SET @Ls_Sql_TEXT = 'SELECT RESF_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', MajorIntSEQ_NUMB = ' + ISNULL(CAST(@An_MajorIntSeq_NUMB AS VARCHAR(5)), '') + ', Process_ID = '+@Lc_ProcessCpro_ID+' ,Type_CODE = '+@Lc_ReasonFirstActivity_CODE;

   SELECT @Lc_Reason_CODE = r.Reason_CODE
	 FROM RESF_Y1 r
	WHERE r.Process_ID = @Lc_ProcessCpro_ID
	  AND r.Type_CODE = @Lc_ReasonFirstActivity_CODE;
	  
   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE SELECT FILE NUMBER FROM CASE';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', StatusCase_CODE = ' + ISNULL(CAST(@Lc_StatusCaseOpen_CODE AS VARCHAR(1)), '');

   OPEN Csnet_Cur;

    FETCH NEXT FROM Csnet_Cur INTO @Lc_CsnetCur_RespondInit_CODE, @Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT, @Lc_CsnetCur_IVDOutOfStateCountyFipsCode_TEXT, @Lc_CsnetCur_IVDOutOfStateOfficeFipsCode_TEXT, @Lc_CsnetCur_IVDOutOfStateCaseId_TEXT;

   BEGIN
    SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
	-- While loop begins
    WHILE @Li_FetchStatus_QNTY = 0
     BEGIN
     -- GSC18 reason code Csnet transaction is generated for the response to Reason code GSC17
     -- Other Csnet transaction is generated only if the Case is in initiating state.
     IF (@Lc_Reason_CODE != @Lc_Space_TEXT 
		AND (@Lc_Reason_CODE = @Lc_ReasonGsc18_CODE OR @Lc_CsnetCur_RespondInit_CODE IN (@Lc_RespondInitC_CODE, @Lc_RespondInitI_CODE, @Lc_RespondInitT_CODE)))
	  BEGIN
		  SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE BATCH_COMMON$SP_INSERT_PENDING_REQUEST';
		  SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', Generated_DATE = ' + ISNULL(CAST(@Ad_Run_DATE AS VARCHAR(15)), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(CAST(@Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT AS VARCHAR(2)), '') + ', IVDOutOfStateCountyFips_CODE = ' + ISNULL(CAST(@Lc_CsnetCur_IVDOutOfStateCountyFipsCode_TEXT AS VARCHAR(3)), '') + ', IVDOutOfStateOfficeFips_CODE = ' + ISNULL(CAST(@Lc_CsnetCur_IVDOutOfStateOfficeFipsCode_TEXT AS VARCHAR(2)), '') + ', ExchangeMode_CODE  = ' + @Lc_Space_TEXT + ', Function_CODE  = ' + @Lc_FunctionMsc_CODE + ', Form_ID  = ' + '0' + ', Action_CODE = ' + ISNULL(CAST(@Lc_ActionP_CODE AS VARCHAR(1)), '') + ', Reason_CODE = ' + ISNULL(CAST(@Lc_Reason_CODE AS VARCHAR(5)), '') + ', IVDOutOfStateCase_ID = ' + ISNULL(CAST(@Lc_CsnetCur_IVDOutOfStateCaseId_TEXT AS VARCHAR(16)), '') + ', FILE_ID = ' + ISNULL(CAST(@Lc_File_ID AS VARCHAR(40)), '');

		  EXEC BATCH_COMMON$SP_INSERT_PENDING_REQUEST
		   @An_Case_IDNO                    = @An_Case_IDNO,
		   @An_RespondentMci_IDNO           = @An_MemberMci_IDNO,
		   @Ac_Function_CODE                = @Lc_FunctionMsc_CODE,
		   @Ac_Action_CODE                  = @Lc_ActionP_CODE,
		   @Ac_Reason_CODE                  = @Lc_Reason_CODE,
		   @Ac_IVDOutOfStateFips_CODE       = @Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT,
		   @Ac_IVDOutOfStateCountyFips_CODE = @Lc_CsnetCur_IVDOutOfStateCountyFipsCode_TEXT,
		   @Ac_IVDOutOfStateOfficeFips_CODE = @Lc_CsnetCur_IVDOutOfStateOfficeFipsCode_TEXT,
		   @Ac_IVDOutOfStateCase_ID         = @Lc_CsnetCur_IVDOutOfStateCaseId_TEXT,
		   @Ad_Generated_DATE               = @Ad_Run_DATE,
		   @Ac_Form_ID                      = 0,
		   @As_FormWeb_URL                  = @Lc_Space_TEXT,
		   @An_TransHeader_IDNO             = 0,
		   @As_DescriptionComments_TEXT     = @Lc_Space_TEXT,
		   @Ac_CaseFormer_ID                = @Lc_Space_TEXT,
		   @Ac_InsCarrier_NAME              = @Lc_Space_TEXT,
		   @Ac_InsPolicyNo_TEXT             = @Lc_Space_TEXT,
		   @Ad_Hearing_DATE                 = @Ld_Low_DATE,
		   @Ad_Dismissal_DATE               = @Ld_Low_DATE,
		   @Ad_GeneticTest_DATE             = @Ld_Low_DATE,
		   @Ad_PfNoShow_DATE                = @Ld_Low_DATE,
		   @Ac_Attachment_INDC              = @Lc_No_INDC,
		   @Ac_File_ID                      = @Lc_File_ID,
		   @Ad_ArrearComputed_DATE          = @Ld_Low_DATE,
		   @An_TotalArrearsOwed_AMNT        = 0,
		   @An_TotalInterestOwed_AMNT       = 0,
		   @Ac_Process_ID                   = @Ac_Process_ID,
		   @Ad_BeginValidity_DATE           = @Ad_Run_DATE,
		   @Ac_SignedonWorker_ID            = @Ac_WorkerUpdate_ID,
		   @Ad_Update_DTTM                  = @Ld_Update_DTTM,
		   @Ac_Msg_CODE                     = @Ac_Msg_CODE OUTPUT,
		   @As_DescriptionError_TEXT        = @As_DescriptionError_TEXT OUTPUT;

		  IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
		   BEGIN
			SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE BATCH_COMMON$SP_INSERT_PENDING_REQUEST FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;

			RAISERROR (50001,16,1);
		   END
	   END

      SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE INSERT ICAS_Y1';
      SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(CAST(@Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT AS VARCHAR(2)), '');

      INSERT INTO ICAS_Y1
                  (Case_IDNO,
                   IVDOutOfStateCase_ID,
                   IVDOutOfStateFips_CODE,
                   IVDOutOfStateOfficeFips_CODE,
                   IVDOutOfStateCountyFips_CODE,
                   Status_CODE,
                   Effective_DATE,
                   End_DATE,
                   RespondInit_CODE,
                   ControlByCrtOrder_INDC,
                   ContOrder_DATE,
                   ContOrder_ID,
                   IVDOutOfStateFile_ID,
                   Petitioner_NAME,
                   ContactFirst_NAME,
                   Respondent_NAME,
                   ContactLast_NAME,
                   ContactMiddle_NAME,
                   PhoneContact_NUMB,
                   Referral_DATE,
                   Contact_EML,
                   FaxContact_NUMB,
                   File_ID,
                   County_IDNO,
                   IVDOutOfStateTypeCase_CODE,
                   Create_DATE,
                   Worker_ID,
                   Update_DTTM,
                   WorkerUpdate_ID,
                   TransactionEventSeq_NUMB,
                   EndValidity_DATE,
                   BeginValidity_DATE,
                   Reason_CODE,
                   RespondentMci_IDNO,
                   PetitionerMci_IDNO,
                   DescriptionComments_TEXT)
      SELECT i.Case_IDNO,
             i.IVDOutOfStateCase_ID,
             i.IVDOutOfStateFips_CODE,
             i.IVDOutOfStateOfficeFips_CODE,
             i.IVDOutOfStateCountyFips_CODE,
             @Lc_StatusCaseClosed_CODE Status_CODE,
             i.Effective_DATE,
             i.End_DATE,
             i.RespondInit_CODE,
             i.ControlByCrtOrder_INDC,
             i.ContOrder_DATE,
             i.ContOrder_ID,
             i.IVDOutOfStateFile_ID,
             i.Petitioner_NAME,
             i.ContactFirst_NAME,
             i.Respondent_NAME,
             i.ContactLast_NAME,
             i.ContactMiddle_NAME,
             i.PhoneContact_NUMB,
             i.Referral_DATE,
             i.Contact_EML,
             i.FaxContact_NUMB,
             i.File_ID,
             i.County_IDNO,
             i.IVDOutOfStateTypeCase_CODE,
             i.Create_DATE,
             i.Worker_ID,
             @Ld_Update_DTTM Update_DTTM,
             @Lc_BatchrRunUser_ID WorkerUpdate_ID,
             @An_TransactionEventSeq_NUMB TransactionEventSeq_NUMB,
             @Ld_High_DATE EndValidity_DATE,
             @Ad_Run_DATE BeginValidity_DATE,
             i.Reason_CODE,
             i.RespondentMci_IDNO,
             i.PetitionerMci_IDNO,
             i.DescriptionComments_TEXT
        FROM ICAS_Y1 i
       WHERE i.Case_IDNO = @An_Case_IDNO
         AND i.Status_CODE = @Lc_StatusEnforcementOpen_CODE
         AND i.EndValidity_DATE = @Ld_High_DATE
         AND i.IVDOutOfStateFips_CODE = @Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT;

      SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY > 0
       BEGIN
		  SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE UPDATE ICAS_Y1';
		  SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '') + ', IVDOutOfStateFips_CODE = ' + ISNULL(CAST(@Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT AS VARCHAR(2)), '');

		  UPDATE ICAS_Y1
			 SET EndValidity_DATE = @Ad_Run_DATE
		   WHERE Case_IDNO = @An_Case_IDNO
			 AND Status_CODE = @Lc_StatusEnforcementOpen_CODE
			 AND EndValidity_DATE = @Ld_High_DATE
			 AND IVDOutOfStateFips_CODE = @Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT;

		  SET @Ln_RowCount_QNTY = @@ROWCOUNT;
		  
		  IF @Ln_RowCount_QNTY = 0
		   BEGIN
			SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE UPDATE ICAS_Y1 FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;

			RAISERROR (50001,16,1);
		   END
		  SET @Lc_RespondInit_CODE = @Lc_RespondInitN_CODE;
       END

      FETCH NEXT FROM Csnet_Cur INTO @Lc_CsnetCur_RespondInit_CODE, @Lc_CsnetCur_IVDOutOfStateFipsCode_TEXT, @Lc_CsnetCur_IVDOutOfStateCountyFipsCode_TEXT, @Lc_CsnetCur_IVDOutOfStateOfficeFipsCode_TEXT, @Lc_CsnetCur_IVDOutOfStateCaseId_TEXT;

      SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
     END
   END
   CLOSE Csnet_Cur;
   DEALLOCATE Csnet_Cur;

   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE UPDATE BATCH_COMMON$SP_UPDATE_CASE_DETAILS';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', RsnStatusCase_CODE = ' + CAST(@Lc_RsnStatusCase_CODE AS VARCHAR(10)) + ', File_ID = ' + @Lc_File_ID + ', SourceRfrl_CODE = ' + @Lc_SourceRfrl_CODE;

   EXEC BATCH_COMMON$SP_UPDATE_CASE_DETAILS
    @An_Case_IDNO                = @An_Case_IDNO,
    @Ac_StatusCase_CODE          = @Lc_StatusCaseClosed_CODE,
    @Ac_RespondInit_CODE		 = @Lc_RespondInit_CODE,	
    @An_RsnStatusCase_CODE       = @Lc_ReasonFirstActivity_CODE,
    @An_StatusCurrent_DATE       = @Ad_Run_DATE,
    @Ac_GoodCause_CODE           = @Lc_GoodCause_CODE,
    @Ac_NonCoop_CODE             = @Lc_NonCoop_CODE,
    @Ad_NonCoop_DATE             = @Ld_NonCoop_DATE,
    @Ac_WorkerUpdate_ID          = @Ac_WorkerUpdate_ID,
    @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
    @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
    BEGIN
     RAISERROR (@Ls_DescriptionError_TEXT,16,1);
    END
    
   SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE UPDATE USRL_Y1';
      SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');
      
   UPDATE u 
	  SET u.CasesAssigned_QNTY = u.CasesAssigned_QNTY - 1,
		  u.BeginValidity_DATE = @Ad_Run_DATE,
	      u.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
		  u.Update_DTTM = @Ld_Update_DTTM,
		  u.WorkerUpdate_ID = @Ac_WorkerUpdate_ID
     FROM USRL_Y1 u, CWRK_Y1 c 
    WHERE u.Worker_ID = c.Worker_ID 
	  AND u.Role_ID = c.Role_ID 
	  AND u.Office_IDNO = c.Office_IDNO
	  AND c.Case_IDNO = @An_Case_IDNO
	  AND @Ad_Run_DATE BETWEEN u.Effective_DATE AND u.Expire_DATE
	  AND u.EndValidity_DATE = @Ld_High_DATE
	  AND @Ad_Run_DATE BETWEEN c.Effective_DATE AND c.Expire_DATE
	  AND c.EndValidity_DATE = @Ld_High_DATE
	  AND u.CasesAssigned_QNTY > 0;

	SET @Ln_RowCount_QNTY = @@ROWCOUNT;

      IF @Ln_RowCount_QNTY = 0
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE UPDATE USRL_Y1 FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
		RAISERROR (50001,16,1);
       END
      
    SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE UPDATE CWRK_Y1';
    SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), '');
      
    UPDATE CWRK_Y1 
       SET Expire_DATE = @Ad_Run_DATE,
		   TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
		   Update_DTTM = @Ld_Update_DTTM,
		   WorkerUpdate_ID = @Ac_WorkerUpdate_ID
     WHERE Case_IDNO = @An_Case_IDNO
       -- 13573 Case reassignment batch populated incorrect total case load -- Start
       AND Expire_DATE = @Ld_High_DATE
       -- 13573 Case reassignment batch populated incorrect total case load -- End
       AND EndValidity_DATE = @Ld_High_DATE
       
    SET @Ln_RowCount_QNTY = @@ROWCOUNT;

    IF @Ln_RowCount_QNTY = 0
     BEGIN
        SET @Ls_DescriptionError_TEXT = 'BATCH_ENF_EMON$SP_PROCESS_CASE_CLOSURE UPDATE CWRK_Y1 FAILED' + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
        RAISERROR (50001,16,1);
     END
        
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('LOCAL', 'Csnet_Cur') IN (0, 1)
    BEGIN
     CLOSE Csnet_Cur;
     DEALLOCATE Csnet_Cur;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
