/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_INSERT_IWEM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------- 
Procedure Name    : BATCH_ENF_EMON$SP_INSERT_IWEM
Programmer Name   : IMP Team 
Description       : This procedure is used to insert datas into IWEM table.
Frequency         : 
Developed On      : 01/05/2012
Called By         : BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On         : 
--------------------------------------------------------------------------------------------------- 
Modified By       : 
Modified On       : 
Version No        :  1.0
-------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_INSERT_IWEM] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC (10),
 @An_OthpSource_IDNO          NUMERIC(9),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ad_Run_DATE                 DATE,
 @Ac_Msg_CODE                 CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_EventFunctionalSeq5600_NUMB	NUMERIC(4)	= 5600,
		  @Lc_Annual_TEXT					CHAR(1)		= 'A',
          @Lc_Biweekly_TEXT					CHAR(1)		= 'B',
          @Lc_Daily_TEXT					CHAR(1)		= 'D',
          @Lc_IwnStatusActive_CODE			CHAR(1)		= 'A',
          @Lc_IwnTypeAlternative_CODE		CHAR(1)		= 'A',
          @Lc_IwnTypeOrder_CODE				CHAR(1)		= 'O',
          @Lc_Monthly_TEXT					CHAR(1)		= 'M',
          @Lc_No_INDC						CHAR(1)		= 'N',
          @Lc_Onetime_TEXT					CHAR(1)		= 'O',
          @Lc_Quarterly_TEXT				CHAR(1)		= 'Q',
          @Lc_Semimonthly_TEXT				CHAR(1)		= 'S',
          @Lc_Space_TEXT					CHAR(1)		= ' ',
          @Lc_StatusSuccess_CODE			CHAR(1)		= 'S',
          @Lc_StatusFail_CODE				CHAR(1)		= 'F',
          @Lc_Yes_INDC						CHAR(1)		= 'Y',
          @Lc_Weekly_TEXT					CHAR(1)		= 'W',
          @Lc_IiwoC_CODE					CHAR(1)		= 'C',
          @Lc_IiwoI_CODE					CHAR(1)		= 'I',
          @Lc_ComplianceStatusActive_CODE	CHAR(2)		= 'AC',
          @Lc_ComplianceTypePeriodic_CODE	CHAR(2)		= 'PA',
          @Lc_DebtTypeMedicalSupp_CODE		CHAR(2)		= 'MS',
          @Lc_DebtTypeMedicaid_CODE			CHAR(2)		= 'DS',
          @Lc_DebtTypeCashMedical_CODE		CHAR(2)		= 'CM',
          @Lc_DebtTypeSpousalSupp_CODE		CHAR(2)		= 'SS',
          @Lc_DebtTypeAlimony_CODE			CHAR(2)		= 'AL',
          @Lc_DebtTypeChildSupp_CODE		CHAR(2)		= 'CS',
          @Lc_ProcessCpro_ID				CHAR(4)		= 'CPRO',
          @Lc_ActivityMajorImiw_CODE		CHAR(4)		= 'IMIW',
          @Lc_ActivityMinorIniwh_CODE		CHAR(5)		= 'INIWH',	
          @Lc_DateFormatYyyymm_TEXT			CHAR(6)		= 'YYYYMM',
          @Ls_Routine_TEXT					VARCHAR(75)	= 'BATCH_ENF_EMON$SP_INSERT_IWEM',
          @Ld_High_DATE						DATE		= '12/31/9999';
  DECLARE @Ln_RowCount_QNTY					NUMERIC,
          @Ln_Obligation12_NUMB				NUMERIC(11, 2),
          @Ln_Arrears_AMNT					NUMERIC(11, 2),
          @Ln_CurCs_AMNT					NUMERIC(11, 2),
          @Ln_CurOt_AMNT					NUMERIC(11, 2),
          @Ln_CurMd_AMNT					NUMERIC(11, 2),
          @Ln_CurSs_AMNT					NUMERIC(11, 2),
          @Ln_Payback_AMNT					NUMERIC(11, 2),
          @Ln_Error_NUMB					NUMERIC(11),
          @Ln_ErrorLine_NUMB				NUMERIC(11),
          @Ln_EventGlobalSeq_NUMB			NUMERIC(19),
          @Lc_FreqPeriodicCs_CODE			CHAR(1),
          @Lc_FreqPeriodicMd_CODE			CHAR(1),
          @Lc_FreqPeriodicOt_CODE			CHAR(1),
          @Lc_FreqPeriodicSs_CODE			CHAR(1),
          @Lc_FreqPayback_CODE				CHAR(1),
          @Lc_IwnPer_CODE					CHAR(1),
          @Lc_IwnStatus_CODE				CHAR(1),
          @Lc_ArrearAged_INDC				CHAR(2),
          @Lc_Iiwo_CODE						CHAR(2),
          @Ls_Sql_TEXT						VARCHAR(300),
          @Ls_Sqldata_TEXT					VARCHAR(3000),
          @Ls_DescriptionError_TEXT			VARCHAR(4000),
          @Ld_Entered_DATE					DATE;

  BEGIN TRY
 
   SET @Ls_Sql_TEXT = 'SELECT SORD_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS CHAR(2));

   SELECT @Lc_Iiwo_CODE = S.Iiwo_CODE
     FROM SORD_Y1 S
    WHERE S.Case_IDNO = @An_Case_IDNO
      AND S.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND @Ad_Run_DATE BETWEEN S.OrderEffective_DATE AND S.OrderEnd_DATE
      AND S.EndValidity_DATE = @Ld_High_DATE;
      
	-- For Initated Income Withholding, Update SORD IiwoCODE as Immmediate.
	IF @Lc_Iiwo_CODE NOT IN (@Lc_IiwoI_CODE, @Lc_IiwoC_CODE) 
		AND EXISTS ( SELECT 1
					   FROM DMNR_Y1 d
					  WHERE d.Case_IDNO = @An_Case_IDNO
					    AND d.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
					    AND d.ActivityMinor_CODE = @Lc_ActivityMinorIniwh_CODE
					    AND d.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB )
	BEGIN
	
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_GENERATE_SEQ';
		EXECUTE BATCH_COMMON$SP_GENERATE_SEQ
		@An_EventFunctionalSeq_NUMB = @Ln_EventFunctionalSeq5600_NUMB,
		@Ac_Process_ID              = @Lc_ProcessCpro_ID,
		@Ad_EffectiveEvent_DATE     = @Ad_Run_DATE,
		@Ac_Note_INDC               = @Lc_No_INDC,
		@Ac_Worker_ID               = @Ac_WorkerUpdate_ID,
		@An_EventGlobalSeq_NUMB     = @Ln_EventGlobalSeq_NUMB OUTPUT,
		@Ac_Msg_CODE                = @Ac_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT   = @Ls_DescriptionError_TEXT OUTPUT;
		
		IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
    
		SET @Ls_Sql_TEXT = 'UPDATE SORD_Y1';
		UPDATE SORD_Y1
         SET Iiwo_CODE = @Lc_IiwoI_CODE,
         	 WorkerUpdate_ID = @Ac_WorkerUpdate_ID,
         	 BeginValidity_DATE = @Ad_Run_DATE,
         	 EventGlobalBeginSeq_NUMB = @Ln_EventGlobalSeq_NUMB,
         	 EventGlobalEndSeq_NUMB = 0
      OUTPUT Deleted.Case_IDNO,
			 Deleted.OrderSeq_NUMB,
			 Deleted.Order_IDNO,
			 Deleted.File_ID,
			 Deleted.OrderEnt_DATE,
			 Deleted.OrderIssued_DATE,
			 Deleted.OrderEffective_DATE,
			 Deleted.OrderEnd_DATE,
			 Deleted.ReasonStatus_CODE,
			 Deleted.StatusOrder_CODE,
			 Deleted.StatusOrder_DATE,
			 Deleted.InsOrdered_CODE,
			 Deleted.MedicalOnly_INDC,
			 Deleted.Iiwo_CODE,
			 Deleted.NoIwReason_CODE,
			 Deleted.IwoInitiatedBy_CODE,
			 Deleted.GuidelinesFollowed_INDC,
			 Deleted.DeviationReason_CODE,
			 Deleted.DescriptionDeviationOthers_TEXT,
			 Deleted.OrderOutOfState_ID,
			 Deleted.CejStatus_CODE,
			 Deleted.CejFips_CODE,
			 Deleted.IssuingOrderFips_CODE,
			 Deleted.Qdro_INDC,
			 Deleted.UnreimMedical_INDC,
			 Deleted.CpMedical_PCT,
			 Deleted.NcpMedical_PCT,
			 Deleted.ParentingTime_PCT,
			 Deleted.NoParentingDays_QNTY,
			 Deleted.PetitionerAppeared_INDC,
			 Deleted.RespondentAppeared_INDC,
			 Deleted.OthersAppeared_INDC,
			 Deleted.PetitionerReceived_INDC,
			 Deleted.RespondentReceived_INDC,
			 Deleted.OthersReceived_INDC,
			 Deleted.PetitionerMailed_INDC,
			 Deleted.RespondentMailed_INDC,
			 Deleted.OthersMailed_INDC,
			 Deleted.PetitionerMailed_DATE,
			 Deleted.RespondentMailed_DATE,
			 Deleted.OthersMailed_DATE,
			 Deleted.CoverageMedical_CODE,
			 Deleted.CoverageDrug_CODE,
			 Deleted.CoverageMental_CODE,
			 Deleted.CoverageDental_CODE,
			 Deleted.CoverageVision_CODE,
			 Deleted.CoverageOthers_CODE,
			 Deleted.DescriptionCoverageOthers_TEXT,
			 Deleted.WorkerUpdate_ID,
			 Deleted.BeginValidity_DATE,
			 @Ad_Run_DATE AS EndValidity_DATE,
			 Deleted.EventGlobalBeginSeq_NUMB,
			 @Ln_EventGlobalSeq_NUMB AS EventGlobalEndSeq_NUMB,
			 Deleted.DescriptionParentingNotes_TEXT,
			 Deleted.LastIrscReferred_DATE,
			 Deleted.LastIrscUpdated_DATE,
			 Deleted.LastIrscReferred_AMNT,
			 Deleted.StatusControl_CODE,
			 Deleted.StateControl_CODE,
			 Deleted.OrderControl_ID,
			 Deleted.PetitionerAttorneyAppeared_INDC,
			 Deleted.RespondentAttorneyAppeared_INDC,
			 Deleted.PetitionerAttorneyReceived_INDC,
			 Deleted.RespondentAttorneyReceived_INDC,
			 Deleted.PetitionerAttorneyMailed_INDC,
			 Deleted.RespondentAttorneyMailed_INDC,
			 Deleted.PetitionerAttorneyMailed_DATE,
			 Deleted.RespondentAttorneyMailed_DATE,
			 Deleted.TypeOrder_CODE,
			 Deleted.ReviewRequested_DATE,
			 Deleted.NextReview_DATE,
			 Deleted.LastReview_DATE,
			 Deleted.LastNoticeSent_DATE,
			 Deleted.DirectPay_INDC,
			 Deleted.SourceOrdered_CODE,
			 -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - START
			 Deleted.Judge_ID,
			 Deleted.Commissioner_ID
			 -- 13650 - SORD - CR0420 SORD Commissioner and Judge Field on Cases that Share a File ID - END
		 INTO SORD_Y1
		 WHERE Case_IDNO = @An_Case_IDNO
		   AND @Ad_Run_DATE BETWEEN OrderEffective_DATE AND OrderEnd_DATE
		   AND EndValidity_DATE = @Ld_High_DATE;
		
		SET @Ln_RowCount_QNTY = @@ROWCOUNT;

	   IF @Ln_RowCount_QNTY = 0
		BEGIN
			SET @Ls_DescriptionError_TEXT = 'UPDATE SORD Failed';
			RAISERROR (50001,16,1);
		END
		
		SET @Lc_Iiwo_CODE = @Lc_IiwoI_CODE;
	END

   SET @Ls_Sql_TEXT = 'SELECT COMP_Y1 1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(2));

   SELECT @Lc_IwnPer_CODE = CASE
                             WHEN COUNT(1)		= 0
                              THEN @Lc_IwnTypeOrder_CODE
                             WHEN COUNT(1) > 0
                                  AND MAX(c.ComplianceStatus_CODE) != @Lc_ComplianceStatusActive_CODE
                              THEN @Lc_IwnTypeOrder_CODE
                             WHEN COUNT(1) > 0
                                  AND MAX(c.ComplianceType_CODE) != @Lc_ComplianceTypePeriodic_CODE
                              THEN @Lc_IwnTypeOrder_CODE
                             WHEN COUNT(1) > 0
                                  AND MAX(c.ComplianceType_CODE)		= @Lc_ComplianceTypePeriodic_CODE
                              THEN @Lc_IwnTypeAlternative_CODE
                            END
     FROM COMP_Y1 C
    WHERE C.Case_IDNO = @An_Case_IDNO
      AND C.OrderSeq_NUMB = @An_OrderSeq_NUMB
      AND @Ad_Run_DATE BETWEEN C.Effective_DATE AND C.End_DATE
      AND C.EndValidity_DATE = @Ld_High_DATE;

   SET @Lc_IwnStatus_CODE = @Lc_IwnStatusActive_CODE;

 
   IF @Lc_IwnStatus_CODE = @Lc_IwnStatusActive_CODE
    BEGIN
     SET @Ld_Entered_DATE = dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(@Ad_Run_DATE);
    END

  
   IF @Lc_IwnPer_CODE = @Lc_IwnTypeAlternative_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT COMP_Y1 2';
     SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(2));

     SELECT @Lc_FreqPeriodicCs_CODE = C.Freq_CODE,
            @Ln_CurCs_AMNT = ISNULL(C.Compliance_AMNT, 0)
       FROM COMP_Y1 C
      WHERE C.Case_IDNO = @An_Case_IDNO
        AND C.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND C.ComplianceType_CODE = @Lc_ComplianceTypePeriodic_CODE
        AND C.ComplianceStatus_CODE = @Lc_ComplianceStatusActive_CODE
        AND dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(@Ad_Run_DATE) BETWEEN C.Effective_DATE AND C.End_DATE
        AND C.EndValidity_DATE = @Ld_High_DATE;

     SET @Ln_CurOt_AMNT = 0;
     SET @Ln_CurMd_AMNT = 0;
     SET @Ln_CurSs_AMNT = 0;
     SET @Ln_Payback_AMNT = 0;
     SET @Lc_FreqPeriodicMd_CODE = @Lc_FreqPeriodicCs_CODE;
     SET @Lc_FreqPeriodicSs_CODE = @Lc_FreqPeriodicCs_CODE;
     SET @Lc_FreqPeriodicOt_CODE = @Lc_FreqPeriodicCs_CODE;
     SET @Lc_FreqPayback_CODE = @Lc_FreqPeriodicCs_CODE;
    END
   ELSE
    BEGIN
     IF @Lc_IwnPer_CODE = @Lc_IwnTypeOrder_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_GET_OBLE_AMT_IWEM';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS CHAR(2));

       EXECUTE BATCH_ENF_EMON$SP_GET_OBLE_AMT_IWEM
        @An_Case_IDNO             = @An_Case_IDNO,
        @An_OrderSeq_NUMB         = @An_OrderSeq_NUMB,
        @Ad_Run_DATE              = @Ad_Run_DATE,
        @An_CurCs_AMNT            = @Ln_CurCs_AMNT OUTPUT,
        @An_CurMd_AMNT            = @Ln_CurMd_AMNT OUTPUT,
        @An_CurSs_AMNT            = @Ln_CurSs_AMNT OUTPUT,
        @Ac_FreqPeriodicCs_CODE   = @Lc_FreqPeriodicCs_CODE OUTPUT,
        @Ac_FreqPeriodicMd_CODE   = @Lc_FreqPeriodicMd_CODE OUTPUT,
        @Ac_FreqPeriodicSs_CODE   = @Lc_FreqPeriodicSs_CODE OUTPUT,
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       SET @Ls_Sql_TEXT = 'BATCH_ENF_EMON$SP_INSERT_IWEM SELECT OBLE_Y1';
       SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(2)) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(20));

       -- When frequency is space, weekly has to be returned
       /*Code changed for converting payback frequency and amount according to the
       CS frequency id CS obligation exists, else payback frequency and amount
       should be same as payback frequency and amount on VSORD */
       SELECT @Lc_FreqPayback_CODE = ISNULL(a.ExpectToPay_CODE,@Lc_Space_TEXT),
          @Ln_Payback_AMNT = ISNULL(CASE a.ExpectToPay_CODE
                WHEN @Lc_Weekly_TEXT
                 THEN CAST((a.ExpectToPay_AMNT * 12) AS FLOAT(53)) / 52
                WHEN @Lc_Monthly_TEXT
                 THEN a.ExpectToPay_AMNT
                WHEN @Lc_Biweekly_TEXT
                 THEN CAST((a.ExpectToPay_AMNT * 12) AS FLOAT(53)) / 26
                WHEN @Lc_Semimonthly_TEXT
                 THEN CAST((a.ExpectToPay_AMNT * 12) AS FLOAT(53)) / 24
                WHEN @Lc_Quarterly_TEXT
                 THEN (a.ExpectToPay_AMNT * 3)
                WHEN @Lc_Annual_TEXT
                 THEN (a.ExpectToPay_AMNT * 12)
                ELSE a.ExpectToPay_AMNT
               END,0)  FROM
       (SELECT  CASE
                  WHEN @Lc_FreqPeriodicCs_CODE != ''
                       AND @Lc_FreqPeriodicCs_CODE IS NOT NULL
                   THEN @Lc_FreqPeriodicCs_CODE
                  WHEN @Lc_FreqPeriodicSs_CODE != ''
                       AND @Lc_FreqPeriodicSs_CODE IS NOT NULL
                   THEN @Lc_FreqPeriodicSs_CODE
                  WHEN @Lc_FreqPeriodicMd_CODE != ''
                       AND @Lc_FreqPeriodicMd_CODE IS NOT NULL
                   THEN @Lc_FreqPeriodicMd_CODE
                  ELSE FreqPeriodic_CODE
                 END  AS ExpectToPay_CODE,
              ExpectToPay_AMNT
         FROM (SELECT ISNULL(MAX(O.FreqPeriodic_CODE), '') AS FreqPeriodic_CODE, MAX(ExpectToPay_AMNT) AS ExpectToPay_AMNT
                     FROM
                      ( SELECT FreqPeriodic_CODE,
							ROUND(ISNULL(SUM(CASE O.FreqPeriodic_CODE
                                        WHEN @Lc_Daily_TEXT
                                         THEN (O.ExpectToPay_AMNT * 365) / 12
                                        WHEN @Lc_Weekly_TEXT
                                         THEN (O.ExpectToPay_AMNT * 52) / 12
                                        WHEN @Lc_Monthly_TEXT
                                         THEN (O.ExpectToPay_AMNT * 12) / 12
                                        WHEN @Lc_Biweekly_TEXT
                                         THEN (O.ExpectToPay_AMNT * 26) / 12
                                        WHEN @Lc_Semimonthly_TEXT
                                         THEN (O.ExpectToPay_AMNT * 24) / 12
                                        WHEN @Lc_Annual_TEXT
                                         THEN (O.ExpectToPay_AMNT / 12)
                                        ELSE O.ExpectToPay_AMNT
                                       END) OVER(PARTITION BY CASE_IDNO), 0), 2) AS ExpectToPay_AMNT,
                         ROW_NUMBER() OVER(PARTITION BY CASE_IDNO ORDER BY CASE WHEN TypeDebt_CODE NOT IN ('GT') THEN 1  ELSE 2 END  ) AS ROWNUM
                 FROM (SELECT y.Case_IDNO,
							   y.OrderSeq_NUMB,
							   y.ObligationSeq_NUMB,
							   y.MemberMci_IDNO,
							   y.TypeDebt_CODE,
							   y.Fips_CODE,
							   y.FreqPeriodic_CODE,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - START
							   CASE WHEN @Ad_Run_DATE BETWEEN BeginObligation_DATE AND EndObligation_DATE 
										THEN  y.Periodic_AMNT 
									ELSE 0 
								END AS Periodic_AMNT,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - END
							   y.ExpectToPay_AMNT,
							   y.ExpectToPay_CODE,
							   y.BeginObligation_DATE,
							   y.EndObligation_DATE,
							   y.EventGlobalBeginSeq_NUMB,
							   y.EventGlobalEndSeq_NUMB,
							   y.BeginValidity_DATE,
							   y.EndValidity_DATE,
						   ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO, y.OrderSeq_NUMB, y.ObligationSeq_NUMB ORDER BY y.BeginObligation_DATE DESC, y.EventGlobalBeginSeq_NUMB DESC) AS rnm
									  FROM OBLE_Y1 AS y 
									 WHERE y.Case_IDNO = @An_Case_IDNO
									   AND y.BeginObligation_DATE <= @Ad_Run_DATE
									   AND y.EndValidity_DATE = @Ld_High_DATE) O
                WHERE O.Case_IDNO = @An_Case_IDNO
				  AND O.rnm = 1
                  AND ( ( @Ad_Run_DATE BETWEEN O.BeginObligation_DATE AND O.EndObligation_DATE )
						OR 
						  O.ExpectToPay_AMNT > 0
						)
                  AND O.BeginValidity_DATE <= @Ad_Run_DATE
                  AND O.EndValidity_DATE > @Ad_Run_DATE)o WHERE ROWNUM = 1 )   AS X)a

       SET @Ls_Sql_TEXT = 'BATCH_COMMON_SCALAR$SF_GREATEST_INT';
       SET @Ls_Sqldata_TEXT = ' FreqPeriodicCs_CODE = ' + ISNULL(@Lc_FreqPeriodicCs_CODE, '') + ', FreqPeriodicMd_CODE = ' + ISNULL (@Lc_FreqPeriodicMd_CODE, '') + ', FreqPeriodicSs_CODE = ' + ISNULL(@Lc_FreqPeriodicSs_CODE, '') + ', FreqPayback_CODE = ' + ISNULL(@Lc_FreqPayback_CODE, '');

       IF @Lc_FreqPeriodicCs_CODE != @Lc_Space_TEXT
          AND @Lc_FreqPeriodicMd_CODE != @Lc_Space_TEXT
          AND @Lc_FreqPeriodicSs_CODE != @Lc_Space_TEXT
          AND @Lc_FreqPayback_CODE != @Lc_Space_TEXT
        BEGIN
         SELECT @Lc_FreqPeriodicOt_CODE = CASE dbo.BATCH_COMMON_SCALAR$SF_GREATEST_INT(CASE @Lc_FreqPeriodicCs_CODE
                                                                                        WHEN @Lc_Weekly_TEXT
                                                                                         THEN 52
                                                                                        WHEN @Lc_Monthly_TEXT
                                                                                         THEN 12
                                                                                        WHEN @Lc_Biweekly_TEXT
                                                                                         THEN 26
                                                                                        WHEN @Lc_Semimonthly_TEXT
                                                                                         THEN 24
                                                                                        WHEN @Lc_Quarterly_TEXT
                                                                                         THEN 4
                                                                                        WHEN @Lc_Annual_TEXT
                                                                                         THEN 1
                                                                                        WHEN @Lc_Space_TEXT
                                                                                         THEN 0
                                                                                       END, dbo.BATCH_COMMON_SCALAR$SF_GREATEST_INT(CASE @Lc_FreqPeriodicMd_CODE
                                                                                                                                     WHEN @Lc_Weekly_TEXT
                                                                                                                                      THEN 52
                                                                                                                                     WHEN @Lc_Monthly_TEXT
                                                                                                                                      THEN 12
                                                                                                                                     WHEN @Lc_Biweekly_TEXT
                                                                                                                                      THEN 26
                                                                                                                                     WHEN @Lc_Semimonthly_TEXT
                                                                                                                                      THEN 24
                                                                                                                                     WHEN @Lc_Quarterly_TEXT
                                                                                                                                      THEN 4
                                                                                                                                     WHEN @Lc_Annual_TEXT
                                                                                                                                      THEN 1
                                                                                                                                     WHEN @Lc_Space_TEXT
                                                                                                                                      THEN 0
                                                                                                                                    END, dbo.BATCH_COMMON_SCALAR$SF_GREATEST_INT(CASE @Lc_FreqPeriodicSs_CODE
                                                                                                                                                                                  WHEN @Lc_Weekly_TEXT
                                                                                                                                                                                   THEN 52
                                                                                                                                                                                  WHEN @Lc_Monthly_TEXT
                                                                                                                                                                                   THEN 12
                                                                                                                                                                                  WHEN @Lc_Biweekly_TEXT
                                                                                                                                                                                   THEN 26
                                                                                                                                                                                  WHEN @Lc_Semimonthly_TEXT
                                                                                                                                                                                   THEN 24
                                                                                                                                                                                  WHEN @Lc_Quarterly_TEXT
                                                                                                                                                                                   THEN 4
                                                                                                                                                                                  WHEN @Lc_Annual_TEXT
                                                                                                                                                                                   THEN 1
                                                                                                                                                                                  WHEN @Lc_Space_TEXT
                                                                                                                                                                                   THEN 0
                                                                                                                                                                                 END, CASE @Lc_FreqPayback_CODE
                                                                                                                                                                                       WHEN @Lc_Weekly_TEXT
                                                                                                                                                                                        THEN 52
                                                                                                                                                                                       WHEN @Lc_Monthly_TEXT
                                                                                                                                                                                        THEN 12
                                                                                                                                                                                       WHEN @Lc_Biweekly_TEXT
                                                                                                                                                                                        THEN 26
                                                                                                                                                                                       WHEN @Lc_Semimonthly_TEXT
                                                                                                                                                                                        THEN 24
                                                                                                                                                                                       WHEN @Lc_Quarterly_TEXT
                                                                                                                                                                                        THEN 4
                                                                                                                                                                                       WHEN @Lc_Annual_TEXT
                                                                                                                                                                                        THEN 1
                                                                                                                                                                                       WHEN @Lc_Space_TEXT
                                                                                                                                                                                        THEN 0
                                                                                                                                                                                      END)))
                                           WHEN 52
                                            THEN @Lc_Weekly_TEXT
                                           WHEN 12
                                            THEN @Lc_Monthly_TEXT
                                           WHEN 26
                                            THEN @Lc_Biweekly_TEXT
                                           WHEN 24
                                            THEN @Lc_Semimonthly_TEXT
                                           WHEN 4
                                            THEN @Lc_Quarterly_TEXT
                                           WHEN 1
                                            THEN @Lc_Annual_TEXT
                                           WHEN 0
                                            THEN @Lc_Space_TEXT
                                          END
        END
       ELSE
        BEGIN
         SET @Lc_FreqPeriodicOt_CODE = @Lc_Space_TEXT;
        END
       SET @Ln_CurOt_AMNT = 0;
      END
    END

   SET @Ls_Sql_TEXT = 'SELECT FROM LSUP_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS CHAR(2)) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(20));

   SELECT @Ln_Arrears_AMNT = ISNULL(SUM((L.OweTotNaa_AMNT - L.AppTotNaa_AMNT) + (L.OweTotPaa_AMNT - L.AppTotPaa_AMNT) + (L.OweTotTaa_AMNT - L.AppTotTaa_AMNT) + (L.OweTotCaa_AMNT - L.AppTotCaa_AMNT) + (L.OweTotUpa_AMNT - L.AppTotUpa_AMNT) + (L.OweTotUda_AMNT - L.AppTotUda_AMNT) + (L.OweTotIvef_AMNT - L.AppTotIvef_AMNT) + (L.OweTotNffc_AMNT - L.AppTotNffc_AMNT) + (L.OweTotMedi_AMNT - L.AppTotMedi_AMNT) + (L.OweTotNonIvd_AMNT - L.AppTotNonIvd_AMNT) - (L.OweTotCurSup_AMNT - L.AppTotCurSup_AMNT + CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  WHEN L.MtdCurSupOwed_AMNT < L.AppTotCurSup_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   THEN L.AppTotCurSup_AMNT - L.MtdCurSupOwed_AMNT
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ELSE 0
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 END)), 0)
     FROM LSUP_Y1 L
    WHERE L.Case_IDNO = @An_Case_IDNO
      AND L.SupportYearMonth_NUMB = CAST(dbo.BATCH_COMMON_SCALAR$SF_TO_CHAR_DATE(@Ad_Run_DATE, @Lc_DateFormatYyyymm_TEXT) AS FLOAT(53))
      AND L.EventGlobalSeq_NUMB = (SELECT MAX(A.EventGlobalSeq_NUMB)
                                     FROM LSUP_Y1 A
                                    WHERE A.Case_IDNO = L.Case_IDNO
                                      AND A.OrderSeq_NUMB = L.OrderSeq_NUMB
                                      AND A.ObligationSeq_NUMB = L.ObligationSeq_NUMB
                                      AND A.SupportYearMonth_NUMB = L.SupportYearMonth_NUMB
                                      AND A.Distribute_DATE <= @Ad_Run_DATE)
      AND EXISTS (SELECT 1
                    FROM OBLE_Y1 O
                   WHERE O.Case_IDNO = L.Case_IDNO
                     AND O.OrderSeq_NUMB = L.OrderSeq_NUMB
                     AND O.ObligationSeq_NUMB = L.ObligationSeq_NUMB
                     -- Alimony Debt Type is added for calculating Income Withholding amount
                     AND O.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeMedicaid_CODE, @Lc_DebtTypeCashMedical_CODE,@Lc_DebtTypeSpousalSupp_CODE, @Lc_DebtTypeAlimony_CODE)
                     AND O.EndValidity_DATE = @Ld_High_DATE);

   SET @Ls_Sql_TEXT = 'SELECT FROM OBLE_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS CHAR(2)) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(20));

   SELECT @Ln_Obligation12_NUMB = ISNULL(SUM(CASE O.FreqPeriodic_CODE
                                              WHEN @Lc_Weekly_TEXT
                                               THEN O.Periodic_AMNT
                                              WHEN @Lc_Monthly_TEXT
                                               THEN (O.Periodic_AMNT * 12) / 52
                                              WHEN @Lc_Biweekly_TEXT
                                               THEN (O.Periodic_AMNT * 26) / 52
                                              WHEN @Lc_Semimonthly_TEXT
                                               THEN (O.Periodic_AMNT * 24) / 52
                                              WHEN @Lc_Quarterly_TEXT
                                               THEN (O.Periodic_AMNT * 4) / 52
                                              WHEN @Lc_Annual_TEXT
                                               THEN O.Periodic_AMNT / 52
                                              ELSE O.Periodic_AMNT
                                             END), 0) * 12
     FROM (SELECT y.Case_IDNO,
							   y.OrderSeq_NUMB,
							   y.ObligationSeq_NUMB,
							   y.MemberMci_IDNO,
							   y.TypeDebt_CODE,
							   y.Fips_CODE,
							   y.FreqPeriodic_CODE,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - START
							   CASE WHEN @Ad_Run_DATE BETWEEN BeginObligation_DATE AND EndObligation_DATE 
										THEN  y.Periodic_AMNT 
									ELSE 0 
								END AS Periodic_AMNT,
							   -- 13759  - EMON - IMIW chain - Amended IWO is not generating correctly when a future obligation is entered on OWIZ - END
							   y.ExpectToPay_AMNT,
							   y.ExpectToPay_CODE,
							   y.BeginObligation_DATE,
							   y.EndObligation_DATE,
							   y.EventGlobalBeginSeq_NUMB,
							   y.EventGlobalEndSeq_NUMB,
							   y.BeginValidity_DATE,
							   y.EndValidity_DATE,
						   ROW_NUMBER() OVER(PARTITION BY y.Case_IDNO, y.OrderSeq_NUMB, y.ObligationSeq_NUMB ORDER BY y.BeginObligation_DATE DESC, y.EventGlobalBeginSeq_NUMB DESC) AS rnm
									  FROM OBLE_Y1 AS y 
									 WHERE y.Case_IDNO = @An_Case_IDNO
									   AND y.BeginObligation_DATE <= @Ad_Run_DATE
									   AND y.EndValidity_DATE = @Ld_High_DATE) O
    WHERE O.Case_IDNO = @An_Case_IDNO
	  AND O.rnm = 1
      AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB
            -- Alimony Debt Type is added for calculating Income Withholding amount  
      AND O.TypeDebt_CODE IN (@Lc_DebtTypeChildSupp_CODE, @Lc_DebtTypeMedicalSupp_CODE, @Lc_DebtTypeMedicaid_CODE, @Lc_DebtTypeCashMedical_CODE,@Lc_DebtTypeSpousalSupp_CODE, @Lc_DebtTypeAlimony_CODE)
      AND O.Periodic_AMNT > 0
      AND ( ( @Ad_Run_DATE BETWEEN O.BeginObligation_DATE AND O.EndObligation_DATE )
			OR 
			  O.ExpectToPay_AMNT > 0
			)
      AND O.EndValidity_DATE = @Ld_High_DATE;

   IF @Ln_Arrears_AMNT > @Ln_Obligation12_NUMB
    BEGIN
     SET @Lc_ArrearAged_INDC = @Lc_Yes_INDC;
    END
   ELSE
    BEGIN
     SET @Lc_ArrearAged_INDC = @Lc_No_INDC;
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO IWEM_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS CHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS CHAR(2)) + ', MemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', OthpSource_IDNO = ' + CAST(@An_OthpSource_IDNO AS VARCHAR(9)) + ', WorkerUpdate_ID = ' + CAST(@Ac_WorkerUpdate_ID AS VARCHAR(30)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS VARCHAR(19)) + ', Run_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(20));

   INSERT IWEM_Y1
          (Case_IDNO,
           OrderSeq_NUMB,
           MemberMci_IDNO,
           Entered_DATE,
           End_DATE,
           OthpEmployer_IDNO,
           TypeSource_CODE,
           IwnPer_CODE,
           IwnStatus_CODE,
           CurCs_AMNT,
           CurMd_AMNT,
           CurSs_AMNT,
           CurOt_AMNT,
           Payback_AMNT,
           FreqCs_CODE,
           FreqMd_CODE,
           FreqSs_CODE,
           FreqOt_CODE,
           FreqPayback_CODE,
           ArrearAged_INDC,
           BeginValidity_DATE,
           EndValidity_DATE,
           WorkerUpdate_ID,
           Update_DTTM,
           TransactionEventSeq_NUMB)
   VALUES ( @An_Case_IDNO,--Case_IDNO
            @An_OrderSeq_NUMB,--OrderSeq_NUMB
            @An_MemberMci_IDNO,--MemberMci_IDNO
            @Ld_Entered_DATE,--Entered_DATE
            @Ld_High_DATE,--End_DATE
            @An_OthpSource_IDNO,--OthpEmployer_IDNO
            @Lc_Iiwo_CODE,--TypeSource_CODE
            @Lc_IwnPer_CODE,--IwnPer_CODE
            @Lc_IwnStatus_CODE,--IwnStatus_CODE
            @Ln_CurCs_AMNT,--CurCs_AMNT
            @Ln_CurMd_AMNT,--CurMd_AMNT
            @Ln_CurSs_AMNT,--CurSs_AMNT
            @Ln_CurOt_AMNT,--CurOt_AMNT
            @Ln_Payback_AMNT,--Payback_AMNT
            @Lc_FreqPeriodicCs_CODE,--FreqCs_CODE
            @Lc_FreqPeriodicMd_CODE,--FreqMd_CODE
            @Lc_FreqPeriodicSs_CODE,--FreqSs_CODE
            @Lc_FreqPeriodicOt_CODE,--FreqOt_CODE
            -- 13619 - GT payment on arrears frequency displays on IWO as One Time Only - Start
            CASE WHEN @Lc_FreqPayback_CODE = @Lc_Onetime_TEXT
			   THEN @Lc_Monthly_TEXT
			   ELSE @Lc_FreqPayback_CODE
		    END,--FreqPayback_CODE
		    -- 13619 - GT payment on arrears frequency displays on IWO as One Time Only - End
            @Lc_ArrearAged_INDC,--ArrearAged_INDC
            dbo.BATCH_COMMON_SCALAR$SF_TRUNC_DATE(@Ad_Run_DATE),--BeginValidity_DATE
            @Ld_High_DATE,--EndValidity_DATE
            @Ac_WorkerUpdate_ID,--WorkerUpdate_ID
            dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),--Update_DTTM
            @An_TransactionEventSeq_NUMB --TransactionEventSeq_NUMB
   );

   SET @Ln_RowCount_QNTY = @@ROWCOUNT;

   IF @Ln_RowCount_QNTY = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT IWEM_Y1 Failed';
     RAISERROR (50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFail_CODE;

   IF (@Ln_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
