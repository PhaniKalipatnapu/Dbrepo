/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_INT02_ACTION_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_INT02_ACTION_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_INT02_ACTION_DTLS]
 @An_Case_IDNO              NUMERIC(6),
 @An_CpMemberMci_IDNO		NUMERIC(10),
 @An_NcpMemberMci_IDNO		NUMERIC(10),
 @An_TransHeader_IDNO       NUMERIC(12),
 @Ad_Transaction_DATE       DATE,
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_Function_CODE          CHAR(3),
 @Ac_Action_CODE            CHAR(1),
 @Ac_Reason_CODE            CHAR(5),
 @Ac_TransOtherState_INDC   CHAR(1),  
 @Ac_Msg_CODE               CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT  CHAR(1) OUTPUT
AS
 BEGIN
 SET NOCOUNT ON;
   DECLARE @Li_DateFormat_NUMB				   INTEGER = 101,
		   @Lc_Space_TEXT                        CHAR = ' ',
           @Lc_VerificationStatusGood_CODE       CHAR = 'Y',
           @Lc_InsTypeInsurers_CODE              CHAR = 'I',
           @Lc_Monthly_TEXT                      CHAR = 'M',
           @Lc_StatusFailed_CODE                 CHAR = 'F',
           @Lc_StatusSuccess_CODE                CHAR = 'S',
           @Lc_IoDirectionInput_INDC             CHAR(1) = 'I',
           @Lc_Mailing_ADDR                      CHAR(1) = 'M',
           @Lc_ActionProvision_CODE              CHAR(1) = 'P',
           @Lc_ActionAcknowledge_CODE			 CHAR(1) = 'A',
           @Lc_RefAssistR_CODE                   CHAR(1) = 'R',
           @Lc_ReceivedNo_INDC					 CHAR(1) = 'N',
           @Lc_RespondInitInstate_CODE           CHAR(1) = 'N', 
           @Lc_ObsoleteNo_INDC					 CHAR(1) = 'N', 
           @Lc_PaymentSourceI1_CODE              CHAR(1) = 'I',
           @Lc_PaymentSourceS1_CODE              CHAR(1) = 'S',
           @Lc_TypeAddressP1_CODE                CHAR(1) = 'P',
           @Lc_TypeAddressS1_CODE                CHAR(1) = 'S',
           @Lc_ReceiptSrcSpecialCollection_CODE  CHAR(2) = 'SC',
           @Lc_ReceiptSrcHomesteadRebate_CODE    CHAR(2) = 'SH',
           @Lc_ReceiptSrcSaverRebate_CODE        CHAR(2) = 'SS',
           @Lc_ReceiptSrcStateTaxRefund_CODE     CHAR(2) = 'ST',
           @Lc_StatusCg_CODE                     CHAR(2) = 'CG',
           @Lc_FunctionCollection_CODE           CHAR(3) = 'COL',
           @Lc_FunctionEnforcement_CODE          CHAR(3) = 'ENF',
           @Lc_FunctionManagestcases_CODE        CHAR(3) = 'MSC',
           @Lc_FunctionEstablishment_CODE        CHAR(3) = 'EST',
           @Lc_FunctionPaternity_CODE            CHAR(3) = 'PAT',
           @Lc_FunctionQuickLocate_CODE          CHAR(3) = 'LO1',
           @Lc_TableImcl_ID						 CHAR(4) = 'IMCL',  
           @Lc_TableSubUifs_ID					 CHAR(4) = 'UIFS',
           @Lc_ReasonAadin_CODE                  CHAR(5) = 'AADIN',
           @Lc_ReasonCitax_CODE                  CHAR(5) = 'CITAX',
           @Lc_ReasonGiher_CODE                  CHAR(5) = 'GIHER',
           @Lc_ReasonSichs_CODE                  CHAR(5) = 'SICHS',
           @Lc_ReasonPichs_CODE                  CHAR(5) = 'PICHS',
           @Lc_ReasonPibts_CODE                  CHAR(5) = 'PIBTS',
           @Lc_ReasonGsmad_CODE                  CHAR(5) = 'GSMAD',
           @Lc_ReasonGsmde_CODE                  CHAR(5) = 'GSMDE',
           @Lc_ReasonLsadr_CODE                  CHAR(5) = 'LSADR',
           @Lc_ReasonLsemp_CODE                  CHAR(5) = 'LSEMP',
           @Lc_ReasonLsout_CODE                  CHAR(5) = 'LSOUT',
           @Lc_State_CODE                        CHAR(6) = 'STATE',
           @Lc_LowDateMmDdYyyy_TEXT              CHAR(11) = '01/01/0001',
           @Ld_High_DATE                         DATE = '12/31/9999',
           @Ld_Disburse_DATE                     DATE = NULL;
  DECLARE  @Ln_Disburse_AMNT             NUMERIC(11,2) = 0,
           @Lc_MailingConfirmed_INDC     CHAR(1) = '',
           @Lc_RefAssist_CODE            CHAR(1) = '',
           @Lc_ResConfirmed_INDC         CHAR(1) = '',
           @Lc_Empty_TEXT				 CHAR(1) ='',
           @Lc_Semicolon_TEXT			 CHAR(1) =';',
           @Lc_DisburseDate_TEXT         CHAR(10) = '',
           @Lc_DisburseAmount_TEXT       CHAR(20) = '',
           @Lc_Request_IDNO              CHAR(6), 
           @Ls_Comments_Text1            VARCHAR(100) ='The following Documents are Required to proceed with your Request: ',
           @Ls_Comments_Text2            VARCHAR(100) ='The following paperwork is being sent to you: ',
           @Ls_ReasonCitax_Text1		 VARCHAR(100) ='A tax offset in the amount of $',
           @Ls_ReasonCitax_Text2		 VARCHAR(100) =' has been disbursed.  Please adjust the NCP''s balance accordingly.',
           @Ls_Routine_TEXT              VARCHAR(100),
           @Ls_Sql_TEXT                  VARCHAR(200),
           @Ls_Sqldata_TEXT              VARCHAR(400),
           @Ls_Comments_TEXT             VARCHAR(Max),
           @Ls_Description_TEXT          VARCHAR(Max),
           @Ls_Transmittal2Action1_TEXT  VARCHAR(MAX),
           @Ls_Transmittal2Action2_TEXT  VARCHAR(MAX),
           @Ls_Transmittal2Action3_TEXT  VARCHAR(MAX),
           @Ls_Transmittal2Action4_TEXT  VARCHAR(MAX),
           @Ls_Transmittal2Action5_TEXT  VARCHAR(MAX);
  BEGIN TRY
   SET @Ls_Transmittal2Action1_TEXT = NULL;
   SET @Ls_Transmittal2Action2_TEXT = NULL;
   SET @Ls_Transmittal2Action3_TEXT = NULL;
   SET @Ls_Transmittal2Action4_TEXT = NULL;
   SET @Ls_Transmittal2Action5_TEXT = NULL;
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICE_CNET$SP_INT02_ACTION_DTLS ';
 SElECT @Lc_Request_IDNO=Element_VALUE 
           FROM #NoticeElementsData_p1 
           WHERE Element_NAME='request_idno';
     
   IF @Ac_TransOtherState_INDC = @Lc_IoDirectionInput_INDC
   BEGIN
		IF (@Ac_Function_CODE = @Lc_FunctionCollection_CODE
			AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
			AND @Ac_Reason_CODE = @Lc_ReasonCitax_CODE)
		BEGIN
			  SET @Ls_Sql_TEXT = 'SELECT CCLB1_V1';
			  SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + CAST(@An_TransHeader_IDNO AS VARCHAR) 
						+ ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '')
						+ ', Transaction_DATE = ' + ISNULL(CAST(@Ad_Transaction_DATE AS VARCHAR), '')
						+ ', Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR);
						
			  SELECT @Ld_Disburse_DATE = MAX(fci.Collection_DATE),
					 @Ln_Disburse_AMNT = SUM(fci.Payment_AMNT)
				FROM (SELECT c.Collection_DATE,
							 c.Payment_AMNT
						FROM CCLB_Y1 c
					   WHERE c.TransHeader_IDNO = @An_TransHeader_IDNO
						 AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
						 AND c.Transaction_DATE = @Ad_Transaction_DATE
						 AND c.PaymentSource_CODE = @Lc_PaymentSourceI1_CODE) AS fci;

			  IF @Ld_Disburse_DATE IS NOT NULL
			  BEGIN
			  SET @Lc_DisburseDate_TEXT = CONVERT(VARCHAR, @Ld_Disburse_DATE, @Li_DateFormat_NUMB);
			  END;

			  IF @Ln_Disburse_AMNT <> 0
			  BEGIN
				SET @Lc_DisburseAmount_TEXT = CONVERT(VARCHAR,CAST((@Ln_Disburse_AMNT) AS MONEY), 1);
			  END;

			  IF (@Ld_Disburse_DATE IS NOT NULL) OR (@Ln_Disburse_AMNT <> 0)
			  BEGIN
				SET @Ls_Transmittal2Action1_TEXT = @Ls_ReasonCitax_Text1 + @Lc_DisburseAmount_TEXT  + @Ls_ReasonCitax_Text2;
			  END;

			  SET @Ld_Disburse_DATE = NULL;
			  SET @Ln_Disburse_AMNT = 0;
			  SET @Lc_DisburseDate_TEXT = '';
			  SET @Lc_DisburseAmount_TEXT = '';
			  SET @Ls_Sql_TEXT = 'SELECT CCLB2_V1';

			  SELECT @Ld_Disburse_DATE = MAX(fci.Collection_DATE),
					 @Ln_Disburse_AMNT = SUM(fci.Payment_AMNT)
				FROM (SELECT c.Collection_DATE,
							 c.Payment_AMNT
						FROM CCLB_Y1 c
					   WHERE c.TransHeader_IDNO = @An_TransHeader_IDNO
						 AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
						 AND c.Transaction_DATE = @Ad_Transaction_DATE
						 AND c.PaymentSource_CODE = @Lc_PaymentSourceS1_CODE) AS fci;

			  IF @Ld_Disburse_DATE IS NOT NULL
			  BEGIN
				SET @Lc_DisburseDate_TEXT = CONVERT(VARCHAR, @Ld_Disburse_DATE, @Li_DateFormat_NUMB);
			  END;

			  IF @Ln_Disburse_AMNT <> 0
			  BEGIN
				SET @Lc_DisburseAmount_TEXT = CONVERT(VARCHAR,CAST((@Ln_Disburse_AMNT) AS MONEY), 1);
			  END;

			  IF (@Ld_Disburse_DATE IS NOT NULL) OR (@Ln_Disburse_AMNT <> 0)
			  BEGIN
				SET @Ls_Transmittal2Action2_TEXT = @Lc_State_CODE+ ' ' + @Lc_DisburseDate_TEXT  + ' ' + @Lc_DisburseAmount_TEXT;
				SET @Ld_Disburse_DATE = NULL;
				SET @Ln_Disburse_AMNT = 0;
				SET @Lc_DisburseDate_TEXT = '';
				SET @Lc_DisburseAmount_TEXT = '';
			   END
		END
		ELSE IF ((@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
			 AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
			 AND @Ac_Reason_CODE = @Lc_ReasonGiher_CODE)
			 OR (@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE
				 AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
				 AND @Ac_Reason_CODE = @Lc_ReasonGiher_CODE)
			 OR (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
				 AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
				 AND @Ac_Reason_CODE = @Lc_ReasonSichs_CODE)
			 OR (@Ac_Function_CODE = @Lc_FunctionPaternity_CODE
				 AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
				 AND @Ac_Reason_CODE = @Lc_ReasonPichs_CODE))
		BEGIN
		        SET @Ls_Sql_TEXT = 'SELECT CTHB_Y1';
		        SELECT @Ls_Transmittal2Action1_TEXT = CASE CONVERT(VARCHAR, b.ActionResolution_DATE, 101)
									   WHEN @Lc_LowDateMmDdYyyy_TEXT
										THEN NULL
									   ELSE CONVERT(VARCHAR, b.ActionResolution_DATE, 101)
									  END
				FROM CTHB_Y1 b
			   WHERE b.TransHeader_IDNO = @An_TransHeader_IDNO
				 AND b.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
				 AND b.Transaction_DATE = @Ad_Transaction_DATE;
		END
		ELSE IF (@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE
			AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
			AND (@Ac_Reason_CODE = @Lc_ReasonGsmad_CODE OR @Ac_Reason_CODE = @Lc_ReasonGsmde_CODE))
		BEGIN
			  SET @Ls_Sql_TEXT = 'SELECT CNLB_Y1';

			  SELECT @Ls_Transmittal2Action1_TEXT = n.InsCarrier_NAME + @Lc_Space_TEXT + n.PolicyInsNo_TEXT
				FROM CNLB_Y1 n
			   WHERE n.TransHeader_IDNO = @An_TransHeader_IDNO
				 AND n.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
				 AND n.Transaction_DATE = @Ad_Transaction_DATE;
		END
		ELSE IF ((@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE OR @Ac_Function_CODE = @Lc_FunctionQuickLocate_CODE)
			 AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
			 AND @Ac_Reason_CODE = @Lc_ReasonLsadr_CODE)
		BEGIN
			  SET @Ls_Sql_TEXT = 'SELECT CNLB_Y1 ';
			  SELECT @Lc_MailingConfirmed_INDC = b.MailingConfirmed_CODE,
					 @Lc_ResConfirmed_INDC = b.ResidentialConfirmed_CODE,
					 @Ls_Transmittal2Action1_TEXT = b.MailingLine1_ADDR,
					 @Ls_Transmittal2Action2_TEXT = b.MailingLine2_ADDR,
					 @Ls_Transmittal2Action3_TEXT = ISNULL(b.MailingCity_ADDR, '') + @Lc_Space_TEXT 
							+ ISNULL(b.MailingState_ADDR, '') + @Lc_Space_TEXT + ISNULL(b.MailingZip_ADDR, '')
				FROM CNLB_Y1  b
			   WHERE b.TransHeader_IDNO = @An_TransHeader_IDNO
				 AND b.Transaction_DATE = @Ad_Transaction_DATE
				 AND b.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE

			  IF @Lc_MailingConfirmed_INDC <> @Lc_VerificationStatusGood_CODE 
					AND @Lc_ResConfirmed_INDC = @Lc_VerificationStatusGood_CODE
			  BEGIN
				SELECT @Ls_Transmittal2Action1_TEXT = b.ResidentialLine1_ADDR,
					   @Ls_Transmittal2Action2_TEXT = b.ResidentialLine2_ADDR,
					   @Ls_Transmittal2Action3_TEXT = ISNULL(b.ResidentialCity_ADDR, '') + @Lc_Space_TEXT 
							+ ISNULL(b.ResidentialState_ADDR, '') + @Lc_Space_TEXT + ISNULL(b.ResidentialZip_ADDR, '')
				  FROM CNLB_Y1 AS b
				 WHERE b.TransHeader_IDNO = @An_TransHeader_IDNO
				   AND b.Transaction_DATE = @Ad_Transaction_DATE
				   AND b.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;
			  END;
			  ELSE
			  BEGIN
				 SET @Ls_Transmittal2Action1_TEXT = NULL;
				 SET @Ls_Transmittal2Action2_TEXT = NULL;
				 SET @Ls_Transmittal2Action3_TEXT = NULL;
			  END;
		END
		ELSE IF ((@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE OR @Ac_Function_CODE = @Lc_FunctionQuickLocate_CODE)
			   AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
			   AND @Ac_Reason_CODE = @Lc_ReasonLsemp_CODE)
		BEGIN
			SET @Lc_MailingConfirmed_INDC = NULL;
			SET @Ls_Sql_TEXT = 'SELECT CNLB_Y1 ';

			SELECT @Lc_MailingConfirmed_INDC = b.EmployerConfirmed_INDC,
				   @Ls_Transmittal2Action1_TEXT = b.Employer_NAME,
				   @Ls_Transmittal2Action2_TEXT = b.EmployerLine1_ADDR,
				   @Ls_Transmittal2Action3_TEXT = b.EmployerLine2_ADDR,
				   @Ls_Transmittal2Action4_TEXT = b.EmployerCity_ADDR + @Lc_Space_TEXT + b.EmployerState_ADDR 
							+ @Lc_Space_TEXT + b.EmployerZip_ADDR,
				   @Ls_Transmittal2Action5_TEXT = b.EmployerEin_ID
			  FROM CNLB_Y1 AS b
			 WHERE b.TransHeader_IDNO = @An_TransHeader_IDNO
			   AND b.Transaction_DATE = @Ad_Transaction_DATE
			   AND b.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE;

			IF @Lc_MailingConfirmed_INDC <> @Lc_VerificationStatusGood_CODE
			 BEGIN
			  SET @Ls_Transmittal2Action1_TEXT = NULL;
			  SET @Ls_Transmittal2Action2_TEXT = NULL;
			  SET @Ls_Transmittal2Action3_TEXT = NULL;
			  SET @Ls_Transmittal2Action4_TEXT = NULL;
			 END
		END;
   END
   ELSE IF ((@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
        AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
        AND @Ac_Reason_CODE = @Lc_ReasonGiher_CODE)
        OR (@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE
            AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
            AND @Ac_Reason_CODE = @Lc_ReasonGiher_CODE)
        OR (@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
            AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
            AND @Ac_Reason_CODE = @Lc_ReasonSichs_CODE)
        OR (@Ac_Function_CODE = @Lc_FunctionPaternity_CODE
            AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
            AND @Ac_Reason_CODE = @Lc_ReasonPichs_CODE))
    BEGIN
        SET @Ls_Sql_TEXT = 'SELECT CSPR_Y1 FOR HEARING DATE';
		SELECT @Ls_Transmittal2Action1_TEXT = CASE CONVERT(VARCHAR, r.Hearing_DATE, 101)
                              WHEN @Lc_LowDateMmDdYyyy_TEXT
                               THEN NULL
                              ELSE CONVERT(VARCHAR, r.Hearing_DATE, 101)
                             END
		FROM CSPR_Y1 r
		WHERE r.Request_IDNO = @Lc_Request_IDNO
			AND r.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
			AND r.EndValidity_DATE = @Ld_High_DATE;
	
		
   END
    ELSE IF ((@Ac_Function_CODE = @Lc_FunctionPaternity_CODE
        AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
        AND @Ac_Reason_CODE = @Lc_ReasonPibts_CODE))
       
            
    BEGIN
        SET @Ls_Sql_TEXT = 'SELECT CSPR_Y1 FOR GENETIC TEST';
		           
		SELECT @Ls_Transmittal2Action1_TEXT = CASE CONVERT(VARCHAR, r.GeneticTest_DATE, 101)
                              WHEN @Lc_LowDateMmDdYyyy_TEXT
                               THEN NULL
                              ELSE CONVERT(VARCHAR, r.GeneticTest_DATE, 101)
                             END
		FROM CSPR_Y1 r
		WHERE r.Request_IDNO = @Lc_Request_IDNO
			AND r.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
			AND r.EndValidity_DATE = @Ld_High_DATE;
	
   END
  
   ELSE IF (@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE
        AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
        AND (@Ac_Reason_CODE = @Lc_ReasonGsmad_CODE OR @Ac_Reason_CODE = @Lc_ReasonGsmde_CODE))
     BEGIN
		SET @Ls_Sql_TEXT = 'SELECT MINS_Y1 ';
		SELECT @Ls_Transmittal2Action1_TEXT = (SELECT o.OtherParty_NAME
               FROM OTHP_Y1 o
               WHERE o.OtherParty_IDNO =a.OthpInsurance_IDNO
                 AND o.TypeOthp_CODE = @Lc_InsTypeInsurers_CODE
                 AND o.EndValidity_DATE = @Ld_High_DATE) + @Lc_Space_TEXT + a.PolicyInsNo_TEXT
      FROM MINS_Y1 AS a
        WHERE a.MemberMci_IDNO =@An_NcpMemberMci_IDNO
			AND a.EndValidity_DATE =@Ld_High_DATE
			AND a.TypePolicy_CODE =@Lc_Monthly_TEXT
			AND a.Status_CODE = @Lc_StatusCg_CODE
			AND a.End_DATE > CONVERT(VARCHAR, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 101)
			AND a.Begin_DATE = (SELECT MAX(m.Begin_DATE) 
								  FROM MINS_Y1 m
								 WHERE m.MemberMci_IDNO = a.MemberMci_IDNO
								   AND m.TypePolicy_CODE = a.TypePolicy_CODE
								   AND m.Status_CODE = a.Status_CODE
								   AND m.End_DATE > CONVERT(VARCHAR, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 101))
			AND a.TransactionEventSeq_NUMB = (SELECT MAX(m.TransactionEventSeq_NUMB) 
                                            FROM MINS_Y1 m
                                           WHERE m.MemberMci_IDNO = a.MemberMci_IDNO
                                             AND m.EndValidity_DATE = '12/31/9999')
  
   END
   ELSE IF ((@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE
			AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
			AND @Ac_Reason_CODE = @Lc_ReasonLsadr_CODE)
        OR (@Ac_Function_CODE = @Lc_FunctionQuickLocate_CODE
            AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
            AND @Ac_Reason_CODE = @Lc_ReasonLsadr_CODE)
        OR (@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE
            AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
            AND @Ac_Reason_CODE = @Lc_ReasonLsout_CODE))
    BEGIN
		SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1 ';
		SELECT @Ls_Transmittal2Action1_TEXT = a.Attn_ADDR,
            @Ls_Transmittal2Action2_TEXT = a.Line1_ADDR,
            @Ls_Transmittal2Action3_TEXT = a.Line2_ADDR,
            @Ls_Transmittal2Action4_TEXT = a.City_ADDR + @Lc_Space_TEXT + a.State_ADDR + @Lc_Space_TEXT 
					+ SUBSTRING(a.Zip_ADDR, 1, 5) 
					+ CASE WHEN LEN(RTRIM(a.Zip_ADDR)) = 9 THEN '-' + SUBSTRING(a.Zip_ADDR, 6, 4) ELSE '' END
					+ @Lc_Space_TEXT + a.Country_ADDR
        FROM AHIS_Y1 AS a
        WHERE a.MemberMci_IDNO = @An_NcpMemberMci_IDNO 
			AND a.TypeAddress_CODE IN (@Lc_Mailing_ADDR, @Lc_TypeAddressP1_CODE, @Lc_TypeAddressS1_CODE)
			AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
			AND dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() BETWEEN a.Begin_DATE AND a.End_DATE
			AND a.TransactionEventSeq_NUMB = (SELECT MAX(a.TransactionEventSeq_NUMB) AS expr
                                            FROM AHIS_Y1 a
                                           WHERE a.MemberMci_IDNO = @An_NcpMemberMci_IDNO
                                             AND a.TypeAddress_CODE IN (@Lc_Mailing_ADDR, @Lc_TypeAddressP1_CODE, @Lc_TypeAddressS1_CODE)
                                             AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
                                             AND CONVERT(VARCHAR, dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(), 101) BETWEEN a.Begin_DATE AND a.End_DATE)
   END
   ELSE IF ((@Ac_Function_CODE = @Lc_FunctionManagestcases_CODE OR @Ac_Function_CODE = @Lc_FunctionQuickLocate_CODE)
        AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
        AND @Ac_Reason_CODE = @Lc_ReasonLsemp_CODE)
   BEGIN
		SET @Ls_Sql_TEXT = 'SELECT EHIS_Y1 ';
		SELECT @Ls_Transmittal2Action1_TEXT = o.OtherParty_NAME,
			   @Ls_Transmittal2Action2_TEXT = o.Line1_ADDR,
			   @Ls_Transmittal2Action3_TEXT = o.Line2_ADDR,
			   @Ls_Transmittal2Action4_TEXT = o.City_ADDR + @Lc_Space_TEXT + o.State_ADDR + @Lc_Space_TEXT 
					+ CASE WHEN LEN(RTRIM(o.Zip_ADDR)) = 9 THEN '-' + SUBSTRING(o.Zip_ADDR, 6, 4) ELSE '' END
					+ @Lc_Space_TEXT + o.Country_ADDR,
            @Ls_Transmittal2Action5_TEXT = o.Fein_IDNO
		FROM EHIS_Y1 AS a,
            OTHP_Y1 AS o
		WHERE a.MemberMci_IDNO = @An_NcpMemberMci_IDNO
			AND dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() BETWEEN a.BeginEmployment_DATE AND a.EndEmployment_DATE
			AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
			AND a.TransactionEventSeq_NUMB = (SELECT MAX(e.TransactionEventSeq_NUMB) AS expr
                                            FROM EHIS_Y1 e
                                           WHERE e.MemberMci_IDNO = a.MemberMci_IDNO
                                             AND dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE
                                             AND e.Status_CODE = @Lc_VerificationStatusGood_CODE)
			AND a.OthpPartyEmpl_IDNO = o.OtherParty_IDNO
			AND o.EndValidity_DATE = @Ld_High_DATE;
   END
   ELSE IF (@Ac_Function_CODE = @Lc_FunctionCollection_CODE
         AND @Ac_Action_CODE = @Lc_ActionProvision_CODE
         AND @Ac_Reason_CODE = @Lc_ReasonCitax_CODE)
   BEGIN
       SET @Ls_Sql_TEXT = 'SELECT DSBL_Y1';
       SELECT @Ld_Disburse_DATE = MAX(fci.Disburse_DATE),
              @Ln_Disburse_AMNT = SUM(fci.Disburse_AMNT)
         FROM (SELECT a.Disburse_DATE,
                      a.Disburse_AMNT
                FROM DSBL_Y1 AS a
                WHERE a.Case_IDNO =@An_Case_IDNO
                  AND a.CheckRecipient_ID = @An_CpMemberMci_IDNO 
                  AND a.CheckRecipient_CODE = '1'
                  AND a.Disburse_DATE = @Ad_Transaction_DATE
                  AND EXISTS (SELECT 1 AS expr
                                FROM RCTH_Y1 AS c
                               WHERE c.SourceBatch_CODE = a.SourceBatch_CODE
                                 AND c.Batch_DATE = a.Batch_DATE
                                 AND c.Batch_NUMB = a.Batch_NUMB
                                 AND c.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                 AND c.SourceReceipt_CODE = @Lc_ReceiptSrcSpecialCollection_CODE
                                 AND c.EndValidity_DATE = @Ld_High_DATE)) AS fci

      IF @Ld_Disburse_DATE IS NOT NULL
	  BEGIN
	    SET @Lc_DisburseDate_TEXT = CONVERT(VARCHAR, @Ld_Disburse_DATE, @Li_DateFormat_NUMB);
	  END;

	  IF @Ln_Disburse_AMNT <> 0
	  BEGIN
	    SET @Lc_DisburseAmount_TEXT = CONVERT(VARCHAR,CAST((@Ln_Disburse_AMNT) AS MONEY), 1);
	  END;

	  IF (@Ld_Disburse_DATE IS NOT NULL) OR (@Ln_Disburse_AMNT <> 0)
	  BEGIN
	    SET @Ls_Transmittal2Action1_TEXT = @Ls_ReasonCitax_Text1 + @Lc_DisburseAmount_TEXT  + @Ls_ReasonCitax_Text2;
	  END;

       SET @Ld_Disburse_DATE = NULL;
       SET @Ln_Disburse_AMNT = 0;
       SET @Lc_DisburseDate_TEXT = '';
	   SET @Lc_DisburseAmount_TEXT = '';

       SELECT @Ld_Disburse_DATE = MAX(fci.Disburse_DATE),
              @Ln_Disburse_AMNT = SUM(fci.Disburse_AMNT)
         FROM (SELECT a.Disburse_DATE,
                      a.Disburse_AMNT
                 FROM DSBL_Y1 AS a
                WHERE a.Case_IDNO = @An_Case_IDNO
                  AND a.CheckRecipient_ID = @An_CpMemberMci_IDNO 
                  AND a.CheckRecipient_CODE = '1'
                  AND a.Disburse_DATE = @Ad_Transaction_DATE
                  AND EXISTS (SELECT 1 AS expr
                                FROM RCTH_Y1 AS c
                               WHERE c.SourceBatch_CODE = a.SourceBatch_CODE
                                 AND c.Batch_DATE = a.Batch_DATE
                                 AND c.Batch_NUMB = a.Batch_NUMB
                                 AND c.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                 AND c.SourceReceipt_CODE IN (@Lc_ReceiptSrcHomesteadRebate_CODE, @Lc_ReceiptSrcSaverRebate_CODE, @Lc_ReceiptSrcStateTaxRefund_CODE)
                                 AND c.EndValidity_DATE = @Ld_High_DATE)) AS fci

      IF @Ld_Disburse_DATE IS NOT NULL
	  BEGIN
	    SET @Lc_DisburseDate_TEXT = CONVERT(VARCHAR, @Ld_Disburse_DATE, @Li_DateFormat_NUMB);
	  END;

	  IF @Ln_Disburse_AMNT <> 0
	  BEGIN
	    SET @Lc_DisburseAmount_TEXT = CONVERT(VARCHAR,CAST((@Ln_Disburse_AMNT) AS MONEY), 1);
	  END;

	  IF (@Ld_Disburse_DATE IS NOT NULL) OR (@Ln_Disburse_AMNT <> 0)
	  BEGIN
	    SET @Ls_Transmittal2Action2_TEXT = @Lc_State_CODE + ' ' + @Lc_DisburseDate_TEXT  + ' ' + @Lc_DisburseAmount_TEXT;
	  END;

       SET @Ld_Disburse_DATE = NULL;
       SET @Ln_Disburse_AMNT = 0;
       SET @Lc_DisburseDate_TEXT = '';
	   SET @Lc_DisburseAmount_TEXT = '';
   END
	
	SELECT @Lc_RefAssist_CODE = c.RefAssist_CODE  
    FROM CFAR_Y1 c  
   WHERE c.Function_CODE = @Ac_Function_CODE  
     AND c.Action_CODE = @Ac_Action_CODE  
     AND c.Reason_CODE = ISNULL(@Ac_Reason_CODE,@Lc_Empty_TEXT)  
     AND c.Obsolete_INDC = @Lc_ObsoleteNo_INDC;
     
    IF ( @Lc_RefAssist_CODE = @Lc_RefAssistR_CODE )
		BEGIN     
		     SELECT @Ls_Description_TEXT = STUFF((SELECT @Lc_Semicolon_TEXT +
			    (SELECT 
					 R.DescriptionValue_TEXT  
						FROM REFM_Y1 R  
					   WHERE R.Table_ID = @Lc_TableImcl_ID  
						 AND R.TableSub_ID = @Lc_TableSubUifs_ID   
						 AND R.Value_CODE = a.Notice_ID)
			    FROM FFCL_Y1 a  
			    JOIN CFAR_Y1 b  
					ON b.Action_CODE = a.Action_CODE  
					AND b.Function_CODE = a.Function_CODE  
					AND b.Reason_CODE = a.Reason_CODE  
			    WHERE a.Function_CODE = @Ac_Function_CODE  
				 AND a.Action_CODE = @Ac_Action_CODE  
				 AND a.Reason_CODE = ISNULL(@Ac_Reason_CODE,@Lc_Empty_TEXT)  
				 AND a.EndValidity_DATE = @Ld_High_DATE
				 FOR XML PATH('')), 1, 1, '')
				 IF(ISNULL(@Ls_Description_TEXT,@Lc_Empty_TEXT) <> @Lc_Empty_TEXT OR @Ls_Description_TEXT <> @Lc_Empty_TEXT)
					BEGIN	
						SET @Ls_Description_TEXT = @Ls_Description_TEXT + @Lc_Semicolon_TEXT;
						SET @Ls_Description_TEXT = @Ls_Comments_Text2 + @Ls_Description_TEXT;
					END
		END     
    ELSE IF ((@Ac_Function_CODE = @Lc_FunctionEstablishment_CODE
			  AND @Ac_Action_CODE = @Lc_ActionAcknowledge_CODE
			  AND @Ac_Reason_CODE = @Lc_ReasonAadin_CODE)
         OR (@Ac_Function_CODE = @Lc_FunctionEnforcement_CODE
			  AND @Ac_Action_CODE = @Lc_ActionAcknowledge_CODE
			  AND @Ac_Reason_CODE = @Lc_ReasonAadin_CODE) 
	     OR (@Ac_Function_CODE = @Lc_FunctionPaternity_CODE
			  AND @Ac_Action_CODE = @Lc_ActionAcknowledge_CODE
			  AND @Ac_Reason_CODE = @Lc_ReasonAadin_CODE)) 
         BEGIN 
				SELECT @Ls_Description_TEXT = STUFF((SELECT @Lc_Semicolon_TEXT +
					(SELECT ISNULL ((SELECT b.DescriptionValue_TEXT  
						FROM REFM_Y1 b  
							WHERE b.Value_CODE = a.Notice_ID  
							AND Table_ID = @Lc_TableImcl_ID  
							AND TableSub_ID = @Lc_TableSubUifs_ID), (SELECT n.DescriptionNotice_TEXT  
																		FROM NREF_Y1 n  
																		WHERE n.Notice_ID = a.Notice_ID  
																		AND Endvalidity_DATE = @Ld_High_DATE)) AS DescriptionValue_TEXT  
							FROM CAIN_Y1 a  
							JOIN CTHB_Y1 c  
								ON c.TransHeader_IDNO = a.TransHeader_IDNO  
								AND c.Transaction_DATE = a.Transaction_DATE  
								AND c.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE  
							JOIN CFAR_Y1 b  
								ON b.Action_CODE = c.Action_CODE  
								AND b.Function_CODE = c.Function_CODE  
								AND b.Reason_CODE = c.Reason_CODE  
								WHERE c.Case_IDNO = @An_Case_IDNO  
									AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE 
									AND a.Received_INDC = @Lc_ReceivedNo_INDC  
									AND a.EndValidity_DATE = @Ld_High_DATE  
									AND b.RefAssist_CODE = @Lc_RefAssistR_CODE  
									AND EXISTS (SELECT 1  
													FROM ICAS_Y1 S  
														WHERE c.Case_IDNO = s.Case_IDNO  
															AND s.RespondInit_CODE <> @Lc_RespondInitInstate_CODE  
															AND s.EndValidity_DATE = @Ld_High_DATE))
														FOR XML PATH('')), 1, 1, '')	
														
						IF(ISNULL(@Ls_Description_TEXT,@Lc_Empty_TEXT) <> @Lc_Empty_TEXT OR @Ls_Description_TEXT <> @Lc_Empty_TEXT)
						BEGIN														
							SET @Ls_Description_TEXT = @Ls_Description_TEXT + @Lc_Semicolon_TEXT;
							SET @Ls_Description_TEXT = @Ls_Comments_Text1 + @Ls_Description_TEXT;
						END
         END
    ELSE
		BEGIN
				SET @Ls_Description_TEXT = @Lc_Empty_TEXT;
		END
		
 SELECT @Ls_Comments_TEXT= @Ls_Description_TEXT + @Lc_Empty_TEXT + DescriptionComments_TEXT
    FROM CSPR_Y1 c 
 WHERE c.Request_IDNO = @Lc_Request_IDNO
			AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
			AND c.EndValidity_DATE = @Ld_High_DATE;

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT ISNULL(CAST(@Ls_Transmittal2Action1_TEXT AS VARCHAR(800)),'') AS Transmittal2Action1_TEXT,
                   ISNULL(CAST(@Ls_Transmittal2Action2_TEXT AS VARCHAR(800)),'') AS Transmittal2Action2_TEXT,
                   ISNULL(CAST(@Ls_Transmittal2Action3_TEXT AS VARCHAR(800)),'') AS Transmittal2Action3_TEXT,
                   ISNULL(CAST(@Ls_Transmittal2Action4_TEXT AS VARCHAR(800)),'') AS Transmittal2Action4_TEXT,
                   ISNULL(CAST(@Ls_Transmittal2Action5_TEXT AS VARCHAR(800)),'') AS Transmittal2Action5_TEXT,
                   ISNULL(CAST(@Ls_Comments_TEXT AS VARCHAR(800)),'') AS Comments_TEXT) up UNPIVOT (tag_value FOR tag_name IN 
											( Transmittal2Action1_TEXT, Transmittal2Action2_TEXT, Transmittal2Action3_TEXT, 
											Transmittal2Action4_TEXT, Transmittal2Action5_TEXT, Comments_TEXT )) AS pvt);

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE (),
            @Ls_DescriptionError_TEXT VARCHAR (4000);

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Routine_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
